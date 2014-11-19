/**
 * \file    TestReadMathML.cpp
 * \brief   Read MathML unit tests
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

#include <iostream>
#include <cstring>
#include <check.h>

#include <sbml/util/util.h>

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

#include <sbml/xml/XMLNode.h>

LIBSBML_CPP_NAMESPACE_USE

/**
 * Wraps the string s in the appropriate XML or MathML boilerplate.
 */
#define XML_HEADER     "<?xml version='1.0' encoding='UTF-8'?>\n"
#define MATHML_HEADER  "<math xmlns='http://www.w3.org/1998/Math/MathML'>\n"
#define MATHML_HEADER_UNITS  "<math xmlns='http://www.w3.org/1998/Math/MathML'\n"
#define MATHML_HEADER_UNITS2  " xmlns:sbml='http://www.sbml.org/sbml/level3/version1/core'>\n"
#define MATHML_FOOTER  "</math>"

#define wrapXML(s)     XML_HEADER s
#define wrapMathML(s)  XML_HEADER MATHML_HEADER s MATHML_FOOTER
#define wrapMathMLUnits(s)  XML_HEADER MATHML_HEADER_UNITS MATHML_HEADER_UNITS2 s MATHML_FOOTER


static ASTNode* N;
static char*    F;


static void
ReadMathML_setup ()
{
  N = NULL;
  F = NULL;
}


static void
ReadMathML_teardown ()
{
  delete N;
  free(F);
}


CK_CPPSTART


START_TEST (test_element_math)
{
  const char* s = wrapXML
  (
    "<math xmlns='http://www.w3.org/1998/Math/MathML'/>"
  );

  N = readMathMLFromString(s);

  fail_unless(N != NULL);
  fail_unless(N->getType() == AST_UNKNOWN);
}
END_TEST


START_TEST (test_element_cn_default)
{
  const char* s = wrapMathML("<cn> 12345.7 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST


START_TEST (test_element_cn_real)
{
  const char* s = wrapMathML("<cn type='real'> 12345.7 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST


START_TEST (test_element_cn_integer)
{
  const char* s = wrapMathML("<cn type='integer'> 12345 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_INTEGER );
  fail_unless( N->getInteger()     == 12345 );
  fail_unless( N->getNumChildren() == 0     );
}
END_TEST


START_TEST (test_element_cn_rational)
{
  const char* s = wrapMathML
  (
    "<cn type='rational'> 12342 <sep/> 2342342 </cn>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );


  fail_unless( N->getType()        == AST_RATIONAL );
  fail_unless( N->getNumerator()   == 12342   );
  fail_unless( N->getDenominator() == 2342342 );
  fail_unless( N->getNumChildren() == 0       );
}
END_TEST


START_TEST (test_element_cn_e_notation)
{
  const char* s = wrapMathML("<cn type='e-notation'> 12.3 <sep/> 5 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL_E );
  fail_unless( N->getMantissa()    == 12.3 );
  fail_unless( N->getExponent()    == 5    );
  fail_unless( N->getNumChildren() == 0    );
}
END_TEST


START_TEST (test_element_ci)
{
  const char* s = wrapMathML("<ci> x </ci>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_NAME   );
  fail_unless( !strcmp(N->getName(), "x") );
  fail_unless( N->getNumChildren() == 0   );
}
END_TEST


START_TEST (test_element_ci_surrounding_spaces_bug)
{
  const char* s = wrapMathML("  <ci> s </ci>  ");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_NAME   );
  fail_unless( !strcmp(N->getName(), "s") );
  fail_unless( N->getNumChildren() == 0   );
}
END_TEST


START_TEST (test_element_csymbol_time)
{
  const char* s = wrapMathML
  (
    "<csymbol encoding='text' "
    "definitionURL='http://www.sbml.org/sbml/symbols/time'> t </csymbol>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_NAME_TIME );
  fail_unless( !strcmp(N->getName(), "t")    );
  fail_unless( N->getNumChildren() == 0      );
}
END_TEST


START_TEST (test_element_csymbol_delay_1)
{
  const char* s = wrapMathML
  (
    "<csymbol encoding='text' "
    "definitionURL='http://www.sbml.org/sbml/symbols/delay'> delay </csymbol>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_FUNCTION_DELAY );
  fail_unless( !strcmp(N->getName(), "delay") );
  fail_unless( N->getNumChildren() == 0       );
}
END_TEST


START_TEST (test_element_csymbol_delay_2)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <csymbol encoding='text' definitionURL='http://www.sbml.org/sbml/"
    "symbols/delay'> my_delay </csymbol>"
    "  <ci> x </ci>"
    "  <cn> 0.1 </cn>"
    "</apply>\n"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "my_delay(x, 0.1)") );
}
END_TEST


START_TEST (test_element_csymbol_delay_3)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <power/>"
    "  <apply>"
    "    <csymbol encoding='text' definitionURL='http://www.sbml.org/sbml/"
    "symbols/delay'> delay </csymbol>"
    "    <ci> P </ci>"
    "    <ci> delta_t </ci>"
    "  </apply>\n"
    "  <ci> q </ci>"
    "</apply>\n"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "pow(delay(P, delta_t), q)") );
}
END_TEST


START_TEST (test_element_csymbol_delay_4)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <csymbol encoding='text' definitionURL='http://www.sbml.org/sbml/"
    "symbols/delay'> my_delay </csymbol>"
    "  <ci> x </ci>"
    "</apply>\n"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "my_delay(x)") );
}
END_TEST


START_TEST (test_element_constants_true)
{
  const char* s = wrapMathML("<true/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_CONSTANT_TRUE );
  fail_unless( N->getNumChildren() == 0 );
}
END_TEST


START_TEST (test_element_constants_false)
{
  const char* s = wrapMathML("<false/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_CONSTANT_FALSE );
  fail_unless( N->getNumChildren() == 0 );
}
END_TEST


START_TEST (test_element_constants_notanumber)
{
#define test_isnan(x) (x != x)  // necessary to avoid peculiar MacOS X bug

  const char* s = wrapMathML("<notanumber/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_REAL );
  fail_unless( test_isnan(N->getReal()) );
  fail_unless( N->getNumChildren() == 0 );
}
END_TEST


START_TEST (test_element_constants_pi)
{
  const char* s = wrapMathML("<pi/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_CONSTANT_PI );
  fail_unless( N->getNumChildren() == 0 );
}
END_TEST


START_TEST (test_element_constants_infinity)
{
  const char* s = wrapMathML("<infinity/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_REAL      );
  fail_unless( util_isInf(N->getReal()) == 1 );
  fail_unless( N->getNumChildren() == 0      );
}
END_TEST


START_TEST (test_element_constants_exponentiale)
{
  const char* s = wrapMathML("<exponentiale/>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_CONSTANT_E );
  fail_unless( N->getNumChildren() == 0 );
}
END_TEST



START_TEST (test_element_operator_plus)
{
  const char* s = wrapMathML
  (
    "<apply> <plus/> <cn> 1 </cn> <cn> 2 </cn> <cn> 3 </cn> </apply>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "1 + 2 + 3") );
}
END_TEST


START_TEST (test_element_operator_times)
{
  const char* s = wrapMathML
  (
    "<apply> <times/> <ci> x </ci> <ci> y </ci> <ci> z </ci> </apply>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "x * y * z") );
}
END_TEST


START_TEST (test_element_abs)
{
  const char* s = wrapMathML("<apply><abs/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "abs(x)") );
}
END_TEST


START_TEST (test_element_and)
{
  const char* s = wrapMathML
  (
    "<apply> <and/> <ci>a</ci> <ci>b</ci> <ci>c</ci> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "and(a, b, c)") );
}
END_TEST


START_TEST (test_element_arccos)
{
  const char* s = wrapMathML("<apply><arccos/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "acos(x)") );
}
END_TEST


START_TEST (test_element_arccosh)
{
  const char* s = wrapMathML("<apply><arccosh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arccosh(x)") );
}
END_TEST


START_TEST (test_element_arccot)
{
  const char* s = wrapMathML("<apply><arccot/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arccot(x)") );
}
END_TEST


START_TEST (test_element_arccoth)
{
  const char* s = wrapMathML("<apply><arccoth/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arccoth(x)") );
}
END_TEST


START_TEST (test_element_arccsc)
{
  const char* s = wrapMathML("<apply><arccsc/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arccsc(x)") );
}
END_TEST


START_TEST (test_element_arccsch)
{
  const char* s = wrapMathML("<apply><arccsch/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arccsch(x)") );
}
END_TEST


START_TEST (test_element_arcsec)
{
  const char* s = wrapMathML("<apply><arcsec/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arcsec(x)") );
}
END_TEST


START_TEST (test_element_arcsech)
{
  const char* s = wrapMathML("<apply><arcsech/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arcsech(x)") );
}
END_TEST


START_TEST (test_element_arcsin)
{
  const char* s = wrapMathML("<apply><arcsin/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "asin(x)") );
}
END_TEST


START_TEST (test_element_arcsinh)
{
  const char* s = wrapMathML("<apply><arcsinh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arcsinh(x)") );
}
END_TEST


START_TEST (test_element_arctan)
{
  const char* s = wrapMathML("<apply><arctan/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "atan(x)") );
}
END_TEST


START_TEST (test_element_arctanh)
{
  const char* s = wrapMathML("<apply><arctanh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "arctanh(x)") );
}
END_TEST


START_TEST (test_element_ceiling)
{
  const char* s = wrapMathML("<apply><ceiling/><cn> 1.6 </cn></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "ceil(1.6)") );
}
END_TEST


START_TEST (test_element_cos)
{
  const char* s = wrapMathML("<apply><cos/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "cos(x)") );
}
END_TEST


START_TEST (test_element_cosh)
{
  const char* s = wrapMathML("<apply><cosh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "cosh(x)") );
}
END_TEST


START_TEST (test_element_cot)
{
  const char* s = wrapMathML("<apply><cot/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "cot(x)") );
}
END_TEST


START_TEST (test_element_coth)
{
  const char* s = wrapMathML("<apply><coth/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "coth(x)") );
}
END_TEST


START_TEST (test_element_csc)
{
  const char* s = wrapMathML("<apply><csc/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "csc(x)") );
}
END_TEST


START_TEST (test_element_csch)
{
  const char* s = wrapMathML("<apply><csch/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "csch(x)") );
}
END_TEST


START_TEST (test_element_eq)
{
  const char* s = wrapMathML
  (
    "<apply> <eq/> <ci>a</ci> <ci>b</ci> <ci>c</ci> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "eq(a, b, c)") );
}
END_TEST


START_TEST (test_element_exp)
{
  const char* s = wrapMathML("<apply><exp/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "exp(x)") );
}
END_TEST


START_TEST (test_element_factorial)
{
  const char* s = wrapMathML("<apply><factorial/><cn> 5 </cn></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "factorial(5)") );
}
END_TEST


START_TEST (test_element_floor)
{
  const char* s = wrapMathML("<apply><floor/><cn> 1.2 </cn></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "floor(1.2)") );
}
END_TEST


START_TEST (test_element_function_call_1)
{
  const char* s = wrapMathML("<apply> <ci> foo </ci> <ci> x </ci> </apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "foo(x)") );
}
END_TEST


START_TEST (test_element_function_call_2)
{
  const char* s = wrapMathML
  (
    "<apply> <plus/> <cn> 1 </cn>"
    "                <apply> <ci> f </ci> <ci> x </ci> </apply>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "1 + f(x)") );
}
END_TEST


START_TEST (test_element_geq)
{
  const char* s = wrapMathML
  (
    "<apply> <geq/> <cn>1</cn> <ci>x</ci> <cn>0</cn> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "geq(1, x, 0)") );
}
END_TEST


START_TEST (test_element_gt)
{
  const char* s = wrapMathML
  (
    "<apply> <gt/> <infinity/>"
    "              <apply> <minus/> <infinity/> <cn>1</cn> </apply>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "gt(INF, INF - 1)") );
}
END_TEST


START_TEST (test_element_lambda)
{
  const char* s = wrapMathML
  (
    "<lambda>"
    "  <bvar> <ci>x</ci> </bvar>"
    "  <apply> <sin/>"
    "          <apply> <plus/> <ci>x</ci> <cn>1</cn> </apply>"
    "  </apply>"
    "</lambda>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "lambda(x, sin(x + 1))") );
}
END_TEST


START_TEST (test_element_leq)
{
  const char* s = wrapMathML
  (
    "<apply> <leq/> <cn>0</cn> <ci>x</ci> <cn>1</cn> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "leq(0, x, 1)") );
}
END_TEST


START_TEST (test_element_ln)
{
  const char* s = wrapMathML("<apply><ln/><ci> a </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "log(a)") );
}
END_TEST


START_TEST (test_element_log_1)
{
  const char* s = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "log(3, x)") );
}
END_TEST


START_TEST (test_element_log_2)
{
  const char* s = wrapMathML("<apply> <log/> <ci> x </ci> </apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "log10(x)") );
}
END_TEST


START_TEST (test_element_lt)
{
  const char* s = wrapMathML
  (
    "<apply> <lt/> <apply> <minus/> <infinity/> <infinity/> </apply>"
    "              <cn>1</cn>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "lt(INF - INF, 1)") );
}
END_TEST


START_TEST (test_element_neq)
{
  const char* s = wrapMathML
  (
    "<apply> <neq/> <notanumber/> <notanumber/> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "neq(NaN, NaN)") );
}
END_TEST


START_TEST (test_element_not)
{
  const char* s = wrapMathML("<apply> <not/> <ci> TooShabby </ci> </apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "not(TooShabby)") );
}
END_TEST


START_TEST (test_element_or)
{
  const char* s = wrapMathML
  (
    "<apply> <or/> <ci>a</ci> <ci>b</ci> <ci>c</ci> <ci>d</ci> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "or(a, b, c, d)") );
}
END_TEST


START_TEST (test_element_piecewise)
{
  const char* s = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <apply> <minus/> <ci>x</ci> </apply>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <ci>x</ci>"
    "    <apply> <gt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "piecewise(-x, lt(x, 0), 0, eq(x, 0), x, gt(x, 0))"),
               NULL );
}
END_TEST


START_TEST (test_element_piecewise_otherwise)
{
  const char* s = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <otherwise>"
    "    <ci>x</ci>"
    "  </otherwise>"
    "</piecewise>"
  );

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "piecewise(0, lt(x, 0), x)") );
}
END_TEST


START_TEST (test_element_piecewise_no_args_1)
{
  const char* s = wrapMathML
  (
    "<piecewise>"
    "</piecewise>"
  );

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "piecewise()"),
               NULL );
}
END_TEST


START_TEST (test_element_piecewise_no_args_2)
{
  const char* s = wrapMathML
  (
    "<piecewise/>"
  );

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "piecewise()"),
               NULL );
}
END_TEST


START_TEST (test_element_piecewise_one_arg)
{
  const char* s = wrapMathML
  (
    "<piecewise>"
    "  <otherwise>"
    "    <ci>x</ci>"
    "  </otherwise>"
    "</piecewise>"
  );

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "piecewise(x)"),
               NULL );
}
END_TEST


START_TEST (test_element_power)
{
  const char* s = wrapMathML("<apply><power/> <ci>x</ci> <cn>3</cn> </apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "pow(x, 3)") );
}
END_TEST


START_TEST (test_element_root_1)
{
  const char* s = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> a </ci>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "root(3, a)") );
}
END_TEST


START_TEST (test_element_root_2)
{
  const char* s = wrapMathML("<apply> <root/> <ci> a </ci> </apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "sqrt(a)") );
}
END_TEST


START_TEST (test_element_sec)
{
  const char* s = wrapMathML("<apply><sec/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "sec(x)") );
}
END_TEST


START_TEST (test_element_sech)
{
  const char* s = wrapMathML("<apply><sech/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "sech(x)") );
}
END_TEST


START_TEST (test_element_sin)
{
  const char* s = wrapMathML("<apply><sin/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "sin(x)") );
}
END_TEST


START_TEST (test_element_sinh)
{
  const char* s = wrapMathML("<apply><sinh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "sinh(x)") );
}
END_TEST


START_TEST (test_element_tan)
{
  const char* s = wrapMathML("<apply><tan/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "tan(x)") );
}
END_TEST


START_TEST (test_element_tanh)
{
  const char* s = wrapMathML("<apply><tanh/><ci> x </ci></apply>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "tanh(x)") );
}
END_TEST


START_TEST (test_element_xor)
{
  const char* s = wrapMathML
  (
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "xor(a, b, b, a)") );
}
END_TEST


START_TEST (test_element_semantics)
{
  const char* s = wrapMathML
  (
  "<semantics> <apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply> </semantics>"
  );


  N = readMathMLFromString(s);

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N != NULL );


  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "xor(a, b, b, a)") );
}
END_TEST


START_TEST (test_element_semantics_URL)
{
  const char* s = wrapMathML
  (
    "<semantics definitionURL='foobar'>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "</semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getDefinitionURL()->getValue(0) == "foobar");

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "xor(a, b, b, a)") );
}
END_TEST


START_TEST (test_element_semantics_annotation)
{
  const char* s = wrapMathML
  (
    "<semantics>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "<annotation encoding='Mathematica'> N[23] </annotation>"
    "</semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getNumSemanticsAnnotations() == 1);

  std::string ann1 = XMLNode::convertXMLNodeToString(N->getSemanticsAnnotation(0));
  std::string annotation = "<annotation encoding=\"Mathematica\"> N[23] </annotation>";
  fail_unless( ann1 == annotation );
}
END_TEST


START_TEST (test_element_semantics_annxml)
{
  const char* s = wrapMathML
  (
    "<semantics>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "<annotation-xml encoding='OpenMath'>"
    "<OMA xmlns=\"http://www.openmath.org/OpenMath\">"
    "<OMS cd=\"arith1\" name=\"divide\"/>"
    "<OMI>123</OMI>"
    "<OMI>456</OMI>"
    "</OMA>"
    "</annotation-xml>"
    "</semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getNumSemanticsAnnotations() == 1);

  std::string ann1 = XMLNode::convertXMLNodeToString(N->getSemanticsAnnotation(0));
  std::string annotation = 
    "<annotation-xml encoding=\"OpenMath\">\n"
    "  <OMA xmlns=\"http://www.openmath.org/OpenMath\">\n"
    "    <OMS cd=\"arith1\" name=\"divide\"/>\n"
    "    <OMI>123</OMI>\n"
    "    <OMI>456</OMI>\n"
    "  </OMA>\n"
    "</annotation-xml>";
  fail_unless( ann1 == annotation );
}
END_TEST


START_TEST (test_element_semantics_lambda)
{
  const char* s = wrapMathML
  (
  "<semantics>"
  "<lambda> <bvar> <ci> a </ci> </bvar>"
  "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
  "</lambda>  </semantics>"
  );


  N = readMathMLFromString(s);

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N != NULL );


  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "lambda(a, xor(a, b, b, a))") );
}
END_TEST


START_TEST (test_element_semantics_URL_lambda)
{
  const char* s = wrapMathML
  (
    "<semantics definitionURL='foobar'>"
    "<lambda> <bvar> <ci> a </ci> </bvar>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "</lambda> </semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getDefinitionURL()->getValue(0) == "foobar");

  F = SBML_formulaToString(N);
  fail_unless( !strcmp(F, "lambda(a, xor(a, b, b, a))") );
}
END_TEST


START_TEST (test_element_semantics_ann_lambda)
{
  const char* s = wrapMathML
  (
    "<semantics> <lambda> <bvar> <ci> a </ci> </bvar>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "</lambda>"
    "<annotation encoding='Mathematica'> N[23] </annotation>"
    "</semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getNumSemanticsAnnotations() == 1);

  std::string ann1 = XMLNode::convertXMLNodeToString(N->getSemanticsAnnotation(0));
  std::string annotation = "<annotation encoding=\"Mathematica\"> N[23] </annotation>";
  fail_unless( ann1 == annotation );
}
END_TEST


START_TEST (test_element_semantics_annxml_lambda)
{
  const char* s = wrapMathML
  (
  "<semantics> <lambda> <bvar> <ci> a </ci> </bvar>"
    "<apply> <xor/> <ci>a</ci> <ci>b</ci> <ci>b</ci> <ci>a</ci> </apply>"
    "</lambda>"
    "<annotation-xml encoding='OpenMath'>"
    "<OMA xmlns=\"http://www.openmath.org/OpenMath\">"
    "<OMS cd=\"arith1\" name=\"divide\"/>"
    "<OMI>123</OMI>"
    "<OMI>456</OMI>"
    "</OMA>"
    "</annotation-xml>"
    "</semantics>"
  );



  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getSemanticsFlag() == true );
  fail_unless( N->getNumSemanticsAnnotations() == 1);

  std::string ann1 = XMLNode::convertXMLNodeToString(N->getSemanticsAnnotation(0));
  std::string annotation = 
    "<annotation-xml encoding=\"OpenMath\">\n"
    "  <OMA xmlns=\"http://www.openmath.org/OpenMath\">\n"
    "    <OMS cd=\"arith1\" name=\"divide\"/>\n"
    "    <OMI>123</OMI>\n"
    "    <OMI>456</OMI>\n"
    "  </OMA>\n"
    "</annotation-xml>";
  fail_unless( ann1 == annotation );
}
END_TEST


//
// libSBML Expat was not correctly interpreting XML namespace prefixes or
// their corresponding qualified element names.  That is, while the
// following common case was parsed correctly:
//
//   <math xmlns='http://www.w3.org/1998/Math/MathML'>
//     <apply>
//     ...
//
// The less common qualified name case was not parsed correctly:
//
//   <math:math xmlns:math='http://www.w3.org/1998/Math/MathML'>
//     <math:apply>
//     ...
//
// regardless of whether the 'math' namespace prefix was defined on <math>
// element or a parent element.
//
// While this bug was not specific to MathML handling (indeed it applied to
// XML namespace handling in general), the bug was first reported in a
// MathML context, hence this test.
//
//
// Reported by Ben S. Skrainka <bss@skrainka.biz> on 29-Apr-05
//
START_TEST (test_element_bug_math_xmlns)
{
  const char* s = wrapXML
  (
    "<foo:math xmlns:foo='http://www.w3.org/1998/Math/MathML'>"
    "  <foo:apply>"
    "    <foo:plus/> <foo:cn>1</foo:cn> <foo:cn>2</foo:cn>"
    "  </foo:apply>"
    "</foo:math>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  F = SBML_formulaToString(N);

  fail_unless( !strcmp(F, "1 + 2") );
}
END_TEST


START_TEST (test_element_bug_apply_ci_1)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <ci> Y </ci>"
    "  <cn> 1 </cn>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_FUNCTION );
  fail_unless( !strcmp(N->getName(), "Y")   );
  fail_unless( N->getNumChildren() == 1     );

  ASTNode* c = N->getLeftChild();

  fail_unless( c != NULL );

  fail_unless( c->getType() == AST_REAL );
  fail_unless( c->getReal() == 1        );
  fail_unless( c->getNumChildren() == 0 );
}
END_TEST


START_TEST (test_element_bug_apply_ci_2)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <ci> Y </ci>"
    "  <csymbol encoding='text' "
    "   definitionURL='http://www.sbml.org/sbml/symbols/time'> t </csymbol>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_FUNCTION );
  fail_unless( !strcmp(N->getName(), "Y")   );
  fail_unless( N->getNumChildren() == 1     );

  ASTNode* c = N->getLeftChild();

  fail_unless( c != NULL );

  fail_unless( c->getType() == AST_NAME_TIME );
  fail_unless( !strcmp(c->getName(), "t")    );
  fail_unless( c->getNumChildren() == 0      );
}
END_TEST


//
// A MathML expression involving a <csymbol> does not "reduce" to the
// correct syntax tree when it is the last argument of an <apply>.
//
// Reported by Jacek Puchalka <japuch@poczta.ibb.waw.pl>
//
START_TEST (test_element_bug_csymbol_1)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <gt/>"
    "  <csymbol encoding='text' "
    "    definitionURL='http://www.sbml.org/sbml/symbols/time'>time</csymbol>"
    "  <cn>5000</cn>"
    "</apply>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_RELATIONAL_GT );
  fail_unless( N->getNumChildren() == 2 );

  ASTNode* c = N->getLeftChild();

  fail_unless( c != NULL );

  fail_unless( c->getType() == AST_NAME_TIME );
  fail_unless( !strcmp(c->getName(), "time") );
  fail_unless( c->getNumChildren() == 0      );

  c = N->getRightChild();

  fail_unless( c != NULL );

  fail_unless( c->getType()        == AST_REAL );
  fail_unless( c->getReal()        == 5000     );
  fail_unless( c->getNumChildren() == 0        );
}
END_TEST


START_TEST (test_element_bug_cn_integer_negative)
{
  const char* s = wrapMathML("<cn type='integer'> -7 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_INTEGER );
  fail_unless( N->getInteger()     == -7 );
  fail_unless( N->getNumChildren() == 0  );
}
END_TEST


START_TEST (test_element_bug_cn_e_notation_1)
{
  const char* s = wrapMathML("<cn type='e-notation'> 2 <sep/> -8 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL_E );
  fail_unless( N->getMantissa()    ==  2.0 );
  fail_unless( N->getExponent()    == -8.0 );
  fail_unless( N->getNumChildren() ==  0   );
}
END_TEST


START_TEST (test_element_bug_cn_e_notation_2)
{
  const char* s = wrapMathML("<cn type='e-notation'> -3 <sep/> 4 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL_E );
  fail_unless( N->getMantissa()    == -3.0 );
  fail_unless( N->getExponent()    ==  4.0 );
  fail_unless( N->getNumChildren() ==  0   );
}
END_TEST


START_TEST (test_element_bug_cn_e_notation_3)
{
  const char* s = wrapMathML("<cn type='e-notation'> -6 <sep/> -1 </cn>");


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL_E );
  fail_unless( N->getMantissa()    == -6.0 );
  fail_unless( N->getExponent()    == -1.0 );
  fail_unless( N->getNumChildren() ==  0   );
}
END_TEST


//
// When constructing a function call to an AST_FUNCTION_DELAY (<csymbol>
// delay), the MathMLHandler clobbered the node type and replaced it with
// AST_FUNCTION.  This bug was missed by previous csymbol unit tests
// because they simply converted the formula tree to an infix string to
// check its structure (which loses the csymbol metadata necessary to
// detect this bug).
//
// Reported by Nicolas Rodriguez on 11-Nov-2005.
//
START_TEST (test_element_bug_csymbol_delay_1)
{
  const char* s = wrapMathML
  (
    "<apply>"
    "  <csymbol encoding='text' definitionURL='http://www.sbml.org/sbml/"
    "symbols/delay'> my_delay </csymbol>"
    "  <ci> x </ci>"
    "  <cn> 0.1 </cn>"
    "</apply>\n"
  );



  N = readMathMLFromString(s);


  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_FUNCTION_DELAY );
  fail_unless( !strcmp(N->getName(), "my_delay")  );
  fail_unless( N->getNumChildren() == 2           );


  ASTNode* c = N->getLeftChild();

  fail_unless( c != NULL );

  fail_unless( c->getType() == AST_NAME   );
  fail_unless( !strcmp(c->getName(), "x") );
  fail_unless( c->getNumChildren() == 0   );


  c = N->getRightChild();

  fail_unless( c != NULL );

  fail_unless( c->getType()        == AST_REAL );
  fail_unless( c->getReal()        == 0.1      );
  fail_unless( c->getNumChildren() == 0        );
}
END_TEST


START_TEST (test_element_invalid_mathml)
{
  const char* invalid = wrapMathML
  (
    "<lambda definitionURL=\"http://biomodels.net/SBO/#SBO:0000065\">"
    "<bvar>"
    "<ci>c</ci>"
    "</bvar>"
    "<apply>"
    "  <ci>c</ci>"
    "</apply>"
    "</lambda>\n"
  );

  N = readMathMLFromString(NULL);
  fail_unless( N == NULL );

  N = readMathMLFromString(invalid);
  fail_unless( N == NULL );
}
END_TEST


START_TEST (test_element_cn_units)
{
  const char* s = wrapMathMLUnits("<cn sbml:units=\"mole\"> 12345.7 </cn>");  

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getUnits()       == "mole"   );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST

START_TEST (test_element_cn_id)
{
  const char* s = wrapMathML("<cn id=\"test\"> 12345.7 </cn>");  

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getId()          == "test"   );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST

START_TEST (test_element_cn_class)
{
  const char* s = wrapMathML("<cn class=\"test\"> 12345.7 </cn>");  

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getClass()       == "test"   );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST

START_TEST (test_element_cn_style)
{
  const char* s = wrapMathML("<cn style=\"test\"> 12345.7 </cn>");  

  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType()        == AST_REAL );
  fail_unless( N->getReal()        == 12345.7  );
  fail_unless( N->getStyle()       == "test"   );
  fail_unless( N->getNumChildren() == 0        );
}
END_TEST


// this fails while default level/version is 2/4
// but other validation fails if I change it to 3/1

// START_TEST (test_element_ci_definitionURL)
// {
//   const char* s = wrapMathML("<ci definitionURL=\"foobar\"> x </ci>");


//   N = readMathMLFromString(s);

//   fail_unless( N != NULL );

//   fail_unless( N->getType() == AST_NAME   );
//   fail_unless( !strcmp(N->getName(), "x") );
//   fail_unless( N->getNumChildren() == 0   );
//   fail_unless( N->getDefinitionURL()->getValue(0) == "foobar");
// }
// END_TEST


START_TEST (test_element_csymbol_avogadro)
{
  const char* s = wrapMathML
  (
    "<csymbol encoding='text' "
    "definitionURL='http://www.sbml.org/sbml/symbols/avogadro'> NA </csymbol>"
  );


  N = readMathMLFromString(s);

  fail_unless( N != NULL );

  fail_unless( N->getType() == AST_NAME_AVOGADRO );
  fail_unless( !strcmp(N->getName(), "NA")    );
  fail_unless( N->getNumChildren() == 0      );
}
END_TEST

START_TEST (test_convert_unary_plus)
{
  const char* s = wrapMathML
  (
  "<apply><plus/><cn>1</cn></apply>"
  );

  N = readMathMLFromString(s);
  
  fail_unless( N != NULL );

  char* result = SBML_formulaToString(N);

  fail_unless( result != NULL );

  N = SBML_parseFormula(result);

  fail_unless( N != NULL );
  
}
END_TEST

Suite *
create_suite_ReadMathML ()
{
  Suite *suite = suite_create("ReadMathML");
  TCase *tcase = tcase_create("ReadMathML");

  tcase_add_checked_fixture( tcase, ReadMathML_setup, ReadMathML_teardown);

  tcase_add_test( tcase, test_element_math                      );

  tcase_add_test( tcase, test_element_cn_default                );
  tcase_add_test( tcase, test_element_cn_real                   );
  tcase_add_test( tcase, test_element_cn_integer                );
  tcase_add_test( tcase, test_element_cn_rational               );
  tcase_add_test( tcase, test_element_cn_e_notation             );
  tcase_add_test( tcase, test_element_ci                        );
  tcase_add_test( tcase, test_element_ci_surrounding_spaces_bug );

  tcase_add_test( tcase, test_element_csymbol_time              );
  tcase_add_test( tcase, test_element_csymbol_delay_1           );
  tcase_add_test( tcase, test_element_csymbol_delay_2           );
  tcase_add_test( tcase, test_element_csymbol_delay_3           );
  tcase_add_test( tcase, test_element_csymbol_delay_4           );

  tcase_add_test( tcase, test_element_constants_true            );
  tcase_add_test( tcase, test_element_constants_false           );
  tcase_add_test( tcase, test_element_constants_notanumber      );
  tcase_add_test( tcase, test_element_constants_pi              );
  tcase_add_test( tcase, test_element_constants_infinity        );
  tcase_add_test( tcase, test_element_constants_exponentiale    );
  tcase_add_test( tcase, test_element_operator_plus             );
  tcase_add_test( tcase, test_element_operator_times            );

  tcase_add_test( tcase, test_element_abs                       );
  tcase_add_test( tcase, test_element_and                       );
  tcase_add_test( tcase, test_element_arccos                    );
  tcase_add_test( tcase, test_element_arccosh                   );
  tcase_add_test( tcase, test_element_arccot                    );
  tcase_add_test( tcase, test_element_arccoth                   );
  tcase_add_test( tcase, test_element_arccsc                    );
  tcase_add_test( tcase, test_element_arccsch                   );
  tcase_add_test( tcase, test_element_arcsec                    );
  tcase_add_test( tcase, test_element_arcsech                   );
  tcase_add_test( tcase, test_element_arcsin                    );
  tcase_add_test( tcase, test_element_arcsinh                   );
  tcase_add_test( tcase, test_element_arctan                    );
  tcase_add_test( tcase, test_element_arctanh                   );
  tcase_add_test( tcase, test_element_ceiling                   );
  tcase_add_test( tcase, test_element_cos                       );
  tcase_add_test( tcase, test_element_cosh                      );
  tcase_add_test( tcase, test_element_cot                       );
  tcase_add_test( tcase, test_element_coth                      );
  tcase_add_test( tcase, test_element_csc                       );
  tcase_add_test( tcase, test_element_csch                      );
  tcase_add_test( tcase, test_element_eq                        );
  tcase_add_test( tcase, test_element_exp                       );
  tcase_add_test( tcase, test_element_factorial                 );
  tcase_add_test( tcase, test_element_floor                     );
  tcase_add_test( tcase, test_element_function_call_1           );
  tcase_add_test( tcase, test_element_function_call_2           );
  tcase_add_test( tcase, test_element_geq                       );
  tcase_add_test( tcase, test_element_gt                        );
  tcase_add_test( tcase, test_element_lambda                    );
  tcase_add_test( tcase, test_element_leq                       );
  tcase_add_test( tcase, test_element_ln                        );
  tcase_add_test( tcase, test_element_log_1                     );
  tcase_add_test( tcase, test_element_log_2                     );
  tcase_add_test( tcase, test_element_lt                        );
  tcase_add_test( tcase, test_element_neq                       );
  tcase_add_test( tcase, test_element_not                       );
  tcase_add_test( tcase, test_element_or                        );
  tcase_add_test( tcase, test_element_piecewise                 );
  tcase_add_test( tcase, test_element_piecewise_otherwise       );
  tcase_add_test( tcase, test_element_piecewise_no_args_1       );
  tcase_add_test( tcase, test_element_piecewise_no_args_2       );
  tcase_add_test( tcase, test_element_piecewise_one_arg         );
  tcase_add_test( tcase, test_element_power                     );
  tcase_add_test( tcase, test_element_root_1                    );
  tcase_add_test( tcase, test_element_root_2                    );
  tcase_add_test( tcase, test_element_sec                       );
  tcase_add_test( tcase, test_element_sech                      );
  tcase_add_test( tcase, test_element_sin                       );
  tcase_add_test( tcase, test_element_sinh                      );
  tcase_add_test( tcase, test_element_tan                       );
  tcase_add_test( tcase, test_element_tanh                      );
  tcase_add_test( tcase, test_element_xor                       );

  tcase_add_test( tcase, test_element_semantics                 );
  tcase_add_test( tcase, test_element_semantics_URL             );
  tcase_add_test( tcase, test_element_semantics_annotation      );
  tcase_add_test( tcase, test_element_semantics_annxml          );
  tcase_add_test( tcase, test_element_semantics_lambda          );
  tcase_add_test( tcase, test_element_semantics_URL_lambda      );
  tcase_add_test( tcase, test_element_semantics_ann_lambda      );
  tcase_add_test( tcase, test_element_semantics_annxml_lambda   );

  tcase_add_test( tcase, test_element_bug_math_xmlns            );
  tcase_add_test( tcase, test_element_bug_apply_ci_1            );
  tcase_add_test( tcase, test_element_bug_apply_ci_2            );
  tcase_add_test( tcase, test_element_bug_csymbol_1             );
  tcase_add_test( tcase, test_element_bug_cn_integer_negative   );
  tcase_add_test( tcase, test_element_bug_cn_e_notation_1       );
  tcase_add_test( tcase, test_element_bug_cn_e_notation_2       );
  tcase_add_test( tcase, test_element_bug_cn_e_notation_3       );
  tcase_add_test( tcase, test_element_bug_csymbol_delay_1       );
  tcase_add_test( tcase, test_convert_unary_plus                );

  tcase_add_test( tcase, test_element_invalid_mathml       );
  tcase_add_test( tcase, test_element_cn_units             );
  tcase_add_test( tcase, test_element_cn_id                );
  tcase_add_test( tcase, test_element_cn_class             );
  tcase_add_test( tcase, test_element_cn_style             );
  // this fails while default level/version is 2/4
  // but other validation fails if I change it to 3/1
  
  // tcase_add_test( tcase, test_element_ci_definitionURL       );
  tcase_add_test( tcase, test_element_csymbol_avogadro              );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
