/**
 * \file    TestCompartmentVolumeRule.c
 * \brief   CompartmentVolumeRule unit tests
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

#include <sbml/SBase.h>
#include <sbml/Rule.h>

#include <check.h>


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Rule_t *CVR;


void
CompartmentVolumeRuleTest_setup (void)
{
  CVR = Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(CVR, SBML_COMPARTMENT_VOLUME_RULE);

  if (CVR == NULL)
  {
    fail("Rule_create() returned a NULL pointer.");
  }
}


void
CompartmentVolumeRuleTest_teardown (void)
{
  Rule_free(CVR);
}


START_TEST (test_CompartmentVolumeRule_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) CVR) ==
               SBML_ASSIGNMENT_RULE );
  fail_unless( Rule_getL1TypeCode((Rule_t *) CVR) ==
               SBML_COMPARTMENT_VOLUME_RULE );

  fail_unless( SBase_getNotes     ((SBase_t *) CVR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) CVR) == NULL );

  fail_unless( Rule_getFormula((Rule_t *) CVR) == NULL );
  fail_unless( Rule_getType((Rule_t *) CVR) ==  RULE_TYPE_SCALAR );

  fail_unless( Rule_getVariable(CVR) == NULL );
  fail_unless( !Rule_isSetVariable(CVR) );
}
END_TEST


//START_TEST (test_CompartmentVolumeRule_createWith)
//{
//  Rule_t *cvr;
//
//
//  cvr = Rule_createRateWithVariableAndFormula("c", "v + 1");
//  Rule_setL1TypeCode(cvr, SBML_COMPARTMENT_VOLUME_RULE);
//
//  fail_unless( SBase_getTypeCode((SBase_t *) cvr) ==
//               SBML_RATE_RULE );
//  fail_unless( Rule_getL1TypeCode((Rule_t *) cvr) ==
//               SBML_COMPARTMENT_VOLUME_RULE );
//
//  fail_unless( SBase_getNotes     ((SBase_t *) cvr) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) cvr) == NULL );
//
//
//  fail_unless( !strcmp(Rule_getFormula(cvr), "v + 1") );
//  fail_unless( !strcmp(Rule_getVariable(cvr), "c") );
//
//  fail_unless( Rule_getType(cvr) ==   RULE_TYPE_RATE );
//
//  fail_unless( Rule_isSetVariable(cvr) );
//
//  Rule_free(cvr);
//}
//END_TEST


START_TEST (test_CompartmentVolumeRule_free_NULL)
{
  Rule_free(NULL);
}
END_TEST


START_TEST (test_CompartmentVolumeRule_setCompartment)
{
  const char *c;
  const char *compartment = "cell";


  Rule_setVariable(CVR, compartment);

  fail_unless( !strcmp(Rule_getVariable(CVR), compartment),
               NULL );
  fail_unless( Rule_isSetVariable(CVR) );

  if (Rule_getVariable(CVR) == compartment)
  {
    fail( "Rule_setVariable(...)"
          " did not make a copy of string." );
  }

  /* Reflexive case (pathological) */
  c = Rule_getVariable(CVR);
  Rule_setVariable(CVR, c);
  fail_unless( !strcmp(Rule_getVariable(CVR), compartment),
               NULL );

  Rule_setVariable(CVR, NULL);
  fail_unless( !Rule_isSetVariable(CVR) );

  if (Rule_getVariable(CVR) != NULL)
  {
    fail( "Rule_setVariable(CVR, NULL)"
          " did not clear string." );
  }
}
END_TEST


Suite *
create_suite_CompartmentVolumeRule (void)
{
  Suite *suite = suite_create("CompartmentVolumeRule");
  TCase *tcase = tcase_create("CompartmentVolumeRule");


  tcase_add_checked_fixture( tcase,
                             CompartmentVolumeRuleTest_setup,
                             CompartmentVolumeRuleTest_teardown );

  tcase_add_test( tcase, test_CompartmentVolumeRule_create         );
  //tcase_add_test( tcase, test_CompartmentVolumeRule_createWith     );
  tcase_add_test( tcase, test_CompartmentVolumeRule_free_NULL      );
  tcase_add_test( tcase, test_CompartmentVolumeRule_setCompartment );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


