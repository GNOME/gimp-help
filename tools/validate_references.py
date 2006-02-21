#!/usr/bin/env python
# _*_ coding: latin1 -*_

# gimp-help-2 -- Validate image file references
# Copyright (C) 2006 Róman Joost 
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
try:
    from lxml import etree
    have_lxml = True
except ImportError:
    have_lxml = False

from xml import xpath
from xml.dom import minidom
import sys
import os
import getopt
import re

# xpath expressions of filereferences in a DocBook XML file
refs_to_test = ['//imagedata[@fileref]',]

# check only xml files
xmlfile_exp = re.compile('[\w-]*.xml$')

# check only png and jpg files
imagefile_exp = re.compile('[\w-]*.(png|jpg)$')

# ignore directories to look for images
ignore_image_dirs = ['callouts',]

class XMLReferenceValidator(object):
    """A validator to validate filereferences in a DocBook complient
       XML file.
    """

    def __init__(self, xpath_expr, filepath=None, xmlstr=None):
        self.xpath_expr = xpath_expr
        self.filepath = filepath
        self.xmlstr = xmlstr
        self.img_references = []
        self.invalid = []

    def create_absolute_imagefp(self, fileref):
        """Creates the absolute filepath.

        The fileref is an attribute value from a gimp-help-2 compliant
        DocBook/XML file.
        """
        mangeled = fileref.split('/')[1:]
        base = os.path.abspath(os.curdir)
        imagefp = "/".join(mangeled)
        # now put everything together
        imagefp = os.path.join(base, imagefp)
            
        # save the filename in our list
        if imagefp not in self.img_references:
            self.img_references.append(imagefp)
        
        return imagefp

    def _validation_helper(self, imagefp):
        imagefp = imagefp.encode()
        if not os.path.exists(imagefp) and self.filepath is not None:
            return (self.filepath, imagefp)
        elif not os.path.exists(imagefp) and self.xmlstr is not None:
            return (0, imagefp)

    def validate_imagepath_references(self):
        raise ValueError("Implemented in sublcasses.")


class LxmlValidator(XMLReferenceValidator):
    """A validator to validate filereferences in a DocBook complient
       XML file.
       
       >>> str = '<sect1><imagedata '\
                 'fileref="../images/toolbox/toolbox-flip.png" /></sect1>'
       >>> val = LxmlValidator(refs_to_test[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       []

       Create a scrambled reference and check if the validator throws an
       error.
       >>> str = '<sect1><imagedata '\
                 'fileref="../foobar/toolbox/toolbox-flip.png" /></sect1>'
       >>> val.xmlstr = str
       >>> val.validate_imagepath_references()
       [(0, '/home/roman/works/projects/gimp-help-2/foobar/toolbox/toolbox-flip.png')]

    """

    def get_elements_by_xpath(self):
        if self.xmlstr is not None:
            from StringIO import StringIO
            doc = etree.parse(StringIO(self.xmlstr))
        else:
            doc = etree.parse(open(self.filepath))
        return doc.xpath(self.xpath_expr)

    
    def validate_imagepath_references(self):
        """Validates all references
            
           returns a tuple (xmlfilepath, imagefilepath) if the reference
           is broken
        """
        elements = self.get_elements_by_xpath()
            
        for el in elements:
            # mangle the filepath
            fileref = el.get('fileref')
            imagefp = self.create_absolute_imagefp(fileref)
            
            result = self._validation_helper(imagefp)
            if result is not None:
                self.invalid.append(result)

        return self.invalid

class LibXMLValidator(XMLReferenceValidator):
    """ It is not important to have a valid DocBook/XML file here. We
       just test, if the method pics up the correct filepath and
       validates it.
       >>> str = '<sect1><imagedata '\
                 'fileref="../images/toolbox/toolbox-flip.png" /></sect1>'
       >>> val = LibXMLValidator(refs_to_test[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       []

       Create a scrambled reference and check if the validator throws an
       error.
       >>> str = '<sect1><imagedata '\
                 'fileref="../foobar/toolbox/toolbox-flip.png" /></sect1>'
       >>> val.xmlstr = str
       >>> val.validate_imagepath_references()
       [(0, '/home/roman/works/projects/gimp-help-2/foobar/toolbox/toolbox-flip.png')]

    """

    def get_elements_by_xpath(self):
        if self.xmlstr is not None:
            dom = minidom.parseString(self.xmlstr)
        else:
            dom = minidom.parse(self.filepath)
        return xpath.Evaluate(self.xpath_expr, dom)

    def validate_imagepath_references(self):
        """Validates all references
            
           returns a tuple (xmlfilepath, imagefilepath) if the reference
           is broken
        """
        for el in self.get_elements_by_xpath():
            fileref = el.getAttribute('fileref')
            imagefp = self.create_absolute_imagefp(fileref)
            
            result = self._validation_helper(imagefp)
            if result is not None:
                self.invalid.append(result)

        return self.invalid

class FileLookup(object):
    """Runs through each directory of <gimp_help_root> and checks each
       xml file it can find.

       >>> fl = FileLookup(gimp_help_root='src/toolbox')
       >>> fl.get_image_root()
       '/home/roman/works/projects/gimp-help-2/images'
       
       If we run the tests already from the gimp-help-2 root, the method
       should return a None given by this path
       >>> fl.gimp_help_root = '../tools'
       >>> fl.get_image_root()
    """
    
    def __init__(self, verbose=0, gimp_help_root='.'):
        self.verbose = verbose
        self.gimp_help_root = gimp_help_root
        
        self.all_img_references = []
        self.brokenimages = []

    def get_image_root(self):
        """Returns the absolute path to the images directory
        """
        result = None
        abspath = os.path.abspath(self.gimp_help_root)
        h, t = os.path.split(abspath) 
        
        while abspath:
            # if we hit the gimp_help_root, we need to check if an
            # 'images' dir exist
            if os.path.exists(os.path.join(h, 'images')) and not\
               h.endswith('src'):
                result = os.path.join(h, 'images')
                break
            
            abspath = h
            h, t = os.path.split(abspath) 

            if t == '':
                break

        return result

    def validate_imagefiles(self):
        """checks if each image file is referenced in the XML files"""
        imageroot = self.get_image_root()
        
        if not self.all_img_references:
            return

        if imageroot is None:
            sys.stderr.write("The path you specified or the directory"\
                             " you're don't contain an 'images' directory")
            return


        for root, dirs, files in os.walk(imageroot):
            if 'CVS' in dirs:
                dirs.remove('CVS')

            for file in files:
                if not imagefile_exp.match(file):
                    continue
                 
                filepath = os.path.abspath(os.path.join(root, file))
                try:
                    self.all_img_references.remove(filepath)
                except ValueError:
                    print filepath
            
    def validate_refs(self):
        """walks to each xml file directory, reads each xml file and
           validates the references
        """
        top = os.path.join(self.gimp_help_root, 'src')
        for root, dirs, files in os.walk(top):
            # don't visit CVS directories
            if 'CVS' in dirs:
                dirs.remove('CVS') 

            if self.verbose:
                print "Checking %s" %root
            
            for file in files:
                # don't care about other files than xml files
                if not xmlfile_exp.match(file):
                    continue

                # puzzle together the relative filepath
                for xpathexpr in refs_to_test:
                    xml_filepath = os.path.join(root, file)
                    
                    if have_lxml:
                        val = LxmlValidator(xpathexpr, 
                                            xml_filepath)
                    else:
                        val = LibXMLValidator(xpathexpr,
                                              xml_filepath)
                    
                    result = val.validate_imagepath_references()
                    if result is not []:
                        self.brokenimages.append(result)
                        
                        # XXX thats kinda stupid, because we have two lists
                        # which save the filepaths of the images
                        self.all_img_references += val.img_references

    def print_broken_imagefilepaths(self):
        """Prints out which xml files have broken references to
           images.
        """
        for itemlist in self.brokenimages:
            for item in itemlist:
                if self.verbose:
                    errormsg = "File %s \ncontains invalid references"\
                               " to\n\n%s\n" %(item)
                else:
                    errormsg = "%s invalid: <%s>" %(item)
                print errormsg

            
def main():
    verbose = 0
    gimp_help_root = os.curdir 

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hivf:x:")
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    
    for o, a in opts:
        if o == "-h":
            usage()
        if o == "-v":
            verbose = 1
        if o == "-f":
            result = []
            for xpath_expr in refs_to_test:
                if have_lxml:
                    val = LxmlValidator(xpath_expr, 
                                        a)
                else:
                    val = LibXMLValidator(xpath_expr,
                                          a)
                result += val.validate_imagepath_references()
            
            for r in result:
                print "%s invalid: %s" %(r)
            sys.exit(1)
        
        if o == "-x":
            gimp_help_root = a
        if o == "-i":
            fl = FileLookup(verbose, gimp_help_root)
            fl.validate_refs()
            fl.validate_imagefiles()
            sys.exit(1)
    
    fl = FileLookup(verbose, gimp_help_root)
    fl.validate_refs()
    fl.print_broken_imagefilepaths()
    sys.exit(1)

def usage():
    sys.stderr.write ( """\
validate_references - Copyright 2006 Roman Joost (gimp-help-2)
validates file references in docbook xml files.

usage: validate_references.py [options]
    
    options:
        -h          this help
        -v          verbose
        -i          check for orphaned image files
        -f  <file>  check only <file>
        -x  <path>  specify another root of xml files""" )
    
if __name__ == "__main__":
    main()
