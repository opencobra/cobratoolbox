/**
 * @file    XMLErrorLog.h
 * @brief   Stores errors (and messages) encountered while processing XML.
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
 * ------------------------------------------------------------------------ -->
 *
 * @class XMLErrorLog
 * @sbmlbrief{core} Log of diagnostics reported during XML processing.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The error log is a list.  The XML layer of libSBML maintains an error
 * log associated with a given XML document or data stream.  When an
 * operation results in an error, or when there is something wrong with the
 * XML content, the problem is reported as an XMLError object stored in the
 * XMLErrorLog list.  Potential problems range from low-level issues (such
 * as the inability to open a file) to XML syntax errors (such as
 * mismatched tags or other problems).
 *
 * A typical approach for using this error log is to first use
 * @if java XMLErrorLog::getNumErrors()@else getNumErrors()@endif@~
 * to inquire how many XMLError object instances it contains, and then to
 * iterate over the list of objects one at a time using
 * getError(unsigned int n) const.  Indexing in the list begins at 0.
 *
 * In normal circumstances, programs using libSBML will actually obtain an
 * SBMLErrorLog rather than an XMLErrorLog.  The former is subclassed from
 * XMLErrorLog and simply wraps commands for working with SBMLError objects
 * rather than the low-level XMLError objects.  Classes such as
 * SBMLDocument use the higher-level SBMLErrorLog.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_what_are_severity_overrides
 *
 * @par
 * The <em>severity override</em> mechanism in XMLErrorLog is intended to help
 * applications handle error conditions in ways that may be more convenient
 * for those applications.  It is possible to use the mechanism to override
 * the severity code of errors logged by libSBML, and even to disable error
 * logging completely.  An override stays in effect until the override is
 * changed again by the calling application.
 */

#ifndef XMLErrorLog_h
#define XMLErrorLog_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/xml/XMLError.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus

#include <iostream>
#include <string>
#include <vector>
#include <list>

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLParser;


class LIBLAX_EXTERN XMLErrorLog
{
public:

  /**
   * Returns the number of errors that have been logged.
   *
   * To retrieve individual errors from the log, callers may use
   * @if clike getError() @else XMLErrorLog::getError(unsigned int n) @endif.
   *
   * @return the number of errors that have been logged.
   */
  unsigned int getNumErrors () const;


  /**
   * Returns the <i>n</i>th XMLError object in this log.
   *
   * Index @p n is counted from 0.  Callers should first inquire about the
   * number of items in the log by using the method
   * @if java XMLErrorLog::getNumErrors()@else getNumErrors()@endif.
   * Attempts to use an error index number that exceeds the actual number
   * of errors in the log will result in a @c NULL being returned.
   *
   * @param n the index number of the error to retrieve (with 0 being the
   * first error).
   *
   * @return the <i>n</i>th XMLError in this log, or @c NULL if @p n is
   * greater than or equal to
   * @if java XMLErrorLog::getNumErrors()@else getNumErrors()@endif.
   *
   * @see getNumErrors()
   */
  const XMLError* getError (unsigned int n) const;


  /**
   * Deletes all errors from this log.
   */
  void clearLog();


  /** @cond doxygenLibsbmlInternal */
  /**
   * Creates a new empty XMLErrorLog.
   */
  XMLErrorLog ();
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Copy Constructor
   */
  XMLErrorLog (const XMLErrorLog& other);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Assignment operator
   */
  XMLErrorLog& operator=(const XMLErrorLog& other);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Destroys this XMLErrorLog.
   */
  virtual ~XMLErrorLog ();
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Logs the given XMLError.
   *
   * @param error XMLError, the error to be logged.
   */
  void add (const XMLError& error);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Logs (copies) the XMLErrors in the given XMLError list to this
   * XMLErrorLog.
   *
   * @param errors list, a list of XMLError to be added to the log.
   */
  void add (const std::list<XMLError>& errors);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Logs (copies) the XMLErrors in the given XMLError list to this
   * XMLErrorLog.
   *
   * @param errors list, a list of XMLError to be added to the log.
   */
  void add (const std::vector<XMLError*>& errors);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the XMLParser associated with this XMLErrorLog.
   *
   * The XMLParser will be used to obtain the current line and column
   * number for XMLError objects that lack line and column numbers when
   * they are logged.  This method is used by libSBML's internal XML
   * parsing code and probably has no useful reason to be called from
   * application programs.
   *
   * @param p XMLParser, the parser to use
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int setParser (const XMLParser* p);
  /** @endcond */


  /**
   * Writes all errors contained in this log to a string and returns it.
   *
   * This method uses printErrors() to format the diagnostic messages.
   * Please consult that method for information about the organization
   * of the messages in the string returned by this method.
   *
   * @return a string containing all logged errors and warnings.
   *
   * @see printErrors()
   */
  std::string toString() const;


  /**
   * Prints all the errors or warnings stored in this error log.
   *
   * This method prints the text to the stream given by the optional
   * parameter @p stream.  If no stream is given, the method prints the
   * output to the standard error stream.
   *
   * The format of the output is:
   * @verbatim
   N error(s):
     line NNN: (id) message
 @endverbatim
   * If no errors have occurred, i.e.,
   * <code>getNumErrors() == 0</code>, then no output will be produced.

   * @param stream the ostream or ostringstream object indicating where
   * the output should be printed.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  void printErrors (std::ostream& stream = std::cerr) const;

  /**
   * Prints the errors or warnings with given severity stored in this error log.
   *
   * This method prints the text to the stream given by the optional
   * parameter @p stream.  If no stream is given, the method prints the
   * output to the standard error stream.
   *
   * The format of the output is:
   * @verbatim
   N error(s):
     line NNN: (id) message
@endverbatim
   * If no errors with that severity was found, then no output will be produced.
   *
   * @param stream the ostream or ostringstream object indicating where
   * the output should be printed.
   * @param severity the severity of the errors sought.
   *
   */
  void printErrors(std::ostream& stream, unsigned int severity) const;

  /**
   * Returns a boolean indicating whether or not the severity has been
   * overridden.
   *
   * @copydetails doc_what_are_severity_overrides
   *
   * @return @c true if an error severity override has been set, @c false
   * otherwise.
   *
   * @see getSeverityOverride()
   * @see setSeverityOverride(@if java int@endif)
   * @see unsetSeverityOverride()
   * @see changeErrorSeverity(@if java int, int, String@endif)
   */
  bool isSeverityOverridden() const;


  /**
   * Usets an existing override.
   *
   * @copydetails doc_what_are_severity_overrides
   *
   * @see getSeverityOverride()
   * @see setSeverityOverride(@if java int@endif)
   * @see isSeverityOverridden()
   * @see changeErrorSeverity(@if java int, int, String@endif)
   */
  void unsetSeverityOverride();


  /**
   * Returns the current override.
   *
   * @copydetails doc_what_are_severity_overrides
   *
   * @return a severity override code.  The possible values are drawn
   * from @if clike the enumeration #XMLErrorSeverityOverride_t@else the
   * set of integer constants whose names begin with the prefix
   * <code>LIBSBML_OVERRIDE_</code>@endif:
   * @li @sbmlconstant{LIBSBML_OVERRIDE_DISABLED, XMLErrorSeverityOverride_t}
   * @li @sbmlconstant{LIBSBML_OVERRIDE_DONT_LOG, XMLErrorSeverityOverride_t}
   * @li @sbmlconstant{LIBSBML_OVERRIDE_WARNING, XMLErrorSeverityOverride_t}
   *
   * @see isSeverityOverridden()
   * @see setSeverityOverride(@if java int@endif)
   * @see unsetSeverityOverride()
   * @see changeErrorSeverity(@if java int, int, String@endif)
   */
  XMLErrorSeverityOverride_t getSeverityOverride() const;


  /**
   * Set the severity override.
   *
   * @copydetails doc_what_are_severity_overrides
   *
   * @param severity an override code indicating what to do.  If the value is
   * @sbmlconstant{LIBSBML_OVERRIDE_DISABLED, XMLErrorSeverityOverride_t}
   * (the default setting) all errors logged will be given the severity
   * specified in their usual definition.   If the value is
   * @sbmlconstant{LIBSBML_OVERRIDE_WARNING, XMLErrorSeverityOverride_t},
   * then all errors will be logged as warnings.  If the value is 
   * @sbmlconstant{LIBSBML_OVERRIDE_DONT_LOG, XMLErrorSeverityOverride_t},
   * no error will be logged, regardless of their severity.
   *
   * @see isSeverityOverridden()
   * @see getSeverityOverride()
   * @see unsetSeverityOverride()
   * @see changeErrorSeverity(@if java int, int, String@endif)
   */
  void setSeverityOverride(XMLErrorSeverityOverride_t severity);


  /**
   * Changes the severity override for errors in the log that have a given
   * severity.
   *
   * This method searches through the list of errors in the log, comparing
   * each one's severity to the value of @p originalSeverity.  For each error
   * encountered with that severity logged by the named @p package, the
   * severity of the error is reset to @p targetSeverity.
   *
   * @copydetails doc_what_are_severity_overrides
   *
   * @param originalSeverity the severity code to match
   *
   * @param targetSeverity the severity code to use as the new severity
   *
   * @param package a string, the name of an SBML Level&nbsp;3 package
   * extension to use to narrow the search for errors.  A value of @c "all"
   * signifies to match against errors logged from any package; a value of a
   * package nickname such as @c "comp" signifies to limit consideration to
   * errors from just that package.  If no value is provided, @c "all" is the
   * default.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see isSeverityOverridden()
   * @see getSeverityOverride()
   * @see setSeverityOverride(@if java int@endif)
   * @see unsetSeverityOverride()
   */
  void changeErrorSeverity(XMLErrorSeverity_t originalSeverity,
                           XMLErrorSeverity_t targetSeverity,
                           std::string package = "all");

protected:
  /** @cond doxygenLibsbmlInternal */

  std::vector<XMLError*> mErrors;
  const XMLParser*       mParser;
  XMLErrorSeverityOverride_t    mOverriddenSeverity;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLErrorLog_t structure and returns it.
 *
 * @return the new XMLErrorLog_t structure.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
XMLErrorLog_t *
XMLErrorLog_create (void);


/**
 * Frees the given XMLError_t structure.
 *
 * @param log XMLErrorLog_t, the error log to be freed.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
void
XMLErrorLog_free (XMLErrorLog_t *log);


/**
 * Logs the given XMLError_t structure.
 *
 * @param log XMLErrorLog_t, the error log to be added to.
 * @param error XMLError_t, the error to be logged.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
void
XMLErrorLog_add (XMLErrorLog_t *log, const XMLError_t *error);


/**
 * Returns the nth XMLError_t in this log.
 *
 * @param log XMLErrorLog_t, the error log to be queried.
 * @param n unsigned int number of the error to retrieve.
 *
 * @return the nth XMLError_t in this log.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
const XMLError_t *
XMLErrorLog_getError (const XMLErrorLog_t *log, unsigned int n);


/**
 * Returns the number of errors that have been logged.
 *
 * @param log XMLErrorLog_t, the error log to be queried.
 *
 * @return the number of errors that have been logged.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
unsigned int
XMLErrorLog_getNumErrors (const XMLErrorLog_t *log);


/**
 * Removes all errors from this log.
 *
 * @param log XMLErrorLog_t, the error log to be cleared.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
void
XMLErrorLog_clearLog (XMLErrorLog_t *log);

/**
 * Writes all errors contained in this log to a string and returns it. 
 *
 * @param log XMLErrorLog_t, the error log to convert.
 *
 * @return a string containing all logged errors.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
char*
XMLErrorLog_toString (XMLErrorLog_t *log);

/**
 * Predicate returning @c true or @c false depending on whether 
 * the 'severity overridden' flag of this XMLErrorLog_t is set.
 * 
 * @param log XMLErrorLog_t structure to be queried.
 *
 * @return @c non-zero (true) if the security override is not set to LIBSBML_OVERRIDE_DISABLED, @c zero (false) otherwise.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
int
XMLErrorLog_isSeverityOverridden (XMLErrorLog_t *log);

/**
 * Usets the override of the given XMLErrorLog_t (sets the flag to LIBSBML_OVERRIDE_DISABLED).
 * 
 * @param log XMLErrorLog_t structure to be queried.
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
void
XMLErrorLog_unsetSeverityOverride (XMLErrorLog_t *log);

/**
 * Returns the current override.
 *
 * @return a severity override code.  The possible values are drawn
 * from the enumeration #XMLErrorSeverityOverride_t:
 * @li @sbmlconstant{LIBSBML_OVERRIDE_DISABLED, XMLErrorSeverityOverride_t}
 * @li @sbmlconstant{LIBSBML_OVERRIDE_DONT_LOG, XMLErrorSeverityOverride_t}
 * @li @sbmlconstant{LIBSBML_OVERRIDE_WARNING, XMLErrorSeverityOverride_t}
 * 
 * @param log XMLErrorLog_t structure to be queried.
 *
 * @see XMLErrorLog_setSeverityOverride()
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
XMLErrorSeverityOverride_t
XMLErrorLog_getSeverityOverride (XMLErrorLog_t *log);

/**
 * Set the severity override of the given @p log to the given @p overridden value. 
 * 
 * @param log XMLErrorLog_t structure to be queried.
 * @param overridden an override code indicating what to do.  If the value is
 * @sbmlconstant{LIBSBML_OVERRIDE_DISABLED, XMLErrorSeverityOverride_t}
 * (the default setting) all errors logged will be given the severity
 * specified in their usual definition.   If the value is
 * @sbmlconstant{LIBSBML_OVERRIDE_WARNING, XMLErrorSeverityOverride_t},
 * then all errors will be logged as warnings.  If the value is 
 * @sbmlconstant{LIBSBML_OVERRIDE_DONT_LOG, XMLErrorSeverityOverride_t},
 * no error will be logged, regardless of their severity.
 *
 * @see XMLErrorLog_getSeverityOverride()
 *
 * @memberof XMLErrorLog_t
 */
LIBLAX_EXTERN
void
XMLErrorLog_setSeverityOverride (XMLErrorLog_t *log, XMLErrorSeverityOverride_t overridden);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLErrorLog_h */
