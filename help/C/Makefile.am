SUBDIRS =

XML_FILES =	*.xml */*.xml */*/*.xml

BASE_FILE =	gimp.xml

EXTRA_DIST = \
	$(XML_FILES)

all:	plainhtml plainhtml-de

plainhtml: $(XML_FILES) ../stylesheets/plainhtml.xsl
	rm -rf plainhtml
	mkdir plainhtml
	cp ../stylesheets/gimp-help-plain.css plainhtml/
	cd plainhtml && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.xsl ../$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl plainhtml/gimp-xrefs-en.xml >plainhtml/gimp-catalog.xml

plainhtml-de: $(XML_FILES) ../stylesheets/plainhtml.de.xsl
	rm -rf plainhtml-de
	mkdir plainhtml-de
	cp ../stylesheets/gimp-help-plain.css plainhtml-de/
	cd plainhtml-de && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.de.xsl ../$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl plainhtml-de/gimp-xrefs-de.xml >plainhtml-de/gimp-catalog.xml

clean:
	rm -rf plainhtml*
	rm -rf gimp
	rm -rf `find -name "*.orig"`
	rm -rf `find -name "*~"`
	rm -rf `find -name "*.ps"`
	rm -rf `find -name "*.tex"`
	rm -rf `find -name "*.pdf"`
	rm -rf `find -name "*.dvi"`
	rm -rf `find -name "*.aux"`
