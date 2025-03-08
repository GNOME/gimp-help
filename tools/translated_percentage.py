#!/usr/bin/env python3
#
# translated_percentage.py
#     Generates info about what percentage of each available language
#     has been translated, for use on the website.
#
# Copyright (c) 2022 Jacob Boerema.
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
# Requirements:
# -

import os
import sys
import subprocess
import getopt
import re

VERSION = 0.1

class GetStats(object):
    def __init__(self, pofile, outfile):
        self.pofile       = pofile
        self.outfile      = outfile
        self.out          = sys.stderr
        self.percentage   = 0
        self.translated   = 0
        self.fuzzy        = 0
        self.untranslated = 0
        self.total        = 0

    def run(self):
        # -o output is very picky on Windows
        out_param = f"-o{self.outfile}"
        # On Windows msgfmt from MINGW64 often seems to crash.
        # You may have to use the one from MSYS and adjust the path accordingly.
        cmd = subprocess.Popen(["msgfmt", "--statistics", out_param, self.pofile],
                               stdin=self.out, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        _cmdout, cmderr = cmd.communicate()
        if cmd.returncode:
            raise Exception("Error during msgfmt command: " + cmderr.decode())

        match_pattern = r"(\d+)\stranslated\D+(?:(\d+)\sfuzzy\D+)?(?:(\d+)\suntranslated\D+)?"
        rex = re.compile(match_pattern)
        m = rex.match(cmderr.decode())
        if m.group(1) is not None:
            self.translated = int(m.group(1))
        if m.group(2) is not None:
            self.fuzzy = int(m.group(2))
        if m.group(3) is not None:
            self.untranslated = int(m.group(3))
        self.total = self.translated + self.fuzzy + self.untranslated


class GetFolderStats(object):
    def __init__(self, basefolder, langdir):
        self.base_folder = basefolder
        self.lang_dir = langdir
        self.total_files = 0
        self.total_messages = 0
        self.translated_messages = 0

    def run(self, verbose, mofile):
        root_folder = os.path.join(self.base_folder, self.lang_dir)
        for root, _dirs, files in os.walk(root_folder):
            for file in files:
                filepath = os.path.join(root, file)
                gs = GetStats(filepath, mofile)
                gs.run()
                self.total_files += 1
                self.total_messages += gs.total
                self.translated_messages += gs.translated

        if verbose:
            pct = 0
            if self.total_messages > 0:
                pct = self.translated_messages / self.total_messages * 100
            pct_round = round(pct,1)
            if pct_round == 100 and self.translated_messages < self.total_messages:
                pct_round = 99
            print(f"{self.lang_dir} - Total files: {self.total_files}, messages: {self.total_messages}, {pct_round}% done")

class GetQRStats(object):
    def __init__(self, basefolder, lang):
        self.base_folder = basefolder
        self.lang = lang
        self.total_files = 0
        self.total_messages = 0
        self.translated_messages = 0

    def run(self, verbose, mofile):
        pofile = self.lang + '.po'
        filepath = os.path.join(self.base_folder, pofile)
        gs = GetStats(filepath, mofile)
        gs.run()
        self.total_files += 1
        self.total_messages += gs.total
        self.translated_messages += gs.translated

        if verbose:
            pct = 0
            if self.total_messages > 0:
                pct = self.translated_messages / self.total_messages * 100
            pct_round = round(pct,1)
            if pct_round == 100 and self.translated_messages < self.total_messages:
                pct_round = 99
            print(f"{self.lang} - Messages: {self.total_messages}, {pct_round}% done")

class CollectStats(object):
    def __init__(self):
        self.languages = []

    def addStats(self, folderstats):
        self.languages.append(folderstats)

class WriteStats(object):
    def __init__(self, filepath, collected_stats):
        self.file_path = filepath
        self.collected_stats = collected_stats

    def run(self, verbose):
        if verbose:
            print(f"Writing {self.file_path}...")
        f = open(self.file_path, 'wt')

        # add xml header
        f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n")

        basecode = "invalid"
        langcode = "invalid"

        # add entities
        for stats in self.collected_stats.languages:
            if isinstance(stats, GetFolderStats):
                langcode = stats.lang_dir
                basecode = "langcode"
            elif isinstance(stats, GetQRStats):
                langcode = stats.lang
                basecode = "langcodeqr"

            percent  = 0
            if stats.total_messages > 0:
                percent = stats.translated_messages / stats.total_messages * 100
            pct_round = round(percent)

            # Don't show it as 100% done until all messages are translated.
            if pct_round == 100 and stats.translated_messages < stats.total_messages:
                pct_round = 99

            entity = f"<!ENTITY gimphelp.{basecode}.{langcode} '{pct_round}' >\n"
            f.write(entity)

        # close file
        f.close()


def printVersion():
    print(f"\ntranslated_percentage.py v {VERSION}, copyright 2022 Jacob Boerema")

def main(argv):
    # Make sure stdout and stderr output utf-8 even on Windows where it's not the default
    sys.stdout = open(sys.stdout.fileno(), 'w', encoding='utf-8', closefd=False)
    sys.stderr = open(sys.stderr.fileno(), 'w', encoding='utf-8', closefd=False)

    verbose = False
    # One language per (sub) folder, or all languages in this folder
    lang_dirs = True
    quick_ref = False
    # By default we expect to be started from /web/
    po_dir    = "../po"
    outfile   = "../web/langstats.xml"

    try:
        opts, _remaining_args = getopt.getopt(argv, "hvqo:p:",
            [
                "help", "verbose", "podir", "output", "quickreference"
            ])
    except getopt.GetoptError:
        usage()
        sys.exit(0)

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
            sys.exit(0)
        elif opt == "-v" or opt == "--verbose":
            verbose = True
        elif opt in ('-p', '--podir'):
            po_dir = arg
        elif opt in ('-o', '--output'):
            outfile = arg
        elif opt in ('-q', '--quickreference'):
            lang_dirs = False
            quick_ref = True


    if verbose:
        printVersion()

    path = po_dir
    messages = "./output.mo"
    languages = CollectStats()

    if lang_dirs:
        messages = "./pomessages.mo"
        list_langdirs = [f.name for f in os.scandir(path) if f.is_dir()]
        for mydir in list_langdirs:
            gfs = GetFolderStats(path, mydir)
            gfs.run(verbose, messages)
            languages.addStats(gfs)

    else:
        if quick_ref:
            messages = "./qrmessages.mo"
            # Handle quickreference po files that are in one folder and
            # have the language code attached to the po filename
            list_pofiles = [f.name for f in os.scandir(path) if f.is_file() and f.name.endswith('.po')]
            languages = CollectStats()
            for po in list_pofiles:
                langcode = po[:-3]
                gfs = GetQRStats(path, langcode)
                gfs.run(verbose, messages)
                languages.addStats(gfs)

        else:
            # In the future maybe also handle translations for our web pages?
            pass

    writer = WriteStats(outfile, languages)
    writer.run(verbose)

    if os.path.isfile(messages):
        os.remove(messages)

    # if errors > 0:
    #     print(f"Total number of errors: {errors}")
    #     sys.exit(1)


def usage():
    printVersion()
    print("""Generates info about what percentage of each available language has been translated, for use on the website.

usage: translated_percentage.py [options]

    options:
        -o      --output          default: ../web/langstats.xml
        -p      --podir           default: ../po
        -q      --quickreference  handle quickreference po files
        -v      --verbose         be more verbose
        -h      --help            this help""")


if __name__ == "__main__":
    main(sys.argv[1:])