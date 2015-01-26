/**
 * \file    TestFormulaFormatter.c
 * \brief   FormulaFormatter unit tests
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

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_FormulaFormatter_isFunction)
{
  ASTNode_t *n = ASTNode_create();


  ASTNode_setType(n, AST_PLUS);
  fail_unless( FormulaFormatter_isFunction(n) == 0, NULL );

  ASTNode_setType(n, AST_NAME);
  fail_unless( FormulaFormatter_isFunction(n) == 0, NULL );

  ASTNode_setType(n, AST_CONSTANT_PI);
  fail_unless( FormulaFormatter_isFunction(n) == 0, NULL );

  ASTNode_setType(n, AST_LAMBDA);
  fail_unless( FormulaFormatter_isFunction(n) == 1, NULL );

  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( FormulaFormatter_isFunction(n) == 1, NULL );

  ASTNode_setType(n, AST_LOGICAL_AND);
  fail_unless( FormulaFormatter_isFunction(n) == 1, NULL );

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  fail_unless( FormulaFormatter_isFunction(n) == 1, NULL );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_FormulaFormatter_isGrouped)
{
  ASTNode_t *p = ASTNode_create();
  ASTNode_t *c;


  /** Empty parent, p is the root of the tree. **/
  fail_unless( FormulaFormatter_isGrouped(NULL, p) == 0, NULL );
  ASTNode_free(p);


  /** "1 + 2 * 3" **/
  p = SBML_parseFormula("1 + 2 * 3");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  /** "(1 + 2) * 3" **/
  p = SBML_parseFormula("(1 + 2) * 3");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 1, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  /**
   * "1 + (2 * 3)":
   *
   * In this case, explicit grouping is not needed due to operator
   * precedence rules.
   */
  p = SBML_parseFormula("1 + (2 * 3)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  /**
   * "foo(1 + 2, 2 * 3)":
   *
   * The parent node foo has higher precedence than its children, but
   * grouping is not nescessary since foo is a function.
   */
  p = SBML_parseFormula("foo(1 + 2, 2 * 3)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  /**
   * "(a / b) * c":
   *
   * In this case, explicit grouping is not needed due to associativity
   * rules.
   */
  p = SBML_parseFormula("(a / b) * c");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  /**
   * "a / (b * c)":
   *
   * In this case, explicit grouping is needed.  The operators / and * have
   * the same precedence, but the parenthesis modifies the associativity.
   */
  p = SBML_parseFormula("a / (b * c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 1, NULL );

  ASTNode_free(p);


  /**
   * "a - (b - c)":
   *
   * Rainer Machne reported that the above parsed correctly, but was not
   * formatted correctly.
   *
   * The bug was in FormulaFormatter_isGrouped().  While it was correctly
   * handling parent and child ASTNodes of the same precedence, it was not
   * handling the special subcase where parent and child nodes were the
   * same operator.  For grouping, this only matters for the subtraction
   * and division operators, as they are not associative.
   * 
   * An exhaustive set of eight tests follow.
   */
  p = SBML_parseFormula("a - (b - c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a - b - c");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a + (b + c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a + b + c");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a * (b * c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a * b * c");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a / (b / c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseFormula("a / b / c");

  c = ASTNode_getLeftChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( FormulaFormatter_isGrouped(p, c) == 0, NULL );

  ASTNode_free(p);
}
END_TEST


START_TEST (test_FormulaFormatter_formatRational)
{
  StringBuffer_t *sb = StringBuffer_create(10);
  ASTNode_t      *n  = ASTNode_create();
  char           *s;


  ASTNode_setRational(n, 1, 2);
  FormulaFormatter_formatRational(sb, n);
  s = StringBuffer_toString(sb);

  fail_unless( !strcmp(s, "(1/2)"), NULL );

  safe_free(s);
  ASTNode_free(n);
  StringBuffer_free(sb);
}
END_TEST


START_TEST (test_FormulaFormatter_formatReal)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();


  /** 1.2 **/
  ASTNode_setReal(n, 1.2);
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "1.2"), NULL );
  StringBuffer_reset(sb);


  /** 1e-100 **/
  ASTNode_setRealWithExponent(n, 1, -100);
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "1.000000e-100"), NULL );
  StringBuffer_reset(sb);



  /** NaN **/
  ASTNode_setReal(n, util_NaN());
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "NaN"), NULL );
  StringBuffer_reset(sb);

  /** Inf **/
  ASTNode_setReal(n, util_PosInf());
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "INF"), NULL );
  StringBuffer_reset(sb);


  /** -Inf **/
  ASTNode_setReal(n, util_NegInf());
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "-INF"), NULL );
  StringBuffer_reset(sb);


  /** -0 **/
  ASTNode_setReal(n, util_NegZero());
  FormulaFormatter_formatReal(sb, n);

  fail_unless( !strcmp(s, "-0"), NULL );
  StringBuffer_reset(sb);


  StringBuffer_free(sb);
  ASTNode_free(n);
}
END_TEST


START_TEST (test_SBML_formulaToString)
{
  const char *formulae[] =
  {
    "1",
    "2.1",
#if defined(WIN32) && !defined(CYGWIN)
    "2.100000e-010",
#else
    "2.100000e-10",
#endif
    "foo",
    "1 + foo",
    "1 + 2",
    "1 + 2 * 3",
    "(1 - 2) * 3",
    "1 + -2 / 3",
    "1 + -2.000000e-100 / 3",
    "1 - -foo / 3",
    "2 * foo^bar + 3.1",
    "foo()",
    "foo(1)",
    "foo(1, bar)",
    "foo(1, bar, 2^-3)",
    "a / b * c",
    "a / (b * c)",
    "1 + 2 + 3",
    "pow(x, y)",
    ""
  };

  ASTNode_t *n;
  char      *s;
  int        i;


  for (i = 0; i < *formulae[i]; i++)
  {
    n = SBML_parseFormula( formulae[i] );
    s = SBML_formulaToString(n);

	fail_unless( !strcmp(s, formulae[i]), NULL );

    ASTNode_free(n);
    safe_free(s);
  }
}
END_TEST


START_TEST (test_SBML_formulaToString_L1toL1)
{
  ASTNode_t *n;
  char      *s;


  /** acos(x) -> acos(x) **/
  n = SBML_parseFormula("acos(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "acos(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arcsin(x) -> asin(x) **/
  n = SBML_parseFormula("asin(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "asin(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** atan(x) -> atan(x) **/
  n = SBML_parseFormula("atan(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "atan(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ceil(x) -> ceil(x) **/
  n = SBML_parseFormula("ceil(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "ceil(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** log(x) -> log(x) **/
  n = SBML_parseFormula("log(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "log(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** log10( x) -> log10(x) **/
  n = SBML_parseFormula("log10(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "log10(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** pow(x, y) -> pow(x, y) **/
  n = SBML_parseFormula("pow(x, y)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "pow(x, y)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** sqr(x) -> pow(x, 2) **/
  n = SBML_parseFormula("sqr(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "pow(x, 2)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** sqrt(x) -> sqrt(x) **/
  n = SBML_parseFormula("sqrt(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "sqrt(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST


START_TEST (test_SBML_formulaToString_L2toL1)
{
  ASTNode_t *n;
  char      *s;


  /** arccos(x) -> acos(x) **/
  n = SBML_parseFormula("arccos(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "acos(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arcsin(x) -> asin(x) **/
  n = SBML_parseFormula("arcsin(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "asin(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arctan(x) -> atan(x) **/
  n = SBML_parseFormula("arctan(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "atan(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ceiling(x) -> ceil(x) **/
  n = SBML_parseFormula("ceiling(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "ceil(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ln(x) -> log(x) **/
  n = SBML_parseFormula("ln(x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "log(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** log(10, x) -> log10(x) **/
  n = SBML_parseFormula("log(10, x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "log10(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** power(x, y) -> pow(x, y) **/
  n = SBML_parseFormula("power(x, y)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "pow(x, y)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** power(x, 2) -> pow(x, 2) **/
  n = SBML_parseFormula("power(x, 2)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "pow(x, 2)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** root(2, x) -> sqrt(x) **/
  n = SBML_parseFormula("root(2, x)");
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "sqrt(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiPlusTimes)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_PLUS);
  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);

  fail_unless( !strcmp(s, "x + y + z"), NULL );

  ASTNode_setType(n, AST_TIMES); 
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x * y * z"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiEq)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "eq()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "eq(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "eq(x, y)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "eq(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiNEq)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_NEQ);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "neq()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "neq(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "neq(x, y)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "neq(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiGT)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_GT);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "gt()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "gt(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "gt(x, y)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "gt(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiPlus)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_PLUS);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "0"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x + y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x + y + z"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiDivide)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_DIVIDE);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, " / "), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, " / (x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x / y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "x / y / z"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiAnd)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_LOGICAL_AND);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "and()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "and(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "and(x, y)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "and(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_multiOr)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_LOGICAL_OR);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "or()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "or(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "or(x, y)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToString(n);
  fail_unless( !strcmp(s, "or(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_FormulaFormatter_accessWithNULL)
{

  // ensure we survive NULL arguments
  FormulaFormatter_format(NULL, NULL);
  FormulaFormatter_formatFunction(NULL, NULL);
  FormulaFormatter_formatOperator(NULL, NULL);
  FormulaFormatter_formatRational(NULL, NULL);
  FormulaFormatter_formatReal(NULL, NULL);
  FormulaFormatter_visit(NULL, NULL, NULL);
  FormulaFormatter_visitFunction(NULL, NULL, NULL);
  FormulaFormatter_visitLog10(NULL, NULL, NULL);
  FormulaFormatter_visitOther(NULL, NULL, NULL);
  FormulaFormatter_visitSqrt(NULL, NULL, NULL);
  FormulaFormatter_visitUMinus(NULL, NULL, NULL);

  fail_unless( FormulaFormatter_isFunction(NULL) == 0 );
  fail_unless( FormulaFormatter_isGrouped(NULL, NULL) == 0 );
  fail_unless( SBML_formulaToString(NULL) == NULL );
  
}
END_TEST


Suite *
create_suite_FormulaFormatter (void) 
{ 
  Suite *suite = suite_create("FormulaFormatter");
  TCase *tcase = tcase_create("FormulaFormatter");
 

  tcase_add_test( tcase, test_FormulaFormatter_isFunction     );
  tcase_add_test( tcase, test_FormulaFormatter_isGrouped      );
  tcase_add_test( tcase, test_FormulaFormatter_formatRational );
  tcase_add_test( tcase, test_FormulaFormatter_formatReal     );
  tcase_add_test( tcase, test_FormulaFormatter_multiPlusTimes );
  tcase_add_test( tcase, test_FormulaFormatter_accessWithNULL );
  tcase_add_test( tcase, test_SBML_formulaToString            );
  tcase_add_test( tcase, test_SBML_formulaToString_L1toL1     );
  tcase_add_test( tcase, test_SBML_formulaToString_L2toL1     );
  tcase_add_test( tcase, test_FormulaFormatter_multiEq        );
  tcase_add_test( tcase, test_FormulaFormatter_multiNEq       );
  tcase_add_test( tcase, test_FormulaFormatter_multiGT        );
  tcase_add_test( tcase, test_FormulaFormatter_multiPlus      );
  tcase_add_test( tcase, test_FormulaFormatter_multiDivide    );
  tcase_add_test( tcase, test_FormulaFormatter_multiAnd       );
  tcase_add_test( tcase, test_FormulaFormatter_multiOr        );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif

