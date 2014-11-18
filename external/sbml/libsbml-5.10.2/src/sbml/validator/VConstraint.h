/**
 * @file    VConstraint.h
 * @brief   Base class for all SBML Validator Constraints
 * @author  Ben Bornstein
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->
 *
 * @class VConstraint
 * @sbmlbrief{core} Helper class for SBML validators.
 * 
 * @htmlinclude not-sbml-warning.html
 *
 */

#ifndef Validator_Constraint_h
#define Validator_Constraint_h


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/validator/Validator.h>
#include <sbml/units/UnitFormulaFormatter.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class Model;


class LIBSBML_EXTERN VConstraint
{
public:

  /**
   * Creates a new VConstraint with the given @p id and Validator @p v.
   *
   * The severity of the constraint is set to 2 by default.
   *
   * @param id an integer, the id of the new VConstraint
   * @param v a Validator for the new VContraint
   */
  VConstraint (unsigned int id, Validator& v);


  /**
   * Destructor for the VConstraint object.
   */
  virtual ~VConstraint ();


  /**
   * Get the constraint identifier of this constraint.
   *
   * Note that constraint identifiers are unrelated to SBML identifiers put
   * on SBML components.  Constraint identifiers are a superset of the
   * validation rule numbers. (These "validation rules" are defined in the
   * SBML specifications beginning with SBML Level&nbsp;2 Version&nbsp;2.)
   * The set of possible constraint identifiers includes all SBML
   * validation rule numbers, and in addition, there exist extra
   * constraints defined by libSBML itself.
   * 
   * @return the id of this Constraint.
   */
  unsigned int getId () const;


  /**
   * Get the severity of this constraint.
   *
   * Severity codes are defined by the enumeration SBMLErrorSeverity_t.
   * See the documentation included in SBMLError for more information.
   * 
   * @return the severity for violating this Constraint.
   *
   * @see SBMLErrorSeverity_t
   */
  unsigned int getSeverity () const;


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Logs a constraint failure to the validator for the given SBML object.
   */
  void logFailure (const SBase& object);

  /**
   * Logs a constraint failure to the validator for the given SBML object.
   * The parameter message is used instead of the constraint's member
   * variable msg.
   */
  void logFailure (const SBase& object, const std::string& message);


  unsigned int mId;
  unsigned int mSeverity;
  Validator&   mValidator;
  bool         mLogMsg;

  std::string  msg;

  /** @endcond */
};


/** @cond doxygenLibsbmlInternal */

template <typename T>
class TConstraint : public VConstraint
{
public:

  TConstraint (unsigned int id, Validator& v) : VConstraint(id, v) { }
  virtual ~TConstraint () { };

  /**
   * Checks to see if this Contraint holds when applied to the given SBML
   * object of type T.  The Model object should contain object and is
   * passed in to provide additional context information, should the
   * contraint need it.
   */
  void check (const Model& m, const T& object)
  {
    mLogMsg = false;

    check_(m, object);

    if (mLogMsg) logFailure(object);
  }


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * The check method delegates to this virtual method.
   */
  virtual void check_ (const Model& m, const T& object) { };

  /** @endcond */
};

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus  */
#endif  /* Validator_Constraint_h */
