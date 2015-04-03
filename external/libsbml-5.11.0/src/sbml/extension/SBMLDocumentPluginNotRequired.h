/**
 * @file    SBMLDocumentPluginNotRequired.h
 * @brief   Definition of SBMLDocumentPluginNotRequired, the plugin class of
 *          layout package for the SBMLDocument element, whose 'required' attribute
 *          must be 'false'.
 * @author  Lucian Smith
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
 * @class SBMLDocumentPluginNotRequired
 * @sbmlbrief{core} Base class for non-required Level 3 packages plug-ins.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBMLDocumentPluginNotRequired class extends the SBMLDocumentPlugin
 * class, adding a validation test such that it reports an error if an SBML
 * document read in has a "required" flag set to @c true.  The purpose of
 * this is to make it simpler to implement packages that are supposed to have
 * "required" flag values of @c false (such as %Layout and other SBML
 * packages that cannot affect the mathematical interpretation of a model).
 *
 * @note This class is not used currently in any package extension.  This
 * class was introduced at a time when libSBML did not provide the necessary
 * hooks into the validation system for packages to add their own validation
 * rules, but this has since changed.  New developments should use the
 * regular SBMLDocumentPlugin class instead of this one.
 */

#ifndef SBMLDocumentPluginNotRequired_h
#define SBMLDocumentPluginNotRequired_h

#ifdef __cplusplus

#include <sbml/extension/SBMLDocumentPlugin.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBMLDocumentPluginNotRequired : public SBMLDocumentPlugin
{
public:

  /**
   * Creates a new SBMLDocumentPluginNotRequired object using the given parameters.
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
  SBMLDocumentPluginNotRequired (const std::string &uri, const std::string &prefix,
                                 SBMLNamespaces *sbmlns);


  /**
   * Copy constructor.
   *
   * This creates a copy of this object.
   *
   * @param orig the SBMLDocumentPluginNotRequired instance to copy.
   */
  SBMLDocumentPluginNotRequired(const SBMLDocumentPluginNotRequired& orig);


  /**
   * Assignment operator for SBMLDocumentPluginNotRequired.
   *
   * @param orig The object whose values are used as the basis of the
   * assignment.
   */
  SBMLDocumentPluginNotRequired& operator=(const SBMLDocumentPluginNotRequired& orig);


  /**
   * Destroy this object.
   */
  virtual ~SBMLDocumentPluginNotRequired ();


#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */

  /**
   * Reads the attributes of corresponding package in SBMLDocument element.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);


  /** @endcond */

#endif //SWIG

#if (0)
  /**
   *
   * Sets the bool value of "required" attribute of corresponding package
   * in SBMLDocument element.  This package is required to set this value
   * to 'false'; attempting to set it to 'true' will result in an error.
   *
   * @param value the bool value of "required" attribute of corresponding
   * package in SBMLDocument element.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  virtual int setRequired(bool value);

  /**
   * Doesn't do anything:  it is illegal to unset the 'required' attribute in this package,
   * as it must always be set to 'false'.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetRequired();
#endif //0

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBMLDocumentPluginNotRequired_h */
