/**
 * \file    TestModelCreator_newSetters.cpp
 * \brief   ModelCreator unit tests
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
#include <sbml/common/extern.h>
#include <sbml/util/List.h>
#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>
#include <sbml/xml/XMLNode.h>


#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_ModelCreator_setFamilyName)
{
  ModelCreator_t * mc = ModelCreator_create();
  fail_unless(mc != NULL);

  int i = ModelCreator_setFamilyName(mc, "Keating");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetFamilyName(mc) == 1);
  fail_unless(!strcmp(ModelCreator_getFamilyName(mc), "Keating"));

  i = ModelCreator_setFamilyName(mc, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetFamilyName(mc) == 0);

  i = ModelCreator_setFamilyName(mc, "Keating");

  fail_unless(ModelCreator_isSetFamilyName(mc) == 1);

  i = ModelCreator_unsetFamilyName(mc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetFamilyName(mc) == 0);

  ModelCreator_free(mc);
}
END_TEST


START_TEST (test_ModelCreator_setGivenName)
{
  ModelCreator_t * mc = ModelCreator_create();
  fail_unless(mc != NULL);

  int i = ModelCreator_setGivenName(mc, "Sarah");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetGivenName(mc) == 1);
  fail_unless(!strcmp(ModelCreator_getGivenName(mc), "Sarah"));

  i = ModelCreator_setGivenName(mc, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetGivenName(mc) == 0);

  i = ModelCreator_setGivenName(mc, "Sarah");

  fail_unless(ModelCreator_isSetGivenName(mc) == 1);

  i = ModelCreator_unsetGivenName(mc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetGivenName(mc) == 0);

  ModelCreator_free(mc);
}
END_TEST


START_TEST (test_ModelCreator_setEmail)
{
  ModelCreator_t * mc = ModelCreator_create();
  fail_unless(mc != NULL);

  int i = ModelCreator_setEmail(mc, "Keating");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetEmail(mc) == 1);
  fail_unless(!strcmp(ModelCreator_getEmail(mc), "Keating"));

  i = ModelCreator_setEmail(mc, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetEmail(mc) == 0);

  i = ModelCreator_setEmail(mc, "Keating");

  fail_unless(ModelCreator_isSetEmail(mc) == 1);

  i = ModelCreator_unsetEmail(mc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetEmail(mc) == 0);

  ModelCreator_free(mc);
}
END_TEST


START_TEST (test_ModelCreator_setOrganization)
{
  ModelCreator_t * mc = ModelCreator_create();
  fail_unless(mc != NULL);

  int i = ModelCreator_setOrganization(mc, "Caltech");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetOrganization(mc) == 1);
  fail_unless(!strcmp(ModelCreator_getOrganization(mc), "Caltech"));

  i = ModelCreator_setOrganization(mc, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetOrganization(mc) == 0);

  i = ModelCreator_setOrganization(mc, "Caltech");

  fail_unless(ModelCreator_isSetOrganization(mc) == 1);

  i = ModelCreator_unsetOrganization(mc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelCreator_isSetOrganization(mc) == 0);

  ModelCreator_free(mc);
}
END_TEST

START_TEST (test_ModelCreator_accessWithNULL)
{
	fail_unless( ModelCreator_clone(NULL) == NULL );
	fail_unless( ModelCreator_createFromNode(NULL) == NULL );

    ModelCreator_free(NULL);

	fail_unless( ModelCreator_getEmail(NULL) == NULL );
	fail_unless( ModelCreator_getFamilyName(NULL) == NULL );
	fail_unless( ModelCreator_getGivenName(NULL) == NULL );
	fail_unless( ModelCreator_getOrganisation(NULL) == NULL );
	fail_unless( ModelCreator_getOrganization(NULL) == NULL );
	fail_unless( ModelCreator_hasRequiredAttributes(NULL) == 0 );
	fail_unless( ModelCreator_isSetEmail(NULL) == 0 );
	fail_unless( ModelCreator_isSetFamilyName(NULL) == 0 );
	fail_unless( ModelCreator_isSetGivenName(NULL) == 0 );
	fail_unless( ModelCreator_isSetOrganisation(NULL) == 0 );
	fail_unless( ModelCreator_isSetOrganization(NULL) == 0 );
	fail_unless( ModelCreator_setEmail(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_setFamilyName(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_setGivenName(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_setOrganisation(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_setOrganization(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_unsetEmail(NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_unsetFamilyName(NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_unsetGivenName(NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_unsetOrganisation(NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( ModelCreator_unsetOrganization(NULL) == LIBSBML_INVALID_OBJECT );

}
END_TEST


Suite *
create_suite_ModelCreator_newSetters (void)
{
  Suite *suite = suite_create("ModelCreator_newSetters");
  TCase *tcase = tcase_create("ModelCreator_newSetters");


  tcase_add_test( tcase, test_ModelCreator_setFamilyName  );
  tcase_add_test( tcase, test_ModelCreator_setGivenName  );
  tcase_add_test( tcase, test_ModelCreator_setEmail  );
  tcase_add_test( tcase, test_ModelCreator_setOrganization  );
  tcase_add_test( tcase, test_ModelCreator_accessWithNULL  );

  suite_add_tcase(suite, tcase);

  return suite;
}


#if defined(__cplusplus)
CK_CPPEND
#endif

