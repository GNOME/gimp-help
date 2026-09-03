message('quickreference: po subdir')

pot_file  = 'gimp-keys.pot'
gimp_keys = files(pot_file)

qr_po_files = files(
    'bg.po',
    'ca.po',
    'cs.po',
    'da.po',
    'de.po',
    'el.po',
    'en_GB.po',
    'eo.po',
    'es.po',
    'fa.po',
    'fi.po',
    'fr.po',
    'hr.po',
    'hu.po',
    'it.po',
    'ja.po',
    'ko.po',
    'lt.po',
    'nl.po',
    'nn.po',
    'pl.po',
    'pt.po',
    'pt_BR.po',
    'ro.po',
    'ru.po',
    'sk.po',
    'sl.po',
    'sr.po',
    'sv.po',
    'tr.po',
    'uk.po',
    'zh_CN.po',
)


gimp_pot = custom_target('gimp-keys.pot',
    input: [keys_xml],
    output: [pot_file],
    command: [
        xml2pot, '@OUTPUT@', '@BUILD_ROOT@', '@SOURCE_ROOT@', '@INPUT@',
    ],
)

# FIXME We may need an optional target to copy an updated
# pot file to the source so we can commit it.

qr_po_targets = {}
qr_po_dependencies = []
foreach lang : po_target_linguas
    if lang != 'en'
        # Update keys po file
        po_target = 'update-qr-po-' + lang
        po_file   = lang + '.po'
        gimp_po_lang = custom_target(po_target,
            depends: [gimp_pot],     # pot file
            output:  [po_file],      # update po
            command: [
                updatepo,
                meson.project_build_root(),
                gimp_pot,
                lang,
                meson.current_source_dir() / po_file,
                meson.current_build_dir() / po_file,
            ],
            # Because po files get out of sync with the source, we probably
            # need build by default and always stale set to true.
            # Maybe not now that we store update po files in the build dir?
            #build_by_default: true,
            #build_always_stale: true,
        )
        qr_po_targets += {lang: gimp_po_lang}
        qr_po_dependencies += gimp_po_lang
    endif
endforeach
