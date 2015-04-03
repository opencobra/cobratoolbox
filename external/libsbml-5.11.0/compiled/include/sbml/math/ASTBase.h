/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTBase.h
 * @brief   Base Node for Abstract Syntax Tree (AST) class.
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
 *
 * @class ASTBase
 * @sbmlbrief{core} Base node for AST classes.
 */

#ifndef ASTBase_h
#define ASTBase_h


#include <sbml/common/extern.h>
#include <sbml/SBMLError.h>
#include <sbml/math/ASTTypes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/ExpectedAttributes.h>

#ifdef __cplusplus

#include <vector>
#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTBasePlugin;
class SBase;

class LIBSBML_EXTERN ASTBase
{
public:

  ASTBase (int type = AST_UNKNOWN);

  ASTBase (SBMLNamespaces* sbmlns, int type = AST_UNKNOWN);
 
  /**
   * Copy constructor
   */
  ASTBase (const ASTBase& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTBase& operator=(const ASTBase& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTBase ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTBase* deepCopy () const = 0;

  void loadASTPlugins(const SBMLNamespaces* sbmlns);

  /**
   * Get the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @sbmlconstant{AST_PLUS, ASTNodeType_t},
   * etc.
   * 
   * @return the type of this ASTNode.
   */
  virtual ASTNodeType_t getType () const;



  virtual int getExtendedType() const;
  
  
  bool isSetType(); 

  /**
   * Sets the type of this ASTNode to the given type code.  A side-effect
   * of doing this is that any numerical values previously stored in this
   * node are reset to zero.
   *
   * @param type the type to which this node should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setType (ASTNodeType_t type);

  virtual int setType(int type);


  /* helper functions to establish types */
  virtual bool isAvogadro() const;
  virtual bool isBoolean() const;
  bool isBinaryFunction() const;
  virtual bool isConstant() const;
  bool isExponential() const;
  bool isCiNumber() const;
  bool isConstantNumber() const;
  bool isCSymbolFunction() const;
  bool isCSymbolNumber() const;
  virtual bool isFunction() const;
  virtual bool isInteger() const;
  virtual bool isLambda() const;
  virtual bool isLogical() const;
  virtual bool isName() const;
  bool isNaryFunction() const;
  virtual bool isNumber() const;
  virtual bool isOperator() const;
  virtual bool isPiecewise() const;
  virtual bool isQualifier() const;
  virtual bool isRational() const;
  virtual bool isReal() const;
  virtual bool isRelational() const;
  virtual bool isSemantics() const;
  bool isUnaryFunction() const;
  virtual bool isUnknown() const;
  bool isUserFunction() const;

  virtual bool representsBvar() const;
  int setIsBvar(bool isbvar);


  










  bool isNumberNode() const;
  bool isFunctionNode() const;

  bool isTopLevelMathMLFunctionNodeTag(const std::string& name) const;

  bool isTopLevelMathMLNumberNodeTag(const std::string& name) const;






  






  /* functions to read and write */
  virtual void write(XMLOutputStream& stream) const;
  
  
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual void addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream);

  virtual bool readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element);

  virtual void logError (XMLInputStream& stream, const XMLToken& element, 
    SBMLErrorCode_t code,
          const std::string& msg = ""); 
  
  //bool readAttributes(const XMLAttributes att);

  /* functions to keep note of whether this instance of an AST is a child */
  bool isChild() const;


  virtual void setIsChildFlag(bool flag);

  // functions for MathML attributes
  std::string getClass() const;
  std::string getId() const;
  std::string getStyle() const;

  SBase* getParentSBMLObject() const;

  bool isSetClass() const;
  bool isSetId() const;
  bool isSetStyle() const;

  bool isSetParentSBMLObject() const;

  int setClass(std::string className);
  int setId(std::string id);
  int setStyle(std::string style);
  
  int setParentSBMLObject(SBase* sb);
  
  int unsetClass();
  int unsetId();
  int unsetStyle();

  int unsetParentSBMLObject();

  virtual ASTBase* getFunction() const;
  //int setCharacter(char value);
  //char getCharacter() const;

  // ------------------------------------------------------------------
  //
  // public functions for EXTENSION
  //
  // ------------------------------------------------------------------

  virtual void addPlugin(ASTBasePlugin* plugin);

  /**
   * Returns a plug-in object (extension interface) for an SBML Level&nbsp;3
   * package extension with the given package name or URI.
   *
   * @param package the name or URI of the package
   *
   * @return the plug-in object (the libSBML extension interface) of
   * a package extension with the given package name or URI.
   */
  ASTBasePlugin* getPlugin(const std::string& package);


  /**
   * Returns a plug-in object (extension interface) for an SBML Level&nbsp;3
   * package extension with the given package name or URI.
   *
   * @param package the name or URI of the package
   *
   * @return the plug-in object (the libSBML extension interface) of a
   * package extension with the given package name or URI.
   */
  const ASTBasePlugin* getPlugin(const std::string& package) const;


  /**
   * Returns the nth plug-in object (extension interface) for an SBML Level&nbsp;3
   * package extension.
   *
   * @param n the index of the plug-in to return
   *
   * @return the plug-in object (the libSBML extension interface) of
   * a package extension with the given package name or URI.
   */
  ASTBasePlugin* getPlugin(unsigned int n);


  /**
   * Returns the nth plug-in object (extension interface) for an SBML Level&nbsp;3
   * package extension.
   *
   * @param n the index of the plug-in to return
   *
   * @return the plug-in object (the libSBML extension interface) of a
   * package extension with the given package name or URI.
   */
  const ASTBasePlugin* getPlugin(unsigned int n) const;


  /**
   * Returns the number of plug-in objects (extenstion interfaces) for SBML
   * Level&nbsp;3 package extensions known.
   *
   * @return the number of plug-in objects (extension interfaces) of
   * package extensions known by this instance of libSBML.
   */
  unsigned int getNumPlugins() const;


  int getTypeFromName(const std::string& name) const;

  const char * getNameFromType(int type) const;

  int setUserData(void *userData);
  void *getUserData() const;
  bool isSetUserData() const;
  int unsetUserData();
  
  //virtual void syncMembersFrom(ASTBase* rhs);
  virtual void writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode = false) const;


  virtual bool isWellFormedNode() const;

  virtual bool hasCorrectNumberArguments() const;

  virtual int getTypeCode () const;

  virtual const std::string& getPackageName() const;

  int setPackageName(const std::string& name);

  virtual bool hasCnUnits() const;
  virtual const std::string& getUnitsPrefix() const;
  
  /**
   * Returns true if this is a package function which should be written as
   * "functionname(argumentlist)", false otherwise.
   */
  virtual bool isPackageInfixFunction() const;

  /**
   * Returns true if this is a package function which should be written
   * special syntax that the package knows about, false otherwise.
   */
  virtual bool hasPackageOnlyInfixSyntax() const;

  /**
   * Returns the precedence of the functions within the package
   */
  virtual int getL3PackageInfixPrecedence() const;

  /**
   * Returns true if this is a package function which needs no special
   * consideration when writng as infix, false otherwise.
   */
  virtual bool hasUnambiguousPackageInfixGrammar(const ASTNode *child) const;



protected:

  void resetPackageName();


  void checkPrefix(XMLInputStream& stream, const std::string& reqd_prefix, 
    const XMLToken& element);

  void writeStartEndElement(XMLOutputStream& stream) const;

  void writeConstant(XMLOutputStream& stream, const std::string & name) const;
  void writeStartElement(XMLOutputStream& stream) const;
  
  void writeAttributes(XMLOutputStream& stream) const;

  virtual void writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const;

  virtual void writeENotation (  const std::string&    mantissa
    , const std::string&    exponent
                , XMLOutputStream& stream ) const;


  void writeNegInfinity(XMLOutputStream& stream) const;

  virtual void syncMembersFrom(ASTBase* rhs);
  virtual void syncMembersAndResetParentsFrom(ASTBase* rhs);
  virtual void syncPluginsFrom(ASTBase* rhs);
  virtual void syncMembersOnlyFrom(ASTBase* rhs);

  /* member variables */

  bool mIsChildFlag;

  ASTNodeType_t mType;
  int mTypeFromPackage;
  std::string mPackageName;
  
  // additional MathML attributes
  std::string mId;
  std::string mClass;
  std::string mStyle;

  SBase * mParentSBMLObject;

  void * mUserData;

  std::string mEmptyString;

  bool mIsBvar;

  //char mChar;

  //----------------------------------------------------------------------
  //
  // Additional data members for Extension
  //
  //----------------------------------------------------------------------

  //
  // ASTBasePlugin derived classes will be stored in mPlugins.
  std::vector<ASTBasePlugin*> mPlugins;

  /* functions and friends to facilitate extensions */

  virtual unsigned int getNumChildren() const;

  virtual double getValue() const;

  friend class ASTNumber;
  friend class ASTFunction;
  friend class ASTCSymbol;
  friend class ASTNode;

private:
  void clearPlugins();
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

