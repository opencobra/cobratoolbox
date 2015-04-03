#!/usr/bin/env ruby
#
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


require 'libSBML'

if (ARGV.size != 1)
    print("\n" + "Usage: printSBML filename" + "\n" + "\n")
    return 1;
end

filename = ARGV[0];
document = LibSBML::readSBML(filename)

if (document.getNumErrors > 0)
    printLine("Encountered the following SBML errors:" + "\n")
    document.printErrors
    exit(1);
end

level = document.getLevel
version = document.getVersion

print("\nFile: #{filename} (Level #{level}, version #{version})\n")

model = document.getModel

if (model == nil)
    print("No model present." + "\n")
    exit(1);
end

idString = "id"
if (level == 1)
  idString = "name"
end
id = "(empty)"
if (model.isSetId)
  id = model.getId
end
print("                 #{idString}: #{id}\n")

if (model.isSetSBOTerm)
    print("      model sboTerm: " + model.getSBOTerm + "\n")
end

print("functionDefinitions: #{model.getNumFunctionDefinitions}\n")
print("    unitDefinitions: #{model.getNumUnitDefinitions}\n")
print("   compartmentTypes: #{model.getNumCompartmentTypes}\n")
print("        specieTypes: #{model.getNumSpeciesTypes}\n")
print("       compartments: #{model.getNumCompartments}\n")
print("            species: #{model.getNumSpecies}\n")
print("         parameters: #{model.getNumParameters}\n")
print(" initialAssignments: #{model.getNumInitialAssignments}\n")
print("              rules: #{model.getNumRules}\n")
print("        constraints: #{model.getNumConstraints}\n")
print("          reactions: #{model.getNumReactions}\n")
print("             events: #{model.getNumEvents}\n")
print("\n")

exit(0);
 
