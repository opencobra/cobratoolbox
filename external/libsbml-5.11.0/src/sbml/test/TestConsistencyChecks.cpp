/**
 * \file    TestConsistencyChecks.cpp
 * \brief   Reads test-data/inconsistent.xml into memory and tests it.
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_consistency_checks)
{
  SBMLReader        reader;
  SBMLDocument*     d;
  unsigned int errors;
  std::string filename(TestDataDirectory);
  filename += "inconsistent.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"inconsistent.xml\") returned a NULL pointer.");
  }

  errors = d->checkConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10301);

  d->getErrorLog()->clearLog();
  d->setConsistencyChecks(LIBSBML_CAT_IDENTIFIER_CONSISTENCY, false);
  errors = d->checkConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 10214);
  fail_unless(d->getError(1)->getErrorId() == 20612);

  d->getErrorLog()->clearLog();
  d->setConsistencyChecks(LIBSBML_CAT_GENERAL_CONSISTENCY, false);
  errors = d->checkConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10701);

  d->getErrorLog()->clearLog();
  d->setConsistencyChecks(LIBSBML_CAT_SBO_CONSISTENCY, false);
  errors = d->checkConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10214);

  d->getErrorLog()->clearLog();
  d->setConsistencyChecks(LIBSBML_CAT_MATHML_CONSISTENCY, false);
  errors = d->checkConsistency();

  fail_unless(errors == 3);
  fail_unless(d->getError(0)->getErrorId() == 99505);
  fail_unless(d->getError(1)->getErrorId() == 99505);
  fail_unless(d->getError(2)->getErrorId() == 80701);

  d->getErrorLog()->clearLog();
  d->setConsistencyChecks(LIBSBML_CAT_UNITS_CONSISTENCY, false);
  errors = d->checkConsistency();

  fail_unless(errors == 0);


  delete d;
}
END_TEST


Suite *
create_suite_TestConsistencyChecks (void)
{ 
  Suite *suite = suite_create("ConsistencyChecks");
  TCase *tcase = tcase_create("ConsistencyChecks");


  tcase_add_test(tcase, test_consistency_checks);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

