SUBDIRS =

XML_FILES =	*.xml */*.xml */*/*.xml
BASE_FILE =	gimp.xml

EXTRA_DIST = \
	$(XML_FILES)

all:  C de

C: $(XML_FILES) ../stylesheets/plainhtml.xsl
	cd ../html && rm -rf C 
	mkdir ../html/C
	cp ../stylesheets/gimp-help-plain.css ../html/C/
	cd ../html/C && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.xsl ../../src/$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl ../html/C/gimp-xrefs-en.xml > ../html/gimp-help.xml

de: $(XML_FILES) ../stylesheets/plainhtml.de.xsl
	cd ../html && rm -rf de
	mkdir ../html/de
	cp ../stylesheets/gimp-help-plain.css ../html/de/
	cd ../html/de && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.de.xsl ../../src/$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl ../html/de/gimp-xrefs-de.xml > ../html/gimp-help.xml

clean: $(XML_FILES) 
	rm -rf C gimp de
	rm -rf `find -name "*.orig"`
	rm -rf `find -name "*~"`
