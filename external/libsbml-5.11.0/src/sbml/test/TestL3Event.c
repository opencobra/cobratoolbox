/**
 * \file    TestL3Event.c
 * \brief   L3 Event unit tests
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

#include <sbml/SBase.h>
#include <sbml/Event.h>
#include <sbml/Trigger.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>
#include <sbml/math/FormulaParser.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Event_t *E;


void
L3EventTest_setup (void)
{
  E = Event_create(3, 1);

  if (E == NULL)
  {
    fail("Event_create(3, 1) returned a NULL pointer.");
  }
}


void
L3EventTest_teardown (void)
{
  Event_free(E);
}


START_TEST (test_L3_Event_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) E) == SBML_EVENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) E) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) E) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) E) == NULL );

  fail_unless( Event_getId     (E) == NULL );
  fail_unless( Event_getName   (E) == NULL );
  fail_unless( Event_getUseValuesFromTriggerTime(E) == 1   );

  fail_unless( !Event_isSetId     (E) );
  fail_unless( !Event_isSetName   (E) );
  fail_unless( !Event_isSetUseValuesFromTriggerTime(E) );
}
END_TEST


START_TEST (test_L3_Event_free_NULL)
{
  Event_free(NULL);
}
END_TEST


START_TEST (test_L3_Event_id)
{
  const char *id = "mitochondria";


  fail_unless( !Event_isSetId(E) );
  
  Event_setId(E, id);

  fail_unless( !strcmp(Event_getId(E), id) );
  fail_unless( Event_isSetId(E) );

  if (Event_getId(E) == id)
  {
    fail("Event_setId(...) did not make a copy of string.");
  }
 
  Event_unsetId(E);
  
  fail_unless( !Event_isSetId(E) );

  if (Event_getId(E) != NULL)
  {
    fail("Event_unsetId(E) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Event_name)
{
  const char *name = "My_Favorite_Factory";


  fail_unless( !Event_isSetName(E) );

  Event_setName(E, name);

  fail_unless( !strcmp(Event_getName(E), name) );
  fail_unless( Event_isSetName(E) );

  if (Event_getName(E) == name)
  {
    fail("Event_setName(...) did not make a copy of string.");
  }

  Event_unsetName(E);
  
  fail_unless( !Event_isSetName(E) );

  if (Event_getName(E) != NULL)
  {
    fail("Event_unsetName(E) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Event_useValuesFromTriggerTime)
{
  fail_unless(Event_isSetUseValuesFromTriggerTime(E) == 0);

  Event_setUseValuesFromTriggerTime(E, 1);

  fail_unless(Event_getUseValuesFromTriggerTime(E) == 1);
  fail_unless(Event_isSetUseValuesFromTriggerTime(E) == 1);

  Event_setUseValuesFromTriggerTime(E, 0);

  fail_unless(Event_getUseValuesFromTriggerTime(E) == 0);
  fail_unless(Event_isSetUseValuesFromTriggerTime(E) == 1);

}
END_TEST


START_TEST (test_L3_Event_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Event_t *e = 
    Event_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) e) == SBML_EVENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) e) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) e) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) e) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) e) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) e) == 1 );

  fail_unless( Event_getNamespaces     (e) != NULL );
  fail_unless( XMLNamespaces_getLength(Event_getNamespaces(e)) == 2 );


  fail_unless( Event_getId     (e) == NULL );
  fail_unless( Event_getName   (e) == NULL );
  fail_unless( Event_getUseValuesFromTriggerTime(e) == 1   );

  fail_unless( !Event_isSetId     (e) );
  fail_unless( !Event_isSetName   (e) );
  fail_unless( !Event_isSetUseValuesFromTriggerTime(e) );

  Event_free(e);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


START_TEST (test_L3_Event_hasRequiredAttributes )
{
  Event_t *e = Event_create (3, 1);

  fail_unless ( !Event_hasRequiredAttributes(e));

  Event_setUseValuesFromTriggerTime(e, 1);

  fail_unless ( Event_hasRequiredAttributes(e));

  Event_free(e);
}
END_TEST


START_TEST (test_L3_Event_hasRequiredElements )
{
  Event_t *e = Event_create (3, 1);

  fail_unless ( !Event_hasRequiredElements(e));

  Trigger_t *t = Trigger_create(3, 1);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Trigger_setInitialValue(t, 1);
  Trigger_setPersistent(t, 1);
  Event_setTrigger(e, t);

  fail_unless ( Event_hasRequiredElements(e));

  Event_free(e);
  Trigger_free(t);
}
END_TEST


START_TEST (test_L3_Event_NS)
{
  fail_unless( Event_getNamespaces     (E) != NULL );
  fail_unless( XMLNamespaces_getLength(Event_getNamespaces(E)) == 1 );
  char* uri = XMLNamespaces_getURI(Event_getNamespaces(E), 0);
  fail_unless( !strcmp( uri, "http://www.sbml.org/sbml/level3/version1/core"));
  safe_free(uri);
}
END_TEST


START_TEST (test_L3_Event_setPriority1)
{
  Priority_t   *priority = Priority_create(3, 1);
  ASTNode_t    *math1 = SBML_parseFormula("0");
  Priority_setMath(priority, math1);
 
  fail_unless (!Event_isSetPriority(E) );

  int i = Event_setPriority(E, priority);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Event_isSetPriority(E) );

  i = Event_unsetPriority(E);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Event_isSetPriority(E) );

  Priority_free(priority);
  ASTNode_free(math1);
}
END_TEST


START_TEST (test_L3_Event_setPriority2)
{
  const Priority_t   *priority 
    = Event_createPriority(E);

  fail_unless (Event_isSetPriority(E) );
  (void) priority;

  Priority_t * p = Event_getPriority(E);

  fail_unless (p != NULL);
  fail_unless (!Priority_isSetMath(p));

}
END_TEST


Suite *
create_suite_L3_Event (void)
{
  Suite *suite = suite_create("L3_Event");
  TCase *tcase = tcase_create("L3_Event");


  tcase_add_checked_fixture( tcase,
                             L3EventTest_setup,
                             L3EventTest_teardown );

  tcase_add_test( tcase, test_L3_Event_create              );
  tcase_add_test( tcase, test_L3_Event_free_NULL           );
  tcase_add_test( tcase, test_L3_Event_id               );
  tcase_add_test( tcase, test_L3_Event_name             );
  tcase_add_test( tcase, test_L3_Event_useValuesFromTriggerTime   );
  tcase_add_test( tcase, test_L3_Event_createWithNS         );
  tcase_add_test( tcase, test_L3_Event_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_Event_hasRequiredElements        );
  tcase_add_test( tcase, test_L3_Event_NS              );
  tcase_add_test( tcase, test_L3_Event_setPriority1              );
  tcase_add_test( tcase, test_L3_Event_setPriority2              );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

