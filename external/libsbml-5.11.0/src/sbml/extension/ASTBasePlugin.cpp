/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTBasePlugin.cpp
 * @brief   Implementation of ASTBasePlugin, the base class of extension 
 *          entities plugged in SBase derived classes in the SBML Core package.
 * @author  Sarah Keating
 *
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */


#include <sbml/common/libsbml-config-common.h>
#include <sbml/extension/ASTBasePlugin.h>

#ifndef LIBSBML_USE_LEGACY_MATH

#include <sbml/extension/SBMLExtensionRegistry.h>

#ifdef __cplusplus

#include <string>
#include <sstream>
#include <iostream>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN


/*
 * Constructor
 */
ASTBasePlugin::ASTBasePlugin (const std::string &uri)
 : mSBMLExt(SBMLExtensionRegistry::getInstance().getExtensionInternal(uri))
  ,mParent(NULL)
  ,mURI(uri)
  ,mSBMLNS(NULL)
  ,mPrefix("")
{
}

/*
 * Constructor
 */
ASTBasePlugin::ASTBasePlugin ()
 : mSBMLExt(NULL)
  ,mParent(NULL)
  ,mURI("")
  ,mSBMLNS(NULL)
  ,mPrefix("")
{
}




/*
* Copy constructor. Creates a copy of this ASTBasePlugin object.
*/
ASTBasePlugin::ASTBasePlugin(const ASTBasePlugin& orig)
  : mSBMLExt(orig.mSBMLExt)
   ,mParent(orig.mParent) // 
   ,mURI(orig.mURI)
   ,mSBMLNS(NULL)
   ,mPrefix(orig.mPrefix)
{
  if (orig.mSBMLNS) {
    mSBMLNS = orig.mSBMLNS->clone();
  }
}



/*
 * Destroy this object.
 */
ASTBasePlugin::~ASTBasePlugin ()
{
	if (mSBMLNS != NULL)
	delete mSBMLNS;
}


/*
 * Assignment operator for ASTBasePlugin.
 */
ASTBasePlugin& 
ASTBasePlugin::operator=(const ASTBasePlugin& orig)
{
  mSBMLExt = orig.mSBMLExt;
  mParent  = orig.mParent;  // 0 should be set to mSBML and mParent?
  mURI     = orig.mURI;
  mPrefix  = orig.mPrefix;

  delete mSBMLNS;
  if (orig.mSBMLNS)
    mSBMLNS = orig.mSBMLNS->clone();
  else
    mSBMLNS = NULL;

  return *this;
}

ASTBasePlugin*
ASTBasePlugin::clone () const
{
  return new ASTBasePlugin(*this);  
}


/*
 * Sets the given SBMLDocument as a parent document.
 */
int 
ASTBasePlugin::setSBMLExtension (const SBMLExtension* ext)
{
  mSBMLExt = ext;  
  return LIBSBML_OPERATION_SUCCESS;
}




/*
 * Sets the parent SBML object of this plugin object to
 * this object and child elements (if any).
 * (Creates a child-parent relationship by this plugin object)
 */
void
ASTBasePlugin::connectToParent (ASTBase* astbase)
{
  mParent = astbase;
}




/**
 *
 * (Extension)
 *
 * Sets the XML namespace to which this element belogns to.
 * For example, all elements that belong to SBML Level 3 Version 1 Core
 * must set the namespace to "http://www.sbml.org/sbml/level3/version1/core";
 * all elements that belong to Layout Extension Version 1 for SBML Level 3
 * Version 1 Core must set the namespace to
 * "http://www.sbml.org/sbml/level3/version1/layout/version1/"
 *
 */
int
ASTBasePlugin::setElementNamespace(const std::string &uri)
{
  mURI = uri;

  return LIBSBML_OPERATION_SUCCESS;
}


int
ASTBasePlugin::setPrefix(const std::string &prefix)
{
  mPrefix = prefix;

  return LIBSBML_OPERATION_SUCCESS;
}

/*
 * Returns the parent element.
 */
ASTBase*
ASTBasePlugin::getParentASTObject ()
{
  return mParent;
}


/*
 * Returns the parent element.
 */
const ASTBase*
ASTBasePlugin::getParentASTObject () const
{
  return mParent;
}



bool 
ASTBasePlugin::isSetMath() const
{
  return false;
}


const ASTBase * 
ASTBasePlugin::getMath() const
{
  return NULL;
}


void
ASTBasePlugin::createMath(int type)
{
  // do nothing
}


int 
ASTBasePlugin::addChild(ASTBase * child)
{ 
  return LIBSBML_INVALID_OBJECT; 
}


ASTBase* 
ASTBasePlugin::getChild (unsigned int n) const
{ 
  return NULL; 
}


unsigned int 
ASTBasePlugin::getNumChildren() const
{ 
  return 0; 
}


int 
ASTBasePlugin::insertChild(unsigned int n, ASTBase* newChild)
{ 
  return LIBSBML_INVALID_OBJECT; 
}


int 
ASTBasePlugin::prependChild(ASTBase* newChild)
{ 
  return LIBSBML_INVALID_OBJECT; 
}


int 
ASTBasePlugin::removeChild(unsigned int n)
{ 
  return LIBSBML_INVALID_OBJECT; 
}


int 
ASTBasePlugin::replaceChild(unsigned int n, ASTBase* newChild, bool delreplaced)
{ 
  return LIBSBML_INVALID_OBJECT; 
}

int 
ASTBasePlugin::swapChildren(ASTFunction* that)
{ 
  return LIBSBML_INVALID_OBJECT; 
}

/*
 * Enables/Disables the given package with child elements in this plugin
 * object (if any).
 */
void 
ASTBasePlugin::enablePackageInternal(const std::string& pkgURI,
                                   const std::string& pkgPrefix, bool flag)
{
 // do nothing.
}


bool 
ASTBasePlugin::stripPackage(const std::string& pkgPrefix, bool flag)
{
  return true;
}



/*
 * Returns the SBML level of this plugin object.
 *
 * @return the SBML level of this plugin object.
 */
unsigned int 
ASTBasePlugin::getLevel() const
{
  return (mSBMLExt != NULL) ? mSBMLExt->getLevel(getURI()) : 0;
}


/*
 * Returns the SBML version of this plugin object.
 *
 * @return the SBML version of this plugin object.
 */
unsigned int 
ASTBasePlugin::getVersion() const
{
  return (mSBMLExt != NULL) ? mSBMLExt->getVersion(getURI()) : 0;
}


/* open doxygen comment */
SBMLNamespaces *
ASTBasePlugin::getSBMLNamespaces() const
{
  if (mSBMLNS == NULL)
    const_cast<ASTBasePlugin*>(this)->mSBMLNS = new SBMLNamespaces();
  return mSBMLNS;

}
/* end doxygen comment */


/*
 * Returns the package version of this plugin object.
 *
 * @return the package version of this plugin object.
 */
unsigned int 
ASTBasePlugin::getPackageVersion() const
{
  return (mSBMLExt == NULL) ? 0 : mSBMLExt->getPackageVersion(getURI());
}





/*
 * Returns the namespace URI of this element.
 */
const std::string& 
ASTBasePlugin::getElementNamespace() const
{
  return mURI;  
}

std::string 
ASTBasePlugin::getURI() const
{
  if (mSBMLExt == NULL) 
    return getElementNamespace();
  
  const std::string &package = (mSBMLExt != NULL) ? mSBMLExt->getName() : std::string("");

  SBMLNamespaces* sbmlns = getSBMLNamespaces();

  if (sbmlns == NULL)
    return getElementNamespace();

  if (package == "" || package == "core")
    return sbmlns->getURI();

  std::string packageURI = sbmlns->getNamespaces()->getURI(package);
  if (!packageURI.empty())
    return packageURI;

  return getElementNamespace();
}

/*
 * Returns the prefix bound to this element.
 */
const std::string& 
ASTBasePlugin::getPrefix() const
{
  
  return mPrefix;
}


/*
 * Returns the package name of this plugin object.
 */
const std::string& 
ASTBasePlugin::getPackageName() const
{
  static string empty; 
  return (mSBMLExt != NULL) ? mSBMLExt->getName() : empty;
}





bool
ASTBasePlugin::read(XMLInputStream& stream, const std::string& reqd_prefix,
                    const XMLToken& currentElement)
{
  return false;
}

void
ASTBasePlugin::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream, int type)
{
}

bool 
ASTBasePlugin::readAttributes(const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element,
                               int type)
{
  return true;
}


void
ASTBasePlugin::writeAttributes(XMLOutputStream& stream, int type) const
{
}

void
ASTBasePlugin::writeXMLNS(XMLOutputStream& stream) const
{
}

bool 
ASTBasePlugin::isNumberNode(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isFunctionNode(int type) const
{
  return false;
}


bool 
ASTBasePlugin::representsUnaryFunction(int type) const
{
  return false;
}


bool 
ASTBasePlugin::representsBinaryFunction(int type) const
{
  return false;
}


bool 
ASTBasePlugin::representsNaryFunction(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isLogical(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isConstantNumber(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isCSymbolFunction(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isCSymbolNumber(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isName(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isNumber(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isOperator(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isRelational(int type) const
{
  return false;
}


bool 
ASTBasePlugin::representsQualifier(int type) const
{
  return false;
}


bool
ASTBasePlugin::hasCorrectNumberArguments(int type) const
{
  return true;
}


bool
ASTBasePlugin::isWellFormedNode(int type) const
{
  return true;
}


bool 
ASTBasePlugin::isFunction(int type) const
{
  return false;
}


bool 
ASTBasePlugin::isTopLevelMathMLFunctionNodeTag(const std::string& name) const
{
  return false;
}


bool 
ASTBasePlugin::isTopLevelMathMLNumberNodeTag(const std::string& name) const
{
  return false;
}


int 
ASTBasePlugin::getTypeFromName(const std::string& name) const
{
  return AST_UNKNOWN;
}


const char * 
ASTBasePlugin::getNameFromType(int type) const
{
  return "AST_unknown";
}

bool
ASTBasePlugin::isPackageInfixFunction() const
{
  //Should be overridden by actual plugins.
  return false;
}

bool
ASTBasePlugin::hasPackageOnlyInfixSyntax() const
{
  //Should be overridden by actual plugins.
  return false;
}

int ASTBasePlugin::getL3PackageInfixPrecedence() const
{
  //Should be overridden by actual plugins.
  return -1;
}

bool ASTBasePlugin::hasUnambiguousPackageInfixGrammar(const ASTNode *child) const
{
  return false;
}

void ASTBasePlugin::visitPackageInfixSyntax ( const ASTNode *parent,
                                         const ASTNode *node,
                                         StringBuffer_t  *sb,
                                         const L3ParserSettings* settings) const
{
  //Any plugin that has its own infix syntax for anything will need to override this.
}

int ASTBasePlugin::checkNumArguments(const ASTNode* function, std::stringstream& error) const
{
  //Default:  nothing is known about the function.  Return '1' for the correct number of arguments, '-1' for the incorrect number of arguments (and set 'error').
  return 0;
}

ASTNode*
ASTBasePlugin::parsePackageInfix(L3ParserGrammarLineType_t type, 
    vector<ASTNode*> *nodeList, vector<std::string*> *stringList,
    vector<double> *doubleList) const
{
  return NULL;
}


int 
ASTBasePlugin::getPackageFunctionFor(const std::string& name) const
{
  return AST_UNKNOWN;
}


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#endif /* LIBSBML_USE_LEGACY_MATH */

/** @endcond */
