/**
 * \file    TestUnitFormulaFormatter.cpp
 * \brief   UnitFormulaFormatter unit tests
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
static 

void
UnitFormulaFormatterTest_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "rules.xml");


  d = readSBML(filename);
  m = d->getModel();

  uff = new UnitFormulaFormatter(m);

  safe_free(filename);

}


void
UnitFormulaFormatterTest_teardown (void)
{
  delete uff;
  delete d;
}

/* put in a test for each possible type of ASTNode
   this will facilitate the transition to ucar library if necessary */
START_TEST (test_UnitFormulaFormatter_getUnitDefinition_unknown)
{
  ASTNode * node = new ASTNode(AST_UNKNOWN);
  UnitDefinition * ud = uff->getUnitDefinition(node);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 0);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  delete node;
  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_boolean)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(0)->getMath());

  fail_unless(ud->getNumUnits() == 1);
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_dimensionless)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(1)->getMath());
  
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
  
  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_invtrig)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(2)->getMath());
 
  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_plus)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(3)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);


  /* check plus with no arguments*/
  /* plus() = 0 undeclared units */
  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(16)->getMath());

  fail_unless(ud->getNumUnits() == 0);
  
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);


  /* check plus with one arguments*/
  /* plus(k) = k with units of k */
  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(17)->getMath());

  fail_unless(ud->getNumUnits() == 1);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_power)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(4)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 2);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_times)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(5)->getMath());

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 2);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);

  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(9)->getMath());

  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* check times with no arguments*/
  /* times() = 1 dimensionless */
  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(14)->getMath());

  fail_unless(ud->getNumUnits() == 1);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);


  /* check times with one arguments*/
  /* times(k) = k with units of k */
  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(15)->getMath());

  fail_unless(ud->getNumUnits() == 1);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_divide)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(6)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete ud;

}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_piecewise)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(7)->getMath());

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* check deals with invalid nodes */
  delete ud;
  ASTNode *node = new ASTNode(AST_FUNCTION_PIECEWISE);

  uff->resetFlags();
  UnitDefinition *ud1 = uff->getUnitDefinition(node);

  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless (ud1->getNumUnits() == 0);

  ASTNode *c = new ASTNode(AST_UNKNOWN);
  node->addChild(c);
  
  delete ud1;
  uff->resetFlags();
  ud1 = uff->getUnitDefinition(node);

  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless (ud1->getNumUnits() == 0);

  delete ud1;
  delete node;
}
END_TEST

START_TEST (test_UnitFormulaFormatter_getUnitDefinition_root)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(8)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_VOLT);

  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_getUnitDefinition_delay)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(10)->getMath());

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_getUnitDefinition_reaction)
{
  UnitDefinition * ud = uff->getUnitDefinition(m->getRule(13)->getMath());

  fail_unless(ud->getNumUnits() == 3);

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == 1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(2)->getMultiplier() == 1);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(ud->getUnit(2)->getExponent() == -1);
  fail_unless(ud->getUnit(2)->getOffset() == 0.0);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);

  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_getUnitDefinition_hasUndeclaredUnits)
{
  UnitDefinition * ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(9)->getMath());
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(11)->getMath());
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(12)->getMath());
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == true);

  delete ud;
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(18)->getMath());
  fail_unless(uff->getContainsUndeclaredUnits() == true);
  fail_unless(uff->canIgnoreUndeclaredUnits() == true);

  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_times)
{
  ASTNode * node = SBML_parseFormula("k1*a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(uff->getContainsUndeclaredUnits() == false);
  fail_unless(uff->canIgnoreUndeclaredUnits() == false);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_times1)
{
  ASTNode * node = SBML_parseFormula("a*k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_times2)
{
  ASTNode * node = SBML_parseFormula("k1*a*k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_times3)
{
  ASTNode * node = SBML_parseFormula("a*k1*k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_times4)
{
  ASTNode * node = SBML_parseFormula("a*k1*k1*k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(4);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_divide)
{
  ASTNode * node = SBML_parseFormula("k1/a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_DIMENSIONLESS);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_divide1)
{
  ASTNode * node = SBML_parseFormula("a/k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 2);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_divide2)
{
  ASTNode * node = SBML_parseFormula("k1/(a/k1)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(1);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_divide3)
{
  ASTNode * node = SBML_parseFormula("a/(k1/k1)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 3);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_divide4)
{
  ASTNode * node = SBML_parseFormula("(a/k1)/(k1/k1)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 3);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_plus)
{
  ASTNode * node = SBML_parseFormula("k1+a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_plus1)
{
  ASTNode * node = SBML_parseFormula("a+k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_plus2)
{
  ASTNode * node = SBML_parseFormula("k1+a+k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_plus3)
{
  ASTNode * node = SBML_parseFormula("a+k1+k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_plus4)
{
  ASTNode * node = SBML_parseFormula("a+k1+k1+k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_minus)
{
  ASTNode * node = SBML_parseFormula("k1-a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_minus1)
{
  ASTNode * node = SBML_parseFormula("a-k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_minus2)
{
  ASTNode * node = SBML_parseFormula("k1-a-k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_minus3)
{
  ASTNode * node = SBML_parseFormula("a-k1-k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_minus4)
{
  ASTNode * node = SBML_parseFormula("a-k1-k1-k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_power)
{
  ASTNode * node = SBML_parseFormula("k1^a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_power1)
{
  ASTNode * node = SBML_parseFormula("a^2");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_power2)
{
  ASTNode * node = SBML_parseFormula("k1^(k1*a)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == -1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_power3)
{
  ASTNode * node = SBML_parseFormula("a^(cell/cell)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);

    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_power4)
{
  ASTNode * node = SBML_parseFormula("a^k1");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);

    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud == NULL);

  delete node;
  delete expUD;
}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_name)
{
  ASTNode * node = SBML_parseFormula("a");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_unknown)
{
  ASTNode * node = SBML_parseFormula("b");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud == NULL);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter_inferUnitDefinition_unknown1)
{
  ASTNode * node = SBML_parseFormula("sin(a)");
  UnitDefinition * ud = NULL;
  UnitDefinition * expUD = new UnitDefinition(m->getSBMLNamespaces());
  Unit * u = expUD->createUnit();
  u->setKind(UNIT_KIND_METRE);
    
  ud = uff->inferUnitDefinition(expUD, node, "a");

  fail_unless(ud == NULL);

  delete node;
  delete expUD;
  delete ud;

}
END_TEST


Suite *
create_suite_UnitFormulaFormatter (void)
{
  Suite *suite = suite_create("UnitFormulaFormatter");
  TCase *tcase = tcase_create("UnitFormulaFormatter");

  tcase_add_checked_fixture(tcase,
                            UnitFormulaFormatterTest_setup,
                            UnitFormulaFormatterTest_teardown);

  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_unknown );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_boolean );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_dimensionless );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_invtrig );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_plus );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_power );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_times );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_divide );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_piecewise );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_root );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_delay );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_reaction );
  tcase_add_test(tcase, test_UnitFormulaFormatter_getUnitDefinition_hasUndeclaredUnits );

  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_times );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_times1 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_times2 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_times3 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_times4 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_divide );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_divide1 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_divide2 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_divide3 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_divide4 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_plus );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_plus1 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_plus2 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_plus3 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_plus4 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_minus );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_minus1 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_minus2 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_minus3 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_minus4 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_power );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_power1 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_power2 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_power3 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_power4 );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_name );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_unknown );
  tcase_add_test(tcase, test_UnitFormulaFormatter_inferUnitDefinition_unknown1 );
  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
