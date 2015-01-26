/**
 * @file    SBasePluginCreatorBase.h
 * @brief   Definition of SBasePluginCreatorBase, the base class of 
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
 *
 * @class SBasePluginCreatorBase
 * @sbmlbrief{core} Base class of %SBasePluginCreator.
 */

#ifndef SBasePluginCreatorBase_h
#define SBasePluginCreatorBase_h


#include <sbml/SBMLDocument.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/extension/SBaseExtensionPoint.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class SBasePlugin;

class LIBSBML_EXTERN SBasePluginCreatorBase
{
public:

  typedef std::vector<std::string>           SupportedPackageURIList;
  typedef std::vector<std::string>::iterator SupportedPackageURIListIter;

  /**
   * Destructor
   */
  virtual ~SBasePluginCreatorBase ();


  /**
   * Creates an SBasePlugin with the given uri and the prefix
   * of the target package extension.
   */
  virtual SBasePlugin* createPlugin(const std::string& uri, 
                                    const std::string& prefix,
                                    const XMLNamespaces *xmlns) const = 0;


  /**
   * Creates and returns a deep copy of this SBasePluginCreatorBase.  Must be overridden by child classes.
   * 
   * @return a (deep) copy of this SBasePluginCreatorBase.
   */
  virtual SBasePluginCreatorBase* clone() const = 0;


  /**
   * Returns the number of supported packages by this creator object.
   */
  unsigned int getNumOfSupportedPackageURI() const;


  /**
   * Returns the supported package to the given index.
   */
  std::string getSupportedPackageURI(unsigned int) const;


  /**
   * Returns an SBMLTypeCode tied to this creator object.
   */
  int getTargetSBMLTypeCode() const;


  /**
   * Returns the target package name of this creator object.
   */
  const std::string& getTargetPackageName() const;


  /**
   * Returns an SBaseExtensionPoint tied to this creator object.
   */
  const SBaseExtensionPoint& getTargetExtensionPoint() const;


  /**
   * Returns true if a package with the given namespace is supported.
   */
  bool isSupported(const std::string& uri) const;

protected:

  /**
   * Constructor
   */
  SBasePluginCreatorBase (const SBaseExtensionPoint& extPoint,
                          const std::vector<std::string>&);


  /**
   * Copy Constructor
   */
  SBasePluginCreatorBase (const SBasePluginCreatorBase&);

  /** @cond doxygenLibsbmlInternal */

  SupportedPackageURIList  mSupportedPackageURI;
  SBaseExtensionPoint       mTargetExtensionPoint;

  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */
  
  SBasePluginCreatorBase& operator=(const SBasePluginCreatorBase&);

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

  
#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates an SBasePlugin_t structure with the given uri and the prefix
 * of the target package extension.
 *
 * @param creator the SBasePluginCreatorBase_t structure  
 * @param uri the package extension uri
 * @param prefix the package extension prefix
 * @param xmlns the package extension namespaces
 *
 * @return an SBasePlugin_t structure with the given uri and the prefix
 * of the target package extension, or @c NULL in case an invalid creator, uri 
 * or prefix was given.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBasePlugin_t*
SBasePluginCreator_createPlugin(SBasePluginCreatorBase_t* creator, 
  const char* uri, const char* prefix, const XMLNamespaces_t* xmlns);

/**
 * Creates a deep copy of the given SBasePluginCreatorBase_t structure
 * 
 * @param creator the SBasePluginCreatorBase_t structure to be copied
 * 
 * @return a (deep) copy of the given SBasePluginCreatorBase_t structure.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t*
SBasePluginCreator_clone(SBasePluginCreatorBase_t* creator);


/**
 * Returns the number of supported packages by the given creator structure.
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * 
 * @return the number of supported packages by the given creator structure.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
unsigned int
SBasePluginCreator_getNumOfSupportedPackageURI(SBasePluginCreatorBase_t* creator);

/**
 * Returns a copy of the package uri with the specified index. 
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * @param index the index of the package uri to return
 * 
 * @return a copy of the package uri with the specified index
 * (Has to be freed by the caller). If creator is invalid NULL will 
 * be returned.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
char*
SBasePluginCreator_getSupportedPackageURI(SBasePluginCreatorBase_t* creator, 
    unsigned int index);

/**
 * Returns the SBMLTypeCode_t tied to the creator structure.
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * 
 * @return the SBMLTypeCode_t tied with the creator structure or 
 * LIBSBML_INVALID_OBJECT.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePluginCreator_getTargetSBMLTypeCode(SBasePluginCreatorBase_t* creator);

/**
 * Returns the target package name of the creator structure.
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * 
 * @return the target package name of the creator structure, or @c NULL if 
 * creator is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
const char*
SBasePluginCreator_getTargetPackageName(SBasePluginCreatorBase_t* creator);

/**
 * Returns the SBaseExtensionPoint_t tied to this creator structure.
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * 
 * @return the SBaseExtensionPoint_t of the creator structure, or @c NULL if 
 * creator is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
const SBaseExtensionPoint_t*
SBasePluginCreator_getTargetExtensionPoint(SBasePluginCreatorBase_t* creator);

/**
 * Returns true (1), if a package with the given namespace is supported. 
 * 
 * @param creator the SBasePluginCreatorBase_t structure
 * @param uri the package uri to test
 * 
 * @return true (1), if a package with the given namespace is supported.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int 
SBasePluginCreator_isSupported(SBasePluginCreatorBase_t* creator, const char* uri);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* SBasePluginCreatorBase_h */

