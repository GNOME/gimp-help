## Process this file with automake to produce Makefile.in

SUBDIRS = quickreference

image_find_predicates = \
	-path '*/.svn' -prune -o \
	\( \
	-name '*.png' -o \
	-name '*.jpg' -o \
	-name '*.mng' -o \
	-name '*.xcf' -o \
	-name '*.gif'    \
	\) -print

IMAGE_FILES := $(sort $(shell cd $(top_srcdir) && find images $(image_find_predicates)))

IMAGE_COUNT := $(words $(IMAGE_FILES))

IMAGE_DIRS := $(sort $(dir $(IMAGE_FILES)))

XML_FILES := $(shell cd $(top_srcdir) && find src -name '*.xml')

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

DISTCHECK_CONFIGURE_FLAGS = --without-gimp

helpdir = $(gimpdatadir)/help

#### XML profiling

xml/%.xml: src/gimp.xml stylesheets/profile.xsl $(filter-out src/gimp.xml, $(XML_FILES))
	@$(mkdir_p) xml

	@echo "Profiling XML for: " $*
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
html/%/index.html: xml/%.xml stylesheets/plainhtml.xsl
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
	@echo "Validating XML for: " $*
	@$(XMLLINT) --noout --valid $< > /dev/null
	@touch $@

validate: $(foreach lang,$(ALL_LINGUAS),xml/stamp-$(lang)-valid)

else

validate:
	@echo "*** Cannot validate XML because xmllint(1) was not found ***"

endif

#### Installation

install-data-local:
	$(mkdir_p) $(DESTDIR)$(helpdir)

	@echo -n "** Installing HTML:"
	@cd html && \
	for lang in $(ALL_LINGUAS); do \
		cp -a $$lang $(DESTDIR)$(helpdir) && echo -n " $$lang"; \
	done
	@echo .

	@echo "** Installing images: (G=gif, J=jpg, M=mng, P=png, X=xcf)"

	@cd $(top_srcdir) && find images $(image_find_predicates) | \
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
all-local: validate html index
endif

dist-hook: dist-copy-images

##  Note that $(IMAGE_FILES) is *huge*, and if we stick it in EXTRA_DIST
##  we get an "Argument list too long" error. So we handle it here.

dist-copy-images:
	test -d "$(distdir)"
	@echo "Copying $(IMAGE_COUNT) images into distdir ..."
	@for dir in $(IMAGE_DIRS); do \
		$(mkdir_p) "$(distdir)/$$dir" || exit; \
	done
	@find images \( $(image_find_predicates) \) \
		-exec cp -fp '{}' gimp-help-2-0.13/'{}' ';'


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
