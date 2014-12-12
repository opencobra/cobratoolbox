/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnRationalNode.cpp
 * @brief   Cn Rational Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTCnRationalNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sstream>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN


ASTCnRationalNode::ASTCnRationalNode (int type) :
  ASTCnBase(type)
    , mNumerator         ( 0 )
    , mDenominator       ( 1 )
    , mIsSetDenominator  ( false )
    , mIsSetNumerator    ( false )
{
}
  

ASTCnRationalNode::ASTCnRationalNode (const XMLNode *xml) :
  ASTCnBase(AST_RATIONAL)
    , mNumerator         ( 0 )
    , mDenominator       ( 1 )
    , mIsSetDenominator  ( false )
    , mIsSetNumerator    ( false )
{
    setType(AST_RATIONAL);
}

  
  /**
   * Copy constructor
   */
ASTCnRationalNode::ASTCnRationalNode (const ASTCnRationalNode& orig):
  ASTCnBase(orig)
    , mNumerator        (orig.mNumerator)
    , mDenominator      (orig.mDenominator)
    , mIsSetDenominator (orig.mIsSetDenominator)
    , mIsSetNumerator   (orig.mIsSetNumerator)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCnRationalNode&
ASTCnRationalNode::operator=(const ASTCnRationalNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTCnBase::operator =(rhs);
    this->mDenominator = rhs.mDenominator;
    this->mNumerator = rhs.mNumerator;
    this->mIsSetDenominator = rhs.mIsSetDenominator;
    this->mIsSetNumerator = rhs.mIsSetNumerator;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCnRationalNode::~ASTCnRationalNode ()
{
}

int
ASTCnRationalNode::getTypeCode () const
{
  return AST_TYPECODE_CN_RATIONAL;
}


  /**
   * Creates a copy (clone).
   */
ASTCnRationalNode*
ASTCnRationalNode::deepCopy () const
{
  return new ASTCnRationalNode(*this);
}




  
long 
ASTCnRationalNode::getDenominator() const
{
  return mDenominator;
}

  
bool 
ASTCnRationalNode::isSetDenominator() const
{
  return mIsSetDenominator;
}

  
int 
ASTCnRationalNode::setDenominator(long value)
{
  mDenominator = value;
  mIsSetDenominator = true;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnRationalNode::unsetDenominator()
{
  mDenominator = 0;
  mIsSetDenominator = false;
  return LIBSBML_OPERATION_SUCCESS;
}


long 
ASTCnRationalNode::getNumerator() const
{
  return mNumerator;
}

  
bool 
ASTCnRationalNode::isSetNumerator() const
{
  return mIsSetNumerator;
}

  
int 
ASTCnRationalNode::setNumerator(long value)
{
  mNumerator = value;
  mIsSetNumerator = true;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCnRationalNode::unsetNumerator()
{
  mNumerator = 0;
  mIsSetNumerator = false;
  return LIBSBML_OPERATION_SUCCESS;
}

int 
ASTCnRationalNode::setValue(long numerator, long denominator)
{
  setType(AST_RATIONAL);
  int i = setNumerator(numerator);
  if (i == LIBSBML_OPERATION_SUCCESS)
    return setDenominator(denominator);
  else
    return i;
}

double 
ASTCnRationalNode::getValue() const
{
  double result = static_cast<double>(mNumerator) / mDenominator;
  return result;
}

bool 
ASTCnRationalNode::isSetRational() const
{
  return (mIsSetDenominator && mIsSetNumerator);
}

void
ASTCnRationalNode::write(XMLOutputStream& stream) const
{
  stream.startElement("cn");

  stream.setAutoIndent(false);

  ASTCnBase::write(stream);

  static const string type = "rational";
  stream.writeAttribute("type", type);

  stream << " " << getNumerator() << " ";
  stream.startEndElement("sep");
  stream << " " << getDenominator() << " ";
  
  stream.endElement("cn");
  
  stream.setAutoIndent(true);
}

bool
ASTCnRationalNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
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

  if (type == "rational")
  {
    int numerator = 0;
    int denominator = 1;

    istringstream isnumerator;
    istringstream isdenominator;
    isnumerator.str( stream.next().getCharacters() );
    isnumerator >> numerator;

    if (stream.peek().getName() == "sep")
    {
      stream.next();
      isdenominator.str( stream.next().getCharacters() );
      isdenominator >> denominator;
    }

    if (isnumerator.fail() || isdenominator.fail())
    {
      logError(stream, element, FailedMathMLReadOfRational);      
    }
    else if ( sizeof(int) > 4 && 
        ( ( (numerator > SBML_INT_MAX) || (numerator < SBML_INT_MIN) ) 
          ||
          ( (denominator > SBML_INT_MAX) || (denominator < SBML_INT_MIN) ) 
        ))
    {
      logError(stream, element, FailedMathMLReadOfRational);
    }

    setNumerator(static_cast<long>(numerator));
    setDenominator(static_cast<long>(denominator));
    ASTBase::setType(AST_RATIONAL);
    read = true;
  }

  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

