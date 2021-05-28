# Create pot file
message('view submenu')

#target      = 'view.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'view'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'display-filters.xml',
    'dot-for-dot.xml',
    'flip-rotate.xml',
    'fullscreen.xml',
    'introduction.xml',
    'navigwindow.xml',
    'new.xml',
    'padding-color.xml',
    'show-all.xml',
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
    'snap-to-canvas.xml',
    'snap-to-grid.xml',
    'snap-to-guides.xml',
    'snap-to-path.xml',
    'view-color-management.xml',
    'zoom.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

view_pot = custom_target(target,
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
