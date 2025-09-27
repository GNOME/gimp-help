########################################################################
####            Configuration (system-dependent) variables          ####
########################################################################

CYGWIN = $(shell make.d/test/is_cygwin.sh || echo 0)


########################################################################
####            The GIMP manual languages                           ####
########################################################################

ALL_LINGUAS = bg ca cs da de el en en_GB eo es fa fi fr hr hu it ja ko lt nl nn pl pt pt_BR ro ru sk sl sv tr uk zh_CN
LANGUAGES = $(if $(LINGUAS),$(filter $(ALL_LINGUAS),$(LINGUAS)),$(ALL_LINGUAS))
ifneq ($(DOC_LINGUAS),)
$(warning Do not set the internal variable DOC_LINGUAS)
endif
DOC_LINGUAS = $(LINGUAS)

ifneq ($(XML_LANG),)
$(error You must not set the internal variable XML_LANG)
endif
ifneq ($(PO_LANGS),)
$(error You must not set the internal variable PO_LANGS)
endif
XML_LANG = en
PO_LANGS = $(filter-out $(XML_LANG), $(LANGUAGES))


########################################################################
####            External programs                                   ####
########################################################################

XSLTPROC  = xsltproc
XSLTFLAGS = --nonet

XMLLINT      = xmllint
XMLLINTFLAGS = --nonet

XML2PO        = tools/xml2po.py
XML2POFLAGS   = --mode=gimphelp

MSGWIDTH      = 79
MSGUNIQ       = msguniq
MSGUNIQFLAGS  =
MSGCAT        = msgcat
MSGCATFLAGS   = --width=$(MSGWIDTH)
MSGINIT       = msginit
MSGINITFLAGS  = --no-translator --width=$(MSGWIDTH)
MSGFMT        = msgfmt
MSGFMTFLAGS   = --check --use-fuzzy --statistics
MSGMERGE      = msgmerge
MSGMERGEFLAGS = --quiet --width=$(MSGWIDTH)

DBLATEX          = dblatex
DBLATEXFLAGS     = --verbose

SED = sed

# Standard shell commands
echo_n  = echo -n
mkdir_p = mkdir -p
ln_s    = ln -s
find_l  = find -L

# Calling make recursively
RMAKE = $(MAKE) -f Makefile.GNU --no-print-directory

# Local (gimp-help-specific) tools
MAKE_IMAGE_LINKS = make.d/make_image_links.pl
MAKE_IMAGE_LINKS_FLAGS = -v
ifeq ($(CYGWIN),1)
    MAKE_IMAGE_LINKS_FLAGS += --mode=hardlink,copy
endif

# FIXME/TODO:
#     make it work with srcdir != builddir
# Directories
srcdir   = .
builddir = .
abs_srcdir   := $(shell cd $(srcdir) && pwd)
abs_builddir := $(shell pwd)


########################################################################
####            Files and directories                               ####
########################################################################

src_file_predicates = \
	-name '*.xml' \
	-not -name '$(notdir $(AUTHORS_DOCBOOK_XML))'
src_dir_predicates  = -name images -prune -o -type d -print
pot_file_predicates = -type f
po_file_predicates  = -type f -not -name "$(COMPENDIUM)"
xml_file_predicates = -name '*.xml'

# List of authors and contributors (no DocBook)
AUTHORS_SOURCE_XML = stylesheets/authors.xml
# Automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML      = src/preface/authors.xml
AUTHORS_DOCBOOK_DIRNAME  = $(dir $(AUTHORS_DOCBOOK_XML))
AUTHORS_DOCBOOK_FILENAME = $(notdir $(AUTHORS_DOCBOOK_XML))
# Stylesheets generating AUTHORS
AUTHORS_TEXT_STYLESHEETS = \
	stylesheets/authors_text.xsl \
	stylesheets/authors_common.xsl
# Stylesheets generating src/preface/authors.xml
AUTHORS_DOCBOOK_STYLESHEETS = \
	stylesheets/authors_docbook.xsl \
	stylesheets/authors_common.xsl
# Stylesheet generating MAINTAINERS
DOAP_STYLESHEET = stylesheets/doap2text.xsl

# Targets which don't require source file list
QUICK_TARGETS = help clean dot image-% AUTHORS MAINTAINERS

# Files & directories
ifeq ($(filter $(QUICK_TARGETS),$(MAKECMDGOALS)),)
SRC_DIRS  := $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
SRC_FILES := $(shell cd $(srcdir) && $(find_l) src/ $(src_file_predicates)) \
             $(AUTHORS_DOCBOOK_XML)
else
SRC_DIRS   = $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
SRC_FILES  = $(shell cd $(srcdir) && $(find_l) src/ $(src_file_predicates)) \
             $(AUTHORS_DOCBOOK_XML)
endif

# TODO
#HTML_STYLESHEETS = stylesheets/html*.xsl
HTML_STYLESHEETS = stylesheets/plainhtml.xsl stylesheets/htmlalternate.xsl

# This variable is used by "msgmerge";
# use empty variable to disable the compendium option
COMPENDIUM = Compendium.po


########################################################################
####            Control the amount of output messages               ####
########################################################################

# Usage of the "msg" and "cmd" variables:
# In the command lines of the make rules, use
#     $(msg) bla bla bla   instead of   @echo bla bla bla
#     $(cmd) command args  instead of   @command args (or command args)
# then
#     messages will be suppressed if VERBOSE=0,
#     commands will be printed if VERBOSE=2.

VERBOSE = 1

ifeq ($(VERBOSE),0)
msg = @:
cmd = @
else
ifeq ($(VERBOSE),1)
msg = @echo
cmd = @
else
msg = @echo
cmd =
endif
endif


########################################################################
####            Functions                                           ####
########################################################################

#--------------------------------------------------------------#
#       The main functions used to transform                   #
#               (a) XML files to POT files                     #
#               (b) POT files to PO files                      #
#               (c) XML and PO files to XML files              #
#--------------------------------------------------------------#

# Create a PO-template (POT)
#
# Usage:
#     $(call xml2pot,xml-files,pot-file)
# Parameters:
#     $1 - input:  original (untranslated) XML files
#                  and other prerequisites, e.g. images or "FORCE"
#     $2 - output: POT template file containing translatable tags
xml2pot = $(XML2PO) $(XML2POFLAGS) --output='-' $(filter %.xml,$(1)) \
          | $(MSGUNIQ) $(MSGUNIQFLAGS) \
          | $(MSGCAT) $(MSGCATFLAGS) - > "$(2)"; \
          test -s "$(2)" || rm -f "$(2)"; \
          touch -c -r $(call get_recent_file,$(1)) "$(2)" || true; \
          test -s "$(2)"

# Merge template (pot) and message catalog (po) or create a new catalog
#
# Usage:
#     $(call pot2po,pot-file,language,po-file)
# Parameters:
#     $1 - input POT file
#     $2 - translation language
#     $3 - output PO file
pot2po = test -e $(3) || \
             $(MSGINIT) $(MSGINITFLAGS) --input $(1) --locale=$(2) --output=$(3); \
         with_compendium="$(shell $(call get_compendium,$3)) \
                          $(shell $(call use_gimp_po_files,$2))"; \
         $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} --update $(3) $(1) \
         && $(MSGFMT) $(MSGFMTFLAGS) $(3) || exit 70; \
         rm -f $(3)~ messages.mo messages.gmo

# Merge PO file into (translated) XML file
#
# Usage:
#     $(call po2xml,en-xml-file,po-file,language,translated-xml-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - PO file containing translations
#     $3 - translation language
#     $4 - resulting (translated) XML file
ifneq ($(FORMAT_XML_WITH_XMLLINT),1)
po2xml = $(XML2PO) $(XML2POFLAGS) --po-file=$(2) --language=$(3) --output=$(4) $(1); \
         rm -f .xml2po.mo
else
po2xml = ($(XML2PO) $(XML2POFLAGS) --po-file=$(2) --language=$(3) --output='-' $(1) \
         | $(XMLLINT) $(XMLLINTFLAGS) --format --output $(4) -); \
         rm -f .xml2po.mo
endif


#--------------------------------------------------------------#
#       Helper functions                                       #
#--------------------------------------------------------------#

make_target_dir = f=$(1); d=$${f%/*}; test -d $$d || $(mkdir_p) $$d

get_recent_file = $(shell ls -t $(1) 2>/dev/null | head -n 1)

copy = $(ln_s) $(abs_srcdir)/$(1) $(2)

ifneq ($(COMPENDIUM),)
get_compendium = \
	file="$(1)"; dir=$${file%/*}; \
	while true; do \
		if test -f $${dir}/$(COMPENDIUM); then \
			echo "--compendium=$${dir}/$(COMPENDIUM)"; \
		fi; \
		case "$${dir}" in \
			po|*/po) break;; \
			    */*) dir="$${dir%/*}";; \
			      *) break;; \
		esac; \
	done
else
get_compendium =
endif

ifneq ($(GIMP_PO_ROOT),)
use_gimp_po_files = \
	for po in $(GIMP_PO_ROOT)/po*/$(1).po; do \
		if test -f "$${po}"; then echo '--compendium'="$${po}"; fi; \
	done
else
use_gimp_po_files =
endif


########################################################################
####            Main targets                                        ####
########################################################################

.PHONY: all
all: html index AUTHORS MAINTAINERS


########################################################################
####            Help!!!                                             ####
########################################################################

.PHONY: help
make.help:
	@echo >&2 'ERROR: cannot find the help file "$@"!'
	@exit 66
# TODO?: replace with a "real" script (e.g. tools/make-help.sed)
#   (probably "yes" if more features are needed...)
help: make.help
	@$(SED) \
	    -e '### skip comments ###' \
	    -e '/^#/d' \
	    -e '### print if no "make" variable found ###' \
	    -e '/%/!b' \
	    -e '### replace "make" variables ###' \
	    -e 's/%LANGUAGES%/%$(strip $(LANGUAGES))%/' \
	    -e 's/%LINGUAS%/%$(strip $(LINGUAS))%/' \
	    -e 's/%ALL_LINGUAS%/%$(strip $(ALL_LINGUAS))%/' \
	$<


########################################################################
####            Make AUTHORS and MAINTAINERS file                   ####
########################################################################

AUTHORS: $(AUTHORS_SOURCE_XML) $(AUTHORS_TEXT_STYLESHEETS)
	$(msg) "[DOC] $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/authors_text.xsl \
	  $< \
	  > $@

$(AUTHORS_DOCBOOK_XML): $(AUTHORS_SOURCE_XML) $(AUTHORS_DOCBOOK_STYLESHEETS)
	$(msg) "[SRC] $@"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/authors_docbook.xsl \
	  $< \
	  > $@

MAINTAINERS: gimp-help.doap $(DOAP_STYLESHEET)
	$(msg) "[DOC] $@"
	$(cmd) $(XSLTPROC) --output $@ $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(DOAP_STYLESHEET) $<


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################

# src/path/to/file/*.xml --> pot/path/to/file.pot
POT_FILES  = $(patsubst src/%,pot/%.pot,$(filter-out src src/,$(SRC_DIRS)))
# Special case: src/*.xml --> pot/gimp.pot
POT_FILES += pot/gimp.pot

# XXX: Secondary Expansion of the following two rules is required because
# "pot/%.pot: $(srcdir)/src/%/*.xml" didn't work with make v3.82
# (cf. bug #637505).
.SECONDEXPANSION:
# General case
ifeq ($(filter pot/%.pot po/%.po,$(MAKECMDGOALS)),)
pot/%.pot: src/$$*/*.xml $$(wildcard images/C/$$*/*.*)
else
pot/%.pot: src/$$*/*.xml FORCE
endif
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)
# Special case: rename pot file for toplevel xml files
ifeq ($(filter pot/%.pot po/%.po,$(MAKECMDGOALS)),)
pot/gimp.pot: src/*.xml $(wildcard images/C/*.*)
else
pot/gimp.pot: src/*.xml FORCE
endif
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)
# Special case: pot file for the authors DocBook file
# requires an additional prerequisite
AUTHORS_POT = $(AUTHORS_DOCBOOK_XML:src/%/$(AUTHORS_DOCBOOK_FILENAME)=pot/%.pot)
ifeq ($(filter pot/%.pot po/%.po,$(MAKECMDGOALS)),)
# TODO: add images to prerequisites if necessary
$(AUTHORS_POT): $(AUTHORS_DOCBOOK_XML) $(wildcard $(AUTHORS_DOCBOOK_DIRNAME)*.xml)
else
$(AUTHORS_POT): $(AUTHORS_DOCBOOK_XML) $(wildcard $(AUTHORS_DOCBOOK_DIRNAME)*.xml) FORCE
endif
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)

# Remove left over pot files
cleanup-pot:
	$(msg) "Cleaning up pot files ..."
	$(cmd) $(find_l) pot/ $(pot_file_predicates) | \
	while read potfile; do \
		potfile=$${potfile#pot/}; srcfile=src/$${potfile%.pot}.xml \
		test -e $${srcfile} || rm -f $${potfile}; \
	done

# Targets suitable for command line
pot: potfiles cleanup-pot ;
potfiles: $(POT_FILES) ;

.PHONY: pot potfiles cleanup-pot


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################

define MAKE_PO_RULES
$(1)_PO_FILES = $$(patsubst pot/%.pot, $(srcdir)/po/$(1)/%.po, $$(POT_FILES))
ifeq ($$(filter $(srcdir)/po/$(1)/%.po,$$(MAKECMDGOALS)),)
$$($(1)_PO_FILES): $(srcdir)/po/$(1)/%.po : pot/%.pot
else
$$($(1)_PO_FILES): $(srcdir)/po/$(1)/%.po : pot/%.pot FORCE
endif
	$$(cmd) $$(call make_target_dir,$$@)
	$$(msg) "[PO]  $$@"
	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
po-$(1): $$($(1)_PO_FILES) cleanup-po-$(1)
	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
cleanup-po-$(1):
	$$(msg) "Cleaning up '$(1)' po files ..."
	$$(cmd) $(find_l) po/$(1)/ $$(po_file_predicates) | \
	while read pofile; do \
		potfile=pot/$$$${pofile#po/$(1)/}t; \
		test -e $$$${potfile} || rm -vf $$$${pofile}; \
	done
endef
$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_PO_RULES,$(LANG))))

# Special case 'en': do nothing :-)
po-en: ;

# Print translation statistics

status-%: po-status-% ;
po-status-%: po-%
	$(cmd) perl tools/get_po_status.pl po/$*

status-all: po-status-all ;
po-status-all:
	$(cmd) for podir in po/*; do \
		perl tools/get_po_status.pl --nofiles --nosummary $${podir} || break; \
	done

todo-%: po-todo-% ;
po-todo-%: po-%
	$(cmd) perl tools/get_po_status.pl --todo po/$*

# Force updating po file(s)
force-po/%:
	$(cmd) $(RMAKE) po/$*/*.po

# Main commandline target
po: $(foreach LANG,$(PO_LANGS),po-$(LANG)) ;

.PHONY: po po-% cleanup-po-% todo-% po-todo-% po-status-%


########################################################################
####            Generate XML prerequisites                          ####
########################################################################

ifeq ($(filter $(QUICK_TARGETS),$(MAKECMDGOALS)),)
include $(foreach LANG,$(PO_LANGS),xml/$(LANG)/.deps.mk)
endif

# The dynamically generated and updated ".deps.mk" files contain
# rules to register the po prereqisite for every xml file, e.g.
#	xml/LANG/*.xml: po/LANG/gimp.po
#	xml/LANG/filters/*.xml: po/LANG/filters.po
#	xml/LANG/filters/generic/*.xml: po/LANG/filters/generic.po
#	etc.

#xml/$(1)/.deps.mk: $(AUTHORS_DOCBOOK_XML) $$($(1)_PO_FILES)
# TODO: simplify
define MAKE_DEP_RULES
xml/$(1)/.deps.mk: $(AUTHORS_DOCBOOK_XML) $$(SRC_FILES)
	$$(cmd) $$(call make_target_dir,$$@)
	$$(msg) "[DEP] $$@"
	$$(cmd) touch $$@
	$$(cmd) for srcdir in $(SRC_DIRS); do \
		ls $$$${srcdir}/*.xml >/dev/null 2>&1 || continue; \
		srcdir=$$$${srcdir%/}; \
		xmldir=xml/$(1)$$$${srcdir#src}; \
		test "$$$${srcdir}" != "src" || srcdir="src/gimp"; \
		pofile=po/$(1)$$$${srcdir#src}.po; \
		echo "$$$${xmldir}/*.xml: $$$${pofile}"; \
	done > $$@
endef
$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_DEP_RULES,$(LANG))))


########################################################################
####            Make XML files:  PO --> XML(non-en)                 ####
########################################################################

# TODO: check xml/$(1) vs. xml-$(1) prerequisites (XML_FILES)
define MAKE_XML_RULES
$(1)_XML_FILES = $$(SRC_FILES:src/%=xml/$(1)/%)
xml/$(1)/%.xml:
	$$(msg) "[XML] $$@"
	$$(cmd) $$(call make_target_dir,$$@)
	$$(cmd) xmlfile=$$@; \
	stem=$$*; \
	srcfile=src/$$$${stem}.xml; \
	test "$$$${stem}" != "$$$${stem%/*}" && stem=$$$${stem%/*} || stem=gimp; \
	pofile=po/$(1)/$$$${stem}.po; \
	test -e "$$$${pofile}" || $$(RMAKE) "$$$${pofile}"; \
	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)

# This is indirectly used as HTML and PDF prerequisite:
xml/$(1): $$($(1)_XML_FILES) | xml/$(1)/images
	$$(cmd) test -d $$@ && touch $$@ || $(mkdir_p) $$@

# Targets suitable for command line
xml-$(1): po-$(1) xml/$(1) cleanup-xml-$(1) ;
endef
$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# Special case: en

en_XML_FILES = $(SRC_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(msg) "[XML] $@ (copy)"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) cp -f $< $@

xml/en: $(en_XML_FILES) | xml/en/images
	$(cmd) test -d $@ && touch $@ || $(mkdir_p) $@

xml-en: xml/en cleanup-xml-en ;

# Images

ifeq ($(MAKE_IMAGES), lazy)
# fast and lazy: detect added or removed images, but may miss changed images
IMAGE_PREREQ = $(shell cd $(srcdir) && $(find_l) images/common images/C -type d)
else ifeq ($(MAKE_IMAGES), force)
# just in case: always update images
IMAGE_PREREQ = FORCE
else
# strict (default): detects added, removed, or changed images
IMAGE_PREREQ = $(shell cd $(srcdir) && $(find_l) images/common images/C)
endif

xml/%/images: $(IMAGE_PREREQ)
	$(cmd) test -d $@ && rm -rf $@/* || $(mkdir_p) $@
	$(cmd) $(echo_n) "Copying images ($*) ..."
	$(cmd) perl $(MAKE_IMAGE_LINKS) $(MAKE_IMAGE_LINKS_FLAGS) \
	                images/common images/C xml/$*
	$(cmd) touch $@

# Remove left over xml files
cleanup-xml-%:
	$(msg) "Cleaning up '$*' xml files ..."
	$(cmd) $(find_l) xml/$*/ $(xml_file_predicates) | \
	while read xmlfile; do \
		test -e src/$${xmlfile#xml/$*/} || rm -vf $${xmlfile}; \
	done

# Command-line targets
xml: $(foreach LANG,$(LANGUAGES),xml-$(LANG)) ;
images-%: xml/%/images html/%/images ;

.PRECIOUS: xml/%/images
.PHONY: xml xml-% images-%


########################################################################
####            XML validation                                      ####
########################################################################

validate: validate-en ;
validate-%: xmllint-% ;
validate-all: $(foreach LANG,$(LANGUAGES),validate-$(LANG)) ;

xmllint: xmllint-en ;
xmllint-%: log/%-xmllint.log
	$(cmd) test -s $< && cat $<

define MAKE_XMLLINT_RULES
log/$(1)-xmllint.log: $$($(1)_XML_FILES)
	$$(cmd) $$(call make_target_dir,$$(@))
	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
		echo "*** Validating XML ($(1)) ... "; \
		$$(XMLLINT) $$(XMLLINTFLAGS) --noent --xinclude xml/$(1)/gimp.xml \
		| $$(SED) -e 's,xmlns:xi="http://www.w3.org/2001/XInclude",,' \
		| $$(XMLLINT) $$(XMLLINTFLAGS) --valid \
			--output log/$(1).xml - 2>$$(@); \
		if test -s $$(@); then \
			echo "(You will find log and xml files in log/.)"; \
		else \
			echo "$(1): no errors."; \
			rm -f  log/$(1).xml; \
		fi >> $$(@); \
	else \
		echo >&2 "*** Validating '$(1)' skipped: 'xmllint' not found."; \
	fi
endef
$(foreach LANG,$(LANGUAGES),$(eval $(call MAKE_XMLLINT_RULES,$(LANG))))

log:
	$(cmd) mkdir $@ && test -w $@


########################################################################
####            Make XSL styesheets for HTML                        ####
########################################################################

# TODO
stylesheets/plainhtml.xsl: stylesheets/plainhtml.xsl.in
	$(msg) "[XSL] $@"
	$(cmd) $(SED) -e s,@STYLEBASE@,http://docbook.sourceforge.net/release/xsl/current, $< > $@

stylesheets/htmlalternate.xsl: stylesheets/htmlalternate.xsl.in
	$(msg) "[XSL] $@"
	$(cmd) cp $< $@


########################################################################
####            Make HTML files:  XML --> HTML                      ####
########################################################################

# Main commandline targets
html-%: xml-% html/%/index.html html/%/gimp-help.xml ;
html: $(foreach lang,$(LANGUAGES),html-$(lang)) ;

# Making the main HTML file (side effect: make gimp-xrefs.xml)
html/%/index.html: xml/% $(HTML_STYLESHEETS) | html/%/images
	$(msg) "*** Making html for $* ... "
	$(cmd) rm -f html/$*/*.*

	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  --xinclude \
	  --stringparam l10n.gentext.default.language $* \
	  -o html/$*/ \
	  stylesheets/plainhtml.xsl \
	  xml/$*/gimp.xml

	$(msg) "Copying stylesheets ... "
	$(cmd) for file in $(srcdir)/stylesheets/*.css \
	                   $(srcdir)/stylesheets/$*/*.css; do \
		if [ -f $${file} ]; then cp -f $${file} html/$*; fi; \
	done

###  Cross references & context help ###
index: $(foreach lang,$(LANGUAGES),index-$(lang)) ;
index-%: html/%/gimp-help.xml ;

html/%/gimp-help.xml: html/%/gimp-xrefs.xml stylesheets/makeindex.xsl
	$(msg) "[XML] $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/makeindex.xsl \
	  $< \
	  > $@

# Making index includes creating sort keys
stylesheets/makeindex.xsl: stylesheets/getsortkey.xsl
	$(cmd) touch $@

# The xrefs file is a side effect of the HTML build
html/%/gimp-xrefs.xml: html/%/index.html
	$(cmd) touch $@

###  HTML images  ###
ifneq ($(CYGWIN),1)
html/%/images: xml/%/images
	$(cmd) test -d html/$* || $(mkdir_p) html/$*
	$(cmd) test -e $@ || $(ln_s) ../../$< $@
else
html/%/images: $(IMAGE_PREREQ)
	$(cmd) if test -h $@; then rm -f $@; fi
	$(cmd) test -d $@ && rm -rf $@/* || $(mkdir_p) $@
	$(cmd) $(echo_n) "Copying HTML images ($*) ..."
	$(cmd) perl $(MAKE_IMAGE_LINKS) $(MAKE_IMAGE_LINKS_FLAGS) \
	                images/common images/C $@
	$(cmd) touch $@
endif

.PRECIOUS: \
	html/%/index.html \
	html/%/gimp-help.xml \
	html/%/gimp-xrefs.xml \
	html/%/images

.PHONY: html html-% index index-%


########################################################################
####            Make HTML draft (single page preview)               ####
########################################################################

preview-xml/%.xml: xml/%.xml stylesheets/drafthtml.xsl
	$(cmd) id=`$(SED) -e 's/.*id=.//' -e tmatch \
	                  -e d -e :match \
			  -e 's/["'"'"'].*//' \
			  -e q $<`; \
	test -n "$${id}" || id=noname; \
	lang=$(shell echo $< | $(SED) -e 's,^xml/,,; s,/.*,,'); \
	destdir=html/$${lang}; \
	test -d $${destdir}/images || $(RMAKE) $${destdir}/images; \
	cp -f $(srcdir)/stylesheets/*.css $(srcdir)/stylesheets/$${lang}/*.css\
	    $${destdir} 2>/dev/null; \
	destfile="$${destdir}/$${id}-draft.html"; \
	echo "Making $${destfile} (ignore any XSLT complaints) ..."; \
	$(XSLTPROC) \
	    $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	    --xinclude \
	    --stringparam l10n.gentext.default.language $${lang} \
	    --output $${destfile} \
	    $(srcdir)/stylesheets/drafthtml.xsl \
	    $<

preview-src/%.xml: $(foreach lang,$(LANGUAGES),preview-xml/$(lang)/%.xml)
	$(msg) "(Remember that links won't work in a draft file.)"

preview-po/%.po:
	@echo >&2 "After merging pofiles this feature does not work any more."
	@echo >&2 "Use 'make ... preview-xml/$*.xml'."

# For backward compatibility:

xml/%.draft: preview-xml/%.xml
	$(msg) "(Remember that links won't work in a draft file.)"

src/%.draft: preview-src/%.xml ;

# Synonyms
draft-xml/%.xml: preview-xml/%.xml ;
draft-src/%.xml: preview-src/%.xml ;
draft-po/%.po:   preview-po/%.po   ;


########################################################################
####            Make PDF files:  XML --> PDF                        ####
########################################################################

ifneq ($(DBLATEX),)

pdf: $(foreach lang,$(LANGUAGES),pdf-$(lang)) ;
pdf-%: pdf/%/gimp.pdf ;

# TODO: check prerequisites, e.g. images (--fig-path option?)
pdf/%/gimp.pdf: xml/% stylesheets/plainprint.xsl xml/%/images
	$(cmd) if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(cmd) test -d pdf/$* || $(mkdir_p) pdf/$*
	$(msg) "*** Making PDF ($*) ..."
	$(cmd) $(DBLATEX) $(DBLATEXFLAGS) $(DBLATEXEXTRAFLAGS) \
	    --xsl-user=$(srcdir)/stylesheets/plainprint.xsl \
	    --output=$@ \
	    xml/$*/gimp.xml

.PRECIOUS: pdf/%/gimp.pdf

else

pdf $(foreach lang,$(LANGUAGES),pdf-$(lang)):
	@echo "*** Cannot build PDFs because DBLATEX was not defined ***"
	@exit 69

endif


########################################################################
####            Make language-specific HTML tarballs                ####
########################################################################

tarball_prefix = gimp-help-html
tarball_dir    = gimp-help
HTMLMETAFILES  = README.md AUTHORS COPYING MAINTAINERS

$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml \
		$(HTMLMETAFILES) make.d/Makefile.html-package
	$(msg) "Making $@ ..."
	$(cmd) test ! -d $(tarball_dir)
	$(cmd) $(mkdir_p) $(tarball_dir)/html
	$(cmd) cd $(tarball_dir)/html && $(ln_s) ../../html/$* .
	$(cmd) cp $(HTMLMETAFILES) $(tarball_dir)/
	$(cmd) cp make.d/INSTALL.html-package $(tarball_dir)/INSTALL
	$(cmd) $(SED) -e '/LANGUAGE *=/s/en/$*/' \
		make.d/Makefile.html-package > $(tarball_dir)/Makefile
	$(cmd) tar -chf $@ $(tarball_dir)/
	$(cmd) rm -rf $(tarball_dir)

$(tarball_prefix)-%.tar.gz: $(tarball_prefix)-%.tar
	$(msg) "Making $@ ..."
	$(cmd) gzip -c9 $< > $@

$(tarball_prefix)-%.tar.bz2: $(tarball_prefix)-%.tar
	$(msg) "Making $@ ..."
	$(cmd) bzip2 -c9 $< > $@

$(tarball_prefix)-%.tar.xz: $(tarball_prefix)-%.tar
	$(msg) "Making $@ ..."
	$(cmd) xz -c9 $< > $@

$(tarball_prefix)-%.zip: $(tarball_prefix)-%.tar
	$(msg) "Making $@ ..."
	$(cmd) rm -rf $(tarball_dir)/html
	$(cmd) $(mkdir_p) $(tarball_dir)/html
	$(cmd) cd $(tarball_dir)/html && $(ln_s) ../../html/$* .
	$(cmd) zip -9rq $@ $(tarball_dir)/html
	$(cmd) rm -rf $(tarball_dir)


########################################################################
####            Clean up                                            ####
########################################################################

clean:
	$(cmd) for dir in pot xml log html pdf; do \
		test -d $${dir} || continue; \
		echo "Removing  $${dir} ..."; \
		rm -rf $${dir}; \
	done
	$(cmd) for f in AUTHORS $(AUTHORS_DOCBOOK_XML) build-system.*; do \
		test -f $${f} || continue; \
		echo "Removing  $${f} ..."; \
		rm -f $${f}; \
	done

dist-clean: clean ;

.PHONY: clean dist-clean


########################################################################
####            Source file checks                                  ####
########################################################################

check: checks ;
checks: check-image-references ;
check-images: check-image-references ;

check-image-references:
	$(cmd) if cd $(srcdir) && test -e tools/validate_references.py && \
	type python >/dev/null 2>&1; then \
	    echo "*** Checking image references ... "; \
	    python tools/validate_references.py \
	        --verbose --broken --orphaned \
		$(IMAGE_LANGS); \
	else \
	    echo >&2 "*** Cannot check image references (no Python installed?) ***"; \
	fi

check-images-%: FORCE
	$(cmd) $(RMAKE) check-image-references IMAGE_LANGS="C $*"

check-image-resolutions-%:
	$(cmd) /bin/sh tools/check_image_resolutions.sh images/$*

# special case 'en':
check-images-en check-images-C: check-image-references ;
check-image-resolutions-en: check-image-resolutions-C ;

.PHONY: checks check-image-references check-image-resolutions-%


########################################################################
####            Build system development & debugging                ####
########################################################################

build-system.svg: make.d/build-system.dot
	$(cmd) if type dot >/dev/null; then \
		dot -Tsvg -o $@ $<; \
	fi

dot: build-system.svg
	$(cmd) if test -e $<; then \
		if type display >/dev/null; then \
			display $<; \
		elif type xv >/dev/null; then \
			xv $<; \
		fi; \
	fi


########################################################################
####            Special targets                                     ####
########################################################################

FORCE: ;

.PHONY: FORCE

# Delete the default suffix rules
.SUFFIXES:
