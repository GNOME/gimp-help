
IMAGES_BASE = $(top_srcdir)/images
IMAGES_DIRS = \
	dialogs		\
	filters		\
	glossary	\
	tool-options	\
	toolbox

HELP_STAMPS = html-build.stamp


all-local: html-build.stamp

html-build.stamp: html index images
	touch html-build.stamp

html:
	@echo '*** Building HTML ***'
	rm -rf $(srcdir)/html 
	mkdir $(srcdir)/html
	for lang in C $(ALL_LINGUAS); do \
	  mkdir $(srcdir)/html/$$lang; \
	  cp $(top_srcdir)/stylesheets/gimp-help-plain.css $(srcdir)/html/$$lang; \
	done;

	@echo '-- Building HTML for C';
	(cd $(srcdir)/html/C && $(XSLTPROC) $(XSLTFLAGS) --xinclude ../../stylesheets/plainhtml.xsl ../../src/gimp.xml)

	for lang in $(ALL_LINGUAS); do \
	  echo '-- Building HTML for '$$lang; \
	  (cd $(srcdir)/html/$$lang && $(XSLTPROC) $(XSLTFLAGS) --xinclude ../../stylesheets/plainhtml.$$lang.xsl ../../src/gimp.xml); \
	done;

index:
	@echo '*** Generating index ***';

	@echo '-- Generating index for C';
	$(XSLTPROC) $(XSLTFLAGS) $(top_srcdir)/stylesheets/makeindex.xsl $(srcdir)/html/C/gimp-xrefs.xml > $(srcdir)/html/gimp-help.xml;

	for lang in $(ALL_LINGUAS); do \
	  echo '-- Generating index for '$$lang; \
	  $(XSLTPROC) $(XSLTFLAGS) $(top_srcdir)/stylesheets/makeindex.xsl $(srcdir)/html/$$lang/gimp-xrefs.xml > $(srcdir)/html/gimp-help.$$lang.xml; \
	done;

images:
	@echo '*** Copying images ***'
	mkdir $(srcdir)/html/images
	for dir in $(IMAGES_DIRS); do \
	  if test -d $(IMAGES_BASE)/$$dir; then \
	    echo '-- Copying images from '$(IMAGES_BASE)/$$dir ; \
	    mkdir $(srcdir)/html/images/$$dir && cp $(IMAGES_BASE)/$$dir/*.png $(srcdir)/html/images/$$dir ; \
	    for lang in $(ALL_LINGUAS); do \
	      if test -d $(IMAGES_BASE)/$$dir/$$lang; then \
	        echo '-- Copying images from '$(IMAGES_BASE)/$$dir/$$lang ; \
	        mkdir $(srcdir)/html/images/$$dir/$$lang && cp $(IMAGES_BASE)/$$dir/$$lang/*.png $(srcdir)/html/images/$$dir/$$lang ; \
	      fi \
	    done; \
	  fi \
	done

clean-local:
	rm -rf $(srcdir)/html $(HELP_STAMPS)


.PHONY: html images
