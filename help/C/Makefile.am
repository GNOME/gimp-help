SUBDIRS =

XML_FILES =	*.xml */*.xml */*/*.xml

BASE_FILE =	gimp.xml

EXTRA_DIST = \
	$(XML_FILES)

all:	plainhtml

plainhtml: $(XML_FILES) ../stylesheets/plainhtml.xsl
	rm -rf plainhtml
	mkdir plainhtml
	cp ../stylesheets/gimp-help-plain.css plainhtml/
	cd plainhtml && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.xsl ../$(BASE_FILE)

clean:
	rm -rf plainhtml
	rm -rf gimp
	rm -rf `find -name "*.orig"`
	rm -rf `find -name "*~"`
	rm -rf `find -name "*.ps"`
	rm -rf `find -name "*.tex"`
	rm -rf `find -name "*.pdf"`
	rm -rf `find -name "*.dvi"`
	rm -rf `find -name "*.aux"`
