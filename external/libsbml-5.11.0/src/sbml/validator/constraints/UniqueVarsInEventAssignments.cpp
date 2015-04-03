/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueVarsInEventAssignments.cpp
 * @brief   Ensures variables within a set of EventAssignments are unique
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
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>

#include "UniqueVarsInEventAssignments.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "In each <event>, the value of the 'variable' field within every "
    "<eventAssignment> definition must be unique across the set of all "
    "<eventAssignment>s within that <event>. (References: L2V1 erratum 17; "
    "L2V2 Section 4.14.)";


/*
 * Creates a new Constraint with the given constraint id.
 */
UniqueVarsInEventAssignments::UniqueVarsInEventAssignments ( unsigned int id,
                                                             Validator& v ) :
  UniqueIdBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueVarsInEventAssignments::~UniqueVarsInEventAssignments ()
{
}


/*
 * @return the fieldname ("variable") to use when logging constraint
 * violations.
 */
const char*
UniqueVarsInEventAssignments::getFieldname ()
{
  return "variable";
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
UniqueVarsInEventAssignments::getPreamble ()
{
  return PREAMBLE;
}


/*
 * Checks that all ids on KineticLawParameters are unique.
 */
void
UniqueVarsInEventAssignments::doCheck (const Model& m)
{
  for (unsigned int n = 0; n < m.getNumEvents(); ++n)
  {
    const Event* e = m.getEvent(n);

    for (unsigned int ea = 0; ea < e->getNumEventAssignments(); ++ea)
    {
      checkId( *e->getEventAssignment(ea) );
    }

    mIdObjectMap.clear();
  }
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
