/**
 * \file    TestXMLNamespaces.c
 * \brief   XMLNamespaces unit tests
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
#include <sbml/xml/XMLNamespaces.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

static XMLNamespaces_t *NS;

void
XMLNamespacesTest_setup (void)
{
  NS = XMLNamespaces_create();

  if (NS == NULL)
  {
    fail("XMLNamespacesTest_setup() failed to create a XMLNamespaces object.");
  }
}

void
XMLNamespacesTest_teardown (void)
{
  XMLNamespaces_free(NS);
}


START_TEST (test_XMLNamespaces_baseline)
{
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 1 );
}
END_TEST


START_TEST (test_XMLNamespaces_add)
{
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 1 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1");
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1a");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1a");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );


  fail_if( XMLNamespaces_getIndex(NS, "http://test1.org/") == -1);
}
END_TEST


START_TEST (test_XMLNamespaces_add1)
{
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 1 );

  int i = XMLNamespaces_add(NS, "http://test1.org/", "test1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 0), "test1") == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefixByURI(NS, "http://test1.org/"),
		      "test1") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 0), "http://test1.org/") == 0 );

  // add with existing prefix
  i = XMLNamespaces_add(NS, "http://test2.org/", "test1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 0), "test1") == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefixByURI(NS, "http://test2.org/"),
		      "test1") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 0), "http://test2.org/") == 0 );

  // add 
  i = XMLNamespaces_add(NS, "http://test.org/", "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( XMLNamespaces_getPrefix(NS, 1) == NULL );
  fail_unless( XMLNamespaces_getPrefixByURI(NS, "http://test.org/") == NULL);
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 1), "http://test.org/") == 0 );

  // add repeat with empty prefix
  i = XMLNamespaces_add(NS, "http://test3.org/", "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( XMLNamespaces_getPrefix(NS, 1) == NULL );
  fail_unless( XMLNamespaces_getPrefixByURI(NS, "http://test3.org/") == NULL);
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 1), "http://test3.org/") == 0 );

  // add sbml ns
  i = XMLNamespaces_add(NS, "http://www.sbml.org/sbml/level1", "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( XMLNamespaces_getPrefix(NS, 1) == NULL );
  fail_unless( XMLNamespaces_getPrefixByURI(NS, 
                     "http://www.sbml.org/sbml/level1") == NULL);
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 1), 
    "http://www.sbml.org/sbml/level1") == 0 );

  // add a repeat of the sbml prefix ns
  i = XMLNamespaces_add(NS, "http://test_sbml_prefix/", "");

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( XMLNamespaces_getPrefix(NS, 1) == NULL );
  fail_unless( XMLNamespaces_getPrefixByURI(NS, 
                     "http://www.sbml.org/sbml/level1") == NULL);
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 1), 
    "http://www.sbml.org/sbml/level1") == 0 );

  // add repeat sbml ns uri
  i = XMLNamespaces_add(NS, "http://www.sbml.org/sbml/level1", "newprefix");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 2), "newprefix") == 0 );
  // this fails because the search finds the uri with the empty prefix first
  fail_unless( XMLNamespaces_getPrefixByURI(NS, 
                     "http://www.sbml.org/sbml/level1") == NULL);
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 2), 
    "http://www.sbml.org/sbml/level1") == 0 );

  // add repeat prefix
  i = XMLNamespaces_add(NS, "http://www.foo", "newprefix");

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 2), "newprefix") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 2), 
    "http://www.sbml.org/sbml/level1") == 0 );


  // change sbml ns uri - it will not do this
  i = XMLNamespaces_add(NS, "http://www.sbml.org/sbml/level2", "newprefix");

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 2), "newprefix") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 2), 
    "http://www.sbml.org/sbml/level1") == 0 );



}
END_TEST


START_TEST (test_XMLNamespaces_add2)
{
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 1 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1");
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1a");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1a");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  fail_unless( XMLNamespaces_isEmpty(NS) == 0 );


  fail_if( XMLNamespaces_getIndex(NS, "http://test1.org/") == -1);
}
END_TEST


START_TEST (test_XMLNamespaces_get)
{
  XMLNamespaces_add(NS, "http://test1.org/", "test1");    /* index 0 */
  XMLNamespaces_add(NS, "http://test2.org/", "test2");    /* index 1 */
  XMLNamespaces_add(NS, "http://test3.org/", "test3");    /* index 2 */
  XMLNamespaces_add(NS, "http://test4.org/", "test4");    /* index 3 */
  XMLNamespaces_add(NS, "http://test5.org/", "test5");    /* index 4 */
  XMLNamespaces_add(NS, "http://test6.org/", "test6");    /* index 5 */
  XMLNamespaces_add(NS, "http://test7.org/", "test7");    /* index 6 */
  XMLNamespaces_add(NS, "http://test8.org/", "test8");    /* index 7 */
  XMLNamespaces_add(NS, "http://test9.org/", "test9");    /* index 8 */

  fail_unless( XMLNamespaces_getLength(NS) == 9 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 9 );

  fail_unless( XMLNamespaces_getIndex(NS, "http://test1.org/") == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefix(NS, 1), "test2") == 0 );
  fail_unless( strcmp(XMLNamespaces_getPrefixByURI(NS, "http://test1.org/"),
		      "test1") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURI(NS, 1), "http://test2.org/") == 0 );
  fail_unless( strcmp(XMLNamespaces_getURIByPrefix(NS, "test2"),
		      "http://test2.org/") == 0 );

  fail_unless( XMLNamespaces_getIndex(NS, "http://test1.org/") ==  0 );
  fail_unless( XMLNamespaces_getIndex(NS, "http://test2.org/") ==  1 );
  fail_unless( XMLNamespaces_getIndex(NS, "http://test5.org/") ==  4 );
  fail_unless( XMLNamespaces_getIndex(NS, "http://test9.org/") ==  8 );
  fail_unless( XMLNamespaces_getIndex(NS, "http://testX.org/") == -1 );

  fail_unless( XMLNamespaces_hasURI(NS, "http://test1.org/") !=  0 );
  fail_unless( XMLNamespaces_hasURI(NS, "http://test2.org/") !=  0 );
  fail_unless( XMLNamespaces_hasURI(NS, "http://test5.org/") !=  0 );
  fail_unless( XMLNamespaces_hasURI(NS, "http://test9.org/") !=  0 );
  fail_unless( XMLNamespaces_hasURI(NS, "http://testX.org/") ==  0 );

  fail_unless( XMLNamespaces_getIndexByPrefix(NS, "test1") ==  0 );
  fail_unless( XMLNamespaces_getIndexByPrefix(NS, "test5") ==  4 );
  fail_unless( XMLNamespaces_getIndexByPrefix(NS, "test9") ==  8 );
  fail_unless( XMLNamespaces_getIndexByPrefix(NS, "testX") == -1 );

  fail_unless( XMLNamespaces_hasPrefix(NS, "test1") !=  0 );
  fail_unless( XMLNamespaces_hasPrefix(NS, "test5") !=  0 );
  fail_unless( XMLNamespaces_hasPrefix(NS, "test9") !=  0 );
  fail_unless( XMLNamespaces_hasPrefix(NS, "testX") ==  0 );

  fail_unless( XMLNamespaces_hasNS(NS, "http://test1.org/", "test1") !=  0 );
  fail_unless( XMLNamespaces_hasNS(NS, "http://test5.org/", "test5") !=  0 );
  fail_unless( XMLNamespaces_hasNS(NS, "http://test9.org/", "test9") !=  0 );
  fail_unless( XMLNamespaces_hasNS(NS, "http://testX.org/", "testX") ==  0 );
}
END_TEST


START_TEST (test_XMLNamespaces_remove)
{
  XMLNamespaces_add(NS, "http://test1.org/", "test1"); 
  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  XMLNamespaces_add(NS, "http://test3.org/", "test3"); 
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 5 );
  XMLNamespaces_remove(NS, 4);
  fail_unless( XMLNamespaces_getLength(NS) == 4 );
  XMLNamespaces_remove(NS, 3);
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  XMLNamespaces_remove(NS, 2);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  XMLNamespaces_remove(NS, 1);
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1");
  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  XMLNamespaces_add(NS, "http://test3.org/", "test3");
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 5 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 4 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 2 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  XMLNamespaces_remove(NS, 0);
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
  fail_unless( XMLNamespaces_getNumNamespaces(NS) == 0 );

}
END_TEST


START_TEST (test_XMLNamespaces_remove_by_prefix)
{
  XMLNamespaces_add(NS, "http://test1.org/", "test1"); 
  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  XMLNamespaces_add(NS, "http://test3.org/", "test3"); 
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );
  XMLNamespaces_removeByPrefix(NS, "test1");
  fail_unless( XMLNamespaces_getLength(NS) == 4 );
  XMLNamespaces_removeByPrefix(NS, "test2");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  XMLNamespaces_removeByPrefix(NS, "test3");
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  XMLNamespaces_removeByPrefix(NS, "test4");
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  XMLNamespaces_removeByPrefix(NS, "test5");
  fail_unless( XMLNamespaces_getLength(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1");
  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  XMLNamespaces_add(NS, "http://test3.org/", "test3");
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );
  XMLNamespaces_removeByPrefix(NS, "test5");
  fail_unless( XMLNamespaces_getLength(NS) == 4 );
  XMLNamespaces_removeByPrefix(NS, "test4");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  XMLNamespaces_removeByPrefix(NS, "test3");
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  XMLNamespaces_removeByPrefix(NS, "test2");
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  XMLNamespaces_removeByPrefix(NS, "test1");
  fail_unless( XMLNamespaces_getLength(NS) == 0 );

  XMLNamespaces_add(NS, "http://test1.org/", "test1"); 
  XMLNamespaces_add(NS, "http://test2.org/", "test2"); 
  XMLNamespaces_add(NS, "http://test3.org/", "test3");
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );
  XMLNamespaces_removeByPrefix(NS, "test3");
  fail_unless( XMLNamespaces_getLength(NS) == 4 );
  XMLNamespaces_removeByPrefix(NS, "test1");
  fail_unless( XMLNamespaces_getLength(NS) == 3 );
  XMLNamespaces_removeByPrefix(NS, "test4");
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  XMLNamespaces_removeByPrefix(NS, "test5");
  fail_unless( XMLNamespaces_getLength(NS) == 1 );
  XMLNamespaces_removeByPrefix(NS, "test2");
  fail_unless( XMLNamespaces_getLength(NS) == 0 );

}
END_TEST


START_TEST (test_XMLNamespaces_remove1)
{
  XMLNamespaces_add(NS, "http://test1.org/", "test1"); 
  XMLNamespaces_add(NS, "http://test2.org/", "test2");

  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  
  int i = XMLNamespaces_remove(NS, 4);
  
  fail_unless (i == LIBSBML_INDEX_EXCEEDS_SIZE );
  fail_unless( XMLNamespaces_getLength(NS) == 2 );
  
  i = XMLNamespaces_removeByPrefix(NS, "test4");

  fail_unless (i == LIBSBML_INDEX_EXCEEDS_SIZE );
  fail_unless( XMLNamespaces_getLength(NS) == 2 );

  i = XMLNamespaces_remove(NS, 1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLNamespaces_getLength(NS) == 1 );

  i = XMLNamespaces_removeByPrefix(NS, "test1");

  fail_unless (i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
}
END_TEST


START_TEST (test_XMLNamespaces_clear)
{
  XMLNamespaces_add(NS, "http://test1.org/", "test1"); 
  XMLNamespaces_add(NS, "http://test2.org/", "test2");
  XMLNamespaces_add(NS, "http://test3.org/", "test3"); 
  XMLNamespaces_add(NS, "http://test4.org/", "test4");
  XMLNamespaces_add(NS, "http://test5.org/", "test5");

  fail_unless( XMLNamespaces_getLength(NS) == 5 );

  int i = XMLNamespaces_clear(NS);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLNamespaces_getLength(NS) == 0 );
}
END_TEST

START_TEST (test_XMLNamespaces_accessWithNULL)
{
  fail_unless( XMLNamespaces_add(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNamespaces_clear(NULL) == LIBSBML_OPERATION_FAILED);
  fail_unless( XMLNamespaces_clone(NULL) == NULL);

  XMLNamespaces_free(NULL);

  fail_unless( XMLNamespaces_getIndex(NULL, NULL) == -1);
  fail_unless( XMLNamespaces_getIndexByPrefix(NULL, NULL) == -1);
  fail_unless( XMLNamespaces_getLength(NULL) == 0);
  fail_unless( XMLNamespaces_getPrefix(NULL, 0) == NULL);
  fail_unless( XMLNamespaces_getPrefixByURI(NULL, NULL) == NULL);
  fail_unless( XMLNamespaces_getURI(NULL, 0) == NULL);
  fail_unless( XMLNamespaces_getURIByPrefix(NULL, NULL) == NULL);
  fail_unless( XMLNamespaces_hasNS(NULL, NULL, NULL) == 0);
  fail_unless( XMLNamespaces_hasPrefix(NULL, NULL) == 0);
  fail_unless( XMLNamespaces_hasURI(NULL, NULL) == 0);
  fail_unless( XMLNamespaces_isEmpty(NULL) == 1);
  fail_unless( XMLNamespaces_remove(NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNamespaces_removeByPrefix(NULL, NULL) == LIBSBML_INVALID_OBJECT);
}
END_TEST

Suite *
create_suite_XMLNamespaces (void)
{
  Suite *suite = suite_create("XMLNamespaces");
  TCase *tcase = tcase_create("XMLNamespaces");

  tcase_add_checked_fixture( tcase,
                             XMLNamespacesTest_setup,
                             XMLNamespacesTest_teardown );

  tcase_add_test( tcase, test_XMLNamespaces_baseline         );
  tcase_add_test( tcase, test_XMLNamespaces_add              );
  tcase_add_test( tcase, test_XMLNamespaces_add1             );
  tcase_add_test( tcase, test_XMLNamespaces_add2             );
  tcase_add_test( tcase, test_XMLNamespaces_get              );
  tcase_add_test( tcase, test_XMLNamespaces_remove           );
  tcase_add_test( tcase, test_XMLNamespaces_remove_by_prefix );
  tcase_add_test( tcase, test_XMLNamespaces_remove1          );
  tcase_add_test( tcase, test_XMLNamespaces_clear            );
  tcase_add_test( tcase, test_XMLNamespaces_accessWithNULL   );
  
  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif

