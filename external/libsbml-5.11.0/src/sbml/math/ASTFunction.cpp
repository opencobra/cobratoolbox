/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTFunction.cpp
 * @brief   Umbrella function class for Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/extension/ASTBasePlugin.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */


LIBSBML_CPP_NAMESPACE_BEGIN

static unsigned int
determineNumChildren(XMLInputStream & stream, 
                     const std::string& element = "")
{
  unsigned int n = 0;

  n = stream.determineNumberChildren(element);

  return n;
}

#if 0
static unsigned int
determineNumQualifiers(XMLInputStream & stream, 
                       const std::string& qualifier,
                       const std::string& container)
{
  unsigned int n = 0;

  n = stream.determineNumSpecificChildren(qualifier, container);

  return n;
}
#endif

static unsigned int
determineNumBvars(XMLInputStream & stream)
{
  unsigned int n = 0;

  const std::string bvar = "bvar";
  const std::string lambda = "lambda";

  n = stream.determineNumSpecificChildren(bvar, lambda);

  return n;
}

static unsigned int
determineNumArgs(XMLInputStream & stream, const std::string& nodeName)
{
  unsigned int n = 0;

  const std::string emptyString = "";

  n = stream.determineNumSpecificChildren(emptyString, nodeName);

  return n;
}

static unsigned int
determineNumPiece(XMLInputStream & stream)
{
  unsigned int n = 0;

  const std::string piece = "piece";
  const std::string piecewise = "piecewise";

  n = stream.determineNumSpecificChildren(piece, piecewise);

  return n;
}

bool
hasOtherwise(XMLInputStream & stream)
{
  unsigned int n = 0;

  const std::string otherwise = "otherwise";
  const std::string piecewise = "piecewise";

  n = stream.determineNumSpecificChildren(otherwise, piecewise);

  if (n > 0)
    return true;
  else
    return false;
}

static unsigned int
determineNumAnnotations(XMLInputStream & stream)
{
  unsigned int n = 0, n1 = 0;

  const std::string annot = "annotation";
  const std::string annot_xml = "annotation-xml";
  const std::string semantics = "semantics";

  n = stream.determineNumSpecificChildren(annot, semantics);
  n1 = stream.determineNumSpecificChildren(annot_xml, semantics);
    
  return n + n1;
}
/**
 * @return s with whitespace removed from the beginning and end.
 */
static const string
trim (const string& s)
{
  if (&s == NULL) return s;

  static const string whitespace(" \t\r\n");

  string::size_type begin = s.find_first_not_of(whitespace);
  string::size_type end   = s.find_last_not_of (whitespace);

  return (begin == string::npos) ? string() : s.substr(begin, end - begin + 1);
}


ASTFunction::ASTFunction (int type) :
   ASTBase   (type)
  , mUnaryFunction    ( NULL )
  , mBinaryFunction   ( NULL )
  , mNaryFunction     ( NULL )
  , mUserFunction     ( NULL )
  , mLambda           ( NULL )
  , mPiecewise        ( NULL )
  , mCSymbol          ( NULL )
  , mQualifier        ( NULL )
  , mSemantics        ( NULL )
  , mIsOther          ( false )
{
  if (this->ASTBase::isUnaryFunction() == true)
  {
    mUnaryFunction = new ASTUnaryFunctionNode(type);
    this->ASTBase::syncPluginsFrom(mUnaryFunction);
  }
  else if (type == AST_FUNCTION_DELAY)
  {
    mCSymbol = new ASTCSymbol(type);
    this->ASTBase::syncPluginsFrom(mCSymbol);
  }
  else if (this->ASTBase::isBinaryFunction() == true
    && type != AST_FUNCTION_DELAY)
  {
    mBinaryFunction = new ASTBinaryFunctionNode(type);
    this->ASTBase::syncPluginsFrom(mBinaryFunction);
  }
  else if (this->ASTBase::isNaryFunction() == true)
  {
    mNaryFunction = new ASTNaryFunctionNode(type);
    this->ASTBase::syncPluginsFrom(mNaryFunction);
  }
  else if (this->ASTBase::isQualifier() == true)
  {
    mQualifier = new ASTQualifierNode(type);
    this->ASTBase::syncPluginsFrom(mQualifier);
  }
  else if (type == AST_FUNCTION)
  {
    mUserFunction = new ASTCiFunctionNode();
    this->ASTBase::syncPluginsFrom(mUserFunction);
  }
  else if (type == AST_LAMBDA)
  {
    mLambda = new ASTLambdaFunctionNode();
    this->ASTBase::syncPluginsFrom(mLambda);
  }
  else if (type == AST_FUNCTION_PIECEWISE)
  {
    mPiecewise = new ASTPiecewiseFunctionNode();
    this->ASTBase::syncPluginsFrom(mPiecewise);
  }
  else if (type == AST_SEMANTICS)
  {
    mSemantics = new ASTSemanticsNode();
    this->ASTBase::syncPluginsFrom(mSemantics);
  }
  else if (type == AST_UNKNOWN)
  {
    mNaryFunction = new ASTNaryFunctionNode(type);
    this->ASTBase::syncPluginsFrom(mNaryFunction);
  }
  else
  {
    bool done = false;
    unsigned int i = 0;
    while (done == false && i < getNumPlugins())
    {
      if (getPlugin(i)->isFunctionNode(type) == true)
      {
        getPlugin(i)->createMath(type);
        this->setPackageName(getPlugin(i)->getPackageName());
        done = true;
      }
      i++;
    }

    if (done == true)
    {
      mIsOther = true;
    }
  }
}
  

 
  /**
   * Copy constructor
   */
ASTFunction::ASTFunction (const ASTFunction& orig):
    ASTBase (orig)
      , mUnaryFunction    ( NULL )
      , mBinaryFunction   ( NULL )
      , mNaryFunction     ( NULL )
      , mUserFunction     ( NULL )
      , mLambda           ( NULL )
      , mPiecewise        ( NULL )
      , mCSymbol          ( NULL )
      , mQualifier        ( NULL )
      , mSemantics        ( NULL )
      , mIsOther          ( orig.mIsOther )
{
  if ( orig.mUnaryFunction  != NULL)
  {
    mUnaryFunction = static_cast<ASTUnaryFunctionNode*>
                                ( orig.mUnaryFunction->deepCopy() );
  }
  if ( orig.mBinaryFunction  != NULL)
  {
    mBinaryFunction = static_cast<ASTBinaryFunctionNode*>
                                 ( orig.mBinaryFunction->deepCopy() );
  }
  if ( orig.mNaryFunction  != NULL)
  {
    mNaryFunction = static_cast<ASTNaryFunctionNode*>
                               ( orig.mNaryFunction->deepCopy() );
  }
  if ( orig.mUserFunction != NULL)
  {
    mUserFunction = static_cast<ASTCiFunctionNode*>
                               ( orig.mUserFunction->deepCopy() );
  }
  if ( orig.mLambda != NULL)
  {
    mLambda = static_cast<ASTLambdaFunctionNode*>( orig.mLambda->deepCopy() );
  }
  if ( orig.mPiecewise != NULL)
  {
    mPiecewise = static_cast<ASTPiecewiseFunctionNode*>
                            ( orig.mPiecewise->deepCopy() );
  }
  if ( orig.mCSymbol  != NULL)
  {
    mCSymbol = static_cast<ASTCSymbol*>( orig.mCSymbol->deepCopy() );
  }
  if ( orig.mQualifier  != NULL)
  {
    mQualifier = static_cast<ASTQualifierNode*>( orig.mQualifier->deepCopy() );
  }
  if ( orig.mSemantics  != NULL)
  {
    mSemantics = static_cast<ASTSemanticsNode*>( orig.mSemantics->deepCopy() );
  }
}
  /**
   * Assignment operator for ASTNode.
   */
ASTFunction&
ASTFunction::operator=(const ASTFunction& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    mIsOther          = rhs.mIsOther;
    
    delete mUnaryFunction;
    if ( rhs.mUnaryFunction  != NULL)
    {
      mUnaryFunction = static_cast<ASTUnaryFunctionNode*>
                                  ( rhs.mUnaryFunction->deepCopy() );
    }
    else
    {
      mUnaryFunction = NULL;
    }

    delete mBinaryFunction;
    if ( rhs.mBinaryFunction  != NULL)
    {
      mBinaryFunction = static_cast<ASTBinaryFunctionNode*>
                                   ( rhs.mBinaryFunction->deepCopy() );
    }
    else
    {
      mBinaryFunction = NULL;
    }

    delete mNaryFunction;
    if ( rhs.mNaryFunction  != NULL)
    {
      mNaryFunction = static_cast<ASTNaryFunctionNode*>
                                 ( rhs.mNaryFunction->deepCopy() );
    }
    else
    {
      mNaryFunction = NULL;
    }

    delete mUserFunction;
    if ( rhs.mUserFunction != NULL)
    {
      mUserFunction = static_cast<ASTCiFunctionNode*>
                                 ( rhs.mUserFunction->deepCopy() );
    }
    else
    {
      mUserFunction = NULL;
    }

    delete mLambda;
    if ( rhs.mLambda != NULL)
    {
      mLambda = static_cast<ASTLambdaFunctionNode*>( rhs.mLambda->deepCopy() );
    }
    else
    {
      mLambda = NULL;
    }

    delete mPiecewise;
    if ( rhs.mPiecewise != NULL)
    {
      mPiecewise = static_cast<ASTPiecewiseFunctionNode*>
                              ( rhs.mPiecewise->deepCopy() );
    }
    else
    {
      mPiecewise = NULL;
    }

    delete mCSymbol;
    if ( rhs.mCSymbol  != NULL)
    {
      mCSymbol = static_cast<ASTCSymbol*>( rhs.mCSymbol->deepCopy() );
    }
    else
    {
      mCSymbol = NULL;
    }

    delete mQualifier;
    if ( rhs.mQualifier  != NULL)
    {
      mQualifier = static_cast<ASTQualifierNode*>( rhs.mQualifier->deepCopy() );
    }
    else
    {
      mQualifier = NULL;
    }

    delete mSemantics;
    if ( rhs.mSemantics  != NULL)
    {
      mSemantics = static_cast<ASTSemanticsNode*>( rhs.mSemantics->deepCopy() );
    }
    else
    {
      mSemantics = NULL;
    }
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTFunction::~ASTFunction ()
{
  if (mUnaryFunction  != NULL) delete mUnaryFunction;
  if (mBinaryFunction != NULL) delete mBinaryFunction;
  if (mNaryFunction   != NULL) delete mNaryFunction;
  if (mUserFunction   != NULL) delete mUserFunction;
  if (mLambda         != NULL) delete mLambda;
  if (mPiecewise      != NULL) delete mPiecewise;
  if (mCSymbol        != NULL) delete mCSymbol;
  if (mQualifier      != NULL) delete mQualifier;
  if (mSemantics      != NULL) delete mSemantics;
}

int
ASTFunction::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION;
}


  /**
   * Creates a copy (clone).
   */
ASTFunction*
ASTFunction::deepCopy () const
{
  return new ASTFunction(*this);
}

int 
ASTFunction::addChild(ASTBase * child)
{
  if (child == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->addChild(child);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->addChild(child);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->addChild(child);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->addChild(child);
  }
  else if (mLambda != NULL)
  {
    return mLambda->addChild(child);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->addChild(child);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->addChild(child);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->addChild(child);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->addChild(child);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->addChild(child);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->addChild(child);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_INVALID_OBJECT;
    }
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

ASTBase* 
ASTFunction::getChild (unsigned int n) const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getChild(n);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getChild(n);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getChild(n);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getChild(n);
  }
  else if (mLambda != NULL)
  {
    return mLambda->getChild(n);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getChild(n);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getChild(n);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getChild(n);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getChild(n);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->getChild(n);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->getChild(n);
        }
        i++;
      }

      // nothing happened
      return NULL;
    }
  }
  else
  {
    return NULL;
  }
}

unsigned int 
ASTFunction::getNumChildren() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getNumChildren();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getNumChildren();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getNumChildren();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getNumChildren();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getNumChildren();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getNumChildren();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getNumChildren();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getNumChildren();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getNumChildren();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->getNumChildren();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->getNumChildren();
        }
        i++;
      }

      // nothing happened
      return 0;
    }
  }
  else
  {
    return 0;
  }
}


int
ASTFunction::removeChild(unsigned int n)
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->removeChild(n);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->removeChild(n);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->removeChild(n);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->removeChild(n);
  }
  else if (mLambda != NULL)
  {
    return mLambda->removeChild(n);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->removeChild(n);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->removeChild(n);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->removeChild(n);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->removeChild(n);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->removeChild(n);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->removeChild(n);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int
ASTFunction::prependChild(ASTBase* newChild)
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->prependChild(newChild);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->prependChild(newChild);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->prependChild(newChild);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->prependChild(newChild);
  }
  else if (mLambda != NULL)
  {
    return mLambda->prependChild(newChild);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->prependChild(newChild);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->prependChild(newChild);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->prependChild(newChild);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->prependChild(newChild);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->prependChild(newChild);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->prependChild(newChild);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int
ASTFunction::replaceChild(unsigned int n, ASTBase* newChild, bool delreplaced)
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->replaceChild(n, newChild, delreplaced);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->replaceChild(n, newChild, delreplaced);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->replaceChild(n, newChild, delreplaced);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->replaceChild(n, newChild, delreplaced);
  }
  else if (mLambda != NULL)
  {
    return mLambda->replaceChild(n, newChild, delreplaced);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->replaceChild(n, newChild, delreplaced);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->replaceChild(n, newChild, delreplaced);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->replaceChild(n, newChild, delreplaced);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->replaceChild(n, newChild, delreplaced);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->replaceChild(n, newChild, delreplaced);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->replaceChild(n, newChild, delreplaced);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int
ASTFunction::insertChild(unsigned int n, ASTBase* newChild)
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->insertChild(n, newChild);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->insertChild(n, newChild);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->insertChild(n, newChild);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->insertChild(n, newChild);
  }
  else if (mLambda != NULL)
  {
    return mLambda->insertChild(n, newChild);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->insertChild(n, newChild);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->insertChild(n, newChild);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->insertChild(n, newChild);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->insertChild(n, newChild);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->insertChild(n, newChild);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->insertChild(n, newChild);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int
ASTFunction::swapChildren(ASTFunction* that)
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->swapChildren(that);
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->swapChildren(that);
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->swapChildren(that);
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->swapChildren(that);
  }
  else if (mLambda != NULL)
  {
    return mLambda->swapChildren(that);
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->swapChildren(that);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->swapChildren(that);
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->swapChildren(that);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->swapChildren(that);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return getPlugin(mPackageName)->swapChildren(that);
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return getPlugin(i)->swapChildren(that);
        }
        i++;
      }

      // nothing happened
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}

void 
ASTFunction::setIsChildFlag(bool flag)
{
  ASTBase::setIsChildFlag(flag);

  if (mUnaryFunction != NULL)
  {
    mUnaryFunction->setIsChildFlag(flag);
  }
  else if (mBinaryFunction != NULL)
  {
    mBinaryFunction->setIsChildFlag(flag);
  }
  else if (mNaryFunction != NULL)
  {
    mNaryFunction->setIsChildFlag(flag);
  }
  else if (mUserFunction != NULL)
  {
    mUserFunction->setIsChildFlag(flag);
  }
  else if (mLambda != NULL)
  {
    mLambda->setIsChildFlag(flag);
  }
  else if (mPiecewise != NULL)
  {
    mPiecewise->setIsChildFlag(flag);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->setIsChildFlag(flag);
  }
  else if (mQualifier != NULL)
  {
    mQualifier->setIsChildFlag(flag);
  }
  else if (mSemantics != NULL)
  {
    mSemantics->setIsChildFlag(flag);
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->setIsChildFlag(flag);
    }
    else
    {
      unsigned int i = 0;
      bool found = false;
      while (found == false && i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->setIsChildFlag(flag);
          found = true;
        }
        i++;
      }
    }
  }
}



int 
ASTFunction::setClass(std::string className)
{
  int success = ASTBase::setClass(className);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->setClass(className);
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->setClass(className);
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->setClass(className);
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->setClass(className);
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->setClass(className);
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->setClass(className);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setClass(className);
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->setClass(className);
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->setClass(className);
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->setClass(className);
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->setClass(className);
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::setId(std::string id)
{
  int success = ASTBase::setId(id);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->setId(id);
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->setId(id);
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->setId(id);
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->setId(id);
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->setId(id);
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->setId(id);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setId(id);
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->setId(id);
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->setId(id);
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->setId(id);
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->setId(id);
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::setStyle(std::string style)
{
  int success = ASTBase::setStyle(style);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->setStyle(style);
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->setStyle(style);
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->setStyle(style);
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->setStyle(style);
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->setStyle(style);
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->setStyle(style);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setStyle(style);
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->setStyle(style);
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->setStyle(style);
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->setStyle(style);
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->setStyle(style);
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::unsetClass()
{
  int success = ASTBase::unsetClass();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->unsetClass();
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->unsetClass();
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->unsetClass();
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->unsetClass();
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->unsetClass();
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->unsetClass();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetClass();
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->unsetClass();
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->unsetClass();
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->unsetClass();
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->unsetClass();
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::unsetId()
{
  int success = ASTBase::unsetId();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->unsetId();
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->unsetId();
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->unsetId();
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->unsetId();
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->unsetId();
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->unsetId();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetId();
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->unsetId();
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->unsetId();
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->unsetId();
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->unsetId();
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::unsetParentSBMLObject()
{
  int success = ASTBase::unsetParentSBMLObject();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->unsetParentSBMLObject();
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->unsetParentSBMLObject();
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->unsetParentSBMLObject();
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->unsetParentSBMLObject();
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->unsetParentSBMLObject();
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->unsetParentSBMLObject();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetParentSBMLObject();
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->unsetParentSBMLObject();
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->unsetParentSBMLObject();
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->unsetParentSBMLObject();
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->unsetParentSBMLObject();
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::unsetStyle()
{
  int success = ASTBase::unsetStyle();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->unsetStyle();
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->unsetStyle();
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->unsetStyle();
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->unsetStyle();
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->unsetStyle();
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->unsetStyle();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetStyle();
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->unsetStyle();
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->unsetStyle();
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->unsetStyle();
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->unsetStyle();
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


bool 
ASTFunction::isSetClass() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isSetClass();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isSetClass();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isSetClass();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isSetClass();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isSetClass();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isSetClass();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetClass();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isSetClass();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetClass();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isSetClass();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isSetClass();
        }
        i++;
      }
      
      return ASTBase::isSetClass();
    }
  }
  else
  {
    return ASTBase::isSetClass();
  }
}


bool 
ASTFunction::isSetId() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isSetId();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isSetId();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isSetId();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isSetId();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isSetId();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isSetId();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetId();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isSetId();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetId();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isSetId();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isSetId();
        }
        i++;
      }
      
      return ASTBase::isSetId();
    }
  }
  else
  {
    return ASTBase::isSetId();
  }
}


bool 
ASTFunction::isSetParentSBMLObject() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isSetParentSBMLObject();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isSetParentSBMLObject();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isSetParentSBMLObject();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isSetParentSBMLObject();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isSetParentSBMLObject();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isSetParentSBMLObject();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetParentSBMLObject();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isSetParentSBMLObject();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetParentSBMLObject();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isSetParentSBMLObject();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isSetParentSBMLObject();
        }
        i++;
      }
      
      return ASTBase::isSetParentSBMLObject();
    }
  }
  else
  {
    return ASTBase::isSetParentSBMLObject();
  }
}


bool 
ASTFunction::isSetStyle() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isSetStyle();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isSetStyle();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isSetStyle();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isSetStyle();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isSetStyle();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isSetStyle();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetStyle();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isSetStyle();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetStyle();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isSetStyle();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isSetStyle();
        }
        i++;
      }
      
      return ASTBase::isSetStyle();
    }
  }
  else
  {
    return ASTBase::isSetStyle();
  }
}


bool 
ASTFunction::isSetUserData() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isSetUserData();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isSetUserData();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isSetUserData();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isSetUserData();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isSetUserData();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isSetUserData();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetUserData();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isSetUserData();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetUserData();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isSetUserData();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isSetUserData();
        }
        i++;
      }
      
      return ASTBase::isSetUserData();
    }
  }
  else
  {
    return ASTBase::isSetUserData();
  }
}


  
int 
ASTFunction::unsetUserData()
{
  int success = ASTBase::unsetUserData();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->unsetUserData();
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->unsetUserData();
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->unsetUserData();
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->unsetUserData();
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->unsetUserData();
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->unsetUserData();
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->unsetUserData();
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->unsetUserData();
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->unsetUserData();
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->unsetUserData();
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->unsetUserData();
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


std::string 
ASTFunction::getClass() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getClass();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getClass();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getClass();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getClass();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getClass();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getClass();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getClass();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getClass();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getClass();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getClass();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getClass();
        }
        i++;
      }

      // nothing happened
      return ASTBase::getClass();
    }
  }
  else
  {
    return ASTBase::getClass();
  }
}


std::string 
ASTFunction::getId() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getId();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getId();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getId();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getId();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getId();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getId();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getId();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getId();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getId();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getId();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getId();
        }
        i++;
      }

      // nothing happened
      return ASTBase::getId();
    }
  }
  else
  {
    return ASTBase::getId();
  }
}


std::string 
ASTFunction::getStyle() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getStyle();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getStyle();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getStyle();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getStyle();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getStyle();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getStyle();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getStyle();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getStyle();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getStyle();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getStyle();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getStyle();
        }
        i++;
      }

      // nothing happened
      return ASTBase::getStyle();
    }
  }
  else
  {
    return ASTBase::getStyle();
  }
}

int 
ASTFunction::setParentSBMLObject(SBase* sb)
{
  int success = ASTBase::setParentSBMLObject(sb);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->setParentSBMLObject(sb);
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->setParentSBMLObject(sb);
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->setParentSBMLObject(sb);
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->setParentSBMLObject(sb);
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->setParentSBMLObject(sb);
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->setParentSBMLObject(sb);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setParentSBMLObject(sb);
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->setParentSBMLObject(sb);
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->setParentSBMLObject(sb);
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->setParentSBMLObject(sb);
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->setParentSBMLObject(sb);
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


int 
ASTFunction::setUserData(void* userData)
{
  int success = ASTBase::setUserData(userData);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mUnaryFunction != NULL)
    {
      success =  mUnaryFunction->setUserData(userData);
    }
    else if (mBinaryFunction != NULL)
    {
      success =  mBinaryFunction->setUserData(userData);
    }
    else if (mNaryFunction != NULL)
    {
      success =  mNaryFunction->setUserData(userData);
    }
    else if (mUserFunction != NULL)
    {
      success =  mUserFunction->setUserData(userData);
    }
    else if (mLambda != NULL)
    {
      success =  mLambda->setUserData(userData);
    }
    else if (mPiecewise != NULL)
    {
      success =  mPiecewise->setUserData(userData);
    }
    else if (mCSymbol != NULL)
    {
      success =  mCSymbol->setUserData(userData);
    }
    else if (mQualifier != NULL)
    {
      success =  mQualifier->setUserData(userData);
    }
    else if (mSemantics != NULL)
    {
      success =  mSemantics->setUserData(userData);
    }
    else if (mIsOther == true)
    {
      if (mPackageName.empty() == false && mPackageName != "core")
      {
        success = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                       ->setUserData(userData);
      }
      else
      {
        unsigned int i = 0;
        bool found = false;
        while (found == false && i < getNumPlugins())
        {
          if (getPlugin(i)->isSetMath() == true)
          {
            success = const_cast<ASTBase*>(getPlugin(i)->getMath())
                                           ->setUserData(userData);
            found = true;
          }
          i++;
        }

        // nothing happened
        if (found == false)
        {
          success = LIBSBML_INVALID_OBJECT;
        }
      }
    }
    else
    {
      success = LIBSBML_INVALID_OBJECT;
    }
  }

  return success;
}


SBase* 
ASTFunction::getParentSBMLObject() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getParentSBMLObject();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getParentSBMLObject();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getParentSBMLObject();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getParentSBMLObject();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getParentSBMLObject();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getParentSBMLObject();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getParentSBMLObject();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getParentSBMLObject();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getParentSBMLObject();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getParentSBMLObject();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getParentSBMLObject();
        }
        i++;
      }

      // nothing happened
      return ASTBase::getParentSBMLObject();
    }
  }
  else
  {
    return ASTBase::getParentSBMLObject();
  }
}


void* 
ASTFunction::getUserData() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getUserData();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getUserData();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getUserData();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getUserData();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getUserData();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getUserData();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getUserData();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getUserData();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getUserData();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getUserData();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getUserData();
        }
        i++;
      }

      // nothing happened
      return ASTBase::getParentSBMLObject();
    }
  }
  else
  {
    return ASTBase::getUserData();
  }
}


unsigned int 
ASTFunction::getNumBvars() const
{
  if (mLambda != NULL)
  {
    return mLambda->getNumBvars();
  }
  else
  {
    return 0;
  }
}



const std::string& 
ASTFunction::getName() const
{
  static std::string emptyString = "";
  if (mUserFunction != NULL)
  {
    return mUserFunction->getName();
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
ASTFunction::isSetName() const
{
  if (mUserFunction != NULL)
  {
    return mUserFunction->isSetName();
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
ASTFunction::setName(const std::string& name)
{
  int type = getExtendedType();
  if (mUserFunction != NULL)
  {
    return mUserFunction->setName(name);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setName(name);
  }
  else if (type == AST_UNKNOWN)
  {
    // we have a function that was created without a type
    // we are setting a name
    reset();
    mUserFunction = new ASTCiFunctionNode();
    mIsOther = false;
    setType(AST_NAME);
    mUserFunction->ASTBase::syncMembersFrom(this);
    return mUserFunction->setName(name);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTFunction::setNameAndChangeType(const std::string& name)
{
  int type = getExtendedType();
  if (mUserFunction != NULL)
  {
    return mUserFunction->setName(name);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setName(name);
  }
  else if (type == AST_UNKNOWN || type == AST_PLUS || type == AST_MINUS
    || type == AST_TIMES || type == AST_DIVIDE || type == AST_POWER)
  {
    // we have a function that was created without a type
    // or as an operator
    // we are setting a name
    reset();
    mUserFunction = new ASTCiFunctionNode();
    mIsOther = false;
    setType(AST_NAME);
    mUserFunction->ASTBase::syncMembersFrom(this);
    return mUserFunction->setName(name);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }

}


int 
ASTFunction::unsetName()
{
  if (mUserFunction != NULL)
  {
    return mUserFunction->unsetName();
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
ASTFunction::setDefinitionURL(const std::string& url)
{
  if (mUserFunction != NULL)
  {
    return mUserFunction->setDefinitionURL(url);
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->setDefinitionURL(url);
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->setDefinitionURL(url);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
const std::string& 
ASTFunction::getDefinitionURL() const
{
  static std::string emptyString = "";
  if (mUserFunction != NULL)
  {
    return mUserFunction->getDefinitionURL();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getDefinitionURL();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getDefinitionURL();
  }
  else
  {
    return emptyString;
  }
}


bool 
ASTFunction::isSetDefinitionURL() const
{
  if (mUserFunction != NULL)
  {
    return mUserFunction->isSetDefinitionURL();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isSetDefinitionURL();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isSetDefinitionURL();
  }
  else
  {
    return false;
  }
}


int 
ASTFunction::unsetDefinitionURL()
{
  if (mUserFunction != NULL)
  {
    return mUserFunction->unsetDefinitionURL();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->unsetDefinitionURL();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->unsetDefinitionURL();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
int 
ASTFunction::setEncoding(const std::string& url)
{
  if (mCSymbol != NULL)
  {
    return mCSymbol->setEncoding(url);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
const std::string& 
ASTFunction::getEncoding() const
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
ASTFunction::isSetEncoding() const
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


int 
ASTFunction::unsetEncoding()
{
  if (mCSymbol != NULL)
  {
    return mCSymbol->unsetEncoding();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  

  // functions for semantics
int 
ASTFunction::addSemanticsAnnotation (XMLNode* sAnnotation)
{
  if (mSemantics != NULL)
  {
    return mSemantics->addSemanticsAnnotation(sAnnotation);
  }
  else
  {
    // here we are a node that is not specifed as a semantics node
    ASTFunction *copyThis = new ASTFunction(*this);
    reset();
    mSemantics = new ASTSemanticsNode();
    mSemantics->ASTBase::syncMembersAndResetParentsFrom(copyThis);
    mSemantics->setType(AST_SEMANTICS);
    this->ASTBase::syncMembersAndResetParentsFrom(mSemantics);

    if (mSemantics->addChild(copyThis) == LIBSBML_OPERATION_SUCCESS)
    {
      mSemantics->addSemanticsAnnotation(sAnnotation);
      return LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      return LIBSBML_OPERATION_FAILED;
    }
  }
}

unsigned int 
ASTFunction::getNumSemanticsAnnotations () const
{
  if (mSemantics != NULL)
  {
    return mSemantics->getNumSemanticsAnnotations();
  }
  else
  {
    return 0;
  }
}


XMLNode* 
ASTFunction::getSemanticsAnnotation (unsigned int n) const
{
  if (mSemantics != NULL)
  {
    return mSemantics->getSemanticsAnnotation(n);
  }
  else
  {
    return NULL;
  }
}


bool 
ASTFunction::isAvogadro() const
{
  return false;
}


bool 
ASTFunction::isBoolean() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->ASTBase::isBoolean();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->ASTBase::isBoolean();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->ASTBase::isBoolean();
  }

  return valid;
}


bool 
ASTFunction::isConstant() const
{
  return false;
}


bool 
ASTFunction::isFunction() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->ASTBase::isFunction();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->ASTBase::isFunction();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->ASTBase::isFunction();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->ASTBase::isFunction();
  }
  else if (mLambda != NULL)
  {
    return mLambda->ASTBase::isFunction();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->ASTBase::isFunction();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->ASTBase::isFunction();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->ASTBase::isFunction();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->ASTBase::isFunction();
  }
  else
  {
    return ASTBase::isFunction();
  }
}


bool 
ASTFunction::isInfinity() const
{
  return false;
}


bool 
ASTFunction::isInteger() const
{
  return false;
}


bool 
ASTFunction::isLambda() const
{
  bool valid = false;
  
  if (mLambda != NULL)
  {
    valid = mLambda->ASTBase::isLambda();
  }

  return valid;
}


bool 
ASTFunction::isLog10() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->isLog10();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->isLog10();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->isLog10();
  }


  return valid;
}


bool 
ASTFunction::isLogical() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->ASTBase::isLogical();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->ASTBase::isLogical();
  }

  return valid;
}


bool 
ASTFunction::isName() const
{
  return false;
}


bool 
ASTFunction::isNaN() const
{
  return false;
}


bool 
ASTFunction::isNegInfinity() const
{
  return false;
}


bool 
ASTFunction::isNumber() const
{
  return false;
}


bool 
ASTFunction::isOperator() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->ASTBase::isOperator();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->ASTBase::isOperator();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->ASTBase::isOperator();
  }

  return valid;
}


bool 
ASTFunction::isPiecewise() const
{
  bool valid = false;
  
  if (mPiecewise != NULL)
  {
    valid = mPiecewise->ASTBase::isPiecewise();
  }

  return valid;
}


bool 
ASTFunction::isQualifier() const
{
  bool valid = false;
  
  if (mQualifier != NULL)
  {
    valid = mQualifier->ASTBase::isQualifier();
  }

  return valid;
}


bool 
ASTFunction::isRational() const
{
  return false;
}


bool 
ASTFunction::isReal() const
{
  return false;
}


bool 
ASTFunction::isRelational() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->ASTBase::isRelational();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->ASTBase::isRelational();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->ASTBase::isRelational();
  }

  return valid;
}


bool 
ASTFunction::isSemantics() const
{
  bool valid = false;
  
  if (mSemantics != NULL)
  {
    valid = mSemantics->ASTBase::isSemantics();
  }

  return valid;
}


bool 
ASTFunction::isSqrt() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->isSqrt();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->isSqrt();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->isSqrt();
  }

  return valid;
}


bool 
ASTFunction::isUMinus() const
{
  bool valid = false;
  
  if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->isUMinus();
  }

  return valid;
}


bool 
ASTFunction::isUnknown() const
{
  bool valid = false;
  
  if (mUnaryFunction != NULL)
  {
    valid = mUnaryFunction->ASTBase::isUnknown();
  }
  else if (mBinaryFunction != NULL)
  {
    valid = mBinaryFunction->ASTBase::isUnknown();
  }
  else if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->ASTBase::isUnknown();
  }
  else if (mIsOther == true)
  {
    valid = this->ASTBase::isUnknown();
  }

  return valid;
}


bool 
ASTFunction::isUPlus() const
{
  bool valid = false;
  
  if (mNaryFunction != NULL)
  {
    valid = mNaryFunction->isUPlus();
  }

  return valid;
}


bool 
ASTFunction::hasCnUnits() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->hasCnUnits();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->hasCnUnits();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->hasCnUnits();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->hasCnUnits();
  }
  else if (mLambda != NULL)
  {
    return mLambda->hasCnUnits();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->hasCnUnits();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->hasCnUnits();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->hasCnUnits();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->hasCnUnits();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->hasCnUnits();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->hasCnUnits();
        }
        i++;
      }
      
      return ASTBase::hasCnUnits();
    }
  }
  else
  {
    return ASTBase::hasCnUnits();
  }
}



const std::string& 
ASTFunction::getUnitsPrefix() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->getUnitsPrefix();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->getUnitsPrefix();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->getUnitsPrefix();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->getUnitsPrefix();
  }
  else if (mLambda != NULL)
  {
    return mLambda->getUnitsPrefix();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->getUnitsPrefix();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->getUnitsPrefix();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->getUnitsPrefix();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->getUnitsPrefix();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->getUnitsPrefix();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->getUnitsPrefix();
        }
        i++;
      }
      
      return ASTBase::getUnitsPrefix();
    }
  }
  else
  {
    return ASTBase::getUnitsPrefix();
  }
}



bool 
ASTFunction::isWellFormedNode() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->isWellFormedNode();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->isWellFormedNode();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->isWellFormedNode();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->isWellFormedNode();
  }
  else if (mLambda != NULL)
  {
    return mLambda->isWellFormedNode();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->isWellFormedNode();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->isWellFormedNode();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->isWellFormedNode();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->isWellFormedNode();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->isWellFormedNode();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->isWellFormedNode();
        }
        i++;
      }
      
      return ASTBase::isWellFormedNode();
    }
  }
  else
  {
    return ASTBase::isWellFormedNode();
  }
}


bool 
ASTFunction::hasCorrectNumberArguments() const
{
  if (mUnaryFunction != NULL)
  {
    return mUnaryFunction->hasCorrectNumberArguments();
  }
  else if (mBinaryFunction != NULL)
  {
    return mBinaryFunction->hasCorrectNumberArguments();
  }
  else if (mNaryFunction != NULL)
  {
    return mNaryFunction->hasCorrectNumberArguments();
  }
  else if (mUserFunction != NULL)
  {
    return mUserFunction->hasCorrectNumberArguments();
  }
  else if (mLambda != NULL)
  {
    return mLambda->hasCorrectNumberArguments();
  }
  else if (mPiecewise != NULL)
  {
    return mPiecewise->hasCorrectNumberArguments();
  }
  else if (mCSymbol != NULL)
  {
    return mCSymbol->hasCorrectNumberArguments();
  }
  else if (mQualifier != NULL)
  {
    return mQualifier->hasCorrectNumberArguments();
  }
  else if (mSemantics != NULL)
  {
    return mSemantics->hasCorrectNumberArguments();
  }
  else if (mIsOther == true)
  {
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      return const_cast<ASTBase*>(getPlugin(mPackageName)->getMath())
                                     ->hasCorrectNumberArguments();
    }
    else
    {
      unsigned int i = 0;
      while (i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          return const_cast<ASTBase*>(getPlugin(i)->getMath())
                                         ->hasCorrectNumberArguments();
        }
        i++;
      }
      
      return ASTBase::hasCorrectNumberArguments();
    }
  }
  else
  {
    return ASTBase::hasCorrectNumberArguments();
  }
}


ASTUnaryFunctionNode *
ASTFunction::getUnaryFunction() const
{
  return mUnaryFunction;
}


ASTBinaryFunctionNode *
ASTFunction::getBinaryFunction() const
{
  return mBinaryFunction;
}


ASTNaryFunctionNode *
ASTFunction::getNaryFunction() const
{
  return mNaryFunction;
}


ASTCiFunctionNode *
ASTFunction::getUserFunction() const
{
  return mUserFunction;
}


ASTLambdaFunctionNode *
ASTFunction::getLambda() const
{
  return mLambda;
}


ASTPiecewiseFunctionNode *
ASTFunction::getPiecewise() const
{
  return mPiecewise;
}


ASTCSymbol *
ASTFunction::getCSymbol() const
{
  return mCSymbol;
}


ASTQualifierNode *
ASTFunction::getQualifier() const
{
  return mQualifier;
}


ASTSemanticsNode *
ASTFunction::getSemantics() const
{
  return mSemantics;
}


void 
ASTFunction::write(XMLOutputStream& stream) const
{
  if (mUnaryFunction != NULL)
  {
    mUnaryFunction->write(stream);
  }
  else if (mBinaryFunction != NULL)
  {
    mBinaryFunction->write(stream);
  }
  else if (mNaryFunction != NULL)
  {
    mNaryFunction->write(stream);
  }
  else if (mUserFunction != NULL)
  {
    mUserFunction->write(stream);
  }
  else if (mLambda != NULL)
  {
    mLambda->write(stream);
  }
  else if (mPiecewise != NULL)
  {
    mPiecewise->write(stream);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->write(stream);
  }
  else if (mQualifier != NULL)
  {
    mQualifier->write(stream);
  }
  else if (mSemantics != NULL)
  {
    mSemantics->write(stream);
  }
  else if (mIsOther == true)
  {
    bool done = false;
    unsigned int i = 0;
    while (done == false && i < getNumPlugins())
    {
      if (getPlugin(i)->isSetMath() == true)
      {
        getPlugin(i)->getMath()->write(stream);
        done = true;
      }
      i++;
    }
  }
}

void 
ASTFunction::writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode) const
{
if (mNaryFunction != NULL)
  {
    mNaryFunction->writeNodeOfType(stream, type, inChildNode);
  }
}


bool 
ASTFunction::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  
  stream.skipText();
  
  const XMLToken currentElement = stream.next(); 
  const string&  currentName = currentElement.getName();

  ASTBase::checkPrefix(stream, reqd_prefix, currentElement);
  
  if (isTopLevelMathMLFunctionNodeTag(currentName) == false)
  {
    //cout << "[DEBUG] Function::read\nBAD THINGS ARE HAPPENING\n\n";
    std::string message = "The element <" + currentName + "> cannot be "
      + "used in this context.";
    logError(stream, currentElement, BadMathMLNodeType, message);
    
    // we have a problem so need to abandon read
    return read;
  }

  // create appropriate sub class
  if (currentName == "apply")
  {
    read = readApply(stream, reqd_prefix, currentElement);
  }
  else if (currentName == "lambda")
  {
    read = readLambda(stream, reqd_prefix, currentElement);
  }
  else if (currentName == "piecewise")
  {
    read = readPiecewise(stream, reqd_prefix, currentElement);
  }
  else if (representsQualifierNode(getTypeFromName(currentName)) == true)
  {
    read = readQualifier(stream, reqd_prefix, currentElement);
  }
  else if (currentName == "semantics")
  {
    read = readSemantics(stream, reqd_prefix, currentElement);
  }
  else
  {
    // we have a top level node that comes from a plugin
    unsigned int i = 0;
    while(read == false &&  i < getNumPlugins())
    {
      read = getPlugin(i)->read(stream, reqd_prefix, currentElement);
      if (read == true)
      {
        reset();
        setType(getPlugin(i)->getMath()->getExtendedType());
        this->setPackageName(getPlugin(i)->getPackageName());
        //this->ASTBase::syncMembersAndResetParentsFrom((ASTBase*)
        //                                           (getPlugin(i)->getMath()));
        mIsOther = true;
      }
      i++;
    }
  }

  if (read == true)
  {
    stream.skipPastEnd(currentElement);
  }
  
  return read;
}


bool 
ASTFunction::readApply(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;
  
  // this will not actually store the attributes for an apply element
  // but will log any unexpected attributes
  ExpectedAttributes expectedAttributes;
  addExpectedAttributes(expectedAttributes, stream);
  ASTBase::readAttributes(currentElement.getAttributes(), expectedAttributes,
                          stream, currentElement);

  /* allow a <apply/> element */
  if (currentElement.isStart() && currentElement.isEnd())
  {
    return true;
  }
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  const string&  nextName = nextElement.getName();
  
  int type = ASTBase::getTypeFromName(nextName);
  unsigned int numPlugins = ASTBase::getNumPlugins();
  
  unsigned int i = 0;
  bool done = false;

  unsigned int numChildren = 0;

  if (nextName == "ci")
  {
    read = readCiFunction(stream, reqd_prefix, currentElement);
    done = true;
  }
  else if (nextName == "csymbol")
  {
    read = readCSymbol(stream, reqd_prefix, currentElement);
    done = true;
  }
  else
  {
    numChildren = determineNumChildren(stream);
  }

  if (done == false && isTopLevelMathMLNumberNodeTag(nextName) == true)
  {
    std::string message = "<" + nextName + "> cannot be used directly " +
      "following an <apply> tag.";

    logError(stream, nextElement, BadMathML, message);
    done = true;
  }

  if (done == false)
  {
    done = readFunctionNode(stream, reqd_prefix, nextElement, 
                            read, type, numChildren);
  }

  // if we are not done look at plugins for function name
  // but only if we are allowed to read from that plugin
  if (stream.getSBMLNamespaces()->getLevel() > 2)
  {
    while (done == false && i < numPlugins)
    {
      ASTBasePlugin* plugin = static_cast<ASTBasePlugin*>(getPlugin(i)); 
      
      // are we allowed to use the plugin
      // ie is the ns declared
      if (stream.getSBMLNamespaces()->getNamespaces()
                                    ->containsUri(plugin->getURI()))
      {
        done = readFunctionNode(stream, reqd_prefix, nextElement, read, type, 
                                numChildren, plugin);
      }
      i++;
    }
  }
  
  if (done == false)
  {
    std::string message = "The element <" + nextName + "> is not a " +
      "permitted MathML element.";
    logError(stream, nextElement, DisallowedMathMLSymbol, message);    
  }
  
  return read;
}


bool
ASTFunction::readFunctionNode(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& nextElement, bool& read,
                  int type, unsigned int numChildren, ASTBasePlugin* plugin)
{
  bool done = false;
  
  if (representsUnaryFunction(type, plugin) == true)  
  {
    reset();
    mUnaryFunction = new ASTUnaryFunctionNode();
    mUnaryFunction->setExpectedNumChildren(numChildren);
    read = mUnaryFunction->read(stream, reqd_prefix);
    if (read == true && mUnaryFunction != NULL)
    {
      // if the type came from a plugin set the packagename
      if (type > AST_UNKNOWN)
      {
        mUnaryFunction->setPackageName(plugin->getPackageName());
      }
      this->ASTBase::syncMembersAndResetParentsFrom(mUnaryFunction);
      done = true;
    }
    else if (read == false)
    {
      stream.skipPastEnd(nextElement);   
      done = true;
    }
  }
  else if (representsBinaryFunction(type, plugin) == true)
  {
    reset();
    mBinaryFunction = new ASTBinaryFunctionNode();
    mBinaryFunction->setExpectedNumChildren(numChildren);
    read = mBinaryFunction->read(stream, reqd_prefix);
    if (read == true && mBinaryFunction != NULL)
    {
      // if the type came from a plugin set the packagename
      if (type > AST_UNKNOWN)
      {
        mBinaryFunction->setPackageName(plugin->getPackageName());
      }
      this->ASTBase::syncMembersAndResetParentsFrom(mBinaryFunction);
      done = true;
    }
    else if (read == false)
    {
      stream.skipPastEnd(nextElement);   
      done = true;
    }
  }
  else if (representsNaryFunction(type, plugin) == true)
  {
    reset();
    mNaryFunction = new ASTNaryFunctionNode();
    mNaryFunction->setExpectedNumChildren(numChildren);
    read = mNaryFunction->read(stream, reqd_prefix);
    if (read == true && mNaryFunction != NULL)
    {
      if (numChildren > 2 && (type == AST_TIMES || type == AST_PLUS))
      {
        /* HACK to replicate old behaviour */
        mNaryFunction->reduceOperatorsToBinary();
      }
        
      // if the type came from a plugin set the packagename
      if (type > AST_UNKNOWN)
      {
        mNaryFunction->setPackageName(plugin->getPackageName());
      }
      this->ASTBase::syncMembersAndResetParentsFrom(mNaryFunction);
      done = true;
    }
    else if (read == false)
    {
      stream.skipPastEnd(nextElement);   
      done = true;
    }
  }

  return done;
}

bool 
ASTFunction::readLambda(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  //const string&  nextName = nextElement.getName();
  
  unsigned int numChildren = 0, numBvars = 0;
  
  numChildren = determineNumChildren(stream, "lambda");
  numBvars = determineNumBvars(stream);
    
  reset();
  
  mLambda = new ASTLambdaFunctionNode();
  
  mLambda->setNumBvars(numBvars);
  mLambda->setExpectedNumChildren(numChildren);
  
  // read attributes on this element here since we have already consumed
  // the element
  ExpectedAttributes expectedAttributes;
  mLambda->addExpectedAttributes(expectedAttributes, stream);
  read = mLambda->ASTBase::readAttributes(currentElement.getAttributes(), 
                                expectedAttributes, stream, currentElement);
  if (read == false)
  {
    mLambda = NULL;
  }
  else
  {  
    read = mLambda->read(stream, reqd_prefix);
  }

  if (read == true && mLambda != NULL)
  {
    this->ASTBase::syncMembersAndResetParentsFrom(mLambda);
  }
  
  return read;
}


bool 
ASTFunction::readPiecewise(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  const string&  nextName = nextElement.getName();
  
  unsigned int numPiece = 0;
  bool otherwise = false;
    
  if (nextName == "piece")
  {
    numPiece = determineNumPiece(stream);
    otherwise = hasOtherwise(stream);
  }
  else if (nextName == "otherwise")
  {
    otherwise = true;
  }

  reset();

  mPiecewise = new ASTPiecewiseFunctionNode();
  
  mPiecewise->setNumPiece(numPiece);
  mPiecewise->setHasOtherwise(otherwise);
  
  // read attributes on this element here since we have already consumed
  // the element
  ExpectedAttributes expectedAttributes;
  mPiecewise->addExpectedAttributes(expectedAttributes, stream);
  read = mPiecewise->readAttributes(currentElement.getAttributes(), 
                               expectedAttributes, stream, currentElement);
  if (read == false)
  {
    mPiecewise = NULL;
  }
  else
  {  
    read = mPiecewise->read(stream, reqd_prefix);
  }

  if (read == true && mPiecewise != NULL)
  {
    this->ASTBase::syncMembersAndResetParentsFrom(mPiecewise);
  }

  return read;
}


bool 
ASTFunction::readQualifier(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;

  const string&  currentName = currentElement.getName();
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  //const string&  nextName = nextElement.getName();
  
  unsigned int numChildren;
  
  if (currentElement.isStart() == true && currentElement.isEnd() == true)
  {
    numChildren = 0;
  }
  else
  {
    numChildren = determineNumArgs(stream, currentName);
  }
    
  // this is a nasty one as we have already consumed currentName
  // so we need to set the type NOW
  reset();

  mQualifier = new ASTQualifierNode(getTypeFromName(currentName));
  
  mQualifier->setExpectedNumChildren(numChildren);
  
  // read attributes on this element here since we have already consumed
  // the element
  ExpectedAttributes expectedAttributes;
  mQualifier->addExpectedAttributes(expectedAttributes, stream);
  read = mQualifier->readAttributes(currentElement.getAttributes(),
                                expectedAttributes, stream, currentElement);
  
  if (read == false)
  {
    mQualifier = NULL;
  }
  else
  {
    if (numChildren > 0)
    {
      read = mQualifier->read(stream, reqd_prefix);

      /* HACK for replicating old behaviour */
      if (read == true)
      {
        if (mQualifier->ASTBase::representsBvar() == true)
        {
          for (unsigned int n = 0; n < numChildren; n++)
          {
            mQualifier->getChild(n)->ASTBase::setIsBvar(true);
          }
        }
      }

    }
  }
  
  if (read == true && mQualifier != NULL)
  {
    this->ASTBase::syncMembersAndResetParentsFrom(mQualifier);
  }

  return read;
}


bool 
ASTFunction::readCiFunction(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;

  stream.skipText();
  const XMLToken nextElement = stream.peek();
  //const string&  nextName = nextElement.getName();
  
  unsigned int numChildren;
    
  string funcName;
  string url = "";
  
  // BUT we might have a ci element that is enclosing the function name
  // this one is an anomaly as we need to read the function name first
  stream.skipText();
  
  const XMLToken element_ci = stream.next ();
  element_ci.getAttributes().readInto("definitionURL", url);
  
  ExpectedAttributes expectedAttributes;
  addExpectedAttributes(expectedAttributes, stream);
  expectedAttributes.add("definitionURL");
  ASTBase::readAttributes(element_ci.getAttributes(), expectedAttributes,
                          stream, element_ci);
  
  funcName = trim( stream.next().getCharacters() );
  
  numChildren = determineNumChildren(stream);
  
  stream.skipPastEnd(element_ci);

  reset();

  mUserFunction = new ASTCiFunctionNode();
  
  mUserFunction->setName(funcName);
  mUserFunction->setExpectedNumChildren(numChildren);
  
  read = mUserFunction->read(stream, reqd_prefix);

  if (read == true && mUserFunction != NULL)
  {
    if (url.empty() == false)
    {
      mUserFunction->setDefinitionURL(url);
    }
    this->setType(mUserFunction->getType());
    this->ASTBase::setIsChildFlag(mUserFunction->ASTBase::isChild());
    if (mNaryFunction != NULL)
    {
      delete mNaryFunction;
      mNaryFunction = NULL;
      mIsOther = false;
    }
    mUserFunction->ASTBase::syncMembersAndResetParentsFrom(this);
  }
  
  return read;
}


bool 
ASTFunction::readCSymbol(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  //const string&  nextName = nextElement.getName();
  
  unsigned int numChildren = determineNumChildren(stream);
    
  reset();

  mCSymbol = new ASTCSymbol();
  
  mCSymbol->setExpectedNumChildren(numChildren);

  /* HACK TO REPLICATE OLD AST */
  /* old code would create a node of type name or
   * a user function with the given name
   * if the url was not recognised
   * need to know we are reading an apply
   */
  mCSymbol->setInReadFromApply(true);
  
  read = mCSymbol->read(stream, reqd_prefix);
  
  mCSymbol->setInReadFromApply(false);

  if (read == true && mCSymbol != NULL)
  {
    if (mNaryFunction != NULL)
    {
      delete mNaryFunction;
      mNaryFunction = NULL;
      mIsOther = false;
    }
    this->ASTBase::syncMembersAndResetParentsFrom(mCSymbol);
  }
  else if (read == false)
  {
    stream.skipPastEnd(nextElement);
  }
  
  return read;
}


bool 
ASTFunction::readSemantics(XMLInputStream& stream, const std::string& reqd_prefix,
                        const XMLToken& currentElement)
{
  bool read = false;
  const string&  currentName = currentElement.getName();
  
  stream.skipText();
  const XMLToken nextElement = stream.peek();
  //const string&  nextName = nextElement.getName();
  
  unsigned int numChildren = 0;
  
  numChildren = determineNumAnnotations(stream);

  reset();

  // this is a nasty one as we have already consumed currentName
  // so we need to set the type NOW
  mSemantics = new ASTSemanticsNode(getTypeFromName(currentName));
  
  mSemantics->setNumAnnotations(numChildren);
  
  // read attributes on this element here since we have already consumed
  // the element
  ExpectedAttributes expectedAttributes;
  mSemantics->addExpectedAttributes(expectedAttributes, stream);
  read = mSemantics->readAttributes(currentElement.getAttributes(), 
                                expectedAttributes, stream, currentElement);
  if (read == false)
  {
    mSemantics = NULL;
  }
  else
  {  
    read = mSemantics->read(stream, reqd_prefix);
  }

  if (read == true && mSemantics != NULL)
  {
    if (mNaryFunction != NULL)
    {
      delete mNaryFunction;
      mNaryFunction = NULL;
      mIsOther = false;
    }
    this->ASTBase::syncMembersAndResetParentsFrom(mSemantics);
  }
  
  return read;
}


void
ASTFunction::syncMembersAndTypeFrom(ASTNumber* rhs, int type)
{
  if (mUnaryFunction != NULL)
  {
    mUnaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mUnaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mUnaryFunction);
  }
  else if (mBinaryFunction != NULL)
  {
    mBinaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mBinaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mBinaryFunction);
  }
  else if (mNaryFunction != NULL)
  {
    mNaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mNaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mNaryFunction);
  }
  else if (mUserFunction != NULL)
  {
    mUserFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mUserFunction->setType(type);
    if (rhs->isSetName() == true)
    {
      mUserFunction->setName(rhs->getName());
    }
    if (rhs->isSetDefinitionURL() == true)
    {
      mUserFunction->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mUserFunction);
  }
  else if (mLambda != NULL)
  {
    mLambda->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mLambda->setType(type);
    this->ASTBase::syncMembersFrom(mLambda);
  }
  else if (mPiecewise != NULL)
  {
    mPiecewise->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mPiecewise->setType(type);
    this->ASTBase::syncMembersFrom(mPiecewise);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->syncMembersAndTypeFrom(rhs, type);
    this->ASTBase::syncMembersFrom(mCSymbol);
  }
  else if (mQualifier != NULL)
  {
    mQualifier->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mQualifier->setType(type);
    this->ASTBase::syncMembersFrom(mQualifier);
  }
  else if (mSemantics != NULL)
  {
    mSemantics->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mSemantics->setType(type);
    if (rhs->isSetDefinitionURL() == true)
    {
      mSemantics->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mSemantics);
  }
  else if (mIsOther == true)
  {
  }
}



void
ASTFunction::syncMembersAndTypeFrom(ASTFunction* rhs, int type)
{
  bool copyChildren = true;
  if (mUnaryFunction != NULL)
  {
    mUnaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mUnaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mUnaryFunction);
  }
  else if (mBinaryFunction != NULL)
  {
    mBinaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mBinaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mBinaryFunction);
  }
  else if (mNaryFunction != NULL)
  {
    mNaryFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mNaryFunction->setType(type);
    this->ASTBase::syncMembersFrom(mNaryFunction);
  }
  else if (mUserFunction != NULL)
  {
    mUserFunction->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mUserFunction->setType(type);
    if (rhs->isSetName() == true)
    {
      mUserFunction->setName(rhs->getName());
    }
    if (rhs->isSetDefinitionURL() == true)
    {
      mUserFunction->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mUserFunction);
  }
  else if (mLambda != NULL)
  {
    mLambda->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mLambda->setType(type);
    // taking a punt that we are creating a lamda from a function
    // that we have parsed so set the numBvars
    mLambda->setNumBvars(rhs->getNumChildren() - 1);
    this->ASTBase::syncMembersFrom(mLambda);
  }
  else if (mPiecewise != NULL)
  {
    mPiecewise->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mPiecewise->setType(type);
    this->ASTBase::syncMembersFrom(mPiecewise);
  }
  else if (mCSymbol != NULL)
  {
    mCSymbol->syncMembersAndTypeFrom(rhs, type);
    this->ASTBase::syncMembersFrom(mCSymbol);
  }
  else if (mQualifier != NULL)
  {
    mQualifier->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mQualifier->setType(type);
    this->ASTBase::syncMembersFrom(mQualifier);
  }
  else if (mSemantics != NULL)
  {
    mSemantics->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mSemantics->setType(type);
    if (rhs->isSetDefinitionURL() == true)
    {
      mSemantics->setDefinitionURL(rhs->getDefinitionURL());
    }
    this->ASTBase::syncMembersFrom(mSemantics);
  }
  else if (mIsOther == true)
  {
    ASTBase * node = NULL;
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      node = getPlugin(mPackageName)->getMath()->deepCopy();
    }
    else
    {
      unsigned int i = 0;
      bool found = false;
      while (found == false && i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          node = getPlugin(i)->getMath()->deepCopy();
          found = true;
        }
        i++;
      }
    }

    if (node != NULL)
    {
      node->ASTBase::syncMembersAndResetParentsFrom(rhs);
      node->setType(type);
      this->ASTBase::syncMembersFrom(node);
      // note this will clone plugins and therefore any children they may have
      // so do not recopy the children
      if (rhs->getNumChildren() == this->getNumChildren())
      {
        copyChildren = false;
      }
      delete node;
    }
  }

  if (copyChildren == true)
  {
    for (unsigned int i = 0; i < rhs->getNumChildren(); i++)
    {
      this->addChild(rhs->getChild(i)->deepCopy());
    }
  }
}


void
ASTFunction::syncPackageMembersAndTypeFrom(ASTFunction* rhs, int type)
{
  bool copyChildren = true;
  if (mIsOther == true)
  {
    ASTBase * node = NULL;
    if (mPackageName.empty() == false && mPackageName != "core")
    {
      node = const_cast<ASTBase*>(getPlugin(mPackageName)->getMath());
    }
    else
    {
      unsigned int i = 0;
      bool found = false;
      while (found == false && i < getNumPlugins())
      {
        if (getPlugin(i)->isSetMath() == true)
        {
          node = const_cast<ASTBase*>(getPlugin(i)->getMath());
          found = true;
        }
        i++;
      }
    }

    if (node != NULL)
    {
      node->ASTBase::syncMembersOnlyFrom(rhs);
      this->ASTBase::syncMembersOnlyFrom(node);
      // note this will clone plugins and therefore any children they may have
      // so do not recopy the children
      if (rhs->getNumChildren() == this->getNumChildren())
      {
        copyChildren = false;
      }
    }
  }

  if (copyChildren == true)
  {
    for (unsigned int i = 0; i < rhs->getNumChildren(); i++)
    {
      this->addChild(rhs->getChild(i)->deepCopy());
    }
  }
}


void
ASTFunction::reset()
{
  if (mUnaryFunction != NULL)
  {
    delete mUnaryFunction;
    mUnaryFunction = NULL;
  }

  if (mBinaryFunction != NULL)
  {
    delete mBinaryFunction;
    mBinaryFunction = NULL;
  }

  if (mNaryFunction != NULL)
  {
    delete mNaryFunction;
    mNaryFunction = NULL;
  }

  if (mUserFunction != NULL)
  {
    delete mUserFunction;
    mUserFunction = NULL;
  }

  if (mLambda != NULL)
  {
    delete mLambda;
    mLambda = NULL;
  }

  if (mPiecewise != NULL)
  {
    delete mPiecewise;
    mPiecewise = NULL;
  }

  if (mCSymbol != NULL)
  {
    delete mCSymbol;
    mCSymbol = NULL;
  }

  if (mQualifier != NULL)
  {
    delete mQualifier;
    mQualifier = NULL;
  }

  if (mSemantics != NULL)
  {
    delete mSemantics;
    mSemantics = NULL;
  }

  mIsOther = false;
}


bool
ASTFunction::representsQualifierNode(int type)
{
  bool valid = false;
  
  unsigned int i = 0;

  while (valid == false && i <= ASTBase::getNumPlugins())
  {
    ASTBasePlugin* plugin = static_cast<ASTBasePlugin*>(getPlugin(i)); 
    
    if (representsQualifier(type, plugin) == true)  
    {
      valid = true;
    }
    i++;
  }

  return valid;
}
LIBSBML_CPP_NAMESPACE_END


/** @endcond */

