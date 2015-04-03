/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnExponentialNode.cpp
 * @brief   Cn Exponential Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTCnExponentialNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sstream>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN


ASTCnExponentialNode::ASTCnExponentialNode (int type) :
  ASTCnBase(type)
    , mExponent         ( 0 )
    , mMantissa       ( 0 )
    , mIsSetMantissa  ( false )
    , mIsSetExponent    ( false )
{
}
  


  /**
   * Copy constructor
   */
ASTCnExponentialNode::ASTCnExponentialNode (const ASTCnExponentialNode& orig):
  ASTCnBase(orig)
    , mExponent        (orig.mExponent)
    , mMantissa      (orig.mMantissa)
    , mIsSetMantissa (orig.mIsSetMantissa)
    , mIsSetExponent   (orig.mIsSetExponent)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCnExponentialNode&
ASTCnExponentialNode::operator=(const ASTCnExponentialNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTCnBase::operator =(rhs);
    this->mMantissa = rhs.mMantissa;
    this->mExponent = rhs.mExponent;
    this->mIsSetMantissa = rhs.mIsSetMantissa;
    this->mIsSetExponent = rhs.mIsSetExponent;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCnExponentialNode::~ASTCnExponentialNode ()
{
}


int
ASTCnExponentialNode::getTypeCode () const
{
  return AST_TYPECODE_CN_EXPONENTIAL;
}


 /**
   * Creates a copy (clone).
   */
ASTCnExponentialNode*
ASTCnExponentialNode::deepCopy () const
{
  return new ASTCnExponentialNode(*this);
}


  
double 
ASTCnExponentialNode::getMantissa() const
{
  return mMantissa;
}

  
bool 
ASTCnExponentialNode::isSetMantissa() const
{
  return mIsSetMantissa;
}

  
int 
ASTCnExponentialNode::setMantissa(double value)
{
  mMantissa = value;
  mIsSetMantissa = true;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnExponentialNode::unsetMantissa()
{
  mMantissa = 0;
  mIsSetMantissa = false;
  return LIBSBML_OPERATION_SUCCESS;
}


long 
ASTCnExponentialNode::getExponent() const
{
  return mExponent;
}

  
bool 
ASTCnExponentialNode::isSetExponent() const
{
  return mIsSetExponent;
}

  
int 
ASTCnExponentialNode::setExponent(long value)
{
  mExponent = value;
  mIsSetExponent = true;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnExponentialNode::unsetExponent()
{
  mExponent = 0;
  mIsSetExponent = false;
  return LIBSBML_OPERATION_SUCCESS;
}

int 
ASTCnExponentialNode::setValue(double value, long value1)
{
  setType(AST_REAL_E);
  int i = setExponent(value1);
  if (i == LIBSBML_OPERATION_SUCCESS)
    return setMantissa(value);
  else
    return i;
}

double 
ASTCnExponentialNode::getValue() const
{
  double result = mMantissa * pow(10.0,  static_cast<double>(mExponent) );

  return result;
}

bool 
ASTCnExponentialNode::isSetExponential() const
{
  return (mIsSetMantissa && mIsSetExponent);
}

void
ASTCnExponentialNode::write(XMLOutputStream& stream) const
{
  stream.startElement("cn");

  stream.setAutoIndent(false);

  ASTCnBase::write(stream);

  writeENotation (  getMantissa(), getExponent(), stream);
  
  stream.endElement("cn");
  
  stream.setAutoIndent(true);
}

bool
ASTCnExponentialNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek ();
  const string&  name = element.getName();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  if (name != "cn")
  {
#if 0
    cout << "HELP\n";
#endif
    return read;
  }

  ASTCnBase::read(stream, reqd_prefix);

  std::string type;
  element.getAttributes().readInto("type", type);

  if (type == "e-notation")
  {
    double mantissa = 0;
    long   exponent = 0;
    istringstream ismantissa;
    istringstream isexponent;
    ismantissa.str( stream.next().getCharacters() );
    ismantissa >> mantissa;

    if (stream.peek().getName() == "sep")
    {
      stream.next();
      isexponent.str( stream.next().getCharacters() );
      isexponent >> exponent;
    }

    setMantissa(mantissa);
    setExponent(exponent);
    ASTBase::setType(AST_REAL_E);

    if (ismantissa.fail() 
      || isexponent.fail()
      || (util_isInf(getValue()) > 0)
      || (util_isInf(getValue()) < 0)
      )
    {
      logError(stream, element, FailedMathMLReadOfExponential);     
    }
    
    read = true;
  }

  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


void
ASTCnExponentialNode::writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const
{
  ASTBase::writeENotation(mantissa, exponent, stream);
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

