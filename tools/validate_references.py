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
    HAVE_LXML = True
except ImportError:
    HAVE_LXML = False

try:
    from xml import xpath
    from xml.dom import minidom
    HAVE_XML = True
except ImportError:
    HAVE_XML = False

import sys
import os
import getopt
import re

# xpath expressions of filereferences in a DocBook XML file
REFERENCESTOTEST = ['//imagedata[@fileref]', '//graphic[@fileref]',
                    '//inlinegraphic[@fileref]']

# check only xml files
xmlfile_exp = re.compile('[\w-]*\.xml$')

# check only png and jpg files
imagefile_exp = re.compile('[\w-]*\.(png|jpg)$')

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

    def get_imagefp(self, fileref):
        """Creates the absolute filepath.

        The fileref is an attribute value from a gimp-help-2 compliant
        DocBook/XML file.
        """
        mangeled = fileref.split('/')[1:]
        base = os.curdir
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
       >>> val = LxmlValidator(REFERENCESTOTEST[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       []

       Create a scrambled reference and check if the validator throws an
       error.
       >>> str = '<sect1><imagedata '\
                 'fileref="../foobar/toolbox/toolbox-flip.png" /></sect1>'
       >>> val = LxmlValidator(REFERENCESTOTEST[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       [(0, './foobar/toolbox/toolbox-flip.png')]

       >>> str = '<sect2><graphic '\
                 'fileref="../foobar/math/dot-for-dot.png" /></sect2>'
       >>> val = LxmlValidator(REFERENCESTOTEST[1], xmlstr=str)
       >>> val.validate_imagepath_references()
       [(0, './foobar/math/dot-for-dot.png')]
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
            imagefp = self.get_imagefp(fileref)

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
       >>> val = LibXMLValidator(REFERENCESTOTEST[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       []

       Create a scrambled reference and check if the validator throws an
       error.
       >>> str = '<sect1><imagedata '\
                 'fileref="../foobar/toolbox/toolbox-flip.png" /></sect1>'
       >>> val = LibXMLValidator(REFERENCESTOTEST[0], xmlstr=str)
       >>> val.validate_imagepath_references()
       [(0, './foobar/toolbox/toolbox-flip.png')]

       >>> str = '<sect2><graphic '\
                 'fileref="../foobar/math/dot-for-dot.png" /></sect2>'
       >>> val = LibXMLValidator(REFERENCESTOTEST[1], xmlstr=str)
       >>> val.validate_imagepath_references()
       [(0, './foobar/math/dot-for-dot.png')]
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
            imagefp = self.get_imagefp(fileref)

            result = self._validation_helper(imagefp)
            if result is not None:
                self.invalid.append(result)

        return self.invalid

class FileLookup(object):
    """Runs through each directory of <gimp_help_root> and checks each
       xml file it can find.

       >>> fl = FileLookup(gimp_help_root='src/toolbox')
       >>> fl.get_image_root()
       'images'
    """

    def __init__(self, verbose=0, absolute=1, gimp_help_root='.'):
        self.verbose = verbose
        self.absolute = absolute
        self.gimp_help_root = gimp_help_root

        self.all_img_references = []
        self.brokenimages = []

    def get_image_root(self):
        """Returns the absolute path to the images directory
        """
        result = None
        root = self.gimp_help_root
        h, t = os.path.split(root)

        # if we are already in the gimp-help-root we don't need to do
        # the traversal
        if os.path.exists(os.path.join(root, 'images')) and\
           os.path.exists(os.path.join(root, 'src')):
            return os.path.join(root, 'images')

        while root:
            # if we hit the gimp_help_root, we need to check if an
            # 'images' dir exist
            if os.path.exists(os.path.join(h, 'images')) and not\
               h.endswith('src'):
                result = os.path.join(h, 'images')
                break

            root = h
            h, t = os.path.split(root)

            if not t:
                break

        return result

    def validate_imagefiles(self):
        """checks if each image file is referenced in the XML files"""
        imageroot = self.get_image_root()

        if not self.all_img_references:
            return

        if imageroot is None:
            sys.stderr.write("The path you specified or the directory"\
                             " you're in do not contain an 'images"\
                             " directory.\n")
            return

        for root, dirs, files in os.walk(imageroot):
            # XXX this filtering of dirs is awkward, but I couldn't come
            # up with a better method yet
            for prune in [ 'callouts', '.svn' ]:
                if prune in dirs:
                    dirs.remove(prune)

            # ignore images in the first level of the images dir
            if root.endswith('images'):
                continue

            # don't care about other files than images files
            for file in filter(imagefile_exp.match, files):
                filepath = os.path.join(root, file)
                if filepath not in self.all_img_references:
                    sys.stdout.write(filepath + "\n")

    def validate_refs(self):
        """walks to each xml file directory, reads each xml file and
           validates the references
        """
        top = os.path.join(self.gimp_help_root, 'src')
        for root, dirs, files in os.walk(top):
            # don't visit .svn directories
            if '.svn' in dirs:
                dirs.remove('.svn')

            if self.verbose:
                sys.stdout.write("Checking %s\n" %root)

            # don't care about other files than xml files
            for file in filter(xmlfile_exp.match, files):

                # puzzle together the relative filepath
                xml_filepath = os.path.join(root, file)

                for xpathexpr in REFERENCESTOTEST:
                    if HAVE_LXML:
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
                if self.absolute:
                    item = os.path.abspath(item)
                if self.verbose:
                    errormsg = "File %s \ncontains invalid references"\
                               " to\n%s\n\n" %(item)
                else:
                    errormsg = "%s invalid: <%s>\n" %(item)
                sys.stdout.write(errormsg)


def main():
    verbose = 0
    absolute = 0
    gimp_help_root = os.curdir

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hivaf:x:")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for o, a in opts:
        if o == "-h":
            usage()
            sys.exit(0)
        if o == "-v":
            verbose = 1
        if o == "-a":
            absolute = 1
        if o == "-f":
            result = []
            for xpath_expr in REFERENCESTOTEST:
                if HAVE_LXML:
                    val = LxmlValidator(xpath_expr, a)
                elif HAVE_XML:
                    val = LibXMLValidator(xpath_expr, a)
                else:
                    sys.exit(1)
                result += val.validate_imagepath_references()

            for r in result:
                print "%s invalid: %s" %(r)
            sys.exit(1)

        if o == "-x":
            gimp_help_root = a
        if o == "-i":
            filelookup = FileLookup(verbose, absolute, gimp_help_root)
            filelookup.validate_refs()
            filelookup.validate_imagefiles()
            sys.exit(1)

    filelookup = FileLookup(verbose, absolute, gimp_help_root)
    filelookup.validate_refs()
    filelookup.print_broken_imagefilepaths()
    sys.exit(1)

def usage():
    sys.stderr.write ( """\
validate_references - Copyright 2006 Roman Joost (gimp-help-2)
validates file references in docbook xml files.

usage: validate_references.py [options]

    options:
        -h          this help
        -v          verbose
        -a          print relative paths as absolute paths
        -i          check for orphaned image files
        -f  <file>  check only <file>
        -x  <path>  specify another root of xml files \n""")

if __name__ == "__main__":
    main()
