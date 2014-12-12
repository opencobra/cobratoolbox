#ifndef ListWrapper_h
#define ListWrapper_h

/**
 * @file    ListWrapper.h
 * @brief   A wrapper template class for List class
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

#include <sbml/util/List.h>
#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

/**
 *
 * ListWrapper : a wrapper template class for List class.
 *
 * Currently (2009-05-26), this template class is used for wrapping
 * the following functions in each language bindings.
 *
 *  - List* ModelHistory::getListCreators()
 *  - List* ModelHistory::getListModifiedDates()
 *  - List* SBase::getCVTerms()
 *  - List* ASTNode::getListOfNodes()
 */
template<typename IType>
class LIBSBML_EXTERN ListWrapper
{
  private:
    List *mList;
    bool mMemOwn;

  public:
    /**
     * Creates a new List.
     *
     * A ListXXX object is newly created (i.e. owned by the caller) and 
     * deleted by the destructor below if the constructor of this class 
     * invoked without an argument. 
     */
    ListWrapper() : mList(new List()), mMemOwn(true) {}


#ifndef SWIG
    /**
     * Creates a new List.
     * (internal implementation)
     *
     * An existing List object is given (i.e. not owned by the caller)
     * and stored.
     *
     */
    ListWrapper(List* list, bool memown = false) : mList(list), mMemOwn(memown) {}

    List* getList() { return mList; }
#endif


    /**
     * destructor
     */
    virtual ~ListWrapper() { if (mMemOwn) delete mList; }


    /**
     * Adds @p item to the end of this List.
     *
     * @param item a pointer to the item to be added.
     */
    void add(IType* item) 
    { 
      if (mList) mList->add(static_cast<void*>(item)); 
    }


    /**
     * Get the nth item in this List.
     *
     * If @p n > <code>listobj.size()</code>, this method returns @c 0.
     *
     * @return the nth item in this List.
     *
     * @see remove()
     *
     */
    IType* get(unsigned int n) const 
    { 
      return (mList) ? static_cast<IType*>(mList->get(n)) : 0; 
    }


    /**
     * Adds @p item to the beginning of this List.
     *
     * @param item a pointer to the item to be added.
     */
    void prepend(IType* item) 
    { 
      if (mList) mList->prepend(static_cast<void*>(item)); 
    }


    /**
     * Removes the nth item from this List and returns a pointer to it.
     *
     * If @p n > <code>listobj.size()</code>, this method returns @c 0.
     *
     * @return the nth item in this List.
     *
     * @see get()
     */
     IType* remove(unsigned int n) 
    { 
      return (mList) ? static_cast<IType*>(mList->remove(n)) : 0; 
    }


    /**
     * Get the number of items in this List.
     * 
     * @return the number of elements in this List.
     */
    unsigned int getSize() const 
    { 
      return (mList) ? mList->getSize() : 0; 
    }
};

#endif // ListWrapper_h
