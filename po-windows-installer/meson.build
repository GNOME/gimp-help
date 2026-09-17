# To stay more compatible with the Makefile build during
# our experimental meson build stage, we will not do it the
# same way GIMP does, but start with a more or less literal
# conversion of our Makefiles.

# FIXME: Missing for now is Makefule "update-po" target
# that can be used to add a new language!

installer_po_files = files(
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
    'kk.po',
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
installer_misc_i18n_files = files(
    'POTFILES.in',
    'POTFILES.skip',
)
installer_i18n_ini = [
    meson.project_source_root() / 'build' / 'windows' / 'installer' / 'lang' / 'help.isl.ini',
]

#XGETTEXT_KEYWORDS=--keyword=_ --keyword=N_ --keyword=Q_:1g --keyword=C_:1c,2 --keyword=NC_:1c,2
#MSGMERGE = INTLTOOL_EXTRACT=$(INTLTOOL_EXTRACT) srcdir=$(srcdir) $(INTLTOOL_UPDATE) --gettext-package $(GETTEXT_PACKAGE) --dist
#GENPOT   = INTLTOOL_EXTRACT=$(INTLTOOL_EXTRACT) srcdir=$(srcdir) $(INTLTOOL_UPDATE) --gettext-package $(GETTEXT_PACKAGE) --pot

# $(GETTEXT_PACKAGE).pot: $(POTFILES)
# 	@if test "x$(INTLTOOL_UPDATE)" = "x/bin/true"; then \
# 		echo "Warning: pot generation deactivated on VPATH builds."; \
# 		echo "         See commit c96006919."; \
# 	fi
# 	$(GENPOT)

package_name  = 'gimp-help-windows-installer'
installer_pot = package_name + '.pot'
installer_po_src_dir = meson.current_source_dir()

# 1. generate potfile
POTFILES = '../../../gimp-help/build/windows/installer/lang/help.isl.ini'

if INTLTOOL_UPDATE.full_path() == '/bin/true'
    intltool_warning = 'Pot generation deactivated on VPATH builds. See commit c96006919.'
    warning(intltool_warning)
    warnings += intltool_warning
endif

win_installer_pot = custom_target('pot-windows-installer',
    output: [installer_pot],
    depend_files: [
        installer_po_files,
        installer_misc_i18n_files,
        installer_i18n_ini,
    ],
    command: [
        INTLTOOL_UPDATE,
        #'-x',
        '-g', package_name,
        '--pot',
    ],
    env: [
        'srcdir=' + installer_po_src_dir,
        'XGETTEXT_ARGS=--output=./po-windows-installer/gimp-help-windows-installer.pot',
    ],
)

# 2. Update po files

# FIXME We may need an optional target to copy an updated
# pot file to the source so we can commit it.

wi_po_targets = {}
wi_po_dependencies = []
foreach lang : po_target_linguas
    if lang != 'en'
        # Update Windows installer po files
        po_target = 'update-installer-po-' + lang
        po_file   = lang + '.po'
        gimp_po_lang = custom_target(po_target,
            depends: [win_installer_pot],   # pot file
            output:  [po_file],             # update po
            command: [
                updatepo,
                meson.project_build_root(),
                win_installer_pot,
                lang,
                meson.current_source_dir() / po_file,
                meson.current_build_dir() / po_file,
            ],
        )
        wi_po_targets += {lang: gimp_po_lang}
        wi_po_dependencies += gimp_po_lang
    endif
endforeach


# po_windows_installer_dir = meson.current_source_dir()
# i18n.gettext('gimp-help-windows-installer', preset: 'glib', install: false,
#              data_dirs: [
#                           meson.project_source_root() / 'build' / 'windows' / 'installer' / 'lang',
#                           meson.project_build_root() / 'build' / 'windows' / 'installer' / 'lang',
#                         ])
