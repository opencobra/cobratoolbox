/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ArgumentsUnitsCheckWarnings.cpp
 * @brief   Ensures math units are consistent.
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

#include "ArgumentsUnitsCheckWarnings.h"

static const char* PREAMBLE =
    "The units of the expressions used as arguments to a function call must "
    "match the units expected for the arguments of that function. "
    "(References: L2V2 Section 3.5.) ";

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
ArgumentsUnitsCheckWarnings::ArgumentsUnitsCheckWarnings (unsigned int id, Validator& v) : UnitsBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
ArgumentsUnitsCheckWarnings::~ArgumentsUnitsCheckWarnings ()
{
}

/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
ArgumentsUnitsCheckWarnings::getPreamble ()
{
  return PREAMBLE;
}




/*
  * Checks that the units of the result of the assignment rule
  * are consistent with variable being assigned
  *
  * If an inconsistent variable is found, an error message is logged.
  */
void
ArgumentsUnitsCheckWarnings::checkUnits (const Model& m, const ASTNode& node, 
                                         const SBase & sb,
                                 bool inKL, int reactNo)
{
  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    /* functions that take a single dimensionless argument */
    /* inverse hyerbolic functions */
    case AST_FUNCTION_ARCCOSH:
    case AST_FUNCTION_ARCCOTH:
    case AST_FUNCTION_ARCCSCH:
    case AST_FUNCTION_ARCSECH:
    case AST_FUNCTION_ARCSINH:
    case AST_FUNCTION_ARCTANH:
    
    /* inverse trig functions */
    case AST_FUNCTION_ARCCOS:
    case AST_FUNCTION_ARCCOT:
    case AST_FUNCTION_ARCCSC:
    case AST_FUNCTION_ARCSEC:
    case AST_FUNCTION_ARCSIN:
    case AST_FUNCTION_ARCTAN: 
  
    /* hyperbolic functions */
    case AST_FUNCTION_COSH:
    case AST_FUNCTION_COTH:
    case AST_FUNCTION_CSCH:
    case AST_FUNCTION_SECH:
    case AST_FUNCTION_SINH:
    case AST_FUNCTION_TANH: 

    /* trigonometry functions */
    case AST_FUNCTION_COS:
    case AST_FUNCTION_COT:
    case AST_FUNCTION_CSC:
    case AST_FUNCTION_SEC:
    case AST_FUNCTION_SIN:
    case AST_FUNCTION_TAN: 

    /* logarithmic functions */
    case AST_FUNCTION_EXP:
    case AST_FUNCTION_LN:
    case AST_FUNCTION_LOG:

    case AST_FUNCTION_FACTORIAL:

      checkDimensionlessArgs(m, node, sb, inKL, reactNo);
      break;

    case AST_FUNCTION:

      checkFunction(m, node, sb, inKL, reactNo);
      break;

    default:

      checkChildren(m, node, sb, inKL, reactNo);
      break;

  }
}

  
/*
  * Checks that the units of the arguments 
  * of the function are dimensionless
  * and that there is only one argument
  *
  * If inconsistent units are found, an error message is logged.
  */
void 
ArgumentsUnitsCheckWarnings::checkDimensionlessArgs (const Model& m, 
                                           const ASTNode& node, 
                                           const SBase & sb, 
                                           bool inKL, int reactNo)
{
  /* check that node has children */
  if (node.getNumChildren() == 0)
  {
    return;
  }

  UnitDefinition *dim = new UnitDefinition(m.getSBMLNamespaces());
  Unit *unit = new Unit(m.getSBMLNamespaces());
  unit->setKind(UNIT_KIND_DIMENSIONLESS);
  unit->initDefaults();
  UnitDefinition * tempUD;
  dim->addUnit(unit);
  
  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  tempUD = unitFormat->getUnitDefinition(node.getChild(0), inKL, reactNo);
  
  if (tempUD->getNumUnits() != 0 && 
    ( unitFormat->getContainsUndeclaredUnits() == false &&
    UnitDefinition::areEquivalent(dim, tempUD) == false))
  {
    logInconsistentDimensionless(node, sb);
  }

  delete tempUD;
  delete dim;
  delete unit;
  delete unitFormat;

}

/*
 * @return the error message to use when logging constraint violations.
 * This method is called by logFailure.
 *
 * Returns a message that the given @p id and its corresponding object are
 * in  conflict with an object previously defined.
 */
const string
ArgumentsUnitsCheckWarnings::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * formula = SBML_formulaToString(&node);
  msg << "The formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " produces an exponent that is not an integer and thus may produce ";
  msg << "invalid units.";
  safe_free(formula);

  return msg.str();
}

/*
* Logs a message about a function that should have dmensionless
* as the arguments
*/
void 
ArgumentsUnitsCheckWarnings::logInconsistentDimensionless (const ASTNode & node, 
                                                 const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula ";
  msg += formula;
  msg += "' in the math element of the ";
  msg += getTypename(sb);
  msg += " uses a function ";
  msg += " which can only act on dimensionless variables.";
  safe_free(formula);

  logFailure(sb, msg);

}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */

