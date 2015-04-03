/**
 * @file    util.c
 * @brief   Utility functions. 
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
 * ------------------------------------------------------------------------ -->
 *
 * Ths file implements a small number of utility functions that may be
 * useful inside and outside of libSBML.
 */

#ifdef _MSC_VER
#pragma warning( push )                    // Save the current warning state.
#pragma warning( disable : 4723 )          // C4723: potential divide by 0
#endif


#include <ctype.h>
#include <locale.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <sbml/common/common.h>
#include <sbml/common/libsbml-package.h>

#include <sbml/util/List.h>
#include <sbml/util/util.h>

#include <math.h>
#ifdef __cplusplus
#include <cmath>
#endif

#if defined(_MSC_VER) || defined(__BORLANDC__)
#  include <float.h>
#endif

#ifndef __DBL_EPSILON__ 
#define __DBL_EPSILON__ DBL_EPSILON
#endif

/** @cond doxygenLibsbmlInternal */

LIBSBML_CPP_NAMESPACE_BEGIN

LIBSBML_EXTERN
int
util_isNaN (double d)
{
  return d != d;
}

LIBSBML_EXTERN
int
util_isFinite (double d)
{
  return !util_isNaN(d) && !util_isNaN(d-d);
}

LIBSBML_EXTERN 
double util_epsilon()
{
  return __DBL_EPSILON__;
}

LIBSBML_EXTERN
int util_isEqual(double a, double b)
{
  return (fabs(a-b) < sqrt(util_epsilon())) ? 1 : 0;
}


int
c_locale_snprintf (char *str, size_t size, const char *format, ...)
{
  int result;
  va_list ap;

  va_start(ap, format);
  result = c_locale_vsnprintf(str, size, format, ap);
  va_end(ap);

  return result;
}


int
c_locale_vsnprintf (char *str, size_t size, const char *format, va_list ap)
{
#ifdef _MSC_VER
#  define vsnprintf _vsnprintf
#endif

  int result;
  char *locale;


  locale = safe_strdup(setlocale(LC_ALL, NULL));
  setlocale(LC_ALL, "C");

  result = vsnprintf(str, size, format, ap);

  setlocale(LC_ALL, locale);
  free(locale);
  
  return result;
}


double
c_locale_strtod (const char *nptr, char **endptr)
{
  double result;
  char *locale;


  locale = safe_strdup(setlocale(LC_ALL, NULL));
  setlocale(LC_ALL, "C");

  result = strtod(nptr, endptr);

  setlocale(LC_ALL, locale);
  free(locale);

  return result;
}


LIBSBML_EXTERN
FILE *
safe_fopen (const char *filename, const char *mode)
{
  FILE       *fp;

  if (filename == NULL || mode == NULL) return NULL;

  fp      = fopen(filename, mode);


  if (fp == (FILE *) NULL)
  {
#ifdef EXIT_ON_ERROR
    const char *format;
    const char *modestr;
    format  = "%s: error: Could not open file '%s' for %s.\n";
    modestr = strcmp(mode, "r") ? "writing" : "reading";
    fprintf(stderr, format, PACKAGE_NAME, filename, modestr);
    exit(-1);
#endif
  }

  return fp;
}


LIBSBML_EXTERN
char *
safe_strcat (const char *str1, const char *str2)
{
  int  len1;
  int  len2;
  char *concat;
  
  if (str1 == NULL || str2 == NULL) return NULL;
  
  len1    = (int)strlen(str1);
  len2    = (int)strlen(str2);
  concat = (char *) safe_malloc( len1 + len2 + 1 );


  strncpy(concat, str1, len1 + 1);
  strncat(concat, str2, len2);

  return concat;
}


LIBSBML_EXTERN
char *
safe_strdup (const char* s)
{
  size_t  size;
  char   *duplicate;
  
  if (s == NULL) return NULL;
  
  size      = strlen(s) + 1;
  duplicate = (char *) safe_malloc(size * sizeof(char));


  strncpy(duplicate, s, size);

  return duplicate;
}


LIBSBML_EXTERN
int
strcmp_insensitive (const char *s1, const char *s2)
{
  while ( (*s1 != '\0') && 
          (tolower( *(unsigned char *) s1) == tolower( *(unsigned char *) s2)) )
  {
    s1++;
    s2++;
  }

  return tolower( *(unsigned char *) s1) - tolower( *(unsigned char *) s2);
}


LIBSBML_EXTERN
unsigned int
streq (const char *s, const char *t)
{
  if (s == NULL)
    return t == NULL;
  else if (t == NULL)
    return 0;
  else
    return !strcmp(s, t);
}


LIBSBML_EXTERN
int
util_bsearchStringsI (const char **strings, const char *s, int lo, int hi)
{
  int cond;
  int mid;
  int result = hi + 1;


  if (s == NULL || strings == NULL) return result;

  while (lo <= hi)
  {
    mid  = (lo + hi) / 2;
    cond = strcmp_insensitive(s, strings[mid]);
      
    if (cond < 0)
    {
      hi = mid - 1;
    }
    else if (cond > 0)
    {
      lo = mid + 1;
    }
    else
    {
      result = mid;
      break;
    }
  }

  return result;
}


LIBSBML_EXTERN
int
util_file_exists (const char *filename)
{
#ifdef _MSC_VER
#  define stat _stat
#endif

  struct stat buf;
  if (filename == NULL) return 0;
  return stat(filename, &buf) == 0;
}


LIBSBML_EXTERN
char *
util_trim (const char *s)
{
  const char *start = s;
  const char *end;

  char *trimmed = NULL;
  int  len;


  if (s == NULL) return NULL;

  len = (int)strlen(s);
  end = start + len - 1;

  /*
   * Skip leading whitespace.
   *
   * When this loop terminates, start will point the first non-whitespace
   * character of the string or NULL.
   */
  while ( len > 0 && isspace(*start) )
  {
    start++;
    len--;
  }

  /*
   * Skip trailing whitespace.
   *
   * When this loop terminates, end will point the last non-whitespace
   * character of the string.
   */
  while ( len > 0 && isspace(*end) )
  {
    end--;
    len--;
  }

  /*
   * If len is zero, the string is either empty or pure whitespace.  Set
   * trimmed to an empty string.
   */
  if (len == 0)
  {
    trimmed    = (char *) safe_malloc(1);
    trimmed[0] = '\0';
  }

  /*
   * Otherwise...
   */
  else
  {
    trimmed = (char *) safe_malloc(len + 1);

    strncpy(trimmed, start, len);
    trimmed[len] = '\0';
  }

  return trimmed;
}


LIBSBML_EXTERN
char *
util_trim_in_place (char *s)
{
  char *end;
  int   len;


  if (s == NULL) return NULL;

  len = (int)strlen(s);
  end = s + len - 1;

  /*
   * Skip leading whitespace.
   *
   * When this loop terminates, s will point the first non-whitespace
   * character of the string or NULL.
   */
  while ( len > 0 && isspace(*s) )
  {
    s++;
    len--;
  }

  /*
   * Skip trailing whitespace.
   *
   * When this loop terminates, end will point the last non-whitespace
   * character of the string.
   */
  while ( len > 0 && isspace(*end) )
  {
    end--;
    len--;
  }

  s[len] = '\0';

  return s;
}


/** @endcond */


LIBSBML_EXTERN
double
util_NaN (void)
{
  double z = 0.0;

  // MSVC++ will produce a compile error if 0.0 is used instead of z.
  return 0.0 / z;
}


LIBSBML_EXTERN
double
util_NegInf (void)
{
  double z = 0.0;

  // MSVC++ will produce a compile error if 0.0 is used instead of z.
  return -1.0 / z;
}


LIBSBML_EXTERN
double
util_PosInf (void)
{
  double z = 0.0;

  // MSVC++ will produce a compile error if 0.0 is used instead of z.
  return 1.0 / z;
}


LIBSBML_EXTERN
double
util_NegZero (void)
{
  return -1.0 / util_PosInf();
}


LIBSBML_EXTERN
int
util_isInf (double d)
{

  if ( !(util_isFinite(d) || util_isNaN(d)) )
  {
    return (d < 0) ? -1 : 1;
  }

  return 0;
}


LIBSBML_EXTERN
int
util_isNegZero (double d)
{
  unsigned char *b = (unsigned char *) &d;

#if WORDS_BIGENDIAN || __BIG_ENDIAN__
  return b[0] == 0x80;
#else
  return b[7] == 0x80;
#endif
}


LIBSBML_EXTERN
void
util_free (void * element)
{
  if (element != NULL)
  {
    safe_free(element);
  }
}

LIBSBML_EXTERN
void
util_freeArray (void ** objects, int length)
{
  int i;
  if (objects == NULL) return;
  for (i = 0; i < length; i++)    
  {
    util_free(objects[i]);
  }
  free(objects);

}

#ifdef _MSC_VER
#pragma warning( pop )  // restore warning
#endif

LIBSBML_CPP_NAMESPACE_END

