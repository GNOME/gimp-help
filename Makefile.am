SUBDIRS = \
	help 

html:
	cd help/C && make 

ps:
	cd help/C && make gimp.ps

dvi:
	cd help/C && make gimp.dvi

tex:
	cd help/C && make gimp.tex

pdf:
	cd help/C && make gimp.pdf

rtf:
	cd help/C && make gimp.pdf

clean:
	rm -rf `find -name "*~" -or -name "*.orig"`
	rm -rf config.log config.cache 
