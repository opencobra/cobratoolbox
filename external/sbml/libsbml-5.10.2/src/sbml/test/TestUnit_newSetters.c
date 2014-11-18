/**
 * \file    TestUnit_newSetters.c
 * \brief   Unit unit tests for new set function API
 * \author  Sarah Keating
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

#include <sbml/SBase.h>
#include <sbml/Unit.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Unit_t *U;


void
UnitTest1_setup (void)
{
  U = Unit_create(1, 2);

  if (U == NULL)
  {
    fail("Unit_create() returned a NULL pointer.");
  }
}


void
UnitTest1_teardown (void)
{
  Unit_free(U);
}


START_TEST (test_Unit_setKind1)
{
  int i = Unit_setKind(U, UnitKind_forName("cell"));

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Unit_isSetKind(U) );
}
END_TEST


START_TEST (test_Unit_setKind2)
{
  int i = Unit_setKind(U, UnitKind_forName("litre"));

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_isSetKind(U) );
}
END_TEST


START_TEST (test_Unit_setMultiplier1)
{
  int i = Unit_setMultiplier(U, 2);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Unit_getMultiplier(U) == 2 );
}
END_TEST


START_TEST (test_Unit_setMultiplier2)
{
  Unit_t *c = 
    Unit_create(2, 2);

  int i = Unit_setMultiplier(c, 4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getMultiplier(c) == 4 );

  Unit_free(c);
}
END_TEST


START_TEST (test_Unit_setExponent1)
{
  int i = Unit_setExponent(U, 2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getExponent(U) == 2 );
}
END_TEST


START_TEST (test_Unit_setExponent2)
{
  int i = Unit_setExponentAsDouble(U, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getExponent(U) == 2 );
}
END_TEST


START_TEST (test_Unit_setExponent3)
{
  int i = Unit_setExponentAsDouble(U, 2.2);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Unit_getExponent(U) == 1 );
}
END_TEST


START_TEST (test_Unit_setScale1)
{
  int i = Unit_setScale(U, 2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getScale(U) == 2 );
}
END_TEST


START_TEST (test_Unit_setOffset1)
{
  int i = Unit_setOffset(U, 2.0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Unit_getOffset(U) == 0 );
}
END_TEST


START_TEST (test_Unit_setOffset2)
{
  Unit_t *U1 = 
    Unit_create(2, 1);
  int i = Unit_setOffset(U1, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getOffset(U1) == 2 );
}
END_TEST


START_TEST (test_Unit_removeScale)
{
  int i = Unit_setScale(U, 2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getScale(U) == 2 );

  i = Unit_removeScale(U);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Unit_getScale(U) == 0 );
  fail_unless( Unit_getMultiplier(U) == 100);
}
END_TEST


Suite *
create_suite_Unit_newSetters (void)
{
  Suite *suite = suite_create("Unit_newSetters");
  TCase *tcase = tcase_create("Unit_newSetters");


  tcase_add_checked_fixture( tcase,
                             UnitTest1_setup,
                             UnitTest1_teardown );

  tcase_add_test( tcase, test_Unit_setKind1       );
  tcase_add_test( tcase, test_Unit_setKind2       );
  tcase_add_test( tcase, test_Unit_setMultiplier1       );
  tcase_add_test( tcase, test_Unit_setMultiplier2       );
  tcase_add_test( tcase, test_Unit_setExponent1       );
  tcase_add_test( tcase, test_Unit_setExponent2       );
  tcase_add_test( tcase, test_Unit_setExponent3       );
  tcase_add_test( tcase, test_Unit_setScale1       );
  tcase_add_test( tcase, test_Unit_setOffset1       );
  tcase_add_test( tcase, test_Unit_setOffset2       );
  tcase_add_test( tcase, test_Unit_removeScale       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

