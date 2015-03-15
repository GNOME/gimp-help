## Process this file with automake to produce Makefile.in

ALL_LINGUAS ?= de el en es fr it ja ko nl nn ru sl sv zh_CN
QUICKREFERENCE_ALL_LINGUAS ?= ca de el en fi fr it ja ko pl ru sv zh_CN
QUICKREFERENCE_LINGUAS = $(filter $(ALL_LINGUAS), $(QUICKREFERENCE_ALL_LINGUAS))

POT_FILES = po/gimp-keys.pot

PO_FILES = $(foreach lang,$(filter-out en,$(QUICKREFERENCE_ALL_LINGUAS)),po/$(lang).po)

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

po/gimp-keys.pot: gimp-keys.xml
	@echo Making $@; \
	$(XML2PO) $(XML2POFLAGS) $< | $(MSGUNIQ) --width=$(MSGWIDTH) - > $@

po/%.po: po/gimp-keys.pot
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

xml/gimp-keys-%.xml: po/%.po gimp-keys.xml
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

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	$(MKDIR_P) docbook
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-docbook.xsl \
	  $< \
	  > $@

docbook: $(foreach lang,$(QUICKREFERENCE_LINGUAS),docbook/gimp-keys-$(lang).xml)

all-local: svg docbook

clean-local:
	rm -rf docbook
	rm -rf svg
	rm -rf xml
	rm -f .xml2po.mo

.DELETE_ON_ERROR:

## EOF
