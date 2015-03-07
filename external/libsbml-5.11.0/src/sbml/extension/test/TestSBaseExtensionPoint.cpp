/**
 * \file    TestSBaseExtensionPoint.cpp
 * \brief   SBaseExtensionPoint unit tests
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

#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

#include <sbml/SBMLTypes.h>

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST (test_SBaseExtensionPoint_create)
{
	SBaseExtensionPoint point ("test", 10);
	fail_unless( point.getTypeCode() == 10 );	
	fail_unless( strcmp(point.getPackageName().c_str(), "test") == 0 );
}
END_TEST

START_TEST (test_SBaseExtensionPoint_clone)
{
	SBaseExtensionPoint point ("test", 10);
	SBaseExtensionPoint *clone = point.clone();
	fail_unless( clone->getTypeCode() == 10 );	
	fail_unless( strcmp(clone->getPackageName().c_str(), "test") == 0 );
	delete clone;
}
END_TEST

START_TEST (test_SBaseExtensionPoint_operators)
{
	SBaseExtensionPoint point1 ("test", 10);
	SBaseExtensionPoint point2 ("test", 11);
	SBaseExtensionPoint *clone = point1.clone();
	
	fail_unless( point1 == (*clone) );	
	fail_unless( !( point1 == point2 ) );	
	fail_unless( point1 < point2 );	

	delete clone;
}
END_TEST


START_TEST (test_SBaseExtensionPoint_c_api)
{
  SBaseExtensionPoint_t *ext = SBaseExtensionPoint_create("test", 10); 
  fail_unless(ext != NULL);
  
  char * name = SBaseExtensionPoint_getPackageName(ext);  
  fail_unless(strcmp(name, "test") == 0);
  fail_unless(SBaseExtensionPoint_getTypeCode(ext) == 10);
  safe_free(name);


  SBaseExtensionPoint_t *ext2 = SBaseExtensionPoint_clone(ext);
  fail_unless(ext2 != NULL);

  name = SBaseExtensionPoint_getPackageName(ext2);
  fail_unless(strcmp(name, "test") == 0);
  fail_unless(SBaseExtensionPoint_getTypeCode(ext2) == 10);
  safe_free(name);

  SBaseExtensionPoint_free(ext);
  SBaseExtensionPoint_free(ext2);

  fail_unless(SBaseExtensionPoint_create(NULL, 0) == NULL);
  fail_unless(SBaseExtensionPoint_clone(NULL) == NULL);
  fail_unless(SBaseExtensionPoint_free(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless(SBaseExtensionPoint_getPackageName(NULL) == NULL);
  fail_unless(SBaseExtensionPoint_getTypeCode(NULL) == LIBSBML_INVALID_OBJECT);
}
END_TEST

Suite *
create_suite_SBaseExtensionPoint (void)
{
  Suite *suite = suite_create("SBaseExtensionPoint");
  TCase *tcase = tcase_create("SBaseExtensionPoint");
	
  tcase_add_test( tcase, test_SBaseExtensionPoint_create );
  tcase_add_test( tcase, test_SBaseExtensionPoint_clone );
  tcase_add_test( tcase, test_SBaseExtensionPoint_operators );
  tcase_add_test( tcase, test_SBaseExtensionPoint_c_api );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS
