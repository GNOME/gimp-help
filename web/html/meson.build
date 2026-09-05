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

xml_2_html = {
    # Website
    'about.xml':       'about.html',
    'download.xml':    'download.html',
    'help.xml':        'help.html',
    #'layout.xml':      ' ',
    'online.xml':      'online.html',
    'website.xml':     'index.html',
}

#input_xml_files = []
foreach file : web_xml
    input_xml_file = meson.project_build_root() / 'web' / file
    if file in xml_2_html
        output_file = xml_2_html.get(file)

        autolayout_html = custom_target('html-website-' + file,
            depends: [autolayout_xml],
            depend_files: [html_files],
            output: [output_file],
            command: [
                xsltproc,
                '--timing',
                '--nonet',
                '--output', '@OUTPUT@',
                web_stylesheets[1],
                input_xml_file,
            ],
            build_by_default: true,
        )
    endif
endforeach
