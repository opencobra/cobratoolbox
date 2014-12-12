/**
 * \file    TestXMLNode_newSetters.c
 * \brief   XMLNode unit tests
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

#include <sbml/common/common.h>
#include <sbml/xml/XMLTriple.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLNamespaces.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART
#endif

START_TEST (test_XMLNode_addChild1)
{
  XMLNode_t *node = XMLNode_create();
  XMLNode_t *node2 = XMLNode_create();

  int i = XMLNode_addChild(node, node2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLNode_getNumChildren(node) == 1);

  XMLNode_free(node);
  XMLNode_free(node2);
}
END_TEST


START_TEST (test_XMLNode_addChild2)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t *node = XMLNode_createStartElement(triple, attr);
  XMLNode_t *node2 = XMLNode_create();

  int i = XMLNode_addChild(node, node2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLNode_getNumChildren(node) == 1);

  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(node);
  XMLNode_free(node2);
}
END_TEST


START_TEST (test_XMLNode_addChild3)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLNode_t *node = XMLNode_createEndElement(triple);
  XMLNode_t *node2 = XMLNode_create();

  int i = XMLNode_addChild(node, node2);

  fail_unless( i == LIBSBML_INVALID_XML_OPERATION);
  fail_unless(XMLNode_getNumChildren(node) == 0);

  XMLTriple_free(triple);
  XMLNode_free(node);
  XMLNode_free(node2);
}
END_TEST


START_TEST (test_XMLNode_removeChildren)
{
  XMLNode_t *node = XMLNode_create();
  XMLNode_t *node2 = XMLNode_create();
  XMLNode_t *node3 = XMLNode_create();

  XMLNode_addChild(node, node2);
  XMLNode_addChild(node, node3);

  fail_unless(XMLNode_getNumChildren(node) == 2);

  int i = XMLNode_removeChildren(node);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLNode_getNumChildren(node) == 0);

  XMLNode_free(node);
  XMLNode_free(node2);
  XMLNode_free(node3);
}
END_TEST


START_TEST(test_XMLNode_removeAttributes)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*      node  = XMLNode_createStartElement(triple, attr);

  XMLTriple_t* xt2    = XMLTriple_createWith("name3", 
                                             "http://name3.org/", "p3");
  XMLTriple_t* xt1    = XMLTriple_createWith("name5", 
                                             "http://name5.org/", "p5");
  int i = XMLNode_addAttr(node, "name1", "val1");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 1);

  i = XMLNode_addAttrWithNS(node, "name2", "val2", 
                                             "http://name1.org/", "p1");
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 2);

  i = XMLNode_addAttrWithTriple(node, xt2, "val2");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 3);

  i = XMLNode_addAttr(node, "name4", "val4");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 4);

  i = XMLNode_removeAttr(node, 7);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLNode_removeAttrByName(node, "name7");

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLNode_removeAttrByNS(node, "name7", "namespaces7");

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );

  i = XMLNode_removeAttrByTriple(node, xt1);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 4);

  i = XMLNode_removeAttr(node, 3);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 3);

  i = XMLNode_removeAttrByName(node, "name1");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 2);

  i = XMLNode_removeAttrByNS(node, "name2", "http://name1.org/");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 1);

  i = XMLNode_removeAttrByTriple(node, xt2);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 0);

  /*-- teardown --*/

  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(node);
}
END_TEST


START_TEST(test_XMLNode_clearAttributes)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*      node  = XMLNode_createStartElement(triple, attr);

  XMLTriple_t* xt2    = XMLTriple_createWith("name3", 
                                             "http://name3.org/", "p3");
  XMLTriple_t* xt1    = XMLTriple_createWith("name5", 
                                             "http://name5.org/", "p5");
  int i = XMLNode_addAttr(node, "name1", "val1");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 1);

  i = XMLNode_addAttrWithNS(node, "name2", "val2", 
                                             "http://name1.org/", "p1");
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 2);

  i = XMLNode_addAttrWithTriple(node, xt2, "val2");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 3);

  i = XMLNode_addAttr(node, "name4", "val4");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 4);

  i = XMLNode_clearAttributes(node);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless (XMLAttributes_getLength(XMLNode_getAttributes(node)) == 0);

  /*-- teardown --*/

  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(node);
}
END_TEST


START_TEST(test_XMLNode_removeNamespaces)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);
  const XMLNamespaces_t* nms;

  int i = XMLNode_addNamespace(node, "http://test1.org/", "test1");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 1);

  i = XMLNode_addNamespace(node, "http://test2.org/", "test2");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 2);

  i = XMLNode_removeNamespace(node, 7);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 2);

  i = XMLNode_removeNamespaceByPrefix(node, "name7");

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE );
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 2);

  i = XMLNode_removeNamespace(node, 0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 1);

  i = XMLNode_removeNamespaceByPrefix(node, "test2");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 0);

  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(node);
}
END_TEST


START_TEST(test_XMLNode_clearNamespaces)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);
  const XMLNamespaces_t* nms;

  int i = XMLNode_addNamespace(node, "http://test1.org/", "test1");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 1);

  i = XMLNode_addNamespace(node, "http://test2.org/", "test2");
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 2);

  i = XMLNode_clearNamespaces(node);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS );
  nms = XMLNode_getNamespaces(node);
  fail_unless (XMLNamespaces_getLength(nms) == 0);

  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(node);
}
END_TEST

START_TEST(test_XMLNode_accessWithNULL)
{
  fail_unless( XMLNode_addAttr(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_addAttrWithNS(NULL, NULL, NULL, NULL, NULL) 
    == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_addAttrWithTriple(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_addChild(NULL, NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_addNamespace(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_clearAttributes(NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_clearNamespaces(NULL) == LIBSBML_INVALID_OBJECT );
  fail_unless( XMLNode_clone(NULL) == NULL);
  fail_unless( XMLNode_convertStringToXMLNode(NULL, NULL) == NULL);
  fail_unless( XMLNode_convertXMLNodeToString(NULL) == NULL);
  fail_unless( XMLNode_createEndElement(NULL) == NULL);
  fail_unless( XMLNode_createFromToken(NULL) == NULL);
  fail_unless( XMLNode_createStartElement(NULL, NULL) == NULL);
  fail_unless( XMLNode_createStartElementNS(NULL, NULL, NULL) == NULL);
  fail_unless( XMLNode_equals(NULL, NULL) == 1);
  fail_unless( XMLNode_equals(NULL, XMLNode_createTextNode(NULL)) == 0);

  XMLNode_free(NULL);

  fail_unless( XMLNode_getAttributes(NULL) == NULL);
  fail_unless( XMLNode_getAttributesLength(NULL) == 0);
  fail_unless( XMLNode_getAttrIndex(NULL, NULL, NULL) == -1);
  fail_unless( XMLNode_getAttrIndexByTriple(NULL, NULL) == -1);
  fail_unless( XMLNode_getAttrName(NULL, 0) == NULL);
  fail_unless( XMLNode_getAttrPrefix(NULL, 0) == NULL);
  fail_unless( XMLNode_getAttrPrefixedName(NULL, 0) == NULL);
  fail_unless( XMLNode_getAttrURI(NULL, 0) == NULL);
  fail_unless( XMLNode_getAttrValue(NULL, 0) == NULL);
  fail_unless( XMLNode_getAttrValueByName(NULL, NULL) == NULL);
  fail_unless( XMLNode_getAttrValueByNS(NULL, NULL, NULL) == NULL);
  fail_unless( XMLNode_getAttrValueByTriple(NULL, NULL) == NULL);
  
  fail_unless( XMLNode_getCharacters(NULL) == NULL);
  
  fail_unless( XMLNode_getChild(NULL, 0) == NULL);
  fail_unless( XMLNode_getChildForName(NULL, NULL) == NULL);
  fail_unless( XMLNode_getChildForNameNC(NULL, NULL) == NULL);
  fail_unless( XMLNode_getChildNC(NULL, 0) == NULL);
  
  fail_unless( XMLNode_getIndex(NULL, NULL) == -1);
  fail_unless( XMLNode_getName(NULL) == NULL);
  
  fail_unless( XMLNode_getNamespaceIndex(NULL, NULL) == -1);
  fail_unless( XMLNode_getNamespaceIndexByPrefix(NULL, NULL) == -1);
  fail_unless( XMLNode_getNamespacePrefix(NULL, 0) == NULL);
  fail_unless( XMLNode_getNamespacePrefixByURI(NULL, NULL) == NULL);
  fail_unless( XMLNode_getNamespaces(NULL) == NULL);
  fail_unless( XMLNode_getNamespacesLength(NULL) == 0);
  fail_unless( XMLNode_getNamespaceURI(NULL, 0) == NULL);
  fail_unless( XMLNode_getNamespaceURIByPrefix(NULL, NULL) == NULL);
  
  fail_unless( XMLNode_getNumChildren(NULL) == 0);
  fail_unless( XMLNode_getPrefix(NULL) == NULL);  
  fail_unless( XMLNode_getURI(NULL) == NULL);
  
  fail_unless( XMLNode_hasAttr(NULL, 0) == 0);
  fail_unless( XMLNode_hasAttrWithName(NULL, NULL) == 0);
  fail_unless( XMLNode_hasAttrWithNS(NULL, NULL, NULL) == 0);
  fail_unless( XMLNode_hasAttrWithTriple(NULL, NULL) == 0);
  
  fail_unless( XMLNode_hasChild(NULL, NULL) == 0);
  fail_unless( XMLNode_hasNamespaceNS(NULL, NULL, NULL) == 0);
  fail_unless( XMLNode_hasNamespacePrefix(NULL, NULL) == 0);
  fail_unless( XMLNode_hasNamespaceURI(NULL, NULL) == 0);
  
  fail_unless( XMLNode_insertChild(NULL, 0, NULL) == NULL);
  
  fail_unless( XMLNode_isAttributesEmpty(NULL) == 0);
  fail_unless( XMLNode_isElement(NULL) == 0);
  fail_unless( XMLNode_isEnd(NULL) == 0);
  fail_unless( XMLNode_isEndFor(NULL, NULL) == 0);
  fail_unless( XMLNode_isEOF(NULL) == 0);
  fail_unless( XMLNode_isNamespacesEmpty(NULL) == 0);
  fail_unless( XMLNode_isStart(NULL) == 0);
  fail_unless( XMLNode_isText(NULL) == 0);
  
  fail_unless( XMLNode_removeAttr(NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_removeAttrByName(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_removeAttrByNS(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_removeAttrByTriple(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless( XMLNode_removeChild(NULL, 0) == NULL);
  fail_unless( XMLNode_removeChildren(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_removeNamespace(NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_removeNamespaceByPrefix(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless( XMLNode_setAttributes(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_setEnd(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_setEOF(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_setNamespaces(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( XMLNode_setTriple(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless( XMLNode_toXMLString(NULL) == NULL);
  fail_unless( XMLNode_unsetEnd(NULL) == LIBSBML_INVALID_OBJECT);
  
    
}
END_TEST

Suite *
create_suite_XMLNode_newSetters (void)
{
  Suite *suite = suite_create("XMLNode_newSetters");
  TCase *tcase = tcase_create("XMLNode_newSetters");

  tcase_add_test( tcase, test_XMLNode_addChild1  );
  tcase_add_test( tcase, test_XMLNode_addChild2  );
  tcase_add_test( tcase, test_XMLNode_addChild3  );
  tcase_add_test( tcase, test_XMLNode_removeChildren  );
  tcase_add_test( tcase, test_XMLNode_removeAttributes  );
  tcase_add_test( tcase, test_XMLNode_clearAttributes  );
  tcase_add_test( tcase, test_XMLNode_removeNamespaces  );
  tcase_add_test( tcase, test_XMLNode_clearNamespaces  );
  tcase_add_test( tcase, test_XMLNode_accessWithNULL   );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif

