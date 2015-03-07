/**
 * @file    TestUnitsConverter.cpp
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

static bool
equalDouble (double a, double b)
{
  bool result = fabs(a-b) < 1e-6;// sqrt(util_epsilon());
  if (!result)
    cerr << "not equal: " << a << " vs " << b 
         << " difference: " << fabs(a-b)
         << endl;
  return result;
}



START_TEST (test_setup)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();

  fail_unless (units->getDefaultProperties().hasOption("units") == true);
  
  delete units;
}
END_TEST


START_TEST (test_setDocument)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  d->createModel();
  units->setDocument(d);

  fail_unless (units->getDocument() == d);
  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertCompartment)
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

  fail_unless(m->getNumUnitDefinitions() == 0);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  fail_unless (
      equalDouble(d->getModel()->getCompartment(0)->getSize(), 0.001) == true);
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


START_TEST (test_convertSpecies)
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
  s->setInitialAmount(2500);
  s->setSubstanceUnits("gram");
  s->setHasOnlySubstanceUnits(true);
  s->setBoundaryCondition(true);
  s->setConstant(false);

  Species *s1 = m->createSpecies();
  s1->setId("s1");
  s1->setCompartment("c");
  s1->setInitialAmount(2500);
  s1->setSubstanceUnits("gram");
  s1->setHasOnlySubstanceUnits(false);
  s1->setBoundaryCondition(true);
  s1->setConstant(false);

  Species *s2 = m->createSpecies();
  s2->setId("s2");
  s2->setCompartment("c");
  s2->setInitialConcentration(2500);
  s2->setSubstanceUnits("gram");
  s2->setHasOnlySubstanceUnits(false);
  s2->setBoundaryCondition(true);
  s2->setConstant(false);
  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getSpecies(0)->getInitialAmount(), 2.5) == true);
  fail_unless (d->getModel()->getSpecies(0)->getSubstanceUnits() == "kilogram");
  fail_unless (
      equalDouble(d->getModel()->getSpecies(1)->getInitialAmount(), 2.5) == true);
  fail_unless (d->getModel()->getSpecies(1)->getSubstanceUnits() == "kilogram");
  fail_unless (
      equalDouble(d->getModel()->getSpecies(2)->getInitialConcentration(), 2500) == true);
  fail_unless (d->getModel()->getSpecies(2)->getSubstanceUnits() == "kilogram");


  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setValue(1.0);
  p->setConstant(true);
  p->setUnits("coulomb");

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 1.0) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters_1)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setValue(10.0);
  p->setConstant(true);
  p->setUnits("my_ud");
  UnitDefinition *ud1 = m->createUnitDefinition();
  ud1->setId("my_ud");
  Unit * u = ud1->createUnit();
  u->initDefaults();
  u->setKind(UNIT_KIND_KILOGRAM);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_NEWTON);
  Unit * u2 = ud1->createUnit();
  u2->initDefaults();
  u2->setKind(UNIT_KIND_JOULE);
  u2->setExponent(-1);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 10.0) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -1.0) == true);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters_2)
{
  SBMLUnitsConverter * units = new SBMLUnitsConverter();
  SBMLDocument *d = new SBMLDocument(3, 1);
  Model * m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("c");
  p->setValue(2.0);
  p->setConstant(true);
  p->setUnits("hertz");

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 2.0) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -1.0) == true);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters_3)
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
  u->setKind(UNIT_KIND_HERTZ);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 3.0) == true);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters_4)
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
  u->setKind(UNIT_KIND_LITRE);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_HERTZ);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -1.0) == true);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 3.0) == true);

  
  delete units;
  delete d;
}
END_TEST


START_TEST (test_convertParameters_fromFile)
{
  string filename(TestDataDirectory);
  filename += "units1.xml";

  SBMLUnitsConverter * units = new SBMLUnitsConverter();

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.008) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "kilogram");
  fail_unless (
      equalDouble(d->getModel()->getParameter(1)->getValue(), 2) == true);
  fail_unless (d->getModel()->getParameter(1)->getUnits() == "unitSid_0");
  fail_unless (
      equalDouble(d->getModel()->getParameter(2)->getValue(), 2) == true);
  fail_unless (d->getModel()->getParameter(2)->getUnits() == "unitSid_0");
  fail_unless (
      equalDouble(d->getModel()->getParameter(3)->getValue(), 1.204428358e24) == true);
  fail_unless (d->getModel()->getParameter(3)->getUnits() == "dimensionless");
  fail_unless (
      equalDouble(d->getModel()->getParameter(4)->getValue(), 2) == true);
  fail_unless (d->getModel()->getParameter(4)->getUnits() == "ml1");
  fail_unless (
      equalDouble(d->getModel()->getParameter(5)->getValue(), 2.901295339109152326e48) == true);
  fail_unless (d->getModel()->getParameter(5)->getUnits() == "dimensionless");
  fail_unless (
      equalDouble(d->getModel()->getParameter(6)->getValue(), 0.002) == true);
  fail_unless (d->getModel()->getParameter(6)->getUnits() == "unitSid_1");
  fail_unless (
      equalDouble(d->getModel()->getParameter(7)->getValue(), 4.0) == true);
  fail_unless (d->getModel()->getParameter(7)->getUnits() == "kilogram");


  fail_unless (d->getModel()->getNumUnitDefinitions() == 3);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "ml1");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  ud = d->getModel()->getUnitDefinition(1);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -3.0) == true);

  ud = d->getModel()->getUnitDefinition(2);
  fail_unless(ud->getId() == "unitSid_1");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 3.0) == true);
  
  delete units;
  delete d;
}
END_TEST

START_TEST (test_convert_ampere_1)
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
  u->setKind(UNIT_KIND_AMPERE);

  units->setDocument(d);

  /* 3 Amps = 3 Amps */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "ampere");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_ampere_2)
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
  u->setKind(UNIT_KIND_AMPERE);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Amps) = 6 Amps */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "ampere");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_ampere_3)
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
  u->setKind(UNIT_KIND_AMPERE);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((Amps)^2) = 3 ((Amps)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "my_ud");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "my_ud");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_ampere_4)
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
  u->setKind(UNIT_KIND_AMPERE);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3Amps)^2) = 27 ((Amps)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_avogadro_1)
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
  u->setKind(UNIT_KIND_AVOGADRO);

  units->setDocument(d);

  /* 3 avogadro = 1.806642537e24 dimensionless */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 1.806642537e24) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_avogadro_2)
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
  u->setKind(UNIT_KIND_AVOGADRO);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Avogadro) = 3.613285074e24 dimensionless */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3.613285074e24) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_avogadro_3)
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
  u->setKind(UNIT_KIND_AVOGADRO);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((avogadro)^2) = 1.087985752165932123e48 (dimensionless) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 1.087985752165932123e48) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_avogadro_4)
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
  u->setKind(UNIT_KIND_AVOGADRO);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3avogadro)^2) = 9.791871769493389107e48 (dimensionless) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  double ans = pow((6.02214179e23 * 3), 2)*3;
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), ans) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "dimensionless");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_hertz_1)
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
  u->setKind(UNIT_KIND_HERTZ);

  units->setDocument(d);

  /* 3 Hz = 3 ((sec)^-1) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -1.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_hertz_2)
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
  u->setKind(UNIT_KIND_HERTZ);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Hz) = 6 ((sec)^-1) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -1.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_hertz_3)
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
  u->setKind(UNIT_KIND_HERTZ);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((Hz)^2) = 3 ((sec)^-2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_hertz_4)
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
  u->setKind(UNIT_KIND_HERTZ);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3Hz)^2) = 27 ((sec)^-2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_candela_1)
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
  u->setKind(UNIT_KIND_CANDELA);

  units->setDocument(d);

  /* 3 Candela = 3 Candela */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "candela");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_candela_2)
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
  u->setKind(UNIT_KIND_CANDELA);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Candela) = 6 Candela */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "candela");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_candela_3)
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
  u->setKind(UNIT_KIND_CANDELA);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((Candela)^2) = 3 ((Candela)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "my_ud");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "my_ud");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_candela_4)
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
  u->setKind(UNIT_KIND_CANDELA);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3Candela)^2) = 27 ((Candela)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_coulomb_1)
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
  u->setKind(UNIT_KIND_COULOMB);

  units->setDocument(d);

  /* 3 Coulomb = 3 Ampere second */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_coulomb_2)
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
  u->setKind(UNIT_KIND_COULOMB);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Coulomb) = 6 Ampere second */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_coulomb_3)
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
  u->setKind(UNIT_KIND_COULOMB);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((Coulomb)^2) = 3 ((Ampere)^2(second)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_coulomb_4)
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
  u->setKind(UNIT_KIND_COULOMB);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3Coulomb)^2) = 27 ((Ampere)^2(second)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_lumen_1)
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
  u->setKind(UNIT_KIND_LUMEN);

  units->setDocument(d);

  /* 3 lumen = 3 candela */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "candela");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_lumen_2)
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
  u->setKind(UNIT_KIND_LUMEN);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Lumen) = 6 candela */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "candela");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 0);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_lumen_3)
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
  u->setKind(UNIT_KIND_LUMEN);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((lumen)^2) = 3 ((candela)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  
  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);

  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_lumen_4)
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
  u->setKind(UNIT_KIND_LUMEN);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3lumen)^2) = 27 ((candela)^2) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);
  
  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);

  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_farad_1)
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
  u->setKind(UNIT_KIND_FARAD);

  units->setDocument(d);
  
  /* 1 Farad = 1 m^-2 kg^-1 s^4 A^2 */
  /* 3 Farad = 3 m^-2 kg^-1 s^4 A^2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), 4.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_farad_2)
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
  u->setKind(UNIT_KIND_FARAD);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*Coulomb) = 6  m^-2 kg^-1 s^4 A^2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 6) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), 4.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_farad_3)
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
  u->setKind(UNIT_KIND_FARAD);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((Coulomb)^2) = 3 (m^-4 kg^-2 s^8 A^4) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 3) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 4.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), -4.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), 8.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_farad_4)
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
  u->setKind(UNIT_KIND_FARAD);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3Coulomb)^2) = 27 (m^-4 kg^-2 s^8 A^4) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 27) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 4.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), -4.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), 8.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_litre_1)
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
  u->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);

  /* 3 litre = 0.003 m^3  */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 3.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_litre_2)
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
  u->setKind(UNIT_KIND_LITRE);
  u->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 (2*l) = 0.006 (m^3) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.006) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 3.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_litre_3)
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
  u->setKind(UNIT_KIND_LITRE);
  u->setMultiplier(1.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((l)^2) = 0.000003 ((m)^6) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.000003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 6.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_litre_4)
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
  u->setKind(UNIT_KIND_LITRE);
  u->setMultiplier(3.0);
  u->setExponent(2.0);

  units->setDocument(d);

  /* 3 ((3l)^2) = .000027 ((m)^6) */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.000027) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");
  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), 6.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_1)
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
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);
  
  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 1 H l = 0.001 m^5 kg s^-2 A^-2 */
  /* 3 H l = 0.003 m^5 kg s^-2 A^-2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 5.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_2)
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
  u->setMultiplier(2.0);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);

  /* 3 H l = 0.003 m^5 kg s^-2 A^-2 */
  /* 3 (2H) l = 0.006 m^5 kg s^-2 A^-2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.006) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 5.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_3)
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
  u->setExponent(2.0);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 1 H l = 0.001 m^5 kg s^-2 A^-2 */
  /* 3 H l = 0.003 m^5 kg s^-2 A^-2 */
  /* 3 (H^2) l = 0.003 m^7 kg^2 s^-4 A^-4 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -4.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 7.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -4.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_4)
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
  u->setMultiplier(3.0);
  u->setExponent(2.0);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 3 ((3H)^2) l = 0.027 m^7 kg^2 s^-4 A^-4 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.027) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -4.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 7.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -4.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_5)
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
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(2.0);

  units->setDocument(d);

  /* 3 H l = 0.003 m^5 kg s^-2 A^-2 */
  /* 3 (H) (2l) = 0.006 m^5 kg s^-2 A^-2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.006) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 5.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_6)
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
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(1.0);
  u1->setExponent(2.0);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 1 H l = 0.001 m^5 kg s^-2 A^-2 */
  /* 3 (H) (l^2) = 0.000003 m^8 kg s^-2 A^-2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), 0.000003) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 8.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_7)
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
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(3.0);
  u1->setExponent(2.0);

  units->setDocument(d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 3 (H) ((3l)^2) = 0.00027 m^8 kg s^-2 A^-2 */
  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);
  double ans = 3 * pow((3 * 0.001),2);
  fail_unless (
      equalDouble(d->getModel()->getParameter(0)->getValue(), ans) == true);
  fail_unless (d->getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d->getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 1.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), 8.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -2.0) == true);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_convert_henry_litre_8)
{
  SBMLUnitsConverter units;
  SBMLDocument d(3, 1);
  Model * m = d.createModel();
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
  u->setMultiplier(2.3);
  u->setExponent(2.0);
  Unit * u1 = ud1->createUnit();
  u1->initDefaults();
  u1->setKind(UNIT_KIND_LITRE);
  u1->setMultiplier(0.5);
  u1->setExponent(-2.0);

  units.setDocument(&d);

  /* 1 Henry = 1 m^2 kg s^-2 A^-2*/
  /* 1 litre = 0.001 m^3*/
  /* 3 ((2.3H)^2) ((0.5l)^-2) = 63480000 m^-2 kg^2 s^-4 A^-4 */
  fail_unless (units.convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (
      equalDouble(d.getModel()->getParameter(0)->getValue(), 63480000) == true);
  fail_unless (d.getModel()->getParameter(0)->getUnits() == "unitSid_0");

  fail_unless (d.getModel()->getNumUnitDefinitions() == 1);

  UnitDefinition *ud = d.getModel()->getUnitDefinition(0);
  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 4);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(0)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(0)->getExponent(), -4.0) == true);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(1)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(1)->getExponent(), 2.0) == true);
  fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);
  fail_unless(ud->getUnit(2)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(2)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(2)->getExponent(), -2.0) == true);
  fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
  fail_unless(ud->getUnit(3)->getScale() == 0);
  fail_unless(equalDouble(ud->getUnit(3)->getMultiplier(), 1.0) == true);
  fail_unless(equalDouble(ud->getUnit(3)->getExponent(), -4.0) == true);

}
END_TEST

START_TEST( test_convert_extend_to_l2 )
{
  string fileName = string(TestDataDirectory) + "/extend_l3.xml";
  SBMLDocument *doc = readSBMLFromFile(fileName.c_str());
  
  // strict conversion ought to fail
  fail_unless(doc->setLevelAndVersion(2, 4, true) == false);
  fail_unless(doc->getErrorLog()->contains(ExtentUnitsNotSubstance));
  

  doc->getErrorLog()->clearLog();
  // non-strict conversion ought to succeed
  fail_unless(doc->setLevelAndVersion(2, 4, false) == true);
  // however it ought to leave a trace in the error log as to what
  // was wrong
  fail_unless(doc->getErrorLog()->contains(ExtentUnitsNotSubstance));

  // when unit validation is disabled, that one ought to also pass
  doc->getErrorLog()->clearLog();
  doc->setConversionValidators(AllChecksON & UnitsCheckOFF);
  fail_unless(doc->setLevelAndVersion(2, 4, true) == true);
  fail_unless(doc->getNumErrors(LIBSBML_SEV_ERROR) == 0);

  delete doc;
}
END_TEST

Suite *
create_suite_TestUnitsConverter (void)
{ 
  Suite *suite = suite_create("UnitsConverter");
  TCase *tcase = tcase_create("UnitsConverter");


  tcase_add_test(tcase, test_setup);
  tcase_add_test(tcase, test_setDocument);
  tcase_add_test(tcase, test_convertCompartment);
  tcase_add_test(tcase, test_convertSpecies);
  tcase_add_test(tcase, test_convertParameters);
  tcase_add_test(tcase, test_convertParameters_1);
  tcase_add_test(tcase, test_convertParameters_2);
  tcase_add_test(tcase, test_convertParameters_3);
  tcase_add_test(tcase, test_convertParameters_4);
  tcase_add_test(tcase, test_convertParameters_fromFile);
  tcase_add_test(tcase, test_convert_ampere_1);
  tcase_add_test(tcase, test_convert_ampere_2);
  tcase_add_test(tcase, test_convert_ampere_3);
  tcase_add_test(tcase, test_convert_ampere_4);
  tcase_add_test(tcase, test_convert_avogadro_1);
  tcase_add_test(tcase, test_convert_avogadro_2);
  tcase_add_test(tcase, test_convert_avogadro_3);
  tcase_add_test(tcase, test_convert_avogadro_4);
  tcase_add_test(tcase, test_convert_hertz_1);
  tcase_add_test(tcase, test_convert_hertz_2);
  tcase_add_test(tcase, test_convert_hertz_3);
  tcase_add_test(tcase, test_convert_hertz_4);
  tcase_add_test(tcase, test_convert_candela_1);
  tcase_add_test(tcase, test_convert_candela_2);
  tcase_add_test(tcase, test_convert_candela_3);
  tcase_add_test(tcase, test_convert_candela_4);
  tcase_add_test(tcase, test_convert_coulomb_1);
  tcase_add_test(tcase, test_convert_coulomb_2);
  tcase_add_test(tcase, test_convert_coulomb_3);
  tcase_add_test(tcase, test_convert_coulomb_4);
  tcase_add_test(tcase, test_convert_lumen_1);
  tcase_add_test(tcase, test_convert_lumen_2);
  tcase_add_test(tcase, test_convert_lumen_3);
  tcase_add_test(tcase, test_convert_lumen_4);
  tcase_add_test(tcase, test_convert_farad_1);
  tcase_add_test(tcase, test_convert_farad_2);
  tcase_add_test(tcase, test_convert_farad_3);
  tcase_add_test(tcase, test_convert_farad_4);
  tcase_add_test(tcase, test_convert_litre_1);
  tcase_add_test(tcase, test_convert_litre_2);
  tcase_add_test(tcase, test_convert_litre_3);
  tcase_add_test(tcase, test_convert_litre_4);
  tcase_add_test(tcase, test_convert_henry_litre_1);
  tcase_add_test(tcase, test_convert_henry_litre_2);
  tcase_add_test(tcase, test_convert_henry_litre_3);
  tcase_add_test(tcase, test_convert_henry_litre_4);
  tcase_add_test(tcase, test_convert_henry_litre_5);
  tcase_add_test(tcase, test_convert_henry_litre_6);
  tcase_add_test(tcase, test_convert_henry_litre_7);
  tcase_add_test(tcase, test_convert_henry_litre_8);
  tcase_add_test(tcase, test_convert_extend_to_l2);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

