# src/preface
message('preface submenu')

# Due to circular reference src -> pot -> src we can't create authors.xml here.
# It is created instead in our root meson.build file.


# list of source files to make a pot from
pot_source_files = [
    #meson.project_build_root() + '/src/preface/' + 'authors.xml',
]
xml_source_files = [
    'authors.xml',
]


target_base = 'preface'
target      = target_base + '.pot'
target_pot  = pot_base + target
target_po   = target_base + '.po'

# Debugging help...
message('Creating target for ' + target_pot)

#xmltarget = xmltarget_base + xmlfile


authors_path = meson.project_source_root() + authors_subdir + authors_file_xml

preface_pot = custom_target(target,
    depends: [copy_authors_to_src],
    input: preface_authors_xml,
    output: [target],
    command: [
        xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), authors_path,
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
    preface_authors = 'preface-authors'

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : xml_source_files
            xmltarget = xmltarget_base + xmlfile
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    xml2po,
                    '--po-file=' + meson.project_source_root() + po_dir + po_source,
                    '--language=' + lang,
                    '--output=' + meson.project_build_root() + dest_dir + xmlfile,
                    # Special case here since authors.xml is only available
                    # in the build dir!
                    meson.project_build_root() + xmlsrc_dir + xmlfile,
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
                    meson.project_build_root() + xmlsrc_dir + xmlfile,
                    meson.project_build_root() + dest_dir   + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    endif

endforeach
