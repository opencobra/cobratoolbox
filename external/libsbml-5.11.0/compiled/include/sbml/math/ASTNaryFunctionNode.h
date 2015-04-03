/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTNaryFunctionNode.h
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

#ifndef ASTNaryFunctionNode_h
#define ASTNaryFunctionNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTFunctionBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTFunction;

class LIBSBML_EXTERN ASTNaryFunctionNode : public ASTFunctionBase
{
public:

  ASTNaryFunctionNode (int type = AST_UNKNOWN);


  /**
   * Copy constructor
   */
  ASTNaryFunctionNode (const ASTNaryFunctionNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTNaryFunctionNode& operator=(const ASTNaryFunctionNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTNaryFunctionNode ();





  /**
   * Creates a copy (clone).
   */
  virtual ASTNaryFunctionNode* deepCopy () const;

  virtual int swapChildren(ASTFunction* that);
  using ASTFunctionBase::swapChildren;

  virtual ASTBase* getChild (unsigned int n) const;

  virtual int removeChild(unsigned int n);

  bool isUMinus() const;

  bool isUPlus() const;

  bool isSqrt() const;

  bool isLog10() const;


  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");
  virtual void writeNodeOfType(XMLOutputStream& stream, int type, 
    bool inChildNode = false) const;

  virtual bool hasCorrectNumberArguments() const;

  virtual int getTypeCode () const;

  void reduceOperatorsToBinary();

  bool getReducedToBinary() const;


protected:

  /* open doxygen comment */


  bool mReducedToBinary;

  friend class ASTFunction;

  void setReducedToBinary(bool reduced);

  /* end doxygen comment */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

