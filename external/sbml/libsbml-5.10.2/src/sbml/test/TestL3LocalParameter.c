/**
 * \file    TestL3LocalParameter.c
 * \brief   L3 Local Parameter unit tests
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
#include <sbml/LocalParameter.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS


static LocalParameter_t *P;


void
L3LocalParameterTest_setup (void)
{
  P = LocalParameter_create(3, 1);

  if (P == NULL)
  {
    fail("LocalParameter_create(3, 1) returned a NULL pointer.");
  }
}


void
L3LocalParameterTest_teardown (void)
{
  LocalParameter_free(P);
}


START_TEST (test_L3_LocalParameter_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) P) == SBML_LOCAL_PARAMETER );
  fail_unless( SBase_getMetaId    ((SBase_t *) P) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) P) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) P) == NULL );

  fail_unless( LocalParameter_getId     (P) == NULL );
  fail_unless( LocalParameter_getName   (P) == NULL );
  fail_unless( LocalParameter_getUnits  (P) == NULL );
  fail_unless( util_isNaN(LocalParameter_getValue(P)));

  fail_unless( !LocalParameter_isSetId     (P) );
  fail_unless( !LocalParameter_isSetName   (P) );
  fail_unless( !LocalParameter_isSetValue (P) );
  fail_unless( !LocalParameter_isSetUnits  (P) );
}
END_TEST


START_TEST (test_L3_LocalParameter_free_NULL)
{
  LocalParameter_free(NULL);
}
END_TEST


START_TEST (test_L3_LocalParameter_id)
{
  const char *id = "mitochondria";


  fail_unless( !LocalParameter_isSetId(P) );
  
  LocalParameter_setId(P, id);

  fail_unless( !strcmp(LocalParameter_getId(P), id) );
  fail_unless( LocalParameter_isSetId(P) );

  if (LocalParameter_getId(P) == id)
  {
    fail("LocalParameter_setId(...) did not make a copy of string.");
  }
}
END_TEST


START_TEST (test_L3_LocalParameter_name)
{
  const char *name = "My_Favorite_Factory";


  fail_unless( !LocalParameter_isSetName(P) );

  LocalParameter_setName(P, name);

  fail_unless( !strcmp(LocalParameter_getName(P), name) );
  fail_unless( LocalParameter_isSetName(P) );

  if (LocalParameter_getName(P) == name)
  {
    fail("LocalParameter_setName(...) did not make a copy of string.");
  }

  LocalParameter_unsetName(P);
  
  fail_unless( !LocalParameter_isSetName(P) );

  if (LocalParameter_getName(P) != NULL)
  {
    fail("LocalParameter_unsetName(P) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_LocalParameter_units)
{
  const char *units = "volume";


  fail_unless( !LocalParameter_isSetUnits(P) );
  
  LocalParameter_setUnits(P, units);

  fail_unless( !strcmp(LocalParameter_getUnits(P), units) );
  fail_unless( LocalParameter_isSetUnits(P) );

  if (LocalParameter_getUnits(P) == units)
  {
    fail("LocalParameter_setUnits(...) did not make a copy of string.");
  }

  LocalParameter_unsetUnits(P);
  
  fail_unless( !LocalParameter_isSetUnits(P) );

  if (LocalParameter_getUnits(P) != NULL)
  {
    fail("LocalParameter_unsetUnits(P, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_LocalParameter_value)
{
  fail_unless( !LocalParameter_isSetValue(P));
  fail_unless( util_isNaN(LocalParameter_getValue(P)));

  LocalParameter_setValue(P, 1.5);

  fail_unless( LocalParameter_isSetValue(P));
  fail_unless( LocalParameter_getValue(P) == 1.5);

  LocalParameter_unsetValue(P);

  fail_unless( !LocalParameter_isSetValue(P));
  fail_unless( util_isNaN(LocalParameter_getValue(P)));
}
END_TEST


START_TEST (test_L3_LocalParameter_constant)
{
  /* a local Parameter does not have a constant attribute but
   * because it derives from parameter it inherits one
   * need to make sure these do the right thing
   */

  fail_unless(LocalParameter_getConstant(P) == 1);

  int i = LocalParameter_setConstant(P, 0);

  fail_unless ( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  
  fail_unless(LocalParameter_getConstant(P) == 1);
}
END_TEST


START_TEST (test_L3_LocalParameter_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  LocalParameter_t *p = 
    LocalParameter_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) p) == SBML_LOCAL_PARAMETER );
  fail_unless( SBase_getMetaId    ((SBase_t *) p) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) p) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) p) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) p) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) p) == 1 );

  fail_unless( LocalParameter_getNamespaces     (p) != NULL );
  fail_unless( XMLNamespaces_getLength(LocalParameter_getNamespaces(p)) == 2 );


  fail_unless( LocalParameter_getId     (p) == NULL );
  fail_unless( LocalParameter_getName   (p) == NULL );
  fail_unless( LocalParameter_getUnits  (p) == NULL );
  fail_unless( util_isNaN(LocalParameter_getValue(p)));

  fail_unless( !LocalParameter_isSetId     (p) );
  fail_unless( !LocalParameter_isSetName   (p) );
  fail_unless( !LocalParameter_isSetValue (p) );
  fail_unless( !LocalParameter_isSetUnits  (p) );

  LocalParameter_free(p);
}
END_TEST


START_TEST (test_L3_LocalParameter_hasRequiredAttributes )
{
  LocalParameter_t *p = LocalParameter_create (3, 1);

  fail_unless ( !LocalParameter_hasRequiredAttributes(p));

  LocalParameter_setId(p, "id");

  fail_unless ( LocalParameter_hasRequiredAttributes(p));

  LocalParameter_free(p);
}
END_TEST


START_TEST (test_L3_LocalParameter_NS)
{
  fail_unless( LocalParameter_getNamespaces     (P) != NULL );
  fail_unless( XMLNamespaces_getLength(LocalParameter_getNamespaces(P)) == 1 );
  fail_unless( !strcmp( XMLNamespaces_getURI(LocalParameter_getNamespaces(P), 0),
    "http://www.sbml.org/sbml/level3/version1/core"));
}
END_TEST


Suite *
create_suite_L3_LocalParameter (void)
{
  Suite *suite = suite_create("L3_LocalParameter");
  TCase *tcase = tcase_create("L3_LocalParameter");


  tcase_add_checked_fixture( tcase,
                             L3LocalParameterTest_setup,
                             L3LocalParameterTest_teardown );

  tcase_add_test( tcase, test_L3_LocalParameter_create              );
  tcase_add_test( tcase, test_L3_LocalParameter_free_NULL           );
  tcase_add_test( tcase, test_L3_LocalParameter_id               );
  tcase_add_test( tcase, test_L3_LocalParameter_name             );
  tcase_add_test( tcase, test_L3_LocalParameter_units            );
  tcase_add_test( tcase, test_L3_LocalParameter_value);
  tcase_add_test( tcase, test_L3_LocalParameter_constant);
  tcase_add_test( tcase, test_L3_LocalParameter_createWithNS         );
  tcase_add_test( tcase, test_L3_LocalParameter_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_LocalParameter_NS              );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

