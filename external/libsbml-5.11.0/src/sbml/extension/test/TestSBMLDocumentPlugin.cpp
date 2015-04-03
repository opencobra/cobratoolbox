/**
 * \file    TestSBMLDocumentPlugin.cpp
 * \brief   SBMLDocumentPlugin unit tests
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

START_TEST (test_SBMLDocumentPlugin_create)
{
	TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	string prefix = "prefix";
	std::vector<std::string> packageURIs;
	packageURIs.push_back(uri);

	// create a creator for TestModelPlugins	
	SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
	SBasePluginCreator<SBMLDocumentPlugin, TestExtension> sbmldocPluginCreator(sbmldocExtPoint,packageURIs);

	fail_unless(sbmldocPluginCreator.getNumOfSupportedPackageURI() == 1);		
	fail_unless(strcmp(sbmldocPluginCreator.getSupportedPackageURI(0).c_str(), uri.c_str()) == 0);
	fail_unless(strcmp(sbmldocPluginCreator.getSupportedPackageURI(10000).c_str(), "") == 0);
	fail_unless(sbmldocPluginCreator.getTargetExtensionPoint().getPackageName() == sbmldocExtPoint.getPackageName());
	fail_unless(sbmldocPluginCreator.getTargetExtensionPoint().getTypeCode() == sbmldocExtPoint.getTypeCode());
	fail_unless(sbmldocPluginCreator.getTargetPackageName() == sbmldocExtPoint.getPackageName());	
	fail_unless(sbmldocPluginCreator.getTargetSBMLTypeCode() == sbmldocExtPoint.getTypeCode());		
	fail_unless(sbmldocPluginCreator.isSupported(uri));	

	SBMLDocumentPlugin *plugin = sbmldocPluginCreator.createPlugin(uri, prefix, ns.getNamespaces());

	fail_unless(plugin != NULL);
  fail_unless(plugin->isSetRequired() == false);
	fail_unless(plugin->getRequired() == true);
	plugin->setRequired(false);
  fail_unless(plugin->isSetRequired() == true);
	fail_unless(plugin->getRequired() == false);

	delete plugin;


}
END_TEST

START_TEST (test_SBMLDocumentPlugin_c_api)
{
  TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	string prefix = "prefix";
	std::vector<std::string> packageURIs;
	packageURIs.push_back(uri);

	// create a creator for TestModelPlugins	
	SBaseExtensionPoint sbmldocExtPoint("core",SBML_DOCUMENT);
	SBasePluginCreator<SBMLDocumentPlugin, TestExtension> sbmldocPluginCreator(sbmldocExtPoint,packageURIs);

	fail_unless(sbmldocPluginCreator.getNumOfSupportedPackageURI() == 1);		
	fail_unless(strcmp(sbmldocPluginCreator.getSupportedPackageURI(0).c_str(), uri.c_str()) == 0);
	fail_unless(strcmp(sbmldocPluginCreator.getSupportedPackageURI(10000).c_str(), "") == 0);
	fail_unless(sbmldocPluginCreator.getTargetExtensionPoint().getPackageName() == sbmldocExtPoint.getPackageName());
	fail_unless(sbmldocPluginCreator.getTargetExtensionPoint().getTypeCode() == sbmldocExtPoint.getTypeCode());
	fail_unless(sbmldocPluginCreator.getTargetPackageName() == sbmldocExtPoint.getPackageName());	
	fail_unless(sbmldocPluginCreator.getTargetSBMLTypeCode() == sbmldocExtPoint.getTypeCode());		
	fail_unless(sbmldocPluginCreator.isSupported(uri));	

  SBMLDocumentPlugin_t* plugin = SBMLDocumentPlugin_create(uri.c_str(), prefix.c_str(), &ns);
	fail_unless(plugin != NULL);
  fail_unless(SBMLDocumentPlugin_isSetRequired(plugin) == (int)false);
  fail_unless(SBMLDocumentPlugin_getRequired(plugin) == (int)true);
  SBMLDocumentPlugin_setRequired(plugin, (int)true); 
  fail_unless(SBMLDocumentPlugin_isSetRequired(plugin) == (int)true);
  fail_unless(SBMLDocumentPlugin_getRequired(plugin) == (int)true);
  SBMLDocumentPlugin_setRequired(plugin, (int)false); 
  fail_unless(SBMLDocumentPlugin_isSetRequired(plugin) == (int)true);
  fail_unless(SBMLDocumentPlugin_getRequired(plugin) == (int)false);
  SBMLDocumentPlugin_unsetRequired(plugin);
  fail_unless(SBMLDocumentPlugin_isSetRequired(plugin) == (int)false);

  fail_unless(SBMLDocumentPlugin_free(plugin) == LIBSBML_OPERATION_SUCCESS);

  fail_unless(SBMLDocumentPlugin_create(NULL, NULL, NULL) == NULL);
  fail_unless(SBMLDocumentPlugin_getRequired(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless(SBMLDocumentPlugin_setRequired(NULL, 0) == LIBSBML_INVALID_OBJECT);

}
END_TEST


Suite *
create_suite_SBMLDocumentPlugin (void)
{
  Suite *suite = suite_create("SBMLDocumentPlugin");
  TCase *tcase = tcase_create("SBMLDocumentPlugin");
	
  tcase_add_test( tcase, test_SBMLDocumentPlugin_create );
  tcase_add_test( tcase, test_SBMLDocumentPlugin_c_api );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

