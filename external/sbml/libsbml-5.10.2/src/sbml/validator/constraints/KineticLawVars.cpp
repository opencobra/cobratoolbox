/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    KineticLawVars.cpp
 * @brief   Ensures FunctionDefinitions contain no undefined variables.
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
#include <sbml/util/List.h>
#include <sbml/math/ASTNode.h>

#include <sbml/ModifierSpeciesReference.h>

#include "KineticLawVars.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
KineticLawVars::KineticLawVars (unsigned int id, Validator& v) :
  TConstraint<Reaction>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
KineticLawVars::~KineticLawVars ()
{
}


/*
 * Checks that all variables referenced in FunctionDefinition bodies are
 * bound variables (function arguments).
 */
void
KineticLawVars::check_ (const Model& m, const Reaction& r)
{
  unsigned int n;
  
  /* create list of all species in the reaction */
  for (n = 0; n < r.getNumReactants(); n++)
  {
    mSpecies.append(r.getReactant(n)->getSpecies());
  }
  for (n = 0; n < r.getNumProducts(); n++)
  {
    mSpecies.append(r.getProduct(n)->getSpecies());
  }
  for (n = 0; n < r.getNumModifiers(); n++)
  {
    mSpecies.append(r.getModifier(n)->getSpecies());
  }

  if ( r.isSetKineticLaw() && r.getKineticLaw()->isSetMath() )
  {
    const ASTNode* math  = r.getKineticLaw()->getMath();
    List*    names = math->getListOfNodes( ASTNode_isName );

    for (n = 0; n < names->getSize(); ++n)
    {
      ASTNode*    node = static_cast<ASTNode*>( names->get(n) );
      string   name = node->getName() ? node->getName() : "";

      if (m.getSpecies(name) != NULL && !mSpecies.contains(name) )
        logUndefined(r, name);
    }
    delete names;
  }

  mSpecies.clear();
}


/*
 * Logs a message about an undefined variable in the given
 * FunctionDefinition.
 */
void
KineticLawVars::logUndefined ( const Reaction& r,
                                       const string& varname )
{
  msg =
    //"All species referenced in the <kineticLaw> formula of a given reaction "
    //"must first be declared using <speciesReference> or "
    //"<modifierSpeciesReference>. More formally, if a <species> identifier "
    //"appears in a 'ci' element of a <reaction>'s <kineticLaw> formula, that "
    //"same identifier must also appear in at least one <speciesReference> or "
    //"<modifierSpeciesReference> in the <reaction> definition. (References: "
    //"L2V2 Section 4.13.5; L2V3 Section 4.13.5.)"
    "The species '";

  msg += varname;
  msg += "' is not listed as a product, reactant, or modifier of reaction '";
  msg += r.getId();
  msg += "'.";
  
  logFailure(r);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
