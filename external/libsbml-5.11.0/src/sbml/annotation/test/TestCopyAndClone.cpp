/**
 * \file    TestCopyAndClone.cpp
 * \brief   Test the copy and clone methods for annotation classes
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

#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>
#include <sbml/annotation/CVTerm.h>
#include <sbml/SBase.h>

#include <check.h>


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

static const string errMsg = "Level/version/namespaces combination is invalid";
static const string errMsg1 = "Null argument to copy constructor";
static const string errMsg2 = "Null argument to assignment operator";

CK_CPPSTART
START_TEST ( test_Date_copyConstructor )
{
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
    
  fail_unless(date->getMonth() == 12);
  fail_unless(date->getSecond() == 45);

  Date* date2=new Date(*date);

  fail_unless(date2->getMonth() == 12);
  fail_unless(date2->getSecond() == 45);

  delete date2;
  delete date;
}
END_TEST

START_TEST ( test_Date_assignmentOperator )
{
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
    
  fail_unless(date->getMonth() == 12);
  fail_unless(date->getSecond() == 45);

  Date* date2=new Date();
  (*date2) = *date;

  fail_unless(date2->getMonth() == 12);
  fail_unless(date2->getSecond() == 45);

  delete date2;
  delete date;
    
}
END_TEST


START_TEST ( test_Date_clone )
{
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
    
  fail_unless(date->getMonth() == 12);
  fail_unless(date->getSecond() == 45);

  Date* date2 = static_cast<Date*>(date->clone());

  fail_unless(date2->getMonth() == 12);
  fail_unless(date2->getSecond() == 45);

  delete date2;
  delete date;

}
END_TEST


START_TEST ( test_Date_ConstructorException )
{
  string msg;
  try 
  {
    Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
    delete date;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  Date *date1 = NULL;
  msg = "";
  try
  {
    Date* date2=new Date(*date1);
    (void) date2;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  Date *date2 = new Date();
  try
  {
    (*date2) = *date1;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
  delete date2;
}
END_TEST


START_TEST ( test_ModelCreator_copyConstructor )
{
  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setEmail("sbml-team@caltech.edu");
    
  fail_unless(mc->getFamilyName() == "Keating");
  fail_unless(mc->getEmail() == "sbml-team@caltech.edu");

  ModelCreator* mc2=new ModelCreator(*mc);

  fail_unless(mc2->getFamilyName() == "Keating");
  fail_unless(mc2->getEmail() == "sbml-team@caltech.edu");

  delete mc2;
  delete mc;
}
END_TEST


START_TEST ( test_ModelCreator_assignmentOperator )
{
  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setEmail("sbml-team@caltech.edu");
    
  fail_unless(mc->getFamilyName() == "Keating");
  fail_unless(mc->getEmail() == "sbml-team@caltech.edu");

  ModelCreator* mc2=new ModelCreator();
  (*mc2) = *mc;

  fail_unless(mc2->getFamilyName() == "Keating");
  fail_unless(mc2->getEmail() == "sbml-team@caltech.edu");

  delete mc2;
  delete mc;
    
}
END_TEST


START_TEST ( test_ModelCreator_clone )
{
  ModelCreator * mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setEmail("sbml-team@caltech.edu");
    
  fail_unless(mc->getFamilyName() == "Keating");
  fail_unless(mc->getEmail() == "sbml-team@caltech.edu");

  ModelCreator* mc2 = static_cast<ModelCreator*>(mc->clone());

  fail_unless(mc2->getFamilyName() == "Keating");
  fail_unless(mc2->getEmail() == "sbml-team@caltech.edu");

  delete mc2;
  delete mc;

}
END_TEST


START_TEST ( test_ModelCreator_ConstructorException )
{
  string msg;
  try 
  {
    ModelCreator * mc = new ModelCreator();
    delete mc;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  ModelCreator *mc1 = NULL;
  msg = "";
  try
  {
    ModelCreator* mc2=new ModelCreator(*mc1);
    (void) mc2;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  ModelCreator *mc2 = new ModelCreator();
  try
  {
    (*mc2) = *mc1;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
  delete mc2;
}
END_TEST


START_TEST ( test_ModelHistory_copyConstructor )
{
  ModelHistory * mh = new ModelHistory();
  
  ModelCreator *mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setGivenName("Sarah");
  mc->setEmail("sbml-team@caltech.edu");

  mh->addCreator(mc);
  delete mc;
    
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  mh->setCreatedDate(date);
  delete date;

  fail_unless(mh->getCreatedDate()->getMonth() == 12);
  fail_unless(mh->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>
    (mh->getListCreators()->get(0))->getFamilyName() == "Keating");

  ModelHistory* mh2=new ModelHistory(*mh);

  fail_unless(mh2->getCreatedDate()->getMonth() == 12);
  fail_unless(mh2->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>(mh2->getListCreators()->get(0))->getFamilyName() == "Keating");

  delete mh2;
  delete mh;
}
END_TEST


START_TEST ( test_ModelHistory_assignmentOperator )
{
  ModelHistory * mh = new ModelHistory();
  
  ModelCreator *mc = new ModelCreator();
  mc->setGivenName("Sarah");
  mc->setFamilyName("Keating");
  mc->setEmail("sbml-team@caltech.edu");

  mh->addCreator(mc);
  delete mc;
    
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  mh->setCreatedDate(date);
  delete date;

  fail_unless(mh->getCreatedDate()->getMonth() == 12);
  fail_unless(mh->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>(mh->getListCreators()->get(0))->getFamilyName() == "Keating");

  ModelHistory* mh2=new ModelHistory();
  (*mh2) = *mh;

  fail_unless(mh2->getCreatedDate()->getMonth() == 12);
  fail_unless(mh2->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>(mh2->getListCreators()->get(0))->getFamilyName() == "Keating");

  delete mh2;
  delete mh;
    
}
END_TEST


START_TEST ( test_ModelHistory_clone )
{
  ModelHistory * mh = new ModelHistory();
  
  ModelCreator *mc = new ModelCreator();
  mc->setFamilyName("Keating");
  mc->setGivenName("Sarah");
  mc->setEmail("sbml-team@caltech.edu");

  mh->addCreator(mc);
  delete mc;
    
  Date * date = new Date(2005, 12, 30, 12, 15, 45, 1, 2, 0);
  
  mh->setCreatedDate(date);
  delete date;

  fail_unless(mh->getCreatedDate()->getMonth() == 12);
  fail_unless(mh->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>(mh->getListCreators()->get(0))->getFamilyName() == "Keating");

  ModelHistory* mh2 = static_cast<ModelHistory*>(mh->clone());

  fail_unless(mh2->getCreatedDate()->getMonth() == 12);
  fail_unless(mh2->getCreatedDate()->getSecond() == 45);

  fail_unless(static_cast <ModelCreator*>(mh2->getListCreators()->get(0))->getFamilyName() == "Keating");

  delete mh2;
  delete mh;

}
END_TEST


START_TEST ( test_ModelHistory_ConstructorException )
{
  string msg;
  try 
  {
    ModelHistory * mh = new ModelHistory();
    delete mh;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  ModelHistory *mh1 = NULL;
  msg = "";
  try
  {
    ModelHistory* mh2=new ModelHistory(*mh1);
    (void) mh2;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  ModelHistory *mh2 = new ModelHistory();
  try
  {
    (*mh2) = *mh1;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
  delete mh2;
}
END_TEST


START_TEST ( test_CVTerm_copyConstructor )
{

  CVTerm * CVTerm1 = new CVTerm(BIOLOGICAL_QUALIFIER);
  CVTerm1->addResource("http://www.geneontology.org/#GO:0005892");
    
  fail_unless(CVTerm1->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm1->getResources()->getLength() == 1);
  fail_unless(CVTerm1->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");

  CVTerm* CVTerm2=new CVTerm(*CVTerm1);

  fail_unless(CVTerm2->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm2->getResources()->getLength() == 1);
  fail_unless(CVTerm2->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");

  delete CVTerm2;
  delete CVTerm1;
}
END_TEST


START_TEST ( test_CVTerm_assignmentOperator )
{
  CVTerm * CVTerm1 = new CVTerm(BIOLOGICAL_QUALIFIER);
  CVTerm1->addResource("http://www.geneontology.org/#GO:0005892");
    
  fail_unless(CVTerm1->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm1->getResources()->getLength() == 1);
  fail_unless(CVTerm1->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");


  CVTerm* CVTerm2=new CVTerm();
  (*CVTerm2) = *CVTerm1;

  fail_unless(CVTerm2->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm2->getResources()->getLength() == 1);
  fail_unless(CVTerm2->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");

  delete CVTerm2;
  delete CVTerm1;
}
END_TEST


START_TEST ( test_CVTerm_clone )
{
  CVTerm * CVTerm1 = new CVTerm(BIOLOGICAL_QUALIFIER);
  CVTerm1->addResource("http://www.geneontology.org/#GO:0005892");
    
  fail_unless(CVTerm1->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm1->getResources()->getLength() == 1);
  fail_unless(CVTerm1->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");


  CVTerm* CVTerm2 = static_cast<CVTerm*>(CVTerm1->clone());

  fail_unless(CVTerm2->getQualifierType() == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm2->getResources()->getLength() == 1);
  fail_unless(CVTerm2->getResources()->getValue(0) == "http://www.geneontology.org/#GO:0005892");

  delete CVTerm2;
  delete CVTerm1;
}
END_TEST


START_TEST ( test_CVTerm_ConstructorException )
{
  string msg;
  try 
  {
    CVTerm * cvterm = new CVTerm(BIOLOGICAL_QUALIFIER);
    delete cvterm;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  CVTerm *cvterm1 = NULL;
  msg = "";
  try
  {
    CVTerm* cvterm2=new CVTerm(*cvterm1);
    (void) cvterm2;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);

  msg = "";
  CVTerm *cvterm2 = new CVTerm(BIOLOGICAL_QUALIFIER);
  try
  {
    (*cvterm2) = *cvterm1;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
  delete cvterm2;
}
END_TEST


Suite *
create_suite_CopyAndClone (void)
{
  Suite *suite = suite_create("CopyAndClone");
  TCase *tcase = tcase_create("CopyAndClone");

  tcase_add_test( tcase, test_Date_copyConstructor );
  tcase_add_test( tcase, test_Date_assignmentOperator );
  tcase_add_test( tcase, test_Date_clone );
  tcase_add_test( tcase, test_Date_ConstructorException );
  tcase_add_test( tcase, test_ModelCreator_copyConstructor );
  tcase_add_test( tcase, test_ModelCreator_assignmentOperator );
  tcase_add_test( tcase, test_ModelCreator_clone );
  tcase_add_test( tcase, test_ModelCreator_ConstructorException );
  tcase_add_test( tcase, test_ModelHistory_copyConstructor );
  tcase_add_test( tcase, test_ModelHistory_assignmentOperator );
  tcase_add_test( tcase, test_ModelHistory_clone );
  tcase_add_test( tcase, test_ModelHistory_ConstructorException );
  tcase_add_test( tcase, test_CVTerm_copyConstructor );
  tcase_add_test( tcase, test_CVTerm_assignmentOperator );
  tcase_add_test( tcase, test_CVTerm_clone );
  tcase_add_test( tcase, test_CVTerm_ConstructorException );
  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND

