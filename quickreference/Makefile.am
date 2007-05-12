## Process this file with automake to produce Makefile.in

PO_FILES = \
	$(wildcard $(top_srcdir)/*.po)

STAMP_DIR = stamps

EXTRA_DIST = \
	gimp-keys.xml

XSL_FILES = \
        $(top_srcdir)/stylesheets/keys-svg.xsl	\
        $(top_srcdir)/stylesheets/keys-docbook.xsl

FORMATS = svg docbook

$(STAMP_DIR)/clean.stamp: Makefile
	@echo '*** Creating fresh stamps directory ***'
	@rm -rf $(STAMP_DIR); $(mkinstalldirs) $(STAMP_DIR)
	@rm -rf $(FORMATS)

	@touch $@


$(STAMP_DIR)/mkdirs.stamp: Makefile
	@echo '*** Creating directories ***'
	@for format in $(FORMATS); do \
	 echo $$format &&
	 $(mkinstalldirs) -p $$format; \
	done;

	@touch $@

mkdirs: $(STAMP_DIR)/mkdirs.stamp


$(STAMP_DIR)/profile.stamp: mkdirs.stamp profile.stamp
	@echo '*** Profiling po files ***'
	@for po in $(PO_FILES); do \
	  $(XML2PO) -p $$po $(top_srcdir)/docs/gimp-keys.xml > $(top_srcdir)/xml/gimp-keys-`basename $$po | sed s/\.po$$//`.xml; \
	done;

	@touch $@

profile: $(STAMP_DIR)/profile.stamp


svg: $(STAMP_DIR)/profile.stamp
	echo '*** Creating quickreference SVGs ***'; \
	$(mkinstalldirs) xml && \
	 for po in $(PO_FILES); do \
	   $(XML2PO) -p $$po $(top_srcdir)/docs/gimp-keys.xml > $(top_srcdir)/xml/gimp-keys-`basename $$po | sed s/\.po$$//`.xml; \
	 done;

	@touch $@


clean: $(STAMP_DIR)/clean.stamp

