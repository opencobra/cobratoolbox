
/**
* @file    SBMLLevelVersionConverter.cpp
* @brief   Implementation of SBMLRuleConverter, a converter sorting rules
* @author  Frank Bergmann 
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
* ------------------------------------------------------------------------ -->
*/


#include <sbml/conversion/SBMLRuleConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/math/ASTNode.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/InitialAssignment.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>
#include <vector>
#include <map>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */
void SBMLRuleConverter::init()
{
  SBMLRuleConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */

SBMLRuleConverter::SBMLRuleConverter() 
  : SBMLConverter("SBML Rule Converter")
{

}

SBMLRuleConverter::SBMLRuleConverter(const SBMLRuleConverter& orig) :
SBMLConverter(orig)
{
}

SBMLRuleConverter* 
SBMLRuleConverter::clone() const
{
  return new SBMLRuleConverter(*this);
}

/*
 * Destroy this object.
 */
SBMLRuleConverter::~SBMLRuleConverter ()
{
}


ConversionProperties
SBMLRuleConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("sortRules", true,
                 "Sort AssignmentRules and InitialAssignments in the model");
    init = true;
    return prop;
  }
}

bool 
  SBMLRuleConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("sortRules"))
    return false;
  return true;
}


static void getSymbols(const ASTNode* node, vector<string>& list)
{
  if (node == NULL) return;
  if (node->isName())
  {
    string name = node->getName();
    vector<string>::iterator it = find(list.begin(), list.end(), name);
    if (it == list.end())
      list.push_back(name);
  }

  for (unsigned int i = 0; i < node->getNumChildren(); i++)
  {
    getSymbols(node->getChild(i), list);
  }

}

static vector<string> getSymbols(const ASTNode* nodes)
{
  vector<string> result;
  if (nodes == NULL) return result;

  getSymbols(nodes, result);

  return result;

}


static vector<AssignmentRule*> reorderRules(vector<AssignmentRule*>& assignmentRules)
{
  if (assignmentRules.size() < 2) return assignmentRules;
  
  map<int, vector<string> > allSymbols;
  map<string, vector<string> > map;
  vector<string> idList;
  vector<AssignmentRule*> result;

  // read id list, initialize all symbols
  for (size_t index = 0; index < assignmentRules.size(); index++)
  {
    AssignmentRule* rule = (AssignmentRule*)assignmentRules[index];
    string variable = rule->getVariable();
    if (!rule->isSetMath())
      allSymbols[(int)index] = vector<string>();
    else
      allSymbols[(int)index] = getSymbols(rule->getMath());
    idList.push_back(variable);
    map[variable] = vector<string>();
  }


  // initialize order array
  vector<int> order;
  for (size_t i = 0; i < assignmentRules.size(); i++)
  {
    order.push_back((int)i);
  }

  // build dependency graph
  for (size_t i = 0; i < idList.size(); i++)
  {
    string id = idList[i];
    for (size_t index = 0; index < assignmentRules.size(); index++)
    {
      vector<string>::iterator it = ::find(allSymbols[(int)index].begin(), allSymbols[(int)index].end(), id);
      if (it != allSymbols[(int)index].end())
      {
        map[(assignmentRules[(int)index])->getVariable()].push_back(id);
      }
    }
  }


  // sort
  bool changed = true;
  while (changed)
  {
    changed = false;
    for (size_t i = 0; i < order.size(); i++)
    {

      int first = order[i];
      for (size_t j = i + 1; j < order.size(); j++)
      {
        int second = order[j];

        string secondVar = assignmentRules[second]->getVariable();
        string firstVar = assignmentRules[first]->getVariable();


        vector<string>::iterator it = ::find(map[firstVar].begin(), map[firstVar].end(), secondVar);

        if (it != map[firstVar].end())
        {
          // found dependency, swap and start over
          order[i] = second;
          order[j] = first;

          changed = true;
          break;
        }
      }

      // if swapped start over
      if (changed)
        break;
    }
  }


  // create new order
  for (size_t i = 0; i < order.size(); i++)
    result.push_back(assignmentRules[order[i]]);


  return result;
}


static vector<InitialAssignment*> reorderInitialAssignments(vector<InitialAssignment*>& intialAssignments)
{
  if (intialAssignments.size() < 2) return intialAssignments;

  map<int, vector<string> > allSymbols;
  map<string, vector<string> > map;
  vector<string> idList;
  vector<InitialAssignment*> result;

  // read id list, initialize all symbols
  for (size_t index = 0; index < intialAssignments.size(); index++)
  {
    InitialAssignment* ia = (InitialAssignment*)intialAssignments[index];
    string variable = ia->getSymbol();
    if (!ia->isSetMath())
      allSymbols[(int)index] = vector<string>();
    else
      allSymbols[(int)index] = getSymbols(ia->getMath());
    idList.push_back(variable);
    map[variable] = vector<string>();
  }

  // initialize order array
  vector<int> order;
  for (size_t i = 0; i < intialAssignments.size(); i++)
  {
    order.push_back((int)i);
  }

  // build dependency graph
  for (size_t i = 0; i < idList.size(); i++)
  {
    string id = idList[i];
    for (size_t index = 0; index < intialAssignments.size(); index++)
    {
      vector<string>::iterator it = ::find(allSymbols[(int)index].begin(), allSymbols[(int)index].end(), id);
      if (it != allSymbols[(int)index].end())
      {
        map[(intialAssignments[(int)index])->getSymbol()].push_back(id);
      }
    }
  }


  // sort
  bool changed = true;
  while (changed)
  {
    changed = false;
    for (size_t i = 0; i < order.size(); i++)
    {

      int first = order[i];
      for (size_t j = i + 1; j < order.size(); j++)
      {
        int second = order[j];

        string secondVar = intialAssignments[second]->getSymbol();
        string firstVar = intialAssignments[first]->getSymbol();


        vector<string>::iterator it = ::find(map[firstVar].begin(), map[firstVar].end(), secondVar);

        if (it != map[firstVar].end())
        {
          // found dependency, swap and start over
          order[i] = second;
          order[j] = first;

          changed = true;
          break;
        }
      }

      // if swapped start over
      if (changed)
        break;
    }
  }


  // create new order
  for (size_t i = 0; i < order.size(); i++)
    result.push_back(intialAssignments[order[i]]);

  return result;
}

int 
SBMLRuleConverter::convert()
{
  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  Model* mModel = mDocument->getModel();
  if (mModel == NULL) return LIBSBML_INVALID_OBJECT;

  
  /* if there are no rules and initial assignments bail now */
  if (mModel->getNumRules() == 0 && mModel->getNumInitialAssignments() == 0)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  /* check consistency of model */
  /* since this function will write to the error log we should
  * clear anything in the log first
  */
  mDocument->getErrorLog()->clearLog();
  unsigned char origValidators = mDocument->getApplicableValidators();

  mDocument->setApplicableValidators(AllChecksON);

  mDocument->checkConsistency();


  /* replace original consistency checks */
  mDocument->setApplicableValidators(origValidators);

  if (mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) != 0)
  {
    return LIBSBML_CONV_INVALID_SRC_DOCUMENT;
  }


  vector<AssignmentRule*> assignmentRules;
  unsigned int numRules = mModel->getNumRules();
  // for any math in document replace each function def
  for (unsigned int i = 1 ; i <= numRules;  i++)
  {
    Rule* rule = mModel->getRule(numRules - i);
    if (rule->getTypeCode() == SBML_ASSIGNMENT_RULE)
    {
      assignmentRules.push_back((AssignmentRule*)mModel->removeRule(numRules - i));
    }

  }

  assignmentRules = reorderRules(assignmentRules);

  for (unsigned int i = 0; i < assignmentRules.size();i++)
    mModel->getListOfRules()->insertAndOwn(i,assignmentRules[i]);


  vector<InitialAssignment*> initialAssignments;
  unsigned int numInitialAssignments = mModel->getNumInitialAssignments();
  for (unsigned int i=0; i < numInitialAssignments; i++)
  {
    initialAssignments.push_back(mModel->getListOfInitialAssignments()->remove(0));
  }

  initialAssignments = reorderInitialAssignments(initialAssignments);

  for (unsigned int i = 0; i < initialAssignments.size();i++)
    mModel->getListOfInitialAssignments()->appendAndOwn(initialAssignments[i]);

  return LIBSBML_OPERATION_SUCCESS;
  
}

/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


