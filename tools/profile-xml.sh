#!/bin/bash
srcdir="src"
dstdir="xml"
infile=""
outfile="-"
lang="en"
verbose=''
help=0
stylesheet="stylesheets/profile.xsl"

usage() {
    exit_code="$1"
    err_msg="$2"
    test -n "$exit_code" || exit_code=0
    test -n "$err_msg" && echo >&2 "Error:" "$err_msg"
    echo "USAGE:"
    echo "   ${0##*/} -h|--help"
    echo "   ${0##*/} [OPTIONS] ([DIR-OPTIONS] | [FILE-OPTIONS])"
    echo "OPTIONS:"
    echo "   -v | --verbose             hmm, pretty useless ;-)"
    echo "   -l | --lang    <language>  [default: en]"
    echo "FILE-OPTIONS:"
    echo "   -i | --input  <input file>   profile a single file only"
    echo "   -f | --file   <input file>   ditto."
    echo "   -o | --output <output file>  [default: stdout]"
    echo "DIR-OPTIONS:"
    echo "   -s | --srcdir <source directory>      [default: src/]"
    echo "   -d | --dstdir <destination directory> [default: xml/]"
    echo "                 (this directory must exist)"
    echo
    exit $exit_code
}

options=`getopt -n profile-xml.sh --unquoted \
         --longoptions "srcdir:,dstdir:,input:,file:,output:,lang:,verbose,help" \
         --options "s:d:i:f:o:l:vh" -- "$@"` || usage 64
set -- $options
while [ -n "$1" ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            verbose='-v'
            ;;
        -s|--srcdir)
            shift
            srcdir="${1%/}"
            ;;
        -d|--dstdir)
            shift
            dstdir="${1%/}"
            ;;
        -i|-f|--input|--file)
            shift
            infile="${1%/}"
            ;;
        -o|--output)
            shift
            outfile="${1%/}"
            ;;
        -l|--lang)
            shift
            lang="$1"
            ;;
        --)
            shift
            break
            ;;
    esac
    shift
done
test $# -eq 0 || usage 64 "Too many arguments: $@"
test -f "$stylesheet" || usage 66 "stylesheet \"$stylesheet\" not found."
test -n "$lang"       || usage 69 "empty language."

if [ -n "$infile" ]; then
    test -f "$infile" || usage 66 "input file \"$infile\" not found."
    case "$outfile" in
        "-") ;;
         "") outfile='-';;
          *) ;;
          *) test -f "$outfile" || 
             usage 66 "output file \"$outfile\" not found.";;
    esac
    srcdir=""
    dstdir=""
else
    test -d "$srcdir" || usage 66 "source directory \"$srcdir\" not found."
    test -d "$dstdir" || usage 73 "destination directory \"$dstdir\" not found."
fi

if [ -n "$infile" ]; then
    if [ "$outfile" = "-" ]; then
        xsltproc --nonet --stringparam profile.lang "$lang" $stylesheet $infile \
        | sed -e '/^[   ]*$/d' -e 's/^ *<sect[1-4][ >]/\n&/' \
        | xmllint --nonet -
    else
        xsltproc --nonet --stringparam profile.lang "$lang" $stylesheet $infile \
        | sed -e '/^[   ]*$/d' -e 's/^ *<sect[1-4][ >]/\n&/' \
        | xmllint --nonet - > $outfile
    fi
else
    find $srcdir -name '.svn' -prune -o -type d |
    while read src_dir
    do
        dst_dir=${dstdir%/}/${src_dir#*$srcdir} 
        test -d $dst_dir || mkdir $verbose -m 755 $dst_dir
    done
    
    find $srcdir -name '.svn' -prune -o -name '*.xml' -print |
    while read src_file
    do
        test -n "$verbose" && echo $src_file
        dst_file=$dstdir/${src_file#*$srcdir/} 
        xsltproc --nonet --stringparam profile.lang "$lang" $stylesheet $src_file \
        | sed -e '/^[   ]*$/d' -e 's/^ *<sect[1-4][ >]/\n&/' \
        | xmllint --nonet - > $dst_file
    done
fi
