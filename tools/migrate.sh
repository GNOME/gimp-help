#!/bin/bash
# this script migrates the content from DocBook XML files to PO/GETTEXT
# supported XML files ??!?!

# XXX: what about fi?
#LINGUAS="de en es fr it ko nl no pl ru sv"
: ${LINGUAS:="de fr"}

: ${srcdir:=src}
: ${oldsrcdir:=oldsrc}
: ${xmldir:=xml}
: ${potdir:=pot}
: ${podir:=po}

SPLIT="python tools/split_xml_multi_lang.py"
XML2PO="python tools/xml2po"	# patched version!!

: ${exclude_patterns:='.svn key-reference* glossary dictionary'}
exclude=$(echo "$exclude_patterns" | \
          sed -e 's/[^ ]\+/"&"/g; s/ / -o -name /g; s/^/\\( -name /; s/$/ \\) -prune /')

# clean-up
if [ -d "$oldsrcdir" ]; then
    echo >&2 Removing $srcdir, $potdir, $podir, $xmldir ...
    test -L $xmldir/en && rm $xmldir/en
    test -d $srcdir && rm -rf $srcdir
    test -d $potdir && rm -rf $potdir
    test -d $podir  && rm -rf $podir
    test -d $xmldir && rm -rf $xmldir
    mv $oldsrcdir $srcdir
fi

echo >&2 "Splitting the source XML"
echo >&2 "Warning: the following files and directories will be skipped:"
echo "$exclude_patterns" | sed -e 's/ /, /g; s/^/    /' >&2
time \
eval find $srcdir $exclude -o -name '*.xml' -print |
while read srcfile
do
    base=${srcfile%/*}
    base=${base#$srcdir}
    $SPLIT --lang="$LINGUAS" --file="$srcfile" \
           --dest="$xmldir"/'*'/"${base#/}"/
done
echo

echo >&2 Moving $srcdir and $xmldir ...
mv -vi "$srcdir" "$oldsrcdir" && \
mv -vi "$xmldir"/en "$srcdir" && \
echo >&2 Creating "$xmldir"/en link to "$srcdir" ...
ln -vs $PWD/"$srcdir" "$xmldir"/en
echo

test "$1" = "split" && exit 0

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
    #$XML2PO --output="$potfile" "$srcfile" 2>&1 | grep -vE 'image file .* not found'
    ($XML2PO --output='-' "$srcfile" | msguniq | msgcat -w80 - > "$potfile") 2>&1 | grep -vE 'image file .* not found'
done
echo

test "$1" = "pot" && exit 0

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
        #$XML2PO --language $lang --reuse=$xmlfile --output="$pofile" \
        #        "$srcfile" 2>&1 | grep -vE 'image file .* not found'
        ($XML2PO --language $lang --reuse=$xmlfile --output='-' \
                 "$srcfile" | msguniq | msgcat -w80 - > "$pofile") 2>&1 \
        | grep -vE 'image file .* not found'
    done
done
echo

echo Simple check: searching for empty files...
trap "rm -f 'empty files'" HUP INT QUIT PIPE TERM
find ${podir} ${potdir} -type f -size 0 | sort | tee "empty files"
echo $(wc -l "empty files") found. && rm -f "empty files"
echo


