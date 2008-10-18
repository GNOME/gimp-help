#!/bin/sh
# This file is part of the gimp-help-2 project and is
# Copyright 2008, Ulf-D. Ehlert
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
dstdir="xml"
#srcfile=""
verbose=''
help=0
stylesheet="stylesheets/profile.xsl"

usage() {
    exit_code="$1"
    err_msg="$2"
    test -n "$exit_code" || exit_code=0
    test -n "$err_msg" && echo >&2 "$err_msg"
    echo "Usage:"
    echo "   ${0##*/} -h|--help"
    echo "   ${0##*/} [OPTIONS]"
    echo "Options:"
    echo "   -s | --srcdir <source directory>"
    echo "   -d | --dstdir <destination directory>"
    exit $exit_code
}

options=`getopt -n xml2lang.sh --unquoted \
         --longoptions "srcdir:,dstdir:,verbose,help" \
	 --options "s:d:vh" -- "$@"` || usage 64
set -- $options
while [ -n "$1" ]; do
    case "$1" in
           -h|--help) usage;;
        -v|--verbose) verbose='-v';;
         -s|--srcdir) shift; srcdir="${1%/}";;
         -d|--dstdir) shift; dstdir="${1%/}";;
                  --) shift; break;;
    esac
    shift
done
test $# -eq 0 || usage 64 "Too many arguments: $@"

test -d "$srcdir"     || usage 66 "Source directory \"$srcdir\" not found."
test -d "$dstdir"     || usage 73 "Destination directory \"$dstdir\" not found."
test -f "$stylesheet" || usage 66 "Stylesheet \"$stylesheet\" not found."

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
   xsltproc --nonet --stringparam profile.lang en $stylesheet $src_file \
   | sed -e '/^[ 	]*$/d' -e 's/^ *<sect[1-4][ >]/\n&/' \
   | xmllint --nonet - > $dst_file
done
