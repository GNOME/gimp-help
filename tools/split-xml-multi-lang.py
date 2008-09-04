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
#import getopt
import optparse
import re
import xml.dom.minidom
import logging
import profile

# Configure logging package
logging.basicConfig(level=logging.INFO, format="%(levelname)-8s %(message)s")
Logger = logging.getLogger("splitxml")

# these tags are considered NOT final
sections   = ('sect1', 'sect2', 'sect3', 'sect4', 'section')
sectinfos  = ('sect2info', 'sect1info', 'sect3info', 'sect4info')
notes      = ('warning', 'caution', 'important', 'tip', 'note')
containers = ('figure', 'caption', 'revhistory', 'formalpara')
nobjects   = ('textobject', 'mediaobject', 'screenshot')
lists      = ('itemizedlist', 'orderedlist', 'variablelist',
              'segmentedlist', 'simplelist', 'calloutlist')
items      = ('varlistentry', 'listitem')
# these tags are considered final
paras      = ('para', 'simpara')
leafs      = ('phrase', 'revision', 'indexterm')
fobjects   = ('imageobject',) 

non_final_nodes = sections + sectinfos + notes + containers + \
                  nobjects + lists + items
final_nodes     = paras + leafs + fobjects


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
        self.logger = logging.getLogger("splitxml.node")
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


################################################################
#        Multi-language XML document                           #
################################################################

class MultiLangDoc(object):
    """Multi-language XML document

    This class provides methods to read/parse a multi-lang XML source
    file, to split the document into single-language documents, and to
    print these documents as single-language XML files.
    """
    def __init__(self, filename, destdir = None):
        """Multi-language XML document"""

        self.filename = filename
        self.destdir  = destdir

        self.logger = logging.getLogger("splitxml.doc")
        self.logger.info("Parsing %s" % filename)

        self.doc = xml.dom.minidom.parse(filename)
        self.dest = {}
        self.seqnum = 0

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
        self.destdir = destdir
        filename = os.path.basename(self.filename)

        for lang in self.languages:
            destdir = self.destdir.replace(langdir_template, lang)
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
        and constructs single language documents while processing the
        document recursively starting with the document element,
        """
        self.logger.debug("process(%s)" % str(self.doc.documentElement.nodeName))
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
                    clone = child.cloneNode(False)
                    self.dest[lang].appendChild(clone)
            else:
                if not 'en' in self.get_langs(child):
                    self.logger.critical("No English document element")
                    sys.exit(74)
                source = self.vectorize(child)
                clones = self.append_clones(source, self.dest, False)
                return self.split(child, source, clones)

        # Never reached, since "parse(filename)" catched it...
        raise RuntimeError("Oops!? No document element found!?")

    def split(self, elem, source, dest):
        """Split a multi-language XML element

        This method does the real work when processing the
        document tree.
        TODO: describe the algorithm(?)
        """
        self.logger.debug("split(%s)" % (elem.nodeName))
        assert source and dest
        self.seqnum += 1

        for child in elem.childNodes:

            # (1) skip this node if we don't need it (e.g. comments)
            if self.ignore(child):
                self.logger.debug("ignoring %s %s" % (child.nodeType, child.nodeName))

            # (2) append non-empty text nodes to the destination nodes
            elif self.text(child):
                if child.nodeValue.strip():
                    # we should never be here, the (parent) node
                    # should be final then...
                    self.logger.warn("TEXT in %s" % elem.nodeName)
                    for lang in self.languages:
                        dest[lang].appendChild(child)

            # (3) skip every non-English element
            elif self.skip(child):
                #self.logger.debug("skipping %s %s" % (child.nodeType, child.nodeName))
                pass

            # (4) at last, handle non-trivial cases...
            else:
                assert child.nodeType == child.ELEMENT_NODE \
                   and 'en' in self.get_langs(child)

                # for every language, find the respective node
                copies = self.vectorize(child)	# no clones

                # (4a) append recursively (localized) clones of nodes we don't
                # need/want to process any further (para, phrase, etc.)
                if self.final(child):
                    self.logger.debug("adding cloned final %s" % child.nodeName)
                    clones = self.append_clones(copies, dest, True)
                # (4b) append non-recursively (localized) clones of nodes and
                # process child recursively (sect[1-4], note, etc.)
                else:
                    self.logger.debug("adding cloned %s" % child.nodeName)
                    clones = self.append_clones(copies, dest, False)
                    self.split(child, copies, clones)

        return dest

    def vectorize(self, elem):
        """Make a set of corresponding nodes from an element node

        This method gets an element with no 'lang' attribute or a 'lang'
        attribute containing "en" (English language) and returns a set of
        corresponding nodes for all languages (translations). If there is
        no translation for some language, the original input node (i.e.
        'en') will be returned.
        """
        self.logger.debug("vectorize(%s)" % elem.nodeName)

        # mark element as "seen"
        elem.setAttribute("seqnum", str(self.seqnum))

        # handle element's "lang" attribute
        nodes = dict([(lang, elem) for lang in self.get_langs(elem)])
        assert nodes.has_key('en')

        if len(nodes) == len(self.languages):
            return nodes

        # Algorithm:
        #   (1) create set of *all* sibling elements of the same type/name
        #     (1a) filter out elements which has already been used (with
        #          "seqnum" attribute) -- done in ".get_siblings()"
        #   (2) select the first matching element for every language
        #   (3) select input element for every missing language

        siblings = self.get_siblings(elem)
        try:
            for sibling in siblings:
                sibling_languages = self.get_langs(sibling)
                for lang in sibling_languages:
                    if not nodes.has_key(lang):
                        nodes[lang] = sibling
                        sibling.setAttribute("seqnum", str(self.seqnum))
                        if len(nodes) == len(self.languages):
                            raise StopIteration  # TODO: user-defined exception(s)
        except StopIteration:
            pass

        for lang in (k for k in self.languages if not nodes.has_key(k)):
            nodes[lang] = elem
        assert len(nodes) == len(self.languages)

        return nodes

    def get_siblings(self, element):
        """Get a list of all previous and following siblings
        of the same type as element

        Elements with a "seqnum" attribute will be removed from the list.
        """
        siblings = []
        this = element
        while this.previousSibling: this = this.previousSibling
        while this:
            # TODO: add test for 'lang' attribute here(!?)
            if this.nodeType == element.nodeType \
            and this.nodeName == element.nodeName \
            and not this.isSameNode(element):
                if not (this.hasAttributes() and
                        this.attributes.get("seqnum")):
                    siblings.append(this)
            this = this.nextSibling
        return siblings

    def append_clones(self, element, parent, recursive):
        """Clone elements and append them to parent nodes

        Returns a dict of (lang,clone) pairs for a specified
        dict of (lang,element) pairs.
        """
        clones = dict([(key, element[key].cloneNode(recursive))
                       for key in element])
        for lang in clones:
            clones[lang].removeAttribute("seqnum")
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
        if name in ('title', 'term'):
            return self.has_nonempty_text(node)
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

        Returnes all languages if element does not have a
        "lang" attribute.
        """
        #if elem.hasAttributes():
        #    lang_attr = elem.attributes.get("lang")
        #else:
        #    lang_attr = None
        try:
            lang_attr = elem.attributes.get("lang")
        except:
            lang_attr = None

        if lang_attr:
            # this is an Attr(Node) instance,
            # its value is a string (e.g. "en;de;fr") or None
            langs = lang_attr.value.strip(';').split(';')
            if all:
                return langs
            else:
                return [k for k in langs if k in self.languages]
        else:
            return self.languages


################################################################
#        main program                                          #
################################################################

def main():
    """Read command line and then take off"""

    logger = logging.getLogger("splitxml")

    languages = ('de', 'es', 'fr', 'it', 'no', 'ru')

    # parse command line

    usage = "usage: %prog [options] [FILE [DIR]]"
    version = "%prog 0.2"
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
        else:
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


# Main program start
if __name__ == '__main__':
    if "--profile" in  sys.argv:
        profile.run("main()")
    else:
        main()
# pydoc doesn't like the following "raise" statement
#else:
#    raise NotImplementedError
