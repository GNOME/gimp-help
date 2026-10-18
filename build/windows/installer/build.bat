@echo off
if "%1"=="" goto help
if "%2"=="" goto help
if "%3"=="" goto help

if not "%4"=="" (
    set htmlpath=%4
) else (
    set htmlpath=..\..\..\htdocs\%1.%2
)
echo %htmlpath%

if [%INNOPATH%]==[] (
FOR /F "usebackq tokens=5,* skip=2" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v "Inno Setup: App Path" /reg:32`) DO set INNOPATH=%%B
) else (if [%INNOPATH%]==[] (
FOR /F "usebackq tokens=5,* skip=2" %%A IN (`REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v "Inno Setup: App Path" /reg:32`) DO set INNOPATH=%%B
))
if not exist "%INNOPATH%\iscc.exe" goto noinno

if not exist "%htmlpath%" goto nohtml

echo "%INNOPATH%"
FOR /D %%l in (%htmlpath%\*) DO if not "%%l"=="%htmlpath%\." (
    if not "%%l"=="%htmlpath%\.." (
        if not "%%l"=="%htmlpath%\pdf" (
            echo Creating installer for %%~nxl
            "%INNOPATH%\iscc.exe" "gimp-help.iss" /DMAJORVERSION="%1" /DMINORVERSION="%2" /DMICROVERSION="%3" /DLANG="%%~nxl" /DHELPDIR="%htmlpath%"
        )
    )
)
goto end

:help
echo Usage: %0 version [htmlpath]
goto end

:noinno
echo Inno Setup path could not be read from Registry - install Inno Setup or set INNOPATH environment variable pointing at it's
echo install directory
goto :end

:nohtml
echo The html files could not be found.
goto :end

:end
