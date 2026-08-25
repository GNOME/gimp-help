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
    output: ['gimp-xrefs.xml'],
    command: [
        xsltproc,
        '--timing',
        '--nonet',
        '--xinclude',
        '--stringparam', 'l10n.gentext.default.language ', lang,
        '--output', meson.current_build_dir() + '/',
        html_stylesheet_plainhtml,
        '@INPUT0@',
    ],
    install: true,
    install_dir: install_prefix / lang + '/',
    build_by_default: true,
)

gimp_help_xml = custom_target(xmlhelptarget,
    #depends: [gimp_html],
    input: [gimp_html, makeindex],

    output: ['gimp-help.xml'],
    command: [
        xsltproc,
        '--timing',
        '--nonet',
        #'--xinclude',
        #'--stringparam', 'l10n.gentext.default.language ', lang,
        '--output', '@OUTPUT@',
        html_stylesheet_path + 'makeindex.xsl',
        '@INPUT0@',
    ],
    install: true,
    install_dir: install_prefix / lang + '/',
    build_by_default: true,
)

images_target = htmltarget + '-images'
if platform_windows
    gimp_html_images = custom_target(images_target,
        depends: [gimp_html],
        output: ['index.html'], # for now so ci doesn't fail
        command: [
            cp,
            '-r',       # recursive
            '-u',       # update if newer, copy if missing
            meson.current_build_dir() / xml_private_dir / 'images',
            meson.current_build_dir() / 'images',
        ],
        #install: true,
        #install_dir: install_prefix / lang / 'images' + '/',
        build_by_default: true,
    )
else
    # if not fs.is_dir(meson.current_build_dir() / 'images')
    #     # Create dir
    #     mkdir_script = 'import os; os.makedirs("@0@", exist_ok=True)'.format(meson.current_build_dir() / 'images')
    #     run_command(python,
    #         '-c',
    #         mkdir_script,
    #         check: true
    #     )
    # endif

    gimp_html_images = custom_target(images_target,
        depends: [gimp_html],
        output: ['index.html'], # for now so ci doesn't fail
        command: [
            ln,
            '-s',       # symbolic links
            meson.current_build_dir() / xml_private_dir / 'images',
            meson.current_build_dir() / 'images',
        ],
        #install: true,
        #install_dir: install_prefix / lang / 'images' + '/',
        build_by_default: true,
    )
endif

# Copies lang folder inside html to install location 
meson.add_install_script(python, '-c', 
    'import shutil; import sys, os; dest_dir = os.environ.get("MESON_INSTALL_DESTDIR_PREFIX") + sys.argv[2]; source_dir=sys.argv[1]; os.makedirs(dest_dir, exist_ok=True); shutil.copytree(source_dir, dest_dir, dirs_exist_ok=True, ignore=shutil.ignore_patterns("*.p"), symlinks=True)',
    meson.current_build_dir(),
    '/' + lang
)

#FIXME: We also need per lang a `gimp-help.xml` file that lists all help ids and what page it links to
