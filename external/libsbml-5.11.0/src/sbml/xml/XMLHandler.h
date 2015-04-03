/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLHandler.h
 * @brief   XMLHandler interface
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
 * @class XMLHandler
 * @sbmlbrief{core} Unified interface to different XML parsers.
 *
 * @ifnot clike @internal @endif@~
 */

#ifndef XMLHandler_h
#define XMLHandler_h

#ifdef __cplusplus

#include <string>
#include <sbml/xml/XMLExtern.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLToken;

class LIBLAX_EXTERN XMLHandler
{
public:

  /**
   * Creates a new XMLHandler.
   */
  XMLHandler ();


  /**
   * Copy Constructor
   */
  XMLHandler (const XMLHandler& other);


  /**
   * Destroys this XMLHandler.
   */
  virtual ~XMLHandler ();


  /**
   * Receive notification of the beginning of the document.
   *
   * By default, do nothing. Application writers may override this method
   * in a subclass to take specific actions at the start of the document.
   */
  virtual void startDocument ();


  /**
   * Receive notification of the XML declaration, i.e.
   * <?xml version="1.0" encoding="UTF-8"?>
   *
   * By default, do nothing. Application writers may override this method
   * in a subclass to take specific actions at the declaration.
   */
  virtual void XML (const std::string& version, const std::string& encoding);


  /**
   * Receive notification of the start of an element.
   *
   * By default, do nothing. Application writers may override this method
   * in a subclass to take specific actions at the start of each element.
   */
  virtual void startElement (const XMLToken& element);


  /**
   * Receive notification of the end of the document.
   *
   * By default, do nothing. Application writers may override this method
   * in a subclass to take specific actions at the end of the document.
   */
  virtual void endDocument ();


  /**
   * Receive notification of the end of an element.
   *
   * By default, do nothing. Application writers may override this method
   * in a subclass to take specific actions at the end of each element.
   */
  virtual void endElement (const XMLToken& element);


  /**
   * Receive notification of character data inside an element.
   *
   * By default, do nothing. Application writers may override this method
   * to take specific actions for each chunk of character data.
   */
  virtual void characters (const XMLToken& data);
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* XMLHandler_h */

/** @endcond */
