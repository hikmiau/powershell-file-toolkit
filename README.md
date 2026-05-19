# powershell-file-toolkit

A PowerShell toolkit for organizing, scanning, cleaning, and checking files in a folder.

## Features

- Organize files by extension
- Scan folders and show file statistics
- Find duplicate files by SHA256 hash
- Move duplicates into a safe folder
- Find empty folders
- Remove empty folders only when requested
- Export reports
- Use a JSON config file
- Run from PowerShell or from a batch menu

## Usage

Preview organization:

    .\scripts\Organize-Folder.ps1 -DryRun

Organize default folder:

    .\scripts\Organize-Folder.ps1

Scan folder:

    .\scripts\Scan-Folder.ps1

Scan recursively:

    .\scripts\Scan-Folder.ps1 -Recurse

Export scan report:

    .\scripts\Scan-Folder.ps1 -Recurse -Export

Find duplicates:

    .\scripts\Find-Duplicates.ps1 -Recurse

Preview moving duplicates:

    .\scripts\Find-Duplicates.ps1 -Recurse -MoveDuplicates -DryRun

Move duplicates:

    .\scripts\Find-Duplicates.ps1 -Recurse -MoveDuplicates

Preview empty folders:

    .\scripts\Clean-EmptyFolders.ps1 -Recurse

Remove empty folders:

    .\scripts\Clean-EmptyFolders.ps1 -Recurse -Clean

## Batch menu

Run:

    toolkit.bat

## Configuration

Edit:

    config\toolkit.json

Default folder:

    %USERPROFILE%\Downloads

## Structure

    powershell-file-toolkit
    â”œâ”€â”€ config
    â”‚   â””â”€â”€ toolkit.json
    â”œâ”€â”€ reports
    â”‚   â””â”€â”€ .gitkeep
    â”œâ”€â”€ scripts
    â”‚   â”œâ”€â”€ Clean-EmptyFolders.ps1
    â”‚   â”œâ”€â”€ Find-Duplicates.ps1
    â”‚   â”œâ”€â”€ Organize-Folder.ps1
    â”‚   â””â”€â”€ Scan-Folder.ps1
    â”œâ”€â”€ toolkit.bat
    â”œâ”€â”€ .gitignore
    â””â”€â”€ README.md
