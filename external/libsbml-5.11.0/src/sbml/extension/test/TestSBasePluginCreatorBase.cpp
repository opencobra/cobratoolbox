/**
 * \file    TestSBasePluginCreatorBase.cpp
 * \brief   SBasePluginCreatorBase unit tests
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
#include <sbml/extension/SBaseExtensionPoint.h>

#include <sbml/SBMLTypes.h>

#include "TestPackage.h"

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST (test_SBasePluginCreatorBase_create)
{
	TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	string prefix = "prefix";
	std::vector<std::string> packageURIs;
	packageURIs.push_back(uri);

	// create a creator for TestModelPlugins
	SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);
	SBasePluginCreator<TestModelPlugin,   TestExtension> modelPluginCreator(modelExtPoint,packageURIs);

	fail_unless(modelPluginCreator.getNumOfSupportedPackageURI() == 1);		
	fail_unless(strcmp(modelPluginCreator.getSupportedPackageURI(0).c_str(), uri.c_str()) == 0);
	fail_unless(strcmp(modelPluginCreator.getSupportedPackageURI(10000).c_str(), "") == 0);
	fail_unless(modelPluginCreator.getTargetExtensionPoint().getPackageName() == modelExtPoint.getPackageName());
	fail_unless(modelPluginCreator.getTargetExtensionPoint().getTypeCode() == modelExtPoint.getTypeCode());
	fail_unless(modelPluginCreator.getTargetPackageName() == modelExtPoint.getPackageName());	
	fail_unless(modelPluginCreator.getTargetSBMLTypeCode() == modelExtPoint.getTypeCode());	
	
	fail_unless(modelPluginCreator.isSupported(uri));	

}
END_TEST

START_TEST (test_SBasePluginCreatorBase_c_api)
{

	TestPkgNamespaces ns(3, 1, 1);
	string uri = TestExtension::getXmlnsL3V1V1();
	string prefix = "prefix";
	std::vector<std::string> packageURIs;
	packageURIs.push_back(uri);

	// create a creator for TestModelPlugins
	SBaseExtensionPoint modelExtPoint("core",SBML_MODEL);
	SBasePluginCreator<TestModelPlugin,   TestExtension> modelPluginCreator(modelExtPoint,packageURIs);


  SBasePluginCreatorBase_t* base = SBasePluginCreator_clone(&modelPluginCreator);
  fail_unless(base != NULL);

 	fail_unless(SBasePluginCreator_getNumOfSupportedPackageURI(base) == 1);

  char * pkgURI = SBasePluginCreator_getSupportedPackageURI(base, 0); 
  fail_unless(strcmp(pkgURI, uri.c_str()) == 0);		
  safe_free(pkgURI);

  pkgURI = SBasePluginCreator_getSupportedPackageURI(base, 1000); 
  fail_unless(strcmp(pkgURI, "") == 0);		
  safe_free(pkgURI);

  char * name = SBaseExtensionPoint_getPackageName(&modelExtPoint);
  fail_unless(strcmp(SBasePluginCreator_getTargetPackageName(base), name ) == 0);	
  safe_free(name);

  fail_unless(SBasePluginCreator_getTargetSBMLTypeCode(base) == 
    SBaseExtensionPoint_getTypeCode(&modelExtPoint) );		
	
  fail_unless(SBasePluginCreator_isSupported(base, uri.c_str()) == 1);		

  fail_unless(SBasePluginCreator_free(base) == LIBSBML_OPERATION_SUCCESS);
	
}
END_TEST

Suite *
create_suite_SBasePluginCreatorBase (void)
{
  Suite *suite = suite_create("SBasePluginCreatorBase");
  TCase *tcase = tcase_create("SBasePluginCreatorBase");
	
  tcase_add_test( tcase, test_SBasePluginCreatorBase_create );
  tcase_add_test( tcase, test_SBasePluginCreatorBase_c_api );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

