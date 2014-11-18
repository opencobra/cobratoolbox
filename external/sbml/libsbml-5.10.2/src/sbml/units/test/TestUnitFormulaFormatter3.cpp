/**
 * \file    TestUnitFormulaFormatter4.cpp
 * \brief   UnitFormulaFormatter unit tests
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
#include <sbml/common/extern.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>

#include <sbml/units/UnitFormulaFormatter.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

extern char *TestDataDirectory;

static UnitFormulaFormatter *uff;
static Model *m;
static SBMLDocument* d;

/* 
 * tests the results from different mathematical functions
 * components that have units
 * e.g. times
 */
BEGIN_C_DECLS


void
UnitFormulaFormatter3Test_setup (void)
{
  d = new SBMLDocument();
 
  char *filename = safe_strcat(TestDataDirectory, "unitsTest.xml");

  d = readSBML(filename);
  m = d->getModel();

  uff = new UnitFormulaFormatter(m);

  safe_free(filename);

}


void
UnitFormulaFormatter3Test_teardown (void)
{
  delete uff;
  delete d;
}

START_TEST (test_getUnitDefinition_power_no_children)
{
  ASTNode * node = new ASTNode(AST_POWER);
  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 0);

  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_one_child)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  node->addChild(c);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), 1));


  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_three_children)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(1);
  ASTNode * c2 = new ASTNode(AST_INTEGER);
  c2->setValue(2);
  node->addChild(c);
  node->addChild(c1);
  node->addChild(c2);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 0);

  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_integer_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(4);
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), 4));

  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_neg_integer_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(-3);
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), -3));

  delete node;
  delete ud;

}
END_TEST

#if (0)
START_TEST (test_getUnitDefinition_power_minus_integer_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(3);
  ASTNode * c2 = new ASTNode(AST_MINUS);
  c2->addChild(c1);
  node->addChild(c);
  node->addChild(c2);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), -3));

  delete node;
  delete ud;

}
END_TEST
#endif

START_TEST (test_getUnitDefinition_power_double_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_REAL);
  c1->setValue(3.2);
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), 3.2));

  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_neg_double_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_REAL);
  c1->setValue(-1.5);
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), -1.5));

  delete node;
  delete ud;

}
END_TEST

#if (0)
START_TEST (test_getUnitDefinition_power_minus_double_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_REAL);
  c1->setValue(0.3);
  ASTNode * c2 = new ASTNode(AST_MINUS);
  c2->addChild(c1);
  node->addChild(c);
  node->addChild(c2);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), -0.3));

  delete node;
  delete ud;

}
END_TEST
#endif

START_TEST (test_getUnitDefinition_power_dim_param_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("a");
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), 3.5));

  delete node;
  delete ud;

}
END_TEST


START_TEST (test_getUnitDefinition_power_nondim_param_exponent)
{
  ASTNode * node = new ASTNode(AST_POWER);
  ASTNode * c = new ASTNode(AST_NAME);
  c->setName("k");
  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("b");
  node->addChild(c);
  node->addChild(c1);

  UnitDefinition * ud = NULL;
    
  ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud != NULL);
  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), 1));

  delete node;
  delete ud;

}
END_TEST


Suite *
create_suite_UnitFormulaFormatter3 (void)
{
  Suite *suite = suite_create("UnitFormulaFormatter3");
  TCase *tcase = tcase_create("UnitFormulaFormatter3");

  tcase_add_checked_fixture(tcase,
                            UnitFormulaFormatter3Test_setup,
                            UnitFormulaFormatter3Test_teardown);

  tcase_add_test(tcase, test_getUnitDefinition_power_no_children );
  tcase_add_test(tcase, test_getUnitDefinition_power_one_child );
  tcase_add_test(tcase, test_getUnitDefinition_power_three_children );
  tcase_add_test(tcase, test_getUnitDefinition_power_integer_exponent );
  tcase_add_test(tcase, test_getUnitDefinition_power_neg_integer_exponent );
//  tcase_add_test(tcase, test_getUnitDefinition_power_minus_integer_exponent );
  tcase_add_test(tcase, test_getUnitDefinition_power_double_exponent );
  tcase_add_test(tcase, test_getUnitDefinition_power_neg_double_exponent );
//  tcase_add_test(tcase, test_getUnitDefinition_power_minus_double_exponent );
  tcase_add_test(tcase, test_getUnitDefinition_power_dim_param_exponent );
  tcase_add_test(tcase, test_getUnitDefinition_power_nondim_param_exponent );

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
