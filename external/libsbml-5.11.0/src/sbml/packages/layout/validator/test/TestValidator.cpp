/**
 * \file   TestValidator.cpp
 * \brief  Validator unit tests
 * \author Ben Bornstein
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
#include <sstream>

#include <vector>

#include <algorithm>
#include <functional>
#include <iterator>

#include <sbml/SBMLDocument.h>
#include <sbml/SBMLReader.h>
#include <sbml/validator/Validator.h>

#include "TestFile.h"

#include "TestValidator.h"

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


TestValidator::TestValidator (Validator& v) : mValidator(v), mVerboseAll(false)
{
  readVerboseFromEnvironment();
}


TestValidator::~TestValidator ()
{
}


/**
 * Function Object: Return true if the given SBMLError has the given
 * id, false otherwise.
 */
struct HasId : public unary_function<SBMLError, bool>
{
  unsigned int id;

  HasId (unsigned int id) : id(id) { }
  bool operator() (const SBMLError& msg) { return msg.getErrorId() == id; }
};


/**
 * Function Object: Takes a SBMLError and returns its integer id.
 */
struct ToId : public unary_function<SBMLError, unsigned int>
{
  unsigned int operator() (const SBMLError& msg) { return msg.getErrorId(); }
};


/**
 * @return true if the Validator behaved as expected when validating
 * TestFile, false otherwise.
 */
bool
TestValidator::test (const TestFile& file)
{
  bool error = false;

  unsigned int id       = file.getConstraintId();
  //cout << file.getFilename() << endl;
  /* change numbers for specific units tests that report same number */
  if (id == 99502 || id == 99503 || id == 99504)
    id = 10501;

  /* change numbers for specific units tests that report same number */
  if (id == 90502 || id == 90503 || id == 90504)
    id = 90501;

  unsigned int expected = file.getNumFailures();
  unsigned int others   = file.getAdditionalFailId();
  /* for 10311 called using just the id validator you will get 99303 */
  if (id == 10311 && expected == 1)
  {
    expected = 2;
    others = 99303;
  }

  unsigned int actual   = mValidator.validate( file.getFullname() );

  list<SBMLError>::const_iterator begin = mValidator.getFailures().begin();
  list<SBMLError>::const_iterator end   = mValidator.getFailures().end();



  if (expected != actual)
  {
    error = true;

    cout << endl;
    cout << "Error: " << file.getFilename() << endl;
    cout << "  - Failures:  Expected: "  << expected << "  Actual: " << actual;
    cout << endl << endl;
  }


  unsigned int same = (unsigned int)count_if(begin, end, HasId(id));
  vector<unsigned int> ids;

  if (expected != same && actual != same)
  {
    // need to consider case where the test case has
    // an additional fail
    if (expected - same != 1)
    {
      error = true;
    }
    else
    {
      transform(begin, end, back_inserter(ids), ToId());

      unsigned int match = 0;
      for (unsigned int i = 0; i < ids.size(); i++)
      {
        if (ids.at(i) == others)
        {
          match = 1;
        }
      }

      if (match == 0)
      {
        error = true;
      }
    }
  }

  if (error)
  {      
    cout << endl;
    cout << "Error: " << file.getFilename() << endl;
    cout << "  - Constraints:  Expected: " << id << "  Actual: ";
    cout << endl;
    copy(ids.begin(), ids.end(), ostream_iterator<unsigned int>(cout, " "));
    cout << endl;
  }

  if ( error || isVerbose(id) )
  {
    copy(begin, end, ostream_iterator<SBMLError>(cout, "\n"));
  }

  mValidator.clearFailures();

  return error == false;
}


/**
 * @return true if the all Validator failures for the given Constraint id
 * test cases should be printed, false otherwise.
 */
bool
TestValidator::isVerbose (unsigned int id)
{
  vector<unsigned int>::iterator begin = mVerboseConstraintIds.begin();
  vector<unsigned int>::iterator end   = mVerboseConstraintIds.end();


  return mVerboseAll || find(begin, end, id) != end;
}


/**
 * Reads the environment variable 'LIBSBML_TEST_VALIDATOR_VERBOSE' and sets
 * the internal verbose state accordingly.
 *
 * LIBSBML_TEST_VALIDATOR_VERBOSE may either be set to 'all' (case
 * sensitive) or a space separated list of constraint ids.
 */
void
TestValidator::readVerboseFromEnvironment ()
{
  const char* s = getenv("LIBSBML_TEST_VALIDATOR_VERBOSE");


  if (s == NULL)
  {
    return;
  }
  else if (string(s) == "all")
  {
    mVerboseAll = true;
  }
  else
  {
    unsigned int  id;
    istringstream is(s);

    while ( !is.eof() )
    {
      is >> id;
      mVerboseConstraintIds.push_back(id);
    }
  }
}
