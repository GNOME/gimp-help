# Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2008, 2009,
# 2011 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PATH_PYTHON3([MINIMUM-VERSION], [MODULE], [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
# ---------------------------------------------------------------------------
# Adds support for distributing Python modules and packages.  To
# install modules, copy them to $(pythondir), using the python_PYTHON
# automake variable.  To install a package with the same name as the
# automake package, install to $(pkgpythondir), or use the
# pkgpython_PYTHON automake variable.
#
# The variables $(pyexecdir) and $(pkgpyexecdir) are provided as
# locations to install python extension modules (shared libraries).
# Another macro is required to find the appropriate flags to compile
# extension modules.
#
# If your package is configured with a different prefix to python,
# users will have to add the install directory to the PYTHONPATH
# environment variable, or create a .pth file (see the python
# documentation for details).
#
# If the MINIMUM-VERSION argument is passed, AM_PATH_PYTHON3 will
# cause an error if the version of python installed on the system
# doesn't meet the requirement.  MINIMUM-VERSION should consist of
# numbers and dots only.
#
# If the MODULE argument is passed, AM_PATH_PYTHON3 will cause an error
# if none of the python satisfying the MINIMUM-VERSION requirement can
# import MODULE.
#
# AM_PATH_PYTHON3 is based on AM_PATH_PYTHON but will search only
# Python 3 locations.
AC_DEFUN([AM_PATH_PYTHON3],
 [
  dnl Find a Python3 interpreter.
  m4_define_default([_AM_PYTHON_INTERPRETER_LIST],
[python3 python python3.13 python3.12 python3.11 python3.10 python3.9 python3.8 python3.7 python3.6])

  AC_ARG_VAR([PYTHON], [the Python interpreter])

  m4_if([$1],[],[
    dnl We still require a version check for Python >= 3.0.
    am_display_PYTHON_MINIMUM=3.0.0
  ], [
    am_display_PYTHON_MINIMUM=$1
  ])

  if test -n "$PYTHON"; then
    # If the user set $PYTHON, use it and don't search something else.
    AC_CACHE_CHECK([$PYTHON (from \$PYTHON env variable) version], [am_cv_python_version],
        [am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version.split()[[0]])"`])
    AC_MSG_CHECKING([whether $PYTHON version >= $am_display_PYTHON_MINIMUM])
    AM_PYTHON3_CHECK_VERSION([$PYTHON], [$am_display_PYTHON_MINIMUM],
        [AC_MSG_RESULT(yes)],
        [AC_MSG_ERROR(too old)])
    m4_if([$2],[],[], [AM_PYTHON_CHECK_MODULE([$PYTHON], [$2],
                            [am_display_PYTHON=$PYTHON],
                            [PYTHON=:])])
  else
    # Otherwise, try each interpreter until we find one that satisfies
    # VERSION.
    AC_MSG_NOTICE([checking for a Python 3 interpreter with version >= $am_display_PYTHON_MINIMUM among: _AM_PYTHON_INTERPRETER_LIST])
    for am_cv_pathless_PYTHON in _AM_PYTHON_INTERPRETER_LIST none; do
      test "$am_cv_pathless_PYTHON" = none && break
      AC_MSG_CHECKING([$am_cv_pathless_PYTHON version])
      am_cv_pathless_PYTHON_version=`$am_cv_pathless_PYTHON -c "import sys; sys.stdout.write(sys.version.split()[[0]])"`
      AC_MSG_RESULT([$am_cv_pathless_PYTHON_version])
      AC_MSG_CHECKING([whether $am_cv_pathless_PYTHON version >= $am_display_PYTHON_MINIMUM])
      AM_PYTHON3_CHECK_VERSION([$am_cv_pathless_PYTHON], [$am_display_PYTHON_MINIMUM],
                               [AC_MSG_RESULT(yes)],
                               [AC_MSG_RESULT(too old)
                                continue])
      m4_if([$2],[], [break],
            [AM_PYTHON_CHECK_MODULE([$am_cv_pathless_PYTHON], [$2], [break])])
    done
    # Set $PYTHON to the absolute path of $am_cv_pathless_PYTHON.
    if test "$am_cv_pathless_PYTHON" = none; then
      PYTHON=:
    else
      AC_PATH_PROG([PYTHON], [$am_cv_pathless_PYTHON])
    fi
    am_display_PYTHON=$am_cv_pathless_PYTHON
  fi

  if test "$PYTHON" = :; then
  dnl Run any user-specified action, or abort.
    m4_default([$4], [AC_MSG_ERROR([no suitable Python interpreter found])])
  else

  dnl Query Python for its version number.  Getting [:3] seems to be
  dnl the best way to do this; it's what "site.py" does in the standard
  dnl library.

  AC_CACHE_CHECK([for $am_display_PYTHON version], [am_cv_python_version],
    [am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version.split()[[0]])"`])
  AC_SUBST([PYTHON_VERSION], [$am_cv_python_version])

  dnl Use the values of $prefix and $exec_prefix for the corresponding
  dnl values of PYTHON_PREFIX and PYTHON_EXEC_PREFIX.  These are made
  dnl distinct variables so they can be overridden if need be.  However,
  dnl general consensus is that you shouldn't need this ability.

  AC_SUBST([PYTHON_PREFIX], ['${prefix}'])
  AC_SUBST([PYTHON_EXEC_PREFIX], ['${exec_prefix}'])

  dnl At times (like when building shared libraries) you may want
  dnl to know which OS platform Python thinks this is.

  AC_CACHE_CHECK([for $am_display_PYTHON platform], [am_cv_python_platform],
    [am_cv_python_platform=`$PYTHON -c "import sys; sys.stdout.write(sys.platform)"`])
  AC_SUBST([PYTHON_PLATFORM], [$am_cv_python_platform])


  dnl Set up 4 directories:

  dnl pythondir -- where to install python scripts.  This is the
  dnl   site-packages directory, not the python standard library
  dnl   directory like in previous automake betas.  This behavior
  dnl   is more consistent with lispdir.m4 for example.
  dnl Query distutils for this directory.
  AC_CACHE_CHECK([for $am_display_PYTHON script directory],
    [am_cv_python_pythondir],
    [if test "x$prefix" = xNONE
     then
       am_py_prefix=$ac_default_prefix
     else
       am_py_prefix=$prefix
     fi
     am_cv_python_pythondir=`$PYTHON -c "import sys; from distutils import sysconfig; sys.stdout.write(sysconfig.get_python_lib(0,0,prefix='$am_py_prefix'))" 2>/dev/null`
     case $am_cv_python_pythondir in
     $am_py_prefix*)
       am__strip_prefix=`echo "$am_py_prefix" | sed 's|.|.|g'`
       am_cv_python_pythondir=`echo "$am_cv_python_pythondir" | sed "s,^$am__strip_prefix,$PYTHON_PREFIX,"`
       ;;
     *)
       case $am_py_prefix in
         /usr|/System*) ;;
         *)
         am_cv_python_pythondir=$PYTHON_PREFIX/lib/python$PYTHON_VERSION/site-packages
         ;;
       esac
       ;;
     esac
    ])
  AC_SUBST([pythondir], [$am_cv_python_pythondir])

  dnl pkgpythondir -- $PACKAGE directory under pythondir.  Was
  dnl   PYTHON_SITE_PACKAGE in previous betas, but this naming is
  dnl   more consistent with the rest of automake.

  AC_SUBST([pkgpythondir], [\${pythondir}/$PACKAGE])

  dnl pyexecdir -- directory for installing python extension modules
  dnl   (shared libraries)
  dnl Query distutils for this directory.
  AC_CACHE_CHECK([for $am_display_PYTHON extension module directory],
    [am_cv_python_pyexecdir],
    [if test "x$exec_prefix" = xNONE
     then
       am_py_exec_prefix=$am_py_prefix
     else
       am_py_exec_prefix=$exec_prefix
     fi
     am_cv_python_pyexecdir=`$PYTHON -c "import sys; from distutils import sysconfig; sys.stdout.write(sysconfig.get_python_lib(1,0,prefix='$am_py_exec_prefix'))" 2>/dev/null`
     case $am_cv_python_pyexecdir in
     $am_py_exec_prefix*)
       am__strip_prefix=`echo "$am_py_exec_prefix" | sed 's|.|.|g'`
       am_cv_python_pyexecdir=`echo "$am_cv_python_pyexecdir" | sed "s,^$am__strip_prefix,$PYTHON_EXEC_PREFIX,"`
       ;;
     *)
       case $am_py_exec_prefix in
         /usr|/System*) ;;
         *)
         am_cv_python_pyexecdir=$PYTHON_EXEC_PREFIX/lib/python$PYTHON_VERSION/site-packages
         ;;
       esac
       ;;
     esac
    ])
  AC_SUBST([pyexecdir], [$am_cv_python_pyexecdir])

  dnl pkgpyexecdir -- $(pyexecdir)/$(PACKAGE)

  AC_SUBST([pkgpyexecdir], [\${pyexecdir}/$PACKAGE])

  dnl Run any user-specified action.
  $3
  fi

])


# AM_PYTHON_CHECK_PYGOBJECT(PROG, VERSION, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ---------------------------------------------------------------------------
# Run ACTION-IF-TRUE if PyGObject is present and at least VERSION.
# Run ACTION-IF-FALSE otherwise.
# This supports any version of Python.
AC_DEFUN([AM_PYTHON_CHECK_PYGOBJECT],
 [prog="import sys, gi
version = '3.0'
if '$2' != '':
  version = '$2'
sys.exit(gi.check_version(version))"
  AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])

# AM_PYTHON_CHECK_MODULE(PROG, MODULE, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ---------------------------------------------------------------------------
# Run ACTION-IF-TRUE if MODULE can be loaded by Python PROG.
# Run ACTION-IF-FALSE otherwise.
# This supports any version of Python.
AC_DEFUN([AM_PYTHON_CHECK_MODULE],
 [prog="import $2"
  AC_MSG_CHECKING(if $1 can import module $2)
  AS_IF([AM_RUN_LOG([$1 -c "$prog"])],
        [AC_MSG_RESULT(yes)
         $3],
        [AC_MSG_RESULT(no)
         $4])])

# AM_PYTHON3_CHECK_VERSION(PROG, VERSION, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
# ---------------------------------------------------------------------------
# Run ACTION-IF-TRUE if the Python interpreter PROG has version >= VERSION
# and version == 3.
# Run ACTION-IF-FALSE otherwise.
# This test uses sys.hexversion instead of the string equivalent (first
# word of sys.version), in order to cope with versions such as 2.2c1.
# This supports Python 3.0 or higher.
#
# Based on AM_PYTHON_CHECK_VERSION but for Python 3 only.
AC_DEFUN([AM_PYTHON3_CHECK_VERSION],
 [prog="import sys
# split strings by '.' and convert to numeric.  Append some zeros
# because we need at least 4 digits for the hex conversion.
# map returns an iterator in Python 3.0 and a list in 2.x
# minver = list(map(int, '$2'.split('.'))) + [[0, 0, 0]]
minver = list(map(int, '$2'.split('.')))
minverhex = 0
# xrange is not present in Python 3.0 and range returns an iterator.
# python2dev had minver[[i]] but that raises
# TypeError: list indices must be integers or slices, not list
# for i in list(range(0, 4)): minverhex = (minverhex << 8) + minver[i]
for v in minver: minverhex = (minverhex << 8) + v
# sys.version_info.major only available since Python 2.7.
# use sys.version_info[0] instead.
# Double the square brackets for M4 syntax.
# sys.exit(sys.version_info[[0]] != 3 or sys.hexversion < minverhex)
sys.exit(sys.version_info[[0]] != 3 or (sys.hexversion >> 8) < minverhex)"
  AS_IF([AM_RUN_LOG([$1 -c "$prog"])], [$3], [$4])])



## Find the install dirs for the python installation.
##  By James Henstridge

dnl a macro to check for ability to create python extensions
dnl  AM_CHECK_PYTHON_HEADERS([ACTION-IF-POSSIBLE], [ACTION-IF-NOT-POSSIBLE])
dnl function also defines PYTHON_INCLUDES
AC_DEFUN([AM_CHECK_PYTHON_HEADERS],
[AC_REQUIRE([AM_PATH_PYTHON3])
AC_MSG_CHECKING(for headers required to compile python extensions)
dnl deduce PYTHON_INCLUDES
py_prefix=`$PYTHON -c "import sys; print(sys.prefix)"`
py_exec_prefix=`$PYTHON -c "import sys; print(sys.exec_prefix)"`
PYTHON_INCLUDES=`$PKG_CONFIG --cflags-only-I python-${PYTHON_VERSION}`
if test "$py_prefix" != "$py_exec_prefix"; then
  py_versiondir="${py_exec_prefix}/include/python${PYTHON_VERSION}"
  dnl Win32 doesn't always have a versioned directory for headers
  if test "$PYTHON_PLATFORM" = "win32"; then
    if test -d "${py_versiondir}" ; then
        py_versiondir=${py_exec_prefix}/include
    fi
  fi
  PYTHON_INCLUDES="$PYTHON_INCLUDES -I${py_versiondir}"
fi
AC_SUBST(PYTHON_INCLUDES)
dnl check if the headers exist:
save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $PYTHON_INCLUDES"
AC_TRY_CPP([#include <Python.h>],dnl
[AC_MSG_RESULT(found)
$1],dnl
[AC_MSG_RESULT(not found)
$2])
CPPFLAGS="$save_CPPFLAGS"
])
