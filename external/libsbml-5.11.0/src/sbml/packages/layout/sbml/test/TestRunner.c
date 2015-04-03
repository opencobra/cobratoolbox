/**
 * Filename    : TestRunner.c
 * Description : TestRunner that runs all the test suites.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2005-05-03
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
 * Copyright (C) 2004-2008 by European Media Laboratories Research gGmbH,
 *     Heidelberg, Germany
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <string.h>
#include <stdlib.h>

#include <sbml/common/extern.h>
#include <sbml/util/memory.h>

#include <check.h>

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
BEGIN_C_DECLS

LIBSBML_CPP_NAMESPACE_USE

Suite *create_suite_Point                 (void);
Suite *create_suite_Dimensions            (void);
Suite *create_suite_BoundingBox           (void);
Suite *create_suite_LineSegment           (void);
Suite *create_suite_CubicBezier           (void);
Suite *create_suite_Curve                 (void);
Suite *create_suite_GraphicalObject       (void);
Suite *create_suite_CompartmentGlyph      (void);
Suite *create_suite_SpeciesGlyph          (void);
Suite *create_suite_ReactionGlyph         (void);
Suite *create_suite_GeneralGlyph          (void);
Suite *create_suite_SpeciesReferenceGlyph (void);
Suite *create_suite_ReferenceGlyph        (void);
Suite *create_suite_TextGlyph             (void);
Suite *create_suite_Layout                (void);
Suite *create_suite_LayoutCreation        (void);
Suite *create_suite_LayoutFormatter       (void);
Suite *create_suite_SBMLHandler           (void);
Suite *create_suite_LayoutWriting         (void);
Suite *create_suite_Misc                  (void);

END_C_DECLS


/**
 * Global.
 *
 * Declared extern in TestReadFromFileN suites.
 */
char *TestDataDirectory;


/**
 * Sets TestDataDirectory for the the TestReadFromFileN suites.
 *
 * For Automake's distcheck target to work properly, TestDataDirectory must
 * begin with the value of the environment variable SRCDIR.
 */
void
setTestDataDirectory (void)
{
  char *srcdir = getenv("srcdir");
  int  length  = (srcdir == NULL) ? 0 : (int)strlen(srcdir);
  
  
  /**
   * strlen("/test-data/") = 11 + 1 (for NULL) = 12
   */
  TestDataDirectory = (char *) safe_calloc( length + 12, sizeof(char) );
  
  if (srcdir != NULL)
  {
    strcpy(TestDataDirectory, srcdir);
  }
  
  strcat(TestDataDirectory, "/test-data/");
}


int
main (void)
{
  int num_failed;
  
  setTestDataDirectory();
  
  SRunner *runner = srunner_create( create_suite_Point() );
  
  srunner_add_suite( runner, create_suite_Dimensions            () );
  srunner_add_suite( runner, create_suite_BoundingBox           () );
  srunner_add_suite( runner, create_suite_LineSegment           () );
  srunner_add_suite( runner, create_suite_CubicBezier           () );
  srunner_add_suite( runner, create_suite_Curve                 () );
  srunner_add_suite( runner, create_suite_GraphicalObject       () );
  srunner_add_suite( runner, create_suite_CompartmentGlyph      () );
  srunner_add_suite( runner, create_suite_SpeciesGlyph          () );
  srunner_add_suite( runner, create_suite_ReactionGlyph         () );
  srunner_add_suite( runner, create_suite_GeneralGlyph          () );
  srunner_add_suite( runner, create_suite_ReferenceGlyph        () );
  srunner_add_suite( runner, create_suite_SpeciesReferenceGlyph () );
  srunner_add_suite( runner, create_suite_TextGlyph             () );
  srunner_add_suite( runner, create_suite_Layout                () );
  srunner_add_suite( runner, create_suite_LayoutCreation        () );
  srunner_add_suite( runner, create_suite_LayoutFormatter       () );
  srunner_add_suite( runner, create_suite_SBMLHandler           () );
  srunner_add_suite( runner, create_suite_LayoutWriting         () );
  /* srunner_add_suite( runner, create_suite_Misc                  () ); */
  
  
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
  safe_free(TestDataDirectory);
  
  return num_failed;
}
