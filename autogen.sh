#!/bin/sh

# This script does all the magic calls to automake/autoconf and
# friends that are needed to configure a cvs checkout.  You need a
# couple of extra tools to run this script successfully.
#
# If you are compiling from a released tarball you don't need these
# tools and you shouldn't use this script.  Just call ./configure
# directly.

PROJECT="gimp-help-2"
TEST_TYPE=-f
FILE=src/gimp.xml

AUTOCONF_REQUIRED_VERSION=2.54
AUTOMAKE_REQUIRED_VERSION=1.6

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.
ORIGDIR=`pwd`
cd $srcdir

check_version ()
{
    if expr $1 \>= $2 > /dev/null; then
	echo "yes (version $1)"
    else
	echo "Too old (found version $1)!"
	DIE=1
    fi
}

echo
echo "I am testing that you have the required versions of autoconf and automake ..."
echo

DIE=0

echo -n "checking for autoconf >= $AUTOCONF_REQUIRED_VERSION ... "
if (autoconf --version) < /dev/null > /dev/null 2>&1; then
    VER=`autoconf --version \
         | grep -iw autoconf | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $AUTOCONF_REQUIRED_VERSION
else
    echo
    echo "  You must have autoconf installed to compile $PROJECT."
    echo "  Download the appropriate package for your distribution,"
    echo "  or get the source tarball at ftp://ftp.gnu.org/pub/gnu/"
    DIE=1;
fi

echo -n "checking for automake >= $AUTOMAKE_REQUIRED_VERSION ... "
if (automake-1.7 --version) < /dev/null > /dev/null 2>&1; then
   AUTOMAKE=automake-1.7
   ACLOCAL=aclocal-1.7
elif (automake-1.8 --version) < /dev/null > /dev/null 2>&1; then
   AUTOMAKE=automake-1.8
   ACLOCAL=aclocal-1.8
elif (automake-1.9 --version) < /dev/null > /dev/null 2>&1; then
   AUTOMAKE=automake-1.9
   ACLOCAL=aclocal-1.9
elif (automake-1.6 --version) < /dev/null > /dev/null 2>&1; then
   AUTOMAKE=automake-1.6
   ACLOCAL=aclocal-1.6
else
    echo
    echo "  You must have automake 1.6 or newer installed to compile $PROJECT."
    echo "  Download the appropriate package for your distribution,"
    echo "  or get the source tarball at ftp://ftp.gnu.org/pub/gnu/automake/"
    DIE=1
fi

if test x$AUTOMAKE != x; then
    VER=`$AUTOMAKE --version \
         | grep automake | sed "s/.* \([0-9.]*\)[-a-z0-9]*$/\1/"`
    check_version $VER $AUTOMAKE_REQUIRED_VERSION
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

$ACLOCAL $ACLOCAL_FLAGS
RC=$?
if test $RC -ne 0; then
   echo "$ACLOCAL gave errors. Please fix the error conditions and try again."
   exit 1
fi

$AUTOMAKE --add-missing || exit 1
autoconf || exit 1

cd $ORIGDIR

if $srcdir/configure --enable-maintainer-mode --enable-build "$@"; then
  echo
  echo "Now type 'make' to compile $PROJECT."
else
  echo
  echo "Configure failed or did not finish!"
  exit 1
fi
