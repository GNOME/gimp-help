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
	using           \
	menus

IMAGE_FILES = \
	$(wildcard $(top_srcdir)/images/*.png)	\
	$(wildcard $(top_srcdir)/images/*/*.png)\
	$(wildcard $(top_srcdir)/images/*/*/*.png)

XML_FILES = \
	$(wildcard $(top_srcdir)/src/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*/*.xml)	\
	$(wildcard $(top_srcdir)/src/*/*/*/*.xml)

DTD_FILES = \
	$(top_srcdir)/src/linkset.dtd

CSS_DIRS = \
	$(top_srcdir)/stylesheets

CSS_FILES = \
        $(top_srcdir)/stylesheets/gimp-help-plain.css \
        $(top_srcdir)/stylesheets/gimp-help-screen.css


MAKEINDEX = $(top_srcdir)/stylesheets/makeindex.xsl

HELP_STAMPS = \
	clean.stamp	\
	css.stamp	\
	latex.stamp	\
	pdf.stamp	\
	html.stamp	\
	images.stamp	\
	index.stamp	\
	mkdirs.stamp	\
	profile.stamp	\
	validate.stamp

FORMATS = html pdf

EXTRA_DIST = \
	TERMINOLOGY			\
	stylesheets/plainhtml.xsl.in	\
	$(MAKEINDEX)			\
	$(IMAGE_FILES)			\
	$(DTD_FILES)			\
	$(XML_FILES)			\
	$(CSS_FILES)


clean.stamp:
	@echo '*** Removing the built help files ***'
	rm -rf html
	rm -rf pdf 
	rm -rf xml
	@echo '*** Removing temporary files ***'
	rm -rf `find . -name "*~"`
	rm -rf `find . -name "*.orig"`
	rm -rf `find . -name "*.bak"`
	rm -rf `find . -name "*.rej"`
	touch clean.stamp

mkdirs.stamp:
	@echo '*** Creating directories ***'
	@for format in $(FORMATS); do \
	  for lang in $(ALL_LINGUAS); do \
	    $(mkinstalldirs) $$format/$$lang; \
	  done; \
	done; \
	$(mkinstalldirs) xml
	touch mkdirs.stamp

css.stamp: mkdirs.stamp $(CSS_FILES)
	@echo '*** Copying stylesheets ***'
	@for lang in $(ALL_LINGUAS); do \
	  cp $(CSS_FILES) $(srcdir)/html/$$lang; \
	  if test $$lang = "zh_CN"; then \
	    cp $(CSS_DIRS)/$$lang/gimp-help-custom.css $(srcdir)/html/$$lang; \
          fi; \
	done;
	touch css.stamp

images.stamp: mkdirs.stamp $(IMAGE_FILES)
	@echo '*** Copying images ***'
	@for format in $(FORMATS); do \
	  $(mkinstalldirs) $$format/images; \
	  cp $(top_srcdir)/images/*.png $$format/images; \
	  for dir in $(IMAGE_DIRS); do \
	    if test -d $(top_srcdir)/images/$$dir; then \
	      $(mkinstalldirs) $$format/images/$$dir; \
	      cp $(top_srcdir)/images/$$dir/*.png $$format/images/$$dir && \
	      for lang in $(ALL_LINGUAS); do \
	        if test -d $(top_srcdir)/images/$$dir/$$lang; then \
	          $(mkinstalldirs) $$format/images/$$dir/$$lang && \
	          cp $(top_srcdir)/images/$$dir/$$lang/*.png $$format/images/$$dir/$$lang; \
	        fi \
	      done; \
	    fi \
	  done; \
	done
	touch images.stamp

convert.stamp: mkdirs.stamp images.stamp $(IMAGE_FILES)
	@echo '*** Converting Images to 8bit depth ***'
	cd $(top_srcdir)/html/images/; \
	for i in `find ./ -name '*.png' -type f`; do \
	  echo "Converting" $$i && \
	  $(CONVERT) $$i $$i; \
	done; \
	touch convert.stamp

profile.stamp: images.stamp $(XML_FILES) $(DTD_FILES)
	@echo '*** Profiling XML files ***'
	@cd $(top_srcdir) && \
	$(mkinstalldirs) xml && cd xml && \
	for lang in $(ALL_LINGUAS); do \
	  echo '-- Profiling XML for '$$lang;\
	  $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	     --stringparam profile.lang $$lang \
	     ../stylesheets/profile.xsl \
             ../src/gimp.xml | \
	     sed -e "s/xmlns[:a-z]*\=\"[^\"]*\" //" | \
	     sed -e "s/lang=[\"'][A-Za-z_;]*[\"']/lang=\"$$lang\"/" >$$lang.xml; \
	done;
	touch profile.stamp

latex.stamp: profile.stamp $(XML_FILES) $(DTD_FILES)
	@echo '*** Building LaTeX files ***'
	@for lang in $(ALL_LINGUAS); do \
	  echo '-- Building LaTeX for '$$lang; \
	  if test $$lang = "zh_CN"; then \
	    stylesheet=$$lang/plainprint.xsl; \stylesheet=plainprint.xsl; \
	  else \
	    stylesheet=plainprint.xsl; \
	  fi; \
	  (cd $(top_srcdir)/pdf/$$lang && \
	    $(XSLTPROC) $(XSLTFLAGS) --noout -o $$lang.tex --xinclude \
		--stringparam l10n.gentext.default.language $$lang \
		--stringparam profile.lang $$lang \
		../../stylesheets/$$stylesheet ../../xml/$$lang.xml); \
	done;
	touch latex.stamp

pdf.stamp: latex.stamp $(XML_FILES) $(DTD_FILES)
	@echo '*** Building PDF files ***'
	@cd $(top_srcdir)/pdf;
	@for lang in $(ALL_LINGUAS); do \
	  echo '-- Building PDF for '$$lang; \
	  (cd $(top_srcdir)/pdf/$$lang && \
	    pdflatex  $$lang.tex; \
	    makeindex $$lang.idx && \
	    pdflatex $$lang.tex); \
	done;
	touch pdf.stamp

html.stamp: profile.stamp $(XML_FILES) $(DTD_FILES)
	@echo '*** Building HTML ***'
	@for lang in $(ALL_LINGUAS); do \
	  echo '-- Building HTML for '$$lang;\
	  (cd $(top_srcdir)/html/$$lang && \
	    $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	       --stringparam l10n.gentext.default.language $$lang \
	       --stringparam profile.lang $$lang \
	       ../../stylesheets/plainhtml.xsl ../../xml/$$lang.xml); \
	done;
	touch html.stamp

index.stamp: html.stamp
	@echo '*** Generating index files ***';
	@for lang in $(ALL_LINGUAS); do \
	  echo '-- Generating index for '$$lang; \
	  $(XSLTPROC) $(XSLTFLAGS) \
	     $(MAKEINDEX) \
	       html/$$lang/gimp-xrefs.xml > html/$$lang/gimp-help.xml; \
	done;
	touch index.stamp

validate.stamp: profile.stamp $(XML_FILES) $(DTD_FILES)
	@if test "x$(XMLLINT)" != "x"; then \
	  echo '*** Validating profiled XML ***'; \
	  for lang in $(ALL_LINGUAS); do \
	    echo -n '-- Validating XML for '$$lang; \
	    $(XMLLINT) --noout --valid xml/$$lang.xml >/dev/null 2>xml/$$lang-validity-errors.log; \
	    echo -n '	number of errors: '; \
	    grep "validity error" xml/$$lang-validity-errors.log | wc -l; \
	  done; \
	  echo 'Log files of the validation process have been generated in the xml directory.'; \
	  echo 'Please correct any errors before writing new content.'; \
	else \
	  echo '*** xmllint is missing, skipping the validation step ***'; \
	fi
	touch validate.stamp

lint: profile.stamp $(XML_FILES) $(DTD_FILES)
	@if test "x$(XMLLINT)" != "x"; then \
	  echo '*** Checking XML for well-formed-ness ***'; \
	  for xml in $(XML_FILES); do \
	    $(XMLLINT) --noout $$xml || exit; \
	  done \
	fi

if GIMP_HELP_BUILD

dist-check-build:

all-local: clean.stamp css.stamp images.stamp validate.stamp index.stamp

CLEANFILES = $(HELP_STAMPS)

else

dist-check-build:
	@echo "*** --enable-build must be specified in order to make dist"
	@false

all-local: css.stamp images.stamp

endif


MAINTAINERCLEANFILES = $(HELP_STAMPS)


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
