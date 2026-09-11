message('pot/menus/colors')

##############

pot_colors_auto = 'auto.pot'

input_files  = xml_sources_colors_auto
output_pot = pot_colors_auto

plain_input  = xml_sources_colors_auto_files

pot_folder     = 'src/menus/colors/auto/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/auto': input_files}

colors_auto_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_colors_components = 'components.pot'

input_files  = xml_sources_colors_components
output_pot = pot_colors_components

plain_input  = xml_sources_colors_components_files

pot_folder     = 'src/menus/colors/components/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/components': input_files}

colors_components_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_colors_desaturate = 'desaturate.pot'

input_files  = xml_sources_colors_desaturate
output_pot = pot_colors_desaturate

plain_input  = xml_sources_colors_desaturate_files

pot_folder     = 'src/menus/colors/desaturate/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/desaturate': input_files}

colors_desaturate_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_colors_info = 'info.pot'

input_files  = xml_sources_colors_info
output_pot = pot_colors_info

plain_input  = xml_sources_colors_info_files

pot_folder     = 'src/menus/colors/info/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/info': input_files}

colors_info_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_colors_map = 'colors_map.pot'

input_files  = xml_sources_colors_map
output_pot = pot_colors_map

plain_input  = xml_sources_colors_map_files

pot_folder     = 'src/menus/colors/map/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/map': input_files}

colors_map_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_colors_tone_mapping = 'tone-mapping.pot'

input_files  = xml_sources_colors_tone_mapping
output_pot = pot_colors_tone_mapping

plain_input  = xml_sources_colors_tone_mapping_files

pot_folder     = 'src/menus/colors/tone-mapping/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'menus/colors/tone-mapping': input_files}

colors_tone_mapping_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)
