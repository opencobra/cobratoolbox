/**
 * \file    TestNewWriteMathMLFromASTFromAST.cpp
 * \brief   Write MathML unit tests starting from ASTNodes
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

#include <limits>
#include <iostream>
#include <cstring>
#include <cstdio>

#include <check.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>

/** @cond doxygenLibsbmlInternal */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


/**
 * Wraps the string s in the appropriate XML boilerplate.
 */
#define XML_HEADER    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define MATHML_HEADER "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
#define MATHML_HEADER_UNITS  "<math xmlns=\"http://www.w3.org/1998/Math/MathML\""
#define MATHML_HEADER_UNITS2  " xmlns:sbml=\"http://www.sbml.org/sbml/level3/version1/core\">\n"
#define MATHML_FOOTER "</math>"

#define wrapMathML(s)   XML_HEADER MATHML_HEADER s MATHML_FOOTER
#define wrapMathMLUnits(s)  XML_HEADER MATHML_HEADER_UNITS MATHML_HEADER_UNITS2 s MATHML_FOOTER


static ASTNode* N;
static char*    S;


void
NewWriteMathMLFromAST_setup ()
{
  N = NULL;
  S = NULL;
}


void
NewWriteMathMLFromAST_teardown ()
{
  delete N;
  free(S);
}


static bool
equals (const char* expected, const char* actual)
{
  if ( !strcmp(expected, actual) ) return true;

  printf( "\nStrings are not equal:\n"  );
  printf( "Expected:\n[%s]\n", expected );
  printf( "Actual:\n[%s]\n"  , actual   );

  return false;
}


CK_CPPSTART


START_TEST (test_MathMLFromAST_cn_real_1)
{
  const char *expected = wrapMathML("  <cn> 1.2 </cn>\n");

  // N = SBML_parseFormula("1.2");
  N = new ASTNode(AST_REAL);
  N->setValue(1.2);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_real_2)
{
  const char* expected = wrapMathML("  <cn> 1234567.8 </cn>\n");

  // N = SBML_parseFormula("1234567.8");
  N = new ASTNode(AST_REAL);
  N->setValue(1234567.8);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_real_3)
{
  const char* expected = wrapMathML("  <cn> -3.14 </cn>\n");

  // N = SBML_parseFormula("-3.14");
  N = new ASTNode(AST_REAL);
  N->setValue(-3.14);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_real_locale)
{
  const char* expected = wrapMathML("  <cn> 2.72 </cn>\n");


  setlocale(LC_NUMERIC, "de_DE");

  // N = SBML_parseFormula("2.72");
  N = new ASTNode(AST_REAL);
  N->setValue(2.72);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

  setlocale(LC_NUMERIC, "C");
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_1)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 0 <sep/> 3 </cn>\n"
  );

  // N = SBML_parseFormula("0e3");
  N = new ASTNode(AST_REAL_E);
  N->setValue(0.0, 3);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_2)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 2000 <sep/> 0 </cn>\n"
  );

  // N = SBML_parseFormula("2e3");
  N = new ASTNode(AST_REAL_E);
  N->setValue(2e3);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_3)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 1234567.8 <sep/> 3 </cn>\n"
  );

  // N = SBML_parseFormula("1234567.8e3");
  N = new ASTNode(AST_REAL_E);
  N->setValue(1234567.8, 3);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_4)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 6.0221367 <sep/> 23 </cn>\n"
  );

  // N = SBML_parseFormula("6.0221367e+23");
  N = new ASTNode(AST_REAL_E);
  N->setValue(6.0221367, 23);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_5)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 4 <sep/> -6 </cn>\n"
  );

  // N = SBML_parseFormula(".000004");
  N = new ASTNode(AST_REAL_E);
  N->setValue(0.000004);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_6)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 4 <sep/> -12 </cn>\n"
  );

  // N = SBML_parseFormula(".000004e-6");
  N = new ASTNode(AST_REAL_E);
  N->setValue(0.000004, -6);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_e_notation_7)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> -1 <sep/> -6 </cn>\n"
  );

  // N = SBML_parseFormula("-1e-6");
  N = new ASTNode(AST_REAL_E);
  N->setValue(-1.0, -6);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_integer)
{
  const char* expected = wrapMathML("  <cn type=\"integer\"> 5 </cn>\n");

  N = new ASTNode(AST_INTEGER);
  N->setValue((long)(5));

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_rational)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"rational\"> 1 <sep/> 3 </cn>\n"
  );

  N = new ASTNode(AST_RATIONAL);
  N->setValue(long(1), 3);
  //N->setValue(static_cast<long>(1), 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_ci)
{
  const char* expected = wrapMathML("  <ci> foo </ci>\n");

  N = new ASTNode(AST_NAME);
  N->setName("foo");

  // N = SBML_parseFormula("foo");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_csymbol_delay)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <csymbol encoding=\"text\" definitionURL=\"http://www.sbml.org/sbml/"
    "symbols/delay\"> my_delay </csymbol>\n"
    "    <ci> x </ci>\n"
    "    <cn> 0.1 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_DELAY);
  fail_unless(N->setName("my_delay") == LIBSBML_OPERATION_SUCCESS);

  ASTNode * c1 = new ASTNode(AST_NAME);
  fail_unless(c1->setName("x") == LIBSBML_OPERATION_SUCCESS);

  ASTNode *c2 = new ASTNode(AST_REAL);
  fail_unless(c2->setValue(0.1) == LIBSBML_OPERATION_SUCCESS);

  fail_unless(N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  // N = SBML_parseFormula("delay(x, 0.1)");
  // N->setName("my_delay");

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_csymbol_time)
{
  const char* expected = wrapMathML
  (
    "  <csymbol encoding=\"text\" "
    "definitionURL=\"http://www.sbml.org/sbml/symbols/time\"> t </csymbol>\n"
  );

  N = new ASTNode(AST_NAME_TIME);
  N->setName("t");

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_true)
{
  const char* expected = wrapMathML("  <true/>\n");

  N = new ASTNode(AST_CONSTANT_TRUE);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_false)
{
  const char* expected = wrapMathML("  <false/>\n");

  N = new ASTNode(AST_CONSTANT_FALSE);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_notanumber)
{
  const char* expected = wrapMathML("  <notanumber/>\n");

  N = new ASTNode(AST_REAL);
  N->setValue( numeric_limits<double>::quiet_NaN() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_infinity)
{
  const char* expected = wrapMathML("  <infinity/>\n");

  N = new ASTNode;
  N->setValue( numeric_limits<double>::infinity() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_infinity_neg)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <infinity/>\n"
    "  </apply>\n"
  );

  N = new ASTNode;
  N->setValue( - numeric_limits<double>::infinity() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_infinity_neg1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <infinity/>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_REAL);
  N->setValue( - numeric_limits<double>::infinity() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_exponentiale)
{
  const char* expected = wrapMathML("  <exponentiale/>\n");

  N = new ASTNode(AST_CONSTANT_E);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_constant_pi)
{
  const char* expected = wrapMathML("  <pi/>\n");

  N = new ASTNode(AST_CONSTANT_PI);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_plus_binary)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "  </apply>\n"
  );

//  // N = SBML_parseFormula("1 + 2");

  N = new ASTNode(AST_PLUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  
  N->addChild(c1);
  N->addChild(c2);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}

END_TEST


START_TEST (test_MathMLFromAST_plus_nary_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <cn type=\"integer\"> 3 </cn>\n"
    "  </apply>\n"
  );
 
  //// N = SBML_parseFormula("1 + 2 + 3");

  N = new ASTNode(AST_PLUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(long(3));
  
  N->addChild(c1);
  N->addChild(c2);
  N->addChild(c3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_plus_nary_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <cn type=\"integer\"> 3 </cn>\n"
    "  </apply>\n"
  );
  
  //// N = SBML_parseFormula("(1 + 2) + 3");

  N = new ASTNode(AST_PLUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(long(3));
  
  ASTNode *plus = new ASTNode(AST_PLUS);
  plus->addChild(c1);
  plus->addChild(c2);
  
  N->addChild(plus);
  N->addChild(c3);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_plus_nary_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <cn type=\"integer\"> 3 </cn>\n"
    "  </apply>\n"
  );

//  // N = SBML_parseFormula("1 + (2 + 3)");
  
  N = new ASTNode(AST_PLUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(long(3));
  
  ASTNode *plus = new ASTNode(AST_PLUS);
  plus->addChild(c2);
  plus->addChild(c3);
  
  N->addChild(c1);
  N->addChild(plus);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_plus_nary_4)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <apply>\n"
    "      <times/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "      <ci> z </ci>\n"
    "    </apply>\n"
    "    <cn type=\"integer\"> 3 </cn>\n"
    "  </apply>\n"
  );

//  // N = SBML_parseFormula("1 + 2 + x * y * z + 3");
  
  N = new ASTNode(AST_PLUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(long(3));
  ASTNode *cx = new ASTNode(AST_NAME);
  cx->setName("x");
  ASTNode *cy = new ASTNode(AST_NAME);
  cy->setName("y");
  ASTNode *cz = new ASTNode(AST_NAME);
  cz->setName("z");
  
  ASTNode *times = new ASTNode(AST_TIMES);
  times->addChild(cx);
  times->addChild(cy);
  times->addChild(cz);
  
  N->addChild(c1);
  N->addChild(c2);
  N->addChild(times);
  N->addChild(c3);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_minus)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_MINUS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  
  N->addChild(c1);
  N->addChild(c2);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_minus_unary_1)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"integer\"> -2 </cn>\n"
  );

  // N = SBML_parseFormula("-2");
  N = new ASTNode(AST_INTEGER);
  N->setValue(-2);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_minus_unary_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <ci> a </ci>\n"
    "  </apply>\n"
  );

  // N = SBML_parseFormula("-a");
  N = new ASTNode(AST_MINUS);
  
  ASTNode *c1 = new ASTNode(AST_NAME);
  c1->setName("a");
  
  N->addChild(c1);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_function_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <ci> foo </ci>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <cn type=\"integer\"> 3 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION);
  fail_unless( N->setName("foo") == LIBSBML_OPERATION_SUCCESS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));
  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(long(3));

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c3) == LIBSBML_OPERATION_SUCCESS);
  // N = SBML_parseFormula("foo(1, 2, 3)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_function_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <ci> foo </ci>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "    <apply>\n"
    "      <ci> bar </ci>\n"
    "      <ci> z </ci>\n"
    "    </apply>\n"
    "  </apply>\n"
  );

  // N = SBML_parseFormula("foo(1, 2, bar(z))");
  N = new ASTNode(AST_FUNCTION);
  fail_unless( N->setName("foo") == LIBSBML_OPERATION_SUCCESS);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_INTEGER);
  c2->setValue(long(2));

  ASTNode *bar = new ASTNode(AST_FUNCTION);
  bar->setName("bar");

  ASTNode *cz = new ASTNode(AST_NAME);
  cz->setName("z");

  fail_unless (bar->addChild(cz) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(bar) == LIBSBML_OPERATION_SUCCESS);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_sin)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <sin/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_SIN);
  ASTNode* c = new ASTNode(AST_INTEGER);
  c->setValue(long(1));

  fail_unless(N->addChild(c) == LIBSBML_OPERATION_SUCCESS);

  // N = SBML_parseFormula("sin(x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_log)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </logbase>\n"
    "    <ci> N </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_LOGBASE);
  
  ASTNode* c1_1 = new ASTNode(AST_INTEGER);
  fail_unless( c1_1->setValue(2) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_1) == LIBSBML_OPERATION_SUCCESS);

  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  // valid ast
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

#if(0)
START_TEST (test_MathMLFromAST_log_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <ci> N </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  /* HACK TO REPLICATE OLD AST */
  // log with only one arg
  // if read this would add the logbase but 
  // when constructed it does not

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST
#endif

START_TEST (test_MathMLFromAST_log_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <ci> x </ci>\n"
    "    </logbase>\n"
    "    <ci> N </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode* c1 = new ASTNode(AST_NAME);
  fail_unless( c1->setName("x") == LIBSBML_OPERATION_SUCCESS);
  
  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  // log with two args - create logbase from first
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_log_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 10 </cn>\n"
    "    </logbase>\n"
    "    <ci> N </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_LOGBASE);
  

  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  // logbase with no args
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_log_4)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 10 </cn>\n"
    "    </logbase>\n"
    "    <ci> N </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_LOGBASE);
  
  ASTNode* c1_1 = new ASTNode(AST_INTEGER);
  fail_unless( c1_1->setValue(10) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_1) == LIBSBML_OPERATION_SUCCESS);

  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("N") == LIBSBML_OPERATION_SUCCESS);

  ASTNode* c3 = new ASTNode(AST_NAME);
  fail_unless( c3->setName("x") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c3) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);

  // log with logbase and more than 1 child
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_root)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  // N = SBML_parseFormula("root(3, x)");
  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_DEGREE);
  
  ASTNode* c1_1 = new ASTNode(AST_INTEGER);
  fail_unless( c1_1->setValue(3) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_1) == LIBSBML_OPERATION_SUCCESS);

  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("x") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  
  // nicely formed ast
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_root1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <ci> y </ci>\n"
    "    </degree>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* expected1 = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <ci> y </ci>\n"
    "    </degree>\n"
    "    <ci> x1 </ci>\n"
    "  </apply>\n"
  );
  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode* c1 = new ASTNode(AST_NAME);
  fail_unless( c1->setName("y") == LIBSBML_OPERATION_SUCCESS);
  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("x") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  
  // ast with two children but none declared as degree
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

  ASTNode* c3 = new ASTNode(AST_NAME);
  fail_unless( c3->setName("x1") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c3) == LIBSBML_OPERATION_SUCCESS);

  // ast with three children but none declared as degree
  safe_free(S);
  S = writeMathMLToString(N);

  fail_unless( equals(expected1, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_root2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </degree>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_DEGREE);
  
  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("x") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  
  // ast with empty degree child
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_root3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "    <ci> y </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode* c1 = new ASTNode(AST_QUALIFIER_DEGREE);
  
  ASTNode* c1_1 = new ASTNode(AST_INTEGER);
  fail_unless( c1_1->setValue(3) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_1) == LIBSBML_OPERATION_SUCCESS);

  ASTNode* c3 = new ASTNode(AST_NAME);
  fail_unless( c3->setName("y") == LIBSBML_OPERATION_SUCCESS);
  ASTNode* c2 = new ASTNode(AST_NAME);
  fail_unless( c2->setName("x") == LIBSBML_OPERATION_SUCCESS);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c2) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c3) == LIBSBML_OPERATION_SUCCESS);
  
  // ast with degree and two other children
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

  ASTNode* c1_2 = new ASTNode(AST_INTEGER);
  fail_unless( c1_2->setValue(4) == LIBSBML_OPERATION_SUCCESS);

  fail_unless (c1->addChild(c1_2) == LIBSBML_OPERATION_SUCCESS);

  c1 = c1->deepCopy();
  c3 = c3->deepCopy();
  delete N;
  N = new ASTNode(AST_FUNCTION_ROOT);

  fail_unless (N->addChild(c1) == LIBSBML_OPERATION_SUCCESS);
  fail_unless (N->addChild(c3) == LIBSBML_OPERATION_SUCCESS);
  
  // ast with degree that has two children
  safe_free(S);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_lambda)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  N = new ASTNode(AST_LAMBDA);

  ASTNode *c1 = new ASTNode(AST_QUALIFIER_BVAR);
  ASTNode *c1_1 = new ASTNode(AST_NAME);
  c1_1->setName("x");
  c1->addChild(c1_1);

  ASTNode *c2 = new ASTNode(AST_QUALIFIER_BVAR);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("y");
  c2->addChild(c2_1);

  ASTNode *c3 = new ASTNode(AST_PLUS);
  ASTNode *c3_1 = new ASTNode(AST_NAME);
  c3_1->setName("x");
  ASTNode *c3_2 = new ASTNode(AST_NAME);
  c3_2->setName("y");
  c3->addChild(c3_1);
  c3->addChild(c3_2);
  
  N->addChild(c1);
  N->addChild(c2);
  N->addChild(c3);




  // N = SBML_parseFormula("lambda(x, y, root(2, x^2 + y^2))");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_lambda1)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  N = new ASTNode(AST_LAMBDA);

  ASTNode *c1_1 = new ASTNode(AST_NAME);
  c1_1->setName("x");

  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("y");

  ASTNode *c3 = new ASTNode(AST_PLUS);
  ASTNode *c3_1 = new ASTNode(AST_NAME);
  c3_1->setName("x");
  ASTNode *c3_2 = new ASTNode(AST_NAME);
  c3_2->setName("y");
  c3->addChild(c3_1);
  c3->addChild(c3_2);
  
  N->addChild(c1_1);
  N->addChild(c2_1);
  N->addChild(c3);




  // N = SBML_parseFormula("lambda(x, y, root(2, x^2 + y^2))");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_lambda_no_bvars)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  N = new ASTNode(AST_LAMBDA);

  ASTNode *c3 = new ASTNode(AST_PLUS);
  ASTNode *c3_1 = new ASTNode(AST_INTEGER);
  c3_1->setValue(2);
  ASTNode *c3_2 = new ASTNode(AST_INTEGER);
  c3_2->setValue(2);
  c3->addChild(c3_1);
  c3->addChild(c3_2);
  
  N->addChild(c3);
  // N = SBML_parseFormula("lambda(2 + 2)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n" 
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(0);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);
  
  ASTNode *p1 = new ASTNode(AST_CONSTRUCTOR_PIECE);
  p1->addChild(c1);
  p1->addChild(c2);

  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(0);

  ASTNode *c4 = new ASTNode(AST_RELATIONAL_EQ);
  ASTNode *c4_1 = new ASTNode(AST_NAME);
  c4_1->setName("x");
  ASTNode *c4_4 = new ASTNode(AST_INTEGER);
  c4_4->setValue(0);
  c4->addChild(c4_1);
  c4->addChild(c4_4);

  ASTNode *p2 = new ASTNode(AST_CONSTRUCTOR_PIECE);
  p2->addChild(c3);
  p2->addChild(c4);

  N->addChild(p1);
  N->addChild(p2);

  // N = SBML_parseFormula(f);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n" 
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(0);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);
  

  ASTNode *c3 = new ASTNode(AST_INTEGER);
  c3->setValue(0);

  ASTNode *c4 = new ASTNode(AST_RELATIONAL_EQ);
  ASTNode *c4_1 = new ASTNode(AST_NAME);
  c4_1->setName("x");
  ASTNode *c4_4 = new ASTNode(AST_INTEGER);
  c4_4->setValue(0);
  c4->addChild(c4_1);
  c4->addChild(c4_4);

  // old way of constructing a pw
  N->addChild(c1);
  N->addChild(c2);
  N->addChild(c3);
  N->addChild(c4);

  // N = SBML_parseFormula(f);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise_otherwise)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> x </ci>\n" 
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(0);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);
  
  ASTNode *p1 = new ASTNode(AST_CONSTRUCTOR_PIECE);
  p1->addChild(c1);
  p1->addChild(c2);
  

  ASTNode *c3 = new ASTNode(AST_NAME);
  c3->setName("x");

  ASTNode *p2 = new ASTNode(AST_CONSTRUCTOR_OTHERWISE);
  p2->addChild(c3);

  N->addChild(p1);
  N->addChild(p2);

  // N = SBML_parseFormula("piecewise(0, lt(x, 0), x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise_otherwise1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> x </ci>\n" 
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(0);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);
  

  ASTNode *c3 = new ASTNode(AST_NAME);
  c3->setName("x");

  N->addChild(c1);
  N->addChild(c2);
  N->addChild(c3);

  // N = SBML_parseFormula("piecewise(0, lt(x, 0), x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise_no_piece)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <otherwise>\n"
    "      <ci> x </ci>\n" 
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c3 = new ASTNode(AST_NAME);
  c3->setName("x");

  ASTNode *p2 = new ASTNode(AST_CONSTRUCTOR_OTHERWISE);
  p2->addChild(c3);

  N->addChild(p2);

  // N = SBML_parseFormula("piecewise(0, lt(x, 0), x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_piecewise_no_piece1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <otherwise>\n"
    "      <ci> x </ci>\n" 
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode *c3 = new ASTNode(AST_NAME);
  c3->setName("x");

  N->addChild(c3);

  // N = SBML_parseFormula("piecewise(0, lt(x, 0), x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_semantics)
{
  const char* expected = wrapMathML
  (
    "  <semantics>\n"
    "    <apply>\n"
    "      <lt/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "    </apply>\n"
    "  </semantics>\n"
  );

  N = new ASTNode(AST_SEMANTICS);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);

  N->addChild(c2);

  // N = SBML_parseFormula("lt(x, 0)");
 //N->setSemanticsFlag();
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_semantics_url)
{
  const char* expected = wrapMathML
  (
    "  <semantics definitionURL=\"foobar\">\n"
    "    <apply>\n"
    "      <lt/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "    </apply>\n"
    "  </semantics>\n"
  );

  XMLAttributes *xa = new XMLAttributes();
  xa->add("definitionURL", "foobar");
  
  N = new ASTNode(AST_SEMANTICS);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);

  N->addChild(c2);

  N->setDefinitionURL(*xa);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
  delete xa;
}
END_TEST


START_TEST (test_MathMLFromAST_semantics_ann)
{
  const char* expected = wrapMathML
  (
    "  <semantics>\n"
    "    <apply>\n"
    "      <lt/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "    </apply>\n"
    "    <annotation encoding=\"bar\">foo</annotation>\n"
    "  </semantics>\n"
  );

  XMLAttributes xa = XMLAttributes();
  xa.add("encoding", "bar");
  
  XMLTriple triple = XMLTriple("annotation", "", "");
  
  XMLToken ann_token = XMLToken(triple, xa);
  
  XMLNode *ann = new XMLNode(ann_token);
  XMLToken text = XMLToken("foo");
  XMLNode textNode = XMLNode(text);
  ann->addChild(textNode);
  
  N = new ASTNode(AST_SEMANTICS);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);

  N->addChild(c2);

  // N = SBML_parseFormula("lt(x, 0)");
  // // N->setSemanticsFlag();
  N->addSemanticsAnnotation(ann);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_semantics_annxml)
{
  const char* expected = wrapMathML
  (
    "  <semantics>\n"
    "    <apply>\n"
    "      <lt/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 0 </cn>\n"
    "    </apply>\n"
    "    <annotation-xml encoding=\"bar\">\n"
    "      <foobar>\n"
    "        <bar id=\"c\"/>\n"
    "      </foobar>\n"
    "    </annotation-xml>\n"
    "  </semantics>\n"
  );

  XMLAttributes xa = XMLAttributes();
  xa.add("encoding", "bar");
  
  XMLAttributes xa1 = XMLAttributes();
  xa1.add("id", "c");

  XMLAttributes blank = XMLAttributes();

  XMLTriple triple = XMLTriple("annotation-xml", "", "");
  XMLTriple foo_triple = XMLTriple("foobar", "", "");
  XMLTriple bar_triple = XMLTriple("bar", "", "");
  
  XMLToken ann_token = XMLToken(triple, xa);
  XMLToken foo_token = XMLToken(foo_triple, blank);
  XMLToken bar_token = XMLToken(bar_triple, xa1);
  
  XMLNode bar = XMLNode(bar_token);
  XMLNode foo = XMLNode(foo_token);
  XMLNode *ann = new XMLNode(ann_token);

  foo.addChild(bar);
  ann->addChild(foo);
  
  N = new ASTNode(AST_SEMANTICS);

  ASTNode *c2 = new ASTNode(AST_RELATIONAL_LT);
  ASTNode *c2_1 = new ASTNode(AST_NAME);
  c2_1->setName("x");
  ASTNode *c2_2 = new ASTNode(AST_INTEGER);
  c2_2->setValue(0);
  c2->addChild(c2_1);
  c2->addChild(c2_2);

  N->addChild(c2);

  // N = SBML_parseFormula("lt(x, 0)");
  // // N->setSemanticsFlag();
  
  N->addSemanticsAnnotation(ann);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_cn_units)
{
  const char *expected = wrapMathMLUnits("  <cn sbml:units=\"mole\"> 1.2 </cn>\n");

  // N = SBML_parseFormula("1.2");
  // N->setUnits("mole");
  N = new ASTNode(AST_REAL);
  N->setValue(1.2);
  N->setUnits("mole");

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_csymbol_avogadro)
{
  const char* expected = wrapMathML
  (
    "  <csymbol encoding=\"text\" "
    "definitionURL=\"http://www.sbml.org/sbml/symbols/avogadro\"> NA </csymbol>\n"
  );

  N = new ASTNode(AST_NAME_AVOGADRO);
  N->setName("NA");

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFromAST_ci_definitionURL)
{
  const char* expected = wrapMathML("  <ci definitionURL=\"http://someurl\"> foo </ci>\n");

  // N = SBML_parseFormula("foo");
  N = new ASTNode(AST_NAME);
  N->setName("foo");
  XMLAttributes xml;
  xml.add("", "http://someurl");
  N->setDefinitionURL(xml);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFromAST_ci_id)
{
  const char* expected = wrapMathML("  <ci id=\"test\"> foo </ci>\n");

  N = new ASTNode(AST_NAME);
  N->setName("foo");

  fail_unless(N->setId("test") == LIBSBML_OPERATION_SUCCESS);


  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFromAST_ci_class)
{
  const char* expected = wrapMathML("  <ci class=\"test\"> foo </ci>\n");

  N = new ASTNode(AST_NAME);
  N->setName("foo");

  fail_unless(N->setClass("test") == LIBSBML_OPERATION_SUCCESS);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFromAST_ci_style)
{
  const char* expected = wrapMathML("  <ci style=\"test\"> foo </ci>\n");

  N = new ASTNode(AST_NAME);
  N->setName("foo");

  fail_unless(N->setStyle("test") == LIBSBML_OPERATION_SUCCESS);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFromAST_func_style)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <sin style=\"a\"/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_SIN);
  N->setStyle("a");

  ASTNode * c = new ASTNode(AST_INTEGER);
  c->setValue((int)(1));

  N->addChild(c);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFromAST_nested_funcs)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <divide/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <apply>\n"
    "      <sin/>\n"
    "      <cn type=\"rational\"> 3 <sep/> 5 </cn>\n"
    "    </apply>\n"
    "  </apply>\n"
  );

//  // N = SBML_parseFormula("1 + 2 + x * y * z + 3");
  
  N = new ASTNode(AST_DIVIDE);
  
  ASTNode *c1 = new ASTNode(AST_INTEGER);
  c1->setValue(long(1));
  ASTNode *c2 = new ASTNode(AST_RATIONAL);
  c2->setValue(long(3), long(5));
  ASTNode *sin = new ASTNode(AST_FUNCTION_SIN);

  sin->addChild(c2);
  
  N->addChild(c1);
  N->addChild(sin);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

#if(0)
START_TEST (test_MathMLFromAST_replaceIDWithFunction_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn> 1 </cn>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "  <ci> x </ci>\n"
  );

  N = new ASTNode(AST_NAME);
  N->setName("x");

  ASTNode *replaced = new ASTNode(AST_PLUS);
  ASTNode *c = new ASTNode();
  c->setValue(1.0);
  replaced->addChild(c);
  
  S = writeMathMLToString(N);

  fail_unless( equals(original, S) );

  N->replaceIDWithFunction("x", replaced);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST
#endif

START_TEST (test_MathMLFromAST_replaceIDWithFunction_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <power/>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <cn> 1 </cn>\n"
    "    </apply>\n"
    "    <cn> 2 </cn>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "  <apply>\n"
    "    <power/>\n"
    "    <ci> x </ci>\n"
    "    <cn> 2 </cn>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_POWER);
  ASTNode *n1 = new ASTNode(AST_NAME);
  n1->setName("x");
  ASTNode *n2 = new ASTNode();
  n2->setValue(2.0);
  N->addChild(n1);
  N->addChild(n2);
  
  ASTNode *replaced = new ASTNode(AST_PLUS);
  ASTNode *c = new ASTNode();
  c->setValue(1.0);
  replaced->addChild(c);
  
  S = writeMathMLToString(N);

  fail_unless( equals(original, S) );

  N->replaceIDWithFunction("x", replaced);

  safe_free(S);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

  delete replaced;
}
END_TEST


Suite *
create_suite_NewWriteMathMLFromAST ()
{
  Suite *suite = suite_create("NewWriteMathMLFromAST");
  TCase *tcase = tcase_create("NewWriteMathMLFromAST");

  tcase_add_checked_fixture(tcase, NewWriteMathMLFromAST_setup, NewWriteMathMLFromAST_teardown);

  tcase_add_test( tcase, test_MathMLFromAST_cn_real_1             );
  tcase_add_test( tcase, test_MathMLFromAST_cn_real_2             );
  tcase_add_test( tcase, test_MathMLFromAST_cn_real_3             );
  tcase_add_test( tcase, test_MathMLFromAST_cn_real_locale        );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_1       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_2       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_3       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_4       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_5       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_6       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_e_notation_7       );
  tcase_add_test( tcase, test_MathMLFromAST_cn_integer            );
  tcase_add_test( tcase, test_MathMLFromAST_cn_rational           );

  tcase_add_test( tcase, test_MathMLFromAST_ci                    );
  tcase_add_test( tcase, test_MathMLFromAST_csymbol_delay         );
  tcase_add_test( tcase, test_MathMLFromAST_csymbol_time          );
  tcase_add_test( tcase, test_MathMLFromAST_constant_true         );
  tcase_add_test( tcase, test_MathMLFromAST_constant_false        );
  tcase_add_test( tcase, test_MathMLFromAST_constant_notanumber   );
  tcase_add_test( tcase, test_MathMLFromAST_constant_infinity     );
  tcase_add_test( tcase, test_MathMLFromAST_constant_infinity_neg );
  tcase_add_test( tcase, test_MathMLFromAST_constant_infinity_neg1 );
  tcase_add_test( tcase, test_MathMLFromAST_constant_exponentiale );
  tcase_add_test( tcase, test_MathMLFromAST_constant_pi );
  tcase_add_test( tcase, test_MathMLFromAST_plus_binary           );
  tcase_add_test( tcase, test_MathMLFromAST_plus_nary_1           );
  tcase_add_test( tcase, test_MathMLFromAST_plus_nary_2           );
  tcase_add_test( tcase, test_MathMLFromAST_plus_nary_3           );
  tcase_add_test( tcase, test_MathMLFromAST_plus_nary_4           );
  tcase_add_test( tcase, test_MathMLFromAST_minus                 );
  tcase_add_test( tcase, test_MathMLFromAST_minus_unary_1         );
  tcase_add_test( tcase, test_MathMLFromAST_minus_unary_2         );
  tcase_add_test( tcase, test_MathMLFromAST_function_1            );
  tcase_add_test( tcase, test_MathMLFromAST_function_2            );
  tcase_add_test( tcase, test_MathMLFromAST_sin                   );
  tcase_add_test( tcase, test_MathMLFromAST_log                   );

    // TO DO - crash

  // this one - log with one argument does not work for now
  // since we need to replicate old behaviour
//  tcase_add_test( tcase, test_MathMLFromAST_log_1                   );
  
  tcase_add_test( tcase, test_MathMLFromAST_log_2                   );
  tcase_add_test( tcase, test_MathMLFromAST_log_3                   );
  tcase_add_test( tcase, test_MathMLFromAST_log_4                   );
  tcase_add_test( tcase, test_MathMLFromAST_root                  );
  tcase_add_test( tcase, test_MathMLFromAST_root1                  );
  tcase_add_test( tcase, test_MathMLFromAST_root2                 );
  tcase_add_test( tcase, test_MathMLFromAST_root3                  );
  tcase_add_test( tcase, test_MathMLFromAST_lambda                );
  tcase_add_test( tcase, test_MathMLFromAST_lambda1                );
  tcase_add_test( tcase, test_MathMLFromAST_lambda_no_bvars       );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise             );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise1             );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise_otherwise   );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise_otherwise1   );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise_no_piece    );
  tcase_add_test( tcase, test_MathMLFromAST_piecewise_no_piece1    );

  tcase_add_test( tcase, test_MathMLFromAST_semantics             );
  tcase_add_test( tcase, test_MathMLFromAST_semantics_url         );
  tcase_add_test( tcase, test_MathMLFromAST_semantics_ann         );
  tcase_add_test( tcase, test_MathMLFromAST_semantics_annxml      );

  ///* L3 additions */
  tcase_add_test( tcase, test_MathMLFromAST_cn_units           );

  tcase_add_test( tcase, test_MathMLFromAST_csymbol_avogadro         );
  tcase_add_test( tcase, test_MathMLFromAST_ci_definitionURL         );
  tcase_add_test( tcase, test_MathMLFromAST_ci_id                    );
  tcase_add_test( tcase, test_MathMLFromAST_ci_class                 );
  tcase_add_test( tcase, test_MathMLFromAST_ci_style                 );

  tcase_add_test( tcase, test_MathMLFromAST_func_style                 );
  tcase_add_test( tcase, test_MathMLFromAST_nested_funcs                 );

  // this will not work as the function is not currently intended
  // to work on the whole AST only its children
  //tcase_add_test( tcase, test_MathMLFromAST_replaceIDWithFunction_1    );
  tcase_add_test( tcase, test_MathMLFromAST_replaceIDWithFunction_2    );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
