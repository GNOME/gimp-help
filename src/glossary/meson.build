# Create glossary.pot
message('glossary submenu')

xml_files_list = xml_sources_glossary

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

        foreach xmlfile : xml_files_list
            target = target_base + xmlfile
            dest_xml = '/glossary/' + xmlfile
            message('Destination xml: ' + dest_xml + ' - ' + target)
            gen_xml = gen.process(
#                '/' + lang + '/' + xmlfile,
                xmlfile,
                #dest_xml,
                #preserve_path_from: meson.current_source_dir(),
                #preserve_path_from: '/glossary/',
            )
            lang_xml_gens += gen_xml
        endforeach
    else
        #TODO English has no po files...

        foreach xmlfile : xml_files_list
            target = target_base + xmlfile
            #lang_xml = meson.project_build_root()  + '/src/' + lang + '/' + xmlfile
            gen_xml = en_gen.process(
                xmlfile,
                preserve_path_from: meson.current_source_dir(),
            )
            lang_xml_gens += gen_xml
        endforeach
    endif
    #lang_generators += lang_xml_gens
    mygen  = all_generators.get(lang)
    mygen += lang_xml_gens
    all_generators  += { lang: mygen}
endforeach


# # list of source files to make a pot from
# pot_source_files = [
# 'glossary.xml',
# ]
# #target     = 'glossary.pot'
# #target_pot = pot_base + target
# target_base = 'glossary'
# target      = target_base + '.pot'
# target_pot  = pot_base + subdir_name + '/' + target
# target_po   = target_base + '.po'

# # Debugging help...
# message('Creating target for ' + target_pot)

# glossary_pot = custom_target(target,
#     input: pot_source_files,
#     output: [target],
#     command: [
#     xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
#     ],
#     build_by_default: true,
# )

# xml_lang_base = meson.project_build_root() + '/xml'
# po_source     = target_po
# # for each enabled language create a xml/lang/... target
# foreach lang : target_linguas
#     # Make lang directory if not existing
#     run_command (
#         'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_base,
#         check: false
#     )

#     # target per lang
#     xmltarget_base = lang + '-'
#     xmlsrc_dir = '/src/' + target_base + '/'
#     dest_dir   = '/xml/' + lang + '/'+ target_base + '/'
#     po_dir     = '/po/'  + lang + '/'

#     # en is a special case...
#     if lang != 'en'
#         foreach xmlfile : pot_source_files
#             xmltarget = xmltarget_base + xmlfile
#             #message(target)
#             gimp_xml = custom_target(xmltarget,
#                 output: [xmltarget],
#                 command: [
#                     xml2po,
#                     '--po-file=' + meson.project_source_root() + po_dir + po_source,
#                     '--language=' + lang,
#                     '--output=' + meson.project_build_root() + dest_dir + xmlfile,
#                     meson.project_source_root() + xmlsrc_dir + xmlfile,
#                 ],
#                 build_by_default: true,
#             )
#         endforeach
#     else
#         # English has no po files...
#         foreach xmlfile : pot_source_files
#             xmltarget = xmltarget_base + xmlfile
#             #message(target)
#             gimp_xml = custom_target(xmltarget,
#                 output: [xmltarget],
#                 command: [
#                     'cp',
#                     meson.project_source_root() + xmlsrc_dir + xmlfile,
#                     meson.project_build_root()  + dest_dir   + xmlfile,
#                 ],
#                 build_by_default: true,
#             )
#         endforeach
#     endif

# endforeach
