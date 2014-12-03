/**
 * @file    SBMLExtensionRegistry.h
 * @brief   Definition of SBMLExtensionRegistry, the registry class in which
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
 *
 * @class SBMLExtensionRegistry
 * @sbmlbrief{core} Registry where package plug-ins are registered.
 *
 */

#ifndef SBMLExtensionRegistry_h
#define SBMLExtensionRegistry_h

#include <sbml/extension/SBMLExtension.h>
LIBSBML_CPP_NAMESPACE_BEGIN


#ifdef __cplusplus

#include <list>
#include <map>


class LIBSBML_EXTERN SBMLExtensionRegistry
{
public:

#ifndef SWIG
  /** @cond doxygenLibsbmlInternal */

  //
  // typedef for SBasePluginCreatorBase
  //
  typedef std::multimap<SBaseExtensionPoint, const SBasePluginCreatorBase*> SBasePluginMap;
  typedef std::pair<SBaseExtensionPoint, const SBasePluginCreatorBase*>     SBasePluginPair;
  typedef SBasePluginMap::iterator                                          SBasePluginMapIter;

  //
  // typedef for SBMLExtension
  //
  typedef std::map<std::string, const SBMLExtension*>              SBMLExtensionMap;
  typedef std::pair<std::string, const SBMLExtension*>             SBMLExtensionPair;
  typedef SBMLExtensionMap::iterator                               SBMLExtensionMapIter;
  /** @endcond */
#endif //SWIG

  /**
   *
   * Returns an instance (singleton) of the SBMLExtensionRegistry class.
   * This function needs to be invoked when manipulating the SBMLExtensionRegistry class. 
   *
   * @return the instance of the SBMLExtensionRegistry object.
   */ 
  static SBMLExtensionRegistry& getInstance();


  /**
   * Add the given SBMLExtension to this SBMLExtensionRegistry.
   *
   * @param ext the SBMLExtension object to be added.
   *   
   * @return integer value indicating success/failure of the
   * function.  The possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_PKG_CONFLICT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int addExtension (const SBMLExtension* ext);


  /**
   * Returns an SBMLExtension object with the given package URI or package name (string).
   *
   * @param package the URI or name of the package extension
   *
   * @return a clone of the SBMLExtension object with the given package URI or name. The returned 
   *         extension is to be freed (i.e.: deleted) by the caller!
   */
  SBMLExtension* getExtension(const std::string& package);

  /**
   * Remove all L2 Extension namespaces from the namespace list. This will call all 
   * overriden SBMLExtension::removeL2Namespaces methods.
   */
  void removeL2Namespaces(XMLNamespaces *xmlns) const;

  /**
   * adds all L2 Extension namespaces to the namespace list. This will call all 
   * overriden SBMLExtension::addL2Namespaces methods.
   */
  void addL2Namespaces(XMLNamespaces *xmlns) const;

  /**
   * Enables all extensions that support serialization / deserialization with
   * SBML Annotations.
   */
  void enableL2NamespaceForDocument(SBMLDocument* doc)  const;

  /** 
   * Goes through all extensions in the list of plugins of the given document
   * and disables all plugins that are not being used. 
   */
  void disableUnusedPackages(SBMLDocument *doc);

  /**
   * Disables the package with the given URI / name.
   */
  static void disablePackage(const std::string& package);

  #ifndef SWIG
  /**
   * Disables all packages with the given URI / name.
   */
  static void disablePackages(const std::vector<std::string>& packages);
  #endif
  
  /**
   * If the given @p package is enabled, returns @c true; otherwise,
   * returns @c false.
   *
   * @return the status (enabled = <b>true</b>, disabled = <b>false</b> of the given package.
   */
  static bool isPackageEnabled(const std::string& package);
  
  /**
   * Enables the package with the given URI / name.
   */
  static void enablePackage(const std::string& package);
  
  #ifndef SWIG
  /**
   * Enables all packages with the given URI / name.
   */
  static void enablePackages(const std::vector<std::string>& packages);
  #endif
  
private:
  /**
   * Returns an SBMLExtension object with the given package URI or package name (string).
   *
   * @param package the URI or name of the package extension
   *
   * @return the SBMLExtension object with the given package URI or name. The returned 
   *         extension is NOT ALLOWED to be freed (i.e.: deleted)!
   */
  const SBMLExtension* getExtensionInternal(const std::string& package);

public:

#ifndef SWIG

  /**
   * Returns the list of SBasePluginCreators with the given extension point.
   *
   * @param extPoint the SBaseExtensionPoint
   *
   * @return the list of SBasePluginCreators with the given typecode.
   */
  std::list<const SBasePluginCreatorBase*> getSBasePluginCreators(const SBaseExtensionPoint& extPoint);


  /**
   * Returns the list of SBasePluginCreators with the given URI
   * of package extension.
   *
   * @param uri the URI of the target package extension.
   *
   * @return the list of SBasePluginCreators with the given URI
   * of package extension.
   */
  std::list<const SBasePluginCreatorBase*> getSBasePluginCreators(const std::string& uri);
	             

  /**
   * Returns an SBasePluginCreator object with the combination of the given 
   * extension point and URI of the package extension.
   *
   * @param extPoint the SBaseExtensionPoint
   * @param uri the URI of the target package extension.
   *
   * @return the SBasePluginCreator with the combination of the given 
   * SBMLTypeCode_t and the given URI of package extension.
   */
  const SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint,
                                                      const std::string& uri);
  
  /** 
   * This function deletes the SBML Extension Registry. It is not meant
   * to be called by programs directly, it will be automatically called
   * by the C++ runtime, at the end of the program. 
   */
  static void deleteRegistry();

#endif //SWIG

  /**
   * Returns the number of SBMLExtension* with the given extension point.
   *
   * @param extPoint the SBaseExtensionPoint
   *
   * @return the number of SBMLExtension* with the given extension point.
   */
  unsigned int getNumExtension(const SBaseExtensionPoint& extPoint);


  /**
   * Enable/disable the package with the given uri.
   *
   * @param uri the URI of the target package.
   * @param isEnabled the bool value corresponding to enabled (true) or 
   * disabled (false)
   *
   * @return false will be returned if the given bool value is false 
   * or the given package is not registered, otherwise true will be
   * returned.
   */
  bool
  setEnabled(const std::string& uri, bool isEnabled);
  

  /**
   * Checks if the extension with the given URI is enabled (true) or 
   * disabled (false)
   *
   * @param uri the URI of the target package.
   *
   * @return false will be returned if the given package is disabled 
   * or not registered, otherwise true will be returned.
   */
  bool isEnabled(const std::string& uri);


  /**
   * Checks if the extension with the given URI is registered (true) 
   * or not (false)
   *
   * @param uri the URI of the target package.
   *
   * @return true will be returned if the package with the given URI
   * is registered, otherwise false will be returned.
   */
  bool isRegistered(const std::string& uri);


  /** 
   * Returns a list of registered packages (such as 'layout', 'fbc' or 'comp')
   * the list contains char* strings and has to be freed by the caller. 
   * 
   * @return the names of the registered packages in a list
   */
  static List* getRegisteredPackageNames();

  /** 
   * Returns the number of registered packages.
   * 
   * @return the number of registered packages.
   */
  static unsigned int getNumRegisteredPackages();


  /** 
   * Returns the registered package name at the given index
   * 
   * @param index zero based index of the package name to return
   * 
   * @return the package name with the given index or NULL
   */
  static std::string getRegisteredPackageName(unsigned int index);

private:

  //
  // Constructor and Copy constructor must not be overridden.
  //
  SBMLExtensionRegistry();
  SBMLExtensionRegistry(const SBMLExtensionRegistry& orig);
  SBMLExtensionRegistry& operator= (const SBMLExtensionRegistry& rhs);
  ~SBMLExtensionRegistry();

  
  static bool registered;

  /** @cond doxygenLibsbmlInternal */
 
  SBMLExtensionMap  mSBMLExtensionMap;
  SBasePluginMap    mSBasePluginMap;

  static SBMLExtensionRegistry* mInstance;

  //
  // Allow getExtensionInternal to be used from within libsbml. 
  //
  friend class SBMLTypeCodes;
  friend class SBMLNamespaces;
  friend class SBMLDocument;
  friend class SBasePlugin;
  friend class SBase;
  friend class ASTBasePlugin;
  friend class ASTBase;
  friend class L3ParserSettings;
  template <class SBMLExtensionType> friend class SBMLExtensionNamespaces;
  template<class SBasePluginType, class SBMLExtensionType> friend class SBasePluginCreator;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Add the given SBMLExtension_t to the SBMLExtensionRegistry_t.
 *
 * @param extension the SBMLExtension_t structure to be added.
 *   
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_PKG_CONFLICT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int 
SBMLExtensionRegistry_addExtension(const SBMLExtension_t* extension);

/**
 * Returns an SBMLExtension_t structure with the given package URI or package name (string).
 *
 * @param package the URI or name of the package extension
 *
 * @return a clone of the SBMLExtension_t structure with the given package URI or name. 
 * Or NULL in case of an invalid package name.
 * 
 * @note The returned extension is to be freed (i.e.: deleted) by the caller!
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
SBMLExtension_t* 
SBMLExtensionRegistry_getExtension(const char* package);

/**
 * Returns an SBasePluginCreator_t structure with the combination of the given 
 * extension point and URI of the package extension.
 *
 * @param extPoint the SBaseExtensionPoint_t
 * @param uri the URI of the target package extension.
 *
 * @return the SBasePluginCreator_t with the combination of the given 
 * SBMLTypeCode_t and the given URI of package extension, or @c NULL for 
 * invalid extensionPoint or uri.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
const SBasePluginCreatorBase_t* 
SBMLExtensionRegistry_getSBasePluginCreator(const SBaseExtensionPoint_t* extPoint, const char* uri);

/**
 * Returns a copied array of SBasePluginCreators with the given extension point.
 *
 * @param extPoint the SBaseExtensionPoint_t
 * @param length pointer to a variable holding the length of the array returned. 
 *
 * @return an array of SBasePluginCreators with the given typecode.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t**
SBMLExtensionRegistry_getSBasePluginCreators(const SBaseExtensionPoint_t* extPoint, int* length);

/**
 * Returns a copied array of SBasePluginCreators with the given URI
 * of package extension.
 *
 * @param uri the URI of the target package extension.
 * @param length pointer to a variable holding the length of the array returned. 
 *
 * @return an array of SBasePluginCreators with the given URI
 * of package extension to be freed by the caller.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t**
SBMLExtensionRegistry_getSBasePluginCreatorsByURI(const char* uri, int* length);


/**
 * Checks if the extension with the given URI is enabled (true) or 
 * disabled (false)
 *
 * @param uri the URI of the target package.
 *
 * @return false (0) will be returned if the given package is disabled 
 * or not registered, otherwise true (1) will be returned.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int
SBMLExtensionRegistry_isEnabled(const char* uri);

/**
 * Enable/disable the package with the given uri.
 *
 * @param uri the URI of the target package.
 * @param isEnabled the bool value corresponding to enabled (true/1) or 
 * disabled (false/0)
 *
 * @return false (0) will be returned if the given bool value is false 
 * or the given package is not registered, otherwise true (1) will be
 * returned.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int
SBMLExtensionRegistry_setEnabled(const char* uri, int isEnabled);


/**
 * Checks if the extension with the given URI is registered (true/1) 
 * or not (false/0)
 *
 * @param uri the URI of the target package.
 *
 * @return true (1) will be returned if the package with the given URI
 * is registered, otherwise false (0) will be returned.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int
SBMLExtensionRegistry_isRegistered(const char* uri);


/**
 * Returns the number of SBMLExtension_t structures for the given extension point.
 *
 * @param extPoint the SBaseExtensionPoint_t
 *
 * @return the number of SBMLExtension_t structures for the given extension point.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int 
SBMLExtensionRegistry_getNumExtensions(const SBaseExtensionPoint_t* extPoint);

/** 
 * Returns a list of registered packages (such as 'layout', 'fbc' or 'comp')
 * the list contains char* strings and has to be freed by the caller. 
 * 
 * @return the names of the registered packages in a list
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
List_t*
SBMLExtensionRegistry_getRegisteredPackages();

/** 
 * Returns the number of registered packages.
 * 
 * @return the number of registered packages.
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
int
SBMLExtensionRegistry_getNumRegisteredPackages();


/** 
 * Returns the registered package name at the given index
 * 
 * @param index zero based index of the package name to return
 * 
 * @return the package name with the given index or NULL
 *
 * @memberof SBMLExtensionRegistry_t
 */
LIBSBML_EXTERN
char*
SBMLExtensionRegistry_getRegisteredPackageName(int index);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* SBMLExtensionRegistry_h */

