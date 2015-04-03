/**
 *@cond doxygenLibsbmlInternal 
 **
 *
 * @file    OutputCompressor.h
 * @brief   utility class for output compression
 * @author  Akiya Jouraku
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#ifndef OutputCompressor_h
#define OutputCompressor_h

#include <iostream>
#include <sbml/common/extern.h>
#include <sbml/compress/CompressCommon.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN OutputCompressor
{
public:

 /**
  * Opens the given gzip file as a gzofstream (subclass of std::ofstream class) object
  * for write access and returned the stream object.
  *
  * @param filename a string, the gzip file name to be written.
  *
  * @note ZlibNotLinked will be thrown if zlib is not linked with libSBML at compile time.
  *
  * @return a ostream* object bound to the given gzip file or NULL if the initialization
  * for the object failed.
  */
  static std::ostream* openGzipOStream(const std::string& filename);


 /**
  * Opens the given bzip2 file as a bzofstream (subclass of std::ofstream class) object
  * for write access and returned the stream object.
  *
  * @param filename a string, the bzip2 file name to be written.
  *
  * @note Bzip2NotLinked will be thrown if zlib is not linked with libSBML at compile time.
  *
  * @return a ostream* object bound to the given bzip2 file or NULL if the initialization
  * for the object failed.
  */
  static std::ostream* openBzip2OStream(const std::string& filename);


 /**
  * Opens the given zip file as a zipofstream (subclass of std::ofstream class) object
  * for write access and returned the stream object.
  *
  * @param filename a string, the zip archive file name to be written.
  * @param filenameinzip a string, the file name to be archived in the above zip archive file.
  * ('filenameinzip' will be extracted when the 'filename' is unzipped)
  *
  * @note ZlibNotLinked will be thrown if zlib is not linked with libSBML at compile time.
  *
  * @return a ostream* object bound to the given zip file or NULL if the initialization
  * for the object failed.
  */
  static std::ostream* openZipOStream(const std::string& filename, const std::string& filenameinzip);

};

LIBSBML_CPP_NAMESPACE_END

#endif // OutputCompressor_h

/** @endcond */
