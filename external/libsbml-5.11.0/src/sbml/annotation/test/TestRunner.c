/**
 * \file    TestRunner.c
 * \brief   Runs all unit tests in the annotation module
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

#include <check.h>
#include <stdlib.h>
#include <string.h>

#include <sbml/common/extern.h>
#include <sbml/util/memory.h>

#ifdef LIBSBML_USE_VLD
  #include <vld.h>
#endif

/**
 * Test suite creation function prototypes.
 *
 * These functions are needed only for calls in main() below.  Therefore a
 * separate header file is not necessary and only adds a maintenance burden
 * to keep the two files synchronized.
 */
#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

Suite *create_suite_CVTerms (void);
Suite *create_suite_CVTerms_newSetters (void);
Suite *create_suite_RDFAnnotation (void);
Suite *create_suite_RDFAnnotation2 (void);
Suite *create_suite_ModelHistory (void);
Suite *create_suite_Date_newSetters (void);
Suite *create_suite_ModelCreator_newSetters (void);
Suite *create_suite_ModelHistory_newSetters (void);
Suite *create_suite_CopyAndClone (void);
Suite *create_suite_Validation (void);
Suite *create_suite_RDFAnnotation_C (void);
Suite *create_suite_L3ModelHistory (void);
Suite *create_suite_SyncAnnotation (void);
Suite *create_suite_RDFAnnotationMetaid (void);

/**
 * Global.
 *
 * Declared extern in TestAnnotation suite.
 */
char *TestDataDirectory;


/**
 * Sets TestDataDirectory for the the TestAnnotation suite.
 *
 * For Automake's distcheck target to work properly, TestDataDirectory must
 * begin with the value of the environment variable SRCDIR.
 */
void
setTestDataDirectory (void)
{
  char *srcdir = getenv("srcdir");
  size_t  length  = (srcdir == NULL) ? 0 : strlen(srcdir);


  /**
   * strlen("/test-data/") = 11 + 1 (for NULL) = 12
   */
  TestDataDirectory = (char *) safe_calloc( length + 12, sizeof(char) );

  if (srcdir != NULL)
  {
    strcpy(TestDataDirectory, srcdir);
    strcat(TestDataDirectory, "/");
  }

  strcat(TestDataDirectory, "test-data/");
}


int
main (int argc, char* argv[]) 
{ 
  int num_failed;
  setTestDataDirectory();

  SRunner *runner = srunner_create( create_suite_CVTerms() );

  srunner_add_suite( runner, create_suite_CVTerms_newSetters  () );
  srunner_add_suite( runner, create_suite_ModelHistory  () );
  srunner_add_suite( runner, create_suite_Date_newSetters  () );
  srunner_add_suite( runner, create_suite_ModelCreator_newSetters  () );
  srunner_add_suite( runner, create_suite_ModelHistory_newSetters  () );
  srunner_add_suite( runner, create_suite_CopyAndClone  () );
  srunner_add_suite( runner, create_suite_RDFAnnotation () );
  srunner_add_suite( runner, create_suite_RDFAnnotation2() );
  srunner_add_suite( runner, create_suite_Validation () );
  srunner_add_suite( runner, create_suite_RDFAnnotation_C () );
  srunner_add_suite( runner, create_suite_L3ModelHistory  () );
  srunner_add_suite( runner, create_suite_SyncAnnotation  () );
  srunner_add_suite( runner, create_suite_RDFAnnotationMetaid () );

  if (argc > 1 && !strcmp(argv[1], "-nofork"))
  {
    srunner_set_fork_status( runner, CK_NOFORK );
  }

  srunner_run_all(runner, CK_NORMAL);
  num_failed = srunner_ntests_failed(runner);

  srunner_free(runner);

  free(TestDataDirectory);

  return num_failed;
}

#if defined(__cplusplus)
CK_CPPEND
#endif


