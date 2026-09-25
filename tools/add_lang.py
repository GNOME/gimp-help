#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
#
# add_lang.py - Add a new language
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


import os, sys
import re
import getopt
from pathlib import Path

VERBOSE = False
VERSION = 0.1


def printVersion():
    print(f"\nadd_lang.py v {VERSION}")

def usage():
    printVersion()
    print("""Adds a new language.

usage: add_lang.py [options] langcode English Native

    langcode                    The code for this language
    English                     The US English name of this language
    Native                      The native name of this language

    options:
        -h      --help          this help""")

def replace_in_file(file_path, search_text, replace_text):
    path = Path(file_path)
    
    # Read the file contents
    content = path.read_text(encoding="utf-8", newline="\n")
    
    # Replace the target text
    new_content = content.replace(search_text, replace_text)

    if content == new_content:
        print(f"ERROR: {search_text} not found in {file_path}!")
        exit(1)
    
    # Write the updated contents back to the file
    path.write_text(new_content, encoding="utf-8", newline="\n")

    print(f"{file_path} has been updated.")


def re_replace_in_file(file_path, search_pattern, add_text, flags = None):
    path = Path(file_path)

    # Read the file contents
    content = path.read_text(encoding="utf-8", newline="\n")

    # Replace the target text
    #new_content = content.replace(search_text, replace_text)
    if flags is None:
        new_content = re.sub(search_pattern, rf"\1\n{add_text}", content)
    else:
        new_content = re.sub(search_pattern, rf"\1\n{add_text}", content, flags=flags, count=1)

    if content == new_content:
        print(f"ERROR: {search_pattern} not found in {file_path}!")
        exit(1)

    # Write the updated contents back to the file
    path.write_text(new_content, encoding="utf-8", newline="\n")

    print(f"{file_path} has been updated.")


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

    if remaining_args is None or len(remaining_args) != 3:
        usage()
        sys.exit(1)
    else:
        langcode = remaining_args[0]
        name_en  = remaining_args[1]
        native   = remaining_args[2]

        if len(name_en) < 2 or len(native) < 2:
            print(f"Invalid English or Native name")
            sys.exit(1)
        if langcode == "en" or langcode == "en_US":
            print(f"No need to add US English. It is the default language!")
            sys.exit(1)


    root_dir = os.path.abspath(root_dir)
    if not (root_dir.endswith("/") or root_dir.endswith("\\")):
        root_dir += '/'

    # 1. Update po/LINGUAS

    LINGUAS_path = root_dir + 'po/LINGUAS'
    if not os.path.exists(LINGUAS_path):
        print(f"File {LINGUAS_path} does not exist!")
        sys.exit(1)

    with open(LINGUAS_path, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()

    if langcode in lines:
        print(f"Language code '{langcode}' is already present!")
        sys.exit(1)
    else:
        new_LINGUAS = ""
        found = False
        prev_code = ""
        for line in lines:
            if line.startswith("#") or line[0] == "":
                new_LINGUAS += line + "\n"
            elif line < langcode or found:
                new_LINGUAS += line + "\n"
                if not found:
                    prev_code = line
            elif not found:
                new_LINGUAS += langcode + "\n" + line + "\n"
                found = True
            else:
                raise RuntimeError("LINGUAS line not copied!")
        
        if not found:
            # add as new last code
            new_LINGUAS += langcode + "\n"

        with open(LINGUAS_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(new_LINGUAS)
            print(f"{LINGUAS_path} has been updated.")

    # 2. quickreference/po/meson.build: Add new po file to qr_po_files.
    # FIXME: The actual po file should probably be generated first from the poit file

    # after that:
    qr_meson_path = root_dir + 'quickreference/po/meson.build'
    if not os.path.exists(qr_meson_path):
        print(f"File {qr_meson_path} does not exist!")
        sys.exit(1)

    if prev_code == "":
        # New first language in list!
        find_str    = f"qr_po_files = files(\n"
        replace_str = f"qr_po_files = files(\n    '{langcode}.po',\n"
    else:
        find_str    = f"'{prev_code}.po',\n"
        replace_str = f"'{prev_code}.po',\n    '{langcode}.po',\n"
    replace_in_file(qr_meson_path, find_str, replace_str)

    # 3. po-windows-installer/meson.build: Add new po file to qr_po_files.
    # FIXME: The actual po file should probably be generated first from the pot file

    # after that:
    wi_meson_path = root_dir + 'po-windows-installer/meson.build'
    if not os.path.exists(wi_meson_path):
        print(f"File {wi_meson_path} does not exist!")
        sys.exit(1)

    if prev_code == "":
        # New first language in list!
        find_str    = f"installer_po_files = files(\n"
        replace_str = f"installer_po_files = files(\n    '{langcode}.po',\n"
    else:
        find_str    = f"'{prev_code}.po',\n"
        replace_str = f"'{prev_code}.po',\n    '{langcode}.po',\n"
    replace_in_file(wi_meson_path, find_str, replace_str)


    # 4 languageVocab.xml

    add_line = f"  <item value=\"{langcode}\">{native} ({name_en})</item>'"
    file_to_update = root_dir + 'stylesheets/languageVocab.xml'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    # Matches the specific line up to its closing tag and captures the indentation
    if prev_code == "":
        pattern = rf'(\s*<vocab>)'
    else:
        pattern = rf'(\s*<item value="{re.escape(prev_code)}">.*?</item>)'

    re_replace_in_file(file_to_update, pattern, add_line)


    # 5. authors_common.xsl

    descriptive_lang = name_en.replace(" ", "_")
    add_line = f"      {langcode}:{descriptive_lang}"
    file_to_update = root_dir + 'stylesheets/authors_common.xsl'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    # Matches the specific line up to its closing tag and captures the indentation
    if prev_code == "":
        pattern = rf'(\s*<xsl:variable name="languages">)'
    else:
        pattern = rf'(\s*{re.escape(prev_code)}:\w+.*?)'

    re_replace_in_file(file_to_update, pattern, add_line)


    # 6 get_po_status.pl

    add_line = f"\t{langcode} => \"{name_en}\","
    file_to_update = root_dir + 'tools/get_po_status.pl'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    if prev_code == "":
        pattern = rf'(\s*my %Languages = \()'
    else:
        pattern = rf'(\s*{re.escape(prev_code)} =>.*?,)'

    re_replace_in_file(file_to_update, pattern, add_line)


    # 7 website.xml - part 1 manual

    file_to_update = root_dir + 'web/website.xml'
    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    add_line = f"""        <listitem>
          <para>
            <ulink url="&gimp.release.base;/{langcode}">{native} ({name_en})</ulink>
            - &gimphelp.langcode.{langcode};%
          </para>
        </listitem>"""

    target_var = f"&gimphelp.langcode.{prev_code};%"

    if prev_code == "":
        pattern = rf'(<term id="gimp-latest-online">Online User Manuals \(HTML\)</term>)'
    else:
        pattern = rf'(<listitem>.*?{re.escape(target_var)}?.*?</listitem>)'

    re_replace_in_file(file_to_update, pattern, add_line, flags=re.DOTALL)


    # 7 website.xml - part 2 quickreference pdf

    add_line = f"""        <listitem>
          <para>
            <ulink url="&gimp.release.base;/pdf/gimp-keys-{langcode}.pdf"
                   title="{native}">{native} ({name_en})</ulink>
            - &gimphelp.langcodeqr.{langcode};%
          </para>
        </listitem>"""
    target_var = f"&gimphelp.langcodeqr.{prev_code};%"

    if prev_code == "":
        pattern = rf'(<term>Quickreference \(PDF\)</term>)'
    else:
        pattern = rf'(<listitem>.*?{re.escape(target_var)}?.*?</listitem>)'

    re_replace_in_file(file_to_update, pattern, add_line, flags=re.DOTALL)



    # ALL_LINGUAS only needed for autotools. Can be removed after meson is declared stable.
    ALL_LINGUAS = ""
    en_code = "en"
    if en_code < langcode:
        target_code = en_code
        t2          = langcode 
    else:
        target_code = langcode
        t2          = en_code 
    t3 = ""

    for line in lines:
        if line.startswith("#") or line[0] == "":
            continue
        elif target_code == t3 or line < target_code:
            ALL_LINGUAS += line + ' '
        else:
            ALL_LINGUAS += target_code + ' ' + line + ' '
            if target_code == t2:
                target_code = t3
            else:
                target_code = t2
    if not target_code == t3:
        # Add new last code
        ALL_LINGUAS += target_code + ' '


    # 8 configure.ac

    search_target = "\tALL_LINGUAS=\""
    # remove last space
    NEW_ALL_LINGUAS = search_target + ALL_LINGUAS[:-1] + "\""

    file_to_update = root_dir + 'configure.ac'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)
    with open(file_to_update, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    updated_content = ""
    found = False
    for line in lines:
        if not found and line.startswith(search_target):
            updated_content += NEW_ALL_LINGUAS + "\n"
            found = True
        else:
            updated_content += line + "\n"
    if not found:
        updated_content += NEW_ALL_LINGUAS + "\n"

    with open(file_to_update, "w", encoding="utf-8", newline="\n") as f:
        f.write(updated_content)
        print(f"{file_to_update} has been updated.")

    # 9 Makefile.GNU

    search_target = "ALL_LINGUAS = "
    # remove last space
    NEW_ALL_LINGUAS = search_target + ALL_LINGUAS[:-1]

    file_to_update = root_dir + 'Makefile.GNU'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)
    with open(file_to_update, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    updated_content = ""
    found = False
    for line in lines:
        if not found and line.startswith(search_target):
            updated_content += NEW_ALL_LINGUAS + "\n"
            found = True
        else:
            updated_content += line + "\n"
    if not found:
        updated_content += NEW_ALL_LINGUAS + "\n"

    with open(file_to_update, "w", encoding="utf-8", newline="\n") as f:
        f.write(updated_content)
        print(f"{file_to_update} has been updated.")


    # 10+11 Windows installer uses different language names, for now MANUAL

    # 12 .gitlab-ci.yml - add MANUALLY due to split over several jobs

    # 13  po/langcode/ + subdirs - copy meson.build files
    # 14  add empty initialized po files


# FIXME: Test with NON-Western languages on command line!


if __name__ == "__main__":
    main(sys.argv[1:])
