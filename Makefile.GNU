########################################################################
####            Preliminaries: Variables and Functions              ####
########################################################################

# The GIMP manual languages
ALL_LINGUAS = de en es fr it ko nl nn pl ru sv zh_CN
LANGUAGES = $(if $(LINGUAS), \
              $(filter $(ALL_LINGUAS),$(LINGUAS)), \
	      $(ALL_LINGUAS))
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

# Essential external programs and their default options
XSLTPROC  = xsltproc
XSLTFLAGS = --nonet

XMLLINT      = xmllint
XMLLINTFLAGS = --nonet

XML2PO = tools/xml2po

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
DOCBOOK2ODF      = docbook2odf
DOCBOOK2ODFFLAGS =

SED = sed

# Standard shell commands
echo_n  = echo -n
mkdir_p = mkdir -p
ln_s    = ln -s
find_l  = find -L

# Calling make recursively
RMAKE = $(MAKE) -f Makefile.GNU --no-print-directory

# FIXME/TODO:
#     make it work with srcdir != builddir
# Directories
srcdir   = .
builddir = .
abs_srcdir   := $(shell cd $(srcdir) && pwd)
abs_builddir := $(shell pwd)

# The following dir names have been removed, IMHO we
# don't need them and they made the file less readable:
#xmldir   = src
#potdir   = pot
#podir    = po
#xmlpodir = xml
#htmldir  = html
#pdfdir   = pdf
#odfdir   = odf
#logdir   = log

# Find files and directories
xml_file_predicates =       \
	-name '.git' -prune \
	          -o        \
	-name '$(notdir $(AUTHORS_DOCBOOK_XML))' -prune \
	          -o        \
	-name '*.xml' -print

file_predicates =           \
	-name '.git' -prune \
	        -o          \
	-type f -print

dir_predicates =            \
	-name '.git' -prune \
	        -o          \
	-type d -print
src_dir_predicates = -name images -prune -o $(dir_predicates)
xml_dir_predicates = $(dir_predicates)
pot_dir_predicates = $(dir_predicates)

# List of authors and contributors (no DocBook)
AUTHORS_SOURCE_XML = stylesheets/authors.xml
# Automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML = src/preface/authors.xml
# Stylesheets generating AUTHORS 
AUTHORS_TEXT_STYLESHEETS = \
	stylesheets/authors_text.xsl \
	stylesheets/authors_common.xsl
# Stylesheets generating src/preface/authors.xml
AUTHORS_DOCBOOK_STYLESHEETS = \
	stylesheets/authors_docbook.xsl \
	stylesheets/authors_common.xsl

# Files & directories
ifneq "$(MAKECMDGOALS)" "help"
SRC_DIRS  := $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
SRC_FILES := $(shell cd $(srcdir) && $(find_l) src/ $(xml_file_predicates)) \
             $(AUTHORS_DOCBOOK_XML)
else
SRC_DIRS   = $(shell cd $(srcdir) && $(find_l) src/ $(src_dir_predicates))
SRC_FILES  = $(shell cd $(srcdir) && $(find_l) src/ $(xml_file_predicates)) \
             $(AUTHORS_DOCBOOK_XML)
endif

# XXX: requires that "plainhtml.xsl" has been renamed to "html.xsl"
HTML_STYLESHEETS = stylesheets/html*.xsl

# This variable is used by "msgmerge";
# use empty variable to disable the compendium option
COMPENDIUM = Compendium.po

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
         test -s $(3) && $(MSGFMT) $(MSGFMTFLAGS) $(3) || exit 70; \
         rm -f messages.mo messages.gmo

# Merge PO file into (translated) XML file
#
# Usage:
#     $(call po2xml,en-xml-file,po-file,language,translated-xml-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - PO file containing translations
#     $3 - translation language
#     $4 - resulting (translated) XML file
ifneq ("$(FORMAT_XML_WITH_XMLLINT)", "1")
po2xml = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
         | $(SED) -e '/Warning: image file .* not found./d'; \
         rm -f .xml2po.mo
else
po2xml = ($(XML2PO) --po-file=$(2) --language=$(3) --output='-' $(1) \
         | $(XMLLINT) $(XMLLINTFLAGS) --format --output $(4) -) 2>&1 \
         | $(SED) -e '/Warning: image file .* not found./d'; \
         rm -f .xml2po.mo
endif


#--------------------------------------------------------------#
#       Helper functions                                       #
#--------------------------------------------------------------#

make_target_dir = f=$(1); d=$${f%/*}; test -d $$d || $(mkdir_p) $$d

get_recent_file = $(shell ls -t $(1) | head -n 1)

copy = $(ln_s) $(abs_srcdir)/$(1) $(2)

ifneq ($(COMPENDIUM),"")
get_compendium = \
	file="$(1)"; dir=$${file%/*}; \
	while true; do \
		if test -f $${dir}/$(COMPENDIUM); then \
			opt="$${opt} --compendium=$${dir}/$(COMPENDIUM)"; \
		fi; \
		case "$${dir}" in \
			po|*/po) break;; \
			    */*) dir="$${dir%/*}";; \
			      *) break;; \
		esac; \
	done; \
	if test -n "$${opt}"; then echo $${opt}; fi
else
get_compendium =
endif

ifneq ($(GIMP_PO_ROOT),"")
use_gimp_po_files = \
	for po in $(GIMP_PO_ROOT)/po*/$(1).po; do \
		test -f "$${po}" && echo '--compendium'="$${po}"; \
	done
else
use_gimp_po_files =
endif


########################################################################
####            Main targets                                        ####
########################################################################

.PHONY: all
all: html index AUTHORS


########################################################################
####            Help!!!                                             ####
########################################################################

.PHONY: help
make.help:
	@echo >&2 'ERROR: cannot find the help file "$@"!'
	@exit 66
# TODO: replace with a "real" script tools/what-ever(?)
#   (probably "yes" if more features are needed...)
help: make.help
	$(cmd) $(SED) \
	    -e '### skip comments ###' \
	    -e '/^#/d' \
	    -e '### print if no "make" variable found ###' \
	    -e '/@/!b' \
	    -e '### replace "make" variables ###' \
	    -e 's/@LANGUAGES@/@$(LANGUAGES)@/' \
	    -e 's/@LINGUAS@/@$(LINGUAS)@/' \
	    -e 's/@ALL_LINGUAS@/@$(ALL_LINGUAS)@/' \
	    -e '### add commas ###' \
	    -e 'tloop' \
	    -e ':loop' \
	    -e '    ### mark value of variable (@@...@@) ###' \
	    -e '    s/@\([^@]*\)@/@@\1@@/' \
	    -e '    twhile' \
	    -e '    :while' \
	    -e '        s/\(@@[^,@]*\) \([^@]*@@\)/\1, \2/' \
	    -e '    twhile' \
	    -e '    s/@@\([^@]*\)@@/\1/' \
	    -e 'tloop' \
	$<


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################

# xmldir/path/to/file/*.xml --> potdir/path/to/file.pot
POT_FILES  = $(patsubst src/%,pot/%.pot,$(filter-out src src/,$(SRC_DIRS)))
# Special case
POT_FILES += pot/gimp.pot

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

define MAKE_PO_RULES
$(1)_PO_FILES = $$(patsubst pot/%.pot, po/$(1)/%.po, $$(POT_FILES))
$$($(1)_PO_FILES): po/$(1)/%.po : pot/%.pot
	$$(cmd) $$(call make_target_dir,$$@)
	$$(msg) "[PO]  $$@"
	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
po-$(1): $$($(1)_PO_FILES)
	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
	$$(cmd) $(find_l) po/$(1)/ -name $(COMPENDIUM) -prune -o $$(file_predicates) | \
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
update-po/%.po:
	$(cmd) po=$@; pot=pot/$${po#update-po/*/}t; \
	$(RMAKE) $${pot} && touch $${pot} && \
	$(RMAKE) po/$*.po

force-po/%:
	$(cmd) for po in po/$*/*.po; do \
		$(RMAKE) update-$${po}; \
	done


########################################################################
####            Generate XML prerequisites                          ####
########################################################################

#ifneq "$(MAKECMDGOALS)" "help"
#ifneq "$(UPDATE)" "nodeps"
include $(foreach LANG,$(PO_LANGS),xml/$(LANG)/.deps.mk)
#endif
#endif

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
	$(call po2xml,$$$${srcfile},$$$${pofile},$(1),$$@)

# This is indirectly used as HTML prerequisite:
xml/$(1): $$($(1)_XML_FILES)
	$$(cmd) test -d $$@ && touch $$@ || $(mkdir_p) $$@

# Targets suitable for command line
xml-$(1): xml/$(1) $$($(1)_XML_FILES) xml/$(1)/images ;
endef
$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# TODO: test new image files structure;
#   how to ensure that $@ is up-to-date without forcing
#   rebuild (which will also force e.g. html-% to be rebuilt)
#   -- use (~1500) image files as prerequisites?
xml/%/images: FORCE
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
	$(cmd) if test -d $@; then rm -rf $@/*; fi
	$(cmd) test -d $@ || $(mkdir_p) $@
	$(cmd) $(echo_n) "*** Copying images ($*) ..."
	$(cmd) perl tools/make_image_links.pl -v \
	           images/common images/C \
		   xml/$*

# Special case: en

en_XML_FILES = $(SRC_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(msg) "[XML] $@ (copy)"
	$(cmd) $(call make_target_dir,$@)
	$(cmd) cp -f $< $@

xml/en: $(en_XML_FILES)
	$(cmd) test -d $@ && touch $@ || $(mkdir_p) $@

# remove stale xml files
cleanup-xml-%:
	$(cmd) $(find_l) xml/$*/ $(file_predicates) | \
	while read xmlfile; do \
		test -e src/$${xmlfile#xml/$*/} || rm -vf $${xmlfile}; \
	done

# Target suitable for command line
xml-en: cleanup-xml-en xml/en $(en_XML_FILES) ;

.PRECIOUS: xml/%/images

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

define MAKE_XMLLINT_RULES
log/$(1)-xmllint.log: $$($(1)_XML_FILES)
	$$(cmd) $$(call make_target_dir,$$(@))
	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
		echo "*** Validating XML ($(1)) ... "; \
		$$(XMLLINT) $$(XMLLINTFLAGS) --xinclude xml/$(1)/gimp.xml \
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
####            Make HTML files:  XML --> HTML                      ####
########################################################################

html: $(foreach lang,$(LANGUAGES),html-$(lang)) ;

# Chain of rules for making html-LANG:
#     html-%  -->  index-%  -->  html/%/gimp-help.xml  -->
#         html/%/gimp-xrefs.xml  -->  html/%/index.html
html-%: index-% ;

html/%/index.html: xml/% $(HTML_STYLESHEETS) html/%/images
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

# TODO: check/enhance new image files structure
html/%/images: xml/%/images
	$(cmd) test -d html/$* || $(mkdir_p) html/$*
	$(cmd) test -e $@ || $(ln_s) ../../$< $@

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

ifneq ("$(DBLATEX)", "")

pdf: $(foreach lang,$(LANGUAGES),pdf-$(lang)) ;
pdf-%: pdf/%/gimp.pdf ;

# TODO: images (--fig-path option?); prerequisites
pdf/%/gimp.pdf: xml/%/gimp.xml stylesheets/plainprint.xsl xml/%/images
	$(cmd) if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(cmd) test -d pdf/$* || $(mkdir_p) pdf/$*
	$(msg) "*** Making PDF ($*) ..."
	$(cmd) $(DBLATEX) $(DBLATEXFLAGS) $(DBLATEXEXTRAFLAGS) \
	    --xsl-user=$(srcdir)/stylesheets/plainprint.xsl \
	    --output=$@ $<

.PRECIOUS: pdf/%/gimp.pdf

else

pdf pdf-%:
	@echo "*** Cannot build PDFs because DBLATEX was not defined ***"
	@exit 69

endif


########################################################################
####            Make ODF files:  XML --> ODF                        ####
########################################################################

ifneq ("$(DOCBOOK2ODF)","")

odf: $(foreach lang,$(LANGUAGES),odf-$(lang)) ;
odf-%: odf/%/gimp.odt ;

# TODO: images; prerequisites
odf/%/gimp.odt: xml/%/gimp-alldocs.xml xml/%/images
	$(cmd) if test -f odf/%.odt; then rm -f odf/%.odt; fi
	$(cmd) test -d odf/$* || $(mkdir_p) odf/$*
	$(msg) "*** Making ODF ($*) ..."
	$(cmd) $(DOCBOOK2ODF) $(DOCBOOK2ODFFLAGS) \
	    --debug -v \
	    --output-dir=`pwd` \
	    --output-file=$@ \
	    $< 

# make temporary XML source file with all Xincludes resolved
xml/%/gimp-alldocs.xml: xml/%/gimp.xml
	$(msg) "*** Merging XML ..."
	$(cmd) $(XMLLINT) $(XMLLINTFLAGS) --xinclude --output $@ $<

.PRECIOUS: odf/%/gimp.odt

else

odf odf-%:
	@echo "*** Cannot build ODFs because DOCBOOK2ODF was not defined ***"
	@exit 69

endif


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


########################################################################
####            Clean up                                            ####
########################################################################

clean:
	$(cmd) for dir in pot xml log html pdf odf; do \
		test -d $${dir} || continue; \
		echo "Removing  $${dir} ..."; \
		rm -rf $${dir}; \
	done
	$(cmd) for f in AUTHORS $(AUTHORS_DOCBOOK_XML) build-system.png; do \
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
		$(VALIDATEREFERENCESFLAGS); \
	else \
	    echo >&2 "*** Cannot check image references (no Python installed?) ***"; \
	fi

check-images-%: FORCE
	$(cmd) $(RMAKE) check-image-references \
		VALIDATEREFERENCESFLAGS="--imgdir=images/C,images/$*"

# special case 'en':
check-images-en check-images-C: check-image-references ;

.PHONY: check-image-references


########################################################################
####            Build system development & debugging                ####
########################################################################

build-system.png: tools/build-system.dot
	$(cmd) if type dot >/dev/null; then \
		dot -Tpng -o $@ $<; \
	fi

dot: build-system.png
	$(cmd) if test -e $<; then \
		if type display >/dev/null; then \
			display $<; \
		elif type xv >/dev/null; then \
			xv $<; \
		fi; \
	fi


.NOEXPORT:
