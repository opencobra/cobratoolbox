/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ExpatParser.cpp
 * @brief   Adapts the Expat XML parser to the XMLParser interface
 * @author  Ben Bornstein <ben.bornstein@jpl.nasa.gov>
 * @author  Michael Hucka <mhucka@caltech.edu>
 *
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
 * ---------------------------------------------------------------------- -->*/

#include <iostream>
#include <sstream>
#include <cstring>

#include <sbml/xml/XMLFileBuffer.h>
#include <sbml/xml/XMLMemoryBuffer.h>
#include <sbml/xml/XMLErrorLog.h>

#include <sbml/xml/ExpatHandler.h>
#include <sbml/xml/ExpatParser.h>

#include <sbml/compress/CompressCommon.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

static const int BUFFER_SIZE = 8192;

/*
 * Expat's error messages are conveniently defined as a consecutive
 * sequence starting from 0.  This makes a translation table easy to
 * create.  The indexes into this table are the Expat codes, and the
 * values are our own error codes.
 */
static XMLErrorCode_t expatErrorTable[] = {
  XMLUnknownError,          // ERROR_NONE
  XMLOutOfMemory,           // ERROR_NO_MEMORY
  BadlyFormedXML,           // ERROR_SYNTAX
  BadlyFormedXML,           // ERROR_NO_ELEMENTS
  BadlyFormedXML,           // ERROR_INVALID_TOKEN
  UnclosedXMLToken,         // ERROR_UNCLOSED_TOKEN
  InvalidCharInXML,         // ERROR_PARTIAL_CHAR
  XMLTagMismatch,           // ERROR_TAG_MISMATCH
  DuplicateXMLAttribute,    // ERROR_DUPLICATE_ATTRIBUTE
  BadXMLDOCTYPE,            // ERROR_JUNK_AFTER_DOC_ELEMENT
  XMLUnknownError,          // ERROR_PARAM_ENTITY_REF
  UndefinedXMLEntity,       // ERROR_UNDEFINED_ENTITY
  UndefinedXMLEntity,       // ERROR_RECURSIVE_ENTITY_REF
  UndefinedXMLEntity,       // ERROR_ASYNC_ENTITY
  InvalidCharInXML,         // ERROR_BAD_CHAR_REF
  InvalidCharInXML,         // ERROR_BINARY_ENTITY_REF
  UndefinedXMLEntity,       // ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF
  BadXMLDeclLocation,       // ERROR_MISPLACED_PI
  BadXMLDecl,               // ERROR_UNKNOWN_ENCODING
  BadXMLDecl,               // ERROR_INCORRECT_ENCODING
  BadlyFormedXML,           // ERROR_UNCLOSED_CDATA_SECTION
  InvalidXMLConstruct,      // ERROR_EXTERNAL_ENTITY_HANDLING
  BadXMLDecl,               // ERROR_NOT_STANDALONE
  XMLUnknownError,          // ERROR_UNEXPECTED_STATE
  XMLUnknownError,          // ERROR_ENTITY_DECLARED_IN_PE
  InvalidXMLConstruct,      // ERROR_FEATURE_REQUIRES_DTD
  InvalidXMLConstruct,      // ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING
  BadXMLPrefix,             // ERROR_UNBOUND_PREFIX
  BadXMLPrefix,             // ERROR_UNDECLARING_PREFIX
  BadlyFormedXML,           // ERROR_INCOMPLETE_PE
  BadXMLDecl,               // ERROR_DECL
  XMLUnknownError,          // ERROR_TEXT_DECL
  XMLUnknownError,          // ERROR_PUBLICID
  XMLUnknownError,          // ERROR_SUSPENDED
  XMLUnknownError,          // ERROR_NOT_SUSPENDED
  XMLUnknownError,          // ERROR_ABORTED
  XMLUnknownError,          // ERROR_FINISHED
  XMLUnknownError           // ERROR_SUSPEND_PE
};


const XMLErrorCode_t
translateError(const int expatCode)
{
  int numTableEntries = sizeof(expatErrorTable)/sizeof(expatErrorTable[0]);

  if (expatCode > 0 && expatCode < numTableEntries)
    return expatErrorTable[expatCode];
  else
    return XMLUnknownError;
}


/*
 * Note that the given error code is a XMLErrorCode_t value, not a code
 * number returned by the underlying parser.  Codes returned by the parser
 * must be translated first.
 *
 * @see translateError().
 */
void
ExpatParser::reportError (const XMLErrorCode_t code,
			  const string&        extraMsg,
			  const unsigned int   line,
			  const unsigned int   column)
{
  if (mErrorLog != NULL)
    mErrorLog->add((const XMLError&)XMLError( code, extraMsg, line, column) );
  else
  {
    // R wrapping for creating an R package objects to the use of cerr
    // Since in most places this would never show up to a developer
    // I am taking it out for now
    // but we can revisit it is we feel we need to
#if 0
    // We have no error log, but we shouldn't gloss over this error.  Use
    // the measure of last resort.

    cerr << XMLError::getStandardMessage(code)
	 << "  Error found at line and column numbers " << line << ":" << column << ":\n"
	 << extraMsg << endl;
#endif
  }
}


/**
 * Creates a new ExpatParser given an XMLHandler object.
 *
 * The parser will notify the given XMLHandler of parse events and errors.
 */
ExpatParser::ExpatParser (XMLHandler& handler) :
   mParser ( XML_ParserCreateNS(NULL, ' ') )
 , mHandler( mParser, handler )
 , mBuffer ( NULL )
 , mSource ( NULL )
{
  if (mParser != NULL) mBuffer = XML_GetBuffer(mParser, BUFFER_SIZE);
}


/**
 * Destroys this ExpatParser.
 */
ExpatParser::~ExpatParser ()
{
  XML_ParserFree(mParser);
  delete mSource;
}


/**
 * Returns true or false depending on whether the last operation
 * caused the underlying parser to generate an error.  Errors may
 * result from out-of-memory conditions as well.  This is called
 * by methods such as @c parse() and @c parseNext().
 * 
 * @return true if the parser encountered an error, false otherwise.
 */
bool
ExpatParser::error () const
{
  bool error = (mParser == NULL || mBuffer == NULL);

  if (mSource != NULL) error = error || mSource->error();
  return error;
}


/**
 * @return the column position of the current parser's location
 * in the XML input stream.
 */
unsigned int
ExpatParser::getColumn () const
{
  return mHandler.getColumn();
}


/**
 * @return the line position of the current parser's location
 * in the XML input stream.
 */
unsigned int
ExpatParser::getLine () const
{
  return mHandler.getLine();
}


/**
 * Parses XML content in one fell swoop.
 *
 * If @p isFile whoa is true (default), @p content is treated as a filename from
 * which to read the XML content.  Otherwise, @p content is treated as a
 * null-terminated buffer containing XML data and is read directly.
 *
 * @return true if the parse was successful, false otherwise.
 */
bool
ExpatParser::parse (const char* content, bool isFile)
{
  bool result = parseFirst(content, isFile);

  if (result)
  {
    while( parseNext() );
    result = (error() == false);
  }

  parseReset();

  return result;
}


/**
 * Begins a progressive parse of XML content.  This parses the first
 * chunk of the XML content and returns.  Successive chunks are parsed by
 * calling parseNext().
 *
 * A chunk differs slightly depending on the underlying XML parser.  For
 * Xerces and libXML chunks correspond to XML elements.  For Expat, a
 * chunk is the size of its internal buffer.
 *
 * If isFile is true (default), content is treated as a filename from which
 * to read the XML content.  Otherwise, content is treated as a buffer
 * containing XML data and is read directly.
 *
 * @return true if the first step of the progressive parse was
 * successful, false otherwise.
 */
bool
ExpatParser::parseFirst (const char* content, bool isFile)
{
  if ( error() ) return false;
 
  if (content == NULL) return false;
  
  if (isFile)
  {
    try
    {
      mSource = new XMLFileBuffer(content);
    }
    catch ( ZlibNotLinked& )
    {
      // libSBML is not linked with zlib.
      std::ostringstream oss;
      oss << "Tried to read " << content << ". Reading a gzip/zip file is not enabled because "
          << "underlying libSBML is not linked with zlib."; 
      reportError(XMLFileUnreadable, oss.str(), 0, 0);
      return false;
    } 
    catch ( Bzip2NotLinked& )
    {
      // libSBML is not linked with bzip2.
      std::ostringstream oss;
      oss << "Tried to read " << content << ". Reading a bzip2 file is not enabled because "
          << "underlying libSBML is not linked with bzip2."; 
      reportError(XMLFileUnreadable, oss.str(), 0, 0);
      return false;
    } 

    if (mSource->error())
    {
      reportError(XMLFileUnreadable, content, 0, 0);
      return false;
    }
  }
  else
  {
    mSource = new XMLMemoryBuffer(content, strlen(content));

    if (mSource == NULL)
    {
      reportError(XMLOutOfMemory, "", 0, 0);
      return false;
    }
  }

  if ( !mSource->error() )
  {
    mHandler.startDocument();
  }

  return true;
}


/**
 * Parses the next chunk of XML content.
 *
 * @return true if the next step of the progressive parse was successful,
 * false otherwise or when at EOF.
 */
bool
ExpatParser::parseNext ()
{
  if ( error() ) return false;

  mBuffer = XML_GetBuffer(mParser, BUFFER_SIZE);

  if ( mBuffer == NULL )
  {
    // See if Expat logged an error.  There are only two things that
    // XML_GetErrorCode will report: parser state errors and "out of memory".
    // So we check for the first and default to the out-of-memory case.

    switch ( XML_GetErrorCode(mParser) )
    {
    case XML_ERROR_SUSPENDED:
    case XML_ERROR_FINISHED:
      reportError(InternalXMLParserError);
      break;

    default:
      reportError(XMLOutOfMemory);
      break;
    }

    return false;
  }

  int bytes = mSource->copyTo(mBuffer, BUFFER_SIZE);
  int done  = (bytes == 0);

  // Attempt to parse the content, checking for the Expat return status.

  if ( XML_ParseBuffer(mParser, bytes, done) == XML_STATUS_ERROR )
  {
    reportError(translateError(XML_GetErrorCode(mParser)), "",
		XML_GetCurrentLineNumber(mParser),
		XML_GetCurrentColumnNumber(mParser));
    return false;
  }
  else if ( mHandler.error() )
  {
    if (mErrorLog != NULL) mErrorLog->add(static_cast<const XMLError&>(*mHandler.error()));
    return false;
  }

  // catch whether an xml declaration has been found
  // Expat does not report a missing xml declaration
  if (!mHandler.hasXMLDeclaration())
  {
    reportError(MissingXMLDecl, "", 1, 1);
    return false;
  }

  if ( !error() && done )
  {
    mHandler.endDocument();
  }

  return !done;
}


/**
 * Resets the progressive parser.  Call between the last call to
 * parseNext() and the next call to parseFirst().
 */
void
ExpatParser::parseReset ()
{
  delete mSource;
  mSource = 0;
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
