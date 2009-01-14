#!/usr/bin/env python
# -*- coding: latin1 -*-
"""
  Validate image file references

  Validates image file references in DocBook XML files and
  finds orphaned images files.
"""

# gimp-help-2 -- validate_references.py
#
# Copyright (C) 2006, 2007 Róman Joost
#           (C) 2008, 2009 Róman Joost, Ulf-D. Ehlert
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import sys
import os
import getopt
import re
import xml.sax

# TODO: use the Python logging system(!?)
#import logging


# Nodes containing filereferences in a DocBook XML file
IMAGE_NODES = ["imagedata", "graphic", "inlinegraphic"]

# Regular expression for image files to be checked (png and jpg files only)
IMAGEFILE_REGEX = re.compile('[\w+-]*\.(png|jpg)$')
# Regular expression for image files to be skipped
IGNORE_IMAGE_REGEX = re.compile('callout')


class FileNameContainer(object):
    """A special purpose container base class.

    This class stores filenames and provides some basic
    access methods common to both derived List classes.

    """
    def __init__(self, verbose=0):
        self.verbose = verbose
        self.data    = {}

    def __contains__(self, key):
        """Is there an entry 'key'?."""
        return self.data.has_key(key)

    def add(self, key, val=True):
        """Add a (key, value) pair to the container, e.g.
           filename and some info corresponding to this filename.
        """
        self.data[key] = val

    def __setitem__(self, key, val):
        """Add a (key, value) pair to the container, e.g.
           filename and some info corresponding to this filename.
        """
        self.data[key] = val

    def erase(self, key):
        """Mark an entry as invalid.
        
        Set the info to False rather than deleting it,
        so that "removing" while iterating is possible.
        """
        if self.data.has_key(key):
            self.data[key] = False

    def size(self):
        """Return the number of non-empty data entries."""
        return len([x for x in self.data if self.data[x]])

    def __len__(self):
        """Return the number of data entries."""
        return len(self.data)

    def sort_out_valid(self, other):
        """Same as 'difference(self,other)'. When common entries
           have been removed, the remaining filenames are just
           the orphaned files, or the broken links, respectively.
        """
        self.difference(other)

    def difference(self, other):
        """Remove entries common to 'self' and 'other'."""
        for key in self.data.iterkeys():
            if key in other:
                self.erase(key)
                other.erase(key)


class ImageFilesList(FileNameContainer):
    """A container for image file names.

    This class is used to collect and save all image files
    in the specified 'images/' directory.

    """
    def __init__(self, verbose=0):
        super(ImageFilesList, self).__init__(verbose)

    def find(self, imageroot):
        """Search for PNG and JPG files in the image directory."""

        self.data.clear()
        self.imageroot = os.path.normpath(imageroot)
        imageroot = self.imageroot + "/"

        if self.verbose == 1:
            sys.stderr.write("searching images in %s ... " % imageroot)
        elif self.verbose > 1:
            sys.stderr.write("searching images in %s ... \n" % imageroot)

        for root, dirs, files in os.walk(self.imageroot):
            if self.verbose > 2:
                sys.stderr.write("    entering " + root + "\n")
            for prune in [ 'callouts', '.svn' ]:
                if prune in dirs:
                    dirs.remove(prune)

            # ignore images in the first level of the images dir
            if root.endswith('images'):
                if self.verbose > 2:
                    sys.stderr.write("    skipping " + root + "\n")
                continue

            # don't care about other files than images files
            for filename in (name for name in files
                                  if IMAGEFILE_REGEX.match(name)):
                filepath = os.path.join(root, filename)
                if self.verbose > 1:
                    sys.stderr.write(filepath + '\n')
                self.add(filepath.replace(imageroot, ""))

        if self.verbose:
            sys.stderr.write("%d files\n" % len(self.data))

    def report(self):
        """Print the list of orphaned image files, i.e. image files
           which are not referred to in any XML source file.
        """
        files = [fname for fname in self.data.keys() if self.data[fname]]
        if self.verbose:
            colon, plural_s = ":", "s"
            if len(files) == 0: colon = ""
            if len(files) == 1: plural_s = ""
            sys.stderr.write("%d orphaned image file%s%s\n" % \
                             (len(files), plural_s, colon))
        for imagefile in sorted(files):
            print "ORPHANED:", os.path.join(self.imageroot, imagefile)


class ImageReferencesList(FileNameContainer):
    """A container for image file references.

    This class is used to collect and save all image file
    references in the XML source files, i.e. it saves
    ('image-file', 'source-file') pairs.

    """
    def __init__(self, verbose=0):
        super(ImageReferencesList, self).__init__(verbose)
        self.cur_files = []	# stack for files in progress
        self.all_files = 0	# visited files
        self.handler   = XMLHandler(self)
        self.parser    = self.make_parser()

    def make_parser(self):
        """Create and return an initialized SAX XMLReader object,
           i.e. an XML parser. A content handler is attached to
           the parser and some appropriate features are set.
        """
        parser = xml.sax.make_parser()
        parser.setContentHandler(self.handler)
        parser.setFeature(xml.sax.handler.feature_namespaces, 0)
        parser.setFeature(xml.sax.handler.feature_external_ges, 0)
        parser.setFeature(xml.sax.handler.feature_external_pes, 0)
        return parser
        
    def find(self, source_file):
        """Parse XML files and extract image references."""

        if self.verbose > 1:
            sys.stderr.write("parsing XML files ... \n")
        elif self.verbose:
            sys.stderr.write("parsing XML files ... ")

        self.push_file(source_file)
        try:
            self.parser.parse(source_file)
        except xml.sax.SAXException, err:
            sys.stderr.write("ERROR parsing %s\n" % err)
        except:
            sys.stderr.write("ERROR reading %s\n" % source_file)
        assert(len(self.cur_files) == 1)

        if self.verbose > 1:
            sys.stderr.write("parsed %d files, %d references\n" % \
                             (self.all_files, self.size()))
        elif self.verbose:
            sys.stderr.write("%d files, %d references\n" % \
                             (self.all_files, self.size()))

    def report(self):
        """Print the list of broken image referencess
           in the XML source file(s).
        """
        files = [fname for fname in self.data.keys() if self.data[fname]]
        if self.verbose:
            colon, plural_s = ":", "s"
            if len(files) == 0: colon = ""
            if len(files) == 1: plural_s = ""
            sys.stderr.write("%d broken image reference%s%s\n" % \
                                  (len(files), plural_s, colon))
        for imagefile in sorted(files):
            print "BROKEN: images/%s IN %s" % (imagefile, self.data[imagefile])

    # Internal stack methods to keep track of the opened files

    def current_file(self):
        """The file currently parsed."""
        return self.cur_files[-1]	# top of filenames stack

    def push_file(self, filename):
        """Add entry to internal stack of filenames."""
        self.cur_files.append(filename)
        self.all_files += 1

    def pop_file(self):
        """Remove top entry from internal stack of filenames."""
        return self.cur_files.pop()


class XMLHandler(xml.sax.handler.ContentHandler):
    """A content handler class as defined by the SAX API."""
    def __init__(self, owner):
        #super(XMLHandler, self).__init__()
        self.owner = owner
    def startElement(self, name, attrs):
        """Handle image nodes."""
        if name in IMAGE_NODES:
            fileref = attrs.getValue('fileref').replace("images/", "")
            if not IGNORE_IMAGE_REGEX.match(fileref):
                self.owner.add(fileref, self.owner.current_file())
        if name == "xi:include" and attrs.has_key('href'):
            filename = os.path.join(os.path.dirname(self.owner.current_file()),
                                    attrs.getValue('href'))
            if os.path.isfile(filename):
                if self.owner.verbose > 1:
                    sys.stderr.write("parsing " + str(filename) + "\n")
                self.owner.push_file(filename)
                parser = self.owner.make_parser()
                try:
                    parser.parse(filename)
                except xml.sax.SAXException, err:
                    sys.stderr.write("ERROR parsing %s\n" % err)
                except:
                    sys.stderr.write("ERROR reading %s\n" % filename)
                self.owner.pop_file()
            else:
                if self.owner.verbose > 1:
                    sys.stderr.write("skipping " + str(filename) + "\n")


def main():
    """The main program (hmm, what did you expect?).
       
       The algorithm for validating image files and references is
       very simple:

       Let
           (1) I := (set of) all image files,
           (2) R := (set of) all image file references,
       then
           (3) B := R \ I = R \ (R ∩ I)
       is the set containing files in R but not in I, that is the set
       of broken references,
           (4) O := I \ R = I \ (R ∩ I)
       is the set containing files in I but not in R, that is the set
       of images not referenced in the XML files (orphaned images).
    """
    verbose                = 0
    gimp_help_root_dir     = "."
    xml_dir                = "src"
    img_dirs               = "images/C"
    xml_root_file          = "gimp.xml"
    find_orphaned_images   = False
    find_broken_references = False

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvr:x:s:i:blio",
                         ["help", "verbose",
                          "root=", "xmldir=", "srcdir=", "imgdir=",
                          "broken", "links", "orphaned", "images"])
    except getopt.GetoptError, err:
        usage(64, str(err))

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
        elif opt == "-v" or opt == "--verbose":
            verbose += 1
        elif opt in ["-r", "--root"]:
            gimp_help_root_dir = arg
        elif opt in ["-x", "--xmldir", "-s", "--srcdir"]:
            xml_dir = arg
            xml_root_file = os.path.join(xml_dir, xml_root_file)
        elif opt in ["-i", "--imgdir"]:
            img_dirs = re.split('[, ]+', arg)
        elif opt in ["-b", "--broken", "-l", "--links"]:
            find_broken_references = True
        elif opt in ["-o", "--orphaned"]:
            find_orphaned_images = True
        elif opt == "-f" or opt == "--file":
            find_broken_references = True
            xml_root_file = arg

    if args:
        usage(64, "Too many arguments.")

    # Change to user specified root dir.
    if gimp_help_root_dir != ".":
        try:
            os.chdir(gimp_help_root_dir)
        except OSError, (errno, strerror):
            sys.stderr.write("Error: " + strerror + ": " + \
                             gimp_help_root_dir +"\n")
            sys.exit(errno)

    # Check for the correct directory.
    if not (os.path.isdir("images/") and os.path.isdir("src/")):
        usage(66, "This script must be called from the " +
                   "gimp-help-2 root directory.")

    # We need an existing xml source file to parse.
    if not os.path.isfile(xml_root_file):
        if os.path.isfile(os.path.join(xml_dir, xml_root_file)):
            xml_root_file = os.path.join(xml_dir, xml_root_file)
        else:
            usage(66, "Cannot find " + xml_root_file + ".")

    # When finding orphaned images, we must parse all xml files.
    #if find_orphaned_images and (xml_root_file != "src/gimp.xml"):
    #    usage(64, "'--file <file>' and '--orphaned' are mutually exclusive.")

    # If no action specified: search for broken image references.
    if not (find_orphaned_images or find_broken_references):
        find_broken_references = True

    # Step 1: find all image references.
    image_refs = ImageReferencesList(verbose)
    image_refs.find(xml_root_file)

    # Step 2: find all image files. 
    image_files = ImageFilesList(verbose) 
    if isinstance(img_dirs, str): img_dirs = [img_dirs]
    for imgdir in img_dirs:
        image_files.find(imgdir)

        # Step 3: remove intersection of image references and images files,
        # the result is the list of invalid (broken) references.
        if find_broken_references:
            image_refs.sort_out_valid(image_files)
            image_refs.report()
            find_broken_references = False

        # Step 4: remove intersection of image references and images files,
        # the result is the list of orphaned image files.
        if find_orphaned_images:
            image_files.sort_out_valid(image_refs)
            image_files.report()


def usage(exitcode=0, msg=""):
    """Help the user."""
    if exitcode > 0 or msg:
        sys.stderr.write("Error: " + msg + "\n")
        sys.stderr.write("(try \"%s --help\")\n" % sys.argv[0])
    else:
        sys.stdout.write ( """\
validate_references - validates image file references in DocBook xml files

Copyright (C) 2006-2008 Róman Joost,
          (C) 2008-2009 Róman Joost, Ulf-D. Ehlert

Usage: validate_references.py [options]

    options:
        -h | --help          this help
        -v | --verbose       verbose; doubling (-v -v) is possible
        -r | --root <dir>    specify the gimp-help-2 root directory
        -x | --xmldir <dir>  specify the XML files directory
        -i | --imgdir <dir>  comma-separated list of images directories
        -o | --orphaned      check for orphaned image files
        -b | --broken        check for broken links (default action)
\n""")    
    sys.exit(exitcode)

if __name__ == "__main__":
    main()
