/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCiFunctionNode.h
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

#ifndef ASTCiFunctionNode_h
#define ASTCiFunctionNode_h


#include <sbml/common/extern.h>

#include <sbml/math/ASTNaryFunctionNode.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTCiFunctionNode : public ASTNaryFunctionNode
{
public:

  ASTCiFunctionNode (int type = AST_FUNCTION);


  /**
   * Copy constructor
   */
  ASTCiFunctionNode (const ASTCiFunctionNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCiFunctionNode& operator=(const ASTCiFunctionNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCiFunctionNode ();





  /**
   * Creates a copy (clone).
   */
  virtual ASTCiFunctionNode* deepCopy () const;

  virtual int swapChildren(ASTFunction* that);

  const std::string& getName() const;
  bool isSetName() const;
  int setName(const std::string& name);
  int unsetName();

  const std::string& getDefinitionURL() const;

  bool isSetDefinitionURL() const;

  int setDefinitionURL(const std::string& url);

  int unsetDefinitionURL();

  virtual void write(XMLOutputStream& stream) const;
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  virtual int getTypeCode () const;


protected:

  /* open doxygen comment */

  std::string mName;

  
  std::string mDefinitionURL;

  /* end doxygen comment */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

