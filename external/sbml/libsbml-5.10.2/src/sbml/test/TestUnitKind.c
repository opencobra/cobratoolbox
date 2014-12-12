/**
 * \file    TestUnitKind.h
 * \brief   UnitKind enumeration unit tests
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
#include <sbml/UnitKind.h>

#include <check.h>


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

START_TEST (test_UnitKind_equals)
{
  fail_unless( UnitKind_equals( UNIT_KIND_AMPERE , UNIT_KIND_AMPERE  ), NULL );
  fail_unless( UnitKind_equals( UNIT_KIND_INVALID, UNIT_KIND_INVALID ), NULL );
  fail_unless( UnitKind_equals( UNIT_KIND_LITER  , UNIT_KIND_LITER   ), NULL );
  fail_unless( UnitKind_equals( UNIT_KIND_LITRE  , UNIT_KIND_LITRE   ), NULL );
  fail_unless( UnitKind_equals( UNIT_KIND_METER  , UNIT_KIND_METER   ), NULL );
  fail_unless( UnitKind_equals( UNIT_KIND_METRE  , UNIT_KIND_METRE   ), NULL );

  fail_unless( UnitKind_equals(UNIT_KIND_LITER, UNIT_KIND_LITRE), NULL );
  fail_unless( UnitKind_equals(UNIT_KIND_LITRE, UNIT_KIND_LITER), NULL );

  fail_unless( UnitKind_equals(UNIT_KIND_METER, UNIT_KIND_METRE), NULL );
  fail_unless( UnitKind_equals(UNIT_KIND_METRE, UNIT_KIND_METER), NULL );

  fail_unless( !UnitKind_equals(UNIT_KIND_AMPERE, UNIT_KIND_WEBER), NULL );
}
END_TEST


START_TEST (test_UnitKind_forName)
{
  fail_unless( UnitKind_forName("ampere")    == UNIT_KIND_AMPERE   , NULL );
  fail_unless( UnitKind_forName("becquerel") == UNIT_KIND_BECQUEREL, NULL );
  fail_unless( UnitKind_forName("candela")   == UNIT_KIND_CANDELA  , NULL );
  fail_unless( UnitKind_forName("Celsius")   == UNIT_KIND_CELSIUS  , NULL );
  fail_unless( UnitKind_forName("coulomb")   == UNIT_KIND_COULOMB  , NULL );

  fail_unless( UnitKind_forName("dimensionless") == UNIT_KIND_DIMENSIONLESS,
               NULL);

  fail_unless( UnitKind_forName("farad")     == UNIT_KIND_FARAD    , NULL );
  fail_unless( UnitKind_forName("gram")      == UNIT_KIND_GRAM     , NULL );
  fail_unless( UnitKind_forName("gray")      == UNIT_KIND_GRAY     , NULL );
  fail_unless( UnitKind_forName("henry")     == UNIT_KIND_HENRY    , NULL );
  fail_unless( UnitKind_forName("hertz")     == UNIT_KIND_HERTZ    , NULL );
  fail_unless( UnitKind_forName("item")      == UNIT_KIND_ITEM     , NULL );
  fail_unless( UnitKind_forName("joule")     == UNIT_KIND_JOULE    , NULL );
  fail_unless( UnitKind_forName("katal")     == UNIT_KIND_KATAL    , NULL );
  fail_unless( UnitKind_forName("kelvin")    == UNIT_KIND_KELVIN   , NULL );
  fail_unless( UnitKind_forName("kilogram")  == UNIT_KIND_KILOGRAM , NULL );
  fail_unless( UnitKind_forName("liter")     == UNIT_KIND_LITER    , NULL );
  fail_unless( UnitKind_forName("litre")     == UNIT_KIND_LITRE    , NULL );
  fail_unless( UnitKind_forName("lumen")     == UNIT_KIND_LUMEN    , NULL );
  fail_unless( UnitKind_forName("lux")       == UNIT_KIND_LUX      , NULL );
  fail_unless( UnitKind_forName("meter")     == UNIT_KIND_METER    , NULL );
  fail_unless( UnitKind_forName("metre")     == UNIT_KIND_METRE    , NULL );
  fail_unless( UnitKind_forName("mole")      == UNIT_KIND_MOLE     , NULL );
  fail_unless( UnitKind_forName("newton")    == UNIT_KIND_NEWTON   , NULL );
  fail_unless( UnitKind_forName("ohm")       == UNIT_KIND_OHM      , NULL );
  fail_unless( UnitKind_forName("pascal")    == UNIT_KIND_PASCAL   , NULL );
  fail_unless( UnitKind_forName("radian")    == UNIT_KIND_RADIAN   , NULL );
  fail_unless( UnitKind_forName("second")    == UNIT_KIND_SECOND   , NULL );
  fail_unless( UnitKind_forName("siemens")   == UNIT_KIND_SIEMENS  , NULL );
  fail_unless( UnitKind_forName("sievert")   == UNIT_KIND_SIEVERT  , NULL );
  fail_unless( UnitKind_forName("steradian") == UNIT_KIND_STERADIAN, NULL );
  fail_unless( UnitKind_forName("tesla")     == UNIT_KIND_TESLA    , NULL );
  fail_unless( UnitKind_forName("volt")      == UNIT_KIND_VOLT     , NULL );
  fail_unless( UnitKind_forName("watt")      == UNIT_KIND_WATT     , NULL );
  fail_unless( UnitKind_forName("weber")     == UNIT_KIND_WEBER    , NULL );

  fail_unless( UnitKind_forName(NULL)     == UNIT_KIND_INVALID, NULL );
  fail_unless( UnitKind_forName("")       == UNIT_KIND_INVALID, NULL );
  fail_unless( UnitKind_forName("foobar") == UNIT_KIND_INVALID, NULL );
}
END_TEST


START_TEST (test_UnitKind_toString)
{
  const char* s;


  s = UnitKind_toString(UNIT_KIND_AMPERE);
  fail_unless(!strcmp(s, "ampere"), NULL);

  s = UnitKind_toString(UNIT_KIND_BECQUEREL);
  fail_unless(!strcmp(s, "becquerel"), NULL);

  s = UnitKind_toString(UNIT_KIND_CANDELA);
  fail_unless(!strcmp(s, "candela"), NULL);

  s = UnitKind_toString(UNIT_KIND_CELSIUS);
  fail_unless(!strcmp(s, "Celsius"), NULL);

  s = UnitKind_toString(UNIT_KIND_COULOMB);
  fail_unless(!strcmp(s, "coulomb"), NULL);

  s = UnitKind_toString(UNIT_KIND_DIMENSIONLESS);
  fail_unless(!strcmp(s, "dimensionless"), NULL);

  s = UnitKind_toString(UNIT_KIND_FARAD);
  fail_unless(!strcmp(s, "farad"), NULL);

  s = UnitKind_toString(UNIT_KIND_GRAM);
  fail_unless(!strcmp(s, "gram"), NULL);

  s = UnitKind_toString(UNIT_KIND_GRAY);
  fail_unless(!strcmp(s, "gray"), NULL);

  s = UnitKind_toString(UNIT_KIND_HENRY);
  fail_unless(!strcmp(s, "henry"), NULL);

  s = UnitKind_toString(UNIT_KIND_HERTZ);
  fail_unless(!strcmp(s, "hertz"), NULL);

  s = UnitKind_toString(UNIT_KIND_ITEM);
  fail_unless(!strcmp(s, "item"), NULL);

  s = UnitKind_toString(UNIT_KIND_JOULE);
  fail_unless(!strcmp(s, "joule"), NULL);

  s = UnitKind_toString(UNIT_KIND_KATAL);
  fail_unless(!strcmp(s, "katal"), NULL);

  s = UnitKind_toString(UNIT_KIND_KELVIN);
  fail_unless(!strcmp(s, "kelvin"), NULL);

  s = UnitKind_toString(UNIT_KIND_KILOGRAM);
  fail_unless(!strcmp(s, "kilogram"), NULL);

  s = UnitKind_toString(UNIT_KIND_LITER);
  fail_unless(!strcmp(s, "liter"), NULL);

  s = UnitKind_toString(UNIT_KIND_LITRE);
  fail_unless(!strcmp(s, "litre"), NULL);

  s = UnitKind_toString(UNIT_KIND_LUMEN);
  fail_unless(!strcmp(s, "lumen"), NULL);

  s = UnitKind_toString(UNIT_KIND_LUX);
  fail_unless(!strcmp(s, "lux"), NULL);

  s = UnitKind_toString(UNIT_KIND_METER);
  fail_unless(!strcmp(s, "meter"), NULL);

  s = UnitKind_toString(UNIT_KIND_METRE);
  fail_unless(!strcmp(s, "metre"), NULL);

  s = UnitKind_toString(UNIT_KIND_MOLE);
  fail_unless(!strcmp(s, "mole"), NULL);

  s = UnitKind_toString(UNIT_KIND_NEWTON);
  fail_unless(!strcmp(s, "newton"), NULL);

  s = UnitKind_toString(UNIT_KIND_OHM);
  fail_unless(!strcmp(s, "ohm"), NULL);

  s = UnitKind_toString(UNIT_KIND_PASCAL);
  fail_unless(!strcmp(s, "pascal"), NULL);

  s = UnitKind_toString(UNIT_KIND_RADIAN);
  fail_unless(!strcmp(s, "radian"), NULL);

  s = UnitKind_toString(UNIT_KIND_SECOND);
  fail_unless(!strcmp(s, "second"), NULL);

  s = UnitKind_toString(UNIT_KIND_SIEMENS);
  fail_unless(!strcmp(s, "siemens"), NULL);

  s = UnitKind_toString(UNIT_KIND_SIEVERT);
  fail_unless(!strcmp(s, "sievert"), NULL);

  s = UnitKind_toString(UNIT_KIND_STERADIAN);
  fail_unless(!strcmp(s, "steradian"), NULL);

  s = UnitKind_toString(UNIT_KIND_TESLA);
  fail_unless(!strcmp(s, "tesla"), NULL);

  s = UnitKind_toString(UNIT_KIND_VOLT);
  fail_unless(!strcmp(s, "volt"), NULL);

  s = UnitKind_toString(UNIT_KIND_WATT);
  fail_unless(!strcmp(s, "watt"), NULL);

  s = UnitKind_toString(UNIT_KIND_WEBER);
  fail_unless(!strcmp(s, "weber"), NULL);


  s = UnitKind_toString(UNIT_KIND_INVALID);
  fail_unless(!strcmp(s, "(Invalid UnitKind)"), NULL );

  s = UnitKind_toString((UnitKind_t)-1);
  fail_unless(!strcmp(s, "(Invalid UnitKind)"), NULL );

  s = UnitKind_toString((UnitKind_t)(UNIT_KIND_INVALID + 1));
  fail_unless(!strcmp(s, "(Invalid UnitKind)"), NULL );
}
END_TEST


START_TEST (test_UnitKind_isValidUnitKindString)
{
  fail_unless( !UnitKind_isValidUnitKindString("fun-foam-unit for kids!", 1, 1),
               NULL );

  fail_unless( UnitKind_isValidUnitKindString("litre", 2, 2), NULL );
  fail_unless( !UnitKind_isValidUnitKindString("liter", 2, 2), NULL );
  fail_unless( UnitKind_isValidUnitKindString("liter", 1, 2), NULL );
  fail_unless( !UnitKind_isValidUnitKindString("meter", 2, 3), NULL );
  fail_unless( UnitKind_isValidUnitKindString("metre", 2, 1), NULL );
  fail_unless( UnitKind_isValidUnitKindString("meter", 1, 2), NULL );
  fail_unless( UnitKind_isValidUnitKindString("Celsius", 2, 1), NULL );
  fail_unless( !UnitKind_isValidUnitKindString("Celsius", 2, 2), NULL );
}
END_TEST


Suite *
create_suite_UnitKind (void) 
{ 
  Suite *suite = suite_create("UnitKind");
  TCase *tcase = tcase_create("UnitKind");


  tcase_add_test( tcase, test_UnitKind_equals   );
  tcase_add_test( tcase, test_UnitKind_forName  );
  tcase_add_test( tcase, test_UnitKind_toString );
  tcase_add_test( tcase, test_UnitKind_isValidUnitKindString );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS
