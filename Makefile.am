## Process this file with automake to produce Makefile.in

IMAGE_DIRS = \
	dialogs		\
	dialogs/examples\
	filters		\
	filters/examples\
	glossary	\
	tool-options	\
	toolbox		\
	callouts	\
	preferences	\
	using

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

CSS_FILES = \
	$(top_srcdir)/stylesheets/gimp-help-plain.css \
	$(top_srcdir)/stylesheets/gimp-help-screen.css

MAKEINDEX = $(top_srcdir)/stylesheets/makeindex.xsl

HELP_STAMPS = \
	clean.stamp	\
	css.stamp	\
	html.stamp	\
	images.stamp	\
	index.stamp	\
	mkdirs.stamp	\
	profile.stamp


EXTRA_DIST = \
	TERMINOLOGY			\
	stylesheets/plainhtml.xsl.in	\
	$(MAKEINDEX)			\
	$(IMAGE_FILES)			\
	$(XML_FILES)			\
	$(CSS_FILES)


clean.stamp:
	@echo '*** Removing the built help files ***'
	rm -rf html
	rm -rf xml
	touch clean.stamp

mkdirs.stamp:
	@echo '*** Creating directories ***'
	for lang in $(ALL_LINGUAS); do \
	  $(mkinstalldirs) html/$$lang; \
	  cp $(CSS_FILES) html/$$lang; \
	done;
	$(mkinstalldirs) xml; \
	$(mkinstalldirs) html/images; \
	touch mkdirs.stamp

css.stamp: mkdirs.stamp $(CSS_FILES)
	@echo '*** Copying stylesheets ***'
	for lang in $(ALL_LINGUAS); do \
	  cp $(CSS_FILES) $(srcdir)/html/$$lang; \
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

profile.stamp: mkdirs.stamp $(XML_FILES)
	@echo '*** Profiling XML files ***'
	cd $(top_srcdir)/xml && \
	for lang in $(ALL_LINGUAS); do \
	  echo '-- Profiling XML for '$$lang;\
	  $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	     --stringparam profile.lang $$lang -o $$lang.xml \
	     $(STYLEBASE)/profiling/profile.xsl \
             ../src/gimp.xml; \
	done;
	touch profile.stamp

html.stamp: profile.stamp $(XML_FILES)
	@echo '*** Building HTML ***'
	for lang in $(ALL_LINGUAS); do \
	  echo '-- Building HTML for '$$lang; \
	  (cd $(top_srcdir)/html/$$lang && \
	    $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	       --stringparam l10n.gentext.default.language $$lang \
	       --stringparam profile.lang $$lang \
	       ../../stylesheets/plainhtml.xsl ../../xml/$$lang.xml); \
	done;
	touch html.stamp

index.stamp: html.stamp
	@echo '*** Generating index files ***';
	for lang in $(ALL_LINGUAS); do \
	  echo '-- Generating index for '$$lang; \
	  $(XSLTPROC) $(XSLTFLAGS) \
	     $(MAKEINDEX) \
	       html/$$lang/gimp-xrefs.xml > html/$$lang/gimp-help.xml; \
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


install-data-local:
	$(mkinstalldirs) $(DESTDIR)$(GIMP_DATADIR)/help
	-cp -r html/* $(DESTDIR)$(GIMP_DATADIR)/help

maintainer-clean-local:
	rm -rf html

## Do not copy the complete html directory to distdir.
## The images don't need to be in the tarball twice, they are copied
## by the images.stamp rule.
dist-hook:
	$(mkinstalldirs) $(distdir)/html
	for lang in $(ALL_LINGUAS); do \
	  cp -r html/$$lang $(distdir)/html; \
	done
