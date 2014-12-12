/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ExpatHandler.cpp
 * @brief   Redirect Expat events to an XMLHandler
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

#include <expat.h>

#include <sbml/xml/XMLHandler.h>
#include <sbml/xml/XMLTriple.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLError.h>
#include <sbml/xml/XMLErrorLog.h>

#include <sbml/xml/ExpatAttributes.h>
#include <sbml/xml/ExpatHandler.h>

#include <sbml/util/util.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * The functions below are internal to this file.  They simply redirect to
 * the corresponding ExpatHandler method (assuming UserData contains a
 * pointer to ExpatHandler).  I first saw this redirect scheme used in
 * Stefan Hoops' ExpatParser class.
 */

static void
XMLDeclHandler (void* userData,
                const XML_Char* version,
                const XML_Char* encoding,
                int)
{
  // call this function even if version or encoding arent set
  //if (version == 0) return;
  //if (encoding == 0) return;
  static_cast<ExpatHandler*>(userData)->XML(version, encoding);
}


static void
startElement (void* userData, const XML_Char* name, const XML_Char** attrs)
{
  static_cast<ExpatHandler*>(userData)->startElement(name, attrs);
}


static void
startNamespace (void* userData, const XML_Char* prefix, const XML_Char* uri)
{
  static_cast<ExpatHandler*>(userData)->startNamespace(prefix, uri);
}


static void
endElement (void* userData, const XML_Char* name)
{
  static_cast<ExpatHandler*>(userData)->endElement(name);
}


static void
characters (void* userData, const XML_Char* chars, int length)
{
  static_cast<ExpatHandler*>(userData)->characters(chars, length);
}


static int
unknownEncodingHandler(void* encodingHandlerData,
		       const XML_Char* name,
		       XML_Encoding* info)
{
  return XML_STATUS_ERROR;
}


/**
 * Creates a new ExpatHandler.  Expat events will be redirected to the
 * given XMLHandler.
 */
ExpatHandler::ExpatHandler (XML_Parser parser, XMLHandler& handler) :
   mParser ( parser  )
 , mHandler( handler )
{
  XML_SetXmlDeclHandler      ( mParser, LIBSBML_CPP_NAMESPACE ::XMLDeclHandler    );
  XML_SetElementHandler      ( mParser, LIBSBML_CPP_NAMESPACE ::startElement, 
                                        LIBSBML_CPP_NAMESPACE ::endElement        );
  XML_SetCharacterDataHandler( mParser, LIBSBML_CPP_NAMESPACE ::characters        );
  XML_SetNamespaceDeclHandler( mParser, LIBSBML_CPP_NAMESPACE ::startNamespace, 0 );
  XML_SetUserData            ( mParser, static_cast<void*>(this)     );
  XML_SetReturnNSTriplet     ( mParser, 1                            );
  mHandlerError = NULL;
  setHasXMLDeclaration(false);
}


/**
* Copy Constructor
*/
ExpatHandler::ExpatHandler (const ExpatHandler& other)
  : mParser  (other.mParser)
  , mHandler (other.mHandler)
  , mNamespaces (other.mNamespaces)
  , mHandlerError(NULL)
{
}


/**
* Assignment operator
*/
ExpatHandler& ExpatHandler::operator=(const ExpatHandler& other)
{
  if (this == &other) return *this;

  mParser = other.mParser;
  mHandler = other.mHandler; 
  mNamespaces = other.mNamespaces;
  mHandlerError = NULL;

  return *this;
}


/**
* Destroys this ExpatHandler.
 */
ExpatHandler::~ExpatHandler ()
{
}


/**
 * Receive notification of the beginning of the document.
 */
void
ExpatHandler::startDocument ()
{
  mHandler.startDocument();
}


/**
 * Receive notification of the XML declaration, i.e.
 * <?xml version="1.0" encoding="UTF-8"?>
 */
int
ExpatHandler::XML (const XML_Char* version, const XML_Char* encoding)
{
  setHasXMLDeclaration(true);

  XML_SetUnknownEncodingHandler( mParser, &unknownEncodingHandler, 0 );
  if (encoding == NULL)
  {
    mHandler.XML(version, "");
    return XML_STATUS_ERROR;
  }
  else if (version == NULL)
  {
    mHandler.XML("", encoding);
    return XML_STATUS_ERROR;
  }
  else
  {
    mHandler.XML(version, encoding);
  }

  return 0;
}


/**
 * Receive notification of the start of an element.
 *
 * @param  name   The element name
 * @param  attrs  The specified or defaulted attributes
 */
void
ExpatHandler::startElement (const XML_Char* name, const XML_Char** attrs)
{
  const XMLTriple       triple    ( name  );
  const ExpatAttributes attributes( attrs, name );
  const XMLToken        element   ( triple, attributes, mNamespaces,
			            getLine(), getColumn() );

  mHandler.startElement(element);
  mNamespaces.clear();
}


/**
 * Receive notification of the start of an XML namespace.
 *
 * @param  prefix  The namespace prefix or NULL (for xmlns="...")
 * @param  uri     The namespace uri    or NULL (for xmlns="")
 */
void
ExpatHandler::startNamespace (const XML_Char* prefix, const XML_Char* uri)
{
  // Expat doesn't flag the use of the prefix 'xml' as an error, but
  // according to the XML Namespaces 1.0 (2nd ed, Aug 2006) specification,
  // "The prefix xml is by definition bound to the namespace name
  // http://www.w3.org/XML/1998/namespace. It MAY, but need not, be
  // declared, and MUST NOT be bound to any other namespace name."
  // I guess we have to catch this ourselves, then?

  if (streq(prefix, "xml")
      && !streq(uri, "http://www.w3.org/XML/1998/namespace"))
  {
    mHandlerError = new XMLError(BadXMLPrefixValue,
                                 "The prefix 'xml' is reserved in XML",
                                 getLine(), getColumn());
  }
  else
  {
    mNamespaces.add(uri ? uri : "", prefix ? prefix : "");
  }
}


/**
 * Receive notification of the end of the document.
 */
void
ExpatHandler::endDocument ()
{
  mHandler.endDocument();
}


/**
 * Receive notification of the end of an element.
 *
 * @param  name  The element name
 */
void
ExpatHandler::endElement (const XML_Char* name)
{
  const XMLTriple  triple ( name );
  const XMLToken   element( triple, getLine(), getColumn() );

  mHandler.endElement(element);
}


/**
 * Receive notification of character data inside an element.
 *
 * @param  chars   The characters
 * @param  length  The number of characters to use from the character array
 */
void
ExpatHandler::characters (const XML_Char* chars, int length)
{
  XMLToken data( string(chars, length) );
  mHandler.characters(data);
}


/**
 * @return the column number of the current XML event.
 */
unsigned int
ExpatHandler::getColumn () const
{
  return static_cast<unsigned int>( XML_GetCurrentColumnNumber(mParser) );
}


/**
 * @return the line number of the current XML event.
 */
unsigned int
ExpatHandler::getLine () const
{
  return static_cast<unsigned int>( XML_GetCurrentLineNumber(mParser) );
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
