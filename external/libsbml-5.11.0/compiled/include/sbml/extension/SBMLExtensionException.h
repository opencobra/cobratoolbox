/**
 * @file    SBMLExtensionException.h
 * @brief   Class of exceptions thrown in some situations.
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
 * @class SBMLExtensionException
 * @sbmlbrief{core} Exception used by package extensions
 *
 * @htmlinclude not-sbml-warning.html
 *
 * @copydetails doc_extension_sbmlextensionexception
 *
 * @see SBMLNamespaces
 */

#ifndef SBMLExtensionException_h
#define SBMLExtensionException_h

#include <sbml/common/common.h>

#ifdef __cplusplus

#include <string>
#include <stdexcept>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBMLExtensionException : public std::invalid_argument
{
public:

  /**
   * Creates a new SBMLExtensionException object with a given message.
   *
   * @param errmsg a string, the text of the error message to store
   * with this exception
   */
  SBMLExtensionException (const std::string& errmsg) throw();


#ifndef SWIG
  /**
   * Destroys this object.
   */
  virtual ~SBMLExtensionException () throw();
#endif
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBMLExtensionException_h */

