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
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This is the base class of the SBasePluginCreator template class.  This
 * contains virtual methods that need to be overridden by subclasses.
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
   * Destroys this SBasePluginCreatorBase object.
   */
  virtual ~SBasePluginCreatorBase ();


  /**
   * Creates an SBasePlugin object with a URI and package prefix.
   *
   * @param uri the XML namespace URI for the SBML package
   *
   * @param prefix the namespace prefix
   *
   * @param xmlns an XMLNamespaces object that identifies namespaces in
   * use by this package extension
   */
  virtual SBasePlugin* createPlugin(const std::string& uri,
                                    const std::string& prefix,
                                    const XMLNamespaces *xmlns) const = 0;


  /**
   * Creates and returns a deep copy of this SBasePluginCreatorBase.
   *
   * @return a (deep) copy of this SBasePluginCreatorBase.
   */
  virtual SBasePluginCreatorBase* clone() const = 0;


  /**
   * Returns the number of package URIs supported by this creator object.
   *
   * @return the number of package URIs supported.
   *
   * @see getSupportedPackageURI()
   */
  unsigned int getNumOfSupportedPackageURI() const;


  /**
   * Returns the URI of the ith package supported by this creator object.
   *
   * @param i the index of the URI being sought.
   *
   * @return the URI being sought, in the form of a string.  If no such
   * URI exists, this method will return an empty string.
   *
   * @see getNumOfSupportedPackageURI()
   */
  std::string getSupportedPackageURI(unsigned int i) const;


  /**
   * Returns a libSBML type code tied to this creator object.
   *
   * @return the integer type code.
   */
  int getTargetSBMLTypeCode() const;


  /**
   * Returns the target package name of this creator object.
   *
   * @return a string, the package name
   */
  const std::string& getTargetPackageName() const;


  /**
   * Returns an SBaseExtensionPoint object tied to this creator object.
   *
   * @return the extension point associated with this creator object.
   */
  const SBaseExtensionPoint& getTargetExtensionPoint() const;


  /**
   * Returns @c true if a package with the given namespace URI is supported.
   *
   * @param uri the XML namespace URI to test.
   *
   * @return @c true if the URI applies to this package extension, @c false
   * otherwise.
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
 * Frees the given SBasePluginCreatorBase_t structure
 * 
 * @param plugin the SBasePluginCreatorBase_t structure to be freed
 * 
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePluginCreator_free(SBasePluginCreatorBase_t* creator);


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

