/**
 *@cond doxygenLibsbmlInternal
 **
 *
 * @file    CompressCommon.cpp
 * @brief   common classes/functions for compression/decompression I/O
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

#include <sbml/compress/CompressCommon.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * Predicate returning @c true or @c false depending on whether
 * libSBML is linked with zlib at compile time.
 *
 * @return @c true if zlib is linked, @c false otherwise.
 */
LIBSBML_EXTERN
bool hasZlib() 
{
#ifdef USE_ZLIB
  return true;
#else
  return false;
#endif // USE_ZLIB
}

/**
 * Predicate returning @c true or @c false depending on whether
 * libSBML is linked with bzip2 at compile time.
 *
 * @return @c true if bzip2 is linked, @c false otherwise.
 */
LIBSBML_EXTERN
bool hasBzip2() 
{
#ifdef USE_BZ2
  return true;
#else
  return false;
#endif // USE_BZ2
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
