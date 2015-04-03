/**
 * @file    SBMLExtensionRegister.h
 * @brief   Template class for registering extension packages
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
 * @class SBMLExtensionRegister
 * @sbmlbrief{core} Template class for extension package registration
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This is the registration template class for SBML package extensions in
 * libSBML.  It is used by package extensions to register themselves with the
 * SBMLExtensionRegistry when libSBML starts up.  An instance of this class
 * needs to be created by each package extension and used in a call to a
 * method on SBMLExtensionRegistry.
 *
 * @section sbmlextensionregister-howto How to use SBMLExtensionRegister in a package extension
 * @copydetails doc_extension_sbmlextensionregister
 */

#ifndef SBMLExtensionRegister_h
#define SBMLExtensionRegister_h

#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN


template<class SBMLExtensionType>
class LIBSBML_EXTERN SBMLExtensionRegister
{
public:

  /**
   * Constructor for SBMLExtensionRegister.
   *
   * This simple constructor arranges for the initialization code of the
   * corresponding package extension to be executed when an object of
   * this class is created.  Specifically, it causes the
   * <code>init()</code> method on the SBMLExtension-derived class to be
   * called when the package is registered with SBMLExtensionRegistry.
   * Extension packages should put any necessary initialization code in
   * their <code>init()</code> method.
   */
  SBMLExtensionRegister() { SBMLExtensionType::init(); };

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBMLExtensionRegister_h */
