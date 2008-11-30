## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference

# The GIMP manual languages
# HIDE FROM AUTOMAKE #ifneq ($(LINGUAS),)
# HIDE FROM AUTOMAKE #LANGUAGES  = $(LINGUAS)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #ifneq ($(ALL_LINGUAS),)
# HIDE FROM AUTOMAKE #LANGUAGES  = $(ALL_LINGUAS)
# HIDE FROM AUTOMAKE #else
# HIDE FROM AUTOMAKE #LANGUAGES ?= de en es fr it ko nl no pl ru sv
# HIDE FROM AUTOMAKE #endif
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
## MSGUNIQ       = msguniq 
MSGUNIQFLAGS  = 
## MSGCAT        = msgcat 
MSGCATFLAGS   = --width=80 
## MSGINIT       = msginit
## MSGINITFLAGS  = --no-translator
## MSGFMT        = msgfmt
## MSGFMTFLAGS   = --check --use-fuzzy --statistics
## MSGMERGE      = msgmerge
## MSGMERGEFLAGS = --quiet --backup=none --update
##
## DBLATEX       = dblatex
DBLATEXFLAGS  =
## DOCBOOK2ODF      = docbook2odf
DOCBOOK2ODFFLAGS =

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
	$(shell echo $(strip $(ALL_LINGUAS)) | \
	        sed -e '/^$$/d; \
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

# for generating a list of directories
dir_predicates =        \
	-name '.svn' -prune \
	        -o          \
	-type d -print

# lists of source (XML) files and source directories
XML_DIRS  = $(shell cd $(srcdir) && find $(xmldir) $(dir_predicates))
XML_FILES = $(shell cd $(top_srcdir) && find src $(src_find_predicates)) \
	    $(AUTHORS_DOCBOOK_XML)
# list of source po template files
POT_FILES = $(XML_FILES:$(xmldir)/%.xml=$(potdir)/%.pot)

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
	$(XML_FILES)			\
	$(XSL_FILES)

# list of authors and contributors
AUTHORS_STYLESHEET_XML = stylesheets/authors.xml
# automatically generated authors section (DocBook)
AUTHORS_DOCBOOK_XML = src/preface/authors.xml

# TODO?: rename "plainhtml.xsl" to "html.xsl" and use ...
# ... HTML_STYLESHEETS = stylesheets/html*.xsl
HTML_STYLESHEETS = stylesheets/plainhtml.xsl stylesheets/htmlalternate.xsl

#
DISTCHECK_CONFIGURE_FLAGS = --without-gimp

# gimp-help directories
## remember that automake defines "srcdir"
helpdir  = $(gimpdatadir)/help
xmldir   = src
potdir   = pot
podir    = po
xmlpodir = xml
htmldir  = html
pdfdir   = pdf
odfdir   = odf
logdir   = log


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
	@echo "Creating $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) \
	  $(srcdir)/stylesheets/authors_text.xsl \
	  $< \
	  > $@
	
$(AUTHORS_DOCBOOK_XML): $(AUTHORS_STYLESHEET_XML) stylesheets/authors_*.xsl
	@echo "Creating $@"
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) \
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
#     $(call xml2pot,xml-file,pot-file)
# Parameters:
#     $1 - original (untranslated) XML file
#     $2 - POT template file containing translatable tags
#
# Hint: Do not use 'grep' for filtering-out the warning
# messages, since grep's exit status is 1 if there is no match.
xml2pot = ($(XML2PO) --output='-' "$(1)" \
          | $(MSGUNIQ) $(MSGUNIQFLAGS) \
          | $(MSGCAT) $(MSGCATFLAGS) - > "$(2)") 2>&1 \
          | sed -e '/image file .* not found/d'

# Merge template (pot) and message catalog (po)
# or create a new catalog
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
if HAVE_XMLLINT
po2xml = ($(XML2PO) --po-file=$(2) --language=$(3) --output='-' $(1) \
         | $(XMLLINT) $(XMLLINTFLAGS) --format --output $(4) -) 2>&1 \
         | sed -e '/Warning: image file .* not found./d'
else
po2xml = $(XML2PO) --po-file=$(2) --language=$(3) --output=$(4) $(1) 2>&1 \
         | sed -e '/Warning: image file .* not found./d'
endif


########################################################################
####            Make pot files:  XML(en) --> POT                    ####
########################################################################

$(POT_FILES): $(potdir)/%.pot : $(xmldir)/%.xml
	$(cmd) f=$@; d=$${f%/*}; test -d $$d || $(mkdir_p) $$d
	$(msg) "[POT] $@"
	$(cmd) if test -s $<; then \
	  $(call xml2pot,$<,$@);\
	else \
	  touch $@; \
	fi

# Targets suitable for command line
# ("make pot" will work even if pot exists)
pot update-pot: potfiles
potfiles: $(POT_FILES)


########################################################################
####            Make po files:  POT --> PO                          ####
########################################################################

# HIDE FROM AUTOMAKE #define MAKE_PO_RULES
# HIDE FROM AUTOMAKE #$(1)_PO_FILES = $$(patsubst $$(potdir)/%.pot, $$(podir)/$(1)/%.po, $$(POT_FILES))
# HIDE FROM AUTOMAKE #$$($(1)_PO_FILES): $$(podir)/$(1)/%.po : $$(potdir)/%.pot
# HIDE FROM AUTOMAKE #	$$(cmd) f=$$@; d=$$$${f%/*}; test -d $$$$d || $$(mkdir_p) $$$$d
# HIDE FROM AUTOMAKE #	$$(msg) "[PO]  $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) if test -s $$<; then $$(call pot2po,$$<,$(1),$$@); else touch $$@; fi
# HIDE FROM AUTOMAKE ## Debugging
# HIDE FROM AUTOMAKE #list-pofiles-$(1) list-po-files-$(1) list-po-$(1):
# HIDE FROM AUTOMAKE #	@echo $$($(1)_PO_FILES)
# HIDE FROM AUTOMAKE #po-$(1): $$($(1)_PO_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) if test -e messages.mo; then rm -f messages.mo; fi
# HIDE FROM AUTOMAKE #endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_PO_RULES,$(LANG))))

# Targets suitable for command line
update-po-%: po-%

# Special case 'en': do nothing :-)
po-en: ;


########################################################################
####            Make XML files:  PO --> XML(non-en)                 ####
########################################################################

# HIDE FROM AUTOMAKE #define MAKE_XML_RULES
# HIDE FROM AUTOMAKE #$(1)_XML_FILES = $$(XML_FILES:$$(xmldir)/%=$$(xmlpodir)/$(1)/%)
# HIDE FROM AUTOMAKE #$$($(1)_XML_FILES): $$(xmlpodir)/$(1)/%.xml : $$(podir)/$(1)/%.po
# HIDE FROM AUTOMAKE #	$$(cmd) f=$$@; d=$$$${f%/*}; test -d $$$$d || $$(mkdir_p) $$$$d
# HIDE FROM AUTOMAKE #	$$(msg) "[XML] $$@"
# HIDE FROM AUTOMAKE #	$$(cmd) if test -s $$(@:$$(xmlpodir)/$(1)/%=$$(xmldir)/%); then \
# HIDE FROM AUTOMAKE #		$$(call po2xml,$$(@:$$(xmlpodir)/$(1)/%=$$(xmldir)/%),$$<,$(1),$$@); \
# HIDE FROM AUTOMAKE #	else \
# HIDE FROM AUTOMAKE #		touch $$@; \
# HIDE FROM AUTOMAKE #	fi
# HIDE FROM AUTOMAKE ## This is indirectly used as HTML prerequisite:
# HIDE FROM AUTOMAKE #$$(xmlpodir)/$(1): $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #	$$(cmd) touch $$(xmlpodir)/$(1)
# HIDE FROM AUTOMAKE ## Debugging
# HIDE FROM AUTOMAKE #list-xmlfiles-$(1) list-xml-files-$(1) list-xml-$(1):
# HIDE FROM AUTOMAKE #	@echo $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE ## Targets suitable for command line
# HIDE FROM AUTOMAKE #xml-$(1): $$($(1)_XML_FILES)
# HIDE FROM AUTOMAKE #endef

$(foreach LANG,$(PO_LANGS),$(eval $(call MAKE_XML_RULES,$(LANG))))

# Special case: en
# HIDE FROM AUTOMAKE #en_XML_FILES = $(XML_FILES:$(xmldir)/%=$(xmlpodir)/en/%)
# TODO: check this
$(en_XML_FILES): $(xmlpodir)/en ;

# TODO: make relative link rather than absolute link(?)
$(xmlpodir)/en: $(XML_FILES)
	$(cmd) src_dir=$$(cd $(srcdir)/$(xmldir) && pwd); \
	poxml_dir=$(xmlpodir); \
	test -d $${poxml_dir} || $(mkdir_p) $${poxml_dir}; \
	test -d $${poxml_dir}/en || $(LN_S) $(abs_builddir)/$${src_dir} $${poxml_dir}/en; \
	touch $@

# Special case: en
xml-en: $(xmlpodir)/en ;


########################################################################
####            XML validation                                      ####
########################################################################

validate: validate-en ;
validate-%: xmllint-% ;
xmllint: xmllint-en ;

xmllint-%: $(logdir)/%-xmllint.log ;
	@echo >&2 "Validating '$*' not implemented."

xmllint-en: $(logdir)/en-xmllint.log ;
	$(cmd) test -s $< && cat $< || echo "No errors."

$(logdir)/en-xmllint.log: $(logdir) $(XML_FILES)
	$(cmd) if type $(XMLLINT) >/dev/null 2>&1; then \
		echo "*** Validating XML for 'en' ... "; \
		$(XMLLINT) $(XMLLINTFLAGS) --xinclude $(xmlpodir)/en/gimp.xml \
		| sed -e 's,xmlns:xi="http://www.w3.org/2001/XInclude",,' \
		| $(XMLLINT) $(XMLLINTFLAGS) --nonet --valid --noout - 2>$@ \
		|| true; \
	else \
		echo "*** Validating 'en' skipped: 'xmllint' not found."; \
	fi

$(logdir):
	$(cmd) mkdir $@ && test -w $@


########################################################################
####            Make HTML files:  XML --> HTML                      ####
########################################################################

# Note that Automake already defines an "html" target
html-local: $(foreach lang,$(ALL_LINGUAS),html-$(lang)) ;

# html-% -> index-% -> html/%/gimp-help.xml -> html/%/gimp-xrefs.xml -> html/%/index.html
html-%: index-% ;

$(htmldir)/%/index.html: $(xmlpodir)/% $(HTML_STYLESHEETS)
	$(msg) "*** Making html for $* ... "
	$(cmd) rm -rf $(htmldir)/$*
	$(cmd) $(mkdir_p) $(htmldir)/$*
	$(cmd) test -h $(htmldir)/images || $(LN_S) ../images $(htmldir)/

	$(cmd) test "$*" = "no" && lang="nb" || lang="$*"; \
	$(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  --xinclude \
	  --stringparam l10n.gentext.default.language $${lang} \
	  -o html/$*/ \
	  stylesheets/plainhtml.xsl \
	  $(xmlpodir)/$*/gimp.xml

	$(cmd) for file in $(srcdir)/stylesheets/*.css; do \
		if [ -f $$file ]; then cp -fp $$file $(htmldir)/$*; fi; \
	done

	$(cmd) for file in $(srcdir)/stylesheets/$*/*.css; do \
		if [ -f $$file ]; then cp -fp $$file $(htmldir)/$*; fi; \
	done

# The xrefs file is a side effect of the HTML build
$(htmldir)/%/gimp-xrefs.xml: $(htmldir)/%/index.html
	$(cmd) touch $@

####  Context Help  ####
index: $(foreach lang,$(LANGUAGES),index-$(lang)) ;
index-%: $(htmldir)/%/gimp-help.xml ;

$(htmldir)/%/gimp-help.xml: $(htmldir)/%/gimp-xrefs.xml stylesheets/makeindex.xsl
	$(cmd) $(XSLTPROC) \
	  $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
	  $(srcdir)/stylesheets/makeindex.xsl \
	  $< \
	  > $@

.PRECIOUS: \
	$(htmldir)/%/index.html \
	$(htmldir)/%/gimp-help.xml \
	$(htmldir)/%/gimp-xrefs.xml


########################################################################
####            Make PDF files:  XML --> PDF                        ####
########################################################################
if HAVE_DBLATEX

## Note that Automake already defines a "pdf" target
pdf-local: $(foreach lang,$(ALL_LINGUAS),pdf-$(lang)) ;
pdf-%: $(pdfdir)/%.pdf ;

$(pdfdir)/%.pdf: $(xmlpodir)/%/gimp.xml stylesheets/plainprint.xsl
	test -d $(pdfdir) || $(mkdir_p) $(pdfdir)
	$(DBLATEX) $(DBLATEXFLAGS) \
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

odf: $(foreach lang,$(ALL_LINGUAS),odf-$(lang)) ;
odf-%: $(odfdir)/%.odt ;

$(odfdir)/%.odt: $(xmlpodir)/%/gimp-alldocs.xml
	$(cmd) test -d $(odfdir) || $(mkdir_p) $(odfdir)
	$(cmd) $(mkdir_p) odf
	$(cmd) $(DOCBOOK2ODF) $(DOCBOOK2ODFFLAGS) \
	    --debug -v \
	    --output-dir=`pwd` \
	    --output-file=$@ \
	    $< 

if HAVE_XMLLINT
$(xmlpodir)/%/gimp-alldocs.xml: $(xmlpodir)/%/gimp.xml
	$(XMLLINT) $(XMLLINTFLAGS) --xinclude --output $@ $<
else
$(xmlpodir)/%/gimp-alldocs.xml: $(xmlpodir)/%/gimp.xml
	@echo "*** WARNING: Cannot resolve xincludes ***"; \
	echo  "*** because xmllint(1) was not found. ***"; \
	cp -v $< $@
endif

else

odf odf-%:
	@echo "*** Cannot build ODFs because docbook2odf(1) was not found ***"
	@exit 69

endif


## TODO OR NOT TODO ## #### HTML preview

## TODO OR NOT TODO ## preview: html index
## TODO OR NOT TODO ## 	rm -rf preview
## TODO OR NOT TODO ## 	$(mkdir_p) preview
## TODO OR NOT TODO ## 	cd preview && $(LN_S) ../html/* .
## TODO OR NOT TODO ## 	cd preview && $(LN_S) $(abs_top_srcdir)/images .

## TODO OR NOT TODO ## preview-%: html/%/index.html html/%/gimp-help.xml
## TODO OR NOT TODO ## 	rm -rf preview-$*
## TODO OR NOT TODO ## 	$(mkdir_p) preview-$*
## TODO OR NOT TODO ## 	cd preview-$* && $(LN_S) ../html/$* .
## TODO OR NOT TODO ## 	cd preview-$* && $(LN_S) $(abs_top_srcdir)/images .

########################################################################
####            HTML draft (single page preview)                    ####
########################################################################

%.draft: %.xml stylesheets/drafthtml.xsl
	@echo "Making draft page(s), ignore any XSLT complaints:"
	$(cmd) id=`sed -e 's/.*id=.//; tmatch; d; :match; s/["'"'"'].*//; q' $<`; \
	test -n "$$id" || id=noname; \
	langs="$(shell echo $@ | \
	               sed -e 's,^$(xmldir)/.*,$(LANGUAGES),; t' \
	                   -e 's,^$(xmlpodir)/\([^/]\+\)/.*,\1,')"; \
	for lang in $${langs}; do \
		destdir=$(htmldir)/$${lang}; \
		test -d $${destdir} && continue || \
		$(mkdir_p) $${destdir}; \
		cp -fp $(srcdir)/stylesheets/*.css \
		       $(srcdir)/stylesheets/$$lang/*.css \
		    $${destdir} 2>/dev/null; \
	done; \
	\
	for lang in $${langs}; do \
		destdir=$(htmldir)/$${lang}; \
		echo "Making $${destdir}/$${id}-draft.html ... "; \
		xmlfile="$<"; xmlfile=$${xmlfile#*/}; \
		xmlfile=$(xmlpodir)/$${lang}/$${xmlfile#$${lang}/}; \
		if [ "$${lang}" = "no" ]; then lang="nb"; fi; \
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
####        Language-specific HTML tarballs for distribution        ####
########################################################################

# HIDE FROM AUTOMAKE #tarball_prefix := gimp-help-2-html

.SECONDARY: $(tarball_prefix)-%.tar
$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml
	$(cmd) rm -rf $(tarball_prefix)-$*
	$(cmd) $(mkdir_p) $(tarball_prefix)-$*
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
	$(foreach lang,$(ALL_LINGUAS), \
		$(tarball_prefix)-$(lang).tar.gz \
		$(tarball_prefix)-$(lang).tar.bz2 \
		$(tarball_prefix)-$(lang).zip \
	)

## TODO ## #### XML validation

if HAVE_XMLLINT

## TODO ## xml/stamp-%-valid: xml/%.xml
## TODO ## 	@echo "Validating XML for:" $*
## TODO ## 	@$(XMLLINT) --noout --valid $< > /dev/null
## TODO ## 	@touch $@
## TODO ## 
## TODO ## validate: $(foreach lang,$(ALL_LINGUAS),xml/stamp-$(lang)-valid)

else

## TODO ## validate:
## TODO ## 	@echo "*** Cannot validate XML because xmllint(1) was not found ***"

endif

## TODO ## #### Miscellaneous checks

## TODO ## .PHONY: checks check-lang-attributes check-svn-property check-image-references

## TODO ## # Note that the default (autoconf) target name is "check".
## TODO ## checks: check-svn-property check-image-references

## TODO ## check-svn-property:
## TODO ## 	@if cd $(srcdir) && test -e tools/check_keywords_property.pl && \
## TODO ## 	type perl >/dev/null 2>&1; then \
## TODO ## 	    echo "*** Checking svn property ... "; \
## TODO ## 	    perl tools/check_keywords_property.pl -v || true; \
## TODO ## 	else \
## TODO ## 	    echo >&2 "*** Cannot check svn property (no Perl installed?) ***"; \
## TODO ## 	fi

## TODO ## check-image-references:
## TODO ## 	@if cd $(srcdir) && test -e tools/validate_references.py && \
## TODO ## 	type python >/dev/null 2>&1; then \
## TODO ## 	    echo "*** Checking image references ... "; \
## TODO ## 	    python tools/validate_references.py --verbose --broken --orphaned || true; \
## TODO ## 	else \
## TODO ## 	    echo >&2 "*** Cannot check image references (no Python installed?) ***"; \
## TODO ## 	fi

## TODO ## #### Installation
## TODO ## 
## TODO ## install-data-local:
## TODO ## 	$(mkdir_p) $(DESTDIR)$(helpdir)
## TODO ## 
## TODO ## 	@$(echo_n) "** Installing HTML:"
## TODO ## 	@cd html && \
## TODO ## 	for lang in $(ALL_LINGUAS); do \
## TODO ## 		$(mkdir_p) $(DESTDIR)$(helpdir)/$$lang && $(echo_n) " $$lang"; \
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
## TODO ## 		$(mkdir_p) $(DESTDIR)$(helpdir)/$${file%/*}; \
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
	rm -rf html
	rm -rf odf
	rm -rf pdf
	rm -rf preview
	rm -rf preview-*
	rm -rf xml
	rm -rf $(tarball_prefix)-*
	rm -rf po
	rm -rf pot


maintainer-clean-local:
	rm -rf html

# GNU Make, please don't delete these targets when a target that depends
# on them fails, 'kay?
#
.PRECIOUS: \
	xml/%/gimp.xml \
	pdf/%/gimp.pdf \
	odf/%/gimp.odf \
	html/%/gimp-xrefs.xml \
	html/%/gimp-help.xml \
	html/%/index.html

.DELETE_ON_ERROR:

## EOF
