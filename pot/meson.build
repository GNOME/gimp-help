message('pot submenu')

### FIXME: Comments referencing source should be relative but are ABDSOLUTE!!!!!!!!!!!!!

pot_gimp_help = 'gimp.pot'

output_pot = pot_gimp_help
input_files = xml_sources_root

gimp_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_lists = {}

pot_appendix = 'appendix.pot'
output_pot   = pot_appendix
input_files  = xml_sources_appendix

xml_sources_lists += { 'appendix': input_files}

appendix_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_concepts = 'concepts.pot'
input_files  = xml_sources_concepts
output_pot   = pot_concepts

xml_sources_lists += { 'concepts': input_files}

concepts_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_dialogs = 'dialogs.pot'
input_files = xml_sources_dialogs
output_pot  = pot_dialogs

xml_sources_lists += { 'dialogs': input_files}

dialogs_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
   ],
)

##############

pot_filters = 'filters.pot'
input_files = xml_sources_filters
output_pot  = pot_filters

xml_sources_lists += { 'filters': input_files}

filters_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_glossary = 'glossary.pot'
input_files  = xml_sources_glossary
output_pot   = pot_glossary

xml_sources_lists += { 'glossary': input_files}

glossary_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_introduction = 'introduction.pot'
input_files  = xml_sources_introduction
output_pot   = pot_introduction

xml_sources_lists += { 'introduction': input_files}

introduction_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_menus   = 'menus.pot'
input_files = xml_sources_menus
output_pot  = pot_menus

xml_sources_lists += { 'menus': input_files}

menus_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_preface = 'preface.pot'
input_files = xml_sources_preface
output_pot  = pot_preface

xml_sources_lists += { 'preface': input_files}

preface_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_toolbox = 'toolbox.pot'
input_files = xml_sources_toolbox
output_pot  = pot_toolbox

xml_sources_lists += { 'toolbox': input_files}

toolbox_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_tutorial = 'tutorial.pot'
input_files  = xml_sources_tutorial
output_pot   = pot_tutorial

xml_sources_lists += { 'tutorial': input_files}

tutorial_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

pot_using   = 'using.pot'
input_files = xml_sources_using
output_pot  = pot_using

xml_sources_lists += { 'using': input_files}

using_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    input: [input_files],
    output: [output_pot],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

#########################


subdir('filters')
subdir('menus')
subdir('toolbox')

pot_dependencies = [
    # root folder
    gimp_pot, appendix_pot, concepts_pot, dialogs_pot, filters_pot,
    glossary_pot, introduction_pot, menus_pot, preface_pot,
    toolbox_pot, tutorial_pot, using_pot,
    # filters
    filters_animation_pot, filters_artistic_pot, filters_blur_pot,
    filters_combine_pot, filters_decor_pot, filters_distort_pot,
    filters_edge_detect_pot, filters_enhance_pot, filters_generic_pot,
    filters_light_and_shadow_pot, filters_map_pot, filters_noise_pot,
    filters_render_pot, filters_web_pot,
    # menus
    menus_colors_pot, menus_edit_pot, menus_file_pot, menus_filters_pot,
    menus_help_pot, menus_image_pot, menus_layer_pot, menus_select_pot,
    menus_view_pot,
    # menus/colors
    colors_auto_pot, colors_components_pot, colors_desaturate_pot,
    colors_info_pot, colors_map_pot, colors_tone_mapping_pot,
    # toolbox
    toolbox_paint_pot, toolbox_selection_pot, toolbox_transform_pot,
    ]
