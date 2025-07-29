# Create html for en

gen_lang = all_generators.get(lang)

idx = 0
gimp_css_all = []
foreach css_file: all_css_files
    css_target = 'css-' + lang + '_@0@'.format(idx)

    gimp_css = custom_target(css_target,
        input: [lang_css_gens[idx]],
        output: [css_file],
        command: [
            cp,
            '@INPUT@',
            '@OUTPUT@',
        ],
        install: true,
        install_dir: install_prefix / lang + '/',
        #build_by_default: true,
    )
    gimp_css_all += gimp_css
    idx += 1
endforeach

gimp_html = custom_target(htmltarget,
    # FIXME: Also depend on entities.xml, css, and images
    depend_files: [plainhtml],
    depends: gimp_css_all,
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
    install: true,
    install_dir: install_prefix / lang + '/',
    build_by_default: true,
)
