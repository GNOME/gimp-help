# po files with one subdir for each supported language

all_po_targets = []

foreach lang : target_linguas
    if lang != 'en'
        message('Update po files for ', lang)
        subdir(lang)
        all_po_targets += lang_po_targets
    endif
endforeach

