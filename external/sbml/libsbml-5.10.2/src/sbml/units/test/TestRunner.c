/**
 * \file    TestRunner.c
 * \brief   Runs all unit tests in the math module
 * \author  Ben Bornstein
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

LIBSBML_CPP_NAMESPACE_USE

/**
 * Test suite creation function prototypes.
 *
 * These functions are needed only for calls in main() below.  Therefore a
 * separate header file is not necessary and only adds a maintenance burden
 * to keep the two files synchronized.
 */
BEGIN_C_DECLS

Suite *create_suite_UtilsUnit (void);
Suite *create_suite_UtilsUnitDefinition (void);
Suite *create_suite_UnitFormulaFormatter (void);
Suite *create_suite_UnitFormulaFormatter1 (void);
Suite *create_suite_UnitFormulaFormatter2 (void);
Suite *create_suite_UnitFormulaFormatter3 (void);
Suite *create_suite_FormulaUnitsData (void);
Suite *create_suite_DerivedUnitDefinition (void);
Suite *create_suite_CalcUnitDefinition (void);

END_C_DECLS
/**
 * Global.
 *
 * Declared extern in TestUnitFormulaFormatter suite.
 */
char *TestDataDirectory;


/**
 * Sets TestDataDirectory for the the TestUnitFormulaFormatter suite.
 *
 * For Automake's distcheck target to work properly, TestDataDirectory must
 * begin with the value of the environment variable SRCDIR.
 */
void
setTestDataDirectory (void)
{
  char *srcdir = getenv("srcdir");
  int  length  = (srcdir == NULL) ? 0 : strlen(srcdir);


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
main (void) 
{ 
  int num_failed;

  setTestDataDirectory();

  SRunner *runner = srunner_create( create_suite_UtilsUnit() );

  srunner_add_suite( runner, create_suite_UtilsUnitDefinition  () );
  srunner_add_suite( runner, create_suite_UnitFormulaFormatter () );
  srunner_add_suite( runner, create_suite_UnitFormulaFormatter1() );
  srunner_add_suite( runner, create_suite_FormulaUnitsData() );
  srunner_add_suite( runner, create_suite_DerivedUnitDefinition() );
  srunner_add_suite( runner, create_suite_UnitFormulaFormatter2() );
  srunner_add_suite( runner, create_suite_CalcUnitDefinition() );
  srunner_add_suite( runner, create_suite_UnitFormulaFormatter3() );
  


#ifdef TRACE_MEMORY
  srunner_set_fork_status(runner, CK_NOFORK);
#endif

  srunner_run_all(runner, CK_NORMAL);
  num_failed = srunner_ntests_failed(runner);

#ifdef TRACE_MEMORY

  if (MemTrace_getNumLeaks() > 0)
  {
    MemTrace_printLeaks(stdout);
  }

  MemTrace_printStatistics(stdout);

#endif

  srunner_free(runner);

  return num_failed;
}
