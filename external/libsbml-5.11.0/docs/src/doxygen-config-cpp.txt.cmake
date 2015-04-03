# @configure_input@
# -----------------------------------------------------------------------------
# File name         : doxyfile-config-cpp.txt
# Description       : Doxygen config for C++ libSBML API manual 
# Original author(s): Michael Hucka <mhucka@caltech.edu>
# Organization      : California Institute of Technology
# -----------------------------------------------------------------------------

# Include libSBML's common Doxygen settings:

@INCLUDE               = doxygen-config-common.txt

# -----------------------------------------------------------------------------
# Beginning of C++ specific configuration settings
# -----------------------------------------------------------------------------

# The PROJECT_NAME tag is a single word (or a sequence of words surrounded 
# by quotes) that should identify the project.

PROJECT_NAME           = "@PACKAGE_NAME@ C++ API"

# The PROJECT_NUMBER tag can be used to enter a project or revision number. 
# This could be handy for archiving the generated documentation or 
# if some version control system is used.

PROJECT_NUMBER         = "@PACKAGE_NAME@ @PACKAGE_VERSION@ C++ API"

# The HTML_OUTPUT tag is used to specify where the HTML docs will be put. 
# If a relative path is entered the value of OUTPUT_DIRECTORY will be 
# put in front of it. If left blank `html' will be used as the default path.

HTML_OUTPUT            = ../formatted/cpp-api

# If you use STL classes (i.e. std::string, std::vector, etc.) but do not
# want to include (a tag file for) the STL sources as input, then you should
# set this tag to YES in order to let doxygen match functions declarations
# and definitions whose arguments contain STL classes
# (e.g. func(std::string); v.s. func(std::string) {}). This also make the
# inheritance and collaboration diagrams that involve STL classes more
# complete and accurate.

BUILTIN_STL_SUPPORT    = YES

# The PREDEFINED tag can be used to specify one or more macro names that 
# are defined before the preprocessor is started (similar to the -D option of 
# gcc). The argument of the tag is a list of macros of the form: name 
# or name=definition (no spaces). If the definition and the = are 
# omitted =1 is assumed.

PREDEFINED             = __cplusplus  \
		         LIBSBML_EXTERN= \
			 BEGIN_C_DECLS= \
			 END_C_DECLS= \
			 LIBSBML_CPP_NAMESPACE_BEGIN= \
			 LIBSBML_CPP_NAMESPACE_END= \
                         SWIG \
			 doxygen_ignore

# The ENABLED_SECTIONS tag can be used to enable conditional 
# documentation sections, marked by \if sectionname ... \endif.

# In libSBML, we use the following section names for the languages:
#
#   java:     only Java
#   python:   only Python
#   perl:     only Perl
#   cpp:      only C++
#   csharp:   only C#
#   conly:    only C
#   clike:    C, C++

ENABLED_SECTIONS       = cpp clike doxygenCppOnly hasDefaultArgs

# Use this opportunity to generate man pages too.
# Note: The output has a lot of errors.  Can't enable just yet.
# GENERATE_MAN           = YES

EXAMPLE_PATH           = common-text . ../.. ../../examples/c++ \
                         ../../examples/c++/comp ../../examples/c++/layout \
                         ../../examples/c++/fbc ../../examples/c++/qual 
