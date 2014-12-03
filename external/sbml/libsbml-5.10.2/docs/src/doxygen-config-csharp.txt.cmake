# @configure_input@
# -----------------------------------------------------------------------------
# File name         : doxyfile-config-cpp.txt
# Description       : Doxygen config for C# libSBML API manual 
# Original author(s): Michael Hucka <mhucka@caltech.edu>
# Original author(s): Frank T. Bergmann <fbergman@caltech.edu>
# Organization      : California Institute of Technology
# -----------------------------------------------------------------------------

# Include libSBML's common Doxygen settings:

@INCLUDE               = doxygen-config-common.txt

# -----------------------------------------------------------------------------
# Beginning of C++ specific configuration settings
# -----------------------------------------------------------------------------

# The PROJECT_NAME tag is a single word (or a sequence of words surrounded 
# by quotes) that should identify the project.

PROJECT_NAME           = "@PACKAGE_NAME@ C# API"

# The PROJECT_NUMBER tag can be used to enter a project or revision number. 
# This could be handy for archiving the generated documentation or 
# if some version control system is used.

PROJECT_NUMBER         = "@PACKAGE_NAME@ @PACKAGE_VERSION@ C# API"

# The HTML_OUTPUT tag is used to specify where the HTML docs will be put. 
# If a relative path is entered the value of OUTPUT_DIRECTORY will be 
# put in front of it. If left blank `html' will be used as the default path.

HTML_OUTPUT            = ../formatted/csharp-api

# Set the OPTIMIZE_OUTPUT_JAVA tag to YES if your project consists of Java 
# sources only. Doxygen will then generate output that is more tailored for 
# Java. For instance, namespaces will be presented as packages, qualified 
# scopes will look different, etc. (also for C#)

OPTIMIZE_OUTPUT_JAVA   = YES

# The INPUT tag can be used to specify the files and/or directories that contain 
# documented source files. You may enter file names like "myfile.cpp" or 
# directories like "/usr/src/myproject". Separate the files or directories 
# with spaces.

INPUT =                            \
  libsbml-accessing.txt            \
  libsbml-coding.txt               \
  libsbml-communications.txt       \
  libsbml-example.txt              \
  libsbml-features.txt             \
  libsbml-installation.txt         \
  libsbml-issues.txt               \
  libsbml-license.txt              \
  libsbml-mainpage.txt             \
  libsbml-math.txt                 \
  libsbml-news.txt                 \
  libsbml-reading-files.txt        \
  libsbml-uninstallation.txt       \
  libsbml-extension-support-classes.txt \
  libsbml-howto-implement-extension.txt \
  @LIBSBML_ROOT_BINARY_DIR@/src/bindings/csharp/csharp-files/

# If the value of the INPUT tag contains directories, you can use the 
# FILE_PATTERNS tag to specify one or more wildcard pattern (like *.cpp 
# and *.h) to filter out the source-files in the directories. If left 
# blank the following patterns are tested: 
# *.c *.cc *.cxx *.cpp *.c++ *.d *.java *.ii *.ixx *.ipp *.i++ *.inl *.h *.hh 
# *.hxx *.hpp *.h++ *.idl *.odl *.cs *.php *.php3 *.inc *.m *.mm *.dox *.py 
# *.f90 *.f *.vhd *.vhdl

FILE_PATTERNS          = *.cs

# The INPUT_FILTER tag can be used to specify a program that doxygen should 
# invoke to filter for each input file. Doxygen will invoke the filter program 
# by executing (via popen()) the command <filter> <input-file>, where <filter> 
# is the value of the INPUT_FILTER tag, and <input-file> is the name of an 
# input file. Doxygen will then use the output that the filter program writes 
# to standard output.

INPUT_FILTER           = ./filters/doc-filter-csharp.py

# The RECURSIVE tag can be used to turn specify whether or not subdirectories 
# should be searched for input files as well. Possible values are YES and NO. 
# If left blank NO is used.

RECURSIVE              = NO

ENABLED_SECTIONS       = csharp notclike doxygenCsharpOnly

# Blank definitions for some constructs used only for some languages.

ALIASES += sbmldefgroup{2}=""
ALIASES += sbmlingroup{1}=""
ALIASES += sbmlendgroup=""

EXCLUDE +=  \
  ../../src/bindings/csharp/csharp-files/libsbmlPINVOKE.cs                                   \
  ../../src/bindings/csharp/csharp-files/SWIGTYPE_p_packageErrorTableEntry.cs                \
  ../../src/bindings/csharp/csharp-files/SWIGTYPE_p_List.cs                                  \
  ../../src/bindings/csharp/csharp-files/SWIGTYPE_p_std__ostream.cs                          \
  ../../src/bindings/csharp/csharp-files/SWIGTYPE_p_std__vectorT_SBMLNamespaces_const_p_t.cs \
  ../../src/bindings/csharp/csharp-files/SBMLTransforms.cs
