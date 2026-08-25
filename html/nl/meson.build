# Create html for nl

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
        #install: true,
        #install_dir: install_prefix / lang + '/',
        #build_by_default: true,
    )
    gimp_css_all += gimp_css
    idx += 1
endforeach

gimp_html = custom_target(htmltarget,
    depends: [gimp_css_all, gimp_ss_all, xml_lang_copy_images],
    input: [gen_lang],
    output: ['index.html'],
    command: [
        xsltproc,
        '--timing',
        '--nonet',
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

images_target = htmltarget + '-images'
gimp_html_images = custom_target(images_target,
    depends: [gimp_html],
    output: ['gimp-xrefs.xml'], # for now so ci doesn't fail
    command: [
        cp,
        '-r',       # recursive
        '-u',       # update if newer, copy if missing
        meson.current_build_dir() / 'index.html.p' / 'images',
        meson.current_build_dir() / 'images',
    ],
    #install: false, #FIXME can't install missing dummy.image
    #install_dir: install_prefix / lang / 'images' + '/',
    build_by_default: true,
)


# Copies lang folder inside html to install location 
meson.add_install_script(python, '-c', 
    'import shutil; import sys, os; dest_dir = os.environ.get("MESON_INSTALL_DESTDIR_PREFIX") + sys.argv[2]; source_dir=sys.argv[1]; os.makedirs(dest_dir, exist_ok=True); shutil.copytree(source_dir, dest_dir, dirs_exist_ok=True, ignore=shutil.ignore_patterns("*.css.p", "*.html.p"))',
    meson.current_build_dir(),
    '/' + lang
)

#FIXME: We also need per lang a `gimp-help.xml` file that lists all help ids and what page it links to
