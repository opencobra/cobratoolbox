/**
 * @file    TestUnitsConverter2.cpp
 * @brief   Tests for unit converter
 * @author  Sarah Keating
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/conversion/SBMLUnitsConverter.h>
#include <sbml/conversion/ConversionProperties.h>



#include <string>
using namespace std;

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

#include <sbml/util/util.h>

extern char *TestDataDirectory;

START_TEST (test_convert_double_exponent)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setValue(3.0);
  p->setConstant(true);
  p->setUnits("my_ud");
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_ud");
  Unit * u = ud1->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_HENRY);
  u->setMultiplier(1.0);
  u->setExponent(0.5);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(1.0);
  u1->setExponent(0.5);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 3 ((H)^0.5) ((l)^0.5) = 0.09.. m^2.5 kg^0.5 s^-1 A^-1 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  double ans = 3 * (pow((0.001), 0.5));
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), ans) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(0)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), -1.0) );
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(1)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(1)->getExponentAsDouble(), 0.5) );
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(2)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(2)->getExponentAsDouble(), 2.5) );
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(3)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(3)->getExponentAsDouble(), -1.0) );

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_double_exponent1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setValue(3.0);
  p->setConstant(true);
  p->setUnits("my_ud");
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_ud");
  Unit * u = ud1->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_HENRY);
  u->setMultiplier(0.2);
  u->setExponent(1.5);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(1.0);
  u1->setExponent(0.5);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 3 ((0.2H)^1.5) ((l)^0.5) = 0.0848.. m^4.5 kg^1.5 s^-3 A^-3 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  double ans = 3 * (pow((0.001), 0.5)) * (pow(0.2, 1.5));
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), ans) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(0)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(0)->getExponentAsDouble(), -3.0) );
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(1)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(1)->getExponentAsDouble(), 1.5) );
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(2)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(2)->getExponentAsDouble(), 4.5) );
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(3)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(3)->getExponentAsDouble(), -3.0) );

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_volume)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("litre");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);

  fail_unless(m->getNumUnitDefinitions() == 0);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (d->getModel()->getVolumeUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_volume1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("litre");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(3.0);
  c1->setConstant(true);
  c1->setUnits("my_vol");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("my_vol");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "my_vol");

  fail_unless (d->getModel()->getVolumeUnits() == "my_vol");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "my_vol");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_volume2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("litre");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(3.0);
  c1->setConstant(true);
  c1->setUnits("litre");


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getVolumeUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_volume3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("litre");
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(3.0);
  c1->setConstant(true);
  c1->setUnits("litre");


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getVolumeUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_volume4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("my_vol");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(3.0);
  c1->setConstant(true);
  c1->setUnits("my_vol");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("my_vol");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  u->setMultiplier(0.1);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.001) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getVolumeUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_area)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setAreaUnits("area");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(2.0);
  c->setConstant(true);
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("area");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (d->getModel()->getAreaUnits() == "area");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "area");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_area1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setAreaUnits("area");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(2.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(2.0);
  c1->setConstant(true);
  c1->setUnits("my_area");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("area");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_area");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_METRE);
  u1->setExponent(2);
  u1->setMultiplier(0.1);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.01) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "area");
  fail_unless (d->getModel()->getAreaUnits() == "area");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "area");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_area2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setAreaUnits("my_area");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(2.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(2.0);
  c1->setConstant(true);
  c1->setUnits("area");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("area");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_area");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_METRE);
  u1->setExponent(2);
  u1->setMultiplier(0.1);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.01) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "area");
  fail_unless (d->getModel()->getAreaUnits() == "area");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "area");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_area3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setAreaUnits("area");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(2.0);
  c->setConstant(true);
  c->setUnits("my_area");
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(2.0);
  c1->setConstant(true);
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("area");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_area");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_METRE);
  u1->setExponent(2);
  u1->setMultiplier(0.1);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.01) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "area");
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1.0) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits().empty());
  fail_unless (d->getModel()->getAreaUnits() == "area");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "area");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_length)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setLengthUnits("metre");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(1.0);
  c->setConstant(true);

  fail_unless(m->getNumUnitDefinitions() == 0);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (d->getModel()->getLengthUnits() == "metre");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_length1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setLengthUnits("metre");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(1.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(2.0);
  c1->setConstant(true);
  c1->setUnits("my_length");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("my_length");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setMultiplier(10);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 10) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "metre");
  fail_unless (d->getModel()->getLengthUnits() == "metre");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_length2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setLengthUnits("my_length");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(1.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(2.0);
  c1->setConstant(true);
  c1->setUnits("my_length");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("my_length");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setMultiplier(10);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 10) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 10) );
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "metre");
  fail_unless (d->getModel()->getLengthUnits() == "metre");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setSubstanceUnits("gram");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits().empty());
  fail_unless (d->getModel()->getSubstanceUnits() == "kilogram");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  s->setSubstanceUnits("gram");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  fail_unless (d->getModel()->isSetSubstanceUnits() == false);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setSubstanceUnits("my_subs");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_subs");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);
  u1->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 0.000001) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits().empty());
  fail_unless (d->getModel()->getSubstanceUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_KILOGRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  s->setSubstanceUnits("my_subs");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_subs");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);
  u1->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 0.000001) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits()== "unitSid_0");
  fail_unless (d->getModel()->isSetSubstanceUnits() == false);

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_KILOGRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setSubstanceUnits("my_subs");
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_subs");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);
  u1->setExponent(3);
  UnitDefinition *ud2 = m->createUnitDefinition();
  ud2->setId("my_subs_1");
  Unit * u2 = ud2->createUnit();
  u2->initDefaults();
  u2->setKind(UNIT_KIND_KILOGRAM);
  u2->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 0.000001) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits().empty());
  fail_unless (d->getModel()->getSubstanceUnits() == "my_subs_1");

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "my_subs_1");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_KILOGRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance5)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setBoundaryCondition("false");
  s->setHasOnlySubstanceUnits("false");
  s->setConstant("false");
  s->setInitialAmount(1000);
  s->setSubstanceUnits("my_subs");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_subs");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);
  u1->setExponent(3);
  UnitDefinition *ud2 = m->createUnitDefinition();
  ud2->setId("my_subs_1");
  Unit * u2 = ud2->createUnit();
  u2->initDefaults();
  u2->setKind(UNIT_KIND_KILOGRAM);
  u2->setExponent(3);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 0.000001) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "my_subs_1");
  fail_unless (d->getModel()->isSetSubstanceUnits() == false);

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "my_subs_1");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_KILOGRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_global)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setVolumeUnits("litre");
  m->setSubstanceUnits("gram");


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  fail_unless (d->getModel()->getVolumeUnits() == "unitSid_0");
  fail_unless (d->getModel()->getSubstanceUnits() == "kilogram");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_global1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setAreaUnits("area");
  m->setSubstanceUnits("avogadro");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("area");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(2);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  fail_unless (d->getModel()->getAreaUnits() == "area");
  fail_unless (d->getModel()->getSubstanceUnits() == "dimensionless");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "area");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_global_time_extent)
{
  string filename(TestDataDirectory);
  filename += "units2.xml";

  SBMLUnitsConverter * units = new SBMLUnitsConverter();

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getTimeUnits() == "second");
  fail_unless(d->getModel()->getExtentUnits() == "kilogram");

  fail_unless (util_isEqual(d->getModel()->getParameter(0)->getValue(), 
                            pow(60.0, -1.0)));
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_SECOND);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == -1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);


  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertCompartment_noSize)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("litre");

  fail_unless(m->getNumUnitDefinitions() == 0);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (d->getModel()->getCompartment(0)->isSetSize() == false);
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noInitialValue)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("litre");
  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(true);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  Species *s1 = m->createSpecies();
  s1->setId("s1");
  s1->setCompartment("c");
  s1->setSubstanceUnits("gram");
  s1->setHasOnlySubstanceUnits(false);
  s1->setBoundaryCondition(true);
  s1->setConstant(false);

  Species *s2 = m->createSpecies();
  s2->setId("s2");
  s2->setCompartment("c");
  s2->setSubstanceUnits("gram");
  s2->setHasOnlySubstanceUnits(false);
  s2->setBoundaryCondition(true);
  s2->setConstant(false);
  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getSpecies(0)->isSetInitialAmount() == false);
  fail_unless (d->getModel()->getSpecies(0)->isSetInitialConcentration() == false);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  fail_unless (d->getModel()->getSpecies(1)->isSetInitialAmount() == false);
  fail_unless (d->getModel()->getSpecies(1)->isSetInitialConcentration() == false);
  fail_unless (d->getModel()->getSpecies(1)->getSubstanceUnits() == "kilogram");
  fail_unless (d->getModel()->getSpecies(2)->isSetInitialAmount() == false);
  fail_unless (d->getModel()->getSpecies(2)->isSetInitialConcentration() == false);
  fail_unless (d->getModel()->getSpecies(2)->getSubstanceUnits() == "kilogram");


  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);

  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setInitialAmount(2500);
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(true);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 2.5) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);

  Species *s1 = m->createSpecies();
  s1->setId("s1");
  s1->setCompartment("c");
  s1->setInitialAmount(2500);
  s1->setSubstanceUnits("gram");
  s1->setHasOnlySubstanceUnits(false);
  s1->setBoundaryCondition(true);
  s1->setConstant(false);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_CONV_INVALID_SRC_DOCUMENT);
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("metre_cubed");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);

  Species *s2 = m->createSpecies();
  s2->setId("s2");
  s2->setCompartment("c");
  s2->setInitialConcentration(2500);
  s2->setSubstanceUnits("gram");
  s2->setHasOnlySubstanceUnits(false);
  s2->setBoundaryCondition(true);
  s2->setConstant(false);
  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_CONV_INVALID_SRC_DOCUMENT);
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("litre");

  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setInitialAmount(2500);
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(true);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 2.5) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("litre");

  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setInitialAmount(2500);
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(false);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_CONV_INVALID_SRC_DOCUMENT);
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize5)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setUnits("litre");

  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setInitialConcentration(2500);
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(false);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_CONV_INVALID_SRC_DOCUMENT);
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameter_noValue)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setConstant(true);
  p->setUnits("coulomb");

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getParameter(0)->isSetValue() == false);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(0)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), 1.0) );
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(1)->getMultiplier(), 1.0) );
  fail_unless(util_isEqual(ud->getUnit(1)->getExponent(), 1.0) );

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertUnitDefinition_noUnits)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSpatialDimensions(3.0);
  c->setConstant(true);
  c->setSize(2);
  c->setUnits("myComp");

  Species *s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  s->setInitialAmount(2500);
  s->setSubstanceUnits("mySpecies");
  s->setHasOnlySubstanceUnits(true);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  Species *s1 = m->createSpecies();
  s1->setId("s1");
  s1->setCompartment("c");
  s1->setInitialAmount(2500);
  s1->setSubstanceUnits("mySpecies");
  s1->setHasOnlySubstanceUnits(false);
  s1->setBoundaryCondition(true);
  s1->setConstant(false);

  Species *s2 = m->createSpecies();
  s2->setId("s2");
  s2->setCompartment("c");
  s2->setInitialConcentration(2500);
  s2->setSubstanceUnits("mySpecies");
  s2->setHasOnlySubstanceUnits(false);
  s2->setBoundaryCondition(true);
  s2->setConstant(false);

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(2);
  p->setUnits("myParam");
  p->setConstant(true);
  
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("myComp");
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("mySpecies");
  UnitDefinition *ud2 = m->createUnitDefinition();
  ud2->setId("myParam");

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 2) );
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "myComp");
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 2500) );
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "mySpecies");
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(1)->getInitialAmount(), 2500) );
  fail_unless (d->getModel()->getSpecies(1)->getSubstanceUnits() == "mySpecies");
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(2)->getInitialConcentration(), 2500) );
  fail_unless (d->getModel()->getSpecies(2)->getSubstanceUnits() == "mySpecies");
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 2) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "myParam");


  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(2);
  p->setUnits("gram");
  p->setConstant(false);
  
  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("2*1.5");

  ast->getChild(0)->setUnits("gram");
  ast->getChild(1)->setUnits("dimensionless");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 0.002) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "kilogram");

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 0.002) );
  fail_unless( child1->getUnits() == "kilogram");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "dimensionless");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("avogadro");
  p->setConstant(false);
  
  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("avogadro");
  ast->getChild(1)->setUnits("dimensionless");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 1.806642537e24) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 1.806642537e24) );
  fail_unless( child1->getUnits() == "dimensionless");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "dimensionless");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("litre");
  p->setConstant(false);
  
  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("litre");
  ast->getChild(1)->setUnits("dimensionless");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 0.003) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 0.003) );
  fail_unless( child1->getUnits() == "unitSid_0");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "dimensionless");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("litre_second");
  p->setConstant(false);
  
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("litre_second");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_LITRE);
  Unit * u1 = ud->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_SECOND);

  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("litre");
  ast->getChild(1)->setUnits("second");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 0.003) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 2);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(1)->getKind() 
                                                       == UNIT_KIND_SECOND);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(1)->getExponent() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(1)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(1)->getScale() == 0);

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "unitSid_1");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_METRE);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 3);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 0.003) );
  fail_unless( child1->getUnits() == "unitSid_1");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "second");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("metre_second");
  p->setConstant(false);
  
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_second");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  Unit * u1 = ud->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_SECOND);

  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("metre_second");
  ast->getChild(1)->setUnits("dimensionless");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 3) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "metre_second");

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 3) );
  fail_unless( child1->getUnits() == "metre_second");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "dimensionless");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units5)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("mine");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_HERTZ);

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("dimensionless");
  p->setConstant(false);
  
  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("mine");
  ast->getChild(1)->setUnits("second");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 3) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "unitSid_0");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_SECOND);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == -1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 3) );
  fail_unless( child1->getUnits() == "unitSid_0");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "second");

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_cn_units6)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  m->setTimeUnits("second");

  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("mine");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_HERTZ);

  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("mine2");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_SECOND);
  u1->setExponent(-1);

  Parameter *p = m->createParameter();
  p->setId("p");
  p->setValue(3);
  p->setUnits("dimensionless");
  p->setConstant(false);
  
  AssignmentRule *ar = m->createAssignmentRule();
  ar->setVariable("p");

  ASTNode *ast = SBML_parseFormula("3*1.5");
  ast->getChild(0)->setUnits("mine");
  ast->getChild(1)->setUnits("second");

  ar->setMath(ast);
  delete ast;

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
 
  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 3) );
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "mine2");
  fail_unless (d->getModel()->getUnitDefinition(0)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_SECOND);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getExponent() == -1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(0)->getUnit(0)->getScale() == 0);

  const ASTNode *convertedAST = d->getModel()->getRule(0)->getMath();

  ASTNode * child1 = convertedAST->getChild(0);
  ASTNode * child2 = convertedAST->getChild(1);

  fail_unless( util_isEqual(child1->getReal(), 3) );
  fail_unless( child1->getUnits() == "mine2");
  fail_unless( util_isEqual(child2->getReal(), 1.5) );
  fail_unless( child2->getUnits() == "second");

  
  delete units;
  delete d;
}
END_TEST


Suite *
create_suite_TestUnitsConverter2 (void)
{ 
  Suite *suite = suite_create("UnitsConverter2");
  TCase *tcase = tcase_create("UnitsConverter2");


  tcase_add_test(tcase, test_convert_double_exponent);
  tcase_add_test(tcase, test_convert_double_exponent1);
  tcase_add_test(tcase, test_convert_model_volume);
  tcase_add_test(tcase, test_convert_model_volume1);
  tcase_add_test(tcase, test_convert_model_volume2);
  tcase_add_test(tcase, test_convert_model_volume3);
  tcase_add_test(tcase, test_convert_model_volume4);
  tcase_add_test(tcase, test_convert_model_area);
  tcase_add_test(tcase, test_convert_model_area1);
  tcase_add_test(tcase, test_convert_model_area2);
  tcase_add_test(tcase, test_convert_model_area3);
  tcase_add_test(tcase, test_convert_model_length);
  tcase_add_test(tcase, test_convert_model_length1);
  tcase_add_test(tcase, test_convert_model_length2);
  tcase_add_test(tcase, test_convert_model_substance);
  tcase_add_test(tcase, test_convert_model_substance1);
  tcase_add_test(tcase, test_convert_model_substance2);
  tcase_add_test(tcase, test_convert_model_substance3);
  tcase_add_test(tcase, test_convert_model_substance4);
  tcase_add_test(tcase, test_convert_model_substance5);
  tcase_add_test(tcase, test_convert_model_global);
  tcase_add_test(tcase, test_convert_model_global1);
  tcase_add_test(tcase, test_convert_global_time_extent);
  tcase_add_test(tcase, test_convertCompartment_noSize);
  tcase_add_test(tcase, test_convertSpecies_noInitialValue);
  tcase_add_test(tcase, test_convertSpecies_noCompSize);
  tcase_add_test(tcase, test_convertSpecies_noCompSize1);
  tcase_add_test(tcase, test_convertSpecies_noCompSize2);
  tcase_add_test(tcase, test_convertSpecies_noCompSize3);
  tcase_add_test(tcase, test_convertSpecies_noCompSize4);
  tcase_add_test(tcase, test_convertSpecies_noCompSize5);
  tcase_add_test(tcase, test_convertParameter_noValue);
  tcase_add_test(tcase, test_convertUnitDefinition_noUnits);
  tcase_add_test(tcase, test_convert_cn_units);
  tcase_add_test(tcase, test_convert_cn_units1);
  tcase_add_test(tcase, test_convert_cn_units2);
  tcase_add_test(tcase, test_convert_cn_units3);
  tcase_add_test(tcase, test_convert_cn_units4);
  tcase_add_test(tcase, test_convert_cn_units5);
  tcase_add_test(tcase, test_convert_cn_units6);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

