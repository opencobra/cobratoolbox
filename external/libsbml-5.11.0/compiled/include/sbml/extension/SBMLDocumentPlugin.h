/**
 * @file    SBMLDocumentPlugin.h
 * @brief   Definition of SBMLDocumentPlugin, the derived class of SBasePlugin.
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
 * @class SBMLDocumentPlugin
 * @sbmlbrief{core} Base class for extending SBMLDocument in packages.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBMLDocumentPlugin class is a specialization of SBasePlugin
 * designed specifically for extending SBMLDocument.  All package
 * extensions must extend SBMLDocument to implement support for SBML
 * Level&nbsp;3 packages; these extensions can be subclasses of this
 * class or from a derived class of this class.
 *
 * @section sbmldocumentplugin-howto How to extend SBMLDocumentPlugin for a package implementation
 * @copydetails doc_extension_sbmldocumentplugin
 */

#ifndef SBMLDocumentPlugin_h
#define SBMLDocumentPlugin_h

#include <sbml/common/sbmlfwd.h>
#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBMLDocument.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/extension/SBasePlugin.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLDocumentPlugin : public SBasePlugin
{
public:

  /**
   * Creates a new SBMLDocumentPlugin object using the given parameters.
   *
   * @copydetails doc_what_are_xmlnamespaces
   *
   * @copydetails doc_what_are_sbmlnamespaces
   *
   * @param uri the URI of the SBML Level&nbsp;3 package implemented by
   * this libSBML package extension.
   *
   * @param prefix the XML namespace prefix being used for the package.
   *
   * @param sbmlns the SBMLNamespaces object for the package.
   */
  SBMLDocumentPlugin (const std::string &uri, const std::string &prefix,
                      SBMLNamespaces *sbmlns);


  /**
   * Copy constructor.
   *
   * This creates a copy of this object.
   *
   * @param orig the SBMLDocumentPlugin instance to copy.
   */
  SBMLDocumentPlugin(const SBMLDocumentPlugin& orig);


  /**
   * Destroy this SBMLDocumentPlugin object.
   */
  virtual ~SBMLDocumentPlugin ();


  /**
   * Assignment operator for SBMLDocumentPlugin.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   */
  SBMLDocumentPlugin& operator=(const SBMLDocumentPlugin& rhs);


  /**
   * Creates and returns a deep copy of this SBMLDocumentPlugin object.
   *
   * @return the (deep) copy of this SBMLDocumentPlugin object.
   */
  virtual SBMLDocumentPlugin* clone () const;


  // ----------------------------------------------------------
  //
  // overridden virtual functions for reading/writing/checking
  // attributes
  //
  // ----------------------------------------------------------

#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */

  /**
   * Subclasses should override this method to get the list of
   * expected attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Reads the attributes of corresponding package in SBMLDocument element.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Writes the attributes of corresponding package in SBMLDocument element.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;

  /** @endcond */

#endif //SWIG

  // -----------------------------------------------------------
  //
  // Additional public functions for manipulating attributes of
  // corresponding package in SBMLDocument element.
  //
  // -----------------------------------------------------------


  /**
   * Sets the SBML "required" attribute value.
   *
   * @copydetails doc_what_is_required_attribute
   *
   * @param value the value to be assigned to the "required" attribute.
   * The "required" attribute takes a Boolean value, either @c true or
   * @c false.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @see getRequired()
   * @see isSetRequired()
   * @see unsetRequired()
   */
  virtual int setRequired(bool value);


  /**
   * Returns the value of the "required" attribute.
   *
   * @copydetails doc_what_is_required_attribute
   *
   * @return the bool value of "required" attribute for the SBML package.
   *
   * @see setRequired(bool value)
   * @see isSetRequired()
   * @see unsetRequired()
   */
  virtual bool getRequired() const;


  /**
   * Returns the value of the "required" attribute.
   *
   * @copydetails doc_what_is_required_attribute
   *
   * @return @c true if the "required" attribute of this SBMLDocument
   * has been set to @c true, @c false otherwise.
   */
  virtual bool isSetRequired() const;


  /**
   * Unsets the value of the "required" attribute of this SBMLDocumentPlugin.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  virtual int unsetRequired();


  /** @cond doxygenLibsbmlInternal */
  virtual bool isCompFlatteningImplemented() const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Check consistency function.
   */
  virtual unsigned int checkConsistency();
  /** @endcond */


protected:
  /*-- data members --*/

  bool mRequired;
  bool mIsSetRequired;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new SBMLDocumentPlugin_t structure with the given package
 * uri, prefix and SBMLNamespaces.
 *
 * @param uri the package uri
 * @param prefix the package prefix
 * @param sbmlns the namespaces
 *
 * @return a new SBMLDocumentPlugin_t structure with the given package
 * uri, prefix and SBMLNamespaces. Or null in case a NULL uri or prefix
 * was given.
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
SBMLDocumentPlugin_t*
SBMLDocumentPlugin_create(const char* uri, const char* prefix,
      SBMLNamespaces_t* sbmlns);

/**
 * Frees the given SBMLDocumentPlugin_t structure
 *
 * @param plugin the SBMLDocumentPlugin_t structure to be freed
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_free(SBMLDocumentPlugin_t* plugin);

/**
 * Creates a deep copy of the given SBMLDocumentPlugin_t structure
 *
 * @param plugin the SBMLDocumentPlugin_t structure to be copied
 *
 * @return a (deep) copy of the given SBMLDocumentPlugin_t structure.
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
SBMLDocumentPlugin_t*
SBMLDocumentPlugin_clone(SBMLDocumentPlugin_t* plugin);

/**
 * Subclasses should override this method to get the list of
 * expected attributes if they have their specific attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 *
 * @param plugin the SBMLDocumentPlugin_t structure
 * @param attributes the ExpectedAttributes_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_addExpectedAttributes(SBMLDocumentPlugin_t* plugin,
      ExpectedAttributes_t* attributes);

/**
 * Subclasses must override this method to read values from the given
 * XMLAttributes_t if they have their specific attributes.
 *
 * @param plugin the SBMLDocumentPlugin_t structure
 * @param attributes the XMLAttributes_t structure
 * @param expectedAttributes the ExpectedAttributes_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_readAttributes(SBMLDocumentPlugin_t* plugin,
      const XMLAttributes_t* attributes,
      const ExpectedAttributes_t* expectedAttributes);

/**
 * Subclasses must override this method to write their XML attributes
 * to the XMLOutputStream_t if they have their specific attributes.
 *
 * @param plugin the SBMLDocumentPlugin_t structure
 * @param stream the XMLOutputStream_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_writeAttributes(SBMLDocumentPlugin_t* plugin,
      XMLOutputStream_t* stream);


/**
 * Returns the value of "required" attribute of corresponding
 * package in the SBMLDocument_t element. The value is true (1) if the
 * package is required, or false (0) otherwise.
 *
 * @param plugin the SBMLDocumentPlugin_t structure
 *
 * @return the value of "required" attribute of corresponding
 * package in the SBMLDocument_t element. The value is true (1) if the
 * package is required, or false (0) otherwise. If the plugin is invalid
 * LIBSBML_INVALID_OBJECT will be returned.
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_getRequired(SBMLDocumentPlugin_t* plugin);


/**
 * Sets the value of "required" attribute of corresponding
 * package in the SBMLDocument_t element. The value is true (1) if the
 * package is required, or false (0) otherwise.
 *
 * @param plugin the SBMLDocumentPlugin_t structure
 * @param required the new value for the "required" attribute.
 *
 * @return the value of "required" attribute of corresponding
 * package in the SBMLDocument_t element. The value is true (1) if the
 * package is required, or false (0) otherwise. If the plugin is invalid
 * LIBSBML_INVALID_OBJECT will be returned.
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_setRequired(SBMLDocumentPlugin_t* plugin, int required);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * SBMLDocumentPlugin_t structure's "required" attribute is set.
 *
 * @param plugin the SBMLDocumentPlugin_t structure to query
 *
 * @return @c non-zero (true) if the "required" attribute of the given
 * SBMLDocumentPlugin_t structure is set, zero (false) otherwise.
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_isSetRequired(SBMLDocumentPlugin_t* plugin);


/**
 * Unsets the "required" attribute of this SBMLDocumentPlugin_t structure.
 *
 * @param plugin the SBMLDocumentPlugin_t structure whose "required" attribute is to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SBMLDocumentPlugin_t
 */
LIBSBML_EXTERN
int
SBMLDocumentPlugin_unsetRequired(SBMLDocumentPlugin_t* plugin);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* SBMLDocumentPlugin_h */
