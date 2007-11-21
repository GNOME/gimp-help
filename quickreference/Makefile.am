## Process this file with automake to produce Makefile.in

QUICKREFERENCE_ALL_LINGUAS = de en fr it ru sv es

PO_FILES = \
	po/gimp-keys.pot\
	po/de.po	\
	po/es.po	\
	po/fr.po	\
	po/it.po	\
	po/sv.po	\
	po/ru.po

XSL_FILES = \
	stylesheets/keys-svg.xsl	\
	stylesheets/keys-docbook.xsl

TEMPLATES = \
	templates/svg_template.xml \
	templates/wilber.svg


EXTRA_DIST = \
	gimp-keys.xml \
	$(PO_FILES) \
	$(XSL_FILES) \
	$(TEMPLATES)

if HAVE_XML2PO

xml/gimp-keys-%.xml: po/%.po gimp-keys.xml
	$(mkdir_p) xml
	$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

# English is a special case
#
xml/gimp-keys-en.xml: po/gimp-keys.pot gimp-keys.xml
	$(mkdir_p) xml
	$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

endif

svg/gimp-keys-%.svg: xml/gimp-keys-%.xml stylesheets/keys-svg.xsl
	$(mkdir_p) svg
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-svg.xsl \
	  $< \
	  > $@

svg: $(foreach lang,$(QUICKREFERENCE_ALL_LINGUAS),svg/gimp-keys-$(lang).svg)

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	$(mkdir_p) docbook
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-docbook.xsl \
	  $< \
	  > $@

docbook: $(foreach lang,$(QUICKREFERENCE_ALL_LINGUAS),docbook/gimp-keys-$(lang).xml)

if GIMP_HELP_BUILD
if HAVE_XML2PO
all-local: svg docbook
endif
endif

clean-local:
	rm -rf docbook
	rm -rf svg
	rm -rf xml

.DELETE_ON_ERROR:

## EOF
