PROC=/usr/bin/xsltproc --nonet
STYLEDIR=stylesheets
AUTOLAYOUT=$(STYLEDIR)/autolayout.xsl
HTMLSTYLE=$(STYLEDIR)/createHTML.xsl
STYLEOPT=

all:
	make autolayout
	make html
	make style

autolayout: layout.xml
	@echo "-- Creating autolayout file"; \
	$(PROC) --noout -o autolayout.xml $(AUTOLAYOUT) layout.xml 


html: autolayout
	@echo "-- Creating html"; \
	mkdir -p html;
	if ! test -e html/Layout; then \
	  mkdir html/Layout && cp -r layout/* html/Layout; \
	fi
	$(PROC) --noout $(HTMLSTYLE) autolayout.xml

style: autolayout
	@echo "-- Copying stylesheet"; \
	cp style.css html/

clean: Makefile
	@echo "-- Cleaning html and autolayout"
	@rm -rf html; \
	rm -f autolayout.xml;\
	rm -f website.database.xml
