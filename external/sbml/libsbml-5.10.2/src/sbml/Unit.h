/**
 * @file    Unit.h
 * @brief   Definitions of Unit and ListOfUnits.
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
 * ---------------------------------------------------------------------- -->
 *
 * @class Unit
 * @sbmlbrief{core} A single unit referenced in an SBML <em>unit definition</em>.
 *
 * The SBML unit definition facility uses two classes of objects,
 * UnitDefinition and Unit.  The approach to defining units in %SBML is
 * compositional; for example, <em>meter second<sup> &ndash;2</sup></em> is
 * constructed by combining a Unit object representing <em>meter</em> with
 * another Unit object representing <em>second<sup> &ndash;2</sup></em>.
 * The combination is wrapped inside a UnitDefinition, which provides for
 * assigning an identifier and optional name to the combination.  The
 * identifier can then be referenced from elsewhere in a model.  Thus, the
 * UnitDefinition class is the container, and Unit instances are placed
 * inside UnitDefinition instances.
 *
 * A Unit has four attributes named "kind", "exponent", "scale"
 * and "multiplier".  It represents a (possibly transformed) reference to a
 * base unit.  The attribute "kind" on Unit indicates the chosen base unit.
 * Its value must be one of the text strings listed below; this list
 * corresponds to SBML Level&nbsp;3 Version&nbsp;1 Core:
 *
 * @copydetails doc_base_units
 *
 * A few small differences exist between the Level&nbsp;3 list of base
 * units and the list defined in other Level/Version combinations of SBML.
 * Specifically, Levels of SBML before Level&nbsp;3 do not define @c
 * avogadro; conversely, Level&nbsp;2 Version&nbsp;1 defines @c Celsius,
 * and Level&nbsp;1 defines @c celsius, @c meter, and @c liter, none of
 * which are available in Level&nbsp;3.  In libSBML, each of the predefined
 * base unit names is represented by an enumeration value @if clike in
 * #UnitKind_t@else whose name begins with the characters
 * <code>UNIT_KIND_</code>@endif, discussed in a separate section below.
 *
 * The attribute named "exponent" on Unit represents an exponent on the
 * unit.  In SBML Level&nbsp;2, the attribute is optional and has a default
 * value of @c 1 (one); in SBML Level&nbsp;3, the attribute is mandatory
 * and there is no default value.  A Unit also has an attribute
 * called "scale"; its value must be an integer exponent for a power-of-ten
 * multiplier used to set the scale of the unit.  For example, a unit
 * having a "kind" value of @c gram and a "scale" value of @c -3 signifies
 * 10<sup>&nbsp;&ndash;3</sup> \f$\times\f$ gram, or milligrams.  In SBML
 * Level&nbsp;2, the attribute is optional and has a default value of @c 0
 * (zero), because 10<sup> 0</sup> = 1; in SBML Level&nbsp;3, the attribute
 * is mandatory and has no default value.  Lastly, the attribute named
 * "multiplier" can be used to multiply the unit by a real-numbered factor;
 * this enables the definition of units that are not power-of-ten multiples
 * of SI units.  For instance, a multiplier of 0.3048 could be used to
 * define @c foot as a measure of length in terms of a @c metre.  The
 * "multiplier" attribute is optional in SBML Level&nbsp;2, where it has a
 * default value of @c 1 (one); in SBML Level&nbsp;3, the attribute is
 * mandatory and has not default value.
 *
 * @if clike
 * <h3><a class="anchor" name="UnitKind_t">UnitKind_t</a></h3>
 * @else
 * <h3><a class="anchor" name="UnitKind_t">%Unit identification codes</a></h3>
 * @endif@~
 *
 * As discussed above, SBML defines a set of base units which serves as the
 * starting point for new unit definitions.  This set of base units
 * consists of the SI units and a small number of additional convenience
 * units.
 * 
 * @if clike Until SBML Level&nbsp;2 Version&nbsp;3, there
 * existed a data type in the SBML specifications called @c UnitKind,
 * enumerating the possible SBML base units.  Although SBML Level&nbsp;2
 * Version&nbsp;3 removed this type from the language specification,
 * libSBML maintains the corresponding enumeration type #UnitKind_t as a
 * convenience and as a way to provide backward compatibility to previous
 * SBML Level/Version specifications.  (The removal in SBML Level&nbsp;2
 * Version&nbsp;3 of the enumeration @c UnitKind was also accompanied by
 * the redefinition of the data type @c UnitSId to include the previous @c
 * UnitKind values as reserved symbols in the @c UnitSId space.  This
 * change has no net effect on permissible models, their representation or
 * their syntax.  The purpose of the change in the SBML specification was
 * simply to clean up an inconsistency about the contexts in which these
 * values were usable.)
 * @endif@if java In SBML Level&nbsp;2 Versions before
 * Version&nbsp;3, there existed an enumeration of units called @c
 * UnitKind.  In Version&nbsp;3, this enumeration was removed and the
 * identifier class @c UnitSId redefined to include the previous @c
 * UnitKind values as reserved symbols.  This change has no net effect on
 * permissible models, their representation or their syntax.  The purpose
 * of the change in the SBML specification was simply to clean up an
 * inconsistency about the contexts in which these values were usable.
 * However, libSBML maintains UnitKind in the form of of a set of static
 * integer constants whose names begin with the characters
 * <code>UNIT_KIND_</code>.  These constants are defined in the class
 * <code><a href="libsbmlConstants.html">libsbmlConstants</a></code>.
 * @endif@if python In SBML Level&nbsp;2 Versions before
 * Version&nbsp;3, there existed an enumeration of units called @c
 * UnitKind.  In Version&nbsp;3, this enumeration was removed and the
 * identifier class @c UnitSId redefined to include the previous @c
 * UnitKind values as reserved symbols.  This change has no net effect on
 * permissible models, their representation or their syntax.  The purpose
 * of the change in the SBML specification was simply to clean up an
 * inconsistency about the contexts in which these values were usable.
 * However, libSBML maintains UnitKind in the form of of a set of static
 * integer constants whose names begin with the characters
 * <code>UNIT_KIND_</code>.  These constants are defined in the class
 * @link libsbml libsbml@endlink.
 * @endif@~
 *
 * As a consequence of the fact that libSBML supports models in all Levels
 * and Versions of SBML, libSBML's set of @c UNIT_KIND_ values is a union
 * of all the possible base unit names defined in the different SBML
 * specifications.  However, not every base unit is allowed in every
 * Level+Version combination of SBML.  Note in particular the following
 * exceptions:
 * <ul>
 * <li> The alternate spelling @c "meter" is included in
 * addition to the official SI spelling @c "metre".  This spelling is only
 * permitted in SBML Level&nbsp;1 models.
 *
 * <li> The alternate spelling @c "liter" is included in addition to the
 * official SI spelling @c "litre".  This spelling is only permitted in
 * SBML Level&nbsp;1 models.
 *
 * <li> The unit @c "Celsius" is included because of its presence in
 * specifications of SBML prior to SBML Level&nbsp;2 Version&nbsp;3.
 *
 * <li> The unit @c avogadro was introduced in SBML Level&nbsp;3, and
 * is only permitted for use in SBML Level&nbsp;3 models.
 * </ul>
 *
 * @if clike The table below lists the symbols defined in the
 * @c UnitKind_t enumeration, and their
 * meanings. @else The table below lists the unit
 * constants defined in libSBML, and their meanings. @endif@~
 *
 * @htmlinclude unitkind-table.html
 * 
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfUnits
 * @sbmlbrief{core} A list of Unit objects.
 * 
 * ListOfUnits is entirely contained within UnitDefinition.
 *
 * @copydetails doc_what_is_listof
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_warning_unit_offset_only_l2v1
 * 
 * @warning <span class="warning">The "offset" attribute is only available in
 * SBML Level&nbsp;2 Version&nbsp;1.  This attribute is not present in SBML
 * Level&nbsp;2 Version&nbsp;2 or above.  When producing SBML models using
 * these later specifications, modelers and software tools need to account
 * for units with offsets explicitly.  The %SBML specification document
 * offers a number of suggestions for how to achieve this.  LibSBML methods
 * such as this one related to "offset" are retained for compatibility with
 * earlier versions of SBML Level&nbsp;2, but their use is strongly
 * discouraged.</span>
 * 
 */

#ifndef Unit_h
#define Unit_h

#include <math.h>

#include <sbml/common/common.h>
#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/UnitKind.h>


#ifdef __cplusplus


#include <string>
#include <cstring>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>
#include <sbml/common/operationReturnValues.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN Unit : public SBase
{
public:

  /**
   * Creates a new Unit using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Unit
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Unit
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Unit (unsigned int level, unsigned int version);


  /**
   * Creates a new Unit using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces
   * 
   * @param sbmlns an SBMLNamespaces object.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Unit (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Unit.
   */
  virtual ~Unit ();


  /**
   * Copy constructor; creates a copy of this Unit.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Unit(const Unit& orig);


  /**
   * Assignment operator.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Unit& operator=(const Unit& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Unit.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next Unit in the list
   * of units within which this Unit is embedded (i.e., in the ListOfUnits
   * located in the enclosing UnitDefinition instance).
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Unit object.
   *
   * @return the (deep) copy of this Unit object.
   */
  virtual Unit* clone () const;


  /**
   * Initializes the fields of this Unit object to "typical" default
   * values.
   *
   * The SBML Unit component has slightly different aspects and default
   * attribute values in different SBML Levels and Versions.  This method
   * sets the values to certain common defaults, based mostly on what they
   * are in SBML Level&nbsp;2.  Specifically:
   * <ul>
   * <li> Sets attribute "exponent" to @c 1
   * <li> Sets attribute "scale" to @c 0
   * <li> Sets attribute "multiplier" to @c 1.0
   * </ul>
   *
   * The "kind" attribute is left unchanged.
   */
  void initDefaults ();


  /**
   * Returns the "kind" of Unit this is.
   * 
   * @if clike
   * @return the value of the "kind" attribute of this Unit as a
   * value from the <a class="el" href="#UnitKind_t">UnitKind_t</a> enumeration.
   * @endif@if java
   * @return the value of the "kind" attribute of this Unit as a
   * value from the set of constants whose names begin
   * with <code>UNIT_KIND_</code> defined in the class
   * <code><a href="libsbmlConstants.html">libsbmlConstants</a></code>.
   * @endif@if python
   * @return the value of the "kind" attribute of this Unit as a
   * value from the set of constants whose names begin
   * with <code>UNIT_KIND_</code> defined in the class
   * @link libsbml libsbml@endlink.
   * @endif@~
   */
  UnitKind_t getKind () const;


  /**
   * Returns the value of the "exponent" attribute of this unit.
   * 
   * @return the "exponent" value of this Unit, as an integer.
   */
  int getExponent () const;


  /**
   * Returns the value of the "exponent" attribute of this unit.
   * 
   * @return the "exponent" value of this Unit, as a double.
   */
  double getExponentAsDouble () const;


  /**
   * Returns the value of the "scale" attribute of this unit.
   * 
   * @return the "scale" value of this Unit, as an integer.
   */
  int getScale () const;


  /**
   * Returns the value of the "multiplier" attribute of this Unit.
   * 
   * @return the "multiplier" value of this Unit, as a double.
   */
  double getMultiplier () const;


  /**
   * Returns the value of the "offset" attribute of this Unit.
   * 
   * @return the "offset" value of this Unit, as a double.
   *
   * @copydetails doc_warning_unit_offset_only_l2v1
   */
  double getOffset () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c ampere.
   * 
   * @return @c true if the kind of this Unit is @c ampere, @c false
   * otherwise. 
   */
  bool isAmpere () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c avogadro.
   * 
   * @return @c true if the kind of this Unit is @c avogadro, @c false
   * otherwise.
   *
   * @note The unit @c avogadro was introduced in SBML Level&nbsp;3, and
   * is only permitted for use in SBML Level&nbsp;3 models.
   */
  bool isAvogadro () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c becquerel
   *
   * @return @c true if the kind of this Unit is @c becquerel, @c false
   * otherwise. 
   */
  bool isBecquerel () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c candela
   *
   * @return @c true if the kind of this Unit is @c candela, @c false
   * otherwise. 
   */
  bool isCandela () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c Celsius
   *
   * @return @c true if the kind of this Unit is @c Celsius, @c false
   * otherwise. 
   *
   * @warning <span class="warning">The predefined unit @c Celsius was
   * removed from the list of predefined units in SBML Level&nbsp;2
   * Version&nbsp;2 at the same time that the "offset" attribute was removed
   * from Unit definitions.  LibSBML methods such as this one related to @c
   * Celsius are retained in order to support SBML Level&nbsp;2
   * Version&nbsp;1, but their use is strongly discouraged.</span>
   */
  bool isCelsius () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c coulomb
   *
   * @return @c true if the kind of this Unit is @c coulomb, @c false
   * otherwise. 
   */
  bool isCoulomb () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c
   * dimensionless.
   *
   * @return @c true if the kind of this Unit is @c dimensionless, @c false
   * 
   * otherwise.
   */
  bool isDimensionless () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c farad
   *
   * @return @c true if the kind of this Unit is @c farad, @c false
   * otherwise. 
   */
  bool isFarad () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c gram
   *
   * @return @c true if the kind of this Unit is @c gram, @c false
   * otherwise. 
   */
  bool isGram () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c gray
   *
   * @return @c true if the kind of this Unit is @c gray, @c false
   * otherwise. 
   */
  bool isGray () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c henry
   *
   * @return @c true if the kind of this Unit is @c henry, @c false
   * otherwise. 
   */
  bool isHenry () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c hertz
   *
   * @return @c true if the kind of this Unit is @c hertz, @c false
   * otherwise. 
   */
  bool isHertz () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c item
   *
   * @return @c true if the kind of this Unit is @c item, @c false
   * otherwise. 
   */
  bool isItem () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c joule
   *
   * @return @c true if the kind of this Unit is @c joule, @c false
   * otherwise. 
   */
  bool isJoule () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c katal
   *
   * @return @c true if the kind of this Unit is @c katal, @c false
   * otherwise. 
   */
  bool isKatal () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c kelvin
   *
   * @return @c true if the kind of this Unit is @c kelvin, @c false
   * otherwise. 
   */
  bool isKelvin () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c kilogram
   *
   * @return @c true if the kind of this Unit is @c kilogram, @c false
   * otherwise. 
   */
  bool isKilogram () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c litre
   *
   * @return @c true if the kind of this Unit is @c litre or 'liter', @c
   * false 
   * otherwise.
   */
  bool isLitre () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c lumen
   *
   * @return @c true if the kind of this Unit is @c lumen, @c false
   * otherwise. 
   */
  bool isLumen () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c lux
   *
   * @return @c true if the kind of this Unit is @c lux, @c false
   * otherwise. 
   */
  bool isLux () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c metre
   *
   * @return @c true if the kind of this Unit is @c metre or 'meter', @c
   * false 
   * otherwise.
   */
  bool isMetre () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c mole
   *
   * @return @c true if the kind of this Unit is @c mole, @c false
   * otherwise. 
   */
  bool isMole () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c newton
   *
   * @return @c true if the kind of this Unit is @c newton, @c false
   * otherwise. 
   */
  bool isNewton () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c ohm
   *
   * @return @c true if the kind of this Unit is @c ohm, @c false
   * otherwise. 
   */
  bool isOhm () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c pascal
   *
   * @return @c true if the kind of this Unit is @c pascal, @c false
   * otherwise. 
   */
  bool isPascal () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c radian
   *
   * @return @c true if the kind of this Unit is @c radian, @c false
   * otherwise. 
   */
  bool isRadian () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c second
   *
   * @return @c true if the kind of this Unit is @c second, @c false
   * otherwise. 
   */
  bool isSecond () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c siemens
   *
   * @return @c true if the kind of this Unit is @c siemens, @c false
   * otherwise. 
   */
  bool isSiemens () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c sievert
   *
   * @return @c true if the kind of this Unit is @c sievert, @c false
   * otherwise. 
   */
  bool isSievert () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c steradian
   *
   * @return @c true if the kind of this Unit is @c steradian, @c false
   * otherwise. 
   */
  bool isSteradian () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c tesla
   *
   * @return @c true if the kind of this Unit is @c tesla, @c false
   * otherwise. 
   */
  bool isTesla () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c volt
   *
   * @return @c true if the kind of this Unit is @c volt, @c false
   * otherwise. 
   */
  bool isVolt () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c watt
   *
   * @return @c true if the kind of this Unit is @c watt, @c false
   * otherwise. 
   */
  bool isWatt () const;


  /**
   * Predicate for testing whether this Unit is of the kind @c weber
   *
   * @return @c true if the kind of this Unit is @c weber, @c false
   * otherwise. 
   */
  bool isWeber () const;


  /**
   * Predicate to test whether the "kind" attribute of this Unit is set.
   * 
   * @return @c true if the "kind" attribute of this Unit is set, @c
   * false otherwise.
   */
  bool isSetKind () const;


  /**
   * Predicate to test whether the "exponent" attribute of this Unit 
   * is set.
   * 
   * @return @c true if the "exponent" attribute of this Unit is set, 
   * @c false otherwise.
   */
  bool isSetExponent () const;


  /**
   * Predicate to test whether the "scale" attribute of this Unit 
   * is set.
   * 
   * @return @c true if the "scale" attribute of this Unit is set, 
   * @c false otherwise.
   */
  bool isSetScale () const;


  /**
   * Predicate to test whether the "multiplier" attribute of this Unit 
   * is set.
   * 
   * @return @c true if the "multiplier" attribute of this Unit is set, 
   * @c false otherwise.
   */
  bool isSetMultiplier () const;


  /**
   * Sets the "kind" attribute value of this Unit.
   *
   * @if clike
   * @param kind a value from the <a class="el"
   * href="#UnitKind_t">UnitKind_t</a> enumeration.
   * @endif@if java
   * @param kind a unit identifier chosen from the set of constants whose
   * names begin with <code>UNIT_KIND_</code> in <code><a
   * href="libsbmlConstants.html">libsbmlConstants</a></code>.
   * @endif@if python
   * @param kind a unit identifier chosen from the set of constants whose
   * names begin with <code>UNIT_KIND_</code> in @link libsbml libsbml@endlink.
   * @endif@~
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setKind (UnitKind_t kind);


  /**
   * Sets the "exponent" attribute value of this Unit.
   *
   * @param value the integer to which the attribute "exponent" should be set
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setExponent (int value);


  /**
   * Sets the "exponent" attribute value of this Unit.
   *
   * @param value the double to which the attribute "exponent" should be set
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setExponent (double value);


  /**
   * Sets the "scale" attribute value of this Unit.
   *
   * @param value the integer to which the attribute "scale" should be set
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setScale (int value);


  /**
   * Sets the "multipler" attribute value of this Unit.
   *
   * @param value the floating-point value to which the attribute
   * "multiplier" should be set
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  int setMultiplier (double value);


  /**
   * Sets the "offset" attribute value of this Unit.
   *
   * @param value the float-point value to which the attribute "offset"
   * should set
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_warning_unit_offset_only_l2v1
   */
  int setOffset (double value);


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_UNIT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getPackageName()
   * @see getElementName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Unit, is
   * always @c "unit".
   * 
   * @return the name of this element, i.e., @c "unit". 
   */
  virtual const std::string& getElementName () const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write out their contained
   * SBML objects as XML elements.  Be sure to call your parents
   * implementation of this method as well.
   */
  virtual void writeElements (XMLOutputStream& stream) const;
  /** @endcond */


  /**
   * Predicate to test whether a given string is the name of a
   * predefined SBML unit.
   *
   * @param name a string to be tested against the predefined unit names
   *
   * @param level the Level of SBML for which the determination should be
   * made.  This is necessary because there are a few small differences
   * in allowed units between SBML Level&nbsp;1 and Level&nbsp;2.
   * 
   * @return @c true if @p name is one of the five SBML predefined unit
   * identifiers (@c "substance", @c "volume", @c "area", @c "length" or @c
   * "time"), @c false otherwise.
   *
   * @note The predefined unit identifiers @c "length" and @c "area" were
   * added in Level&nbsp;2 Version&nbsp;1.
   *
   * @copydetails doc_note_static_methods
   */
  static bool isBuiltIn (const std::string& name, unsigned int level);


  /**
   * Predicate to test whether a given string is the name of a valid
   * base unit in SBML (such as @c "gram" or @c "mole").
   *
   * This method exists because prior to SBML Level&nbsp;2 Version&nbsp;3,
   * an enumeration called @c UnitKind was defined by SBML.  This enumeration
   * was removed in SBML Level&nbsp;2 Version&nbsp;3 and its values were
   * folded into the space of values of a type called @c UnitSId.  This method
   * therefore has less significance in SBML Level&nbsp;2 Version&nbsp;3
   * and Level&nbsp;2 Version&nbsp;4, but remains for backward
   * compatibility and support for reading models in older Versions of
   * Level&nbsp;2.
   *
   * @param name a string to be tested
   * 
   * @param level an unsigned int representing the SBML specification
   * Level 
   * 
   * @param version an unsigned int representing the SBML specification
   * Version
   * 
   * @return @c true if name is a valid SBML UnitKind, @c false otherwise
   *
   * @note The allowed unit names differ between SBML Levels&nbsp;1
   * and&nbsp;2 and again slightly between Level&nbsp;2 Versions&nbsp;1
   * and&nbsp;2.
   *
   * @copydetails doc_note_static_methods
   */
  static bool isUnitKind (const std::string& name,
                          unsigned int level, unsigned int version);


  /**
   * Predicate returning @c true if two
   * Unit objects are identical.
   *
   * Two Unit objects are considered to be @em identical if they match in
   * all attributes.  (Contrast this to the method areEquivalent(@if java
   * Unit u1, %Unit u2@endif), which compares Unit objects only with respect
   * to certain attributes.)
   *
   * @param unit1 the first Unit object to compare
   * @param unit2 the second Unit object to compare
   *
   * @return @c true if all the attributes of unit1 are identical
   * to the attributes of unit2, @c false otherwise.
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike areEquivalent() @else Unit::areEquivalent(Unit u1, %Unit u2) @endif@~
   */
  static bool areIdentical(Unit * unit1, Unit * unit2);


  /**
   * Predicate returning @c true if 
   * Unit objects are equivalent.
   *
   * Two Unit objects are considered to be @em equivalent either if (1) both
   * have a "kind" attribute value of @c dimensionless, or (2) their "kind",
   * "exponent" and (for SBML Level&nbsp;2 Version&nbsp;1) "offset"
   * attribute values are equal. (Contrast this to the method
   * areIdentical(@if java Unit, %Unit@endif), which compares Unit objects with respect to all
   * attributes, not just the "kind" and "exponent".)
   *
   * @param unit1 the first Unit object to compare
   * @param unit2 the second Unit object to compare
   *
   * @return @c true if the "kind" and "exponent" attributes of unit1 are
   * identical to the kind and exponent attributes of unit2, @c false
   * otherwise.
   *
   * @copydetails doc_note_static_methods
   * 
   * @see @if clike areIdentical() @else Unit::areIdentical(Unit u1, %Unit u2) @endif@~
   */
  static bool areEquivalent(Unit * unit1, Unit * unit2);


  /**
   * Manipulates the attributes of the Unit to express the unit with the 
   * value of the scale attribute reduced to zero.
   *
   * For example, 1 millimetre can be expressed as a Unit with kind=@c
   * "metre" multiplier=@c "1" scale=@c "-3" exponent=@c "1". It can also be
   * expressed as a Unit with kind=@c "metre"
   * multiplier=<code>"0.001"</code> scale=@c "0" exponent=@c "1".
   *
   * @param unit the Unit object to manipulate.
   *
   * @return integer value indicating success/failure of the function.  The
   * possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike convertToSI() @else Unit::convertToSI(Unit u) @endif@~
   * @see @if clike merge() @else Unit::merge(Unit u1, Unit u2) @endif@~
   */
  static int removeScale(Unit * unit);


  /**
   * Merges two Unit objects with the same "kind" attribute value into a
   * single Unit.
   *
   * For example, the following,
   * @verbatim
 <unit kind="metre" exponent="2"/>
 <unit kind="metre" exponent="1"/>
 @endverbatim
   * would be merged to become
   * @verbatim
 <unit kind="metre" exponent="3"/>
 @endverbatim
   *
   * @param unit1 the first Unit object; the result of the operation is
   * left as a new version of this unit, modified in-place.  Not modified if
   * the two units have different kinds.
   * 
   * @param unit2 the second Unit object to merge with the first
   *
   * @copydetails doc_note_static_methods
   * 
   * @see @if clike convertToSI() @else Unit::convertToSI(Unit u) @endif@~
   * @see @if clike removeScale() @else Unit::removeScale(Unit u) @endif@~
   */
  static void merge(Unit * unit1, Unit * unit2);


  /**
   * Returns a UnitDefinition object containing the given @p unit converted
   * to the appropriate SI unit.
   *
   * This method exists because some units can be expressed in terms of
   * others when the same physical dimension is involved.  For example, one
   * hertz is identical to 1&nbsp;sec<sup>-1</sup>, one litre is equivalent
   * to 1 cubic decametre, and so on.
   *
   * @param unit the Unit object to convert to SI
   *
   * @return a UnitDefinition object containing the SI unit.
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike merge() @else Unit::merge(Unit u1, Unit u2) @endif@~
   */
  static UnitDefinition * convertToSI(const Unit * unit);


  /**
   * Predicate returning @c true if
   * all the required attributes for this Unit object
   * have been set.
   *
   * The required attributes for a Unit object are:
   * @li "kind"
   * @li "exponent" (required in SBML Level&nbsp;3; optional in Level&nbsp;2)
   * @li "multiplier" (required in SBML Level&nbsp;3; optional in Level&nbsp;2)
   * @li "scale" (required in SBML Level&nbsp;3; optional in Level&nbsp;2)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


protected:
  /** @cond doxygenLibsbmlInternal */

  void setExponentUnitChecking (double value); 
                                           
  double getExponentUnitChecking();

  double getExponentUnitChecking() const;

  bool isUnitChecking();

  bool isUnitChecking() const;

  /**
   * Subclasses should override this method to get the list of
   * expected attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);


  /**
   * Subclasses should override this method to read values from the given
   * XMLAttributes set into their specific fields.  Be sure to call your
   * parents implementation of this method as well.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);

  void readL1Attributes (const XMLAttributes& attributes);

  void readL2Attributes (const XMLAttributes& attributes);
  
  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;


  /**
   * Predicate to test whether a given string is the name of a valid
   * base unit in SBML Level 1 (such as @c "gram" or @c "mole")
   *
   * @param name a string to be tested
   * 
   * @return @c true if name is a valid SBML UnitKind, @c false otherwise
   */
  static bool isL1UnitKind (const std::string& name);


  /**
   * Predicate to test whether a given string is the name of a valid base
   * unit in SBML Level&nbsp;2 Version&nbsp;1 (such as @c "gram" or @c
   * "mole")
   *
   * @param name a string to be tested
   * 
   * @return @c true if name is a valid SBML UnitKind, @c false otherwise
   */
  static bool isL2V1UnitKind (const std::string& name);


  /**
   * Predicate to test whether a given string is the name of a valid base
   * unit in SBML Level&nbsp;2 Version&nbsp;2, 3 or 4 (such as @c "gram" or @c
   * "mole")
   *
   * @param name a string to be tested
   * 
   * @return @c true if name is a valid SBML UnitKind, @c false otherwise
   */
  static bool isL2UnitKind (const std::string& name);


  /**
   * Predicate to test whether a given string is the name of a valid base
   * unit in SBML Level&nbsp;3 Version&nbsp;1 (such as @c "gram" or @c
   * "mole")
   *
   * @param name a string to be tested
   * 
   * @return @c true if name is a valid SBML UnitKind, @c false otherwise
   */
  static bool isL3UnitKind (const std::string& name);

  bool isExplicitlySetExponent() const { return mExplicitlySetExponent; };

  bool isExplicitlySetMultiplier() const { return mExplicitlySetMultiplier; };

  bool isExplicitlySetScale() const { return mExplicitlySetScale; };

  bool isExplicitlySetOffset() const { return mExplicitlySetOffset; };

  UnitKind_t  mKind;
  int         mExponent;
  double      mExponentDouble;
  int         mScale;
  double      mMultiplier;
  double      mOffset; 

  bool        mIsSetExponent;
  bool        mIsSetScale;
  bool        mIsSetMultiplier;

  bool        mExplicitlySetExponent;
  bool        mExplicitlySetMultiplier;
  bool        mExplicitlySetScale;
  bool        mExplicitlySetOffset;

  bool        mInternalUnitCheckingFlag;

  /* the validator classes need to be friends to access the 
   * protected constructor that takes no arguments
   */
  friend class Validator;
  friend class ConsistencyValidator;
  friend class IdentifierConsistencyValidator;
  friend class InternalConsistencyValidator;
  friend class L1CompatibilityValidator;
  friend class L2v1CompatibilityValidator;
  friend class L2v2CompatibilityValidator;
  friend class L2v3CompatibilityValidator;
  friend class L2v4CompatibilityValidator;
  friend class L3v1CompatibilityValidator;
  friend class MathMLConsistencyValidator;
  friend class ModelingPracticeValidator;
  friend class OverdeterminedValidator;
  friend class SBOConsistencyValidator;
  friend class UnitConsistencyValidator;
  friend class UnitFormulaFormatter;
  friend class UnitDefinition;


  /** @endcond */
};



class LIBSBML_EXTERN ListOfUnits : public ListOf
{
public:

  /**
   * Creates a new ListOfUnits object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfUnits (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfUnits object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfUnits object to be created.
   */
  ListOfUnits (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfUnits object.
   *
   * @return the (deep) copy of this ListOfUnits object.
   */
  virtual ListOfUnits* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Unit objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_UNIT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfUnits, the XML element name is @c "listOfUnits".
   * 
   * @return the name of this element, i.e., @c "listOfUnits".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Unit from the ListOfUnits.
   *
   * @param n the index number of the Unit to get.
   * 
   * @return the nth Unit in this ListOfUnits.
   *
   * @see size()
   */
  virtual Unit * get(unsigned int n); 


  /**
   * Get a Unit from the ListOfUnits.
   *
   * @param n the index number of the Unit to get.
   * 
   * @return the nth Unit in this ListOfUnits.
   *
   * @see size()
   */
  virtual const Unit * get(unsigned int n) const; 


  /**
   * Removes the nth item from this ListOfUnits items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Unit* remove (unsigned int n);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create a ListOfUnits object corresponding to the next token
   * in the XML input stream.
   * 
   * @return the %SBML object corresponding to next XMLToken in the
   * XMLInputStream, or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new Unit_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Unit_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Unit_t
 *
 * @return a pointer to the newly created Unit_t structure.
 *
 * @note Once a Unit_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Unit_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
Unit_t *
Unit_create (unsigned int level, unsigned int version);


/**
 * Creates a new Unit_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces, a pointer to an SBMLNamespaces_t structure
 * to assign to this Unit_t
 *
 * @return a pointer to the newly created Unit_t structure.
 *
 * @note Once a Unit_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Unit_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
Unit_t *
Unit_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Unit_t structure.
 *
 * @param u the Unit_t structure to be freed.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
void
Unit_free (Unit_t *u);


/**
 * Creates a deep copy of the given Unit_t structure
 * 
 * @param u the Unit_t structure to be copied
 * 
 * @return a (deep) copy of the given Unit_t structure.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
Unit_t *
Unit_clone (const Unit_t* u);


/**
 * Initializes the attributes of this Unit_t (except for "kind") to their
 * default values.
 *
 * The default values are as follows:
 * 
 * - exponent   = 1
 * - scale      = 0
 * - multiplier = 1.0
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
void
Unit_initDefaults (Unit_t *u);


/**
 * Returns a list of XMLNamespaces_t associated with this Unit_t
 * structure.
 *
 * @param u the Unit_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Unit_getNamespaces(Unit_t *u);


/**
 * Returns the "kind" attribute value of the given unit @p u.
 * 
 * @return the value of the "kind" attribute of this Unit_t as a value from
 * the UnitKind_t enumeration.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
UnitKind_t
Unit_getKind (const Unit_t *u);


/**
 * Returns the value of the "exponent" attribute of the given Unit_t
 * structure @p u.
 *
 * @param u a Unit_t structure
 *
 * @return the "exponent" value of this Unit_t structure, as an integer.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_getExponent (const Unit_t *u);


/**
 * Returns the value of the "exponent" attribute of the given Unit_t
 * structure @p u.
 *
 * @param u a Unit_t structure
 *
 * @return the "exponent" value of this Unit_t structure, as a double.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
double
Unit_getExponentAsDouble (const Unit_t *u);


/**
 * Returns the value of the "scale" attribute of the given Unit_t structure
 * @p u.
 *
 * @param u a Unit_t structure
 *
 * @return the "scale" value of this Unit_t, as an integer.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_getScale (const Unit_t *u);


/**
 * Returns the value of the "multiplier" attribute of the given Unit_t
 * structure @p u.
 * 
 * @param u a Unit_t structure
 *
 * @return the "multiplier" value of this Unit_t, as a double
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
double
Unit_getMultiplier (const Unit_t *u);


/**
 * Returns the value of the "offset" attribute of the given Unit_t
 * structure @p u.
 * 
 * @param u a Unit_t structure
 *
 * @return the "offset" value of this Unit_t, as a double
 *
 * @warning The "offset" attribute is only available in SBML Level 2
 * Version 1.  This attribute is not present in SBML Level 2 Version 2 or
 * above.  When producing SBML models using these later specifications,
 * Modelers and software need to account for units with offsets explicitly.
 * The SBML specification document offers a number of suggestions for how
 * to achieve this.  LibSBML functions such as this one related to "offset"
 * are retained for compatibility with earlier versions of SBML Level 2,
 * but their use is strongly discouraged.
 * 
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
double
Unit_getOffset (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c ampere.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "ampere", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isAmpere (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c becquerel.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "becquerel", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isBecquerel (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c candela.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "candela", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isCandela (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c Celsius.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "Celsius", zero (0) otherwise.
 *
 * @warning The predefined unit @c Celsius was removed from the list of
 * predefined units in SBML Level 2 Version 3 at the same time that the
 * "offset" attribute was removed from Unit definitions.  LibSBML functions
 * such as this one related to @c Celsius are retained for compatibility
 * with earlier versions of SBML Level 2, but their use is strongly
 * discouraged.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isCelsius (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c coulomb.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "coulomb", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isCoulomb (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c dimensionless.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "dimensionless", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isDimensionless (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c farad.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "farad", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isFarad (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c gram.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "gram", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isGram (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c gray.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "gray", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isGray (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c henry.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "henry", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isHenry (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c hertz.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "hertz", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isHertz (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c item.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "item", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isItem (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c joule.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "joule", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isJoule (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c katal.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "katal", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isKatal (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c kelvin.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "kelvin", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isKelvin (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c kilogram.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "kilogram", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isKilogram (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c litre or @c liter.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given Unit_t
 * structure is set to @c "litre" or @c "liter", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isLitre (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c lumen.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "lumen", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isLumen (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c lux.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "lux", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isLux (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c metre or @c meter.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given Unit_t
 * structure is set to @c "metre" or @c "meter", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isMetre (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c mole.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "mole", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isMole (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c newton.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "newton", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isNewton (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c ohm.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "ohm", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isOhm (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c pascal.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "pascal", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isPascal (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c radian.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "radian", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isRadian (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c second.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "second", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSecond (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c siemens.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "siemens", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSiemens (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c sievert.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "sievert", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSievert (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c steradian.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "steradian", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSteradian (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c tesla.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "tesla", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isTesla (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c volt.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "volt", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isVolt (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c watt.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "watt", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isWatt (const Unit_t *u);


/**
 * Predicate for testing whether the given Unit_t structure represents a
 * unit of the kind @c weber.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set to @c "weber", zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isWeber (const Unit_t *u);


/**
 * Predicate to test whether the "kind" attribute of the given Unit_t
 * structure @p u is set.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "kind" attribute of the given
 * Unit_t structure is set, zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSetKind (const Unit_t *u);


/**
 * Predicate to test whether the "exponent" attribute of the given Unit_t
 * structure @p u is set.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "exponent" attribute of the given
 * Unit_t structure is set, zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSetExponent (const Unit_t *u);


/**
 * Predicate to test whether the "multiplier" attribute of the given Unit_t
 * structure @p u is set.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "multiplier" attribute of the given
 * Unit_t structure is set, zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSetMultiplier (const Unit_t *u);


/**
 * Predicate to test whether the "scale" attribute of the given Unit_t
 * structure @p u is set.
 *
 * @param u the Unit_t structure to query
 * 
 * @return nonzero (for true) if the "scale" attribute of the given
 * Unit_t structure is set, zero (0) otherwise.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isSetScale (const Unit_t *u);


/**
 * Sets the kind of the given Unit_t structure @p u to the given
 * UnitKind_t value.
 *
 * @param u the Unit_t structure whose value is to be set
 * @param kind a value from the UnitKind_t enumeration 
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setKind (Unit_t *u, UnitKind_t kind);


/**
 * Sets the "exponent" attribute value of the given Unit_t structure @p u.
 *
 * @param u the Unit_t structure whose value is to be set
 * @param value the integer to which the attribute "exponent" should be set
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setExponent (Unit_t *u, int value);


/**
 * Sets the "exponent" attribute value of the given Unit_t structure @p u.
 *
 * @param u the Unit_t structure whose value is to be set
 * @param value the double to which the attribute "exponent" should be set
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setExponentAsDouble (Unit_t *u, double value);


/**
 * Sets the "scale" attribute value of the given Unit_t structure @p u.
 *
 * @param u the Unit_t structure whose value is to be set
 * @param value the integer to which the attribute "scale" should be set
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setScale (Unit_t *u, int value);


/**
 * Sets the "multiplier" attribute value of the given Unit_t structure @p u.
 *
 * @param u the Unit_t structure whose value is to be set
 * @param value the integer to which the attribute "multiplier" should be set
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setMultiplier (Unit_t *u, double value);


/**
 * Sets the "offset" attribute value of the given Unit_t structure @p u.
 * 
 * @param u the Unit_t structure whose value is to be set
 * @param value the integer to which the attribute "offset" should be set
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @warning The "offset" attribute is only available in SBML Level 2
 * Version 1.  This attribute is not present in SBML Level 2 Version 2 or
 * above.  When producing SBML models using these later specifications,
 * Modelers and software need to account for units with offsets explicitly.
 * The SBML specification document offers a number of suggestions for how
 * to achieve this.  LibSBML functions such as this one related to "offset"
 * are retained for compatibility with earlier versions of SBML Level 2,
 * but their use is strongly discouraged.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_setOffset (Unit_t *u, double value);


/**
 * Predicate returning @c true or @c false depending on whether
 * all the required attributes for this Unit_t structure
 * have been set.
 *
 * The required attributes for a Unit_t structure are:
 * @li kind
 * @li exponent (L3 on)
 * @li multiplier (L3 on)
 * @li scale (L3 on)
 *
 * @return a boolean value indicating whether all the required
 * elements for this structure have been defined.
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_hasRequiredAttributes(Unit_t *u);


/**
 * Predicate to test whether a given string is the name of a built-in SBML
 * unit, depending on the SBML level, since new units were added between
 * levels 2 and 3.
 *
 * @param name a string to be tested against the built-in unit names
 * @param level the level of SBML one is checking. 
 *
 * @return nonzero (for true) if @p name is one of the five SBML
 * built-in Unit names (@c "substance", @c "volume, @c "area", @c "length"
 * or @c "time"), zero (0) otherwise
 *
 * @note: @c "length" and @c "area" were added in Level 2 Version 1
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_isBuiltIn (const char *name, unsigned int level);

/** 
 * Predicate returning @c true (non-zero) if two
 * Unit_t structures are identical.
 *
 * Two Unit_t structures are considered to be @em identical if they match in
 * all attributes.  (Contrast this to the method areEquivalent(), which 
 * compares Unit_t structures only with respect
 * to certain attributes.)
 *
 * @param unit1 the first Unit_t structure to compare
 * @param unit2 the second Unit_t structure to compare
 *
 * @return @c true if all the attributes of unit1 are identical
 * to the attributes of unit2, @c false otherwise.
 *
 * @see Unit_areEquivalent()
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int 
Unit_areIdentical(Unit_t * unit1, Unit_t * unit2);

/** 
 * Predicate returning @c true if 
 * Unit_t structures are equivalent.
 *
 * Two Unit_t structures are considered to be @em equivalent either if (1) both
 * have a "kind" attribute value of @c dimensionless, or (2) their "kind",
 * "exponent" and (for SBML Level&nbsp;2 Version&nbsp;1) "offset"
 * attribute values are equal. (Contrast this to the method
 * areIdentical(), which compares Unit_t structures with respect to all
 * attributes, not just the "kind" and "exponent".)
 *
 * @param unit1 the first Unit_t structure to compare
 * @param unit2 the second Unit_t structure to compare
 *
 * @return @c true if the "kind" and "exponent" attributes of unit1 are
 * identical to the kind and exponent attributes of unit2, @c false
 * otherwise.
 * 
 * @see Unit_areIdentical()
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int
Unit_areEquivalent(Unit_t * unit1, Unit_t * unit2);

/** 
 * Manipulates the attributes of the Unit_t to express the unit with the 
 * value of the scale attribute reduced to zero.
 *
 * For example, 1 millimetre can be expressed as a Unit_t with kind=@c
 * "metre" multiplier=@c "1" scale=@c "-3" exponent=@c "1". It can also be
 * expressed as a Unit_t with kind=@c "metre"
 * multiplier=<code>"0.001"</code> scale=@c "0" exponent=@c "1".
 *
 * @param unit the Unit_t structure to manipulate.
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @see Unit_convertToSI()
 * @see Unit_merge()
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
int 
Unit_removeScale(Unit_t * unit);

/** 
 * Merges two Unit_t structures with the same "kind" attribute value into a
 * single Unit.
 * 
 * For example, the following,
 * @verbatim
 <unit kind="metre" exponent="2"/>
 <unit kind="metre" exponent="1"/>
 @endverbatim
 * would be merged to become
 * @verbatim
 <unit kind="metre" exponent="3"/>
 @endverbatim
 *
 * @param unit1 the first Unit_t structure; the result of the operation is
 * left as a new version of this unit, modified in-place.  Not modified if
 * the two units have different kinds.
 * 
 * @param unit2 the second Unit_t structure to merge with the first
 * 
 * @see Unit_convertToSI()
 * @see Unit_removeScale()
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
void 
Unit_merge(Unit_t * unit1, Unit_t * unit2);

/**
 * Returns a UnitDefinition_t structure containing the given @p unit converted
 * to the appropriate SI unit.
 *
 * This method exists because some units can be expressed in terms of
 * others when the same physical dimension is involved.  For example, one
 * hertz is identical to 1&nbsp;sec<sup>-1</sup>, one litre is equivalent
 * to 1 cubic decametre, and so on.
 *
 * @param unit the Unit_t structure to convert to SI
 *
 * @return a UnitDefinition_t structure containing the SI unit.
 *
 * @see Unit_merge()
 *
 * @memberof Unit_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
Unit_convertToSI(Unit_t * unit);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG  */
#endif  /* Unit_h */

