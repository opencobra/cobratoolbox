/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueIdBase.h
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

#ifndef UniqueIdBase_h
#define UniqueIdBase_h


#ifdef __cplusplus


#include <string>
#include <sstream>
#include <map>

#include "IdBase.h"

LIBSBML_CPP_NAMESPACE_BEGIN

class SBase;
class Validator;


class UniqueIdBase: public IdBase
{
public:

  /**
   * Creates a new UniqueIdBase with the given constraint id.
   */
  UniqueIdBase (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~UniqueIdBase ();


protected:

  /**
   * Resets the state of this GlobalConstraint by clearing its internal
   * list of error messages.
   */
  void reset ();

  /**
   * Called by check().  Override this method to define your own subset.
   */
  virtual void doCheck (const Model& m) = 0;

  /**
   * Checks that the id associated with the given object is unique.  If it
   * is not, logFailure is called.
   */
  void doCheckId (const std::string& id, const SBase& object);


  /**
   * Returns the error message to use when logging constraint violations.
   * This method is called by logFailure.
   *
   * Returns a message that the given @p id and its corresponding object are
   * in conflict with an object previously defined.
   */
  virtual const std::string
  getMessage (const std::string& id, const SBase& object);


  typedef std::map<std::string, const SBase*> IdObjectMap;
  IdObjectMap mIdObjectMap;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* UniqueIdBase_h */

/** @endcond */

