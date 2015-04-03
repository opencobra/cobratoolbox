/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTConstantNumberNode.h
 * @brief   Constant Number Node for Abstract Syntax Tree (AST) class.
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
 * in the file Valued "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#ifndef ASTConstantNumberNode_h
#define ASTConstantNumberNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTCnBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTConstantNumberNode: public ASTCnBase
{
public:

  ASTConstantNumberNode (int type = AST_CONSTANT_PI);


  
  /**
   * Copy constructor
   */
  ASTConstantNumberNode (const ASTConstantNumberNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTConstantNumberNode& operator=(const ASTConstantNumberNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTConstantNumberNode ();



  /**
   * Creates a copy (clone).
   */
  ASTConstantNumberNode* deepCopy () const;


  int setValue(double value);

  double getValue() const;

  bool isSetValue() const;

  int unsetValue();

  bool isNaN() const;

  bool isInfinity() const;

  bool isNegInfinity() const;

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");

  virtual int getTypeCode () const;


protected:


  double mValue;
  bool mIsSetValue;

};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

