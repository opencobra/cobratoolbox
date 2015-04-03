/**
 * \file    TestSBasePlugin.cpp
 * \brief   SBasePlugin unit tests
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

#include <sbml/SBMLTypes.h>

#include "TestPackage.h"

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST (test_SBasePlugin_getUri)
{
	TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	TestExtension* ext = (TestExtension*)SBMLExtensionRegistry::getInstance().getExtension(uri);
	TestModelPlugin plugin(uri, "test", &ns);

	fail_unless(strcmp(plugin.getURI().c_str(), uri.c_str()) == 0);
  fail_unless(strcmp(plugin.getElementNamespace().c_str(), uri.c_str()) == 0);
	fail_unless(plugin.getParentSBMLObject() == NULL);
	fail_unless(plugin.getSBMLDocument() == NULL);

  SBMLDocument doc (&ns);
  fail_unless(doc.getSBMLNamespaces()->getNamespaces()->getURI("test") != "");
  plugin.setSBMLDocument(&doc);
  fail_unless(plugin.getURI() == uri);
  doc.getSBMLNamespaces()->getNamespaces()->remove("test");
  fail_unless(plugin.getURI() == uri);
  doc.getSBMLNamespaces()->getNamespaces()->add("http://different/uri", "test");
  fail_unless(plugin.getURI() != uri);
  plugin.setSBMLDocument(NULL);
  fail_unless(plugin.getURI() == uri);


	delete ext;

}
END_TEST

START_TEST (test_SBasePlugin_create)
{
  TestPkgNamespaces ns(3, 1, 1);
  string uri = TestExtension::getXmlnsL3V1V1();
	TestExtension* ext = (TestExtension*)SBMLExtensionRegistry::getInstance().getExtension(uri);
	TestModelPlugin plugin(uri, "prefix", &ns);

	fail_unless(strcmp(plugin.getURI().c_str(), uri.c_str()) == 0);
	fail_unless(strcmp(plugin.getPrefix().c_str(), "prefix") == 0);
	fail_unless(plugin.getParentSBMLObject() == NULL);
	fail_unless(plugin.getSBMLDocument() == NULL);

	delete ext;
}
END_TEST

START_TEST (test_SBasePlugin_c_api)
{
	TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	TestExtension* ext = (TestExtension*)SBMLExtensionRegistry::getInstance().getExtension(uri);
        
	TestModelPlugin plugin(uri, "prefix", &ns);

  SBasePlugin_t* cPlugin = SBasePlugin_clone(&plugin);
  fail_unless(cPlugin != NULL);
  fail_unless(strcmp(SBasePlugin_getURI(cPlugin), uri.c_str()) == 0);
  fail_unless(strcmp(SBasePlugin_getPrefix(cPlugin), "prefix") == 0);
  fail_unless(SBasePlugin_getParentSBMLObject(cPlugin) == NULL);
  fail_unless(SBasePlugin_getSBMLDocument(cPlugin) == NULL);
  
  SBasePlugin_free(cPlugin);


  fail_unless(SBasePlugin_clone(NULL) == NULL);
  fail_unless(SBasePlugin_createObject(NULL, NULL) == NULL);
  fail_unless(SBasePlugin_getPackageName(NULL) == NULL);
  fail_unless(SBasePlugin_getPrefix(NULL) == NULL);
  fail_unless(SBasePlugin_getURI(NULL) == NULL);
  fail_unless(SBasePlugin_hasRequiredElements(NULL) == LIBSBML_INVALID_OBJECT);
  
  delete ext;
}
END_TEST

Suite *
create_suite_SBasePlugin (void)
{
  Suite *suite = suite_create("SBasePlugin");
  TCase *tcase = tcase_create("SBasePlugin");
	
  tcase_add_test( tcase, test_SBasePlugin_create );
  tcase_add_test( tcase, test_SBasePlugin_c_api );
  tcase_add_test( tcase, test_SBasePlugin_getUri );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS
