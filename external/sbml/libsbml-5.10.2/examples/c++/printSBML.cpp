/**
 * @file    printModel.cpp
 * @brief   Prints some information about the top-level model
 * @author  Sarah Keating
 * @author  Ben Bornstein
 * @author  Michael Hucka
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
main (int argc, char* argv[])
{
  if (argc != 2)
  {
    cout << endl << "Usage: printSBML filename" << endl << endl;
    return 1;
  }

  const char* filename   = argv[1];
  SBMLDocument* document = readSBML(filename);

  if (document->getNumErrors() > 0)
  {
    cerr << "Encountered the following SBML errors:" << endl;
    document->printErrors(cerr);
    return 1;
  }

  unsigned int level   = document->getLevel  ();
  unsigned int version = document->getVersion();

  cout << endl
       << "File: " << filename
       << " (Level " << level << ", version " << version << ")" << endl;

  Model* model = document->getModel();

  if (model == 0)
  {
    cout << "No model present." << endl;
    return 1;
  }

  cout << "               "
       << (level == 1 ? "name: " : "  id: ")
       << (model->isSetId() ? model->getId() : "(empty)") << endl;

  if (model->isSetSBOTerm())
    cout << "      model sboTerm: " << model->getSBOTerm() << endl;

  cout << "functionDefinitions: " << model->getNumFunctionDefinitions() << endl;
  cout << "    unitDefinitions: " << model->getNumUnitDefinitions    () << endl;
  cout << "   compartmentTypes: " << model->getNumCompartmentTypes   () << endl;
  cout << "        specieTypes: " << model->getNumSpeciesTypes       () << endl;
  cout << "       compartments: " << model->getNumCompartments       () << endl;
  cout << "            species: " << model->getNumSpecies            () << endl;
  cout << "         parameters: " << model->getNumParameters         () << endl;
  cout << " initialAssignments: " << model->getNumInitialAssignments () << endl;
  cout << "              rules: " << model->getNumRules              () << endl;
  cout << "        constraints: " << model->getNumConstraints        () << endl;
  cout << "          reactions: " << model->getNumReactions          () << endl;
  cout << "             events: " << model->getNumEvents             () << endl;
  cout << endl;

  delete document;
  return 0;
}
