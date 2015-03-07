/**
 * \file    TestSBMLExtension.cpp
 * \brief   SBMLExtension unit tests
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
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/extension/SBasePluginCreator.h>
#include <sbml/extension/SBMLDocumentPlugin.h>
#include <sbml/extension/SBaseExtensionPoint.h>

#include <sbml/SBMLTypes.h>

#include "TestPackage.h"

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST (test_SBMLExtension)
{
	string uri = TestExtension::getXmlnsL3V1V1();
	TestExtension* ext = (TestExtension*)SBMLExtensionRegistry::getInstance().getExtension(uri);
	fail_unless(ext != NULL );
	fail_unless(ext->getURI(3, 1, 1) == uri);
	fail_unless(ext->getURI(300, 100, 100) == "");

	// test adding nothing
	int status = ext->addSBasePluginCreator(NULL);
	fail_unless(status == LIBSBML_INVALID_OBJECT );

	// test adding incomplete

	TestPkgNamespaces ns(3, 1, 1);
	string prefix = "prefix";
	std::vector<std::string> noURIs;
	std::vector<std::string> packageURIs;
	packageURIs.push_back(uri);

	// create a creator for TestModelPlugins
	SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);
	SBasePluginCreator<TestModelPlugin,   TestExtension> *modelPluginCreator
		= new SBasePluginCreator<TestModelPlugin,   TestExtension>(modelExtPoint,noURIs);
	
	status = ext->addSBasePluginCreator(modelPluginCreator);
	fail_unless(status == LIBSBML_INVALID_OBJECT );

	// now add real one
	delete modelPluginCreator;
	modelPluginCreator
		= new SBasePluginCreator<TestModelPlugin,   TestExtension>(modelExtPoint,packageURIs);
	
	status = ext->addSBasePluginCreator(modelPluginCreator);
	fail_unless(status == LIBSBML_OPERATION_SUCCESS );

	// this number is three as the static initializer already adds 2, plus the one created above
	fail_unless(ext->getNumOfSBasePlugins() == 3 ); 
	fail_unless(ext->getNumOfSupportedPackageURI() == 1 );

	// now try to get it back
	SBasePluginCreatorBase* plugin = ext->getSBasePluginCreator(modelExtPoint);
	fail_unless(plugin != NULL );

	// get it by index
	plugin = ext->getSBasePluginCreator(0);
	fail_unless(plugin != NULL );

	// test remaining methods

	ext->setEnabled(true);
	fail_unless(ext->isEnabled() == true);	
	ext->setEnabled(false);
	fail_unless(ext->isEnabled() == false);
	ext->setEnabled(true);
	fail_unless(ext->isEnabled() == true);	

	fail_unless(ext->isSupported(uri));
	fail_unless(ext->getSupportedPackageURI(0) == uri);	
	fail_unless(ext->getSupportedPackageURI(10) == "");	

	delete modelPluginCreator;
	delete ext;
}
END_TEST

START_TEST (test_SBMLExtension_c_api)
{
  string sUri = TestExtension::getXmlnsL3V1V1();
  const char* uri = sUri.c_str();
  TestExtension* ext = (TestExtension*)SBMLExtensionRegistry_getExtension(uri);
  TestExtension* ext2  = (TestExtension*)SBMLExtension_clone(ext);
  fail_unless(ext2 != NULL);

  fail_unless(SBMLExtension_getLevel(ext, uri) == SBMLExtension_getLevel(ext2, uri));
  fail_unless(SBMLExtension_getVersion(ext, uri) == SBMLExtension_getVersion(ext2, uri));
  fail_unless(SBMLExtension_getPackageVersion(ext, uri) == SBMLExtension_getPackageVersion(ext2, uri));

  fail_unless(SBMLExtension_free(ext2) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBMLExtension_free(ext) == LIBSBML_OPERATION_SUCCESS);
}
END_TEST

START_TEST(test_SBMLExtension_reenable)
{  
  TestPkgNamespaces ns(3, 1, 1);
  SBMLDocument doc(&ns);
  Model* model = doc.createModel();  
  TestModelPlugin* mPlugin = dynamic_cast<TestModelPlugin*>( model->getPlugin("test") );
  fail_unless(mPlugin != NULL);
  mPlugin->setValue("foo");
  fail_unless(mPlugin->getValue() == "foo");
  fail_unless(doc.getNumDisabledPlugins() == 0);

  // disable plugin 
  doc.disablePackage(TestExtension::getXmlnsL3V1V1(), "test");
  fail_unless(doc.getNumDisabledPlugins() == 1);
  mPlugin = dynamic_cast<TestModelPlugin*>(model->getPlugin("test"));
  fail_unless(mPlugin == NULL);

  // re-enable plugin
  doc.enablePackage(TestExtension::getXmlnsL3V1V1(), "test", true);
  fail_unless(doc.getNumDisabledPlugins() == 0);
  mPlugin = dynamic_cast<TestModelPlugin*>(model->getPlugin("test"));
  fail_unless(mPlugin != NULL);
  fail_unless(mPlugin->getValue() == "foo");

  // disable again
  doc.disablePackage(TestExtension::getXmlnsL3V1V1(), "test");
  fail_unless(doc.getNumDisabledPlugins() == 1);
  doc.deleteDisabledPlugins();
  fail_unless(doc.getNumDisabledPlugins() == 0);

  // enable plugin
  doc.enablePackage(TestExtension::getXmlnsL3V1V1(), "test", true);
  mPlugin = dynamic_cast<TestModelPlugin*>(model->getPlugin("test"));
  fail_unless(mPlugin != NULL);
  fail_unless(mPlugin->getValue().empty());

}
END_TEST

Suite *
create_suite_SBMLExtension (void)
{
  Suite *suite = suite_create("SBMLExtension");
  TCase *tcase = tcase_create("SBMLExtension");
	
  tcase_add_test( tcase, test_SBMLExtension );
  tcase_add_test( tcase, test_SBMLExtension_c_api );
  tcase_add_test( tcase, test_SBMLExtension_reenable );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS
