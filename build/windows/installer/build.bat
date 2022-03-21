@echo off
if "%1"=="" goto help
if "%2"=="" goto help
if "%3"=="" goto help

if [%INNOPATH%]==[] (
FOR /F "usebackq tokens=5,* skip=2" %%A IN (`REG QUERY "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v "Inno Setup: App Path" /reg:32`) DO set INNOPATH=%%B
) else (if [%INNOPATH%]==[] (
FOR /F "usebackq tokens=5,* skip=2" %%A IN (`REG QUERY "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1" /v "Inno Setup: App Path" /reg:32`) DO set INNOPATH=%%B
))
if not exist "%INNOPATH%\iscc.exe" goto noinno

echo "%INNOPATH%"
FOR /D %%l in (..\..\..\htdocs\%1.%2\*) DO if not "%%l"=="..\..\..\htdocs\%1.%2\." (
    if not "%%l"=="..\..\..\htdocs\%1.%2\.." (
        if not "%%l"=="..\..\..\htdocs\%1.%2\pdf" (
            echo Creating installer for %%~nxl
            "%INNOPATH%\iscc.exe" "gimp-help.iss" /DMAJORVERSION="%1" /DMINORVERSION="%2" /DMICROVERSION="%3" /DLANG="%%~nxl" /DHELPDIR="..\..\..\htdocs\%1.%2"
        )
    )
)
goto end

:help
echo Usage: %0 version
goto end

:noinno
echo Inno Setup path could not be read from Registry - install Inno Setup or set INNOPATH environment variable pointing at it's
echo install directory
goto :end

:end
