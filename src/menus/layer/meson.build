# Create pot file
message('layer submenu')

#target      = 'layer.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'layer'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
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
    'rotate-90.xml',
    'rotate-180.xml',
    'rotate-270.xml',
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

# Debugging help...
message('Creating target for ' + target_pot)

combine_pot = custom_target(target,
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
