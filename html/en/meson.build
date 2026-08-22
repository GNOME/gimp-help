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
    depends: [gimp_css_all, gimp_ss_all, xml_lang_copy_images],
    input: [gen_lang],

    output: ['index.html'], #FIXME: Needs all files to be able to easily install them???
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
    output: ['dummy.image'],
    command: [
        cp,
        '-r',       # recursive
        '-u',       # update if newer, copy if missing
        meson.current_build_dir() / 'index.html.p' / 'images',
        meson.current_build_dir() / 'images',
    ],
    install: true,
    install_dir: install_prefix / lang / 'images' + '/',
    build_by_default: true,
)

#FIXME: Second run it adds an /images folder inside images!!!

#FIXME: We also need per lang a `gimp-help.xml` file that lists all help ids and what page it links to
