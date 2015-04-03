/**
* @file    SBMLReactionConverter.cpp
* @brief   Implementation of SBMLReactionConverter, a converter changing reactions into rate rules
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
* ------------------------------------------------------------------------ -->
*/


#include <sbml/conversion/SBMLReactionConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SyntaxChecker.h>
#include <sbml/Model.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#ifdef __cplusplus

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */
void SBMLReactionConverter::init()
{
  SBMLReactionConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLReactionConverter::SBMLReactionConverter() 
  : SBMLConverter("SBML Reaction Converter")
  , mOriginalModel (NULL)
{
  mReactionsToRemove.clear();
  mRateRulesMap.clear();
}


SBMLReactionConverter::SBMLReactionConverter(const SBMLReactionConverter& orig) 
  : SBMLConverter(orig)
  , mReactionsToRemove (orig.mReactionsToRemove)
  , mRateRulesMap      (orig.mRateRulesMap)
  , mOriginalModel     (orig.mOriginalModel)
{
}


  
/*
 * Destroy this object.
 */
SBMLReactionConverter::~SBMLReactionConverter ()
{
  if (mOriginalModel != NULL)
    delete mOriginalModel;
}


SBMLReactionConverter* 
SBMLReactionConverter::clone() const
{
  return new SBMLReactionConverter(*this);
}


ConversionProperties
SBMLReactionConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("replaceReactions", true,
                   "Replace reactions with rateRules");
    init = true;
    return prop;
  }
}


bool 
SBMLReactionConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("replaceReactions"))
    return false;
  return true;
}


int 
SBMLReactionConverter::setDocument(const SBMLDocument* doc)
{
  if (SBMLConverter::setDocument(doc) == LIBSBML_OPERATION_SUCCESS)
  {
    if (mDocument != NULL)
    {
      mOriginalModel = mDocument->getModel()->clone();
      return LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      return LIBSBML_OPERATION_SUCCESS;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
SBMLReactionConverter::setDocument(SBMLDocument* doc)
{
  if (SBMLConverter::setDocument(doc) == LIBSBML_OPERATION_SUCCESS)
  {
    if (mDocument != NULL)
    {
      mOriginalModel = mDocument->getModel()->clone();
      return LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      return LIBSBML_OPERATION_SUCCESS;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
SBMLReactionConverter::convert()
{
  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  if (mOriginalModel == NULL) return LIBSBML_INVALID_OBJECT;

  /// validate doc - and abort if invalid
  if (isDocumentValid() == false) return LIBSBML_CONV_INVALID_SRC_DOCUMENT;

  // if we have no reactions we are done
  if (mOriginalModel->getNumReactions() == 0)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  bool success = false;

  mReactionsToRemove.clear();

  mRateRulesMap.clear();
  
  // deal with any local parameters that are about to get lost
  ConversionProperties props;
  props.addOption("promoteLocalParameters", true,
                 "Promotes all Local Parameters to Global ones");
  
  // convert
  int parameterReplaced = mDocument->convert(props);

  if (parameterReplaced != LIBSBML_OPERATION_SUCCESS)
  {
    return parameterReplaced;
  }

  Model * model = mDocument->getModel();

  for (unsigned int react = 0; react < model->getNumReactions(); react++)
  {
    Reaction * rn = model->getReaction(react);
    bool rnReplaced = true;

    // if there is no kineticLaw math skip this reaction
    if (rn->isSetKineticLaw() == false ||
      rn->getKineticLaw()->isSetMath() == false)
    {
      // remove the reaction - since reactants/products may get rules attached
      mReactionsToRemove.append(rn->getId());
      continue;
    }

    for (unsigned int prod = 0; prod < rn->getNumProducts(); prod++)
    {
      const std::string speciesId = rn->getProduct(prod)->getSpecies();
      ASTNode * math = createRateRuleMathForSpecies(speciesId, rn, false);
      if (math != NULL)
      {
        mRateRulesMap.push_back(make_pair(speciesId, math));
      }
      else
      {
        rnReplaced = false;
      }
    }

    for (unsigned int react = 0; react < rn->getNumReactants(); react++)
    {
      const std::string speciesId = rn->getReactant(react)->getSpecies();
      ASTNode * math = createRateRuleMathForSpecies(speciesId, rn, true);
      if (math != NULL)
      {
        mRateRulesMap.push_back(make_pair(speciesId, math));
      }
      else
      {
        rnReplaced = false;
      }
    }

    if (rnReplaced == true)
    {
      // add the reaction id to a list to be removed
      mReactionsToRemove.append(rn->getId());
    }

  }

  if (mReactionsToRemove.size() == mOriginalModel->getNumReactions())
  {
    success = replaceReactions();
  }

  if (success) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    Model * model = mDocument->getModel();
    // failed - restore original model
    *model = *(mOriginalModel->clone());
    return LIBSBML_OPERATION_FAILED;
  }
}


ASTNode *
SBMLReactionConverter::createRateRuleMathForSpecies(const std::string &spId, 
                                               Reaction *rn, bool isReactant)
{
  ASTNode * math = NULL;

  Species * species = mOriginalModel->getSpecies(spId);

  if (species == NULL) return NULL;

  Compartment * comp = mOriginalModel->getCompartment(species->getCompartment());

  if (comp == NULL) return NULL;

  // need to work out stoichiometry
  ASTNode * stoich;
  
  if (isReactant == true)
  {
    SpeciesReference * sr = rn->getReactant(spId);
    if (sr == NULL)
    {
      // this should not happen but lets catch it if we can
      return NULL;
    }
    else
    {
      stoich = determineStoichiometryNode(sr, isReactant);
    }
  }
  else
  {
    SpeciesReference * sr = rn->getProduct(spId);
    if (sr == NULL)
    {
      // this should not happen but lets catch it if we can
      return NULL;
    }
    else
    {
      stoich = determineStoichiometryNode(sr, isReactant);
    }
  }   

  ASTNode* conc_per_time = NULL;

  if (util_isEqual(comp->getSpatialDimensionsAsDouble(), 0.0) ||
    species->getHasOnlySubstanceUnits() == true)
  {
    conc_per_time = rn->getKineticLaw()->getMath()->deepCopy();
  }
  else
  {
    conc_per_time = new ASTNode(AST_DIVIDE);
    conc_per_time->addChild(rn->getKineticLaw()->getMath()->deepCopy());
    ASTNode * compMath = new ASTNode(AST_NAME);
    compMath->setName(comp->getId().c_str());
    conc_per_time->addChild(compMath);
  }

  math = new ASTNode(AST_TIMES);
  math->addChild(stoich);
  math->addChild(conc_per_time);


  return math;
}


ASTNode*
SBMLReactionConverter::determineStoichiometryNode(SpeciesReference * sr,
                                                  bool isReactant)
{
  ASTNode * stoich = NULL;
  ASTNode * tempNode = NULL;

  if (sr->isSetStoichiometry() == true)
  {
    double st = sr->getStoichiometry();
    tempNode = new ASTNode(AST_REAL);
    tempNode->setValue(st);
  }
  else
  {
    if (sr->isSetId() == true)
    {
      std::string id = sr->getId();
      if (mOriginalModel->getInitialAssignment(id) != NULL)
      {
        tempNode = mOriginalModel->getInitialAssignment(id)->isSetMath() ?
          mOriginalModel->getInitialAssignment(id)->getMath()->deepCopy() : NULL;

      }
      else if (mOriginalModel->getAssignmentRule(id) != NULL)
      {
        tempNode = mOriginalModel->getAssignmentRule(id)->isSetMath() ?
          mOriginalModel->getAssignmentRule(id)->getMath()->deepCopy() : NULL;
      }
    }
    else if (sr->isSetStoichiometryMath() == true)
    {
      if (sr->getStoichiometryMath()->isSetMath() == true)
      {
        tempNode = sr->getStoichiometryMath()->getMath()->deepCopy();
      }
    }
  }

  if (tempNode == NULL)
  {
    tempNode = new ASTNode(AST_REAL);
    tempNode->setValue(1.0);
  }

  if (isReactant == true)
  {
    stoich = new ASTNode(AST_MINUS);
    stoich->addChild(tempNode->deepCopy());
  }
  else
  {
    stoich = tempNode->deepCopy();
  }

  delete tempNode;

  return stoich;
}

int
SBMLReactionConverter::createRateRule(const std::string &spId, ASTNode *math)
{
  int success = LIBSBML_OPERATION_SUCCESS;
  // if the species is a boundaryConsition we dont create a raterule
  if (mOriginalModel->getSpecies(spId)->getBoundaryCondition() == true)
  {
    return success;
  }

  Model * model = mDocument->getModel();

  if (model->getRateRule(spId) == NULL)
  {
    // create a rate rule for this variable
    RateRule * rr = model->createRateRule();
    
    success = rr->setVariable(spId);

    if (success == LIBSBML_OPERATION_SUCCESS)
    {
      success = rr->setMath(math);
    }
  }
  else
  {
    // we already have a rate rule (species may occur in more than 1 reaction)
    RateRule* rr = model->getRateRule(spId);
    ASTNode * rr_math = const_cast<ASTNode*>(rr->getMath());
    ASTNode * new_math = new ASTNode(AST_PLUS);
    success = new_math->addChild(rr_math->deepCopy());
    if (success == LIBSBML_OPERATION_SUCCESS)
    {
      success = new_math->addChild(math->deepCopy());
    }
    if (success == LIBSBML_OPERATION_SUCCESS)
    {
      success = rr->setMath(new_math);
    }
  }

  return success;
}


bool
SBMLReactionConverter::replaceReactions()
{
  bool replaced = false;
  int success = LIBSBML_OPERATION_SUCCESS;

  // create the rateRules
  RuleMapIter it;
  for (it = mRateRulesMap.begin(); 
    success == LIBSBML_OPERATION_SUCCESS && it != mRateRulesMap.end(); ++it)
  {
    success = createRateRule((*it).first, (*it).second);
  }

  if (success != LIBSBML_OPERATION_SUCCESS)
  {
    return replaced;
  }

  Model * model = mDocument->getModel();
  // remove the reactions
  for (unsigned int i = 0; i < mReactionsToRemove.size(); i++)
  {
    delete model->removeReaction(mReactionsToRemove.at(i));
  }

  // check we have succeeded
  if (model->getNumReactions() == 0)  replaced = true;

  return replaced;
}


bool
SBMLReactionConverter::isDocumentValid()
{
  bool valid = true;

  unsigned char origValidators = mDocument->getApplicableValidators();
  mDocument->setApplicableValidators(AllChecksON);
  
  // set the flag to ignore flattening when validating
  mDocument->checkConsistency();

  unsigned int errors =  mDocument->getErrorLog()
                      ->getNumFailsWithSeverity(LIBSBML_SEV_ERROR);
  
  // reset validators
  mDocument->setApplicableValidators(origValidators);

  if (errors > 0)
  {
    valid = false;
  }

  return valid;
}

/** @cond doxygenCOnly */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


