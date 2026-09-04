message('web: layout subdir')

web_images = [
    '202010-wilber-and-co.jpg',
    'help-system.png',
    'note.png',
    'wilber.png',
]

foreach file : web_images
    web_image = configure_file(
        input : file,
        output: file,
        copy: true,
        #install: true,
        # FIXME: Install location
    )
    html_files += web_image
endforeach
