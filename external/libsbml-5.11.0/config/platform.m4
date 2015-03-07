dnl @file    platform.m4
dnl @brief   Autoconf macros for detecting misc. platform characteristics
dnl @author  Mike hucka
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
dnl In configure.ac, make sure to invoke this after CONFIG_BINARIES.

AC_DEFUN([CONFIG_PLATFORM],
[
  AC_DEFINE([SHAREDLIBEXT])
  AC_DEFINE([HOST_TYPE])
  AC_DEFINE([LIBSUFFIX])

  case $host_os in
  *linux*)
    CPPFLAGS="-DLINUX $CPPFLAGS"
    HOST_TYPE="linux"
    SHAREDLIBEXT="so"
    ;;

  *solaris*)
    CPPFLAGS="-DSOLARIS $CPPFLAGS"
    HOST_TYPE="solaris"
    SHAREDLIBEXT="so"
    ;;

  *cygwin*)
    CPPFLAGS="-DWIN32 -DCYGWIN -DLIBSBML_EXPORTS $CPPFLAGS"
    HOST_TYPE="cygwin"
    SHAREDLIBEXT="dll"
    ;;

  *darwin*)
    CPPFLAGS="-DMACOSX $CPPFLAGS"
    HOST_TYPE="darwin"
    SHAREDLIBEXT="dylib"
    ;;

  *aix*)
    CPPFLAGS="-DAIX $CPPFLAGS"
    HOST_TYPE="aix"
    SHAREDLIBEXT="a"
    ;;

  *freebsd*)
    CPPFLAGS="-DFREEBSD $CPPFLAGS"
    HOST_TYPE="freebsd"
    SHAREDLIBEXT="so"
    ;;
  
  esac

  dnl Set ourselves up to be able to look in the right lib directories.
  dnl On Linux, 64-bit libraries tend to put into directories named
  dnl .../lib64 instead of .../lib.  On MacOS, the libraries are either
  dnl fat binaries or placed in the same directories, so no change is
  dnl needed there.  FIXME: The following code has only been tested
  dnl under Linux and MacOS.

  LIBSUFFIX=""
  if test ${host_cpu} = "x86_64"; then
    if echo $CFLAGS $CXXFLAGS | grep -v "m32"; then
      LIBSUFFIX="64"
    fi
  fi

  AC_SUBST(SHAREDLIBEXT)
  AC_SUBST(HOST_TYPE)
  AC_SUBST(LIBSUFFIX)
])
