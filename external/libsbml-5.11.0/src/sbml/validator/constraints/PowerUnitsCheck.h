/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    PowerUnitsCheck.h
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

#ifndef PowerUnitsCheck_h
#define PowerUnitsCheck_h


#ifdef __cplusplus


#include <string>
#include <sstream>
#include <math.h>

#include <sbml/validator/VConstraint.h>

#include "UnitsBase.h"

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;


class PowerUnitsCheck: public UnitsBase
{
public:

  /**
   * Creates a new Constraint with the given @p id.
   */
  PowerUnitsCheck (unsigned int id, Validator& v);

  /**
   * Destroys this Constraint.
   */
  virtual ~PowerUnitsCheck ();


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
   * Checks that the units of the power function are consistent
   *
   * If inconsistent units are found, an error message is logged.
   */
  void checkUnitsFromPower (const Model& m, const ASTNode& node, 
                              const SBase & sb, bool inKL, int reactNo);

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

  void logNonDimensionlessPowerConflict (const ASTNode & node, 
                                             const SBase & sb);

  void logNonIntegerPowerConflict (const ASTNode & node, 
                                             const SBase & sb);
  void logRationalPowerConflict (const ASTNode & node, 
                                             const SBase & sb);
  void logExpressionPowerConflict (const ASTNode & node, 
                                             const SBase & sb);
  /* HACK: until I rewrite the unit stuff
   * if a mathml has pow(p, 0.5)/ pow (p, 0.5) then its valid
   * at moment it will fire this constraint twice
   */

  void checkForPowersBeingDivided (const Model& m, const ASTNode& node, 
                              const SBase & sb);
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* PowerUnitsCheck_h */

/** @endcond */

