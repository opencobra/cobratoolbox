/**
 * \file    TestMemory.h
 * \brief   memory functions unit tests
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


/**
 * Tests in this suite are somewhat verbose.  Since most of the tests are
 * of memory tracing facilities, each piece of memory needs to be
 * allocated, tracked and freed for each test.
 */


/**
 * This is really a dummy test, without it, if TRACE_MEMORY was not defined,
 * the test suite would be empty.
 */
START_TEST (test_memory_safe_malloc)
{
  void *p = safe_malloc(1024);


  if (p == NULL)
  {
    fail("safe_malloc() should not return NULL");
  }

  safe_free(p);
}
END_TEST


#ifdef TRACE_MEMORY


START_TEST (test_memory_MemTrace_MemInfoList_create)
{
  MemInfoList_t *list = MemTrace_MemInfoList_create();


  fail_unless( list->head == NULL );
  fail_unless( list->tail == NULL );
  fail_unless( list->size ==    0 );

  MemTrace_MemInfoList_free(list);
}
END_TEST


START_TEST (test_memory_MemTrace_MemInfoNode_create)
{
  MemInfoNode_t *node;
  int           line;


  node = MemTrace_MemInfoNode_create((int *) 42, 4, "Foo.c", line = __LINE__);

  fail_unless( node->address == (int *) 42 );
  fail_unless( node->size    ==          4 );
  fail_unless( node->line    == line );
  fail_unless( node->next    == NULL );

  fail_unless( !strcmp(node->filename, "Foo.c") );

  free(node);
}
END_TEST


START_TEST (test_memory_MemTrace_MemInfoList_append_1)
{
  MemInfoList_t *list = MemTrace_MemInfoList_create();
  MemInfoNode_t *node = NULL;
  int           size  = sizeof(MemInfoList_t); 


  node = MemTrace_MemInfoNode_create(&list, size, __FILE__, __LINE__);
  MemTrace_MemInfoList_append(list, node);

  fail_unless( list->head       == node );
  fail_unless( list->tail       == node );
  fail_unless( list->head->next == NULL );
  fail_unless( list->tail->next == NULL ); 
  fail_unless( list->size       ==    1 );

  MemTrace_MemInfoList_free(list);
}
END_TEST


START_TEST (test_memory_MemTrace_MemInfoList_append_2)
{
  MemInfoList_t *list  = MemTrace_MemInfoList_create();
  MemInfoNode_t *node1 = NULL;
  MemInfoNode_t *node2 = NULL;
  int           size   = sizeof(MemInfoList_t); 


  node1 = MemTrace_MemInfoNode_create(&list, size, __FILE__, __LINE__);
  node2 = MemTrace_MemInfoNode_create(&list, size, __FILE__, __LINE__);

  MemTrace_MemInfoList_append(list, node1);
  MemTrace_MemInfoList_append(list, node2);

  fail_unless( list->head       == node1 );
  fail_unless( list->tail       == node2 );
  fail_unless( list->head->next == node2 );
  fail_unless( list->tail->next ==  NULL ); 
  fail_unless( list->size       ==     2 );

  MemTrace_MemInfoList_free(list);
}
END_TEST


START_TEST (test_memory_MemTrace_MemInfoList_get)
{
  MemInfoList_t *list  = MemTrace_MemInfoList_create();
  MemInfoNode_t *node1 = NULL;
  MemInfoNode_t *node2 = NULL;
  MemInfoNode_t *node3 = NULL;
  MemInfoNode_t *node4 = NULL;


  node1 = MemTrace_MemInfoNode_create( (int *) 41, 4, __FILE__, __LINE__);
  node2 = MemTrace_MemInfoNode_create( (int *) 42, 4, __FILE__, __LINE__);
  node3 = MemTrace_MemInfoNode_create( (int *) 43, 4, __FILE__, __LINE__);
  node4 = MemTrace_MemInfoNode_create( (int *) 44, 4, __FILE__, __LINE__);

  MemTrace_MemInfoList_append(list, node1);
  MemTrace_MemInfoList_append(list, node2);
  MemTrace_MemInfoList_append(list, node3);
  MemTrace_MemInfoList_append(list, node4);

  fail_unless( MemTrace_MemInfoList_get(list, (int *) 40) ==  NULL );
  fail_unless( MemTrace_MemInfoList_get(list, (int *) 41) == node1 );
  fail_unless( MemTrace_MemInfoList_get(list, (int *) 42) == node2 );
  fail_unless( MemTrace_MemInfoList_get(list, (int *) 43) == node3 );
  fail_unless( MemTrace_MemInfoList_get(list, (int *) 44) == node4 );

  MemTrace_MemInfoList_free(list);
}
END_TEST


START_TEST (test_memory_MemTrace_MemInfoList_remove)
{
  MemInfoList_t *list    = MemTrace_MemInfoList_create();
  MemInfoNode_t *node1   = NULL;
  MemInfoNode_t *node2   = NULL;
  MemInfoNode_t *node3   = NULL;
  MemInfoNode_t *node4   = NULL;
  MemInfoNode_t *removed = NULL;


  node1 = MemTrace_MemInfoNode_create( (int *) 41, 4, __FILE__, __LINE__);
  node2 = MemTrace_MemInfoNode_create( (int *) 42, 4, __FILE__, __LINE__);
  node3 = MemTrace_MemInfoNode_create( (int *) 43, 4, __FILE__, __LINE__);
  node4 = MemTrace_MemInfoNode_create( (int *) 44, 4, __FILE__, __LINE__);

  MemTrace_MemInfoList_append(list, node1);
  MemTrace_MemInfoList_append(list, node2);
  MemTrace_MemInfoList_append(list, node3);
  MemTrace_MemInfoList_append(list, node4);
  fail_unless( list->size == 4 );

  /* Not Found */
  fail_unless( MemTrace_MemInfoList_remove(list, (int *) 40) == NULL );
  fail_unless( list->size == 4 );

  /* Remove middle */
  removed = MemTrace_MemInfoList_remove(list, (int *) 43);
  fail_unless( removed    == node3 );
  fail_unless( list->head == node1 );
  fail_unless( list->tail == node4 );
  fail_unless( list->size ==     3 );

  /* Remove first */
  removed = MemTrace_MemInfoList_remove(list, (int *) 41);
  fail_unless( removed    == node1 );
  fail_unless( list->head == node2 );
  fail_unless( list->tail == node4 );
  fail_unless( list->size ==     2 );

  /* Remove last */
  removed = MemTrace_MemInfoList_remove(list, (int *) 44);
  fail_unless( removed    == node4 );
  fail_unless( list->head == node2 );
  fail_unless( list->tail == node2 );
  fail_unless( list->size ==     1 );

  MemTrace_MemInfoList_free(list);
}
END_TEST


START_TEST (test_memory_MemTrace_init)
{
  MemTrace_init();

  fail_unless( MemTrace_getNumAllocs()         == 0 );
  fail_unless( MemTrace_getNumLeaks()          == 0 );
  fail_unless( MemTrace_getNumFrees()          == 0 );
  fail_unless( MemTrace_getNumUnmatchedFrees() == 0 );
}
END_TEST


START_TEST (test_memory_MemTrace_getAllocs)
{
  void *p = safe_malloc(1024);
  void *q = safe_malloc(1024);


  fail_unless( MemTrace_getNumAllocs() == 2 );
  fail_unless( MemTrace_getNumLeaks()  == 2 );
  fail_unless( MemTrace_getNumFrees()  == 0 );

  safe_free(p);

  fail_unless( MemTrace_getNumAllocs() == 2 );
  fail_unless( MemTrace_getNumLeaks()  == 1 );
  fail_unless( MemTrace_getNumFrees()  == 1 );

  safe_free(q);

  fail_unless( MemTrace_getNumAllocs() == 2 );
  fail_unless( MemTrace_getNumLeaks()  == 0 );
  fail_unless( MemTrace_getNumFrees()  == 2 );
}
END_TEST


START_TEST (test_memory_MemTrace_getNumUnmatchedFrees)
{
  void *p = malloc(1024);
  void *q = malloc(1024);


  fail_unless( MemTrace_getNumFrees()          == 2 );
  fail_unless( MemTrace_getNumUnmatchedFrees() == 0 );

  safe_free(p);

  fail_unless( MemTrace_getNumFrees()          == 3 );
  fail_unless( MemTrace_getNumUnmatchedFrees() == 1 );

  safe_free(q);

  fail_unless( MemTrace_getNumFrees()          == 4 );
  fail_unless( MemTrace_getNumUnmatchedFrees() == 2 );
}
END_TEST


START_TEST (test_memory_MemTrace_reset)
{
  MemTrace_reset();

  fail_unless( MemTrace_getNumAllocs()         == 0 );
  fail_unless( MemTrace_getNumLeaks()          == 0 );
  fail_unless( MemTrace_getNumFrees()          == 0 );
  fail_unless( MemTrace_getNumUnmatchedFrees() == 0 );
}
END_TEST


#endif  /** TRACE_MEMORY **/


Suite *
create_suite_memory (void) 
{ 
  Suite *suite = suite_create("memory");
  TCase *tcase = tcase_create("memory");


  tcase_add_test( tcase, test_memory_safe_malloc );

#ifdef TRACE_MEMORY

  tcase_add_test( tcase, test_memory_MemTrace_MemInfoList_create   );
  tcase_add_test( tcase, test_memory_MemTrace_MemInfoNode_create   );
  tcase_add_test( tcase, test_memory_MemTrace_MemInfoList_append_1 );
  tcase_add_test( tcase, test_memory_MemTrace_MemInfoList_append_2 );
  tcase_add_test( tcase, test_memory_MemTrace_MemInfoList_get      );
  tcase_add_test( tcase, test_memory_MemTrace_MemInfoList_remove   );
  tcase_add_test( tcase, test_memory_MemTrace_init                 );
  tcase_add_test( tcase, test_memory_MemTrace_getAllocs            );
  tcase_add_test( tcase, test_memory_MemTrace_getNumUnmatchedFrees );
  tcase_add_test( tcase, test_memory_MemTrace_reset                );

#endif

  suite_add_tcase(suite, tcase);

  return suite;
}
