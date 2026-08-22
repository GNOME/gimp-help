# Language specific po subdir

lang_po_targets = []

po_files_root = [
    ['appendix.po',     appendix_pot],
    ['concepts.po',     concepts_pot],
    ['dialogs.po',      dialogs_pot],
    ['filters.po',      filters_pot],
    ['gimp.po',         gimp_pot],
    ['glossary.po',     glossary_pot],
    ['introduction.po', introduction_pot],
    ['menus.po',        menus_pot],
    ['preface.po',      preface_pot],
    ['toolbox.po',      toolbox_pot],
    ['tutorial.po',     tutorial_pot],
    ['using.po',        using_pot],
]

foreach pof : po_files_root
    po_target = 'update-po-' + lang + '-' + pof[0]
    gimp_po_lang = custom_target(po_target,
        depends: [pof[1]],      # pot file
        output:  [pof[0]],      # update po
        command: [
            updatepo,
            meson.project_build_root(),
            pof[1],
            lang,
            meson.current_source_dir() / pof[0],
            meson.current_build_dir() / pof[0],
        ],
        # Because po files get out of sync with the source, we probably
        # need build by default set to true.
        build_by_default: true,
    )
    lang_po_targets += gimp_po_lang
endforeach

subdir('filters')
subdir('menus')
subdir('toolbox')
