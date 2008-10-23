#  This the autoconf script for the gimp-help-2 project.
#  The GPL version 2 applies to it, which you may get from
#  http://www.gnu.org/.

AC_PREREQ(2.54)

m4_define([help_major_version], [2])
m4_define([help_minor_version], [4])
m4_define([help_micro_version], [1])

m4_define([help_version], [help_major_version.help_minor_version.help_micro_version])

AC_INIT([GIMP-Help], [help_version])

AC_CONFIG_SRCDIR([src/gimp.xml])

AM_INIT_AUTOMAKE([1.6 dist-bzip2 -Wall -Wno-portability])


AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET


#  You can set the ALL_LINGUAS environment variable to
#  control what languages are build.
#  
#  GIMP 2.2 Linguas: Content for those language code exist, but they
#  haven't been worked on for a while:
#  ALL_LINGUAS="cs de en es fr hr it ko nl no ru sv zh_CN"
#
XML_LANG="en"

QUICKREFERENCE_ALL_LINGUAS="de en fr it ko ru sv"

if test "x$ALL_LINGUAS" = "x"; then
  ALL_LINGUAS="de en es fr it ko nl no pl ru sv"
else
  QUICKREFERENCE_LINGUAS=""
  for asked_lang in $ALL_LINGUAS ; do
    for lang in $QUICKREFERENCE_ALL_LINGUAS ; do
      if test "$lang" = "$asked_lang"; then
        QUICKREFERENCE_LINGUAS="$QUICKREFERENCE_LINGUAS $asked_lang"
      fi
    done
  done
  QUICKREFERENCE_ALL_LINGUAS=$QUICKREFERENCE_LINGUAS
fi

AC_SUBST(XML_LANG)
AC_SUBST(ALL_LINGUAS)
AC_SUBST(QUICKREFERENCE_ALL_LINGUAS)


#  The build of the HTML files is optional.

AC_ARG_ENABLE(build,
              AS_HELP_STRING([--disable-build],
                             [don't build the HTML files (needs xsltproc)]),
              , enable_build=yes)

AM_CONDITIONAL(GIMP_HELP_BUILD, test "x$enable_build" = "xyes")


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
if test -z "$XSLTPROC" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find xsltproc(1). You will need it to build the help files.
** If you want to install the prebuilt help files only, use --disable-build.
** See the file 'INSTALL' for more help.])
fi


#  Search for xmllint

AC_PATH_PROG(XMLLINT, xmllint)
if test -z "$XMLLINT" && test "x$enable_build" = "xyes"; then
  AC_MSG_WARN([cannot find xmllint(1), XML will not be validated])
fi

AM_CONDITIONAL(HAVE_XMLLINT, test -n "$XMLLINT")


#  Search for dblatex

AC_PATH_PROG(DBLATEX, dblatex)
if test -z "$DBLATEX"; then
  AC_MSG_WARN([cannot find dblatex(1), PDF generation disabled])
fi

AM_CONDITIONAL(HAVE_DBLATEX, test -n "$DBLATEX")


#  Optional: dot to create build system map

AC_PATH_PROG(DOT, dot)
if test -z "$DOT"; then
  AC_MSG_WARN([cannot find dot(1), creating build system PNG disabled])
fi

AM_CONDITIONAL(HAVE_DOT, test -n "$DOT")


#  Search for docbook2odf

AC_PATH_PROG(DOCBOOK2ODF, docbook2odf)
if test -z "$DOCBOOK2ODF"; then
  AC_MSG_WARN([cannot find docbook2odf(1), ODF generation disabled])
fi

AM_CONDITIONAL(HAVE_DOCBOOK2ODF, test -n "$DOCBOOK2ODF")


#  Search for xml2po

AC_PATH_PROG(XML2PO, xml2po)
if test -z "$XML2PO"; then
  AC_MSG_WARN([cannot find xml2po(1), SVG generation disabled
(this tool is part of the gnome-doc-utils package)])
fi

AM_CONDITIONAL(HAVE_XML2PO, test -n "$XML2PO")


#  Search for gettext tools

AC_PATH_PROG(MSGFMT, msgfmt)
if test -z "$MSGFMT" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find msgfmt(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi

MSGFMTFLAGS="--check --use-fuzzy --statistics"
AC_SUBST(MSGFMTFLAGS)


AC_PATH_PROG(MSGINIT, msginit)
if test -z "$MSGINIT" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find msginit(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi

MSGINITFLAGS="--no-translator"
AC_SUBST(MSGINITFLAGS)


AC_PATH_PROG(MSGMERGE, msgmerge)
if test -z "$MSGMERGE" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find msgmerge(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi

MSGMERGEFLAGS="--quiet --backup=none --update"
AC_SUBST(MSGMERGEFLAGS)


AC_PATH_PROG(MSGUNIQ, msguniq)
if test -z "$MSGUNIQ" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find msguniq(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi


AC_PATH_PROG(MSGCAT, msgcat)
if test -z "$MSGCAT" && test "x$enable_build" = "xyes"; then
  AC_MSG_ERROR([
** Couldn't find msgcat(1). You will need it to build the help files.
** See the file 'INSTALL' for more help.])
fi


#  Optionally allow xsltproc to access DTDs over the network

AC_ARG_ENABLE(network,
              AS_HELP_STRING([--enable-network],
                             [allow xsltproc to fetch DTDs/entities over the network]))

if test "x$enable_network" != "xyes"; then
  XSLTFLAGS="$XSLTFLAGS --nonet"
fi

AC_SUBST(XSLTFLAGS)


#  Default to the correct way of identifying stylesheets.
#  People need an XML catalog to resolve this to a local file.

STYLEBASE='http://docbook.sourceforge.net/release/xsl/current'


#  Allow to explicitely specify the stylesheet location
#  in case the XML catalog doesn't exist or is broken.

AC_ARG_WITH(xsl,
            AS_HELP_STRING([--with-xsl=<basedir>],
                           [path to the base of the DocBook Modular Stylesheets]))

if test "x$with_xsl" != "x"; then
  STYLEBASE="$with_xsl"
  AC_CHECK_FILE($STYLEBASE/xhtml/docbook.xsl, ,
                AC_MSG_ERROR([** Couldn't find docbook.xsl in $STYLEBASE/xhtml]))
fi

AC_SUBST(STYLEBASE)


#  We need the GIMP data directory to install the help files.

AC_ARG_WITH(gimp,
            AS_HELP_STRING([--without-gimp],
                           [skip check for gimp2, install into PREFIX]))

if test "x$with_gimp" != "xno"; then
  #  Note: AC_MSG_ERROR() must be bracket-quoted, or else errors result
  PKG_CHECK_MODULES(GIMP, gimp-2.0, , [AC_MSG_ERROR([
** Couldn't find a GIMP-2.0 installation. If you want to skip this check and
** install the help files to the configured prefix, use the --without-gimp
** configure option. Note that GIMP will then only find the help files if it
** is installed in the same prefix. See the file 'INSTALL' for more help.])])

  gimpdatadir=`$PKG_CONFIG --variable=gimpdatadir gimp-2.0`
else
  gimpdatadir='$(datadir)/gimp/2.0'
fi

AC_SUBST(gimpdatadir)


AC_CONFIG_FILES([
Makefile
quickreference/Makefile
omf/gimp-C.omf
stylesheets/plainhtml.xsl
stylesheets/htmlalternate.xsl
])

AC_OUTPUT

AC_MSG_RESULT([
 Rebuild the help files:    $enable_build
 Languages:                 $ALL_LINGUAS
 Installation prefix:       $gimpdatadir
])
