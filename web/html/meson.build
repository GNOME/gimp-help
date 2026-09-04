message('web: html subdir')

css_files = [
    'style.css',
]

html_files = []
foreach file : css_files
    webfile = configure_file(
        input : file,
        output: file,
        copy: true,
        #install: true,
        # FIXME: Install location
    )
    html_files += webfile
endforeach

subdir('layout')

input_xml_files = []
foreach file : web_xml
    input_xml_files += meson.project_build_root() / 'web' / file
endforeach

autolayout_html = custom_target('html-website',
    depends: [autolayout_xml],
    depend_files: [html_files],
    #input: [layout],
    output: ['index.html'],
    command: [
        xsltproc,
        '--timing',
        '--nonet',
        #'--path', meson.project_source_root() + '/web/', 
        '--output', '@OUTPUT@', #meson.project_build_root() + '/web/' + autolayout, 
        web_stylesheets[1],
        input_xml_files,
        #'@INPUT0@',
    ],
    build_by_default: true,
)
