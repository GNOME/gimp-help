#!/bin/bash
# this script migrates the content from DocBook XML files to PO/GETTEXT
# supported XML files ??!?!

# XXX: what about fi, hr?
: ${LINGUAS:="de es fr it ko nl no pl ru sv"}

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
    echo Removing $srcdir, $potdir, $podir, $xmldir ...
    test -L $xmldir/en && rm $xmldir/en
    test -d $srcdir && rm -rf $srcdir
    test -d $potdir && rm -rf $potdir
    test -d $podir  && rm -rf $podir
    test -d $xmldir && rm -rf $xmldir
    test -e $oldsrcdir/preface/authors.xml && \
        rm -f $oldsrcdir/preface/authors.xml
    mv $oldsrcdir $srcdir
fi

if [ -e $srcdir/preface/titles.xml ] &&
   [ -e stylesheets/authors_docbook.xsl ] &&
   [ -e stylesheets/authors.xml ]; then
    echo "Creating src/preface/authors.xml:"
    echo xsltproc --nonet \
        --output $srcdir/preface/authors.xml \
        stylesheets/authors_docbook.xsl \
        stylesheets/authors.xml
else
    echo >&2 "ERROR: Cannot make $srcdir/preface/authors.xml"
fi

echo "Splitting the source XML:"
echo "Warning: the following files and directories will be skipped:"
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
test -e $srcdir/preface/authors.xml && rm -f $srcdir/preface/authors.xml
echo

echo Saving source directory ...
mv -vi "$srcdir" "$oldsrcdir" && \
mv -vi "$xmldir"/en "$srcdir" && \
echo Creating link "$xmldir"/en ...
ln -vs $PWD/"$srcdir" "$xmldir"/en
echo

test "$1" = "split" && exit 0

echo "Reformatting English XML files:"
find $srcdir/ -type f -name '*.xml' |
while read xmlfile; do
    xmllint --nonet --format --output ${xmlfile%.xml}.xmllint $xmlfile
    if test -s ${xmlfile%.xml}.xmllint && \
       mv -f ${xmlfile%.xml}.xmllint $xmlfile
    then
        echo $xmlfile
    else
        echo "ERROR $xmlfile"
    fi
done
echo

test "$1" = "xmllint" && exit 0

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


