message('pot submenu')

# Debugging help...

xml_sources_root = [
    'gimp.xml',
    'help-missing.xml',
    'introduction.xml',
    'key-reference.xml',
]

pot_gimp_help = 'gimp.pot'

input_xml  = xml_sources_root
output_pot = pot_gimp_help

input_files = []
input_base_dir = meson.project_source_root() + '/src/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

gimp_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
#        xml2pot, '@OUTPUT@', '@OUTDIR@', '@SOURCE_ROOT@', '@INPUT@',
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_lists = {}

xml_sources_appendix = [
    'bibliography.xml',
    'bugs.xml',
    'contributing.xml',
    'fdl.xml',
    'tone-mapping-tutorial.xml',
]
pot_appendix = 'appendix.pot'

input_xml  = xml_sources_appendix
output_pot = pot_appendix

input_files = []
input_base_dir = meson.project_source_root() + '/src/appendix/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
appendix_input = input_files
xml_sources_lists += { 'appendix': input_files}

appendix_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_concepts = [
    'basic-setup.xml',
    'brushes.xml',
    'color-management.xml',
    'concepts.xml',
    'docks.xml',
    'gradients.xml',
    'grid-and-guides.xml',
    'image-types.xml',
    'images-loading.xml',
    'images.xml',
    'imagewindow.xml',
    'intro.xml',
    'layer-groups.xml',
    'layer-modes-legacy.xml',
    'layer-modes.xml',
    'layers.xml',
    'palettes.xml',
    'patterns.xml',
    'plugins.xml',
    'qmask.xml',
    'script-fu.xml',
    'selection.xml',
    'text-management.xml',
    'toolbox.xml',
    'tools-presets.xml',
    'undo.xml',
]
pot_concepts = 'concepts.pot'

input_xml  = xml_sources_concepts
output_pot = pot_concepts

input_files = []
input_base_dir = meson.project_source_root() + '/src/concepts/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'concepts': input_files}

concepts_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_dialogs = [
    'brushes-dialog.xml',
    'buffers-dialog.xml',
    'channel-dialog.xml',
    'channel-menu.xml',
    'channel-selection-mask.xml',
    'color-dialog.xml',
    'dashboard.xml',
    'device-status-dialog.xml',
    'dialogs-content.xml',
    'dialogs-file.xml',
    'dialogs-management.xml',
    'dialogs-misc.xml',
    'dialogs-preferences.xml',
    'dialogs-structure.xml',
    'dialogs_introduction.xml',
    'document-dialog.xml',
    'edit-template-dialog.xml',
    'error-console.xml',
    'export-file-dialog.xml',
    'export-file-formats.xml',
    'file-gif-export.xml',
    'file-heif-export.xml',
    'file-jpeg-export.xml',
    'file-mng-export.xml',
    'file-png-export.xml',
    'file-tiff-export.xml',
    'file-webp-export.xml',
    'fonts-dialog.xml',
    'gradient-dialog.xml',
    'gradient-editor-dialog.xml',
    'histogram-dialog.xml',
    'images-dialog.xml',
    'import-file-formats.xml',
    'indexed-palette-dialog.xml',
    'keyboard-shortcuts-dialog.xml',
    'layer-dialog.xml',
    'layer-mask.xml',
    'mypaint-brushes-dialog.xml',
    'navigation-dialog.xml',
    'open-file-dialog.xml',
    'palettes-dialog.xml',
    'path-dialog.xml',
    'patterns-dialog.xml',
    'pointer-dialog.xml',
    'prefs-canvas-interaction-modifiers.xml',
    'prefs-canvas-interaction-snapping.xml',
    'prefs-canvas-interaction.xml',
    'prefs-color-management.xml',
    'prefs-debugging.xml',
    'prefs-default-grid.xml',
    'prefs-default-image.xml',
    'prefs-dialog-defaults.xml',
    'prefs-display.xml',
    'prefs-folders-data.xml',
    'prefs-folders.xml',
    'prefs-help.xml',
    'prefs-icon-theme.xml',
    'prefs-image-window-appearance.xml',
    'prefs-image-window-title.xml',
    'prefs-image-window.xml',
    'prefs-import-export.xml',
    'prefs-input-controllers.xml',
    'prefs-input-devices.xml',
    'prefs-interface.xml',
    'prefs-playground.xml',
    'prefs-system-resources.xml',
    'prefs-theme.xml',
    'prefs-tool-options.xml',
    'prefs-toolbox.xml',
    'prefs-window-management.xml',
    'qmask.xml',
    'sample-points.xml',
    'save-file-dialog.xml',
    'symmetry-painting.xml',
    'tagging.xml',
    'templates-dialog.xml',
    'tool-preset-editor.xml',
    'tool-presets-dialog.xml',
    'undo-history-dialog.xml',
    'welcome-dialog.xml',
]
pot_dialogs = 'dialogs.pot'

input_xml  = xml_sources_dialogs
output_pot = pot_dialogs

input_files = []
input_base_dir = meson.project_source_root() + '/src/dialogs/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'dialogs': input_files}

dialogs_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
   ],
)

##############

xml_sources_filters = [
    'about-common-features.xml',
    'animation.xml',
    'artistic.xml',
    'blur.xml',
    'combine.xml',
    'common-features.xml',
    'decor.xml',
    'distort.xml',
    'edge-detect.xml',
    'enhance.xml',
    'generic.xml',
    'introduction.xml',
    'light-and-shadow.xml',
    'map.xml',
    'noise.xml',
    'render.xml',
    'web.xml',
]
pot_filters = 'filters.pot'

input_xml  = xml_sources_filters
output_pot = pot_filters

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'filters': input_files}

filters_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_glossary = [
    'glossary.xml',
]
pot_glossary = 'glossary.pot'

input_xml  = xml_sources_glossary
output_pot = pot_glossary

input_files = []
input_base_dir = meson.project_source_root() + '/src/glossary/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
glossary_input = input_files
xml_sources_lists += { 'glossary': input_files}

glossary_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_introduction = [
    'whats-new.xml',
]
pot_introduction = 'introduction.pot'

input_xml  = xml_sources_introduction
output_pot = pot_introduction

input_files = []
input_base_dir = meson.project_source_root() + '/src/introduction/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'introduction': input_files}

introduction_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_menus = [
    'about-plugin-menuitems.xml',
    'colors.xml',
    'edit.xml',
    'file.xml',
    'filters.xml',
    'help.xml',
    'image.xml',
    'introduction.xml',
    'layer.xml',
    'select.xml',
    'tools.xml',
    'view.xml',
    'windows-open-recent-docks.xml',
    'windows.xml',
]
pot_menus = 'menus.pot'

input_xml  = xml_sources_menus
output_pot = pot_menus

input_files = []
input_base_dir = meson.project_source_root() + '/src/menus/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'menus': input_files}

menus_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_preface = [
    'authors.xml',
]
pot_preface = 'preface.pot'

input_xml  = xml_sources_preface
output_pot = pot_preface

input_files = []
input_base_dir = meson.project_source_root() + '/src/preface/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'preface': input_files}

preface_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_toolbox = [
    'about-common-options-display.xml',
    'color-picker.xml',
    'gegl-operation.xml',
    'intro.xml',
    'measure.xml',
    'other-tools.xml',
    'paint-tools.xml',
    'path.xml',
    'selection-tools.xml',
    'text.xml',
    'toolbox-color-area.xml',
    'transform-tools.xml',
    'zoom.xml',
]
pot_toolbox = 'toolbox.pot'

input_xml  = xml_sources_toolbox
output_pot = pot_toolbox

input_files = []
input_base_dir = meson.project_source_root() + '/src/toolbox/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'toolbox': input_files}

toolbox_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_tutorial = [
    'quickies.xml',
]
pot_tutorial = 'tutorial.pot'

input_xml  = xml_sources_tutorial
output_pot = pot_tutorial

input_files = []
input_base_dir = meson.project_source_root() + '/src/tutorial/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'tutorial': input_files}

tutorial_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

##############

xml_sources_using = [
    'animated-brushes.xml',
    'brushes.xml',
    'creating-brush-quickly.xml',
    'customize-splashscreen.xml',
    'fileformats.xml',
    'fonts-and-text.xml',
    'getting-unstuck-export.xml',
    'getting-unstuck-gui.xml',
    'getting-unstuck-intro.xml',
    'getting-unstuck.xml',
    'layers.xml',
    'paths.xml',
    'photography.xml',
    'python-plug-in-tutorial.xml',
    'qmask.xml',
    'script-fu-gui-api.xml',
    'script-fu-tutorial.xml',
    'selections.xml',
    'setup-tile-cache.xml',
    'shortcuts.xml',
    'simpleobjects.xml',
    'variable-size-brush.xml',
    'web.xml',
]
pot_using = 'using.pot'

input_xml  = xml_sources_using
output_pot = pot_using

input_files = []
input_base_dir = meson.project_source_root() + '/src/using/'
output_dir     = meson.project_build_root()  + '/pot'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach
xml_sources_lists += { 'using': input_files}

using_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
#    depend_files: [input_files],
    input: [input_files],
    output: [output_pot],
    command: [
#        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

#########################

# input_files = []
# input_base_dir = meson.project_source_root() + '/src/'

# foreach xml_file: xml_sources_root
#     input_files += input_base_dir + xml_file
# endforeach

# #input_files = xml_sources_root

# gimp_pot = custom_target(pot_gimp_help,
#     depends: [copy_authors_to_src],
#     depend_files: [input_files],
#     #input: input_files,
#     output: [pot_gimp_help],
#     command: [
# ##        xml2pot, pot_gimp_help, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
# #        xml2pot, meson.current_build_dir() + '/' + pot_gimp_help, meson.project_build_root(), meson.project_source_root(), input_files,
#         xml2pot, pot_gimp_help, meson.project_build_root() + '/pot', meson.project_source_root(), input_files,
#     ],
#     #build_by_default: true,
# )


# FIXME / TODO:
subdir('filters')
subdir('menus')
subdir('toolbox')
