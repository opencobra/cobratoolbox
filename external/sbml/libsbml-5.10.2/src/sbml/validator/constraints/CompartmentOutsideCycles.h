/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    CompartmentOutsideCycles.h
 * @brief   Ensures no cycles exist via a Compartment's 'outside' attribute.
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

#ifndef CompartmentOutsideCycles_h
#define CompartmentOutsideCycles_h


#ifdef __cplusplus



#include <string>
#include <vector>

#include <algorithm>
#include <functional>

#include <sbml/validator/VConstraint.h>
#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class Model;
class Compartment;
class Validator;


class CompartmentOutsideCycles: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given @p id.
   */
  CompartmentOutsideCycles (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~CompartmentOutsideCycles ();


protected:

  /**
   * Checks that no Compartments in Model have a cycle via their 'outside'
   * attribute.
   *
   * Sets mHolds to true if no cycles are found, false otherwise.
   */
  virtual void check_ (const Model& m, const Model& object);

  /**
   * Checks for a cycle by following Compartment c's 'outside' attribute.
   * If a cycle is found, it is added to the list of found cycles, mCycles.
   */
  void checkForCycle (const Model& m, const Compartment* c);

  /**
   * Returns true if Compartment @p c is contained in one of the already found
   * cycles, false otherwise.
   *
   * @return true if Compartment c is contained in one of the already found
   * cycles, false otherwise.
   */
  bool isInCycle (const Compartment* c);

  /**
   * Logs a message about a cycle found starting at Compartment c.
   */
  void logCycle (const Compartment* c, const IdList& cycle);


  std::vector<IdList> mCycles;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* CompartmentOutsideCycles_h */

/** @endcond */
