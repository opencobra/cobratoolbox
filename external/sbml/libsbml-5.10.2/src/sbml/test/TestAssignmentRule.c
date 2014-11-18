/**
 * \file    TestAssignmentRule.c
 * \brief   AssignmentRule unit tests
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
#include <sbml/Rule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static AssignmentRule_t *AR;


void
AssignmentRuleTest_setup (void)
{
  AR = AssignmentRule_create(2, 4);

  if (AR == NULL)
  {
    fail("AssignmentRule_create() returned a NULL pointer.");
  }
}


void
AssignmentRuleTest_teardown (void)
{
  AssignmentRule_free(AR);
}

START_TEST (test_AssignmentRule_L2_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) AR) == SBML_ASSIGNMENT_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) AR) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) AR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) AR) == NULL );

  fail_unless( AssignmentRule_getFormula(AR) == NULL );
  fail_unless( AssignmentRule_getMath   (AR) == NULL );

  fail_unless( AssignmentRule_getVariable(AR) == NULL );
  fail_unless( Rule_getType    ((Rule_t*)AR) == RULE_TYPE_SCALAR );
}
END_TEST


START_TEST (test_AssignmentRule_free_NULL)
{
  AssignmentRule_free(NULL);
}
END_TEST


START_TEST (test_AssignmentRule_setVariable)
{
  const char *variable = "x";


  AssignmentRule_setVariable(AR, variable);

  fail_unless( !strcmp(AssignmentRule_getVariable(AR), variable) );
  fail_unless( AssignmentRule_isSetVariable(AR) );

  if (AssignmentRule_getVariable(AR) == variable)
  {
    fail("AssignmentRule_setVariable(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  AssignmentRule_setVariable(AR, AssignmentRule_getVariable(AR));
  fail_unless( !strcmp(AssignmentRule_getVariable(AR), variable) );

  AssignmentRule_setVariable(AR, NULL);
  fail_unless( !AssignmentRule_isSetVariable(AR) );

  if (AssignmentRule_getVariable(AR) != NULL)
  {
    fail("AssignmentRule_setVariable(AR, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_AssignmentRule_createWithFormula)
{
  const ASTNode_t *math;
  char *formula;

  AssignmentRule_t *ar = AssignmentRule_create(2, 4);
  AssignmentRule_setVariable(ar, "s");
  AssignmentRule_setFormula(ar, "1 + 1");


  fail_unless( SBase_getTypeCode  ((SBase_t *) ar) == SBML_ASSIGNMENT_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) ar) == NULL );
  fail_unless( !strcmp(AssignmentRule_getVariable(ar), "s") );

  math = AssignmentRule_getMath(ar);
  fail_unless(math != NULL);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "1 + 1") );

  fail_unless( !strcmp(AssignmentRule_getFormula(ar), formula) );

  AssignmentRule_free(ar);
  safe_free(formula);
}
END_TEST


START_TEST (test_AssignmentRule_createWithMath)
{
  ASTNode_t       *math = SBML_parseFormula("1 + 1");

  AssignmentRule_t *ar = AssignmentRule_create(2, 4);
  AssignmentRule_setVariable(ar, "s");
  AssignmentRule_setMath(ar, math);


  fail_unless( SBase_getTypeCode  ((SBase_t *) ar) == SBML_ASSIGNMENT_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) ar) == NULL );
  fail_unless( !strcmp(AssignmentRule_getVariable(ar), "s") );
  fail_unless( !strcmp(AssignmentRule_getFormula(ar), "1 + 1") );
  fail_unless( AssignmentRule_getMath(ar) != math );

  AssignmentRule_free(ar);
}
END_TEST


START_TEST (test_AssignmentRule_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  AssignmentRule_t *object = 
    AssignmentRule_createWithNS(sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_ASSIGNMENT_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Rule_getNamespaces     ((Rule_t*) object) != NULL );
  fail_unless( XMLNamespaces_getLength(Rule_getNamespaces((Rule_t*)(object))) == 2 );

  Rule_free((Rule_t*)(object));
}
END_TEST


Suite *
create_suite_AssignmentRule (void)
{
  Suite *suite = suite_create("AssignmentRule");
  TCase *tcase = tcase_create("AssignmentRule");


  tcase_add_checked_fixture( tcase,
                             AssignmentRuleTest_setup,
                             AssignmentRuleTest_teardown );

  tcase_add_test( tcase, test_AssignmentRule_L2_create     );
  tcase_add_test( tcase, test_AssignmentRule_free_NULL     );
  tcase_add_test( tcase, test_AssignmentRule_setVariable   );
  tcase_add_test( tcase, test_AssignmentRule_createWithFormula   );
  tcase_add_test( tcase, test_AssignmentRule_createWithMath   );
  tcase_add_test( tcase, test_AssignmentRule_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

