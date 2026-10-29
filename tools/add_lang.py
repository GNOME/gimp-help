#!/usr/bin/env python3
# -*- encoding: utf-8 -*-
#
# add_lang.py - Automate adding a new language for translation
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
import shutil
from pathlib import Path

VERBOSE = False
VERSION = 0.1


# Note that this script is for the most part quite dumb:
# it only checks for duplicate langcode-s in LINGUAS.
# For all other files it presumes it is not present without checking.

# Note 2: This script needs to be run twice. After the first run
#         meson needs to be called to update some of the po files.
#         When meson is finished, call this script again to update
#         the last meson.build files and copy po files.

def printVersion():
    print(f"\nadd_lang.py v {VERSION}")

def usage():
    printVersion()
    print("""Adds a new language for translation.

usage: add_lang.py [options] langcode English Native build_dir

    For iso codes and localized names see also
    https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes

    langcode                    The code for this language
    English                     The US English name of this language
    Native                      The localized name of this language
    build_dir                   The build directory path (needed for
                                second run, ignored in first run)

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

def copy_po_file (build_dir_path, src_dir_path, copy_pattern):
    from_path = build_dir_path + '/' + copy_pattern
    to_path   = src_dir_path   + '/' + copy_pattern
    if not os.path.exists(src_dir_path):
        print(f"Path {src_dir_path} does not exist!")
        sys.exit(1)
    elif not os.path.exists(from_path):
        print(f"File {from_path} does not exist!")
        sys.exit(1)
    elif os.path.exists(to_path):
        print(f"File {to_path} already exists!")
        sys.exit(1)

    shutil.copy(from_path, to_path)

    print(f"{from_path} has been copied to {to_path}.")

def main(argv):
    # default assume current directory is root_dir
    root_dir  = '.'
    global VERBOSE

    default_lang = 'en'
    langcode     = 'en'
    first_run    = True
    build_dir    = None

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

    arg_len = len(remaining_args)
    if remaining_args is None or arg_len < 3 or arg_len > 4:
        usage()
        sys.exit(1)
    else:
        langcode = remaining_args[0]
        name_en  = remaining_args[1]
        native   = remaining_args[2]
        if arg_len == 4:
            build_dir = remaining_args[3]

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
        print(f"Language code '{langcode}' found: assuming second run.")
        first_run = False
        if build_dir is None:
            print(f"ERROR: Missing 'build_dir' parameter. Second run aborted!")
            sys.exit(1)
        elif not build_dir.endswith('/'):
            build_dir += '/'

    found       = False
    new_LINGUAS = ""
    prev_code   = ""
    for line in lines:
        if line.startswith("#") or line[0] == "":
            new_LINGUAS += line + "\n"
        elif line < langcode or found:
            new_LINGUAS += line + "\n"
            if not found:
                prev_code = line
        elif not found:
            if first_run:
                new_LINGUAS += langcode + "\n" + line + "\n"
            else:
                new_LINGUAS += line + "\n"
            found = True
        else:
            raise RuntimeError("LINGUAS line not copied!")
    
    if not found:
        # add as new last code
        new_LINGUAS += langcode + "\n"

    if first_run:
        with open(LINGUAS_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(new_LINGUAS)
            print(f"{LINGUAS_path} has been updated.")

    # Because "en" is not in LINGUAS we need an additional prev_code
    # for certain languages (e.g.en_CA) or sorting will be incorrect
    # But only use that where "en" is expected to be included,
    # thus not in po files or get_po_status.
    if langcode.startswith(default_lang) and prev_code < default_lang:
        prev_code_with_en = default_lang
    else:
        prev_code_with_en = prev_code

    if not first_run:
        # 2. quickreference/po/meson.build: Add new po file to qr_po_files.

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

        # Now add po files by copying them from the build dir
        po_pattern = f"{langcode}.po"
        po_path    = 'po-windows-installer'
        from_path  = build_dir + po_path
        to_path    = root_dir  + po_path
        copy_po_file(from_path, to_path, po_pattern)
        po_path    = 'quickreference/po'
        from_path  = build_dir + po_path
        to_path    = root_dir  + po_path
        copy_po_file(from_path, to_path, po_pattern)

        po_path    = 'po'
        from_path  = build_dir + po_path + '/' + langcode
        to_path    = root_dir  + po_path + '/' + langcode
        shutil.copytree(from_path, to_path, dirs_exist_ok=True, ignore=shutil.ignore_patterns("*.mo", ".po~"))

        print(f"Po files have been copied from {from_path} to {to_path}.")

        print(f"Now check all changes and commit, then make an MR.")
        exit(0)


    # 4 languageVocab.xml

    add_line = f"  <item value=\"{langcode}\">{native} ({name_en})</item>'"
    file_to_update = root_dir + 'stylesheets/languageVocab.xml'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    if prev_code_with_en == "":
        pattern = rf'(\s*<vocab>)'
    else:
        pattern = rf'(\s*<item value="{re.escape(prev_code_with_en)}">.*?</item>)'

    re_replace_in_file(file_to_update, pattern, add_line)


    # 5. authors_common.xsl

    descriptive_lang = name_en.replace(" ", "_")
    add_line = f"      {langcode}:{descriptive_lang}"
    file_to_update = root_dir + 'stylesheets/authors_common.xsl'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    if prev_code_with_en == "":
        pattern = rf'(\s*<xsl:variable name="languages">)'
    else:
        pattern = rf'(\s*{re.escape(prev_code_with_en)}:\w+.*?)'

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

    # Due to "en" not having "- &gimphelp.langcode.en;%" in website.xml we will have
    # to manually adjust the added langcode to go directly after en.
    if not prev_code_with_en == prev_code:
        print(f"WARNING: Manual fixing needed to sort {langcode} directly after 'en' in web/website.xml!")

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

    # Parse lines in LINGUAS (does not include en)
    for line in lines:
        if line.startswith("#") or line[0] == "":
            continue
        elif target_code == t3 or line < target_code:
            ALL_LINGUAS += line + ' '
        elif target_code != t2 and line > t2:
            # After'en' but before 'en_GB' e.g. 'en_CA'
            ALL_LINGUAS += t2 + ' ' + line + ' '
            target_code = t3
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


    # 10+11 Windows installer uses different language names
    # We added all currently known InnoSetup languages.
    # We check here if our language is listed:
    file_to_check = root_dir + 'build/windows/installer/languages.isi'
    with open(file_to_check, "r", encoding="utf-8") as f:
        contents = f.read()
        if contents.find(f"LANG=='{langcode}'", None, None) < 0:
            print("WARNING: No translation available for InnoSetup. Add manually!")

    # 12 .gitlab-ci.yml
    # We add it as first in the last language job for both meson and make
    file_to_update = root_dir + '.gitlab-ci.yml'

    if not os.path.exists(file_to_update):
        print(f"File {file_to_update} does not exist!")
        sys.exit(1)

    find_str    = 'MESON_LANGS_5: "'
    replace_str = 'MESON_LANGS_5: "' + f"{langcode} "
    replace_in_file(file_to_update, find_str, replace_str)

    find_str    = 'MAKE_LANGS_6: "'
    replace_str = 'MAKE_LANGS_6: "' + f"{langcode} "
    replace_in_file(file_to_update, find_str, replace_str)

    po_subdirs = [
        '',
        'menus/',
        'menus/colors/',
        'filters/',
        'toolbox/',
    ]
    meson = 'meson.build'

    po_path = root_dir + 'po/' + langcode
    if os.path.exists(po_path):
        print(f"Po folder already exists. Assuming meson.build files are already initialized!")
        sys.exit(1)


    # Create required folders
    os.makedirs(po_path + '/menus/colors', exist_ok=True)
    os.makedirs(po_path + '/filters', exist_ok=True)
    os.makedirs(po_path + '/toolbox', exist_ok=True)
    print(f"Folder {po_path} and subdirs created.")

    # Copy meson.build files from a known to exist language
    copy_from_path = root_dir + 'po/nl'
    if not os.path.exists(copy_from_path):
        print(f"Missing path {copy_from_path}. Can't copy meson.build files!")
        sys.exit(1)

    po_path +=  '/'
    copy_from_path += '/'
    for subdir in po_subdirs:
        shutil.copy(copy_from_path + subdir + meson, po_path + subdir + meson)
    print(f"Copied meson.build files.")

    print(f"\nNow meson needs to be called to update po files for quickreference and the windows installer.")
    print(f"Run from your build dir:\n\t'meson setup -Dprefix=$YOUR_PREFIX $YOUR_SRCDIR -Dlanguages={langcode} -Dquickreference=true -Dwindows-installer=true -Dmaintainer=false -Dlanguage-menu=false && ninja'")
    print(f"After that run add_lang.py again and it will finish the addition of {langcode}.")


if __name__ == "__main__":
    main(sys.argv[1:])
