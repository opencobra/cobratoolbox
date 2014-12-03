/**
 * @file    convertReactions.cpp
 * @brief   Loads an SBML File and converts reactions to ODEs
 * @author  Sarah Keating
 * @author  Frank T. Bergmann
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */


#include <iostream>
#include <sbml/SBMLTypes.h>
#include <sbml/conversion/ConversionProperties.h>

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int
main (int argc, char *argv[])
{
 
  if (argc != 3)
  {
    cout 
	     << endl
		 << "Usage: convertReactions input-filename output-filename" << endl
	     << endl
	     << "This program will attempt to convert all reactions" << endl
	     << "contained in the source model, and write a new SBML file."
	     << endl
	     << endl;
    return 1;
  }

  const char* inputFile   = argv[1];
  const char* outputFile  = argv[2];

  // read document 
  SBMLDocument* document  = readSBML(inputFile);
  unsigned int  errors    = document->getNumErrors(LIBSBML_SEV_ERROR);

  // stop in case of errors
  if (errors > 0)
  {
    cerr << "Encountered the following SBML errors:" << endl;
    document->printErrors(cerr);
    cerr << "Conversion skipped.  Please correct the problems above first."
	 << endl;
    return errors;
  }

  // create conversion object that identifies the function definition converter
  ConversionProperties props;
  props.addOption("replaceReactions", true,
                 "Replace reactions with rateRules");
  
  // convert
  int success = document->convert(props);

  if (success != LIBSBML_OPERATION_SUCCESS)
  {
    cerr << "Unable to perform conversion due to the following:" << endl;
    document->printErrors(cerr);
    return errors;
  }   
  else
  {
    cout << "Conversion completed." << endl;
    writeSBML(document, outputFile);
  }

  return 0;
}


