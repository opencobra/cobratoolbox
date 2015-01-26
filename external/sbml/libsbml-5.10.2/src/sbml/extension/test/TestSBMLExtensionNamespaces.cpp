/**
 * \file    TestSBMLExtensionNamespaces.cpp
 * \brief   SBMLExtensionNamespaces unit tests
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

START_TEST (test_SBMLExtensionNamespaces_create)
{
	TestPkgNamespaces ns;

	fail_unless(ns.getURI() == TestExtension::getXmlnsL3V1V1());
	fail_unless(ns.getPackageVersion() == TestExtension::getDefaultPackageVersion());
	fail_unless(ns.getPackageName() == TestExtension::getPackageName());

	ns.setPackageVersion(42);
	fail_unless(ns.getPackageVersion() == 42);

}
END_TEST

START_TEST (test_SBMLExtensionNamespaces_c_api)
{
  TestPkgNamespaces ns;
  SBMLExtensionNamespaces_t* extNs = SBMLExtensionNamespaces_clone(&ns);
  fail_unless( extNs != NULL);
  fail_unless(strcmp(SBMLExtensionNamespaces_getPackageName(extNs), 
    TestExtension::getPackageName().c_str()) == 0);
  fail_unless(SBMLExtensionNamespaces_getPackageVersion(extNs) ==  
    TestExtension::getDefaultPackageVersion());

  fail_unless(SBMLExtensionNamespaces_free(extNs) == LIBSBML_OPERATION_SUCCESS);
}
END_TEST

Suite *
create_suite_SBMLExtensionNamespaces (void)
{
  Suite *suite = suite_create("SBMLExtensionNamespaces");
  TCase *tcase = tcase_create("SBMLExtensionNamespaces");
	
  tcase_add_test( tcase, test_SBMLExtensionNamespaces_create );
  tcase_add_test( tcase, test_SBMLExtensionNamespaces_c_api );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

