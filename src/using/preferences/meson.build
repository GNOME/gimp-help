# Create pot file
message('preferences submenu')

#target      = 'preferences.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'preferences'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'preferences_introduction.xml',
    'prefs-color-management.xml',
    'prefs-default-grid.xml',
    'prefs-default-image.xml',
    'prefs-dialog-defaults.xml',
    'prefs-display.xml',
    'prefs-folders-data.xml',
    'prefs-folders.xml',
    'prefs-help.xml',
    'prefs-icon-theme.xml',
    'prefs-image-window-appearance.xml',
    'prefs-image-window-snapping.xml',
    'prefs-image-window-title.xml',
    'prefs-image-window.xml',
    'prefs-import-export.xml',
    'prefs-input-controllers.xml',
    'prefs-input-devices.xml',
    'prefs-interface.xml',
    'prefs-system-resources.xml',
    'prefs-theme.xml',
    'prefs-tool-options.xml',
    'prefs-toolbox.xml',
    'prefs-window-management.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

preferences_pot = custom_target(target,
    depends: [using_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.build_root(), meson.source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

subdir_name  = 'using'
using_base = subdir_name + '/'
target_name  = 'create-subdir-' + subdir_name

# Make sure subdir exists
filters_directory = custom_target(target_name,
    output: [target_name],
    command: [
        'mkdir', '-p',
        meson.build_root() + '/pot/' + subdir_name,
    ],
)

target_using_base = using_base  + target_base
xml_lang_base = meson.build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p',
        xml_lang_base + '/' + lang + '/'+ target_using_base ,
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_using_base + '/'
    dest_dir   = '/xml/' + lang + '/' + target_using_base + '/'
    po_dir     = '/po/'  + lang + '/' + using_base

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
