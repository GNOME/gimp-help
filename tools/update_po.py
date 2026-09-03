#!/usr/bin/env python3
#
# update_po.py - Updates or inits po file
# Copyright (c) 2026 Jacob Boerema.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Conversion of the Makefile routine

# Merge template (pot) and message catalog (po) or create a new catalog
#
# Usage:
#     $(call pot2po,pot-file,language,po-file)
# Parameters:
#     $1 - input POT file
#     $2 - translation language
#     $3 - output PO file
# pot2po = test -e $(3) || \
#              $(MSGINIT) $(MSGINITFLAGS) --input $(1) --locale=$(2) --output=$(3); \
#          with_compendium="$(shell $(call get_compendium,$3)) \
#                           $(shell $(call use_gimp_po_files,$2))"; \
#          $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} --update $(3) $(1) \
#          && $(MSGFMT) $(MSGFMTFLAGS) $(3) || exit 70; \
#          rm -f $(3)~ messages.mo messages.gmo

import sys, os
import subprocess
import shutil
import time

VERBOSE=0

build_dir = sys.argv[1]
pot_file  = sys.argv[1] + '/' + sys.argv[2]
lang      = sys.argv[3]
src_po    = sys.argv[4]
dest_po   = sys.argv[5]

#1. Check if po file exists, if not init empty po file


# print("1: " + sys.argv[1])  # build dir
# print("2: " + sys.argv[2])  # pot/concepts.pot
# print("3: " + sys.argv[3])  # nl
# print("4: " + sys.argv[4])  # concepts.po in source
# print("5: " + sys.argv[5])  # concepts.po in build

if VERBOSE > 0:
    print("pot: " + pot_file)
    print("src po: " + src_po)
    print("dest po: " + dest_po)

if not os.path.isfile(src_po):
    if VERBOSE > 0:
        print('Initializing missing po file: ' + src_po)
    #FIXME After the first time build/po is initialized, but not src po,
    #      What to do about that?
    init_cmd = subprocess.Popen(
        ["msginit",
            "--no-translator",
            "--width=79",
            "--input %s"  % pot_file,
            "--locale=%s" % lang,
            "--output=%s" % dest_po,
        ],
        stdin=sys.stdout,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    cmdout, cmderr = init_cmd.communicate()
    if init_cmd.returncode:
        raise Exception("Error during msginit command.")

else:
    # For now: just copy to build/po
    # FIXME should test first which is newer
    shutil.copy(src_po, dest_po)


# We need to start in the directory where the dest po is and use
# the dest po file without path, or else the po files will contain
# references to the fully qualified paths when updating the po files.
#FIXME Probably needs to be done in POT instead of here!

dest_path = os.path.dirname(dest_po)
dest_base = os.path.basename(dest_po)
os.chdir(dest_path)

dest_po = dest_base

#2 Merge po with pot

#outfile="dummy.po"
merge_cmd = subprocess.Popen(
    ["msgmerge",
        "--quiet",
        "--width=79",
        "--update",
        dest_po,
        pot_file,
    ],
)
cmdout, cmderr = merge_cmd.communicate()
if merge_cmd.returncode:
    raise Exception("Error during msgmerge command.")


#3 fmt po

# When using meson it apparently happens that msgfmt is called when
# the pofile is already in use by another process.
# We will try it again 20 times and sleep for 5 seconds in between.
result  = 1
max_cnt = 20
counter = 0
while result != 0 and counter < max_cnt:
    fmt_cmd = subprocess.Popen(
        ["msgfmt",
            "--check",
            "--use-fuzzy",
            "--statistics",
            dest_po,
        ],
        stdin=sys.stdout,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    cmdout, cmderr = fmt_cmd.communicate()
    if not fmt_cmd.returncode:
        result = 0
    counter += 1
    if (result):
        if counter == 1:
            print(f"Msgfmt failed, trying again...", file=sys.stderr)
        #print(f"Errors: {cmderr}")

        time.sleep(5)

if result:
    print(f"Gave up after {counter} times`. Last error: {cmderr.decode("utf-8")}")
    sys.exit(7)
elif counter > 1:
    print(f"Succeeded after {counter} times")

# cmdout, cmderr = fmt_cmd.communicate()
# if fmt_cmd.returncode:
#     raise Exception("Error during msgfmt command.")

#FIXME 4 Remove backup files (extension ~po) and messages.mo
#        Possibly also change things to not have messages.mo, but unique name per call
