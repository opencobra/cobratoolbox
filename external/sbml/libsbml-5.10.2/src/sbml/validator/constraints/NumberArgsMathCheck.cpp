/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    NumberArgsMathCheck.cpp
 * @brief   Ensures number of arguments to functions are appropriate.
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

#include "NumberArgsMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "A MathML operator must be supplied the number of arguments "
    "appropriate for that operator. (References: SBML L2v3 Section 3.4.1.)";


/*
 * Creates a new Constraint with the given @p id.
 */
NumberArgsMathCheck::NumberArgsMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
NumberArgsMathCheck::~NumberArgsMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
NumberArgsMathCheck::getPreamble ()
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
NumberArgsMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  ASTNodeType_t type = node.getType();

  switch (type) 
  {
  case AST_FUNCTION_ABS:
  case AST_FUNCTION_ARCCOS:
  case AST_FUNCTION_ARCCOSH:
  case AST_FUNCTION_ARCCOT:
  case AST_FUNCTION_ARCCOTH:
  case AST_FUNCTION_ARCCSC:
  case AST_FUNCTION_ARCCSCH:
  case AST_FUNCTION_ARCSEC:
  case AST_FUNCTION_ARCSECH:
  case AST_FUNCTION_ARCSIN:
  case AST_FUNCTION_ARCSINH:
  case AST_FUNCTION_ARCTAN:
  case AST_FUNCTION_ARCTANH:
  case AST_FUNCTION_CEILING:
  case AST_FUNCTION_COS:
  case AST_FUNCTION_COSH:
  case AST_FUNCTION_COT:
  case AST_FUNCTION_COTH:
  case AST_FUNCTION_CSC:
  case AST_FUNCTION_CSCH:
  case AST_FUNCTION_EXP:
  case AST_FUNCTION_FACTORIAL:
  case AST_FUNCTION_FLOOR:
  case AST_FUNCTION_LN:
  case AST_FUNCTION_SEC:
  case AST_FUNCTION_SECH:
  case AST_FUNCTION_SIN:
  case AST_FUNCTION_SINH:
  case AST_FUNCTION_TAN:
  case AST_FUNCTION_TANH:
  case AST_LOGICAL_NOT:

    checkUnary(m, node, sb);
      break;

    case AST_DIVIDE:
    case AST_POWER:
    case AST_RELATIONAL_NEQ:
    case AST_FUNCTION_DELAY:
    case AST_FUNCTION_POWER:
    case AST_FUNCTION_LOG:       // a log ASTNode has a child for base

    checkBinary(m, node, sb);
      break;

      //n-ary 0 or more arguments
    case AST_TIMES:
    case AST_PLUS:
    case AST_LOGICAL_AND:
    case AST_LOGICAL_OR:
    case AST_LOGICAL_XOR:
      checkChildren(m, node, sb);
      break;

    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_GEQ:
    case AST_RELATIONAL_GT:
    case AST_RELATIONAL_LEQ:
    case AST_RELATIONAL_LT:
      checkAtLeast2Args(m, node, sb);
      break;

    case AST_FUNCTION_PIECEWISE:
      checkPiecewise(m, node, sb);
      break;


    case AST_FUNCTION_ROOT:
    case AST_MINUS:
      
      checkSpecialCases(m, node, sb);
      break;

      
    case AST_FUNCTION:
      /* the case for a functionDefinition has its own rule
         from l2v4*/

      if (m.getLevel() < 3 && m.getVersion() < 4)
      {
        if (m.getFunctionDefinition(node.getName()) != NULL)
        {
          /* functiondefinition math */
          const ASTNode * fdMath = m.getFunctionDefinition(node.getName())->getMath();
          if (fdMath != NULL)
          {
          /* We have a definition for this function.  Does the defined number
	            of arguments equal the number used here? */

            if (node.getNumChildren() + 1 != fdMath->getNumChildren())
	          {
              logMathConflict(node, sb);
	          }
          }

        }
      }
      break;

    default:

      checkChildren(m, node, sb);
      break;

  }

}

/*
  * Checks that the function has only one argument
  */
void NumberArgsMathCheck::checkUnary(const Model& m, 
                                     const ASTNode& node, const SBase & sb)
{
  if (node.getNumChildren() != 1)
  {
    logMathConflict(node, sb);
  }
  else
  {
    checkMath(m, *node.getLeftChild(), sb);
  }
}

/*
  * Checks that the function has exactly two arguments
  */
void NumberArgsMathCheck::checkBinary(const Model& m, 
                                      const ASTNode& node, const SBase & sb)
{
  if (node.getNumChildren() != 2)
  {
    logMathConflict(node, sb);
  }

  for (unsigned int n = 0; n < node.getNumChildren(); n++)
  {
    checkMath(m, *node.getChild(n), sb);
  }
}

/*
  * Checks that the functions have either one or two arguments
  */
void NumberArgsMathCheck::checkSpecialCases(const Model& m, 
                                            const ASTNode& node, const SBase & sb)
{
  if (node.getNumChildren() < 1 || node.getNumChildren() > 2)
  {
    logMathConflict(node, sb);
  }

  for (unsigned int n = 0; n < node.getNumChildren(); n++)
  {
    checkMath(m, *node.getChild(n), sb);
  }
}

/*
  * Checks that the function has at least two arguments
  */
void NumberArgsMathCheck::checkAtLeast2Args(const Model& m, 
                                    const ASTNode& node, const SBase & sb)
{
  if (node.getNumChildren() < 2)
  {
    logMathConflict(node, sb);
  }

  for (unsigned int n = 0; n < node.getNumChildren(); n++)
  {
    checkMath(m, *node.getChild(n), sb);
  }
}

  
void NumberArgsMathCheck::checkPiecewise(const Model& m, 
                                    const ASTNode& node, const SBase & sb)
{
  if (node.getNumChildren() == 0)
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
NumberArgsMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * formula = SBML_formulaToString(&node);
  msg << "\nThe formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " has an inappropriate number of arguments.";
  safe_free(formula);

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

