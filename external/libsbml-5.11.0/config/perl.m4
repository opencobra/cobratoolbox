dnl
dnl Filename    : perl.m4
dnl Description : Autoconf macro to check for existence of Perl
dnl Author(s)   : Mike Hucka
dnl Organization: SBML Team
dnl Created     : 2005-05-01
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
dnl Check --with-perl[=PREFIX]
dnl

AC_DEFUN([CONFIG_PROG_PERL],
[
  AC_ARG_VAR([PERL])

  AC_ARG_WITH(perl,
              AS_HELP_STRING([--with-perl@<:@=PREFIX@:>@],
                             [generate Perl interface library @<:@default=no@:>@]),
	      [with_perl=$withval],
	      [with_perl=no])

  if test $with_perl != no; then

    dnl Find a perl executable.

    if test $with_perl != yes; then
      AC_PATH_PROG([PERL], [perl], [no], [$with_perl/bin])
    else
      AC_PATH_PROG([PERL], [perl])
    fi

    if test $PERL != "perl" && ! test -f $PERL;
    then
      AC_MSG_ERROR([*** $PERL missing - please install first or check config.log ***])
    fi

    CHECK_MK=`($PERL -mExtUtils::MakeMaker -e '{print "OK"}') 2>/dev/null`
    if test x$CHECK_MK != xOK;
    then
      AC_MSG_ERROR([*** ExtUtils::MakeMaker module is missing - please install first or check config.log ***])
    fi

    dnl
    dnl enable --with-swig option if SWIG-generated files of Perl bindings
    dnl (LibSBML_wrap.cxx and LibSBML.pm) need to be regenerated.
    dnl

    perl_dir="src/bindings/perl"

    if test "$with_swig" = "no" -o -z "$with_swig" ; then
      AC_MSG_CHECKING(whether SWIG is required for Perl bindings.)
      if test ! -e "${perl_dir}/LibSBML_wrap.cxx" -o ! -e "${perl_dir}/LibSBML.pm" ; then
        with_swig="yes"
        AC_MSG_RESULT(yes)
      else
        AC_MSG_RESULT(no)
      fi
    fi

    AC_DEFINE([USE_PERL], 1, [Define to 1 to use Perl])
    AC_SUBST(USE_PERL, 1)

    AC_SUBST(PERL_CPPFLAGS)
    AC_SUBST(PERL_LDFLAGS)
    AC_SUBST(PERL_LIBS)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_PERL"

])

