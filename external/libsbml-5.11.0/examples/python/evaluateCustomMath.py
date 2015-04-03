#!/usr/bin/env python
## 
## @file    evaluateCustomMath.py
## @brief   evaluates the given formula
## @author  Frank Bergmann
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
## THE SOFTWARE IS PROVIDED "AS IS",        WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
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
import libsbml

def main (args):
    """Usage: evaluateCustomMath formula [model containing values]
    """
    if len(args) < 2:
      print("Usage: evaluateCustomMath formula [model containing values]")
      return 1;

    formula = args[1];
    filename = None
    if (len(args) > 2):
        filename = args[2]

    math = libsbml.parseFormula(formula);
    if (math == None):
      print("Invalid formula, aborting.");
      return 1;

    doc = None;
    if filename != None:
      doc = libsbml.readSBML(filename);
      if doc.getNumErrors(libsbml.LIBSBML_SEV_ERROR) > 0:
        print("The models contains errors, please correct them before continuing.");
        doc.printErrors();
        return 1;
      # the following maps a list of ids to their corresponding model values
      # this makes it possible to evaluate expressions involving SIds. 
      libsbml.SBMLTransforms.mapComponentValues(doc.getModel());    
    else:
      # create dummy document
      doc = libsbml.SBMLDocument(3, 1);

    result = libsbml.SBMLTransforms.evaluateASTNode(math, doc.getModel());
    print("{0} = {1}".format(formula, result));
   
if __name__ == '__main__':
  main(sys.argv)  
