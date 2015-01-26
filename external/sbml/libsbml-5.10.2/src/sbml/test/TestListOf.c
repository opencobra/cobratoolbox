/**
 * \file    TestListOf.c
 * \brief   ListOf unit tests
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

#include <sbml/ListOf.h>
#include <sbml/SBase.h>
#include <sbml/Species.h>
#include <sbml/Compartment.h>
#include <sbml/Model.h>

#include <check.h>




#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

START_TEST (test_ListOf_create)
{
  ListOf_t *lo = (ListOf_t*) ListOf_create(2,4);


  fail_unless( SBase_getTypeCode  ((SBase_t *) lo) == SBML_LIST_OF );
  fail_unless( SBase_getNotes     ((SBase_t *) lo) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) lo) == NULL );
  fail_unless( SBase_getMetaId    ((SBase_t *) lo) == NULL );

  fail_unless( ListOf_size(lo) == 0 );

  ListOf_free(lo);
}
END_TEST


START_TEST (test_ListOf_free_NULL)
{
  ListOf_free(NULL);
}
END_TEST


START_TEST (test_ListOf_remove)
{
  ListOf_t *lo = (ListOf_t*) ListOf_create(2,4);

  SBase_t *sp = (SBase_t*)Species_create(2, 4);

  fail_unless( ListOf_size(lo) == 0 );

  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);

  fail_unless( ListOf_size(lo) == 5 );

  SBase_t *elem;
  elem = ListOf_remove(lo, 0);
  Species_free((Species_t*) elem);
  elem = ListOf_remove(lo, 0);
  Species_free((Species_t*) elem);
  elem = ListOf_remove(lo, 0);
  Species_free((Species_t*) elem);
  elem = ListOf_remove(lo, 0);
  Species_free((Species_t*) elem);
  elem = ListOf_remove(lo, 0);
  Species_free((Species_t*) elem);

  fail_unless( ListOf_size(lo) == 0 );

  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_appendAndOwn(lo, sp);

  fail_unless( ListOf_size(lo) == 5 );

  ListOf_free(lo);
}
END_TEST


START_TEST (test_ListOf_clear)
{
  ListOf_t *lo = (ListOf_t*) ListOf_create(2,4);

  SBase_t *sp = (SBase_t*)Species_create(2, 4); 

  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);

  fail_unless( ListOf_size(lo) == 5 );

  /* clear and delete */

  ListOf_clear(lo, 1);

  fail_unless( ListOf_size(lo) == 0 );

  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_append(lo, sp);
  ListOf_appendAndOwn(lo, sp);

  fail_unless( ListOf_size(lo) == 5 );

  /* delete each item */

  SBase_t *elem;
  elem = ListOf_get(lo, 0);
  Species_free((Species_t*) elem);
  elem = ListOf_get(lo, 1);
  Species_free((Species_t*) elem);
  elem = ListOf_get(lo, 2);
  Species_free((Species_t*) elem);
  elem = ListOf_get(lo, 3);
  Species_free((Species_t*) elem);
  elem = ListOf_get(lo, 4);
  Species_free((Species_t*) elem);

  /* clear only */

  ListOf_clear(lo, 0);

  fail_unless( ListOf_size(lo) == 0 );

  ListOf_free(lo);
  
}
END_TEST


START_TEST (test_ListOf_append)
{
  Model_t *m = Model_create(2, 4);
  Model_createCompartment(m);

  ListOf_t *loc = Model_getListOfCompartments(m);

  fail_unless(ListOf_size(loc) == 1);

  SBase_t *c = (SBase_t*)Compartment_create(2, 4);
  int i = ListOf_append(loc, c);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ListOf_size(loc) == 2);

  SBase_t *sp = (SBase_t*)Species_create(2, 4);
  i = ListOf_append(loc, sp);

  fail_unless(i == LIBSBML_INVALID_OBJECT);
  fail_unless(ListOf_size(loc) == 2);

  Model_t* m2 = Model_clone(m);
  ListOf_t* loc2 = Model_getListOfCompartments(m2);
  fail_unless(ListOf_size(loc2) == 2);
  i = ListOf_appendFrom(loc, loc2);
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(ListOf_size(loc) == 4);

  ListOf_t* los = Model_getListOfSpecies(m);
  i = ListOf_appendFrom(loc, los);
  fail_unless(i == LIBSBML_INVALID_OBJECT);


  Model_free(m);
  Model_free(m2);
  Species_free((Species_t*)sp);
}
END_TEST

Suite *
create_suite_ListOf (void) 
{ 
  Suite *suite = suite_create("ListOf");
  TCase *tcase = tcase_create("ListOf");
 

  tcase_add_test(tcase, test_ListOf_create    );
  tcase_add_test(tcase, test_ListOf_free_NULL );
  tcase_add_test(tcase, test_ListOf_remove    );
  tcase_add_test(tcase, test_ListOf_clear     );
  tcase_add_test(tcase, test_ListOf_append    );
 
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

