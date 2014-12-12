/**
 * \file    TestWriteMathML.cpp
 * \brief   Write MathML unit tests
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
#include <cstring>
#include <cstdio>

#include <check.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/L3Parser.h>
#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>

/** @cond doxygenIgnored */

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
#define MATHML_HEADER_UNITS_ALT  " xmlns:foo=\"http://www.sbml.org/sbml/level3/version1/core\">\n"
#define MATHML_FOOTER "</math>"

#define wrapMathML(s)   XML_HEADER MATHML_HEADER s MATHML_FOOTER
#define wrapMathMLUnits(s)  XML_HEADER MATHML_HEADER_UNITS MATHML_HEADER_UNITS2 s MATHML_FOOTER
#define wrapMathMLUnitsOtherPrefix(s)  XML_HEADER MATHML_HEADER_UNITS MATHML_HEADER_UNITS_ALT s MATHML_FOOTER


static ASTNode* N;
static char*    S;


void
WriteMathML_setup ()
{
  N = NULL;
  S = NULL;
}


void
WriteMathML_teardown ()
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


START_TEST (test_MathMLFormatter_cn_real_1)
{
  const char *expected = wrapMathML("  <cn> 1.2 </cn>\n");

  N = SBML_parseFormula("1.2");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_real_2)
{
  const char* expected = wrapMathML("  <cn> 1234567.8 </cn>\n");

  N = SBML_parseFormula("1234567.8");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_real_3)
{
  const char* expected = wrapMathML("  <cn> -3.14 </cn>\n");

  N = SBML_parseFormula("-3.14");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_real_locale)
{
  const char* expected = wrapMathML("  <cn> 2.72 </cn>\n");


  setlocale(LC_NUMERIC, "de_DE");

  N = SBML_parseFormula("2.72");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

  setlocale(LC_NUMERIC, "C");
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_1)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 0 <sep/> 3 </cn>\n"
  );

  N = SBML_parseFormula("0e3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_2)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 2 <sep/> 3 </cn>\n"
  );

  N = SBML_parseFormula("2e3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_3)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 1234567.8 <sep/> 3 </cn>\n"
  );

  N = SBML_parseFormula("1234567.8e3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_4)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 6.0221367 <sep/> 23 </cn>\n"
  );

  N = SBML_parseFormula("6.0221367e+23");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_5)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 4 <sep/> -6 </cn>\n"
  );

  N = SBML_parseFormula(".000004");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_6)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> 4 <sep/> -12 </cn>\n"
  );

  N = SBML_parseFormula(".000004e-6");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_e_notation_7)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"e-notation\"> -1 <sep/> -6 </cn>\n"
  );

  N = SBML_parseFormula("-1e-6");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_integer)
{
  const char* expected = wrapMathML("  <cn type=\"integer\"> 5 </cn>\n");

  N = SBML_parseFormula("5");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_rational)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"rational\"> 1 <sep/> 3 </cn>\n"
  );

  N = new ASTNode;
  N->setValue(static_cast<long>(1), 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_ci)
{
  const char* expected = wrapMathML("  <ci> foo </ci>\n");

  N = SBML_parseFormula("foo");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_csymbol_delay)
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

  N = SBML_parseFormula("delay(x, 0.1)");
  N->setName("my_delay");

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_csymbol_time)
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


START_TEST (test_MathMLFormatter_constant_true)
{
  const char* expected = wrapMathML("  <true/>\n");

  N = new ASTNode(AST_CONSTANT_TRUE);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_constant_false)
{
  const char* expected = wrapMathML("  <false/>\n");

  N = new ASTNode(AST_CONSTANT_FALSE);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_constant_notanumber)
{
  const char* expected = wrapMathML("  <notanumber/>\n");

  N = new ASTNode(AST_REAL);
  N->setValue( numeric_limits<double>::quiet_NaN() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_constant_infinity)
{
  const char* expected = wrapMathML("  <infinity/>\n");

  N = new ASTNode;
  N->setValue( numeric_limits<double>::infinity() );

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_constant_infinity_neg)
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


START_TEST (test_MathMLFormatter_constant_exponentiale)
{
  const char* expected = wrapMathML("  <exponentiale/>\n");

  N = new ASTNode(AST_CONSTANT_E);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_plus_binary)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <plus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "  </apply>\n"
  );

  N = SBML_parseFormula("1 + 2");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_plus_nary_1)
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

  N = SBML_parseFormula("1 + 2 + 3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_plus_nary_2)
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

  N = SBML_parseFormula("(1 + 2) + 3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_plus_nary_3)
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

  N = SBML_parseFormula("1 + (2 + 3)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_plus_nary_4)
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

  N = SBML_parseFormula("1 + 2 + x * y * z + 3");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_minus)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <cn type=\"integer\"> 1 </cn>\n"
    "    <cn type=\"integer\"> 2 </cn>\n"
    "  </apply>\n"
  );

  N = SBML_parseFormula("1 - 2");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_minus_unary_1)
{
  const char* expected = wrapMathML
  (
    "  <cn type=\"integer\"> -2 </cn>\n"
  );

  N = SBML_parseFormula("-2");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_minus_unary_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <minus/>\n"
    "    <ci> a </ci>\n"
    "  </apply>\n"
  );

  N = SBML_parseFormula("-a");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_function_1)
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

  N = SBML_parseFormula("foo(1, 2, 3)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_function_2)
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

  N = SBML_parseFormula("foo(1, 2, bar(z))");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_sin)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <sin/>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  N = SBML_parseFormula("sin(x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_log)
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

  N = SBML_parseFormula("log(2, N)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_root)
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

  N = SBML_parseFormula("root(3, x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_lambda)
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
    "      <root/>\n"
    "      <degree>\n"
    "        <cn type=\"integer\"> 2 </cn>\n"
    "      </degree>\n"
    "      <apply>\n"
    "        <plus/>\n"
    "        <apply>\n"
    "          <power/>\n"
    "          <ci> x </ci>\n"
    "          <cn type=\"integer\"> 2 </cn>\n"
    "        </apply>\n"
    "        <apply>\n"
    "          <power/>\n"
    "          <ci> y </ci>\n"
    "          <cn type=\"integer\"> 2 </cn>\n"
    "        </apply>\n"
    "      </apply>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  N = SBML_parseFormula("lambda(x, y, root(2, x^2 + y^2))");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_lambda_no_bvars)
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

  N = SBML_parseFormula("lambda(2 + 2)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_piecewise)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <apply>\n"
    "        <minus/>\n"
    "        <ci> x </ci>\n"
    "      </apply>\n"
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
    "    <piece>\n"
    "      <ci> x </ci>\n"
    "      <apply>\n"
    "        <gt/>\n"
    "        <ci> x </ci>\n" 
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char *f = "piecewise(-x, lt(x, 0), 0, eq(x, 0), x, gt(x, 0))";

  N = SBML_parseFormula(f);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_piecewise_otherwise)
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

  N = SBML_parseFormula("piecewise(0, lt(x, 0), x)");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_semantics)
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

  N = SBML_parseFormula("lt(x, 0)");
  N->addSemanticsAnnotation(NULL);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_semantics_url)
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
  
  N = SBML_parseFormula("lt(x, 0)");
  N->addSemanticsAnnotation(NULL);
  N->setDefinitionURL(*xa);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_semantics_ann)
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
  
  N = SBML_parseFormula("lt(x, 0)");
  //N->setSemanticsFlag();
  N->addSemanticsAnnotation(ann);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_semantics_annxml)
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
  
  N = SBML_parseFormula("lt(x, 0)");
  //N->setSemanticsFlag();
  N->addSemanticsAnnotation(ann);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_cn_units)
{
  const char *expected = wrapMathMLUnits("  <cn sbml:units=\"mole\"> 1.2 </cn>\n");

  N = SBML_parseFormula("1.2");
  N->setUnits("mole");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_apply_cn_units)
{
  const char *expected = wrapMathMLUnits("  <apply>\n    <divide/>\n    <cn sbml:units=\"mole\" type=\"integer\"> 3 </cn>\n    <cn sbml:units=\"dimensionless\" type=\"integer\"> 4 </cn>\n  </apply>\n");

  N = SBML_parseL3Formula("3 mole / 4 dimensionless");
  //N->setUnits("mole");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_apply_cn_units_old)
{
  const char *expected = wrapMathMLUnits("  <apply>\n    <divide/>\n    <cn sbml:units=\"mole\" type=\"integer\"> 3 </cn>\n    <cn sbml:units=\"dimensionless\" type=\"integer\"> 4 </cn>\n  </apply>\n");

  N = SBML_parseFormula("3 / 4");
  N->getChild(0)->setUnits("mole");
  N->getChild(1)->setUnits("dimensionless");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_apply_cn_units_1)
{
  const char *expected = wrapMathMLUnitsOtherPrefix("  <apply>\n    <divide/>\n    <cn foo:units=\"mole\" type=\"integer\"> 3 </cn>\n    <cn foo:units=\"dimensionless\" type=\"integer\"> 4 </cn>\n  </apply>\n");

  N = readMathMLFromString(expected);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_MathMLFormatter_csymbol_avogadro)
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


START_TEST (test_MathMLFormatter_ci_definitionURL)
{
  const char* expected = wrapMathML("  <ci definitionURL=\"http://someurl\"> foo </ci>\n");

  N = SBML_parseFormula("foo");
  XMLAttributes xml;
  xml.add("", "http://someurl");
  N->setDefinitionURL(xml);
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFormatter_ci_id)
{
  const char* expected = wrapMathML("  <ci id=\"test\"> foo </ci>\n");

  N = SBML_parseFormula("foo");
  N->setId("test");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFormatter_ci_class)
{
  const char* expected = wrapMathML("  <ci class=\"test\"> foo </ci>\n");

  N = SBML_parseFormula("foo");
  N->setClass("test");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST

START_TEST (test_MathMLFormatter_ci_style)
{
  const char* expected = wrapMathML("  <ci style=\"test\"> foo </ci>\n");

  N = SBML_parseFormula("foo");
  N->setStyle("test");
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


Suite *
create_suite_WriteMathML ()
{
  Suite *suite = suite_create("WriteMathML");
  TCase *tcase = tcase_create("WriteMathML");

  tcase_add_checked_fixture(tcase, WriteMathML_setup, WriteMathML_teardown);

  tcase_add_test( tcase, test_MathMLFormatter_cn_real_1             );
  tcase_add_test( tcase, test_MathMLFormatter_cn_real_2             );
  tcase_add_test( tcase, test_MathMLFormatter_cn_real_3             );
  tcase_add_test( tcase, test_MathMLFormatter_cn_real_locale        );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_1       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_2       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_3       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_4       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_5       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_6       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_e_notation_7       );
  tcase_add_test( tcase, test_MathMLFormatter_cn_integer            );
  tcase_add_test( tcase, test_MathMLFormatter_cn_rational           );

  tcase_add_test( tcase, test_MathMLFormatter_ci                    );
  tcase_add_test( tcase, test_MathMLFormatter_csymbol_delay         );
  tcase_add_test( tcase, test_MathMLFormatter_csymbol_time          );
  tcase_add_test( tcase, test_MathMLFormatter_constant_true         );
  tcase_add_test( tcase, test_MathMLFormatter_constant_false        );
  tcase_add_test( tcase, test_MathMLFormatter_constant_notanumber   );
  tcase_add_test( tcase, test_MathMLFormatter_constant_infinity     );
  tcase_add_test( tcase, test_MathMLFormatter_constant_infinity_neg );
  tcase_add_test( tcase, test_MathMLFormatter_constant_exponentiale );
  tcase_add_test( tcase, test_MathMLFormatter_plus_binary           );
  tcase_add_test( tcase, test_MathMLFormatter_plus_nary_1           );
  tcase_add_test( tcase, test_MathMLFormatter_plus_nary_2           );
  tcase_add_test( tcase, test_MathMLFormatter_plus_nary_3           );
  tcase_add_test( tcase, test_MathMLFormatter_plus_nary_4           );
  tcase_add_test( tcase, test_MathMLFormatter_minus                 );
  tcase_add_test( tcase, test_MathMLFormatter_minus_unary_1         );
  tcase_add_test( tcase, test_MathMLFormatter_minus_unary_2         );
  tcase_add_test( tcase, test_MathMLFormatter_function_1            );
  tcase_add_test( tcase, test_MathMLFormatter_function_2            );
  tcase_add_test( tcase, test_MathMLFormatter_sin                   );
  tcase_add_test( tcase, test_MathMLFormatter_log                   );
  tcase_add_test( tcase, test_MathMLFormatter_root                  );
  tcase_add_test( tcase, test_MathMLFormatter_lambda                );
  tcase_add_test( tcase, test_MathMLFormatter_lambda_no_bvars       );
  tcase_add_test( tcase, test_MathMLFormatter_piecewise             );
  tcase_add_test( tcase, test_MathMLFormatter_piecewise_otherwise   );

  tcase_add_test( tcase, test_MathMLFormatter_semantics             );
  tcase_add_test( tcase, test_MathMLFormatter_semantics_url         );
  tcase_add_test( tcase, test_MathMLFormatter_semantics_ann         );
  tcase_add_test( tcase, test_MathMLFormatter_semantics_annxml      );

  /* L3 additions */
  tcase_add_test( tcase, test_MathMLFormatter_cn_units                 );
  tcase_add_test( tcase, test_MathMLFormatter_apply_cn_units           );
  tcase_add_test( tcase, test_MathMLFormatter_apply_cn_units_old       );
  tcase_add_test( tcase, test_MathMLFormatter_apply_cn_units_1         );

  tcase_add_test( tcase, test_MathMLFormatter_csymbol_avogadro         );
  tcase_add_test( tcase, test_MathMLFormatter_ci_definitionURL         );
  tcase_add_test( tcase, test_MathMLFormatter_ci_id                    );
  tcase_add_test( tcase, test_MathMLFormatter_ci_class                 );
  tcase_add_test( tcase, test_MathMLFormatter_ci_style                 );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
