## Process this file with automake to produce Makefile.in

PO_FILES = \
	$(wildcard $(top_srcdir)/quickreference/po/*.po)

XML_FILES = $(wildcard xml/*.xml)

STAMP_DIR = stamps

EXTRA_DIST = \
	gimp-keys.xml

XSL_FILES = \
        $(top_srcdir)/stylesheets/keys-svg.xsl	\
        $(top_srcdir)/stylesheets/keys-docbook.xsl

FORMATS = xml svg docbook

$(STAMP_DIR)/clean.stamp: Makefile
	@echo '*** Creating fresh stamps directory ***'
	@rm -rf $(STAMP_DIR); $(mkinstalldirs) $(STAMP_DIR)
	@rm -rf $(FORMATS)

	@touch $@

clean: $(STAMP_DIR)/clean.stamp


$(STAMP_DIR)/mkdirs.stamp: Makefile
	@echo '*** Creating directories ***'
	$(mkinstalldirs) $(STAMP_DIR)
	@for format in $(FORMATS); do \
	 $(mkinstalldirs) $$format; \
	done;

	@touch $@

mkdirs: $(STAMP_DIR)/mkdirs.stamp


$(STAMP_DIR)/profile.stamp: mkdirs
	@echo '*** Profiling po files ***'
	for po in $(PO_FILES); do \
	  $(XML2PO) -p $$po gimp-keys.xml > xml/gimp-keys-`basename $$po | sed s/\.po$$//`.xml; \
	done;

	@touch $@

profile: $(STAMP_DIR)/profile.stamp


$(STAMP_DIR)/svg.stamp: profile
	echo '*** Creating quickreference SVGs ***'; \
	for xml in $(XML_FILES); do \
	  $(XSLTPROC) stylesheets/keys-svg.xsl $$xml > svg/`basename $$xml | sed s/\.xml/\.svg/`; \
	done;

	@touch $@

svg: $(STAMP_DIR)/svg.stamp

$(STAMP_DIR)/docbook.stamp: profile
	echo '*** Creating quickreference as DocBook/XML ***'; \
	for xml in $(XML_FILES); do \
	  $(XSLTPROC) stylesheets/keys-docbook.xsl $$xml > docbook/`basename $$xml`;\
	 done;

	@touch $@

docbook: $(STAMP_DIR)/docbook.stamp
