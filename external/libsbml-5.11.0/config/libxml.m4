dnl Filename    : libxml.m4
dnl Description : Autoconf macro to check for existence of libxml library
dnl Created     : 2007-02-22
dnl
dnl ---------------------------------------------------------------------------
dnl Portions of this file were taken from the file "libxml.m4" provided
dnl with the libxml2 version 2.6.27 distribution.  Here are the headers
dnl from that file:
dnl
dnl    Configure paths for LIBXML2
dnl    Mike Hommey 2004-06-19
dnl    use CPPFLAGS instead of CFLAGS
dnl    Toshio Kuratomi 2001-04-21
dnl    Adapted from:
dnl    Configure paths for GLIB
dnl    Owen Taylor     97-11-3
dnl
dnl Modifications here (in the version used in libSBML) include changing
dnl the configure flag to be "--with-libxml" to better distinguish the
dnl library in the libSBML configure options, changing the name of the
dnl macro to CONFIG_LIB_LIBXML, and various modifications to the code.
dnl
dnl The file libxml.m4 from libxml2 version 2.6.27 does not itself contain
dnl a copyright or license statement, but libxml 2.6.27 overall contains the
dnl following copyright and distribution notice:
dnl
dnl ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
dnl Except where otherwise noted in the source code (e.g. the files hash.c,
dnl list.c and the trio files, which are covered by a similar licence but
dnl with different Copyright notices) all the files are:
dnl
dnl  Copyright (C) 1998-2003 Daniel Veillard.  All Rights Reserved.
dnl
dnl Permission is hereby granted, free of charge, to any person obtaining a copy
dnl of this software and associated documentation files (the "Software"), to deal
dnl in the Software without restriction, including without limitation the rights
dnl to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
dnl copies of the Software, and to permit persons to whom the Software is fur-
dnl nished to do so, subject to the following conditions:
dnl
dnl The above copyright notice and this permission notice shall be included in
dnl all copies or substantial portions of the Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
dnl IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
dnl NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
dnl DANIEL VEILLARD BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
dnl IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CON-
dnl NECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
dnl
dnl Except as contained in this notice, the name of Daniel Veillard shall not
dnl be used in advertising or otherwise to promote the sale, use or other deal-
dnl ings in this Software without prior written authorization from him.
dnl ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


dnl
dnl Supports --with-libxml[=PREFIX]
dnl
dnl Invoke from configure.ac as
dnl CONFIG_LIB_LIBXML([MIN-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Tests for libxml2, and defines LIBXML_CPPFLAGS and LIBXML_LIBS.

AC_DEFUN([CONFIG_LIB_LIBXML],
[
  AC_ARG_WITH([libxml],
    AS_HELP_STRING([--with-libxml@<:@=PREFIX@:>@],
                   [use the libxml2 XML library @<:@default=yes@:>@]),
            [with_libxml="$withval"],
            [with_libxml=no])

  if test "$default_libxml" = "yes" -o "$with_libxml" != "no"; then

    if test -n "$with_xerces" -a "$with_xerces" != "no"; then
      AC_MSG_ERROR([
***************************************************************************
In the command line you used to run 'configure', the options --with-libxml
and --with-xerces were both supplied.  It only makes sense to provide one
or the other.  Please check your configuration options and modify them
appropriately, then re-run 'configure'.
***************************************************************************
])
    elif test -n "$with_expat" -a "$with_expat" != "no"; then
      AC_MSG_ERROR([
***************************************************************************
In the command line you used to run 'configure', the options --with-libxml
and --with-expat were both supplied.  It only makes sense to provide one
or the other.  Please check your configuration options and modify them
appropriately, then re-run 'configure'.
***************************************************************************
])
    fi

    dnl If we reach here, we've either been requested deliberately via
    dnl --with-libxml, or else we're the default.

    dnl Possible values of $default_libxml:
    dnl 1. Empty string
    dnl 2. "yes"

    dnl Possible values of $with_libxml:
    dnl 1. Empty string
    dnl 2. "no"
    dnl 3. "yes" (--with-libxml given without arg)
    dnl 4. A path (--with-libxml=arg)

    dnl We need to find xml2-config.  If we have a path in $with_libxml,
    dnl we use it to search, otherwise we search in the user's default
    dnl command search path.

    if test -n "$with_libxml" -a "$with_libxml" != "yes" -a "$with_libxml" != "no"; then
      if test -z "$XML2_CONFIG" ; then
        dnl The XML2_CONFIG environment variable is not set.  Look for
        dnl xml2-config in the path given by $with_libxml
        AC_PATH_PROG(XML2_CONFIG, xml2-config, no, [$with_libxml/bin])
      fi
      libxml_lib_path="$with_libxml/lib${LIBSUFFIX}"
    else
      if test "$HOST_TYPE" = "darwin"; then
        if test -z "$XML2_CONFIG" ; then
          dnl The XML2_CONFIG environment variable is not set.  Look for
          dnl xml2-config in the path given by $with_libxml
          AC_PATH_PROG(XML2_CONFIG, xml2-config, no, [/usr/bin])
        fi
        libxml_lib_path="/usr/lib${LIBSUFFIX}"
      else
        dnl User did not supply a path with the flag.
        if test x${XML2_CONFIG+set} != xset ; then
          dnl User did not set XML2_CONFIG either.  Try their default path.
          AC_PATH_PROG(XML2_CONFIG, xml2-config, no)
        fi

        libxml_lib_path=`$XML2_CONFIG --prefix`
      fi
    fi

    if test "$XML2_CONFIG" = "no"; then
      AC_MSG_ERROR([
***************************************************************************
'configure' could not find 'xml2-config' in directory $with_libxml/bin/.
There are a number of possible causes for this.  One possibility is that
the PATH supplied in the argument --with-libxml=PATH is of the form
'/usr/local/lib', when in fact it needs to be of the form '/usr/local'; in
other words, omit the 'lib' part of the name, because 'configure' appends
'lib' (or 'lib64' on some 64-bit systems) to whatever PATH is given as the
--with-libxml argument value.  Another possible cause of this problem is
that the xml2-config utility program is not located in PATH/bin, or (if no
argument PATH was given to --with-libxml) in your shell's command search
path.  This might happen on systems where the xml2-config utility is part
of a development tools package that must be installed separately from
whatever package contains the actual libxml2 library files.  Please check
that xml2-config exists in the expected location and adjust the arguments
to 'configure' if necessary.  Finally, if xml2-config is located in an
unusual location, you can try setting the environment variable XML2_CONFIG
to the full path of xml2-config and retrying the 'configure' command.
***************************************************************************
])
    fi

    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_LIBS="$LIBS"

    min_xml_version=ifelse([$1], ,2.0.0,[$1])
    AC_MSG_CHECKING(for libxml2 - version >= $min_xml_version)
    no_xml=""
    if test "$XML2_CONFIG" = "no" ; then
      no_xml=yes
    else
      LIBXML_CPPFLAGS=`$XML2_CONFIG --cflags`
      LIBXML_LIBS=`$XML2_CONFIG --libs`
      ver=`$XML2_CONFIG --version`
      xml_config_major_version=`echo $ver | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\1/'`
      xml_config_minor_version=`echo $ver | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\2/'`
      xml_config_micro_version=`echo $ver | sed 's/\([[0-9]]*\).\([[0-9]]*\).\([[0-9]]*\)/\3/'`

      CPPFLAGS="$CPPFLAGS $LIBXML_CPPFLAGS"
      LIBS="$LIBXML_LIBS $LIBS"

      # Set up LD_LIBRARY_PATH/DYLD_LIBRARY_PATH for compiling the
      # test program below

      tmp_library_path=""
      case $host in
      *darwin*)
        tmp_library_path="$DYLD_LIBRARY_PATH"
        DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH;$libxml_lib_path"
        export DYLD_LIBRARY_PATH
        ;;
      *)
        tmp_library_path="$LD_LIBRARY_PATH"
        LD_LIBRARY_PATH="$LD_LIBRARY_PATH;$libxml_lib_path"
        export LD_LIBRARY_PATH
        ;;
      esac

      dnl Now check if the installed libxml is sufficiently new.
      dnl (Also sanity checks the results of xml2-config to some extent)

      rm -f conf.xmltest
      AC_RUN_IFELSE([AC_LANG_SOURCE([[
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <libxml/xmlversion.h>

int
main()
{
  int xml_major_version, xml_minor_version, xml_micro_version;
  int major, minor, micro;
  char *tmp_version;

  system("touch conf.xmltest");

  /* Capture xml2-config output via autoconf/configure variables */

  /* HP/UX 9 writes to sscanf strings */
  tmp_version = (char *)strdup("$min_xml_version");
  if (sscanf(tmp_version, "%d.%d.%d", &major, &minor, &micro) != 3) {
     printf("%s, bad version string from xml2-config\n", "$min_xml_version");
     exit(1);
   }
   free(tmp_version);

   /* Capture the version information from the header files */
   tmp_version = (char *)strdup(LIBXML_DOTTED_VERSION);
   if (sscanf(tmp_version, "%d.%d.%d", &xml_major_version,
              &xml_minor_version, &xml_micro_version) != 3) {
     printf("%s, bad version string from libxml includes\n",
            "LIBXML_DOTTED_VERSION");
     exit(1);
   }
   free(tmp_version);

  /* Compare xml2-config output to the libxml headers */

  if ((xml_major_version != $xml_config_major_version) ||
      (xml_minor_version != $xml_config_minor_version) ||
      (xml_micro_version != $xml_config_micro_version))
    {
      printf("*** libxml header files (version %d.%d.%d) do not match\n",
             xml_major_version, xml_minor_version, xml_micro_version);
      printf("*** xml2-config (version %d.%d.%d)\n",
             $xml_config_major_version, $xml_config_minor_version,
             $xml_config_micro_version);
      return 1;
    }

  /* Compare the headers to the library to make sure we match */

  /* Less than ideal -- doesn't provide us with return value feedback,
   * only exits if there's a serious mismatch between header and library.
   */
    LIBXML_TEST_VERSION;

    /* Test that the library is greater than our minimum version */
    if ((xml_major_version > major) ||
        ((xml_major_version == major) && (xml_minor_version > minor)) ||
        ((xml_major_version == major) && (xml_minor_version == minor) &&
        (xml_micro_version >= micro)))
      {
        return 0;
       }
     else
      {
        printf("\n*** An old version of libxml2 (%d.%d.%d) was found.\n",
               xml_major_version, xml_minor_version, xml_micro_version);
        printf("*** You need a version of libxml2 newer than %d.%d.%d.\n",
               major, minor, micro);
        printf("*** The latest version of libxml2 is always available\n");
        printf("*** from ftp://ftp.xmlsoft.org.\n");
        printf("***\n");
        printf("*** If you've already installed a sufficiently new version,\n");
        printf("*** this error probably means that the wrong copy of the\n");
        printf("*** xml2-config shell script is being found.  The easiest\n");
        printf("*** way to fix this is to remove the old version of\n");
        printf("*** libxml2, but you can also set the environment variable\n");
        printf("*** XML2_CONFIG to the path of the correct copy of\n");
        printf("*** xml2-config.  (In this case, you will have to modify\n");
        printf("*** your LD_LIBRARY_PATH or DYLD_LIBRARY_PATH environment\n");
        printf("*** variable, or edit /etc/ld.so.conf so that the correct\n");
        printf("*** copy of the library is found at run-time.\n");
    }
  return 1;
}
]])],[],[no_xml=yes],[echo $ac_n "cross compiling; assumed OK... $ac_c"])
      CPPFLAGS="$ac_save_CPPFLAGS"
      LIBS="$ac_save_LIBS"
    fi

    if test "x$no_xml" = x ; then
      AC_MSG_RESULT(yes (version $xml_config_major_version.$xml_config_minor_version.$xml_config_micro_version))
      ifelse([$2], , :, [$2])
    else
      if test "$XML2_CONFIG" = "no" ; then
        echo "*** The xml2-config script installed by LIBXML could not be found"
        echo "*** If libxml was installed in PREFIX, make sure PREFIX/bin is in"
        echo "*** your path, or set the XML2_CONFIG environment variable to the"
        echo "*** full path to xml2-config."
      else
        if test -f conf.xmltest ; then
          AC_MSG_ERROR(installed version of libxml2 is too old!)
        else
          echo "*** Could not run libxml test program, checking why..."
          CPPFLAGS="$CPPFLAGS $LIBXML_CPPFLAGS"
          LIBS="$LIBS $LIBXML_LIBS"
          AC_LINK_IFELSE(
	[AC_LANG_PROGRAM(
          [[#include <libxml/xmlversion.h>
            #include <stdio.h>]],
          [[ LIBXML_TEST_VERSION; return 0; ]])],

        [ echo "*** The test program compiled, but did not run.  This usually"
          echo "*** means that the run-time linker is not finding libxml2.  You"
          echo "*** will need to set your LD_LIBRARY_PATH or DYLD_LIBRARY_PATH"
          echo "*** environment variable, or edit /etc/ld.so.conf to point to"
          echo "*** the installed location.  Also, make sure you have run"
          echo "*** ldconfig if that is required on your operating system."
          echo "***"
          echo "*** If you have an old version of libxml2 installed, it is best"
          echo "*** to remove it, although you may also be able to get things"
          echo "*** to work by modifying you value of LD_LIBRARY_PATH."],

        [ echo "*** The test program failed to compile or link. See the file"
          echo "*** config.log for the exact error that occured. This"
          echo "*** usually means LIBXML was incorrectly installed or that"
          echo "*** you have moved LIBXML since it was installed. In the"
          echo "*** latter case, you may want to edit the xml2-config"
          echo "*** script located in $XML2_CONFIG" ])

        fi
      fi

      LIBXML_CPPFLAGS=""
      LIBXML_LIBS=""
      ifelse([$3], , :, [$3])
    fi

    CPPFLAGS="$ac_save_CPPFLAGS"
    LIBS="$ac_save_LIBS"
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

    AC_DEFINE([USE_LIBXML], 1, [Define to 1 to use the libxml2 XML library])
    AC_SUBST(USE_LIBXML, 1)

    AC_SUBST(LIBXML_CPPFLAGS)
    AC_SUBST(LIBXML_LDFLAGS)
    AC_SUBST(LIBXML_LIBS)
    AC_SUBST(XML2_CONFIG)
    rm -f conf.xmltest

    AC_SUBST(XML_PARSER, [libxml2])

    dnl One more wrinkle: libxml 2.6.16 as shipped by Apple is broken, in
    dnl that it doesn't report XML_NS_ERR_UNDEFINED_NAMESPACE when the
    dnl condition arises.  Let's note the situation and conditionalize the
    dnl code where necessary.

    if test "$HOST_TYPE" = "darwin"\
         -a `echo $XML2_CONFIG | sed 's,///*,/,g'` = "/usr/bin/xml2-config"; then
      dnl
      dnl (Tiger, Leopard)
      dnl
      if test "`$XML2_CONFIG --libtool-libs`" = "/usr/lib/libxml2.la" \
         -a $xml_config_major_version -eq 2\
         -a $xml_config_minor_version -eq 6\
         -a $xml_config_micro_version -eq 16; then
          AC_SUBST(BUGGY_APPLE_LIBXML,1)
      elif test $xml_config_major_version -eq 2\
         -a $xml_config_minor_version -eq 7\
         -a $xml_config_micro_version -eq 8; then
        dnl
        dnl (Mountain Lion)
        dnl
        AC_SUBST(BUGGY_APPLE_LIBXML,1)
      else
        dnl
        dnl (Snow Leopard)
        dnl
        if test $xml_config_major_version -eq 2\
         -a $xml_config_minor_version -eq 7\
         -a $xml_config_micro_version -eq 3; then
          AC_SUBST(BUGGY_APPLE_LIBXML,1)
        fi
      fi
    fi
  fi

])
