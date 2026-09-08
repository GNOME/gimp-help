message('quickreference: pdf subdir')

pdf_install_prefix = install_prefix / 'pdf/'

foreach lang : target_linguas
    qr_pdf_target = 'qr-pdf-' + lang
    qr_pdf_output = 'gimp-keys-' + lang + '.pdf'

    qr_pdf_lang = custom_target(qr_pdf_target,
        depends: [qr_svg_targets.get(lang)],
        input: [qr_svg_targets.get(lang)],
        output: [qr_pdf_output],
        command: [
            SVG2PDF,
            '-a',
            '-fpdf',
            '-o', meson.project_build_root() + '/quickreference/pdf/' + qr_pdf_output,
            '@INPUT@',
        ],
        install: true,
        install_dir: pdf_install_prefix,
        build_by_default: true,
    )
endforeach
