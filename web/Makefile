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
	mkdir -p $(BUILD_DIR)/html;
	@if ! test -e $(BUILD_DIR)/html/Layout; then \
	  mkdir $(BUILD_DIR)/html/Layout && cp -r layout/* $(BUILD_DIR)/html/Layout; \
	fi

%.html: autolayout.xml
	@echo "-- Building " $@; \
	$(PROC) $(STYLEDIR)/createHTML.xsl $(filter-out autolayout.xml, $^) $(TIDY) > $@

built: website
	@echo "-- Copying html to $(BUILD_DIR)/html/"; \
	mv *.html $(BUILD_DIR)/html/

style: website
	@echo "-- Copying stylesheet"; \
	cp style.css $(BUILD_DIR)/html/

clean: Makefile
	@echo "-- Cleaning html and autolayout"
	@rm -rf $(BUILD_DIR)/html; \
	rm -f autolayout.xml;\

depends: autolayout.xml
	$(PROC) $(STYLEDIR)/makefile-dep.xsl $< > depends.tabular

depends.tabular: layout.xml
	touch $@
	$(MAKE) depends
