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
    './css/gimp22.css',
]
css_files = [
    'gimp-help-plain.css',
    'gimp-help-screen.css',
    'gimp-help-draft.css',
    'gimp22.css',
]

# custom language specific additional css files
## For nn
css_nn_path_files = [
    './css/nn/gimp-help-custom.css',
]
css_nn_files = [
    'gimp-help-custom.css',
]

subdir('images')

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

    htmltarget = 'html-'+lang
    subdir(lang)

endforeach
