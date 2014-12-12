#!/usr/bin/env ruby
#
## 
## @file    translateMath.py
## @brief   Translates infix formulas into MathML and vice-versa
## @author  Sarah Keating
## @author  Ben Bornstein
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


#
#Translates the given infix formula into MathML.
#
#@return the MathML as a string.  The caller owns the memory and is
#responsible for freeing it.
#
def translateInfix(formula)
    math = LibSBML::parseFormula(formula);
    return LibSBML::writeMathMLToString(math);
end
# 
# Translates the given MathML into an infix formula.  The MathML must
# contain no leading whitespace, but an XML header is optional.
# 
# @return the infix formula as a string.  The caller owns the memory and
# is responsible for freeing it.
# 
def translateMathML(xml)
    math = LibSBML::readMathMLFromString(xml);
    return LibSBML::formulaToString(math);
end

# don't print the exception 
trap("SIGINT") { exit! }

puts "This program translates infix formulas into MathML and"
puts "vice-versa.  Enter or return on an empty line triggers"
puts "translation. Ctrl-C quits"

sb = ""  
begin
  while true
      puts "Enter infix formula or MathML expression (Ctrl-C to quit):"
      print ("> ")
      STDOUT.flush
  
      line = gets
      while line != nil:
          trimmed = line.strip!
          length = trimmed.size
          if (length > 0)
              sb = sb + trimmed;
          else
              str = sb;
              result = ""
              if (str[0] == 60)
    	  result = translateMathML(str)
              else
    	  result =  translateInfix(str)
              end    
              print("Result:\n\n #{result}\n\n");
              sb = "";
              break;
          end
          line = gets
      end
   end
rescue SystemExit, Interrupt, Exception
end
