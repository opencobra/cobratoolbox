/**
 * \file    TestL3FormulaFormatter.c
 * \brief   FormulaFormatter unit tests
 * \author  Lucian Smith, from Ben Bornstein
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

#include <sbml/math/L3FormulaFormatter.h>
#include <sbml/math/L3Parser.h>
#include <sbml/math/L3ParserSettings.h>
//extern int isTranslatedModulo (const ASTNode_t* node);
//extern int getL3Precedence(const ASTNode_t* node);

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_L3FormulaFormatter_isFunction)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_t *c = ASTNode_create();


  ASTNode_setType(n, AST_NAME);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 0, NULL );

  ASTNode_setType(n, AST_CONSTANT_PI);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 0, NULL );

  ASTNode_setType(n, AST_LAMBDA);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_LOGICAL_AND);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_PLUS);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );


  ASTNode_addChild(n, c);
  ASTNode_setType(n, AST_LOGICAL_AND);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );

  ASTNode_setType(n, AST_PLUS);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 1, NULL );


  c = ASTNode_create();
  ASTNode_addChild(n, c);
  ASTNode_setType(n, AST_LOGICAL_AND);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 0, NULL );

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 0, NULL );

  ASTNode_setType(n, AST_PLUS);
  fail_unless( L3FormulaFormatter_isFunction(n, NULL) == 0, NULL );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_L3FormulaFormatter_isGrouped)
{
  ASTNode_t *p = ASTNode_create();
  ASTNode_t *c;


  /** Empty parent, p is the root of the tree. **/
  fail_unless( L3FormulaFormatter_isGrouped(NULL, p, NULL) == 0, NULL );
  ASTNode_free(p);


  /** "1 + 2 * 3" **/
  p = SBML_parseL3Formula("1 + 2 * 3");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  /** "(1 + 2) * 3" **/
  p = SBML_parseL3Formula("(1 + 2) * 3");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  /**
   * "1 + (2 * 3)":
   *
   * In this case, explicit grouping is not needed due to operator
   * precedence rules.
   */
  p = SBML_parseL3Formula("1 + (2 * 3)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  /**
   * "foo(1 + 2, 2 * 3)":
   *
   * The parent node foo has higher precedence than its children, but
   * grouping is not nescessary since foo is a function.
   */
  p = SBML_parseL3Formula("foo(1 + 2, 2 * 3)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  /**
   * "(a / b) * c":
   *
   * In this case, explicit grouping is not needed due to associativity
   * rules.
   */
  p = SBML_parseL3Formula("(a / b) * c");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  /**
   * "a / (b * c)":
   *
   * In this case, explicit grouping is needed.  The operators / and * have
   * the same precedence, but the parenthesis modifies the associativity.
   */
  p = SBML_parseL3Formula("a / (b * c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  ASTNode_free(p);


  /**
   * "a - (b - c)":
   *
   * Rainer Machne reported that the above parsed correctly, but was not
   * formatted correctly.
   *
   * The bug was in L3FormulaFormatter_isGrouped().  While it was correctly
   * handling parent and child ASTNodes of the same precedence, it was not
   * handling the special subcase where parent and child nodes were the
   * same operator.  For grouping, this only matters for the subtraction
   * and division operators, as they are not associative.
   * 
   * An exhaustive set of eight tests follow.
   */
  p = SBML_parseL3Formula("a - (b - c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a - b - c");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a + (b + c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a + b + c");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a * (b * c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a * b * c");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a / (b / c)");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 1, NULL );

  ASTNode_free(p);


  p = SBML_parseL3Formula("a / b / c");

  c = ASTNode_getLeftChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  c = ASTNode_getRightChild(p);
  fail_unless( L3FormulaFormatter_isGrouped(p, c, NULL) == 0, NULL );

  ASTNode_free(p);
}
END_TEST


START_TEST (test_SBML_formulaToL3String)
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
    "x % y",
    "(1 + x) % (3 / y)",
    "x^2 % -y",
    "x && y == z",
    "(x && y) == z",
    "a && b || c",
    "a && (b || c)",
    "-x^y",
    "(-x)^y",
    "x^-y",
    "!x^2",
    "(!x)^2",
    "x^!2",
    "x == y == z",
    "x >= y <= z",
    "x > y == z",
    "1 ml",
    "(3/4) uM",
    "INF",
    "NaN",
    "avogadro",
    "time",
    "pi",
    "true",
    "false",
    "(x > y) + (p == q)",
    "gt(x, y, z) + eq(p, d, q)",
    "gt(x) + eq(p)",
    "gt() + eq()",
    "(x || y) > (p && q)",
    "or(x) > and(p)",
    "or() > and()",
    "(x * y)^2",
    "(x * y * z)^2",
    "times(x)^2",
    "times()^2",
    ""
  };

  ASTNode_t *n;
  char      *s;
  int        i;


  for (i = 0; i < *formulae[i]; i++)
  {
    n = SBML_parseL3Formula( formulae[i] );
    s = SBML_formulaToL3String(n);

    fail_unless( !strcmp(s, formulae[i]), NULL );

    ASTNode_free(n);
    safe_free(s);
  }
}
END_TEST


START_TEST (test_SBML_formulaToL3String_L1toL3)
{
  ASTNode_t *n;
  char      *s;


  /** acos(x) -> acos(x) **/
  n = SBML_parseL3Formula("acos(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "acos(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arcsin(x) -> asin(x) **/
  n = SBML_parseL3Formula("asin(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "asin(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** atan(x) -> atan(x) **/
  n = SBML_parseL3Formula("atan(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "atan(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ceil(x) -> ceil(x) **/
  n = SBML_parseL3Formula("ceil(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "ceil(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** log(x) -> log10(x) **/
  n = SBML_parseL3Formula("log(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "log10(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** log(x) -> log10(x), if parsed with the old parser **/
  n = SBML_parseFormula("log(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "ln(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** log10( x) -> log10(x) **/
  n = SBML_parseL3Formula("log10(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "log10(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** pow(x, y) -> x^y **/
  n = SBML_parseL3Formula("pow(x, y)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "x^y"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** sqr(x) -> x^2 **/
  n = SBML_parseL3Formula("sqr(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "x^2"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** sqrt(x) -> sqrt(x) **/
  n = SBML_parseL3Formula("sqrt(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "sqrt(x)"), NULL );


  n = SBML_parseL3Formula("x + (y + z)");
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x + (y + z)"), NULL );

  n = SBML_parseL3Formula("(x + y) + z");
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x + y + z"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST


START_TEST (test_SBML_formulaToL3String_L2toL3)
{
  ASTNode_t *n;
  char      *s;


  /** arccos(x) -> acos(x) **/
  n = SBML_parseL3Formula("arccos(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "acos(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arcsin(x) -> asin(x) **/
  n = SBML_parseL3Formula("arcsin(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "asin(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** arctan(x) -> atan(x) **/
  n = SBML_parseL3Formula("arctan(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "atan(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ceiling(x) -> ceil(x) **/
  n = SBML_parseL3Formula("ceiling(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "ceil(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** ln(x) -> log(x) **/
  n = SBML_parseL3Formula("ln(x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "ln(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** log(10, x) -> log10(x) **/
  n = SBML_parseL3Formula("log(10, x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "log10(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** power(x, y) -> pow(x, y) **/
  n = SBML_parseL3Formula("power(x, y)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "x^y"), NULL );

  safe_free(s);
  ASTNode_free(n);

  /** power(x, 2) -> pow(x, 2) **/
  n = SBML_parseL3Formula("power(x, 2)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "x^2"), NULL );

  safe_free(s);
  ASTNode_free(n);


  /** root(2, x) -> sqrt(x) **/
  n = SBML_parseL3Formula("root(2, x)");
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "sqrt(x)"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiPlusTimes)
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
  s = SBML_formulaToL3String(n);

  fail_unless( !strcmp(s, "x + y + z"), NULL );

  ASTNode_setType(n, AST_TIMES); 
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x * y * z"), NULL );

  safe_free(s);
  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_collapseMinus)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();
  ASTNode_t      *c2 = ASTNode_create();
  ASTNode_t      *c3 = ASTNode_create();
  ASTNode_t      *c4 = ASTNode_create();
  L3ParserSettings_t* l3ps = L3ParserSettings_create();

  ASTNode_setType(n, AST_MINUS);
  ASTNode_setType(c, AST_MINUS);
  ASTNode_addChild(n, c);
  ASTNode_setType(c2, AST_MINUS);
  ASTNode_addChild(c, c2);
  ASTNode_setType(c3, AST_MINUS);
  ASTNode_addChild(c2, c3);
  ASTNode_setName(c4, "x");
  ASTNode_addChild(c3, c4);

  //default (false)
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "----x"), NULL );
  safe_free(s);

  //explicit false
  L3ParserSettings_setParseCollapseMinus(l3ps, 0);
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "----x"), NULL );
  safe_free(s);

  //explicit true
  L3ParserSettings_setParseCollapseMinus(l3ps, 1);
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "x"), NULL );
  safe_free(s);

  ASTNode_free(n);
  L3ParserSettings_free(l3ps);
}
END_TEST

START_TEST (test_L3FormulaFormatter_parseUnits)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  L3ParserSettings_t* l3ps = L3ParserSettings_create();

  ASTNode_setReal(n, 1.1);
  ASTNode_setUnits(n, "mL");

  //default (true)
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "1.1 mL"), NULL );
  safe_free(s);

  //explicit false
  L3ParserSettings_setParseUnits(l3ps, 0);
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "1.1"), NULL );
  safe_free(s);

  //explicit true
  L3ParserSettings_setParseUnits(l3ps, 1);
  s = SBML_formulaToL3StringWithSettings(n, l3ps);
  fail_unless( !strcmp(s, "1.1 mL"), NULL );
  safe_free(s);

  ASTNode_free(n);
  L3ParserSettings_free(l3ps);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiEq)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_EQ);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "eq()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "eq(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x == y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "eq(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiNEq)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_NEQ);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "neq()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "neq(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x != y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "neq(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiGT)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_RELATIONAL_GT);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "gt()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "gt(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x > y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "gt(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiPlus)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_PLUS);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "plus()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "plus(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x + y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x + y + z"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiDivide)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_DIVIDE);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "divide()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "divide(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x / y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "divide(x, y, z)"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiAnd)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_LOGICAL_AND);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "and()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "and(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x && y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x && y && z"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_multiOr)
{
  StringBuffer_t *sb = StringBuffer_create(42);
  char           *s  = StringBuffer_getBuffer(sb);
  ASTNode_t      *n  = ASTNode_create();
  ASTNode_t      *c  = ASTNode_create();

  ASTNode_setType(n, AST_LOGICAL_OR);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "or()"), NULL );

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "or(x)"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x || y"), NULL );
  safe_free(s);

  c = ASTNode_create();
  ASTNode_setName(c, "z");
  ASTNode_addChild(n, c);
  s = SBML_formulaToL3String(n);
  fail_unless( !strcmp(s, "x || y || z"), NULL );
  safe_free(s);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_L3FormulaFormatter_accessWithNULL)
{

  // ensure we survive NULL arguments
  L3FormulaFormatter_format(NULL, NULL, NULL);
  L3FormulaFormatter_formatFunction(NULL, NULL, NULL);
  L3FormulaFormatter_formatOperator(NULL, NULL);
  L3FormulaFormatter_visit(NULL, NULL, NULL, NULL);
  L3FormulaFormatter_visitFunction(NULL, NULL, NULL, NULL);
  L3FormulaFormatter_visitLog10(NULL, NULL, NULL, NULL);
  L3FormulaFormatter_visitOther(NULL, NULL, NULL, NULL);
  L3FormulaFormatter_visitSqrt(NULL, NULL, NULL, NULL);
  L3FormulaFormatter_visitUMinus(NULL, NULL, NULL, NULL);

  fail_unless( L3FormulaFormatter_isFunction(NULL, NULL) == 0 );
  fail_unless( L3FormulaFormatter_isGrouped(NULL, NULL, NULL) == 0 );
  fail_unless( SBML_formulaToL3String(NULL) == NULL );
  
}
END_TEST


//START_TEST (test_getL3Precedence_noargs)
//{
//  ASTNode_t *n = ASTNode_create();
//
//  ASTNode_setType(n, AST_PLUS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_MINUS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_TIMES);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_DIVIDE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_POWER);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_INTEGER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RATIONAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_NAME);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_AVOGADRO);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_TIME);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_CONSTANT_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_FALSE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_PI);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_TRUE);
//  fail_unless( getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LAMBDA);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_FUNCTION);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ABS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CEILING);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_DELAY);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_EXP);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FACTORIAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FLOOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LOG);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_POWER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ROOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LOGICAL_AND);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_LOGICAL_NOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_LOGICAL_OR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_LOGICAL_XOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_RELATIONAL_EQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_GEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_GT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_LEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_LT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_NEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_UNKNOWN);
//  fail_unless(getL3Precedence(n) == 8);
//  ASTNode_free(n);
//}
//END_TEST
//
//START_TEST (test_getL3Precedence_onearg)
//{
//  ASTNode_t *n = ASTNode_create();
//  ASTNode_t *c = ASTNode_create();
//  ASTNode_setName(c, "x");
//  ASTNode_addChild(n, c);
//
//  ASTNode_setType(n, AST_PLUS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_MINUS);
//  fail_unless(getL3Precedence(n) == 6); //Different!
//
//  ASTNode_setType(n, AST_TIMES);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_DIVIDE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_POWER);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_INTEGER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RATIONAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_NAME);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_AVOGADRO);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_TIME);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_CONSTANT_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_FALSE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_PI);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_TRUE);
//  fail_unless( getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LAMBDA);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_FUNCTION);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ABS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CEILING);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_DELAY);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_EXP);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FACTORIAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FLOOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LOG);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_POWER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ROOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LOGICAL_AND);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_LOGICAL_NOT);
//  fail_unless(getL3Precedence(n) == 6); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_OR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_LOGICAL_XOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_RELATIONAL_EQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_GEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_GT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_LEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_LT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RELATIONAL_NEQ);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_UNKNOWN);
//  fail_unless(getL3Precedence(n) == 8);
//  ASTNode_free(n);
//}
//END_TEST
//
//START_TEST (test_getL3Precedence_twoargs)
//{
//  ASTNode_t *n = ASTNode_create();
//  ASTNode_t *c = ASTNode_create();
//  ASTNode_setName(c, "x");
//  ASTNode_addChild(n, c);
//  c = ASTNode_create();
//  ASTNode_setName(c, "y");
//  ASTNode_addChild(n, c);
//
//  ASTNode_setType(n, AST_PLUS);
//  fail_unless(getL3Precedence(n) == 4); //Different!
//
//  ASTNode_setType(n, AST_MINUS);
//  fail_unless(getL3Precedence(n) == 4); //Different!
//
//  ASTNode_setType(n, AST_TIMES);
//  fail_unless(getL3Precedence(n) == 5); //Different!
//
//  ASTNode_setType(n, AST_DIVIDE);
//  fail_unless(getL3Precedence(n) == 5); //Different!
//
//  ASTNode_setType(n, AST_POWER);
//  fail_unless(getL3Precedence(n) == 7); //Different!
//
//
//  ASTNode_setType(n, AST_INTEGER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RATIONAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_NAME);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_AVOGADRO);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_TIME);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_CONSTANT_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_FALSE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_PI);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_TRUE);
//  fail_unless( getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LAMBDA);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_FUNCTION);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ABS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CEILING);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_DELAY);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_EXP);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FACTORIAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FLOOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LOG);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_POWER);
//  fail_unless(getL3Precedence(n) == 7); //Different!
//
//  ASTNode_setType(n, AST_FUNCTION_ROOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LOGICAL_AND);
//  fail_unless(getL3Precedence(n) == 2); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_NOT);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_OR);
//  fail_unless(getL3Precedence(n) == 2); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_XOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_RELATIONAL_EQ);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_GEQ);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_GT);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_LEQ);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_LT);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_NEQ);
//  fail_unless(getL3Precedence(n) == 3); //Different!
//
//
//  ASTNode_setType(n, AST_UNKNOWN);
//  fail_unless(getL3Precedence(n) == 8);
//  ASTNode_free(n);
//}
//END_TEST
//
//START_TEST (test_getL3Precedence_threeargs)
//{
//  ASTNode_t *n = ASTNode_create();
//  ASTNode_t *c = ASTNode_create();
//  ASTNode_setName(c, "x");
//  ASTNode_addChild(n, c);
//  c = ASTNode_create();
//  ASTNode_setName(c, "y");
//  ASTNode_addChild(n, c);
//  c = ASTNode_create();
//  ASTNode_setName(c, "z");
//  ASTNode_addChild(n, c);
//
//  ASTNode_setType(n, AST_PLUS);
//  fail_unless(getL3Precedence(n) == 4); //Different!
//
//  ASTNode_setType(n, AST_MINUS);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_TIMES);
//  fail_unless(getL3Precedence(n) == 5); //Different!
//
//  ASTNode_setType(n, AST_DIVIDE);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_POWER);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//
//  ASTNode_setType(n, AST_INTEGER);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_REAL_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_RATIONAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_NAME);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_AVOGADRO);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_NAME_TIME);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_CONSTANT_E);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_FALSE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_PI);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_CONSTANT_TRUE);
//  fail_unless( getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LAMBDA);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_FUNCTION);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ABS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCOTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCCSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCSINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_ARCTANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CEILING);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COS);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COSH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_COTH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_CSCH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_DELAY);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_EXP);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FACTORIAL);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_FLOOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_LOG);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_POWER);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_FUNCTION_ROOT);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SEC);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SECH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SIN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_SINH);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TAN);
//  fail_unless(getL3Precedence(n) == 8);
//
//  ASTNode_setType(n, AST_FUNCTION_TANH);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_LOGICAL_AND);
//  fail_unless(getL3Precedence(n) == 2); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_NOT);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_OR);
//  fail_unless(getL3Precedence(n) == 2); //Different!
//
//  ASTNode_setType(n, AST_LOGICAL_XOR);
//  fail_unless(getL3Precedence(n) == 8);
//
//
//  ASTNode_setType(n, AST_RELATIONAL_EQ);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_GEQ);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_GT);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_LEQ);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_LT);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//  ASTNode_setType(n, AST_RELATIONAL_NEQ);
//  fail_unless(getL3Precedence(n) == 8); //Different!
//
//
//  ASTNode_setType(n, AST_UNKNOWN);
//  fail_unless(getL3Precedence(n) == 8);
//  ASTNode_free(n);
//}
//END_TEST
//
//START_TEST (test_getL3Precedence_mod)
//{
//  ASTNode_t *n = SBML_parseL3Formula("(x%1) % sin(j+(3%4))");
//  fail_unless( getL3Precedence(n) == 5);
//  ASTNode_free(n);
//
//}
//END_TEST
//
//
//START_TEST (test_isTranslatedModulo)
//{
//  ASTNode_t *n = ASTNode_create();
//  ASTNode_t *c = ASTNode_create();
//
//  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
//  fail_unless(!isTranslatedModulo(n));
//
//  ASTNode_setName(c, "x");
//  ASTNode_addChild(n, c);
//  c = ASTNode_create();
//  ASTNode_setName(c, "y");
//  ASTNode_addChild(n, c);
//  c = ASTNode_create();
//  ASTNode_setName(c, "z");
//  ASTNode_addChild(n, c);
//  fail_unless(!isTranslatedModulo(n));
//  ASTNode_free(n);
//
//  n = SBML_parseL3Formula("(x-1) % sin(j+(3/4))");
//  fail_unless( isTranslatedModulo(n));
//  ASTNode_free(n);
//
//  n = SBML_parseL3Formula("(x%1) % sin(j+(3%4))");
//  fail_unless( isTranslatedModulo(n));
//  ASTNode_free(n);
//
//  n = SBML_parseL3Formula("(x-1) % sin(j+(3/4)) % y^-2");
//  fail_unless( isTranslatedModulo(n));
//  ASTNode_free(n);
//}
//END_TEST


Suite *
create_suite_L3FormulaFormatter (void) 
{ 
  Suite *suite = suite_create("L3FormulaFormatter");
  TCase *tcase = tcase_create("L3FormulaFormatter");
 

  tcase_add_test( tcase, test_L3FormulaFormatter_isFunction     );
  tcase_add_test( tcase, test_L3FormulaFormatter_isGrouped      );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiPlusTimes );
  tcase_add_test( tcase, test_L3FormulaFormatter_accessWithNULL );
  tcase_add_test( tcase, test_SBML_formulaToL3String            );
  tcase_add_test( tcase, test_SBML_formulaToL3String_L1toL3     );
  tcase_add_test( tcase, test_SBML_formulaToL3String_L2toL3     );
  tcase_add_test( tcase, test_L3FormulaFormatter_collapseMinus  );
  tcase_add_test( tcase, test_L3FormulaFormatter_parseUnits     );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiEq        );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiNEq       );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiGT        );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiPlus      );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiDivide    );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiAnd       );
  tcase_add_test( tcase, test_L3FormulaFormatter_multiOr        );
  //tcase_add_test( tcase, test_getL3Precedence_noargs  );
  //tcase_add_test( tcase, test_getL3Precedence_onearg  );
  //tcase_add_test( tcase, test_getL3Precedence_twoargs );
  //tcase_add_test( tcase, test_getL3Precedence_threeargs);
  //tcase_add_test( tcase, test_getL3Precedence_mod     );
  //tcase_add_test( tcase, test_isTranslatedModulo      );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif

