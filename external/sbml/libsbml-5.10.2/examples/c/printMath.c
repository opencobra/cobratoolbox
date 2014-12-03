/**
 * @file    printMath.c
 * @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
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
#include <stdlib.h>

#include <sbml/SBMLTypes.h>


void
printFunctionDefinition (unsigned int n, const FunctionDefinition_t *fd)
{
  const ASTNode_t *math;
  char *formula;


  if ( FunctionDefinition_isSetMath(fd) )
  {
    printf("FunctionDefinition %d, %s(", n, FunctionDefinition_getId(fd));

    math = FunctionDefinition_getMath(fd);

    /* Print function arguments. */
    if (ASTNode_getNumChildren(math) > 1)
    {
      printf("%s", ASTNode_getName( ASTNode_getLeftChild(math) ));

      for (n = 1; n < ASTNode_getNumChildren(math) - 1; ++n)
      {
        printf(", %s", ASTNode_getName( ASTNode_getChild(math, n) ));
      }
    }

    printf(") := ");

    /* Print function body. */
    if (ASTNode_getNumChildren(math) == 0)
    {
      printf("(no body defined)");
    }
    else
    {
      math    = ASTNode_getChild(math, ASTNode_getNumChildren(math) - 1);
      formula = SBML_formulaToString(math);
      printf("%s\n", formula);
      free(formula);
    }
  }
}


void
printRuleMath (unsigned int n, const Rule_t *r)
{
  char *formula;


  if ( Rule_isSetMath(r) )
  {
    formula = SBML_formulaToString( Rule_getMath(r) );
    printf("Rule %d, formula: %s\n", n, formula);
    free(formula);
  }
}


void
printReactionMath (unsigned int n, Reaction_t *r)
{
  char         *formula;
  KineticLaw_t *kl;


  if (Reaction_isSetKineticLaw(r))
  {
    kl = Reaction_getKineticLaw(r);

    if ( KineticLaw_isSetMath(kl) )
    {
      formula = SBML_formulaToString( KineticLaw_getMath(kl) );
      printf("Reaction %d, formula: %s\n", n, formula);
      free(formula);
    }
  }
}


void
printEventAssignmentMath (unsigned int n, const EventAssignment_t *ea)
{
  const char *variable;
  char       *formula;


  if ( EventAssignment_isSetMath(ea) )
  {
    variable = EventAssignment_getVariable(ea);
    formula  = SBML_formulaToString( EventAssignment_getMath(ea) );

    printf("  EventAssignment %d, trigger: %s = %s\n", n, variable, formula);

    free(formula);
  }
}


void
printEventMath (unsigned int n, Event_t *e)
{
  char         *formula;
  unsigned int i;


  if ( Event_isSetDelay(e) )
  {
    const Delay_t *delay = Event_getDelay(e);

    formula = SBML_formulaToString( Delay_getMath(delay) );
    printf("Event %d delay: %s\n", n, formula);
    free(formula);
  }

  if ( Event_isSetTrigger(e) )
  {
    const Trigger_t *trigger = Event_getTrigger(e);

    formula = SBML_formulaToString( Trigger_getMath(trigger) );
    printf("Event %d trigger: %s\n", n, formula);
    free(formula);
  }

  for (i = 0; i < Event_getNumEventAssignments(e); ++i)
  {
    printEventAssignmentMath(i + 1, Event_getEventAssignment(e, i));
  }

  printf("\n");
}


void
printMath (Model_t *m)
{
  unsigned int  n;


  for (n = 0; n < Model_getNumFunctionDefinitions(m); ++n)
  {
    printFunctionDefinition(n + 1, Model_getFunctionDefinition(m, n));
  }

  for (n = 0; n < Model_getNumRules(m); ++n)
  {
    printRuleMath(n + 1, Model_getRule(m, n));
  }

  printf("\n");

  for (n = 0; n < Model_getNumReactions(m); ++n)
  {
    printReactionMath(n + 1, Model_getReaction(m, n));
  }

  printf("\n");

  for (n = 0; n < Model_getNumEvents(m); ++n)
  {
    printEventMath(n + 1, Model_getEvent(m, n));
  }
}


int
main (int argc, char *argv[])
{
  SBMLDocument_t *d;
  Model_t        *m;


  if (argc != 2)
  {
    printf("Usage: printMath filename\n");
    return 1;
  }

  d = readSBML(argv[1]);
  m = SBMLDocument_getModel(d);

  SBMLDocument_printErrors(d, stdout);

  printMath(m);
  printf("\n");

  SBMLDocument_free(d);
  return 0;
}

