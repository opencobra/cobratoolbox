/**
 * @file    UnitKind.c
 * @brief   SBML UnitKind enumeration
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

#include <sbml/common/common.h>
#include <sbml/UnitKind.h>


const char* UNIT_KIND_STRINGS[] =
{
    "ampere"
  , "avogadro"
  , "becquerel"
  , "candela"
  , "Celsius"
  , "coulomb"
  , "dimensionless"
  , "farad"
  , "gram"
  , "gray"
  , "henry"
  , "hertz"
  , "item"
  , "joule"
  , "katal"
  , "kelvin"
  , "kilogram"
  , "liter"
  , "litre"
  , "lumen"
  , "lux"
  , "meter"
  , "metre"
  , "mole"
  , "newton"
  , "ohm"
  , "pascal"
  , "radian"
  , "second"
  , "siemens"
  , "sievert"
  , "steradian"
  , "tesla"
  , "volt"
  , "watt"
  , "weber"
  , "(Invalid UnitKind)"
};

/**
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
int
UnitKind_equals (UnitKind_t uk1, UnitKind_t uk2)
{
  return
    (uk1 == uk2) ||
    ( (uk1 == UNIT_KIND_LITER) && (uk2 == UNIT_KIND_LITRE) ) ||
    ( (uk1 == UNIT_KIND_LITRE) && (uk2 == UNIT_KIND_LITER) ) ||
    ( (uk1 == UNIT_KIND_METER) && (uk2 == UNIT_KIND_METRE) ) ||
    ( (uk1 == UNIT_KIND_METRE) && (uk2 == UNIT_KIND_METER) );
}


/**
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
UnitKind_t
UnitKind_forName (const char *name)
{
  if (name != NULL)
  {
    const UnitKind_t lo = UNIT_KIND_AMPERE;
    const UnitKind_t hi = UNIT_KIND_WEBER;

    return util_bsearchStringsI(UNIT_KIND_STRINGS, name, lo, hi);
  }
  else
    return UNIT_KIND_INVALID;
}


/**
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
const char *
UnitKind_toString (UnitKind_t uk)
{
  if ( (uk < UNIT_KIND_AMPERE) || (uk > UNIT_KIND_INVALID) )
  {
    uk = UNIT_KIND_INVALID;
  }

  return UNIT_KIND_STRINGS[uk];
}


/**
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
int
UnitKind_isValidUnitKindString (const char *str, unsigned int level, unsigned int version)
{
  UnitKind_t uk = UnitKind_forName(str);
  if (level == 1)
  {
    return uk != UNIT_KIND_INVALID;
  }
  else
  {
    if (uk == UNIT_KIND_METER || uk == UNIT_KIND_LITER)
      return 0;
    else if (version > 1 && uk == UNIT_KIND_CELSIUS)
      return 0;
    else
      return uk != UNIT_KIND_INVALID;
  }
}

