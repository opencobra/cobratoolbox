/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnRealNode.h
 * @brief   Cn Real Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTCnRealNode_h
#define ASTCnRealNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTCnBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTCnRealNode: public ASTCnBase
{
public:

  ASTCnRealNode (int type = AST_REAL);


  ASTCnRealNode (const XMLNode *xml);

  
  /**
   * Copy constructor
   */
  ASTCnRealNode (const ASTCnRealNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCnRealNode& operator=(const ASTCnRealNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCnRealNode ();





  /**
   * Creates a copy (clone).
   */
  ASTCnRealNode* deepCopy () const;



  /**
   * Get the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @sbmlconstant{AST_PLUS, ASTNodeType_t},
   * etc.
   * 
   * @return the type of this ASTNode.
   */
 // virtual ASTNodeType_t getType () const;


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
//  virtual int setType (ASTNodeType_t type);

  double getReal() const;

  bool isSetReal() const;

  int setReal(double value);

  int unsetReal();


  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");
  virtual double getValue() const;


  virtual int getTypeCode () const;

protected:

  void writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const;


  double mReal;
  bool mIsSetReal;


};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

