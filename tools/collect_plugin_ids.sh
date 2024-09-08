#!/bin/sh
#
# collect_plugin_ids.sh --
# Copyright (C) 2023 The GIMP Documentation Team.
# License: GPL
#
# Collect all help-ids of plug-ins because these are not stored in
# GIMP's /app/widgets/gimphelp-ids.h.
# Every define that ends in _PROC is considered a help-id.
# Commandline parameters:
# 1 - GIMP's plug-ins folder
# 2 - File path of output file

usage="Usage: ${0##*/} GIMP_DIR OUTPUT_FILE"
programs="grep"

die() {
    exitcode="$1"; shift
    echo >&2 "$*"
    exit $exitcode
}

# Check command line arguments
if [ -n "$1" ]; then
    test -d "$1" || die 65 "No such directory: $arg"
else
    die 64 "$usage"
fi

if ! [ -n "$2" ]; then
    die 64 "$usage"
fi

# Check for required programs
for prog in $programs; do
    type $prog >/dev/null 2>&1 || die 69 "Missing program: $prog"
done

# We consider every define that has _PROC in it as a plug-in id definition
grep -Rh '^#define[[:space:]].*[A-Z_0-9].*_PROC[A-Z_0-9]*[[:space:]].*\"[a-z_].*\"' $1 >$2
