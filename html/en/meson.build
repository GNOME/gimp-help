# Create html for en

gen_lang = all_generators.get(lang)
# img_gen_lang = all_img_gens.get(lang)


# gimp_copy_lang_images = custom_target('html-images-'+lang,
#     input: [img_gen_lang],
#     output: ['images.dummy'],
#     command: [
#         # command to copy all images
#         # MAKE_IMAGE_LINKS,
#         # MAKE_IMAGE_LINKS_FLAGS,
#         # '@INPUT@',
#         # '@OUTPUT@',
#         # As a hack I guess we could copy the resulting images from input to
#         # an images folder under the private xml folder.
#         dummy_ls,
#         #'@INPUT@',
#         #'@OUTPUT@',
#     ],
#     install: true,
#     install_dir: install_prefix / lang / 'images/',
# )

# #  foreach src : srcs
#     # Ugly trick to copy Python plug-ins into subfolders so that we can run GIMP
#     # from the build directory without installing it.
#     # To be run even if we don't install Python plug-ins so that we can
#     # still run them for in-build scripts.
# #    run_command(python, meson.project_source_root() / 'build/meson/cp-plug-in-subfolder.py',
# #                meson.current_source_dir() / src, meson.current_build_dir() / name, check: true)
# #  endforeach


# gen_merge = generator(cp, #dummy_ls,
#     output: '@PLAINNAME@',
#     arguments : [
#         '@INPUT@',
#         '@OUTPUT@',
#     ]
# )

# merged_list = []
# foreach myfile: gen_lang
#     mymerge = gen_merge.process(
#         myfile,
#         #preserve_path_from: meson.current_source_dir(),
#     )
#     merged_list += mymerge
# endforeach
# foreach myfile: gimp_copy_lang_images
#     mymerge = gen_merge.process(
#         myfile,
#         #preserve_path_from: meson.current_source_dir(),
#     )
#     merged_list += mymerge
# endforeach

idx = 0
gimp_css_all = []
foreach css_file: all_css_files
    css_target = 'css-' + lang + '_@0@'.format(idx)

    # FIXME Check if there is a simpler way to copy the css files
    # for install we maybe can use install_data, but we also want
    # it in /html/lang/ build dirs.
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
        build_by_default: true,
    )
    gimp_css_all += gimp_css
    idx += 1
endforeach

gimp_html = custom_target(htmltarget,
    depends: [gimp_css_all, gimp_ss_all, xml_lang_copy_images],
    input: [gen_lang],

    output: ['gimp-xrefs.xml'], #FIXME: Needs all files to be able to easily install them???
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
        '--output', '@OUTPUT@',
        html_stylesheet_path + 'makeindex.xsl',
        '@INPUT0@',
    ],
    install: true,
    install_dir: install_prefix / lang + '/',
    build_by_default: true,
)

# Call with meson install --no-rebuild, or the above slow target will be run again for each language!

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

# For now, actual installation means copying all html, css, xml and image files/folders
# Eventually we may want to extend html output to list all html files, then we should
# be able to get rid of this script
# Copies lang folder inside html to install location 
meson.add_install_script(python, '-c', 
    'import shutil; import sys, os; dest_dir = os.environ.get("MESON_INSTALL_DESTDIR_PREFIX") + sys.argv[2]; source_dir=sys.argv[1]; os.makedirs(dest_dir, exist_ok=True); shutil.copytree(source_dir, dest_dir, dirs_exist_ok=True, ignore=shutil.ignore_patterns("*.p"), symlinks=True)',
    meson.current_build_dir(),
    '/' + lang
)
