/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    AssignmentCycles.cpp
 * @brief   Ensures unique variables assigned by rules and events
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

#include "AssignmentCycles.h"
#include <sbml/util/IdList.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new Constraint with the given constraint id.
 */
AssignmentCycles::AssignmentCycles (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
AssignmentCycles::~AssignmentCycles ()
{
}


/*
 * Checks that all ids on the following Model objects are unique:
 * event assignments and assignment rules.
 */
void
AssignmentCycles::check_ (const Model& m, const Model& object)
{
  // this rule ony applies in l2v2 and beyond
  if (object.getLevel() == 1 
    || (object.getLevel() == 2 && object.getVersion() == 1))
    return;

  unsigned int n;

  mIdMap.clear();

  /* create map of id mapped to id that it refers to that is
   * also the id of a Reaction, AssignmentRule or InitialAssignment
   */
  for (n = 0; n < m.getNumInitialAssignments(); ++n)
  { 
    if (m.getInitialAssignment(n)->isSetMath())
    {
      addInitialAssignmentDependencies(m, *m.getInitialAssignment(n));
    }
  }
  
  for (n = 0; n < m.getNumReactions(); ++n)
  { 
    if (m.getReaction(n)->isSetKineticLaw()){
      if (m.getReaction(n)->getKineticLaw()->isSetMath())
      {
        addReactionDependencies(m, *m.getReaction(n));
      }
    }
  }
  
  for (n = 0; n < m.getNumRules(); ++n)
  { 
    if (m.getRule(n)->isAssignment() && m.getRule(n)->isSetMath())
    {
      addRuleDependencies(m, *m.getRule(n));
    }
  }

  // check for self assignment
  checkForSelfAssignment(m);

  determineAllDependencies();
  determineCycles(m);

  checkForImplicitCompartmentReference(m);
}
 
void 
AssignmentCycles::addInitialAssignmentDependencies(const Model& m, 
                                         const InitialAssignment& object)
{
  unsigned int ns;
  std::string thisId = object.getSymbol();

  /* loop thru the list of names in the Math
    * if they refer to a Reaction, an Assignment Rule
    * or an Initial Assignment add to the map
    * with the variable as key
    */
  List* variables = object.getMath()->getListOfNodes( ASTNode_isName );
  for (ns = 0; ns < variables->getSize(); ns++)
  {
    ASTNode* node = static_cast<ASTNode*>( variables->get(ns) );
    string   name = node->getName() ? node->getName() : "";

    if (m.getReaction(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getRule(name) && m.getRule(name)->isAssignment())
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getInitialAssignment(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
  }

  delete variables;
}


void 
AssignmentCycles::addReactionDependencies(const Model& m, const Reaction& object)
{
  unsigned int ns;
  std::string thisId = object.getId();

  /* loop thru the list of names in the Math
    * if they refer to a Reaction, an Assignment Rule
    * or an Initial Assignment add to the map
    * with the variable as key
    */
  List* variables = object.getKineticLaw()->getMath()
                                      ->getListOfNodes( ASTNode_isName );
  for (ns = 0; ns < variables->getSize(); ns++)
  {
    ASTNode* node = static_cast<ASTNode*>( variables->get(ns) );
    string   name = node->getName() ? node->getName() : "";

    if (m.getReaction(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getRule(name) && m.getRule(name)->isAssignment())
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getInitialAssignment(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
  }

  delete variables;
}


void 
AssignmentCycles::addRuleDependencies(const Model& m, const Rule& object)
{
  unsigned int ns;
  std::string thisId = object.getVariable();

  /* loop thru the list of names in the Math
    * if they refer to a Reaction, an Assignment Rule
    * or an Initial Assignment add to the map
    * with the variable as key
    */
  List* variables = object.getMath()->getListOfNodes( ASTNode_isName );
  for (ns = 0; ns < variables->getSize(); ns++)
  {
    ASTNode* node = static_cast<ASTNode*>( variables->get(ns) );
    string   name = node->getName() ? node->getName() : "";

    if (m.getReaction(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getRule(name) && m.getRule(name)->isAssignment())
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
    else if (m.getInitialAssignment(name))
    {
      mIdMap.insert(pair<const std::string, std::string>(thisId, name));
    }
  }

  delete variables;
}


void 
AssignmentCycles::determineAllDependencies()
{
  IdIter iterator;
  IdIter inner_it;
  IdRange range;

  /* for each pair in the map (x, y)
   * retrieve all other pairs where y is first (e.g. (y, s))
   * and create pairs showing that x depends on these e.g. (x, s)
   * check whether the pair already exists in the map
   * and add it if not
   */
  for (iterator = mIdMap.begin(); iterator != mIdMap.end(); iterator++)
  {
    range = mIdMap.equal_range((*iterator).second);
    for (inner_it = range.first; inner_it != range.second; inner_it++)
    {
      const pair<const std::string, std::string> &depend = 
            pair<const std::string, std::string>((*iterator).first, (*inner_it).second);
      if (!alreadyExistsInMap(mIdMap, depend))
        mIdMap.insert(depend);
    }
  }
}


bool 
AssignmentCycles::alreadyExistsInMap(IdMap map, 
                                     pair<const std::string, std::string> dependency)
{
  bool exists = false;

  IdIter it;
  
  for (it = map.begin(); it != map.end(); it++)
  {
    if (((*it).first == dependency.first)
      && ((*it).second == dependency.second))
      exists = true;
  }

  return exists;
}

  
void 
AssignmentCycles::checkForSelfAssignment(const Model& m)
{
  IdIter the_iterator;

  for (the_iterator = mIdMap.begin();
    the_iterator != mIdMap.end(); the_iterator++)
  {
    if ((*the_iterator).first == (*the_iterator).second)
    {
      logMathRefersToSelf(m, (*the_iterator).first);
    }
  }
}


void 
AssignmentCycles::determineCycles(const Model& m)
{
  IdIter it;
  IdRange range;
  IdList variables;
  IdMap logged;
  std::string id;
  variables.clear();

  /* create a list of variables that are cycles ie (x, x) */
  for (it = mIdMap.begin(); it != mIdMap.end(); it++)
  {
    if ((*it).first == (*it).second)
    {
      id = (*it).first;
      if (!variables.contains(id))
      {
        variables.append(id);
      }
    }
  }

  /* loop thru other dependencies for each; if the dependent is also
   * in the list then this is the cycle
   * keep a record of logged dependencies to avoid logging twice
   */
   
  for (unsigned int n = 0; n < variables.size(); n++)
  {
    id = variables.at(n);
    range = mIdMap.equal_range(id);
    for (it = range.first; it != range.second; it++)
    {
      if (((*it).second != id)
        && (variables.contains((*it).second))
        && !alreadyExistsInMap(logged, pair<const std::string, std::string>(id, (*it).second))
        && !alreadyExistsInMap(logged, pair<const std::string, std::string>((*it).second, id)))
      {
        logCycle(m, id, (*it).second);
        logged.insert(pair<const std::string, std::string>(id, (*it).second));
      }
    }
  }
}
 

void 
AssignmentCycles::checkForImplicitCompartmentReference(const Model& m)
{
  mIdMap.clear();

  unsigned int i, ns;
  std::string id;

  for (i = 0; i < m.getNumInitialAssignments(); i++)
  {
    if (m.getInitialAssignment(i)->isSetMath())
    {
      id = m.getInitialAssignment(i)->getSymbol();
      if (m.getCompartment(id) 
        && m.getCompartment(id)->getSpatialDimensions() > 0)
      {
        List* variables = m.getInitialAssignment(i)->getMath()
                                        ->getListOfNodes( ASTNode_isName );
        for (ns = 0; ns < variables->getSize(); ns++)
        {
          ASTNode* node = static_cast<ASTNode*>( variables->get(ns) );
          string   name = node->getName() ? node->getName() : "";
          if (!name.empty() && !alreadyExistsInMap(mIdMap, pair<const std::string, std::string>(id, name)))
            mIdMap.insert(pair<const std::string, std::string>(id, name));
        }
        delete variables;
      }
    }
  }

  for (i = 0; i < m.getNumRules(); i++)
  {
    if (m.getRule(i)->isSetMath() && m.getRule(i)->isAssignment())
    {
      id = m.getRule(i)->getVariable();
      if (m.getCompartment(id) 
        && m.getCompartment(id)->getSpatialDimensions() > 0)
      {
        List* variables = m.getRule(i)->getMath()->getListOfNodes( ASTNode_isName );
        for (ns = 0; ns < variables->getSize(); ns++)
        {
          ASTNode* node = static_cast<ASTNode*>( variables->get(ns) );
          string   name = node->getName() ? node->getName() : "";
          if (!name.empty() && !alreadyExistsInMap(mIdMap, pair<const std::string, std::string>(id, name)))
            mIdMap.insert(pair<const std::string, std::string>(id, name));
        }
        delete variables;
      }
    }
  }

  IdIter it;
  IdRange range;

  for (i = 0; i < m.getNumCompartments(); i++)
  {
    std::string id = m.getCompartment(i)->getId();
    range = mIdMap.equal_range(id);
    for (it = range.first; it != range.second; it++)
    {
      const Species *s = m.getSpecies((*it).second);
      if (s && s->getCompartment() == id
        && s->getHasOnlySubstanceUnits() == false)
      {
        logImplicitReference(m, id, s);
      }
    }
  }
}

/*
  * Logs a message about an undefined &lt;ci&gt; element in the given
  * FunctionDefinition.
  */
void
AssignmentCycles::logCycle (const Model& m, std::string id,
                                std::string id1)
{
  if (m.getInitialAssignment(id))
  {
    if (m.getInitialAssignment(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getInitialAssignment(id)),
        static_cast <const SBase *> (m.getInitialAssignment(id1)));
    }
    else if (m.getReaction(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getInitialAssignment(id)),
        static_cast <const SBase *> (m.getReaction(id1)));
    }
    else if (m.getRule(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getInitialAssignment(id)),
        static_cast <const SBase *> (m.getRule(id1)));
    }
  }
  else if (m.getReaction(id))
  {
    if (m.getInitialAssignment(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getReaction(id)),
        static_cast <const SBase *> (m.getInitialAssignment(id1)));
    }
    else if (m.getReaction(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getReaction(id)),
        static_cast <const SBase *> (m.getReaction(id1)));
    }
    else if (m.getRule(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getReaction(id)),
        static_cast <const SBase *> (m.getRule(id1)));
    }
  }
  else if (m.getRule(id))
  {
    if (m.getInitialAssignment(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getRule(id)),
        static_cast <const SBase *> (m.getInitialAssignment(id1)));
    }
    else if (m.getReaction(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getRule(id)),
        static_cast <const SBase *> (m.getReaction(id1)));
    }
    else if (m.getRule(id1))
    {
      logCycle(
        static_cast <const SBase *> (m.getRule(id)),
        static_cast <const SBase *> (m.getRule(id1)));
    }
  }
}  


void
AssignmentCycles::logCycle ( const SBase* object,
                                       const SBase* conflict )
{
  msg = "The ";
  msg += SBMLTypeCode_toString( object->getTypeCode(), object->getPackageName().c_str());
  msg += " with id '";
  msg += object->getId();
  msg += "' creates a cycle with the ";
  msg += SBMLTypeCode_toString( conflict->getTypeCode(), object->getPackageName().c_str());
  msg += " with id '";
  msg += conflict->getId();
  msg += "'.";

  
  logFailure(*object);
}

void
AssignmentCycles::logMathRefersToSelf (const Model& m, std::string id)
{
  if (m.getInitialAssignment(id))
  {
    logMathRefersToSelf(m.getInitialAssignment(id)->getMath(), 
              static_cast <const SBase * > (m.getInitialAssignment(id)));
  }
  else if (m.getReaction(id))
  {
    logMathRefersToSelf(m.getReaction(id)->getKineticLaw()->getMath(), 
              static_cast <const SBase * > (m.getReaction(id)));
  }
  else if (m.getRule(id))
  {
    logMathRefersToSelf(m.getRule(id)->getMath(), 
              static_cast <const SBase * > (m.getRule(id)));
  }

}  
  
  
  
void
AssignmentCycles::logMathRefersToSelf (const ASTNode * node,
                                             const SBase* object)
{
  char * formula = SBML_formulaToString(node);   
  msg = "The ";

  msg += SBMLTypeCode_toString( object->getTypeCode(), object->getPackageName().c_str());
  msg += " with id '";
  msg += object->getId();
  msg += "' refers to that variable within the math formula '";
  msg += formula;
  msg += "'.";
  safe_free(formula);
  
  logFailure(*object);

}

  
void 
AssignmentCycles::logImplicitReference (const Model& m, std::string id, 
                                        const Species* conflict)
{
  if (m.getInitialAssignment(id))
  {
    logImplicitReference(
      static_cast <const SBase * > (m.getInitialAssignment(id)), conflict);
  }
  else if (m.getRule(id))
  {
    logImplicitReference(static_cast <const SBase * > (m.getRule(id)), 
                         conflict);
  }
}

                                        
void 
AssignmentCycles::logImplicitReference (const SBase* object, 
                                        const Species* conflict)
{
  msg = "The ";
  msg += SBMLTypeCode_toString( object->getTypeCode(), object->getPackageName().c_str());
  msg += " assigning value to compartment '";
  msg += object->getId();
  msg += "' refers to species '";
  msg += conflict->getId();
  msg += "'->  Since the use of the species id in this context ";
  msg += "refers to a concentration, this is an implicit ";
  msg += "reference to compartment '";
  msg += object->getId();
  msg += "'.";

  
  logFailure(*object);
}

#endif /* __cplusplus */
LIBSBML_CPP_NAMESPACE_END


/** @endcond */

