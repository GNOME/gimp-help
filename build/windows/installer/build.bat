@echo off
if "%1"=="" goto help
for /a:d %l in (N:\gimp\output\2.10.12\x86_64-w64-mingw32\share\gimp\2.0\help\*) if not "%l"=="N:\gimp\output\2.10.12\x86_64-w64-mingw32\share\gimp\2.0\help\." .and. not "%l"=="N:\gimp\output\2.10.12\x86_64-w64-mingw32\share\gimp\2.0\help\.." (
	echo %@name[%l]
	start "" /LOW "D:\Program Files\Inno Setup 6 Dev\iscc.exe" "Gimp - Help.iss" /DVERSION="%1" /DLANG="%@name[%l]"
)
goto end
:help
echo Usage: %0 version
goto end
:end
