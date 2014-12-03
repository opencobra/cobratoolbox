/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    StringBuffer.c
 * @brief   A growable buffer for creating character strings.
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

#include <sbml/common/common.h>
#include <sbml/util/StringBuffer.h>

LIBSBML_CPP_NAMESPACE_BEGIN

LIBSBML_EXTERN
StringBuffer_t *
StringBuffer_create (unsigned long capacity)
{
  StringBuffer_t *sb;


  sb           = (StringBuffer_t *) safe_malloc(sizeof(StringBuffer_t));
  sb->buffer   = (char *)           safe_malloc(capacity + 1);
  sb->capacity = capacity;

  StringBuffer_reset(sb);

  return sb;
}


LIBSBML_EXTERN
void
StringBuffer_free (StringBuffer_t *sb)
{
  if (sb == NULL) return;


  safe_free(sb->buffer);
  safe_free(sb);
}


LIBSBML_EXTERN
void
StringBuffer_reset (StringBuffer_t *sb)
{
  if (sb == NULL) return;
  sb->buffer[ sb->length = 0 ] = '\0';
}


LIBSBML_EXTERN
void
StringBuffer_append (StringBuffer_t *sb, const char *s)
{
  unsigned long len;

  if (sb == NULL || s == NULL) return;
  
  len = (unsigned long)strlen(s);  

  StringBuffer_ensureCapacity(sb, len);

  strncpy(sb->buffer + sb->length, s, len + 1);
  sb->length += len;
}


LIBSBML_EXTERN
void
StringBuffer_appendChar (StringBuffer_t *sb, char c)
{
  if (sb == NULL) return;

  StringBuffer_ensureCapacity(sb, 1);

  sb->buffer[sb->length++] = c;
  sb->buffer[sb->length]   = '\0';
}


LIBSBML_EXTERN
void
StringBuffer_appendNumber (StringBuffer_t *sb, const char *format, ...)
{
#ifdef _MSC_VER
#  define vsnprintf _vsnprintf
#endif

  const int size = 42;
  int       len;
  va_list   ap;

  if (sb == NULL) return;

  StringBuffer_ensureCapacity(sb, size);

  va_start(ap, format);
  len = c_locale_vsnprintf(sb->buffer + sb->length, size, format, ap);
  va_end(ap);

  sb->length += (len < 0 || len > size) ? size : len;
  sb->buffer[sb->length] = '\0';
}


LIBSBML_EXTERN
void
StringBuffer_appendInt (StringBuffer_t *sb, long i)
{
  StringBuffer_appendNumber(sb, "%d", i);
}


LIBSBML_EXTERN
void
StringBuffer_appendReal (StringBuffer_t *sb, double r)
{
  StringBuffer_appendNumber(sb, LIBSBML_FLOAT_FORMAT, r);
}


LIBSBML_EXTERN
void
StringBuffer_appendExp (StringBuffer_t *sb, double r)
{
  StringBuffer_appendNumber(sb, "%e", r);
}


LIBSBML_EXTERN
void
StringBuffer_ensureCapacity (StringBuffer_t *sb, unsigned long n)
{
  unsigned long wanted;
  unsigned long c;

  if (sb == NULL) return;

  wanted = sb->length + n;

  if (wanted > sb->capacity)
  {
    /*
     * Double the total new capacity (c) until it is greater-than wanted.
     * Grow StringBuffer by this amount minus the current capacity.
     */
    for (c = 2 * sb->capacity; c < wanted; c *= 2) ;
    StringBuffer_grow(sb, c - sb->capacity);
  }                   
}


LIBSBML_EXTERN
void
StringBuffer_grow (StringBuffer_t *sb, unsigned long n)
{
  if (sb == NULL) return;
  sb->capacity += n;
  sb->buffer    = (char *) safe_realloc(sb->buffer, sb->capacity + 1);
}


LIBSBML_EXTERN
char *
StringBuffer_getBuffer (const StringBuffer_t *sb)
{
  if (sb == NULL) return NULL;
  return sb->buffer;
}


LIBSBML_EXTERN
unsigned long
StringBuffer_length (const StringBuffer_t *sb)
{
  if (sb == NULL) return 0;
  return sb->length;
}


LIBSBML_EXTERN
unsigned long
StringBuffer_capacity (const StringBuffer_t *sb)
{
  if (sb == NULL) return 0;
  return sb->capacity;
}


LIBSBML_EXTERN
char *
StringBuffer_toString (const StringBuffer_t *sb)
{
  char *s = NULL;

  if (sb == NULL) return s;
  
  s = (char *) safe_malloc(sb->length + 1);

  strncpy(s, sb->buffer, sb->length + 1);
  return s;
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
