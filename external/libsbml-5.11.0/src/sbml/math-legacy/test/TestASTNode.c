/**
 * \file    TestASTNode.c
 * \brief   ASTNode unit tests
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
#include <sbml/util/List.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/L3Parser.h>
#include <sbml/EventAssignment.h>
#include <sbml/Model.h>
#include <sbml/SBMLDocument.h>
#include <sbml/xml/XMLNode.h>

#include <limits.h>
#include <math.h>
#include <check.h>


#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif



START_TEST (test_ASTNode_create)
{
  ASTNode_t *n = ASTNode_create();
  EventAssignment_t *ea = 
    EventAssignment_create(2, 4);


  fail_unless( ASTNode_getType(n) == AST_UNKNOWN );

  fail_unless( ASTNode_getCharacter(n) == '\0' );
  fail_unless( ASTNode_getName     (n) == NULL );
  fail_unless( ASTNode_getInteger  (n) == 0    );
  fail_unless( ASTNode_getExponent (n) == 0    );

  fail_unless( ASTNode_getNumChildren(n) == 0 );

  fail_unless( ASTNode_getParentSBMLObject(n) == NULL );

  EventAssignment_free(ea);

  ASTNode_free(n);
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
  ASTNode_t *n;
  EventAssignment_t *ea = 
    EventAssignment_create(2, 4);


  /** "foo" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType(n) == AST_NAME     );
  fail_unless( !strcmp(ASTNode_getName(n), "foo") );
  fail_unless( ASTNode_getNumChildren(n) == 0     );

  fail_unless( ASTNode_getParentSBMLObject(n) == NULL );

  EventAssignment_free(ea);

  Token_free(t);
  ASTNode_free(n);

  /** "2" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_INTEGER );
  fail_unless( ASTNode_getInteger    (n) == 2 );
  fail_unless( ASTNode_getNumChildren(n) == 0 );

  Token_free(t);
  ASTNode_free(n);

  /** "4.0" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_REAL );
  fail_unless( ASTNode_getReal       (n) == 4.0 );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** ".272e1" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_REAL_E );
  fail_unless( ASTNode_getMantissa   (n) == .272 );
  fail_unless( ASTNode_getExponent   (n) == 1    );
  fail_unless( ASTNode_getNumChildren(n) == 0    );

  Token_free(t);
  ASTNode_free(n);

  /** "+" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_PLUS );
  fail_unless( ASTNode_getCharacter  (n) == '+' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** "-" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_MINUS );
  fail_unless( ASTNode_getCharacter  (n) == '-' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** "*" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_TIMES );
  fail_unless( ASTNode_getCharacter  (n) == '*' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** "/" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_DIVIDE );
  fail_unless( ASTNode_getCharacter  (n) == '/' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** "^" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_POWER );
  fail_unless( ASTNode_getCharacter  (n) == '^' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  /** "@" **/
  t = FormulaTokenizer_nextToken(ft);
  n = ASTNode_createFromToken(t);

  fail_unless( ASTNode_getType       (n) == AST_UNKNOWN );
  fail_unless( ASTNode_getCharacter  (n) == '@' );
  fail_unless( ASTNode_getNumChildren(n) == 0   );

  Token_free(t);
  ASTNode_free(n);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeConstants)
{
  ASTNode_t *n = ASTNode_create();


  /** ExponentialE **/
  ASTNode_setName(n, "ExponentialE");
  fail_unless( ASTNode_isName(n));

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_CONSTANT_E );

  ASTNode_setType(n, AST_NAME);


  /** False **/
  ASTNode_setName(n, "False");
  fail_unless( ASTNode_isName(n));

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_CONSTANT_FALSE );

  ASTNode_setType(n, AST_NAME);


  /** Pi **/
  ASTNode_setName(n, "Pi");
  fail_unless( ASTNode_isName(n));

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_CONSTANT_PI );

  ASTNode_setType(n, AST_NAME);


  /** True **/
  ASTNode_setName(n, "True");
  fail_unless( ASTNode_isName(n));

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_CONSTANT_TRUE );

  ASTNode_setType(n, AST_NAME);


  /** Foo **/
  ASTNode_setName(n, "Foo");
  fail_unless( ASTNode_isName(n));

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_isName(n));


  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeFunctions)
{
  ASTNode_t *n = ASTNode_createWithType(AST_FUNCTION);


  /** abs **/
  ASTNode_setName(n, "abs");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ABS );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccos **/
  ASTNode_setName(n, "arccos");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCOS );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccosh **/
  ASTNode_setName(n, "arccosh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCOSH );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccot **/
  ASTNode_setName(n, "arccot");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCOT );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccoth **/
  ASTNode_setName(n, "arccoth");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCOTH );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccsc **/
  ASTNode_setName(n, "arccsc");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCSC );

  ASTNode_setType(n, AST_FUNCTION);


  /** arccsch **/
  ASTNode_setName(n, "arccsch");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCSCH );

  ASTNode_setType(n, AST_FUNCTION);


  /** arcsec **/
  ASTNode_setName(n, "arcsec");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCSEC );

  ASTNode_setType(n, AST_FUNCTION);


  /** arcsech **/
  ASTNode_setName(n, "arcsech");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCSECH );

  ASTNode_setType(n, AST_FUNCTION);


  /** arcsin **/
  ASTNode_setName(n, "arcsin");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCSIN );

  ASTNode_setType(n, AST_FUNCTION);


  /** arcsinh **/
  ASTNode_setName(n, "arcsinh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCSINH );

  ASTNode_setType(n, AST_FUNCTION);


  /** arctan **/
  ASTNode_setName(n, "arctan");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCTAN );

  ASTNode_setType(n, AST_FUNCTION);


  /** arctanh **/
  ASTNode_setName(n, "arctanh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCTANH );

  ASTNode_setType(n, AST_FUNCTION);


  /** ceiling **/
  ASTNode_setName(n, "ceiling");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_CEILING );

  ASTNode_setType(n, AST_FUNCTION);


  /** cos **/
  ASTNode_setName(n, "cos");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_COS );

  ASTNode_setType(n, AST_FUNCTION);


  /** cosh **/
  ASTNode_setName(n, "cosh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_COSH );

  ASTNode_setType(n, AST_FUNCTION);


  /** cot **/
  ASTNode_setName(n, "cot");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_COT );

  ASTNode_setType(n, AST_FUNCTION);


  /** coth **/
  ASTNode_setName(n, "coth");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_COTH );

  ASTNode_setType(n, AST_FUNCTION);


  /** csc **/
  ASTNode_setName(n, "csc");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_CSC );

  ASTNode_setType(n, AST_FUNCTION);


  /** csch **/
  ASTNode_setName(n, "csch");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_CSCH );

  ASTNode_setType(n, AST_FUNCTION);


  /** exp **/
  ASTNode_setName(n, "exp");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_EXP );

  ASTNode_setType(n, AST_FUNCTION);


  /** factorial **/
  ASTNode_setName(n, "factorial");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_FACTORIAL );

  ASTNode_setType(n, AST_FUNCTION);


  /** floor **/
  ASTNode_setName(n, "floor");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_FLOOR );

  ASTNode_setType(n, AST_FUNCTION);


  /** lambda **/
  ASTNode_setName(n, "lambda");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_LAMBDA );

  ASTNode_setType(n, AST_FUNCTION);


  /** ln **/
  ASTNode_setName(n, "ln");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_LN );

  ASTNode_setType(n, AST_FUNCTION);


  /** log **/
  ASTNode_setName(n, "log");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_LOG );

  ASTNode_setType(n, AST_FUNCTION);


  /** piecewise **/
  ASTNode_setName(n, "piecewise");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_PIECEWISE );

  ASTNode_setType(n, AST_FUNCTION);


  /** power **/
  ASTNode_setName(n, "power");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_POWER );

  ASTNode_setType(n, AST_FUNCTION);


  /** root **/
  ASTNode_setName(n, "root");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ROOT );

  ASTNode_setType(n, AST_FUNCTION);


  /** sec **/
  ASTNode_setName(n, "sec");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_SEC );

  ASTNode_setType(n, AST_FUNCTION);


  /** sech **/
  ASTNode_setName(n, "sech");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_SECH );

  ASTNode_setType(n, AST_FUNCTION);


  /** sin **/
  ASTNode_setName(n, "sin");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_SIN );

  ASTNode_setType(n, AST_FUNCTION);


  /** sinh **/
  ASTNode_setName(n, "sinh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_SINH );

  ASTNode_setType(n, AST_FUNCTION);


  /** tan **/
  ASTNode_setName(n, "tan");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_TAN );

  ASTNode_setType(n, AST_FUNCTION);


  /** tanh **/
  ASTNode_setName(n, "tanh");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_TANH );

  ASTNode_setType(n, AST_FUNCTION);


  /** Foo **/
  ASTNode_setName(n, "Foo");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION);

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );


  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeFunctionsL1)
{
  ASTNode_t *n = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_t *c;


  /** acos **/
  ASTNode_setName(n, "acos");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCCOS );

  ASTNode_setType(n, AST_FUNCTION);


  /** asin **/
  ASTNode_setName(n, "asin");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCSIN );

  ASTNode_setType(n, AST_FUNCTION);


  /** atan **/
  ASTNode_setName(n, "atan");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ARCTAN );

  ASTNode_setType(n, AST_FUNCTION);


  /** ceil **/
  ASTNode_setName(n, "ceil");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_CEILING );

  ASTNode_setType(n, AST_FUNCTION);

  /** pow **/
  ASTNode_setName(n, "pow");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_FUNCTION_POWER );

  ASTNode_free(n);

  /**
   * log(x) and log(x, y)
   *
   * In SBML L1 log(x) (with exactly one argument) canonicalizes to a node
   * of type AST_FUNCTION_LN (see L1 Specification, Appendix C), whereas
   * log(x, y) canonicalizes to a node of type AST_FUNCTION_LOG.
   */
  n = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setName(n, "log");

  c = ASTNode_create();
  ASTNode_setName (c, "x");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION );  
  fail_unless( ASTNode_getNumChildren(n) == 1 );

  ASTNode_canonicalize(n);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION_LN );  
  fail_unless( ASTNode_getNumChildren(n) == 1 );

  /** log(x, y) (continued) **/
  ASTNode_setType(n, AST_FUNCTION);

  c = ASTNode_create();
  ASTNode_setName (c, "y");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION );
  fail_unless( ASTNode_getNumChildren(n) == 2 );

  ASTNode_canonicalize(n);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION_LOG );

  ASTNode_free(n);


  /** log10(x) -> log(10, x) **/
  n = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setName(n, "log10");

  c = ASTNode_create();
  ASTNode_setName (c, "x");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION );  
  fail_unless( ASTNode_getNumChildren(n) == 1 );

  ASTNode_canonicalize(n);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION_LOG );  
  fail_unless( ASTNode_getNumChildren(n) == 2 );

  c = ASTNode_getLeftChild(n);
  fail_unless( ASTNode_getType(c)    == AST_INTEGER );
  fail_unless( ASTNode_getInteger(c) == 10 );

  c = ASTNode_getRightChild(n);
  fail_unless( ASTNode_getType(c) == AST_NAME   );
  fail_unless( !strcmp(ASTNode_getName(c), "x") );

  ASTNode_free(n);


  /** sqr(x) -> power(x, 2) **/
  n = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setName(n, "sqr");

  c = ASTNode_create();
  ASTNode_setName (c, "x");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION );  
  fail_unless( ASTNode_getNumChildren(n) == 1 );

  ASTNode_canonicalize(n);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION_POWER );  
  fail_unless( ASTNode_getNumChildren(n) == 2 );

  c = ASTNode_getLeftChild(n);
  fail_unless( ASTNode_getType(c) == AST_NAME   );
  fail_unless( !strcmp(ASTNode_getName(c), "x") );

  c = ASTNode_getRightChild(n);
  fail_unless( ASTNode_getType(c)    == AST_INTEGER );
  fail_unless( ASTNode_getInteger(c) == 2 );

  ASTNode_free(n);


  /** sqrt(x) -> root(2, x) **/
  n = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setName(n, "sqrt");

  c = ASTNode_create();
  ASTNode_setName (c, "x");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION );  
  fail_unless( ASTNode_getNumChildren(n) == 1 );

  ASTNode_canonicalize(n);

  fail_unless( ASTNode_getType(n) == AST_FUNCTION_ROOT );  
  fail_unless( ASTNode_getNumChildren(n) == 2 );

  c = ASTNode_getLeftChild(n);
  fail_unless( ASTNode_getType(c)    == AST_INTEGER );
  fail_unless( ASTNode_getInteger(c) == 2 );

  c = ASTNode_getRightChild(n);
  fail_unless( ASTNode_getType(c) == AST_NAME   );
  fail_unless( !strcmp(ASTNode_getName(c), "x") );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeLogical)
{
  ASTNode_t *n = ASTNode_createWithType(AST_FUNCTION);


  /** and **/
  ASTNode_setName(n, "and");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_LOGICAL_AND );

  ASTNode_setType(n, AST_FUNCTION);


  /** not **/
  ASTNode_setName(n, "not");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_LOGICAL_NOT );

  ASTNode_setType(n, AST_FUNCTION);


  /** or **/
  ASTNode_setName(n, "or");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_LOGICAL_OR );

  ASTNode_setType(n, AST_FUNCTION);


  /** xor **/
  ASTNode_setName(n, "xor");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_LOGICAL_XOR );

  ASTNode_setType(n, AST_FUNCTION);


  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_canonicalizeRelational)
{
  ASTNode_t *n = ASTNode_createWithType(AST_FUNCTION);


  /** eq **/
  ASTNode_setName(n, "eq");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_EQ );

  ASTNode_setType(n, AST_FUNCTION);


  /** geq **/
  ASTNode_setName(n, "geq");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_GEQ );

  ASTNode_setType(n, AST_FUNCTION);


  /** gt **/
  ASTNode_setName(n, "gt");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_GT );

  ASTNode_setType(n, AST_FUNCTION);


  /** leq **/
  ASTNode_setName(n, "leq");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_LEQ );

  ASTNode_setType(n, AST_FUNCTION);


  /** lt **/
  ASTNode_setName(n, "lt");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_LT );

  ASTNode_setType(n, AST_FUNCTION);


  /** neq **/
  ASTNode_setName(n, "neq");
  fail_unless( ASTNode_getType(n) == AST_FUNCTION );

  ASTNode_canonicalize(n);
  fail_unless( ASTNode_getType(n) == AST_RELATIONAL_NEQ );

  ASTNode_setType(n, AST_FUNCTION);


  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_deepCopy_1)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *child, *copy;


  /** 1 + 2 **/
  ASTNode_setCharacter(node, '+');
  ASTNode_addChild( node, ASTNode_create() );
  ASTNode_addChild( node, ASTNode_create() );

  ASTNode_setInteger( ASTNode_getLeftChild (node), 1 );
  ASTNode_setInteger( ASTNode_getRightChild(node), 2 );

  fail_unless( ASTNode_getType       (node) == AST_PLUS );
  fail_unless( ASTNode_getCharacter  (node) == '+'      );
  fail_unless( ASTNode_getNumChildren(node) == 2        );

  child = ASTNode_getLeftChild(node);

  fail_unless( ASTNode_getType       (child) == AST_INTEGER );
  fail_unless( ASTNode_getInteger    (child) == 1           );
  fail_unless( ASTNode_getNumChildren(child) == 0           );

  child = ASTNode_getRightChild(node);

  fail_unless( ASTNode_getType       (child) == AST_INTEGER );
  fail_unless( ASTNode_getInteger    (child) == 2           );
  fail_unless( ASTNode_getNumChildren(child) == 0           );

  /** deepCopy() **/
  copy = ASTNode_deepCopy(node);

  fail_unless( copy != node );
  fail_unless( ASTNode_getType       (copy) == AST_PLUS );
  fail_unless( ASTNode_getCharacter  (copy) == '+'      );
  fail_unless( ASTNode_getNumChildren(copy) == 2        );

  child = ASTNode_getLeftChild(copy);

  fail_unless( child != ASTNode_getLeftChild(node) );
  fail_unless( ASTNode_getType       (child) == AST_INTEGER );
  fail_unless( ASTNode_getInteger    (child) == 1           );
  fail_unless( ASTNode_getNumChildren(child) == 0           );

  child = ASTNode_getRightChild(copy);
  fail_unless( child != ASTNode_getRightChild(node) );
  fail_unless( ASTNode_getType       (child) == AST_INTEGER );
  fail_unless( ASTNode_getInteger    (child) == 2           );
  fail_unless( ASTNode_getNumChildren(child) == 0           );

  ASTNode_free(node);
  ASTNode_free(copy);
}
END_TEST


START_TEST (test_ASTNode_deepCopy_2)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *copy;


  ASTNode_setName(node, "Foo");

  fail_unless( ASTNode_getType(node) == AST_NAME     );
  fail_unless( !strcmp(ASTNode_getName(node), "Foo") );
  fail_unless( ASTNode_getNumChildren(node) == 0     );

  /** deepCopy() **/
  copy = ASTNode_deepCopy(node);

  fail_unless( copy != node );
  fail_unless( ASTNode_getType(copy) == AST_NAME     );
  fail_unless( !strcmp(ASTNode_getName(copy), "Foo") );
  fail_unless( ASTNode_getNumChildren(copy) == 0     );

  fail_unless( !strcmp(ASTNode_getName(copy), ASTNode_getName(node)) );

  ASTNode_free(node);
  ASTNode_free(copy);
}
END_TEST


START_TEST (test_ASTNode_deepCopy_3)
{
  ASTNode_t *node = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_t *copy;


  ASTNode_setName(node, "Foo");
  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( !strcmp(ASTNode_getName(node), "Foo") );
  fail_unless( ASTNode_getNumChildren(node) == 0     );

  /** deepCopy() **/
  copy = ASTNode_deepCopy(node);

  fail_unless( copy != node );
  fail_unless( ASTNode_getType(copy) == AST_FUNCTION );
  fail_unless( !strcmp(ASTNode_getName(copy), "Foo") );
  fail_unless( ASTNode_getNumChildren(copy) == 0     );

  fail_unless( !strcmp(ASTNode_getName(copy), ASTNode_getName(node)) );

  ASTNode_free(node);
  ASTNode_free(copy);
}
END_TEST


START_TEST (test_ASTNode_deepCopy_4)
{
  ASTNode_t *node = ASTNode_createWithType(AST_FUNCTION_ABS);
  ASTNode_t *copy;


  ASTNode_setName(node, "ABS");
  fail_unless( ASTNode_getType(node) == AST_FUNCTION_ABS );
  fail_unless( !strcmp(ASTNode_getName(node), "ABS")     );
  fail_unless( ASTNode_getNumChildren(node) == 0         );

  /** deepCopy() **/
  copy = ASTNode_deepCopy(node);

  fail_unless( copy != node );
  fail_unless( ASTNode_getType(copy) == AST_FUNCTION_ABS );
  fail_unless( !strcmp(ASTNode_getName(copy), "ABS")     );
  fail_unless( ASTNode_getNumChildren(copy) == 0         );

  fail_unless( !strcmp(ASTNode_getName(copy), ASTNode_getName(node)) );

  ASTNode_free(node);
  ASTNode_free(copy);
}
END_TEST


START_TEST (test_ASTNode_getName)
{
  ASTNode_t *n = ASTNode_create();


  /** AST_NAMEs **/
  ASTNode_setName(n, "foo");
  fail_unless( !strcmp(ASTNode_getName(n), "foo") );

  ASTNode_setType(n, AST_NAME_TIME);
  fail_unless( !strcmp(ASTNode_getName(n), "foo") );

  ASTNode_setName(n, NULL);
  fail_unless( ASTNode_getName(n) == NULL );


  /** AST_CONSTANTs **/
  ASTNode_setType(n, AST_CONSTANT_E);
  fail_unless( !strcmp(ASTNode_getName(n), "exponentiale") );

  ASTNode_setType(n, AST_CONSTANT_FALSE);
  fail_unless( !strcmp(ASTNode_getName(n), "false") );

  ASTNode_setType(n, AST_CONSTANT_PI);
  fail_unless( !strcmp(ASTNode_getName(n), "pi") );

  ASTNode_setType(n, AST_CONSTANT_TRUE);
  fail_unless( !strcmp(ASTNode_getName(n), "true") );


  /** AST_LAMBDA **/
  ASTNode_setType(n, AST_LAMBDA);
  fail_unless( !strcmp(ASTNode_getName(n), "lambda") );


  /** AST_FUNCTION (user-defined) **/
  ASTNode_setType(n, AST_FUNCTION);
  ASTNode_setName(n, "f");
  fail_unless( !strcmp(ASTNode_getName(n), "f") );

  ASTNode_setType(n, AST_FUNCTION_DELAY);
  fail_unless( !strcmp(ASTNode_getName(n), "f") );

  ASTNode_setName(n, NULL);
  fail_unless( !strcmp(ASTNode_getName(n), "delay") );

  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( ASTNode_getName(n) == NULL );


  /** AST_FUNCTIONs (builtin)  **/
  ASTNode_setType(n, AST_FUNCTION_ABS);
  fail_unless( !strcmp(ASTNode_getName(n), "abs") );

  ASTNode_setType(n, AST_FUNCTION_ARCCOS);
  fail_unless( !strcmp(ASTNode_getName(n), "arccos") );

  ASTNode_setType(n, AST_FUNCTION_TAN);
  fail_unless( !strcmp(ASTNode_getName(n), "tan") );

  ASTNode_setType(n, AST_FUNCTION_TANH);
  fail_unless( !strcmp(ASTNode_getName(n), "tanh") );


  /** AST_LOGICALs **/
  ASTNode_setType(n, AST_LOGICAL_AND);
  fail_unless( !strcmp(ASTNode_getName(n), "and") );

  ASTNode_setType(n, AST_LOGICAL_NOT);
  fail_unless( !strcmp(ASTNode_getName(n), "not") );

  ASTNode_setType(n, AST_LOGICAL_OR);
  fail_unless( !strcmp(ASTNode_getName(n), "or")  );

  ASTNode_setType(n, AST_LOGICAL_XOR);
  fail_unless( !strcmp(ASTNode_getName(n), "xor") );


  /** AST_RELATIONALs **/
  ASTNode_setType(n, AST_RELATIONAL_EQ);
  fail_unless( !strcmp(ASTNode_getName(n), "eq") );

  ASTNode_setType(n, AST_RELATIONAL_GEQ);
  fail_unless( !strcmp(ASTNode_getName(n), "geq") );

  ASTNode_setType(n, AST_RELATIONAL_LT);
  fail_unless( !strcmp(ASTNode_getName(n), "lt") );

  ASTNode_setType(n, AST_RELATIONAL_NEQ);
  fail_unless( !strcmp(ASTNode_getName(n), "neq") );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_getReal)
{
  ASTNode_t *n = ASTNode_create();


  /** 2.0 **/
  ASTNode_setType(n, AST_REAL);
  ASTNode_setReal(n, 1.6);

  fail_unless(ASTNode_getReal(n) == 1.6);

  /** 12.3e3 **/
  ASTNode_setType(n, AST_REAL_E);
  ASTNode_setRealWithExponent(n, 12.3, 3);

  double val = fabs(ASTNode_getReal(n) - 12300.0);
  fail_unless(val < util_epsilon());

  /** 1/2 **/
  ASTNode_setType(n, AST_RATIONAL);
  ASTNode_setRational(n, 1, 2);

  fail_unless(ASTNode_getReal(n) == 0.5);

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_getPrecedence)
{
  ASTNode_t *n = ASTNode_create();


  ASTNode_setType(n, AST_PLUS);
  fail_unless( ASTNode_getPrecedence(n) == 2 );

  ASTNode_setType(n, AST_MINUS);
  fail_unless( ASTNode_getPrecedence(n) == 2 );

  ASTNode_setType(n, AST_TIMES);
  fail_unless( ASTNode_getPrecedence(n) == 3 );

  ASTNode_setType(n, AST_DIVIDE);
  fail_unless( ASTNode_getPrecedence(n) == 3 );

  ASTNode_setType(n, AST_POWER);
  fail_unless( ASTNode_getPrecedence(n) == 4 );

  ASTNode_setType (n, AST_MINUS);
  ASTNode_addChild(n, ASTNode_createWithType(AST_NAME));
  fail_unless( ASTNode_isUMinus(n)      == 1 );
  fail_unless( ASTNode_getPrecedence(n) == 5 );

  ASTNode_setType(n, AST_NAME);
  fail_unless( ASTNode_getPrecedence(n) == 6 );

  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( ASTNode_getPrecedence(n) == 6 );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_isLog10)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_t *c;


  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( ASTNode_isLog10(n) == 0 );

  /** log() **/
  ASTNode_setType(n, AST_FUNCTION_LOG);
  fail_unless( ASTNode_isLog10(n) == 0 );

  /** log(10) **/
  c = ASTNode_create();
  ASTNode_addChild(n, c);

  ASTNode_setInteger(c, 10);
  fail_unless( ASTNode_isLog10(n) == 0 );

  /** log(10, x) -> ASTNode_isLog10() == 1 **/
  ASTNode_addChild(n, ASTNode_create());
  fail_unless( ASTNode_isLog10(n) == 1 );

  /** log(2, x) **/
  ASTNode_setInteger(c, 2);
  fail_unless( ASTNode_isLog10(n) == 0 );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_isSqrt)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_t *c;


  ASTNode_setType(n, AST_FUNCTION);
  fail_unless( ASTNode_isSqrt(n) == 0 );

  /** root() **/
  ASTNode_setType(n, AST_FUNCTION_ROOT);
  fail_unless( ASTNode_isSqrt(n) == 0 );

  /** root(2) **/
  c = ASTNode_create();
  ASTNode_addChild(n, c);

  ASTNode_setInteger(c, 2);
  fail_unless( ASTNode_isSqrt(n) == 0 );

  /** root(2, x) -> ASTNode_isSqrt() == 1 **/
  ASTNode_addChild(n, ASTNode_create());
  fail_unless( ASTNode_isSqrt(n) == 1 );

  /** root(3, x) **/
  ASTNode_setInteger(c, 3);
  fail_unless( ASTNode_isSqrt(n) == 0 );

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_isUMinus)
{
  ASTNode_t *n = ASTNode_create();


  ASTNode_setType(n, AST_MINUS);
  fail_unless( ASTNode_isUMinus(n) == 0 );

  ASTNode_addChild(n, ASTNode_createWithType(AST_NAME));
  fail_unless( ASTNode_isUMinus(n) == 1 );

  ASTNode_free(n);
}
END_TEST

  

START_TEST (test_ASTNode_isUPlus)
{
  ASTNode_t *n = ASTNode_create();


  ASTNode_setType(n, AST_PLUS);
  fail_unless( ASTNode_isUPlus(n) == 0 );

  ASTNode_addChild(n, ASTNode_createWithType(AST_NAME));
  fail_unless( ASTNode_isUPlus(n) == 1 );

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_setCharacter)
{
  ASTNode_t *node = ASTNode_create();


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  ASTNode_setName(node, "foo");
  fail_unless( ASTNode_getType(node)      == AST_NAME );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( !strcmp(ASTNode_getName(node), "foo")  );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '+');
  fail_unless( ASTNode_getType     (node) == AST_PLUS );
  fail_unless( ASTNode_getCharacter(node) == '+'      );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '-');
  fail_unless( ASTNode_getType     (node) == AST_MINUS );
  fail_unless( ASTNode_getCharacter(node) == '-'       );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '*');
  fail_unless( ASTNode_getType     (node) == AST_TIMES );
  fail_unless( ASTNode_getCharacter(node) == '*'       );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '/');
  fail_unless( ASTNode_getType     (node) == AST_DIVIDE );
  fail_unless( ASTNode_getCharacter(node) == '/'        );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '^');
  fail_unless( ASTNode_getType     (node) == AST_POWER );
  fail_unless( ASTNode_getCharacter(node) == '^'       );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setCharacter(node, '$');
  fail_unless( ASTNode_getType     (node) == AST_UNKNOWN );
  fail_unless( ASTNode_getCharacter(node) == '$'         );
  fail_unless( ASTNode_getName(node)      == NULL     );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setName_1)
{
  const char *name = "foo";
  ASTNode_t  *node = ASTNode_create();


  fail_unless( ASTNode_getType(node) == AST_UNKNOWN );

  ASTNode_setName(node, name);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( !strcmp(ASTNode_getName(node), name) );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  if (ASTNode_getName(node) == name)
  {
    fail("ASTNode_setName(...) did not make a copy of name.");
  }

  ASTNode_setName(node, NULL);
  fail_unless( ASTNode_getType(node) == AST_NAME );

  if (ASTNode_getName(node) != NULL)
  {
    fail("ASTNode_setName(node, NULL) did not clear string.");
  }

  ASTNode_setType(node, AST_FUNCTION_COS);
  fail_unless( ASTNode_getType(node) == AST_FUNCTION_COS );
  fail_unless( !strcmp(ASTNode_getName(node), "cos") );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setType(node, AST_PLUS);
  ASTNode_setName(node, name);
  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( !strcmp(ASTNode_getName(node), name) );
  fail_unless( ASTNode_getCharacter(node) == '+'        );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setName_2)
{
  const char *name = "foo";
  ASTNode_t  *node = ASTNode_create();
  ASTNode_setId(node, "s");

  fail_unless( ASTNode_getType(node) == AST_UNKNOWN );

  ASTNode_setName(node, name);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), name) == 0);
  safe_free(id);

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setName_3)
{
  const char *name = "foo";
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  ASTNode_setId(node, "s");

  ASTNode_setName(node, name);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), name) == 0);
  safe_free(id);

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setName_4)
{
  const char *name = "foo";
  ASTNode_t  *node = ASTNode_createWithType(AST_INTEGER);
  ASTNode_setId(node, "s");

  ASTNode_setName(node, name);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), name) == 0);
  safe_free(id);

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setName_5)
{
  const char *name = "foo";
  ASTNode_t  *node = ASTNode_createWithType(AST_INTEGER);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");

  ASTNode_setName(node, name);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), name) == 0);
  fail_unless( strcmp(units, "") == 0);
  safe_free(id);
  safe_free(units);

  ASTNode_free(node);;
}
END_TEST


START_TEST (test_ASTNode_setName_override)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION_SIN);


  fail_unless( !strcmp(ASTNode_getName(node), "sin")     );
  fail_unless( ASTNode_getType(node) == AST_FUNCTION_SIN );

  ASTNode_setName(node, "MySinFunc");

  fail_unless( !strcmp(ASTNode_getName(node), "MySinFunc") );
  fail_unless( ASTNode_getType(node) == AST_FUNCTION_SIN   );

  ASTNode_setName(node, NULL);

  fail_unless( !strcmp(ASTNode_getName(node), "sin")     );
  fail_unless( ASTNode_getType(node) == AST_FUNCTION_SIN );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setInteger)
{
  ASTNode_t *node = ASTNode_create();


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  ASTNode_setName(node, "foo");
  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( !strcmp(ASTNode_getName(node), "foo") );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getInteger(node)   == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setReal(node, 3.2);
  fail_unless( ASTNode_getType   (node) == AST_REAL );
  fail_unless( ASTNode_getInteger(node) == 0         );
  fail_unless( ASTNode_getName(node)== NULL );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getReal(node)      == 3.2        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_setInteger(node, 321);
  fail_unless( ASTNode_getType   (node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 321         );
  fail_unless( ASTNode_getName(node)== NULL );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getReal(node)      == 0        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setReal)
{
  ASTNode_t *node = ASTNode_create();


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  ASTNode_setName(node, "foo");
  fail_unless( ASTNode_getType(node) == AST_NAME );

  ASTNode_setReal(node, 32.1);
  fail_unless( ASTNode_getType(node) == AST_REAL );
  fail_unless( ASTNode_getInteger(node) == 0         );
  fail_unless( ASTNode_getName(node)== NULL );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getReal(node)      == 32.1        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 1      );
  fail_unless( ASTNode_getMantissa(node) == 32.1     );

  ASTNode_setRational(node, 45, 90);
  fail_unless( ASTNode_getType(node) == AST_RATIONAL );
  fail_unless( ASTNode_getInteger(node) == 45         );
  fail_unless( ASTNode_getName(node)== NULL );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getReal(node)      == 0.5        );
  fail_unless( ASTNode_getExponent(node)  == 0        );
  fail_unless( ASTNode_getDenominator(node) == 90      );
  fail_unless( ASTNode_getMantissa(node) == 0     );

  ASTNode_setRealWithExponent(node, 32.0, 4);
  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0         );
  fail_unless( ASTNode_getName(node)== NULL );
  fail_unless( ASTNode_getCharacter(node) == 0        );
  fail_unless( ASTNode_getReal(node)      == 320000        );
  fail_unless( ASTNode_getExponent(node)  == 4        );
  fail_unless( ASTNode_getDenominator(node) == 1      );
  fail_unless( ASTNode_getMantissa(node) == 32     );

  ASTNode_free(node);
}
END_TEST



START_TEST (test_ASTNode_setType_1)
{
  ASTNode_t *node = ASTNode_create();


  /**
   * Ensure "foo" is cleared in subsequent sets.
   */
  ASTNode_setName(node, "foo");
  fail_unless( ASTNode_getType(node) == AST_NAME );

  /**
   * node->value.name should not to cleared or changed as we toggle from
   * AST_FUNCTION to and from AST_NAME.
   */
  ASTNode_setType(node, AST_FUNCTION);
  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( !strcmp(ASTNode_getName(node), "foo") );

  ASTNode_setType(node, AST_NAME);
  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( !strcmp(ASTNode_getName(node), "foo") );

  /**
   * But now it should...
   */
  ASTNode_setType(node, AST_INTEGER);
  fail_unless( ASTNode_getType(node) == AST_INTEGER );

  ASTNode_setType(node, AST_REAL);
  fail_unless( ASTNode_getType(node) == AST_REAL );

  ASTNode_setType(node, AST_UNKNOWN);
  fail_unless( ASTNode_getType(node) == AST_UNKNOWN );

  /**
   * Setting these types should also set node->value.ch
   */
  ASTNode_setType(node, AST_PLUS);
  fail_unless( ASTNode_getType     (node) == AST_PLUS );
  fail_unless( ASTNode_getCharacter(node) == '+'      );

  ASTNode_setType(node, AST_MINUS);
  fail_unless( ASTNode_getType     (node) == AST_MINUS );
  fail_unless( ASTNode_getCharacter(node) == '-'       );

  ASTNode_setType(node, AST_TIMES);
  fail_unless( ASTNode_getType     (node) == AST_TIMES );
  fail_unless( ASTNode_getCharacter(node) == '*'       );

  ASTNode_setType(node, AST_DIVIDE);
  fail_unless( ASTNode_getType     (node) == AST_DIVIDE );
  fail_unless( ASTNode_getCharacter(node) == '/'        );

  ASTNode_setType(node, AST_POWER);
  fail_unless( ASTNode_getType     (node) == AST_POWER );
  fail_unless( ASTNode_getCharacter(node) == '^'       );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_setType_2)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_INTEGER);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setInteger(node, 1);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 1);
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_REAL);

  fail_unless( ASTNode_getType(node) == AST_REAL );
  fail_unless( ASTNode_getInteger(node) == 0);
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_3)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_REAL_E);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setRealWithExponent(node, 2.3, 1);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 2.3));
  fail_unless( ASTNode_getExponent(node) == 1);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 23));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_RATIONAL);

  fail_unless( ASTNode_getType(node) == AST_RATIONAL );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( ASTNode_getReal(node) == 0);
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_4)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME_TIME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setName(node, "t");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 0);
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( ASTNode_getReal(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_NAME_AVOGADRO);

  fail_unless( ASTNode_getType(node) == AST_NAME_AVOGADRO );
  fail_unless( util_isEqual(ASTNode_getReal(node), 6.02214179e23));
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 1);
  fail_unless( ASTNode_isName(node) == 1);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/avogadro") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_5)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_CONSTANT_PI);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_CONSTANT_PI );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 1);
  fail_unless( ASTNode_getInteger(node) == 0);
  safe_free(id);


  ASTNode_setType(node, AST_INTEGER);

  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 0);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 0);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_6)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  ASTNode_setDefinitionURLString(node, "my_url");
  ASTNode_setName(node, "t");


  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "my_url") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_INTEGER);

  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 0);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( ASTNode_getName(node) == NULL);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_7)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME_TIME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setName(node, "t");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( ASTNode_getReal(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_REAL);

  fail_unless( ASTNode_getType(node) == AST_REAL );
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( ASTNode_getReal(node) == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_8)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_REAL_E);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setRealWithExponent(node, 2.3, 1);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 2.3));
  fail_unless( ASTNode_getExponent(node) == 1);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 23));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_NAME_AVOGADRO);

  fail_unless( ASTNode_getType(node) == AST_NAME_AVOGADRO );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 6.02214179e23));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 6.02214179e23));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/avogadro") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST



START_TEST (test_ASTNode_setType_9)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_REAL_E);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setRealWithExponent(node, 2.3, 1);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 2.3));
  fail_unless( ASTNode_getExponent(node) == 1);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 23));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_NAME);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST



START_TEST (test_ASTNode_setType_10)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_REAL_E);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setRealWithExponent(node, 2.3, 1);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 2.3));
  fail_unless( ASTNode_getExponent(node) == 1);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 23));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_PLUS);

  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST



START_TEST (test_ASTNode_setType_11)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_REAL);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setReal(node, 2.3);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_REAL );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 2.3));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 2.3));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_FUNCTION_COS);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_COS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST



START_TEST (test_ASTNode_setType_12)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_INTEGER);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setInteger(node, 2);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 2);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 0));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 2);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_DIVIDE);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_13)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  ASTNode_setDefinitionURLString(node, "my_url");
  ASTNode_setName(node, "t");


  fail_unless( ASTNode_getType(node) == AST_NAME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "my_url") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "my_url") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_14)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME_TIME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setName(node, "t");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( ASTNode_getReal(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_LAMBDA);

  fail_unless( ASTNode_getType(node) == AST_LAMBDA );
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( ASTNode_getReal(node) == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_15)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME_TIME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setName(node, "t");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( ASTNode_getReal(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION_PIECEWISE);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_PIECEWISE );
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( ASTNode_getReal(node) == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_16)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_NAME_TIME);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setName(node, "t");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 1);
  fail_unless( ASTNode_getReal(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION_DELAY);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_DELAY );
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(ASTNode_getName(node), "t") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isName(node) == 0);
  fail_unless( ASTNode_getReal(node) == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_17)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_INTEGER);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setUnits(node, "mole");
  ASTNode_setInteger(node, 2);
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 2);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 0));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 2);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "mole") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_FUNCTION_DELAY);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_DELAY );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
                      "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_18)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_INTEGER);

  fail_unless( ASTNode_getType(node) == AST_INTEGER );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_19)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION_COS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_FUNCTION_COS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_RATIONAL);

  fail_unless( ASTNode_getType(node) == AST_RATIONAL );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_20)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_REAL_E);

  fail_unless( ASTNode_getType(node) == AST_REAL_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_21)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_REAL);

  fail_unless( ASTNode_getType(node) == AST_REAL );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_22)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 0);
  safe_free(id);
  safe_free(units);


  ASTNode_setType(node, AST_NAME);

  fail_unless( ASTNode_getType(node) == AST_NAME );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 1);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_23)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 0);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_CONSTANT_E);

  fail_unless( ASTNode_getType(node) == AST_CONSTANT_E );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_isConstant(node) == 1);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_24)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "") == 0);
  safe_free(url);
  fail_unless( ASTNode_isConstant(node) == 0);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_NAME_AVOGADRO);

  fail_unless( ASTNode_getType(node) == AST_NAME_AVOGADRO );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 6.02214179e23));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 6.02214179e23));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "avogadro") == 0);
  fail_unless( ASTNode_isName(node) == 1);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/avogadro") == 0);
  safe_free(url);
  fail_unless( ASTNode_isConstant(node) == 1);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_25)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "") == 0);
  safe_free(url);
  fail_unless( ASTNode_isConstant(node) == 0);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_NAME_TIME);

  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 0));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 1);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  fail_unless( ASTNode_isConstant(node) == 0);
  safe_free(id);
  safe_free(units);


  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_26)
{
  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION_DELAY);
  Model_t * m = Model_create(3, 1);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));


  fail_unless( ASTNode_getType(node) == AST_FUNCTION_DELAY );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( ASTNode_getMantissa(node) == 0);
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  char* id = ASTNode_getId(node);
  char* units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "delay") == 0);
  fail_unless( ASTNode_isName(node) == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);

  ASTNode_setType(node, AST_NAME_TIME);

  fail_unless( ASTNode_getType(node) == AST_NAME_TIME );
  fail_unless( ASTNode_getInteger(node) == 0);
  fail_unless( util_isEqual(ASTNode_getMantissa(node), 0));
  fail_unless( ASTNode_getExponent(node) == 0);
  fail_unless( ASTNode_getDenominator(node) == 1);
  fail_unless( ASTNode_getNumerator(node) == 0);
  fail_unless( util_isEqual(ASTNode_getReal(node), 0));
  id = ASTNode_getId(node);
  units = ASTNode_getUnits(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( strcmp(units, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  fail_unless( ASTNode_isName(node) == 1);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/time") == 0);
  safe_free(url);
  safe_free(id);
  safe_free(units);

  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_27)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_PLUS);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2,(SBase_t*)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_PLUS );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t*)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION_COS);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_COS );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_28)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_RELATIONAL_NEQ);

  fail_unless( ASTNode_getType(node) == AST_RELATIONAL_NEQ );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_29)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_LOGICAL_OR);

  fail_unless( ASTNode_getType(node) == AST_LOGICAL_OR );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_30)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_31)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION_DELAY);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_DELAY );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "delay") == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( ASTNode_getName(node) == NULL);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_32)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_LAMBDA);

  fail_unless( ASTNode_getType(node) == AST_LAMBDA );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_33)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_DIVIDE);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_DIVIDE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION_PIECEWISE);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_PIECEWISE );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_34)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  ASTNode_setName(node, "my_func");
  ASTNode_setDefinitionURLString(node, "my_url");
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "my_func") == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "my_url") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_FUNCTION_DELAY);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION_DELAY );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "my_func") == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "http://www.sbml.org/sbml/symbols/delay") == 0);
  safe_free(url);
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_setType_35)
{
  Model_t * m = Model_create(3, 1);

  ASTNode_t  *node = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setId(node, "s");
  ASTNode_setParentSBMLObject(node, (SBase_t*)(m));
  ASTNode_setName(node, "my_func");
  ASTNode_setDefinitionURLString(node, "my_url");
  
  ASTNode_t * c1 = ASTNode_createWithType(AST_NAME);
  ASTNode_setId(c1, "c1");
  ASTNode_setName(c1, "child");
  ASTNode_addChild(node, c1);

  ASTNode_t * c2 = ASTNode_createWithType(AST_REAL);
  ASTNode_setParentSBMLObject(c2, (SBase_t *)(m));
  ASTNode_setReal(c2, 3.2);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getType(node) == AST_FUNCTION );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  char* id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "my_func") == 0);
  char* url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, 
    "my_url") == 0);
  safe_free(url);
  safe_free(id);

  ASTNode_t *child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);

  ASTNode_setType(node, AST_LAMBDA);

  fail_unless( ASTNode_getType(node) == AST_LAMBDA );
  fail_unless( ASTNode_getNumChildren(node) == 2);
  id = ASTNode_getId(node);
  fail_unless( strcmp(id, "s") == 0);
  fail_unless( ASTNode_getParentSBMLObject(node) == (SBase_t *)(m));
  fail_unless( strcmp(ASTNode_getName(node), "my_func") == 0);
  url = ASTNode_getDefinitionURLString(node);
  fail_unless( strcmp(url, "") == 0);
  safe_free(url);
  safe_free(id);

  child = ASTNode_getChild(node, 0);

  fail_unless( ASTNode_getType(child) == AST_NAME );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "c1") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == NULL);
  fail_unless( strcmp(ASTNode_getName(child), "child") == 0);
  safe_free(id);

  child = ASTNode_getChild(node, 1);

  fail_unless( ASTNode_getType(child) == AST_REAL );
  fail_unless( ASTNode_getNumChildren(child) == 0);
  id = ASTNode_getId(child);
  fail_unless( strcmp(id, "") == 0);
  fail_unless( ASTNode_getParentSBMLObject(child) == (SBase_t *)(m));
  fail_unless( util_isEqual(ASTNode_getReal(child), 3.2));
  safe_free(id);



  ASTNode_free(node);
  Model_free(m);
}
END_TEST


START_TEST (test_ASTNode_no_children)
{
  ASTNode_t *node = ASTNode_create();


  fail_unless( ASTNode_getNumChildren(node) == 0 );

  fail_unless( ASTNode_getLeftChild (node) == NULL );
  fail_unless( ASTNode_getRightChild(node) == NULL );

  fail_unless( ASTNode_getChild(node, 0) == NULL );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_one_child)
{
  ASTNode_t *node  = ASTNode_create();
  ASTNode_t *child = ASTNode_create();


  ASTNode_addChild(node, child);

  fail_unless( ASTNode_getNumChildren(node) == 1 );

  fail_unless( ASTNode_getLeftChild (node) == child );
  fail_unless( ASTNode_getRightChild(node) == NULL  );

  fail_unless( ASTNode_getChild(node, 0) == child );
  fail_unless( ASTNode_getChild(node, 1) == NULL  );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_children)
{
  ASTNode_t *parent = ASTNode_create();
  ASTNode_t *left   = ASTNode_create();
  ASTNode_t *right  = ASTNode_create();
  ASTNode_t *right2 = ASTNode_create();


  ASTNode_setType(parent, AST_PLUS);
  ASTNode_setInteger(left  , 1);
  ASTNode_setInteger(right , 2);
  ASTNode_setInteger(right2, 3);

  /**
   * Two Children
   */
  ASTNode_addChild( parent, left  );
  ASTNode_addChild( parent, right );

  fail_unless( ASTNode_getNumChildren(parent) == 2 );
  fail_unless( ASTNode_getNumChildren(left)   == 0 );
  fail_unless( ASTNode_getNumChildren(right)  == 0 );

  fail_unless( ASTNode_getLeftChild (parent) == left  );
  fail_unless( ASTNode_getRightChild(parent) == right );

  fail_unless( ASTNode_getChild(parent, 0) == left  );
  fail_unless( ASTNode_getChild(parent, 1) == right );
  fail_unless( ASTNode_getChild(parent, 2) == NULL  );

  /**
   * Three Children
   */
  ASTNode_addChild(parent, right2);

  fail_unless( ASTNode_getNumChildren(parent) == 3 );
  fail_unless( ASTNode_getNumChildren(left)   == 0 );
  fail_unless( ASTNode_getNumChildren(right)  == 0 );
  fail_unless( ASTNode_getNumChildren(right2) == 0 );

  fail_unless( ASTNode_getLeftChild (parent) == left   );
  fail_unless( ASTNode_getRightChild(parent) == right2 );

  fail_unless( ASTNode_getChild(parent, 0) == left   );
  fail_unless( ASTNode_getChild(parent, 1) == right  );
  fail_unless( ASTNode_getChild(parent, 2) == right2 );
  fail_unless( ASTNode_getChild(parent, 3) == NULL   );

  ASTNode_free(parent);
}
END_TEST


START_TEST (test_ASTNode_getListOfNodes)
{
  const char *gaussian =
  (
    "(1 / (sigma * sqrt(2 * pi))) * exp( -(x - mu)^2 / (2 * sigma^2) )"
  );

  ASTNode_t *root, *node;
  List_t    *list;


  root = SBML_parseFormula(gaussian);
  list = ASTNode_getListOfNodes(root, (ASTNodePredicate) ASTNode_isName);

  fail_unless( List_size(list) == 4 );


  node = (ASTNode_t *) List_get(list, 0);

  fail_unless( ASTNode_isName(node) );
  fail_unless( !strcmp(ASTNode_getName(node), "sigma") );

  node = (ASTNode_t *) List_get(list, 1);

  fail_unless( ASTNode_isName(node) );
  fail_unless( !strcmp(ASTNode_getName(node), "x") );

  node = (ASTNode_t *) List_get(list, 2);

  fail_unless( ASTNode_isName(node) );
  fail_unless( !strcmp(ASTNode_getName(node), "mu") );

  node = (ASTNode_t *) List_get(list, 3);

  fail_unless( ASTNode_isName(node) );
  fail_unless( !strcmp(ASTNode_getName(node), "sigma") );

  List_free(list);
  ASTNode_free(root);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *arg = ASTNode_create();
  const char* bvar = "foo";

  ASTNode_setType(node, AST_PLUS);
  ASTNode_setName(c1, "foo");
  ASTNode_setName(c2, "foo2");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);

  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 0)), "foo")); 


  ASTNode_setName(arg, "repl");

  ASTNode_replaceArgument(node, bvar, arg);

  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 0)), "repl")); 

  ASTNode_free(node);
  ASTNode_free(arg);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument1)
{
  ASTNode_t *node = SBML_parseFormula("x*y");
  ASTNode_t *user = ASTNode_createWithType(AST_FUNCTION);
  ASTNode_setName(user, "f");

  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();

  const char* bvar = "x";

  ASTNode_setName(c1, "x");
  ASTNode_setName(c2, "y");
  ASTNode_addChild(user, c1);
  ASTNode_addChild(user, c2);
  
  char* math = SBML_formulaToString(user);
  fail_unless( !strcmp(math, "f(x, y)")); 
  safe_free(math);


  ASTNode_replaceArgument(node, bvar, user);
  
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "f(x, y) * y")); 
  safe_free(math);

  ASTNode_free(node);
  ASTNode_free(user);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument2)
{
  ASTNode_t *node = SBML_parseFormula("x*y");
  ASTNode_t *user = ASTNode_createWithType(AST_NAME_TIME);
  ASTNode_setName(user, "f");

  const char* bvar = "x";

  ASTNode_replaceArgument(node, bvar, user);
  
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "f * y")); 
  safe_free(math);
  ASTNode_t * child = ASTNode_getChild(node, 0);

  fail_unless (ASTNode_getType(child) == AST_NAME_TIME);

  ASTNode_free(node);
  ASTNode_free(user);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument3)
{
  ASTNode_t *node = SBML_parseFormula("piecewise(x, gt(x, y), x)");
  ASTNode_t *repl1 = SBML_parseFormula("a/b");
  ASTNode_t *repl2 = SBML_parseFormula("2");

  const char* bvar = "x";

  ASTNode_replaceArgument(node, bvar, repl2);
  
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(2, gt(2, y), 2)")); 
  safe_free(math);

  ASTNode_replaceArgument(node, "y", repl1);
  
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(2, gt(2, a / b), 2)")); 
  safe_free(math);
  ASTNode_free(node);
  ASTNode_free(repl1);
  ASTNode_free(repl2);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument4)
{
  ASTNode_t *node = SBML_parseFormula("piecewise(x, gt(x, y), y)");
  ASTNode_t *repl1 = SBML_parseFormula("a/b");
  ASTNode_t *repl2 = SBML_parseFormula("2");

  const char* bvar = "x";

  ASTNode_replaceArgument(node, bvar, repl2);
  
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(2, gt(2, y), y)")); 
  safe_free(math);

  ASTNode_replaceArgument(node, "y", repl1);
  
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(2, gt(2, a / b), a / b)")); 
  safe_free(math);
  ASTNode_free(node);
  ASTNode_free(repl1);
  ASTNode_free(repl2);
}
END_TEST


START_TEST (test_ASTNode_replaceArgument5)
{
  ASTNode_t *node = SBML_parseFormula("piecewise(y, gt(x, y), x)");
  ASTNode_t *repl1 = SBML_parseFormula("a/b");
  ASTNode_t *repl2 = SBML_parseFormula("2");

  const char* bvar = "x";

  ASTNode_replaceArgument(node, bvar, repl2);
  
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(y, gt(2, y), 2)")); 
  safe_free(math);

  ASTNode_replaceArgument(node, "y", repl1);
  
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "piecewise(a / b, gt(2, a / b), 2)")); 
  safe_free(math);
  ASTNode_free(node);
  ASTNode_free(repl1);
  ASTNode_free(repl2);
}
END_TEST


START_TEST (test_ASTNode_removeChild)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_PLUS);
  ASTNode_setName(c1, "foo");
  ASTNode_setName(c2, "foo2");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getNumChildren(node) == 2); 


  i = ASTNode_removeChild(node, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 1); 

  i = ASTNode_removeChild(node, 1);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( ASTNode_getNumChildren(node) == 1); 

  i = ASTNode_removeChild(node, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 0); 

  ASTNode_free(node);
  ASTNode_free(c1);
  ASTNode_free(c2);
}
END_TEST


START_TEST (test_ASTNode_replaceChild)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *c3 = ASTNode_create();
  ASTNode_t *c4 = ASTNode_create();
  ASTNode_t *c5 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_LOGICAL_AND);
  ASTNode_setName(c1, "a");
  ASTNode_setName(c2, "b");
  ASTNode_setName(c3, "c");
  ASTNode_setName(c4, "d");
  ASTNode_setName(c5, "e");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);
  ASTNode_addChild(node, c3);

  fail_unless( ASTNode_getNumChildren(node) == 3); 
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b, c)"));
  safe_free(math);

  i = ASTNode_replaceChild(node, 0, c4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 3);
  math = SBML_formulaToString(node); 
  fail_unless( !strcmp(math, "and(d, b, c)"));
  safe_free(math);

  i = ASTNode_replaceChild(node, 3, c4);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( ASTNode_getNumChildren(node) == 3); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(d, b, c)"));
  safe_free(math);

  i = ASTNode_replaceChild(node, 1, c5);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 3); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(d, e, c)"));
  safe_free(math);

  ASTNode_free(node);
  ASTNode_free(c1);
  ASTNode_free(c2);
}
END_TEST


START_TEST (test_ASTNode_insertChild)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *c3 = ASTNode_create();
  ASTNode_t *newc = ASTNode_create();
  ASTNode_t *newc1 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_LOGICAL_AND);
  ASTNode_setName(c1, "a");
  ASTNode_setName(c2, "b");
  ASTNode_setName(c3, "c");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);
  ASTNode_addChild(node, c3);

  fail_unless( ASTNode_getNumChildren(node) == 3); 
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b, c)"));
  safe_free(math);

  ASTNode_setName(newc, "d");
  ASTNode_setName(newc1, "e");

  i = ASTNode_insertChild(node, 1, newc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 4); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, d, b, c)"));
  safe_free(math);

  i = ASTNode_insertChild(node, 5, newc);

  fail_unless( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless( ASTNode_getNumChildren(node) == 4); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, d, b, c)"));
  safe_free(math);

  i = ASTNode_insertChild(node, 2, newc1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 5); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, d, e, b, c)"));
  safe_free(math);

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_swapChildren)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *node_1 = ASTNode_create();
  ASTNode_t *c1_1 = ASTNode_create();
  ASTNode_t *c2_1 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_LOGICAL_AND);
  ASTNode_setName(c1, "a");
  ASTNode_setName(c2, "b");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getNumChildren(node) == 2); 
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b)"));
  safe_free(math);

  ASTNode_setType(node_1, AST_LOGICAL_AND);
  ASTNode_setName(c1_1, "d");
  ASTNode_setName(c2_1, "f");
  ASTNode_addChild(node_1, c1_1);
  ASTNode_addChild(node_1, c2_1);

  fail_unless( ASTNode_getNumChildren(node_1) == 2); 
  math = SBML_formulaToString(node_1);
  fail_unless( !strcmp(math, "and(d, f)"));
  safe_free(math);

  i = ASTNode_swapChildren(node, node_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 2); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(d, f)"));
  safe_free(math);
  fail_unless( ASTNode_getNumChildren(node_1) == 2); 
  math = SBML_formulaToString(node_1);
  fail_unless( !strcmp(math, "and(a, b)"));
  safe_free(math);

  ASTNode_free(node_1);
  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_addChild1)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *c1_1 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_LOGICAL_AND);
  ASTNode_setName(c1, "a");
  ASTNode_setName(c2, "b");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getNumChildren(node) == 2); 
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b)"));
  safe_free(math);

  ASTNode_setName(c1_1, "d");

  i = ASTNode_addChild(node, c1_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 3); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b, d)"));
  safe_free(math);
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 0)), "a") );
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 1)), "b") );
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 2)), "d") );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_prependChild1)
{
  ASTNode_t *node = ASTNode_create();
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_t *c1_1 = ASTNode_create();
  int i = 0;

  ASTNode_setType(node, AST_LOGICAL_AND);
  ASTNode_setName(c1, "a");
  ASTNode_setName(c2, "b");
  ASTNode_addChild(node, c1);
  ASTNode_addChild(node, c2);

  fail_unless( ASTNode_getNumChildren(node) == 2); 
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(a, b)"));
  safe_free(math);

  ASTNode_setName(c1_1, "d");

  i = ASTNode_prependChild(node, c1_1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumChildren(node) == 3); 
  math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "and(d, a, b)"));
  safe_free(math);
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 0)), "d") );
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 1)), "a") );
  fail_unless( !strcmp(ASTNode_getName(ASTNode_getChild(node, 2)), "b") );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_freeName)
{
  ASTNode_t *node = ASTNode_create();
  int i = 0;

  i = ASTNode_setName(node, "a");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  char* math = SBML_formulaToString(node);
  fail_unless( !strcmp(math, "a"));
  safe_free(math);
  fail_unless( !strcmp(ASTNode_getName(node), "a") );

  i = ASTNode_freeName(node);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getName(node) == NULL );

  i = ASTNode_freeName(node);

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( ASTNode_getName(node) == NULL );

  ASTNode_setType(node, AST_UNKNOWN);

  i = ASTNode_freeName(node);

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless( ASTNode_getName(node) == NULL );

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_addSemanticsAnnotation)
{
  XMLNode_t *ann = XMLNode_create();
  ASTNode_t *node = ASTNode_create();
  int i = 0;

  i = ASTNode_addSemanticsAnnotation(node, ann);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( ASTNode_getNumSemanticsAnnotations(node) == 1);

  i = ASTNode_addSemanticsAnnotation(node, NULL);

  fail_unless(i == LIBSBML_OPERATION_FAILED);
  fail_unless( ASTNode_getNumSemanticsAnnotations(node) == 1);

  ASTNode_free(node);
}
END_TEST


START_TEST (test_ASTNode_units)
{
  ASTNode_t *n = ASTNode_create();


  ASTNode_setType(n, AST_REAL);
  ASTNode_setReal(n, 1.6);
  
  int i = ASTNode_setUnits(n, "mole");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetUnits(n) == 1);
  char* units = ASTNode_getUnits(n);
  fail_unless(!strcmp(units, "mole"));
  safe_free(units);

  i = ASTNode_unsetUnits(n);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetUnits(n) == 0);
  units = ASTNode_getUnits(n);
  fail_unless(!strcmp(units, ""));
  safe_free(units);

  i = ASTNode_setUnits(n, "1mole");

  fail_unless(i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless(ASTNode_isSetUnits(n) == 0);

  ASTNode_setType(n, AST_FUNCTION);

  i = ASTNode_setUnits(n, "mole");

  fail_unless(i == LIBSBML_UNEXPECTED_ATTRIBUTE);
  fail_unless(ASTNode_isSetUnits(n) == 0);
  units = ASTNode_getUnits(n);
  fail_unless(!strcmp(units, ""));
  safe_free(units);


  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_id)
{
  int i;
  ASTNode_t *n = ASTNode_create();

  i = ASTNode_setId(n, "test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetId(n) == 1);
  char* id = ASTNode_getId(n);
  fail_unless(!strcmp(id, "test"));
  safe_free(id);

  i = ASTNode_unsetId(n);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetId(n) == 0);
  id = ASTNode_getId(n);
  fail_unless(!strcmp(id, ""));
  safe_free(id);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_class)
{
  int i;
  ASTNode_t *n = ASTNode_create();

  i = ASTNode_setClass(n, "test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetClass(n) == 1);
  char* nclass = ASTNode_getClass(n);
  fail_unless(!strcmp(nclass, "test"));
  safe_free(nclass);

  i = ASTNode_unsetClass(n);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetClass(n) == 0);
  nclass = ASTNode_getClass(n);
  fail_unless(!strcmp(nclass, ""));
  safe_free(nclass);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_style)
{
  int i;
  ASTNode_t *n = ASTNode_create();

  i = ASTNode_setStyle(n, "test");

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetStyle(n) == 1);
  char* style = ASTNode_getStyle(n);
  fail_unless(!strcmp(style, "test"));
  safe_free(style);

  i = ASTNode_unsetStyle(n);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_isSetStyle(n) == 0);
  style = ASTNode_getStyle(n);
  fail_unless(!strcmp(style, ""));
  safe_free(style);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_avogadro)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_setType(n, AST_NAME_AVOGADRO);
  ASTNode_setName(n, "NA");

  fail_unless(!strcmp(ASTNode_getName(n), "NA"));
  double val = ASTNode_getReal(n);
  fail_unless(val == 6.02214179e23);
  fail_unless(ASTNode_isConstant(n) == 1);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_avogadro_bug)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_setName(n, "NA");
  ASTNode_setType(n, AST_NAME_AVOGADRO);

  fail_unless(!strcmp(ASTNode_getName(n), "NA"));
  double val = ASTNode_getReal(n);
  fail_unless(val == 6.02214179e23);
  fail_unless(ASTNode_isConstant(n) == 1);

  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_accessWithNULL)
{
  fail_unless( ASTNode_addChild (NULL, NULL) == LIBSBML_INVALID_OBJECT);  
  fail_unless( ASTNode_addSemanticsAnnotation (NULL, NULL) 
                == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_canonicalize (NULL) == 0);
  fail_unless( ASTNode_createFromToken (NULL) == NULL);
  fail_unless( ASTNode_deepCopy (NULL) == NULL);  

  // survive NULL access
  ASTNode_fillListOfNodes (NULL,NULL, NULL);
  ASTNode_free (NULL);  

  fail_unless( ASTNode_freeName (NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_getCharacter (NULL) == CHAR_MAX);
  fail_unless( ASTNode_getChild (NULL, 0) == NULL);
  fail_unless( ASTNode_getDenominator (NULL) == LONG_MAX);
  fail_unless( ASTNode_getExponent (NULL) == LONG_MAX);
  fail_unless( ASTNode_getInteger (NULL) == LONG_MAX);
  fail_unless( ASTNode_getLeftChild (NULL) == NULL);
  fail_unless( ASTNode_getListOfNodes (NULL, NULL) == NULL);
  fail_unless( util_isNaN(ASTNode_getMantissa (NULL)) );
  fail_unless( ASTNode_getName (NULL) == NULL);
  fail_unless( ASTNode_getNumChildren (NULL) == 0);
  fail_unless( ASTNode_getNumerator (NULL) == LONG_MAX);
  fail_unless( ASTNode_getNumSemanticsAnnotations (NULL) == 0);
  fail_unless( ASTNode_getParentSBMLObject (NULL) == NULL);
  fail_unless( ASTNode_getPrecedence (NULL) == 6);
  fail_unless( util_isNaN(ASTNode_getReal (NULL)));
  fail_unless( ASTNode_getRightChild (NULL) == NULL);
  fail_unless( ASTNode_getSemanticsAnnotation (NULL, 0) == NULL);
  fail_unless( ASTNode_getType (NULL) == AST_UNKNOWN);
  fail_unless( ASTNode_getUnits (NULL) == NULL);
  fail_unless( ASTNode_getUserData (NULL) == NULL);
  fail_unless( ASTNode_hasCorrectNumberArguments (NULL) == 0);
  fail_unless( ASTNode_hasUnits (NULL) == 0);
  fail_unless( ASTNode_insertChild (NULL, 0, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_isBoolean (NULL) == 0);
  fail_unless( ASTNode_returnsBoolean (NULL) == 0);
  fail_unless( ASTNode_isConstant (NULL) == 0);
  fail_unless( ASTNode_isFunction (NULL) == 0);
  fail_unless( ASTNode_isInfinity (NULL) == 0);
  fail_unless( ASTNode_isInteger (NULL) == 0);
  fail_unless( ASTNode_isLambda (NULL) == 0);
  fail_unless( ASTNode_isLog10 (NULL) == 0);
  fail_unless( ASTNode_isLogical (NULL) == 0);
  fail_unless( ASTNode_isName (NULL) == 0);
  fail_unless( ASTNode_isNaN (NULL) == 0);
  fail_unless( ASTNode_isNegInfinity (NULL) == 0);
  fail_unless( ASTNode_isNumber (NULL) == 0);
  fail_unless( ASTNode_isOperator (NULL) == 0);
  fail_unless( ASTNode_isPiecewise (NULL) == 0);
  fail_unless( ASTNode_isRational (NULL) == 0);
  fail_unless( ASTNode_isReal (NULL) == 0);
  fail_unless( ASTNode_isRelational (NULL) == 0);
  fail_unless( ASTNode_isSetUnits (NULL) == 0);
  fail_unless( ASTNode_isSqrt (NULL) == 0);
  fail_unless( ASTNode_isUMinus (NULL) == 0);
  fail_unless( ASTNode_isUPlus (NULL) == 0);
  fail_unless( ASTNode_isUnknown (NULL) == 0);
  fail_unless( ASTNode_isWellFormedASTNode (NULL) == 0);
  fail_unless( ASTNode_prependChild (NULL, NULL) == LIBSBML_INVALID_OBJECT);
  
  // don't crash
  ASTNode_reduceToBinary (NULL);
  ASTNode_replaceArgument (NULL, NULL, NULL);
  
  fail_unless( ASTNode_removeChild (NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_replaceChild (NULL, 0, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setCharacter (NULL, CHAR_MAX) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setInteger (NULL, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setName (NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setRational (NULL, 0, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setReal (NULL, 0.0) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setRealWithExponent (NULL, 0.0, 0) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setType (NULL, AST_UNKNOWN) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setUnits (NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_setUserData (NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_swapChildren (NULL, NULL) == LIBSBML_INVALID_OBJECT);
  fail_unless( ASTNode_unsetUnits (NULL) == LIBSBML_INVALID_OBJECT);
}
END_TEST

START_TEST (test_ASTNode_isBoolean)
{
  ASTNode_t *n;// = ASTNode_createWithType(AST_FUNCTION);
  n = ASTNode_createWithType(AST_PLUS);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_MINUS);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_TIMES);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_DIVIDE);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_POWER);
  fail_unless(! ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_INTEGER);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_REAL);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_REAL_E);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RATIONAL);
  fail_unless(! ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME_AVOGADRO);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME_TIME);
  fail_unless(! ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_E);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_FALSE);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_PI);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_TRUE);
  fail_unless( ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LAMBDA);
  fail_unless(! ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ABS);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOS);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOSH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOT);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOTH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCSC);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCSCH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSEC);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSECH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSIN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSINH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCTAN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCTANH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CEILING);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COS);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COSH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COT);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COTH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CSC);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CSCH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_DELAY);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_EXP);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_FACTORIAL);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_FLOOR);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_LN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_LOG);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_PIECEWISE);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_POWER);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ROOT);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SEC);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SECH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SIN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SINH);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_TAN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_TANH);
  fail_unless(! ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_AND);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_NOT);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_OR);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_XOR);
  fail_unless( ASTNode_isBoolean(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_EQ);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_GEQ);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_GT);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_LEQ);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_LT);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_NEQ);
  fail_unless( ASTNode_isBoolean(n));
  ASTNode_free(n);

  n = ASTNode_createWithType(AST_UNKNOWN);
  fail_unless(! ASTNode_isBoolean(n));
  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_returnsBoolean)
{
  const ASTNode_t *math;

  // boolean function
  ASTNode* n = SBML_parseFormula("geq(a,b)");
  fail_unless(ASTNode_returnsBoolean(n) == 1);
  ASTNode_free(n);

  // not boolean function
  n = SBML_parseFormula("times(a,b)");
  fail_unless(ASTNode_returnsBoolean(n) == 0);
  ASTNode_free(n);

  // piecewise with bool
  n = SBML_parseFormula("piecewise(true, geq(X, T), false)");
  fail_unless(ASTNode_returnsBoolean(n) == 1);
  ASTNode_free(n);

  // piecewise no boolean
  n = SBML_parseFormula("piecewise(true, geq(X, T), 5)");
  fail_unless(ASTNode_returnsBoolean(n) == 0);
  ASTNode_free(n);

  // func with no model
  n = SBML_parseFormula("func1(X)");
  fail_unless(ASTNode_returnsBoolean(n) == 0);

  // func with model that does not contain that func
  SBMLDocument_t *doc = SBMLDocument_createWithLevelAndVersion(3,1);
  Model_t* model = SBMLDocument_createModel(doc);
  Constraint_t *c = Model_createConstraint(model);
  Constraint_setMath(c, n);

  math = Constraint_getMath(c);
  fail_unless(ASTNode_returnsBoolean(math) == 0);

  // func with model but func has no math
  FunctionDefinition_t* fd = Model_createFunctionDefinition(model);
  FunctionDefinition_setId(fd, "func1");
  fail_unless(ASTNode_returnsBoolean(math) == 0);

  // func with model func returns boolean
  ASTNode* m = SBML_parseFormula("lambda(x, true)");
  FunctionDefinition_setMath(fd, m);
  ASTNode_free(m);
  fail_unless(ASTNode_returnsBoolean(math) == 1);

  // func with model func returns number
  m = SBML_parseFormula("lambda(x, 6)");
  FunctionDefinition_setMath(fd, m);
  ASTNode_free(m);
  fail_unless(ASTNode_returnsBoolean(math) == 0);
  ASTNode_free(n);
  SBMLDocument_free(doc);
}
END_TEST

START_TEST (test_ASTNode_isAvogadro)
{
  ASTNode_t *n;// = ASTNode_createWithType(AST_FUNCTION);
  n = ASTNode_createWithType(AST_PLUS);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_MINUS);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_TIMES);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_DIVIDE);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_POWER);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_INTEGER);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_REAL);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_REAL_E);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RATIONAL);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME_AVOGADRO);
  fail_unless( ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_NAME_TIME);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_E);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_FALSE);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_PI);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_CONSTANT_TRUE);
  fail_unless( ! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LAMBDA);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ABS);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOS);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOSH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCOTH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCSC);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCCSCH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSEC);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSECH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSIN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCSINH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCTAN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ARCTANH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CEILING);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COS);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COSH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_COTH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CSC);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_CSCH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_DELAY);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_EXP);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_FACTORIAL);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_FLOOR);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_LN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_LOG);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_PIECEWISE);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_POWER);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_ROOT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SEC);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SECH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SIN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_SINH);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_TAN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_FUNCTION_TANH);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_AND);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_NOT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_OR);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_LOGICAL_XOR);
  fail_unless(! ASTNode_isAvogadro(n));

  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_EQ);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_GEQ);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_GT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_LEQ);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_LT);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
  n = ASTNode_createWithType(AST_RELATIONAL_NEQ);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);

  n = ASTNode_createWithType(AST_UNKNOWN);
  fail_unless(! ASTNode_isAvogadro(n));
  ASTNode_free(n);
}
END_TEST

START_TEST (test_ASTNode_hasTypeAndNumChildren)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_t *c = ASTNode_create();

  ASTNode_setType(n, AST_PLUS);
  fail_unless( ASTNode_hasTypeAndNumChildren(n, AST_PLUS, 0));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_PLUS, 1));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_MINUS, 0));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_UNKNOWN, 1));

  ASTNode_setName(c, "x");
  ASTNode_addChild(n, c);
  ASTNode_setType(n, AST_FUNCTION_PIECEWISE);
  fail_unless( ASTNode_hasTypeAndNumChildren(n, AST_FUNCTION_PIECEWISE, 1));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_FUNCTION_PIECEWISE, 0));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_LOGICAL_AND, 1));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_DIVIDE, 0));

  c = ASTNode_create();
  ASTNode_setName(c, "y");
  ASTNode_addChild(n, c);
  ASTNode_setType(n, AST_DIVIDE);
  fail_unless( ASTNode_hasTypeAndNumChildren(n, AST_DIVIDE, 2));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_DIVIDE, 0));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_CONSTANT_E, 2));
  fail_unless(!ASTNode_hasTypeAndNumChildren(n, AST_RELATIONAL_EQ, 0));

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_hasUnits)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_t *c = ASTNode_create();

  ASTNode_setInteger(n, 1);
  fail_unless( ASTNode_hasUnits(n) == 0);

  ASTNode_setUnits(n, "litre");
  fail_unless( ASTNode_hasUnits(n) == 1);

  ASTNode_free(n);

  n = ASTNode_create();
  ASTNode_setType(n, AST_PLUS);
  ASTNode_setInteger(c, 2);
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_hasUnits(n) == 0);

  c = ASTNode_create();
  ASTNode_setInteger(c, 3);
  ASTNode_setUnits(c, "mole");
  ASTNode_addChild(n, c);

  fail_unless( ASTNode_hasUnits(n) == 1);

  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_reduceToBinary)
{
  ASTNode_t *n = ASTNode_create();
  ASTNode_setType(n, AST_PLUS);
  ASTNode_t *c1 = ASTNode_create();
  ASTNode_setInteger(c1, 2);
  ASTNode_t *c2 = ASTNode_create();
  ASTNode_setInteger(c2, 2);

  ASTNode_addChild(n, c1);
  ASTNode_addChild(n, c2);
  ASTNode_addChild(n, c2->deepCopy());

  fail_unless( ASTNode_getNumChildren(n) == 3);

  ASTNode_reduceToBinary(n);

  fail_unless( ASTNode_getNumChildren(n) == 2);

  ASTNode_t * child = ASTNode_getChild(n, 0);

  fail_unless(ASTNode_getNumChildren(child) == 2);

  child = ASTNode_getChild(n, 1);
  
  fail_unless(ASTNode_getNumChildren(child) == 0);


  ASTNode_free(n);
}
END_TEST


START_TEST (test_ASTNode_userData_1)
{
  ASTNode_t *n = ASTNode_create();

  Model_t * m = Model_create(3,1);
  
  fail_unless(ASTNode_getUserData(n) == NULL);

  int i = ASTNode_setUserData(n, (void*)(m));

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_getUserData(n) != NULL);
  fail_unless(ASTNode_getUserData(n) == m);
  
  i = ASTNode_setUserData(n, NULL);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ASTNode_getUserData(n) == NULL);

  ASTNode_free(n);
  Model_free(m);
}
END_TEST


Suite *
create_suite_ASTNode (void) 
{ 
  Suite *suite = suite_create("ASTNode");
  TCase *tcase = tcase_create("ASTNode");


  tcase_add_test( tcase, test_ASTNode_create                  );
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
  tcase_add_test( tcase, test_ASTNode_getName                 );
  tcase_add_test( tcase, test_ASTNode_getReal                 );
  tcase_add_test( tcase, test_ASTNode_getPrecedence           );
  tcase_add_test( tcase, test_ASTNode_isLog10                 );
  tcase_add_test( tcase, test_ASTNode_isSqrt                  );
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
  tcase_add_test( tcase, test_ASTNode_setType_1                 );
  tcase_add_test( tcase, test_ASTNode_setType_2                 );
  tcase_add_test( tcase, test_ASTNode_setType_3                 );
  tcase_add_test( tcase, test_ASTNode_setType_4                 );
  tcase_add_test( tcase, test_ASTNode_setType_5                 );
  tcase_add_test( tcase, test_ASTNode_setType_6                 );
  tcase_add_test( tcase, test_ASTNode_setType_7                 );
  tcase_add_test( tcase, test_ASTNode_setType_8                 );
  tcase_add_test( tcase, test_ASTNode_setType_9                 );
  tcase_add_test( tcase, test_ASTNode_setType_10                 );
  tcase_add_test( tcase, test_ASTNode_setType_11                 );
  tcase_add_test( tcase, test_ASTNode_setType_12                 );
  tcase_add_test( tcase, test_ASTNode_setType_13                 );
  tcase_add_test( tcase, test_ASTNode_setType_14                 );
  tcase_add_test( tcase, test_ASTNode_setType_15                 );
  tcase_add_test( tcase, test_ASTNode_setType_16                 );
  tcase_add_test( tcase, test_ASTNode_setType_17                 );
  tcase_add_test( tcase, test_ASTNode_setType_18                 );
  tcase_add_test( tcase, test_ASTNode_setType_19                 );
  tcase_add_test( tcase, test_ASTNode_setType_20                 );
  tcase_add_test( tcase, test_ASTNode_setType_21                 );
  tcase_add_test( tcase, test_ASTNode_setType_22                 );
  tcase_add_test( tcase, test_ASTNode_setType_23                 );
  tcase_add_test( tcase, test_ASTNode_setType_24                 );
  tcase_add_test( tcase, test_ASTNode_setType_25                 );
  tcase_add_test( tcase, test_ASTNode_setType_26                 );
  tcase_add_test( tcase, test_ASTNode_setType_27                 );
  tcase_add_test( tcase, test_ASTNode_setType_28                 );
  tcase_add_test( tcase, test_ASTNode_setType_29                 );
  tcase_add_test( tcase, test_ASTNode_setType_30                 );
  tcase_add_test( tcase, test_ASTNode_setType_31                 );
  tcase_add_test( tcase, test_ASTNode_setType_32                 );
  tcase_add_test( tcase, test_ASTNode_setType_33                 );
  tcase_add_test( tcase, test_ASTNode_setType_34                 );
  tcase_add_test( tcase, test_ASTNode_setType_35                 );
  tcase_add_test( tcase, test_ASTNode_no_children             );
  tcase_add_test( tcase, test_ASTNode_one_child               );
  tcase_add_test( tcase, test_ASTNode_children                );
  tcase_add_test( tcase, test_ASTNode_getListOfNodes          );
  tcase_add_test( tcase, test_ASTNode_replaceArgument         );
  tcase_add_test( tcase, test_ASTNode_replaceArgument1         );
  tcase_add_test( tcase, test_ASTNode_replaceArgument2         );
  tcase_add_test( tcase, test_ASTNode_replaceArgument3         );
  tcase_add_test( tcase, test_ASTNode_replaceArgument4         );
  tcase_add_test( tcase, test_ASTNode_replaceArgument5         );
  tcase_add_test( tcase, test_ASTNode_removeChild             );
  tcase_add_test( tcase, test_ASTNode_replaceChild            );
  tcase_add_test( tcase, test_ASTNode_insertChild             );
  tcase_add_test( tcase, test_ASTNode_swapChildren            );
  tcase_add_test( tcase, test_ASTNode_addChild1               );
  tcase_add_test( tcase, test_ASTNode_prependChild1           );
  tcase_add_test( tcase, test_ASTNode_freeName                );
  tcase_add_test( tcase, test_ASTNode_addSemanticsAnnotation  );
  tcase_add_test( tcase, test_ASTNode_units                   );
  tcase_add_test( tcase, test_ASTNode_id                      );
  tcase_add_test( tcase, test_ASTNode_class                   );
  tcase_add_test( tcase, test_ASTNode_style                   );
  tcase_add_test( tcase, test_ASTNode_avogadro                );
  tcase_add_test( tcase, test_ASTNode_avogadro_bug            );
  tcase_add_test( tcase, test_ASTNode_accessWithNULL          );
  tcase_add_test( tcase, test_ASTNode_isBoolean               );
  tcase_add_test( tcase, test_ASTNode_returnsBoolean          );
  tcase_add_test( tcase, test_ASTNode_isAvogadro              );
  tcase_add_test( tcase, test_ASTNode_hasTypeAndNumChildren   );
  tcase_add_test( tcase, test_ASTNode_hasUnits   );
  tcase_add_test( tcase, test_ASTNode_reduceToBinary   );
  tcase_add_test( tcase, test_ASTNode_userData_1   );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif


