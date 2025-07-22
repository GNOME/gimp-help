# Create dialogs.pot
message('dialogs submenu')

# list of source files to make a pot from
pot_source_files = [
'brushes-dialog.xml',
'buffers-dialog.xml',
'channel-dialog.xml',
'channel-menu.xml',
'channel-selection-mask.xml',
'color-dialog.xml',
'dashboard.xml',
'device-status-dialog.xml',
'dialogs_introduction.xml',
'dialogs-content.xml',
'dialogs-file.xml',
'dialogs-management.xml',
'dialogs-misc.xml',
'dialogs-preferences.xml',
'dialogs-structure.xml',
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
'indexed-palette-dialog.xml',
'import-file-formats.xml',
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
target_base = 'dialogs'
target      = target_base + '.pot'
target_pot  = pot_base + target
target_po   = target_base + '.po'

# Debugging help...
message('Creating target for ' + target_pot)

dialogs_pot = custom_target(target,
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)
xml_lang_base = meson.project_build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_base,
        check: false
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_base + '/'
    dest_dir   = '/xml/' + lang + '/'+ target_base + '/'
    po_dir     = '/po/'  + lang + '/'

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : pot_source_files
            xmltarget = xmltarget_base + xmlfile
            #message(target)
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    xml2po,
                    '--po-file=' + meson.project_source_root() + po_dir + po_source,
                    '--language=' + lang,
                    '--output=' + meson.project_build_root() + dest_dir + xmlfile,
                    meson.project_source_root() + xmlsrc_dir + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    else
        # English has no po files...
        foreach xmlfile : pot_source_files
            xmltarget = xmltarget_base + xmlfile
            #message(target)
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    'cp',
                    meson.project_source_root() + xmlsrc_dir + xmlfile,
                    meson.project_build_root()  + dest_dir   + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    endif

endforeach
