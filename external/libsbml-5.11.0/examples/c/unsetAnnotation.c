/**
 * @file    unsetAnnotation.cpp
 * @brief   unset annotation for each element
 * @author  Akiya Jouraku
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
#include "util.h"

int
main (int argc, char* argv[])
{
  unsigned int i,j,errors;
  const char* filename   = argv[1];
  SBMLDocument_t* document;
  Model_t* m;

  if (argc != 3)
  {
    printf("\nUsage: unsetAnnotation <input-filename> <output-filename>\n");
    return 1;
  }

  
  filename = argv[1];  
  document = readSBML(filename);

  errors =  SBMLDocument_getNumErrors(document);

  if(errors > 0)
  {
    SBMLDocument_printErrors(document, stderr);
    SBMLDocument_free(document);
    return errors;
  }

  m = SBMLDocument_getModel( document );
  SBase_unsetAnnotation((SBase_t*)m);

  for(i=0; i < Model_getNumReactions(m); i++)
  {
    Reaction_t* re = Model_getReaction(m, i);
    SBase_unsetAnnotation((SBase_t*)re);

    for(j=0; j < Reaction_getNumReactants(re); j++)
    {
      SpeciesReference_t* rt = Reaction_getReactant(re,j);
      SBase_unsetAnnotation((SBase_t*)rt);
    }

    for(j=0; j < Reaction_getNumProducts(re); j++)
    {
      SpeciesReference_t* rt = Reaction_getProduct(re,j);
      SBase_unsetAnnotation((SBase_t*)rt);
    }

    for(j=0; j < Reaction_getNumModifiers(re); j++)
    {
      SpeciesReference_t* md = Reaction_getModifier(re,j);
      SBase_unsetAnnotation((SBase_t*)md);
    }

    if(Reaction_isSetKineticLaw(re))
    {
      KineticLaw_t* kl =  Reaction_getKineticLaw(re);
      SBase_unsetAnnotation((SBase_t*)kl);

      for(j=0; j < KineticLaw_getNumParameters(kl); j++)
      {
        Parameter_t* pa = KineticLaw_getParameter(kl, j);
        SBase_unsetAnnotation((SBase_t*)pa);
      }
    }

  }

  for(i=0; i < Model_getNumSpecies(m); i++)
  {
    Species_t* sp = Model_getSpecies(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumCompartments(m); i++)
  {
    Compartment_t* sp = Model_getCompartment(m,i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumFunctionDefinitions(m); i++)
  {
    FunctionDefinition_t* sp = Model_getFunctionDefinition(m,i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumUnitDefinitions(m); i++)
  {
    UnitDefinition_t* sp = Model_getUnitDefinition(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumParameters(m); i++)
  {
    Parameter_t* sp = Model_getParameter(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumRules(m); i++)
  {
    Rule_t* sp = Model_getRule(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumInitialAssignments(m); i++)
  {
    InitialAssignment_t* sp = Model_getInitialAssignment(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumEvents(m); i++)
  {
    Event_t* sp = Model_getEvent(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);

    for(j=0; j < Event_getNumEventAssignments(sp); j++)
    {
      EventAssignment_t* ea = Event_getEventAssignment(sp, j);
      SBase_unsetAnnotation((SBase_t*)ea);
    }
  }

  for(i=0; i < Model_getNumSpeciesTypes(m); i++)
  {
    SpeciesType_t* sp = Model_getSpeciesType(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  for(i=0; i < Model_getNumConstraints(m); i++)
  {
    Constraint_t* sp = Model_getConstraint(m, i);
    SBase_unsetAnnotation((SBase_t*)sp);
  }

  writeSBML(document, argv[2]);

  SBMLDocument_free(document);
  return errors;
}



