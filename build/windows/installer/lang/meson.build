#installer_lang_src_dir = meson.current_source_dir()

help_isl_ini = files('help.isl.ini')

help_isl_in  = 'help.isl.in'
help_isl     = 'help.isl' 

# * help.isl.ini is used by intltool-extract to extract the localizable
#   strings. We needed to use the ini syntax for leaving comments to
#   translators (with '#' instead of ';').
# * help.isl.in is in the actual .isl format except for the gettext
#   underscoring.
# * help.isl is in the .isl format but mixing all languages.

create_help_isl_in = custom_target(help_isl_in,
    input: [help_isl_ini],
    output: [help_isl_in],
    depends: [installer_files_all],
    command: [
        sed,
        's/^#/;/',
        '@INPUT@',
    ],
    capture: true,
)

create_help_isl = custom_target('help-isl-multilingual',
    depends: [create_help_isl_in],
    input: [wi_po_dependencies],
    output: [help_isl],
    depend_files: [
        installer_po_files,
        installer_misc_i18n_files,
        installer_i18n_ini,
    ],
    command: [
        INTLTOOL_MERGE,
        meson.project_build_root() / 'po-windows-installer',
        create_help_isl_in,
        './build/windows/installer/lang/' + help_isl,
        '-d',
        '-u',
        #'-q',  # quiet output when we are done testing
        '-c',  meson.project_build_root() / 'po-windows-installer' / '.intltool-merge-cache',
    ],
)


lang_isls = []

# help.en.isl always needs to be available for other languages
isl_base = 'help.en.isl'
create_lang_en_isl = custom_target('help-en-isl',
    input: [create_help_isl],
    output: [isl_base],
    command: [
        generate_isl,
        'en',
        meson.current_build_dir(),
    ],
    build_by_default: true,
)
lang_isls += create_lang_en_isl

foreach lang : po_target_linguas

    if lang != 'en'
        isl_base = 'help.' + lang + '.isl'
        create_lang_isl = custom_target('help-' + lang + '-isl',
            input: [create_help_isl],
            output: [isl_base],
            depends: [create_lang_en_isl],
            command: [
                generate_isl,
                lang,
                meson.current_build_dir(),
            ],
            build_by_default: true,
        )
        lang_isls += create_lang_isl
    endif
endforeach
