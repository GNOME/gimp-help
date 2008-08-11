#########################################################################
####            Preliminaries: Variables and Functions              ####
########################################################################

# The GIMP manual languages
ifneq ($(ALL_LINGUAS),)
LANGUAGES  = $(ALL_LINGUAS)
else
ifneq ($(LINGUAS),)
LANGUAGES  = $(LINGUAS)
else
LANGUAGES ?= de en es fr it ko nl no pl ru sv
endif
endif
XML_LANG   = en
PO_LANGS   = $(filter-out $(XML_LANG), $(LANGUAGES))

# Essential external programs and their default options
XSLTPROC  = $(fake) xsltproc
XSLTFLAGS = --nonet

XMLLINT      = $(fake) xmllint
XMLLINTFLAGS = --nonet -noout

XML2PO   = $(fake) xml2po

MSGINIT  = $(fake) msginit
MSGFMT   = $(fake) msgfmt
MSGMERGE = $(fake) msgmerge
MSGINITFLAGS  = --no-translator
MSGFMTFLAGS   = --check --use-fuzzy --statistics
MSGMERGEFLAGS = --quiet --backup=none --update

# Simple commands
mkdir_p = mkdir -p
ln_s    = ln -s

# FIXME/TODO:
#     (1) make it work with srcdir != builddir
#     (2) rename(?) srcdir, xmldir, xmlpodir
# Directories
srcdir   = .
builddir = .
xmldir   = src
potdir   = pot
podir    = po
xmlpodir = xml
htmldir  = html

# Find files and directories
xml_file_predicates =       \
	-name '.svn' -prune \
	          -o        \
	-name '*.xml' -print

dir_predicates =        \
	-name '.svn' -prune \
	        -o          \
	-type d -print
xml_dir_predicates = $(dir_predicates)
pot_dir_predicates = $(dir_predicates)

# Files & directories
XML_FILES := $(shell cd $(srcdir) && find $(xmldir) $(xml_file_predicates))
XML_DIRS  := $(shell cd $(srcdir) && find $(xmldir) $(dir_predicates))
#DIR_TREE   = $(patsubst $(xmldir)/%, %, $(XML_DIRS))
DIR_TREE   = $(XML_DIRS:$(xmldir)/%=%)

#POT_FILES  = $(patsubst $(xmldir)/%.xml, $(potdir)/%.pot, $(XML_FILES))
POT_FILES  = $(XML_FILES:$(xmldir)/%.xml=$(potdir)/%.pot)
#POT_DIRS   = $(patsubst $(xmldir)/%, $(potdir)/%, $(XML_DIRS))
POT_DIRS   = $(XML_DIRS:$(xmldir)/%=$(potdir)/%)

# XXX: requires that "plainhtml.xsl" has been renamed to "html.xsl"
HTML_STYLESHEETS = stylesheets/html*.xsl


# To talk or not to talk, that is the question!
VERBOSE ?= 1

# Usage of the "msg" and "cmd" variables:
# In the command lines of the make rules, use
#     $(msg) bla bla bla   instead of   @echo bla bla bla
#     $(cmd) command args  instead of   @command args (or command args)
# then
#     messages will be suppressed if VERBOSE=0,
#     commands will be printed if VERBOSE=2.
#
ifeq ("$(VERBOSE)", "0")
msg = @:
cmd = @
else
ifeq ("$(VERBOSE)", "1")
msg = @echo
cmd = @
else
msg = @echo
cmd =
endif
endif

# Testing & debugging
ifeq ($(DEBUG),)
fake      =
else
fake      = echo
endif


#--------------------------------------------------------------#
#       The main functions used to transform                   #
#               (a) XML files to POT files                     #
#               (b) POT files to PO files                      #
#               (c) XML and PO files to XML files              #
#--------------------------------------------------------------#

# Create a PO-template
#
# Usage:
#     $(call xml2pot,xml-file,pot-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - POT template file containing translatable tags
xml2pot = $(XML2PO) --output="$(2)" $(1) 2>&1 \
          | sed -e '/Warning: image file .* not found./d'

# Merge template (pot) and message catalog (po) or create a new catalog
#
# Usage:
#     $(call pot2po,pot-file,language,po-file)
# Parameters:
#     $1 - input POT file
#     $2 - translation language
#     $3 - output PO file
# TODO: include compendium (cf. "info msgmerge")
pot2po  = if [ -f $@ ]; then \
              $(MSGFMT)   $(MSGFMTFLAGS)   $(3); \
              $(MSGMERGE) $(MSGMERGEFLAGS) $(3) $(1) && touch $(3); \
          else \
              $(MSGINIT)  $(MSGINITFLAGS) --input $(1) --locale=$(2) --output $(3); \
          fi

# Merge PO file into (translated) XML file
#
# Usage:
#     $(call po2xml,en-xml-file,po-file,language,translated-xml-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - PO file containing translations
#     $3 - translation language
#     $4 - resulting (translated) XML file
po2xml  = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
          | sed -e '/Warning: image file .* not found./d'


########################################################################
####            Main targets                                        ####
########################################################################

first: all

# ignore
validate: ;
html: ;
#index: ;
AUTHORS: ;

all: validate html index AUTHORS


########################################################################
####            Help!!!                                             ####
########################################################################

.PHONY: help
help:
	@echo 'Common targets:'
	@printf '  %s\t- %s.\n' \
	'html-<LANG>' 'Build HTML for language <LANG> (implies xml-<LANG>)' \
	'xml-<LANG> ' 'Create/update XML files for language <LANG> (implies po-<LANG>)' \
	'po-<LANG>  ' 'Create/update PO files for language <LANG> (implies pot)' \
	'pot        ' 'Create/update POT files'
	@echo '(where <LANG> is one of' $(shell echo $(LANGUAGES) | sed -e 's/ /,&/g')')'


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################

# xmldir/path/to/file.xml --> potdir/path/to/file.pot
$(POT_FILES): $(potdir)/%.pot : $(xmldir)/%.xml
	$(cmd) f=$@; d=$${f%/*}; test -d $$d || $(mkdir_p) $$d
	$(msg) "[POT] $@"
	$(cmd) if test -s $<; then $(call xml2pot,$<,$@); else touch $@; fi

# Targets suitable for command line
# ("make pot" will work even if pot exists)
pot update-pot: potfiles
potfiles: $(POT_FILES)


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################

define MAKE_PO_RULES
$(1)_PO_FILES = $$(patsubst $$(potdir)/%.pot, $$(podir)/$(1)/%.po, $$(POT_FILES))
$$($(1)_PO_FILES): $$(podir)/$(1)/%.po : $$(potdir)/%.pot
	$$(cmd) f=$$@; d=$$$${f%/*}; test -d $$$$d || $$(mkdir_p) $$$$d
	$$(msg) "[PO]  $$@"
	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
# Debugging
list-pofiles-$(1) list-po-files-$(1) list-po-$(1):
	@echo $$($(1)_PO_FILES)
po-$(1): $$($(1)_PO_FILES)
	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_PO_RULES,$(LANG))))

# Targets suitable for command line
update-po-%: po-%

# Special case 'en': do nothing :-)
po-en: ;


########################################################################
####            Make XML files  [PO --> XML(non-en)]                ####
########################################################################

#$(1)_XML_FILES = $$(patsubst $$(podir)/$(1)/%.po, $$(xmlpodir)/$(1)/%.xml, $$($(1)_PO_FILES))
define MAKE_XML_RULES
$(1)_XML_FILES = $$(XML_FILES:$$(xmldir)/%=$$(xmlpodir)/$(1)/%)
$$($(1)_XML_FILES): $$(xmlpodir)/$(1)/%.xml : $$(podir)/$(1)/%.po
	$$(cmd) f=$$@; d=$$$${f%/*}; test -d $$$$d || $$(mkdir_p) $$$$d
	$$(msg) "[XML] $$@"
	$$(cmd) if test -s $$(@:$$(xmlpodir)/$(1)/%=$$(xmldir)/%); then \
		$$(call po2xml,$$(@:$$(xmlpodir)/$(1)/%=$$(xmldir)/%),$$<,$(1),$$@); \
	else \
		touch $$@; \
	fi
# This is indirectly used as HTML prerequisite:
$$(xmlpodir)/$(1): $$($(1)_XML_FILES)
	$$(cmd) touch $$(xmlpodir)/$(1)
# Debugging
list-xmlfiles-$(1) list-xml-files-$(1) list-xml-$(1):
	@echo $$($(1)_XML_FILES)
# Targets suitable for command line
xml-$(1): $$($(1)_XML_FILES)
endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# Special case: en
en_XML_FILES = $(XML_FILES:$(xmldir)/%=$(xmlpodir)/en/%)
$(en_XML_FILES): xmldir-en

xmldir-en: $(xmlpodir)/en ;
# TODO: make relative link rather than absolute link(?)
$(xmlpodir)/en: $(XML_FILES)
	$(cmd) target_dir=$$(cd $(srcdir)/$(xmldir) && pwd); \
	link_dir=$(builddir)/$(xmlpodir); \
	test -d $${link_dir} || $(fake) $(mkdir_p) $${link_dir}; \
	test -d $${link_dir}/en || $(fake) $(ln_s) $${target_dir} $${link_dir}/en; \
	touch $@


# Targets suitable for command line

# Special case: en
xml-en: xmldir-en

# Debugging
list-xmlfiles-en list-xml-files-en list-xml-en:
	@echo $(en_XML_FILES)


########################################################################
####            Make HTML files:  XML --> HTML                      ####
########################################################################

html-%: po-% index-% html/%/index.html ;

html/%/index.html: $(xmlpodir)/% $(HTML_STYLESHEETS)
	$(msg) "*** Making html for $* ... "
	$(cmd) rm -rf html/$*
	$(cmd) $(mkdir_p) html/$*
	$(cmd) test -L html/images || $(ln_s) ../images html/

	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  --xinclude \
	  --stringparam l10n.gentext.default.language $* \
	  -o html/$*/ \
	  stylesheets/html.xsl \
	  $(xmlpodir)/$*/gimp.xml

	$(cmd) for file in $(srcdir)/stylesheets/*.css; do \
		test -f $$file || continue; \
		cp -fp $$file html/$*; \
	done

	$(cmd) for file in $(srcdir)/stylesheets/$*/*.css; do \
		test -f $$file || continue; \
		cp -fp $$file html/$*; \
	done

# The xrefs file is a side effect of the HTML build
html/%/gimp-xrefs.xml: html/%/index.html
	$(cmd) touch $@

####  Context Help  ####
# XXX: IMHO "index" is a bad name
index: $(foreach lang,$(LANGUAGES),index-$(lang)) ;
index-%: html/%/gimp-help.xml ;

html/%/gimp-help.xml: html/%/gimp-xrefs.xml stylesheets/makeindex.xsl
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/makeindex.xsl \
	  $< \
	  > $@

.PRECIOUS: \
	html/%/index.html \
	html/%/gimp-help.xml \
	html/%/gimp-xrefs.xml


########################################################################
####            Debugging etc.                                      ####
########################################################################

list-xmlfiles list-xml-files list-xml:
	@echo $(XML_FILES)

list-potfiles list-pot-files list-pot:
	@echo $(POT_FILES)

build-system.png: build-system.dot
	@if type dot >/dev/null; then \
		dot -Tpng -o $@ $<; \
	fi

dot: build-system.png
	@if test -e $<; then \
		if type display >/dev/null; then \
			display $<; \
		elif type xv >/dev/null; then \
			xv $<; \
		fi; \
	fi


########################################################################
####     Miscellaneous stuff, to be removed...                      ####
########################################################################

# Clone a directory tree
#     $1 - location of destination directory tree
#     $2 - list of source directories [XXX: drop this in favour of $(XML_DIRS)?]
#clone_dirtree = for sourcedir in $(2); do \
#                    test "$${sourcedir}" != "." || sourcedir="" ; \
#                    sourcedir=$${sourcedir\#./}; \
#                    destdir=$(builddir)/$(1)/$${sourcedir}; \
#                    test -d $${destdir} || $(fake) $(mkdir_p) $${destdir}; \
#                done

# Get the XML files (prerequisites) for the HTML target
#     $1 - locale (en, de, es, fr, ...)
# Returns
#     $(XML_FILES)             if $1 is 'en', 
#     translated $(XML_FILES)  otherwise
#xml_po_files = $(if $(findstring en,$(1)),$(XML_FILES),$(subst $(xmldir),$(xmlpodir)/$(1),$(XML_FILES)))
#xml_po_files = $(subst $(xmldir),$(xmlpodir)/$(1),$(XML_FILES))

# XXX: do we need this?
# Special case 'en'
#htmldir-en: $(xmldir)
#
#htmldir-%: xmldir-%
#	$(msg) "Making $@"
#	$(cmd) $(call clone_dirtree,html/$*,$(DIR_TREE))

# XXX: I'm not sure if the following rule (using a function) works -
# it seems to depend on the function...
#html/%/index.html: $(call xml_po_files,%) $(HTML_STYLESHEETS)

#html/en/index.html: $(call xml_po_files,en) $(HTML_STYLESHEETS)
#html/en/index.html: $(XML_FILES) $(HTML_STYLESHEETS)

# XXX: do we need this?
#xmldir-%: podir-%
#	$(msg) "Making $(xmlpodir)/$* directories"
#	$(cmd) $(call clone_dirtree,$(xmlpodir)/$*,$(DIR_TREE))


# XXX: do we need this?
#podir-%: $(POT_DIRS)
#	$(msg) "Making po directories ($*)"
#	$(cmd) $(call clone_dirtree,$(podir)/$*,$(DIR_TREE))

# XXX: do we need this?
#podir-en:
#	@echo >&2 "Skipped making po directory for 'en'."

# XXX: do we need this?
#potdir: $(POT_DIRS)
#	$(msg) "Making pot directories ($(potdir))... "
#	$(cmd)$(call clone_dirtree,$(potdir),$(DIR_TREE))

