/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCnBase.h
 * @brief   Base Node for Abstract Syntax Tree (AST) Units.
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

#ifndef ASTCnBase_h
#define ASTCnBase_h


#include <sbml/common/extern.h>
#include <sbml/math/ASTBase.h>
#include <sbml/math/ASTTypes.h>
#include <sbml/xml/XMLInputStream.h>
#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN ASTCnBase : public ASTBase
{
public:

  ASTCnBase (int type = AST_UNKNOWN);

  /**
   * Copy constructor
   */
  ASTCnBase (const ASTCnBase& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  ASTCnBase& operator=(const ASTCnBase& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTCnBase ();


  /**
   * Creates a copy (clone).
   */
  virtual ASTCnBase* deepCopy () const = 0;


  /* functions to read and write */
  virtual void write(XMLOutputStream& stream) const;
  
  
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");


  // functions for units attributes
  std::string getUnits() const;

  bool isSetUnits() const;

  int setUnits(const std::string& units);
  
  int unsetUnits();

  virtual const std::string& getUnitsPrefix() const;
  virtual bool hasCnUnits() const;

  bool isSetUnitsPrefix() const;

  int setUnitsPrefix(std::string prefix);
  
  int unsetUnitsPrefix();

  virtual void syncMembersFrom(ASTCnBase* rhs);
  using ASTBase::syncMembersFrom;
  virtual void syncMembersAndResetParentsFrom(ASTCnBase* rhs);
  using ASTBase::syncMembersAndResetParentsFrom;

  virtual void addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream);

  virtual bool readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element);


  virtual int getTypeCode () const;



protected:
  /* member variables */

  std::string mUnits;
  std::string mUnitsPrefix;

};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif  /* ASTNode_h */


/** @endcond */

