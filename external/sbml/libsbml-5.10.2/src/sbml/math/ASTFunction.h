/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTFunction.h
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

#ifndef ASTFunction_h
#define ASTFunction_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTBase.h>
#include <sbml/math/ASTFunctionBase.h>
#include <sbml/math/ASTNaryFunctionNode.h>
#include <sbml/math/ASTUnaryFunctionNode.h>
#include <sbml/math/ASTBinaryFunctionNode.h>
#include <sbml/math/ASTCiFunctionNode.h>
#include <sbml/math/ASTLambdaFunctionNode.h>
#include <sbml/math/ASTPiecewiseFunctionNode.h>
#include <sbml/math/ASTCSymbol.h>
#include <sbml/math/ASTQualifierNode.h>
#include <sbml/math/ASTSemanticsNode.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTFunction : public ASTBase
{
public:

  ASTFunction (int type = AST_UNKNOWN);


  /**
   * Copy constructor
   */
  ASTFunction (const ASTFunction& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTFunction& operator=(const ASTFunction& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTFunction ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTFunction* deepCopy () const;

  /************************************* 
   * get functions 
   */
  
  /* ast attributes */
  std::string getClass() const;
  std::string getId() const;
  std::string getStyle() const;

  /* other attributes */
  const std::string& getDefinitionURL() const;
  const std::string& getEncoding() const;
  const std::string& getName() const;

  /* user data */
  SBase* getParentSBMLObject() const;
  void *getUserData() const;
  unsigned int getNumBvars() const;

  /************************************* 
   * isSet functions 
   */
  
  /* ast attributes */
  bool isSetClass() const;
  bool isSetId() const;
  bool isSetStyle() const;


  /* other attributes */
  bool isSetDefinitionURL() const;
  bool isSetEncoding() const;
  bool isSetName() const;
  
  /* user data */
  bool isSetParentSBMLObject() const;
  bool isSetUserData() const;

  /************************************* 
   * set functions 
   */
  
  /* ast attributes */
  int setClass(std::string className);
  int setId(std::string id);
  int setStyle(std::string style);


  /* other attributes */
  int setDefinitionURL(const std::string& url);
  int setEncoding(const std::string& encoding);
  int setName(const std::string& name);

  /* user data */
  int setParentSBMLObject(SBase* sb);
  int setUserData(void *userData);

  /************************************* 
   * unset functions 
   */
  
  /* ast attributes */
  int unsetClass();
  int unsetId();
  int unsetStyle();

  /* other attributes */
  int unsetDefinitionURL();
  int unsetEncoding();
  int unsetName();  

  /* user data */
  int unsetParentSBMLObject();
  int unsetUserData();
  
  /************************************* 
   * manipulating child functions 
   */

  int addChild(ASTBase * child);

  ASTBase* getChild (unsigned int n) const;

  unsigned int getNumChildren() const;

  int insertChild(unsigned int n, ASTBase* newChild);

  int prependChild(ASTBase* newChild);

  int removeChild(unsigned int n);

  int replaceChild(unsigned int n, ASTBase* newChild);

  int swapChildren(ASTFunction* that);

  void setIsChildFlag(bool flag);

  /************************************* 
   * semantics functions 
   */
  
  int addSemanticsAnnotation (XMLNode* sAnnotation);

  unsigned int getNumSemanticsAnnotations () const;

  XMLNode* getSemanticsAnnotation (unsigned int n) const;

  
  /************************************* 
   * convenience query functions 
   */
  
  bool isAvogadro() const;
  bool isBoolean() const;
  bool isConstant() const;
  bool isFunction() const;
  bool isInfinity() const;
  bool isInteger() const;
  bool isLambda() const;
  bool isLog10() const;
  bool isLogical() const;
  bool isName() const;
  bool isNaN() const;
  bool isNegInfinity() const;
  bool isNumber() const;
  bool isOperator() const;
  bool isPiecewise() const;
  bool isQualifier() const;
  bool isRational() const;
  bool isReal() const;
  bool isRelational() const;
  bool isSemantics() const;
  bool isSqrt() const;
  bool isUMinus() const;
  bool isUnknown() const;
  bool isUPlus() const;
  
  virtual bool hasCnUnits() const;
  virtual const std::string& getUnitsPrefix() const;
  
  /************************************* 
   * access member variable functions 
   */

  ASTUnaryFunctionNode *      getUnaryFunction() const;
  ASTBinaryFunctionNode *     getBinaryFunction() const;
  ASTNaryFunctionNode *       getNaryFunction() const;
  ASTCiFunctionNode *         getUserFunction() const;
  ASTLambdaFunctionNode *     getLambda() const;
  ASTPiecewiseFunctionNode *  getPiecewise() const;
  ASTCSymbol *                getCSymbol() const;
  ASTQualifierNode *          getQualifier() const;
  ASTSemanticsNode *          getSemantics() const;


  virtual bool isWellFormedNode() const;
 
  virtual bool hasCorrectNumberArguments() const;
 
  /************************************* 
   * read/write functions 
   */
  virtual void write(XMLOutputStream& stream) const;


  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");

  virtual void writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode = false) const;

  virtual int getTypeCode () const;


protected:

  /* sync the member variables when changing asts */
  void syncMembersAndTypeFrom(ASTNumber* rhs, int type);
  void syncMembersAndTypeFrom(ASTFunction* rhs, int type);
  void syncPackageMembersAndTypeFrom(ASTFunction* rhs, int type);
  
  int setNameAndChangeType(const std::string& name);

  void reset();

  bool readApply(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readLambda(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readPiecewise(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readQualifier(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readCiFunction(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readCSymbol(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readSemantics(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& currentElement);

  bool readFunctionNode(XMLInputStream& stream, const std::string& reqd_prefix,
                  const XMLToken& nextElement, bool& read, int type, 
                  unsigned int numChildren, ASTBasePlugin* plugin = NULL);

  bool representsQualifierNode(int type);

  friend class ASTNode;
  friend class ASTSemanticsNode;

  /* member variables */

  ASTUnaryFunctionNode *      mUnaryFunction;
  ASTBinaryFunctionNode *     mBinaryFunction;
  ASTNaryFunctionNode *       mNaryFunction;
  ASTCiFunctionNode *         mUserFunction;
  ASTLambdaFunctionNode *     mLambda;
  ASTPiecewiseFunctionNode *  mPiecewise;
  ASTCSymbol *                mCSymbol;
  ASTQualifierNode *          mQualifier;
  ASTSemanticsNode *          mSemantics;
  
  bool mIsOther;

};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

