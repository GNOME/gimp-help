message('quickreference: svg subdir')

qr_svg_targets = {}

foreach lang : target_linguas
    qr_svg_target = 'qr-svg-' + lang
    qr_svg_output = 'gimp-keys-' + lang + '.svg'

    svg_lang = custom_target(qr_svg_target,
        depend_files: [keys_svg, templatefiles],
        input: [qr_xml_targets.get(lang)],
        output: [qr_svg_output],
        command: [
            xsltproc,
            '--timing',
            '--nonet',
            '--output', meson.project_build_root() + '/quickreference/svg/' + qr_svg_output, 
            keys_svg,
            '@INPUT0@',
        ],
    )
    qr_svg_targets += {lang: svg_lang}
endforeach
