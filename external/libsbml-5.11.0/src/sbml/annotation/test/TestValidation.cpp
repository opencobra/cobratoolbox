/**
 * \file    TestValidation.cpp
 * \brief   Validation of Date ModelCreator and ModelHistory unit tests
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/annotation/RDFAnnotation.h>
#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>
#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART

START_TEST (test_Validation_Date1)
{
  Date * date = new Date(200, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  fail_unless (!(date->representsValidDate()));

  delete date;
}
END_TEST


START_TEST (test_Validation_Date2)
{
  Date * date = new Date(2007, 14, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  fail_unless (!(date->representsValidDate()));

  delete date;
}
END_TEST


START_TEST (test_Validation_Date3)
{
  Date * date = new Date("Jan 12");
  fail_unless(date != NULL);

  fail_unless (!(date->representsValidDate()));

  delete date;
}
END_TEST


START_TEST (test_Validation_Date4)
{
  Date * date = new Date(2007, 12, 30, 12, 15, 45, 1, 2, 0);
  fail_unless(date != NULL);

  fail_unless (date->representsValidDate());

  delete date;
}
END_TEST


START_TEST (test_Validation_ModelCreator)
{
  ModelCreator * mc = new ModelCreator();
  fail_unless(mc != NULL);

  fail_unless (!(mc->hasRequiredAttributes()));

  mc->setEmail("k123");

  fail_unless (!(mc->hasRequiredAttributes()));

  mc->setFamilyName("Keating");

  fail_unless (!(mc->hasRequiredAttributes()));

  mc->setGivenName("Sarah");

  fail_unless (mc->hasRequiredAttributes());
  
  delete mc;
}
END_TEST


START_TEST (test_Validation_ModelHistory1)
{
  ModelHistory * mh = new ModelHistory();
  fail_unless(mh != NULL);

  fail_unless (!(mh->hasRequiredAttributes()));

  Date * date = new Date(2007, 12, 30, 12, 15, 45, 1, 2, 0);
  mh->setCreatedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  mh->setModifiedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setGivenName("Sarah");

  mh->addCreator(mc);

  fail_unless (mh->hasRequiredAttributes());
  
  delete mh;
  delete mc;
  delete date;
}
END_TEST


START_TEST (test_Validation_ModelHistory2)
{
  ModelHistory * mh = new ModelHistory();
  fail_unless(mh != NULL);

  fail_unless (!(mh->hasRequiredAttributes()));

  Date * date = new Date(200, 12, 30, 12, 15, 45, 1, 2, 0);
  mh->setCreatedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  mh->setModifiedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setGivenName("Sarah");

  mh->addCreator(mc);

  fail_unless (!(mh->hasRequiredAttributes()));
  
  delete mh;
  delete mc;
  delete date;
}
END_TEST


START_TEST (test_Validation_ModelHistory3)
{
  ModelHistory * mh = new ModelHistory();
  fail_unless(mh != NULL);

  fail_unless (!(mh->hasRequiredAttributes()));

  Date * date = new Date(2007, 12, 30, 12, 15, 45, 1, 2, 0);
  mh->setCreatedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  mh->setModifiedDate(date);

  fail_unless (!(mh->hasRequiredAttributes()));

  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");

  mh->addCreator(mc);

  fail_unless (!(mh->hasRequiredAttributes()));
  
  delete mh;
  delete mc;
  delete date;
}
END_TEST


START_TEST (test_Validation_CVTerm1)
{
  CVTerm * cv = new CVTerm();
  fail_unless(cv != NULL);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->setQualifierType(MODEL_QUALIFIER);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->setModelQualifierType(BQM_IS);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->addResource("ggg");

  fail_unless ((cv->hasRequiredAttributes()));
  
  delete cv;
}
END_TEST


START_TEST (test_Validation_CVTerm2)
{
  CVTerm * cv = new CVTerm();
  fail_unless(cv != NULL);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->setQualifierType(BIOLOGICAL_QUALIFIER);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->setBiologicalQualifierType(BQB_IS);

  fail_unless (!(cv->hasRequiredAttributes()));

  cv->addResource("ggg");

  fail_unless ((cv->hasRequiredAttributes()));
  
  delete cv;
}
END_TEST

START_TEST (test_Validation_Date_Default)
{
  Date *date1 = new Date();
  Date *date2 = new Date("");

  fail_unless (date1->getYear()          == date2->getYear()          );
  fail_unless (date1->getMonth()         == date2->getMonth()         );
  fail_unless (date1->getDay()           == date2->getDay()           );
  fail_unless (date1->getHour()          == date2->getHour()          );
  fail_unless (date1->getMinute()        == date2->getMinute()        );
  fail_unless (date1->getSecond()        == date2->getSecond()        );
  fail_unless (date1->getSignOffset()    == date2->getSignOffset()    );
  fail_unless (date1->getHoursOffset()   == date2->getHoursOffset()   );
  fail_unless (date1->getMinutesOffset() == date2->getMinutesOffset() );
  
  delete date1;
  delete date2;
  
}
END_TEST
  

Suite *
create_suite_Validation (void)
{
  Suite *suite = suite_create("Validation");
  TCase *tcase = tcase_create("Validation");

  tcase_add_test(tcase, test_Validation_Date1         );
  tcase_add_test(tcase, test_Validation_Date2         );
  tcase_add_test(tcase, test_Validation_Date3         );
  tcase_add_test(tcase, test_Validation_Date4         );
  tcase_add_test(tcase, test_Validation_Date_Default  );
  tcase_add_test(tcase, test_Validation_ModelCreator  );
  tcase_add_test(tcase, test_Validation_ModelHistory1 );
  tcase_add_test(tcase, test_Validation_ModelHistory2 );
  tcase_add_test(tcase, test_Validation_ModelHistory3 );
  tcase_add_test(tcase, test_Validation_CVTerm1       );
  tcase_add_test(tcase, test_Validation_CVTerm2       );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

