/**
 * \file    TestUtil.h
 * \brief   utilility functions unit tests
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

#if defined(WIN32) && !defined(CYGWIN)
#include <errno.h>
#define snprintf _snprintf
#else
#include <sys/errno.h>
#endif 

#include <sbml/common/common.h>
#include <sbml/common/operationReturnValues.h>
#include <locale.h>

#include <check.h>

BEGIN_C_DECLS


START_TEST (test_c_locale_snprintf)
{
  char s[32];
  char* lc;


  lc = setlocale(LC_ALL, "de_DE");

  /**
   * These tests will fail under some platforms because of a minimal 
   * setlocale() implementation (e.g. Cygwin (see setlocale manpage)) 
   * or limited number of default locales (e.g. Ubuntu based).
   * Thus these tests will be skipped when setlocale() returns
   * NULL.
   */
  if ( lc != NULL )
  {
    fail_unless( snprintf(s, sizeof(s), "%3.2f", 3.14) == 4 );
    fail_unless( !strcmp(s, "3,14")                         );
  }

  fail_unless( c_locale_snprintf(s, sizeof(s), "%3.2f", 3.14) == 4 );
  fail_unless( !strcmp(s, "3.14")                                  );

  setlocale(LC_ALL, "C");
}
END_TEST


/**
 * The nature of vsnprintf makes it difficult to unit test using the
 * 'check' framework.  For now, since c_local_snprintf is written in terms
 * of c_locale_vsnprintf, if the "sn" test succeeds, we assume "vsn" is
 * correct.
 *
START_TEST (test_c_locale_vsnprintf)
{
}
END_TEST
*/


START_TEST (test_c_locale_strtod)
{
  const char *en = "2.72";
  char* lc;
  char *endptr;

  lc = setlocale(LC_ALL, "de_DE");

  /**
   * These tests will fail under some platforms because of a minimal 
   * setlocale() implementation (e.g. Cygwin (see setlocale manpage)) 
   * or limited number of default locales (e.g. Ubuntu based).
   * Thus these tests will be skipped when setlocale() returns
   * NULL.
   */
  if ( lc != NULL )
  {
    const char *de = "2,72";

    endptr = NULL;
    fail_unless( util_isEqual(strtod(de, &endptr), 2.72) );
    fail_unless( (endptr - de)       == 4    );
    fail_unless( errno != ERANGE             );
  }

  endptr = NULL;
  fail_unless( util_isEqual(c_locale_strtod(en, &endptr),2.72) );
  fail_unless( (endptr - en)                == 4    );
  fail_unless( errno != ERANGE                      );

  setlocale(LC_ALL, "C");
}
END_TEST


START_TEST (test_util_file_exists)
{
  fail_unless(  util_file_exists("TestUtil.c")      );
  fail_unless( !util_file_exists("NonexistentFile") );
}
END_TEST


START_TEST (test_util_strcmp_insensitive)
{
  fail_unless( strcmp_insensitive("foobar", "foobar") == 0 );
  fail_unless( strcmp_insensitive("foobar", "FooBar") == 0 );

  fail_unless( strcmp_insensitive("foobar", "FooBaz") < 0 );
  fail_unless( strcmp_insensitive("foobar", "FooBaZ") < 0 );

  fail_unless( strcmp_insensitive("foobar", "FooBab") > 0 );
  fail_unless( strcmp_insensitive("foobar", "FooBaB") > 0 );

  fail_unless( strcmp_insensitive("", "")  == 0 );

  fail_unless( strcmp_insensitive("", "a") < 0 );
  fail_unless( strcmp_insensitive("a", "") > 0 );
}
END_TEST


START_TEST (test_util_safe_strcat)
{
  char *p, *q, *r, *s;


  fail_unless( !strcmp( p = safe_strcat( "foo", "bar" ), "foobar" ) );
  fail_unless( !strcmp( q = safe_strcat( "foo", ""    ), "foo"    ) );
  fail_unless( !strcmp( r = safe_strcat( ""   , "bar" ), "bar"    ) );
  fail_unless( !strcmp( s = safe_strcat( ""   , ""    ), ""       ) );

  safe_free(p);
  safe_free(q);
  safe_free(r);
  safe_free(s);
}
END_TEST


START_TEST (test_util_trim)
{
  char *p, *q, *r, *s, *t, *u, *v, *w, *x, *y, *z;


  fail_unless( !strcmp( p = util_trim("p"  ), "p") );
  fail_unless( !strcmp( q = util_trim("q " ), "q") );
  fail_unless( !strcmp( r = util_trim(" r" ), "r") );
  fail_unless( !strcmp( s = util_trim(" s "), "s") );

  fail_unless( !strcmp( t = util_trim("foo"  ), "foo") );
  fail_unless( !strcmp( u = util_trim("foo " ), "foo") );
  fail_unless( !strcmp( v = util_trim(" bar" ), "bar") );
  fail_unless( !strcmp( w = util_trim(" bar "), "bar") );

  fail_unless( !strcmp( x = util_trim(" foo bar " ), "foo bar") );

  fail_unless( !strcmp( y = util_trim(" "), "") );
  fail_unless( !strcmp( z = util_trim("" ), "") );


  fail_unless( util_trim((char *) NULL) == NULL );

  safe_free(p);
  safe_free(q);
  safe_free(r);
  safe_free(s);
  safe_free(t);
  safe_free(u);
  safe_free(v);
  safe_free(w);
  safe_free(x);
  safe_free(y);
  safe_free(z);
}
END_TEST


START_TEST (test_util_trim_in_place)
{
  char *s = safe_malloc(100);

  strcpy(s, "p");
  fail_unless( !strcmp( util_trim_in_place(s), "p") );

  strcpy(s, "q ");
  fail_unless( !strcmp( util_trim_in_place(s), "q") );

  strcpy(s, " r");
  fail_unless( !strcmp( util_trim_in_place(s), "r") );

  strcpy(s, " s ");
  fail_unless( !strcmp( util_trim_in_place(s), "s") );

  strcpy(s, "foo");
  fail_unless( !strcmp( util_trim_in_place(s), "foo") );

  strcpy(s, "foo ");
  fail_unless( !strcmp( util_trim_in_place(s), "foo") );

  strcpy(s, " bar");
  fail_unless( !strcmp( util_trim_in_place(s), "bar") );

  strcpy(s, " bar ");
  fail_unless( !strcmp( util_trim_in_place(s), "bar") );

  strcpy(s, " foo bar ");
  fail_unless( !strcmp( util_trim_in_place(s), "foo bar") );

  strcpy(s, " ");
  fail_unless( !strcmp( util_trim_in_place(s), "") );

  strcpy(s, "");
  fail_unless( !strcmp( util_trim_in_place(s), "") );

  fail_unless( util_trim_in_place((char *) NULL) == NULL );

  safe_free(s);
}
END_TEST


START_TEST (test_util_NaN)
{
  double d = util_NaN();


  fail_unless( d != d, "util_NaN() did not return NaN.");
}
END_TEST


START_TEST (test_util_NegInf)
{
  double d = util_NegInf();


  if ( util_isFinite(d) || util_isNaN(d) || d >= 0)
  {
    fail("util_NegInf() did not return -Inf.");
  }
}
END_TEST


START_TEST (test_util_PosInf)
{
  double d = util_PosInf();


  if ( util_isFinite(d) || util_isNaN(d) || d <= 0)
  {
    fail("util_PosInf() did not return +Inf.");
  }
}
END_TEST


START_TEST (test_util_NegZero)
{
  double d = util_NegZero();


  fail_unless(d == 0, "util_NegZero() did not even return a zero!");
  fail_unless( util_isNegZero(d) );
}
END_TEST


START_TEST (test_util_isInf)
{
  fail_unless( util_isInf( util_PosInf()  ) ==  1 );
  fail_unless( util_isInf( util_NegInf()  ) == -1 );
  fail_unless( util_isInf( util_NaN()     ) ==  0 );
  fail_unless( util_isInf( util_NegZero() ) ==  0 );

  fail_unless( util_isInf(0.0) == 0 );
  fail_unless( util_isInf(1.2) == 0 );
}
END_TEST

START_TEST (test_util_accessWithNULL)
{
  fail_unless ( util_bsearchStringsI(NULL, NULL, 0, 0) == 1 );
  fail_unless ( util_file_exists(NULL) == 0 );

  util_free(NULL);

  fail_unless ( util_trim(NULL) == NULL );
  fail_unless ( util_trim_in_place(NULL) == NULL );

  fail_unless ( safe_fopen(NULL, NULL) == NULL );
  fail_unless ( safe_strcat(NULL, NULL) == NULL );
  fail_unless ( safe_strdup(NULL) == NULL );

}
END_TEST

START_TEST (test_util_operationReturn)
{
  int NONE_EXISTING_RETURN_CODE=123456;
  fail_unless(OperationReturnValue_toString(LIBSBML_OPERATION_FAILED) != NULL);
  fail_unless(OperationReturnValue_toString(LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN) != NULL);
  fail_unless(OperationReturnValue_toString(NONE_EXISTING_RETURN_CODE) == NULL);
}
END_TEST


Suite *
create_suite_util (void) 
{ 
  Suite *suite = suite_create("util");
  TCase *tcase = tcase_create("util");


  tcase_add_test( tcase, test_c_locale_snprintf       );
  tcase_add_test( tcase, test_c_locale_strtod         );
  tcase_add_test( tcase, test_util_file_exists        );
  tcase_add_test( tcase, test_util_strcmp_insensitive );
  tcase_add_test( tcase, test_util_safe_strcat        );
  tcase_add_test( tcase, test_util_trim               );
  tcase_add_test( tcase, test_util_trim_in_place      );
  tcase_add_test( tcase, test_util_NaN                );
  tcase_add_test( tcase, test_util_NegInf             );
  tcase_add_test( tcase, test_util_PosInf             );
  tcase_add_test( tcase, test_util_NegZero            );
  tcase_add_test( tcase, test_util_isInf              );
  tcase_add_test( tcase, test_util_accessWithNULL     );
  tcase_add_test( tcase, test_util_operationReturn    );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


