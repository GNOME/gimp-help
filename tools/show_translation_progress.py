#!/usr/bin/env python3
# This file is part of the gimp-help project and is
# Copyright 2004, 2005, 2006, 2007 Roman Joost
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
import sys
import os
import os.path
import getopt
import re
import xml.etree.ElementTree as ET

ALL_LINGUAS = re.compile(r'ALL_LINGUAS="(\w.+)\w')


class GIMPHelpXMLParser(object):
    """Parses the XML sources..."""

    def __init__(self, filepath, xpathexpr=".//help-item[@id]"):
        self.ids = []
        assert filepath != ""
        self.filepath = filepath
        self.xpathexpr = xpathexpr

    def get_ids(self):
        """Returns a list of ids parsed from gimp-help.xml."""

        print("Parsing XML file: %s" % self.filepath)
        tree = ET.parse(self.filepath)

        # XXX the ids
        ids = tree.findall(self.xpathexpr)
        self.ids = [x.get('id') for x in ids ]

        return self.ids


class GIMPHelpHeaderParser(object):
    """Parses gimphelp-ids.h and indexes the ids"""

    helpid = re.compile('gimp-.[a-z-0-9]+')
    pluginid = re.compile('(plug-in|file|extension)-.[a-z-0-9]+')

    def __init__(self, filepath):
        assert filepath != ""
        self.filepath = filepath
        self.regex = self.helpid
        self.ids = []

    def set_filepath(self, filepath, regex):
        """Allows you to set a different file and regex for parsing ids"""
        self.filepath = filepath
        self.regex = regex

    def parse(self, be_verbose):
        h_file = open(self.filepath, "r")
        if be_verbose:
            print("Help ID's:")
        # XXX do a read() and match with a regexp
        for line in h_file.readlines():
            try:
                str = self.regex.search(line).group()
                if str in self.ids:
                    print(f"Duplicate help id found: {str}")
                else:
                    self.ids.append(str)
                if be_verbose:
                    print(str)
            except AttributeError:
                pass


class ExceptionListReader(object):
    """Reads a list of exceptions from a file"""

    def __init__(self, filepath):
        assert filepath != ""
        self.filepath = filepath
        self.exception_list = []

    def read_list(self, be_verbose=None):
        h_file = open(self.filepath, "r")
        if be_verbose:
            print("Exceptions:")

        for line in h_file.readlines():
            try:
                str = line.rstrip()
                if str in self.exception_list:
                    print(f"Duplicate exception entry found: '{str}'.")
                else:
                    self.exception_list.append(str)
                if be_verbose:
                    print(f"Ignoring: '{str}'.")
            except AttributeError:
                pass

        return self.exception_list


class Statistics(object):
    """Creates statistics output."""

    def __init__(self, headerpath, helproot, buildroot, plugin_ids_path, be_verbose, print_missing):
        self.helproot = helproot
        self.buildroot = buildroot
        self.plugin_ids_path = plugin_ids_path
        self.be_verbose = be_verbose
        self.hp = GIMPHelpHeaderParser(headerpath)
        self.hp.parse(be_verbose)
        if (self.plugin_ids_path is not None):
            self.hp.set_filepath(self.plugin_ids_path, self.hp.pluginid)
            self.hp.parse(be_verbose)

        ignorelist = os.path.join(helproot, 'tools', 'ignore-ids.txt')
        ignore_list = ExceptionListReader(ignorelist)
        self.ignore_ids = ignore_list.read_list()
        if self.ignore_ids:
            for id in self.ignore_ids:
                if not id in self.hp.ids:
                    print(f"Ignore id not found in list of known help ids: '{id}'.")
                else:
                    self.hp.ids.remove(id)
                    if be_verbose:
                        print(f"Ignoring id '{id}'")

        self.totals = len(self.hp.ids)
        self.docs = self.getDocuments(buildroot)
        self.statistics = self._generateStatistics(print_missing)

    def getDocuments(self, buildroot):
        """ returns a dictionary with languages as keys and paths to the
            xml documents as values
        """
        linguas = get_linguas(buildroot)
        result = {}
        for lang in linguas:
            # puzzling the path to the gimp-help.xml file together
            helpfile = os.path.join(buildroot, 'html', lang,
                                    'gimp-help.xml')
            if os.path.exists(helpfile):
                xp = GIMPHelpXMLParser(helpfile)
                result[lang] = xp.get_ids()

        return result

    def get_ids_from_lang(self, lang):
        """Iterator over ids of given language."""
        if lang not in list(self.docs.keys()):
            raise KeyError("%s not found in indexed documents." % lang)
        for id in self.docs[lang]:
            yield id

    def _generateStatistics(self, print_missing):
        """ generates statistics for every language
            returns list with dicts
                dicts = {written items, todo items, percentage written,
                language}
        """

        # FIXME - Parse GIMP's XML menus to see which menu help topics we should have.

        result = []
        helpids = self.hp.ids
        todo_ids = self.hp.ids

        for lang in list(self.docs.keys()):
            other_ids = []
            matched = []
            todo_ids = self.hp.ids.copy()

            if self.be_verbose:
                print(f"\nLanguage: {lang}")

            for id in self.get_ids_from_lang(lang):
                if id in helpids:
                    matched.append(id)
                    todo_ids.remove(id)
                    if self.be_verbose:
                        print(f"help-id found: {id}")
                else:
                    other_ids.append(id)
                    if self.be_verbose:
                        print(f"not in help-ids: {id}")

            done = len(matched)
            add = len(other_ids)
            total_done = done + add
            todo = len(todo_ids)
            print(f"\nLanguage: {lang}. Total help-ids: {self.totals}, of which {done} done and {todo} missing.")
            print(f"There are: {done} other help pages for a total of {total_done} pages.")

            if done < self.totals:
                prc_done = done*100/self.totals
            else:
                todo = 0
                prc_done = 100

            if len(todo_ids) > 0:
                if print_missing:
                    print("\nMissing help for ids")
                    print(  "--------------------")
                    for id in todo_ids:
                        print(id)
                else:
                    print("\nTo show the missing help-ids enable option -m")

            lang = self._makedict(done=done,
                                 todo=todo,
                                 others=add,
                                 prc_done=prc_done,
                                 lang=lang)
            result.append(lang)

        return result

    def getInvalidIds(self):
        """ parses one gimp-help.xml file and compare the id's found
            with help ids. If the id from the xml file is not in help
            ids, append it to invalid.
            returns list with invalid ids (str)
        """
        if not self.docs:
            raise ValueError("Can't parse a gimp-help.xml for any"
                             " Language. Maybe you need to build the HTML"
                             " docs? Check if gimp-help.xml files exist.")

        for lang in list(self.docs.keys()):
            invalid = []
            # List of ids to skip. Some of them should probably be removed here
            # but at the moment that would lead to a long list of invalid ids.
            # We should revisit this some time in the future.
            skip = [
                'authors', 'become-a-gimp-wizard', 'bibliography',
                'clipboard', 'crop-', 'file-', 'filters', 'getting-started',
                'gfdl', 'gimp-brush', 'gimp-buffer', 'gimp-channel',
                'gimp-colors-', 'gimp-colorselector', 'gimp-concepts',
                'gimp-dock', 'gimp-edit', 'gimp-file', 'gimp-filter',
                'gimp-font', 'gimp-gradient', 'gimp-help', 'gimp-image',
                'gimp-indexed', 'gimp-introduction', 'gimp-layer',
                'gimp-palette', 'gimp-path', 'gimp-pattern', 'gimp-prefs',
                'gimp-selection', 'gimp-tool', 'gimp-using', 'gimp-tutorial',
                'gimp-view', 'gimp-windows', 'gimpressionist',
                'introduction', 'key-reference', 'legal',
                'plug-in', 'python-fu', 'script-fu',
                'preface', 'tone-mapping', 'text-', 'tool-',
                'dialogs', 'menus',
                'gimp-', '-dialog'
            ]

            for id in self.get_ids_from_lang(lang):
                not_invalid = None
                if id in skip:
                    continue

                not_invalid = list(filter(lambda k, y=0:\
                    y + self._is_substring(id, k), skip))

                if not_invalid:
                    continue

                if not self._is_helpid(id):
                    invalid.append(id)

            invalid.sort()
        return invalid


    def getInvalidFilenames(self):
        """ indexes all filenames and compare it with the help ids
            if filename is not in help ids append it to invalid list
            returns list with invalid filenames(str)
        """
        names = {}
        root = os.path.join(self.helproot, "src")
        # dirs which we can safely skip
        filter_directories = [
            'appendix', 'concepts', 'filters', 'glossary', 'images', 'introduction',
            'preface', 'tutorial', 'using',
            ]

        # filenames which we can safely skip
        filter_files = [
            'about-', 'gimp', 'help-missing', 'introduction', 'key-reference',
            ]

        ignore_dirs = []

        if self.be_verbose:
            print(f"\nHelp src root: {root}")
        for root, dirs, files in os.walk(root):
            skip = False
            for item in ignore_dirs:
                if root.startswith(item):
                    skip = True
                    break

            if not skip:
                if self.be_verbose and len(dirs) > 0:
                    print(f"Root: {root} - Dirs: {dirs}")
                for dir in dirs:
                    if dir in filter_directories:
                        if self.be_verbose:
                            print(f"Removing dir: {dir}")
                        ignore_dirs.append(os.path.join(root, dir))
                    elif self.be_verbose:
                        print(f"Keeping dir: {dir}")

                for file in files:
                    if file.endswith('xml'):
                        id = file[:-4]
                        names[id] = os.path.join(root, file)

        # remove the valid entries
        for id in list(names.keys()):
            not_invalid = 0

            not_invalid = list(filter(lambda k, y=0:\
                y + self._is_substring(id, k), filter_files))
            if not_invalid:
                if self.be_verbose:
                    print(f"Remove valid name: {names[id]}")
                del names[id]

        return names

    def printHTMLStatistics(self):
        """ returns HTML Code with statistics """
        raise NotImplementedError

    def printTextStatistics(self, print_invalid=0):
        """ prints Text Statistics """
        invalid_ids = self.getInvalidIds()
        invalid_files = self.getInvalidFilenames()

        print("\nGeneral statistics:")
        print("===================")

        for dict in self.statistics:
            done = '#'*int(dict['prc_done']/10)
            todo = ' '*(10-int(dict['prc_done']/10))
            print("\nLanguage: %s" %dict['lang'])
            print("Found titles for: %i ids - Todo: %s ids - other ids: %s"\
                %(dict['done'], dict['todo'], dict['others']))
            print("Percent done: |%s%s| %s%%" %(done,todo, dict['prc_done']))

        print("\n\nFound %i ids which are not part of gimphelp-ids.h and also not in our skip list." %len(invalid_ids))
        print("Maybe their naming could be improved or else they should be added to the skip list.")
        print("\nInvalid ids:")
        print("================")

        if print_invalid:
            invalid_ids.sort()
            for id in invalid_ids:
                print("%s" %id)
        else:
            print("Hint: start the program again with parameter >>-i<<", end=' ')
            print("if you want to view them.")

        print("\n\nFound %i filenames which are not part of gimphelp-ids.h" %len(invalid_files))
        print("We should check if their filenames can be synchronized with their ids.")
        print("\nInvalid filenames:")
        print("======================")

        if print_invalid:
            keys = list(invalid_files.keys())
            #keys.sort()
            for k in keys:
                print("%s -> %s" %(k, invalid_files[k]))
        else:
            print("Hint: start the program again with parameter >>-i<<", end=' ')
            print("if you want to view them.")

    def _makedict(self, **kwargs):
        return kwargs

    def _is_substring(self, str, substr):
        """ returns True if str is substr from str """
        return str.find(substr) >= 0

    def _is_helpid(self, name):
        """ returns True if the file is in helpids otherwise 0 """
        return name is not None and name in self.hp.ids


def get_linguas(gimpbuildpath):
    """ returns the linguas set in configure.in in gimp-help dir """
    gimphtmlpath = os.path.join(gimpbuildpath, "html")
    if not os.path.exists(gimphtmlpath):
        print(f"WARNING: html directory {gimphtmlpath} not found!")
        gimpbuildpath = None
        return []

    if 'ALL_LINGUAS' in os.environ:
        linguas = os.environ.get('ALL_LINGUAS')
        linguas = linguas.split(' ')
        return linguas

    linguas = os.listdir(gimphtmlpath)
    if 'images' in linguas:
        linguas.remove('images')
    print(f"Linguas: {linguas}")

    return linguas


def main():
    gimp = None
    helppath = "."
    buildpath = '.'
    plugin_ids_path = None
    print_invalid = 0
    print_missing = 0
    gimpheaderfile = "gimphelp-ids.h"
    errormsg = None
    show_usage = False
    be_verbose = False

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hb:x:g:p:imv")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    if not opts:
        show_usage = True

    for o, a in opts:
        if o == "-h":
            show_usage = True
        if o == "-x":
            helppath = a
        if o == "-b":
            buildpath = a
        if o == "-p":
            plugin_ids_path = a
        if o == "-g":
            gimp = os.path.join(a, "app", "widgets", gimpheaderfile)
        if o == "-i":
            print_invalid = 1
        if o == "-m":
            print_missing = 1
        if o == "-v":
            be_verbose = True

    if show_usage:
        usage()
        sys.exit(1)

    if gimp:
        gimp = os.path.abspath(gimp)
        print(f"Path to GIMP help ids   : {gimp}")
        if not os.path.exists(gimp):
            errormsg = "Path to GIMP is invalid"
    else:
        errormsg = "Path to GIMP not set (commandline option -g)"

    if not errormsg:
        helppath = os.path.abspath(helppath)
        if not os.path.exists(helppath):
            errormsg = "Path to gimp-help is invalid"

    if not errormsg:
        buildpath = os.path.abspath(buildpath)
        if not os.path.exists(buildpath):
            errormsg = "Path to gimp-help build root is invalid"

    if not errormsg:
        st = Statistics(gimp, helppath, buildpath, plugin_ids_path, be_verbose, print_missing)
        st.printTextStatistics(print_invalid)
        sys.exit(1)
    else:
        usage(errormsg)
        sys.exit(0)


def usage(errormsg=None):

    print("""show_translation_progress.py - Copyright 2004 Roman Joost (gimp-help)
Generates some statistical information about the documentation process.

usage: show_translation_progress.py [options]

    options:
        -g      path to the GIMP sources (eg. /opt/gimp)
        -x      path to the gimp-help sources (eg. /opt/gimp-help)
        -b      path to the gimp-help build root (eg. /opt/gimp-help/build)
        -p      path to the file with plug-in help-ids (generated using collect_plugin_ids.sh)
        -i      print ids which are invalid or have inconsistencies
        -m      print help-ids that are missing from gimp-help
        -v      be more verbose
        -h      this help""")
    if errormsg and errormsg != "":
        print("\nError: %s" % errormsg)

if __name__ == "__main__":
    main()
