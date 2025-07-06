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

# Basic default class; inherit from it to construct other special-handling classes
#

import sys
import re
from lxml import etree

class basicXmlMode:
    """Abstract class for special handling of document types."""

    def xml_qname (self, node):
        qname = "<tag is not a string>"
        if isinstance(node.tag, str):
            qname = etree.QName(node.tag).localname
        if node.prefix is not None:
            qname = node.prefix + ':' + qname
        return qname

    def getIgnoredTags(self):
        "Returns array of tags to be ignored."
        return ['itemizedlist', 'orderedlist', 'variablelist', 'varlistentry']

    def getFinalTags(self):
        "Returns array of tags to be considered 'final'."
        return ['para', 'title', 'releaseinfo', 'revnumber',
                'date', 'itemizedlist', 'orderedlist',
                'variablelist', 'varlistentry', 'term']

    def isFinalNode(self, node):
        #node.type =='text' or not node.children or
        ###if node.type == 'element' and node.name in self.getFinalTags():
        qname = self.xml_qname(node)
        text = "<not a text object>"
        if isinstance(node.text, str):
            text = node.text.strip()
        print(f"IsFinalNode for {qname}, tag: {node.tag} attrib: {node.attrib}, text: [{text}]", file=sys.stderr)

        if etree.iselement(node) and self.xml_qname(node) in self.getFinalTags():
            print("\t--> Element is present in list of final tags...", file=sys.stderr)
            return True
        ###elif node.children:
        ###else: ###elif len(node) > 0 or node.text:
        elif len(node) > 0 or node.text:
            final_children = True
            has_children   = False
            ###child = node.children
            ###while child and final_children:
            ###    if not child.isBlankNode() and child.type != 'comment' and not self.isFinalNode(child):
            ###        final_children = False
            ###    child = child.next
            print(f"IsFinalNode: check children", file=sys.stderr)
            for child in node.iterchildren():
                name = self.xml_qname(child)
                text = "<not a text object>"
                if isinstance(node.text, str):
                    text = node.text.strip()
                print(f"\t--> isFinalNode: handle child {name}... with text [{text}]", file=sys.stderr)
                has_children = True
                ###if not child.isBlankNode() and child.type != 'comment' and not self.isFinalNode(child):
                #empty_text = node.text is None or re.fullmatch(r'\s+', node.text) is not None
                #empty_tail = node.tail is None or re.fullmatch(r'\s+', node.tail) is not None
                empty_text = node.text is None or node.text.strip() == ""
                empty_tail = node.tail is None or node.tail.strip() == ""
                #print(f"\t empty text: {empty_text}, tail: {empty_tail}", file=sys.stderr)
                ###if not (node.text is None or not re.fullmatch(r'\s+', node.text)) and not node.tail is None and not self.isFinalNode(child):
                ###if not self.isFinalNode(child):
                ###    print(f"\t--> Text of not final child: [{node.text}]...", file=sys.stderr)
                ###    final_children = False
                ###    break
                if not empty_text or not empty_tail or not self.isFinalNode(child):
                    #print(f"\t--> Text of not final child: [{node.text.strip()}]...", file=sys.stderr)
                    final_children = False
                    break
                elif empty_text:
                    print("\t--> isFinalNode: no text...", file=sys.stderr)
                elif empty_tail:
                    print(f"\t--> isFinalNode: no tail..., text is [[{node.text.strip()}]]", file=sys.stderr)
                else:
                    print("\t--> isFinalNode: no final node...", file=sys.stderr)
            print(f"IsFinalNode: children of {qname} DONE", file=sys.stderr)
            if not has_children:
                #print("\t--> NO children...", file=sys.stderr)
                return False
            if final_children:
                print("\t--> isFinalNode: final child YES.", file=sys.stderr)
                return True
            else:
                print("\t--> isFinalNode: NOT final child...", file=sys.stderr)
        else:
            print("\t--> isFinalNode: empty node...", file=sys.stderr)
        #print("\t--> XXX...", file=sys.stderr)
        return False

    def getSpacePreserveTags(self):
        "Returns array of tags in which spaces are to be preserved."
        return []

    def getTreatedAttributes(self):
        "Returns array of tag attributes which content is to be translated"
        return []

    def preProcessXml(self, doc, msg):
        "Preprocess a document and perhaps adds some messages."
        print("<no preprocessing done for basic mode>", file=sys.stderr)
        pass

    def postProcessXmlTranslation(self, doc, language, translators):
        """Sets a language and translators in "doc" tree.

        "translators" is a string consisted of translator credits.
        "language" is a simple string.
        "doc" is a libxml2.xmlDoc instance."""
        pass

    def getStringForTranslators(self):
        """Returns None or a string to be added to PO files.

        Common example is 'translator-credits'."""
        return None

    def getCommentForTranslators(self):
        """Returns a comment to be added next to string for crediting translators.

        It should explain the format of the string provided by getStringForTranslators()."""
        return None
