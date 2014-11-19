/**
 * @file    LayoutUtilities.h
 * @brief   Definition of LayoutUtilities for SBML Layout.
 * @author  Ralph Gauges
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
 * Copyright (C) 2004-2008 by European Media Laboratories Research gGmbH,
 *     Heidelberg, Germany
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#ifndef LAYOUTUTILITIES_H_
#define LAYOUTUTILITIES_H_

#include <sbml/SBase.h>
#include <sbml/common/extern.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * Converts the given SBase* object to an XMLNode, with the appropriate namespace defined.
 */
LIBSBML_EXTERN XMLNode getXmlNodeForSBase(const SBase* object);

/**
 * If defined, adds the 'metaid' attribute from the provided SBase object to the XMLAttributes object.
 */
LIBSBML_EXTERN void addSBaseAttributes(const SBase& object,XMLAttributes& att);

/**
 * If defined, adds the 'id' attribute from the provided SBase object to the XMLAttributes object.
 */
LIBSBML_EXTERN void addGraphicalObjectAttributes(const GraphicalObject& object,XMLAttributes& att);

/**
 * copies the attributes from source to target
 * this is used in the assignment operators and copy constructors
 */
LIBSBML_EXTERN void copySBaseAttributes(const SBase& source,SBase& target);

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#endif /*LAYOUTUTILITIES_H_*/
