win_installer_files = [
    # InnoSetup script and include files
    'gimp-help.iss',
    'version.isi',
    'languages.isi',
    # Images for the installer
    'big.bmp',
    'small.bmp',
]


installer_files_all = []
foreach file: win_installer_files
    copied_file = fs.copyfile(file)

    installer_files_all += copied_file
endforeach

subdir('lang')
