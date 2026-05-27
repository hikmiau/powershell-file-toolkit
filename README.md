> [!NOTE]
> This is a legacy Windows/PowerShell project from my previous Windows setup.
>
> I currently use Arch Linux with dwm, Neovim, Kitty, fish, and Git as my main development environment, so this repository is no longer actively maintained.
>
> The project is kept public as part of my learning history and portfolio.

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

```text
powershell-file-toolkit
|-- config
|   `-- toolkit.json
|-- reports
|   `-- .gitkeep
|-- scripts
|   |-- Clean-EmptyFolders.ps1
|   |-- Find-Duplicates.ps1
|   |-- Organize-Folder.ps1
|   `-- Scan-Folder.ps1
|-- toolkit.bat
|-- .gitignore
`-- README.md
```
