/**
 * \file    TestXMLNode.c
 * \brief   XMLNode unit tests
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
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLInputStream.h>

#include <check.h>
using namespace std;
LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART

START_TEST (test_XMLNode_getIndex)
{
	const char* xmlstr = "<annotation>\n"
	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
	"</annotation>";
	
	XMLNode_t *node = XMLNode_create();
	fail_unless(XMLNode_getIndex(node, "test") == -1);	
	XMLNode_free(node);	
		
	node   = XMLNode_convertStringToXMLNode(xmlstr, NULL);
	fail_unless(XMLNode_getIndex(node, "test") == 0);	
	XMLNode_free(node);			
}
END_TEST

START_TEST (test_XMLNode_hasChild)
{
	const char* xmlstr = "<annotation>\n"
	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
	"</annotation>";
	
	XMLNode_t *node = XMLNode_create();
	fail_unless(XMLNode_hasChild(node, "test") == (int)false);	
	XMLNode_free(node);	
	
	node   = XMLNode_convertStringToXMLNode(xmlstr, NULL);
	fail_unless(XMLNode_hasChild(node, "test") == (int)true);	
	XMLNode_free(node);			
}
END_TEST

START_TEST (test_XMLNode_getChildForName)
{
	const char* xmlstr = "<annotation>\n"
	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
	"</annotation>";
	
	XMLNode_t *node = XMLNode_create();
	XMLNode annotation = node->getChild("test");
	std::string name = annotation.getName();
	fail_unless( name == "");	
	XMLNode_free(node);	
	
	node   = XMLNode_convertStringToXMLNode(xmlstr, NULL);
	annotation = node->getChild("test");
	fail_unless( strcmp(XMLNode_getName(&annotation),"test") == 0);	
	XMLNode_free(node);			
}
END_TEST

START_TEST (test_XMLNode_equals)
{
	const char* xmlstr = "<annotation>\n"
	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
	"</annotation>";
	
	XMLNode_t *node  = XMLNode_create();
	XMLNode_t *node1 = XMLNode_convertStringToXMLNode(xmlstr, NULL);
	fail_unless( !XMLNode_equals(node,node1));	
	XMLNode_free(node);	

	XMLNode_t *node2 = XMLNode_convertStringToXMLNode(xmlstr, NULL);
	fail_unless( XMLNode_equals(node2,node1));	
	XMLNode_free(node1);			
	XMLNode_free(node2);			
}
END_TEST

START_TEST (test_XMLNode_create)
{
  XMLNode_t *node = XMLNode_create();

  fail_unless(node != NULL);
  fail_unless(XMLNode_getNumChildren(node) == 0);
  XMLNode_free(node);

  node = XMLNode_create();
  fail_unless(node != NULL);

  XMLNode_t *node2 = XMLNode_create();
  fail_unless(node2 != NULL);

  XMLNode_addChild(node, node2);
  fail_unless(XMLNode_getNumChildren(node) == 1);

  XMLNode_t *node3 = XMLNode_create();
  fail_unless(node3 != NULL);

  XMLNode_addChild(node, node3);
  fail_unless(XMLNode_getNumChildren(node) == 2);

  XMLNode_free(node);
  XMLNode_free(node2);
  XMLNode_free(node3);
}
END_TEST


START_TEST (test_XMLNode_createFromToken)
{
  XMLToken_t *token;
  XMLTriple_t *triple;
  XMLNode_t *node;

  triple = XMLTriple_createWith("attr", "uri", "prefix");
  token = XMLToken_createWithTriple(triple);
  node = XMLNode_createFromToken(token);

  fail_unless(node != NULL);
  fail_unless(XMLNode_getNumChildren(node) == 0);

  fail_unless(strcmp(XMLNode_getName(node), "attr") == 0);
  fail_unless(strcmp(XMLNode_getPrefix(node), "prefix") == 0);
  fail_unless(strcmp(XMLNode_getURI(node), "uri") == 0);
  fail_unless (XMLNode_getChild(node, 1) != NULL);

  XMLToken_free(token);
  XMLTriple_free(triple);
  XMLNode_free(node);



}
END_TEST


START_TEST (test_XMLNode_createElement)
{
  XMLTriple_t     *triple;
  XMLAttributes_t *attr;
  XMLNamespaces_t *ns;
  XMLNode_t *snode, *enode, *tnode;

  const XMLAttributes_t* cattr;
  const char* name   = "test";
  const char* uri    = "http://test.org/";
  const char* prefix = "p";
  const char* text   = "text node";

  /* start element with namespace */

  triple = XMLTriple_createWith(name, uri, prefix);
  ns     = XMLNamespaces_create();
  attr   = XMLAttributes_create();
  XMLNamespaces_add(ns, uri, prefix);
  XMLAttributes_addWithNamespace(attr,"id", "value", uri, prefix);
  snode = XMLNode_createStartElementNS(triple, attr, ns);

  fail_unless(snode != NULL);
  fail_unless(XMLNode_getNumChildren(snode) == 0);
  fail_unless(strcmp(XMLNode_getName  (snode), name  ) == 0);
  fail_unless(strcmp(XMLNode_getPrefix(snode), prefix) == 0);
  fail_unless(strcmp(XMLNode_getURI   (snode), uri   ) == 0);
  fail_unless(XMLNode_isElement(snode) == 1);
  fail_unless(XMLNode_isStart  (snode) == 1);
  fail_unless(XMLNode_isEnd    (snode) == 0);
  fail_unless(XMLNode_isText   (snode) == 0);

  XMLNode_setEnd(snode);
  fail_unless ( XMLNode_isEnd(snode) == 1);
  XMLNode_unsetEnd(snode);
  fail_unless ( XMLNode_isEnd(snode) == 0);

  cattr = XMLNode_getAttributes(snode);
  fail_unless(cattr != NULL);
  fail_unless(strcmp(XMLAttributes_getName  (cattr, 0), "id"   ) == 0);
  fail_unless(strcmp(XMLAttributes_getValue (cattr, 0), "value") == 0);
  fail_unless(strcmp(XMLAttributes_getPrefix(cattr, 0),  prefix) == 0);
  fail_unless(strcmp(XMLAttributes_getURI   (cattr, 0),  uri   ) == 0);

  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNamespaces_free(ns);
  XMLNode_free(snode);

  /* start element */

  attr   = XMLAttributes_create();
  XMLAttributes_add(attr,"id", "value");
  triple = XMLTriple_createWith(name, "", "");
  snode  = XMLNode_createStartElement(triple, attr);

  fail_unless(snode != NULL);
  fail_unless(XMLNode_getNumChildren(snode) == 0);
  fail_unless(strcmp(XMLNode_getName  (snode), "test") == 0);
  fail_unless(XMLNode_getPrefix(snode) == NULL );
  fail_unless(XMLNode_getURI   (snode) == NULL );
  fail_unless(XMLNode_isElement(snode) == 1);
  fail_unless(XMLNode_isStart  (snode) == 1);
  fail_unless(XMLNode_isEnd    (snode) == 0);
  fail_unless(XMLNode_isText   (snode) == 0);

  cattr = XMLNode_getAttributes(snode);
  fail_unless(cattr != NULL);
  fail_unless(strcmp(XMLAttributes_getName  (cattr, 0), "id"   ) == 0);
  fail_unless(strcmp(XMLAttributes_getValue (cattr, 0), "value") == 0);
  fail_unless(XMLAttributes_getPrefix(cattr, 0) == NULL);
  fail_unless(XMLAttributes_getURI   (cattr, 0) == NULL);

  /* end element */

  enode = XMLNode_createEndElement(triple);
  fail_unless(enode != NULL);
  fail_unless(XMLNode_getNumChildren(enode) == 0);
  fail_unless(strcmp(XMLNode_getName(enode), "test") == 0);
  fail_unless(XMLNode_getPrefix(enode) == NULL );
  fail_unless(XMLNode_getURI   (enode) == NULL );
  fail_unless(XMLNode_isElement(enode) == 1);
  fail_unless(XMLNode_isStart  (enode) == 0);
  fail_unless(XMLNode_isEnd    (enode) == 1);
  fail_unless(XMLNode_isText   (enode) == 0);

  /* text node */

  tnode = XMLNode_createTextNode(text);
  fail_unless(tnode != NULL);
  fail_unless(strcmp(XMLNode_getCharacters(tnode), text) == 0);
  fail_unless(XMLNode_getNumChildren(tnode) == 0);
  fail_unless(XMLNode_getName  (tnode) == NULL);
  fail_unless(XMLNode_getPrefix(tnode) == NULL );
  fail_unless(XMLNode_getURI   (tnode) == NULL );
  fail_unless(XMLNode_isElement(tnode) == 0);
  fail_unless(XMLNode_isStart  (tnode) == 0);
  fail_unless(XMLNode_isEnd    (tnode) == 0);
  fail_unless(XMLNode_isText   (tnode) == 1);

  XMLTriple_free(triple);
  XMLAttributes_free(attr);
  XMLNode_free(snode);
  XMLNode_free(enode);
  XMLNode_free(tnode);

}
END_TEST


START_TEST (test_XMLNode_getters)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLTriple_t *triple;
  XMLAttributes_t *attr;
  XMLNamespaces_t *NS;

  NS = XMLNamespaces_create();
  XMLNamespaces_add(NS, "http://test1.org/", "test1");

  token = XMLToken_createWithText("This is a test");
  node = XMLNode_createFromToken(token);

  fail_unless(node != NULL);
  fail_unless(XMLNode_getNumChildren(node) == 0);

  fail_unless(strcmp(XMLNode_getCharacters(node), "This is a test") == 0);
  fail_unless (XMLNode_getChild(node, 1) != NULL);

  attr = XMLAttributes_create();
  fail_unless(attr != NULL);
  XMLAttributes_add(attr, "attr2", "value");
  
  triple = XMLTriple_createWith("attr", "uri", "prefix");
  token = XMLToken_createWithTripleAttr(triple, attr);  

  fail_unless(token != NULL);
  node = XMLNode_createFromToken(token);

  fail_unless(strcmp(XMLNode_getName(node), "attr") == 0);
  fail_unless(strcmp(XMLNode_getURI(node), "uri") == 0);
  fail_unless(strcmp(XMLNode_getPrefix(node), "prefix") == 0);

  const XMLAttributes_t *returnattr = XMLNode_getAttributes(node);
  fail_unless(strcmp(XMLAttributes_getName(returnattr, 0), "attr2") == 0);
  fail_unless(strcmp(XMLAttributes_getValue(returnattr, 0), "value") == 0);

  token = XMLToken_createWithTripleAttrNS(triple, attr, NS); 
  node = XMLNode_createFromToken(token);

  const XMLNamespaces_t *returnNS = XMLNode_getNamespaces(node);
  fail_unless( XMLNamespaces_getLength(returnNS) == 1 );
  fail_unless( XMLNamespaces_isEmpty(returnNS) == 0 );
  
  XMLTriple_free(triple);
  XMLToken_free(token);
  XMLNode_free(node);

}
END_TEST


START_TEST (test_XMLNode_convert)
{
  const char* xmlstr = "<annotation>\n"
                       "  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
                       "</annotation>";
  XMLNode_t       *node;
  const XMLNode_t *child, *gchild;
  const XMLAttributes_t *attr;
  const XMLNamespaces_t *ns;

  node   = XMLNode_convertStringToXMLNode(xmlstr, NULL);
  child  = XMLNode_getChild(node,0);
  gchild = XMLNode_getChild(child,0);
  attr   = XMLNode_getAttributes(child);
  ns     = XMLNode_getNamespaces(child);

  fail_unless(strcmp(XMLNode_getName(node), "annotation") == 0);
  fail_unless(strcmp(XMLNode_getName(child),"test" ) == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test" ) == 0);
  fail_unless(strcmp(XMLAttributes_getName (attr,0), "id"   ) == 0);
  fail_unless(strcmp(XMLAttributes_getValue(attr,0), "test" ) == 0);
  fail_unless(strcmp(XMLNamespaces_getURI(ns,0), "http://test.org/" ) == 0 );
  fail_unless(XMLNamespaces_getPrefix(ns,0) == NULL );

  char* toxmlstring = XMLNode_toXMLString(node);
  fail_unless( strcmp(toxmlstring, xmlstr) == 0);

  XMLNode_free(node);
  safe_free(toxmlstring);

}
END_TEST

START_TEST (test_XMLNode_convert_dummyroot)
{
  const char* xmlstr_nodummy1 = "<notes>\n"
                                "  <p>test</p>\n"
                                "</notes>";
  const char* xmlstr_nodummy2 = "<html>\n"
                                "  <p>test</p>\n"
                                "</html>";
  const char* xmlstr_nodummy3 = "<body>\n"
                                "  <p>test</p>\n"
                                "</body>";
  const char* xmlstr_nodummy4 = "<p>test</p>";
  const char* xmlstr_nodummy5 = "<test1>\n"
                                "  <test2>test</test2>\n"
                                "</test1>";

  const char* xmlstr_dummy1 = "<p>test1</p><p>test2</p>";
  const char* xmlstr_dummy2 = "<test1>test1</test1><test2>test2</test2>";

  XMLNode_t       *rootnode;
  const XMLNode_t *child, *gchild;
  char *toxmlstring;

  // xmlstr_nodummy1 

  rootnode   = XMLNode_convertStringToXMLNode(xmlstr_nodummy1, NULL);
  fail_unless(XMLNode_getNumChildren(rootnode) == 1);

  child  = XMLNode_getChild(rootnode,0);
  gchild = XMLNode_getChild(child,0);

  fail_unless(strcmp(XMLNode_getName(rootnode), "notes") == 0);
  fail_unless(strcmp(XMLNode_getName(child),"p" ) == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_nodummy1) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_nodummy2 

  rootnode   = XMLNode_convertStringToXMLNode(xmlstr_nodummy2, NULL);
  fail_unless(XMLNode_getNumChildren(rootnode) == 1);

  child  = XMLNode_getChild(rootnode,0);
  gchild = XMLNode_getChild(child,0);

  fail_unless(strcmp(XMLNode_getName(rootnode), "html") == 0);
  fail_unless(strcmp(XMLNode_getName(child),"p" ) == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_nodummy2) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_nodummy3

  rootnode   = XMLNode_convertStringToXMLNode(xmlstr_nodummy3, NULL);
  fail_unless(XMLNode_getNumChildren(rootnode) == 1);

  child  = XMLNode_getChild(rootnode,0);
  gchild = XMLNode_getChild(child,0);

  fail_unless(strcmp(XMLNode_getName(rootnode), "body") == 0);
  fail_unless(strcmp(XMLNode_getName(child),"p" ) == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_nodummy3) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_nodummy4

  rootnode   = XMLNode_convertStringToXMLNode(xmlstr_nodummy4, NULL);
  fail_unless(XMLNode_getNumChildren(rootnode) == 1);

  child  = XMLNode_getChild(rootnode,0);
  fail_unless(strcmp(XMLNode_getName(rootnode), "p") == 0);
  fail_unless(strcmp(XMLNode_getCharacters(child),"test" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_nodummy4) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_nodummy5

  rootnode   = XMLNode_convertStringToXMLNode(xmlstr_nodummy5, NULL);
  fail_unless(XMLNode_getNumChildren(rootnode) == 1);

  child  = XMLNode_getChild(rootnode,0);
  gchild = XMLNode_getChild(child,0);

  fail_unless(strcmp(XMLNode_getName(rootnode), "test1") == 0);
  fail_unless(strcmp(XMLNode_getName(child),"test2" ) == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_nodummy5) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_dummy1

  rootnode    = XMLNode_convertStringToXMLNode(xmlstr_dummy1, NULL);
  fail_unless(XMLNode_isEOF(rootnode)          == 1);
  fail_unless(XMLNode_getNumChildren(rootnode) == 2);

  child   = XMLNode_getChild(rootnode,0);
  gchild  = XMLNode_getChild(child,0);
  fail_unless(strcmp(XMLNode_getName(child), "p") == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test1" ) == 0);

  child   = XMLNode_getChild(rootnode,1);
  gchild  = XMLNode_getChild(child,0);
  fail_unless(strcmp(XMLNode_getName(child), "p") == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test2" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_dummy1) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

  // xmlstr_dummy2

  rootnode    = XMLNode_convertStringToXMLNode(xmlstr_dummy2, NULL);
  fail_unless(XMLNode_isEOF(rootnode)          == 1);
  fail_unless(XMLNode_getNumChildren(rootnode) == 2);

  child   = XMLNode_getChild(rootnode,0);
  gchild  = XMLNode_getChild(child,0);
  fail_unless(strcmp(XMLNode_getName(child), "test1") == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test1" ) == 0);

  child   = XMLNode_getChild(rootnode,1);
  gchild  = XMLNode_getChild(child,0);
  fail_unless(strcmp(XMLNode_getName(child), "test2") == 0);
  fail_unless(strcmp(XMLNode_getCharacters(gchild),"test2" ) == 0);

  toxmlstring = XMLNode_toXMLString(rootnode);
  fail_unless( strcmp(toxmlstring, xmlstr_dummy2) == 0);

  XMLNode_free(rootnode);
  safe_free(toxmlstring);

}
END_TEST


START_TEST (test_XMLNode_insert)
{
  /* setup */

  XMLAttributes_t* attr = XMLAttributes_create();

  XMLTriple_t *trp_p  = XMLTriple_createWith("parent","","");
  XMLTriple_t *trp_c1 = XMLTriple_createWith("child1","","");
  XMLTriple_t *trp_c2 = XMLTriple_createWith("child2","","");
  XMLTriple_t *trp_c3 = XMLTriple_createWith("child3","","");
  XMLTriple_t *trp_c4 = XMLTriple_createWith("child4","","");
  XMLTriple_t *trp_c5 = XMLTriple_createWith("child5","","");

  XMLNode_t *p  = XMLNode_createStartElement(trp_p,  attr);
  XMLNode_t *c1 = XMLNode_createStartElement(trp_c1, attr);
  XMLNode_t *c2 = XMLNode_createStartElement(trp_c2, attr);
  XMLNode_t *c3 = XMLNode_createStartElement(trp_c3, attr);
  XMLNode_t *c4 = XMLNode_createStartElement(trp_c4, attr);
  XMLNode_t *c5 = XMLNode_createStartElement(trp_c5, attr);

  /* test of insert */

  XMLNode_addChild(p, c2);
  XMLNode_addChild(p, c4);
  XMLNode_insertChild(p, 0, c1);
  XMLNode_insertChild(p, 2, c3);
  XMLNode_insertChild(p, 4, c5);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,0)), "child1") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,1)), "child2") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,2)), "child3") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,3)), "child4") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,4)), "child5") == 0);

  XMLNode_removeChildren(p);

  XMLNode_insertChild(p, 0, c1);
  XMLNode_insertChild(p, 0, c2);
  XMLNode_insertChild(p, 0, c3);
  XMLNode_insertChild(p, 0, c4);
  XMLNode_insertChild(p, 0, c5);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,0)), "child5") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,1)), "child4") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,2)), "child3") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,3)), "child2") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,4)), "child1") == 0);

  XMLNode_removeChildren(p);

  /* test of insert by an index which is out of range */

  XMLNode_insertChild(p, 1, c1);
  XMLNode_insertChild(p, 2, c2);
  XMLNode_insertChild(p, 3, c3);
  XMLNode_insertChild(p, 4, c4);
  XMLNode_insertChild(p, 5, c5);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,0)), "child1") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,1)), "child2") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,2)), "child3") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,3)), "child4") == 0);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,4)), "child5") == 0);

  XMLNode_removeChildren(p);

  /* test for the return value of insert */

  XMLNode_t* tmp;

  tmp = XMLNode_insertChild(p, 0, c1);
  fail_unless(strcmp(XMLNode_getName(tmp),"child1") == 0);
  tmp = XMLNode_insertChild(p, 0, c2);
  fail_unless(strcmp(XMLNode_getName(tmp),"child2") == 0);
  tmp = XMLNode_insertChild(p, 0, c3);
  fail_unless(strcmp(XMLNode_getName(tmp),"child3") == 0);
  tmp = XMLNode_insertChild(p, 0, c4);
  fail_unless(strcmp(XMLNode_getName(tmp),"child4") == 0);
  tmp = XMLNode_insertChild(p, 0, c5);
  fail_unless(strcmp(XMLNode_getName(tmp),"child5") == 0);

  XMLNode_removeChildren(p);

  tmp = XMLNode_insertChild(p, 1, c1);
  fail_unless(strcmp(XMLNode_getName(tmp),"child1") == 0);
  tmp = XMLNode_insertChild(p, 2, c2);
  fail_unless(strcmp(XMLNode_getName(tmp),"child2") == 0);
  tmp = XMLNode_insertChild(p, 3, c3);
  fail_unless(strcmp(XMLNode_getName(tmp),"child3") == 0);
  tmp = XMLNode_insertChild(p, 4, c4);
  fail_unless(strcmp(XMLNode_getName(tmp),"child4") == 0);
  tmp = XMLNode_insertChild(p, 5, c5);
  fail_unless(strcmp(XMLNode_getName(tmp),"child5") == 0);

  /* teardown*/

  XMLNode_free(p);
  XMLNode_free(c1);
  XMLNode_free(c2);
  XMLNode_free(c3);
  XMLNode_free(c4);
  XMLNode_free(c5);
  XMLAttributes_free(attr);
  XMLTriple_free(trp_p);
  XMLTriple_free(trp_c1);
  XMLTriple_free(trp_c2);
  XMLTriple_free(trp_c3);
  XMLTriple_free(trp_c4);
  XMLTriple_free(trp_c5);

}
END_TEST


START_TEST (test_XMLNode_remove)
{
  /* setup */

  XMLAttributes_t* attr = XMLAttributes_create();

  XMLTriple_t *trp_p  = XMLTriple_createWith("parent","","");
  XMLTriple_t *trp_c1 = XMLTriple_createWith("child1","","");
  XMLTriple_t *trp_c2 = XMLTriple_createWith("child2","","");
  XMLTriple_t *trp_c3 = XMLTriple_createWith("child3","","");
  XMLTriple_t *trp_c4 = XMLTriple_createWith("child4","","");
  XMLTriple_t *trp_c5 = XMLTriple_createWith("child5","","");

  XMLNode_t *p  = XMLNode_createStartElement(trp_p,  attr);
  XMLNode_t *c1 = XMLNode_createStartElement(trp_c1, attr);
  XMLNode_t *c2 = XMLNode_createStartElement(trp_c2, attr);
  XMLNode_t *c3 = XMLNode_createStartElement(trp_c3, attr);
  XMLNode_t *c4 = XMLNode_createStartElement(trp_c4, attr);
  XMLNode_t *c5 = XMLNode_createStartElement(trp_c5, attr);

  /* test of remove */

  XMLNode_t* r;

  XMLNode_addChild(p, c1);
  XMLNode_addChild(p, c2);
  XMLNode_addChild(p, c3);
  XMLNode_addChild(p, c4);
  XMLNode_addChild(p, c5);

  r = XMLNode_removeChild(p, 5);
  fail_unless( r == NULL );

  r = XMLNode_removeChild(p, 1);
  fail_unless(XMLNode_getNumChildren(p) == 4);
  fail_unless(strcmp(XMLNode_getName(r),"child2") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 3);
  fail_unless(XMLNode_getNumChildren(p) == 3);
  fail_unless(strcmp(XMLNode_getName(r),"child5") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 2);
  fail_unless(strcmp(XMLNode_getName(r),"child1") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 1);
  fail_unless(XMLNode_getNumChildren(p) == 1);
  fail_unless(strcmp(XMLNode_getName(r),"child4") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 0);
  fail_unless(strcmp(XMLNode_getName(r),"child3") == 0);
  XMLNode_free(r);

  /* test of sequential remove (in reverse order) */

  XMLNode_addChild(p, c1);
  XMLNode_addChild(p, c2);
  XMLNode_addChild(p, c3);
  XMLNode_addChild(p, c4);
  XMLNode_addChild(p, c5);

  r = XMLNode_removeChild(p, 4);
  fail_unless(XMLNode_getNumChildren(p) == 4);
  fail_unless(strcmp(XMLNode_getName(r),"child5") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 3);
  fail_unless(XMLNode_getNumChildren(p) == 3);
  fail_unless(strcmp(XMLNode_getName(r),"child4") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 2);
  fail_unless(XMLNode_getNumChildren(p) == 2);
  fail_unless(strcmp(XMLNode_getName(r),"child3") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 1);
  fail_unless(XMLNode_getNumChildren(p) == 1);
  fail_unless(strcmp(XMLNode_getName(r),"child2") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 0);
  fail_unless(strcmp(XMLNode_getName(r),"child1") == 0);
  XMLNode_free(r);

  /* test of sequential remove*/

  XMLNode_addChild(p, c1);
  XMLNode_addChild(p, c2);
  XMLNode_addChild(p, c3);
  XMLNode_addChild(p, c4);
  XMLNode_addChild(p, c5);


  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 4);
  fail_unless(strcmp(XMLNode_getName(r),"child1") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 3);
  fail_unless(strcmp(XMLNode_getName(r),"child2") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 2);
  fail_unless(strcmp(XMLNode_getName(r),"child3") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 1);
  fail_unless(strcmp(XMLNode_getName(r),"child4") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 0);
  fail_unless(XMLNode_getNumChildren(p) == 0);
  fail_unless(strcmp(XMLNode_getName(r),"child5") == 0);
  XMLNode_free(r);


  /* test of sequential remove and insert */

  XMLNode_addChild(p, c1);
  XMLNode_addChild(p, c2);
  XMLNode_addChild(p, c3);
  XMLNode_addChild(p, c4);
  XMLNode_addChild(p, c5);

  r = XMLNode_removeChild(p, 0);
  fail_unless(strcmp(XMLNode_getName(r),"child1") == 0);
  XMLNode_insertChild(p, 0, r);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,0)),"child1") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 1);
  fail_unless(strcmp(XMLNode_getName(r),"child2") == 0);
  XMLNode_insertChild(p, 1, r);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,1)),"child2") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 2);
  fail_unless(strcmp(XMLNode_getName(r),"child3") == 0);
  XMLNode_insertChild(p, 2, r);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,2)),"child3") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 3);
  fail_unless(strcmp(XMLNode_getName(r),"child4") == 0);
  XMLNode_insertChild(p, 3, r);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,3)),"child4") == 0);
  XMLNode_free(r);

  r = XMLNode_removeChild(p, 4);
  fail_unless(strcmp(XMLNode_getName(r),"child5") == 0);
  XMLNode_insertChild(p, 4, r);
  fail_unless(XMLNode_getNumChildren(p) == 5);
  fail_unless(strcmp(XMLNode_getName(XMLNode_getChild(p,4)),"child5") == 0);
  XMLNode_free(r);

  /* teardown*/

  XMLNode_free(p);
  XMLNode_free(c1);
  XMLNode_free(c2);
  XMLNode_free(c3);
  XMLNode_free(c4);
  XMLNode_free(c5);
  XMLAttributes_free(attr);
  XMLTriple_free(trp_p);
  XMLTriple_free(trp_c1);
  XMLTriple_free(trp_c2);
  XMLTriple_free(trp_c3);
  XMLTriple_free(trp_c4);
  XMLTriple_free(trp_c5);

}
END_TEST


START_TEST (test_XMLNode_namespace_add)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);

  fail_unless( XMLNode_getNamespacesLength(node) == 0 );
  fail_unless( XMLNode_isNamespacesEmpty(node)  == 1 );

  XMLNode_addNamespace(node, "http://test1.org/", "test1");
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  fail_unless( XMLNode_isNamespacesEmpty(node)  == 0 );

  XMLNode_addNamespace(node, "http://test2.org/", "test2");
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  fail_unless( XMLNode_isNamespacesEmpty(node)  == 0 );

  XMLNode_addNamespace(node, "http://test1.org/", "test1a");
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  fail_unless( XMLNode_isNamespacesEmpty(node)  == 0 );

  XMLNode_addNamespace(node, "http://test1.org/", "test1a");
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  fail_unless( XMLNode_isNamespacesEmpty(node)  == 0 );

  fail_if( XMLNode_getNamespaceIndex(node, "http://test1.org/") == -1);

  XMLNode_free(node);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLNode_namespace_get)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);

  XMLNode_addNamespace(node, "http://test1.org/", "test1");    /* index 0 */
  XMLNode_addNamespace(node, "http://test2.org/", "test2");    /* index 1 */
  XMLNode_addNamespace(node, "http://test3.org/", "test3");    /* index 2 */
  XMLNode_addNamespace(node, "http://test4.org/", "test4");    /* index 3 */
  XMLNode_addNamespace(node, "http://test5.org/", "test5");    /* index 4 */
  XMLNode_addNamespace(node, "http://test6.org/", "test6");    /* index 5 */
  XMLNode_addNamespace(node, "http://test7.org/", "test7");    /* index 6 */
  XMLNode_addNamespace(node, "http://test8.org/", "test8");    /* index 7 */
  XMLNode_addNamespace(node, "http://test9.org/", "test9");    /* index 8 */

  fail_unless( XMLNode_getNamespacesLength(node) == 9 );

  fail_unless( XMLNode_getNamespaceIndex(node, "http://test1.org/") == 0 );
  fail_unless( strcmp(XMLNode_getNamespacePrefix(node, 1), "test2") == 0 );
  fail_unless( strcmp(XMLNode_getNamespacePrefixByURI(node, "http://test1.org/"),
		      "test1") == 0 );
  fail_unless( strcmp(XMLNode_getNamespaceURI(node, 1), "http://test2.org/") == 0 );
  fail_unless( strcmp(XMLNode_getNamespaceURIByPrefix(node, "test2"),
		      "http://test2.org/") == 0 );

  fail_unless( XMLNode_getNamespaceIndex(node, "http://test1.org/") ==  0 );
  fail_unless( XMLNode_getNamespaceIndex(node, "http://test2.org/") ==  1 );
  fail_unless( XMLNode_getNamespaceIndex(node, "http://test5.org/") ==  4 );
  fail_unless( XMLNode_getNamespaceIndex(node, "http://test9.org/") ==  8 );
  fail_unless( XMLNode_getNamespaceIndex(node, "http://testX.org/") == -1 );

  fail_unless( XMLNode_hasNamespaceURI(node, "http://test1.org/") !=  0 );
  fail_unless( XMLNode_hasNamespaceURI(node, "http://test2.org/") !=  0 );
  fail_unless( XMLNode_hasNamespaceURI(node, "http://test5.org/") !=  0 );
  fail_unless( XMLNode_hasNamespaceURI(node, "http://test9.org/") !=  0 );
  fail_unless( XMLNode_hasNamespaceURI(node, "http://testX.org/") ==  0 );

  fail_unless( XMLNode_getNamespaceIndexByPrefix(node, "test1") ==  0 );
  fail_unless( XMLNode_getNamespaceIndexByPrefix(node, "test5") ==  4 );
  fail_unless( XMLNode_getNamespaceIndexByPrefix(node, "test9") ==  8 );
  fail_unless( XMLNode_getNamespaceIndexByPrefix(node, "testX") == -1 );

  fail_unless( XMLNode_hasNamespacePrefix(node, "test1") !=  0 );
  fail_unless( XMLNode_hasNamespacePrefix(node, "test5") !=  0 );
  fail_unless( XMLNode_hasNamespacePrefix(node, "test9") !=  0 );
  fail_unless( XMLNode_hasNamespacePrefix(node, "testX") ==  0 );

  fail_unless( XMLNode_hasNamespaceNS(node, "http://test1.org/", "test1") !=  0 );
  fail_unless( XMLNode_hasNamespaceNS(node, "http://test5.org/", "test5") !=  0 );
  fail_unless( XMLNode_hasNamespaceNS(node, "http://test9.org/", "test9") !=  0 );
  fail_unless( XMLNode_hasNamespaceNS(node, "http://testX.org/", "testX") ==  0 );

  XMLNode_free(node);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLNode_namespace_remove)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);

  XMLNode_addNamespace(node, "http://test1.org/", "test1"); 
  XMLNode_addNamespace(node, "http://test2.org/", "test2");
  XMLNode_addNamespace(node, "http://test3.org/", "test3"); 
  XMLNode_addNamespace(node, "http://test4.org/", "test4");
  XMLNode_addNamespace(node, "http://test5.org/", "test5");

  fail_unless( XMLNode_getNamespacesLength(node) == 5 );
  XMLNode_removeNamespace(node, 4);
  fail_unless( XMLNode_getNamespacesLength(node) == 4 );
  XMLNode_removeNamespace(node, 3);
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  XMLNode_removeNamespace(node, 2);
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  XMLNode_removeNamespace(node, 1);
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );


  XMLNode_addNamespace(node, "http://test1.org/", "test1");
  XMLNode_addNamespace(node, "http://test2.org/", "test2");
  XMLNode_addNamespace(node, "http://test3.org/", "test3");
  XMLNode_addNamespace(node, "http://test4.org/", "test4");
  XMLNode_addNamespace(node, "http://test5.org/", "test5");

  fail_unless( XMLNode_getNamespacesLength(node) == 5 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 4 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  XMLNode_removeNamespace(node, 0);
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );

  XMLNode_free(node);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLNode_namespace_remove_by_prefix)
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);


  XMLNode_addNamespace(node, "http://test1.org/", "test1"); 
  XMLNode_addNamespace(node, "http://test2.org/", "test2");
  XMLNode_addNamespace(node, "http://test3.org/", "test3"); 
  XMLNode_addNamespace(node, "http://test4.org/", "test4");
  XMLNode_addNamespace(node, "http://test5.org/", "test5");

  fail_unless( XMLNode_getNamespacesLength(node) == 5 );
  XMLNode_removeNamespaceByPrefix(node, "test1");
  fail_unless( XMLNode_getNamespacesLength(node) == 4 );
  XMLNode_removeNamespaceByPrefix(node, "test2");
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  XMLNode_removeNamespaceByPrefix(node, "test3");
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  XMLNode_removeNamespaceByPrefix(node, "test4");
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  XMLNode_removeNamespaceByPrefix(node, "test5");
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );

  XMLNode_addNamespace(node, "http://test1.org/", "test1");
  XMLNode_addNamespace(node, "http://test2.org/", "test2");
  XMLNode_addNamespace(node, "http://test3.org/", "test3");
  XMLNode_addNamespace(node, "http://test4.org/", "test4");
  XMLNode_addNamespace(node, "http://test5.org/", "test5");

  fail_unless( XMLNode_getNamespacesLength(node) == 5 );
  XMLNode_removeNamespaceByPrefix(node, "test5");
  fail_unless( XMLNode_getNamespacesLength(node) == 4 );
  XMLNode_removeNamespaceByPrefix(node, "test4");
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  XMLNode_removeNamespaceByPrefix(node, "test3");
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  XMLNode_removeNamespaceByPrefix(node, "test2");
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  XMLNode_removeNamespaceByPrefix(node, "test1");
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );

  XMLNode_addNamespace(node, "http://test1.org/", "test1"); 
  XMLNode_addNamespace(node, "http://test2.org/", "test2"); 
  XMLNode_addNamespace(node, "http://test3.org/", "test3");
  XMLNode_addNamespace(node, "http://test4.org/", "test4");
  XMLNode_addNamespace(node, "http://test5.org/", "test5");

  fail_unless( XMLNode_getNamespacesLength(node) == 5 );
  XMLNode_removeNamespaceByPrefix(node, "test3");
  fail_unless( XMLNode_getNamespacesLength(node) == 4 );
  XMLNode_removeNamespaceByPrefix(node, "test1");
  fail_unless( XMLNode_getNamespacesLength(node) == 3 );
  XMLNode_removeNamespaceByPrefix(node, "test4");
  fail_unless( XMLNode_getNamespacesLength(node) == 2 );
  XMLNode_removeNamespaceByPrefix(node, "test5");
  fail_unless( XMLNode_getNamespacesLength(node) == 1 );
  XMLNode_removeNamespaceByPrefix(node, "test2");
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );

  XMLNode_free(node);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST (test_XMLNode_namespace_set_clear )
{
  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);
  XMLNamespaces_t* ns = XMLNamespaces_create();

  fail_unless( XMLNode_getNamespacesLength(node) == 0 );
  fail_unless( XMLNode_isNamespacesEmpty(node)   == 1 );  

  XMLNamespaces_add(ns, "http://test1.org/", "test1"); 
  XMLNamespaces_add(ns, "http://test2.org/", "test2");
  XMLNamespaces_add(ns, "http://test3.org/", "test3"); 
  XMLNamespaces_add(ns, "http://test4.org/", "test4");
  XMLNamespaces_add(ns, "http://test5.org/", "test5");

  XMLNode_setNamespaces(node, ns);

  fail_unless(XMLNode_getNamespacesLength(node) == 5 );
  fail_unless(XMLNode_isNamespacesEmpty(node)   == 0 );  
  fail_unless(strcmp(XMLNode_getNamespacePrefix(node, 0), "test1") == 0 );
  fail_unless(strcmp(XMLNode_getNamespacePrefix(node, 1), "test2") == 0 );
  fail_unless(strcmp(XMLNode_getNamespacePrefix(node, 2), "test3") == 0 );
  fail_unless(strcmp(XMLNode_getNamespacePrefix(node, 3), "test4") == 0 );
  fail_unless(strcmp(XMLNode_getNamespacePrefix(node, 4), "test5") == 0 );
  fail_unless(strcmp(XMLNode_getNamespaceURI(node, 0), "http://test1.org/") == 0 );
  fail_unless(strcmp(XMLNode_getNamespaceURI(node, 1), "http://test2.org/") == 0 );
  fail_unless(strcmp(XMLNode_getNamespaceURI(node, 2), "http://test3.org/") == 0 );
  fail_unless(strcmp(XMLNode_getNamespaceURI(node, 3), "http://test4.org/") == 0 );
  fail_unless(strcmp(XMLNode_getNamespaceURI(node, 4), "http://test5.org/") == 0 );

  XMLNode_clearNamespaces(node);
  fail_unless( XMLNode_getNamespacesLength(node) == 0 );
  fail_unless( XMLNode_isAttributesEmpty(node)   != 0 );

  XMLNamespaces_free(ns);
  XMLNode_free(node);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST(test_XMLNode_attribute_add_remove)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);
  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");
  XMLTriple_t* xt3    = XMLTriple_createWith("name3", "http://name3.org/", "p3");
  XMLTriple_t* xt1a   = XMLTriple_createWith("name1", "http://name1a.org/", "p1a");
  XMLTriple_t* xt2a   = XMLTriple_createWith("name2", "http://name2a.org/", "p2a");

  /*-- test of adding attributes with namespace --*/

  XMLNode_addAttrWithNS(node, "name1", "val1", "http://name1.org/", "p1");
  XMLNode_addAttrWithTriple(node, xt2, "val2");
  fail_unless( XMLNode_getAttributesLength(node) == 2 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );

  fail_unless( strcmp(XMLNode_getAttrName  (node, 0), "name1") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 0), "val1" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 1), "name2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 1), "val2" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 1), "p2"   ) == 0 );
  fail_unless( XMLNode_getAttrValueByName (node, "name1") == NULL );
  fail_unless( XMLNode_getAttrValueByName (node, "name2") == NULL );
  fail_unless( strcmp(XMLNode_getAttrValueByNS (node, "name1", "http://name1.org/"), "val1" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByNS (node, "name2", "http://name2.org/"), "val2" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByTriple (node, xt1), "val1" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByTriple (node, xt2), "val2" ) == 0 );

  fail_unless( XMLNode_hasAttr(node, -1) == 0 );
  fail_unless( XMLNode_hasAttr(node,  2) == 0 );
  fail_unless( XMLNode_hasAttr(node,  0) == 1 );
  fail_unless( XMLNode_hasAttrWithNS(node, "name1", "http://name1.org/")   == 1 );
  fail_unless( XMLNode_hasAttrWithNS(node, "name2", "http://name2.org/")   == 1 );
  fail_unless( XMLNode_hasAttrWithNS(node, "name3", "http://name3.org/")   == 0 );
  fail_unless( XMLNode_hasAttrWithTriple(node, xt1)   == 1 );
  fail_unless( XMLNode_hasAttrWithTriple(node, xt2)   == 1 );
  fail_unless( XMLNode_hasAttrWithTriple(node, xt3)   == 0 );

  /*-- test of adding an attribute without namespace --*/

  XMLNode_addAttr(node, "noprefix", "val3");
  fail_unless( XMLNode_getAttributesLength(node) == 3 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );
  fail_unless( strcmp(XMLNode_getAttrName (node, 2), "noprefix") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue(node, 2), "val3"    ) == 0 );
  fail_unless( XMLNode_getAttrURI    (node, 2) == NULL );
  fail_unless( XMLNode_getAttrPrefix (node, 2) == NULL );
  fail_unless( strcmp(XMLNode_getAttrValueByName (node, "noprefix"),     "val3" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByNS   (node, "noprefix", ""), "val3" ) == 0 );
  fail_unless( XMLNode_hasAttrWithName (node, "noprefix"    ) == 1 );
  fail_unless( XMLNode_hasAttrWithNS   (node, "noprefix", "") == 1 );

  /*-- test of overwriting existing attributes with namespace --*/

  XMLNode_addAttrWithTriple(node, xt1, "mval1");
  XMLNode_addAttrWithNS(node, "name2", "mval2", "http://name2.org/", "p2");

  fail_unless( XMLNode_getAttributesLength(node) == 3 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );

  fail_unless( strcmp(XMLNode_getAttrName  (node, 0), "name1") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 0), "mval1") == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 1), "name2"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 1), "mval2"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 1), "p2"      ) == 0 );
  fail_unless( XMLNode_hasAttrWithTriple(node, xt1) == 1 );
  fail_unless( XMLNode_hasAttrWithNS(node, "name1", "http://name1.org/")   == 1 );

  /*-- test of overwriting an existing attribute without namespace --*/

  XMLNode_addAttr(node, "noprefix", "mval3");
  fail_unless( XMLNode_getAttributesLength(node) == 3 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 2), "noprefix") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 2), "mval3"   ) == 0 );
  fail_unless(        XMLNode_getAttrURI   (node, 2) == NULL );
  fail_unless(        XMLNode_getAttrPrefix(node, 2) == NULL );
  fail_unless( XMLNode_hasAttrWithName (node, "noprefix") == 1 );
  fail_unless( XMLNode_hasAttrWithNS   (node, "noprefix", "") == 1 );

  /*-- test of overwriting existing attributes with the given triple --*/

  XMLNode_addAttrWithTriple(node, xt1a, "val1a");
  XMLNode_addAttrWithTriple(node, xt2a, "val2a");
  fail_unless( XMLNode_getAttributesLength(node) == 5 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 3), "name1") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 3), "val1a") == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 3), "http://name1a.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 3), "p1a") == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 4), "name2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 4), "val2a") == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 4), "http://name2a.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 4), "p2a") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByNS (node, "name1", "http://name1a.org/"), "val1a" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByNS (node, "name2", "http://name2a.org/"), "val2a" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByTriple (node, xt1a), "val1a" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrValueByTriple (node, xt2a), "val2a" ) == 0 );

  /*-- test of removing attributes with namespace --*/

  XMLNode_removeAttrByTriple(node, xt1a);
  XMLNode_removeAttrByTriple(node, xt2a);
  fail_unless( XMLNode_getAttributesLength(node) == 3 );

  XMLNode_removeAttrByNS(node, "name1", "http://name1.org/");
  fail_unless( XMLNode_getAttributesLength(node) == 2 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 0), "name2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 0), "mval2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 0), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 0), "p2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 1), "noprefix") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 1), "mval3") == 0 );
  fail_unless(        XMLNode_getAttrURI   (node, 1) == NULL);
  fail_unless(        XMLNode_getAttrPrefix(node, 1) == NULL);
  fail_unless( XMLNode_hasAttrWithNS(node, "name1", "http://name1.org/")   == 0 );

  XMLNode_removeAttrByTriple(node, xt2);
  fail_unless( XMLNode_getAttributesLength(node) == 1 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 0 );
  fail_unless( strcmp(XMLNode_getAttrName (node, 0), "noprefix") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue(node, 0), "mval3") == 0 );
  fail_unless(       XMLNode_getAttrURI   (node, 0) == NULL );
  fail_unless(       XMLNode_getAttrPrefix(node, 0) == NULL );
  fail_unless( XMLNode_hasAttrWithTriple(node, xt2) == 0 );
  fail_unless( XMLNode_hasAttrWithNS(node, "name2", "http://name2.org/")   == 0 );

  /*-- test of removing attributes without namespace --*/

  XMLNode_removeAttrByName(node, "noprefix");
  fail_unless( XMLNode_getAttributesLength(node) == 0 );
  fail_unless( XMLNode_isAttributesEmpty(node)   == 1 );
  fail_unless( XMLNode_hasAttrWithName(node, "noprefix"    ) == 0 );
  fail_unless( XMLNode_hasAttrWithNS  (node, "noprefix", "") == 0 );

  /*-- teardown --*/

  XMLNode_free(node);
  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(xt3);
  XMLTriple_free(xt1a);
  XMLTriple_free(xt2a);
  XMLTriple_free(triple);
  XMLAttributes_free(attr);
}
END_TEST


START_TEST(test_XMLNode_attribute_set_clear)
{
  /*-- setup --*/

  XMLTriple_t*     triple = XMLTriple_createWith("test","","");
  XMLAttributes_t* attr   = XMLAttributes_create();
  XMLNode_t*       node   = XMLNode_createStartElement(triple, attr);
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

  XMLNode_setAttributes(node, nattr);
  fail_unless(XMLNode_getAttributesLength(node) == 5 );
  fail_unless(XMLNode_isAttributesEmpty(node)   == 0 );

  fail_unless( strcmp(XMLNode_getAttrName  (node, 0), "name1") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 0), "val1" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 0), "http://name1.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 0), "p1"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 1), "name2") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 1), "val2" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 1), "http://name2.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 1), "p2"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 2), "name3") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 2), "val3" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 2), "http://name3.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 2), "p3"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 3), "name4") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 3), "val4" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 3), "http://name4.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 3), "p4"   ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrName  (node, 4), "name5") == 0 );
  fail_unless( strcmp(XMLNode_getAttrValue (node, 4), "val5" ) == 0 );
  fail_unless( strcmp(XMLNode_getAttrURI   (node, 4), "http://name5.org/") == 0 );
  fail_unless( strcmp(XMLNode_getAttrPrefix(node, 4), "p5"   ) == 0 );

  /*-- test of setTriple -- */

  XMLTriple_t* ntriple = XMLTriple_createWith("test2","http://test2.org/","p2");  
  XMLNode_setTriple(node, ntriple);
  fail_unless(strcmp(XMLNode_getName(node),   "test2") == 0);
  fail_unless(strcmp(XMLNode_getURI(node),    "http://test2.org/") == 0);
  fail_unless(strcmp(XMLNode_getPrefix(node), "p2") == 0);

  /*-- test of clearing attributes -- */

  XMLNode_clearAttributes(node);
  fail_unless( XMLNode_getAttributesLength(node) == 0 );
  fail_unless( XMLNode_isAttributesEmpty(node)   != 0 );

  /*-- teardown --*/

  XMLTriple_free(triple);
  XMLTriple_free(ntriple);
  XMLNode_free(node);
  XMLAttributes_free(attr);
  XMLAttributes_free(nattr);
  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(xt3);
  XMLTriple_free(xt4);
  XMLTriple_free(xt5);

}
END_TEST

//
//START_TEST(test_XMLInputStream_assignment)
//{
//	const char* xmlstr1 = "<annotation>\n"
//	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
//	"</annotation>";
//  const char* xmlstr2= "<annotations>\n"
//	"  <test xmlns=\"http://test.org/\" id=\"test\">test</test>\n"
//	"</annotations>";
//
//  XMLInputStream stream(xmlstr1, false);
//  XMLNode node(stream);
//  fail_unless(node.getName() == "annotation");
//  stream = XMLInputStream(xmlstr2, false);
//  fail_unless(stream.isError() == true);
//}
//END_TEST
//

Suite *
create_suite_XMLNode (void)
{
  Suite *suite = suite_create("XMLNode");
  TCase *tcase = tcase_create("XMLNode");

  //tcase_add_test( tcase, test_XMLInputStream_assignment );
  tcase_add_test( tcase, test_XMLNode_getIndex  );
  tcase_add_test( tcase, test_XMLNode_hasChild  );
  tcase_add_test( tcase, test_XMLNode_getChildForName  );
  tcase_add_test( tcase, test_XMLNode_equals  );
  tcase_add_test( tcase, test_XMLNode_create  );
  tcase_add_test( tcase, test_XMLNode_createFromToken  );
  tcase_add_test( tcase, test_XMLNode_createElement  );
  tcase_add_test( tcase, test_XMLNode_getters  );
  tcase_add_test( tcase, test_XMLNode_convert  );
  tcase_add_test( tcase, test_XMLNode_convert_dummyroot  );
  tcase_add_test( tcase, test_XMLNode_insert  );
  tcase_add_test( tcase, test_XMLNode_remove  );
  tcase_add_test( tcase, test_XMLNode_namespace_add );
  tcase_add_test( tcase, test_XMLNode_namespace_get );
  tcase_add_test( tcase, test_XMLNode_namespace_remove );
  tcase_add_test( tcase, test_XMLNode_namespace_remove_by_prefix );
  tcase_add_test( tcase, test_XMLNode_namespace_set_clear );
  tcase_add_test( tcase, test_XMLNode_attribute_add_remove);
  tcase_add_test( tcase, test_XMLNode_attribute_set_clear);
  suite_add_tcase(suite, tcase);

  return suite;
}

CK_CPPEND

