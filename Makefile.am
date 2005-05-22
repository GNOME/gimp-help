## Process this file with automake to produce Makefile.in

STAMP_DIR = stamps

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
        $(top_srcdir)/stylesheets/gimp-help-plain.css	\
        $(top_srcdir)/stylesheets/gimp-help-screen.css	

XSL_FILES = \
        $(top_srcdir)/stylesheets/plainprint.xsl	\
        $(top_srcdir)/stylesheets/profile.xsl

MAKEINDEX = $(top_srcdir)/stylesheets/makeindex.xsl

HELP_STAMPS = \
	$(STAMP_DIR)/css.stamp		\
	$(STAMP_DIR)/latex.stamp	\
	$(STAMP_DIR)/pdf.stamp		\
	$(STAMP_DIR)/html.stamp		\
	$(STAMP_DIR)/images.stamp	\
	$(STAMP_DIR)/index.stamp	\
	$(STAMP_DIR)/mkdirs.stamp	\
	$(STAMP_DIR)/profile.stamp	\
	$(STAMP_DIR)/validate.stamp

FORMATS = html pdf

EXTRA_DIST = \
	HACKING				\
	INSTALL				\
	TERMINOLOGY			\
	stylesheets/plainhtml.xsl.in	\
	$(XSL_FILES)			\
	$(MAKEINDEX)			\
	$(IMAGE_FILES)			\
	$(DTD_FILES)			\
	$(XML_FILES)			\
	$(CSS_FILES)


$(STAMP_DIR)/clean.stamp: Makefile
	@echo '*** Creating fresh stamps directory ***'
	@rm -rf $(STAMP_DIR); $(mkinstalldirs) $(STAMP_DIR)
	@echo '*** Removing the built help files ***'
	rm -rf html
	rm -rf pdf 
	rm -rf xml
	@echo '*** Removing temporary files ***'
	@rm -rf `find . -name "*~"`
	@rm -rf `find . -name "*.orig"`
	@rm -rf `find . -name "*.bak"`
	@rm -rf `find . -name "*.rej"`

	@touch $@


$(STAMP_DIR)/mkdirs.stamp: $(patsubst %,$(STAMP_DIR)/mkdirs.%.stamp,$(ALL_LINGUAS)) 
	@echo '*** Creating directories ***'
	@touch $@

$(patsubst %,$(STAMP_DIR)/mkdirs.%.stamp,$(ALL_LINGUAS)) : $(STAMP_DIR)/mkdirs.%.stamp :
	@$(mkinstalldirs) $(STAMP_DIR)
	@for format in $(FORMATS); do \
	  $(mkinstalldirs) $$format/$*; \
	done;

	@touch $@

mkdirs: $(STAMP_DIR)/mkdirs.stamp


$(STAMP_DIR)/css.stamp : $(patsubst %,$(STAMP_DIR)/css.%.stamp,$(ALL_LINGUAS))
	@echo '*** Copying stylesheets ***'
	@touch $@

$(patsubst %,$(STAMP_DIR)/css.%.stamp,$(ALL_LINGUAS)) : $(STAMP_DIR)/css.%.stamp : $(STAMP_DIR)/mkdirs.%.stamp $(CSS_FILES)
	@cp $(CSS_FILES) $(srcdir)/html/$*; \
	if test $* = "zh_CN"; then \
	  cp $(CSS_DIRS)/$*/gimp-help-custom.css $(srcdir)/html/$*; \
	fi

	@touch $@

css: $(STAMP_DIR)/css.stamp


$(STAMP_DIR)/images.stamp : $(patsubst %,$(STAMP_DIR)/images.%.stamp,$(ALL_LINGUAS))
	@echo '*** Copying images ***'
	@touch $@

$(patsubst %,$(STAMP_DIR)/images.%.stamp,$(ALL_LINGUAS)) : $(STAMP_DIR)/images.%.stamp : $(STAMP_DIR)/mkdirs.%.stamp $(IMAGE_FILES)
	@for format in $(FORMATS); do \
	  $(mkinstalldirs) $$format/images; \
	  cp $(top_srcdir)/images/*.png $$format/images; \
	  for dir in $(IMAGE_DIRS); do \
	    if test -d $(top_srcdir)/images/$$dir; then \
	      $(mkinstalldirs) $$format/images/$$dir; \
	      cp $(top_srcdir)/images/$$dir/*.png $$format/images/$$dir && \
	      if test -d $(top_srcdir)/images/$$dir/$*; then \
		$(mkinstalldirs) $$format/images/$$dir/$* && \
		cp $(top_srcdir)/images/$$dir/$*/*.png $$format/images/$$dir/$*; \
	      fi \
	    fi \
	  done; \
	done

	@touch $@

images: $(STAMP_DIR)/images.stamp


$(STAMP_DIR)/convert.stamp: $(STAMP_DIR)/images.stamp
	@echo '*** Converting Images to 8bit depth ***'
	cd $(top_srcdir)/html/images/; \
	for i in `find ./ -name '*.png' -type f`; do \
	  echo "Converting" $$i && \
	  $(CONVERT) -colors 128 $$i $$i; \
	done

	@touch $@

convert: $(STAMP_DIR)/convert.stamp


$(STAMP_DIR)/profile.stamp: $(patsubst %,$(STAMP_DIR)/profile.%.stamp,$(ALL_LINGUAS))
	@echo '*** Profiling XML files ***'
	@touch $@

$(patsubst %,$(STAMP_DIR)/profile.%.stamp,$(ALL_LINGUAS)): $(STAMP_DIR)/profile.%.stamp : $(STAMP_DIR)/mkdirs.%.stamp $(XML_FILES)
	@cd $(top_srcdir) && \
	$(mkinstalldirs) xml && cd xml && \
	echo '-- Profiling XML for '$*;\
	$(XSLTPROC) $(XSLTFLAGS) --xinclude \
	   --stringparam profile.lang $* \
	   ../stylesheets/profile.xsl \
	   ../src/gimp.xml | \
	   sed -e "s/xmlns[:a-z]*\=\"[^\"]*\" //" | \
	   sed -e "s/lang=[\"'][A-Za-z_;]*[\"']/lang=\"$*\"/" >$*.xml

	@touch $@

profile: $(STAMP_DIR)/profile.stamp 


$(STAMP_DIR)/latex.stamp: $(STAMP_DIR)/profile.stamp
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
	done

	@touch $@

latex: $(STAMP_DIR)/latex.stamp


$(STAMP_DIR)/pdf.stamp: $(STAMP_DIR)/latex.stamp 
	@echo '*** Building PDF files ***'
	@cd $(top_srcdir)/pdf;
	@for lang in $(ALL_LINGUAS); do \
	  echo '-- Building PDF for '$$lang; \
	  (cd $(top_srcdir)/pdf/$$lang && \
	    pdflatex  $$lang.tex; \
	    makeindex $$lang.idx && \
	    pdflatex $$lang.tex); \
	done

	@touch $@

pdf: $(STAMP_DIR)/pdf.stamp


$(STAMP_DIR)/html.stamp: $(patsubst %,$(STAMP_DIR)/html.%.stamp,$(ALL_LINGUAS))
	@echo '*** Building HTML ***'
	@touch $@

$(patsubst %,$(STAMP_DIR)/html.%.stamp,$(ALL_LINGUAS)): $(STAMP_DIR)/html.%.stamp : $(STAMP_DIR)/profile.%.stamp $(STAMP_DIR)/css.%.stamp $(STAMP_DIR)/images.%.stamp $(STAMP_DIR)/convert.stamp
	echo '-- Building HTML for '$*;\
	(cd $(top_srcdir)/html/$* && \
	  $(XSLTPROC) $(XSLTFLAGS) --xinclude \
	     --stringparam l10n.gentext.default.language $* \
	     --stringparam profile.lang $* \
	     ../../stylesheets/plainhtml.xsl ../../xml/$*.xml);

	@touch $@

html: $(STAMP_DIR)/html.stamp 


$(STAMP_DIR)/index.stamp: $(patsubst %,$(STAMP_DIR)/index.%.stamp,$(ALL_LINGUAS))
	@echo '*** Generating index files ***';
	@touch $@

$(patsubst %,$(STAMP_DIR)/index.%.stamp,$(ALL_LINGUAS)): $(STAMP_DIR)/index.%.stamp : $(STAMP_DIR)/html.%.stamp
	echo '-- Generating index for '$*; \
	  $(XSLTPROC) $(XSLTFLAGS) \
	     $(MAKEINDEX) \
	       html/$*/gimp-xrefs.xml > html/$*/gimp-help.xml;

	@touch $@

index: $(STAMP_DIR)/index.stamp 


$(STAMP_DIR)/validate.stamp: $(patsubst %,$(STAMP_DIR)/validate.%.stamp,$(ALL_LINGUAS))
	@if test "x$(XMLLINT)" != "x"; then \
	  echo '*** Validating profiled XML ***'; \
	  echo 'Log files of the validation process have been generated in the xml directory.'; \
	  echo 'Please correct any errors before writing new content.'; \
	else \
	  echo '*** xmllint is missing, skipping the validation step ***'; \
	fi

	@touch $@

$(patsubst %,$(STAMP_DIR)/validate.%.stamp,$(ALL_LINGUAS)): $(STAMP_DIR)/validate.%.stamp : $(STAMP_DIR)/profile.%.stamp
	@echo -n '-- Validating XML for '$*; \
	$(XMLLINT) --noout --valid xml/$*.xml >/dev/null 2>xml/$*-validity-errors.log; \
	echo -n '	number of errors: '; \
	grep "validity error" xml/$*-validity-errors.log | wc -l

	@touch $@

validate: $(STAMP_DIR)/validate.stamp


lint: $(STAMP_DIR)/profile.stamp
	@if test "x$(XMLLINT)" != "x"; then \
	  echo '*** Checking XML for well-formed-ness ***'; \
	  for xml in $(XML_FILES); do \
	    $(XMLLINT) --noout $$xml || exit; \
	  done \
	fi

if GIMP_HELP_BUILD

dist-check-build:

all-local: mkdirs validate images css html index

clean: $(STAMP_DIR)/clean.stamp

CLEANFILES = $(HELP_STAMPS)

else

dist-check-build:
	@echo "*** --enable-build must be specified in order to make dist"
	@false

all-local: mkdirs images css

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
