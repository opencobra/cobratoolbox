/**
 * @file    SBMLInternalValidator.h
 * @brief   Definition of SBMLInternalValidator, the validator for all internal validation performed by libSBML.
 * @author  Frank Bergmann
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
 * ------------------------------------------------------------------------ -->
 *
 * @class SBMLInternalValidator
 * @sbmlbrief{core} Basic SBML consistency checks and other validations.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * LibSBML implements facilities for verifying that a given SBML document is
 * valid according to the SBML specifications; it also exposes the validation
 * interface so that user programs and SBML Level&nbsp;3 package authors may
 * use the facilities to implement new validators.  The entry point for this
 * is the SBMLValidator class.
 *
 * The subclass SBMLInternalValidator embodies the implementation of the
 * consistency-checking methods defined on SBMLDocument.  The methods
 * SBMLDocument::setConsistencyChecks(), SBMLDocument::checkConsistency(),
 * SBMLDocument::checkInternalConsistency() and other method of that sort
 * are in fact implemented by SBMLInternalValidator.  These validations
 * are all performed on the internal (in-memory) representation of an SBML
 * model.
 *
 * Users should not need to call SBMLInternalValidator methods directly,
 * since the interface is already provided on SBMLDocument.  However, this
 * class is exposed in case users would like to implement new or additional
 * validations by extending this class (SBMLInternalValidator) or using
 * this class as an example of how to implement such validators.
 */

#ifndef SBMLInternalValidator_h
#define SBMLInternalValidator_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/validator/SBMLValidator.h>
#include <sbml/SBMLError.h>


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLInternalValidator : public SBMLValidator
{
public:

  /**
   * Controls the consistency checks that are performed when
   * SBMLDocument::checkConsistency() is called.
   *
   * This method works by adding or subtracting consistency checks from the
   * set of all possible checks that SBMLDocument::checkConsistency() knows
   * how to perform.  This method may need to be called multiple times in
   * order to achieve the desired combination of checks.  The first
   * argument (@p category) in a call to this method indicates the category
   * of consistency/error checks that are to be turned on or off, and the
   * second argument (@p apply, a boolean) indicates whether to turn it on
   * (value of @c true) or off (value of @c false).
   *
   * @if clike
   * The possible categories (values to the argument @p category) are the
   * set of values from the enumeration #SBMLErrorCategory_t.
   * The following are the possible choices:
   * @endif@if java
   * The possible categories (values to the argument @p category) are the
   * set of constants whose names begin with the characters <code>LIBSBML_CAT_</code>
   * in the interface class {@link libsbmlConstants}.
   * The following are the possible choices:
   * @endif@if python 
   * The possible categories (values to the argument @p category) are the
   * set of constants whose names begin with the characters <code>LIBSBML_CAT_</code>
   * in the interface class @link libsbml libsbml@endlink.
   * The following are the possible choices:
   * @endif@~
   * <ul>
   * <li> @sbmlconstant{LIBSBML_CAT_GENERAL_CONSISTENCY, SBMLErrorCategory_t}: 
   * Correctness and consistency of specific SBML language constructs.
   * Performing this set of checks is highly recommended.  With respect to
   * the SBML specification, these concern failures in applying the
   * validation rules numbered 2xxxx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_IDENTIFIER_CONSISTENCY, SBMLErrorCategory_t}:
   * Correctness and consistency of identifiers used for model entities.  An
   * example of inconsistency would be using a species identifier in a
   * reaction rate formula without first having declared the species.  With
   * respect to the SBML specification, these concern failures in applying
   * the validation rules numbered 103xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_UNITS_CONSISTENCY, SBMLErrorCategory_t}:
   * Consistency of measurement units associated with quantities in a model.
   * With respect to the SBML specification, these concern failures in
   * applying the validation rules numbered 105xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_MATHML_CONSISTENCY, SBMLErrorCategory_t}:
   * Syntax of MathML constructs.  With respect to the SBML specification,
   * these concern failures in applying the validation rules numbered 102xx
   * in the Level&nbsp;2 Versions&nbsp;2&ndash;4 and Level&nbsp;3
   * Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_SBO_CONSISTENCY, SBMLErrorCategory_t}:
   * Consistency and validity of %SBO identifiers (if any) used in the model.
   * With respect to the SBML specification, these concern failures in
   * applying the validation rules numbered 107xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_OVERDETERMINED_MODEL, SBMLErrorCategory_t}:
   * Static analysis of whether the system of equations implied by a model is
   * mathematically overdetermined.  With respect to the SBML specification,
   * this is validation rule #10601 in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_MODELING_PRACTICE, SBMLErrorCategory_t}:
   * Additional checks for recommended good modeling practice. (These are
   * tests performed by libSBML and do not have equivalent SBML validation
   * rules.)
   * </ul>
   * 
   * <em>By default, all validation checks are applied</em> to the model in
   * an SBMLDocument object @em unless
   * SBMLDocument::setConsistencyChecks(@if java int, boolean@endif)
   * is called to indicate that only a subset should be applied.  Further,
   * this default (i.e., performing all checks) applies separately to
   * <em>each new SBMLDocument object</em> created.  In other words, each
   * time a model is read using SBMLReader::readSBML(@if java String@endif),
   * SBMLReader::readSBMLFromString(@if java String@endif),
   * or the global functions readSBML() and readSBMLFromString(), a new
   * SBMLDocument is created and for that document, a call to
   * SBMLDocument::checkConsistency() will default to applying all possible checks.
   * Calling programs must invoke
   * SBMLDocument::setConsistencyChecks(@if java int, boolean@endif)
   * for each such new model if they wish to change the consistency checks
   * applied.
   * 
   * @param category a value drawn from @if clike #SBMLErrorCategory_t@else
   * the set of SBML error categories@endif@~ indicating the
   * consistency checking/validation to be turned on or off.
   *
   * @param apply a boolean indicating whether the checks indicated by
   * @p category should be applied or not.
   *
   * @see SBMLDocument::checkConsistency()
   */
  void setConsistencyChecks(SBMLErrorCategory_t category, bool apply);


  /**
   * Controls the consistency checks that are performed when
   * SBMLDocument::setLevelAndVersion(@if java long, long, boolean@endif) is called.
   *
   * This method works by adding or subtracting consistency checks from the
   * set of all possible checks that may be performed to avoid conversion
   * to or from an invalid document.  This method may need to be called 
   * multiple times in
   * order to achieve the desired combination of checks.  The first
   * argument (@p category) in a call to this method indicates the category
   * of consistency/error checks that are to be turned on or off, and the
   * second argument (@p apply, a boolean) indicates whether to turn it on
   * (value of @c true) or off (value of @c false).
   *
   * @if clike
   * The possible categories (values to the argument @p category) are the
   * set of values from the enumeration #SBMLErrorCategory_t.
   * The following are the possible choices:
   * @endif@if java
   * The possible categories (values to the argument @p category) are the
   * set of constants whose names begin with the characters <code>LIBSBML_CAT_</code>
   * in the interface class {@link libsbmlConstants}.
   * The following are the possible choices:
   * @endif@if python 
   * The possible categories (values to the argument @p category) are the
   * set of constants whose names begin with the characters <code>LIBSBML_CAT_</code>
   * in the interface class @link libsbml libsbml@endlink.
   * The following are the possible choices:
   * @endif@~
   * <ul>
   * <li> @sbmlconstant{LIBSBML_CAT_GENERAL_CONSISTENCY, SBMLErrorCategory_t}: 
   * Correctness and consistency of specific SBML language constructs.
   * Performing this set of checks is highly recommended.  With respect to
   * the SBML specification, these concern failures in applying the
   * validation rules numbered 2xxxx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_IDENTIFIER_CONSISTENCY, SBMLErrorCategory_t}:
   * Correctness and consistency of identifiers used for model entities.  An
   * example of inconsistency would be using a species identifier in a
   * reaction rate formula without first having declared the species.  With
   * respect to the SBML specification, these concern failures in applying
   * the validation rules numbered 103xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_UNITS_CONSISTENCY, SBMLErrorCategory_t}:
   * Consistency of measurement units associated with quantities in a model.
   * With respect to the SBML specification, these concern failures in
   * applying the validation rules numbered 105xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_MATHML_CONSISTENCY, SBMLErrorCategory_t}:
   * Syntax of MathML constructs.  With respect to the SBML specification,
   * these concern failures in applying the validation rules numbered 102xx
   * in the Level&nbsp;2 Versions&nbsp;2&ndash;4 and Level&nbsp;3
   * Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_SBO_CONSISTENCY, SBMLErrorCategory_t}: 
   * Consistency and validity of %SBO identifiers (if any) used in the model.
   * With respect to the SBML specification, these concern failures in
   * applying the validation rules numbered 107xx in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_OVERDETERMINED_MODEL, SBMLErrorCategory_t}:
   * Static analysis of whether the system of equations implied by a model is
   * mathematically overdetermined.  With respect to the SBML specification,
   * this is validation rule #10601 in the Level&nbsp;2
   * Versions&nbsp;2&ndash;4 and Level&nbsp;3 Version&nbsp;1 specifications.
   * 
   * <li> @sbmlconstant{LIBSBML_CAT_MODELING_PRACTICE, SBMLErrorCategory_t}:
   * Additional checks for recommended good modeling practice. (These are
   * tests performed by libSBML and do not have equivalent SBML validation
   * rules.)
   * </ul>
   * 
   * <em>By default, all validation checks are applied</em> to the model in
   * an SBMLDocument object @em unless
   * SBMLDocument::setConsistencyChecks(@if java int, boolean@endif)
   * is called to indicate that only a subset should be applied.  Further,
   * this default (i.e., performing all checks) applies separately to
   * <em>each new SBMLDocument object</em> created.  In other words, each
   * time a model is read using SBMLReader::readSBML(@if java String@endif),
   * SBMLReader::readSBMLFromString(@if java String@endif),
   * or the global functions readSBML() and readSBMLFromString(), a new
   * SBMLDocument is created and for that document, a call to
   * SBMLDocument::checkConsistency() will default to applying all possible checks.
   * Calling programs must invoke
   * SBMLDocument::setConsistencyChecks(@if java int, boolean@endif)
   * for each such new model if they wish to change the consistency checks
   * applied.
   * 
   * @param category a value drawn from @if clike #SBMLErrorCategory_t@else
   * the set of SBML error categories@endif@~ indicating the consistency
   * checking/validation to be turned on or off.
   *
   * @param apply a boolean indicating whether the checks indicated by
   * @p category should be applied or not.
   *
   * @see SBMLDocument::setLevelAndVersion(@if java long, long, boolean@endif)
   */
  void setConsistencyChecksForConversion(SBMLErrorCategory_t category, 
                                         bool apply);


  /**
   * Performs consistency checking and validation on this SBML document.
   *
   * If this method returns a nonzero value (meaning, one or more
   * consistency checks have failed for SBML document), the failures may be
   * due to warnings @em or errors.  Callers should inspect the severity
   * flag in the individual SBMLError objects returned by
   * SBMLDocument::getError(@if java long@endif) to determine the nature of the failures.
   *
   * @param writeDocument by default checkConsistency will write the document
   *                      in order to determine all errors for the document. 
   *                      This will also clear the error log. Setting this
   *                      parameter to false will skip this additional step
   *                      but might not find all errors.
   *
   * @return the number of failed checks (errors) encountered.
   *
   * @see SBMLDocument::checkInternalConsistency()
   */
  unsigned int checkConsistency (bool writeDocument=false);

  
  /**
   * Performs consistency checking on libSBML's internal representation of 
   * an SBML Model.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   *
   * The distinction between this method and
   * SBMLDocument::checkConsistency() is that this method reports on
   * fundamental syntactic and structural errors that violate the XML
   * Schema for SBML; by contrast, SBMLDocument::checkConsistency()
   * performs more elaborate model verifications and also validation
   * according to the validation rules written in the appendices of the
   * SBML Level&nbsp;2 Versions&nbsp;2&ndash;4 specification documents.
   * 
   * @see SBMLDocument::checkConsistency()
   */
  unsigned int checkInternalConsistency ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;1 and can be converted
   * to Level&nbsp;1.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL1Compatibility ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;2 Version&nbsp;1 and can
   * be converted to Level&nbsp;2 Version&nbsp;1.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL2v1Compatibility ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;2 Version&nbsp;2 and can
   * be converted to Level&nbsp;2 Version&nbsp;2.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL2v2Compatibility ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;2 Version&nbsp;3 and can
   * be converted to Level&nbsp;2 Version&nbsp;3.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL2v3Compatibility ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;2 Version&nbsp;4 and can
   * be converted to Level&nbsp;2 Version&nbsp;4.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL2v4Compatibility ();


  /**
   * Performs a set of consistency checks on the document to establish
   * whether it is compatible with SBML Level&nbsp;3 Version&nbsp;1 and can
   * be converted to Level&nbsp;3 Version&nbsp;1.
   *
   * Callers should query the results of the consistency check by calling
   * SBMLDocument::getError(@if java long@endif).
   *
   * @return the number of failed checks (errors) encountered.
   */
  unsigned int checkL3v1Compatibility ();


  /** 
   * @return the current list of selected validators
   */
  unsigned char getApplicableValidators() const;


  /** 
   * @return the current list of selected validators for conversion
   */
  unsigned char getConversionValidators() const;


  /** 
   * Set the current list of validators to be applied
   *
   * @param appl the mask of validators to be applied
   */  
  void setApplicableValidators(unsigned char appl);


  /** 
   * Set the current list of conversion validators to be applied
   *
   * @param appl the mask of validators to be applied
   */
  void setConversionValidators(unsigned char appl);


  /**
   * Constructor.
   */
  SBMLInternalValidator();


  /**
   * Copy constructor; creates a copy of an SBMLInternalValidator object.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SBMLInternalValidator(const SBMLInternalValidator& orig);


  /**
   * Creates and returns a deep copy of this SBMLValidator object.
   *
   * @return the (deep) copy of this SBMLValidator object.
   */
  virtual SBMLValidator* clone() const;


  /**
   * Destroy this object.
   */
  virtual ~SBMLInternalValidator ();


  /** 
   * Runs the validations.
   * 
   * This runs the validations that were previously enabled via methods such as
   * SBMLDocument::setConsistencyChecks(@if java int, boolean@endif).
   *
   * @return the number of validation failures that occurred.  The objects
   * describing the actual failures can be retrieved using getFailures().
   */
  virtual unsigned int validate();


protected:
  /** @cond doxygenLibsbmlInternal */

  unsigned char mApplicableValidators;
  unsigned char mApplicableValidatorsForConversion;

  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */

  /** @endcond */


};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

  
#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLInternalValidator_h */

