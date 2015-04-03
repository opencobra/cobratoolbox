#!/usr/bin/env ruby
#
# @file    printMath.rb
# @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
# @author  Alex Gutteridge (Ruby conversion of examples/c/printMath.c)
# @author  Ben Bornstein
# 
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

require 'libSBML'
     
module LibSBML
  class Model
    def printMath
      getNumFunctionDefinitions.times do |n|
        puts "Function #{n}: #{getFunctionDefinition(n)}" 
      end
      getNumRules.times do |n|
        puts "Rule #{n}: #{getRule(n)}"
      end  
      getNumReactions.times do |n|
        puts "Reaction #{n}: #{getReaction(n)}"
      end  
      getNumEvents.times do |n|
        puts "Event #{n} #{getEvent(n)}"
      end
    end
  end
  
  class FunctionDefinition
     def to_s
       s = ""
       if isSetMath
         s << "#{getId}("
         math = getMath
         
         #Print function args
         if math.getNumChildren > 1
           s << math.getLeftChild.getName
           ((math.getNumChildren)-2).times do |n|
             s << ", " + math.getChild(n+1).getName
           end
         end
         
         s << ") := "

         #Print function body
         if math.getNumChildren == 0
           s << "(no body defined)"
         else
           s << LibSBML::formulaToString(math.getChild(math.getNumChildren-1))
         end

         return s

       end
     end
  end
  class Rule
     def to_s
        if isSetMath
          LibSBML::formulaToString(getMath)
        end  
     end
  end
  class Reaction
    def to_s
      if isSetKineticLaw and getKineticLaw.isSetMath
         LibSBML::formulaToString(getKineticLaw.getMath)                                           
      end
    end
  end
  class EventAssignment
    def to_s
      if isSetMath
        "#{getVariable} = #{LibSBML::formulaToString(getMath)}" 
      end
    end
  end
  class Event
    def to_s
      d = ''
      t = ''
      a = []
      if isSetDelay
        d = "Delay: #{LibSBML::formulaToString(getDelay.getMath)} "
      end
      if isSetTrigger
        t = "Trigger: #{LibSBML::formulaToString(getTrigger.getMath)} "
      end
      getNumEventAssignments.times do |n|
         a << getEventAssignment(n).to_s 
      end
      d + t + a.join(", ")   
    end
  end
end
 
if ARGV.size != 1
  puts "Usage: printMath filename"
  exit(1)
end

d = LibSBML::readSBML(ARGV[0])
d.printErrors

d.getModel.printMath

