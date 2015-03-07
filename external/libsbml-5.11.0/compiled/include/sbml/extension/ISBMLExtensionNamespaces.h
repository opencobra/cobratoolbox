/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ISBMLExtensionNamespaces.h
 * @brief   ISBMLExtensionNamespaces interface to the SBMLExtensionNamespaces class
 * @author  Frank Bergmann
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
 * @class ISBMLExtensionNamespaces
 * @sbmlbrief{core}
 *
 * @htmlinclude not-sbml-warning.html
 */

#ifndef ISBMLExtensionNamespaces_h
#define ISBMLExtensionNamespaces_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/common/common.h>

#ifdef __cplusplus

#include <string>
#include <stdexcept>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ISBMLExtensionNamespaces : public SBMLNamespaces
{
public:
   
  ISBMLExtensionNamespaces();
  
  ISBMLExtensionNamespaces(unsigned int level, 
                           unsigned int version, 
                           const std::string &pkgName,
                           unsigned int pkgVersion, 
                           const std::string& pkgPrefix = "");

  ISBMLExtensionNamespaces(const ISBMLExtensionNamespaces& orig);   
   
  virtual ~ISBMLExtensionNamespaces();
   
  virtual std::string getURI() const = 0;
  virtual unsigned int getPackageVersion() const = 0;
  virtual const std::string& getPackageName() const = 0;
  virtual void setPackageVersion(unsigned int pkgVersion)  = 0;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#endif  /* ISBMLExtensionNamespaces_h */

/** @endcond */
