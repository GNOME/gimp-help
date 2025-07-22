# Create pot file
message('colors submenu')

#target      = 'colors.pot'
#target_pot  = pot_base + subdir_name + '/' + target

target_base = 'colors'
target      = target_base + '.pot'
target_pot  = pot_base + subdir_name + '/' + target
target_po   = target_base + '.po'

# list of source files to make a pot from
pot_source_files = [
    'auto.xml',
    'brightness-contrast.xml',
    'color-balance.xml',
    'color-temperature.xml',
    'colorize.xml',
    'colortoalpha.xml',
    'components.xml',
    'curves.xml',
    'desaturate.xml',
    'dither.xml',
    'exposure.xml',
    'gegl-local-threshold.xml',
    'hot.xml',
    'hue-chroma.xml',
    'hue-saturation.xml',
    'info.xml',
    'introduction.xml',
    'invert.xml',
    'levels.xml',
    'linear-invert.xml',
    'map.xml',
    'posterize.xml',
    'rgb-clip.xml',
    'saturation.xml',
    'shadows-highlights.xml',
    'threshold.xml',
    'tone-mapping.xml',
    'value-invert.xml',
]

# Debugging help...
message('Creating target for ' + target_pot)

colors_pot = custom_target(target,
    depends: [menus_directory],
    input: pot_source_files,
    output: [target],
    command: [
    xml2pot, target_pot, meson.project_build_root(), meson.project_source_root(), '@INPUT@',
    ],
    build_by_default: true,
)

menus_subdir_name = 'colors'
target_name = 'create-subdir-menus-' + menus_subdir_name

# Make sure subdir exists
menus_colors_directory = custom_target(target_name,
    output: [target_name],
    command: [
        'mkdir', '-p',
        meson.project_build_root() + '/pot/menus/' + menus_subdir_name,
    ],
)

menus_base = subdir_name + '/'
target_menus_base = menus_base  + target_base
xml_lang_base = meson.project_build_root() + '/xml'
po_source     = target_po
# for each enabled language create a xml/lang/... target
foreach lang : target_linguas
    # Make lang directory if not existing
    run_command (
        'mkdir', '-p', xml_lang_base + '/' + lang + '/'+ target_menus_base,
        check: false
    )

    # target per lang
    xmltarget_base = lang + '-'
    xmlsrc_dir = '/src/' + target_menus_base + '/'
    dest_dir   = '/xml/' + lang + '/' + target_menus_base + '/'
    po_dir     = '/po/'  + lang + '/' + menus_base

    # en is a special case...
    if lang != 'en'
        foreach xmlfile : pot_source_files
            xmltarget = xmltarget_base + xmlfile
            #message(target)
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    xml2po,
                    '--po-file=' + meson.project_source_root() + po_dir + po_source,
                    '--language=' + lang,
                    '--output=' + meson.project_build_root() + dest_dir + xmlfile,
                    meson.project_source_root() + xmlsrc_dir + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    else
        # English has no po files...
        foreach xmlfile : pot_source_files
            xmltarget = xmltarget_base + xmlfile
            #message(target)
            gimp_xml = custom_target(xmltarget,
                output: [xmltarget],
                command: [
                    'cp',
                    meson.project_source_root() + xmlsrc_dir + xmlfile,
                    meson.project_build_root()  + dest_dir   + xmlfile,
                ],
                build_by_default: true,
            )
        endforeach
    endif

endforeach

# subdirs of the menus menu

subdir('auto')
subdir('components')
subdir('desaturate')
subdir('info')
subdir('map')
subdir('tone-mapping')
