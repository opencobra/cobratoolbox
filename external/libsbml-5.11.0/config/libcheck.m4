dnl @file    libcheck.m4
dnl @brief   Autoconf macro to check for existence of Check library
dnl @author  Mike Hucka (but portions taken from Check 0.9.5)
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
dnl Portions of this file originally came from the check 0.9.5
dnl distribution.  I (Mike Hucka) made some modifications because before
dnl discovering the version provided by check 0.9.5, we previously had
dnl written our own libcheck.m4, and I wanted to preserve some of the
dnl features of that original one, such as the messages it printed and the
dnl extra steps it too on MacOS X.
dnl
dnl According to the file NEWS in the check 0.9.5 distribution,
dnl libcheck is distributed under the terms of the LGPL.

dnl
dnl Supports --with-check[=PREFIX]
dnl
dnl Invoke in configure.ac as CONFIG_LIB_CHECK or CONFIG_LIB_CHECK(MIN-VERSION).
dnl Default minimum version is 0.9.2 because that's the minimum LibSBML needs.
dnl

AC_DEFUN([CONFIG_LIB_LIBCHECK],
[
  AC_ARG_WITH([check],
    AS_HELP_STRING([--with-check@<:@=PREFIX@:>@],
                   [use the libcheck unit testing library @<:@default=no@:>@]),
    [with_libcheck=$withval],
    [with_libcheck=no])

  if test $with_libcheck != no; then

    AC_LANG_PUSH(C)

    LIBCHECK_LIBS="-lcheck"

    if test $with_libcheck != yes; then
      libcheck_root="$with_libcheck"
      libcheck_lib_path="$libcheck_root/lib${LIBSUFFIX}"
      CONFIG_ADD_LDPATH($libcheck_lib_path)
      LIBCHECK_CPPFLAGS="-I$libcheck_root/include"
      LIBCHECK_LDFLAGS="-L$libcheck_lib_path"
    else
      dnl On the Macs, if the user has installed libcheck via Fink and they
      dnl used the default Fink install path of /sw, the following should
      dnl catch it.  We do this so that Mac users are more likely to find
      dnl success even if they only type --with-check.

      dnl This is a case statement, in case we need to do something similar
      dnl for other host types in the future.

      case $host in
      *darwin*) 
        if test -e "/sw"; then
          libcheck_root="/sw"
          libcheck_lib_path="/sw/lib"
          CONFIG_ADD_LDPATH($libcheck_lib_path)
          LIBCHECK_CPPFLAGS="-I$libcheck_root/include"
          LIBCHECK_LDFLAGS="-L$libcheck_lib_path"
        fi
        ;;
      esac    

      dnl Note that CONFIG_ADD_LDPATH is deliberately not called in cases
      dnl other than the two above.
    fi

    dnl The following is grungy but I don't know how else to make 
    dnl AC_CHECK_LIB use particular library and include paths without
    dnl permanently resetting CPPFLAGS etc.

    tmp_CFLAGS="$CFLAGS"
    tmp_LDFLAGS="$LDFLAGS"
    tmp_LIBS="$LIBS"
    CFLAGS="$LIBCHECK_CPPFLAGS $CFLAGS"
    LDFLAGS="$LIBCHECK_LDFLAGS $LDFLAGS"
    LIBS="$LIBCHECK_LIBS $LIBS"

    libcheck_found=no

    AC_CHECK_HEADERS([check.h], [libcheck_found=yes], [libcheck_found=no])

    if test $libcheck_found = no; then
      AC_CHECK_LIB([check], [srunner_create],
        [libcheck_found=yes],
        [libcheck_found=no])
    fi

    if test $libcheck_found = no; then
      AC_MSG_ERROR([Could not find the libcheck library.])
    fi

    # Set up LD_LIBRARY_PATH/DYLD_LIBRARY_PATH for compiling the
    # test program below

    tmp_library_path=""
    case $host in
    *darwin*) 
      tmp_library_path="$DYLD_LIBRARY_PATH"
      DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH;$libcheck_lib_path"
      export DYLD_LIBRARY_PATH
      ;;
    *)
      tmp_library_path="$LD_LIBRARY_PATH"
      LD_LIBRARY_PATH="$LD_LIBRARY_PATH;$libcheck_lib_path"
      export LD_LIBRARY_PATH
      ;;
    esac    

    min_check_version=ifelse([$1], ,0.9.2,$1)
    AC_MSG_CHECKING(for Check version >= $min_check_version)

    rm -f conf.check-test
    AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <check.h>

int main ()
{
  int major, minor, micro;
  char *tmp_version;

  system ("touch conf.check-test");

  /* HP/UX 9 writes to sscanf strings */
  tmp_version = strdup("$min_check_version");
  if (sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) != 3)
    {
      printf("%s, bad version string\n", "$min_check_version");
      return 1;
    }
    
  if ((CHECK_MAJOR_VERSION != check_major_version) ||
      (CHECK_MINOR_VERSION != check_minor_version) ||
      (CHECK_MICRO_VERSION != check_micro_version))
    {
      printf("\n*** The Check header file (version %d.%d.%d) does not match\n",
             CHECK_MAJOR_VERSION, CHECK_MINOR_VERSION, CHECK_MICRO_VERSION);
      printf("*** the Check library found (version %d.%d.%d).\n",
             check_major_version, check_minor_version, check_micro_version);
      return 1;
    }

  if ((check_major_version > major) ||
      ((check_major_version == major) && (check_minor_version > minor)) ||
      ((check_major_version == major) && (check_minor_version == minor)
        && (check_micro_version >= micro)))
    {
      return 0;
    }
  else
    {
      printf("\n*** An old version of Check (%d.%d.%d) was found.\n",
             check_major_version, check_minor_version, check_micro_version);
      printf("*** You need a version of Check that's at least %d.%d.%d.\n", 
        major, minor, micro);
      printf("***\n"); 
      printf("*** If you've already installed a sufficiently new version,\n");
      printf("*** this error probably means that the wrong copy of the\n");
      printf("*** Check library and header file are being found.  Re-run\n");
      printf("*** configure with the --with-check=PATH option to specify\n");
      printf("*** the prefix where the correct version is installed.\n");
    }

  return 1;
}
]])], [AC_MSG_RESULT(yes)], [no_check=yes], [[]])

    CFLAGS="$tmp_CFLAGS"
    LDFLAGS="$tmp_LDFLAGS"
    LIBS="$tmp_LIBS"

    if test "x$no_check" = x ; then
      ifelse([$2], , :, [$2])
    else
      if test -f conf.check-test ; then
	:
      else
        echo "*** Could not run Check test program, trying to find out why..."

        CFLAGS="$LIBCHECK_CPPFLAGS $CFLAGS"
        LDFLAGS="$LIBCHECK_LDFLAGS $LDFLAGS"
        LIBS="$LIBCHECK_LIBS $LIBS"

        AC_LINK_IFELSE(
        [AC_LANG_PROGRAM([[
	  #include <stdio.h>
	  #include <stdlib.h>
	  #include <check.h>]], [])], 

        [ echo "*** The test program compiled, but did not run.  This usually"
          echo "*** means that the run-time linker is not finding libcheck, but"
          echo "*** could also be the result of mixing binary architectures"
          echo "*** (e.g., trying to use a 32-bit check library while compiling"
          echo "*** in a 64-bit environment).  At this point, it is best to"
          echo "*** look in the file 'config.log' for clues about what happened."
          echo "***"
          echo "*** If the problem is due to the first issue, will may need"
          echo "*** to set your LD_LIBRARY_PATH environment variable, or"
          echo "*** edit /etc/ld.so.conf to point to the installed"
          echo "*** location, and also run ldconfig if that is required on"
          echo "*** your operating system.  If the problem is due to the"
          echo "*** second (mixing architectures), you may need to obtain a"
          echo "*** different copy of libcheck or recompile it for this"
          echo "*** machine architecture."
          echo "***"
          echo "*** If you have an old version of Check installed, it is best"
          echo "*** to remove it, although you may also be able to get things"
          echo "*** to work by modifying you value of LD_LIBRARY_PATH."],
  
        [ echo "*** The test program failed to compile or link. See the file"
          echo "*** 'config.log' for more information about what happened." ])
        
        CFLAGS="$tmp_CFLAGS"
        LDFLAGS="$tmp_LDFLAGS"
        LIBS="$tmp_LIBS"
  
      fi

      rm -f conf.check-test
      ifelse([$3], , AC_MSG_ERROR([check not found]), [$3])
    fi

    rm -f conf.check-test

    CFLAGS="$tmp_CFLAGS"
    LDFLAGS="$tmp_LDFLAGS"
    LIBS="$tmp_LIBS"
    case $host in
    *darwin*) 
      DYLD_LIBRARY_PATH=$tmp_library_path
      export DYLD_LIBRARY_PATH
      ;;
    *)
      LD_LIBRARY_PATH=$tmp_library_path
      export LD_LIBRARY_PATH
      ;;
    esac    

    AC_LANG_POP(C)

    AC_DEFINE([USE_LIBCHECK], 1, [Define to 1 to use the check library])
    AC_SUBST(USE_LIBCHECK, 1)

    AC_SUBST(LIBCHECK_CPPFLAGS)
    AC_SUBST(LIBCHECK_LDFLAGS)
    AC_SUBST(LIBCHECK_LIBS)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_LIBCHECK"

])
