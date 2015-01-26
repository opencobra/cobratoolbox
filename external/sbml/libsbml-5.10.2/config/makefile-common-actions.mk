## Filename    : makefile-common-actions.mk
## Description : Makefile include file containing common actions
## Author(s)   : SBML Team <sbml-team@caltech.edu>
## Organization: California Institute of Technology
## Created     : 2004-06-17
##
##<!---------------------------------------------------------------------------
## This file is part of libSBML.  Please visit http://sbml.org for more
## information about SBML, and the latest version of libSBML.
##
## Copyright (C) 2013-2014 jointly by the following organizations:
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##     3. University of Heidelberg, Heidelberg, Germany
##
## Copyright (C) 2009-2013 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
##  
## Copyright (C) 2006-2008 by the California Institute of Technology,
##     Pasadena, CA, USA 
##  
## Copyright (C) 2002-2005 jointly by the following organizations: 
##     1. California Institute of Technology, Pasadena, CA, USA
##     2. Japan Science and Technology Agency, Japan
## 
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation.  A copy of the license agreement is provided
## in the file named "LICENSE.txt" included with this software distribution
## and also available online as http://sbml.org/software/libsbml/license.html
##----------------------------------------------------------------------- -->*/

# General explanations: 
#
# The rules in this file are meant to be generic and included in other
# makefiles.  This file is meant to be included last by other makefiles.
#
# As a general rule, variables with names in all lower-case letters (such
# as `cxxcompile') are assumed to be defined by the enclosing makefile,
# while those in all upper-case letters (such as `TOP_SRCDIR') are assumed
# to be defined in `makefile-common-vars.mk' which in turn must be included
# by the enclosing makefile.


# -----------------------------------------------------------------------------
# Common compilation rules for object files and libraries.
# -----------------------------------------------------------------------------

.SUFFIXES:
.SUFFIXES: .a .so .dylib .jnilib .c .h .cpp .hpp .cs .o .lo .la .obj .Po .py .pyc .pyo .i .bundle .rb .t

# The following define default values of variables like `cxxcompile'.  An
# enclosing makefile can define other values, in which case those
# definitions will override what's given here.

top_include := $(TOP_SRCDIR)/src
top_src     := $(TOP_SRCDIR)/src

default_includes ?= -I. -I$(top_include)

# Compiling under cygwin and Sun cc doesn't need -fPIC.

ifneq "$(HOST_TYPE)" "cygwin"
  ifndef USE_SUN_CC
    FPIC = -fPIC
  endif
endif

# Compiling under Sun cc must not use -Wall.

ifndef USE_SUN_CC
  WALL = -Wall
endif

# Here follow the generic compilation commands.  (Note: the use of 'sort'
# here is only to remove duplicates, which the 'sort' function does as a
# documented side-effect.)

compile ?= $(LIBTOOL) --mode=compile --tag=CC $(CC) $(sort $(default_includes) $(INCLUDES)) $(CPPFLAGS) \
        $(extra_CPPFLAGS) $(CFLAGS) $(extra_CFLAGS) 

cxxcompile ?= $(LIBTOOL) --mode=compile --tag=CXX $(CXX) $(sort $(default_includes) $(INCLUDES)) \
        $(CPPFLAGS) $(extra_CPPFLAGS) $(CXXFLAGS) $(extra_CXXFLAGS) 

# The following two commands are used for dependency tracking only when 
# building universal binaries on MacOSX.

compile_nocflags ?= $(CC) $(sort $(default_includes) $(INCLUDES)) \
        $(CPPFLAGS) $(extra_CPPFLAGS) 

cxxcompile_nocxxflags ?= $(CXX) $(sort $(default_includes) $(INCLUDES)) \
        $(CPPFLAGS) $(extra_CPPFLAGS) \

# For linking libraries, we try to follow the result of the libtool
# numbering scheme, but at the final end, not in the input format.  (The
# libtool input format is peculiar to us.)  Curious, this makes the
# numbering very easy: it's a direct mapping of the libsbml version number.

library_version = $(shell echo $(PACKAGE_VERSION) | sed -e 's/\-.*//g' -e 's/[a-zA-Z]//g' )
library_major_version = $(word 1, $(subst ., ,$(library_version)))
library_minor_version = $(word 2, $(subst ., ,$(library_version)))
library_patch_version = $(word 3, $(subst ., ,$(library_version)))

# `platform_link_flags' is used below in the definition of link_shared_lib.
# Generally, gcc and ld need -shared, but some systems think different.

ifeq "$(HOST_TYPE)" "darwin"
  # MacOS X's normal libraries have the extension .dylib, and "bundles"
  # have .so.  The default shared library definition here builds .dylib.
  platform_link_flags ?= -dynamiclib -flat_namespace \
	-current_version $(library_version)

  #
  # -M options are not allowed with multiple -arch flags.
  # 
  match = $(shell echo $(compile) | grep '\-arch.*\-arch.*')
  ifneq "$(match)" ""
    USE_UNIVBINARY = 1
  endif

  match = $(shell echo $(cxxcompile) | grep '\-arch.*\-arch.*')
  ifneq "$(match)" ""
    USE_UNIVBINARY = 1
  endif 
else
  #
  # -no-undefined option is required to generate a *.dll file
  # by using libtool on Cygwin  
  #
  ifeq "$(HOST_TYPE)" "cygwin" 
    platform_link_flags ?= -no-undefined
  else
    ifeq "$(HOST_TYPE)" "aix5.3.0.0" 
      platform_link_flags ?= -G
    else
      ifdef USE_SUN_CC
        platform_link_flags ?= -G
      else
        platform_link_flags ?= -shared
      endif
    endif
  endif
endif


# The following defines the default function for linking objects into a
# shared library. It gets used thus: $(call link_shared_lib,ARGS...).  The
# forms $(1), $(2) in the expressions below, etc. are the arguments passed
# to the call.  An enclosing makefile can provide another definition, in
# which case, the definition below will not be used.

#    -version-info $(subst .,:,$(library_version)) \

ifndef link_shared_lib
  define link_shared_lib 
    $(LIBTOOL) --mode=link $(CXX) $(extra_LDFLAGS) $(LDFLAGS) \
    -version-info \
    `expr $(library_major_version) \+ $(library_minor_version)`:$(library_patch_version):$(library_minor_version) \
    -inst-prefix-dir "$(DESTDIR)" \
    $(platform_link_flags) -rpath $(LIBDIR) -o $(1) $(objfiles:.o=.lo) \
    $(extra_LIBS) $(LIBS)
  endef
endif

ifndef link_dl_lib
  define link_dl_lib
    $(TOP_SRCDIR)/config/lt_link_helper.sh $(CXX) --libdir $(LIBDIR) \
    $(LDFLAGS) $(extra_LDFLAGS) $(platform_link_flags) \
    -o $(1) $(objfiles:.o=.lo) $(extra_LIBS) $(LIBS)
  endef
endif

# The following defines the default function for linking objects into a
# static library. It gets used thus: $(call link_static_lib,ARGS...).  The
# forms $(1), $(2) in the expressions below, etc. are the arguments passed
# to the call.  An enclosing makefile can provide another definition, in
# which case the definition below will not be used.

ifdef USE_SUN_CC
  define link_static_lib
    -rm -f $(1)
   $(CXX) -xar -o $(1) $(objfiles)
  endef
else
  define link_static_lib
    -rm -f $(1)
    $(AR) -cru $(1) $(objfiles)
    $(RANLIB) $(1)
  endef
endif

# Most of the sources are a mix of C and C++ files.  They have separate
# extensions, and simply using something like $(sources:.cpp=.o) doesn't
# work for converting the source file names into object file names because
# you have to do it twice (once each for .cpp and .c) and then you have to
# filter the results.  This abstracts out this common operation.

make_objects_list = \
  $(filter %.lo,\
    $(patsubst %.cpp,%.lo,$(1)) $(patsubst %.c,%.lo,$(1)))

# The following generate the list of object file names and dependency file
# names from the list of source files.  They're used for the generic
# compilation rules further below.

tmplist  ?= $(sources:.cpp=.lo) $(sources:.c=.lo)
objfiles ?= $(filter %.lo,$(tmplist))

# This next line includes the dependency files.  This uses a wildcard on
# the actual files, so that if they don't exist yet, `make' won't generate
# errors about being unable to include such-and-such file.  If the files
# are missing, the wildcard will expand to nothing.  The /dev/null at the
# end makes sure that we don't have an empty `include' line.

include $(wildcard $(DEPDIR)/*.$(DEPEXT)) /dev/null

# The next set of rules are generic for creating .a, .so, and other styles
# of static and shared library files.

ifneq "$(HOST_TYPE)" "aix"
# Both shared and static libraries in AIX have the same extension (.a).
# We have to choose what's built.  Shared is more likely to be preferred,
# so we leave out this rule for static libraries when building under AIX.

%.a ../%.a: $(objfiles)
	$(call link_static_lib,$@)

endif

%.la ../%.la: $(objfiles)
	$(call link_shared_lib,$@)

%.$(SHAREDLIBEXT) ../%.$(SHAREDLIBEXT): $(objfiles)
	$(call link_dl_lib,$@)

%.$(JNIEXT) ../%.$(JNIEXT): $(objfiles)
	$(call link_dl_lib,$@)

#
# -install_name option should be used when building an universal binary on MacOSX.
#
#%.$(SHAREDLIBEXT) ../%.$(SHAREDLIBEXT): $(objfiles)
#ifeq "$(HOST_TYPE)" "darwin"
#	$(call link_shared_lib,$@ -install_name $@)
#else
#	$(call link_shared_lib,$@)
#endif

# The following define generic rules for creating object files.

ifeq "$(HOST_TYPE)" "aix"

.c.lo:
	$(compile) -c -o $@ $<

.c.obj:
	if $(compile) -c -o $@ \
	  `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(srcdir)/$<'; fi`; \
	then mv "$(DEPDIR)/$*.Tpo" "$(DEPDIR)/$*.$(DEPEXT)"; \
	else rm -f "$(DEPDIR)/$*.Tpo"; exit 1; \
	fi

.cpp.lo .cxx.lo:
	$(cxxcompile) -c -o $@ $<

.cpp.obj:
	if $(cxxcompile) -c -o $@ \
	  `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(srcdir)/$<'; fi`; \
	then mv "$(DEPDIR)/$*.Tpo" "$(DEPDIR)/$*.$(DEPEXT)"; \
	else rm -f "$(DEPDIR)/$*.Tpo"; exit 1; \
	fi

else
# All hosts types that are not aix.

.c.lo:
ifndef USE_UNIVBINARY
  ifdef USE_SUN_CC
	$(compile) -c -o $@ $<
  else
	$(compile) -MT $@ -MD -MP -MF "$(DEPDIR)/$*.$(DEPEXT)" -c -o $@ $<
  endif
else
	$(compile_nocflags) -MT $@ -MM -MP -MF "$(DEPDIR)/$*.$(DEPEXT)" $<
	$(compile) -c -o $@ $<
endif

.c.obj:
	if $(compile) -MT $@ -MD -MP -MF "$(DEPDIR)/$*.Tpo" \
	  -c -o $@ `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(srcdir)/$<'; fi`; \
	then mv "$(DEPDIR)/$*.Tpo" "$(DEPDIR)/$*.$(DEPEXT)"; \
	else rm -f "$(DEPDIR)/$*.Tpo"; exit 1; \
	fi

.cpp.lo .cxx.lo:
ifndef USE_UNIVBINARY
  ifdef USE_SUN_CC
	$(cxxcompile) -c -o $@ $<
  else
	$(cxxcompile) -MT $@ -MD -MP -MF "$(DEPDIR)/$*.$(DEPEXT)" -c -o $@ $<
  endif
else
	$(cxxcompile_nocxxflags) -MT $@ -MM -MP -MF "$(DEPDIR)/$*.$(DEPEXT)" $<
	$(cxxcompile) -c -o $@ $<
endif

.cpp.obj:
	if $(cxxcompile) -MT $@ -MD -MP -MF "$(DEPDIR)/$*.Tpo" \
	  -c -o $@ `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(srcdir)/$<'; fi`; \
	then mv "$(DEPDIR)/$*.Tpo" "$(DEPDIR)/$*.$(DEPEXT)"; \
	else rm -f "$(DEPDIR)/$*.Tpo"; exit 1; \
	fi

endif

ifeq "$(HOST_TYPE)" "darwin"

%.bundle ../%.bundle: $(objfiles)
	$(call link_dl_lib,$@)

endif

# This next line ensures that the object output directory is created first.
# Got this from a posting by Paul D. Smith to gnu.utils.help, 2001-12-03.

__dummy := $(shell [ -d $(DEPDIR) ] || mkdir $(DEPDIR))


# -----------------------------------------------------------------------------
# Generic default.
# -----------------------------------------------------------------------------

default: $(objfiles) $(test_objfiles) $(libraries)


# -----------------------------------------------------------------------------
# Generic recursive targets.
# -----------------------------------------------------------------------------

recursive_targets = all-recursive include-recursive install-data-recursive \
	install-exec-recursive installdirs-recursive install-recursive \
	uninstall-recursive uninstall-info-recursive install-info-recursive \
	ps-recursive info-recursive dvi-recursive pdf-recursive \
	check-recursive installcheck-recursive mostlyclean-recursive \
	clean-recursive distclean-recursive maintainer-clean-recursive \
	install-man-recursive tags-recursive etags-recursive ctags-recursive \
	docs-recursive install-docs-recursive \
	dist-recursive distcheck-recursive

# Always want -w in the flags passed to recursive makes, so that it prints
# the current directory at each step.

ifeq "$(findstring $(MAKEFLAGS),-w)" ""
  MAKEFLAGS := $(MAKEFLAGS) -w
endif

# Notes about the following:
#
# include-recursive is split out as a separate target, so that
# it is not made to depend on $(subdirs) targets.  Instead, if
# include-recursive is a command, a separate set of logic below
# causes a 'make include' to be performed in $(subdirs)

$(filter-out include-recursive,$(recursive_targets)): subdirs

subdirs_recurse = $(addsuffix -recurse,$(subdirs))

subdirs: $(subdirs_recurse)

$(subdirs_recurse): 
ifneq "$(MAKEFLAGS)" ""
	$(MAKE) -C $(subst -recurse,,$@) -$(MAKEFLAGS) $(MAKECMDGOALS)
else
	$(MAKE) -C $(subst -recurse,,$@) $(MAKECMDGOALS)
endif

# Now here's the separate logic for include-recursive:

subdirs_recurse_inc = $(addsuffix -recurse-inc,$(subdirs))

include-recursive: $(subdirs_recurse_inc)

$(subdirs_recurse_inc): 
ifneq "$(MAKEFLAGS)" ""
	$(MAKE) -C $(subst -recurse-inc,,$@) -$(MAKEFLAGS) include
else
	$(MAKE) -C $(subst -recurse-inc,,$@) include
endif


# -----------------------------------------------------------------------------
# Running checks.
# -----------------------------------------------------------------------------

# This depends on $(check_driver) and $(test_objfiles) to have been defined
# in the including Makefile.

# 2010-04-26: if you build libSBML as a universal binary with x86_64 support
# on MacOS 10.5, "make check" may fail because not all the libraries needed
# by an executable are available in 64-bit form on the system.  We have to
# drop down to 32-bit in that case.  Conversely, on 10.6, MacOS ships with
# 64-bit binaries for (it seems) everything, and builds 64-bit executables
# by default.  

filtered_cflags   = $(shell echo '$(CFLAGS)'   | sed -e "s/-arch x86_64//g")
filtered_cppflags = $(shell echo '$(CPPFLAGS)' | sed -e "s/-arch x86_64//g")
filtered_ldflags  = $(shell echo '$(LDFLAGS)'  | sed -e "s/-arch x86_64//g")

$(check_driver): $(test_objfiles)
ifndef USE_UNIVBINARY
	$(LIBTOOL) --mode=link $(CXX) $(extra_CPPFLAGS) $(extra_CXXFLAGS) \
	  $(default_includes) $(CPPFLAGS) $(CFLAGS) $(INCLUDES) \
	  $(test_objfiles) $(objfiles) $(extra_LDFLAGS) $(LDFLAGS) \
	  $(LIBS) $(extra_LIBS) -o $@
else
	@version=`uname -r | awk -F. '{print $$1}'`;\
	if test $$version -ge 10; then \
	  cflags="$(CFLAGS)"; \
	  cppflags="$(CPPFLAGS)"; \
	  ldflags="$(LDFLAGS)"; \
        else \
	  cflags="$(filtered_cflags)";\
	  cppflags="$(filtered_cppflags)";\
	  ldflags="$(filtered_ldflags)";\
	fi; \
	$(LIBTOOL) --mode=link $(CXX) $(extra_CPPFLAGS) $(extra_CXXFLAGS) \
	  $(default_includes) $$cppflags $$cflags $(INCLUDES) \
	  $(test_objfiles) $(objfiles) $(extra_LDFLAGS) $$ldflags \
	  $(LIBS) $(extra_LIBS) -o $@
endif

run-checks: $(check_driver) $(libraries)
	@echo
	@echo
	@echo Running Tests in $(thisdir)
	@echo -----------------------------------------------------------------
	@$(call libsbmlrun,./$(check_driver))
	@echo -----------------------------------------------------------------
	@echo

# Utility function for reconstructing test files using translateTests.pl
# This is called by some sub-makefiles in src/bindings.  The arguments are:
#   (1) a letter, 'p' for Python, 'j' for Java, 'r' for Ruby, 'c' for C#
#   (2) a list of directories in src/* (e.g., "xml sbml math annotation")
#   (3) the root of the output directory where to write the translated tests

translateTests = $(TOP_SRCDIR)/dev/utilities/translateTests/translateTests.pl

define test_translator
  for d in $(2); do \
    list="$(top_src)/$$d/test/*.c $(top_src)/$$d/test/*.cpp"; \
    for file in $$list; do \
      $(translateTests) -$(1) -o $(3)/$$d $$file; \
    done; \
  done; 
endef


# -----------------------------------------------------------------------------
# Installation
# -----------------------------------------------------------------------------

# It doesn't look like you can usefully strip binary libraries at installation
# time on Darwin.  The man page for 'strip' says you'd have to do it as 'ld -s'
# to really make it work, but you don't want to strip the library that's built
# in the source tree -- you only want to strip the copy that gets installed
# in the destination directory.  So, we do the following conditional, until
# we can figure out something better.

ifneq "$(HOST_TYPE)" "darwin"
  install_strip = strip -S
else
  install_strip = echo
endif

# The following defines a macro that is invoked like this:
# $(call install_library,$(libname),$(dest))

define install_library
  $(MKINSTALLDIRS) $(DESTDIR)$(LIBDIR)
  $(LIBTOOL) --mode=install $(INSTALL_SH) $(1) $(DESTDIR)$(LIBDIR)
endef

to_install_libraries = $(addprefix install-,$(libraries))

$(to_install_libraries): $(libraries) installdirs
	$(call install_library,$(subst install-,,$@),$(DESTDIR)$(LIBDIR))

install-libraries: $(libraries) $(to_install_libraries)

# 'install_includes takes one argument, the root of the destination directory.

define install_includes
  @file="$(1)"; \
  targetdir="$(2)"; \
  if test -n '$(INCLUDEPREFIX)'; then \
    targetdir="$$targetdir/$(INCLUDEPREFIX)"; \
  fi; \
  if test -n '$(header_inst_prefix)'; then \
    targetdir="$$targetdir/$(header_inst_prefix)"; \
  fi; \
  $(MKINSTALLDIRS) $$targetdir; \
  if test -f $$file || test -d $$file; then d=.; else d=$(srcdir); fi; \
  dir=`echo "$$file" | sed -e 's,/[^/]*$$,,'`; \
  if test "$$dir" != "$$file" && test "$$dir" != "."; then \
    dir="/$$dir"; \
    $(MKINSTALLDIRS) $$targetdir/$$dir; \
  else \
    dir=''; \
  fi; \
  if test -d $$d/$$file; then \
    if test -d $(srcdir)/$$file && test $$d != $(srcdir); then \
      echo Copying $(srcdir)/$$file; \
      $(INSTALL_SH) -m 644 $(srcdir)/$$file $$targetdir$$dir || exit 1; \
    fi; \
    $(INSTALL_SH) -m 644 $$d/$$file $$targetdir$$dir || exit 1; \
  else \
    echo Copying $$targetdir/$$file; \
    $(INSTALL_SH) -m 644 $$d/$$file $$targetdir/$$file || exit 1; \
  fi;
endef

to_install_headers = $(addprefix install-,$(headers))

$(to_install_headers): $(headers) installdirs
	$(call install_includes,$(subst install-,,$@),$(DESTDIR)$(INCLUDEDIR))

install-headers: $(headers) $(to_install_headers)

# The following is for the copy of the include directory created in the root
# of the libsbml source tree.

include_root = $(subst //,/,$(TOP_SRCDIR)/include/$(INCLUDEPREFIX)/$(header_inst_prefix)/)

include: $(addprefix $(include_root),$(headers))

$(addprefix $(include_root),$(headers)): $(headers)
	$(call install_includes,$(@F),$(TOP_SRCDIR)/include)

#
# And now, code for uninstalling.
#

# The following defines a macro that is invoked like this:
# $(call install_library,$(libname),$(dest))

# The goofiness involving find ... -empty is because rmdir will fail if the
# directory's not empty, and we can't count on the host system having a
# version of GNU rmdir with its --ignore-fail-on-non-empty flag.  This
# is just a more portable way of detecting whether a directory is empty.

define uninstall_library
  @if test -f $(1); then \
    finalname="$(notdir $(basename $(1)))$(suffix $(1)).$(library_version)"; \
    target="$(2)/$$finalname"; \
    if test -f $$target ; then \
      echo rm $$target; \
      rm $$target; \
    fi; \
    target="$(2)/$(notdir $(1))"; \
    if test -L $$target ; then \
      echo rm $$target; \
      rm $$target; \
    fi; \
    if test -f $$target ; then \
      echo rm $$target; \
      rm $$target; \
    fi; \
  else \
    if test -d $(2) && test -n "`find $(2) -maxdepth 0 -empty`"; then \
      echo rmdir $(2); \
      rmdir $(2); \
    fi; \
  fi; \
  if test -n "`find $(DESTDIR)$(LIBDIR) -maxdepth 0 -empty`"; then \
    echo rmdir "$(DESTDIR)$(LIBDIR)"; \
    rmdir "$(DESTDIR)$(LIBDIR)"; \
  else \
    echo "Directory $(DESTDIR)$(LIBDIR) not empty; leaving it alone"; \
  fi;
endef

to_uninstall_libraries = $(addprefix uninstall-,$(libraries))

$(to_uninstall_libraries): 
	$(call uninstall_library,$(subst uninstall-,,$@),$(DESTDIR)$(LIBDIR))

uninstall-libraries: $(to_uninstall_libraries)

# 'install_includes takes one argument, the root of the destination directory.

define uninstall_includes
  @file="$(1)"; \
  targetdir="$(2)"; \
  if test -n '$(INCLUDEPREFIX)'; then \
    targetdir="$$targetdir/$(INCLUDEPREFIX)"; \
  fi; \
  if test -n '$(header_inst_prefix)'; then \
    targetdir="$$targetdir/$(header_inst_prefix)"; \
  fi; \
  if test -f $$file || test -d $$file; then d=.; else d=$(srcdir); fi; \
  dir=`echo "$$file" | sed -e 's,/[^/]*$$,,'`; \
  if test "$$dir" != "$$file" && test "$$dir" != "."; then \
    dir="/$$dir"; \
  else \
    dir=''; \
  fi; \
  if test -f $$targetdir/$$file; then \
    echo rm $$targetdir/$$file; \
    rm $$targetdir/$$file; \
  elif test -d $$targetdir/$$file; then \
    if test -n "`find $$targetdir/$$file -empty`"; then \
      echo rmdir $$targetdir/$$file; \
      rmdir $$targetdir/$$file; \
    else \
      echo "Directory $$targetdir/$$file not empty; leaving it alone"; \
    fi; \
  fi; \
  if test -d $$targetdir; then \
    if test -n "`find $$targetdir -maxdepth 0 -empty`"; then \
      echo rmdir $$targetdir; \
      rmdir $$targetdir; \
    fi; \
  fi;
endef

to_uninstall_headers = $(addprefix uninstall-,$(headers))

$(to_uninstall_headers): $(headers) 
	$(call uninstall_includes,$(subst uninstall-,,$@),$(DESTDIR)$(INCLUDEDIR))

uninstall-headers: $(headers) $(to_uninstall_headers)


# -----------------------------------------------------------------------------
# Creating distribution (for libSBML maintainers only)
# -----------------------------------------------------------------------------

# The `dist-normal' case uses the list of files and diretories in
# $(distfiles) and mirrors their structure in $(DISTDIR)/$(thisdir)/,
# except that files and directories that are also listed in
# $(distfile_exclude) are not copied.

# The $(sort ...) removes duplicates.

sortedfiles = $(sort $(distfiles))

dist-normal: DESTINATION := $(DISTDIR)/$(thisdir)
dist-normal: $(distfiles)
	$(shell [ -d $(DESTINATION) ] || mkdir -p $(DESTINATION))
	@list='$(sortedfiles)'; for file in $$list; do \
	  exlist='$(distfiles_exclude)'; for ex in $$exlist; do \
	    if test $$file = $$ex; then continue 2; fi; \
          done; \
	  if test -f $$file || test -d $$file; then d=.; else d=$(srcdir); fi; \
	  dir=`echo "$$file" | sed -e 's,/[^/]*$$,,'`; \
	  if test "$$dir" != "$$file" && test "$$dir" != "."; then \
	    dir="/$$dir"; \
	    $(MKINSTALLDIRS) "$(DESTINATION)/$$dir"; \
	  elif test -d "$$dir"; then \
	    $(MKINSTALLDIRS) "$(DESTINATION)/$$dir"; \
	  else \
	    dir=''; \
	  fi; \
	  if test -d $$d/$$file; then \
	    if test -d $(srcdir)/$$file && test $$d != $(srcdir); then \
	      echo Copying $(srcdir)/$$file; \
	      cp -r $(srcdir)/$$file $(DESTINATION)/$$dir || exit 1; \
	    fi; \
	    cp -r $$d/$$file $(DESTINATION)/$$dir || exit 1; \
	  else \
	    echo Copying $(DESTINATION)/$$file; \
	    test -f $(DESTINATION)/$$file \
	    || cp -r $$d/$$file $(DESTINATION)/$$file \
	    || exit 1; \
	  fi; \
	done

#	      $(INSTALL_SH) --mode="u+X,g+X,o+X" $(srcdir)/$$file $(DESTINATION)/$$dir || exit 1; \
#	    $(INSTALL_SH) -d $$d/$$file $(DESTINATION)/$$dir || exit 1; \
#	    || $(INSTALL_SH) --mode="u+X,g+X,o+X" $$d/$$file $(DESTINATION)/$$file \


# -----------------------------------------------------------------------------
# Cleaning
# -----------------------------------------------------------------------------

# This tries to follow the recommended GNU make guidelines.

# Although we don't explicitly use libtool in the hand-written libSBML
# makefiles, the cleaning targets for libtool are included below in case
# someone ever decides to use libtool as part of some make actions.

mostlyclean:        clean-generic mostlyclean-libtool
mostlyclean-normal: clean-generic mostlyclean-libtool

clean:        mostlyclean clean-libraries clean-libtool clean-extras clean-deps
clean-normal: mostlyclean clean-libraries clean-libtool clean-extras clean-deps

clean-generic:
	-rm -f *.$(OBJEXT) *.lo core *.core

clean-libtool:
	-rm -rf .libs _libs

clean-deps:
	-test -z "./$(DEPDIR)" || rm -rf ./$(DEPDIR)

ifdef libraries
  clean-libraries:
	-test -z "$(libraries)" || rm -f $(libraries)
else
  clean-libraries:
endif

ifdef extra_clean
  clean-extras:
	-test -z "$(extra_clean)" || rm -rf $(extra_clean)
else
  clean-extras:
endif

mostlyclean-libtool:
	-rm -f *.lo *.la *.loT

distclean: clean distclean-compile distclean-generic \
	distclean-tags distclean-libtool
distclean-normal: clean distclean-compile distclean-generic \
	distclean-tags distclean-libtool

distclean-compile:
	-rm -f *.tab.c

distclean-generic:
	-rm -f Makefile
ifdef extra_distclean
	-rm -rf $(extra_distclean)
endif

distclean-tags:
	-rm -f TAGS CTAGS ID GTAGS GRTAGS GSYMS GPATH tags

distclean-libtool:
	-rm -f libtool

maintainer-clean:        distclean maintainer-clean-generic
maintainer-clean-normal: distclean maintainer-clean-generic

maintainer-clean-generic:
	-rm -rf $(extra_maintainer_clean)


# -----------------------------------------------------------------------------
# Miscellaneous definitions.
# -----------------------------------------------------------------------------

# The following is for running shell commands with the right XX_LIBRARY_PATH
# variable set for different platforms.

ifeq "$(HOST_TYPE)" "darwin"

  define libsbmlrun
	env DYLD_LIBRARY_PATH=".:$(RUN_LDPATH):$(DYLD_LIBRARY_PATH)" srcdir=$(realpath .) $(LIBTOOL) -dlopen $(TOP_BUILDDIR)/src/libsbml.la --mode=execute $(1)
  endef

else

  define libsbmlrun
	env LD_LIBRARY_PATH=".:$(RUN_LDPATH):$(LD_LIBRARY_PATH)" srcdir=$(realpath .) $(LIBTOOL) -dlopen $(TOP_BUILDDIR)/src/libsbml.la --mode=execute $(1)
  endef

endif


# -----------------------------------------------------------------------------
# Common dependency rules.
# -----------------------------------------------------------------------------
# These rules ensure that files like makefiles are recreated when
# dependencies change.  The rules are generic enough that they apply to the
# top-level source directory as well as the source subdirectories.

Makefile: Makefile.in $(TOP_SRCDIR)/configure \
	     $(TOP_SRCDIR)/config/makefile-common-vars.mk
	cd $(TOP_BUILDDIR) && $(SHELL) ./config.status $(thisdir)/$@

$(TOP_SRCDIR)/config/makefile-common-vars.mk: \
	     $(TOP_SRCDIR)/config/makefile-common-vars.mk.in \
	     $(TOP_SRCDIR)/configure
	cd $(TOP_BUILDDIR) && $(SHELL) ./config.status config/makefile-common-vars.mk

$(TOP_SRCDIR)/config.status: $(TOP_SRCDIR)/configure $(TOP_SRCDIR)/VERSION.txt
	$(SHELL) ./config.status --recheck

$(TOP_SRCDIR)/configure: \
	     $(TOP_SRCDIR)/configure.ac \
	     $(TOP_SRCDIR)/VERSION.txt \
	     $(TOP_SRCDIR)/VERSION_PACKAGES.ac \
	     $(ACLOCAL_M4) \
	     $(wildcard $(TOP_SRCDIR)/config/*.m4)
	cd $(TOP_SRCDIR) && $(AUTOCONF) -Wall --force
	cd $(TOP_SRCDIR) && $(SHELL) ./config.status --recheck

$(ACLOCAL_M4): $(ACINCLUDE_M4) 
	cd $(TOP_SRCDIR) && $(ACLOCAL) -I config

$(TOP_SRCDIR)/config/chk_swig_version.sh: $(TOP_SRCDIR)/configure \
	    $(TOP_BUILDDIR)/config.status \
	    $(TOP_BUILDDIR)/config/chk_swig_version.sh.in
	cd $(TOP_BUILDDIR) && $(SHELL) ./config.status config/chk_swig_version.sh


# -----------------------------------------------------------------------------
# Tags files.
# -----------------------------------------------------------------------------

# 2006-08-09 <mhucka@caltech.edu> Previously I had it create tags in each
# source directory separately, but that turns out to be very inconvenient
# when using tags.  The new formulation is designed to create only one tags
# file, recursively looking in subdirectories for source files to use as
# input.  This is therefore really only meant to be used in the libsbml
# 'src' directory.

etags-version-check: 
	@if test -z "`$(ETAGS) --version 2>&1 | grep 'Free Software'`"; then \
	  echo "Your 'etags' command is not the GNU [X]Emacs version,"; \
	  echo "and I'm afraid I don't know how to work with it. Quitting."; \
	  exit 2; \
	fi

ctags-version-check: 
	@if test -z "`$(CTAGS) --version 2>&1 | grep 'Free Software'`"; then \
	  echo "Your 'ctags' command is not the GNU version, and"; \
	  echo "I'm afraid I don't know how to work with it. Quitting."; \
	  exit 2; \
	fi

etags: etags-version-check TAGS
ctags: ctags-version-check CTAGS

etags-command ?= $(ETAGS) $(ETAGSFLAGS)
ctags-command ?= $(CTAGS) $(CTAGSFLAGS)

files-to-tag := $(shell find . -name '*.c' -o -name '*.cpp' -o -name '*.h')

TAGS: $(files-to-tag)
	$(etags-command) $(files-to-tag)

CTAGS: $(files-to-tag)
	$(ctags-command) $(files-to-tag)


# -----------------------------------------------------------------------------
# Common special targets.
# -----------------------------------------------------------------------------

.PHONY: $(recursive_targets) CTAGS GTAGS docs all all-am check check-am \
	include clean clean-generic clean-libtool ctags \
	dist dist-all dist-gzip distcheck distclean \
	distclean-generic distclean-libtool distclean-tags distcleancheck \
	distdir distuninstallcheck dvi dvi-am info info-am \
	install install-am install-data install-data-am \
	install-exec install-exec-am install-info install-info-am \
	install-man install-strip installcheck installcheck-am installdirs \
	installdirs-am maintainer-clean maintainer-clean-generic mostlyclean \
	mostlyclean-generic mostlyclean-libtool \
	pdf pdf-am ps ps-am tags uninstall uninstall-am uninstall-info-am \
	clean-extras subdirs $(subdirs_recurse) subdist subdistcheck

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:


# -----------------------------------------------------------------------------
# End.
# -----------------------------------------------------------------------------

## The following is for [X]Emacs users.  Please leave in place.
## Local Variables:
## mode: Makefile
## End:
