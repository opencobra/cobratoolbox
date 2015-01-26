/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    CompartmentOutsideCycles.cpp
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

#include <sbml/Model.h>
#include <sbml/Compartment.h>

#include <sbml/util/IdList.h>
#include "CompartmentOutsideCycles.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
CompartmentOutsideCycles::CompartmentOutsideCycles ( unsigned int id,
                                                     Validator& v ) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
CompartmentOutsideCycles::~CompartmentOutsideCycles ()
{
}


/*
 * Checks that no Compartments in Model have a cycle via their 'outside'
 * attribute.
 *
 * Sets mHolds to true if no cycles are found, false otherwise.
 */
void
CompartmentOutsideCycles::check_ (const Model& m, const Model& object)
{
  for (unsigned int n = 0; n < m.getNumCompartments(); n++)
  {
    checkForCycle(m, m.getCompartment(n));
  }

  mCycles.clear();
}


/*
 * Checks for a cycle by following Compartment c's 'outside' attribute.  If
 * a cycle is found, it is added to the list of found cycles, mCycles.
 */
void
CompartmentOutsideCycles::checkForCycle (const Model& m, const Compartment* c)
{
  IdList visited;


  while (c != NULL && !isInCycle(c))
  {
    const string& id = c->getId();

    if ( visited.contains(id) )
    {
      visited.removeIdsBefore(id);

      mCycles.push_back(visited);
      logCycle(c, visited);

      break;
    }

    visited.append(id);
    c = c->isSetOutside() ? m.getCompartment( c->getOutside() ) : NULL;
  }
}


/*
 * Function Object: Returns true if Compartment c is contained in the given
 * IdList cycle.
 */
struct CycleContains : public unary_function<IdList, bool>
{
  CycleContains (const Compartment* c) : id(c->getId()) { }

  bool operator() (const IdList& lst) const
  {
    return lst.contains(id);
  }

  const string& id;
};


/*
 * @return true if Compartment c is contained in one of the already found
 * cycles, false otherwise.
 */
bool
CompartmentOutsideCycles::isInCycle (const Compartment* c)
{
  vector<IdList>::iterator end = mCycles.end();
  return find_if(mCycles.begin(), end, CycleContains(c)) != end;
}


/*
 * Logs a message about a cycle found starting at Compartment c.
 */
void
CompartmentOutsideCycles::logCycle (const Compartment* c, const IdList& cycle)
{
  //msg  = 
  //  "A <compartment> may not enclose itself through a chain of references "
  //  "involving the 'outside' field. This means that a compartment cannot "
  //  "have its own identifier as the value of 'outside', nor can it point to "
  //  "another compartment whose 'outside' field points directly or indirectly "
  //  "to the compartment. (References: L2V1 erratum 11; L2V2 Section 4.7.7.) ";
  msg = "Compartment '" + c->getId() + "' encloses itself";

  if (cycle.size() > 1)
  {
    IdList::const_iterator iter = cycle.begin();
    IdList::const_iterator end  = cycle.end();

    msg += " via '" + *iter++ + "'";
    while (iter != end) msg += " -> '" + *iter++ + "'";
    msg += " -> '" + c->getId() + "'";
  }

  msg += '.';

  logFailure(*c);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

