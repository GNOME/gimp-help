message('pot/toolbox')

##############

xml_sources_toolbox_paint = [
    'about-common-paint-options.xml',
    'airbrush.xml',
    'blur-sharpen.xml',
    'brush-tools.xml',
    'bucket-fill.xml',
    'clone.xml',
    'common-features.xml',
    'dodge-burn.xml',
    'dynamics.xml',
    'eraser.xml',
    'gradient.xml',
    'heal.xml',
    'ink.xml',
    'MyPaint-brush.xml',
    'paintbrush.xml',
    'pencil.xml',
    'perspective-clone.xml',
    'smudge.xml',
]
pot_toolbox_paint = 'paint.pot'

input_xml  = xml_sources_toolbox_paint
output_pot = pot_toolbox_paint

input_files = []
input_base_dir = meson.project_source_root() + '/src/toolbox/paint/'
output_dir     = meson.project_build_root()  + '/pot/toolbox'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

toolbox_paint_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_toolbox_selection = [
    'about-common-select-modifiers.xml',
    'about-common-select-options.xml',
    'by-color.xml',
    'common-features.xml',
    'ellipse.xml',
    'foreground.xml',
    'free.xml',
    'fuzzy.xml',
    'iscissors.xml',
    'rectangle.xml',
]
pot_toolbox_selection = 'selection.pot'

input_xml  = xml_sources_toolbox_selection
output_pot = pot_toolbox_selection

input_files = []
input_base_dir = meson.project_source_root() + '/src/toolbox/selection/'
output_dir     = meson.project_build_root()  + '/pot/toolbox'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

toolbox_selection_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_toolbox_transform = [
    'about-common-transform-options.xml',
    'align.xml',
    'cage.xml',
    'common-features.xml',
    'crop.xml',
    'flip.xml',
    'handle-transform.xml',
    'move.xml',
    'perspective.xml',
    'rotate.xml',
    'scale.xml',
    'shear.xml',
    'transform-3d.xml',
    'unified-transform.xml',
    'warp-transform.xml',
]
pot_toolbox_transform = 'transform.pot'

input_xml  = xml_sources_toolbox_transform
output_pot = pot_toolbox_transform

input_files = []
input_base_dir = meson.project_source_root() + '/src/toolbox/transform/'
output_dir     = meson.project_build_root()  + '/pot/toolbox'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

toolbox_transform_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)
