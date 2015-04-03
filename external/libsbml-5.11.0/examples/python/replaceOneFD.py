#!/usr/bin/env python
## 
## @file    replaceOneFD.py
## @brief   replaces a given function definition in a specific part of the model
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
import libsbml

def main (args):
    """Usage: replaceOneFD filename functionDefinitionId reactionId outfile
    """
    if (len(args) != 5):
      print("Usage: replaceOneFD filename functionDefinitionId reactionId outfile");
      return 1;

    filename = args[1];
    outFile = args[4];
    functionDefinitionId = args[2];
    reactionId = args[3];
    document = libsbml.readSBML(filename);

    if (document.getNumErrors(libsbml.LIBSBML_SEV_ERROR)  > 0):
      print("The models contains errors, please correct them before continuing.");
      document.printErrors();
      return 1;

    model = document.getModel();
    functionDefinition = model.getFunctionDefinition(functionDefinitionId);
    if (functionDefinition == None):
      print();
      print("No functiondefinition with the given id can be found.");
      return 1;

    reaction = model.getReaction(reactionId);
    if (reaction == None):
      print();
      print("No reaction with the given id can be found.");
      return 1;

    if (reaction.isSetKineticLaw() == False or reaction.getKineticLaw().isSetMath()== False):
      print();
      print("The reaction has no math set. ");
      return 1;

    # Until here it was all setup, all we needed was an ASTNode, in which we wanted to 
    # replace calls to a function definition, with the function definitions content. 
    #
    libsbml.SBMLTransforms.replaceFD(reaction.getKineticLaw().getMath(), functionDefinition);

    # finally write to file
    libsbml.writeSBML(document, outFile);
   
if __name__ == '__main__':
  main(sys.argv)  
