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
'dialogs-content.xml',
'dialogs-management.xml',
'dialogs-misc.xml',
'dialogs-structure.xml',
'dialogs_introduction.xml',
'document-dialog.xml',
'edit-template-dialog.xml',
'error-console.xml',
'export-file-dialog.xml',
'fonts-dialog.xml',
'gradient-dialog.xml',
'gradient-editor-dialog.xml',
'histogram-dialog.xml',
'images-dialog.xml',
'indexed-palette-dialog.xml',
'layer-dialog.xml',
'layer-mask.xml',
'navigation-dialog.xml',
'palettes-dialog.xml',
'path-dialog.xml',
'patterns-dialog.xml',
'pointer-dialog.xml',
'qmask.xml',
'sample-points.xml',
'save-file-dialog.xml',
'symmetry-painting.xml',
'tagging.xml',
'templates-dialog.xml',
'tool-preset-editor.xml',
'tool-presets-dialog.xml',
'undo-history-dialog.xml',
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
    xml2pot, target_pot, meson.build_root(), meson.source_root(), '@INPUT@',
    ],
    build_by_default: true,
)
xml_lang_base = meson.build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p',
        xml_lang_base + '/' + lang + '/'+ target_base ,
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
                    '--po-file=' + meson.source_root() + po_dir + po_source,
                    '--language=' + lang,
                    '--output=' + meson.build_root() + dest_dir + xmlfile,
                    meson.source_root() + xmlsrc_dir + xmlfile,
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
                    meson.source_root() + xmlsrc_dir + xmlfile,
                    meson.build_root()  + dest_dir   + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    endif

endforeach
