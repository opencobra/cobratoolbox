/**
 * \file    TestUnit.c
 * \brief   Unit unit tests
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
UnitTest_setup (void)
{
  U = Unit_create(2, 4);

  if (U == NULL)
  {
    fail("Unit_create() returned a NULL pointer.");
  }
}


void
UnitTest_teardown (void)
{
  Unit_free(U);
}


START_TEST (test_Unit_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) U) == SBML_UNIT );
  fail_unless( SBase_getMetaId    ((SBase_t *) U) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) U) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) U) == NULL );

  fail_unless( Unit_getKind      (U) == UNIT_KIND_INVALID );
  fail_unless( Unit_getExponent  (U) == 1   );
  fail_unless( Unit_getScale     (U) == 0   );
  fail_unless( Unit_getMultiplier(U) == 1.0 );

  fail_unless( !Unit_isSetKind(U) );
  fail_unless( Unit_isSetExponent  (U)   );
  fail_unless( Unit_isSetScale     (U)  );
  fail_unless( Unit_isSetMultiplier(U) );
}
END_TEST


//START_TEST (test_Unit_createWith)
//{
//  Unit_t *u = Unit_createWithKindExponentScale(UNIT_KIND_SECOND, -2, 1);
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) u) == SBML_UNIT );
//  fail_unless( SBase_getMetaId    ((SBase_t *) u) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) u) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) u) == NULL );
//
//  fail_unless( Unit_getKind      (u) == UNIT_KIND_SECOND );
//  fail_unless( Unit_getExponent  (u) == -2   );
//  fail_unless( Unit_getScale     (u) ==  1   );
//  fail_unless( Unit_getMultiplier(u) ==  1.0 );
//  fail_unless( Unit_getOffset    (u) ==  0.0 );
//
//  fail_unless( Unit_isSetKind(u) );
//
//  Unit_free(u);
//}
//END_TEST


START_TEST (test_Unit_free_NULL)
{
  Unit_free(NULL);
}
END_TEST


START_TEST (test_Unit_isXXX)
{
  fail_unless( !Unit_isSetKind(U) );

  Unit_setKind(U, UNIT_KIND_AMPERE);
  fail_unless( Unit_isAmpere(U) );

  Unit_setKind(U, UNIT_KIND_BECQUEREL);
  fail_unless( Unit_isBecquerel(U) );

  Unit_setKind(U, UNIT_KIND_CANDELA);
  fail_unless( Unit_isCandela(U) );

  /* since the Unit is the default level and version
   * celsius is no longer a valid unit
   * and setKind will fail
   */
/*  Unit_setKind(U, UNIT_KIND_CELSIUS);
  fail_unless( Unit_isCelsius(U) );
*/
  Unit_setKind(U, UNIT_KIND_COULOMB);
  fail_unless( Unit_isCoulomb(U) );

  Unit_setKind(U, UNIT_KIND_DIMENSIONLESS);
  fail_unless( Unit_isDimensionless(U) );

  Unit_setKind(U, UNIT_KIND_FARAD);
  fail_unless( Unit_isFarad(U) );

  Unit_setKind(U, UNIT_KIND_GRAM);
  fail_unless( Unit_isGram(U) );

  Unit_setKind(U, UNIT_KIND_GRAY);
  fail_unless( Unit_isGray(U) );

  Unit_setKind(U, UNIT_KIND_HENRY);
  fail_unless( Unit_isHenry(U) );

  Unit_setKind(U, UNIT_KIND_HERTZ);
  fail_unless( Unit_isHertz(U) );

  Unit_setKind(U, UNIT_KIND_ITEM);
  fail_unless( Unit_isItem(U) );

  Unit_setKind(U, UNIT_KIND_JOULE);
  fail_unless( Unit_isJoule(U) );

  Unit_setKind(U, UNIT_KIND_KATAL);
  fail_unless( Unit_isKatal(U) );

  Unit_setKind(U, UNIT_KIND_KELVIN);
  fail_unless( Unit_isKelvin(U) );

  Unit_setKind(U, UNIT_KIND_KILOGRAM);
  fail_unless( Unit_isKilogram(U) );

  Unit_setKind(U, UNIT_KIND_LITRE);
  fail_unless( Unit_isLitre(U) );

  Unit_setKind(U, UNIT_KIND_LUMEN);
  fail_unless( Unit_isLumen(U) );

  Unit_setKind(U, UNIT_KIND_LUX);
  fail_unless( Unit_isLux(U) );

  Unit_setKind(U, UNIT_KIND_METRE);
  fail_unless( Unit_isMetre(U) );

  Unit_setKind(U, UNIT_KIND_MOLE);
  fail_unless( Unit_isMole(U) );

  Unit_setKind(U, UNIT_KIND_NEWTON);
  fail_unless( Unit_isNewton(U) );

  Unit_setKind(U, UNIT_KIND_OHM);
  fail_unless( Unit_isOhm(U) );

  Unit_setKind(U, UNIT_KIND_PASCAL);
  fail_unless( Unit_isPascal(U) );

  Unit_setKind(U, UNIT_KIND_RADIAN);
  fail_unless( Unit_isRadian(U) );

  Unit_setKind(U, UNIT_KIND_SECOND);
  fail_unless( Unit_isSecond(U) );

  Unit_setKind(U, UNIT_KIND_SIEMENS);
  fail_unless( Unit_isSiemens(U) );

  Unit_setKind(U, UNIT_KIND_SIEVERT);
  fail_unless( Unit_isSievert(U) );

  Unit_setKind(U, UNIT_KIND_STERADIAN);
  fail_unless( Unit_isSteradian(U) );

  Unit_setKind(U, UNIT_KIND_TESLA);
  fail_unless( Unit_isTesla(U) );

  Unit_setKind(U, UNIT_KIND_VOLT);
  fail_unless( Unit_isVolt(U) );

  Unit_setKind(U, UNIT_KIND_WATT);
  fail_unless( Unit_isWatt(U) );

  Unit_setKind(U, UNIT_KIND_WEBER);
  fail_unless( Unit_isWeber(U) );
}
END_TEST


START_TEST (test_Unit_isBuiltIn)
{
  fail_unless( Unit_isBuiltIn( "substance", 1) );
  fail_unless( Unit_isBuiltIn( "volume"   , 1) );
  fail_unless( !Unit_isBuiltIn( "area"     , 1) );
  fail_unless( !Unit_isBuiltIn( "length"   , 1) );
  fail_unless( Unit_isBuiltIn( "time"     , 1) );

  fail_unless( Unit_isBuiltIn( "substance", 2) );
  fail_unless( Unit_isBuiltIn( "volume"   , 2) );
  fail_unless( Unit_isBuiltIn( "area"     , 2) );
  fail_unless( Unit_isBuiltIn( "length"   , 2) );
  fail_unless( Unit_isBuiltIn( "time"     , 2) );

  fail_unless( !Unit_isBuiltIn( NULL     , 1) );
  fail_unless( !Unit_isBuiltIn( ""       , 1) );
  fail_unless( !Unit_isBuiltIn( "volt"   , 1) );
  fail_unless( !Unit_isBuiltIn( "foobar" , 1) );
  fail_unless( !Unit_isBuiltIn( NULL     , 2) );
  fail_unless( !Unit_isBuiltIn( ""       , 2) );
  fail_unless( !Unit_isBuiltIn( "volt"   , 2) );
  fail_unless( !Unit_isBuiltIn( "foobar" , 2) );
}
END_TEST


START_TEST (test_Unit_set_get)
{
  Unit_t *u = Unit_create(2, 4);


  fail_unless( Unit_getKind      (u) == UNIT_KIND_INVALID );
  fail_unless( Unit_getExponent  (u) == 1   );
  fail_unless( Unit_getScale     (u) == 0   );
  fail_unless( Unit_getMultiplier(u) == 1.0 );
  fail_unless( !Unit_isSetKind(u) );

  Unit_setKind(u, UNIT_KIND_WATT);
  fail_unless( Unit_getKind      (u) == UNIT_KIND_WATT );

  Unit_setExponent(u, 3);
  fail_unless( Unit_getExponent  (u) == 3   );

  Unit_setScale(u, 4);
  fail_unless( Unit_getScale     (u) == 4  );

  Unit_setMultiplier(u, 3.2);
  fail_unless( Unit_getMultiplier(u) == 3.2 );

  Unit_free(u);
}
END_TEST


START_TEST (test_Unit_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Unit_t *object = 
    Unit_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_UNIT );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Unit_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Unit_getNamespaces(object)) == 2 );

  Unit_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_Unit (void)
{
  Suite *suite = suite_create("Unit");
  TCase *tcase = tcase_create("Unit");


  tcase_add_checked_fixture( tcase, UnitTest_setup, UnitTest_teardown );

  tcase_add_test( tcase, test_Unit_create     );
  //tcase_add_test( tcase, test_Unit_createWith );
  tcase_add_test( tcase, test_Unit_free_NULL  );
  tcase_add_test( tcase, test_Unit_isXXX      );
  tcase_add_test( tcase, test_Unit_isBuiltIn  );
  tcase_add_test( tcase, test_Unit_set_get    );
  tcase_add_test( tcase, test_Unit_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


