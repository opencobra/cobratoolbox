#!/usr/bin/env python
#
# @file   generate-class-name-list.py
# @brief  Generate a list of class names defined in libSBML
# @author Michael Hucka
# @date   Created 2013-12-19
#
# This program takes one argument, the root of the libSBML src/sbml
# directory.  It walks down the directory tree recursively, looking in .h
# files, and in every file it finds, it looks for the string "@class"
# followed by a word.  It extracts the word.  In the end, it prints to
# standard output all the words it found.
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

import os, sys, re
from os.path import join
sys.path.append('../../../src/bindings/swig')
sys.path.append('../../src/bindings/swig')
from libsbmlutils import find_classes


def main(args):
  if len(args) != 2:
      print ("Must be given one argument: the path to the libSBML src/sbml dir")
      sys.exit(1)

  classes = [re.sub('_t', '', c) for c in find_classes(args[1], True)]
  try:
    for c in sorted(set(classes)):
        print (c)
  except (NameError,):
    classes.sort()
    for c in classes:
        print (c)

if __name__ == '__main__':
  main(sys.argv)
