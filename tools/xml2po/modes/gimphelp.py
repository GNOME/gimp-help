# -*- coding: utf-8 -*-
# Copyright (c) 2004, 2005, 2006 Danilo Segan <danilo@gnome.org>.
#
# This file is part of xml2po.
#
# xml2po is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# xml2po is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with xml2po; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# Adapted for the GIMP Manual's build system 2009-12-14
# (c) 2009 The GIMP Documentation Team
#

import re
import libxml2
import os
import sys
try:
    # Hashlib is new in Python 2.5
    from hashlib import md5 as md5_new
except ImportError:
    from md5 import new as md5_new

from .docbook import docbookXmlMode

class gimphelpXmlMode(docbookXmlMode):
    """Class for special handling of gimp-help DocBook document types.

    It sets lang attribute on article elements, and adds translators
    to articleinfo/copyright."""
    def __init__(self):
        try:
            super(gimphelpXmlMode, self).__init__()
        except TypeError:
            self.lists = ['itemizedlist', 'orderedlist', 'variablelist',
                          'segmentedlist', 'simplelist', 'calloutlist', 'varlistentry' ]
            self.objects = [ 'figure', 'textobject', 'imageobject', 'mediaobject',
                             'screenshot', 'author', 'personname', 'firstname', 'surname',
                             'othername', 'email' ]

    def getTreatedAttributes(self):
        "Return array of tag attributes which content is to be translated"
        return ['xreflabel']

    def _output_images(self, node, msg):
        assert node
        if node.type == 'element' and node.name == 'imagedata':
            # Use .fileref to construct new message
            attr = node.prop("fileref")
            if attr:
                assert attr.startswith("images/")
                origimagepath = attr
                for subdir in ("C", "common"):
                    imagepath = origimagepath.replace("/", "/%s/" % subdir, 1)
                    # I need to search files relatively to the source directory.
                    scriptdir = os.path.dirname(os.path.realpath(__file__))
                    imagepath = os.path.join(scriptdir, '../../../', imagepath)
                    if os.path.exists(imagepath):
                        hash = self._md5_for_file(imagepath)
                        break
                else:
                    hash = "THIS FILE DOESN'T EXIST"
                    sys.stderr.write("Warning: image file '%s' not found.\n" %
                                     origimagepath)
                msg.outputMessage(
                    "@@image: '%s'; md5=%s" % (origimagepath, hash),
                    node.lineNo(),
                    "When image changes, this message will be marked fuzzy "
                    "or untranslated for you.\nIt doesn't matter what you "
                    "translate it to: it's not used at all.")
        elif node and node.children:
            child = node.children
            while child:
                self._output_images(child,msg)
                child = child.next

    def preProcessXml(self, doc, msg):
        """Add additional messages of interest here."""
        root = doc.getRootElement()
        self._output_images(root,msg)

# Perform some tests when ran standalone
if __name__ == '__main__':
    test = gimphelpXmlMode()
    print("Ignored tags       : " + repr(test.getIgnoredTags()))
    print("Final tags         : " + repr(test.getFinalTags()))
    print("Space-preserve tags: " + repr(test.getSpacePreserveTags()))

    print("Credits from string: '%s'" % test.getStringForTranslators())
    print("Explanation for credits:\n\t'%s'" % test.getCommentForTranslators())

