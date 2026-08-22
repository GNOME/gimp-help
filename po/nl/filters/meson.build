# Language specific po subdir

po_files_filters = [
    ['animation.po',            filters_animation_pot],
    ['artistic.po',             filters_artistic_pot],
    ['blur.po',                 filters_blur_pot],
    ['combine.po',              filters_combine_pot],
    ['decor.po',                filters_decor_pot],
    ['distort.po',              filters_distort_pot],
    ['edge-detect.po',          filters_edge_detect_pot],
    ['enhance.po',              filters_enhance_pot],
    ['generic.po',              filters_generic_pot],
    ['light-and-shadow.po',     filters_light_and_shadow_pot],
    ['map.po',                  filters_map_pot],
    ['noise.po',                filters_noise_pot],
    ['render.po',               filters_render_pot],
    ['web.po',                  filters_web_pot],
]

target_po_files = po_files_filters
subdir = 'filters'
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
