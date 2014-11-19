dnl
dnl Filename    : ruby.m4
dnl Description : Autoconf macro to check for Ruby
dnl Author(s)   : SBML Team <sbml-team@caltech.edu>
dnl Organization: California Institute of Technology
dnl Created     : 2007-12-17
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
dnl Provides --with-ruby[=PREFIX]
dnl

AC_DEFUN([CONFIG_PROG_RUBY],
[
  AC_ARG_VAR([RUBY])

  AC_ARG_WITH(ruby,
              AS_HELP_STRING([--with-ruby@<:@=PREFIX@:>@],
                             [generate Ruby interface library @<:@default=no@:>@]),
	      [with_ruby=$withval],
	      [with_ruby=no])

  if test "x$with_ruby" != xno; then

    dnl Find a ruby executable.

    if test "x$with_ruby" != xyes;
    then
      dnl Remove needless trailing slashes because it can confuse tests later.
      with_ruby=`echo $with_ruby | sed -e 's,\(.*\)/$,\1,g'`

      AC_PATH_PROGS([RUBY], [ruby ruby1.8 ruby 1.9], [no], [$with_ruby/bin])
    else
      AC_PATH_PROGS([RUBY], [ruby ruby1.8 ruby 1.9])
    fi

    if test -z "$RUBY" -o "$RUBY" = "no" -o ! -f "$RUBY"; 
    then
      AC_MSG_ERROR([*** ruby missing - please install first or check config.log ***])
    fi  

    dnl check version if required
    m4_ifvaln([$1], [
        AC_MSG_CHECKING($RUBY version >= $1)
        if test `$RUBY -rrbconfig -e ["puts RUBY_VERSION >= \"$1\" ? \"OK\" : \"OLD\""]` = "OK"
        then
          AC_MSG_RESULT(ok)
        else
          AC_MSG_RESULT(no)
          AC_MSG_ERROR([*** ruby version $1 or later is required ***])
        fi
    ])

    AC_MSG_CHECKING(for ruby prefix)
    RUBY_PREFIX=`$RUBY -rrbconfig -e ["include Config; puts CONFIG['prefix']"]`
    AC_MSG_RESULT($RUBY_PREFIX)

    if test `$RUBY -rrbconfig -e ["puts RUBY_VERSION >= \"2.0.0\" ? \"OK\" : \"OLD\""]` = "OK";
    then
      RUBY_ARCHDIR=`$RUBY -rrbconfig -e ["include RbConfig; print \"#{CONFIG['rubyhdrdir']} -I#{CONFIG['rubyhdrdir']}/#{CONFIG['arch']}\" "]`
      RUBY_H=`$RUBY -rrbconfig -e ["include RbConfig; print \"#{CONFIG['rubyhdrdir']}\" "]`"/ruby.h"
      RUBY_INSTALL_DIR=`/usr/bin/ruby -rrbconfig -e 's = File::SEPARATOR; a = RbConfig::CONFIG["archdir"].squeeze(s); b = RbConfig::CONFIG["libdir"].squeeze(s); print a.sub(/^#{b}#{s}ruby/, "/usr/local/lib#{s}ruby#{s}site_ruby")'`
    else
    if test `$RUBY -rrbconfig -e ["puts RUBY_VERSION >= \"1.9.0\" ? \"OK\" : \"OLD\""]` = "OK";
    then
      RUBY_ARCHDIR=`$RUBY -rrbconfig -e ["include Config; print \"#{CONFIG['rubyhdrdir']} -I#{CONFIG['rubyhdrdir']}/#{CONFIG['arch']}\" "]`
      RUBY_H=`$RUBY -rrbconfig -e ["include Config; print \"#{CONFIG['rubyhdrdir']}\" "]`"/ruby.h"
      RUBY_INSTALL_DIR=`/usr/bin/ruby -rrbconfig -e 's = File::SEPARATOR; a = Config::CONFIG["archdir"].squeeze(s); b = Config::CONFIG["libdir"].squeeze(s); print a.sub(/^#{b}#{s}ruby/, "/usr/local/lib#{s}ruby#{s}site_ruby")'`
    else
      RUBY_ARCHDIR=`$RUBY -rrbconfig -e ["include Config; puts CONFIG['archdir']"]`
      RUBY_H="${RUBY_ARCHDIR}/ruby.h"
      RUBY_INSTALL_DIR=`/usr/bin/ruby -rrbconfig -e 's = File::SEPARATOR; a = Config::CONFIG["archdir"].squeeze(s); b = Config::CONFIG["libdir"].squeeze(s); print a.sub(/^#{b}#{s}ruby/, "/usr/local/lib#{s}ruby#{s}site_ruby")'`
    fi
    fi

    AC_MSG_CHECKING(for ruby.h)
    if test -z "$RUBY_H" || ! test -f "$RUBY_H"; 
    then
      AC_MSG_RESULT(no)

      AC_MSG_ERROR([*** $RUBY_H missing - please install first or check config.log ***])
    fi
    AC_MSG_RESULT(yes)

    RUBY_LIBDIR=`$RUBY -rrbconfig -e ["include Config; puts CONFIG['libdir']"]` 
    RUBY_NAME=`$RUBY -rrbconfig -e ["include Config; puts CONFIG['RUBY_SO_NAME']"]`


    dnl
    dnl Check for possible binary 32/64-bit incompatbilities.
    dnl

    changequote(<<, >>)
    if test `$RUBY -e "print ['f'].pack('p').size"` = "8"; then
      RUBY_64BIT=1
    else
      RUBY_64BIT=0
    fi
    changequote([, ])

    case $host in
    *darwin*) 
      dnl MacOS 10.6 (Snow Leopard) makes 64-bit binaries by default.
      dnl MacOS 10.5 (Leopard) makes 32-bit binaries by default.

      osx_major_ver=`uname -r | cut -f1 -d'.'`

      if test ${osx_major_ver} -ge 10; then
        dnl We're on MacOS 10.6, which makes 64-bit bins unless told not to.

        AC_MSG_CHECKING([whether this is a 64-bit version of ruby])
        if test $RUBY_64BIT -eq 1; then
          AC_MSG_RESULT([yes])

          dnl Did the user request a 32-bit libSBML?  Because that'd be bad.
          AC_MSG_CHECKING([whether only 32-bit libSBML binaries are being made])
          if echo $CFLAGS $CXXFLAGS | egrep -q "arch i386"; then
            dnl On MacOSX, we might be making fat binaries.  Check that.
            if echo $CFLAGS $CXXFLAGS | grep -q "arch x86_64"; then
              AC_MSG_RESULT([no])
            else
              dnl Not making fat binaries, and we have a conflict.
              AC_MSG_RESULT([yes, and that's a problem])
              if test "x$enable_univbinary" != xno; then
                AC_MSG_ERROR([
***************************************************************************
The copy of ruby ($RUBY) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The ruby interpreter will be unable to load the resulting
libSBML libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 option or else add "-arch x86_64" to the arguments given to
the --enable-universal-binary option.
***************************************************************************
])
              else
                AC_MSG_ERROR([
***************************************************************************
The copy of ruby ($RUBY) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The ruby interpreter will be unable to load the resulting
libSBML libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 or else add the option --enable-universal-binary.
***************************************************************************
])
              fi
            fi
          else
            AC_MSG_RESULT([no, all good])
          fi

        else
          AC_MSG_RESULT([no])
  	  dnl ruby reports being 32-bit, but we're on a 64-bit system.

          AC_MSG_CHECKING([whether only 64-bit libSBML binaries are being made])
          if echo $CFLAGS $CXXFLAGS | egrep -q "arch x86_64"; then
            dnl On MacOSX, we might be making fat binaries.  Check that.
            if echo $CFLAGS $CXXFLAGS | grep -q "arch i386"; then
              AC_MSG_RESULT([no])
            else
              dnl Not making fat binaries, and we have a conflict.
              AC_MSG_RESULT([yes, and that's a problem])
              if test "x$enable_univbinary" != xno; then
                AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 32-bit (i386) version, 
because your copy of ruby ($RUBY) is a 32-bit version.
By default, MacOS 10.6+ (Snow Leopard) builds everything as 64-bit
(x86_64) binaries.  Please either add "-arch i386" to the arguments to
--enable-universal-binary, or remove --enable-universal-binary and 
add --enable-m32 to your configure options, the re-run the configure step,
and recompile.  If you get a compilation error, please check whether you
have a private version of a dependent library (e.g., expat, libxml, or
xerces) that was built only as a 64-bit version, and either remove,
recompile or replace it it before proceeding further.
***************************************************************************
])
              else
                AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 32-bit (i386) version, 
because your copy of ruby ($RUBY) is a 32-bit version.
By default, MacOS 10.6+ (Snow Leopard) builds everything as 64-bit
(x86_64) binaries.  Please add ONE of the following options,
    --enable-m32
or
    --enable-universal-binary="-arch i386 -arch x86_64" 
to your configure options, re-run the configure step, and recompile.  If
you get a compilation error, please check whether you have a private 
version of a dependent library (e.g., expat, libxml, or xerces) that was 
built only as a 64-bit version, and either remove, recompile or replace it
it before proceeding further.
***************************************************************************
])
              fi
            fi
          else
            AC_MSG_RESULT([no, all good])
          fi
        fi

      else
        dnl We're on pre-MacOS 10.6, which makes 32-bit bins by default,
        dnl but the underlying hardware is still 64-bit and 64-bit programs
        dnl can still be executed.

        AC_MSG_CHECKING([whether this is a 64-bit version of ruby])
        if test $RUBY_64BIT -eq 1; then
          AC_MSG_RESULT([yes])

          dnl Did the user request a 64-bit libSBML?  If not, it's a problem.
          AC_MSG_CHECKING([whether 64-bit libSBML binaries are being built])
          if echo $CFLAGS $CXXFLAGS | grep -q "arch x86_64"; then
            AC_MSG_RESULT([yes, we are 'go' for 64-bit])
          else
            AC_MSG_RESULT([no, and that's a problem])
            if test "x$enable_univbinary" != xno; then
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 64-bit (x86_64) version, 
because your copy of ruby ($RUBY) is a 64-bit
version.  By default, MacOS versions before version 10.6 (Snow Leopard)
build everything as 32-bit (i386) binaries.  Please add the string
"-arch x86_64" to the arguments to your --enable-universal-binary option,
re-run the configure step, and recompile.  If you get a compilation error,
please check whether you have a private version of a dependent library
(e.g., expat, libxml, or xerces) that was built only as a 32-bit version,
and either remove, recompile or replace it it before proceeding further.
***************************************************************************
])
            else
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 64-bit (x86_64) version, 
because your copy of ruby ($RUBY) is a 64-bit
version.  By default, MacOS versions before version 10.6 (Snow Leopard)
build everything as 32-bit (i386) binaries.  Please add ONE of the
following options,
    --enable-m64
or
    --enable-universal-binary="-arch i386 -arch x86_64"
to your configure options, re-run the configure step, and recompile.
***************************************************************************
])
            fi
          fi
        else
          AC_MSG_RESULT([no])
          dnl Not a 64-bit ruby, and we're on pre-MacOS 10.6.
          dnl Did the user request a 64-bit libSBML?  If so, it's a problem.

          AC_MSG_CHECKING([whether only 64-bit libSBML binaries are being made])
          if echo $CFLAGS $CXXFLAGS | egrep -q "arch x86_64"; then
            dnl On MacOSX, we might be making fat binaries.  Check that.
            if echo $CFLAGS $CXXFLAGS | grep -q "arch i386"; then
              AC_MSG_RESULT([no, which is good])
            else
              dnl Not making fat binaries, and we have a conflict.
              AC_MSG_RESULT([yes, and that's a problem])
              if test "x$enable_univbinary" != xno; then
                AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 32-bit (i386) version, 
because your copy of ruby ($RUBY) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The ruby interpreter will be unable to load the
resulting libSBML libraries at run-time.  Please add "-arch i386" to
the arguments to the --enable-universal-binary configure option (or
remove the --enable-universal-binary option), re-run the configure step,
and then recompile libSBML.
***************************************************************************
])
                else
                  AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 32-bit (i386) version, 
because your copy of ruby ($RUBY) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The ruby interpreter will be unable to load the
resulting libSBML libraries at run-time.  Please add ONE of the following
options,
    --enable-m32
or
    --enable-universal-binary="-arch i386 -arch x86_64"
to your configure options, re-run the configure step, and recompile.  If
you get a compilation error, please check whether you have a private
version of a dependent library (e.g., expat, libxml, or xerces) that was
built only as a 32-bit version, and either remove, recompile or replace it
it before proceeding further.
***************************************************************************
])
                fi
              fi
            else
              AC_MSG_RESULT([no])
            fi
          fi
        fi
      ;;

      *)
        dnl
        dnl Non-MacOSX systems.  We only have to worry if the operating
        dnl system is a 64-bit one.
        dnl

        if test ${host_cpu} = "x86_64"; then
          dnl We're on a system that makes 64-bit binaries by default.

          AC_MSG_CHECKING([whether this is a 64-bit version of ruby])
          if test $RUBY_64BIT -eq 1; then
            AC_MSG_RESULT([yes])

            dnl Did the user request a 32-bit libSBML?  Because that'd be bad.
            AC_MSG_CHECKING([whether only 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
You have requested building a 32-bit version of libSBML, but the ruby
environment ($RUBY) on this sytem is a 64-bit version.
The ruby interpreter will be unable to load the resulting libSBML library
at run-time. Please reconfigure libSBML WITHOUT the --enable-m32 option (or
whatever means you used to indicate 32-bit compilation in this instance).
***************************************************************************
])
            else
              AC_MSG_RESULT([no])
            fi
          else
            dnl Not a 64-bit version of ruby, but this is still an x86_64.

            AC_MSG_RESULT([no])
            AC_MSG_CHECKING([whether 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, excellent])
            else
              AC_MSG_RESULT([no, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly as a 32-bit (i386) binary because 
your copy of ruby ($RUBY) is a 32-bit version.  Please 
add the option --enable-m32 to your configure options, re-run the configure
step, and recompile.  If you get a compilation error, please check whether
you have private version of a dependent library (e.g., expat, libxml, or
xerces) that was built only as a 64-bit version, and either remove,
recompile or replace it it before proceeding further.
***************************************************************************
])
            fi
          fi
        fi
      ;;
    esac

    dnl Figure out the last bits for linking.
    dnl This comes in part from SWIG 1.3.31's configure.ac file.

    case $host in
    *darwin*) 
   	RUBY_CPPFLAGS="-I${RUBY_ARCHDIR}"
	RUBY_LDFLAGS="-L${RUBY_LIBDIR} -undefined dynamic_lookup"
	;;
    *cygwin* | *mingw*) 
	RUBY_CPPFLAGS="-I${RUBY_ARCHDIR} -DUSE_DL_IMPORT"
	RUBY_LDFLAGS="-L${RUBY_LIBDIR}"
        RUBY_LIBS="-l${RUBY_NAME}"
	CONFIG_ADD_LDPATH(${RUBY_PREFIX}/lib/${RUBY_NAME}/config)
	;;
    *)
	RUBY_CPPFLAGS="-I${RUBY_ARCHDIR}"
        RUBY_LDFLAGS="-L${RUBY_LIBDIR}"
        RUBY_LIBS="-l${RUBY_NAME}"
	;;
    esac

    dnl
    dnl enable --with-swig option if SWIG-generated files of Ruby bindings
    dnl (libsbml_wrap.cpp) need to be regenerated.
    dnl

    ruby_dir="src/bindings/ruby"

    if test "$with_swig" = "no" -o -z "$with_swig" ; then
      AC_MSG_CHECKING(whether SWIG is required for Ruby bindings.)
      if test ! -e "${ruby_dir}/libsbml_wrap.cpp" ; then
        with_swig="yes"
        AC_MSG_RESULT(yes)
      else
        if test "$enable_layout" = "no"; then
          if grep -q getListOfLayouts "${ruby_dir}/libsbml_wrap.cpp"; then
            with_swig="yes"
            AC_MSG_RESULT(yes)
          else
            AC_MSG_RESULT(no)
          fi
        else
          if grep -q getListOfLayouts "${ruby_dir}/libsbml_wrap.cpp"; then
            AC_MSG_RESULT(no)
          else
            with_swig="yes"
            AC_MSG_RESULT(yes)
          fi
        fi
      fi
    fi

    AC_DEFINE([USE_RUBY], 1, [Define to 1 to use Ruby])
    AC_SUBST(USE_RUBY, 1)

    AC_SUBST(RUBY_CPPFLAGS)
    AC_SUBST(RUBY_INSTALL_DIR)
    AC_SUBST(RUBY_LDFLAGS)
    AC_SUBST(RUBY_LIBS)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_RUBY"

])

