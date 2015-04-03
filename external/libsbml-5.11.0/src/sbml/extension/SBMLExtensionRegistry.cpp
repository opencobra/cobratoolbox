/**
 * @file    SBMLExtensionRegistry.cpp
 * @brief   Implementation of SBMLExtensionRegistry, the registry class in which
 *          extension packages are registered.
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

#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/SBMLDocument.h>
#include <sbml/extension/SBasePlugin.h>
#include <algorithm>
#include <iostream>
#include <string>

#include <sbml/extension/RegisterExtensions.h>

#ifdef __cplusplus

#include <sbml/util/IdList.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus


/** @cond doxygenLibsbmlInternal */
SBMLExtensionRegistry* SBMLExtensionRegistry::mInstance = NULL;

bool SBMLExtensionRegistry::registered = false;

void 
SBMLExtensionRegistry::deleteRegistry()
{
  if (mInstance != NULL)
  {
    delete mInstance;
    mInstance = NULL;
    registered = false;
  }
}

/** @cond doxygenLibsbmlInternal */


/*
 *
 */
SBMLExtensionRegistry& 
SBMLExtensionRegistry::getInstance()
{
  if (mInstance == NULL)
  {
    mInstance = new SBMLExtensionRegistry();
    std::atexit(SBMLExtensionRegistry::deleteRegistry);
  }

  if (!registered)
  {
    registered = true;
    #include <sbml/extension/RegisterExtensions.cxx>
  }
  return *mInstance;
}

SBMLExtensionRegistry::SBMLExtensionRegistry() 
: mSBMLExtensionMap()
, mSBasePluginMap()
{
}


SBMLExtensionRegistry::SBMLExtensionRegistry(const SBMLExtensionRegistry& orig)
{
  if (&orig != NULL)
  {
    mSBMLExtensionMap =   orig.mSBMLExtensionMap;
    mSBasePluginMap   =   orig.mSBasePluginMap;
  }
}

SBMLExtensionRegistry& SBMLExtensionRegistry::operator= (const SBMLExtensionRegistry&rhs)
{
  if (this != &rhs)
  {
    mSBMLExtensionMap = rhs.mSBMLExtensionMap;
    mSBasePluginMap = rhs.mSBasePluginMap;
  }
  return *this;
}

SBMLExtensionRegistry::~SBMLExtensionRegistry()
{
  vector<void*> deletedExtensions;
  SBMLExtensionMapIter it = mSBMLExtensionMap.begin();
  while (it != mSBMLExtensionMap.end())
  {
    SBMLExtension* ext = const_cast<SBMLExtension*>(it->second);
    void* address = reinterpret_cast<void*>(ext);

    // it turns out that the same extension can be in there multiple times.
    if (std::find(deletedExtensions.begin(), deletedExtensions.end(),address) == deletedExtensions.end())
    {
      deletedExtensions.push_back(address);
      delete ext;
    }

    ++it;
  }
  mSBMLExtensionMap.clear();

  // // not necessary, as when the extension is deleted, the plugins 
  // // are deleted as well. 
  // // 
  // SBasePluginMapIter sbaseIt = mSBasePluginMap.begin();
  // while (sbaseIt != mSBasePluginMap.end())
  // {
  //   SBasePluginCreatorBase* base = const_cast<SBasePluginCreatorBase*>(sbaseIt->second);
  //   delete base;
  //   ++sbaseIt;
  // }
  mSBasePluginMap.clear();

  deletedExtensions.clear();
}


/*
 * Add the given SBMLExtension to SBMLTypeCode_t element
 */
int 
SBMLExtensionRegistry::addExtension (const SBMLExtension* sbmlExt)
{
  //
  // null check
  //
  if (!sbmlExt)
  {
    //std::cout << "[DEBUG] SBMLExtensionRegistry::addExtension() : invalid attribute value " << std::endl;
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  
  //
  // duplication check
  //
  for (unsigned int i=0; i < sbmlExt->getNumOfSupportedPackageURI(); i++)
  {
	   SBMLExtensionMapIter it = mSBMLExtensionMap.find(sbmlExt->getSupportedPackageURI(i));
	   if (it != mSBMLExtensionMap.end())
		   return LIBSBML_PKG_CONFLICT;
  }

  
  SBMLExtension *sbmlExtClone = sbmlExt->clone();

  //
  // Register each (URI, SBMLExtension) pair and (pkgName, SBMLExtension) pair
  //
  for (unsigned int i=0; i < sbmlExt->getNumOfSupportedPackageURI(); i++)
  {    
    mSBMLExtensionMap.insert( SBMLExtensionPair(sbmlExt->getSupportedPackageURI(i), sbmlExtClone) );
  }
  //
  mSBMLExtensionMap.insert( SBMLExtensionPair(sbmlExt->getName(), sbmlExtClone) );


  //
  // Register (SBMLTypeCode_t, SBasePluginCreatorBase) pair
  //
  for (int i=0; i < sbmlExtClone->getNumOfSBasePlugins(); i++)
  {
    const SBasePluginCreatorBase *sbPluginCreator = sbmlExtClone->getSBasePluginCreator(i);
#if 0
    std::cout << "[DEBUG] SBMLExtensionRegistry::addExtension() " << sbPluginCreator << std::endl;
#endif
    mSBasePluginMap.insert( SBasePluginPair(sbPluginCreator->getTargetExtensionPoint(), sbPluginCreator));
  }    

  return LIBSBML_OPERATION_SUCCESS;
}

SBMLExtension*
SBMLExtensionRegistry::getExtension(const std::string& uri)
{
	const SBMLExtension* extension = getExtensionInternal(uri);
	if (extension == NULL) return NULL;
	return extension->clone();
}

const SBMLExtension*
SBMLExtensionRegistry::getExtensionInternal(const std::string& uri)
{
  if(&uri == NULL) return NULL;
  
  SBMLExtensionMapIter it = mSBMLExtensionMap.find(uri);

#if 0
  if (it == mSBMLExtensionMap.end()) 
    std::cout << "[DEBUG] SBMLExtensionRegistry::getExtensionInternal() " << uri << " is NOT found." << std::endl;
  else
    std::cout << "[DEBUG] SBMLExtensionRegistry::getExtensionInternal() " << uri << " is FOUND." << std::endl;
#endif

  return (it != mSBMLExtensionMap.end()) ? mSBMLExtensionMap[uri] : NULL;  
}


/** @cond doxygenLibsbmlInternal */
/*
 * Get the list of SBasePluginCreators with the given SBMLTypeCode_t element
 */
std::list<const SBasePluginCreatorBase*> 
SBMLExtensionRegistry::getSBasePluginCreators(const SBaseExtensionPoint& extPoint)
{
  std::list<const SBasePluginCreatorBase*> sbaseExtList;

  if (&extPoint != NULL)
  {
    SBasePluginMapIter it = mSBasePluginMap.find(extPoint);
    if (it != mSBasePluginMap.end())
    {    
      do 
      {
        sbaseExtList.push_back((*it).second);
        ++it;
      } while ( it != mSBasePluginMap.upper_bound(extPoint));
    }
  }  

  return sbaseExtList;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Get the list of SBasePluginCreators with the given URI (string)
 */
std::list<const SBasePluginCreatorBase*> 
SBMLExtensionRegistry::getSBasePluginCreators(const std::string& uri)
{
  std::list<const SBasePluginCreatorBase*> sbasePCList;

  if (&uri != NULL)
  {
  SBasePluginMapIter it = mSBasePluginMap.begin();
  if (it != mSBasePluginMap.end())
  {    
    do 
    {
     const SBasePluginCreatorBase* sbplug = (*it).second;

     if (sbplug->isSupported(uri))
     {
#if 0
        std::cout << "[DEBUG] SBMLExtensionRegistry::getPluginCreators() " 
                  << uri << " is found." << std::endl;
#endif
        sbasePCList.push_back((*it).second);
     }

      ++it;
    } while ( it != mSBasePluginMap.end() );
  }

#if 0
    if (sbasePluginList.size() == 0)
      std::cout << "[DEBUG] SBMLExtensionRegistry::getPluginCreators() " 
                << uri << " is NOT found." << std::endl;
#endif
  }

  return sbasePCList;  
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Get an SBasePluginCreator with the given extension point and URI pair
 */
const SBasePluginCreatorBase* 
SBMLExtensionRegistry::getSBasePluginCreator(const SBaseExtensionPoint& extPoint, const std::string &uri)
{
  if(&extPoint == NULL || &uri == NULL) return NULL;
  SBasePluginMapIter it = mSBasePluginMap.find(extPoint);
  if (it != mSBasePluginMap.end())
  {
    do
    {
      const SBasePluginCreatorBase* sbplugc = (*it).second;

      if (sbplugc->isSupported(uri))
      {
#if 0
          std::cout << "[DEBUG] SBMLExtensionRegistry::getSBasePluginCreators() " 
                    << uri << " is found." << std::endl;
#endif
        return sbplugc;
      }      
      ++it;
    } while ( it != mSBasePluginMap.end() );
  }      

#if 0
    std::cout << "[DEBUG] SBMLExtensionRegistry::getSBasePluginCreators() " 
              << uri << " is NOT found." << std::endl;
#endif

  return NULL;
}
/** @endcond */


unsigned int 
SBMLExtensionRegistry::getNumExtension(const SBaseExtensionPoint& extPoint)
{
  unsigned int numOfExtension = 0;
  if (&extPoint == NULL) return 0;
  SBasePluginMapIter it = mSBasePluginMap.find(extPoint);
  if (it != mSBasePluginMap.end())
  {    
    numOfExtension = (unsigned int)distance(it, mSBasePluginMap.upper_bound(extPoint));
  }    

  return numOfExtension;
}


/*
 * enable/disable the package with the given uri.
 * 
 * Returned value is the result of this function.
 */
bool 
SBMLExtensionRegistry::setEnabled(const std::string& uri, bool isEnabled)
{
  SBMLExtension *sbmlext = const_cast<SBMLExtension*>(getExtensionInternal(uri));  
  return (sbmlext) ? sbmlext->mIsEnabled = isEnabled : false;
}

void
SBMLExtensionRegistry::removeL2Namespaces(XMLNamespaces *xmlns)  const
{
  SBMLExtensionMap::const_iterator it = mSBMLExtensionMap.begin();
  while (it != mSBMLExtensionMap.end())
  {
    it->second->removeL2Namespaces(xmlns);
    it++;
  }
}

/*
 * adds all L2 Extension namespaces to the namespace list. This will call all 
 * overriden SBMLExtension::addL2Namespaces methods.
 */
void
SBMLExtensionRegistry::addL2Namespaces(XMLNamespaces *xmlns) const
{
  SBMLExtensionMap::const_iterator it = mSBMLExtensionMap.begin();
  while (it != mSBMLExtensionMap.end())
  {
    it->second->addL2Namespaces(xmlns);
    it++;
  }
}

/*
 * Enables all extensions that support serialization / deserialization with
 * SBML Annotations.
 */
void 
SBMLExtensionRegistry::enableL2NamespaceForDocument(SBMLDocument* doc)  const
{
  // only ought to do this for non-L3 documents
  if (doc->getLevel() == 3)
    return;

  SBMLExtensionMap::const_iterator it = mSBMLExtensionMap.begin();
  while (it != mSBMLExtensionMap.end())
  {
    it->second->enableL2NamespaceForDocument(doc);
    it++;
  }
}

/*
 * Checks if the extension with the given URI is enabled (true) or disabled (false)
 */
bool 
SBMLExtensionRegistry::isEnabled(const std::string& uri)
{
  const SBMLExtension *sbmlext = getExtensionInternal(uri);  
  return (sbmlext) ? sbmlext->mIsEnabled : false;
}

void DeleteStringChild(void* child)
{
  if (child == NULL) return;
  free ((char*)child);
}

/*
 * Checks if the extension with the given URI is registered (true) or not (false)
 */
bool 
SBMLExtensionRegistry::isRegistered(const std::string& uri)
{  
  return (getExtensionInternal(uri)) ? true : false;
}

List* 
SBMLExtensionRegistry::getRegisteredPackageNames()
{
  const SBMLExtensionRegistry& instance = getInstance();
  SBMLExtensionMap::const_iterator it = instance.mSBMLExtensionMap.begin();
  List* result = new List();
  std::vector<std::string> present;
  while (it != instance.mSBMLExtensionMap.end())
  {    
    const std::string& temp = (*it).second->getName();
    if (std::find(present.begin(), present.end(), temp) == present.end())
    {
      char *name = safe_strdup(temp.c_str());
      result->add(name);
      present.push_back(temp);
    }
    it++;
  }
  
  return result;
}

std::vector<std::string> SBMLExtensionRegistry::getAllRegisteredPackageNames()
{
  const SBMLExtensionRegistry& instance = getInstance();
  std::vector<std::string> result;
  SBMLExtensionMap::const_iterator it = instance.mSBMLExtensionMap.begin();
  while (it != instance.mSBMLExtensionMap.end())
  {    
    const std::string& temp = (*it).second->getName();
    if (std::find(result.begin(), result.end(), temp) == result.end())
    {
      result.push_back(temp);
    }
    ++it;
  }
  return result;
}

unsigned int 
SBMLExtensionRegistry::getNumRegisteredPackages()
{
   return (unsigned int)getAllRegisteredPackageNames().size();
}


std::string
SBMLExtensionRegistry::getRegisteredPackageName(unsigned int index)
{
  const SBMLExtensionRegistry& instance = getInstance();
  SBMLExtensionMap::const_iterator it = instance.mSBMLExtensionMap.begin();
  std::vector<std::string> present;
  unsigned int count = 0;
  while (it != instance.mSBMLExtensionMap.end())
  {    
    const std::string& temp = (*it).second->getName();
    if (std::find(present.begin(), present.end(), temp) == present.end())
    {
      if (index == count)
      {
        return temp;
      }
      present.push_back(temp);
      ++count;
    }
    ++it;
  }

  return "";
}

void 
SBMLExtensionRegistry::disableUnusedPackages(SBMLDocument *doc)
{
  for (unsigned int i = doc->getNumPlugins(); i > 0; i--)
  {
    SBasePlugin *plugin = doc->getPlugin(i-1);
    if (plugin == NULL) continue;
    const SBMLExtension *ext = getExtensionInternal(plugin->getURI());
    if (!ext->isInUse(doc))
      doc->disablePackage(plugin->getURI(), plugin->getPrefix());
  }
}


/*
 * Disables the package with the given URI / name.
 */
void
SBMLExtensionRegistry::disablePackage(const std::string& package)
{
  SBMLExtension *ext = const_cast<SBMLExtension*>(getInstance().getExtensionInternal(package));
  if (ext != NULL)
    ext->setEnabled(false);
}

/** @cond doxygenLibsbmlInternal */
/*
 * Disables all packages with the given URI / name.
 */
void
SBMLExtensionRegistry::disablePackages(const std::vector<std::string>& packages)
{
  std::vector<std::string>::const_iterator it = packages.begin();
  while (it != packages.end())
  {
    disablePackage(*it);
    ++it;
  }  
}
/** @endcond */

/*
 * Enables the package with the given URI / name.
 */
void
SBMLExtensionRegistry::enablePackage(const std::string& package)
{
  SBMLExtension *ext = const_cast<SBMLExtension*>(getInstance().getExtensionInternal(package));
  if (ext != NULL)
    ext->setEnabled(true);  
}

/*
 * @returns the status (enabled = <b>true</b>, disabled = <b>false</b> of the given package.
 */
bool
SBMLExtensionRegistry::isPackageEnabled(const std::string& package)
{
  const SBMLExtension *ext = getInstance().getExtensionInternal(package);
  if (ext != NULL)
    return ext->isEnabled();
  return false;
}

/** @cond doxygenLibsbmlInternal */
/*
 * Enables all packages with the given URI / name.
 */
void
SBMLExtensionRegistry::enablePackages(const std::vector<std::string>& packages)
{
  std::vector<std::string>::const_iterator it = packages.begin();
  while (it != packages.end())
  {
    enablePackage(*it);
    ++it;
  }
}
/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
int 
SBMLExtensionRegistry_addExtension(const SBMLExtension_t* extension)
{
  if (extension == NULL) return LIBSBML_INVALID_OBJECT;
  return SBMLExtensionRegistry::getInstance().addExtension(extension);
}

LIBSBML_EXTERN
SBMLExtension_t* 
SBMLExtensionRegistry_getExtension(const char* package)
{
  if (package == NULL) return NULL;
  string sPackage(package);
  return SBMLExtensionRegistry::getInstance().getExtension(sPackage);
}

LIBSBML_EXTERN
const SBasePluginCreatorBase_t* 
SBMLExtensionRegistry_getSBasePluginCreator(const SBaseExtensionPoint_t* extPoint, const char* uri)
{
  if (extPoint == NULL || uri == NULL) return NULL;
  string sUri(uri);
  return SBMLExtensionRegistry::getInstance().getSBasePluginCreator(*extPoint, sUri);
}

LIBSBML_EXTERN
SBasePluginCreatorBase_t**
SBMLExtensionRegistry_getSBasePluginCreators(const SBaseExtensionPoint_t* extPoint, int* length)
{
  if (extPoint == NULL || length == NULL) return NULL;

  std::list<const SBasePluginCreatorBase*> list = 
    SBMLExtensionRegistry::getInstance().getSBasePluginCreators(*extPoint);

  *length = (int)list.size();
  SBasePluginCreatorBase_t** result = (SBasePluginCreatorBase_t**)malloc(sizeof(SBasePluginCreatorBase_t*)*(*length));
  
  std::list<const SBasePluginCreatorBase*>::iterator it;
  int count = 0;
  for (it = list.begin(); it != list.end(); it++)
  {
    result[count++] = (*it)->clone();
  }
  
  return result;
}

LIBSBML_EXTERN
SBasePluginCreatorBase_t**
SBMLExtensionRegistry_getSBasePluginCreatorsByURI(const char* uri, int* length)
{
   if (uri == NULL || length == NULL) return NULL;
   string sUri(uri);
   std::list<const SBasePluginCreatorBase*> list = 
     SBMLExtensionRegistry::getInstance().getSBasePluginCreators(sUri);
 
   *length = (int)list.size();
   SBasePluginCreatorBase_t** result = (SBasePluginCreatorBase_t**)malloc(sizeof(SBasePluginCreatorBase_t*)*(*length));
   
   std::list<const SBasePluginCreatorBase*>::iterator it;
   int count = 0;
   for (it = list.begin(); it != list.end(); it++)
   {
     result[count++] = (*it)->clone();
   }
  
  return result;
}


LIBSBML_EXTERN
int
SBMLExtensionRegistry_isEnabled(const char* uri)
{
  if (uri == NULL) return 0;
  string sUri(uri);
  return SBMLExtensionRegistry::getInstance().isEnabled(sUri);
}

LIBSBML_EXTERN
int
SBMLExtensionRegistry_setEnabled(const char* uri, int isEnabled)
{
  if (uri == NULL) return 0;
  string sUri(uri);  
  return SBMLExtensionRegistry::getInstance().setEnabled(sUri, isEnabled);
}

LIBSBML_EXTERN
int
SBMLExtensionRegistry_isRegistered(const char* uri)
{
  if (uri == NULL) return 0;
  string sUri(uri);
  return (int)SBMLExtensionRegistry::getInstance().isRegistered(sUri);
}

LIBSBML_EXTERN
int 
SBMLExtensionRegistry_getNumExtensions(const SBaseExtensionPoint_t* extPoint)
{
  if (extPoint == NULL) return 0;
  return SBMLExtensionRegistry::getInstance().getNumExtension(*extPoint);
}


LIBSBML_EXTERN
List_t*
SBMLExtensionRegistry_getRegisteredPackages()
{
  return (List_t*)SBMLExtensionRegistry::getRegisteredPackageNames();
}


/** 
 * Returns the number of registered packages.
 * 
 * @return the number of registered packages.
 */
LIBSBML_EXTERN
int
SBMLExtensionRegistry_getNumRegisteredPackages()
{
  return (int)SBMLExtensionRegistry::getNumRegisteredPackages();
}


/** 
 * Returns the registered package name at the given index
 * 
 * @param index zero based index of the package name to return
 * 
 * @return the package name with the given index or NULL
 */
LIBSBML_EXTERN
char*
SBMLExtensionRegistry_getRegisteredPackageName(int index)
{
  return safe_strdup(SBMLExtensionRegistry::getRegisteredPackageName(index).c_str());
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

