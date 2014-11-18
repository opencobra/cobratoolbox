/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    DuplicateTopLevelAnnotation.h
 * @brief   Checks for duplicate top level annotations
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

#ifndef DuplicateTopLevelAnnotation_h
#define DuplicateTopLevelAnnotation_h


#ifdef __cplusplus

#include <string>

#include <sbml/validator/VConstraint.h>

#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class DuplicateTopLevelAnnotation: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given constraint id.
   */
  DuplicateTopLevelAnnotation (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~DuplicateTopLevelAnnotation ();


protected:

  /**
   * Checks that &lt;ci&gt; element after an apply is already listed as a FunctionDefinition.
   */
  virtual void check_ (const Model& m, const Model& object);

  /**
   * Checks that &lt;ci&gt; element after an apply is already listed as a FunctionDefinition.
   */
  void checkAnnotation(const SBase& object);

  /**
   * Logs a message about an undefined &lt;ci&gt; element in the given
   * FunctionDefinition.
   */
  void logDuplicate (const std::string name, const SBase& object);

  IdList mNamespaces;

};

LIBSBML_CPP_NAMESPACE_END
#endif  /* __cplusplus */
#endif  /* DuplicateTopLevelAnnotation_h */

/** @endcond */
