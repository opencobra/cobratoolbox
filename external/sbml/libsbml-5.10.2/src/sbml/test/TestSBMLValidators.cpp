/**
 * @file    TestSBMLValidators.cpp
 * @brief   unit tests for SBMLValidator, SBMLInternalValidator and SBMLExternalValidator
 * @author  Frank Bergmann
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

#include <sbml/SBMLError.h>
#include <sbml/validator/SBMLValidator.h>
#include <sbml/validator/SBMLInternalValidator.h>
#include <sbml/validator/SBMLExternalValidator.h>

#include <check.h>

#include <iostream>
#include <list>


LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS



extern char *TestDataDirectory;


START_TEST (test_SBMLValidators_create)
{

  SBMLValidator validator;
  
  // test NULL document
  validator.setDocument(NULL);
  fail_unless(validator.getDocument() == NULL);
  fail_unless(validator.getModel() == NULL);
  fail_unless(validator.getErrorLog() == NULL);
  fail_unless(validator.getFailures().size() == 0);
  
  validator.logFailure(SBMLError());
  fail_unless(validator.getFailures().size() == 1);
  validator.clearFailures();



  // test doc
  SBMLDocument doc; 
  doc.createModel();
  validator.setDocument(&doc);
  fail_unless(validator.getDocument() != NULL);
  fail_unless(validator.getModel() != NULL);
  fail_unless(validator.getErrorLog() != NULL);
  fail_unless(validator.getFailures().size() == 0);

  // validator base class always returns 0 errors
  fail_unless(validator.validate() == 0);
  
}
END_TEST

  
START_TEST (test_SBMLValidators_internal)
{
  SBMLInternalValidator validator;
  
  // test NULL document
  validator.setDocument(NULL);
  fail_unless(validator.getDocument() == NULL);
  fail_unless(validator.getModel() == NULL);
  fail_unless(validator.getErrorLog() == NULL);
  fail_unless(validator.getFailures().size() == 0);

  validator.logFailure(SBMLError());
  fail_unless(validator.getFailures().size() == 1);
  validator.clearFailures();



  // test doc
  SBMLDocument doc; 
  doc.createModel();
  validator.setDocument(&doc);
  fail_unless(validator.getDocument() != NULL);
  fail_unless(validator.getModel() != NULL);
  fail_unless(validator.getErrorLog() != NULL);
  fail_unless(validator.getFailures().size() == 0);

  // validator base class always returns 0 errors
  fail_unless(validator.validate() == 0);

  // the remaining methods of internal validator are tested through the calls on 
  // SBML Document
  
  
}
END_TEST



Suite *
create_suite_SBMLValidatorAPI(void)
{
  Suite *suite = suite_create("SBMLValidator API");
  TCase *tcase = tcase_create("SBMLValidator API");

  tcase_add_test(tcase, test_SBMLValidators_create);
  tcase_add_test(tcase, test_SBMLValidators_internal);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
