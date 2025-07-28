#!/bin/sh
#
# Create a PO-template (POT)
# Since meson can't do piped commands we use a script
# Copyright (C) 2021 The GIMP Documentation Team.
# License: GPL
#
# Assumptions: this script is in the same directory as xml2po
#
# First argument $1 - name of output.pot
# $2 - build root
# $3 = source root
# Arguments $4-...  - xml input files
#
# Ideally we would want to be able to set where
# xml2po, msguniq, msgcat etc. are located but with current (0.50) meson setting
# env variables is cumbersome so let's skip that for now

build_root=$2
source_root=$3
#out_pot="$MESON_BUILD_ROOT/pot/$1"
#out_pot="$MESON_BUILD_ROOT/pot/$1"
#out_pot=$build_root/pot/$1
out_pot=$build_root/$1
src_files="${@:4}"

# Keeping these debug statments for now...
echo Meson source: $MESON_SOURCE_ROOT
echo Meson build: $MESON_BUILD_ROOT

echo First argument: $1
echo Meson source: $source_root
echo Meson build: $build_root
echo Source files: ${@:4}
echo Source files: $src_files
echo Destination file: $out_pot

$source_root/tools/xml2po.py --mode=gimphelp --output=- $src_files \
  | msguniq | msgcat - --width=79 -o "$out_pot"

recent_file="$(ls -t $src_files 2>/dev/null | sed 1q)"

#echo "Most recently updated: $recent_file"

# test -s file - Returns true if file exists, and is not empty.
test -s "$out_pot" || rm -f "$out_pot"; \
touch -c -r $recent_file "$out_pot" || true; \
test -s "$out_pot"
