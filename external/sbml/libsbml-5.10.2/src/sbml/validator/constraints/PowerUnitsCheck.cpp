/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    PowerUnitsCheck.cpp
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
#include <sbml/SBMLTransforms.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/util/IdList.h>

#include <sbml/units/UnitFormulaFormatter.h>

#include <sbml/util/List.h>
#include <sbml/util/util.h>

#include "PowerUnitsCheck.h"


/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
  "A math expression using power with non-integer units may result in incorrect units.";


/*
 * Creates a new Constraint with the given @p id.
 */
PowerUnitsCheck::PowerUnitsCheck (unsigned int id, Validator& v) : UnitsBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
PowerUnitsCheck::~PowerUnitsCheck ()
{
}

/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
PowerUnitsCheck::getPreamble ()
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
PowerUnitsCheck::checkUnits (const Model& m, const ASTNode& node, const SBase & sb,
                                 bool inKL, int reactNo)
{
  ASTNodeType_t type = node.getType();

  switch (type) 
  {
    //case AST_DIVIDE:
    //  checkForPowersBeingDivided(m, node, sb);
    //  break;
    case AST_POWER:
    case AST_FUNCTION_POWER:

      checkUnitsFromPower(m, node, sb, inKL, reactNo);
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
 * The two arguments to power, which are of the form power(a, b) 
 * with the meaning a^b, should be as follows: 
 * (1) if the second argument is an integer, 
 *     then the first argument can have any units; 
 * (2) if the second argument b is a rational number n/m, 
 * it must be possible to derive the m-th root of (a{unit})n,
 * where {unit} signifies the units associated with a; 
 * otherwise, (3) the units of the first argument must be 'dimensionless'. 
 * The second argument (b) should always have units of 'dimensionless'.
 *
 */
void 
PowerUnitsCheck::checkUnitsFromPower (const Model& m, 
                                        const ASTNode& node, 
                                        const SBase & sb, bool inKL, int reactNo)
{

  /* check that node has 2 children */
  if (node.getNumChildren() != 2)
  {
    return;
  }

  double value;
  UnitDefinition dim(m.getSBMLNamespaces());
  Unit unit(m.getSBMLNamespaces());
  unit.setKind(UNIT_KIND_DIMENSIONLESS);
  unit.initDefaults();
  dim.addUnit(&unit);

  UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);

  UnitDefinition *tempUD = NULL;
  UnitDefinition *unitsArg1, *unitsArgPower;
  unitsArg1 = unitFormat->getUnitDefinition(node.getLeftChild(), inKL, reactNo);
  unsigned int undeclaredUnits = 
    unitFormat->getContainsUndeclaredUnits();

  ASTNode *child = node.getRightChild();
  unitFormat->resetFlags();
  unitsArgPower = unitFormat->getUnitDefinition(child, inKL, reactNo);

  unsigned int undeclaredUnitsPower = 
    unitFormat->getContainsUndeclaredUnits();

  // The second argument (b) should always have units of 'dimensionless'.
  // or it has undeclared units that we assume are correct

  if (undeclaredUnitsPower == 0 && !UnitDefinition::areEquivalent(&dim, unitsArgPower))
  {
    logNonDimensionlessPowerConflict(node, sb);
  }

  // The first argument is dimensionless then it doesnt matter 
  // what the power is

  if (undeclaredUnits == 0 && !UnitDefinition::areEquivalent(&dim, unitsArg1))
  {
    // if not argument needs to be an integer or a rational 
    unsigned int isInteger = 0;
    unsigned int isRational = 0;
    unsigned int isExpression = 0;
    /* power must be an integer
     * but need to check that it is not a real
     * number that is integral
     * i.e. mathml <cn> 2 </cn> will record a "real"
     */
    if (child->isRational())
    {
      isRational = 1;
    }
    else if (child->isInteger())
    {
      isInteger = 1;
    }
    else if (child->isReal())
    {
      if (ceil(child->getReal()) == child->getReal())
      {
        isInteger = 1;
      }
    }
    else if (child->getNumChildren() > 0)

    {
      // power might itself be an expression
      tempUD = unitFormat->getUnitDefinition(child, inKL, reactNo);
      UnitDefinition::simplify(tempUD);

      if (tempUD->isVariantOfDimensionless())
      {
        SBMLTransforms::mapComponentValues(&m);
        double value = SBMLTransforms::evaluateASTNode(child);
        SBMLTransforms::clearComponentValues();
        if (!util_isNaN(value))
        {
          if (floor(value) != value)
            isExpression = 1;
          else
            isInteger = 1;
        }
        else
        {
          isExpression = 1;
        }
      }
      else
      {
        /* here the child is an expression with units
        * flag the expression as not checked
        */
        isExpression = 1;
      }
    }
    else 
    {
      // power could be a parameter or a speciesReference in l3
      const Parameter *param = NULL;
      const SpeciesReference *sr = NULL;

      if (child->isName())
      {
        /* Parameters may be declared in two places (the model and the
        * kinetic law's local parameter list), so we have to check both.
        */

        if (sb.getTypeCode() == SBML_KINETIC_LAW)
        {
	        const KineticLaw* kl = dynamic_cast<const KineticLaw*>(&sb);

	        /* First try local parameters and if null is returned, try
	        * the global parameters */
	        if (kl != NULL)
	        {
	          param = kl->getParameter(child->getName());
	        }
        }

	      if (param == NULL)
	      {
	        param = m.getParameter(child->getName());
	      }

        if (param == NULL && m.getLevel() > 2)
        {
          // could be a species reference
          sr = m.getSpeciesReference(child->getName());
        }
        
      }

      if (param != NULL)
      {
        /* We found a parameter with this identifier. */

        if (UnitDefinition::areEquivalent(&dim, unitsArgPower) || undeclaredUnitsPower)
        {
          value = param->getValue();
          if (value != 0)
          {
            if (ceil(value) == value)
            {
              isInteger = 1;
            }
          }

        }
        else
        {
	  /* No parameter definition found for child->getName() */
          logUnitConflict(node, sb);
        }
      }
      else if (sr != NULL)
      {
        // technically here there is an issue
        // stoichiometry is dimensionless
        SBMLTransforms::mapComponentValues(&m);
        double value = SBMLTransforms::evaluateASTNode(child, &m);
        SBMLTransforms::clearComponentValues();
        // but it may not be an integer
        if (util_isNaN(value))
          // we cant check
        {
          isExpression = 1;
        }
        else
        {
          if (ceil(value) == value)
          {
            isInteger = 1;
          }
        }
      }
    }

    if (isRational == 1)
    {
      //FIX-ME will need sorting for double exponents

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
    else if (isExpression == 1)
    {
      logExpressionPowerConflict(node, sb);
    }
    else if (isInteger == 0)
    {
      logNonIntegerPowerConflict(node, sb);
    }

  }




 // if (!areEquivalent(dim, unitsPower)) 
 // {
 //   /* 'v' does not have units of dimensionless. */

 //   /* If the power 'n' is a parameter, check if its units are either
 //    * undeclared or declared as dimensionless.  If either is the case,
 //    * the value of 'n' must be an integer.
 //    */

 //   const Parameter *param = NULL;

 //   if (child->isName())
 //   {
 //     /* Parameters may be declared in two places (the model and the
 //      * kinetic law's local parameter list), so we have to check both.
 //      */

 //     if (sb.getTypeCode() == SBML_KINETIC_LAW)
 //     {
	//      const KineticLaw* kl = dynamic_cast<const KineticLaw*>(&sb);

	//      /* First try local parameters and if null is returned, try
	//      * the global parameters */
	//      if (kl != NULL)
	//      {
	//        param = kl->getParameter(child->getName());
	//      }
 //     }

	//    if (param == NULL)
	//    {
	//      param = m.getParameter(child->getName());
	//    }
 //     
 //   }

 //   if (param != NULL)
 //   {
 //     /* We found a parameter with this identifier. */

 //     if (areEquivalent(dim, unitsArgPower) || unitFormat->hasUndeclaredUnits(child))
 //     {
 //       value = param->getValue();
 //       if (value != 0)
 //       {
 //         if (ceil(value) != value)
 //         {
 //           logUnitConflict(node, sb);
 //         }
 //       }

 //     }
 //     else
 //     {
	///* No parameter definition found for child->getName() */
 //       logUnitConflict(node, sb);
 //     }
 //   }
 //   else if (child->isFunction() || child->isOperator())
 //   {
 //     /* cannot test whether the value will be appropriate */
 //     if (!areEquivalent(dim, unitsArgPower))
 //     {
 //       logUnitConflict(node, sb);
 //     }
 //   }
 //   /* power must be an integer
 //    * but need to check that it is not a real
 //    * number that is integral
 //    * i.e. mathml <cn> 2 </cn> will record a "real"
 //    */
 //   else if (!child->isInteger())
 //   {
 //     if (!child->isReal()) 
 //     {
 //       logUnitConflict(node, sb);
 //     }
 //     else if (ceil(child->getReal()) != child->getReal())
 //     {
 //       logUnitConflict(node, sb);
 //     }
 //   }
 // }
 // else if (!areEquivalent(dim, unitsArgPower)) 
 // {
 //   /* power (3, k) */
 //   logUnitConflict(node, sb);
 // }

  checkUnits(m, *node.getLeftChild(), sb, inKL, reactNo);

  delete unitFormat;
  delete unitsArg1;
  delete unitsArgPower;
}


/*
 * @return the error message to use when logging constraint violations.
 * This method is called by logFailure.
 *
 * Returns a message that the given @p id and its corresponding object are
 * in  conflict with an object previously defined.
 */
const string
PowerUnitsCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * formula = SBML_formulaToString(&node);
  msg << "The formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " contains a power that is not an integer and thus may produce ";
  msg << "invalid units.";
  safe_free(formula);

  return msg.str();
}


//void 
//PowerUnitsCheck::checkForPowersBeingDivided (const Model& m, const ASTNode& node, 
//                              const SBase & sb)
//{
//  ASTNode* left = node.getLeftChild();
//  ASTNode* right = node.getRightChild();
//
//  if (left->getType() == AST_POWER || left->getType() == AST_FUNCTION_POWER)
//  {
//    if (right->getType() == AST_POWER || right->getType() == AST_FUNCTION_POWER)
//    {
//      /* have a power divided by a power */
//      /* check whether objects have same units */
//        UnitFormulaFormatter *unitFormat = new UnitFormulaFormatter(&m);
//
//        UnitDefinition *tempUD, *tempUD1, *tempUD2, *tempUD3;
//        tempUD = unitFormat->getUnitDefinition(left->getLeftChild());
//        tempUD1 = unitFormat->getUnitDefinition(right->getLeftChild());
//        tempUD2 = unitFormat->getUnitDefinition(right->getRightChild());
//        tempUD3 = unitFormat->getUnitDefinition(left->getRightChild());
//
//        if (!areEquivalent(tempUD, tempUD1))
//        {
//          checkChildren(m, node, sb);
//        }
//        else
//        {
//          if(!areEquivalent(tempUD2, tempUD3))
//          {
//            logUnitConflict(node, sb);
//          }
//          else
//          {
//            /* create an ASTNode with pow(object, left_exp - right_exp) */
//            ASTNode *newPower = new ASTNode(AST_POWER);
//            ASTNode * newMinus = new ASTNode(AST_MINUS);
//            newMinus->addChild(left->getRightChild()->deepCopy());
//            newMinus->addChild(right->getRightChild()->deepCopy());
//            newPower->addChild(left->getLeftChild()->deepCopy());
//            newPower->addChild(newMinus);
//
//            checkUnitsFromPower(m, *newPower, sb);
//
//            delete newPower;
//          }
//        }
//
//        delete unitFormat;
//        delete tempUD;
//        delete tempUD1;
//        delete tempUD2;
//        delete tempUD3;
//    }
//    else
//    {
//      checkChildren(m, node, sb);
//    }
//  }
//  else 
//  {
//    checkChildren(m, node, sb);
//  }
//}
/*
 * Logs a message about a function that should return same units
 * as the arguments
 */
void 
PowerUnitsCheck::logNonDimensionlessPowerConflict (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '"; 
  msg += formula;
  msg += "' in the ";
  msg += getFieldname();
  msg += " element of the " ;
  msg += getTypename(sb);
  msg += " contains a power that is not dimensionless and thus may produce ";
  msg += "invalid units.";
  safe_free(formula);

  logFailure(sb, msg);

}


void 
PowerUnitsCheck::logNonIntegerPowerConflict (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '"; 
  msg += formula;
  msg += "' in the ";
  msg += getFieldname();
  msg += " element of the " ;
  msg += getTypename(sb);
  msg += " contains a power that is not an integer and thus may produce ";
  msg += "invalid units.";
  safe_free(formula);

  logFailure(sb, msg);

}

void 
PowerUnitsCheck::logRationalPowerConflict (const ASTNode & node, 
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
PowerUnitsCheck::logExpressionPowerConflict (const ASTNode & node, 
                                             const SBase & sb)
{
  char * formula = SBML_formulaToString(&node);
  msg = "The formula '"; 
  msg += formula;
  msg += "' in the ";
  msg += getFieldname();
  msg += " element of the " ;
  msg += getTypename(sb);
  msg += " contains an expression for the exponent of the power function ";
  msg += "and thus cannot be checked for unit validity.";

  
  safe_free(formula);
  
  logFailure(sb, msg);

}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */

