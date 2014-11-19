/**
 * @file    SBMLConverterRegistry.h
 * @brief   Implementation of SBMLConverterRegistry, a registry of available converters.
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

#ifdef __cplusplus

#include <algorithm>
#include <vector>
#include <string>
#include <sstream>

#include <sbml/conversion/ConversionProperties.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/util/util.h>

// for now convertes to be used have to be included once!
#include <sbml/conversion/RegisterConverters.cpp>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


SBMLConverterRegistry& 
SBMLConverterRegistry::getInstance()
{
  static SBMLConverterRegistry singletonObj;
  return singletonObj;
}

int 
SBMLConverterRegistry::addConverter (const SBMLConverter* converter)
{
  if (converter == NULL) return LIBSBML_INVALID_OBJECT;

  mConverters.push_back(converter->clone());

  return LIBSBML_OPERATION_SUCCESS;
}

SBMLConverter* 
SBMLConverterRegistry::getConverterFor(const ConversionProperties& props) const
{
  std::vector<const SBMLConverter*>::const_iterator it; 
  for (it = mConverters.begin(); it != mConverters.end(); it++)
  {
    if ((*it)->matchesProperties(props))
    {
      SBMLConverter* converter = (*it)->clone();
      converter->setProperties(&props);
      return converter;
    }
  }
  return NULL;
}

int 
SBMLConverterRegistry::getNumConverters() const
{
  return (int)mConverters.size();
}

SBMLConverter* 
SBMLConverterRegistry::getConverterByIndex(int index) const
{
  if (index < 0 || index >= getNumConverters())
    return NULL;
  return mConverters.at(index)->clone();
}


/** @cond doxygenLibsbmlInternal */

SBMLConverterRegistry::SBMLConverterRegistry()
{
}

SBMLConverterRegistry::~SBMLConverterRegistry()
{
  size_t numConverters = mConverters.size();
  for (size_t i = 0; i < numConverters; ++i)
  {
    SBMLConverter *current = const_cast<SBMLConverter *>(mConverters.back());
    mConverters.pop_back();
    if (current != NULL) 
    {
      delete current;
      current = NULL;
    }
  }
  mConverters.clear();
}

/** @endcond */


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */



