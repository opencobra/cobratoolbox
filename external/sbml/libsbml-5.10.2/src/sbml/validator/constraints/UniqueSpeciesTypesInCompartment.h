/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    UniqueSpeciesTypesInCompartment.h
 * @brief   Ensures unique variables assigned by rules and events
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

#ifndef UniqueSpeciesTypesInCompartment_h
#define UniqueSpeciesTypesInCompartment_h


#ifdef __cplusplus

#include <string>

#include <sbml/validator/VConstraint.h>

#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class UniqueSpeciesTypesInCompartment: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given constraint id.
   */
  UniqueSpeciesTypesInCompartment (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~UniqueSpeciesTypesInCompartment ();


protected:

  /**
   * Checks that any species with boundary condition false
   * is not set by reaction and rules
   */
  virtual void check_ (const Model& m, const Model& object);

  /**
   * Logs a message about species with boundary condition false
   * being set by reaction and rules
   */
  void logConflict (const Species& s, const Compartment& c);

  IdList mSpecies;
  IdList mSpeciesTypes;

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* UniqueSpeciesTypesInCompartment_h */

/** @endcond */
