/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XercesTranscode.h
 * @brief   Transcodes a Xerces-C++ XMLCh* string to the local code page.
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

#ifndef XercesTranscode_h
#define XercesTranscode_h

#ifdef __cplusplus

#include <string>
#include <xercesc/util/XMLString.hpp>
#include <sbml/common/libsbml-namespace.h>

LIBSBML_CPP_NAMESPACE_BEGIN

#if XERCES_VERSION_MAJOR <= 2
typedef unsigned int XercesSize_t;
typedef XMLSSize_t   XercesFileLoc;
#else
typedef XMLSize_t    XercesSize_t;
typedef XMLFileLoc   XercesFileLoc;
#endif


/**
 * Transcodes a Xerces-C++ XMLCh* string to the UTF8 string.  This
 * class offers implicit conversion to a C++ string and destroys the
 * transcoded buffer when the XercesTranscode object goes out of scope.
 */
class XercesTranscode
{
public:

  XercesTranscode (const XMLCh* s) :
    mBuffer( transcodeToUTF8(s) ) { }

  ~XercesTranscode     () { delete [] mBuffer; }
  operator std::string () { return std::string(mBuffer); }


private:

  char* mBuffer;

  XercesTranscode  ();
  XercesTranscode  (const XercesTranscode&);
  XercesTranscode& operator= (const XercesTranscode&);

 /**
  * convert the given internal XMLCh* string to the UTF-8 char* string.
  */
  char* transcodeToUTF8(const XMLCh* src_str);

};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* XercesTranscode_h */

/** @endcond */
