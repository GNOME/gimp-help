# po files with one subdir for each supported language

########################################################################
####            The GIMP manual languages                           ####
########################################################################

# LINGUAS is read in the main meson.build because we need it in /stylesheets/
# which needs to be done before /po/
po_additional_files = files('LINGUAS')


all_po_targets = []

foreach lang : po_target_linguas
    if lang != 'en'
        message('Update po files for ', lang)
        subdir(lang)
        all_po_targets += lang_po_targets
    endif
endforeach

po_dependencies = all_po_targets