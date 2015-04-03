/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnExponentialNode.h
 * @brief   Cn Exponent Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTCnExponentialNode_h
#define ASTCnExponentialNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTCnBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTCnExponentialNode: public ASTCnBase
{
public:

  ASTCnExponentialNode (int type = AST_REAL_E);


  
  /**
   * Copy constructor
   */
  ASTCnExponentialNode (const ASTCnExponentialNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCnExponentialNode& operator=(const ASTCnExponentialNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCnExponentialNode ();





  /**
   * Creates a copy (clone).
   */
  ASTCnExponentialNode* deepCopy () const;

  double getMantissa() const;

  bool isSetMantissa() const;

  int setMantissa(double value);

  int unsetMantissa();

  long getExponent() const;

  bool isSetExponent() const;

  int setExponent(long value);

  int unsetExponent();

  virtual int setValue(double value, long value1);

  virtual double getValue() const;

  bool isSetExponential() const;

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");

  virtual int getTypeCode () const;


protected:

  void writeENotation (  double    mantissa
                , long             exponent
                , XMLOutputStream& stream ) const;

  long mExponent;
  double mMantissa;
  bool mIsSetMantissa;
  bool mIsSetExponent;


};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

