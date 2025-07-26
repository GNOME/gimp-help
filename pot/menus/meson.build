message('pot/menus submenu')

##############

xml_sources_menus_colors = [
    'auto.xml',
    'brightness-contrast.xml',
    'color-balance.xml',
    'color-temperature.xml',
    'colorize.xml',
    'colortoalpha.xml',
    'components.xml',
    'curves.xml',
    'desaturate.xml',
    'dither.xml',
    'exposure.xml',
    'gegl-local-threshold.xml',
    'hot.xml',
    'hue-chroma.xml',
    'hue-saturation.xml',
    'info.xml',
    'introduction.xml',
    'invert.xml',
    'levels.xml',
    'linear-invert.xml',
    'map.xml',
    'posterize.xml',
    'rgb-clip.xml',
    'saturation.xml',
    'shadows-highlights.xml',
    'threshold.xml',
    'tone-mapping.xml',
    'value-invert.xml',
]
pot_menus_colors = 'colors.pot'

input_xml  = xml_sources_menus_colors
output_pot = pot_menus_colors

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/colors/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/colors': input_files}

menus_colors_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_edit = [
    'buffer.xml',
    'clear.xml',
    'copy-visible.xml',
    'copy.xml',
    'cut.xml',
    'fill-bg.xml',
    'fill-fg.xml',
    'fill-path.xml',
    'fill-pattern.xml',
    'fill-selection-outline.xml',
    'input-devices.xml',
    'introduction.xml',
    'module-manager.xml',
    'paste-as-brush.xml',
    'paste-as-floating-data-in-place.xml',
    'paste-as-floating-data.xml',
    'paste-as-new-image.xml',
    'paste-as-new-layer-in-place.xml',
    'paste-as-new-layer.xml',
    'paste-as-pattern.xml',
    'paste-as.xml',
    'paste-in-place.xml',
    'paste-into-selection-in-place.xml',
    'paste-into-selection.xml',
    'paste.xml',
    'preferences.xml',
    'redo.xml',
    'shortcuts.xml',
    'stroke-path.xml',
    'stroke-selection.xml',
    'undo-history.xml',
    'undo.xml',
    'units.xml',
]
pot_menus_edit = 'edit.pot'

input_xml  = xml_sources_menus_edit
output_pot = pot_menus_edit

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/edit/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/edit': input_files}

menus_edit_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_file = [
    'close-all.xml',
    'close.xml',
    'copy-location.xml',
    'create-template.xml',
    'create.xml',
    'export-as.xml',
    'export.xml',
    'new.xml',
    'open-as-layer.xml',
    'open-location.xml',
    'open-recent.xml',
    'open.xml',
    'print.xml',
    'quit.xml',
    'revert.xml',
    'save-as-copy.xml',
    'save-as.xml',
    'save.xml',
    'send-by-email.xml',
    'show-in-file-manager.xml',
]
pot_menus_file = 'file.pot'

input_xml  = xml_sources_menus_file
output_pot = pot_menus_file

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/file/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/file': input_files}

menus_file_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_filters = [
    'development.xml',
    'introduction.xml',
    'python-fu.xml',
    'repeat.xml',
    'reset-all.xml',
    'reshow.xml',
    'script-fu.xml',
]
pot_menus_filters = 'filters.pot'

input_xml  = xml_sources_menus_filters
output_pot = pot_menus_filters

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/filters/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/filters': input_files}

menus_filters_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_help = [
    'about.xml',
    'context-help.xml',
    'gimp-online.xml',
    'help.xml',
    'plug-in-browser.xml',
    'procedure-browser.xml',
    'search-and-run.xml',
    'tip-of-the-day.xml',
    'user-manual.xml',
    'welcome-dialog.xml',
]
pot_menus_help = 'help.pot'

input_xml  = xml_sources_menus_help
output_pot = pot_menus_help

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/help/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/help': input_files}

menus_help_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_image = [
    'align-layers.xml',
    'assign-color-profile.xml',
    'canvas-size.xml',
    'color-management.xml',
    'configure-grid.xml',
    'convert-grayscale.xml',
    'convert-indexed.xml',
    'convert-rgb.xml',
    'convert-to-color-profile.xml',
    'crop.xml',
    'discard-color-profile.xml',
    'duplicate.xml',
    'encoding.xml',
    'fit-canvas-to-layers.xml',
    'fit-canvas-to-selection.xml',
    'flatten.xml',
    'guides-new-percent.xml',
    'guides-new-selection.xml',
    'guides-new.xml',
    'guides-remove.xml',
    'guides.xml',
    'introduction.xml',
    'merge-layers.xml',
    'metadata-editor.xml',
    'metadata-viewer.xml',
    'metadata.xml',
    'mode.xml',
    'print-size.xml',
    'properties.xml',
    'save-color-profile-to-file.xml',
    'scale.xml',
    'slice-using-guides.xml',
    'soft-proof-black-point.xml',
    'soft-proof-profile-assign.xml',
    'soft-proof-rendering-intent.xml',
    'transform-flip.xml',
    'transform-rotate.xml',
    'transform.xml',
    'use-srgb-profile.xml',
    'zealous-crop.xml',
]
pot_menus_image = 'image.pot'

input_xml  = xml_sources_menus_image
output_pot = pot_menus_image

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/image/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/image': input_files}

menus_image_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_layer = [
    'alpha-add.xml',
    'alpha-remove.xml',
    'alpha-selection-add.xml',
    'alpha-selection-intersect.xml',
    'alpha-selection-replace.xml',
    'alpha-selection-subtract.xml',
    'alpha-semi-flatten.xml',
    'anchor.xml',
    'bottom.xml',
    'color-to-alpha.xml',
    'crop-to-content.xml',
    'delete.xml',
    'duplicate.xml',
    'flip-horizontal.xml',
    'flip-vertical.xml',
    'introduction.xml',
    'lower-to-bottom.xml',
    'lower.xml',
    'mask-add.xml',
    'mask-apply.xml',
    'mask-delete.xml',
    'mask-disable.xml',
    'mask-edit.xml',
    'mask-selection-add.xml',
    'mask-selection-intersect.xml',
    'mask-selection-replace.xml',
    'mask-selection-subtract.xml',
    'mask-show.xml',
    'mask.xml',
    'merge-down.xml',
    'merge-layer-group.xml',
    'new-from-visible.xml',
    'new-layer-group.xml',
    'new.xml',
    'next.xml',
    'offset.xml',
    'previous.xml',
    'raise-to-top.xml',
    'raise.xml',
    'resize-to-image.xml',
    'resize-to-selection.xml',
    'resize.xml',
    'rotate-180.xml',
    'rotate-270.xml',
    'rotate-90.xml',
    'rotate-arbitrary.xml',
    'scale.xml',
    'stack-reverse.xml',
    'stack.xml',
    'text-along-path.xml',
    'text-commands.xml',
    'text-discard.xml',
    'text-to-path.xml',
    'threshold-alpha.xml',
    'top.xml',
    'transform.xml',
    'transparency.xml',
]
pot_menus_layer = 'layer.pot'

input_xml  = xml_sources_menus_layer
output_pot = pot_menus_layer

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/layer/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/layer': input_files}

menus_layer_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_select = [
    'all.xml',
    'border.xml',
    'by_color.xml',
    'distort.xml',
    'feather.xml',
    'float.xml',
    'from-path.xml',
    'grow.xml',
    'invert.xml',
    'none.xml',
    'qmask-toggle.xml',
    'remove-holes.xml',
    'rounded-rectangle.xml',
    'selection-editor.xml',
    'sharpen.xml',
    'shrink.xml',
    'to-channel.xml',
    'to-path.xml',
]
pot_menus_select = 'select.pot'

input_xml  = xml_sources_menus_select
output_pot = pot_menus_select

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/select/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/select': input_files}

menus_select_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_menus_view = [
    'display-filters.xml',
    'dot-for-dot.xml',
    'flip-rotate.xml',
    'fullscreen.xml',
    'introduction.xml',
    'movetoscreen.xml',
    'navigwindow.xml',
    'new.xml',
    'padding-color.xml',
    'scroll-center.xml',
    'show-all.xml',
    'show-canvas-boundary.xml',
    'show-grid.xml',
    'show-guides.xml',
    'show-layer-boundary.xml',
    'show-menubar.xml',
    'show-rulers.xml',
    'show-sample-points.xml',
    'show-scrollbars.xml',
    'show-selection.xml',
    'show-statusbar.xml',
    'shrink-wrap.xml',
    'snap-to-bounding-boxes.xml',
    'snap-to-canvas.xml',
    'snap-to-equidistance.xml',
    'snap-to-grid.xml',
    'snap-to-guides.xml',
    'snap-to-path.xml',
    'view-black-point.xml',
    'view-color-manage-view.xml',
    'view-color-management-reset.xml',
    'view-color-management.xml',
    'view-mark-out-of-gamut.xml',
    'view-rendering-intent.xml',
    'view-soft-proof.xml',
    'zoom.xml',
]
pot_menus_view = 'view.pot'

input_xml  = xml_sources_menus_view
output_pot = pot_menus_view

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/view/'
output_dir     = meson.project_build_root()  + '/pot/menus'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus/view': input_files}

menus_view_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)


#FIXME
subdir('colors')