/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    DuplicateTopLevelAnnotation.cpp
 * @brief   Checks for duplicate top level annotations
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
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/Rule.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>

#include "DuplicateTopLevelAnnotation.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN


/*
 * Creates a new Constraint with the given constraint id.
 */
DuplicateTopLevelAnnotation::DuplicateTopLevelAnnotation (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
DuplicateTopLevelAnnotation::~DuplicateTopLevelAnnotation ()
{
}


/*
 * Checks whether all annotations have duplicate top level namespaces
 */
void
DuplicateTopLevelAnnotation::check_ (const Model& m, const Model& object)
{
  /* check the annotations on each object */

  unsigned int n, i;
  if (object.isSetAnnotation())
  {
    checkAnnotation(static_cast <const SBase &> (object));
  }
  if (object.getNumFunctionDefinitions() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfFunctionDefinitions())));
    for (n = 0; n < object.getNumFunctionDefinitions(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getFunctionDefinition(n))));
    }
  }
  if (object.getNumUnitDefinitions() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfUnitDefinitions())));
    for (n = 0; n < object.getNumUnitDefinitions(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getUnitDefinition(n))));
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getUnitDefinition(n)->getListOfUnits())));
      for (i = 0; i < object.getUnitDefinition(n)->getNumUnits(); i++)
      {
        checkAnnotation(static_cast <const SBase &> 
                      (*(object.getUnitDefinition(n)->getUnit(i))));
      }
    }
  }
  if (object.getNumCompartmentTypes() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfCompartmentTypes())));
    for (n = 0; n < object.getNumCompartmentTypes(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getCompartmentType(n))));
    }
  }
  if (object.getNumSpeciesTypes() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfSpeciesTypes())));
    for (n = 0; n < object.getNumSpeciesTypes(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getSpeciesType(n))));
    }
  }
  if (object.getNumCompartments() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfCompartments())));
    for (n = 0; n < object.getNumCompartments(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getCompartment(n))));
    }
  }
  if (object.getNumSpecies() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfSpecies())));
    for (n = 0; n < object.getNumSpecies(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getSpecies(n))));
    }
  }
  if (object.getNumParameters() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfParameters())));
    for (n = 0; n < object.getNumParameters(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getParameter(n))));
    }
  }
  if (object.getNumInitialAssignments() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfInitialAssignments())));
    for (n = 0; n < object.getNumInitialAssignments(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getInitialAssignment(n))));
    }
  }
  if (object.getNumRules() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfRules())));
    for (n = 0; n < object.getNumRules(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getRule(n))));
    }
  }
  if (object.getNumConstraints() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfConstraints())));
    for (n = 0; n < object.getNumConstraints(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getConstraint(n))));
    }
  }
  if (object.getNumReactions() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfReactions())));
    for (n = 0; n < object.getNumReactions(); n++)
    {
      const Reaction *r = object.getReaction(n);
      checkAnnotation(static_cast <const SBase &> (*(r)));
      if (r->getNumReactants() > 0)
      {
        checkAnnotation(static_cast <const SBase &> 
                             (*(r->getListOfReactants())));
        for (i = 0; i < r->getNumReactants(); i++)
        {
          checkAnnotation(static_cast <const SBase &> 
                             (*(r->getReactant(i))));
        }
      }
      if (r->getNumProducts() > 0)
      {
        checkAnnotation(static_cast <const SBase &> 
                             (*(r->getListOfProducts())));
        for (i = 0; i < r->getNumProducts(); i++)
        {
          checkAnnotation(static_cast <const SBase &> 
                             (*(r->getProduct(i))));
        }
      }
      if (r->getNumModifiers() > 0)
      {
        checkAnnotation(static_cast <const SBase &> 
                             (*(r->getListOfModifiers())));
        for (i = 0; i < r->getNumModifiers(); i++)
        {
          checkAnnotation(static_cast <const SBase &> 
                             (*(r->getModifier(i))));
        }
      }
      if (r->isSetKineticLaw())
      {
        checkAnnotation(static_cast <const SBase &> 
                             (*(r->getKineticLaw())));
        if (r->getKineticLaw()->getNumParameters() > 0)
        {
          checkAnnotation(static_cast <const SBase &> 
                              (*(r->getKineticLaw()->getListOfParameters())));
          for (i = 0; i < r->getKineticLaw()->getNumParameters(); i++)
          {
            checkAnnotation(static_cast <const SBase &> 
                           (*(r->getKineticLaw()->getParameter(i))));
          }
        }
      }
    }
  }
  if (object.getNumEvents() > 0)
  {
    checkAnnotation(static_cast <const SBase &> 
                    (*(object.getListOfEvents())));
    for (n = 0; n < object.getNumEvents(); n++)
    {
      checkAnnotation(static_cast <const SBase &> 
                    (*(object.getEvent(n))));

      if (object.getEvent(n)->getNumEventAssignments() > 0)
      {
        checkAnnotation(static_cast <const SBase &> 
                      (*(object.getEvent(n)->getListOfEventAssignments())));
        for (i = 0; i < object.getEvent(n)->getNumEventAssignments(); i++)
        {
          checkAnnotation(static_cast <const SBase &> 
                        (*(object.getEvent(n)->getEventAssignment(i))));
        }
      }
    }
  }
}

/*
  * Check the annotation
  */
void DuplicateTopLevelAnnotation::checkAnnotation(const SBase & object)
{
  const XMLNode * ann = (const_cast <SBase &> (object)).getAnnotation();

  if (ann == NULL) return;

  mNamespaces.clear();
  for (unsigned int i = 0; i < ann->getNumChildren(); i++)
  {
    std::string name = ann->getChild(i).getPrefix();

    if (mNamespaces.contains(name))
    {
      logDuplicate(name, object);
    }
    else
    {
      mNamespaces.append(name);
    }
  }
}

/*
  * Logs a message about dupliacte top level annotations.
  */
void
DuplicateTopLevelAnnotation::logDuplicate (std::string name, const SBase& object )
{

  msg = "The namespaces '";
  msg += name;
  msg += "' is duplicated within the annotation of the ";
  msg += SBMLTypeCode_toString( object.getTypeCode(), object.getPackageName().c_str() );
  msg += " with id '";
  msg += object.getId();
  msg += "'.";

  
  logFailure(object);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
