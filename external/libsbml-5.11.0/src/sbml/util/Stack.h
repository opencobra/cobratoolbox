/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    Stack.h
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

#ifndef Stack_h
#define Stack_h

#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


typedef struct
{
  long  sp;
  long  capacity;
  void  **stack;
} Stack_t;


/**
 * Creates a new Stack_t and returns a pointer to it.
 *
 * @param capacity the length of the created Stack_t.
 *
 * @return a new Stack_t of the given size.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
Stack_t *
Stack_create (int capacity);


/**
 * Free the given Stack_t.
 *
 * This function does not free individual Stack_t items.  It frees only the
 * Stack_t structure.
 *
 * @param s the Stack_t structure.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
void
Stack_free (Stack_t *s);

/**
 * @return the position of the first occurrence of item in the Stack_t or -1
 * if item cannot be found.  The search begins at the top of the Stack_t
 * (position 0) and proceeds downward (position 1, 2, etc.).
 *
 * Since ultimately the stack stores pointers, == is used to test for
 * equality.
 *
 * @param s the Stack_t structure.
 * @param item the item to find in the Stack_t.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
int
Stack_find (Stack_t *s, void *item);

/**
 * Pushes item onto the top of the Stack_t.
 *
 * @param s the Stack_t structure.
 * @param item the item to push to the top of the Stack_t.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
void
Stack_push (Stack_t *s, void *item);

/**
 * @return (and removes) the top item on the Stack_t.
 *
 * @param s the Stack_t structure.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
void *
Stack_pop (Stack_t *s);

/**
 * Pops the Stack_t n times.  The last item popped is returned.
 *
 * This function is conceptually simpler (and significantly faster for
 * large N) than calling Stack_pop() in a loop, but assumes you don't need
 * to track or manipulate the intermediate items popped.
 *
 * @param s the Stack_t structure.
 * @param n The number of times to pop the Stack_t.
 *
 * @memberof Stack_t
 */
void *
Stack_popN (Stack_t *s, unsigned int n);

/**
 * @return (but does not remove) the top item on the Stack_t.
 *
 * @param s the Stack_t structure.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
void *
Stack_peek (Stack_t *s);

/**
 * @return (but does not remove) the nth item from the top of the Stack_t,
 * starting at zero, i.e. Stack_peekAt(0) is equivalent to Stack_peek().
 * If n is out of range (n < 0 or n >= Stack_size()) returns NULL.
 *
 * @param s the Stack_t structure.
 * @param n The index of the item to return.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
void *
Stack_peekAt (Stack_t *s, int n);

/**
 * @return the number of items currently on the Stack_t.
 *
 * @param s the Stack_t structure.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
int
Stack_size (Stack_t *s);

/**
 * @return the number of items the Stack_t is capable of holding before it
 * will (automatically) double its storage capacity.
 *
 * @param s the Stack_t structure.
 *
 * @memberof Stack_t
 */
LIBSBML_EXTERN
int
Stack_capacity (Stack_t *s);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /** Stack_h **/

/** @endcond */

