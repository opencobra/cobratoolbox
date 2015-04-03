/**
 * @file    convertSBML.cpp
 * @brief   Converts SBML documents between levels
 * @author  Michael Hucka
 * @author  Sarah Keating
 * @author  Ben Bornstein
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

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int
main (int argc, char *argv[])
{
  const unsigned int latestLevel   = SBMLDocument::getDefaultLevel();
  const unsigned int latestVersion = SBMLDocument::getDefaultVersion();


  if (argc != 3)
  {
    cout << "Usage: convertSBML input-filename output-filename" << endl
	 << "This program will attempt to convert a model either to" << endl
	 << "SBML Level " << latestLevel << " Version " << latestVersion
	 << " (if the model is not already) or, if " << endl
	 << "the model is already expressed in Level " << latestLevel
	 << " Version " << latestVersion << ", this" << endl
	 << "program will attempt to convert the model to Level 1 Version 2."
	 << endl;
    return 1;
  }

  const char* inputFile   = argv[1];
  const char* outputFile  = argv[2];

  SBMLDocument* document  = readSBML(inputFile);
  unsigned int  errors    = document->getNumErrors();

  if (errors > 0)
  {
    cerr << "Encountered the following SBML errors:" << endl;
    document->printErrors(cerr);
    cerr << "Conversion skipped.  Please correct the problems above first."
	 << endl;
    return errors;
  }

  /**
   * If the given model is not already L2v4, assume that the user wants to
   * convert it to the latest release of SBML (which is L2v4 currently).
   * If the model is already L2v4, assume that the user wants to attempt to
   * convert it down to Level 1 (specifically L1v2).
   */

  unsigned int olevel   = document->getLevel();
  unsigned int oversion = document->getVersion();
  bool success;

  if (olevel < latestLevel || oversion < latestVersion)
  {
    cout << "Attempting to convert Level " << olevel << " Version " << oversion
	 << " model to Level " << latestLevel
	 << " Version " << latestVersion << "."  << endl;
    success = document->setLevelAndVersion(latestLevel, latestVersion);
  }
  else
  {
    cout << "Attempting to convert Level " << olevel << " Version " << oversion
	 << " model to Level 1 Version 2." << endl;
    success = document->setLevelAndVersion(1, 2);
  }

  errors = document->getNumErrors();

  if (!success)
  {
    cerr << "Unable to perform conversion due to the following:" << endl;
    document->printErrors(cerr);
    cout << endl;
    cout << "Conversion skipped.  Either libSBML does not (yet)" << endl
	 << "have the ability to convert this model or (automatic)" << endl
	 << "conversion is not possible in this case." << endl;

    delete document;
    return errors;
  }   
  else if (errors > 0)
  {
    cout << "Information may have been lost in conversion; but a valid model ";
    cout << "was produced by the conversion.\nThe following information ";
    cout << "was provided:\n";
    document->printErrors(cout);
    writeSBML(document, outputFile);
  }
  else
  {
    cout << "Conversion completed." << endl;
    writeSBML(document, outputFile);
  }

  delete document;
  return 0;
}


