/**
 * @file    TestXMLError.cpp
 * @brief   XMLError unit tests, C++ version
 * @author  Michael Hucka
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
#include <XMLError.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


CK_CPPSTART



START_TEST (test_XMLError_create)
{
  XMLError* error = new XMLError;
  fail_unless( error != NULL );
  delete error;

  error = new XMLError(DuplicateXMLAttribute);
  fail_unless( error->getErrorId()  == DuplicateXMLAttribute );
  fail_unless( error->getSeverity() == LIBSBML_SEV_ERROR );
  fail_unless( error->getSeverityAsString() == "Error" );
  fail_unless( error->getCategory() == LIBSBML_CAT_XML );
  fail_unless( error->getCategoryAsString() == "XML content");
  fail_unless( error->getMessage()  == "Duplicate XML attribute." );
  fail_unless( error->getShortMessage()  == "Duplicate attribute" );
  delete error;

  error = new XMLError(12345, "My message");
  fail_unless( error->getErrorId()  == 12345 );
  fail_unless( error->getMessage()  == "My message" );
  fail_unless( error->getSeverity() == LIBSBML_SEV_FATAL );
  fail_unless( error->getSeverityAsString() == "Fatal" );
  fail_unless( error->getCategory() == LIBSBML_CAT_INTERNAL );
  fail_unless( error->getCategoryAsString() == "Internal");
  delete error;

  error = new XMLError(12345, "My message", 0, 0,
                       LIBSBML_SEV_INFO, LIBSBML_CAT_SYSTEM);
  fail_unless( error->getErrorId()  == 12345 );
  fail_unless( error->getMessage()  == "My message" );
  fail_unless( error->getSeverity() == LIBSBML_SEV_INFO );
  fail_unless( error->getSeverityAsString() == "Informational" );
  fail_unless( error->getCategory() == LIBSBML_CAT_SYSTEM );
  fail_unless( error->getCategoryAsString() == "Operating system");
  fail_unless( error->isInfo() );
  fail_unless( error->isSystem() );
  delete error;

  error = new XMLError(10000, "Another message", 0, 0,
                       LIBSBML_SEV_FATAL, LIBSBML_CAT_XML);
  fail_unless( error->getErrorId()  == 10000 );
  fail_unless( error->getMessage()  == "Another message" );
  fail_unless( error->getSeverity() == LIBSBML_SEV_FATAL );
  fail_unless( error->getSeverityAsString() == "Fatal" );
  fail_unless( error->getCategory() == LIBSBML_CAT_XML );
  fail_unless( error->getCategoryAsString() == "XML content");
  fail_unless( error->isFatal() );
  fail_unless( error->isXML() );
  delete error;
}
END_TEST


START_TEST (test_XMLError_setters)
{
  XMLError* error = new XMLError;
  fail_unless( error != NULL );

  int i = error->setLine(23);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( error->getLine() == 23);

  i = error->setColumn(45);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( error->getColumn() == 45);

  delete error;
}
END_TEST


Suite *
create_suite_XMLError (void)
{
  Suite *suite = suite_create("XMLError");
  TCase *tcase = tcase_create("XMLError");

  tcase_add_test( tcase, test_XMLError_create  );
  tcase_add_test( tcase, test_XMLError_setters  );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

