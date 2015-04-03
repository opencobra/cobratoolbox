/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbol.h
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

#ifndef ASTCSymbol_h
#define ASTCSymbol_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTBase.h>
#include <sbml/math/ASTCSymbolTimeNode.h>
#include <sbml/math/ASTCSymbolDelayNode.h>
#include <sbml/math/ASTCSymbolAvogadroNode.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNumber;

class LIBSBML_EXTERN ASTCSymbol : public ASTBase
{
public:

  ASTCSymbol (int type = AST_UNKNOWN);


  /**
   * Copy constructor
   */
  ASTCSymbol (const ASTCSymbol& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCSymbol& operator=(const ASTCSymbol& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCSymbol ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTCSymbol* deepCopy () const;

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
  double getValue() const;

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
  int setValue(double value);


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

  int replaceChild(unsigned int n, ASTBase* newChild, bool delreplaced);

  int swapChildren(ASTFunction* that);

  void setIsChildFlag(bool flag);


  /************************************* 
   * convenience query functions 
   */
  
  bool isAvogadro() const;
  bool isDelay () const;
  bool isTime() const;
  
  

  virtual bool isWellFormedNode() const;
 
  virtual bool hasCorrectNumberArguments() const;
 
 
  virtual bool hasCnUnits() const;
  virtual const std::string& getUnitsPrefix() const;

  /************************************* 
   * access member variable functions 
   */
  ASTCSymbolTimeNode * getTime() const;
  ASTCSymbolDelayNode * getDelay() const;
  ASTCSymbolAvogadroNode * getAvogadro() const;


  /************************************* 
   * read/write functions 
   */
  virtual void write(XMLOutputStream& stream) const;


  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  void setExpectedNumChildren(unsigned int n);

  virtual int getTypeCode () const;


protected:

  /* sync the member variables when changing asts */
  void syncMembersAndTypeFrom(ASTNumber* rhs, int type);
  void syncMembersAndTypeFrom(ASTFunction* rhs, int type);

  unsigned int getExpectedNumChildren() const;

  void setInReadFromApply(bool inReadFromApply);

  void reset();

  friend class ASTNumber;
  friend class ASTFunction;

  /* member variables */

  ASTCSymbolTimeNode * mTime;
  ASTCSymbolDelayNode * mDelay;
  ASTCSymbolAvogadroNode * mAvogadro;

  bool mIsOther;

  unsigned int mCalcNumChildren;

  /* HACK TO REPLICATE OLD AST */
  bool mInReadFromApply;

};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTCSymbol_h */


/** @endcond */

