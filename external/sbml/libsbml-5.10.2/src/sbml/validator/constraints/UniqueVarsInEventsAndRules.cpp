/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueVarsInEventsAndRules.cpp
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

#include <sbml/Model.h>
#include <sbml/Rule.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>

#include "UniqueVarsInEventsAndRules.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "An identifier used as the value of 'variable' in an <eventAssignment> "
    "cannot also appear as the value of 'variable' in an <assignmentRule>. "
    "(References: L2V1 Section 4.10.5; L2V2 Section 4.14.)";


/*
 * Creates a new Constraint with the given constraint id.
 */
UniqueVarsInEventsAndRules::UniqueVarsInEventsAndRules (unsigned int id, Validator& v) :
  UniqueIdBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueVarsInEventsAndRules::~UniqueVarsInEventsAndRules ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
UniqueVarsInEventsAndRules::getPreamble ()
{
  return PREAMBLE;
}


/*
 * Checks that all ids on the following Model objects are unique:
 * event assignments and assignment rules.
 */
void
UniqueVarsInEventsAndRules::doCheck (const Model& m)
{
  unsigned int n, ea, nr;

  for (n = 0; n < m.getNumEvents(); ++n)
  {
    const Event* e = m.getEvent(n);

    /* for each event assignment check that the variable is not used
     * in an assignment rule 
     * needs to be this way to avoid logging an error for
     * repeated use of a variable in event assignments (904)
     */
    for (ea = 0; ea < e->getNumEventAssignments(); ++ea)
    {
      checkId( *e->getEventAssignment(ea) );
     
      for (nr = 0; nr < m.getNumRules(); ++nr) 
      {
        const Rule* r = m.getRule(nr);

        if (r->isAssignment()) {
          checkId( *m.getRule(nr) );
        }
      }

      mIdObjectMap.clear();
    }
  }  
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

