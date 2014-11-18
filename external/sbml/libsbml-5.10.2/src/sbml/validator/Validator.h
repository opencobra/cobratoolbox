/**
 * @file    Validator.h
 * @brief   Base class for SBML Validators
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
 * @class Validator
 * @sbmlbrief{core} Entry point for SBML validation rules in libSBML.
 * 
 * @htmlinclude not-sbml-warning.html
 *
 * LibSBML implements facilities for verifying that a given SBML document
 * is valid according to the SBML specifications; it also exposes the
 * validation interface so that user programs and SBML Level&nbsp;3 package
 * authors may use the facilities to implement new validators.  There are
 * two main interfaces to libSBML's validation facilities, based on the
 * classes Validator and SBMLValidator.
 *
 * The Validator class is the basis of the system for validating an SBML
 * document against the validation rules defined in the SBML
 * specifications.  The scheme used by Validator relies is compact and uses
 * the @em visitor programming pattern, but it relies on C/C++ features and
 * is not directly accessible from language bindings.  SBMLValidator offers
 * a framework for straightforward class-based extensibility, so that user
 * code can subclass SBMLValidator to implement new validation systems,
 * different validators can be introduced or turned off at run-time, and
 * interfaces can be provided in the libSBML language bindings.
 * SBMLValidator can call Validator functionality internally (as is the
 * case in the current implementation of SBMLInternalValidator) or use
 * entirely different implementation approaches, as necessary.
 */

#ifndef Validator_h
#define Validator_h


#ifdef __cplusplus


/** @cond doxygenLibsbmlInternal */

#include <list>
#include <string>

/** @endcond */


#include <sbml/SBMLError.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class VConstraint;
struct ValidatorConstraints;
class SBMLDocument;


class LIBSBML_EXTERN Validator
{
public:

  /**
   * Constructor; creates a new Validator object for the given
   * category of validation.
   *
   * @param category code indicating the kind of validations that this
   * validator will perform.  The category code value must be
   * @if clike taken from the enumeration #SBMLErrorCategory_t @endif@~
   * @if java one of of the values from the set of constants whose names
   * begin with the characters <code>LIBSBML_CAT_</code> in the interface
   * class {@link libsbmlConstants}.@endif@~
   * @if python one of of the values from the set of constants whose names
   * begin with the characters <code>LIBSBML_CAT_</code> in the interface
   * class @link libsbml libsbml@endlink.@endif@~
   */
  Validator ( SBMLErrorCategory_t category = LIBSBML_CAT_SBML );


  /**
   * Destroys this Validator object.
   */
  virtual ~Validator ();


  /**
   * Initializes this Validator object.
   *
   * When creating a subclass of Validator, override this method to add
   * your own validation code.
   */
  virtual void init () = 0;


  /**
   * Adds the given VContraint object to this validator.
   *
   * @param c the VConstraint ("validator constraint") object to add.
   */
  virtual void addConstraint (VConstraint* c);


  /**
   * Clears this Validator's list of validation failures.
   *
   * If you are validating multiple SBML documents with the same Validator,
   * call this method after you have processed the list of failures from
   * the last Validation run and before validating the next document.
   */
  void clearFailures ();


  /**
   * Get the category of validation rules covered by this validator.
   *
   * The category values are drawn from the enumeration
   * #SBMLErrorCategory_t.  See the documentation for the class SBMLError
   * for more information.
   */
  const unsigned int getCategory () const;


  /**
   * Get the list of SBMLError objects (if any) logged as a result
   * of running the validator.
   * 
   * @return a list of failures logged during validation.
   */
  const std::list<SBMLError>& getFailures () const;


  /**
   * Adds the given failure to this list of Validators failures.
   *
   * @param err the SBMLError object to append.
   */
  void logFailure (const SBMLError& err);


  /**
   * Validates the given SBML document.
   *
   * @param d the SBMLDocument object to be validated.
   *
   * @return the number of validation failures that occurred.  The objects
   * describing the actual failures can be retrieved using getFailures().
   */
  virtual unsigned int validate (const SBMLDocument& d);


  /**
   * Validates the SBML document located at the given file name.
   *
   * @param filename the path to the file to be read and validated.
   *
   * @return the number of validation failures that occurred.  The objects
   * describing the actual failures can be retrieved using getFailures().
   */
  virtual unsigned int validate (const std::string& filename);


protected:
  /** @cond doxygenLibsbmlInternal */


  ValidatorConstraints* mConstraints;
  std::list<SBMLError>  mFailures;
  unsigned int          mCategory;


  friend class ValidatingVisitor;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* Validator_h */
