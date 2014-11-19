/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnBase.cpp
 * @brief   Base Abstract Syntax Tree (AST) Units.
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
 * Copyright (C) 2009-2012 jointly by the following organizations: 
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
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/math/ASTCnBase.h>
#include <sbml/SyntaxChecker.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTCnBase::ASTCnBase (int type) :
   ASTBase     ( type )
   , mUnits ("")
   , mUnitsPrefix ("")
{
}
  

/**
 * Copy constructor
 */
ASTCnBase::ASTCnBase (const ASTCnBase& orig):
   ASTBase          ( orig)  
  , mUnits               (orig.mUnits)
  , mUnitsPrefix (orig.mUnitsPrefix)
{
}


/**
 * Assignment operator for ASTNode.
 */
ASTCnBase&
ASTCnBase::operator=(const ASTCnBase& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    mUnits                = rhs.mUnits;
    mUnitsPrefix = rhs.mUnitsPrefix;
  }
  return *this;
}


/**
 * Destroys this ASTNode, including any child nodes.
 */
ASTCnBase::~ASTCnBase ()
{
}

  
int
ASTCnBase::getTypeCode () const
{
  return AST_TYPECODE_CN_BASE;
}


// functions for units attributes

std::string 
ASTCnBase::getUnits() const
{
  return mUnits;
}


bool 
ASTCnBase::isSetUnits() const
{
  return (mUnits.empty() == false);
}


int 
ASTCnBase::setUnits(const std::string& units)
{
  if (&(units) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (!(SyntaxChecker::isValidInternalUnitSId(units)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mUnits = units;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


int 
ASTCnBase::unsetUnits()
{
  mUnits = "";
  if (mUnits.empty() == true)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


const std::string& 
ASTCnBase::getUnitsPrefix() const
{
  return mUnitsPrefix;
}


bool 
ASTCnBase::isSetUnitsPrefix() const
{
  return (mUnitsPrefix.empty() == false);
}


int 
ASTCnBase::setUnitsPrefix(std::string prefix)
{
  mUnitsPrefix = prefix;
  return LIBSBML_OPERATION_SUCCESS;
}


int 
ASTCnBase::unsetUnitsPrefix()
{
  mUnitsPrefix = "";
  if (mUnitsPrefix.empty() == true)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


bool
ASTCnBase::hasCnUnits() const
{
  return (mUnits.empty() == false);
}


void 
ASTCnBase::write(XMLOutputStream& stream) const
{
  if (isSetUnits() == true && stream.getSBMLNamespaces() != NULL 
    && stream.getSBMLNamespaces()->getLevel() > 2)
  {
    if (isSetUnitsPrefix() == true)
    {
      stream.writeAttribute("units", getUnitsPrefix(), getUnits());
    }
    else
    {
      stream.writeAttribute("units", "sbml", getUnits());
    }
  }

  ASTBase::writeAttributes(stream);
}

void
ASTCnBase::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  if (stream.getSBMLNamespaces() != NULL
    && stream.getSBMLNamespaces()->getLevel() > 2)
  {
    attributes.add("units");
  }

  attributes.add("type");
}

bool 
ASTCnBase::readAttributes(const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element)
{
  bool read = ASTBase::readAttributes(attributes, expectedAttributes,
                                      stream, element);

  if (read == false)
  {
    return read;
  }

  string units;
  attributes.readInto( "units"        , units );

  // cannot put up the prefix here as we need the stream
  // to establish the sbml ns uri
  if (!units.empty())
  {
    setUnits(units);
  }

  return true;
}


bool 
ASTCnBase::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;

  const XMLToken element = stream.next ();
  
  ExpectedAttributes expectedAttributes;
  addExpectedAttributes(expectedAttributes, stream);
  read = readAttributes(element.getAttributes(), expectedAttributes,
                        stream, element);

  string prefix;
  if (isSetUnits() == true)
  {
    prefix = element.getAttrPrefix(
      element.getAttrIndex("units", stream.getSBMLNamespaces()->getURI()));
	  
    setUnitsPrefix(prefix);
  }

  //return ASTBase::read(stream, reqd_prefix);

  return read;
}



void
ASTCnBase::syncMembersFrom(ASTCnBase* rhs)
{
  ASTBase::syncMembersFrom(rhs);
  mUnits  = rhs->mUnits;
  mUnitsPrefix = rhs->mUnitsPrefix;
}


void
ASTCnBase::syncMembersAndResetParentsFrom(ASTCnBase* rhs)
{
  ASTBase::syncMembersAndResetParentsFrom(rhs);
  mUnits  = rhs->mUnits;
  mUnitsPrefix = rhs->mUnitsPrefix;
}

LIBSBML_CPP_NAMESPACE_END


/** @endcond */

