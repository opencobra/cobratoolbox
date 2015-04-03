/**
* @file    SBMLIdConverter.cpp
* @brief   Implementation of SBMLIdConverter, a converter renaming SIds
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


#include <sbml/conversion/SBMLIdConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/util/IdList.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SyntaxChecker.h>
#include <sbml/Model.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */
void SBMLIdConverter::init()
{
  SBMLIdConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLIdConverter::SBMLIdConverter() 
  : SBMLConverter("SBML Id Converter")
{

}


SBMLIdConverter::SBMLIdConverter(const SBMLIdConverter& orig) :
  SBMLConverter(orig)
{
}

SBMLIdConverter* 
SBMLIdConverter::clone() const
{
  return new SBMLIdConverter(*this);
}


/*
 * Destroy this object.
 */
SBMLIdConverter::~SBMLIdConverter ()
{
}


ConversionProperties
SBMLIdConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("renameSIds", true,
     "Rename all SIds specified in the 'currentIds' option to the ones specified in 'newIds'");
    prop.addOption("currentIds", "",
                   "Comma separated list of ids to rename");
    prop.addOption("newIds", "",
                   "Comma separated list of the new ids");
    init = true;
    return prop;
  }
}


bool 
SBMLIdConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("renameSIds"))
    return false;
  return true;
}

int 
SBMLIdConverter::convert()
{
  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  Model* mModel = mDocument->getModel();
  if (mModel == NULL) return LIBSBML_INVALID_OBJECT;

  // nothing to do
  if (!mProps->hasOption("currentIds") || !mProps->hasOption("newIds"))
	return LIBSBML_OPERATION_SUCCESS;
  
  bool success = true;
  
  IdList currentIds(mProps->getOption("currentIds")->getValue());
  IdList newIds(mProps->getOption("newIds")->getValue());
  
  // if the size does not match something is wrong. 
  if (newIds.size() != currentIds.size())
	return LIBSBML_UNEXPECTED_ATTRIBUTE;
  
  List* allElements = mDocument->getAllElements();
  std::map<std::string, std::string> renamed;
  
  // rename ids 
  for (unsigned int i = 0; i < allElements->getSize(); ++i)
  {
    SBase* current = static_cast<SBase*>(allElements->get(i));
    if (current == NULL || !current->isSetId() 
      || current->getTypeCode() == SBML_LOCAL_PARAMETER)
      continue;	 

    for (unsigned int j = 0; j < currentIds.size(); ++j)
    {
      if (current->getId() != currentIds.at(j))
        continue;

      // return error code in case new id is invalid		
      if (!SyntaxChecker::isValidSBMLSId(newIds.at(j)))
      {
        delete allElements;
        return LIBSBML_INVALID_ATTRIBUTE_VALUE;
      }

      current->setId(newIds.at(j));
      renamed[currentIds.at(j)] = newIds.at(j);
      break;
    }	
  }

  // update all references that we changed
  std::map<std::string, std::string>::const_iterator it;
  for (unsigned int i = 0; i < allElements->getSize(); ++i)
  {
	  SBase* current = static_cast<SBase*>(allElements->get(i));
	  for (it = renamed.begin(); it != renamed.end(); ++it)
	  {
	    current->renameSIdRefs(it->first, it->second);
	  }
  }
  
  delete allElements;

  if (success) return LIBSBML_OPERATION_SUCCESS;
  return LIBSBML_OPERATION_FAILED;
  
}

/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


