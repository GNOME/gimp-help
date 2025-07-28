# Create html for en

gen_lang = all_generators.get(lang)

gimp_html = custom_target(htmltarget,
    # FIXME: Also depend on entities.xml, css, and images
    depend_files: [plainhtml],
    input: [gen_lang],
    output: ['index.html'],
    command: [
        xsltproc,
        #'--verbose',
        '--timing',
        '--nonet',
        '--path', meson.current_build_dir()+'/images',  # testing if this helps
        '--xinclude',
        '--stringparam', 'l10n.gentext.default.language ', lang,
        '--output', meson.current_build_dir() + '/',
        html_stylesheet_path,
        '@INPUT0@',
    ],
    #build_by_default: true,
)
