/**
 * @file    extern.h
 * @brief   Definitions of LIBSBML_EXTERN and related things.
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

#ifndef LIBSBML_EXTERN_H
#define LIBSBML_EXTERN_H

#include <sbml/common/libsbml-namespace.h>

#if ( defined(WIN32) && !defined(CYGWIN) && !defined(__MINGW32__))

#if ( ! defined LIBSBML_STATIC )
/**
 * The following ifdef block is the standard way of creating macros which
 * make exporting from a DLL simpler. All files within this DLL are
 * compiled with the LIBSBML_EXPORTS symbol defined on the command line.
 * This symbol should not be defined on any project that uses this
 * DLL. This way any other project whose source files include this file see
 * LIBSBML_EXTERN functions as being imported from a DLL, wheras this DLL
 * sees symbols defined with this macro as being exported.
 *
 * (From Andrew Finney's sbwdefs.h, with "SBW" replaced by "LIBSBML" :)
 */
#if defined(LIBSBML_EXPORTS)
#  define LIBSBML_EXTERN __declspec(dllexport)
#else
#  define LIBSBML_EXTERN __declspec(dllimport)
#endif

#else
#  define LIBSBML_EXTERN
#endif  /* LIBSBML_STATIC */

/**
 * Disable MSVC++ warning C4800: 'const int' : forcing value to bool 'true'
 * or 'false' (performance warning).
 */
#pragma warning(disable: 4800)

/**
 * Disable MSVC++ warning C4291: no matching operator delete found.
 */
#pragma warning(disable: 4291)

/**
 * Disable MSVC++ warning C4251: class 'type' needs to have dll-interface
 * to be used by clients of class 'type2'.
 *
 * For an explanation of why this is safe, see:
 *   - http://www.unknownroad.com/rtfm/VisualStudio/warningC4251.html
 */
#pragma warning(disable: 4251)
#pragma warning(disable: 4275)

#else

/**
 * LIBSBML_EXTERN is used under Windows to simplify exporting functions
 * from a DLL.  When compiling under Windows, all files within this DLL are
 * compiled with the LIBSBML_EXPORTS symbol defined on the command line.
 * This in turn causes extern.h to define a different version of
 * LIBSBML_EXTERN that is appropriate for exporting functions to client
 * code that uses the DLL.
 */
#define LIBSBML_EXTERN

#endif  /* WIN32 */

#undef BEGIN_C_DECLS
#undef END_C_DECLS

#if defined(__cplusplus)
#  define BEGIN_C_DECLS extern "C" {
#  define END_C_DECLS   }
#else
#  define BEGIN_C_DECLS
#  define END_C_DECLS
#endif


#endif  /** LIBSBML_EXTERN_H **/

