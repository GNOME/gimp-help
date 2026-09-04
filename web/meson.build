message('web subdir')

web_xml = [
    # Website
    'about.xml',
    'download.xml',
    'help.xml',
    'layout.xml',
    'online.xml',
    'website.xml',
]
xml_data = [
    # Data used for generating html
    'entities.xml',
    'langstats-static.xml',
    'qrstats-static.xml',
]
web_total = web_xml + xml_data

stats_xml_manual = 'langstats.xml'
stats_xml_qr     = 'qrstats.xml'
autolayout       = 'autolayout.xml'
layout           = 'layout.xml'

langstats = custom_target('update-langstats',
    depends: [po_dependencies],
    output:  [stats_xml_manual],
    command: [
        PCTPROC,
        '-v',
        '-p' + meson.project_build_root() / 'po/',
        '-o' + meson.current_build_dir() / stats_xml_manual,
    ],
    #build_by_default: true,
)

qrstats = custom_target('update-qrstats',
    depends: [qr_po_dependencies],
    output:  [stats_xml_qr],
    command: [
        PCTPROC,
        '-v',
        '-p' + meson.project_build_root() / 'po/',
        '-o' + meson.current_build_dir() / stats_xml_qr,
    ],
    #build_by_default: true,
)

subdir('stylesheets')

webxml_targets = []
foreach file : web_total
    webxml = configure_file(
        input : file,
        output: file,
        copy: true,
    )
    webxml_targets += webxml
endforeach

autolayout_xml = custom_target(autolayout,
    depends: [langstats, qrstats],
    depend_files: [webxml_targets],
    input: [layout],
    output: [autolayout],
    command: [
        xsltproc,
        '--timing',
        '--nonet',
        '--path', meson.project_source_root() + '/web/', 
        '--output', meson.project_build_root() + '/web/' + autolayout, 
        web_stylesheets[0],
        '@INPUT0@',
    ],
    build_by_default: true,
)

subdir('html')
