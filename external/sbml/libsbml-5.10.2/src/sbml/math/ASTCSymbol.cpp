/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbol.cpp
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

#include <sbml/math/ASTCSymbol.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/extension/ASTBasePlugin.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* URL_TIME  = "http://www.sbml.org/sbml/symbols/time";
static const char* URL_DELAY = "http://www.sbml.org/sbml/symbols/delay";
static const char* URL_AVOGADRO = "http://www.sbml.org/sbml/symbols/avogadro";


ASTCSymbol::ASTCSymbol (int type) :
   ASTBase     ( type )
  , mTime      ( NULL )
  , mDelay     ( NULL )
  , mAvogadro  ( NULL )
  , mIsOther   ( false )
  , mCalcNumChildren ( 0 )
  , mInReadFromApply ( false)
{
  switch (type)
  {
    case AST_NAME_TIME:
      mTime = new ASTCSymbolTimeNode(type);
      this->ASTBase::syncPluginsFrom(mTime);
      break;
    case AST_FUNCTION_DELAY:
      mDelay = new ASTCSymbolDelayNode(type);
      this->ASTBase::syncPluginsFrom(mDelay);
      break;
    case AST_NAME_AVOGADRO:
      mAvogadro = new ASTCSymbolAvogadroNode(type);
      this->ASTBase::syncPluginsFrom(mAvogadro);
      break;
    default:
      break;
  }
}
  

 
  /**
   * Copy constructor
   */
ASTCSymbol::ASTCSymbol (const ASTCSymbol& orig):
    ASTBase (orig)
  , mTime      ( NULL )
  , mDelay     ( NULL )
  , mAvogadro  ( NULL )
  , mIsOther        ( orig.mIsOther )
  , mCalcNumChildren ( orig.mCalcNumChildren )
  , mInReadFromApply ( orig.mInReadFromApply)
{
  if ( orig.mTime  != NULL)
  {
    mTime = static_cast<ASTCSymbolTimeNode*>
                                ( orig.mTime->deepCopy() );
  }

  if ( orig.mDelay  != NULL)
  {
    mDelay = static_cast<ASTCSymbolDelayNode*>
                                ( orig.mDelay->deepCopy() );
  }

  if ( orig.mAvogadro  != NULL)
  {
    mAvogadro = static_cast<ASTCSymbolAvogadroNode*>
                                ( orig.mAvogadro->deepCopy() );
  }
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCSymbol&
ASTCSymbol::operator=(const ASTCSymbol& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    mIsOther        = rhs.mIsOther;
    mCalcNumChildren = rhs.mCalcNumChildren;
    mInReadFromApply = rhs.mInReadFromApply;


    delete mTime;
    if ( rhs.mTime  != NULL)
    {
      mTime = static_cast<ASTCSymbolTimeNode*>
                                  ( rhs.mTime->deepCopy() );
    }
    else
    {
      mTime = NULL;
    }

    delete mDelay;
    if ( rhs.mDelay  != NULL)
    {
      mDelay = static_cast<ASTCSymbolDelayNode*>
                                  ( rhs.mDelay->deepCopy() );
    }
    else
    {
      mDelay = NULL;
    }

    delete mAvogadro;
    if ( rhs.mAvogadro  != NULL)
    {
      mAvogadro = static_cast<ASTCSymbolAvogadroNode*>
                                  ( rhs.mAvogadro->deepCopy() );
    }
    else
    {
      mAvogadro = NULL;
    }

  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCSymbol::~ASTCSymbol ()
{
  if (mTime  != NULL) delete mTime;
  if (mDelay  != NULL) delete mDelay;
  if (mAvogadro  != NULL) delete mAvogadro;
}

int
ASTCSymbol::getTypeCode () const
{
  return AST_TYPECODE_CSYMBOL;
}


  /**
   * Creates a copy (clone).
   */
ASTCSymbol*
ASTCSymbol::deepCopy () const
{
  return new ASTCSymbol(*this);
}

int 
ASTCSymbol::addChild(ASTBase * child)
{
  if (child == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mDelay != NULL)
  {
    return mDelay->addChild(child);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

int 
ASTCSymbol::swapChildren(ASTFunction * that)
{
  if (that == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mDelay != NULL)
  {
    return mDelay->swapChildren(that);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTCSymbol::insertChild(unsigned int n, ASTBase* newChild)
{
  if (newChild == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mDelay != NULL)
  {
    return mDelay->insertChild(n, newChild);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTCSymbol::prependChild(ASTBase * newChild)
{
  if (newChild == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mDelay != NULL)
  {
    return mDelay->prependChild(newChild);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTCSymbol::removeChild(unsigned int n)
{
  if (mDelay != NULL)
  {
    return mDelay->removeChild(n);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTCSymbol::replaceChild(unsigned int n, ASTBase* newChild)
{
  if (newChild == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (mDelay != NULL)
  {
    return mDelay->replaceChild(n, newChild);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


ASTBase* 
ASTCSymbol::getChild (unsigned int n) const
{
  if (mDelay != NULL)
  {
    return mDelay->getChild(n);
  }
  else
  {
    return NULL;
  }
}

unsigned int 
ASTCSymbol::getNumChildren() const
{
  if (mDelay != NULL)
  {
    return mDelay->getNumChildren();
  }
  else
  {
    return 0;
  }
}


void 
ASTCSymbol::setIsChildFlag(bool flag)
{
  ASTBase::setIsChildFlag(flag);

  if (mTime != NULL)
  {
    mTime->ASTBase::setIsChildFlag(flag);
  }
  else if (mDelay != NULL)
  {
    mDelay->ASTBase::setIsChildFlag(flag);
  }
  else if (mAvogadro != NULL)
  {
    mAvogadro->ASTBase::setIsChildFlag(flag);
  }
}


int 
ASTCSymbol::setClass(std::string className)
{
  int success = ASTBase::setClass(className);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::setClass(className);
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::setClass(className);
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::setClass(className);
    }
  }

  return success;
}


int 
ASTCSymbol::setId(std::string id)
{
  int success = ASTBase::setId(id);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::setId(id);
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::setId(id);
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::setId(id);
    }
  }

  return success;
}


int 
ASTCSymbol::setStyle(std::string style)
{
  int success = ASTBase::setStyle(style);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::setStyle(style);
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::setStyle(style);
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::setStyle(style);
    }
  }

  return success;
}


int 
ASTCSymbol::setParentSBMLObject(SBase* sb)
{
  int success = ASTBase::setParentSBMLObject(sb);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::setParentSBMLObject(sb);
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::setParentSBMLObject(sb);
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::setParentSBMLObject(sb);
    }
  }

  return success;
}


int 
ASTCSymbol::setUserData(void* userData)
{
  int success = ASTBase::setUserData(userData);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::setUserData(userData);
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::setUserData(userData);
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::setUserData(userData);
    }
  }

  return success;
}


int 
ASTCSymbol::unsetClass()
{
  int success = ASTBase::unsetClass();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::unsetClass();
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::unsetClass();
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::unsetClass();
    }
  }

  return success;
}


int 
ASTCSymbol::unsetId()
{
  int success = ASTBase::unsetId();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::unsetId();
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::unsetId();
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::unsetId();
    }
  }

  return success;
}


int 
ASTCSymbol::unsetStyle()
{
  int success = ASTBase::unsetStyle();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::unsetStyle();
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::unsetStyle();
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::unsetStyle();
    }
  }

  return success;
}


int 
ASTCSymbol::unsetParentSBMLObject()
{
  int success = ASTBase::unsetParentSBMLObject();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::unsetParentSBMLObject();
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::unsetParentSBMLObject();
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::unsetParentSBMLObject();
    }
  }

  return success;
}


int 
ASTCSymbol::unsetUserData()
{
  int success = ASTBase::unsetUserData();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mTime != NULL)
    {
      success =  mTime->ASTBase::unsetUserData();
    }
    else if (mDelay != NULL)
    {
      success =  mDelay->ASTBase::unsetUserData();
    }
    else if (mAvogadro != NULL)
    {
      success =  mAvogadro->ASTBase::unsetUserData();
    }
  }

  return success;
}


bool 
ASTCSymbol::isSetClass() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::isSetClass();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::isSetClass();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::isSetClass();
  }
  else
  {
    return ASTBase::isSetClass();
  }
}


bool 
ASTCSymbol::isSetId() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::isSetId();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::isSetId();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::isSetId();
  }
  else
  {
    return ASTBase::isSetId();
  }
}


bool 
ASTCSymbol::isSetStyle() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::isSetStyle();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::isSetStyle();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::isSetStyle();
  }
  else
  {
    return ASTBase::isSetStyle();
  }
}


bool 
ASTCSymbol::isSetParentSBMLObject() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::isSetParentSBMLObject();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::isSetParentSBMLObject();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::isSetParentSBMLObject();
  }
  else
  {
    return ASTBase::isSetParentSBMLObject();
  }
}


bool 
ASTCSymbol::isSetUserData() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::isSetUserData();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::isSetUserData();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::isSetUserData();
  }
  else
  {
    return ASTBase::isSetUserData();
  }
}


std::string 
ASTCSymbol::getClass() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::getClass();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::getClass();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::getClass();
  }
  else
  {
    return ASTBase::getClass();
  }
}


std::string 
ASTCSymbol::getId() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::getId();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::getId();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::getId();
  }
  else
  {
    return ASTBase::getId();
  }
}


std::string 
ASTCSymbol::getStyle() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::getStyle();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::getStyle();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::getStyle();
  }
  else
  {
    return ASTBase::getStyle();
  }
}


SBase* 
ASTCSymbol::getParentSBMLObject() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::getParentSBMLObject();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::getParentSBMLObject();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::getParentSBMLObject();
  }
  else
  {
    return ASTBase::getParentSBMLObject();
  }
}


void* 
ASTCSymbol::getUserData() const
{
  if (mTime != NULL)
  {
    return mTime->ASTBase::getUserData();
  }
  else if (mDelay != NULL)
  {
    return mDelay->ASTBase::getUserData();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->ASTBase::getUserData();
  }
  else
  {
    return ASTBase::getUserData();
  }
}


int 
ASTCSymbol::setValue(double value)
{
  // at present we will never get here - because 
  // the setValue function on an ASTNode changes the type to
  // AST_REAL
  
  // what should happen if you were working with the base classes
  int success = LIBSBML_INVALID_OBJECT;

  if (mAvogadro != NULL)
  {
    success = mAvogadro->setValue(value);
  }

  return success;
}

double
ASTCSymbol::getValue() const
{
  if (mAvogadro != NULL)
  {
    return mAvogadro->getValue();
  }
  else if (mIsOther == true)
  {
    //FIX ME
    //return getPlugin("qual")->getMath()->getValue();
    return util_NaN();
  }
  else
  {
    return 0;//util_NaN();
  }

}

const std::string& 
ASTCSymbol::getName() const
{
  static std::string emptyString = "";
  if (mTime != NULL)
  {
    return mTime->getName();
  }
  else if (mDelay != NULL)
  {
    return mDelay->getName();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->getName();
  }
  else
  {
    return emptyString;
  }
}

  
bool 
ASTCSymbol::isSetName() const
{
  if (mTime != NULL)
  {
    return mTime->isSetName();
  }
  else if (mDelay != NULL)
  {
    return mDelay->isSetName();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->isSetName();
  }
  else
  {
    return false;
  }
}

  
int 
ASTCSymbol::setName(const std::string& name)
{
  if (mTime != NULL)
  {
    return mTime->setName(name);
  }
  else if (mDelay != NULL)
  {
    return mDelay->setName(name);
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->setName(name);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int 
ASTCSymbol::unsetName()
{
  if (mTime != NULL)
  {
    return mTime->unsetName();
  }
  else if (mDelay != NULL)
  {
    return mDelay->unsetName();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->unsetName();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


bool
ASTCSymbol::isTime() const
{
  return (mTime != NULL);
}


bool
ASTCSymbol::isDelay() const
{
  return (mDelay != NULL);
}


bool
ASTCSymbol::isAvogadro() const
{
  bool isAvogadro = false;
  
  if (mAvogadro != NULL)
  {
    isAvogadro = mAvogadro->ASTBase::isAvogadro();
  }

  return isAvogadro;
}


int 
ASTCSymbol::setDefinitionURL(const std::string& url)
{
  if (mTime != NULL)
  {
    return mTime->setDefinitionURL(url);
  }
  else if (mDelay != NULL)
  {
    return mDelay->setDefinitionURL(url);
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->setDefinitionURL(url);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
int 
ASTCSymbol::setEncoding(const std::string& encoding)
{
  if (mTime != NULL)
  {
    return mTime->setEncoding(encoding);
  }
  else if (mDelay != NULL)
  {
    return mDelay->setEncoding(encoding);
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->setEncoding(encoding);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

  
const std::string& 
ASTCSymbol::getDefinitionURL() const
{
  static std::string emptyString = "";
  if (mTime != NULL)
  {
    return mTime->getDefinitionURL();
  }
  else if (mDelay != NULL)
  {
    return mDelay->getDefinitionURL();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->getDefinitionURL();
  }
  else
  {
    return emptyString;
  }
}


const std::string& 
ASTCSymbol::getEncoding() const
{
  static std::string emptyString = "";
  if (mTime != NULL)
  {
    return mTime->getEncoding();
  }
  else if (mDelay != NULL)
  {
    return mDelay->getEncoding();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->getEncoding();
  }
  else
  {
    return emptyString;
  }
}


bool
ASTCSymbol::isSetDefinitionURL() const
{
  bool success = false;
  if (mTime != NULL)
  {
    return mTime->isSetDefinitionURL();
  }
  else if (mDelay != NULL)
  {
    return mDelay->isSetDefinitionURL();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->isSetDefinitionURL();
  }
  else
  {
    return success;
  }
}


bool
ASTCSymbol::isSetEncoding() const
{
  bool success = false;
  if (mTime != NULL)
  {
    return mTime->isSetEncoding();
  }
  else if (mDelay != NULL)
  {
    return mDelay->isSetEncoding();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->isSetEncoding();
  }
  else
  {
    return success;
  }
}


int 
ASTCSymbol::unsetDefinitionURL()
{
  return LIBSBML_OPERATION_SUCCESS;
}


int
ASTCSymbol::unsetEncoding()
{
  return LIBSBML_OPERATION_SUCCESS;
}


bool 
ASTCSymbol::isWellFormedNode() const
{
  if (mTime != NULL)
  {
    return mTime->isWellFormedNode();
  }
  else if (mDelay != NULL)
  {
    return mDelay->isWellFormedNode();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->isWellFormedNode();
  }
  else
  {
    return ASTBase::isWellFormedNode();
  }
}


bool 
ASTCSymbol::hasCorrectNumberArguments() const
{
  if (mTime != NULL)
  {
    return mTime->hasCorrectNumberArguments();
  }
  else if (mDelay != NULL)
  {
    return mDelay->hasCorrectNumberArguments();
  }
  else if (mAvogadro != NULL)
  {
    return mAvogadro->hasCorrectNumberArguments();
  }
  else
  {
    return ASTBase::hasCorrectNumberArguments();
  }
}

bool
ASTCSymbol::hasCnUnits() const
{
  if (mDelay != NULL)
  {
    return mDelay->hasCnUnits();
  }
  else
  {
    return false;
  }
}



const std::string &
ASTCSymbol::getUnitsPrefix() const
{
  if (mDelay != NULL)
  {
    return mDelay->getUnitsPrefix();
  }
  else
  {
    return ASTBase::getUnitsPrefix();
  }
}

void 
ASTCSymbol::write(XMLOutputStream& stream) const
{
  if (mDelay != NULL)
  {
    mDelay->write(stream);
  }
  else if (mAvogadro != NULL)
  {
    mAvogadro->write(stream);
  }
  else if (mTime != NULL)
  {
    mTime->write(stream);
  }
  else if (mIsOther == true)
  {
    // FIX ME
    //getPlugin("qual")->getMath()->write(stream);
  }
}

bool 
ASTCSymbol::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek();
  const string&  name = element.getName();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  if (name != "csymbol" )
  {
#if 0
    cout << "[DEBUG} csymbol::read\nBAD THINGS ARE HAPPENING\n\n";
#endif
  }

  if (name == "csymbol")
  {
    std::string url;
    element.getAttributes().readInto("definitionURL", url);
    if (url == URL_DELAY)
    {
      mDelay = new ASTCSymbolDelayNode();
      mDelay->setExpectedNumChildren(getExpectedNumChildren());
      read = mDelay->read(stream, reqd_prefix);
      if (read == true && mDelay != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mDelay);
      }
    }
    else if (url == URL_AVOGADRO)
    {
      if (stream.getSBMLNamespaces() != NULL 
        && stream.getSBMLNamespaces()->getLevel() > 2)
      {
        mAvogadro = new ASTCSymbolAvogadroNode();
        read = mAvogadro->read(stream, reqd_prefix);
        if (read == true && mAvogadro != NULL)
        {
          this->ASTBase::syncMembersAndResetParentsFrom(mAvogadro);
        }
      }
      else
      {
        /* HACK TO REPLICATE OLD AST */
        /* old code would create a node of type name or
         * a user function with the given name
         * if the url was not recognised
         */
        if (mInReadFromApply == false)
        {
          mTime = new ASTCSymbolTimeNode();
          read = mTime->read(stream, reqd_prefix);
          if (read == true && mTime != NULL)
          {
            std::string name = mTime->getName();
            mTime->setType(AST_NAME);
            mTime->setName(name);
            this->ASTBase::syncMembersAndResetParentsFrom(mTime);
          }
        }
        else
        {
          mDelay = new ASTCSymbolDelayNode();
          mDelay->setExpectedNumChildren(getExpectedNumChildren());
          read = mDelay->read(stream, reqd_prefix);
          if (read == true && mDelay != NULL)
          {
            std::string name = mDelay->getName();
            mDelay->setType(AST_FUNCTION);
            mDelay->setName(name);
            this->ASTBase::syncMembersAndResetParentsFrom(mDelay);
          }
        }
        logError(stream, element, BadCsymbolDefinitionURLValue);      
      }
    }
    else if (url == URL_TIME)
    {
      mTime = new ASTCSymbolTimeNode();
      read = mTime->read(stream, reqd_prefix);
      if (read == true && mTime != NULL)
      {
        this->ASTBase::syncMembersAndResetParentsFrom(mTime);
      }
    }
    else
    {
      /* HACK TO REPLICATE OLD AST */
        /* old code would create a node of type name or
         * a user function with the given name
         * if the url was not recognised
         */
      if (mInReadFromApply == false)
      {
        mTime = new ASTCSymbolTimeNode();
        read = mTime->read(stream, reqd_prefix);
        if (read == true && mTime != NULL)
        {
          std::string name = mTime->getName();
          mTime->setType(AST_NAME);
          mTime->setName(name);
          this->ASTBase::syncMembersAndResetParentsFrom(mTime);
        }
      }
      else
      {
        mDelay = new ASTCSymbolDelayNode();
        mDelay->setExpectedNumChildren(getExpectedNumChildren());
        read = mDelay->read(stream, reqd_prefix);
        if (read == true && mDelay != NULL)
        {
          std::string name = mDelay->getName();
          mDelay->setType(AST_FUNCTION);
          mDelay->setName(name);
          this->ASTBase::syncMembersAndResetParentsFrom(mDelay);
        }
      }
      logError(stream, element, BadCsymbolDefinitionURLValue);      
    }
  }

  return read;
}

  
void 
ASTCSymbol::setExpectedNumChildren(unsigned int n) 
{
  mCalcNumChildren = n; 
}
  

unsigned int 
ASTCSymbol::getExpectedNumChildren() const 
{ 
  return mCalcNumChildren; 
}


ASTCSymbolTimeNode * 
ASTCSymbol::getTime() const
{ 
  return mTime; 
}
  

ASTCSymbolDelayNode * 
ASTCSymbol::getDelay() const
{ 
  return mDelay; 
}


ASTCSymbolAvogadroNode * 
ASTCSymbol::getAvogadro() const
{ 
  return mAvogadro; 
}


void
ASTCSymbol::syncMembersAndTypeFrom(ASTNumber* rhs, int type)
{
  // do not copy definitionURL as this is set
  // by appropriate class
  if (mTime != NULL)
  {
    mTime->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mTime->setType(type);
    if (rhs->isSetName() == true)
    {
      mTime->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mTime);
  }
  else if (mDelay != NULL)
  {
    mDelay->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mDelay->setType(type);
    if (rhs->isSetName() == true)
    {
      mDelay->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mDelay);
  }
  else if (mAvogadro != NULL)
  {
    mAvogadro->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mAvogadro->setType(type);
    if (rhs->isSetName() == true)
    {
      mAvogadro->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mAvogadro);
  }
  else if (mIsOther == true)
  {
  }
}



void
ASTCSymbol::syncMembersAndTypeFrom(ASTFunction* rhs, int type)
{
  // do not copy definitionURL as this is set
  // by appropriate class
  if (mTime != NULL)
  {
    mTime->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mTime->setType(type);
    if (rhs->isSetName() == true)
    {
      mTime->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mTime);
  }
  else if (mDelay != NULL)
  {
    mDelay->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mDelay->setType(type);
    if (rhs->isSetName() == true)
    {
      mDelay->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mDelay);
  }
  else if (mAvogadro != NULL)
  {
    mAvogadro->ASTBase::syncMembersAndResetParentsFrom(rhs);
    mAvogadro->setType(type);
    if (rhs->isSetName() == true)
    {
      mAvogadro->setName(rhs->getName());
    }
    this->ASTBase::syncMembersFrom(mAvogadro);
  }
  else if (mIsOther == true)
  {
  }
}


void
ASTCSymbol::setInReadFromApply(bool inReadFromApply)
{
  mInReadFromApply = inReadFromApply;
}




LIBSBML_CPP_NAMESPACE_END


/** @endcond */

