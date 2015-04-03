/**
 * \file    TestEvent_newSetters.c
 * \brief   Event unit tests for new set function API
 * \author  Sarah Keating
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

#include <sbml/SBase.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>
#include <sbml/Trigger.h>
#include <sbml/Delay.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>




#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Event_t *E;


void
EventTest1_setup (void)
{
  E = Event_create(2, 4);

  if (E == NULL)
  {
    fail("Event_create() returned a NULL pointer.");
  }
}


void
EventTest1_teardown (void)
{
  Event_free(E);
}


START_TEST (test_Event_setId1)
{
  const char *id = "1e1";
  int i = Event_setId(E, id);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Event_isSetId(E) );
}
END_TEST


START_TEST (test_Event_setId2)
{
  const char *id = "e1";
  int i = Event_setId(E, id);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Event_getId(E), id) );
  fail_unless( Event_isSetId(E) );

  i = Event_unsetId(E);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetId(E) );
}
END_TEST


START_TEST (test_Event_setId3)
{
  int i = Event_setId(E, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetId(E) );
}
END_TEST


START_TEST (test_Event_setName1)
{
  const char *name = "3Set_k2";

  int i = Event_setName(E, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Event_isSetName(E) );
}
END_TEST


START_TEST (test_Event_setName2)
{
  const char *name = "Set k2";

  int i = Event_setName(E, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Event_getName(E), name) );
  fail_unless( Event_isSetName(E) );

  i = Event_unsetName(E);


  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetName(E) );
}
END_TEST


START_TEST (test_Event_setName3)
{
  int i = Event_setName(E, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetName(E) );
}
END_TEST


START_TEST (test_Event_setTrigger1)
{
  Trigger_t   *trigger 
    = Trigger_create(2, 1);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(trigger, math);
  ASTNode_free(math);
 
  int i = Event_setTrigger(E, trigger);

  fail_unless( i == LIBSBML_VERSION_MISMATCH );
  fail_unless( !Event_isSetTrigger(E) );
  
  Trigger_free(trigger);
}
END_TEST


START_TEST (test_Event_setTrigger2)
{
  ASTNode_t         *math1   = SBML_parseFormula("0");
  Trigger_t   *trigger 
    = Trigger_create(2, 4);
  Trigger_setMath(trigger, math1);
 
  int i = Event_setTrigger(E, trigger);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Event_getTrigger(E) != NULL );
  fail_unless( Event_isSetTrigger(E) );
  
  ASTNode_free(math1);
  Trigger_free(trigger);
}
END_TEST


START_TEST (test_Event_setDelay1)
{
  ASTNode_t         *math1   = SBML_parseFormula("0");
  Delay_t   *Delay 
    = Delay_create(2, 4);
  Delay_setMath(Delay, math1);

  int i = Event_setDelay(E, Delay);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Event_getDelay(E) != NULL );
  fail_unless( Event_isSetDelay(E) );

  i = Event_unsetDelay(E);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS) ;
  fail_unless( !Event_isSetDelay(E) );

  ASTNode_free(math1);
  Delay_free(Delay);
}
END_TEST


START_TEST (test_Event_setDelay2)
{
  ASTNode_t         *math1   = SBML_parseFormula("0");
  Delay_t   *Delay = 
    Delay_create(2, 1);
  Delay_setMath(Delay, math1);

  int i = Event_setDelay(E, Delay);

  fail_unless( i == LIBSBML_VERSION_MISMATCH );
  fail_unless( !Event_isSetDelay(E) );

  i = Event_unsetDelay(E);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  ASTNode_free(math1);
  Delay_free(Delay);
}
END_TEST


START_TEST (test_Event_setTimeUnits1)
{
  const char *units = "second";

  int i = Event_setTimeUnits(E, units);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !Event_isSetTimeUnits(E) );
}
END_TEST


START_TEST (test_Event_setTimeUnits2)
{
  const char *units = "second";
  Event_t *e = Event_create(2, 1);

  int i = Event_setTimeUnits(e, units);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS); 
  fail_unless( !strcmp(Event_getTimeUnits(e), units) );
  fail_unless( Event_isSetTimeUnits(e) );

  i = Event_unsetTimeUnits(e);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetTimeUnits(e) );

  Event_free(e);
}
END_TEST


START_TEST (test_Event_setTimeUnits3)
{
  const char *units = "1second";
  Event_t *e = Event_create(2, 1);

  int i = Event_setTimeUnits(e, units);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE); 
  fail_unless( !Event_isSetTimeUnits(e) );

  i = Event_unsetTimeUnits(e);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetTimeUnits(e) );

  Event_free(e);
}
END_TEST


START_TEST (test_Event_setTimeUnits4)
{
  Event_t *e = Event_create(2, 1);

  int i = Event_setTimeUnits(e, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS); 
  fail_unless( !Event_isSetTimeUnits(e) );

  Event_free(e);
}
END_TEST


START_TEST (test_Event_setUseValuesFromTriggerTime1)
{
  Event_t *e = Event_create(2, 4);
  int i = Event_setUseValuesFromTriggerTime(e, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Event_getUseValuesFromTriggerTime(e) == 0 );

  i = Event_setUseValuesFromTriggerTime(e, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Event_getUseValuesFromTriggerTime(e) == 1 );

  Event_free(e);
}
END_TEST


START_TEST (test_Event_setUseValuesFromTriggerTime2)
{
  Event_t *e = Event_create(2, 2);
  int i = Event_setUseValuesFromTriggerTime(e, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);

  Event_free(e);
}
END_TEST


START_TEST (test_Event_addEventAssignment1)
{
  Event_t *e = Event_create(2, 2);
  EventAssignment_t *ea 
    = EventAssignment_create(2, 2);

  int i = Event_addEventAssignment(e, ea);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  EventAssignment_setVariable(ea, "f");
  i = Event_addEventAssignment(e, ea);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  ASTNode_t* math = SBML_parseFormula("a-n");
  EventAssignment_setMath(ea, math);
  ASTNode_free(math);
  i = Event_addEventAssignment(e, ea);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Event_getNumEventAssignments(e) == 1);

  EventAssignment_free(ea);
  Event_free(e);
}
END_TEST


START_TEST (test_Event_addEventAssignment2)
{
  Event_t *e = Event_create(2, 2);
  EventAssignment_t *ea 
    = EventAssignment_create(2, 3);
  EventAssignment_setVariable(ea, "f");
  ASTNode_t* math = SBML_parseFormula("a-n");
  EventAssignment_setMath(ea, math);
  ASTNode_free(math);

  int i = Event_addEventAssignment(e, ea);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Event_getNumEventAssignments(e) == 0);

  EventAssignment_free(ea);
  Event_free(e);
}
END_TEST


START_TEST (test_Event_addEventAssignment3)
{
  Event_t *e = Event_create(2, 2);

  int i = Event_addEventAssignment(e, NULL);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Event_getNumEventAssignments(e) == 0);

  Event_free(e);
}
END_TEST


START_TEST (test_Event_addEventAssignment4)
{
  Event_t *e = Event_create(2, 2);
  EventAssignment_t *ea 
    = EventAssignment_create(2, 2);
  EventAssignment_setVariable(ea, "c");
  ASTNode_t* math = SBML_parseFormula("a-n");
  EventAssignment_setMath(ea, math);
  ASTNode_free(math);
  EventAssignment_t *ea1 
    = EventAssignment_create(2, 2);
  EventAssignment_setVariable(ea1, "c");
  math = SBML_parseFormula("a-n");
  EventAssignment_setMath(ea1, math);
  ASTNode_free(math);

  int i = Event_addEventAssignment(e, ea);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Event_getNumEventAssignments(e) == 1);

  i = Event_addEventAssignment(e, ea1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Event_getNumEventAssignments(e) == 1);  
  
  EventAssignment_free(ea);
  EventAssignment_free(ea1);
  Event_free(e);
}
END_TEST


START_TEST (test_Event_createEventAssignment)
{
  Event_t *e = Event_create(2, 2);
  
  EventAssignment_t *ea = Event_createEventAssignment(e);

  fail_unless( Event_getNumEventAssignments(e) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (ea)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (ea)) == 2 );

  Event_free(e);
}
END_TEST


Suite *
create_suite_Event_newSetters (void)
{
  Suite *suite = suite_create("Event_newSetters");
  TCase *tcase = tcase_create("Event_newSetters");


  tcase_add_checked_fixture( tcase,
                             EventTest1_setup,
                             EventTest1_teardown );

  tcase_add_test( tcase, test_Event_setId1        );
  tcase_add_test( tcase, test_Event_setId2        );
  tcase_add_test( tcase, test_Event_setId3        );
  tcase_add_test( tcase, test_Event_setName1      );
  tcase_add_test( tcase, test_Event_setName2      );
  tcase_add_test( tcase, test_Event_setName3      );
  tcase_add_test( tcase, test_Event_setTrigger1   );
  tcase_add_test( tcase, test_Event_setTrigger2   );
  tcase_add_test( tcase, test_Event_setDelay1     );
  tcase_add_test( tcase, test_Event_setDelay2     );
  tcase_add_test( tcase, test_Event_setTimeUnits1 );
  tcase_add_test( tcase, test_Event_setTimeUnits2 );
  tcase_add_test( tcase, test_Event_setTimeUnits3 );
  tcase_add_test( tcase, test_Event_setTimeUnits4 );
  tcase_add_test( tcase, test_Event_setUseValuesFromTriggerTime1 );
  tcase_add_test( tcase, test_Event_setUseValuesFromTriggerTime2 );
  tcase_add_test( tcase, test_Event_addEventAssignment1 );
  tcase_add_test( tcase, test_Event_addEventAssignment2 );
  tcase_add_test( tcase, test_Event_addEventAssignment3 );
  tcase_add_test( tcase, test_Event_addEventAssignment4 );
  tcase_add_test( tcase, test_Event_createEventAssignment );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

