#!/usr/bin/env python
## 
## @file    printModel.py
## @brief   Prints some information about the top-level model
## @author  Sarah Keating
## @author  Ben Bornstein
## @author  Michael Hucka
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

import sys
import os.path
from libsbml import *

def main (args):
  """Usage: printNotes filename
  """
  
  
  if (len(args) != 2):
      print("\n" + "Usage: printSBML filename"  );
      return 1;
  
  filename = args[1];
  document = readSBML(filename);
  
  if (document.getNumErrors() > 0):
      printLine("Encountered the following SBML errors:" );
      document.printErrors();
      return 1;
  
  level = document.getLevel();
  version = document.getVersion();
  
  print("\n"
                        + "File: " + filename
                        + " (Level " + str(level) + ", version " + str(version) + ")" );
  
  model = document.getModel();
  
  if (model == None):
      print("No model present." );
      return 1;
  
  idString = "  id: "
  if (level == 1):
	idString = "name: "
  id = "(empty)"
  if (model.isSetId()):
	id = model.getId()
  print("               "
                        + idString
                        + id );
  
  if (model.isSetSBOTerm()):
      print("      model sboTerm: " + model.getSBOTerm() );
  
  print("functionDefinitions: " + str(model.getNumFunctionDefinitions()) );
  print("    unitDefinitions: " + str(model.getNumUnitDefinitions()) );
  print("   compartmentTypes: " + str(model.getNumCompartmentTypes()) );
  print("        specieTypes: " + str(model.getNumSpeciesTypes()) );
  print("       compartments: " + str(model.getNumCompartments()) );
  print("            species: " + str(model.getNumSpecies()) );
  print("         parameters: " + str(model.getNumParameters()) );
  print(" initialAssignments: " + str(model.getNumInitialAssignments()) );
  print("              rules: " + str(model.getNumRules()) );
  print("        constraints: " + str(model.getNumConstraints()) );
  print("          reactions: " + str(model.getNumReactions()) );
  print("             events: " + str(model.getNumEvents()) );
  print("\n");
  
  return 0;
 
if __name__ == '__main__':
  main(sys.argv)  
