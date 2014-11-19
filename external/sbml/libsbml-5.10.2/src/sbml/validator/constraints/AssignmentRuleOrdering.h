/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    AssignmentRuleOrdering.h
 * @brief   Checks rule ordering for l2v1 and l1
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

#ifndef AssignmentRuleOrdering_h
#define AssignmentRuleOrdering_h


#ifdef __cplusplus

#include <string>
#include <sbml/validator/VConstraint.h>

#include <sbml/util/IdList.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class AssignmentRuleOrdering: public TConstraint<Model>
{
public:

  /**
   * Creates a new Constraint with the given constraint id.
   */
  AssignmentRuleOrdering (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~AssignmentRuleOrdering ();


protected:

  /**
   * Checks that &lt;ci&gt; element after an apply is already listed as a FunctionDefinition.
   */
  virtual void check_ (const Model& m, const Model& object);

  void checkRuleForVariable(const Model &, const Rule &);
  void checkRuleForLaterVariables(const Model &, const Rule &,
                                                        unsigned int);
  /**
   * Logs a message about an undefined &lt;ci&gt; element in the given
   * FunctionDefinition.
   */
void logForwardReference (const ASTNode & node,
                                             const SBase& object,
                                             std::string name);
  void logRuleRefersToSelf ( const ASTNode & node, const SBase& object);

  IdList mVariables;
  IdList mTempList;
  IdList mVariableList;

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* AssignmentRuleOrdering_h */

/** @endcond */

