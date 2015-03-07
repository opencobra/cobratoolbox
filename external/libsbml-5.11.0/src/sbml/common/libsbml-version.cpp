/**
 * @file    libsbml-version.cpp
 * @brief   Define libSBML version numbers for access from client software.
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
 * ------------------------------------------------------------------------ -->
 */

#include "libsbml-version.h"
#include <string.h>

#ifdef USE_EXPAT
#include <expat.h>
#endif 

#ifdef USE_XERCES
#include <xercesc/util/XercesDefs.hpp>
#include <xercesc/util/XercesVersion.hpp>
#endif

#ifdef USE_LIBXML
#include <libxml/xmlversion.h>
#endif

#ifdef USE_ZLIB
#include <zlib.h>
#endif

#ifdef USE_BZ2
#include <bzlib.h>
#endif

LIBSBML_CPP_NAMESPACE_BEGIN

LIBSBML_EXTERN
int 
getLibSBMLVersion () 
{ 
  return LIBSBML_VERSION; 
}


LIBSBML_EXTERN
const char* 
getLibSBMLDottedVersion () 
{ 
  return LIBSBML_DOTTED_VERSION;
}


LIBSBML_EXTERN
const char* 
getLibSBMLVersionString () 
{ 
  return LIBSBML_VERSION_STRING;
}

LIBSBML_EXTERN
int 
isLibSBMLCompiledWith(const char* option)
{
  if (option == NULL) return 0;

  if (strcmp(option, "expat") == 0)
  {
#ifdef USE_EXPAT
    return 1;
#else
    return 0;
#endif
  }

  if (strcmp(option, "libxml") == 0 ||
      strcmp(option, "xml2") == 0 ||
      strcmp(option, "libxml2") == 0)
  {
#ifdef USE_LIBXML
    return LIBXML_VERSION;
#else
    return 0;
#endif
  }

  if (strcmp(option, "xerces-c") == 0 ||
    strcmp(option, "xercesc") == 0)
  {
#ifdef USE_XERCES
#ifdef _XERCES_VERSION
    return _XERCES_VERSION;
#else
    return 1;
#endif
#else
    return 0;
#endif
  }

  if (strcmp(option, "zlib") == 0 ||
    strcmp(option, "zip") == 0)
  {
#ifdef USE_ZLIB
    return ZLIB_VERNUM;
#else
    return 0;
#endif
  }

  if (strcmp(option, "bzip") == 0 ||
    strcmp(option, "bzip2") == 0 ||
    strcmp(option, "bz2") == 0)
  {
#ifdef USE_BZ2
    return 1;
#else
    return 0;
#endif
  }

  return 0;
}

LIBSBML_EXTERN
const char* 
getLibSBMLDependencyVersionOf(const char* option)
{
  if (option == NULL) return NULL;
  
  if (strcmp(option, "expat") == 0)
  {
#ifdef USE_EXPAT
    return static_cast<const char*>(XML_ExpatVersion());
#else
    return NULL;
#endif
  }

  if (strcmp(option, "libxml") == 0 ||
    strcmp(option, "libxml2") == 0)
  {
#ifdef USE_LIBXML
    return LIBXML_DOTTED_VERSION;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "xerces-c") == 0 ||
    strcmp(option, "xercesc") == 0)
  {
#ifdef USE_XERCES
    return XERCES_FULLVERSIONDOT;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "zlib") == 0 ||
    strcmp(option, "zip") == 0)
  {
#ifdef USE_ZLIB
    return ZLIB_VERSION;
#else
    return NULL;
#endif
  }

  if (strcmp(option, "bzip") == 0 ||
    strcmp(option, "bzip2") == 0 ||
    strcmp(option, "bz2") == 0)
  {
#ifdef USE_BZ2
    return BZ2_bzlibVersion();
#else
    return NULL;
#endif
  }

  return NULL;
}



LIBSBML_CPP_NAMESPACE_END


