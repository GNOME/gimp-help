# Language specific po subdir

po_files_menus_colors = [
    ['auto.po',         colors_auto_pot],
    ['components.po',   colors_components_pot],
    ['desaturate.po',   colors_desaturate_pot],
    ['info.po',         colors_info_pot],
    ['map.po',          colors_map_pot],
    ['tone-mapping.po', colors_tone_mapping_pot],
]

target_po_files = po_files_menus_colors
subdir = 'menus-colors'
target_base_name = 'update-po-' + lang + '-' + subdir + '-'
foreach pof : target_po_files
    po_target = target_base_name + pof[0]
    gimp_po_lang = custom_target(po_target,
        depends: [pof[1]],      # pot file
        output:  [pof[0]],      # update po
        command: [
            updatepo,
            meson.project_build_root(),
            pof[1],
            lang,
            meson.current_source_dir() / pof[0],
            meson.current_build_dir()  / pof[0],
        ],
        # Because po files get out of sync with the source, we probably
        # need build by default set to true.
        build_by_default: true,
    )
    lang_po_targets += gimp_po_lang
endforeach
