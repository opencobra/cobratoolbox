/**
 * @file    TestSBMLError.cpp
 * @brief   SBMLError unit tests, C++ version
 * @author  Sarah Keating
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

#if defined(WIN32) && !defined(CYGWIN)

#include <iostream>

#endif


#include <limits>

#include <check.h>
#include <SBMLError.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


CK_CPPSTART



START_TEST (test_SBMLError_create)
{
  SBMLError* error = new SBMLError;
  fail_unless( error != NULL );
  delete error;

  error = new SBMLError(EmptyListInReaction);
  fail_unless( error->getErrorId()  == EmptyListInReaction );
  fail_unless( error->getSeverity() == LIBSBML_SEV_ERROR );
  fail_unless( error->getSeverityAsString() == "Error" );
  fail_unless( error->getCategory() == LIBSBML_CAT_SBML );
  fail_unless( error->getCategoryAsString() == "General SBML conformance");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(OverdeterminedSystem, 2, 1);
  fail_unless( error->getErrorId()  == OverdeterminedSystem );
  fail_unless( error->getSeverity() == LIBSBML_SEV_WARNING );
  fail_unless( error->getSeverityAsString() == "Warning" );
  fail_unless( error->getCategory() == LIBSBML_CAT_OVERDETERMINED_MODEL );
  fail_unless( error->getCategoryAsString() == "Overdetermined model");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(OffsetNoLongerValid, 2, 2);
  fail_unless( error->getErrorId()  == OffsetNoLongerValid );
  fail_unless( error->getSeverity() == LIBSBML_SEV_ERROR );
  fail_unless( error->getSeverityAsString() == "Error" );
  fail_unless( error->getCategory() == LIBSBML_CAT_GENERAL_CONSISTENCY );
  fail_unless( error->getCategoryAsString() == "SBML component consistency");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(NoSBOTermsInL1, 2, 2);
  fail_unless( error->getErrorId()  == NoSBOTermsInL1 );
  fail_unless( error->getSeverity() == LIBSBML_SEV_WARNING );
  fail_unless( error->getSeverityAsString() == "Warning" );
  fail_unless( error->getCategory() == LIBSBML_CAT_SBML_L1_COMPAT );
  fail_unless( error->getCategoryAsString() == "Translation to SBML L1V2");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(DisallowedMathMLEncodingUse, 2, 2);
  fail_unless( error->getErrorId()  == DisallowedMathMLEncodingUse );
  fail_unless( error->getSeverity() == LIBSBML_SEV_ERROR );
  fail_unless( error->getSeverityAsString() == "Error" );
  fail_unless( error->getCategory() == LIBSBML_CAT_MATHML_CONSISTENCY );
  fail_unless( error->getShortMessage() == "Use of the MathML 'encoding' attribute is not allowed on this element");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(DisallowedMathMLEncodingUse, 1, 2);
  fail_unless( error->getErrorId()  == DisallowedMathMLEncodingUse );
  fail_unless( error->getSeverity() == LIBSBML_SEV_NOT_APPLICABLE );
  fail_unless( error->getCategory() == LIBSBML_CAT_MATHML_CONSISTENCY );
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(UnknownError, 2, 4);
  fail_unless( error->getErrorId()  == UnknownError );
  fail_unless( error->getSeverity() == LIBSBML_SEV_FATAL );
  fail_unless( error->getSeverityAsString() == "Fatal" );
  fail_unless( error->getCategory() == LIBSBML_CAT_INTERNAL );
  fail_unless( error->getShortMessage() == "Encountered unknown internal libSBML error");
  fail_unless( error->isValid() == true);
  delete error;

  error = new SBMLError(70912, 2, 4);
  fail_unless( error->getErrorId()  == 70912 );
  fail_unless( error->getSeverity() == LIBSBML_SEV_WARNING );
  fail_unless( error->getSeverityAsString() == "Warning" );
  fail_unless( error->getCategory() == LIBSBML_CAT_INTERNAL );
  fail_unless( error->getShortMessage() == "Encountered unknown internal libSBML error");
  fail_unless( error->isValid() == false);
  delete error;
}
END_TEST


Suite *
create_suite_SBMLError (void)
{
  Suite *suite = suite_create("SBMLError");
  TCase *tcase = tcase_create("SBMLError");

  tcase_add_test( tcase, test_SBMLError_create  );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

