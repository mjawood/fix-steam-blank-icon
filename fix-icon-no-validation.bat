@echo off
setlocal enabledelayedexpansion

REM If no arguments, show help
if "%~1"=="" (
    echo Usage: fix-icon.bat path1 [path2 ...]
    echo You can use wildcards, e.g. *.url or *.lnk
    exit /b 1
)

REM Expand each argument (including wildcards) safely
for %%A in (%*) do (
    call :fix_icon "%%~A"
)

echo All done.
exit /b 0


REM =========================================
REM FUNCTION: fix_icon
REM =========================================
:fix_icon
set "shortcut=%~1"

REM Example debug
echo Processing: "%shortcut%"

REM Check if the file is a .url file
if /I not "%~x1" == ".url" (
    echo File is not a .url file.
    exit /b 1
)

REM Check if the file exists
if not exist "%~1" (
    echo File does not exist.
    exit /b 1
)

REM Read the file line by line
for /f "usebackq delims=" %%i in ("%~1") do set "%%~i" 2>nul

REM Validate the URL and extract the game ID
if "%URL:~0,18%" == "steam://rungameid/" set "gameid=%URL:~18%"
if not defined gameid (
    echo Invalid URL: "%URL%"
    exit /b 1
)

REM Check if icon file already exists
if exist "%IconFile%" (
    echo Icon file already exists: "%IconFile%"
    exit /b 1
)

REM Extract the icon file name
for %%f in ("%IconFile%") do set "icon_name=%%~nxf"
if not defined icon_name (
    echo Invalid icon file path: "%IconFile%"
    exit /b 1
)

REM Download the icon file
REM Icon location is written on: https://steamdb.info/app/{gameid}/info/
set "icon_url=https://cdn.cloudflare.steamstatic.com/steamcommunity/public/images/apps/%gameid%/%icon_name%"
echo Downloading icon file: "%icon_url%"
curl -o "%IconFile%" "%icon_url%"

exit /b 0
