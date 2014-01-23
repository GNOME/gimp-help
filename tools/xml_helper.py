#! /usr/bin/env python
# -*- encoding: utf-8 -*-


# gimp-help-2 --XML language separator tool
# Copyright (C) 2006 Joao S. O. Bueno Calligaris
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
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
#



import sys

#download elementtree from http://effbot.org/downloads/
#it is set to be included in the core Python as of version 2.5
import elementtree.ElementTree as ET
from copy import copy, deepcopy
import os.path
from os import mkdir

IDTAG = "xml_id"
HASHTAG = "xml_hash"
CHANGEDTAG = "xml_changed"



work_dir = "./working_translation"

version = "0.91"
#TODO (v.0.9): properly formating the final gimp-help xml files
#that is: Adding a DTD header, and doing line wrapping and identation


class Stub(object):
    def __init__(self, node=None):
        self.node = node
        self.children_langs = {}
    def getchildren (self):
        return [self.node]


def recurse_anotate (parent, document):
    """
    Since in elementTree tehre sis no way to get  a reference to a node ? siblings or parent, this takes care of it.
    """
    document.parent = parent
    siblings = parent.getchildren ()
    self_index = siblings.index (document)
    if self_index != 0:
        document.previous_sibling = siblings[self_index - 1]
    else:
        document.previous_sibling = None

    if self_index + 1 < len ( siblings):
        document.next_sibling = siblings[self_index + 1]
    else:
        document.next_sibling = None
    for child in document:
        recurse_anotate (document, child)

def make_dir (path):
    if path == "":
        return
    while not os.path.isdir (path):
        make_dir (os.path.dirname(path))
        mkdir (path)

def create_new_ids (document):
    idcount = 1
    for node in document.getiterator ():
        node_hash = str (ET.tostring(node, "utf-8").__hash__())
        node.attrib [IDTAG] = str (idcount)
        node.attrib [HASHTAG] = node_hash
        idcount += 1

def parse_hashes (document):
    all_hashes = {}
    for node in document.getiterator ():
        all_hashes [node.attrib[HASHTAG]] = node
    return all_hashes

def parse_ids (document):
    all_ids = {}
    for node in document.getiterator ():
        all_ids [node.attrib[IDTAG]] = node
    return all_ids

def get_node_by_id (document, id):
    for node in document.getiterator ():
        if node.attrib.has_key (IDTAG) and \
           node.attrib[IDTAG] == id:
            return node
    return None
def get_all_langs (document):
    """Rerieve all languages in use  a document"""
    langs = {}
    for node in document.get_iterator():
        if node.attrib.has_key ("lang"):
            if ";" in node.attrib["lang"]:
                local_langs = node.attrib["lang"].split(";")
            else:
                local_langs = [node.attrib["lang"]]
            for local_lang in local_langs:
                langs[local_lang] = None
    return langs.keys ()

def node_replace (parent_node, old_node, new_node):
    parent_node.insert (parent_node.getchildren().index(old_node), new_node)
    parent_node.remove (old_node)

def node_insert_after (parent_node, old_node, new_node):
    #this is not working:
    #parent_node.insert (parent_node.getchildren().index(old_node) + 1, new_node)
    for i, node in enumerate (parent_node.getchildren()):
        if node.attrib[IDTAG] == old_node.attrib[IDTAG]:
            break
    else:
        sys.stderr ("Error placing new tag - putting at the end of parent tag")
    parent_node.insert (i + 1, new_node)



def create_ids (path, document):
    try:
        helper_document = ET.parse (path).getroot()
    except:
        create_new_ids (document)
        return
    #Here it will check witch nodes in any of the selected languages had
    # changed since the file was last merged back, and add a "fuzzy"
    # xml attribute to tehm.

    #this may take a while.

    #nodes with the same content may clash and give false positives
    #of having changed. That will not be a big deal.
    all_hashes = parse_hashes (helper_document)
    idcount = 1
    for node in document.getiterator ():
        node_hash = str (ET.tostring(node, "utf-8").__hash__())
        if not all_hashes.has_key (node_hash):
            node.attrib [CHANGEDTAG] = "True"
        node.attrib [IDTAG] = str (idcount)
        node.attrib [HASHTAG] = node_hash
        idcount += 1

def remove_ids (document):
    for node in document.getiterator ():
        for attrib in (CHANGEDTAG, HASHTAG, IDTAG):
            if node.attrib.has_key (attrib):
                del node.attrib [attrib]


def remove_hashes (document):
    for node in document.getiterator ():
        if node.attrib.has_key (HASHTAG):
            del node.attrib [HASHTAG]
        if (node.attrib.has_key (IDTAG) and
            not node.attrib.has_key ("lang") and
            not node.getchildren()
            ):
            del node.attrib [IDTAG]

def create_node_order_helper (document):
    counter = 0
    for node in document.getiterator ():
        node.xml_helper_order = counter
        counter += 1

def _sort_nodes (node_list):
    reindex = {}
    for i, node in enumerate (node_list):
        reindex [node.xml_helper_order] = i
    new_list = []
    sorted_keys = reindex.keys()[:]
    sorted_keys.sort()
    for key in sorted_keys:
        new_list.append (node_list[reindex[key]])
    return new_list



def recurse_rip (parent, element, all_langs):
    element.children_langs = {}
    if not element.attrib.has_key ("lang"):
        for child in element.getchildren()[:]:
            recurse_rip (element, child, all_langs)
    else:
        elem_langs = element.attrib["lang"].split (";")
        first_lang_found = False
        for elem_lang in  elem_langs:
            if elem_lang in all_langs:
                try:
                    parent.children_langs[elem_lang] += 1
                except KeyError:
                    parent.children_langs[elem_lang] = 1
                if not first_lang_found:
                    for child in element.getchildren()[:]:
                        recurse_rip (element, child, all_langs)
                    first_lang_found = True
        if not first_lang_found:
            if element.tail.isspace():
                element.tail = ""
            #print ET.tostring (element, "utf-8")
            parent.remove (element)
    if element.children_langs:
        pass
    del element.children_langs

def count_children_lang (node):
    count = 0
    first = True
    for child in node.getiterator ():
        if first:
            first = False
            continue
        if node.attrib.has_key("lang"):
            count += 1
    return count

def merge_docs (helper_document, translated_document, merge_langs):
    recurse_anotate (Stub(helper_document), helper_document)
    recurse_anotate (Stub(translated_document), translated_document)
    all_ids = parse_ids (helper_document)
    for node in translated_document.getiterator ():
        #this extra attribute is retrieved in the sorting
        #by lang attributes routine to assure the same
        #document order of the nodes with the same lang.
        if not node.attrib.has_key ("lang"):
            continue
        if (len (node.attrib["lang"].split(";") ) > 1 and
            len (node.getchildren ())  and
            count_children_lang (node) != 0 ):
            continue

        found_lang = False
        elem_langs = node.attrib["lang"].split (";")
        for elem_lang in  elem_langs:
            if elem_lang in merge_langs:
                found_lang = True
                break
        if not found_lang:
            continue
        #if it got here, current node in document is to be
        #merged into helper_document
        if node.attrib.has_key (IDTAG):
            node_to_be_replaced = all_ids [node.attrib[IDTAG]]
            node_replace (node_to_be_replaced.parent, node_to_be_replaced, node)
        else:
            #find the nearest node with an idtag.
            address_node = node
            found = False
            while address_node.previous_sibling != None:
                address_node = address_node.previous_sibling
                if address_node.attrib.has_key (IDTAG):
                    prev_id = address_node.attrib[IDTAG]
                    where_to_insert = all_ids [prev_id]
                    found = True
                    break
            if not found:
                prev_id = node.parent.attrib[IDTAG]
                where_to_insert = all_ids [prev_id].getchildren()[0]
            node_insert_after (where_to_insert.parent, where_to_insert, node)
    return helper_document

def _format_xml_internal (child_langs,
                          node,
                          nodes_by_lang
                         ):
            if not len (child_langs):
                return
            index = node.getchildren().index (
                            nodes_by_lang [child_langs[0]] [0] )
            for remove_1 in nodes_by_lang:
                for remove_2 in nodes_by_lang[remove_1]:
                    node.remove (remove_2)
            child_langs.sort ()
            #restore original order of the text - it may have mixed up
            #after merging and sorting languages
            for lang in nodes_by_lang:
                nodes_by_lang[lang] = _sort_nodes (nodes_by_lang[lang])

            for lang in child_langs:
                node.insert (index, nodes_by_lang [lang].pop(0))
                index += 1

def format_xml (node):
    """Recursively sort the chidren tags by lang attrib"""
    group = None
    child_langs = []
    nodes_by_lang = {}
    for child in node.getchildren():
        do_grandchildren = True
        if child.tag != group:
            _format_xml_internal (child_langs, node, nodes_by_lang)
            child_langs = []
            nodes_by_lang = {}
            group = child.tag
        if child.attrib.has_key ("lang"):

            lang = child.attrib["lang"]
            if len (lang.split (";")) > 1:
                langs = lang.split(";")
                langs.sort ()
                lang = ";".join (langs)
                child.attrib["lang"] = lang
            else:
                do_grandchildren = False
            child_langs.append (lang)
            try:
                nodes_by_lang[lang].append (child)
            except:
                nodes_by_lang[lang] = [child]
        if do_grandchildren:
            format_xml (child)
    else: #at the end of this nodes' children
        _format_xml_internal (child_langs, node, nodes_by_lang)

def _create_missing_tags_internal (node,
                                   group_langs,
                                   base_lang
                                  ):

        number_base_nodes = len (group_langs [base_lang])
        if not number_base_nodes:
            return

        for lang in group_langs:
            if lang == base_lang:
                continue
            if len (group_langs [lang]) < number_base_nodes:
                if len (group_langs [lang]):
                    index = node.getchildren().index (group_langs
                                                    [lang][-1])
                else:
                    index = node.getchildren().index (group_langs
                                                [base_lang][-1]) + 1
                    #If a target language has less tags than
                    #the base language in  a tag group,
                    #the later nodes of base lang will be cloned
                    #as the later clones of target lang, regardless
                    #of their content.
                for copying_node in group_langs[base_lang] [
                    len (group_langs[lang]):]:
                    new_node = deepcopy (copying_node)
                    new_node.attrib ["lang"] = lang
                    if "no-clone-content" in options:
                        new_node.clear()
                    node.insert (index, new_node)
                    index += 1


def create_missing_tags (node, all_langs):
    """
        when separating  a file into fewer languages for translation,
        create new tags for the target languages if the first language
        on the language list has more tags in each group
        of equal tags among siblings than the other languages
    """
    base_lang = all_langs[0]
    langs = all_langs[1:]
    group = None
    child_langs = []
    group_langs = {}
    for lang in all_langs:
        group_langs[lang] =  []

    for child in node.getchildren():
        do_grandchildren = True
        if child.tag != group:
            _create_missing_tags_internal (node, group_langs, base_lang)

            child_langs = []
            group_langs = {}
            for lang in all_langs:
                group_langs[lang] =  []
            group = child.tag
        if child.attrib.has_key ("lang"):
            lang = child.attrib["lang"]
            if len (lang.split (";")) > 1:
                local_langs = lang.split (";")
                found = False
                for local_lang in local_langs:
                    if local_lang in all_langs:
                        found = True
                        break
                if found:
                    local_missing = []
                    for global_lang in all_langs:
                        if global_lang not in local_langs:
                            local_missing.append (global_lang)
                    if len (local_missing):
                        local_langs += local_missing
                        local_langs_txt = ";".join (local_langs)
                        child.attrib["lang"] = local_langs_txt
            else:
                if lang in all_langs:
                    child_langs.append (lang)
                    group_langs [lang].append (child)

                do_grandchildren = False
        if do_grandchildren:
            create_missing_tags (child, all_langs)
    else: #at the end of the siblings
        _create_missing_tags_internal (node, group_langs, base_lang)


def rip (file, langs):
    try:
        all_document = ET.parse (file)
    except:
        sys.stderr.write ("Error parsing file %s. Skipped\n")
        return
    document = all_document.getroot ()
    current_langs = copy (langs)

    #TODO:
    #compare_files (document)

    output_helper_name =  os.path.join (work_dir,
                                        os.path.dirname (file),
                                        ".helper",
                                        os.path.basename (file)
                                       )
    make_dir (os.path.dirname (output_helper_name))

    if not "no-create-tags" in options:
        create_missing_tags (document, langs)

    create_ids (output_helper_name, document)

    all_document.write (output_helper_name, "utf-8")
    recurse_rip (Stub (), document, langs)

    remove_hashes (document)
    output_file_name = os.path.join (work_dir, file)
    all_document.write (output_file_name,  "utf-8")


def merge (file, langs):
    input_helper_name =  os.path.join (work_dir,
                              os.path.dirname (file),
                              ".helper",
                               os.path.basename (file)
                                       )
    input_file_name = os.path.join (work_dir, file)

    helper_document = ET.parse (input_helper_name).getroot()
    translated_document = ET.parse (input_file_name).getroot()

    merge_docs (helper_document, translated_document, langs)

    document = helper_document
    remove_ids (document)
    if not "no-format" in options:
        create_node_order_helper (document)
        format_xml (document)

    all_document = ET.ElementTree (document)
    all_document.write (file, "utf-8")

    #write copy with IDs and hash, so that when this file is
    #next splited, changed tags get marked with "changed"
    create_new_ids (document)

    all_document.write (input_helper_name, "utf-8")

    if not "no-delete-rip" in options:
        os.unlink (input_file_name)

def format (file):
    all_document = ET.parse (file)
    document = all_document.getroot()
    create_node_order_helper (document)
    format_xml (document)
    all_document.write (file, "utf-8")
    #print ET.tostring (document,"utf-8")
    #TODO:

    #format_textual_xml (file)

    #this function should take care of
    #DTD headers, indentation and line length
    #reading and writing to the XML file as a text file



def rip_files (in_files, langs):
    for file in in_files:
        rip (file, langs)

def merge_files (in_files, langs):
    for file in in_files:
        merge (file, langs)

def format_files (in_files):
    for file in in_files:
        format (file)

def short_help():
    global work_dir
    sys.stderr.write ( """\
\nExamples of use:
    ./tools/rip_lang.py --rip --langs=en,fr src/gimp.xml
    ./tools/rip_lang.py --merge --langs=fr src/gimp.xml

Execute  xml_helper.py --help to see the full help text
\n""")

def help():
    global work_dir
    sys.stderr.write ( """\
Usage:
rip_lang.py --rip|--merge|--format  [--no-format] [--no-clone-content]
[--no-create-tags]
--lang=xx,yy,zz file1, file2 ...filen

This script Will create versions of these XML files at %s directory
containing only the tags that include the selected languages
 (and creating empty tags if there is a tag for one
language and not for the others).

The tags that already exist will receive a xmlid attribute -
keep it unchanged, or the merger script won't work.

It will also create a .helper directory in that same directory, where
it will store a version of the original XML with some helper tags.
Do not remove these files, or the merger script won't be able to
merge your modifications back into the main XML.

Operation modes:

--rip:
    will generate a new XML document containing only the
    desired languages (see --lang). XML created this way
    have an extra xmlid attrib in all tags. This is used when
    integrating back into  the main XML. You may write more tags
    for a given language, and they will be integrated - leave these
    without a "xmlid" attrib. All new tags must have a lang attrib
    or be inside a tag with alang attrib.


--merge:
    will integrate back a working copy of a XML file into
    the main XML structure. The hidden version in .helper
    dir must exist. Merged files are formated as for the
    --format mode, unless stated otherwise.
    N.B. the paths to the files passed to the script are the paths
    on main src tree, not the in the working dir.

--format:
    will format target xml files as per the guidelines in the
    HACKING file.
    NOT FULLY IMPLEMENTED - At this time,
    this will just sort the tags by the lang attrib.

--help:
    Displays this help and exits

--version:
    Displays the script version and exits


Options:

    --langs:
        mandatory for the --rip and --merge modes - the selected languages
        that will be kept on the working version (ruip) or
        merged back in the main XML (merge).
        The oprder matters in (rip) mode - the first language
        specified is the one that will be clonned in newly created tags
        for the other languages if they don't exist.
        Usage: --langs=xx,yy,zz, ... where xx, yy and zz are language
        codes

    --no-create-tags:
        in --rip mode, doesn't create tags that do not exist for a given
        language, when compared to the first language specified

    --no-clone-content:
        create new language tags, but empty tags, instead of copying
        the content of the first language specified. NB - tags created in
        this way are self closed ( <tag  />  ), by the xml generator.
        Dont forget to change the format to <tag> </tag>  when adding
        content.
    --no-format:
        passed to merge mode - doesn't run the formatting routines
        after merging the xml file.

    --no-delete-rip:
        To avoid conflicts, the working XML version is deleted when merging
        is successfull. If passing this option, the file is preserved (the
        xmlids change when merging, so it is basically impossible to use
        this script to merge a XML a second time.

General Notes:

If a version of the XML being split already exists in the
.helper dir, it will mark changed tags since the last split with
a 'changed=""' XML attribute. This way translations can be kept in sink
without further resource to Harry Potter style magic.

This script will not normally  supress existing XML tags. If
a tag is deleted in the working file, it's copy in the  .helper file
will be used.

Workflow example :

cd gimp-help-2
./tools/rip_lang.py --rip --langs=en,pt_BR src/gimp.xml
cd %s/src
<editor_of_choice> gimp.xml
<translate>
<save><exit>
cd ../..
./tools/rip_lang.py --merge --langs=pt_BR src/gimp.xml
\n

(C) 2006 João S. O. Bueno Calligaris
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
\n""" %(work_dir, work_dir))


if __name__=="__main__":
    langs = None
    in_files = []
    options = []
    for option in sys.argv[1:]:
       if option[0:8]=="--langs=":
           langs = option[8:].split(",")
       elif option == "--help":
           help ()
           sys.exit(0)
       elif option == "--version":
           print "xml_helper version %s\nby João S. O. Bueno Calligaris (c) 2006" % version
           sys.exit(0)
       elif option[:2] != "--":
           in_files.append (option)
       else:
           options.append (option[2:])
    if  not in_files:
        short_help()
        sys.exit (1)
    if "rip" in options and langs:
        rip_files (in_files, langs)
    elif "merge" in options and langs:
        merge_files (in_files, langs)
    elif "format" in options:
        format_files (in_files)
    else:
        short_help()
        print options, langs
        sys.exit (1)