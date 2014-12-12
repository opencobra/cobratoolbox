/**
 * @file    SBMLConstructorException.h
 * @brief   Definition of SBMLConstructorException, the exception class for constructor exceptions
 * @author  Ben Bornstein
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
 * @class SBMLConstructorException
 * @sbmlbrief{core} Exceptions thrown by some libSBML constructors.
 *
 * In some situations, constructors for SBML objects may need to indicate to
 * callers that the creation of the object failed.  The failure may be for
 * different reasons, such as an attempt to use invalid parameters or a
 * system condition such as a memory error.  To communicate this to callers,
 * those classes will throw an SBMLConstructorException.
 *
 * In languages that don't have an exception mechanism (e.g., C), the
 * constructors generally try to return an error code instead of throwing
 * an exception.
 */

#ifndef SBML_CONSTRUCTOR_EXCEPTION_H
#define SBML_CONSTRUCTOR_EXCEPTION_H

#include <sbml/common/extern.h>
#include <sbml/SBMLNamespaces.h>

#ifdef __cplusplus

#include <string>
#include <stdexcept>
#include <algorithm>

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLConstructorException : public std::invalid_argument
{
public:

  /** @cond doxygenLibsbmlInternal */

  /* constructor */
  SBMLConstructorException (std::string errmsg = "");
  SBMLConstructorException (std::string errmsg, std::string sbmlErrMsg);
  SBMLConstructorException (std::string elementName, SBMLNamespaces* xmlns);
  virtual ~SBMLConstructorException () throw();
  
 /** @endcond */

  /**
   * Returns the message associated with this SBML exception.
   *
   * @return the message string.
   */
  const std::string getSBMLErrMsg() const { return mSBMLErrMsg; }

private:
  std::string mSBMLErrMsg;
};


LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif /* SBML_CONSTRUCTOR_EXCEPTION_H */

