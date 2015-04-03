/**
 * \file    TestParameter_newSetters.p
 * \brief   Parameter unit tests for new set function API
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
#include <sbml/Parameter.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Parameter_t *P;


void
ParameterTest1_setup (void)
{
  P = Parameter_create(1, 2);

  if (P == NULL)
  {
    fail("Parameter_create() returned a NULL pointer.");
  }
}


void
ParameterTest1_teardown (void)
{
  Parameter_free(P);
}


START_TEST (test_Parameter_setId1)
{
  int i = Parameter_setId(P, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Parameter_isSetId(P) );
}
END_TEST


START_TEST (test_Parameter_setId2)
{
  int i = Parameter_setId(P, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_isSetId(P) );
  fail_unless( !strcmp(Parameter_getId(P), "cell" ));

  i = Parameter_setId(P, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetId(P) );
}
END_TEST


START_TEST (test_Parameter_setName1)
{
  int i = Parameter_setName(P, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_isSetName(P) );

  i = Parameter_unsetName(P);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetName(P) );
}
END_TEST


START_TEST (test_Parameter_setName2)
{
  Parameter_t *p = 
    Parameter_create(2, 2);

  int i = Parameter_setName(p, "1cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_isSetName(p) );

  i = Parameter_unsetName(p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetName(p) );

  Parameter_free(p);
}
END_TEST


START_TEST (test_Parameter_setName3)
{
  Parameter_t *p = 
    Parameter_create(1, 2);

  int i = Parameter_setName(p, "11pp");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Parameter_isSetName(p) );

  i = Parameter_setName(p, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetName(p) );

  Parameter_free(p);
}
END_TEST


START_TEST (test_Parameter_setValue1)
{
  int i = Parameter_setValue(P, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_getValue(P) == 2.0 );
  fail_unless( Parameter_isSetValue(P));

  i = Parameter_unsetValue(P);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetValue(P));
}
END_TEST


START_TEST (test_Parameter_setValue2)
{
  Parameter_t *p = 
    Parameter_create(2, 2);

  int i = Parameter_unsetValue(p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetValue(p));

  Parameter_free(p);
}
END_TEST


START_TEST (test_Parameter_setUnits1)
{
  int i = Parameter_setUnits(P, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Parameter_isSetUnits(P) );

  i = Parameter_unsetUnits(P);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetUnits(P) );
}
END_TEST


START_TEST (test_Parameter_setUnits2)
{
  int i = Parameter_setUnits(P, "litre");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_isSetUnits(P) );

  i = Parameter_unsetUnits(P);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetUnits(P) );
}
END_TEST


START_TEST (test_Parameter_setUnits3)
{
  int i = Parameter_setUnits(P, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Parameter_isSetUnits(P) );
}
END_TEST


START_TEST (test_Parameter_setConstant1)
{
  int i = Parameter_setConstant(P, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Parameter_getConstant(P) == 0 );
}
END_TEST


START_TEST (test_Parameter_setConstant2)
{
  Parameter_t *p = 
    Parameter_create(2, 2);

  int i = Parameter_setConstant(p, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Parameter_getConstant(p) == 0 );

  Parameter_free(p);
}
END_TEST


Suite *
create_suite_Parameter_newSetters (void)
{
  Suite *suite = suite_create("Parameter_newSetters");
  TCase *tcase = tcase_create("Parameter_newSetters");


  tcase_add_checked_fixture( tcase,
                             ParameterTest1_setup,
                             ParameterTest1_teardown );

  tcase_add_test( tcase, test_Parameter_setId1       );
  tcase_add_test( tcase, test_Parameter_setId2       );
  tcase_add_test( tcase, test_Parameter_setName1       );
  tcase_add_test( tcase, test_Parameter_setName2       );
  tcase_add_test( tcase, test_Parameter_setName3       );
  tcase_add_test( tcase, test_Parameter_setValue1       );
  tcase_add_test( tcase, test_Parameter_setValue2       );
  tcase_add_test( tcase, test_Parameter_setUnits1       );
  tcase_add_test( tcase, test_Parameter_setUnits2       );
  tcase_add_test( tcase, test_Parameter_setUnits3       );
  tcase_add_test( tcase, test_Parameter_setConstant1       );
  tcase_add_test( tcase, test_Parameter_setConstant2       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

