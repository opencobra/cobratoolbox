/**
 * \file    TestSBMLExtensionRegistry.cpp
 * \brief   SBMLExtensionRegistry unit tests
 * \author  Frank T. Bergmann <fbergman@caltech.edu>
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

#if defined(__cplusplus)
#include <iostream>
#endif

#include <check.h>

#include <sbml/common/common.h>
#include <sbml/common/extern.h>

#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLDocumentPlugin.h>
#include <sbml/extension/SBasePluginCreator.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

#include <sbml/SBMLTypes.h>

#include "TestPackage.h"

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST (test_SBMLExtensionRegistry_addExtension)
{
	SBMLExtensionRegistry& instance = SBMLExtensionRegistry::getInstance();

	// test that null reference is caught 
	int result = instance.addExtension(NULL);	
	fail_unless( result == LIBSBML_INVALID_ATTRIBUTE_VALUE );	

	// create extension
	TestExtension testExtension;
	std::vector<std::string> packageURIs;
	std::string newUri = "http://www.sbml.org/sbml/level3/version1/test/version4";
	packageURIs.push_back(newUri);

	SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
	SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);

	SBasePluginCreator<SBMLDocumentPlugin, TestExtension> sbmldocPluginCreator(sbmldocExtPoint,packageURIs);
	SBasePluginCreator<TestModelPlugin, TestExtension> modelPluginCreator(modelExtPoint,packageURIs);

	testExtension.addSBasePluginCreator(&sbmldocPluginCreator);
	testExtension.addSBasePluginCreator(&modelPluginCreator);

	// add valid extension

	fail_unless(instance.isRegistered(newUri) == false);
	result = instance.addExtension(&testExtension);	
	fail_unless( result == LIBSBML_OPERATION_SUCCESS );	
	fail_unless(instance.isRegistered(newUri) == true);

	// adding again should give us an error
	result = instance.addExtension(&testExtension);	
	fail_unless( result == LIBSBML_PKG_CONFLICT );	

	// is registered
	fail_unless( instance.isRegistered( 
		TestExtension::getXmlnsL3V1V1() ) == true );	
	
	instance.setEnabled( 
		TestExtension::getXmlnsL3V1V1(), true );	

	fail_unless( instance.isEnabled( 
		TestExtension::getXmlnsL3V1V1() ) == true );	


	// set enabled 
	instance.setEnabled( 
		TestExtension::getXmlnsL3V1V1(), false );	

	fail_unless( instance.isEnabled( 
		TestExtension::getXmlnsL3V1V1() ) == false );	

	instance.setEnabled( 
		TestExtension::getXmlnsL3V1V1(), true );	

  fail_unless( instance.isEnabled(
               TestExtension::getXmlnsL3V1V1() ) == true );
  
  SBMLExtensionRegistry::disablePackage(TestExtension::getXmlnsL3V1V1());
  
  fail_unless( instance.isEnabled(
                                  TestExtension::getXmlnsL3V1V1() ) == false );

  SBMLExtensionRegistry::enablePackage(TestExtension::getXmlnsL3V1V1());

  fail_unless( instance.isEnabled(
                                  TestExtension::getXmlnsL3V1V1() ) == true );

  std::vector<std::string> names; names.push_back(TestExtension::getXmlnsL3V1V1());
  SBMLExtensionRegistry::disablePackages(names);
  
  fail_unless(   SBMLExtensionRegistry::isPackageEnabled(names[0]) == false );
  SBMLExtensionRegistry::enablePackages(names);

  fail_unless(   SBMLExtensionRegistry::isPackageEnabled(names[0]) == true );

  
}
END_TEST

START_TEST (test_SBMLExtensionRegistry_getExtension)
{
	string *nullString = NULL;

	SBMLExtensionRegistry &instance = SBMLExtensionRegistry::getInstance();
	const std::string &uri = TestExtension::getXmlnsL3V1V1();
	// try and get extension for NULL reference;
	SBMLExtension* result = instance.getExtension(*nullString);
	fail_unless(result == NULL);

	// get a valid one
	result = instance.getExtension(uri);
  fail_unless(result != NULL);

	bool status = instance.setEnabled(uri, false);
	fail_unless(status == false);

	fail_unless(instance.isEnabled(uri) == false);
	fail_unless(result->isEnabled() == false);

	// delete it and try again
	delete result;

	status = instance.isEnabled(uri);
	fail_unless(status == false);

	result = instance.getExtension(uri);	
	fail_unless(result != NULL);

	status = instance.setEnabled(uri, true);
	fail_unless(status == true);
	fail_unless(result->isEnabled() == true);


	delete result;
}
END_TEST

START_TEST (test_SBMLExtensionRegistry_c_api)
{
  fail_unless(SBMLExtensionRegistry_getExtension(NULL) == NULL);
  fail_unless(SBMLExtensionRegistry_addExtension(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless(SBMLExtensionRegistry_isRegistered(TestExtension::getXmlnsL3V1V1().c_str()) == (int)true);
  fail_unless(SBMLExtensionRegistry_isEnabled(TestExtension::getXmlnsL3V1V1().c_str()) == (int)true);
  fail_unless(SBMLExtensionRegistry_setEnabled(TestExtension::getXmlnsL3V1V1().c_str(), (int)false) == (int)false);
  fail_unless(SBMLExtensionRegistry_isEnabled(TestExtension::getXmlnsL3V1V1().c_str()) == (int)false);

}
END_TEST

Suite *
create_suite_SBMLExtensionRegistry (void)
{
  Suite *suite = suite_create("SBMLExtensionRegistry");
  TCase *tcase = tcase_create("SBMLExtensionRegistry");
	
  tcase_add_test( tcase, test_SBMLExtensionRegistry_addExtension );
  tcase_add_test( tcase, test_SBMLExtensionRegistry_getExtension );
  tcase_add_test( tcase, test_SBMLExtensionRegistry_c_api        );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

