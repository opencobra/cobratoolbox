/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnIntegerNode.cpp
 * @brief   Cn Integer Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTBase.h>
#include <sbml/math/ASTCnIntegerNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sstream>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN


ASTCnIntegerNode::ASTCnIntegerNode (int type) :
  ASTCnBase(type)
    , mInteger (0)
    , mIsSetInteger  (false)
{
}
  

ASTCnIntegerNode::ASTCnIntegerNode (const XMLNode *xml) :
  ASTCnBase(AST_INTEGER)
    , mInteger  (0)
    , mIsSetInteger  (false)
{
  setType(AST_INTEGER);
}

  
  /**
   * Copy constructor
   */
ASTCnIntegerNode::ASTCnIntegerNode (const ASTCnIntegerNode& orig):
  ASTCnBase(orig)
    , mInteger (orig.mInteger)
    , mIsSetInteger (orig.mIsSetInteger)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCnIntegerNode&
ASTCnIntegerNode::operator=(const ASTCnIntegerNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTCnBase::operator =(rhs);
    this->mInteger = rhs.mInteger;
    this->mIsSetInteger = rhs.mIsSetInteger;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCnIntegerNode::~ASTCnIntegerNode ()
{
}

int
ASTCnIntegerNode::getTypeCode () const
{
  return AST_TYPECODE_CN_INTEGER;
}


  /**
   * Creates a copy (clone).
   */
ASTCnIntegerNode*
ASTCnIntegerNode::deepCopy () const
{
  return new ASTCnIntegerNode(*this);
}



  /**
   * Get the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @link int#AST_LAMBDA
   * AST_LAMBDA@endlink, @link int#AST_PLUS AST_PLUS@endlink,
   * etc.
   * 
   * @return the type of this ASTNode.
   */
//int
//ASTCnIntegerNode::getType () const
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
//ASTCnIntegerNode::setType (int type)
//{
//  if (mType == type) 
//  {
//    return LIBSBML_OPERATION_SUCCESS;
//  }
//
//  mType = type;
//  return LIBSBML_OPERATION_SUCCESS;
//}

  
long 
ASTCnIntegerNode::getInteger() const
{
  return mInteger;
}

  
bool 
ASTCnIntegerNode::isSetInteger() const
{
  return mIsSetInteger;
}

  
int 
ASTCnIntegerNode::setInteger(long value)
{
  mInteger = value;
  mIsSetInteger = true;
  setType(AST_INTEGER);
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnIntegerNode::unsetInteger()
{
  mInteger = 0;
  mIsSetInteger = false;
  return LIBSBML_OPERATION_SUCCESS;
}


void
ASTCnIntegerNode::write(XMLOutputStream& stream) const
{
  stream.startElement("cn");

  stream.setAutoIndent(false);

  ASTCnBase::write(stream);

  static const string type = "integer";
  stream.writeAttribute("type", type);

  stream << " " << getInteger() << " ";
  
  stream.endElement("cn");
  
  stream.setAutoIndent(true);
}

bool
ASTCnIntegerNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
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

  if (type == "integer")
  {
    int value = 0;
    istringstream isint;
    isint.str( stream.next().getCharacters() );
    isint >> value;

    if (isint.fail())
    {
      logError(stream, element, FailedMathMLReadOfInteger);      
    }
    else if ( sizeof(int) > 4 && ( (value > SBML_INT_MAX) || (value < SBML_INT_MIN) ) )
    {
      logError(stream, element, FailedMathMLReadOfInteger);      
    }

    setInteger(value);
    ASTBase::setType(AST_INTEGER);
    read = true;
  }
  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


double 
ASTCnIntegerNode::getValue() const 
{
  return 0;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

