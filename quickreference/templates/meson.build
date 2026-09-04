message('quickreference: templates subdir')

templates = [
    'svg_template.xml',
    'wilber.svg',
]

templatefiles = []
foreach file : templates
    templatefile = configure_file(
        input : file,
        output: file,
        copy: true,
    )
    templatefiles += templatefile
endforeach
