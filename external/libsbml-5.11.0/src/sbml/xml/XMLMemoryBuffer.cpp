/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLMemoryBuffer.cpp
 * @brief   XMLMemoryBuffer implements the XMLBuffer interface for files
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

#include <cstring>
#include <sbml/xml/XMLMemoryBuffer.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a XMLBuffer based on the given sequence of bytes in buffer.
 * This class copies the given character to its local buffer to avoid
 * a potential segmentation fault which could happen if the given
 * character deleted outside during the lifetime of this XMLMemoryBuffer object.
 */
XMLMemoryBuffer::XMLMemoryBuffer (const char* buffer, unsigned int length) :
   mBuffer( NULL   )
 , mLength( length )
 , mOffset( 0      )
{
  if (buffer == NULL) return;
  
  size_t bufsize  = strlen(buffer);
  char* tmpbuf = new char[bufsize+1];

  strncpy(tmpbuf, buffer, bufsize+1);
  mBuffer = tmpbuf;
}


/*
 * Destroys this XMLMemoryBuffer.
 */
XMLMemoryBuffer::~XMLMemoryBuffer ()
{
  delete[] mBuffer;
}


/*
 * Copies at most nbytes from this XMLMemoryBuffer to the memory pointed
 * to by destination.
 *
 * @return the number of bytes actually copied (may be 0).
 */
unsigned int
XMLMemoryBuffer::copyTo (void* destination, unsigned int bytes)
{
  if (mOffset > mLength) return 0;
  if (mOffset + bytes > mLength) bytes = mLength - mOffset;

  memcpy(destination, mBuffer + mOffset, bytes);
  mOffset += bytes;

  return bytes;
}


/*
 * @return true if there was an error reading from the underlying buffer
 * (i.e. it's null), false otherwise.
 */
bool
XMLMemoryBuffer::error ()
{
  return (mBuffer == NULL);
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
