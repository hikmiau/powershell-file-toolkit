@echo off
setlocal
cd /d "%~dp0"

set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if not exist "%PS%" (
    set "PS=%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
)

if not exist "%PS%" (
    echo PowerShell was not found.
    pause
    exit /b 1
)

"%PS%" -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%~dp0' -Recurse | Unblock-File" >nul 2>nul

:menu
cls
echo ============================
echo   powershell-file-toolkit
echo ============================
echo.
echo 1. Preview organization
echo 2. Organize folder
echo 3. Scan folder
echo 4. Scan folder recursively
echo 5. Export scan report
echo 6. Find duplicates
echo 7. Preview moving duplicates
echo 8. Move duplicates
echo 9. Preview empty folders
echo 10. Clean empty folders
echo Q. Quit
echo.

set /p option="Choose an option: "

if /i "%option%"=="1" goto organize_preview
if /i "%option%"=="2" goto organize
if /i "%option%"=="3" goto scan
if /i "%option%"=="4" goto scan_recursive
if /i "%option%"=="5" goto scan_export
if /i "%option%"=="6" goto duplicates
if /i "%option%"=="7" goto duplicates_preview_move
if /i "%option%"=="8" goto duplicates_move
if /i "%option%"=="9" goto empty_preview
if /i "%option%"=="10" goto empty_clean
if /i "%option%"=="Q" goto end

echo Invalid option.
pause
goto menu

:organize_preview
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Organize-Folder.ps1" -DryRun
echo.
pause
goto menu

:organize
echo This will organize files.
set /p confirm="Continue? Y/N: "
if /i not "%confirm%"=="Y" goto menu
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Organize-Folder.ps1"
echo.
pause
goto menu

:scan
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Scan-Folder.ps1"
echo.
pause
goto menu

:scan_recursive
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Scan-Folder.ps1" -Recurse
echo.
pause
goto menu

:scan_export
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Scan-Folder.ps1" -Recurse -Export
echo.
pause
goto menu

:duplicates
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Find-Duplicates.ps1" -Recurse
echo.
pause
goto menu

:duplicates_preview_move
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Find-Duplicates.ps1" -Recurse -MoveDuplicates -DryRun
echo.
pause
goto menu

:duplicates_move
echo This will move duplicate files to the duplicates folder.
set /p confirm="Continue? Y/N: "
if /i not "%confirm%"=="Y" goto menu
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Find-Duplicates.ps1" -Recurse -MoveDuplicates
echo.
pause
goto menu

:empty_preview
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Clean-EmptyFolders.ps1" -Recurse
echo.
pause
goto menu

:empty_clean
echo This will remove empty folders.
set /p confirm="Continue? Y/N: "
if /i not "%confirm%"=="Y" goto menu
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Clean-EmptyFolders.ps1" -Recurse -Clean
echo.
pause
goto menu

:end
endlocal
exit /b
