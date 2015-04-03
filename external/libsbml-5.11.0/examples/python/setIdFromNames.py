#!/usr/bin/env python
##
## @file    setIdFromNames.py
## @brief   Utility program, renaming all SIds that also has
##          names specified. The new id will be derived from
##          the name, with all invalid characters removed. 
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

# This class implements an identifier transformer, that means it can be used
# to rename all sbase elements. 
class SetIdFromNames(libsbml.IdentifierTransformer):
  def __init__(self, ids):
    # call the constructor of the base class
    libsbml.IdentifierTransformer.__init__(self)
	# remember existing ids ...
    self.existingIds = ids   
	
  # The function actually doing the transforming. This function is called 
  # once for each SBase element in the model. 
  def transform(self, element):
    # return in case we don't have a valid element
    if (element == None or element.getTypeCode() == libsbml.SBML_LOCAL_PARAMETER):
        return libsbml.LIBSBML_OPERATION_SUCCESS;
    
    # or if there is nothing to do
    if (element.isSetName() == False or element.getId() == element.getName()):
        return libsbml.LIBSBML_OPERATION_SUCCESS;

	# find the new id
    newId = self.getValidIdForName(element.getName());
	
    # set it
    element.setId(newId);

    # remember it
    self.existingIds.append(newId);
    
    return libsbml.LIBSBML_OPERATION_SUCCESS;

  def nameToSbmlId(self, name):
    IdStream = []
    count = 0;
    end = len(name)
    
    if '0' <= name[count] and name[count] <= '9':
      IdStream.append('_');
    for  count in range (0, end):     
      if (('0' <= name[count] and name[count] <= '9') or
          ('a' <= name[count] and name[count] <= 'z') or
          ('A' <= name[count] and name[count] <= 'Z')):
          IdStream.append(name[count]);
      else:
          IdStream.append('_');
    Id = ''.join(IdStream);
    if (Id[len(Id) - 1] != '_'):
        return Id;
    
    return Id[:-1]
  # 
  # Generates the id out of the name, and ensures it is unique. 
  # It does so by appending numbers to the original name. 
  # 
  def getValidIdForName(self, name):
    baseString = self.nameToSbmlId(name);
    id = baseString;
    count = 1;
    while (self.existingIds.count(id) != 0):
      id = "{0}_{1}".format(baseString, count);
      count = count + 1
    return id;

      
      
# 
# Returns a list of all ids from the given list of elements
# 
def getAllIds(allElements):
    result = []
    if (allElements == None or allElements.getSize() == 0):
        return result;

    for i in range (0, allElements.getSize()):
        current = allElements.get(i);
        if (current.isSetId() and current.getTypeCode() != libsbml.SBML_LOCAL_PARAMETER):
            result.append(current.getId());
    return result;



def main (args):
  """Usage: setIdFromNames filename output
  """
  if len(args) != 3:
    print(main.__doc__)
    sys.exit(1)
  
  filename = args[1];
  output = args[2];
  
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
  
  
  # get a list of all elements, as we will need to know all identifiers
  # so that we don't create duplicates. 
  allElements = document.getListOfAllElements();
  
  # get a list of all ids
  allIds = getAllIds(allElements);
  
  # create the transformer with the ids
  trans = SetIdFromNames(allIds);
  
  # rename the identifiers (using the elements we already gathered before)
  start = time.time() * 1000;
  document.getModel().renameIDs(allElements, trans);
  stop = time.time() * 1000;
  print "    rename time (ms): {0}".format(stop - start);
  
  # write to file
  start = time.time() * 1000;
  libsbml.writeSBMLToFile(document, output);
  stop = time.time() * 1000;
  print "     write time (ms): {0}".format(stop - start);
  print "";
  
  # if we got here all went well ... 
  
if __name__ == '__main__':
  main(sys.argv)  
