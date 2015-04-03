/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    OverDeterminedCheck.cpp
 * @brief   Checks for over determined models.
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
#include <sbml/util/List.h>

#include <sbml/util/IdList.h>
#include "OverDeterminedCheck.h"

#include <iostream>
#include <cstring>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new Constraint with the given @p id.
 */
OverDeterminedCheck::OverDeterminedCheck ( unsigned int id,
                                                     Validator& v ) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
OverDeterminedCheck::~OverDeterminedCheck ()
{
  mEquations.clear(); // list of equation vertexes
  mVariables.clear(); // list of variable vertexes
  mGraph.clear();

  /* these are to enable the bipartite matching without passing variables */
  mMatching.clear();
  mVarNeighInPrev.clear();
  mEqnNeighInPrev.clear();

  revisited.clear();
  visited.clear();

}


/*
 * Checks that a model is not over determined
 */
void
OverDeterminedCheck::check_ (const Model& m, const Model& object)
{
  unsigned int n;
  unsigned int NumAlgRules = 0;
  IdList unmatchedEqns;

  for (n = 0; n < m.getNumRules(); n++)
  {
    if (m.getRule(n)->isAlgebraic())
    {
      NumAlgRules++;
    }
  }

  if (NumAlgRules > 0)
  {
    createGraph(m);

    /* short check - if number equations exceeds number of variables
     * then maximal matching MUST leave one or more equations unconnected
     */
    if (mEquations.size() > mVariables.size())
    {
       logOverDetermined(m, unmatchedEqns);
    }
    else
    {
      unmatchedEqns = findMatching();

      if (unmatchedEqns.size() > 0)
      {
        logOverDetermined(m, unmatchedEqns);
      }
    }
  }
}


/* 
 * creates equation vertexes according to the L2V2 spec 4.11.5 for every
 * 1. a Species that has the boundaryCondition field set to false 
 * and constant field set to false and which is referenced by one or more 
 * reactant or product lists of a Reaction containing a KineticLaw 
 * 2. a Rule 
 * 3. a KineticLaw 
 */
void
OverDeterminedCheck::writeEquationVertexes(const Model& m)
{
  const Reaction *r;
  const Species* s;
  char rule[10];
  char react[10];

  unsigned int n, sr;

  /* a Species that has the boundaryCondition field set to false 
   * and constant field set to false and which is referenced by one or 
   * more reactant or product lists of a Reaction containing 
   * a KineticLaw
   */
  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      r = m.getReaction(n);
      for (sr = 0; sr < r->getNumReactants(); sr++)
      {
        s = m.getSpecies(r->getReactant(sr)->getSpecies());
        if (!s->getBoundaryCondition() && !s->getConstant())
        {
          if (!mEquations.contains(s->getId()))
            mEquations.append(s->getId());
        }
      }

      for (sr = 0; sr < r->getNumProducts(); sr++)
      {
        s = m.getSpecies(r->getProduct(sr)->getSpecies());
        if (!s->getBoundaryCondition() && !s->getConstant())
        {
          if (!mEquations.contains(s->getId()))
            mEquations.append(s->getId());
        }
      }
    }
  }


  /* a Rule structure */
  for (n = 0; n < m.getNumRules(); n++)
  {
    sprintf(rule, "rule_%u", n);
    mEquations.append(rule);
  }

  /* a Kinetic Law structure */
  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      sprintf(react, "KL_%u", n);
      mEquations.append(react);
    }
  }
}


/*
 * creates variable vertexes according to the L2V2 spec 4.11.5 for
 * (a) every Species, Compartment and Parameter structure which has the
 * Constant field set to false; and 
 * (b) for every Reaction structure.
 */
void
OverDeterminedCheck::writeVariableVertexes(const Model& m)
{
  unsigned int n, k;

  for (n = 0; n < m.getNumCompartments(); n++)
  {
    if (!m.getCompartment(n)->getConstant())
    {
      mVariables.append(m.getCompartment(n)->getId());
    }
    else if (m.getLevel() == 1)
    {
      mVariables.append(m.getCompartment(n)->getId());
    }
  }

  for (n = 0; n < m.getNumSpecies(); n++)
  {
    if (!m.getSpecies(n)->getConstant())
    {
      mVariables.append(m.getSpecies(n)->getId());
    }
    else if (m.getLevel() == 1)
    {
      mVariables.append(m.getSpecies(n)->getId());
    }
  }

  for (n = 0; n < m.getNumParameters(); n++)
  {
    if (!m.getParameter(n)->getConstant())
    {
      mVariables.append(m.getParameter(n)->getId());
    }
    else if (m.getLevel() == 1)
    {
      mVariables.append(m.getParameter(n)->getId());
    }
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      mVariables.append(m.getReaction(n)->getId());
    }
    if (m.getLevel() > 2)
    {
      /* in L3 stoichiometry could be altered by rules
       * so these need to be included
       * where a speciesReference is marked as false
       */
      for (k = 0; k < m.getReaction(n)->getNumReactants(); k++)
      {
        if (m.getReaction(n)->getReactant(k)->getConstant() == false )
        {
          mVariables.append(m.getReaction(n)->getReactant(k)->getId());
        }
      }
      for (k = 0; k < m.getReaction(n)->getNumProducts(); k++)
      {
        if (m.getReaction(n)->getProduct(k)->getConstant() == false )
        {
          mVariables.append(m.getReaction(n)->getProduct(k)->getId());
        }
      }
    }
  }
}


/*
 * creates a bipartite graph according to the L2V2 spec 4.11.5 
 * creates edges between the equation vertexes and the variable vertexes
 * graph produced is an id representimg the equation and an IdList
 * listing the edges the equation vertex is connected to
*/
void
OverDeterminedCheck::createGraph(const Model& m)
{
  IdList joined;
  IdList speciesAdded;
  unsigned int n, sr;
  const Reaction *r;
  const Species *s;
  const char * sId;
  const Rule *rule;
  const ASTNode *math;
  const KineticLaw * kl;
  List * names;
  ASTNode * node;
  string name;

  /* create a list of ids relating to
   * 1. species
   * 2. rules
   * 3. kinetic laws
   */
  writeEquationVertexes(m);
  
  /* create a list relating to variables
   * 1. compartments
   * 2. species
   * 3. parameters
   * 4. reactions
   */
  writeVariableVertexes(m);

  /* create the edges for the graph */

  /*
   * a Species structure that has the boundaryCondition field set to false 
   * and constant field set to false and which is referenced by the reactant 
   * or product lists of a Reaction structure containing a KineticLaw structure. 
   * The edge connects the vertex representing the species 
   *    to the vertex representing the species' equation
   */

  speciesAdded.clear();
  unsigned int eqnCount = 0;
  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      r = m.getReaction(n);
      for (sr = 0; sr < r->getNumReactants(); sr++)
      {
        s = m.getSpecies(r->getReactant(sr)->getSpecies());
        sId = s->getId().c_str();

        if (mEquations.contains(sId) 
          && mVariables.contains(sId)
          && !speciesAdded.contains(sId))
        {
          joined.append(sId);
          speciesAdded.append(sId);
        }
        if (joined.size() > 0)
        {
          mGraph[mEquations.at(eqnCount)] = joined;
          joined.clear();
          eqnCount++;
        }
      }

      for (sr = 0; sr < r->getNumProducts(); sr++)
      {
        s = m.getSpecies(r->getProduct(sr)->getSpecies());
        sId = s->getId().c_str();

        if (mEquations.contains(sId) 
          && mVariables.contains(sId)
          && !speciesAdded.contains(sId))
        {
          joined.append(sId);
          speciesAdded.append(sId);
        }
        if (joined.size() > 0)
        {
          mGraph[mEquations.at(eqnCount)] = joined;
          joined.clear();
          eqnCount++;
        }
      }
    }
  }

  /* rules */
  for (n = 0; n < m.getNumRules(); n++)
  {
    rule = m.getRule(n);

    /*
     * an AssignmentRule or RateRule. 
     * The edge connects the vertex representing the Rule to the vertex
     * representing the variable referenced by the variable field of the rule.
     */
    if (rule->isAssignment() || rule->isRate())
    {
      if (mVariables.contains(rule->getVariable()))
      {
        joined.append(rule->getVariable());
      }
    }

    /*
     * the occurrence of a MathML ci symbol referencing a variable within an 
     * AssignmentRule or AlgebraicRule. 
     * The ci element must either reference: (a) a Species, compartment or 
     * parameter structure which has the constant field set to false; or 
     * (b) reference a Reaction structure
     * The edge connects the vertex representing the rule to the vertex 
     * representing the variable. 
     */
    if (rule->isSetMath())
    {
      math = rule->getMath();
      names = math->getListOfNodes( ASTNode_isName );

      for (sr = 0; sr < names->getSize(); sr++)
      {
        node = static_cast<ASTNode*>( names->get(sr) );
        name = node->getName() ? node->getName() : "";
        if (mVariables.contains(name))
        {
          joined.append(name);
        }
      }

      delete names;

    }

    mGraph[mEquations.at(eqnCount)] = joined;
    joined.clear();
    eqnCount++;
  }

  /* kineticlaws */
  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      /*
       * a KineticLaw. 
       * The edge connects the vertex representing the KineticLaw equation 
       * to the variable vertex representing the Reaction containing the 
       * KineticLaw.
       */
      if (mVariables.contains(m.getReaction(n)->getId()))
      {
        joined.append(m.getReaction(n)->getId());
      }

      /*
       * the occurrence of a MathML ci symbol referencing a variable within 
       * an KineticLaw. 
       * The ci element must either reference a Species, compartment or 
       * parameter structure which has the constant field set to false. 
       * In this context a ci element cannot refer to a Reaction structure.
       * The edge connects the vertex representing the kinetic law to the 
       * vertex representing the variable. 
       */
      kl = m.getReaction(n)->getKineticLaw();

      if (kl->isSetMath())
      {
        math = kl->getMath();
        names = math->getListOfNodes( ASTNode_isName );

        for (sr = 0; sr < names->getSize(); sr++)
        {
          node = static_cast<ASTNode*>( names->get(sr) );
          name = node->getName() ? node->getName() : "";
          if (mVariables.contains(name))
          {
            joined.append(name);
          }
        }

	delete names;
	
      }
      mGraph[mEquations.at(eqnCount)] = joined;
      joined.clear();
      eqnCount++;
    }
  }
}

/*
 * finds a maximal matching of the bipartite graph
 * adapted from the only implementation I could find:
 * # Hopcroft-Karp bipartite max-cardinality mMatching and max independent set
 * # David Eppstein, UC Irvine, 27 Apr 2002 - Python Cookbook
 *
 * returns an IdList of any equation vertexes that are unconnected 
 * in the maximal matching
 */ 
IdList 
OverDeterminedCheck::findMatching()
{
  IdList unmatchedEquations;


  unsigned int n, p;
  IdList temp;
  IdList tempVarsInMatching;
  IdList unmatch;
  IdList layer;
  IdList unmatchFlag;
  unmatchFlag.append("unmatched");
  graph newLayer;

  /* create greedy mMatching */
  for (n = 0; n < mEquations.size(); n++)
  {
    for (p = 0; p < mGraph[mEquations.at(n)].size(); p++)
    {
      if (mMatching.count(mGraph[mEquations.at(n)].at(p)) == 0)
      {
        temp.append(mEquations.at(n));
        mMatching[mGraph[mEquations.at(n)].at(p)] = temp;
        temp.clear();
        break;
      }
    }
  }

  unsigned int maximal = 1;
  while (maximal == 1)
  {
    unmatch.clear();
    mVarNeighInPrev.clear();

    /* create mEqnNeighInPrev - graph giving neighbour in previous layer */

    /* list of variables in mMatching */
    tempVarsInMatching.clear();
    for (graph::iterator iter = mMatching.begin(); iter != mMatching.end(); iter++)
    {
      tempVarsInMatching.append((*iter).second.at(0));
    }


    for (n = 0; n < mEquations.size(); n++)
    {
      if (!tempVarsInMatching.contains(mEquations.at(n)))
      {
        mEqnNeighInPrev[mEquations.at(n)] = unmatchFlag;
        layer.append(mEquations.at(n));
      }
    }

    /* extend layering structure */
    while (layer.size() > 0 && unmatch.size() == 0)
    {
      graph::iterator iter;

      newLayer.clear();

      temp.clear();
      for (iter = mVarNeighInPrev.begin(); 
                        iter != mVarNeighInPrev.end(); iter++)
      {
        temp.append((*iter).first); 
      }
      for (n = 0; n < layer.size(); n++)
      {
        for (p = 0; p < mGraph[layer.at(n)].size(); p++)
        {
          if (!temp.contains(mGraph[layer.at(n)].at(p)))
          {
            newLayer[mGraph[layer.at(n)].at(p)].append(layer.at(n));
          }
        }
      }

      layer.clear();
      temp.clear();
      for (iter = newLayer.begin(); 
                        iter != newLayer.end(); iter++)
      {
        mVarNeighInPrev[(*iter).first] = (*iter).second;
        if (tempVarsInMatching.contains((*iter).first))
        {
          layer.append(mMatching[(*iter).first].at(0));
          temp.append((*iter).first);
          mEqnNeighInPrev[mMatching[(*iter).first].at(0)] = temp;
        }
        else
        {
          unmatch.append((*iter).first);
        }
      }
    } // end of extending layers while statement

    /* finished without needing alternative paths */
    if (unmatch.size() == 0)
    {
      /* list any equations that are not matched */
      temp.clear();
      for (graph::iterator iter = mMatching.begin(); 
                        iter != mMatching.end(); iter++)
      {
        temp.append(mMatching[(*iter).first].at(0));
      }

      for (n = 0; n < mEquations.size(); n++)
      {
        if (!temp.contains(mEquations.at(n)))
        {
          unmatchedEquations.append(mEquations.at(n));
        }
      }
      maximal = 0;
    }
    else
    {
      for (n = 0; n < unmatch.size(); n++)
      {
        maximal = Recurse(unmatch.at(n));
        if (maximal == 2) break;
      }
    }
  }

  if (maximal == 2)
  {
    // we have a flip flopping set of matches
    unmatchedEquations.append(mMatching[unmatch.at(n)].at(0));
  }
  return unmatchedEquations;

}


/*
 * function that looks for alternative paths and adds these to the matching
 * where necessary
 */
unsigned int
OverDeterminedCheck::Recurse(std::string v)
{
  //static graph revisited;
  //static IdList visited;
  unsigned int rec = 0;
  unsigned int n;
  IdList tempVarNeigh;
  IdList tempEqnNeigh;
  IdList L;
  IdList pu;
  IdList prev;

  graph::iterator iter;

  tempVarNeigh.clear();
  for (iter = mVarNeighInPrev.begin(); 
                    iter != mVarNeighInPrev.end(); iter++)
  {
    tempVarNeigh.append((*iter).first);
  }

  tempEqnNeigh.clear();
  for (iter = mEqnNeighInPrev.begin(); 
                    iter != mEqnNeighInPrev.end(); iter++)
  {
    tempEqnNeigh.append((*iter).first);
  }

  if (tempVarNeigh.contains(v))
  {
    L = mVarNeighInPrev[v];
    mVarNeighInPrev.erase(v);

    for (n = 0; n < L.size(); n++)
    {
      if (tempEqnNeigh.contains(L.at(n)))
      {
        pu = mEqnNeighInPrev[L.at(n)];
        mEqnNeighInPrev.erase(L.at(n));

        if (pu.size() == 0)
          break;

        if (pu.size() == 1 && !strcmp(pu.at(0).c_str(), "unmatched"))
        {
          /* look to see if variable has been here before
           * in order t catch variables that are flip flopping
           * between equations
           */
          bool repeat = false;
          if (!visited.contains(v))
          {
            visited.append(v);
            revisited[v] = L;
          }
          else
          {
            prev = revisited[v];
            unsigned int i;
            for (i = 0; i < L.size(); i++)
            {
              if (prev.contains(L.at(i)))
              {
                repeat = true;
              }
              else
              {
                prev.append(L.at(i));
              }
              if (repeat) break;
            }
          }
          if (!repeat)
          {
            mMatching[v] = L;
            rec = 1;
          }
          else
          {
            rec = 2;
            return rec;
          }
        }
        else if (Recurse(pu.at(0)))
        {
          mMatching[v] = L;
          rec = 1;
        }
      }
    }
  }
  return rec;
}


/*
 * Logs a message about overdetermined model.
 * As yet this only reports the problem - it doesnt really give
 * any additional information
 */
void
OverDeterminedCheck::logOverDetermined (const Model& m, const IdList& unmatch)
{
  //msg =
  //  "The system of equations created from an SBML model must not be "
  //  "overdetermined. (References: L2V2 Section 4.11.5.)";

  logFailure(m);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
