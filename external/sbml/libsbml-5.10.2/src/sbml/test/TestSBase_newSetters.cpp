/**
 * \file    TestSBase_newSetters.cpp
 * \brief   SBase unit tests for new set API
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
#include <sbml/common/extern.h>

#include <sbml/SBase.h>
#include <sbml/Model.h>
#include <sbml/annotation/CVTerm.h>
#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>

#include <check.h>
#include <limits.h>

LIBSBML_CPP_NAMESPACE_USE

/*
 * We create a lot of strings in this file, for testing, and we don't 
 * do what this warning tries to help with, so we shut it up just
 * for this file.
 */
#ifdef __GNUC__ 
#pragma GCC diagnostic ignored "-Wwrite-strings"
#endif

static SBase *S;


BEGIN_C_DECLS


void
SBaseTest_setup1 (void)
{
  S = new(std::nothrow) Model(2, 4);

  if (S == NULL)
  {
    fail("'new(std::nothrow) SBase;' returned a NULL pointer.");
  }

}


void
SBaseTest_teardown1 (void)
{
  delete S;
}


START_TEST (test_SBase_setNotes)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLTriple_t *triple = XMLTriple_createWith("p", "", "");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLToken_t *tt = XMLToken_createWithText("This is my text");
  XMLNode_t *n1 = XMLNode_createFromToken(tt);


  token = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node, n1);

  int i = SBase_setNotes(S, node);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  i = SBase_unsetNotes(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 0);

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);

  i = SBase_setNotes(S, node);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless(SBase_isSetNotes(S) == 0);

  token = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node, n1);

  i = SBase_setNotes(S, node);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  i = SBase_setNotes(S, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 0);
  XMLNode_free(node);
}
END_TEST


START_TEST (test_SBase_setNotes1)
{
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *html_node = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLNode_t * notes;
  const XMLNode_t *child;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);
  XMLNode_addChild(head_node, title_node);
  XMLNode_addChild(html_node, head_node);
  XMLNode_addChild(html_node, body_node);

  int i = SBase_setNotes(S, html_node);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 1);

  child = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "p"));
  fail_unless(XMLNode_getNumChildren(child) == 1);

  child = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(html_token);
  XMLToken_free(head_token);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLNode_free(html_node);
  XMLNode_free(head_node);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
}
END_TEST


START_TEST (test_SBase_setNotes2)
{
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *body_token = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLNode_t * notes;
  const XMLNode_t *child;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);

  int i = SBase_setNotes(S, body_node);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 1);

  child = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "p"));
  fail_unless(XMLNode_getNumChildren(child) == 1);

  child = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
}
END_TEST


START_TEST (test_SBase_setNotes3)
{
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *p_token = XMLToken_createWithTripleAttrNS(p_triple, att, ns);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLNode_t * notes;
  const XMLNode_t *child;

  XMLNode_addChild(p_node, text_node);

  int i = SBase_setNotes(S, p_node);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "p"));
  fail_unless(XMLNode_getNumChildren(child) == 1);

  child = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(p_triple);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
}
END_TEST


START_TEST (test_SBase_setAnnotation)
{
  XMLToken_t *token;
  XMLNode_t *node;

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);


  int i = SBase_setAnnotation(S, node);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 1);

  i = SBase_unsetAnnotation(S);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  SBase_unsetAnnotation(S);
  fail_unless(SBase_isSetAnnotation(S) == 0);

  i = SBase_setAnnotation(S, node);
  i = SBase_setAnnotation(S, NULL);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 0 );
}
END_TEST


START_TEST (test_SBase_setNotesString)
{
  char * notes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>";
  char * taggednotes = "<notes><p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p></notes>";
  char * badnotes = "<notes>This is a test note</notes>";

  int i = SBase_setNotesString(S, notes);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  i = SBase_unsetNotes(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 0);


  i = SBase_setNotesString(S, taggednotes);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  i = SBase_setNotesString(S, NULL);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 0);

  i = SBase_setNotesString(S, badnotes);

  fail_unless ( i == LIBSBML_INVALID_OBJECT);
  fail_unless(SBase_isSetNotes(S) == 0);
}
END_TEST


START_TEST (test_SBase_setAnnotationString)
{
  char * annotation = "This is a test note";
  char * taggedannotation = "<annotation>This is a test note</annotation>";

  int i = SBase_setAnnotationString(S, annotation);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 1);


  i = SBase_setAnnotationString(S, "");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 0 );

  i = SBase_setAnnotationString(S, taggedannotation);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 1);

  i = SBase_unsetAnnotation(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetAnnotation(S) == 0 );

}
END_TEST


START_TEST (test_SBase_appendAnnotation)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLToken_t *token1;
  XMLNode_t *node1;
  XMLToken_t *token_top;
  XMLNode_t *node_top;
  XMLTriple_t *triple = XMLTriple_createWith("any", "", "pr");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.any", "pr");
  token_top = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node_top = XMLNode_createFromToken(token_top);
  XMLToken_t *token_top1;
  XMLNode_t *node_top1;
  XMLTriple_t *triple1 = XMLTriple_createWith("anyOther", "", "prOther");
  XMLNamespaces_t *ns1 = XMLNamespaces_create();
  XMLNamespaces_add(ns1, "http://www.any.other", "prOther");
  token_top1 = XMLToken_createWithTripleAttrNS(triple1, att, ns1);
  node_top1 = XMLNode_createFromToken(token_top1);

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node_top, node);

 
  int i = SBase_setAnnotation(S, node_top);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  token1 = XMLToken_createWithText("This is additional");
  node1 = XMLNode_createFromToken(token1);
  XMLNode_addChild(node_top1, node1);

  i = SBase_appendAnnotation(S, node_top1);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  XMLNode_t *t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 2);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is a test note"));
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 1),0)),
    "This is additional"));

  i = SBase_appendAnnotation(S, NULL);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 2);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is a test note"));
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 1),0)),
    "This is additional"));

}
END_TEST


START_TEST (test_SBase_appendAnnotation1)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLToken_t *token1;
  XMLNode_t *node1;
  XMLToken_t *token_top;
  XMLNode_t *node_top;
  XMLTriple_t *triple = XMLTriple_createWith("any", "", "pr");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.any", "pr");
  token_top = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node_top = XMLNode_createFromToken(token_top);
  XMLToken_t *token_top1;
  XMLNode_t *node_top1;
  XMLTriple_t *triple1 = XMLTriple_createWith("anyOther", "", "prOther");
  XMLNamespaces_t *ns1 = XMLNamespaces_create();
  XMLNamespaces_add(ns1, "http://www.any.other", "prOther");
  token_top1 = XMLToken_createWithTripleAttrNS(triple1, att, ns1);
  node_top1 = XMLNode_createFromToken(token_top1);

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node_top, node);

 
  int i = SBase_setAnnotation(S, NULL);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  token1 = XMLToken_createWithText("This is additional");
  node1 = XMLNode_createFromToken(token1);
  XMLNode_addChild(node_top1, node1);

  i = SBase_appendAnnotation(S, node_top1);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  XMLNode_t *t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 1);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is additional"));

  token1 = XMLToken_createWithText("This is a repeat");
  node1 = XMLNode_createFromToken(token1);
  node_top1 = XMLNode_createFromToken(token_top1);
  XMLNode_addChild(node_top1, node1);

  i = SBase_appendAnnotation(S, node_top1);
  fail_unless( i == LIBSBML_DUPLICATE_ANNOTATION_NS);

  t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 1);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is additional"));

}
END_TEST


START_TEST (test_SBase_appendAnnotation2)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLToken_t *token_top;
  XMLNode_t *node_top;
  XMLTriple_t *triple = XMLTriple_createWith("any", "", "pr");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.any", "pr");
  token_top = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node_top = XMLNode_createFromToken(token_top);

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node_top, node);

 
  int i = SBase_setAnnotation(S, node_top);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  i = SBase_appendAnnotationString(S, "<prA:other xmlns:prA=\"http://some\">This is additional</prA:other>");

  XMLNode_t *t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 2);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is a test note"));

  const XMLNode_t *c1 = XMLNode_getChild(XMLNode_getChild(t1, 1), 0);

  fail_unless(XMLNode_getNumChildren(c1) == 0);
  fail_unless(!strcmp(XMLNode_getCharacters(c1), "This is additional"));

  char * newann =
    "<annotation>"
    "<prA:other xmlns:prA=\"http://some\">This is additional repeat</prA:other>"
    "<rdf:RDF xmlns:rdf=\"http://rdf\">This is a new annotation</rdf:RDF>"
    "</annotation>";

  i = SBase_appendAnnotationString(S, newann);

  fail_unless( i == LIBSBML_DUPLICATE_ANNOTATION_NS);

  t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 3);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is a test note"));
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 1),0)),
    "This is additional"));
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 2),0)),
    "This is a new annotation"));

}
END_TEST


START_TEST (test_SBase_appendAnnotationString)
{
  XMLToken_t *token;
  XMLNode_t *node;
  XMLToken_t *token_top;
  XMLNode_t *node_top;
  XMLTriple_t *triple = XMLTriple_createWith("any", "", "pr");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.any", "pr");
  token_top = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node_top = XMLNode_createFromToken(token_top);

  token = XMLToken_createWithText("This is a test note");
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node_top, node);

 
  int i = SBase_setAnnotation(S, node_top);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  i = SBase_appendAnnotationString(S, "<prA:other xmlns:prA=\"http://some\">This is additional</prA:other>");

  XMLNode_t *t1 = SBase_getAnnotation(S);

  fail_unless(XMLNode_getNumChildren(t1) == 2);
  fail_unless(!strcmp(XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(t1, 0),0)),
    "This is a test note"));

  const XMLNode_t *c1 = XMLNode_getChild(XMLNode_getChild(t1, 1), 0);

  fail_unless(XMLNode_getNumChildren(c1) == 0);
  fail_unless(!strcmp(XMLNode_getCharacters(c1), "This is additional"));
}
END_TEST


START_TEST (test_SBase_appendNotes)
{ // add a p tag to a p tag
  XMLToken_t *token;
  XMLNode_t *node;
  XMLToken_t *token1;
  XMLNode_t *node1;
  XMLNode_t * node2;
  XMLTriple_t *triple = XMLTriple_createWith("p", "", "");
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLToken_t *token4 = XMLToken_createWithText("This is my text");
  XMLNode_t *node4 = XMLNode_createFromToken(token4);
  XMLToken_t *token5 = XMLToken_createWithText("This is additional text");
  XMLNode_t *node5 = XMLNode_createFromToken(token5);

  token = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node = XMLNode_createFromToken(token);
  XMLNode_addChild(node, node4);

  int i = SBase_setNotes(S, node);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  token1 = XMLToken_createWithTripleAttrNS(triple, att, ns);
  node1 = XMLNode_createFromToken(token1);
  XMLNode_addChild(node1, node5);
  
  i = SBase_appendNotes(S, node1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  node2 = SBase_getNotes(S);

  fail_unless(XMLNode_getNumChildren(node2) == 2);
  fail_unless(!strcmp(XMLNode_getName(XMLNode_getChild(node2, 0)), "p"));
  fail_unless(XMLNode_getNumChildren(XMLNode_getChild(node2, 0)) == 1);
  fail_unless(!strcmp(XMLNode_getName(XMLNode_getChild(node2, 1)), "p"));
  fail_unless(XMLNode_getNumChildren(XMLNode_getChild(node2, 1)) == 1);

  const char * chars1 = XMLNode_getCharacters(XMLNode_getChild(
    XMLNode_getChild(node2, 0), 0));
  const char * chars2 = XMLNode_getCharacters(XMLNode_getChild(
    XMLNode_getChild(node2, 1), 0));

  fail_unless(!strcmp(chars1, "This is my text"));
  fail_unless(!strcmp(chars2, "This is additional text"));

  XMLNode_free(node);
  XMLNode_free(node1);
}
END_TEST


START_TEST (test_SBase_appendNotes1)
{
  // add a html tag to an html tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *html_node = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *html_node1 = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node1 = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node1 = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);
  XMLNode_addChild(head_node, title_node);
  XMLNode_addChild(html_node, head_node);
  XMLNode_addChild(html_node, body_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);
  XMLNode_addChild(head_node1, title_node1);
  XMLNode_addChild(html_node1, head_node1);
  XMLNode_addChild(html_node1, body_node1);

  int i = SBase_setNotes(S, html_node);
  i = SBase_appendNotes(S, html_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(html_token);
  XMLToken_free(head_token);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLNode_free(html_node);
  XMLNode_free(head_node);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(html_node1);
  XMLNode_free(head_node1);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes2)
{// add a body tag to an html tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *html_node = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *body_token1 = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token1);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);
  XMLNode_addChild(head_node, title_node);
  XMLNode_addChild(html_node, head_node);
  XMLNode_addChild(html_node, body_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);

  int i = SBase_setNotes(S, html_node);
  i = SBase_appendNotes(S, body_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(html_token);
  XMLToken_free(head_token);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLToken_free(body_token1);
  XMLNode_free(html_node);
  XMLNode_free(head_node);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes3)
{
  // add a p tag to an html tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *html_node = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *p_token1 = XMLToken_createWithTripleAttrNS(p_triple, att, ns);
  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token1);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);
  XMLNode_addChild(head_node, title_node);
  XMLNode_addChild(html_node, head_node);
  XMLNode_addChild(html_node, body_node);

  XMLNode_addChild(p_node1, text_node1);

  int i = SBase_setNotes(S, html_node);
  i = SBase_appendNotes(S, p_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(html_token);
  XMLToken_free(head_token);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLToken_free(p_token1);
  XMLNode_free(html_node);
  XMLNode_free(head_node);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes4)
{
  // add a html tag to a body tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *body_token1 = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *body_node = XMLNode_createFromToken(body_token1);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *html_node1 = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node1 = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node1 = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);
  XMLNode_addChild(head_node1, title_node1);
  XMLNode_addChild(html_node1, head_node1);
  XMLNode_addChild(html_node1, body_node1);

  int i = SBase_setNotes(S, body_node);
  i = SBase_appendNotes(S, html_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLToken_free(body_token1);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(html_node1);
  XMLNode_free(head_node1);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes5)
{
  // add a html tag to a p tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *html_triple = XMLTriple_createWith("html", "", "");
  XMLTriple_t *head_triple = XMLTriple_createWith("head", "", "");
  XMLTriple_t *title_triple = XMLTriple_createWith("title", "", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *html_token = XMLToken_createWithTripleAttrNS(html_triple, att, ns);
  XMLToken_t *head_token = XMLToken_createWithTripleAttr(head_triple, att);
  XMLToken_t *title_token = XMLToken_createWithTripleAttr(title_triple, att);
  XMLToken_t *body_token = XMLToken_createWithTripleAttr(body_triple, att);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *p_token1 = XMLToken_createWithTripleAttrNS(p_triple, att, ns);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *p_node = XMLNode_createFromToken(p_token1);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *html_node1 = XMLNode_createFromToken(html_token);
  XMLNode_t *head_node1 = XMLNode_createFromToken(head_token);
  XMLNode_t *title_node1 = XMLNode_createFromToken(title_token);
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);
  XMLNode_addChild(head_node1, title_node1);
  XMLNode_addChild(html_node1, head_node1);
  XMLNode_addChild(html_node1, body_node1);

  int i = SBase_setNotes(S, p_node);
  i = SBase_appendNotes(S, html_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "html"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(html_triple);
  XMLTriple_free(head_triple);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(p_token1);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(html_node1);
  XMLNode_free(head_node1);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes6)
{// add a body tag to an body tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *body_token = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);

  int i = SBase_setNotes(S, body_node);
  i = SBase_appendNotes(S, body_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes7)
{// add a body tag to an p tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *body_token = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *p_token1 = XMLToken_createWithTripleAttrNS(p_triple, att, ns);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token1);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *body_node1 = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);

  XMLNode_addChild(p_node1, text_node1);
  XMLNode_addChild(body_node1, p_node1);

  int i = SBase_setNotes(S, p_node);
  i = SBase_appendNotes(S, body_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(p_token1);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(body_node1);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotes8)
{
  // add a p tag to an body tag
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLNamespaces_t *ns = XMLNamespaces_create();
  XMLNamespaces_add(ns, "http://www.w3.org/1999/xhtml", "");
  XMLTriple_t *body_triple = XMLTriple_createWith("body", "", "");
  XMLTriple_t *p_triple = XMLTriple_createWith("p", "", "");
  XMLToken_t *body_token = XMLToken_createWithTripleAttrNS(body_triple, att, ns);
  XMLToken_t *p_token = XMLToken_createWithTripleAttr(p_triple, att);
  XMLToken_t *text_token = XMLToken_createWithText("This is my text");
  XMLNode_t *body_node = XMLNode_createFromToken(body_token);
  XMLNode_t *p_node = XMLNode_createFromToken(p_token);
  XMLNode_t *text_node = XMLNode_createFromToken(text_token);

  XMLToken_t *p_token1 = XMLToken_createWithTripleAttrNS(p_triple, att, ns);
  XMLToken_t *text_token1 = XMLToken_createWithText("This is more text");
  XMLNode_t *p_node1 = XMLNode_createFromToken(p_token1);
  XMLNode_t *text_node1 = XMLNode_createFromToken(text_token1);

  XMLNode_t * notes;
  const XMLNode_t *child, *child1;

  XMLNode_addChild(p_node, text_node);
  XMLNode_addChild(body_node, p_node);

  XMLNode_addChild(p_node1, text_node1);

  int i = SBase_setNotes(S, body_node);
  i = SBase_appendNotes(S, p_node1);

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);

  notes = SBase_getNotes(S);

  fail_unless(!strcmp(XMLNode_getName(notes), "notes"));
  fail_unless(XMLNode_getNumChildren(notes) == 1);

  child = XMLNode_getChild(notes, 0);

  fail_unless(!strcmp(XMLNode_getName(child), "body"));
  fail_unless(XMLNode_getNumChildren(child) == 2);

  child1 = XMLNode_getChild(child, 0);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is my text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  child1 = XMLNode_getChild(child, 1);

  fail_unless(!strcmp(XMLNode_getName(child1), "p"));
  fail_unless(XMLNode_getNumChildren(child1) == 1);

  child1 = XMLNode_getChild(child1, 0);

  fail_unless(!strcmp(XMLNode_getCharacters(child1), "This is more text"));
  fail_unless(XMLNode_getNumChildren(child1) == 0);

  XMLAttributes_free(att);
  XMLNamespaces_free(ns);
  XMLTriple_free(body_triple);
  XMLTriple_free(p_triple);
  XMLToken_free(body_token);
  XMLToken_free(p_token);
  XMLToken_free(text_token);
  XMLToken_free(text_token1);
  XMLToken_free(p_token1);
  XMLNode_free(body_node);
  XMLNode_free(p_node);
  XMLNode_free(text_node);
  XMLNode_free(p_node1);
  XMLNode_free(text_node1);
}
END_TEST


START_TEST (test_SBase_appendNotesString)
{
  char * notes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>";
  char * taggednotes = "<notes>\n"
                       "  <p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>\n"
                       "</notes>";
  char * taggednewnotes = "<notes>\n"
                       "  <p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>\n"
                       "  <p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>\n"
                       "</notes>";
  char * badnotes = "<notes>This is a test note</notes>";
  char * newnotes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>";

  int i = SBase_setNotesString(S, notes);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);

  i = SBase_appendNotesString(S, badnotes);
  const char * notes1 = SBase_getNotesString(S);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednotes, notes1));

  i = SBase_appendNotesString(S, newnotes);

  notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString1)
{ // add html to html
  char * notes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is a test note </p>\n"
                 "  </body>\n"
                 "</html>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <head>\n"
                 "      <title/>\n"
                 "    </head>\n"
                 "    <body>\n"
                 "      <p>This is a test note </p>\n"
                 "      <p>This is more test notes </p>\n"
                 "    </body>\n"
                 "  </html>\n"
                 "</notes>";
  char * addnotes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is more test notes </p>\n"
                 "  </body>\n"
                 "</html>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString2)
{ // add body to html
  char * notes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is a test note </p>\n"
                 "  </body>\n"
                 "</html>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <head>\n"
                 "      <title/>\n"
                 "    </head>\n"
                 "    <body>\n"
                 "      <p>This is a test note </p>\n"
                 "      <p>This is more test notes </p>\n"
                 "    </body>\n"
                 "  </html>\n"
                 "</notes>";
  char * addnotes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                    "  <p>This is more test notes </p>\n"
                    "</body>\n";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString3)
{ // add p to html
  char * notes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is a test note </p>\n"
                 "  </body>\n"
                 "</html>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <head>\n"
                 "      <title/>\n"
                 "    </head>\n"
                 "    <body>\n"
                 "      <p>This is a test note </p>\n"
                 "      <p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>\n"
                 "    </body>\n"
                 "  </html>\n"
                 "</notes>";
  char * addnotes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString4)
{ // add html to body
  char * notes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <p>This is a test note </p>\n"
                 "</body>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <head>\n"
                 "      <title/>\n"
                 "    </head>\n"
                 "    <body>\n"
                 "      <p>This is a test note </p>\n"
                 "      <p>This is more test notes </p>\n"
                 "    </body>\n"
                 "  </html>\n"
                 "</notes>";
  char * addnotes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is more test notes </p>\n"
                 "  </body>\n"
                 "</html>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString5)
{ // add html to p
  char * notes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <head>\n"
                 "      <title/>\n"
                 "    </head>\n"
                 "    <body>\n"
                 "      <p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>\n"
                 "      <p>This is more test notes </p>\n"
                 "    </body>\n"
                 "  </html>\n"
                 "</notes>";
  char * addnotes = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <head>\n"
                 "    <title/>\n"
                 "  </head>\n"
                 "  <body>\n"
                 "    <p>This is more test notes </p>\n"
                 "  </body>\n"
                 "</html>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString6)
{ // add body to body
  char * notes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <p>This is a test note </p>\n"
                 "</body>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <p>This is a test note </p>\n"
                 "    <p>This is more test notes </p>\n"
                 "  </body>\n"
                 "</notes>";
  char * addnotes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <p>This is more test notes </p>\n"
                 "</body>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString7)
{ // add body to p
  char * notes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <p xmlns=\"http://www.w3.org/1999/xhtml\">This is a test note </p>\n"
                 "    <p>This is more test notes </p>\n"
                 "  </body>\n"
                 "</notes>";
  char * addnotes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <p>This is more test notes </p>\n"
                 "</body>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST (test_SBase_appendNotesString8)
{ // add p to body
  char * notes = "<body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "  <p>This is a test note </p>\n"
                 "</body>";
  char * taggednewnotes = 
                 "<notes>\n"
                 "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
                 "    <p>This is a test note </p>\n"
                 "    <p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>\n"
                 "  </body>\n"
                 "</notes>";
  char * addnotes = "<p xmlns=\"http://www.w3.org/1999/xhtml\">This is more test notes </p>";

  int i = SBase_setNotesString(S, notes);
  i = SBase_appendNotesString(S, addnotes);

  const char *notes1 = SBase_getNotesString(S);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_isSetNotes(S) == 1);
  fail_unless(!strcmp(taggednewnotes, notes1));

}
END_TEST


START_TEST(test_SBase_addCVTerms)
{
  CVTerm_t * cv = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv, BQB_ENCODES);
  CVTerm_addResource(cv, "foo");
  
  int i = SBase_addCVTerm(S, cv);

  fail_unless ( i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless(SBase_getNumCVTerms(S) == 0);

  SBase_setMetaId(S, "_id");
  i = SBase_addCVTerm(S, cv);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_getNumCVTerms(S) == 1);
  fail_unless(SBase_getCVTerms(S) != NULL);

  i = SBase_addCVTerm(S, NULL);

  fail_unless(i == LIBSBML_OPERATION_FAILED);
  fail_unless(SBase_getNumCVTerms(S) == 1);
  fail_unless(SBase_getCVTerms(S) != NULL);

  CVTerm_t *cv2 = CVTerm_createWithQualifierType(MODEL_QUALIFIER);

  i = SBase_addCVTerm(S, cv2);

  fail_unless(i == LIBSBML_INVALID_OBJECT);
  fail_unless(SBase_getNumCVTerms(S) == 1);
  fail_unless(SBase_getCVTerms(S) != NULL);
 
  CVTerm_free(cv);
  CVTerm_free(cv2);
}
END_TEST


START_TEST(test_SBase_addCVTerms_newBag)
{
  SBase_setMetaId(S, "_id");
  CVTerm_t * cv = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv, BQB_ENCODES);
  CVTerm_addResource(cv, "foo");
  
  int i = SBase_addCVTerm(S, cv);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_getNumCVTerms(S) == 1);
  fail_unless(SBase_getCVTerms(S) != NULL);

  CVTerm_t * cv3 = SBase_getCVTerm(S, 0);

  fail_unless( CVTerm_getNumResources(cv3) == 1);

  CVTerm_t * cv1 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv1, BQB_ENCODES);
  CVTerm_addResource(cv1, "foo1");
 
  i = SBase_addCVTermNewBag(S, cv1);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_getNumCVTerms(S) == 2);
  fail_unless(SBase_getCVTerms(S) != NULL);

  cv3 = SBase_getCVTerm(S, 0);

  fail_unless( CVTerm_getNumResources(cv3) == 1);  
  
  cv3 = SBase_getCVTerm(S, 1);

  fail_unless( CVTerm_getNumResources(cv3) == 1);  

  CVTerm_t * cv2 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv2, BQB_ENCODES);
  CVTerm_addResource(cv2, "foo2");
 
  i = SBase_addCVTerm(S, cv2);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_getNumCVTerms(S) == 2);
  fail_unless(SBase_getCVTerms(S) != NULL);

  cv3 = SBase_getCVTerm(S, 0);

  fail_unless( CVTerm_getNumResources(cv3) == 1);  
  
  cv3 = SBase_getCVTerm(S, 1);

  fail_unless( CVTerm_getNumResources(cv3) == 2);  

  CVTerm_free(cv);
  CVTerm_free(cv1);
  CVTerm_free(cv2);
}
END_TEST


START_TEST(test_SBase_unsetCVTerms)
{
  CVTerm_t * cv = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv, BQB_ENCODES);
  CVTerm_addResource(cv, "foo");

  SBase_setMetaId(S, "_id");
  SBase_addCVTerm(S, cv);
  CVTerm_t * cv1 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv1, BQB_IS);
  CVTerm_addResource(cv1, "bar");
  
  SBase_addCVTerm(S, cv1);
  CVTerm_t * cv2 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv2, BQB_IS);
  CVTerm_addResource(cv2, "bar1");
  
  SBase_addCVTerm(S, cv2);
  CVTerm_t * cv4 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType(cv4, BQB_IS);
  CVTerm_addResource(cv4, "bar1");
  
  SBase_addCVTerm(S, cv4);
  
  fail_unless(SBase_getNumCVTerms(S) == 2);

  int i = SBase_unsetCVTerms(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(SBase_getNumCVTerms(S) == 0);
  fail_unless(SBase_getCVTerms(S) == NULL);
  
  CVTerm_free(cv);
  CVTerm_free(cv2);
  CVTerm_free(cv1);
  CVTerm_free(cv4);
}
END_TEST


START_TEST (test_SBase_setMetaId1)
{
  SBase *c = new(std::nothrow) Compartment(1, 2);

  int i = SBase_setMetaId(c, "cell");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !SBase_isSetMetaId(c) );

  delete c;
}
END_TEST


START_TEST (test_SBase_setMetaId2)
{
  int i = SBase_setMetaId(S, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !SBase_isSetMetaId(S) );

  i = SBase_unsetMetaId(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetMetaId(S) );
}
END_TEST


START_TEST (test_SBase_setMetaId3)
{
  int i = SBase_setMetaId(S, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetMetaId(S) );
  fail_unless( !strcmp(SBase_getMetaId(S), "cell" ));

  i = SBase_unsetMetaId(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetMetaId(S) );
}
END_TEST


START_TEST (test_SBase_setMetaId4)
{
  int i = SBase_setMetaId(S, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetMetaId(S) );
  fail_unless( !strcmp(SBase_getMetaId(S), "cell" ));

  i = SBase_setMetaId(S, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetMetaId(S) );
}
END_TEST


START_TEST (test_SBase_setSBOTerm1)
{
  SBase *c = new(std::nothrow) Compartment(1, 2);

  int i = SBase_setSBOTerm(c, 2);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !SBase_isSetSBOTerm(c) );

  delete c;
}
END_TEST


START_TEST (test_SBase_setSBOTerm2)
{
  int i = SBase_setSBOTerm(S, 5);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 5 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:0000005") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:0000005") == 0);

  i = SBase_unsetSBOTerm(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == -1 );
  fail_unless( SBase_getSBOTermID(S) == NULL);
  fail_unless( SBase_getSBOTermAsURL(S) == NULL);

  i = SBase_setSBOTerm(S, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 0 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:0000000") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:0000000") == 0);

  i = SBase_setSBOTerm(S, 9999999);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 9999999 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:9999999") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:9999999") == 0);

  /* set an SBOTerm by ID */

  i = SBase_setSBOTermID(S, "SBO:0000005");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 5 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:0000005") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:0000005") == 0);

  i = SBase_unsetSBOTerm(S);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTermID(S) == NULL);
  fail_unless( SBase_getSBOTermAsURL(S) == NULL);

  i = SBase_setSBOTermID(S, "SBO:0000000");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 0 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:0000000") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:0000000") == 0);

  i = SBase_setSBOTermID(S, "SBO:9999999");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTerm(S) == 9999999 );
  fail_unless( strcmp(SBase_getSBOTermID(S), "SBO:9999999") == 0);
  fail_unless( strcmp(SBase_getSBOTermAsURL(S), 
               "http://identifiers.org/biomodels.sbo/SBO:9999999") == 0);

  /* check invalid attribute value */

  i = SBase_setSBOTerm(S, SBML_INT_MAX);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTermID(S) == NULL);
  fail_unless( SBase_getSBOTermAsURL(S) == NULL);

  i = SBase_setSBOTerm(S, -1);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTermID(S) == NULL);
  fail_unless( SBase_getSBOTermAsURL(S) == NULL);

  i = SBase_setSBOTerm(S, 10000000);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !SBase_isSetSBOTerm(S) );
  fail_unless( SBase_getSBOTermID(S) == NULL);
  fail_unless( SBase_getSBOTermAsURL(S) == NULL);

}
END_TEST


START_TEST (test_SBase_setNamespaces)
{
  XMLNamespaces *ns = new XMLNamespaces();
  ns->add("url", "name");

  int i = SBase_setNamespaces(S, ns);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( XMLNamespaces_getLength(Model_getNamespaces((Model_t *)(S))) == 1 );

  i = SBase_setNamespaces(S, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Model_getNamespaces((Model_t *)(S)) == 0 );
}
END_TEST


START_TEST (test_SBase_setModelHistory)
{
  SBase_t *sb = new Species(2,4);
  ModelHistory_t *mh = ModelHistory_create();
  int i = SBase_setModelHistory(sb, mh);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );

  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_SBase_setModelHistory_Model)
{
  S->setMetaId("_001");
  ModelHistory_t * history = ModelHistory_create();
  ModelCreator_t * mc = ModelCreator_create();
  Date_t * date = 
    Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  ModelHistory_addCreator(history, mc);
  ModelHistory_setCreatedDate(history, date);
  ModelHistory_setModifiedDate(history, date);

  int i = SBase_setModelHistory(S, history);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );

  ModelHistory_free(history);
}
END_TEST


START_TEST (test_SBase_setModelHistoryL3)
{
  SBase_t *sb = new Species(3,1);
  sb->setMetaId("_s");
  ModelHistory_t *mh = ModelHistory_create();
  ModelCreator_t * mc = ModelCreator_create();
  Date_t * date = 
    Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  ModelHistory_addCreator(mh, mc);
  ModelHistory_setCreatedDate(mh, date);
  ModelHistory_setModifiedDate(mh, date);

  int i = SBase_setModelHistory(sb, mh);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(SBase_isSetModelHistory(sb)==1);

  mh = SBase_getModelHistory(sb);

  fail_unless(mh != NULL);

  SBase_unsetModelHistory(sb);
  mh = SBase_getModelHistory(sb);

  fail_unless(SBase_isSetModelHistory(sb)==0);
  fail_unless(mh == NULL);

  ModelHistory_free(mh);
}
END_TEST


Suite *
create_suite_SBase_newSetters (void)
{
  Suite *suite = suite_create("SBase_newSetters");
  TCase *tcase = tcase_create("SBase_newSetters");


  tcase_add_checked_fixture(tcase, SBaseTest_setup1, SBaseTest_teardown1);

  tcase_add_test(tcase, test_SBase_setNotes      );
  tcase_add_test(tcase, test_SBase_setNotes1     );
  tcase_add_test(tcase, test_SBase_setNotes2     );
  tcase_add_test(tcase, test_SBase_setNotes3     );
  tcase_add_test(tcase, test_SBase_setAnnotation );
  tcase_add_test(tcase, test_SBase_setNotesString);
  tcase_add_test(tcase, test_SBase_setAnnotationString);
  tcase_add_test(tcase, test_SBase_appendAnnotation );
  tcase_add_test(tcase, test_SBase_appendAnnotation1 );
  tcase_add_test(tcase, test_SBase_appendAnnotation2 );
  tcase_add_test(tcase, test_SBase_appendAnnotationString );
  tcase_add_test(tcase, test_SBase_appendNotes );
  tcase_add_test(tcase, test_SBase_appendNotes1 );
  tcase_add_test(tcase, test_SBase_appendNotes2 );
  tcase_add_test(tcase, test_SBase_appendNotes3 );
  tcase_add_test(tcase, test_SBase_appendNotes4 );
  tcase_add_test(tcase, test_SBase_appendNotes5 );
  tcase_add_test(tcase, test_SBase_appendNotes6 );
  tcase_add_test(tcase, test_SBase_appendNotes7 );
  tcase_add_test(tcase, test_SBase_appendNotes8 );
  tcase_add_test(tcase, test_SBase_appendNotesString );
  tcase_add_test(tcase, test_SBase_appendNotesString1);
  tcase_add_test(tcase, test_SBase_appendNotesString2);
  tcase_add_test(tcase, test_SBase_appendNotesString3);
  tcase_add_test(tcase, test_SBase_appendNotesString4);
  tcase_add_test(tcase, test_SBase_appendNotesString5);
  tcase_add_test(tcase, test_SBase_appendNotesString6);
  tcase_add_test(tcase, test_SBase_appendNotesString7);
  tcase_add_test(tcase, test_SBase_appendNotesString8);
  tcase_add_test(tcase, test_SBase_addCVTerms );
  tcase_add_test(tcase, test_SBase_addCVTerms_newBag );
  tcase_add_test(tcase, test_SBase_unsetCVTerms );
  tcase_add_test(tcase, test_SBase_setMetaId1     );
  tcase_add_test(tcase, test_SBase_setMetaId2     );
  tcase_add_test(tcase, test_SBase_setMetaId3     );
  tcase_add_test(tcase, test_SBase_setMetaId4     );
  tcase_add_test(tcase, test_SBase_setSBOTerm1     );
  tcase_add_test(tcase, test_SBase_setSBOTerm2     );
  tcase_add_test(tcase, test_SBase_setNamespaces   );
  tcase_add_test(tcase, test_SBase_setModelHistory   );
  tcase_add_test(tcase, test_SBase_setModelHistory_Model   );
  tcase_add_test(tcase, test_SBase_setModelHistoryL3   );

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
