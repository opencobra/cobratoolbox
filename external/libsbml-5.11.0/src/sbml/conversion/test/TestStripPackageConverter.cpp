/**
 * @file    TestStripPackageConverter.cpp
 * @brief   Tests for converter that strips packages
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

#include <sbml/conversion/SBMLStripPackageConverter.h>
#include <sbml/conversion/ConversionProperties.h>



#include <string>
using namespace std;

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

#include <sbml/util/util.h>

extern char *TestDataDirectory;

START_TEST (test_strip_unknownreq)
{
  std::string filename(TestDataDirectory);
  std::string fileIn = filename + "package1.xml";

  SBMLDocument* d = readSBMLFromFile(fileIn.c_str());

  fail_unless(d != NULL);

  ConversionProperties props;
  props.addOption("package", "unknownreq");

  SBMLConverter* converter = new SBMLStripPackageConverter();
  converter->setProperties(&props);
  converter->setDocument(d);

  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);

  std::string newModel = writeSBMLToStdString(d);
  
  
  std::string fileOut = filename + "package1-unknownreq_stripped.xml";
  SBMLDocument* fdoc = readSBMLFromFile(fileOut.c_str());
  string stripped = writeSBMLToStdString(fdoc);
  
  fail_unless(stripped == newModel);

  delete converter;
  delete fdoc;
  delete d;
}
END_TEST


START_TEST (test_strip_comp)
{
  std::string filename(TestDataDirectory);
  std::string fileIn = filename + "package1.xml";

  SBMLDocument* d = readSBMLFromFile(fileIn.c_str());

  fail_unless(d != NULL);

  ConversionProperties props;
  props.addOption("package", "comp");

  SBMLConverter* converter = new SBMLStripPackageConverter();
  converter->setProperties(&props);
  converter->setDocument(d);

  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);

  std::string newModel = writeSBMLToStdString(d);
  
  
  std::string fileOut = filename + "package1-comp_stripped.xml";
  SBMLDocument* fdoc = readSBMLFromFile(fileOut.c_str());
  string stripped = writeSBMLToStdString(fdoc);
  
  fail_unless(stripped == newModel);

  delete converter;
  delete fdoc;
  delete d;
}
END_TEST


Suite *
create_suite_TestStripPackageConverter (void)
{ 
  Suite *suite = suite_create("StripPackageConverter");
  TCase *tcase = tcase_create("StripPackageConverter");


  tcase_add_test(tcase, test_strip_unknownreq);
  tcase_add_test(tcase, test_strip_comp);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

