# Language specific po subdir

po_files_menus = [
    ['colors.po',   menus_colors_pot],
    ['edit.po',     menus_edit_pot],
    ['file.po',     menus_file_pot],
    ['filters.po',  menus_filters_pot],
    ['help.po',     menus_help_pot],
    ['image.po',    menus_image_pot],
    ['layer.po',    menus_layer_pot],
    ['select.po',   menus_select_pot],
    ['view.po',     menus_view_pot],
]

target_po_files = po_files_menus
subdir = 'menus'
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

subdir('colors')