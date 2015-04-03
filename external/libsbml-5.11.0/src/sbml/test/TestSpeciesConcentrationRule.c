/**
 * \file    TestSpeciesConcentrationRule.c
 * \brief   SpeciesConcentrationRule unit tests
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

static Rule_t *SCR;


void
SpeciesConcentrationRuleTest_setup (void)
{
  SCR = Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(SCR, SBML_SPECIES_CONCENTRATION_RULE);

  if (SCR == NULL)
  {
    fail("Rule_createAssignment() returned a NULL pointer.");
  }
}


void
SpeciesConcentrationRuleTest_teardown (void)
{
  Rule_free(SCR);
}


START_TEST (test_SpeciesConcentrationRule_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) SCR) ==
               SBML_ASSIGNMENT_RULE );
  fail_unless( Rule_getL1TypeCode((Rule_t *) SCR) ==
               SBML_SPECIES_CONCENTRATION_RULE );

  fail_unless( SBase_getNotes     ((SBase_t *) SCR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) SCR) == NULL );

  fail_unless( Rule_getFormula((Rule_t *) SCR) == NULL );
  fail_unless( Rule_getType((Rule_t *) SCR) ==  RULE_TYPE_SCALAR );

  fail_unless( Rule_getVariable(SCR) == NULL );
  fail_unless( !Rule_isSetVariable(SCR) );
}
END_TEST


//START_TEST (test_SpeciesConcentrationRule_createWith)
//{
//  Rule_t *scr;
//
//
//  scr = Rule_createRateWithVariableAndFormula("c", "v + 1");
//  Rule_setL1TypeCode(scr, SBML_SPECIES_CONCENTRATION_RULE);
//
//  fail_unless( SBase_getTypeCode((SBase_t *) scr) ==
//               SBML_RATE_RULE );
//  fail_unless( Rule_getL1TypeCode((Rule_t *) scr) ==
//               SBML_SPECIES_CONCENTRATION_RULE );
//
//  fail_unless( SBase_getNotes     ((SBase_t *) scr) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) scr) == NULL );
//
//  fail_unless( !strcmp(Rule_getFormula( scr), "v + 1") );
//  fail_unless( !strcmp(Rule_getVariable(scr), "c") );
//
//  fail_unless( Rule_getType( scr) ==  RULE_TYPE_RATE );
//
//  fail_unless( Rule_isSetVariable(scr) );
//
//  Rule_free(scr);
//}
//END_TEST


START_TEST (test_SpeciesConcentrationRule_free_NULL)
{
  Rule_free(NULL);
}
END_TEST


START_TEST (test_SpeciesConcentrationRule_setSpecies)
{
  const char       *species = "s2";
  const char *s;


  Rule_setVariable(SCR, species);

  fail_unless( !strcmp(Rule_getVariable(SCR), species),
               NULL );
  fail_unless( Rule_isSetVariable(SCR) );

  if (Rule_getVariable(SCR) == species)
  {
    fail( "SpeciesConcentrationRule_setSpecies(...)"
          " did not make a copy of string." );
  }

  /* Reflexive case (pathological) */
  s = Rule_getVariable(SCR);
  Rule_setVariable(SCR, s);
  fail_unless( !strcmp(Rule_getVariable(SCR), species),
               NULL );

  Rule_setVariable(SCR, NULL);
  fail_unless( !Rule_isSetVariable(SCR) );

  if (Rule_getVariable(SCR) != NULL)
  {
    fail( "SpeciesConcentrationRule_setSpecies(SCR, NULL)"
          " did not clear string." );
  }
}
END_TEST


Suite *
create_suite_SpeciesConcentrationRule (void)
{
  Suite *suite = suite_create("SpeciesConcentrationRule");
  TCase *tcase = tcase_create("SpeciesConcentrationRule");


  tcase_add_checked_fixture( tcase,
                             SpeciesConcentrationRuleTest_setup,
                             SpeciesConcentrationRuleTest_teardown );

  tcase_add_test( tcase, test_SpeciesConcentrationRule_create     );
  //tcase_add_test( tcase, test_SpeciesConcentrationRule_createWith );
  tcase_add_test( tcase, test_SpeciesConcentrationRule_free_NULL  );
  tcase_add_test( tcase, test_SpeciesConcentrationRule_setSpecies );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

