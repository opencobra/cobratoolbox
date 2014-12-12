/**
 * \file    TestValidASTNode.cpp
 * \brief   Test the isWellFormedASTNode function
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

#include <limits>
#include <iostream>
#include <cstdio>
#include <cstring>

#include <check.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */

CK_CPPSTART


START_TEST (test_ValidASTNode_infix_nary_plus0)
{
  ASTNode *n = readMathMLFromString(
     "<math xmlns='http://www.w3.org/1998/Math/MathML'>"
     "  <apply>"
     "    <plus/>"
     "  </apply>"
     "</math>"
    );

  fail_unless( n != NULL );

  char* formula = SBML_formulaToString(n);

  ASTNode *node = SBML_parseFormula(formula);

  fail_unless( node != NULL );

  delete n;
  delete node;
}
END_TEST

START_TEST (test_ValidASTNode_infix_nary_plus1)
{
  ASTNode *n = readMathMLFromString(
     "<math xmlns='http://www.w3.org/1998/Math/MathML'>"
     "  <apply>"
     "    <plus/>"
     "    <cn> 0 </cn>"
     "  </apply>"
     "</math>"
    );

  fail_unless( n != NULL );

  char* formula = SBML_formulaToString(n);

  ASTNode *node = SBML_parseFormula(formula);

  fail_unless( node != NULL );

  delete n;
  delete node;
}
END_TEST

START_TEST (test_ValidASTNode_infix_nary_times0)
{
   ASTNode *n = readMathMLFromString(
     "<math xmlns='http://www.w3.org/1998/Math/MathML'>"
     "  <apply>"
     "    <times/>"
     "  </apply>"
     "</math>"
    );

  fail_unless( n != NULL );

  char* formula = SBML_formulaToString(n);

  ASTNode *node = SBML_parseFormula(formula);

  fail_unless( node != NULL );

  delete n;
  delete node;
}
END_TEST


START_TEST (test_ValidASTNode_infix_nary_times1)
{
   ASTNode *n = readMathMLFromString(
     "<math xmlns='http://www.w3.org/1998/Math/MathML'>"
     "  <apply>"
     "    <times/>"
     "    <cn> 0 </cn>"
     "  </apply>"
     "</math>"
    );

  fail_unless( n != NULL );

  char* formula = SBML_formulaToString(n);

  ASTNode *node = SBML_parseFormula(formula);

  fail_unless( node != NULL );

  delete n;
  delete node;
}
END_TEST


START_TEST (test_ValidASTNode_Number)
{
  ASTNode *n = SBML_parseFormula("1.2");

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("d");
  int i = n->addChild(d);

  // old test allowed to create invalid node
//  fail_unless( !(n->isWellFormedASTNode()) );
  fail_unless( i == LIBSBML_INVALID_OBJECT);

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_Name)
{
  ASTNode *n = SBML_parseFormula("c");

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("d");
  int i = n->addChild(d);

  // old test allowed to create invalid node
//  fail_unless( !(n->isWellFormedASTNode()) );
  fail_unless( i == LIBSBML_INVALID_OBJECT);

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_unary)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_ABS);

  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *c = SBML_parseFormula("c");
  n->addChild(c);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("d");
  n->addChild(d);

  fail_unless( !(n->isWellFormedASTNode()) );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_binary)
{
  ASTNode *n = new ASTNode(AST_DIVIDE);

  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *c = SBML_parseFormula("c");
  n->addChild(c);

  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *d = SBML_parseFormula("d");
  n->addChild(d);

  fail_unless( n->isWellFormedASTNode() );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_nary)
{
  ASTNode *n = new ASTNode(AST_DIVIDE);
  fail_unless( !(n->isWellFormedASTNode()) );
  
  ASTNode *c = SBML_parseFormula("c");

  n->addChild(c->deepCopy());
  fail_unless( !(n->isWellFormedASTNode()) );

  n->addChild(c->deepCopy());
  fail_unless( (n->isWellFormedASTNode()) );

  n->addChild(c->deepCopy());
  fail_unless( !(n->isWellFormedASTNode()) );

  n = new ASTNode(AST_TIMES);
  fail_unless( (n->isWellFormedASTNode()) );

  n->addChild(c);

  fail_unless( (n->isWellFormedASTNode()) );

  ASTNode *d = SBML_parseFormula("d");
  n->addChild(d);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *e = SBML_parseFormula("e");
  n->addChild(e);

  fail_unless( n->isWellFormedASTNode() );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_root)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_ROOT);

  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *c = SBML_parseFormula("c");
  n->addChild(c);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("3");
  n->addChild(d);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *e = SBML_parseFormula("3");
  n->addChild(e);

  fail_unless( !(n->isWellFormedASTNode()) );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_log)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_LOG);

  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *c = SBML_parseFormula("c");
  n->addChild(c);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("3");
  n->addChild(d);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *e = SBML_parseFormula("3");
  n->addChild(e);

  fail_unless( !(n->isWellFormedASTNode()) );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_lambda)
{
  ASTNode *n = new ASTNode(AST_LAMBDA);
  fail_unless( !(n->isWellFormedASTNode()) );

  ASTNode *c = SBML_parseFormula("c");
  n->addChild(c);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *d = SBML_parseFormula("d");
  n->addChild(d);

  fail_unless( n->isWellFormedASTNode() );

  ASTNode *e = SBML_parseFormula("e");
  n->addChild(e);

  fail_unless( n->isWellFormedASTNode() );

  delete n;
}
END_TEST


START_TEST (test_ValidASTNode_setType)
{
  ASTNode *n = new ASTNode();
  
  int i = n->setType(AST_REAL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getType() == AST_REAL);
  
  i = n->setType(AST_PLUS);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getType() == AST_PLUS);
  fail_unless( n->getCharacter() == '+' );
  
  i = n->setType(AST_FUNCTION_ARCCOSH);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getType() == AST_FUNCTION_ARCCOSH);
  
  i = n->setType(AST_UNKNOWN);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( n->getType() == AST_UNKNOWN);
  
  delete n;
}
END_TEST

START_TEST (test_ValidASTNode_returnsBoolean)
{ 
  ASTNode node(AST_LOGICAL_AND);
  fail_unless(node.returnsBoolean());

  node.setType(AST_LOGICAL_NOT);
  fail_unless(node.returnsBoolean());

  node.setType(AST_LOGICAL_OR);  
  fail_unless(node.returnsBoolean());

  node.setType(AST_LOGICAL_XOR);
  fail_unless(node.returnsBoolean());

  node.setType(AST_FUNCTION_PIECEWISE);
  fail_unless(node.returnsBoolean());

  node.setType(AST_RELATIONAL_EQ);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_RELATIONAL_GEQ);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_RELATIONAL_GT);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_RELATIONAL_LEQ);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_RELATIONAL_LT);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_RELATIONAL_NEQ);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_CONSTANT_TRUE);
  fail_unless(node.returnsBoolean());
  
  node.setType(AST_CONSTANT_FALSE);
  fail_unless(node.returnsBoolean());
  
}
END_TEST


Suite *
create_suite_TestValidASTNode ()
{
  Suite *suite = suite_create("TestValidASTNode");
  TCase *tcase = tcase_create("TestValidASTNode");

  tcase_add_test( tcase, test_ValidASTNode_infix_nary_plus0  );
  tcase_add_test( tcase, test_ValidASTNode_infix_nary_plus1  );
  tcase_add_test( tcase, test_ValidASTNode_infix_nary_times0 );
  tcase_add_test( tcase, test_ValidASTNode_infix_nary_times1 );
  tcase_add_test( tcase, test_ValidASTNode_Number            );
  tcase_add_test( tcase, test_ValidASTNode_returnsBoolean    );
  tcase_add_test( tcase, test_ValidASTNode_Name              );
  tcase_add_test( tcase, test_ValidASTNode_unary             );
  tcase_add_test( tcase, test_ValidASTNode_binary            );
  tcase_add_test( tcase, test_ValidASTNode_nary              );
  tcase_add_test( tcase, test_ValidASTNode_root              );
  tcase_add_test( tcase, test_ValidASTNode_log              );
  tcase_add_test( tcase, test_ValidASTNode_lambda            );
  tcase_add_test( tcase, test_ValidASTNode_setType           );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

