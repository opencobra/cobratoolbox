#!/usr/bin/env python
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

import sys
import time
import os
import os.path
from libsbml import *

#
#Translates the given infix formula into MathML.
#
#@return the MathML as a string.  The caller owns the memory and is
#responsible for freeing it.
#
def translateInfix(formula):
    math = parseFormula(formula);
    return writeMathMLToString(math);

# 
# Translates the given MathML into an infix formula.  The MathML must
# contain no leading whitespace, but an XML header is optional.
# 
# @return the infix formula as a string.  The caller owns the memory and
# is responsible for freeing it.
# 
def translateMathML(xml):
    math = readMathMLFromString(xml);
    return formulaToString(math);

def main (args):
  """Usage: readSBML filename
  """

  
  print("This program translates infix formulas into MathML and");
  print("vice-versa.  Enter or return on an empty line triggers");
  print("translation. Ctrl-C quits");

  sb = ""  
  try:
    while True:
        print("Enter infix formula or MathML expression (Ctrl-C to quit):");
        print "> ",
    
        line = sys.stdin.readline()
        while line != None:
            trimmed = line.strip();
            length = len(trimmed);
            if (length > 0):
                sb = sb + trimmed;
            else:
                str = sb;
                result = ""
                if (str[0] == '<'):
	    			result = translateMathML(str)
                else:
	    		    result =  translateInfix(str)
    
                print("Result:\n\n" + result + "\n\n");
                sb = "";
                break;
    
            line = sys.stdin.readline()
  except: 
	return 0;
  return 0;

if __name__ == '__main__':
  main(sys.argv)  
