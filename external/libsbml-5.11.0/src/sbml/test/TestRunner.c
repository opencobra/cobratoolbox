/**
 * \file    TestRunner.c
 * \brief   Runs all unit tests in the sbml module
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

#include <string.h>
#include <stdlib.h>

#include <sbml/common/extern.h>
#include <sbml/util/memory.h>

#include <check.h>

#ifdef LIBSBML_USE_VLD
  #include <vld.h>
#endif

LIBSBML_CPP_NAMESPACE_USE


/**
 * Test suite creation function prototypes.
 *
 * These functions are needed only for calls in main() below.  Therefore a
 * separate header file is not necessary and only adds a maintenance burden
 * to keep the two files synchronized.
 */
BEGIN_C_DECLS


Suite *create_suite_ReadSBML                      (void);
Suite *create_suite_WriteSBML                     (void);
Suite *create_suite_WriteL3SBML                   (void);

Suite *create_suite_AlgebraicRule                 (void);
Suite *create_suite_AssignmentRule                (void);
Suite *create_suite_Compartment                   (void);
Suite *create_suite_Compartment_newSetters        (void);
Suite *create_suite_L3_Compartment                (void);
Suite *create_suite_CompartmentType               (void);
Suite *create_suite_CompartmentType_newSetters    (void);
Suite *create_suite_Constraint                    (void);
Suite *create_suite_Constraint_newSetters         (void);
Suite *create_suite_CompartmentVolumeRule         (void);
Suite *create_suite_Delay                         (void);
Suite *create_suite_Event                         (void);
Suite *create_suite_L3_Event                      (void);
Suite *create_suite_Event_newSetters              (void);
Suite *create_suite_EventAssignment               (void);
Suite *create_suite_EventAssignment_newSetters    (void);
Suite *create_suite_FunctionDefinition            (void);
Suite *create_suite_FunctionDefinition_newSetters (void);
Suite *create_suite_InitialAssignment             (void);
Suite *create_suite_InitialAssignment_newSetters  (void);
Suite *create_suite_KineticLaw                    (void);
Suite *create_suite_KineticLaw_newSetters         (void);
Suite *create_suite_L3_KineticLaw                 (void);
Suite *create_suite_ListOf                        (void);
Suite *create_suite_Model                         (void);
Suite *create_suite_L3_Model                      (void);
Suite *create_suite_Model_newSetters              (void);
Suite *create_suite_ModifierSpeciesReference      (void);
Suite *create_suite_Parameter                     (void);
Suite *create_suite_L3_Parameter                  (void);
Suite *create_suite_L3_LocalParameter             (void);
Suite *create_suite_Parameter_newSetters          (void);
Suite *create_suite_ParameterRule                 (void);
Suite *create_suite_Priority                      (void);
Suite *create_suite_RateRule                      (void);
Suite *create_suite_Reaction                      (void);
Suite *create_suite_L3_Reaction                   (void);
Suite *create_suite_Reaction_newSetters           (void);
Suite *create_suite_Rule                          (void);
Suite *create_suite_Rule_newSetters               (void);
Suite *create_suite_RuleType                      (void);
Suite *create_suite_SBase                         (void);
Suite *create_suite_SBase_newSetters              (void);
Suite *create_suite_SBMLConvert                   (void);
Suite *create_suite_SBMLConvertStrict             (void);
Suite *create_suite_SBMLDocument                  (void);
Suite *create_suite_SBMLError                     (void);
Suite *create_suite_SBMLReader                    (void);
Suite *create_suite_SBMLWriter                    (void);
Suite *create_suite_SimpleSpeciesReference        (void);
Suite *create_suite_Species                       (void);
Suite *create_suite_L3_Species                    (void);
Suite *create_suite_Species_newSetters            (void);
Suite *create_suite_SpeciesConcentrationRule      (void);
Suite *create_suite_SpeciesReference              (void);
Suite *create_suite_L3_SpeciesReference           (void);
Suite *create_suite_SpeciesReference_newSetters   (void);
Suite *create_suite_SpeciesType                   (void);
Suite *create_suite_SpeciesType_newSetters        (void);
Suite *create_suite_StoichiometryMath             (void);
Suite *create_suite_Trigger                       (void);
Suite *create_suite_L3Trigger                     (void);
Suite *create_suite_Unit                          (void);
Suite *create_suite_L3_Unit                       (void);
Suite *create_suite_Unit_newSetters               (void);
Suite *create_suite_UnitDefinition                (void);
Suite *create_suite_UnitDefinition_newSetters     (void);
Suite *create_suite_UnitKind                      (void);

Suite *create_suite_CopyAndClone                  (void);
Suite *create_suite_TestReadFromFile1             (void);
Suite *create_suite_TestReadFromFile2             (void);
Suite *create_suite_TestReadFromFile3             (void);
Suite *create_suite_TestReadFromFile4             (void);
Suite *create_suite_TestReadFromFile5             (void);
Suite *create_suite_TestReadFromFile6             (void);
Suite *create_suite_TestReadFromFile7             (void);
Suite *create_suite_TestReadFromFile8             (void);
Suite *create_suite_TestReadFromFile9             (void);

Suite *create_suite_TestConsistencyChecks         (void);
Suite *create_suite_ParentObject                  (void);
Suite *create_suite_SBMLNamespaces                (void);
Suite *create_suite_AncestorObject                (void);
Suite *create_suite_TestInternalConsistencyChecks (void);
Suite *create_suite_HasReqdAtt                    (void);
Suite *create_suite_HasReqdElements               (void);
Suite *create_suite_SyntaxChecker                 (void);
Suite *create_suite_SBMLConstructorException      (void);

Suite *create_suite_SBMLValidatorAPI              (void);

Suite *create_suite_GetMultipleObjects            (void);
Suite *create_suite_RemoveFromParent              (void);
Suite *create_suite_RenameIDs                     (void);
Suite *create_suite_SBMLTransforms                (void);
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
main (int argc, char* argv[]) 
{ 
  int num_failed;

  setTestDataDirectory();

  SRunner *runner = srunner_create( create_suite_ReadSBML               () );
  srunner_add_suite( runner, create_suite_SBMLValidatorAPI              () );
  srunner_add_suite( runner, create_suite_RenameIDs                     () );
  srunner_add_suite( runner, create_suite_RemoveFromParent              () );
  srunner_add_suite( runner, create_suite_GetMultipleObjects            () );
  srunner_add_suite( runner, create_suite_WriteSBML                     () );
  srunner_add_suite( runner, create_suite_WriteL3SBML                   () );
  srunner_add_suite( runner, create_suite_AlgebraicRule                 () ); 
  srunner_add_suite( runner, create_suite_AssignmentRule                () );
  srunner_add_suite( runner, create_suite_Compartment                   () );
  srunner_add_suite( runner, create_suite_L3_Compartment                () );
  srunner_add_suite( runner, create_suite_Compartment_newSetters        () );
  srunner_add_suite( runner, create_suite_CompartmentType               () );
  srunner_add_suite( runner, create_suite_CompartmentType_newSetters    () );
  srunner_add_suite( runner, create_suite_CompartmentVolumeRule         () );
  srunner_add_suite( runner, create_suite_Constraint                    () );
  srunner_add_suite( runner, create_suite_Constraint_newSetters         () );
  srunner_add_suite( runner, create_suite_Delay                         () );
  srunner_add_suite( runner, create_suite_Event                         () );
  srunner_add_suite( runner, create_suite_L3_Event                      () );
  srunner_add_suite( runner, create_suite_Event_newSetters              () );
  srunner_add_suite( runner, create_suite_EventAssignment               () );
  srunner_add_suite( runner, create_suite_EventAssignment_newSetters    () );
  srunner_add_suite( runner, create_suite_FunctionDefinition            () );
  srunner_add_suite( runner, create_suite_FunctionDefinition_newSetters () );
  srunner_add_suite( runner, create_suite_InitialAssignment             () );
  srunner_add_suite( runner, create_suite_InitialAssignment_newSetters  () );
  srunner_add_suite( runner, create_suite_KineticLaw                    () );
  srunner_add_suite( runner, create_suite_KineticLaw_newSetters         () );
  srunner_add_suite( runner, create_suite_L3_KineticLaw                 () );
  srunner_add_suite( runner, create_suite_ListOf                        () );
  srunner_add_suite( runner, create_suite_Model                         () );
  srunner_add_suite( runner, create_suite_L3_Model                      () );
  srunner_add_suite( runner, create_suite_Model_newSetters              () );
  srunner_add_suite( runner, create_suite_ModifierSpeciesReference      () );
  srunner_add_suite( runner, create_suite_Parameter                     () );
  srunner_add_suite( runner, create_suite_L3_Parameter                  () );
  srunner_add_suite( runner, create_suite_L3_LocalParameter             () );
  srunner_add_suite( runner, create_suite_Parameter_newSetters          () );
  srunner_add_suite( runner, create_suite_ParameterRule                 () );
  srunner_add_suite( runner, create_suite_Priority                      () );
  srunner_add_suite( runner, create_suite_RateRule                      () );
  srunner_add_suite( runner, create_suite_Reaction                      () );
  srunner_add_suite( runner, create_suite_L3_Reaction                   () );
  srunner_add_suite( runner, create_suite_Reaction_newSetters           () );
  srunner_add_suite( runner, create_suite_Rule                          () );
  srunner_add_suite( runner, create_suite_Rule_newSetters               () );
  srunner_add_suite( runner, create_suite_SBase                         () );
  srunner_add_suite( runner, create_suite_SBase_newSetters              () );
  srunner_add_suite( runner, create_suite_Species                       () );
  srunner_add_suite( runner, create_suite_L3_Species                    () );
  srunner_add_suite( runner, create_suite_Species_newSetters            () );
  srunner_add_suite( runner, create_suite_SpeciesReference              () );
  srunner_add_suite( runner, create_suite_L3_SpeciesReference           () );
  srunner_add_suite( runner, create_suite_SpeciesReference_newSetters   () );
  srunner_add_suite( runner, create_suite_SpeciesConcentrationRule      () );
  srunner_add_suite( runner, create_suite_SpeciesType                   () );
  srunner_add_suite( runner, create_suite_SpeciesType_newSetters        () );
  srunner_add_suite( runner, create_suite_StoichiometryMath             () );
  srunner_add_suite( runner, create_suite_Trigger                       () );
  srunner_add_suite( runner, create_suite_L3Trigger                     () );
  srunner_add_suite( runner, create_suite_Unit                          () );
  srunner_add_suite( runner, create_suite_L3_Unit                       () );
  srunner_add_suite( runner, create_suite_Unit_newSetters               () );
  srunner_add_suite( runner, create_suite_UnitDefinition                () );
  srunner_add_suite( runner, create_suite_UnitDefinition_newSetters     () );
  srunner_add_suite( runner, create_suite_UnitKind                      () );
  srunner_add_suite( runner, create_suite_CopyAndClone                  () );
  srunner_add_suite( runner, create_suite_SBMLConvert                   () );
  srunner_add_suite( runner, create_suite_SBMLConvertStrict             () );
  srunner_add_suite( runner, create_suite_SBMLDocument                  () );
  srunner_add_suite( runner, create_suite_SBMLError                     () );
  srunner_add_suite( runner, create_suite_TestReadFromFile1             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile2             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile3             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile4             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile5             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile6             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile7             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile8             () );
  srunner_add_suite( runner, create_suite_TestReadFromFile9             () );
  srunner_add_suite( runner, create_suite_TestConsistencyChecks         () );
  srunner_add_suite( runner, create_suite_ParentObject                  () );
  srunner_add_suite( runner, create_suite_AncestorObject                () );
  srunner_add_suite( runner, create_suite_TestInternalConsistencyChecks () );
  srunner_add_suite( runner, create_suite_HasReqdAtt                    () );
  srunner_add_suite( runner, create_suite_HasReqdElements               () );
  srunner_add_suite( runner, create_suite_SBMLNamespaces                () );
  srunner_add_suite( runner, create_suite_SyntaxChecker                 () );
  srunner_add_suite( runner, create_suite_SBMLConstructorException      () );
  srunner_add_suite( runner, create_suite_SBMLTransforms                () );
  srunner_add_suite( runner, create_suite_GetMultipleObjects            () );


#ifdef TRACE_MEMORY
  srunner_set_fork_status(runner, CK_NOFORK);
#else
  if (argc > 1 && !strcmp(argv[1], "-nofork"))
  {
    srunner_set_fork_status( runner, CK_NOFORK );
  }
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

END_C_DECLS
