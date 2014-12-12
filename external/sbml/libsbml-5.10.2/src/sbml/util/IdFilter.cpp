/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdFilterFilter.cpp
 * @brief   Filter to return only elements with an id set
 * @author  Sarah Keating
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

#include <sbml/util/IdFilter.h>
#include <sbml/SBase.h>

LIBSBML_CPP_NAMESPACE_BEGIN

IdFilter::IdFilter() : ElementFilter()
{
}


IdFilter::~IdFilter()
{
}


bool 
IdFilter::filter(const SBase* element)
{
	// return in case we don't have a valid element with an id
  if (element == NULL || element->isSetId() == false)
  {
      return false;
  }

  // otherwise we have an id set and want to keep the element
  // unless it is a rule or intialAssignment/eventAssignment
  int tc = element->getTypeCode();
  if (tc == SBML_ASSIGNMENT_RULE || tc == SBML_RATE_RULE
    || tc == SBML_INITIAL_ASSIGNMENT || tc == SBML_EVENT_ASSIGNMENT)
  {
    return false;
  }

  return true;			
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
