/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnRationalNode.h
 * @brief   Cn Rational Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTCnRationalNode_h
#define ASTCnRationalNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTCnBase.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTCnRationalNode: public ASTCnBase
{
public:

  ASTCnRationalNode (int type = AST_RATIONAL);


  ASTCnRationalNode (const XMLNode *xml);

  
  /**
   * Copy constructor
   */
  ASTCnRationalNode (const ASTCnRationalNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCnRationalNode& operator=(const ASTCnRationalNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCnRationalNode ();





  /**
   * Creates a copy (clone).
   */
  ASTCnRationalNode* deepCopy () const;

  long getDenominator() const;

  bool isSetDenominator() const;

  int setDenominator(long value);

  int unsetDenominator();

  long getNumerator() const;

  bool isSetNumerator() const;

  int setNumerator(long value);

  int unsetNumerator();

  virtual int setValue(long numerator, long denominator);

  virtual double getValue() const;

  bool isSetRational() const;

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual int getTypeCode () const;

protected:
  //void writeENotation (  double    mantissa
  //              , long             exponent
  //              , XMLOutputStream& stream ) const;

  long mNumerator;
  long mDenominator;
  bool mIsSetDenominator;
  bool mIsSetNumerator;


};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

