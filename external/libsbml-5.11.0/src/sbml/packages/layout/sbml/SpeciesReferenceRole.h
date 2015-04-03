/**
 * @file    SpeciesReferenceRole.h
 * @brief   Definition of SpeciesReferenceRole enum for SBML Layout.
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

#include <sbml/common/extern.h>


#ifndef SpeciesReferenceRole_H__
#define SpeciesReferenceRole_H__

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * @enum  SpeciesReferenceRole_t
 * @brief SpeciesReferenceRole_t is the enumeration of possible values for the 'role' attribute of a SpeciesReferenceGlyph.
 *
 * The role attribute is of type SpeciesReferenceRole and is used to specify how the species reference should be displayed. Allowed values are 'substrate', 'product', 'sidesubstrate', 'sideproduct', 'modifier', 'activator', 'inhibitor' and 'undefined'. 
 *
 * This attribute is optional and should only be necessary if the optional speciesReference attribute is not given or if the respective information from the model needs to be overridden.
 */
LIBSBML_EXTERN
typedef enum
{
    SPECIES_ROLE_UNDEFINED /*!< 'undefined':  The role of the referenced Species is undefined. */
  , SPECIES_ROLE_SUBSTRATE /*!< 'substrate':  The referenced Species is a principle substrate of the reaction. */
  , SPECIES_ROLE_PRODUCT /*!< 'product':  The referenced Species is a principle product of the reaction. */
  , SPECIES_ROLE_SIDESUBSTRATE /*!< 'sidesubstrate':  The referenced Species is a side substrate of the reaction.  Used for simple chemicals such as ATP, NAD+, etc.*/
  , SPECIES_ROLE_SIDEPRODUCT /*!< 'sideproduct':  The referenced Species is a side product of the reaction.  Used for simple chemicals such as ATP, NAD+, etc. */
  , SPECIES_ROLE_MODIFIER /*!< 'modifier':  The referenced Species influences the reaction in some way, but is not produced or consumed by it. */
  , SPECIES_ROLE_ACTIVATOR /*!< The referenced Species acts as an activator of the reaction. */
  , SPECIES_ROLE_INHIBITOR /*!< The referenced Species acts as an inhibitor of the reaction. */
} SpeciesReferenceRole_t;


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* SpeciesReferenceRole_H__ */
