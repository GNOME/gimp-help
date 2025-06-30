# -*- encoding: utf-8 -*-
# Copyright (c) 2004, 2005, 2006 Danilo Šegan <danilo@gnome.org>.
# Copyright (c) 2009 Claude Paroz <claude@2xlibre.net>.
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
import os
import sys
import re
import subprocess
import tempfile
import gettext
from lxml import etree
#import lxml
#import lxml.etree

DEBUG_VERBOSITY = 0
NULL_STRING = '/dev/null'
if not os.path.exists('/dev/null'): NULL_STRING = 'NUL'


def xml_qname (node):
    qname = etree.QName(node.tag).localname
    if node.prefix is not None:
        qname = node.prefix + ':' + qname
    return qname


# Utility functions
def escapePoString(text):
    return text.replace('\\','\\\\').replace('"', "\\\"").replace("\n","\\n").replace("\t","\\t")

def unEscapePoString(text):
    return text.replace('\\"', '"').replace('\\\\','\\')

class NoneTranslations:
    def gettext(self, message):
        return None

    def lgettext(self, message):
        return None

    def ngettext(self, msgid1, msgid2, n):
        return None

    def lngettext(self, msgid1, msgid2, n):
        return None

    def ugettext(self, message):
        return None

    def ungettext(self, msgid1, msgid2, n):
        return None

class MessageOutput:
    """ Class to abstract po/pot file """
    def __init__(self, app):
        self.app = app
        self.messages = []
        self.comments = {}
        self.linenos = {}
        self.nowrap = {}
        self.translations = []
        self.do_translations = False
        self.output_msgstr = False # this is msgid mode for outputMessage; True is for msgstr mode

    def translationsFollow(self):
        """Indicate that what follows are translations."""
        self.output_msgstr = True

    def setFilename(self, filename):
        self.filename = filename

    def outputMessage(self, text, lineno = 0, comment = None, spacepreserve = False, tag = None):
        """Adds a string to the list of messages."""
        if (text.strip() != ''):
            t = escapePoString(text)
            if self.output_msgstr:
                self.translations.append(t)
                return

            if self.do_translations or (not t in self.messages):
                self.messages.append(t)
                if spacepreserve:
                    self.nowrap[t] = True
                if t in self.linenos.keys():
                    self.linenos[t].append((self.filename, tag, lineno))
                else:
                    self.linenos[t] = [ (self.filename, tag, lineno) ]
                if (not self.do_translations) and comment and not t in self.comments:
                    self.comments[t] = comment
            else:
                if t in self.linenos.keys():
                    self.linenos[t].append((self.filename, tag, lineno))
                else:
                    self.linenos[t] = [ (self.filename, tag, lineno) ]
                if comment and not t in self.comments:
                    self.comments[t] = comment

    def outputHeader(self, out):
        from datetime import datetime
        # Using time.strftime was not working correctly for me: instead of a
        # timezone offset a timezone name was added. This fixes it.
        dt = datetime.now()
        tz = dt.astimezone().tzinfo
        out.write("""msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\\n"
"POT-Creation-Date: %s\\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n"
"Language-Team: LANGUAGE <LL@li.org>\\n"
"MIME-Version: 1.0\\n"
"Content-Type: text/plain; charset=UTF-8\\n"
"Content-Transfer-Encoding: 8bit\\n"

""" % (dt.astimezone(tz).strftime("%Y-%m-%d %H:%M%z")))

    def outputAll(self, out):
        self.outputHeader(out)

        for k in self.messages:
            if k in self.comments:
                out.write("#. %s\n" % (self.comments[k].replace("\n","\n#. ")))
            references = ""
            for reference in self.linenos[k]:
                references += "%s:%d(%s) " % (reference[0], reference[2], reference[1])
            out.write("#: %s\n" % (references.strip()))
            if k in self.nowrap and self.nowrap[k]:
                out.write("#, no-wrap\n")
            out.write("msgid \"%s\"\n" % (k))
            translation = ""
            if self.do_translations:
                if len(self.translations)>0:
                    translation = self.translations.pop(0)
            if translation == k:
                translation = ""
            out.write("msgstr \"%s\"\n\n" % (translation))

class XMLDocument(object):
    def __init__(self, filename, base_path, app):
        print(f"\nInitialize XmlDocument for {filename}...", file=sys.stderr)
        self.dtd_contents = None
        self.filename = filename
        self.app = app
        self.expand_entities = self.app.options.get('expand_entities')
        self.ignored_tags = self.app.current_mode.getIgnoredTags()

        # Remove the part of the path that redirects from build dir to
        # source dir since that part depends on personal setup and can
        # cause a lot of unnecessary changes in commits.
        self.base_path = base_path
        self.source_filename = self.filename
        if self.source_filename.startswith(self.base_path):
            self.source_filename = self.source_filename[len(self.base_path):]

        load_dtd      = True
        keep_entities = not self.app.options.get('expand_all_entities')

        parser = etree.XMLParser(load_dtd = load_dtd or keep_entities,
                                 resolve_entities = not(keep_entities))
        doc = etree.parse(filename, parser)
        doc.xinclude()
        self.doc = doc

        ###ctxt = libxml2.createFileParserCtxt(filename)
        ###ctxt.lineNumbers(1)
        ###if self.app.options.get('expand_all_entities'):
        ###    ctxt.replaceEntities(1)

        ###try:
        ###    ctxt.parseDocument()
        ###except Exception as e:
        ###    print("Error parsing XML file '%s': %s" % (filename, str(e)), file=sys.stderr)
        ###    sys.exit(1)

        ###self.doc = ctxt.doc()

        ###if self.doc.name != filename:
        ###    raise Exception("Error: I tried to open '%s' but got '%s' -- how did that happen?" % (filename, self.doc.name))

        if self.app.msg:
            self.app.msg.setFilename(self.source_filename)
        self.isFinalNode = self.app.current_mode.isFinalNode
        print("XmlDocument init finished...\n", file=sys.stderr)

    def generate_messages(self):
        print("XmlDocument generate_messages...", file=sys.stderr)
        self.app.msg.setFilename(self.source_filename)
        self.doSerialize(self.doc.getroot())

    def normalizeNode(self, node):
        print("XmlDocument normalizeNode...", file=sys.stderr)
        #print >>sys.stderr, "<%s> (%s) [%s]" % (node.name, node.type, node.serialize('utf-8'))
        if not node:
            return
        elif self.app.isSpacePreserveNode(node):
            return
        elif node.isText():
            if node.isBlankNode():
                if self.app.options.get('expand_entities') or \
                  (not (node.prev and not node.prev.isBlankNode() and node.next and not node.next.isBlankNode()) ):
                    node.setContent('')
            else:
                node.setContent(re.sub(r'\s+',' ', node.content))

        elif node.children and node.type == 'element':
            child = node.children
            while child:
                nextchild = child.next
                self.normalizeNode(child)
                child = nextchild

    def normalizeString(self, text, spacepreserve = False):
        """Normalizes string to be used as key for gettext lookup.

        Removes all unnecessary whitespace."""
        print(f"XmlDocument normalizeString for text [{text}] ...", file=sys.stderr)
        mytext = text
        if spacepreserve:
            return text
        try:
            # Lets add document DTD so entities are resolved
            dtd = self.doc.intSubset()
            tmp = dtd.serialize('utf-8')
            tmp = tmp + '<norm>%s</norm>' % text
        except:
            print(f"Error serializing DTD.", file=sys.stderr)
            tmp = '<norm>%s</norm>' % text

        try:
            ctxt = libxml2.createDocParserCtxt(tmp)
            if self.app.options.get('expand_entities'):
                ctxt.replaceEntities(1)
            ctxt.parseDocument()
            tree = ctxt.doc()
            newnode = tree.getRootElement()
        except:
            print("""Error while normalizing string as XML:\n"%s"\n""" % (text), file=sys.stderr)
            return text

        # Not sure if saving the doc here is really necessary. It was one of the
        # things done in debugging and don't want to spend time now to check if
        # we can remove it.
        save_doc = self.doc
        self.doc = ctxt.doc()
        self.normalizeNode(newnode)
        self.doc = save_doc

        result = ''
        child = newnode.children
        while child:
            nextchild = child.next
            result += child.serialize('utf-8')
            child = nextchild

        result = re.sub('^ ','', result)
        result = re.sub(' $','', result)
        tree.freeDoc()

        return result

    def stringForEntity(self, node):
        """Replaces entities in the node."""
        print("XmlDocument stringForEntity...", file=sys.stderr)
        text = node.serialize('utf-8')
        try:
            # Lets add document DTD so entities are resolved
            dtd = self.doc.intSubset()
            tmp = dtd.serialize('utf-8') + '<norm>%s</norm>' % text
            next = True
        except:
            tmp = '<norm>%s</norm>' % text
            next = False

        ctxt = libxml2.createDocParserCtxt(tmp)
        if self.expand_entities:
            ctxt.replaceEntities(1)
        ctxt.parseDocument()
        tree = ctxt.doc()
        if next:
            newnode = tree.children.next
        else:
            newnode = tree.children

        result = ''
        child = newnode.children
        while child:
            nextchild = child.next
            result += child.serialize('utf-8')
            child = nextchild
        tree.freeDoc()
        return result


    def myAttributeSerialize(self, node):
        print("XmlDocument myAttributeSerialize...", file=sys.stderr)
        result = ''
        if node.children:
            child = node.children
            nextchild = child.next
            while child:
                if child.type=='text':
                    result += self.doc.encodeEntitiesReentrant(child.content)
                elif child.type=='entity_ref':
                    if not self.expand_entities:
                        result += '&' + child.name + ';'
                    else:
                        result += child.content.decode('utf-8')
                else:
                    result += self.myAttributeSerialize(child)
                child = nextchild
        else:
            result = node.serialize('utf-8')
        return result

    def startTagForNode(self, node):
        print("XmlDocument startTagForNode...", file=sys.stderr)
        if node is None:
            return 0

###        result = node.name
        result = xml_qname(node)
        params = ''
###        if node.properties:
###            for p in node.properties:
        print(f"\tNode {result} --> Attributes: [{node.attrib}].", file=sys.stderr)
        if len(node.items()) > 0:
            for name, atval in node.items():
                if name == 'attribute':
                    try:
                        nsprop = p.ns().name + ":" + p.name
                    except:
                        nsprop = p.name
                    params += " %s=\"%s\"" % (nsprop, self.myAttributeSerialize(p))
        return result+params

    def endTagForNode(self, node):
        print("XmlDocument endTagForNode...", file=sys.stderr)
        if node is None:
            return False
###        return node.name
        return xml_qname(node)

    def ignoreNode(self, node):
        #print("XmlDocument ignoreNode...", file=sys.stderr)
        if self.isFinalNode(node):
            return False
###        if node.type == 'dtd' and self.dtd_contents is None:
            # We need to parse dtd once to get the declared entities if any
###            return False
###        elif node.name in self.ignored_tags or node.type in ('dtd', 'comment'):
        elif xml_qname(node) in self.ignored_tags: ### or node.type in ('dtd', 'comment'):
            print("XmlDocument ignoreNode: YES", file=sys.stderr)
            return True
        return False

    def getCommentForNode(self, node):
        """Walk through previous siblings until a comment is found, or other element.

        Only whitespace is allowed between comment and current node."""
        print("XmlDocument getCommentForNode...", file=sys.stderr)
###        prev = node.prev
        parent = node.getparent()
        firstchild = None
        if parent is not None:
            firstchild = parent[0]
        prev = node.getprevious()
###        while prev and prev.type == 'text' and prev.content.strip() == '':
###            prev = prev.prev
        while prev is not None and self.isTextNode(prev):
            print(f"prev: {prev.tag}, first: {firstchild.tag}", file=sys.stderr)
            if prev == firstchild:
                prev = None
            else:
                prev = prev.getprevious()
###        if prev and prev.type == 'comment':
###            return prev.content.strip()
        if prev and prev.tail is not None:
            return prev.tail.strip()
        else:
            return None

    def replaceAttributeContentsWithText(self, node, text):
        print("XmlDocument replaceAttributeContentsWithText...", file=sys.stderr)
        try:
            node.setContent(text.decode('utf-8'))
        except TypeError:
            sys.stderr.write("--> replaceAttributeContentsWithText: Failed to decode text to utf-8.")
            sys.exit(1)

    def printErrorHeader(self, text, log):
        print("XmlDocument printErrorHeader...", file=sys.stderr)

        print(f"\n========================", file=log)
        print(f"Source xml: {self.filename}", file=log)
        print(f"Source po : {self.app.pofile}", file=log)
        print(f"\nTranslated msgstr:\n{text}", file=log)

    def CheckMatchedTags(self, text):
        print("XmlDocument CheckMatchedTags...", file=sys.stderr)
        stack = []
        textblock = text

        log=sys.stdout
        headerPrinted = False

        # It might be even better to do the below with regex, see e.g.
        # https://datadependence.com/2016/03/find-unclosed-tags-using-stacks/
        # However I'm not sure it really matters that much since the text
        # blocks usually are fairly small and most don't have a lot of tags.
        start_tag = textblock.find('<')
        while start_tag > -1:
            textblock = textblock[start_tag+1:]
            end_tag = textblock.find('>')
            if end_tag > 2 and textblock[0] == '!' and textblock[1] == '-' and textblock[2] == '-':
                # Start of comment inside a translation is suspicious!
                if not headerPrinted:
                    self.printErrorHeader(text, log)
                    headerPrinted = True
                print(f"WARNING: Suspicious XML comment found. Skipping contents of comment.", file=log)
                end_comment = textblock.find('-->')
                if end_comment > -1:
                    textblock = textblock[end_comment+3:]
                    start_tag = textblock.find('<')
                    continue
                else:
                    print(f"WARNING: XML comment closing tag missing", file=log)
                    start_tag = -1
                    continue
            elif end_tag > 2 and textblock[0] == '?' and textblock[end_tag-1] == '?':
                # XML "external command"
                # This can be improved to explicitly search for end with '?>'
                textblock = textblock[end_tag+1:]
                start_tag = textblock.find('<')
                continue

            if end_tag > -1:
                # Found left and right brackets: grab tag
                tag = textblock[: end_tag]
                # Check that it's not a tag that closes itself and comment tags starting with <!
                if textblock[end_tag-1] != '/' and textblock[0] != '!':
                    # Tag can have multiple elements inside, watch for first space
                    space = tag.find(' ')
                    if space > -1:
                        tag = tag[: space]

                    open_tag = (len(tag) > 0 and tag[0] != '/')
                    if open_tag:
                        # Add tag to stack
                        stack.append(tag)
                    else:
                        tag = tag[1:]
                        if len(stack) == 0:
                            pass
                        else:
                            if stack[-1] == tag:
                                # Close the block
                                stack.pop()
                            else:
                                if not headerPrinted:
                                    self.printErrorHeader(text, log)
                                    headerPrinted = True
                                print(f"\nWARNING: Found closing tag [{tag}], however we expected [{stack[0]}].", file=log)
                                print(f"Remaining tags: {str(stack)}", file=log)
                                if tag in stack:
                                    stack.remove(tag)
                                    print("  Assuming incorrect tag order, found and removed tag from the stack", file=log)
                textblock = textblock[end_tag+1:]
                start_tag = textblock.find('<')
            else:
                start_tag = -1


        if len(stack):
            if not headerPrinted:
                self.printErrorHeader(text, log)
                headerPrinted = True
            print(f"\nERROR: Found unmatched tags in po msgstr.", file=log)
            print(f"Tags not matched: {str(stack)}", file=log)
            print(f"========================\n", file=log)
            return False

        if headerPrinted:
            print(f"========================\n", file=log)
        return True

    def replaceNodeContentsWithText(self, node, text):
        """Replaces all subnodes of a node with contents of text treated as XML."""

        print("XmlDocument replaceNodeContentsWithText...", file=sys.stderr)
        if not self.CheckMatchedTags(text):
            return

        if node.children:
            starttag = self.startTagForNode(node)
            endtag = self.endTagForNode(node)

            # Lets add document DTD so entities are resolved
            tmp = '<?xml version="1.0" encoding="utf-8" ?>'
            try:
                dtd = self.doc.intSubset()
                tmp = tmp + dtd.serialize('utf-8')
            except libxml2.treeError:
                pass

            content = '<%s>%s</%s>' % (starttag, text, endtag)
            tmp = tmp + content

            newnode = None
            try:
                ctxt = libxml2.createDocParserCtxt(tmp)
                ctxt.replaceEntities(0)
                ctxt.parseDocument()
                newnode = ctxt.doc()
            except:
                pass

            if not newnode:
                print(f"\n--> Error parsing translation as XML:\n{text}")
                # See: https://gitlab.gnome.org/GNOME/libxml2/-/issues/64
                print("--> Note: this might be caused by a bug in libxml2.\n")
                return

            newelem = newnode.getRootElement()

            if newelem and newelem.children:
                free = node.children
                while free:
                    nextchild = free.next
                    free.unlinkNode()
                    free = nextchild

                if node:
                    nextnode = node.next
                    node.replaceNode(newelem.copyNodeList())
                    node.__next__ = nextnode

            else:
                # In practice, this happens with tags such as "<para>    </para>" (only whitespace in between)
                pass
        else:
            node.setContent(text)

    def isTextNode(self, node):
        text = node.text.strip()
        return text != ''

    def hasText(self, node):
        """Whether or not a node contains text

        A node "contains text" if the node itself or one of its children
        is a text node containing non-empty text.
        """
        print("XmlDocument hasText...", file=sys.stderr)
###        if node.name in self.ignored_tags:
        if node.tag in self.ignored_tags:
            return False
###        if node.isText() and node.content.strip() != '':
        if self.isTextNode(node):
            return True
###        child = node.children
###        while child:
###            nextchild = child.next
        for child in node.iterchildren():
###            if child.isText() and child.content.strip() != '':
            if self.isTextNode(child ):
                return True

        return False


    def worthOutputting(self,node):
        """Whether or not a node is worth outputting

        A node is "worth outputting", if the node itself or one of its
        children is a text node -- unless the node is not final and there
        is a parent node which is already worth outputting.
        """
        print("XmlDocument worthOutputting...", file=sys.stderr)
        worth = self.hasText(node)	# is or has non-empty text node
###        if not (self.isFinalNode(node) or node.get_name() in self.ignored_tags):
###            parent = node.get_parent()
        if not (self.isFinalNode(node) or xml_qname(node) in self.ignored_tags):
            parent = node.getparent()
            while worth and parent is not None:
                if self.worthOutputting(parent):
                    worth = False
                else:
###                    parent = parent.get_parent()
                    parent = parent.getparent()
        return worth

    def processAttribute(self, node, attr):
        print("XmlDocument processAttribute...", file=sys.stderr)
        assert node and attr

        outtxt = self.normalizeString(attr.content)
        if self.app.operation == 'merge':
            translation = self.app.getTranslation(outtxt)  # unicode or None
            if translation is not None:
                self.replaceAttributeContentsWithText(attr,
                                                      translation.encode('utf-8'))
        else:
            self.app.msg.outputMessage(outtxt, node.lineNo(),  "", spacepreserve=False,
                              tag = node.name + ":" + attr.name)

    def processElementTag(self, node, replacements, restart = False):
        """Process node with node.type == 'element'."""
        print("XmlDocument processElementTag...", file=sys.stderr)
###        if node.type != 'element':
        if not etree.iselement(node):
            raise Exception("Invalid node: only element nodes allowed here!")

        # Translate attributes if needed
        print(f"\tNode: {node.tag} --> Attributes: [{node.attrib}].", file=sys.stderr)
###        if node.properties and self.app.current_mode.getTreatedAttributes():
        if len(node.items()) > 0 and self.app.current_mode.getTreatedAttributes():
            for name, atval in node.items():
                if name in self.app.current_mode.getTreatedAttributes():
                    self.processAttribute(node, name)
            # DamnedLies has an older python3 libxml2 without an iterator for XmlAttr, try to work around it
            # Version using iterator
            #for p in node.properties:
            #    if p.name in self.app.current_mode.getTreatedAttributes():
            #        self.processAttribute(node, p)

            # ugly hack to iterate node.properties without iterator
###            p = node.properties
###            while p:
###                prev = p
###                if p.name in self.app.current_mode.getTreatedAttributes():
###                    self.processAttribute(node, p)
###                p = node.properties.next
                # It looks like we can't count on p.last
                # Apparently last node in list points to itself (prev)
###                if p == prev:
###                    break

        #outtxt = ''
        outtxt = node.text.strip()
        if restart:
            myrepl = []
        else:
            myrepl = replacements

        submsgs = []

##        child = node.children
##        while child:
            # Although I do not know why, child or child.next gets changed inside the if part below.
            # This makes child.next fail when it shouldn't. That's why we store nextchild here
            # before going into the if and use that at the end of the loop
##            nextchild = child.next
        print(f"\tIterate over children of element node.", file=sys.stderr)
        for child in node.iterchildren():
            print(f"\tChild: <{child.tag}>", file=sys.stderr)
            if self.isFinalNode(child):
                if len(child) == 0:
                    # No children: serialize Text (and tail?)
                    #outtxt += self.doSerialize(child)
                    (starttag, content, endtag, translation) = self.processElementTag(child, myrepl, False)
                    outtxt += '<%s>%s</%s>' % (starttag, content, endtag)
                    #continue
                else:
                    myrepl.append(self.processElementTag(child, myrepl, True))
                    outtxt += '<placeholder-%d/>' % (len(myrepl))
###            if (self.isFinalNode(child)) or (child.type == 'element' and self.worthOutputting(child)):
            elif (etree.iselement(child) and self.worthOutputting(child)):
                print(f"\tAppend child as placeholder.", file=sys.stderr)
                myrepl.append(self.processElementTag(child, myrepl, True))
                outtxt += '<placeholder-%d/>' % (len(myrepl))
            else:
                print(f"\tAppend child.", file=sys.stderr)
###                if child.type == 'element':
                if etree.iselement(child):
                    print(f"\tAppend child element.", file=sys.stderr)
                    (starttag, content, endtag, translation) = self.processElementTag(child, myrepl, False)
                    outtxt += '<%s>%s</%s>' % (starttag, content, endtag)
                else:
                    print(f"\tAppend serialized child.", file=sys.stderr)
                    outtxt += self.doSerialize(child)
            print(f"\tOuttext: [{outtxt}]", file=sys.stderr)
###            child = nextchild

        if self.app.operation == 'merge':
            norm_outtxt = self.normalizeString(outtxt, self.app.isSpacePreserveNode(node))
            translation = self.app.getTranslation(norm_outtxt)
        else:
            translation = outtxt

        print(f"\tGet start and end tag.", file=sys.stderr)
        starttag = self.startTagForNode(node)
        endtag = self.endTagForNode(node)

        # FIXME Tail needs to go AFTER endtag, but is not part of endtag!
        if node.tail is not None:
            outtxt += node.tail.strip()

        print(f"\tIs it worth outputting.", file=sys.stderr)
        worth = self.worthOutputting(node)
        if not translation:
            translation = outtxt
            if worth and self.app.options.get('mark_untranslated'):
                node.setLang('C')

        print(f"\trestart {restart} - worth {worth}...", file=sys.stderr)
        if restart or worth:
            for i, repl in enumerate(myrepl):
                # repl[0] may contain translated attributes with
                # non-ASCII chars, so implicit conversion to <str> may fail
                replacement = '<%s>%s</%s>' % \
                              (repl[0], repl[3], repl[2])
                translation = translation.replace('<placeholder-%d/>' % (i+1), replacement)

            if worth:
                if self.app.operation == 'merge':
                    self.replaceNodeContentsWithText(node, translation)
                else:
                    print(f"\tNormalize outtxt {outtxt}.", file=sys.stderr)
                    norm_outtxt = self.normalizeString(outtxt, self.app.isSpacePreserveNode(node))
###                    self.app.msg.outputMessage(norm_outtxt, node.lineNo(), self.getCommentForNode(node), self.app.isSpacePreserveNode(node), tag = node.name)
                    self.app.msg.outputMessage(norm_outtxt, node.sourceline, self.getCommentForNode(node), self.app.isSpacePreserveNode(node), tag = node.tag)

        print(f"\treturn processElementTag result: <{starttag}> '{outtxt}' <{endtag}>, translation: [{translation}].", file=sys.stderr)
        return (starttag, outtxt, endtag, translation)


    def isExternalGeneralParsedEntity(self, node):
        print("XmlDocument isExternalGeneralParsedEntity...", file=sys.stderr)
        try:
            # it would be nice if debugDumpNode could use StringIO, but it apparently cannot
            tmp = tempfile.TemporaryFile(encoding='utf-8')
            node.debugDumpNode(tmp,0)
            tmp.seek(0)
            tmpstr = tmp.read()
            tmp.close()
        except:
            # We fail silently, and replace all entities if we cannot
            # write .xml2po-entitychecking
            # !!! This is not very nice thing to do, but I don't know if
            #     raising an exception is any better
            return False
        return tmpstr.find('EXTERNAL_GENERAL_PARSED_ENTITY') != -1

    def doSerialize(self, node):
        """Serializes a node and its children, emitting PO messages along the way.

        node is the node to serialize, first indicates whether surrounding
        tags should be emitted as well.
        """

        print("XmlDocument doSerialize...", file=sys.stderr)
        #FIXME - See https://github.com/itstool/itstool/pull/57/files line 972 etc (ugly hack...)
###        if node.type == 'dtd' and self.dtd_contents is None:
            #node.debugDumpDTD(sys.stderr)
###            if node.children is not None:
###                self.dtd_contents = '[\n' + self.doSerialize(node.children) + ']>'
###            return ''
###        elif node.type == 'entity_decl':
            # Our parameter entities are not correctly handled. Fix that by
            # using a hack here to add what we are expecting.
            # This is called from the dtd node above in doSerialize
###            x = node.serialize('utf-8')
            # Add the entities parameter
###            return x + '\n%' + node.name + ';\n'

        if self.ignoreNode(node):
            print(f"\t--> ignore node", file=sys.stderr)
            return ''
###        elif not node.children:
        elif len(node) == 0: ### Also check for comment? (tail)
            print(f"\t--> Use etree to serialize node", file=sys.stderr)
            ###return node.serialize("utf-8")
            ser = etree.tostring(node, encoding="unicode", method="text").strip()
            print(f"\t--> serialized node: [{ser}]", file=sys.stderr)
            return etree.tostring(node, encoding="unicode", method="text").strip()
###        elif node.type == 'entity_ref':
###            if self.isExternalGeneralParsedEntity(node):
###                return node.serialize('utf-8')
###            else:
###                return self.stringForEntity(node)
###        elif node.type == 'text':
        elif isinstance(node.text, str) and not node.text.strip() == '':
            print(f"\t--> text node {node.tag} - [{node.text.strip()}]", file=sys.stderr)
###            nodetext = node.serialize('utf-8')
            nodetext = etree.tostring(node, encoding="utf-8")
            return nodetext.strip
###        elif node.type == 'element':
        elif etree.iselement(node):
            print(f"\t--> element node, text: {node.text}", file=sys.stderr)
            repl = []
            (starttag, content, endtag, translation) = self.processElementTag(node, repl, True)
            return '<%s>%s</%s>' % (starttag, content.encode('utf-8'), endtag)
        else:
            outtxt = ''
            print(f"\t--> Process children of node", file=sys.stderr)
            for child in node.iterchildren():
                print(f"\t--> serialize child: [{child.tag}]", file=sys.stderr)
                outtxt += self.doSerialize(child)
                #if isinstance(child, str):
                #    self._output_images(child,msg)

###            child = node.children
###            outtxt = ''
###            while child:
                # Not sure if the same problem with using next.child happens here too
                # but we will use nextchild here too just to be sure
###                nextchild = child.next
###                outtxt += self.doSerialize(child)
###                child = nextchild
            return outtxt

    def debug_output_node(self, node, level, childnum):
        skipstr = ''
        lvl = 0
        while lvl <= level:
            skipstr += '  '
            lvl += 1

        childtxt = ''
        if childnum > 0:
            childtxt = f"Child {childnum} "

        nodetext = ''
        if isinstance(node.text, str):
            nodetext = node.text.strip()
        nodetail = ''
        if node.tail is not None and isinstance(node.tail, str):
            nodetail = node.tail.strip()

        print(f"{skipstr}{childtxt}Node <{node.tag}>, attrib: {node.attrib}\n{skipstr}Text: [{nodetext}]\n{skipstr}Tail: [{nodetail}]", file=sys.stderr)

        if len(node) > 0:
            self.debug_output_children(node, level+1)

    def debug_output_children(self, node, level):
        knum = 1
        for child in node.iterchildren():
            self.debug_output_node(child, level, knum)
            knum += 1

    def debug_output_all(self, node):
        print(f"\nOutput lxml structure\n", file=sys.stderr)
        level = 0
        self.debug_output_node(node, level, -1)
        print(f"\n---------------------\n", file=sys.stderr)


def xml_error_handler(ctxt, error):
    #deactivate error messages from the validation
    if DEBUG_VERBOSITY > 0:
        print(f"--> xml_error_handler: {error}")
    pass

class Main(object):
    def __init__(self, mode, operation, output, base_path, options):
        ###libxml2.registerErrorHandler(xml_error_handler, None)
        self.operation = operation
        self.options = options
        self.msg = None
        self.gt = None
        self.current_mode = self.load_mode(mode)()
        self.base_path = base_path
        # Prepare output
        if operation == 'update':
            self.out = tempfile.TemporaryFile(encoding='utf-8')
        elif output == '-':
            self.out = sys.stdout
        else:
            self.out = open(output, 'w', encoding='utf-8', buffering=1)

    def load_mode(self, modename):
        try:
            module = __import__('xml2po.modes.%s' % modename, globals(), locals(), ['%sXmlMode' % modename])
            return getattr(module, '%sXmlMode' % modename)
        except (ImportError, AttributeError):
            if modename == 'basic':
                sys.stderr.write("Unable to find xml2po modes. Please check your xml2po installation.\n")
                sys.exit(1)
            else:
                sys.stderr.write("Unable to load mode '%s'. Falling back to 'basic' mode with automatic detection (-a).\n" % modename)
                return self.load_mode('basic')

    def to_pot(self, xmlfiles):
        """ Produce a pot file from the list of 'xmlfiles' """
        print("Start to_pot...", file=sys.stderr)
        self.msg = MessageOutput(self)
        for xmlfile in xmlfiles:
            if not os.access(xmlfile, os.R_OK):
                raise IOError("Unable to read file '%s'" % xmlfile)
            try:
                doc = XMLDocument(xmlfile, self.base_path, self)
            except Exception as e:
                print("Error parsing XML file '%s': %s" % (xmlfile, str(e)), file=sys.stderr)
                sys.exit(1)
            self.current_mode.preProcessXml(doc.doc, self.msg)
            doc.generate_messages()
            doc.debug_output_all(doc.doc.getroot())
        self.output_po()

    def merge(self, mofile, xmlfile):
        """ Merge translations from mofile into xmlfile to generate a translated XML file """
        print("Start merge...", file=sys.stderr)
        if not os.access(xmlfile, os.R_OK):
            raise IOError("Unable to read file '%s'" % xmlfile)
        try:
            doc = XMLDocument(xmlfile, self.base_path, self)
        except Exception as e:
            print("Error parsing XML file '%s': %s" % (xmlfile, str(e)), file=sys.stderr)
            sys.exit(1)
        try:
            mfile = open(mofile, "rb")
        except:
            print("Error opening MO file '%s': %s." % (mofile, str(e)), file=sys.stderr)
            sys.exit(1)
        self.gt = gettext.GNUTranslations(mfile)
        self.gt.add_fallback(NoneTranslations())
        # Has preProcessXml use cases for merge?
        #self.current_mode.preProcessXml(doc.doc, self.msg)

        doc.doSerialize(doc.doc)
        tcmsg = self.current_mode.getStringForTranslators()
        outtxt = self.getTranslation(tcmsg)
        self.current_mode.postProcessXmlTranslation(doc.doc, self.options.get('translationlanguage'), outtxt)
        serialized_doc = doc.doc.serialize('utf-8', 1)
        # Now we need to hack the results when external parameter entities
        # are defined, since they are not correctly serialized for our purposes.
        # Replace the dtd entities with our previously parsed version.
        if doc.dtd_contents is not None:
            corrected_doc = re.sub(r'\[.+?\]\>', doc.dtd_contents, serialized_doc, count=1, flags=re.DOTALL)
        else:
            corrected_doc = serialized_doc
        self.out.write(corrected_doc)

    def reuse(self, origxml, xmlfile):
        """ Produce a po file from xmlfile pot and using translations from origxml """
        self.msg = MessageOutput(self)
        self.msg.do_translations = True
        if not os.access(xmlfile, os.R_OK):
            raise IOError("Unable to read file '%s'" % xmlfile)
        if not os.access(origxml, os.R_OK):
            raise IOError("Unable to read file '%s'" % xmlfile)
        try:
            doc = XMLDocument(xmlfile, self.base_path, self)
        except Exception as e:
            print("Error parsing XML file '%s': %s" % (xmlfile, str(e)), file=sys.stderr)
            sys.exit(1)
        doc.generate_messages()

        self.msg.translationsFollow()
        try:
            doc = XMLDocument(origxml, self.base_path, self)
        except Exception as e:
            print("Error parsing XML file '%s': %s" % (origxml, str(e)), file=sys.stderr)
            sys.exit(1)
        doc.generate_messages()
        self.output_po()

    def update(self, xmlfiles, lang_file):
        """ Merge the produced pot with an existing po file (lang_file) """
        if not os.access(lang_file, os.W_OK):
            raise IOError("'%s' does not exist or is not writable." % lang_file)
        self.to_pot(xmlfiles)
        lang = os.path.basename(lang_file).split(".")[0]

        sys.stderr.write("Merging translations for %s: \n" % (lang))
        self.out.seek(0)
        merge_cmd = subprocess.Popen(["msgmerge", "-o", ".tmp.%s.po" % lang, lang_file, "-"],
                                     stdin=self.out, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        cmdout, cmderr = merge_cmd.communicate()
        if merge_cmd.returncode:
             raise Exception("Error during msgmerge command.")
        else:
            result = subprocess.call(["mv", ".tmp.%s.po" % lang, lang_file])
            if result:
                raise Exception("Error: cannot rename file.")
            else:
                subprocess.call(["msgfmt", "-cv", "-o", NULL_STRING, lang_file])

    def getTranslation(self, text):
        """Returns a translation via gettext for specified snippet.

        text should be a string to look for.
        """
        if not text or text.strip() == '':
            return text
        if self.gt:
            res = self.gt.gettext(text)
            return res

        return text

    def output_po(self):
        """ Write the resulting po/pot file to specified output """
        print(f"Write po file", file=sys.stderr)
        tcmsg = self.current_mode.getStringForTranslators()
        tccom = self.current_mode.getCommentForTranslators()
        if tcmsg:
            self.msg.outputMessage(tcmsg, lineno=0, comment=tccom)

        self.msg.outputAll(self.out)

    # **** XML utility functions ****
    def isSpacePreserveNode(self, node):
        ### FIXME if node.getSpacePreserve() == 1:
        if False:
            return True
        else:
###            return node.name in self.current_mode.getSpacePreserveTags()
            return node.tag in self.current_mode.getSpacePreserveTags()

