#!/usr/bin/env python
##
## @file    test.py
## @brief   AutoRunner for Python test scripts
## @author  Akiya Jouraku
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

import os
import sys
import re
import glob
import unittest

test_basedir = 'test'
test_subdirs = ['sbml','xml','math','annotation']
test_files   = "/Test*.py"

def suite():
  suite = unittest.TestSuite()
  cwd = os.getcwd()    
  sys.path.append(cwd)
  os.chdir(test_basedir + '/..')
  for subdir in test_subdirs :
    sys.path.append(test_basedir + '/' + subdir)
    for file in glob.glob( test_basedir + '/' + subdir + '/' + test_files ) :
      module_name = re.compile(r"\.py$").sub('',os.path.basename(file))     
      module = __import__(module_name)
      class_name = getattr(module, module_name)
      suite.addTest(unittest.makeSuite(class_name))
  return suite

if __name__ == "__main__":
  if len(sys.argv) > 1: 
    # parse additional command line arguments
    for index in range(1, len(sys.argv)):
      current = sys.argv[index]
      hasNext = (index + 1) < len(sys.argv)
      nextIndex = (index + 1);
      if current == "-b" and hasNext:
        # allow to set the base path
        test_basedir = sys.argv[nextIndex];
        index = nextIndex
      elif current == "-p" and hasNext:
        # add directory to path
        sys.path.append(sys.argv[nextIndex])
        index = nextIndex
      elif current == "-a" and hasNext:
        # allow to test additional directories
        test_subdirs = test_subdirs  + sys.argv[nextIndex:]
        break;
  if unittest.TextTestRunner(verbosity=1).run(suite()).wasSuccessful() :
    sys.exit(0)
  else:
    sys.exit(1)

