/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ArgumentsUnitsCheck.h
 * @brief   Ensures units consistent with math
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

#ifndef ArgumentsUnitsCheck_h
#define ArgumentsUnitsCheck_h


#ifdef __cplusplus


#include <string>
#include <sstream>
#include <math.h>

#include <sbml/validator/VConstraint.h>

#include "UnitsBase.h"

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;


class ArgumentsUnitsCheck: public UnitsBase
{
public:

  /**
   * Creates a new Constraint with the given @p id.
   */
  ArgumentsUnitsCheck (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~ArgumentsUnitsCheck ();


protected:

  /**
   * Checks that the units of the ASTnode 
   * are appropriate for the function being performed
   *
   * If inconsistent units are found, an error message is logged.
   */
  virtual void checkUnits (const Model& m, const ASTNode& node, const SBase & sb,
    bool inKL = false, int reactNo = -1);
  
  /**
   * Returns the preamble to use when logging constraint violations.  
   *
   * @return the preamble to use when logging constraint violations.  The
   * preamble will be prepended to each log message.  If not overriden,
   * returns an empty string.
   */
  virtual const char* getPreamble ();

  /**
   * Returns the error message to use when logging constraint violations.
   * This method is called by logFailure.
   *
   * If at all possible please use getPreamble() and getFieldname() when
   * constructing error messages.  This will help to make your constraint
   * easily customizable.
   * 
   * @return the error message to use when logging constraint violations.
   */
  virtual const std::string
  getMessage (const ASTNode& node, const SBase& object);

  /**
    * Checks that the units of the delay function are consistent
    *
    * If inconsistent units are found, an error message is logged.
    */
  void checkUnitsFromDelay (const Model& m, const ASTNode& node, 
                            const SBase & sb, bool inKL, int reactNo);

  /**
    * Checks that the units of the piecewise function are consistent
    *
    * If inconsistent units are found, an error message is logged.
    */
  void checkUnitsFromPiecewise (const Model& m, const ASTNode& node, 
                                const SBase & sb, bool inKL, int reactNo);

  /**
   * Checks that the units of the function are consistent
   * for a function returning value with same units as argument(s)
   *
   * If inconsistent units are found, an error message is logged.
   */
  void checkSameUnitsAsArgs (const Model& m, const ASTNode& node, 
                              const SBase & sb, bool inKL, int reactNo);

  /**
  * Logs a message about a function that should return same units
  * as the arguments
  */
  void logInconsistentSameUnits (const ASTNode & node, const SBase & sb);

  /**
  * Logs a message about a delay function that should have time units
  */
  void logInconsistentDelay (const ASTNode & node, const SBase & sb);

  /**
  * Logs a message about a piecewise function that should same units
  */
  void logInconsistentPiecewise (const ASTNode & node, const SBase & sb);

  /**
  * Logs a message about the conditional part of a piecewise function 
  * that should have dimensionless units
  */
  void logInconsistentPiecewiseCondition (const ASTNode & node, 
                                                    const SBase & sb);

};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* ArgumentsUnitsCheck_h */

/** @endcond */

