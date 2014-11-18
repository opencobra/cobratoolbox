#!/usr/bin/env python
#
# @file   swigdoc.py
# @brief  Creates documentation for C#, Java, Python, and Perl.
# @author Ben Bornstein
# @author Christoph Flamm
# @author Akiya Jouraku
# @author Michael Hucka
# @author Frank Bergmann
#
#<!---------------------------------------------------------------------------
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
#----------------------------------------------------------------------- -->*/

import sys, string, os.path, re, argparse, libsbmlutils

#
# Hardwired values.  These need to be updated manually.
#

ignored_hfiles   = ['ListWrapper.h']
ignored_ifiles   = ['std_string.i', 'javadoc.i', 'spatial-package.i']
libsbml_types    = ['ASTNodeType_t',
                    'ASTNode_t',
                    'BiolQualifierType_t',
                    'ConversionOptionType_t',
                    'ModelQualifierType_t',
                    'OperationReturnValues_t',
                    'ParseLogType_t',
                    'QualifierType_t',
                    'RuleType_t',
                    'SBMLCompTypeCode_t',
                    'SBMLErrorCategory_t',
                    'SBMLErrorSeverity_t',
                    'SBMLFbcTypeCode_t',
                    'SBMLLayoutTypeCode_t',
                    'SBMLQualTypeCode_t',
                    'SBMLTypeCode_t',
                    'UnitKind_t',
                    'XMLErrorCategory_t',
                    'XMLErrorCode_t',
                    'XMLErrorSeverityOverride_t',
                    'XMLErrorSeverity_t',
                    'CompSBMLErrorCode_t',
                    'QualSBMLErrorCode_t',
                    'FbcSBMLErrorCode_t',
                    'LayoutSBMLErrorCode_t',
                    # Keep this one last, so that in regexp searches, it
                    # doesn't match the XXXXSBMLErrorCode_t ones above.
                    'SBMLErrorCode_t']

# In some languages like C#, we have to be careful about the method declaration
# that we put on the swig %{java|cs}methodmodifiers.  In particular, in C#, if
# a method overrides a base class' method, we have to add the modifier "new".
#
# FIXME: The following approach of hard-coding the list of cases is
# definitely not ideal.  We need to extract the list somehow, but it's not
# easy to do within this script (swigdoc.py) because the syntax of the
# files we read in is C++, not the target language like C#, and in C++,
# it's not obvious if the method you're looking at overrides another.  We a
# more sophisticated parser like the compiler itself, or we should write a
# small C# program to gather this info prior to running swigdoc.py.

overriders = \
{ 
'AlgebraicRule'             : [ 'clone', 'hasRequiredAttributes' ],
'AssignmentRule'            : [ 'clone', 'hasRequiredAttributes' ],
'Compartment'               : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName' ],
'CompartmentType'           : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName' ],
'CompExtension'             : [ 'clone', 'getErrorIdOffset' ],
'Constraint'                : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements' ],
'Delay'                     : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements' ],
'Event'                     : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'setId', 'setName', 'unsetId', 'unsetName', 'connectToChild', 'enablePackageInternal' ],
'EventAssignment'           : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'getId' ],
'FbcExtension'              : [ 'clone', 'getErrorIdOffset' ],
'FunctionDefinition'        : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'setId', 'setName', 'unsetId', 'unsetName' ],
'InitialAssignment'         : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'getId' ],
'ISBMLExtensionNamespaces'  : [ 'getURI', 'getPackageName' ],
'KineticLaw'                : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'connectToChild', 'enablePackageInternal' ],
'LayoutExtension'           : [ 'clone', 'getErrorIdOffset' ],
'ListOf'                    : [ 'clone', 'getTypeCode', 'getElementName', 'connectToChild', 'enablePackageInternal' ],
'ListOfCompartmentTypes'    : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfCompartments'        : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfConstraints'         : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfEventAssignments'    : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfEvents'              : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfFunctionDefinitions' : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfInitialAssignments'  : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfParameters'          : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfLocalParameters'     : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfReactions'           : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfRules'               : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfSpecies'             : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfSpeciesReferences'   : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfSpeciesTypes'        : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfUnitDefinitions'     : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'ListOfUnits'               : [ 'clone', 'getTypeCode', 'getItemTypeCode', 'getElementName', 'get', 'remove' ],
'Parameter'                 : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName' ],
'QualExtension'             : [ 'clone', 'getErrorIdOffset' ],
'LocalParameter'            : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'getDerivedUnitDefinition' ],
'Model'                     : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredElements', 'setId', 'setName', 'unsetId', 'unsetName', 'setAnnotation', 'appendAnnotation', 'connectToChild', 'enablePackageInternal' ],
'SimpleSpeciesReference'    : [ 'getId', 'getName', 'isSetId', 'isSetName', 'setId', 'setName', 'unsetId', 'unsetName' ],
'ModifierSpeciesReference'  : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes' ],
'Priority'                  : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements' ],
'RateRule'                  : [ 'clone', 'hasRequiredAttributes' ],
'Reaction'                  : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName', 'connectToChild', 'enablePackageInternal' ],
'Rule'                      : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements', 'hasRequiredAttributes', 'getId' ],
'SBMLDocument'              : [ 'clone', 'getModel', 'getTypeCode', 'getElementName', 'getNamespaces', 'connectToChild', 'enablePackageInternal' ],
'SBMLDocumentPlugin'        : [ 'clone' ],
'SBMLErrorLog'              : [ 'getError' ],
'SBMLConverter'             : [ 'convert', 'getDefaultProperties', 'matchesProperties' ],
'Species'                   : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName' ],
'SpeciesReference'          : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setAnnotation', 'appendAnnotation' ],
'SpeciesType'               : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'setId', 'setName', 'unsetId', 'unsetName' ],
'StoichiometryMath'         : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements' ],
'Trigger'                   : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredElements', 'hasRequiredAttributes' ],
'Unit'                      : [ 'clone', 'getTypeCode', 'getElementName', 'hasRequiredAttributes' ],
'UnitDefinition'            : [ 'clone', 'getId', 'getName', 'isSetId', 'isSetName', 'getTypeCode', 'getElementName', 'hasRequiredAttributes', 'hasRequiredElements', 'setId', 'setName', 'unsetId', 'unsetName', 'connectToChild', 'enablePackageInternal' ],
'XMLNode'                   : [ 'clone' ]
}

virtual_functions = \
{
'ElementFilter'             : [ 'filter' ]
}

#
# Globally-scoped variables that are set automatically at run time.
#

language         = ''
doc_include_path = ''
libsbml_classes  = []


#
# Global variable for tracking all class docs, so that we can handle
# cross-references like @copydetails that may refer to files other
# than the file being processed at any given time.
#

allclassdocs = {}


#
# Global list of preprocessor symbols defined via the --define option to
# swigdoc.py on the command line.  'SWIG' and '__cplusplus' are always
# defined by default.  (C is the only language for which we would not define
# __cplusplus, but for C, we don't use swigdoc.py anyway.)
#

preprocessor_defines = ['SWIG', '__cplusplus']


#
# Classes and methods.
#

class CHeader:
  """CHeader encapsulates the C++ class and C function definitions
  found within a C header file.
  """

  def __init__(self, stream, language, defines):
    self.language    = language
    self.classes     = []
    self.functions   = []
    self.classDocs   = []

    self.inClass     = False
    self.inClassDocs = False
    self.inDocs      = False
    self.isInternal  = False
    self.ignoreThis  = False

    self.classname   = ''
    self.docstring   = ''
    self.lines       = ''

    if stream is not None:
      read_loop(self.header_line_parser, stream.readlines(), defines)



  def header_line_parser(self, line):
    stripped = line.strip()

    # Track things that we flag as internal, so that we can
    # remove them from the documentation.

    if (stripped.find('@cond doxygenLibsbmlInternal') >= 0): self.isInternal = True
    if (stripped.find('@endcond') >= 0):                     self.isInternal = False

    # Watch for class description, usually at top of file.

    if (not self.inClassDocs) and stripped.startswith('* @class'):
      self.inClassDocs = True
      self.classname = stripped[8:].strip()
      if self.classname.endswith('.'):
        self.classname = self.classname[:-1]
      self.docstring = ''
      return

    if self.inClassDocs:
      if stripped.startswith('* @brief'):
        self.docstring += ' * ' + stripped[9:].strip() + '\n'
        return
      elif stripped.startswith('* @sbmlbrief{'):
        end = stripped.find('}')
        pkg = stripped[13:end]
        rest = stripped[end + 1:].strip()
        marker = '@htmlinclude pkg-marker-' + pkg + '.html'

        # In the case of Java, the output of swigdoc is fed to Javadoc and
        # not Doxygen.  So, we do our own processing of our special Doxygen
        # aliases.  If we're not doing this for Java, we leave them in.
        if self.language == 'java':
          self.docstring += ' * ' + marker + ' ' + rest + '\n'
        else:
          group = '@sbmlpackage{' + pkg + '}'
          self.docstring += ' * \n * ' + group + '\n *\n' + marker + ' ' + rest + '\n'
        return
      elif not stripped.endswith('*/') and not stripped.startswith('* @class'):
        self.docstring += line
        return
      else:
        if not self.classname.startswith("doc_"):
          self.docstring = '/**\n' + self.docstring + ' */'
        self.docstring = removeHTMLcomments(self.docstring)
        doc = CClassDoc(self.docstring, self.classname, self.isInternal)
        self.classDocs.append(doc)

      # There may be more class docs in the same comment.
      if stripped.startswith('* @class'):
        self.classname = stripped[8:].strip()
        if self.classname.endswith('.'):
          self.classname = self.classname[:-1]
      else:
        self.inClassDocs = False

      self.docstring = ''
      return

    # Watch for class definition, methods and out-of-class functions.

    if stripped.startswith('class ') and not stripped.endswith(';'):
      self.ignoreThis = False
      self.inClass = True
      self.classname = line[6:].split(':')[0].strip()
      if self.classname[:6] == 'LIBSBM' or self.classname[:6] == 'LIBLAX':
        self.classname = self.classname.split(' ')[1].strip()
      self.classes.append( CClass(self.classname) )
      return

    if stripped == '};':
      self.inClass = False
      return

    if stripped == '/**':
      self.docstring  = ''
      self.lines      = ''
      self.ignoreThis = False
      self.inDocs     = True

    if self.inDocs:
      self.docstring += line
      self.inDocs     = (stripped != '*/')
      return

    # If we get here, we're no longer inside a comment block.
    # Start saving lines, but skip embedded comments.

    if stripped.startswith('#') or (stripped.find('typedef') >= 0):
      self.ignoreThis = True
      return

    if not self.ignoreThis:
      cppcomment = stripped.find('//')
      if cppcomment != -1:
        stripped = stripped[:cppcomment]
      self.lines += stripped + ' '         # Space avoids jamming code together.

      # Keep an eye out for the end of the declaration.
      if not stripped.startswith('*') and \
         (stripped.endswith(';') or stripped.endswith(')') or stripped.endswith('}')):

        # It might be a forward declaration.  Skip it.
        if self.lines.startswith('class'):
          return

        # It might be a C++ operator redefinition.  Skip it.
        if self.lines.find('operator') >= 0:
          return

        # It might be an enum.  Skip it.
        # If it's not an enum at this point, parse it.
        if stripped.endswith('}'):
          self.lines = self.lines[:self.lines.rfind('{')]
        if not stripped.startswith('enum'):

          # If this segment begins with a comment, we need to skip over it.
          searchstart = self.lines.rfind('*/')
          if (searchstart < 0):
            searchstart = 0

          # Find (we hope) the end of the method name.
          stop = self.lines[searchstart:].find('(')

          # Pull out the method name & signature.
          if (stop > 0):
            name      = self.lines[searchstart : searchstart + stop].split()[-1]
            endparen  = self.lines.rfind(')')
            args      = self.lines[searchstart + stop : endparen + 1]
            isConst   = self.lines[endparen:].rfind('const')
            isVirtual = self.lines[searchstart : endparen].find('virtual')

            if len(self.docstring) > 0:
              # Remove embedded HTML comments before we store the doc string.
              self.docstring = removeHTMLcomments(self.docstring)
            else:
              # We have an empty self.docstring.  Put in something so that later
              # stages can do whatever postprocessing they need.
              self.docstring = '/** */'

            # Swig doesn't seem to mind C++ argument lists, even though they
            # have "const", "&", etc. So I'm leaving the arg list unmodified.
            func = Method(self.isInternal, self.docstring, name, args,
                          (isConst > 0), (isVirtual != -1))

            # Reset buffer for the next iteration, to skip the part seen.
            self.lines = self.lines[endparen + 2:]
            self.docstring = ''

            if self.inClass:
              c = self.classes[-1]
              c.methods.append(func)

              # Record method variants that take different arguments.
              if c.methodVariants.get(name) == None:
                c.methodVariants[name] = {}
              c.methodVariants[name][args] = func
            else:
              self.functions.append(func)
              # FIXME need do nc variants



class CClass:
  """A CClass encapsulates a C++ class.  It has the following public
  attributes:

    - name
    - methods
    - methodVariants
  """

  def __init__ (self, name):
    """CClass(name) -> CClass

    Creates a new CClass with the given name.
    """
    self.name           = name
    self.methods        = [ ]
    self.methodVariants = {}



class Method:
  """A Method encapsulates a C/C++ function.  Currently, it has the
  following public attributes:

    - isInternal
    - docstring
    - name
    - args
    - isConst
    - isVirtual
  """

  def __init__ (self, isInternal, docstring, name, args, isConst, isVirtual):
    """Method(isInternal, docstring name, args, isConst,isVirtual) -> Method

    Creates a new Method description with the given docstring, name and args,
    for the language, with special consideration if the method
    was declared constant and/or internal.
    """

    global language

    self.name       = name
    self.isConst    = isConst
    self.isInternal = isInternal
    self.isVirtual  = isVirtual

    if isInternal:
      if language == 'java':
        # We have a special Javadoc doclet that understands a non-standard
        # Javadoc tag, @internal.  When present in the documentation string
        # of a method, it causes it to be excluded from the final
        # documentation output.  @internal is something doxygen offers.
        #
        p = re.compile('(\s+?)\*/', re.MULTILINE)
        self.docstring = p.sub(r'\1* @internal\1*/', docstring)
      elif language == 'csharp':
        # We mark internal methods in a different way for C#.
        self.docstring = docstring
      else:
        self.docstring = "  @internal\n" + docstring
    else:
      self.docstring = docstring

    # In Java and C#, if a method is const and swig has to translate the type,
    # then for some reason swig cannot match up the resulting doc strings
    # that we put into %javamethodmodifiers.  The result is that the java
    # documentation for the methods are empty.  I can't figure out why, but
    # have figured out that if we omit the argument list in the doc string
    # that is put on %javamethodmodifiers for such case, swig does generate 
    # the comments for those methods.  This approach is potentially dangerous
    # because swig might attach the doc string to the wrong method if a
    # methods has multiple versions with varying argument types, but the
    # combination doesn't seem to arise in libSBML currently, and anyway,
    # this fixes a real problem in the Java documentation for libSBML.

    if language == 'java' or language == 'csharp':
      if isConst and (args.find('unsigned int') >= 0):
        self.args = ''
      elif not args.strip() == '()':
        if isConst:
          self.args = args + ' const'
        else:
          self.args = args
      else:
        if isConst:
          self.args = '() const'
        else:
          self.args = ''
    else:
      self.args = args



class CClassDoc:
  """Encapsulates documentation for a class.  Currently, it has the
  following public attributes:

    - docstring
    - name
  """

  def __init__ (self, docstring, name, isInternal):
    """CClassDoc(docstring, name) -> CClassDoc

    Creates a new CClassDoc with the given docstring and name.
    """

    # Take out excess leading blank lines.
    docstring = re.sub('/\*\*(\s+\*)+', r'/** \n *', docstring)

    # Add marker for internal classes.
    if isInternal:
      docstring = re.sub('\*/', r'* @internal\n */', docstring)

    self.docstring  = docstring
    self.name       = name
    self.isInternal = isInternal


# Example case for working out the algorithm for read_loop().
# Preprocessor symbols are X, Y, Z.
# Start:
#
# X not defined
# Y not defined
# Z defined
#
# skipping = false
# states = []
# symbols = []
#
# #ifdef X
#
#   skipping = true
#   states[0] = false
#   symbols[0] = X
#
#   ; should ignore rest of this until outer #else
#
#   #ifndef Y
#
#   #else
#
#   #endif
#
# #else
#
#   skipping = false
#   states[0] = false
#   symbols[0] = X
#
# #endif
#
# skipping = false
# states = []
# symbols = []
#
# #ifdef Z
#
#   skipping = false
#   states[0] = false
#   symbols[0] = Z
#
#   #ifndef Y
#
#     skipping = false
#     states[1] = false
#     symbols[1] = Y
#
#   #else
#
#     skipping = true
#     states[1] = false
#     symbols[1] = Y
#
#   #endif
#
#   skipping = false
#   states[0] = false
#   symbols[0] = Z
#
# #else
#
#   skipping = true
#   states[0] = false
#   symbols[0] = Z
#
# #endif

def read_loop(line_parser_func, lines, defined_symbols):
  """Non-recursive function to call 'line_parser_func'() on each line
  of 'lines', paying attention to #if/#ifdef/#ifndef/#else/#endif
  conditionals.  'defined_symbols' is a list of the symbols to check when
  reading #if/#ifdef/#ifndef conditions."""

  # symbol_stack holds the current #if condition symbol
  # state_stack holds the skipping state before the current #if symbol was seen

  states   = [False]
  skipping = False

  for line in lines:
    split = line.split()
    if split:
      start = split[0]
      if start == '#if' or start == '#ifdef':
        states.append(skipping)
        if skipping:
          continue
        skipping = True
        for s in defined_symbols:
          if split[1] == s:
            skipping = False
            break
      elif start == '#ifndef':
        states.append(skipping)
        if skipping:
          continue
        for s in defined_symbols:
          if split[1] == s:
            skipping = True
            break
      elif start == '#endif':
        skipping = states.pop()
      elif start == '#else' and not skipping:
        skipping = not states[-1]
    if not skipping:
      line_parser_func(line)



def find_inclusions(extension, lines, ignored_list):
  includes = []
  def inclusions_line_parser(line):
    split = line.split()
    if split and split[0] == '%include':
      filename = re.sub('["<>]', '', split[1]).strip()
      if filename.endswith(extension) and filename not in ignored_list:
        includes.append(filename)

  read_loop(inclusions_line_parser, lines, preprocessor_defines)
  return includes



def get_swig_files (swig_file, included_files=[], parent_dirs=[]):
  """
  Builds a list of all the files %include'd recursively from the given
  SWIG .i file.
  """

  # Record directories encountered.

  dir = os.path.abspath(os.path.join(swig_file, os.pardir))
  if dir not in parent_dirs:
    parent_dirs.append(dir)

  # Read the current file.

  swig_file = os.path.normpath(os.path.abspath(os.path.join(dir, swig_file)))
  stream = open(swig_file)
  lines  = stream.readlines()
  stream.close()

  # Create list of %include'd .i files found in the file, but filter out
  # the ones we ignore.

  ifiles = find_inclusions('.i', lines, ignored_ifiles)

  # Recursively look for files that are included by the files we found.
  # SWIG searches multiple paths for %include'd .i files.  We just look in
  # the directories of the .i files we encounter.
  found_ifiles = []
  for ifilename in ifiles:
    search_dirs = ['.'] + parent_dirs
    for dir in search_dirs:
      file = os.path.normpath(os.path.abspath(os.path.join(dir, ifilename)))
      if os.path.isfile(file) and file not in included_files:
        included_files.append(file)
        found_ifiles.extend(get_swig_files(file, included_files, parent_dirs))
        break

  return [swig_file] + found_ifiles



def get_header_files (swig_files, include_path):
  """
  Reads the list of %include directives from the given SWIG (.i) files, and
  returns a list of C/C++ headers (.h) found.  This uses a recursive algorithm.
  """

  hfiles = []
  for file in swig_files:
    stream = open(file)
    hfiles.extend(find_inclusions('.h', stream.readlines(), ignored_hfiles))
    stream.close()

  # Convert the .h file names to absolute paths.  This is slightly tricky
  # because the file might be in the current directory, or in the
  # include_path we were given, or in the directory of one of the .i files we
  # encountered.  So, we need to search them all.

  search_dirs = [os.path.abspath('.')] + [os.path.abspath(include_path)]
  for file in swig_files:
    search_dirs.append(os.path.dirname(file))

  abs_hfiles = []
  for file in hfiles:
    for dir in search_dirs:
      abs_path = os.path.abspath(os.path.join(dir, file))
      if os.path.isfile(abs_path) and abs_path not in abs_hfiles:
        abs_hfiles.append(abs_path)

  return abs_hfiles



def translateVerbatim (match):
  tag  = match.group(1)
  body = match.group(2)

  # If this code block has the form @code{.java}, remove the {.java} part.
  body = re.sub(r'\A{.java}', '', body)

  # Do some other important replacements in the body.
  body = body.replace('<p>', '')
  body = body.replace('<', '&lt;')
  body = body.replace('>', '&gt;')

  # Return the reconstructed version.
  body = r"<pre class='fragment'>" + body
  body = re.sub(r'(\s*\*\s*)*\Z', '</pre>', body)
  return body



def translateInclude (match):
  global doc_include_path

  file    = match.group(2)
  file    = re.sub('["\']', '', file)   #'
  content = ''
  try:
    stream  = open(doc_include_path + '/common-text/' + file, 'r')
    content = stream.read()
    stream.close()
  except (Exception,):
    e = sys.exc_info()[1]
    print('Warning: cannot expand common-text: ' + file)
    print(e)

  content = removeHTMLcomments(content)

  # Quote embedded double quotes.
  content = re.sub('\"', '\\\"', content)

  return content



def translateCopydetails (match):
  operator = match.group(1)
  name = match.group(2)
  if (name in allclassdocs):
    text = allclassdocs[name]
  else:
    # If it's not found, just write out what we read in.
    text = '@copy' + operator + ' ' + name
  return text



def translateIfElse (match):
  # Our possible conditional elements and their meanings are:
  #
  #   a language name: java, python, csharp, perl, cpp, conly
  #   special terms: clike (= C or C++)
  #
  # The special variants are because Doxygen doesn't have a way to indicate a
  # conjunction like "if not C or C++".  We have to have special smarts here
  # for notclike.

  ifnot = match.group(1) == '@ifnot'
  cond  = match.group(2)
  if ((not ifnot) and (cond == language)) \
     or (ifnot and (cond != language or cond == 'clike')):
    text = match.group(3)
  elif match.group(5) == '@else':
    text = match.group(6)
  else:
    text = ''
  return text



def translatePythonCrossRef (match):
  prior = match.group(1)
  classname = match.group(2)
  method = match.group(3)
  args = match.group(4)
  return prior + classname + "." + method + "()"



def translatePythonSeeRef (match):
  prior = match.group(1)
  method = match.group(2)
  args = match.group(3)
  return prior + method + "()"



def translateAllowingBreaks (translations, docstring):
  for pair in translations:
    new_pattern = re.sub(' ', r'\s+\*?\s*', pair[0])
    replacement = pair[1]
    docstring   = re.sub(new_pattern, replacement, docstring)
  return docstring


def translateJavaSeeArgs (match):
  front = match.group(1)
  args  = match.groups()
  reconstructed = front + '(' + ', '.join(filter(None, args[1::2])) + ')'
  return match.group(0)


def rewriteClassRefAddingSpace (match):
  return match.group(1) + match.group(2) + match.group(3)



def rewriteClassRef (match):
  return match.group(1) + match.group(2)



def translateCrossRefs (str):
  if re.search('@sbmlfunction', str) != None:
    p = re.compile('@sbmlfunction{([^}]+?)}')
    str = p.sub(translateSBMLFunctionRef, str)
  else:
    p = re.compile(r'([^\w.">])(' + '|'.join(libsbml_classes) + r')\b([^:])')
    str = p.sub(translateClassRef, str)
    p = re.compile('(\W+)(\w+?)::(\w+\s*\([^)]*?\))')
    str = p.sub(translateMethodRef, str)
  return str



def translateSBMLFunctionRef (match):
  if language != 'java':
    return match.group(0)

  # Group 1 is the contents inside @sbmlfunction{...}
  content = match.group(1)

  # Take out embedded comment continuation characters ('*') and line breaks.
  p = re.compile(r'\s+\*\s+')
  content = p.sub(r' ', content)

  # Take out the backslashes in front of quoted commas.
  p = re.compile(r'\\,')
  content = p.sub(r',', content)

  # Split the function name from the args. Possible forms:
  #   name
  #   name, arg
  #   name, arg, arg

  content_match   = re.match(r'([\w.]+)\s*,?\s*(.+)?', content)
  function_name   = content_match.group(1)
  args_with_names = content_match.group(2) or ''

  # Args are of the form (type1 name1, type2 name2).  Remove the names.
  p = re.compile(r'\b([\w.]+)\s+(\w+)\b')
  args_no_names = p.sub(r'\1', args_with_names)

  # Convert libSBML and Java plain type names to fully qualified ones.
  common_java_classes = ['String', 'Object']

  p = re.compile(r'\b(' + '|'.join(libsbml_classes) + r')\b', re.DOTALL)
  expanded_args = p.sub(r'org.sbml.libsbml.\1', args_no_names)
  p = re.compile(r'\b(' + '|'.join(common_java_classes) + r')\b', re.DOTALL)
  expanded_args = p.sub(r'java.lang.\1', expanded_args)

  return '<a href="libsbml.html#' \
    + function_name + '(' + expanded_args + ')"><code>libsbml.' \
    + function_name + '(' + args_with_names + ')</code></a>'



def translateMethodRef (match):
  prior     = match.group(1)
  classname = match.group(2)
  method    = match.group(3)
  if language == 'java':
    return prior + '{@link ' + classname + '#' + method + '}'
  elif language == 'csharp':
    return prior + '<see cref="' + classname + '.' + method + '"/>'



def translateClassRef (match):
  if language != 'java' and language != 'csharp':
    return match.group(0)
  leading      = match.group(1)
  classname    = match.group(2)
  trailing     = match.group(3)
  if leading == '%' or leading == '(':
    return match.group(0)
  elif language == 'java':
    return leading + '{@link ' + classname + '}' + trailing
  elif language == 'csharp':
    return leading + '<see cref="' + classname + '"/>' + trailing



def rewriteList (match):
  lead   = match.group(1);
  list   = match.group(2);
  space  = match.group(3);
  ending = match.group(4);

  list = re.sub(r'@li\b', '<li>', list)
  list = re.sub('r<p>', '', list)       # Remove embedded <p>'s.
  return lead + "<ul>\n" + lead + list + "\n" + lead + "</ul>" + space + ending;



def rewriteDeprecated (match):
  lead   = match.group(1);
  depr   = match.group(2);
  body   = match.group(3);
  ending = match.group(5);
  return lead + depr + '<div class="deprecated">' + body + '</div>\n' + lead + ending



def rewriteConstantLink (match):
  # Cheapskate solution: rewrite it as a plain @link, just like our Doxygen
  # macro does in doxygen-config-common.txt, so that it gets translated by
  # the subsequent call to rewriteEnumLink in this file.
  args      = match.group(1)
  split     = args.split(',')
  symbol    = split[0].strip()
  type_name = split[1].strip()
  return '@link ' + type_name + '#' + symbol + ' ' + symbol + '@endlink'
 


def rewriteEnumLink (match):
  enum       = match.group(1)
  target     = match.group(2)
  print_name = match.group(3)

  if language == 'java':
    return '{@link libsbmlConstants#' + target + ' ' + print_name + '}'
  elif language == 'python':
    return '@link libsbml#' + target + ' ' + print_name + '@endlink'
  elif language == 'csharp':
    return '@link libsbmlcs#' + target + ' ' + print_name + '@endlink'
  else:
    return match.group(0)



def rewriteCommonReferences (docstring):
  """rewriteCommonReferences (docstring) -> docstring

  Recognize common C++ type references and change the reference syntax.
  """

  # For some languages, we don't have separate types like ASTNode_t.
  # They're just values on a single global class.  So, remove the type names.

  docstring = re.sub('(' + '|'.join(libsbml_types) + ')#', '#', docstring)

  # Handle references to enumerations and #define constants.  (Make sure to
  # run rewriteConstantLink before rewriteEnumLink, because the former relies
  # on the latter expanding the links it creates.)

  p = re.compile('@sbmlconstant{([^}]+?)}')
  docstring = p.sub(rewriteConstantLink, docstring)
  p = re.compile('@link\s*\*?\s+(\w+)?#(\w+)\s*\*?\s+(\w+)\s*@endlink')
  docstring = p.sub(rewriteEnumLink, docstring)

  return docstring



def sanitizeForHTML (docstring):
  """sanitizeForHTML (docstring) -> docstring

  Performs HTML transformations on the C++/Doxygen docstring.
  """

  # Remove some things we use as hacks in Doxygen 1.7-1.8.

  docstring = docstring.replace(r'@~', '')
  p = re.compile('^\s*\*\s+@par(\s)', re.MULTILINE)
  docstring = p.sub(r'\1', docstring)

  # Remove @ref's, since we currently have no way to deal with them.

  docstring = re.sub('@ref\s+\w+', '', docstring)

  # First do conditional section inclusion based on the current language.

  p = re.compile('(@if|@ifnot)[\s*]+(\w+)[\s*]+(.+?)((@else)\s+(.+?))?@endif', re.DOTALL)
  docstring = p.sub(translateIfElse, docstring)

  # Replace blank lines between paragraphs with <p>.  There are two main
  # cases: comments blocks whose lines always begin with an asterix (e.g.,
  # C/C++), and comment blocks where they don't (e.g., Python).  The third
  # substitution below does the same thing for blank lines, except for the
  # very end of the doc string.

  p = re.compile('^(\s+)\*\s*$', re.MULTILINE)
  docstring = p.sub(r'\1* <p>', docstring)
  p = re.compile('^((?!\s+\Z)\s+)$', re.MULTILINE)
  docstring = p.sub(r'\1<p>', docstring)
  p = re.compile('^(?!\Z)$', re.MULTILINE)
  docstring = p.sub(r'<p>', docstring)

  # There's no Javadoc verbatim or @code/@endcode equivalent, so we have to
  # convert it to raw HTML and transform the content too.  This requires
  # helpers.  The following treats both @verbatim and @code the same way.

  p = re.compile('@(?P<tag>verbatim|code)(.+?)@end(?P=tag)', re.DOTALL)
  docstring = p.sub(translateVerbatim, docstring)

  # Javadoc doesn't have a @section or @subsection commands, so we translate
  # those ourselves.

  p = re.compile('@section\s+[^\s]+\s+(.*)$', re.MULTILINE)
  docstring = p.sub(r'<h2>\1</h2>', docstring)
  p = re.compile('@subsection\s+[^\s]+\s+(.*)$', re.MULTILINE)
  docstring = p.sub(r'<h3>\1</h3>', docstring)
  p = re.compile('@subsubsection\s+[^\s]+\s+(.*)$', re.MULTILINE)
  docstring = p.sub(r'<h4>\1</h4>', docstring)

  # Javadoc doesn't have an @image command.  We translate @image html
  # but ditch @image latex.

  p = re.compile('@image\s+html+\s+([^\s]+).*$', re.MULTILINE)
  docstring = p.sub(r"<center class='image'><img src='\1'></center>", docstring)
  p = re.compile('@image\s+latex+\s+([^\s]+).*$', re.MULTILINE)
  docstring = p.sub(r'', docstring)

  # Doxygen doesn't understand HTML character codes like &ge;, so we've
  # been using doxygen's Latex facility to get special mathematical
  # characters into the documentation, but as luck would have it, Javadoc
  # doesn't understand the Latex markup.  All of this is getting old.

  docstring = re.sub(r'\\f\$\\geq\\f\$', '&#8805;', docstring)
  docstring = re.sub(r'\\f\$\\leq\\f\$', '&#8804;', docstring)
  docstring = re.sub(r'\\f\$\\times\\f\$', '&#215;', docstring)

  # Replace triple dashes with &mdash;.  Doxygen does it but Java doesn't.

  docstring = re.sub(r'---', '&mdash;', docstring)

  # The following are done in pairs because I couldn't come up with a
  # better way to catch the case where @c and @em end up alone at the end
  # of a line and the thing to be formatted starts on the next one after
  # the comment '*' character on the beginning of the line.

  docstring = re.sub('@c +([^ ,;()/*\n\t<]+)', r'<code>\1</code>', docstring)
  docstring = re.sub('@c(\n[ \t]*\*[ \t]*)([^ ,;()/*\n\t<]+)', r'\1<code>\2</code>', docstring)
  docstring = re.sub('@p +([^ ,.:;()/*\n\t<]+)', r'<code>\1</code>', docstring)
  docstring = re.sub('@p(\n[ \t]*\*[ \t]+)([^ ,.:;()/*\n\t<]+)', r'\1<code>\2</code>', docstring)
  docstring = re.sub('@em *([^ ,.:;()/*\n\t<]+)', r'<em>\1</em>', docstring)
  docstring = re.sub('@em(\n[ \t]*\*[ \t]*)([^ ,.:;()/*\n\t<]+)', r'\1<em>\2</em>', docstring)

  # Convert @li into <li>, but also add <ul> ... </ul>.  This is a bit
  # simple-minded (I suppose like most of this code), but ought to work
  # for the cases we use in practice.

  p = re.compile('^(\s+\*\s+)(@li\s+.*?)(\s+)(\*/|<p>\s+\*\s+(?!@li\s))', re.MULTILINE|re.DOTALL)
  docstring = p.sub(rewriteList, docstring)

  # Wrap @deprecated content with a class so that we can style it.

  p = re.compile('^(\s+\*\s+)(@deprecated\s)((\S|\s)+)(<p>|\*/)', re.MULTILINE|re.DOTALL)
  docstring = p.sub(rewriteDeprecated, docstring)

  # Handle cross references for languages where it's not done.  Doxygen
  # automatically cross-references class names in text to the class
  # definition page, but Javadoc and the C# case don't.  Rather than having
  # to put in a lot conditional @if/@endif's into the documentation to
  # manually create cross-links just for the Java case, let's automate.

  if language == 'java' or language == 'csharp':
    listOfSegments = re.split('(@sbmlfunction{[^}]+?})', docstring)
    reconstructed = ''
    for segment in listOfSegments:
      reconstructed += translateCrossRefs(segment)
    docstring = reconstructed

  # Clean-up step needed because some of the procedures above are imperfect.
  # The first converts " * * @foo" lines into " * @foo".
  # The 2nd pair converts * <p> * <p> * sequences into one <p>.
  # The 3rd converts consecutive <p> * <p> sequences into one <p>.

  p = re.compile('^(\s+)\*\s+\*\s+@', re.MULTILINE)
  docstring = p.sub(r'\1* @', docstring)

  p = re.compile('^(\s*)\*\s*<p>', re.MULTILINE)
  docstring = p.sub(r'\1<p>', docstring)
  p = re.compile('^(\s*)\*?\s*<p>((\s+\*)+\s+<p>)+', re.MULTILINE)
  docstring = p.sub(r'\1*', docstring)

  p = re.compile('<p>([\s*]*<p>)+', re.MULTILINE)
  docstring = p.sub(r'<p>', docstring)

  # Merge separated @see's, or else the first gets lost in the javadoc output.

  p = re.compile(r'(@see.+?)<p>.+?@see', re.DOTALL)
  docstring = p.sub(r'\1@see', docstring)

  # If the doc string ends with <p> followed by */, then javadoc parses it
  # incorrectly.  Since we typically end class and method docs with a list of
  # @see's, the consequence is that it omits the last entry of a list of
  # @see's.  The behavior is totally baffling, but let's just deal with it.
  # The two forms below are because, when we are processing method doc
  # strings, they do not yet end with "*/" when we process them here, so we
  # match against either the end of the string or a "*/".)

  p = re.compile(r'(<p>\s*)+\*/', re.MULTILINE)
  docstring = p.sub(r'*/', docstring)
  p = re.compile(r'(<p>\s*)+\Z', re.MULTILINE)
  docstring = p.sub(r'', docstring)

  # Take out any left-over Doxygen-style quotes, because Javadoc doesn't have
  # the %foo quoting mechanism.

  docstring = re.sub(r'(\s)%(\w)', r'\1\2', docstring)

  # Currently, we don't handle @ingroup or our pseudo-tag, @sbmlpackage.

  docstring = re.sub(r'@ingroup \w+', '', docstring)
  docstring = re.sub(r'@sbmlpackage{\w+}', '', docstring)

  return docstring



def removeStar (match):
  text = match.group()
  text = text.replace('*', '')
  return text



def removeHTMLcomments (docstring):
  return re.sub(r'<!--.+?\s-->', '', docstring, re.DOTALL|re.MULTILINE)



def rewriteDocstringForJava (docstring):
  """rewriteDocstringForJava (docstring) -> docstring

  Performs some mimimal javadoc-specific sanitizations on the
  C++/Doxygen docstring.
  """

  docstring = rewriteCommonReferences(docstring)

  # Preliminary: rewrite some of the data type references to equivalent
  # Java types.  (Note: this rewriting affects only the documentation
  # comments inside classes & methods, not the method signatures.)

  breakable_translations = [[r'an unsigned int',     'a long integer'],
                            [r'unsigned int',        'long'],
                            [r'const char\*',        'String'],
                            [r'const char \*',       'String '],
                            [r'const std::string&',  'String'],
                            [r'const std::string &', 'String '],
                            [r'const std::string',   'String']]

  docstring = translateAllowingBreaks(breakable_translations, docstring)

  docstring = re.sub(r'std::string',            'String',  docstring)
  docstring = re.sub(r'NULL',                   'null',    docstring)
  docstring = re.sub(r'\bbool\b',               'boolean', docstring)
  docstring = re.sub(r'const ',                 '',        docstring)

  # Also use Java syntax instead of "const XMLNode*" etc.

  p = re.compile(r'const (%?)(' + '|'.join(libsbml_classes) + r')( ?)(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRefAddingSpace, docstring)
  p = re.compile(r'(%?)(' + '|'.join(libsbml_classes) + r')( ?)(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRefAddingSpace, docstring)

  # Do the big work.

  docstring = sanitizeForHTML(docstring)

  # Fix up for a problem introduced by sanitizeForHTML: it puts {@link ...}
  # into the arguments of functions mentioned in @see's, if the function has
  # more than one argument.  The following gets rid of the @link's.  This
  # should be fixed properly some day.

  p = re.compile(r'((@see|@throws)\s+[\w\\ ,.\'"=<>()#]*?){@link\s+([^}]+?)}') #"
  while re.search(p, docstring) != None:
    docstring = p.sub(r'\1\3', docstring)

  # Inside of @see, change double colons to pound signs.

  docstring = re.sub('(@see\s+\w+)::', r'\1#', docstring)

  # The syntax for @see is slightly different: method names need to have a
  # leading pound sign character.  This particular bit of code only handles
  # a single @see foo(), which means the docs have to be written that way.
  # Maybe someday in the future it should be expanded to handle
  # @see foo(), bar(), etc., but I don't have time right now to do it.

  docstring = re.sub('(@see\s+)([\w:.]+)\(', r'\1#\2(', docstring)

  # Remove the parameter names from argument lists, if any, inside @see's.
  # (The Java convention is that the parameter names are not included in the
  # text of the reference.)  At this point, we expect to see only single
  # types like "long" and not "unsigned int", because we translated them above.

  p = re.compile(r'(@see\s+#?\w+)\((\w+)+\s+\w+(\s*,\s*(\w+)\s+\w+)?\)')
  docstring = p.sub(translateJavaSeeArgs, docstring)

  # The syntax for @link is vastly different.

  p = re.compile('@link([\s/*]+[\w\s,.:#()*]+[\s/*]*[\w():#]+[\s/*]*)@endlink', re.DOTALL)
  docstring = p.sub(r'{@link \1}', docstring)

  # Outside of @see and other constructs, dot is used to reference members
  # instead of C++'s double colon.

  docstring = docstring.replace(r'::', '.')

  # Need to escape quotation marks.  The reason is that the
  # %javamethodmodifiers directives created for use with SWIG will
  # themselves be double-quoted strings, and leaving embedded quotes
  # will completely screw that up.

  docstring = docstring.replace('"', "'")
  docstring = docstring.replace(r"'", r"\'")

  return docstring



def rewriteDocstringForCSharp (docstring):
  """rewriteDocstringForCSharp (docstring) -> docstring

  Performs some mimimal C#-specific sanitizations on the
  C++/Doxygen docstring.
  """

  # Remove some things we use as hacks in Doxygen 1.7-1.8.

  docstring = docstring.replace(r'@~', '')
  p = re.compile('@par(\s)', re.MULTILINE)
  docstring = p.sub(r'\1', docstring)

  # Rewrite some common things.

  docstring = rewriteCommonReferences(docstring)

  # Rewrite some of the data type references to equivalent C# types.  (Note:
  # this rewriting affects only the documentation comments inside classes &
  # methods, not the actual method signatures.)

  docstring = docstring.replace(r'const char *', 'string ')
  docstring = docstring.replace(r'const char* ', 'string ')
  docstring = docstring.replace(r'an unsigned int', 'a long integer')
  docstring = docstring.replace(r'unsigned int', 'long')
  docstring = docstring.replace(r'const std::string&', 'string')
  docstring = docstring.replace(r'const std::string &', 'string ')
  docstring = docstring.replace(r'const std::string', 'string')
  docstring = docstring.replace(r'std::string', 'string')
  docstring = docstring.replace(r'const ', '')
  docstring = docstring.replace(r'NULL', 'null')
  docstring = docstring.replace(r'boolean', 'bool')

  # Use C# syntax instead of "const XMLNode*" etc.

  p = re.compile(r'const (%?)(' + '|'.join(libsbml_classes) + r')( ?)(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRefAddingSpace, docstring)
  p = re.compile(r'(%?)(' + '|'.join(libsbml_classes) + r')( ?)(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRefAddingSpace, docstring)

  # Do replacements on some documentation text we sometimes use.

  p = re.compile(r'libsbmlConstants([@.])')
  docstring = p.sub(r'libsbmlcs.libsbml\1', docstring)

  # Fix @link for constants that we forgot conditionalize in the source.

  p = re.compile(r'@link +([A-Z_0-9]+?)@endlink', re.DOTALL)
  docstring = p.sub(r'@link libsbml.\1@endlink', docstring)

  # Can't use math symbols.  Kluge around it.

  docstring = re.sub(r'\\f\$\\geq\\f\$', '>=', docstring)
  docstring = re.sub(r'\\f\$\\leq\\f\$', '<=', docstring)
  docstring = re.sub(r'\\f\$\\times\\f\$', '*', docstring)

  # Some additional special cases.

  docstring = docstring.replace(r'SBML_formulaToString()', 'libsbmlcs.libsbml.formulaToString()')
  docstring = docstring.replace(r'SBML_parseFormula()', 'libsbmlcs.libsbml.parseFormula()')

  # Need to escape the quotation marks:

  docstring = docstring.replace('"', "'")
  docstring = docstring.replace(r"'", r"\'")

  return docstring



def rewriteDocstringForPython (docstring):
  """rewriteDocstringForPython (docstring) -> docstring

  Performs some mimimal Python specific sanitizations on the
  C++/Doxygen docstring.

  Note: this is not the only processing performed for the Python
  documentation.  In docs/src, the doxygen-based code has an additional
  filter that processes the output of *this* filter.
  """

  # Rewrite some common things.

  docstring = rewriteCommonReferences(docstring)

  # Take out the C++ comment start and end.

  docstring = docstring.replace('/**', '').replace('*/', '')
  p = re.compile(r'^\s*\*[ \t]*', re.MULTILINE)
  docstring = p.sub(r'', docstring)

  # Rewrite some of the data type references to equivalent Python types.
  # (Note: this rewriting affects only the documentation comments inside
  # classes & methods, not the method signatures.)

  docstring = re.sub(r'const\s+char\s+\*',    'string ',        docstring)
  docstring = re.sub(r'const\s+char\* ',      'string ',        docstring)
  docstring = re.sub(r'const\s+std::string&', 'string',         docstring)
  docstring = re.sub(r'const\s+std::string',  'string',         docstring)
  docstring = re.sub(r'std::string',          'string',         docstring)
  docstring = re.sub(r'NULL',                 'None',           docstring)

  breakable_translations = [[r'an unsigned int',     'a long integer'],
                            [r'unsigned int',        'long'],
                            [r'@c (|")?true(|")?',   r'@c \1True\2'],
                            [r'@c (|")?false(|")?',  r'@c \1False\2'],
                            [r'@c double',           r'@c float']]

  docstring = translateAllowingBreaks(breakable_translations, docstring)

  # Also use Python syntax instead of "const XMLNode*" etc.

  p = re.compile(r'const (%?)(' + '|'.join(libsbml_classes) + r') ?(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRef, docstring)
  p = re.compile(r'(%?)(' + '|'.join(libsbml_classes) + r') ?(\*|&)', re.DOTALL)
  docstring = p.sub(rewriteClassRef, docstring)

  # Need to escape the quotation marks:

  docstring = docstring.replace('"', "'")
  docstring = docstring.replace(r"'", r"\'")

  # Python method cross-references won't be made by doxygen unless
  # the method reference is written without arguments.

  p = re.compile('(\s+)(\S+?)::(\w+\s*)(\([^)]*?\))', re.MULTILINE)
  docstring = p.sub(translatePythonCrossRef, docstring)
  p = re.compile('(@see\s+)(\w+\s*)(\([^)]*?\))')
  docstring = p.sub(translatePythonSeeRef, docstring)

  return docstring



def rewriteDocstringForPerl (docstring):
  """rewriteDocstringForPerl (docstring) -> docstring

  Performs some mimimal Perl specific sanitizations on the
  C++/Doxygen docstring.
  """

  docstring = rewriteCommonReferences(docstring)

  # Get rid of the /** ... */ and leading *'s.
  docstring = docstring.replace('/**', '').replace('*/', '').replace('*', ' ')

  # Get rid of indentation
  p = re.compile('^\s+(\S*\s*)', re.MULTILINE)
  docstring = p.sub(r'\1', docstring)

  # Get rid of paragraph indentation not caught by the code above.
  p = re.compile('^[ \t]+(\S)', re.MULTILINE)
  docstring = p.sub(r'\1', docstring)

  # Get rid of blank lines.
  p = re.compile('^[ \t]+$', re.MULTILINE)
  docstring = p.sub(r'', docstring)

  # Get rid of the %foo quoting.
  docstring = re.sub('(\s)%(\w)', r'\1\2', docstring)

  # The following are done in pairs because I couldn't come up with a
  # better way to catch the case where @c and @em end up alone at the end
  # of a line and the thing to be formatted starts on the next one after
  # the comment '*' character on the beginning of the line.

  docstring = re.sub('@c *([^ ,.:;()/*\n\t<]+)', r'C<\1>', docstring)
  docstring = re.sub('@c(\n[ \t]*\*[ \t]*)([^ ,.:;()/*\n\t<]+)', r'\1C<\2>', docstring)
  docstring = re.sub('@p +([^ ,.:;()/*\n\t<]+)', r'C<\1>', docstring)
  docstring = re.sub('@p(\n[ \t]*\*[ \t]+)([^ ,.:;()/*\n\t<]+)', r'\1C<\2>', docstring)
  docstring = re.sub('@em *([^ ,.:;()/*\n\t<]+)', r'I<\1>', docstring)
  docstring = re.sub('@em(\n[ \t]*\*[ \t]*)([^ ,.:;()/*\n\t<]+)', r'\1I<\2>', docstring)

  docstring = docstring.replace('<ul>', r'\n=over\n')
  docstring = docstring.replace('<li> ', r'\n=item\n\n')
  docstring = docstring.replace('</ul>', r'\n=back\n')

  docstring = docstring.replace(r'@returns?', 'Returns')
  docstring = docstring.replace(' < ', ' E<lt> ').replace(' > ', ' E<gt> ')
  docstring = re.sub('<code>([^<]*)</code>', r'C<\1>', docstring)
  docstring = re.sub('<b>([^<]*)</b>', r'B<\1>', docstring)  

  return docstring



def processClassMethods(ostream, c):
  # In the Python docs, we have to combine the docstring for methods with
  # different signatures and write out a single method docstring.  In the
  # other languages, we write out separate docstrings for every method
  # having a different signature.

  if language == 'python':
    written = {}
    for m in c.methods:
      if m.name + m.args in written:
        continue
      if m.name.startswith('~'):
        continue

      if c.methodVariants[m.name].__len__() > 1:

        # This method has more than one variant.  It's possible some or all
        # of them are marked @internal.  Therefore, before we start writing
        # a statement that there are multiple variants, we must check that
        # we're left with more than one non-internal method to document.
        count = 0
        for argVariant in list(c.methodVariants[m.name].values()):
          if re.search('@internal', argVariant.docstring) == None:
            count += 1
        if count <= 1:
          continue

        newdoc = ' This method has multiple variants; they differ in the' + \
                 ' arguments\n they accept.  Each variant is described' + \
                 ' separately below.\n'

        for argVariant in list(c.methodVariants[m.name].values()):
          # Each entry in the methodVariants dictionary is itself a dictionary.
          # The dictionary entries are keyed by method arguments (as strings).
          # The dictionary values are the 'func' objects we use.
          if re.search('@internal', argVariant.docstring) == None:
            newdoc += "\n@par\n<hr>\n<span class='variant-sig-heading'>Method variant with the following"\
                      + " signature</span>:\n <pre class='signature'>" \
                      + argVariant.name \
                      + rewriteDocstringForPython(argVariant.args) \
                      + "</pre>\n\n"
            newdoc += rewriteDocstringForPython(argVariant.docstring)
          written[argVariant.name + argVariant.args] = 1
      else:
        newdoc = rewriteDocstringForPython(m.docstring)
      ostream.write(formatMethodDocString(m.name, c.name, newdoc, m.isInternal, m.args, m))
      written[m.name + m.args] = 1
  else: # Not python
    for m in c.methods:
      if m.name.startswith('~'):
        continue
      if language == 'java':
        newdoc = rewriteDocstringForJava(m.docstring)
      elif language == 'csharp':
        newdoc = rewriteDocstringForCSharp(m.docstring)
      elif language == 'perl':
        newdoc = rewriteDocstringForPerl(m.docstring)
      # print c.name + ": " + m.name + " " + str(m.isInternal)
      ostream.write(formatMethodDocString(m.name, c.name, newdoc, m.isInternal, m.args, m))

  ostream.flush()



def formatMethodDocString (methodname, classname, docstring, isInternal, args=None, f = None):
  if language == 'java':
    pre  = '%javamethodmodifiers'
    post = ' public'
  elif language == 'csharp':
    pre  = '%csmethodmodifiers'
    if f != None and f.isVirtual:
      # this time we note right from the start, whether a function is virtual or not	  
      if classname in virtual_functions and methodname in virtual_functions[classname]:
        post = ' public virtual'
      else:
        post = ' public new'
    elif classname in virtual_functions and methodname in virtual_functions[classname]:
        post = ' public virtual'
    elif classname in overriders and methodname in overriders[classname]:
      # See the comment for the definition of 'overriders' for more info.
      post = ' public new'
    else:
      post = ' public'
    if isInternal:
      post = ' /* libsbml-internal */' + post
  elif language == 'perl':
    pre  = '=item'
    post = ''
  elif language == 'python':
    pre  = '%feature("docstring")'
    if isInternal:
      post = '\n\n@internal'
    else:
      post = ''

  output = pre + ' '

  if classname:
    output += classname + '::'

  if language == 'perl':
    output += '%s\n\n%s%s\n\n\n'   % (methodname, docstring.strip(), post)
  elif language == 'python':
    output += '%s "\n%s%s\n";\n\n\n' % (methodname, docstring.strip(), post)
  else:
    output += '%s%s "\n%s%s\n";\n\n\n' % (methodname, args, docstring.strip(), post)

  return output



def generateFunctionDocString (methodname, docstring, args, isInternal, f):
  if language == 'java':
    doc = rewriteDocstringForJava(docstring)
  elif language == 'csharp':
    doc = rewriteDocstringForCSharp(docstring)
  elif language == 'python':
    doc = rewriteDocstringForPython(docstring)
  elif language == 'perl':
    doc = rewriteDocstringForPerl(docstring)
  return formatMethodDocString(methodname, None, doc, isInternal, args, f)



def generateClassDocString (docstring, classname, isInternal):
  pretext   = ''
  separator = ''
  posttext  = ''

  if language == 'java':
    pretext   = '%typemap(javaimports) '
    separator = ' "\n'
    posttext  = '\n"\n\n\n'
    docstring = rewriteDocstringForJava(docstring).strip()

  elif language == 'python':
    pretext   = '%feature("docstring") '
    separator = ' "\n'
    posttext  = '\n";\n\n\n'
    docstring = rewriteDocstringForPython(docstring).strip()

  elif language == 'csharp':
    pretext   = '%typemap(csimports) '
    separator = ' "\n using System;\n using System.Runtime.InteropServices;\n\n'
    posttext  = '\n"\n\n\n'
    docstring = rewriteDocstringForCSharp(docstring).strip()

  elif language == 'perl':
    pretext   = '=back\n\n=head2 '
    separator = '\n\n'
    posttext  = '\n\n=over\n\n\n'
    docstring = rewriteDocstringForPerl(docstring).strip()

  # If this is one of our fake classes used for creating commonly-reused
  # documentation strings, we don't write it to the output file; we only
  # store the documentation string in a global variable to be used later.

  if classname.startswith('doc_'):
    allclassdocs[classname] = docstring
    return ''
  else:
    return pretext + classname + separator + docstring + posttext



def processClasses (ostream, classes):
  for c in classes:
    processClassMethods(ostream, c)



def processFunctions (ostream, functions):
  for f in functions:
    ostream.write(generateFunctionDocString(f.name, f.docstring, f.args, f.isInternal,f))



def processClassDocs (ostream, classDocs):
  for c in classDocs:
    ostream.write(generateClassDocString(c.docstring, c.name, c.isInternal))



def processFile (filename, ostream, language, preprocessor_defines):
  """processFile (filename, ostream, language, preprocessor_defines)

  Reads the the given header file and writes to ostream the necessary SWIG
  incantation to annotate each method (or function) with a docstring
  appropriate for the given language.
  """

  istream = open(filename)
  header  = CHeader(istream, language, preprocessor_defines)
  istream.close()

  processClassDocs(ostream, header.classDocs)
  processClasses(ostream, header.classes)
  processFunctions(ostream, header.functions)

  ostream.flush()



def postProcessOutputForPython(contents):
  """Do post-processing on the final output for Python."""

  # Friggin' doxygen escapes HTML character codes it doesn't understand, so
  # the hack we have to do for Javadoc turns out doesn't work for the Python
  # documentation.  Kluge around it.

  contents = re.sub(r'\\f\$\\geq\\f\$', '>=', contents)
  contents = re.sub(r'\\f\$\\leq\\f\$', '<=', contents)
  contents = re.sub(r'\\f\$\\times\\f\$', '*', contents)

  # Doxygen doesn't understand <nobr>.

  contents = re.sub(r'</?nobr>', '', contents)

  return contents



def postProcessOutput(istream, ostream):
  """postProcessOutput(instream, outstream)

  Post-processes the output to perform final substitutions."""

  contents = istream.read()

  # Repeatedly do substitutions for @copydetails/@copydoc, because some
  # inclusions may include others (and those then need to be expanded).
  # The loop limit is to avoid accidental infinite loops.
  iteration = 0
  while re.search('@copy(details|doc)', contents) != None and iteration < 10:
    p = re.compile('@copy(details|doc)\s+(\w+)')
    contents = p.sub(translateCopydetails, contents)
    iteration += 1

  # Do additional post-processing on a language-specific basis.

  if language == 'python':
    contents = postProcessOutputForPython(contents)
  elif language == 'java':
    # Javadoc doesn't have an @htmlinclude command, so we process the file
    # inclusion directly here.
    p = re.compile('@htmlinclude\s+(\*\s+)*([-\w."\']+)', re.DOTALL)   #'
    contents = p.sub(translateInclude, contents)

  ostream.write(contents)


#
# Top-level main function and command-line argument parser.
#

__desc_end = '''This file is part of libSBML.  Please visit http://sbml.org for
more information about SBML, and the latest version of libSBML.'''

def parse_cmdline(direct_args = None):
    parser = argparse.ArgumentParser(epilog=__desc_end)
    parser.add_argument("-d", "--define", action='append',
                        help="define #ifdef symbol when scanning files for includes")
    parser.add_argument("-e", "--extra", action='append',
                        help="read given file as an additional source file")
    parser.add_argument("-l", "--language", required=True,
                        help="language for which to generate SWIG docstrings")
    parser.add_argument("-m", "--master", required=True,
                        help="main SWIG interface .i file to read")
    parser.add_argument("-o", "--output", required=True,
                        help="output file to write SWIG docstrings")
    parser.add_argument("-t", "--top", required=True,
                        help="path to top of libSBML source directory")
    return parser.parse_args(direct_args)



def expanded_path(path):
    if path: return os.path.expanduser(os.path.expandvars(path))
    else:    return ''



def get_language(direct_args = None):
    return direct_args.language



def get_master_file(direct_args = None):
    return os.path.abspath(expanded_path(direct_args.master))



def get_output_file(direct_args = None):
    return os.path.abspath(expanded_path(direct_args.output))



def get_top_dir(direct_args = None):
    return os.path.abspath(expanded_path(direct_args.top))



def get_defines(direct_args = None):
  if direct_args.define: return direct_args.define
  else:                  return []



def get_extra_source_files(direct_args = None):
  if direct_args.extra: return direct_args.extra
  else:                 return []



def main (args):
  global doc_include_path
  global header_files
  global language
  global libsbml_classes
  global preprocessor_defines

  args                  = parse_cmdline()
  language              = get_language(args)
  main_swig_file        = get_master_file(args)
  output_swig_file      = get_output_file(args)
  h_include_path        = os.path.join(get_top_dir(args), 'src')
  doc_include_path      = os.path.join(get_top_dir(args), 'docs', 'src')
  preprocessor_defines += get_defines(args)
  extra_input_files     = get_extra_source_files(args)

  # We first write all our output to a temporary file.  Later, we open this
  # file, post-process it, and write the final output to the real destination.

  tmpfilename = output_swig_file + ".tmp"
  stream      = open(tmpfilename, 'w')

  # Find all class names, by searching header files for @class declarations
  # and SWIG .i files for %template declarations.  We need this list to
  # recognize when class names are mentioned inside documentation text.

  swig_files       = get_swig_files(main_swig_file)
  header_files     = get_header_files(swig_files, h_include_path)
  libsbml_classes  = libsbmlutils.find_classes(header_files)
  libsbml_classes += libsbmlutils.find_classes(swig_files)

  try:
    libsbml_classes  = sorted(list(set(libsbml_classes)))
  except (NameError,):
    libsbml_classes.sort()
  except (Exception,):
    e = sys.exc_info()[1]
    pass

  # Now, do the main processing pass, writing the output as we go along.

  if language == 'perl':
    if (os.path.exists(os.path.abspath('LibSBML.txt'))):
      infile = open(os.path.abspath('LibSBML.txt'), 'r')
    else:
      infile = open(h_include_path + '/bindings/perl/LibSBML.txt', 'r')
    stream.write(infile.read())
    stream.write('=head1 FUNCTION INDEX\n\n=over 8\n\n')

  for file in header_files:
    processFile(file, stream, language, preprocessor_defines)

  for file in extra_input_files:
    processFile(os.path.abspath(file), stream, language, preprocessor_defines)

  if os.path.exists('local-doc-extras.i'):
    stream.write('\n%include "local-doc-extras.i"\n')

  if language == 'perl':
    stream.write('=cut\n')

  stream.close()

  # Certain things can't be done until we have seen all the input.  So, now
  # we reopen the file we wrote, post-process the contents, and write the
  # results to the real destination (which is given as arg[5]).

  tmpstream   = open(tmpfilename, 'r')
  finalstream = open(output_swig_file, 'w')
  postProcessOutput(tmpstream, finalstream)

  try:
    tmpstream.flush()
    tmpstream.close()
  except (Exception,):
    e = sys.exc_info()[1]
    #FB: not printing the warning below, as after all the documentation file
    #    has been correctly created. 
    pass
    # print "\tWarning, error flushing stream \n\t\t'%s'. \n\tThis is not a serious error, but an issue with the python interpreter known to occur in python 2.7." % e
  finalstream.flush()
  finalstream.close()

  os.remove(tmpfilename)


if __name__ == '__main__':
  main(sys.argv)
 


## The following is for Emacs users.  Please leave in place.
## Local Variables: 
## python-indent-offset: 2
## End: 
