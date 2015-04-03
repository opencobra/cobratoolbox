/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    LibXMLTranscode.h
 * @brief   Transcodes a LibXML xmlChar string to UTF-8.
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

#ifndef LibXMLTranscode_h
#define LibXMLTranscode_h

#ifdef __cplusplus

#include <string>
#include <libxml/parser.h>
#include <sbml/xml/XMLExtern.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * Transcodes a LibXML xmlChar* string to UTF-8.  This class offers
 * implicit conversion to a C++ string.
 */
class LibXMLTranscode
{
public:

  LibXMLTranscode (const xmlChar* s, int len = -1) :
    mBuffer(reinterpret_cast<const char*>(s)), mLen(len), mReplaceNCR(false) { }

  LibXMLTranscode (const xmlChar* s, bool replace, int len = -1) :
    mBuffer(reinterpret_cast<const char*>(s)), mLen(len), mReplaceNCR(replace) { }

  ~LibXMLTranscode () { }

  operator std::string ();

private:

  const char* mBuffer;
  int         mLen;
  bool        mReplaceNCR;

  LibXMLTranscode  ();
  LibXMLTranscode  (const LibXMLTranscode&);
  LibXMLTranscode& operator= (const LibXMLTranscode&);

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* LibXMLTranscode_h */

/** @endcond */
