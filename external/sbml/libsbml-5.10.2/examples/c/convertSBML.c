/**
 * @file    convertSBML.c
 * @brief   Converts SBML documents between levels
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

#include <stdio.h>
#include <sbml/SBMLTypes.h>


int
main (int argc, char *argv[])
{
  unsigned int    latestLevel   = SBMLDocument_getDefaultLevel();
  unsigned int    latestVersion = SBMLDocument_getDefaultVersion();
  unsigned int    errors;
  SBMLDocument_t *d;


  if (argc != 3)
  {
    printf("Usage: convertSBML input-filename output-filename\n");
    printf("This program will attempt to convert a model either to\n");
    printf("SBML Level %d Version %d (if the model is not already) or, if",
	   latestLevel, latestVersion);
    printf("the model is already expressed in Level %d Version %d, this\n",
	   latestLevel, latestVersion);
    printf("program will attempt to convert the model to Level 1 Version 2.\n");
    return 1;
  }

  d      = readSBML(argv[1]);
  errors = SBMLDocument_getNumErrors(d);

  if (errors > 0)
  {
    printf("Encountered the following SBML error(s):\n");
    SBMLDocument_printErrors(d, stdout);
    printf("Conversion skipped.  Please correct the problems above first.\n");
    return errors;
  }
  else
  {
    unsigned int olevel   = SBMLDocument_getLevel(d);
    unsigned int oversion = SBMLDocument_getVersion(d);
    int success;

    if (olevel < latestLevel || oversion < latestVersion)
    {
      printf("Attempting to convert model to SBML Level %d Version %d.\n",
             latestLevel, latestVersion);
      success = SBMLDocument_setLevelAndVersion(d, latestLevel, latestVersion);
    }
    else
    {
      printf("Attempting to convert model to SBML Level 1 Version 2.\n");
      success = SBMLDocument_setLevelAndVersion(d, 1, 2);
    }

    errors = SBMLDocument_getNumErrors(d);

    if (!success)
    {
      printf("Unable to perform conversion due to the following:\n");
      SBMLDocument_printErrors(d, stdout);

      printf("Conversion skipped.  Either libSBML does not (yet) have\n");
      printf("ability to convert this model, or (automatic) conversion\n");
      printf("is not possible in this case.\n");
    }
    else if (errors > 0)
    {
      printf("Information may have been lost in conversion; but a valid model ");
      printf("was produced by the conversion.\nThe following information ");
      printf("was provided:\n");
      SBMLDocument_printErrors(d, stdout);
      writeSBML(d, argv[2]);
    }
    else
    { 	    
      printf("Conversion completed.\n");
      writeSBML(d, argv[2]);
    }
  }

  SBMLDocument_free(d);
  return errors;
}

