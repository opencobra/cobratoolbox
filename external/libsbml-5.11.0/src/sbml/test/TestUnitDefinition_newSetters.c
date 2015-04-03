/**
 * \file    TestUnitDefinition.c
 * \brief   SBML UnitDefinition unit tests for new API
 * \author  sarah Keating
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
#include <sbml/UnitDefinition.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static UnitDefinition_t *UD;


void
UnitDefinitionTest1_setup (void)
{
  UD = UnitDefinition_create(2, 4);

  if (UD == NULL)
  {
    fail("UnitDefinition_create() returned a NULL pointer.");
  }
}


void
UnitDefinitionTest1_teardown (void)
{
  UnitDefinition_free(UD);
}


START_TEST (test_UnitDefinition_setId1)
{
  int i = UnitDefinition_setId(UD, "mmls");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(UnitDefinition_getId(UD), "mmls") );
  fail_unless( UnitDefinition_isSetId(UD) );

  i = UnitDefinition_setId(UD, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !UnitDefinition_isSetId(UD) );

  i = UnitDefinition_setId(UD, "123");
  
  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE);
  fail_unless( !UnitDefinition_isSetId(UD) );

}
END_TEST


START_TEST (test_UnitDefinition_setName1)
{
  int i = UnitDefinition_setName(UD, "mmls");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(UnitDefinition_getName(UD), "mmls") );
  fail_unless( UnitDefinition_isSetName(UD) );

  i = UnitDefinition_setName(UD, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !UnitDefinition_isSetName(UD) );

  i = UnitDefinition_setName(UD, "123");
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( UnitDefinition_isSetName(UD) );

}
END_TEST


START_TEST (test_UnitDefinition_setName2)
{
  int i = UnitDefinition_setName(UD, "mmls");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !strcmp(UnitDefinition_getName(UD), "mmls") );
  fail_unless( UnitDefinition_isSetName(UD) );

  i = UnitDefinition_unsetName(UD);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !UnitDefinition_isSetName(UD) );
}
END_TEST


START_TEST (test_UnitDefinition_addUnit1)
{
  UnitDefinition_t *m = UnitDefinition_create(2, 2);
  Unit_t *p 
    = Unit_create(2, 2);

  int i = UnitDefinition_addUnit(m, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  Unit_setKind(p, UNIT_KIND_MOLE);
  i = UnitDefinition_addUnit(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( UnitDefinition_getNumUnits(m) == 1);

  Unit_free(p);
  UnitDefinition_free(m);
}
END_TEST


START_TEST (test_UnitDefinition_addUnit2)
{
  UnitDefinition_t *m = UnitDefinition_create(2, 2);
  Unit_t *p 
    = Unit_create(2, 1);
  Unit_setKind(p, UNIT_KIND_MOLE);

  int i = UnitDefinition_addUnit(m, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( UnitDefinition_getNumUnits(m) == 0);

  Unit_free(p);
  UnitDefinition_free(m);
}
END_TEST


START_TEST (test_UnitDefinition_addUnit3)
{
  UnitDefinition_t *m = UnitDefinition_create(2, 2);
  Unit_t *p 
    = Unit_create(1, 2);
  Unit_setKind(p, UNIT_KIND_MOLE);

  int i = UnitDefinition_addUnit(m, p);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( UnitDefinition_getNumUnits(m) == 0);

  Unit_free(p);
  UnitDefinition_free(m);
}
END_TEST


START_TEST (test_UnitDefinition_addUnit4)
{
  UnitDefinition_t *m = UnitDefinition_create(2, 2);
  Unit_t *p = NULL; 

  int i = UnitDefinition_addUnit(m, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( UnitDefinition_getNumUnits(m) == 0);

  UnitDefinition_free(m);
}
END_TEST


START_TEST (test_UnitDefinition_createUnit)
{
  UnitDefinition_t *m = UnitDefinition_create(2, 2);
  
  Unit_t *p = UnitDefinition_createUnit(m);

  fail_unless( UnitDefinition_getNumUnits(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  UnitDefinition_free(m);
}
END_TEST


Suite *
create_suite_UnitDefinition_newSetters (void)
{
  Suite *suite = suite_create("UnitDefinition_newSetters");
  TCase *tcase = tcase_create("UnitDefinition_newSetters");


  tcase_add_checked_fixture( tcase,
                             UnitDefinitionTest1_setup,
                             UnitDefinitionTest1_teardown );

  tcase_add_test( tcase, test_UnitDefinition_setId1                 );
  tcase_add_test( tcase, test_UnitDefinition_setName1               );
  tcase_add_test( tcase, test_UnitDefinition_setName2               );
  tcase_add_test( tcase, test_UnitDefinition_addUnit1               );
  tcase_add_test( tcase, test_UnitDefinition_addUnit2               );
  tcase_add_test( tcase, test_UnitDefinition_addUnit3               );
  tcase_add_test( tcase, test_UnitDefinition_addUnit4               );
  tcase_add_test( tcase, test_UnitDefinition_createUnit             );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

