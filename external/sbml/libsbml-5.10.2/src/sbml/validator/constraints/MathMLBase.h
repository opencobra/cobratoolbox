/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    MathMLBase.h
 * @brief   Base class for MathML Constraints
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
 * Copyright (C) 2009-2013 jointly by the following organizations: 
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#ifndef MathMLBase_h
#define MathMLBase_h


#ifdef __cplusplus


#include <string>
#include <math.h>

#include <sbml/validator/VConstraint.h>
#include <sbml/util/memory.h>
#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;


class MathMLBase: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given @p id.
   */
  MathMLBase (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~MathMLBase ();


protected:

  /**
   * loops through all occurences of MathML within a model
   */
  virtual void check_(const Model& m, const Model& object);

  /**
   * Checks the MathML of the ASTnode 
   * is appropriate for the function being performed
   *
   * If an inconsistency is found, an error message is logged.
   */
  virtual void checkMath (const Model& m, const ASTNode& node, const SBase & sb) = 0;
 
  /**
   * Checks the MathML of the children of ASTnode 
   * forces recursion through the AST tree
   *
   * calls checkMath for each child
   */
  void checkChildren (const Model& m, const ASTNode& node, const SBase & sb);
 
  /**
   * Checks the MathML of a function definition 
   * as applied to the arguments supplied to it
   *
   * creates an ASTNode of the function with appropriate arguments
   * and calls checkMath
   */
  void checkFunction (const Model& m, const ASTNode& node, const SBase & sb);
  
  /**
   * Returns the fieldname to use when logging constraint violations
   * ("math")
   *
   * @return the fieldname ("math") to use when logging constraint
   * violations.
   */
  virtual const char* getFieldname ();

  /**
   * Returns the preamble to use when logging constraint violations.  
   *
   * @return the preamble to use when logging constraint violations.  The
   * preamble will be prepended to each log message.  If not overriden,
   * returns an empty string.
   */
  virtual const char* getPreamble ();

  /**
   * Returns the error message to use when logging constraint violations.
   * This method is called by logFailure.
   *
   * If at all possible please use getPreamble() and getFieldname() when
   * constructing error messages.  This will help to make your constraint
   * easily customizable.
   *
   * @return the error message to use when logging constraint violations.
   */
  virtual const std::string
  getMessage (const ASTNode& node, const SBase& object) = 0;

  /**
   * Returns a non-owning character pointer to the typename of the given SBase 
   * @p object, as constructed from its typecode and package.
   *
   * @return the typename of the given SBase object.
   */
  const char* getTypename (const SBase& object);

  /**
   * Logs a message that the math (and its corresponding object) have
   * failed to satisfy this constraint.
   */
  void logMathConflict (const ASTNode& node, const SBase& object);

  /**
   * Checks that the math will return a numeric result
   * forces recursion thru the AST tree
   * 
   * @returns true if produces a numeric; false otherwise
   */
  bool returnsNumeric(const Model &, const ASTNode* node);

  /**
   * Checks that the MathML of a function definition 
   * as applied to the arguments supplied to it will return a numeric
   *
   * creates an ASTNode of the function with appropriate arguments
   * and calls returnsNumeric
   * 
   * @returns true if produces a numeric; false otherwise
   */
  bool checkNumericFunction (const Model& m, const ASTNode* node);

  /**
  * Checks that the math will uses numeric functions 
  * forces recursion thru the AST tree
  * 
  * returns true if numeric functions; false otherwise
  */
  bool isNumericFunction(const Model & m, const ASTNode* node);

 /* occasionally a mathML constraint will need to know which reaction
   * the kineticLaw it is testing comes from
   * or whether the math from an event is a trigger or a delay
   *
   * this information isnt available from just the math and the model
   * and so these flags provide it
   */
  unsigned int mKLCount;
  unsigned int mIsTrigger;

  IdList mLocalParameters;

};

//void
//ReplaceArgument(ASTNode * math, const ASTNode * bvar, ASTNode * arg);

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* MathMLBase_h */

/** @endcond */

