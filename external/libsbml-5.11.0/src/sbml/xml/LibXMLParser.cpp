/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    LibXMLParser.cpp
 * @brief   Adapts the LibXML XML parser to the XMLParser interface
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
 * ---------------------------------------------------------------------- -->*/

#include <iostream>
#include <sstream>

#include <libxml/xmlerror.h>

#include <sbml/xml/XMLFileBuffer.h>
#include <sbml/xml/XMLMemoryBuffer.h>

#include <sbml/xml/LibXMLHandler.h>
#include <sbml/xml/LibXMLParser.h>

#include <sbml/compress/CompressCommon.h>


using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

static const int BUFFER_SIZE = 8192;

/*
 * Table mapping libXML error codes to ours.  The error code numbers are not
 * contiguous, hence the table has to map pairs of numbers rather than
 * simply being an array of codes.  The table is an array of vectors of
 * items [libxml code, our code], where `our code' is an error code
 * taken from the enumeration XMLParser::errorCodes.
 *
 * see /usr/include/libxml2/libxml/xmlerror.h
 * http://stuff.mit.edu/afs/sipb/project/php/share/gtk-doc/html/libxml2/libxml2-parser.html
 */ 
static struct libxmlErrors {
#ifdef __BORLANDC__
  int      libxmlCode;
#else
  const int      libxmlCode;
#endif  
  XMLErrorCode_t ourCode;
} libxmlErrorTable[] = {
  { XML_ERR_INTERNAL_ERROR, 	       BadlyFormedXML},
  { XML_ERR_NO_MEMORY,		       XMLOutOfMemory},
  { XML_ERR_DOCUMENT_START,	       BadlyFormedXML},
  { XML_ERR_DOCUMENT_EMPTY,	       XMLContentEmpty},
  { XML_ERR_DOCUMENT_END,	       BadlyFormedXML},
  { XML_ERR_INVALID_HEX_CHARREF,       InvalidXMLConstruct},
  { XML_ERR_INVALID_DEC_CHARREF,       InvalidXMLConstruct},
  { XML_ERR_INVALID_CHARREF,	       InvalidXMLConstruct},
  { XML_ERR_INVALID_CHAR,	       InvalidCharInXML},
  { XML_ERR_CHARREF_AT_EOF,	       BadlyFormedXML},
  { XML_ERR_CHARREF_IN_PROLOG,	       BadlyFormedXML},
  { XML_ERR_CHARREF_IN_EPILOG,	       BadlyFormedXML},
  { XML_ERR_CHARREF_IN_DTD,	       BadlyFormedXML},
  { XML_ERR_UNDECLARED_ENTITY,         UndefinedXMLEntity},
  { XML_WAR_UNDECLARED_ENTITY,         UndefinedXMLEntity},
  { XML_ERR_UNKNOWN_ENCODING,	       BadXMLDecl},
  { XML_ERR_UNSUPPORTED_ENCODING,      BadXMLDecl},
  { XML_ERR_STRING_NOT_STARTED,        BadlyFormedXML},
  { XML_ERR_STRING_NOT_CLOSED,	       BadlyFormedXML},
  { XML_ERR_NS_DECL_ERROR,	       BadlyFormedXML},
  { XML_ERR_LT_IN_ATTRIBUTE,	       BadXMLAttribute},
  { XML_ERR_ATTRIBUTE_NOT_STARTED,     InternalXMLParserError},
  { XML_ERR_ATTRIBUTE_NOT_FINISHED,    BadlyFormedXML},
  { XML_ERR_ATTRIBUTE_WITHOUT_VALUE,   MissingXMLAttributeValue},
  { XML_ERR_ATTRIBUTE_REDEFINED,       DuplicateXMLAttribute},
  { XML_ERR_LITERAL_NOT_STARTED,       InternalXMLParserError},
  { XML_ERR_LITERAL_NOT_FINISHED,      InternalXMLParserError},
  { XML_ERR_COMMENT_NOT_FINISHED,      BadXMLComment},
  { XML_ERR_PI_NOT_STARTED,	       BadProcessingInstruction},
  { XML_ERR_PI_NOT_FINISHED,	       BadProcessingInstruction},
  { XML_ERR_ATTLIST_NOT_STARTED,       BadlyFormedXML},
  { XML_ERR_ATTLIST_NOT_FINISHED,      BadlyFormedXML},
  { XML_ERR_MIXED_NOT_STARTED,	       BadlyFormedXML},
  { XML_ERR_MIXED_NOT_FINISHED,	       BadlyFormedXML},
  { XML_ERR_ELEMCONTENT_NOT_STARTED,   BadlyFormedXML},
  { XML_ERR_ELEMCONTENT_NOT_FINISHED,  BadlyFormedXML},
  { XML_ERR_XMLDECL_NOT_STARTED,       BadXMLDecl},
  { XML_ERR_XMLDECL_NOT_FINISHED,      BadXMLDecl},
  { XML_ERR_CONDSEC_NOT_STARTED,       BadlyFormedXML},
  { XML_ERR_CONDSEC_NOT_FINISHED,      BadlyFormedXML},
  { XML_ERR_EXT_SUBSET_NOT_FINISHED,   BadlyFormedXML},
  { XML_ERR_DOCTYPE_NOT_FINISHED,      BadXMLDOCTYPE},
  { XML_ERR_MISPLACED_CDATA_END,       BadlyFormedXML},
  { XML_ERR_CDATA_NOT_FINISHED,	       BadlyFormedXML},
  { XML_ERR_RESERVED_XML_NAME,	       BadXMLDeclLocation},
  { XML_ERR_SPACE_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_SEPARATOR_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_NMTOKEN_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_NAME_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_PCDATA_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_URI_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_PUBID_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_LT_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_GT_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_LTSLASH_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_EQUAL_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_TAG_NAME_MISMATCH,	       XMLTagMismatch},
  { XML_ERR_TAG_NOT_FINISHED,	       BadlyFormedXML},
  { XML_ERR_STANDALONE_VALUE,	       BadlyFormedXML},
  { XML_ERR_ENCODING_NAME,	       BadXMLDecl},
  { XML_ERR_HYPHEN_IN_COMMENT,	       BadXMLComment},
  { XML_ERR_INVALID_ENCODING,	       BadXMLDecl},
  { XML_ERR_CONDSEC_INVALID,	       BadlyFormedXML},
  { XML_ERR_VALUE_REQUIRED,	       BadlyFormedXML},
  { XML_ERR_NOT_WELL_BALANCED,	       BadlyFormedXML},
  { XML_ERR_EXTRA_CONTENT,	       BadlyFormedXML},
  { XML_ERR_INVALID_URI,	       BadlyFormedXML},
  { XML_ERR_URI_FRAGMENT,	       BadlyFormedXML},
  { XML_WAR_CATALOG_PI,		       BadlyFormedXML},
  { XML_ERR_NO_DTD,		       BadlyFormedXML},
  { XML_ERR_CONDSEC_INVALID_KEYWORD,   BadlyFormedXML},
  { XML_ERR_VERSION_MISSING,	       BadXMLDecl},
  { XML_WAR_UNKNOWN_VERSION,	       BadXMLDecl},
  { XML_WAR_LANG_VALUE,		       BadlyFormedXML},
  { XML_WAR_NS_URI,		       BadXMLPrefix},
  { XML_WAR_NS_URI_RELATIVE,	       BadXMLPrefix},
  { XML_ERR_MISSING_ENCODING,	       MissingXMLEncoding},
#if LIBXML_VERSION >= 20627
  { XML_WAR_SPACE_VALUE,	       BadlyFormedXML},
  { XML_ERR_NOT_STANDALONE,	       BadlyFormedXML},
  { XML_ERR_NOTATION_PROCESSING,       BadlyFormedXML},
  { XML_WAR_NS_COLUMN,		       BadlyFormedXML},
#endif
  { XML_NS_ERR_XML_NAMESPACE,	       BadXMLPrefixValue},
  { XML_NS_ERR_UNDEFINED_NAMESPACE,    BadXMLPrefix},
  { XML_NS_ERR_QNAME,		       BadXMLPrefix},
  { XML_NS_ERR_ATTRIBUTE_REDEFINED,    BadlyFormedXML},
#if LIBXML_VERSION >= 20627
  { XML_NS_ERR_EMPTY,		       BadlyFormedXML},
#endif
  // The next one should always be last.  It's used only as a marker.
  { 205,			       XMLUnknownError},
};


const XMLErrorCode_t
translateError(const int libxmlCode)
{
  unsigned int tableSize = sizeof(libxmlErrorTable)/sizeof(libxmlErrorTable[0]);


  if (libxmlCode > 0 && libxmlCode < 205)
  {
    // Iterate through the table, searching for a match for the given code.
    // Yes, this is inefficient, but if we're already in an exception,
    // who cares how efficient the error look-up is?

    for (unsigned int i = 0; i < tableSize; i++)
      if (libxmlErrorTable[i].libxmlCode == libxmlCode)
	return libxmlErrorTable[i].ourCode;

    return UnrecognizedXMLParserCode;
  }

  return XMLUnknownError;
}


/*
 * Note that the given error code is an XMLError code, not a code
 * number returned by the underlying parser.  Codes returned by the
 * parser must be translated first.
 *
 * @see translateError().
 */
void
LibXMLParser::reportError (const XMLErrorCode_t code,
			   const string&        extraMsg,
			   const unsigned int   line,
			   const unsigned int   column)
{
  if (mErrorLog != NULL)
    mErrorLog->add(XMLError( code, extraMsg, line, column) );
  else
  {
    // R wrapping for creating an R package objects to the use of cerr
    // Since in most places this would never show up to a developer
    // I am taking it out for now
    // but we can revisit it is we feel we need to
#if 0

    // We have no error log, but we shouldn't gloss over this error.  Use
    // the measure of last resort.

    xmlErrorPtr libxmlError = xmlGetLastError();

    cerr << XMLError::getStandardMessage(code) << " at line and column numbers ";

    if (line != 0 || column != 0)
      cerr << line << ":" << column;
    else if (libxmlError != NULL)
      cerr << libxmlError->line << ":" << libxmlError->int2;

    cerr << ":\n" << extraMsg << endl;
#endif
  }
}


/**
 * Creates a new LibXMLParser.  The parser will notify the given XMLHandler
 * of parse events and errors.
 */
LibXMLParser::LibXMLParser (XMLHandler& handler) :
   mParser ( NULL                  )
 , mHandler( handler               )
 , mBuffer ( new char[BUFFER_SIZE] )
 , mSource ( NULL                  )
{
  xmlSAXHandler* sax  = LibXMLHandler::getInternalHandler();
  void*          data = static_cast<void*>(&mHandler);
  mParser             = xmlCreatePushParserCtxt(sax, data, 0, 0, 0);

  mHandler.setContext(mParser);
}


/**
 * Destroys this LibXMLParser.
 */
LibXMLParser::~LibXMLParser ()
{
  xmlFreeParserCtxt(mParser);
  delete [] mBuffer;
  delete    mSource;
}


/**
 * @return true if the parser encountered an error, false otherwise.
 */
bool
LibXMLParser::error () const
{
  bool error = (mParser == NULL || mBuffer == NULL);

  if (mSource != NULL) error = error || mSource->error();
  return error;
}


/**
 * @return the current column position of the parser.
 */
unsigned int
LibXMLParser::getColumn () const
{
  return mHandler.getColumn();
}


/**
 * @return the current line position of the parser.
 */
unsigned int
LibXMLParser::getLine () const
{
  return mHandler.getLine();
}


/**
 * Parses XML content in one fell swoop.
 *
 * If isFile is true (default), content is treated as a filename from
 * which to read the XML content.  Otherwise, content is treated as a
 * null-terminated buffer containing XML data and is read directly.
 *
 * @return true if the parse was successful, false otherwise.
 */
bool
LibXMLParser::parse (const char* content, bool isFile)
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
 * Xerces and libXML chunks correspond to XML elements.  For Expat, a chunk
 * is the size of its internal buffer.
 *
 * If isFile is true (default), content is treated as a filename from which
 * to read the XML content.  Otherwise, content is treated as a buffer
 * containing XML data and is read directly.
 *
 * @return true if the first step of the progressive parse was
 * successful, false otherwise.
 */
bool
LibXMLParser::parseFirst (const char* content, bool isFile)
{
  if ( error() ) return false;
  
  if (content == NULL) return false;
  
  if ( isFile )
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


    if ( mSource->error() )
    {
      reportError(XMLFileUnreadable, content, 0, 0);
      return false;
    }
  }
  else
  {
    mSource = new XMLMemoryBuffer(content, (unsigned int)strlen(content));
  }

  if ( mSource == NULL )
  {
    reportError(XMLOutOfMemory, "", 0, 0);
    return false;
  }

  if ( !error() )
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
LibXMLParser::parseNext ()
{
  if ( error() ) return false;

  int bytes = mSource->copyTo(mBuffer, BUFFER_SIZE);
  int done  = (bytes == 0);

  if ( mSource->error() )
  {
    reportError(InternalXMLParserError,
		"error: Could not read from source buffer.");
    return false;
  }

  if ( xmlParseChunk(mParser, mBuffer, bytes, done) )
  {
    xmlErrorPtr libxmlError = xmlGetLastError();

    // I tried reporting the message from libXML that's available in
    // libxmlError->message, but the thing is bogus: it will say things
    // like "such and such error model line 0" which is wrong and
    // confusing.  So even though we lose some details by dropping the
    // libXML message, I think it's less confusing for the user.

    reportError(translateError(libxmlError->code), "",
		libxmlError->line, libxmlError->int2);
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
LibXMLParser::parseReset ()
{
  xmlCtxtResetPush(mParser, 0, 0, 0, 0);

  delete mSource;
  mSource = NULL;
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
