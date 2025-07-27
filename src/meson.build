message('src submenu')


pot_dependencies = [
    # root folder
    gimp_pot, appendix_pot, concepts_pot, dialogs_pot, filters_pot,
    glossary_pot, introduction_pot, menus_pot, preface_pot,
    toolbox_pot, tutorial_pot, using_pot,
    # filters
    filters_animation_pot, filters_artistic_pot, filters_blur_pot,
    filters_combine_pot, filters_decor_pot, filters_distort_pot,
    filters_edge_detect_pot, filters_enhance_pot, filters_generic_pot,
    filters_light_and_shadow_pot, filters_map_pot, filters_noise_pot,
    filters_render_pot, filters_web_pot,
    # menus
    menus_colors_pot, menus_edit_pot, menus_file_pot, menus_filters_pot,
    menus_help_pot, menus_image_pot, menus_layer_pot, menus_select_pot,
    menus_view_pot,
    # menus/colors
    colors_auto_pot, colors_components_pot, colors_desaturate_pot,
    colors_info_pot, colors_map_pot, colors_tone_mapping_pot,
    # toolbox
    toolbox_paint_pot, toolbox_selection_pot, toolbox_transform_pot,
    ]

xml_lang_base = meson.project_build_root() + '/src'
po_source     = 'gimp.po'
# for each enabled language create a xml/lang/... target

gen = generator(xml2po,
    #depends: [gimp_pot],
    depends: pot_dependencies,
    output: '@PLAINNAME@',
    arguments : [
        '--po-file=' + meson.project_source_root() + '/po/' + lang + '/' + po_source,
        '--language=' + lang,
#        '--output=@BUILD_DIR@' + '/' + '@OUTPUT@',
        '--output=@OUTPUT@',
        '@INPUT@',
    ])

en_gen = generator(cp,
#    depends: [gimp_pot],
    depends: pot_dependencies,
    output: '@PLAINNAME@',
    arguments : [
        '@INPUT@',
        '@OUTPUT@',
    ])

#lang_generators = []
all_generators  = {}

idx = 0
foreach lang : target_linguas
    # Make lang directory if not existing
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

    idx = 0
    foreach lang : target_linguas
        message('language ' + lang + ' index @0@'.format(idx) + 'folder: ' + xml_sub_dir)
        idx += 1

        lang_xml_gens = []

        # en is a special case...
        if lang != 'en'
            foreach xmlfile : xml_files_list
                gen_xml = gen.process(
                    xmlfile,
                    preserve_path_from: meson.current_source_dir(),
                )
                lang_xml_gens += gen_xml
            endforeach
        else
            # English has no po files, so we just copy the xml files
            foreach xmlfile : xml_files_list
                gen_xml = en_gen.process(
                    xmlfile,
                    preserve_path_from: meson.current_source_dir(),
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
