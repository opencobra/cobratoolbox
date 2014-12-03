#!/usr/bin/env python
## 
## @file    printUnits.py
## @brief   Prints some unit information about the model
## @author  Sarah Keating
## @author  Michael Hucka
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

import sys
import os.path
from libsbml import *

def main (args):
  """Usage: printUnits filename
  """

  if (len(args) != 2):
      print("Usage: printUnits filename");
      return 1;
  
  filename = args[1];
  document = readSBML(filename);
  
  if (document.getNumErrors() > 0):
      print("Encountered the following SBML errors:");
      document.printErrors();
      return 1;
  
  model = document.getModel();
  
  if (model == None):
      print("No model present.");
      return 1;

  for i in range(0, model.getNumSpecies()):
      s = model.getSpecies(i);
      print("Species " + str(i) + ": "
      + UnitDefinition.printUnits(s.getDerivedUnitDefinition()));
  
  for i in range(0,model.getNumCompartments()):
      c = model.getCompartment(i);
      print("Compartment " + str(i) + ": "
                                    + UnitDefinition.printUnits(c.getDerivedUnitDefinition()))
  
  for i in range(0,model.getNumParameters()):
      p = model.getParameter(i);
      print("Parameter " + str(i) + ": "
                                    + UnitDefinition.printUnits(p.getDerivedUnitDefinition()))
  
  for i in range(0,model.getNumInitialAssignments()):
      ia = model.getInitialAssignment(i);
      print("InitialAssignment " + str(i) + ": "
                                    + UnitDefinition.printUnits(ia.getDerivedUnitDefinition()));
      tmp = "no"
      if (ia.containsUndeclaredUnits()):
		tmp = "yes"
      print("        undeclared units: " + tmp);
  
  for i in range(0,model.getNumEvents()):
      e = model.getEvent(i);
      print("Event " + str(i) + ": ");
  
      if (e.isSetDelay()):
          print("Delay: "
                                            + UnitDefinition.printUnits(e.getDelay().getDerivedUnitDefinition()));
          tmp = "no"
          if (e.getDelay().containsUndeclaredUnits()):
		    tmp = "yes"
          print("        undeclared units: " + tmp);
  
      for j in range(0,e.getNumEventAssignments()):
          ea = e.getEventAssignment(j);
          print("EventAssignment " + str(j) + ": "
                                            + UnitDefinition.printUnits(ea.getDerivedUnitDefinition()));
          tmp = "no"
          if (ea.containsUndeclaredUnits()):
		    tmp = "yes"
          print("        undeclared units: " + tmp);
  
  for i in range(0,model.getNumReactions()):
      r = model.getReaction(i);
  
      print("Reaction " + str(i) + ": ");
  
      if (r.isSetKineticLaw()):
          print("Kinetic Law: "
                                            + UnitDefinition.printUnits(r.getKineticLaw().getDerivedUnitDefinition()));
          tmp = "no"
          if (r.getKineticLaw().containsUndeclaredUnits()):
		    tmp = "yes"
          print("        undeclared units: " + tmp);
  
      for j in range(0,r.getNumReactants()):
          sr = r.getReactant(j);
  
          if (sr.isSetStoichiometryMath()):
              print("Reactant stoichiometryMath" + str(j) + ": "
                                                    + UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
              tmp = "no"
              if (sr.getStoichiometryMath().containsUndeclaredUnits()):
		        tmp = "yes"
              print("        undeclared units: " + tmp);              
  
      for j in range(0,r.getNumProducts()):
          sr = r.getProduct(j);
  
          if (sr.isSetStoichiometryMath()):
              print("Product stoichiometryMath" + str(j) + ": "
                                                    + UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
              tmp = "no"
              if (sr.getStoichiometryMath().containsUndeclaredUnits()):
		        tmp = "yes"
              print("        undeclared units: " + tmp);    
  
  for i in range(0,model.getNumRules()):
      r = model.getRule(i);
      print("Rule " + str(i) + ": "
                                    + UnitDefinition.printUnits(r.getDerivedUnitDefinition()));
      tmp = "no"
      if (r.getStoichiometryMath().containsUndeclaredUnits()):
		tmp = "yes"
      print("        undeclared units: " + tmp);    
  
  return 0;
  
if __name__ == '__main__':
  main(sys.argv)  
