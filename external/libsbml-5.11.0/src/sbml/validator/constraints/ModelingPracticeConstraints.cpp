/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ModelingPracticeConstraints.cpp
 * @brief   ModelingPractice check constraints.  
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

#ifndef AddingConstraintsToValidator
#include <sbml/validator/VConstraint.h>
#endif

#include <sbml/validator/ConstraintMacros.h>

#include "LocalParameterShadowsIdInModel.h"
/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

// Compartment validation

START_CONSTRAINT (80501, Compartment, c)
{
  pre( c.getLevel() > 1);
  pre( c.getSpatialDimensions() != 0 );
  
  //msg =
  //  "It is recommended that the size of a compartment is set.";

  bool fail = true;

  // is size set on the element
  if (c.isSetSize() == true)
  {
    fail = false;
  }
  else
  {
    pre (c.isSetId() == true);
    // is there an initial assignment/assignment rule that would set the value
    if (m.getInitialAssignmentBySymbol(c.getId()) != NULL)
    {
      fail = false;
    }
    else if (m.getAssignmentRuleByVariable(c.getId()) != NULL)
    {
      fail = false;
    }
  }

  inv( fail == false);
}
END_CONSTRAINT


START_CONSTRAINT (80601, Species, s)
{
  bool fail = true;

  if (s.isSetInitialAmount() == true || s.isSetInitialConcentration() == true)
  {
    fail = false;
  }
  else
  {
    pre (s.isSetId() == true);
    // is there an initial assignment/assignment rule that would set the value
    if (m.getInitialAssignmentBySymbol(s.getId()) != NULL)
    {
      fail = false;
    }
    else if (m.getAssignmentRuleByVariable(s.getId()) != NULL)
    {
      fail = false;
    }
  }

  inv (fail == false);
}
END_CONSTRAINT


// Parameters
EXTERN_CONSTRAINT( 81121, LocalParameterShadowsIdInModel             )


START_CONSTRAINT (80701, Parameter, p)
{
  inv(p.isSetUnits() == true);
}
END_CONSTRAINT



/** @endcond */

