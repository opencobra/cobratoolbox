/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTNumber.cpp
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

#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/extension/ASTBasePlugin.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

#if defined(_MSC_VER) || defined(__BORLANDC__)
#  define isnan(d)  _isnan(d)
#endif

LIBSBML_CPP_NAMESPACE_BEGIN



ASTNumber::ASTNumber (int type) :
   ASTBase   (type)
  , mExponential    ( NULL )
  , mInteger        ( NULL )
  , mRational       ( NULL )
  , mReal           ( NULL )
  , mCiNumber       ( NULL )
  , mConstant       ( NULL )
  , mCSymbol        ( NULL )
  , mIsOther        ( false )
{
  switch (type)
  {
    case AST_REAL_E:
      mExponential = new ASTCnExponentialNode(type);
      this->ASTBase::syncPluginsFrom(mExponential);
      break;
    case AST_INTEGER:
      mInteger = new ASTCnIntegerNode(type);
      this->ASTBase::syncPluginsFrom(mInteger);
      break;
    case AST_RATIONAL:
      mRational = new ASTCnRationalNode(type);
      this->ASTBase::syncPluginsFrom(mRational);
      break;
    case AST_REAL:
      mReal = new ASTCnRealNode(type);
      this->ASTBase::syncPluginsFrom(mReal);
      break;
    case AST_NAME:
      mCiNumber = new ASTCiNumberNode(type);
      this->ASTBase::syncPluginsFrom(mCiNumber);
      break;
    case AST_CONSTANT_E:
    case AST_CONSTANT_FALSE:
    case AST_CONSTANT_PI:
    case AST_CONSTANT_TRUE:
      mConstant = new ASTConstantNumberNode(type);
      this->ASTBase::syncPluginsFrom(mConstant);
      break;
    case AST_NAME_TIME:
    case AST_NAME_AVOGADRO:
      mCSymbol = new ASTCSymbol(type);
      this->ASTBase::syncPluginsFrom(mCSymbol);
      break;

    default:
      break;
  }
}
  

 
  /**
   * Copy constructor
   */
ASTNumber::ASTNumber (const ASTNumber& orig):
    ASTBase (orig)
      , mExponential    ( NULL )
      , mInteger        ( NULL )
      , mRational       ( NULL )
      , mReal           ( NULL )
      , mCiNumber       ( NULL )
      , mConstant       ( NULL )
      , mCSymbol        ( NULL )
      , mIsOther        ( orig.mIsOther )
{
  if ( orig.mExponential  != NULL)
  {
    mExponential = static_cast<ASTCnExponentialNode*>
                                ( orig.mExponential->deepCopy() );
  }
  if ( orig.mInteger  != NULL)
  {
    mInteger = static_cast<ASTCnIntegerNode*>
                                ( orig.mInteger->deepCopy() );
  }
  if ( orig.mRational  != NULL)
  {
    mRational = static_cast<ASTCnRationalNode*>
                                ( orig.mRational->deepCopy() );
  }
  if ( orig.mReal  != NULL)
  {
    mReal = static_cast<ASTCnRealNode*>
                                ( orig.mReal->deepCopy() );
  }
  if ( orig.mCiNumber  != NULL)
  {
    mCiNumber = static_cast<ASTCiNumberNode*>
                                ( orig.mCiNumber->deepCopy() );
  }
  if ( orig.mConstant  != NULL)
  {
    mConstant = static_cast<ASTConstantNumberNode*>
                                ( orig.mConstant->deepCopy() );
  }
  if ( orig.mCSymbol  != NULL)
  {
    mCSymbol = static_cast<ASTCSymbol*>
                                ( orig.mCSymbol->deepCopy() );
  }
}
  /**
   * Assignment operator for ASTNode.
   */
ASTNumber&
ASTNumber::operator=(const ASTNumber& rhs)
{
  if(&rhs!=this)
  {
    this->operator =(rhs);
    mIsOther        = rhs.mIsOther;

    delete mExponential;
    if ( rhs.mExponential  != NULL)
    {
      mExponential = static_cast<ASTCnExponentialNode*>
                                  ( rhs.mExponential->deepCopy() );
    }
    else
    {
      mExponential = NULL;
    }

    delete mInteger;
    if ( rhs.mInteger  != NULL)
    {
      mInteger = static_cast<ASTCnIntegerNode*>
                                  ( rhs.mInteger->deepCopy() );
    }
    else
    {
      mInteger = NULL;
    }

    delete mRational;
    if ( rhs.mRational  != NULL)
    {
      mRational = static_cast<ASTCnRationalNode*>
                                  ( rhs.mRational->deepCopy() );
    }
    else
    {
      mRational = NULL;
    }

    delete mReal;
    if ( rhs.mReal  != NULL)
    {
      mReal = static_cast<ASTCnRealNode*>
                                  ( rhs.mReal->deepCopy() );
    }
    else
    {
      mReal = NULL;
    }

    delete mCiNumber;
    if ( rhs.mCiNumber  != NULL)
    {
      mCiNumber = static_cast<ASTCiNumberNode*>
                                  ( rhs.mCiNumber->deepCopy() );
    }
    else
    {
      mCiNumber = NULL;
    }

    delete mConstant;
    if ( rhs.mConstant  != NULL)
    {
      mConstant = static_cast<ASTConstantNumberNode*>
                                  ( rhs.mConstant->deepCopy() );
    }
    else
    {
      mConstant = NULL;
    }

    delete mCSymbol;
    if ( rhs.mCSymbol  != NULL)
    {
      mCSymbol = static_cast<ASTCSymbol*>
                                  ( rhs.mCSymbol->deepCopy() );
    }
    else
    {
      mCSymbol = NULL;
    }

  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTNumber::~ASTNumber ()
{
  if (mExponential  != NULL) delete mExponential;
  if (mInteger      != NULL) delete mInteger;
  if (mRational     != NULL) delete mRational;
  if (mReal         != NULL) delete mReal;
  if (mCiNumber     != NULL) delete mCiNumber;
  if (mConstant     != NULL) delete mConstant;
  if (mCSymbol      != NULL) delete mCSymbol;
}

int
ASTNumber::getTypeCode () const
{
  return AST_TYPECODE_NUMBER;
}


  /**
   * Creates a copy (clone).
   */
ASTNumber*
ASTNumber::deepCopy () const
{
  return new ASTNumber(*this);
}

int 
ASTNumber::setClass(std::string className)
{
  int success = ASTBase::setClass(className);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->setClass(className);
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->setClass(className);
    }
    else if (mRational != NULL)
    {
      success =  mRational->setClass(className);
    }
    else if (mReal != NULL)
    {
      success =  mReal->setClass(className);
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->setClass(className);
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->setClass(className);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setClass(className);
    }
  }

  return success;
}


int 
ASTNumber::setId(std::string id)
{
  int success = ASTBase::setId(id);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->setId(id);
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->setId(id);
    }
    else if (mRational != NULL)
    {
      success =  mRational->setId(id);
    }
    else if (mReal != NULL)
    {
      success =  mReal->setId(id);
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->setId(id);
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->setId(id);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setId(id);
    }
  }

  return success;
}


int 
ASTNumber::setStyle(std::string style)
{
  int success = ASTBase::setStyle(style);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->setStyle(style);
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->setStyle(style);
    }
    else if (mRational != NULL)
    {
      success =  mRational->setStyle(style);
    }
    else if (mReal != NULL)
    {
      success =  mReal->setStyle(style);
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->setStyle(style);
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->setStyle(style);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setStyle(style);
    }
  }

  return success;
}


int 
ASTNumber::setUnits(const std::string& units)
{
  int success = LIBSBML_UNEXPECTED_ATTRIBUTE;

  if (mExponential != NULL)
  {
    success =  mExponential->setUnits(units);
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->setUnits(units);
  }
  else if (mRational != NULL)
  {
    success =  mRational->setUnits(units);
  }
  else if (mReal != NULL)
  {
    success =  mReal->setUnits(units);
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->setUnits(units);
  }

  return success;
}


int 
ASTNumber::setUnitsPrefix(const std::string& prefix)
{
  int success = LIBSBML_UNEXPECTED_ATTRIBUTE;

  if (mExponential != NULL)
  {
    success =  mExponential->setUnitsPrefix(prefix);
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->setUnitsPrefix(prefix);
  }
  else if (mRational != NULL)
  {
    success =  mRational->setUnitsPrefix(prefix);
  }
  else if (mReal != NULL)
  {
    success =  mReal->setUnitsPrefix(prefix);
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->setUnitsPrefix(prefix);
  }

  return success;
}


int 
ASTNumber::setParentSBMLObject(SBase* sb)
{
  int success = ASTBase::setParentSBMLObject(sb);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->setParentSBMLObject(sb);
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->setParentSBMLObject(sb);
    }
    else if (mRational != NULL)
    {
      success =  mRational->setParentSBMLObject(sb);
    }
    else if (mReal != NULL)
    {
      success =  mReal->setParentSBMLObject(sb);
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->setParentSBMLObject(sb);
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->setParentSBMLObject(sb);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setParentSBMLObject(sb);
    }
  }

  return success;
}


int 
ASTNumber::setUserData(void* userData)
{
  int success = ASTBase::setUserData(userData);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->setUserData(userData);
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->setUserData(userData);
    }
    else if (mRational != NULL)
    {
      success =  mRational->setUserData(userData);
    }
    else if (mReal != NULL)
    {
      success =  mReal->setUserData(userData);
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->setUserData(userData);
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->setUserData(userData);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setUserData(userData);
    }
  }

  return success;
}


void 
ASTNumber::setIsChildFlag(bool flag)
{
  ASTBase::setIsChildFlag(flag);

  if (mExponential != NULL)
  {
    mExponential->setIsChildFlag(flag);
  }
  else if (mInteger != NULL)
  {
    mInteger->setIsChildFlag(flag);
  }
  else if (mRational != NULL)
  {
    mRational->setIsChildFlag(flag);
  }
  else if (mReal != NULL)
  {
    mReal->setIsChildFlag(flag);
  }
  else if (mCiNumber != NULL)
  {
    mCiNumber->setIsChildFlag(flag);
  }
  else if (mConstant != NULL)
  {
    mConstant->setIsChildFlag(flag);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->setIsChildFlag(flag);
  }
}


int 
ASTNumber::unsetClass()
{
  int success = ASTBase::unsetClass();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->unsetClass();
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->unsetClass();
    }
    else if (mRational != NULL)
    {
      success =  mRational->unsetClass();
    }
    else if (mReal != NULL)
    {
      success =  mReal->unsetClass();
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->unsetClass();
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->unsetClass();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetClass();
    }
  }

  return success;
}


int 
ASTNumber::unsetId()
{
  int success = ASTBase::unsetId();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->unsetId();
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->unsetId();
    }
    else if (mRational != NULL)
    {
      success =  mRational->unsetId();
    }
    else if (mReal != NULL)
    {
      success =  mReal->unsetId();
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->unsetId();
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->unsetId();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetId();
    }
  }

  return success;
}


int 
ASTNumber::unsetParentSBMLObject()
{
  int success = ASTBase::unsetParentSBMLObject();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->unsetParentSBMLObject();
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->unsetParentSBMLObject();
    }
    else if (mRational != NULL)
    {
      success =  mRational->unsetParentSBMLObject();
    }
    else if (mReal != NULL)
    {
      success =  mReal->unsetParentSBMLObject();
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->unsetParentSBMLObject();
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->unsetParentSBMLObject();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetParentSBMLObject();
    }
  }

  return success;
}


int 
ASTNumber::unsetStyle()
{
  int success = ASTBase::unsetStyle();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->unsetStyle();
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->unsetStyle();
    }
    else if (mRational != NULL)
    {
      success =  mRational->unsetStyle();
    }
    else if (mReal != NULL)
    {
      success =  mReal->unsetStyle();
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->unsetStyle();
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->unsetStyle();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetStyle();
    }
  }

  return success;
}


int 
ASTNumber::unsetUserData()
{
  int success = ASTBase::unsetUserData();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mExponential != NULL)
    {
      success =  mExponential->unsetUserData();
    }
    else if (mInteger != NULL)
    {
      success =  mInteger->unsetUserData();
    }
    else if (mRational != NULL)
    {
      success =  mRational->unsetUserData();
    }
    else if (mReal != NULL)
    {
      success =  mReal->unsetUserData();
    }
    else if (mCiNumber != NULL)
    {
      success =  mCiNumber->unsetUserData();
    }
    else if (mConstant != NULL)
    {
      success =  mConstant->unsetUserData();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetUserData();
    }
  }

  return success;
}


int 
ASTNumber::unsetUnits()
{
  int success = LIBSBML_UNEXPECTED_ATTRIBUTE;

  if (mExponential != NULL)
  {
    success =  mExponential->unsetUnits();
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->unsetUnits();
  }
  else if (mRational != NULL)
  {
    success =  mRational->unsetUnits();
  }
  else if (mReal != NULL)
  {
    success =  mReal->unsetUnits();
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->unsetUnits();
  }

  return success;
}


int 
ASTNumber::unsetUnitsPrefix()
{
  int success = LIBSBML_UNEXPECTED_ATTRIBUTE;

  if (mExponential != NULL)
  {
    success =  mExponential->unsetUnitsPrefix();
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->unsetUnitsPrefix();
  }
  else if (mRational != NULL)
  {
    success =  mRational->unsetUnitsPrefix();
  }
  else if (mReal != NULL)
  {
    success =  mReal->unsetUnitsPrefix();
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->unsetUnitsPrefix();
  }

  return success;
}


bool 
ASTNumber::isSetClass() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetClass();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isSetClass();
  }
  else if (mRational != NULL)
  {
    return mRational->isSetClass();
  }
  else if (mReal != NULL)
  {
    return mReal->isSetClass();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isSetClass();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isSetClass();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetClass();
  }
  else
  {
    return ASTBase::isSetClass();
  }
}


bool 
ASTNumber::isSetId() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetId();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isSetId();
  }
  else if (mRational != NULL)
  {
    return mRational->isSetId();
  }
  else if (mReal != NULL)
  {
    return mReal->isSetId();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isSetId();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isSetId();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetId();
  }
  else
  {
    return ASTBase::isSetId();
  }
}


bool 
ASTNumber::isSetParentSBMLObject() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetParentSBMLObject();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isSetParentSBMLObject();
  }
  else if (mRational != NULL)
  {
    return mRational->isSetParentSBMLObject();
  }
  else if (mReal != NULL)
  {
    return mReal->isSetParentSBMLObject();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isSetParentSBMLObject();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isSetParentSBMLObject();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetParentSBMLObject();
  }
  else
  {
    return ASTBase::isSetParentSBMLObject();
  }
}


bool 
ASTNumber::isSetStyle() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetStyle();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isSetStyle();
  }
  else if (mRational != NULL)
  {
    return mRational->isSetStyle();
  }
  else if (mReal != NULL)
  {
    return mReal->isSetStyle();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isSetStyle();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isSetStyle();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetStyle();
  }
  else
  {
    return ASTBase::isSetStyle();
  }
}


bool 
ASTNumber::isSetUserData() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetUserData();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isSetUserData();
  }
  else if (mRational != NULL)
  {
    return mRational->isSetUserData();
  }
  else if (mReal != NULL)
  {
    return mReal->isSetUserData();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isSetUserData();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isSetUserData();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetUserData();
  }
  else
  {
    return ASTBase::isSetUserData();
  }
}


bool 
ASTNumber::isSetUnits() const
{
  int success = false;

  if (mExponential != NULL)
  {
    success =  mExponential->isSetUnits();
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->isSetUnits();
  }
  else if (mRational != NULL)
  {
    success =  mRational->isSetUnits();
  }
  else if (mReal != NULL)
  {
    success =  mReal->isSetUnits();
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->isSetUnits();
  }

  return success;
}


bool 
ASTNumber::isSetUnitsPrefix() const
{
  int success = false;

  if (mExponential != NULL)
  {
    success =  mExponential->isSetUnitsPrefix();
  }
  else if (mInteger != NULL)
  {
    success =  mInteger->isSetUnitsPrefix();
  }
  else if (mRational != NULL)
  {
    success =  mRational->isSetUnitsPrefix();
  }
  else if (mReal != NULL)
  {
    success =  mReal->isSetUnitsPrefix();
  }
  else if (mConstant != NULL)
  {
    success =  mConstant->isSetUnitsPrefix();
  }

  return success;
}


std::string 
ASTNumber::getClass() const
{
  if (mExponential != NULL)
  {
    return mExponential->getClass();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getClass();
  }
  else if (mRational != NULL)
  {
    return mRational->getClass();
  }
  else if (mReal != NULL)
  {
    return mReal->getClass();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->getClass();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getClass();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getClass();
  }
  else
  {
    return ASTBase::getClass();
  }
}


std::string 
ASTNumber::getId() const
{
  if (mExponential != NULL)
  {
    return mExponential->getId();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getId();
  }
  else if (mRational != NULL)
  {
    return mRational->getId();
  }
  else if (mReal != NULL)
  {
    return mReal->getId();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->getId();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getId();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getId();
  }
  else
  {
    return ASTBase::getId();
  }
}


std::string 
ASTNumber::getStyle() const
{
  if (mExponential != NULL)
  {
    return mExponential->getStyle();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getStyle();
  }
  else if (mRational != NULL)
  {
    return mRational->getStyle();
  }
  else if (mReal != NULL)
  {
    return mReal->getStyle();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->getStyle();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getStyle();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getStyle();
  }
  else
  {
    return ASTBase::getStyle();
  }
}


std::string
ASTNumber::getUnits() const
{
  static std::string emptyString = "";

  if (mExponential != NULL)
  {
    return mExponential->getUnits();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getUnits();
  }
  else if (mRational != NULL)
  {
    return mRational->getUnits();
  }
  else if (mReal != NULL)
  {
    return mReal->getUnits();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getUnits();
  }
  else
  {
    return emptyString;
  }
}

SBase* 
ASTNumber::getParentSBMLObject() const
{
  if (mExponential != NULL)
  {
    return mExponential->getParentSBMLObject();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getParentSBMLObject();
  }
  else if (mRational != NULL)
  {
    return mRational->getParentSBMLObject();
  }
  else if (mReal != NULL)
  {
    return mReal->getParentSBMLObject();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->getParentSBMLObject();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getParentSBMLObject();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getParentSBMLObject();
  }
  else
  {
    return ASTBase::getParentSBMLObject();
  }
}


void* 
ASTNumber::getUserData() const
{
  if (mExponential != NULL)
  {
    return mExponential->getUserData();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getUserData();
  }
  else if (mRational != NULL)
  {
    return mRational->getUserData();
  }
  else if (mReal != NULL)
  {
    return mReal->getUserData();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->getUserData();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getUserData();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getUserData();
  }
  else
  {
    return ASTBase::getUserData();
  }
}



const std::string&
ASTNumber::getUnitsPrefix() const
{
  if (mExponential != NULL)
  {
    return mExponential->getUnitsPrefix();
  }
  else if (mInteger != NULL)
  {
    return mInteger->getUnitsPrefix();
  }
  else if (mRational != NULL)
  {
    return mRational->getUnitsPrefix();
  }
  else if (mReal != NULL)
  {
    return mReal->getUnitsPrefix();
  }
  else if (mConstant != NULL)
  {
    return mConstant->getUnitsPrefix();
  }
  else
  {
    return ASTBase::getUnitsPrefix();
  }
}



  
double 
ASTNumber::getMantissa() const
{
  if (mExponential != NULL)
  {
    return mExponential->getMantissa();
  }
  else
  {
    return 0;
  }
}

  
bool 
ASTNumber::isSetMantissa() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetMantissa();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setMantissa(double value)
{
  if (mExponential != NULL)
  {
    return mExponential->setMantissa(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTNumber::unsetMantissa()
{
  if (mExponential != NULL)
  {
    return mExponential->unsetMantissa();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


long 
ASTNumber::getExponent() const
{
  if (mExponential != NULL)
  {
    return mExponential->getExponent();
  }
  else
  {
    return 0;
  }
}

  
bool 
ASTNumber::isSetExponent() const
{
  if (mExponential != NULL)
  {
    return mExponential->isSetExponent();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setExponent(long value)
{
  if (mExponential != NULL)
  {
    return mExponential->setExponent(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTNumber::unsetExponent()
{
  if (mExponential != NULL)
  {
    return mExponential->unsetExponent();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

long 
ASTNumber::getInteger() const
{
  if (mInteger != NULL)
  {
    return mInteger->getInteger();
  }
  else
  {
    return 0;
  }
}

  
bool 
ASTNumber::isSetInteger() const
{
  if (mInteger != NULL)
  {
    return mInteger->isSetInteger();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setInteger(long value)
{
  if (mInteger != NULL)
  {
    return mInteger->setInteger(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::unsetInteger()
{
  if (mInteger != NULL)
  {
    return mInteger->unsetInteger();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


long 
ASTNumber::getDenominator() const
{
  if (mRational != NULL)
  {
    return mRational->getDenominator();
  }
  else
  {
    return 1;
  }
}

  
bool 
ASTNumber::isSetDenominator() const
{
  if (mRational != NULL)
  {
    return mRational->isSetDenominator();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setDenominator(long value)
{
  if (mRational != NULL)
  {
    return mRational->setDenominator(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::unsetDenominator()
{
  if (mRational != NULL)
  {
    return mRational->unsetDenominator();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


long 
ASTNumber::getNumerator() const
{
  if (mRational != NULL)
  {
    return mRational->getNumerator();
  }
  else
  {
    return 0;
  }
}

  
bool 
ASTNumber::isSetNumerator() const
{
  if (mRational != NULL)
  {
    return mRational->isSetNumerator();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setNumerator(long value)
{
  if (mRational != NULL)
  {
    return mRational->setNumerator(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::unsetNumerator()
{
  if (mRational != NULL)
  {
    return mRational->unsetNumerator();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

double 
ASTNumber::getReal() const
{
  if (mReal != NULL)
  {
    return mReal->getReal();
  }
  else
  {
    return 0;
  }
}

  
bool 
ASTNumber::isSetReal() const
{
  if (mReal != NULL)
  {
    return mReal->isSetReal();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setReal(double value)
{
  if (mReal != NULL)
  {
    return mReal->setReal(value);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::unsetReal()
{
  if (mReal != NULL)
  {
    return mReal->unsetReal();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::setValue(long numerator, long denominator)
{
  if (mRational == NULL)
  {
    std::string units = ASTNumber::getUnits();
    reset();
    mRational = new ASTCnRationalNode(AST_RATIONAL);
    mRational->setUnits(units);
    setType(AST_RATIONAL);
    mRational->ASTBase::syncMembersFrom(this);
  }
  int i = mRational->setNumerator(numerator);
  if (i == LIBSBML_OPERATION_SUCCESS)
    return mRational->setDenominator(denominator);
  else
    return i;
}


int 
ASTNumber::setValue(double value, long value1)
{
  if (mExponential == NULL)
  {
    std::string units = ASTNumber::getUnits();
    reset();
    mExponential = new ASTCnExponentialNode(AST_REAL_E);
    mExponential->setUnits(units);
    setType(AST_REAL_E);
    mExponential->ASTBase::syncMembersFrom(this);
  }

  int i = mExponential->setExponent(value1);
  if (i == LIBSBML_OPERATION_SUCCESS)
    return mExponential->setMantissa(value);
  else
    return i;
}

int 
ASTNumber::setValue(double value)
{
  if (mExponential == NULL && mReal == NULL && !(isnan(value) > 0 || util_isInf(value) != 0))
  {
    std::string units = ASTNumber::getUnits();
    reset();
    mReal = new ASTCnRealNode(AST_REAL);
    mReal->setUnits(units);
    setType(AST_REAL);
    mReal->ASTBase::syncMembersFrom(this);
  }
  else if ((isnan(value) > 0 || util_isInf(value) != 0) && mConstant == NULL) 
  {
    reset();
    mConstant = new ASTConstantNumberNode(AST_REAL);
    setType(AST_REAL);
    mConstant->ASTBase::syncMembersFrom(this);
  }

  if (mReal != NULL) 
  {
    return mReal->setReal(value);
  }
  else if (mConstant != NULL)
  {
    return mConstant->setValue(value);
  }
  else if (mExponential != NULL)
  {
    return mExponential->setValue(value, 0);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

int 
ASTNumber::setValue(long value)
{
  if (mInteger == NULL)
  {
    std::string units = ASTNumber::getUnits();
    reset();
    mInteger = new ASTCnIntegerNode(AST_INTEGER);
    mInteger->setUnits(units);
    setType(AST_INTEGER);
    mInteger->ASTBase::syncMembersFrom(this);
  }

  return mInteger->setInteger(value);
}


int 
ASTNumber::setValue(int value)
{
  if (mInteger == NULL)
  {
    std::string units = ASTNumber::getUnits();
    reset();
    mInteger = new ASTCnIntegerNode(AST_INTEGER);
    mInteger->setUnits(units);
    setType(AST_INTEGER);
    mInteger->ASTBase::syncMembersFrom(this);
  }

  return mInteger->setInteger(value);
}

double
ASTNumber::getValue() const
{
  if (mRational != NULL)
  {
    return mRational->getValue();
  }
  else if (mReal != NULL)
  {
    return mReal->getReal();
  }
  else if (mExponential != NULL)
  {
    return mExponential->getValue();
  }
  else if (mInteger != NULL)
  {
    return double (mInteger->getInteger());
  }
  else if (mConstant != NULL)
  {
    return mConstant->getValue();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getValue();
  }
  else if (mIsOther == true)
  {
    //FIX ME
    return 0;//getPlugin("qual")->getMath()->getValue();
  }
  else
  {
    return 0;//util_NaN();
  }

}


bool
ASTNumber::isSetConstantValue() const
{
  if (mConstant != NULL)
  {
    return mConstant->isSetValue();
  }
  else
  {
    return false;
  }
}

const std::string& 
ASTNumber::getName() const
{
  static std::string emptyString = "";
  if (mCiNumber != NULL)
  {
    return mCiNumber->getName();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getName();
  }
  else
  {
    return emptyString;
  }
}

  
bool 
ASTNumber::isSetName() const
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->isSetName();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetName();
  }
  else
  {
    return false;
  }
}

  
int 
ASTNumber::setName(const std::string& name)
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->setName(name);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setName(name);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTNumber::setNameAndChangeType(const std::string& name)
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->setName(name);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setName(name);
  }
  else if (representsNumber(getExtendedType()) == true)
  {
    reset();
    mCiNumber = new ASTCiNumberNode();
    mIsOther = false;
    setType(AST_NAME);
    mCiNumber->ASTBase::syncMembersFrom(this);
    return mCiNumber->setName(name);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTNumber::unsetName()
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->unsetName();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->unsetName();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTNumber::setDefinitionURL(const std::string& url)
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->setDefinitionURL(url);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setDefinitionURL(url);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
int 
ASTNumber::setEncoding(const std::string& encoding)
{
  if (mCSymbol != NULL)
  {
    return mCSymbol->setEncoding(encoding);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
const std::string& 
ASTNumber::getDefinitionURL() const
{
  static std::string emptyString = "";
  if (mCiNumber != NULL)
  {
    return mCiNumber->getDefinitionURL();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getDefinitionURL();
  }
  else
  {
    return emptyString;
  }
}


const std::string& 
ASTNumber::getEncoding() const
{
  static std::string emptyString = "";
  if (mCSymbol != NULL)
  {
    return mCSymbol->getEncoding();
  }
  else
  {
    return emptyString;
  }
}


bool
ASTNumber::isSetDefinitionURL() const
{
  if (mCiNumber != NULL)
  {
    return mCiNumber->isSetDefinitionURL();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetDefinitionURL();
  }
  else
  {
    return false;
  }
}

bool
ASTNumber::isSetEncoding() const
{
  if (mCSymbol != NULL)
  {
    return mCSymbol->isSetEncoding();
  }
  else
  {
    return false;
  }
}

/* convenience functions */
bool 
ASTNumber::isAvogadro() const
{
  bool valid = false;
  
  if (mCSymbol != NULL)
  {
    valid = mCSymbol->isAvogadro();
  }

  return valid;
}


bool 
ASTNumber::isBoolean() const
{
  bool valid = false;
  
  if (mConstant != NULL)
  {
    valid = mConstant->isBoolean();
  }

  return valid;
}


bool 
ASTNumber::isConstant() const
{
  bool valid = false;
  
  if (mCSymbol != NULL)
  {
    valid = mCSymbol->isConstant();
  }
  else if (mConstant != NULL)
  {
    valid = mConstant->isConstantNumber();
  }

  return valid;
}


bool 
ASTNumber::isFunction() const
{
  return false;
}


bool 
ASTNumber::isInfinity() const
{
  bool valid = false;
  
  if (mConstant != NULL)
  {
    valid = mConstant->isInfinity();
  }

  return valid;
}


bool 
ASTNumber::isInteger() const
{
  bool valid = false;
  
  if (mInteger != NULL)
  {
    valid = mInteger->isInteger();
  }

  return valid;
}


bool 
ASTNumber::isLambda() const
{
  return false;
}


bool 
ASTNumber::isLog10() const
{
  return false;
}


bool 
ASTNumber::isLogical() const
{
  return false;
}


bool 
ASTNumber::isName() const
{
  bool valid = false;
  
  if (mCSymbol != NULL)
  {
    valid = mCSymbol->isName();
  }
  else if (mCiNumber != NULL)
  {
    valid = mCiNumber->isName();
  }

  return valid;
}


bool 
ASTNumber::isNaN() const
{
  bool valid = false;
  
  if (mConstant != NULL)
  {
    valid = mConstant->isNaN();
  }

  return valid;
}


bool 
ASTNumber::isNegInfinity() const
{
  bool valid = false;
  
  if (mConstant != NULL)
  {
    valid = mConstant->isNegInfinity();
  }

  return valid;
}


bool 
ASTNumber::isNumber() const
{
  bool valid = false;
  
  if (mRational != NULL)
  {
    valid = mRational->isNumber();
  }
  else if (mReal != NULL)
  {
    valid = mReal->isNumber();
  }
  else if (mExponential != NULL)
  {
    valid = mExponential->isNumber();
  }
  else if (mInteger != NULL)
  {
    valid = mInteger->isNumber();
  }
  else if (mConstant != NULL)
  {
    valid = mConstant->isNumber();
  }

  return valid;
}


bool 
ASTNumber::isOperator() const
{
  return false;
}


bool 
ASTNumber::isPiecewise() const
{
  return false;
}


bool 
ASTNumber::isQualifier() const
{
  return false;
}


bool 
ASTNumber::isRational() const
{
  bool valid = false;
  
  if (mRational != NULL)
  {
    valid = mRational->isRational();
  }

  return valid;
}


bool 
ASTNumber::isReal() const
{
  bool valid = false;
  
  if (mReal != NULL)
  {
    valid = mReal->isReal();
  }
  else if (mConstant != NULL)
  {
    valid = mConstant->isReal();
  }

  return valid;
}


bool 
ASTNumber::isRelational() const
{
  return false;
}


bool 
ASTNumber::isSemantics() const
{
  return false;
}


bool 
ASTNumber::isSqrt() const
{
  return false;
}


bool 
ASTNumber::isUMinus() const
{
  return false;
}


bool 
ASTNumber::isUnknown() const
{
  bool isUnknown = false;
  if (mInteger != NULL)
  {
    isUnknown = mInteger->isUnknown();
  }
  else if (mRational != NULL)
  {
    isUnknown = mRational->isUnknown();
  }
  else if (mReal != NULL)
  {
    isUnknown = mReal->isUnknown();
  }
  else if (mExponential != NULL)
  {
    isUnknown = mExponential->isUnknown();
  }
  else if (mCiNumber != NULL)
  {
    isUnknown = mCiNumber->isUnknown();
  }
  else if (mConstant != NULL)
  {
    isUnknown = mConstant->isUnknown();
  }
  else if (mCSymbol != NULL)
  {
    isUnknown = mCSymbol->isUnknown();
  }
  else if (mIsOther == true)
  {
  }

  return isUnknown;
}


bool 
ASTNumber::isUPlus() const
{
  return false;
}


bool
ASTNumber::hasCnUnits() const
{
  bool hasCnUnits = false;
  
  if (mExponential != NULL)
  {
    hasCnUnits =  mExponential->hasCnUnits();
  }
  else if (mInteger != NULL)
  {
    hasCnUnits =  mInteger->hasCnUnits();
  }
  else if (mRational != NULL)
  {
    hasCnUnits =  mRational->hasCnUnits();
  }
  else if (mReal != NULL)
  {
    hasCnUnits =  mReal->hasCnUnits();
  }

  return hasCnUnits;
}


bool 
ASTNumber::isWellFormedNode() const
{
  if (mExponential != NULL)
  {
    return mExponential->isWellFormedNode();
  }
  else if (mInteger != NULL)
  {
    return mInteger->isWellFormedNode();
  }
  else if (mRational != NULL)
  {
    return mRational->isWellFormedNode();
  }
  else if (mReal != NULL)
  {
    return mReal->isWellFormedNode();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->isWellFormedNode();
  }
  else if (mConstant != NULL)
  {
    return mConstant->isWellFormedNode();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isWellFormedNode();
  }
  else
  {
    return ASTBase::isWellFormedNode();
  }
}


bool 
ASTNumber::hasCorrectNumberArguments() const
{
  if (mExponential != NULL)
  {
    return mExponential->hasCorrectNumberArguments();
  }
  else if (mInteger != NULL)
  {
    return mInteger->hasCorrectNumberArguments();
  }
  else if (mRational != NULL)
  {
    return mRational->hasCorrectNumberArguments();
  }
  else if (mReal != NULL)
  {
    return mReal->hasCorrectNumberArguments();
  }
  else if (mCiNumber != NULL)
  {
    return mCiNumber->hasCorrectNumberArguments();
  }
  else if (mConstant != NULL)
  {
    return mConstant->hasCorrectNumberArguments();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->hasCorrectNumberArguments();
  }
  else
  {
    return ASTBase::hasCorrectNumberArguments();
  }
}


void 
ASTNumber::write(XMLOutputStream& stream) const
{
  if (mInteger != NULL)
  {
    mInteger->write(stream);
  }
  else if (mRational != NULL)
  {
    mRational->write(stream);
  }
  else if (mReal != NULL)
  {
    mReal->write(stream);
  }
  else if (mExponential != NULL)
  {
    mExponential->write(stream);
  }
  else if (mCiNumber != NULL)
  {
    mCiNumber->write(stream);
  }
  else if (mConstant != NULL)
  {
    mConstant->write(stream);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->write(stream);
  }
  else if (mIsOther == true)
  {
    // FIX ME
    //getPlugin("qual")->getMath()->write(stream);
  }
}

bool 
ASTNumber::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek();
  const string&  name = element.getName();
  
  //ASTBase::checkPrefix(stream, reqd_prefix, element);

  if (isTopLevelMathMLNumberNodeTag(name) == false)
  {
#if 0
    cout << "[DEBUG] Number::read\nBAD THINGS ARE HAPPENING\n\n";
#endif
  }
  
  if (name == "cn")
  {
    std::string type = "real";
    element.getAttributes().readInto("type", type);
    if (type == "integer")
    {
      mInteger = new ASTCnIntegerNode();
      read = mInteger->read(stream, reqd_prefix);
      if (read == true && mInteger != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mInteger);
      }
    }
    else if (type == "rational")
    {
      mRational = new ASTCnRationalNode();
      read = mRational->read(stream, reqd_prefix);
      if (read == true && mRational != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mRational);
      }
    }
    else if (type == "e-notation")
    {
      mExponential = new ASTCnExponentialNode();
      read = mExponential->read(stream, reqd_prefix);
      if (read == true && mExponential != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mExponential);
      }
    }
    else if (type == "real")
    {
      mReal = new ASTCnRealNode();
      read = mReal->read(stream, reqd_prefix);
      if (read == true && mReal != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mReal);
      }
    }
    else
    {
      logError(stream, element, DisallowedMathTypeAttributeValue);      
      //for (unsigned int i = 0; i < getNumPlugins(); i++)
      //{
      //  read = getPlugin(i)->read(stream, reqd_prefix);
      //  if (read == true && getPlugin(i)->getMath() != NULL)
      //  {
      //    setType(getPlugin(i)->getMath()->getType());
      //    mIsOther = true;
      //    break;
      //  }
      //}
    }
  }
  else if (name == "ci")
  {
    mCiNumber = new ASTCiNumberNode();
    read = mCiNumber->read(stream, reqd_prefix);
    if (read == true && mCiNumber != NULL)
    {
      this->ASTBase::syncMembersAndResetParentsFrom(mCiNumber);
    }
  }
  else if (name == "true" || name == "false"
    || name == "pi" || name == "exponentiale"
    || name == "notanumber" || name == "infinity")
  {
    mConstant = new ASTConstantNumberNode();
    read = mConstant->read(stream, reqd_prefix);
    if (read == true && mConstant != NULL)
    {
      this->ASTBase::syncMembersAndResetParentsFrom(mConstant);
    }

  }

  else if (name == "csymbol")
  {
    mCSymbol = new ASTCSymbol();
    read = mCSymbol->read(stream, reqd_prefix);
    if (read == true && mCSymbol != NULL)
    {
      this->ASTBase::syncMembersAndResetParentsFrom(mCSymbol);
    }
  }
  return read;
}

void
ASTNumber::syncMembersAndTypeFrom(ASTNumber* rhs, int type)
{
  if (mInteger != NULL)
  {
    mInteger->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mInteger->setType(type);
    if (rhs->isSetUnits() == true)
    {
      mInteger->setUnits(rhs->getUnits());
      mInteger->setUnitsPrefix(rhs->getUnitsPrefix());
    }
    if (rhs->isSetInteger() == true) 
    {
      mInteger->setInteger(rhs->getInteger());
    }
    this->ASTBase::syncMembersFrom(mInteger);
  }
  else if (mRational != NULL)
  {
    mRational->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mRational->setType(type);
    if (rhs->isSetUnits() == true)
    {
      mRational->setUnits(rhs->getUnits());
      mRational->setUnitsPrefix(rhs->getUnitsPrefix());
    }
    if (rhs->isSetDenominator() == true)
    {
      mRational->setDenominator(rhs->getDenominator());
    }
    if (rhs->isSetNumerator() == true)
    {
      mRational->setNumerator(rhs->getNumerator());
    }
    this->ASTBase::syncMembersFrom(mRational);
  }
  else if (mReal != NULL)
  {
    mReal->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mReal->setType(type);
    if (rhs->isSetUnits() == true)
    {
      mReal->setUnits(rhs->getUnits());
      mReal->setUnitsPrefix(rhs->getUnitsPrefix());
    }
    if (rhs->isSetReal() == true)
    {
      mReal->setReal(rhs->getValue());
    }
    
    if (rhs->isSetConstantValue())
    {
      setValue(rhs->getValue());
    }
    else
      this->ASTBase::syncMembersFrom(mReal);
  }
  else if (mExponential != NULL)
  {
    mExponential->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mExponential->setType(type);
    if (rhs->isSetUnits() == true)
    {
      mExponential->setUnits(rhs->getUnits());
      mExponential->setUnitsPrefix(rhs->getUnitsPrefix());
    }
    if (rhs->isSetExponent() == true)
    {
      mExponential->setExponent(rhs->getExponent());
    }
    if (rhs->isSetMantissa() == true)
    {
      mExponential->setMantissa(rhs->getMantissa());
    }
    this->ASTBase::syncMembersFrom(mExponential);
  }
  else if (mCiNumber != NULL)
  {
    mCiNumber->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mCiNumber->setType(type);
    if (rhs->isSetName() == true)
    {
      mCiNumber->setName(rhs->getName());
    }
    if (rhs->isSetDefinitionURL() == true)
    {
      mCiNumber->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mCiNumber);
  }
  else if (mConstant != NULL)
  {
    mConstant->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mConstant->setType(type);
    if (rhs->isSetConstantValue() == true)
    {
      mConstant->setValue(rhs->getValue());
    }
    if (rhs->isSetUnits() == true && mExponential != NULL)
    {
      mExponential->setUnits(rhs->getUnits());
      mExponential->setUnitsPrefix(rhs->getUnitsPrefix());
    }
    this->ASTBase::syncMembersFrom(mConstant);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->syncMembersAndTypeFrom(rhs, type);
    this->ASTBase::syncMembersFrom(mCSymbol);
  }
  else if (mIsOther == true)
  {
  }
}



void
ASTNumber::syncMembersAndTypeFrom(ASTFunction* rhs, int type)
{
  if (mInteger != NULL)
  {
    mInteger->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mInteger->setType(type);
    this->ASTBase::syncMembersFrom(mInteger);
  }
  else if (mRational != NULL)
  {
    mRational->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mRational->setType(type);
    this->ASTBase::syncMembersFrom(mRational);
  }
  else if (mReal != NULL)
  {
    mReal->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mReal->setType(type);
    this->ASTBase::syncMembersFrom(mReal);
  }
  else if (mExponential != NULL)
  {
    mExponential->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mExponential->setType(type);
    this->ASTBase::syncMembersFrom(mExponential);
  }
  else if (mCiNumber != NULL)
  {
    mCiNumber->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mCiNumber->setType(type);
    if (rhs->isSetDefinitionURL() == true)
    {
      mCiNumber->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mCiNumber);
  }
  else if (mConstant != NULL)
  {
    mConstant->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mConstant->setType(type);
    this->ASTBase::syncMembersFrom(mConstant);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->syncMembersAndTypeFrom(rhs, type);
    this->ASTBase::syncMembersFrom(mCSymbol);
  }
  else if (mIsOther == true)
  {
  }
}



void
ASTNumber::reset()
{
  if (mExponential != NULL)
  {
    delete mExponential;
    mExponential = NULL;
  }

  if (mInteger != NULL)
  {
    delete mInteger;
    mInteger = NULL;
  }

  if (mRational != NULL)
  {
    delete mRational;
    mRational = NULL;
  }

  if (mReal != NULL)
  {
    delete mReal;
    mReal = NULL;
  }

  if (mCiNumber != NULL)
  {
    delete mCiNumber;
    mCiNumber = NULL;
  }

  if (mConstant != NULL)
  {
    delete mConstant;
    mConstant = NULL;
  }

  if (mCSymbol != NULL)
  {
    delete mCSymbol;
    mCSymbol = NULL;
  }

  mIsOther = false;
}



LIBSBML_CPP_NAMESPACE_END


/** @endcond */

