## Process this file with automake to produce Makefile.in

# Select languages that are both in LINGUAS and ALL_LINGUAS
LANGUAGES = $(if $(LINGUAS),$(filter $(ALL_LINGUAS),$(LINGUAS)),$(ALL_LINGUAS))

POT_FILES = $(srcdir)/po/gimp-keys.pot

PO_FILES = $(foreach lang,$(filter-out en,$(ALL_LINGUAS)),$(srcdir)/po/$(lang).po)

PDF_FILES = $(foreach lang,$(LANGUAGES),gimp-keys-$(lang).pdf)

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

# gimp-help directories
helpdir  = $(gimpdatadir)/help

$(srcdir)/po/gimp-keys.pot: $(srcdir)/gimp-keys.xml
	@echo Making $@; \
	$(XML2PO) $(XML2POFLAGS) $< | $(MSGUNIQ) --width=$(MSGWIDTH) - > $@

$(srcdir)/po/%.po: $(srcdir)/po/gimp-keys.pot
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
pot: $(srcdir)/po/gimp-keys.pot ;
po-%: $(srcdir)/po/%.po ;
po: $(foreach lang,$(filter-out en,$(LANGUAGES)),po-$(lang)) ;

xml/gimp-keys-%.xml: $(srcdir)/po/%.po $(srcdir)/gimp-keys.xml
	@$(MKDIR_P) xml
	@$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

# English is a special case
#
.INTERMEDIATE: xml/gimp-keys-en.xml
xml/gimp-keys-en.xml: $(srcdir)/gimp-keys.xml
	@$(MKDIR_P) xml; \
	cp $< $@

svg/gimp-keys-%.svg: xml/gimp-keys-%.xml stylesheets/keys-svg.xsl
	@$(MKDIR_P) svg
	@echo "*** Making Quickreference SVG ($*) ..."
	@$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-svg.xsl \
	  $< \
	  > $@

svg: $(foreach lang,$(LANGUAGES),svg/gimp-keys-$(lang).svg)

# Quickreference PDF generation

if HAVE_SVG2PDF

pdf/gimp-keys-%.pdf: svg/gimp-keys-%.svg
	@$(MKDIR_P) pdf
	@if test -f pdf/%.pdf; then rm -f pdf/%.pdf; fi
	@echo "*** Making Quickreference PDF ($*) ..."
	@$(SVG2PDF) $(SVG2PDF_FLAGS) -o $@ $<

pdf-local: $(foreach lang,$(LANGUAGES),pdf/gimp-keys-$(lang).pdf)

endif

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	@$(MKDIR_P) docbook
	@echo "*** Making Quickreference docbook ($*) ..."
	@$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-docbook.xsl \
	  $< \
	  > $@

docbook: $(foreach lang,$(LANGUAGES),docbook/gimp-keys-$(lang).xml)

all-local: svg pdf-local docbook

install-data-local:
	@$(MKDIR_P) $(DESTDIR)$(helpdir)/pdf || exit 77
	@echo "*** Installing Quickreference PDF's into: $(DESTDIR)$(helpdir)/pdf"
	@cd pdf; \
	for file in $(PDF_FILES); do \
		cp -f $${file} $(DESTDIR)$(helpdir)/pdf/$* ; \
	done; \
	echo .

uninstall-local:
	@test -d $(DESTDIR)$(helpdir)/pdf || exit 70
	@echo "*** Uninstalling PDF:"
	@for file in $(PDF_FILES); do \
		rm -rf $(DESTDIR)$(helpdir)/pdf/$${file}; \
		echo "Removed $(DESTDIR)$(helpdir)/pdf/$${file}"; \
	done; \
	echo .
	@test -z "$(DESTDIR)${helpdir}" || cd $(DESTDIR)${helpdir} && \
	rmdir pdf \
	&& echo "Removed $(DESTDIR)${helpdir}/pdf"

clean-local:
	@echo "*** Cleaning up ..."
	@rm -rf docbook
	@rm -rf pdf
	@rm -rf svg
	@rm -rf xml
	@rm -f .xml2po.mo

.DELETE_ON_ERROR:

## EOF
