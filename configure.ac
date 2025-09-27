#  This the autoconf script for the gimp-help project.
#  The GPL version 2 applies to it, which you may get from
#  http://www.gnu.org/.

AC_PREREQ(2.54)

m4_define([help_major_version], [3])
m4_define([help_minor_version], [0])
m4_define([help_micro_version], [1])

m4_define([help_version], [help_major_version.help_minor_version.help_micro_version])

m4_define([python3_required_version], [3.6.0])

AC_INIT([GIMP-Help], [help_version])

# Apparently this macro must be called before "AM_INIT_AUTOMAKE"
AC_CANONICAL_BUILD
case $build_os in
  *cygwin*|mingw*) IS_CYGWIN=yes;;
         *) IS_CYGWIN=no;;
esac
# for use in Makefile.am
AM_CONDITIONAL(CYGWIN, test $IS_CYGWIN = yes)
# for use in Makefile
#AC_SUBST(IS_CYGWIN)

AC_CONFIG_SRCDIR([src/gimp.xml])
AC_CONFIG_MACRO_DIR([m4macros])
AC_CONFIG_COMMANDS(
    [stylesheets],
    [test "${srcdir:-.}" != "${builddir:-.}" &&
     { test -d stylesheets || mkdir stylesheets; } &&
     cp -f $srcdir/stylesheets/*.xsl $srcdir/stylesheets/*.dtd $srcdir/stylesheets/languageVocab.xml $srcdir/stylesheets/entities.xml stylesheets/]
)
# XXX: use this if 'configure' (instead of 'config.status') should do it:
#AC_CONFIG_COMMANDS_POST([
#    test "${srcdir:-.}" != "${builddir:-.}" &&
#    { test -d stylesheets || mkdir stylesheets; } &&
#    cp -f $srcdir/stylesheets/*.xsl $srcdir/stylesheets/*.dtd $srcdir/stylesheets/languageVocab.xml $srcdir/stylesheets/entities.xml stylesheets/
#])

AM_INIT_AUTOMAKE([1.16 tar-pax dist-bzip2 -Wall -Wno-portability])

AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MKDIR_P
AC_PROG_MAKE_SET
AC_PROG_SED


#  You can set the LINGUAS or LANGUAGES environment variable to
#  control what languages are built:
#      LINGUAS   will be re restricted to languages in ALL_LINGUAS
#      LANGUAGES will override ALL_LINGUAS
#

if test "x$ALL_LINGUAS" = "x"; then
	ALL_LINGUAS="bg ca cs da de el en en_GB eo es fa fi fr hr hu it ja ko lt nl nn pl pt pt_BR ro ru sk sl sv tr uk zh_CN"
else
  ALL_LINGUAS=`echo "$ALL_LINGUAS" | $SED -e 's/[,] */ /g'`
fi

AC_SUBST(ALL_LINGUAS)


#  It doesn't make sense to disable HTML build.

AC_ARG_ENABLE(build, AS_HELP_STRING([--disable-build], [obsolete]), , )
#AM_CONDITIONAL(GIMP_HELP_BUILD, true)

#AC_ARG_ENABLE(i18n,
#              AS_HELP_STRING([--disable-i18n],
#                             [don't build translated HTML files (with xml2po & gettext)]),
#              , enable_i18n=yes)
#AM_CONDITIONAL(GIMP_HELP_I18N, test "$enable_i18n" = "yes")

test "$ALL_LINGUAS" != "en" && enable_i18n=yes || enable_i18n=no


#  Check for GNU make.

AC_MSG_CHECKING([whether ${MAKE-make} is GNU make])
if (${MAKE-make} --version) < /dev/null > /dev/null 2>&1; then
  if (${MAKE-make} --version) 2> /dev/null | grep 'GNU Make' > /dev/null 2>&1; then
    AC_MSG_RESULT(yes)
  else
    AC_MSG_RESULT(no)
    AC_MSG_WARN([
** It seems that the make utility is not GNU Make. Since this project
** makes use of GNU Make extensions, you may run into build problems.
** Please use GNU Make if possible.
])
  fi
else
  AC_MSG_ERROR([${MAKE-make} not found])
fi


#  Search for the XSLT processor

AC_PATH_PROG(XSLTPROC, xsltproc)
if test -z "$XSLTPROC"; then
  AC_MSG_ERROR([
** Couldn't find xsltproc(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi


#  Search for xmllint

AC_PATH_PROG(XMLLINT, xmllint)
if test -z "$XMLLINT" && test "x$enable_build" = "xyes"; then
  AC_MSG_WARN([cannot find xmllint(1), XML will not be validated])
fi

AM_CONDITIONAL(HAVE_XMLLINT, test -n "$XMLLINT")
XMLLINTFLAGS="--nonet"
AC_SUBST(XMLLINTFLAGS)


#  Search for dblatex

AC_PATH_PROG(DBLATEX, dblatex)
if test -z "$DBLATEX"; then
  AC_MSG_WARN([cannot find dblatex(1), PDF generation disabled])
fi

AM_CONDITIONAL(HAVE_DBLATEX, test -n "$DBLATEX")
DBLATEXFLAGS="--backend=xetex --style=db2latex --verbose"
AC_SUBST(DBLATEXFLAGS)

#  Search for rsvg-convert used for building quickreference PDF's

AC_PATH_PROG(SVG2PDF, rsvg-convert)
if test -z "$SVG2PDF"; then
  AC_MSG_NOTICE([cannot find rsvg-convert(1), Quickreference PDF generation disabled])
fi

AM_CONDITIONAL(HAVE_SVG2PDF, test -n "$SVG2PDF")
SVG2PDF_FLAGS="-a -f pdf"
AC_SUBST(SVG2PDF_FLAGS)

#  Use our customized xml2po

AM_PATH_PYTHON3(python3_required_version, libxml2, ,)

XML2PO='$(PYTHON) $(top_srcdir)/tools/xml2po.py'
XML2POFLAGS='--mode=gimphelp --base=$(top_srcdir)/'
AC_SUBST(XML2PO)
AC_SUBST(XML2POFLAGS)


#  Search for gettext tools

AC_PATH_PROG(MSGFMT, msgfmt)
if test -z "$MSGFMT" && test "x$enable_i18n" = "xyes"; then
  # print warning only for the main i18n tools xml2po & msgfmt
  AC_MSG_WARN([cannot find msgfmt])
  missing_i18n_tools=${missing_i18n_tools:+"${missing_i18n_tools} "}msgfmt
fi
MSGFMTFLAGS="--check --use-fuzzy --statistics"
AC_SUBST(MSGFMTFLAGS)


AC_PATH_PROG(MSGINIT, msginit)
if test -z "$MSGINIT" && test "x$enable_i18n" = "xyes"; then
  missing_i18n_tools=${missing_i18n_tools:+"${missing_i18n_tools} "}msginit
fi
MSGINITFLAGS='--no-translator --width=$(MSGWIDTH)'
AC_SUBST(MSGINITFLAGS)


AC_PATH_PROG(MSGMERGE, msgmerge)
if test -z "$MSGMERGE" && test "x$enable_i18n" = "xyes"; then
  missing_i18n_tools=${missing_i18n_tools:+"${missing_i18n_tools} "}msgmerge
fi
MSGMERGEFLAGS='--quiet --width=$(MSGWIDTH)'
AC_SUBST(MSGMERGEFLAGS)


AC_PATH_PROG(MSGUNIQ, msguniq)
if test -z "$MSGUNIQ" && test "x$enable_i18n" = "xyes"; then
  missing_i18n_tools=${missing_i18n_tools:+"${missing_i18n_tools} "}msguniq
fi
MSGUNIQFLAGS=
AC_SUBST(MSGUNIQFLAGS)


AC_PATH_PROG(MSGCAT, msgcat)
if test -z "$MSGCAT" && test "x$enable_i18n" = "xyes"; then
  missing_i18n_tools=${missing_i18n_tools:+"${missing_i18n_tools} "}msgcat
fi
MSGCATFLAGS='--width=$(MSGWIDTH)'
AC_SUBST(MSGCATFLAGS)

MSGWIDTH=79
AC_SUBST(MSGWIDTH)

AC_MSG_CHECKING([if building the Windows installer])
AC_ARG_ENABLE(windows-installer,
              [  --enable-windows-installer
                          generate files needed for the Windows installer
                          (default=no)],,
              enable_windows_installer=no)
AC_MSG_RESULT([$enable_windows_installer])
AM_CONDITIONAL(BUILD_WINDOWS_INSTALLER, test "x$enable_windows_installer" != xno)

# Not calling:
# IT_PROG_INTLTOOL(intltool_required_version)
# on purpose because it tries to init po/ and we don't want this as we
# handle our main docs po files differently. So checking the tools we
# need individually for po-windows-installer/.

if test "x$enable_windows_installer" != xno; then
  AC_PATH_PROG(INTLTOOL_MERGE, intltool-merge)
  if test -z "$INTLTOOL_MERGE"; then
    AC_MSG_ERROR([
** Couldn't find intltool-merge(8). It is necessary to build the
** language files for the Windows installer.
** Install the intltool or configure with --disable-windows-installer])
  fi
fi

# The below tools are only necessary to build `make update-po` in
# po-windows-intaller/.
AC_PATH_PROG(INTLTOOL_UPDATE, intltool-update)
if test -z "$INTLTOOL_UPDATE" && test "x$enable_i18n" = "xyes"; then
  AC_MSG_WARN([
** Couldn't find intltool-update(8). You will not be able to run
** `make update-po` in po-windows-intaller/.])
fi
AC_PATH_PROG(INTLTOOL_EXTRACT, intltool-extract)
if test -z "$INTLTOOL_EXTRACT" && test "x$enable_i18n" = "xyes"; then
  AC_MSG_WARN([
** Couldn't find intltool-extract(8). You will not be able to run
** `make update-po` in po-windows-intaller/.])
fi

#  Optional: dot to create build system map

AC_PATH_PROG(DOT, dot)
#if test -z "$DOT"; then
#  AC_MSG_NOTICE([cannot find dot(1), creating build system PNG disabled])
#fi

AM_CONDITIONAL(HAVE_DOT, test -n "$DOT")


#test -z "$missing_i18n_tools" && HAVE_I18N_TOOLS=yes || HAVE_I18N_TOOLS=no
#AC_SUBST(HAVE_I18N_TOOLS)
AM_CONDITIONAL(HAVE_I18N_TOOLS, test -z "$missing_i18n_tools")

test -z "$missing_i18n_tools" || test "$missing_i18n_tools" = "xml2po" &&
HAVE_GETTEXT_TOOLS=yes || HAVE_GETTEXT_TOOLS=no
AM_CONDITIONAL(HAVE_GETTEXT_TOOLS, test "$HAVE_GETTEXT_TOOLS" = "yes")
#AC_SUBST(HAVE_GETTEXT_TOOLS)


#  Optionally allow xsltproc to access DTDs over the network

AC_ARG_ENABLE(network,
              AS_HELP_STRING([--enable-network],
                             [allow xsltproc to fetch DTDs/entities over the network]))

if test "x$enable_network" != "xyes"; then
  XSLTFLAGS="$XSLTFLAGS --nonet"
fi

AC_SUBST(XSLTFLAGS)


#  Optionally allow to build a language selector. A HTML menu is
#  rendered based on ALL_LINGUAS below the header navigation in the HTML
#  output.

AC_ARG_ENABLE(languageMenu,
              AS_HELP_STRING([--enable-languageMenu],
                             [Compile the HTML output with a language selector.]))

if test "x$enable_languageMenu" = "xyes"; then
    XSLTFLAGS="$XSLTFLAGS --stringparam gimp.help.languageselector 1"
fi

AC_SUBST(XSLTFLAGS)


#  Optionally search for pngnq and pngcrush, which are helpful for
#  creating distributions

AC_PATH_PROG(PNGNQ, pngnq)
if test -z "$PNGNQ"; then
  AC_MSG_WARN([cannot find pngnq,
images will not be optimized during distribution creation])
fi



AC_PATH_PROG(PNGCRUSH, pngcrush)
if test -z "$PNGCRUSH"; then
  AC_MSG_WARN([cannot find pngcrush,
images will not be optimized during distribution creation])
fi

AM_CONDITIONAL(HAVE_PNGOPTIMIZERS, test -n "$PNGNQ" && test -n "$PNGCRUSH")


#  Default to the correct way of identifying stylesheets.
#  People need an XML catalog to resolve this to a local file.

STYLEBASE='http://docbook.sourceforge.net/release/xsl/current'


#  Allow to explicitly specify the stylesheet location
#  in case the XML catalog doesn't exist or is broken.

AC_ARG_WITH(xsl,
            AS_HELP_STRING([--with-xsl=<basedir>],
                           [path to the base of the DocBook Modular Stylesheets
                            (deprecated - fix your DocBook Stylesheets package!)
                           ]))

if test "x$with_xsl" != "x"; then
  STYLEBASE="$with_xsl"
  AC_CHECK_FILE($STYLEBASE/xhtml/docbook.xsl, ,
                AC_MSG_ERROR([** Couldn't find docbook.xsl in $STYLEBASE/xhtml]))
fi

AC_SUBST(STYLEBASE)


#  We need the GIMP data directory to install the help files.

AC_ARG_WITH(gimp,
            AS_HELP_STRING([--without-gimp],
                           [skip check for gimp3, install into PREFIX]))

if test "x$with_gimp" != "xno"; then
  #  Note: AC_MSG_ERROR() must be bracket-quoted, or else errors result
  PKG_CHECK_MODULES(GIMP, gimp-3.0, , [AC_MSG_ERROR([
** Couldn't find a GIMP-3.0 installation. If you want to skip this check and
** install the help files to the configured prefix, use the --without-gimp
** configure option. Note that GIMP will then only find the help files if it
** is installed in the same prefix. See the file 'INSTALL' for more help.])])

  gimpdatadir=`$PKG_CONFIG --variable=gimpdatadir gimp-3.0`
else
  gimpdatadir=`pkg-config --variable=gimpdatadir gimp-3.0` ||
  gimpdatadir='$(datadir)/gimp/3.0'
fi

AC_SUBST(gimpdatadir)


if test -n "$missing_i18n_tools" && test "$enable_i18n" = "yes"; then
  AC_MSG_WARN([
** Couldn't find some tools needed to build translated help files.
** You will be able to build the English manual, but no translations.])
  ALL_LINGUAS=en
fi


AC_CONFIG_FILES([
build/Makefile
build/windows/Makefile
build/windows/installer/Makefile
build/windows/installer/lang/Makefile
m4macros/Makefile
Makefile
po-windows-installer/Makefile.in
quickreference/Makefile
stylesheets/plainhtml.xsl
stylesheets/htmlalternate.xsl
])

# By default, autoconf will create only po/Makefile.
# This code is used to create the POTFILES and Makefile for all
# additional gettext catalogs.
m4_define([generate_po_makefile], [
  AC_MSG_NOTICE([Generating POTFILES and Makefile for $1])

  AC_CONFIG_COMMANDS([$1/stamp-it],
  [[
    if  ! grep "^# INTLTOOL_MAKEFILE$" "$1/Makefile.in" > /dev/null ; then
       as_fn_error $? "$1/Makefile.in.in was not created by intltoolize." "$LINENO" 5
    fi
    rm -f "$1/stamp-it" "$1/POTFILES"
    sed -e '/^#/d' -e 's/^[[].*] *//' \
        -e '/^[ 	]*$/d'        \
        -e "s|^|	$ac_top_srcdir/|" \
        "$srcdir/$1/POTFILES.in" | sed '$!s/$/ \\/' >"$1/POTFILES" && \
    sed -e "/^# This comment gets stripped out/ {"  \
        -e 'r $1/POTFILES'                          \
        -e "d" -e "}"                               \
        "$1/Makefile.in" >"$1/Makefile" && \
    touch "$1/stamp-it"
  ]])
])

generate_po_makefile([po-windows-installer])

AC_OUTPUT

AC_MSG_RESULT([
 Languages:                 $ALL_LINGUAS
 Installation prefix:       $gimpdatadir ])
if test -n "$missing_i18n_tools" && test "$enable_i18n" = "yes"; then
 AC_MSG_RESULT([ Missing translation tools: $missing_i18n_tools ])
fi
