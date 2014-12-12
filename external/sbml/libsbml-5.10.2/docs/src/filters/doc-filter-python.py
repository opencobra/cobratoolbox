#!/usr/bin/env python                        # -*- python-indent-offset: 2 -*-
#
# @file    doc-filter-python.py
# @brief   Post-process libSBML's Python doc strings for use by Doxygen.
# @author  Michael Hucka
#
# Usage: pythondocfilter.py libsbml.py > output.py
#
# This is designed to be used as the value of the INPUT_FILTER
# configuration variable in Doxygen.  This filter reads the standard input,
# on which it expects one file at a time fed to it by doxygen, then cooks
# the contents and writes the results to standard output.  The need for
# this is to do additional transformations that can't be done in swigdoc.py
# because they rely on having in hand the final output from SWIG.
#
# <!--------------------------------------------------------------------------
# This file is part of libSBML.  Please visit http://sbml.org for more
# information about SBML, and the latest version of libSBML.
#
# Copyright (C) 2013-2014 jointly by the following organizations:
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#     3. University of Heidelberg, Heidelberg, Germany
#
# Copyright (C) 2009-2013 jointly by the following organizations: 
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
#  
# Copyright (C) 2006-2008 by the California Institute of Technology,
#     Pasadena, CA, USA 
#  
# Copyright (C) 2002-2005 jointly by the following organizations: 
#     1. California Institute of Technology, Pasadena, CA, USA
#     2. Japan Science and Technology Agency, Japan
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation.  A copy of the license agreement is provided
# in the file named "LICENSE.txt" included with this software distribution
# and also available online as http://sbml.org/software/libsbml/license.html
# ---------------------------------------------------------------------- -->*/

import sys, string, os.path, re


def reformatDocString (match):
  text = match.group(1)

  # First, a regexp we use more than once below.
  # This regexp matches signatures of the following form:
  #    foo()
  #    foo() -> result(arg, arg, ...)
  #    foo(arg, arg, ...) -> result(arg, arg, ...)

  sigLHS  = '\w+\([\w()=*:"<>?,.\n ]*\)'
  sigRHS  = '( -> [\w()=*:"<>?|, \t]+)?'
  sigLine = sigLHS + sigRHS

  # We start by fixing some wonkiness with the output from SWIG: it sometimes
  # doubles up the signature strings it puts at the top of the doc string.
  # Here we try to remove the duplicates.

  p = re.compile('(?P<sig>' + sigLine + ')\s+(?P=sig)', re.MULTILINE)
  text = p.sub(r'\1', text)

  # The following are the bits we add around the signature strings, assigned
  # to variables to make the subsequent code slightly more readable.

  intro  = '<span class="signatureTitle">Python method signature(s)</span>:\n'
  sStart = '<pre class="signature">%'
  sEnd   = '</pre>'

  # The next regexp matches multiple signatures.
  # This relies on the fact that the first line(s) (up to a blank line) in
  # every method documentation string is the signature of the method.
  # The \A at the beginning of the regexp forces it that way.

  sigRE  = '\A(\s*)((' + sigLine + '\s*)+)'

  # This matches when the signatures are the only things in a docstring.
  p = re.compile(sigRE + '\Z', re.MULTILINE)
  text = p.sub(r'\1' + r'\1' + sStart + r'\2' + sEnd, text)

  # This matches when the signatures are followed with more text.
  p = re.compile(sigRE + '^\s*$', re.MULTILINE)
  text = p.sub(r'\1' + r'\1' + sStart + r'\2' + sEnd + r'\1<p>', text)

  # This ditches the "self" part of the signature string.
  text = re.sub(r'\(\w* ?self\)',  '()', text)
  text = re.sub(r'\(\w* ?self, ',  '(',  text)

  # This fixes a weird translation by SWIG's doc string generator: it
  # seems to turn "char *" to "char" instead of "string".  In our code,
  # this is almost never correct.  So:
  p = re.compile('(' + sigLHS + ') -> char')
  text = p.sub(r'\1 -> string', text)

  # Exceptions to the previous rule:
  text = text.replace('getCharacter() -> string', 'getCharacter() -> char')

  # Prettify the arrow:
  newArrow = '@htmlonly ' + \
             '<span class="signatureArrow"> </span>' + \
             '@endhtmlonly'
  p = re.compile(' -> ')
  text = p.sub(r' ' + newArrow + ' ', text)

  # Now we do a final transformation: bring up the brief description, if there
  # is one, to make it the first line of the doc string.

  start = '<pre class="signature">'
  brief = '\w[^.]+\.'

  p = re.compile('(' + start + r'.*?)<p>\s*(' + brief + ')\s(.*)', re.DOTALL)
  text = p.sub(r'\2\n\n' + r'\1' + r'\3', text)

  # Crucial detail: need a '!' character after the opening triple quotes or
  # else Doxygen puts the entire docstring inside a verbatim environment.

  return "\"\"\"!" + text + "\"\"\""


def filterDocStrings (contents):
  # Make the docstrings more readable.
  p = re.compile('\"\"\"(.+?)\"\"\"', re.DOTALL | re.MULTILINE)
  contents = p.sub(reformatDocString, contents)

  # Additional manipulations.

  # "Double" is called "float" in python.  There's no "double" in Python,
  # so there's no risk of damaging code here, but we have to be careful
  # about different contexts in which the word "double" might be used.
  contents = contents.replace(' double', " float")
  contents = contents.replace('(double', " (float")

  # These enumeration types are actually integers in the Python bindings.

  contents = re.sub(r'ASTNodeType_t\b',              'long',         contents)
  contents = re.sub(r'ASTNode_t\b',                  'long',         contents)
  contents = re.sub(r'BiolQualifierType_t\b',        'long',         contents)
  contents = re.sub(r'ConversionOptionType_t\b',     'long',         contents)
  contents = re.sub(r'ModelQualifierType_t\b',       'long',         contents)
  contents = re.sub(r'OperationReturnValues_t\b',    'long',         contents)
  contents = re.sub(r'ParseLogType_t\b',             'long',         contents)
  contents = re.sub(r'QualifierType_t\b',            'long',         contents)
  contents = re.sub(r'RuleType_t\b',                 'long',         contents)
  contents = re.sub(r'SBMLCompTypeCode_t\b',         'long',         contents)
  contents = re.sub(r'SBMLErrorCategory_t\b',        'long',         contents)
  contents = re.sub(r'SBMLErrorSeverity_t\b',        'long',         contents)
  contents = re.sub(r'SBMLFbcTypeCode_t\b',          'long',         contents)
  contents = re.sub(r'SBMLLayoutTypeCode_t\b',       'long',         contents)
  contents = re.sub(r'SBMLQualTypeCode_t\b',         'long',         contents)
  contents = re.sub(r'SBMLTypeCode_t\b',             'long',         contents)
  contents = re.sub(r'UnitKind_t\b',                 'long',         contents)
  contents = re.sub(r'XMLErrorCategory_t\b',         'long',         contents)
  contents = re.sub(r'XMLErrorCode_t\b',             'long',         contents)
  contents = re.sub(r'XMLErrorSeverityOverride_t\b', 'long',         contents)
  contents = re.sub(r'XMLErrorSeverity_t\b',         'long',         contents)

  # Replace SBMLErrorCode_t last.
  contents = re.sub(r'CompSBMLErrorCode_t\b',        'long',         contents)
  contents = re.sub(r'QualSBMLErrorCode_t\b',        'long',         contents)
  contents = re.sub(r'FbcSBMLErrorCode_t\b',         'long',         contents)
  contents = re.sub(r'LayoutSBMLErrorCode_t\b',      'long',         contents)
  contents = re.sub(r'SBMLErrorCode_t\b',            'long',         contents)

  # We alter the names of some functions.
  contents = re.sub('SBML_parseFormula\b',        "parseFormula",    contents)
  contents = re.sub('SBML_formulaToString\b',     "formulaToString", contents)

  # Other simple type replacements.
  contents = contents.replace('an unsigned int',           'a long integer')
  contents = contents.replace('unsigned int',              'long')
  contents = contents.replace('const std.string&',         'string')
  contents = contents.replace('const std.string',          'string')
  contents = contents.replace('SBMLConstructorException',  'ValueError')
  # Make sure to do the replacement for 'const' before the replacement for
  # 'char *', because in the SWIG output, there are things like 'char const *'.
  contents = contents.replace('const ',                    '')
  contents = contents.replace('char *',                    'string')
  contents = contents.replace('string *',                  'string')

  return contents


# The only reason this is a function and not inlined in filterContents()
# is the need to get match.group(0), which you can't do with Python's
# \number syntax in a regexp.  ("\0" is not interpreted as a group number.)

def hack_class_docstring(match):
  whole = match.group(0)
  indent = match.group(1)
  return whole + '\n' + indent + '##\n'


def filterContents (contents):
  """
  filterContents(contents) -> contents
  """

  # The following removes the space after the ':' in an __init__ definition
  # because otherwise, Doxygen 1.4.5's parser fails to match __init__
  # properly.  Clearly it's a bug in Doxygen.
  contents = re.sub('def __init__\(([^)]+)\): \n',
                    r'def __init__(\1):\n', contents)

  # The following adds a couple of comment characters after the doc string of
  # every class declaration.  Why, you ask?  Oh yes, let me tell you.
  # Because Doxygen 1.8.5 (possibly other versions too), when using @ingroup
  # and when producing output for Python, will incorrectly process the first
  # method that comes after a Python class declaration.  It (1) uses the
  # brief description from the class declaration as the brief description for
  # the method, and (2) files the method in a list of method members on the
  # page with all the classes defined in the group.  An example of the result
  # is a long list of clone() methods on the page describing one of our L3
  # package groups (e.g., for the libSBML 'comp' extension), with one clone()
  # method per class in the group, because for most of our classes, the first
  # method declared is clone().

  p = re.compile('^class\s+\w+\(\w+?\):\n(\s+)""".+?"""', re.MULTILINE|re.DOTALL)
  contents = p.sub(lambda match: hack_class_docstring(match), contents)

  return contents


def filterForDoxygen (contents):
  """
  filterForDoxygen(contents) -> contents

  Massage the content of a python file to better suit Doxygen's expectations.
  """
  contents = filterContents(contents)
  contents = filterDocStrings(contents)

  return contents


def main (args):
  """Usage: pythondocfilter.py libsbml.py > output.py

  libsbml.py    pathname to the libsbml.py file produced by SWIG.

  This cooks the final output of our swigdoc.py + SWIG sequence for use
  with doxygen, to do additional transformations that can't be done in
  swigdoc.py because they rely on having in hand the final output from
  SWIG.  This only acts on files whose names end in .py.
  """

  if len(args) != 2:
    print main.__doc__
    sys.exit(1)

  istream    = open(args[1], 'r')
  contents   = istream.read()
  istream.close()

  # Only process the content if it's Python.

  if re.search('.py$', args[1]):
    sys.stdout.write(filterForDoxygen(contents))
  else:
    sys.stdout.write(contents)

  sys.exit(0)


if __name__ == '__main__':
  main(sys.argv)


# Misc. code from previous iterations that I don't want to throw
# away just yet:
# 
#  text = p.sub(r'\1<table class="signatureTable"><tr><td class="signatureIntro"><b>Python method signature(s)</b>:</td><td class="signatureBlock">\2</td></tr></table>\1<p>', text)
