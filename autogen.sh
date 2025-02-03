#!/bin/sh

# This script does all the magic calls to automake/autoconf and
# friends that are needed to configure a cvs checkout.  You need a
# couple of extra tools to run this script successfully.
#
# If you are compiling from a released tarball you don't need these
# tools and you shouldn't use this script.  Just call ./configure
# directly.

PROJECT="gimp-help"
TEST_TYPE=-f
FILE=src/gimp.xml

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.
ORIGDIR=`pwd`
cd $srcdir

DIE=0

echo -n "Looking for latest automake version ... "
required_automake_minor=10
# Highest automake minor version to look for
minor=17
while [ $minor -ge $required_automake_minor ]; do
    ver=1.$minor
    if (automake-$ver --version) < /dev/null > /dev/null 2>&1; then
        AUTOMAKE=automake-$ver
        ACLOCAL=aclocal-$ver
	echo $ver
        break
    fi
    minor=`expr $minor - 1`
done

if [ -z "$AUTOMAKE" ]; then
    echo
    echo "  You must have automake 1.$required_automake_minor or newer" \
            "installed to compile $PROJECT. Highest version of automake " \
            "known by this script is 1.$minor and may need to be adjusted."
    echo "  Download the appropriate package for your distribution,"
    echo "  or get the source tarball at ftp://ftp.gnu.org/pub/gnu/automake/"
    DIE=1
fi

if test "$DIE" -eq 1; then
    echo
    echo "Please install/upgrade the missing tools and call me again."
    echo
    exit 1
fi


test $TEST_TYPE $FILE || {
    echo
    echo "You must run this script in the top-level $PROJECT directory."
    echo
    exit 1
}


if test -z "$NOCONFIGURE"; then
  echo
  echo "I am going to run ./configure with the following arguments:"
  echo
  echo "  --enable-maintainer-mode --enable-build $AUTOGEN_CONFIGURE_ARGS $@"
  echo

  if test -z "$*"; then
      echo "If you wish to pass additional arguments, please specify them "
      echo "on the $0 command line or set the AUTOGEN_CONFIGURE_ARGS "
      echo "environment variable."
      echo
  fi
fi

if test -z "$ACLOCAL_FLAGS"; then
    acdir=`$ACLOCAL --print-ac-dir`
    m4list="pkg.m4"

    for file in $m4list
    do
        if [ ! -f "$acdir/$file" ]; then
            echo
            echo "WARNING: aclocal's directory is $acdir, but..."
            echo "         no file $acdir/$file"
            echo "         You may see fatal macro warnings below."
            echo "         If these files are installed in /some/dir, set the ACLOCAL_FLAGS "
            echo "         environment variable to \"-I /some/dir\", or install"            echo "         $acdir/$file."
            echo
        fi
    done
fi

$ACLOCAL -I m4macros $ACLOCAL_FLAGS
RC=$?
if test $RC -ne 0; then
   echo "$ACLOCAL gave errors. Please fix the error conditions and try again."
   exit 1
fi

$AUTOMAKE --add-missing || exit 1
if [ -e Makefile.in ]; then
    sed -e 's/^# HIDE FROM AUTOMAKE #//' \
        -e '/^all\(-local\)\?:/i\
\
\
'       Makefile.in > Makefile.in.tmp &&
    mv Makefile.in.tmp Makefile.in
else
    echo >&2 "Error: cannot find Makefile.in"
    exit 1
fi
autoconf || exit 1

rm -rf autom4te.cache

cd $ORIGDIR

if test -z "$NOCONFIGURE"; then
  if $srcdir/configure --enable-maintainer-mode "$@"; then
    echo
    echo "Now type 'make' to compile $PROJECT."
  else
    echo
    echo "Configure failed or did not finish!"
    exit 1
  fi
fi
