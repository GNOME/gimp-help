#!/bin/sh
#
# check_image_resolutions -- find image files with resolution != 144x144 dpi
# Copyright (C) 2009 The GIMP Documentation Team.
# License: GPL
#

usage="Usage: ${0##*/} DIR [DIR ...]"
programs="find xargs identify awk"

die() {
    exitcode="$1"; shift
    echo >&2 "$*"
    exit $exitcode
}

# Check command line arguments
if [ -n "$1" ]; then
    for arg; do
        test -d "$arg" || die 65 "No such directory: $arg"
    done
else
    die 64 "$usage"
fi

# Check for required programs
for prog in $programs; do
    type $prog >/dev/null 2>&1 || die 69 "Missing program: $prog"
done

# Start
find "$@" -name .git -prune \
          -o \( -name *.png -o -name *.jpg \) -print | \
xargs identify -format "%d/%f %x %y %wx%h\n" | \
sort | \
awk '
    BEGIN {
        n = 0; m = 0;
        c[0]="|"; c[1]="/"; c[2]="-"; c[3]="\\";
        print("Checking image files for potential resolution problems...");
    }
    # Input:
    #     $1  -  file name (incl. path)
    #     $2  -  x resolution (ok: 56.69, 56.70, 143.*, 144.*)
    #     $3  -  x units (e.g. "PixelsPerInch", "Undefined", ...)
    #     $4  -  y resolution
    #     $5  -  y units
    #     $6  -  <width>x<height>
    # Example:
    #     path/to/image.png 56.69 PixelsPerCentimeter \
    #         56.69 PixelsPerCentimeter 273x303
    /./ { ++n }
    /./ && ($2 !~ /^(56\.|14[34])/ || $4 !~ /^(56|14[34])/) {
        ++m;
        if ($2 != $4) {
            printf("%s (%s): %sx%s [%s]\n", $1, $6, $2, $4, $3)
        } else {
            printf("%s (%s): %s [%s]\n", $1, $6, $2, $3)
        }
    }
    END {
        printf("  Total: %d    Suspects: %d\n", n, m);
    }
'

