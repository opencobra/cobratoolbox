/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTNumber.h
 * @brief   Cn Number Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTNumber_h
#define ASTNumber_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTBase.h>
#include <sbml/math/ASTCnIntegerNode.h>
#include <sbml/math/ASTCnRationalNode.h>
#include <sbml/math/ASTCnRealNode.h>
#include <sbml/math/ASTCnExponentialNode.h>
#include <sbml/math/ASTCiNumberNode.h>
#include <sbml/math/ASTConstantNumberNode.h>
#include <sbml/math/ASTCSymbol.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTNumber : public ASTBase
{
public:

  ASTNumber (int type = AST_UNKNOWN);


  /**
   * Copy constructor
   */
  ASTNumber (const ASTNumber& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTNumber& operator=(const ASTNumber& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTNumber ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTNumber* deepCopy () const;


  /************************************* 
   * get functions 
   */
  
  /* ast attributes */
  std::string getClass() const;
  std::string getId() const;
  std::string getStyle() const;
  
  /* numerical members */
  long getDenominator() const;
  long getExponent() const;
  long getInteger() const;
  double getMantissa() const;
  long getNumerator() const;
  double getReal() const;
  double getValue() const;

  /* other attributes */
  const std::string& getDefinitionURL() const;
  const std::string& getEncoding() const;
  const std::string& getName() const;
  std::string getUnits() const;
  const std::string& getUnitsPrefix() const;

  /* user data */
  SBase* getParentSBMLObject() const;
  void *getUserData() const;

  /************************************* 
   * isSet functions 
   */
  
  /* ast attributes */
  bool isSetClass() const;
  bool isSetId() const;
  bool isSetStyle() const;

  /* numerical members */
  bool isSetDenominator() const;
  bool isSetExponent() const;
  bool isSetInteger() const;
  bool isSetMantissa() const;
  bool isSetNumerator() const;
  bool isSetReal() const;
  bool isSetConstantValue() const;

  /* other attributes */
  bool isSetDefinitionURL() const;
  bool isSetEncoding() const;
  bool isSetName() const;
  bool isSetUnits() const;
  bool isSetUnitsPrefix() const;

  /* user data */
  bool isSetUserData() const;
  bool isSetParentSBMLObject() const;

  /************************************* 
   * set functions 
   */
  
  /* ast attributes */
  int setClass(std::string className);
  int setId(std::string id);
  int setStyle(std::string style);

  /* numerical members */
  int setDenominator(long value);
  int setExponent(long value);
  int setInteger(long value);
  int setMantissa(double value);
  int setNumerator(long value);
  int setReal(double value);
  int setValue(long numerator, long denominator);
  int setValue(double value, long value1);
  int setValue(double value);
  int setValue(long value);
  int setValue(int value);

  /* other attributes */
  int setDefinitionURL(const std::string& url);
  int setEncoding(const std::string& encoding);
  int setName(const std::string& name);
  //int setNameAndChangeType(const std::string& name);
  int setUnits(const std::string& units);
  int setUnitsPrefix(const std::string& prefix);

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
  
  /* numerical members */
  int unsetDenominator();
  int unsetExponent();
  int unsetInteger();
  int unsetMantissa();
  int unsetNumerator();
  int unsetReal();

  /* other attributes */
  int unsetDefinitionURL();
  int unsetEncoding();
  int unsetName();  
  int unsetUnits();
  int unsetUnitsPrefix();

  /* user data */
  int unsetParentSBMLObject();
  int unsetUserData();

  void setIsChildFlag(bool flag);

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
  
  
 
  virtual bool isWellFormedNode() const;
 
  virtual bool hasCorrectNumberArguments() const;
 
 
 /************************************* 
   * access member variable functions 
   */

  /************************************* 
   * read/write functions 
   */
  virtual void write(XMLOutputStream& stream) const;


  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual int getTypeCode () const;


protected:

  /* sync the member variables when changing asts */
  void syncMembersAndTypeFrom(ASTNumber* rhs, int type);
  void syncMembersAndTypeFrom(ASTFunction* rhs, int type);
  
  int setNameAndChangeType(const std::string& name);

  void reset();

  friend class ASTNode;

  /* member variables */

  ASTCnExponentialNode * mExponential;
  ASTCnIntegerNode *     mInteger;
  ASTCnRationalNode *    mRational;
  ASTCnRealNode *        mReal;
  ASTCiNumberNode *      mCiNumber;
  ASTConstantNumberNode * mConstant;
  ASTCSymbol *           mCSymbol;

  bool mIsOther;

};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

