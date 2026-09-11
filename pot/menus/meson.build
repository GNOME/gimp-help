message('pot/menus submenu')

##############

pot_menus_colors = 'colors.pot'

input_files  = xml_sources_menus_colors
output_pot = pot_menus_colors

plain_input  = xml_sources_menus_colors_files

pot_folder     = 'src/menus/colors/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors': input_files}

menus_colors_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_edit = 'edit.pot'

input_files  = xml_sources_menus_edit
output_pot = pot_menus_edit

plain_input  = xml_sources_menus_edit_files

pot_folder     = 'src/menus/edit/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/edit': input_files}

menus_edit_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_file = 'file.pot'

input_files  = xml_sources_menus_file
output_pot = pot_menus_file

plain_input  = xml_sources_menus_file_files

pot_folder     = 'src/menus/file/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/file': input_files}

menus_file_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_filters = 'menus_filters.pot'

input_files  = xml_sources_menus_filters
output_pot = pot_menus_filters

plain_input  = xml_sources_menus_filters_files

pot_folder     = 'src/menus/filters/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/filters': input_files}

menus_filters_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_help = 'help.pot'

input_files  = xml_sources_menus_help
output_pot = pot_menus_help

plain_input  = xml_sources_menus_help_files

pot_folder     = 'src/menus/help/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/help': input_files}

menus_help_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_image = 'image.pot'

input_files  = xml_sources_menus_image
output_pot = pot_menus_image

plain_input  = xml_sources_menus_image_files

pot_folder     = 'src/menus/image/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/image': input_files}

menus_image_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_layer = 'layer.pot'

input_files  = xml_sources_menus_layer
output_pot = pot_menus_layer

plain_input  = xml_sources_menus_layer_files

pot_folder     = 'src/menus/layer/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/layer': input_files}

menus_layer_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_select = 'select.pot'

input_files  = xml_sources_menus_select
output_pot = pot_menus_select

plain_input  = xml_sources_menus_select_files

pot_folder     = 'src/menus/select/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/select': input_files}

menus_select_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_menus_view = 'view.pot'

input_files  = xml_sources_menus_view
output_pot = pot_menus_view

plain_input  = xml_sources_menus_view_files

pot_folder     = 'src/menus/view/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/view': input_files}

menus_view_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)


subdir('colors')
