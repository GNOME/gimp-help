SUBDIRS = \
	help 

all:	html

html:
	cd help/C && make 

clean:
	rm -rf `find -name "*~" -or -name "*.orig"`
	rm -rf config.log config.cache 
