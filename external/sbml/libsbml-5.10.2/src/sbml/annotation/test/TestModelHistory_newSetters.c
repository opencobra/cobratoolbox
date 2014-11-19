/**
 * \file    TestModelHistory_newSetters.cpp
 * \brief   ModelHistory unit tests
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

START_TEST (test_ModelHistory_setCreatedDate1)
{
  ModelHistory_t * mh = ModelHistory_create();
  fail_unless(mh != NULL);

  Date_t *date = Date_createFromString("2005-12-30T12:15:32+02:00");

  int i = ModelHistory_setCreatedDate(mh, date);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelHistory_isSetCreatedDate(mh) == 1);

  fail_unless(date != ModelHistory_getCreatedDate(mh));

  const char * dateChar
    = Date_getDateAsString(ModelHistory_getCreatedDate(mh));
  fail_unless(!strcmp(dateChar, "2005-12-30T12:15:32+02:00"));

  i = ModelHistory_setCreatedDate(mh, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelHistory_isSetCreatedDate(mh) == 0);

  Date_free(date);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_setCreatedDate2)
{
  ModelHistory_t * mh = ModelHistory_create();
  fail_unless(mh != NULL);

  Date_t *date = Date_createFromString("Jan 12");

  int i = ModelHistory_setCreatedDate(mh, date);

  fail_unless( i == LIBSBML_INVALID_OBJECT );
  fail_unless(ModelHistory_isSetCreatedDate(mh) == 0);

  Date_free(date);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_setModifiedDate1)
{
  ModelHistory_t * mh = ModelHistory_create();
  fail_unless(mh != NULL);

  Date_t *date = Date_createFromString("2005-12-30T12:15:32+02:00");

  int i = ModelHistory_setModifiedDate(mh, date);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelHistory_isSetModifiedDate(mh) == 1);

  fail_unless(date != ModelHistory_getModifiedDate(mh));

  const char * dateChar
    = Date_getDateAsString(ModelHistory_getModifiedDate(mh));
  fail_unless(!strcmp(dateChar, "2005-12-30T12:15:32+02:00"));

  i = ModelHistory_setModifiedDate(mh, NULL);

  fail_unless( i == LIBSBML_OPERATION_FAILED );
  fail_unless(ModelHistory_isSetModifiedDate(mh) == 1);

  Date_free(date);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_setModifiedDate2)
{
  ModelHistory_t * mh = ModelHistory_create();
  fail_unless(mh != NULL);

  Date_t *date = Date_createFromValues(200, 13, 76, 56, 89, 90, 0, 0, 0);

  int i = ModelHistory_setModifiedDate(mh, date);

  fail_unless( i == LIBSBML_INVALID_OBJECT );
  fail_unless(ModelHistory_isSetModifiedDate(mh) == 0);

  Date_free(date);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_addCreator1)
{
  ModelHistory_t * mh = ModelHistory_create();
  ModelCreator_t * mc = ModelCreator_create();
  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");

  int i = ModelHistory_addCreator(mh, mc);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(ModelHistory_getNumCreators(mh) == 1);

  ModelCreator_free(mc);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_addCreator2)
{
  ModelHistory_t * mh = ModelHistory_create();
  ModelCreator_t * mc = ModelCreator_create();
  ModelCreator_setGivenName(mc, "Sarah");

  int i = ModelHistory_addCreator(mh, mc);

  fail_unless( i == LIBSBML_INVALID_OBJECT );
  fail_unless(ModelHistory_getNumCreators(mh) == 0);

  ModelCreator_free(mc);
  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_ModelHistory_addCreator3)
{
  ModelHistory_t * mh = ModelHistory_create();
  ModelCreator_t * mc = NULL;

  int i = ModelHistory_addCreator(mh, mc);

  fail_unless( i == LIBSBML_OPERATION_FAILED );
  fail_unless(ModelHistory_getNumCreators(mh) == 0);

  ModelHistory_free(mh);
}
END_TEST


Suite *
create_suite_ModelHistory_newSetters (void)
{
  Suite *suite = suite_create("ModelHistory_newSetters");
  TCase *tcase = tcase_create("ModelHistory_newSetters");


  tcase_add_test( tcase, test_ModelHistory_setCreatedDate1  );
  tcase_add_test( tcase, test_ModelHistory_setCreatedDate2  );
  tcase_add_test( tcase, test_ModelHistory_setModifiedDate1  );
  tcase_add_test( tcase, test_ModelHistory_setModifiedDate2  );
  tcase_add_test( tcase, test_ModelHistory_addCreator1  );
  tcase_add_test( tcase, test_ModelHistory_addCreator2  );
  tcase_add_test( tcase, test_ModelHistory_addCreator3  );

  suite_add_tcase(suite, tcase);

  return suite;
}


#if defined(__cplusplus)
CK_CPPEND
#endif

