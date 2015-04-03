/**
 * \file   TestConsistencyValidator.cpp
 * \brief  Runs the ConsistencyValidator on each SBML file in test-data/
 * \author Sarah Keating
 * \author Ben Bornstein
 * \author Michael Hucka
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

#include <iostream>
#include <set>

#include <algorithm>

#include "TestFile.h"
#include "TestValidator.h"

#include "ConsistencyValidator.h"
#include "MathMLConsistencyValidator.h"
#include "IdentifierConsistencyValidator.h"
#include "SBOConsistencyValidator.h"
#include "UnitConsistencyValidator.h"
#include <sbml/validator/OverdeterminedValidator.h>
#include "L1CompatibilityValidator.h"
#include "L2v1CompatibilityValidator.h"
#include "L2v2CompatibilityValidator.h"
#include "L2v3CompatibilityValidator.h"
#include "L2v4CompatibilityValidator.h"
#include "L3v1CompatibilityValidator.h"
#include <sbml/validator/ModelingPracticeValidator.h>
#include <sbml/SBase.h>

#ifdef LIBSBML_USE_VLD
  #include <vld.h>
#endif

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runMainTest (const TestFile& file)
{
  ConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runIdTest (const TestFile& file)
{
  IdentifierConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runMathMLTest (const TestFile& file)
{
  MathMLConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runSBOTest (const TestFile& file)
{
  SBOConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runUnitTest (const TestFile& file)
{
  UnitConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  bool result = true;

  try
  {
    result = tester.test(file);
  }
  catch (SBMLConstructorException &e)
  {
    cout << e.getSBMLErrMsg() << endl;
    result = false;
  }

  return result;
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runOverTest (const TestFile& file)
{
  OverdeterminedValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL1Test (const TestFile& file)
{
  L1CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL2v1Test (const TestFile& file)
{
  L2v1CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL2v2Test (const TestFile& file)
{
  L2v2CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL2v3Test (const TestFile& file)
{
  L2v3CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL2v4Test (const TestFile& file)
{
  L2v4CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runL3v1Test (const TestFile& file)
{
  L3v1CompatibilityValidator validator;
  TestValidator            tester(validator);


  validator.init();

  return tester.test(file);
}

/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
runTestBadXML (const TestFile& file)
{
  ConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

bool
runAdditionalSBMLTest (const TestFile& file)
{
  ConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

bool
runAdditionalUnitTest (const TestFile& file)
{
  UnitConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}

bool
runAdditionalMathTest (const TestFile& file)
{
  MathMLConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}


bool
runAdditionalSBOTest (const TestFile& file)
{
  SBOConsistencyValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}


bool
runModelingPracticeTest (const TestFile& file)
{
  ModelingPracticeValidator validator;
  TestValidator        tester(validator);


  validator.init();

  return tester.test(file);
}


/**
 * Run a given set of tests and print the results.
 */
unsigned int
runTests ( const string& msg,
	   const string& directory,
	   unsigned int  begin,
	   unsigned int  end,
	   bool (*tester)(const TestFile& file), 
     unsigned int library)
{
  cout.precision(0);
  cout.width(3);

  cout << msg << "." << endl;

  set<TestFile> files    = TestFile::getFilesIn(directory, begin, end, library);
  unsigned int  passes   = count_if(files.begin(), files.end(), tester);
  unsigned int  failures = files.size() - passes;
  double        percent  = (static_cast<double>(passes) / files.size()) * 100;

  cout << static_cast<int>(percent) << "%: Checks: " << files.size();
  cout << ", Failures: " << failures << endl;

  return failures;
}

/**
 * Runs the libSBML ConsistencyValidator on all consistency TestFiles in
 * the test-data/ directory.
 * Runs the libSBML L1CompatibilityValidator on all TestFiles in the
 * test-data-conversion/ directory.
 */
int
main (int argc, char* argv[])
{
  unsigned int library = 0;
#ifdef USE_EXPAT
  library = 1;
#endif
#ifdef USE_LIBXML
  library = 2;
#endif
  unsigned int failed = 0;

  string prefix(".");

  char *srcdir = getenv("srcdir");
  if (srcdir != NULL) 
  {
    prefix = srcdir;
  }
  if (argc == 2)
  {
    prefix = argv[1];
  }

  // allow the test runner to be invoked with the directory containing
  // the test-data and test-data conversion directories 
  string testDataDir = prefix + "/" + "test-data";
  string testDataConversionDir = prefix + "/" + "test-data-conversion";
  string testThisDataDir;

  cout << endl;
  cout << "Validator testrunner" << endl;
  cout << "====================" << endl;
  cout << "using test data from           : " << testDataDir << endl;
  cout << "using conversion test data from: " << testDataConversionDir << endl;
  cout << endl;


  testThisDataDir = testDataDir + "/" + "xml-parser-constraints";
  failed += runTests( "Testing Bad XML Constraints (0000 - 10000)",
		      testThisDataDir, 0, 9999, runTestBadXML, library);

  testThisDataDir = testDataDir + "/" + "sbml-xml-constraints";
  failed += runTests( "Testing General XML Consistency Constraints (10000 - 10199)",
		      testThisDataDir, 10000, 10199, runMainTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-mathml-constraints";
  failed += runTests( "Testing General MathML Consistency Constraints (10200 - 10299)",
		      testThisDataDir, 10200, 10299, runMathMLTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-identifier-constraints";
  failed += runTests( "Testing Id Consistency Constraints (10300 - 10399)",
		      testThisDataDir, 0, 0, runIdTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-annotation-constraints";
  failed += runTests( "Testing General Annotation Consistency Constraints (10400 - 10499)",
		      testThisDataDir, 10400, 10499, runMainTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-unit-constraints";
  failed += runTests( "Testing Unit Consistency Constraints (10500 - 10599)",
		      testThisDataDir, 10500, 10599, runUnitTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-modeldefinition-constraints";
  failed += runTests( "Testing Overdetermined Constraints (10600 - 10699)",
		      testThisDataDir, 10600, 10699, runOverTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-sbo-constraints";
  failed += runTests( "Testing SBO Consistency Constraints (10700 - 10799)",
		      testThisDataDir, 10700, 10799, runSBOTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-notes-constraints";
  failed += runTests( "Testing General Notes Consistency Constraints (10800 - 19999)",
		      testThisDataDir, 10800, 19999, runMainTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-general-consistency-constraints";
  failed += runTests( "Testing Model Consistency Constraints (20000 - 29999)",
		      testThisDataDir, 20000, 29999, runMainTest, library);

  failed += runTests( "Testing L1 Compatibility Constraints (91000 - 91999)",
		      testDataConversionDir, 91000, 91999, runL1Test, library);

  failed += runTests( "Testing L2v1 Compatibility Constraints (92000 - 92999)",
		      testDataConversionDir, 92000, 92999, runL2v1Test, library);

  failed += runTests("Testing L2v2 Compatibility Constraints (93000 - 93999)",
		     testDataConversionDir, 93000, 93999, runL2v2Test, library);

  failed += runTests("Testing L2v3 Compatibility Constraints (94000 - 94999)",
		     testDataConversionDir, 94000, 94999, runL2v3Test, library);

  failed += runTests("Testing L2v4 Compatibility Constraints (95000 - 95999)",
		     testDataConversionDir, 95000, 95999, runL2v4Test, library);

  failed += runTests( "Testing L3v1 Compatibility Constraints (96000 - 96999)",
		      testDataConversionDir, 96000, 96999, runL3v1Test, library);

  testThisDataDir = testDataDir + "/" + "libsbml-constraints";
  failed += runTests("Testing Additional SBML Constraints (99100 - 99199)",
		     testThisDataDir, 99100, 99199, runAdditionalSBMLTest, library);

  failed += runTests("Testing Additional Math Constraints (99200 - 99299)",
		     testThisDataDir, 99200, 99299, runAdditionalMathTest, library);

  failed += runTests("Testing Additional SBML Constraints (99300 - 99399)",
		     testThisDataDir, 99300, 99399, runAdditionalSBMLTest, library);

  failed += runTests("Testing Additional Annotation Constraints (99400 - 99499)",
		     testThisDataDir, 99400, 99499, runAdditionalSBMLTest, library);

  failed += runTests("Testing Additional Unit Constraints (99500 - 99599)",
		     testThisDataDir, 99500, 99599, runAdditionalUnitTest, library);

  failed += runTests("Testing Additional SBO Constraints (99700 - 99799)",
		     testThisDataDir, 99700, 99799, runAdditionalSBOTest, library);

  testThisDataDir = testDataDir + "/" + "sbml-modeling-practice-constraints";
  failed += runTests("Testing Modeling Practice Constraints (80000 - 89999)",
		     testThisDataDir, 80000, 89999, runModelingPracticeTest, library);

  return failed;
}

