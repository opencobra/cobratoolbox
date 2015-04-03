/**
 * \file    TestXMLTriple.c
 * \brief   XMLTriple unit tests
 * \author  Michael Hucka <mhucka@caltech.edu>
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
#include <sbml/xml/XMLTriple.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_XMLTriple_create)
{
  const char * test;
  XMLTriple_t *t = XMLTriple_create();
  fail_unless(t != NULL);
  fail_unless(XMLTriple_isEmpty(t) != 0);
  XMLTriple_free(t);

  t = XMLTriple_createWith("attr", "uri", "prefix");

  test = XMLTriple_getName(t);
  fail_unless( strcmp(test, "attr") == 0 );

  test = XMLTriple_getURI(t);
  fail_unless( strcmp(test, "uri") == 0 );
  
  test = XMLTriple_getPrefix(t);
  fail_unless( strcmp(test, "prefix") == 0 );

  test = XMLTriple_getPrefixedName(t);
  fail_unless( strcmp(test, "prefix:attr") == 0 );
  
  fail_unless(XMLTriple_isEmpty(t) == 0);
  
  safe_free((void*)(test));

  XMLTriple_free(t);

  t = XMLTriple_createWith("attr", "uri", "");

  test = XMLTriple_getName(t);
  fail_unless( strcmp(test, "attr") == 0 );

  test = XMLTriple_getURI(t);
  fail_unless( strcmp(XMLTriple_getURI(t), "uri") == 0 );

  fail_unless( XMLTriple_getPrefix(t) == NULL );
  
  test = XMLTriple_getPrefixedName(t);
  fail_unless( strcmp(test, "attr") == 0 );

  fail_unless(XMLTriple_isEmpty(t) == 0);

  safe_free((void*)(test));
  
  XMLTriple_free(t);
}
END_TEST


START_TEST (test_XMLTriple_comparison)
{
  XMLTriple_t *t1 = XMLTriple_createWith("attr", "uri", "prefix");
  XMLTriple_t *t2 = XMLTriple_createWith("attr", "uri", "prefix");
  XMLTriple_t *t3 = XMLTriple_createWith("diff", "diff", "diff");

  fail_unless( XMLTriple_equalTo(t1, t2) != 0 );
  fail_unless( XMLTriple_equalTo(t1, t3) == 0 );
  fail_unless( XMLTriple_equalTo(t2, t3) == 0 );
  fail_unless( XMLTriple_notEqualTo(t1, t2) == 0 );
  fail_unless( XMLTriple_notEqualTo(t1, t3) != 0 );
  fail_unless( XMLTriple_notEqualTo(t2, t3) != 0 );

  XMLTriple_free(t1);
  XMLTriple_free(t2);
  XMLTriple_free(t3);
}
END_TEST

START_TEST (test_XMLTriple_accessWithNULL)
{
  XMLTriple_t * temp = XMLTriple_create();
  fail_unless( XMLTriple_clone(NULL) == NULL);
  fail_unless( XMLTriple_createWith(NULL, NULL, NULL) == NULL);
  fail_unless( XMLTriple_equalTo(NULL, NULL) == 1);
  fail_unless( XMLTriple_equalTo(NULL, temp) == 0);
  
  XMLTriple_free(NULL);
  
  fail_unless( XMLTriple_getName(NULL) == NULL);
  fail_unless( XMLTriple_getPrefix(NULL) == NULL);
  fail_unless( XMLTriple_getPrefixedName(NULL) == NULL);
  fail_unless( XMLTriple_getURI(NULL) == NULL);
  fail_unless( XMLTriple_isEmpty(NULL) == 1);
  fail_unless( XMLTriple_notEqualTo(NULL, temp) == 1);
  fail_unless( XMLTriple_notEqualTo(NULL, NULL) == 0);

  XMLTriple_free(temp);
}
END_TEST

Suite *
create_suite_XMLTriple (void)
{
  Suite *suite = suite_create("XMLTriple");
  TCase *tcase = tcase_create("XMLTriple");

  tcase_add_test( tcase, test_XMLTriple_create  );
  tcase_add_test( tcase, test_XMLTriple_comparison );
  tcase_add_test( tcase, test_XMLTriple_accessWithNULL );
  
  suite_add_tcase(suite, tcase);

  return suite;
}


#if defined(__cplusplus)
CK_CPPEND
#endif

