/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTLambdaFunctionNode.h
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

#ifndef ASTLambdaFunctionNode_h
#define ASTLambdaFunctionNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTNaryFunctionNode.h>
#include <sbml/math/ASTBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTLambdaFunctionNode : public ASTNaryFunctionNode
{
public:

  ASTLambdaFunctionNode (int type = AST_LAMBDA);


  /**
   * Copy constructor
   */
  ASTLambdaFunctionNode (const ASTLambdaFunctionNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTLambdaFunctionNode& operator=(const ASTLambdaFunctionNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTLambdaFunctionNode ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTLambdaFunctionNode* deepCopy () const;

  virtual int swapChildren(ASTFunction* that);

  int setNumBvars(unsigned int numBvars);


  unsigned int getNumBvars() const;

  virtual int addChild(ASTBase* child, bool inRead = false);
  using ASTFunctionBase::addChild;

  virtual ASTBase* getChild (unsigned int n) const;

  virtual int removeChild(unsigned int n);

  virtual int prependChild(ASTBase* child);

  virtual int insertChild(unsigned int n, ASTBase* newChild);

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");

  virtual bool hasCorrectNumberArguments() const;

  virtual int getTypeCode () const;


protected:

  /* open doxygen comment */

  unsigned int mNumBvars;

  
  friend class ASTFunction;

  /* end doxygen comment */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

