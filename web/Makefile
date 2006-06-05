PROC=xsltproc
STYLEDIR=stylesheets
AUTOLAYOUT=$(STYLEDIR)/autolayout.xsl
STYLEOPT=

all: autolayout.xml dirs built style

include depends.tabular

autolayout.xml: layout.xml
	@echo "-- Creating autolayout file"; \
	$(PROC) --noout -o autolayout.xml $(AUTOLAYOUT) layout.xml 
	$(MAKE) depends


dirs: autolayout.xml
	@echo "-- Creating directories"; \
	mkdir -p html;
	if ! test -e html/Layout; then \
	  mkdir html/Layout && cp -r layout/* html/Layout; \
	fi

%.html: autolayout.xml
	@echo "-- Building " $@; \
	$(PROC) $(STYLEDIR)/createHTML.xsl $(filter-out autolayout.xml, $^) $(TIDY) > $@
	
built: website
	mv *.html html	

style: website 
	@echo "-- Copying stylesheet"; \
	cp style.css html/

clean: Makefile
	@echo "-- Cleaning html and autolayout"
	@rm -rf html; \
	rm -f autolayout.xml;\

depends: autolayout.xml
	$(PROC) $(STYLEDIR)/makefile-dep.xsl $< > depends.tabular

depends.tabular: layout.xml
	touch $@
	$(MAKE) depends

