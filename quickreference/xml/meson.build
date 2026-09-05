message('quickreference: xml subdir')

qr_xml_targets = {}

# We always need the English xml available
lang = 'en'
qr_target = 'qr-xml-' + lang
qr_output = 'gimp-keys-' + lang + '.xml'

# Copy the base xml to the build dir
xml_lang = custom_target(qr_target,
    input: [keys_xml],
    output: [qr_output],
    command: [
        cp,
        '@INPUT@',
        '@OUTPUT@',
    ],
)
qr_en_xml_target = xml_lang

foreach lang : target_linguas
    qr_target = 'qr-xml-' + lang
    qr_output = 'gimp-keys-' + lang + '.xml'
    if lang != 'en'
        # Merge base (English) xml with po translations
        xml_lang = custom_target(qr_target,
            depends: [qr_po_targets.get(lang)],
            input: [qr_en_xml_target],         # The English xml in the build dir
            output: [qr_output],
            command: [
                xml2po,
                '-k',
                '--mode=gimphelp',
                '--po-file=' + meson.project_build_root() + '/quickreference/po/' + lang + '.po',
                '--language=' + lang,
                '--output=@OUTPUT@',
                '@INPUT@',
            ],
        )
    endif
    qr_xml_targets += {lang: xml_lang}
endforeach
