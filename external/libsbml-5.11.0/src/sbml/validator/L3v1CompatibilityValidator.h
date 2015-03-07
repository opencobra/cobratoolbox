/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    L3v1CompatibilityValidator.h
 * @brief   Checks whether an SBML model can be converted from L2v2/3 to L3v1
 * @author  Sarah Keating
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#ifndef L3v1CompatibilityValidator_h
#define L3v1CompatibilityValidator_h


#ifdef __cplusplus


#include <sbml/validator/Validator.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class L3v1CompatibilityValidator: public Validator
{
public:

  L3v1CompatibilityValidator () :
    Validator( LIBSBML_CAT_SBML_L2V1_COMPAT ) { }

  virtual ~L3v1CompatibilityValidator () { }

  /**
   * Initializes this Validator with a set of Constraints.
   */
  virtual void init ();
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* L3v1CompatibilityValidator_h */


/** @endcond */

