/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbolTimeNode.h
 * @brief   Ci Number Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTCSymbolTimeNode_h
#define ASTCSymbolTimeNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTCiNumberNode.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTCSymbolTimeNode: public ASTCiNumberNode
{
public:

  ASTCSymbolTimeNode (int type = AST_NAME_TIME);


  
  /**
   * Copy constructor
   */
  ASTCSymbolTimeNode (const ASTCSymbolTimeNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCSymbolTimeNode& operator=(const ASTCSymbolTimeNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCSymbolTimeNode ();



  /**
   * Creates a copy (clone).
   */
  ASTCSymbolTimeNode* deepCopy () const;

  const std::string& getEncoding() const;
  bool isSetEncoding() const;
  int setEncoding(const std::string& encoding);
  int unsetEncoding();

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual void addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream);

  virtual bool readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element);


  virtual int getTypeCode () const;


protected:

  std::string mEncoding;


};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

