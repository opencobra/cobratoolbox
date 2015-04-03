/**
 * @file    SBMLConstructorException.cpp
 * @brief   Implementation of SBMLConstructorException, the exception class for constructor exceptions
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
 */

#include <sbml/SBMLConstructorException.h>

#include <sbml/SBMLNamespaces.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLOutputStream.h>

#include <string>
#include <sstream>

LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */

SBMLConstructorException::SBMLConstructorException(std::string errmsg) :
      std::invalid_argument("Level/version/namespaces combination is invalid")
    , mSBMLErrMsg(errmsg)
{
}

SBMLConstructorException::SBMLConstructorException (std::string errmsg, std::string sbmlErrMsg) :
    std::invalid_argument(errmsg)
  , mSBMLErrMsg(sbmlErrMsg)
{
}

SBMLConstructorException::SBMLConstructorException (std::string elementName, SBMLNamespaces* sbmlns) :
    std::invalid_argument("Level/version/namespaces combination is invalid")
  , mSBMLErrMsg(elementName)
{
  if (sbmlns == NULL) return;
  
  XMLNamespaces* xmlns = sbmlns->getNamespaces();
  
  if (xmlns == NULL) return;
    
  std::ostringstream oss;
  XMLOutputStream xos(oss);
  xos << *xmlns;
  mSBMLErrMsg.append(oss.str());
  
}

SBMLConstructorException::~SBMLConstructorException() throw()
{
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

