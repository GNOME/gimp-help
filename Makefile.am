SUBDIRS = \
	src	

all:	html

html:
	cd src && make 

clean:
	rm -rf `find -name "*~" -or -name "*.orig"`
	rm -rf config.log config.cache
	cd html && rm -rf de C *.xml
