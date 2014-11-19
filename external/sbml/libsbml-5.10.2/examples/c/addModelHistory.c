/**
 * \file    addModelHistory.cpp
 * \brief   adds Model History to a model
 * \author  Sarah Keating
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

#include <sbml/xml/XMLNode.h>
#include <sbml/annotation/ModelHistory.h>


void printStatus(const char* message, int status)
{
	printf("%s", message);
	switch(status)
	{
	case LIBSBML_OPERATION_SUCCESS:
    printf("succeeded");
		break;
	case LIBSBML_INVALID_OBJECT:
    printf("invalid object");
		break;
	case LIBSBML_OPERATION_FAILED:
    printf("operation failed");
		break;
	default: 
    printf("unknown");
		break;
	}
  printf("\n");
}

int
main (int argc, char *argv[])
{

  SBMLDocument_t* d;
  Model_t* m;
  unsigned int  errors;

  if (argc != 3)
  {
    printf("\n"
      "  usage: addModelHistory <input-filename> <output-filename>\n"
      "\n");
    return 2;
  }


  d      = readSBML(argv[1]);
  errors = SBMLDocument_getNumErrors(d);

  if (errors > 0)
  {
    printf("Read Error(s):\n");
    SBMLDocument_printErrors(d, stdout);	 
    printf("Correct the above and re-run.\n");
  }
  else
  {
    int status;
    Date_t* date, *date2;
    ModelHistory_t* h = ModelHistory_create();
    ModelCreator_t* c = ModelCreator_create();

    ModelCreator_setFamilyName(c, "Keating");
    ModelCreator_setGivenName(c, "Sarah");
    ModelCreator_setEmail(c, "sbml-team@caltech.edu");
    ModelCreator_setOrganisation(c, "University of Hertfordshire");


    status = ModelHistory_addCreator(h, c);
	  printStatus("Status for addCreator: ", status);

    
    date = Date_createFromString("1999-11-13T06:54:32");
    date2 = Date_createFromString("2007-11-30T06:54:00-02:00");
       
    status = ModelHistory_setCreatedDate(h, date);
	  printStatus("Set created date:      ", status);

    status = ModelHistory_setModifiedDate(h, date2);
	  printStatus("Set modified date:     ", status);

    m = SBMLDocument_getModel(d);
    status =  Model_setModelHistory(m, h);
	  printStatus("Set model history:     ", status);
  
    writeSBML(d, argv[2]);
  }

  SBMLDocument_free(d);
  return errors;
}

