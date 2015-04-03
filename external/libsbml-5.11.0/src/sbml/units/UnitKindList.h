/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UnitKindList.h
 * @brief   Maintains a list of UnitKinds.
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

#ifndef UnitKindList_h
#define UnitKindList_h


#ifdef __cplusplus


#include <string>
#include <vector>
#include <sbml/common/libsbml-namespace.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class UnitKindList
{
public:

  typedef std::vector<std::string>::iterator       iterator;
  typedef std::vector<std::string>::const_iterator const_iterator;

  /**
   * Appends UnitKind to the list of UnitKinds.
   */
  void append (const std::string UnitKind) { mKinds.push_back(UnitKind); }

  /**
   * Returns true if @p UnitKind is already in this UnitKindList, false otherwise.
   *
   * @return true if UnitKind is already in this UnitKindList, false otherwise.
   */
  bool contains (const std::string UnitKind) const;

  /**
   * Removes the first occurence of this UnitKind in this UnitKindList.
   */
  void removeUnitKind (const std::string UnitKind);

  /**
   * Returns the number of UnitKinds in this UnitKindList.
   *
   * @return the number of UnitKinds in this UnitKindList.
   */
  unsigned int size () const { return (unsigned int)mKinds.size(); }

  /**
   * Returns an iterator to the beginning of this UnitKindList.
   *
   * @return an iterator to the beginning of this UnitKindList.
   */
  std::vector<std::string>::const_iterator begin () const
  {
    return mKinds.begin();
  }

  /**
   * Returns an iterator to the end of this UnitKindList.
   *
   * @return an iterator to the end of this UnitKindList.
   */
  std::vector<std::string>::const_iterator end () const
  {
    return mKinds.end();
  }


private:

  std::vector<std::string> mKinds;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* UnitKindList_h */


/** @endcond */

