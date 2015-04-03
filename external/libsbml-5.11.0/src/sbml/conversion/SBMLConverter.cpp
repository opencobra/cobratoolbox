/**
 * @file    SBMLConverter.cpp
 * @brief   Implementation of SBMLConverter, the base class of package extensions.
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */
 
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/SBMLConstructorException.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

SBMLConverter::SBMLConverter () :
    mDocument (NULL)
  , mProps(NULL)
  , mName("")
{
}

SBMLConverter::SBMLConverter (const std::string& name)
  : mDocument (NULL)
  , mProps(NULL)
  , mName(name)
{
}

/*
 * Copy constructor.
 */
SBMLConverter::SBMLConverter(const SBMLConverter& orig) :
    mDocument (NULL)
  , mProps(NULL)
  , mName("")
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mDocument = orig.mDocument;
    mName = orig.mName;
    
    if (orig.mProps != NULL) 
    {
      mProps = new ConversionProperties(*orig.mProps);
    }
  }
}


/*
 * Destroy this object.
 */
SBMLConverter::~SBMLConverter ()
{
  if (mProps != NULL)
  {
    delete mProps;
    mProps = NULL;
  }
}


/*
 * Assignment operator for SBMLConverter.
 */
SBMLConverter& 
SBMLConverter::operator=(const SBMLConverter& rhs)
{  
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    mDocument = rhs.mDocument;
    mName = rhs.mName;
    
    if (mProps != NULL)
    {
      delete mProps;
      mProps = NULL;
    }
    
    if (rhs.mProps != NULL)
    {
      mProps = new ConversionProperties(*rhs.mProps);
    }
    else
    {
      mProps = NULL;
    }
  }

  return *this;
}


SBMLConverter*
SBMLConverter::clone () const
{
  return new SBMLConverter(*this);
}


SBMLDocument* 
SBMLConverter::getDocument()
{
  return mDocument;
}


const SBMLDocument* 
SBMLConverter::getDocument() const
{
  return mDocument;
}

int 
SBMLConverter::setDocument(const SBMLDocument* doc)
{
  if (mDocument == doc)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  mDocument = const_cast<SBMLDocument *> (doc);
  return LIBSBML_OPERATION_SUCCESS;
}



int 
SBMLConverter::setDocument(SBMLDocument* doc)
{
  if (mDocument == doc)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  mDocument = doc;
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string&
SBMLConverter::getName() const
{
  return mName;
}

int
SBMLConverter::convert()
{
  return LIBSBML_OPERATION_FAILED;
}
  
bool 
SBMLConverter::matchesProperties(const ConversionProperties &) const
{
  return false;
}

SBMLNamespaces* 
SBMLConverter::getTargetNamespaces() 
{
  if (mProps == NULL) return NULL;
  return mProps->getTargetNamespaces();
}

int 
SBMLConverter::setProperties(const ConversionProperties *props)
{
  if (props == NULL) return LIBSBML_OPERATION_FAILED; 
  if (mProps != NULL)
  {
    delete mProps;
    mProps = NULL;
  }
  mProps = props->clone();
  return LIBSBML_OPERATION_SUCCESS;
}
  
ConversionProperties* 
SBMLConverter::getProperties() const
{
  return mProps;
}

ConversionProperties 
SBMLConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  return prop;
}

  
/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


