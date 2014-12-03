/**
 * \file    TestStringBuffer.c
 * \brief   StringBuffer unit tests
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

#include <check.h>
#include <locale.h>

#include <sbml/common/common.h>
#include <sbml/util/StringBuffer.h>


static StringBuffer_t *SB;


void
StringBufferTest_setup (void)
{
  SB = StringBuffer_create(10);

  if (SB == NULL)
  {
    fail("StringBuffer_create(10) returned a NULL pointer.");
  }
}


void
StringBufferTest_teardown (void)
{
  StringBuffer_free(SB);
}


START_TEST (test_StringBuffer_create)
{
  fail_unless(StringBuffer_length(SB)   ==  0);
  fail_unless(StringBuffer_capacity(SB) == 10);
}
END_TEST


START_TEST (test_StringBuffer_free_NULL)
{
  StringBuffer_free(NULL);
}
END_TEST


START_TEST (test_StringBuffer_append)
{
  char *s, *t;


  StringBuffer_append(SB, "foo");

  fail_unless( StringBuffer_length(SB)   ==  3 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "foo") );

  StringBuffer_append(SB, "bar");

  fail_unless( StringBuffer_length(SB)   ==  6 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "foobar") );

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_appendChar)
{
  char *s, *t, *u;


  StringBuffer_appendChar(SB, '*');

  fail_unless( StringBuffer_length(SB)   ==  1 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "*") );

  StringBuffer_append(SB, "foo");

  fail_unless( StringBuffer_length(SB)   ==  4 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "*foo") );

  StringBuffer_appendChar(SB, '*');

  fail_unless( StringBuffer_length(SB)   ==  5 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  u = StringBuffer_toString(SB);
  fail_unless( !strcmp(u, "*foo*") );

  safe_free(s);
  safe_free(t);
  safe_free(u);
}
END_TEST


START_TEST (test_StringBuffer_appendInt)
{
  char *s, *t;


  StringBuffer_appendInt(SB, 1);

  fail_unless( StringBuffer_length(SB)   ==  1 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "1") );

  StringBuffer_appendChar(SB, ' ');
  StringBuffer_appendInt(SB, 23);

  fail_unless( StringBuffer_length(SB)   ==  4 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  t = StringBuffer_toString(SB);

  fail_unless( !strcmp(t, "1 23") );

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_appendReal)
{
  char *s, *t;


  StringBuffer_appendReal(SB, 1.2);

  fail_unless( StringBuffer_length(SB)   ==  3 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "1.2") );

  StringBuffer_appendChar(SB, ' ');
  StringBuffer_appendReal(SB, 3);

  fail_unless( StringBuffer_length(SB)   ==  5 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "1.2 3") );

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_appendReal_locale)
{
  char *s, *t;


  setlocale(LC_NUMERIC, "de_DE");

  StringBuffer_appendReal(SB, 1.2);

  fail_unless( StringBuffer_length(SB)   ==  3 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "1.2") );

  StringBuffer_appendChar(SB, ' ');
  StringBuffer_appendReal(SB, 3);

  fail_unless( StringBuffer_length(SB)   ==  5 );
  fail_unless( StringBuffer_capacity(SB) == 80 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "1.2 3") );

  setlocale(LC_NUMERIC, "C");

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_grow)
{
  char *s;


  StringBuffer_append(SB, "foobar");

  fail_unless( StringBuffer_length(SB)   ==  6 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  StringBuffer_grow(SB, 10);

  fail_unless( StringBuffer_length(SB)   ==  6 );
  fail_unless( StringBuffer_capacity(SB) == 20 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "foobar") );

  safe_free(s);
}
END_TEST


START_TEST (test_StringBuffer_append_grow)
{
  char *s, *t;


  StringBuffer_append(SB, "fooooooooo");

  fail_unless( StringBuffer_length(SB)   == 10 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "fooooooooo") );

  StringBuffer_append(SB, "bar");

  fail_unless( StringBuffer_length(SB)   == 13 );
  fail_unless( StringBuffer_capacity(SB) == 20 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "fooooooooobar") );

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_appendChar_grow)
{
  char *s, *t;


  StringBuffer_append(SB, "fooooooooo");

  fail_unless( StringBuffer_length(SB)   == 10 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "fooooooooo") );

  StringBuffer_appendChar(SB, '!');

  fail_unless( StringBuffer_length(SB)   == 11 );
  fail_unless( StringBuffer_capacity(SB) == 20 );

  t = StringBuffer_toString(SB);
  fail_unless( !strcmp(t, "fooooooooo!") );

  safe_free(s);
  safe_free(t);
}
END_TEST


START_TEST (test_StringBuffer_reset)
{
  StringBuffer_append(SB, "foo");

  fail_unless( StringBuffer_length(SB)   ==  3 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  StringBuffer_reset(SB);

  fail_unless( StringBuffer_length(SB)   ==  0 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  StringBuffer_append(SB, "foobarfoobar");

  fail_unless( StringBuffer_length(SB)   == 12 );
  fail_unless( StringBuffer_capacity(SB) == 20 );

  StringBuffer_reset(SB);

  fail_unless( StringBuffer_length(SB)   ==  0 );
  fail_unless( StringBuffer_capacity(SB) == 20 );
}
END_TEST


START_TEST (test_StringBuffer_toString)
{
  char *s;


  StringBuffer_append(SB, "foo");

  fail_unless( StringBuffer_length(SB)   ==  3 );
  fail_unless( StringBuffer_capacity(SB) == 10 );

  s = StringBuffer_toString(SB);
  fail_unless( !strcmp(s, "foo") );

  s[0] = 'b';

  if ( !strcmp(SB->buffer, "boo") )
  {
    fail("StringBuffer_toString() did not make a copy of its internal buffer.");
  }

  safe_free(s);
}
END_TEST

START_TEST (test_StringBuffer_accessWithNULL)
{
  StringBuffer_append(NULL, NULL);
  StringBuffer_appendChar(NULL, ' ');
  StringBuffer_appendExp(NULL, 0.0);
  StringBuffer_appendInt(NULL, 0);
  StringBuffer_appendNumber(NULL, NULL);
  StringBuffer_appendReal(NULL, 0.0);
  
  fail_unless (StringBuffer_capacity(NULL) == 0);

  StringBuffer_ensureCapacity(NULL, 0);
  StringBuffer_free(NULL);

  fail_unless (StringBuffer_getBuffer(NULL) == NULL);

  StringBuffer_grow(NULL, 0);

  fail_unless (StringBuffer_length(NULL) == 0);

  StringBuffer_reset(NULL);

  fail_unless (StringBuffer_toString(NULL) == NULL);
}
END_TEST

Suite *
create_suite_StringBuffer (void)
{
  Suite *suite = suite_create("StringBuffer");
  TCase *tcase = tcase_create("StringBuffer");

  tcase_add_checked_fixture( tcase,
                             StringBufferTest_setup,
                             StringBufferTest_teardown );

  tcase_add_test( tcase, test_StringBuffer_create            );
  tcase_add_test( tcase, test_StringBuffer_free_NULL         );
  tcase_add_test( tcase, test_StringBuffer_append            );
  tcase_add_test( tcase, test_StringBuffer_appendChar        );
  tcase_add_test( tcase, test_StringBuffer_appendInt         );
  tcase_add_test( tcase, test_StringBuffer_appendReal        );
  tcase_add_test( tcase, test_StringBuffer_appendReal_locale );
  tcase_add_test( tcase, test_StringBuffer_grow              );
  tcase_add_test( tcase, test_StringBuffer_append_grow       );
  tcase_add_test( tcase, test_StringBuffer_appendChar_grow   );
  tcase_add_test( tcase, test_StringBuffer_reset             );
  tcase_add_test( tcase, test_StringBuffer_toString          );
  tcase_add_test( tcase, test_StringBuffer_accessWithNULL    );

  suite_add_tcase(suite, tcase);

  return suite;
}
