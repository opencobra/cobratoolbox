/**
 * \file    TestCalculatedUnitDefinitions.cpp
 * \brief   unit tests for the getCalcUnitDefinition function
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
#include <sbml/SBMLTypeCodes.h>

#include <sbml/units/UnitFormulaFormatter.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

extern char *TestDataDirectory;

static Model *m;
static SBMLDocument* d;

/* 
 * tests the results from different model
 * components that have units
 * e.g. compartment; species; parameter
 */


void
CalcUnitDefinition_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "calculateUnits.xml");

  d = readSBML(filename);
  m = d->getModel();

  safe_free(filename);
}


void
CalcUnitDefinition_teardown (void)
{
  delete d;
}
CK_CPPSTART

START_TEST (test_CalcUnitDefinition_parameter)
{
  UnitDefinition *fud = NULL;
  
  fud = m->getParameter("k1")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("k1")->setCalculatingUnits(true);
  fud = m->getParameter("k1")->getDerivedUnitDefinition();
  m->getParameter("k1")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_parameter1)
{
  UnitDefinition *fud = m->getParameter("k2")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("k2")->setCalculatingUnits(true);
  fud = m->getParameter("k2")->getDerivedUnitDefinition();
  m->getParameter("k2")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_initialAssignment)
{
  UnitDefinition *fud = m->getParameter("c")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("c")->setCalculatingUnits(true);
  fud = m->getParameter("c")->getDerivedUnitDefinition();
  m->getParameter("c")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 2);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_initialAssignment1)
{
  UnitDefinition *fud = m->getParameter("d")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("d")->setCalculatingUnits(true);
  fud = m->getParameter("d")->getDerivedUnitDefinition();
  m->getParameter("d")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_initialAssignment_useRn)
{
  UnitDefinition *fud = m->getParameter("n")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("n")->setCalculatingUnits(true);
  fud = m->getParameter("n")->getDerivedUnitDefinition();
  m->getParameter("n")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 2);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 2);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  fail_unless(fud->getUnit(1)->getMultiplier() == 1);
  fail_unless(fud->getUnit(1)->getScale() == 0);
  fail_unless(fud->getUnit(1)->getExponent() == -2);
  fail_unless(fud->getUnit(1)->getOffset() == 0.0);
  fail_unless(fud->getUnit(1)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_initialAssignment_useSR)
{
  UnitDefinition *fud = m->getParameter("p")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("p")->setCalculatingUnits(true);
  fud = m->getParameter("p")->getDerivedUnitDefinition();
  m->getParameter("p")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_initialAssignment_useSR1)
{
  UnitDefinition *fud = m->getParameter("known6")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  m->getParameter("known6")->setCalculatingUnits(true);
  fud = m->getParameter("known6")->getDerivedUnitDefinition();
  m->getParameter("known6")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_assignmentRule)
{
  UnitDefinition *fud = m->getParameter("a")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("a")->setCalculatingUnits(true);
  fud = m->getParameter("a")->getDerivedUnitDefinition();
  m->getParameter("a")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_assignmentRule1)
{
  UnitDefinition *fud = m->getParameter("e")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("e")->setCalculatingUnits(true);
  fud = m->getParameter("e")->getDerivedUnitDefinition();
  m->getParameter("e")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 2);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  fail_unless(fud->getUnit(1)->getMultiplier() == 1);
  fail_unless(fud->getUnit(1)->getScale() == 0);
  fail_unless(fud->getUnit(1)->getExponent() == -1);
  fail_unless(fud->getUnit(1)->getOffset() == 0.0);
  fail_unless(fud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_eventAssignment)
{
  UnitDefinition *fud = m->getParameter("f")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("f")->setCalculatingUnits(true);
  fud = m->getParameter("f")->getDerivedUnitDefinition();
  m->getParameter("f")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_eventAssignment1)
{
  UnitDefinition *fud = m->getParameter("g")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("g")->setCalculatingUnits(true);
  fud = m->getParameter("g")->getDerivedUnitDefinition();
  m->getParameter("g")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_eventAssignment2)
{
  UnitDefinition *fud = m->getParameter("t")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("t")->setCalculatingUnits(true);
  fud = m->getParameter("t")->getDerivedUnitDefinition();
  m->getParameter("t")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_rateRule)
{
  UnitDefinition *fud = m->getParameter("h")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("h")->setCalculatingUnits(true);
  fud = m->getParameter("h")->getDerivedUnitDefinition();
  m->getParameter("h")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_rateRule1)
{
  UnitDefinition *fud = m->getParameter("k")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("k")->setCalculatingUnits(true);
  fud = m->getParameter("k")->getDerivedUnitDefinition();
  m->getParameter("k")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == -1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_delay)
{
  UnitDefinition *fud = m->getParameter("l")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("l")->setCalculatingUnits(true);
  fud = m->getParameter("l")->getDerivedUnitDefinition();
  m->getParameter("l")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_priority)
{
  UnitDefinition *fud = m->getParameter("m")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("m")->setCalculatingUnits(true);
  fud = m->getParameter("m")->getDerivedUnitDefinition();
  m->getParameter("m")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_global_with_local_known)
{
  UnitDefinition *fud = m->getParameter("q")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("q")->setCalculatingUnits(true);
  fud = m->getParameter("q")->getDerivedUnitDefinition();
  m->getParameter("q")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_global_with_local_unknown)
{
  UnitDefinition *fud = m->getParameter("r")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("r")->setCalculatingUnits(true);
  fud = m->getParameter("r")->getDerivedUnitDefinition();
  m->getParameter("r")->setCalculatingUnits(false);

  fail_unless(fud == NULL);
}
END_TEST


START_TEST (test_CalcUnitDefinition_local)
{
  UnitDefinition *fud = m->getReaction("R5")->getKineticLaw()
    ->getParameter("local")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getReaction("R5")->getKineticLaw()
    ->getParameter("local")->setCalculatingUnits(true);
  fud = m->getReaction("R5")->getKineticLaw()
    ->getParameter("local")->getDerivedUnitDefinition();
  m->getReaction("R5")->getKineticLaw()
    ->getParameter("local")->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_local1)
{
  UnitDefinition *fud = m->getReaction("R5")->getKineticLaw()
    ->getLocalParameter(0)->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getReaction("R5")->getKineticLaw()
    ->getLocalParameter(0)->setCalculatingUnits(true);
  fud = m->getReaction("R5")->getKineticLaw()
    ->getLocalParameter(0)->getDerivedUnitDefinition();
  m->getReaction("R5")->getKineticLaw()
    ->getLocalParameter(0)->setCalculatingUnits(false);

  fail_unless(fud->getNumUnits() == 1);
  fail_unless(!strcmp(fud->getId().c_str(), ""), NULL);

  fail_unless(fud->getUnit(0)->getMultiplier() == 1);
  fail_unless(fud->getUnit(0)->getScale() == 0);
  fail_unless(fud->getUnit(0)->getExponent() == 1);
  fail_unless(fud->getUnit(0)->getOffset() == 0.0);
  fail_unless(fud->getUnit(0)->getKind() == UNIT_KIND_SECOND);

  delete fud;
}
END_TEST


START_TEST (test_CalcUnitDefinition_unknownReaction)
{
  m->unsetExtentUnits();

  UnitDefinition *fud = m->getParameter("o")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("o")->setCalculatingUnits(true);
  fud = m->getParameter("o")->getDerivedUnitDefinition();
  m->getParameter("o")->setCalculatingUnits(false);

  fail_unless(fud == NULL);
}
END_TEST


START_TEST (test_CalcUnitDefinition_rateRule_timeUnknown)
{
  m->unsetTimeUnits();

  UnitDefinition *fud = m->getParameter("h")->getDerivedUnitDefinition();

  fail_unless(fud->getNumUnits() == 0);

  m->getParameter("h")->setCalculatingUnits(true);
  fud = m->getParameter("h")->getDerivedUnitDefinition();
  m->getParameter("h")->setCalculatingUnits(false);

  fail_unless(fud == NULL);
}
END_TEST


START_TEST (test_CalcUnitDefinition_noModel)
{
  Parameter * p = new Parameter(3, 1);
  p->setId("p");

  UnitDefinition *fud = p->getDerivedUnitDefinition();

  fail_unless(fud == NULL);

  p->setCalculatingUnits(true);
  fud = p->getDerivedUnitDefinition();
  p->setCalculatingUnits(false);

  fail_unless(fud == NULL);

  p->setUnits("second");

  fud = p->getDerivedUnitDefinition();

  fail_unless(fud == NULL);

  p->setCalculatingUnits(true);
  fud = p->getDerivedUnitDefinition();
  p->setCalculatingUnits(false);

  fail_unless(fud == NULL);

  delete p;
}
END_TEST


Suite *
create_suite_CalcUnitDefinition (void)
{
  Suite *suite = suite_create("CalcUnitDefinition");
  TCase *tcase = tcase_create("CalcUnitDefinition");

  tcase_add_checked_fixture(tcase,
                            CalcUnitDefinition_setup,
                            CalcUnitDefinition_teardown);

  tcase_add_test(tcase, test_CalcUnitDefinition_parameter );
  tcase_add_test(tcase, test_CalcUnitDefinition_parameter1 );

  tcase_add_test(tcase, test_CalcUnitDefinition_initialAssignment );
  tcase_add_test(tcase, test_CalcUnitDefinition_initialAssignment1 );
  tcase_add_test(tcase, test_CalcUnitDefinition_initialAssignment_useRn );
  tcase_add_test(tcase, test_CalcUnitDefinition_initialAssignment_useSR );
  tcase_add_test(tcase, test_CalcUnitDefinition_initialAssignment_useSR1 );

  tcase_add_test(tcase, test_CalcUnitDefinition_assignmentRule );
  tcase_add_test(tcase, test_CalcUnitDefinition_assignmentRule1 );

  tcase_add_test(tcase, test_CalcUnitDefinition_eventAssignment );
  tcase_add_test(tcase, test_CalcUnitDefinition_eventAssignment1 );
  tcase_add_test(tcase, test_CalcUnitDefinition_eventAssignment2 );

  tcase_add_test(tcase, test_CalcUnitDefinition_rateRule );
  tcase_add_test(tcase, test_CalcUnitDefinition_rateRule1 );

  tcase_add_test(tcase, test_CalcUnitDefinition_delay );

  tcase_add_test(tcase, test_CalcUnitDefinition_priority );

  tcase_add_test(tcase, test_CalcUnitDefinition_global_with_local_known );
  tcase_add_test(tcase, test_CalcUnitDefinition_global_with_local_unknown );

  tcase_add_test(tcase, test_CalcUnitDefinition_local );
  tcase_add_test(tcase, test_CalcUnitDefinition_local1 );

  tcase_add_test(tcase, test_CalcUnitDefinition_unknownReaction );

  tcase_add_test(tcase, test_CalcUnitDefinition_rateRule_timeUnknown );

  tcase_add_test(tcase, test_CalcUnitDefinition_noModel );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
