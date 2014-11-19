/**
 * @file    SBasePluginCreatorBase.cpp
 * @brief   Implementation of SBasePluginCreatorBase, the base class of 
 *          SBasePlugin creator classes.
 * @author  Akiya Jouraku
 *
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

#include <sbml/extension/SBasePluginCreatorBase.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/** @cond doxygenLibsbmlInternal */
SBasePluginCreatorBase::SBasePluginCreatorBase (const SBaseExtensionPoint& extPoint,
                                                const std::vector<std::string>& packageURIs)
 : mSupportedPackageURI(packageURIs)
  ,mTargetExtensionPoint(extPoint)
{ 
#if 0
    for (int i=0; i < packageURIs.size(); i++)
    {
      std::cout << "[DEBUG] SBasePluginCreatorBase() : supported package "
                << mSupportedPackageURI[i] << std::endl;
                //<< packageURIs[i] << std::endl;
      std::cout << "[DEBUG] SBasePluginCreatorBase() : isSupported "
                << isSupported(mSupportedPackageURI[i]) << std::endl;
    }  
#endif
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Destructor
 */
SBasePluginCreatorBase::~SBasePluginCreatorBase()
{
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Copy Constructor
 */
SBasePluginCreatorBase::SBasePluginCreatorBase (const SBasePluginCreatorBase& orig)
:  mSupportedPackageURI(orig.mSupportedPackageURI)
  ,mTargetExtensionPoint(orig.mTargetExtensionPoint)
{
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
int
SBasePluginCreatorBase::getTargetSBMLTypeCode() const
{
  return mTargetExtensionPoint.getTypeCode();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Get an SBMLTypeCode tied with this creator object.
 */
const std::string& 
SBasePluginCreatorBase::getTargetPackageName() const
{
  return mTargetExtensionPoint.getPackageName();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Get an SBaseExtensionPoint tied with this creator object.
 */
const SBaseExtensionPoint& 
SBasePluginCreatorBase::getTargetExtensionPoint() const
{
  return mTargetExtensionPoint;
}
/** @endcond */



/** @cond doxygenLibsbmlInternal */

unsigned int 
SBasePluginCreatorBase::getNumOfSupportedPackageURI() const
{
  return (unsigned int)mSupportedPackageURI.size();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
std::string
SBasePluginCreatorBase::getSupportedPackageURI(unsigned int i) const
{
  return (i < mSupportedPackageURI.size()) ? mSupportedPackageURI[i] : std::string();
  return (i < mSupportedPackageURI.size()) ? mSupportedPackageURI[i] : std::string("");
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool 
SBasePluginCreatorBase::isSupported(const std::string& uri) const
{
  if (&uri == NULL) return false;
  return ( mSupportedPackageURI.end()
            !=
           find(mSupportedPackageURI.begin(), mSupportedPackageURI.end(), uri)
         );
}
/** @endcond */

#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
SBasePlugin_t*
SBasePluginCreator_createPlugin(SBasePluginCreatorBase_t* creator, 
  const char* uri, const char* prefix, const XMLNamespaces_t* xmlns)
{
  if (creator == NULL || uri == NULL || prefix == NULL) return NULL;
  string sUri(uri); string sPrefix(prefix);
  return creator->createPlugin(sUri, sPrefix, xmlns);
}

LIBSBML_EXTERN
SBasePluginCreatorBase_t*
SBasePluginCreator_clone(SBasePluginCreatorBase_t* creator)
{
  if (creator == NULL) return NULL;
  return creator->clone();
}

LIBSBML_EXTERN
unsigned int
SBasePluginCreator_getNumOfSupportedPackageURI(SBasePluginCreatorBase_t* creator)
{
  if (creator == NULL) return 0;
  return creator->getNumOfSupportedPackageURI();
}

LIBSBML_EXTERN
char*
SBasePluginCreator_getSupportedPackageURI(SBasePluginCreatorBase_t* creator, 
    unsigned int index)
{
  if (creator == NULL) return NULL;
  return safe_strdup(creator->getSupportedPackageURI(index).c_str());
}

LIBSBML_EXTERN
int
SBasePluginCreator_getTargetSBMLTypeCode(SBasePluginCreatorBase_t* creator)
{
  if (creator == NULL) return LIBSBML_INVALID_OBJECT;
  return creator->getTargetSBMLTypeCode();
}

LIBSBML_EXTERN
const char*
SBasePluginCreator_getTargetPackageName(SBasePluginCreatorBase_t* creator)
{
  if (creator == NULL) return NULL;
  return creator->getTargetPackageName().c_str();
}

LIBSBML_EXTERN
const SBaseExtensionPoint_t*
SBasePluginCreator_getTargetExtensionPoint(SBasePluginCreatorBase_t* creator)
{
  if (creator == NULL) return NULL;
  return &(creator->getTargetExtensionPoint());
}

LIBSBML_EXTERN
int 
SBasePluginCreator_isSupported(SBasePluginCreatorBase_t* creator, const char* uri)
{
  if (creator == NULL) return (int)false;
  string sUri(uri);
  return creator->isSupported(sUri);
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


