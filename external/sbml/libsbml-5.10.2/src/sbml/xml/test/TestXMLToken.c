/**
 * \file    TestXMLToken.c
 * \brief   XMLToken unit tests
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
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLTriple.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_XMLToken_create)
{
  XMLToken_t *token;
  XMLTriple_t *triple;
  XMLAttributes_t *attr;

  token = XMLToken_create();
  fail_unless(token != NULL);
  XMLToken_free(token);

  triple = XMLTriple_createWith("attr", "uri", "prefix");

  token = XMLToken_createWithTriple(triple);
  fail_unless(token != NULL);
  fail_unless(strcmp(XMLToken_getName(token), "attr") == 0);
  fail_unless(strcmp(XMLToken_getPrefix(token), "prefix") == 0);
  fail_unless(strcmp(XMLToken_getURI(token), "uri") == 0);
  XMLToken_free(token);

  attr = XMLAttributes_create();
  fail_unless(attr != NULL);
  XMLAttributes_add(attr, "attr2", "value");
  token = XMLToken_createWithTripleAttr(triple, attr);  
  fail_unless(token != NULL);
  const XMLAttributes_t *returnattr = XMLToken_getAttributes(token);
  fail_unless(strcmp(XMLAttributes_getName(returnattr, 0), "attr2") == 0);
  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_fields)
{
  /* Tokens created with just a triple are flagged as end elements. */

  XMLTriple_t *triple;
  XMLToken_t *token;

  triple = XMLTriple_createWith("attr", "uri", "prefix");
  token = XMLToken_createWithTriple(triple);
  fail_unless(XMLToken_isElement(token) == 1);
  fail_unless(XMLToken_isEnd(token) == 1);
  fail_unless(XMLToken_isStart(token) == 0);
  fail_unless(XMLToken_isText(token) == 0);
  fail_unless(XMLToken_isEOF(token) == 0);

  fail_unless(strcmp(XMLToken_getName(token), "attr") == 0);
  fail_unless(strcmp(XMLToken_getURI(token), "uri") == 0);
  fail_unless(strcmp(XMLToken_getPrefix(token), "prefix") == 0);
  XMLToken_free(token);
  XMLTriple_free(triple);
}
END_TEST

START_TEST (test_XMLToken_chars)
{
  XMLToken_t *token;

  token = XMLToken_createWithText("This is text");
  fail_unless(XMLToken_isElement(token) == 0);
  fail_unless(XMLToken_isEnd(token) == 0);
  fail_unless(XMLToken_isStart(token) == 0);
  fail_unless(XMLToken_isText(token) == 1);
  fail_unless(XMLToken_isEOF(token) == 0);

  fail_unless(strcmp(XMLToken_getCharacters(token), "This is text") == 0);

  XMLToken_free(token);
}
END_TEST


START_TEST (test_XMLToken_namespace_add)
{
  XMLTriple_t*   triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr = XMLAttributes_create();
  XMLToken_t *token     = XMLToken_createWithTripleAttr(triple, attr);

  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)  == 1 );

  XMLToken_addNamespace(token, "http://test1.org/", "test1");
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  fail_unless( XMLToken_isNamespacesEmpty(token)  == 0 );

  XMLToken_addNamespace(token, "http://test2.org/", "test2");
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  fail_unless( XMLToken_isNamespacesEmpty(token)  == 0 );

  XMLToken_addNamespace(token, "http://test1.org/", "test1a");
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  fail_unless( XMLToken_isNamespacesEmpty(token)  == 0 );

  XMLToken_addNamespace(token, "http://test1.org/", "test1a");
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  fail_unless( XMLToken_isNamespacesEmpty(token)  == 0 );

  fail_if( XMLToken_getNamespaceIndex(token, "http://test1.org/") == -1);

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_namespace_get)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLToken_addNamespace(token, "http://test1.org/", "test1");    /* index 0 */
  XMLToken_addNamespace(token, "http://test2.org/", "test2");    /* index 1 */
  XMLToken_addNamespace(token, "http://test3.org/", "test3");    /* index 2 */
  XMLToken_addNamespace(token, "http://test4.org/", "test4");    /* index 3 */
  XMLToken_addNamespace(token, "http://test5.org/", "test5");    /* index 4 */
  XMLToken_addNamespace(token, "http://test6.org/", "test6");    /* index 5 */
  XMLToken_addNamespace(token, "http://test7.org/", "test7");    /* index 6 */
  XMLToken_addNamespace(token, "http://test8.org/", "test8");    /* index 7 */
  XMLToken_addNamespace(token, "http://test9.org/", "test9");    /* index 8 */

  fail_unless( XMLToken_getNamespacesLength(token) == 9 );

  fail_unless( XMLToken_getNamespaceIndex(token, "http://test1.org/") == 0 );
  fail_unless( strcmp(XMLToken_getNamespacePrefix(token, 1), "test2") == 0 );
  fail_unless( strcmp(XMLToken_getNamespacePrefixByURI(token, "http://test1.org/"),
		      "test1") == 0 );
  fail_unless( strcmp(XMLToken_getNamespaceURI(token, 1), "http://test2.org/") == 0 );
  fail_unless( strcmp(XMLToken_getNamespaceURIByPrefix(token, "test2"),
		      "http://test2.org/") == 0 );

  fail_unless( XMLToken_getNamespaceIndex(token, "http://test1.org/") ==  0 );
  fail_unless( XMLToken_getNamespaceIndex(token, "http://test2.org/") ==  1 );
  fail_unless( XMLToken_getNamespaceIndex(token, "http://test5.org/") ==  4 );
  fail_unless( XMLToken_getNamespaceIndex(token, "http://test9.org/") ==  8 );
  fail_unless( XMLToken_getNamespaceIndex(token, "http://testX.org/") == -1 );

  fail_unless( XMLToken_hasNamespaceURI(token, "http://test1.org/") !=  0 );
  fail_unless( XMLToken_hasNamespaceURI(token, "http://test2.org/") !=  0 );
  fail_unless( XMLToken_hasNamespaceURI(token, "http://test5.org/") !=  0 );
  fail_unless( XMLToken_hasNamespaceURI(token, "http://test9.org/") !=  0 );
  fail_unless( XMLToken_hasNamespaceURI(token, "http://testX.org/") ==  0 );

  fail_unless( XMLToken_getNamespaceIndexByPrefix(token, "test1") ==  0 );
  fail_unless( XMLToken_getNamespaceIndexByPrefix(token, "test5") ==  4 );
  fail_unless( XMLToken_getNamespaceIndexByPrefix(token, "test9") ==  8 );
  fail_unless( XMLToken_getNamespaceIndexByPrefix(token, "testX") == -1 );

  fail_unless( XMLToken_hasNamespacePrefix(token, "test1") !=  0 );
  fail_unless( XMLToken_hasNamespacePrefix(token, "test5") !=  0 );
  fail_unless( XMLToken_hasNamespacePrefix(token, "test9") !=  0 );
  fail_unless( XMLToken_hasNamespacePrefix(token, "testX") ==  0 );

  fail_unless( XMLToken_hasNamespaceNS(token, "http://test1.org/", "test1") !=  0 );
  fail_unless( XMLToken_hasNamespaceNS(token, "http://test5.org/", "test5") !=  0 );
  fail_unless( XMLToken_hasNamespaceNS(token, "http://test9.org/", "test9") !=  0 );
  fail_unless( XMLToken_hasNamespaceNS(token, "http://testX.org/", "testX") ==  0 );

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_namespace_remove)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLToken_addNamespace(token, "http://test1.org/", "test1"); 
  XMLToken_addNamespace(token, "http://test2.org/", "test2");
  XMLToken_addNamespace(token, "http://test3.org/", "test3"); 
  XMLToken_addNamespace(token, "http://test4.org/", "test4");
  XMLToken_addNamespace(token, "http://test5.org/", "test5");

  fail_unless( XMLToken_getNamespacesLength(token) == 5 );
  XMLToken_removeNamespace(token, 4);
  fail_unless( XMLToken_getNamespacesLength(token) == 4 );
  XMLToken_removeNamespace(token, 3);
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  XMLToken_removeNamespace(token, 2);
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  XMLToken_removeNamespace(token, 1);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );


  XMLToken_addNamespace(token, "http://test1.org/", "test1");
  XMLToken_addNamespace(token, "http://test2.org/", "test2");
  XMLToken_addNamespace(token, "http://test3.org/", "test3");
  XMLToken_addNamespace(token, "http://test4.org/", "test4");
  XMLToken_addNamespace(token, "http://test5.org/", "test5");

  fail_unless( XMLToken_getNamespacesLength(token) == 5 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 4 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  XMLToken_removeNamespace(token, 0);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_namespace_remove_by_prefix)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLToken_addNamespace(token, "http://test1.org/", "test1"); 
  XMLToken_addNamespace(token, "http://test2.org/", "test2");
  XMLToken_addNamespace(token, "http://test3.org/", "test3"); 
  XMLToken_addNamespace(token, "http://test4.org/", "test4");
  XMLToken_addNamespace(token, "http://test5.org/", "test5");

  fail_unless( XMLToken_getNamespacesLength(token) == 5 );
  XMLToken_removeNamespaceByPrefix(token, "test1");
  fail_unless( XMLToken_getNamespacesLength(token) == 4 );
  XMLToken_removeNamespaceByPrefix(token, "test2");
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  XMLToken_removeNamespaceByPrefix(token, "test3");
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  XMLToken_removeNamespaceByPrefix(token, "test4");
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  XMLToken_removeNamespaceByPrefix(token, "test5");
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_addNamespace(token, "http://test1.org/", "test1");
  XMLToken_addNamespace(token, "http://test2.org/", "test2");
  XMLToken_addNamespace(token, "http://test3.org/", "test3");
  XMLToken_addNamespace(token, "http://test4.org/", "test4");
  XMLToken_addNamespace(token, "http://test5.org/", "test5");

  fail_unless( XMLToken_getNamespacesLength(token) == 5 );
  XMLToken_removeNamespaceByPrefix(token, "test5");
  fail_unless( XMLToken_getNamespacesLength(token) == 4 );
  XMLToken_removeNamespaceByPrefix(token, "test4");
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  XMLToken_removeNamespaceByPrefix(token, "test3");
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  XMLToken_removeNamespaceByPrefix(token, "test2");
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  XMLToken_removeNamespaceByPrefix(token, "test1");
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_addNamespace(token, "http://test1.org/", "test1"); 
  XMLToken_addNamespace(token, "http://test2.org/", "test2"); 
  XMLToken_addNamespace(token, "http://test3.org/", "test3");
  XMLToken_addNamespace(token, "http://test4.org/", "test4");
  XMLToken_addNamespace(token, "http://test5.org/", "test5");

  fail_unless( XMLToken_getNamespacesLength(token) == 5 );
  XMLToken_removeNamespaceByPrefix(token, "test3");
  fail_unless( XMLToken_getNamespacesLength(token) == 4 );
  XMLToken_removeNamespaceByPrefix(token, "test1");
  fail_unless( XMLToken_getNamespacesLength(token) == 3 );
  XMLToken_removeNamespaceByPrefix(token, "test4");
  fail_unless( XMLToken_getNamespacesLength(token) == 2 );
  XMLToken_removeNamespaceByPrefix(token, "test5");
  fail_unless( XMLToken_getNamespacesLength(token) == 1 );
  XMLToken_removeNamespaceByPrefix(token, "test2");
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLToken_namespace_set_clear )
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLNamespaces_t* ns = XMLNamespaces_create();

  fail_unless( XMLToken_getNamespacesLength(token) == 0 );
  fail_unless( XMLToken_isNamespacesEmpty(token)   == 1 );  

  XMLNamespaces_add(ns, "http://test1.org/", "test1"); 
  XMLNamespaces_add(ns, "http://test2.org/", "test2");
  XMLNamespaces_add(ns, "http://test3.org/", "test3"); 
  XMLNamespaces_add(ns, "http://test4.org/", "test4");
  XMLNamespaces_add(ns, "http://test5.org/", "test5");

  XMLToken_setNamespaces(token, ns);

  fail_unless(XMLToken_getNamespacesLength(token) == 5 );
  fail_unless(XMLToken_isNamespacesEmpty(token)   == 0 );  
  fail_unless(strcmp(XMLToken_getNamespacePrefix(token, 0), "test1") == 0 );
  fail_unless(strcmp(XMLToken_getNamespacePrefix(token, 1), "test2") == 0 );
  fail_unless(strcmp(XMLToken_getNamespacePrefix(token, 2), "test3") == 0 );
  fail_unless(strcmp(XMLToken_getNamespacePrefix(token, 3), "test4") == 0 );
  fail_unless(strcmp(XMLToken_getNamespacePrefix(token, 4), "test5") == 0 );
  fail_unless(strcmp(XMLToken_getNamespaceURI(token, 0), "http://test1.org/") == 0 );
  fail_unless(strcmp(XMLToken_getNamespaceURI(token, 1), "http://test2.org/") == 0 );
  fail_unless(strcmp(XMLToken_getNamespaceURI(token, 2), "http://test3.org/") == 0 );
  fail_unless(strcmp(XMLToken_getNamespaceURI(token, 3), "http://test4.org/") == 0 );
  fail_unless(strcmp(XMLToken_getNamespaceURI(token, 4), "http://test5.org/") == 0 );

  XMLToken_clearNamespaces(token);
  fail_unless( XMLToken_getNamespacesLength(token) == 0 );

  XMLNamespaces_free(ns);
  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST(test_XMLToken_attribute_add_remove)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);

  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");
  XMLTriple_t* xt3    = XMLTriple_createWith("name3", "http://name3.org/", "p3");
  XMLTriple_t* xt1a   = XMLTriple_createWith("name1", "http://name1a.org/", "p1a");
  XMLTriple_t* xt2a   = XMLTriple_createWith("name2", "http://name2a.org/", "p2a");

  /*-- test of adding attributes with namespace --*/

  XMLToken_addAttrWithNS(token, "name1", "val1", "http://name1.org/", "p1");
  XMLToken_addAttrWithTriple(token, xt2, "val2");
  fail_unless( XMLToken_getAttributesLength(token) == 2 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );

  fail_unless( strcmp(XMLToken_getAttrName  (token, 0), "name1") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 0), "val1" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 1), "name2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 1), "val2" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 1), "p2"   ) == 0 );
  fail_unless( XMLToken_getAttrValueByName (token, "name1") == NULL );
  fail_unless( XMLToken_getAttrValueByName (token, "name2") == NULL );
  fail_unless( strcmp(XMLToken_getAttrValueByNS (token, "name1", "http://name1.org/"), "val1" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByNS (token, "name2", "http://name2.org/"), "val2" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByTriple (token, xt1), "val1" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByTriple (token, xt2), "val2" ) == 0 );

  fail_unless( XMLToken_hasAttr(token, -1) == 0 );
  fail_unless( XMLToken_hasAttr(token,  2) == 0 );
  fail_unless( XMLToken_hasAttr(token,  0) == 1 );
  fail_unless( XMLToken_hasAttrWithNS(token, "name1", "http://name1.org/")   == 1 );
  fail_unless( XMLToken_hasAttrWithNS(token, "name2", "http://name2.org/")   == 1 );
  fail_unless( XMLToken_hasAttrWithNS(token, "name3", "http://name3.org/")   == 0 );
  fail_unless( XMLToken_hasAttrWithTriple(token, xt1)   == 1 );
  fail_unless( XMLToken_hasAttrWithTriple(token, xt2)   == 1 );
  fail_unless( XMLToken_hasAttrWithTriple(token, xt3)   == 0 );

  /*-- test of adding an attribute without namespace --*/

  XMLToken_addAttr(token, "noprefix", "val3");
  fail_unless( XMLToken_getAttributesLength(token) == 3 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );
  fail_unless( strcmp(XMLToken_getAttrName (token, 2), "noprefix") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue(token, 2), "val3"    ) == 0 );
  fail_unless( XMLToken_getAttrURI    (token, 2) == NULL );
  fail_unless( XMLToken_getAttrPrefix (token, 2) == NULL );
  fail_unless( strcmp(XMLToken_getAttrValueByName (token, "noprefix"),     "val3" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByNS   (token, "noprefix", ""), "val3" ) == 0 );
  fail_unless( XMLToken_hasAttrWithName (token, "noprefix"    ) == 1 );
  fail_unless( XMLToken_hasAttrWithNS   (token, "noprefix", "") == 1 );

  /*-- test of overwriting existing attributes with namespace --*/

  XMLToken_addAttrWithTriple(token, xt1, "mval1");
  XMLToken_addAttrWithNS(token, "name2", "mval2", "http://name2.org/", "p2");

  fail_unless( XMLToken_getAttributesLength(token) == 3 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );

  fail_unless( strcmp(XMLToken_getAttrName  (token, 0), "name1") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 0), "mval1") == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 1), "name2"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 1), "mval2"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 1), "p2"      ) == 0 );
  fail_unless( XMLToken_hasAttrWithTriple(token, xt1) == 1 );
  fail_unless( XMLToken_hasAttrWithNS(token, "name1", "http://name1.org/")   == 1 );

  /*-- test of overwriting an existing attribute without namespace --*/

  XMLToken_addAttr(token, "noprefix", "mval3");
  fail_unless( XMLToken_getAttributesLength(token) == 3 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 2), "noprefix") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 2), "mval3"   ) == 0 );
  fail_unless(        XMLToken_getAttrURI   (token, 2) == NULL );
  fail_unless(        XMLToken_getAttrPrefix(token, 2) == NULL );
  fail_unless( XMLToken_hasAttrWithName (token, "noprefix") == 1 );
  fail_unless( XMLToken_hasAttrWithNS   (token, "noprefix", "") == 1 );

  /*-- test of overwriting existing attributes with the given triple --*/

  XMLToken_addAttrWithTriple(token, xt1a, "val1a");
  XMLToken_addAttrWithTriple(token, xt2a, "val2a");
  fail_unless( XMLToken_getAttributesLength(token) == 5 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 3), "name1") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 3), "val1a") == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 3), "http://name1a.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 3), "p1a") == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 4), "name2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 4), "val2a") == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 4), "http://name2a.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 4), "p2a") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByNS (token, "name1", "http://name1a.org/"), "val1a" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByNS (token, "name2", "http://name2a.org/"), "val2a" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByTriple (token, xt1a), "val1a" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrValueByTriple (token, xt2a), "val2a" ) == 0 );

  /*-- test of removing attributes with namespace --*/

  XMLToken_removeAttrByTriple(token, xt1a);
  XMLToken_removeAttrByTriple(token, xt2a);
  fail_unless( XMLToken_getAttributesLength(token) == 3 );

  XMLToken_removeAttrByNS(token, "name1", "http://name1.org/");
  fail_unless( XMLToken_getAttributesLength(token) == 2 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 0), "name2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 0), "mval2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 0), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 0), "p2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 1), "noprefix") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 1), "mval3") == 0 );
  fail_unless(        XMLToken_getAttrURI   (token, 1) == NULL);
  fail_unless(        XMLToken_getAttrPrefix(token, 1) == NULL);
  fail_unless( XMLToken_hasAttrWithNS(token, "name1", "http://name1.org/")   == 0 );

  XMLToken_removeAttrByTriple(token, xt2);
  fail_unless( XMLToken_getAttributesLength(token) == 1 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 0 );
  fail_unless( strcmp(XMLToken_getAttrName (token, 0), "noprefix") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue(token, 0), "mval3") == 0 );
  fail_unless(       XMLToken_getAttrURI   (token, 0) == NULL );
  fail_unless(       XMLToken_getAttrPrefix(token, 0) == NULL );
  fail_unless( XMLToken_hasAttrWithTriple(token, xt2) == 0 );
  fail_unless( XMLToken_hasAttrWithNS(token, "name2", "http://name2.org/")   == 0 );

  /*-- test of removing attributes without namespace --*/

  XMLToken_removeAttrByName(token, "noprefix");
  fail_unless( XMLToken_getAttributesLength(token) == 0 );
  fail_unless( XMLToken_isAttributesEmpty(token)   == 1 );
  fail_unless( XMLToken_hasAttrWithName(token, "noprefix"    ) == 0 );
  fail_unless( XMLToken_hasAttrWithNS  (token, "noprefix", "") == 0 );

  /*-- teardown --*/

  XMLToken_free(token);
  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(xt3);
  XMLTriple_free(xt1a);
  XMLTriple_free(xt2a);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);

}
END_TEST


START_TEST(test_XMLToken_attribute_set_clear)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLToken_t*      token  = XMLToken_createWithTripleAttr(triple, attr);
  XMLAttributes_t* nattr  = XMLAttributes_create();

  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");
  XMLTriple_t* xt3    = XMLTriple_createWith("name3", "http://name3.org/", "p3");
  XMLTriple_t* xt4    = XMLTriple_createWith("name4", "http://name4.org/", "p4");
  XMLTriple_t* xt5    = XMLTriple_createWith("name5", "http://name5.org/", "p5");

  XMLAttributes_addWithTriple(nattr, xt1, "val1");
  XMLAttributes_addWithTriple(nattr, xt2, "val2");
  XMLAttributes_addWithTriple(nattr, xt3, "val3");
  XMLAttributes_addWithTriple(nattr, xt4, "val4");
  XMLAttributes_addWithTriple(nattr, xt5, "val5");

  /*-- test of settting attributes -- */

  XMLToken_setAttributes(token, nattr);
  fail_unless(XMLToken_getAttributesLength(token) == 5 );
  fail_unless(XMLToken_isAttributesEmpty(token)   == 0 );

  fail_unless( strcmp(XMLToken_getAttrName  (token, 0), "name1") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 0), "val1" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 1), "name2") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 1), "val2" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 1), "p2"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 2), "name3") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 2), "val3" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 2), "http://name3.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 2), "p3"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 3), "name4") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 3), "val4" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 3), "http://name4.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 3), "p4"   ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrName  (token, 4), "name5") == 0 );
  fail_unless( strcmp(XMLToken_getAttrValue (token, 4), "val5" ) == 0 );
  fail_unless( strcmp(XMLToken_getAttrURI   (token, 4), "http://name5.org/") == 0 );
  fail_unless( strcmp(XMLToken_getAttrPrefix(token, 4), "p5"   ) == 0 );

  /*-- test of setTriple -- */

  XMLTriple_t* ntriple = XMLTriple_createWith("test2","http://test2.org/","p2");  
  XMLToken_setTriple(token, ntriple);
  fail_unless(strcmp(XMLToken_getName(token),   "test2") == 0);
  fail_unless(strcmp(XMLToken_getURI(token),    "http://test2.org/") == 0);
  fail_unless(strcmp(XMLToken_getPrefix(token), "p2") == 0);

  /*-- test of clearing attributes -- */

  XMLToken_clearAttributes(token);
  fail_unless( XMLToken_getAttributesLength(token) == 0 );
  fail_unless( XMLToken_isAttributesEmpty(token)   != 0 );

  /*-- teardown --*/

  XMLAttributes_free(nattr);
  XMLTriple_free(triple);
  XMLTriple_free(ntriple);
  XMLAttributes_free(attr);
  XMLToken_free(token);
  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(xt3);
  XMLTriple_free(xt4);
  XMLTriple_free(xt5);

}
END_TEST

START_TEST(test_XMLToken_accessWithNULL)
{
  fail_unless (XMLToken_addAttr(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_addAttrWithNS(NULL, NULL, NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_addAttrWithTriple(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_addNamespace(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_append(NULL, NULL) == LIBSBML_OPERATION_FAILED);
  fail_unless (XMLToken_clearAttributes(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_clearNamespaces(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_clone(NULL) == NULL);
  fail_unless (XMLToken_createWithTriple(NULL) == NULL);
  fail_unless (XMLToken_createWithTripleAttr(NULL, NULL) == NULL);
  fail_unless (XMLToken_createWithTripleAttrNS(NULL, NULL, NULL) == NULL);
  
  XMLToken_free(NULL);
  
  fail_unless (XMLToken_getAttributes(NULL) == NULL);
  fail_unless (XMLToken_getAttributesLength(NULL) == 0);
  fail_unless (XMLToken_getAttrIndex(NULL, NULL, NULL) == -1);
  fail_unless (XMLToken_getAttrIndexByTriple(NULL, NULL) == -1);
  fail_unless (XMLToken_getAttrName(NULL, 0) == NULL);
  fail_unless (XMLToken_getAttrPrefix(NULL, 0) == NULL);
  fail_unless (XMLToken_getAttrPrefixedName(NULL, 0) == NULL);
  fail_unless (XMLToken_getAttrURI(NULL, 0) == NULL);
  fail_unless (XMLToken_getAttrValue(NULL, 0) == NULL);
  fail_unless (XMLToken_getAttrValueByName(NULL, NULL) == NULL);
  fail_unless (XMLToken_getAttrValueByNS(NULL, NULL, NULL) == NULL);
  fail_unless (XMLToken_getAttrValueByTriple(NULL, NULL) == NULL);
  fail_unless (XMLToken_getCharacters(NULL) == NULL);
  fail_unless (XMLToken_getColumn(NULL) == 0);
  fail_unless (XMLToken_getLine(NULL) == 0);
  fail_unless (XMLToken_getName(NULL) == NULL);
  fail_unless (XMLToken_getNamespaceIndex(NULL, NULL) == -1);
  fail_unless (XMLToken_getNamespaceIndexByPrefix(NULL, NULL) == -1);
  fail_unless (XMLToken_getNamespacePrefix(NULL, 0) == NULL);
  fail_unless (XMLToken_getNamespacePrefixByURI(NULL, NULL) == NULL);
  fail_unless (XMLToken_getNamespaces(NULL) == NULL);
  fail_unless (XMLToken_getNamespacesLength(NULL) == 0);
  fail_unless (XMLToken_getNamespaceURI(NULL, 0) == NULL);
  fail_unless (XMLToken_getNamespaceURIByPrefix(NULL, NULL) == NULL);
  fail_unless (XMLToken_getPrefix(NULL) == NULL);
  fail_unless (XMLToken_getURI(NULL) == NULL);
  fail_unless (XMLToken_hasAttr(NULL, 0) == 0);
  fail_unless (XMLToken_hasAttrWithName(NULL, NULL) == 0);
  fail_unless (XMLToken_hasAttrWithNS(NULL, NULL, NULL) == 0);
  fail_unless (XMLToken_hasAttrWithTriple(NULL, NULL) == 0);
  fail_unless (XMLToken_hasNamespaceNS(NULL, NULL, NULL) == 0);
  fail_unless (XMLToken_hasNamespacePrefix(NULL, NULL) == 0);
  fail_unless (XMLToken_hasNamespaceURI(NULL, NULL) == 0);
  fail_unless (XMLToken_isAttributesEmpty(NULL) == 0);
  fail_unless (XMLToken_isElement(NULL) == 0);
  fail_unless (XMLToken_isEnd(NULL) == 0);
  fail_unless (XMLToken_isEndFor(NULL, NULL) == 0);
  fail_unless (XMLToken_isEOF(NULL) == 0);
  fail_unless (XMLToken_isNamespacesEmpty(NULL) == 0);
  fail_unless (XMLToken_isStart(NULL) == 0);
  fail_unless (XMLToken_isText(NULL) == 0);
  
  fail_unless (XMLToken_removeAttr(NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_removeAttrByName(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_removeAttrByNS(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_removeAttrByTriple(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless (XMLToken_removeNamespace(NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_removeNamespaceByPrefix(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless (XMLToken_setAttributes(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_setEnd(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_setEOF(NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_setNamespaces(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless (XMLToken_setTriple(NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  fail_unless (XMLToken_unsetEnd(NULL) == LIBSBML_INVALID_OBJECT);
}
END_TEST

Suite *
create_suite_XMLToken (void)
{
  Suite *suite = suite_create("XMLToken");
  TCase *tcase = tcase_create("XMLToken");

  tcase_add_test( tcase, test_XMLToken_create  );
  tcase_add_test( tcase, test_XMLToken_fields  );
  tcase_add_test( tcase, test_XMLToken_chars  );
  tcase_add_test( tcase, test_XMLToken_namespace_add );
  tcase_add_test( tcase, test_XMLToken_namespace_get );
  tcase_add_test( tcase, test_XMLToken_namespace_remove );
  tcase_add_test( tcase, test_XMLToken_namespace_remove_by_prefix );
  tcase_add_test( tcase, test_XMLToken_namespace_set_clear );
  tcase_add_test( tcase, test_XMLToken_attribute_add_remove);
  tcase_add_test( tcase, test_XMLToken_attribute_set_clear);
  tcase_add_test( tcase, test_XMLToken_accessWithNULL             );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif
