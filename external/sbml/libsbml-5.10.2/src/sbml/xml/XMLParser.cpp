/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLParser.cpp
 * @brief   XMLParser interface and factory
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


#ifdef USE_EXPAT
#include <sbml/xml/ExpatParser.h>
#endif

#ifdef USE_LIBXML
#include <sbml/xml/LibXMLParser.h>
#endif

#ifdef USE_XERCES
#include <sbml/xml/XercesParser.h>
#endif

#include <sbml/xml/XMLErrorLog.h>
#include <sbml/xml/XMLParser.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new XMLParser.  The parser will notify the given XMLHandler
 * of parse events and errors.
 */
XMLParser::XMLParser () : mErrorLog(NULL)
{
}


/*
 * Destroys this XMLParser.
 */
XMLParser::~XMLParser ()
{
}


/*
 * Creates a new XMLParser.  The parser will notify the given XMLHandler
 * of parse events and errors.
 *
 * The library parameter indicates the underlying XML library to use if
 * the XML compatibility layer has been linked against multiple XML
 * libraries.  It may be one of: "expat" (default), "libxml", or
 * "xerces".
 *
 * If the XML compatibility layer has been linked against only a single
 * XML library, the library parameter is ignored.
 */
XMLParser*
XMLParser::create (XMLHandler& handler, const string library)
{
#ifdef USE_EXPAT
  if (library.empty() || library == "expat")  return new ExpatParser(handler);
#endif

#ifdef USE_LIBXML
  if (library.empty() || library == "libxml") return new LibXMLParser(handler);
#endif

#ifdef USE_XERCES
  if (library.empty() || library == "xerces") return new XercesParser(handler);
#endif

  return NULL;
}


/*
 * @return an XMLErrorLog which can be used to log XML parse errors and
 * other validation errors (and messages).
 */
XMLErrorLog*
XMLParser::getErrorLog ()
{
  return mErrorLog;
}


/*
 * Sets the XMLErrorLog this parser will use to log errors.
 */
int
XMLParser::setErrorLog (XMLErrorLog* log)
{
  mErrorLog = log;
  if (mErrorLog != NULL) 
  {
    return mErrorLog->setParser(this);
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
