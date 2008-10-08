#!/usr/bin/env python
# _*_ coding: utf8 -*_
"""
 Convert multi-lang XML files

 Copyright (C) 2008 The GIMP Documentation Team

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
"""


import sys
import os
import os.path
import codecs
import optparse
import re
import xml.dom.minidom
import logging
import profile

import unittest
import doctest


# Configure logging package
logging.basicConfig(level=logging.INFO, format="%(levelname)-8s %(message)s")
Logger = logging.getLogger("splitxml")

# Constants
RECURSIVE = True
NONRECURSIVE = False

# these tags are considered NOT FINAL
sections   = ('sect1', 'sect2', 'sect3', 'sect4', 'section', 'bibliodiv',
              'book', 'part', 'chapter', 'preface', 'legalnotice')
sectinfos  = ('sect2info', 'sect1info', 'sect3info', 'sect4info',
              'bookinfo', 'appendixinfo')
notes      = ('warning', 'caution', 'important', 'tip', 'note')
containers = ('figure', 'caption', 'revhistory', 'formalpara', 'equation',
              'informalequation', 'informalfigure', 'example')
# XXX: making 'inlinemediaobject' "final" should also work
nobjects   = ('textobject', 'mediaobject', 'screenshot', 'inlinemediaobject')
lists      = ('itemizedlist', 'orderedlist', 'variablelist',
              'segmentedlist', 'simplelist', 'calloutlist', 'informaltable')
tables     = ('table', 'tgroup', 'thead', 'tbody', 'row', 'entry')
items      = ('varlistentry', 'listitem', 'seglistitem',
              'glossentry', 'glossdef', 'biblioentry')

# these tags are considered FINAL
paras      = ('para', 'simpara', 'programlisting', 'blockquote')
leafs      = ('phrase', 'revision', 'indexterm', 'graphic', 'alt', 'seg',
              'anchor')
fobjects   = ('imageobject',)
fgui       = ('guiicon', 'guimenuitem')
keys       = ('keycap', 'keycombo')
misc       = ('member', 'releaseinfo', 'isbn', 'author', 'copyright',
              'publisher', 'abbrev', 'toc', 'index')

# these tags are considered FINAL if they contain text
text_final_nodes = ('title', 'term', 'segtitle', 'subtitle', 'glossterm')

non_final_nodes = sections + sectinfos + notes + containers + \
                  nobjects + lists + tables + items
final_nodes     = paras + leafs + fobjects + fgui + keys + misc


# >>>>>>>>>>>>>>>> not used >>>>>>>>>>>>>>>>
################################################################
#        XML node                                              #
################################################################

# TODO: try to implement this class, this should make
# the code more readable (and logical), e.g.
#     some_node.is_whatever()
# instead of
#     self.whatever(some_node)

class XmlNode(object):
    """FIXME"""

    def __init__(self, node):
        self.logger = logging.getLogger("splitxml")
        assert isinstance(node, xml.dom.minidom.Node)
        self._node = node

    def get_children(self):
        """FIXME

        This method is just an idea, it has never been used or tested...
        """
        if self._node.childNodes:
            return [XmlNode(child) for child in self._node.childNodes]
        else:
            return []

    def type(self):
        """Get the node type"""
        return self._node.nodeType

    def is_text(self):
        """Whether or not a node is a text node.
        """
        return self.type() == xml.dom.minidom.Node.TEXT_NODE

    def ignore(self):
        """Whether or not a node is to be ignored.

        This method is used to skip comments etc.
        """
        return self._node.nodeType in (xml.dom.minidom.Node.COMMENT_NODE,) \
            or self._node.nodeName in ('xi:include',)
# <<<<<<<<<<<<<<<< not used <<<<<<<<<<<<<<<<


################################################################
#        Multi-language XML document                           #
################################################################

class MultiLangDoc(object):
    """Multi-language XML document

    This class provides methods to read/parse a multi-lang XML source
    file, to split the document into single-language documents, and to
    print these documents as single-language XML files.
    """
    def __init__(self, filename):
        """Multi-language XML document"""

        self.filename = filename
        self.dest = {}	# destination documents

        self.logger = logging.getLogger("splitxml")
        self.logger.info("Parsing %s" % filename)

        try:
            self.doc = xml.dom.minidom.parse(filename)
        except IOError, err:
            self.logger.error(err)
            sys.exit(66)

    def printfiles(self, destdir):
        """Print resulting documents to the respective output files"""

        assert destdir
        langdir_template = '*'
        destdir = destdir.rstrip('/')
        if destdir.find(langdir_template) < 0:
            if destdir:
                destdir = os.path.join(destdir, langdir_template)
            else:
                destdir = langdir_template
        destdir_template = destdir
        filename = os.path.basename(self.filename)

        for lang in self.languages:
            destdir = destdir_template.replace(langdir_template, lang)
            if not os.path.isdir(destdir):
                os.makedirs(destdir, 0755)
            destfile = os.path.join(destdir, filename)
            output = codecs.open(destfile, 'w', "UTF-8")
            self.logger.info("Writing %s" % destfile)
            self.dest[lang].writexml(output, encoding="UTF-8")
            output.close()
            self.dest[lang].unlink()

    def process(self, languages):
        """Split a multi-language XML document

        This method creates XML document (root) nodes for every language,
        then constructs single-language documents while processing the
        document recursively, starting with the document element,
        """
        self.logger.debug("process(%s)" % self.doc.documentElement.nodeName)
        self.languages = languages
        if 'en' not in languages:
            self.languages.insert(0, "en")

        impl = xml.dom.minidom.getDOMImplementation()
        for lang in self.languages:
            self.dest[lang] = impl.createDocument(None, None, None)
            dtd = impl.createDocumentType(
                    self.doc.documentElement.nodeName,
                    "-//OASIS//DTD DocBook XML V4.3//EN",
                    "http://www.docbook.org/xml/4.3/docbookx.dtd")
            self.dest[lang].encoding = "UTF-8"
            self.dest[lang].appendChild(dtd)

        for child in self.doc.childNodes:
            if child.nodeType == xml.dom.minidom.Node.DOCUMENT_TYPE_NODE:
                continue
            if child.nodeType != xml.dom.minidom.Node.ELEMENT_NODE:
                for lang in self.languages:
                    clone = child.cloneNode(NONRECURSIVE)
                    self.dest[lang].appendChild(clone)
            else:
                # This is the document element (aka root element)
                try:
                    self.doc_languages = self.get_langs(child)
                    if not 'en' in self.doc_languages:
                        raise RuntimeError("No English document element")
                except (AttributeError, RuntimeError):
                    #sys.exit("No English document element")
                    self.logger.error("No English document element")
                    sys.exit(74)
                # Now we know that the document element has a valid "lang"
                # attribute, and so has every element (via parent nodes).
                self.seqnum = 0
                child.setAttribute("seqnum", str(self.seqnum))
                clones = self.append_clones(child, self.dest, NONRECURSIVE)
                return self.split(child, clones)

        # Never reached, since "parse(filename)" catched it...
        raise RuntimeError("Oops!? No document element found!?")

    def split(self, elem, dest):
        """Split a multi-language XML element

        This is the main routine for traversing the document tree. For
        every child element (with lang="en") of the specified "elem" node,
        this function searches the corresponding nodes containing
        translations of that child. Then it appends the nodes to the
        respective nodes of the destination vector and, if necessary,
        traverses the child element calling itself recursively.

        The "elem" argument may also be a set of different element nodes
        for every language, then searching will be applied to different
        sets of child nodes for every language.
        """
        if isinstance(elem, dict):
            parentnodes = elem
            elem = parentnodes['en']
        else:
            parentnodes = None

        # dest is a cloned vector of elem:
        assert elem.nodeName == dest['en'].nodeName

        self.logger.debug("split(%s)" % (elem.nodeName))

        for child in elem.childNodes:

            # (1) skip this node if we don't need it (e.g. comments)
            if self.ignore(child):
                pass

            # (2) append non-empty text nodes to the destination nodes
            elif self.text(child):
                if child.nodeValue.strip():
                    # we should never be here, the (parent) node
                    # should be final then...
                    logger.warn("TEXT in %s: <%s>" % \
                        (elem.nodeName, child.nodeValue.strip()))
                    # XXX: better just skip this text?
                    for lang in self.languages:
                        dest[lang].appendChild(child.cloneNode(NONRECURSIVE))
                elif self.logger.isEnabledFor(logging.DEBUG):
                    for lang in self.languages:
                        dest[lang].appendChild(child.cloneNode(NONRECURSIVE))

            # (3) skip every non-English element
            elif self.skip(child):
                pass

            # (4) at last, handle non-trivial cases...
            else:
                assert child.nodeType == child.ELEMENT_NODE \
                   and 'en' in self.get_langs(child)

                # Find the corresponding node for every language. Here
                # it makes a difference if we use a set of (different)
                # parent nodes for every language or just one single
                # element.
                copies = self.vectorize(child, parentnodes)

                # (4a) append recursively localized clones of nodes we don't
                # need/want to process any further (para, phrase, etc.)
                if self.final(child):
                    self.logger.debug("split(%s) --> adding %s (final)" % \
                            (elem.nodeName, child.nodeName))
                    clones = self.append_clones(copies, dest, RECURSIVE)
                # (4b) append non-recursively localized clones of nodes and
                # then traverse child nodes recursively (sect[1-4], note, etc.)
                else:
                    self.logger.debug("split(%s) --> adding %s" % \
                            (elem.nodeName, child.nodeName))
                    clones = self.append_clones(copies, dest, NONRECURSIVE)
                    self.split(copies, clones)

        return dest

    def vectorize(self, elem, parents=None):
        """Make a set of corresponding nodes from an element node

        This method gets an element with no 'lang' attribute or a 'lang'
        attribute containing "en" (English language) and returns a set of
        corresponding nodes for all languages (translations). If there is
        no translation for some language, the original input node (i.e.
        'en') will be returned.

        If every element of the resulting vector is the same node (i.e.
        the same as "elem"), the result will be reduced to this element.
        """
        if isinstance(parents, dict):
            self.logger.debug("vectorize(%s in %s)" % \
                (elem.nodeName, parents['en'].nodeName))
        else:
            self.logger.debug("vectorize(%s)" % elem.nodeName)

        assert not isinstance(parents, dict) or elem.parentNode == parents['en']

        # Mark element as "seen"
        self.seqnum += 1
        elem.setAttribute("seqnum", str(self.seqnum))

        # Trivial case: the element contains all languages
        if len(self.get_langs(elem)) == len(self.languages):
            return elem

        # Typical (and simple) case: we are working on the original source
        # tree, the nodes of the resulting vector will have the same
        # parent node.
        if not parents:

            # copy element for every element language
            nodes = dict([(lang, elem) for lang in self.get_langs(elem)])
            assert nodes.has_key('en')
            assert len(nodes) != len(self.languages)

            # TODO: describe algorithm

            siblings = self.get_siblings(elem)
            found = 0

            for sibl in siblings:
                langs = self.get_langs(sibl)
                new_langs = [k for k in langs if k not in nodes]
                if not self.final(elem):
                    if len(langs) > len(new_langs):
                        break
                elif not new_langs:
                    continue
                sibl.setAttribute("seqnum", str(self.seqnum))
                for lang in new_langs:
                    nodes[lang] = sibl
                    found += 1
                if len(nodes) == len(self.languages):
                    return nodes

            for lang in (k for k in self.languages if not nodes.has_key(k)):
                nodes[lang] = elem
            assert len(nodes) == len(self.languages)

            if found:
                # nodes[x] != elem for one ore more x in self.languages
                return nodes
            else:
                # nodes[x] == elem for every x in self.languages
                return elem

        # Special case: for every language (assuming there is a tranlation
        # for this language, of course) we are working in separate subtree
        # of the original source tree, and the nodes of the resulting
        # vector may have different parent nodes.
        else:
            assert elem.parentNode == parents['en']
            assert not self.final(elem.parentNode)
            nodes = dict([(lang, elem) for lang in self.get_langs(elem)])
            assert nodes.has_key('en')
            assert len(nodes) != len(self.languages)

            # TODO: describe algorithm

            for lang in parents:
                if lang in nodes: continue

                children = (child for child in parents[lang].childNodes
                            if child.nodeType == child.ELEMENT_NODE
                            if child.nodeName == elem.nodeName
                            if not child.getAttribute("seqnum"))

                for child in children:
                    child_langs = self.get_langs(child)
                    new_langs = [k for k in child_langs if k not in nodes]
                    if not new_langs or lang not in new_langs:
                        continue
                    child.setAttribute("seqnum", str(self.seqnum))
                    for lang in new_langs:
                        assert child.parentNode.isSameNode(parents[lang])
                        nodes[lang] = child
                    if len(nodes) == len(self.languages):
                        return nodes
                    break

            for lang in (k for k in self.languages if not k in nodes):
                nodes[lang] = elem

            assert len(nodes) == len(self.languages)
            return nodes


    def get_siblings(self, element):
        """Get a list of all previous and following siblings
        of the same type as element

        Elements with a "seqnum" attribute will be removed from the list.
        """
        # The English element is not necessarily the first one,
        # so we have to check every sibling:
        return [sibl for sibl in element.parentNode.childNodes
                         if sibl.nodeType == element.nodeType
                         if sibl.nodeName == element.nodeName
                         if not sibl.isSameNode(element)
                         if not sibl.getAttribute("seqnum")]

    def append_clones(self, element, parent, recursive):
        """Clone element(s) and append them to parent nodes

        Element is either a single element (which means it's the
        same element for every language) or a language-indexed
        vector of elements.

        The method returns a language-indexed node vector.
        """
        if isinstance(element, dict):
            assert len(element) == len(self.languages)
            clones = dict([(key, element[key].cloneNode(recursive))
                          for key in element])
        else:
            clones = dict([(key, element.cloneNode(recursive))
                          for key in self.languages])

        if not self.logger.isEnabledFor(logging.DEBUG):
            if clones['en'].hasAttribute("seqnum"):
                for lang in clones:
                    clones[lang].removeAttribute("seqnum")
            else:
                # Should never happen...
                self.logger.warn("%s without seqnum" %  clones['en'].nodeName)
            for lang in clones:
                if clones[lang].hasAttribute("lang"):
                    clones[lang].removeAttribute("lang")

        for lang in clones:
            parent[lang].appendChild(clones[lang])
        return clones

    def final(self, node):
        """Whether or not a node is a final node.

        Final nodes will be cloned recursively and added to the
        destination tree (more precisely: the localized nodes
        will be cloned).

        Non-final (localized) nodes will be cloned non-recursively
        and also added to the destination tree, then they will be
        processed recursively until a final node is reached.
        """
        name = node.nodeName

        # Simple(?) cases
        if name in non_final_nodes:
            return False
        elif name in final_nodes:
            return True

        # Special cases
        # XXX: Hmm, what would happen if we used this test
        #      for *every* node?
        elif name in text_final_nodes:
            return self.has_nonempty_text(node)
        elif name in ('procedure', 'step'):
            return self.get_langs(node) == 1
        else:
            self.logger.warn("don't know what to do with '%s', assuming final" % name)
            return True


    def ignore(self, node):
        """Whether or not a node is to be ignored.

        This method is used to skip comments etc.
        """
        return node.nodeType in (node.COMMENT_NODE,) \
            or node.nodeName in ('xi:include',)

    def text(self, node):
        """Whether or not a node is a text node."""
        return node.nodeType == xml.dom.Node.TEXT_NODE

    def has_nonempty_text(self, node):
        """Whether or not a node has a non-empty text node."""
        assert node.nodeType == xml.dom.Node.ELEMENT_NODE

        for child in node.childNodes:
            if child.nodeType == xml.dom.Node.TEXT_NODE \
            and child.nodeValue.strip():
                return True
        return False

    def skip(self, node):
        """Whether or not a node is to be skipped.

        This method is used to filter out non-English element nodes.
        """
        if node.nodeType != node.ELEMENT_NODE:
            return True
        else:
            langs = self.get_langs(node)
            return 'en' not in langs
            #return not langs or 'en' not in langs

    def get_langs(self, elem, all=False):
        """Get a list of languages specified by the "lang"
        attribute for a given element

        If that element does not have a "lang" attribute,
        the parent nodes will be searched until an attribute
        is found. (The document/root element is guaranteed to
        have a "lang" attribute...).
        """
        # get value as string (e.g. "en;de;fr")
        langs = elem.getAttribute("lang")
        while not langs:
            elem = elem.parentNode
            langs = elem.getAttribute("lang")
        langs = langs.strip(';').split(';')
        # use "set(langs)" since "langs" may contain identical entries:
        return [lang for lang in set(langs) if lang in self.languages]


################################################################
#        main program                                          #
################################################################

def main():
    """Read command line and then take off"""

    logger = logging.getLogger("splitxml")

    languages = ('de', 'es', 'fr', 'it', 'no', 'ru')

    # parse command line

    usage = "usage: %prog [options] [FILE [DIR]]"
    version = "%prog 0.6 2008-10-08"
    cmdline = optparse.OptionParser(usage=usage, version=version)

    cmdline.set_defaults(languages= ",".join(languages))
    cmdline.add_option("--debug", dest="debug",
        action="store_true", default=False,
        help="produce some more or less useful debugging messages")
    cmdline.add_option("--profile", dest="profile",
        action="store_true", default=False,
        help="print a  profiling report from the script execution")
    cmdline.add_option("-l", "--lang", dest="languages", metavar="LANG",
        help="comma-separated list of languages, "
             "'en' will be added automatically; "
             "defaults to '" + ",".join(languages) + "'")
    cmdline.add_option("-f", "--file", dest="filename", metavar="FILE",
        help="input file (required), a multi-lang XML file (FILE may also "
             "be specified as the first command-line argument)")
    cmdline.add_option("-d", "--dest", dest="destdir", metavar="DIR",
        help="output directory (required); if DIR contains a single '*', "
             "this will be replaced by the respective language, otherwise "
             "subdirs DIR/xx, DIR/yy, etc. will be used for output (DIR "
             "may also be specified as the second command-line argument)")

    (options, args) = cmdline.parse_args()

    if args:
        options.filename = args[0]
        if len(args) == 2:
            options.destdir = args[1]
        elif len(args) > 2:
            cmdline.error("too many arguments")

    if not options.filename:
        cmdline.error("no input file specified")
    if not options.destdir:
        cmdline.error("no output directory specified")

    if options.debug:
        Logger.setLevel(logging.DEBUG)

    options.languages = re.split('[, ]+', options.languages)
    try: options.languages.remove('en')
    except ValueError: pass
    options.languages.insert(0, 'en')

    doc = MultiLangDoc(options.filename)
    doc.process(options.languages)
    doc.printfiles(options.destdir)


def runtests():
    """Runs registered automated tests."""
    testrunner = unittest.TextTestRunner()
    suite = unittest.TestSuite()
    suite.addTest(
        doctest.DocFileSuite("split_xml_multi_lang.test",
                             optionflags = doctest.NORMALIZE_WHITESPACE |
                                doctest.ELLIPSIS |
                                doctest.REPORT_NDIFF)
    )
    testrunner.run(suite)


# Main program start
if __name__ == '__main__':
    if "--profile" in sys.argv:
        profile.run("main()")
    if "--test" in sys.argv:
        runtests()
    else:
        main()
