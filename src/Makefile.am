SUBDIRS =

XML_FILES =	*.xml */*.xml */*/*.xml
BASE_FILE =	gimp.xml

EXTRA_DIST = \
	$(XML_FILES)

all:  C de fr


C: $(XML_FILES) ../stylesheets/plainhtml.xsl
	cd ../html && rm -rf C 
	mkdir ../html/C
	cp ../stylesheets/gimp-help-plain.css ../html/C/
	cd ../html/C && $(XSLTPROC) --xinclude --nonet ../../stylesheets/plainhtml.xsl ../../src/$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl ../html/C/gimp-xrefs-en.xml > ../html/gimp-help.xml

de: $(XML_FILES) ../stylesheets/plainhtml.de.xsl
	cd ../html && rm -rf de
	mkdir ../html/de
	cp ../stylesheets/gimp-help-plain.css ../html/de/
	cd ../html/de && $(XSLTPROC) --xinclude --nonet ../../stylesheets/plainhtml.de.xsl ../../src/$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl ../html/de/gimp-xrefs-de.xml > ../html/gimp-help.xml

fr: $(XML_FILES) ../stylesheets/plainhtml.fr.xsl
	cd ../html && rm -rf fr
	mkdir ../html/fr
	cp ../stylesheets/gimp-help-plain.css ../html/fr/
	cd ../html/fr && $(XSLTPROC) --xinclude --nonet ../../stylesheets/plainhtml.fr.xsl ../../src/$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl ../html/fr/gimp-xrefs-fr.xml > ../html/gimp-help.xml

clean: $(XML_FILES) 
	cd ../html && rm -rf C de fr
	rm -rf `find -name "*.orig"`
	rm -rf `find -name "*~"`
