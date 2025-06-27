#!/usr/bin/env python3
#
# validate_po.py - Validates correct use of XML tags and other possible
#                  causes of problems in po files.
# Copyright (c) 2021, 2022 Jacob Boerema.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Requirements:
# - polib (pip install polib)

import sys
import getopt
import polib

VERSION = 0.2

class Validate(object):
    def __init__(self, verbose, warnings):
        self.pofile = None
        self.po = None
        self.errors = 0
        self.filecnt = 0
        self.files_with_errors = 0
        self.log=sys.stdout
        self.verbose = verbose
        self.warnings = warnings

    def setFile(self, pofile):
        self.pofile = pofile
        self.po = polib.pofile(pofile)
        self.filecnt += 1

    def printErrorHeader(self, entry, log):
        if self.headerPrinted:
            return
        self.headerPrinted = True
        if not self.verbose:
            print(f"\nPo file: {self.pofile}")
            print(f"Po line number: {entry.linenum}")
        else:
            print(f"\nPo line number: {entry.linenum}")
        print(f"Source text: {entry.occurrences}")
        #print(f"Comment: {entry.comment}")
        #print(f"Translator Comment: {entry.tcomment}")
        #print(f"Context: {entry.msgctxt}")
        if self.verbose:
                print(f"\nOriginal msgid:\n{entry.msgid}", file=self.log)
                print(f"\nTranslated msgstr:\n{entry.msgstr}\n", file=self.log)

    def parse_text(self, entry):
        stack = []
        textblock = entry.msgstr
        err = 0
        #self.headerPrinted = False

        # Note that XML tags do not get escaped. This means we can't really detect
        # the difference between the use of < and > signs and tag begin/end.
        # For now let's just assume that all occurrences of < and > are for tags.

        start_tag = textblock.find('<')
        while start_tag > -1:
            textblock = textblock[start_tag+1:]
            end_tag = textblock.find('>')
            if end_tag > 2 and textblock[0] == '!' and textblock[1] == '-' and textblock[2] == '-':
                # Start of comment inside a translation is suspicious!
                if self.warnings:
                    self.printErrorHeader(entry, self.log)
                    print(f"WARNING: Suspicious XML comment found. Skipping contents of comment.", file=self.log)
                end_comment = textblock.find('-->')
                if end_comment > -1:
                    textblock = textblock[end_comment+3:]
                    start_tag = textblock.find('<')
                    continue
                else:
                    if self.warnings:
                        print(f"WARNING: XML comment closing tag missing", file=self.log)
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
                    # check for closing tag first
                    if len(tag) > 2 and tag[0] == ' ' and tag[1] == '/':
                        # space not allowed when closing tag between < and /
                        err += 1
                        self.printErrorHeader(entry, self.log)
                        tag = tag[1:]
                        print(f"ERROR: No space allowed between '<' and '/' when closing a tag, in this case [{tag}].", file=self.log)

                    if len(tag) > 0 and tag[0] == '/':
                        if tag[1] == ' ':
                            # space not allowed when closing tag between / and tag
                            err += 1
                            self.printErrorHeader(entry, self.log)
                            tag = tag[2:]
                            print(f"ERROR: No space allowed between '/' and [{tag}] when closing a tag.", file=self.log)
                        else:
                            tag = tag[1:]
                        # space is allowed when closing tag, however I think it looks ugly,
                        # so let's issue a warning
                        space = tag.find(' ')
                        if space > -1:
                            #err += 1
                            ending = tag[space+1:]
                            tag = tag[: space]
                            elen = len(ending)
                            ei = 0
                            while elen > ei and ending[ei] == ' ':
                                ei += 1
                            ending = ending[ei:]
                            if elen > ei and ending[0] != '>':
                                self.printErrorHeader(entry, self.log)
                                err +=1
                                print(f"ERROR: Closing tag [/{tag}] cannot not have a space except at the end.", file=self.log)
                            else:
                                if self.warnings:
                                    self.printErrorHeader(entry, self.log)
                                    print(f"WARNING: Unnecessary space between tag and closing bracket, see [{tag}].", file=self.log)
                        # no uppercase allowed in tag
                        lo_tag = tag.lower()
                        if tag != lo_tag:
                            self.printErrorHeader(entry, self.log)
                            err += 1
                            print(f"ERROR: Closing tag [/{tag}] should be all lowercase.", file=self.log)
                            tag = lo_tag
                        if len(stack) == 0:
                            self.printErrorHeader(entry, self.log)
                            err += 1
                            print(f"ERROR: Closing tag [/{tag}] before opening tag.", file=self.log)
                        else:
                            if stack[-1] == tag:
                                # Correct closing tag found, remove from stack
                                stack.pop()
                            else:
                                self.printErrorHeader(entry, self.log)
                                err += 1
                                print(f"ERROR: Found closing tag [/{tag}], however we expected [{stack[0]}].", file=self.log)
                                print(f"\tRemaining tags: {str(stack)}", file=self.log)
                                if tag in stack:
                                    stack.remove(tag)
                                    print("\t  Assuming incorrect tag order, found and removed tag from the stack", file=self.log)
                                elif len(stack) == 1:
                                    stack.pop()
                                    print("\t  Assuming typo, removed remaining tag from the stack", file=self.log)

                    else:
                        # Tag can have multiple elements inside, watch for first space
                        space = tag.find(' ')
                        err_space = False
                        # Get rid of unlikely occurrence of multiple spaces before opening tag
                        while space == 0:
                            err_space = True
                            tag = tag[1:]
                            space = tag.find(' ')
                            if space == -1:
                                break

                        if space > -1:
                            tag = tag[: space]

                        skip = False
                        if err_space:
                            if textblock[end_tag-1] == ' ':
                                # Assume these are random < and > characters not a tag
                                if self.warnings:
                                    self.printErrorHeader(entry, self.log)
                                    print(f"WARNING: Assuming random < and > encountered, but could be a faulty tag too.", file=self.log)
                                skip = True
                            else:
                                # Suspicious, erroneous space(s) before tag name?
                                self.printErrorHeader(entry, self.log)
                                err += 1
                                print(f"ERROR: No space allowed when opening a tag, see [{tag}].", file=self.log)

                        if not skip:
                            open_tag = (len(tag) > 0)
                            if open_tag:
                                # no uppercase allowed in tag
                                lo_tag = tag.lower()
                                if tag != lo_tag:
                                    self.printErrorHeader(entry, self.log)
                                    err += 1
                                    print(f"ERROR: Opening tag [{tag}] should be all lowercase.", file=self.log)
                                    tag = lo_tag
                                # Add opening tag to stack
                                stack.append(tag)
                            else:
                                self.printErrorHeader(entry, self.log)
                                err += 1
                                print(f"ERROR: Empty opening tag <> not allowed.", file=self.log)
                else:
                    if len(tag) == 1:
                        # empty closing tag not allowed
                        err += 1
                        self.printErrorHeader(entry, self.log)
                        tag = tag[1:]
                        print(f"ERROR: Empty closing tag not allowed.", file=self.log)

                textblock = textblock[end_tag+1:]
                start_tag = textblock.find('<')
            else:
                start_tag = -1


        if len(stack):
            err += 1
            self.printErrorHeader(entry, self.log)
            print(f"ERROR: Found tags that were not closed: {str(stack)}.", file=self.log)

        return err

    def check_illegal_chars(self, entry):
        text = entry.msgstr
        result = 0
        idx = 0
        textlen = len(text)

        # msgfmt doesn't like vertical tab (\v) so detect it here...
        # See: https://gitlab.gnome.org/GNOME/gimp-help/-/commit/6b661af55bc6dc90bb198c59702d9b6cfc42f94f
        # Problem is that polib unescapes all strings, but doesn't handle \v
        # Starting with v. 1.2.0 it does handle \v.
        vert_tab = text.find("\\v")
        if vert_tab > -1:
            #result += 1
            if self.warnings:
                # for now just a warning until polib handles \v
                self.printErrorHeader(entry, self.log)
                print(f"WARNING: Possible vertical tab (\\v) detected. Note: could be a false positive.", file=self.log)
            #print(f"ERROR: Vertical tab (\\v) not allowed.", file=self.log)

        while idx < textlen:
            if text[idx] < ' ':
                if text[idx] != "\n" and text[idx] != "\t":
                    result += 1
                    self.printErrorHeader(entry, self.log)
                    if text[idx] == "\v":
                        print(f"ERROR: vertical tab \\v not allowed in text.", file=self.log)
                    elif text[idx] == "\r":
                        print(f"ERROR: \\r not allowed in text.", file=self.log)
                    elif text[idx] == "\b":
                        print(f"ERROR: \\b not allowed in text.", file=self.log)
                    else:
                        print(f"ERROR: Found illegal character in text: {ord(text[idx])}.", file=self.log)
                    print("Note: this is often caused by not escaping Windows path characters (\\).")

            idx += 1

        return result


    def run(self):
        errcnt = 0
        valid_entries = [e for e in self.po if not (e.obsolete or e.fuzzy)]
        for entry in valid_entries:
            skip_parse = False
            self.headerPrinted = False

            if entry.msgid.startswith("@@image:"):
                # TODO: check and warn for img not found msg?
                # But that probably shouldn't be done in the
                # po validator but in a source xml validator.
                continue
            elif entry.msgid.startswith("translator-credits"):
                # TODO: Should we check for translators not in AUTHORS?
                #continue
                # Parsing would give errors on email address like <a@b.c> because
                # it considers that a tag without closing tag
                # However, we do want to check for chars like \v
                skip_parse = True

            errcnt += self.check_illegal_chars(entry)
            if not skip_parse:
                errcnt += self.parse_text(entry)

            # TODO Possible enhancements:
            #      - Compare tags found in msgid and msgstr
            #        The same tags and the same number of tags should be found
            #      - compare msgid and msgstr also for differences in:
            #        + number of brackets () [] {}
            #        + number of sentences
            #        + use of quotes (which can differ per language)

        if errcnt > 0:
            self.errors += errcnt
            self.files_with_errors += 1
            print(f"\n{self.pofile}: {errcnt} errors detected.\n")

def printVersion():
    print(f"\nPo Validator v {VERSION}, copyright 2021, 2022 Jacob Boerema")

def main(argv):
    # Make sure stdout and stderr output utf-8 even on Windows where it's not the default
    sys.stdout = open(sys.stdout.fileno(), 'w', encoding='utf-8', closefd=False)
    sys.stderr = open(sys.stderr.fileno(), 'w', encoding='utf-8', closefd=False)

    verbose = False
    warnings = False

    try:
        opts, remaining_args = getopt.getopt(argv, "hvw",
            [
                "help", "verbose", "warnings"
            ])
    except getopt.GetoptError as err:
        usage()
        sys.exit(0)

    for opt, arg in opts:
        if opt == "-h" or opt == "--help":
            usage()
            sys.exit(0)
        elif opt == "-v" or opt == "--verbose":
            verbose = True
        elif opt == "-w" or opt == "--warnings":
            warnings = True

    # Treat remaining arguments as po files
    filenames = []
    while remaining_args:
        filenames.append(remaining_args.pop())

    if len(filenames) == 0:
        usage()
        sys.exit(0)

    if verbose:
        printVersion()

    validator = Validate(verbose, warnings)
    for file in filenames:
        if verbose:
            print(f"Checking {file}")
        validator.setFile(file)
        validator.run()

    if validator.errors > 0:
        print(f"{validator.files_with_errors} of {validator.filecnt} files contain errors")
        print(f"Total number of errors: {validator.errors}")
        sys.exit(1)


def usage():
    printVersion()
    print("""Validates correct use of XML tags and other possible causes of problems in po files.

usage: validate_po.py [options] POFILES

    options:
        -v      --verbose       be more verbose
        -w      --warnings      show warnings
        -h      --help          this help""")


if __name__ == "__main__":
    main(sys.argv[1:])