/**
 * \file    TestXMLInputStream.c
 * \brief   XMLInputStream unit tests
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
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLErrorLog.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

/**
 * Wraps the string s in the appropriate XML boilerplate.
 */
#define XML_START   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define SBML_START  "<sbml "
#define NS_L1       "xmlns=\"http://www.sbml.org/sbml/level1\" "
#define NS_L2v1     "xmlns=\"http://www.sbml.org/sbml/level2\" "
#define NS_L2v2     "xmlns=\"http://www.sbml.org/sbml/level2/version2\" "
#define LV_L1v1     "level=\"1\" version=\"1\">\n"
#define LV_L1v2     "level=\"1\" version=\"2\">\n"
#define LV_L2v1     "level=\"2\" version=\"1\">\n"
#define LV_L2v2     "level=\"2\" version=\"2\">\n"
#define SBML_END    "</sbml>\n"

#define wrapXML(s)        XML_START s
#define wrapSBML_L1v1(s)  XML_START SBML_START NS_L1   LV_L1v1 s SBML_END
#define wrapSBML_L1v2(s)  XML_START SBML_START NS_L1   LV_L1v2 s SBML_END
#define wrapSBML_L2v1(s)  XML_START SBML_START NS_L2v1 LV_L2v1 s SBML_END
#define wrapSBML_L2v2(s)  XML_START SBML_START NS_L2v2 LV_L2v2 s SBML_END


START_TEST (test_XMLInputStream_create)
{
  const char* text = wrapSBML_L2v1("  <model id=\"Branch\"/>\n");

  XMLInputStream_t * stream = XMLInputStream_create(text, 0, "");

  fail_unless(stream != NULL);
  fail_unless(XMLInputStream_isEOF(stream) == 0);
  fail_unless(XMLInputStream_isGood(stream) == 1);
  fail_unless(XMLInputStream_isError(stream) == 0);

  XMLInputStream_next(stream);
  fail_unless(strcmp(XMLInputStream_getEncoding(stream), "UTF-8") == 0);

  XMLInputStream_free(stream);

}
END_TEST


START_TEST (test_XMLInputStream_next_peek)
{
  const char* text = 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<sbml "
    "xmlns=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\">\n"
    "  <model id=\"Branch\"/>\n"
    "</sbml>";

  XMLInputStream_t *stream = XMLInputStream_create(text, 0, "");;
  const XMLToken_t  *next0 = XMLInputStream_peek(stream);
  
  fail_unless(stream != NULL);
  
  fail_unless(strcmp(XMLToken_getName(next0), "sbml") == 0);
  
  XMLToken_t * next1 = XMLInputStream_next(stream);
  
  fail_unless(strcmp(XMLToken_getName(next1), "sbml") == 0);
 
  XMLInputStream_free(stream);

}
END_TEST


START_TEST (test_XMLInputStream_skip)
{
  const char* text = 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<sbml "
    "xmlns=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\">\n"
    "<listOfFunctionDefinitions>\n"
    "<notes>My Functions</notes>\n"
    "<functionDefinition/>\n"
    "</listOfFunctionDefinitions>\n"
    "<listOfUnitDefinitions>\n"
    "<notes>My Units</notes>\n"
    "<unitDefinition/>\n"
    "</listOfUnitDefinitions>\n"
    "</sbml>";

        
  XMLInputStream_t *stream = XMLInputStream_create(text, 0, "");;

  fail_unless(stream != NULL);
  
  XMLToken_t * next0 = XMLInputStream_next(stream);
  XMLInputStream_skipText (stream);

  /* skip past listOfFunctionDefinitions */
  XMLInputStream_skipPastEnd(stream, XMLInputStream_next(stream)); 
  XMLInputStream_skipText (stream);

  next0= XMLInputStream_next(stream);

  fail_unless(strcmp(XMLToken_getName(next0), "listOfUnitDefinitions") == 0);
 
  XMLInputStream_free(stream);

}
END_TEST


START_TEST (test_XMLInputStream_setErrorLog)
{
  const char* text = 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "<sbml "
    "xmlns=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\">\n"
    "<listOfFunctionDefinitions>\n"
    "<notes>My Functions</notes>\n"
    "<functionDefinition/>\n"
    "</listOfFunctionDefinitions>\n"
    "<listOfUnitDefinitions>\n"
    "<notes>My Units</notes>\n"
    "<unitDefinition/>\n"
    "</listOfUnitDefinitions>\n"
    "</sbml>";

        
  XMLInputStream_t *stream = XMLInputStream_create(text, 0, "");;

  fail_unless(stream != NULL);

  XMLErrorLog_t *log = XMLErrorLog_create();

  int i = XMLInputStream_setErrorLog(stream, log);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(XMLInputStream_getErrorLog(stream) == log);
  
  i = XMLInputStream_setErrorLog(stream, NULL);
  fail_unless(i == LIBSBML_OPERATION_FAILED);

}
END_TEST 

START_TEST (test_XMLInputStream_accessWithNULL)
{
  fail_unless (XMLInputStream_create(NULL, 0, NULL) == NULL);

  XMLInputStream_free(NULL);

  fail_unless (XMLInputStream_getEncoding(NULL) == NULL);
  fail_unless (XMLInputStream_getErrorLog(NULL) == NULL);
  fail_unless (XMLInputStream_isEOF(NULL) == 0);
  fail_unless (XMLInputStream_isError(NULL) == 0);
  fail_unless (XMLInputStream_isGood(NULL) == 0);
  fail_unless (XMLInputStream_next(NULL) == NULL);
  fail_unless (XMLInputStream_peek(NULL) == NULL);
  fail_unless (XMLInputStream_setErrorLog(NULL, NULL) == LIBSBML_OPERATION_FAILED);

  XMLInputStream_skipPastEnd(NULL, NULL);
  XMLInputStream_skipText(NULL);  
}
END_TEST 

Suite *
create_suite_XMLInputStream (void)
{
  Suite *suite = suite_create("XMLInputStream");
  TCase *tcase = tcase_create("XMLInputStream");

  tcase_add_test( tcase, test_XMLInputStream_create  );
  tcase_add_test( tcase, test_XMLInputStream_next_peek  );
  tcase_add_test( tcase, test_XMLInputStream_skip  );
  tcase_add_test( tcase, test_XMLInputStream_setErrorLog  );
  tcase_add_test( tcase, test_XMLInputStream_accessWithNULL );

  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif



