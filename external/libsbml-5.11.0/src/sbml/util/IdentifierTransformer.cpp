/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdentifierTransformer.cpp
 * @brief   Implementation of the base class of all Identifier Transformers
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


#include <cstddef> 
#include <sbml/common/libsbml-namespace.h> 
#include <sbml/common/operationReturnValues.h> 
#include <sbml/util/IdentifierTransformer.h> 
 
LIBSBML_CPP_NAMESPACE_BEGIN

IdentifierTransformer::IdentifierTransformer()
: mUserData(NULL)
{
}


IdentifierTransformer::~IdentifierTransformer()
{
}

int 
IdentifierTransformer::transform(const SBase* element)
{
  return transform(const_cast<SBase*>(element));
}


int 
IdentifierTransformer::transform(SBase* element)
{
  return LIBSBML_OPERATION_SUCCESS;
}

void* 
IdentifierTransformer::getUserData()
{
  return mUserData;
}

void 
IdentifierTransformer::setUserData(void* userData)
{
  mUserData = userData;
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
