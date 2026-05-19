param(
    [string]$Path,
    [string]$Config = "$PSScriptRoot\..\config\toolkit.json",
    [switch]$Recurse,
    [switch]$Clean
)

function Expand-PathValue {
    param([string]$Value)
    [Environment]::ExpandEnvironmentVariables($Value)
}

$configData = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json

if (-not $Path) {
    $Path = Expand-PathValue $configData.targetPath
}

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Target path not found: $Path"
}

$folders = Get-ChildItem -LiteralPath $Path -Directory -Recurse:$Recurse -Force -ErrorAction SilentlyContinue |
    Sort-Object { $_.FullName.Length } -Descending

$emptyFolders = @()

foreach ($folder in $folders) {
    $hasContent = Get-ChildItem -LiteralPath $folder.FullName -Force -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $hasContent) {
        $emptyFolders += $folder
    }
}

if ($emptyFolders.Count -eq 0) {
    Write-Host "No empty folders found." -ForegroundColor Yellow
    return
}

foreach ($folder in $emptyFolders) {
    [pscustomobject]@{
        Folder = $folder.FullName
        Mode = if ($Clean) { "Removed" } else { "Preview" }
    }

    if ($Clean) {
        Remove-Item -LiteralPath $folder.FullName -Force -ErrorAction SilentlyContinue
    }
}

if (-not $Clean) {
    Write-Host "Preview only. Run with -Clean to remove empty folders." -ForegroundColor Cyan
}
