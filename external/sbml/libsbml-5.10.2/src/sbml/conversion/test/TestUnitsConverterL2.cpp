/**
 * @file    TestUnitsConverterL2.cpp
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

START_TEST (test_convert_model_volume)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "volume");
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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "my_vol");
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "my_vol");

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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "volume");

  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "volume");
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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
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


START_TEST (test_convert_model_volume4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "volume");


  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "volume");
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


START_TEST (test_convert_model_volume5)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
  c1->setUnits("volume");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("volume");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  u->setMultiplier(0.1);


  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.001) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "volume");


  fail_unless (d->getModel()->getUnitDefinition(0)->getId() == "volume");
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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());

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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 0.01) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "area");

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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "area");

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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 0.01) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits() == "area");
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 1.0) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits().empty());

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
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_length1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(1.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(1.0);
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 10) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "metre");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_length2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model * m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setSize(1.0);
  c->setSpatialDimensions(1.0);
  c->setConstant(true);
  Compartment *c1 = m->createCompartment();
  c1->setId("c1");
  c1->setSize(1.0);
  c1->setSpatialDimensions(1.0);
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
      util_isEqual(d->getModel()->getCompartment(0)->getSize(), 1) == 1);
  fail_unless (d->getModel()->getCompartment(0)->getUnits().empty());
  fail_unless (
      util_isEqual(d->getModel()->getCompartment(1)->getSize(), 10) == 1);
  fail_unless (d->getModel()->getCompartment(1)->getUnits() == "metre");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("substance");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "substance");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_GRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("substance");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "substance");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_GRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance3)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits()== "kilogram");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("metre_cubed");
  Unit * u = ud->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_METRE);
  u->setExponent(3);
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("substance");
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_GRAM);
  UnitDefinition *ud2 = m->createUnitDefinition();
  ud2->setId("my_subs_1");
  Unit * u2 = ud2->createUnit();
  u2->initDefaults();
  u2->setKind(UNIT_KIND_KILOGRAM);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 2);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");

  fail_unless (d->getModel()->getUnitDefinition(1)->getId() == "substance");
  fail_unless (d->getModel()->getUnitDefinition(1)->getNumUnits() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getKind() 
                                                       == UNIT_KIND_GRAM);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getExponent() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getMultiplier() == 1);
  fail_unless (d->getModel()->getUnitDefinition(1)->getUnit(0)->getScale() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_model_substance5)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  UnitDefinition *ud2 = m->createUnitDefinition();
  ud2->setId("my_subs_1");
  Unit * u2 = ud2->createUnit();
  u2->initDefaults();
  u2->setKind(UNIT_KIND_KILOGRAM);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 1) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertCompartment_noSize)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 2.5) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
      util_isEqual(d->getModel()->getSpecies(0)->getInitialAmount(), 2.5) == 1);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertSpecies_noCompSize4)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  SBMLDocument *d = new SBMLDocument(2, 4);
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
  fail_unless(util_isEqual(ud->getUnit(0)->getMultiplier(), 1.0) == 1);
  fail_unless(util_isEqual(ud->getUnit(0)->getExponent(), 1.0) == 1);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(util_isEqual(ud->getUnit(1)->getMultiplier(), 1.0) == 1);
  fail_unless(util_isEqual(ud->getUnit(1)->getExponent(), 1.0) == 1);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_time)
{
  string filename(TestDataDirectory);
  filename += "units3.xml";

  SBMLUnitsConverter * units = new SBMLUnitsConverter();

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless (
      util_isEqual(d->getModel()->getParameter(0)->getValue(), 60) == 1);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "second");



  delete units;
  delete d;
}
END_TEST


Suite *
create_suite_TestUnitsConverterL2 (void)
{ 
  Suite *suite = suite_create("UnitsConverterL2");
  TCase *tcase = tcase_create("UnitsConverterL2");


  tcase_add_test(tcase, test_convert_model_volume);
  tcase_add_test(tcase, test_convert_model_volume1);
  tcase_add_test(tcase, test_convert_model_volume2);
  tcase_add_test(tcase, test_convert_model_volume3);
  tcase_add_test(tcase, test_convert_model_volume4);
  tcase_add_test(tcase, test_convert_model_volume5);
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
  tcase_add_test(tcase, test_convertCompartment_noSize);
  tcase_add_test(tcase, test_convertSpecies_noInitialValue);
  tcase_add_test(tcase, test_convertSpecies_noCompSize);
  tcase_add_test(tcase, test_convertSpecies_noCompSize1);
  tcase_add_test(tcase, test_convertSpecies_noCompSize2);
  tcase_add_test(tcase, test_convertSpecies_noCompSize3);
  tcase_add_test(tcase, test_convertSpecies_noCompSize4);
  tcase_add_test(tcase, test_convertSpecies_noCompSize5);
  tcase_add_test(tcase, test_convertParameter_noValue);
  tcase_add_test(tcase, test_convert_time);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

