#!/bin/sh

test -z "$2" || {
    echo >&2 "Usage: $0 [stylebase]"
    exit 64
}

stylebase=${1:-http://docbook.sourceforge.net/release/xsl/current}

tmpdir="${TMPDIR:-/tmp}"
test -d "${tmpdir}" && test -w "${tmpdir}" || tmpdir=.

cat <<EOF>${tmpdir}/docbooktest.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.3//EN"
                         "http://www.docbook.org/xml/4.3/docbookx.dtd">
<article><para>Hello world!</para></article>
EOF

xsltproc --nonet --noout --nomkdir --nowrite --novalid \
    $stylebase/xhtml/docbook.xsl ${tmpdir}/docbooktest.xml >/dev/null 2>&1
error=$?
rm -f ${tmpdir}/docbooktest.xml

exit $error

