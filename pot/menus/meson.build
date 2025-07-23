message('pot submenu')

pot_source_files_root = [
    'gimp.xml',
    'help-missing.xml',
    'introduction.xml',
    'key-reference.xml',
]

target     = 'gimp-help.pot'
#target_pot = pot_base + target

# Debugging help...
message('Creating target for ' + target)

input_files = []
input_base_dir = meson.project_source_root() + '/src/'

foreach xml_file: pot_source_files_root
    input_files += input_base_dir + xml_file
endforeach

#input_files = pot_source_files_root

gimp_pot = custom_target(target,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    #input: input_files,
    output: [target],
    command: [
##        xml2pot, target, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
#        xml2pot, meson.current_build_dir() + '/' + target, meson.project_build_root(), meson.project_source_root(), input_files,
        xml2pot, target, meson.project_build_root() + '/pot', meson.project_source_root(), input_files,
    ],
    #build_by_default: true,
)


# FIXME / TODO:
#subdir('filters')
#subdir('menus')
#subdir('toolbox')
