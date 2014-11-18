/**
 * \file    TestXMLAttributes.cpp
 * \brief   TestXMLAttributes unit tests
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


#include <limits>

#include <iostream>
#include <check.h>
#include <XMLAttributes.h>
#include <XMLError.h>
#include <XMLNamespaces.h>
#include <XMLNode.h>
#include <XMLToken.h>
#include <XMLInputStream.h>
#include <sbml/xml/XMLConstructorException.h>

#include <string>


/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */
static const string errMsg = "NULL reference in XML constructor";
static const string errMsg1 = "Null argument to copy constructor";
static const string errMsg2 = "Null argument to assignment operator";
static const string errMsg3 = "Null argument given to constructor";


CK_CPPSTART

START_TEST ( test_XMLAttributes )
{
  string msg;
  try 
  {
    XMLAttributes * att = new XMLAttributes();
    delete att;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  XMLAttributes *att1 = NULL;
  msg = "";
  // copy constructor
  try
  {
    XMLAttributes* att2=new XMLAttributes(*att1);
    (void) att2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLAttributes *att2 = new XMLAttributes();
  // assignment
  try
  {
    (*att2) = *att1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);
  delete att2;
}
END_TEST


START_TEST ( test_XMLError )
{
  string msg;
  try 
  {
    XMLError * err = new XMLError(MissingXMLDecl);
    delete err;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  XMLError *err1 = NULL;
  msg = "";
  // copy constructor
  try
  {
    XMLError* err2=new XMLError(*err1);
    (void) err2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLError *err2 = new XMLError(MissingXMLDecl);
  // assignment
  try
  {
    (*err2) = *err1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);
  delete err2;
}
END_TEST


START_TEST ( test_XMLNamespaces )
{
  string msg;
  try 
  {
    XMLNamespaces * ns = new XMLNamespaces();
    delete ns;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  XMLNamespaces *ns1 = NULL;
  msg = "";
  // copy constructor
  try
  {
    XMLNamespaces* ns2=new XMLNamespaces(*ns1);
    (void) ns2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLNamespaces *ns2 = new XMLNamespaces();
  // assignment
  try
  {
    (*ns2) = *ns1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);
  delete ns2;
}
END_TEST


START_TEST ( test_XMLNode )
{
  string msg;
  try 
  {
    XMLNode * node = new XMLNode();
    delete node;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  XMLNode *node1 = NULL;
  msg = "";
  // copy constructor
  try
  {
    XMLNode* node2=new XMLNode(*node1);
    (void) node2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLNode *node2 = new XMLNode();
  // assignment
  try
  {
    (*node2) = *node1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);
  delete node2;
}
END_TEST


START_TEST ( test_XMLToken )
{
  string msg;
  try 
  {
    XMLToken * token = new XMLToken();
    delete token;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  XMLTriple *triple = NULL;
  // ctor from triple
  try 
  {
    XMLToken * token3 = new XMLToken(*(triple));
    (void) token3;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLTriple *triple1 = new XMLTriple();
  XMLAttributes *att = NULL;
  // ctor from triple and attributes
  try 
  {
    XMLToken * token3 = new XMLToken(*(triple1), *(att));
    (void) token3;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLAttributes *att1 = new XMLAttributes();
  XMLNamespaces *ns = NULL;
  // ctor from triple, attributes & namespaces
  try 
  {
    XMLToken * token3 = new XMLToken(*(triple1), *(att1), *(ns));
    (void) token3;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  std::string *mess = NULL;
  // ctor from string
  try 
  {
    XMLToken * token3 = new XMLToken(*(mess));
    (void) token3;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  XMLToken *token1 = NULL;
  msg = "";
  // copy ctor
  try
  {
    XMLToken* token2=new XMLToken(*token1);
    (void) token2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLToken *token2 = new XMLToken();
  // assignment
  try
  {
    (*token2) = *token1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);
  delete token2;
  delete triple1;
  delete att1;

}
END_TEST


START_TEST ( test_XMLTriple )
{
  string msg;
  try 
  {
    XMLTriple * triple = new XMLTriple();
    delete triple;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  XMLTriple *triple1 = NULL;
  msg = "";
  // copy constructor
  try
  {
    XMLTriple* triple2=new XMLTriple(*triple1);
    (void) triple2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  XMLTriple *triple2 = new XMLTriple();
  // assignment
  try
  {
    (*triple2) = *triple1;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg2);

  msg = "";
  // ctor with name/uri/prefix
  try
  {
    std::string *name = NULL;
    std::string uri = "uri";
    std::string prefix = "prefix";
    XMLTriple *triple2 = new XMLTriple (*(name), uri, prefix);
    (void) triple2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg3);

  msg = "";
  // ctor with name/uri/prefix
  try
  {
    std::string name = "name";
    std::string *uri = NULL;
    std::string prefix = "prefix";
    XMLTriple *triple2 = new XMLTriple (name, *(uri), prefix);
    (void) triple2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg3);

  msg = "";
  // ctor with name/uri/prefix

  try
  {
    std::string name = "name";
    std::string uri = "uri";
    std::string *prefix = NULL;
    XMLTriple *triple2 = new XMLTriple (name, uri, *(prefix));
    (void) triple2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg3);

  msg = "";
  // ctor with triplet
  std::string *triplet = NULL;
  try
  {
    XMLTriple *triple2 = new XMLTriple (*(triplet));
    (void) triple2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  delete triple2;
}
END_TEST


START_TEST ( test_XMLOutputStream )
{
  string msg;
  std::ostream *stream = NULL;
  msg = "";
  // ctor from stream
  try
  {
    XMLOutputStream* opstream2=new XMLOutputStream(*(stream));
    (void) opstream2;
  }
  catch (XMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
}
END_TEST


START_TEST ( test_XMLInputStream )
{
  const char *stream = NULL;
  
  // XMLInputStream no longer throws an exception when invoked with 
  // NULL stream, instead it produces an invald stream;

  XMLInputStream opstream2(stream);
  fail_unless(opstream2.isError());

}
END_TEST


Suite *
create_suite_XMLExceptions (void)
{
  Suite *suite = suite_create("XMLExceptions");
  TCase *tcase = tcase_create("XMLExceptions");

 
  tcase_add_test( tcase, test_XMLAttributes);
  tcase_add_test( tcase, test_XMLError);
  tcase_add_test( tcase, test_XMLNamespaces);
  tcase_add_test( tcase, test_XMLNode);
  tcase_add_test( tcase, test_XMLToken);
  tcase_add_test( tcase, test_XMLTriple);
  tcase_add_test( tcase, test_XMLOutputStream);
  tcase_add_test( tcase, test_XMLInputStream);

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
