/**
 * \file    TestNewNewASTNode.cpp
 * \brief   ASTNode unit tests
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
 * Copyright (C) 2009-2012 jointly by the following organizations: 
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
#include <sbml/util/List.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/EventAssignment.h>
#include <sbml/Model.h>
#include <sbml/SBMLDocument.h>
#include <sbml/math/MathML.h>
#include <sbml/xml/XMLNode.h>

#include <limits.h>
#include <check.h>

#define XML_HEADER    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define MATHML_HEADER "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
#define MATHML_FOOTER "</math>"

#define wrapMathML(s)   XML_HEADER MATHML_HEADER s MATHML_FOOTER

#if defined(WIN32) && !defined(CYGWIN)
#include <math.h>
extern int isnan(double x); 
extern int isinf(double x); 
extern int finite(double x);
#endif


#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif



START_TEST (test_ASTNode_create)
{
  ASTNode *n = new ASTNode();


  fail_unless( n->getType() == AST_UNKNOWN);
  fail_unless( n->getCharacter() == '\0' );
  fail_unless( n->getName     () == NULL );
  fail_unless( n->getInteger  () == 0    );
  fail_unless( n->getExponent () == 0    );

  fail_unless( n->getNumChildren() == 0 );

  fail_unless( n->getParentSBMLObject() == NULL );

  //EventAssignment_free(ea);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_free_NULL)
{
  ASTNode_free(NULL);
}
END_TEST


START_TEST (test_ASTNode_createFromToken)
{
  const char         *formula = "foo 2 4.0 .272e1 +-*/^@";
  FormulaTokenizer_t *ft      = FormulaTokenizer_createFromFormula(formula);

  Token_t   *t;
  ASTNode *n;
  EventAssignment_t *ea = 
    EventAssignment_create(2, 4);


  /** "foo" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType() == AST_NAME     );
  fail_unless( !strcmp(n->getName(), "foo") );
  fail_unless( n->getNumChildren() == 0     );

  fail_unless( n->getParentSBMLObject() == NULL );

  EventAssignment_free(ea);

  Token_free(t);
  delete n;

  /** "2" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_INTEGER );
  fail_unless( n->getInteger    () == 2 );
  fail_unless( n->getNumChildren() == 0 );

  Token_free(t);
  delete n;

  /** "4.0" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_REAL );
  fail_unless( n->getReal       () == 4.0 );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** ".272e1" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_REAL_E );
  fail_unless( n->getMantissa   () == .272 );
  fail_unless( n->getExponent   () == 1    );
  fail_unless( n->getNumChildren() == 0    );

  Token_free(t);
  delete n;

  /** "+" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_PLUS );
  fail_unless( n->getCharacter  () == '+' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** "-" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_MINUS );
  fail_unless( n->getCharacter  () == '-' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** "*" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_TIMES );
  fail_unless( n->getCharacter  () == '*' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** "/" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_DIVIDE );
  fail_unless( n->getCharacter  () == '/' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** "^" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_POWER );
  fail_unless( n->getCharacter  () == '^' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  /** "@" **/
  t = FormulaTokenizer_nextToken(ft);
  n = new ASTNode(t);

  fail_unless( n->getType       () == AST_UNKNOWN );
  fail_unless( n->getCharacter  () == '@' );
  fail_unless( n->getNumChildren() == 0   );

  Token_free(t);
  delete n;

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeConstants)
{
  ASTNode *n = new ASTNode();


  /** ExponentialE **/
  n->setName("ExponentialE");
  fail_unless( n->isName());

  n->canonicalize();
  fail_unless( n->getType() == AST_CONSTANT_E );

  n->setType(AST_NAME);


  /** False **/
  n->setName("False");
  fail_unless( n->isName());

  n->canonicalize();
  fail_unless( n->getType() == AST_CONSTANT_FALSE );

  n->setType(AST_NAME);


  /** Pi **/
  n->setName("Pi");
  fail_unless( n->isName());

  n->canonicalize();
  fail_unless( n->getType() == AST_CONSTANT_PI );

  n->setType(AST_NAME);


  /** True **/
  n->setName("True");
  fail_unless( n->isName());

  n->canonicalize();
  fail_unless( n->getType() == AST_CONSTANT_TRUE );

  n->setType(AST_NAME);


  /** Foo **/
  n->setName("Foo");
  fail_unless( n->isName());

  n->canonicalize();
  fail_unless( n->isName());


  delete n;
}
END_TEST


START_TEST (test_ASTNode_canonicalizeFunctions)
{
  ASTNode *n = new ASTNode(AST_FUNCTION);


  /** abs **/
  n->setName("abs");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ABS );

  n->setType(AST_FUNCTION);


  /** arccos **/
  n->setName("arccos");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCOS );

  n->setType(AST_FUNCTION);


  /** arccosh **/
  n->setName("arccosh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCOSH );

  n->setType(AST_FUNCTION);


  /** arccot **/
  n->setName("arccot");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCOT );

  n->setType(AST_FUNCTION);


  /** arccoth **/
  n->setName("arccoth");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCOTH );

  n->setType(AST_FUNCTION);


  /** arccsc **/
  n->setName("arccsc");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCSC );

  n->setType(AST_FUNCTION);


  /** arccsch **/
  n->setName("arccsch");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCSCH );

  n->setType(AST_FUNCTION);


  /** arcsec **/
  n->setName("arcsec");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCSEC );

  n->setType(AST_FUNCTION);


  /** arcsech **/
  n->setName("arcsech");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCSECH );

  n->setType(AST_FUNCTION);


  /** arcsin **/
  n->setName("arcsin");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCSIN );

  n->setType(AST_FUNCTION);


  /** arcsinh **/
  n->setName("arcsinh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCSINH );

  n->setType(AST_FUNCTION);


  /** arctan **/
  n->setName("arctan");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCTAN );

  n->setType(AST_FUNCTION);


  /** arctanh **/
  n->setName("arctanh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCTANH );

  n->setType(AST_FUNCTION);


  /** ceiling **/
  n->setName("ceiling");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_CEILING );

  n->setType(AST_FUNCTION);


  /** cos **/
  n->setName("cos");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_COS );

  n->setType(AST_FUNCTION);


  /** cosh **/
  n->setName("cosh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_COSH );

  n->setType(AST_FUNCTION);


  /** cot **/
  n->setName("cot");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_COT );

  n->setType(AST_FUNCTION);


  /** coth **/
  n->setName("coth");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_COTH );

  n->setType(AST_FUNCTION);


  /** csc **/
  n->setName("csc");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_CSC );

  n->setType(AST_FUNCTION);


  /** csch **/
  n->setName("csch");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_CSCH );

  n->setType(AST_FUNCTION);


  /** exp **/
  n->setName("exp");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_EXP );

  n->setType(AST_FUNCTION);


  /** factorial **/
  n->setName("factorial");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_FACTORIAL );

  n->setType(AST_FUNCTION);


  /** floor **/
  n->setName("floor");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_FLOOR );

  n->setType(AST_FUNCTION);


  /** lambda **/
  n->setName("lambda");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_LAMBDA );

  n->setType(AST_FUNCTION);


  /** ln **/
  n->setName("ln");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_LN );

  n->setType(AST_FUNCTION);


  /** log **/
  n->setName("log");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_LOG );

  n->setType(AST_FUNCTION);


  /** piecewise **/
  n->setName("piecewise");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_PIECEWISE );

  n->setType(AST_FUNCTION);


  /** power **/
  n->setName("power");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_POWER );

  n->setType(AST_FUNCTION);


  /** root **/
  n->setName("root");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ROOT );

  n->setType(AST_FUNCTION);


  /** sec **/
  n->setName("sec");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_SEC );

  n->setType(AST_FUNCTION);


  /** sech **/
  n->setName("sech");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_SECH );

  n->setType(AST_FUNCTION);


  /** sin **/
  n->setName("sin");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_SIN );

  n->setType(AST_FUNCTION);


  /** sinh **/
  n->setName("sinh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_SINH );

  n->setType(AST_FUNCTION);


  /** tan **/
  n->setName("tan");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_TAN );

  n->setType(AST_FUNCTION);


  /** tanh **/
  n->setName("tanh");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_TANH );

  n->setType(AST_FUNCTION);


  /** Foo **/
  n->setName("Foo");
  fail_unless( n->getType() == AST_FUNCTION);

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION );


  delete n;
}
END_TEST


START_TEST (test_ASTNode_canonicalizeFunctionsL1)
{
  ASTNode *n = new ASTNode(AST_FUNCTION);
  ASTNode *c;


  /** acos **/
  n->setName("acos");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCCOS );

  n->setType(AST_FUNCTION);


  /** asin **/
  n->setName("asin");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCSIN );

  n->setType(AST_FUNCTION);


  /** atan **/
  n->setName("atan");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_ARCTAN );

  n->setType(AST_FUNCTION);


  /** ceil **/
  n->setName("ceil");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_CEILING );

  n->setType(AST_FUNCTION);

  /** pow **/
  n->setName("pow");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_FUNCTION_POWER );

  delete n;

  /**
   * log(x) and log(x, y)
   *
   * In SBML L1 log(x) (with exactly one argument) canonicalizes to a node
   * of type AST_FUNCTION_LN (see L1 Specification, Appendix C), whereas
   * log(x, y) canonicalizes to a node of type AST_FUNCTION_LOG.
   */
  n = new ASTNode(AST_FUNCTION);
  n->setName("log");

  c = new ASTNode();
  c->setName ("x");
  n->addChild(c);

  fail_unless( n->getType() == AST_FUNCTION );  
  fail_unless( n->getNumChildren() == 1 );

  n->canonicalize();

  fail_unless( n->getType() == AST_FUNCTION_LN );  
  fail_unless( n->getNumChildren() == 1 );

  /** log(x, y) (continued) **/
  n->setType(AST_FUNCTION);
  n->setName("log");

  c = new ASTNode();
  c->setName ("y");
  n->addChild(c);

  fail_unless( n->getType() == AST_FUNCTION );
  fail_unless( n->getNumChildren() == 2 );

  n->canonicalize();

  fail_unless( n->getType() == AST_FUNCTION_LOG );

  delete n;


  /** log10(x) -> log(10, x) **/
  n = new ASTNode(AST_FUNCTION);
  n->setName("log10");

  c = new ASTNode();
  c->setName ("x");
  n->addChild(c);

  fail_unless( n->getType() == AST_FUNCTION );  
  fail_unless( n->getNumChildren() == 1 );

  n->canonicalize();

  fail_unless( n->getType() == AST_FUNCTION_LOG );  
  fail_unless( n->getNumChildren() == 2 );

  c = n->getLeftChild();
  fail_unless( c->getType()    == AST_INTEGER );
  fail_unless( c->getInteger() == 10 );

  c = n->getRightChild();
  fail_unless( c->getType() == AST_NAME   );
  fail_unless( !strcmp(c->getName(), "x") );

  delete n;


  /** sqr(x) -> power(x, 2) **/
  n = new ASTNode(AST_FUNCTION);
  n->setName("sqr");

  c = new ASTNode();
  c->setName ("x");
  n->addChild(c);

  fail_unless( n->getType() == AST_FUNCTION );  
  fail_unless( n->getNumChildren() == 1 );

  n->canonicalize();

  fail_unless( n->getType() == AST_FUNCTION_POWER );  
  fail_unless( n->getNumChildren() == 2 );

  c = n->getLeftChild();
  fail_unless( c->getType() == AST_NAME   );
  fail_unless( !strcmp(c->getName(), "x") );

  c = n->getRightChild();
  fail_unless( c->getType()    == AST_INTEGER );
  fail_unless( c->getInteger() == 2 );

  delete n;


  /** sqrt(x) -> root(2, x) **/
  n = new ASTNode(AST_FUNCTION);
  n->setName("sqrt");

  c = new ASTNode();
  c->setName ("x");
  n->addChild(c);

  fail_unless( n->getType() == AST_FUNCTION );  
  fail_unless( n->getNumChildren() == 1 );

  n->canonicalize();

  fail_unless( n->getType() == AST_FUNCTION_ROOT );  
  fail_unless( n->getNumChildren() == 2 );

  c = n->getLeftChild();
  fail_unless( c->getType()    == AST_INTEGER );
  fail_unless( c->getInteger() == 2 );

  c = n->getRightChild();
  fail_unless( c->getType() == AST_NAME   );
  fail_unless( !strcmp(c->getName(), "x") );

  delete n;
}
END_TEST


START_TEST (test_ASTNode_canonicalizeLogical)
{
  ASTNode *n = new ASTNode(AST_FUNCTION);


  /** and **/
  n->setName("and");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_LOGICAL_AND );

  n->setType(AST_FUNCTION);


  /** not **/
  n->setName("not");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_LOGICAL_NOT );

  n->setType(AST_FUNCTION);


  /** or **/
  n->setName("or");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_LOGICAL_OR );

  n->setType(AST_FUNCTION);


  /** xor **/
  n->setName("xor");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_LOGICAL_XOR );

  n->setType(AST_FUNCTION);


  delete n;
}
END_TEST


START_TEST (test_ASTNode_canonicalizeRelational)
{
  ASTNode *n = new ASTNode(AST_FUNCTION);


  /** eq **/
  n->setName("eq");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_EQ );

  n->setType(AST_FUNCTION);


  /** geq **/
  n->setName("geq");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_GEQ );

  n->setType(AST_FUNCTION);


  /** gt **/
  n->setName("gt");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_GT );

  n->setType(AST_FUNCTION);


  /** leq **/
  n->setName("leq");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_LEQ );

  n->setType(AST_FUNCTION);


  /** lt **/
  n->setName("lt");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_LT );

  n->setType(AST_FUNCTION);


  /** neq **/
  n->setName("neq");
  fail_unless( n->getType() == AST_FUNCTION );

  n->canonicalize();
  fail_unless( n->getType() == AST_RELATIONAL_NEQ );

  n->setType(AST_FUNCTION);


  delete n;
}
END_TEST


START_TEST (test_ASTNode_deepCopy_1)
{
  ASTNode *node = new ASTNode();
  ASTNode *child, *copy;


  /** 1 + 2 **/
  node->setCharacter('+');
  node->addChild(new ASTNode() );
  node->addChild(new ASTNode() );

  node->getLeftChild()->setValue((long)(1) );
  node->getRightChild()->setValue(long (2) );

  fail_unless( node->getType       () == AST_PLUS );
  fail_unless( node->getCharacter  () == '+'      );
  fail_unless( node->getNumChildren() == 2        );

  child = node->getLeftChild();

  fail_unless( child->getType       () == AST_INTEGER );
  fail_unless( child->getInteger    () == 1           );
  fail_unless( child->getNumChildren() == 0           );

  child = node->getRightChild();

  fail_unless( child->getType       () == AST_INTEGER );
  fail_unless( child->getInteger    () == 2           );
  fail_unless( child->getNumChildren() == 0           );

  /** deepCopy() **/
  copy = node->deepCopy();

  fail_unless( copy != node );
  fail_unless( copy->getType       () == AST_PLUS );
  fail_unless( copy->getCharacter  () == '+'      );
  fail_unless( copy->getNumChildren() == 2        );

  child = copy->getLeftChild();

  fail_unless( child != node->getLeftChild() );
  fail_unless( child->getType       () == AST_INTEGER );
  fail_unless( child->getInteger    () == 1           );
  fail_unless( child->getNumChildren() == 0           );

  child = copy->getRightChild();
  fail_unless( child != node->getRightChild() );
  fail_unless( child->getType       () == AST_INTEGER );
  fail_unless( child->getInteger    () == 2           );
  fail_unless( child->getNumChildren() == 0           );

  fail_unless(node->isWellFormedASTNode() == true);

  delete node;
  delete copy;
}
END_TEST


START_TEST (test_ASTNode_deepCopy_2)
{
  ASTNode *node = new ASTNode();
  ASTNode *copy;


  node->setName("Foo");

  fail_unless( node->getType() == AST_NAME     );
  fail_unless( !strcmp(node->getName(), "Foo") );
  fail_unless( node->getNumChildren() == 0     );

  /** deepCopy() **/
  copy = node->deepCopy();

  fail_unless( copy != node );
  fail_unless( copy->getType() == AST_NAME     );
  fail_unless( !strcmp(copy->getName(), "Foo") );
  fail_unless( copy->getNumChildren() == 0     );

  fail_unless( !strcmp(node->getName(), copy->getName()) );

  fail_unless(node->isWellFormedASTNode() == true);

  delete node;
  delete copy;
}
END_TEST


START_TEST (test_ASTNode_deepCopy_3)
{
  ASTNode *node = new ASTNode(AST_FUNCTION);
  ASTNode *copy;


  node->setName("Foo");
  fail_unless( node->getType() == AST_FUNCTION );
  fail_unless( !strcmp(node->getName(), "Foo") );
  fail_unless( node->getNumChildren() == 0     );

  /** deepCopy() **/
  copy = node->deepCopy();

  fail_unless( copy != node );
  fail_unless( copy->getType() == AST_FUNCTION );
  fail_unless( !strcmp(copy->getName(), "Foo") );
  fail_unless( copy->getNumChildren() == 0     );

  fail_unless( !strcmp(copy->getName(), node->getName()) );

  fail_unless(node->isWellFormedASTNode() == true);

  delete node;
  delete copy;
}
END_TEST


START_TEST (test_ASTNode_deepCopy_4)
{
  ASTNode *node = new ASTNode(AST_FUNCTION_ABS);
  ASTNode *copy;


  node->setName("ABS");
  fail_unless( node->getType() == AST_FUNCTION_ABS );
  fail_unless( !strcmp(node->getName(), "ABS")     );
  fail_unless( node->getNumChildren() == 0         );

  /** deepCopy() **/
  copy = node->deepCopy();

  fail_unless( copy != node );
  fail_unless( copy->getType() == AST_FUNCTION_ABS );
  fail_unless( !strcmp(copy->getName(), "ABS")     );
  fail_unless( copy->getNumChildren() == 0         );

  fail_unless( !strcmp(copy->getName(), node->getName()) );

  fail_unless(node->isWellFormedASTNode() == false);

  delete node;
  delete copy;
}
END_TEST


START_TEST (test_ASTNode_deepCopy_5)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  ASTNode *copy;


  node->setValue((long)(2));
  fail_unless( node->getType() == AST_INTEGER );
  fail_unless( node->getInteger() == 2     );
  fail_unless( node->getNumChildren() == 0         );

  /** deepCopy() **/
  copy = node->deepCopy();

  fail_unless( copy != node );
  fail_unless( copy->getType() == AST_INTEGER );
  fail_unless( copy->getInteger() == 2     );
  fail_unless( copy->getNumChildren() == 0         );

  fail_unless(node->isWellFormedASTNode() == true);

  delete node;
  delete copy;
}
END_TEST


START_TEST (test_ASTNode_getName)
{
  ASTNode *n = new ASTNode();


  /** AST_NAMEs **/
  n->setName("foo");
  fail_unless( !strcmp(n->getName(), "foo") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_NAME_TIME);
  fail_unless( !strcmp(n->getName(), "foo") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setName(NULL);
  fail_unless( n->getName() == NULL );
  fail_unless(n->isWellFormedASTNode() == true);


  /** AST_CONSTANTs **/
  n->setType(AST_CONSTANT_E);
  fail_unless( !strcmp(n->getName(), "exponentiale") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_CONSTANT_FALSE);
  fail_unless( !strcmp(n->getName(), "false") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_CONSTANT_PI);
  fail_unless( !strcmp(n->getName(), "pi") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_CONSTANT_TRUE);
  fail_unless( !strcmp(n->getName(), "true") );
  fail_unless(n->isWellFormedASTNode() == true);


  ///** AST_LAMBDA **/
  n->setType(AST_LAMBDA);
  fail_unless( !strcmp(n->getName(), "lambda") );
  fail_unless(n->isWellFormedASTNode() == false);


  ///** AST_FUNCTION (user-defined) **/
  n->setType(AST_FUNCTION);
  n->setName("f");
  fail_unless( !strcmp(n->getName(), "f") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_FUNCTION_DELAY);
  fail_unless( !strcmp(n->getName(), "f") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setName(NULL);
  fail_unless( !strcmp(n->getName(), "delay") );

  n->setType(AST_FUNCTION);
  fail_unless( n->getName() == NULL );
  fail_unless(n->isWellFormedASTNode() == true);


  ///** AST_FUNCTIONs (builtin)  **/
  n->setType(AST_FUNCTION_ABS);
  fail_unless( !strcmp(n->getName(), "abs") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_FUNCTION_ARCCOS);
  fail_unless( !strcmp(n->getName(), "arccos") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_FUNCTION_TAN);
  fail_unless( !strcmp(n->getName(), "tan") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_FUNCTION_TANH);
  fail_unless( !strcmp(n->getName(), "tanh") );
  fail_unless(n->isWellFormedASTNode() == false);


  ///** AST_LOGICALs **/
  n->setType(AST_LOGICAL_AND);
  fail_unless( !strcmp(n->getName(), "and") );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_LOGICAL_NOT);
  fail_unless( !strcmp(n->getName(), "not") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_LOGICAL_OR);
  fail_unless( !strcmp(n->getName(), "or")  );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_LOGICAL_XOR);
  fail_unless( !strcmp(n->getName(), "xor") );
  fail_unless(n->isWellFormedASTNode() == true);


  ///** AST_RELATIONALs **/
  n->setType(AST_RELATIONAL_EQ);
  fail_unless( !strcmp(n->getName(), "eq") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_RELATIONAL_GEQ);
  fail_unless( !strcmp(n->getName(), "geq") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_RELATIONAL_LT);
  fail_unless( !strcmp(n->getName(), "lt") );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_RELATIONAL_NEQ);
  fail_unless( !strcmp(n->getName(), "neq") );
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_getReal)
{
  ASTNode *n = new ASTNode(AST_REAL);


  n->setValue(1.6);

  fail_unless(util_isEqual(n->getReal(), 1.6));

  /** 12.3e3 **/
  n->setType(AST_REAL_E);
  n->setValue(12.3, 3);

  fail_unless(util_isEqual(n->getReal(), 12300.0));

  ///** 1/2 **/
  n->setType(AST_RATIONAL);
  n->setValue(long(1), 2);

  fail_unless(util_isEqual(n->getReal(), 0.5));
  
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_getInteger)
{
  ASTNode *n = new ASTNode(AST_INTEGER);
  n->setValue(long(4));

  fail_unless(n->getType() == AST_INTEGER);
  fail_unless(n->getInteger() == 4);

  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST

START_TEST (test_ASTNode_getRational)
{
  ASTNode *n = new ASTNode(AST_RATIONAL);
  n->setValue(long(4), long(2));

  fail_unless(n->getType() == AST_RATIONAL);
  fail_unless(n->getNumerator() == 4);
  fail_unless(n->getDenominator() == 2);
  fail_unless(util_isEqual(n->getReal(), 2));

  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST

START_TEST (test_ASTNode_getRealE)
{
  ASTNode *n = new ASTNode(AST_REAL_E);
  n->setValue(4.2, long(2));

  fail_unless(n->getType() == AST_REAL_E);
  fail_unless(util_isEqual(n->getMantissa(), 4.2));
  fail_unless(n->getExponent() == 2);
  fail_unless(util_isEqual(n->getReal(), 4.2e2));

  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_getPrecedence)
{
  ASTNode *n = new ASTNode();


  n->setType(AST_PLUS);
  fail_unless( n->getPrecedence() == 2 );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_MINUS);
  fail_unless( n->getPrecedence() == 2 );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_TIMES);
  fail_unless( n->getPrecedence() == 3 );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_DIVIDE);
  fail_unless( n->getPrecedence() == 3 );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_POWER);
  fail_unless( n->getPrecedence() == 4 );
  fail_unless(n->isWellFormedASTNode() == false);

  n->setType(AST_MINUS);
  n->addChild(new ASTNode(AST_NAME));
  fail_unless( n->isUMinus() == true );
  fail_unless( n->getPrecedence() == 5 );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_NAME);
  fail_unless( n->getPrecedence() == 6 );
  fail_unless(n->isWellFormedASTNode() == true);

  n->setType(AST_FUNCTION);
  fail_unless( n->getPrecedence() == 6 );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_isLog10)
{
  ASTNode *n = new ASTNode();
  ASTNode *c1, *c2;


  n->setType(AST_FUNCTION);
  fail_unless( n->isLog10() == false );

  /** log() **/
  n->setType(AST_FUNCTION_LOG);
  fail_unless( n->isLog10() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  /** log(10) **/
  c1 = new ASTNode(AST_INTEGER);
  c1->setValue(10);

  n->addChild(c1);

  fail_unless( n->isLog10() == false );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  /* log (base=10, ?) */
  n = new ASTNode(AST_FUNCTION_LOG);
  fail_unless(n->isWellFormedASTNode() == false);

  c1 = new ASTNode(AST_QUALIFIER_LOGBASE);
  
  ASTNode* c1_1 = new ASTNode(AST_INTEGER);
  fail_unless( c1_1->setValue(10) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_1) == LIBSBML_OPERATION_SUCCESS);

  c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

 
  fail_unless (n->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  
  fail_unless( n->isLog10() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  /** log(10, x) -> n->isLog10() == 1 **/
  fail_unless (n->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  fail_unless( n->isLog10() == true );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_isLog10_1)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_LOG);
  ASTNode *c, *c1, *c2;



  c = new ASTNode(AST_QUALIFIER_LOGBASE);
  c1 = new ASTNode(AST_INTEGER);
  c1->setValue(2);

  c->addChild(c1);
  n->addChild(c);
 
  /* log(2, ) */
  fail_unless( n->isLog10() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  c2 = new ASTNode(AST_INTEGER);
  c2->setValue(3);

  n->addChild(c2);

  /* log(2, 3) */
  fail_unless( n->isLog10() == false );
  fail_unless(n->isWellFormedASTNode() == true);


  delete n;
}
END_TEST


START_TEST (test_ASTNode_isSqrt)
{
  ASTNode *n = new ASTNode();
  ASTNode *c1 = new ASTNode(AST_QUALIFIER_DEGREE);
  ASTNode *c1_1 = new ASTNode(AST_INTEGER);
  ASTNode *c2 = new ASTNode(AST_NAME);


  n->setType(AST_FUNCTION);
  fail_unless( n->isSqrt() == false );

  /** root() **/
  n->setType(AST_FUNCTION_ROOT);
  fail_unless( n->isSqrt() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  /** root(2, ?) **/
  c1_1->setValue((long)(2));
  c1->addChild(c1_1);
  n->addChild(c1);

  fail_unless( n->isSqrt() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  /** root(2, x) -> ASTNode_isSqrt() == 1 **/
  n->addChild(c2);
  fail_unless( n->isSqrt() == true );
  fail_unless(n->isWellFormedASTNode() == true);

  /** root(3, x) **/
  c1_1->setValue((long)(3));
  fail_unless( n->isSqrt() == false );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_isSqrt1)
{
  ASTNode *n = new ASTNode();
  ASTNode *c2 = new ASTNode(AST_NAME);


  n->setType(AST_FUNCTION);
  fail_unless( n->isSqrt() == false );

  /** root() **/
  n->setType(AST_FUNCTION_ROOT);
  fail_unless( n->isSqrt() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  /** root(x) -> ASTNode_isSqrt() == 1 **/
  n->addChild(c2);
  fail_unless( n->isSqrt() == false );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_isUMinus)
{
  ASTNode *n = new ASTNode(AST_MINUS);

  fail_unless( n->isUMinus() == false );
  fail_unless(n->isWellFormedASTNode() == false);

  n->addChild(new ASTNode(AST_NAME));
  
  fail_unless( n->isUMinus() == 1 );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST

  
START_TEST (test_ASTNode_isUPlus)
{
  ASTNode *n = new ASTNode(AST_PLUS);

  fail_unless( n->isUPlus() == false );
  fail_unless(n->isWellFormedASTNode() == true);

  n->addChild(new ASTNode(AST_NAME));
  
  fail_unless( n->isUPlus() == 1 );
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_setCharacter)
{
  ASTNode *node = new ASTNode();


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  node->setName("foo");
  fail_unless( node->getType()      == AST_NAME );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( !strcmp(node->getName(), "foo")  );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('+');
  fail_unless( node->getType     () == AST_PLUS );
  fail_unless( node->getCharacter() == '+'      );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('-');
  fail_unless( node->getType     () == AST_MINUS );
  fail_unless( node->getCharacter() == '-'       );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('*');
  fail_unless( node->getType     () == AST_TIMES );
  fail_unless( node->getCharacter() == '*'       );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('/');
  fail_unless( node->getType     () == AST_DIVIDE );
  fail_unless( node->getCharacter() == '/'        );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('^');
  fail_unless( node->getType     () == AST_POWER );
  fail_unless( node->getCharacter() == '^'       );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setCharacter('$');
  fail_unless( node->getType     () == AST_UNKNOWN );
  fail_unless( node->getCharacter() == '$'         );
  fail_unless( node->getName()      == NULL     );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_1)
{
  const char *name = "foo";
  ASTNode  *node = new ASTNode();


  fail_unless( node->getType() == AST_UNKNOWN );

  node->setName(name);

  fail_unless( node->getType() == AST_NAME );
  fail_unless( !strcmp(node->getName(), name) );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  if (node->getName() == name)
  {
    fail("node->setName(...) did not make a copy of name.");
  }

  node->setName(NULL);
  fail_unless( node->getType() == AST_NAME );

  if (node->getName() != NULL)
  {
    fail("node->setName(NULL) did not clear string.");
  }

  node->setType(AST_FUNCTION_COS);
  fail_unless( node->getType() == AST_FUNCTION_COS );
  fail_unless( !strcmp(node->getName(), "cos") );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  node->setType(AST_PLUS);
  node->setName(name);
  fail_unless( node->getType() == AST_NAME );
  fail_unless( !strcmp(node->getName(), name) );
  fail_unless( node->getCharacter() == '+'        );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_2)
{
  const char *name = "foo";
  ASTNode  *node = new ASTNode();
  node->setId("s");

  fail_unless( node->getType() == AST_UNKNOWN );

  node->setName(name);

  fail_unless( node->getType() == AST_NAME );
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), name) == 0);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_3)
{
  const char *name = "foo";
  ASTNode  *node = new ASTNode(AST_PLUS);
  node->setId("s");

  node->setName(name);

  fail_unless( node->getType() == AST_NAME );
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), name) == 0);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_4)
{
  const char *name = "foo";
  ASTNode  *node = new ASTNode(AST_INTEGER);
  node->setId("s");

  node->setName(name);

  fail_unless( node->getType() == AST_NAME );
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), name) == 0);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_5)
{
  const char *name = "foo";
  ASTNode  *node = new ASTNode(AST_INTEGER);
  node->setId("s");
  node->setUnits("mole");

  node->setName(name);

  fail_unless( node->getType() == AST_NAME );
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), name) == 0);
  fail_unless( node->getUnits() == "");

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setName_override)
{
  ASTNode  *node = new ASTNode(AST_FUNCTION_SIN);


  fail_unless( !strcmp(node->getName(), "sin")     );
  fail_unless( node->getType() == AST_FUNCTION_SIN );

  node->setName("MySinFunc");

  fail_unless( !strcmp(node->getName(), "MySinFunc") );
  fail_unless( node->getType() == AST_FUNCTION_SIN   );

  node->setName(NULL);

  fail_unless( !strcmp(node->getName(), "sin")     );
  fail_unless( node->getType() == AST_FUNCTION_SIN );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setInteger)
{
  Model * m = new Model(3,1);
  ASTNode *node = new ASTNode();
  node->setStyle("style");
  node->setParentSBMLObject(m);


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  node->setName("foo");
  fail_unless( node->getType() == AST_NAME );
  fail_unless( !strcmp(node->getName(), "foo") );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( node->getInteger()   == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( node->getStyle() == "style"      );
  fail_unless( node->getParentSBMLObject() == m );

  node->setValue(3.2);
  fail_unless( node->getType   () == AST_REAL );
  fail_unless( node->getInteger() == 0         );
  fail_unless( node->getName()== NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 3.2)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( node->getStyle() == "style"      );
  fail_unless( node->getParentSBMLObject() == m );

  node->setValue((long)(321));
  fail_unless( node->getType   () == AST_INTEGER );
  fail_unless( node->getInteger() == 321         );
  fail_unless( node->getName()== NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setReal)
{
  ASTNode *node = new ASTNode(AST_REAL);

  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  node->setName("foo");
  fail_unless( node->getType() == AST_NAME );

  node->setValue(32.1);
  fail_unless( node->getType() == AST_REAL );
  fail_unless( node->getInteger() == 0         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 32.1)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 32.1)     );

  node->setValue(long(45), long(90));
  fail_unless( node->getType() == AST_RATIONAL );
  fail_unless( node->getInteger() == 45         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 0.5)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 90      );
  fail_unless( util_isEqual(node->getMantissa(), 0)     );

  node->setValue(32.0, 4);
  fail_unless( node->getType() == AST_REAL_E );
  fail_unless( node->getInteger() == 0         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 320000)        );
  fail_unless( node->getExponent()  == 4        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 32)     );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setValue)
{
  ASTNode *node = new ASTNode(AST_FUNCTION);
  node->setClass("c");

  node->setValue(32.1);
  fail_unless( node->getType() == AST_REAL );
  fail_unless( node->getInteger() == 0         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 32.1)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 32.1)     );
  fail_unless( node->getClass() == "c");

  delete node;
  node = new ASTNode(AST_FUNCTION);
  node->setClass("c");

  node->setValue(long(45), long(90));
  fail_unless( node->getType() == AST_RATIONAL );
  fail_unless( node->getInteger() == 45         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 0.5)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 90      );
  fail_unless( util_isEqual(node->getMantissa(), 0)     );
  fail_unless( node->getClass() == "c");

  delete node;
  node = new ASTNode(AST_FUNCTION);
  node->setClass("c");

  node->setValue(32.0, 4);
  fail_unless( node->getType() == AST_REAL_E );
  fail_unless( node->getInteger() == 0         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 320000)        );
  fail_unless( node->getExponent()  == 4        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 32)     );
  fail_unless( node->getClass() == "c");

  delete node;
  node = new ASTNode(AST_FUNCTION);
  node->setClass("c");

  node->setValue((long)(4));
  fail_unless( node->getType() == AST_INTEGER );
  fail_unless( node->getInteger() == 4         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 0)     );
  fail_unless( node->getClass() == "c");

  delete node;
  node = new ASTNode(AST_FUNCTION);
  node->setClass("c");

  node->setValue((int)(4));
  fail_unless( node->getType() == AST_INTEGER );
  fail_unless( node->getInteger() == 4         );
  fail_unless( node->getName() == NULL );
  fail_unless( node->getCharacter() == 0        );
  fail_unless( util_isEqual(node->getReal(), 0)        );
  fail_unless( node->getExponent()  == 0        );
  fail_unless( node->getDenominator() == 1      );
  fail_unless( util_isEqual(node->getMantissa(), 0)     );
  fail_unless( node->getClass() == "c");

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setType_1)
{
  ASTNode *node = new ASTNode(AST_NAME);

  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  node->setName("foo");
  fail_unless( node->getType() == AST_NAME );

  /**
   * node->value.name should not to cleared or changed as we toggle from
   * AST_FUNCTION to and from AST_NAME.
   */
  node->setType(AST_FUNCTION);
  fail_unless( node->getType() == AST_FUNCTION );
  fail_unless( !strcmp(node->getName(), "foo") );

  node->setType(AST_NAME);
  fail_unless( node->getType() == AST_NAME );
  fail_unless( !strcmp(node->getName(), "foo") );

  /**
   * But now it should...
   */
  node->setType(AST_INTEGER);
  fail_unless( node->getType() == AST_INTEGER );

  node->setType(AST_REAL);
  fail_unless( node->getType() == AST_REAL );

  node->setType(AST_UNKNOWN);
  fail_unless( node->getType() == AST_UNKNOWN );

  /**
   * Setting these types should also set node->value.ch
   */
  node->setType(AST_PLUS);
  fail_unless( node->getType     () == AST_PLUS );
  fail_unless( node->getCharacter() == '+'      );

  node->setType(AST_MINUS);
  fail_unless( node->getType     () == AST_MINUS );
  fail_unless( node->getCharacter() == '-'       );

  node->setType(AST_TIMES);
  fail_unless( node->getType     () == AST_TIMES );
  fail_unless( node->getCharacter() == '*'       );

  node->setType(AST_DIVIDE);
  fail_unless( node->getType     () == AST_DIVIDE );
  fail_unless( node->getCharacter() == '/'        );

  node->setType(AST_POWER);
  fail_unless( node->getType     () == AST_POWER );
  fail_unless( node->getCharacter() == '^'       );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_setType_2)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  Model* m = new Model(3,1);
  node->setValue((long)(1));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 1);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_REAL);

  fail_unless( node->getType() == AST_REAL);
  fail_unless( node->getInteger() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_3)
{
  ASTNode *node = new ASTNode(AST_REAL_E);
  Model* m = new Model(3,1);
  node->setValue(2.3, (long)(1));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_REAL_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 2.3));
  fail_unless( node->getExponent() == 1);
  fail_unless( util_isEqual(node->getReal(), 23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_RATIONAL);

  fail_unless( node->getType() == AST_RATIONAL);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_4)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == false);
  fail_unless( node->isName() == true);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/time");
  //fail_unless( node->getEncoding() == "text");

  node->setType(AST_NAME_AVOGADRO);

  fail_unless( node->getType() == AST_NAME_AVOGADRO);
  fail_unless( util_isEqual(node->getReal(), 6.02214179e23));
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == true);
  fail_unless( node->isName() == true);
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/avogadro");
  //fail_unless( node->getEncoding() == "text");


  delete m;
  delete node;
}
END_TEST


START_TEST (test_ASTNode_setType_5)
{
  ASTNode *node = new ASTNode(AST_CONSTANT_PI);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_CONSTANT_PI);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == true);
  fail_unless( node->getInteger() == 0);

  node->setType(AST_INTEGER);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == false);
  fail_unless( node->getInteger() == 0);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_6)
{
  ASTNode *node = new ASTNode(AST_NAME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);
  node->setDefinitionURL("my_url");

  fail_unless( node->getType() == AST_NAME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->getDefinitionURLString() == "my_url");

  node->setType(AST_INTEGER);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getId() == "s");
  fail_unless( node->getName() == NULL);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->getInteger() == 0);


  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_7)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_REAL);

  fail_unless( node->getType() == AST_REAL);
  fail_unless( node->getId() == "s");
  fail_unless( node->getName() == NULL);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( util_isEqual(node->getReal(), 0));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_8)
{
  ASTNode *node = new ASTNode(AST_REAL_E);
  Model* m = new Model(3,1);
  node->setValue(2.3, (long)(1));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_REAL_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 2.3));
  fail_unless( node->getExponent() == 1);
  fail_unless( util_isEqual(node->getReal(), 23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");

  node->setType(AST_NAME_AVOGADRO);

  fail_unless( node->getType() == AST_NAME_AVOGADRO);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 6.02214179e23));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 6.02214179e23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/avogadro");


  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_9)
{
  ASTNode *node = new ASTNode(AST_REAL_E);
  Model* m = new Model(3,1);
  node->setValue(2.3, (long)(1));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_REAL_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 2.3));
  fail_unless( node->getExponent() == 1);
  fail_unless( util_isEqual(node->getReal(), 23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_NAME);

  fail_unless( node->getType() == AST_NAME);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_10)
{
  ASTNode *node = new ASTNode(AST_REAL_E);
  Model* m = new Model(3,1);
  node->setValue(2.3, (long)(1));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_REAL_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 2.3));
  fail_unless( node->getExponent() == 1);
  fail_unless( util_isEqual(node->getReal(), 23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_PLUS);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_11)
{
  ASTNode *node = new ASTNode(AST_REAL);
  Model* m = new Model(3,1);
  node->setValue(2.3);
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_REAL);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 2.3));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 2.3));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_FUNCTION_COS);

  fail_unless( node->getType() == AST_FUNCTION_COS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_12)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  Model* m = new Model(3,1);
  node->setValue((long)(2));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 2);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_DIVIDE);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_13)
{
  ASTNode *node = new ASTNode(AST_NAME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);
  node->setDefinitionURL("my_url");

  fail_unless( node->getType() == AST_NAME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->getDefinitionURLString() == "my_url");

  node->setType(AST_FUNCTION);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() == "my_url");


  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_14)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_LAMBDA);

  fail_unless( node->getType() == AST_LAMBDA);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( util_isEqual(node->getReal(), 0));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_15)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_FUNCTION_PIECEWISE);

  fail_unless( node->getType() == AST_FUNCTION_PIECEWISE);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( util_isEqual(node->getReal(), 0));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_16)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_FUNCTION_DELAY);

  fail_unless( node->getType() == AST_FUNCTION_DELAY);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/delay");
  fail_unless( util_isEqual(node->getReal(), 0));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_17)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  Model* m = new Model(3,1);
  node->setValue((long)(2));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 2);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");

  node->setType(AST_FUNCTION_DELAY);

  fail_unless( node->getType() == AST_FUNCTION_DELAY);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/delay");



  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_18)
{
  ASTNode *node = new ASTNode(AST_PLUS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_INTEGER);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_19)
{
  ASTNode *node = new ASTNode(AST_FUNCTION_COS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_FUNCTION_COS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_RATIONAL);

  fail_unless( node->getType() == AST_RATIONAL);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_20)
{
  ASTNode *node = new ASTNode(AST_DIVIDE);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_REAL_E);

  fail_unless( node->getType() == AST_REAL_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_21)
{
  ASTNode *node = new ASTNode(AST_FUNCTION);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  node->setType(AST_REAL);

  fail_unless( node->getType() == AST_REAL);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_22)
{
  ASTNode *node = new ASTNode(AST_PLUS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getName() == NULL);

  node->setType(AST_NAME);

  fail_unless( node->getType() == AST_NAME);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->getName() == NULL);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_23)
{
  ASTNode *node = new ASTNode(AST_PLUS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == false);

  node->setType(AST_CONSTANT_E);

  fail_unless( node->getType() == AST_CONSTANT_E);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isConstant() == true);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_24)
{
  ASTNode *node = new ASTNode(AST_PLUS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getName() == NULL);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->isConstant() == false);

  node->setType(AST_NAME_AVOGADRO);

  fail_unless( node->getType() == AST_NAME_AVOGADRO);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 6.02214179e23));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 6.02214179e23));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( strcmp(node->getName(), "avogadro") == 0);
  fail_unless( node->getDefinitionURLString() == 
    "http://www.sbml.org/sbml/symbols/avogadro");
  fail_unless( node->isConstant() == true);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_25)
{
  ASTNode *node = new ASTNode(AST_PLUS);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getName() == NULL);
  fail_unless( node->getDefinitionURLString() == "");

  node->setType(AST_NAME_TIME);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->getName() == NULL);
  fail_unless( node->getDefinitionURLString() == 
    "http://www.sbml.org/sbml/symbols/time");

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_26)
{
  ASTNode *node = new ASTNode(AST_FUNCTION_DELAY);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_FUNCTION_DELAY);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( strcmp(node->getName(), "delay") == 0);
  fail_unless( node->getDefinitionURLString() == 
    "http://www.sbml.org/sbml/symbols/delay");

  node->setType(AST_NAME_TIME);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->getName() == NULL);
  fail_unless( node->getDefinitionURLString() == 
    "http://www.sbml.org/sbml/symbols/time");

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_27)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_PLUS);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_PLUS);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_FUNCTION_COS);

  fail_unless( node->getType() == AST_FUNCTION_COS);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_28)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_RELATIONAL_NEQ);

  fail_unless( node->getType() == AST_RELATIONAL_NEQ);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_29)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_LOGICAL_OR);

  fail_unless( node->getType() == AST_LOGICAL_OR);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);

  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_30)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_FUNCTION);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_31)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_FUNCTION_DELAY);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_FUNCTION_DELAY);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "delay") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "http://www.sbml.org/sbml/symbols/delay");


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_FUNCTION);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getName() == NULL);
  fail_unless( node->getDefinitionURLString() ==
    "http://www.sbml.org/sbml/symbols/delay");


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_32)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_LAMBDA);

  fail_unless( node->getType() == AST_LAMBDA);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_33)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_FUNCTION_PIECEWISE);

  fail_unless( node->getType() == AST_FUNCTION_PIECEWISE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_34)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_FUNCTION);
  node->setId("s");
  node->setParentSBMLObject(m);
  node->setName("my_func");
  node->setDefinitionURL("my_url");


  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "my_url");


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_FUNCTION_DELAY);

  fail_unless( node->getType() == AST_FUNCTION_DELAY);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "http://www.sbml.org/sbml/symbols/delay");


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setType_35)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_FUNCTION);
  node->setId("s");
  node->setParentSBMLObject(m);
  node->setName("my_func");
  node->setDefinitionURL("my_url");


  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "my_url");


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_LAMBDA);

  fail_unless( node->getType() == AST_LAMBDA);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "");


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_1)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  Model* m = new Model(3,1);
  node->setValue((long)(2));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 2);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->isQualifier() == false);

  node->setType(AST_QUALIFIER_BVAR);

  fail_unless( node->getType() == AST_QUALIFIER_BVAR);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->isQualifier() == true);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_2)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->isQualifier() == false);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_QUALIFIER_BVAR);

  fail_unless( node->getType() == AST_QUALIFIER_BVAR);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->isQualifier() == true);
  fail_unless( node->getDefinitionURLString() 
    == "");
  fail_unless( util_isEqual(node->getReal(), 0));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_3)
{
  ASTNode *node = new ASTNode(AST_INTEGER);
  Model* m = new Model(3,1);
  node->setValue((long)(2));
  node->setId("s");
  node->setUnits("mole");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_INTEGER);
  fail_unless( node->getInteger() == 2);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "mole");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->isSemantics() == false);

  node->setType(AST_SEMANTICS);

  fail_unless( node->getType() == AST_SEMANTICS);
  fail_unless( node->getInteger() == 0);
  fail_unless( util_isEqual(node->getMantissa(), 0));
  fail_unless( node->getExponent() == 0);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDenominator() == 1);
  fail_unless( node->getNumerator() == 0);
  fail_unless( node->getId() == "s");
  fail_unless( node->getUnits() == "");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->getDefinitionURLString() == "");
  fail_unless( node->isSemantics() == true);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_4)
{
  ASTNode *node = new ASTNode(AST_NAME_TIME);
  Model* m = new Model(3,1);
  node->setId("s");
  node->setName("t");
  node->setParentSBMLObject(m);

  fail_unless( node->getType() == AST_NAME_TIME);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == true);
  fail_unless( node->isSemantics() == false);
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/time");

  node->setType(AST_SEMANTICS);

  fail_unless( node->getType() == AST_SEMANTICS);
  fail_unless( node->getId() == "s");
  fail_unless( strcmp(node->getName(), "t") == 0);
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isName() == false);
  fail_unless( node->getDefinitionURLString() 
    == "http://www.sbml.org/sbml/symbols/time");
  fail_unless( util_isEqual(node->getReal(), 0));
  fail_unless( node->isSemantics() == true);

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_5)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_FUNCTION);
  node->setId("s");
  node->setParentSBMLObject(m);
  node->setName("my_func");
  node->setDefinitionURL("my_url");


  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_FUNCTION);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "my_url");
  fail_unless( node->isSemantics() == false);


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_SEMANTICS);

  fail_unless( node->getType() == AST_SEMANTICS);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( strcmp(node->getName(), "my_func") == 0);
  fail_unless( node->getDefinitionURLString() ==
    "my_url");
  fail_unless( node->isSemantics() == true);


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_setNewTypes_6)
{
  Model* m = new Model(3,1);

  ASTNode *node = new ASTNode(AST_DIVIDE);
  node->setId("s");
  node->setParentSBMLObject(m);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setId("c1");
  c1->setName("child");
  node->addChild(c1);

  ASTNode *c2 = new ASTNode(AST_REAL);
  c2->setParentSBMLObject(m);
  c2->setValue(3.2);
  node->addChild(c2);

  fail_unless( node->getType() == AST_DIVIDE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isQualifier() == false);


  ASTNode * child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  node->setType(AST_QUALIFIER_LOGBASE);

  fail_unless( node->getType() == AST_QUALIFIER_LOGBASE);
  fail_unless( node->getNumChildren() == 2);
  fail_unless( node->getId() == "s");
  fail_unless( node->getParentSBMLObject() == m);
  fail_unless( node->isQualifier() == true);


  child = node->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "c1");
  fail_unless( child->getParentSBMLObject() == NULL);
  fail_unless( strcmp(child->getName(), "child") == 0);

  child = node->getChild(1);

  fail_unless( child->getType() == AST_REAL);
  fail_unless( child->getNumChildren() == 0);
  fail_unless( child->getId() == "");
  fail_unless( child->getParentSBMLObject() == m);
  fail_unless( util_isEqual(child->getReal(), 3.2));

  delete node;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_no_children)
{
  ASTNode *node = new ASTNode();


  fail_unless( node->getNumChildren() == 0 );

  fail_unless( node->getLeftChild () == NULL );
  fail_unless( node->getRightChild() == NULL );

  fail_unless( node->getChild(0) == NULL );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_one_child)
{
  ASTNode *node  = new ASTNode(AST_FUNCTION_ABS);
  ASTNode *child = new ASTNode();


  node->addChild(child);

  fail_unless( node->getNumChildren() == 1 );

  fail_unless( node->getLeftChild () == child );
  fail_unless( node->getRightChild() == NULL  );

  fail_unless( node->getChild(0) == child );
  fail_unless( node->getChild(1) == NULL  );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_children)
{
  ASTNode *parent = new ASTNode(AST_PLUS);
  ASTNode *left   = new ASTNode();
  ASTNode *right  = new ASTNode();
  ASTNode *right2 = new ASTNode();


  parent->setType(AST_PLUS);
  left->setValue((long)(1));
  left->setType(AST_INTEGER);
  right->setValue((long)(2));
  right2->setValue((long)(3));

  fail_unless(parent->isWellFormedASTNode() == true);
  /**
   * Two Children
   */
  parent->addChild( left  );
  parent->addChild( right );

  fail_unless(parent->isWellFormedASTNode() == true);
  fail_unless( parent->getNumChildren() == 2 );
  fail_unless( left->getNumChildren()   == 0 );
  fail_unless( right->getNumChildren()  == 0 );

  fail_unless( parent->getLeftChild () == left  );
  fail_unless( parent->getRightChild() == right );

  fail_unless( parent->getChild( 0) == left  );
  fail_unless( parent->getChild( 1) == right );
  fail_unless( parent->getChild( 2) == NULL  );

  /**
   * Three Children
   */
  parent->addChild(right2);

  fail_unless(parent->isWellFormedASTNode() == true);
  fail_unless( parent->getNumChildren() == 3 );
  fail_unless( left->getNumChildren()   == 0 );
  fail_unless( right->getNumChildren()  == 0 );
  fail_unless( right2->getNumChildren() == 0 );

  fail_unless( parent->getLeftChild () == left   );
  fail_unless( parent->getRightChild() == right2 );

  fail_unless( parent->getChild(0) == left   );
  fail_unless( parent->getChild(1) == right  );
  fail_unless( parent->getChild(2) == right2 );
  fail_unless( parent->getChild(3) == NULL   );

  delete parent;
}
END_TEST


START_TEST (test_ASTNode_children1)
{
  ASTNode *parent = new ASTNode();
  ASTNode *left   = new ASTNode();
  ASTNode *right  = new ASTNode();
  ASTNode *right2 = new ASTNode();


  left->setValue((long)(1));
  left->setType(AST_INTEGER);
  right->setValue((long)(2));
  right2->setValue((long)(3));

  fail_unless(parent->isWellFormedASTNode() == true);

  /**
   * Two Children
   */
  parent->addChild( left  );
  parent->addChild( right );

  fail_unless(parent->isWellFormedASTNode() == true);
  fail_unless( parent->getNumChildren() == 2 );
  fail_unless( left->getNumChildren()   == 0 );
  fail_unless( right->getNumChildren()  == 0 );

  fail_unless( parent->getLeftChild () == left  );
  fail_unless( parent->getRightChild() == right );

  fail_unless( parent->getChild( 0) == left  );
  fail_unless( parent->getChild( 1) == right );
  fail_unless( parent->getChild( 2) == NULL  );

  /**
   * Three Children
   */
  parent->addChild(right2);

  fail_unless(parent->isWellFormedASTNode() == true);
  fail_unless( parent->getNumChildren() == 3 );
  fail_unless( left->getNumChildren()   == 0 );
  fail_unless( right->getNumChildren()  == 0 );
  fail_unless( right2->getNumChildren() == 0 );

  fail_unless( parent->getLeftChild () == left   );
  fail_unless( parent->getRightChild() == right2 );

  fail_unless( parent->getChild(0) == left   );
  fail_unless( parent->getChild(1) == right  );
  fail_unless( parent->getChild(2) == right2 );
  fail_unless( parent->getChild(3) == NULL   );

  delete parent;
}
END_TEST


START_TEST (test_ASTNode_nested_children)
{
  ASTNode *parent = new ASTNode(AST_FUNCTION_LOG);
  ASTNode *left   = new ASTNode(AST_QUALIFIER_LOGBASE);
  ASTNode *right  = new ASTNode(AST_INTEGER);
  ASTNode *childOfleft = new ASTNode(AST_INTEGER);

  right->setValue((long)(2));
  childOfleft->setValue((long)(3));

  left->addChild(childOfleft);
  parent->addChild( left  );
  parent->addChild( right );

  fail_unless( parent->getNumChildren() == 2 );
  fail_unless( left->getNumChildren()   == 1 );
  fail_unless( right->getNumChildren()  == 0 );

  fail_unless( parent->getChild (0) == childOfleft  );
  fail_unless( parent->getChild(1) == right );
  fail_unless( parent->getChild( 2) == NULL  );

  //fail_unless( parent->getChild (0)->getNumChildren() == 1   );
  //fail_unless( parent->getChild(0)->getChild(0) == childOfleft );

  fail_unless( parent->isLog10() == false);

  delete parent;
}
END_TEST


START_TEST (test_ASTNode_nested_children1)
{
  ASTNode *parent = new ASTNode(AST_FUNCTION_LOG);
  ASTNode *left   = new ASTNode(AST_QUALIFIER_LOGBASE);
  ASTNode *right  = new ASTNode(AST_INTEGER);
  ASTNode *childOfleft = new ASTNode(AST_INTEGER);

  right->setValue((long)(2));
  childOfleft->setValue((long)(10));

  left->addChild(childOfleft);
  parent->addChild( left  );
  parent->addChild( right );

  fail_unless( parent->getNumChildren() == 2 );
  fail_unless( left->getNumChildren()   == 1 );
  fail_unless( right->getNumChildren()  == 0 );

  fail_unless( parent->getChild (0) == childOfleft  );
  fail_unless( parent->getChild(1) == right );
  fail_unless( parent->getChild( 2) == NULL  );

  //fail_unless( parent->getChild (0)->getNumChildren() == 1   );
  //fail_unless( parent->getChild(0)->getChild(0) == childOfleft );

  fail_unless( parent->isLog10() == true);

  delete parent;
}
END_TEST


START_TEST (test_ASTNode_getListOfNodes1)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();

  node->setType(AST_PLUS);
  c1->setName("foo");
  c2->setName("foo2");
  node->addChild(c1);
  node->addChild(c2);


  List *list = node->getListOfNodes((ASTNodePredicate) ASTNode_isName);

  fail_unless( list->getSize() == 2 );


  ASTNode* node1 = (ASTNode *) list->get(0);

  fail_unless( node1->isName() == true );
  fail_unless( !strcmp(node1->getName(), "foo") );

  node1 = (ASTNode *) list->get(1);

  fail_unless( node1->isName() == true );
  fail_unless( !strcmp(node1->getName(), "foo2") );


  delete list;
  delete node;
}
END_TEST


START_TEST (test_ASTNode_replaceArgument)
{
  ASTNode *arg = new ASTNode();
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  const char * varName = "foo";

  node->setType(AST_PLUS);
  c1->setName(varName);
  c2->setName("foo2");
  node->addChild(c1);
  node->addChild(c2);

  arg->setName("rep1");

  fail_unless( !strcmp(node->getChild(0)->getName(), "foo")); 
  fail_unless( !strcmp(node->getChild(1)->getName(), "foo2")); 

  node->replaceArgument(varName, arg);

  fail_unless( !strcmp(node->getChild(0)->getName(), "rep1")); 
  fail_unless( !strcmp(node->getChild(1)->getName(), "foo2")); 

  delete arg;
  delete node;
}
END_TEST


START_TEST (test_ASTNode_removeChild)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  int i = 0;

  node->setType(AST_PLUS);
  c1->setName("foo");
  c1->setName("foo2");
  node->addChild(c1);
  node->addChild(c2);

  fail_unless( node->getNumChildren() == 2); 


  i = node->removeChild(0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 1); 

  i = node->removeChild(1);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( node->getNumChildren() == 1); 

  i = node->removeChild(0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 0); 

  delete node;
  delete c1;
  delete c2;
}
END_TEST


START_TEST (test_ASTNode_replaceChild)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *c3 = new ASTNode();
  ASTNode *c4 = new ASTNode();
  ASTNode *c5 = new ASTNode();
  int i = 0;

  node->setType(AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  c3->setName("c");
  c4->setName("d");
  c5->setName("e");
  node->addChild(c1);
  node->addChild(c2);
  node->addChild(c3);

  fail_unless( node->getNumChildren() == 3); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(a, b, c)"));

  i = node->replaceChild(0, c4, true);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 3); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(d, b, c)"));

  i = node->replaceChild(3, c4, true);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( node->getNumChildren() == 3); 
 // fail_unless( !strcmp(SBML_formulaToString(node), "and(d, b, c)"));

  i = node->replaceChild(1, c5, true);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 3); 
  fail_unless( !strcmp(node->getChild(1)->getName(), "e"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(d, e, c)"));

  delete node;
}
END_TEST


START_TEST (test_ASTNode_insertChild)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *c3 = new ASTNode();
  ASTNode *newc = new ASTNode();
  ASTNode *newc1 = new ASTNode();
  int i = 0;

  node->setType(AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  c3->setName("c");
  node->addChild(c1);
  node->addChild(c2);
  node->addChild(c3);

  fail_unless( node->getNumChildren() == 3); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "c"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(a, b, c)"));

  newc->setName("d");
  newc1->setName("e");

  i = node->insertChild(1, newc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 4); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "b"));
  fail_unless( !strcmp(node->getChild(3)->getName(), "c"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(a, d, b, c)"));

  i = node->insertChild(5, newc);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( node->getNumChildren() == 4); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "b"));
  fail_unless( !strcmp(node->getChild(3)->getName(), "c"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(a, d, b, c)"));

  i = node->insertChild(2, newc1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 5); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "e"));
  fail_unless( !strcmp(node->getChild(3)->getName(), "b"));
  fail_unless( !strcmp(node->getChild(4)->getName(), "c"));
//  fail_unless( !strcmp(SBML_formulaToString(node), "and(a, d, e, b, c)"));

  delete node;
}
END_TEST


START_TEST (test_ASTNode_swapChildren)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *node_1 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  ASTNode *c2_1 = new ASTNode();
  int i = 0;

  node->setType( AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  node->addChild( c1);
  node->addChild( c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
 // fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  node_1->setType(AST_LOGICAL_AND);
  c1_1->setName("d");
  c2_1->setName("f");
  node_1->addChild(c1_1);
  node_1->addChild(c2_1);

  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(d, f)"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, f)"));
  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(a, b)"));

  delete node;
  delete node_1;
}
END_TEST


START_TEST (test_ASTNode_swapChildren1)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  //ASTNode *c2 = new ASTNode();
  ASTNode *node_1 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  //ASTNode *c2_1 = new ASTNode();
  int i = 0;

  node->setType( AST_FUNCTION_COS);
  c1->setName("a");
  node->addChild( c1);

  fail_unless( node->getNumChildren() == 1); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
 // fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  node_1->setType(AST_FUNCTION_COS);
  c1_1->setName("d");
  node_1->addChild(c1_1);

  fail_unless( node_1->getNumChildren() == 1); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(d, f)"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 1); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, f)"));
  fail_unless( node_1->getNumChildren() == 1); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(a, b)"));

  delete node;
  delete node_1;
}
END_TEST


START_TEST (test_ASTNode_swapChildren2)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *node_1 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  ASTNode *c2_1 = new ASTNode();
  int i = 0;

  node->setType( AST_FUNCTION_DELAY);
  c1->setName("a");
  c2->setName("b");
  node->addChild( c1);
  node->addChild( c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
 // fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  node_1->setType(AST_LOGICAL_AND);
  c1_1->setName("d");
  c2_1->setName("f");
  node_1->addChild(c1_1);
  node_1->addChild(c2_1);

  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(d, f)"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, f)"));
  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(a, b)"));

  delete node;
  delete node_1;
}
END_TEST


START_TEST (test_ASTNode_swapChildren3)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *node_1 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  ASTNode *c2_1 = new ASTNode();
  int i = 0;

  node->setType( AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  node->addChild( c1);
  node->addChild( c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
 // fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  node_1->setType(AST_FUNCTION_DELAY);
  c1_1->setName("d");
  c2_1->setName("f");
  node_1->addChild(c1_1);
  node_1->addChild(c2_1);

  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(d, f)"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, f)"));
  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(a, b)"));

  delete node;
  delete node_1;
}
END_TEST


START_TEST (test_ASTNode_swapChildren4)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *node_1 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  ASTNode *c2_1 = new ASTNode();
  int i = 0;

  node->setType( AST_FUNCTION_DELAY);
  c1->setName("a");
  c2->setName("b");
  node->addChild( c1);
  node->addChild( c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
 // fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  node_1->setType(AST_FUNCTION_DELAY);
  c1_1->setName("d");
  c2_1->setName("f");
  node_1->addChild(c1_1);
  node_1->addChild(c2_1);

  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(d, f)"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "f"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, f)"));
  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(node_1), "and(a, b)"));

  delete node;
  delete node_1;
}
END_TEST


START_TEST (test_ASTNode_swapChildren5)
{
  ASTNode *node = new ASTNode(AST_SEMANTICS);
  ASTNode *n1 = new ASTNode(AST_PLUS);
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  
  ASTNode *node_1 = new ASTNode(AST_MINUS);
  ASTNode *c1_1 = new ASTNode();
  ASTNode *c2_1 = new ASTNode();
  
  c1->setName("a");
  c2->setName("b");
  n1->addChild( c1);
  n1->addChild( c2);
  node->addChild(n1);

  int i;

  fail_unless( node->getType() == AST_SEMANTICS);
  
  ASTNode *child = node->getChild(0);

  fail_unless( child->getType() == AST_PLUS );
  fail_unless( child->getNumChildren() == 2); 
  fail_unless( !strcmp(child->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(child->getChild(1)->getName(), "b"));

  c1_1->setName("d");
  c2_1->setName("f");
  node_1->addChild(c1_1);
  node_1->addChild(c2_1);

  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "f"));

  i = node->swapChildren( node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 1); 
  fail_unless( node->getType() == AST_SEMANTICS);

  child = node->getChild(0);

  fail_unless( child->getNumChildren() == 2); 
  fail_unless( child->getType() == AST_PLUS);
  fail_unless( !strcmp(child->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(child->getChild(1)->getName(), "f"));
  
  fail_unless( node_1->getNumChildren() == 2); 
  fail_unless( !strcmp(node_1->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node_1->getChild(1)->getName(), "b"));

  delete node;
  delete node_1;
  delete n1;
}
END_TEST


START_TEST (test_ASTNode_addChild1)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  int i = 0;

  node->setType(AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  node->addChild(c1);
  node->addChild(c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  c1_1->setName("d");

  i = node->addChild(c1_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 3); 
//  fail_unless( !strcmp(SBML_formulaToString(), "and(a, b, d)"));
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "d"));

  delete node;
}
END_TEST


START_TEST (test_ASTNode_prependChild1)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();
  ASTNode *c1_1 = new ASTNode();
  int i = 0;

  node->setType(AST_LOGICAL_AND);
  c1->setName("a");
  c2->setName("b");
  node->addChild(c1);
  node->addChild(c2);

  fail_unless( node->getNumChildren() == 2); 
  fail_unless( !strcmp(node->getChild(0)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "b"));
//  fail_unless( !strcmp(SBML_formulaToString(), "and(a, b)"));

  c1_1->setName("d");

  i = node->prependChild(c1_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumChildren() == 3); 
//  fail_unless( !strcmp(SBML_formulaToString(), "and(d, a, b)"));
  fail_unless( !strcmp(node->getChild(0)->getName(), "d"));
  fail_unless( !strcmp(node->getChild(1)->getName(), "a"));
  fail_unless( !strcmp(node->getChild(2)->getName(), "b"));

  delete node;
}
END_TEST


START_TEST (test_ASTNode_freeName)
{
  ASTNode *node = new ASTNode();
  int i = 0;

  i = node->setName("a");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
//  fail_unless( !strcmp(SBML_formulaToString(node), "a"));
  fail_unless( !strcmp(node->getName(), "a") );

  i = node->freeName();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getName() == NULL );

  i = node->freeName();

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( node->getName() == NULL );

  node->setType(AST_UNKNOWN);

  i = node->freeName();

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( node->getName() == NULL );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_freeName1)
{
  ASTNode *node = new ASTNode(AST_FUNCTION);
  int i = 0;

  i = node->setName("a");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
//  fail_unless( !strcmp(SBML_formulaToString(node), "a"));
  fail_unless( !strcmp(node->getName(), "a") );

  i = node->freeName();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getName() == NULL );

  i = node->freeName();

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( node->getName() == NULL );

  node->setType(AST_UNKNOWN);

  i = node->freeName();

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( node->getName() == NULL );

  delete node;
}
END_TEST


START_TEST (test_ASTNode_addSemanticsAnnotation)
{
  XMLNode *ann = new XMLNode();
  ASTNode *node = new ASTNode(AST_SEMANTICS);
  int i = 0;

  fail_unless(node->isWellFormedASTNode() == true);
  
  i = node->addSemanticsAnnotation(ann);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( node->getNumSemanticsAnnotations() == 1);
  fail_unless(node->isWellFormedASTNode() == true);

  i = node->addSemanticsAnnotation(NULL);

  fail_unless(i == LIBSBML_OPERATION_FAILED);
  fail_unless( node->getNumSemanticsAnnotations() == 1);
  fail_unless(node->isWellFormedASTNode() == true);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_addSemanticsAnnotation1)
{
  XMLNode *ann = new XMLNode();
  ASTNode *node = new ASTNode();
  int i = 0;

  fail_unless(node->isWellFormedASTNode() == true);

  i = node->addSemanticsAnnotation(ann);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(node->getType() == AST_SEMANTICS);
  fail_unless( node->getNumSemanticsAnnotations() == 1);
  fail_unless(node->getNumChildren() == 1);
  fail_unless(node->isWellFormedASTNode() == true);

  i = node->addSemanticsAnnotation(NULL);

  fail_unless(i == LIBSBML_OPERATION_FAILED);
  fail_unless( node->getNumSemanticsAnnotations() == 1);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_addSemanticsAnnotation2)
{
  XMLNode *ann = new XMLNode();
  ASTNode *node = new ASTNode(AST_INTEGER);
  int i = 0;

  fail_unless(node->isWellFormedASTNode() == true);

  i = node->addSemanticsAnnotation(ann);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(node->getType() == AST_SEMANTICS);
  fail_unless( node->getNumSemanticsAnnotations() == 1);
  fail_unless(node->getNumChildren() == 1);
  fail_unless(node->isWellFormedASTNode() == true);

  i = node->addSemanticsAnnotation(NULL);

  fail_unless(i == LIBSBML_OPERATION_FAILED);
  fail_unless( node->getNumSemanticsAnnotations() == 1);

  delete node;
}
END_TEST


START_TEST (test_ASTNode_units)
{
  ASTNode *n = new ASTNode();


  n->setType(AST_REAL);
  n->setValue(1.6);
  
  int i = n->setUnits("mole");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetUnits() == 1);
  fail_unless(n->getUnits() == "mole");

  i = n->unsetUnits();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetUnits() == 0);
  fail_unless(n->getUnits() == "");

  i = n->setUnits("1mole");

  fail_unless(i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless(n->isSetUnits() == 0);

  n->setType(AST_FUNCTION);

  i = n->setUnits("mole");

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless(n->isSetUnits() == 0);
  fail_unless(n->getUnits() == "");


  delete n;
}
END_TEST

START_TEST (test_ASTNode_id)
{
  int i;
  ASTNode *n = new ASTNode();

  i = n->setId("test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetId() == 1);
  fail_unless(n->getId() == "test");

  i = n->unsetId();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetId() == 0);
  fail_unless(n->getId() == "");

  delete n;
}
END_TEST

START_TEST (test_ASTNode_class)
{
  int i;
  ASTNode *n = new ASTNode();

  i = n->setClass("test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetClass() == 1);
  fail_unless(n->getClass() == "test");

  i = n->unsetClass();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetClass() == 0);
  fail_unless(n->getClass() == "");

  delete n;
}
END_TEST

START_TEST (test_ASTNode_style)
{
  int i;
  ASTNode *n = new ASTNode();

  i = n->setStyle("test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetStyle() == 1);
  fail_unless(n->getStyle() == "test");

  i = n->unsetStyle();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->isSetStyle() == 0);
  fail_unless(n->getStyle() == "");

  delete n;
}
END_TEST

START_TEST (test_ASTNode_avogadro)
{
  ASTNode *n = new ASTNode(AST_NAME_AVOGADRO);
  n->setType(AST_NAME_AVOGADRO);
  n->setName("NA");

  fail_unless(!strcmp(n->getName(), "NA"));
  double val = n->getReal();
  fail_unless(util_isEqual(val, 6.02214179e23));
  fail_unless(n->isConstant() == true);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST

START_TEST (test_ASTNode_avogadro_1)
{
  ASTNode *n = new ASTNode();
  n->setType(AST_NAME_AVOGADRO);
  n->setName("NA");

  fail_unless(!strcmp(n->getName(), "NA"));
  double val = n->getReal();
  fail_unless(util_isEqual(val, 6.02214179e23));
  fail_unless(n->isConstant() == true);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST

START_TEST (test_ASTNode_avogadro_bug)
{
  ASTNode *n = new ASTNode();
  n->setName("NA");
  n->setType(AST_NAME_AVOGADRO);

  fail_unless(!strcmp(n->getName(), "NA"));
  double val = n->getReal();
  fail_unless(util_isEqual(val, 6.02214179e23));
  fail_unless(n->isConstant() == true);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

}
END_TEST


START_TEST (test_ASTNode_isBoolean)
{
  ASTNode *n = new ASTNode(AST_PLUS);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_MINUS);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_TIMES);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_DIVIDE);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_POWER);
  fail_unless(n->isBoolean() == false);

  delete n;
  n = new ASTNode(AST_INTEGER);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_REAL);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_REAL_E);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_RATIONAL);
  fail_unless(n->isBoolean() == false);

  delete n;
  n = new ASTNode(AST_NAME);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_NAME_AVOGADRO);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_NAME_TIME);
  fail_unless(n->isBoolean() == false);

  delete n;
  n = new ASTNode(AST_CONSTANT_E);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_CONSTANT_FALSE);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_CONSTANT_PI);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_CONSTANT_TRUE);
  fail_unless(n->isBoolean() == true);

  delete n;
  n = new ASTNode(AST_LAMBDA);
  fail_unless(n->isBoolean() == false);

  delete n;
  n = new ASTNode(AST_FUNCTION);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ABS);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOS);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOSH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOT);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOTH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCSC);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCSCH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSEC);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSECH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSIN);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSINH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCTAN);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCTANH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CEILING);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COS);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COSH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COT);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COTH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CSC);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CSCH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_DELAY);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_EXP);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_FACTORIAL);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_FLOOR);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_LN);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_LOG);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_PIECEWISE);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_POWER);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ROOT);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SEC);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SECH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SIN);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SINH);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_TAN);
  fail_unless(n->isBoolean() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_TANH);
  fail_unless(n->isBoolean() == false);

  delete n;
  n = new ASTNode(AST_LOGICAL_AND);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_LOGICAL_NOT);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_LOGICAL_OR);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_LOGICAL_XOR);
  fail_unless(n->isBoolean() == true);

  delete n;
  n = new ASTNode(AST_RELATIONAL_EQ);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_RELATIONAL_GEQ);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_RELATIONAL_GT);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_RELATIONAL_LEQ);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_RELATIONAL_LT);
  fail_unless(n->isBoolean() == true);
  delete n;
  n = new ASTNode(AST_RELATIONAL_NEQ);
  fail_unless(n->isBoolean() == true);
  delete n;

  n = new ASTNode(AST_UNKNOWN);
  fail_unless(n->isBoolean() == false);
  delete n;
}
END_TEST

START_TEST (test_ASTNode_returnsBoolean)
{
  ASTNode *node = new ASTNode();
  ASTNode *c1 = new ASTNode();
  ASTNode *c2 = new ASTNode();

  node->setType(AST_RELATIONAL_GEQ);
  c1->setName("a");
  c2->setName("b");
  node->addChild(c1);
  node->addChild(c2);

  // boolean function
//  n = SBML_parseFormula("geq(a,b)");
  fail_unless(node->returnsBoolean() == 1);

  delete node;
  // not boolean function
//  n = SBML_parseFormula("times(a,b)");
  node = new ASTNode(AST_TIMES);
  c1 = new ASTNode();
  c2 = new ASTNode();

  c1->setName("a");
  c2->setName("b");
  node->addChild(c1);
  node->addChild(c2);
  fail_unless(node->returnsBoolean() == 0);

  delete node;

  // piecewise with bool
//  n = SBML_parseFormula("piecewise(true, geq(X, T), false)");
  node = new ASTNode(AST_FUNCTION_PIECEWISE);
  c1 = new ASTNode(AST_CONSTANT_TRUE);
  ASTNode *c3 = new ASTNode(AST_CONSTANT_FALSE);

  c2 = new ASTNode(AST_RELATIONAL_GEQ);
  ASTNode *c1_2 = new ASTNode();
  ASTNode *c2_2 = new ASTNode();

  c1_2->setName("a");
  c2_2->setName("b");
  c2->addChild(c1_2);
  c2->addChild(c2_2);

  node->addChild(c1);
  node->addChild(c2);
  node->addChild(c3);

  fail_unless(node->returnsBoolean() == 1);

  delete node;
  // piecewise no boolean
//  n = SBML_parseFormula("piecewise(true, geq(X, T), 5)");
  node = new ASTNode(AST_FUNCTION_PIECEWISE);
  c1 = new ASTNode(AST_CONSTANT_TRUE);
  c3 = new ASTNode(AST_INTEGER);
  c3->setValue((long)(5));

  c2 = new ASTNode(AST_RELATIONAL_GEQ);
  c1_2 = new ASTNode();
  c2_2 = new ASTNode();

  c1_2->setName("a");
  c2_2->setName("b");
  c2->addChild(c1_2);
  c2->addChild(c2_2);

  node->addChild(c1);
  node->addChild(c2);
  node->addChild(c3);
  fail_unless(node->returnsBoolean() == 0);

  delete node;

  // func with no model
  ASTNode * n = SBML_parseFormula("func1(X)");

  // TO DO
  //// func with model that does not contain that func
  SBMLDocument_t *doc = SBMLDocument_createWithLevelAndVersion(3,1);
  Model_t* model = SBMLDocument_createModel(doc);
  Constraint_t *c = Model_createConstraint(model);
  Constraint_setMath(c, n);
  const ASTNode *math;

  math = Constraint_getMath(c);
  fail_unless(ASTNode_returnsBoolean(math) == 0);

  // func with model but func has no math
  FunctionDefinition_t* fd = Model_createFunctionDefinition(model);
  FunctionDefinition_setId(fd, "func1");
  fail_unless(ASTNode_returnsBoolean(math) == 0);

  // func with model func returns boolean
  ASTNode* m = SBML_parseFormula("lambda(x, true)");
  FunctionDefinition_setMath(fd, m);
  delete m;
  fail_unless(ASTNode_returnsBoolean(math) == 1);

  // func with model func returns number
  m = SBML_parseFormula("lambda(x, 6)");
  FunctionDefinition_setMath(fd, m);
  delete m;
  fail_unless(ASTNode_returnsBoolean(math) == 0);
  delete n;
  SBMLDocument_free(doc);
}
END_TEST

START_TEST (test_ASTNode_isAvogadro)
{
  ASTNode *n = new ASTNode(AST_PLUS);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_MINUS);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_TIMES);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_DIVIDE);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_POWER);
  fail_unless(n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_INTEGER);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_REAL);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_REAL_E);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RATIONAL);
  fail_unless(n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_NAME);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_NAME_AVOGADRO);
  fail_unless(n->isAvogadro() == true);
  delete n;
  n = new ASTNode(AST_NAME_TIME);
  fail_unless(n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_CONSTANT_E);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_CONSTANT_FALSE);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_CONSTANT_PI);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_CONSTANT_TRUE);
  fail_unless( n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_LAMBDA);
  fail_unless(n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_FUNCTION);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ABS);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOS);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOSH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOT);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCOTH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCSC);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCCSCH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSEC);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSECH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSIN);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCSINH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCTAN);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ARCTANH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CEILING);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COS);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COSH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COT);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_COTH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CSC);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_CSCH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_DELAY);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_EXP);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_FACTORIAL);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_FLOOR);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_LN);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_LOG);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_PIECEWISE);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_POWER);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_ROOT);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SEC);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SECH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SIN);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_SINH);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_TAN);
  fail_unless(n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_FUNCTION_TANH);
  fail_unless(n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_LOGICAL_AND);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_LOGICAL_NOT);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_LOGICAL_OR);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_LOGICAL_XOR);
  fail_unless( n->isAvogadro() == false);

  delete n;
  n = new ASTNode(AST_RELATIONAL_EQ);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RELATIONAL_GEQ);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RELATIONAL_GT);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RELATIONAL_LEQ);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RELATIONAL_LT);
  fail_unless( n->isAvogadro() == false);
  delete n;
  n = new ASTNode(AST_RELATIONAL_NEQ);
  fail_unless( n->isAvogadro() == false);
  delete n;

  n = new ASTNode(AST_UNKNOWN);
  fail_unless(n->isAvogadro() == false);
  delete n;
}
END_TEST

START_TEST (test_ASTNode_testConvenienceIs)
{
  ASTNode *n = new ASTNode();
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == true);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_NAME_AVOGADRO);
  fail_unless(n->isAvogadro() == true);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == true);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == true);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_CONSTANT_TRUE);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == true);
  fail_unless(n->isConstant() == true);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_RELATIONAL_LT);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == true);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == true);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_CONSTANT_E);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == true);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_FUNCTION_SIN);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == true);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_REAL);
  n->setValue(std::numeric_limits<double>::infinity());
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == true);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_INTEGER);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == true);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_LAMBDA);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == true);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_FUNCTION_LOG);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == true);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_LOGICAL_OR);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == true);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == true);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_NAME);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == true);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_NAME_TIME);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == true);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_REAL);
  n->setValue(std::numeric_limits<double>::quiet_NaN());
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == true);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_REAL);
  n->setValue(-std::numeric_limits<double>::infinity());
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == true);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_REAL);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_MINUS);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == true);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_FUNCTION_PIECEWISE);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == true);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == true);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_RATIONAL);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == true);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_REAL);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == true);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == true);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_RELATIONAL_EQ);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == true);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == true);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;
  
  /* sqrt */
  n = new ASTNode(AST_FUNCTION_ROOT);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == true);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == false);

  delete n;

  n = new ASTNode(AST_MINUS);
  ASTNode * c = new ASTNode(AST_INTEGER);
  n->addChild(c);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == true);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == true);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_UNKNOWN);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == true);
  fail_unless(n->isUPlus() == false);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;

  n = new ASTNode(AST_PLUS);
  c = new ASTNode(AST_INTEGER);
  n->addChild(c);
  fail_unless(n->isAvogadro() == false);
  fail_unless(n->isBoolean() == false);
  fail_unless(n->isConstant() == false);
  fail_unless(n->isFunction() == false);
  fail_unless(n->isInfinity() == false);
  fail_unless(n->isInteger() == false);
  fail_unless(n->isLambda() == false);
  fail_unless(n->isLog10() == false);
  fail_unless(n->isLogical() == false);
  fail_unless(n->isName() == false);
  fail_unless(n->isNaN() == false);
  fail_unless(n->isNegInfinity() == false);
  fail_unless(n->isNumber() == false);
  fail_unless(n->isOperator() == true);
  fail_unless(n->isQualifier() == false);
  fail_unless(n->isPiecewise() == false);
  fail_unless(n->isRational() == false);
  fail_unless(n->isReal() == false);
  fail_unless(n->isRelational() == false);
  fail_unless(n->isSqrt() == false);
  fail_unless(n->isUMinus() == false);
  fail_unless(n->isUnknown() == false);
  fail_unless(n->isUPlus() == true);
  fail_unless(n->isWellFormedASTNode() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_ParentSBMLObject)
{
  ASTNode *n = new ASTNode();

  fail_unless(n->getParentSBMLObject() == NULL);

  Species * s = new Species(3,1);
  int i = n->setParentSBMLObject((SBase*)(s));

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->getParentSBMLObject() != NULL);

  SBase * sb = n->getParentSBMLObject();

  fail_unless( sb == s);

  delete n;
  delete s;
}
END_TEST


START_TEST (test_ASTNode_ParentSBMLObject_1)
{
  ASTNode *n = new ASTNode();

  fail_unless(n->getParentSBMLObject() == NULL);
  fail_unless(n->isSetParentSBMLObject() == false);

  Species * s = new Species(3,1);
  int i = n->setParentSBMLObject((SBase*)(s));

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->getParentSBMLObject() != NULL);
  fail_unless(n->isSetParentSBMLObject() == true);

  SBase * sb = n->getParentSBMLObject();

  fail_unless( sb == s);

  i = n->unsetParentSBMLObject();

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(n->getParentSBMLObject() == NULL);
  fail_unless(n->isSetParentSBMLObject() == false);

  delete n;
  delete s;
}
END_TEST


START_TEST (test_ASTNode_hasTypeAndNumChildren)
{
  ASTNode *n = new ASTNode(AST_PLUS);
  ASTNode *c = new ASTNode(AST_NAME);

  fail_unless( n->hasTypeAndNumChildren(AST_PLUS, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_PLUS, 1));
  fail_unless(!n->hasTypeAndNumChildren(AST_MINUS, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_UNKNOWN, 1));

  c->setName("x");
  n->addChild(c);
  n->setType(AST_FUNCTION_PIECEWISE);
  fail_unless( n->hasTypeAndNumChildren(AST_FUNCTION_PIECEWISE, 1));
  fail_unless(!n->hasTypeAndNumChildren(AST_FUNCTION_PIECEWISE, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_PLUS, 1));
  fail_unless(!n->hasTypeAndNumChildren(AST_PLUS, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_LOGICAL_AND, 1));
  fail_unless(!n->hasTypeAndNumChildren(AST_DIVIDE, 0));

  c = new ASTNode();
  c->setName("y");
  n->addChild(c);
  n->setType(AST_DIVIDE);
  fail_unless( n->hasTypeAndNumChildren(AST_DIVIDE, 2));
  fail_unless(!n->hasTypeAndNumChildren(AST_DIVIDE, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_FUNCTION_PIECEWISE, 2));
  fail_unless(!n->hasTypeAndNumChildren(AST_FUNCTION_PIECEWISE, 0));
  fail_unless(!n->hasTypeAndNumChildren(AST_CONSTANT_E, 2));
  fail_unless(!n->hasTypeAndNumChildren(AST_RELATIONAL_EQ, 0));

  delete n;
}
END_TEST


START_TEST (test_ASTNode_hasUnits)
{
  ASTNode *n = new ASTNode();
  ASTNode *c = new ASTNode();

  n->setValue(1.0);
  fail_unless( n->hasUnits() == false);

  n->setUnits("litre");
  fail_unless( n->hasUnits() == true);

  delete n;
  n = new ASTNode(AST_PLUS);
  c->setValue(2.0);
  n->addChild(c);

  fail_unless( n->hasUnits() == false);

  c = new ASTNode();
  c->setValue(2.0);
  c->setUnits("mole");
  n->addChild(c);

  fail_unless( n->hasUnits() == true);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_renameSIdRefs)
{
  ASTNode *n = new ASTNode(AST_FUNCTION);
  n->setName("x");

  fail_unless(strcmp(n->getName(), "x") == 0);

  n->renameSIdRefs("x", "y");
  fail_unless(strcmp(n->getName(), "x") != 0);
  fail_unless(strcmp(n->getName(), "y") == 0);


  ASTNode *c = new ASTNode(AST_NAME);
  c->setName("t");
  n->addChild(c);

  fail_unless(strcmp(n->getChild(0)->getName(), "t") == 0);
  
  n->renameSIdRefs("t", "t1");
  
  fail_unless(strcmp(n->getChild(0)->getName(), "t1") == 0);

  delete n;
}
END_TEST


START_TEST (test_ASTNode_renameUnitSIdRefs)
{
  ASTNode *n = new ASTNode();
  ASTNode *c = new ASTNode();

  n->setValue(1.0);
  n->setUnits("litre");
  fail_unless (n->getUnits() == "litre");

  n->renameUnitSIdRefs("litre", "me");

  fail_unless (n->getUnits() == "me");

  delete n;
  n = new ASTNode(AST_PLUS);
  c->setValue(2.0);
  c->setUnits("a");
  n->addChild(c);

  fail_unless( n->hasUnits() == true);
  fail_unless (n->getChild(0)->getUnits() == "a");

  n->renameUnitSIdRefs("a", "me");

  fail_unless (n->getChild(0)->getUnits() == "me");

  delete n;
}
END_TEST


START_TEST (test_ASTNode_replaceIDWithFunction_2)
{
  ASTNode *n = new ASTNode(AST_POWER);
  ASTNode *n1 = new ASTNode(AST_NAME);
  n1->setName("x");
  ASTNode *n2 = new ASTNode();
  n2->setValue(2.0);
  n->addChild(n1);
  n->addChild(n2);

  ASTNode *replaced = new ASTNode(AST_PLUS);
  ASTNode *c = new ASTNode();
  c->setValue(1.0);
  replaced->addChild(c);

  ASTNode *child = n->getChild(0);

  fail_unless(strcmp(child->getName(), "x") == 0);
  fail_unless(child->getType() == AST_NAME);
  fail_unless(child->getNumChildren() == 0);

  n->replaceIDWithFunction("x", replaced);

  child = n->getChild(0);
  fail_unless(child->getName()== NULL);
  fail_unless(child->getType() == AST_PLUS);
  fail_unless(child->getNumChildren() == 1);

  delete n;
  delete replaced;
}
END_TEST


START_TEST (test_ASTNode_reduceToBinary)
{
  ASTNode *n = new ASTNode(AST_PLUS);
  ASTNode *n1 = new ASTNode();
  n1->setValue(1.0);
  ASTNode *n2 = new ASTNode();
  n2->setValue(2.0);
  ASTNode *n3 = new ASTNode();
  n3->setValue(3.0);

  n->addChild(n1);
  n->addChild(n2);
  n->addChild(n3);

  fail_unless( n->getNumChildren() == 3);
  fail_unless(n->isWellFormedASTNode() == true);

  n->reduceToBinary();

  fail_unless( n->getNumChildren() == 2);
  fail_unless(n->isWellFormedASTNode() == true);

  ASTNode * child = n->getChild(0);

  fail_unless(child->getNumChildren() == 2);

  child = n->getChild(1);
  
  fail_unless(child->getNumChildren() == 0);


  delete n;
}
END_TEST


START_TEST (test_ASTNode_userData_1)
{
  ASTNode *n = new ASTNode(AST_PLUS);

  Model * m = new Model(3,1);
  
  fail_unless(n->getUserData() == NULL);
  fail_unless(n->isSetUserData() == false);

  n->setUserData((void*)(m));

  fail_unless(n->getUserData() != NULL);
  fail_unless(n->getUserData() == m);
  fail_unless(n->isSetUserData() == true);
  
  n->setUserData(NULL);

  fail_unless(n->getUserData() == NULL);
  fail_unless(n->isSetUserData() == false);

  delete n;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_userData_2)
{
  ASTNode *n = new ASTNode(AST_INTEGER);

  Model * m = new Model(3,1);
  
  fail_unless(n->getUserData() == NULL);
  fail_unless(n->isSetUserData() == false);

  n->setUserData((void*)(m));

  fail_unless(n->getUserData() != NULL);
  fail_unless(n->getUserData() == m);
  fail_unless(n->isSetUserData() == true);
  
  n->unsetUserData();

  fail_unless(n->getUserData() == NULL);
  fail_unless(n->isSetUserData() == false);

  delete n;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_userData_3)
{
  ASTNode *n = new ASTNode(AST_NAME_TIME);

  Model * m = new Model(3,1);
  
  fail_unless(n->getUserData() == NULL);

  n->setUserData((void*)(m));

  fail_unless(n->getUserData() != NULL);
  fail_unless(n->getUserData() == m);
  
  n->setUserData(NULL);

  fail_unless(n->getUserData() == NULL);

  delete n;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_userData_4)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_DELAY);

  Model * m = new Model(3,1);
  
  fail_unless(n->getUserData() == NULL);

  n->setUserData((void*)(m));

  fail_unless(n->getUserData() != NULL);
  fail_unless(n->getUserData() == m);
  
  n->setUserData(NULL);

  fail_unless(n->getUserData() == NULL);

  delete n;
  delete m;
}
END_TEST


START_TEST (test_ASTNode_csymbol_1)
{
  ASTNode *n = new ASTNode(AST_FUNCTION_DELAY);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setName("c1");

  ASTNode *c2 = new ASTNode(AST_NAME);
  c2->setName("c2");

  ASTNode *c3 = new ASTNode(AST_NAME);
  c3->setName("c3");

  fail_unless( n->getNumChildren() == 0);

  int i = n->addChild(c1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 1);
  fail_unless( strcmp(n->getChild(0)->getName(), "c1") == 0);

  i = n->insertChild(0, c2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 2);
  fail_unless( strcmp(n->getChild(0)->getName(), "c2") == 0);

  i = n->removeChild(1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 1);
  fail_unless( strcmp(n->getChild(0)->getName(), "c2") == 0);

  i = n->prependChild(c3);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 2);
  fail_unless( strcmp(n->getChild(0)->getName(), "c3") == 0);

  i = n->replaceChild(0, c1, true);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 2);
  fail_unless( strcmp(n->getChild(0)->getName(), "c1") == 0);

  ASTNode *cc1 = new ASTNode(AST_PLUS);

  ASTNode *cc2 = new ASTNode(AST_NAME);
  cc2->setName("cc2");

  ASTNode *cc3 = new ASTNode(AST_NAME);
  cc3->setName("cc3");
  cc1->addChild(cc2);
  cc1->addChild(cc3);

  i = n->swapChildren(cc1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( n->getNumChildren() == 2);
  fail_unless( strcmp(n->getChild(0)->getName(), "cc2") == 0);
  
  delete n;
  delete cc1;
}
END_TEST


START_TEST (test_ASTNode_csymbol_2)
{
  ASTNode *n = new ASTNode(AST_NAME_TIME);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setName("c1");

  fail_unless( n->getNumChildren() == 0);

  int i = n->addChild(c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->insertChild(0, c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->removeChild(1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->prependChild(c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->replaceChild(0, c1, true);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  ASTNode *cc1 = new ASTNode(AST_PLUS);

  ASTNode *cc2 = new ASTNode(AST_NAME);
  cc2->setName("cc2");

  ASTNode *cc3 = new ASTNode(AST_NAME);
  cc3->setName("cc3");
  cc1->addChild(cc2);
  cc1->addChild(cc3);

  i = n->swapChildren(cc1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  delete n;
  delete c1;
  delete cc1;
}
END_TEST


START_TEST (test_ASTNode_csymbol_3)
{
  ASTNode *n = new ASTNode(AST_NAME_AVOGADRO);

  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setName("c1");

  fail_unless( n->getNumChildren() == 0);

  int i = n->addChild(c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->insertChild(0, c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->removeChild(1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->prependChild(c1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  i = n->replaceChild(0, c1, true);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  ASTNode *cc1 = new ASTNode(AST_PLUS);

  ASTNode *cc2 = new ASTNode(AST_NAME);
  cc2->setName("cc2");

  ASTNode *cc3 = new ASTNode(AST_NAME);
  cc3->setName("cc3");
  cc1->addChild(cc2);
  cc1->addChild(cc3);

  i = n->swapChildren(cc1);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( n->getNumChildren() == 0);

  delete n;
  delete c1;
  delete cc1;
}
END_TEST


START_TEST (test_ASTNode_csymbol_4)
{
  ASTNode *n = new ASTNode(AST_NAME_AVOGADRO);

  int i = n->setValue(6e23);

  /* set value will change the type
   * probably not what we want ultimately but for now
   */

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( util_isEqual(n->getReal(), 6e23));
  fail_unless( n->getType() == AST_REAL);

  delete n;
  n = new ASTNode(AST_NAME_TIME);

  i = n->setValue(6e23);

  /* set value will change the type
   * probably not what we want ultimately but for now
   */

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( util_isEqual(n->getReal(), 6e23));
  fail_unless( n->getType() == AST_REAL);  
  
  delete n;
}
END_TEST

START_TEST (test_ASTNode_replace)
{
  ASTNode* node = readMathMLFromString(
    "<math xmlns='http://www.w3.org/1998/Math/MathML'>\n"
    "  <csymbol encoding='text' definitionURL='http://www.sbml.org/sbml/symbols/time'> time </csymbol>\n"
    "</math>"
    );

  fail_unless(node != NULL);
  
  ASTNode*function = SBML_parseFormula("X");
  ASTNode*function1 = SBML_parseFormula("Y");

  ASTNode* temp = node;
  node = new ASTNode(AST_DIVIDE);
  node->addChild(temp);
  node->addChild(function->deepCopy());

  char* formula = SBML_formulaToString(node);
  fail_unless(strcmp(formula, "time / X")==0);
  safe_free(formula);

  node->replaceIDWithFunction("X", function1);
  formula = SBML_formulaToString(node);
  fail_unless(strcmp(formula, "time / Y")==0);
  safe_free(formula);

  ASTNode* ast1 = new ASTNode(AST_TIMES);
  ast1->addChild(function->deepCopy());
  ast1->addChild(node->deepCopy());
  
  formula = SBML_formulaToString(ast1);
  fail_unless(strcmp(formula, "X * (time / Y)")==0);
  safe_free(formula);

  ASTNode* divTemplate = new ASTNode(AST_DIVIDE);
  ASTNode* function3 = function1->deepCopy();
  divTemplate->addChild(function3);

  divTemplate->insertChild(0, function->deepCopy());
  formula = SBML_formulaToString(divTemplate);
  fail_unless(strcmp(formula, "X / Y")==0);
  safe_free(formula);

  fail_unless(divTemplate->removeChild(1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(divTemplate->insertChild(1, function1->deepCopy()) == LIBSBML_OPERATION_SUCCESS);
  formula = SBML_formulaToString(divTemplate);
  fail_unless(strcmp(formula, "X / Y")==0);
  safe_free(formula);

  delete node;
  delete ast1;
  delete function;
  delete function1;
  delete function3;
  delete divTemplate;
}
END_TEST


START_TEST (test_ASTNode_representsBvar)
{
  const char* original = wrapMathML
  (
    "<lambda>"
    "  <bvar> <ci>x</ci> </bvar>"
    "  <ci>y</ci>"
    "</lambda>"
  );

  ASTNode* N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  delete N;
}
END_TEST






Suite *
create_suite_NewASTNode (void) 
{ 
  Suite *suite = suite_create("NewASTNode");
  TCase *tcase = tcase_create("NewASTNode");


  tcase_add_test( tcase, test_ASTNode_replace                  );
  tcase_add_test( tcase, test_ASTNode_create                  );
  tcase_add_test( tcase, test_ASTNode_getInteger                 );
  tcase_add_test( tcase, test_ASTNode_getReal                 );
  tcase_add_test( tcase, test_ASTNode_getRational                 );
  tcase_add_test( tcase, test_ASTNode_getRealE                 );
  tcase_add_test( tcase, test_ASTNode_free_NULL               );

  tcase_add_test( tcase, test_ASTNode_createFromToken         );
  tcase_add_test( tcase, test_ASTNode_canonicalizeConstants   );
  tcase_add_test( tcase, test_ASTNode_canonicalizeFunctions   );
  tcase_add_test( tcase, test_ASTNode_canonicalizeFunctionsL1 );
  tcase_add_test( tcase, test_ASTNode_canonicalizeLogical     );
  tcase_add_test( tcase, test_ASTNode_canonicalizeRelational  );

  tcase_add_test( tcase, test_ASTNode_deepCopy_1              );
  tcase_add_test( tcase, test_ASTNode_deepCopy_2              );
  tcase_add_test( tcase, test_ASTNode_deepCopy_3              );
  tcase_add_test( tcase, test_ASTNode_deepCopy_4              );
  tcase_add_test( tcase, test_ASTNode_deepCopy_5              );

  tcase_add_test( tcase, test_ASTNode_getName                 );
  tcase_add_test( tcase, test_ASTNode_getPrecedence           );

  tcase_add_test( tcase, test_ASTNode_isLog10                 );
  tcase_add_test( tcase, test_ASTNode_isLog10_1                 );
  tcase_add_test( tcase, test_ASTNode_isSqrt                  );
  tcase_add_test( tcase, test_ASTNode_isSqrt1                  );
  tcase_add_test( tcase, test_ASTNode_isUMinus                );
  tcase_add_test( tcase, test_ASTNode_isUPlus                 );

  tcase_add_test( tcase, test_ASTNode_setCharacter            );

  tcase_add_test( tcase, test_ASTNode_setName_1                 );
  tcase_add_test( tcase, test_ASTNode_setName_2                 );
  tcase_add_test( tcase, test_ASTNode_setName_3                 );
  tcase_add_test( tcase, test_ASTNode_setName_4                 );
  tcase_add_test( tcase, test_ASTNode_setName_5                 );
  tcase_add_test( tcase, test_ASTNode_setName_override        );

  tcase_add_test( tcase, test_ASTNode_setInteger              );
  tcase_add_test( tcase, test_ASTNode_setReal                 );
  tcase_add_test( tcase, test_ASTNode_setValue                 );

  tcase_add_test( tcase, test_ASTNode_setType_1                 );
  tcase_add_test( tcase, test_ASTNode_setType_2                 );
  tcase_add_test( tcase, test_ASTNode_setType_3                 );
  tcase_add_test( tcase, test_ASTNode_setType_4                 );
  tcase_add_test( tcase, test_ASTNode_setType_5                 );
  tcase_add_test( tcase, test_ASTNode_setType_6                 );
  tcase_add_test( tcase, test_ASTNode_setType_7                 );
  tcase_add_test( tcase, test_ASTNode_setType_8                 );
  tcase_add_test( tcase, test_ASTNode_setType_9                 );
  tcase_add_test( tcase, test_ASTNode_setType_10                );
  tcase_add_test( tcase, test_ASTNode_setType_11                );
  tcase_add_test( tcase, test_ASTNode_setType_12                );
  tcase_add_test( tcase, test_ASTNode_setType_13                );
  tcase_add_test( tcase, test_ASTNode_setType_14                );
  tcase_add_test( tcase, test_ASTNode_setType_15                );
  tcase_add_test( tcase, test_ASTNode_setType_16                );
  tcase_add_test( tcase, test_ASTNode_setType_17                );
  tcase_add_test( tcase, test_ASTNode_setType_18                );
  tcase_add_test( tcase, test_ASTNode_setType_19                );
  tcase_add_test( tcase, test_ASTNode_setType_20                );
  tcase_add_test( tcase, test_ASTNode_setType_21                );
  tcase_add_test( tcase, test_ASTNode_setType_22                );
  tcase_add_test( tcase, test_ASTNode_setType_23                );
  tcase_add_test( tcase, test_ASTNode_setType_24                );
  tcase_add_test( tcase, test_ASTNode_setType_25                );
  tcase_add_test( tcase, test_ASTNode_setType_26                );
  tcase_add_test( tcase, test_ASTNode_setType_27                );
  tcase_add_test( tcase, test_ASTNode_setType_28                );
  tcase_add_test( tcase, test_ASTNode_setType_29                );
  tcase_add_test( tcase, test_ASTNode_setType_30                );
  tcase_add_test( tcase, test_ASTNode_setType_31                );
  tcase_add_test( tcase, test_ASTNode_setType_32                );
  tcase_add_test( tcase, test_ASTNode_setType_33                );
  tcase_add_test( tcase, test_ASTNode_setType_34                );
  tcase_add_test( tcase, test_ASTNode_setType_35                );

  tcase_add_test( tcase, test_ASTNode_setNewTypes_1             );
  tcase_add_test( tcase, test_ASTNode_setNewTypes_2             );
  tcase_add_test( tcase, test_ASTNode_setNewTypes_3             );
  tcase_add_test( tcase, test_ASTNode_setNewTypes_4             );
  tcase_add_test( tcase, test_ASTNode_setNewTypes_5             );
  tcase_add_test( tcase, test_ASTNode_setNewTypes_6             );
  
  tcase_add_test( tcase, test_ASTNode_no_children             );
  tcase_add_test( tcase, test_ASTNode_one_child               );
  tcase_add_test( tcase, test_ASTNode_children                );
  tcase_add_test( tcase, test_ASTNode_children1               );
  tcase_add_test( tcase, test_ASTNode_nested_children                );
  tcase_add_test( tcase, test_ASTNode_nested_children1                );

  tcase_add_test( tcase, test_ASTNode_getListOfNodes1          );
  tcase_add_test( tcase, test_ASTNode_replaceArgument         );
  tcase_add_test( tcase, test_ASTNode_removeChild             );
  tcase_add_test( tcase, test_ASTNode_replaceChild            );
  tcase_add_test( tcase, test_ASTNode_insertChild             );
  tcase_add_test( tcase, test_ASTNode_swapChildren            );
  tcase_add_test( tcase, test_ASTNode_swapChildren1            );
  tcase_add_test( tcase, test_ASTNode_swapChildren2            );
  tcase_add_test( tcase, test_ASTNode_swapChildren3            );
  tcase_add_test( tcase, test_ASTNode_swapChildren4            );
  tcase_add_test( tcase, test_ASTNode_swapChildren5            );
  tcase_add_test( tcase, test_ASTNode_addChild1               );
  tcase_add_test( tcase, test_ASTNode_prependChild1           );
  tcase_add_test( tcase, test_ASTNode_freeName                );
  tcase_add_test( tcase, test_ASTNode_freeName1                );
  tcase_add_test( tcase, test_ASTNode_addSemanticsAnnotation  );
  tcase_add_test( tcase, test_ASTNode_addSemanticsAnnotation1 );
  tcase_add_test( tcase, test_ASTNode_addSemanticsAnnotation2 );
  tcase_add_test( tcase, test_ASTNode_units                   );
  tcase_add_test( tcase, test_ASTNode_id                      );
  tcase_add_test( tcase, test_ASTNode_class                   );
  tcase_add_test( tcase, test_ASTNode_style                   );
  tcase_add_test( tcase, test_ASTNode_avogadro                );
  tcase_add_test( tcase, test_ASTNode_avogadro_1              );
  tcase_add_test( tcase, test_ASTNode_avogadro_bug            );

  tcase_add_test( tcase, test_ASTNode_isBoolean               );
  tcase_add_test( tcase, test_ASTNode_returnsBoolean          );
  tcase_add_test( tcase, test_ASTNode_isAvogadro              );

  tcase_add_test( tcase, test_ASTNode_testConvenienceIs              );
  
  tcase_add_test( tcase, test_ASTNode_ParentSBMLObject         );
  tcase_add_test( tcase, test_ASTNode_ParentSBMLObject_1         );
  
  tcase_add_test( tcase, test_ASTNode_hasTypeAndNumChildren         );
  tcase_add_test( tcase, test_ASTNode_hasUnits         );
  tcase_add_test( tcase, test_ASTNode_renameSIdRefs         );
  tcase_add_test( tcase, test_ASTNode_renameUnitSIdRefs         );
  tcase_add_test( tcase, test_ASTNode_replaceIDWithFunction_2        );
  tcase_add_test( tcase, test_ASTNode_reduceToBinary   );
  tcase_add_test( tcase, test_ASTNode_userData_1   );
  tcase_add_test( tcase, test_ASTNode_userData_2   );
  tcase_add_test( tcase, test_ASTNode_userData_3   );
  tcase_add_test( tcase, test_ASTNode_userData_4   );

  tcase_add_test( tcase, test_ASTNode_csymbol_1   );
  tcase_add_test( tcase, test_ASTNode_csymbol_2   );
  tcase_add_test( tcase, test_ASTNode_csymbol_3   );
  tcase_add_test( tcase, test_ASTNode_csymbol_4   );
  
  tcase_add_test( tcase, test_ASTNode_representsBvar   );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif


