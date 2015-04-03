/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLMemoryBuffer.h
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

#ifndef XMLMemoryBuffer_h
#define XMLMemoryBuffer_h

#include <sbml/xml/XMLBuffer.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLMemoryBuffer : public XMLBuffer
{
public:

  /**
   * Creates a XMLBuffer based on the given sequence of bytes in buffer.
   * This class copies the given character to its local buffer to avoid
   * a potential segmentation fault which could happen if the given
   * character deleted outside during the lifetime of this XMLMemoryBuffer object.
   */
  XMLMemoryBuffer (const char* buffer, unsigned int length);


  /**
   * Destroys this XMLMemoryBuffer.
   */
  virtual ~XMLMemoryBuffer ();


  /**
   * Copies at most nbytes from this XMLMemoryBuffer to the memory pointed
   * to by destination.
   *
   * @return the number of bytes actually copied (may be 0).
   */
  virtual unsigned int copyTo (void* destination, unsigned int bytes);


  /**
   * Returns true if there was an error reading from the underlying buffer
   * (i.e. it's null), false otherwise.
   *
   * @return true if there was an error reading from the underlying buffer,
   * false otherwise.
   */
  virtual bool error ();


private:

  XMLMemoryBuffer ();
  XMLMemoryBuffer (const XMLMemoryBuffer&);
  XMLMemoryBuffer& operator= (const XMLMemoryBuffer&);


  const char*   mBuffer;
  unsigned int  mLength;
  unsigned int  mOffset;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* XMLMemoryBuffer_h */

/** @endcond */
