/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ArgumentsUnitsCheck.cpp
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

#include "ArgumentsUnitsCheck.h"

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
ArgumentsUnitsCheck::ArgumentsUnitsCheck (unsigned int id, Validator& v) : UnitsBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
ArgumentsUnitsCheck::~ArgumentsUnitsCheck ()
{
}

/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
ArgumentsUnitsCheck::getPreamble ()
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
ArgumentsUnitsCheck::checkUnits (const Model& m, const ASTNode& node, const SBase & sb,
                                 bool inKL, int reactNo)
{
  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    /* functions that act on same units */
    case AST_PLUS:
    case AST_MINUS:
    case AST_FUNCTION_ABS:
    case AST_FUNCTION_CEILING:
    case AST_FUNCTION_FLOOR:
    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_GEQ:
    case AST_RELATIONAL_GT:
    case AST_RELATIONAL_LEQ:
    case AST_RELATIONAL_LT:
    case AST_RELATIONAL_NEQ:
  
      checkSameUnitsAsArgs(m, node, sb, inKL, reactNo);
      break;

    case AST_FUNCTION_DELAY:

      checkUnitsFromDelay(m, node, sb, inKL, reactNo);
      break;

    case AST_FUNCTION_PIECEWISE:
      
      checkUnitsFromPiecewise(m, node, sb, inKL, reactNo);
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
  * Checks that the units of the delay function are consistent
  *
  * If inconsistent units are found, an error message is logged.
  */
void 
ArgumentsUnitsCheck::checkUnitsFromDelay (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb, bool inKL, int reactNo)
{
  /* check that node has two children */
  if (node.getNumChildren() != 2)
  {
    return;
  }

  if (!m.getSBMLNamespaces()->getNamespaces())
  {
#if 0
    cout << "[DEBUG] XMLNS IS NULL" << endl;
#endif
  }

  /* delay(x, t) 
   * no restrictions on units of x
   * but t must have units of time
   */
  UnitDefinition *time = new UnitDefinition(m.getSBMLNamespaces());
  Unit *unit = new Unit(m.getSBMLNamespaces());
  unit->setKind(UNIT_KIND_SECOND);
  unit->initDefaults();
  UnitDefinition * tempUD;
  time->addUnit(unit);
  
  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  tempUD = unitFormat->getUnitDefinition(node.getRightChild(), inKL, reactNo);
  
  if (!unitFormat->getContainsUndeclaredUnits())
  {
    if (!UnitDefinition::areEquivalent(time, tempUD)) 
    {
      logInconsistentDelay(node, sb);
    }
  }

  delete time;
  delete tempUD;
  delete unit;
  delete unitFormat;

  checkUnits(m, *node.getLeftChild(), sb, inKL, reactNo);
}
/*
  * Checks that the units of the piecewise function are consistent
  *
  * If inconsistent units are found, an error message is logged.
  */
void 
ArgumentsUnitsCheck::checkUnitsFromPiecewise (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb, bool inKL, int reactNo)
{
  /* check that node has children */
  if (node.getNumChildren() == 0)
  {
    return;
  }

  /* piecewise(a0, a1, a2, a3, ...)
   * a0 and a2, a(n_even) must have same units
   * a1, a3, a(n_odd) must be dimensionless
   */
  unsigned int n;
  UnitDefinition *dim = new UnitDefinition(m.getSBMLNamespaces());
  Unit *unit = new Unit(m.getSBMLNamespaces());
  unit->setKind(UNIT_KIND_DIMENSIONLESS);
  unit->initDefaults();
  UnitDefinition * tempUD;
  UnitDefinition * tempUD1 = NULL;
  dim->addUnit(unit);
  
  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  tempUD = unitFormat->getUnitDefinition(node.getChild(0), inKL, reactNo);

  for(n = 2; n < node.getNumChildren(); n+=2)
  {
    tempUD1 = unitFormat->getUnitDefinition(node.getChild(n), inKL, reactNo);
  
    if (!unitFormat->getContainsUndeclaredUnits())
    {
      if (!UnitDefinition::areEquivalent(tempUD, tempUD1)) 
      {
        logInconsistentPiecewise(node, sb);
      }
    }
    delete tempUD1;
  }

  delete tempUD;

  for(n = 1; n < node.getNumChildren(); n+=2)
  {
    tempUD = unitFormat->getUnitDefinition(node.getChild(n), inKL, reactNo);

    if (!UnitDefinition::areEquivalent(tempUD, dim)) 
    {
      logInconsistentPiecewiseCondition(node, sb);
    }
    delete tempUD;
  }
 
  delete dim;
  delete unit;
  delete unitFormat;

  for(n = 0; n < node.getNumChildren(); n++)
  {
    checkUnits(m, *node.getChild(n), sb, inKL, reactNo);
  }

}
/*
  * Checks that the units of the function are consistent
  * for a function returning value with same units as argument(s)
  *
  * If inconsistent units are found, an error message is logged.
  */
void 
ArgumentsUnitsCheck::checkSameUnitsAsArgs (const Model& m, 
                                              const ASTNode& node, 
                                              const SBase & sb, bool inKL, 
                                              int reactNo)
{
  /* check that node has children */
  if (node.getNumChildren() == 0)
  {
    return;
  }

  UnitDefinition * ud;
  UnitDefinition * tempUD = NULL;
  unsigned int n;
  unsigned int i = 0;
  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  ud = unitFormat->getUnitDefinition(node.getChild(i), inKL, reactNo);

  /* get the first child that is not a parameter with undeclared units */
  while (unitFormat->getContainsUndeclaredUnits() && 
    i < node.getNumChildren()-1)
  {
    delete ud; 
    i++;
    unitFormat->resetFlags();
    ud = unitFormat->getUnitDefinition(node.getChild(i), inKL, reactNo);
  }


  /* check that all children have the same units 
   * unless one of the children is a parameter with undeclared units 
   * which is not tested */
  for (n = i+1; n < node.getNumChildren(); n++)
  {
    unitFormat->resetFlags();
    tempUD = unitFormat->getUnitDefinition(node.getChild(n), inKL, reactNo);

    if (!unitFormat->getContainsUndeclaredUnits())
    {
      if (!UnitDefinition::areIdenticalSIUnits(ud, tempUD))
      {
        logInconsistentSameUnits(node, sb);
      }
    }
    delete tempUD;
  }

  delete unitFormat;
  delete ud;

  for (n = 0; n < node.getNumChildren(); n++)
  {
    checkUnits(m, *node.getChild(n), sb, inKL, reactNo);
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
ArgumentsUnitsCheck::getMessage (const ASTNode& node, const SBase& object)
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
* Logs a message about a function that should return same units
* as the arguments
*/
void 
ArgumentsUnitsCheck::logInconsistentSameUnits (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '" ;
  msg += formula;
  msg += "' in the math element of the ";
  msg += getTypename(sb);
  msg += " can only act on variables with the same units.";
  safe_free(formula);

  logFailure(sb, msg);

}

/*
* Logs a message about a delay function that should have time units
*/
void 
ArgumentsUnitsCheck::logInconsistentDelay (const ASTNode & node, 
                                          const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula ";
  msg += formula;
  msg += "' in the math element of the ";
  msg += getTypename(sb);
  msg += " uses a delay function";
  msg += " with a delta t value that does not have units of time.";
  safe_free(formula);

  logFailure(sb, msg);

}

/*
* Logs a message about a piecewise function that should same units
*/
void 
ArgumentsUnitsCheck::logInconsistentPiecewise (const ASTNode & node, 
                                          const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula ";
  msg += formula;
  msg += "' in the math element of the ";
  msg += getTypename(sb);
  msg += " uses a piecewise function";
  msg += " where different branches return different units.";
  safe_free(formula);

  logFailure(sb, msg);

}

/*
* Logs a message about the conditional part of a piecewise function 
* that should have dimensionless units
*/
void 
ArgumentsUnitsCheck::logInconsistentPiecewiseCondition (const ASTNode & node, 
                                          const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '";
  msg += formula;
  msg += "' in the math element of the ";
  msg += getTypename(sb);
  msg += " uses a piecewise function";
  msg += " where the conditional statement is not dimensionless.";
  safe_free(formula);

  logFailure(sb, msg);

}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

