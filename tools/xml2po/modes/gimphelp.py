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
# (c) 2009 The GIMP Documenation Team
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

from docbook import docbookXmlMode

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
                             'screenshot' ]

# Perform some tests when ran standalone
if __name__ == '__main__':
    test = gimphelpXmlMode()
    print "Ignored tags       : " + repr(test.getIgnoredTags())
    print "Final tags         : " + repr(test.getFinalTags())
    print "Space-preserve tags: " + repr(test.getSpacePreserveTags())

    print "Credits from string: '%s'" % test.getStringForTranslators()
    print "Explanation for credits:\n\t'%s'" % test.getCommentForTranslators()

