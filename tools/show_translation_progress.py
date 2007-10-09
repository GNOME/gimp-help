#!/usr/bin/env python
# This file is part of the gimp-help-2 project and is
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
import xml.xpath
import xml.dom.minidom

ALL_LINGUAS = re.compile('ALL_LINGUAS="(\w.+)\w')


class GIMPHelpXMLParser(object):
    """Parses the XML sources..."""

    def __init__(self, filepath, xpathexpr="//help-item[@id]"):
        self.ids = []
        assert filepath != ""
        self.filepath = filepath
        self.xpathexpr = xpathexpr

    def get_ids(self):
        """Returns a list of ids parsed from gimp-help.xml."""
        fh = open(self.filepath, 'r')
        dom = xml.dom.minidom.parse(fh)
        print "Parsing XML file: %s" % os.path.basename(os.path.dirname(self.filepath))
        # XXX the ids
        ids = xml.xpath.Evaluate(self.xpathexpr, dom)
        self.ids = [x.getAttribute('id') for x in ids ]
        return self.ids


class GIMPHelpHeaderParser(object):
    """Parses gimphelp-ids.h and indexes the ids"""

    helpid = re.compile('gimp-.[a-z-]+')

    def __init__(self, filepath):
        assert filepath != ""
        self.filepath = filepath
        self.ids = []

    def parse(self):
        h_file = open(self.filepath, "r")
        # XXX do a read() and match with a regexp
        for line in h_file.readlines():
            try:
                str = self.helpid.search(line).group()
                self.ids.append(str)
            except AttributeError:
                pass


class Statistics(object):
    """Creates statistics output."""
    
    def __init__(self, headerpath, helproot):
        self.helproot = helproot
        self.hp = GIMPHelpHeaderParser(headerpath)
        self.hp.parse()
        self.totals = len(self.hp.ids)
        self.docs = self.getDocuments(helproot)
        self.statistics = self._generateStatistics()

    def getDocuments(self, helproot):
        """ returns a dictionary with languages as keys and paths to the
            xml documents as values 
        """
        linguas = get_linguas(helproot) 
        result = {}
        for lang in linguas:
            # puzzling the path to the gimp-help.xml file together
            helpfile = os.path.join(helproot, 'html', lang,
                                    'gimp-help.xml')
            if os.path.exists(helpfile):
                xp = GIMPHelpXMLParser(helpfile)
                result[lang] = xp.get_ids()

        return result

    def get_ids_from_lang(self, lang):
        """Iterator over ids of given language."""
        if lang not in self.docs.keys():
            raise KeyError("%s not found in indexed documents." % lang)
        for id in self.docs[lang]:
            yield id

    def _generateStatistics(self):
        """ generates statistics for every language
            returns list with dicts
                dicts = {written items, todo items, percentage written,
                language}
        """
        result = []
        helpids = self.hp.ids

        for lang in self.docs.keys():
            other_ids = []
            matched = []

            for id in self.get_ids_from_lang(lang):
                if id not in helpids:
                    matched.append(id)
                else:
                    other_ids.append(id)

            done = len(matched)
            add = len(other_ids)
            if done < self.totals:
                todo = self.totals - done
                prc_done = done*100/self.totals
            else:
                todo = 0
                prc_done = 100

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

        for lang in self.docs.keys():
            invalid = []
            skip = ['faq', 'using', 'fdl', 'glossary',
                'introduction', 'gimp-main', 'legal', 'tools-color',
                'tools-paint', 'tools-selection', 'tools-transform',
                'tools-menu', 'plug-in']

            for id in self.get_ids_from_lang(lang):
                not_invalid = None
                if id in skip:
                    continue

                not_invalid = filter(lambda k, y=0:\
                    y + self._is_substring(id, k), skip)

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
        # XXX needs to be rewritten
        invalid = []
        names = {}
        root = os.path.join(self.helproot, "src")
        # dirs which we can savely skip
        filter_directories = ['glossary', 'faq', 'filters']

        # filenames which we can savely skip
        filter_files = ['gimp', 'introduction', 'menu']

        for root, dirs, files in os.walk(root):
            if 'CVS' in dirs:
                dirs.remove('CVS') # don't visit CVS dirs

            for dir in dirs:
                if dir in filter_directories:
                    dirs.remove(dir)

            for file in files:
                if file.endswith('xml'):
                    id = file[:-4]
                    names[id] = os.path.join(root, file)

        # remove the valid entries
        for id in names.keys():
            not_invalid = 0

            not_invalid = filter(lambda k, y=0:\
                y + self._is_substring(id, k), filter_files)
            if not_invalid:
                continue

            if self._is_helpid('gimp-' + id):
                del names[id]

        return names

    def printHTMLStatistics(self):
        """ returns HTML Code with statistics """
        raise NotImplementedError 

    def printTextStatistics(self, print_invalid=0):
        """ prints Text Statistics """
        invalid_ids = self.getInvalidIds()
        invalid_files = self.getInvalidFilenames()

        print "General statistics:"
        print "==================="

        for dict in self.statistics:
            done = '#'*int(dict['prc_done']/10)
            todo = ' '*(10-(dict['prc_done']/10))
            print "\nLanguage: %s" %dict['lang']
            print "Found titles for: %i ids - Todo: %s ids - other ids: %s"\
                %(dict['done'], dict['todo'], dict['others'])
            print "Percent done: |%s%s| %s%%" %(done,todo, dict['prc_done'])

        print "\n\nInvalid ids:"
        print "================"
        print "Found %i ids which are not part of gimphelp-ids.h" %len(invalid_ids)

        if print_invalid:
            invalid_ids.reverse()
            for id in invalid_ids:
                print "%s" %id
        else:
            print "Hint: start the program again with parameter >>-i<<",
            print "if you want to view them."

        print "\n\nInvalid filenames:"
        print "======================"
        print "Found %i filenames which are not part of gimphelp-ids.h" %len(invalid_files)

        if print_invalid:
            keys = invalid_files.keys()
            keys.sort()
            for k in keys:
                print "%s -> %s" %(k, invalid_files[k])
        else:
            print "Hint: start the program again with parameter >>-i<<",
            print "if you want to view them."

    def _makedict(self, **kwargs):
        return kwargs

    def _is_substring(self, str, substr):
        """ returns True if str is substr from str """
        return str.find(substr) >= 0

    def _is_helpid(self, name):
        """ returns True if the file is in helpids otherwise 0 """
        return name is not None and name in self.hp.ids


def get_linguas(gimphelppath):
    """ returns the linguas set in configure.in in gimp-help-2 dir """
    gimphelppath = os.path.join(gimphelppath, "html")
    if os.environ.has_key('ALL_LINGUAS'):
        linguas = os.environ.get('ALL_LINGUAS')
        linguas = linguas.split(' ')
        return linguas 

    linguas = os.listdir(gimphelppath)
    linguas.remove('images')
    return linguas


def main():
    header = None
    xml = None
    helppath = "."
    print_invalid = 0
    gimpheaderfile = "gimphelp-ids.h"
    xmldocs = {}

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hx:g:i")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    if not opts:
        errormsg = "Please set the path to gimp-help-2 and gimp installation."
        usage(errormsg)
        sys.exit(1)

    for o, a in opts:
        if o == "-h":
            usage()
        if o == "-x":
            helppath = a
        if o == "-g":
            gimp = os.path.join(a, "app", "widgets", gimpheaderfile)
        if o == "-i":
            print_invalid = 1

    gimp = os.path.abspath(gimp)
    helppath = os.path.abspath(helppath)
    if os.path.exists(gimp) and os.path.exists(helppath):
        st = Statistics(gimp, helppath)
        st.printTextStatistics(print_invalid)
        sys.exit(1)
    else:
        usage()
        print "Error: one of your path is invalid!"
        sys.exit(0)


def usage(errormsg=None):
    
    print """idlookup.py - Copyright 2004 Roman Joost (gimp-help-2)
generates some statistical information about the documentation process 

usage: idlookup.py [options]

    options:
        -g      path to the GIMP sources (eg. /opt/gimp)
        -x      path to the gimp-help-2 sources (eg. /opt/gimp-help-2)
        -i      print ids which are supposed to be invalid
        -h      this help"""
    if errormsg:
        print "\nError: %s" % errormsg

if __name__ == "__main__":
    main()
