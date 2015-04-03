/**
 * \file    TestXMLToken_newSetters.c
 * \brief   XMLToken_newSetters unit tests
 * \author  Sarah Keating
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
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLTriple.h>


#include <sbml/common/extern.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST(test_XMLToken_newSetters_setAttributes1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLAttributes_t* nattr  = XMLAttributes_create();

  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");

  XMLAttributes_addWithTriple(nattr, xt1, "val1");

  /*-- test of setting attributes -- */

  int i = XMLToken_setAttributes(token, nattr);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLToken_isAttributesEmpty(token)   == 0 );

  /*-- teardown --*/

  XMLAttributes_free(nattr);
  XMLAttributes_free(attr);
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLTriple_free(xt1);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setAttributes2)
{
  int i ;
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t*      token  = XMLToken_createWithTriple(triple);
  XMLAttributes_t* nattr  = XMLAttributes_create();

  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");

  XMLAttributes_addWithTriple(nattr, xt1, "val1");

  /*-- test of setting attributes with NULL value -- */
  i = XMLToken_setAttributes(token, NULL);

  fail_unless ( i == LIBSBML_INVALID_OBJECT);

  /*-- test of setting attributes -- */

  i = XMLToken_setAttributes(token, nattr);

  fail_unless ( i == LIBSBML_INVALID_XML_OPERATION);
  fail_unless(XMLToken_isAttributesEmpty(token)   == 1 );


  /*-- teardown --*/

  XMLAttributes_free(nattr);
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLTriple_free(xt1);
}
END_TEST


START_TEST(test_XMLToken_newSetters_clearAttributes1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLAttributes_t* nattr  = XMLAttributes_create();

  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");

  XMLAttributes_addWithTriple(nattr, xt1, "val1");

  /*-- test of setting attributes -- */

  int i = XMLToken_setAttributes(token, nattr);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLToken_isAttributesEmpty(token)   == 0 );

  i = XMLToken_clearAttributes(token);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLToken_isAttributesEmpty(token)   == 1 );
  /*-- teardown --*/

  XMLAttributes_free(nattr);
  XMLAttributes_free(attr);
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLTriple_free(xt1);
}
END_TEST


START_TEST(test_XMLToken_newSetters_addAttributes1)
{
  const char * test;
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLTriple_t* xt2    = XMLTriple_createWith("name3", 
                                             "http://name3.org/", "p3");
  /*-- test of adding attributes --*/

  int i = XMLToken_addAttr(token, "name1", "val1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLToken_getAttributesLength(token) == 1 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );

  test = XMLToken_getAttrName  (token, 0);
  fail_unless( strcmp(test, "name1") == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrValue (token, 0);
  fail_unless( strcmp(test, "val1" ) == 0 );
  safe_free((void*)(test));


  i = XMLToken_addAttrWithNS(token, "name2", "val2", 
                                             "http://name1.org/", "p1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLToken_getAttributesLength(token) == 2 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );

  test = XMLToken_getAttrName  (token, 1);
  fail_unless( strcmp(test, "name2") == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrValue (token, 1);
  fail_unless( strcmp(test, "val2" ) == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrURI   (token, 1);
  fail_unless( strcmp(test, "http://name1.org/") == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrPrefix(token, 1);
  fail_unless( strcmp(test, "p1"   ) == 0 );
  safe_free((void*)(test));


  i = XMLToken_addAttrWithTriple(token, xt2, "val2");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLToken_getAttributesLength(token) == 3 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );

  test = XMLToken_getAttrName  (token, 2);
  fail_unless( strcmp(test, "name3") == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrValue (token, 2);
  fail_unless( strcmp(test, "val2" ) == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrURI   (token, 2);
  fail_unless( strcmp(test, "http://name3.org/") == 0 );
  safe_free((void*)(test));

  test = XMLToken_getAttrPrefix(token, 2);
  fail_unless( strcmp(test, "p3"   ) == 0 );
  safe_free((void*)(test));


  /*-- teardown --*/

  XMLTriple_free(xt2);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_addAttributes2)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t*      token  = XMLToken_createWithTriple(triple);

  XMLTriple_t* xt2    = XMLTriple_createWith("name3", 
                                             "http://name3.org/", "p3");
  /*-- test of adding attributes --*/

  int i = XMLToken_addAttr(token, "name1", "val1");

  fail_unless( i == LIBSBML_INVALID_XML_OPERATION );
  fail_unless( XMLToken_getAttributesLength(token) == 0 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 1 );

  i = XMLToken_addAttrWithNS(token, "name2", "val2", 
                                             "http://name1.org/", "p1");

  fail_unless( i == LIBSBML_INVALID_XML_OPERATION );
  fail_unless( XMLToken_getAttributesLength(token) == 0 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 1 );

  i = XMLToken_addAttrWithTriple(token, xt2, "val2");

  fail_unless( i == LIBSBML_INVALID_XML_OPERATION );
  fail_unless( XMLToken_getAttributesLength(token) == 0 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 1 );

  /*-- teardown --*/

  XMLTriple_free(xt2);
  XMLTriple_free(triple);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setNamespaces1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLNamespaces_t* ns = XMLNamespaces_create();

  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- test of setting namespaces -- */
  XMLNamespaces_add(ns, "http://test1.org/", "test1"); 

  int i =   XMLToken_setNamespaces(token, ns);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 0 );  

  /*-- teardown --*/

  XMLAttributes_free(attr);
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLNamespaces_free(ns);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setNamespaces2)
{
  int i;
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t*      token  = XMLToken_createWithTriple(triple);
  XMLNamespaces_t* ns = XMLNamespaces_create();

  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- test of setting namespaces -- */
  XMLNamespaces_add(ns, "http://test1.org/", "test1"); 

  
  /*-- test of setting namespaces with NULL value -- */
  i = XMLToken_setNamespaces(token, NULL);

  fail_unless ( i == LIBSBML_INVALID_OBJECT);


  /*-- test of setting namespaces -- */
  i =   XMLToken_setNamespaces(token, ns);

  fail_unless ( i == LIBSBML_INVALID_XML_OPERATION);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- teardown --*/

  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLNamespaces_free(ns);
}
END_TEST


START_TEST(test_XMLToken_newSetters_clearNamespaces1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLNamespaces_t* ns = XMLNamespaces_create();

  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- test of setting namespaces -- */
  XMLNamespaces_add(ns, "http://test1.org/", "test1"); 

  int i =   XMLToken_setNamespaces(token, ns);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 0 );  

  i = XMLToken_clearNamespaces(token);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- teardown --*/

  XMLAttributes_free(attr);
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLNamespaces_free(ns);
}
END_TEST


START_TEST(test_XMLToken_newSetters_addNamespaces1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- test of setting namespaces -- */
  int i =  XMLToken_addNamespace(token, "http://test1.org/", "test1");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 0 );  

  /*-- teardown --*/

  XMLAttributes_free(attr);
  XMLTriple_free(triple);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_addNamespaces2)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t*      token  = XMLToken_createWithTriple(triple);
  
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- test of setting namespaces -- */
  int i =   XMLToken_addNamespace(token, "http://test1.org/", "test1");

  fail_unless ( i == LIBSBML_INVALID_XML_OPERATION);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  /*-- teardown --*/

  XMLTriple_free(triple);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setTriple1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t*      token  = XMLToken_create();
  
  /*-- test of setting triple -- */
  int i =   XMLToken_setTriple(token, triple);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(XMLToken_getName(token), "test") );

  /*-- teardown --*/

  XMLTriple_free(triple);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setTriple2)
{
  int i;
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLToken_t *token = XMLToken_createWithText("This is text");
  
    
  /*-- test of setting triple with NULL value -- */
  i = XMLToken_setTriple(token, NULL);

  fail_unless ( i == LIBSBML_INVALID_OBJECT);

  
  /*-- test of setting triple -- */
  i =   XMLToken_setTriple(token, triple);

  fail_unless ( i == LIBSBML_INVALID_XML_OPERATION);

  /*-- teardown --*/

  XMLTriple_free(triple);
  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setEnd)
{
  /*-- setup --*/

  XMLToken_t*      token  = XMLToken_create();
  fail_unless( XMLToken_isEnd(token) == 0 );
  
  /*-- test of setting end -- */
  int i =   XMLToken_setEnd(token);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_isEnd(token) == 1 );

  i =   XMLToken_unsetEnd(token);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_isEnd(token) == 0 );
  /*-- teardown --*/

  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_setEOF)
{
  /*-- setup --*/

  XMLToken_t*      token  = XMLToken_create();
  fail_unless( XMLToken_isEnd(token) == 0 );
  
  /*-- test of setting eof -- */
  int i =   XMLToken_setEOF(token);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_isEnd(token) == 0 );
  fail_unless( XMLToken_isStart(token) == 0 );
  fail_unless( XMLToken_isText(token) == 0 );

  /*-- teardown --*/

  XMLToken_free(token);
}
END_TEST


START_TEST(test_XMLToken_newSetters_removeAttributes1)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLTriple_t* xt2    = XMLTriple_createWith("name3", 
                                             "http://name3.org/", "p3");
  XMLTriple_t* xt1    = XMLTriple_createWith("name5", 
                                             "http://name5.org/", "p5");
  int i = XMLToken_addAttr(token, "name1", "val1");
  i = XMLToken_addAttrWithNS(token, "name2", "val2", 
                                             "http://name1.org/", "p1");
  i = XMLToken_addAttrWithTriple(token, xt2, "val2");
  i = XMLToken_addAttr(token, "name4", "val4");

  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 4);

  i = XMLToken_removeAttr(token, 7);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLToken_removeAttrByName(token, "name7");

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLToken_removeAttrByNS(token, "name7", "namespaces7");

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLToken_removeAttrByTriple(token, xt1);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );
  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 4);

  i = XMLToken_removeAttr(token, 3);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 3);

  i = XMLToken_removeAttrByName(token, "name1");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 2);

  i = XMLToken_removeAttrByNS(token, "name2", "http://name1.org/");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 1);

  i = XMLToken_removeAttrByTriple(token, xt2);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLToken_getAttributes(token)) == 0);

  /*-- teardown --*/

  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLToken_free(token);
}
END_TEST


START_TEST (test_XMLToken_newSetters_removeNamespaces)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLToken_addNamespace(token, "http://test1.org/", "test1"); 

  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  
  int i = XMLToken_removeNamespace(token, 4);
  
  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  
  i = XMLToken_removeNamespace(token, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_newSetters_removeNamespaces1)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLToken_addNamespace(token, "http://test1.org/", "test1"); 

  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  
  int i = XMLToken_removeNamespaceByPrefix(token, "test2");
  
  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  
  i = XMLToken_removeNamespaceByPrefix(token, "test1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


Suite *
create_suite_XMLToken_newSetters (void)
{
  Suite *suite = suite_create("XMLToken_newSetters");
  TCase *tcase = tcase_create("XMLToken_newSetters");

  tcase_add_test( tcase, test_XMLToken_newSetters_setAttributes1);
  tcase_add_test( tcase, test_XMLToken_newSetters_setAttributes2);
  tcase_add_test( tcase, test_XMLToken_newSetters_clearAttributes1);
  tcase_add_test( tcase, test_XMLToken_newSetters_addAttributes1);
  tcase_add_test( tcase, test_XMLToken_newSetters_addAttributes2);
  tcase_add_test( tcase, test_XMLToken_newSetters_setNamespaces1);
  tcase_add_test( tcase, test_XMLToken_newSetters_setNamespaces2);
  tcase_add_test( tcase, test_XMLToken_newSetters_clearNamespaces1);
  tcase_add_test( tcase, test_XMLToken_newSetters_addNamespaces1);
  tcase_add_test( tcase, test_XMLToken_newSetters_addNamespaces2);
  tcase_add_test( tcase, test_XMLToken_newSetters_setTriple1);
  tcase_add_test( tcase, test_XMLToken_newSetters_setTriple2);
  tcase_add_test( tcase, test_XMLToken_newSetters_setEnd);
  tcase_add_test( tcase, test_XMLToken_newSetters_setEOF);
  tcase_add_test( tcase, test_XMLToken_newSetters_removeAttributes1);
  tcase_add_test( tcase, test_XMLToken_newSetters_removeNamespaces);
  tcase_add_test( tcase, test_XMLToken_newSetters_removeNamespaces1);

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif

