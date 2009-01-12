#########################################################################
####            Preliminaries: Variables and Functions              ####
########################################################################

# The GIMP manual languages
ifneq ($(LINGUAS),)
LANGUAGES  = $(LINGUAS)
else
ifneq ($(ALL_LINGUAS),)
LANGUAGES  = $(ALL_LINGUAS)
else
LANGUAGES ?= de en es fr it ko nl no pl ru sv
endif
endif

XML_LANG   = en
PO_LANGS   = $(filter-out $(XML_LANG), $(LANGUAGES))

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
MSGINITFLAGS  = --no-translator
MSGFMT        = msgfmt
MSGFMTFLAGS   = --check --use-fuzzy --statistics
MSGMERGE      = msgmerge
MSGMERGEFLAGS = --quiet --width=$(MSGWIDTH)

DBLATEX          = dblatex
DBLATEXFLAGS     = --verbose
DOCBOOK2ODF      = docbook2odf
DOCBOOK2ODFFLAGS =

# Standard shell commands
echo_n  = echo -n
mkdir_p = mkdir -p
ln_s    = ln -s

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
	-name '.svn' -prune \
	          -o        \
	-name '$(notdir $(AUTHORS_DOCBOOK_XML))' -prune \
	          -o        \
	-name '*.xml' -print

file_predicates =           \
	-name '.svn' -prune \
	        -o          \
	-type f -print

dir_predicates =            \
	-name '.svn' -prune \
	        -o          \
	-type d -print
xml_dir_predicates = $(dir_predicates)
pot_dir_predicates = $(dir_predicates)

# List of authors and contributors
AUTHORS_STYLESHEET_XML = stylesheets/authors.xml
# Automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML = src/preface/authors.xml

# Files & directories
XML_DIRS  := $(shell cd $(srcdir) && find src $(dir_predicates))
XML_FILES := $(shell cd $(srcdir) && find src $(xml_file_predicates)) \
	    $(AUTHORS_DOCBOOK_XML)

POT_FILES  = $(XML_FILES:src/%.xml=pot/%.pot)

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
#     $(call xml2pot,xml-file,pot-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - POT template file containing translatable tags
#
# Hint: Better don't use 'grep' for filtering-out the warning
# messages, since grep's exit status is 1 if there is no match.
xml2pot = ($(XML2PO) --output='-' "$(1)" \
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
             with_compendium=$(shell $(call get_compendium,$3)); \
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
ifeq ("$(XMLLINT)", "")
po2xml = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
         | sed -e '/Warning: image file .* not found./d'
else
po2xml = ($(XML2PO) --po-file=$(2) --language=$(3) --output='-' $(1) \
         | $(XMLLINT) $(XMLLINTFLAGS) --format --output $(4) -) 2>&1 \
         | sed -e '/Warning: image file .* not found./d'
endif


#--------------------------------------------------------------#
#       Helper functions                                       #
#--------------------------------------------------------------#

make_target_dir = f=$(1); d=$${f%/*}; test -d $$d || $(mkdir_p) $$d

copy = $(ln_s) $(abs_srcdir)/$(1) $(2)

ifneq ($(COMPENDIUM),"")
get_compendium = \
	dir="$(1)"; dir=$${dir%/*}; \
	while test "$${dir}" != "po"; do \
		if test -f $${dir}/$(COMPENDIUM); then \
			opt="$${opt} --compendium=$${dir}/$(COMPENDIUM)"; \
		fi; \
		dir="$${dir%/*}"; \
	done; \
	if test -n "$${opt}"; then echo $${opt}; fi
else
get_compendium =
endif


########################################################################
####            Main targets                                        ####
########################################################################

first: all
all: html index AUTHORS


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
$(POT_FILES): pot/%.pot : src/%.xml
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[POT] $@"
	$(cmd) if test -s $<; then $(call xml2pot,$<,$@); else touch $@; fi

# Targets suitable for command line
# ("make pot" will work even if pot exists)
pot update-pot: potfiles ;
potfiles: $(POT_FILES) ;


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################

define MAKE_PO_RULES
$(1)_PO_FILES = $$(patsubst pot/%.pot, po/$(1)/%.po, $$(POT_FILES))
$$($(1)_PO_FILES): po/$(1)/%.po : pot/%.pot
	$$(cmd) $$(call make_target_dir,$$@)
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
####            Make XML files:  PO --> XML(non-en)                 ####
########################################################################

define MAKE_XML_RULES
$(1)_XML_FILES = $$(XML_FILES:src/%=xml/$(1)/%)
$$($(1)_XML_FILES): xml/$(1)/%.xml : po/$(1)/%.po
	$$(cmd) $$(call make_target_dir,$$@)
	$$(msg) "[XML] $$@"
	$$(cmd) if test -s $$(@:xml/$(1)/%=src/%); then \
		$$(call po2xml,$$(@:xml/$(1)/%=src/%),$$<,$(1),$$@); \
	else \
		touch $$@; \
	fi

# This is indirectly used as HTML prerequisite:
xml/$(1): $$($(1)_XML_FILES)
	$$(cmd) test -d $$@ && touch $$@ || $(mkdir_p) $$@

# Targets suitable for command line
xml-$(1): xml/$(1) $$($(1)_XML_FILES) xml/$(1)/images ;
endef
$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# TODO: test new image files structure;
#       use (~1500) image files as prerequisites?
xml/%/images: FORCE
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) if test -L xml/$*; then rm -v xml/$*; fi
	$(cmd) if test -d $@; then rm -rf $@/*; fi
	$(cmd) test -d $@ || $(mkdir_p) $@
	$(msg) "*** Copying images ($*) ..."
	$(cmd) (cd images && find common C $(dir_predicates)) | \
	while read dir; do \
		dest=$${dir#*/}; \
		test -d $@/$${dest} || $(mkdir_p) $@/$${dest}; \
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

en_XML_FILES = $(XML_FILES:src/%=xml/en/%)
$(en_XML_FILES): xml/en/%.xml : src/%.xml
	$(cmd) if test -L xml/en; then rm -v xml/en; fi
	$(cmd) $(call make_target_dir,$@)
	$(msg) "[XML] $@"
	$(cmd) $(call copy,$<,$@)

xml/en: $(en_XML_FILES)
	$(cmd) if test -L $@; then rm -v $@; fi
	$(cmd) test -d $@ && touch $@ || $(mkdir_p) $@

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

define MAKE_XMLLINT_RULES
log/$(1)-xmllint.log: log $$($(1)_XML_FILES)
	$$(cmd) if type $$(XMLLINT) >/dev/null 2>&1; then \
		echo "*** Validating XML ($(1)) ... "; \
		$$(XMLLINT) $$(XMLLINTFLAGS) --xinclude xml/$(1)/gimp.xml \
		| sed -e 's,xmlns:xi="http://www.w3.org/2001/XInclude",,' \
		| $$(XMLLINT) $$(XMLLINTFLAGS) --nonet --valid \
			--output log/$(1).xml - 2>$$(@); \
		if test -s $$(@); then \
			echo "(You will find log and xml files in log/.)"; \
		else \
			echo "No errors."; \
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
	$(cmd) test -d html/$* || $(mkdir_p) html/$*
	$(cmd) $(ln_s) ../../xml/$*/images $@

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
####            HTML draft (single page preview)                    ####
########################################################################

%.draft: %.xml stylesheets/drafthtml.xsl
	@echo "Making draft page(s), ignore any XSLT complaints:"
	$(cmd) id=`sed -e 's/.*id=.//; tmatch; d; :match; s/["'"'"'].*//; q' $<`; \
	test -n "$$id" || id=noname; \
	langs="$(shell echo $@ | \
	               sed -e 's,^src/.*,$(LANGUAGES),; t' \
	                   -e 's,^xml/\([^/]\+\)/.*,\1,')"; \
	for lang in $${langs}; do \
		destdir=html/$${lang}; \
		test -d $${destdir} && continue || \
		$(mkdir_p) $${destdir}; \
		cp -fp $(srcdir)/stylesheets/*.css \
		       $(srcdir)/stylesheets/$$lang/*.css \
		    $${destdir} 2>/dev/null; \
	done; \
	\
	for lang in $${langs}; do \
		destdir=html/$${lang}; \
		echo "Making $${destdir}/$${id}-draft.html ... "; \
		xmlfile="$<"; xmlfile=$${xmlfile#*/}; \
		xmlfile=xml/$${lang}/$${xmlfile#$${lang}/}; \
		if [ "$${lang}" = "no" ]; then lang="nn"; fi; \
		$(XSLTPROC) \
		    $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
		    --xinclude \
		    --stringparam l10n.gentext.default.language $${lang} \
		    --novalid \
		    --output $${destdir}/$${id}-draft.html \
		    $(srcdir)/stylesheets/drafthtml.xsl \
		    $${xmlfile} \
		; \
	done && \
	echo "(Remember that links won't work in a draft file.)"


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
####            AUTHORS                                             ####
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

check-svn: check-svn-property ;

check-svn-property:
	$(cmd) if cd $(srcdir) && test -e tools/check_keywords_property.pl && \
	type perl >/dev/null 2>&1; then \
	    echo "*** Checking svn property ... "; \
	    perl tools/check_keywords_property.pl -v || true; \
	else \
	    echo >&2 "*** Cannot check svn property (no Perl installed?) ***"; \
	fi

.PHONY: check-svn check-svn-property


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


