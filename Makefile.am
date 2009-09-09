## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference

# used for creating the ChangeLog
LAST_RELEASE_TAG = GIMP_HELP_2_4_2

# The GIMP manual languages
LANGUAGES = $(if $(LINGUAS), \
              $(filter $(ALL_LINGUAS),$(LINGUAS)), \
	      $(ALL_LINGUAS))
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

## Essential external programs and their default options
## (some of these variables are provided via "configure" -- see configure.ac)
##
## XSLTPROC  = xsltproc
## XSLTFLAGS = --nonet
##
## XMLLINT      = xmllint
XMLLINTFLAGS = --nonet
##
## XML2PO = $(srcdir)/tools/xml2po
##
MSGWIDTH      = 79
## MSGUNIQ       = msguniq 
MSGUNIQFLAGS  = 
## MSGCAT        = msgcat 
MSGCATFLAGS   = --width=$(MSGWIDTH)
## MSGINIT       = msginit
MSGINITFLAGS  = --no-translator --width=$(MSGWIDTH)
## MSGFMT        = msgfmt
## MSGFMTFLAGS   = --check --use-fuzzy --statistics
## MSGMERGE      = msgmerge
MSGMERGEFLAGS = --quiet --width=$(MSGWIDTH)
##
## DBLATEX       = dblatex
DBLATEXFLAGS     = --verbose
## DOCBOOK2ODF      = docbook2odf
DOCBOOK2ODFFLAGS =

# Standard shell commands
find_l = find -L

# Calling make recursively
RMAKE = $(MAKE) --no-print-directory

# Standard shell commands
echo_n = echo $(ECHO_N)

### Find files and directories

# XML files excluding automatically generated files
xml_file_predicates =       \
	-name '.git' -prune \
	-o                  \
	-name '$(notdir $(AUTHORS_DOCBOOK_XML))' -prune \
	-o                  \
	-name '*.xml' -print

#  for generating a list of files (of any type)
file_predicates =           \
	-name '.git' -prune \
	        -o          \
	-type f -print

# for generating a list of directories
dir_predicates =            \
	-name '.git' -prune \
	        -o          \
	-type d -print

# for generating xml source directories
src_dir_predicates = -name images -prune -o $(dir_predicates)

# list of authors and contributors (no DocBook)
AUTHORS_SOURCE_XML = stylesheets/authors.xml
# automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML = src/preface/authors.xml
# Stylesheets generating AUTHORS 
AUTHORS_TEXT_STYLESHEETS = \
	stylesheets/authors_text.xsl \
	stylesheets/authors_common.xsl
# Stylesheets generating src/preface/authors.xml
AUTHORS_DOCBOOK_STYLESHEETS = \
	stylesheets/authors_docbook.xsl \
	stylesheets/authors_common.xsl

# lists of source (XML) files and source directories
# HIDE FROM AUTOMAKE #ifeq ($(filter help clean,$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #SRC_DIRS  := $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
# HIDE FROM AUTOMAKE #SRC_FILES := $(shell cd $(srcdir) && $(find_l) src/ $(xml_file_predicates)) \
# HIDE FROM AUTOMAKE #             $(AUTHORS_DOCBOOK_XML)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #SRC_DIRS  = $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
# HIDE FROM AUTOMAKE #SRC_FILES = $(shell cd $(srcdir) && $(find_l) src/ $(xml_file_predicates)) \
# HIDE FROM AUTOMAKE #            $(AUTHORS_DOCBOOK_XML)
# HIDE FROM AUTOMAKE #endif

# lists of PO files (translations)
PO_FILES = $(shell cd $(srcdir) && $(find_l) po/ $(file_predicates))

# stylesheets for HTML
COMMON_CSS_FILES = \
	stylesheets/gimp-help-plain.css	\
	stylesheets/gimp-help-screen.css

# alternate stylesheets for HTML
OTHER_CSS_FILES = \
	stylesheets/gimp22.css

# stylesheets for XSLT
XSL_FILES = \
	stylesheets/authors_docbook.xsl	\
	stylesheets/authors_text.xsl	\
	stylesheets/authors_common.xsl	\
	stylesheets/makeindex.xsl	\
	stylesheets/plainprint.xsl	\
	stylesheets/plainhtml.xsl.in	\
	stylesheets/htmlalternate.xsl

# tools needed for building
DIST_TOOLS = \
	tools/make_image_links.pl

# additional files to be distributed (automake)
EXTRA_DIST = \
	AUTHORS			\
	HACKING			\
	INSTALL			\
	TERMINOLOGY		\
	$(COMMON_CSS_FILES)	\
	$(OTHER_CSS_FILES)	\
	$(SRC_FILES)		\
	$(AUTHORS_SOURCE_XML)	\
	$(PO_FILES)		\
	$(XSL_FILES)		\
	$(DIST_TOOLS)

# TODO?: rename "plainhtml.xsl" to "html.xsl" and use ...
# ... HTML_STYLESHEETS = stylesheets/html*.xsl
HTML_STYLESHEETS = stylesheets/plainhtml.xsl stylesheets/htmlalternate.xsl

#
DISTCHECK_CONFIGURE_FLAGS = --without-gimp

# gimp-help directories
## remember that automake defines "srcdir"
helpdir  = $(gimpdatadir)/help


########################################################################
####            Control the amount of output messages               ####
########################################################################

# Usage of the "msg" and "cmd" variables:
# In the command lines of the make rules, use
#     $(msg) bla bla bla   instead of   @echo bla bla bla
#     $(cmd) command args  instead of   @command args (or command args)
# then
#     messages will be suppressed if (and only if) VERBOSE=0,
#     commands will be printed if (and only if) VERBOSE=2.
#
# HIDE FROM AUTOMAKE #VERBOSE ?= 1
# HIDE FROM AUTOMAKE #ifeq ("$(VERBOSE)", "0")
# HIDE FROM AUTOMAKE #msg = @:
# HIDE FROM AUTOMAKE #cmd = @
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #ifeq ("$(VERBOSE)", "2")
# HIDE FROM AUTOMAKE #msg = @echo
# HIDE FROM AUTOMAKE #cmd =
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #msg = @echo
# HIDE FROM AUTOMAKE #cmd = @
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #endif


########################################################################
####            Make AUTHORS file                                   ####
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
#     $2 - output: POT template file containing translatable tags
#
# Hint: Better don't use 'grep' for filtering-out the warning
# messages, since grep's exit status is 1 if there is no match.
xml2pot = ($(XML2PO) --output='-' $(1) \
          | $(MSGUNIQ) $(MSGUNIQFLAGS) \
          | $(MSGCAT) $(MSGCATFLAGS) - > "$(2)") 2>&1 \
          | $(SED) -e '/image file .* not found/d'; \
          test -s "$(2)" || rm -f "$(2)"; \
          touch -c -r `ls -t $(1) | head -n 1` "$(2)" || true; \
          test -s "$(2)"

# Merge template (pot) and message catalog (po) or create a new catalog
#
# Usage:
#     $(call pot2po,pot-file,language,po-file)
# Parameters:
#     $1 - input POT file
#     $2 - translation language
#     $3 - output PO file
pot2po = with_compendium="$(shell $(call get_compendium,$3)) \
                          $(shell $(call use_gimp_po_files,$2))"; \
         tmpfile=$(3).tmp; \
         if [ -s $(3) ]; then \
             $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} \
                 --output-file $${tmpfile} $(3) $(1); \
         else \
             $(MSGINIT) $(MSGINITFLAGS) --input $(1) --locale=$(2) --output=$(3); \
             pofile=$(3); \
             if [ -s $${pofile%/*}.po ]; then \
                 $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} \
                     --output-file $${tmpfile} $${pofile%/*}.po $(3); \
             elif [ -n "$${with_compendium}" ]; then \
                 $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} \
	             --output-file $${tmpfile} $(3) $(1); \
             else \
                 $(SED) -e '/Plural-Forms:/d' $(3) > $${tmpfile}; \
             fi; \
         fi; \
         test -s $${tmpfile} && mv -f $${tmpfile} $(3) || rm -f $${tmpfile}; \
         test -s $(3) && $(MSGFMT) $(MSGFMTFLAGS) $(3); \
         rm -f messages.mo messages.gmo; \
         test -s $(3)

# Merge PO file into (translated) XML file
#
# Usage:
#     $(call po2xml,en-xml-file,po-file,language,translated-xml-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - PO file containing translations
#     $3 - translation language
#     $4 - resulting (translated) XML file
po2xml = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
         | $(SED) -e '/Warning: image file .* not found./d'; \
         rm -f .xml2po.mo


#--------------------------------------------------------------#
#       Helper functions                                       #
#                                                              #
#       (special thanks to automake for resorting - of         #
#       course you know it better than any human author!)      #
#--------------------------------------------------------------#

make_target_dir = f=$(1); d=$${f%/*}; test -d $$d || $(MKDIR_P) $$d

copy = $(LN_S) $(abs_srcdir)/$(1) $(2)

# HIDE FROM AUTOMAKE #ifneq ($(COMPENDIUM),"")
# HIDE FROM AUTOMAKE #get_compendium = \
# HIDE FROM AUTOMAKE #	file="$(1)"; dir=$${file%/*}; \
# HIDE FROM AUTOMAKE #	while true; do \
# HIDE FROM AUTOMAKE #		if test -f $${dir}/$(COMPENDIUM); then \
# HIDE FROM AUTOMAKE #			opt="$${opt} --compendium=$${dir}/$(COMPENDIUM)"; \
# HIDE FROM AUTOMAKE #		fi; \
# HIDE FROM AUTOMAKE #		case "$${dir}" in \
# HIDE FROM AUTOMAKE #			po|*/po) break;; \
# HIDE FROM AUTOMAKE #			    */*) dir="$${dir%/*}";; \
# HIDE FROM AUTOMAKE #			      *) break;; \
# HIDE FROM AUTOMAKE #		esac; \
# HIDE FROM AUTOMAKE #	done; \
# HIDE FROM AUTOMAKE #	if test -n "$${opt}"; then echo $${opt}; fi
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #get_compendium =
# HIDE FROM AUTOMAKE #endif

# HIDE FROM AUTOMAKE #ifneq ($(GIMP_PO_ROOT),"")
# HIDE FROM AUTOMAKE #use_gimp_po_files = \
# HIDE FROM AUTOMAKE #	for po in $(GIMP_PO_ROOT)/po*/$(1).po; do \
# HIDE FROM AUTOMAKE #		test -f "$${po}" && echo '--compendium'="$${po}"; \
# HIDE FROM AUTOMAKE #	done
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #use_gimp_po_files =
# HIDE FROM AUTOMAKE #endif


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################
#
# xmldir/path/to/file/*.xml --> potdir/path/to/file.pot
POT_FILES  = $(patsubst src/%,pot/%.pot,$(filter-out src src/,$(SRC_DIRS)))
# Special case
POT_FILES += pot/gimp.pot
#
# Special case
pot/gimp.pot: $(srcdir)/src/*.xml
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)
# Special case: pot file for the authors DocBook file
# (src/preface/authors.xml, but this may change...)
# TODO: is there a better way?
AUTHORS_POT = $(AUTHORS_DOCBOOK_XML:src/%/$(notdir $(AUTHORS_DOCBOOK_XML))=pot/%.pot)
$(AUTHORS_POT): $(AUTHORS_DOCBOOK_XML) $(wildcard $(dir $(AUTHORS_DOCBOOK_XML))*.xml)
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)
pot/%.pot: $(srcdir)/src/%/*.xml
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)

# Targets suitable for command line
# ("make pot" will work even if pot exists)
pot: potfiles ;
potfiles: $(POT_FILES)
	$(msg) "--- Cleaning up pot files ..."
	$(cmd) $(find_l) pot/ $(file_predicates) | \
	while read potfile; do \
		potfile=$${potfile#pot/}; srcfile=src/$${potfile%.pot}.xml \
		test -e $${srcfile} || rm -f $${potfile}; \
	done


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################
#
# HIDE FROM AUTOMAKE #define MAKE_PO_RULES
# HIDE FROM AUTOMAKE #$(1)_PO_FILES = $$(patsubst pot/%.pot, $$(srcdir)/po/$(1)/%.po, $$(POT_FILES))
# HIDE FROM AUTOMAKE #ifeq ($$(filter po/$(1)/%.po,$$(MAKECMDGOALS)),)
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): $$(srcdir)/po/$(1)/%.po : pot/%.pot
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): $$(srcdir)/po/$(1)/%.po : pot/%.pot FORCE
# HIDE FROM AUTOMAKE #endif
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$@)
# HIDE FROM AUTOMAKE #	$$(msg) "[PO]  $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
# HIDE FROM AUTOMAKE #po-$(1): $$($(1)_PO_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
# HIDE FROM AUTOMAKE #endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_PO_RULES,$(LANG))))

# Special case 'en': do nothing :-)
po-en: ;

# Print translation statistics

status-%: po-status-% ;
po-status-%: po-%
	$(cmd) perl $(srcdir)/tools/get_po_status.pl po/$*

status-all: po-status-all ;
po-status-all:
	$(cmd) for podir in po/*; do \
		perl $(srcdir)/tools/get_po_status.pl \
			--nofiles --nosummary $${podir} \
		|| break; \
	done

todo-%: po-todo-% ;
po-todo-%: po-%
	$(cmd) perl $(srcdir)/tools/get_po_status.pl --todo po/$*

# Force updating po file
update-po/%.po:
	$(msg) "Deprecated, use 'make po/$*.po instead'"
	$(cmd) false


########################################################################
####            Generate XML prerequisites                          ####
########################################################################

# HIDE FROM AUTOMAKE #ifeq ($(filter help clean,$(MAKECMDGOALS)),)
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
# HIDE FROM AUTOMAKE #	$$(cmd) touch $$@
# HIDE FROM AUTOMAKE #	$$(cmd) for srcdir in $(SRC_DIRS); do \
# HIDE FROM AUTOMAKE #		ls $$$${srcdir}/*.xml >/dev/null 2>&1 || continue; \
# HIDE FROM AUTOMAKE #		srcdir=$$$${srcdir%/}; \
# HIDE FROM AUTOMAKE #		xmldir=xml/$(1)$$$${srcdir#src}; \
# HIDE FROM AUTOMAKE #		test "$$$${srcdir}" != "src" || srcdir="src/gimp"; \
# HIDE FROM AUTOMAKE #		pofile=po/$(1)$$$${srcdir#src}.po; \
# HIDE FROM AUTOMAKE #		echo "$$$${xmldir}/*.xml: $$$${pofile}"; \
# HIDE FROM AUTOMAKE #	done > $$@
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
# HIDE FROM AUTOMAKE #	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## This is indirectly used as HTML and PDF prerequisite:
# HIDE FROM AUTOMAKE #xml/$(1): $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) test -d $$@ && touch $$@ || $(mkdir_p) $$@
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## Targets suitable for command line
# HIDE FROM AUTOMAKE #xml-$(1): xml/$(1) $$($(1)_XML_FILES) xml/$(1)/images ;
# HIDE FROM AUTOMAKE #endef
# HIDE FROM AUTOMAKE #$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# Special case: en

en_XML_FILES = $(SRC_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(msg) "[XML] $@ (copy)"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) cp -f $< $@

xml/en: $(en_XML_FILES)
	$(cmd) test -d $@ && touch $@ || $(MKDIR_P) $@

# Images

# TODO: test new image files structure;
#   how to ensure that $@ is up-to-date without forcing
#   rebuild (which will also force e.g. html-% to be rebuilt 
#   -- use (~1500) image files as prerequisites?
xml/%/images: FORCE
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
	$(cmd) if test -d $@; then rm -rf $@/*; fi
	$(cmd) test -d $@ || $(MKDIR_P) $@
	$(cmd) $(echo_n) "Copying images ($*) ..."
	$(cmd) perl $(srcdir)/tools/make_image_links.pl -v \
	           $(srcdir)/images/common $(srcdir)/images/C \
		   xml/$*

# remove stale xml files
cleanup-xml-%:
	$(cmd) $(find_l) xml/$*/ $(file_predicates) | \
	while read xmlfile; do \
		test -e src/$${xmlfile#xml/$*/} || rm -vf $${xmlfile}; \
	done

# Target suitable for command line
xml-en: cleanup-xml-en xml/en $(en_XML_FILES) ;
xml-images-%: xml/%/images ;
images-%: xml-images-% html-images-% ;

.PHONY: FORCE
FORCE: ;


########################################################################
####            XML validation                                      ####
########################################################################

validate: validate-en ;
validate-%: xmllint-% ;

xmllint: xmllint-en ;
xmllint-%: log/%-xmllint.log
	$(cmd) test -s $< && cat $<

# HIDE FROM AUTOMAKE #define MAKE_XMLLINT_RULES
# HIDE FROM AUTOMAKE #log/$(1)-xmllint.log: $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) $$(call make_target_dir,$$(@))
# HIDE FROM AUTOMAKE #	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
# HIDE FROM AUTOMAKE #		echo "*** Validating XML ($(1)) ... "; \
# HIDE FROM AUTOMAKE #		$$(XMLLINT) $$(XMLLINTFLAGS) --xinclude xml/$(1)/gimp.xml \
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

# Note that Automake already defines an "html" target
html-local: $(foreach lang,$(LANGUAGES),html-$(lang)) ;

# Chain of rules for making html-LANG:
#     html-%  -->  index-%  -->  html/%/gimp-help.xml  -->
#         html/%/gimp-xrefs.xml  -->  html/%/index.html
html-%: index-% ;

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

####  HTML images  ####
# TODO: check/enhance new image files structure
html-images-%: html/%/images ;
html/%/images: xml/%/images
	$(cmd) test -d html/$* || $(MKDIR_P) html/$*
	$(cmd) test -e $@ || $(LN_S) ../../$< $@

# The xrefs file is a side effect of the HTML build
html/%/gimp-xrefs.xml: html/%/index.html
	$(cmd) touch $@

####  Context Help  ####
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
	html/%/gimp-xrefs.xml \
	html/%/images


########################################################################
####            Make PDF files:  XML --> PDF                        ####
########################################################################
if HAVE_DBLATEX

## Note that Automake already defines a "pdf" target
pdf-local: $(foreach lang,$(LANGUAGES),pdf-$(lang)) ;
pdf-%: pdf/%/gimp.pdf ;

# TODO: images (--fig-path option?); prerequisites
pdf/%/gimp.pdf: xml/% stylesheets/plainprint.xsl | xml/%/images
	$(cmd) if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(cmd) test -d pdf/$* || $(MKDIR_P) pdf/$*
	$(msg) "*** Making PDF ($*) ..."
	$(cmd) $(DBLATEX) $(DBLATEXFLAGS) $(DBLATEXEXTRAFLAGS) \
	    --xsl-user=$(srcdir)/stylesheets/plainprint.xsl \
	    --output=$@ \
	    xml/$*/gimp.xml

else

pdf-local pdf-%:
	@echo "*** Cannot build PDFs because dblatex(1) was not found ***"
	@exit 69

endif


########################################################################
####            Make ODF files:  XML --> ODF                        ####
########################################################################
if HAVE_DOCBOOK2ODF

odf: $(foreach lang,$(LANGUAGES),odf-$(lang)) ;
odf-%: odf/%/gimp.odt ;

# TODO: images; prerequisites
odf/%/gimp.odt: xml/%/gimp-alldocs.xml xml/%/images
	$(cmd) if test -f odf/%.odt; then rm -f odf/%.odt; fi
	$(cmd) test -d odf/$* || $(MKDIR_P) odf/$*
	$(msg) "*** Making ODF ($*) ..."
	$(cmd) $(DOCBOOK2ODF) $(DOCBOOK2ODFFLAGS) \
	    --debug -v \
	    --output-dir=`pwd` \
	    --output-file=$@ \
	    $< 

if HAVE_XMLLINT
# make temporary XML source file with all Xincludes resolved
xml/%/gimp-alldocs.xml: xml/%/gimp.xml
	$(XMLLINT) $(XMLLINTFLAGS) --xinclude --output $@ $<
else
# TODO: use xsltproc and a simple stylesheet?
xml/%/gimp-alldocs.xml: xml/%/gimp.xml
	@echo "*** WARNING: Cannot resolve xincludes ***"; \
	echo  "*** because xmllint(1) was not found. ***"; \
	cp -v $< $@
endif

else

odf odf-%:
	@echo "*** Cannot build ODFs because docbook2odf(1) was not found ***"
	@exit 69

endif


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
####        Language-specific HTML tarballs for distribution        ####
########################################################################

tarball_prefix = gimp-help-2-html
tarball_dir    = gimp-help-2
HTMLMETAFILES  = README AUTHORS COPYING MAINTAINERS

.SECONDARY: $(tarball_prefix)-%.tar
$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml \
		$(HTMLMETAFILES) tools/Makefile.html-package
	$(msg) "Making $@ ..."
	$(cmd) test ! -d $(tarball_dir)
	$(cmd) $(MKDIR_P) $(tarball_dir)/html
	$(cmd) cd $(tarball_dir)/html && $(LN_S) ../../html/$* .
	$(cmd) cp $(HTMLMETAFILES) $(tarball_dir)/
	$(cmd) $(SED) -e '/LANGUAGE *=/s/en/$*/' \
		tools/Makefile.html-package > $(tarball_dir)/Makefile
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
	$(cmd) rm -rf $(DESTDIR)$(helpdir)/*
	$(cmd) dir=$(DESTDIR)$(helpdir); \
	while [ -d "$${dir}" ]; do \
		rmdir $${dir} 2>/dev/null \
		&& echo removed $${dir} \
		&& dir=$${dir%/*} \
		|| break; \
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
		$(VALIDATEREFERENCESFLAGS); \
	else \
	    echo >&2 "*** Cannot check image references (no Python installed?) ***"; \
	fi

check-images-%: FORCE
	$(cmd) $(RMAKE) check-image-references \
		VALIDATEREFERENCESFLAGS="--imgdir=images/C,images/$*"

check-image-resolutions-%:
	$(cmd) /bin/sh tools/check_image_resolutions.sh images/$*

# special case 'en':
check-images-en check-images-C: check-image-references ;
check-image-resolutions-en: check-image-resolutions-C ;

.PHONY: checks check-image-references check-image-resolutions-%


if HAVE_DOT
########################################################################
####            Build system development                            ####
########################################################################

build-system.png: tools/build-system.dot
	$(cmd) $(DOT) -Tpng -o $@ $< && \
	echo "$@ created."

dot: build-system.png
endif


## TODO ## check-local: validate

all-local: html-local index AUTHORS

dist-hook: dist-copy-images generate-changelog

##  Note that number of images is *huge*, and if we stick image files in
##  EXTRA_DIST we get an "Argument list too long" error. So we handle it here.

generate-changelog:
	@if test -d "$(srcdir)/.git"; \
	then \
		echo Creating ChangeLog && \
		( cd "$(top_srcdir)" && \
		  echo '# Generated by Makefile. Do not edit.'; echo; \
		  $(top_srcdir)/missing --run git log --stat -t $(LAST_RELEASE_TAG)..HEAD ) > ChangeLog.tmp \
		&& mv -f ChangeLog.tmp $(top_distdir)/ChangeLog \
		|| ( rm -f ChangeLog.tmp ; \
			echo Failed to generate ChangeLog >&2 ); \
	else \
		echo A git clone is required to generate a ChangeLog >&2; \
	fi


dist-copy-images:
	$(cmd) test -d "$(top_srcdir)/images" && test -d "$(distdir)"
	@echo "Copying images into distdir $(distdir) ..."
	$(cmd)(cd $(top_srcdir) && tar -cf- --exclude=.git images) \
	| (cd $(distdir) && tar -xf-)
	$(cmd) test -d "$(distdir)/images" && test ! -d "$(distdir)/images/.git"


clean-local:
	$(cmd) rm -rf html
	$(cmd) rm -rf odf
	$(cmd) rm -rf pdf
	$(cmd) rm -rf xml
	$(cmd) rm -rf log
	$(cmd) rm -rf pot
	$(cmd) rm -f $(tarball_prefix)-*
	$(cmd) rm -f AUTHORS $(AUTHORS_DOCBOOK_XML) build-system.png
	$(cmd) rm -f .xml2po.mo messages.mo


maintainer-clean-local:
	$(cmd) rm -rf html

# Override automake-generated targets
Makefile: $(srcdir)/Makefile.in $(srcdir)/Makefile.am $(srcdir)/configure.ac $(srcdir)/autogen.sh
	$(msg) "!!! Updating '$@' running 'autogen.sh' ($? changed) !!!"
	$(cmd) opt=`test -e $(srcdir)/config.status && \
	     $(srcdir)/config.status --version | \
	     sed -e 's/.*with options "//' \
	         -e tmatch -e d -e :match -e 's/".*//' \
		 -e "s/'\([^'=]*\)=\([^']*\)'/\1='\2'/"`; \
	test -n "$${opt}" && eval $(srcdir)/autogen.sh $${opt}
$(srcdir)/Makefile.in: $(srcdir)/Makefile.am $(srcdir)/autogen.sh ;

$(top_builddir)/config.status: $(top_srcdir)/configure ;

$(top_srcdir)/configure: $(top_srcdir)/configure.ac ;

# GNU Make, please don't delete these targets when a target that depends
# on them fails, 'kay?
#			TODO: check: seems that xml/%/gimp.xml can be removed
.PRECIOUS: \
	xml/%/gimp.xml \
	xml/%/images \
	pdf/%/gimp.pdf \
	odf/%/gimp.odt \
	html/%/gimp-xrefs.xml \
	html/%/gimp-help.xml \
	html/%/index.html

.DELETE_ON_ERROR:

## EOF
