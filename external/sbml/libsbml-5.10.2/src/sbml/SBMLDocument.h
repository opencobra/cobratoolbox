/**
 * @file    SBMLDocument.h
 * @brief   Top-level container for an SBML Model and associated data.
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * @class SBMLDocument
 * @sbmlbrief{core} Overall SBML container object.
 *
 * @if clike LibSBML uses the class SBMLDocument as a
 * top-level container for storing SBML content and data associated with it
 * (such as warnings and error messages).  The two primary means of reading
 * an SBML model, SBMLReader::readSBML() and
 * SBMLReader::readSBMLFromString(), both return a pointer to an
 * SBMLDocument object.  From there, callers can inquire about any errors
 * encountered (e.g., using SBMLDocument::getNumErrors()), access the Model
 * object, and perform other actions such as consistency-checking and model
 * translation.
 * @endif@if python LibSBML uses the class SBMLDocument as a
 * top-level container for storing SBML content and data associated with it
 * (such as warnings and error messages).  The two primary means of reading
 * an SBML model, SBMLReader::readSBML() and
 * SBMLReader::readSBMLFromString(), both return a pointer to an
 * SBMLDocument object.  From there, callers can inquire about any errors
 * encountered (e.g., using SBMLDocument::getNumErrors()), access the Model
 * object, and perform other actions such as consistency-checking and model
 * translation.
 * @endif@if java LibSBML uses the class SBMLDocument as a top-level
 * container for storing SBML content and data associated with it (such as
 * warnings and error messages).  The two primary means of reading an SBML
 * model, SBMLReader::readSBML(String filename) and
 * SBMLReader::readSBMLFromString(String xml), both return an SBMLDocument
 * object.  From there, callers can inquire about any errors encountered
 * (e.g., using SBMLDocument::getNumErrors()), access the Model object, and
 * perform other actions such as consistency-checking and model
 * translation.
 * @endif@~
 * 
 * When creating fresh models programmatically, the starting point is
 * typically the creation of an SBMLDocument object instance.  The
 * SBMLDocument constructor accepts arguments for the SBML Level and
 * Version of the model to be created.  After creating the SBMLDocument
 * object, calling programs then typically call SBMLDocument::createModel()
 * almost immediately, and then proceed to call the methods on the Model
 * object to fill out the model's contents.
 *
 * SBMLDocument corresponds roughly to the class <i>Sbml</i> defined in the
 * SBML Level&nbsp;2 specification and <i>SBML</i> in the Level&nbsp;3
 * specification.  It does not have a direct correspondence in SBML
 * Level&nbsp;1.  (However, to make matters simpler for applications,
 * libSBML creates an SBMLDocument no matter whether the model is
 * Level&nbsp;1, Level&nbsp;2 or Level&nbsp;3.)  In its barest form, when written out in
 * XML format for (e.g.) SBML Level&nbsp;2 Version&nbsp;4, the corresponding
 * structure is the following:
 * @verbatim
<sbml xmlns="http://www.sbml.org/sbml/level2/version4" level="2" version="4">
  ...
</sbml>@endverbatim
 * 
 * SBMLDocument is derived from SBase, and therefore contains the usual SBase
 * attributes (in SBML Level&nbsp;2 and Level&nbsp;3) of "metaid" and "sboTerm", as
 * well as the subelements "notes" and "annotation".  It also contains the
 * attributes "level" and "version" indicating the Level and Version of the
 * SBML data structure.  These can be accessed using the methods defined by
 * the SBase class for that purpose.
 *
 * @section checking Checking consistency and adherence to SBML specifications
 *
 * One of the most important features of libSBML is its ability to perform
 * SBML validation to ensure that a model adheres to the SBML specification
 * for whatever Level+Version combination the model uses.  SBMLDocument
 * provides the methods for running consistency-checking and validation
 * rules on the SBML content.
 *
 * First, a brief explanation of the rationale is in order.  In libSBML
 * versions up to and including the version&nbsp;3.3.x series, the
 * individual methods for creating and setting attributes and other
 * components were quite lenient, and allowed a caller to compose SBML
 * entities that might not, in the end, represent valid SBML.  This allowed
 * applications the freedom to do things such as save incomplete models
 * (which is useful when models are being developed over long periods of
 * time).  In the version&nbsp;4.x series, libSBML is somewhat stricter,
 * but still permits structures to be created independently and the results
 * to be combined in a separate step.  In all these cases, it means that a
 * separate validation step is necessary when a calling program finally
 * wants to finish a complete SBML document.
 *
 * The primary interface to this validation facility is SBMLDocument's
 * SBMLDocument::checkInternalConsistency() and
 * SBMLDocument::checkConsistency().  The former verifies the basic
 * internal consistency and syntax of an SBML document, and the latter
 * implements more elaborate validation rules (both those defined by the
 * SBML specifications, as well as additional rules offered by libSBML).
 *
 * @if clike The checks performed by SBMLDocument::checkInternalConsistency() are
 * hardwired and cannot be changed by calling programs, but the validation
 * performed by SBMLDocument::checkConsistency() is under program control
 * using the method SBMLDocument::setConsistencyChecks().  Applications can
 * selectively disable specific kinds of checks that they may not be
 * interested in, by calling SBMLDocument::setConsistencyChecks() with
 * appropriate parameters.
 * @endif@if python The checks performed by SBMLDocument::checkInternalConsistency() are
 * hardwired and cannot be changed by calling programs, but the validation
 * performed by SBMLDocument::checkConsistency() is under program control
 * using the method SBMLDocument::setConsistencyChecks().  Applications can
 * selectively disable specific kinds of checks that they may not be
 * interested in, by calling SBMLDocument::setConsistencyChecks() with
 * appropriate parameters.
 * @endif@if java The checks performed by SBMLDocument::checkInternalConsistency() are
 * hardwired and cannot be changed by calling programs, but the validation
 * performed by SBMLDocument::checkConsistency() is under program control
 * using the method SBMLDocument::setConsistencyChecks(int categ, boolean
 * onoff).  Applications can selectively disable specific kinds of checks
 * that they may not be interested by calling
 * SBMLDocument::setConsistencyChecks(int categ, boolean onoff) with
 * appropriate parameters.
 * @endif@~
 *
 * These methods have slightly different relevance depending on whether a
 * model is created programmaticaly from scratch, or whether it is read in
 * from a file or data stream.  The following list summarizes the possible
 * scenarios.
 *
 * <em>Scenario 1: Creating a model from scratch</em>.  Before writing out
 * the model, 
 *
 * @li Call SBMLDocument::checkInternalConsistency(), then inquire about
 * the results by calling SBMLDocument::getNumErrors()
 *
 * @li Call @if java SBMLDocument::setConsistencyChecks(int categ, boolean
 * onoff) @else SBMLDocument::setConsistencyChecks() @endif@~ to configure
 * which checks will be performed by SBMLDocument::checkConsistency()
 *
 * @li Call SBMLDocument::checkConsistency(), then inquire about the results by
 * calling SBMLDocument::getNumErrors()
 *
 * <em>Scenario 2: Reading a model from a file or data stream.</em> After
 * reading the model,
 * 
 * @li Basic consistency checks will have been performed automatically by
 * libSBML upon reading the content, so you only need to inquire about the
 * results by using SBMLDocument::getNumErrors()
 * 
 * @li Call @if java SBMLDocument::setConsistencyChecks(int categ, boolean
 * onoff) @else SBMLDocument::setConsistencyChecks() @endif@~ to configure
 * which checks are performed by SBMLDocument::checkConsistency()
 * 
 * @li Call SBMLDocument::checkConsistency(), then inquire about the results
 * by calling SBMLDocument::getNumErrors()
 *
 * @if clike An example of using the consistency-checking
 * and validation facilities is provided in this manual in the
 * section @ref libsbml-example. @endif@~
 * 
 * @section converting Converting documents between Levels and Versions of SBML
 *
 * LibSBML provides facilities for limited translation of SBML between
 * Levels and Versions of the SBML specifications.  The method for doing is
 * is @if java SBMLDocument::setLevelAndVersion(long lev, long ver, boolean strict) @else setLevelAndVersion() @endif.  In 
 * general, models can be converted upward without difficulty (e.g., from
 * SBML Level&nbsp;1 to Level&nbsp;2, or from an earlier Version of
 * Level&nbsp;2 to the latest Version of Level&nbsp;2).  Sometimes models
 * can be translated downward as well, if they do not use constructs
 * specific to more advanced Levels of SBML.
 *
 * Calling @if java SBMLDocument::setLevelAndVersion(long lev, long ver, boolean strict) @else SBMLDocument::setLevelAndVersion() @endif@~ will not @em necessarily lead
 * to a successful conversion.  The method will return a boolean value
 * to indicate success or failure.  Callers must check the error log (see 
 * next section) attached to the SBMLDocument object after calling
 * @if java SBMLDocument::setLevelAndVersion(long lev, long ver) @else SBMLDocument::setLevelAndVersion() @endif@~ in order to assess whether any
 * problems arose.
 *
 * If an application is interested in translating to a lower Level and/or
 * Version of SBML within a Level, the following methods allow for prior
 * assessment of whether there is sufficient compatibility to make a
 * translation possible:
 *
 * @li SBMLDocument::checkL1Compatibility(),
 * @li SBMLDocument::checkL2v1Compatibility(),
 * @li SBMLDocument::checkL2v2Compatibility(),
 * @li SBMLDocument::checkL2v3Compatibility(), 
 * @li SBMLDocument::checkL2v4Compatibility(), and
 * @li SBMLDocument::checkL3v1Compatibility().
 * 
 * Some changes between Versions of SBML Level&nbsp;2 may lead to
 * unexpected behaviors when attempting conversions in either direction.
 * For example, SBML Level&nbsp;2 Version&nbsp;4 relaxed the requirement
 * for consistency in units of measurement between expressions annd
 * quantities in a model.  As a result, a model written in Version&nbsp;4,
 * if converted to Version&nbsp;3 with no other changes, may fail
 * validation as a Version&nbsp;3 model because Version&nbsp;3 imposed
 * stricter requirements on unit consistency.
 *
 * Other changes between SBML Level 2 and Level 3 make downward conversions
 * challenging.  In some cases, it means that a model converted to
 * Level&nbsp;2 from Level&nbsp;3 will contain attributes that were not
 * explicitly given in the Level&nbsp;3 model, because in Level&nbsp;2
 * these attributes may have been optional or have default values.
 * 
 * @section errors Error handling
 *
 * Upon reading a model, SBMLDocument logs any problems encountered while
 * reading the model from the file or data stream.  The log contains
 * objects that record diagnostic information about any notable issues that
 * arose.  Whether the problems are warnings or errors, they are both
 * reported through a single common interface involving the object class
 * SBMLError.
 *
 * The methods SBMLDocument::getNumErrors(), @if java SBMLDocument::getError(long n) @else SBMLDocument::getError() @endif@~ and
 * SBMLDocument::printErrors() allow callers to interact with the warnings
 * or errors logged.  Alternatively, callers may retrieve the entire log as
 * an SBMLErrorLog object using the method SBMLDocument::getErrorLog().
 * The SBMLErrorLog object provides some alternative methods for
 * interacting with the set of errors and warnings.  In either case,
 * applications typically should first call SBMLDocument::getNumErrors() to
 * find out if any issues have been logged after specific libSBML
 * operations such as the ones discussed in the sections above.  If they
 * have, then an application will should proceed to inspect the individual
 * reports using either the direct interfaces on SBMLDocument or using the
 * methods on the SBMLErrorLog object.
 *
 * @if clike An example of using the error facility is
 * provided in this manual in the
 * section @ref libsbml-example. @endif@~
 * 
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_sbmldocument_default_level
 *
 * @par
 * This "default Level" corresponds to the most recent SBML specification
 * Level available at the time libSBML version @htmlinclude
 * libsbml-version.html was released.  The default Level is used by
 * SBMLDocument if no Level is explicitly specified at the time of the
 * construction of an SBMLDocument instance.
 *
 * @class doc_sbmldocument_default_version
 *
 * @par
 * This "default Version" corresponds to the most recent Version within the
 * most recent Level of SBML available at the time libSBML version
 * @htmlinclude libsbml-version.html was released.  The default Version is
 * used by SBMLDocument if no Version is explicitly specified at the time of
 * the construction of an SBMLDocument instance.
 * 
 */

#ifndef SBMLDocument_h
#define SBMLDocument_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBase.h>
#include <sbml/SBMLTransforms.h>


#ifdef __cplusplus


#include <iosfwd>
#include <map>

LIBSBML_CPP_NAMESPACE_BEGIN

class Model;
class ConversionProperties;
class SBMLVisitor;
class XMLError;

class SBMLValidator;
class SBMLInternalValidator;

/** @cond doxygenLibsbmlInternal */
/* Internal constants for setting/unsetting particular consistency checks. */

#define IdCheckON         0x01
#define IdCheckOFF        0xfe
#define SBMLCheckON       0x02
#define SBMLCheckOFF      0xfd
#define SBOCheckON        0x04
#define SBOCheckOFF       0xfb
#define MathCheckON       0x08
#define MathCheckOFF      0xf7
#define UnitsCheckON      0x10
#define UnitsCheckOFF     0xef
#define OverdeterCheckON  0x20
#define OverdeterCheckOFF 0xdf
#define PracticeCheckON   0x40
#define PracticeCheckOFF  0xbf
#define AllChecksON       0x7f

/** @endcond */


class LIBSBML_EXTERN SBMLDocument: public SBase
{
public:

  /**
   * The default SBML Level of new SBMLDocument objects.
   *
   * @copydetails doc_sbmldocument_default_level
   *
   * @return an integer indicating the most recent SBML specification Level
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike getDefaultVersion() @else SBMLDocument::getDefaultVersion() @endif@~
   */
  static unsigned int getDefaultLevel ();


  /**
   * The default Version of new SBMLDocument objects.
   *
   * @copydetails doc_sbmldocument_default_version 
   *
   * @return an integer indicating the most recent SBML specification
   * Version
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike getDefaultLevel() @else SBMLDocument::getDefaultLevel() @endif@~
   */
  static unsigned int getDefaultVersion ();


  /**
   * Creates a new SBMLDocument, optionally with given values for the SBML
   * Level and Version.
   *
   * If <em>both</em> the SBML Level and Version attributes are not
   * specified, the SBML document is treated as having the latest Level and
   * Version of SBML as determined by SBMLDocument::getDefaultLevel() and
   * SBMLDocument::getDefaultVersion(); <em>however</em>, the SBMLDocument
   * object is otherwise left blank.  In particular, the blank SBMLDocument
   * object has no associated XML attributes, including (but not limited
   * to) an XML namespace declaration.  The XML namespace declaration is
   * not added until the model is written out, <em>or</em> the method
   * SBMLDocument::setLevelAndVersion(@if java long, long, boolean@endif)
   * is called.  This may be important to keep in mind
   * if an application needs to add additional XML namespace declarations
   * on the <code>&lt;sbml&gt;</code> element.  Application writers should
   * either provide values for @p level and @p version on the call to this
   * constructor, or else call
   * SBMLDocument::setLevelAndVersion(@if java long, long, boolean@endif)
   * shortly after creating the SBMLDocument object.
   *
   * @param level an integer for the SBML Level
   *
   * @param version an integer for the Version within the SBML Level
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see SBMLDocument::setLevelAndVersion(@if java long, long, boolean@endif)
   * @see getDefaultLevel()
   * @see getDefaultVersion()
   */
  SBMLDocument (unsigned int level = 0, unsigned int version = 0);


  /**
   * Creates a new SBMLDocument using the given SBMLNamespaces object 
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   */
  SBMLDocument (SBMLNamespaces* sbmlns);


  /**
   * Destroys this SBMLDocument.
   */
  virtual ~SBMLDocument ();


  /**
   * Copy constructor; creates a copy of this SBMLDocument.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SBMLDocument (const SBMLDocument& orig);


  /**
   * Assignment operator for SBMLDocument.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLDocument& operator=(const SBMLDocument& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of SBMLDocument.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this SBMLDocument object.
   *
   * @return the (deep) copy of this SBMLDocument object.
   */
  virtual SBMLDocument* clone () const;


  /**
   * Returns the Model object stored in this SBMLDocument.
   *
   * It is important to note that this method <em>does not create</em> a
   * Model instance.  The model in the SBMLDocument must have been created
   * at some prior time, for example using SBMLDocument::createModel() 
   * or SBMLDocument::setModel(@if java Model@endif).
   * This method returns @c NULL if a model does not yet exist.
   * 
   * @return the Model contained in this SBMLDocument.
   *
   * @see createModel()
   */
  const Model* getModel () const;


  /**
   * Returns the Model object stored in this SBMLDocument.
   *
   * It is important to note that this method <em>does not create</em> a
   * Model instance.  The model in the SBMLDocument must have been created
   * at some prior time, for example using SBMLDocument::createModel() 
   * or SBMLDocument::setModel(@if java Model@endif).
   * This method returns @c NULL if a model does not yet exist.
   * 
   * @return the Model contained in this SBMLDocument.
   *
   * @see createModel()
   */
  Model* getModel ();


  /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * @param id string representing the id of objects to find
   *
   * @return pointer to the first element found with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);
  
  
  /**
   * Returns the first child element it can find with the given @p metaid, or
   * itself if it has the given @p metaid, or @c NULL if no such object is
   * found.
   *
   * @param metaid string representing the metaid of objects to find
   *
   * @return pointer to the first element found with the given @p metaid.
   */
  virtual SBase* getElementByMetaId(const std::string& metaid);
  
  
  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);
  
  
 /**
   * Removes FunctionDefinition constructs from the document and expands
   * any instances of their use within <code>&lt;math&gt;</code> elements.
   *
   * For example, suppose a Model contains a FunctionDefinition with
   * identifier @c "f" representing the math expression: <em>f(x, y) = x *
   * y</em>.  Suppose further that there is a reaction in which the
   * <code>&lt;math&gt;</code> element of the KineticLaw object contains
   * <code>f(s, p)</code>, where @c s and @c p are other identifiers
   * defined in the model.  The outcome of invoking this method is that the
   * <code>&lt;math&gt;</code> of the KineticLaw now represents the
   * expression <em>s * p</em> and the model no longer contains any
   * FunctionDefinition objects.
   * 
   * @return bool @c true if the transformation was successful, 
   * @c false, otherwise.
   *
   * @note This function will check the consistency of a model before
   * attemptimg the transformation.  If the model is not valid SBML, the
   * transformation will not be performed and the function will return @c
   * false.
   */
  bool expandFunctionDefinitions();


  /**
   * Removes InitialAssignment constructs from the document and
   * replaces them with appropriate values.
   *
   * For example, suppose a Model contains a InitialAssignment to a symbol
   * @c "k" where @c "k" is the identifier of a Parameter.  The outcome of
   * invoking this method is that the "value" attribute of the Parameter
   * definition is set to the result calculated using the InitialAssignment
   * object's <code>&lt;math&gt;</code> formula, and the corresponding
   * InitialAssignment is then removed from the Model.
   * 
   * @return bool @c true if the transformation was successful, 
   * @c false, otherwise.
   *
   * @note This function will check the consistency of a model before
   * attemptimg the transformation.  If the model is not valid SBML, the
   * transformation will not be performed and the function will return @c
   * false.  As part of that process, this method will check that it has
   * values for any components referred to by the <code>&lt;math&gt;</code>
   * elements of InitialAssignment objects.  In cases where not all of the
   * values have been declared (e.g., if the mathematical expression refers
   * to model entities that have no declared values), the InitialAssignment
   * in question will @em not be removed and this method will return @c
   * false.
   */
  bool expandInitialAssignments();


  /**
   * Sets the SBML Level and Version of this SBMLDocument instance,
   * attempting to convert the model as needed.
   *
   * This method is the principal way in libSBML to convert models between
   * Levels and Versions of SBML.  Generally, models can be converted
   * upward without difficulty (e.g., from SBML Level&nbsp;1 to
   * Level&nbsp;2, or from an earlier Version of Level&nbsp;2 to the latest
   * Version of Level&nbsp;2).  Sometimes models can be translated downward
   * as well, if they do not use constructs specific to more advanced
   * Levels of SBML.
   *
   * Before calling this method, callers may check compatibility directly
   * using the methods SBMLDocument::checkL1Compatibility(),
   * SBMLDocument::checkL2v1Compatibility(),
   * SBMLDocument::checkL2v2Compatibility(),
   * SBMLDocument::checkL2v3Compatibility(),
   * SBMLDocument::checkL2v4Compatibility(), and
   * SBMLDocument::checkL3v1Compatibility().
   * 
   * The valid combinations of SBML Level and Version as of this release
   * of libSBML are the following: 
   * <ul>
   * <li> Level&nbsp;1 Version&nbsp;2
   * <li> Level&nbsp;2 Version&nbsp;1
   * <li> Level&nbsp;2 Version&nbsp;2
   * <li> Level&nbsp;2 Version&nbsp;3
   * <li> Level&nbsp;2 Version&nbsp;4
   * <li> Level&nbsp;3 Version&nbsp;1
   * </ul>
   * 
   * Strict conversion applies the additional criteria that both the
   * source and the target model must be consistent SBML.  Users can
   * control the consistency checks that are applied using the
   * SBMLDocument::setConsistencyChecksForConversion(@if java int, boolean@endif) method.  If either
   * the source or the potential target model have validation errors, the
   * conversion is not performed.  When a strict conversion is successful,
   * the underlying SBML object model is altered to reflect the new level
   * and version.  Thus, information that cannot be converted
   * (e.g. sboTerms) will be lost.
   * 
   * @param level the desired SBML Level
   *  
   * @param version the desired Version within the SBML Level
   *
   * @param strict boolean indicating whether to check consistency
   * of both the source and target model when performing
   * conversion (defaults to <code> true </code>)
   *
   * @param ignorePackages boolean indicating whether the presence of
   * packages should be ignored by the conversion routine 
   * (defaults to <code> false </code>)
   *
   * @return @c true if the level and version of the document were
   * successfully set to the requested values (which may have required
   * conversion of the model), @c false otherwise.
   *
   * @note Calling this method will not @em necessarily lead to a successful
   * conversion.  If the conversion fails, it will be logged in the error
   * list associated with this SBMLDocument.  Callers should consult
   * getNumErrors() to find out if the conversion succeeded without
   * problems.  For conversions from Level&nbsp;2 to Level&nbsp;1, callers
   * can also check the Level of the model after calling this method to
   * find out whether it is Level&nbsp;1.  (If the conversion to
   * Level&nbsp;1 failed, the Level of this model will be left unchanged.)
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   * 
   * @see checkL1Compatibility()
   * @see checkL2v1Compatibility()
   * @see checkL2v2Compatibility()
   * @see checkL2v3Compatibility()
   * @see checkL2v4Compatibility()
   * @see checkL3v1Compatibility()
   * @see checkL3v1Compatibility()
   */
  bool setLevelAndVersion (unsigned int level, unsigned int version,
                           bool strict = true, bool ignorePackages = false);


  /** @cond doxygenLibsbmlInternal */
  /**
   * @param package
   * @param level
   * @param version
   */
  void updateSBMLNamespace(const std::string& package, unsigned int level, 
                           unsigned int version);
  /** @endcond */


  /**
   * Sets the Model for this SBMLDocument to a copy of the given Model.
   *
   * @param m the new Model to use.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   *
   * @see createModel()
   * @see getModel()
   */
  int setModel (const Model* m);


  /**
   * Creates a new Model inside this SBMLDocument, and returns a pointer to
   * it.
   *
   * In SBML Level&nbsp;2, the use of an identifier on a Model object is
   * optional.  This method takes an optional argument, @p sid, for setting
   * the identifier.  If not supplied, the identifier attribute on the
   * Model instance is not set.
   *
   * @param sid the identifier of the new Model to create.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see getModel()
   * @see SBMLDocument::setModel(@if java Model@endif)
   */
  Model* createModel (const std::string& sid = "");


  /**
   * Sets the location of this SBMLDocument.
   *
   * Called automatically when readSBMLFromFile is used, but may be set
   * manually as well.
   */
  void setLocationURI (const std::string& uri);


  /**
   * Get the location of this SBMLDocument.
   *
   * If this document was read from a file or had its location set manually,
   * that filename or set location will be returned, otherwise, an empty
   * string is returned.
   */
  std::string getLocationURI() const;


  /**
   * Get the location of this SBMLDocument.
   *
   * If this document was read from a file or had its location set manually,
   * that filename or set location will be returned, otherwise, an empty
   * string is returned.
   */
  std::string getLocationURI();

  
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
   * rules.)  </ul>
   * 
   * <em>By default, all validation checks are applied</em> to the model in
   * an SBMLDocument object @em unless
   * SBMLDocument::setConsistencyChecks(@if java int categ, boolean onoff@endif)
   * is called to indicate that only a subset should be applied.  Further,
   * this default (i.e., performing all checks) applies separately to
   * <em>each new SBMLDocument object</em> created.  In other words, each
   * time a model is read using SBMLReader::readSBML(@if java String filename@endif),
   * SBMLReader::readSBMLFromString(@if java String xml@endif),
   * or the global functions readSBML() and readSBMLFromString(), a new
   * SBMLDocument is created and for that document, a call to
   * SBMLDocument::checkConsistency() will default to applying all possible checks.
   * Calling programs must invoke
   * SBMLDocument::setConsistencyChecks(@if java int categ, boolean onoff@endif)
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
   * @return the number of failed checks (errors) encountered.
   *
   * @see SBMLDocument::checkInternalConsistency()
   */
  unsigned int checkConsistency ();


  /**
   * Performs consistency checking and validation on this SBML document.
   *
   * If this method returns a nonzero value (meaning, one or more
   * consistency checks have failed for SBML document), the failures may be
   * due to warnings @em or errors.  Callers should inspect the severity
   * flag in the individual SBMLError objects returned by
   * SBMLDocument::getError(@if java long@endif) to determine the nature of the failures.
   *
   * @note unlike checkConsistency this method will write the document
   *       in order to determine all errors for the document. This will 
   *       also clear the error log. 
   *
   * @return the number of failed checks (errors) encountered.
   *
   * @see SBMLDocument::checkConsistency()
   */
  unsigned int validateSBML ();


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
   * Returns the nth error or warning encountered during parsing,
   * consistency checking, or attempted translation of this model.
   *
   * Callers can use method XMLError::getSeverity() on the result to assess
   * the severity of the problem.  The possible severity levels range from
   * informational messages to fatal errors.
   *
   * @return the error or warning indexed by integer @p n, or return @c
   * NULL if <code>n &gt; (getNumErrors() - 1)</code>.
   *
   * @param n the integer index of the error sought.
   *
   * @see SBMLDocument::getNumErrors()
   */
  const SBMLError* getError (unsigned int n) const;


  /**
   * Returns the number of errors or warnings encountered during parsing,
   * consistency checking, or attempted translation of this model.
   *
   * @return the number of errors or warnings encountered
   *
   * @see SBMLDocument::getError(unsigned int n)
   */
  unsigned int getNumErrors () const;


  /**
   * Returns the number of errors or warnings encountered with the given 
   * severity during parsing,
   * consistency checking, or attempted translation of this model.
   *
   * @param severity the severity of the error sought. 
   *
   * @return the number of errors or warnings encountered
   *
   * @see SBMLDocument::getError(unsigned int n)
   */
  unsigned int getNumErrors (unsigned int severity) const;


  /**
   * Prints all the errors or warnings encountered trying to parse,
   * check, or translate this SBML document.
   *
   * It prints the text to the stream given by the optional parameter @p
   * stream.  If no parameter is given, it prints the output to the
   * standard error stream.
   *
   * If no errors have occurred, i.e., <code>getNumErrors() == 0</code>, no
   * output will be sent to the stream.
   *
   * The format of the output is:
   * @verbatim
   N error(s):
     line NNN: (id) message
 @endverbatim
   *
   * @param stream the ostream or ostringstream object indicating where
   * the output should be printed.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see getNumErrors()
   * @see getErrorLog()
   * @see SBMLDocument::getError(unsigned int n)
   */
  void printErrors (std::ostream& stream = std::cerr) const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * No-op; it is provided for consistency with the method available on
   * other libSBML object classes but has no effect on SBMLDocument.
   */
  virtual void setSBMLDocument (SBMLDocument* d);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets this SBML object to child SBML objects (if any).
   * (Creates a child-parent relationship by the parent)
   *
   * Subclasses must override this function if they define
   * one ore more child elements.
   * Basically, this function needs to be called in
   * constructor, copy constructor and assignment operator.
   *
   * @see setSBMLDocument
   * @see enablePackageInternal
   */
  virtual void connectToChild ();
  /** @endcond */


  /**
   * Converts this document using the converter that best matches
   * the given conversion properties. 
   * 
   * @param props the conversion properties to use
   * 
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_CONV_CONVERSION_NOT_AVAILABLE, OperationReturnValues_t}
   */
  virtual int convert(const ConversionProperties& props);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Enables/Disables the given package with this element and child
   * elements (if any).
   * (This is an internal implementation for enablePackage function)
   *
   * @note Subclasses of the SBML Core package in which one or more child
   * elements are defined must override this function.
   */
  virtual void enablePackageInternal(const std::string& pkgURI,const std::string& pkgPrefix, bool flag);
  /** @endcond */


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_DOCUMENT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see SBMLDocument::getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for SBMLDocument,
   * is always @c "sbml".
   * 
   * @return the name of this element, i.e., @c "sbml".
   */
  virtual const std::string& getElementName () const;


  /**
   * Returns the list of errors or warnings logged during parsing, 
   * consistency checking, or attempted translation of this model.
   * 
   * @return the SBMLErrorLog used for this SBMLDocument
   * 
   * @see SBMLDocument::getNumErrors()
   */
  SBMLErrorLog* getErrorLog ();


  /**
   * Returns a constant pointer to the list of errors or warnings 
   * logged during parsing, consistency checking, or attempted translation 
   * of this model.
   * 
   * @return the SBMLErrorLog used for this SBMLDocument
   * 
   * @see SBMLDocument::getNumErrors()
   */
  const SBMLErrorLog* getErrorLog () const;


  /**
   * Returns a list of XML Namespaces associated with the XML content
   * of this SBML document.
   * 
   * @return the XML Namespaces associated with this SBML object
   */
  virtual XMLNamespaces* getNamespaces() const;


  /**
   * Set/unset default namespace to each top-level element defined in the
   * given package extension.
   *
   * This works by adding a <code>xmlns=&quot;...&quot;</code> attribute.  No
   * prefix will be written when writing elements defined in the given
   * package extension if @c true is given as second argument.
   *
   * @param package the name or URI of the package extension.
   * @param flag boolean value to indicate whether to write a namespace
   * prefix.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_PKG_UNKNOWN_VERSION, OperationReturnValues_t}
   */
  int enableDefaultNS(const std::string& package, bool flag);


  /**
   * Returns @c true if a default namespace is added to each top-level
   * element defined in the given package extension, otherwise returns
   * @c false.
   *
   * This basically checks if the attribute
   * <code>xmlns=&quot;...&quot;</code> is present.
   *   
   * @param package the name or URI of the package extension.
   *
   * @return a boolean 
   */
  bool isEnabledDefaultNS(const std::string& package);

  
  /**
   * Sets the <code>required</code> attribute value of the given package
   * extension.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   * @param flag Boolean value indicating whether the package is required.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_PKG_UNKNOWN_VERSION, OperationReturnValues_t}
   */
  int setPackageRequired(const std::string& package, bool flag);


  /**
   * Returns the <code>required</code> attribute of the given package
   * extension.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   *
   * @return Boolean flag indicating whether the package is flagged as
   * being required.
   */
  bool getPackageRequired(const std::string& package);


  /**
   * Returns @c true if the required attribute of the given package extension
   * is defined, otherwise returns @c false.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   *
   * @return a Boolean
   */
  bool isSetPackageRequired(const std::string& package);


  /**
   * Returns @c true if the given package extension is one of an ignored
   * packages, otherwise returns @c false.
   *
   * An ignored package is one that is defined to be used in this SBML
   * document, but the package is not enabled in this copy of libSBML.
   *
   * @param pkgURI the URI of the package extension.
   *
   * @return a Boolean, @c true if the package is being ignored and
   * @c false otherwise.
   */
  bool isIgnoredPackage(const std::string& pkgURI);
  
  
  /**
   * Returns @c true if the given package extension is one of an ignored
   * packages that has been disabled, otherwise returns @c false.
   *
   * An ignored package is one that is defined to be used in this SBML
   * document, but the package is not enabled in this copy of libSBML.
   * It may have been disabled to avoid reproducing the package
   * information when writing out the file.
   *
   * @param pkgURI the URI of the package extension.
   *
   * @return a Boolean, @c true if the package is being ignored and
   * @c false otherwise.
   */
  bool isDisabledIgnoredPackage(const std::string& pkgURI);
  
  
  /**
   * Sets the value of the <code>required</code> attribute for the given
   * package.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   * @param flag a Boolean value.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_PKG_UNKNOWN_VERSION, OperationReturnValues_t}
   *
   * @deprecated Replaced in libSBML 5.2.0 by
   * setPackageRequired(@if java String, boolean@endif)
   */
  int setPkgRequired(const std::string& package, bool flag);


  /**
   * Returns the <code>required</code> attribute of the given package
   * extension.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   *
   * @return a Boolean value indicating whether the package is flagged as
   * being required in this SBML document.
   *
   * @deprecated Replaced in libSBML 5.2.0 by
   * getPackageRequired(@if java String@endif)
   */
  bool getPkgRequired(const std::string& package);


  /**
   * Returns @c true if the required attribute of the given package extension
   * is defined, otherwise returns @c false.
   *
   * @note The name of package must not be given if the package is not
   * enabled.
   *
   * @param package the name or URI of the package extension.
   *
   * @return a Boolean value.
   *
   * @deprecated Replaced in libSBML 5.2.0 by
   * isSetPackageRequired(@if java String@endif)
   */
  bool isSetPkgRequired(const std::string& package);


  /**
   * Returns @c true if the given package extension is one of ignored
   * packages, otherwise returns @c false.
   *
   * An ignored package is one that is defined to be used in this SBML
   * document, but the package is not enabled in this copy of libSBML.
   *
   * @param pkgURI the URI of the package extension.
   *
   * @return a boolean
   *
   * @deprecated Replaced in libSBML 5.2.0 by
   * isIgnoredPackage(@if java String@endif)
   */
  bool isIgnoredPkg(const std::string& pkgURI);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Return the position of this element.
   *
   * @return the ordinal position of the element with respect to its
   * siblings or -1 (default) to indicate the position is not significant.
   */
  int getElementPosition () const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write out their contained
   * SBML objects as XML elements.  Be sure to call your parents
   * implementation of this method as well.
   */
  virtual void writeElements (XMLOutputStream& stream) const;


  /**
   * Validation system.
   */
  unsigned char getApplicableValidators() const;


  /**
   * Validation system.
   */
  unsigned char getConversionValidators() const;


  /**
   * Validation system.
   */
  void setApplicableValidators(unsigned char appl);


  /**
   * Validation system.
   */
  void setConversionValidators(unsigned char appl);


  /**
   * Validation system.
   */
  unsigned int getNumValidators() const;


  /**
   * Validation system.
   */
  int clearValidators();


  /**
   * Validation system.
   */
  int addValidator(const SBMLValidator* validator);


  /**
   * Validation system.
   */
  SBMLValidator* getValidator(unsigned int index);

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  //typedef std::map<std::string, bool>  PkgRequiredMap;
  //typedef PkgRequiredMap::iterator     PkgRequiredMapIter;
  typedef std::map<std::string, bool>  PkgUseDefaultNSMap;
  typedef PkgUseDefaultNSMap::iterator PkgUseDefaultNSMapIter;


  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);


  /**
   * Subclasses should override this method to get the list of
   * expected attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);


  /**
   * Subclasses should override this method to read values from the given
   * XMLAttributes set into their specific fields.  Be sure to call your
   * parents implementation of this method as well.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;

  /**
   *
   * Subclasses should override this method to write their xmlns attriubutes
   * (if any) to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   *
   */
  virtual void writeXMLNS (XMLOutputStream& stream) const;


  int mLevel;
  int mVersion;

  Model* mModel;
  std::string mLocationURI;

  SBMLErrorLog mErrorLog;

  std::list<SBMLValidator*> mValidators;
  SBMLInternalValidator *mInternalValidator;

  //PkgRequiredMap           mPkgRequiredMap;
  XMLAttributes            mRequiredAttrOfUnknownPkg;
  XMLAttributes            mRequiredAttrOfUnknownDisabledPkg;

  PkgUseDefaultNSMap       mPkgUseDefaultNSMap;

  friend class SBase;
  friend class SBMLReader;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

#include <stdio.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new, empty SBMLDocument_t structure.
 *
 * The SBML Level and Version attributes default to the most recent SBML
 * specification (at the time this libSBML was released).
 *
 * @return the SBMLDocument_t structure created
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
SBMLDocument_t *
SBMLDocument_create (void);


/**
 * Creates a new, empty SBMLDocument_t structure with given values for the
 * SBML Level and Version.
 *
 * If not specified, the SBML Level and Version attributes default to the
 * most recent SBML specification (at the time this libSBML was
 * released).
 *
 * @param level an integer for the SBML Level
 * @param version an integer for the Version within the SBML Level
 *
 * @return the SBMLDocument_t structure created
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
SBMLDocument_t *
SBMLDocument_createWithLevelAndVersion (unsigned int level, unsigned int version);


/**
 * Creates a new SBMLDocument using the given SBMLNamespaces_t structure 
 * @p sbmlns.
 *
 * @copydetails doc_what_are_sbmlnamespaces 
 *
 * @param sbmlns an SBMLNamespaces_t structure.
 *
 * @throws SBMLConstructorException
 * Thrown if the given @p level and @p version combination, or this kind
 * of SBML structure, are either invalid or mismatched with respect to the
 * parent SBMLDocument_t structure.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
SBMLDocument_t *
SBMLDocument_createWithSBMLNamespaces (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given SBMLDocument_t structure.
 *
 * @param d the SBMLDocument_t structure
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
void
SBMLDocument_free (SBMLDocument_t *d);


/**
 * Creates and returns a deep copy of the given SBMLDocument_t structure
 *
 * @param d the SBMLDocument_t structure
 * 
 * @return a (deep) copy of the SBMLDocument_t structure
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
SBMLDocument_t *
SBMLDocument_clone (const SBMLDocument_t *d);


/**
 * Returns the SBML Level of the given SBMLDocument_t structure.
 *
 * @param d the SBMLDocument_t structure
 * 
 * @return the SBML Level number
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getLevel (const SBMLDocument_t *d);


/**
 * Returns the Version within the SBML Level of the given SBMLDocument_t
 * structure.
 *
 * @param d the SBMLDocument_t structure
 * 
 * @return the version number
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getVersion (const SBMLDocument_t *d);


/**
 * Returns the Model_t structure stored in this SBMLDocument_t structure.
 *
 * @param d the SBMLDocument_t structure
 * 
 * @return the Model_t contained in this SBMLDocument_t structure.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
Model_t *
SBMLDocument_getModel (SBMLDocument_t *d);


/**
 * Removes any FunctionDefinition_t's from the document and expands
 * any instances of their use within &gt;math&lt; elements.
 *
 * For example a Model_t contains a FunctionDefinition_t with id f
 * representing the math expression: f(x, y) = x * y.
 * The math element of the KineticLaw_t uses f(s, p).
 * The outcome of the function is that the math of the KineticLaw_t
 * now represents the math expression: s * p and the model no longer
 * contains any FunctionDefinition_t's.
 * 
 * @param d the SBMLDocument_t structure
 *
 * @return true (non-zero) if the transformation was successful,
 * false (0) otherwise.
 *
 * @note This function will check the consistency of a model
 * before attemptimg the transformation.  In the case of a model
 * with invalid SBML the transformation will not be done and the
 * function will return @c false.
 * 
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_expandFunctionDefintions (SBMLDocument_t *d);


/**
 * Removes any InitialAssignment_t's from the document and replaces
 * the appropriate values.
 *
 * For example a Model_t contains a InitialAssignment_t with symbol k
 * where k is the id of a Parameter_t.
 * The outcome of the function is that the value attribute of
 * the Parameter_t is the value calculated using the math expression
 * of the InitialAssignment_t and the corresponding InitialAssignment_t
 * has been removed from the Model_t.
 * 
 * @param d the SBMLDocument_t structure
 *
 * @return true (non-zero) if the transformation was successful,
 * false (0) otherwise.
 *
 *
 * @note This function will check the consistency of a model
 * before attemptimg the transformation.  In the case of a model
 * with invalid SBML the transformation will not be done and the
 * function will return @c false.  As part of the process the 
 * function will check that it has values for any components
 * referred to by the math elements of InitialAssignment_t's.  In
 * the case where not all values have been declared the particular
 * InitialAssignment_t will not be removed and the function will 
 * return @c false.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_expandInitialAssignments (SBMLDocument_t *d);


/**
 * Sets the SBML Level and Version of this SBMLDocument_t, attempting to
 * convert the model as needed.
 *
 * This method is used to convert models between Levels and Versions of
 * SBML.  Generally, models can be converted upward without difficulty
 * (e.g., from SBML Level 1 to Level 2, or from an earlier version of
 * Level 2 to the latest version of Level 2).  Sometimes models can be
 * translated downward as well, if they do not use constructs specific to
 * more advanced Levels of SBML.
 *
 * Callers can also check compatibility directly using the methods
 * checkL1Compatibility(), checkL2v1Compatibility(), and 
 * checkL2v2Compatibility().
 * 
 * The valid combinations as of this release of libSBML are the
 * following: 
 *
 * @li Level 1 Version 1
 * @li Level 1 Version 2
 * @li Level 2 Version 1
 * @li Level 2 Version 2
 * @li Level 2 Version 3
 * @li Level 2 Version 4
 *
 * @param d the SBMLDocument_t structure
 *
 * @param level the desired SBML Level
 *
 * @param version the desired Version within the SBML Level
 *
 * @note Calling this method will not @em necessarily lead to successful
 * conversion.  If the conversion fails, it will be logged in the error
 * list associated with this SBMLDocument_t structure.  Callers should
 * consult getNumErrors() to find out if the conversion succeeded without
 * problems.  For conversions from Level 2 to Level 1, callers can also
 * check the Level of the model after calling this method to find out
 * whether it is Level 1.  (If the conversion to Level 1 failed, the Level
 * of this model will be left unchanged.)
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setLevelAndVersion (  SBMLDocument_t *d
                                 , unsigned int    level
                                 , unsigned int    version );


/**
 * Sets the SBML Level and Version of this SBMLDocument_t, attempting to
 * convert the model as needed.
 *
 * This method is used to convert models between Levels and Versions of
 * SBML.  Generally, models can be converted upward without difficulty
 * (e.g., from SBML Level 1 to Level 2, or from an earlier version of
 * Level 2 to the latest version of Level 2).  Sometimes models can be
 * translated downward as well, if they do not use constructs specific to
 * more advanced Levels of SBML.
 *
 * Callers can also check compatibility directly using the methods
 * checkL1Compatibility(), checkL2v1Compatibility(), and 
 * checkL2v2Compatibility().
 * 
 * The valid combinations as of this release of libSBML are the
 * following: 
 *
 * @li Level 1 Version 1
 * @li Level 1 Version 2
 * @li Level 2 Version 1
 * @li Level 2 Version 2
 * @li Level 2 Version 3
 * @li Level 2 Version 4
 *
 * @param d the SBMLDocument_t structure
 *
 * @param level the desired SBML Level
 *
 * @param version the desired Version within the SBML Level
 *
 * @note Calling this method will not @em necessarily lead to successful
 * conversion.  If the conversion fails, it will be logged in the error
 * list associated with this SBMLDocument_t structure.  Callers should
 * consult getNumErrors() to find out if the conversion succeeded without
 * problems.  For conversions from Level 2 to Level 1, callers can also
 * check the Level of the model after calling this method to find out
 * whether it is Level 1.  (If the conversion to Level 1 failed, the Level
 * of this model will be left unchanged.)
 *
 *
 * Strict conversion applies the additional criteria that both the source
 * and the target model must be consistent SBML.  Users can control the
 * consistency checks that are applied using the 
 * SBMLDocument::setConsistencyChecks function.  If either the source
 * or the potential target model have validation errors, the conversion
 * is not performed.  When a strict conversion is successful, the
 * underlying SBML structure model is altered to reflect the new level
 * and version.  Thus information that cannot be converted (e.g. sboTerms)
 * will be lost.  
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setLevelAndVersionStrict (  SBMLDocument_t *d
                                       , unsigned int    level
                                       , unsigned int    version );


/**
 * Sets the SBML Level and Version of this SBMLDocument_t, attempting to
 * convert the model as needed.
 *
 * This method is used to convert models between Levels and Versions of
 * SBML.  Generally, models can be converted upward without difficulty
 * (e.g., from SBML Level 1 to Level 2, or from an earlier version of
 * Level 2 to the latest version of Level 2).  Sometimes models can be
 * translated downward as well, if they do not use constructs specific to
 * more advanced Levels of SBML.
 *
 * Callers can also check compatibility directly using the methods
 * checkL1Compatibility(), checkL2v1Compatibility(), and 
 * checkL2v2Compatibility().
 * 
 * The valid combinations as of this release of libSBML are the
 * following: 
 *
 * @li Level 1 Version 1
 * @li Level 1 Version 2
 * @li Level 2 Version 1
 * @li Level 2 Version 2
 * @li Level 2 Version 3
 * @li Level 2 Version 4
 *
 * @param d the SBMLDocument_t structure
 *
 * @param level the desired SBML Level
 *
 * @param version the desired Version within the SBML Level
 *
 * @note Calling this method will not @em necessarily lead to successful
 * conversion.  If the conversion fails, it will be logged in the error
 * list associated with this SBMLDocument_t structure.  Callers should
 * consult getNumErrors() to find out if the conversion succeeded without
 * problems.  For conversions from Level 2 to Level 1, callers can also
 * check the Level of the model after calling this method to find out
 * whether it is Level 1.  (If the conversion to Level 1 failed, the Level
 * of this model will be left unchanged.)
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setLevelAndVersionNonStrict (  SBMLDocument_t *d
                                 , unsigned int    level
                                 , unsigned int    version );


/**
 * Sets the model contained in the given SBMLDocument_t structure to a copy
 * of the given Model_t structure.
 *
 * @param d the SBMLDocument_t structure
 *
 * @param m the new Model_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setModel (SBMLDocument_t *d, const Model_t *m);


/**
 * Creates a new Model_t structure inside the given SBMLDocument_t
 * structure and returns a pointer to it.
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the Model_t structure created
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
Model_t *
SBMLDocument_createModel (SBMLDocument_t *d);


/**
 * Sets the location of this SBMLDocument_t.
 *
 * Called automatically when readSBMLFromFile() is used, but may be set
 * manually as well.
 *
 * @param d the SBMLDocument_t structure
 * @param location the location URI of the document.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
void 
SBMLDocument_setLocationURI (SBMLDocument_t *d, const char* location);

/**
 * Get the location of this SBMLDocument_t.
 *
 * If this document was read from a file or had its location set manually,
 * that filename or set location will be returned, otherwise, an empty
 * string is returned.
 *
 * @param d the SBMLDocument_t structure to query
 *
 * @return The filename or set location of the document, or an empty string if
 * no such information is found.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
char*
SBMLDocument_getLocationURI(SBMLDocument_t *d);

/**
 * Allows particular validators to be turned on or off prior to
 * calling checkConsistency. 
 *
 * The second argument (@p category) to this method indicates which
 * category of consistency/error checks are being turned on or off, and
 * the second argument (a boolean) indicates whether to turn on (value of
 * @c true) or off (value of @c false) that particula category of checks.
 * The possible categories are represented as values of the enumeration
 * SBMLErrorCategory_t.  The following are the possible choices in libSBML
 * version 3.0.2:
 *
 * @li LIBSBML_CAT_GENERAL_CONSISTENCY:    General overall SBML consistency.
 * 
 * @li LIBSBML_CAT_IDENTIFIER_CONSISTENCY: Consistency of identifiers.  An
 * example of inconsistency would be using a species identifier in a
 * reaction rate formula without first having declared the species.
 * 
 * @li LIBSBML_CAT_UNITS_CONSISTENCY:      Consistency of units of measure.
 * 
 * @li LIBSBML_CAT_MATHML_CONSISTENCY:     Consistency of MathML constructs.
 * 
 * @li LIBSBML_CAT_SBO_CONSISTENCY:        Consistency of SBO identifiers.
 * 
 * @li LIBSBML_CAT_OVERDETERMINED_MODEL:   Checking whether the system of
 * equations implied by a model is mathematically overdetermined.
 * 
 * @li LIBSBML_CAT_MODELING_PRACTICE:      General good practice in
 * model construction.
 * 
 * By default, all validation checks are applied to the model in an
 * SBMLDocument_t structure @em unless setConsistencyChecks() is called to
 * indicate that only a subset should be applied.
 *
 * @param d the SBMLDocument_t structure
 *
 * @param category a value drawn from SBMLErrorCategory_t indicating the
 * consistency checking/validation to be turned on or off
 *
 * @param apply a boolean indicating whether the checks indicated by @p
 * category should be applied or not. 
 * 
 * @note The default (i.e., performing all checks) applies to each new
 * SBMLDocument_t structure created.  This means that each time a model is
 * read using SBMLReader::readSBML(), SBMLReader::readSBMLFromString, or
 * the global functions readSBML() and readSBMLFromString(), a new
 * SBMLDocument is created and for that document all checks are enabled.
 *
 * @see SBMLDocument_checkConsistency()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
void
SBMLDocument_setConsistencyChecks(SBMLDocument_t *d, 
                                  SBMLErrorCategory_t category,
                                  int apply);

/**
 * Allows particular validators to be turned on or off prior to
 * calling setLevelAndVersion. 
 *
 * The second argument (@p category) to this method indicates which
 * category of consistency/error checks are being turned on or off, and
 * the second argument (a boolean) indicates whether to turn on (value of
 * @c true) or off (value of @c false) that particula category of checks.
 * The possible categories are represented as values of the enumeration
 * SBMLErrorCategory_t.  The following are the possible choices in libSBML
 * version 3.0.2:
 *
 * @li LIBSBML_CAT_GENERAL_CONSISTENCY:    General overall SBML consistency.
 * 
 * @li LIBSBML_CAT_IDENTIFIER_CONSISTENCY: Consistency of identifiers.  An
 * example of inconsistency would be using a species identifier in a
 * reaction rate formula without first having declared the species.
 * 
 * @li LIBSBML_CAT_UNITS_CONSISTENCY:      Consistency of units of measure.
 * 
 * @li LIBSBML_CAT_MATHML_CONSISTENCY:     Consistency of MathML constructs.
 * 
 * @li LIBSBML_CAT_SBO_CONSISTENCY:        Consistency of SBO identifiers.
 * 
 * @li LIBSBML_CAT_OVERDETERMINED_MODEL:   Checking whether the system of
 * equations implied by a model is mathematically overdetermined.
 * 
 * @li LIBSBML_CAT_MODELING_PRACTICE:      General good practice in
 * model construction.
 * 
 * By default, all validation checks are applied to the model in an
 * SBMLDocument_t structure @em unless setConsistencyChecks() is called to
 * indicate that only a subset should be applied.
 *
 * @param d the SBMLDocument_t structure
 *
 * @param category a value drawn from SBMLErrorCategory_t indicating the
 * consistency checking/validation to be turned on or off
 *
 * @param apply a boolean indicating whether the checks indicated by @p
 * category should be applied or not. 
 * 
 * @note The default (i.e., performing all checks) applies to each new
 * SBMLDocument_t structure created.  This means that each time a model is
 * read using SBMLReader::readSBML(), SBMLReader::readSBMLFromString, or
 * the global functions readSBML() and readSBMLFromString(), a new
 * SBMLDocument is created and for that document all checks are enabled.
 *
 * @see SBMLDocument_setLevelAndVersionStrict()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
void
SBMLDocument_setConsistencyChecksForConversion(SBMLDocument_t *d, 
                                               SBMLErrorCategory_t category,
                                               int apply);

/**
 * Performs a set of consistency and validation checks on the given SBML
 * document.
 *
 * If this method returns a nonzero value (meaning, one or more
 * consistency checks have failed for SBML document), the failures may be
 * due to warnings @em or errors.  Callers should inspect the severity
 * flag in the individual SBMLError_t structures returned by getError() to
 * determine the nature of the failures.
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_checkConsistency (SBMLDocument_t *d);


/**
 * Performs consistency checking and validation on the given SBML document.
 *
 * If this method returns a nonzero value (meaning, one or more
 * consistency checks have failed for SBML document), the failures may be
 * due to warnings @em or errors.  Callers should inspect the severity
 * flag in the individual SBMLError_t structures returned by
 * SBMLDocument_getError() to determine the nature of the failures.
 *
 * @note unlike SBMLDocument_checkConsistency(), this method will write the document
 *       in order to determine all errors for the document. This will 
 *       also clear the error log. 
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @see SBMLDocument_checkConsistency()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_validateSBML (SBMLDocument_t *d);


/**
 * Performs consistency checking on libSBML's internal representation of 
 * an SBML Model.
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @note The consistency checks performed by this function are limited
 * to inconsistencies that are not caught by other consistency checks.
 * @see setConsistencyChecks()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_checkInternalConsistency (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 1 and can be converted to
 * Level 1.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL1Compatibility (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 2 Version 1 and can be
 * converted to Level 2 Version 1.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL2v1Compatibility (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 2 Version 2 and can be
 * converted to Level 2 Version 2.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL2v2Compatibility (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 2 Version 3 and can be
 * converted to Level 2 Version 3.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL2v3Compatibility (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 2 Version 4 and can be
 * converted to Level 2 Version 4.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL2v4Compatibility (SBMLDocument_t *d);


/**
 * Performs a set of consistency checks on the document to establish
 * whether it is compatible with SBML Level 3 Version 1 and can be
 * converted to Level 3 Version 1.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of failed checks (errors) encountered.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int 
SBMLDocument_checkL3v1Compatibility (SBMLDocument_t *d);


/**
 * Returns the nth error or warning encountered during parsing,
 * consistency checking, or attempted translation of this model.
 *
 * Callers can use method XMLError_getSeverity() on the result to assess
 * the severity of the problem.  The severity levels range from
 * informationl messages to fatal errors.
 *
 * @return the error or warning indexed by integer @p n, or return @c NULL
 * if n > (SBMLDocument_getNumErrors() - 1).
 *
 * @param d the SBMLDocument_t structure
 *
 * @param n the index of the error sought.
 *
 * @see SBMLDocument_getNumErrors(), SBMLDocument_setLevelAndVersion(),
 * SBMLDocument_checkConsistency(), SBMLDocument_checkL1Compatibility(),
 * SBMLDocument_checkL2v1Compatibility()
 * SBMLDocument_checkL2v2Compatibility(), SBMLReader_readSBML(),
 * SBMLReader_readSBMLFromString().
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
const SBMLError_t *
SBMLDocument_getError (SBMLDocument_t *d, unsigned int n);


/**
 * Returns the number of errors or warnings encountered during parsing,
 * consistency checking, or attempted translation of this model.
 *
 * @param d the SBMLDocument_t structure
 *
 * @return the number of errors or warnings encountered
 *
 * @see SBMLDocument_setLevelAndVersion(), SBMLDocument_checkConsistency(),
 * SBMLDocument_checkL1Compatibility(),
 * SBMLDocument_checkL2v1Compatibility()
 * SBMLDocument_checkL2v2Compatibility(), SBMLReader_readSBML(),
 * SBMLReader_readSBMLFromString().
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getNumErrors (const SBMLDocument_t *d);

/**
 * Returns the number of errors or warnings encountered during parsing,
 * consistency checking, or attempted translation of this model.
 *
 * @param d the SBMLDocument_t structure
 * @param severity the severity requested
 *
 * @return the number of errors or warnings encountered with the given severity 
 * level
 *
 * @see SBMLDocument_setLevelAndVersion(), SBMLDocument_checkConsistency(),
 * SBMLDocument_checkL1Compatibility(),
 * SBMLDocument_checkL2v1Compatibility()
 * SBMLDocument_checkL2v2Compatibility(), SBMLReader_readSBML(),
 * SBMLReader_readSBMLFromString().
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getNumErrorsWithSeverity (const SBMLDocument_t *d, unsigned int severity);

/**
 * Prints to the given output stream all the errors or warnings
 * encountered during parsing, consistency checking, or attempted
 * translation of this model.
 *
 * If no errors have occurred, i.e., SBMLDocument_getNumErrors() == 0, no
 * output will be sent to the stream.
 *
 * The format of the output is:
 *
 *   N error(s):
 *     line NNN: (id) message
 *
 * @param d the SBMLDocument_t structure
 * 
 * @param stream the output stream where the messages should be printed
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
void
SBMLDocument_printErrors (SBMLDocument_t *d, FILE *stream);


/**
 * @return the most recent SBML specification level (at the time this
 * libSBML was released).
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getDefaultLevel ();


/**
 * @return the most recent SBML specification version (at the time this
 * libSBML was released).
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
unsigned int
SBMLDocument_getDefaultVersion ();


/**
 * Returns a list of XMLNamespaces_t associated with the XML content
 * of this SBML document.
 *
 * @param d the SBMLDocument_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with this SBML structure
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
SBMLDocument_getNamespaces(SBMLDocument_t *d);


/**
 * Sets the SBMLnamespaces_t 
 *
 * @param d the SBMLDocument_t structure to change
 * @param sbmlns The SBMLNamespaces_t structure to set
 * 
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setSBMLNamespaces (SBMLDocument_t *d, SBMLNamespaces_t * sbmlns);


/**
 * Returns the <code>required</code> attribute of the given package
 * extension.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure to check
 * @param package the name or URI of the package extension.
 *
 * @return true (non-zero) if the package is flagged as
 * being required in this SBML document, false (0) otherwise.
 *
 * @deprecated Replaced in libSBML 5.2.0 by
 * SBMLDocument_getPackageRequired()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_getPkgRequired (SBMLDocument_t *d, const char * package);

/**
 * Returns the <code>required</code> attribute of the given package
 * extension.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure to check
 * @param package the name or URI of the package extension.
 *
 * @return true (non-zero) if the package is flagged as
 * being required in this SBML document, false (0) otherwise.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_getPackageRequired (SBMLDocument_t *d, const char * package);


/**
 * Sets the value of the <code>required</code> attribute for the given
 * package.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure
 * @param package the name or URI of the package extension.
 * @param flag a Boolean value.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_PKG_UNKNOWN_VERSION, OperationReturnValues_t}
 *
 * @deprecated Replaced in libSBML 5.2.0 by
 * SBMLDocument_setPackageRequired()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setPkgRequired (SBMLDocument_t *d, const char * package, int flag);

/**
 * Sets the value of the <code>required</code> attribute for the given
 * package.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure
 * @param package the name or URI of the package extension.
 * @param flag a Boolean value.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_PKG_UNKNOWN_VERSION, OperationReturnValues_t}
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_setPackageRequired (SBMLDocument_t *d, const char * package, int flag);


/**
 * Tests whether the required attribute of the given package extension
 * is defined.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure
 * @param package the name or URI of the package extension.
 *
 * @return @c non-zero (true) if the required attribute of the given package extension
 * is defined, @c zero (false) otherwise.
 *
 * @deprecated Replaced in libSBML 5.2.0 by
 * SBMLDocument_isSetPackageRequired()
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_isSetPkgRequired (SBMLDocument_t *d, const char * package);

/**
 * Tests whether the required attribute of the given package extension
 * is defined.
 *
 * @note The name of package must not be given if the package is not
 * enabled.
 *
 * @param d the SBMLDocument_t structure
 * @param package the name or URI of the package extension.
 *
 * @return @c non-zero (true) if the required attribute of the given package extension
 * is defined, @c zero (false) otherwise.
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_isSetPackageRequired (SBMLDocument_t *d, const char * package);

/**
 * Converts this document using the converter that best matches
 * the given conversion properties. 
 * 
 * @param d the SBMLDocument_t structure
 * @param props the conversion properties to use
 * 
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_CONV_CONVERSION_NOT_AVAILABLE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLDocument_t
 */
LIBSBML_EXTERN
int
SBMLDocument_convert(SBMLDocument_t *d, const ConversionProperties_t* props);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* SBMLDocument_h */

