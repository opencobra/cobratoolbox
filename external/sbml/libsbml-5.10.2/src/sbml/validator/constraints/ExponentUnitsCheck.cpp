/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ExponentUnitsCheck.cpp
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

#include "ExponentUnitsCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
  "The use of non-integral exponents may result in incorrect units.";


/*
 * Creates a new Constraint with the given @p id.
 */
ExponentUnitsCheck::ExponentUnitsCheck (unsigned int id, Validator& v) : UnitsBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
ExponentUnitsCheck::~ExponentUnitsCheck ()
{
}

/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
ExponentUnitsCheck::getPreamble ()
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
ExponentUnitsCheck::checkUnits (const Model& m, const ASTNode& node, const SBase & sb,
                                 bool inKL, int reactNo)
{
  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    case AST_FUNCTION_ROOT:

      checkUnitsFromRoot(m, node, sb, inKL, reactNo);
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
  * Checks that the units of the power function are consistent
  *
  * If inconsistent units are found, an error message is logged.
  *
  * The two arguments to root, which are of the form root(n, a) 
  * where the degree n is optional (defaulting to '2'), should be as follows: 
  * (1) if the optional degree qualifier n is an integer, 
  * then it must be possible to derive the n-th root of a; 
  * (2) if the optional degree qualifier n is a rational n/m 
  * then it must be possible to derive the n-th root of (a{unit})m, 
  * where {unit} signifies the units associated with a; 
  * otherwise, (3) the units of a must be 'dimensionless'.  
  */
void 
ExponentUnitsCheck::checkUnitsFromRoot (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb, bool inKL, int reactNo)
{
  /* check that node has 2 children */
  if (node.getNumChildren() != 2)
  {
    return;
  }

  UnitDefinition dim(m.getSBMLNamespaces());
  Unit unit(m.getSBMLNamespaces());
  unit.setKind(UNIT_KIND_DIMENSIONLESS);
  unit.initDefaults();
  dim.addUnit(&unit);
  /* root (v, n) = v^1/n 
   * the exponent of the resulting unit must be integral
   */

  int root = 1;
  UnitDefinition * unitsArg1;
  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  unitsArg1 = unitFormat->getUnitDefinition(node.getLeftChild(), inKL, reactNo);
  unsigned int undeclaredUnits = 
    unitFormat->getContainsUndeclaredUnits();
  ASTNode * child = node.getRightChild();
   
  // The first argument is dimensionless then it doesnt matter 
  // what the root is

  if (undeclaredUnits == 0 && !UnitDefinition::areEquivalent(&dim, unitsArg1))
  {
    // if not argument needs to be an integer or a rational 
    unsigned int isInteger = 0;
    unsigned int isRational = 0;

    if (child->isRational())
    {
      isRational = 1;
    }
    else if (child->isInteger())
    {
      isInteger = 1;
      root = (int)child->getInteger();
    }
    else if (child->isReal())
    {
      if (ceil(child->getReal()) == child->getReal())
      {
        isInteger = 1;
        root = (int) child->getReal();
      }
      else
      {
        logNonIntegerPowerConflict(node, sb);
      }
    }
    else 
    {
      logUnitConflict(node, sb);
    }

    if (isRational == 1)
    {
      //* (2) if the second argument b is a rational number n/m, 
      //* it must be possible to derive the m-th root of (a{unit})n,
      //* where {unit} signifies the units associated with a; 
      unsigned int impossible = 0;
      for (unsigned int n = 0; impossible == 0 && n < unitsArg1->getNumUnits(); n++)
      {
        if ((int)(unitsArg1->getUnit(n)->getExponent()) * child->getInteger() %
          child->getDenominator() != 0)
          impossible = 1;
      }

      if (impossible)
        logRationalPowerConflict(node, sb);

    }
    else if (isInteger == 1)
    {
      unsigned int impossible = 0;
      for (unsigned int n = 0; impossible == 0 && n < unitsArg1->getNumUnits(); n++)
      {
        if ((int)(unitsArg1->getUnit(n)->getExponent()) % root != 0)
          impossible = 1;
      }

      if (impossible)
        logNonIntegerPowerConflict(node, sb);
    }

  }

  ///* exponent must have integral form */
  //if (!child->isInteger())
  //{
  //  if (!child->isReal()) 
  //  {
  //    logUnitConflict(node, sb);
  //  }
  //  else if (ceil(child->getReal()) != child->getReal())
  //  {
  //    logUnitConflict(node, sb);
  //  }
  //  else 
  //  {
  //    root = (int) child->getReal();
  //  }
  //}
  //else
  //{
  //  root = child->getInteger();
  //}
  //
  //for (n = 0; n < tempUD->getNumUnits(); n++)
  //{
  //  if (tempUD->getUnit(n)->getExponent() % root != 0)
  //  {
  //    logUnitConflict(node, sb);
  //  }
  //}

  checkUnits(m, *node.getLeftChild(), sb);

  delete unitFormat;
  delete unitsArg1;
}


/*
 * @return the error message to use when logging constraint violations.
 * This method is called by logFailure.
 *
 * Returns a message that the given @p id and its corresponding object are
 * in  conflict with an object previously defined.
 */
const string
ExponentUnitsCheck::getMessage (const ASTNode& node, const SBase& object)
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

void 
ExponentUnitsCheck::logRationalPowerConflict (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '"; 
  msg += formula;
  msg += "' in the ";
  msg += getFieldname();
  msg += " element of the " ;
  msg += getTypename(sb);
  msg += " contains a rational power that is inconsistent and thus may produce ";
  msg += "invalid units.";
  safe_free(formula);

  logFailure(sb, msg);

}

void 
ExponentUnitsCheck::logNonIntegerPowerConflict (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '"; 
  msg += formula;
  msg += "' in the ";
  msg += getFieldname();
  msg += " element of the " ;
  msg += getTypename(sb);
  msg += " contains a root that is not an integer and thus may produce ";
  msg += "invalid units.";
  safe_free(formula);

  logFailure(sb, msg);

}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

