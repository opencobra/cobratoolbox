/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    FunctionReferredToExists.cpp
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

#include <sbml/Model.h>
#include <sbml/Rule.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>

#include "FunctionReferredToExists.h"
#include <sbml/util/IdList.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus


/*
 * Creates a new Constraint with the given constraint id.
 */
FunctionReferredToExists::FunctionReferredToExists (unsigned int id, Validator& v) :
  TConstraint<Model>(id, v)
{
}


/*
 * Destroys this Constraint.
 */
FunctionReferredToExists::~FunctionReferredToExists ()
{
}


/*
 * Checks that all ids on the following Model objects are unique:
 * event assignments and assignment rules.
 */
void
FunctionReferredToExists::check_ (const Model& m, const Model& object)
{
  // does not apply in l2v4 and beyond
  if (m.getLevel() == 2 && m.getVersion() < 4)
  {
    unsigned int n;

    for (n = 0; n < m.getNumFunctionDefinitions(); ++n)
    {
      mFunctions.append(m.getFunctionDefinition(n)->getId());

      checkCiElements(m.getFunctionDefinition(n));
    }
  }
}

/*
  * Checks that &lt;ci&gt; element after an apply is already listed as a FunctionDefinition.
  */
void FunctionReferredToExists::checkCiElements(const FunctionDefinition * fd)
{
  const ASTNode* node = fd->getBody();

  checkCiIsFunction(fd, node);

  //if (node != NULL && node->getType() == AST_FUNCTION)
  //{
  //  if (!mFunctions.contains(node->getName()))
  //  {
  //    logUndefined(*fd, node->getName());
  //  }
  //}

}

/*
  * Checks that &lt;ci&gt; element after an apply is already listed as a FunctionDefinition.
  */
void FunctionReferredToExists::checkCiIsFunction(const FunctionDefinition * fd,
                                                 const ASTNode * node)
{
  if (fd == NULL || node == NULL) return;
  if (node != NULL && node->getType() == AST_FUNCTION)
  {
    if (!mFunctions.contains(node->getName()))
    {
      logUndefined(*fd, node->getName());
    }
  }

  for (unsigned int i = 0; i < node->getNumChildren(); i++)
  {
    checkCiIsFunction(fd, node->getChild(i));
  }
}

/*
  * Logs a message about an undefined &lt;ci&gt; element in the given
  * FunctionDefinition.
  */
void
FunctionReferredToExists::logUndefined ( const FunctionDefinition& fd,
                                       const string& varname )
{
  //msg =
  //  "Inside the 'lambda' of a <functionDefinition>, if a 'ci' element is the "
  //  "first element within a MathML 'apply', then the 'ci''s value can only "
  //  "be chosen from the set of identifiers of other SBML "
  //  "<functionDefinition>s defined prior to that point in the SBML model. In "
  //  "other words, forward references to user-defined functions are not "
  //  "permitted. (References: L2V2 Section 4.3.2.)";

  msg = "'";
  msg += varname;
  msg += "' is not listed as the id of an existing FunctionDefinition.";

  
  logFailure(fd);
}

#endif /* __cplusplus */

LIBSBML_CPP_NAMESPACE_END

/** @endcond */
