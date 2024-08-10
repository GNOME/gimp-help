#!/usr/bin/env python3
# -*- coding: latin1 -*-
"""
  Validate image file references

  Validates image file references in DocBook XML files and
  finds orphaned images files.
"""

# gimp-help -- validate_references.py
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
import logging

# Configure logging
logging.basicConfig(format="%(message)s", level=logging.WARNING)
Logger = logging.getLogger()

# Nodes containing filereferences in a DocBook XML file
IMAGE_NODES = ["imagedata", "graphic", "inlinegraphic"]

# Regular expression for image files to be checked (png and jpg files only)
IMAGEFILE_REGEX = re.compile(r'[\w.+-]*\.(png|jpg|svg)$')
# Regular expression for image files to be skipped
IGNORE_IMAGE_REGEX = re.compile('callout')


class FileNameContainer(object):
    """A special purpose container base class.

    This class stores filenames and provides some basic
    access methods common to both derived List classes.

    """
    def __init__(self):
        self.data = {}

    def __contains__(self, key):
        """Is there an entry 'key'?."""
        return key in self.data

    def __setitem__(self, key, val):
        """Add a (key, value) pair to the container, e.g.
           filename and some info corresponding to this filename.
        """
        self.data[key] = val

    def add(self, key, val=True):
        """Add a (key, value) pair to the container, e.g.
           filename and some info corresponding to this filename.
        """
        self.data[key] = val

    def clear(self):
        """Remove all entries, i.e. remove all (key, value) pairs."""
        self.data = {}

    def erase(self, key):
        """Mark an entry as invalid.

        Set the info to False rather than deleting it,
        so that "removing" while iterating is possible.
        """
        self.data[key] = False

    def files(self):
        return [x for x in self.data if self.data[x]]

    def size(self):
        """Return the number of non-empty data entries."""
        return len(self.files())

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
        for key in (k for k in self.data if k in other):
            self.erase(key)


class ImageFilesList(FileNameContainer):
    """A container for image file names.

    This class is used to collect and save all image files
    in the specified 'images/' directory.

    """
    def __init__(self):
        super(ImageFilesList, self).__init__()
        self.imageroot = ""

    def find(self, imageroot):
        """Search for PNG and JPG files in the image directory."""

        self.clear()
        self.imageroot = os.path.normpath(imageroot)

        Logger.info("\nsearching images in '%s' ..." % self.imageroot)

        for root, dirs, files in os.walk(self.imageroot):
            for prune in [ 'callouts', '.git' ]:
                if prune in dirs:
                    dirs.remove(prune)

            # don't save the prefix common to all entries
            prefixlen = len(self.imageroot) + 1  # path + "/"
            # don't care about other files than images files
            for filename in (name for name in files
                                  if IMAGEFILE_REGEX.match(name)):
                filepath = os.path.join(root, filename)
                Logger.debug(filepath)
                self.add(filepath[prefixlen:])

        Logger.info("found %d image files\n" % len(self))

    def report(self):
        """Print the list of orphaned image files, i.e. image files
           which are not referred to in any XML source file.
        """
        files = self.files()
        Logger.info("%d orphaned image file%s%s" % \
                    (len(files), char_if("s", len(files) != 1),
                                 char_if(":", len(files) != 0)))
        for imagefile in sorted(files):
            print("ORPHANED:", os.path.join(self.imageroot, imagefile))


class ImageReferencesList(FileNameContainer):
    """A container for image file references.

    This class is used to collect and save all image file
    references in the XML source files, i.e. it saves
    ('image-file', 'source-file') pairs.

    """
    def __init__(self):
        super(ImageReferencesList, self).__init__()
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
        # "Optionally do not perform Namespace processing
        # (implies namespace-prefixes)."
        parser.setFeature(xml.sax.handler.feature_namespaces, 0)
        # "Do not include external general (text) entities."
        parser.setFeature(xml.sax.handler.feature_external_ges, 0)
        # "Do not include any external parameter entities,
        # even the external DTD subset."
        parser.setFeature(xml.sax.handler.feature_external_pes, 0)
        return parser

    def find(self, source_file):
        """Parse XML files and extract image references."""

        Logger.info("parsing XML files ... ")
        self.push_file(source_file)
        Logger.debug("parsing %s" % source_file)

        try:
            self.parser.parse(source_file)
        except xml.sax.SAXException as err:
            Logger.error("ERROR parsing %s" % err)
            sys.exit(65)
        except:
            Logger.error("ERROR reading %s" % source_file)
            sys.exit(65)

        assert(len(self.cur_files) == 1)
        Logger.info("found %d references in %d files" % \
                    (len(self), self.all_files))

    def add(self, imagefile_reference):
        """Add a (reference, location) pair to the list of image files.

        "imagefile_reference" is the value of the 'fileref' attribute
        as returned from the xml-parser. The common prefix "images/"
        will be removed.
        "location" is the name of the current xml source file.
        """
        key = imagefile_reference.replace("images/", "")
        val = self.current_file()
        super(ImageReferencesList, self).add(key, val)

    def report(self):
        """Print the list of broken image references
           in the XML source file(s).
        """
        files = self.files()
        Logger.info("%d broken image reference%s%s" % \
                    (len(files), char_if("s", len(files) != 1),
                                 char_if(":", len(files) != 0)))
        for imagefile in sorted(files):
            print("BROKEN: images/%s IN %s" % (imagefile, self.data[imagefile]))

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
            try:
                fileref = attrs.getValue('fileref')
                if not IGNORE_IMAGE_REGEX.match(fileref):
                    self.owner.add(fileref)
            except KeyError:
                self.error("missing 'fileref' attribute")
        if name == "xi:include" and 'href' in attrs:
            filename = os.path.join(os.path.dirname(self.owner.current_file()),
                                    attrs.getValue('href'))
            if os.path.isfile(filename):
                parser = self.owner.make_parser()
                self.owner.push_file(filename)
                Logger.debug("parsing %s" % filename)
                parser.parse(filename)
                self.owner.pop_file()
            else:
                self.error("missing file: '%s'" % filename)

    def error(self, errmsg=""):
        """Wrapper function for raising an xml.sax.SAXException.

        This is a simple workaround to raise an exception with
        line and column number provided.
        """
        try:
            line = self._locator.getLineNumber()
            column = self._locator.getColumnNumber()
        except AttributeError:
            line, column = '?', '?'
        errmsg = "%s:%s:%s: %s" % \
                 (self.owner.current_file(), line, column, errmsg)
        raise xml.sax.SAXException(errmsg)


def main():
    r"""The main program (hmm, what did you expect?).

       The algorithm for validating image files and references is
       very simple:

       Let
           (1) R := (set of) all image file references,
           (2) I := (set of) all image files,
       then
           (3) B := R \ I = R \ (R ∩ I)
       is the set containing files in R but not in I, that is the set
       of broken references,
           (4) O := I \ R = I \ (R ∩ I)
       is the set containing files in I but not in R, that is the set
       of images not referenced in the XML files (orphaned images).
    """
    gimp_help_root_dir     = "."
    xml_dir                = "src"
    img_dirs               = "images/C"
    languages              = "C"
    xml_root_file          = "gimp.xml"
    find_orphaned_images   = False
    find_broken_references = False

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvr:x:s:blof:",
                         ["help", "verbose",
                          "root=", "xmldir=", "srcdir=", "file=",
                          "broken", "links", "orphaned",])
    except getopt.GetoptError as err:
        usage(64, str(err))

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
        elif opt == "-v" or opt == "--verbose":
            if not Logger.isEnabledFor(logging.DEBUG):
                Logger.setLevel(Logger.getEffectiveLevel() - logging.DEBUG)
        elif opt in ["-r", "--root"]:
            gimp_help_root_dir = arg
        elif opt in ["-x", "--xmldir", "-s", "--srcdir"]:
            xml_dir = arg
            xml_root_file = os.path.join(xml_dir, xml_root_file)
        elif opt in ["-b", "--broken", "-l", "--links"]:
            find_broken_references = True
        elif opt in ["-o", "--orphaned"]:
            find_orphaned_images = True
        elif opt == "-f" or opt == "--file":
            find_broken_references = True
            xml_root_file = arg

    languages = args or ["C"];
    if "en" in languages:
        if "C" in languages:
            languages.remove("en")
        else:
            languages[languages.index("en")] = "C"

    # Change to user specified root dir.
    if gimp_help_root_dir != ".":
        try:
            os.chdir(gimp_help_root_dir)
        except OSError as xxx_todo_changeme:
            (errno, strerror) = xxx_todo_changeme.args
            Logger.error("ERROR: %s: %s" % (strerror, gimp_help_root_dir))
            sys.exit(errno)

    # Check for the correct directory.
    if not (os.path.isdir("images/") and os.path.isdir("src/")):
        usage(66, "This script must be called from the " +
                  "gimp-help root directory.")

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

    image_refs  = ImageReferencesList()
    image_files = ImageFilesList()

    # find all image references.
    image_refs.find(xml_root_file)                         # (1)

    # find all image files in "images/C", then
    # remove intersection of image references and image files;
    # the result is the list of invalid (broken) references.
    if find_broken_references:
        image_files.find("images/C")                       # (2)
        image_refs.sort_out_valid(image_files)             # (3)
        image_refs.report()

    # find all image files in "images/LANG", then
    # remove intersection of image references and image files;
    # the result is the list of orphaned image files.
    if find_orphaned_images:
        img_dirs = ("images/" + lang for lang in languages)
        for imgdir in img_dirs:
            # if possible, avoid searching in "images/C" twice
            if not (imgdir == image_files.imageroot):
                image_files.find(imgdir)                   # (2)
            image_files.sort_out_valid(image_refs)         # (4)
            image_files.report()


def usage(exitcode=0, msg=""):
    """Help the user."""
    if exitcode > 0 or msg:
        sys.stderr.write("Error: %s\n" % msg)
        sys.stderr.write("(try \"%s --help\")\n" % sys.argv[0])
    else:
        sys.stdout.write ( """\
validate_references - validates image file references in DocBook xml files

Copyright (C) 2006-2007 Róman Joost,
          (C) 2008-2012 Róman Joost, Ulf-D. Ehlert

Usage: validate_references.py [options] [language ...]

    options:
        -h | --help          this help
        -v | --verbose       verbose; may be provided twice (-vv)
        -r | --root <dir>    specify the gimp-help root directory
        -x | --xmldir <dir>  specify the XML files directory
        -o | --orphaned      check for orphaned image files
        -b | --broken        check for broken links (default action)
\n""")
    sys.exit(exitcode)


def char_if(char, cond):
    if cond:
        return char
    else:
        return ""


if __name__ == "__main__":
    main()
