#!/usr/bin/env ruby
#
## 
## @file    unsetAnnotation.py
## @brief   unset annotation for each element
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
## 


require 'libSBML'


if (ARGV.size != 2):
    print("\nUsage: unsetAnnotation <input-filename> <output-filename>" + "\n" + "\n")
    exit(1);
end

filename = ARGV[0];

document = LibSBML::readSBML(filename)

errors = document.getNumErrors

if (errors > 0)
    document.printErrors
    return errors;
end

m = document.getModel
m.unsetAnnotation

m.getNumReactions.times do |i|
    re = m.getReaction(i)      
    re.unsetAnnotation

    re.getNumReactants.times do |j|
        rt = re.getReactant(j)
        rt.unsetAnnotation          
    end
    re.getNumProducts.times do |j|
        rt = re.getProduct(j)
        rt.unsetAnnotation
    end
    re.getNumModifiers.times do |j|
        md = re.getModifier(j)
        md.unsetAnnotation
    end
    if (re.isSetKineticLaw)
        kl = re.getKineticLaw
        kl.unsetAnnotation

        kl.getNumParameters.times do |j|
            pa = kl.getParameter(j)
            pa.unsetAnnotation
        end
    end
end
m.getNumSpecies.times do |i|
    sp = m.getSpecies(i)
    sp.unsetAnnotation
end
m.getNumCompartments.times do |i|
    sp = m.getCompartment(i)
    sp.unsetAnnotation
end
m.getNumFunctionDefinitions.times do |i|
    sp = m.getFunctionDefinition(i)
    sp.unsetAnnotation
end
m.getNumUnitDefinitions.times do |i|
    sp = m.getUnitDefinition(i)
    sp.unsetAnnotation
end
m.getNumParameters.times do |i|
    sp = m.getParameter(i)
    sp.unsetAnnotation
end
m.getNumRules.times do |i|
    sp = m.getRule(i)
    sp.unsetAnnotation
end
m.getNumInitialAssignments.times do |i|
    sp = m.getInitialAssignment(i)
    sp.unsetAnnotation
end
m.getNumEvents.times do |i|
    sp = m.getEvent(i)
    sp.unsetAnnotation

    sp.getNumEventAssignments.times do |j|
        ea = sp.getEventAssignment(j)
        ea.unsetAnnotation
    end
end
m.getNumSpeciesTypes.times do |i|
    sp = m.getSpeciesType(i)
    sp.unsetAnnotation
end
m.getNumConstraints.times do |i|
    sp = m.getConstraint(i)
    sp.unsetAnnotation
end
LibSBML::writeSBML(document, ARGV[1])

exit(errors);

