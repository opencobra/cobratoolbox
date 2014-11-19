/**
 * \file    TestList.c
 * \brief   List unit tests
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
#include <sbml/util/List.h>


static List_t *L;


void
ListTest_setup (void)
{
  L = List_create();

  if (L == NULL)
  {
    fail("List_create() returned a NULL pointer.");
  }
}


void
ListTest_teardown (void)
{
  List_free(L);
}


START_TEST (test_List_create)
{
  fail_unless(List_size(L) == 0);

  /*
  fail_unless(L->head == NULL);
  fail_unless(L->tail == NULL);
  */
}
END_TEST


START_TEST (test_ListNode_create)
{
  char       *s    = "foo";
  ListNode_t *node = ListNode_create(s);


  /*
  fail_unless(node->item == s   );
  fail_unless(node->next == NULL);
  */

  ListNode_free(node);
}
END_TEST


START_TEST (test_List_free_NULL)
{
  List_free(NULL);
}
END_TEST


START_TEST (test_List_add_1)
{
  List_add(L, "foo");

  fail_unless(List_size(L) == 1);

  /*
  fail_unless( !strcmp(L->head->item, "foo") );

  fail_unless(L->head       == L->tail);
  fail_unless(L->head->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_add_2)
{
  List_add(L, "foo");
  List_add(L, "bar");

  fail_unless(List_size(L) == 2);

  /*
  fail_unless( !strcmp(L->head->item      , "foo") );
  fail_unless( !strcmp(L->head->next->item, "bar") );

  fail_unless(L->head->next == L->tail);
  fail_unless(L->tail->next == NULL   );
  */
}
END_TEST


int
myPredicate (const void *item)
{
  const char *s = (char *) item;


  return s[1] == 'a';
}


START_TEST (test_List_countIf)
{
  const char *foo = "foo";
  const char *bar = "bar";
  const char *baz = "baz";
  const char *bop = "bop";

  List_add(L, (void *) foo);
  List_add(L, (void *) bop);

  fail_unless( List_countIf(L, myPredicate) == 0 );

  List_add(L, (void *) foo);
  List_add(L, (void *) bar);
  List_add(L, (void *) baz);
  List_add(L, (void *) bop);

  fail_unless( List_countIf(L, myPredicate) == 2 );

  List_add(L, (void *) baz);

  fail_unless( List_countIf(L, myPredicate) == 3 );
}
END_TEST


START_TEST (test_List_findIf)
{
  List_t *list;

  const char *foo = "foo";
  const char *bar = "bar";
  const char *baz = "baz";
  const char *bop = "bop";


  List_add(L, (void *) foo);
  List_add(L, (void *) bop);

  list = List_findIf(L, myPredicate);

  fail_unless( list            != NULL );
  fail_unless( List_size(list) == 0    );

  List_free(list);

  List_add(L, (void *) foo);
  List_add(L, (void *) bar);
  List_add(L, (void *) baz);
  List_add(L, (void *) bop);

  list = List_findIf(L, myPredicate);

  fail_unless( list              != NULL );
  fail_unless( List_size(list)   == 2    );
  fail_unless( List_get(list, 0) == bar  );
  fail_unless( List_get(list, 1) == baz  );

  List_free(list);

  List_add(L, (void *) baz);

  list = List_findIf(L, myPredicate);

  fail_unless( list              != NULL );
  fail_unless( List_size(list)   == 3    );
  fail_unless( List_get(list, 0) == bar  );
  fail_unless( List_get(list, 1) == baz  );
  fail_unless( List_get(list, 2) == baz  );

  List_free(list);
}
END_TEST


int
myStrCmp (const void *s1, const void *s2)
{
  return strcmp((const char *) s1, (const char *) s2);
}


START_TEST (test_List_find)
{
  const char *foo = "foo";
  const char *bar = "bar";
  const char *baz = "baz";
  const char *bop = "bop";

  List_add(L, (void *) foo);
  List_add(L, (void *) bar);
  List_add(L, (void *) baz);

  fail_unless( List_find(L, (void *) foo, myStrCmp) == foo  );
  fail_unless( List_find(L, (void *) bar, myStrCmp) == bar  );
  fail_unless( List_find(L, (void *) baz, myStrCmp) == baz  );
  fail_unless( List_find(L, (void *) bop, myStrCmp) == NULL );
}
END_TEST


START_TEST (test_List_get)
{
  List_add(L, "foo");
  List_add(L, "bar");

  fail_unless(List_size(L) == 2);
 
  fail_unless( !strcmp(List_get(L, 0), "foo") );
  fail_unless( !strcmp(List_get(L, 1), "bar") );

  fail_unless(List_get(L, -1) == NULL);
  fail_unless(List_get(L,  2) == NULL);
}
END_TEST


START_TEST (test_List_prepend_1)
{
  List_prepend(L, "foo");

  fail_unless(List_size(L) == 1);

  /*
  fail_unless( !strcmp(L->head->item, "foo") );

  fail_unless(L->head       == L->tail);
  fail_unless(L->head->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_prepend_2)
{
  List_prepend(L, "foo");
  List_prepend(L, "bar");

  fail_unless(List_size(L) == 2);

  /*
  fail_unless( !strcmp(L->head->item      , "bar") );
  fail_unless( !strcmp(L->head->next->item, "foo") );

  fail_unless(L->head->next == L->tail);
  fail_unless(L->tail->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_remove_1)
{
  List_add(L, "foo");

  fail_unless( !strcmp(List_remove(L, 0), "foo") );

  fail_unless(List_size(L) == 0);

  /*
  fail_unless(L->head == NULL);
  fail_unless(L->tail == NULL);
  */
}
END_TEST


START_TEST (test_List_remove_2)
{
  List_add(L, "foo");
  List_add(L, "bar");

  fail_unless( !strcmp(List_remove(L, 1), "bar") );

  fail_unless(List_size(L) == 1);

  fail_unless( !strcmp( List_get(L, 0), "foo" ) );

  /*
  fail_unless(L->head       == L->tail);
  fail_unless(L->head->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_remove_3)
{
  List_add(L, "foo");
  List_add(L, "bar");
  List_add(L, "baz");

  fail_unless( !strcmp( List_remove(L, 1), "bar" ) );

  fail_unless(List_size(L) == 2);

  fail_unless( !strcmp( List_get(L, 0), "foo" ) );
  fail_unless( !strcmp( List_get(L, 1), "baz" ) );

  /*
  fail_unless(L->head       != L->tail);
  fail_unless(L->tail->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_remove_4)
{
  List_add(L, "foo");
  List_add(L, "bar");
  List_add(L, "baz");

  fail_unless( !strcmp( List_remove(L, 2), "baz" ) );

  fail_unless(List_size(L) == 2);

  fail_unless( !strcmp( List_get(L, 0), "foo" ) );
  fail_unless( !strcmp( List_get(L, 1), "bar" ) );

  /*
  fail_unless(L->head       != L->tail);
  fail_unless(L->tail->next == NULL   );
  */
}
END_TEST


START_TEST (test_List_freeItems)
{
  List_add(L, safe_strdup("foo"));
  List_add(L, safe_strdup("bar"));
  List_add(L, safe_strdup("baz"));

  fail_unless(List_size(L) == 3);

  List_freeItems(L, safe_free, void);

  fail_unless(List_size(L) == 0);

  /*
  fail_unless(L->head      == NULL);
  fail_unless(L->tail      == NULL);
  */
}
END_TEST

START_TEST (test_List_accessWithNULL)
{

  // test null arguments
  List_add (NULL, NULL);
  
  fail_unless( List_countIf (NULL, NULL) == 0 );
  fail_unless( List_find (NULL, NULL, NULL) == NULL );
  fail_unless( List_findIf (NULL, NULL) == NULL );
  
  List_free(NULL);

  fail_unless( List_get (NULL, 0) == NULL );

  List_prepend(NULL, NULL);

  fail_unless( List_remove (NULL, 0) == NULL );
  fail_unless( List_size (NULL) == 0 );

}
END_TEST


Suite *
create_suite_List (void)
{
  Suite *suite = suite_create("List");
  TCase *tcase = tcase_create("List");


  tcase_add_checked_fixture(tcase, ListTest_setup, ListTest_teardown);

  tcase_add_test( tcase, test_List_create     );
  tcase_add_test( tcase, test_List_free_NULL  );
  tcase_add_test( tcase, test_ListNode_create );
  tcase_add_test( tcase, test_List_add_1      );
  tcase_add_test( tcase, test_List_add_2      );
  tcase_add_test( tcase, test_List_get        );
  tcase_add_test( tcase, test_List_countIf    );
  tcase_add_test( tcase, test_List_findIf     );
  tcase_add_test( tcase, test_List_find       );
  tcase_add_test( tcase, test_List_prepend_1  );
  tcase_add_test( tcase, test_List_prepend_2  );
  tcase_add_test( tcase, test_List_remove_1   );
  tcase_add_test( tcase, test_List_remove_2   );
  tcase_add_test( tcase, test_List_remove_3   );
  tcase_add_test( tcase, test_List_remove_4   );
  tcase_add_test( tcase, test_List_freeItems  );
  tcase_add_test( tcase, test_List_accessWithNULL );

  suite_add_tcase(suite, tcase);

  return suite;
}
