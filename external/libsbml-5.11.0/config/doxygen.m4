dnl Filename    : doxygen.m4
dnl Description : Autoconf macro to check for existence of Doxygen
dnl Author(s)   : Mike Hucka <mhucka@caltech.edu>
dnl Created     : 2007-04-16
dnl
dnl ---------------------------------------------------------------------------
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
dnl ---------------------------------------------------------------------------

dnl
dnl Supports --with-doxygen[=PREFIX]
dnl

dnl WARNING: make sure to invoke this *after* invoking the check for Java,
dnl because there's a test at the end of this file involving $with_java.

AC_DEFUN([CONFIG_PROG_DOXYGEN],
[
  AC_SUBST(DOXYGEN_CONFIG_OPT)

  AC_ARG_WITH([doxygen],
    AS_HELP_STRING([--with-doxygen@<:@=PREFIX@:>@],
                   [specify path to doxygen @<:@default=autodetect@:>@]),
    [with_doxygen=$withval],
    [with_doxygen=no])

  if test "$with_doxygen" != "no"; then
    if test "$with_doxygen" != "yes"; then
      dnl Users seems to have supplied a prefix directory path.  See if we can
      dnl find doxygen somewhere in the given tree.
  
      dnl 1st remove trailing slashes because it can confuse tests below.
  
      with_doxygen=`echo $with_doxygen | sed -e 's,\(.*\)/$,\1,g'`
  
      AC_PATH_PROG([DOXYGEN], [doxygen], [no], 
                   [$with_doxygen/bin $with_doxygen/Contents/Resources $with_doxygen/.. $with_doxygen])
      AC_SUBST(DOXYGEN_CONFIG_OPT,[=$with_doxygen])
    else
      dnl Nothing supplied -- look for doxygen on the user's path.
      AC_PATH_PROG([DOXYGEN], [doxygen])
    fi

    if test -z "$DOXYGEN" -o "$DOXYGEN" = "no"; then
      AC_MSG_ERROR([Could not find 'doxygen' executable for Doxygen.])
    fi

    dnl We've found a copy of doxygen.
    dnl Check the version if required.

    DOXYGEN_MIN_VERSION=$1
    DOXYGEN_MAX_VERSION=$2

    m4_ifvaln([$DOXYGEN_MIN_VERSION], [
      AC_MSG_CHECKING($DOXYGEN version >= $1)

      version=`"$DOXYGEN" --version | tr -d '\015'`

      changequote(<<, >>)

      dx=`echo $version | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      dy=`echo $version | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      dz=`echo $version | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

      doxygen_version=`printf "%02d%02d%02d" $dx $dy $dz`

      minx=`echo $DOXYGEN_MIN_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      miny=`echo $DOXYGEN_MIN_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      minz=`echo $DOXYGEN_MIN_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`
	
      min_version=`printf "%d%02d%02d" $minx $miny $minz`

      maxx=`echo $DOXYGEN_MAX_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      maxy=`echo $DOXYGEN_MAX_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      maxz=`echo $DOXYGEN_MAX_VERSION | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`
	
      max_version=`printf "%d%02d%02d" $maxx $maxy $maxz`

      changequote([, ])

      if test $doxygen_version -gt $max_version; then
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([Doxygen version cannot be greater than $DOXYGEN_MAX_VERSION, but found version $dx.$dy.$dz.])
      fi

      if test $doxygen_version -ge $min_version; then
        AC_MSG_RESULT(yes (found $dx.$dy.$dz))
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([Doxygen version must be at least $DOXYGEN_MIN_VERSION, but found only version $dx.$dy.$dz.])
      fi
    ])

    AC_DEFINE([USE_DOXYGEN], 1, [Define to 1 to use DOXYGEN])
    AC_SUBST(USE_DOXYGEN, 1)

    dnl Check the existence of a jar file for javadoc if --with-java enabled.
    dnl The jar file is classes.jar (MacOSX) or tools.jar (other OSes).

    if test "$with_java" != "no"; then
      AC_MSG_CHECKING(for javadoc)
      if ! test -e $JAVADOC_JAR; then
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([*** missing $JAVADOC_JAR - please install first or check config.log ***])
      else
        AC_MSG_RESULT(yes)
      fi
    fi

  else
    DOXYGEN="no-doxygen-found"
  fi

])

