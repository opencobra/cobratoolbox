/**
 * @file    ASTNode.cpp
 * @brief   Base Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTNode.h>
#include <sbml/math/ASTCnIntegerNode.h>
#include <sbml/math/ASTPiecewiseFunctionNode.h>
#include <sbml/util/List.h>
#include <sbml/util/IdList.h>
#include <sbml/math/ASTTypes.h>
#include <sbml/SBase.h>
#include <sbml/Model.h>
#include <sbml/extension/ASTBasePlugin.h>

#include <limits.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN



/*
 * String Constants
 */
static const char *AST_LAMBDA_STRING = "lambda";

static const char *AST_CONSTANT_STRINGS[] =
{
  "exponentiale"
  , "false"
  , "pi"
  , "true"
};

static const char *AST_FUNCTION_STRINGS[] =
{
  "abs"
  , "arccos"
  , "arccosh"
  , "arccot"
  , "arccoth"
  , "arccsc"
  , "arccsch"
  , "arcsec"
  , "arcsech"
  , "arcsin"
  , "arcsinh"
  , "arctan"
  , "arctanh"
  , "ceiling"
  , "cos"
  , "cosh"
  , "cot"
  , "coth"
  , "csc"
  , "csch"
  , "delay"
  , "exp"
  , "factorial"
  , "floor"
  , "ln"
  , "log"
  , "piecewise"
  , "power"
  , "root"
  , "sec"
  , "sech"
  , "sin"
  , "sinh"
  , "tan"
  , "tanh"
};


static const char *AST_LOGICAL_STRINGS[] =
{
  "and"
  , "not"
  , "or"
  , "xor"
};


static const char *AST_RELATIONAL_STRINGS[] =
{
  "eq"
  , "geq"
  , "gt"
  , "leq"
  , "lt"
  , "neq"
};


static const char *AST_OPERATOR_STRINGS[] =
{
  "divide"
  , "minus"
  , "plus"
  , "times"
  , "power"
};

/*
 * Used by the Destructor to delete each item in mPlugins.
 */
struct DeleteASTPluginEntity : public unary_function<ASTBasePlugin*, void>
{
  void operator() (ASTBasePlugin* ast) { delete ast;}
};


#ifdef __cplusplus

ASTNode::ASTNode (ASTNodeType_t type) :
        ASTBase ((int)(type))
      , mNumber  ( NULL )
      , mFunction ( NULL )
      , mChar (0)
      , mHistoricalName ("")
{
  if (type == AST_UNKNOWN)
  {
    // user has not told us; need to assume something so lets go with 
    // a function
    mFunction = new ASTFunction ((int)(type));
    this->ASTBase::syncMembersFrom(mFunction);
  }
  else if (representsNumber((int)(type)) == true)
  {
    mNumber = new ASTNumber ((int)(type));
    this->ASTBase::syncPluginsFrom(mNumber);
  }
  else if (representsFunction((int)(type)) == true
    || representsQualifier((int)(type)) == true
    || type == AST_FUNCTION
    || type == AST_FUNCTION_PIECEWISE
    || type == AST_LAMBDA
    || type == AST_SEMANTICS)
  {
    mFunction = new ASTFunction ((int)(type));
    this->ASTBase::syncPluginsFrom(mFunction);
  }
  else
  {
    bool found = false;
    for (unsigned int i = 0; i < ASTBase::getNumPlugins(); i++)
    {
      if (found == false 
        && (representsFunction((int)(type), ASTBase::getPlugin(i)) == true
        || isTopLevelMathMLFunctionNodeTag(getNameFromType((int)(type))) == true))
      {
        mFunction = new ASTFunction ((int)(type));
        this->ASTBase::syncPluginsFrom(mFunction);
        found = true;
      }

    }
  }

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}
  

/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (SBMLNamespaces* sbmlns, ASTNodeType_t type) :
        ASTBase (sbmlns, (int)(type))
      , mNumber  ( NULL )
      , mFunction ( NULL )
      , mChar (0)
      , mHistoricalName ("")
{
  if (type == AST_UNKNOWN)
  {
    // user has not told us; need to assume something so lets go with 
    // a function
    mFunction = new ASTFunction ((int)(type));
  }
  else if (representsNumber((int)(type)) == true)
  {
    mNumber = new ASTNumber ((int)(type));
  }
  else if (representsFunction((int)(type)) == true
    || representsQualifier((int)(type)) == true
    || type == AST_FUNCTION
    || type == AST_FUNCTION_PIECEWISE
    || type == AST_LAMBDA
    || type == AST_SEMANTICS)
  {
    mFunction = new ASTFunction ((int)(type));
  }
  else
  {
    bool found = false;
    for (unsigned int i = 0; i < ASTBase::getNumPlugins(); i++)
    {
      if (found == false 
        && representsFunction((int)(type), ASTBase::getPlugin(i)) == true)
      {
        mFunction = new ASTFunction ((int)(type));
        found = true;
      }

    }
  }
}
/** @endcond */
  

/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (int type) :
        ASTBase (type)
      , mNumber  ( NULL )
      , mFunction ( NULL )
      , mChar (0)
      , mHistoricalName ("")
{
  if (type == AST_UNKNOWN)
  {
    // user has not told us; need to assume something so lets go with 
    // a function
    mFunction = new ASTFunction (type);
    this->ASTBase::syncMembersFrom(mFunction);
  }
  else if (representsNumber(type) == true)
  {
    mNumber = new ASTNumber (type);
    this->ASTBase::syncPluginsFrom(mNumber);
  }
  else if (representsFunction(type) == true
    || representsQualifier(type) == true
    || type == AST_FUNCTION
    || type == AST_FUNCTION_PIECEWISE
    || type == AST_LAMBDA
    || type == AST_SEMANTICS)
  {
    mFunction = new ASTFunction (type);
    this->ASTBase::syncPluginsFrom(mFunction);
  }
  else
  {
    bool found = false;
    for (unsigned int i = 0; i < ASTBase::getNumPlugins(); i++)
    {
      if (found == false 
        && (representsFunction(type, ASTBase::getPlugin(i)) == true
        || representsQualifier(type, ASTBase::getPlugin(i)) == true
        || isTopLevelMathMLFunctionNodeTag(getNameFromType(type)) == true))
      {
        mFunction = new ASTFunction (type);
        this->ASTBase::syncPluginsFrom(mFunction);
        found = true;
      }

    }
  }

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}
/** @endcond */  


/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (SBMLNamespaces* sbmlns, int type) :
        ASTBase (sbmlns, type)
      , mNumber  ( NULL )
      , mFunction ( NULL )
      , mChar (0)
      , mHistoricalName ("")
{
  if (type == AST_UNKNOWN)
  {
    // user has not told us; need to assume something so lets go with 
    // a function
    mFunction = new ASTFunction (type);
  }
  else if (representsNumber(type) == true)
  {
    mNumber = new ASTNumber (type);
  }
  else if (representsFunction(type) == true
    || representsQualifier(type) == true
    || type == AST_FUNCTION
    || type == AST_FUNCTION_PIECEWISE
    || type == AST_LAMBDA
    || type == AST_SEMANTICS)
  {
    mFunction = new ASTFunction (type);
  }
  else
  {
    bool found = false;
    for (unsigned int i = 0; i < ASTBase::getNumPlugins(); i++)
    {
      if (found == false 
        && representsFunction(type, ASTBase::getPlugin(i)) == true)
      {
        mFunction = new ASTFunction (type);
        found = true;
      }

    }
  }
}
/** @endcond */
  

/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (ASTNumber* number) :
ASTBase (number->getType())
      , mNumber  ( number )
      , mFunction ( NULL )
      , mChar (0)
      , mHistoricalName ("")
{
  this->syncMembersFrom(number);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (ASTFunction* function) :
ASTBase (function->getType())
      , mNumber  ( NULL )
      , mFunction ( function )
      , mChar (0)
      , mHistoricalName ("")
{
  this->syncMembersFrom(function);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
ASTNode::ASTNode (Token_t* token):
ASTBase()
{
  mNumber = NULL;
  mFunction = NULL;
  mChar = 0;
  mHistoricalName = "";

  if (token != NULL)
  {
    if (token->type == TT_NAME)
    {
      mFunction = new ASTFunction(AST_UNKNOWN);
      this->ASTBase::syncMembersFrom(mFunction);
      setName(token->value.name);
    }
    else if (token->type == TT_INTEGER)
    {
      mNumber = new ASTNumber(AST_INTEGER);
      this->ASTBase::syncMembersFrom(mNumber);
      setValue(token->value.integer);
    }
    else if (token->type == TT_REAL)
    {
      mNumber = new ASTNumber(AST_REAL);
      this->ASTBase::syncMembersFrom(mNumber);
      setValue(token->value.real);
    }
    else if (token->type == TT_REAL_E)
    {
      mNumber = new ASTNumber(AST_REAL_E);
      this->ASTBase::syncMembersFrom(mNumber);
      setValue(token->value.real, token->exponent);
    }
    else
    {
      mFunction = new ASTFunction();
      this->ASTBase::syncMembersFrom(mFunction);
      setCharacter(token->value.ch);
    }
  }

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}
/** @endcond */


/*
   * Copy constructor
   */
ASTNode::ASTNode (const ASTNode& orig) :
        ASTBase(orig)
      , mNumber  ( NULL )
      , mFunction ( NULL )
      , mChar (orig.mChar)
      , mHistoricalName (orig.mHistoricalName)
{
  if (orig.mNumber != NULL)
  {
    mNumber = new ASTNumber(orig.getExtendedType());
    mNumber->syncMembersAndTypeFrom(orig.mNumber, orig.getExtendedType());
    this->ASTBase::syncMembersAndResetParentsFrom(mNumber);     
  }
  else if (orig.mFunction != NULL)
  {
    mFunction = new ASTFunction(orig.getExtendedType());
    mFunction->syncMembersAndTypeFrom(orig.mFunction, orig.getExtendedType());
    this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
  }
  //if (orig.mNumber != NULL)
  //{
  //  mNumber = static_cast<ASTNumber*>( orig.mNumber->deepCopy() );
  //}

  //if (orig.mFunction != NULL)
  //{
  //  mFunction = static_cast<ASTFunction*>( orig.mFunction->deepCopy() );
  //}
}


/*
 * 
   * Assignment operator for ASTNode.
   */
ASTNode&
ASTNode::operator=(const ASTNode& rhs)
{
  if(&rhs!=this)
  {
    reset();
    mChar = rhs.mChar;
    mHistoricalName = rhs.mHistoricalName;

    if (rhs.mNumber != NULL)
    {
      mNumber = new ASTNumber(rhs.getExtendedType());
      mNumber->syncMembersAndTypeFrom(rhs.mNumber, rhs.getExtendedType());
      this->ASTBase::syncMembersAndResetParentsFrom(mNumber);     
    }
    else if (rhs.mFunction != NULL)
    {
      mFunction = new ASTFunction(rhs.getExtendedType());
      mFunction->syncMembersAndTypeFrom(rhs.mFunction, rhs.getExtendedType());
      this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    }
  }
  return *this;
}


/*
   * Destroys this ASTNode, including any child nodes.
   */
ASTNode::~ASTNode ()
{
  if (mFunction != NULL) delete mFunction;
  if (mNumber != NULL) delete mNumber;
  for_each( mPlugins.begin(), mPlugins.end(), DeleteASTPluginEntity() );

}


/** @cond doxygenLibsbmlInternal */
int
ASTNode::getTypeCode () const
{
  return AST_TYPECODE_ASTNODE;
}
/** @endcond */


/*
   * Creates a copy (clone).
   */
ASTNode*
ASTNode::deepCopy () const
{
  return new ASTNode(*this);
}

/*-------------------------------------
 * 
 * getter functions from old ASTNode API
 *
 *---------------------------------------
 */
  
char 
ASTNode::getCharacter() const
{
  if (mFunction != NULL)
  {
    int type = mFunction->getType();
    char c = mChar;
    switch (type)
    {
    case AST_PLUS:
       c = '+';
       break;
    case AST_MINUS:
       c = '-';
       break;
    case AST_TIMES:
       c = '*';
       break;
    case AST_DIVIDE:
       c = '/';
       break;
    case AST_POWER:
       c = '^';
       break;
    default:
      break;
    }

    return c;
  }
  else
  {
    return mChar;
  }
}
  

std::string 
ASTNode::getClass() const
{
  if (mNumber != NULL)
  {
    return mNumber->getClass();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getClass();
  }
  else
  {
    return ASTBase::getClass();
  }
}
  

XMLAttributes* 
ASTNode::getDefinitionURL() const
{
  XMLAttributes *att = NULL;

  std::string url;
  
  if (mNumber != NULL)
  {
    url = mNumber->getDefinitionURL();
  }
  else if (mFunction != NULL)
  {
    url = mFunction->getDefinitionURL();
  }
  
  if (url.empty() == false)
  {
    att = new XMLAttributes();
    att->add("definitionURL", url);
  }

  return att;
}


const std::string& 
ASTNode::getDefinitionURLString() const
{
  static std::string emptyString = "";
  
  if (mNumber != NULL)
  {
    return mNumber->getDefinitionURL();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getDefinitionURL();
  }
  else
  {
    return emptyString;
  }
}


long 
ASTNode::getDenominator () const
{
  if (mNumber != NULL)
  {
    return mNumber->getDenominator();
  }
  else
  {
    return 1;
  }
}


long 
ASTNode::getExponent () const
{
  if (mNumber != NULL)
  {
    return mNumber->getExponent();
  }
  else
  {
    return 0; 
  }
}


std::string 
ASTNode::getId() const
{
  if (mNumber != NULL)
  {
    return mNumber->getId();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getId();
  }
  else
  {
    return ASTBase::getId();
  }
}


long 
ASTNode::getInteger () const
{
  if (mNumber != NULL && mNumber->getType() == AST_INTEGER )
  {
    return mNumber->getInteger();
  }
  else if (mNumber != NULL && mNumber->getType() == AST_RATIONAL )
  {
    return mNumber->getNumerator();
  }
  else
  {
    return 0;
  }
}


double 
ASTNode::getMantissa () const
{
  if (mNumber != NULL && mNumber->getType() == AST_REAL_E)
  {
    return mNumber->getMantissa();
  }
  else if (mNumber != NULL && mNumber->getType() == AST_REAL)
  {
    return mNumber->getValue();
  }
  else if (mNumber != NULL && mNumber->getType() == AST_NAME_AVOGADRO)
  {
    return mNumber->getValue();
  }
  else
  {
    return 0;
  }
}


const char*
ASTNode::getName () const
{
  const char* result = "";

  if (mNumber != NULL)
  {
    result = mNumber->getName().c_str();
  }
  else if (mFunction != NULL)
  {
    result = mFunction->getName().c_str();
  }
  /*
   * If the node does not have a name and is not a user-defined function
   * (type == AST_FUNCTION), use the default name for the builtin node
   * types.
   */
  if (!strcmp(result, ""))
  {
    // we might have the case were people were allowed to store names
    // for builtin functions which would override the default name
    if (mHistoricalName.empty() == false)
    {
      result = mHistoricalName.c_str();
    }
    else
    {
      /* HACK TO REPLICATE OLD AST */
      /* did not expect some things like AST_PLUS etc to have a name
       * my code uses the getNameFromType to write the MathmL so these
       * do have names
       */
      if (getType() >= AST_NAME_TIME)
      {
        result = getNameFromType(getExtendedType());
      }
      else if (getType() == AST_NAME_AVOGADRO)
      {
        result = "avogadro";
      }
    }
  }

  if (!strcmp(result, ""))
    return NULL;
  else
    return result;
}


/** @cond doxygenLibsbmlInternal */
unsigned int 
ASTNode::getNumBvars() const
{
  if (mNumber != NULL)
  {
    return 0;
  }
  else if (mFunction != NULL)
  {
    return mFunction->getNumBvars();
  }
  else
  {
    return 0;
  }
}
/** @endcond */


long 
ASTNode::getNumerator () const
{
  if (mNumber != NULL && mNumber->getType() == AST_RATIONAL)
  {
    return mNumber->getNumerator();
  }
  else if (mNumber != NULL && mNumber->getType() == AST_INTEGER)
  {
    return mNumber->getInteger();
  }
  else
  {
    return 0;
  }
}

  
const char* 
ASTNode::getOperatorName () const
{
  switch(mType) 
  {
  case AST_DIVIDE:
    return AST_OPERATOR_STRINGS[0];
  case AST_MINUS:
    return AST_OPERATOR_STRINGS[1];
  case AST_PLUS:
    return AST_OPERATOR_STRINGS[2];
  case AST_TIMES:
    return AST_OPERATOR_STRINGS[3];
  case AST_POWER:
    return AST_OPERATOR_STRINGS[4];
  default:
    return NULL;
  }
}


SBase *
ASTNode::getParentSBMLObject() const
{
  if (mNumber != NULL)
  {
    return mNumber->getParentSBMLObject();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getParentSBMLObject();
  }
  else
  {
    return ASTBase::getParentSBMLObject();
  }
}


int
ASTNode::getPrecedence() const
{
  int precedence;

  if ( isUMinus() )
  {
    precedence = 5;
  }
  else
  {
    switch (mType)
    {
      case AST_PLUS:
      case AST_MINUS:
        precedence = 2;
        break;

      case AST_DIVIDE:
      case AST_TIMES:
        precedence = 3;
        break;

      case AST_POWER:
        precedence = 4;
        break;

      default:
        precedence = 6;
        break;
    }
  }

  return precedence;
}


double 
ASTNode::getReal () const
{
  /* HACK TO REPLICATE OLD AST */
  // hack since old ASTNode would reset the "real" value of an integer to 0
  if (mNumber != NULL && mNumber->getType() != AST_INTEGER)
  {
    return mNumber->getValue();
  }
  else
  {
    return 0;
  }
}


std::string 
ASTNode::getStyle() const
{
  if (mNumber != NULL)
  {
    return mNumber->getStyle();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getStyle();
  }
  else
  {
    return ASTBase::getStyle();
  }
}


ASTNodeType_t 
ASTNode::getType () const
{
  if (mNumber != NULL)
  {
    return mNumber->getType();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getType();
  }
  else
  {
    return ASTBase::getType();
  }
}


int 
ASTNode::getExtendedType () const
{
  if (mNumber != NULL)
  {
    return mNumber->getExtendedType();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getExtendedType();
  }
  else
  {
    return ASTBase::getExtendedType();
  }
}


/** @cond doxygenLibsbmlInternal */
const std::string&
ASTNode::getPackageName () const
{
  if (mNumber != NULL)
  {
    return mNumber->getPackageName();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getPackageName();
  }
  else
  {
    return ASTBase::getPackageName();
  }
}
/** @endcond */


std::string 
ASTNode::getUnits() const
{
  static std::string emptyString= "";
  if (mNumber != NULL)
  {
    return mNumber->getUnits();
  }
  else
  {
    return emptyString;
  }
}


/*-------------------------------------
 * 
 * setter functions from old ASTNode API
 *
 *---------------------------------------
 */
  

int 
ASTNode::setCharacter(char value)
{
  if (value == '+')
  {
    setType(AST_PLUS);
    mFunction->ASTBase::setType(AST_PLUS);
  }
  else if (value == '-')
  {
    setType(AST_MINUS);
    mFunction->ASTBase::setType(AST_MINUS);
  }
  else if (value == '*')
  {
    setType(AST_TIMES);
    mFunction->ASTBase::setType(AST_TIMES);
  }
  else if (value == '/')
  {
    setType(AST_DIVIDE);
    mFunction->ASTBase::setType(AST_DIVIDE);
  }
  else if (value == '^')
  {
    setType(AST_POWER);
    mFunction->ASTBase::setType(AST_POWER);
  }
  else
  {
    setType(AST_UNKNOWN);
  }

  mChar = value;
  return LIBSBML_OPERATION_SUCCESS;
}
  

int 
ASTNode::setClass(const std::string& className)
{
  int success = ASTBase::setClass(className);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->setClass(className);
    }
    else if (mFunction != NULL)
    {
      success = mFunction->setClass(className);
    }
  }

  return success;
}


int
ASTNode::setDefinitionURL(XMLAttributes url)
{
  int success = LIBSBML_INVALID_OBJECT;

  if (mNumber != NULL)
  {
    success = mNumber->setDefinitionURL(url.getValue(0));
  }
  else if (mFunction != NULL)
  {
    success = mFunction->setDefinitionURL(url.getValue(0));
  }

  return success;
}


int
ASTNode::setDefinitionURL(const std::string& url)
{
  int success = LIBSBML_INVALID_OBJECT;

  if (mNumber != NULL)
  {
    success = mNumber->setDefinitionURL(url);
  }
  else if (mFunction != NULL)
  {
    success = mFunction->setDefinitionURL(url);
  }

  return success;
}


int 
ASTNode::setId(const std::string& id)
{
  int success = ASTBase::setId(id);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->setId(id);
    }
    else if (mFunction != NULL)
    {
      success = mFunction->setId(id);
    }
  }

  return success;
}


int 
ASTNode::setName(const char * name)
{
  int success = LIBSBML_INVALID_OBJECT;
  std::string strName = "";
  if (name != NULL)
  {
    strName = string(name);
  }


  if (mNumber != NULL)
  {
    success = mNumber->setNameAndChangeType(strName);
    this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
  }
  else if (mFunction != NULL && getType() == AST_UNKNOWN) 
  {
    mNumber = new ASTNumber(AST_NAME);
    mNumber->syncMembersAndTypeFrom(mFunction, AST_NAME);
    
    delete mFunction;
    mFunction = NULL;
    
    success = mNumber->setName(strName);
    this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
  }
  else if (mFunction != NULL)
  {
    success = mFunction->setNameAndChangeType(strName);
    if (success == LIBSBML_INVALID_OBJECT)
    {
      // we have a situation were a function that does not expect to have 
      // a name (because it has one by default) wants one - 
      // so we store that on ASTNode
      // since it is not really part of the new ast class structure
      mHistoricalName = strName;
      success = LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      mHistoricalName.clear();
    }
    this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
  }

  return success;
}  


int
ASTNode::setParentSBMLObject(SBase* sb)
{
  if (mNumber != NULL)
  {
    return mNumber->setParentSBMLObject(sb);
  }
  else if (mFunction != NULL)
  {
    return mFunction->setParentSBMLObject(sb);
  }
  else
  {
    return ASTBase::setParentSBMLObject(sb);
  }
}


int 
ASTNode::setStyle(const std::string& style)
{
  int success = ASTBase::setStyle(style);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->setStyle(style);
    }
    else if (mFunction != NULL)
    {
      success = mFunction->setStyle(style);
    }
  }

  return success;
}


int 
ASTNode::setType (int type) 
{
  if (getExtendedType() == type)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;
  std::string name = "";

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
    name = mNumber->getName();
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
    name = mFunction->getName();
  }
  
  reset(); 

  if (representsNumber(type))
  {
    mNumber = new ASTNumber(type);
    if (copyNumber != NULL)
    {
      mNumber->syncMembersAndTypeFrom(copyNumber, type);
      this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
    }
    else if (copyFunction != NULL)
    {
      mNumber->syncMembersAndTypeFrom(copyFunction, type);
      this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
    }
  }
  else if (representsFunction(type) 
    || representsQualifier(type) 
    || type == AST_FUNCTION
    || type == AST_LAMBDA
    || type == AST_FUNCTION_DELAY
    || type == AST_FUNCTION_PIECEWISE
    || type == AST_SEMANTICS
    || type == AST_UNKNOWN)
  {
    mFunction = new ASTFunction(type);
    if (copyNumber != NULL)
    {
      mFunction->syncMembersAndTypeFrom(copyNumber, type);
      this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    }
    else if (copyFunction != NULL)
    {
      mFunction->syncMembersAndTypeFrom(copyFunction, type);
      this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    }

    // keep the name as it was possible to rename functions

    if (name.empty() == false)
    {
      mHistoricalName = name;
    }
    
    // keep a record of the character if the type is an operator
    switch (type)
    {
    case AST_PLUS:
      mChar = '+';
      mHistoricalName.clear();
      break;
    case AST_MINUS:
      mChar = '-';
      mHistoricalName.clear();
      break;
    case AST_TIMES:
      mChar = '*';
      mHistoricalName.clear();
      break;
    case AST_DIVIDE:
      mChar = '/';
      mHistoricalName.clear();
      break;
    case AST_POWER:
      mChar = '^';
      mHistoricalName.clear();
      break;
    default:
      break;
    }
  }
  else
  {
    bool found = false;
    for (unsigned int i = 0; i < ASTBase::getNumPlugins(); i++)
    {
      if (found == false)
      {
        const char * name = ASTBase::getPlugin(i)->getNameFromType(type);
        if (representsFunction(type, ASTBase::getPlugin(i)) == true)
        {
          mFunction = new ASTFunction (type);
          if (copyNumber != NULL)
          {
            mFunction->syncMembersAndTypeFrom(copyNumber, type);
            this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
          }
          else if (copyFunction != NULL)
          {
            mFunction->syncMembersAndTypeFrom(copyFunction, type);
            this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
          }
          found = true;
        }
        else if (ASTBase::getPlugin(i)
                          ->isTopLevelMathMLFunctionNodeTag(name) == true)
        {
          mFunction = new ASTFunction (type);
          if (copyNumber != NULL)
          {
            mFunction->syncMembersAndTypeFrom(copyNumber, type);
            this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
          }
          else if (copyFunction != NULL)
          {
            mFunction->syncPackageMembersAndTypeFrom(copyFunction, type);
            this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
          }
          found = true;
        }
      }

    }
  }

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return ASTBase::setType(type);
}


int 
ASTNode::setType (ASTNodeType_t type) 
{
  return this->setType((int)(type));
}

  
int 
ASTNode::setUnits(const std::string& units)
{
  if (mNumber != NULL)
  {
    return mNumber->setUnits(units);
  }
  else
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
}


int 
ASTNode::setValue(int value)
{
  int success = LIBSBML_INVALID_OBJECT;

  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
  }

  int type = AST_INTEGER;

  if (getType() != type)
  {
    reset();
    mNumber = new ASTNumber(type);
  }

  if (copyNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyNumber, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }
  else if (copyFunction != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyFunction, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }

  success = mNumber->setValue(value);

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return success;
}


int
ASTNode::setValue(long value)
{
  int success = LIBSBML_INVALID_OBJECT;
  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
  }

  int type = AST_INTEGER;

  if (getType() != type)
  {
    reset();
    mNumber = new ASTNumber(type);
  }

  if (copyNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyNumber, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }
  else if (copyFunction != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyFunction, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }

  success = mNumber->setValue(value);

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return success;
}

int
ASTNode::setValue(long numerator, long denominator)
{
  int success = LIBSBML_INVALID_OBJECT;
  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
  }

  int type = AST_RATIONAL;

  if (getType() != type)
  {
    reset();
    mNumber = new ASTNumber(type);
  }

  if (copyNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyNumber, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }
  else if (copyFunction != NULL && mNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyFunction, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }

  if (mNumber != NULL)
  success = mNumber->setValue(numerator, denominator);

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return success;
}

int
ASTNode::setValue(double value)
{
  int success = LIBSBML_INVALID_OBJECT;
  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
  }

  int type = AST_REAL;
  if (getType() == AST_REAL_E)
  {
    type = AST_REAL_E;
  }

  if (getType() != AST_REAL || getType() != AST_REAL_E)
  {
    reset();
    mNumber = new ASTNumber(type);
  }

  if (copyNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyNumber, type);
    this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
  }
  else if (copyFunction != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyFunction, AST_REAL);
    this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
  }

  success = mNumber->setValue(value);

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return success;
}

int
ASTNode::setValue(double mantissa, long exponent)
{
  int success = LIBSBML_INVALID_OBJECT;
  ASTNumber * copyNumber = NULL;
  ASTFunction * copyFunction = NULL;

  if (mNumber != NULL)
  {
    copyNumber = new ASTNumber(*(getNumber()));
  }
  else if (mFunction != NULL)
  {
    copyFunction = new ASTFunction(*(getFunction()));
  }
  
  int type = AST_REAL_E;

  if (getType() != type)
  {
    reset();
    mNumber = new ASTNumber(type);
  }

  if (copyNumber != NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyNumber, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }
  else if (copyFunction != NULL && mNumber!= NULL)
  {
    mNumber->syncMembersAndTypeFrom(copyFunction, type);
    this->ASTBase::syncMembersFrom(mNumber);
  }

  if (mNumber != NULL)
  success = mNumber->setValue(mantissa, exponent);

  if (copyNumber != NULL)
  {
    delete copyNumber;
  }

  if (copyFunction != NULL)
  {
    delete copyFunction;
  }

  return success;
}


/** @cond doxygenLibsbmlInternal */
void 
ASTNode::setIsChildFlag(bool flag)
{
  ASTBase::setIsChildFlag(flag);

  if (mNumber != NULL)
  {
    mNumber->setIsChildFlag(flag);
  }
  else if (mFunction != NULL)
  {
    mFunction->setIsChildFlag(flag);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
ASTNode::representsBvar() const
{
  return ASTBase::representsBvar();
}

  /* isSet functions */
  
bool 
ASTNode::isSetClass() const
{
  if (mNumber != NULL)
  {
    return mNumber->isSetClass();
  }
  else if (mFunction != NULL)
  {
    return mFunction->isSetClass();
  }
  else
  {
    return ASTBase::isSetClass();
  }
}
  

bool 
ASTNode::isSetId() const
{
  if (mNumber != NULL)
  {
    return mNumber->isSetId();
  }
  else if (mFunction != NULL)
  {
    return mFunction->isSetId();
  }
  else
  {
    return ASTBase::isSetId();
  }
}
  

bool 
ASTNode::isSetParentSBMLObject() const
{
  if (mNumber != NULL)
  {
    return mNumber->isSetParentSBMLObject();
  }
  else if (mFunction != NULL)
  {
    return mFunction->isSetParentSBMLObject();
  }
  else
  {
    return ASTBase::isSetParentSBMLObject();
  }
}
  

bool 
ASTNode::isSetStyle() const
{
  if (mNumber != NULL)
  {
    return mNumber->isSetStyle();
  }
  else if (mFunction != NULL)
  {
    return mFunction->isSetStyle();
  }
  else
  {
    return ASTBase::isSetStyle();
  }
}
  

bool 
ASTNode::isSetUnits() const
{
  bool success = false;

  if (mNumber != NULL)
  {
    success = mNumber->isSetUnits();
  }

  return success;
}
  

  /* unset functions */
int 
ASTNode::unsetClass()
{
  int success = ASTBase::unsetClass();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->unsetClass();
    }
    else if (mFunction != NULL)
    {
      success = mFunction->unsetClass();
    }
  }

  return success;
}
  

int 
ASTNode::unsetId()
{
  int success = ASTBase::unsetId();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->unsetId();
    }
    else if (mFunction != NULL)
    {
      success = mFunction->unsetId();
    }
  }

  return success;
}
  

int 
ASTNode::unsetParentSBMLObject()
{
  int success = ASTBase::unsetParentSBMLObject();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->unsetParentSBMLObject();
    }
    else if (mFunction != NULL)
    {
      success = mFunction->unsetParentSBMLObject();
    }
  }

  return success;
}
  

int 
ASTNode::unsetStyle()
{
  int success = ASTBase::unsetStyle();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->unsetStyle();
    }
    else if (mFunction != NULL)
    {
      success = mFunction->unsetStyle();
    }
  }

  return success;
}
  

int 
ASTNode::unsetUnits()
{
  if (mNumber != NULL)
  {
    return mNumber->unsetUnits();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


int
ASTNode::freeName()
{
  int success = LIBSBML_UNEXPECTED_ATTRIBUTE;
  
  if (mNumber != NULL)
  {
    if (mNumber->getName().empty() != true)
    {
      success = mNumber->setName("");
    }
  }
  else if (mFunction != NULL)
  {
    if (mFunction->getName().empty() != true)
    {
      success = mFunction->setName("");
    }
  }

  return success;
}


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::hasCnUnits() const
{
  bool hasCnUnits = false;

  if (mNumber != NULL)
  {
    hasCnUnits = mNumber->hasCnUnits();
  }
  else if (mFunction != NULL)
  {
    hasCnUnits = mFunction->hasCnUnits();
  }

  return hasCnUnits;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
const std::string&
ASTNode::getUnitsPrefix() const
{
  if (mNumber != NULL)
  {
    return mNumber->getUnitsPrefix();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getUnitsPrefix();
  }
  else
  {
    return ASTBase::getUnitsPrefix();
  }
}
/** @endcond */


// functions for semantics

int 
ASTNode::addSemanticsAnnotation (XMLNode* sAnnotation)
{
  int success = LIBSBML_OPERATION_FAILED;
  if (mFunction != NULL)
  {
    success = mFunction->addSemanticsAnnotation(sAnnotation);
    if (success == LIBSBML_OPERATION_SUCCESS)
    {
      this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    }
  }
  else if (mNumber != NULL)
  {
    ASTNode * copyThis = new ASTNode(*this);
    reset();
    mFunction = new ASTFunction(AST_SEMANTICS);
    mFunction->ASTBase::syncMembersFrom(copyThis);
    mFunction->setType(AST_SEMANTICS);
    this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    mFunction->addChild(copyThis);
    success = mFunction->addSemanticsAnnotation(sAnnotation);
  }
  return success;
}

unsigned int 
ASTNode::getNumSemanticsAnnotations () const
{
  if (mFunction != NULL)
  {
    return mFunction->getNumSemanticsAnnotations();
  }
  else
  {
    return 0;
  }
}


XMLNode* 
ASTNode::getSemanticsAnnotation (unsigned int n) const
{
  if (mFunction != NULL)
  {
    return mFunction->getSemanticsAnnotation(n);
  }
  else
  {
    return NULL;
  }
}


/* convenience functions */
bool 
ASTNode::isAvogadro() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isAvogadro();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isAvogadro();
  }

  return valid;
}


bool 
ASTNode::isBoolean() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isBoolean();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isBoolean();
  }

  return valid;
}


bool 
ASTNode::isConstant() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isConstant();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isConstant();
  }

  return valid;
}


bool 
ASTNode::isFunction() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isFunction();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isFunction();
  }

  return valid;
}


bool 
ASTNode::isInfinity() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isInfinity();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isInfinity();
  }

  return valid;
}


bool 
ASTNode::isInteger() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isInteger();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isInteger();
  }

  return valid;
}


bool 
ASTNode::isLambda() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isLambda();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isLambda();
  }

  return valid;
}


bool 
ASTNode::isLog10() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isLog10();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isLog10();
  }

  return valid;
}


bool 
ASTNode::isLogical() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isLogical();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isLogical();
  }

  return valid;
}


bool 
ASTNode::isName() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isName();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isName();
  }

  return valid;
}


bool 
ASTNode::isNaN() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isNaN();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isNaN();
  }

  return valid;
}


bool 
ASTNode::isNegInfinity() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isNegInfinity();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isNegInfinity();
  }

  return valid;
}


bool 
ASTNode::isNumber() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isNumber();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isNumber();
  }

  return valid;
}


bool 
ASTNode::isOperator() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isOperator();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isOperator();
  }

  return valid;
}


bool 
ASTNode::isPiecewise() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isPiecewise();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isPiecewise();
  }

  return valid;
}


bool 
ASTNode::isQualifier() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isQualifier();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isQualifier();
  }

  return valid;
}


bool 
ASTNode::isRational() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isRational();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isRational();
  }

  return valid;
}


bool 
ASTNode::isReal() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    // replicate old behaviour
    valid = (mNumber->isReal() ||
      mNumber->isRational() ||
      mNumber->isExponential());
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isReal();
  }

  return valid;
}


bool 
ASTNode::isRelational() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isRelational();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isRelational();
  }

  return valid;
}


bool 
ASTNode::isSemantics() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isSemantics();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isSemantics();
  }

  return valid;
}


bool 
ASTNode::isSqrt() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isSqrt();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isSqrt();
  }

  return valid;
}


bool 
ASTNode::isUMinus() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isUMinus();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isUMinus();
  }

  return valid;
}


bool 
ASTNode::isUnknown() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isUnknown();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isUnknown();
  }

  return valid;
}


bool 
ASTNode::isUPlus() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isUPlus();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isUPlus();
  }

  return valid;
}

bool
ASTNode::returnsBoolean (const Model* givenModel /*=NULL*/) const
{   

  if (isBoolean() == true)
  {
    return true;
  }

  const Model* model = givenModel;
  if (givenModel == NULL && getParentSBMLObject() != NULL)
  {
    model = getParentSBMLObject()->getModel();
  }

  if (getType() == AST_FUNCTION)
  {
    if (model == NULL)
    {
      return false;
    }
    else
    {
      const FunctionDefinition* fd = model->getFunctionDefinition( getName() );

      if (fd != NULL && fd->isSetMath())
      {
        return fd->getMath()->getRightChild()->returnsBoolean();
      }
      else
      {
        return false;
      }
    }
  }

  else if (getType() == AST_FUNCTION_PIECEWISE)
  {
    for (unsigned int c = 0; c < getNumChildren(); c += 2)
    {
      if ( getChild(c)->returnsBoolean() == false ) 
        return false;
    }

    return true;
  }

  // add explicit return value in case we overlooked something
  return false;
}




int
ASTNode::addChild(ASTNode* child)
{
  if (child == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }
  // since  ASTNode is not quite a proper node 
  // this function can work differently than expected

  if (mFunction != NULL)
  {
    // we know we are a function so add a child
    return mFunction->addChild((child));
  }
  else if (mNumber != NULL)
  {
    //we know we are a number so should not really add a child
    return LIBSBML_INVALID_OBJECT;  
  }
  else
  {
    // should not get here but just in case
    return LIBSBML_INVALID_OBJECT;
  }
}

unsigned int 
ASTNode::getNumChildren() const
{
  if (mFunction != NULL)
  {
    return mFunction->getNumChildren();
  }
  else
    return 0;
}

ASTNode *
ASTNode::getChild(unsigned int n) const
{
  ASTNode* child = NULL;

  if (mFunction != NULL && mFunction->getNumChildren() > 0)
  {
    if (n >= mFunction->getNumChildren())
    {
      return child;
    }

    ASTBase * c1 = mFunction->getChild(n);

    if (c1 == NULL)
    {
      return child;
    }

    if (c1->isNumberNode() == true )
    {
      ASTNumber * num = dynamic_cast<ASTNumber*>(c1);
      if (static_cast<ASTNode*>(c1)->mNumber != NULL)
      {
        if (num != NULL)
        {
          child = new ASTNode(num);
          child->syncMembersAndResetParentsFrom(num);
      }
        else
        {
          child = static_cast<ASTNode*>(c1);
        }
      }
      else
      {
        child = new ASTNode(static_cast<ASTNumber*>(c1));
        child->syncMembersAndResetParentsFrom(c1);
      }
    }
    else 
    {
      ASTFunction * fun = dynamic_cast<ASTFunction*>(c1);
      if (static_cast<ASTNode*>(c1)->mFunction != NULL)
      {
        if (fun != NULL)
        {
          child = new ASTNode(fun);
          child->syncMembersAndResetParentsFrom(fun);
        }
        else
        {
          child = static_cast<ASTNode*>(c1);
        }
      }
      else
      {
        child = new ASTNode(static_cast<ASTFunction*>(c1));
        child->syncMembersAndResetParentsFrom(c1);
      }
    }
  
  }
  
  return child;
}


ASTNode*
ASTNode::getLeftChild() const
{
  return getChild(0);
}



ASTNode*
ASTNode::getRightChild() const
{
  unsigned int nc = getNumChildren();

  return (nc > 1) ? getChild(nc - 1) : NULL;
}


int
ASTNode::removeChild(unsigned int n)
{
  int removed = LIBSBML_INDEX_EXCEEDS_SIZE;
  
  if (mNumber != NULL)
  {
    removed = LIBSBML_INVALID_OBJECT;
  }
  else if (mFunction != NULL)
  {
    unsigned int size = mFunction->getNumChildren();
    if (n < size)
    {
      removed = mFunction->removeChild(n);
    }
  }

  return removed;
}


int
ASTNode::prependChild(ASTNode* child)
{
  int success = LIBSBML_INVALID_OBJECT;
  
  if (mNumber == NULL && mFunction != NULL)
  {
    success = mFunction->prependChild(child);
  }

  return success;
}


int
ASTNode::replaceChild(unsigned int n, ASTNode* newChild)
{
  int replaced = LIBSBML_INDEX_EXCEEDS_SIZE;
  
  if (mNumber != NULL)
  {
    replaced = LIBSBML_INVALID_OBJECT;
  }
  else if (mFunction != NULL)
  {
    unsigned int size = mFunction->getNumChildren();
    if (n < size)
    {
      replaced = mFunction->replaceChild(n, newChild);
    }
  }

  return replaced;
}


int
ASTNode::insertChild(unsigned int n, ASTNode* newChild)
{
  int inserted = LIBSBML_INDEX_EXCEEDS_SIZE;
  
  if (mNumber != NULL)
  {
    inserted = LIBSBML_INVALID_OBJECT;
  }
  else if (mFunction != NULL)
  {
    unsigned int size = mFunction->getNumChildren();
    if (n <= size)
    {
      inserted = mFunction->insertChild(n, newChild);
    }
  }

  return inserted;
}


int
ASTNode::swapChildren(ASTNode* that)
{
  int success = LIBSBML_INVALID_OBJECT;
  
  if (mNumber == NULL && mFunction != NULL)
  {
    if (that->mFunction != NULL)
    {
      success = mFunction->swapChildren(that->mFunction);
    }
  }

  return success;
}


/** @cond doxygenLibsbmlInternal */
void 
ASTNode::write(XMLOutputStream& stream) const
{
  if (ASTBase::isChild() == false)
  {
    static const string uri = "http://www.w3.org/1998/Math/MathML";

    stream.startElement("math");
    stream.writeAttribute("xmlns", uri);

    // need to know if we have units
    if (hasCnUnits() == true && stream.getSBMLNamespaces() != NULL
      && stream.getSBMLNamespaces()->getLevel() > 2)
    {
      string prefix = getUnitsPrefix();
      if (prefix.empty() == true)
      {
        prefix = "sbml";
      }
      stream.writeAttribute(prefix, "xmlns", stream.getSBMLNamespaces()->getURI());
    }

    for (unsigned int i = 0; i < getNumPlugins(); i++)
    {
      getPlugin(i)->writeXMLNS(stream);
    }
  }

  //if (getSemanticsFlag() == true)
  //{
  //  stream.startElement("semantics");
  //}
  if (mNumber != NULL)
  {
    mNumber->write(stream);
  }

  if (mFunction != NULL)
  {
    mFunction->write(stream);
  }

  //if (getSemanticsFlag() == true)
  //{
  //  for (unsigned int n = 0; n < getNumSemanticsAnnotations(); n++)
  //  {
  //    stream << *(getSemanticsAnnotation(n));
  //  }
  //  stream.endElement("semantics");
  //}

  if (ASTBase::isChild() == false)
  {
    stream.endElement("math");
  }

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
void 
ASTNode::writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode) const
{
if (mFunction != NULL)
  {
    mFunction->writeNodeOfType(stream, type, inChildNode);
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek();
  const string&  name = element.getName();
  if (name == "math")
  {
    ASTBase::checkPrefix(stream, reqd_prefix, element);

    const XMLToken elem = stream.next();
      
    if (elem.isStart() && elem.isEnd()) 
    {
      read = true;
      return read;
    }

    stream.skipText();
    read = ASTNode::read(stream, reqd_prefix);
  }
  else if (isTopLevelMathMLNumberNodeTag(name) == true)
  {
    mNumber = new ASTNumber();
    read = mNumber->read(stream, reqd_prefix);
    if (read == true && mNumber != NULL)
    {
      if (mFunction != NULL)
      {
        delete mFunction;
        mFunction = NULL;
      }
      this->ASTBase::syncMembersAndResetParentsFrom(mNumber);
    }
  }
  else if (isTopLevelMathMLFunctionNodeTag(name) == true)
  {
    if (mFunction != NULL)
    {
      delete mFunction;
      mFunction = NULL;
    }
    mFunction = new ASTFunction();
    read = mFunction->read(stream, reqd_prefix);
    if (read == true && mFunction != NULL)
    {
      if (mNumber != NULL)
      {
        delete mNumber;
        mNumber = NULL;
      }
      this->ASTBase::syncMembersAndResetParentsFrom(mFunction);
    }
    else if (read == false)
    {
      delete mFunction;
      mFunction = new ASTFunction();
      stream.skipPastEnd(element);
      read = true;
    }

  }
  else if (representsFunction(getTypeFromName(name)) == true)
  {
    std::string message = "Missing <apply> tag.";
    logError(stream, element, BadMathMLNodeType, message);   
  }
  else
  {
    std::string message = "The element <" + name + "> is not a " +
      "permitted MathML element.";
    logError(stream, element, DisallowedMathMLSymbol, message);   
  }

  if (read == false)
  {
    stream.skipPastEnd(element);
  }

  return read;
}
/** @endcond */


List* 
ASTNode::getListOfNodes (ASTNodePredicate predicate) const
{
  if (predicate == NULL) return NULL;

  List* lst = new List;

  fillListOfNodes(predicate, lst);

  return lst;
}


void
ASTNode::fillListOfNodes(ASTNodePredicate predicate, List* lst) const
{
  if (lst == NULL || predicate == NULL) return;

  ASTNode*     child;
  unsigned int c;
  unsigned int numChildren = getNumChildren();

  if (predicate(this) != 0)
  {
    lst->add( const_cast<ASTNode*>(this) );
  }

  for (c = 0; c < numChildren; c++)
  {
    child = getChild(c);
    child->fillListOfNodes(predicate, lst);
  }
}


void 
ASTNode::replaceArgument(const std::string& bvar, ASTNode *arg)
{
  if (arg == NULL)
  {
    return;
  }
  else if (getNumChildren() == 0)
  {
    if (this->isName() && this->getName() == bvar)
    {
      if (arg->isName())
      {
        this->setType(arg->getType());
        this->setName(arg->getName());
      }
      else if (arg->isReal())
      {
        this->setValue(arg->getReal());
      }
      else if (arg->isInteger())
      {
        this->setValue(arg->getInteger());
      }
      else if (arg->isConstant())
      {
        this->setType(arg->getType());
      }
      else
      {
        this->setType(arg->getType());
        this->setName(arg->getName());
        for (unsigned int c = 0; c < arg->getNumChildren(); c++)
        {
          this->addChild(arg->getChild(c)->deepCopy());
        }
      }
    }
  }
  for (unsigned int i = 0; i < getNumChildren(); i++)
  {

    ASTNode * child = getChild(i);
    if (child->isName())
    {
      if (child->getName() == bvar)
      {
        if (arg->isName())
        {
          child->setType(arg->getType());
          child->setName(arg->getName());
        }
        else if (arg->isReal())
        {
          child->setValue(arg->getReal());
        }
        else if (arg->isInteger())
        {
          child->setValue(arg->getInteger());
        }
        else if (arg->isConstant())
        {
          child->setType(arg->getType());
        }
        else
        {
          ASTNode * newChild = new ASTNode(arg->getType());
          if (newChild->getFunction() != NULL)
          {
            newChild->getFunction()->
              syncMembersAndTypeFrom(arg->getFunction(), arg->getType());
          }

          this->replaceChild(i, newChild->deepCopy());

          delete newChild;
        }
      }
    }
    else
    {
      child->replaceArgument(bvar, arg);
    }
  }
}


bool 
ASTNode::hasUnits() const
{
  bool hasUnits = isSetUnits();

  unsigned int n = 0;
  while(!hasUnits && n < getNumChildren())
  {
    hasUnits = getChild(n)->hasUnits();
    n++;
  }

  return hasUnits;
}


int
ASTNode::hasTypeAndNumChildren(int type, unsigned int numchildren) const
{
  return (getType() == type && getNumChildren() == numchildren);
}


void 
ASTNode::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (getType() == AST_NAME ||
      getType() == AST_FUNCTION ||
      getType() == AST_UNKNOWN) 
  {
    if (getName() == oldid) 
    {
      setName(newid.c_str());
    }
  }

  for (unsigned int child=0; child<getNumChildren(); child++) 
  {
    getChild(child)->renameSIdRefs(oldid, newid);
  }
}


void 
ASTNode::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetUnits()) 
  {
    if (getUnits() == oldid) 
    {
      setUnits(newid);
    }
  }
  
  for (unsigned int child=0; child<getNumChildren(); child++) 
  {
    getChild(child)->renameUnitSIdRefs(oldid, newid);
  }
}


/** @cond doxygenLibsbmlInternal */
void 
ASTNode::replaceIDWithFunction(const std::string& id, const ASTNode* function)
{
  for (unsigned int i=0; i<getNumChildren(); i++) 
  {
    ASTNode* child = getChild(i);
    if (child->getType() == AST_NAME &&
        child->getName() == id) 
    {
      replaceChild(i, function->deepCopy());
    }
    else 
    {
      child->replaceIDWithFunction(id, function);
    }
  }
}
/** @endcond */


void
ASTNode::reduceToBinary()
{
  unsigned int numChildren = getNumChildren();
  /* number of children should be greater than 2 */
  if (numChildren < 3)
    return;

  ASTNode* op = new ASTNode( getExtendedType() );
  ASTNode* op2 = new ASTNode( getExtendedType() );

  // add the first two children to the first node
  op->addChild(getChild(0));
  op->addChild(getChild(1));

  op2->addChild(op);

  for (unsigned int n = 2; n < numChildren; n++)
  {
    op2->addChild(getChild(n));
  }

  swapChildren(op2);

  reduceToBinary();
}


bool 
ASTNode::isWellFormedASTNode() const
{
  bool valid = false;
  
  if (mNumber != NULL)
  {
    valid = mNumber->isWellFormedNode();
  }
  else if (mFunction != NULL)
  {
    valid = mFunction->isWellFormedNode();
  }

  return valid;
}


bool
ASTNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = false;
  
  if (mNumber != NULL)
  {
    correctNumArgs = mNumber->hasCorrectNumberArguments();
  }
  else if (mFunction != NULL)
  {
    correctNumArgs = mFunction->hasCorrectNumberArguments();
  }

  return correctNumArgs;
}


/** @cond doxygenLibsbmlInternal */
bool 
ASTNode::containsVariable(const std::string id) const
{
  bool found = false;

  List * nodes = this->getListOfNodes( ASTNode_isName );
  if (nodes == NULL) return false;
  
  unsigned int i = 0;
  while (found == false && i < nodes->getSize())
  {
    ASTNode* node = static_cast<ASTNode*>( nodes->get(i) );
    string   name = node->getName() ? node->getName() : "";
    if (name == id)
    {
      found = true;
    }
    i++;
  }

  delete nodes;
  
  return found;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
unsigned int 
ASTNode::getNumVariablesWithUndeclaredUnits(Model * m) const
{
  unsigned int number = 0;

  if (m == NULL)
  {
    if (this->getParentSBMLObject() != NULL)
    {
      m = static_cast <Model *>(this->getParentSBMLObject()
                                     ->getAncestorOfType(SBML_MODEL));
    }
  }

  // we are possibly in a kineticLaw where parameters might
  // have local ids
  KineticLaw* kl = NULL;

  if (this->getParentSBMLObject() != NULL && 
    this->getParentSBMLObject()->getTypeCode() == SBML_KINETIC_LAW)
  {
    kl = static_cast<KineticLaw*>(this->getParentSBMLObject());
  }

  // create a list of variables in the math
  List * nodes = this->getListOfNodes( ASTNode_isName );
  IdList * variables = new IdList();
  if (nodes != NULL)
  {
    for (unsigned int i = 0; i < nodes->getSize(); i++)
    {
      ASTNode* node = static_cast<ASTNode*>( nodes->get(i) );
      string   name = node->getName() ? node->getName() : "";
      if (name.empty() == false)
      {
        if (variables->contains(name) == false)
        {
          variables->append(name);
        }
      }
    }
    delete nodes;
  }

  if ( m == NULL)
  {
    // there is no model so we have no units
    number = variables->size();
  }
  else
  {    
    // should we look for reactions or speciesreferences in the math
    bool allowReactionId = true;
    //bool allowSpeciesRef = false;

    if ( (m->getLevel() < 2) 
     || ((m->getLevel() == 2) && (m->getVersion() == 1)) )
    {
      allowReactionId = false;
    }

    /*if (m->getLevel() > 2)
    {
      allowSpeciesRef = true;
    }*/

    // loop thru the list and check the unit status of each variable
    for (unsigned int v = 0; v < variables->size(); v++)
    {
      string id = variables->at(v);
      

      if (m->getParameter(id) != NULL)
      {
        if (m->getParameter(id)->isSetUnits() == false)
        {
          number++;
        }
      }
      else if (m->getSpecies(id) != NULL)
      {
        UnitDefinition *ud = m->getSpecies(id)->getDerivedUnitDefinition();
        if (ud == NULL || ud->getNumUnits() == 0)
        {
          number++;
        }
        //delete ud;
      }
      else if (m->getCompartment(id) != NULL)
      {
        UnitDefinition *ud = m->getCompartment(id)->getDerivedUnitDefinition();
        if (ud == NULL || ud->getNumUnits() == 0)
        {
          number++;
        }
        //delete ud;
      }
      else if (kl != NULL && kl->getParameter(id) != NULL)
      {
        UnitDefinition *ud = kl->getParameter(id)->getDerivedUnitDefinition();
        if (ud == NULL || ud->getNumUnits() == 0)
        {
          number++;
        }
        delete ud;
      }
      else if (allowReactionId == true 
         && m->getReaction(id) != NULL 
         && m->getReaction(id)->getKineticLaw() != NULL)
      {
        UnitDefinition *ud = m->getReaction(id)->getKineticLaw()
                                               ->getDerivedUnitDefinition();
        if (ud == NULL || ud->getNumUnits() == 0)
        {
          number++;
        }
        //delete ud;
      }
      /* actually these always are considered to be dimensionless */
      //else if (allowSpeciesRef == true && m->getSpeciesReference(id) != NULL)
      //{
      //}
    }
  }

  return number;
}
/** @endcond */


int
ASTNode::setUserData(void *userData)
{
  int success = ASTBase::setUserData(userData);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->setUserData(userData);
    }
    else if (mFunction != NULL)
    {
      success = mFunction->setUserData(userData);
    }
  }

  return success;
}


void *
ASTNode::getUserData() const
{
  if (mNumber != NULL)
  {
    return mNumber->getUserData();
  }
  else if (mFunction != NULL)
  {
    return mFunction->getUserData();
  }
  else
  {
    return ASTBase::getUserData();
  }
}


bool 
ASTNode::isSetUserData() const
{
  if (mNumber != NULL)
  {
    return mNumber->isSetUserData();
  }
  else if (mFunction != NULL)
  {
    return mFunction->isSetUserData();
  }
  else
  {
    return ASTBase::isSetUserData();
  }
}
  

int 
ASTNode::unsetUserData()
{
  int success = ASTBase::unsetUserData();

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    if (mNumber != NULL)
    {
      success = mNumber->unsetUserData();
    }
    else if (mFunction != NULL)
    {
      success = mFunction->unsetUserData();
    }
  }

  return success;
}
  

bool
ASTNode::canonicalize ()
{
  bool found = false;


  if (mType == AST_NAME)
  {
    found = canonicalizeConstant();
  }

  if (!found && mType == AST_FUNCTION)
  {
    found = canonicalizeFunction();

    if (!found)
    {
      found = canonicalizeLogical();
    }

    if (!found)
    {
      found = canonicalizeRelational();
    }
  }

  return found;
}


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::canonicalizeConstant ()
{
  const int first = AST_CONSTANT_E;
  const int last  = AST_CONSTANT_TRUE;
  const int size  = last - first + 1;

  int  index;
  bool found;



  index = util_bsearchStringsI(AST_CONSTANT_STRINGS, getName(), 0, size - 1);
  found = (index < size);

  if (found)
  {
    setType( static_cast<ASTNodeType_t>(first + index) );
  }

  return found;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::canonicalizeFunction ()
{
  const int first = AST_FUNCTION_ABS;
  const int last  = AST_FUNCTION_TANH;
  const int size  = last - first + 1;

  int  index;
  bool found;


  /*
   * Search for SBML Level 1 function names first.
   */
  found = canonicalizeFunctionL1();

  /*
   * Now Lambda...
   */
  if (!found)
  {
    if ( (found = !strcmp_insensitive(getName(), AST_LAMBDA_STRING)) )
    {
      setType(AST_LAMBDA);
    }
  }

  /*
   * ... and finally the L2 (MathML) function names.
   */
  if (!found)
  {
    index = util_bsearchStringsI(AST_FUNCTION_STRINGS, getName(), 0, size - 1);
    found = (index < size);

    if (found)
    {
      setType( static_cast<ASTNodeType_t>(first + index) );
    }
  }

  return found;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::canonicalizeFunctionL1 ()
{
  ASTNode* child;


  if ( !strcmp_insensitive(getName(), "acos") )
  {
    setType(AST_FUNCTION_ARCCOS);
  }
  else if ( !strcmp_insensitive(getName(), "asin") )
  {
    setType(AST_FUNCTION_ARCSIN);
  }
  else if ( !strcmp_insensitive(getName(), "atan") )
  {
    setType(AST_FUNCTION_ARCTAN);
  }
  else if ( !strcmp_insensitive(getName(), "ceil") )
  {
    setType(AST_FUNCTION_CEILING);
  }

  /*
   * "log(x)" in L1 is represented as "ln(x)" in L2.
   *
   * Notice, however, that the conversion is performed only if the number of
   * arguments is 1.  Thus "log(5, x)" will still be "log(5, x) when passed
   * through this filter.
   */
  else if ( !strcmp_insensitive(getName(), "log") && (getNumChildren() == 1) )
  {
    setType(AST_FUNCTION_LN);
  }

  /*
   * "log10(x)" in L1 is represented as "log(10, x)" in L2.
   */
  else if ( !strcmp_insensitive(getName(), "log10") && (getNumChildren() == 1) )
  {
    setType(AST_FUNCTION_LOG);

    child = new ASTNode(AST_INTEGER);
    child->setValue(10);

    prependChild(child);
  }

  /*
   * Here we set the type to AST_FUNCTION_POWER.  We could set it to
   * AST_POWER, but then we would loose the idea that it was a function
   * before it was canonicalized.
   */
  else if ( !strcmp_insensitive(getName(), "pow") )
  {
    setType(AST_FUNCTION_POWER);
  }

  /*
   * "sqr(x)" in L1 is represented as "power(x, 2)" in L2.
   */
  else if ( !strcmp_insensitive(getName(), "sqr") && (getNumChildren() == 1) )
  {
    setType(AST_FUNCTION_POWER);

    child = new ASTNode(AST_INTEGER);
    child->setValue(2);

    addChild(child);
  }

  /*
   * "sqrt(x) in L1 is represented as "root(2, x)" in L1.
   */
  else if ( !strcmp_insensitive(getName(), "sqrt") && (getNumChildren() == 1) )
  {
    setType(AST_FUNCTION_ROOT);

    child = new ASTNode(AST_INTEGER);
    child->setValue(2);

    prependChild(child);
  }

  /*
   * Was a conversion performed?
   */
  return (mType != AST_FUNCTION);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::canonicalizeLogical ()
{
  const int first = AST_LOGICAL_AND;
  const int last  = AST_LOGICAL_XOR;
  const int size  = last - first + 1;

  int  index;
  bool found;


  index = util_bsearchStringsI(AST_LOGICAL_STRINGS, getName(), 0, size - 1);
  found = (index < size);

  if (found)
  {
    setType( static_cast<ASTNodeType_t>(first + index) );
  }

  return found;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
ASTNode::canonicalizeRelational ()
{
  const int first = AST_RELATIONAL_EQ;
  const int last  = AST_RELATIONAL_NEQ;
  const int size  = last - first + 1;

  int  index;
  bool found;


  index = util_bsearchStringsI(AST_RELATIONAL_STRINGS, getName(), 0, size - 1);
  found = (index < size);

  if (found)
  {
    setType( static_cast<ASTNodeType_t>(first + index) );
  }

  return found;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
void
ASTNode::reset()
{
  if (mNumber != NULL)
  {
    delete mNumber;
    mNumber = NULL;
  }

  if (mFunction != NULL)
  {
    delete mFunction;
    mFunction = NULL;
  }

  //mChar = 0;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
ASTNumber *
ASTNode::getNumber() const
{
  return mNumber;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
ASTFunction *
ASTNode::getFunction() const
{
  return mFunction;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
void
ASTNode::connectPlugins()
{
  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}
/** @endcond */


#endif /* __cplusplus */


/** @cond doxygenIgnored */

LIBSBML_EXTERN
ASTNode_t *
ASTNode_create (void)
{
  return new(nothrow) ASTNode;
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_createWithType (ASTNodeType_t type)
{
  return new(nothrow) ASTNode((int)(type));
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_createFromToken (Token_t *token)
{
  if (token == NULL) return NULL;
  return new(nothrow) ASTNode(token);
}


LIBSBML_EXTERN
void
ASTNode_free (ASTNode_t *node)
{
  if (node == NULL) return;

  delete static_cast<ASTNode*>(node);
}


LIBSBML_EXTERN
int
ASTNode_freeName (ASTNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->freeName();
}


LIBSBML_EXTERN
int
ASTNode_canonicalize (ASTNode_t *node)
{
  if (node == NULL) return (int)false;
  return (int) static_cast<ASTNode*>(node)->canonicalize();
}


LIBSBML_EXTERN
int
ASTNode_addChild (ASTNode_t *node, ASTNode_t *child)
{
	if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->addChild
                                    ( static_cast<ASTNode*>(child) );
}


LIBSBML_EXTERN
int
ASTNode_prependChild (ASTNode_t *node, ASTNode_t *child)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->prependChild
                                    ( static_cast<ASTNode*>(child) );
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_deepCopy (const ASTNode_t *node)
{
  if ( node == NULL ) return NULL;
  return
    static_cast<ASTNode_t *>( static_cast<const ASTNode*>(node)->deepCopy() );
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_getChild (const ASTNode_t *node, unsigned int n)
{
  if (node == NULL) return NULL;
  return static_cast<const ASTNode*>(node)->getChild(n);
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_getLeftChild (const ASTNode_t *node)
{
  if (node == NULL) return NULL;
  return static_cast<const ASTNode*>(node)->getLeftChild();
}


LIBSBML_EXTERN
ASTNode_t *
ASTNode_getRightChild (const ASTNode_t *node)
{
  if (node == NULL) return NULL;
  return static_cast<const ASTNode*>(node)->getRightChild();
}


LIBSBML_EXTERN
unsigned int
ASTNode_getNumChildren (const ASTNode_t *node)
{
  if (node == NULL) return 0;
  return static_cast<const ASTNode*>(node)->getNumChildren();
}


LIBSBML_EXTERN
List_t *
ASTNode_getListOfNodes (const ASTNode_t *node, ASTNodePredicate predicate)
{
  if (node == NULL) return NULL;
  return static_cast<const ASTNode*>(node)->getListOfNodes(predicate);
}


LIBSBML_EXTERN
void
ASTNode_fillListOfNodes ( const ASTNode_t  *node,
                          ASTNodePredicate predicate,
                          List_t           *lst )
{
  if (node == NULL) return;

  List* x = static_cast<List*>(lst);

  static_cast<const ASTNode*>(node)->fillListOfNodes(predicate, x);
}


LIBSBML_EXTERN
char
ASTNode_getCharacter (const ASTNode_t *node)
{
  if (node == NULL) return CHAR_MAX;
  return static_cast<const ASTNode*>(node)->getCharacter();
}


LIBSBML_EXTERN
long
ASTNode_getInteger (const ASTNode_t *node)
{
  if (node == NULL) return LONG_MAX;
  return static_cast<const ASTNode*>(node)->getInteger();
}


LIBSBML_EXTERN
const char *
ASTNode_getName (const ASTNode_t *node)
{
  if (node == NULL) return NULL;
  return static_cast<const ASTNode*>(node)->getName();
}


LIBSBML_EXTERN
long
ASTNode_getNumerator (const ASTNode_t *node)
{
  if (node == NULL) return LONG_MAX;
  return static_cast<const ASTNode*>(node)->getNumerator();
}


LIBSBML_EXTERN
long
ASTNode_getDenominator (const ASTNode_t *node)
{
  if (node == NULL) return LONG_MAX;
  return static_cast<const ASTNode*>(node)->getDenominator();
}


LIBSBML_EXTERN
double
ASTNode_getReal (const ASTNode_t *node)
{
  if (node == NULL) return util_NaN();
  return static_cast<const ASTNode*>(node)->getReal();
}


LIBSBML_EXTERN
double
ASTNode_getMantissa (const ASTNode_t *node)
{
  if (node == NULL) return numeric_limits<double>::quiet_NaN();
  return static_cast<const ASTNode*>(node)->getMantissa();
}


LIBSBML_EXTERN
long
ASTNode_getExponent (const ASTNode_t *node)
{
  if (node == NULL) return LONG_MAX;
  return static_cast<const ASTNode*>(node)->getExponent();
}


LIBSBML_EXTERN
int
ASTNode_getPrecedence (const ASTNode_t *node)
{
  if (node == NULL) return 6; // default precedence
  return static_cast<const ASTNode*>(node)->getPrecedence();
}


LIBSBML_EXTERN
ASTNodeType_t
ASTNode_getType (const ASTNode_t *node)
{
  if (node == NULL) return AST_UNKNOWN;
  return static_cast<const ASTNode*>(node)->getType();
}

LIBSBML_EXTERN
const char *
ASTNode_getId(const ASTNode_t * node)
{
  if (node == NULL)
    return NULL;

  return node->getId().empty() ? "" : safe_strdup(node->getId().c_str());
}

LIBSBML_EXTERN
const char *
ASTNode_getClass(const ASTNode_t * node)
{
  if (node == NULL)
    return NULL;

  return node->getClass().empty() ? "" : safe_strdup(node->getClass().c_str());
}

LIBSBML_EXTERN
const char *
ASTNode_getStyle(const ASTNode_t * node)
{
  if (node == NULL)
    return NULL;

  return node->getStyle().empty() ? "" : safe_strdup(node->getStyle().c_str());
}


LIBSBML_EXTERN
const char *
ASTNode_getUnits(const ASTNode_t * node)
{
  if (node == NULL) return NULL;
  return safe_strdup(node->getUnits().c_str());
}


LIBSBML_EXTERN
int
ASTNode_isAvogadro (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isAvogadro();
}


LIBSBML_EXTERN
int
ASTNode_isBoolean (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isBoolean();
}


LIBSBML_EXTERN
int
ASTNode_returnsBoolean (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->returnsBoolean();
}


LIBSBML_EXTERN
int
ASTNode_returnsBooleanForModel (const ASTNode_t *node, const Model_t* model)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->returnsBoolean(model);
}


LIBSBML_EXTERN
int
ASTNode_isConstant (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isConstant();
}


LIBSBML_EXTERN
int
ASTNode_isFunction (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isFunction();
}


LIBSBML_EXTERN
int
ASTNode_isInfinity (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isInfinity() );
}


LIBSBML_EXTERN
int
ASTNode_isInteger (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isInteger();
}


LIBSBML_EXTERN
int
ASTNode_isLambda (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isLambda();
}


LIBSBML_EXTERN
int
ASTNode_isLog10 (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isLog10();
}


LIBSBML_EXTERN
int
ASTNode_isLogical (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isLogical();
}


LIBSBML_EXTERN
int
ASTNode_isName (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isName();
}


LIBSBML_EXTERN
int
ASTNode_isNaN (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isNaN() );
}


LIBSBML_EXTERN
int
ASTNode_isNegInfinity (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isNegInfinity() );
}


LIBSBML_EXTERN
int
ASTNode_isNumber (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isNumber();
}


LIBSBML_EXTERN
int
ASTNode_isOperator (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isOperator();
}


LIBSBML_EXTERN
int
ASTNode_isPiecewise (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isPiecewise() );
}


LIBSBML_EXTERN
int
ASTNode_isQualifier (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isQualifier() );
}


LIBSBML_EXTERN
int
ASTNode_isRational (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isRational();
}


LIBSBML_EXTERN
int
ASTNode_isReal (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isReal();
}


LIBSBML_EXTERN
int
ASTNode_isRelational (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isRelational();
}


LIBSBML_EXTERN
int
ASTNode_isSemantics (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isSemantics() );
}


LIBSBML_EXTERN
int
ASTNode_isSqrt (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isSqrt();
}


LIBSBML_EXTERN
int
ASTNode_isUMinus (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isUMinus();
}

LIBSBML_EXTERN
int
ASTNode_isUPlus (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isUPlus();
}

LIBSBML_EXTERN
int
ASTNode_hasTypeAndNumChildren(const ASTNode_t *node, ASTNodeType_t type, unsigned int numchildren)
{
  if (node==NULL) return (int) false;
  return node->hasTypeAndNumChildren((int)(type), numchildren);
}


LIBSBML_EXTERN
int
ASTNode_isUnknown (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return (int) static_cast<const ASTNode*>(node)->isUnknown();
}


LIBSBML_EXTERN
int
ASTNode_isSetId (const ASTNode_t *node)
{
  return static_cast<int>(node->isSetId());
}


LIBSBML_EXTERN
int
ASTNode_isSetClass (const ASTNode_t *node)
{
  return static_cast<int>(node->isSetClass());
}


LIBSBML_EXTERN
int
ASTNode_isSetStyle (const ASTNode_t *node)
{
  return static_cast<int>(node->isSetStyle());
}


LIBSBML_EXTERN
int
ASTNode_isSetUnits (const ASTNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>(node->isSetUnits());
}


LIBSBML_EXTERN
int
ASTNode_hasUnits (const ASTNode_t *node)
{
  if (node == NULL) return (int)false;
  return static_cast<int>(node->hasUnits());
}


LIBSBML_EXTERN
int
ASTNode_setCharacter (ASTNode_t *node, char value)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setCharacter(value);
}


LIBSBML_EXTERN
int
ASTNode_setName (ASTNode_t *node, const char *name)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setName(name);
}


LIBSBML_EXTERN
int
ASTNode_setInteger (ASTNode_t *node, long value)
{
  if(node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setValue(value);
}


LIBSBML_EXTERN
int
ASTNode_setRational (ASTNode_t *node, long numerator, long denominator)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setValue(numerator, denominator);
}


LIBSBML_EXTERN
int
ASTNode_setReal (ASTNode_t *node, double value)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setValue(value);
}


LIBSBML_EXTERN
int
ASTNode_setRealWithExponent (ASTNode_t *node, double mantissa, long exponent)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setValue(mantissa, exponent);
}


LIBSBML_EXTERN
int
ASTNode_setType (ASTNode_t *node, ASTNodeType_t type)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setType(type);
}


LIBSBML_EXTERN
int
ASTNode_setId (ASTNode_t *node, const char *id)
{
  return static_cast<ASTNode*>(node)->setId(id);
}


LIBSBML_EXTERN
int
ASTNode_setClass (ASTNode_t *node, const char *className)
{
  return static_cast<ASTNode*>(node)->setClass(className);
}


LIBSBML_EXTERN
int
ASTNode_setStyle (ASTNode_t *node, const char *style)
{
  return static_cast<ASTNode*>(node)->setStyle(style);
}


LIBSBML_EXTERN
int
ASTNode_setUnits (ASTNode_t *node, const char *units)
{
  if (node == NULL ) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->setUnits(units);
}


LIBSBML_EXTERN
int
ASTNode_swapChildren (ASTNode_t *node, ASTNode_t *that)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)
                         ->swapChildren( static_cast<ASTNode*>(that) );
}


LIBSBML_EXTERN
int
ASTNode_unsetId (ASTNode_t *node)
{
  return static_cast<ASTNode*>(node)->unsetId();
}


LIBSBML_EXTERN
int
ASTNode_unsetClass (ASTNode_t *node)
{
  return static_cast<ASTNode*>(node)->unsetClass();
}


LIBSBML_EXTERN
int
ASTNode_unsetStyle (ASTNode_t *node)
{
  return static_cast<ASTNode*>(node)->unsetStyle();
}


LIBSBML_EXTERN
int
ASTNode_unsetUnits (ASTNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return static_cast<ASTNode*>(node)->unsetUnits();
}


LIBSBML_EXTERN
void
ASTNode_replaceArgument(ASTNode_t* node, const char * bvar, ASTNode_t* arg)
{
  if (node == NULL) return ;
  static_cast<ASTNode*>(node)->replaceArgument(bvar, 
                                                  static_cast<ASTNode*>(arg));
}


LIBSBML_EXTERN
void
ASTNode_reduceToBinary(ASTNode_t* node)
{
  if (node == NULL) return;
  static_cast<ASTNode*>(node)->reduceToBinary();
}


LIBSBML_EXTERN
SBase_t * 
ASTNode_getParentSBMLObject(ASTNode_t* node)
{
  if (node == NULL) return NULL;
  return node->getParentSBMLObject();
}



LIBSBML_EXTERN
int
ASTNode_setParentSBMLObject(ASTNode_t* node, SBase_t * sb)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setParentSBMLObject(sb);
}


LIBSBML_EXTERN
int 
ASTNode_unsetParentSBMLObject(ASTNode_t* node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->unsetParentSBMLObject();
}



LIBSBML_EXTERN
int
ASTNode_isSetParentSBMLObject(ASTNode_t* node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>(node->isSetParentSBMLObject());
}


LIBSBML_EXTERN
int
ASTNode_removeChild(ASTNode_t* node, unsigned int n)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeChild(n);
}


LIBSBML_EXTERN
int
ASTNode_replaceChild(ASTNode_t* node, unsigned int n, ASTNode_t * newChild)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->replaceChild(n, newChild);
}


LIBSBML_EXTERN
int
ASTNode_insertChild(ASTNode_t* node, unsigned int n, ASTNode_t * newChild)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->insertChild(n, newChild);
}


LIBSBML_EXTERN
int
ASTNode_addSemanticsAnnotation(ASTNode_t* node, XMLNode_t * annotation)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addSemanticsAnnotation(annotation);
}


LIBSBML_EXTERN
unsigned int
ASTNode_getNumSemanticsAnnotations(ASTNode_t* node)
{
  if (node == NULL) return 0;
  return node->getNumSemanticsAnnotations();
}


LIBSBML_EXTERN
XMLNode_t *
ASTNode_getSemanticsAnnotation(ASTNode_t* node, unsigned int n)
{
  if (node == NULL) return NULL;
  return node->getSemanticsAnnotation(n);
}


LIBSBML_EXTERN
int
ASTNode_setUserData(ASTNode_t* node, void *userData)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setUserData(userData);
}


LIBSBML_EXTERN
void *
ASTNode_getUserData(ASTNode_t* node)
{
  if (node == NULL) return NULL;
  return node->getUserData();
}


LIBSBML_EXTERN
int
ASTNode_unsetUserData(ASTNode_t* node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->unsetUserData();
}


LIBSBML_EXTERN
int
ASTNode_isSetUserData(ASTNode_t* node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>(node->isSetUserData());
}

LIBSBML_EXTERN
int
ASTNode_hasCorrectNumberArguments(ASTNode_t* node)
{
  if (node == NULL) return (int)false;
  return static_cast <int> (node->hasCorrectNumberArguments());
}

LIBSBML_EXTERN
int
ASTNode_isWellFormedASTNode(ASTNode_t* node)
{
  if (node == NULL) return (int) false;
  return static_cast <int> (node->isWellFormedASTNode());
}


LIBSBML_EXTERN
XMLAttributes_t * 
ASTNode_getDefinitionURL(ASTNode_t* node)
{
  if (node == NULL) return NULL;
  return node->getDefinitionURL();
}


LIBSBML_EXTERN
int 
ASTNode_setDefinitionURL(ASTNode_t* node, XMLAttributes_t defnURL)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setDefinitionURL(defnURL);
}


LIBSBML_EXTERN
const char * 
ASTNode_getDefinitionURLString(ASTNode_t* node)
{
  if (node == NULL) return "";
  XMLAttributes *att = node->getDefinitionURL();
  return (att != NULL) ? safe_strdup(att->getValue("definitionURL").c_str()) : "";
}



LIBSBML_EXTERN
int 
ASTNode_setDefinitionURLString(ASTNode_t* node, const char * defnURL)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  XMLAttributes_t *att = XMLAttributes_create();
  XMLAttributes_add(att, "definitionURL", defnURL);
  return node->setDefinitionURL(*(att));
}


/** @cond doxygenLibsbmlInternal */
/*
 * Internal utility function used in some language binding code.
 */
LIBSBML_EXTERN
int
ASTNode_true(const ASTNode *node)
{
  return 1;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
int
ASTNode_isPackageInfixFunction(const ASTNode *node)
{
  if(node==NULL) return 0;
  return node->isPackageInfixFunction();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
int
ASTNode_hasPackageOnlyInfixSyntax(const ASTNode *node)
{
  if(node==NULL) return 0;
  return node->hasPackageOnlyInfixSyntax();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
int
ASTNode_getL3PackageInfixPrecedence(const ASTNode *node)
{
  if(node==NULL) return 8;
  return node->getL3PackageInfixPrecedence();
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
int
ASTNode_hasUnambiguousPackageInfixGrammar(const ASTNode *node, const ASTNode *child)
{
  if(node==NULL) return 0;
  return (int)node->hasUnambiguousPackageInfixGrammar(child);
}
/** @endcond */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
