/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    NumericArgsMathCheck.cpp
 * @brief   Ensures arguments to numeric operators/functions are consistent.
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

#include "NumericArgsMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "The arguments to the following MathML constructs must have a numeric "
    "type: 'plus', 'minus', 'times', 'divide', 'power', 'root', 'abs', "
    "'exp', 'ln', 'log', 'floor', 'ceiling', 'factorial', 'sin', 'cos', "
    "'tan', 'sec', 'csc', 'cot', 'sinh', 'cosh', 'tanh', 'sech', 'csch', "
    "'coth', 'arcsin', 'arccos', 'arctan', 'arcsec', 'arccsc', 'arccot', "
    "'arcsinh', 'arccosh', 'arctanh', 'arcsech', 'arccsch', 'arccoth'. "
    "(References: L2V2 Section 3.5.8.)";


/*
 * Creates a new Constraint with the given @p id.
 */
NumericArgsMathCheck::NumericArgsMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
NumericArgsMathCheck::~NumericArgsMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
NumericArgsMathCheck::getPreamble ()
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
NumericArgsMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    case AST_PLUS:
    case AST_MINUS:
    case AST_TIMES:
    case AST_DIVIDE:
    case AST_POWER:
    case AST_FUNCTION_POWER:
    case AST_FUNCTION_ROOT:
    case AST_FUNCTION_ABS:
    case AST_FUNCTION_EXP:
    case AST_FUNCTION_LN:
    case AST_FUNCTION_LOG:
    case AST_FUNCTION_CEILING:
    case AST_FUNCTION_FLOOR:
    case AST_FUNCTION_FACTORIAL:
    case AST_FUNCTION_COS:
    case AST_FUNCTION_COT:
    case AST_FUNCTION_CSC:
    case AST_FUNCTION_SEC:
    case AST_FUNCTION_SIN:
    case AST_FUNCTION_TAN: 
    case AST_FUNCTION_COSH:
    case AST_FUNCTION_COTH:
    case AST_FUNCTION_CSCH:
    case AST_FUNCTION_SECH:
    case AST_FUNCTION_SINH:
    case AST_FUNCTION_TANH: 
    case AST_FUNCTION_ARCCOSH:
    case AST_FUNCTION_ARCCOTH:
    case AST_FUNCTION_ARCCSCH:
    case AST_FUNCTION_ARCSECH:
    case AST_FUNCTION_ARCSINH:
    case AST_FUNCTION_ARCTANH:
    case AST_FUNCTION_ARCCOS:
    case AST_FUNCTION_ARCCOT:
    case AST_FUNCTION_ARCCSC:
    case AST_FUNCTION_ARCSEC:
    case AST_FUNCTION_ARCSIN:
    case AST_FUNCTION_ARCTAN: 

      checkNumericArgs(m, node, sb);
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
 * Checks that the arguments of numeric functions are consistent
 *
 * If not, an error message is logged.
 */
void 
NumericArgsMathCheck::checkNumericArgs (const Model& m, const ASTNode& node, 
                                               const SBase & sb)
{
  unsigned int n;
  
  for (n = 0; n < node.getNumChildren(); n++)
  {
    if (!returnsNumeric(m, node.getChild(n)))
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
NumericArgsMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * formula = SBML_formulaToString(&node);
  msg << "\nThe formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " uses an argument to a operator that expects a numeric value.";
  safe_free(formula);

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

