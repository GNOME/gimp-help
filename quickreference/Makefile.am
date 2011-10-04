## Process this file with automake to produce Makefile.in

ALL_LINGUAS ?= de el en es fr it ja ko nl nn pl ru sl sv zh_CN
QUICKREFERENCE_ALL_LINGUAS ?= de el en fi fr it ja ko ru sl sv zh_CN
QUICKREFERENCE_LINGUAS = $(filter $(ALL_LINGUAS), $(QUICKREFERENCE_ALL_LINGUAS))

PO_FILES = \
	po/gimp-keys.pot\
	po/de.po	\
	po/el.po	\
	po/es.po	\
	po/fi.po	\
	po/fr.po	\
	po/it.po	\
	po/ja.po	\
	po/ko.po	\
	po/nn.po	\
	po/sl.po	\
	po/sv.po	\
	po/ru.po	\
	po/zh_CN.po

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

xml/gimp-keys-%.xml: po/%.po gimp-keys.xml
	$(mkdir_p) xml
	$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

# English is a special case
#
xml/gimp-keys-en.xml: po/gimp-keys.pot gimp-keys.xml
	$(mkdir_p) xml
	$(XML2PO) -p $< $(srcdir)/gimp-keys.xml > $@

svg/gimp-keys-%.svg: xml/gimp-keys-%.xml stylesheets/keys-svg.xsl
	$(mkdir_p) svg
	$(XSLTPROC) \
	  $(srcdir)/stylesheets/keys-svg.xsl \
	  $< \
	  > $@

svg: $(foreach lang,$(QUICKREFERENCE_LINGUAS),svg/gimp-keys-$(lang).svg)

docbook/gimp-keys-%.xml: xml/gimp-keys-%.xml stylesheets/keys-docbook.xsl
	$(mkdir_p) docbook
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
