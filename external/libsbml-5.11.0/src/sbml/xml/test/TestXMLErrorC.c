/**
 * @file    TestXMLError.c
 * @brief   XMLError unit tests, C version
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
#include <sbml/xml/XMLError.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART
#endif

START_TEST (test_XMLError_create_C)
{
  XMLError_t *error = XMLError_create();
  fail_unless(error != NULL);
  fail_unless(XMLError_isInfo(error) == 0);
  fail_unless(XMLError_isWarning(error) == 0);
  fail_unless(XMLError_isError(error) == 0);
  fail_unless(XMLError_isFatal(error) == 1);
  XMLError_free(error);

  error = XMLError_createWithIdAndMessage(12345, "My message");
  fail_unless( strcmp(XMLError_getMessage(error), "My message") == 0 );
  fail_unless( XMLError_getErrorId(error) == 12345 );
  XMLError_free(error);
}
END_TEST


START_TEST (test_XMLError_variablesAsStrings)
{
  XMLError_t *error = XMLError_createWithIdAndMessage(1003, "");
  
  fail_unless( XMLError_getErrorId(error)  == 1003 );
  fail_unless( XMLError_getSeverity(error) == LIBSBML_SEV_ERROR );
  fail_unless( !strcmp(XMLError_getSeverityAsString(error), "Error") );
  fail_unless( XMLError_getCategory(error) == LIBSBML_CAT_XML );
  fail_unless( !strcmp(XMLError_getCategoryAsString(error), "XML content"));

  XMLError_free(error);
}
END_TEST

START_TEST (test_XMLError_accessWithNULL)
{
  // survive NULL arguments  
  XMLError_free(NULL);

  fail_unless( XMLError_createWithIdAndMessage(0, NULL) == NULL);
  fail_unless( XMLError_getCategory(NULL) == SBML_INT_MAX);
  fail_unless( XMLError_getCategoryAsString(NULL) == NULL);
  fail_unless( XMLError_getColumn(NULL) == 0);
  fail_unless( XMLError_getErrorId(NULL) == SBML_INT_MAX);
  fail_unless( XMLError_getLine(NULL) == 0);
  fail_unless( XMLError_getMessage(NULL) == NULL);
  fail_unless( XMLError_getSeverity(NULL) == SBML_INT_MAX);
  fail_unless( XMLError_getSeverityAsString(NULL) == NULL);
  fail_unless( XMLError_getShortMessage(NULL) == NULL);
  fail_unless( XMLError_isError(NULL) == 0);
  fail_unless( XMLError_isFatal(NULL) == 0);
  fail_unless( XMLError_isInfo(NULL) == 0);
  fail_unless( XMLError_isWarning(NULL) == 0);

  XMLError_print(NULL, NULL); 

}
END_TEST

Suite *
create_suite_XMLError_C (void)
{
  Suite *suite = suite_create("XMLErrorC");
  TCase *tcase = tcase_create("XMLErrorC");

  tcase_add_test( tcase, test_XMLError_create_C  );
  tcase_add_test( tcase, test_XMLError_variablesAsStrings  );
  tcase_add_test( tcase, test_XMLError_accessWithNULL     );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif


