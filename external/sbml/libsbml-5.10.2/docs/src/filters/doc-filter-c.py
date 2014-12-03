#!/usr/bin/env python
#
# @file   doc-filter-c.py
# @brief  Post-process libSBML's source files for creating C docs with Doxygen.
# @author Michael Hucka
# @date   Created 2013-12-19
#
# This filter is hooked into our Doxygen configuration using the INPUT_FILTER
# configuration variable in doxygen-config-c.txt.in.  This means it's called
# on every input file before Doxygen sees it.
#
# The purpose of program is to look inside every comment, and translate class
# names from C to C_t.  It does this by looking at a list of all known
# classes (which is assumed to exist in a file named "class-list.txt" in the
# directory where it is called) and then doing text replacements on the input
# file.  The search tries to be careful to pick up only standalone references
# to the class names, and avoids those preceded by the percent character (%)
# which is Doxygen's symbol-quoting character.
#
# This first checks the environment variable LIBSBML_CLASSES_LIST; if it is
# set, the value is taken to be the path to a file containing the list of
# classes instead of the default file name "class-list.txt".
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

import sys, string, os, re

#
# Global variables.
#

libsbml_classes = []

#
# Helper functions.
#

def rewrite_references(match):
    body = match.group(1)

    # Replace class name C with C_t, except if the name is preceded by '%'
    # or suffixed with an underscore or ".h", ".cpp", and similar.

    p = re.compile(r'\b(?<!%)(' + '|'.join(libsbml_classes)
                   + r')(?!(\.h|\.cpp|\.c|_))\b')
    contents = p.sub(r'\1_t', body)
    return '/**' + contents + '*/'


def filter_contents (contents):
    global libsbml_classes

    p = re.compile(r'/\*\*(.+?)\*/', re.DOTALL | re.MULTILINE)
    contents = p.sub(rewrite_references, contents)

    return contents


#
# Main driver.
#

def main (args):
    """Usage: c-doc-filter.py  FILE
    """

    global libsbml_classes

    if len(args) != 2:
        print main.__doc__
        sys.exit(1)

    # Check if the environment variable LIBSBML_CLASSES_LIST is set.
    # If it is, use its value as the path to the classes list file.
    # If not, use a default name.

    if os.environ.get('LIBSBML_CLASSES_LIST'):
        classes_list_file = os.environ.get('LIBSBML_CLASSES_LIST')
    else:
        classes_list_file = 'class-list.txt'

    istream         = open(classes_list_file, 'r')
    libsbml_classes = istream.read().splitlines()
    istream.close()

    istream         = open(args[1], 'r')
    contents        = istream.read()
    istream.close()

    sys.stdout.write(filter_contents(contents))
    sys.exit(0)



if __name__ == '__main__':
  main(sys.argv)
