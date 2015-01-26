/**
 * \file    TestRule_newSetters.c
 * \brief   Rule unit tests for new set function API
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

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>

#include <sbml/SBase.h>
#include <sbml/Parameter.h>
#include <sbml/Rule.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Rule_t *R;


void
RuleTest1_setup (void)
{
  R = Rule_createAssignment(2, 4);

  if (R == NULL)
  {
    fail("Rule_create() returned a NULL pointer.");
  }
}


void
RuleTest1_teardown (void)
{
  Rule_free(R);
}



START_TEST (test_Rule_setFormula1)
{
  const char *formula = "k1*X0";

  int i = Rule_setFormula(R, formula);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(Rule_getFormula(R), formula) );
  fail_unless( Rule_isSetFormula(R)   );
}
END_TEST


START_TEST (test_Rule_setFormula2)
{
  int i = Rule_setFormula(R, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetFormula(R)   );
}
END_TEST


START_TEST (test_Rule_setFormula3)
{
  const char *formula = "k1 X0";

  int i = Rule_setFormula(R, formula);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !Rule_isSetFormula(R)   );
}
END_TEST


START_TEST (test_Rule_setMath1)
{
  ASTNode_t *math = ASTNode_createWithType(AST_TIMES);
  ASTNode_t *a = ASTNode_create();
  ASTNode_t *b = ASTNode_create();
  ASTNode_setName(a, "a");
  ASTNode_setName(b, "b");
  ASTNode_addChild(math, a);
  ASTNode_addChild(math, b);
  char *formula;
  const ASTNode_t *math1;

  int i = Rule_setMath(R, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Rule_isSetMath(R)   );

  math1 = Rule_getMath(R);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "a * b") );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Rule_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_t *a = ASTNode_create();
  ASTNode_setName(a, "a");
  ASTNode_addChild(math, a);

  int i = Rule_setMath(R, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !Rule_isSetMath(R)   );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Rule_setMath3)
{
  int i = Rule_setMath(R, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetMath(R)   );
}
END_TEST


START_TEST (test_Rule_setUnits1)
{
  int i = Rule_setUnits(R, "second");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !Rule_isSetUnits(R)   );
}
END_TEST


START_TEST (test_Rule_setUnits2)
{
  Rule_t *R1 = 
    Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(R1, SBML_PARAMETER_RULE);

  int i = Rule_setUnits(R1, "second");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Rule_isSetUnits(R1)   );

  i = Rule_unsetUnits(R1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetUnits(R1)   );

  Rule_free(R1);
}
END_TEST


START_TEST (test_Rule_setUnits3)
{
  Rule_t *R1 = 
    Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(R1, SBML_PARAMETER_RULE);
  
  int i = Rule_setUnits(R1, "1second");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( !Rule_isSetUnits(R1)   );

  i = Rule_unsetUnits(R1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetUnits(R1)   );

  Rule_free(R1);
}
END_TEST


START_TEST (test_Rule_setUnits4)
{
  Rule_t *R1 = 
    Rule_createAssignment(1, 2);
  Rule_setL1TypeCode(R1, SBML_PARAMETER_RULE);

  int i = Rule_setUnits(R1, "second");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Rule_isSetUnits(R1)   );

  i = Rule_setUnits(R1, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetUnits(R1)   );

  Rule_free(R1);
}
END_TEST


START_TEST (test_Rule_setVariable1)
{
  int i = Rule_setVariable(R, "1mole");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( !Rule_isSetVariable(R)   );
}
END_TEST


START_TEST (test_Rule_setVariable2)
{
  int i = Rule_setVariable(R, "mole");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Rule_isSetVariable(R)   );

  i = Rule_setVariable(R, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Rule_isSetVariable(R)   );
}
END_TEST


START_TEST (test_Rule_setVariable3)
{
  Rule_t *R1 = 
    Rule_createAlgebraic(1, 2);
  
  int i = Rule_setVariable(R1, "r");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !Rule_isSetVariable(R1)   );

  Rule_free(R1);
}
END_TEST


Suite *
create_suite_Rule_newSetters (void)
{
  Suite *suite = suite_create("Rule_newSetters");
  TCase *tcase = tcase_create("Rule_newSetters");


  tcase_add_checked_fixture( tcase,
                             RuleTest1_setup,
                             RuleTest1_teardown );

  tcase_add_test( tcase, test_Rule_setFormula1         );
  tcase_add_test( tcase, test_Rule_setFormula2         );
  tcase_add_test( tcase, test_Rule_setFormula3         );
  tcase_add_test( tcase, test_Rule_setMath1            );
  tcase_add_test( tcase, test_Rule_setMath2            );
  tcase_add_test( tcase, test_Rule_setMath3            );
  tcase_add_test( tcase, test_Rule_setUnits1            );
  tcase_add_test( tcase, test_Rule_setUnits2            );
  tcase_add_test( tcase, test_Rule_setUnits3            );
  tcase_add_test( tcase, test_Rule_setUnits4            );
  tcase_add_test( tcase, test_Rule_setVariable1            );
  tcase_add_test( tcase, test_Rule_setVariable2            );
  tcase_add_test( tcase, test_Rule_setVariable3            );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

