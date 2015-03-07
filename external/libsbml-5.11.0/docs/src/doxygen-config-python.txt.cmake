# @configure_input@
# -----------------------------------------------------------------------------
# File name         : doxyfile-config-python.txt
# Description       : Doxygen config for Python libSBML API manual 
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

PROJECT_NAME           = "@PACKAGE_NAME@ Python API"

# The PROJECT_NUMBER tag can be used to enter a project or revision number. 
# This could be handy for archiving the generated documentation or 
# if some version control system is used.

PROJECT_NUMBER         = "@PACKAGE_VERSION@"

# The HTML_OUTPUT tag is used to specify where the HTML docs will be put. 
# If a relative path is entered the value of OUTPUT_DIRECTORY will be 
# put in front of it. If left blank `html' will be used as the default path.

HTML_OUTPUT            = ../formatted/python-api

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
		         LIBSBML_EXTERN:="" \
			 BEGIN_C_DECLS:="" \
			 END_C_DECLS:="" \
			 LIBSBML_CPP_NAMESPACE_BEGIN:="" \
			 LIBSBML_CPP_NAMESPACE_END:="" \
			 SWIG=1 \
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
#   notcpp:   not C++
#   notclike: not C or C++

ENABLED_SECTIONS       = python notclike notcpp doxygenPythonOnly

# Because of how we construct the Python documentation, we don't want
# the first sentence to be assumed to be the brief description.

BRIEF_MEMBER_DESC      = NO

# Override the settings in doxygen-config-common.txt to refer to just
# the files relevant for the Python bindings.

INPUT = \
  libsbml-accessing.txt                 \
  libsbml-changes.txt                   \
  libsbml-coding.txt                    \
  libsbml-communications.txt            \
  libsbml-converters.txt                \
  libsbml-core-versus-packages.txt      \
  libsbml-extending.txt                 \
  libsbml-extension-support-classes.txt \
  libsbml-features.txt                  \
  libsbml-groups.txt                    \
  libsbml-howto-implement-extension.txt \
  libsbml-installation.txt              \
  libsbml-issues.txt                    \
  libsbml-license.txt                   \
  libsbml-mainpage.txt                  \
  libsbml-math.txt                      \
  libsbml-news.txt                      \
  libsbml-old-news.txt                  \
  libsbml-other.txt                     \
  libsbml-programming.txt               \
  libsbml-python-creating-model.txt     \
  libsbml-python-example-files.txt      \
  libsbml-python-reading-files.txt      \
  libsbml-release-info.txt              \
  libsbml.py                            \
  ../../src/sbml/common/common-documentation.h \
  ../../src/sbml/common/common-sbmlerror-codes.h

LAYOUT_FILE = doxygen-layout-python.xml

# The INPUT_FILTER tag can be used to specify a program that doxygen should 
# invoke to filter for each input file. Doxygen will invoke the filter program 
# by executing (via popen()) the command <filter> <input-file>, where <filter> 
# is the value of the INPUT_FILTER tag, and <input-file> is the name of an 
# input file. Doxygen will then use the output that the filter program writes 
# to standard output.

INPUT_FILTER           = "${PYTHON_EXECUTABLE} filters/doc-filter-python.py"

# Because of the way the proxies are done, @param never works properly.
# So don't bother telling us.

WARN_IF_DOC_ERROR      = YES

# According to the Doxygen 1.5.4 docs, you're supposed to set this for Python.

OPTIMIZE_OUTPUT_JAVA    = YES

# Ignore some symbols from the output.  We use this to hide some classes that we
# don't expose outside of the core.
#
# 2011-12-15 <mhucka@caltech.edu> Note: because of the way Python code
# works, the only symbols handed to the matcher are the class names and the
# function names, SEPARATELY.  You can't use a path pattern like
# SBasePlugin::connectToParent; it will simply never match.  I traced
# Doxygen's code in a debugger, and found that what the code handling
# EXCLUDE_SYMBOLS sees is "SBasePlugin" at one point and "connectToParent"
# at another point -- not connected at all.  Therefore, this drastically
# limits what we can do with EXCLUDE_SYMBOLS to hide things.  You don't
# want to put methods in this list unless you're absolutely sure that
# the methods should be removed no matter what class they may appear on.
# So, right now, we use this mainly to hide classes that don't get
# hidden by other means, and methods that should be universally hidden
# (or have completely unique names, so there's no chance of accidentally
# hiding more than intended).

EXCLUDE_SYMBOLS =                      \
  ISBMLExtensionNamespaces             \
  SBMLExtension                        \
  SBMLFunctionDefinitionConverter_init \
  SBMLInitialAssignmentConverter_init  \
  SBMLLevelVersionConverter_init       \
  SBMLRuleConverter_init               \
  SBMLStripPackageConverter_init       \
  SBMLTransforms                       \
  SBMLUnitsConverter_init              \
  SBaseExtensionPoint                  \
  SwigPyIterator                       \
  XMLInputStream                       \
  XMLOutputStream                      \
  swig_import_helper                   \
  weakref_proxy                        \
  _newclass                            \
  accept                               \
  string

EXAMPLE_PATH           = common-text examples . ../.. ../../examples/python \
                         ../../examples/python/comp ../../examples/python/layout \
                         ../../examples/python/fbc ../../examples/python/qual 
