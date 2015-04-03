/**
 * \file    TestModelHistory.cpp
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

START_TEST (test_Date_create)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);

  fail_unless(date != NULL);
  fail_unless(Date_getYear(date) == 2005);
  fail_unless(Date_getMonth(date) == 12);
  fail_unless(Date_getDay(date) == 30);
  fail_unless(Date_getHour(date) == 12);
  fail_unless(Date_getMinute(date) == 15);
  fail_unless(Date_getSecond(date) == 45);
  fail_unless(Date_getSignOffset(date) == 1);
  fail_unless(Date_getHoursOffset(date) == 2);
  fail_unless(Date_getMinutesOffset(date) == 0);

  Date_free(date);
}
END_TEST

START_TEST (test_Date_createFromString)
{
  const char * dd = "2012-12-02T14:56:11Z";

  Date_t * date = Date_createFromString(dd);

  fail_unless(date != NULL);
  fail_unless(!strcmp(Date_getDateAsString(date), "2012-12-02T14:56:11Z"));
  fail_unless(Date_getYear(date) == 2012);
  fail_unless(Date_getMonth(date) == 12);
  fail_unless(Date_getDay(date) == 2);
  fail_unless(Date_getHour(date) == 14);
  fail_unless(Date_getMinute(date) == 56);
  fail_unless(Date_getSecond(date) == 11);
  fail_unless(Date_getSignOffset(date) == 0);
  fail_unless(Date_getHoursOffset(date) == 0);
  fail_unless(Date_getMinutesOffset(date) == 0);

  Date_free(date);
}
END_TEST

START_TEST (test_Date_setters)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  Date_setYear(date, 2012);
  Date_setMonth(date, 3);
  Date_setDay(date, 28);
  Date_setHour(date, 23);
  Date_setMinute(date, 4);
  Date_setSecond(date, 32);
  Date_setSignOffset(date, 1);
  Date_setHoursOffset(date, 2);
  Date_setMinutesOffset(date, 32);

  fail_unless(Date_getYear(date) == 2012);
  fail_unless(Date_getMonth(date) == 3);
  fail_unless(Date_getDay(date) == 28);
  fail_unless(Date_getHour(date) == 23);
  fail_unless(Date_getMinute(date) == 4);
  fail_unless(Date_getSecond(date) == 32);
  fail_unless(Date_getSignOffset(date) == 1);
  fail_unless(Date_getHoursOffset(date) == 2);
  fail_unless(Date_getMinutesOffset(date) == 32);
  fail_unless(!strcmp(Date_getDateAsString(date), "2012-03-28T23:04:32+02:32"));

  Date_free(date);
}
END_TEST

START_TEST (test_Date_getDateAsString)
{
  const char * dd = "2005-02-02T14:56:11Z";

  Date_t * date = Date_createFromString(dd);

  fail_unless(date != NULL);
  fail_unless(Date_getYear(date) == 2005);
  fail_unless(Date_getMonth(date) == 2);
  fail_unless(Date_getDay(date) == 2);
  fail_unless(Date_getHour(date) == 14);
  fail_unless(Date_getMinute(date) == 56);
  fail_unless(Date_getSecond(date) == 11);
  fail_unless(Date_getSignOffset(date) == 0);
  fail_unless(Date_getHoursOffset(date) == 0);
  fail_unless(Date_getMinutesOffset(date) == 0);

  Date_setYear(date, 2012);
  Date_setMonth(date, 3);
  Date_setDay(date, 28);
  Date_setHour(date, 23);
  Date_setMinute(date, 4);
  Date_setSecond(date, 32);
  Date_setSignOffset(date, 1);
  Date_setHoursOffset(date, 2);
  Date_setMinutesOffset(date, 32);

  fail_unless(!strcmp(Date_getDateAsString(date), "2012-03-28T23:04:32+02:32"));

  Date_free(date);
}
END_TEST

START_TEST(test_ModelCreator_create)
{
  ModelCreator_t * mc = ModelCreator_create();

  fail_unless(mc != NULL);

  ModelCreator_free(mc);

}
END_TEST


START_TEST(test_ModelCreator_setters)
{
  ModelCreator_t * mc = ModelCreator_create();

  fail_unless(mc != NULL);

  fail_unless(ModelCreator_isSetFamilyName(mc) == 0);
  fail_unless(ModelCreator_isSetGivenName(mc) == 0);
  fail_unless(ModelCreator_isSetEmail(mc) == 0);
  fail_unless(ModelCreator_isSetOrganisation(mc) == 0);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  fail_unless(!strcmp(ModelCreator_getFamilyName(mc), "Keating"));
  fail_unless(!strcmp(ModelCreator_getGivenName(mc), "Sarah"));
  fail_unless(!strcmp(ModelCreator_getEmail(mc), "sbml-team@caltech.edu"));
  fail_unless(!strcmp(ModelCreator_getOrganisation(mc), "UH"));

  fail_unless(ModelCreator_isSetFamilyName(mc) == 1);
  fail_unless(ModelCreator_isSetGivenName(mc) == 1);
  fail_unless(ModelCreator_isSetEmail(mc) == 1);
  fail_unless(ModelCreator_isSetOrganisation(mc) == 1);

  ModelCreator_unsetFamilyName(mc);
  ModelCreator_unsetGivenName(mc);
  ModelCreator_unsetEmail(mc);
  ModelCreator_unsetOrganisation(mc);

  fail_unless(!strcmp(ModelCreator_getFamilyName(mc), ""));
  fail_unless(!strcmp(ModelCreator_getGivenName(mc), ""));
  fail_unless(!strcmp(ModelCreator_getEmail(mc), ""));
  fail_unless(!strcmp(ModelCreator_getOrganisation(mc), ""));

  fail_unless(ModelCreator_isSetFamilyName(mc) == 0);
  fail_unless(ModelCreator_isSetGivenName(mc) == 0);
  fail_unless(ModelCreator_isSetEmail(mc) == 0);
  fail_unless(ModelCreator_isSetOrganisation(mc) == 0);

  // test alternate spelling functions
  fail_unless(ModelCreator_isSetOrganization(mc) == 0);
  
  ModelCreator_setOrganization(mc, "UH");

  fail_unless(!strcmp(ModelCreator_getOrganization(mc), "UH"));
  fail_unless(ModelCreator_isSetOrganization(mc) == 1);

  ModelCreator_unsetOrganisation(mc);

  fail_unless(!strcmp(ModelCreator_getOrganization(mc), ""));
  fail_unless(ModelCreator_isSetOrganization(mc) == 0);

  ModelCreator_free(mc);

}
END_TEST

START_TEST (test_ModelHistory_create)
{
  ModelHistory_t * history = ModelHistory_create();

  fail_unless(history != NULL);
  fail_unless(ModelHistory_getListCreators(history) != NULL);
  fail_unless(ModelHistory_getCreatedDate(history) == NULL);
  fail_unless(ModelHistory_getModifiedDate(history) == NULL);

  ModelHistory_free(history);
}
END_TEST

START_TEST (test_ModelHistory_addCreator)
{
  ModelCreator_t * newMC;
  ModelHistory_t * history = ModelHistory_create();

  fail_unless(ModelHistory_getNumCreators(history) == 0);

  fail_unless(history != NULL);

  ModelCreator_t * mc = ModelCreator_create();
  fail_unless(mc != NULL);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  ModelHistory_addCreator(history, mc);

  fail_unless(ModelHistory_getNumCreators(history) == 1);
  ModelCreator_free(mc);

  newMC = (ModelCreator_t*) List_get(ModelHistory_getListCreators(history), 0);
  fail_unless(newMC != NULL);

  fail_unless(!strcmp(ModelCreator_getFamilyName(newMC), "Keating"));
  fail_unless(!strcmp(ModelCreator_getGivenName(newMC), "Sarah"));
  fail_unless(!strcmp(ModelCreator_getEmail(newMC), "sbml-team@caltech.edu"));
  fail_unless(!strcmp(ModelCreator_getOrganisation(newMC), "UH"));

  ModelHistory_free(history);
}
END_TEST

START_TEST (test_ModelHistory_setCreatedDate)
{
  ModelHistory_t * history = ModelHistory_create();

  fail_unless(history != NULL);

  fail_unless(ModelHistory_isSetCreatedDate(history) == 0);

  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  ModelHistory_setCreatedDate(history, date);
  fail_unless(ModelHistory_isSetCreatedDate(history) == 1);

  Date_free(date);

  Date_t * newdate = ModelHistory_getCreatedDate(history);
  fail_unless(Date_getYear(newdate) == 2005);
  fail_unless(Date_getMonth(newdate) == 12);
  fail_unless(Date_getDay(newdate) == 30);
  fail_unless(Date_getHour(newdate) == 12);
  fail_unless(Date_getMinute(newdate) == 15);
  fail_unless(Date_getSecond(newdate) == 45);
  fail_unless(Date_getSignOffset(newdate) == 1);
  fail_unless(Date_getHoursOffset(newdate) == 2);
  fail_unless(Date_getMinutesOffset(newdate) == 0);

  ModelHistory_free(history);

}
END_TEST


START_TEST (test_ModelHistory_setModifiedDate)
{
  ModelHistory_t * history = ModelHistory_create();

  fail_unless(history != NULL);
  fail_unless(ModelHistory_isSetModifiedDate(history) == 0);

  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  ModelHistory_setModifiedDate(history, date);
  Date_free(date);
  fail_unless(ModelHistory_isSetModifiedDate(history) == 1);

  Date_t * newdate = ModelHistory_getModifiedDate(history);
  fail_unless(Date_getYear(newdate) == 2005);
  fail_unless(Date_getMonth(newdate) == 12);
  fail_unless(Date_getDay(newdate) == 30);
  fail_unless(Date_getHour(newdate) == 12);
  fail_unless(Date_getMinute(newdate) == 15);
  fail_unless(Date_getSecond(newdate) == 45);
  fail_unless(Date_getSignOffset(newdate) == 1);
  fail_unless(Date_getHoursOffset(newdate) == 2);
  fail_unless(Date_getMinutesOffset(newdate) == 0);

  ModelHistory_free(history);
}
END_TEST


START_TEST (test_ModelHistory_addModifiedDate)
{
  ModelHistory_t * history = ModelHistory_create();

  fail_unless(history != NULL);
  fail_unless(ModelHistory_isSetModifiedDate(history) == 0);
  fail_unless(ModelHistory_getNumModifiedDates(history) == 0);

  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  ModelHistory_addModifiedDate(history, date);
  Date_free(date);

  fail_unless(ModelHistory_getNumModifiedDates(history) == 1);
  fail_unless(ModelHistory_isSetModifiedDate(history) == 1);

  Date_t * newdate = (Date_t *) List_get(ModelHistory_getListModifiedDates(history), 0);

  fail_unless(Date_getYear(newdate) == 2005);
  fail_unless(Date_getMonth(newdate) == 12);
  fail_unless(Date_getDay(newdate) == 30);
  fail_unless(Date_getHour(newdate) == 12);
  fail_unless(Date_getMinute(newdate) == 15);
  fail_unless(Date_getSecond(newdate) == 45);
  fail_unless(Date_getSignOffset(newdate) == 1);
  fail_unless(Date_getHoursOffset(newdate) == 2);
  fail_unless(Date_getMinutesOffset(newdate) == 0);

  Date_t * date1 = Date_createFromValues(2008, 11, 2, 16, 42, 40, 1, 2, 0);
  
  ModelHistory_addModifiedDate(history, date1);
  Date_free(date1);

  fail_unless(ModelHistory_getNumModifiedDates(history) == 2);
  fail_unless(ModelHistory_isSetModifiedDate(history) == 1);

  Date_t * newdate1 = ModelHistory_getModifiedDateFromList(history, 1);

  fail_unless(Date_getYear(newdate1) == 2008);
  fail_unless(Date_getMonth(newdate1) == 11);
  fail_unless(Date_getDay(newdate1) == 2);
  fail_unless(Date_getHour(newdate1) == 16);
  fail_unless(Date_getMinute(newdate1) == 42);
  fail_unless(Date_getSecond(newdate1) == 40);
  fail_unless(Date_getSignOffset(newdate1) == 1);
  fail_unless(Date_getHoursOffset(newdate1) == 2);
  fail_unless(Date_getMinutesOffset(newdate1) == 0);

  ModelHistory_free(history);
}
END_TEST

START_TEST (test_ModelHistory_accessWithNULL)
{
	fail_unless ( ModelHistory_addCreator(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless ( ModelHistory_addModifiedDate(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless ( ModelHistory_clone(NULL) == NULL );

	// ensure that we don't crash
    ModelHistory_free(NULL) ;

	fail_unless ( ModelHistory_getCreatedDate(NULL) == NULL );
	fail_unless ( ModelHistory_getCreator(NULL, 0) == NULL );
	fail_unless ( ModelHistory_getListCreators(NULL) == NULL );
	fail_unless ( ModelHistory_getListModifiedDates(NULL) == NULL );
	fail_unless ( ModelHistory_getModifiedDate(NULL) == NULL );
	fail_unless ( ModelHistory_getModifiedDateFromList(NULL, 0) == NULL );
	fail_unless ( ModelHistory_getNumCreators(NULL) == SBML_INT_MAX );
	fail_unless ( ModelHistory_getNumModifiedDates(NULL) == SBML_INT_MAX );
	fail_unless ( ModelHistory_hasRequiredAttributes(NULL) == 0 );
	fail_unless ( ModelHistory_isSetCreatedDate(NULL) == 0 );
	fail_unless ( ModelHistory_isSetModifiedDate(NULL) == 0 );
	fail_unless ( ModelHistory_setCreatedDate(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless ( ModelHistory_setModifiedDate(NULL, NULL) == LIBSBML_INVALID_OBJECT );

}
END_TEST

Suite *
create_suite_ModelHistory (void)
{
  Suite *suite = suite_create("ModelHistory");
  TCase *tcase = tcase_create("ModelHistory");


  tcase_add_test( tcase, test_Date_create  );
  tcase_add_test( tcase, test_Date_createFromString  );
  tcase_add_test( tcase, test_Date_setters  );
  tcase_add_test( tcase, test_Date_getDateAsString  );
  tcase_add_test( tcase, test_ModelCreator_create  );
  tcase_add_test( tcase, test_ModelCreator_setters  );
  tcase_add_test( tcase, test_ModelHistory_create  );
  tcase_add_test( tcase, test_ModelHistory_addCreator  );
  tcase_add_test( tcase, test_ModelHistory_setCreatedDate  );
  tcase_add_test( tcase, test_ModelHistory_setModifiedDate  );
  tcase_add_test( tcase, test_ModelHistory_addModifiedDate  );
  tcase_add_test( tcase, test_ModelHistory_accessWithNULL   );
  suite_add_tcase(suite, tcase);

  return suite;
}


#if defined(__cplusplus)
CK_CPPEND
#endif
