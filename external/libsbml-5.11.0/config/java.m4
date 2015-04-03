dnl
dnl Filename    : java.m4
dnl Description : Autoconf macro to check for existence of Java
dnl Author(s)   : SBML Team <sbml-team@caltech.edu>
dnl Organization: California Institute of Technology
dnl Created     : 2004-07-07
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
dnl Supports --with-java[=PREFIX]
dnl

AC_DEFUN([CONFIG_PROG_JAVA],
[
  AC_ARG_WITH([java],
    AS_HELP_STRING([--with-java@<:@=PREFIX@:>@],
                   [generate Java interface library @<:@default=no@:>@]),
    [with_java=$withval],
    [with_java=no])

  AC_ARG_WITH(java-bin-check,
    AS_HELP_STRING([--without-jre-check], [disable checking for 32 vs. 64-bit JRE]),
          [  if test "x$withval" = "xno"; then
        bin_check_nonfatal=1
         fi
      ]
    )

  if test "$with_java" != "no"; then

    if test "$with_java" != "yes"; then
      dnl Users seems to have supplied a prefix directory path.  See if we can
      dnl find Java somewhere in the given tree.

      dnl 1st remove trailing slashes because it can confuse tests below.

      with_java=`echo $with_java | sed -e 's,\(.*\)/$,\1,g'`

      AC_PATH_PROG([JAVA], [java], [no], [$with_java/bin])
      AC_PATH_PROG([JAVAC], [javac], [no], [$with_java/bin])
      AC_PATH_PROG([JAR], [jar], [no], [$with_java/bin])
    else
      dnl No prefix directory path supplied for --with-java.  Use defaults.

      AC_PATH_PROG([JAVA], [java])
      AC_PATH_PROG([JAVAC], [javac])
      AC_PATH_PROG([JAR], [jar])
    fi

    dnl Sanity checks.

    if test -z "$JAVA" -o "$JAVA" = "no"; then
      AC_MSG_ERROR([Could not find a `java' executable.])
    fi
    if test -z "$JAVAC" -o "$JAVAC" = "no"; then
      AC_MSG_ERROR([Could not find a `javac' executable.])
    fi

    dnl Check version if required.

    m4_ifvaln([$1], [
      AC_MSG_CHECKING($JAVA version >= $1)

      changequote(<<, >>)

      rx=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      ry=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      rz=`echo $1 | sed -e 's/\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

      version=`"$JAVA" -version 2>&1 | sed -e 's/openjdk/java/' | sed -e 's/-internal//'| sed -e 's/\(.*\)$/\1/;q'`

      jx=`echo $version | sed -e 's/java version \"\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\1/'`
      jy=`echo $version | sed -e 's/java version \"\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\2/'`
      jz=`echo $version | sed -e 's/java version \"\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\).*/\3/'`

      changequote([, ])

      if test $jx -gt $rx \
         || (test $jx -eq $rx -a $jy -gt $ry) \
         || (test $jx -eq $rx -a $jy -eq $ry -a $jz -ge $rz); then
        AC_MSG_RESULT(yes (found $jx.$jy.$jz))
      else
        AC_MSG_RESULT(no)
        AC_MSG_ERROR([Need Java version $1, but only found version $jx.$jy.$jz.])
      fi

      dnl Retain these for use below.

      JAVA_VER_MINOR=$jy
      JAVA_VER_SUBMINOR=$jz

    ])

    dnl Look for the path to jni.h.

    dnl On some systems, what we first get as $JAVA or $JAVAC is a symlink.
    dnl We need to get to the real directory first.
    dnl (However, only do this if the user didn't request a specific path.)

    if test "$with_java" = "yes"; then
      while test -h "$JAVAC"; do
        dnl
        dnl This next case case statement does 2 things:
        dnl 1) On Ubuntu and maybe some other systems, following the symlinks
        dnl    gets us to /usr/bin/ecj, which is a shell script that invokes
        dnl    the actual executable.  This stumps our code trying to find
        dnl    the jni include directory.  The weak solution here is to
        dnl    detect when /usr/lib/jvm/* appears in the path at
        dnl    some point, which is the actual home under Ubuntu (and
        dnl    hopefully others) containing files we're looking for.
        dnl
        dnl 2) $javaclink may end up being a relative path (e.g.
        dnl    "/usr/bin/java" -> "../java/bin/java" on Solaris).  So, the
        dnl    value of javaclink must be appended to $JAVAC to construct an
        dnl    absolute path.
        dnl

        dnl "/usr/lib/jvm/java-gcj/bin/javac" might be initially set to JAVAC.
        case "$JAVAC" in
          /usr/lib/jvm/*)
            break
            ;;
          *)
            javaclink=`readlink "$JAVAC"`
            ;;
        esac

        case "$javaclink" in
          /*)
            JAVAC="$javaclink"
            ;;
          *)
            dnl 'X' avoids triggering unwanted echo options.
            JAVAC=`echo "X${JAVAC}" | sed -e 's/^X//' -e 's:[[^/]]*$::'`"$javaclink"
            ;;
        esac
      done
    fi

    dnl
    dnl Next, look for the JNI header files and related files.
    dnl

    case "$host" in
      *darwin*)
        framework="/System/Library/Frameworks/JavaVM.framework"
        case $JAVA_VER_MINOR in
          8)
            if test -e "$framework/Versions/Current/Headers"; then
              headers="$framework/Versions/Current/Headers"
            elif test -e "$framework/Versions/CurrentJDK/Headers"; then
              headers="$framework/Versions/CurrentJDK/Headers"
            fi
            ;;
          7)
            if test -e "$framework/Versions/Current/Headers"; then
              headers="$framework/Versions/Current/Headers"
            elif test -e "$framework/Versions/CurrentJDK/Headers"; then
              headers="$framework/Versions/CurrentJDK/Headers"
            elif test -e "$framework/Versions/1.7.0/Headers"; then
              headers="$framework/Versions/1.7.0/Headers"
            elif test -e "$framework/Versions/1.7/Headers"; then
              headers="$framework/Versions/1.7/Headers"
            fi
            ;;
          6)
            if test -e "$framework/Versions/Current/Headers"; then
              headers="$framework/Versions/Current/Headers"
            elif test -e "$framework/Versions/CurrentJDK/Headers"; then
              headers="$framework/Versions/CurrentJDK/Headers"
            elif test -e "$framework/Versions/1.6.0/Headers"; then
              headers="$framework/Versions/1.6.0/Headers"
            elif test -e "$framework/Versions/1.6/Headers"; then
              headers="$framework/Versions/1.6/Headers"
            fi
            ;;
          5)
            if test -e "$framework/Versions/CurrentJDK/Headers"; then
              headers="$framework/Versions/CurrentJDK/Headers"
            elif test -e "$framework/Versions/1.5.0/Headers"; then
              headers="$framework/Versions/1.5.0/Headers"
            elif test -e "$framework/Versions/1.5/Headers"; then
              headers="$framework/Versions/1.5/Headers"
            fi
            ;;
        esac

        if ! test -e "$headers/jni.h"; then
          if test $macosx_minor_vers -ge 9; then
            AC_MSG_ERROR([
Cannot find Java include files.  
Note that Mac OS X 10.9 (Mavericks) does not provide a JDK by default.
You may need to install Apple's "Java for OS X Developer Package"
distribution, which you can find by visiting http://developer.apple.com
and searching for "java", then selecting the most recent distribution.
At the time of this writing, the full name was "Java for OS X 2013-005
Developer Package".  As an alternative, you can try to use Oracle's
distribution of Java for Mac OS X.
])
          else
            AC_MSG_ERROR([
Cannot find Java include files. Your environment may lack a Java
development kit installation.
])
          fi
        fi

        JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"$headers\""

        parent=`dirname "$headers"`
        if test -e "$parent/Classes/classes.jar"; then
          JAVADOC_JAR="$parent/Classes/classes.jar"
        else
          JAVADOC_JAR="${parent}JDK/Classes/classes.jar"
        fi
      ;;

      *)
        parent=`dirname "$JAVAC"`

        if test -e "$parent/include/jni.h"; then
          headers="${parent}/include"
          JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"${headers}\""
        else

          dnl The ${parent} directory seems to be "bin" directory (e.g. "/usr/local/bin").
          dnl So, the parent's parent directory is checked below.

          parent=`dirname "${parent}"`

          if test -e "${parent}/include/jni.h"; then
            headers="${parent}/include"
            JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"${headers}\""
          else
        dnl Not there either.  Are we dealing with gcj?

        if `$JAVA -version 2>&1 | grep -q gcj`; then
          dnl Yes, gcj.  Try its special place.

              if test -d "/usr/lib/jvm/java-gcj/include"; then
                headers="/usr/lib/jvm/java-gcj/include"
                JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"${headers}\""
              else
                AC_MSG_ERROR([Cannot find Java include files.])
              fi
            else
              AC_MSG_ERROR([Cannot find Java include files.])
            fi
          fi
        fi

    dnl Some platforms have additional system-specific include dirs.

        case "$host_os" in
          *cygwin*) JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"$parent/include/win32\"";;
          freebsd*) JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"$parent/include/freebsd\"";;
          linux*)   JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"$parent/include/linux\"";;
          solaris*) JAVA_CPPFLAGS="$JAVA_CPPFLAGS -I\"$parent/include/solaris\"";;
        esac

        JAVADOC_JAR="$parent/lib/tools.jar"
      ;;
    esac

    dnl On MacOS X, JNI libraries loaded by Java need to be created as bundles.

    case $host in
    *darwin*)
    JAVA_LDFLAGS="${JAVA_LDFLAGS} -bundle_loader \"${JAVA}\""
    ;;
    *)
    JAVA_LDFLAGS=
    ;;
    esac

    dnl On MacOS X, the JNI library needs an oddball extension.

    case $host in
    *darwin*)
    JNIEXT="jnilib"
    JNIBASENAME="libsbmlj"
    ;;
    *cygwin*)
    JNIEXT="dll"
    JNIBASENAME="libsbmlj"
    ;;
    *)
    JNIEXT="so"
    JNIBASENAME="libsbmlj"
    ;;
    esac

    if test -z "$headers"; then
      AC_MSG_ERROR([Cannot find Java include files.])
    fi

    dnl
    dnl Check whether the JRE matches possible 32/64-bit options given
    dnl during configuration (such as telling configure --enable-m64 but
    dnl using a copy of Java that's only 32-bit).
    dnl

    if test -z "$bin_check_nonfatal"; then
      case $host in
      *darwin*)
        dnl MacOS 10.6 (Snow Leopard) makes 64-bit binaries by default.
        dnl MacOS 10.5 (Leopard) makes 32-bit binaries by default.

        osx_major_ver=`uname -r | cut -f1 -d'.'`

        if test ${osx_major_ver} -ge 10; then
          dnl We're on MacOS 10.6, which makes 64-bit bins unless told not to.

          AC_MSG_CHECKING([whether this is a 64-bit version of Java])
      BUILD_JAVA_DATA_TEST
          if test "`(cd ${srcdir}/config; $JAVA printJavaDataModel)`" = "64"; then
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
The Java run-time interpreter found at $JAVA
is a 64-bit version, but you have requested that libSBML be built as a
32-bit version.  The Java interpreter will be unable to load the resulting
libSBML JNI libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 option or else add "-arch x86_64" to the arguments given to
the --enable-universal-binary option.  If you are certain you want to
ignore this condition and proceed with the existing configuration anyway,
add --without-java-bin-check to the options for configure to bypass this
architecture check.
***************************************************************************
])
                else
                  AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 64-bit version, but you have requested that libSBML be built as a
32-bit version.  The Java interpreter will be unable to load the resulting
libSBML JNI libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32 or else add the option --enable-universal-binary.  If you are
certain that you want to proceed with the existing configuration anyway,
add --without-java-bin-check to the options for configure to bypass this
architecture check.
***************************************************************************
])
                fi
              fi
            else
              AC_MSG_RESULT([no])
            fi

          else
            AC_MSG_RESULT([no])
            dnl Java reports being 32-bit, but we're on a 64-bit system.

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
The Java run-time interpreter found at $JAVA
is a 32-bit version, but this version of MacOS X builds 64-bit binaries by
default.  The Java interpreter will be unable to load the resulting libSBML
JNI libraries at run-time.  Please reconfigure libSBML with the option
--enable-m32 or add "-arch i386" to the arguments to the
--enable-universal-binary option, and then recompile libSBML.  If you are
certain you want to ignore this condition and proceed with the existing
configuration anyway, add --without-java-bin-check to the options for
configure to bypass this architecture check.
***************************************************************************
])
                else
                  AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 32-bit version, but this version of MacOS X builds 64-bit binaries by
default.  The Java interpreter will be unable to load the resulting libSBML
JNI libraries at run-time.  Please reconfigure libSBML with the option
--enable-m32 or else use the --enable-universal-binary option, and then
recompile libSBML.  If you are certain that you want to proceed with the
existing configuration, add --without-java-bin-check to the options for
configure to bypass this architecture check.
***************************************************************************
])
                fi
              fi
            fi
          fi
        else
          dnl We're on pre-MacOS 10.6, which makes 32-bit bins by default,
          dnl but the underlying hardware is still 64-bit and 64-bit programs
          dnl can still be executed.

          AC_MSG_CHECKING([whether this is a 64-bit version of Java])
      BUILD_JAVA_DATA_TEST
          if test "`(cd ${srcdir}/config; $JAVA printJavaDataModel)`" = "64"; then
            AC_MSG_RESULT([yes])

            dnl Did the user request a 64-bit libSBML?  If not, it's a problem.
            AC_MSG_CHECKING([whether 64-bit libSBML binaries are being made])
            if echo $CFLAGS $CXXFLAGS | egrep -q "arch x86_64"; then
              AC_MSG_RESULT([yes])
            else
              AC_MSG_RESULT([no, and that's a problem])
              if test "x$enable_univbinary" != xno; then
                AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 64-bit version, but this operating system builds 32-bit binaries by
default.  The Java interpreter will be unable to load the resulting
libSBML JNI libraries at run-time.  Please add the string "-arch x86_64"
to the arguments to your --enable-universal-binary option, re-run the
configure step, and recompile.  If you are certain you want to ignore this
condition and proceed with the existing configuration anyway, add
--without-java-bin-check to the options for configure to bypass this
architecture check.
***************************************************************************
])
              else
                AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 64-bit version, but this operating system builds 32-bit binaries by
default.  The Java interpreter will be unable to load the resulting
libSBML JNI libraries at run-time.  Please add ONE of the following
options,
    --enable-m64
or
    --enable-universal-binary="-arch i386 -arch x86_64"
to your configure options, re-run the configure step, and recompile.  If
you are certain that you want to proceed with the existing configuration
anyway, add --without-java-bin-check to the options for configure to bypass
this architecture check.
***************************************************************************
])
              fi
            fi
          else
            AC_MSG_RESULT([no])
            dnl Did the user request a 64-bit libSBML?  If so, it's a problem.

            AC_MSG_CHECKING([whether only 64-bit libSBML binaries are being made])
            if echo $CFLAGS $CXXFLAGS | grep -q "arch x86_64"; then
              dnl On MacOSX, we might be making fat binaries.  Check that.
              if echo $CFLAGS $CXXFLAGS | grep -q "arch i386"; then
                AC_MSG_RESULT([no, which is good])
              else
                dnl Not making fat binaries, and we have a conflict.
                AC_MSG_RESULT([yes, and that's a problem])
                if test "x$enable_univbinary" != xno; then
                  AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 32-bit version, but you have explicitly requested only the creation
of a 64-bit libSBML.  The Java interpreter will be unable to load the
resulting libSBML JNI libraries at run-time.  Please add "-arch i386" to
the arguments to the --enable-universal-binary configure option (or
remove the --enable-universal-binary option), re-run the configure step,
and then recompile libSBML.  If you are certain you want to ignore this
condition and proceed with the existing configuration anyway, add
--without-java-bin-check to the options for configure to bypass this
architecture check.
***************************************************************************
])
                else
                  AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 32-bit version, but you have explicitly requested only the creation
of a 64-bit libSBML.  The Java interpreter will be unable to load the
resulting libSBML JNI libraries at run-time.  Please reconfigure WITHOUT
the --enable-m64 option (or whatever means you used to indicate 32-bit
compilation in this instance) and then recompile libSBML.  If you are
certain you want to ignore this condition and proceed with the existing
configuration anyway, add --without-java-bin-check to the options for
configure to bypass this architecture check.
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

          AC_MSG_CHECKING([whether JRE is a 64-bit version])
      BUILD_JAVA_DATA_TEST
          if test "`(cd ${srcdir}/config; $JAVA printJavaDataModel)`" = "64"; then
            AC_MSG_RESULT([yes])

            dnl Did the user request a 32-bit libSBML?  Because that'd be bad.
            AC_MSG_CHECKING([whether only 32-bit libSBML binaries are being made])
            if echo $CFLAGS $CXXFLAGS | egrep -q "m32"; then
              AC_MSG_RESULT([yes, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 64-bit version, but you have requested that libSBML be built as a
32-bit version.  The Java interpreter will be unable to load the resulting
libSBML JNI libraries at run-time.  Please reconfigure libSBML WITHOUT the
--enable-m32.  If you are certain that you want to proceed with the
existing configuration anyway, add --without-java-bin-check to the options
for configure to bypass this architecture check.
***************************************************************************
])
            else
              AC_MSG_RESULT([no])
            fi

          else
            AC_MSG_RESULT([no])
        dnl Java reports being 32-bit, but we're on a 64-bit system.

            AC_MSG_CHECKING([whether 32-bit libSBML binaries are being made])
            if echo $CFLAGS $CXXFLAGS | egrep -q "m32"; then
              AC_MSG_RESULT([yes, excellent])
            else
              AC_MSG_RESULT([no, and that's a problem])
              AC_MSG_ERROR([
***************************************************************************
The Java run-time interpreter found at $JAVA
is a 32-bit version, but this operating system builds 64-bit binaries by
default.  The Java interpreter will be unable to load the resulting libSBML
JNI libraries at run-time.  Please reconfigure libSBML with the option
--enable-m32.  If you are certain that you want to
proceed with the existing configuration, add --without-java-bin-check to
the options for configure to bypass this architecture check.
***************************************************************************
])
            fi
          fi
        fi
      ;;

      esac
    fi

    dnl
    dnl enable --with-swig option if SWIG-generated files of Java bindings
    dnl (libsbml_wrap.cpp and java-files/**/*.java) need to be regenerated.
    dnl

    java_dir="src/bindings/java"

    if test "$with_swig" = "no" -o -z "$with_swig" ; then
      AC_MSG_CHECKING(whether SWIG is required for Java bindings.)
      if test ! -e "${java_dir}/libsbml_wrap.cpp" -o ! -d "${java_dir}/java-files" ; then
        with_swig="yes"
        AC_MSG_RESULT(yes)
      else
        if test "$enable_layout" = "no"; then
          if grep -q getListOfLayouts "${java_dir}/libsbml_wrap.cpp"; then
            with_swig="yes"
            AC_MSG_RESULT(yes)
          else
            AC_MSG_RESULT(no)
          fi
        else
          if grep -q getListOfLayouts "${java_dir}/libsbml_wrap.cpp"; then
            AC_MSG_RESULT(no)
          else
            with_swig="yes"
            AC_MSG_RESULT(yes)
          fi
        fi
      fi
    fi

    dnl
    dnl Finally, set up our variables.
    dnl

    AC_DEFINE([USE_JAVA], 1, [Define to 1 to use Java])
    AC_SUBST(USE_JAVA, 1)

    AC_SUBST(JAVA_CPPFLAGS)
    AC_SUBST(JAVA_LDFLAGS)
    AC_SUBST(JNIEXT)
    AC_SUBST(JNIBASENAME)
    AC_SUBST(JAVADOC_JAR)

  fi

  dnl We record the USE_XXX flag, for later testing in Makefiles.

  LIBSBML_OPTIONS="$LIBSBML_OPTIONS USE_JAVA"

])

AC_DEFUN([BUILD_JAVA_DATA_TEST],
[
  rm -f ${srcdir}/config/printJavaDataModel.class
  $JAVAC ${srcdir}/config/printJavaDataModel.java
  if ! test -f ${srcdir}/config/printJavaDataModel.class; then
    AC_MSG_RESULT([can't compile Java test class])
    AC_MSG_ERROR([
***************************************************************************
We're sorry for the difficulty, but 'configure' attempted to compile a
small Java test class and failed for unknown reasons.  It is likely that
there is something wrong with your computer's Java JDK installation and
"javac" is unable to properly compile Java source code.  Perhaps the
problem is that only a JRE (Java Runtime Environment) and not a JDK (Java
Development Environment) is installed.  Please check the Java installation
on your system before proceeding further.

If you are certain that you have a properly configured and installed Java
JDK on your system, please use the libSBML issue tracker to file a report
that this problem has occurred, or else email libsbml-team@caltech.edu
directly, and please include the file "config.log".  (The file should have
been left at the top level of your libSBML source code directory.)  We will
attempt to debug the problem and improve 'configure' for future releases.

Finally, if you are certain that you have a properly configured and
installed Java JDK on your system, and you want to try skipping this test
and continue configuring and compiling libSBML with Java, add the option
--without-java-bin-check to 'configure' to bypass this architecture check.
***************************************************************************
])
  fi
])
