/**
 * @file    UnitKind.h
 * @brief   Definition of SBML's UnitKind enumeration
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
 * ------------------------------------------------------------------------ -->
 *
 * @var typedef enum UnitKind_t
 * @brief Enumeration of predefined SBML base units
 *
 * For more information, please refer to the class documentation for Unit.
 * 
 * @see UnitDefinition_t
 * @see Unit_t
 */

#ifndef UnitKind_h
#define UnitKind_h


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * @var typedef enum UnitKind_t
 */
typedef enum
{
    UNIT_KIND_AMPERE /*!< Ampere ('A'); SI base unit of electrical current (<i>I</i>) */
  , UNIT_KIND_AVOGADRO /*!< Avogadro; From the SBML specification, the unit 'dimensionless' multiplied with Avogadro's number*/
  , UNIT_KIND_BECQUEREL /*!< Bequerel ('Bq'); SI derived unit of radioactivity.  Equivalent to <code>s<sup>-1</sup></code>.*/
  , UNIT_KIND_CANDELA /*!< Candela ('cd'); SI base unit of luminous intensity */
  , UNIT_KIND_CELSIUS /*!< Celsius ('&deg;C'); unit of measurement for temperature.  Can either mean a specific temperature on the Celsius scale, or can indicate a temperature interval.  This duality of purpose makes it a poor choice for a unit and is only included for completeness; use UNIT_KIND_KELVIN instead.*/
  , UNIT_KIND_COULOMB /*!< Coulomb ('C'); SI derived unit of electric charge (<b>Q</b>); the charge transported by a constant current of one ampere in one second (<code>A x s</code>; also equivalent to <code>F x V</code>).*/
  , UNIT_KIND_DIMENSIONLESS /*!< Dimensionless; Having no explicit dimensionality, from the SBML specification.  Sometimes used for counts of items.  Not equivalent to unknown!*/
  , UNIT_KIND_FARAD /*!< Farad ('F'); SI derived unit of electric capacitance.  Equivalent to <code>s<sup>4</sup> x A<sup>2</sup> x m<sup>-2</sup> x kg<sup>-1</sup></code>*/
  , UNIT_KIND_GRAM /*!< Gram ('g'); SI derived unit of mass.  Equivalent to <code>10<sup>-3</sup> kg</code>*/
  , UNIT_KIND_GRAY /*!< Gray ('Gy'); SI derived unit of absorbed dose, specific energy (imparted) and of kerma.  Equivalent to one <code>m<sup>2</sup> x m<sup>-2</sup></code>, or one <code>J x kg<sup>-1</sup></code>.*/
  , UNIT_KIND_HENRY /*!< Henry ('H'); SI derived unit of inductance.  Equivalent to <code>m<sup>2</sup> x kg x s<sup>-2</sup> x A<sup>-2</sup></code>*/
  , UNIT_KIND_HERTZ /*!< Hertz ('Hz'); SI base unit of frequency; a number of cycles per second of a periodic phenomenon.*/
  , UNIT_KIND_ITEM /*!< Item; From the SBML specification, 'item' is used for expressing such things as 'N items' when 'mole' is not an appropriate unit*/
  , UNIT_KIND_JOULE /*!< Joule ('J'); The SI derived unit of energy.  Equivalent to <code>kg x m<sup>2</sup> x s<sup>-2</sup>.</code>*/
  , UNIT_KIND_KATAL /*!< Katal ('kat'); The SI derived unit of catalytic activity.  Equivalent to <code>mol x s<sup>-1</sup>.</code>*/
  , UNIT_KIND_KELVIN /*!< Kelvin ('K'); SI base unit of temperature.*/
  , UNIT_KIND_KILOGRAM /*!< Kilogram ('kg'); SI base unit of mass.*/
  , UNIT_KIND_LITER /*!< Liter ('L'); American spelling of the SI unit 'litre'.  Here solely to catch the misspelling; use  UNIT_KIND_LITRE instead.*/
  , UNIT_KIND_LITRE /*!< Litre ('L'); non-SI metric system of volume.  Equivalent to <code>10<sup>3</sup>cm<sup>3</sup></code>.*/
  , UNIT_KIND_LUMEN /*!< Lumen ('lm'); SI derived unit of luminous flux.  Equivalent to <code>cd x sr</code>.*/
  , UNIT_KIND_LUX /*!< Lux ('lx'); SI derived unit of luminous emittance.  Equivalent to <code>lm x m<sup>-2</sup></code>.*/
  , UNIT_KIND_METER /*!<Meter ('m'); American spelling of the SI unit 'metre'.  Here solely to catch the misspelling; use UNIT_KIND_METRE instead. */
  , UNIT_KIND_METRE /*!< Metre ('m'); SI base unit of length.*/
  , UNIT_KIND_MOLE /*!< Mole ('mol'); SI base unit of amount.  Defined as the amount of any substance that contains as many elementary entities as there are atoms in 12 grams of pure Carbon-12, which corresponds to the Avogadro constant.  See UNIT_KIND_AVOGADRO.*/
  , UNIT_KIND_NEWTON /*!< Newton ('N'); SI derived unit of force.  Equivalent to one <code>kg x m x sec<sup>-2</sup></code>.*/
  , UNIT_KIND_OHM /*!< Ohm ('&#8486;'); SI derived unit of electrical resistance.  Equivalent to <code>kg x m<sup>2</sup> x s<sup>-3</sup> x A<sup>-2</sup></code>.*/
  , UNIT_KIND_PASCAL /*!< Pascal ('Pa'); SI derived unit of pressure.  Equivalent to <code>kg x m<sup>-1</sup> x s<sup>-2</sup></code>.*/
  , UNIT_KIND_RADIAN /*!< Radian ('rad'); SI derived unit of angular measure.  Dimensionless; an angle's measurement in radians is numerically equal to the length of a corresponding arc of a unit circle.*/
  , UNIT_KIND_SECOND /*!< Second ('s'); SI base unit of time.*/
  , UNIT_KIND_SIEMENS /*!< Siemens ('S'); SI derived unit of electric conductance.  Equivalent to <code>A<sup>2</sup> x s<sup>3</sup> x kg<sup>-1</sup> x m<sup>-2</sup></code>.*/
  , UNIT_KIND_SIEVERT /*!< Sievert ('Sv'); SI derived unit of equivalent radiation dose, effective dose, and committed dose.  Equivalent to the UNIT_KIND_GRAY (<code>m<sup>2</sup> x m<sup>-2</sup></code>), but used to express the biological equivalent dose in human tissue.*/
  , UNIT_KIND_STERADIAN /*!< Steradian ('sr'); SI derived unit of solid angle.  An angle's measurement in steradians is numerically equal to the area of the corresponding surface on a unit sphere.  Like the radian, it is dimensionless, essentially because a solid angle is the ratio between the area subtended and the square of its distance from the vertex: both the numerator and denominator of this ratio have dimension <code>length<sup>2</sup></code>. It is useful, however, to distinguish between dimensionless quantities of different nature, so in practice the symbol "sr" is used to indicate a solid angle..*/
  , UNIT_KIND_TESLA /*!< Tesla ('T'); SI derived unit of magnetic field strength or magnetic flux density.  Equivalent to <code>kg x A<sup>-1</sup> x s<sup>-2</sup></code>.*/
  , UNIT_KIND_VOLT /*!< Volt ('V'); SI derived unit of electric potential.  Equivalent to <code>kg x m<sup>2</sup> x A<sup>-1</sup> x s<sup>-3</sup></code>.*/
  , UNIT_KIND_WATT /*!< Watt ('W'); SI derived unit of power.  Equivalent to <code>kg x m<sup>2</sup> x s<sup>-3</sup></code>.*/
  , UNIT_KIND_WEBER /*!< Weber ('Wb'); SI derived unit of magnetic flux.  Equivalent to <code>kg x m<sup>2</sup> x A<sup>-1</sup> x s<sup>-2</sup></code>.*/
  , UNIT_KIND_INVALID /*!< An invalid unit.  Used by libsbml when the 'unit' attribute of an element does not contain any allowed value.*/
} UnitKind_t;


/**
 * Tests for logical equality between two given <code>UNIT_KIND_</code>
 * code values.
 *
 * This function behaves exactly like C's <code>==</code> operator, except
 * for the following two cases:
 * <ul>
  * <li>@sbmlconstant{UNIT_KIND_LITER, UnitKind_t} <code>==</code> @sbmlconstant{UNIT_KIND_LITRE, UnitKind_t}
 * <li>@sbmlconstant{UNIT_KIND_METER, UnitKind_t} <code>==</code> @sbmlconstant{UNIT_KIND_METRE, UnitKind_t}
 * </ul>
 *
 * In the two cases above, C equality comparison would yield @c false
 * (because each of the above is a distinct enumeration value), but
 * this function returns @c true.
 *
 * @param uk1 a <code>UNIT_KIND_</code> value 
 * @param uk2 a second <code>UNIT_KIND_</code> value to compare to @p uk1
 *
 * @return nonzero (for @c true) if @p uk1 is logically equivalent to @p
 * uk2, zero (for @c false) otherwise.
 *
 * @note For more information about the libSBML unit codes, please refer to
 * the class documentation for Unit.
 *
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
int
UnitKind_equals (UnitKind_t uk1, UnitKind_t uk2);


/**
 * Converts a text string naming a kind of unit to its corresponding
 * libSBML <code>UNIT_KIND_</code> constant/enumeration value.
 *
 * @param name a string, the name of a predefined base unit in SBML
 * 
 * @return @if clike a value from UnitKind_t corresponding to the given
 * string @p name (determined in a case-insensitive manner).
 * @endif@if python a value the set of <code>UNIT_KIND_</code> codes
 * defined in class @link libsbml libsbml@endlink, corresponding to the
 * string @p name (determined in a case-insensitive
 * manner).@endif@if java a value the set of <code>UNIT_KIND_</code> codes
 * defined in class {@link libsbmlConstants}, corresponding to the string
 * @p name (determined in a case-insensitive manner).@endif@~
 *
 * @note For more information about the libSBML unit codes, please refer to
 * the class documentation for Unit.
 *
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
UnitKind_t
UnitKind_forName (const char *name);


/**
 * Converts a unit code to a text string equivalent.
 *
 * @param uk @if clike a value from the UnitKind_t enumeration
 * @endif@if python a value from the set of <code>UNIT_KIND_</code> codes
 * defined in the class @link libsbml libsbml@endlink
 * @endif@if java a value from the set of <code>UNIT_KIND_</code> codes
 * defined in the class {@link libsbmlConstants}
 * @endif@~
 *
 * @return the name corresponding to the given unit code.
 *
 * @note For more information about the libSBML unit codes, please refer to
 * the class documentation for Unit.
 * 
 * @warning The string returned is a static data value.  The caller does not
 * own the returned string and is therefore not allowed to modify it.
 *
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
const char *
UnitKind_toString (UnitKind_t uk);


/**
 * Predicate for testing whether a given string corresponds to a
 * predefined libSBML unit code.
 *
 * @param str a text string naming a base unit defined by SBML
 * @param level the Level of SBML
 * @param version the Version within the Level of SBML
 *
 * @return nonzero (for @c true) if string is the name of a valid
 * <code>UNIT_KIND_</code> value, zero (for @c false) otherwise.
 *
 * @note For more information about the libSBML unit codes, please refer to
 * the class documentation for Unit.
 *
 * @if conly
 * @memberof Unit_t
 * @endif
 */
LIBSBML_EXTERN
int
UnitKind_isValidUnitKindString (const char *str, unsigned int level, unsigned int version);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /** UnitKind_h **/

