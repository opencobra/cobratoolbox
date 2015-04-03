/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    PrefixTransformer.cpp
 * @brief   A special IdentifierTransformer allowing to customize how to apply  prefixes
 * @author  Frank T. Bergmann
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


#include <sbml/common/operationReturnValues.h>
#include <sbml/SBase.h>
#include <sbml/util/PrefixTransformer.h>

LIBSBML_CPP_NAMESPACE_USE

PrefixTransformer::PrefixTransformer () 
{
}

PrefixTransformer::~PrefixTransformer () 
{
}

PrefixTransformer::PrefixTransformer (const std::string& prefix) 
: mPrefix(prefix) 
{
}


int PrefixTransformer::transform(SBase* element)
{
  // if there is nothing to do return ... 
  if (element == NULL || mPrefix.empty()) 
  return LIBSBML_OPERATION_SUCCESS;

  // prefix meta id if we have one ... 
  if (element->isSetMetaId())
  {
    if (element->setMetaId(mPrefix + element->getMetaId()) != LIBSBML_OPERATION_SUCCESS)
      return LIBSBML_OPERATION_FAILED;
  }

  // prefix other ids (unitsid, or sid) ...
  // skip local parameters
  if (element->isSetId() && element->getTypeCode() != SBML_LOCAL_PARAMETER)
  {
    if (element->setId(mPrefix + element->getId()) != LIBSBML_OPERATION_SUCCESS)
      return LIBSBML_OPERATION_FAILED;
  }
  return LIBSBML_OPERATION_SUCCESS;
}

const std::string& 
PrefixTransformer::getPrefix() const
{
  return mPrefix;
}

void 
PrefixTransformer::setPrefix(const std::string& prefix)
{
  mPrefix = prefix;
}

/** @endcond */
