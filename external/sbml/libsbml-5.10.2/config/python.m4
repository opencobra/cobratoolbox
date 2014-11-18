dnl
dnl Filename    : python.m4
dnl Description : Autoconf macro to check for Python
dnl Author(s)   : SBML Team <sbml-team@caltech.edu>
dnl Organization: California Institute of Technology
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
dnl Provides --with-python[=PREFIX]
dnl

AC_DEFUN([CONFIG_PROG_PYTHON],
[
  AC_ARG_VAR([PYTHON])

  AC_ARG_WITH(python,
              AS_HELP_STRING([--with-python@<:@=PREFIX@:>@],
                             [generate Python interface library @<:@default=no@:>@]),
	      [with_python=$withval],
	      [with_python=no])

  AC_ARG_WITH(python-interpreter,
              AS_HELP_STRING([--with-python-interpreter@<:@=PATH@:>@],
                             [set path to Python interpreter @<:@default=autodetect@:>@]),
	      [PYTHON=$withval],
	      [PYTHON=no])

  if test $with_python != no; then

    dnl Find a python executable.

    python_dir=""

    if test "$PYTHON" != no ; then
      AC_MSG_CHECKING([whether $PYTHON exists])
      if test -f "$PYTHON" ; then
        AC_MSG_RESULT(yes)
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([$PYTHON does not exist.])
      fi
      if test $with_python != yes; then
        dnl User provided both --with-python and --with-python-interpreter
        dnl We will use the directory given by --with-python preferentially
        dnl for situations where we need a directory.  Note: because of the
        dnl way configure options are usually designed, the directory given
        dnl to --with-python should be the parent of the directory containing
        dnl a "bin" subdirectory that in turn contains the python binary. In
        dnl other words, people use things like --with-python=/usr/local
        if test -d "$with_python" ; then
          python_dir="$with_python/bin"
        else
          dnl Whatever they gave for --with-python is not a directory.
          dnl We'll use the directory from --with-python-interpreter.
          python_dir=`AS_DIRNAME(["$PYTHON"])`
        fi
      else
        dnl No --with-python provided.
        python_dir=`AS_DIRNAME(["$PYTHON"])`
      fi
    else    
      if test $with_python != yes; then
        dnl We're supposed to look for python in the given dir.
        dnl First remove trailing slashes because it can confuse later tests.
        with_python=`echo $with_python | sed -e 's,\(.*\)/$,\1,g'`
  
        AC_PATH_PROG([PYTHON], [python], [no], [$with_python/bin])
      else
        AC_PATH_PROG([PYTHON], [python])
      fi
      python_dir=`AS_DIRNAME(["$PYTHON"])`
    fi

    if test -z "$PYTHON" -o "$PYTHON" = "no" -o ! -f "$PYTHON";
    then
      AC_MSG_ERROR([*** cannot find python -- please install it or check config.log ***])
    fi

    dnl check version if required
    m4_ifvaln([$1], [
        AC_MSG_CHECKING([the version of "$PYTHON"])
        if test `"$PYTHON" -c ["import sys; print(sys.version[:3]) >= \"$1\" and \"OK\" or \"OLD\""]` = "OK"
        then
          AC_MSG_RESULT(ok)
        else
          AC_MSG_RESULT(no)
          AC_MSG_ERROR([*** python version too low -- libSBML requires $1 or later ***])
        fi
    ])

    AC_MSG_CHECKING(for Python prefix)
    PYTHON_PREFIX=`("$PYTHON" -c "import sys; print(sys.prefix)") 2>/dev/null`
    AC_MSG_RESULT($PYTHON_PREFIX)

    changequote(<<, >>)
    PYTHON_VERSION=`"$PYTHON" -c "import sys; print(sys.version[:3])"`
    changequote([, ])

    PYTHON_NAME="python$PYTHON_VERSION"

    dnl
    dnl Set PYTHON_CPPFLAGS. For this, don't rely on python-config --cflags.
    dnl The Apple-supplied /usr/bin/python*-config is wrong for our builds,
    dnl and the Macports version is sometimes wrong due to bugs.
    dnl

    AC_MSG_CHECKING([for Python include path])
    if test -z "$PYTHON_CPPFLAGS"; then
    	python_path=`$PYTHON -c "import distutils.sysconfig; \
            print (distutils.sysconfig.get_python_inc ());"`
    	if test -n "${python_path}"; then
            python_path="-I$python_path"
    	fi
    	PYTHON_CPPFLAGS=$python_path
    fi
    case $host in
    *darwin*)
        ;;
    *cygwin* | *mingw*) 
	PYTHON_CPPFLAGS="$PYTHON_CPPFLAGS -DUSE_DL_IMPORT"
        ;;
    *)
        ;;
    esac
    AC_MSG_RESULT([$PYTHON_CPPFLAGS])
    AC_SUBST([PYTHON_CPPFLAGS])

    dnl
    dnl Set LDFLAGS and get the list of libraries.
    dnl Our preferred approach is to use python-config, so we try that first.
    dnl

    if test -d "$python_dir" ; then
      AC_PATH_PROG([PYTHON_CONFIG], [${PYTHON_NAME}-config], [no], [$python_dir])
    else
      AC_PATH_PROG([PYTHON_CONFIG], [${PYTHON_NAME}-config])
    fi    

    if test -n "$PYTHON_CONFIG" ; then

      dnl
      dnl We have a python-config.
      dnl

      AC_MSG_CHECKING([$PYTHON_CONFIG --ldflags])
      PYTHON_LDFLAGS=`"$PYTHON_CONFIG" --ldflags`
      AC_MSG_RESULT([done])

      AC_MSG_CHECKING([$PYTHON_CONFIG --libs])
      PYTHON_LIBS=`"$PYTHON_CONFIG" --libs`
      AC_MSG_RESULT([done])

      dnl We cannot always trust the results.  Do some fix-ups.

      case $host in
      *darwin*) 
          dnl MacOS X note: this MUST remain .so, even though we use .dylib
          dnl for libsbml.

          PYTHON_EXT="so"

          dnl Some versions of python-config put -Wstrict-prototypes in the
          dnl cflags. Remove it, because it's not valid for C++ and leads to a
          dnl warning that could confuse people.

          PYTHON_CPPFLAGS=`echo $PYTHON_CPPFLAGS | sed -e 's/-Wstrict-prototypes//'`

          dnl Some distributions are broken: the value reported by
          dnl python-config --ldflags for the location of the library doesn't
          dnl contain the library that is named in python-config --libs.
          
          changequote(<<, >>)
          tmp_v=`"$PYTHON" -c "import sys; print(sys.version[:1])"`
          changequote([, ])

          AC_MSG_CHECKING([if we can trust $PYTHON_CONFIG --libs])
          if test $tmp_v -ge 3; then
            AC_MSG_RESULT([no, we're not using those values])

            tmp_e=`"$PYTHON" -c "from distutils import sysconfig; print(sysconfig.get_config_var('Py_ENABLE_SHARED'))"`
            tmp_sl=`"$PYTHON" -c "from distutils import sysconfig; print(sysconfig.get_config_var('SYSLIBS'))"`

            if test $tmp_e -eq 0; then
              tmp_pl=`"$PYTHON" -c "from distutils import sysconfig; print('-L' + sysconfig.get_config_var('LIBPL'))"`
              PYTHON_LDFLAGS="$tmp_pl $tmp_sl"
            else
              PYTHON_LDFLAGS="$tmp_sl"
            fi

            tmp_l=`"$PYTHON" -c "from distutils import sysconfig; print(sysconfig.get_config_var('LIBS'))"`
            PYTHON_LIBS="$tmp_l -lpython$PYTHON_VERSION"
          else
            AC_MSG_RESULT([yes, it's probably okay])
          fi

          dnl Some versions of macports python have dependencies on libraries 
          dnl in the installation directory, but don't put that dir on ldflags.

          if test $with_python != yes; then
            PYTHON_LDFLAGS="$PYTHON_LDFLAGS -L$with_python/lib"
          fi

          ;;
      *cygwin* | *mingw*) 
          PYTHON_EXT="dll"
          ;;
      *)
          PYTHON_EXT="so"
          ;;
      esac

    else

      dnl
      dnl Well, foo.  Can't find python-config; have to do this the hard way.
      dnl

      AC_MSG_WARN([No $PYTHON_CONFIG found -- we'll have to guess at the settings])
  
      dnl This is partially from SWIG 1.3.31's configure.ac file.
  
      case $host in
      *darwin*) 
          dnl Got an ugly situation on MacOS X: need different args depending
          dnl on whether the Python came from MacOS, Fink, or the Mac Python
          dnl from www.python.org.  The following uses a set of heuristics.
          dnl 1. If the python comes from /Library, assume it's Mac Python.
          dnl    Use the -framework flag.
          dnl 2. If it's from /System, assume it's the standard MacOS one.
          dnl    Use the -framework flag.
          dnl 3. If it's from anywhere else assume it's either the Fink
          dnl    version or something else, and don't use -framework.
  
          if test `expr "${PYTHON_PREFIX}" ':' '/Library/Frameworks/.*'` -ne 0; then
            dnl Assume Mac Python from www.python.org/download/mac
  
            PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib/${PYTHON_NAME}/lib-dynload -F/Library/Frameworks -framework Python"
  
          elif test `expr "${PYTHON_PREFIX}" ':' '/System/Library/Frameworks/.*'` -ne 0; then
            dnl MacOSX-installed version of Python (we hope).
  
            PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib/${PYTHON_NAME}/lib-dynload -F/System/Library/Frameworks -framework Python"
  
          else
            macosx_version=`sw_vers -productVersion | cut -d"." -f1,2` 
            if test ${macosx_version} '>' 10.2; then
              dnl According to configure.in of Python source code, -undefined
              dnl dynamic_lookup should be used for 10.3 or later. Actually,
              dnl the option is needed to avoid undefined symbols error when
              dnl building a Python binding library with non-system-installed
              dnl Python on 10.3 or later.  Also, according to the man page of
              dnl ld, environment variable MACOSX_DEPLOYMENT_TARGET must be set
              dnl to 10.3 or higher to use -undefined dynamic_lookup.
              dnl Currently, the environment variables is set in
              dnl src/binding/python/Makefile.in.
    
              PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib/${PYTHON_NAME}/lib-dynload -undefined dynamic_lookup"
  
            else
              dnl Fink-installed version of Python, or something else.
  
              PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib/${PYTHON_NAME}/lib-dynload -bundle_loader ${PYTHON}"
  
            fi
          fi
  
          dnl MacOS X note: this MUST remain .so even though we use .dylib for libsbml.
          PYTHON_EXT="so"
          ;;
      *cygwin* | *mingw*) 
          PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib${LIBSUFFIX}/${PYTHON_NAME}/config"
          PYTHON_LIBS="-l${PYTHON_NAME}"
          PYTHON_EXT="dll"
          ;;
      *)
          PYTHON_LDFLAGS="-L${PYTHON_PREFIX}/lib${LIBSUFFIX}/${PYTHON_NAME}/config"
          PYTHON_LIBS="-l${PYTHON_NAME}"
          PYTHON_EXT="so"
          ;;
      esac
  
    fi  
  
    dnl
    dnl Add the library path to LDPATH too.
    dnl
    case $host in
    *darwin*) 
        CONFIG_ADD_LDPATH(${PYTHON_PREFIX}/lib/${PYTHON_NAME}/lib-dynload)
        ;;
    *cygwin* | *mingw*) 
        CONFIG_ADD_LDPATH(${PYTHON_PREFIX}/lib${LIBSUFFIX}/${PYTHON_NAME}/config)
        ;;
      *)
        CONFIG_ADD_LDPATH(${PYTHON_PREFIX}/lib${LIBSUFFIX}/${PYTHON_NAME}/config)
        ;;
    esac

    dnl
    dnl Check for possible binary 32/64-bit incompatbilities.
    dnl

    python_platform=`("$PYTHON" -c "import platform; print(platform.platform())") 2>/dev/null`

    case $host in
    *darwin*) 
      dnl MacOS 10.6 (Snow Leopard) makes 64-bit binaries by default.
      dnl MacOS 10.5 (Leopard) makes 32-bit binaries by default.

      osx_major_ver=`uname -r | cut -f1 -d'.'`

      if test ${osx_major_ver} -ge 10; then
        dnl We're on MacOS 10.6, which makes 64-bit bins unless told not to.

        AC_MSG_CHECKING([whether this is a 64-bit version of Python])
        if echo $python_platform | grep -q "64bit"; then
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
The Python environment ($PYTHON) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The Python environment will be unable to load the resulting
libSBML libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 option or else add "-arch x86_64" to the arguments given to
the --enable-universal-binary option.
***************************************************************************
])
              else
                AC_MSG_ERROR([
***************************************************************************
The Python environment ($PYTHON) on this system is
a 64-bit version, but you have requested that libSBML be built as a 32-bit
version.  The Python environment will be unable to load the resulting
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
          dnl Python reports being 32-bit, but we're on a 64-bit system.

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
because your copy of Python ($PYTHON) is a 32-bit version.
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
because your copy of Python ($PYTHON) is a 32-bit version.
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

        AC_MSG_CHECKING([whether this is a 64-bit version of Python])
        if echo $python_platform | grep -q "64bit"; then
          AC_MSG_RESULT([yes])

          dnl Did the user request a 64-bit libSBML?  If not, it's a problem.
          AC_MSG_CHECKING([whether 64-bit libSBML binaries are being made])
          if echo $CFLAGS $CXXFLAGS | egrep -q "arch x86_64"; then
            AC_MSG_RESULT([yes, you are clever!])
          else
            AC_MSG_RESULT([no, and that's a problem])
            if test "x$enable_univbinary" != xno; then
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly to include a 64-bit (x86_64) version, 
because your copy of Python ($PYTHON) is a 64-bit
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
because your copy of Python ($PYTHON) is a 64-bit
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
          dnl Not a 64-bit Python, and we're on pre-MacOS 10.6.
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
because your copy of Python ($PYTHON) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The Python environment will be unable to load the
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
because your copy of Python ($PYTHON) is a 32-bit
version; however, you have explicitly requested only the creation 
of a 64-bit libSBML.  The Python environment will be unable to load the
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

          AC_MSG_CHECKING([whether this is a 64-bit version of Python])
          if echo $python_platform | grep -q "x86_64"; then
            AC_MSG_RESULT([yes])

            dnl Did the user request a 32-bit libSBML?  Because that'd be bad.
            AC_MSG_CHECKING([whether only 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
You have requested building a 32-bit version of libSBML, but the version of 
Python ($PYTHON) found on this sytem is a 64-bit version.
The Python environment will be unable to load libSBML at run-time.
Please reconfigure libSBML WITHOUT the --enable-m32 option (or whatever
means you used to indicate 32-bit compilation in this instance).
***************************************************************************
])
            else
              AC_MSG_RESULT([no])
            fi
          else
            dnl Not a 64-bit version of Python, but this is still an x86_64.

            AC_MSG_RESULT([no])
            AC_MSG_CHECKING([whether 32-bit libSBML binaries are being made])
            if echo $CXXFLAGS $CFLAGS | grep -q "m32"; then
              AC_MSG_RESULT([yes, excellent])
            else
              AC_MSG_RESULT([no, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
LibSBML needs to be built explicitly as a 32-bit (i386) binary because 
your copy of Python ($PYTHON) is a 32-bit version.  Please 
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
    dnl enable --with-swig option if SWIG-generated files of Python bindings
    dnl (libsbml_wrap.cpp and libsbml.py) need to be regenerated.
    dnl

    python_dir="src/bindings/python"

    if test "$with_swig" = "no" -o -z "$with_swig" ; then
      AC_MSG_CHECKING(whether SWIG is required for Python bindings.)
      if test ! -e "${python_dir}/libsbml_wrap.cpp" -o ! -e "${python_dir}/libsbml.py" ; then
        with_swig="yes"
        AC_MSG_RESULT(yes)
      else
        if test "$enable_layout" = "no"; then
          if grep -q getListOfLayouts "${python_dir}/libsbml_wrap.cpp"; then
            with_swig="yes"
            AC_MSG_RESULT(yes)
          else
            AC_MSG_RESULT(no)
          fi
        else
          if grep -q getListOfLayouts "${python_dir}/libsbml_wrap.cpp"; then
            AC_MSG_RESULT(no)
          else
            with_swig="yes"
            AC_MSG_RESULT(yes)
          fi
        fi
      fi
    fi

    AC_DEFINE([USE_PYTHON], 1, [Define to 1 to use Python])
    AC_SUBST(USE_PYTHON, 1)

    AC_SUBST(PYTHON_CPPFLAGS)
    AC_SUBST(PYTHON_LDFLAGS)
    AC_SUBST(PYTHON_LIBS)
    AC_SUBST(PYTHON_EXT)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_PYTHON"

])

