## Process this file with automake to produce Makefile.in

IMAGE_DIRS = \
	dialogs		\
	filters		\
	glossary	\
	tool-options	\
	toolbox

IMAGE_FILES = \
	$(wildcard $(top_srcdir)/images/*.png)	\
	$(wildcard $(top_srcdir)/images/*/*.png)\
	$(wildcard $(top_srcdir)/images/*/*/*.png)

XML_FILES = \
	$(top_srcdir)/src/linkset.dtd		\
	$(wildcard $(top_srcdir)/src/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*/*/*.xml)

CSS_FILE = $(top_srcdir)/stylesheets/gimp-help-plain.css

MAKEINDEX = $(top_srcdir)/stylesheets/makeindex.xsl

HELP_STAMPS = \
	clean.stamp mkdirs.stamp css.stamp images.stamp html.stamp index.stamp


EXTRA_DIST = \
	TERMINOLOGY			\
	stylesheets/plainhtml.xsl.in	\
	$(MAKEINDEX)			\
	$(IMAGE_FILES)			\
	$(XML_FILES)			\
	$(CSS_FILE)


clean.stamp:
	@echo '*** Removing the built help files ***'
	rm -rf html
	touch clean.stamp

mkdirs.stamp:
	@echo '*** Creating directories ***'
	for lang in C $(ALL_LINGUAS); do \
	  $(mkinstalldirs) html/$$lang; \
	  cp $(CSS_FILE) html/$$lang; \
	done;
	$(mkinstalldirs) html/images; \
	touch mkdirs.stamp

css.stamp: mkdirs.stamp $(CSS_FILE)
	@echo '*** Copying stylesheets ***'
	for lang in C $(ALL_LINGUAS); do \
	  cp $(CSS_FILE) $(srcdir)/html/$$lang; \
	done;
	touch css.stamp

images.stamp: mkdirs.stamp $(IMAGE_FILES)
	@echo '*** Copying images ***'
	cp $(top_srcdir)/images/*.png html/images;
	for dir in $(IMAGE_DIRS); do \
	  if test -d $(top_srcdir)/images/$$dir; then \
	    $(mkinstalldirs) html/images/$$dir && \
	    cp $(top_srcdir)/images/$$dir/*.png html/images/$$dir; \
	    for lang in $(ALL_LINGUAS); do \
	      if test -d $(top_srcdir)/images/$$dir/$$lang; then \
	        $(mkinstalldirs) html/images/$$dir/$$lang && \
	        cp $(top_srcdir)/images/$$dir/$$lang/*.png html/images/$$dir/$$lang; \
	      fi \
	    done; \
	  fi \
	done
	touch images.stamp

html.stamp: mkdirs.stamp $(XML_FILES)
	@echo '*** Building HTML ***'
	@echo '-- Building HTML for C';
	(cd html/C && \
	  $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	     --stringparam l10n.gentext.default.language en \
	     --stringparam profile.lang en \
	     ../../stylesheets/plainhtml.xsl ../../src/gimp.xml)
	for lang in $(ALL_LINGUAS); do \
	  echo '-- Building HTML for '$$lang; \
	  (cd html/$$lang && \
	    $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	       --stringparam l10n.gentext.default.language $$lang \
	       --stringparam profile.lang $$lang \
	       ../../stylesheets/plainhtml.xsl ../../src/gimp.xml); \
	done;
	touch html.stamp

index.stamp: html.stamp
	@echo '*** Generating index files ***';
	@echo '-- Generating index for C';
	$(XSLTPROC) $(XSLTFLAGS) \
	   $(MAKEINDEX) html/C/gimp-xrefs.xml > html/gimp-help.xml;

	for lang in $(ALL_LINGUAS); do \
	  echo '-- Generating index for '$$lang; \
	  $(XSLTPROC) $(XSLTFLAGS) \
	     $(MAKEINDEX) html/$$lang/gimp-xrefs.xml > html/gimp-help.$$lang.xml; \
	done;
	touch index.stamp

if GIMP_HELP_BUILD

dist-check-build:

all-local: clean.stamp css.stamp images.stamp html.stamp index.stamp

CLEANFILES = $(HELP_STAMPS)

else

dist-check-build:
	@echo "*** --enable-build must be specified in order to make dist"
	@false

all-local: css.stamp images.stamp

endif


if GIMP_HELP_INSTALL

install-data-local: html/gimp-help.xml
	$(mkinstalldirs) $(DESTDIR)$(GIMP_DATADIR)/help
	-cp -r html/* $(DESTDIR)$(GIMP_DATADIR)/help

endif


maintainer-clean-local:
	rm -rf html

dist-hook:
	$(mkinstalldirs) $(distdir)/html
	-cp html/*.xml $(distdir)/html
	for lang in C $(ALL_LINGUAS); do \
	  cp -r html/$$lang $(distdir)/html; \
	done

