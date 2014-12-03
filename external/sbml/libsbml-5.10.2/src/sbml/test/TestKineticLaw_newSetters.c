/**
 * \file    TestKineticLaw_newSetters.c
 * \brief   KineticLaw unit tests for new set function API
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
#include <sbml/KineticLaw.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static KineticLaw_t *kl;


void
KineticLawTest1_setup (void)
{
  kl = KineticLaw_create(2, 4);

  if (kl == NULL)
  {
    fail("KineticLaw_create() returned a NULL pointer.");
  }
}


void
KineticLawTest1_teardown (void)
{
  KineticLaw_free(kl);
}



START_TEST (test_KineticLaw_setFormula1)
{
  const char *formula = "k1*X0";

  int i = KineticLaw_setFormula(kl, formula);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(KineticLaw_getFormula(kl), formula) );
  fail_unless( KineticLaw_isSetFormula(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setFormula2)
{
  int i = KineticLaw_setFormula(kl, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetFormula(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setFormula3)
{
  const char *formula = "k1 X0";

  int i = KineticLaw_setFormula(kl, formula);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !KineticLaw_isSetFormula(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setMath1)
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

  int i = KineticLaw_setMath(kl, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_isSetMath(kl)   );

  math1 = KineticLaw_getMath(kl);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "a * b") );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_KineticLaw_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_t *a = ASTNode_create();
  ASTNode_setName(a, "a");
  ASTNode_addChild(math, a);

  int i = KineticLaw_setMath(kl, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !KineticLaw_isSetMath(kl)   );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_KineticLaw_setMath3)
{
  int i = KineticLaw_setMath(kl, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetMath(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setTimeUnits1)
{
  int i = KineticLaw_setTimeUnits(kl, "second");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !KineticLaw_isSetTimeUnits(kl)   );

  i = KineticLaw_unsetTimeUnits(kl);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !KineticLaw_isSetTimeUnits(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setTimeUnits2)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setTimeUnits(kl1, "second");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_isSetTimeUnits(kl1)   );

  i = KineticLaw_unsetTimeUnits(kl1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetTimeUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_setTimeUnits3)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setTimeUnits(kl1, "1second");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( !KineticLaw_isSetTimeUnits(kl1)   );

  i = KineticLaw_unsetTimeUnits(kl1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetTimeUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_setTimeUnits4)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setTimeUnits(kl1, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetTimeUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_setSubstanceUnits1)
{
  int i = KineticLaw_setSubstanceUnits(kl, "mole");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl)   );

  i = KineticLaw_unsetSubstanceUnits(kl);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl)   );
}
END_TEST


START_TEST (test_KineticLaw_setSubstanceUnits2)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setSubstanceUnits(kl1, "mole");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_isSetSubstanceUnits(kl1)   );

  i = KineticLaw_unsetSubstanceUnits(kl1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_setSubstanceUnits3)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setSubstanceUnits(kl1, "1second");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl1)   );

  i = KineticLaw_unsetSubstanceUnits(kl1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_setSubstanceUnits4)
{
  KineticLaw_t *kl1 = 
    KineticLaw_create(1, 2);
  
  int i = KineticLaw_setSubstanceUnits(kl1, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !KineticLaw_isSetSubstanceUnits(kl1)   );

  KineticLaw_free(kl1);
}
END_TEST


START_TEST (test_KineticLaw_addParameter1)
{
  KineticLaw_t *kl = KineticLaw_create(2, 2);
  Parameter_t *p 
    = Parameter_create(2, 2);

  int i = KineticLaw_addParameter(kl, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Parameter_setId(p, "p");
  i = KineticLaw_addParameter(kl, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_getNumParameters(kl) == 1);

  Parameter_free(p);
  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_KineticLaw_addParameter2)
{
  KineticLaw_t *kl = KineticLaw_create(2, 2);
  Parameter_t *p 
    = Parameter_create(2, 1);
  Parameter_setId(p, "p");

  int i = KineticLaw_addParameter(kl, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( KineticLaw_getNumParameters(kl) == 0);

  Parameter_free(p);
  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_KineticLaw_addParameter3)
{
  KineticLaw_t *kl = KineticLaw_create(2, 2);
  Parameter_t *p 
    = Parameter_create(1, 2);
  Parameter_setId(p, "p");

  int i = KineticLaw_addParameter(kl, p);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( KineticLaw_getNumParameters(kl) == 0);

  Parameter_free(p);
  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_KineticLaw_addParameter4)
{
  KineticLaw_t *kl = KineticLaw_create(2, 2);
  Parameter_t *p = NULL;

  int i = KineticLaw_addParameter(kl, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( KineticLaw_getNumParameters(kl) == 0);

  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_KineticLaw_createParameter)
{
  KineticLaw_t *kl = KineticLaw_create(2, 2);
  
  Parameter_t *p = KineticLaw_createParameter(kl);

  fail_unless( KineticLaw_getNumParameters(kl) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  KineticLaw_free(kl);
}
END_TEST


Suite *
create_suite_KineticLaw_newSetters (void)
{
  Suite *suite = suite_create("KineticLaw_newSetters");
  TCase *tcase = tcase_create("KineticLaw_newSetters");


  tcase_add_checked_fixture( tcase,
                             KineticLawTest1_setup,
                             KineticLawTest1_teardown );

  tcase_add_test( tcase, test_KineticLaw_setFormula1         );
  tcase_add_test( tcase, test_KineticLaw_setFormula2         );
  tcase_add_test( tcase, test_KineticLaw_setFormula3         );
  tcase_add_test( tcase, test_KineticLaw_setMath1            );
  tcase_add_test( tcase, test_KineticLaw_setMath2            );
  tcase_add_test( tcase, test_KineticLaw_setMath3            );
  tcase_add_test( tcase, test_KineticLaw_setTimeUnits1            );
  tcase_add_test( tcase, test_KineticLaw_setTimeUnits2            );
  tcase_add_test( tcase, test_KineticLaw_setTimeUnits3            );
  tcase_add_test( tcase, test_KineticLaw_setTimeUnits4            );
  tcase_add_test( tcase, test_KineticLaw_setSubstanceUnits1            );
  tcase_add_test( tcase, test_KineticLaw_setSubstanceUnits2            );
  tcase_add_test( tcase, test_KineticLaw_setSubstanceUnits3            );
  tcase_add_test( tcase, test_KineticLaw_setSubstanceUnits4            );
  tcase_add_test( tcase, test_KineticLaw_addParameter1            );
  tcase_add_test( tcase, test_KineticLaw_addParameter2            );
  tcase_add_test( tcase, test_KineticLaw_addParameter3            );
  tcase_add_test( tcase, test_KineticLaw_addParameter4            );
  tcase_add_test( tcase, test_KineticLaw_createParameter          );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


