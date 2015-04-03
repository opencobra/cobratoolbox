dnl
dnl Filename    : csharp.m4
dnl Description : Autoconf macro for CSharp bindings
dnl Author(s)   : SBML Team <sbml-team@caltech.edu>
dnl Organization: California Institute of Technology
dnl Created     : 2008-07-02
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

#
# Some of the code used in this file was borrowed heavily from configure.in 
# file of SWIG-1.3.35 (http://www.swig.org).
#
# SWIG is distributed under the following terms:
#
# ------------------------------------------------------------------------------ 
# I.  Copyright (c) 1995-1998
# The University of Utah and the Regents of the University of California
# All Rights Reserved
# 
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that 
# (1) The above copyright notice and the following two paragraphs
# appear in all copies of the source code and (2) redistributions
# including binaries reproduces these notices in the supporting
# documentation.   Substantial modifications to this software may be
# copyrighted by their authors and need not follow the licensing terms
# described here, provided that the new terms are clearly indicated in
# all files where they apply.
# 
# IN NO EVENT SHALL THE AUTHOR, THE UNIVERSITY OF CALIFORNIA, THE 
# UNIVERSITY OF UTAH OR DISTRIBUTORS OF THIS SOFTWARE BE LIABLE TO ANY
# PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
# DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
# EVEN IF THE AUTHORS OR ANY OF THE ABOVE PARTIES HAVE BEEN ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.
# 
# THE AUTHOR, THE UNIVERSITY OF CALIFORNIA, AND THE UNIVERSITY OF UTAH
# SPECIFICALLY DISCLAIM ANY WARRANTIES,INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND 
# THE AUTHORS AND DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE,
# SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
# 
# 
# II. 
# 
# This software includes contributions that are Copyright (c) 1998-2005
# University of Chicago.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.  Redistributions
# in binary form must reproduce the above copyright notice, this list of
# conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.  Neither the name of
# the University of Chicago nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF CHICAGO AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF
# CHICAGO OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# 
# III.  
# 
# This software includes contributions that are Copyright (c) 2005-2006
# Arizona Board of Regents (University of Arizona).
# All Rights Reserved
# 
# Permission is hereby granted, without written agreement and without
# license or royalty fees, to use, copy, modify, and distribute this
# software and its documentation for any purpose, provided that 
# (1) The above copyright notice and the following two paragraphs
# appear in all copies of the source code and (2) redistributions
# including binaries reproduces these notices in the supporting
# documentation.   Substantial modifications to this software may be
# copyrighted by their authors and need not follow the licensing terms
# described here, provided that the new terms are clearly indicated in
# all files where they apply.
# 
# THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY OF ARIZONA AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF
# ARIZONA OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ------------------------------------------------------------------------------ 


AC_DEFUN([CONFIG_PROG_CSHARP],
[
  AC_ARG_WITH(csharp, 
              AS_HELP_STRING([--with-csharp@<:@=PREFIX@:>@], 
                             [generate C# interface library @<:@default=no@:>@]),
              [with_csharp="$withval"], 
              [with_csharp=no])

  AC_ARG_WITH(cil-interpreter, 
              AS_HELP_STRING([--with-cil-interpreter@<:@=PATH@:>@], 
                             [set path to C# CIL interp. @<:@default=autodetect@:>@]),
              [CSHARP_BIN="$withval"], 
              [CSHARP_BIN=])

  AC_ARG_WITH(csharp-compiler, 
              AS_HELP_STRING([--with-csharp-compiler@<:@=PATH@:>@],
                             [set path to C# compiler @<:@default=autodetect@:>@]),
              [CSHARP_COMPILERBIN="$withval"], 
              [CSHARP_COMPILERBIN=])

  # First, check for "--with-csharp"
  if test "x${with_csharp}" != xno ; then

    CSHARP_PATH=""
    if test "x${with_csharp}" != xyes;  then
      CSHARP_PATH="$with_csharp:$with_csharp/bin"
    fi

    if test -z "$CSHARP_COMPILERBIN" ; then
      case $host in
      *-*-cygwin* | *-*-mingw*)
        # prefer Mono gmcs (.NET 2.0) over mcs (.NET 1.1) - note mcs-1.2.3 has major pinvoke bug
        if test -z "$CSHARP_PATH"; then
          AC_PATH_PROGS(CSHARP_COMPILER, csc gmcs2 gmcs mcs cscc)
        else
          AC_PATH_PROGS(CSHARP_COMPILER, csc gmcs2 gmcs mcs cscc, "", $CSHARP_PATH)
        fi
        if test -n "$CSHARP_COMPILER" && test "$CSHARP_COMPILER" = "csc" ; then
          AC_MSG_CHECKING(whether csc is the Microsoft CSharp compiler)
          csc 2>/dev/null | grep "C#" > /dev/null || CSHARP_COMPILER=""
          if test -z "$CSHARP_COMPILER" ; then
            AC_MSG_RESULT(no)
            if test -z "$CSHARP_PATH"; then
              AC_PATH_PROGS(CSHARP_COMPILER, gmcs2 gmcs mcs cscc)
            else
              AC_PATH_PROGS(CSHARP_COMPILER, gmcs2 gmcs mcs cscc, "", $CSHARP_PATH)
            fi
          else
            AC_MSG_RESULT(yes)
          fi
        fi
        ;;
      *)
        if test -z "$CSHARP_PATH"; then
          AC_PATH_PROGS(CSHARP_COMPILER, gmcs2 gmcs mcs cscc)
        else
          AC_PATH_PROGS(CSHARP_COMPILER, gmcs2 gmcs mcs cscc, "", $CSHARP_PATH)
        fi
        ;;
      esac
    else
      CSHARP_COMPILER="$CSHARP_COMPILERBIN"
    fi

    # check CSHARP_COMPILER 
    AC_MSG_CHECKING(whether $CSHARP_COMPILER exists)
    if test -f "$CSHARP_COMPILER" ; then
      AC_MSG_RESULT(yes)
    else
      AC_MSG_RESULT(no)
      AC_MSG_ERROR([CSharp Compiler $CSHARP_COMPILER does not exist.])
    fi

    CSHARP_COMPILER_NAME=`echo $CSHARP_COMPILER | sed 's,.*[[\/\\]],,' `

    CSHARP_PATHSEPARATOR="/"
    CSHARPCYGPATH_W=echo
    if test -z "$CSHARP_BIN" ; then
      CSHARP_CILINTERPRETER=""
      if test "cscc" = "$CSHARP_COMPILER_NAME" ; then
        if test -z "$CSHARP_PATH"; then
          AC_PATH_PROGS(CSHARP_CILINTERPRETER, ilrun)
        else
          AC_PATH_PROGS(CSHARP_CILINTERPRETER, ilrun, "", $CSHARP_PATH)
        fi
      else
        if test "mcs" = "$CSHARP_COMPILER_NAME"; then
          # Check that mcs is the C# compiler and not the Unix mcs utility by examining the output of 'mcs --version'
          # The Mono compiler should emit: Mono C# compiler version a.b.c.d
	  csharp_version_raw=`($CSHARP_COMPILER --version) 2>/dev/null`
          csharp_version_searched=`($CSHARP_COMPILER --version | sed -e "/C#/b" -e "/Mono/b" -e d) 2>/dev/null` # return string if contains 'Mono' or 'C#'
          CSHARP_COMPILER_NAME="";
          if test -n "$csharp_version_raw" ; then
            if test "$csharp_version_raw" = "$csharp_version_searched" ; then
              CSHARP_COMPILER_NAME="mcs"
            fi
          fi
          if test "mcs" != "$CSHARP_COMPILER_NAME" ; then
            echo "mcs is not a working Mono C# compiler"
          fi
        fi
        if test "mcs" = "$CSHARP_COMPILER_NAME" || test "gmcs" = "$CSHARP_COMPILER_NAME" || test "gmcs2" = "$CSHARP_COMPILER_NAME"; then
            if test -z "$CSHARP_PATH"; then
              AC_PATH_PROGS(CSHARP_CILINTERPRETER, mono) # Mono JIT
            else
              AC_PATH_PROGS(CSHARP_CILINTERPRETER, mono, "", $CSHARP_PATH) # Mono JIT
            fi
        else
          if test "csc" = "$CSHARP_COMPILER_NAME"; then
              CSHARP_PATHSEPARATOR="\\\\"
              CSHARPCYGPATH_W='cygpath -w'
          fi
        fi
      fi
    else
      CSHARP_CILINTERPRETER="$CSHARP_BIN"
    fi

    # check CSHARP_CILINTERPRETER
    AC_MSG_CHECKING(whether $CSHARP_CILINTERPRETER exists)
    if test -f "$CSHARP_CILINTERPRETER" ; then
      AC_MSG_RESULT(yes)
    else
      AC_MSG_RESULT(no)
      AC_MSG_ERROR([CSharp Compiler $CSHARP_CILINTERPRETER does not exist.])
    fi

    # set SN/GACUTIL
    if test -z "$CSHARP_PATH"; then
      AC_PATH_PROGS([SN], [sn])
      AC_PATH_PROGS([GACUTIL], [gacutil])
    else
      AC_PATH_PROGS([SN], [sn], "", $CSHARP_PATH)
      AC_PATH_PROGS([GACUTIL], [gacutil], "", $CSHARP_PATH)
    fi

    dnl
    dnl Check for possible binary 32/64-bit incompatbilities.
    dnl

    mono_version_raw=`($CSHARP_CILINTERPRETER --version) 2>/dev/null`
    case $host in
    *darwin*) 
      dnl MacOS 10.6 (Snow Leopard) makes 64-bit binaries by default.
      dnl MacOS 10.5 (Leopard) makes 32-bit binaries by default.
      dnl As of this time (2010-07-27), the off-the-shelf copies of 
      dnl Mono are 32-bit versions, but one could build a 64-bit version
      dnl from source.

      osx_major_ver=`uname -r | cut -f1 -d'.'`

      if test ${osx_major_ver} -ge 10; then
        dnl We're on MacOS 10.6, which makes 64-bit bins unless told not to.

        AC_MSG_CHECKING([whether this is a 64-bit version of mono])
        if echo $mono_version_raw | grep -q "x86_64"; then
          dnl Wow, this is a 64-bit version.  OK, good job, user.
          AC_MSG_RESULT([yes, impressive!])

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
The C# environment ($CSHARP_CILINTERPRETER) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The C# environment will be unable to load the resulting
libSBML libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 option or else add "-arch x86_64" to the arguments given to
the --enable-universal-binary option.
***************************************************************************
])
              else
                AC_MSG_ERROR([
***************************************************************************
The C# environment ($CSHARP_CILINTERPRETER) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The C# environment will be unable to load the resulting
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
  	  dnl mono reports being 32-bit, but we're on a 64-bit system.

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
because your C# environment ($CSHARP_CILINTERPRETER) is a 32-bit version.
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
because your C# environment ($CSHARP_CILINTERPRETER) is a 32-bit version.
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

        AC_MSG_CHECKING([whether this is a 64-bit version of mono])
        if echo $mono_version_raw | grep -q "x86_64"; then
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
because your C# environment ($CSHARP_CILINTERPRETER) is a 64-bit
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
because your C# environment ($CSHARP_CILINTERPRETER) is a 64-bit
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
          dnl Not a 64-bit mono, and we're on pre-MacOS 10.6.
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
because your C# environment ($CSHARP_CILINTERPRETER) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The C# environment will be unable to load the
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
because your C# environment ($CSHARP_CILINTERPRETER) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The C# environment environment will be unable to 
load the resulting libSBML libraries at run-time.  Please add ONE of the 
following options,
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

          AC_MSG_CHECKING([whether this is a 64-bit version of mono])
          if echo $mono_version_raw | egrep -q "x86_64|amd64"; then
            AC_MSG_RESULT([yes])

            dnl Did the user request a 32-bit libSBML?  Because that'd be bad.
            AC_MSG_CHECKING([whether only 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
You have requested building a 32-bit version of libSBML, but the C#
environment ($CSHARP_CILINTERPRETER) on this sytem is a 64-bit version.
The C# environment will be unable to load libSBML at run-time.
Please reconfigure libSBML WITHOUT the --enable-m32 option (or whatever
means you used to indicate 32-bit compilation in this instance).
***************************************************************************
])
            else
              AC_MSG_RESULT([no])
            fi
          else
            dnl Not a 64-bit version of mono, but this is still an x86_64.

            AC_MSG_RESULT([no])
            AC_MSG_CHECKING([whether 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, excellent])
            else
              AC_MSG_RESULT([no, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly as a 32-bit (i386) binary because 
your C# environment ($CSHARP_CILINTERPRETER) is a 32-bit version.  Please 
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


    dnl
    dnl Determine file extensions, compilation flags, and other things.
    dnl

    case $host in
    *-*-cygwin* | *-*-mingw*)
	# Cygwin requires the Windows standard (Pascal) calling convention
        # as it is a Windows executable and not a Cygwin built executable

        if test "$GCC" = yes; then
            CSHARP_LDFLAGS=" -mno-cygwin -mthreads -Wl,--add-stdcall-alias"
            CSHARP_CPPFLAGS="-mno-cygwin -mthreads"
        else
            CSHARP_LDFLAGS=""
            CSHARP_CPPFLAGS=""
        fi 
        CSHARP_EXT="dll"   
        CSHARP_SWIGFLAGS="-DSWIG_CSHARP_NO_WSTRING_HELPER"
        ;;
    *darwin*) 
        CSHARP_LDFLAGS="-bundle_loader \"${CSHARP_CILINTERPRETER}\""
        CSHARP_CPPFLAGS=""
        CSHARP_SWIGFLAGS=""
        CSHARP_EXT="dylib"   
        ;;
    *)
        CSHARP_LDFLAGS=""
        CSHARP_CPPFLAGS=""
        CSHARP_SWIGFLAGS=""
        CSHARP_EXT="so"   
        ;;
    esac

    dnl
    dnl enable --with-swig option if SWIG-generated files of C# bindings 
    dnl (libsbml_wrap.cpp and csharp-files/*.cs) need to be regenerated.
    dnl

    csharp_dir="src/bindings/csharp"

    if test "$with_swig" = "no" -o -z "$with_swig" ; then
      AC_MSG_CHECKING(whether SWIG is required for CSharp bindings.)
      if test ! -e "${csharp_dir}/libsbml_wrap.cpp" -o ! -d "${csharp_dir}/csharp-files" ; then
        with_swig="yes"
        AC_MSG_RESULT(yes)
      else
        if test "$enable_layout" = "no"; then
          if grep -q getListOfLayouts "${csharp_dir}/libsbml_wrap.cpp"; then
            with_swig="yes"
            AC_MSG_RESULT(yes)
          else
            AC_MSG_RESULT(no)
          fi
        else
          if grep -q getListOfLayouts "${csharp_dir}/libsbml_wrap.cpp"; then
            AC_MSG_RESULT(no)
          else
            with_swig="yes"
            AC_MSG_RESULT(yes)
          fi
        fi
      fi
    fi


    AC_DEFINE([USE_CSHARP], 1, [Define to 1 to use CSharp])
    AC_SUBST(USE_CSHARP, 1)

    AC_SUBST(CSHARP_COMPILER)
    AC_SUBST(CSHARP_CILINTERPRETER)
    AC_SUBST(CSHARP_CPPFLAGS)
    AC_SUBST(CSHARP_LDFLAGS)
    AC_SUBST(CSHARP_SWIGFLAGS)
    AC_SUBST(CSHARP_EXT)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_CSHARP"

])


