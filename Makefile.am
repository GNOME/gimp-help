## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference

# The GIMP manual languages
# HIDE FROM AUTOMAKE #ifneq ($(LINGUAS),)
# HIDE FROM AUTOMAKE #LANGUAGES  = $(LINGUAS)
# HIDE FROM AUTOMAKE #else ifneq ($(ALL_LINGUAS),)
# HIDE FROM AUTOMAKE #LANGUAGES  = $(ALL_LINGUAS)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #LANGUAGES ?= de en es fr it ko nl no pl ru sv
# HIDE FROM AUTOMAKE #endif

XML_LANG = en
PO_LANGS = $(filter-out $(XML_LANG), $(LANGUAGES))

## Essential external programs and their default options
## (some of these variables are provided via "configure" -- see configure.ac)
##
## XSLTPROC  = xsltproc
## XSLTFLAGS = --nonet
##
## XMLLINT      = xmllint
XMLLINTFLAGS = --nonet
##
## XML2PO = tools/xml2po
##
MSGWIDTH      = 79
## MSGUNIQ       = msguniq 
MSGUNIQFLAGS  = 
## MSGCAT        = msgcat 
MSGCATFLAGS   = --width=$(MSGWIDTH)
## MSGINIT       = msginit
## MSGINITFLAGS  = --no-translator
## MSGFMT        = msgfmt
## MSGFMTFLAGS   = --check --use-fuzzy --statistics
## MSGMERGE      = msgmerge
MSGMERGEFLAGS = --quiet --width=$(MSGWIDTH)
##
## DBLATEX       = dblatex
DBLATEXFLAGS     = --verbose
## DOCBOOK2ODF      = docbook2odf
DOCBOOK2ODFFLAGS =

# Calling make recursively
RMAKE = $(MAKE) $(MAKEFLAGS) --no-print-directory

# Standard shell commands
echo_n = echo $(ECHO_N)

# options for the "find images" command:
image_find_predicates =     \
	-name '.svn' -prune \
	-o \
	  -type d \
	  \( -name '[a-z][a-z]' -o -name '[a-z][a-z]_[A-Z][A-Z]' \) \
	  $(image_lang_exclude) \
	  -prune \
	-o \
	\( \
	-name '*.png' -o \
	-name '*.jpg' -o \
	-name '*.mng' -o \
	-name '*.xcf' -o \
	-name '*.gif'    \
	\) -print

# languages we want to exclude from installing images
image_lang_exclude = \
	$(shell echo $(strip $(LANGUAGES)) | \
	        $(SED) -e '/^$$/d; \
	                   s/ / -o -name /g; \
	                   s/^/! \\( -name /; \
	                   s/$$/ \\)/ ' \
	)

# find HTML files (used when installing html)
html_files_find_predicates = \
	-type f -name '*.*' \
	-print

# XML files excluding automatically generated files
src_find_predicates =       \
	-name '.svn' -prune \
	-o                  \
	-name '$(notdir $(AUTHORS_DOCBOOK_XML))' -prune \
	-o                  \
	-name '*.xml' -print

#  for generating a list of files (of any type)
file_predicates =           \
	-name '.svn' -prune \
	        -o          \
	-type f -print

# for generating a list of directories
dir_predicates =            \
	-name '.svn' -prune \
	        -o          \
	-type d -print

# for generating xml source directories
src_dir_predicates = -name images -prune -o $(dir_predicates)

# list of authors and contributors (no DocBook)
AUTHORS_STYLESHEET_XML = stylesheets/authors.xml
# automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML = src/preface/authors.xml

# lists of source (XML) files and source directories
SRC_DIRS  = $(shell cd $(srcdir) && find src $(src_dir_predicates))
SRC_FILES = $(shell cd $(srcdir) && find src $(src_find_predicates)) \
	    $(AUTHORS_DOCBOOK_XML)

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
	stylesheets/makeindex.xsl	\
	stylesheets/plainprint.xsl	\
	stylesheets/plainhtml.xsl.in	\
	stylesheets/htmlalternate.xsl	\
	stylesheets/profile.xsl

# additional files to be distributed (automake)
EXTRA_DIST = \
	AUTHORS				\
	HACKING				\
	INSTALL				\
	TERMINOLOGY			\
	$(COMMON_CSS_FILES)		\
	$(OTHER_CSS_FILES)		\
	$(SRC_FILES)			\
	$(XSL_FILES)

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

AUTHORS: $(AUTHORS_STYLESHEET_XML) stylesheets/authors_text.xsl $(AUTHORS_DOCBOOK_XML)
	$(msg) "[DOC] $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/authors_text.xsl \
	  $< \
	  > $@
	
$(AUTHORS_DOCBOOK_XML): $(AUTHORS_STYLESHEET_XML) stylesheets/authors_*.xsl
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
          | sed -e '/image file .* not found/d'

# Merge template (pot) and message catalog (po) or create a new catalog
#
# Usage:
#     $(call pot2po,pot-file,language,po-file)
# Parameters:
#     $1 - input POT file
#     $2 - translation language
#     $3 - output PO file
pot2po = if [ -s $(3) ]; then \
             with_compendium="$(shell $(call get_compendium,$3))"; \
             tmpfile=$(3).tmp; \
             $(MSGFMT)   $(MSGFMTFLAGS)   $(3); \
             $(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} $(3) $(1) \
             > $${tmpfile}; \
             test -s  $${tmpfile} && mv -f $${tmpfile} $(3) || rm -f $${tmpfile}; \
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
if HAVE_XMLLINT
po2xml = ($(XML2PO) --po-file=$(2) --language=$(3) --output='-' $(1) \
         | $(XMLLINT) $(XMLLINTFLAGS) --format --output $(4) -) 2>&1 \
         | $(SED) -e '/Warning: image file .* not found./d'
else
po2xml = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
         | $(SED) -e '/Warning: image file .* not found./d'
endif


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
# HIDE FROM AUTOMAKE #	dir="$(1)"; dir=$${dir%/*}; \
# HIDE FROM AUTOMAKE #	while test "$${dir}" != "po"; do \
# HIDE FROM AUTOMAKE #		if test -f $${dir}/$(COMPENDIUM); then \
# HIDE FROM AUTOMAKE #			opt="$${opt} --compendium=$${dir}/$(COMPENDIUM)"; \
# HIDE FROM AUTOMAKE #		fi; \
# HIDE FROM AUTOMAKE #		dir="$${dir%/*}"; \
# HIDE FROM AUTOMAKE #	done; \
# HIDE FROM AUTOMAKE #	if test -n "$${opt}"; then echo $${opt}; fi
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #get_compendium =
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
pot/gimp.pot: src/*.xml
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
pot/%.pot: src/%/*.xml
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) $(call xml2pot,$^,$@)
#
# Targets suitable for command line
# ("make pot" will work even if pot exists)
pot: potfiles ;
potfiles: $(POT_FILES) ;


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################
#
# HIDE FROM AUTOMAKE #define MAKE_PO_RULES
# HIDE FROM AUTOMAKE #$(1)_PO_FILES = $$(patsubst pot/%.pot, po/$(1)/%.po, $$(POT_FILES))
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): po/$(1)/%.po : pot/%.pot
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
	$(cmd) perl tools/get_po_status.pl po/$*

status-all: po-status-all ;
po-status-all:
	$(cmd) for podir in po/*; do \
		perl tools/get_po_status.pl --nofiles --nosummary $${podir} || break; \
	done


########################################################################
####            Generate XML prerequisites                          ####
########################################################################

include $(foreach LANG,$(PO_LANGS),xml/$(LANG)/.deps.mk)

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
# HIDE FROM AUTOMAKE #	srcfile=src/$$$${stem}.xml; \
# HIDE FROM AUTOMAKE #	test "$$$${stem}" != "$$$${stem%/*}" && stem=$$$${stem%/*} || stem=gimp; \
# HIDE FROM AUTOMAKE #	pofile=po/$(1)/$$$${stem}.po; \
# HIDE FROM AUTOMAKE #	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## This is indirectly used as HTML prerequisite:
# HIDE FROM AUTOMAKE #xml/$(1): $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) test -d $$@ && touch $$@ || $(mkdir_p) $$@
# HIDE FROM AUTOMAKE #
# HIDE FROM AUTOMAKE ## Targets suitable for command line
# HIDE FROM AUTOMAKE #xml-$(1): xml/$(1) $$($(1)_XML_FILES) xml/$(1)/images ;
# HIDE FROM AUTOMAKE #endef
# HIDE FROM AUTOMAKE #$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# TODO: test new image files structure;
#       use (~1500) image files as prerequisites?
xml/%/images: FORCE
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
	$(cmd) if test -d $@; then rm -rf $@/*; fi
	$(cmd) test -d $@ || $(MKDIR_P) $@
	$(msg) "*** Copying images ($*) ..."
	$(cmd) (cd images && find common C $(dir_predicates)) | \
	while read dir; do \
		dest=$${dir#*/}; \
		test "$${dir}" != "$${dest}" || continue; \
		test -d $@/$${dest} || $(MKDIR_P) $@/$${dest}; \
	done
	$(cmd) (cd images && find common C $(file_predicates)) | \
	while read image; do \
		if [ "$*" != "en" ]; then \
			localized=$*/$${image#C/}; \
			test -e images/$${localized} && image=$${localized}; \
		fi; \
		dest=$${image#*/}; \
		$(call copy,images/$${image},$@/$${dest}); \
	done

# Special case: en

en_XML_FILES = $(SRC_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(cmd) if test -L xml/en; then rm -v xml/en; fi
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[XML] $@"
	$(cmd) $(call copy,$<,$@)

xml/en: $(en_XML_FILES)
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) test -d $@ && touch $@ || $(MKDIR_P) $@

# Target suitable for command line
xml-en: xml/en ;

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
# HIDE FROM AUTOMAKE #log/$(1)-xmllint.log: log $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
# HIDE FROM AUTOMAKE #		echo "*** Validating XML ($(1)) ... "; \
# HIDE FROM AUTOMAKE #		$$(XMLLINT) $$(XMLLINTFLAGS) --xinclude xml/$(1)/gimp.xml \
# HIDE FROM AUTOMAKE #		| $(SED) -e 's,xmlns:xi="http://www.w3.org/2001/XInclude",,' \
# HIDE FROM AUTOMAKE #		| $$(XMLLINT) $$(XMLLINTFLAGS) --nonet --valid \
# HIDE FROM AUTOMAKE #			--output log/$(1).xml - 2>$$(@); \
# HIDE FROM AUTOMAKE #		if test -s $$(@); then \
# HIDE FROM AUTOMAKE #			echo "(You will find log and xml files in log/.)"; \
# HIDE FROM AUTOMAKE #		else \
# HIDE FROM AUTOMAKE #			echo "No errors."; \
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

html/%/index.html: xml/% $(HTML_STYLESHEETS) html/images html/%/images
	$(msg) "*** Making html for $* ... "
	$(cmd) rm -f html/$*/*.*

	$(cmd) test "$*" = "no" && lang="nn" || lang="$*"; \
	$(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  --xinclude \
	  --stringparam l10n.gentext.default.language $${lang} \
	  -o html/$*/ \
	  stylesheets/plainhtml.xsl \
	  xml/$*/gimp.xml

	$(cmd) for file in $(srcdir)/stylesheets/*.css; do \
		if [ -f $$file ]; then cp -fp $$file html/$*; fi; \
	done

	$(cmd) for file in $(srcdir)/stylesheets/$*/*.css; do \
		if [ -f $$file ]; then cp -fp $$file html/$*; fi; \
	done

# TODO: check/enhance new image files structure
html/images: FORCE
	$(cmd) if test -L $@; then rm -v $@; fi

html/%/images: xml/%/images
	$(cmd) test -d html/$* || $(MKDIR_P) html/$*
	$(cmd) $(LN_S) ../../xml/$*/images $@

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
pdf/%/gimp.pdf: xml/%/gimp.xml stylesheets/plainprint.xsl xml/%/images
	$(cmd) if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(cmd) test -d pdf/$* || $(MKDIR_P) pdf/$*
	$(msg) "*** Making PDF ($*) ..."
	$(cmd) $(DBLATEX) $(DBLATEXFLAGS) $(DBLATEXEXTRAFLAGS) \
	    --xsl-user=$(srcdir)/stylesheets/plainprint.xsl \
	    --output=$@ $<

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
	$(cmd) id=`sed -e 's/.*id=.//; tmatch; d; :match; s/["'"'"'].*//; q' $<`; \
	test -n "$${id}" || id=noname; \
	lang=$(shell echo $< | sed -e 's,^xml/,,; s,/.*,,'); \
	destdir=html/$${lang}; \
	test -d $${destdir}/images || $(RMAKE) $${destdir}/images; \
	cp -f $(srcdir)/stylesheets/*.css $(srcdir)/stylesheets/$${lang}/*.css\
	    $${destdir} 2>/dev/null; \
	if [ "$${lang}" = "no" ]; then lang="nn"; fi; \
	destfile="$${destdir}/$${id}-draft.html"; \
	echo "Making $${destfile} (ignore any XSLT complaints) ..."; \
	$(XSLTPROC) \
	    $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	    --xinclude \
	    --stringparam l10n.gentext.default.language $${lang} \
	    --novalid \
	    --output $${destfile} \
	    $(srcdir)/stylesheets/drafthtml.xsl \
	    $<

preview-po/%.po: preview-xml/%.xml ;

preview-src/%.xml: $(foreach lang,$(LANGUAGES),preview-xml/$(lang)/%.xml)
	$(msg) "(Remember that links won't work in a draft file.)"

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

# HIDE FROM AUTOMAKE #tarball_prefix := gimp-help-2-html

.SECONDARY: $(tarball_prefix)-%.tar
$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml
	$(cmd) rm -rf $(tarball_prefix)-$*
	$(cmd) $(MKDIR_P) $(tarball_prefix)-$*
	$(cmd) cd $(tarball_prefix)-$* && $(LN_S) ../html/$* .
	$(cmd) cd $(tarball_prefix)-$* && $(LN_S) ../html/images .
	$(cmd) tar -chf $@ --exclude .svn $(tarball_prefix)-$*
	$(cmd) rm -rf $(tarball_prefix)-$*

$(tarball_prefix)-%.tar.gz: $(tarball_prefix)-%.tar
	gzip -c9 $< > $@

$(tarball_prefix)-%.tar.bz2: $(tarball_prefix)-%.tar
	bzip2 -c9 $< > $@

$(tarball_prefix)-%.zip: $(tarball_prefix)-%.tar
	tar xf $<
	zip -9r $@ $(tarball_prefix)-$*
	rm -rf $(tarball_prefix)-$*

html-dist: \
	$(foreach lang,$(LANGUAGES), \
		$(tarball_prefix)-$(lang).tar.gz \
		$(tarball_prefix)-$(lang).tar.bz2 \
		$(tarball_prefix)-$(lang).zip \
	)


########################################################################
####            Source file checks                                  ####
########################################################################

# Note that the default (autoconf) target name is "check".
checks: check-svn-property check-image-references ;
check-svn: check-svn-property ;
check-images: check-image-references ;

check-svn-property:
	$(cmd) if cd $(srcdir) && test -e tools/check_keywords_property.pl && \
	type perl >/dev/null 2>&1; then \
	    echo "*** Checking svn property ... "; \
	    perl tools/check_keywords_property.pl -v || true; \
	else \
	    echo >&2 "*** Cannot check svn property (no Perl installed?) ***"; \
	fi

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

# special case 'en':
check-images-en check-images-C: check-image-references ;

.PHONY: checks check-svn-property check-image-references




## TODO ## #### Installation
## TODO ## 
## TODO ## install-data-local:
## TODO ## 	$(MKDIR_P) $(DESTDIR)$(helpdir)
## TODO ## 
## TODO ## 	@$(echo_n) "** Installing HTML:"
## TODO ## 	@cd html && \
## TODO ## 	for lang in $(ALL_LINGUAS); do \
## TODO ## 		$(MKDIR_P) $(DESTDIR)$(helpdir)/$$lang && $(echo_n) " $$lang"; \
## TODO ## 		find $$lang $(html_files_find_predicates) | \
## TODO ## 		while read file; do \
## TODO ## 		  $(INSTALL_DATA) $$file $(DESTDIR)$(helpdir)/$$file || exit 66; \
## TODO ## 		done \
## TODO ## 	done
## TODO ## 	@echo .
## TODO ## 
## TODO ## 	@echo "** Installing images: (G=gif, J=jpg, M=mng, P=png, X=xcf)"
## TODO ## 
## TODO ## 	@(cd $(top_srcdir) && find images $(image_find_predicates)) | \
## TODO ## 	while read file; do \
## TODO ## 		case "$$file" in \
## TODO ## 		  *.png) $(echo_n) P ;; \
## TODO ## 		  *.jpg) $(echo_n) J ;; \
## TODO ## 		  *.xcf) $(echo_n) X ;; \
## TODO ## 		  *.mng) $(echo_n) M ;; \
## TODO ## 		  *.gif) $(echo_n) G ;; \
## TODO ## 		esac; \
## TODO ## 		test -d $(DESTDIR)$(helpdir)/$${file%/*} || \
## TODO ## 		$(MKDIR_P) $(DESTDIR)$(helpdir)/$${file%/*}; \
## TODO ## 		$(INSTALL) $(top_srcdir)/$$file $(DESTDIR)$(helpdir)/$$file || exit 66; \
## TODO ## 	done
## TODO ## 	@echo .
## TODO ## 
## TODO ## uninstall-local:
## TODO ## 	rm -rf $(DESTDIR)$(helpdir)

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

dist-hook: dist-copy-images

##  Note that number of images is *huge*, and if we stick image files in
##  EXTRA_DIST we get an "Argument list too long" error. So we handle it here.

dist-copy-images:
	$(cmd) test -d "$(top_srcdir)/images" && test -d "$(distdir)"
	@echo "Copying images into distdir $(distdir) ..."
	$(cmd)(cd $(top_srcdir) && tar -cf- --exclude=.svn images) \
	| (cd $(distdir) && tar -xf-)
	$(cmd) test -d "$(distdir)/images" && test ! -d "$(distdir)/images/.svn"


clean-local:
	$(cmd) rm -rf html
	$(cmd) rm -rf odf
	$(cmd) rm -rf pdf
	$(cmd) rm -rf xml
	$(cmd) rm -rf log
	$(cmd) rm -rf pot
	$(cmd) rm -f $(tarball_prefix)-*
	$(cmd) rm -f AUTHORS $(AUTHORS_DOCBOOK_XML) build-system.png


maintainer-clean-local:
	$(cmd) rm -rf html

# GNU Make, please don't delete these targets when a target that depends
# on them fails, 'kay?
#
.PRECIOUS: \
	xml/%/gimp.xml \
	pdf/%/gimp.pdf \
	odf/%/gimp.odt \
	html/%/gimp-xrefs.xml \
	html/%/gimp-help.xml \
	html/%/index.html

.DELETE_ON_ERROR:

## EOF
