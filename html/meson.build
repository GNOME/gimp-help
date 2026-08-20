html_stylesheet_path = meson.project_build_root() + '/stylesheets/plainhtml.xsl'

prefix = get_option('prefix')
install_prefix = prefix + '/share/gimp/3.0/help'

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

#subdir('images')
subdir('stylesheets')

SRC_IMAGE_FOLDERS = [
    meson.project_source_root() / 'images' / 'common' ,
    meson.project_source_root() / 'images' / 'C' ,
]

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

    message('Current: ', meson.current_build_dir())

    # FIXME This is a hack: we are copying the images to the meson private
    #       directory used for the xml generation. However, we need the
    #       images available there.
    # FIXME 2 We also don't do symbolic links at this time.
    run_command(perl,
        MAKE_IMAGE_LINKS,
        MAKE_IMAGE_LINKS_FLAGS,
        SRC_IMAGE_FOLDERS,
        meson.current_build_dir() / lang / 'index.html.p',
        check: true
    )

    htmltarget = 'html-'+lang
    subdir(lang)

endforeach
