/**
 * @file    XMLInputStream.h
 * @brief   XMLInputStream
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
 * @class XMLInputStream
 * @sbmlbrief{core} An interface to an XML input stream.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * SBML content is serialized using XML; the resulting data can be stored and
 * read to/from a file or data stream.  Low-level XML parsers such as Xerces
 * provide facilities to read XML data.  To permit the use of different XML
 * parsers (Xerces, Expat or libxml2), libSBML implements an abstraction
 * layer.  XMLInputStream and XMLOutputStream are two parts of that
 * abstraction layer.
 *
 * XMLInputStream is an interface to a file or text string containing XML.
 * It wraps the content to be read, as well as the low-level XML parser to be
 * used and an XMLErrorLog to record errors and other issues (if any arise).
 * Internally, the content will be in the form of either a pointer to a file
 * name or a character string; XMLInputStream knows the form of the content
 * and acts appropriately.  Other libSBML object classes use XMLInputStream
 * as their interface for all read operations on the XML data.
 * XMLInputStream provides the functionality to extract data in the form of
 * XMLToken objects.  It logs any errors encountered while reading.  It also
 * keeps track of whether a read operation has failed irrecoverably or
 * determines whether it is safe to continue reading.
 *
 * SBMLNamespaces objects can be associated with an XMLInputStream; this
 * facilitates logging errors related to reading XML attributes and elements
 * that may only be relevant to particular Level and Version combinations of
 * SBML.
 *
 * @note The convenience of the XMLInputStream and XMLOutputStream
 * abstraction may be useful for developers interested in creating parsers
 * for other XML formats besides SBML.  It can provide developers with a
 * layer above more basic XML parsers, as well as some useful programmatic
 * elements such as XMLToken, XMLError, etc.
 *
 * @see XMLOutputStream
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_xml_encoding
 *
 * @par The @em encoding is indicated by the <code>xml</code> declaration at the
 * beginning of an XML document or data stream.  The form of this declaration
 * is
 * @verbatim
<?xml version="1.0" encoding="UTF-8"?>
@endverbatim
 * Note that the SBML specifications require the use of UTF-8 encoding, so
 * for SBML documents, the value returned by this method will always be
 * the string <code>"UTF-8"</code>.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_xml_version
 *
 * @par The @em version is indicated by the <code>xml</code> declaration at the
 * beginning of an XML document or data stream.  The form of this declaration
 * is
 * @verbatim
 <?xml version="1.0" encoding="UTF-8"?>
@endverbatim
 * Note that the SBML specifications require the use of version 1.0, so
 * for SBML documents, the value returned by this method will always be
 * the string <code>"1.0"</code>.
 */

#ifndef XMLInputStream_h
#define XMLInputStream_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>
#include <sbml/SBMLNamespaces.h>


#ifdef __cplusplus

#include <string>

#include <sbml/xml/XMLTokenizer.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLErrorLog;
class XMLParser;


class LIBLAX_EXTERN XMLInputStream
{
public:

  /**
   * Creates a new XMLInputStream.
   *
   * @param content the source of the stream.
   *
   * @param isFile a boolean flag to indicate whether @p content is a file
   * name.  If @c true, @p content is assumed to be the file from which the
   * XML content is to be read.  If @c false, @p content is taken to be a
   * string that @em is the content to be read.
   *
   * @param library the name of the parser library to use.
   *
   * @param errorLog the XMLErrorLog object to use.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLInputStream (  const char*        content
                  , bool               isFile   = true
                  , const std::string  library  = "" 
                  , XMLErrorLog*       errorLog = NULL );


  /**
   * Destroys this XMLInputStream.
   */
  virtual ~XMLInputStream ();


  /**
   * Returns the encoding of the XML stream.
   *
   * @copydetails doc_xml_encoding 
   *
   * @return the encoding of the XML stream.
   *
   * @see getVersion()
   */
  const std::string& getEncoding ();


  /**
   * Returns the version of the XML stream.
   *
   * @copydetails doc_xml_version 
   *
   * @return the version of the XML stream.
   *
   * @see getEncoding()
   */
  const std::string& getVersion ();


  /**
   * Returns the XMLErrorLog used to log parsing problems.
   *
   * @return the XMLErrorLog used to log XML parse errors and other
   * validation errors (and messages).
   */
  XMLErrorLog* getErrorLog ();


  /**
   * Returns @c true if end of file (stream) has been reached.
   *
   * @return @c true if end of file (stream) has been reached, @c false
   * otherwise.
   */
  bool isEOF () const;


  /**
   * Returns @c true if a fatal error occurred while reading from this
   * stream.
   *
   * @return @c true if a fatal error occurred while reading from this
   * stream.
   */
  bool isError () const;


  /**
   * Returns @c true if the stream is in a good state.
   *
   * The definition of "good state" is that isEOF() and isError() both return
   * @c false.
   *
   * @return @c true if the stream is in a good state, @c false otherwise.
   */
  bool isGood () const;


  /**
   * Returns the next token on this XML input stream.
   *
   * The token is consumed in the process.
   *
   * @return the next XMLToken, or an EOF token (i.e.,
   * <code>XMLToken.isEOF() == true</code>).
   *
   * @see peek()
   */
  XMLToken next ();


  /**
   * Returns the next token @em without consuming it.
   *
   * A subsequent call to either peek() or next() will return the same token.
   *
   * @return the next XMLToken or EOF (XMLToken.isEOF() == true).
   *
   * @see next()
   */
  const XMLToken& peek ();


  /**
   * Consume zero or more tokens up to and including the corresponding end
   * element or EOF.
   *
   * @param element the element whose end will be sought in the input stream.
   */
  void skipPastEnd (const XMLToken& element);


  /**
   * Consume zero or more tokens up to but not including the next XML element
   * or EOF.
   */
  void skipText ();


  /**
   * Sets the XMLErrorLog this stream will use to log errors.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int setErrorLog (XMLErrorLog* log);


  /**
   * Prints a string representation of the underlying token stream.
   *
   * @return a string representing the underlying XML token stream.
   *
   * @note This method is intended for debugging purposes.
   */
  std::string toString ();


  /**
   * Returns the SBMLNamespaces object attached to this XMLInputStream.
   *
   * @return the SBMLNamespaces object or @c NULL if none has been set.
   */
  SBMLNamespaces * getSBMLNamespaces();


  /**
   * Sets the SBML namespaces associated with this XML input stream.
   *
   * This allows this stream to reference the available SBML namespaces being
   * read.
   *
   * @param sbmlns the list of namespaces to use.
   */
   void setSBMLNamespaces(SBMLNamespaces * sbmlns);


  /**
   * Returns the number of child tokens of the given element in this stream.
   *
   * This method allows information from the input stream to be determined
   * without the need to actually read and consume the tokens in the stream.
   * It returns the number of child elements of the element represented by
   * the @p elementName, i.e., the number of child elements encountered
   * before the closing tag for the @p elementName supplied.
   *
   * If no @p elementName is supplied or it is an empty string, then as a
   * special case, this method assumes the element is a MathML
   * <code>apply</code> element followed by a function name.
   *
   * @param elementName a string representing the name of the element for
   * which the number of children are to be determined.
   *
   * @return an unsigned int giving the number of children of the @p
   * elementName specified.
   *
   * @note This method assumes the stream has been read up to and including
   * the element @p elementName.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  unsigned int determineNumberChildren(const std::string& elementName = "");


  /**
   * Returns the number of child tokens of the specified type within a
   * given container element.
   *
   * This method allows information from the input stream to be determined
   * without the need to actually read and consume the tokens in the stream.
   * It returns the number of child elements of the @p childName element
   * within the element specified by @p container.  In other words, it counts
   * the number of @p childName elements encountered before the closing tag
   * for the @p container supplied.
   *
   * @param childName a string representing the name of the child
   * element whose number is to be determined.
   *
   * @param container a string representing the name of the element
   * for which the number of children are to be determined.
   *
   * @return an unsigned int giving the number of children of type @p
   * childName within the @p container element.
   *
   * @note This method assumes the stream has been read up to and including
   * the element @p container.
   */
  unsigned int determineNumSpecificChildren(const std::string& childName,
                                            const std::string& container);

private:
  /** @cond doxygenLibsbmlInternal */


  /**
   * Copy Constructor, made private so as to notify users, that copying an
   * input stream is not supported.
   */
  XMLInputStream (const XMLInputStream& other);


  /**
   * Assignment operator, made private so as to notify users, that copying an
   * input stream is not supported.
   */
  XMLInputStream& operator=(const XMLInputStream& other);


  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Unitialized XMLInputStreams may only be created by subclasses.
   */
  XMLInputStream ();


  /**
   * Runs mParser until mTokenizer is ready to deliver at least one
   * XMLToken or a fatal error occurs.
   */
  void queueToken ();
  bool requeueToken ();


  bool mIsError;

  XMLToken     mEOF;
  XMLTokenizer mTokenizer;
  XMLParser*   mParser;

  SBMLNamespaces* mSBMLns;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN

BEGIN_C_DECLS


/**
 * Creates a new empty XMLInputStream_t structure and returns a pointer to
 * it.
 *
 * @param content the source of the stream.
 *
 * @param isFile a boolean flag to indicate whether @p content is a file
 * name.  If @c true, @p content is assumed to be the file from which the
 * XML content is to be read.  If @c false, @p content is taken to be a
 * string that @em is the content to be read.
 *
 * @param library the name of the parser library to use.
 *
 * @return pointer to the XMLInputStream_t structure created.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
XMLInputStream_t *
XMLInputStream_create (const char* content, int isFile, const char *library);


/**
 * Destroys this XMLInputStream_t structure.
 *
 * @param stream XMLInputStream_t structure to be freed.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
void
XMLInputStream_free (XMLInputStream_t *stream);


/**
 * Returns the encoding of the XML stream.
 *
 * @copydetails doc_xml_encoding
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return the encoding of this XMLInputStream_t, as a pointer to a string.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
const char *
XMLInputStream_getEncoding (XMLInputStream_t *stream);


/**
 * Returns the error log associated with the given stream.
 * 
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return the XMLErrorLog object for the @p stream.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
XMLErrorLog_t *
XMLInputStream_getErrorLog (XMLInputStream_t *stream);


/**
 * Returns nonzero if the given stream has reached EOF.
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return @c true (nonzero) if this stream is at its end, @c false (zero)
 * otherwise.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
int
XMLInputStream_isEOF (XMLInputStream_t *stream);


/**
 * Returns nonzero if the stream has experienced a fatal error.
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return @c true (nonzero) if a fatal error occurred while reading from
 * this stream, @c false (zero) otherwise.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
int
XMLInputStream_isError (XMLInputStream_t *stream);


/**
 * Returns nonzero if the given stream is in a good state.
 *
 * The definition of "good state" is that isEOF() and isError() both return
 * @c false.
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return @c true (nonzero) if the stream is happy, @c false (zero)
 * otherwise.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
int
XMLInputStream_isGood (XMLInputStream_t *stream);


/**
 * Returns the next token in the given stream.
 *
 * The token is consumed in the process.
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return the token, as an XMLToken_t structure.
 *
 * @see XMLInputStream_peek()
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLInputStream_next (XMLInputStream_t *stream);


/**
 * Returns the next token @em without consuming it.
 *
 * A subsequent call to either peek() or next() will return the same token.
 *
 * @param stream the XMLInputStream_t structure to examine.
 *
 * @return the token, as an XMLToken_t structure.
 *
 * @see XMLInputStream_get()
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
const XMLToken_t *
XMLInputStream_peek (XMLInputStream_t *stream);


/**
 * Consume zero or more tokens up to and including the corresponding end
 * element or EOF.
 *
 * @param stream the XMLInputStream_t to act on.
 *
 * @param element the element whose end will be sought in the input stream.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
void
XMLInputStream_skipPastEnd (XMLInputStream_t *stream,
                            const XMLToken_t *element);


/**
 * Consume zero or more tokens up to but not including the next XML element
 * or EOF.
 *
 * @param stream the XMLInputStream_t structure to act on.
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
void
XMLInputStream_skipText (XMLInputStream_t *stream);


/**
 * Sets the XMLErrorLog this stream will use to log errors.
 *
 * @param stream XMLInputStream_t structure to act on.
 *
 * @param log the XMLErrorLog_t structure to attach to the @p stream.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof XMLInputStream_t
 */
LIBLAX_EXTERN
int
XMLInputStream_setErrorLog (XMLInputStream_t *stream, XMLErrorLog_t *log);


END_C_DECLS

LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLInputStream_h */
