/**
 * @file    Compartment.h
 * @brief   Definitions of Compartment and ListOfCompartments
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
 * @class Compartment
 * @sbmlbrief{core} An SBML compartment, where species are located.
 *
 * A compartment in SBML represents a bounded space in which species are
 * located.  Compartments do not necessarily have to correspond to actual
 * structures inside or outside of a biological cell.
 *
 * It is important to note that although compartments are optional in the
 * overall definition of Model, every species in an SBML model must be
 * located in a compartment.  This in turn means that if a model defines
 * any species, the model must also define at least one compartment.  The
 * reason is simply that species represent physical things, and therefore
 * must exist @em somewhere.  Compartments represent the @em somewhere.
 *
 * Compartment has one required attribute, "id", to give the compartment a
 * unique identifier by which other parts of an SBML model definition can
 * refer to it.  A compartment can also have an optional "name" attribute
 * of type @c string.  Identifiers and names must be used according to the
 * guidelines described in the SBML specifications.
 *
 * Compartment also has an optional attribute "spatialDimensions" that is
 * used to indicate the number of spatial dimensions possessed by the
 * compartment.  Most modeling scenarios involve compartments with integer
 * values of "spatialDimensions" of @c 3 (i.e., a three-dimensional
 * compartment, which is to say, a volume), or 2 (a two-dimensional
 * compartment, a surface), or @c 1 (a one-dimensional compartment, a
 * line).  In SBML Level&nbsp;3, the type of this attribute is @c double,
 * there are no restrictions on the permitted values of the
 * "spatialDimensions" attribute, and there are no default values.  In SBML
 * Level&nbsp;2, the value must be a positive @c integer, and the default
 * value is @c 3; the permissible values in SBML Level&nbsp;2 are @c 3, @c
 * 2, @c 1, and @c 0 (for a point).
 *
 * Another optional attribute on Compartment is "size", representing the @em
 * initial total size of that compartment in the model.  The "size" attribute
 * must be a floating-point value and may represent a volume (if the
 * compartment is a three-dimensional one), or an area (if the compartment is
 * two-dimensional), or a length (if the compartment is one-dimensional).
 * There is no default value of compartment size in SBML Level&nbsp;2 or
 * Level&nbsp;3.  In particular, a missing "size" value <em>does not imply
 * that the compartment size is 1</em>.  (This is unlike the definition of
 * compartment "volume" in SBML Level&nbsp;1.)  When the compartment's
 * "spatialDimensions" attribute does not have a value of @c 0, a missing
 * value of "size" for a given compartment signifies that the value either is
 * unknown, or to be obtained from an external source, or determined by an
 * InitialAssignment, AssignmentRule, AlgebraicRule or RateRule
 * @if conly structure @else object@endif@~ elsewhere in the model.  In SBML
 * Level&nbsp;2, there are additional special requirements on the values of
 * "size"; we discuss them in a <a href="#comp-l2">separate section
 * below</a>.
 *
 * The units associated with a compartment's "size" attribute value may be
 * set using the optional attribute "units".  The rules for setting and
 * using compartment size units differ between SBML Level&nbsp;2 and
 * Level&nbsp;3, and are discussed separately below.
 *
 * Finally, the optional Compartment attribute named "constant" is used to
 * indicate whether the compartment's size stays constant after simulation
 * begins.  A value of @c true indicates the compartment's "size" cannot be
 * changed by any other construct except InitialAssignment; a value of @c
 * false indicates the compartment's "size" can be changed by other
 * constructs in SBML.  In SBML Level&nbsp;2, there is an additional
 * explicit restriction that if "spatialDimensions"=@c "0", the value
 * cannot be changed by InitialAssignment either.  Further, in
 * Level&nbsp;2, "constant" has a default value of @c true.  In SBML
 * Level&nbsp;3, there is no default value for the "constant" attribute.
 *
 *
 * @section comp-l2 Additional considerations in SBML Level&nbsp;2
 *
 * In SBML Level&nbsp;2, the default units of compartment size, and the kinds
 * of units allowed as values of the attribute "units", interact with the
 * number of spatial dimensions of the compartment.  The value of the "units"
 * attribute of a Compartment @if conly structure @else object@endif@~ must
 * be one of the base units (see Unit), or the predefined unit identifiers @c
 * volume, @c area, @c length or @c dimensionless, or a new unit defined by a
 * UnitDefinition @if conly structure @else object@endif@~ in the enclosing
 * Model, subject to the restrictions detailed in the following table:
 *
 * <table border="0" class="centered text-table width80 normal-font alt-row-colors"
 *        style="padding-bottom: 0.5em">
 * <caption class="top-caption">Restrictions on values permitted for
 * compartment <code>size</code> and <code>units</code> attributes.</caption>
 *  <tr>
 *      <th align="left" valign="bottom">
 *        Value of<br><code>spatialDimensions</code>
 *      </th>
 *      <th align="left" valign="bottom">
 *        <code>size</code><br>allowed?
 *      </th>
 *      <th align="left" valign="bottom">
 *        <code>units</code><br>allowed?
 *      </th>
 *      <th align="left" valign="bottom">
 * 	  Allowable kinds of units
 *      </th>
 *      <th align="left" valign="bottom">
 * 	  Default value of attribute <code>units</code>
 *      </th>
 *  </tr>
 *  <tr>
 *      <td><code>3</code></td>
 *      <td>yes</td>
 *      <td>yes</td>
 *      <td>units of volume, or <code>dimensionless</code></td>
 *      <td><code>volume</code></td>
 *  </tr>
 *  <tr>
 *      <td><code>2</code></td>
 *      <td>yes</td>
 *      <td>yes</td>
 *      <td>units of area, or <code>dimensionless</code></td>
 *      <td><code>area</code></td>
 *  </tr>
 *  <tr>
 *      <td><code>1</code></td>
 *      <td>yes</td>
 *      <td>yes</td>
 *      <td>units of length, or <code>dimensionless</code></td>
 *      <td><code>length</code></td>
 *  </tr>
 *  <tr>
 *      <td><code>0</code></td>
 *      <td>no</td>
 *      <td>no</td>
 *      <td>(no units allowed)</td>
 *      <td></td>
 *  </tr>
 *  </tr>
 * </table>
 *
 * In SBML Level&nbsp;2, the units of the compartment size, as defined by the
 * "units" attribute or (if "units" is not set) the default value listed in
 * the table above, are used in the following ways when the compartment has
 * a "spatialDimensions" value greater than @c 0:
 * <ul>
 * <li> The value of the "units" attribute is used as the units of the
 * compartment identifier when the identifier appears as a numerical
 * quantity in a mathematical formula expressed in MathML.
 *
 * <li> The @c math element of an AssignmentRule or InitialAssignment
 * referring to this compartment must have identical units.
 *
 * <li> In RateRule objects that set the rate of change of the compartment's
 * size, the units of the rule's @c math element must be identical to the
 * compartment's "units" attribute divided by the default @em time units.
 * (In other words, the units for the rate of change of compartment size
 * are <em>compartment size</em>/<em>time</em> units.
 *
 * <li> When a Species is to be treated in terms of concentrations or
 * density, the units of the spatial size portion of the concentration
 * value (i.e., the denominator in the units formula @em substance/@em
 * size) are those indicated by the value of the "units" attribute on the
 * compartment in which the species is located.
 * </ul>
 *
 * Compartments with "spatialDimensions"=@c 0 require special treatment in
 * this framework.  As implied above, the "size" attribute must not have a
 * value on an SBML Level&nbsp;2 Compartment
 * @if conly structure @else object@endif@~ if the "spatialDimensions"
 * attribute has a value of @c 0.  An additional related restriction is that
 * the "constant" attribute must default to or be set to @c true if the value
 * of the "spatialDimensions" attribute is @c 0, because a zero-dimensional
 * compartment cannot ever have a size.
 *
 * If a compartment has no size or dimensional units, how should such a
 * compartment's identifier be interpreted when it appears in mathematical
 * formulas?  The answer is that such a compartment's identifier should not
 * appear in mathematical formulas in the first place---it has no
 * value, and its value cannot change.  Note also that a zero-dimensional
 * compartment is a point, and species located at points can only be
 * described in terms of amounts, not spatially-dependent measures such as
 * concentration.  Since SBML KineticLaw formulas are already in terms of
 * @em substance/@em time and not (say) @em concentration/@em time, volume
 * or other factors in principle are not needed for species located in
 * zero-dimensional compartments.
 *
 * Finally, in SBML Level&nbsp;2 Versions 2&ndash;4, each compartment in a
 * model may optionally be designated as belonging to a particular
 * compartment @em type.  The optional attribute "compartmentType" is used
 * identify the compartment type represented by the Compartment structure.
 * The "compartmentType" attribute's value must be the identifier of a
 * CompartmentType instance defined in the model.  If the "compartmentType"
 * attribute is not present on a particular compartment definition, a
 * unique virtual compartment type is assumed for that compartment, and no
 * other compartment can belong to that compartment type.  The values of
 * "compartmentType" attributes on compartments have no effect on the
 * numerical interpretation of a model.  Simulators and other numerical
 * analysis software may ignore "compartmentType" attributes.  The
 * "compartmentType" attribute and the CompartmentType
 * @if conly structures @else class of objects@endif@~ are
 * not present in SBML Level&nbsp;3 Core nor in SBML Level&nbsp;1.
 *
 *
 * @section comp-l3 Additional considerations in SBML Level&nbsp;3
 *
 * One difference between SBML Level&nbsp;3 and lower Levels of SBML is
 * that there are no restrictions on the permissible values of the
 * "spatialDimensions" attribute, and there is no default value defined for
 * the attribute.  The value of "spatialDimensions" does not have to be an
 * integer, either; this is to allow for the possibility of representing
 * structures with fractal dimensions.
 *
 * The number of spatial dimensions possessed by a compartment cannot enter
 * into mathematical formulas, and therefore cannot directly alter the
 * numerical interpretation of a model.  However, the value of
 * "spatialDimensions" @em does affect the interpretation of the units
 * associated with a compartment's size.  Specifically, the value of
 * "spatialDimensions" is used to select among the Model attributes
 * "volumeUnits", "areaUnits" and "lengthUnits" when a Compartment
 * @if conly object @else structure@endif@~ does not define a value for its
 * "units" attribute.
 *
 * The "units" attribute may be left unspecified for a given compartment in a
 * model; in that case, the compartment inherits the unit of measurement
 * specified by one of the attributes on the enclosing Model
 * @if conly structure @else object@endif@~ instance.  The applicable
 * attribute on Model depends on the value of the compartment's
 * "spatialDimensions" attribute; the relationship is shown in the table
 * below.  If the Model @if conly structure @else object@endif@~ does not
 * define the relevant attribute ("volumeUnits", "areaUnits" or
 * "lengthUnits") for a given "spatialDimensions" value, the unit associated
 * with that Compartment @if conly structure @else object@endif's size is
 * undefined.  If @em both "spatialDimensions" and "units" are left unset on
 * a given Compartment @if conly structure @else object@endif@~ instance,
 * then no unit can be chosen from among the Model's "volumeUnits",
 * "areaUnits" or "lengthUnits" attributes (even if the Model instance
 * provides values for those attributes), because there is no basis to select
 * between them and there is no default value of "spatialDimensions".
 * Leaving the units of compartments' sizes undefined in an SBML model does
 * not render the model invalid; however, as a matter of best practice, we
 * strongly recommend that all models specify the units of measurement for
 * all compartment sizes.
 *
 * <table border="0" class="centered text-table width80 normal-font alt-row-colors"
 *        style="padding-bottom: 0.5em">
 * <caption class="top-caption">Interpretation of the Compartment "units" attribute.</caption>
 *  <tr>
 *      <th align="left" valign="bottom">
 *        Value of attribute<br>"spatialDimensions"
 *      </th>
 *      <th align="left" valign="bottom">
 *        Attribute of Model used<br>for inheriting the unit
 *      </th>
 *      <th align="left" valign="bottom">
 *        Recommended candidate units
 *      </th>
 *  </tr>
 *  <tr>
 *      <td><code>3</code></td>
 *      <td>&quot;volumeUnits&quot;</td>
 *      <td>units of volume, or <code>dimensionless</code></td>
 *  </tr>
 *  <tr>
 *      <td><code>2</code></td>
 *      <td>&quot;areaUnits&quot;</td>
 *      <td>units of area, or <code>dimensionless</code></td>
 *  </tr>
 *  <tr>
 *      <td><code>1</code></td>
 *      <td>&quot;lengthUnits&quot;</td>
 *      <td>units of length, or <code>dimensionless</code></td>
 *  </tr>
 *  <tr>
 *      <td><em>other</em></td>
 *      <td><em>no units inherited</em></td>
 *      <td><em>no specific recommendations</em></td>
 *  </tr>
 *  </tr>
 * </table>
 *
 * The unit of measurement associated with a compartment's size, as defined
 * by the "units" attribute or (if "units" is not set) the inherited value
 * from Model according to the table above, is used in the following ways:
 *
 * <ul>
 *
 * <li> When the identifier of the compartment appears as a numerical
 * quantity in a mathematical formula expressed in MathML, it represents
 * the size of the compartment, and the unit associated with the size is
 * the value of the "units" attribute.
 *
 * <li> When a Species is to be treated in terms of concentrations or
 * density, the unit associated with the spatial size portion of the
 * concentration value (i.e., the denominator in the formula
 * <em>amount</em>/<em>size</em>) is specified by the value of the "units"
 * attribute on the compartment in which the species is located.
 *
 * <li> The "math" elements of AssignmentRule, InitialAssignment and
 * EventAssignment @if conly structures @else objects@endif@~ setting the
 * value of the compartment size should all have the same units as the unit
 * associated with the compartment's size.
 *
 * <li> In a RateRule @if conly structure @else object@endif@~ that defines a
 * rate of change for a compartment's size, the unit of the rule's "math"
 * element should be identical to the compartment's "units" attribute divided
 * by the model-wide unit of <em>time</em>.  (In other words, {<em>unit of
 * compartment size</em>}/{<em>unit of time</em>}.)
 *
 * </ul>
 *
 *
 * @section comp-other Other aspects of Compartment
 *
 * In SBML Level&nbsp;1 and Level&nbsp;2, Compartment has an optional
 * attribute named "outside", whose value can be the identifier of another
 * Compartment @if conly structure @else object@endif@~ defined in the
 * enclosing Model @if conly structure @else object@endif@~.  Doing so means
 * that the other compartment contains it or is outside of it.  This enables
 * the representation of simple topological relationships between
 * compartments, for those simulation systems that can make use of the
 * information (e.g., for drawing simple diagrams of compartments).  It is
 * worth noting that in SBML, there is no relationship between compartment
 * sizes when compartment positioning is expressed using the "outside"
 * attribute.  The size of a given compartment does not in any sense include
 * the sizes of other compartments having it as the value of their "outside"
 * attributes.  In other words, if a compartment @em B has the identifier of
 * compartment @em A as its "outside" attribute value, the size of @em A does
 * not include the size of @em B.  The compartment sizes are separate.
 *
 * In Level&nbsp;2, there are two restrictions on the "outside" attribute.
 * First, because a compartment with "spatialDimensions" of @c 0 has no
 * size, such a compartment cannot act as the container of any other
 * compartment @em except compartments that @em also have
 * "spatialDimensions" values of @c 0.  Second, the directed graph formed
 * by representing Compartment structures as vertexes and the "outside"
 * attribute values as edges must be acyclic.  The latter condition is
 * imposed to prevent a compartment from being contained inside itself.  In
 * the absence of a value for "outside", compartment definitions in SBML
 * Level&nbsp;2 do not have any implied spatial relationships between each
 * other.
 *
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfCompartments
 * @sbmlbrief{core} A list of Compartment objects.
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
 * @class doc_compartment_units
 *
 * @par
 * Compartments in SBML have an attribute ("units") for declaring the
 * units of measurement intended for the value of the compartment's size.  In
 * the absence of a value given for this attribute, the units are inherited
 * from values either defined on the enclosing Model (in SBML Level&nbsp;3)
 * or in defaults (in SBML Level&nbsp;2).  This method returns a
 * @if conly UnitDefinition_t structure @else UnitDefinition object@endif@~
 * based on how this compartment's units are interpreted according to the
 * relevant SBML guidelines, or it returns @c NULL if no units have been
 * declared and no defaults are defined by the relevant SBML specification.
 *
 * Note that unit declarations for
 * @if conly Compartment_t structures @else Compartment objects @endif@~
 * are specified in terms of the @em identifier of a unit,
 * but @em this method returns @if conly a structure @else an object @endif,
 * not a unit identifier.  It does this by constructing an appropriate
 * @if conly UnitDefinition_t structure @else UnitDefinition object@endif.  For
 * SBML Level&nbsp;2 models, it will do this even when the value of the
 * "units" attribute is one of the special SBML Level&nbsp;2 unit identifiers
 * @c "substance", @c "volume", @c "area", @c "length" or @c "time".  Callers
 * may find this useful in conjunction with the helper methods provided by
 * the @if conly UnitDefinition_t structure @else UnitDefinition
 * class@endif@~ for comparing different UnitDefinition objects.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_compartment_both_size_and_volume
 *
 * @par
 * In SBML Level&nbsp;1, compartments are always three-dimensional
 * constructs and only have volumes, whereas in SBML Level&nbsp;2 and higher,
 * compartments may be other than three-dimensional, and therefore the
 * "volume" attribute is named "size" in Level&nbsp;2 and above.  LibSBML
 * provides both @if conly Compartment_getSize() and Compartment_getVolume()
 * @else Compartment::getSize() and Compartment::getVolume()@endif@~
 * for easier support of different SBML Levels.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_compartment_volume
 *
 * @note The attribute "volume" only exists by that name in SBML
 * Level&nbsp;1.  In Level&nbsp;2 and above, the equivalent attribute is
 * named "size".  In SBML Level&nbsp;1, a compartment's volume has a default
 * value (@c 1.0) and therefore methods such as
 * @if conly Compartment_isSetVolume() @else Compartment::isSetVolume()@endif@~
 * will always return @c true for a Level&nbsp;1 model.  In Level&nbsp;2, a
 * compartment's size (the equivalent of SBML Level&nbsp;1's "volume") is
 * optional and has no default value, and therefore may or may not be set.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_spatial_dimensions_as_double
 *
 * @note In SBML Level&nbsp;3, the data type of the "spatialDimensions"
 * attribute is @c double, whereas in Level&nbsp;2, it is @c integer.  To
 * avoid backward compatibility issues, libSBML provides two separate methods
 * for obtaining the value as either an integer or a type @c double, for
 * models where it is relevant.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_unit_analysis_depends_on_model
 *
 * @note The libSBML system for unit analysis depends on the model as a
 * whole.  In cases where the
 * @if conly Compartment_t structure @else Compartment object@endif@~ has not
 * yet been added to a model, or the model itself is incomplete, unit
 * analysis is not possible, and consequently this method will return @c
 * NULL.
 */

#ifndef Compartment_h
#define Compartment_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/annotation/RDFAnnotation.h>
#endif
#include <sbml/common/operationReturnValues.h>

#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN Compartment : public SBase
{
public:
  /**
   * Creates a new Compartment object using the given SBML @p level and @p
   * version values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Compartment
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Compartment
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Compartment (unsigned int level, unsigned int version);


  /**
   * Creates a new Compartment object using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces
   *
   * It is worth emphasizing that although this constructor does not take an
   * identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a Compartment object is required to have a
   * value.  Thus, callers are cautioned to assign a value after calling this
   * constructor.  Setting the identifier can be accomplished using the
   * method @if java Compartment::setId(String id)@else setId()@endif.
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
  Compartment (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Compartment.
   */
  virtual ~Compartment ();


  /**
   * Copy constructor; creates a copy of a Compartment.
   *
   * @param orig the Compartment instance to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Compartment(const Compartment& orig);


  /**
   * Assignment operator for Compartment.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Compartment& operator=(const Compartment& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Compartment.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next Compartment object in the
   * list of compartments within which this Compartment object is embedded (i.e.,
   * the ListOfCompartments in the parent Model).
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Compartment object.
   *
   * @return the (deep) copy of this Compartment object.
   */
  virtual Compartment* clone () const;


  /**
   * Initializes the fields of this Compartment object to "typical" default
   * values.
   *
   * The SBML Compartment component has slightly different aspects and
   * default attribute values in different SBML Levels and Versions.
   * This method sets the values to certain common defaults, based
   * mostly on what they are in SBML Level&nbsp;2.  Specifically:
   *
   * @li Sets attribute "spatialDimensions" to @c 3
   * @li Sets attribute "constant" to @c true
   * @li (Applies to Level&nbsp;1 models only) Sets attribute "volume" to @c 1.0
   * @li (Applies to Level&nbsp;3 models only) Sets attribute "units" to @c litre
   */
  void initDefaults ();


  /**
   * Returns the value of the "id" attribute of this Compartment object.
   *
   * @return the identifier of this Compartment object.
   *
   * @see getName()
   * @see setId(@if java String@endif)
   * @see unsetId()
   * @see isSetId()
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this Compartment object.
   *
   * @return the name of this Compartment object.
   *
   * @see getId()
   * @see isSetName()
   * @see setName(@if java String@endif)
   * @see unsetName()
   */
  virtual const std::string& getName () const;


  /**
   * Get the value of the "compartmentType" attribute of this Compartment
   * object.
   *
   * @return the value of the "compartmentType" attribute of this
   * Compartment object as a string.
   *
   * @note The "compartmentType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   *
   * @see isSetCompartmentType()
   * @see setCompartmentType(@if java String@endif)
   * @see unsetCompartmentType()
   */
  const std::string& getCompartmentType () const;


  /**
   * Get the number of spatial dimensions of this Compartment object.
   *
   * @return the value of the "spatialDimensions" attribute of this
   * Compartment object as an unsigned integer
   *
   * @copydetails doc_note_spatial_dimensions_as_double
   *
   * @see getSpatialDimensionsAsDouble()
   * @see setSpatialDimensions(@if java unsigned int@endif)
   * @see isSetSpatialDimensions()
   * @see unsetSpatialDimensions()
   */
  unsigned int getSpatialDimensions () const;


  /**
   * Get the number of spatial dimensions of this Compartment object,
   * as a double.
   *
   * @return the value of the "spatialDimensions" attribute of this
   * Compartment object as a double, or @c NaN if this model is not in SBML
   * Level&nbsp;3 format.
   *
   * @copydetails doc_note_spatial_dimensions_as_double
   *
   * @see getSpatialDimensions()
   * @see setSpatialDimensions(@if java unsigned int@endif)
   * @see isSetSpatialDimensions()
   * @see unsetSpatialDimensions()
   */
  double getSpatialDimensionsAsDouble () const;


  /**
   * Get the size of this Compartment object.
   *
   * @copydetails doc_compartment_both_size_and_volume
   *
   * @return the value of the "size" attribute ("volume" in Level&nbsp;1) of
   * this Compartment object as a floating-point number.
   *
   * @note This method is identical to
   * @if java Compartment::getVolume()@else getVolume()@endif.
   *
   * @see getVolume()
   * @see isSetSize()
   * @see setSize(@if java double@endif)
   * @see unsetSize()
   */
  double getSize () const;


  /**
   * Get the volume of this Compartment object.
   *
   * @copydetails doc_compartment_both_size_and_volume
   *
   * @return the value of the "volume" attribute ("size" in Level&nbsp;2) of
   * this Compartment object, as a floating-point number.
   *
   * @copydetails doc_note_compartment_volume
   *
   * @note This method is identical to
   * @if java Compartment::getSize()@else getSize()@endif.
   *
   * @see getSize()
   * @see isSetVolume()
   * @see setVolume(@if java double@endif)
   * @see unsetVolume()
   */
  double getVolume () const;


  /**
   * Get the units of this Compartment object's size.
   *
   * The value of an SBML compartment's "units" attribute establishes the
   * unit of measurement associated with the compartment's size.
   *
   * @return the value of the "units" attribute of this Compartment object,
   * as a string.  An empty string indicates that no units have been assigned
   * to the value of the size.
   *
   * @copydetails doc_note_unassigned_unit_are_not_a_default
   *
   * @see isSetUnits()
   * @see setUnits(@if java String@endif)
   * @see unsetUnits()
   */
  const std::string& getUnits () const;


  /**
   * Get the identifier, if any, of the Compartment object that is designated
   * as being outside of @em this one.
   *
   * @return the value of the "outside" attribute of this Compartment object.
   *
   * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
   * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
   * Core.
   *
   * @see isSetOutside()
   * @see setOutside(@if java String@endif)
   * @see unsetOutside()
   */
  const std::string& getOutside () const;


  /**
   * Get the value of the "constant" attribute of this Compartment object.
   *
   * @return @c true if this Compartment object's size is flagged as being
   * constant, @c false otherwise.
   *
   * @see isSetConstant()
   * @see setConstant(@if java bool@endif)
   */
  bool getConstant () const;


  /**
   * Predicate returning @c true if this Compartment object's "id" attribute
   * is set.
   *
   * @return @c true if the "id" attribute of this Compartment object is
   * set, @c false otherwise.
   *
   * @see getId()
   * @see unsetId()
   * @see setId(@if java String@endif)
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this Compartment object's "name"
   * attribute is set.
   *
   * @return @c true if the "name" attribute of this Compartment object is
   * set, @c false otherwise.
   *
   * @see getName()
   * @see setName(@if java String@endif)
   * @see unsetName()
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if this Compartment object's
   * "compartmentType" attribute is set.
   *
   * @return @c true if the "compartmentType" attribute of this Compartment
   * is set, @c false otherwise.
   *
   * @note The "compartmentType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   *
   * @see setCompartmentType(@if java String@endif)
   * @see getCompartmentType()
   * @see unsetCompartmentType()
   */
  bool isSetCompartmentType () const;


  /**
   * Predicate returning @c true if this Compartment object's "size"
   * attribute is set.
   *
   * This method is similar but not identical to
   * @if java Compartment::isSetVolume()@else isSetVolume()@endif.  The latter
   * should be used in the context of SBML Level&nbsp;1 models instead of
   * @if java Compartment::isSetSize()@else isSetSize()@endif@~
   * because @if java Compartment::isSetVolume()@else isSetVolume()@endif@~
   * performs extra processing to take into account the difference in
   * default values between SBML Levels&nbsp;1 and&nbsp;2.
   *
   * @return @c true if the "size" attribute ("volume" in Level&nbsp;2) of
   * this Compartment object is set, @c false otherwise.
   *
   * @see isSetVolume()
   * @see setSize(@if java double@endif)
   * @see getSize()
   * @see unsetSize()
   */
  bool isSetSize () const;


  /**
   * Predicate returning @c true if this Compartment object's "volume"
   * attribute is set.
   *
   * This method is similar but not identical to
   * @if java Compartment::isSetSize()@else isSetSize()@endif.  The latter
   * should not be used in the context of SBML Level&nbsp;1 models because the
   * present method performs extra processing to take into account
   * the difference in default values between SBML Levels&nbsp;1 and&nbsp;2.
   *
   * @return @c true if the "volume" attribute ("size" in Level&nbsp;2 and
   * above) of this Compartment object is set, @c false otherwise.
   *
   * @copydetails doc_note_compartment_volume
   *
   * @see isSetSize()
   * @see getVolume()
   * @see setVolume(@if java double@endif)
   * @see unsetVolume()
   */
  bool isSetVolume () const;


  /**
   * Predicate returning @c true if this Compartment object's "units"
   * attribute is set.
   *
   * @return @c true if the "units" attribute of this Compartment object is
   * set, @c false otherwise.
   *
   * @copydetails doc_note_unassigned_unit_are_not_a_default
   *
   * @see setUnits(@if java String@endif)
   * @see getUnits()
   * @see unsetUnits()
   */
  bool isSetUnits () const;


  /**
   * Predicate returning @c true if this Compartment object's "outside"
   * attribute is set.
   *
   * @return @c true if the "outside" attribute of this Compartment object is
   * set, @c false otherwise.
   *
   * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
   * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
   * Core.
   *
   * @see getOutside()
   * @see setOutside(@if java String@endif)
   * @see unsetOutside()
   */
  bool isSetOutside () const;


  /**
   * Predicate returning @c true if this Compartment object's
   * "spatialDimensions" attribute is set.
   *
   * @return @c true if the "spatialDimensions" attribute of this
   * Compartment object is set, @c false otherwise.
   *
   * @see getSpatialDimensions()
   * @see setSpatialDimensions(@if java unsigned int@endif)
   * @see unsetSpatialDimensions()
   */
  bool isSetSpatialDimensions () const;


  /**
   * Predicate returning @c true if this Compartment object's "constant"
   * attribute is set.
   *
   * @return @c true if the "constant" attribute of this Compartment object is
   * set, @c false otherwise.
   *
   * @see getConstant()
   * @see setConstant(@if java bool@endif)
   */
  bool isSetConstant () const;


  /**
   * Sets the value of the "id" attribute of this Compartment object.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this Compartment object. If
   * the string is @c NULL, this method will return
   * @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see getId()
   * @see unsetId()
   * @see isSetId()
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this Compartment object.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the Compartment object. If the string is @c
   * NULL, this method will return
   * @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see getName()
   * @see isSetName()
   * @see unsetName()
   */
  virtual int setName (const std::string& name);


  /**
   * Sets the "compartmentType" attribute of this Compartment object.
   *
   * @param sid the identifier of a CompartmentType object defined elsewhere
   * in this Model. If the string is @c NULL, this method will return
   * @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The "compartmentType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   *
   * @see isSetCompartmentType()
   * @see getCompartmentType()
   * @see unsetCompartmentType()
   */
  int setCompartmentType (const std::string& sid);


  /**
   * Sets the "spatialDimensions" attribute of this Compartment object.
   *
   * @param value an unsigned integer indicating the number of dimensions
   * of this compartment.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @see getSpatialDimensions()
   * @see isSetSpatialDimensions()
   * @see unsetSpatialDimensions()
   */
  int setSpatialDimensions (unsigned int value);


  /**
   * Sets the "spatialDimensions" attribute of this Compartment object as a double.
   *
   * @param value a double indicating the number of dimensions
   * of this compartment.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @see getSpatialDimensions()
   * @see isSetSpatialDimensions()
   * @see unsetSpatialDimensions()
   */
  int setSpatialDimensions (double value);


  /**
   * Sets the "size" attribute (or "volume" in SBML Level&nbsp;1) of this
   * Compartment object.
   *
   * @param value a @c double representing the size of this compartment
   * instance in whatever units are in effect for the compartment.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @note This method is identical to
   * @if java Compartment::setVolume(double value)@else setVolume()@endif.
   *
   * @see setVolume(@if java double@endif)
   * @see getSize()
   * @see isSetSize()
   * @see unsetSize()
   */
  int setSize (double value);


  /**
   * Sets the "volume" attribute (or "size" in SBML Level&nbsp;2) of this
   * Compartment object.
   *
   * This method is identical to
   * @if java Compartment::setSize(double value)@else setSize()@endif@~
   * and is provided for compatibility between SBML Level&nbsp;1 and
   * higher Levels of SBML.
   *
   * @param value a @c double representing the volume of this compartment
   * instance in whatever units are in effect for the compartment.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @copydetails doc_note_compartment_volume
   *
   * @see setSize(@if java double@endif)
   * @see getVolume()
   * @see isSetVolume()
   * @see unsetVolume()
   */
  int setVolume (double value);


  /**
   * Sets the "units" attribute of this Compartment object.
   *
   * @param sid the identifier of the defined units to use.  If @p sid is @c
   * NULL, then this method will return
   * @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see isSetUnits()
   * @see getUnits()
   * @see unsetUnits()
   */
  int setUnits (const std::string& sid);


  /**
   * Sets the "outside" attribute of this Compartment object.
   *
   * @param sid the identifier of a compartment that encloses this one. If @p
   * sid is @c NULL, then this method will return
   * @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
   * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
   * Core.
   *
   * @see isSetOutside()
   * @see getOutside()
   * @see unsetOutside()
   */
  int setOutside (const std::string& sid);


  /**
   * Sets the value of the "constant" attribute of this Compartment object.
   *
   * @param value a boolean indicating whether the size/volume of this
   * compartment should be considered constant (@c true) or variable
   * (@c false).
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @see isSetConstant()
   * @see getConstant()
   */
  int setConstant (bool value);


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * @copydoc doc_renameunitsidref_common
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * Unsets the value of the "name" attribute of this Compartment object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see getName()
   * @see setName(@if java String@endif)
   * @see isSetName()
   */
  virtual int unsetName ();


  /**
   * Unsets the value of the "compartmentType" attribute of this Compartment object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The "compartmentType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   *
   * @see setCompartmentType(const std::string& sid)
   * @see isSetCompartmentType()
   * @see getCompartmentType()
   */
  int unsetCompartmentType ();


  /**
   * Unsets the value of the "size" attribute of this Compartment object.
   *
   * In SBML Level&nbsp;1, a compartment's volume has a default value (@c
   * 1.0) and therefore <em>should always be set</em>.  Calling this method
   * on a Level&nbsp;1 model resets the value to @c 1.0 rather than actually
   * unsetting it.  In Level&nbsp;2, a compartment's "size" is optional with
   * no default value, and unsetting it will result in the compartment having
   * no defined size.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note This method is identical to
   * @if java Compartment::unsetVolume()@else unsetVolume()@endif.
   *
   * @see unsetVolume()
   * @see getSize()
   * @see isSetSize()
   * @see setSize(@if java double@endif)
   */
  int unsetSize ();


  /**
   * Unsets the value of the "volume" attribute of this Compartment object.
   *
   * This method is identical to
   * @if java Compartment::unsetSize()@else unsetSize()@endif.  Please refer
   * to that method's documentation for more information about its behavior.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_compartment_volume
   *
   * @see unsetSize()
   * @see getVolume()
   * @see setVolume(@if java double@endif)
   * @see isSetVolume()
   */
  int unsetVolume ();


  /**
   * Unsets the value of the "units" attribute of this Compartment object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isSetUnits()
   * @see setUnits(@if java String@endif)
   * @see getUnits()
   */
  int unsetUnits ();


  /**
   * Unsets the value of the "outside" attribute of this Compartment object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
   * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
   * Core.
   *
   * @see isSetOutside()
   * @see getOutside()
   * @see setOutside(@if java String@endif)
   */
  int unsetOutside ();


  /**
   * Unsets the value of the "spatialDimensions" attribute of this
   * Compartment object.
   *
   * In SBML Levels prior to Level&nbsp;3, compartments must always have a
   * value for the number of dimensions.  Consequently, calling this method
   * on a model of SBML Level 1&ndash;2 will result in a return value of
   * @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note This function is only valid for SBML Level&nbsp;3.
   *
   * @see getSpatialDimensions()
   * @see isSetSpatialDimensions()
   * @see setSpatialDimensions(@if java unsigned int@endif)
   */
  int unsetSpatialDimensions ();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Compartment object's designated size.
   *
   * @copydetails doc_compartment_units
   *
   * @return a UnitDefinition that expresses the units of this
   * Compartment object, or @c NULL if one cannot be constructed.
   *
   * @copydetails doc_note_unit_analysis_depends_on_model
   *
   * @see isSetUnits()
   * @see getUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Compartment object's designated size.
   *
   * @copydetails doc_compartment_units
   *
   * @return a UnitDefinition that expresses the units of this
   * Compartment object, or @c NULL if one cannot be constructed.
   *
   * @copydetails doc_note_unit_analysis_depends_on_model
   *
   * @see isSetUnits()
   * @see getUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Returns the libSBML type code for this SBML object.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_COMPARTMENT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object
   *
   * For Compartment, the XML element name is always @c "compartment".
   *
   * @return the name of this element.
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
   * Predicate returning @c true if all the required attributes for this
   * Compartment object have been set.
   *
   * The required attributes for a Compartment object are:
   * @li "id" (or "name" in SBML Level&nbsp;1)
   * @li "constant" (in SBML Level&nbsp;3 only)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const;


protected:
  /** @cond doxygenLibsbmlInternal */



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

  bool isExplicitlySetSpatialDimensions() const {
    return mExplicitlySetSpatialDimensions; };

  bool isExplicitlySetConstant() const { return mExplicitlySetConstant; } ;


  std::string   mId;
  std::string   mName;
  std::string   mCompartmentType;
  unsigned int  mSpatialDimensions;
  double        mSpatialDimensionsDouble;
  double        mSize;
  std::string   mUnits;
  std::string   mOutside;
  bool          mConstant;

  bool  mIsSetSize;
  bool  mIsSetSpatialDimensions;
  bool  mIsSetConstant;
  bool  mExplicitlySetSpatialDimensions;
  bool  mExplicitlySetConstant;

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

  /** @endcond */
};


class LIBSBML_EXTERN ListOfCompartments : public ListOf
{
public:

  /**
   * Creates a new ListOfCompartments object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   *
   * @param version the Version within the SBML Level
   */
  ListOfCompartments (unsigned int level, unsigned int version);


  /**
   * Creates a new ListOfCompartments object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfCompartments object to be created.
   */
  ListOfCompartments (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfCompartments object.
   *
   * @return the (deep) copy of this ListOfCompartments object.
   */
  virtual ListOfCompartments* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Compartment objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf
   * instance: @sbmlconstant{SBML_COMPARTMENT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfCompartments, the XML element name is always
   * @c "listOfCompartments".
   *
   * @return the name of this element.
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Compartment object from the ListOfCompartments.
   *
   * @param n the index number of the Compartment object to get.
   *
   * @return the nth Compartment object in this ListOfCompartments.
   *
   * @see size()
   */
  virtual Compartment * get(unsigned int n);


  /**
   * Get a Compartment object from the ListOfCompartments.
   *
   * @param n the index number of the Compartment object to get.
   *
   * @return the nth Compartment object in this ListOfCompartments.
   *
   * @see size()
   */
  virtual const Compartment * get(unsigned int n) const;


  /**
   * Get a Compartment object from the ListOfCompartments
   * based on its identifier.
   *
   * @param sid a string representing the identifier
   * of the Compartment object to get.
   *
   * @return Compartment object in this ListOfCompartments
   * with the given @p sid or @c NULL if no such
   * Compartment object exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Compartment* get (const std::string& sid);


  /**
   * Get a Compartment object from the ListOfCompartments
   * based on its identifier.
   *
   * @param sid a string representing the identifier
   * of the Compartment object to get.
   *
   * @return Compartment object in this ListOfCompartments
   * with the given @p sid or @c NULL if no such
   * Compartment object exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Compartment* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfCompartments items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Compartment* remove (unsigned int n);


  /**
   * Removes item in this ListOfCompartments items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then
   * @c NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual Compartment* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfCompartments
   * in a model is (in SBML Level&nbsp;2 Version&nbsp;4) the fifth
   * ListOf___.  (However, it differs for different Levels and Versions of
   * SBML.)
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/* ----------------------------------------------------------------------------
 * See the .cpp file for the documentation of the following functions.
 * --------------------------------------------------------------------------*/

/*
LIBSBML_EXTERN
Compartment_t *
Compartment_createWithLevelVersionAndNamespaces (unsigned int level,
              unsigned int version, XMLNamespaces_t *xmlns);
*/

/**
 * Creates a new Compartment_t structure using the given SBML @p level and @p
 * version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Compartment_t structure.
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Compartment_t structure.
 *
 * @returns the newly-created Compartment_t structure, or a null pointer if
 * an error occurred during constructions.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
Compartment_t *
Compartment_create (unsigned int level, unsigned int version);


/**
 * Creates a new Compartment_t structure using the given SBMLNamespaces_t
 * structure, @p sbmlns.
 *
 * @copydetails doc_what_are_sbmlnamespaces
 *
 * It is worth emphasizing that although this constructor does not take an
 * identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
 * (identifier) attribute of a Compartment_t instance is required to have a
 * value.  Thus, callers are cautioned to assign a value after calling this
 * constructor.  Setting the identifier can be accomplished using the method
 * Compartment_setId().
 *
 * @param sbmlns an SBMLNamespaces_t structure.
 *
 * @returns the newly-created Compartment_t structure, or a null pointer if
 * an error occurred during constructions
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
Compartment_t *
Compartment_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Compartment_t structure.
 *
 * @param c the Compartment_t structure to be freed.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
void
Compartment_free (Compartment_t *c);


/**
 * Creates a deep copy of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure to be copied.
 *
 * @return a (deep) copy of the given Compartment_t structure, or a null
 * pointer if a failure occurred.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
Compartment_t *
Compartment_clone (const Compartment_t* c);


/**
 * Initializes the fields of the given Compartment_t structure to "typical"
 * default values.
 *
 * The SBML Compartment component has slightly different aspects and
 * default attribute values in different SBML Levels and Versions.
 * This method sets the values to certain common defaults, based
 * mostly on what they are in SBML Level&nbsp;2.  Specifically:
 *
 * @li Sets attribute "spatialDimensions" to @c 3
 * @li Sets attribute "constant" to @c 1
 * @li (Applies to Level&nbsp;1 models only) Sets attribute "volume" to @c 1.0
 * @li (Applies to Level&nbsp;3 models only) Sets attribute "units" to @c litre
 *
 * @param c the Compartment_t structure.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
void
Compartment_initDefaults (Compartment_t *c);


/**
 * Returns a list of XMLNamespaces_t structures associated with the given
 * Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return pointer to the XMLNamespaces_t structure associated with this SBML
 * structure
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Compartment_getNamespaces(Compartment_t *c);


/**
 * Returns the value of the "id" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return the id of this structure.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const char *
Compartment_getId (const Compartment_t *c);


/**
 * Returns the value of the "name" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return the name of the Compartment_t structure @p c, as a pointer to a
 * string.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const char *
Compartment_getName (const Compartment_t *c);


/**
 * Get the value of the "compartmentType" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "compartmentType" attribute of the
 * Compartment_t structure @p c as a string.
 *
 * @note The "compartmentType" attribute is only available in SBML
 * Level&nbsp;2 Versions&nbsp;2&ndash;4.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const char *
Compartment_getCompartmentType (const Compartment_t *c);


/**
 * Get the number of spatial dimensions of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "spatialDimensions" attribute of the
 * Compartment_t structure @p c as an unsigned integer
 *
 * @copydetails doc_note_spatial_dimensions_as_double
 *
 * @see Compartment_getSpatialDimensionsAsDouble()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
unsigned int
Compartment_getSpatialDimensions (const Compartment_t *c);


/**
 * Get the number of spatial dimensions of the given Compartment_t structure,
 * as a double.
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "spatialDimensions" attribute of the
 * Compartment_t structure @p c as a double.
 *
 * @copydetails doc_note_spatial_dimensions_as_double
 *
 * @see Compartment_getSpatialDimensions()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
double
Compartment_getSpatialDimensionsAsDouble (const Compartment_t *c);


/**
 * Get the size of the given Compartment_t structure.
 *
 * @copydetails doc_compartment_both_size_and_volume
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "size" attribute ("volume" in Level 1) of
 * the Compartment_t structure @p c as a float-point number.
 *
 * @note This method is identical to Compartment_getVolume().
 *
 * @see Compartment_isSetSize()
 * @see Compartment_getVolume()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
double
Compartment_getSize (const Compartment_t *c);


/**
 * Get the volume of the given Compartment_t structure.
 *
 * @copydetails doc_compartment_both_size_and_volume
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "volume" attribute ("size" in Level&nbsp;2) of
 * @p c, as a floating-point number.
 *
 * @copydetails doc_note_compartment_volume
 *
 * @note This method is identical to Compartment_getSize().
 *
 * @see Compartment_isSetVolume()
 * @see Compartment_getSize()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
double
Compartment_getVolume (const Compartment_t *c);


/**
 * Get the units of the given Compartment_t structure's size.
 *
 * The value of an SBML compartment's "units" attribute establishes the
 * unit of measurement associated with the compartment's size.
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "units" attribute of the Compartment_t structure,
 * as a string.  An empty string indicates that no units have been assigned
 * to the value of the size.
 *
 * @copydetails doc_note_unassigned_unit_are_not_a_default
 *
 * @see Compartment_isSetUnits()
 * @see Compartment_setUnits()
 * @see Compartment_getSize()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const char *
Compartment_getUnits (const Compartment_t *c);


/**
 * Get the identifier, if any, of the compartment that is designated
 * as being outside of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return the value of the "outside" attribute of this Compartment_t
 * structure.
 *
 * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
 * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
 * Core.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
const char *
Compartment_getOutside (const Compartment_t *c);


/**
 * Get the value of the "constant" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if this compartment's size is flagged as being
 * constant, @c 0 otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_getConstant (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "id"
 * attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "id" attribute of this Compartment_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetId (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "name"
 * attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "name" attribute of this Compartment_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetName (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's
 * "compartmentType" attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "compartmentType" attribute of this Compartment_t
 * structure is set, @c 0 otherwise.
 *
 * @note The "compartmentType" attribute is only available in SBML
 * Level&nbsp;2 Versions&nbsp;2&ndash;4.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetCompartmentType (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "size"
 * attribute is set.
 *
 * This method is similar but not identical to Compartment_isSetVolume().
 * The latter should be used in the context of SBML Level&nbsp;1 models
 * instead of Compartment_isSetSize() because Compartment_isSetVolume()
 * performs extra processing to take into account the difference in default
 * values between SBML Levels&nbsp;1 and&nbsp;2.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "size" attribute ("volume" in Level&nbsp;2) of
 * this Compartment_t structure is set, @c 0 otherwise.
 *
 * @see Compartment_isSetVolume()
 * @see Compartment_setSize()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetSize (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structures's "volume"
 * attribute is set.
 *
 * This method is similar but not identical to Compartment_isSetSize().  The
 * latter should not be used in the context of SBML Level&nbsp;1 models
 * because the present method performs extra processing to take into account
 * the difference in default values between SBML Levels&nbsp;1 and&nbsp;2.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "volume" attribute ("size" in Level&nbsp;2 and
 * above) of this Compartment_t structure is set, @c 0 otherwise.
 *
 * @copydetails doc_note_compartment_volume
 *
 * @see Compartment_isSetSize()
 * @see Compartment_setVolume()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetVolume (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "units"
 * attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "units" attribute of this Compartment_t structure
 * is set, @c 0 otherwise.
 *
 * @copydetails doc_note_unassigned_unit_are_not_a_default
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetUnits (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "outside"
 * attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "outside" attribute of this Compartment_t structure
 * is set, @c 0 otherwise.
 *
 * @note The "outside" attribute is defined in SBML Level&nbsp;1 and
 * Level&nbsp;2, but does not exist in SBML Level&nbsp;3 Version&nbsp;1
 * Core.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetOutside (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's
 * "spatialDimensions" attribute is set.
 *
 * @param c the Compartment_t structure.
 *
 * @return @c 1 if the "spatialDimensions" attribute of this Compartment_t
 * structure is set, @c 0 otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetSpatialDimensions (const Compartment_t *c);


/**
 * Predicate returning @c 1 if the given Compartment_t structure's "constant"
 * attribute is set.
 *
 * @return @c 1 if the "constant" attribute of this Compartment_t
 * structure is set, @c 0 otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_isSetConstant (const Compartment_t *c);


/**
 * Sets the value of the "id" attribute of the given Compartment_t structure.
 *
 * The string @p sid is copied.
 *
 * @copydetails doc_id_syntax
 *
 * @param c the Compartment_t structure.
 *
 * @param sid the identifier to which the structures "id" attribute should
 * be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p sid is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setId (Compartment_t *c, const char *sid);


/**
 * Sets the "name" attribute of the given Compartment_t structure.
 *
 * This function copies the string given in @p string.  If the string is
 * a null pointer, this function performs Compartment_unsetName() instead.
 *
 * @param c the Compartment_t structure.
 *
 * @param name the string to which the structures "name" attribute should be
 * set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p name is equivalent to
 * unsetting the value of the "name" attribute.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setName (Compartment_t *c, const char *name);


/**
 * Sets the "compartmentType" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 * @param sid the identifier of a CompartmentType_t structure defined
 * elsewhere in the enclosing Model_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p sid is equivalent to
 * unsetting the value of the "compartmentType" attribute.
 *
 * @note The "compartmentType" attribute is only available in SBML
 * Level&nbsp;2 Versions&nbsp;2&ndash;4.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setCompartmentType (Compartment_t *c, const char *sid);


/**
 * Sets the "spatialDimensions" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 * @param value an unsigned integer indicating the number of dimensions
 * of the given compartment.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setSpatialDimensions (Compartment_t *c, unsigned int value);


/**
 * Sets the "spatialDimensions" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 * @param value a double indicating the number of dimensions
 * of the given compartment.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setSpatialDimensionsAsDouble (Compartment_t *c, double value);


/**
 * Sets the "size" attribute (or "volume" in SBML Level 1) of the given
 * Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 * @param value a @c double representing the size of the given
 * Compartment_t structure in whatever units are in effect
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @see Compartment_isSetSize()
 * @see Compartment_setVolume()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setSize (Compartment_t *c, double value);


/**
 * Sets the "volume" attribute (or "size" in SBML Level 2) of the given
 * Compartment_t structure.
 *
 * This method is identical to Compartment_setSize() and is provided for
 * compatibility between SBML Level&nbsp;1 and higher Levels of SBML.
 *
 * @param c the Compartment_t structure.
 *
 * @param value a @c double representing the volume of the given
 * Compartment_t structure in whatever units are in effect
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @copydetails doc_note_compartment_volume
 *
 * @see Compartment_isSetVolume()
 * @see Compartment_setSize()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setVolume (Compartment_t *c, double value);


/**
 * Sets the "units" attribute of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @param sid the identifier of the defined units to use.  The string will
 * be copied.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p sid is equivalent to
 * unsetting the value of the "units" attribute.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setUnits (Compartment_t *c, const char *sid);


/**
 * Sets the "outside" attribute of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @param sid the identifier of a compartment that encloses this one.  The
 * string will be copied.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p sid is equivalent to
 * unsetting the value of the "outside" attribute.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setOutside (Compartment_t *c, const char *sid);


/**
 * Sets the value of the "constant" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @param value an integer indicating whether the size/volume of the
 * compartment @p c should be considered constant (indicated by a nonzero @p
 * value) or variable (@p value is zero).
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_setConstant (Compartment_t *c, int value);


/**
 * Unsets the "name" attribute of the given Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetName (Compartment_t *c);


/**
 * Unsets the value of the "compartmentType" attribute of the given
 * Compartment_t structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetCompartmentType (Compartment_t *c);


/**
 * Unsets the value of the "size" attribute of the given Compartment_t
 * structure.
 *
 * In SBML Level&nbsp;1, a compartment's volume has a default value (@c
 * 1.0) and therefore <em>should always be set</em>.  Calling this method
 * on a Level&nbsp;1 model resets the value to @c 1.0 rather than actually
 * unsetting it.  In Level&nbsp;2, a compartment's "size" is optional with
 * no default value, and unsetting it will result in the compartment having
 * no defined size.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetSize (Compartment_t *c);


/**
 * (For SBML Level 1) Unsets the value of the "volume" attribute of the
 * given Compartment_t structure.
 *
 * This method is identical to Compartment_unsetSize().  Please refer to that
 * method's documentation for more information about its behavior.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @copydetails doc_note_compartment_volume
 *
 * @see Compartment_unsetSize()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetVolume (Compartment_t *c);


/**
 * Unsets the value of the "units" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetUnits (Compartment_t *c);


/**
 * Unsets the value of the "outside" attribute of the given Compartment_t
 * structure.
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetOutside (Compartment_t *c);


/**
 * Unsets the value of the "spatialDimensions" attribute of the given
 * Compartment_t structure.
 *
 * In SBML Levels prior to Level&nbsp;3, compartments must always have a
 * value for the number of dimensions.  Consequently, calling this method
 * on a model of SBML Level 1&ndash;2 will result in a return value of
 * @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @param c the Compartment_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_unsetSpatialDimensions (Compartment_t *c);


/**
 * Constructs and returns a UnitDefinition that corresponds to the units
 * of the given Compartment_t structure's designated size.
 *
 * @copydetails doc_compartment_units
 *
 * @param c the Compartment_t structure whose units are to be returned.
 *
 * @return a UnitDefinition_t structure that expresses the units
 * of the given Compartment_t structure.
 *
 * @copydetails doc_note_unit_analysis_depends_on_model
 *
 * @see Compartment_isSetUnits()
 * @see Compartment_getUnits()
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
UnitDefinition_t *
Compartment_getDerivedUnitDefinition(Compartment_t *c);


/**
 * Predicate returning @c 1 or @c 0 depending on whether all the required
 * attributes for the given Compartment_t structure have been set.
 *
 * The required attributes for a Compartment_t structure are:
 * @li id (name in SBML Level 1 only)
 * @li constant (in SBML Level 3 only)
 *
 * @param c the Compartment_t structure to check.
 *
 * @return @c true (nonzero) if all the required attributes for this
 * structure have been defined, @c false (zero) otherwise.
 *
 * @memberof Compartment_t
 */
LIBSBML_EXTERN
int
Compartment_hasRequiredAttributes (Compartment_t *c);


/**
 * Returns the Compartment_t structure having a given identifier.
 *
 * @param lo the list of Compartments_t structures to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfCompartments with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfCompartments_t
 */
LIBSBML_EXTERN
Compartment_t *
ListOfCompartments_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a Compartment_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of Compartment_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The Compartment_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfCompartments_t
 */
LIBSBML_EXTERN
Compartment_t *
ListOfCompartments_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* Compartment_h */
