message('pot/menus/colors')

##############

xml_sources_colors_auto = [
    'color-enhance.xml',
    'equalize.xml',
    'stretch-contrast-hsv.xml',
    'stretch-contrast.xml',
    'white-balance.xml',
]
pot_colors_auto = 'auto.pot'

input_xml  = xml_sources_colors_auto
output_pot = pot_colors_auto

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/auto/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_auto_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_colors_components = [
    'channel-mixer.xml',
    'compose.xml',
    'decompose.xml',
    'extract-component.xml',
    'mono-mixer.xml',
    'recompose.xml',
]
pot_colors_components = 'components.pot'

input_xml  = xml_sources_colors_components
output_pot = pot_colors_components

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/components/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_components_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_colors_desaturate = [
    'color-to-gray.xml',
    'desaturate.xml',
    'mono-mixer.xml',
    'sepia.xml',
]
pot_colors_desaturate = 'desaturate.pot'

input_xml  = xml_sources_colors_desaturate
output_pot = pot_colors_desaturate

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/desaturate/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_desaturate_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_colors_info = [
    'borderaverage.xml',
    'export-histogram.xml',
    'histogram.xml',
    'smooth_palette.xml',
]
pot_colors_info = 'info.pot'

input_xml  = xml_sources_colors_info
output_pot = pot_colors_info

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/info/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_info_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_colors_map = [
    'alien-map.xml',
    'color-exchange.xml',
    'color-rotate.xml',
    'gradientmap.xml',
    'palettemap.xml',
    'rearrange-colormap.xml',
    'sample-colorize.xml',
    'set-colormap.xml',
]
pot_colors_map = 'map.pot'

input_xml  = xml_sources_colors_map
output_pot = pot_colors_map

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/map/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_map_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_colors_tone_mapping = [
    'destripe.xml',
    'fattal.xml',
    'mantiuk.xml',
    'reinhard.xml',
    'retinex.xml',
    'stress.xml',
]
pot_colors_tone_mapping = 'tone-mapping.pot'

input_xml  = xml_sources_colors_tone_mapping
output_pot = pot_colors_tone_mapping

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/tone-mapping/'
output_dir     = meson.project_build_root()  + '/pot/menus/colors'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

colors_tone_mapping_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

#subdir('auto')
#subdir('components')
#subdir('desaturate')
#subdir('info')
#subdir('map')
#subdir('tone-mapping')
