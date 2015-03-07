/**
 * @file    List.cpp
 * @brief   Simple, generic list class.
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

#include <stdio.h>
#include <sbml/util/util.h>
#include <sbml/util/List.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new List.
 */
List::List ():
    size(0)
  , head(NULL)
  , tail(NULL)
{
}


/*
 * Destroys the given List.
 *
 * This function does not delete List items.  It destroys only the List and
 * its constituent ListNodes (if any).
 *
 * Presumably, you either i) have pointers to the individual list items
 * elsewhere in your program and you want to keep them around for awhile
 * longer or ii) the list has no items (List.size() == 0).  If neither are
 * true, try List_freeItems() instead.
 */
List::~List ()
{
  ListNode *node;
  ListNode *temp;


  node = head;

  while (node != NULL)
  {
    temp = node;
    node = node->next;

    delete temp;
  }
}


/*
 * Adds item to the end of this List.
 */
void
List::add (void *item)
{
  if (item == NULL) return;

  ListNode* node = new ListNode(item);


  if (head == NULL)
  {
    head = node;
    tail = node;
  }
  else
  {
    tail->next = node;
    tail       = node;
  }

  size++;
}


/*
 * @return the number of items in this List for which predicate(item)
 * returns true.
 *
 * The typedef for ListItemPredicate is:
 *
 *   int (*ListItemPredicate) (const void *item);
 *
 * where a return value of non-zero represents true and zero represents
 * false.
 */
unsigned int
List::countIf (ListItemPredicate predicate) const
{
  unsigned int count = 0;
  ListNode     *node = head;

  if (predicate == NULL) return 0;

  while (node != NULL)
  {
    if (predicate(node->item) != 0)
    {
      count++;
    }

    node = node->next;
  }

  return count;
}


/*
 * @return the first occurrence of item1 in this List or NULL if item was
 * not found.  ListItemComparator is a pointer to a function used to find
 * item.  The typedef for ListItemComparator is:
 *
 *   int (*ListItemComparator) (void *item1, void *item2);
 *
 * The return value semantics are the same as for strcmp:
 *
 *   -1    item1 <  item2,
 *    0    item1 == item 2
 *    1    item1 >  item2
 */
void *
List::find (const void *item1, ListItemComparator comparator) const
{
  void     *item2  = NULL;
  ListNode *node   = head;

  if (comparator == NULL) return NULL;

  while (node != NULL)
  {
    if (comparator(item1, node->item) == 0)
    {
      item2 = node->item;
      break;
    }

    node = node->next;
  }

  return item2;
}


/*
 * @return a new List containing (pointers to) all items in this List for
 * which predicate(item) was true.
 *
 * The returned list may be empty.
 *
 * The caller owns the returned list (but not its constituent items) and is
 * responsible for deleting it.
 */
List *
List::findIf (ListItemPredicate predicate) const
{
  List     *result = new List();  
  ListNode *node   = head;

  if (predicate == NULL) return result;

  while (node != NULL)
  {
    if (predicate(node->item) != 0)
    {
      result->add(node->item);
    }

    node = node->next;
  }

  return result;
}


/*
 * Returns the nth item in this List.  If n > List.size() returns 0.
 */
void *
List::get (unsigned int n) const
{
  ListNode* node = head;


  if (n >= size)
  {
    return NULL;
  }

  /**
   * Special case to retreive last item in the list without a full list
   * traversal.
   */
  if (n == (size - 1))
  {
    node = tail;
  }
  else
  {
    /* Point node to the nth item. */
    while (n-- > 0)
    {
      node = node->next;
    }
  }

  return node->item;
}


/*
 * Adds item to the beginning of this List.
 */
void
List::prepend (void *item)
{
  ListNode* node = new ListNode(item);


  if (head == NULL)
  {
    head = node;
    tail = node;
  }
  else
  {
    node->next = head;
    head       = node;
  }

  size++;
}


/*
 * Removes the nth item from this List and returns a pointer to it.  If n >
 * List.size() returns 0.
 */
void *
List::remove (unsigned int n)
{
  void*     item;
  ListNode* prev;
  ListNode* temp;
  ListNode* next;


  if (n >= size)
  {
    return NULL;
  }

  /**
   * temp = node to be removed
   * prev = node before temp (or NULL if temp == list->head)
   * next = node after  temp (or NULL if temp == list->tail)
   */
  prev = NULL;
  temp = head;
  next = temp->next;

  /**
   * Point temp to nth item.
   */
  while (n-- > 0)
  {
    prev = temp;
    temp = temp->next;
    next = temp->next;
  }

  /**
   * If the first item in the list is being removed, only list->head needs
   * to be updated to remove temp.  Otherwise, prev->next must "forget"
   * about temp and point to next instead.
   */
  if (head == temp)
  {
    head = next;
  }
  else
  {
    prev->next = next;
  }

  /**
   * Regardless of the restructuring above, if the last item in the list
   * has been removed, update list->tail.
   */
  if (tail == temp)
  {
    tail = prev;
  }

  item = temp->item;
  delete temp;

  size--;

  return item;
}


/*
 * Returns the number of elements in this List.
 */
unsigned int
List::getSize () const
{
  return size;
}

void
List::transferFrom(List* list)
{
  if (list==NULL) return;
  if (list->head == NULL) return;
  if (head==NULL) {
    head = list->head;
    tail = list->tail;
    size = list->size;
  }
  else {
    tail->next = list->head;
    tail = list->tail;
    size += list->size;
  }
  list->head = NULL;
  list->tail = NULL;
  list->size = 0;
}

/** @cond doxygenLibsbmlInternal */
void 
List::deleteListAndChildrenWith(List* list, ListDeleteItemFunc delteFunc)
{
  if (list == NULL || delteFunc == NULL) return;
  
  ListNode     *node = list->head;

  while (node != NULL)
  {
    delteFunc(node->item);

    node = node->next;
  }

  delete list;
  list = NULL;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */

/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
List_t *
List_create (void)
{
  return new List;
}


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
ListNode_t *
ListNode_create (void *item)
{
  return new ListNode(item);
}
/** @endcond */


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void
List_free (List_t *lst)
{
  if (lst == NULL) return;
  delete static_cast<List*>(lst);
}


/** @cond doxygenLibsbmlInternal */
void
ListNode_free (ListNode_t *node)
{
  delete static_cast<ListNode*>(node);
}
/** @endcond */


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void
List_add (List_t *lst, void *item)
{
  if (lst == NULL) return;
  static_cast<List*>(lst)->add(item);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
unsigned int
List_countIf (const List_t *lst, ListItemPredicate predicate)
{
  if (lst == NULL) return 0;
  return static_cast<const List*>(lst)->countIf(predicate);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void *
List_find ( const List_t *lst,
            const void   *item1,
            ListItemComparator comparator )
{
  if (lst == NULL) return NULL;
  return static_cast<const List*>(lst)->find(item1, comparator);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
List_t *
List_findIf (const List_t *lst, ListItemPredicate predicate)
{
  if (lst == NULL) return NULL;
  return static_cast<const List*>(lst)->findIf(predicate);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void *
List_get (const List_t *lst, unsigned int n)
{
  if (lst == NULL) return NULL;
  return static_cast<const List*>(lst)->get(n);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void
List_prepend (List_t *lst, void *item)
{
  if (lst == NULL) return;
  static_cast<List*>(lst)->prepend(item);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
void *
List_remove (List_t *lst, unsigned int n)
{
  if (lst == NULL) return NULL;
  return static_cast<List*>(lst)->remove(n);
}


/**
 * @if conly
 * @memberof List_t
 * @endif
 */
LIBSBML_EXTERN
unsigned int
List_size (const List_t *lst)
{
  if (lst == NULL) return 0;
  return static_cast<const List*>(lst)->getSize();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

