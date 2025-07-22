# Create pot file
message('edit submenu')

#target      = 'edit.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'edit'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
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

# Debugging help...
message('Creating target for ' + target_pot)

edit_pot = custom_target(target,
    depends: [menus_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

menus_base = subdir_name + '/'
target_menus_base = menus_base  + target_base
xml_lang_base = meson.project_build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_menus_base,
        check: false
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_menus_base + '/'
    dest_dir   = '/xml/' + lang + '/' + target_menus_base + '/'
    po_dir     = '/po/'  + lang + '/' + menus_base

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
