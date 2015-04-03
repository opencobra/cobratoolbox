#!/usr/bin/env python
## 
## @file    convertSBML.py
## @brief   Converts SBML documents between levels
## @author  Michael Hucka
## @author  Sarah Keating
## @author  Ben Bornstein
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
  """Usage: convertSBML input-filename output-filename
     This program will attempt to convert a model either to
     SBML Level 3 Version 1 (if the model is not already) or, if 
     the model is already expressed in Level 3 Version 1, this
     program will attempt to convert the model to Level 1 Version 2.     
  """

  latestLevel = SBMLDocument.getDefaultLevel();  
  latestVersion = SBMLDocument.getDefaultVersion();

  if len(args) != 3:
    print(main.__doc__)
    sys.exit(1)
  
  
  inputFile = args[1];
  outputFile = args[2];
  
  document = readSBML(inputFile);
  
  errors = document.getNumErrors();
  
  if (errors > 0):
      print("Encountered the following SBML errors:" + "\n");
      document.printErrors();
      print("Conversion skipped.  Please correct the problems above first."
      + "\n");
      return errors;
  
  # 
  # If the given model is not already L2v4, assume that the user wants to
  # convert it to the latest release of SBML (which is L2v4 currently).
  # If the model is already L2v4, assume that the user wants to attempt to
  # convert it down to Level 1 (specifically L1v2).
  # 
    
  olevel = document.getLevel();
  oversion = document.getVersion();
  success = False;
  
  if (olevel < latestLevel or oversion < latestVersion):
      print ("Attempting to convert Level " + str(olevel) + " Version " + str(oversion)
                                + " model to Level " + str(latestLevel)
                                + " Version " + str(latestVersion) + "." + "\n");
      success = document.setLevelAndVersion(latestLevel, latestVersion);
  else:
      print ("Attempting to convert Level " + str(olevel) + " Version " + str(oversion)
                                 + " model to Level 1 Version 2." + "\n");
      success = document.setLevelAndVersion(1, 2);
  
  errors = document.getNumErrors();
  
  if (not success):
      print("Unable to perform conversion due to the following:" + "\n");
      document.printErrors();
      print("\n");
      print("Conversion skipped.  Either libSBML does not (yet)" + "\n"
                                + "have the ability to convert this model or (automatic)" + "\n"
                                + "conversion is not possible in this case." + "\n");
  
      return errors;
  elif (errors > 0):
      print("Information may have been lost in conversion; but a valid model ");
      print("was produced by the conversion.\nThe following information ");
      print("was provided:\n");
      document.printErrors();
      writeSBML(document, outputFile);
  else:
      print("Conversion completed." + "\n");
      writeSBML(document, outputFile);
  return 0;
  
if __name__ == '__main__':
  main(sys.argv)  
