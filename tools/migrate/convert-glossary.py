#!/usr/bin/env python
# _*_ coding: utf8 -*_
"""
FIXME: Missing docstring
"""

import sys
import re
import xml.dom.minidom
import logging

logging.basicConfig(level=logging.INFO, format="%(levelname)-8s %(message)s")
Logger = logging.getLogger("migrate.glossary")

def usage(exit_code=0):
    sys.stderr.write("Usage:\n    " +
                     "%s [--lang LANGUAGES] < RESOVLVED_GLOSSARY_XML\n" % \
                     sys.argv[0])
    sys.exit(exit_code)

def get_lang(elem):
    """Get the value of the "lang" attribute for a given element
    """
    lang = elem.getAttribute("lang")
    if lang:
        return lang
    else:
        return get_lang(elem.parentNode)

def main():
    """FIXME: Missing docstring"""
    languages = ["en","de","es","fr","hr","it","ko","nl","no","pl","ru","sv"]
    if sys.argv[1:]:
        if sys.argv[1] in ("-h", "--help"):
            usage()
        elif sys.argv[1] in ("-l", "--lang"):
            if not sys.argv[2]: usage(64)
            languages = re.split('[;, ]', sys.argv[2])
        else:
            usage(64)

    # read XML file
    filename = sys.stdin
    doc = xml.dom.minidom.parse(filename)

    # document element is last child of document root
    old_glossary = doc.childNodes[-1]
    assert old_glossary.nodeName == "glossary"
    assert old_glossary.getAttribute("lang")

    # this script requires a sequence of 'glossentry' nodes (no 'glossdiv'
    # nodes!) with unified 'glossterm's -- see "stylesheets/glossary.xsl"
    glossentries = [child for child in old_glossary.childNodes
                          if child.nodeName == "glossentry"]
    assert glossentries

    # dict of lists of glossentries
    entry_by_id = {}
    # for matching glossary ids
    localized_id_regex = re.compile("(.*)-([a-z]{2}(_[A-Z]{2})?)$")

    for glossentry in glossentries:
        id = glossentry.getAttribute("id")
        assert id
        # match and split ids like "glossary-foo-xx"
        # with a language suffix "xx"
        match = localized_id_regex.search(id)
        if match:
            saved_id = id
            id, lang = match.group(1,2)
            if lang == get_lang(glossentry):
                glossentry.setAttribute("id", id)
                assert id == glossentry.getAttribute("id")
                Logger.warn("changed id '%s' to '%s'" % (saved_id, id))
            else:
                # Oops - that's probably "glossary-plug-in"
                id = saved_id

        entry = dict(node=glossentry, term=None)
        # typically there's more than one glossentry with this id
        if id in entry_by_id:
            entry_by_id[id].append(entry)
        else:
            entry_by_id[id] = [entry]

        # unified glossterms:
        # <glossterm>
        #   <phrase lang="en"> ... </phrase>
        #   <phrase lang="xx"> ... </phrase>
        #   <phrase lang="yy"> ... </phrase>
        #   ...
        # </glossterm>
        for glossterm in [child for child in glossentry.childNodes
                           if child.nodeName == "glossterm"]:
            for phrase in [child for child in glossterm.childNodes
                                 if child.nodeName == "phrase"]:
                lang = get_lang(phrase)
                if lang.find("en") < 0: continue
                phrase.normalize()
                assert len(phrase.childNodes) == 1  # should be a text node
                term = phrase.childNodes[0].nodeValue.strip()
                entry_by_id[id][-1]['term'] = term.encode("UTF-8")

    impl = xml.dom.minidom.getDOMImplementation()
    result = impl.createDocument(
            None,
            "glossary",
            impl.createDocumentType(
                    "glossary",
                    "-//OASIS//DTD DocBook XML V4.5//EN",
                    "http://www.docbook.org/xml/4.5/docbookx.dtd"))
    result.encoding = "UTF-8"
    new_glossary = result.childNodes[-1]
    assert new_glossary.nodeName == "glossary"
    for attr in ('id', 'lang'):
        new_glossary.setAttribute(attr, old_glossary.getAttribute(attr))

    # append title and indexterm nodes
    for child in (child for child in old_glossary.childNodes
                        if child.nodeType == xml.dom.Node.ELEMENT_NODE
                        if child.nodeName != "glossentry"):
        new_glossary.appendChild(child.cloneNode(True))

    for id in sorted(entry_by_id.keys()):
        Logger.debug("%d %s" % (len(entry_by_id[id]), id))
        all_langs = []
        en_node = None
        for entry in entry_by_id[id]:
            node, term = entry['node'], entry['term']
            langs = get_lang(node)
            Logger.debug("    %s" % langs)
            assert (langs.find("en") < 0) == (term is None)
            all_langs.extend(langs.split(';'))
            node = new_glossary.appendChild(node.cloneNode(True))
            if term: en_node = node
        if not en_node:
            Logger.warn("removed %s (glossentry for %s)" % \
                        (id, ",".join(all_langs)))
            continue
        missing_langs = [lang for lang in languages if lang not in all_langs]
        if missing_langs:
            en_node.setAttribute("lang", get_lang(en_node) +
                                         ';' + ';'.join(missing_langs))

    print result.toxml("UTF-8")

# Main program start
if __name__ == '__main__':
    main()
