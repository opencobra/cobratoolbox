/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    AssignmentCycles.h
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

#ifndef AssignmentCycles_h
#define AssignmentCycles_h


#ifdef __cplusplus

#include <string>
#include <sbml/validator/VConstraint.h>

#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

typedef std::multimap<const std::string, std::string> IdMap;
typedef IdMap::iterator                               IdIter;
typedef std::pair<IdIter, IdIter>                     IdRange;

class AssignmentCycles: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given constraint id.
   */
  AssignmentCycles (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~AssignmentCycles ();


protected:

  virtual void check_ (const Model& m, const Model& object);

  
  /* create pairs of ids that depend on each other */
  void addInitialAssignmentDependencies(const Model &, 
                                        const InitialAssignment &);
  
  void addReactionDependencies(const Model &, const Reaction &);
  
  
  void addRuleDependencies(const Model &, const Rule &);

  
  void determineAllDependencies();


  /* helper function to check if a pair already exists */
  bool alreadyExistsInMap(IdMap map, 
                          std::pair<const std::string, std::string> dependency);

  
  /* check for explicit use of original variable */
  void checkForSelfAssignment(const Model &);


  /* find cycles in the map of dependencies */
  void determineCycles(const Model& m);


  /* if a rule for a compartment refers to a species
   * within that compartment it is an implicit reference
   */
  void checkForImplicitCompartmentReference(const Model& m);
  
  /**
   * functions for logging messages about the cycle
   */
  void logCycle (const SBase* object, const SBase* conflict);
  
  
  void logCycle (const Model& m, std::string id, std::string id1);
  
  
  void logMathRefersToSelf (const ASTNode * node,
                                             const SBase* object);
  
  
  void logMathRefersToSelf (const Model& m, std::string id);

  
  void logImplicitReference (const SBase* object, const Species* conflict);


  void logImplicitReference (const Model& m, std::string id, 
                             const Species* conflict);

  
  IdMap mIdMap;

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* AssignmentCycles_h */

/** @endcond */

