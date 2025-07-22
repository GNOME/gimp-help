# Create pot file
message('auto - colors submenu')

#target      = 'auto.pot'
#target_pot  = pot_base + subdir_name + '/' + menus_subdir_name + '/' + target
target_base = 'auto'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'color-enhance.xml',
    'equalize.xml',
    'stretch-contrast-hsv.xml',
    'stretch-contrast.xml',
    'white-balance.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

auto_colors_pot = custom_target(target,
    depends: [menus_colors_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

menus_colors_base = subdir_name + '/' + menus_subdir_name + '/'
target_menus_colors_base = menus_colors_base  + target_base
message(target_menus_colors_base)
xml_lang_base = meson.project_build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_menus_colors_base,
        check: false
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_menus_colors_base + '/'
    dest_dir   = '/xml/' + lang + '/' + target_menus_colors_base + '/'
    po_dir     = '/po/'  + lang + '/' + menus_colors_base

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
