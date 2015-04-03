/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    memory.c
 * @brief   Safe (c|m)alloc(), free() and trace functions
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
#include <sbml/util/memory.h>

#include <sbml/common/extern.h>
#include <sbml/common/libsbml-package.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * PACKAGE_NAME is defined (as part of the autoconf process) in
 * libsbml-package.h (which is included by common.h).
 */
#define MSG_OUT_OF_MEMORY  PACKAGE_NAME ": error: Out of Memory!"


/*
 * If TRACE_MEMORY is defined, safe_malloc and safe_calloc have been
 * redefined in util.h as macros that first call MemTrace_alloc().  We need
 * to undo this definition to compile the *real* safe_malloc() and
 * safe_calloc().
 */
#ifdef TRACE_MEMORY
#  undef safe_malloc
#  undef safe_calloc
#  undef safe_realloc
#endif


/*
 * Allocates size bytes of memory and returns a pointer to the allocated
 * memory.  If the memory could not be allocated, prints an error message
 * and exits.
 */
void *
safe_malloc (size_t size)
{
  void *p = (void *) malloc(size);


  if (p == NULL)
  {
#ifdef EXIT_ON_ERROR
    fprintf(stderr, MSG_OUT_OF_MEMORY);
    exit(-1);
#endif
  }

  return p;
}


/*
 * Allocates memory for an array of nmemb elements of size bytes each and
 * returns a pointer to the allocated memory.  The memory is set to zero.
 * If the memory could not be allocated, prints an error message and exits.
 */
LIBSBML_EXTERN
void *
safe_calloc (size_t nmemb, size_t size)
{
  void *p = (void *) calloc(nmemb, size);


  if (p == NULL)
  {
#ifdef EXIT_ON_ERROR
    fprintf(stderr, MSG_OUT_OF_MEMORY);
    exit(-1);
#endif
  }

  return p;
}


/*
 * Changes the size of the memory block pointed to by ptr to size bytes and
 * returns a new pointer to it.  Note: the new pointer may be different
 * than ptr.  If the memory could not be allocated, prints an error message
 * and exits.
 */
void *
safe_realloc (void *ptr, size_t size)
{
  void *p = (void *) realloc(ptr, size);


  if (p == NULL)
  {
#ifdef EXIT_ON_ERROR
    fprintf(stderr, MSG_OUT_OF_MEMORY);
    exit(-1);
#endif
  }

  return p;
}




#ifdef TRACE_MEMORY

/*
 * The following data are shared among the functions below.
 */
static int MemTrace_initialized = 0;

static unsigned int MemTrace_NumAllocs;
static unsigned int MemTrace_NumFrees;

static unsigned int MemTrace_CurrentBytes;
static unsigned int MemTrace_MaxBytes;

static MemInfoList_t *MemTrace_AllocList;
static MemInfoList_t *MemTrace_FreeList;
static MemInfoList_t *MemTrace_UnmatchedFreeList;


/*
 * Initializes the memory tracing facility.  Multiple calls are gracefully
 * ignored.
 */
void
MemTrace_init (void)
{
  if (!MemTrace_initialized)
  {
    MemTrace_NumAllocs = 0;
    MemTrace_NumFrees  = 0;

    MemTrace_CurrentBytes  = 0;
    MemTrace_MaxBytes      = 0;

    MemTrace_AllocList         = MemTrace_MemInfoList_create();
    MemTrace_FreeList          = MemTrace_MemInfoList_create();
    MemTrace_UnmatchedFreeList = MemTrace_MemInfoList_create();

    MemTrace_initialized = 1;
  }
}


/*
 * Resets the memory tracing facility, i.e. starts a new tracing "session".
 */
void
MemTrace_reset (void)
{
  if (MemTrace_initialized)
  {
    MemTrace_MemInfoList_free( MemTrace_AllocList         );
    MemTrace_MemInfoList_free( MemTrace_FreeList          );
    MemTrace_MemInfoList_free( MemTrace_UnmatchedFreeList );

    MemTrace_initialized = 0;
    MemTrace_init();
  }
}


/*
 * @return the total number of safe_malloc()s and safe_calloc()s that have
 * occurred in this program up to this point.
 */
unsigned int
MemTrace_getNumAllocs (void)
{
  return MemTrace_NumAllocs;
}


/*
 * @return the number of safe_malloc()s and safe_calloc()s that have
 * occurred without corresponding safe_free()s, i.e. a potential memory
 * leak.
 */
unsigned int
MemTrace_getNumLeaks (void)
{
  return MemTrace_AllocList->size;
}


/*
 * @return the total number of safe_frees() that have occurred in this
 * program up to this point.
 */
unsigned int
MemTrace_getNumFrees (void)
{
  return MemTrace_NumFrees;
}


/*
 * @return the number of safe_free()s that have no corresponding
 * safe_malloc() or safe_calloc(), i.e. the free has no *matching* memory
 * allocation.
 */
unsigned int
MemTrace_getNumUnmatchedFrees (void)
{
  return MemTrace_UnmatchedFreeList->size;
}


/*
 * @return the maximum number of bytes allocated in this program up to this
 * point.
 */
unsigned int
MemTrace_getMaxBytes (void)
{
  return MemTrace_MaxBytes;
}


/*
 * Prints the current memory trace statistics to the given stream.
 */
void
MemTrace_printStatistics (FILE *stream)
{
  unsigned int allocs    = MemTrace_getNumAllocs();
  unsigned int leaks     = MemTrace_getNumLeaks();
  unsigned int frees     = MemTrace_getNumFrees();
  unsigned int unmatched = MemTrace_getNumUnmatchedFrees();

  float percent;


  fprintf(stream, "\nMemory Trace Statistics:\n");

  if (allocs == frees)
  {
    fprintf(stream, "100%%: ");
  }
  else if (allocs == 0)
  {
    fprintf(stream, "0%%: ");
  }
  else
  {
    if (allocs > frees)
    {
      percent = ((float) frees / allocs) * 100;
    }
    else
    {
      percent = ((float) allocs/ frees) * 100;
    }

    fprintf(stream, "%4.1f%%: ", percent);
  }

  fprintf(stream, "Allocs: %d, Frees: %d, Leaks: %d, ", allocs, frees, leaks);
  fprintf(stream, "Unmatched Frees: %d\n", unmatched);
}


/*
 * Prints the file and line number of all memory leaks that have occurred
 * in this program up to this point.  Output is sent to stream.
 */
void
MemTrace_printLeaks (FILE *stream)
{
  unsigned int  leaks = MemTrace_getNumLeaks();
  unsigned int  total = 0;
  MemInfoNode_t *node = NULL;


  fprintf(stream, "\nMemory Leaks:\n");

  for (node = MemTrace_AllocList->head; node != NULL; node = node->next)
  {
    total += node->size;

    fprintf( stream,
             "  In file %s at line %d (%d bytes leaked)\n",
             node->filename,
             node->line,
             node->size );
  }

  fprintf(stream, "Total Leaks: %d ", leaks);

  if (total > 1048576)
  {
    fprintf(stream, "(%4.1f M", ((float) total) / 1048576);
  }
  else if (total > 1024)
  {
    fprintf(stream, "(%4.1f K", ((float) total) / 1024);
  }
  else
  {
    fprintf(stream, "(%d ", total);
  }

  fprintf(stream, "bytes leaked)\n");
}


/*
 * Traces a memory allocation by adding a MemInfoNode to AllocList.
 * Address is the pointer returned by safe_malloc() or safe_calloc().  Size
 * is the total number of bytes allocated.  Filename and line indicate
 * where in the source code the allocation occurred.
 *
 * This function returns location, so that it may be used in the following
 * manner:
 *
 *   MemTrace_alloc( safe_malloc(size), size, __FILE__, __LINE__ );
 *
 * or similarly for safe_calloc() with size replaced by nmemb * size.
 */
void *
MemTrace_alloc ( void       *address,  size_t       size,
                 const char *filename, unsigned int line )
{
  MemInfoNode_t *node;


  if (MemTrace_initialized)
  {
    node = MemTrace_MemInfoNode_create(address, size, filename, line);

    MemTrace_MemInfoList_append(MemTrace_AllocList, node);
    MemTrace_NumAllocs++;

    MemTrace_CurrentBytes += size;

    if (MemTrace_CurrentBytes > MemTrace_MaxBytes)
    {
      MemTrace_MaxBytes = MemTrace_CurrentBytes;
    }
  }

  return address;
}


/*
 * Traces a memory reallocation.  This function behaves exactly like
 * MemTrace_alloc(), except that the original pointer passed to realloc()
 * must be passed in as well to ensure it is properly recorded as freed.
 * For e.g.:
 *
 *   MemTrace_realloc( safe_realloc(ptr, size), size, ptr, __FILE__, __LINE__)
 */
void *
MemTrace_realloc ( void       *address,  size_t       size,  void *original,
                   const char *filename, unsigned int line )
{
  MemTrace_free(original, filename, line);
  return MemTrace_alloc(address, size, filename, line);
}


/*
 * Traces a memory free by removing the MemInfoNode containing address from
 * AllocList and appending it to FreeList.
 */
void
MemTrace_free (void *address, const char *filename, unsigned int line)
{
  MemInfoNode_t *node;


  if ( MemTrace_initialized && (address != NULL) )
  {
    node = MemTrace_MemInfoList_remove(MemTrace_AllocList, address);

    if (node != NULL)
    {
      MemTrace_MemInfoList_append(MemTrace_FreeList, node);
      MemTrace_CurrentBytes -= node->size;
    }
    else
    {
      node = MemTrace_MemInfoNode_create(address, 0, filename, line);
      MemTrace_MemInfoList_append(MemTrace_UnmatchedFreeList, node);
    }

    MemTrace_NumFrees++;
  }
}


/*
 * Creates a new MemInfoList and returns a pointer to it.
 */
MemInfoList_t *
MemTrace_MemInfoList_create (void)
{
  MemInfoList_t *list = (MemInfoList_t *) safe_malloc( sizeof(MemInfoList_t) );


  list->head = NULL;
  list->tail = NULL;
  list->size = 0;

  return list;
}


/*
 * Frees the given MemInfoList and its constituent MemInfoNodes
 */
void
MemTrace_MemInfoList_free (MemInfoList_t *list)
{
  MemInfoNode_t *node = list->head;
  MemInfoNode_t *temp = NULL;


  while (node != NULL)
  {
    temp = node;
    node = node->next;

    free(temp);
  }

  free(list);
}


/*
 * Creates a new MemInfoNode and returns a pointer to it.
 */
MemInfoNode_t *
MemTrace_MemInfoNode_create ( const void *address,  size_t       size,
                              const char *filename, unsigned int line )
{
  MemInfoNode_t *node = (MemInfoNode_t *) safe_malloc( sizeof(MemInfoNode_t) );


  node->address  = address;
  node->size     = size;
  node->filename = filename;
  node->line     = line;
  node->next     = NULL;

  return node;
}


/*
 * Appends the given MemInfoNode to the given MemInfoList.
 */
void
MemTrace_MemInfoList_append (MemInfoList_t *list, MemInfoNode_t *node)
{
  if (list->head == NULL)
  {
    list->head = node;
    list->tail = node;
  }
  else
  {
    list->tail->next = node;
    list->tail       = node;
  }

  list->size++;
}


/*
 * Returns a pointer to the MemInfoNode in MemInfoList with the given
 * address or NULL if address is not found.
 */
MemInfoNode_t *
MemTrace_MemInfoList_get (const MemInfoList_t *list, const void *address)
{
  MemInfoNode_t *node;


  for (node = list->head; node != NULL; node = node->next)
  {
    if (node->address == address)
    {
      break;
    }
  }

  return node;
}


/*
 * Removes the MemInfoNode with the given address from MemInfoList and
 * returns a pointer to it.  If address is not found in the list, NULL is
 * returned.
 */
MemInfoNode_t *
MemTrace_MemInfoList_remove (MemInfoList_t *list, const void *address)
{
  MemInfoNode_t *prev;
  MemInfoNode_t *curr;
  MemInfoNode_t *next;


  /*
   * curr = node to be removed
   * prev = node before curr (or NULL if curr == list->head)
   * next = node after  curr (or NULL if curr == list->tail)
   */
  prev = NULL;
  curr = list->head;

  /*
   * Point curr to nth item.
   */
  while (curr != NULL)
  {
    next = curr->next;

    if (curr->address == address)
    {
      break;
    }

    prev = curr;
    curr = curr->next;
  }


  if (curr != NULL)
  {
    /*
     * If the first item in the list is being removed, only list->head
     * needs to be updated to remove curr.  Otherwise, prev->next must
     * "forget" about curr and point to next instead.
     */
    if (list->head == curr)
    {
      list->head = next;
    }
    else
    {
      prev->next = next;
    }

    /*
     * Regardless of the restructuring above, if the last item in the list
     * has been removed, update list->tail.
     */
    if (list->tail == curr)
    {
      list->tail = prev;
    }

    list->size--;
  }

  return curr;
}

LIBSBML_CPP_NAMESPACE_END

#endif  /** TRACE_MEMORY **/

/** @endcond */

