/**
 * @file    SBaseExtensionPoint.h
 * @brief   Implementation of SBaseExtensionPoint
 * @author  Akiya Jouraku
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

#include <sbml/common/common.h>
#include <sbml/common/operationReturnValues.h>
#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/SBMLTypeCodes.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * constructor
 */
SBaseExtensionPoint::SBaseExtensionPoint(const std::string& pkgName, int typeCode) 
 : mPackageName(pkgName)
  ,mTypeCode(typeCode) 
{
}

SBaseExtensionPoint::~SBaseExtensionPoint()
{

}


/*
 * copy constructor
 */
SBaseExtensionPoint::SBaseExtensionPoint(const SBaseExtensionPoint& orig) 
 : mPackageName(orig.mPackageName)
  ,mTypeCode(orig.mTypeCode) 
{
}


/*
 * clone
 */
SBaseExtensionPoint* 
SBaseExtensionPoint::clone() const 
{ 
  return new SBaseExtensionPoint(*this); 
}


const std::string& 
SBaseExtensionPoint::getPackageName() const 
{ 
  return mPackageName; 
}


int 
SBaseExtensionPoint::getTypeCode() const 
{ 
  return mTypeCode; 
}

bool operator==(const SBaseExtensionPoint& lhs, const SBaseExtensionPoint& rhs) 
{
  if (&lhs == NULL || &rhs == NULL) return false;

  if (   (lhs.getTypeCode()    == rhs.getTypeCode()) 
      && (lhs.getPackageName() == rhs.getPackageName()) 
     )
  {
    return true;
  }

  if (   (lhs.getTypeCode()    == SBML_GENERIC_SBASE ) 
      && (lhs.getPackageName() == "all" ) 
     )
  {
    return true;
  }

  return false;
}


bool operator<(const SBaseExtensionPoint& lhs, const SBaseExtensionPoint& rhs) 
{
  if (&lhs == NULL || &rhs == NULL) return false;

  if ( lhs.getPackageName() == rhs.getPackageName() )
  {
    if (lhs.getTypeCode()  < rhs.getTypeCode())
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  else if ( lhs.getPackageName() < rhs.getPackageName() )
  {
    return true;
  }

  return false;
}


#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN 
SBaseExtensionPoint_t *
SBaseExtensionPoint_create(const char* pkgName, int typeCode)
{
  if (pkgName == NULL) return NULL;
  return new SBaseExtensionPoint(pkgName, typeCode);
}

LIBSBML_EXTERN 
int
SBaseExtensionPoint_free(SBaseExtensionPoint_t *extPoint)
{
  if (extPoint == NULL) return LIBSBML_INVALID_OBJECT;
  delete extPoint;
  return LIBSBML_OPERATION_SUCCESS;
}


LIBSBML_EXTERN 
SBaseExtensionPoint_t *
SBaseExtensionPoint_clone(const SBaseExtensionPoint_t *extPoint)
{
  if (extPoint == NULL) return NULL;
  return extPoint->clone();
}

LIBSBML_EXTERN 
char *
SBaseExtensionPoint_getPackageName(const SBaseExtensionPoint_t *extPoint)
{
  if (extPoint == NULL) return NULL;
  return safe_strdup(extPoint->getPackageName().c_str());
}

LIBSBML_EXTERN 
int
SBaseExtensionPoint_getTypeCode(const SBaseExtensionPoint_t *extPoint)
{
  if (extPoint == NULL) return LIBSBML_INVALID_OBJECT;
  return extPoint->getTypeCode();
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

