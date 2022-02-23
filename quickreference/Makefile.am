## Process this file with automake to produce Makefile.in

QUICKREFERENCE_ALL_LINGUAS ?= ca da de el es en fi fr it ja ko nl nn pl pt_BR ro ru sl sv zh_CN
QUICKREFERENCE_LINGUAS = $(if $(LINGUAS),$(filter $(QUICKREFERENCE_ALL_LINGUAS),$(LINGUAS)),$(QUICKREFERENCE_ALL_LINGUAS))

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
	@$(MKDIR_P) xml
	@$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

# English is a special case
#
.INTERMEDIATE: xml/gimp-keys-en.xml
xml/gimp-keys-en.xml: gimp-keys.xml
	@$(MKDIR_P) xml; \
	cp $< $@

svg/gimp-keys-%.svg: xml/gimp-keys-%.xml stylesheets/keys-svg.xsl
	@$(MKDIR_P) svg
	@echo "*** Making Quickreference SVG ($*) ..."
	@$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-svg.xsl \
	  $< \
	  > $@

svg: $(foreach lang,$(QUICKREFERENCE_LINGUAS),svg/gimp-keys-$(lang).svg)

SVG2PDF = rsvg-convert
SVG2PDF_FLAGS = -a -f Pdf

pdf/gimp-keys-%.pdf: svg/gimp-keys-%.svg
	@$(MKDIR_P) pdf
	@if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	@echo "*** Making Quickreference PDF ($*) ..."
	@$(SVG2PDF) $(SVG2PDF_FLAGS) -o $@ $<

pdf-local: $(foreach lang,$(QUICKREFERENCE_LINGUAS),pdf/gimp-keys-$(lang).pdf)

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	@$(MKDIR_P) docbook
	@echo "*** Making Quickreference docbook ($*) ..."
	@$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-docbook.xsl \
	  $< \
	  > $@

docbook: $(foreach lang,$(QUICKREFERENCE_LINGUAS),docbook/gimp-keys-$(lang).xml)

all-local: svg pdf-local docbook

clean-local:
	@echo "*** Cleaning up ..."
	@rm -rf docbook
	@rm -rf pdf
	@rm -rf svg
	@rm -rf xml
	@rm -f .xml2po.mo

.DELETE_ON_ERROR:

## EOF
