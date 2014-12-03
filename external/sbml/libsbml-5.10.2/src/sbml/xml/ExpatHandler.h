/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ExpatHandler.h
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

#ifndef ExpatHandler_h
#define ExpatHandler_h

#ifdef __cplusplus

#include <string>

#include <expat.h>
#include <sbml/xml/XMLHandler.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLError.h>


LIBSBML_CPP_NAMESPACE_BEGIN


class ExpatHandler
{
public:

  /**
   * Creates a new ExpatHandler.  Expat events will be redirected to the
   * given XMLHandler.
   */
  ExpatHandler (XML_Parser parser, XMLHandler& handler);


  /**
   * Copy Constructor
   */
  ExpatHandler (const ExpatHandler& other);


  /**
   * Assignment operator
   */
  ExpatHandler& operator=(const ExpatHandler& other);


  /**
   * Destroys this ExpatHandler.
   */
  virtual ~ExpatHandler ();


  /**
   * Receive notification of the beginning of the document.
   */
  void startDocument ();


  /**
   * Receive notification of the XML declaration, i.e.
   * <?xml version="1.0" encoding="UTF-8"?>
   */
  int XML (const XML_Char* version, const XML_Char* encoding);


  /**
   * Receive notification of the start of an element.
   *
   * @param  name   The element name
   * @param  attrs  The specified or defaulted attributes
   */
  void startElement (const XML_Char* name, const XML_Char** attrs);


  /**
   * Receive notification of the start of an XML namespace.
   *
   * @param  prefix  The namespace prefix or NULL (for xmlns="...")
   * @param  uri     The namespace uri    or NULL (for xmlns="")
   */
  void startNamespace (const XML_Char* prefix, const XML_Char* uri);


  /**
   * Receive notification of the end of the document.
   */
  void endDocument ();


  /**
   * Receive notification of the end of an element.
   *
   * @param  name  The element name
   */
  void endElement (const XML_Char* name);


  /**
   * Receive notification of character data inside an element.
   *
   * @param  chars   The characters
   * @param  length  The number of characters to use from the character array
   */
  void characters (const XML_Char* chars, int length);


  /**
   * Returns the column number of the current XML event.
   *
   * @return the column number of the current XML event.
   */
  unsigned int getColumn () const;


  /**
   * Returns the line number of the current XML event.
   *
   * @return the line number of the current XML event.
   */
  unsigned int getLine () const;


  /**
   * Returns true or false depending on whether the handler
   * caught an error in-between our (liblax) code and Expat.
   */
  XMLError* error() { return mHandlerError; };

  bool hasXMLDeclaration() { return gotXMLDecl; } 
  void setHasXMLDeclaration(bool value) { gotXMLDecl = value; }

protected:

  bool gotXMLDecl;

  XML_Parser    mParser;
  XMLHandler&   mHandler;
  XMLNamespaces mNamespaces;

  XMLError*     mHandlerError;

};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* ExpatHandler_h */

/** @endcond */
