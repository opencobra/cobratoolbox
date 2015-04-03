/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    PiecewiseValueMathCheck.cpp
 * @brief   Ensures types returned by branches of a piecewise are consistent.
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

#include "PiecewiseValueMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "The types of values within 'piecewise' operators should all be "
    "consistent: the set of expressions that make up the first arguments of "
    "the 'piece' and 'otherwise' operators within the same 'piecewise' "
    "operator should all return values of the same type. (References: L2V2 "
    "Section 3.5.8.)";


/*
 * Creates a new Constraint with the given @p id.
 */
PiecewiseValueMathCheck::PiecewiseValueMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
PiecewiseValueMathCheck::~PiecewiseValueMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
PiecewiseValueMathCheck::getPreamble ()
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
PiecewiseValueMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    case AST_FUNCTION_PIECEWISE:

      checkPiecewiseArgs(m, node, sb);
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
 * Checks that the arguments of the branches of a piecewise are consistent
 *
 * If not, an error message is logged.
 */
void 
PiecewiseValueMathCheck::checkPiecewiseArgs (const Model& m, const ASTNode& node, 
                                                  const SBase & sb)
{
  unsigned int numChildren = node.getNumChildren();

  /* arguments must return consistent types */
  for (unsigned int n = 0; n < numChildren; n += 2)
  {
    if (returnsNumeric(m, node.getChild(n)) && 
      !returnsNumeric(m, node.getLeftChild()))
    {
      logMathConflict(node, sb);
    }
    else if (node.getChild(n)->isBoolean() && 
            !node.getLeftChild()->isBoolean())
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
PiecewiseValueMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * left = SBML_formulaToString(node.getLeftChild());
  msg << "\nThe piecewise formula ";
  msg << "in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " returns arguments" ;
  msg << " which have different value types from the first element '";
  msg << left << "'."; 
  safe_free(left);

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
