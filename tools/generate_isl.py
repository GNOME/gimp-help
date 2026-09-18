#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
#
# generate_isl_po.py - Generate single language isl file
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
# Based in part on generate_meson_build.py

import os, sys
import re
import getopt

VERBOSE = False
VERSION = 0.1


def printVersion():
    print(f"\ngenerate_meson_build.py v {VERSION}")

def usage():
    printVersion()
    print("""Generates help.langcode.isl files from the multilingual help.isl.

usage: generate_isl.py langcode directory

    options:
        -h      --help          this help""")

def main(argv):
    # default assume current directory is root_dir
    root_dir  = '.'
    global VERBOSE

    src_file = 'help.isl'
    langcode = 'en'

    try:
        opts, remaining_args = getopt.getopt(argv, "hv",
            [
                "help", "verbose"
            ])
    except getopt.GetoptError as err:
        usage()
        sys.exit(1)

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
            sys.exit(0)
        elif opt == "-v" or opt == "--verbose":
            VERBOSE = True

    if remaining_args is not None:
        if len(remaining_args) >= 1:
            langcode = remaining_args[0]
            if VERBOSE:
                print(f" Selected langcode: {langcode}")
        else:
            usage()
            sys.exit(1)

        if len(remaining_args) >= 2:
            root_dir = remaining_args[1]
            if VERBOSE:
                print(f" Selected directory: {root_dir}")
    else:
        usage()
        sys.exit(1)


    root_dir = os.path.abspath(root_dir)
    if not (root_dir.endswith("/") or root_dir.endswith("\\")):
        root_dir += '/'

    prefix    = f"[{langcode}]"
    base_isl  = root_dir + src_file
    lang_file = f"help.{langcode}.isl"
    dest_file = root_dir + lang_file

    if not os.path.exists(base_isl):
        print(f"File {base_isl} does not exist!")
        sys.exit(1)

    file_contents = ''
    with open(base_isl, "r", encoding="utf-8") as base:
        lines = base.read().splitlines()

    for line in lines:
        if line == "" or line[0] == ';'  or line[0] == '[' or prefix in line or \
            (langcode == 'en' and not '[' in line):
            if not langcode == 'en':
                line = line.replace(prefix, "")
            file_contents += line + "\n"
            if VERBOSE:
                print(line)

    with open(dest_file, "w", encoding="utf-8-sig", newline="\n") as f:
        f.write(file_contents)


if __name__ == "__main__":
    main(sys.argv[1:])
