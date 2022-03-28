isl_in_files = \
	help.isl.in
isl_files = $(isl_in_files:.isl.in=.isl)

stamp_files = \
	stamp-isl

CLEANFILES = $(isl_files) $(stamp_files)

stamp-isl: help.isl Makefile.am
	@											\
	for lang in $(top_srcdir)/po/*/; do							\
		code=`basename $$lang`;								\
		prefix="\\[$$code\\]";								\
		isl="$(builddir)/help.$$code.isl";						\
		echo "  GEN      $$isl";							\
		echo -ne "\\xEF\\xBB\\xBF" > "$$isl";						\
		sed '/^\w\+'"$$prefix"'=/{s/\(.\)'"$$prefix"'/\1/;n};/^\w.*=/d' $<  >> "$$isl";	\
	done &&											\
	code="en" &&										\
	prefix="" &&										\
	isl="$(builddir)/help.$$code.isl" &&							\
	echo "  GEN      $$isl" &&								\
	echo -ne "\\xEF\\xBB\\xBF" > "$$isl" &&							\
	sed '/^\w\+'"$$prefix"'=/{s/\(.\)'"$$prefix"'/\1/;n};/^\w.*=/d' $<  >> "$$isl" &&	\
	echo timestamp > stamp-isl

# * help.isl.ini is used by intltool-extract to extract the localizable
#   strings. We needed to use the ini syntax for leaving comments to
#   translators (with '#' instead of ';').
# * help.isl.in is in the actual .isl format except for the gettext
#   underscoring.
# * help.isl is in the .isl format but mixing all languages.
help.isl: help.isl.in $(wildcard $(top_srcdir)/po-windows-installer/*.po) Makefile.am
	$(AM_V_GEN) $(INTLTOOL_MERGE) $(top_srcdir)/po-windows-installer $< $(@) -d -u -c $(top_builddir)/po-windows-installer/.intltool-merge-cache

help.isl.in: help.isl.ini Makefile.am
	$(AM_V_GEN) sed 's/^#/;/' $< > $@

all-local: $(stamp_files)

clean-local:
	@						\
	for lang in $(top_srcdir)/po/*/; do							\
		code=`basename $$lang`;					\
		isl="$(builddir)/help.$$code.isl";	\
		echo "  RM       $$isl";		\
		rm -f "$$isl";				\
	done

TESTS_ENVIRONMENT = \
	GIMP_TESTING_ABS_TOP_SRCDIR=@abs_top_srcdir@

TESTS = test-installer-langs.sh
