SUBDIRS =

XML_FILES =	*.xml */*.xml */*/*.xml
HELP_DIRS = de C images
BASE_FILE =	gimp.xml
INSTCMD = $(INSTALL) -m 644 `find ./ -name '*.*' -type f -maxdepth 1`

EXTRA_DIST = \
	$(XML_FILES)

all:  C de

C: $(XML_FILES) ../stylesheets/plainhtml.xsl
	rm -rf C 
	mkdir C
	cp ../stylesheets/gimp-help-plain.css C/
	cd C && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.xsl ../$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl C/gimp-xrefs-en.xml > gimp-help.xml

de: $(XML_FILES) ../stylesheets/plainhtml.de.xsl
	rm -rf de
	mkdir de
	cp ../stylesheets/gimp-help-plain.css de/
	cd de && $(XSLTPROC) --nonet ../../stylesheets/plainhtml.de.xsl ../$(BASE_FILE)
	$(XSLTPROC) ../stylesheets/makeindex.xsl de/gimp-xrefs-de.xml > gimp-help.xml

clean: rm -rf de
	rm -rf C
	rm -rf gimp
	rm -rf `find -name "*.orig"`
	rm -rf `find -name "*~"`
	rm -rf `find -name "*.ps"`
	rm -rf `find -name "*.tex"`
	rm -rf `find -name "*.pdf"`
	rm -rf `find -name "*.dvi"`
	rm -rf `find -name "*.aux"`

install: $(XML_FILES) 
	$(INSTCMD) ${prefix}
	for dir in `for i in '$(HELP_DIRS)'; \
		do echo $$i; done`; do\
			mkdir ${prefix}/$$dir &&\
			cd $$dir && \
			$(INSTCMD) ${prefix}/$$dir && cd ..;\
	done

uninstall: $(XML_FILES)
	cd ${prefix} && rm -rf $(HELP_DIRS) *.*
