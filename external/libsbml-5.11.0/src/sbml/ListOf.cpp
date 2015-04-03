/**
 * @file    ListOf.cpp
 * @brief   Wraps List and inherits from SBase
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <algorithm>
#include <functional>

#include <sbml/SBMLVisitor.h>
#include <sbml/ListOf.h>
#include <sbml/SBO.h>
#include <sbml/common/common.h>
#include <sbml/util/ElementFilter.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new ListOf items.
 */
ListOf::ListOf (unsigned int level, unsigned int version)
: SBase(level,version)
{
    if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


/*
 * Creates a new ListOf items.
 */
ListOf::ListOf (SBMLNamespaces* sbmlns)
: SBase(sbmlns)
{
    if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


/**
 * Used by the Destructor to delete each item in mItems.
 */
struct Delete : public unary_function<SBase*, void>
{
  void operator() (SBase* sb) { delete sb; }
};


/*
 * Destroys the given ListOf and its constituent items.
 */
ListOf::~ListOf ()
{
  for_each( mItems.begin(), mItems.end(), Delete() );
}


/**
 * Used by the Copy Constructor to clone each item in mItems.
 */
struct Clone : public unary_function<SBase*, SBase*>
{
  SBase* operator() (SBase* sb) { return sb->clone(); }
};


/*
 * Copy constructor. Creates a copy of this ListOf items.
 */
ListOf::ListOf (const ListOf& orig) : SBase(orig), mItems()
{
  mItems.resize( orig.size() );
  transform( orig.mItems.begin(), orig.mItems.end(), mItems.begin(), Clone() );
  connectToChild();
}


/*
 * Assignment operator
 */
ListOf& ListOf::operator=(const ListOf& rhs)
{
  if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    // Deletes existing items
    for_each( mItems.begin(), mItems.end(), Delete() );
    mItems.resize( rhs.size() );
    transform( rhs.mItems.begin(), rhs.mItems.end(), mItems.begin(), Clone() );
    connectToChild();
  }

  return *this;
}

/*
 * Accepts the given SBMLVisitor.
 */
bool
ListOf::accept (SBMLVisitor& v) const
{
  v.visit(*this, getItemTypeCode() );
  for (unsigned int n = 0 ; n < mItems.size() && mItems[n]->accept(v); ++n) ;
  v.leave(*this, getItemTypeCode() );

  return true;
}


/*
 * @return a (deep) copy of this ListOf items.
 */
ListOf*
ListOf::clone () const
{
  return new ListOf(*this);
}

/*
 * Inserts the item at the given location.  This ListOf items assumes
 * no ownership of item and will not delete it.
 */
int 
ListOf::insert(int location, const SBase* item)
{
  return insertAndOwn(location, item->clone());
}

/*
 * Inserts the item at the given location.  This ListOf items assumes
 * ownership of item and will delete it.
 */
int 
ListOf::insertAndOwn(int location, SBase* item)
{
  /* no list elements yet */
  if (this->getItemTypeCode() == SBML_UNKNOWN )
  {
    mItems.insert( mItems.begin() + location, item );
    item->connectToParent(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (!isValidTypeForList(item))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else
  {
    mItems.insert( mItems.begin() + location, item );
    item->connectToParent(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * Adds item to the end of this ListOf items.  This ListOf items assumes
 * no ownership of item and will not delete it.
 */
int
ListOf::append (const SBase* item)
{
  SBase* clone = item->clone();
  int ret = appendAndOwn( clone );
  if (ret != LIBSBML_OPERATION_SUCCESS) {
    delete clone;
  }
  return ret;
}


/*
 * Adds item to the end of this ListOf items.  This ListOf items assumes
 * ownership of item and will delete it.
 */
int
ListOf::appendAndOwn (SBase* item)
{
  /* no list elements yet */
  if (this->getItemTypeCode() == SBML_UNKNOWN )
  {
    mItems.push_back( item );
    item->connectToParent(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (!isValidTypeForList(item))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else
  {
    mItems.push_back( item );
    item->connectToParent(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
}

int ListOf::appendFrom(const ListOf* list)
{
  if (list==NULL) return LIBSBML_INVALID_OBJECT;
  if (getItemTypeCode() != list->getItemTypeCode()) {
    return LIBSBML_INVALID_OBJECT;
  }
  int ret = LIBSBML_OPERATION_SUCCESS;
  for (unsigned int item=0; item<list->size(); item++) {
    ret = appendAndOwn(list->get(item)->clone());
    if (ret != LIBSBML_OPERATION_SUCCESS) return ret;
  }
  return ret;
}

/*
 * @return the nth item in this ListOf items.
 */
const SBase*
ListOf::get (unsigned int n) const
{
  return (n < mItems.size()) ? mItems[n] : NULL;
}


/*
 * @return the nth item in this ListOf items.
 */
SBase*
ListOf::get (unsigned int n)
{
  return const_cast<SBase*>( static_cast<const ListOf&>(*this).get(n) );
}


SBase*
ListOf::getElementBySId(const std::string& id)
{
  if (id.empty()) return NULL;
  for (unsigned int i = 0; i < size(); i++)
  {
    SBase* obj = get(i);
    if (obj->isSetId() && obj->getId() == id)
    {
      return obj;
    }
    obj = obj->getElementBySId(id);
    if (obj != NULL) return obj;
  }

  return getElementFromPluginsBySId(id);
}

SBase*
ListOf::getElementByMetaId(const std::string& metaid)
{
  if (metaid.empty()) return NULL;
  for (unsigned int i = 0; i < size(); i++)
  {
    SBase* obj = get(i);
    if (obj->getMetaId() == metaid)
    {
      return obj;
    }
    obj = obj->getElementByMetaId(metaid);
    if (obj != NULL) return obj;
  }

  return getElementFromPluginsByMetaId(metaid);
}


List*
ListOf::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;
  for (unsigned int i = 0; i < size(); i++) {
    SBase* obj = get(i);
    if (filter == NULL || filter->filter(obj))
      ret->add(obj);
    sublist = obj->getAllElements(filter);
    ret->transferFrom(sublist);
    delete sublist;
  }

  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}
/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
//struct IdEq : public unary_function<SBase*, bool>
//{
//  const string& id;
//
//  IdEq (const string& id) : id(id) { }
//  bool operator() (SBase* sb) { return sb->getId() == id; }
//};


/*
 * @return item in this ListOf items with the given @p id or @c NULL if no such
 * item exists.
 */
//const SBase*
//ListOf::get (const std::string& sid) const
//{
//  vector<SBase*>::const_iterator result;
//
//  result = find_if( mItems.begin(), mItems.end(), IdEq(sid) );
//  return (result == mItems.end()) ? 0 : *result;
//}


/*
 * @return item in this ListOf items with the given @p id or @c NULL if no such
 * item exists.
 */
//SBase*
//ListOf::get (const std::string& sid)
//{
//  return const_cast<SBase*>( static_cast<const ListOf&>(*this).get(sid) );
//}


/*
 * Removes all items in this ListOf object.
 *
 * If doDelete is true (default), all items in this ListOf object are deleted
 * and cleared, and thus the caller doesn't have to delete those items.
 * Otherwise, all items are just cleared from this ListOf object and the caller
 * is responsible for deleting all items (In this case, pointers to all items
 * should be stored elsewhere before calling this function by the caller).
 */
void
ListOf::clear (bool doDelete)
{
  if (doDelete)
    for_each( mItems.begin(), mItems.end(), Delete() );
  mItems.clear();
}

int ListOf::removeFromParentAndDelete()
{
  clear(true);
  unsetAnnotation();
  unsetCVTerms();
  unsetId(); //Just in case
  unsetMetaId();
  unsetModelHistory();
  unsetName(); //Just in case
  unsetNotes();
  unsetSBOTerm();  
  return LIBSBML_OPERATION_SUCCESS;
}

/*
 * Removes the nth item from this ListOf items and returns a pointer to
 * it.  The caller owns the returned item and is responsible for deleting
 * it.
 */
SBase*
ListOf::remove (unsigned int n)
{
  SBase* item = get(n);
  if (item != NULL) mItems.erase( mItems.begin() + n );
  return item;
}


/*
 * Removes item in this ListOf items with the given @p id or @c NULL if no such
 * item exists.  The caller owns the returned item and is repsonsible for
 * deleting it.
 */
//SBase*
//ListOf::remove (const std::string& sid)
//{
//  SBase* item = 0;
//  vector<SBase*>::iterator result;
//
//  result = find_if( mItems.begin(), mItems.end(), IdEq(sid) );
//
//  if (result != mItems.end())
//  {
//    item = *result;
//    mItems.erase(result);
//  }
//
//  return item;
//}
//

/*
 * @return the number of items in this ListOf items.
 */
unsigned int
ListOf::size () const
{
  return (unsigned int)mItems.size();
}


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePackage function)
 */
void 
ListOf::enablePackageInternal(const std::string& pkgURI, const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  ListItemIter it = mItems.begin();
  while (it != mItems.end())
  {
    (*it)->enablePackageInternal(pkgURI,pkgPrefix,flag);
    ++it;
  }
}
/** @endcond */


/**
 * Used by ListOf::setSBMLDocument().
 */
struct SetSBMLDocument : public unary_function<SBase*, void>
{
  SBMLDocument* d;

  SetSBMLDocument (SBMLDocument* d) : d(d) { }
  void operator() (SBase* sbase) { sbase->setSBMLDocument(d); }
};


/**
 * Used by ListOf::setParentSBMLObject().
 */
struct SetParentSBMLObject : public unary_function<SBase*, void>
{
  SBase* sb;

  SetParentSBMLObject (SBase *sb) : sb(sb) { }
  void operator() (SBase* sbase) { sbase->connectToParent(sb); }
};

/** @cond doxygenLibsbmlInternal */

/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
ListOf::setSBMLDocument (SBMLDocument* d)
{
  SBase::setSBMLDocument(d);
  for_each( mItems.begin(), mItems.end(), SetSBMLDocument(d) );
}


/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
  */
void
ListOf::connectToChild()
{
  SBase::connectToChild();
  for_each( mItems.begin(), mItems.end(), SetParentSBMLObject(this) );
}

/** @endcond */


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 */
int
ListOf::getTypeCode () const
{
  return SBML_LIST_OF;
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOf::getItemTypeCode () const
{
  return SBML_UNKNOWN;
}


/*
 * @return the name of this element ie "listOf".
 
 */
const string&
ListOf::getElementName () const
{
  static const string name = "listOf";
  return name;
}


/**
 * Used by ListOf::writeElements().
 */
struct Write : public unary_function<SBase*, void>
{
  XMLOutputStream& stream;

  Write (XMLOutputStream& s) : stream(s) { }
  void operator() (SBase* sbase) { sbase->write(stream); }
};


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
ListOf::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  for_each( mItems.begin(), mItems.end(), Write(stream) );

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
ListOf::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
ListOf::readAttributes (const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes)
{
  SBase::readAttributes(attributes,expectedAttributes);

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v3 ->)
  // is read in SBase::readAttributes()
  //
}

void 
ListOf::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v3 ->)
  // is written in SBase::writeAttributes()
  //

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}

/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
ListOf_t *
ListOf_create (unsigned int level, unsigned int version)
{
  return new(nothrow) ListOf(level,version);
}


LIBSBML_EXTERN
void
ListOf_free (ListOf_t *lo)
{
  if (lo != NULL)
  delete lo;
}


LIBSBML_EXTERN
ListOf_t *
ListOf_clone (const ListOf_t *lo)
{
  return (lo != NULL) ? static_cast<ListOf_t*>( lo->clone() ) : NULL;
}


LIBSBML_EXTERN
int
ListOf_append (ListOf_t *lo, const SBase *item)
{
  if (lo != NULL)
    return lo->append(item);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
ListOf_appendAndOwn (ListOf_t *lo, SBase_t *item)
{
  if (lo != NULL)
    return lo->appendAndOwn(item);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
ListOf_appendFrom (ListOf_t *lo, ListOf_t *list)
{
  if (lo != NULL)
    return lo->appendFrom(list);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
ListOf_insert (ListOf_t *lo, int location, const SBase_t *item)
{
  if (lo != NULL)
    return lo->insert(location, item);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
ListOf_insertAndOwn (ListOf_t *lo, int location, SBase_t *item)
{
  if (lo != NULL)
    return lo->insertAndOwn(location, item);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
SBase *
ListOf_get (ListOf_t *lo, unsigned int n)
{
  return (lo != NULL) ? lo->get(n) : NULL;
}


//LIBSBML_EXTERN
//SBase *
//ListOf_getById (ListOf_t *lo, const char *sid)
//{
//  return (sid != NULL) ? lo->get(sid) : NULL;
//}
//

LIBSBML_EXTERN
void
ListOf_clear (ListOf_t *lo, int doDelete)
{
  if (lo != NULL)
  lo->clear(doDelete);
}


LIBSBML_EXTERN
SBase *
ListOf_remove (ListOf_t *lo, unsigned int n)
{
  return (lo != NULL) ? lo->remove(n) : NULL;
}


//LIBSBML_EXTERN
//SBase *
//ListOf_removeById (ListOf_t *lo, const char *sid)
//{
//  return (sid != NULL) ? lo->remove(sid) : NULL;
//}


LIBSBML_EXTERN
unsigned int
ListOf_size (const ListOf_t *lo)
{
  return (lo != NULL) ? lo->size() : SBML_INT_MAX;
}


LIBSBML_EXTERN
int
ListOf_getItemTypeCode (const ListOf_t *lo)
{
  return (lo != NULL) ? lo->getItemTypeCode() : SBML_UNKNOWN;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

