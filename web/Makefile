PROC=$(XSLTPROCPATH)xsltproc
TOOLSPATH=../tools/
PCTPROC=$(TOOLSPATH)translated_percentage.py
STYLEDIR=stylesheets
AUTOLAYOUT=$(STYLEDIR)/autolayout.xsl
STYLEOPT=
HTMLIGNORE= autolayout.xml langstats.xml

all:  langstats.xml dirs built style

include depends.tabular

autolayout.xml: layout.xml langstats.xml
	@echo "-- Creating autolayout file"; \
	$(PROC) --noout -o autolayout.xml $(AUTOLAYOUT) layout.xml
	$(MAKE) depends

clean-langstats:
# Make sure this gets rebuilt because the source po files are not under /web/
# so we can't know when we need to update.
	@echo "-- Deleting langstats.xml";
	@rm -f langstats.xml;

langstats.xml:
	@echo "-- Updating translation percentages"; \
	$(PCTPROC) -v -p ../po -o "langstats.xml"

dirs: autolayout.xml
	@echo "-- Creating directories"; \
	mkdir -p $(BUILD_DIR)/html;
	@if ! test -e $(BUILD_DIR)/html/Layout; then \
	  mkdir $(BUILD_DIR)/html/Layout && cp -r layout/* $(BUILD_DIR)/html/Layout; \
	fi

%.html: autolayout.xml
	@echo "-- Building " $@; \
	$(PROC) $(STYLEDIR)/createHTML.xsl $(filter-out $(HTMLIGNORE), $^) $(TIDY) > $@

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
	rm -f langstats.xml;\

depends: autolayout.xml
	$(PROC) $(STYLEDIR)/makefile-dep.xsl $< > depends.tabular

depends.tabular: layout.xml
	touch $@
	$(MAKE) depends
