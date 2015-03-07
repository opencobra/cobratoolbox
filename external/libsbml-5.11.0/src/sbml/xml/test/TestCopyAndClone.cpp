/**
 * \file    TestReadSBML.cpp
 * \brief   Read SBML unit tests
 * \author  Ben Bornstein
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
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>


#include <check.h>
using namespace std;
LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART
START_TEST ( test_NS_copyConstructor )
{
  XMLNamespaces * ns = new XMLNamespaces();
  ns->add("http://test1.org/", "test1");
  
  fail_unless( ns->getLength() == 1 );
  fail_unless( ns->isEmpty() == 0 );
  fail_unless(ns->getPrefix(0) == "test1");
  fail_unless(ns->getURI("test1") == "http://test1.org/");

  XMLNamespaces * ns2 = new XMLNamespaces(*ns);

  fail_unless( ns2->getLength() == 1 );
  fail_unless( ns2->isEmpty() == 0 );
  fail_unless(ns2->getPrefix(0) == "test1");
  fail_unless(ns2->getURI("test1") == "http://test1.org/");

  delete ns2;
  delete ns;
}
END_TEST

START_TEST ( test_NS_assignmentOperator )
{
  XMLNamespaces * ns = new XMLNamespaces();
  ns->add("http://test1.org/", "test1");
  
  fail_unless( ns->getLength() == 1 );
  fail_unless( ns->isEmpty() == 0 );
  fail_unless(ns->getPrefix(0) == "test1");
  fail_unless(ns->getURI("test1") == "http://test1.org/");

  XMLNamespaces * ns2 = new XMLNamespaces();
  (*ns2) = *ns;

  fail_unless( ns2->getLength() == 1 );
  fail_unless( ns2->isEmpty() == 0 );
  fail_unless(ns2->getPrefix(0) == "test1");
  fail_unless(ns2->getURI("test1") == "http://test1.org/");

  delete ns2;
  delete ns;
}
END_TEST


START_TEST ( test_NS_clone )
{
  XMLNamespaces * ns = new XMLNamespaces();
  ns->add("http://test1.org/", "test1");
  
  fail_unless( ns->getLength() == 1 );
  fail_unless( ns->isEmpty() == 0 );
  fail_unless(ns->getPrefix(0) == "test1");
  fail_unless(ns->getURI("test1") == "http://test1.org/");

  XMLNamespaces * ns2 = static_cast<XMLNamespaces*>(ns->clone());

  fail_unless( ns2->getLength() == 1 );
  fail_unless( ns2->isEmpty() == 0 );
  fail_unless(ns2->getPrefix(0) == "test1");
  fail_unless(ns2->getURI("test1") == "http://test1.org/");

  delete ns2;
  delete ns;
}
END_TEST


START_TEST ( test_Triple_copyConstructor )
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");

  fail_unless (t->getName() == "sarah");
  fail_unless (t->getURI() == "http://foo.org/");
  fail_unless (t->getPrefix() == "bar");

  XMLTriple *t2 = new XMLTriple(*t);

  fail_unless (t2->getName() == "sarah");
  fail_unless (t2->getURI() == "http://foo.org/");
  fail_unless (t2->getPrefix() == "bar");

  delete t;
  delete t2;
}
END_TEST


START_TEST ( test_Triple_assignmentOperator )
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");

  fail_unless (t->getName() == "sarah");
  fail_unless (t->getURI() == "http://foo.org/");
  fail_unless (t->getPrefix() == "bar");

  XMLTriple *t2 = new XMLTriple;
  (*t2) = *t;

  fail_unless (t2->getName() == "sarah");
  fail_unless (t2->getURI() == "http://foo.org/");
  fail_unless (t2->getPrefix() == "bar");

  delete t;
  delete t2;
}
END_TEST

START_TEST ( test_Triple_clone )
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");

  fail_unless (t->getName() == "sarah");
  fail_unless (t->getURI() == "http://foo.org/");
  fail_unless (t->getPrefix() == "bar");

  XMLTriple * t2 = static_cast<XMLTriple*>(t->clone());

  fail_unless (t2->getName() == "sarah");
  fail_unless (t2->getURI() == "http://foo.org/");
  fail_unless (t2->getPrefix() == "bar");

  delete t;
  delete t2;
}
END_TEST

START_TEST (test_Token_copyConstructor)
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, 3, 4);

  fail_unless(token->getName() == "sarah");
  fail_unless(token->getURI() == "http://foo.org/");
  fail_unless(token->getPrefix() == "bar");
  fail_unless(token->isEnd() == 1);
  fail_unless(token->isEOF() == 0);
  fail_unless(token->getLine() == 3);
  fail_unless(token->getColumn() == 4);

  XMLToken *token2 = new XMLToken(*token);

  fail_unless(token2->getName() == "sarah");
  fail_unless(token2->getURI() == "http://foo.org/");
  fail_unless(token2->getPrefix() == "bar");
  fail_unless(token2->isEnd() == 1);
  fail_unless(token2->isEOF() == 0);
  fail_unless(token2->getLine() == 3);
  fail_unless(token2->getColumn() == 4);

  delete t;
  delete token;
  delete token2;
}
END_TEST

START_TEST (test_Token_assignmentOperator)
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, 3, 4);

  fail_unless(token->getName() == "sarah");
  fail_unless(token->getURI() == "http://foo.org/");
  fail_unless(token->getPrefix() == "bar");
  fail_unless(token->isEnd() == 1);
  fail_unless(token->isEOF() == 0);
  fail_unless(token->getLine() == 3);
  fail_unless(token->getColumn() == 4);

  XMLToken *token2 = new XMLToken();
  (*token2) = *token;

  fail_unless(token2->getName() == "sarah");
  fail_unless(token2->getURI() == "http://foo.org/");
  fail_unless(token2->getPrefix() == "bar");
  fail_unless(token2->isEnd() == 1);
  fail_unless(token2->isEOF() == 0);
  fail_unless(token2->getLine() == 3);
  fail_unless(token2->getColumn() == 4);

  delete t;
  delete token;
  delete token2;
}
END_TEST

START_TEST (test_Token_clone)
{
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, 3, 4);

  fail_unless(token->getName() == "sarah");
  fail_unless(token->getURI() == "http://foo.org/");
  fail_unless(token->getPrefix() == "bar");
  fail_unless(token->isEnd() == 1);
  fail_unless(token->isEOF() == 0);
  fail_unless(token->getLine() == 3);
  fail_unless(token->getColumn() == 4);

  XMLToken *token2 = static_cast<XMLToken*>(token->clone());

  fail_unless(token2->getName() == "sarah");
  fail_unless(token2->getURI() == "http://foo.org/");
  fail_unless(token2->getPrefix() == "bar");
  fail_unless(token2->isEnd() == 1);
  fail_unless(token2->isEOF() == 0);
  fail_unless(token2->getLine() == 3);
  fail_unless(token2->getColumn() == 4);

  delete t;
  delete token;
  delete token2;
}
END_TEST

START_TEST (test_Node_copyConstructor)
{
  XMLAttributes *att = new XMLAttributes();
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, *att, 3, 4);
  XMLNode *node = new XMLNode(*token);
  XMLNode *child = new XMLNode();
  node->addChild(*child);

  fail_unless(node->getNumChildren() == 1);
  fail_unless(node->getName() == "sarah");
  fail_unless(node->getURI() == "http://foo.org/");
  fail_unless(node->getPrefix() == "bar");
  fail_unless(node->isEnd() == 0);
  fail_unless(node->isEOF() == 0);
  fail_unless(node->getLine() == 3);
  fail_unless(node->getColumn() == 4);

  XMLNode *node2 = new XMLNode(*node);

  fail_unless(node2->getNumChildren() == 1);
  fail_unless(node2->getName() == "sarah");
  fail_unless(node2->getURI() == "http://foo.org/");
  fail_unless(node2->getPrefix() == "bar");
  fail_unless(node2->isEnd() == 0);
  fail_unless(node2->isEOF() == 0);
  fail_unless(node2->getLine() == 3);
  fail_unless(node2->getColumn() == 4);

  delete t;
  delete token;
  delete node;
  delete node2;
  delete child;
  delete att;

}
END_TEST
  
START_TEST (test_Node_assignmentOperator)
{
  XMLAttributes *att = new XMLAttributes();
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, *att, 3, 4);
  XMLNode *node = new XMLNode(*token);
  XMLNode *child = new XMLNode();
  node->addChild(*child);

  fail_unless(node->getNumChildren() == 1);
  fail_unless(node->getName() == "sarah");
  fail_unless(node->getURI() == "http://foo.org/");
  fail_unless(node->getPrefix() == "bar");
  fail_unless(node->isEnd() == 0);
  fail_unless(node->isEOF() == 0);
  fail_unless(node->getLine() == 3);
  fail_unless(node->getColumn() == 4);

  XMLNode *node2 = new XMLNode();
  (*node2) = *node;

  fail_unless(node2->getNumChildren() == 1);
  fail_unless(node2->getName() == "sarah");
  fail_unless(node2->getURI() == "http://foo.org/");
  fail_unless(node2->getPrefix() == "bar");
  fail_unless(node2->isEnd() == 0);
  fail_unless(node2->isEOF() == 0);
  fail_unless(node2->getLine() == 3);
  fail_unless(node2->getColumn() == 4);

  delete t;
  delete token;
  delete node;
  delete node2;
  delete child;
  delete att;
}
END_TEST
START_TEST (test_Node_clone)
{
  XMLAttributes *att = new XMLAttributes();
  XMLTriple *t = new XMLTriple("sarah", "http://foo.org/", "bar");
  XMLToken *token = new XMLToken(*t, *att, 3, 4);
  XMLNode *node = new XMLNode(*token);
  XMLNode *child = new XMLNode();
  node->addChild(*child);

  fail_unless(node->getNumChildren() == 1);
  fail_unless(node->getName() == "sarah");
  fail_unless(node->getURI() == "http://foo.org/");
  fail_unless(node->getPrefix() == "bar");
  fail_unless(node->isEnd() == 0);
  fail_unless(node->isEOF() == 0);
  fail_unless(node->getLine() == 3);
  fail_unless(node->getColumn() == 4);

  XMLNode *node2 = static_cast<XMLNode*>(node->clone());

  fail_unless(node2->getNumChildren() == 1);
  fail_unless(node2->getName() == "sarah");
  fail_unless(node2->getURI() == "http://foo.org/");
  fail_unless(node2->getPrefix() == "bar");
  fail_unless(node2->isEnd() == 0);
  fail_unless(node2->isEOF() == 0);
  fail_unless(node2->getLine() == 3);
  fail_unless(node2->getColumn() == 4);

  delete t;
  delete token;
  delete node;
  delete node2;
  delete child;
  delete att;
}
END_TEST


Suite *
create_suite_CopyAndClone (void)
{
  Suite *suite = suite_create("CopyAndClone");
  TCase *tcase = tcase_create("CopyAndClone");

  tcase_add_test( tcase, test_NS_copyConstructor );
  tcase_add_test( tcase, test_NS_assignmentOperator );
  tcase_add_test( tcase, test_NS_clone );
  tcase_add_test( tcase, test_Triple_copyConstructor );
  tcase_add_test( tcase, test_Triple_assignmentOperator );
  tcase_add_test( tcase, test_Triple_clone );
  tcase_add_test( tcase, test_Token_copyConstructor );
  tcase_add_test( tcase, test_Token_assignmentOperator );
  tcase_add_test( tcase, test_Token_clone );
  tcase_add_test( tcase, test_Node_copyConstructor );
  tcase_add_test( tcase, test_Node_assignmentOperator );
  tcase_add_test( tcase, test_Node_clone );
  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND

