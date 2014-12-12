/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdentifierTransformer.h
 * @brief   Base class of all Identifier Transformers
 * @author  Frank T. Bergmann
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
 * ---------------------------------------------------------------------- -->
 *
 * @class IdentifierTransformer
 * @sbmlbrief{core} Base class for identifier transformers.
 */

#ifndef IdentifierTransformer_h
#define IdentifierTransformer_h


#ifdef __cplusplus

#include <sbml/common/extern.h>
#include <sbml/common/libsbml-namespace.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBase;

class LIBSBML_EXTERN IdentifierTransformer
{
public:
  IdentifierTransformer();
  virtual ~IdentifierTransformer();
  int transform(const SBase* element);
  virtual int transform(SBase* element);
  
  #ifndef SWIG
  void* getUserData();
  void setUserData(void* userData);
  #endif

  
private:
  void* mUserData;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* IdentifierTransformer_h */

/** @endcond */
