/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdBase.cpp
 * @brief   Base class for Id constraints
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

#include "IdBase.h"
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/ModifierSpeciesReference.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN


/*
 * Creates a new IdBase with the given constraint id.
 */
IdBase::IdBase (unsigned int id, Validator& v) : TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
IdBase::~IdBase ()
{
}


/*
 * @return the fieldname to use logging constraint violations.  If not
 * overridden, "id" is returned.
 */
const char*
IdBase::getFieldname ()
{
  return "id";
}


/*
 * @return the preamble to use when logging constraint violations.  The
 * preamble will be prepended to each log message.  If not overriden,
 * returns an empty string.
 */
const char*
IdBase::getPreamble ()
{
  return "";
}


/*
 * Checks that all ids for some given subset of the Model adhere to this
 * Constraint.  Override the doCheck() method to define your own subset.
 */
void
IdBase::check_ (const Model& m, const Model& object)
{
  doCheck(m);
}


/*
 * These convenience methods simply wrap (delegate to) doCheckId(const
 * std::string&, const SBase& object).  This is necessary because getId()
 * is not (yet) defined on SBase for SBML objects.
 *
 * For Rules and EventAssignments, it calls getVariable() instead.
 */

/* id is no longer on SBase */
//void
//IdBase::checkId (const SBase& x)
//{
////  if (x.isSetId()) doCheckId(x.getId(), x);
//}


void
IdBase::checkId (const Model& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const FunctionDefinition& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const UnitDefinition& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const Compartment& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const Species& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const Parameter& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const Rule& x)
{
  switch (x.getTypeCode())
  {
    case SBML_ASSIGNMENT_RULE:
      doCheckId(static_cast<const AssignmentRule&>(x).getVariable(), x);
      break;

    case SBML_RATE_RULE:
      doCheckId(static_cast<const RateRule&>(x).getVariable(), x);
      break;

    default:
      break;
  }
}


void
IdBase::checkId (const Reaction& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const Event& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}


void
IdBase::checkId (const EventAssignment& x)
{
  if (x.isSetVariable()) doCheckId(x.getVariable(), x);
}


void
IdBase::checkId (const CompartmentType& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}

void
IdBase::checkId (const SpeciesType& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}

void
IdBase::checkId (const SpeciesReference& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}

void
IdBase::checkId (const ModifierSpeciesReference& x)
{
  if (x.isSetId()) doCheckId(x.getId(), x);
}

void
IdBase::checkId (const InitialAssignment& x)
{
  if (x.isSetSymbol()) doCheckId(x.getSymbol(), x);
}

/*
 * @return the typename of the given SBase object.
 */
const char*
IdBase::getTypename (const SBase& object)
{
  return SBMLTypeCode_toString( object.getTypeCode(), object.getPackageName().c_str() );
}


/*
 * Logs a message that the given @p id (and its corresponding object) have
 * failed to satisfy this constraint.
 */
void
IdBase::logIdConflict (const std::string& id, const SBase& object)
{
  logFailure(object, getMessage(id, object));
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

