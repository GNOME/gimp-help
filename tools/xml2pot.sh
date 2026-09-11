#!/bin/bash
# Using bash here explicitly instead of sh to allow substitution of "${@:4}"
#
# Create a PO-template (POT)
# Since meson can't do piped commands we use a script
# Copyright (C) 2021, 2026 The GIMP Documentation Team.
# License: GPL
#
# Arguments (starting at 1)
# $1 - name of output.pot (including subdir)
# $2 - build root (added to output.pot)
# $3 - source root (to find xml2po.py)
# $4 and up ... - xml input files (each with relative path from source root)

build_root=$2
source_root=$3
# Because we change directory below, we need the actual absolute path here
out_pot=`realpath $build_root/$1`

# Put input arguments 4 and up into src_files
src_files="${@:4}"

#FIXME Use env vars for actual locations of MSGUNIQ, MSGCAT?

# We work in the source root. Source files have paths relative to that.
# This is to make sure we don't get ugly paths in the source locations
# shown in the comments of the po files.
cd $source_root

# Combines the strings from input xml files into a pot file
# with all translatable strings
./tools/xml2po.py -k --mode=gimphelp --output=- $src_files \
  | msguniq | msgcat - --width=79 -o "$out_pot"

recent_file="$(ls -t $src_files 2>/dev/null | sed 1q)"

# test -s file - Returns true if file exists, and is not empty.
test -s "$out_pot" || rm -f "$out_pot"; \
touch -c -r $recent_file "$out_pot" || true; \
test -s "$out_pot"
