/**
* @file    promoteParameters.c
* @brief   promotes all local to global paramters
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


#include <stdio.h>
#include <sbml/SBMLTypes.h>
#include <sbml/conversion/ConversionProperties.h>


int
  main (int argc, char *argv[])
{
  SBMLDocument_t *doc;

  if (argc != 3)
  {
    printf("Usage: promoteParameters input-filename output-filename\n");
    return 2;
  }

  doc = readSBML(argv[1]);

  if (SBMLDocument_getNumErrorsWithSeverity(doc, LIBSBML_SEV_ERROR) > 0)
  {
    SBMLDocument_printErrors(doc, stderr);
  }
  else
  {
    /* need new variables ... */
    ConversionProperties_t* props;
    ConversionOption_t* option1;

    /* create a new conversion properties structure */
    props = ConversionProperties_create();

    /* add an option that we want to convert parameters */
    option1 = ConversionOption_create("promoteLocalParameters");
    ConversionOption_setType(option1, CNV_TYPE_BOOL);
    ConversionOption_setValue(option1, "true");
    ConversionOption_setDescription(option1, "Promotes all Local Parameters to Global ones");
    ConversionProperties_addOption(props, option1);
   
    /* perform the conversion */
    if (SBMLDocument_convert(doc, props) != LIBSBML_OPERATION_SUCCESS)
    {
      printf ("conversion failed ... ");
      return 3;
    }

    /* successfully completed, write the resulting file */
    writeSBML(doc, argv[2]);
  }

  return 0;
}

