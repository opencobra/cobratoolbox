/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    NumericReturnMathCheck.cpp
 * @brief   Ensures math returns a numeric result.
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
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/UnitDefinition.h>
#include <sbml/Event.h>
#include <sbml/Reaction.h>
#include <sbml/EventAssignment.h>
#include <sbml/SpeciesReference.h>
#include <sbml/Rule.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/units/UnitFormulaFormatter.h>

#include "NumericReturnMathCheck.h"

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

static const char* PREAMBLE =
    "The MathML formulas in the following elements must yield numeric "
    "expressions: 'math' in <kineticLaw>, 'stoichiometryMath' in "
    "<speciesReference>, 'math' in <initialAssignment>, 'math' in "
    "<assignmentRule>, 'math' in <rateRule>, 'math' in <algebraicRule>, and "
    "'delay' in <event>, and 'math' in <eventAssignment>.";


/*
 * Creates a new Constraint with the given @p id.
 */
NumericReturnMathCheck::NumericReturnMathCheck (unsigned int id, Validator& v) : MathMLBase(id, v)
{
}


/*
 * Destroys this Constraint.
 */
NumericReturnMathCheck::~NumericReturnMathCheck ()
{
}


/*
 * @return the preamble to use when logging constraint violations.
 */
const char*
NumericReturnMathCheck::getPreamble ()
{
  return PREAMBLE;
}


/*
 * Checks the MathML of the ASTnode 
 * is appropriate for the function being performed
 *
 * If an inconsistency is found, an error message is logged.
 */
void
NumericReturnMathCheck::checkMath (const Model& m, const ASTNode& node, const SBase & sb)
{
  /* should not be here but why not catch it rather than crash*/
  if (&(node) == NULL)
  {
    return;
  }

  //SBMLTypeCode_t type = sb.getTypeCode();
  int type = sb.getTypeCode();
  
  /* HACK: if the math is a lambda - this is invalid
   * and will be caught by constraint 2006
   * dont want to check it here as it will also fire this
   */
  if (!(node.getType() == AST_LAMBDA))
  {
    switch (type) 
    {
      case SBML_KINETIC_LAW:
      case SBML_INITIAL_ASSIGNMENT:
      case SBML_ASSIGNMENT_RULE:
      case SBML_RATE_RULE:
      case SBML_ALGEBRAIC_RULE:
      case SBML_SPECIES_CONCENTRATION_RULE:
      case SBML_COMPARTMENT_VOLUME_RULE:
      case SBML_PARAMETER_RULE:
      case SBML_EVENT_ASSIGNMENT:
      case SBML_SPECIES_REFERENCE:

        if (!returnsNumeric(m, &node))
        {
          logMathConflict(node, sb);
        }
        break;

      case SBML_EVENT:

        /* only want to check delay since trigger should return boolean */
        if (!mIsTrigger && !returnsNumeric(m , &node))
        {
          logMathConflict(node, sb);
        }
        break;

      default:

        break;

    }
  }
}


/*
 * @return the error message to use when logging constraint violations.
 * This method is called by logFailure.
 *
 * Returns a message that the given @p id and its corresponding object are
 * in  conflict with an object previously defined.
 */
const string
NumericReturnMathCheck::getMessage (const ASTNode& node, const SBase& object)
{

  ostringstream msg;

  //msg << getPreamble();

  char * formula = SBML_formulaToString(&node);
  msg << "\nThe formula '" << formula;
  msg << "' in the " << getFieldname() << " element of the " << getTypename(object);
  msg << " does not return a numeric result.";
  safe_free(formula);

  return msg.str();
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

