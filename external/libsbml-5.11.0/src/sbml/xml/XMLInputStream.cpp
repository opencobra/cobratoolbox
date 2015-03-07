/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLInputStream.cpp
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
 * ---------------------------------------------------------------------- -->*/

#include <sbml/xml/XMLErrorLog.h>
#include <sbml/xml/XMLParser.h>

#include <sbml/xml/XMLInputStream.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLParser;


/*
 * Creates a new XMLInputStream.
 */
XMLInputStream::XMLInputStream (  const char*   content
                                , bool          isFile
                                , const std::string  library 
                                , XMLErrorLog*  errorLog ) :


   mIsError ( false )
 , mParser  ( XMLParser::create( mTokenizer, library) )
 , mSBMLns  ( NULL )
{
  // if the content points to nothing throw an exception ??
  //if (content == NULL)
  //  throw XMLConstructorException();

  if ( !isGood() ) return;
  if ( errorLog != NULL ) setErrorLog(errorLog);
  // if this fails we should probably flag the stream as error
  if (!mParser->parseFirst(content, isFile))
    mIsError = true; 
}

 /**
 * Copy Constructor, made private so as to notify users, that copying an input stream is not supported. 
 */
 XMLInputStream::XMLInputStream (const XMLInputStream& other)
   : mIsError(true)   
   , mParser(NULL)
   , mSBMLns(NULL)
 {
 }


 /**
 * Assignment operator, made private so as to notify users, that copying an input stream is not supported. 
 */
 XMLInputStream& XMLInputStream::operator=(const XMLInputStream& other)
 {
   if (this == &other) return *this;
   mIsError = true;
   return *this;
 }


/*
 * Destroys this XMLInputStream.
 */
XMLInputStream::~XMLInputStream ()
{
  if ( mParser != NULL )
  {
     /**
      *  set NULL to 'XMLErrorLog::mParser' (corresponding XMLErrorLog* 
      *  object was passed to the above constructer as 'errorLog') because 
      *  the corresponding 'mParser' is deleted here and can't be accessed 
      *  anymore.    
	   */
    XMLErrorLog* errorLog = mParser->getErrorLog();
    if ( errorLog != NULL ) errorLog->setParser(NULL);
  }
  delete mParser;
  delete mSBMLns;
}


/*
 * @return the encoding of the XML stream.
 */
const string&
XMLInputStream::getEncoding ()
{
  return mTokenizer.getEncoding();
}


/*
 * @return the version of the XML stream.
 */
const string&
XMLInputStream::getVersion ()
{
  return mTokenizer.getVersion();
}


/*
 * @return an XMLErrorLog which can be used to log XML parse errors and
 * other validation errors (and messages).
 */
XMLErrorLog*
XMLInputStream::getErrorLog ()
{
  return mParser->getErrorLog();
}


/*
 * @return true if end of file (stream) has been reached, false otherwise.
 */
bool
XMLInputStream::isEOF () const
{
  return mTokenizer.isEOF();
}


/*
 * @return true if a fatal error occurred while reading from this stream.
 */
bool
XMLInputStream::isError () const
{
  return (mIsError || mParser == NULL);
}


/*
 * @return true if the stream is in a good state (i.e. isEOF() and
 * isError() are both false), false otherwise.
 */
bool
XMLInputStream::isGood () const
{
  return (isError() == false && isEOF() == false);
}


/*
 * Consumes the next XMLToken and return it.
 *
 * @return the next XMLToken or EOF (XMLToken.isEOF() == true).
 */
XMLToken
XMLInputStream::next ()
{
  queueToken();
  return mTokenizer.hasNext() ? mTokenizer.next() : XMLToken();
}


/*
 * Returns the next XMLToken without consuming it.  A subsequent call to
 * either peek() or next() will return the same token.
 *
 * @return the next XMLToken or EOF (XMLToken.isEOF() == true).
 */
const XMLToken&
XMLInputStream::peek ()
{
  queueToken();
  return mTokenizer.hasNext() ? mTokenizer.peek() : mEOF;
}


/*
 * Runs mParser until mTokenizer is ready to deliver at least one XMLToken
 * or a fatal error occurs.
 */
void
XMLInputStream::queueToken ()
{
  if ( !isGood() ) return;

  bool success = true;

  while ( success && mTokenizer.hasNext() == false )
  {
    success = mParser->parseNext();
  }

  if (success == false && isEOF() == false)
  {
    mIsError = true;
  }
}


bool
XMLInputStream::requeueToken ()
{
  bool success = false;
  if ( !isGood() ) return success;
  else if (this->mTokenizer.mEOFSeen == true) return success;

  success = mParser->parseNext();

  if (success == false && isEOF() == false)
  {
    mIsError = true;
  }

  return success;
}


/*
 * Sets the XMLErrorLog this stream will use to log errors.
 */
int
XMLInputStream::setErrorLog (XMLErrorLog* log)
{
  return mParser->setErrorLog(log);
}


/*
 * Consume zero or more XMLTokens up to and including the corresponding
 * end XML element or EOF.
 */
void
XMLInputStream::skipPastEnd (const XMLToken& element)
{
  if ( element.isEnd() ) return;

  while ( isGood() && !peek().isEndFor(element) ) next();
  next();
}


/*
 * Consume zero or more XMLTokens up to but not including the next XML
 * element or EOF.
 */
void
XMLInputStream::skipText ()
{
  while ( isGood() && peek().isText() ) next();
}


/*
 * Prints a string representation of the underlying token stream, for
 * debugging purposes.
 */
string
XMLInputStream::toString ()
{
  return mTokenizer.toString();
}

SBMLNamespaces *
XMLInputStream::getSBMLNamespaces()
{
  return mSBMLns;
}

void
XMLInputStream::setSBMLNamespaces(SBMLNamespaces * sbmlns)
{
  if (mSBMLns == sbmlns) return;
  delete mSBMLns;
  if (sbmlns != NULL)
  {
    mSBMLns = sbmlns->clone();
  }
  else
  {
    mSBMLns = NULL;
  }
}

unsigned int
XMLInputStream::determineNumberChildren(const std::string& elementName)
{
  bool valid = false;
  unsigned int num = this->mTokenizer.determineNumberChildren(valid, elementName);

  bool canReQ = true;
  while (canReQ == true && isGood() == true && valid == false)
  {
    canReQ = requeueToken();
    if (canReQ == true)
    {
      num = this->mTokenizer.determineNumberChildren(valid, elementName);
    }
  }

  return num;
}


unsigned int
XMLInputStream::determineNumSpecificChildren(const std::string& childName,
                                             const std::string& container)
{
  bool valid = false;
  unsigned int num = this->mTokenizer.determineNumSpecificChildren(valid, 
                                                       childName, container);

  while (isGood() == true && valid == false)
  {
    requeueToken();
    if (isGood() == true)
    {
      num = this->mTokenizer.determineNumSpecificChildren(valid, 
                                                       childName, container);
    }
  }

  return num;
}

LIBLAX_EXTERN
XMLInputStream_t *
XMLInputStream_create (const char* content, int isFile, const char *library)
{
  if (content == NULL || library == NULL) return NULL;
  return new(nothrow) XMLInputStream(content, isFile, library);
}


LIBLAX_EXTERN
void
XMLInputStream_free (XMLInputStream_t *stream)
{
  if (stream == NULL) return;
  delete static_cast<XMLInputStream*>(stream);
}  


LIBLAX_EXTERN
const char *
XMLInputStream_getEncoding (XMLInputStream_t *stream)
{
  if (stream == NULL) return NULL;
  return stream->getEncoding().empty() ? NULL : stream->getEncoding().c_str();
}


LIBLAX_EXTERN
XMLErrorLog_t *
XMLInputStream_getErrorLog (XMLInputStream_t *stream)
{
  if (stream == NULL) return NULL;
  return stream->getErrorLog();
}


LIBLAX_EXTERN
int
XMLInputStream_isEOF (XMLInputStream_t *stream)
{
  if (stream == NULL) return (int)false;
  return static_cast<int>(stream->isEOF());
}


LIBLAX_EXTERN
int
XMLInputStream_isError (XMLInputStream_t *stream)
{
  if (stream == NULL) return (int)false;
  return static_cast<int>(stream->isError());
}


LIBLAX_EXTERN
int
XMLInputStream_isGood (XMLInputStream_t *stream)
{
  if (stream == NULL) return (int)false;
  return static_cast<int>(stream->isGood());
}


LIBLAX_EXTERN
XMLToken_t *
XMLInputStream_next (XMLInputStream_t *stream)
{
  if (stream == NULL) return NULL;
  return new (nothrow) XMLToken(stream->next());
}


LIBLAX_EXTERN
const XMLToken_t *
XMLInputStream_peek (XMLInputStream_t *stream)
{
  if (stream == NULL) return NULL;
  return &(stream->peek());
}


LIBLAX_EXTERN
void
XMLInputStream_skipPastEnd (XMLInputStream_t *stream,
			    const XMLToken_t *element)
{
  if (stream == NULL || element == NULL) return;
  stream->skipPastEnd(*element);
}


LIBLAX_EXTERN
void
XMLInputStream_skipText (XMLInputStream_t *stream)
{
  if (stream == NULL) return;
  stream->skipText();
}


LIBLAX_EXTERN
int
XMLInputStream_setErrorLog (XMLInputStream_t *stream, XMLErrorLog_t *log)
{
  if (stream == NULL ) return LIBSBML_OPERATION_FAILED;
  return stream->setErrorLog(log);
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
