/**
 * @file    SBMLExtensionRegistry.h
 * @brief   The registry class for tracking package extensions.
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
 *
 * @class SBMLExtensionRegistry
 * @sbmlbrief{core} Registry where package extensions are registered.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This class provides a central registry of all extensions known to libSBML.
 * Each package extension must be registered with the registry.  The registry
 * class is accessed by various classes to retrieve information about known
 * package extensions and to create additional attributes and/or elements by
 * factory objects of the package extensions.
 *
 * @copydetails doc_extension_sbmlextensionregistry
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
   * Returns a singleton instance of the registry.
   *
   * Callers need to obtain a copy of the package extension registry before
   * they can invoke its methods.  The registry is implemented as a
   * singleton, and this is the method callers can use to get a copy of it.
   *
   * @return the instance of the SBMLExtensionRegistry object.
   */
  static SBMLExtensionRegistry& getInstance();


  /**
   * Add the given SBMLExtension object to this SBMLExtensionRegistry.
   *
   * @param ext the SBMLExtension object to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_PKG_CONFLICT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int addExtension (const SBMLExtension* ext);


  /**
   * Returns an SBMLExtension object with the given package URI or package
   * name.
   *
   * @param package a string representing the URI or name of the SBML package
   * whose package extension is being sought.
   *
   * @return a clone of the SBMLExtension object with the given package URI
   * or name.
   *
   * @note The caller is responsible for freeing the object returned.  Since
   * the object is a clone, freeing it will not result in the deletion of the
   * original package extension object.
   */
  SBMLExtension* getExtension(const std::string& package);


  /**
   * Removes SBML Level&nbsp;2 namespaces from the namespace list.
   *
   * @if clike 
   * This will call all overridden
   * <code>SBMLExtension::removeL2Namespaces()</code> methods.
   * @endif@~
   *
   * @param xmlns an XMLNamespaces object listing one or more namespaces
   * to be removed.
   */
  void removeL2Namespaces(XMLNamespaces *xmlns) const;


  /**
   * Adds SBML Level&nbsp;2 namespaces to the namespace list.
   *
   * @if clike
   * This will call all overridden
   * <code>SBMLExtension::addL2Namespaces()</code> methods.
   * @endif@~
   *
   * @param xmlns an XMLNamespaces object providing one or more namespaces to
   * be added.
   */
  void addL2Namespaces(XMLNamespaces *xmlns) const;


  /**
   * Enables package extensions that support serialization to SBML annotations.
   *
   * SBML Level&nbsp;2 does not have a package mechanism in the way that SBML
   * Level&nbsp;3 does.  However, SBML annotations can be used to store SBML
   * constructs.  In fact, a widely-used approach to developing SBML
   * Level&nbsp;3 packages involves first using them as annotations.
   *
   * @param doc the SBMLDocument object for which this should be enabled.
   */
  void enableL2NamespaceForDocument(SBMLDocument* doc)  const;


  /**
   * Disables unused packages.
   *
   * This method walks through all extensions in the list of plugins of the
   * given SBML document @p doc, and disables all that are not being used.
   *
   * @param doc the SBMLDocument object whose unused package extensions
   * should be disabled.
   */
  void disableUnusedPackages(SBMLDocument *doc);


  /**
   * Disables the package with the given URI or name.
   *
   * @param package a string representing the URI or name of the SBML package
   * whose package extension is to be disabled.
   */
  static void disablePackage(const std::string& package);


  #ifndef SWIG
  /**
   * Disables all packages with the given URI / name.
   *
   * @param packages a vector of package names or URIs.
   */
  static void disablePackages(const std::vector<std::string>& packages);
  #endif


  /**
   * Returns @c true if the named package is enabled.
   *
   * @param package the name or URI of a package to test.
   *
   * @return @c true if the package is enabled, @c false otherwise.
   */
  static bool isPackageEnabled(const std::string& package);


  /**
   * Enables the package with the given URI / name.
   *
   * @param package the name or URI of a package to enable.
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
   * Returns the list of SBasePluginCreators with the given package URI.
   *
   * @param uri the URI of the target package extension.
   *
   * @return the list of SBasePluginCreators with the given URI
   * of package extension.
   */
  std::list<const SBasePluginCreatorBase*> getSBasePluginCreators(const std::string& uri);


  /**
   * Returns an SBasePluginCreator object with the combination of the given
   * extension point and package URI.
   *
   * @param extPoint the SBaseExtensionPoint
   * @param uri the URI of the target package extension.
   *
   * @return the SBasePluginCreator object corresponding to the arguments.
   */
  const SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint,
                                                      const std::string& uri);

  /**
   * Delete the SBML extension registry.
   *
   * It is not meant to be called by programs directly, it will be
   * automatically called by the C++ runtime, at the end of the program.
   */
  static void deleteRegistry();

#endif //SWIG

  /**
   * Returns the number of extensions that have a given extension point.
   *
   * @param extPoint the SBaseExtensionPoint object
   *
   * @return the number of SBMLExtension-derived objects with the given
   * extension point.
   */
  unsigned int getNumExtension(const SBaseExtensionPoint& extPoint);


  /**
   * Enables or disable the package with the given URI.
   *
   * @param uri the URI of the target package.
   * @param isEnabled @c true to enable the package, @c false to disable.
   *
   * @return @c false if @p isEnabled is @c false or the given package is not
   * registered, otherwise this method returns @c true.
   */
  bool setEnabled(const std::string& uri, bool isEnabled);


  /**
   * Returns @c true if the given extension is enabled.
   *
   * @param uri the URI of the target package.
   *
   * @return @c false if the given package is disabled or not registered,
   * @c true otherwise.
   */
  bool isEnabled(const std::string& uri);


  /**
   * Returns @c true if a package extension is registered for the
   * corresponding package URI.
   *
   * @param uri the URI of the target package.
   *
   * @return @c true if the package with the given URI is registered,
   * otherwise returns @c false.
   */
  bool isRegistered(const std::string& uri);


  /**
   * Returns a list of registered packages.
   *
   * This method returns a List object containing the nicknames of the SBML
   * packages for which package extensions are registered with this copy of
   * libSBML.  The list will contain strings (e.g., <code>"layout"</code>,
   * <code>"fbc"</code>, etc.) and has to be freed by the caller.
   *
   * @return a list of strings representing the names of the registered
   * packages.
   */
  static List* getRegisteredPackageNames();


  /**
   * Returns a list of registered packages.
   *
   * This method returns a vector of strings containing the nicknames of the
   * SBML packages for which package extensions are registered with this copy
   * of libSBML.  The vector will contain <code>std::string</code> objects.
   *
   * @return a vector of strings
   */
  static std::vector<std::string> getAllRegisteredPackageNames();


  /**
   * Returns the number of registered packages.
   *
   * @return a count of the registered package extensions.
   *
   * @if clike
   * @see getRegisteredPackageNames()
   * @endif@~
   */
  static unsigned int getNumRegisteredPackages();


  /**
   * Returns the nth registered package.
   *
   * @param index zero-based index of the package name to return.
   *
   * @return the package name with the given index, or @c NULL if none
   * such exists.
   *
   * @see getNumRegisteredPackages()
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
 * @copydetails doc_returns_success_code
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

