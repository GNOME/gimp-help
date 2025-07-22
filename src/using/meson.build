# Create using.pot
message('using submenu')

# list of source files to make a pot from
pot_source_files = [
    'animated-brushes.xml',
    'brushes.xml',
    'creating-brush-quickly.xml',
    'customize-splashscreen.xml',
    'fileformats.xml',
    'fonts-and-text.xml',
    'getting-unstuck-export.xml',
    'getting-unstuck-gui.xml',
    'getting-unstuck-intro.xml',
    'getting-unstuck.xml',
    'layers.xml',
    'paths.xml',
    'photography.xml',
    'python-plug-in-tutorial.xml',
    'qmask.xml',
    'script-fu-gui-api.xml',
    'script-fu-tutorial.xml',
    'selections.xml',
    'setup-tile-cache.xml',
    'shortcuts.xml',
    'simpleobjects.xml',
    'variable-size-brush.xml',
    'web.xml',
]
#target     = 'using.pot'
#target_pot = pot_base + target
target_base = 'using'
target      = target_base + '.pot'
target_pot  = pot_base + target
target_po   = target_base + '.po'

# Debugging help...
message('Creating target for ' + target_pot)

using_pot = custom_target(target,
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

subdir_name = 'using'
target_name = 'create-subdir-' + subdir_name

# Make sure subdir exists
using_directory = custom_target(target_name,
    output: [target_name],
    command: [
        'mkdir', '-p',
        meson.project_build_root() + '/pot/' + subdir_name,
    ],
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

# subdirs of the using menu
