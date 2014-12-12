/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XercesTranscode.cpp
 * @brief   Transcodes a Xerces-C++ XMLCh* string to an UTF-8 string.
 * @author  Akiya Jouraku
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

#include <sbml/xml/XercesTranscode.h>
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/util/TransService.hpp>
#include <xercesc/util/XMLString.hpp>

using namespace std;
using namespace xercesc;

LIBSBML_CPP_NAMESPACE_BEGIN


/**
 * convert the given internal XMLCh* string to the UTF-8 char* string.
 */
char* 
XercesTranscode::transcodeToUTF8(const XMLCh* src_str)
{
  if ( src_str == NULL )
  {
    char* str = new char[1];
    str[0] = '\0';
    return str;
  }

  const XercesSize_t block_size = 8192;
  XMLTransService::Codes res_value;
  XMLTranscoder* transcoder = XMLPlatformUtils::fgTransService->makeNewTranscoderFor(
                                XMLRecognizer::UTF_8, res_value, block_size);

  if ( transcoder == NULL )
  {
    // this should not happen
    return xercesc::XMLString::transcode(src_str);
  }

  const XMLCh* cur_srcptr= src_str;
  XercesSize_t src_size  = XMLString::stringLen(src_str);
  XercesSize_t read_size = 0;
  XercesSize_t dst_size  = 0;
  char* utf8_str         = new char[1];

  utf8_str[0] = '\0';

  while ( read_size < src_size )
  {
    XMLByte* buf_tofill      = new XMLByte[block_size+4];
    XercesSize_t rest_size   = src_size - read_size;
    XercesSize_t tmpbuf_size = (rest_size > block_size) ? block_size : rest_size;

    XercesSize_t numchars_eaten = 0; 
    XercesSize_t numchars_dst   = 0;

    //
    // converts from the internal XMLCh* encoding to the UTF-8 encoding.
    //
    //  XMLTranscoder::UnRep_Throw   : Throw an exception.
    //  XMLTranscoder::UnRep_RepChar : Use the replacement char.
    //
    numchars_dst = transcoder->transcodeTo(cur_srcptr, tmpbuf_size, buf_tofill, block_size, 
                                           numchars_eaten, XMLTranscoder::UnRep_RepChar);

    if (numchars_dst <= block_size)
    {
      for(int i=0; i < 4; i++)
      {
        buf_tofill[numchars_dst+i] = 0;
      }
    }

    cur_srcptr += numchars_eaten;
    read_size  += numchars_eaten;
    dst_size   += numchars_dst;

    char* new_str = new char[dst_size+1]; 
    XMLString::copyString(new_str, utf8_str);
    XMLString::catString(new_str, reinterpret_cast<char*>(buf_tofill) );

    delete [] utf8_str;
    delete [] buf_tofill;

    utf8_str = new_str;
  }

  delete transcoder; 

  return utf8_str;
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
