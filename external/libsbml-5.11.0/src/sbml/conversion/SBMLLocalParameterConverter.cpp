/**
* @file    SBMLLocalParameterConverter.cpp
* @brief   Implementation of SBMLLocalParameterConverter, a converter replacing local parameters with global ones
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


#include <sbml/conversion/SBMLLocalParameterConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/util/IdList.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SyntaxChecker.h>
#include <sbml/Model.h>
#include <sbml/Reaction.h>
#include <sbml/Parameter.h>
#include <sbml/LocalParameter.h>
#include <sbml/KineticLaw.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>
#include <sstream>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */
void SBMLLocalParameterConverter::init()
{
  SBMLLocalParameterConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLLocalParameterConverter::SBMLLocalParameterConverter() 
  : SBMLConverter("SBML Local Parameter Converter")
{

}


SBMLLocalParameterConverter::SBMLLocalParameterConverter(const SBMLLocalParameterConverter& orig) :
  SBMLConverter(orig)
{
}

SBMLLocalParameterConverter* 
SBMLLocalParameterConverter::clone() const
{
  return new SBMLLocalParameterConverter(*this);
}


/*
 * Destroy this object.
 */
SBMLLocalParameterConverter::~SBMLLocalParameterConverter ()
{
}


ConversionProperties
SBMLLocalParameterConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("promoteLocalParameters", true,
                   "Promotes all Local Parameters to Global ones");
    init = true;
    return prop;
  }
}


bool 
SBMLLocalParameterConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("promoteLocalParameters"))
    return false;
  return true;
}

std::string getNewId(Model* model, const std::string& reactionId, const std::string& localId)
{
  string newId = reactionId + "_" + localId;
  if (model->getParameter(newId) == NULL)
    return newId;

  int ncount = 1;
  do 
  {
    stringstream str;
    str << reactionId << "_" << localId << "_" << ncount;
    newId = str.str();
    ++ncount;
  }
  while(model->getParameter(newId) != NULL);

  return newId;

}

int 
SBMLLocalParameterConverter::convert()
{
  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  Model* mModel = mDocument->getModel();
  if (mModel == NULL) return LIBSBML_INVALID_OBJECT;

  bool success = true;

  for (unsigned int i = 0; i < mModel->getNumReactions(); ++i)
  {
    Reaction* current = mModel->getReaction(i);
    
    if (current == NULL || !current->isSetKineticLaw()) 
      continue;
    
    KineticLaw* law = current->getKineticLaw();
    if (law == NULL || law->getNumParameters() == 0)
      continue;

    ListOfParameters* list =  law->getListOfParameters();
    
    for (unsigned int j = list->size(); j >= 1; --j)
    {
      Parameter* param = list->remove(j-1);
      const std::string oldId = param->getId();
      string newId = getNewId(mModel, current->getId(), oldId);
      LocalParameter* lParam = dynamic_cast<LocalParameter*>(param);

      if (lParam != NULL)
      {
        Parameter newparam(*lParam);
        newparam.setId(newId);
        newparam.setConstant(true);
        mModel->addParameter(&newparam);
      }
      else
      {
        param->setId(newId);
        mModel->addParameter(param);
      }
      delete param;

      if (law->isSetMath()) 
        (const_cast<ASTNode*>(law->getMath()))->renameSIdRefs(oldId, newId);
    }

  }

  if (success) return LIBSBML_OPERATION_SUCCESS;
  return LIBSBML_OPERATION_FAILED;
  
}

/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


