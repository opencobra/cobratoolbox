/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnRealNode.cpp
 * @brief   Cn Real Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTCnRealNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sstream>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN


ASTCnRealNode::ASTCnRealNode (int type) :
  ASTCnBase(type)
    , mReal (0)
    , mIsSetReal  (false)
{
}
  

ASTCnRealNode::ASTCnRealNode (const XMLNode *xml) :
  ASTCnBase(AST_REAL)
    , mReal  (0)
    , mIsSetReal  (false)
{
  setType(AST_REAL);
}

  
  /**
   * Copy constructor
   */
ASTCnRealNode::ASTCnRealNode (const ASTCnRealNode& orig):
  ASTCnBase(orig)
    , mReal (orig.mReal)
    , mIsSetReal (orig.mIsSetReal)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCnRealNode&
ASTCnRealNode::operator=(const ASTCnRealNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTCnBase::operator =(rhs);
    this->mReal = rhs.mReal;
    this->mIsSetReal = rhs.mIsSetReal;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCnRealNode::~ASTCnRealNode ()
{
}

int
ASTCnRealNode::getTypeCode () const
{
  return AST_TYPECODE_CN_REAL;
}


  /**
   * Creates a copy (clone).
   */
ASTCnRealNode*
ASTCnRealNode::deepCopy () const
{
  return new ASTCnRealNode(*this);
}



  /**
   * Get the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @link ASTNodeType_t#AST_LAMBDA
   * AST_LAMBDA@endlink, @link ASTNodeType_t#AST_PLUS AST_PLUS@endlink,
   * etc.
   * 
   * @return the type of this ASTNode.
   */
//ASTNodeType_t
//ASTCnRealNode::getType () const
//{
//  return mType;
//}


  /**
   * Sets the type of this ASTNode to the given type code.  A side-effect
   * of doing this is that any numerical values previously stored in this
   * node are reset to zero.
   *
   * @param type the type to which this node should be set
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values returned by this function are:
   * @li @link OperationReturnValues_t#LIBSBML_OPERATION_SUCCESS LIBSBML_OPERATION_SUCCESS @endlink
   * @li @link OperationReturnValues_t#LIBSBML_INVALID_ATTRIBUTE_VALUE LIBSBML_INVALID_ATTRIBUTE_VALUE @endlink
   */
//int 
//ASTCnRealNode::setType (ASTNodeType_t type)
//{
//  if (mType == type) 
//  {
//    return LIBSBML_OPERATION_SUCCESS;
//  }
//
//  mType = type;
//  return LIBSBML_OPERATION_SUCCESS;
//}

  
double 
ASTCnRealNode::getReal() const
{
  return mReal;
}

  
double 
ASTCnRealNode::getValue() const 
{
  return mReal;
}

  
bool 
ASTCnRealNode::isSetReal() const
{
  return mIsSetReal;
}

  
int 
ASTCnRealNode::setReal(double value)
{
  mReal = value;
  mIsSetReal = true;
  setType(AST_REAL);
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnRealNode::unsetReal()
{
  mReal = 0;
  mIsSetReal = false;
  return LIBSBML_OPERATION_SUCCESS;
}


void
ASTCnRealNode::write(XMLOutputStream& stream) const
{
  stream.startElement("cn");

  stream.setAutoIndent(false);

  ASTCnBase::write(stream);

  ostringstream output;

  output.precision(LIBSBML_DOUBLE_PRECISION);
  output << getReal();

  string            value_string = output.str();
  string::size_type position     = value_string.find('e');

  if (position == string::npos)
  {
    stream << " " << value_string << " ";
  }
  else
  {
    const string mantissa_string = value_string.substr(0, position);
    const string exponent_string = value_string.substr(position + 1);

    double mantissa = strtod(mantissa_string.c_str(), 0);
    long   exponent = strtol(exponent_string.c_str(), 0, 10);

    this->writeENotation(mantissa, exponent, stream);
  }

  stream.endElement("cn");
  
  stream.setAutoIndent(true);
}

bool
ASTCnRealNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
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

  std::string type = "real";
  element.getAttributes().readInto("type", type);

  if (type == "real")
  {
    double value = 0;
    istringstream isreal;
    isreal.str( stream.next().getCharacters() );
    isreal >> value;

    setReal(value);
    ASTBase::setType(AST_REAL);

    if (isreal.fail() 
      || (util_isInf(getValue()) > 0)
      || (util_isInf(getValue()) < 0)
      )
    {
      logError(stream, element, FailedMathMLReadOfDouble);      
    }

    read = true;
  }
  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


void
ASTCnRealNode::writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const
{
  ASTBase::writeENotation(mantissa, exponent, stream);
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

