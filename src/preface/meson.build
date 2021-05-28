# Create preface.pot
message('preface submenu')

# list of source files to make a pot from
pot_source_files = [
    meson.build_root() + '/src/preface/' + 'authors.xml',
]
xml_source_files = [
    'authors.xml',
]

#target     = 'preface.pot'
#target_pot = pot_base + target

target_base = 'preface'
target      = target_base + '.pot'
target_pot  = pot_base + target
target_po   = target_base + '.po'

# Debugging help...
message('Creating target for ' + target_pot)

preface_pot = custom_target(target,
    depends: [authors_doc],
    input: pot_source_files,
    output: [target],
    command: [
        xml2pot, target_pot, meson.build_root(), meson.source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

subdir_name = 'preface'
target_name = 'create-subdir-' + subdir_name

# Make sure subdir exists
preface_directory = custom_target(target_name,
    output: [target_name],
    command: [
        'mkdir', '-p',
        meson.build_root() + '/pot/' + subdir_name,
    ],
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
    preface_authors = 'preface-authors'

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : xml_source_files
            xmltarget = xmltarget_base + xmlfile
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    xml2po,
                    '--po-file=' + meson.source_root() + po_dir + po_source,
                    '--language=' + lang,
                    '--output=' + meson.build_root() + dest_dir + xmlfile,
                    # Special case here since authors.xml is only available
                    # in the build dir!
                    meson.build_root() + xmlsrc_dir + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    else
        # English has no po files...
        foreach xmlfile : xml_source_files
            xmltarget = xmltarget_base + xmlfile
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    'cp',
                    # Special case here since authors.xml is only available
                    # in the build dir!
                    meson.build_root() + xmlsrc_dir + xmlfile,
                    meson.build_root() + dest_dir   + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    endif

endforeach
