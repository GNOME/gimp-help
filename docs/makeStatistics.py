#!/usr/bin/env python
# This file is part of the gimp-help-2 project and is
# Copyright 2004 Roman Joost
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
import xml.parsers.expat
import sys
import os
import getopt
import re
import string

from os.path import join

class GIMPHelpXMLParser:
    
    def __init__(self, xml_filename):
        self.ids = []
        assert xml_filename != ""
        self.xml_filename = xml_filename
        self.Parser = xml.parsers.expat.ParserCreate()
        
        self.Parser.CharacterDataHandler = self.handleCharData
        self.Parser.StartElementHandler = self.handleStartElement
        self.Parser.EndElementHandler = self.handleEndElement

    def parse(self):
        try:
            xml_file = open(self.xml_filename, "r")
        except IOError:
            print "ERROR: Can't open XML file %s" %self.xml_filename
            raise
        else:
            try: self.Parser.ParseFile(xml_file)
            finally: xml_file.close()

    def handleStartElement(self, name, attrs):
        if attrs.has_key('id'):
            self.ids.append(attrs['id'])

    def handleCharData(self, data): pass
    def handleEndElement(self, name): pass

class GIMPHelpHeaderParser:
    
    helpid = re.compile('gimp-.[a-z-]+')
    
    def __init__(self, header_filename):
        assert header_filename != ""
        self.h_filename = header_filename
        self.ids = []

    def parse(self):
        try:
            h_file = open(self.h_filename, "r")
        except IOError:
            print "ERROR: Can't open gimp header file: %s"\
                %self.h_filename
            raise
        else:
            for line in h_file.readlines():
                try:
                    str = self.helpid.search(line).group()
                    self.ids.append(str)
                except AttributeError:
                    pass

class Statistics:
    
    def __init__(self, tuple):
        headerfile, self.helproot = tuple
        self.hp = GIMPHelpHeaderParser(headerfile)
        self.hp.parse()
        self.totals = len(self.hp.ids)
        
        self.docs = self.getDocumentPaths()
        self.statistics = self._generateStatistics()
   
    def getDocumentPaths(self):
        """ returns a dictionary with languages as keys and paths to the
            xml documents as values 
        """
        linguas = get_linguas(self.helproot) 
        result = {}
        for lang in linguas:
            # puzzling the path to the gimp-help.xml file together
            helpfile = self.helproot + 'html/' + lang + '/gimp-help.xml'
            if os.path.exists(helpfile):
                result[lang] = helpfile

        return result
   
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
            xp = GIMPHelpXMLParser(self.docs[lang])
            xp.parse()
            for id in xp.ids:
                if id not in helpids:
                    xp.ids.remove(id)
                else:
                    other_ids.append(id)
                    
            done = len(xp.ids)
            add = len(other_ids)
            if done < self.totals:
                todo = self.totals - done
                prc_done = done*100/self.totals
            else:
                todo = 0
                prc_done = 100
                
            lang = self.makedict(done=done,\
                                 todo=todo,\
                                 others=add,\
                                 prc_done=prc_done,\
                                 lang=lang)
            result.append(lang)
        
        return result
    
    def getInvalidIds(self):
        """ parses one gimp-help.xml file and compare the id's found
            with help ids. If the id from the xml file is not in help
            ids, append it to invalid.
            returns list with invalid ids (str)
        """
        assert self.docs != {}
        
        for lang in self.docs.keys():
            xp = GIMPHelpXMLParser(self.docs[lang])
            xp.parse()
            invalid = []
            skip = ['faq', 'using', 'fdl', 'glossary',
                'introduction', 'gimp-main', 'legal', 'tools-color',
                'tools-paint', 'tools-selection', 'tools-transform',
                'tools-menu', 'plug-in']
            
            for id in xp.ids:
                not_invalid = None
                if id in skip:
                    continue
            
                not_invalid = filter(lambda k, y=0:\
                    y + self.isSubstring(id, k), skip)
                
                if not_invalid:
                    continue

                if not self.is_helpid(id):
                    invalid.append(id)

            invalid.sort()
        return invalid

        
    def getInvalidFilenames(self):
        """ indexes all filenames and compare it with the help ids
            if filename is not in help ids append it to invalid list
            returns list with invalid filenames(str)
        """
        invalid = []
        names = {}
        root = self.helproot + "src"
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
                    names[id] = join(root, file)

        # remove the valid entries
        for id in names.keys():
            not_invalid = 0

            not_invalid = filter(lambda k, y=0:\
                y + self.isSubstring(id, k), filter_files)
            if not_invalid:
                continue
           
            if self.is_helpid('gimp-' + id):
                del names[id]
                
        return names 
        
    def isSubstring(self, str, substr):
        """ returns 1 if str is substr from str """
        if string.find(str, substr) >= 0:
            return 1

        return 0
    
    def is_helpid(self, name):
        """ returns 1 if the file is in helpids otherwise 0 """
        if name is not None and name in self.hp.ids:
            return 1
        
        return 0
            
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
        
    def makedict(self, **kwargs):
        return kwargs

def get_linguas(gimphelppath):
    """ returns the linguas set in configure.in in gimp-help-2 dir """
    defaultlinguas = ['en', 'de', 'fr', 'sv', 'zh_CN']
    gimphelppath = "%sconfigure.in" % gimphelppath
    if os.environ.has_key('ALL_LINGUAS'):
        linguas = os.environ.get('ALL_LINGUAS')
        linguas = linguas.split(' ')
        return linguas 
        
    try:
        f = open(gimphelppath, 'r')
    except IOError:
        return defaultlinguas
    
    for line in f.readlines():
        try:
            linguas = re.search('ALL_LINGUAS="(\w.+)"', line).groups()
            linguas = linguas[0].split(' ')
            return linguas
        except AttributeError:
            pass

    return defaultlinguas 
            
def main():
    header = None
    xml = None
    helppath = "" 
    print_invalid = 0
    gimpheaderfile = "/gimphelp-ids.h"
    xmldocs = {}
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hx:g:i")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    if not opts:
        usage()
        sys.exit(1)
    
    for o, a in opts:
        if o == "-h":
            usage()
        if o == "-x":
            helppath = a
        if o == "-g":
            gimp = a + "/app/widgets" + gimpheaderfile
        if o == "-i":
            print_invalid = 1
    
    if os.path.exists(gimp) and os.path.exists(helppath):
        st = Statistics((gimp, helppath))
        st.printTextStatistics(print_invalid)
        sys.exit(1)
    else:
        usage()
        print "Error: one of your path is invalid!"
        sys.exit(0)

def usage():
    
    print """idlookup.py - Copyright 2004 Roman Joost (gimp-help-2)
generates some statistical information about the documentation process 

usage: idlookup.py [options]
    
    options:
        -g      path to the GIMP sources (eg. /opt/gimp)
        -x      path to the gimp-help-2 sources (eg. /opt/gimp-help-2)
        -i      print ids which are supposed to be invalid
        -h      this help"""
    
if __name__ == "__main__":
    main()
