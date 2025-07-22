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

# Debugging help...
message('Creating target for ' + target_pot)

view_pot = custom_target(target,
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
