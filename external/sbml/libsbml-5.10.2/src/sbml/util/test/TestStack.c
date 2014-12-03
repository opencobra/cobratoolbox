/**
 * \file    TestStack.c
 * \brief   Stack unit tests
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

#include <sbml/common/common.h>
#include <sbml/util/Stack.h>


static Stack_t *S;


void
StackTest_setup (void)
{
  S = Stack_create(10);

  if (S == NULL)
  {
    fail("Stack_create(10) returned a NULL pointer.");
  }
}


void
StackTest_teardown (void)
{
  Stack_free(S);
}


START_TEST (test_Stack_create)
{
  fail_unless(Stack_size(S)     ==  0);
  fail_unless(Stack_capacity(S) == 10);
}
END_TEST


START_TEST (test_Stack_free_NULL)
{
  Stack_free(NULL);
}
END_TEST


START_TEST (test_Stack_push)
{
  Stack_push(S, "foo");

  fail_unless( Stack_size(S)     ==  1        );
  fail_unless( Stack_capacity(S) == 10        );
  fail_unless( !strcmp( Stack_peek(S), "foo") );
}
END_TEST


START_TEST (test_Stack_pop)
{
  char *item = NULL;


  Stack_push(S, "foo");
  
  item = (char *) Stack_pop(S);

  fail_unless( Stack_size(S)     ==  0 );
  fail_unless( Stack_capacity(S) == 10 );
  fail_unless( !strcmp(item, "foo")    );
}
END_TEST


START_TEST (test_Stack_popN)
{
  Stack_push(S, "foo");
  Stack_push(S, "bar");
  Stack_push(S, "baz");
  Stack_push(S, "bop");

  fail_unless( Stack_size(S) ==  4 );

  fail_unless( Stack_popN(S, 0) == NULL );
  fail_unless( Stack_size(S) == 4 );

  fail_unless( !strcmp(Stack_popN(S, 3), "bar") );
  fail_unless( Stack_size(S) == 1 );

  fail_unless( !strcmp(Stack_popN(S, 1), "foo") );
  fail_unless( Stack_size(S) == 0 );

  fail_unless( Stack_popN(S, 0) == NULL );
  fail_unless( Stack_size(S) == 0 );
}
END_TEST


START_TEST (test_Stack_peek)
{
  char *item = NULL;


  Stack_push(S, "foo");

  item = (char *) Stack_peek(S);

  fail_unless( Stack_size(S)     ==  1 );
  fail_unless( Stack_capacity(S) == 10 );
  fail_unless( !strcmp(item, "foo")    );
}
END_TEST


START_TEST (test_Stack_peekAt)
{
  char *item = NULL;


  Stack_push(S, "foo");
  Stack_push(S, "bar");
  Stack_push(S, "baz");

  fail_unless( Stack_size(S)     ==  3 );
  fail_unless( Stack_capacity(S) == 10 );

  item = (char *) Stack_peekAt(S, 0);
  fail_unless( !strcmp(item, "baz") );

  item = (char *) Stack_peekAt(S, 1);
  fail_unless( !strcmp(item, "bar") );

  item = (char *) Stack_peekAt(S, 2);
  fail_unless( !strcmp(item, "foo") );

  fail_unless( Stack_peekAt(S, -1) == NULL );
  fail_unless( Stack_peekAt(S,  3) == NULL );
}
END_TEST


START_TEST (test_Stack_size)
{
  fail_unless( Stack_size(S)     ==  0 );
  fail_unless( Stack_capacity(S) == 10 );

  Stack_push(S, "foo");

  fail_unless( Stack_size(S)     ==  1 );
  fail_unless( Stack_capacity(S) == 10 );
}
END_TEST


START_TEST (test_Stack_capacity)
{
  fail_unless(Stack_capacity(S) == 10);
}
END_TEST


START_TEST (test_Stack_grow)
{
  int  i;


  for (i = 0; i < 10; i++)
  {
    Stack_push(S, "foo");
  }

  fail_unless( Stack_size(S)     == 10 );
  fail_unless( Stack_capacity(S) == 10 );
  fail_unless( !strcmp(Stack_peek(S), "foo") );

  Stack_push(S, "bar");

  fail_unless( Stack_size(S)     == 11       );
  fail_unless( Stack_capacity(S) == 20       );
  fail_unless( !strcmp(Stack_peek(S), "bar") );
}
END_TEST


START_TEST (test_Stack_find)
{
  char *s1 = "foo";
  char *s2 = "bar";
  char *s3 = "baz";
  char *s4 = "bop";


  Stack_push(S, s1);
  Stack_push(S, s2);
  Stack_push(S, s3);

  fail_unless( Stack_find(S, s1) ==  2 );
  fail_unless( Stack_find(S, s2) ==  1 );
  fail_unless( Stack_find(S, s3) ==  0 );
  fail_unless( Stack_find(S, s4) == -1 );
}
END_TEST

START_TEST (test_Stack_accessWithNULL)
{
  fail_unless ( Stack_capacity(NULL) == 0 );
  fail_unless ( Stack_find(NULL, NULL) == -1 );

  Stack_free(NULL);

  fail_unless ( Stack_peek(NULL) == NULL );
  fail_unless ( Stack_peekAt(NULL, 0) == NULL );
  fail_unless ( Stack_pop(NULL) == NULL );
  fail_unless ( Stack_popN(NULL, 0) == NULL );

  Stack_push(NULL, NULL);

  fail_unless ( Stack_size(NULL) == 0 );

}
END_TEST


Suite *
create_suite_Stack (void)
{
  Suite *suite = suite_create("Stack");
  TCase *tcase = tcase_create("Stack");

  tcase_add_checked_fixture(tcase, StackTest_setup, StackTest_teardown);

  tcase_add_test( tcase, test_Stack_create    );
  tcase_add_test( tcase, test_Stack_free_NULL );
  tcase_add_test( tcase, test_Stack_push      );
  tcase_add_test( tcase, test_Stack_pop       );
  tcase_add_test( tcase, test_Stack_popN      );
  tcase_add_test( tcase, test_Stack_peek      );
  tcase_add_test( tcase, test_Stack_peekAt    );
  tcase_add_test( tcase, test_Stack_size      );
  tcase_add_test( tcase, test_Stack_capacity  );
  tcase_add_test( tcase, test_Stack_grow      );
  tcase_add_test( tcase, test_Stack_find      );
  tcase_add_test( tcase, test_Stack_accessWithNULL );

  suite_add_tcase(suite, tcase);

  return suite;
}
