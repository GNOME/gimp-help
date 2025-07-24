message('src submenu')

# subdir('appendix')
# subdir('concepts')
# subdir('dialogs')
# subdir('filters')
# subdir('glossary')
# subdir('introduction')
# subdir('menus')
# subdir('preface')
# subdir('toolbox')
# subdir('tutorial')
# subdir('using')

#####
# # #subdir('images') # not a directory with xml files
#####

# all_pots = custom_target('pot-all',
#     depends: [appendix_pot],
#     input:'',
#     output: 'pot-all',
#     command: [
#         'ls',
#     ],
#     build_by_default: true,
# )

# list of source files to make a pot from
input_base_dir = meson.project_source_root() + '/src/'
pot_source_files_root = [
    'gimp.xml',
    'help-missing.xml',
    'introduction.xml',
    'key-reference.xml',
]
# pot_source_files_root = [
#     input_base_dir + 'gimp.xml',
#     input_base_dir + 'help-missing.xml',
#     input_base_dir + 'introduction.xml',
#     input_base_dir + 'key-reference.xml',
# ]
# target     = 'gimp.pot'
# target_pot = pot_base + target

# # Debugging help...
# message('Creating target for ' + target_pot)

# gimp_pot = custom_target(target,
#     #depends: [authors_doc],
#     input: pot_source_files_root,
#     output: [target],
#     command: [
#         xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
#     ],
#     build_by_default: true,
# )


# xml_lang_base = meson.project_build_root() + '/xml'
# po_source     = 'gimp.po'
# # for each enabled language create a xml/lang/... target
# foreach lang : target_linguas
#     # Make lang directory if not existing
#     run_command (
#         'mkdir', '-p', xml_lang_base + '/' + lang,
#         check: false
#     )

#     # target per lang
#     target_base = lang + '-'
#     htmltarget = 'html-'+lang

#     # en is a special case...
#     if lang != 'en'
#         foreach xmlfile : pot_source_files_root
#             target = target_base + xmlfile
#             #message(target)
#             gimp_xml = custom_target(target,
#                 output: [target],
#                 command: [
#                     xml2po,
#                     '--po-file=' + meson.project_source_root() + '/po/' + lang + '/' + po_source,
#                     '--language=' + lang,
#                     '--output=' + meson.project_build_root() + '/xml/' + lang + '/' + xmlfile,
#                     meson.project_source_root() + '/src/' + xmlfile,
#                 ],
#                 build_by_default: true,
#             )
#         endforeach
#     else
#         #TODO English has no po files...
#         foreach xmlfile : pot_source_files_root
#             target = target_base + xmlfile
#             lang_xml = meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile
#             #message(target)
#             gimp_xml = custom_target(target,
#                 output: [target],
#                 command: [
#                     'cp',
#                     meson.project_source_root() + '/src/' + xmlfile,
#                     #meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile,
#                     lang_xml,
#                 ],
#                 build_by_default: true,
#             )

#         endforeach
#         gimp_html = custom_target(htmltarget,
#             ##depends: plainhtml,
#             input: plainhtml,
#             output: [htmltarget],
#             command: [
#                 xsltproc,
#                 '--verbose',
#                 '--timing',
#                 '--nonet',
#                 '--path', meson.project_build_root(),
#                 '--path', meson.project_build_root()+'/xml/images',  # testing if this helps
#                 '--xinclude',
#                 '--stringparam', 'l10n.gentext.default.language ', lang,
#                 '--output', 'html/' + lang + '/',
#                 meson.project_build_root() + '/stylesheets/plainhtml.xsl', #TODO refer to source??? or copy first!
#                 'xml/' + lang + '/gimp.xml',
#                 #meson.project_source_root() + '/src/' + xmlfile,
#                 #meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile,
#             ],
#             build_by_default: true,
#         )
#     endif
# endforeach

pot_dependencies = [
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

xml_lang_base = meson.project_build_root() + '/xml'
po_source     = 'gimp.po'
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang,
        check: false
    )

    # target per lang
    target_base = lang + '-'
    htmltarget = 'html-'+lang

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : pot_source_files_root
            target = target_base + xmlfile
            #message(target)
            gimp_xml = custom_target(target,
                depends: pot_dependencies,
                output: [target],
                command: [
                    xml2po,
                    '--po-file=' + meson.project_source_root() + '/po/' + lang + '/' + po_source,
                    '--language=' + lang,
                    '--output=' + meson.project_build_root() + '/xml/' + lang + '/' + xmlfile,
                    meson.project_source_root() + '/src/' + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    else
        #TODO English has no po files...
        foreach xmlfile : pot_source_files_root
            target = target_base + xmlfile
            lang_xml = meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile
            #message(target)
            gimp_xml = custom_target(target,
                output: [target],
                command: [
                    'cp',
                    meson.project_source_root() + '/src/' + xmlfile,
                    #meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile,
                    lang_xml,
                ],
                build_by_default: true,
            )

        endforeach
        gimp_html = custom_target(htmltarget,
            ##depends: plainhtml,
            input: plainhtml,
            output: [htmltarget],
            command: [
                xsltproc,
                '--verbose',
                '--timing',
                '--nonet',
                '--path', meson.project_build_root(),
                '--path', meson.project_build_root()+'/xml/images',  # testing if this helps
                '--xinclude',
                '--stringparam', 'l10n.gentext.default.language ', lang,
                '--output', 'html/' + lang + '/',
                meson.project_build_root() + '/stylesheets/plainhtml.xsl', #TODO refer to source??? or copy first!
                'xml/' + lang + '/gimp.xml',
                #meson.project_source_root() + '/src/' + xmlfile,
                #meson.project_build_root()  + '/xml/' + lang + '/' + xmlfile,
            ],
            build_by_default: true,
        )
    endif
endforeach
