## Process this file with automake to produce Makefile.in

ALL_LINGUAS ?= en nl
QUICKREFERENCE_ALL_LINGUAS ?= en nl
QUICKREFERENCE_LINGUAS = $(filter $(ALL_LINGUAS), $(QUICKREFERENCE_ALL_LINGUAS))

POT_FILES = $(srcdir)/po/gimp-keys.pot

PO_FILES = $(foreach lang,$(filter-out en,$(QUICKREFERENCE_ALL_LINGUAS)),$(srcdir)/po/$(lang).po)

XSL_FILES = \
	stylesheets/keys-svg.xsl	\
	stylesheets/keys-docbook.xsl

TEMPLATES = \
	templates/svg_template.xml \
	templates/wilber.svg


EXTRA_DIST = \
	gimp-keys.xml \
	$(POT_FILES) \
	$(PO_FILES) \
	$(XSL_FILES) \
	$(TEMPLATES)

COMPENDIUM = Compendium.po

$(srcdir)/po/gimp-keys.pot: $(srcdir)/gimp-keys.xml
	@echo Making $@; \
	$(XML2PO) $(XML2POFLAGS) $< | $(MSGUNIQ) --width=$(MSGWIDTH) - > $@

po/%.po: $(srcdir)/po/gimp-keys.pot
	@echo Making $@; \
	if [ -f $(top_srcdir)/po/$*/$(COMPENDIUM) ]; then \
		with_compendium="--compendium=$(top_srcdir)/po/$*/$(COMPENDIUM)"; \
	fi; \
	if [ ! -s $@ ]; then \
		$(MSGINIT) $(MSGINITFLAGS) --input=$< --locale=$* --output=$@; \
	fi; \
	$(MSGMERGE) $(MSGMERGEFLAGS) $${with_compendium} --update $@ $<; \
	rm -f $@~

.PHONY: pot po-% po
pot: po/gimp-keys.pot ;
po-%: po/%.po ;
po: $(foreach lang,$(filter-out en,$(QUICKREFERENCE_LINGUAS)),po-$(lang)) ;

xml/gimp-keys-%.xml: $(srcdir)/po/%.po gimp-keys.xml
	$(MKDIR_P) xml
	$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

# English is a special case
#
.INTERMEDIATE: xml/gimp-keys-en.xml
xml/gimp-keys-en.xml: gimp-keys.xml
	$(MKDIR_P) xml; \
	cp $< $@

svg/gimp-keys-%.svg: xml/gimp-keys-%.xml stylesheets/keys-svg.xsl
	$(MKDIR_P) svg
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-svg.xsl \
	  $< \
	  > $@

svg: $(foreach lang,$(QUICKREFERENCE_LINGUAS),svg/gimp-keys-$(lang).svg)

if HAVE_DBLATEX

DBLATEXFLAGS="--verbose"

else

pdf/gimp-keys-%.pdf: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	@if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	$(MKDIR_P) pdf
	@echo "*** Making Quickreference PDF ($*) ..."
	$(DBLATEX) \
	    --xsl-user=$(srcdir)/stylesheets/keys-docbook.xsl \
	    --output=$@ $<

pdf: $(foreach lang,$(QUICKREFERENCE_ALL_LINGUAS),pdf/gimp-keys-$(lang).pdf)

install-data-local:
	$(MKDIR_P) $(DESTDIR)$(helpdir) || exit 77
	@echo "*** Installing PDF:"
	cd html && \
	for lang in $(QUICKREFERENCE_LINGUAS); do \
		@echo " $${lang}"; \
		tar -chf- $${lang} | \
		(cd $(DESTDIR)$(helpdir)/ && tar -xf-) || exit 70; \
	done; \
	echo .

endif

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	$(MKDIR_P) docbook
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-docbook.xsl \
	  $< \
	  > $@

docbook: $(foreach lang,$(QUICKREFERENCE_LINGUAS),docbook/gimp-keys-$(lang).xml)

all-local: svg pdf docbook

clean-local:
	rm -rf docbook
	rm -rf svg
	rm -rf pdf
	rm -rf xml
	rm -f .xml2po.mo

.DELETE_ON_ERROR:

## EOF
