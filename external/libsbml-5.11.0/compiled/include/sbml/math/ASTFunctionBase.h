/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTFunctionBase.h
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

#ifndef ASTFunctionBase_h
#define ASTFunctionBase_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTFunctionBase: public ASTBase
{
public:

  ASTFunctionBase (int type = AST_UNKNOWN);


  /**
   * Copy constructor
   */
  ASTFunctionBase (const ASTFunctionBase& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTFunctionBase& operator=(const ASTFunctionBase& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTFunctionBase ();





  /**
   * Creates a copy (clone).
   */
  virtual ASTFunctionBase* deepCopy () const = 0;



  /**
   * Get the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @sbmlconstant{AST_PLUS, ASTNodeType_t},
   * etc.
   * 
   * @return the type of this ASTNode.
   */



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

  virtual int addChild(ASTBase * child, bool inRead = false);

  virtual ASTBase* getChild (unsigned int n) const;

  virtual unsigned int getNumChildren() const;

  virtual int removeChild(unsigned int n);

  virtual int prependChild(ASTBase* child);

  virtual int replaceChild(unsigned int n, ASTBase* newChild, bool delreplaced);

  virtual int insertChild(unsigned int n, ASTBase* newChild);

  virtual int swapChildren(ASTFunctionBase* that);

  virtual void write(XMLOutputStream& stream) const;

  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");



  bool hasChildren() const;

  void setExpectedNumChildren(unsigned int n);
  void writeArgumentsOfType(XMLOutputStream& stream, int type) const;

  virtual bool isWellFormedNode() const;

  virtual bool hasCorrectNumberArguments() const;


  virtual int getTypeCode () const;

  virtual bool hasCnUnits() const;
  virtual const std::string& getUnitsPrefix() const;

protected:

  /* open doxygen comment */

  std::vector<ASTBase*> mChildren;


  unsigned int mCalcNumChildren;

  unsigned int getExpectedNumChildren() const;


  /* end doxygen comment */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

