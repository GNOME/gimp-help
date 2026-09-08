# generate to per language images, but if language has replacements then
# those replacement translated images need to be used instead of the
# versions here!

subdir('base-examples')
subdir('contribute')
subdir('dialogs')
subdir('filters')
subdir('glossary')
subdir('math')
subdir('menus')
subdir('preferences')
subdir('stock-icons')
subdir('tool-options')
subdir('toolbox')
subdir('tutorials')
subdir('using')


images_C = \
    images_base_examples + \
    images_contribute + \
    images_dialogs + \
    images_dialogs_examples + \
    images_filters + \
    images_filters_animation + \
    images_filters_artistic + \
    images_filters_blur + \
    images_filters_combine + \
    images_filters_common + \
    images_filters_decor + \
    images_filters_distort + \
    images_filters_edge_detect + \
    images_filters_enhance + \
    images_filters_examples + \
    images_filters_examples_animation + \
    images_filters_examples_artistic + \
    images_filters_examples_blur + \
    images_filters_examples_decor + \
    images_filters_examples_distort + \
    images_filters_examples_edge_detect + \
    images_filters_examples_enhance + \
    images_filters_examples_generic + \
    images_filters_examples_light_and_shadow + \
    images_filters_examples_map + \
    images_filters_examples_noise + \
    images_filters_examples_render + \
    images_filters_generic + \
    images_filters_light_and_shadow + \
    images_filters_map + \
    images_filters_noise + \
    images_filters_render + \
    images_filters_web + \
    images_glossary + \
    images_math + \
    images_menus + \
    images_preferences + \
    images_stock_icons + \
    images_tool_options + \
    images_toolbox + \
    images_tutorials + \
    images_tutorials_tone_mapping + \
    images_using
    # TODO: Add the submenus...

test_images_C = images_base_examples
test_images_C_path = images_base_examples_path


img_gen = generator(cp,
    #depends: pot_dependencies,
    output: '@PLAINNAME@',
    arguments : [
        '@INPUT@',
        '@OUTPUT@',
    ])

# use test_images_C_path for now

all_img_gens = {}
foreach lang : target_linguas
  lang_img_gens = []
  foreach img_file: test_images_C_path
    gen_imgs = img_gen.process(
        img_file,
        preserve_path_from: meson.current_source_dir(),
    )
    lang_img_gens += gen_imgs
    img_gens = {lang: lang_img_gens}
    all_img_gens += img_gens
  endforeach
endforeach
