/**
 * \file    TestFormulaTokenizer.c
 * \brief   FormulaTokenizer unit tests
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

#include <locale.h>

#include <sbml/common/common.h>
#include <sbml/math/FormulaTokenizer.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif


START_TEST (test_FormulaTokenizer_create)
{
  const char         *formula = "1 + two * 3";
  FormulaTokenizer_t *ft      = FormulaTokenizer_createFromFormula(formula);


  fail_unless( !strcmp(ft->formula, formula) );
  fail_unless( ft->pos == 0 );

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_free_NULL)
{
  FormulaTokenizer_free(NULL);
}
END_TEST


START_TEST (test_Token_create)
{
  Token_t *t = Token_create();


  fail_unless( t->type          == TT_UNKNOWN );
  fail_unless( t->value.ch      == '\0'       );
  fail_unless( t->value.name    == NULL       );
  fail_unless( t->value.integer == 0          );
  fail_unless( t->value.real    == 0.0        );
  fail_unless( t->exponent      == 0          );

  Token_free(t);
}
END_TEST


START_TEST (test_Token_free)
{
  Token_t *t = Token_create();


  t->type       = TT_NAME;
  t->value.name = safe_strdup("foo");

  Token_free(t);
}
END_TEST


START_TEST (test_Token_free_NULL)
{
  Token_free(NULL);
}
END_TEST


START_TEST (test_FormulaTokenizer_empty)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_END );
  fail_unless( t->value.ch == '\0'   );
  Token_free(t);

  /**
   * Subsequent calls to FormulaTokenizer_nextToken() should continue to
   * return TT_END.
   */
  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_END );
  fail_unless( t->value.ch == '\0'   );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_END );
  fail_unless( t->value.ch == '\0'   );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_whitespace)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula(" \t \n ");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);

  fail_unless( t->type     == TT_END );
  fail_unless( t->value.ch == '\0'   );

  Token_free(t);
  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_operators)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("+-*/^(),");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_PLUS );
  fail_unless( t->value.ch == '+'     );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_MINUS );
  fail_unless( t->value.ch == '-'      );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_TIMES );
  fail_unless( t->value.ch == '*'      );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_DIVIDE );
  fail_unless( t->value.ch == '/'       );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_POWER );
  fail_unless( t->value.ch == '^'      );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_LPAREN );
  fail_unless( t->value.ch == '('       );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_RPAREN );
  fail_unless( t->value.ch == ')'       );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_COMMA );
  fail_unless( t->value.ch == ','      );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless(t->type      == TT_END );
  fail_unless( t->value.ch == '\0'   );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_names)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("foobar Foo2Bar _Foo_Bar");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME               );
  fail_unless( !strcmp(t->value.name, "foobar") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME                );
  fail_unless( !strcmp(t->value.name, "Foo2Bar") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME                 );
  fail_unless( !strcmp(t->value.name, "_Foo_Bar") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_numbers)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("123 3.14 .007 6.7 5.");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type          == TT_INTEGER );
  fail_unless( t->value.integer == 123        );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL );
  fail_unless( t->value.real == 3.14    );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL );
  fail_unless( t->value.real == .007    );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL );
  fail_unless( t->value.real == 6.7     );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL );
  fail_unless( t->value.real == 5.0     );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_numbers_nan_inf)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("NaN Inf");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL       );
  fail_unless( t->value.real != t->value.real );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type                   == TT_REAL );
  fail_unless( util_isInf(t->value.real) == 1       );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_numbers_exp)
{
  const char         *formula = "12.3e1 .314E1 7e-3 .067e2 5E0 2e+12 3e 4";
  FormulaTokenizer_t *ft      = FormulaTokenizer_createFromFormula(formula);
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == 12.3      );
  fail_unless( t->exponent   == 1         );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == .314      );
  fail_unless( t->exponent   == 1         );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real ==  7        );
  fail_unless( t->exponent   == -3        );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == .067      );
  fail_unless( t->exponent   == 2         );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == 5.0       );
  fail_unless( t->exponent   == 0         );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == 2         );
  fail_unless( t->exponent   == 12        );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL_E );
  fail_unless( t->value.real == 3.0       );
  fail_unless( t->exponent   == 0         );
  Token_free(t);

  /**
   * Gobble-up the '4'.  This last token is here as a test to ensure the
   * previous token is not interpreted as 3e4.
   */
  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type          == TT_INTEGER );
  fail_unless( t->value.integer == 4          );
  Token_free(t);


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_numbers_locale)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("2.72");
  Token_t            *t;


  setlocale(LC_NUMERIC, "de_DE");

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type       == TT_REAL );
  fail_unless( t->value.real == 2.72    );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  setlocale(LC_NUMERIC, "C");

  FormulaTokenizer_free(ft);
}
END_TEST


START_TEST (test_FormulaTokenizer_unknown)
{
  FormulaTokenizer_t *ft = FormulaTokenizer_createFromFormula("bbornstein@acm.org");
  Token_t            *t;


  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME                   );
  fail_unless( !strcmp(t->value.name, "bbornstein") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_UNKNOWN );
  fail_unless( t->value.ch == '@'        );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME            );
  fail_unless( !strcmp(t->value.name, "acm") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type     == TT_UNKNOWN );
  fail_unless( t->value.ch == '.'        );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_NAME            );
  fail_unless( !strcmp(t->value.name, "org") );
  Token_free(t);

  t = FormulaTokenizer_nextToken(ft);
  fail_unless( t->type == TT_END );
  Token_free(t);

  FormulaTokenizer_free(ft);
}
END_TEST

START_TEST (test_FormulaTokenizer_accessWithNULL)
{
  
  fail_unless( FormulaTokenizer_createFromFormula(NULL) == NULL );

  FormulaTokenizer_free(NULL);

  fail_unless( FormulaTokenizer_nextToken(NULL) == NULL );

}
END_TEST

Suite *
create_suite_FormulaTokenizer (void) 
{ 
  Suite *suite = suite_create("FormulaTokenizer");
  TCase *tcase = tcase_create("FormulaTokenizer");
 

  tcase_add_test( tcase, test_FormulaTokenizer_create    );
  tcase_add_test( tcase, test_FormulaTokenizer_free_NULL );
  tcase_add_test( tcase, test_Token_create               );
  tcase_add_test( tcase, test_Token_free                 );
  tcase_add_test( tcase, test_Token_free_NULL            );

  tcase_add_test( tcase, test_FormulaTokenizer_empty           );
  tcase_add_test( tcase, test_FormulaTokenizer_whitespace      );
  tcase_add_test( tcase, test_FormulaTokenizer_operators       );
  tcase_add_test( tcase, test_FormulaTokenizer_names           );
  tcase_add_test( tcase, test_FormulaTokenizer_numbers         );
  tcase_add_test( tcase, test_FormulaTokenizer_numbers_exp     );
  tcase_add_test( tcase, test_FormulaTokenizer_numbers_nan_inf );
  tcase_add_test( tcase, test_FormulaTokenizer_unknown         );
  tcase_add_test( tcase, test_FormulaTokenizer_numbers_locale  );
  tcase_add_test( tcase, test_FormulaTokenizer_accessWithNULL  );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif



