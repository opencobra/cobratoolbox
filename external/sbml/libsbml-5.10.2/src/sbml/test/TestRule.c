/**
 * \file    TestRule.c
 * \brief   Rule unit tests
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

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>

#include <sbml/SBase.h>
#include <sbml/Rule.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Rule_t *R;


void
RuleTest_setup (void)
{
  R = Rule_createAlgebraic(2, 4);

  if (R == NULL)
  {
    fail("Rule_createAlgebraic() returned a NULL pointer.");
  }
}


void
RuleTest_teardown (void)
{
  Rule_free(R);
}


START_TEST (test_Rule_init)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) R) == SBML_ALGEBRAIC_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) R) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) R) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) R) == NULL );

  fail_unless( Rule_getFormula(R) == NULL );
  fail_unless( Rule_getMath   (R) == NULL );
}
END_TEST


START_TEST (test_Rule_setFormula)
{
  const char *formula = "k1*X0";


  Rule_setFormula(R, formula);

  fail_unless( !strcmp(Rule_getFormula(R), formula) );
  fail_unless( Rule_isSetFormula(R) == 1 );

  if (Rule_getFormula(R) == formula)
  {
    fail("Rule_setFormula(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Rule_setFormula(R, Rule_getFormula(R));
  fail_unless( !strcmp(Rule_getFormula(R), formula) );

  Rule_setFormula(R, "");
  fail_unless( Rule_isSetFormula(R) == 0 );

  if (Rule_getFormula(R) != NULL)
  {
    fail("Rule_setFormula(R, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Rule_setMath)
{
  ASTNode_t *math = SBML_parseFormula("1 + 1");


  Rule_setMath(R, math);

  fail_unless( Rule_getMath(R) != math );
  fail_unless( Rule_isSetMath(R) );

  /* Reflexive case (pathological) */
  Rule_setMath(R, (ASTNode_t *) Rule_getMath(R));
  fail_unless( Rule_getMath(R) != math );

  Rule_setMath(R, NULL);
  fail_unless( !Rule_isSetMath(R) );

  if (Rule_getMath(R) != NULL)
  {
    fail("Rule_setMath(R, NULL) did not clear ASTNode.");
  }
}
END_TEST


Suite *
create_suite_Rule (void)
{
  Suite *suite = suite_create("Rule");
  TCase *tcase = tcase_create("Rule");


  tcase_add_checked_fixture( tcase, RuleTest_setup, RuleTest_teardown );

  tcase_add_test( tcase, test_Rule_init               );
  tcase_add_test( tcase, test_Rule_setFormula         );
  tcase_add_test( tcase, test_Rule_setMath            );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


