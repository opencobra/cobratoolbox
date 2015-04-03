/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    EqualityArgsMathCheck.cpp
 * @brief   Ensures arguments to eq and neq are consistent.
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

#include <sbml/units/UnitFormulaFormatter.h>

#include "EqualityArgsMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "The values of all arguments to 'eq' and 'neq' operators should have the "
    "same type (either all boolean or all numeric). (References: L2V2 "
    "Section 3.5.8.)";


/*
 * Creates a new Constraint with the given @p id.
 */
EqualityArgsMathCheck::EqualityArgsMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
EqualityArgsMathCheck::~EqualityArgsMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
EqualityArgsMathCheck::getPreamble ()
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
EqualityArgsMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  ASTNodeType_t type = node.getType();

  /* check arguments of eq or neq */
  switch (type) 
  {
    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_NEQ:

      checkArgs(m, node, sb);
      break;


    case AST_FUNCTION:

      checkFunction(m, node, sb);
      break;

    default:

      checkChildren(m, node, sb);
      break;

  }
}

  
/*
  * Checks that the arguments to eq or neq are consistent
  * i.e. have same type both boolean or both numeric
  *
  * If an inconsistency is found, an error message is logged.
  */
void 
EqualityArgsMathCheck::checkArgs (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb)
{
  /* check that node has two children */
  if (node.getNumChildren() != 2)
  {
    return;
  }

  /* arguments must return consistent value types */
  if (returnsNumeric(m, node.getLeftChild()) && 
     !returnsNumeric(m, node.getRightChild()))
  {
    logMathConflict(node, sb);
  }
  else if (node.getLeftChild()->isBoolean() && 
          !node.getRightChild()->isBoolean())
  {
    logMathConflict(node, sb);
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
EqualityArgsMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();
  char * formula = SBML_formulaToString(&node);
  msg << "\nThe formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " uses arguments that should be either both numeric or both boolean.";
  safe_free(formula);

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
