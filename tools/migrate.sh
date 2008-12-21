#!/bin/bash
# this script migrates the content from DocBook XML files to PO/GETTEXT
# supported XML files ??!?!

start_time=`date '+%T' 2>/dev/null`

: ${LINGUAS:="de es fr it ko nl no pl ru sv fi hr lt"}

: ${srcdir:=src}
: ${oldsrcdir:=oldsrc}
: ${xmldir:=xml}
: ${potdir:=pot}
: ${podir:=po}

SPLIT="python tools/split_xml_multi_lang.py"
XML2PO="python tools/xml2po"	# patched version!!

: ${exclude_patterns:='.svn key-reference-* glossary dictionary'}
exclude=$(echo "$exclude_patterns" | \
          sed -e 's/[^ ]\+/"&"/g; s/ / -o -name /g; s/^/\\( -name /; s/$/ \\) -prune /')

# backup source
test -d "$oldsrcdir" || {
    echo "Making source backup '$oldsrcdir' ..."
    cp -r $srcdir $oldsrcdir || exit 66
}

# clean-up
if [ -d "$potdir" ]; then
    echo Removing $potdir, $podir, $xmldir ...
    test -L $xmldir/en && rm $xmldir/en
    test -d $potdir && rm -rf $potdir
    test -d $podir  && rm -rf $podir
    test -d $xmldir && rm -rf $xmldir
    test -e $oldsrcdir/preface/authors.xml && \
        rm -f $oldsrcdir/preface/authors.xml
fi
# echo "Making (temp) source dir '$srcdir' ..."
# cp -a $oldsrcdir $srcdir
# echo

# patches
echo "Applying patches (if any) ..."
for f in *.diff *.diff.gz *.diff.bz2; do
    test -f "$f" || continue
    echo "Patch: $f"
    case $f in
        *.diff.bz2) bzip2 -dc $f;;
        *.diff.gz)  gzip  -dc $f;;
        *.diff)     cat $f;;
    esac | patch --verbose -p0
done
echo

# src/preface/authors.xml
if [ -e $srcdir/preface/titles.xml ] &&
   [ -e stylesheets/authors_docbook.xsl ] &&
   [ -e stylesheets/authors.xml ]
then
    echo "Creating src/preface/authors.xml..."
    xsltproc --nonet \
        --output $srcdir/preface/authors.xml \
        stylesheets/authors_docbook.xsl \
        stylesheets/authors.xml
else
    echo >&2 "ERROR: Cannot make $srcdir/preface/authors.xml"
fi
echo

# split
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
echo

# oldsrc
# echo "Removing old (multi-lang) source directory ..."
# rm -rf "$srcdir" && \
echo "Installing new (single-lang) source directory ..."
cp -rv "$xmldir"/en/* "$srcdir"
# echo Creating link "$xmldir"/en ...
# ln -vs $PWD/"$srcdir" "$xmldir"/en
echo Removing authors files ...
test -e $srcdir/preface/titles.xml && \
    rm -vf $srcdir/preface/titles.xml
test -e $oldsrcdir/preface/authors.xml && \
    rm -vf $oldsrcdir/preface/authors.xml
echo

# src/glossary/glossary.xml
if [ -e $oldsrcdir/glossary/glossary.xml ] &&
   [ -e stylesheets/migrate/convert-glossary.xsl ] &&
   [ -e tools/migrate/convert-glossary.py ]
then
    echo "Removing old glossary and dictionary files ..."
    rm -vf $srcdir/glossary/*.xml
    rm -rvf $srcdir/dictionary
    echo "Creating $srcdir/glossary/glossary.xml:"
    test -d $srcdir/glossary || mkdir $srcdir/glossary
    xsltproc --nonet --xinclude \
        stylesheets/migrate/convert-glossary.xsl \
        $oldsrcdir/glossary/glossary.xml \
    | tools/migrate/convert-glossary.py --lang "$LINGUAS" \
    | xmllint --nonet --format - \
    > $srcdir/glossary/glossary.xml
    echo
    echo "Splitting $srcdir/glossary/glossary.xml:"
    $SPLIT --lang="$LINGUAS" --file="$srcdir/glossary/glossary.xml" \
           --dest="$xmldir"/'*'/glossary/
else
    echo >&2 "ERROR: Cannot make $srcdir/glossary/glossary.xml"
fi
echo

test "$1" = "split" && exit 0

# xmllint
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
echo "Reformatting gimp.xml files:"
for lang in $LINGUAS; do
    test "$lang" != "en" || continue
    xmlfile=$xmldir/$lang/gimp.xml
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

# pot
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

# po
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
                 "$srcfile" | msguniq --use-first | msgcat -w80 - > "$pofile") 2>&1 \
        | grep -vE 'image file .* not found'
    done
done
echo

for lang in $LINGUAS; do
    if test -f $oldsrcdir/key-reference-$lang.xml; then
        echo >&2 "$podir/$lang/key-reference.po"
        cp -vf $podir/$lang/key-reference.po "$podir/$lang/key-reference.po~"
        $XML2PO --language $lang --reuse=$oldsrcdir/key-reference-$lang.xml \
            --output='-' "$srcdir/key-reference.xml" \
        | msguniq --use-first | msgcat -w80 - > "$podir/$lang/key-reference.po"
    fi
done
echo

# check
echo Simple check: searching for empty files...
trap "rm -f 'empty files'" HUP INT QUIT PIPE TERM
find ${podir} ${potdir} -type f -size 0 | sort | tee "empty files"
echo $(wc -l "empty files") found. && rm -f "empty files"
echo

if [ -n "$start_time" ]; then
    echo "Started at  $start_time"
    echo Finished at `date '+%T'`
    echo
fi
