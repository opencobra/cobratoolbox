dnl
dnl Filename    : configure.ac
dnl Description : Run this file through autoconf to produce `configure'
dnl Author(s)   : SBML Team <sbml-team@caltech.edu>
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

dnl ---------------------------------------------------------------------------
dnl Autoconf initialization.
dnl
dnl Bug reports are sent to sbml-team@cds.caltech.edu
dnl ---------------------------------------------------------------------------

m4_define(LIBSBML_VERSION, m4_esyscmd_s(cat VERSION.txt))

dnl The AC_PREREQ macro can come before AC_INIT (but it's the only one).

AC_PREREQ([2.62])

AC_INIT([libSBML],
        [LIBSBML_VERSION],
        [libsbml-team@caltech.edu],
        [libsbml],
        [http://sbml.org/Software/libSBML])

AC_CONFIG_AUX_DIR(config)

AC_REVISION($Revision: 21538 $)

AC_CONFIG_SRCDIR(src/Makefile.in)

AC_CONFIG_HEADERS(src/sbml/common/libsbml-config-common.h)
AC_CONFIG_HEADERS(src/sbml/common/libsbml-package.h)
AC_CONFIG_HEADERS(src/sbml/common/libsbml-namespace.h)

LIBSBML_VERSION_NUMERIC=m4_esyscmd(cat VERSION.txt |\
  awk -F'.' '{ printf("%d%02d%02d\n", $1, $2, $3) }')
AC_SUBST(LIBSBML_VERSION_NUMERIC)

LIBSBML_MAJOR_VERSION=m4_esyscmd(cat VERSION.txt |\
  awk -F'.' '{ printf("%d\n", $1) }')
AC_SUBST(LIBSBML_MAJOR_VERSION)

LIBSBML_MINOR_VERSION=m4_esyscmd(cat VERSION.txt |\
  awk -F'.' '{ printf("%d\n", $2) }')
AC_SUBST(LIBSBML_MINOR_VERSION)

LIBSBML_REVISION_VERSION=m4_esyscmd(cat VERSION.txt |\
  awk -F'.' '{ printf("%d\n", $3) }')
AC_SUBST(LIBSBML_REVISION_VERSION)

LIBSBML_BETA_VERSION=m4_esyscmd(cat VERSION.txt |\
  awk -F'\\-' '{ printf("%s\n", $2) }')
AC_SUBST(LIBSBML_BETA_VERSION)


dnl ---------------------------------------------------------------------------
dnl Command-line options
dnl ---------------------------------------------------------------------------

dnl [2007-06-25] This is not currently functioning and may never be again.

dnl AC_ARG_ENABLE([memory-tracing],
dnl   AC_HELP_STRING([--enable-memory-tracing],
dnl                  [Enable memory tracing (default: disabled)]),
dnl     [enable_tracing=$withval],
dnl     [enable_tracing=no])

dnl if test "$enable_tracing" != no; then
dnl   AC_DEFINE([TRACE_MEMORY], 1,
dnl             [Define to 1 to enable primitive memory tracing.])
dnl fi

AC_ARG_ENABLE([cpp-namespace],
  AS_HELP_STRING([--enable-cpp-namespace@<:@=ARG@:>@],
                 [enable C++ namespace for libsbml @<:@default=no@:>@]),
  [enable_cpp_namespace=$enableval],
  [enable_cpp_namespace=no])

if test "$enable_cpp_namespace" != no; then
  AC_DEFINE([LIBSBML_USE_CPP_NAMESPACE], 1, [Define to 1 to enable C++ namespace.])
fi

dnl -------------------------------------------------------
dnl Extension plug-ins for SBML Level 3 packages.
dnl -------------------------------------------------------

AC_ARG_ENABLE([layout],
  AS_HELP_STRING([--enable-layout@<:@=ARG@:>@],
                 [build support for SBML 'layout' @<:@default=no@:>@]),
  [enable_layout=$enableval],
  [enable_layout=no])

if test "$enable_layout" != no; then
  AC_DEFINE([USE_LAYOUT], 1, [Define to 1 to build support for SBML 'layout'.])
  AC_DEFINE([LIBSBML_HAS_PACKAGE_LAYOUT], 1, [Define to 1 to build support for SBML 'layout'.])
  AC_SUBST(USE_LAYOUT, 1)
  AC_SUBST(LIBSBML_HAS_PACKAGE_LAYOUT, 1)
fi

AC_ARG_ENABLE([comp],
  AS_HELP_STRING([--enable-comp@<:@=ARG@:>@],
                 [build support for SBML 'comp' @<:@default=no@:>@]),
  [enable_comp=$enableval],
  [enable_comp=no])

if test "$enable_comp" != no; then
  AC_DEFINE([USE_COMP], 1, [Define to 1 to build support for SBML 'comp'.])
  AC_DEFINE([LIBSBML_HAS_PACKAGE_COMP], 1, [Define to 1 to build support for SBML 'comp'.])
  AC_SUBST(USE_COMP, 1)
  AC_SUBST(LIBSBML_HAS_PACKAGE_COMP, 1)
fi

AC_ARG_ENABLE([fbc],
  AS_HELP_STRING([--enable-fbc@<:@=ARG@:>@],
                 [build support for SBML 'fbc' @<:@default=no@:>@]),
  [enable_fbc=$enableval],
  [enable_fbc=no])

if test "$enable_fbc" != no; then
  AC_DEFINE([USE_FBC], 1, [Define to 1 to build support for SBML 'fbc'.])
  AC_DEFINE([LIBSBML_HAS_PACKAGE_FBC], 1, [Define to 1 to build support for SBML 'fbc'.])
  AC_SUBST(USE_FBC, 1)
  AC_SUBST(LIBSBML_HAS_PACKAGE_FBC, 1)
fi

AC_ARG_ENABLE([qual],
  AS_HELP_STRING([--enable-qual@<:@=ARG@:>@],
                 [build support for SBML 'qual' @<:@default=no@:>@]),
  [enable_qual=$enableval],
  [enable_qual=no])

if test "$enable_qual" != no; then
  AC_DEFINE([USE_QUAL], 1, [Define to 1 to build support for SBML 'qual'.])
  AC_DEFINE([LIBSBML_HAS_PACKAGE_QUAL], 1, [Define to 1 to build support for SBML 'qual'.])
  AC_SUBST(USE_QUAL, 1)
  AC_SUBST(LIBSBML_HAS_PACKAGE_QUAL, 1)
fi

dnl -------------------------------------------------------
dnl Other SBML L3 package variables
dnl -------------------------------------------------------

CONFIG_SBML_PACKAGE_VARS

dnl -------------------------------------------------------
dnl Compression
dnl -------------------------------------------------------

AC_ARG_ENABLE([compression],
  AS_HELP_STRING([--enable-compression@<:@=ARG@:>@],
                 [enable file compression if possible @<:@default=yes@:>@]),
  [enable_compression=$enableval],
  [enable_compression=yes])

if test "$enable_compression" != no; then
  AC_DEFINE([USE_COMPRESSION], 1, [Define to 1 to enable zlib/bzip2 file compression.])
  AC_SUBST(USE_COMPRESSION, 1)
fi

dnl ---------------------------------------------------------------------------
dnl LIBSBML_SHARED_VERSION
dnl ---------------------------------------------------------------------------

AC_ARG_ENABLE([shared-version],
  AS_HELP_STRING([--enable-shared-version@<:@=ARG@:>@],
                 [include version number into shared library @<:@default=yes@:>@]),
  [enable_shared_version=$enableval],
  [enable_shared_version=yes])

if test "$enable_shared_version" != no; then
  AC_DEFINE([LIBSBML_SHARED_VERSION], 1, [Define to 1 to include the version number in the shared library.])
  AC_SUBST(LIBSBML_SHARED_VERSION, 1)
fi

dnl ---------------------------------------------------------------------------
dnl LIBSBML_USE_LEGACY_MATH
dnl ---------------------------------------------------------------------------

AC_ARG_ENABLE([legacy-math],
  AS_HELP_STRING([--enable-legacy-math@<:@=ARG@:>@],
                 [use legacy AST math implementation @<:@default=no@:>@]),
  [enable_use_legacy_math=$enableval],
  [enable_use_legacy_math=no])

if test "$enable_use_legacy_math" != no; then
  AC_DEFINE([LIBSBML_USE_LEGACY_MATH], 1, [Define to 1 to use the legacy math AST implementation.])
  AC_SUBST(LIBSBML_USE_LEGACY_MATH, 1)
fi

dnl ---------------------------------------------------------------------------
dnl LIBSBML_USE_STRICT_INCLUDES
dnl ---------------------------------------------------------------------------

AC_ARG_ENABLE([strict-includes],
  AS_HELP_STRING([--enable-strict-includes@<:@=ARG@:>@],
                 [use strict .h inclusion rules @<:@default=no@:>@]),
  [enable_use_strict_includes=$enableval],
  [enable_use_strict_includes=no])

if test "$enable_use_strict_includes" != no; then
  AC_DEFINE([LIBSBML_USE_STRICT_INCLUDES], 1, [Define to 1 to use strict include rules for header files.])
  AC_SUBST(LIBSBML_USE_STRICT_INCLUDES, 1)
fi


dnl Other cmd-line options are defined in the individual .m4 files in the
dnl config/ subdirectory.


dnl ---------------------------------------------------------------------------
dnl Check host operating system, set some important flags accordingly, check
dnl for important configuration flags.
dnl ---------------------------------------------------------------------------

AC_CANONICAL_HOST

dnl CONFIG_BINARIES checks --enable-universal-binary, --enable-m32 and
dnl --enable-m64.  This must be done before DOLT, CONFIG_PLATFORM,
dnl AC_PROG_LIBTOOL, CONFIG_PROG_MATLAB, and possibly others below, because it
dnl sets CFLAGS.  A particularly important scenario is using --enable-m32 on
dnl a 64-bit platform, because without setting CFLAGS *before* attempting to 
dnl configure libtool, the libtool script that's created ends up using 64-bit
dnl link paths and options.  This leads to difficult-to-understand errors at
dnl compile/link-time.

CONFIG_BINARIES
CONFIG_PLATFORM

CONFIG_LDPATH


dnl ---------------------------------------------------------------------------
dnl Checks for various programs and packages.
dnl ---------------------------------------------------------------------------

AC_PROG_CXX
AC_PROG_CC
AC_PROG_CPP
AC_LIBTOOL_WIN32_DLL
AC_PROG_INSTALL
AC_PROG_MAKE_SET

AC_PATH_PROG([AUTOCONF],[autoconf],[autoconf])
AC_PATH_PROG([ACLOCAL],[aclocal],[aclocal])


dnl Check whether -Wno-long-double option is supported.
dnl
dnl (On MacOS X, compilation generates a warning about `long double'
dnl  with Python and Ruby bindings).

saved_CPPFLAGS=$CPPFLAGS
CPPFLAGS="-Wno-long-double"
AC_MSG_CHECKING([whether -Wno-long-double is supported])
AC_COMPILE_IFELSE(
  [AC_LANG_SOURCE([])],
  [AC_SUBST(HAS_GCC_WNO_LONG_DOUBLE, 1)
   AC_MSG_RESULT([yes])],
  [AC_MSG_RESULT([no])]
)
CPPFLAGS=$saved_CPPFLAGS


dnl The Lisp language binding has been removed for the time being, because
dnl it no longer works in recent versions of libSBML.

CONFIG_PROG_PYTHON
CONFIG_PROG_PERL
CONFIG_PROG_JAVA(1.5.0)
CONFIG_PROG_MATLAB
CONFIG_PROG_OCTAVE(2.9.7,2.9.7)
CONFIG_PROG_RUBY
CONFIG_PROG_CSHARP

dnl Make sure to test for SWIG after all of the language binding tests,
dnl because the language binding tests sometimes cause swig to be required.

CONFIG_PROG_SWIG(2.0.0)

dnl Make sure to test doxygen *after* java, because there's a dependency
dnl in CONFIG_PROG_DOXYGEN on whether --with-java was also given.

CONFIG_PROG_DOXYGEN(1.7.0,1.8.8)

dnl Do this one last, because some earlier config options may end up changing
dnl things like CFLAGS, which in turn affects the libtool script that the
dnl following stesp create.

AC_PROG_LIBTOOL
AC_SUBST(LIBTOOL)
DOLT


dnl ---------------------------------------------------------------------------
dnl Checks for libraries.
dnl ---------------------------------------------------------------------------

AC_LANG(C)

AC_CHECK_LIB(m, isnan)

CONFIG_LIB_EXPAT(1.95.8)
CONFIG_LIB_XERCES
if test "$with_expat" = "no" -a "$with_xerces" = "no"; then
  default_libxml="yes"
fi
CONFIG_LIB_LIBXML(2.6.16)

CONFIG_LIB_LIBCHECK(0.9.2)
CONFIG_LIB_ZLIB
CONFIG_LIB_BZ2


dnl ---------------------------------------------------------------------------
dnl Checks for header files.
dnl ---------------------------------------------------------------------------

AC_HEADER_STDC
AC_CHECK_HEADERS(errno.h)
AC_CHECK_HEADERS(math.h)
AC_CHECK_HEADERS(ieeefp.h)


dnl ---------------------------------------------------------------------------
dnl Checks for typedefs, structures, and compiler characteristics.
dnl ---------------------------------------------------------------------------

AC_C_BIGENDIAN
AC_C_CONST
AC_TYPE_SIZE_T
AC_EXEEXT
AC_OBJEXT


dnl ---------------------------------------------------------------------------
dnl Checks for Sun cc.
dnl ---------------------------------------------------------------------------

if ($CXX -V 2>&1 | grep 'Sun C++')  >/dev/null 2>/dev/null; then
  AC_SUBST(USE_SUN_CC, 1)
fi


dnl ---------------------------------------------------------------------------
dnl Miscellaneous
dnl ---------------------------------------------------------------------------

dnl Root directory
dnl Translate path for native Windows compilers for use with 'make check'

ROOT_DIR=`pwd`
case $host in
*-*-cygwin* | *-*-mingw*)
  if (cygpath --mixed $ROOT_DIR) >/dev/null 2>/dev/null; then
    ROOT_DIR=`cygpath --mixed $ROOT_DIR`
  fi
  # Extra files generated by some Windows compilers
  EXTRA_CLEAN="*.stackdump *.exp *.lib"
  ;;
esac

dnl In order to allow certain Makefile tests, we define a variable that
dnl stores a list of options available to configure.  This variable is
dnl added to by the configure options defined in config/ .m4 files.

AC_DEFINE(LIBSBML_OPTIONS)
AC_SUBST(LIBSBML_OPTIONS)


dnl ---------------------------------------------------------------------------
dnl Output
dnl ---------------------------------------------------------------------------

AC_CONFIG_FILES([config/makefile-common-vars.mk])
AC_CONFIG_FILES([config/lt_link_helper.sh], [chmod a+x config/lt_link_helper.sh])
AC_CONFIG_FILES([config/mkoctfile_wrapper.sh], [chmod a+x config/mkoctfile_wrapper.sh])
AC_CONFIG_FILES([config/chk_swig_version.sh], [chmod a+x config/chk_swig_version.sh])
AC_CONFIG_FILES([./Makefile])

AC_CONFIG_FILES([libsbml.spec])

AC_CONFIG_FILES([src/Makefile])

AC_CONFIG_FILES([src/sbml/common/Makefile])
AC_CONFIG_FILES([src/sbml/common/libsbml-version.h])

AC_CONFIG_FILES([src/bindings/Makefile])

AC_CONFIG_FILES([src/bindings/python/Makefile])
AC_CONFIG_FILES([src/bindings/python/setup.py])

AC_CONFIG_FILES([src/bindings/perl/Makefile])
AC_CONFIG_FILES([src/bindings/perl/Makefile.PL])

AC_CONFIG_FILES([src/bindings/matlab/Makefile])
AC_CONFIG_FILES([src/bindings/matlab/test/Makefile])

AC_CONFIG_FILES([src/bindings/octave/Makefile])
AC_CONFIG_FILES([src/bindings/octave/test/Makefile])

AC_CONFIG_FILES([src/bindings/java/Makefile])
AC_CONFIG_FILES([src/bindings/java/Manifest.txt])

dnl The Lisp language binding has been removed for the time being, because it
dnl no longer works in recent versions of libSBML.
dnl AC_CONFIG_FILES([src/bindings/java/Makefile])

AC_CONFIG_FILES([src/bindings/ruby/Makefile])

AC_CONFIG_FILES([src/bindings/csharp/Makefile])

AC_CONFIG_FILES([src/sbml/annotation/Makefile])
AC_CONFIG_FILES([src/sbml/annotation/test/Makefile])

AC_CONFIG_FILES([src/sbml/math/Makefile])
AC_CONFIG_FILES([src/sbml/math/test/Makefile])

AC_CONFIG_FILES([src/sbml/math-legacy/Makefile])
AC_CONFIG_FILES([src/sbml/math-legacy/test/Makefile])

AC_CONFIG_FILES([src/sbml/units/Makefile])
AC_CONFIG_FILES([src/sbml/units/test/Makefile])

AC_CONFIG_FILES([src/sbml/Makefile])
AC_CONFIG_FILES([src/sbml/test/Makefile])

AC_CONFIG_FILES([src/sbml/util/Makefile])
AC_CONFIG_FILES([src/sbml/util/test/Makefile])

AC_CONFIG_FILES([src/sbml/validator/Makefile])
AC_CONFIG_FILES([src/sbml/validator/constraints/Makefile])
AC_CONFIG_FILES([src/sbml/validator/test/Makefile])
AC_CONFIG_FILES([src/sbml/validator/test/test-data/Makefile])
AC_CONFIG_FILES([src/sbml/validator/test/test-data/sbml-general-consistency-constraints/Makefile])

AC_CONFIG_FILES([src/sbml/xml/Makefile])
AC_CONFIG_FILES([src/sbml/xml/test/Makefile])

AC_CONFIG_FILES([src/sbml/compress/Makefile])

AC_CONFIG_FILES([src/sbml/extension/Makefile])
AC_CONFIG_FILES([src/sbml/extension/test/Makefile])
AC_CONFIG_FILES([src/sbml/extension/RegisterExtensions.h])
AC_CONFIG_FILES([src/sbml/extension/RegisterExtensions.cxx])

AC_CONFIG_FILES([src/sbml/conversion/Makefile])
AC_CONFIG_FILES([src/sbml/conversion/test/Makefile])

AC_CONFIG_FILES([src/sbml/packages/Makefile])

if test -d src/sbml/packages/comp; then
if test "$enable_comp" != "no" ; then
  AC_CONFIG_FILES([src/sbml/packages/comp/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/common/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/extension/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/extension/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/sbml/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/sbml/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/util/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/util/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/validator/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/validator/constraints/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/validator/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/comp/validator/test/test-data/Makefile])
  AC_CONFIG_FILES([examples/c++/comp/Makefile])
  AC_CONFIG_FILES([examples/c/comp/Makefile])
fi
fi

if test -d src/sbml/packages/fbc; then
if test "$enable_fbc" != "no" ; then
  AC_CONFIG_FILES([src/sbml/packages/fbc/common/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/extension/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/extension/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/sbml/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/util/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/validator/constraints/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/validator/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/validator/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/fbc/validator/test/test-data/Makefile])
  AC_CONFIG_FILES([examples/c++/fbc/Makefile])
fi
fi

AC_CONFIG_FILES([src/sbml/packages/layout/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/common/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/extension/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/sbml/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/sbml/test/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/util/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/validator/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/validator/constraints/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/validator/test/Makefile])
AC_CONFIG_FILES([src/sbml/packages/layout/validator/test/test-data/Makefile])

if test -d src/sbml/packages/qual; then
if test "$enable_qual" != "no" ; then
  AC_CONFIG_FILES([src/sbml/packages/qual/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/common/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/extension/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/sbml/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/sbml/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/validator/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/validator/constraints/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/validator/test/Makefile])
  AC_CONFIG_FILES([src/sbml/packages/qual/validator/test/test-data/Makefile])
  AC_CONFIG_FILES([examples/c++/qual/Makefile])
fi
fi

AC_CONFIG_FILES([docs/Makefile])
AC_CONFIG_FILES([docs/index.html])
AC_CONFIG_FILES([docs/src/Makefile])
AC_CONFIG_FILES([docs/src/doxygen-config-c.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-cpp.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-csharp.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-octave.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-python.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-perl.txt])
AC_CONFIG_FILES([docs/src/doxygen-config-matlab.txt])
AC_CONFIG_FILES([docs/src/common-text/libsbml-downloading.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-group-comp-intro.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-group-fbc-intro.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-group-layout-intro.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-group-qual-intro.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-installation.html])
AC_CONFIG_FILES([docs/src/common-text/libsbml-version.html],
                [tr -d '\n' < docs/src/common-text/libsbml-version.html > libsbmlversiontmp;
		 mv libsbmlversiontmp docs/src/common-text/libsbml-version.html])
AC_CONFIG_FILES([docs/src/common-text/sbml-specifications-table.html])
AC_CONFIG_FILES([docs/src/java-substitutions/libsbmlConstants.java])

AC_CONFIG_FILES([examples/c/Makefile])
AC_CONFIG_FILES([examples/c++/Makefile])
AC_CONFIG_FILES([examples/java/Makefile])
AC_CONFIG_FILES([examples/csharp/Makefile])

if test "$enable_layout" != "no" ; then
  AC_CONFIG_FILES([examples/c++/layout/Makefile])
fi

if test -d dev; then
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/linux/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/linux/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/macos/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/macos/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/windows/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/windows/python/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/binaries/windows/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/experimental/source/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/linux/32-bit/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/linux/32-bit/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/linux/64-bit/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/linux/64-bit/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/linux/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/macos/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/macos/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/32-bit/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/32-bit/python/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/32-bit/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/64-bit/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/64-bit/python/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/64-bit/R_interface/README.md])
  AC_CONFIG_FILES([dev/misc-files/readmes-for-downloads-new-dir-struct/stable/windows/README.md])
fi

dnl ---------------------------------------------------------------------------
dnl package system files that include the layout package
dnl ---------------------------------------------------------------------------

AC_CONFIG_FILES([src/bindings/csharp/local-downcast-extension.i])
AC_CONFIG_FILES([src/bindings/csharp/local-downcast-namespaces.i])
AC_CONFIG_FILES([src/bindings/csharp/local-downcast-converters.i])
AC_CONFIG_FILES([src/bindings/csharp/local-packages.i])

AC_CONFIG_FILES([src/bindings/java/local-downcast-extension.i])
AC_CONFIG_FILES([src/bindings/java/local-downcast-namespaces.i])
AC_CONFIG_FILES([src/bindings/java/local-downcast-converters.i])
AC_CONFIG_FILES([src/bindings/java/local-packages.i])

AC_CONFIG_FILES([src/bindings/perl/local-downcast.cpp])
AC_CONFIG_FILES([src/bindings/perl/local-downcast-extension.cpp])
AC_CONFIG_FILES([src/bindings/perl/local-downcast-namespaces.cpp])
AC_CONFIG_FILES([src/bindings/perl/local-downcast-converters.cpp])
AC_CONFIG_FILES([src/bindings/perl/local-downcast-plugins.cpp])
AC_CONFIG_FILES([src/bindings/perl/local-packages.i])

AC_CONFIG_FILES([src/bindings/python/local-downcast.cpp])
AC_CONFIG_FILES([src/bindings/python/local-downcast-extension.cpp])
AC_CONFIG_FILES([src/bindings/python/local-downcast-namespaces.cpp])
AC_CONFIG_FILES([src/bindings/python/local-downcast-converters.cpp])
AC_CONFIG_FILES([src/bindings/python/local-downcast-plugins.cpp])
AC_CONFIG_FILES([src/bindings/python/local-packages.i])

AC_CONFIG_FILES([src/bindings/ruby/local-downcast.cpp])
AC_CONFIG_FILES([src/bindings/ruby/local-downcast-extension.cpp])
AC_CONFIG_FILES([src/bindings/ruby/local-downcast-namespaces.cpp])
AC_CONFIG_FILES([src/bindings/ruby/local-downcast-converters.cpp])
AC_CONFIG_FILES([src/bindings/ruby/local-downcast-plugins.cpp])
AC_CONFIG_FILES([src/bindings/ruby/local-packages.i])

AC_CONFIG_FILES([src/bindings/swig/libsbml-packages.h])
AC_CONFIG_FILES([src/bindings/swig/libsbml-packages.i])
  
dnl ---------------------------------------------------------------------------

AC_CONFIG_FILES([macosx/Makefile])
AC_CONFIG_FILES([macosx/build.sh], [chmod a+x macosx/build.sh])
AC_CONFIG_FILES([macosx/resources/package-intro.txt])
AC_CONFIG_FILES([macosx/resources/package-readme.txt])

AC_CONFIG_FILES([macosx/libsbml-package.pmdoc/01local-contents.xml])
AC_CONFIG_FILES([macosx/libsbml-package.pmdoc/01local.xml])
AC_CONFIG_FILES([macosx/libsbml-package.pmdoc/index.xml])

AC_OUTPUT


dnl ---------------------------------------------------------------------------
dnl Inform users of settings
dnl ---------------------------------------------------------------------------

dnl Gather up the values of the flags into one set of variables for easier
dnl printing below.

if test "$with_expat" != "no"; then
  xml_library="Expat"
  xml_cppflags=$EXPAT_CPPFLAGS
  xml_ldflags=$EXPAT_LDFLAGS
  xml_libs=$EXPAT_LIBS
elif test "$with_libxml" != "no" -o "$default_libxml" = "yes"; then
  xml_library="libxml2"
  xml_cppflags=$LIBXML_CPPFLAGS
  xml_ldflags=$LIBXML_LDFLAGS
  xml_libs=$LIBXML_LIBS
else
  xml_library="Xerces-C++"
  xml_cppflags=$XERCES_CPPFLAGS
  xml_ldflags=$XERCES_LDFLAGS
  xml_libs=$XERCES_LIBS
fi


dnl Simple helper functions used below.

print_whitespace()
{
  i=$1
  if test -n "$i"; then
    while expr $i \> 0 > /dev/null
    do 
      i=`expr $i - 1`; printf ' '
    done
  fi
}

print_flag()
{
  if test -n "$2" -a "$2" != "no"; then
    i=`expr 13 - ${#1}`
    printf "  Using $1 with path "
    print_whitespace $i
    if test -n "$4"; then
      /bin/echo -n "= $3"
    else
      echo "= $3"
    fi
  fi
  dnl
  dnl If there's a 4th arg, print it after everything else on the line.
  dnl 
  if test -n "$4"; then
    echo "  ($4)"
  fi
}


echo ""
echo "----------------------------------------------------------------------"
echo "${PACKAGE_NAME} version ${PACKAGE_VERSION}"
echo "----------------------------------------------------------------------"
echo ""
echo "More information and the latest version are available online at"
echo "http://sbml.org/Software/libSBML"
echo ""
echo "Please report problems using the issue tracker at"
echo "http://sbml.org/software/libsbml/issue-tracker"
echo ""
echo "To contact the developers directly, email libsbml-team@caltech.edu"
echo ""
echo "Configured on host \"`hostname`\""
echo "  host type                     = $HOST_TYPE"
echo "  host vendor                   = $host_vendor"
echo "  host operating system         = $host_os"
echo "  host CPU architecture         = $host_cpu"
echo ""
echo "General build flags:"
echo "  CC                            = $CC"
echo "  CXX                           = $CXX"
echo "  CPPFLAGS                      = $CPPFLAGS $ZLIB_CPPFLAGS $BZ2_CPPFLAGS"
echo "  CFLAGS                        = $CFLAGS"
echo "  CFLAGS_ARCH                   = $CFLAGS_ARCH"
echo "  CXXFLAGS                      = $CXXFLAGS"
echo "  CXXFLAGS_ARCH                 = $CXXFLAGS_ARCH"
echo "  LDFLAGS                       = $LDFLAGS $ZLIB_LDFLAGS $BZ2_LDFLAGS"
echo "  LDFLAGS_ARCH                  = $LDFLAGS_ARCH"
echo "  LIBS                          = $LIBS $ZLIB_LIBS $BZ2_LIBS"
echo ""
echo "XML parser library configuration:"
echo "  XML library                   = $xml_library"
echo "  CPPFLAGS for XML              = $xml_cppflags"
echo "  LDFLAGS for XML               = $xml_ldflags"
echo "  LIBS for XML                  = $xml_libs"
if test -n "$XML2_CONFIG"; then
  echo "  XML2_CONFIG                   = $XML2_CONFIG"
fi
echo ""
echo "Other ${PACKAGE_NAME} configuration settings:"
echo "  Installation \$prefix          = $prefix"

print_flag "libcheck"  	$with_libcheck	$with_check
print_flag "SWIG"   	$with_swig	$SWIG
print_flag "doxygen"    $with_doxygen   $DOXYGEN
print_flag "Java"   	$with_java	$JAVA
print_flag "Python" 	$with_python	$PYTHON
print_flag "Perl"   	$with_perl	$PERL
print_flag "MATLAB"   	$with_matlab	$MATLAB
print_flag "Octave"   	$with_octave	$OCTAVE
print_flag "Asdf"   	$EXT_ASDF	$ASDF
print_flag "UFFI"   	$EXT_UFFI	$UFFI
print_flag "Ruby"       $with_ruby      $RUBY
print_flag "CSharp"     $with_csharp    $CSHARP_CILINTERPRETER
print_flag "zlib"       $with_zlib      $with_zlib
print_flag "bzip2"      $with_bzip2     $with_bzip2

if test "$enable_cpp_namespace" != "no" ; then
  echo "  Using C++ namespace for libSBML (libsbml) = yes"
fi

echo ""
echo "Support for SBML packages:"

if test "$enable_comp" != "no" ; then
  echo "  SBML 'comp'                   = $enable_comp"
fi
if test "$enable_fbc" != "no" ; then
  echo "  SBML 'fbc'                    = $enable_fbc"
fi
if test "$enable_layout" != "no" ; then
  echo "  SBML 'layout'                 = $enable_layout"
fi
if test "$enable_qual" != "no" ; then
  echo "  SBML 'qual'                   = $enable_qual"
fi

echo ""
echo "Other potentially important settings:"
if test "$enable_univbinary" != "no"; then
  echo "  Building libSBML as MacOS universal binary."
fi

if test "$with_zlib" != "no"; then
  /bin/echo -n "  Compression support is enabled for .zip"
  if test "$with_bzip2" != "no"; then
    echo ", .gz and .bz2 files"
  else
    echo " and .gz files"
  fi
elif test "$with_bzip2" != "no"; then
  echo "  Compression support is enabled for .bz2 files"
fi

if test "$HOST_TYPE" = "darwin"; then
  echo "  Value of \$DYLD_LIBRARY_PATH   = $DYLD_LIBRARY_PATH"
else
  echo "  Value of \$LD_LIBRARY_PATH     = $LD_LIBRARY_PATH"
fi

if test -n "$with_java" -a "$with_java" != "no"; then
  echo "  Value of \$CLASSPATH for Java  = $CLASSPATH"  
fi

if test -n "$with_csharp" -a "$with_csharp" != "no"; then
  echo "  Using CSharp compiler = $CSHARP_COMPILER"
fi

dnl Print these warnings at the end so they're less likely to be overlooked.

if test "$with_zlib" = no -a "$with_bzip2" = no; then
  echo ""
  echo "Warning: reading/writing compressed SBML in this copy of libSBML"
  echo "is not supported or has not been enabled.  If this was not your"
  echo "intention, please check the --with-zlib, -with-bzip2, and/or"
  echo "--enable-compression options."
  echo ""
elif test "$with_zlib" = no; then
  echo ""
  echo "Warning: reading/writing compressed SBML in .gz and .zip format"
  echo "in this copy of libSBML is not supported or has been disabled."
  echo "If this was not your intention, please check the --with-zlib"
  echo "option."
  echo ""
elif test "$with_bzip2" = no; then
  echo ""
  echo "Warning: reading/writing compressed SBML in .bz2 format in"
  echo "this copy of libSBML is not supported or has been disabled."
  echo "If this was not your intention, please check the --with-bzip2"
  echo "option."
  echo ""
fi


dnl Temporarily unavailable anyway, so skip this for now:
dnl echo "  enable memory tracing? = $enable_tracing"

echo "----------------------------------------------------------------------"
echo ""
