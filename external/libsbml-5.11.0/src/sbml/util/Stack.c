/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    Stack.c
 * @brief   Generic (void *) Stack for C structs on the heap
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
#include <sbml/util/Stack.h>

LIBSBML_CPP_NAMESPACE_BEGIN

#ifdef DEBUG

/**
 * Reports a message to stderr if n is out of range in Stack_peekAt.
 */
#define REPORT_STACK_RANGE_ERROR(function, n, size) \
fprintf( stderr, \
         "Stack.c: %s(Stack_t *s, n = %d): Warning: n must be >= 0 " \
         "and < Stack_size() (%d).  Returning NULL.", \
         function, \
         n, \
         siz );

#else

#define REPORT_STACK_RANGE_ERROR(function, n, size) ;

#endif


LIBSBML_EXTERN
Stack_t *
Stack_create (int capacity)
{
  Stack_t *s;


  s           = (Stack_t *) safe_calloc( 1       , sizeof(Stack_t) );
  s->stack    = (void   **) safe_calloc( capacity, sizeof(void *)  );
  s->sp       = -1;
  s->capacity = capacity;

  return s;
}


LIBSBML_EXTERN
void
Stack_free (Stack_t *s)
{
  if (s == NULL) return;

  safe_free(s->stack);
  safe_free(s);
}


LIBSBML_EXTERN
int
Stack_find (Stack_t *s, void *item)
{
  int pos = Stack_size(s);


  while ((pos-- > 0) && (s->stack[pos] != item)) ;

  if (pos >= 0)
  {
    pos = (int)(s->sp - pos);
  }

  return pos;
}


LIBSBML_EXTERN
void
Stack_push (Stack_t *s, void *item)
{
  if (s == NULL) return; 

  if (Stack_size(s) == s->capacity)
  {
    s->capacity *= 2;
    s->stack     = (void **)
                   safe_realloc(s->stack, s->capacity * sizeof(void *));
                   
  }

  s->stack[ ++(s->sp) ] = item;
}


LIBSBML_EXTERN
void *
Stack_pop (Stack_t *s)
{
  if (s == NULL) return NULL;
  return s->stack[ (s->sp)-- ];
}


void *
Stack_popN (Stack_t *s, unsigned int n)
{
  if (n == 0 || s == NULL || s->sp == -1) return NULL;

  s->sp -= n;

  if (s->sp < -1)
  {
    s->sp = -1;
  }

  return s->stack[ s->sp + 1 ];
}


LIBSBML_EXTERN
void *
Stack_peek (Stack_t *s)
{
  if (s == NULL) return NULL;
  return s->stack[ s->sp ];
}


LIBSBML_EXTERN
void *
Stack_peekAt (Stack_t *s, int n)
{
  int size = Stack_size(s);

  if (s == NULL) return NULL;

  if (n < 0 || n >= size)
  {
    REPORT_STACK_RANGE_ERROR("Stack_peekAt", n, size);
    return NULL;
  }

  return s->stack[ s->sp - n ];
}


LIBSBML_EXTERN
int
Stack_size (Stack_t *s)
{
  if (s == NULL) return 0;
  return (int)(s->sp + 1);
}


LIBSBML_EXTERN
int
Stack_capacity (Stack_t *s)
{
  if (s == NULL) return 0;
  return (int)(s->capacity);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
