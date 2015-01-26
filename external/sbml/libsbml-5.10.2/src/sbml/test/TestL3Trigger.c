/**
 * \file    TestL3Trigger.c
 * \brief   SBML Trigger unit tests
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
#include <sbml/math/FormulaFormatter.h>

#include <sbml/SBase.h>
#include <sbml/Trigger.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Trigger_t *T;


void
L3TriggerTest_setup (void)
{
  T = Trigger_create(3, 1);

  if (T == NULL)
  {
    fail("Trigger_create() returned a NULL pointer.");
  }
}


void
L3TriggerTest_teardown (void)
{
  Trigger_free(T);
}


START_TEST (test_L3Trigger_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) T) == SBML_TRIGGER );
  fail_unless( SBase_getMetaId    ((SBase_t *) T) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) T) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) T) == NULL );

  fail_unless( Trigger_getMath(T) == NULL );
  fail_unless( Trigger_getInitialValue(T) == 1 );
  fail_unless( Trigger_getPersistent(T) == 1 );
  fail_unless( Trigger_isSetInitialValue(T) == 0 );
  fail_unless( Trigger_isSetPersistent(T) == 0 );

}
END_TEST


START_TEST (test_L3Trigger_setInitialValue)
{
  int i = Trigger_setInitialValue(T, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
 
  fail_unless( Trigger_getInitialValue(T) == 0 );
  fail_unless( Trigger_isSetInitialValue(T) == 1 );

  i = Trigger_setInitialValue(T, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
 
  fail_unless( Trigger_getInitialValue(T) == 1 );
  fail_unless( Trigger_isSetInitialValue(T) == 1 );

}
END_TEST


START_TEST (test_L3Trigger_setInitialValue1)
{
  Trigger_t *t = Trigger_create(2, 4);

  int i = Trigger_setInitialValue(t, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
 
  fail_unless( Trigger_getInitialValue(T) == 1 );
  fail_unless( Trigger_isSetInitialValue(T) == 0 );

  Trigger_free(t);
}
END_TEST


START_TEST (test_L3Trigger_setPersistent)
{
  int i = Trigger_setPersistent(T, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
 
  fail_unless( Trigger_getPersistent(T) == 0 );
  fail_unless( Trigger_isSetPersistent(T) == 1 );

  i = Trigger_setPersistent(T, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
 
  fail_unless( Trigger_getPersistent(T) == 1 );
  fail_unless( Trigger_isSetPersistent(T) == 1 );

}
END_TEST


START_TEST (test_L3Trigger_setPersistent1)
{
  Trigger_t *t = Trigger_create(2, 4);

  int i = Trigger_setPersistent(t, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
 
  fail_unless( Trigger_getPersistent(T) == 1 );
  fail_unless( Trigger_isSetPersistent(T) == 0 );

  Trigger_free(t);
}
END_TEST


Suite *
create_suite_L3Trigger (void)
{
  Suite *suite = suite_create("L3Trigger");
  TCase *tcase = tcase_create("L3Trigger");


  tcase_add_checked_fixture( tcase,
                             L3TriggerTest_setup,
                             L3TriggerTest_teardown );

  tcase_add_test( tcase, test_L3Trigger_create       );
  tcase_add_test( tcase, test_L3Trigger_setInitialValue      );
  tcase_add_test( tcase, test_L3Trigger_setInitialValue1     );
  tcase_add_test( tcase, test_L3Trigger_setPersistent      );
  tcase_add_test( tcase, test_L3Trigger_setPersistent1     );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

