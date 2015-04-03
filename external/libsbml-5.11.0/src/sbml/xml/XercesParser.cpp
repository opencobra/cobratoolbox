/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XercesParser.cpp
 * @brief   Adapts the Xerces-C++ XML parser to the XMLParser interface
 * @author  Ben Bornstein
 * @author  Michael Hucka
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

#include <cstring>
#include <iostream>
#include <sstream>

#include <xercesc/framework/LocalFileInputSource.hpp>
#include <xercesc/framework/MemBufInputSource.hpp>
#include <xercesc/parsers/SAX2XMLReaderImpl.hpp>
#include <xercesc/sax2/XMLReaderFactory.hpp>
#include <xercesc/util/PlatformUtils.hpp>

#include <sbml/xml/XMLHandler.h>
#include <sbml/xml/XMLErrorLog.h>

#include <sbml/xml/XercesTranscode.h>
#include <sbml/xml/XercesParser.h>

#include <sbml/compress/CompressCommon.h>
#include <sbml/compress/InputDecompressor.h>

#include <sbml/common/common.h>

using namespace std;
using namespace xercesc;

LIBSBML_CPP_NAMESPACE_BEGIN


/*
 * Table mapping Xerces error codes to ours.  The error code numbers are not
 * contiguous, hence the table has to map pairs of numbers rather than
 * simply being an array of codes.  The table is an array of vectors of
 * items [xerces code, our code], where `our code' is an error code
 * taken from the enumeration XMLParser::errorCodes.
 *
 * See  /include/xercesc/framework/XMLErrorCodes.hpp
 * and /src/xerces-c-src_2_7_0/src/xercesc/NLS/EN_US/XMLErrList_EN_US.Xml
 */ 
static struct xercesError {
  const int            xercesCode;
  const XMLErrorCode_t ourCode;
} xercesErrorTable[] = {
  { XMLErrs::AttrAlreadyUsedInSTag,        DuplicateXMLAttribute},
  { XMLErrs::NotationAlreadyExists,        BadlyFormedXML},
  { XMLErrs::AttListAlreadyExists,         BadlyFormedXML},
  { XMLErrs::XMLException_Warning,         BadlyFormedXML},
  { XMLErrs::BadDigitForRadix,             XMLBadNumber},
  { XMLErrs::BadStandalone,                BadXMLDecl},
  { XMLErrs::BadXMLEncoding,               BadXMLDecl},
  { XMLErrs::BadXMLVersion,                BadXMLDecl},
  { XMLErrs::ColonNotLegalWithNS,          XMLBadColon},
  { XMLErrs::DeclStringRep,                BadXMLDecl},
  { XMLErrs::EmptyMainEntity,              XMLContentEmpty},
  { XMLErrs::EncodingRequired,             MissingXMLEncoding},
  { XMLErrs::EntityNotFound,               UndefinedXMLEntity},
  { XMLErrs::ExpectedAttrValue,            BadlyFormedXML},
  { XMLErrs::ExpectedComment,              BadlyFormedXML},
  { XMLErrs::ExpectedCommentOrPI,          BadXMLComment},
  { XMLErrs::ExpectedDeclString,           BadXMLDecl},
  { XMLErrs::ExpectedEndOfTagX,            XMLTagMismatch},
  { XMLErrs::ExpectedEqSign,               BadlyFormedXML},
  { XMLErrs::ExpectedQuotedString,         XMLExpectedQuotedString},
  { XMLErrs::ExpectedWhitespace,           BadlyFormedXML},
  { XMLErrs::IllegalSequenceInComment,     BadXMLComment},
  { XMLErrs::InvalidCharacter,             InvalidCharInXML},
  { XMLErrs::InvalidCharacterInAttrValue,  InvalidCharInXML},
  { XMLErrs::InvalidDocumentStructure,     BadXMLDocumentStructure},
  { XMLErrs::MoreEndThanStartTags,         XMLTagMismatch},
  { XMLErrs::NoEmptyStrNamespace,          BadXMLPrefix},
  { XMLErrs::NoPIStartsWithXML,            BadXMLDeclLocation},
  { XMLErrs::NoUseOfxmlnsAsPrefix,         BadXMLPrefix},
  { XMLErrs::NoUseOfxmlnsURI,              BadXMLPrefixValue},
  { XMLErrs::NotValidAfterContent,         InvalidAfterXMLContent},
  { XMLErrs::PINameExpected,               BadProcessingInstruction},
  { XMLErrs::PartialTagMarkupError,        XMLTagMismatch},
  { XMLErrs::PrefixXMLNotMatchXMLURI,      BadXMLPrefixValue},
  { XMLErrs::StandaloneNotLegal,           BadXMLDecl},
#if XERCES_VERSION_MAJOR <= 2
  { XMLErrs::UnexpectedEOF,                XMLUnexpectedEOF},
#endif
  { XMLErrs::UnknownPrefix,                BadXMLPrefix},
  { XMLErrs::UnsupportedXMLVersion,        BadXMLDecl},
  { XMLErrs::UnterminatedComment,          BadXMLComment},
  { XMLErrs::UnterminatedEndTag,           BadlyFormedXML},
  { XMLErrs::UnterminatedPI,               BadlyFormedXML},
  { XMLErrs::UnterminatedStartTag,         BadlyFormedXML},
  { XMLErrs::UnterminatedXMLDecl,          BadXMLDecl},
  { XMLErrs::XMLDeclMustBeFirst,           BadXMLDeclLocation},
  { XMLErrs::XMLDeclMustBeLowerCase,       BadXMLDecl},
  { XMLErrs::XMLException_Fatal,           UnrecognizedXMLParserCode},
  { XMLErrs::XMLVersionRequired,           BadXMLDecl},
  { XMLErrs::ExpectedCommentOrCDATA,       BadlyFormedXML},
  { XMLErrs::ExpectedAttrName,             BadlyFormedXML},
#if XERCES_VERSION_MINOR >= 8
  { XMLErrs::DuplicateDocTypeDecl,         BadXMLDOCTYPE},
#endif
  { XMLErrs::BadSchemaLocation,            BadXMLAttributeValue},

  // The next one should always be last.  It's used only as a marker.
  { XMLErrs::F_HighBounds,                 XMLUnknownError},
};



const XMLErrorCode_t
translateError(const int xercesCode)
{
  unsigned int tableSize = sizeof(xercesErrorTable)/sizeof(xercesErrorTable[0]);

  if (xercesCode > 0 && xercesCode < XMLErrs::F_HighBounds)
  {
    // Iterate through the table, searching for a match for the given code.
    // Yes, this is inefficient, but if we're already in an exception,
    // who cares how efficient the error look-up is?

    for (unsigned int i = 0; i < tableSize; i++)
    {
      if (xercesErrorTable[i].xercesCode == xercesCode)
	      return xercesErrorTable[i].ourCode;
    }

    // If we get here, we haven't found it in the table.  This means Xerces
    // returned a code we don't have, either because our table is
    // incomplete or because this version of Xerces is somehow different
    // from what we tested.  Bad news either way.

    return UnrecognizedXMLParserCode;
  }

  // The given code is outside the range of numbers in which known Xerces
  // codes lie.  Really bad news, and means something is wrong with our code.

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
XercesParser::reportError (const XMLErrorCode_t code,
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

    cerr << XMLError::getStandardMessage(code)
	 << "  Error found at line and column numbers " << line << ":" << column << ":\n"
	 << extraMsg << endl;
#endif
  }
}


/**
 * Subclass of Xerces' `SAXParseException' that can store the error code.
 */
class OurSAXParseException : public SAXParseException
{
public:
  /**
    * Create a new instance of OurSAXParseException.
    * See also the `SAXParseException' in Xerces 2.7.0.
    *
    * @param message The error or warning message.
    * @param publicId The public identifer of the entity that generated
    *                 the error or warning.
    * @param systemId The system identifer of the entity that generated
    *                 the error or warning.
    * @param lineNumber The line number of the end of the text that
    *                   caused the error or warning.
    * @param columnNumber The column number of the end of the text that
    *                     caused the error or warning.
    * @param manager    Pointer to the memory manager to be used to
    *                   allocate objects.
    * @param errorCode  Integer error code of what caused this exception.
    *
    * @see Parser#setLocale
    */
  OurSAXParseException
    (
     const int               theErrorCode
     , const XMLCh* const    theMessage
     , const XMLCh* const    thePublicId
     , const XMLCh* const    theSystemId
     , const XercesFileLoc   theLineNumber
     , const XercesFileLoc   theColumnNumber 
    ) : SAXParseException(theMessage, thePublicId, theSystemId,
			  theLineNumber, theColumnNumber)
      
  {
    lastXercesError = theErrorCode;

    switch (theErrorCode) {

    case XMLErrs::NotationAlreadyExists:
    case XMLErrs::AttListAlreadyExists:
    case XMLErrs::XMLException_Warning:
      line   = LIBSBML_UNKNOWN_LINE;
      column = LIBSBML_UNKNOWN_COLUMN;
      break;

    default:
      line   = static_cast<XMLSSize_t>(theLineNumber);
      column = static_cast<XMLSSize_t>(theColumnNumber);

    }
  };

  
  /**
   * In some circumstances, attempting to get a line number is a bad idea
   * because Xerces returns junk.  On some architectures (e.g., 32-bit
   * Linux Fedora Core), attempting to get a line number causes a seg
   * fault.
   */
  XMLSSize_t getColumnNumber() const {
    return column;
  }

  XMLSSize_t getLineNumber() const {
    return line;
  }


  /**
   * Last error code returned by the Xerces parser when it threw a
   * `SAXParseException'.
   */
  int        lastXercesError;
  
  /**
   * Last error's line and column numbers.  This is only needed because
   * sometimes we have to clean up the values returned by Xerces.
   */
  XMLSSize_t line;
  XMLSSize_t column;
};


/**
 * XercesReader is a specialization of the default SAX2XMLReader that
 * captures and redirects XML declarations and some special errors.
 */
class XercesReader : public SAX2XMLReaderImpl
{
public:

  XercesReader (XMLHandler& handler) : mHandler(handler), gotXMLDecl (false) { }
  virtual ~XercesReader () { }

  /**
   * This method is used to report the XML decl scanned by the parser.
   * Refer to the XML specification to see the meaning of parameters.
   */
  virtual void XMLDecl (  const XMLCh* const version
                        , const XMLCh* const encoding
                        , const XMLCh* const standalone
                        , const XMLCh* const autoEncoding
		       )
  {
    mHandler.XML( XercesTranscode(version), XercesTranscode(encoding) );
    setHasXMLDeclaration(true);
  }

  /**
   * The default error definition for SAX2XMLReaderImpl throws away the
   * error code and doesn't report it, even if you install a custom
   * error handler.  (SAXParseException doesn't even have a field for
   * the error number.  WTF?)  We want that error code number.  There 
   * doesn't seem to be a way to get it except by overriding the 
   * definition of the `error' method.
   */
  virtual void error (  const unsigned int                errCode
		      , const XMLCh* const                msgDomain
		      , const XMLErrorReporter::ErrTypes  errType
		      , const XMLCh* const                errorText
		      , const XMLCh* const                systemId
		      , const XMLCh* const                publicId
		      , const XercesFileLoc               lineNum
		      , const XercesFileLoc               colNum
		     )
  {
    OurSAXParseException toThrow =
      OurSAXParseException(errCode, errorText, publicId, systemId,
                           lineNum, colNum);
    throw toThrow;
  }

  XMLHandler&  mHandler;

  bool hasXMLDeclaration() { return gotXMLDecl; } 
  void setHasXMLDeclaration(bool value) { gotXMLDecl = value; }

protected:

  bool gotXMLDecl;
};


/**
 * Creates a new XercesParser.  The parser will notify the given XMLHandler
 * of parse events and errors.
 */
XercesParser::XercesParser (XMLHandler& handler) :
   mReader         ( NULL    )
 , mSource         ( NULL    )
 , mHandler        ( handler )
{
  try
  {
    XMLPlatformUtils::Initialize();

    mReader = new XercesReader(handler); // XMLReaderFactory::createXMLReader();

    mReader->setContentHandler(&mHandler);
    mReader->setErrorHandler(&mHandler);

    mReader->setFeature( XMLUni::fgSAX2CoreNameSpaces,            true );
    mReader->setFeature( XMLUni::fgSAX2CoreNameSpacePrefixes,     true );
    mReader->setFeature( XMLUni::fgXercesValidationErrorAsFatal,  true );
    mReader->setFeature( XMLUni::fgXercesContinueAfterFatalError, false );
  }
  catch (...)
  {
  }
}


/**
 * Destroys this XercesParser.
 */
XercesParser::~XercesParser ()
{
  delete mReader;
  delete mSource;
  XMLPlatformUtils::Terminate();
}


/**
 * Creates a Xerces-C++ InputSource appropriate to the given XML content.
 */
InputSource*
XercesParser::createSource (const char* content, bool isFile)
{
  InputSource* source = NULL;

  if ( isFile )
  {
    std::string filename(content); 

    if (  
          ( string::npos != filename.find(".gz",  filename.length() - 3) ) ||
          ( string::npos != filename.find(".zip", filename.length() - 4) ) ||
          ( string::npos != filename.find(".bz2", filename.length() - 4) ) 
       )
    {
      char* xmlstring = NULL;
      try
      {
         // open a gzip file
         if ( string::npos != filename.find(".gz", filename.length() - 3) )
         {
           xmlstring = InputDecompressor::getStringFromGzip(filename);
         }
         // open a bz2 file
         else if ( string::npos != filename.find(".bz2", filename.length() - 4) )
         {
           xmlstring = InputDecompressor::getStringFromBzip2(filename);
         }
         // open a zip file
         else if ( string::npos != filename.find(".zip", filename.length() - 4) )
         {
           xmlstring = InputDecompressor::getStringFromZip(filename);
         }
      }
      catch(const char* error)
      {
        reportError(XMLFileUnreadable, error, 0, 0);
        return source;
      }
      catch ( ZlibNotLinked& )
      {
        // libSBML is not linked with zlib.
        std::ostringstream oss;
        oss << "Tried to read " << content << ". Reading a gzip/zip file is not enabled because "
            << "underlying libSBML is not linked with zlib."; 
        reportError(XMLFileUnreadable, oss.str(), 0, 0);
        return source;
      }
      catch ( Bzip2NotLinked& )
      {
        // libSBML is not linked with bzip2.
        std::ostringstream oss;
        oss << "Tried to read " << content << ". Reading a bzip2 file is not enabled because "
            << "underlying libSBML is not linked with bzip2."; 
        reportError(XMLFileUnreadable, oss.str(), 0, 0);
        return source;
      }
 
      if ( xmlstring == NULL || strlen(xmlstring) == 0)
      {
         reportError(XMLOutOfMemory, "The given compressed file can't be read into a string", 0, 0);
         return source;
      }

      unsigned int   size   = strlen(xmlstring);
      const XMLByte* bytes  = reinterpret_cast<const XMLByte*>(xmlstring);

      try
      {
        source = new MemBufInputSource(bytes, size, "FromString", true); 
      }
      catch (...)
      {
      }

      if ( source == NULL ) reportError(XMLOutOfMemory, content, 0, 0);

    }
    else
    {
      XMLCh* filename = XMLString::transcode(content);

      try
      {
        source = new LocalFileInputSource(filename);
      }
      catch (const XMLException& )
      {
        reportError(XMLFileUnreadable, content, 0, 0);
      }

      XMLString::release(&filename);
    }
  }
  else
  {
    const unsigned int size  = strlen(content);
    const XMLByte*     bytes = reinterpret_cast<const XMLByte*>(content);
    
    // It's really friggin' impossible to figure out if this Xerces call
    // can actually ever throw an exception, but I have to believe it can,
    // so let's just be prudent here.  BTW, the Xerces documentation sucks.

    try
    {
      source = new MemBufInputSource(bytes, size, "FromString", false); 
    }
    catch (...)
    {
    }

    if ( source == NULL ) reportError(XMLOutOfMemory, "", 0, 0);
  }

  return source;
}


/**
 * @return true if the parser encountered an error, false otherwise.
 */
bool
XercesParser::error () const
{
  return (mReader == NULL);
}


/**
 * @return the current column position of the parser.
 */
unsigned int
XercesParser::getColumn () const
{
  return mHandler.getColumn();
}


/**
 * @return the current line position of the parser.
 */
unsigned int
XercesParser::getLine () const
{
  return mHandler.getLine();
}


/**
 * @return true if the parse was successful, false otherwise;
 */
bool
XercesParser::parse (const char* content, bool isFile, bool isProgressive)
{
  if ( error() ) return false;

  bool result = true;

  try
  {
    mSource = createSource(content, isFile);

    if (mSource != NULL)
    {
      if (isProgressive)
      {
        mReader->parseFirst(*mSource, mToken);
      }
      else
      {
        mReader->parse(*mSource);
      }
    }
    else
    {
      result = false;
    }
  }

  // Xerces throws an exception here if the xml declaration is corrupt
  catch (const OurSAXParseException& e)
  {
    reportError(translateError(e.lastXercesError), 
      XMLString::transcode(e.getMessage()),
		e.getLineNumber(), e.getColumnNumber());
    result = false;
  }
  catch (...)
  {
    result = false;
  }

  return result;
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
XercesParser::parse (const char* content, bool isFile)
{
  return parse(content, isFile, false);
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
 * If isFile is true (default), content is treated as a filename from
 * which to read the XML content.  Otherwise, content is treated as a
 * null-terminated buffer containing XML data and is read directly.
 *
 * @return true if the first step of the progressive parse was
 * successful, false otherwise.
 */
bool
XercesParser::parseFirst (const char* content, bool isFile)
{
  if (content == NULL) return false;

  return parse(content, isFile, true);
}


/**
 * Parses the next chunk of XML content.
 *
 * @return true if the next step of the progressive parse was successful,
 * false otherwise or when at EOF.
 */
bool
XercesParser::parseNext ()
{
  bool result = true;

  if ( error() ) return false;

  try
  {
    mReader->parseNext(mToken);
  }
  catch (const OurSAXParseException& e)
  {
    reportError(translateError(e.lastXercesError), "",
		e.getLineNumber(), e.getColumnNumber());
    result = false;
  }
  catch (const XMLException& e)
  {
    // This shouldn't happen.  If it does, we should figure out how to
    // do the same trick as with OurSAXParseException so that we can
    // report canonical error numbers for this case too.

    // XMLException doesn't have a lastXercesError or getColumnNumber().

    char* msg = XMLString::transcode(e.getMessage());
    reportError(XMLUnknownError, msg, static_cast<const unsigned int>(e.getSrcLine()), 1);
    result = false;
  }
  catch (...)
  {
    reportError(XMLUnknownError, "thrown by Xerces", 0, 0);
    result = false;
  }

  if (! static_cast <XercesReader *> (mReader) ->hasXMLDeclaration())
  {
    reportError(MissingXMLDecl, "", 1, 1);
    return false;
  }

  return result;
}


/**
 * Resets the progressive parser.  Call between the last call to
 * parseNext() and the next call to parseFirst().
 */
void
XercesParser::parseReset ()
{
  if (mReader != NULL)
  {
    mReader->parseReset(mToken);
  }

  delete mSource;
  mSource = NULL;
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */


//     /* error numbers are from the expat error enumeration
//      * xerces does not enumerate its saxexceptions
//      */
//     if (strncmp(msg.c_str(), "Expected end of tag", 19) == 0)
//     {
//       nError = 7;
//     }
//     else if (strncmp(msg.c_str(), "Expected whitespace", 19) == 0)
//     {
//       msg = "Not well formed";
//       nError = 4;
//     }
//     else if (strncmp(msg.c_str(), "Expected equal sign", 19) == 0)
//     {
//       nError = 4;
//     }
//     else if (strncmp(msg.c_str(), "Expected comment or", 19) == 0)
//     {
//       nError = 4;
//     }
//     else if (strncmp(msg.c_str(), "Expected an attribute value", 27) == 0)
//     {
//       msg += " - Not well formed";
//       nError = 4;
//     }
//     else if (strncmp(msg.c_str(), "The attribute '", 15) == 0)
//     {
//       nError = 8;
//     }
//     else if (strncmp(msg.c_str(), "No processing instruction starts with", 37) == 0)
//     {
//       nError = 17;
//     }
//     else if (strncmp(msg.c_str(), "Entity '", 8) == 0)
//     {
//       nError = 11;
//     }
//     else if (strncmp(msg.c_str(), "The prefix '", 12) == 0)
//     {
//       nError = 27;
//     }
//     else if (strncmp(msg.c_str(), "The value of the attribute '", 28) == 0)
//     {
//       nError = 28;
//     }

//     getErrorLog()->add( XMLError(nError, msg, 
//       XMLError::Error, "", e.getLineNumber(), e.getColumnNumber()));
    
//     result = false;
