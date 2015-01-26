dnl
dnl Filename    : octave.m4
dnl Description : Autoconf macro for Octave configuration
dnl Author(s)   : Mike Hucka
dnl Created     : 2007-08-26
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

dnl Unlike the others, this takes 2 args: octave version and mkoctfile version.
dnl CONFIG_PROG_OCTAVE(oversion, mversion)

AC_DEFUN([CONFIG_PROG_OCTAVE],
[
  AC_ARG_WITH([octave],
    AS_HELP_STRING([--with-octave@<:@=PREFIX@:>@],
                   [generate Octave interface library @<:@default=no@:>@]),
    [with_octave=$withval],
    [with_octave=no])

  if test $with_octave != no; then

    if test $with_octave != yes; then
      dnl Remove needless trailing slashes because it can confuse tests later.
      with_octave=`echo $with_octave | sed -e 's,\(.*\)/$,\1,g'`

      AC_PATH_PROG([OCTAVE], [octave], [no], [$with_octave/bin])
      AC_PATH_PROG([MKOCTFILE], [mkoctfile], [no], [$with_octave/bin])
      AC_PATH_PROG([OCTAVE_CONFIG], [octave-config], [no], [$with_octave/bin])
    else
      AC_PATH_PROG([OCTAVE], [octave])
      AC_PATH_PROG([MKOCTFILE], [mkoctfile])
      AC_PATH_PROG([OCTAVE_CONFIG], [octave-config])
    fi

    if test -z "$OCTAVE" -o "$OCTAVE" = "no"; then
      AC_MSG_ERROR([Could not find 'octave' executable for Octave.])
    elif  test -z "$MKOCTFILE" -o "$MKOCTFILE" = "no"; then
      AC_MSG_ERROR([Could not find 'mkoctfile' executable for Octave.])
    fi

    dnl If we got this far, we have octave and mkoctfile executables.
    dnl Now check their versions against what was requested (if anything).

    OCTAVE_REQUEST_VERSION=$1
    MKOCTFILE_REQUEST_VERSION=$2

    AC_MSG_CHECKING(octave version)

    octave_version=`"$OCTAVE_CONFIG" --version 2>&1 | head -n 1`
    octave_major_ver=`echo $octave_version | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
    octave_minor_ver=`echo $octave_version | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
    octave_micro_ver=`echo $octave_version | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

    AC_MSG_RESULT($octave_version)

    if test -n "$OCTAVE_REQUEST_VERSION"; then
      AC_MSG_CHECKING(if octave version >= $OCTAVE_REQUEST_VERSION (found $octave_version))
    
      changequote(<<, >>)
      octave_major_req=`expr $OCTAVE_REQUEST_VERSION : '\([0-9]*\)\.[0-9]*\.[0-9]*'`
      octave_minor_req=`expr $OCTAVE_REQUEST_VERSION : '[0-9]*\.\([0-9]*\)\.[0-9]*'`
      octave_micro_req=`expr $OCTAVE_REQUEST_VERSION : '[0-9]*\.[0-9]*\.\([0-9]*\)'`
      changequote([, ])

      if test $octave_major_ver -gt $octave_major_req \
         || (test $octave_major_ver -eq $octave_major_req && \
             test $octave_minor_ver -gt $octave_minor_req) \
         || (test $octave_major_ver -eq $octave_major_req && \
             test $octave_minor_ver -eq $octave_minor_req && \
             test $octave_micro_ver -ge $octave_micro_req)
      then
        AC_MSG_RESULT(yes)
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR(installed version of octave is too old!)
      fi
    fi

    AC_MSG_CHECKING(mkoctfile version)

    changequote(<<, >>)
    mkoctfile_version=`"$MKOCTFILE" --version 2>&1 | head -n 1 | sed 's/.* \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/p; d'`
    mkoctfile_major_ver=`expr $mkoctfile_version : '\([0-9]*\)\.[0-9]*\.[0-9]*'`
    mkoctfile_minor_ver=`expr $mkoctfile_version : '[0-9]*\.\([0-9]*\)\.[0-9]*'`
    mkoctfile_micro_ver=`expr $mkoctfile_version : '[0-9]*\.[0-9]*\.\([0-9]*\)' '|' 0`
    changequote([, ])

    AC_MSG_RESULT($mkoctfile_version)

    MKOCTFILEVERNUM=`printf "%02d%02d%02d" $mkoctfile_major_ver $mkoctfile_minor_ver $mkoctfile_micro_ver`

    if test -n "$MKOCTFILE_REQUEST_VERSION"; then
      AC_MSG_CHECKING(if mkoctfile version >= (found $MKOCTFILE_REQUEST_VERSION))
    
      changequote(<<, >>)
      mkoctfile_major_req=`expr $MKOCTFILE_REQUEST_VERSION : '\([0-9]*\)\.[0-9]*\.[0-9]*'`
      mkoctfile_minor_req=`expr $MKOCTFILE_REQUEST_VERSION : '[0-9]*\.\([0-9]*\)\.[0-9]*'`
      mkoctfile_micro_req=`expr $MKOCTFILE_REQUEST_VERSION : '[0-9]*\.[0-9]*\.\([0-9]*\)'`
      changequote([, ])

      if test $mkoctfile_major_ver -gt $mkoctfile_major_req \
         || (test $mkoctfile_major_ver -eq $mkoctfile_major_req && \
             test $mkoctfile_minor_ver -gt $mkoctfile_minor_req) \
         || (test $mkoctfile_major_ver -eq $mkoctfile_major_req && \
             test $mkoctfile_minor_ver -eq $mkoctfile_minor_req && \
             test $mkoctfile_micro_ver -ge $mkoctfile_micro_req)
      then
        AC_MSG_RESULT(yes)
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR(installed version of mkoctfile is too old!)
      fi
    fi

    MKOCTFILE_FLAGS="--mex"
    OCTAVEEXT="mex"

    dnl get rid of prefix part from the directory name of the local oct file
    dnl repository in order to rebase it later.
    LOCALOCTFILEDIR=`"$OCTAVE_CONFIG" -p LOCALOCTFILEDIR | sed -e "s#^\`\"$OCTAVE_CONFIG\" -p PREFIX\`##"`

    AC_DEFINE([USE_OCTAVE], 1, [Define to 1 to use Octave])
    AC_SUBST(USE_OCTAVE, 1)

    AC_SUBST(OCTAVE)
    AC_SUBST(MKOCTFILE)
    AC_SUBST(MKOCTFILE_FLAGS)
    AC_SUBST(OCTAVEEXT)
    AC_SUBST(LOCALOCTFILEDIR) 

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_OCTAVE"

])

