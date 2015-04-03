/**
 * @file    TestUnknownPackages.cpp
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

START_TEST (test_readwrite_unknown)
{
  string origModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" xmlns:extra=\"http://www.sbml.org/sbml/level3/version1/extra/version1\" level=\"3\" version=\"1\" extra:required=\"false\">\n"
  "  <model>\n"
  "    <extra:listOfThings>\n"
  "      <extra:thing extra:id=\"y\"/>\n"
  "    </extra:listOfThings>\n"
  "  </model>\n"
  "</sbml>\n";

  SBMLDocument* doc = readSBMLFromString(origModel.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //Fail if we claim there are errors in the document (there shouldn't be)
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 0);
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_WARNING) == 1);
  fail_unless(doc->getError(0)->getErrorId() == UnrequiredPackagePresent);

  string newModel = writeSBMLToStdString(doc);

  fail_unless(newModel==origModel);

  delete doc;
}
END_TEST

START_TEST (test_readwrite_unknown2)
{
  string origModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" xmlns:extra=\"http://www.sbml.org/sbml/level3/version1/extra/version1\" level=\"3\" version=\"1\" extra:required=\"true\">\n"
  "  <model>\n"
  "    <extra:listOfThings>\n"
  "      <extra:thing extra:id=\"y\"/>\n"
  "    </extra:listOfThings>\n"
  "  </model>\n"
  "</sbml>\n";

  SBMLDocument* doc = readSBMLFromString(origModel.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //Fail if we claim there are errors in the document (there shouldn't be)
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 1);
  fail_unless(doc->getError(0)->getErrorId() == RequiredPackagePresent);

  string newModel = writeSBMLToStdString(doc);

  fail_unless(newModel==origModel);

  delete doc;
}
END_TEST

START_TEST (test_readwrite_unknown3)
{
  string origModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" xmlns:extra=\"http://www.sbml.org/sbml/level3/version1/extra/version1\" level=\"3\" version=\"1\" extra:required=\"false\">\n"
  "  <model>\n"
  "    <extra:listOfThings>\n"
  "      <extra:thing extra:id=\"y\"/>\n"
  "    </extra:listOfThings>\n"
  "  </model>\n"
  "</sbml>\n";

  SBMLDocument* doc = readSBMLFromString(origModel.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //disable and re-enable the package
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", false);
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", true);

  string newModel = writeSBMLToStdString(doc);

  fail_unless(newModel==origModel);

  delete doc;
}
END_TEST

START_TEST (test_readwrite_unknown4)
{
  string origModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" xmlns:extra=\"http://www.sbml.org/sbml/level3/version1/extra/version1\" level=\"3\" version=\"1\" extra:required=\"true\">\n"
  "  <model>\n"
  "    <extra:listOfThings>\n"
  "      <extra:thing extra:id=\"y\"/>\n"
  "    </extra:listOfThings>\n"
  "  </model>\n"
  "</sbml>\n";

  SBMLDocument* doc = readSBMLFromString(origModel.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //disable and re-enable the package
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", false);
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", true);

  string newModel = writeSBMLToStdString(doc);

  fail_unless(newModel==origModel);

  delete doc;
}
END_TEST

START_TEST (test_copy_unknown1)
{
  string filename(TestDataDirectory);
  // load document
  string cfile = filename + "extra_not_required1.xml";
  SBMLDocument* doc = readSBMLFromFile(cfile.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //Fail if we claim there are errors in the document (there shouldn't be)
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 0);

  //Write this model to a string.
  string origModel = writeSBMLToStdString(doc);

  //Now make a copy and write *that* to a string:
  SBMLDocument* dcopy = doc->clone();
  string newModel = writeSBMLToStdString(dcopy);

  fail_unless(newModel==origModel);

  delete doc;
  delete dcopy;
}
END_TEST
  
START_TEST (test_copy_unknown2)
{
  string filename(TestDataDirectory);
  // load document
  string cfile = filename + "extra_not_required1.xml";
  SBMLDocument* doc = readSBMLFromFile(cfile.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //Fail if we claim there are errors in the document (there shouldn't be)
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 0);

  //disable the package
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", false);

  //Write this model to a string.
  string origModel = writeSBMLToStdString(doc);

  //Now make a copy and write *that* to a string:
  SBMLDocument* dcopy = doc->clone();
  string newModel = writeSBMLToStdString(dcopy);

  fail_unless(newModel==origModel);

  delete doc;
  delete dcopy;
}
END_TEST
  
START_TEST (test_copy_unknown3)
{
  string filename(TestDataDirectory);
  // load document
  string cfile = filename + "extra_not_required1.xml";
  SBMLDocument* doc = readSBMLFromFile(cfile.c_str());

  // fail if there is no model (readSBMLFromFile always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //Fail if we claim there are errors in the document (there shouldn't be)
  fail_unless(doc->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 0);

  //Write this model to a string.
  string origModel = writeSBMLToStdString(doc);

  //disable the package
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", false);

  //Now make a copy, re-enable the package, and write *that* to a string:
  SBMLDocument* dcopy = doc->clone();
  dcopy->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", true);
  string newModel = writeSBMLToStdString(dcopy);

  fail_unless(newModel==origModel);

  delete doc;
  delete dcopy;
}
END_TEST
  
START_TEST (test_disable_unknown)
{
  string origModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" xmlns:extra=\"http://www.sbml.org/sbml/level3/version1/extra/version1\" level=\"3\" version=\"1\" extra:required=\"false\">\n"
  "  <model extra:info1=\"extra!\" extra:info2=\"READ_ALL_ABOUT_IT\">\n"
  "    <extra:listOfThings>\n"
  "      <extra:thing extra:id=\"y\"/>\n"
  "    </extra:listOfThings>\n"
  "  </model>\n"
  "</sbml>\n";

  string disabledModel = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" level=\"3\" version=\"1\">\n"
  "  <model/>\n"
  "</sbml>\n";

  SBMLDocument* doc = readSBMLFromString(origModel.c_str());

  // fail if there is no model (readSBML* always returns a valid document)
  fail_unless(doc->getModel() != NULL);

  //disable the package
  doc->enablePackageInternal("http://www.sbml.org/sbml/level3/version1/extra/version1", "extra", false);

  //write it to a string
  string newModel = writeSBMLToStdString(doc);

  fail_unless(newModel==disabledModel);

  delete doc;
}
END_TEST

Suite *
create_suite_TestUnknownPackages (void)
{ 
  Suite *suite = suite_create("TestUnknownPackages");
  TCase *tcase = tcase_create("TestUnknownPackages");

  tcase_add_test(tcase, test_readwrite_unknown);
  tcase_add_test(tcase, test_readwrite_unknown2);
  tcase_add_test(tcase, test_readwrite_unknown3);
  tcase_add_test(tcase, test_readwrite_unknown4);
  tcase_add_test(tcase, test_copy_unknown1);
  tcase_add_test(tcase, test_copy_unknown2);
  tcase_add_test(tcase, test_copy_unknown3);
  tcase_add_test(tcase, test_disable_unknown);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

