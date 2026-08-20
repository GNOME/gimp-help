# TODO We could probably move entites.xml here from /stylesheets
# and then do processing for installation from here
# or we could adjust paths in the source xml files that use
# entities and maybe add it to css?
# Although entities doesn't need to be available for the html
# so probably not


stylesheet_xml_files = [
    'entities.xml',
]


idx = 0
gimp_ss_all = []
foreach ss_file: stylesheet_xml_files
    ss_target = 'ss-xml-' + '_@0@'.format(idx)

    gimp_ss = custom_target(ss_target,
        input: [entities],
        output: [ss_file],
        command: [
            cp,
            '@INPUT@',
            '@OUTPUT@',
        ],
    )
    gimp_ss_all += gimp_ss
    idx += 1
endforeach
