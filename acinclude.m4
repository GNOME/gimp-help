# This file is part of the gimp-help-2 project.
# Copyright (C) 2010 The GIMP Documentation Team
# License: GPL
#

# GIMPHELP_DOCBOOK_CHECK_CONFIG([STYLEBASE])
#
# Check if DocBook XSL stylesheets are configured.
# --------------------------------------------------------------
AC_DEFUN([GIMPHELP_DOCBOOK_CHECK_CONFIG],
[AC_CACHE_CHECK([for a working DocBook XSL Stylesheets configuration],
[gh_cv_dcbk_xsl_conf],
[gh_cv_dcbk_xsl_conf=unknown
gh_tmpdir="${TMPDIR:-/tmp}"
test -d "${gh_tmpdir}" && test -w "${gh_tmpdir}" || gh_tmpdir=.
cat <<EOF>${gh_tmpdir}/docbooktest.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.3//EN"
                         "http://www.docbook.org/xml/4.3/docbookx.dtd">
<article><para>Hello world!</para></article>
EOF
xsltproc --nonet --noout $1/xhtml/docbook.xsl ${gh_tmpdir}/docbooktest.xml >/dev/null 2>&1
if test $? -eq 0; then
    gh_cv_dcbk_xsl_conf=yes
else
    gh_cv_dcbk_xsl_conf=no
fi]
)
rm -f ${gh_tmpdir}/docbooktest.xml
HAVE_DOCBOOK_XSL=$gh_cv_dcbk_xsl_conf
if test $gh_cv_dcbk_xsl_conf != yes; then
    AC_MSG_WARN([
    ***
    *** Looks like your DocBook XSL Stylesheets don't work.
    *** Possible reasons:
    ***   (a) DocBook XSL Stylesheets are not installed;
    ***   (b) DocBook XSL Stylesheets are not correctly configured
    ***      (in this case you may have to add a catalog entry
    ***        <rewriteURI uriStartString="$1/"
    ***            file:///path/to/your/xml/docbook/stylesheets"/>
    ***      or
    ***        <rewriteSystem systemIdStartString="$1/"
    ***            file:///path/to/your/xml/docbook/stylesheets"/>
    ***      to your XML catalog file (usually /etc/xml/catalog)).
    ***])
fi
])
