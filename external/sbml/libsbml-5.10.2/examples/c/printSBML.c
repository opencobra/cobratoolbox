/**
 * @file    printSBML.c
 * @brief   Prints some information about the top-level model
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

#include <stdio.h>
#include <sbml/SBMLTypes.h>


int
main (int argc, char *argv[])
{
  const char *filename;

  SBMLDocument_t *d;
  Model_t        *m;

  unsigned int level, version;


  if (argc != 2)
  {
    printf("Usage: printSBML filename\n");
    return 2;
  }


  filename = argv[1];
  d        = readSBML(filename);

  SBMLDocument_printErrors(d, stdout);

  m = SBMLDocument_getModel(d);

  level   = SBMLDocument_getLevel  (d);
  version = SBMLDocument_getVersion(d);

  printf("\n");
  printf("File: %s (Level %u, version %u)\n", filename, level, version);

  if (m == NULL)
  {
    printf("No model present.");
    return 1;
  }

  printf("         ");
  printf("  model id: %s\n",  Model_isSetId(m) ? Model_getId(m) : "(empty)");

  printf( "functionDefinitions: %d\n",  Model_getNumFunctionDefinitions(m) );
  printf( "    unitDefinitions: %d\n",  Model_getNumUnitDefinitions    (m) );
  printf( "   compartmentTypes: %d\n",  Model_getNumCompartmentTypes   (m) );
  printf( "        specieTypes: %d\n",  Model_getNumSpeciesTypes       (m) );
  printf( "       compartments: %d\n",  Model_getNumCompartments       (m) );
  printf( "            species: %d\n",  Model_getNumSpecies            (m) );
  printf( "         parameters: %d\n",  Model_getNumParameters         (m) );
  printf( " initialAssignments: %d\n",  Model_getNumInitialAssignments (m) );
  printf( "              rules: %d\n",  Model_getNumRules              (m) );
  printf( "        constraints: %d\n",  Model_getNumConstraints        (m) );
  printf( "          reactions: %d\n",  Model_getNumReactions          (m) );
  printf( "             events: %d\n",  Model_getNumEvents             (m) );
  printf( "\n" );

  SBMLDocument_free(d);
  return 0;
}

