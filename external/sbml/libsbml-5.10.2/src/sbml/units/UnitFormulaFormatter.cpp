/** 
 *@cond doxygenLibsbmlInternal 
 **
 * @file    UnitFormulaFormatter.cpp
 * @brief   Formats an AST formula tree as a unit definition
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/units/UnitFormulaFormatter.h>
#include <sbml/SBMLTransforms.h>
#include <sbml/util/util.h>
#include <sbml/util/IdList.h>



LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus
/*
 *  constructs a UnitFormulaFormatter
 */
UnitFormulaFormatter::UnitFormulaFormatter(const Model *m)
 : model(m)
{
  mContainsUndeclaredUnits = false;
  mCanIgnoreUndeclaredUnits = 2;
  depthRecursiveCall = 0;
}

/*
 *  destructor
 */
UnitFormulaFormatter::~UnitFormulaFormatter()
{
}

/*
  * visits the ASTNode and returns the unitDefinition of the formula
  * this function is really a dispatcher to the other
  * UnitFormulaFormatter::getUnitdefinition functions
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinition(const ASTNode * node, 
                                        bool inKL, int reactNo)
{  
  /** 
    * returns a copy of existing UnitDefinition* object (if any) that 
    * corresponds to a given ASTNode*. 
    * (This is for avoiding redundant recursive calls.)
    */

  std::map<const ASTNode*, UnitDefinition*>::iterator it = 
                                                unitDefinitionMap.find(node);
  if(it != unitDefinitionMap.end()) {
    return static_cast<UnitDefinition*>(it->second->clone());
  }

    
  UnitDefinition * ud = NULL;

  if (node == NULL)
  {
    return ud;
  }

  ++depthRecursiveCall;


  ASTNodeType_t type = node->getType();

  switch (type) 
  {
  /* functions that return a dimensionless result */
    case AST_FUNCTION_FACTORIAL:

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

    /* boolean */
    case AST_LOGICAL_AND:
    case AST_LOGICAL_NOT:
    case AST_LOGICAL_OR:
    case AST_LOGICAL_XOR:
    case AST_CONSTANT_FALSE:
    case AST_CONSTANT_TRUE:

    /* relational */
    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_GEQ:
    case AST_RELATIONAL_GT:
    case AST_RELATIONAL_LEQ:
    case AST_RELATIONAL_LT:
    case AST_RELATIONAL_NEQ:

      ud = getUnitDefinitionFromDimensionlessReturnFunction
                                                        (node, inKL, reactNo);
      break;

  /* functions that return same units */
    case AST_PLUS:
    case AST_MINUS:
    case AST_FUNCTION_ABS:
    case AST_FUNCTION_CEILING:
    case AST_FUNCTION_FLOOR:
  
      ud = getUnitDefinitionFromArgUnitsReturnFunction(node, inKL, reactNo);
      break;

  /* power functions */
    case AST_POWER:
    case AST_FUNCTION_POWER:
  
      ud = getUnitDefinitionFromPower(node, inKL, reactNo);
      break;

  /* times functions */
    case AST_TIMES:
  
      ud = getUnitDefinitionFromTimes(node, inKL, reactNo);
      break;

  /* divide functions */
    case AST_DIVIDE:
  
      ud = getUnitDefinitionFromDivide(node, inKL, reactNo);
      break;

  /* piecewise functions */
    case AST_FUNCTION_PIECEWISE:
  
      ud = getUnitDefinitionFromPiecewise(node, inKL, reactNo);
      break;

  /* root functions */
    case AST_FUNCTION_ROOT:
  
      ud = getUnitDefinitionFromRoot(node, inKL, reactNo);
      break;

  /* functions */
    case AST_LAMBDA:
    case AST_FUNCTION:
  
      ud = getUnitDefinitionFromFunction(node, inKL, reactNo);
      break;
    
  /* delay */
    case AST_FUNCTION_DELAY:
  
      ud = getUnitDefinitionFromDelay(node, inKL, reactNo);
      break;

    //  /* new types */
    //case AST_QUALIFIER_DEGREE:
    //case AST_QUALIFIER_LOGBASE:

    //  ud = getUnitDefinition(node->getChild(0), inKL, reactNo);
    //  break;

  /* others */

    /* numbers */
    case AST_INTEGER:
    case AST_REAL:
    case AST_REAL_E:
    case AST_RATIONAL:

    /* time */
    case AST_NAME_TIME:

    /* constants */
    case AST_CONSTANT_E:
    case AST_CONSTANT_PI:

    /* name of another component in the model */
    case AST_NAME:

      ud = getUnitDefinitionFromOther(node, inKL, reactNo);
      break;

    case AST_UNKNOWN:
    default:
    
      if (node->isQualifier() == true)
      {
        /* code so that old and new ast classes will do the right thing */
        ud = getUnitDefinition(node->getChild(0), inKL, reactNo);
      }
      else
      {
        ud = new UnitDefinition(model->getSBMLNamespaces());
      }
      break;
  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  // dont simplify an empty ud
  if (ud->getNumUnits() > 1)
    UnitDefinition::simplify(ud);

  --depthRecursiveCall;

  if ( depthRecursiveCall != 0 )
  {
    if (unitDefinitionMap.end() == unitDefinitionMap.find(node))
    {
      /* adds a pair of ASTNode* (node) and 
         UnitDefinition* (ud) to the UnitDefinitionMap */
      unitDefinitionMap.insert(std::pair<const ASTNode*, 
        UnitDefinition*>(node,static_cast<UnitDefinition*>(ud->clone())));
      undeclaredUnitsMap.insert(std::pair<const ASTNode*, 
                                    bool>(node,mContainsUndeclaredUnits));
      canIgnoreUndeclaredUnitsMap.insert(std::pair<const ASTNode*, 
                           unsigned int>(node,mCanIgnoreUndeclaredUnits));
    }
  }
  else
  {
    /** 
      * Clears two map objects because all recursive call has finished.
      */ 
    std::map<const ASTNode*, UnitDefinition*>::iterator it = 
                                                unitDefinitionMap.begin();
    while( it != unitDefinitionMap.end() )
    {
      delete it->second;
      ++it;
    }
    unitDefinitionMap.clear();
    undeclaredUnitsMap.clear();
    canIgnoreUndeclaredUnitsMap.clear();
  }

  /* if something is returned with an empty unitDefinition
   * it means not all units could be determined
   */
  if (ud->getNumUnits() == 0)
  {
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
  }

  return ud;
}


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from a function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromFunction(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  unsigned int i, nodeCount;
  Unit * unit;
  ASTNode * fdMath;
  // ASTNode *newMath;
  //bool needDelete = false;
  unsigned int noBvars;

  if(node->getType() == AST_FUNCTION)
  {
    const FunctionDefinition *fd = 
                               model->getFunctionDefinition(node->getName());
    if (fd && fd->isSetMath())
    {
      noBvars = fd->getNumArguments();
      if (noBvars == 0)
      {
        fdMath = fd->getMath()->getLeftChild()->deepCopy();
      }
      else
      {
        fdMath = fd->getMath()->getRightChild()->deepCopy();
      }

      for (i = 0, nodeCount = 0; i < noBvars; i++, nodeCount++)
      {
        if (nodeCount < node->getNumChildren())
          fdMath->replaceArgument(fd->getArgument(i)->getName(), 
                                            node->getChild(nodeCount));
      }
      ud = getUnitDefinition(fdMath, inKL, reactNo);
      delete fdMath;
    }
    else
    {
      ud = new UnitDefinition(model->getSBMLNamespaces());
    }
  }
  else
  {
    /**
     * function is a lambda function - which wont have any units
     */
    unit = new Unit(model->getSBMLNamespaces());
    unit->setKind(UNIT_KIND_DIMENSIONLESS);
    unit->initDefaults();
    ud   = new UnitDefinition(model->getSBMLNamespaces());
    
    ud->addUnit(unit);

    delete unit;
  }
  
  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from a times function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromTimes(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  UnitDefinition * tempUD;
  int numChildren = node->getNumChildren();
  int n = 0;
  unsigned int i;
  unsigned int currentIgnore = mCanIgnoreUndeclaredUnits;

  if (numChildren == 0)
  {
    /* times with no arguments is the identity which is 1 dimensionless */
    Unit * u = new Unit(model->getSBMLNamespaces());
    u->initDefaults();
    u->setKind(UNIT_KIND_DIMENSIONLESS);
    ud = new UnitDefinition(model->getSBMLNamespaces());
    ud->addUnit(u);
    delete u;
  }
  else
  {
    ud = getUnitDefinition(node->getChild(n), inKL, reactNo);
    if (mCanIgnoreUndeclaredUnits == 0) currentIgnore = 0;

    if (ud)
    {
      for(n = 1; n < numChildren; n++)
      {
        tempUD = getUnitDefinition(node->getChild(n), inKL, reactNo);
        if (mCanIgnoreUndeclaredUnits == 0) currentIgnore = 0;
        for (i = 0; i < tempUD->getNumUnits(); i++)
        {
          ud->addUnit(tempUD->getUnit(i));
        }
        delete tempUD;
      }
    }
    else
    {
      ud = new UnitDefinition(model->getSBMLNamespaces());
    }
  }

  mCanIgnoreUndeclaredUnits = currentIgnore;
  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from a divide function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromDivide(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  UnitDefinition * tempUD;
  unsigned int i;
  Unit * unit;

  ud = getUnitDefinition(node->getLeftChild(), inKL, reactNo);

  if (node->getNumChildren() == 1)
    return ud;
  tempUD = getUnitDefinition(node->getRightChild(), inKL, reactNo);
  for (i = 0; i < tempUD->getNumUnits(); i++)
  {
    unit = tempUD->getUnit(i);
    /* dont change the exponent on a dimensionless unit */
    if (unit->getKind() != UNIT_KIND_DIMENSIONLESS)
      unit->setExponentUnitChecking(-1 * unit->getExponentUnitChecking());
    ud->addUnit(unit);
  }
  delete tempUD;

  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from a power function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromPower(const ASTNode * node,
                                                 bool inKL, int reactNo)
{ 
  unsigned int numChildren = node->getNumChildren();

  if (numChildren == 0 || numChildren > 2)
  {
    UnitDefinition * ud = new UnitDefinition(model->getSBMLNamespaces());
    return ud;
  }

  UnitDefinition * variableUD = getUnitDefinition(
                                       node->getLeftChild(), inKL, reactNo);

  if (numChildren == 1)
  {
    mContainsUndeclaredUnits = true;
    return variableUD;
  }

  // save the undeclared status of variable
  bool varHasUndeclared = mContainsUndeclaredUnits;
  unsigned int varCanIgnoreUndeclared = mCanIgnoreUndeclaredUnits;

  double exponentValue = 0.0;
  ASTNode * exponentNode = node->getRightChild();

  // is the exponent dimensionless or a number because if not it is a problem
  UnitDefinition* exponentUD = getUnitDefinition(exponentNode, inKL, reactNo);
  UnitDefinition::simplify(exponentUD);

  if (exponentNode->isInteger() == true ||
    exponentNode->isReal() == true ||
    exponentUD->isVariantOfDimensionless())
  {
    SBMLTransforms::mapComponentValues(model);
    exponentValue = SBMLTransforms::evaluateASTNode(node->getRightChild(), model);
    SBMLTransforms::clearComponentValues();

    for (unsigned int n = 0; n < variableUD->getNumUnits(); n++)
    {
      Unit * unit = variableUD->getUnit(n);
      unit->setExponentUnitChecking(exponentValue * unit->getExponentAsDouble());
    }

    // restore undeclared status as it should come from variable
    mContainsUndeclaredUnits = varHasUndeclared;
    mCanIgnoreUndeclaredUnits = varCanIgnoreUndeclared;
  }
  else
  {
    mContainsUndeclaredUnits = true;
  }

  return variableUD;

}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from 
  * a piecewise function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromPiecewise(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  unsigned int n = 0;
  UnitDefinition *tempUD1 = NULL;
  /* this is fine if all other return branches have units
   * but if there are undeclared units these get ignored
   */
  ud = getUnitDefinition(node->getLeftChild(), inKL, reactNo);
  
 /* piecewise(a0, a1, a2, a3, ...)
   * a0 and a2, a(n_even) must have same units
   * a1, a3, a(n_odd) must be dimensionless
   */
  while (!mContainsUndeclaredUnits && n < node->getNumChildren())
  {
    n+=2;
    tempUD1 = getUnitDefinition(node->getChild(n), inKL, reactNo);
  
    if (tempUD1) delete tempUD1;
  }


  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from a root function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromRoot(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
/* this only works is the exponent is an integer - 
   * since a unit can only have an integral exponent 
   * but the mathml might do something like
   * pow(sqrt(m) * 2, 2) - which would be okay
   * unless we challenge the sqrt(m) !!
   */

  UnitDefinition * tempUD;
  UnitDefinition *tempUD2 = NULL;
  unsigned int i;
  Unit * unit;
  ASTNode * child, * child1;

  tempUD = getUnitDefinition(node->getRightChild(), inKL, reactNo);
  ud = new UnitDefinition(model->getSBMLNamespaces());

  if (node->getNumChildren() == 1)
    return ud;

  child1 = node->getLeftChild();
  
  if (child1->isQualifier() == true)
  {
    child = child1->getChild(0);
  }
  else
  {
    child = node->getLeftChild();
  }

  for (i = 0; i < tempUD->getNumUnits(); i++)
  {
    unit = tempUD->getUnit(i);
    // if unit is dimensionless it doesnt matter 
    if (unit->getKind() != UNIT_KIND_DIMENSIONLESS)
    {
      // if fractional exponents are created flag not to check units
      if (child->isInteger()) 
      {
        double doubleExponent = 
                 double(unit->getExponent())/double(child->getInteger());
        //if (floor(doubleExponent) != doubleExponent)
        //  mContainsUndeclaredUnits = true;
        unit->setExponentUnitChecking(doubleExponent);
      }
      else if (child->isReal())
      {
        double doubleExponent = 
                            double(unit->getExponent())/child->getReal();
        //if (floor(doubleExponent) != doubleExponent)
        //  mContainsUndeclaredUnits = true;
        unit->setExponentUnitChecking(doubleExponent);
      }
      else
      {

        tempUD2 = getUnitDefinition(child, inKL, reactNo);
        UnitDefinition::simplify(tempUD2);

        if (tempUD2->isVariantOfDimensionless())
        {
          SBMLTransforms::mapComponentValues(model);
          double value = SBMLTransforms::evaluateASTNode(child);
          SBMLTransforms::clearComponentValues();
          if (!util_isNaN(value))
          {
            double doubleExponent = 
                                double(unit->getExponent())/value;
            //if (floor(doubleExponent) != doubleExponent)
              unit->setExponentUnitChecking(doubleExponent);
//              mContainsUndeclaredUnits = true;
//            unit->setExponentUnitChecking((int)(unit->getExponent()/value));
          }
          else
          {
            mContainsUndeclaredUnits = true;
          }
        }
        else
        {
          /* here the child is an expression with units
          * flag the expression as not checked
          */
          mContainsUndeclaredUnits = true;
        }
      }
    }
    ud->addUnit(unit);
  }

  delete tempUD;
  if (tempUD2 != NULL)
    delete tempUD2;

  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from 
  * a delay function
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromDelay(const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  
  ud = getUnitDefinition(node->getLeftChild(), inKL, reactNo);

  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from 
  * a function returning dimensionless value
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromDimensionlessReturnFunction(
                                const ASTNode *node, bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  Unit *unit;
    
  unit = new Unit(model->getSBMLNamespaces());
  unit->setKind(UNIT_KIND_DIMENSIONLESS);
  unit->initDefaults();
  ud   = new UnitDefinition(model->getSBMLNamespaces());
    
  ud->addUnit(unit);

  delete unit;

  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from 
  * a function returning value with same units as argument(s)
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromArgUnitsReturnFunction
                                       (const ASTNode * node, 
                                        bool inKL, int reactNo)
{ 
  UnitDefinition * ud;
  UnitDefinition * tempUd;
  unsigned int i = 0;
  unsigned int n = 0;
 
  /* save any existing value of undeclaredUnits/canIgnoreUndeclaredUnits */
  unsigned int originalIgnore = mCanIgnoreUndeclaredUnits;
  bool originalUndeclaredValue = mContainsUndeclaredUnits;
  unsigned int currentIgnore = mCanIgnoreUndeclaredUnits;
  bool currentUndeclared = mContainsUndeclaredUnits;

  /* get first arg that is not a parameter with undeclared units */
  ud = getUnitDefinition(node->getChild(i), inKL, reactNo);
  while (getContainsUndeclaredUnits() == true
    && i < node->getNumChildren()-1)
  {
    if (originalUndeclaredValue == true)
      currentIgnore = 0;
    else
      currentIgnore = 1;


    currentUndeclared = true;

    i++;
    delete ud;
    resetFlags();
    ud = getUnitDefinition(node->getChild(i), inKL, reactNo);
  }

  /* loop thru remain children to determine undeclaredUnit status */
  if (mContainsUndeclaredUnits && i == node->getNumChildren()-1)
  {
    /* all children are parameters with undeclared units */
    currentIgnore = 0;
  }
  else
  {
    for (n = i+1; n < node->getNumChildren(); n++)
    {
      resetFlags();
      tempUd = getUnitDefinition(node->getChild(n), inKL, reactNo);
      if (getContainsUndeclaredUnits())
      {
        currentUndeclared = true;
        currentIgnore = 1;
      }
      delete tempUd;
    }
  }

  /* restore original value of undeclaredUnits */
  if (node->getNumChildren() > 1)
  {
    mContainsUndeclaredUnits = currentUndeclared;
  }

  /* temporary HACK while I figure this out */
  if (originalIgnore == 2)
  {
    mCanIgnoreUndeclaredUnits = currentIgnore;
  }
  


  return ud;
}
/* @endcond */


/* @cond doxygenLibsbmlInternal */
/** 
  * returns the unitDefinition for the ASTNode from anything else
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromOther(const ASTNode * node,
    bool inKL, int reactNo)
{ 
  UnitDefinition * ud = NULL;
  const UnitDefinition * tempUd;
  Unit * unit;

  unsigned int n, found;
  double exponent;

  const KineticLaw * kl;

  /** 
   * ASTNode represents a number, a constant, TIME, DELAY, or
   * the name of another element of the model
   */

  if (node->isNumber())
  {
    /* in L3 a number can have units */
    if (node->isSetUnits())
    {
      std::string units = node->getUnits();
      if (UnitKind_isValidUnitKindString(units.c_str(), 
                          model->getLevel(), model->getVersion()))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName(units.c_str()));
        unit->initDefaults();
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        ud->addUnit(unit);
        delete unit;
      }
      else
      {
        tempUd = model->getUnitDefinition(units);
        if (tempUd != NULL)
        {
          ud   = new UnitDefinition(model->getSBMLNamespaces());
          
          for (n = 0; n < tempUd->getNumUnits(); n++)
          {
            ud->addUnit(tempUd->getUnit(n));
          }
        }

      }
    }
    else
    {
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      mContainsUndeclaredUnits = true;
      mCanIgnoreUndeclaredUnits = 0;
    }
  }
  else if (node->getType() == AST_CONSTANT_E)
  {
    ud   = new UnitDefinition(model->getSBMLNamespaces());
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
  }
  else if (node->getType() == AST_CONSTANT_PI)
  {
    unit = new Unit(model->getSBMLNamespaces());
    unit->setKind(UNIT_KIND_DIMENSIONLESS);
    unit->initDefaults();
    ud   = new UnitDefinition(model->getSBMLNamespaces());
    
    ud->addUnit(unit);
    delete unit;
  }
  else if (node->isName())
  {
    if (node->getType() == AST_NAME_TIME)
    {
      tempUd = model->getUnitDefinition("time");

      if (tempUd == NULL) 
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName("second"));
        unit->initDefaults();
        ud   = new UnitDefinition(model->getSBMLNamespaces());
        
        ud->addUnit(unit);

        delete unit;
      }
      else
      {
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        for (n = 0; n < tempUd->getNumUnits(); n++)
        {
          ud->addUnit(tempUd->getUnit(n));
        }
      }
    }
    /* must be the name of a compartment, species or parameter */
    else
    {
      found = 0;
      //n = 0;
      if (inKL)
      {
        if (model->getReaction(reactNo)->isSetKineticLaw())
        {
          kl = model->getReaction(reactNo)->getKineticLaw();
          ud = getUnitDefinitionFromParameter(
                                           kl->getParameter(node->getName()));
          if (ud != NULL)
          {
            found = 1;
          }
        }
      }
      if (found == 0)// && n < model->getNumCompartments())
      {
        ud = getUnitDefinitionFromCompartment(
                                      model->getCompartment(node->getName()));
        if (ud != NULL)
        {
          found = 1;
        }
      }

      if (found == 0)//&& n < model->getNumSpecies())
      {
        ud = getUnitDefinitionFromSpecies(
                                          model->getSpecies(node->getName()));
        if (ud != NULL)
        {
          found = 1;
        }
      }

      if (found == 0 )//&& n < model->getNumParameters())
      {
        ud = getUnitDefinitionFromParameter(
                                       model->getParameter(node->getName()));
        if (ud != NULL)
        {
          found = 1;
        }
      }

      if (found == 0 && model->getLevel() > 2)
      {
        // check for sr
        if (model->getSpeciesReference(node->getName()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());

          Unit *u = new Unit(model->getSBMLNamespaces());
          u->setKind(UNIT_KIND_DIMENSIONLESS);
          u->initDefaults();
          ud->addUnit(u);
          delete u;
          found = 1;
        }

      }
      
      if (found == 0 )//&& n < model->getNumParameters())
      {
        if (model->getReaction(node->getName()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          // <ci> element refers to reaction
          // units should be substance per time
          // NOTE: whether the KL has correct units is
          // checked elsewhere
          // but in L3 there might not be units for extent
          // or time
          /* check for builtin unit substance redefined */
          if (model->getLevel() < 3)
          {
            tempUd = model->getUnitDefinition("substance");
            if (tempUd == NULL) 
            {
              unit = new Unit(model->getSBMLNamespaces());
              unit->setKind(UnitKind_forName("mole"));
              unit->initDefaults();
              ud   = new UnitDefinition(model->getSBMLNamespaces());

              ud->addUnit(unit);
              delete unit;
            }
            else
            {
              ud   = new UnitDefinition(model->getSBMLNamespaces());

              for (n = 0; n < tempUd->getNumUnits(); n++)
              {
                ud->addUnit(tempUd->getUnit(n));
              }
            }
            /* check for redinition of time
             * and add per time to ud
             */
            tempUd = model->getUnitDefinition("time");

            if (tempUd == NULL) 
            {
              unit = new Unit(model->getSBMLNamespaces());
              unit->setKind(UnitKind_forName("second"));
              unit->initDefaults();
              unit->setExponentUnitChecking(-1);
          
              ud->addUnit(unit);

              delete unit;
            }
            else
            {
              for (n = 0; n < tempUd->getNumUnits(); n++)
              {
                unit = (const_cast<Unit*>(tempUd->getUnit(n)))->clone();
                exponent = unit->getExponent();
                unit->setExponentUnitChecking(exponent * -1);
                ud->addUnit(unit);
              }
            }
          }
          else
          {
            /* in L3 the units will be extent per time
             * or possibly not declared at all !
             */
            std::string extentUnits = model->getExtentUnits();
            if (UnitKind_isValidUnitKindString(extentUnits.c_str(), 
                                               model->getLevel(), 
                                               model->getVersion()))
            {
              Unit* u = new Unit(model->getSBMLNamespaces());
              u->setKind(UnitKind_forName(extentUnits.c_str()));
              u->initDefaults();
              ud->addUnit(u);
              delete u;
            }
            else if (model->getUnitDefinition(extentUnits) != NULL)
            {
              for (unsigned int n = 0; 
                n < model->getUnitDefinition(extentUnits)->getNumUnits(); n++)
              {
                // need to prevent level/version mismatches
                // ud will have default level and veersion
                const Unit* uFromModel = 
                          model->getUnitDefinition(extentUnits)->getUnit(n);
                if (uFromModel  != NULL)
                {
                  Unit* u = new Unit(uFromModel->getSBMLNamespaces());
                  u->setKind(uFromModel->getKind());
                  u->setExponent(uFromModel->getExponent());
                  u->setScale(uFromModel->getScale());
                  u->setMultiplier(uFromModel->getMultiplier());
                  ud->addUnit(u);
                  delete u;
                }
              }
            }
            else
            {
              mContainsUndeclaredUnits = true;
              mCanIgnoreUndeclaredUnits = 0;
            }

            std::string timeUnits = model->getTimeUnits();
            if (UnitKind_isValidUnitKindString(timeUnits.c_str(), 
                                               model->getLevel(), 
                                               model->getVersion()))
            {
              Unit* u = new Unit(model->getSBMLNamespaces());
              u->setKind(UnitKind_forName(timeUnits.c_str()));
              u->initDefaults();
              u->setExponent(-1);
              ud->addUnit(u);
              delete u;
            }
            else if (model->getUnitDefinition(timeUnits) != NULL)
            {
              for (unsigned int n = 0; 
                n < model->getUnitDefinition(timeUnits)->getNumUnits(); n++)
              {
                // need to prevent level/version mismatches
                // ud will have default level and veersion
                const Unit* uFromModel = 
                            model->getUnitDefinition(timeUnits)->getUnit(n);
                if (uFromModel  != NULL)
                {
                  Unit* u = new Unit(uFromModel->getSBMLNamespaces());
                  u->setKind(uFromModel->getKind());
                  u->setExponent(uFromModel->getExponent() * -1);
                  u->setScale(uFromModel->getScale());
                  u->setMultiplier(uFromModel->getMultiplier());
                  ud->addUnit(u);
                  delete u;
                }
              }
            }
            else
            {
              mContainsUndeclaredUnits = true;
              mCanIgnoreUndeclaredUnits = 0;
            }
          }
        }
      }
      
    }
  }

  /* catch case where a user has used a name in a formula that 
   * has not been declared anywhere in the model
   * return a unit definition with no units
   */
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }
  return ud;
}
/* @endcond */


/** 
  * returns the unitDefinition for the units of the compartment
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromCompartment
                                             (const Compartment * compartment)
{
  if (compartment == NULL)
  {
    return NULL;
  }

  UnitDefinition * ud = NULL;
  const UnitDefinition * tempUD;
  Unit * unit = NULL;
  unsigned int n, p;

  const char * units = compartment->getUnits().c_str();
  /* in l3 the units might be derived from attributes on the model */
  if (!strcmp(units, "") && compartment->getLevel() > 2)
  {
    switch ((int)(compartment->getSpatialDimensions()))
    {
    case 1:
      if (model->isSetLengthUnits())
        units = model->getLengthUnits().c_str();
      break;
    case 2:
      if (model->isSetAreaUnits())
        units = model->getAreaUnits().c_str();
      break;
    case 3:
      if (model->isSetVolumeUnits())
        units = model->getVolumeUnits().c_str();
      break;
    default:
      break;
    }
  }

  /* no units declared implies they default to the value appropriate
   * to the spatialDimensions of the compartment 
   * noting that it is possible that these have been overridden
   * using builtin units 
   *
   * BUT NO DEFAULTS IN L3
   */
  if (!strcmp(units, ""))
  {
    if (model->getLevel() < 3)
    {
      switch ((int)(compartment->getSpatialDimensions()))
      {
        case 0:
          unit = new Unit(model->getSBMLNamespaces());
          unit->setKind(UNIT_KIND_DIMENSIONLESS);
          unit->initDefaults();
          ud   = new UnitDefinition(model->getSBMLNamespaces());
        
          ud->addUnit(unit);
          break;
        case 1: 
          /* check for builtin unit length redefined */
          tempUD = model->getUnitDefinition("length");
          if (tempUD == NULL) 
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(UnitKind_forName("metre"));
            unit->initDefaults();
            ud   = new UnitDefinition(model->getSBMLNamespaces());
          
            ud->addUnit(unit);
          }
          else
          {
            ud   = new UnitDefinition(model->getSBMLNamespaces());

            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(tempUD->getUnit(0)->getKind());
            unit->setMultiplier(tempUD->getUnit(0)->getMultiplier());
            unit->setScale(tempUD->getUnit(0)->getScale());
            unit->setExponentUnitChecking(tempUD->getUnit(0)->getExponentUnitChecking());
            unit->setOffset(tempUD->getUnit(0)->getOffset());

            ud->addUnit(unit);
          }
          break;
        case 2:
          /* check for builtin unit area redefined */
          tempUD = model->getUnitDefinition("area");
          if (tempUD == NULL) 
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(UnitKind_forName("metre"));
            unit->initDefaults();
            unit->setExponentUnitChecking(2);
            ud   = new UnitDefinition(model->getSBMLNamespaces());
            
            ud->addUnit(unit);
          }
          else
          {
            ud   = new UnitDefinition(model->getSBMLNamespaces());

            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(tempUD->getUnit(0)->getKind());
            unit->setMultiplier(tempUD->getUnit(0)->getMultiplier());
            unit->setScale(tempUD->getUnit(0)->getScale());
            unit->setExponentUnitChecking(tempUD->getUnit(0)->getExponentUnitChecking());
            unit->setOffset(tempUD->getUnit(0)->getOffset());

            ud->addUnit(unit);
          }
          break;
        case 3:
          /* check for builtin unit volume redefined */
          tempUD = model->getUnitDefinition("volume");
          if (tempUD == NULL) 
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(UnitKind_forName("litre"));
            unit->initDefaults();
            ud   = new UnitDefinition(model->getSBMLNamespaces());
          
            ud->addUnit(unit);
          }
          else
          {
            ud   = new UnitDefinition(model->getSBMLNamespaces());

            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(tempUD->getUnit(0)->getKind());
            unit->setMultiplier(tempUD->getUnit(0)->getMultiplier());
            unit->setScale(tempUD->getUnit(0)->getScale());
            unit->setExponentUnitChecking(tempUD->getUnit(0)->getExponentUnitChecking());
            unit->setOffset(tempUD->getUnit(0)->getOffset());

            ud->addUnit(unit);
          }
          break;
        default:
          break;
      }

      delete unit;
    }
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */
    if (UnitKind_isValidUnitKindString(units, 
                          compartment->getLevel(), compartment->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      
      ud->addUnit(unit);

      delete unit;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            ud->addUnit(unit);

            delete unit;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (Unit_isBuiltIn(units, model->getLevel()) && ud == NULL)
    {
      ud   = new UnitDefinition(model->getSBMLNamespaces());

      if (!strcmp(units, "volume"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_LITRE);
        unit->initDefaults();
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "area"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName("metre"));
        unit->initDefaults();
        unit->setExponentUnitChecking(2);
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "length"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName("metre"));
        unit->initDefaults();
        ud->addUnit(unit);
      }

      delete unit;
    }
  }

  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  return ud;
}

/** 
  * returns the unitDefinition for the units of the species
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromSpecies(const Species * species)
{
  if (species == NULL)
  {
    return NULL;
  }
  
  UnitDefinition * ud = NULL;
  const UnitDefinition * tempUd;
  UnitDefinition *subsUD = NULL;
  UnitDefinition *sizeUD = NULL;
  Unit * unit = NULL;
  const Compartment * c;
  unsigned int n, p;

  const char * units        = species->getSubstanceUnits().c_str();
  const char * spatialUnits = species->getSpatialSizeUnits().c_str();


  /* in l3 the units might be derived from attributes on the model */
  if (!strcmp(units, "") && species->getLevel() > 2)
  {
    if (model->isSetSubstanceUnits())
      units = model->getSubstanceUnits().c_str();
  }
  /* deal with substance units */
 
  /* no units declared implies they default to the value substance
   * BUT NO DEFAULTS IN L3
   */
  if (!strcmp(units, ""))
  {
    if (species->getLevel() < 3)
    {
      /* check for builtin unit substance redefined */
      tempUd = model->getUnitDefinition("substance");
      if (tempUd == NULL) 
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName("mole"));
        unit->initDefaults();
        subsUD   = new UnitDefinition(model->getSBMLNamespaces());

        subsUD->addUnit(unit);
      }
      else
      {
        subsUD   = new UnitDefinition(model->getSBMLNamespaces());

        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(tempUd->getUnit(0)->getKind());
        unit->setMultiplier(tempUd->getUnit(0)->getMultiplier());
        unit->setScale(tempUd->getUnit(0)->getScale());
        unit->setExponentUnitChecking(tempUd->getUnit(0)->getExponentUnitChecking());
        unit->setOffset(tempUd->getUnit(0)->getOffset());

        subsUD->addUnit(unit);

      }

      delete unit;
      unit = NULL;
    }
    else
    {
      // units is undefined 

      // as a safety catch
      return new UnitDefinition(model->getSBMLNamespaces());
    }
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */
    if (UnitKind_isValidUnitKindString(units, 
                                 species->getLevel(), species->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      subsUD   = new UnitDefinition(model->getSBMLNamespaces());
      
      subsUD->addUnit(unit);

      delete unit;
      unit = NULL;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          subsUD = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            subsUD->addUnit(unit);

            delete unit;
            unit = NULL;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (Unit_isBuiltIn(units, model->getLevel()) && subsUD == NULL)
    {
      subsUD   = new UnitDefinition(model->getSBMLNamespaces());

      if (!strcmp(units, "substance"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_MOLE);
        unit->initDefaults();
        subsUD->addUnit(unit);

        delete unit;
        unit = NULL;
      }
    }
    else if (subsUD == NULL)
    {
      // units is undefined 

      // as a safety catch
      return new UnitDefinition(model->getSBMLNamespaces());
    }

  }
  if (species->getHasOnlySubstanceUnits())
  {
    ud = subsUD;
    return ud;
  }

  /* get the compartment containing the species */
  c = model->getCompartment(species->getCompartment().c_str());

  if (c && ((c->getLevel() < 3 && c->getSpatialDimensions() == 0)
    || (c->getLevel() > 2 && c->isSetSpatialDimensions() && 
    c->getSpatialDimensions() == 0)))
  {
    ud = subsUD;
    return ud;
  }

  /* deal with spatial size units */

  /* no units declared implies they default to the value of compartment size */
  if (!strcmp(spatialUnits, ""))
  {
    sizeUD   = getUnitDefinitionFromCompartment(c);
    if (species->getLevel() > 2 && sizeUD && sizeUD->getNumUnits() == 0)
    {
      /* compartment units are not defined */
      delete sizeUD;
      return new UnitDefinition(model->getSBMLNamespaces());
    }
  }
  else
  {
    if (UnitKind_isValidUnitKindString(spatialUnits, species->getLevel(), 
                                                     species->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(spatialUnits));
      unit->initDefaults();
      sizeUD   = new UnitDefinition(model->getSBMLNamespaces());
      
      sizeUD->addUnit(unit);

      delete unit;
      unit = NULL;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(spatialUnits, model->getUnitDefinition(n)->getId().c_str()))
        {
          sizeUD = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                    model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                         model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                      model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                        model->getUnitDefinition(n)->getUnit(p)->getOffset());

            sizeUD->addUnit(unit);

            delete unit;
            unit = NULL;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (Unit_isBuiltIn(spatialUnits, model->getLevel()) && sizeUD == NULL)
    {
      sizeUD   = new UnitDefinition(model->getSBMLNamespaces());

      if (!strcmp(spatialUnits, "volume"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_LITRE);
        unit->initDefaults();
        sizeUD->addUnit(unit);
      }
      else if (!strcmp(spatialUnits, "area"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_METRE);
        unit->initDefaults();
        unit->setExponentUnitChecking(2);
        sizeUD->addUnit(unit);
      }
      else if (!strcmp(spatialUnits, "length"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_METRE);
        unit->initDefaults();
        sizeUD->addUnit(unit);
      }
      if (unit != NULL)
      delete unit;
    }
  }

  /* units of the species are units substance/size */
  ud = subsUD;

  /* shouldnt really happen but if someone is creating invalid
   * sbml the sizeUD may be NULL
   */
  if (sizeUD != NULL)
  {
    for (n = 0; n < sizeUD->getNumUnits(); n++)
    {
      unit = sizeUD->getUnit(n);
      unit->setExponentUnitChecking(-1 * unit->getExponentUnitChecking());

      ud->addUnit(unit);
    }
  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  delete sizeUD;

  return ud;
}

/** 
  * returns the unitDefinition for the units of the parameter
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromParameter
                                                (const Parameter * parameter)
{
  if (parameter == NULL)
  {
    return NULL;
  }

  UnitDefinition * ud = NULL;
  Unit * unit = NULL;
  unsigned int n, p;

  const char * units = parameter->getUnits().c_str();

 /* no units declared */
  if (!strcmp(units, ""))
  {
    ud   = new UnitDefinition(model->getSBMLNamespaces());
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */

    if (UnitKind_isValidUnitKindString(units, 
                              parameter->getLevel(), parameter->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      
      ud->addUnit(unit);

      delete unit;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentAsDouble());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            ud->addUnit(unit);

            delete unit;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (Unit_isBuiltIn(units, model->getLevel()) && ud == NULL)
    {
      ud   = new UnitDefinition(model->getSBMLNamespaces());

      if (!strcmp(units, "substance"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_MOLE);
        unit->initDefaults();
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "volume"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_LITRE);
        unit->initDefaults();
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "area"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_METRE);
        unit->initDefaults();
        unit->setExponentUnitChecking(2);
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "length"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_METRE);
        unit->initDefaults();
        ud->addUnit(unit);
      }
      else if (!strcmp(units, "time"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_SECOND);
        unit->initDefaults();
        ud->addUnit(unit);
      }

      delete unit;
    }

  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  return ud;
}

/** 
  * returns the unitDefinition for the time units of the event
  */
UnitDefinition * 
UnitFormulaFormatter::getUnitDefinitionFromEventTime(const Event * event)
{
  if (event == NULL)
  {
    return NULL;
  }
  UnitDefinition * ud = NULL;
  const UnitDefinition * tempUd;
  Unit * unit;
  unsigned int n, p;

  const char * units = event->getTimeUnits().c_str();
  if (event->getLevel() > 2)
    units = model->getTimeUnits().c_str();

 /* no units declared */
  if (!strcmp(units, ""))
  {
    /* defaults to time in L2
    * check for redefinition of time
    */
    if (event->getLevel() < 3)
    {
      tempUd = model->getUnitDefinition("time");

      if (tempUd == NULL) 
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_SECOND);
        unit->initDefaults();
        ud   = new UnitDefinition(model->getSBMLNamespaces());
        
        ud->addUnit(unit);

        delete unit;
      }
      else
      {
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        for (n = 0; n < tempUd->getNumUnits(); n++)
        {
          ud->addUnit(tempUd->getUnit(n));
        }
      }
    }
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */

    if (UnitKind_isValidUnitKindString(units, 
                                     event->getLevel(), event->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      
      ud->addUnit(unit);

      delete unit;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            ud->addUnit(unit);

            delete unit;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (event->getLevel() < 3)
    {
      if (Unit_isBuiltIn(units, model->getLevel()) && ud == NULL)
      {
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        if (!strcmp(units, "time"))
        {
          unit = new Unit(model->getSBMLNamespaces());
          unit->setKind(UNIT_KIND_SECOND);
          unit->initDefaults();
          ud->addUnit(unit);

          delete unit;
        }
      }

    }
  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  return ud;
}

/**
* Returns the unitDefinition constructed
* from the extent units of this Model.
*/
UnitDefinition * 
UnitFormulaFormatter::getExtentUnitDefinition()
{
  UnitDefinition * ud = NULL;
  Unit * unit = NULL;
  unsigned int n, p;

  const char * units = model->getExtentUnits().c_str();

 /* no units declared */
  if (!strcmp(units, ""))
  {
    ud   = new UnitDefinition(model->getSBMLNamespaces());
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */

    if (UnitKind_isValidUnitKindString(units, 
                              model->getLevel(), model->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      
      ud->addUnit(unit);

      delete unit;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            ud->addUnit(unit);

            delete unit;
          }
        }
      }
    }
  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  return ud;
}

UnitDefinition * 
UnitFormulaFormatter::getSpeciesSubstanceUnitDefinition(const Species * species)
{
  if (species == NULL)
  {
    return NULL;
  }
  
  UnitDefinition * ud = NULL;
  const UnitDefinition * tempUd;
  Unit * unit = NULL;
  unsigned int n, p;

  const char * units        = species->getSubstanceUnits().c_str();


  /* in l3 the units might be derived from attributes on the model */
  if (!strcmp(units, "") && species->getLevel() > 2)
  {
    if (model->isSetSubstanceUnits())
      units = model->getSubstanceUnits().c_str();
  }
  /* deal with substance units */
 
  /* no units declared implies they default to the value substance
   * BUT NO DEFAULTS IN L3
   */
  if (!strcmp(units, ""))
  {
    if (species->getLevel() < 3)
    {
      /* check for builtin unit substance redefined */
      tempUd = model->getUnitDefinition("substance");
      if (tempUd == NULL) 
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UnitKind_forName("mole"));
        unit->initDefaults();
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        ud->addUnit(unit);
      }
      else
      {
        ud   = new UnitDefinition(model->getSBMLNamespaces());

        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(tempUd->getUnit(0)->getKind());
        unit->setMultiplier(tempUd->getUnit(0)->getMultiplier());
        unit->setScale(tempUd->getUnit(0)->getScale());
        unit->setExponentUnitChecking(tempUd->getUnit(0)->getExponentUnitChecking());
        unit->setOffset(tempUd->getUnit(0)->getOffset());

        ud->addUnit(unit);

      }

      delete unit;
    }
    else
    {
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      mContainsUndeclaredUnits = true;
      mCanIgnoreUndeclaredUnits = 0;
    }
  }
  else
  {
    /* units can be a predefined unit kind
    * a unit definition id or a builtin unit
    */
    if (UnitKind_isValidUnitKindString(units, 
                                 species->getLevel(), species->getVersion()))
    {
      unit = new Unit(model->getSBMLNamespaces());
      unit->setKind(UnitKind_forName(units));
      unit->initDefaults();
      ud   = new UnitDefinition(model->getSBMLNamespaces());
      
      ud->addUnit(unit);

      delete unit;
    }
    else 
    {
      for (n = 0; n < model->getNumUnitDefinitions(); n++)
      {
        if (!strcmp(units, model->getUnitDefinition(n)->getId().c_str()))
        {
          ud = new UnitDefinition(model->getSBMLNamespaces());
          
          for (p = 0; p < model->getUnitDefinition(n)->getNumUnits(); p++)
          {
            unit = new Unit(model->getSBMLNamespaces());
            unit->setKind(model->getUnitDefinition(n)->getUnit(p)->getKind());
            unit->setMultiplier(
                   model->getUnitDefinition(n)->getUnit(p)->getMultiplier());
            unit->setScale(
                        model->getUnitDefinition(n)->getUnit(p)->getScale());
            unit->setExponentUnitChecking(
                     model->getUnitDefinition(n)->getUnit(p)->getExponentUnitChecking());
            unit->setOffset(
                       model->getUnitDefinition(n)->getUnit(p)->getOffset());

            ud->addUnit(unit);

            delete unit;
          }
        }
      }
    }
    /* now check for builtin units 
     * this check is left until now as it is possible for a builtin 
     * unit to be reassigned using a unit definition and thus will have 
     * been picked up above
     */
    if (Unit_isBuiltIn(units, model->getLevel()) && ud == NULL)
    {
      ud   = new UnitDefinition(model->getSBMLNamespaces());

      if (!strcmp(units, "substance"))
      {
        unit = new Unit(model->getSBMLNamespaces());
        unit->setKind(UNIT_KIND_MOLE);
        unit->initDefaults();
        ud->addUnit(unit);

        delete unit;
      }
    }
  }
  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  return ud;
}

UnitDefinition * 
UnitFormulaFormatter::getSpeciesExtentUnitDefinition(const Species * species)
{
  if (species == NULL)
  {
    return NULL;
  }
  unsigned int n;
  UnitDefinition * ud = NULL;
  Unit * unit = NULL;

  /* get model extent - if there is none then species has none */
  UnitDefinition * modelExtent = getExtentUnitDefinition();
  if (modelExtent == NULL || modelExtent->getNumUnits() == 0)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
    delete modelExtent;
    return ud;
  }

  UnitDefinition *conversion = NULL;

  /* get conversionFactor - if none or if it has no units bail*/
  if (species->isSetConversionFactor())
  {
    conversion = getUnitDefinitionFromParameter(
      model->getParameter(species->getConversionFactor()));
  }
  else if (model->isSetConversionFactor())
  {
    conversion = getUnitDefinitionFromParameter(
      model->getParameter(model->getConversionFactor()));
  }
    
  if (conversion == NULL || conversion->getNumUnits() == 0)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
    mContainsUndeclaredUnits = true;
    mCanIgnoreUndeclaredUnits = 0;
    delete modelExtent;
    delete conversion;
    return ud;
  }
  
  /* both exist so multiply */
  ud = new UnitDefinition(model->getSBMLNamespaces());
  for (n = 0; n < modelExtent->getNumUnits(); n++)
  {
    unit = new Unit(model->getSBMLNamespaces());
    unit->setKind(modelExtent->getUnit(n)->getKind());
    unit->setMultiplier(
            modelExtent->getUnit(n)->getMultiplier());
    unit->setScale(
            modelExtent->getUnit(n)->getScale());
    unit->setExponentUnitChecking(
            modelExtent->getUnit(n)->getExponentUnitChecking());
    unit->setOffset(
            modelExtent->getUnit(n)->getOffset());

    ud->addUnit(unit);

    delete unit;
  }
  for (n = 0; n < conversion->getNumUnits(); n++)
  {
    unit = new Unit(model->getSBMLNamespaces());
    unit->setKind(conversion->getUnit(n)->getKind());
    unit->setMultiplier(
            conversion->getUnit(n)->getMultiplier());
    unit->setScale(
            conversion->getUnit(n)->getScale());
    unit->setExponentUnitChecking(
            conversion->getUnit(n)->getExponentUnitChecking());
    unit->setOffset(
            conversion->getUnit(n)->getOffset());

    ud->addUnit(unit);

    delete unit;
  }


  // as a safety catch 
  if (ud == NULL)
  {
    ud = new UnitDefinition(model->getSBMLNamespaces());
  }

  UnitDefinition::simplify(ud);

  delete modelExtent;
  delete conversion;
  return ud;
}

/** 
  * returns canIgnoreUndeclaredUnits value
  */
bool 
UnitFormulaFormatter::canIgnoreUndeclaredUnits()
{
  if (mCanIgnoreUndeclaredUnits == 2
    || mCanIgnoreUndeclaredUnits == 0)
    return false;
  else
    return true;
}


/** 
  * returns undeclaredUnits value
  */
bool 
UnitFormulaFormatter::getContainsUndeclaredUnits()
{
  return mContainsUndeclaredUnits;
}

/** 
  * resets the undeclaredUnits and canIgnoreUndeclaredUnits flags
  * since these will different for each math formula
  */
void 
UnitFormulaFormatter::resetFlags()
{
  mContainsUndeclaredUnits = false;
  mCanIgnoreUndeclaredUnits = 2;
}

UnitDefinition *
UnitFormulaFormatter::inferUnitDefinition(UnitDefinition* expectedUD, 
    const ASTNode * LHS, std::string id, bool inKL, int reactNo)
{
  UnitDefinition * resultUD = NULL;

  ASTNode * math = LHS->deepCopy();
  math->reduceToBinary();

  bool isolated = false;
  ASTNode * child1 = NULL, * child2 = NULL;
  unsigned int numChildren = math->getNumChildren();

  // is the math just the ci element
  if (numChildren == 0 && math->getType() == AST_NAME
    && math->getName() == id)
  {
    resultUD = new UnitDefinition(*expectedUD);
    isolated = true;
  }

  while (isolated == false && numChildren > 0)
  {
    child1 = math->getChild(0);
    if (numChildren != 2)
    {
      /* dont support this yet */
      //isolated = true;
      resultUD = NULL;
      break;
    }
    else
    {
      child2 = math->getChild(1);
    }

    if (child1->containsVariable(id) == true)
    {
      if (child1->getType() == AST_NAME && child1->getName() == id)
      {
        resultUD = inverseFunctionOnUnits(expectedUD, child2, math->getType(),
                                          inKL, reactNo);
        isolated = true;
        continue;
      }
      else
      {
        expectedUD = inverseFunctionOnUnits(expectedUD, child2, math->getType(),
                                            inKL, reactNo);
        math = child1;
        numChildren = math->getNumChildren();
        continue;
      }
    }
    else if (child2->containsVariable(id) == true)
    {
      if (child2->getType() == AST_NAME && child2->getName() == id)
      {
        resultUD = inverseFunctionOnUnits(expectedUD, child1, math->getType(),
                                          inKL, reactNo, true);
        isolated = true;
        continue;
      }
      else
      {
        expectedUD = inverseFunctionOnUnits(expectedUD, child1, math->getType(),
                                            inKL, reactNo, true);
        math = child2;
        numChildren = math->getNumChildren();
        continue;
      }
    }
    else
    {
      //isolated = true;
      resultUD = NULL;
      break;
    }
  }

  return resultUD;
}

UnitDefinition *
UnitFormulaFormatter::inverseFunctionOnUnits(UnitDefinition* expectedUD,
    const ASTNode * math, ASTNodeType_t functionType, 
    bool inKL, int reactNo, bool unknownInLeftChild)
{
  UnitDefinition * resolvedUD = NULL;
  UnitDefinition * mathUD = this->getUnitDefinition(math, inKL, reactNo);

  switch (functionType)
  {
  case AST_TIMES:
    resolvedUD = UnitDefinition::divide(expectedUD, mathUD);
    break;
  case AST_DIVIDE:
    if (unknownInLeftChild == true)
    {
      resolvedUD = UnitDefinition::divide(mathUD, expectedUD);
    }
    else
    {
      resolvedUD = UnitDefinition::combine(expectedUD, mathUD);
    }
    break;
  case AST_PLUS:
  case AST_MINUS:
    resolvedUD = UnitDefinition::combine(expectedUD, NULL);
    break;
  case AST_POWER:
    if (unknownInLeftChild == true)
    {
      resolvedUD = new UnitDefinition(expectedUD->getSBMLNamespaces());
      Unit * u = resolvedUD->createUnit();
      u->setKind(UNIT_KIND_DIMENSIONLESS);
      u->initDefaults();
    }
    else
    {
      if (mathUD == NULL || mathUD->getNumUnits() == 0 
        || mathUD->isVariantOfDimensionless() == true)
      {
        SBMLTransforms::mapComponentValues(this->model);
        double exp = 1.0/(SBMLTransforms::evaluateASTNode(math, this->model));
        resolvedUD = new UnitDefinition(*expectedUD);
        for (unsigned int i = 0; i < resolvedUD->getNumUnits(); i++)
        {
          Unit * u = resolvedUD->getUnit(i);
          if (u->getLevel() < 3)
          {
            u->setExponent((int)(u->getExponent() * exp));
          }
          else
          {
            u->setExponent(u->getExponentAsDouble() * exp);
          }
        }
      }
    }
    break;
  default:
    break;
  }


  return resolvedUD;
}

bool
UnitFormulaFormatter::variableCanBeDeterminedFromMath(const ASTNode * node, 
                                                  std::string id)
{
  bool possible = false;

  if (node != NULL)
  {
    if (node->containsVariable(id) == true)
    {
      if (node->getNumVariablesWithUndeclaredUnits() == 1)
      {
        possible = true;
      }
    }
  }

  return possible;
}


bool
UnitFormulaFormatter::possibleToUseUnitsData(FormulaUnitsData * fud)
{
  bool possible = false;

  if (fud != NULL)
  { 
    if (fud->getContainsUndeclaredUnits() == false)
    {
      possible = true;
    }
    else if (fud->getCanIgnoreUndeclaredUnits() == true)
    {
      possible = true;
    }
  }

  return possible;
}

#endif /* __cplusplus */
/** @cond doxygenIgnored */

/* NOT YET NECESSARY 
LIBSBML_EXTERN
UnitFormulaFormatter_t* 
UnitFormulaFormatter_create(Model_t * model)
{
  return new(nothrow) UnitFormulaFormatter(model);
}

LIBSBML_EXTERN
UnitDefinition_t * 
UnitFormulaFormatter_getUnitDefinition(UnitFormulaFormatter_t * uff,
                                       const ASTNode_t * node, 
                                       unsigned int inKL, int reactNo)
{
  return uff->getUnitDefinition(node, inKL, reactNo);
}

LIBSBML_EXTERN
UnitDefinition_t * 
UnitFormulaFormatter_getUnitDefinitionFromCompartment
                                         (UnitFormulaFormatter_t * uff,
                                          const Compartment_t * compartment)
{
  return uff->getUnitDefinitionFromCompartment(compartment);
}

LIBSBML_EXTERN
UnitDefinition_t * 
UnitFormulaFormatter_getUnitDefinitionFromSpecies
                                         (UnitFormulaFormatter_t * uff,
                                          const Species_t * species)
{
  return uff->getUnitDefinitionFromSpecies(species);
}

LIBSBML_EXTERN
UnitDefinition_t * 
UnitFormulaFormatter_getUnitDefinitionFromParameter
                                         (UnitFormulaFormatter_t * uff,
                                          const Parameter * parameter)
{
  return uff->getUnitDefinitionFromParameter(parameter);
}

LIBSBML_EXTERN
UnitDefinition_t * 
UnitFormulaFormatter_getUnitDefinitionFromEventTime
                                         (UnitFormulaFormatter_t * uff,
                                          const Event * event)
{
  return uff->getUnitDefinitionFromEventTime(event);
}

LIBSBML_EXTERN
int 
UnitFormulaFormatter_canIgnoreUndeclaredUnits(UnitFormulaFormatter_t * uff)
{
  return static_cast <int> (uff->canIgnoreUndeclaredUnits());
}

LIBSBML_EXTERN
int
UnitFormulaFormatter_getContainsUndeclaredUnits(UnitFormulaFormatter_t * uff)
{
  return static_cast <int> (uff->getContainsUndeclaredUnits());
}

LIBSBML_EXTERN
void 
UnitFormulaFormatter_resetFlags(UnitFormulaFormatter_t * uff)
{
  uff->resetFlags();
}



*/

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
