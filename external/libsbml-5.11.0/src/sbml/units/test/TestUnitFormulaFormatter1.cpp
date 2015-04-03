/**
 * \file    TestUnitFormulaFormatter1.cpp
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
 * tests the results from different model
 * components that have units
 * e.g. compartment; species; parameter
 */

BEGIN_C_DECLS


void
UnitFormulaFormatter1Test_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "components.xml");


  d = readSBML(filename);
  m = d->getModel();

  uff = new UnitFormulaFormatter(m);

  safe_free(filename);
}


void
UnitFormulaFormatter1Test_teardown (void)
{
  delete uff;
  delete d;
}

START_TEST (test_UnitFormulaFormatter1_getUnitDefinition_compartment)
{  
  UnitDefinition * ud = NULL;
  
  /* compartment with declared standard units */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(0));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* compartment with declared units from unit definition */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(1));

  UnitDefinition::simplify(ud);

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 3);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* compartment with no declared units spatial dimensions = 0 */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(2));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);


  delete ud;

  /* compartment with no declared units spatial dimensions = 1 */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(3));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* compartment with no declared units spatial dimensions = 2 */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(4));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 2);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* compartment with no declared units spatial dimensions = 3 */
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(5));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* compartment with builtin units volume*/
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(6));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* compartment with builtin units area*/
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(7));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 2);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* compartment with builtin units length*/
  ud = uff->getUnitDefinitionFromCompartment(m->getCompartment(8));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* check deals with invalid nodes */
  delete ud;
  UnitDefinition * ud1 = NULL;
  
  Compartment *c = new Compartment(m->getLevel(), m->getVersion());
  c->setId("c");
  c->setUnits("undefined");

  ud1 = uff->getUnitDefinitionFromCompartment(c);

  fail_unless (ud1->getNumUnits() == 0);

  delete c;
  delete ud1;
}
END_TEST

START_TEST (test_UnitFormulaFormatter1_getUnitDefinition_species)
{
  UnitDefinition * ud = NULL;
  
  /* species with declared standard units for substance and spatialSize*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(0));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* species with declared standard units for substance and hasOnlySubstanceUnits = 1*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(1));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete ud;

  /* species with declared units from unit definition for substance and hasOnlySubstanceUnits = 1*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(2));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete ud;

  /* species with declared standard units for substance and no spatialSizeUnits*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(3));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -2);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* species with declared standard units for spatialSizeUnits but no substance*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(4));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* species with declared units from unit definition for spatialSizeUnits but no substance*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(5));

  UnitDefinition::simplify(ud);

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -3);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* species with no units for substance and spatialSize*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(6));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_LITRE);

  delete ud;

  /* species with builtin units for substance and spatialSize*/
  ud = uff->getUnitDefinitionFromSpecies(m->getSpecies(7));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_LITRE);

  /* check deals with invalid nodes */
  delete ud;
  UnitDefinition * ud1 = NULL;
  
  Species *s = new Species(m->getLevel(), m->getVersion());
  s->setId("s");
  s->setUnits("undefined");

  ud1 = uff->getUnitDefinitionFromSpecies(s);

  fail_unless (ud1->getNumUnits() == 0);

  delete ud1;

  s->setUnits("mole"); // here the compartment size will be NULL

  ud1 = uff->getUnitDefinitionFromSpecies(s);

  fail_unless (ud1->getNumUnits() == 1);
  delete s;
  delete ud1;

}
END_TEST

START_TEST (test_UnitFormulaFormatter1_getUnitDefinition_parameter)
{
  UnitDefinition * ud = NULL;
 
  /* parameter with declared standard units */
  ud = uff->getUnitDefinitionFromParameter(m->getParameter(0));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* parameter with declared units from unit definition */
  ud = uff->getUnitDefinitionFromParameter(m->getParameter(1));

  fail_unless(ud->getNumUnits() == 2);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == -1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);

  delete ud;

  /* parameter with no declared units */
  ud = uff->getUnitDefinitionFromParameter(m->getParameter(2));

  fail_unless(ud->getNumUnits() == 0);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  delete ud;
 
  /* parameter with builtin units time */
  ud = uff->getUnitDefinitionFromParameter(m->getParameter(3));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  ///* check deals with invalid nodes */
  delete ud;
  UnitDefinition * ud1 = NULL;
  
  Parameter *p = new Parameter(m->getLevel(), m->getVersion());
  p->setId("p");
  p->setUnits("undefined");

  ud1 = uff->getUnitDefinitionFromParameter(p);

  fail_unless (ud1->getNumUnits() == 0);

  delete p;
  delete ud1;

}
END_TEST

START_TEST (test_UnitFormulaFormatter1_getUnitDefinition_function)
{
  UnitDefinition * ud = NULL;
 
  /* function applied to numbers only */
  ud = uff->getUnitDefinition(m->getRule(0)->getMath());

  fail_unless(ud->getNumUnits() == 0);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);


  delete ud;

  /* function applied to components */
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(1)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == -2);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete ud;

  /* function with two arguments but only one bvar */
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(2)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 3);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete ud;

  /* function with two arguments but only one bvar */
  uff->resetFlags();
  ud = uff->getUnitDefinition(m->getRule(3)->getMath());

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == -1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete ud;

}
END_TEST


START_TEST (test_UnitFormulaFormatter1_getUnitDefinition_event)
{
  UnitDefinition * ud = NULL;

  /* event with no time units */
  ud = uff->getUnitDefinitionFromEventTime(m->getEvent(0));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete ud;

  /* event with declared units from unit definition */
  ud = uff->getUnitDefinitionFromEventTime(m->getEvent(1));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 60);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete ud;

  /* event with declared units second */
  ud = uff->getUnitDefinitionFromEventTime(m->getEvent(2));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);


  delete ud;

  /* event with declared units time */
  ud = uff->getUnitDefinitionFromEventTime(m->getEvent(3));

  fail_unless(ud->getNumUnits() == 1);

  fail_unless(!strcmp(ud->getId().c_str(), ""), NULL);

  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  
  /* check deals with invalid nodes */
  delete ud;
  UnitDefinition * ud1 = NULL;
  
  Event *e = new Event(m->getLevel(), m->getVersion());
  e->setId("p");
  e->setTimeUnits("undefined");

  ud1 = uff->getUnitDefinitionFromEventTime(e);

  fail_unless (ud1->getNumUnits() == 0);

  delete e;
  delete ud1;

}
END_TEST


Suite *
create_suite_UnitFormulaFormatter1 (void)
{
  Suite *suite = suite_create("UnitFormulaFormatter1");
  TCase *tcase = tcase_create("UnitFormulaFormatter1");

  tcase_add_checked_fixture(tcase,
                            UnitFormulaFormatter1Test_setup,
                            UnitFormulaFormatter1Test_teardown);

  tcase_add_test(tcase, test_UnitFormulaFormatter1_getUnitDefinition_compartment );
  tcase_add_test(tcase, test_UnitFormulaFormatter1_getUnitDefinition_species );
  tcase_add_test(tcase, test_UnitFormulaFormatter1_getUnitDefinition_parameter );
  tcase_add_test(tcase, test_UnitFormulaFormatter1_getUnitDefinition_function );
  tcase_add_test(tcase, test_UnitFormulaFormatter1_getUnitDefinition_event);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
