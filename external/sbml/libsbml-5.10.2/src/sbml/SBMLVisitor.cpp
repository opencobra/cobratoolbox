/**
 * @file   SBMLVisitor.cpp
 * @brief  Visitor Design Pattern for the SBML object tree  
 * @author Ben Bornstein
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

#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/ModifierSpeciesReference.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

SBMLVisitor::~SBMLVisitor ()
{
}


void
SBMLVisitor::visit (const SBMLDocument& x)
{
  visit( static_cast<const SBase&>(x) );
}


void
SBMLVisitor::visit (const Model& x)
{
  visit( static_cast<const SBase&>(x) );
}


void
SBMLVisitor::visit (const KineticLaw& x)
{
  visit( static_cast<const SBase&>(x) );
}


void
SBMLVisitor::visit (const Priority& x)
{
  visit( static_cast<const SBase&>(x) );
}


void
SBMLVisitor::visit (const ListOf& x, int type)
{
  visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const SBase& sb)
{
  return false;
}


bool
SBMLVisitor::visit (const FunctionDefinition& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const UnitDefinition& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Unit& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const CompartmentType& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const SpeciesType& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Compartment& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Species& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Parameter& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const InitialAssignment& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Rule& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const AlgebraicRule& x)
{
  return visit( static_cast<const Rule&>(x) );
}


bool
SBMLVisitor::visit (const AssignmentRule& x)
{
  return visit( static_cast<const Rule&>(x) );
}


bool
SBMLVisitor::visit (const RateRule& x)
{
  return visit( static_cast<const Rule&>(x) );
}


bool
SBMLVisitor::visit (const Constraint& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Reaction& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const SimpleSpeciesReference& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const SpeciesReference& x)
{
  return visit( static_cast<const SimpleSpeciesReference&>(x) );
}


bool
SBMLVisitor::visit (const ModifierSpeciesReference& x)
{
  return visit( static_cast<const SimpleSpeciesReference&>(x) );
}


bool
SBMLVisitor::visit (const Event& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const EventAssignment& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Trigger& x)
{
  return visit( static_cast<const SBase&>(x) );
}


bool
SBMLVisitor::visit (const Delay& x)
{
  return visit( static_cast<const SBase&>(x) );
}


void
SBMLVisitor::leave (const SBMLDocument& x)
{
}


void
SBMLVisitor::leave (const Model& x)
{
}


void
SBMLVisitor::leave (const KineticLaw& x)
{
}


void
SBMLVisitor::leave (const Priority& x)
{
}


void
SBMLVisitor::leave (const Reaction& x)
{
}


void
SBMLVisitor::leave (const SBase& x)
{
}


void
SBMLVisitor::leave (const ListOf& x, int type)
{
}

#endif /* __cplusplus */


/** @cond doxygenIgnored */

/** @endcond */
LIBSBML_CPP_NAMESPACE_END
