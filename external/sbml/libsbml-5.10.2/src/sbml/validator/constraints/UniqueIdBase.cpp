/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueIdBase.cpp
 * @brief   Base class for unique id constraints
 * @author  Ben Bornstein
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

#include <sbml/SBase.h>

#include "UniqueIdBase.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new UniqueIdBase with the given constraint id.
 */
UniqueIdBase::UniqueIdBase (unsigned int id, Validator& v) : IdBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueIdBase::~UniqueIdBase ()
{
}


/*
 * Resets the state of this GlobalConstraint by clearing its internal
 * list of error messages.
 */
void
UniqueIdBase::reset ()
{
  mIdObjectMap.clear();
}


/*
 * Checks that the id associated with the given object is unique.  If it
 * is not, logIdConflict is called.
 */
void
UniqueIdBase::doCheckId (const string& id, const SBase& object)
{
  if (mIdObjectMap.insert( make_pair(id, &object) ).second == false)
  {
    logIdConflict(id, object);
  }
}


/*
 * @return the error message to use when logging constraint violations.
 * This method is called by logFailure.
 *
 * Returns a message that the given @p id and its corresponding object are
 * in  conflict with an object previously defined.
 */
const string
UniqueIdBase::getMessage (const string& id, const SBase& object)
{
  IdObjectMap::iterator iter = mIdObjectMap.find(id);


  if (iter == mIdObjectMap.end())
  {
    return
      "Internal (but non-fatal) Validator error in "
      "UniqueIdBase::getMessage().  The SBML object with duplicate id was "
      "not found when it came time to construct a descriptive error message.";
  }


  ostringstream msg;
  const SBase&  previous = *(iter->second);


  //msg << getPreamble();

  //
  // Example message: 
  //
  // The Compartment id 'cell' conflicts with the previously defined
  // Parameter id 'cell' at line 10.
  //

  msg << "  The " << getTypename(object) << " " << getFieldname()
      << " '" << id << "' conflicts with the previously defined "
      << getTypename(previous) << ' ' << getFieldname()
      << " '" << id << "'";

  if (previous.getLine() != 0)
  {
    msg << " at line " << previous.getLine();
  }

  msg << '.';

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
