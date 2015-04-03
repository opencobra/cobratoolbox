/**
 * @file    ExpectedAttributes.h
 * @brief   Definition of ExpectedAttributes, the class allowing the specification
 *          of attributes to expect.
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

#ifndef EXPECTED_ATTRIBUTES_H
#define EXPECTED_ATTRIBUTES_H

#include <sbml/common/extern.h>


#ifdef __cplusplus

#include <string>
#include <vector>
#include <stdexcept>
#include <algorithm>

LIBSBML_CPP_NAMESPACE_BEGIN
/** @cond doxygenLibsbmlInternal */
  #ifndef SWIG
class LIBSBML_EXTERN ExpectedAttributes
{
public:

  ExpectedAttributes() 
  {}

  ExpectedAttributes(const ExpectedAttributes& orig) 
    : mAttributes(orig.mAttributes) 
  {}
    
  void add(const std::string& attribute) { mAttributes.push_back(attribute); }

  std::string get(unsigned int i) const
  {
    return (mAttributes.size() < i) ? mAttributes[i] : std::string(); 
  }

  bool hasAttribute(const std::string& attribute) const
  {
    return ( std::find(mAttributes.begin(), mAttributes.end(), attribute)
             != mAttributes.end() );
  }

private:
  std::vector<std::string> mAttributes;
};


#endif //SWIG
/** @endcond */


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN 
ExpectedAttributes_t *
ExpectedAttributes_create();

/* Clone the provided ExpectedAttributes_t structure */
LIBSBML_EXTERN 
ExpectedAttributes_t *
ExpectedAttributes_clone(ExpectedAttributes_t *attr);

/* Add the provided attribute to the ExpectedAttributes_t structure */
LIBSBML_EXTERN 
int
ExpectedAttributes_add(ExpectedAttributes_t *attr, const char* attribute);

/* Get the attribute at the provided index of the provided ExpectedAttributes_t structure */
LIBSBML_EXTERN 
char*
ExpectedAttributes_get(ExpectedAttributes_t *attr, unsigned int index);

/* Check the provided ExpectedAttributes_t structure to see if it contains the provided attribute*/
LIBSBML_EXTERN 
int
ExpectedAttributes_hasAttribute(ExpectedAttributes_t *attr, const char* attribute);
/** @endcond */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG   */
#endif  /* EXPECTED_ATTRIBUTES_H */
