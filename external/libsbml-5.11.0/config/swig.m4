dnl
dnl Filename    : swig.m4
dnl Description : Autoconf macro to check for SWIG
dnl Author(s)   : Michael Hucka <mhucka@caltech.edu>
dnl Created     : 2004-06-18
dnl 
dnl <!-------------------------------------------------------------------------
dnl This file is part of libSBML.  Please visit http://sbml.org for more
dnl information about SBML, and the latest version of libSBML.
dnl
dnl Copyright (C) 2013-2014 jointly by the following organizations:
dnl     1. California Institute of Technology, Pasadena, CA, USA
dnl     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
dnl     3. University of Heidelberg, Heidelberg, Germany
dnl
dnl Copyright (C) 2009-2013 jointly by the following organizations: 
dnl     1. California Institute of Technology, Pasadena, CA, USA
dnl     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
dnl  
dnl Copyright (C) 2006-2008 by the California Institute of Technology,
dnl     Pasadena, CA, USA 
dnl  
dnl Copyright (C) 2002-2005 jointly by the following organizations: 
dnl     1. California Institute of Technology, Pasadena, CA, USA
dnl     2. Japan Science and Technology Agency, Japan
dnl 
dnl This library is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU Lesser General Public License as published by
dnl the Free Software Foundation.  A copy of the license agreement is provided
dnl in the file named "LICENSE.txt" included with this software distribution
dnl and also available online as http://sbml.org/software/libsbml/license.html
dnl --------------------------------------------------------------------- -->*/

dnl
dnl Supports --with-swig[=PREFIX]
dnl

AC_DEFUN([CONFIG_PROG_SWIG],
[
  AC_SUBST(SWIG_CONFIG_OPT)

  AC_ARG_WITH([swig],
    AS_HELP_STRING([--with-swig@<:@=PREFIX@:>@],
	           [set location of swig @<:@default=autodetect@:>@]),
    [with_swig=$withval],
    [with_swig=no])

  if test "$with_swig" != "no"; then

    if test $with_swig != yes; then
      dnl Users seems to have supplied a prefix directory path.  See if we can
      dnl find swig somewhere in the given tree.

      dnl 1st remove trailing slashes because it can confuse tests below.

      with_swig=`echo $with_swig | sed -e 's,\(.*\)/$,\1,g'`

      AC_PATH_PROG([SWIG], [swig], [no], [$with_swig/bin])
      AC_SUBST(SWIG_CONFIG_OPT,[=$with_swig])
    else
      dnl Given --with-swig without an argument.
      dnl No prefix directory path supplied for --with-swig.  Use defaults.

      AC_PATH_PROG([SWIG], [swig], [no])
    fi

    dnl Did we actually find a copy of swig where indicated?

    if test "$SWIG" = "no"; then
      AC_MSG_ERROR([
***************************************************************************
SWIG has been requested via --with-swig, or else is required to update a
language binding dependency, but the program 'swig' cannot be found on this
system.  Please install SWIG, or (if it is installed) check whether an
argument needs to be provided to libSBML's configure --with-swig option so
that the configure program can find 'swig'.
***************************************************************************
])
    fi

    dnl Check the version if required.

    m4_ifvaln([$1], [
      AC_MSG_CHECKING($SWIG version >= $1)

      changequote(<<, >>)

      rx=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      ry=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      rz=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`
	
      version=`"$SWIG" -version | tr -d '\015'`

      sx=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      sy=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      sz=`echo $version | sed -e 's/SWIG Version \([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

      changequote([, ])

      if test $sx -gt $rx \
         || (test $sx -eq $rx && test $sy -gt $ry) \
         || (test $sx -eq $rx && test $sy -eq $ry && test $sz -ge $rz); then
        AC_MSG_RESULT(yes (found $sx.$sy.$sz))

        dnl Now ask swig for the list of libraries that it wants.

        SWIGLIB=`"$SWIG" -swiglib`
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([Need SWIG version $1, but only found version $sx.$sy.$sz.])
      fi

    ])

    dnl Set up replacement variables, including some that we don't currently
    dnl use but may in the future.

    AC_DEFINE([USE_SWIG], 1, [Define to 1 to use SWIG])
    AC_SUBST(USE_SWIG, 1)

    AC_SUBST(SWIGLIB)
    AC_SUBST(SWIGFLAGS)

    AC_SUBST(SWIG_CPPFLAGS)
    AC_SUBST(SWIG_LDFLAGS)
    AC_SUBST(SWIG_LIBS)

  else
    dnl --with-swig not given.  Use the simplest default.
    SWIG=swig

  fi

  dnl Record the version of SWIG we need, for later testing. 
  dnl Note that this is always set, regardless of whether --with-swig is given.

  SWIGNEEDVERSION=[$1]

  dnl Do substitutions we always do.

  AC_SUBST(SWIG)
  AC_SUBST(SWIGNEEDVERSION)    

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_SWIG"

])

