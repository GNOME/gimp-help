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
    def __init__(self, pofile):
        self.pofile = pofile
        self.percentage = 0
        #self.out = sys.stdout # todo: write to file maybe...
        self.out = sys.stderr
        self.translated   = 0
        self.fuzzy        = 0
        self.untranslated = 0
        self.total        = 0

    def run(self):
        #self.out.seek(0)
        cmd = subprocess.Popen(["msgfmt", "--statistics", self.pofile],
                               stdin=self.out, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        cmdout, cmderr = cmd.communicate()
        if cmd.returncode:
             raise Exception("Error during msgfmt command.")

        match_pattern = "(\d+)\stranslated\D+(?:(\d+)\sfuzzy\D+)?(?:(\d+)\suntranslated\D+)?"
        rex = re.compile(match_pattern)
        m = rex.match(cmderr.decode())
        if m.group(1) != None:
            self.translated = int(m.group(1))
        if m.group(2) != None:
            self.fuzzy = int(m.group(2))
        if m.group(3) != None:
            self.untranslated = int(m.group(3))
        self.total = self.translated + self.fuzzy + self.untranslated


class GetFolderStats(object):
    def __init__(self, basefolder, langdir):
        self.base_folder = basefolder
        self.lang_dir = langdir
        self.total_files = 0
        self.total_messages = 0
        self.translated_messages = 0

    def run(self, verbose):
        root_folder = os.path.join(self.base_folder, self.lang_dir)
        for root, dirs, files in os.walk(root_folder):
            for file in files:
                filepath = os.path.join(root, file)
                gs = GetStats(filepath)
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

        # add entities
        for stats in self.collected_stats.languages:
            langcode = stats.lang_dir
            percent  = 0
            if stats.total_messages > 0:
                percent = stats.translated_messages / stats.total_messages * 100
            pct_round = round(percent)

            # Don't show it as 100% done until all messages are translated.
            if pct_round == 100 and stats.translated_messages < stats.total_messages:
                pct_round = 99

            entity = f"<!ENTITY gimphelp.langcode.{langcode} '{pct_round}' >\n"
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
    # By default we expect to be started from /web/
    po_dir    = "../po"
    outfile   = "../web/langstats.xml"

    try:
        opts, remaining_args = getopt.getopt(argv, "hvo:p:",
            [
                "help", "verbose"
            ])
    except getopt.GetoptError as err:
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


    if verbose:
        printVersion()

    if lang_dirs:
        path = po_dir
        list_langdirs = [f.name for f in os.scandir(path) if f.is_dir()]
        languages = CollectStats()
        for dir in list_langdirs:
            gfs = GetFolderStats(path, dir)
            gfs.run(verbose)
            languages.addStats(gfs)
        writer = WriteStats(outfile, languages)
        writer.run(verbose)

        messages = "./messages.mo"
        if os.path.isfile(messages):
            os.remove(messages)

    else:
        # todo!
        pass

    # if errors > 0:
    #     print(f"Total number of errors: {errors}")
    #     sys.exit(1)


def usage():
    printVersion()
    print("""Generates info about what percentage of each available language has been translated, for use on the website.

usage: translated_percentage.py [options]

    options:
        -o      --output        default: ../web/langstats.xml
        -p      --podir         default: ../po
        -v      --verbose       be more verbose
        -h      --help          this help""")


if __name__ == "__main__":
    main(sys.argv[1:])