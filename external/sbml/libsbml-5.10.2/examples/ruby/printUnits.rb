#!/usr/bin/env ruby
#
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


require 'libSBML'


if (ARGV.size != 1)
    puts "Usage: printUnits filename"
    return 1;
end

filename = ARGV[0];
document = LibSBML::readSBML(filename)

if (document.getNumErrors > 0)
    puts "Encountered the following SBML errors:"
    document.printErrors
    exit(1);
end
model = document.getModel

if (model == nil)
    puts "No model present."
    exit(1);
end
model.getNumSpecies.times do |i|
    s = model.getSpecies(i)
    puts "Species #{i}: #{LibSBML::UnitDefinition.printUnits(s.getDerivedUnitDefinition)}\n"
end
model.getNumCompartments.times do |i|
    c = model.getCompartment(i)
    puts "Compartment #{i}: #{LibSBML::UnitDefinition.printUnits(c.getDerivedUnitDefinition)}\n"
end
model.getNumParameters.times do |i|
    p = model.getParameter(i)
    puts "Parameter #{i}: #{LibSBML::UnitDefinition.printUnits(p.getDerivedUnitDefinition)}\n"
end
model.getNumInitialAssignments.times do |i|
    ia = model.getInitialAssignment(i)
    print("InitialAssignment #{i}: #{LibSBML::UnitDefinition.printUnits(ia.getDerivedUnitDefinition)}\n")
    tmp = "no"
    if (ia.containsUndeclaredUnits)
	  tmp = "yes"
    end
    print("        undeclared units: #{tmp}")
end
model.getNumEvents.times do |i|
    e = model.getEvent(i)
    puts "Event #{i}: "

    if (e.isSetDelay)
        print("\n\tDelay: #{LibSBML::UnitDefinition.printUnits(e.getDelay.getDerivedUnitDefinition)}\n")
        tmp = "no"
        if (e.getDelay.containsUndeclaredUnits)
	      tmp = "yes"
        end
        print("        undeclared units: #{tmp}")
    end
    e.getNumEventAssignments.times do |j|
        ea = e.getEventAssignment(j)
        print("\n\tEventAssignment #{j}: #{LibSBML::UnitDefinition.printUnits(ea.getDerivedUnitDefinition)}\n")
        tmp = "no"
        if (ea.containsUndeclaredUnits)
	      tmp = "yes"
        end
        print("        undeclared units: #{tmp}")
    end
end
model.getNumReactions.times do |i|
    r = model.getReaction(i)

    print("\nReaction #{i}: ")

    if (r.isSetKineticLaw)
        print("Kinetic Law: #{LibSBML::UnitDefinition.printUnits(r.getKineticLaw.getDerivedUnitDefinition)}\n")
        tmp = "no"
        if (r.getKineticLaw.containsUndeclaredUnits)
	      tmp = "yes"
        end
        print("        undeclared units: #{tmp}")
    end
    r.getNumReactants.times do |j|
        sr = r.getReactant(j)

        if (sr.isSetStoichiometryMath)
            print("Reactant stoichiometryMath #{j}: #{LibSBML::UnitDefinition.printUnits(sr.getStoichiometryMath.getDerivedUnitDefinition)}\n")
            tmp = "no"
            if (sr.getStoichiometryMath.containsUndeclaredUnits)
	          tmp = "yes"
            end
            print("        undeclared units: #{tmp}")
        end
    end
    r.getNumProducts.times do |j|
        sr = r.getProduct(j)

        if (sr.isSetStoichiometryMath)
            print("Product stoichiometryMath #{j}: #{LibSBML::UnitDefinition.printUnits(sr.getStoichiometryMath.getDerivedUnitDefinition)}\n")
            tmp = "no"
            if (sr.getStoichiometryMath.containsUndeclaredUnits)
	          tmp = "yes"
            end
           print("        undeclared units: #{tmp}")
        end
    end
end
model.getNumRules.times do |i|
    r = model.getRule(i)
    print("\nRule #{i}: #{LibSBML::UnitDefinition.printUnits(r.getDerivedUnitDefinition)}\n")
    tmp = "no"
    if (r.getStoichiometryMath.containsUndeclaredUnits)
	  tmp = "yes"
    end
    print("        undeclared units: #{tmp}")
end
puts
exit(0);
  
