/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdList.cpp
 * @brief   Maintains a list of SIds.  Useful for finding cycles.
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
#include <sstream>
#include <sbml/util/IdList.h>


using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

IdList::IdList()
{
}

IdList::IdList(const std::string& commaSeparated)
{
  if (&commaSeparated == NULL || commaSeparated.size() == 0) 
    return;

  size_t length = commaSeparated.size();
  size_t index = 0;   
  char current;
  stringstream currentId;
  while (index < length)
  {
    current = commaSeparated[index];
    if (current == ',' || current == ' ' || current == '\t' || current == ';')
    {
      const string& id = currentId.str();
      
      if (!id.empty())
        append(id);

      // reset stream
      currentId.str("");
      currentId.clear();      
    } 
    else
    {
      currentId << current;
    }
    ++index;
  }

  const string& id = currentId.str();
  if (!id.empty())
   append(id);
}


/**
 * @return true if id is already in this IdList, false otherwise.
 */
bool
IdList::contains (const std::string id) const
{
  IdList::const_iterator end = mIds.end();
  
  return std::find(mIds.begin(), end, id) != end;
}


/**
 * Removes all ids in this IdList before the given @p id.
 */
void
IdList::removeIdsBefore (const std::string id)
{
  IdList::iterator end = mIds.end();
  IdList::iterator pos = std::find(mIds.begin(), end, id);


  if (pos != end) mIds.erase(mIds.begin(), pos);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

