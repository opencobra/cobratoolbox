/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    LocalParameterMathCheck.cpp
 * @brief   checks &lt;ci&gt; element of local parameter not used elsewhere
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
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/UnitDefinition.h>
#include <sbml/Event.h>
#include <sbml/Reaction.h>
#include <sbml/EventAssignment.h>
#include <sbml/SpeciesReference.h>
#include <sbml/Rule.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/units/UnitFormulaFormatter.h>

#include "LocalParameterMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

static const char* PREAMBLE =
    "The 'id' value of a <parameter> defined within a <kineticLaw> can only "
    "be used in 'ci' elements within the MathML content of that same "
    "<kineticLaw>; the identifier is not visible to other parts of the "
    "model. (References: L2V2 Section 3.5.3.)";


/*
 * Creates a new Constraint with the given @p id.
 */
LocalParameterMathCheck::LocalParameterMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
LocalParameterMathCheck::~LocalParameterMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
LocalParameterMathCheck::getPreamble ()
{
  return PREAMBLE;
}


/*
  * Checks the MathML of the ASTnode 
  * is appropriate for the function being performed
  *
  * If an inconsistency is found, an error message is logged.
  */
void
LocalParameterMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  ASTNodeType_t type = node.getType();
    
  /* if the node is a &lt;ci&gt; element it will have type AST_NAME
   * check that this name is an appropriate component of the model */
    
  switch (type) 
  {
    case AST_NAME:

      checkCiElement(m, node, sb);
      break;

    default:

      checkChildren(m, node, sb);
      break;

  }
}

  
/*
  * Checks any &lt;ci&gt; elements in the MathML of the ASTnode 
  * contain the id of an appropriate component of the model
  *
  * If an inconsistency is found, an error message is logged.
  */
void 
LocalParameterMathCheck::checkCiElement (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb)
{
  std::string name = node.getName();
  const KineticLaw * kl;

  if (m.getCompartment(name) == NULL &&
      m.getSpecies(name)     == NULL &&
      m.getParameter(name)   == NULL &&
      m.getReaction(name)    == NULL)
  {

    /* check whether we are in a kinetic law since there
     * may be local parameters to this law that are allowed
     */

    if (sb.getTypeCode() == SBML_KINETIC_LAW)
    {
      kl = m.getReaction(mKLCount)->getKineticLaw();

      if (kl->getParameter(name) == NULL && mLocalParameters.contains(name))
      {
        logMathConflict(node, sb);
      }
    }
    else if (mLocalParameters.contains(name))
    {
        logMathConflict(node, sb);
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
LocalParameterMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  msg << "\nThe formula '";
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " uses '" << node.getName() << "' that is the id of a local parameter.";

  return msg.str();
}

#endif /* __cplusplus */

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

