/**
 * @file    TestInferUnitsConverter.cpp
 * @brief   Tests for converter that infers units
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

#include <sbml/conversion/SBMLInferUnitsConverter.h>
#include <sbml/conversion/ConversionProperties.h>



#include <string>
using namespace std;

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

#include <sbml/util/util.h>

extern char *TestDataDirectory;

START_TEST (test_infer_dimensionless)
{
  string filename(TestDataDirectory);
  filename += "inferUnits.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("g")->isSetUnits() == false);
  fail_unless(d->getModel()->getParameter("d")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 1);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("g")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("g")->getUnits() == "dimensionless");

  fail_unless(d->getModel()->getParameter("d")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("d")->getUnits() == "dimensionless");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_existingUD)
{
  string filename(TestDataDirectory);
  filename += "inferUnits.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("a")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 1);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("a")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("a")->getUnits() == "knownUnits");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_newUD)
{
  string filename(TestDataDirectory);
  filename += "inferUnits.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("b")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 1);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("b")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("b")->getUnits() == "unitSid_0");

  fail_unless(d->getModel()->getNumUnitDefinitions() == 2);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(1);

  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 2);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == 1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_LITRE);

  fail_unless(ud->getUnit(1)->getMultiplier() == 1);
  fail_unless(ud->getUnit(1)->getScale() == 0);
  fail_unless(ud->getUnit(1)->getExponent() == 1);
  fail_unless(ud->getUnit(1)->getOffset() == 0.0);
  fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_baseUnit)
{
  string filename(TestDataDirectory);
  filename += "inferUnits.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("c")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 1);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("c")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("c")->getUnits() == "second");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_baseUnit_fromMath)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-2.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("l")->isSetUnits() == false);
  fail_unless(d->getModel()->getParameter("g2")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 2);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("l")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("l")->getUnits() == "second");

  fail_unless(d->getModel()->getParameter("g2")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("g2")->getUnits() == "second");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_existingUD_fromMath)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-2.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("known2")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 2);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("known2")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("known2")->getUnits() == "knownUnits");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_dimensionless_fromMath)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-2.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("g")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 2);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("g")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("g")->getUnits() == "dimensionless");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_newUD_fromMath)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-2.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("c")->isSetUnits() == false);
  fail_unless(d->getModel()->getNumUnitDefinitions() == 2);

  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("c")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("c")->getUnits() == "unitSid_0");

  fail_unless(d->getModel()->getNumUnitDefinitions() == 3);

  UnitDefinition *ud = d->getModel()->getUnitDefinition(2);

  fail_unless(ud->getId() == "unitSid_0");
  fail_unless(ud->getNumUnits() == 1);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == -1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_fromReaction)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-3.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  fail_unless(d->getModel()->getParameter("k1")->isSetUnits() == false);
  
  SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  units->setDocument(d);

  fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless(d->getModel()->getParameter("k1")->isSetUnits() == true);
  fail_unless(d->getModel()->getParameter("k1")->getUnits() == "per_time");

  delete units;
  delete d;
}
END_TEST


START_TEST (test_infer_localParam_fromReaction)
{
  string filename(TestDataDirectory);
  filename += "inferUnits-3.xml";

  SBMLDocument* d = readSBMLFromFile(filename.c_str());

  fail_unless(d != NULL);

  LocalParameter * p = d->getModel()->getReaction(1)->
                                 getKineticLaw()->getLocalParameter("k2");

  fail_unless(p->isSetUnits() == false);

  p->setCalculatingUnits(true);
  UnitDefinition *ud = p->getDerivedUnitDefinition();

  fail_unless(ud->getNumUnits() == 1);
  
  fail_unless(ud->getUnit(0)->getMultiplier() == 1);
  fail_unless(ud->getUnit(0)->getScale() == 0);
  fail_unless(ud->getUnit(0)->getExponent() == -1);
  fail_unless(ud->getUnit(0)->getOffset() == 0.0);
  fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);


  // TO DO make the units converter do local parameters;
  //fail_unless(d->getModel()->getNumUnitDefinitions() == 3);
  //
  //SBMLInferUnitsConverter * units = new SBMLInferUnitsConverter();

  //units->setDocument(d);

  //fail_unless (units->convert() == LIBSBML_OPERATION_SUCCESS);

  //kl = d->getModel()->getReaction(1)->getKineticLaw();

  //fail_unless(kl->getLocalParameter("k2")->isSetUnits() == true);
  //fail_unless(kl->getLocalParameter("k2")->getUnits() == "per_time");

  //delete units;
  delete d;
}
END_TEST


Suite *
create_suite_TestInferUnitsConverter (void)
{ 
  Suite *suite = suite_create("InferUnitsConverter");
  TCase *tcase = tcase_create("InferUnitsConverter");


  tcase_add_test(tcase, test_infer_dimensionless);
  tcase_add_test(tcase, test_infer_existingUD);
  tcase_add_test(tcase, test_infer_newUD);
  tcase_add_test(tcase, test_infer_baseUnit);
  tcase_add_test(tcase, test_infer_dimensionless_fromMath);
  tcase_add_test(tcase, test_infer_existingUD_fromMath);
  tcase_add_test(tcase, test_infer_newUD_fromMath);
  tcase_add_test(tcase, test_infer_baseUnit_fromMath);
  tcase_add_test(tcase, test_infer_fromReaction);
  tcase_add_test(tcase, test_infer_localParam_fromReaction);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

