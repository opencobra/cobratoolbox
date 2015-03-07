dnl
dnl Filename    : matlab.m4
dnl Description : Autoconf macro for MATLAB configuration
dnl Author(s)   : Mike Hucka
dnl Created     : 2004-08-02
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

AC_DEFUN([CONFIG_PROG_MATLAB],
[
  AC_ARG_WITH([matlab],
    AS_HELP_STRING([--with-matlab@<:@=PREFIX@:>@],
                   [generate MATLAB interface library @<:@default=no@:>@]),
    [with_matlab=$withval],
    [with_matlab=no])

  if test $with_matlab != no; then

    if test $with_matlab != yes;
    then
      dnl Remove needless trailing slashes because it can confuse tests later.
      with_matlab=`echo $with_matlab | sed -e 's,\(.*\)/$,\1,g'`

      AC_PATH_PROG([MATLAB], [matlab], [no], [$with_matlab/bin])
    else
      AC_PATH_PROG([MATLAB], [matlab])
    fi

    if test -z "$MATLAB" -o "$MATLAB" = "no"; then
      AC_MSG_ERROR([Could not find 'matlab' executable for MATLAB.])
    fi

    AC_DEFINE([USE_MATLAB], 1, [Define to 1 to use MATLAB])
    AC_SUBST(USE_MATLAB, 1)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_MATLAB"

])
