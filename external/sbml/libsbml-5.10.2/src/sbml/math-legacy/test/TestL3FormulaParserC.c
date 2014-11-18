/**
 * \file    TestL3FormulaParser.c
 * \brief   L3FormulaParser unit tests
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
#include <sbml/math/L3Parser.h>
#include <sbml/math/L3ParserSettings.h>
#include <sbml/Model.h>
#include <sbml/Reaction.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/Compartment.h>
#include <sbml/SpeciesReference.h>
#include <sbml/FunctionDefinition.h>

#include <check.h>

#if __cplusplus
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_SBML_C_parseL3Formula_1)
{
  ASTNode_t *r = SBML_parseL3Formula("1");


  fail_unless( ASTNode_getType       (r) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (r) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_2)
{
  ASTNode_t *r = SBML_parseL3Formula("2.1");


  fail_unless( ASTNode_getType       (r) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (r) == 2.1, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_3)
{
  ASTNode_t *r = SBML_parseL3Formula("2.1e5");


  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) == 2.1, NULL );
  fail_unless( ASTNode_getExponent   (r) ==   5, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_4)
{
  ASTNode_t *r = SBML_parseL3Formula("foo");


  fail_unless( ASTNode_getType(r) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0     , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_5)
{
  ASTNode_t *r = SBML_parseL3Formula("1 + foo");
  ASTNode_t *c;



  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_6)
{
  ASTNode_t *r = SBML_parseL3Formula("1 + 2");
  ASTNode_t *c;



  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_7)
{
  ASTNode_t *r = SBML_parseL3Formula("1 + 2 * 3");
  ASTNode_t *c;



  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_TIMES, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '*', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_8)
{
  ASTNode_t *r = SBML_parseL3Formula("(1 - 2) * 3");
  ASTNode_t *c;


  fail_unless( ASTNode_getType       (r) == AST_TIMES, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '*', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getLeftChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger   (c)  == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_9)
{
  ASTNode_t *r = SBML_parseL3Formula("1 + -2 / 3");
  ASTNode_t *c;


  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(c) ==  1, NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_10)
{
  ASTNode_t *r = SBML_parseL3Formula("1 + -2e100 / 3");
  ASTNode_t *c;


  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(c) ==  1, NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (c) ==   2, NULL );
  fail_unless( ASTNode_getExponent   (c) == 100, NULL );
  fail_unless( ASTNode_getNumChildren(c) ==   0, NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_11)
{
  ASTNode_t *r = SBML_parseL3Formula("1 - -foo / 3");
  ASTNode_t *c;



  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2, NULL );

  c = ASTNode_getLeftChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild( ASTNode_getLeftChild( ASTNode_getRightChild(r) ) );

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_12)
{
  ASTNode_t *r = SBML_parseL3Formula("2 * foo^bar + 3.0");
  ASTNode_t *c;


  fail_unless( ASTNode_getType       (r) == AST_PLUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '+', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_TIMES, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '*', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 3.0, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0  , NULL );

  c = ASTNode_getLeftChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_POWER, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '^', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild( ASTNode_getRightChild( ASTNode_getLeftChild(r) ) );

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild( ASTNode_getLeftChild(r) ) );

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "bar") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_13)
{
  ASTNode_t *r = SBML_parseL3Formula("foo()");


  fail_unless( ASTNode_getType(r) == AST_FUNCTION , NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0     , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_14)
{
  ASTNode_t *r = SBML_parseL3Formula("foo(1)");
  ASTNode_t *c;


  fail_unless( ASTNode_getType(r) == AST_FUNCTION , NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1     , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_15)
{
  ASTNode_t *r = SBML_parseL3Formula("foo(1, bar)");
  ASTNode_t *c;


  fail_unless( ASTNode_getType(r) == AST_FUNCTION , NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2     , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "bar") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_16)
{
  ASTNode_t *r = SBML_parseL3Formula("foo(1, bar, 2^-3)");
  ASTNode_t *c;


  fail_unless( ASTNode_getType(r) == AST_FUNCTION , NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "foo") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 3     , NULL );

  c = ASTNode_getChild(r, 0);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getChild(r, 1);

  fail_unless( ASTNode_getType(c) == AST_NAME     , NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "bar") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0     , NULL );

  c = ASTNode_getChild(r, 2);

  fail_unless( ASTNode_getType       (c) == AST_POWER, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '^', NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild( ASTNode_getChild(r, 2) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getChild(r, 2) );

  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (c) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(c) ==  1, NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0 , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_17)
{
  ASTNode_t *r = SBML_parseL3Formula("1//1");

  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input '1//1' at position 3:  syntax error, unexpected '/'"), NULL);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_18)
{
  ASTNode_t *r = SBML_parseL3Formula("1+2*3 4");

  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input '1+2*3 4' at position 7:  syntax error, unexpected integer"), NULL);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_negInf)
{
  ASTNode_t *r = SBML_parseL3Formula("-inf");

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(r) ==  1, NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);


  fail_unless( ASTNode_getType(c)             == AST_REAL, NULL );
  fail_unless( util_isInf(ASTNode_getReal(c)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(c)      ==  0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_negZero)
{
  ASTNode_t *r = SBML_parseL3Formula("-0.0");

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(r) ==  1, NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType(c)                 == AST_REAL, NULL );
  fail_unless( util_isNegZero(ASTNode_getReal(c)) == 0, NULL );
  fail_unless( ASTNode_getReal(c)                 == 0, NULL );
  fail_unless( ASTNode_getNumChildren(c)          == 0, NULL );

  ASTNode_free(r);
}
END_TEST

START_TEST (test_SBML_C_parseL3Formula_e1)
{
  ASTNode_t *r = SBML_parseL3Formula("2.001e+5");


  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) == 2.001, NULL );
  fail_unless( ASTNode_getExponent   (r) ==   5, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_e2)
{
  ASTNode_t *r = SBML_parseL3Formula(".001e+5");


  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) == .001, NULL );
  fail_unless( ASTNode_getExponent   (r) ==   5, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_e3)
{
  ASTNode_t *r = SBML_parseL3Formula(".001e-5");


  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) == .001, NULL );
  fail_unless( ASTNode_getExponent   (r) ==  -5, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_e4)
{
  ASTNode_t *r = SBML_parseL3Formula("2.e-005");


  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) ==   2, NULL );
  fail_unless( ASTNode_getExponent   (r) ==  -5, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_e5)
{
  ASTNode_t *r = SBML_parseL3Formula(".e+5");

  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input '.e+5' at position 1:  syntax error, unexpected $undefined"), NULL);

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational1)
{
  ASTNode_t *r = SBML_parseL3Formula("(3/4)");

  fail_unless( ASTNode_getType       (r) == AST_RATIONAL, NULL );
  fail_unless( ASTNode_getNumerator  (r) ==   3, NULL );
  fail_unless( ASTNode_getDenominator(r) ==   4, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational2)
{
  ASTNode_t *r = SBML_parseL3Formula("(3/4) mL");

  fail_unless( ASTNode_getType       (r) == AST_RATIONAL, NULL );
  fail_unless( ASTNode_getNumerator  (r) ==   3, NULL );
  fail_unless( ASTNode_getDenominator(r) ==   4, NULL );
  fail_unless( !strcmp(ASTNode_getUnits(r), "mL"), NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational3)
{
  ASTNode_t *r = SBML_parseL3Formula("3/4");

  fail_unless( ASTNode_getType       (r) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational4)
{
  ASTNode_t *r = SBML_parseL3Formula("(3/x)");

  fail_unless( ASTNode_getType       (r) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational5)
{
  ASTNode_t *r = SBML_parseL3Formula("(3/4.4)");

  fail_unless( ASTNode_getType       (r) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_rational6)
{
  ASTNode_t *r = SBML_parseL3Formula("3/4 ml");

  fail_unless( ASTNode_getType       (r) == AST_DIVIDE, NULL );
  fail_unless( ASTNode_getCharacter  (r) == '/', NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 4, NULL );
  fail_unless( !strcmp(ASTNode_getUnits(c), "ml"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST



START_TEST (test_SBML_C_parseL3Formula_rational7)
{
  ASTNode_t *r = SBML_parseL3Formula("(3/4.4) ml");

  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input '(3/4.4) ml' at position 10:  syntax error, unexpected element name"), NULL );
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants1)
{
  ASTNode_t *r = SBML_parseL3Formula("true");
  fail_unless( ASTNode_getType       (r) == AST_CONSTANT_TRUE, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants2)
{
  ASTNode_t *r = SBML_parseL3Formula("false");
  fail_unless( ASTNode_getType       (r) == AST_CONSTANT_FALSE, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants3)
{
  ASTNode_t *r = SBML_parseL3Formula("pi");
  fail_unless( ASTNode_getType       (r) == AST_CONSTANT_PI, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants4)
{
  ASTNode_t *r = SBML_parseL3Formula("exponentiale");
  fail_unless( ASTNode_getType       (r) == AST_CONSTANT_E, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants5)
{
  ASTNode_t *r = SBML_parseL3Formula("avogadro");
  fail_unless( ASTNode_getType       (r) == AST_NAME_AVOGADRO, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants6)
{
  ASTNode_t *r = SBML_parseL3Formula("time");
  fail_unless( ASTNode_getType       (r) == AST_NAME_TIME, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants7)
{
  ASTNode_t *r = SBML_parseL3Formula("inf");
  fail_unless( ASTNode_getType(r)             == AST_REAL, NULL );
  fail_unless( util_isInf(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r)      ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants8)
{
  ASTNode_t *r = SBML_parseL3Formula("infinity");
  fail_unless( ASTNode_getType(r)             == AST_REAL, NULL );
  fail_unless( util_isInf(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r)      ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants9)
{
  ASTNode_t *r = SBML_parseL3Formula("INF");
  fail_unless( ASTNode_getType(r)             == AST_REAL, NULL );
  fail_unless( util_isInf(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r)      ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants10)
{
  ASTNode_t *r = SBML_parseL3Formula("notanumber");
  fail_unless( ASTNode_getType(r)        == AST_REAL, NULL );
  fail_unless( util_isNaN(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants11)
{
  ASTNode_t *r = SBML_parseL3Formula("nan");
  fail_unless( ASTNode_getType(r)        == AST_REAL, NULL );
  fail_unless( util_isNaN(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_constants12)
{
  ASTNode_t *r = SBML_parseL3Formula("NaN");
  fail_unless( ASTNode_getType(r)        == AST_REAL, NULL );
  fail_unless( util_isNaN(ASTNode_getReal(r)) ==  1, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==  0, NULL );
  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modulo)
{
  ASTNode_t *r = SBML_parseL3Formula("x % y");
  //Instead of trying to go through everything individually, we'll just test the round-tripping:
  fail_unless( !strcmp(SBML_formulaToString(r), "piecewise(x - y * ceil(x / y), xor(lt(x, 0), lt(y, 0)), x - y * floor(x / y))"), NULL );
ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_oddMathML1)
{
  ASTNode_t *r = SBML_parseL3Formula("sqrt(3)");

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_ROOT, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_oddMathML2)
{
  ASTNode_t *r = SBML_parseL3Formula("sqr(3)");

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_POWER, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_oddMathML3)
{
  ASTNode_t *r = SBML_parseL3Formula("log10(3)");

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_LOG, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 10, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_oddMathML4)
{
  ASTNode_t *r = SBML_parseL3Formula("log(4.4, 3)");

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_LOG, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_oddMathML5)
{
  ASTNode_t *r = SBML_parseL3Formula("root(1.1, 3)");

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_ROOT, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_t *c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 1.1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent1)
{
  Model_t *model = Model_create(3,1);
  Parameter_t *p = Model_createParameter(model);
  Parameter_setId(p, "infinity");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("infinity", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "infinity") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent2)
{
  Model_t *model = Model_create(3,1);
  Species_t *p = Model_createSpecies(model);
  Species_setId(p, "true");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("true", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "true") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent3)
{
  Model_t *model = Model_create(3,1);
  Compartment_t *p = Model_createCompartment(model);
  Compartment_setId(p, "NaN");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("NaN", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "NaN") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent4)
{
  Model_t *model = Model_create(3,1);
  Reaction_t *p = Model_createReaction(model);
  Reaction_setId(p, "pi");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("pi", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "pi") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent5)
{
  Model_t *model = Model_create(3,1);
  Reaction_t *p = Model_createReaction(model);
  SpeciesReference_t * sr = Reaction_createProduct(p);
  SpeciesReference_setId(sr, "avogadro");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("avogadro", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "avogadro") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent6)
{
  Model_t *model = Model_create(3,1);
  Reaction_t *p = Model_createReaction(model);
  SpeciesReference_t* sr = Reaction_createProduct(p);
  SpeciesReference_setId(sr, "AVOGADRO"); 
  ASTNode_t *r = SBML_parseL3FormulaWithModel("avogadro", model);

  fail_unless( ASTNode_getType       (r) == AST_NAME_AVOGADRO, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "avogadro") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_modelPresent7)
{
  Model_t *model = Model_create(3,1);
  FunctionDefinition_t *p = Model_createFunctionDefinition(model);
  FunctionDefinition_setId(p, "sin");
  ASTNode_t *r = SBML_parseL3FormulaWithModel("sin(x, y)", model);

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "sin") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_arguments)
{
  ASTNode_t *r = SBML_parseL3Formula("sin(x,y)");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'sin(x,y)' at position 8:  The function 'sin' takes exactly one argument, but 2 were found."), NULL );

  r = SBML_parseL3Formula("delay(x)");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'delay(x)' at position 8:  The function 'delay' takes exactly two arguments, but 1 were found."), NULL );

  r = SBML_parseL3Formula("piecewise()");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'piecewise()' at position 11:  The function 'piecewise' takes at least one argument, but none were found."), NULL );

  r = SBML_parseL3Formula("gt(x)");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'gt(x)' at position 5:  The function 'gt' takes at least two arguments, but 1 were found."), NULL );

  r = SBML_parseL3Formula("minus()");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'minus()' at position 7:  The function 'minus' takes exactly one or two arguments, but 0 were found."), NULL );

  r = SBML_parseL3Formula("root(x, y, z)");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'root(x, y, z)' at position 13:  The function 'root' takes exactly one or two arguments, but 3 were found."), NULL );

  r = SBML_parseL3Formula("power()");
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'power()' at position 7:  The function 'power' takes exactly two arguments, but 0 were found."), NULL );
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_logic1)
{
  ASTNode_t *r = SBML_parseL3Formula("1 && 2 == 3");
  ASTNode_t *c;



  fail_unless( ASTNode_getType       (r) == AST_LOGICAL_AND, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "and") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_RELATIONAL_EQ, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "eq") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2  , NULL );

  c = ASTNode_getLeftChild(c);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getRightChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_logic2)
{
  ASTNode_t *r = SBML_parseL3Formula("(1 && 2) == 3");
  ASTNode_t *c;


  fail_unless( ASTNode_getType       (r) == AST_RELATIONAL_EQ, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "eq") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_LOGICAL_AND, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "and") , NULL );
  fail_unless( ASTNode_getNumChildren(c) == 2, NULL );

  c = ASTNode_getRightChild(r);

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 3, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getLeftChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 1, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild( ASTNode_getLeftChild(r) );

  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger   (c)  == 2, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_precedence)
{
  ASTNode_t *root = SBML_parseL3Formula("a && b == !(c - d * e^-f) ");
  ASTNode_t *left;
  ASTNode_t *right;

  fail_unless( ASTNode_getType       (root) == AST_LOGICAL_AND, NULL );
  fail_unless( !strcmp(ASTNode_getName(root), "and") , NULL );
  fail_unless( ASTNode_getNumChildren(root) == 2  , NULL );

  left = ASTNode_getLeftChild(root);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "a") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  right = ASTNode_getRightChild(root);

  fail_unless( ASTNode_getType       (right) == AST_RELATIONAL_EQ, NULL );
  fail_unless( !strcmp(ASTNode_getName(right), "eq") , NULL );
  fail_unless( ASTNode_getNumChildren(right) == 2  , NULL );

  left = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "b") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  right = ASTNode_getRightChild(right);

  fail_unless( ASTNode_getType       (right) == AST_LOGICAL_NOT, NULL );
  fail_unless( !strcmp(ASTNode_getName(right), "not") , NULL );
  fail_unless( ASTNode_getNumChildren(right) == 1, NULL );

  right = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (right) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (right) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(right) == 2, NULL );

  left = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "c") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  right = ASTNode_getRightChild(right);

  fail_unless( ASTNode_getType       (right) == AST_TIMES, NULL );
  fail_unless( ASTNode_getCharacter  (right) == '*', NULL );
  fail_unless( ASTNode_getNumChildren(right) == 2, NULL );

  left = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "d") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  right = ASTNode_getRightChild(right);

  fail_unless( ASTNode_getType       (right) == AST_POWER, NULL );
  fail_unless( ASTNode_getCharacter  (right) == '^', NULL );
  fail_unless( ASTNode_getNumChildren(right) == 2, NULL );

  left = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "e") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  right = ASTNode_getRightChild(right);

  fail_unless( ASTNode_getType       (right) == AST_MINUS, NULL );
  fail_unless( ASTNode_getCharacter  (right) == '-', NULL );
  fail_unless( ASTNode_getNumChildren(right) == 1, NULL );

  left = ASTNode_getLeftChild(right);

  fail_unless( ASTNode_getType       (left) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(left), "f") , NULL );
  fail_unless( ASTNode_getNumChildren(left) == 0, NULL );

  ASTNode_free(root);
}
END_TEST

  
START_TEST (test_SBML_C_parseL3Formula_parselogsettings)
{
  //Default:
  ASTNode_t *r = SBML_parseL3Formula("log(4.4)");
  ASTNode_t *c;

  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_LOG, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 10, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_t *settings = L3ParserSettings_create();

  //Explicit parsing as ln
  L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_LN);
  fail_unless(L3ParserSettings_getParseLog(settings) == L3P_PARSE_LOG_AS_LN);
  
  r = SBML_parseL3FormulaWithSettings("log(4.4)", settings);
  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_LN, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1  , NULL );

  c = ASTNode_getLeftChild(r);

  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);

  //Explicit parsing as log10
  L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_LOG10);
  fail_unless(L3ParserSettings_getParseLog(settings) == L3P_PARSE_LOG_AS_LOG10);

  r = SBML_parseL3FormulaWithSettings("log(4.4)", settings);
  fail_unless( ASTNode_getType       (r) == AST_FUNCTION_LOG, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (c) == 10, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);

  //Explicit setting as error
  L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_ERROR);
  fail_unless(L3ParserSettings_getParseLog(settings) == L3P_PARSE_LOG_AS_ERROR);

  r = SBML_parseL3FormulaWithSettings("log(4.4)", settings);

  fail_unless( r == NULL, NULL );
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input 'log(4.4)' at position 8:  Writing a function as 'log(x)' was legal in the L1 parser, but translated as the natural log, not the base-10 log.  This construct is disallowed entirely as being ambiguous, and you are encouraged instead to use 'ln(x)', 'log10(x)', or 'log(base, x)'."), NULL);

  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_collapseminussettings1)
{
  //Default:
  ASTNode_t *r = SBML_parseL3Formula("--4.4");
  ASTNode_t *c;

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();

  //Explicit parsing to collapse the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 1);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 1);

  r = SBML_parseL3FormulaWithSettings("--4.4", settings);
  fail_unless( ASTNode_getType       (r) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (r) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );

  ASTNode_free(r);

  //Explicit parsing to expand the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 0);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("--4.4", settings);

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_collapseminussettings2)
{
  //Default:
  ASTNode_t *r = SBML_parseL3Formula("--x");
  ASTNode_t *c;

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();

  //Explicit parsing to collapse the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 1);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 1);

  r = SBML_parseL3FormulaWithSettings("--x", settings);
  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );

  ASTNode_free(r);

  //Explicit parsing to expand the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 0);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("--x", settings);

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 1  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_collapseminussettings3)
{
  //Default:
  ASTNode_t *r = SBML_parseL3Formula("x---4.4");
  ASTNode_t *c;

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();

  //Explicit parsing to collapse the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 1);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 1);

  r = SBML_parseL3FormulaWithSettings("x---4.4", settings);
  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);

  //Explicit parsing to expand the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 0);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("x---4.4", settings);

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (c) == 4.4, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_collapseminussettings4)
{
  //Default:
  ASTNode_t *r = SBML_parseL3Formula("x---y");
  ASTNode_t *c;

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "y"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();

  //Explicit parsing to collapse the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 1);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 1);

  r = SBML_parseL3FormulaWithSettings("x---y", settings);
  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "y"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);

  //Explicit parsing to expand the minuses
  L3ParserSettings_setParseCollapseMinus(settings, 0);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("x---y", settings);

  fail_unless( ASTNode_getType       (r) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 2  , NULL );

  c = ASTNode_getLeftChild(r);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "x"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  c = ASTNode_getRightChild(r);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_MINUS, NULL );
  fail_unless( ASTNode_getNumChildren(c) == 1  , NULL );

  c = ASTNode_getLeftChild(c);
  fail_unless( ASTNode_getType       (c) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(c), "y"), NULL );
  fail_unless( ASTNode_getNumChildren(c) == 0, NULL );

  ASTNode_free(r);
  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_collapseminussettings5)
{
  ////Explicit parsing to collapse the minuses
  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();
  L3ParserSettings_setParseCollapseMinus(settings, 1);
  fail_unless(L3ParserSettings_getParseCollapseMinus(settings) == 1);

  ASTNode_t* r = SBML_parseL3FormulaWithSettings("---4", settings);
  fail_unless( ASTNode_getType       (r) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (r) == -4, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  r = SBML_parseL3FormulaWithSettings("---(3/8)", settings);
  fail_unless( ASTNode_getType       (r) == AST_RATIONAL, NULL );
  fail_unless( ASTNode_getNumerator  (r) == -3, NULL );
  fail_unless( ASTNode_getDenominator(r) == 8, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  r = SBML_parseL3FormulaWithSettings("---(-3/8)", settings);
  fail_unless( ASTNode_getType       (r) == AST_RATIONAL, NULL );
  fail_unless( ASTNode_getNumerator  (r) == 3, NULL );
  fail_unless( ASTNode_getDenominator(r) == 8, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  r = SBML_parseL3FormulaWithSettings("---4.4", settings);
  fail_unless( ASTNode_getType       (r) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (r) == -4.4, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  r = SBML_parseL3FormulaWithSettings("---4e-3", settings);
  fail_unless( ASTNode_getType       (r) == AST_REAL_E, NULL );
  fail_unless( ASTNode_getMantissa   (r) == -4, NULL );
  fail_unless( ASTNode_getExponent   (r) == -3, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  r = SBML_parseL3FormulaWithSettings("---.4", settings);
  fail_unless( ASTNode_getType       (r) == AST_REAL, NULL );
  fail_unless( ASTNode_getReal       (r) == -.4, NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0, NULL );
  ASTNode_free(r);

  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_avogadrosettings)
{
  ASTNode_t *r = SBML_parseL3Formula("avogadro");
  fail_unless( ASTNode_getType       (r) == AST_NAME_AVOGADRO, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);

  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();
  L3ParserSettings_setParseAvogadroCsymbol(settings, 0);
  fail_unless(L3ParserSettings_getParseAvogadroCsymbol(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("avogadro", settings);
  fail_unless( ASTNode_getType       (r) == AST_NAME, NULL );
  fail_unless( !strcmp(ASTNode_getName(r), "avogadro") , NULL );
  fail_unless( ASTNode_getNumChildren(r) == 0  , NULL );
  ASTNode_free(r);

  L3ParserSettings_setParseAvogadroCsymbol(settings, 1);
  fail_unless(L3ParserSettings_getParseAvogadroCsymbol(settings) == 1);

  r = SBML_parseL3FormulaWithSettings("avogadro", settings);
  fail_unless( ASTNode_getType       (r) == AST_NAME_AVOGADRO, NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);
  L3ParserSettings_free(settings);
}
END_TEST


START_TEST (test_SBML_C_parseL3Formula_unitssettings)
{
  ASTNode_t *r = SBML_parseL3Formula("4 mL");

  fail_unless( ASTNode_getType       (r) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (r) ==   4, NULL );
  fail_unless( !strcmp(ASTNode_getUnits(r), "mL"), NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);

  L3ParserSettings_t *settings = SBML_getDefaultL3ParserSettings();
  L3ParserSettings_setParseUnits(settings, 0);
  fail_unless(L3ParserSettings_getParseUnits(settings) == 0);

  r = SBML_parseL3FormulaWithSettings("4 mL", settings);
  fail_unless(r == NULL, NULL);
  fail_unless( !strcmp(SBML_getLastParseL3Error(), "Error when parsing input '4 mL' at position 4:  The ability to associate units with numbers has been disabled."), NULL );

  L3ParserSettings_setParseUnits(settings, 1);
  fail_unless(L3ParserSettings_getParseUnits(settings) == 1);
  r = SBML_parseL3FormulaWithSettings("4 mL", settings);
  fail_unless( ASTNode_getType       (r) == AST_INTEGER, NULL );
  fail_unless( ASTNode_getInteger    (r) ==   4, NULL );
  fail_unless( !strcmp(ASTNode_getUnits(r), "mL"), NULL );
  fail_unless( ASTNode_getNumChildren(r) ==   0, NULL );
  ASTNode_free(r);

  L3ParserSettings_free(settings);
}
END_TEST


Suite *
create_suite_L3FormulaParserC (void) 
{ 
  Suite *suite = suite_create("L3FormulaParserC");
  TCase *tcase = tcase_create("L3FormulaParserC");
 
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_1       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_2       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_3       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_4       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_5       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_6       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_7       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_8       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_9       );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_10      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_11      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_12      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_13      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_14      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_15      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_16      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_17      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_18      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_negInf  );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_negZero );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_e1      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_e2      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_e3      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_e4      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_e5      );
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational3);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational4);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational5);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational6);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_rational7);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants3);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants4);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants5);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants6);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants7);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants8);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants9);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants10);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants11);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_constants12);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modulo);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_oddMathML1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_oddMathML2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_oddMathML3);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_oddMathML4);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_oddMathML5);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent3);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent4);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent5);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent6);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_modelPresent7);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_arguments);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_logic1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_logic2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_precedence);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_parselogsettings);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_collapseminussettings1);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_collapseminussettings2);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_collapseminussettings3);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_collapseminussettings4);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_collapseminussettings5);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_avogadrosettings);
  tcase_add_test( tcase, test_SBML_C_parseL3Formula_unitssettings);

  suite_add_tcase(suite, tcase);

  return suite;
}

#if __cplusplus
CK_CPPEND
#endif
