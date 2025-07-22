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

# Debugging help...
message('Creating target for ' + target_pot)

image_pot = custom_target(target,
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
