/**
 * @file    ElementFilter.h
 * @brief   Base class of element filters.
 * @author  Frank T. Bergmann
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
 * ---------------------------------------------------------------------- -->
 *
 * @class ElementFilter
 * @sbmlbrief{core} Base class for filter functions.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * Some libSBML objects provide the ability to return lists of components.
 * To provide callers with greater control over exactly what is
 * returned, these methods take optional arguments in the form of filters.
 * The ElementFilter class is the parent class for these filters.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_what_is_user_data
 *
 * @par
 * The user data associated with an SBML object can be used by an application
 * developer to attach custom information to that object in the model.  In case
 * of a deep copy, this data will passed as-is.  The data attribute will never
 * be interpreted by libSBML.
 */

#ifndef ElementFilter_h
#define ElementFilter_h


#ifdef __cplusplus

#include <sbml/common/extern.h>
#include <sbml/common/libsbml-namespace.h>

LIBSBML_CPP_NAMESPACE_BEGIN

#define ADD_FILTERED_LIST(pResult,pSublist,list,pFilter)\
{\
  if (list.size() > 0) {\
    if (pFilter == NULL || pFilter->filter(&list))\
    pResult->add(&list);\
    pSublist = list.getAllElements(pFilter);\
    pResult->transferFrom(pSublist);\
    delete pSublist;\
  }\
}

#define ADD_FILTERED_PLIST(pResult,pSublist,pList,pFilter)\
{\
  if (pList != NULL && pList->size() > 0) {\
    if (pFilter == NULL || pFilter->filter(pList))\
    pResult->add(pList);\
    pSublist = pList->getAllElements(pFilter);\
    pResult->transferFrom(pSublist);\
    delete pSublist;\
  }\
}

#define ADD_FILTERED_POINTER(pResult,pSublist,pElement,pFilter)\
{\
  if (pElement != NULL) {\
    if (pFilter == NULL || pFilter->filter(pElement))\
    pResult->add(pElement);\
    pSublist = pElement->getAllElements(pFilter);\
    pResult->transferFrom(pSublist);\
    delete pSublist;\
  }\
}

#define ADD_FILTERED_ELEMENT(pResult,pSublist,element,pFilter)\
{\
  if (&element != NULL) {\
    if (pFilter == NULL || pFilter->filter(&element))\
    pResult->add(&element);\
    pSublist = element.getAllElements(pFilter);\
    pResult->transferFrom(pSublist);\
    delete pSublist;\
  }\
}

#define ADD_FILTERED_FROM_PLUGIN(pResult,pSublist,pFilter)\
{\
    pSublist = getAllElementsFromPlugins(pFilter);\
    pResult->transferFrom(pSublist);\
    delete pSublist;\
}

class SBase;

class LIBSBML_EXTERN ElementFilter
{
public:

  /**
   * Creates a new ElementFilter object.
   */
  ElementFilter();


  /**
   * Destroys this ElementFilter.
   */
  virtual ~ElementFilter();


  /**
   * Predicate to test elements.
   *
   * This is the central predicate of the ElementFilter class.  In subclasses
   * of ElementFilter, callers should implement this method such that it
   * returns @c true for @p element arguments that are "desirable" and @c
   * false for those that are "undesirable" in whatever filtering context the
   * ElementFilter subclass is designed to be used.
   *
   * @param element the element to be tested.
   *
   * @return @c true if the @p element is desirable or should be kept,
   * @c false otherwise.
   */
  virtual bool filter(const SBase* element);


  /**
   * Returns the user data that has been previously set via setUserData().
   *
   * Callers can attach private data to ElementFilter objects using
   * setUserData().  This user data can be used by an application to store
   * custom information to be accessed by the ElementFilter in its work.  In
   * case of a deep copy, the data will passed as it is.  The attribute will
   * never be interpreted by libSBML.
   *
   * @return the user data of this node, or @c NULL if no user data has been
   * set.
   *
   * @warning This <em>user data</em> is specific to an ElementFilter object
   * instance, and is not the same as the user data that may be attached to
   * an SBML object using SBase::setUserData().
   *
   * @see setUserData()
   */
  void* getUserData();


  /**
   * Sets the user data of this element.
   *
   * Callers can attach private data to ElementFilter objects using this
   * method, and retrieve them using getUserData().  Such user data can be
   * used by an application to store information to be accessed by the
   * ElementFilter in its work.  In case of a deep copy, this data will
   * passed as it is.  The attribute will never be interpreted by libSBML.
   *
   * @param userData specifies the new user data.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @warning This <em>user data</em> is specific to an ElementFilter object
   * instance, and is not the same as the user data that may be attached to
   * an SBML object using SBase::setUserData().
   *
   * @see getUserData()
   */
  void setUserData(void* userData);


private:
  /** @cond doxygenLibsbmlInternal */

  void* mUserData;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* ElementFilter_h */
