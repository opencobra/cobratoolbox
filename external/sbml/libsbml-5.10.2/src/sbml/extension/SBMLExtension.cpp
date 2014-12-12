/**
 * @file    SBMLExtension.cpp
 * @brief   Implementation of SBMLExtension, the base class of package extensions.
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

#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/extension/ASTBasePlugin.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

static const packageErrorTableEntry defaultErrorTable[] =
{
  // 10304
  { 0, 
    "",
    0, 
    LIBSBML_SEV_ERROR,
    "",
    { ""
    }
  }
};

SBMLExtension::SBMLExtension ()
 : mIsEnabled(true)
#ifndef LIBSBML_USE_LEGACY_MATH
 , mASTBasePlugin (NULL)
#endif
{
}


/*
 * Copy constructor.
 */
SBMLExtension::SBMLExtension(const SBMLExtension& orig)
 : mIsEnabled(orig.mIsEnabled)
 , mSupportedPackageURI(orig.mSupportedPackageURI)
#ifndef LIBSBML_USE_LEGACY_MATH
 , mASTBasePlugin(NULL)
#endif
{
#ifndef LIBSBML_USE_LEGACY_MATH
  if (orig.mASTBasePlugin != NULL) {
    mASTBasePlugin = orig.mASTBasePlugin->clone();
  }
#endif
  for (size_t i=0; i < orig.mSBasePluginCreators.size(); i++)
    mSBasePluginCreators.push_back(orig.mSBasePluginCreators[i]->clone());
}


/*
 * Destroy this object.
 */
SBMLExtension::~SBMLExtension ()
{
  for (size_t i=0; i < mSBasePluginCreators.size(); i++)
    delete mSBasePluginCreators[i];
#ifndef LIBSBML_USE_LEGACY_MATH
  delete mASTBasePlugin;
#endif
}


/*
 * Assignment operator for SBMLExtension.
 */
SBMLExtension& 
SBMLExtension::operator=(const SBMLExtension& orig)
{  
  mIsEnabled = orig.mIsEnabled; 
  mSupportedPackageURI = orig.mSupportedPackageURI; 

#ifndef LIBSBML_USE_LEGACY_MATH
  mASTBasePlugin = NULL;
  if (orig.mASTBasePlugin != NULL) {
    mASTBasePlugin = orig.mASTBasePlugin->clone();
  }
#endif /* LIBSBML_USE_LEGACY_MATH */

  for (size_t i=0; i < mSBasePluginCreators.size(); i++)
    delete mSBasePluginCreators[i];

  for (size_t i=0; i < orig.mSBasePluginCreators.size(); i++)
    mSBasePluginCreators.push_back(orig.mSBasePluginCreators[i]->clone());

  return *this;
}


/** @cond doxygenLibsbmlInternal */
/*
 *
 */
int 
SBMLExtension::addSBasePluginCreator(const SBasePluginCreatorBase* sbaseExt)
{
  if (!sbaseExt)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  //
  // (TODO) Checks the XMLNamespaces of the given SBaseAttributeExtension and
  //        that of this SBMLExtension object.
  //        Returns LIBSBML_INVALID_ATTRIBUTE_VALUE if the namespaces are mismatched.
  //

  if (sbaseExt->getNumOfSupportedPackageURI() == 0)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  for (unsigned int i=0; i < sbaseExt->getNumOfSupportedPackageURI(); i++)
  {
    std::string uri = sbaseExt->getSupportedPackageURI(i);

#if 0
    std::cout << "[DEBUG] SBMLExtension::addSBasePluginCreator() : given package uri " 
              << uri << " typecode " << sbaseExt->getTargetSBMLTypeCode() << std::endl;
#endif

    if (! isSupported(uri) ) 
    {
      mSupportedPackageURI.push_back(uri);
    }
  }

  mSBasePluginCreators.push_back(sbaseExt->clone());

#if 0
    std::cout << "[DEBUG] SBMLExtension::addSBasePluginCreator() : supported package num " 
              <<  mSupportedPackageURI.size() << std::endl;

  for (int i=0; i < mSupportedPackageURI.size(); i++)
  {
      std::cout << "[DEBUG] SBMLExtension::addSBasePluginCreator() : supported package " 
                << mSupportedPackageURI[i] << std::endl;
  }
#endif

  return LIBSBML_OPERATION_SUCCESS;
}
/** @endcond */


#ifndef LIBSBML_USE_LEGACY_MATH
/** @cond doxygenLibsbmlInternal */

int 
SBMLExtension::setASTBasePlugin(const ASTBasePlugin* astPlugin)
{
  if (astPlugin == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (astPlugin->getElementNamespace().empty() == true)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  mASTBasePlugin = astPlugin->clone();

  return LIBSBML_OPERATION_SUCCESS;
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */

bool
SBMLExtension::isSetASTBasePlugin() const
{
  return (mASTBasePlugin != NULL);
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */

ASTBasePlugin*
SBMLExtension::getASTBasePlugin()
{
  return mASTBasePlugin;
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */

const ASTBasePlugin*
SBMLExtension::getASTBasePlugin() const
{
  return const_cast<SBMLExtension*>(this)->getASTBasePlugin();
}

/** @endcond */

#endif /* LIBSBML_USE_LEGACY_MATH */

/** @cond doxygenLibsbmlInternal */
SBasePluginCreatorBase*
SBMLExtension::getSBasePluginCreator(const SBaseExtensionPoint& extPoint)
{
  if (&extPoint == NULL) return NULL;
  std::vector<SBasePluginCreatorBase*>::iterator it = mSBasePluginCreators.begin();
  while(it != mSBasePluginCreators.end())
  {
#if 0    
    static int i=0;
    std::cout << "[DEBUG] SBMLExtension::getSBasePluginCreator() : the given typeCode " 
              << extPoint.getTypeCode ()<< " (" << i << ") typecode " << (*it)->getTargetSBMLTypeCode() 
              << std::endl;
    i++;
#endif
    if ((*it)->getTargetExtensionPoint() == extPoint)
      return *it;  
    ++it;
  }

  return NULL;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
const SBasePluginCreatorBase*
SBMLExtension::getSBasePluginCreator(const SBaseExtensionPoint& extPoint) const
{
  return const_cast<SBMLExtension*>(this)->getSBasePluginCreator(extPoint);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
SBasePluginCreatorBase*
SBMLExtension::getSBasePluginCreator(unsigned int n)
{
  return (n < mSBasePluginCreators.size()) ? mSBasePluginCreators[n] : NULL;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
const SBasePluginCreatorBase*
SBMLExtension::getSBasePluginCreator(unsigned int n) const
{
  return const_cast<SBMLExtension*>(this)->getSBasePluginCreator(n);
}
/** @endcond */


int 
SBMLExtension::getNumOfSBasePlugins() const
{
  return (int)mSBasePluginCreators.size();
}


/*
 *
 */
unsigned int 
SBMLExtension::getNumOfSupportedPackageURI() const
{
  return (unsigned int)mSupportedPackageURI.size();
}


/*
 *
 */
bool
SBMLExtension::isSupported(const std::string& uri) const
{
  if(&uri == NULL) return false;
  return ( mSupportedPackageURI.end() 
            != 
           find(mSupportedPackageURI.begin(),mSupportedPackageURI.end(), uri) );
}


const std::string&
SBMLExtension::getSupportedPackageURI(unsigned int i) const
{
  static std::string empty = "";
  return (i < mSupportedPackageURI.size()) ? mSupportedPackageURI[i] : empty;
}


/*
 * enable/disable this package.
 */
bool
SBMLExtension::setEnabled(bool isEnabled) 
{
  return SBMLExtensionRegistry::getInstance().setEnabled(getSupportedPackageURI(0), isEnabled);
}


/*
 * Check if this package is enabled (true) or disabled (false).
 */
bool 
SBMLExtension::isEnabled() const
{
  return SBMLExtensionRegistry::getInstance().isEnabled(getSupportedPackageURI(0));
}


/*
 * Removes the L2 Namespace
 *
 * This method should be overridden by all extensions that want to serialize
 * to an L2 annotation.
 */
void SBMLExtension::removeL2Namespaces(XMLNamespaces* xmlns)  const
{

}

/*
 * adds the L2 Namespace 
 *
 * This method should be overridden by all extensions that want to serialize
 * to an L2 annotation.
 */
void SBMLExtension::addL2Namespaces(XMLNamespaces* xmlns)  const
{

}

/*
 * Adds the L2 Namespace to the document and enables the extension.
 *
 * If the extension supports serialization to SBML L2 Annotations, this 
 * method should be overrridden, so it will be activated.
 */
void SBMLExtension::enableL2NamespaceForDocument(SBMLDocument* doc)  const
{

}


bool 
SBMLExtension::isInUse(SBMLDocument *doc) const
{
  return true;
}

/** @cond doxygenLibsbmlInternal */
packageErrorTableEntry 
SBMLExtension::getErrorTable(unsigned int index) const
{
  return defaultErrorTable[0];
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
unsigned int 
SBMLExtension::getErrorTableIndex(unsigned int errorId) const
{
  return 0;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
unsigned int
SBMLExtension::getErrorIdOffset() const
{
  return 0;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
unsigned int 
SBMLExtension::getSeverity(unsigned int index, unsigned int pkgVersion) const
{
  packageErrorTableEntry pkgErr = getErrorTable(index);
  switch (pkgVersion)
  {
    case 1:
    default:
      return pkgErr.l3v1_severity;
      break;
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
unsigned int 
SBMLExtension::getCategory(unsigned int index) const
{
  packageErrorTableEntry pkgErr = getErrorTable(index);
  return pkgErr.category;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
std::string 
SBMLExtension::getMessage(unsigned int index, 
                          unsigned int pkgVersion, 
                          const std::string& details) const
{
  packageErrorTableEntry pkgErr = getErrorTable(index);
      
  ostringstream newMsg;
  std::string ref;
  std::string message;

  newMsg << pkgErr.message;

  switch (pkgVersion)
  {
    case 1:
    default:
      ref = pkgErr.reference.ref_l3v1;
      break;
  }

  if (!ref.empty())
  {
    newMsg << "\nReference: " << ref << endl;
  }

  if (!details.empty())
  {
    newMsg << " " << details;
  }      
  newMsg << endl;
  message =  newMsg.str();

  return message;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
std::string 
SBMLExtension::getShortMessage(unsigned int index) const
{
  packageErrorTableEntry pkgErr = getErrorTable(index);
  return pkgErr.shortMessage;
}
/** @endcond */

#endif /* __cplusplus */

/** @cond doxygenIgnored */

LIBSBML_EXTERN
SBMLExtension_t*
SBMLExtension_clone(SBMLExtension_t* ext)
{
  if (ext == NULL) return NULL;
  return ext->clone();
}

LIBSBML_EXTERN
int
SBMLExtension_free(SBMLExtension_t* ext)
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  delete ext;
  return LIBSBML_OPERATION_SUCCESS;

}

LIBSBML_EXTERN
int
SBMLExtension_addSBasePluginCreator(SBMLExtension_t* ext, 
      SBasePluginCreatorBase_t *sbaseExt )
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  return ext->addSBasePluginCreator(sbaseExt);
}

LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreator(SBMLExtension_t* ext, 
      SBaseExtensionPoint_t *extPoint )
{
  if (ext == NULL|| extPoint == NULL) return NULL;
  return ext->getSBasePluginCreator(*extPoint);
}

LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreatorByIndex(SBMLExtension_t* ext, 
      unsigned int index)
{
  if (ext == NULL) return NULL;
  return ext->getSBasePluginCreator(index);
}

LIBSBML_EXTERN
int
SBMLExtension_getNumOfSBasePlugins(SBMLExtension_t* ext)
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  return ext->getNumOfSBasePlugins();
}

LIBSBML_EXTERN
int
SBMLExtension_getNumOfSupportedPackageURI(SBMLExtension_t* ext)
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  return ext->getNumOfSupportedPackageURI();
}

LIBSBML_EXTERN
int
SBMLExtension_isSupported(SBMLExtension_t* ext, const char* uri)
{
  if (ext == NULL || uri == NULL) return (int)false;
  string sUri(uri);
  return ext->isSupported(sUri);
}

LIBSBML_EXTERN
const char*
SBMLExtension_getSupportedPackageURI(SBMLExtension_t* ext, unsigned int index)
{
  if (ext == NULL) return NULL;
  return ext->getSupportedPackageURI(index).c_str();
}

LIBSBML_EXTERN
const char*
SBMLExtension_getName(SBMLExtension_t* ext)
{
  if (ext == NULL) return NULL;
  return ext->getName().c_str();

}


LIBSBML_EXTERN
const char*
SBMLExtension_getURI(SBMLExtension_t* ext, unsigned int sbmlLevel, 
      unsigned int sbmlVersion, unsigned int pkgVersion)
{
  if (ext == NULL) return NULL;
  return ext->getURI(sbmlLevel, sbmlVersion, pkgVersion).c_str();
}

LIBSBML_EXTERN
unsigned int
SBMLExtension_getLevel(SBMLExtension_t* ext, const char* uri)
{
  if (ext == NULL || uri == NULL) return SBML_INT_MAX;
  string sUri(uri);
  return ext->getLevel(sUri);
}

LIBSBML_EXTERN
unsigned int
SBMLExtension_getVersion(SBMLExtension_t* ext, const char* uri)
{
  if (ext == NULL || uri == NULL) return SBML_INT_MAX;
  string sUri(uri);
  return ext->getVersion(sUri);

}

LIBSBML_EXTERN
unsigned int
SBMLExtension_getPackageVersion(SBMLExtension_t* ext, const char* uri)
{
  if (ext == NULL || uri == NULL) return SBML_INT_MAX;
  string sUri(uri);
  return ext->getPackageVersion(sUri);
}

LIBSBML_EXTERN
const char*
SBMLExtension_getStringFromTypeCode(SBMLExtension_t* ext, int typeCode)
{
  if (ext == NULL) return NULL;
  return ext->getStringFromTypeCode(typeCode);
    
}

LIBSBML_EXTERN
SBMLNamespaces_t*
SBMLExtension_getSBMLExtensionNamespaces(SBMLExtension_t* ext, const char* uri)
{
  if (ext == NULL || uri == NULL) return NULL;
  string sUri(uri);
  return ext->getSBMLExtensionNamespaces(sUri);
}

LIBSBML_EXTERN
int
SBMLExtension_setEnabled(SBMLExtension_t* ext, int isEnabled)
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  return ext->setEnabled(isEnabled);
}

LIBSBML_EXTERN
int
SBMLExtension_isEnabled(SBMLExtension_t* ext)
{
  if (ext == NULL) return LIBSBML_INVALID_OBJECT;
  return ext->isEnabled();
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
