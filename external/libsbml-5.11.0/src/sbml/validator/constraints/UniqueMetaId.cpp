/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueMetaId.cpp
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

#include "UniqueMetaId.h"
#include <sbml/SBMLDocument.h>
#include <sbml/ModifierSpeciesReference.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "Every 'metaid' attribute value must be unique across the set of all "
    "'metaid' values in a model. (References: L2V2 Sections 3.3.1 and "
    "3.1.6.)";


/*
 * Creates a new UniqueMetaId with the given constraint id.
 */
UniqueMetaId::UniqueMetaId (unsigned int id, Validator& v) : TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
UniqueMetaId::~UniqueMetaId ()
{
}


/*
 * @return the fieldname to use logging constraint violations.  If not
 * overridden, "metaid" is returned.
 */
const char*
UniqueMetaId::getFieldname ()
{
  return "metaid";
}


/*
 * @return the preamble to use when logging constraint violations.  The
 * preamble will be prepended to each log message.  If not overriden,
 * returns an empty string.
 */
const char*
UniqueMetaId::getPreamble ()
{
  return PREAMBLE;
}


/*
 * Checks that all ids for some given subset of the Model adhere to this
 * Constraint.  Override the doCheck() method to define your own subset.
 */
void
UniqueMetaId::check_ (const Model& m, const Model& object)
{
  doCheck(m);
}


/*
 * @return the typename of the given SBase object.
 */
const char*
UniqueMetaId::getTypename (const SBase& object)
{
  return SBMLTypeCode_toString( object.getTypeCode(), object.getPackageName().c_str() );
}


/*
 * Logs a message that the given @p id (and its corresponding object) have
 * failed to satisfy this constraint.
 */
void
UniqueMetaId::logIdConflict (const std::string& id, const SBase& object)
{
  logFailure(object, getMessage(id, object));
}

/*
 * Resets the state of this GlobalConstraint by clearing its internal
 * list of error messages.
 */
void
UniqueMetaId::reset ()
{
  mMetaIdObjectMap.clear();
}


/*
 * Checks that the id associated with the given object is unique.  If it
 * is not, logIdConflict is called.
 */
void
UniqueMetaId::doCheckMetaId (const SBase& object)
{ 
  if (object.isSetMetaId())
  {
    const string& id = object.getMetaId();

    if (mMetaIdObjectMap.insert( make_pair(id, &object) ).second == false)
    {
      logIdConflict(id, object);
    }
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
UniqueMetaId::getMessage (const string& id, const SBase& object)
{
  IdObjectMap::iterator iter = mMetaIdObjectMap.find(id);


  if (iter == mMetaIdObjectMap.end())
  {
    return
      "Internal (but non-fatal) Validator error in "
      "UniqueMetaId::getMessage().  The SBML object with duplicate id was "
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
/*
 * Checks that all ids on the following Model objects are unique:
 * FunctionDefinitions, Species, Compartments, global Parameters,
 * Reactions, and Events.
 */
void
UniqueMetaId::doCheck (const Model& m)
{
  unsigned int n, size, j, num;

  /* check any metaid on the sbml container */
  doCheckMetaId(*m.getSBMLDocument());

  doCheckMetaId( m );

  size = m.getNumFunctionDefinitions();
  if (size > 0) doCheckMetaId(*m.getListOfFunctionDefinitions());
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getFunctionDefinition(n) );

  size = m.getNumUnitDefinitions();
  if (size > 0) doCheckMetaId(*m.getListOfUnitDefinitions());
  for (n = 0; n < size; ++n) 
  {
    const UnitDefinition *ud = m.getUnitDefinition(n);
    doCheckMetaId( *ud );
    num = ud->getNumUnits();
    if (num > 0) doCheckMetaId(*ud->getListOfUnits());
    for (j = 0; j < num; j++)
    {
      doCheckMetaId(*ud->getUnit(j));
    }
  }

  size = m.getNumCompartmentTypes();
  if (size > 0) doCheckMetaId(*m.getListOfCompartmentTypes());
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getCompartmentType(n) );

  size = m.getNumSpeciesTypes();
  if (size > 0) doCheckMetaId(*m.getListOfSpeciesTypes());
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getSpeciesType(n) );

  size = m.getNumCompartments();
  if (size > 0) doCheckMetaId(*m.getListOfCompartments());
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getCompartment(n) );

  size = m.getNumSpecies();
  if (size > 0) doCheckMetaId(*m.getListOfSpecies());
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getSpecies(n) );

  size = m.getNumParameters();
  if (size > 0) doCheckMetaId(*m.getListOfParameters()); 
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getParameter(n) );

  size = m.getNumInitialAssignments();
  if (size > 0) doCheckMetaId(*m.getListOfInitialAssignments()); 
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getInitialAssignment(n) );

  size = m.getNumRules();
  if (size > 0) doCheckMetaId(*m.getListOfRules()); 
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getRule(n) );

  size = m.getNumConstraints();
  if (size > 0) doCheckMetaId(*m.getListOfConstraints()); 
  for (n = 0; n < size; ++n) doCheckMetaId( *m.getConstraint(n) );

  size = m.getNumReactions();
  if (size > 0) doCheckMetaId(*m.getListOfReactions()); 
  for (n = 0; n < size; ++n) 
  {
    const Reaction *r = m.getReaction(n);
    doCheckMetaId( *r );

    if (r->isSetKineticLaw())
    {
      doCheckMetaId(*r->getKineticLaw());
      num = r->getKineticLaw()->getNumParameters();
      if (num > 0) doCheckMetaId(*r->getKineticLaw()->getListOfParameters());
      for (j = 0; j < num; j++)
      {
        doCheckMetaId(*r->getKineticLaw()->getParameter(j));
      }
    }

    num = r->getNumReactants();
    if (num > 0) doCheckMetaId(*r->getListOfReactants());
    for (j = 0; j < num; j++)
    {
      doCheckMetaId(*r->getReactant(j));
    }

    num = r->getNumProducts();
    if (num > 0) doCheckMetaId(*r->getListOfProducts());
    for (j = 0; j < num; j++)
    {
      doCheckMetaId(*r->getProduct(j));
    }

    num = r->getNumModifiers();
    if (num > 0) doCheckMetaId(*r->getListOfModifiers());
    for (j = 0; j < num; j++)
    {
      doCheckMetaId(*r->getModifier(j));
    }
  }

  size = m.getNumEvents();
  if (size > 0) doCheckMetaId(*m.getListOfEvents()); 
  for (n = 0; n < size; ++n) 
  {
    const Event *e = m.getEvent(n);
    doCheckMetaId( *e );
 
    if (e->isSetTrigger())
    {
      doCheckMetaId( *e->getTrigger());
    }

    if (e->isSetDelay())
    {
      doCheckMetaId( *e->getDelay());
    }

    num = e->getNumEventAssignments();
    if (num > 0) doCheckMetaId(*e->getListOfEventAssignments());
    for (j = 0; j < num; j++)
    {
      doCheckMetaId(*e->getEventAssignment(j));
    }
  }

  reset();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
