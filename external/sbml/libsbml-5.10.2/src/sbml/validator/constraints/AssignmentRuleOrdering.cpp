/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    AssignmentRuleOrdering.cpp
 * @brief   Checks rule ordering for l2v1 and l1
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

#include <cstring>

#include <sbml/Model.h>
#include <sbml/Rule.h>
#include <sbml/Reaction.h>
#include <sbml/InitialAssignment.h>
#include <sbml/util/List.h>
#include <sbml/util/memory.h>

#include "AssignmentRuleOrdering.h"
#include <sbml/util/IdList.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new Constraint with the given constraint id.
 */
AssignmentRuleOrdering::AssignmentRuleOrdering (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
AssignmentRuleOrdering::~AssignmentRuleOrdering ()
{
}


/*
 * Checks that all ids on the following Model objects are unique:
 * event assignments and assignment rules.
 */
void
AssignmentRuleOrdering::check_ (const Model& m, const Model& object)
{
  //// this rule ony applies in l2v1 and l1
  //if (!(object.getLevel() == 1 
  //  || (object.getLevel() == 2 && object.getVersion() == 1)))
  //  return;

  unsigned int n;

  mVariableList.clear();

  // create a list of all assignment rule variables 
  // in the order they appear
  for (n = 0; n < m.getNumRules(); ++n)
  { 
    if (m.getRule(n)->isAssignment())
    {
      mVariableList.append(m.getRule(n)->getId());
    }
  }
 
  for (n = 0; n < m.getNumRules(); ++n)
  { 
    if (m.getRule(n)->isAssignment())
    {
      if (m.getRule(n)->isSetMath())
      {
        checkRuleForVariable(m, *m.getRule(n));
        checkRuleForLaterVariables(m, *m.getRule(n), n);
      }
    }
  }
}
 
void 
AssignmentRuleOrdering::checkRuleForVariable(const Model& m, const Rule& object)
{
  /* list the <ci> elements */
  List* variables = object.getMath()->getListOfNodes( ASTNode_isName );
  std::string variable = object.getVariable();

  if (variables != NULL)
  {
    for (unsigned int i = 0; i < variables->getSize(); i++)
    {
      ASTNode* node = static_cast<ASTNode*>( variables->get(i) );
      const char *   name = node->getName() ? node->getName() : "";
      if (!(strcmp(variable.c_str(), name)))
        logRuleRefersToSelf(*(object.getMath()), object);
    }
    // return value of ASTNode::getListOfNodes() needs to be
    // deleted by caller.
    delete variables;
  }

}


void 
AssignmentRuleOrdering::checkRuleForLaterVariables(const Model& m, 
                                                   const Rule& object,
                                                   unsigned int n)
{
  /* list the <ci> elements of this rule*/
  List* variables = object.getMath()->getListOfNodes( ASTNode_isName );

  if (variables != NULL)
  {
    unsigned int index;
    for (unsigned int i = 0; i < variables->getSize(); i++)
    {
      ASTNode* node = static_cast<ASTNode*>( variables->get(i) );
      const char *   name = node->getName() ? node->getName() : "";
  
      if (mVariableList.contains(name))
      {
        // this <ci> is a variable
        // check that it occurs later
        index = 0; 
        while(index < mVariableList.size())
        {
          if (!strcmp(name, mVariableList.at(index).c_str()))
            break;
          index++;
        }
        if (index > n)
          logForwardReference(*(object.getMath()), object, name);
      }
    }
    // return value of ASTNode::getListOfNodes() needs to be
    // deleted by caller.
    delete variables;
  }
}


void
AssignmentRuleOrdering::logRuleRefersToSelf (const ASTNode & node,
                                             const SBase& object)
{
  char * formula = SBML_formulaToString(&node);
  msg =
    "The AssignmentRule with variable '";
  msg += object.getId();
  msg += "' refers to that variable within the math formula '";
  msg += formula;
  msg += "'.";
  safe_free(formula);
  
  logFailure(object);

}

void
AssignmentRuleOrdering::logForwardReference (const ASTNode & node,
                                             const SBase& object,
                                             std::string name)
{
  char * formula = SBML_formulaToString(&node);
  msg =
    "The AssignmentRule with variable '";
  msg += object.getId();
  msg += "' refers to the variable '";
  msg += name;
  msg += "' within the math formula '";
  msg += formula;
  msg += "'. '";
  msg += name;
  msg += "' is the subject of a later assignment rule.";
  safe_free(formula);
  
  logFailure(object);

}
#endif /* __cplusplus */

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
