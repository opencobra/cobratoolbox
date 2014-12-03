/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTBase.cpp
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
#include <sbml/math/ASTNumber.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

/* open doxygen comment */

///*
// * Used by the Destructor to delete each item in mPlugins.
// */
//struct DeleteASTPluginEntity : public unary_function<ASTBasePlugin*, void>
//{
//  void operator() (ASTBasePlugin* ast) { delete ast;}
//};
//

/*
 * Used by the Copy Constructor to clone each item in mPlugins.
 */
struct CloneASTPluginEntity : public unary_function<ASTBasePlugin*, ASTBasePlugin*>
{
  ASTBasePlugin* operator() (ASTBasePlugin* ast) { 
    if (!ast) return 0;
    return ast->clone(); 
  }
};

struct AssignASTPluginEntity : public unary_function<ASTBasePlugin*, ASTBasePlugin*>
{
  ASTBasePlugin* operator() (ASTBasePlugin* ast) { 
    if (!ast) return 0;
    return ast; 
  }
};

/*
 * Used by the Copy Constructor to clone each item in mPlugins.
 */
struct CloneASTPluginEntityNoParent : public unary_function<ASTBasePlugin*, ASTBasePlugin*>
{
  ASTBasePlugin* operator() (ASTBasePlugin* ast) { 
    if (!ast) return 0;
    ast->connectToParent(NULL);
    return ast->clone(); 
  }
};

/* end doxygen comment */



ASTBase::ASTBase (int type) :
   mIsChildFlag     ( false )
   , mPackageName      ( "core" )
   , mId ("")
   , mClass ("")
   , mStyle ("")
   , mParentSBMLObject ( NULL )
   , mUserData ( NULL )
   , mEmptyString ("")
   , mIsBvar ( false )
{
  setType(type);

  loadASTPlugins(NULL);

  // need to set the package name

  resetPackageName();

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}
  

ASTBase::ASTBase (SBMLNamespaces* sbmlns, int type) :
   mIsChildFlag     ( false )
   , mPackageName      ( "core" )
   , mId ("")
   , mClass ("")
   , mStyle ("")
   , mParentSBMLObject ( NULL )
   , mUserData ( NULL )
   , mEmptyString ("")
   , mIsBvar ( false )
{
  setType(type);

  loadASTPlugins(sbmlns);
  
  // need to set the package name

  resetPackageName();
  
}
  

/**
 * Copy constructor
 */
ASTBase::ASTBase (const ASTBase& orig):
   mIsChildFlag          ( orig.mIsChildFlag )  
  , mType                ( orig.mType )
  , mTypeFromPackage     ( orig.mTypeFromPackage)
  , mPackageName         ( orig.mPackageName )
  , mId                  (orig.mId)
  , mClass               (orig.mClass)
  , mStyle               (orig.mStyle)
  , mParentSBMLObject    (orig.mParentSBMLObject)
  , mUserData            (orig.mUserData)
  , mEmptyString         (orig.mEmptyString)
  , mIsBvar              (orig.mIsBvar)
{
  mPlugins.resize( orig.mPlugins.size() );
  transform( orig.mPlugins.begin(), orig.mPlugins.end(), 
             mPlugins.begin(), CloneASTPluginEntity() );
  for (size_t i=0; i < mPlugins.size(); i++)
  {
    mPlugins[i]->connectToParent(this);
  }
}


/**
 * Assignment operator for ASTNode.
 */
ASTBase&
ASTBase::operator=(const ASTBase& rhs)
{
  if(&rhs!=this)
  {
    mIsChildFlag          = rhs.mIsChildFlag;
    mType                 = rhs.mType;
    mTypeFromPackage      = rhs.mTypeFromPackage;
    mPackageName          = rhs.mPackageName;
    mId                   = rhs.mId;
    mClass                = rhs.mClass;
    mStyle                = rhs.mStyle;
    mParentSBMLObject     = rhs.mParentSBMLObject;
    mUserData             = rhs.mUserData;
    mEmptyString          = rhs.mEmptyString;
    mIsBvar               = rhs.mIsBvar;

    mPlugins.clear();
    mPlugins.resize( rhs.mPlugins.size() );
    transform( rhs.mPlugins.begin(), rhs.mPlugins.end(), 
               mPlugins.begin(), CloneASTPluginEntity() );
  }
  return *this;
}


/**
 * Destroys this ASTNode, including any child nodes.
 */
ASTBase::~ASTBase ()
{
  //for_each( mPlugins.begin(), mPlugins.end(), DeleteASTPluginEntity() );
}

  
int
ASTBase::getTypeCode () const
{
  return AST_TYPECODE_BASE;
}


// functions for MathML attributes

std::string 
ASTBase::getClass() const
{
  return mClass;
}


std::string 
ASTBase::getId() const
{
  return mId;
}


std::string 
ASTBase::getStyle() const
{
  return mStyle;
}


SBase *
ASTBase::getParentSBMLObject() const
{
  return mParentSBMLObject;
}


bool 
ASTBase::isSetClass() const
{
  return (mClass.empty() == false);
}


bool 
ASTBase::isSetId() const
{
  return (mId.empty() == false);
}


bool
ASTBase::isSetParentSBMLObject() const
{
  return (mParentSBMLObject != NULL);
}


bool 
ASTBase::isSetStyle() const
{
  return (mStyle.empty() == false);
}


int 
ASTBase::setClass(std::string className)
{
  mClass = className;
  return LIBSBML_OPERATION_SUCCESS;
}


int 
ASTBase::setId(std::string id)
{
  mId = id;
  return LIBSBML_OPERATION_SUCCESS;
}


int 
ASTBase::setStyle(std::string style)
{
  mStyle = style;
  return LIBSBML_OPERATION_SUCCESS;
}


int
ASTBase::setParentSBMLObject(SBase* sb)
{
  mParentSBMLObject = sb;
  if (mParentSBMLObject != NULL)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
ASTBase::unsetClass()
{
  mClass = "";
  if (mClass.empty() == true)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
ASTBase::unsetId()
{
  mId = "";
  if (mId.empty() == true)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
ASTBase::unsetParentSBMLObject()
{
  mParentSBMLObject = NULL;
  if (mParentSBMLObject == NULL)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int 
ASTBase::unsetStyle()
{
  mStyle = "";
  if (mStyle.empty() == true)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}

ASTNodeType_t
ASTBase::getType () const
{
  return mType;
}


int
ASTBase::getExtendedType () const
{
  if (mType == AST_ORIGINATES_IN_PACKAGE)
  {
    return mTypeFromPackage;
  }
  else
  {
    return (int)(mType);
  }
}



bool 
ASTBase::isSetType()
{
  return (mType != AST_UNKNOWN);
}


int 
ASTBase::setType (ASTNodeType_t type)
{
  mType = type;
  mPackageName = "core";
  mTypeFromPackage = AST_UNKNOWN;
  if (type == AST_QUALIFIER_BVAR)
  {
    mIsBvar = true;
  }
  if (type == AST_UNKNOWN)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
}


int 
ASTBase::setType (int type)
{
  if (type < AST_ORIGINATES_IN_PACKAGE)
  {
    mType = (ASTNodeType_t)(type);
    mTypeFromPackage = AST_UNKNOWN;
    mPackageName = "core";
  }
  else
  {
    mType = AST_ORIGINATES_IN_PACKAGE;
    mTypeFromPackage = type;
    resetPackageName();
  }
 
  /* HACK for replicating old behaviour */
  if (type == AST_QUALIFIER_BVAR)
  {
    mIsBvar = true;
  }

  if (type == AST_UNKNOWN)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
}


const std::string&
ASTBase::getPackageName() const
{
  return mPackageName;
}


int
ASTBase::setPackageName(const std::string& name)
{
  mPackageName = name;
  return LIBSBML_OPERATION_SUCCESS;
}

bool
ASTBase::isPackageInfixFunction() const
{
  if (getType() != AST_ORIGINATES_IN_PACKAGE) return false;
  for (size_t i=0; i < mPlugins.size(); i++)
  {
    if (mPlugins[i]->isPackageInfixFunction()) return true;
  }
  return false;
}

bool
ASTBase::hasPackageOnlyInfixSyntax() const
{
  if (getType() != AST_ORIGINATES_IN_PACKAGE) return false;
  for (size_t i=0; i < mPlugins.size(); i++)
  {
    if (mPlugins[i]->hasPackageOnlyInfixSyntax()) return true;
  }
  return false;
}

int
ASTBase::getL3PackageInfixPrecedence() const
{
  if (getType() != AST_ORIGINATES_IN_PACKAGE) return 8;
  for (size_t i=0; i < mPlugins.size(); i++)
  {
    int ret = mPlugins[i]->getL3PackageInfixPrecedence();
    if (ret != -1) return ret;
  }
  return 8;
}

bool 
ASTBase::hasUnambiguousPackageInfixGrammar(const ASTNode *child) const
{
  if (getType() != AST_ORIGINATES_IN_PACKAGE) return false;
  for (size_t i=0; i < mPlugins.size(); i++)
  {
    if (mPlugins[i]->hasUnambiguousPackageInfixGrammar(child)) return true;
  }
  return false;
}

  /* helper functions */

bool 
ASTBase::isAvogadro() const
{
  return (getType() == AST_NAME_AVOGADRO);
}


bool 
ASTBase::isBoolean() const
{
  bool boolean = false;

  ASTNodeType_t type = getType();
  if (isLogical() == true || isRelational() == true
    || type == AST_CONSTANT_TRUE || type == AST_CONSTANT_FALSE)
  {
    boolean = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(boolean == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isLogical(getExtendedType()) == true)
      {
        boolean = true;
      }
      i++;
    }
  }

  return boolean;
}



bool 
ASTBase::isBinaryFunction() const
{
  bool isFunction = false;

  int type = getExtendedType();
  if (representsBinaryFunction(type) == true)
  {
    isFunction = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isFunction == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->representsBinaryFunction(type) == true)
      {
        isFunction = true;
      }
      i++;
    }
  }
  return isFunction;
}


bool 
ASTBase::isConstant() const
{
  bool isConstant = isConstantNumber();

  if (isConstant == false && ASTBase::isAvogadro() == true)
  {
    isConstant = true;
  }
  
  return isConstant;
}


bool 
ASTBase::isExponential() const
{
  return (getType() == AST_REAL_E);
}


bool 
ASTBase::isCiNumber() const
{
  bool isNumber = false;

  switch (mType)
  {
  case AST_NAME:
    isNumber = true;
    break;
  default:
    break;
  }

  return isNumber;
}


bool 
ASTBase::isConstantNumber() const
{
  bool isNumber = false;

  //FIX ME
  // do I want true and false here
  switch (mType)
  {
    case AST_CONSTANT_E:
    case AST_CONSTANT_FALSE:
    case AST_CONSTANT_PI:
    case AST_CONSTANT_TRUE:
      isNumber = true;
      break;
    default:
      break;
  }
  
  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNumber == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isConstantNumber(getExtendedType()) == true)
      {
        isNumber = true;
      }
      i++;
    }
  }

  return isNumber;
}


bool 
ASTBase::isCSymbolFunction() const
{
  bool isCsymbolFunc = false;

  switch (getType())
  {
  case AST_FUNCTION_DELAY:
    isCsymbolFunc = true;
    break;
  default:
    break;
  }

  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isCsymbolFunc == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isCSymbolFunction(getExtendedType()) == true)
      {
        isCsymbolFunc = true;
      }
      i++;
    }
  }
  
  return isCsymbolFunc;
}


bool 
ASTBase::isCSymbolNumber() const
{
  bool isNumber = false;

  switch (getType())
  {
  case AST_NAME_TIME:
  case AST_NAME_AVOGADRO:
    isNumber = true;
    break;
  default:
    break;
  }

  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNumber == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isCSymbolNumber(getExtendedType()) == true)
      {
        isNumber = true;
      }
      i++;
    }
  }
  return isNumber;
}


bool 
ASTBase::isFunction() const
{
  bool isFunction = false;

  int type = getType();
  if (type >= AST_FUNCTION && type <= AST_FUNCTION_TANH)
  {
    isFunction = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isFunction == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isFunction(getExtendedType()) == true)
      {
        isFunction = true;
      }
      i++;
    }
  }

  return isFunction;
}


bool 
ASTBase::isInteger() const
{
  return (getType() == AST_INTEGER);
}


bool 
ASTBase::isLambda() const
{
  return (getType() == AST_LAMBDA);
}


bool 
ASTBase::isLogical() const
{
  bool isLogical = false;

  int type = getExtendedType();
  if (type >= AST_LOGICAL_AND && type <= AST_LOGICAL_XOR)
  {
    isLogical = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isLogical == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isLogical(type) == true)
      {
        isLogical = true;
      }
      i++;
    }
  }

  return isLogical;
}


bool 
ASTBase::isName() const
{
  bool isName = false;

  switch (getType())
  {
  case AST_NAME:
  case AST_NAME_AVOGADRO:
  case AST_NAME_TIME:
    isName = true;
    break;
  default:
    break;
  }
  
  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isName == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isName(getExtendedType()) == true)
      {
        isName = true;
      }
      i++;
    }
  }

  return isName;
}


bool 
ASTBase::isNaryFunction() const
{
  bool isFunction = false;

  int type = getExtendedType();

  if (representsNaryFunction(type) == true)
  {
    isFunction = true;
  }
  else if (representsFunctionRequiringAtLeastTwoArguments(type) == true)
  {
    isFunction = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isFunction == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->representsNaryFunction(type) == true)
      {
        isFunction = true;
      }
      i++;
    }
  }
  return isFunction;
}


bool 
ASTBase::isNumber() const
{
  bool isNumber = false;

  switch (mType)
  {
  case AST_INTEGER:
  case AST_REAL:
  case AST_REAL_E:
  case AST_RATIONAL:
    isNumber = true;
    break;
  default:
    break;
  }
  
  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNumber == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isNumber(getExtendedType()) == true)
      {
        isNumber = true;
      }
      i++;
    }
  }

  return isNumber;
}


bool 
ASTBase::isOperator() const
{
  bool isOperator = false;

  int type = getExtendedType();
  if (type == AST_PLUS || type == AST_MINUS || type == AST_TIMES
    || type == AST_DIVIDE || type == AST_POWER)
  {
    isOperator = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isOperator == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isOperator(type) == true)
      {
        isOperator = true;
      }
      i++;
    }
  }

  return isOperator;
}


bool 
ASTBase::isPiecewise() const
{
  return (getType() == AST_FUNCTION_PIECEWISE);
}


bool 
ASTBase::isQualifier() const
{
  bool isQualifier = false;

  if (representsQualifier(getExtendedType()) == true)
  {
    isQualifier = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isQualifier == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->representsQualifier(getExtendedType()) == true)
      {
        isQualifier = true;
      }
      i++;
    }
  }
  return isQualifier;
}


bool 
ASTBase::isRational() const
{
  return (getType() == AST_RATIONAL);
}


bool 
ASTBase::isReal() const
{
  return (getType() == AST_REAL);
}


bool 
ASTBase::isRelational() const
{
  bool relational = false;

  int type = getExtendedType();
  if (type >= AST_RELATIONAL_EQ && type <= AST_RELATIONAL_NEQ)
  {
    relational = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(relational == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isRelational(type) == true)
      {
        relational = true;
      }
      i++;
    }
  }

  return relational;
}


bool 
ASTBase::isSemantics() const
{
  bool isSemantics = false;

  if (getType() == AST_SEMANTICS)
  {
    isSemantics = true;
  }

  return isSemantics;
}


bool 
ASTBase::isUnaryFunction() const
{
  bool isFunction = false;

  int type = getExtendedType();

  if (representsUnaryFunction(type) == true)
  {
    isFunction = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isFunction == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->representsUnaryFunction(type) == true)
      {
        isFunction = true;
      }
      i++;
    }
  }
  return isFunction;
}


bool 
ASTBase::isUnknown() const
{
  return (getType() == AST_UNKNOWN);
}


bool 
ASTBase::isUserFunction() const
{
  bool isFunction = false;

  if (getType() == AST_FUNCTION)
  {
    isFunction = true;
  }

  return isFunction;
}


bool 
ASTBase::isNumberNode() const
{
  bool isNumberNode = false;

  if ( ASTBase::isNumber() == true
    || isCiNumber() == true
    || isConstantNumber() == true
    || mType == AST_NAME_TIME
    || mType == AST_NAME_AVOGADRO)
  {
    isNumberNode = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNumberNode == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isNumberNode(getExtendedType()) == true)
      {
        isNumberNode = true;
      }
      i++;
    }
  }

  return isNumberNode;
}



bool 
ASTBase::isFunctionNode() const
{
  bool isFunctionNode = false;

  if ( isFunction() == true
    || isLambda() == true
    || isLogical() == true
    || isRelational() == true
    || isOperator() == true
    || isPiecewise() == true
    || isSemantics() == true
    || isQualifier() == true)
  {
    isFunctionNode = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isFunctionNode == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isFunctionNode(getExtendedType()) == true)
      {
        isFunctionNode = true;
      }
      i++;
    }
  }

  return isFunctionNode;
}


bool 
ASTBase::isTopLevelMathMLFunctionNodeTag(const std::string& name) const
{
  bool isNode = false;

  if ( isCoreTopLevelMathMLFunctionNodeTag(name))
  {
    isNode = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNode == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isTopLevelMathMLFunctionNodeTag(name) == true)
      {
        isNode = true;
      }
      i++;
    }
  }

  return isNode;
}


bool 
ASTBase::isTopLevelMathMLNumberNodeTag(const std::string& name) const
{
  bool isNode = false;

  if ( isCoreTopLevelMathMLNumberNodeTag(name))
  {
    isNode = true;
  }
  else if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while(isNode == false && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      if (plugin->isTopLevelMathMLNumberNodeTag(name) == true)
      {
        isNode = true;
      }
      i++;
    }
  }

  return isNode;
}


int
ASTBase::setUserData(void *userData)
{
	mUserData = userData;
  if (userData == NULL)
  {
    if (mUserData == NULL)
    {
      return LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      return LIBSBML_OPERATION_FAILED;
    }
  }
  if (mUserData != NULL)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


void *
ASTBase::getUserData() const
{
	return mUserData;
}


bool
ASTBase::isSetUserData() const
{
  return (mUserData != NULL);
}


int
ASTBase::unsetUserData()
{
	mUserData = NULL;
  if (mUserData == NULL)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


bool 
ASTBase::isWellFormedNode() const
{
  return true;
}


bool 
ASTBase::hasCorrectNumberArguments() const
{
  return true;
}


bool
ASTBase::hasCnUnits() const
{
  return false;
}


const std::string&
ASTBase::getUnitsPrefix() const
{
  return mEmptyString;
}


bool
ASTBase::representsBvar() const
{
  return mIsBvar;
}


int
ASTBase::setIsBvar(bool isbvar)
{
  mIsBvar = isbvar;
  return LIBSBML_OPERATION_SUCCESS;
}


void 
ASTBase::write(XMLOutputStream& stream) const
{
}

bool 
ASTBase::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  ExpectedAttributes expectedAttributes;
  addExpectedAttributes(expectedAttributes, stream);
  
  const XMLToken element = stream.next ();
  
  return readAttributes(element.getAttributes(), expectedAttributes,
                        stream, element);
}

void
ASTBase::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  attributes.add("id");
  attributes.add("class");
  attributes.add("style");
  
  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->addExpectedAttributes(attributes, stream, getExtendedType());
  }
}

bool 
ASTBase::readAttributes(const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element)
{
  bool read = true;

  //
  // check that all attributes are expected
  //
  for (int i = 0; i < attributes.getLength(); i++)
  {
    std::string name   = attributes.getName(i);
    std::string uri    = attributes.getURI(i);
    std::string prefix = attributes.getPrefix(i);

    //
    // To allow prefixed attribute whose namespace doesn't belong to
    // core or extension package.
    //
    // (e.g. xsi:type attribute in Curve element in layout extension)
    //
    if (!prefix.empty())
    {
      if ( expectedAttributes.hasAttribute(prefix + ":" + name) ) continue;
    }

    if (!expectedAttributes.hasAttribute(name))
    {
      std::string message = "The attribute '" + name + "' is not permitted" +
        " on a <" + element.getName() + "> element.";
      if (name == "type")
      {
        logError(stream, element, DisallowedMathTypeAttributeUse, message);    
      }
      else if (name == "encoding")
      {
        logError(stream, element, DisallowedMathMLEncodingUse, message);    
      }
      else if (name == "definitionURL")
      {
        logError(stream, element, DisallowedDefinitionURLUse, message);    
      }
      else if (name == "units")
      {
        if (stream.getSBMLNamespaces() != NULL
          && stream.getSBMLNamespaces()->getLevel() > 2)
        {
          logError(stream, element, DisallowedMathUnitsUse, message);   
        }
        else
        {
          message = "The 'units' attribute was introduced in SBML Level 3.";
          logError(stream, element, InvalidMathMLAttribute, message);  
        }

      }
      else
      {
        logError(stream, element, InvalidMathElement, message);
      }

      // not sufficient to make the read bad
      //return false;
    }
  }


  
  string id; 
  string className;
  string style;

  attributes.readInto( "id"           , id        );
  attributes.readInto( "class"        , className );
  attributes.readInto( "style"        , style     );

  if (!id.empty())
  {
	  if (setId(id) != LIBSBML_OPERATION_SUCCESS)
    {
      read = false;
    }
  }

  if (!className.empty())
  {
	  if (setClass(className) != LIBSBML_OPERATION_SUCCESS)
    {
      read = false;
    }
  }

  if (!style.empty())
  {
	  if (setStyle(style) != LIBSBML_OPERATION_SUCCESS)
    {
      read = false;
    }
  }

  unsigned int i = 0;
  while (read == true && i < getNumPlugins())
  {
    read = getPlugin(i)->readAttributes(attributes, expectedAttributes, 
                                        stream, element, getExtendedType());
    i++;
  }


  return read;
}


bool 
ASTBase::isChild() const
{
  return mIsChildFlag;
}


void 
ASTBase::setIsChildFlag(bool flag)
{
  mIsChildFlag = flag;
}

//
//
// (EXTENSION)
//
//

void 
ASTBase::addPlugin(ASTBasePlugin* plugin)
{
  mPlugins.push_back(plugin);
}


/*
 * Returns a plugin object (extenstion interface) of package extension
 * with the given package name or URI.
 *
 * @param package the name or URI of the package
 *
 * @return the plugin object of package extension with the given package
 * name or URI. 
 */
ASTBasePlugin* 
ASTBase::getPlugin(const std::string& package)
{
  ASTBasePlugin* astPlugin = 0;

  for (size_t i=0; i < mPlugins.size(); i++)
  {
    std::string uri = mPlugins[i]->getURI();
    const SBMLExtension* sbmlext = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);
    if (uri == package)
    {
      astPlugin = mPlugins[i];
      break;
    }
    else if (sbmlext && (sbmlext->getName() == package) )
    {
      astPlugin = mPlugins[i];
      break;
    }
  }

  return astPlugin;
}


/*
 * Returns a plugin object (extenstion interface) of package extension
 * with the given package name or URI.
 *
 * @param package the name or URI of the package
 *
 * @return the plugin object of package extension with the given package
 * name or URI. 
 */
const ASTBasePlugin* 
ASTBase::getPlugin(const std::string& package) const
{
  return const_cast<ASTBase*>(this)->getPlugin(package);
}


ASTBasePlugin* 
ASTBase::getPlugin(unsigned int n)
{
  if (n >= getNumPlugins()) 
    return NULL;
  return mPlugins[n];
}


/*
 * Returns a plugin object (extenstion interface) of package extension
 * with the given package name or URI.
 *
 * @param package the name or URI of the package
 *
 * @return the plugin object of package extension with the given package
 * name or URI. 
 */
const ASTBasePlugin* 
ASTBase::getPlugin(unsigned int n) const
{
  return const_cast<ASTBase*>(this)->getPlugin(n);
}


/*
 * Returns the number of plugin objects of package extensions.
 *
 * @return the number of plugin objects of package extensions.
 */
unsigned int 
ASTBase::getNumPlugins() const
{
  return (int)mPlugins.size();
}


void
ASTBase::writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const
{
  if (&stream == NULL) return;

  ostringstream output;

  output.precision(LIBSBML_DOUBLE_PRECISION);
  output << mantissa;

  const string      value_string = output.str();
  string::size_type position     = value_string.find('e');

  if (position != string::npos)
  {
    const string exponent_string = value_string.substr(position + 1);
    exponent += strtol(exponent_string.c_str(), NULL, 10);
  }

  output.str("");
  output << exponent;

  const string mantissa_string = value_string.substr(0, position);
  const string exponent_string = output.str();

  writeENotation(mantissa_string, exponent_string, stream);
}


void
ASTBase::writeENotation (  const std::string&    mantissa
                               , const std::string&    exponent
                , XMLOutputStream& stream ) const
{
  if (&mantissa == NULL || &exponent == NULL || &stream == NULL) return;

  static const string enotation = "e-notation";
  stream.writeAttribute("type", enotation);

  stream << " " << mantissa << " ";
  stream.startEndElement("sep");
  stream << " " << exponent << " ";
}

void 
ASTBase::writeNegInfinity(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  stream.startElement("apply");
  stream.startEndElement("minus");
  stream.startEndElement("infinity");
  stream.endElement("apply");
}

void 
ASTBase::writeConstant(XMLOutputStream& stream, const std::string & name) const
{
  if (&stream == NULL) return;

	stream.startElement(name);
  writeAttributes(stream);
	stream.endElement(name);
}

void 
ASTBase::writeStartEndElement (XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  const char * name = getNameFromType(getExtendedType());
	stream.startElement(name);
  writeAttributes(stream);
	stream.endElement(name);
  
}


void 
ASTBase::writeStartElement (XMLOutputStream& stream) const
{
  std::string name = getNameFromType(getExtendedType());
	stream.startElement(name);
  writeAttributes(stream);
}



void 
ASTBase::writeAttributes (XMLOutputStream& stream) const
{
  if (isSetId())
    stream.writeAttribute("id", getId());
  if (isSetClass())
	  stream.writeAttribute("class", getClass());
  if (isSetStyle())
    stream.writeAttribute("style", getStyle());

  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->writeAttributes(stream, getExtendedType());
  }
}


void 
ASTBase::writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode) const
{
}


int 
ASTBase::getTypeFromName(const std::string& name) const
{
  int type = getCoreTypeFromName(name);

  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while (type == AST_UNKNOWN && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      type = plugin->getTypeFromName(name);
      i++;
    }
  }

  return type;
}


const char* 
ASTBase::getNameFromType(int type) const
{
  const char* name = getNameFromCoreType(type);
  
  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    bool empty = name == NULL || strcmp(name, "") == 0;
    while (empty == true && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      name = plugin->getNameFromType(type);
      if (strcmp(name, "AST_unknown") == 0)
      {
        name = "";
      }
      i++;
      empty = (strcmp(name, "") == 0);
    }
  }

  return name;
}


void
ASTBase::loadASTPlugins(const SBMLNamespaces * sbmlns)
{
  if (sbmlns == NULL)
  {
    unsigned int numPkgs = SBMLExtensionRegistry::getNumRegisteredPackages();

    for (unsigned int i=0; i < numPkgs; i++)
    {
      const std::string &uri = SBMLExtensionRegistry::getRegisteredPackageName(i);
      const SBMLExtension* sbmlext = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);

      if (sbmlext && sbmlext->isEnabled())
      {

        //const std::string &prefix = xmlns->getPrefix(i);
        const ASTBasePlugin* astPlugin = sbmlext->getASTBasePlugin();
        if (astPlugin != NULL)
        {
          //// need to give the plugin infomrtaion about itself
          //astPlugin->setSBMLExtension(sbmlext);
          //astPlugin->connectToParent(this);
          mPlugins.push_back(astPlugin->clone());
        }

      }
    }
  }
  else
  {
    const XMLNamespaces *xmlns = sbmlns->getNamespaces();

    if (xmlns)
    {
      int numxmlns= xmlns->getLength();
      for (int i=0; i < numxmlns; i++)
      {
        const std::string &uri = xmlns->getURI(i);
        const SBMLExtension* sbmlext = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);

        if (sbmlext && sbmlext->isEnabled())
        {
          const ASTBasePlugin* astPlugin = sbmlext->getASTBasePlugin();
          if (astPlugin != NULL)
          {
            ASTBasePlugin* myastPlugin = astPlugin->clone();
            myastPlugin->setSBMLExtension(sbmlext);
            myastPlugin->setPrefix(xmlns->getPrefix(i));
            myastPlugin->connectToParent(this);
            mPlugins.push_back(myastPlugin);
          }
        }
      }
    }
  }
}


void
ASTBase::syncMembersFrom(ASTBase* rhs)
{
  if (rhs == NULL)
  {
    return;
  }

  mIsChildFlag          = rhs->mIsChildFlag;
  mType                 = rhs->mType;
  mTypeFromPackage      = rhs->mTypeFromPackage;
  mPackageName          = rhs->mPackageName;
  mId                   = rhs->mId;
  mClass                = rhs->mClass;
  mStyle                = rhs->mStyle;
  mParentSBMLObject     = rhs->mParentSBMLObject;
  mUserData             = rhs->mUserData;
  mIsBvar               = rhs->mIsBvar;

  // deal with plugins

  mPlugins.clear();
  mPlugins.resize( rhs->mPlugins.size() );
  transform( rhs->mPlugins.begin(), rhs->mPlugins.end(), 
             mPlugins.begin(), CloneASTPluginEntity() );
}


void
ASTBase::syncPluginsFrom(ASTBase* rhs)
{
  if (rhs == NULL)
  {
    return;
  }

  mIsChildFlag          = rhs->mIsChildFlag;
  mType                 = rhs->mType;
  mTypeFromPackage      = rhs->mTypeFromPackage;
  mPackageName          = rhs->mPackageName;
  mId                   = rhs->mId;
  mClass                = rhs->mClass;
  mStyle                = rhs->mStyle;
  mParentSBMLObject     = rhs->mParentSBMLObject;
  mUserData             = rhs->mUserData;
  mIsBvar               = rhs->mIsBvar;

  // deal with plugins

  mPlugins.clear();
  mPlugins.resize( rhs->mPlugins.size() );
  transform( rhs->mPlugins.begin(), rhs->mPlugins.end(), 
             mPlugins.begin(), AssignASTPluginEntity() );
}


void
ASTBase::syncMembersAndResetParentsFrom(ASTBase* rhs)
{
  if (rhs == NULL)
  {
    return;
  }

  mIsChildFlag          = rhs->mIsChildFlag;
  mType                 = rhs->mType;
  mTypeFromPackage      = rhs->mTypeFromPackage;
  mPackageName          = rhs->mPackageName;
  mId                   = rhs->mId;
  mClass                = rhs->mClass;
  mStyle                = rhs->mStyle;
  mParentSBMLObject     = rhs->mParentSBMLObject;
  mUserData             = rhs->mUserData;
  mIsBvar               = rhs->mIsBvar;

  // deal with plugins

  // if they are not the same delete and replace
  bool identicalPlugins = true;
  if (mPlugins.size() == rhs->mPlugins.size())
  {
    for (unsigned int i = 0; i < mPlugins.size(); i++)
    {
      if (rhs->mPlugins[i] != mPlugins[i])
        identicalPlugins = false;
    }
  }
  else
  {
    identicalPlugins = false;
  }
  if (identicalPlugins == false)
  {
    mPlugins.clear();
    mPlugins.resize( rhs->mPlugins.size() );
    transform( rhs->mPlugins.begin(), rhs->mPlugins.end(), 
               mPlugins.begin(), CloneASTPluginEntityNoParent() );
  }

  // reset parents
  for (unsigned int i = 0; i < getNumPlugins(); i++)
  {
    getPlugin(i)->connectToParent(this);
  }
}


void
ASTBase::syncMembersOnlyFrom(ASTBase* rhs)
{
  if (rhs == NULL)
  {
    return;
  }

  mIsChildFlag          = rhs->mIsChildFlag;
  mId                   = rhs->mId;
  mClass                = rhs->mClass;
  mStyle                = rhs->mStyle;
  mParentSBMLObject     = rhs->mParentSBMLObject;
  mUserData             = rhs->mUserData;

}




void
ASTBase::resetPackageName()
{
  std::string name = "";
  int type = getExtendedType();
  if (getNumPlugins() > 0)
  {
    unsigned int i = 0;
    while (name.empty() == true && i < getNumPlugins())
    {
      const ASTBasePlugin* plugin = static_cast<const ASTBasePlugin*>(getPlugin(i)); 
      name = plugin->getNameFromType(type);
      if (name == "AST_unknown")
      {
        name.clear();
      }
      i++;
    }
    if (name.empty() == false && i <= getNumPlugins())
    {
      mPackageName = getPlugin(i-1)->getPackageName();
    }
  }
}

void
ASTBase::logError (XMLInputStream& stream, const XMLToken& element, SBMLErrorCode_t code,
          const std::string& msg)
{
  if (&element == NULL || &stream == NULL) return;

  SBMLNamespaces* ns = stream.getSBMLNamespaces();
  if (ns != NULL)
  {
    static_cast <SBMLErrorLog*>
      (stream.getErrorLog())->logError(
      code,
      ns->getLevel(), 
      ns->getVersion(),
      msg, 
      element.getLine(), 
      element.getColumn());
  }
  else
  {
    static_cast <SBMLErrorLog*>
      (stream.getErrorLog())->logError(
      code, 
      SBML_DEFAULT_LEVEL, 
      SBML_DEFAULT_VERSION, 
      msg, 
      element.getLine(), 
      element.getColumn());
  }
}

void
ASTBase::checkPrefix(XMLInputStream &stream, const std::string& reqd_prefix, 
                     const XMLToken& element)
{
  if (!reqd_prefix.empty())
  {
    std::string prefix = element.getPrefix();
    if (prefix != reqd_prefix)
    {
      const string message = "Element <" + element.getName() 
        + "> should have prefix \"" + reqd_prefix + "\".";

      logError(stream, element, InvalidMathElement, message);
      
    }
  }
}


ASTBase* 
ASTBase::getFunction() const
{ 
  return NULL; 
}


double 
ASTBase::getValue() const 
{ 
  return 0;
}


unsigned int 
ASTBase::getNumChildren() const 
{
  return 0;
}



LIBSBML_CPP_NAMESPACE_END


/** @endcond */

