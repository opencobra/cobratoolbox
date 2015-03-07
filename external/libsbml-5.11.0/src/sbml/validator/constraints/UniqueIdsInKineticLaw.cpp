/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueIdsInKineticLaw.cpp
 * @brief   Ensures the ids for all Parameters in a KineticLaw are unique
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
#include <sbml/Reaction.h>
#include <sbml/KineticLaw.h>
#include <sbml/Parameter.h>

#include "UniqueIdsInKineticLaw.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "The value of the 'id' field of each parameter defined locally within a "
    "<kineticLaw> must be unique across the set of all such parameter "
    "definitions in that <kineticLaw>. (References: L2V2 Sections 3.4.1 and "
    "4.13.9; L2V1 Sections 3.4.1 and 4.13.5.)";


/*
 * Creates a new Constraint with the given constraint id.
 */
UniqueIdsInKineticLaw::UniqueIdsInKineticLaw (unsigned int id, Validator& v) :
  UniqueIdBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueIdsInKineticLaw::~UniqueIdsInKineticLaw ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
UniqueIdsInKineticLaw::getPreamble ()
{
  return PREAMBLE;
}


/*
 * Checks that all ids on KineticLawParameters are unique.
 */
void
UniqueIdsInKineticLaw::doCheck (const Model& m)
{
  for (unsigned int r = 0; r < m.getNumReactions(); ++r)
  {
    const KineticLaw* kl = m.getReaction(r)->getKineticLaw();
    if (kl == NULL) continue;

    for (unsigned int p = 0; p < kl->getNumParameters(); ++p)
    {
      checkId( *kl->getParameter(p) );
    }

    reset();
  }
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
