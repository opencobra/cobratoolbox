/**
 * \file    TestRunner.c
 * \brief   Runs all unit tests in the xml module
 * \author  Ben Bornstein and Michael Hucka
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
#include <check.h>

#ifdef LIBSBML_USE_VLD
  #include <vld.h>
#endif

#if defined(__cplusplus)
CK_CPPSTART
#endif

Suite *create_suite_XMLAttributes (void);
Suite *create_suite_XMLNamespaces (void);
Suite *create_suite_XMLNode (void);
Suite *create_suite_XMLNode_newSetters (void);
Suite *create_suite_XMLTriple (void);
Suite *create_suite_XMLToken (void);
Suite *create_suite_XMLToken_newSetters (void);
Suite *create_suite_CopyAndClone (void);
Suite *create_suite_XMLError (void);
Suite *create_suite_XMLError_C (void);
Suite *create_suite_XMLErrorLog (void);
Suite *create_suite_XMLInputStream (void);
Suite *create_suite_XMLOutputStream (void);
Suite *create_suite_XMLAttributes_C (void);
Suite *create_suite_XMLExceptions (void);

int
main (int argc, char* argv[]) 
{ 
  int num_failed = 0;
  SRunner *runner = srunner_create(create_suite_XMLAttributes());
  srunner_add_suite(runner, create_suite_CopyAndClone());

  srunner_add_suite(runner, create_suite_XMLNamespaces());
  srunner_add_suite(runner, create_suite_XMLTriple());
  srunner_add_suite(runner, create_suite_XMLToken());
  srunner_add_suite(runner, create_suite_XMLToken_newSetters());
  srunner_add_suite(runner, create_suite_XMLNode());
  srunner_add_suite(runner, create_suite_XMLNode_newSetters());
  srunner_add_suite(runner, create_suite_XMLError());
  srunner_add_suite(runner, create_suite_XMLError_C());
  srunner_add_suite(runner, create_suite_XMLErrorLog());
  srunner_add_suite(runner, create_suite_XMLInputStream());
  srunner_add_suite(runner, create_suite_XMLOutputStream());
  srunner_add_suite(runner, create_suite_XMLAttributes_C());
  srunner_add_suite(runner, create_suite_XMLExceptions());

  if (argc > 1 && !strcmp(argv[1], "-nofork"))
  {
    srunner_set_fork_status( runner, CK_NOFORK );
  }

  srunner_run_all(runner, CK_NORMAL);
  num_failed = srunner_ntests_failed(runner);

  srunner_free(runner);

  return num_failed;
}

#if defined(__cplusplus)
CK_CPPEND
#endif
