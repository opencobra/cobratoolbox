/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueSpeciesTypesInCompartment.cpp
 * @brief   Ensures unique variables assigned by rules and events
 * @author  Sarah Keating
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

#include <cstring>

#include <sbml/Model.h>
#include <sbml/Rule.h>
#include <sbml/Reaction.h>
#include <sbml/Species.h>

#include "UniqueSpeciesTypesInCompartment.h"
#include <sbml/util/IdList.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN


/*
 * Creates a new Constraint with the given constraint id.
 */
UniqueSpeciesTypesInCompartment::UniqueSpeciesTypesInCompartment (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueSpeciesTypesInCompartment::~UniqueSpeciesTypesInCompartment ()
{
}


/*
  * Checks that any species with boundary condition false
  * is not set by reaction and rules
  */
void
UniqueSpeciesTypesInCompartment::check_ (const Model& m, const Model& object)
{
  unsigned int n, ns;

  /* speciesType only occurs in l2v2 and higher */
  if (m.getLevel() == 1 || (m.getLevel()== 2 && m.getVersion() == 1))  return;
  
  for (n = 0; n < m.getNumCompartments(); n++)
  {
    const string & id = m.getCompartment(n)->getId();

    /* create List of species in this compartment */
    for (ns = 0; ns < m.getNumSpecies(); ns++)
    {
      if (!strcmp(m.getSpecies(ns)->getCompartment().c_str(), id.c_str()))
      {
        mSpecies.append(m.getSpecies(ns)->getId());
      }
    } 

    /* loop thru the list of Species in the compartment and check that
       no speciesTypes are same */
    for (IdList::const_iterator the_iterator = mSpecies.begin();
      the_iterator != mSpecies.end(); the_iterator++)
    {
      if (m.getSpecies(*the_iterator)->isSetSpeciesType()) 
      {
        const string & type = m.getSpecies(*the_iterator)->getSpeciesType();

        if (mSpeciesTypes.contains(type))
        {
          logConflict(*m.getSpecies(*the_iterator), *m.getCompartment(n));
        }
        else
        {
          mSpeciesTypes.append(type);
        }
      }
    }

    mSpecies.clear();
    mSpeciesTypes.clear();

  }
}

/*
  * Logs a message about species with boundary condition false
  * being set by reaction and rules
  */
void
UniqueSpeciesTypesInCompartment::logConflict (const Species& s, const Compartment& c)
{
  msg =
    //"There cannot be more than one species of a given <speciesType> in the "
    //"same compartment of a model. More formally, for any given compartment, "
    //"there cannot be more than one <species> definition in which both of the "
    //"following hold simultaneously: (i) the <species>' 'compartment' value "
    //"is set to that compartment's identifier and (ii) the <species>' "
    //"'speciesType' is set the same value as the 'speciesType' of another "
    //"<species> that also sets its 'compartment' to that compartment "
    //"identifier. (References: L2V2 Section 4.8.2; L2V3 Section 4.8.2)"
    "The compartment '";

  msg += c.getId();
  msg += "' contains more than one species with species type '";
  msg += s.getSpeciesType();
  msg += "'.";

  
  logFailure(s);
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
