/**
 * \file    TestL3Unit.c
 * \brief   L3 Unit unit tests
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
L3UnitTest_setup (void)
{
  U = Unit_create(3, 1);

  if (U == NULL)
  {
    fail("Unit_create(3, 1) returned a NULL pointer.");
  }
}


void
L3UnitTest_teardown (void)
{
  Unit_free(U);
}


START_TEST (test_L3_Unit_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) U) == SBML_UNIT );
  fail_unless( SBase_getMetaId    ((SBase_t *) U) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) U) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) U) == NULL );

  fail_unless( Unit_getKind     (U) == UNIT_KIND_INVALID );
  fail_unless( util_isNaN(Unit_getExponentAsDouble (U)) );
  fail_unless( util_isNaN(Unit_getMultiplier (U)) );
  fail_unless( Unit_getScale (U) == SBML_INT_MAX );

  fail_unless( !Unit_isSetKind     (U) );
  fail_unless( !Unit_isSetExponent (U) );
  fail_unless( !Unit_isSetMultiplier (U) );
  fail_unless( !Unit_isSetScale (U) );
}
END_TEST


START_TEST (test_L3_Unit_free_NULL)
{
  Unit_free(NULL);
}
END_TEST


START_TEST (test_L3_Unit_kind)
{
  const char *kind = "mole";


  fail_unless( !Unit_isSetKind(U) );
  
  Unit_setKind(U, UnitKind_forName(kind));

  fail_unless( Unit_getKind(U) == UNIT_KIND_MOLE );
  fail_unless( Unit_isSetKind(U) );
}
END_TEST


START_TEST (test_L3_Unit_exponent)
{
  double exponent = 0.2;

  fail_unless( !Unit_isSetExponent(U));
  fail_unless( util_isNaN(Unit_getExponentAsDouble(U)));
  
  Unit_setExponentAsDouble(U, exponent);

  fail_unless( Unit_getExponentAsDouble(U) == exponent );
  fail_unless( Unit_isSetExponent(U) );
}
END_TEST


START_TEST (test_L3_Unit_multiplier)
{
  double multiplier = 0.2;

  fail_unless( !Unit_isSetMultiplier(U));
  fail_unless( util_isNaN(Unit_getMultiplier(U)));
  
  Unit_setMultiplier(U, multiplier);

  fail_unless( Unit_getMultiplier(U) == multiplier );
  fail_unless( Unit_isSetMultiplier(U) );
}
END_TEST


START_TEST (test_L3_Unit_scale)
{
  int scale = 2;

  fail_unless( !Unit_isSetScale(U));
  fail_unless( Unit_getScale (U) == SBML_INT_MAX );
  
  Unit_setScale(U, scale);

  fail_unless( Unit_getScale(U) == scale );
  fail_unless( Unit_isSetScale(U) );
}
END_TEST


START_TEST (test_L3_Unit_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Unit_t *u = 
    Unit_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) u) == SBML_UNIT );
  fail_unless( SBase_getMetaId    ((SBase_t *) u) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) u) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) u) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) u) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) u) == 1 );

  fail_unless( Unit_getNamespaces     (u) != NULL );
  fail_unless( XMLNamespaces_getLength(Unit_getNamespaces(u)) == 2 );


  fail_unless( Unit_getKind     (u) == UNIT_KIND_INVALID );
  fail_unless( util_isNaN(Unit_getExponentAsDouble (u)) );
  fail_unless( util_isNaN(Unit_getMultiplier (u)) );
//  fail_unless( util_isNaN((double)(Unit_getScale (u))) );

  fail_unless( !Unit_isSetKind     (u) );
  fail_unless( !Unit_isSetExponent (u) );
  fail_unless( !Unit_isSetMultiplier (u) );
  fail_unless( !Unit_isSetScale (u) );

  Unit_free(u);
}
END_TEST


START_TEST (test_L3_Unit_hasRequiredAttributes )
{
  Unit_t *u = Unit_create (3, 1);

  fail_unless ( !Unit_hasRequiredAttributes(u));

  Unit_setKind(u, UNIT_KIND_MOLE);

  fail_unless ( !Unit_hasRequiredAttributes(u));

  Unit_setExponentAsDouble(u, 0);

  fail_unless ( !Unit_hasRequiredAttributes(u));

  Unit_setMultiplier(u, 0.45);

  fail_unless ( !Unit_hasRequiredAttributes(u));

  Unit_setScale(u, 2);
  fail_unless ( Unit_hasRequiredAttributes(u));

  Unit_free(u);
}
END_TEST


START_TEST (test_L3_Unit_NS)
{
  fail_unless( Unit_getNamespaces     (U) != NULL );
  fail_unless( XMLNamespaces_getLength(Unit_getNamespaces(U)) == 1 );
  fail_unless( !strcmp( XMLNamespaces_getURI(Unit_getNamespaces(U), 0),
    "http://www.sbml.org/sbml/level3/version1/core"));
}
END_TEST


Suite *
create_suite_L3_Unit (void)
{
  Suite *suite = suite_create("L3_Unit");
  TCase *tcase = tcase_create("L3_Unit");


  tcase_add_checked_fixture( tcase,
                             L3UnitTest_setup,
                             L3UnitTest_teardown );

  tcase_add_test( tcase, test_L3_Unit_create              );
  tcase_add_test( tcase, test_L3_Unit_free_NULL           );
  tcase_add_test( tcase, test_L3_Unit_kind               );
  tcase_add_test( tcase, test_L3_Unit_exponent      );
  tcase_add_test( tcase, test_L3_Unit_multiplier);
  tcase_add_test( tcase, test_L3_Unit_scale);
  tcase_add_test( tcase, test_L3_Unit_createWithNS         );
  tcase_add_test( tcase, test_L3_Unit_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_Unit_NS              );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

