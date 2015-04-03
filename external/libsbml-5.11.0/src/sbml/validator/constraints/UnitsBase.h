/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UnitsBase.h
 * @brief   Ensures units consistent with math
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

#ifndef UnitsBase_h
#define UnitsBase_h


#ifdef __cplusplus


#include <string>
#include <math.h>

#include <sbml/validator/VConstraint.h>

#include <sbml/util/memory.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;


class UnitsBase: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given @p id.
   */
  UnitsBase (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~UnitsBase ();


protected:

  /**
   * Checks that the units of the any math within the model
   * are appropriate for the function being performed
   */
  void check_(const Model& m, const Model& object);

  /**
   * Checks that the units of the ASTnode 
   * are appropriate for the function being performed
   *
   * If inconsistent units are found, an error message is logged.
   */
  virtual void checkUnits (const Model& m, const ASTNode& node, const SBase & sb,
    bool inKL = false, int reactNo = -1) = 0;
 
  /**
   * Checks that the units of the ASTnode 
   * are appropriate for the function being performed
   *
   * If inconsistent units are found, an error message is logged.
   */
  void checkChildren (const Model& m, const ASTNode& node, const SBase & sb, 
                             bool inKL, int reactNo);
 
  /**
   * Checks that the units of function definition 
   * are appropriate for the function being performed
   * forces recursion through the AST tree
   *
   * If inconsistent units are found, an error message is logged.
   */
  void checkFunction (const Model& m, const ASTNode& node, 
    const SBase & sb, bool inKL, int reactNo);
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
   * Is a constant character reference to a static empty string.
   *
   * @return an empty string
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
   * Logs a message that the given @p id (and its corresponding object) have
   * failed to satisfy this constraint.
   */
  void logUnitConflict (const ASTNode& node, const SBase& object);

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* UnitsBase_h */

/** @endcond */
