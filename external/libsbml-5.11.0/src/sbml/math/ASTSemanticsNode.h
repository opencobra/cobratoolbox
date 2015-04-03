/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTSemanticsNode.h
 * @brief   Base Node for Abstract Syntax Tree (AST) class.
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

#ifndef ASTSemanticsNode_h
#define ASTSemanticsNode_h


#include <sbml/common/extern.h>
#include <sbml/xml/XMLInputStream.h>

#include <sbml/math/ASTFunctionBase.h>


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN

class ASTFunction;

class LIBSBML_EXTERN ASTSemanticsNode : public ASTFunctionBase
{
public:

  ASTSemanticsNode (int type = AST_SEMANTICS);

  /**
   * Copy constructor
   */
  ASTSemanticsNode (const ASTSemanticsNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTSemanticsNode& operator=(const ASTSemanticsNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTSemanticsNode ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTSemanticsNode* deepCopy () const;



  virtual int swapChildren(ASTFunction* that);
  using ASTFunctionBase::swapChildren;

  // functions for semantics
  int addSemanticsAnnotation (XMLNode* sAnnotation);

  unsigned int getNumSemanticsAnnotations () const;

  XMLNode* getSemanticsAnnotation (unsigned int n) const;
  int setNumAnnotations(unsigned int numAnnotations);


  unsigned int getNumAnnotations() const;

  const std::string& getDefinitionURL() const;

  bool isSetDefinitionURL() const;

  int setDefinitionURL(const std::string& url);

  int unsetDefinitionURL();

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual void addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream);

  virtual bool readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element);

  virtual bool hasCorrectNumberArguments() const;

  virtual int getTypeCode () const;


protected:

  /* member variables */

  List* mSemanticsAnnotations;

  std::string mDefinitionURL;
  unsigned int mNumAnnotations;
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

