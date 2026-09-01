html_stylesheet_path = meson.project_build_root() + '/stylesheets/'
html_stylesheet_plainhtml = html_stylesheet_path  + 'plainhtml.xsl'

xml_base_file   = 'gimp-xrefs.xml'
xml_private_dir = xml_base_file + '.p'


# install prefix should point to the location inside GIMP's prefix 
# where the language folders should be added that contain html
# e.g. HELP_PREFIX=$GIMP_PREFIX/share/gimp/3.0/help
install_prefix = get_option('prefix')

css_gen = generator(cp,
    output: '@PLAINNAME@',
    arguments : [
        '@INPUT@',
        '@OUTPUT@',
    ])

css_path_files = [
    './css/gimp-help-plain.css',
    './css/gimp-help-screen.css',
    './css/gimp-help-draft.css',
]
css_files = [
    'gimp-help-plain.css',
    'gimp-help-screen.css',
    'gimp-help-draft.css',
]

# custom language specific additional css files
## For nn
css_nn_path_files = [
    './css/nn/gimp-help-custom.css',
]
css_nn_files = [
    'gimp-help-custom.css',
]

subdir('stylesheets')

# SRC_IMAGE_FOLDERS = [
#     meson.project_source_root() / 'images' / 'common' ,
#     meson.project_source_root() / 'images' / 'C' ,
# ]

#FIXME: Depending on po below should be enough because po depends on pot
#FIXME: Should only depend on the po files for the current language
gen = generator(xml2po,
    depends: [pot_dependencies, po_dependencies],
    output: '@PLAINNAME@',
    arguments : [
        '-k',
        '--mode=gimphelp',
        '@EXTRA_ARGS@',
        '--output=@OUTPUT@',
        '@INPUT@',
    ])

en_gen = generator(cp,
    depends: [pot_dependencies, po_dependencies],
    output: '@PLAINNAME@',
    arguments : [
        '@INPUT@',
        '@OUTPUT@',
    ])

all_generators  = {}

idx = 0
foreach lang : target_linguas
    # target per lang
    target_base = lang + '-'
    htmltarget = 'html-'+lang

    message('language ' + lang + ' index @0@'.format(idx))
    idx += 1

    lang_xml_gens = []

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : xml_sources_root
            #target = target_base + xmlfile
            #dest_xml = '/' + lang + '/' + xmlfile
            #message('Destination xml: ' + dest_xml + ' - ' + target)
            gen_xml = gen.process(
                xmlfile,
                extra_args: [
                    '--po-file=' + meson.project_build_root() + '/po/' + lang + '/' + 'gimp.po',
                    #'--po-file=' + '@INPUT@',
                    '--language=' + lang,
                ],
                #preserve_path_from: meson.current_source_dir(),
            )
            lang_xml_gens += gen_xml
        endforeach
    else
        # English has no po files...
        foreach xmlfile : xml_sources_root
            #target = target_base + xmlfile
            #lang_xml = meson.project_build_root()  + '/src/' + lang + '/' + xmlfile
            gen_xml = en_gen.process(
                xmlfile,
                #preserve_path_from: meson.current_source_dir(),
            )
            lang_xml_gens += gen_xml

        endforeach
    endif
    #lang_generators += lang_xml_gens
    all_generators  += { lang: lang_xml_gens}
endforeach

foreach folder, file_list: xml_sources_lists
    xml_files_list = file_list
    xml_sub_dir    = '/' + folder + '/'
    po_file        = folder + '.po'

    idx = 0
    foreach lang : target_linguas
        message('language ' + lang + ' index @0@'.format(idx) + ' folder: ' + xml_sub_dir)
        idx += 1

        lang_xml_gens = []

        # en is a special case...
        if lang != 'en'
            po_file_path = meson.project_build_root() + '/po/' + lang + '/' + po_file
            foreach xmlfile : xml_files_list
                gen_xml = gen.process(
                    xmlfile,
                    extra_args: [
                        '--po-file=' + po_file_path,
                        '--language=' + lang,
                    ],
                    #preserve_path_from: meson.current_source_dir(),
                    preserve_path_from: SRC_FOLDER,
                )
                lang_xml_gens += gen_xml
            endforeach
        else
            # English has no po files, so we just copy the xml files
            message('Folder: ', folder, 'first file: ', file_list[0].full_path())
            foreach xmlfile : xml_files_list
                gen_xml = en_gen.process(
                    xmlfile,
                    #preserve_path_from: meson.current_source_dir(),
                    preserve_path_from: SRC_FOLDER,
                )
                lang_xml_gens += gen_xml
            endforeach
        endif

        # Update generators for this language
        mygen  = all_generators.get(lang)
        mygen += lang_xml_gens
        all_generators  += { lang: mygen}
    endforeach
endforeach



foreach lang : target_linguas

    all_css_path_files = css_path_files
    all_css_files      = css_files
    if lang == 'nn'
      all_css_path_files += css_nn_path_files
      all_css_files      += css_nn_files
    endif

    lang_css_gens = []
    foreach css_file: all_css_path_files
        gen_css = css_gen.process(
            css_file,
            preserve_path_from: meson.current_source_dir(),
        )
        lang_css_gens += gen_css
    endforeach


    # FIXME: This is a hack, we are not supposed to touch a meson private dir
    if not fs.is_dir(meson.current_build_dir() / lang / xml_private_dir)
        # Create dir
        mkdir_script = 'import os; os.makedirs("@0@", exist_ok=True)'.format(meson.current_build_dir() / lang / xml_private_dir)
        run_command(python,
            '-c',
            mkdir_script,
            check: true
        )
    endif

    msg = 'Copying images for @0@'.format(lang)
    message(msg)

# xml/%/images: $(IMAGE_PREREQ)
#   type d in combination with find it stands for directory
#   test -L file  True if file exists and is a symbolic Link. [[ -L demofile ]]
#   test -d file  True if file exists and is a Directory. [[ -d demofile ]]
# 	$(cmd) if test -L $@; then rm -v $@; fi
# 	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
# 	$(cmd) if test -d $@; then rm -rf $@/*; fi
# 	$(cmd) test -d $@ || $(MKDIR_P) $@
# 	$(cmd) $(echo_n) "Copying images ($*) ..."
# 	$(cmd) perl $(MAKE_IMAGE_LINKS) $(MAKE_IMAGE_LINKS_FLAGS) \
# 	           $(srcdir)/images/common $(srcdir)/images/C $@
# 	$(cmd) touch $@

    # FIXME This is a hack: we are copying the images to the meson private
    #       directory used for the xml generation. However, we need the
    #       images available there.
    # FIXME 2 We also don't do symbolic links at this time.


    # FIXME: A different idea: maybe we can use a generator to copy relevant
    #        images to /html/lang/ that way meson can maybe track changes,
    #        and from there copy images to xml private dir
    #       That way we may not need to delete all images every run.
    #       An issue could be that every time a translated image is added,
    #       our meson files need to be updated too.

    htmltarget         = 'html-'+lang
    xmlhelptarget      = 'html-'+lang+'gimp-help-xml'
    copy_images_target = 'xml-images-' + lang

    # xml_lang_copy_images = custom_target(copy_images_target,
    #     output:  [copy_images_target],
    #     command: [
    #         MAKE_IMAGE_LINKS,
    #         MAKE_IMAGE_LINKS_FLAGS,
    #         SRC_IMAGE_FOLDERS,
    #         meson.current_build_dir() / lang / xml_private_dir / images,
    #     ],
    #     install: false,
    #     build_by_default: true,
    #     build_always_stale: true,
    # )

    # FIXME custom_target has a @PRIVATE_DIR@ variable that we may be able to
    # use to add images to the private dir, something to investigate later.
    # This should do the same as the make target xml/%/images
    xml_lang_copy_images = custom_target(copy_images_target,
        output:  [copy_images_target],
        command: [
            copy_images,
            meson.project_source_root(),
            meson.current_build_dir(),
            MAKE_IMAGE_LINKS_FLAGS,
            lang,
        ],
        depend_files: [
            images_C_files,
            images_common_files,
        ],
        install: false,
        build_by_default: true,
        build_always_stale: true,   # for now
    )

    #subdir(lang)

    ### And now create in a language subdir ###
    ### This requires meson 1.10, without that, the below code would need
    ### to be added to a language subdir under html for each language.

    gen_lang = all_generators.get(lang)

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
            #build_by_default: true,
            build_subdir: lang,
        )
        gimp_css_all += gimp_css
        idx += 1
    endforeach

    gimp_html = custom_target(htmltarget,
        depends: [gimp_css_all, gimp_ss_all, xml_lang_copy_images],
        input: [gen_lang],
        output: [xml_base_file], #FIXME: Needs all files to be able to easily install them
        command: [
            xsltproc,
            '--timing',
            '--nonet',
            '--xinclude',
            '--stringparam', 'l10n.gentext.default.language ', lang,
            '--output', meson.current_build_dir() + '/' + lang + '/',
            html_stylesheet_plainhtml,
            '@INPUT0@',
        ],
        install: true,
        install_dir: install_prefix / lang + '/',
        build_by_default: true,
        build_subdir: lang,
    )

    gimp_help_xml = custom_target(xmlhelptarget,
        input: [gimp_html, makeindex],
        output: ['gimp-help.xml'],
        command: [
            xsltproc,
            '--timing',
            '--nonet',
            '--output', meson.current_build_dir() + '/' + lang + '/' + 'gimp-help.xml',
            html_stylesheet_path + 'makeindex.xsl',
            #'@INPUT0@',
            meson.current_build_dir() / lang / xml_private_dir / 'gimp.xml',
        ],
        install: true,
        install_dir: install_prefix / lang + '/',
        build_by_default: true,
        build_subdir: lang,
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
                meson.current_build_dir() / lang / xml_private_dir / 'images',
                meson.current_build_dir() / lang / 'images',
            ],
            #install: true,
            #install_dir: install_prefix / lang / 'images' + '/',
            build_by_default: true,
            build_subdir: lang,
        )
    else
        gimp_html_images = custom_target(images_target,
            depends: [gimp_html],
            output: ['index.html'], # for now so ci doesn't fail
            command: [
                ln,
                '-s',       # symbolic links
                meson.current_build_dir() / lang / xml_private_dir / 'images',
                meson.current_build_dir() / lang / 'images',
            ],
            #install: true,
            #install_dir: install_prefix / lang / 'images' + '/',
            build_by_default: true,
            build_subdir: lang,
        )
    endif

    # For now, actual installation means copying all html, css, xml and image files/folders
    # Eventually we may want to extend html output to list all html files, then we should
    # be able to get rid of this script
    # Copies lang folder inside html to install location 
    meson.add_install_script(python, '-c', 
        'import shutil; import sys, os; dest_dir = os.environ.get("MESON_INSTALL_DESTDIR_PREFIX") + sys.argv[2]; source_dir=sys.argv[1]; os.makedirs(dest_dir, exist_ok=True); shutil.copytree(source_dir, dest_dir, dirs_exist_ok=True, ignore=shutil.ignore_patterns("*.p"), symlinks=True)',
        meson.current_build_dir() / lang,
        '/' + lang
    )

endforeach
