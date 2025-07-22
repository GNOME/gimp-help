# Create pot file
message('enhance submenu')

#target      = 'enhance.pot'
#target_pot  = pot_base + subdir_name + '/' + target
target_base = 'enhance'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'antialias.xml',
    'deinterlace.xml',
    'despeckle.xml',
    'high-pass.xml',
    'introduction.xml',
    'nl-filter.xml',
    'noise-reduction.xml',
    'red-eye-removal.xml',
    'symmetric-nearest-neighbor.xml',
    'unsharp_mask.xml',
    'wavelet-decompose.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

enhance_pot = custom_target(target,
    depends: [filters_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

subdir_name  = 'filters'
filters_base = subdir_name + '/'
target_name  = 'create-subdir-' + subdir_name

# Make sure subdir exists
filters_directory = custom_target(target_name,
    output: [target_name],
    command: [
        'mkdir', '-p',
        meson.project_build_root() + '/pot/' + subdir_name,
    ],
)

target_filters_base = filters_base  + target_base
xml_lang_base = meson.project_build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_filters_base,
        check: false
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_filters_base + '/'
    dest_dir   = '/xml/' + lang + '/' + target_filters_base + '/'
    po_dir     = '/po/'  + lang + '/' + filters_base

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
