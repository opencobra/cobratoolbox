/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    MathMLBase.cpp
 * @brief   Base class for MathML Constraints.
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

#include "MathMLBase.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
MathMLBase::MathMLBase (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
MathMLBase::~MathMLBase ()
{
}


/*
 * @return the fieldname to use logging constraint violations.  If not
 * overridden, "math" is returned.
 */
const char*
MathMLBase::getFieldname ()
{
  return "math";
}


/*
 * @return the preamble to use when logging constraint violations.  The
 * preamble will be prepended to each log message.  If not overriden,
 * returns an empty string.
 */
const char*
MathMLBase::getPreamble ()
{
  return "";
}


/*
  * loops through all occurences of MathML within a model
  */
void
MathMLBase::check_ (const Model& m, const Model& object)
{
  unsigned int n, ea, sr, p;

  // there shouldnt be any math inside a level 1 model
  if (object.getLevel() == 1) return;

  /* create a list of local parameters ids */
  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      for (p = 0; p < m.getReaction(n)->getKineticLaw()->getNumParameters(); p++)
      {
        mLocalParameters.append(m.getReaction(n)->getKineticLaw()->getParameter(p)->getId());
      }
    }
  }

  
  /* check all math within a model */

  for (n = 0; n < m.getNumRules(); n++)
  {
    if (m.getRule(n)->isSetMath())
    {
      checkMath(m, *m.getRule(n)->getMath(), *m.getRule(n));
    }
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      if (m.getReaction(n)->getKineticLaw()->isSetMath())
      {
        mKLCount = n;
        checkMath(m, *m.getReaction(n)->getKineticLaw()->getMath(), 
          *m.getReaction(n)->getKineticLaw());
      }
    }
    for (sr = 0; sr < m.getReaction(n)->getNumProducts(); sr++)
    {
      if (m.getReaction(n)->getProduct(sr)->isSetStoichiometryMath())
      {
        const StoichiometryMath* smm = m.getReaction(n)->getProduct(sr)->getStoichiometryMath();
        if (smm->isSetMath())
          checkMath(m, *smm->getMath(), *m.getReaction(n)->getProduct(sr));
      }
    }
    for (sr = 0; sr < m.getReaction(n)->getNumReactants(); sr++)
    {
      if (m.getReaction(n)->getReactant(sr)->isSetStoichiometryMath())
      {
        const StoichiometryMath* smm = m.getReaction(n)->getReactant(sr)->getStoichiometryMath();
        if (smm->isSetMath())
          checkMath(m, *smm->getMath(), *m.getReaction(n)->getReactant(sr));
      }
    }
  }

  for (n = 0; n < m.getNumEvents(); n++)
  {
    mIsTrigger = 0;
    if (m.getEvent(n)->isSetTrigger())
    {
      if (m.getEvent(n)->getTrigger()->isSetMath())
      {
        mIsTrigger = 1;
        checkMath(m, *m.getEvent(n)->getTrigger()->getMath(), 
                                               *m.getEvent(n));
      }
    }
    if (m.getEvent(n)->isSetDelay())
    {
      if (m.getEvent(n)->getDelay()->isSetMath())
      {
        mIsTrigger = 0;
        checkMath(m, *m.getEvent(n)->getDelay()->getMath(), 
                                            *m.getEvent(n));
      }
    }
    if (m.getEvent(n)->isSetPriority())
    {
      if (m.getEvent(n)->getPriority()->isSetMath())
      {
        mIsTrigger = 0;
        checkMath(m, *m.getEvent(n)->getPriority()->getMath(), 
                                            *m.getEvent(n));
      }
    }
    for (ea = 0; ea < m.getEvent(n)->getNumEventAssignments(); ea++)
    {
      if (m.getEvent(n)->getEventAssignment(ea)->isSetMath())
      {
        checkMath(m, *m.getEvent(n)->getEventAssignment(ea)->getMath(), 
          *m.getEvent(n)->getEventAssignment(ea));
      }
    }
  }

  for (n = 0; n < m.getNumInitialAssignments(); n++)
  {
    if (m.getInitialAssignment(n)->isSetMath())
    {
      checkMath(m, *m.getInitialAssignment(n)->getMath(), *m.getInitialAssignment(n));
    }
  }

  for (n = 0; n < m.getNumConstraints(); n++)
  {
    if (m.getConstraint(n)->isSetMath())
    {
      checkMath(m, *m.getConstraint(n)->getMath(), *m.getConstraint(n));
    }
  }
}


/*
  * Checks the MathML of the children of ASTnode 
  * forces recursion through the AST tree
  *
  * calls checkMath for each child
  */
void 
MathMLBase::checkChildren (const Model& m, 
                                  const ASTNode& node, 
                                  const SBase & sb)
{
  unsigned int n;

  for(n = 0; n < node.getNumChildren(); n++)
  {
    checkMath(m, *node.getChild(n), sb);
  }
}

//void
//ReplaceArgument(ASTNode * math, const ASTNode * bvar, ASTNode * arg)
//{
//
//  for (unsigned int i = 0; i < math->getNumChildren(); i++)
//  {
//    if (math->getChild(i)->isName())
//    {
//      if (!strcmp(math->getChild(i)->getName(), bvar->getName()))
//      {
//        if (arg->isName())
//        {
//          math->getChild(i)->setName(arg->getName());
//        }
//        else if (arg->isReal())
//        {
//          math->getChild(i)->setValue(arg->getReal());
//        }
//        else if (arg->isInteger())
//        {
//          math->getChild(i)->setValue(arg->getInteger());
//        }
//        else if (arg->isConstant())
//        {
//          math->getChild(i)->setType(arg->getType());
//        }
//      }
//    }
//    else
//    {
//      ReplaceArgument(math->getChild(i), bvar, arg);
//    }
//  }
//}
//
/*
  * Checks the MathML of a function definition 
  * as applied to the arguments supplied to it
  *
  * creates an ASTNode of the function with appropriate arguments
  * and calls checkMath
  */
void 
MathMLBase::checkFunction (const Model& m, 
                                  const ASTNode& node, 
                                  const SBase & sb)
{
  unsigned int i, nodeCount;
  unsigned int noBvars;
  ASTNode * fdMath;
  const FunctionDefinition *fd = m.getFunctionDefinition(node.getName());

  if (fd && fd->isSetMath() == true && fd->isSetBody() == true)
  {
    noBvars = fd->getNumArguments();
    fdMath = fd->getBody()->deepCopy();
    //if (noBvars == 0)
    //{
    //  fdMath = fd->getMath()->getLeftChild()->deepCopy();
    //}
    //else
    //{
    //  fdMath = fd->getMath()->getRightChild()->deepCopy();
    //}

    for (i = 0, nodeCount = 0; i < noBvars; i++, nodeCount++)
    {
      if (nodeCount < node.getNumChildren())
        fdMath->replaceArgument(fd->getArgument(i)->getName(), 
                                          node.getChild(nodeCount));
    }
    /* check the math of the new function */
    checkMath(m, *fdMath, sb);

    delete fdMath;
  }
}


/*
 * @return the typename of the given SBase object.
 */
const char*
MathMLBase::getTypename (const SBase& object)
{
  return SBMLTypeCode_toString( object.getTypeCode(), object.getPackageName().c_str() );
}


/*
 * Logs a message that the math (and its corresponding object) have
 * failed to satisfy this constraint.
 */
void
MathMLBase::logMathConflict (const ASTNode& node, const SBase& object)
{
  logFailure(object, getMessage(node, object));
}


/*
 * Checks that the math will return a numeric result
 * forces recursion thru the AST tree
 * 
 * returns true if produces a numeric; false otherwise
 */
bool 
MathMLBase::returnsNumeric(const Model & m, const ASTNode* node)
{
  unsigned int n, count;
  ASTNodeType_t type = node->getType();
  unsigned int numChildren = node->getNumChildren();
  bool numeric;
  bool temp;


  /* a node may have children and is therefore some sort of function
   *  or if there are no children we are at the bottom of the tree 
   */
  if (numChildren == 0)
  {
    /* at bottom of AST tree result will be numeric if the node 
     * is already a number OR the name of species/compartment/parameter
     * that will be a number
     */
    if (node->isNumber()         ||
        node->isName()           ||
        type == AST_CONSTANT_E   ||
        type == AST_CONSTANT_PI   )
    {
      numeric = true;
    }
    /* or possible a functionDefinition with no bvars */
    else if (type == AST_FUNCTION)
    {
      numeric = checkNumericFunction(m, node);
    }
    /* or possibly a plus/times/piecewise with no arguments */
    else if (type == AST_PLUS || type == AST_TIMES 
      || type == AST_FUNCTION_PIECEWISE)
    {
      numeric = true;
    }
    else
    {
      numeric = false;
    }
  }
  else
  {
    /* the function may be a function that can only return a numeric
     * so need to check children
     * or need to deal with the odd cases of piecewise or a function definition
     */
    if (node->isOperator() || node->isFunction())
    {
      switch (type)
      {
      case AST_FUNCTION:

        numeric = checkNumericFunction(m, node);
        break;
        
      case AST_FUNCTION_PIECEWISE:
        numeric = returnsNumeric(m, node->getLeftChild());

        break;

      default:
      
        count = 0;
        for (n = 0; n < numChildren; n++)
        {
          temp = returnsNumeric(m, node->getChild(n));
          if (temp)
            count++;
        }
        if (count != numChildren)
          numeric = false;
        else
          numeric = true;
        break;
      }
    }
    else if (node->isQualifier())
    {
      if (numChildren > 1)
      {
        numeric = false;
      }
      else
      {
        numeric = returnsNumeric(m, node->getChild(0));
      }

    }
    else /* not a function that returns a number */
    {
      numeric = false;
    }
  }
  
  return numeric;
}


/*
  * Checks that the MathML of a function definition 
  * as applied to the arguments supplied to it will return a numeric
  *
  * creates an ASTNode of the function with appropriate arguments
  * and calls returnsNumeric
  * 
  * @returns true if produces a numeric; false otherwise
  */
bool 
MathMLBase::checkNumericFunction (const Model& m, const ASTNode* node)
{
  unsigned int i, nodeCount;
  //const ASTNode * fdMath;
  //bool needDelete = false;
  unsigned int noBvars;

  ASTNode * fdMath;
  const FunctionDefinition *fd = m.getFunctionDefinition(node->getName());

  if (fd != NULL && fd->isSetMath() == true && fd->isSetBody() == true)
  {
    noBvars = fd->getNumArguments();
    fdMath = fd->getBody()->deepCopy();
    //if (noBvars == 0)
    //{
    //  fdMath = fd->getMath()->getLeftChild()->deepCopy();
    //}
    //else
    //{
    //  fdMath = fd->getMath()->getRightChild()->deepCopy();
    //}

    for (i = 0, nodeCount = 0; i < noBvars; i++, nodeCount++)
    {
      if (nodeCount < node->getNumChildren())
        fdMath->replaceArgument(fd->getArgument(i)->getName(), 
                                          node->getChild(nodeCount));
    //}
  ///* check this function definition exists */
  //if (m.getFunctionDefinition(node->getName()))
  //{
  //  /* formula will be the right child of the functiondefinition math */
  //  fdMath = m.getFunctionDefinition(node->getName())->getMath()->getRightChild();
  //  
  //  /* if function has no variables then this will be null */
  //  if (fdMath == NULL)
  //  {
  //    newMath = m.getFunctionDefinition(node->getName())->getMath()->getLeftChild();
  //  }
  //  else
  //  {
  //    /*
  //      * create a new ASTNode of this type but with the children
  //      * from the original function
  //      */
  //    newMath = new ASTNode(fdMath->getType());
  //    /* if the fd refers to another function need to copy the name */
  //    if (fdMath->getType() == AST_FUNCTION)
  //      newMath->setName(fdMath->getName());
  //    needDelete = true;
  //    nodeCount = 0;
  //    for (i = 0; i < fdMath->getNumChildren(); i++)
  //    {
  //      if (fdMath->getChild(i)->isName())
  //      {
  //        newMath->addChild(node->getChild(nodeCount)->deepCopy());
  //        nodeCount++;
  //      }
  //      else
  //      {
  //        newMath->addChild(fdMath->getChild(i)->deepCopy());
  //      }
  //    }
    }
    
    bool isNumeric = returnsNumeric(m, fdMath);
    //bool isNumeric = returnsNumeric(m, newMath);
    //if(needDelete) delete newMath;
    delete fdMath;
   
    return isNumeric;
  }
  else
  {
    /* if the function definition doesnt exist then this will be caught
     * by another constraint and we shouldnt ever get here
     */
    return true;
  }
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
