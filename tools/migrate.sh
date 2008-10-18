#!/bin/bash
# This file is part of the gimp-help-2 project and is
# Copyright 2008, Ulf-D. Ehlert, Roman Joost
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

srcdir="src"
xmldir="xml"
potdir="pot"
podir="po"
LINGUAS="de"
SPLIT="/opt/python2.4/bin/python tools/split_xml_multi_lang.py"
XML2PO="python tools/xml2po"	# patched version!!
XMLLANG2EN="tools/xmllang2en.sh -v"

echo "Creating en_US ..."
$XMLLANG2EN --srcdir=$srcdir --dstdir=en_US

echo "Splitting the source XML"
time \
find $srcdir -name .svn -prune -o -name '*.xml' -print |
while read srcfile
do
    base=${srcfile%/*}
    base=${base#$srcdir/}
    $SPLIT --lang="$LINGUAS" --file="$srcfile" \
           --dest="$xmldir"/'*'/"$base"/
done
echo

srcdir=$xmldir/en
echo


echo "Creating POT files"
time \
find $srcdir -name '*.xml' |
while read srcfile
do
    potfile=$potdir/${srcfile#$srcdir/}
    potfile=${potfile%.xml}.pot
    dest=${potfile%/*}
    test -d "$dest" || mkdir -p "$dest"
    echo >&2 $potfile
    $XML2PO --output="$potfile" "$srcfile" 2>&1 | grep -vE 'image file .* not found'
done
echo


echo "Creating PO files"
time \
find $srcdir -name '*.xml' |
while read srcfile
do
    base=${srcfile#$srcdir/}
    for lang in $LINGUAS; do
        xmlfile=$xmldir/$lang/$base
        pofile=${podir}/$lang/${base%.xml}.po
        dest=${pofile%/*}
        test -d "$dest" || mkdir -p "$dest"
        echo >&2 $pofile
        $XML2PO --language $lang --reuse=$xmlfile --output="$pofile" \
                "$srcfile" 2>&1 | grep -vE 'image file .* not found'
    done
done
echo
