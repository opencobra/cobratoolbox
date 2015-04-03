/**
 * @file    VConstraint.cpp
 * @brief   Base class for all SBML Validator Constraints
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/validator/VConstraint.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

VConstraint::VConstraint (unsigned int id, Validator& v) :
    mId       ( id   )
  , mSeverity ( 2    )
  , mValidator( v    )
  , mLogMsg   ( true )
{
}


VConstraint::~VConstraint ()
{
}


/*
 * @return the id of this Constraint.
 */
unsigned int
VConstraint::getId () const
{
  return mId;
}


/*
 * @return the severity for violating this Constraint.
 */
unsigned int
VConstraint::getSeverity () const
{
  return mSeverity;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Logs a constraint failure to the validator for the given SBML object.
 */
void
VConstraint::logFailure (const SBase& object)
{
  logFailure(object, msg);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Logs a constraint failure to the validator for the given SBML object.
 * The parameter message is used instead of the constraint's member
 * variable msg.
 */
void
VConstraint::logFailure (const SBase& object, const std::string& message)
{
  if (&object == NULL || &message == NULL) return;

  SBMLError error = SBMLError( mId, object.getLevel(), object.getVersion(),
			       message, object.getLine(), object.getColumn(),
             LIBSBML_SEV_ERROR, LIBSBML_CAT_SBML, object.getPackageName(),
             object.getPackageVersion());

  if (error.getSeverity() != LIBSBML_SEV_NOT_APPLICABLE)
    mValidator.logFailure(error);

/*    ( SBMLError( mId, object.getLevel(), object.getVersion(),
                 message, object.getLine(), object.getColumn(),
                 LIBSBML_SEV_ERROR, LIBSBML_CAT_SBML ));*/

}
/** @endcond */

#endif /* __cplusplus */


/** @cond doxygenIgnored */

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

