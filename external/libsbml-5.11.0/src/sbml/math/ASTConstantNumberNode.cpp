/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTConstantNumberNode.cpp
 * @brief   Constant Number Abstract Syntax Tree (AST) class.
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
 * in the file Valued "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/math/ASTConstantNumberNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN



ASTConstantNumberNode::ASTConstantNumberNode (int type) :
  ASTCnBase(type)
    , mValue       ( 0 )
    , mIsSetValue (false)
{
}
  


  /**
   * Copy constructor
   */
ASTConstantNumberNode::ASTConstantNumberNode (const ASTConstantNumberNode& orig):
  ASTCnBase(orig)
    , mValue      (orig.mValue)
    , mIsSetValue (orig.mIsSetValue)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTConstantNumberNode&
ASTConstantNumberNode::operator=(const ASTConstantNumberNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    this->mValue = rhs.mValue;
    this->mIsSetValue = rhs.mIsSetValue;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTConstantNumberNode::~ASTConstantNumberNode ()
{
}

int
ASTConstantNumberNode::getTypeCode () const
{
  return AST_TYPECODE_CONSTANT_NUMBER;
}


  /**
   * Creates a copy (clone).
   */
ASTConstantNumberNode*
ASTConstantNumberNode::deepCopy () const
{
  return new ASTConstantNumberNode(*this);
}


  
double 
ASTConstantNumberNode::getValue() const
{
  return mValue;
}

  
int 
ASTConstantNumberNode::setValue(double value)
{
  mValue = value;
  mIsSetValue = true;
  return LIBSBML_OPERATION_SUCCESS;
}

  
bool 
ASTConstantNumberNode::isSetValue() const
{
  return mIsSetValue;
}

  
int 
ASTConstantNumberNode::unsetValue() 
{
  mValue = util_NaN();
  mIsSetValue = false;
  return LIBSBML_OPERATION_SUCCESS;
}


bool
ASTConstantNumberNode::isNaN() const
{
  if ( getType() == AST_REAL )
  {
    double value = getValue();
    return (value != value);
  }

  return false;
}

  
bool
ASTConstantNumberNode::isInfinity() const
{
  if ( getType() == AST_REAL )
  {
    return (util_isInf(getValue()) > 0);
  }

  return false;
}

  
bool
ASTConstantNumberNode::isNegInfinity() const
{
  if ( getType() == AST_REAL )
  {
    return (util_isInf(getValue()) < 0);
  }

  return false;
}

  
void
ASTConstantNumberNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  std::string name;

  ASTNodeType_t type  = getType();
  bool constantNumber = false;

  switch ( type )
  {
    case AST_REAL:
      if (isNaN() == true)
      {
        name = "notanumber";
        constantNumber = true;
      }
      else if (isInfinity() == true)
      {
        name = "infinity";
        constantNumber = true;
      }
      else if (isNegInfinity() == true)
      {
        constantNumber = true;
      }
      break;
    default:  
      break;
  }

  if (constantNumber == false)
  {
    ASTBase::writeStartEndElement(stream);
  }
  else
  {
    if (isNegInfinity() == true)
    {
      ASTBase::writeNegInfinity(stream);
    }
    else
    {
      ASTBase::writeConstant(stream, name);
    }
  }
}

bool
ASTConstantNumberNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek ();

  std::string      name = element.getName();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  ASTBase::read(stream, reqd_prefix);

  int type = ASTBase::getTypeFromName(name);
  setType(type);
  
  if (name == "notanumber")
  {
    setValue(numeric_limits<double>::quiet_NaN());
  }
  else if (name == "infinity")
  {
    setValue(numeric_limits<double>::infinity());
  }
    
  read = true;

  return read;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

