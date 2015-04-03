/**
 * \file    TestDate_newSetters.cpp
 * \brief   Date unit tests
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

START_TEST (test_Date_setYear)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setYear(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getYear(date) == 2000);

  i = Date_setYear(date, 12121);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getYear(date) == 2000);

  i = Date_setYear(date, 2008);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getYear(date) == 2008);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2008-12-30T12:15:45+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setMonth)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setMonth(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMonth(date) == 1);

  i = Date_setMonth(date, 12121);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMonth(date) == 1);

  i = Date_setMonth(date, 11);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getMonth(date) == 11);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-11-30T12:15:45+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setDay)
{
  Date_t * date = Date_createFromValues(2005, 2, 12, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setDay(date, 29);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getDay(date) == 1);

  i = Date_setDay(date, 31);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getDay(date) == 1);

  i = Date_setDay(date, 15);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getDay(date) == 15);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-02-15T12:15:45+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setHour)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setHour(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getHour(date) == 0);

  i = Date_setHour(date, 12121);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getHour(date) == 0);

  i = Date_setHour(date, 9);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getHour(date) == 9);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T09:15:45+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setMinute)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setMinute(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMinute(date) == 0);

  i = Date_setMinute(date, 12121);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMinute(date) == 0);

  i = Date_setMinute(date, 32);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getMinute(date) == 32);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T12:32:45+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setSecond)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setSecond(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getSecond(date) == 0);

  i = Date_setSecond(date, 12121);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getSecond(date) == 0);

  i = Date_setSecond(date, 32);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getSecond(date) == 32);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T12:15:32+02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setOffsetSign)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setSignOffset(date, 2);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getSignOffset(date) == 0);

  i = Date_setSignOffset(date, -4);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getSignOffset(date) == 0);

  i = Date_setSignOffset(date, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getSignOffset(date) == 0);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T12:15:45-02:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setHoursOffset)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setHoursOffset(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getHoursOffset(date) == 0);

  i = Date_setHoursOffset(date, 11);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getHoursOffset(date) == 11);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T12:15:45+11:00"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setHoursOffset_neg_arg)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setHoursOffset(date, -3);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getHoursOffset(date) == 0);

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setMinutesOffset)
{
  Date_t * date = Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  int i = Date_setMinutesOffset(date, 434);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMinutesOffset(date) == 0);

  i = Date_setMinutesOffset(date, 60);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Date_getMinutesOffset(date) == 0);

  i = Date_setMinutesOffset(date, 45);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getMinutesOffset(date) == 45);

  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2005-12-30T12:15:45+02:45"));

  Date_free(date);
}
END_TEST


START_TEST (test_Date_setDateAsString)
{
  Date_t * date = Date_createFromValues(2007, 10, 23, 14, 15, 16, 1, 3, 0);
  fail_unless(date != NULL);

  int i = Date_setDateAsString(date, "20081-12-30T12:15:45+02:00");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless(!strcmp(Date_getDateAsString(date), 
                               "2007-10-23T14:15:16+03:00"));

  i = Date_setDateAsString(date, "200-12-30T12:15:45+02:00");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless(!strcmp(Date_getDateAsString(date), 
                               "2007-10-23T14:15:16+03:00"));

  i = Date_setDateAsString(date, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless(!strcmp(Date_getDateAsString(date), 
                           "2000-01-01T00:00:00Z"));

  i = Date_setDateAsString(date, "2008-12-30T12:15:45+02:00");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Date_getYear(date) == 2008);
  fail_unless( Date_getMonth(date) == 12);
  fail_unless( Date_getDay(date) == 30);
  fail_unless( Date_getHour(date) == 12);
  fail_unless( Date_getMinute(date) == 15);
  fail_unless( Date_getSecond(date) == 45);
  fail_unless( Date_getSignOffset(date) == 1);
  fail_unless( Date_getHoursOffset(date) == 2);
  fail_unless( Date_getMinutesOffset(date) == 0);


  Date_free(date);
}
END_TEST

START_TEST (test_Date_accessWithNULL)
{
	fail_unless( Date_clone(NULL) == NULL );
	fail_unless( Date_createFromString(NULL) == NULL );
	
	// ensure that we don't crash
    Date_free(NULL);
	
	fail_unless( Date_getDateAsString(NULL) == NULL );
	fail_unless( Date_getDay(NULL) == SBML_INT_MAX );
	fail_unless( Date_getHour(NULL) == SBML_INT_MAX );
	fail_unless( Date_getHoursOffset(NULL) == SBML_INT_MAX );
	fail_unless( Date_getMinute(NULL) == SBML_INT_MAX );
	fail_unless( Date_getMinutesOffset(NULL) == SBML_INT_MAX );
	fail_unless( Date_getMonth(NULL) == SBML_INT_MAX );
	fail_unless( Date_getSecond(NULL) == SBML_INT_MAX );
	fail_unless( Date_getSignOffset(NULL) == SBML_INT_MAX );
	fail_unless( Date_getYear(NULL) == SBML_INT_MAX );
	fail_unless( Date_representsValidDate(NULL) == 0 );
	fail_unless( Date_setDateAsString(NULL, NULL) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setDay(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setHour(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setHoursOffset(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setMinute(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setMinutesOffset(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setMonth(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setSecond(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setSignOffset(NULL, 0) == LIBSBML_INVALID_OBJECT );
	fail_unless( Date_setYear(NULL, 0) == LIBSBML_INVALID_OBJECT );

}
END_TEST

Suite *
create_suite_Date_newSetters (void)
{
  Suite *suite = suite_create("Date_newSetters");
  TCase *tcase = tcase_create("Date_newSetters");


  tcase_add_test( tcase, test_Date_setYear                );
  tcase_add_test( tcase, test_Date_setMonth               );
  tcase_add_test( tcase, test_Date_setDay                 );
  tcase_add_test( tcase, test_Date_setHour                );
  tcase_add_test( tcase, test_Date_setMinute              );
  tcase_add_test( tcase, test_Date_setSecond              );
  tcase_add_test( tcase, test_Date_setOffsetSign          );
  tcase_add_test( tcase, test_Date_setHoursOffset         );
  tcase_add_test( tcase, test_Date_setHoursOffset_neg_arg );
  tcase_add_test( tcase, test_Date_setMinutesOffset       );
  tcase_add_test( tcase, test_Date_setDateAsString        );
  tcase_add_test( tcase, test_Date_accessWithNULL         );

  suite_add_tcase(suite, tcase);

  return suite;
}


#if defined(__cplusplus)
CK_CPPEND
#endif

