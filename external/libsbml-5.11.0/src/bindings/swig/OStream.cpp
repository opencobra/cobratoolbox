/**
 * @file    OStream.cpp
 * @brief   Implementations of wrapper classes for C++ standard output streams. 
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include "OStream.h"

/**
  * Creates a new OStream object with one of standard output stream objects.
  * 
  * @param sot a value from the StdOSType enumeration indicating
  * the type of stream to create.
  */
OStream::OStream (StdOSType sot) 
{
  switch (sot) {
    case COUT:
      Stream = &std::cout;
      break;
    case CERR:
      Stream = &std::cerr;
      break;
    case CLOG:
      Stream = &std::clog;
      break;
    default:
      Stream = &std::cout;
  }
}

/**
 * Destructor.
 */
OStream::~OStream () 
{
}
  

/**
 * Returns the stream object.
 * <p>
 * @return the stream object
 */
std::ostream* 
OStream::get_ostream ()  
{ 
  return Stream;
}


/**
 * Writes an end-of-line character on this tream.
 */
void 
OStream::endl ()
{
  std::endl(*Stream);
}
  

/**
 * Creates a new OFStream object for a file.
 * <p>
 * This opens the given file @p filename with the @p is_append flag
 * (default is <code>false</code>), and creates an OFStream object
 * instance that associates the file's content with an OStream object.
 * <p>
 * @param filename the name of the file to open
 * @param is_append whether to open the file for appending (default:
 * <code>false</code>, meaning overwrite the content instead)
 */
OFStream::OFStream (const std::string& filename, bool is_append) 
{
  if (is_append) {
    Stream = new std::ofstream(filename.c_str(),std::ios_base::app);
  }
  else {
    Stream = new std::ofstream(filename.c_str(),std::ios_base::out);
  }
}


/**
 * Destructor.
 */
OFStream::~OFStream ()
{
  delete Stream;
}


/**
 * Opens a file and associates this stream object with it.
 * <p>
 * This method opens a given file @p filename with the given
 * @p is_append flag (whose default value is <code>false</code>),
 * and associates <i>this</i> stream object with the file's content.
 * <p>
 * @param filename the name of the file to open
 * @param is_append whether to open the file for appending (default:
 * <code>false</code>, meaning overwrite the content instead)
 */
void 
OFStream::open (const std::string& filename, bool is_append) 
{ 
  if (is_append) {
    static_cast<std::ofstream*>(Stream)->open(filename.c_str(),std::ios_base::app);
  }
  else {
    static_cast<std::ofstream*>(Stream)->open(filename.c_str(),std::ios_base::out);
  }
}  
  

/**
 * Closes the file currently associated with this stream object.
 */
void 
OFStream::close ()
{
  static_cast<std::ofstream*>(Stream)->close();
}
  

/**
 * Returns <code>true</code> if this stream object is currently
 * associated with a file.
 * <p>
 * @return <code>true</code> if the stream object is currently
 * associated with a file, <code>false</code> otherwise
 */
bool 
OFStream::is_open () 
{ 
  return static_cast<std::ofstream*>(Stream)->is_open(); 
}


/**
 * Creates a new OStringStream object
 */
OStringStream::OStringStream () 
{
  Stream = new std::ostringstream();
}
  

/**
 * Returns the copy of the string object currently assosiated 
 * with this <code>ostringstream</code> buffer.
 * <p>
 * @return a copy of the string object for this stream
 */
std::string 
OStringStream::str () 
{
  return static_cast<std::ostringstream*>(Stream)->str();
}


/**
 * Sets string @p s to the string object currently assosiated with
 * this stream buffer.
 * <p>
 * @param s the string to write to this stream
 */
void 
OStringStream::str (const std::string& s)
{
  static_cast<std::ostringstream*>(Stream)->str(s.c_str());
}


/**
 * Destructor.
 */
OStringStream::~OStringStream () 
{
  delete Stream;
}
  
