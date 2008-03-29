## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference

# Options for the "find images" command:
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
		        s/[[:blank:]]/ -o -name /g; \
			s/^/! \\( -name /; \
			s/$$/ \\)/ ' \
	)

html_files_find_predicates = \
	-type f -name '*.*' \
	-print

src_find_predicates =       \
	-name '.svn' -prune \
	-o                  \
	-name '*.xml' -print

XML_FILES := $(shell cd $(top_srcdir) && find src $(src_find_predicates))

COMMON_CSS_FILES = \
	stylesheets/gimp-help-plain.css	\
	stylesheets/gimp-help-screen.css

OTHER_CSS_FILES = \
	stylesheets/plainhtml.xsl.in	\
	stylesheets/htmlalternate.xsl	\
	stylesheets/gimp22.css		\
	stylesheets/zh_CN/gimp-help-custom.css

XSL_FILES = \
	stylesheets/authors_docbook.xsl \
	stylesheets/authors_text.xsl \
	stylesheets/makeindex.xsl \
	stylesheets/plainprint.xsl \
	stylesheets/profile.xsl

EXTRA_DIST = \
	HACKING				\
	INSTALL				\
	TERMINOLOGY			\
	$(COMMON_CSS_FILES)		\
	$(OTHER_CSS_FILES)		\
	$(XML_FILES)			\
	$(XSL_FILES)

AUTHORS_DOCBOOK_XML = src/preface/authors.xml

DISTCHECK_CONFIGURE_FLAGS = --without-gimp

helpdir = $(gimpdatadir)/help

#### XML profiling

# Note that "src/gimp.xml" must be the first prerequisite
# (it doesn't matter that it's listed twice)
xml/%.xml: src/gimp.xml stylesheets/profile.xsl $(XML_FILES)
	@$(mkdir_p) xml

	@echo "Profiling  XML for:" $*
	@$(XSLTPROC) \
	  $(XSLTFLAGS) \
	  --xinclude \
	  --stringparam profile.lang $* \
	  $(top_srcdir)/stylesheets/profile.xsl \
	  $< \
	  > $@.tmp

	@sed -e 's/xmlns[:a-z]*="[^"]*" //' \
	    -e 's/lang="[A-Za-z_;]*"/lang="$*"/' \
	    -e '/^[ \t]*$$/d' \
	  < $@.tmp \
	  > $@

	@rm -f $@.tmp

if HAVE_XMLLINT
	@$(XMLLINT) --noout $@
endif

#### PDF output

if HAVE_DBLATEX

pdf/%.pdf: xml/%.xml stylesheets/plainprint.xsl
	$(mkdir_p) pdf
	dblatex -p $(top_srcdir)/stylesheets/plainprint.xsl $< -o $@

# Note that Automake already defines a "pdf" target
pdf-local: $(foreach lang,$(ALL_LINGUAS),pdf/$(lang).pdf)

else

pdf-local:
	@echo "*** Cannot build PDFs because dblatex(1) was not found ***"
	@false

endif

#### ODF output

if HAVE_DOCBOOK2ODF

odf/%.odt: xml/%.xml
	$(mkdir_p) odf
	$(DOCBOOK2ODF) --debug -v $< --output-dir=`pwd` --output-file=$@

odf: $(foreach lang,$(ALL_LINGUAS),odf/$(lang).odt)

else

odf:
	@echo "*** Cannot build ODFs because docbook2odf(1) was not found ***"
	@false

endif

#### HTML output

if GIMP_HELP_BUILD

# Main text
html/%/index.html: xml/%.xml stylesheets/plainhtml.xsl stylesheets/htmlalternate.xsl
	@rm -rf html/$*
	@$(mkdir_p) html/$*
	@test -d html/images || $(LN_S) $(abs_top_srcdir)/images html/

	@echo "Creating HTML for: " $*
	@$(XSLTPROC) \
	  $(XSLTFLAGS) \
	  --xinclude \
	  --stringparam l10n.gentext.default.language $* \
	  -o html/$*/ \
	  stylesheets/plainhtml.xsl \
	  $<

	@for file in $(top_srcdir)/stylesheets/*.css; do \
		test -f $$file || continue; \
		echo "Adding stylesheet: $$file"; \
		cp -fp $$file html/$*; \
	done

	@for file in $(top_srcdir)/stylesheets/$*/*.css; do \
		test -f $$file || continue; \
		echo "Adding language-specific stylesheet: $$file"; \
		cp -fp $$file html/$*; \
	done

# The xrefs file is a side effect of the HTML build
html/%/gimp-xrefs.xml: html/%/index.html
	@touch $@

# Index
html/%/gimp-help.xml: html/%/gimp-xrefs.xml stylesheets/makeindex.xsl
	$(XSLTPROC) \
	  $(XSLTFLAGS) \
	  $(top_srcdir)/stylesheets/makeindex.xsl \
	  $< \
	  > $@

# Note that Automake already defines an "html" target
html-local: $(foreach lang,$(ALL_LINGUAS),html/$(lang)/index.html)

index: $(foreach lang,$(ALL_LINGUAS),html/$(lang)/gimp-help.xml)

else # GIMP_HELP_BUILD

html-local:
	@echo "*** Cannot build HTML because --disable-build was specified ***"
	@false

index:
	@echo "*** Cannot build indexes because --disable-build was specified ***"
	@false

endif # GIMP_HELP_BUILD

#### HTML preview

preview: html index
	rm -rf preview
	$(mkdir_p) preview
	cd preview && $(LN_S) ../html/* .
	cd preview && $(LN_S) $(abs_top_srcdir)/images .

preview-%: html/%/index.html html/%/gimp-help.xml
	rm -rf preview-$*
	$(mkdir_p) preview-$*
	cd preview-$* && $(LN_S) ../html/$* .
	cd preview-$* && $(LN_S) $(abs_top_srcdir)/images .

#### HTML draft (single page preview)

%.draft: %.xml
	@echo "Making draft page (ignore any XSLT complaints):"
	@for lang in $(ALL_LINGUAS); do \
		test -d $(builddir)/html/$$lang && continue || \
		$(mkdir_p) $(builddir)/html/$$lang; \
		cp -fp $(srcdir)/stylesheets/*.css $(builddir)/html/$$lang; \
		for file in $(srcdir)/stylesheets/$$lang/*.css; do \
			test -f $$file || continue; \
			cp -fp $$file $(builddir)/html/$$lang/; \
		done; \
	done

	@id=`sed -e 's/.*id=.//; tmatch; d; :match; s/["'"'"'].*//; q' $<`; \
	test -n "$$id" || id=noname; \
	for lang in $(ALL_LINGUAS); do \
		echo "Making $(builddir)/html/$$lang/$${id}-draft.html ... "; \
		$(XSLTPROC) \
		    $(XSLTFLAGS) \
		    $(XSLTEXTRAFLAGS) \
		    --xinclude \
		    --stringparam profile.lang $$lang \
		    --novalid \
		    $(srcdir)/stylesheets/profile.xsl \
		    $< \
		| \
		sed -e 's/xmlns[:a-z]*="[^"]*" //' \
		    -e 's/lang="[A-Za-z_;]*"/lang="'$$lang'"/' \
		    -e '/^[ \t]*$$/d' \
		| \
		$(XSLTPROC) \
		    $(XSLTFLAGS) $(XSLTEXTRAFLAGS) \
		    --xinclude \
		    --stringparam l10n.gentext.default.language $* \
		    --novalid \
		    --output $(builddir)/html/$$lang/$${id}-draft.html \
		    $(srcdir)/stylesheets/drafthtml.xsl \
		    - \
		; \
	done && \
	echo "(Remember that links won't work in a draft file.)"

#### Language-specific HTML tarballs for distribution

tarball_prefix := gimp-help-2-html

.SECONDARY: $(tarball_prefix)-%.tar
$(tarball_prefix)-%.tar: html/%/index.html html/%/gimp-help.xml
	rm -rf $(tarball_prefix)-$*
	$(mkdir_p) $(tarball_prefix)-$*
	cd $(tarball_prefix)-$* && $(LN_S) ../html/$* .
	cd $(tarball_prefix)-$* && $(LN_S) $(abs_top_srcdir)/images .
	tar chf $@ --exclude .svn $(tarball_prefix)-$*
	rm -rf $(tarball_prefix)-$*

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

#### XML validation

if HAVE_XMLLINT

xml/stamp-%-valid: xml/%.xml
	@echo "Validating XML for:" $*
	@$(XMLLINT) --noout --valid $< > /dev/null
	@touch $@

validate: $(foreach lang,$(ALL_LINGUAS),xml/stamp-$(lang)-valid)

else

validate:
	@echo "*** Cannot validate XML because xmllint(1) was not found ***"

endif

#### AUTHORS file creation

authors: stylesheets/authors.xml stylesheets/authors_text.xsl
	@echo "Creating AUTHORS"
	$(XSLTPROC) stylesheets/authors_text.xsl stylesheets/authors.xml > AUTHORS
	@echo "Creating src/preface/authors.xml"
	$(XSLTPROC) stylesheets/authors_docbook.xsl stylesheets/authors.xml > $(AUTHORS_DOCBOOK_XML)


#### Installation

install-data-local:
	$(mkdir_p) $(DESTDIR)$(helpdir)

	@echo -n "** Installing HTML:"
	@cd html && \
	for lang in $(ALL_LINGUAS); do \
		$(mkdir_p) $(DESTDIR)$(helpdir)/$$lang && echo -n " $$lang"; \
		find $$lang $(html_files_find_predicates) | \
		while read file; do \
		  $(INSTALL_DATA) $$file $(DESTDIR)$(helpdir)/$$file || exit 66; \
		done \
	done
	@echo .

	@echo "** Installing images: (G=gif, J=jpg, M=mng, P=png, X=xcf)"

	@(cd $(top_srcdir) && find images $(image_find_predicates)) | \
	while read file; do \
		case "$$file" in \
		  *.png) echo -n P ;; \
		  *.jpg) echo -n J ;; \
		  *.xcf) echo -n X ;; \
		  *.mng) echo -n M ;; \
		  *.gif) echo -n G ;; \
		esac; \
		test -d $(DESTDIR)$(helpdir)/$${file%/*} || \
		$(mkdir_p) $(DESTDIR)$(helpdir)/$${file%/*}; \
		$(INSTALL) $(top_srcdir)/$$file $(DESTDIR)$(helpdir)/$$file || exit 66; \
	done
	@echo .

uninstall-local:
	rm -rf $(DESTDIR)$(helpdir)

#### Et cetera

check-local: validate

if GIMP_HELP_BUILD
all-local: validate html-local index
endif

dist-hook: dist-copy-images

##  Note that number of images is *huge*, and if we stick image files in
##  EXTRA_DIST we get an "Argument list too long" error. So we handle it here.

dist-copy-images:
	test -d "$(top_srcdir)/images" && test -d "$(distdir)"
	@echo "Copying images into distdir $(distdir) ..."
	@(cd $(top_srcdir) && tar -cf- --exclude=.svn images) \
	| (cd $(distdir) && tar -xf-)
	test -d "$(distdir)/images" && test ! -d "$(distdir)/images/.svn"


clean-local:
if GIMP_HELP_BUILD
	rm -rf html
endif
	rm -rf odf
	rm -rf pdf
	rm -rf preview
	rm -rf preview-*
	rm -rf xml
	rm -rf $(tarball_prefix)-*

maintainer-clean-local:
	rm -rf html

# GNU Make, please don't delete these targets when a target that depends
# on them fails, 'kay?
#
.PRECIOUS: \
	xml/%.xml \
	pdf/%.pdf \
	odf/%.odf \
	html/%/gimp-xrefs.xml \
	html/%/gimp-help.xml \
	html/%/index.html

.DELETE_ON_ERROR:

## EOF
