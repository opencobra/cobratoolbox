#!/usr/bin/env python
#
# @file    doc-filter-csharp.py
# @brief   Post-process libSBML's csharp doc strings for use by Doxygen.
# @author  Michael Hucka
#
# Usage: csdocfilter.py libsbml.py > output.py
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


def filterForDoxygen (istream, ostream):
  # We read the stream line by line, looking for our marker.  The marker is
  # created by src/bindings/swig/swigdoc.py; it is *not* the same marker as
  # we use in Doxygen comments, but rather a separate marker used for
  # communication between swigdoc.py and this (csdocfilter.py) script.
  pattern = re.compile('(.+?)/\* libsbml-internal \*/(.+?)public(.+?)')
  for line in istream.readlines():
    match = pattern.search(line)
    if match:
      ostream.write(pattern.sub(r'\1\2private\3', line))
    else:
      ostream.write(line)


def main (args):
  """Usage: csdocfilter.py file > output

  This cooks the final output of our swigdoc.py + SWIG sequence for use
  with doxygen, to do additional transformations that can't be done in
  swigdoc.py because they rely on having in hand the final output from
  SWIG.  This only acts on files whose names end in .cs.
  """

  if len(args) != 2:
    print main.__doc__
    sys.exit(1)

  istream = open(args[1], 'r')

  # Only process the content if it's C#.
  if re.search('.cs$', args[1]):
    filterForDoxygen(istream, sys.stdout)
  else:
    sys.stdout.write(istream.read())

  istream.close()
  sys.exit(0)


if __name__ == '__main__':
  main(sys.argv)

