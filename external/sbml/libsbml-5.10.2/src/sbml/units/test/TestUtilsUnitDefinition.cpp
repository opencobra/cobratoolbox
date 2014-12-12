/**
 * \file    TestUtilsUnitDefinition.c
 * \brief   Utilities on unitdefinitions unit tests (no pun intended)
 * \author  Sarah Keating and Ralph Gauges
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

#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/math/ASTNode.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST(test_unitdefinition_simplify)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_DIMENSIONLESS);
  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_METRE);
  u2->setExponent(2);
  Unit* u3 = new Unit(2, 4);
  u3->setKind(UNIT_KIND_METRE);
  u3->setExponent(-3);

  /* case with only one unit */
  ud->addUnit(u);

  UnitDefinition::simplify(ud);

  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* case with one unit plus a dimensionless unit */
  ud->addUnit(u1);

  UnitDefinition::simplify(ud);
  
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* case with two units of same kind */
  ud->addUnit(u2);

  UnitDefinition::simplify(ud);
  
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getExponent() == 3);

  /* case with two units of same kind that cancel*/
  ud->addUnit(u3);

  UnitDefinition::simplify(ud);
  
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);

  /* NULL case*/
  ud = NULL;

  UnitDefinition::simplify(ud);
  
  fail_unless(ud == NULL);

  delete u;
  delete u1;
  delete u2;
  delete u3;
  delete ud;
 }
END_TEST


START_TEST (test_unitdefinition_simplify1)
{
  UnitDefinition *ud = new UnitDefinition(2, 1);
  
  Unit * u = ud->createUnit();
  u->setKind(UNIT_KIND_MOLE);

  Unit * u1 = ud->createUnit();
  u1->setKind(UNIT_KIND_MOLE);
  u1->setExponent(-1);

  UnitDefinition::simplify(ud);

  fail_unless( ud->getNumUnits() == 1);
  fail_unless( ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS );

  delete ud;
}
END_TEST


START_TEST(test_unitdefinition_order)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_AMPERE);
  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_HERTZ);

  ud->addUnit(u);
  ud->addUnit(u1);
  ud->addUnit(u2);

  UnitDefinition::reorder(ud);

  fail_unless(ud->getNumUnits() == 3);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_HERTZ);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

  /* NULL case*/
  ud = NULL;

  UnitDefinition::reorder(ud);
  
  fail_unless(ud == NULL);

  delete u;
  delete u1;
  delete u2;
  delete ud;
}
END_TEST

START_TEST(test_unitdefinition_convert_SI)
{
  UnitDefinition* ud  = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_JOULE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_NEWTON);

  u1->setExponent(-1);

  ud->addUnit(u);
  ud->addUnit(u1);

  ud1 = UnitDefinition::convertToSI(ud);

  fail_unless(ud1->getNumUnits() == 1);
  fail_unless(ud1->getUnit(0)->getKind() == UNIT_KIND_METRE);

  /* NULL case*/
  ud = NULL;

  ud1 = UnitDefinition::convertToSI(ud);
  
  fail_unless(ud1 == NULL);

  delete u;
  delete u1;
  delete ud;
  delete ud1;
}
END_TEST


START_TEST (test_unitdefinition_convert_SI1)
{
  UnitDefinition *ud = new UnitDefinition(2, 1);
  UnitDefinition *ud1;
  
  Unit * u = ud->createUnit();
  u->setKind(UNIT_KIND_HERTZ);

  ud1 = UnitDefinition::convertToSI(ud);

  fail_unless( ud1->getNumUnits() == 1);
  fail_unless( ud1->getUnit(0)->getKind() == UNIT_KIND_SECOND );
  fail_unless( ud1->getUnit(0)->getExponent() == -1);
  fail_unless( ud1->getLevel() == 2);
  fail_unless( ud1->getVersion() == 1);


  UnitDefinition_free(ud);
}
END_TEST


START_TEST (test_unitdefinition_convert_SI2)
{
  UnitDefinition *ud = new UnitDefinition(1, 1);
  UnitDefinition *ud1;
  
  Unit * u = ud->createUnit();
  u->setKind(UNIT_KIND_FARAD);

  ud1 = UnitDefinition::convertToSI(ud);

  fail_unless( ud1->getNumUnits() == 4);
  fail_unless( ud1->getLevel() == 1);
  fail_unless( ud1->getVersion() == 1);
  fail_unless( ud1->getUnit(0)->getKind() == UNIT_KIND_AMPERE );
  fail_unless( ud1->getUnit(0)->getExponent() == 2);
  fail_unless( ud1->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM );
  fail_unless( ud1->getUnit(1)->getExponent() == -1);
  fail_unless( ud1->getUnit(2)->getKind() == UNIT_KIND_METRE );
  fail_unless( ud1->getUnit(2)->getExponent() == -2);
  fail_unless( ud1->getUnit(3)->getKind() == UNIT_KIND_SECOND );
  fail_unless( ud1->getUnit(3)->getExponent() == 4);


  UnitDefinition_free(ud);
}
END_TEST


START_TEST(test_unitdefinition_areIdentical)
{
  UnitDefinition* ud  = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_JOULE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_NEWTON);
  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_METRE);
  
  ud->addUnit(u);
  ud->addUnit(u1);

  ud1->addUnit(u);
  ud1->addUnit(u1);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 1);

  ud->addUnit(u2);

  identical = UnitDefinition::areIdentical(ud, ud1);
 
  fail_unless(identical == 0);

  /* NULL case*/
  ud = NULL;

  identical = UnitDefinition::areIdentical(ud, ud1);;
  
  fail_unless(identical == 0);
 
  identical = UnitDefinition::areIdentical(ud1, ud);;
  
  fail_unless(identical == 0);
  
  ud1 = NULL;

  identical = UnitDefinition::areIdentical(ud, ud1);;
  
  fail_unless(identical == 1);

  delete u;
  delete u1;
  delete u2;
  delete ud;
  delete ud1;

}
END_TEST

START_TEST(test_unitdefinition_areIdentical1)
{
  UnitDefinition* ud  = new UnitDefinition(2, 1);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = new Unit(2, 1);
  u->setKind(UNIT_KIND_JOULE);
  Unit* u1 = new Unit(2, 1);
  u1->setKind(UNIT_KIND_NEWTON);
  Unit* u2 = new Unit(2, 2);
  u2->setKind(UNIT_KIND_METRE);
  
  ud->addUnit(u);
  ud->addUnit(u1);

  ud1->addUnit(u2);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 0);

  delete u;
  delete u1;
  delete u2;
  delete ud;
  delete ud1;

}
END_TEST

START_TEST(test_unitdefinition_areIdentical2)
{
  UnitDefinition* ud  = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = new Unit(2, 2);
  u->setKind(UNIT_KIND_JOULE);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_NEWTON);
  
  ud->addUnit(u);
  ud->addUnit(u1);

  ud1->addUnit(u);
  ud1->addUnit(u1);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 1);

  delete u;
  delete u1;
  delete ud;
  delete ud1;

}
END_TEST


START_TEST(test_unitdefinition_mismatch_multipliers)
{
  UnitDefinition* ud  = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = new Unit(2, 2);
  u->setKind(UNIT_KIND_JOULE);
  u->setMultiplier(2.0);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_NEWTON);
  
  ud->addUnit(u);
  ud->addUnit(u1);

  u->setMultiplier(1.0);
  u1->setMultiplier(2.0);

  ud1->addUnit(u);
  ud1->addUnit(u1);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 1);

  int equivalent = UnitDefinition::areEquivalent(ud, ud1);
  fail_unless(equivalent == 1);

  identical = UnitDefinition::areIdenticalSIUnits(ud, ud1);

  fail_unless(identical == 1);

  delete u;
  delete u1;
  delete ud;
  delete ud1;

}
END_TEST


START_TEST(test_unitdefinition_mismatch_multipliers1)
{
  UnitDefinition* ud  = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = new Unit(2, 2);
  u->setKind(UNIT_KIND_METRE);
  u->setMultiplier(2.0);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_DIMENSIONLESS);
  
  ud->addUnit(u);
  ud->addUnit(u1);

  u->setMultiplier(1.0);
  u1->setMultiplier(2.0);

  ud1->addUnit(u);
  ud1->addUnit(u1);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 1);

  int equivalent = UnitDefinition::areEquivalent(ud, ud1);
  fail_unless(equivalent == 1);

  identical = UnitDefinition::areIdenticalSIUnits(ud, ud1);

  fail_unless(identical == 1);

  delete u;
  delete u1;
  delete ud;
  delete ud1;

}
END_TEST


START_TEST(test_unitdefinition_mismatch_multipliers2)
{
  UnitDefinition* ud  = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = ud->createUnit();
  u->setKind(UNIT_KIND_METRE);
  u->setMultiplier(2.0);
  u  = ud->createUnit();
  u->setKind(UNIT_KIND_SECOND);
  u->setMultiplier(3.0);


  Unit* u1 =  ud1->createUnit();
  u1->setKind(UNIT_KIND_METRE);
  u1->setMultiplier(3.0);
  u1  = ud1->createUnit();
  u1->setKind(UNIT_KIND_SECOND);
  u1->setMultiplier(2.0);

  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 1);

  int equivalent = UnitDefinition::areEquivalent(ud, ud1);
  fail_unless(equivalent == 1);

  identical = UnitDefinition::areIdenticalSIUnits(ud, ud1);

  fail_unless(identical == 1);

  delete ud;
  delete ud1;

}
END_TEST


START_TEST(test_unitdefinition_mismatch_dimensionless)
{
  UnitDefinition* ud  = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);

  Unit* u  = new Unit(2, 2);
  u->setKind(UNIT_KIND_DIMENSIONLESS);
  u->setExponent(2);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_DIMENSIONLESS);
  
  ud->addUnit(u);

  ud1->addUnit(u1);

  // these are not identical 
  int identical = UnitDefinition::areIdentical(ud, ud1);

  fail_unless(identical == 0);

  int equivalent = UnitDefinition::areEquivalent(ud, ud1);
  fail_unless(equivalent == 1);

  // but they match sufficiently for unit manipluation
  identical = UnitDefinition::areIdenticalSIUnits(ud, ud1);

  fail_unless(identical == 1);

  delete u;
  delete u1;
  delete ud;
  delete ud1;

}
END_TEST


START_TEST(test_unitdefinition_areEquivalent)
{
  UnitDefinition* ud  = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_JOULE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_NEWTON);
  Unit* u2 = new Unit(2, 4);
  u->setKind(UNIT_KIND_METRE);

  u1->setExponent(-1);

  ud->addUnit(u);
  ud->addUnit(u1);

  ud1->addUnit(u2);

  int equivalent = UnitDefinition::areEquivalent(ud, ud1);

  //fail_unless(equivalent == 1);

  ud->addUnit(u2);

  equivalent = UnitDefinition::areEquivalent(ud, ud1);
 
  fail_unless(equivalent == 0);

  /* NULL case*/
  ud = NULL;

  equivalent = UnitDefinition::areEquivalent(ud, ud1);
  
  fail_unless(equivalent == 0);
 
  equivalent = UnitDefinition::areEquivalent(ud1, ud);
  
  fail_unless(equivalent == 0);
 
  ud1 = NULL;

  equivalent = UnitDefinition::areEquivalent(ud, ud1);
  
  fail_unless(equivalent == 1);

  delete u;
  delete u1;
  delete u2;
  delete ud;
  delete ud1;
}
END_TEST

START_TEST(test_unitdefinition_combine)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_MOLE);
  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_SECOND);
  u2->setExponent(2);

  ud->addUnit(u);
  ud1->addUnit(u1);
  
  udTemp = UnitDefinition::combine(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);

  /* case with two units of same kind */
  ud1->addUnit(u2);

  udTemp = UnitDefinition::combine(udTemp, ud1);

  fail_unless(udTemp->getNumUnits() == 3);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getExponent() == 2);
  fail_unless(udTemp->getUnit(2)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(2)->getExponent() == 2);

  /* NULL case*/
  ud = NULL;
  
  udTemp = UnitDefinition::combine(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(1)->getExponent() == 2);

  udTemp = UnitDefinition::combine(ud1, ud);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(1)->getExponent() == 2);

  ud1 = NULL;

  udTemp = UnitDefinition::combine(ud1, ud);

  fail_unless(udTemp == NULL);

  delete u;
  delete ud1;
  delete u1;
  delete u2;
  delete ud;
 }
END_TEST


START_TEST(test_unitdefinition_combine1)
{
  UnitDefinition* ud = new UnitDefinition(2, 1);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 1);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_MOLE);
 
  ud->addUnit(u);
  ud1->addUnit(u1);
  
  udTemp = UnitDefinition::combine(ud, ud1);

  fail_unless(udTemp == 0);

  delete u;
  delete ud1;
  delete u1;
  delete ud;
 }
END_TEST



START_TEST(test_unitdefinition_combine2)
{
  UnitDefinition* ud = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);
  UnitDefinition* udTemp;

  Unit* u  = ud->createUnit();
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = ud1->createUnit();
  u1->setKind(UNIT_KIND_MOLE);
  
  udTemp = UnitDefinition::combine(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getLevel() == 2);
  fail_unless(udTemp->getVersion() == 2);

  delete ud1;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 4);
  u1->setKind(UNIT_KIND_MOLE);
  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_SECOND);
  u2->setExponent(2);

  ud->addUnit(u);
  ud1->addUnit(u1);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getExponent() == -1);

  /* case with two units of same kind */
  ud1->addUnit(u2);

  udTemp = UnitDefinition::divide(udTemp, ud1);

  fail_unless(udTemp->getNumUnits() == 3);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getExponent() == -2);
  fail_unless(udTemp->getUnit(2)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(2)->getExponent() == -2);

  /* NULL case*/
  ud = NULL;
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(0)->getExponent() == -1);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(1)->getExponent() == -2);

  udTemp = UnitDefinition::divide(ud1, ud);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(1)->getExponent() == 2);

  ud1 = NULL;

  udTemp = UnitDefinition::divide(ud1, ud);

  fail_unless(udTemp == NULL);

  delete u;
  delete ud1;
  delete u1;
  delete u2;
  delete ud;
 }
END_TEST


START_TEST(test_unitdefinition_divide1)
{
  UnitDefinition* ud = new UnitDefinition(2, 1);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 1);
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = new Unit(2, 2);
  u1->setKind(UNIT_KIND_MOLE);
 
  ud->addUnit(u);
  ud1->addUnit(u1);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp == 0);

  delete u;
  delete ud1;
  delete u1;
  delete ud;
 }
END_TEST



START_TEST(test_unitdefinition_divide2)
{
  UnitDefinition* ud = new UnitDefinition(2, 2);
  UnitDefinition* ud1 = new UnitDefinition(2, 2);
  UnitDefinition* udTemp;

  Unit* u  = ud->createUnit();
  u->setKind(UNIT_KIND_METRE);
  Unit* u1 = ud1->createUnit();
  u1->setKind(UNIT_KIND_MOLE);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getExponent() == -1);
  fail_unless(udTemp->getLevel() == 2);
  fail_unless(udTemp->getVersion() == 2);

  delete ud1;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide3)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_LITRE);
  u->setExponent(-2);
  u->setMultiplier(0.001);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_LITRE);
  u2->setExponent(-2);

  ud->addUnit(u);
  ud1->addUnit(u2);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(udTemp->getUnit(0)->getMultiplier() == 1000000);


  delete u;
  delete ud1;
  delete u2;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide4)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  u->setExponent(5);
  u->setMultiplier(0.0630957);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_MOLE);
  u2->setExponent(4);

  ud->addUnit(u);
  ud1->addUnit(u2);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(util_isEqual(udTemp->getUnit(0)->getMultiplier(), 9.99997e-7));


  delete u;
  delete ud1;
  delete u2;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide5)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  u->setExponent(5);
  u->setMultiplier(0.0630957);
  Unit* u1  = new Unit(2, 4);
  u1->setKind(UNIT_KIND_LITRE);
  u1->setExponent(-2);
  u1->setMultiplier(0.001);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_MOLE);
  u2->setExponent(4);
  Unit* u3 = new Unit(2, 4);
  u3->setKind(UNIT_KIND_LITRE);
  u3->setExponent(-2);

  ud->addUnit(u);
  ud->addUnit(u1);
  ud1->addUnit(u2);
  ud1->addUnit(u3);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(util_isEqual(udTemp->getUnit(0)->getMultiplier(), 0.99999727018141493));


  delete u;
  delete u1;
  delete ud1;
  delete u2;
  delete u3;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide6)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_LITRE);
  u->setExponent(-2);
  u->setMultiplier(0.001);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_LITRE);
  u2->setExponent(-2);
  u2->setMultiplier(0.001);

  ud->addUnit(u);
  ud1->addUnit(u2);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(udTemp->getUnit(0)->getMultiplier() == 1);


  delete u;
  delete ud1;
  delete u2;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide7)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  u->setMultiplier(2);
  Unit* u1  = new Unit(2, 4);
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(3);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_MOLE);
  Unit* u3 = new Unit(2, 4);
  u3->setKind(UNIT_KIND_LITRE);

  ud->addUnit(u);
  ud->addUnit(u1);
  ud1->addUnit(u2);
  ud1->addUnit(u3);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(util_isEqual(udTemp->getUnit(0)->getMultiplier(), 6));


  delete u;
  delete u1;
  delete ud1;
  delete u2;
  delete u3;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide8)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;

  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  u->setMultiplier(2);
  u->setExponent(3);
  Unit* u1  = new Unit(2, 4);
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(3);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_MOLE);
  Unit* u3 = new Unit(2, 4);
  u3->setKind(UNIT_KIND_LITRE);

  ud->addUnit(u);
  ud->addUnit(u1);
  ud1->addUnit(u2);
  ud1->addUnit(u3);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 1);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(0)->getExponent() == 2);
  fail_unless(util_isEqual(udTemp->getUnit(0)->getMultiplier(), 2*pow(6, 0.5)));


  delete u;
  delete u1;
  delete ud1;
  delete u2;
  delete u3;
  delete ud;
  delete udTemp;
 }
END_TEST


START_TEST(test_unitdefinition_divide9)
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  UnitDefinition* ud1 = new UnitDefinition(2, 4);
  UnitDefinition* udTemp;//, * udTemp2;

  Unit* u4  = new Unit(2, 4);
  u4->setKind(UNIT_KIND_SECOND);
  u4->setExponent(2);
  Unit* u  = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  u->setMultiplier(2);
  u->setExponent(3);
  Unit* u1  = new Unit(2, 4);
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(3);

  Unit* u2 = new Unit(2, 4);
  u2->setKind(UNIT_KIND_MOLE);
  Unit* u3 = new Unit(2, 4);
  u3->setKind(UNIT_KIND_LITRE);
  Unit* u5 = new Unit(2, 4);
  u5->setKind(UNIT_KIND_SECOND);

  ud->addUnit(u4);
  ud->addUnit(u);
  ud->addUnit(u1);
  ud1->addUnit(u5);
  ud1->addUnit(u2);
  ud1->addUnit(u3);
  
  udTemp = UnitDefinition::divide(ud, ud1);

  fail_unless(udTemp->getNumUnits() == 2);
  fail_unless(udTemp->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(udTemp->getUnit(0)->getExponent() == 1);
  fail_unless(util_isEqual(udTemp->getUnit(0)->getMultiplier(), 3.0));
  fail_unless(udTemp->getUnit(1)->getKind() == UNIT_KIND_MOLE);
  fail_unless(udTemp->getUnit(1)->getExponent() == 2);
  fail_unless(util_isEqual(udTemp->getUnit(1)->getMultiplier(), sqrt(8.0)));


  delete u;
  delete u1;
  delete u2;
  delete u3;
  delete u4;
  delete u5;
  delete ud;
  delete ud1;
  delete udTemp;
 }
END_TEST


Suite *
create_suite_UtilsUnitDefinition (void) 
{ 
  Suite *suite = suite_create("UtilsUnitDefinition");
  TCase *tcase = tcase_create("UtilsUnitDefinition");
 

  tcase_add_test( tcase, test_unitdefinition_simplify      );
  tcase_add_test( tcase, test_unitdefinition_simplify1     );
  tcase_add_test( tcase, test_unitdefinition_order         );
  tcase_add_test( tcase, test_unitdefinition_convert_SI    );
  tcase_add_test( tcase, test_unitdefinition_convert_SI1   );
  tcase_add_test( tcase, test_unitdefinition_convert_SI2   );
  tcase_add_test( tcase, test_unitdefinition_areIdentical  );
  tcase_add_test( tcase, test_unitdefinition_areIdentical1 );
  tcase_add_test( tcase, test_unitdefinition_areIdentical2 );
  tcase_add_test( tcase, test_unitdefinition_mismatch_multipliers );
  tcase_add_test( tcase, test_unitdefinition_mismatch_multipliers1 );
  tcase_add_test( tcase, test_unitdefinition_mismatch_multipliers2 );
  tcase_add_test( tcase, test_unitdefinition_mismatch_dimensionless );
  tcase_add_test( tcase, test_unitdefinition_areEquivalent );
  tcase_add_test( tcase, test_unitdefinition_combine );
  tcase_add_test( tcase, test_unitdefinition_combine1 );
  tcase_add_test( tcase, test_unitdefinition_combine2 );
  tcase_add_test( tcase, test_unitdefinition_divide );
  tcase_add_test( tcase, test_unitdefinition_divide1 );
  tcase_add_test( tcase, test_unitdefinition_divide2 );
  tcase_add_test( tcase, test_unitdefinition_divide3 );
  tcase_add_test( tcase, test_unitdefinition_divide4 );
  tcase_add_test( tcase, test_unitdefinition_divide5 );
  tcase_add_test( tcase, test_unitdefinition_divide6 );
  tcase_add_test( tcase, test_unitdefinition_divide7 );
  tcase_add_test( tcase, test_unitdefinition_divide8 );
  tcase_add_test( tcase, test_unitdefinition_divide9 );

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

