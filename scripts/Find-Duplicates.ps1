param(
    [string]$Path,
    [string]$Config = "$PSScriptRoot\..\config\toolkit.json",
    [switch]$Recurse,
    [switch]$Export,
    [switch]$MoveDuplicates,
    [switch]$DryRun
)

function Expand-PathValue {
    param([string]$Value)
    [Environment]::ExpandEnvironmentVariables($Value)
}

function Get-UniquePath {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $Path
    }

    $directory = Split-Path $Path
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $extension = [System.IO.Path]::GetExtension($Path)
    $index = 1

    do {
        $candidate = Join-Path $directory "$name ($index)$extension"
        $index++
    } while (Test-Path -LiteralPath $candidate)

    $candidate
}

$configData = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json

if (-not $Path) {
    $Path = Expand-PathValue $configData.targetPath
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Target path not found: $Path"
}

$duplicateFolder = Join-Path $Path $configData.duplicateFolder

$allFiles = Get-ChildItem -LiteralPath $Path -File -Recurse:$Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        -not $_.FullName.StartsWith($duplicateFolder, [System.StringComparison]::OrdinalIgnoreCase)
    }

$sizeGroups = $allFiles |
    Group-Object Length |
    Where-Object { $_.Count -gt 1 }

if ($sizeGroups.Count -eq 0) {
    Write-Host "No possible duplicates found." -ForegroundColor Yellow
    return
}

$possibleFiles = @($sizeGroups | ForEach-Object { $_.Group })

Write-Host "Possible duplicate files to check: $($possibleFiles.Count)" -ForegroundColor Cyan
Write-Host "Hashing files. This may take a while for large folders..." -ForegroundColor Cyan

$hashResults = @()
$total = $possibleFiles.Count
$current = 0

foreach ($file in $possibleFiles) {
    $current++

    Write-Progress `
        -Activity "Finding duplicates" `
        -Status "Hashing $current of $total files" `
        -PercentComplete (($current / $total) * 100)

    try {
        $hash = Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256
        $hashResults += [pscustomobject]@{
            Hash = $hash.Hash
            Path = $file.FullName
            Name = $file.Name
            Length = $file.Length
        }
    } catch {}
}

Write-Progress -Activity "Finding duplicates" -Completed

$duplicateGroups = $hashResults |
    Group-Object Hash |
    Where-Object { $_.Count -gt 1 }

if ($duplicateGroups.Count -eq 0) {
    Write-Host "No duplicate files found." -ForegroundColor Yellow
    return
}

$results = @()

foreach ($group in $duplicateGroups) {
    $filesInGroup = $group.Group | Sort-Object Path
    $original = $filesInGroup[0]
    $duplicates = $filesInGroup | Select-Object -Skip 1

    foreach ($duplicate in $duplicates) {
        $destination = Get-UniquePath (Join-Path $duplicateFolder $duplicate.Name)

        $results += [pscustomobject]@{
            Hash = $group.Name
            Original = $original.Path
            Duplicate = $duplicate.Path
            To = if ($MoveDuplicates) { $destination } else { "" }
            Mode = if ($MoveDuplicates) {
                if ($DryRun) { "Move preview" } else { "Moved" }
            } else {
                "Found"
            }
        }

        if ($MoveDuplicates -and -not $DryRun) {
            New-Item -ItemType Directory -Force $duplicateFolder | Out-Null
            Move-Item -LiteralPath $duplicate.Path -Destination $destination
        }
    }
}

$results

if ($Export) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $output = Join-Path "$PSScriptRoot\..\reports" "duplicates-report-$timestamp.json"
    $results | ConvertTo-Json -Depth 10 | Set-Content $output -Encoding utf8
    Write-Host "Report saved to: $output" -ForegroundColor Green
}

if ($MoveDuplicates -and $DryRun) {
    Write-Host "Preview only. Run without -DryRun to move duplicates." -ForegroundColor Cyan
}
