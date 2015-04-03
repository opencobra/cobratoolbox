#!/usr/bin/env python
##
## @file    unsetNotes.py
## @brief   unset notes for each element
## @author  Akiya Jouraku
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

import sys
import time
import os
import os.path
from libsbml import *

def main (args):
  """Usage: unsetNotes <input-filename> <output-filename>
  """
  if (len(args) != 3):
      print("\n" + "Usage: unsetNotes <input-filename> <output-filename>" + "\n" + "\n");
      return 1;
  
  filename = args[1];
  
  document = readSBML(filename);
  
  
  errors = document.getNumErrors();
  
  if (errors > 0):
      document.printErrors();
      return errors;
  
  m = document.getModel();
  m.unsetNotes();
  
  for i in range(0, m.getNumReactions()):
      re = m.getReaction(i);
      re.unsetNotes();
  
      for j in range(0, re.getNumReactants()):
          rt = re.getReactant(j);
          rt.unsetNotes();
  
      for j in range(0, re.getNumProducts()):
          rt = re.getProduct(j);
          rt.unsetNotes();
  
      for j in range(0, re.getNumModifiers()):
          md = re.getModifier(j);
          md.unsetNotes();
  
      if (re.isSetKineticLaw()):
          kl = re.getKineticLaw();
          kl.unsetNotes();
  
          for j in range(0, kl.getNumParameters()):
              pa = kl.getParameter(j);
              pa.unsetNotes();
  
  for i in range(0, m.getNumSpecies()):
      sp = m.getSpecies(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumCompartments()):
      sp = m.getCompartment(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumFunctionDefinitions()):
      sp = m.getFunctionDefinition(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumUnitDefinitions()):
      sp = m.getUnitDefinition(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumParameters()):
      sp = m.getParameter(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumRules()):
      sp = m.getRule(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumInitialAssignments()):
      sp = m.getInitialAssignment(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumEvents()):
      sp = m.getEvent(i);
      sp.unsetNotes();
  
      for j in range(0, sp.getNumEventAssignments()):
          ea = sp.getEventAssignment(j);
          ea.unsetNotes();
  
  for i in range(0, m.getNumSpeciesTypes()):
      sp = m.getSpeciesType(i);
      sp.unsetNotes();
  
  for i in range(0, m.getNumConstraints()):
      sp = m.getConstraint(i);
      sp.unsetNotes();
  
  writeSBML(document, args[2]);
  
  return errors;

if __name__ == '__main__':
  main(sys.argv)  
