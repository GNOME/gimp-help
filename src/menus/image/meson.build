# Create pot file
message('image submenu')

#target      = 'image.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'image'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'align-layers.xml',
    'assign-color-profile.xml',
    'autocrop.xml',
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
    'enable-color-management.xml',
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
    'precision.xml',
    'print-size.xml',
    'properties.xml',
    'save-color-profile-to-file.xml',
    'scale.xml',
    'slice-using-guides.xml',
    'transform-flip.xml',
    'transform-rotate.xml',
    'transform.xml',
    'zealous-crop.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

image_pot = custom_target(target,
    depends: [menus_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.build_root(), meson.source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

menus_base = subdir_name + '/'
target_menus_base = menus_base  + target_base
xml_lang_base = meson.build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p',
        xml_lang_base + '/' + lang + '/'+ target_menus_base ,
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
