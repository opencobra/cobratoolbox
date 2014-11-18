/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    MathMLConsistencyConstraints.cpp
 * @brief   MathMLConsistency check constraints.  See SBML Wiki
 * @author  Ben Bornstein
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

//#include <string>

#include <sbml/validator/VConstraint.h>
#include "LogicalArgsMathCheck.h"
#include "NumericArgsMathCheck.h"
#include "PieceBooleanMathCheck.h"
#include "PiecewiseValueMathCheck.h"
#include "EqualityArgsMathCheck.h"
#include "FunctionApplyMathCheck.h"
#include "CiElementMathCheck.h"
#include "LambdaMathCheck.h"
#include "NumericReturnMathCheck.h"
#include "LocalParameterMathCheck.h"
#include "NumberArgsMathCheck.h"
#include "FunctionNoArgsMathCheck.h"
#include "ValidCnUnitsValue.h"


#endif


#include <sbml/validator/ConstraintMacros.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

// General XML validation

// 10101: utf-8 - caught at read
// 10102: undfeined element - caught at read
// 10103: schema conformance - caught in various places

//General MathML validation

// 10201: namespace - caught at read
// 10202: elements - caught at read
// 10203: encoding - caught at read
// 10204: url - caught at read
// 10205: time/delay url - caught at read
// 10206: type - caught at read
// 10207: values for type - caught at read

EXTERN_CONSTRAINT( 10208, LambdaMathCheck        )
EXTERN_CONSTRAINT( 10209, LogicalArgsMathCheck   )
EXTERN_CONSTRAINT( 10210, NumericArgsMathCheck   )
EXTERN_CONSTRAINT( 10211, EqualityArgsMathCheck  )
EXTERN_CONSTRAINT( 10212, PiecewiseValueMathCheck)
EXTERN_CONSTRAINT( 10213, PieceBooleanMathCheck  )
EXTERN_CONSTRAINT( 10214, FunctionApplyMathCheck )
EXTERN_CONSTRAINT( 10215, CiElementMathCheck     )
EXTERN_CONSTRAINT( 10216, LocalParameterMathCheck)
EXTERN_CONSTRAINT( 10217, NumericReturnMathCheck )
EXTERN_CONSTRAINT( 10218, NumberArgsMathCheck )
EXTERN_CONSTRAINT( 10219, FunctionNoArgsMathCheck )

// 10220: units only on cn - caught at read

EXTERN_CONSTRAINT( 10221, ValidCnUnitsValue)


/** @endcond */
