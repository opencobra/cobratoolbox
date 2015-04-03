/**
 * \file    TestParameterRule.c
 * \brief   ParameterRule unit tests
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

static Rule_t *PR;


void
ParameterRuleTest_setup (void)
{
  PR = Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(PR, SBML_PARAMETER_RULE);

  if (PR == NULL)
  {
    fail("Rule_createAssignment() returned a NULL pointer.");
  }
}


void
ParameterRuleTest_teardown (void)
{
  Rule_free(PR);
}


START_TEST (test_ParameterRule_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) PR) ==
               SBML_ASSIGNMENT_RULE );
  fail_unless( Rule_getL1TypeCode((Rule_t *) PR) ==
               SBML_PARAMETER_RULE );
  fail_unless( SBase_getNotes     ((SBase_t *) PR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) PR) == NULL );

  fail_unless( Rule_getFormula((Rule_t *) PR) == NULL );

  fail_unless( Rule_getUnits(PR) == NULL );
  fail_unless( Rule_getVariable (PR) == NULL );

  fail_unless( Rule_getType( PR) ==  RULE_TYPE_SCALAR );

  fail_unless( !Rule_isSetVariable (PR) );
  fail_unless( !Rule_isSetUnits(PR) );
}
END_TEST


//START_TEST (test_ParameterRule_createWith)
//{
//  Rule_t *pr;
//
//
//  pr = Rule_createRateWithVariableAndFormula("c", "v + 1");
//  Rule_setL1TypeCode(pr, SBML_PARAMETER_RULE);
//
//  fail_unless( SBase_getTypeCode((SBase_t *) pr) ==
//               SBML_RATE_RULE );
//  fail_unless( Rule_getL1TypeCode((Rule_t *) pr) ==
//               SBML_PARAMETER_RULE );
//  fail_unless( SBase_getNotes     ((SBase_t *) pr) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) pr) == NULL );
//
//  fail_unless( Rule_getUnits(pr) == NULL );
//
//  fail_unless( !strcmp(Rule_getFormula(pr), "v + 1") );
//  fail_unless( !strcmp(Rule_getVariable(pr), "c") );
//
//  fail_unless( Rule_getType( pr) ==  RULE_TYPE_RATE );
//
//  fail_unless( Rule_isSetVariable(pr) );
//  fail_unless( !Rule_isSetUnits(pr) );
//
//  Rule_free(pr);
//}
//END_TEST


START_TEST (test_ParameterRule_free_NULL)
{
  Rule_free(NULL);
}
END_TEST


START_TEST (test_ParameterRule_setName)
{
  const char *name = "cell";
  const char *c;


  Rule_setVariable(PR, name);

  fail_unless( !strcmp(Rule_getVariable(PR), name));
  fail_unless( Rule_isSetVariable(PR) );

  if (Rule_getVariable(PR) == name)
  {
    fail( "ParameterRule_setName(...) did not make a copy of string." );
          
  }

  /* Reflexive case (pathological) */
  c = Rule_getVariable(PR);
  Rule_setVariable(PR, c);
  fail_unless( !strcmp(Rule_getVariable(PR), name),
               NULL );

  Rule_setVariable(PR, NULL);
  fail_unless( !Rule_isSetVariable(PR) );

  if (Rule_getVariable(PR) != NULL)
  {
    fail( "Rule_setVariable(PR, NULL)"
          " did not clear string." );
  }
}
END_TEST


START_TEST (test_ParameterRule_setUnits)
{
  const char *units = "cell";


  Rule_setUnits(PR, units);

  fail_unless( !strcmp(Rule_getUnits(PR), units)    );
  fail_unless( Rule_isSetUnits(PR) );

  if (Rule_getUnits(PR) == units)
  {
    fail( "Rule_setUnits(...) did not make a copy of string." );
  }

  /* Reflexive case (pathological) */
  Rule_setUnits(PR, Rule_getUnits(PR));
  fail_unless( !strcmp(Rule_getUnits(PR), units) );

  Rule_setUnits(PR, NULL);
  fail_unless( !Rule_isSetUnits(PR) );

  if (Rule_getUnits(PR) != NULL)
  {
    fail( "Rule_setUnits(PR, NULL) did not clear string." );
  }
}
END_TEST


Suite *
create_suite_ParameterRule (void)
{
  Suite *suite = suite_create("ParameterRule");
  TCase *tcase = tcase_create("ParameterRule");


  tcase_add_checked_fixture( tcase,
                             ParameterRuleTest_setup,
                             ParameterRuleTest_teardown );

  tcase_add_test( tcase, test_ParameterRule_create     );
  //tcase_add_test( tcase, test_ParameterRule_createWith );
  tcase_add_test( tcase, test_ParameterRule_free_NULL  );
  tcase_add_test( tcase, test_ParameterRule_setName    );
  tcase_add_test( tcase, test_ParameterRule_setUnits   );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

