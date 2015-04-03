/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    PrefixTransformer.h
 * @brief   A special IdentifierTransformer allowing to customize how to apply  prefixes
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
 * ---------------------------------------------------------------------- -->*/

#ifndef PrefixTransformer_h
#define PrefixTransformer_h

#ifdef __cplusplus

#include <string>

#include <sbml/common/extern.h>
#include <sbml/common/libsbml-namespace.h>
#include <sbml/util/IdentifierTransformer.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBase;

/** 
 * Simple IdentifierTransformer, that prefixes all given 
 * elements with the prefix given to the constructor. 
 * 
 * this will prefix metaids, unitsids and sids. 
 */ 
class LIBSBML_EXTERN PrefixTransformer : public IdentifierTransformer
{
protected:
  std::string mPrefix;

public: 
  /**
   * Default contructor
   */
  PrefixTransformer();

  /**
   * Constructor initializing the transformer with a given prefix
   */
  PrefixTransformer (const std::string& prefix);

  /**
   * Destructor
   */
  virtual ~PrefixTransformer();

  /**
   * @return the currently set prefix
   */
  const std::string& getPrefix() const;

  /** 
   * Sets the prefix to be applied by this transformer
   */
  void setPrefix(const std::string& prefix);

  /** 
   * transform the given SBase element
   */ 
  virtual int transform(SBase* element);  

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#endif //PrefixTransformer_h

/** @endcond */
