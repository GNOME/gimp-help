## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference m4macros po-windows-installer build

# used for creating the ChangeLog
LAST_RELEASE_TAG = GIMP_HELP_3_0_0


########################################################################
####            The GIMP manual languages                           ####
########################################################################

LANGUAGES = $(if $(LINGUAS),$(filter $(ALL_LINGUAS),$(LINGUAS)),$(ALL_LINGUAS))
# HIDE FROM AUTOMAKE #ifneq ($(DOC_LINGUAS),)
# HIDE FROM AUTOMAKE #$(warning Do not set the internal variable DOC_LINGUAS)
# HIDE FROM AUTOMAKE #endif
DOC_LINGUAS = $(LINGUAS)

# HIDE FROM AUTOMAKE #ifneq ($(XML_LANG),)
# HIDE FROM AUTOMAKE #$(error You must not set the internal variable XML_LANG)
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #ifneq ($(PO_LANGS),)
# HIDE FROM AUTOMAKE #$(error You must not set the internal variable PO_LANGS)
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #XML_LANG = en
# HIDE FROM AUTOMAKE #PO_LANGS = $(filter-out $(XML_LANG), $(LANGUAGES))


########################################################################
####            External programs                                   ####
########################################################################

## Essential external programs and their default options:
##
## (the following variables are provided via "configure";
## edit configure.ac to change their default values)
##
## XSLTPROC, XSLTFLAGS
## XMLLINT, XMLLINTFLAGS
## XML2PO, XML2POFLAGS
## MSGWIDTH
## MSGUNIQ. MSGUNIQFLAGS
## MSGCAT, MSGCATFLAGS
## MSGINIT, MSGINITFLAGS
## MSGFMT, MSGFMTFLAGS
## MSGMERGE, MSGMERGEFLAGS
## DBLATEX, DBLATEXFLAGS

# HIDE FROM AUTOMAKE #ifneq ($(srcdir),$(builddir))
# HIDE FROM AUTOMAKE #XSLTFLAGS += --path $(builddir)
# HIDE FROM AUTOMAKE #endif

# Standard shell commands
find_l = find -L
echo_n = echo $(ECHO_N)

# Calling make recursively
RMAKE = $(MAKE) --no-print-directory

# Local (gimp-help-specific) tools
MAKE_IMAGE_LINKS = $(srcdir)/make.d/make_image_links.pl
MAKE_IMAGE_LINKS_FLAGS = -v
if CYGWIN
    MAKE_IMAGE_LINKS_FLAGS += --mode=hardlink,copy
endif


########################################################################
####            Files and directories                               ####
########################################################################

### Find files and directories

# XML files excluding automatically generated files
src_file_predicates =       \
	-name '*.xml' \
	-not -name '$(notdir $(AUTHORS_DOCBOOK_XML))'
src_dir_predicates  = -name images -prune -o -type d -print
pot_file_predicates = -type f
po_file_predicates  = -type f -not -name "$(COMPENDIUM)"
xml_file_predicates = -name '*.xml'

# list of authors and contributors (no DocBook)
AUTHORS_DATA_XML = stylesheets/authors.xml
# automatically generated authors section (DocBook)
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

# lists of source (XML) files and source directories
# HIDE FROM AUTOMAKE #ifeq ($(filter $(QUICK_TARGETS),$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #SRC_DIRS  := $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
# HIDE FROM AUTOMAKE #SRC_FILES := $(shell cd $(srcdir) && $(find_l) src/ $(src_file_predicates))
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #SRC_DIRS  = $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
# HIDE FROM AUTOMAKE #SRC_FILES = $(shell cd $(srcdir) && $(find_l) src/ $(src_file_predicates))
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #SRC_FILES += $(AUTHORS_DOCBOOK_XML)

# TODO?: rename "plainhtml.xsl" to "html.xsl" and use ...
# ... HTML_STYLESHEETS = stylesheets/html*.xsl
HTML_STYLESHEETS = stylesheets/plainhtml.xsl stylesheets/htmlalternate.xsl

# This variable is used by "msgmerge";
# use empty variable to disable the compendium option
COMPENDIUM = Compendium.po


### List of files for the autotools' "dist" rules

# lists of PO files (translations)
PO_FILES = $(shell cd $(srcdir) && $(find_l) po/ -type f)

# stylesheets for HTML
COMMON_CSS_FILES = \
	stylesheets/gimp-help-plain.css	\
	stylesheets/gimp-help-screen.css

# alternate stylesheets for HTML
OTHER_CSS_FILES = \
	stylesheets/gimp22.css

# stylesheets (and more) for XSLT
XSL_FILES = \
	stylesheets/authors.dtd 	\
	stylesheets/plainhtml.xsl.in	\
	stylesheets/entities.xml	\
	stylesheets/languageVocab.xml	\
	$(shell cd $(srcdir) && $(find_l) stylesheets/ -type f -name '*.xsl')	\
	gimp-help.doap

# tools needed for building
DIST_TOOLS = \
	autogen.sh \
	make.d \
	tools/xml2po.py \
	tools/xml2po

# additional files to be distributed (automake)
EXTRA_DIST = \
	AUTHORS			\
	MAINTAINERS		\
	HACKING			\
	INSTALL			\
	TERMINOLOGY		\
	$(COMMON_CSS_FILES)	\
	$(OTHER_CSS_FILES)	\
	$(SRC_FILES)		\
	$(AUTHORS_DATA_XML)	\
	$(PO_FILES)		\
	$(XSL_FILES)		\
	$(DIST_TOOLS)

#
DISTCHECK_CONFIGURE_FLAGS = --without-gimp

# gimp-help directories
## remember that automake defines "srcdir"
helpdir  = $(gimpdatadir)/help


########################################################################
####            Control the amount of output messages               ####
########################################################################
#
# Usage of the "msg" and "cmd" variables:
# In the command lines of the make rules, use
#     $(msg) bla bla bla   instead of   @echo bla bla bla
#     $(cmd) command args  instead of   @command args (or command args)
# then
#     messages will be suppressed if (and only if) VERBOSE=0,
#     commands will be printed if (and only if) VERBOSE=2.
#
# HIDE FROM AUTOMAKE #VERBOSE ?= 1
# HIDE FROM AUTOMAKE #ifeq ($(VERBOSE),0)
# HIDE FROM AUTOMAKE #msg = @:
# HIDE FROM AUTOMAKE #cmd = @
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #ifeq ($(VERBOSE),2)
# HIDE FROM AUTOMAKE #msg = @echo
# HIDE FROM AUTOMAKE #cmd =
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #msg = @echo
# HIDE FROM AUTOMAKE #cmd = @
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #endif


########################################################################
####            Functions                                           ####
########################################################################

#--------------------------------------------------------------#
#       The main functions used to transform                   #
#               (a) XML files to POT files                     #
#               (b) POT files to PO files                      #
#               (c) XML and PO files to XML files              #
#--------------------------------------------------------------#

if HAVE_I18N_TOOLS
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
po2xml = $(XML2PO) $(XML2POFLAGS) --po-file=$(2) --language=$(3) --output=$(4) $(1); \
         rm -f .xml2po.mo

else

xml2pot = echo "Error: couldn't find xml2po or gettext tools"; exit 69
pot2po  = echo "Error: couldn't find gettext tools (msgmerge, msginit, msgfmt)"; exit 69
po2xml  = echo "Error: couldn't find xml2po or gettext tools"; exit 69

endif


#--------------------------------------------------------------#
#       Helper functions                                       #
#                                                              #
#       (special thanks to automake for resorting - of         #
#       course you know it better than any human author!)      #
#--------------------------------------------------------------#

make_target_dir = f=$(1); d=$${f%/*}; test -d $$d || $(MKDIR_P) $$d

get_recent_file = $(shell ls -t $(1) 2>/dev/null | $(SED) 1q)

copy = $(LN_S) $(abs_srcdir)/$(1) $(2)

# HIDE FROM AUTOMAKE #ifneq ($(COMPENDIUM),)
# HIDE FROM AUTOMAKE #get_compendium = \
# HIDE FROM AUTOMAKE #	file="$(1)"; dir=$${file%/*}; \
# HIDE FROM AUTOMAKE #	while true; do \
# HIDE FROM AUTOMAKE #		if test -f $${dir}/$(COMPENDIUM); then \
# HIDE FROM AUTOMAKE #			echo "--compendium=$${dir}/$(COMPENDIUM)"; \
# HIDE FROM AUTOMAKE #		fi; \
# HIDE FROM AUTOMAKE #		case "$${dir}" in \
# HIDE FROM AUTOMAKE #			po|*/po) break;; \
# HIDE FROM AUTOMAKE #			    */*) dir="$${dir%/*}";; \
# HIDE FROM AUTOMAKE #			      *) break;; \
# HIDE FROM AUTOMAKE #		esac; \
# HIDE FROM AUTOMAKE #	done
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #get_compendium =
# HIDE FROM AUTOMAKE #endif

# HIDE FROM AUTOMAKE #ifneq ($(GIMP_PO_ROOT),)
# HIDE FROM AUTOMAKE #use_gimp_po_files = \
# HIDE FROM AUTOMAKE #	for po in $(GIMP_PO_ROOT)/po*/$(1).po; do \
# HIDE FROM AUTOMAKE #		if test -f "$${po}"; then echo '--compendium'="$${po}"; fi; \
# HIDE FROM AUTOMAKE #	done
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #use_gimp_po_files =
# HIDE FROM AUTOMAKE #endif


########################################################################
####            Main targets                                        ####
########################################################################

# XXX: It looks like "automake" is unable to place the "all:" target
# at top of Makefile, so running "make" might create some random file
# (depending on which target is the first one in the Makefile).
# Use "make all" instead. (FIXME: and get rid of automake/autoconf!)
all-local: html-local index AUTHORS MAINTAINERS

# TODO?: check-local: validate


########################################################################
####            Help!!!                                             ####
########################################################################

make.help:
	@echo >&2 'ERROR: cannot find the help file "$@"!'
	@exit 66

help: make.help
	$(cmd) $(SED) \
	    -e '### skip comments ###' \
	    -e '/^#/d' \
	    -e '### print if no "make" variable found ###' \
	    -e '/%/!b' \
	    -e '### replace "make" variables ###' \
	    -e 's/%LANGUAGES%/%$(strip $(LANGUAGES))%/' \
	    -e 's/%LINGUAS%/%$(strip $(LINGUAS))%/' \
	    -e 's/%ALL_LINGUAS%/%$(strip $(ALL_LINGUAS))%/' \
	$<

.PHONY: help


########################################################################
####            Make AUTHORS and MAINTAINERS file                   ####
########################################################################

AUTHORS: $(AUTHORS_DATA_XML) $(AUTHORS_TEXT_STYLESHEETS)
	$(msg) "[DOC] $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/authors_text.xsl \
	  $< \
	  > $@

$(AUTHORS_DOCBOOK_XML): $(AUTHORS_DATA_XML) $(AUTHORS_DOCBOOK_STYLESHEETS)
	$(msg) "[SRC] $@"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/authors_docbook.xsl \
	  $< \
	  > $@
	$(cmd) touch -c -r $< $@ || true

MAINTAINERS: gimp-help.doap $(DOAP_STYLESHEET)
	$(msg) "[DOC] $@"
	$(cmd) $(XSLTPROC) --output $@ $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(DOAP_STYLESHEET) $<


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################

# src/path/to/file/*.xml --> pot/path/to/file.pot
# HIDE FROM AUTOMAKE #POT_FILES  = $(patsubst src/%,pot/%.pot,$(filter-out src src/,$(SRC_DIRS)))
# Special case: src/*.xml --> pot/gimp.pot
# HIDE FROM AUTOMAKE #POT_FILES += pot/gimp.pot

# XXX: Secondary Expansion of the following two rules is required because
# "pot/%.pot: $(srcdir)/src/%/*.xml" didn't work with make v3.82
# (cf. bug #637505).
# HIDE FROM AUTOMAKE #.SECONDEXPANSION:
# General case
# HIDE FROM AUTOMAKE #ifeq ($(filter pot/%.pot,$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #pot/%.pot: $(srcdir)/src/$$*/*.xml $$(wildcard images/C/$$*/*.*)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #pot/%.pot: $(srcdir)/src/$$*/*.xml FORCE
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #	$(cmd) $(call make_target_dir,$@)
# HIDE FROM AUTOMAKE #	$(msg) "[POT] $@"
# HIDE FROM AUTOMAKE #	$(cmd) $(call xml2pot,$^,$@)
# Special case: rename pot file for toplevel xml files
# HIDE FROM AUTOMAKE #ifeq ($(filter pot/%.pot,$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #pot/gimp.pot: $(srcdir)/src/*.xml $(wildcard images/C/*.*)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #pot/gimp.pot: $(srcdir)/src/*.xml FORCE
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #	$(cmd) $(call make_target_dir,$@)
# HIDE FROM AUTOMAKE #	$(msg) "[POT] $@"
# HIDE FROM AUTOMAKE #	$(cmd) $(call xml2pot,$^,$@)
# Special case: pot file for the authors DocBook file
# requires an additional prerequisite
# HIDE FROM AUTOMAKE #AUTHORS_POT = $(AUTHORS_DOCBOOK_XML:src/%/$(AUTHORS_DOCBOOK_FILENAME)=pot/%.pot)
# HIDE FROM AUTOMAKE #ifeq ($(filter pot/%.pot,$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE ## TODO: add images to prerequisites if necessary
# HIDE FROM AUTOMAKE #$(AUTHORS_POT): $(AUTHORS_DOCBOOK_XML) $(wildcard $(AUTHORS_DOCBOOK_DIRNAME)*.xml)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #$(AUTHORS_POT): $(AUTHORS_DOCBOOK_XML) $(wildcard $(AUTHORS_DOCBOOK_DIRNAME)*.xml) FORCE
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #	$(cmd) $(call make_target_dir,$@)
# HIDE FROM AUTOMAKE #	$(msg) "[POT] $@"
# HIDE FROM AUTOMAKE #	$(cmd) $(call xml2pot,$^,$@)

# Remove left over pot files
cleanup-pot:
	$(msg) "Cleaning up pot files ..."
	$(cmd) if [ "$(srcdir)" = "$(builddir)" ]; then \
		$(find_l) pot/ $(pot_file_predicates) | \
		while read potfile; do \
			potfile=$${potfile#pot/}; srcfile=src/$${potfile%.pot}.xml \
			test -e $${srcfile} || rm -f $${potfile}; \
		done; \
	fi

# Targets suitable for command line
pot: potfiles cleanup-pot ;
potfiles: $(POT_FILES) ;

.PHONY: pot potfiles cleanup-pot


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################
#
# HIDE FROM AUTOMAKE #define MAKE_PO_RULES
# HIDE FROM AUTOMAKE #$(1)_PO_FILES = $$(patsubst pot/%.pot, $(srcdir)/po/$(1)/%.po, $$(POT_FILES))
# HIDE FROM AUTOMAKE #ifeq ($$(filter $(srcdir)/po/$(1)/%.po,$$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): $(srcdir)/po/$(1)/%.po : pot/%.pot
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): $(srcdir)/po/$(1)/%.po : pot/%.pot FORCE
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$@)
# HIDE FROM AUTOMAKE #	$$(msg) "[PO]  $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
# HIDE FROM AUTOMAKE #po-$(1): $$($(1)_PO_FILES) cleanup-po-$(1)
# HIDE FROM AUTOMAKE #	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
# HIDE FROM AUTOMAKE #cleanup-po-$(1):
# HIDE FROM AUTOMAKE #ifeq ($$(srcdir),$$(builddir))
# HIDE FROM AUTOMAKE #	$$(msg) "Cleaning up '$(1)' po files ..."
# HIDE FROM AUTOMAKE #	$$(cmd) $(find_l) po/$(1)/ $$(po_file_predicates) | \
# HIDE FROM AUTOMAKE #	while read pofile; do \
# HIDE FROM AUTOMAKE #		potfile=pot/$$$${pofile#po/$(1)/}t; \
# HIDE FROM AUTOMAKE #		test -e $$$${potfile} || rm -vf $$$${pofile}; \
# HIDE FROM AUTOMAKE #	done
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_PO_RULES,$(LANG))))

# Special case 'en': do nothing :-)
po-en: ;

# Print translation statistics

status-%: po-status-% ;
po-status-%: po-%
	$(cmd) perl $(srcdir)/tools/get_po_status.pl $(srcdir)/po/$*

status-all: po-status-all ;
po-status-all:
	$(cmd) for podir in $(srcdir)/po/*; do \
		perl $(srcdir)/tools/get_po_status.pl \
			--nofiles --nosummary $${podir} \
		|| break; \
	done

todo-%: po-todo-% ;
po-todo-%: po-%
	$(cmd) perl $(srcdir)/tools/get_po_status.pl --todo $(srcdir)/po/$*

# Main commandline target
po: $(foreach LANG,$(PO_LANGS),po-$(LANG)) ;

.PHONY: po po-% cleanup-po-% todo-% po-todo-% po-status-%


########################################################################
####            Generate XML prerequisites                          ####
########################################################################

# HIDE FROM AUTOMAKE #ifeq ($(filter $(QUICK_TARGETS),$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #include $(foreach LANG,$(PO_LANGS),xml/$(LANG)/.deps.mk)
# HIDE FROM AUTOMAKE #endif

# The dynamically generated and updated ".deps.mk" files contain
# rules to register the po prereqisite for every xml file, e.g.
#	xml/LANG/*.xml: po/LANG/gimp.po
#	xml/LANG/filters/*.xml: po/LANG/filters.po
#	xml/LANG/filters/generic/*.xml: po/LANG/filters/generic.po
#	etc.

#xml/$(1)/.deps.mk: $(AUTHORS_DOCBOOK_XML) $$($(1)_PO_FILES)
# TODO: simplify
# HIDE FROM AUTOMAKE #define MAKE_DEP_RULES
# HIDE FROM AUTOMAKE #xml/$(1)/.deps.mk: $(AUTHORS_DOCBOOK_XML) $$(SRC_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$@)
# HIDE FROM AUTOMAKE #	$$(msg) "[DEP] $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) echo "first: all" > $$@
# HIDE FROM AUTOMAKE #	$$(cmd) for path in $(SRC_DIRS); do \
# HIDE FROM AUTOMAKE #		ls $$(srcdir)/$$$${path}/*.xml >/dev/null 2>&1 || \
# HIDE FROM AUTOMAKE #		ls $$$${path}/*.xml >/dev/null 2>&1 || continue; \
# HIDE FROM AUTOMAKE #		path=$$$${path%/}; \
# HIDE FROM AUTOMAKE #		xmldir=xml/$(1)$$$${path#src}; \
# HIDE FROM AUTOMAKE #		test "$$$${path}" != "src" || path="src/gimp"; \
# HIDE FROM AUTOMAKE #		pofile=po/$(1)$$$${path#src}.po; \
# HIDE FROM AUTOMAKE #		echo "$$$${xmldir}/*.xml: $$$${pofile}"; \
# HIDE FROM AUTOMAKE #	done >> $$@
# HIDE FROM AUTOMAKE #endef
# HIDE FROM AUTOMAKE #$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_DEP_RULES,$(LANG))))


########################################################################
####            Make XML files:  PO --> XML(non-en)                 ####
########################################################################
#
# TODO: check xml/$(1) vs. xml-$(1) prerequisites (XML_FILES)
# HIDE FROM AUTOMAKE #define MAKE_XML_RULES
# HIDE FROM AUTOMAKE #$(1)_XML_FILES = $$(SRC_FILES:src/%=xml/$(1)/%)
# HIDE FROM AUTOMAKE #xml/$(1)/%.xml:
# HIDE FROM AUTOMAKE #	$$(msg) "[XML] $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$@)
# HIDE FROM AUTOMAKE #	$$(cmd) xmlfile=$$@; \
# HIDE FROM AUTOMAKE #	stem=$$*; \
# HIDE FROM AUTOMAKE #	srcfile=$$(srcdir)/src/$$$${stem}.xml; \
# HIDE FROM AUTOMAKE #	test "$$$${stem}" != "$$$${stem%/*}" && stem=$$$${stem%/*} || stem=gimp; \
# HIDE FROM AUTOMAKE #	pofile=$$(srcdir)/po/$(1)/$$$${stem}.po; \
# HIDE FROM AUTOMAKE #	test -e "$$$${pofile}" || $$(RMAKE) "$$$${pofile}"; \
# HIDE FROM AUTOMAKE #	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)
# Special case: authors.xml
# HIDE FROM AUTOMAKE #xml/$(1)/$(AUTHORS_DOCBOOK_XML:src/%=%): $(AUTHORS_DOCBOOK_XML)
# HIDE FROM AUTOMAKE #	$$(msg) "[XML] $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$@)
# HIDE FROM AUTOMAKE #	$$(cmd) xmlfile=$$@; \
# HIDE FROM AUTOMAKE #	srcfile=$(AUTHORS_DOCBOOK_XML); \
# HIDE FROM AUTOMAKE #	stem=$$(dir $$(@:xml/$(1)/%=%)); \
# HIDE FROM AUTOMAKE #	pofile=$$(srcdir)/po/$(1)/$$$${stem%/}.po; \
# HIDE FROM AUTOMAKE #	test -e "$$$${pofile}" || $$(RMAKE) "$$$${pofile}"; \
# HIDE FROM AUTOMAKE #	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## This is indirectly used as HTML and PDF prerequisite:
# HIDE FROM AUTOMAKE #xml/$(1): $$($(1)_XML_FILES) | xml/$(1)/images
# HIDE FROM AUTOMAKE #	$$(cmd) test -d $$@ && touch $$@ || $(MKDIR_P) $$@
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## Targets suitable for command line
# HIDE FROM AUTOMAKE #xml-$(1): po-$(1) xml/$(1) cleanup-xml-$(1) ;
# HIDE FROM AUTOMAKE #endef
# HIDE FROM AUTOMAKE #$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# Special case: en

en_XML_FILES = $(SRC_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(msg) "[XML] $@ (copy)"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) cp -f $< $@

xml/en: $(en_XML_FILES) | xml/en/images
	$(cmd) test -d $@ && touch $@ || $(MKDIR_P) $@

xml-en: xml/en cleanup-xml-en ;

# Images

# HIDE FROM AUTOMAKE #ifeq ($(MAKE_IMAGES), lazy)
# HIDE FROM AUTOMAKE ## fast and lazy: detect added or removed images, but may miss changed images
# HIDE FROM AUTOMAKE #IMAGE_PREREQ = $(shell cd $(srcdir) && $(find_l) images/common images/C -type d)
# HIDE FROM AUTOMAKE #else ifeq ($(MAKE_IMAGES), force)
# HIDE FROM AUTOMAKE ## just in case: always update images
# HIDE FROM AUTOMAKE #IMAGE_PREREQ = FORCE
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE ## strict (default): detects added, removed, or changed images
# HIDE FROM AUTOMAKE #IMAGE_PREREQ = $(shell cd $(srcdir) && $(find_l) images/common images/C)
# HIDE FROM AUTOMAKE #endif

xml/%/images: $(IMAGE_PREREQ)
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
	$(cmd) if test -d $@; then rm -rf $@/*; fi
	$(cmd) test -d $@ || $(MKDIR_P) $@
	$(cmd) $(echo_n) "Copying images ($*) ..."
	$(cmd) perl $(MAKE_IMAGE_LINKS) $(MAKE_IMAGE_LINKS_FLAGS) \
	           $(srcdir)/images/common $(srcdir)/images/C $@
	$(cmd) touch $@

# Remove left over xml files
cleanup-xml-%:
	$(msg) "Cleaning up '$*' xml files ..."
	$(cmd) if [ "$(srcdir)" = "$(builddir)" ]; then \
		$(find_l) xml/$*/ $(xml_file_predicates) | \
		while read xmlfile; do \
			test -e src/$${xmlfile#xml/$*/} || rm -vf $${xmlfile}; \
		done; \
	fi

# Target suitable for command line
images-%: xml/%/images html/%/images ;

# Main commandline target
xml: $(foreach LANG,$(LANGUAGES),xml-$(LANG)) ;

.PRECIOUS: xml/%/images
.PHONY: xml xml-%


########################################################################
####            XML validation                                      ####
########################################################################

validate: validate-en ;
validate-%: xmllint-% ;
validate-all: $(foreach LANG,$(LANGUAGES),validate-$(LANG)) ;

xmllint: xmllint-en ;
xmllint-%: log/%-xmllint.log
	$(cmd) test -s $< && cat $<

# HIDE FROM AUTOMAKE #define MAKE_XMLLINT_RULES
# HIDE FROM AUTOMAKE #log/$(1)-xmllint.log: $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$(@))
# HIDE FROM AUTOMAKE #	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
# HIDE FROM AUTOMAKE #		echo "*** Validating XML ($(1)) ... "; \
# HIDE FROM AUTOMAKE #		$$(XMLLINT) $$(XMLLINTFLAGS) --noent --xinclude xml/$(1)/gimp.xml \
# HIDE FROM AUTOMAKE #		| $(SED) -e 's,xmlns:xi="http://www.w3.org/2001/XInclude",,' \
# HIDE FROM AUTOMAKE #		| $$(XMLLINT) $$(XMLLINTFLAGS) --valid \
# HIDE FROM AUTOMAKE #			--output log/$(1).xml - 2>$$(@); \
# HIDE FROM AUTOMAKE #		if test -s $$(@); then \
# HIDE FROM AUTOMAKE #			echo "(You will find log and xml files in log/.)"; \
# HIDE FROM AUTOMAKE #		else \
# HIDE FROM AUTOMAKE #			echo "$(1): no errors."; \
# HIDE FROM AUTOMAKE #			rm -f  log/$(1).xml; \
# HIDE FROM AUTOMAKE #		fi >> $$(@); \
# HIDE FROM AUTOMAKE #	else \
# HIDE FROM AUTOMAKE #		echo >&2 "*** Validating '$(1)' skipped: 'xmllint' not found."; \
# HIDE FROM AUTOMAKE #	fi
# HIDE FROM AUTOMAKE #endef
$(foreach LANG,$(LANGUAGES),$(eval $(call MAKE_XMLLINT_RULES,$(LANG))))

log:
	$(cmd) mkdir $@ && test -w $@


########################################################################
####            Make HTML files:  XML --> HTML                      ####
########################################################################

### Main commandline targets ###
html-%: xml-% html/%/index.html html/%/gimp-help.xml ;
# Note that automake already defines a target "html"
html-local: $(foreach lang,$(LANGUAGES),html-$(lang)) ;

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
if CYGWIN
# Cygwin
html/%/images: $(IMAGE_PREREQ)
	$(cmd) if test -h $@; then rm -f $@; fi
	$(cmd) test -d $@ && rm -rf $@/* || $(MKDIR_P) $@
	$(cmd) $(echo_n) "Copying HTML images ($*) ..."
	$(cmd) perl $(MAKE_IMAGE_LINKS) $(MAKE_IMAGE_LINKS_FLAGS) \
	           $(srcdir)/images/common $(srcdir)/images/C $@
	$(cmd) touch $@
else
# Default (non-Cygwin)
html/%/images: xml/%/images
	$(cmd) test -d html/$* || $(MKDIR_P) html/$*
	$(cmd) test -e $@ || $(LN_S) ../../$< $@
endif

.PHONY: html-% index index-%


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
if HAVE_DBLATEX

## Note that Automake already defines a "pdf" target
pdf-local: $(foreach lang,$(LANGUAGES),pdf-$(lang)) ;
pdf-%: pdf/%/gimp.pdf ;

# TODO: check prerequisites, e.g. images (--fig-path option?)
pdf/%/gimp.pdf: xml/% stylesheets/plainprint.xsl xml/%/images
	$(cmd) if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(cmd) test -d pdf/$* || $(MKDIR_P) pdf/$*
	$(msg) "*** Making PDF ($*) ..."
	$(cmd) $(DBLATEX) $(DBLATEXFLAGS) $(DBLATEXEXTRAFLAGS) \
	    --xsl-user=$(srcdir)/stylesheets/plainprint.xsl \
	    --output=$@ \
	    xml/$*/gimp.xml

else

pdf-local $(foreach lang,$(LANGUAGES),pdf-$(lang)):
	@echo "*** Cannot build PDFs because dblatex(1) was not found ***"
	@exit 69

endif


########################################################################
####            Make language-specific HTML tarballs                ####
########################################################################

tarball_prefix = gimp-help-html
tarball_dir    = gimp-help
HTMLMETAFILES  = README.md documentation-guidelines.md AUTHORS COPYING MAINTAINERS

$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml \
		$(HTMLMETAFILES) make.d/Makefile.html-package
	$(msg) "Making $@ ..."
	$(cmd) test ! -d $(tarball_dir)
	$(cmd) $(MKDIR_P) $(tarball_dir)/html
	$(cmd) cd $(tarball_dir)/html && $(LN_S) ../../html/$* .
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

$(tarball_prefix)-%.zip: $(tarball_prefix)-%.tar
	$(msg) "Making $@ ..."
	$(cmd) rm -rf $(tarball_dir)/html
	$(cmd) $(MKDIR_P) $(tarball_dir)/html
	$(cmd) cd $(tarball_dir)/html && $(LN_S) ../../html/$* .
	$(cmd) zip -9rq $@ $(tarball_dir)/html
	$(cmd) rm -rf $(tarball_dir)

html-dist: \
	$(foreach lang,$(LANGUAGES), \
		$(tarball_prefix)-$(lang).tar.gz \
		$(tarball_prefix)-$(lang).tar.bz2 \
		$(tarball_prefix)-$(lang).zip \
	)


########################################################################
####            Make a distribution tar file                        ####
########################################################################

dist-hook: dist-copy-images generate-changelog

##  Note that number of images is *huge*, and if we stick image files in
##  EXTRA_DIST we get an "Argument list too long" error. So we handle it here.

dist-copy-images:
	$(cmd) test -d "$(top_srcdir)/images" && test -d "$(distdir)"
	@echo "Copying images into distdir $(distdir) ..."
	$(cmd)(cd $(top_srcdir) && tar -cf- --exclude=.git images) \
	| (cd $(distdir) && tar -xf-)
	$(cmd) test -d "$(distdir)/images" && test ! -d "$(distdir)/images/.git"

generate-changelog:
	@if test -d "$(srcdir)/.git"; \
	then \
		echo Creating ChangeLog && \
		( cd "$(top_srcdir)" && \
		  echo '# Generated by Makefile. Do not edit.'; echo; \
		  ./missing --run git log --stat -t $(LAST_RELEASE_TAG)..HEAD ) > ChangeLog.tmp \
		&& mv -f ChangeLog.tmp $(top_distdir)/ChangeLog \
		|| ( rm -f ChangeLog.tmp ; \
			echo Failed to generate ChangeLog >&2 ); \
	else \
		echo A git clone is required to generate a ChangeLog >&2; \
	fi


########################################################################
####            Installation                                        ####
########################################################################

install-data-local:
	$(cmd) $(MKDIR_P) $(DESTDIR)$(helpdir) || exit 77
	$(cmd) $(echo_n) "*** Installing HTML:"
	$(cmd) cd html && \
	for lang in $(LANGUAGES); do \
		$(echo_n) " $${lang}"; \
		tar -chf- $${lang} | \
		(cd $(DESTDIR)$(helpdir)/ && tar -xf-) || exit 70; \
	done; \
	echo .

uninstall-local:
	$(cmd) test -d $(DESTDIR)$(helpdir) || exit 70
	$(cmd) $(echo_n) "*** Uninstalling HTML:"
	$(cmd) for lang in $(LANGUAGES); do \
		$(echo_n) " $${lang}"; \
		rm -rf $(DESTDIR)$(helpdir)/$${lang}; \
	done; \
	echo .
	$(cmd) test -z "$(DESTDIR)" || cd $(DESTDIR) && \
	dir="$(helpdir)" && \
	while [ -d "$${dir}" ]; do \
		if [[ "$${dir}" == "${prefix}" ]]; then \
			break; \
		else \
			rmdir $${dir} 2>/dev/null \
			&& echo removed $(DESTDIR)$${dir} \
			&& dir=$${dir%/*} \
			|| break; \
		fi \
	done


########################################################################
####            Source file checks                                  ####
########################################################################

# Note that the default (autoconf) target name is "check".
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
	$(cmd) /bin/sh $(srcdir)/tools/check_image_resolutions.sh $(srcdir)/images/$*

# special case 'en':
check-images-en check-images-C: check-image-references ;
check-image-resolutions-en: check-image-resolutions-C ;

.PHONY: checks check-image-references check-image-resolutions-%


if HAVE_DOT
########################################################################
####            Build system development & debugging                ####
########################################################################

build-system.svg: make.d/build-system.dot
	$(cmd) $(DOT) -Tsvg -o $@ $< && \
	echo "$@ created."

dot: build-system.svg
endif


########################################################################
####            Clean up                                            ####
########################################################################

# Delete all files that are normally created by building the program.
clean-local: mostlyclean-local
	$(cmd) rm -rf html
	$(cmd) rm -f AUTHORS MAINTAINERS

# Like `clean-local', but may refrain from deleting a few files that people
# normally don't want to recompile.
mostlyclean-local:
	$(cmd) rm -rf pdf
	$(cmd) rm -rf xml
	$(cmd) rm -rf pot
# HIDE FROM AUTOMAKE #ifneq ($(srcdir),$(builddir))
	$(cmd) rm -rf src
	$(cmd) rm -rf po
# HIDE FROM AUTOMAKE #else
	$(cmd) rm -f $(AUTHORS_DOCBOOK_XML)
# HIDE FROM AUTOMAKE #endif
	$(cmd) rm -rf $(tarball_dir)
	$(cmd) rm -f $(tarball_prefix)-*
	$(cmd) rm -f build-system.*
	$(cmd) rm -f .xml2po.mo messages.mo

# Delete all files in the current directory (or created by this makefile) that
# are created by configuring or building the program.
distclean-local: clean-local
# HIDE FROM AUTOMAKE #ifneq ($(srcdir),$(builddir))
		$(cmd) rm -rf stylesheets
# HIDE FROM AUTOMAKE #endif

# Delete almost everything (not 'configure' or anything that needs to exist in
# order to run 'configure') that can be reconstructed with this Makefile.
maintainer-clean-local: distclean-local
	$(cmd) rm -rf log

# Override automake-generated targets
Makefile: $(srcdir)/Makefile.in $(srcdir)/Makefile.am $(srcdir)/configure.ac $(srcdir)/autogen.sh
	$(msg) "!!! Updating '$@' running 'autogen.sh' ($? changed) !!!"
	$(cmd) opt=`test -e $(builddir)/config.status && \
	     $(builddir)/config.status --version | \
	     sed -e 's/.*with options "//' \
	         -e tmatch -e d -e :match -e 's/".*//' \
		 -e "s/'\([^'=]*\)=\([^']*\)'/\1='\2'/"`; \
	test -n "$${opt}" && eval $(srcdir)/autogen.sh $${opt}
$(srcdir)/Makefile.in: $(srcdir)/Makefile.am $(srcdir)/autogen.sh ;

$(top_builddir)/config.status: $(top_srcdir)/configure ;

$(top_srcdir)/configure: $(top_srcdir)/configure.ac ;


########################################################################
####            Special targets                                     ####
########################################################################

FORCE: ;

.PHONY: FORCE

# Delete the default suffixes (we don't compile C files)
SUFFIXES =

# GNU Make, please don't delete these targets when a target that depends
# on them fails, 'kay?
#			TODO: check: seems that xml/%/gimp.xml can be removed
.PRECIOUS: \
	xml/%/gimp.xml \
	xml/%/images \
	pdf/%/gimp.pdf \
	html/%/index.html \
	html/%/gimp-xrefs.xml \
	html/%/gimp-help.xml \
	html/%/images

.DELETE_ON_ERROR:

## EOF
