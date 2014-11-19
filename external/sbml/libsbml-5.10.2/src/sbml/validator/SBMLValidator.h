/**
 * @file    SBMLValidator.h
 * @brief   Definition of SBMLValidator, the base class for user callable SBML validators.
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
 * @class SBMLValidator
 * @sbmlbrief{core} Base class for SBML validators.
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
 *
 * Users of libSBML may already be familiar with the facilities encompassed
 * by the validation system, in the form of the consistency-checking methods
 * defined on SBMLDocument.  The methods SBMLDocument::setConsistencyChecks(@if java int, boolean@endif),
 * SBMLDocument::checkConsistency(), SBMLDocument::checkInternalConsistency()
 * and other method of that sort are in fact implemented via SBMLValidator,
 * specifically as methods on the class SBMLInternalValidator.
 *
 * Authors may use SBMLValidator as the base class for their own validator
 * extensions to libSBML.  The class SBMLInternalValidator may serve as a
 * code example for how to implement such things.
 */

#ifndef SBMLValidator_h
#define SBMLValidator_h

#include <sbml/SBMLNamespaces.h>
#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/SBMLTypes.h>
#endif


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN

  class SBMLErrorLog;

class LIBSBML_EXTERN SBMLValidator
{
public:

  /**
   * Creates a new SBMLValidator.
   */
  SBMLValidator ();


  /**
   * Copy constructor; creates a copy of an SBMLValidator object.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SBMLValidator(const SBMLValidator& orig);


  /**
   * Destroy this object.
   */
  virtual ~SBMLValidator ();


  /**
   * Assignment operator for SBMLValidator.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLValidator& operator=(const SBMLValidator& rhs);


  /**
   * Creates and returns a deep copy of this SBMLValidator object.
   *
   * @return the (deep) copy of this SBMLValidator object.
   */
  virtual SBMLValidator* clone() const;


  /**
   * Returns the current SBML document in use by this validator.
   * 
   * @return the current SBML document
   *
   * @see setDocument(@if java SBMLDocument@endif)
   */
  virtual SBMLDocument* getDocument();


  /**
   * Returns the current SBML document in use by this validator.
   * 
   * @return a const reference to the current SBML document
   * 
   * @see setDocument(@if java SBMLDocument@endif)
   */
  virtual const SBMLDocument* getDocument() const;


  /** 
   * Sets the current SBML document to the given SBMLDocument object.
   * 
   * @param doc the document to use for this validation
   * 
   * @return an integer value indicating the success/failure of the
   * validation.  @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The possible values returned by this
   * function are
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see getDocument()
   */
  virtual int setDocument(const SBMLDocument* doc);


  /** 
   * Runs this validator on the current SBML document.
   *
   * @return an integer value indicating the success/failure of the
   * validation.  @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The possible values returned by this
   * function are determined by the specific subclasses of this class.
   */
  virtual unsigned int validate(); 

  
  /**
   * Clears this validator's list of failures.
   *
   * If you are validating multiple SBML documents with the same validator,
   * call this method after you have processed the list of failures from
   * the last validation run and before validating the next document.
   *
   * @if clike @see getFailures() @endif@~
   */
  virtual void clearFailures ();


  /**
   * Returns a list of SBMLError objects (if any) that were logged by the
   * last run of this validator.
   * 
   * @return a list of errors, warnings and other diagnostics logged during
   * validation.
   *
   * @see clearFailures()
   */
  const std::vector<SBMLError>& getFailures () const;


  /**
   * Adds the given failure to this list of Validators failures.
   *
   * @param err an SBMLError object representing an error or warning
   *
   * @if clike @see getFailures() @endif@~
   */
  void logFailure (const SBMLError& err);


  /**
   * Validates the given SBMLDocument object.
   *
   * This is identical to calling setDocument(@if java SBMLDocument @endif)
   * followed by validate().
   *
   * @param d the SBML document to validate
   *
   * @return the number of validation failures that occurred.  The objects
   * describing the actual failures can be retrieved using getFailures().
   */
  unsigned int validate (const SBMLDocument& d);


  /**
   * Validates the SBML document located at the given @p filename.
   *
   * This is a convenience method that saves callers the trouble of
   * using SBMLReader to read the document first.
   *
   * @param filename the path to the file to be read and validated.
   *
   * @return the number of validation failures that occurred.  The objects
   * describing the actual failures can be retrieved using getFailures().
   */
  unsigned int validate (const std::string& filename);


  /**
   * Returns the list of errors or warnings logged during parsing,
   * consistency checking, or attempted translation of this model.
   *
   * Note that this refers to the SBMLDocument object's error log (i.e.,
   * the list returned by SBMLDocument::getErrorLog()).  @em That list of
   * errors and warnings is @em separate from the validation failures
   * tracked by this validator (i.e., the list returned by getFailures()).
   * 
   * @return the SBMLErrorLog used for the SBMLDocument
   * 
   * @if clike @see getFailures() @endif@~
   */
  SBMLErrorLog* getErrorLog ();


  /**
   * Returns the Model object stored in the SBMLDocument.
   *
   * It is important to note that this method <em>does not create</em> a
   * Model instance.  The model in the SBMLDocument must have been created
   * at some prior time, for example using SBMLDocument::createModel() 
   * or SBMLDocument::setModel(@if java Model@endif).
   * This method returns @c NULL if a model does not yet exist.
   * 
   * @return the Model contained in this validator's SBMLDocument object.
   *
   * @see SBMLDocument::setModel(@if java Model@endif)
   * @see SBMLDocument::createModel()
   */
  const Model* getModel () const;


  /**
   * Returns the Model object stored in the SBMLDocument.
   *
   * It is important to note that this method <em>does not create</em> a
   * Model instance.  The model in the SBMLDocument must have been created
   * at some prior time, for example using SBMLDocument::createModel() 
   * or SBMLDocument::setModel(@if java Model@endif).
   * This method returns @c NULL if a model does not yet exist.
   * 
   * @return the Model contained in this validator's SBMLDocument object.
   *
   * @see SBMLDocument::setModel(@if java Model@endif)
   * @see SBMLDocument::createModel()
   */
  Model* getModel ();


  /** 
   * Returns the number of failures encountered in the last validation run.
   * 
   * This method returns the number of failures logged by this validator.
   * This number only reflects @em this validator's actions; the number may
   * not be the same as the number of errors and warnings logged on the
   * SBMLDocument object's error log (i.e., the object returned by
   * SBMLDocument::getErrorLog()), because other parts of libSBML may log
   * errors and warnings beyond those found by this validator.
   *
   * @return the number of errors logged by this validator. 
   */
  unsigned int getNumFailures() const;


  /** 
   * Returns the failure object at index n in this validator's list of
   * failures logged during the last run.
   *
   * Callers should use getNumFailures() first, to find out the number
   * of entries in this validator's list of failures.
   *
   * @param n an integer indicating the index of the object to return from
   * the failures list; index values start at 0.
   * 
   * @return the failure at the given index number.
   *
   * @see getNumFailures()
   */
  SBMLError* getFailure (unsigned int n) const;


#ifndef SWIG

#endif // SWIG



protected:
  /** @cond doxygenLibsbmlInternal */
  std::vector<SBMLError>  mFailures;
  SBMLDocument *   mDocument;
  friend class SBMLDocument;
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
#endif  /* SBMLValidator_h */


