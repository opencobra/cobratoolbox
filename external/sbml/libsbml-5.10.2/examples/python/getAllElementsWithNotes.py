#!/usr/bin/env python
##
## @file    getAllElementsWithNotes.py
## @brief   Utility program, demontrating how to use the element filter
##          class to search the model for elements with specific attributes
##          in this example, we look for elements with notes
##
## @author  Frank T. Bergmann
## 
## 
## <!--------------------------------------------------------------------------
## This sample program is distributed under a different license than the rest
## of libSBML.  This program uses the open-source MIT license, as follows:
##
## Copyright (c) 2013-2014 by the California Institute of Technology
## (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
## and the University of Heidelberg (Germany), with support from the National
## Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
##
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.
##
## Neither the name of the California Institute of Technology (Caltech), nor
## of the European Bioinformatics Institute (EMBL-EBI), nor of the University
## of Heidelberg, nor the names of any contributors, may be used to endorse
## or promote products derived from this software without specific prior
## written permission.
## ------------------------------------------------------------------------ -->
## 
## 

import sys
import os.path
import time 
import libsbml

# This class implements an element filter, that can be used to find elements
# with notes
class NotesFilter(libsbml.ElementFilter):
  def __init__(self):
    # call the constructor of the base class
    libsbml.ElementFilter.__init__(self)
	
  # The function performing the filtering, here we just check 
  # that we have a valid element, and that it has notes. 
  def filter(self, element):
    # return in case we don't have a valid element
    if (element == None or element.isSetNotes() == False):
        return False;
    # otherwise we have notes set and want to keep the element
    if (element.isSetId()):
      print "                     found : {0}".format(element.getId()) 
    else: 
      print "                     found element without id" 
    return True

def main (args):
  """Usage: getAllElementsWithNotes filename
  """
  if len(args) != 2:
    print(main.__doc__)
    sys.exit(1)
  
  filename = args[1];
  
  # read the document
  start = time.time() * 1000;
  document = libsbml.readSBMLFromFile(filename);
  stop = time.time() * 1000;
  
  
  print ""
  print "            filename: {0}".format( filename);
  print "      read time (ms): {0}".format( stop - start);
  
  # stop in case of serious errors
  errors = document.getNumErrors(libsbml.LIBSBML_SEV_ERROR);
  if (errors > 0):
      print "            error(s): {0}".format(errors);
      document.printErrors();
      sys.exit (errors);
  
  
  # create the filter we want to use
  filter = NotesFilter()

  # get a list of all elements with notes
  start = time.time() * 1000;
  print "    searching ......:"
  allElements = document.getListOfAllElements(filter);
  stop = time.time() * 1000;
  print "    search time (ms): {0}".format(stop - start);

  print " elements with notes: {0}".format(allElements.getSize())
  
  # if we got here all went well ... 
  
if __name__ == '__main__':
  main(sys.argv)  
