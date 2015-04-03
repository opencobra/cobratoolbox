/**
 * \file    TestSpeciesType_newSetters.c
 * \brief   SpeciesType unit tests for new set function API
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
#include <sbml/SpeciesType.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static SpeciesType_t *ST;


void
SpeciesTypeTest1_setup (void)
{
  ST = SpeciesType_create(2, 2);

  if (ST == NULL)
  {
    fail("SpeciesType_create() returned a NULL pointer.");
  }
}


void
SpeciesTypeTest1_teardown (void)
{
  SpeciesType_free(ST);
}


START_TEST (test_SpeciesType_setId2)
{
  int i = SpeciesType_setId(ST, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !SpeciesType_isSetId(ST) );
}
END_TEST


START_TEST (test_SpeciesType_setId3)
{
  int i = SpeciesType_setId(ST, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SpeciesType_isSetId(ST) );
  fail_unless( !strcmp(SpeciesType_getId(ST), "cell" ));
}
END_TEST


START_TEST (test_SpeciesType_setId4)
{
  int i = SpeciesType_setId(ST, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SpeciesType_isSetId(ST) );
  fail_unless( !strcmp(SpeciesType_getId(ST), "cell" ));
  
  i = SpeciesType_setId(ST, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SpeciesType_isSetId(ST) );
}
END_TEST


START_TEST (test_SpeciesType_setName1)
{
  int i = SpeciesType_setName(ST, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SpeciesType_isSetName(ST) );

  i = SpeciesType_unsetName(ST);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SpeciesType_isSetName(ST) );
}
END_TEST


START_TEST (test_SpeciesType_setName2)
{
  int i = SpeciesType_setName(ST, "1cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SpeciesType_isSetName(ST) );

  i = SpeciesType_unsetName(ST);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SpeciesType_isSetName(ST) );
}
END_TEST


START_TEST (test_SpeciesType_setName3)
{
  int i = SpeciesType_setName(ST, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SpeciesType_isSetName(ST) );

  i = SpeciesType_setName(ST, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SpeciesType_isSetName(ST) );
}
END_TEST


Suite *
create_suite_SpeciesType_newSetters (void)
{
  Suite *suite = suite_create("SpeciesType_newSetters");
  TCase *tcase = tcase_create("SpeciesType_newSetters");


  tcase_add_checked_fixture( tcase,
                             SpeciesTypeTest1_setup,
                             SpeciesTypeTest1_teardown );

  tcase_add_test( tcase, test_SpeciesType_setId2       );
  tcase_add_test( tcase, test_SpeciesType_setId3       );
  tcase_add_test( tcase, test_SpeciesType_setId4       );
  tcase_add_test( tcase, test_SpeciesType_setName1       );
  tcase_add_test( tcase, test_SpeciesType_setName2       );
  tcase_add_test( tcase, test_SpeciesType_setName3       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


