/**
 * @file    printAnnotation.cpp
 * @brief   Prints annotation strings for each element
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


void printAnnotation(SBase_t *sb, const char* id )
{
  if (!SBase_isSetAnnotation(sb)) return;
  
  printf("----- %s (%s) annotation -----\n%s\n\n"
  , SBase_getElementName(sb)
  , id
  , SBase_getAnnotationString(sb)
  );
}


int
main (int argc, char* argv[])
{
  unsigned int i,j,errors;
  const char* filename;
  SBMLDocument_t* document;
  Model_t* m;

  if (argc != 2)
  {
    printf("\nUsage: printAnnotation filename\n\n");
    return 1;
  }

  filename  = argv[1];
  document  = readSBML(filename);

  errors = SBMLDocument_getNumErrors( document);

  printf("\n%s\n\n", filename);

  if(errors > 0)
  {
    SBMLDocument_printErrors(document, stderr);
    SBMLDocument_free(document);
    return errors;
  }


  /* Model */

  m = SBMLDocument_getModel(document);
  printAnnotation((SBase_t*)m, Model_getId(m));

  for(i=0; i < Model_getNumReactions(m); i++)
  {
    Reaction_t* re = Model_getReaction( m, i);
    printAnnotation((SBase_t*)re, Reaction_getId(re));

    /* SpeciesReference (Reactant) */

    for(j=0; j < Reaction_getNumReactants( re); j++)
    {
      SpeciesReference_t* rt =  Reaction_getReactant(re, j);
      if (SBase_isSetAnnotation((SBase_t*) rt)) printf("   ");
      printAnnotation((SBase_t*)rt, SpeciesReference_getSpecies( rt ) );
    }

    /* SpeciesReference (Product) */

    for(j=0; j < Reaction_getNumProducts( re ); j++)
    {
      SpeciesReference_t* rt = Reaction_getProduct( re, j);
      if (SBase_isSetAnnotation((SBase_t*) rt)) printf("   ");
      printAnnotation((SBase_t*)rt, SpeciesReference_getSpecies( rt ) );
    }

    /* ModifierSpeciesReference (Modifiers) */

    for(j=0; j < Reaction_getNumModifiers( re ); j++)
    {
      SpeciesReference_t* md = Reaction_getModifier(re, j);
      if (SBase_isSetAnnotation((SBase_t*) md)) printf("   ");
      printAnnotation((SBase_t*)md, SpeciesReference_getSpecies( md ) );
    }

    /* KineticLaw */

    if(Reaction_isSetKineticLaw( re ))
    {
      KineticLaw_t* kl = Reaction_getKineticLaw( re );
      if (SBase_isSetAnnotation((SBase_t*) kl)) printf("   ");
      printAnnotation((SBase_t*)kl, "");

      /* Parameter */

      for(j=0; j < KineticLaw_getNumParameters( kl ); j++)
      {
        Parameter_t* pa = KineticLaw_getParameter( kl, j);
        if (SBase_isSetAnnotation((SBase_t*) pa)) printf("   ");
        printAnnotation((SBase_t*)pa, Parameter_getId(pa));
      }
    }

  }

  /* Species */

  for(i=0; i < Model_getNumSpecies(m); i++)
  {
    Species_t* sp = Model_getSpecies(m, i);
    printAnnotation((SBase_t*)sp, Species_getId(sp));
  }

  /* Compartments */

  for(i=0; i < Model_getNumCompartments( m ); i++)
  {
    Compartment_t* sp = Model_getCompartment(m, i);
    printAnnotation((SBase_t*)sp, Compartment_getId(sp));
  }

  /* FunctionDefinition */

  for(i=0; i < Model_getNumFunctionDefinitions(m); i++)
  {
    FunctionDefinition_t* sp = Model_getFunctionDefinition(m, i);
    printAnnotation((SBase_t*)sp, FunctionDefinition_getId(sp));
  }

  /* UnitDefinition */

  for(i=0; i < Model_getNumUnitDefinitions(m); i++)
  {
    UnitDefinition_t* sp = Model_getUnitDefinition( m, i);
    printAnnotation((SBase_t*)sp, UnitDefinition_getId(sp));
  }

  /* Parameter */

  for(i=0; i < Model_getNumParameters( m ); i++)
  {
    Parameter_t* sp = Model_getParameter( m, i);
    printAnnotation((SBase_t*)sp, Parameter_getId(sp));
  }

  /* Rule */

  for(i=0; i < Model_getNumReactions( m ); i++)
  {
    Rule_t* sp = Model_getRule(m, i);
    printAnnotation((SBase_t*)sp, "");
  }

  /* InitialAssignment */

  for(i=0; i < Model_getNumInitialAssignments(m); i++)
  {
    InitialAssignment_t* sp = Model_getInitialAssignment(m, i);
    printAnnotation((SBase_t*)sp, "");
  }

  /* Event */

  for(i=0; i < Model_getNumEvents(m); i++)
  {
    Event_t* sp = Model_getEvent(m, i);
    printAnnotation((SBase_t*)sp, Event_getId(sp));

    /* Trigger */

    if(Event_isSetTrigger( sp ))
    {
      Trigger_t* tg = Event_getTrigger(sp);
      if (SBase_isSetAnnotation( (SBase_t*) tg)) printf( "   " );
      printAnnotation((SBase_t*)tg, "");
    }

    /* Delay */

    if(Event_isSetDelay(sp))
    {
      Delay_t* dl = Event_getDelay(sp);
      if (SBase_isSetAnnotation( (SBase_t*) dl)) printf( "   " );
      printAnnotation((SBase_t*) dl, "");
    }

    /* EventAssignment */

    for(j=0; j < Event_getNumEventAssignments(sp); j++)
    {
      EventAssignment_t* ea = Event_getEventAssignment(sp, j);
      if (SBase_isSetAnnotation( (SBase_t*) ea)) printf( "   " );      
      printAnnotation((SBase_t*)ea, "");
    }
  }

  /* SpeciesType */

  for(i=0; i < Model_getNumSpeciesTypes(m); i++)
  {
    SpeciesType_t* sp = Model_getSpeciesType(m, i);
    printAnnotation((SBase_t*)sp, SpeciesType_getId(sp));
  }

  /* Constraints */

  for(i=0; i < Model_getNumConstraints(m); i++)
  {
    Constraint_t* sp = Model_getConstraint(m, i);
    printAnnotation((SBase_t*)sp, "");
  }

  SBMLDocument_free( document );
  return errors;
}


