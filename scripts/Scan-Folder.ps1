param(
    [string]$Path,
    [string]$Config = "$PSScriptRoot\..\config\toolkit.json",
    [switch]$Recurse,
    [switch]$Export
)

function Expand-PathValue {
    param([string]$Value)
    [Environment]::ExpandEnvironmentVariables($Value)
}

function Format-Size {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }

    if ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }

    if ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }

    return "$Bytes B"
}

$configData = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json

if (-not $Path) {
    $Path = Expand-PathValue $configData.targetPath
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Target path not found: $Path"
}

$files = Get-ChildItem -LiteralPath $Path -File -Recurse:$Recurse -ErrorAction SilentlyContinue
$folders = Get-ChildItem -LiteralPath $Path -Directory -Recurse:$Recurse -ErrorAction SilentlyContinue

$totalSize = ($files | Measure-Object Length -Sum).Sum

if (-not $totalSize) {
    $totalSize = 0
}

$extensionStats = $files |
    Group-Object {
        if ([string]::IsNullOrWhiteSpace($_.Extension)) {
            "[no extension]"
        } else {
            $_.Extension.ToLowerInvariant()
        }
    } |
    Sort-Object Count -Descending |
    Select-Object Name, Count

$largestFiles = $files |
    Sort-Object Length -Descending |
    Select-Object -First $configData.topCount Name, FullName, @{Name="Size"; Expression={ Format-Size $_.Length }}

$oldLimit = (Get-Date).AddDays(-[int]$configData.oldFileDays)

$oldFiles = $files |
    Where-Object { $_.LastWriteTime -lt $oldLimit } |
    Sort-Object LastWriteTime |
    Select-Object -First $configData.topCount Name, FullName, LastWriteTime

$emptyFolders = $folders |
    Where-Object {
        -not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue | Select-Object -First 1)
    } |
    Select-Object FullName

$report = [ordered]@{
    ScannedPath = $Path
    Recursive = [bool]$Recurse
    TotalFiles = $files.Count
    TotalFolders = $folders.Count
    TotalSize = Format-Size $totalSize
    FileTypes = $extensionStats
    LargestFiles = $largestFiles
    OldFiles = $oldFiles
    EmptyFolders = $emptyFolders
}

Write-Host ""
Write-Host "Folder scanner" -ForegroundColor Cyan
Write-Host "Path: $Path"
Write-Host "Files: $($files.Count)"
Write-Host "Folders: $($folders.Count)"
Write-Host "Total size: $(Format-Size $totalSize)"
Write-Host ""

Write-Host "File types:" -ForegroundColor Cyan
$extensionStats | Format-Table -AutoSize

Write-Host "Largest files:" -ForegroundColor Cyan
$largestFiles | Format-Table -AutoSize

Write-Host "Old files:" -ForegroundColor Cyan
$oldFiles | Format-Table -AutoSize

Write-Host "Empty folders:" -ForegroundColor Cyan
$emptyFolders | Format-Table -AutoSize

if ($Export) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $output = Join-Path "$PSScriptRoot\..\reports" "folder-report-$timestamp.json"
    $report | ConvertTo-Json -Depth 10 | Set-Content $output -Encoding utf8
    Write-Host "Report saved to: $output" -ForegroundColor Green
}
