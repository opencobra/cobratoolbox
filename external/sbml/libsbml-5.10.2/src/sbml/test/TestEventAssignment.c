/**
 * \file    TestEventAssignment.c
 * \brief   SBML EventAssignment unit tests
 * \author  Ben Bornstein
 * 
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/common/common.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>

#include <sbml/SBase.h>
#include <sbml/EventAssignment.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static EventAssignment_t *EA;


void
EventAssignmentTest_setup (void)
{
  EA = EventAssignment_create(2, 4);

  if (EA == NULL)
  {
    fail("EventAssignment_create() returned a NULL pointer.");
  }
}


void
EventAssignmentTest_teardown (void)
{
  EventAssignment_free(EA);
}


START_TEST (test_EventAssignment_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) EA) == SBML_EVENT_ASSIGNMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) EA) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) EA) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) EA) == NULL );

  fail_unless( EventAssignment_getVariable(EA) == NULL );
  fail_unless( EventAssignment_getMath    (EA) == NULL );
}
END_TEST


//START_TEST (test_EventAssignment_createWith)
//{
//  ASTNode_t         *math = SBML_parseFormula("0");
//  EventAssignment_t *ea   = EventAssignment_createWithVarAndMath("k", math);
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) ea) == SBML_EVENT_ASSIGNMENT );
//  fail_unless( SBase_getMetaId    ((SBase_t *) ea) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) ea) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) ea) == NULL );
//
//  fail_unless( EventAssignment_getMath(ea) != math );
//  fail_unless( EventAssignment_isSetMath(ea) );
//
//  fail_unless( !strcmp(EventAssignment_getVariable(ea), "k") );
//  fail_unless( EventAssignment_isSetVariable(ea) );
//
//  ASTNode_free(math);
//  EventAssignment_free(ea);
//}
//END_TEST


START_TEST (test_EventAssignment_free_NULL)
{
  EventAssignment_free(NULL);
}
END_TEST


START_TEST (test_EventAssignment_setVariable)
{
  const char *variable = "k2";


  EventAssignment_setVariable(EA, variable);

  fail_unless( !strcmp(EventAssignment_getVariable(EA), variable) );
  fail_unless( EventAssignment_isSetVariable(EA) );

  if (EventAssignment_getVariable(EA) == variable)
  {
    fail("EventAssignment_setVariable(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  EventAssignment_setVariable(EA, EventAssignment_getVariable(EA));
  fail_unless( !strcmp(EventAssignment_getVariable(EA), variable) );

  EventAssignment_setVariable(EA, NULL);
  fail_unless( !EventAssignment_isSetVariable(EA) );

  if (EventAssignment_getVariable(EA) != NULL)
  {
    fail("EventAssignment_setVariable(EA, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_EventAssignment_setMath)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");
  char *formula;
  const ASTNode_t *math1;

  EventAssignment_setMath(EA, math);

  math1 = EventAssignment_getMath(EA);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "2 * k") );

  fail_unless( EventAssignment_getMath(EA) != math);
  fail_unless( EventAssignment_isSetMath(EA) );

  /* Reflexive case (pathological) */
  EventAssignment_setMath(EA, (ASTNode_t *) EventAssignment_getMath(EA));

  math1 = EventAssignment_getMath(EA);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "2 * k") );
  fail_unless( EventAssignment_getMath(EA) != math );

  EventAssignment_setMath(EA, NULL);
  fail_unless( !EventAssignment_isSetMath(EA) );

  if (EventAssignment_getMath(EA) != NULL)
  {
    fail("EventAssignment_setMath(EA, NULL) did not clear ASTNode.");
  }

  ASTNode_free(math);
}
END_TEST


START_TEST (test_EventAssignment_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  EventAssignment_t *object = 
    EventAssignment_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_EVENT_ASSIGNMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( EventAssignment_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(
                        EventAssignment_getNamespaces(object)) == 2 );

  EventAssignment_free(object);
}
END_TEST


Suite *
create_suite_EventAssignment (void)
{
  Suite *suite = suite_create("EventAssignment");
  TCase *tcase = tcase_create("EventAssignment");


  tcase_add_checked_fixture( tcase,
                             EventAssignmentTest_setup,
                             EventAssignmentTest_teardown );

  tcase_add_test( tcase, test_EventAssignment_create      );
  //tcase_add_test( tcase, test_EventAssignment_createWith  );
  tcase_add_test( tcase, test_EventAssignment_free_NULL   );
  tcase_add_test( tcase, test_EventAssignment_setVariable );
  tcase_add_test( tcase, test_EventAssignment_setMath     );
  tcase_add_test( tcase, test_EventAssignment_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

