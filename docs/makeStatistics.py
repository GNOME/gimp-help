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
        if attrs.has_key('id') and attrs.has_key('title'):
            if len(attrs['title']) >= 1:
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
        headerfile, self.docs = tuple
        self.hp = GIMPHelpHeaderParser(headerfile)
        self.hp.parse()
        self.totals = len(self.hp.ids)
        self.linguas = self._generateStatistics()
    
    def _generateStatistics(self):
        """ generates statistics for every language """
        linguas = []
        for lang in self.docs.keys():
            xp = GIMPHelpXMLParser(self.docs[lang])
            xp.parse()
            done = len(xp.ids)
            todo = self.totals - done
            prc_done = done*100/self.totals
            lang = self.makedict(done=done, todo=todo,\
                prc_done=prc_done, lang=lang)
            linguas.append(lang)
        
        return linguas
        
    def printHTMLStatistics(self):
        """ returns HTML Code with statistics """
        raise NotImplementedError 

    def printTextStatistics(self):
        """ prints Text Statistics """
        for dict in self.linguas:
            done = '#'*int(dict['prc_done']/10)
            todo = ' '*(10-(dict['prc_done']/10))
            print "\nLanguage: %s" %dict['lang']
            print "Found titles for: %i ids - Todo: %s ids"\
                %(dict['done'], dict['todo'])
            print "Percent done: |%s%s| %s%%" %(done,todo, dict['prc_done'])
        
    def makedict(self, **kwargs):
        return kwargs
        
def main():
    header = None
    xml = None
    linguas = ['de', 'fr', 'sv', 'en']
    helpxmlfile = "/gimp-help.xml"
    gimpheaderfile = "/gimphelp-ids.h"
    xmldocs = {}
    
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hx:g:")
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
            helppath = a + "/html/"
        if o == "-g":
            gimp = a + "/app/widgets" + gimpheaderfile
    
    if os.path.exists(gimp) and os.path.exists(helppath):
        for lang in linguas:
            # puzzling the path to the gimp-help.xml file
            helpfile = helppath + lang + helpxmlfile
            if os.path.exists(helpfile):
                xmldocs[lang] = helpfile
        
        st = Statistics((gimp, xmldocs))
        st.printTextStatistics()
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
        -h      this help"""
    
if __name__ == "__main__":
    main()
