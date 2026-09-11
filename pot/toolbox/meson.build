message('pot/toolbox')

##############

pot_toolbox_paint = 'paint.pot'

input_files  = xml_sources_toolbox_paint
output_pot = pot_toolbox_paint

plain_input  = xml_sources_toolbox_paint_files

pot_folder     = 'src/toolbox/paint/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'toolbox/paint': input_files}

toolbox_paint_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_toolbox_selection = 'selection.pot'

input_files  = xml_sources_toolbox_selection
output_pot = pot_toolbox_selection

plain_input  = xml_sources_toolbox_selection_files

pot_folder     = 'src/toolbox/selection/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'toolbox/selection': input_files}

toolbox_selection_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)

##############

pot_toolbox_transform = 'transform.pot'

input_files  = xml_sources_toolbox_transform
output_pot = pot_toolbox_transform

plain_input  = xml_sources_toolbox_transform_files

pot_folder     = 'src/toolbox/transform/'
relative_input = []
foreach file : plain_input
    relative_input += pot_folder + file
endforeach

xml_sources_lists += { 'toolbox/transform': input_files}

toolbox_transform_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', relative_input,
    ],
)
