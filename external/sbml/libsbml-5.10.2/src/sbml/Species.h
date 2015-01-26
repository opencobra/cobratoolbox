/**
 * @file    Species.h
 * @brief   Definitions of Species and ListOfSpecies.
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
 * @class Species
 * @sbmlbrief{core} An SBML <em>species</em> &ndash; a pool of entities.
 *
 * A @em species in SBML refers to a pool of entities that (a) are
 * considered indistinguishable from each other for the purposes of the
 * model, (b) participate in reactions, and (c) are located in a specific
 * @em compartment.  The SBML Species object class is intended to represent
 * these pools.
 *
 * As with other major constructs in SBML, Species has a mandatory
 * attribute, "id", used to give the species type an identifier in the
 * model.  The identifier must be a text string conforming to the identifer
 * syntax permitted in SBML.  Species also has an optional "name"
 * attribute, of type @c string.  The "id" and "name" must be used
 * according to the guidelines described in the SBML specifications.
 *
 * The required attribute "compartment" is used to identify the compartment
 * in which the species is located.  The attribute's value must be the
 * identifier of an existing Compartment object.  It is important to note
 * that there is no default value for the "compartment" attribute on
 * Species; every species in an SBML model must be assigned a compartment
 * @em explicitly.  (This also implies that every model with one or more
 * Species objects must define at least one Compartment object.)
 *
 * 
 * @section species-amounts The initial amount and concentration of a species
 *
 * The optional attributes "initialAmount" and "initialConcentration", both
 * having a data type of @c double, can be used to set the @em initial
 * quantity of the species in the compartment where the species is located.
 * These attributes are mutually exclusive; i.e., <em>only one</em> can
 * have a value on any given instance of a Species object.  Missing
 * "initialAmount" and "initialConcentration" values implies that their
 * values either are unknown, or to be obtained from an external source, or
 * determined by an InitialAssignment or other SBML construct elsewhere in
 * the model.
 *
 * A species' initial quantity in SBML is set by the "initialAmount" or
 * "initialConcentration" attribute exactly once.  If the "constant"
 * attribute is @c true, then the value of the species' quantity is fixed
 * and cannot be changed except by an InitialAssignment.  These methods
 * differ in that the "initialAmount" and "initialConcentration" attributes
 * can only be used to set the species quantity to a literal floating-point
 * number, whereas the use of an InitialAssignment object allows the value
 * to be set using an arbitrary mathematical expression (which, thanks to
 * MathML's expressiveness, may evaluate to a rational number).  If the
 * species' "constant" attribute is @c false, the species' quantity value
 * may be overridden by an InitialAssignment or changed by AssignmentRule
 * or AlgebraicRule, and in addition, for <em>t &gt; 0</em>, it may also be
 * changed by a RateRule, Event objects, and as a result of being a
 * reactant or product in one or more Reaction objects.  (However, some
 * constructs are mutually exclusive; see the SBML specifications for the
 * precise details.)  It is not an error to define "initialAmount" or
 * "initialConcentration" on a species and also redefine the value using an
 * InitialAssignment, but the "initialAmount" or "initialConcentration"
 * setting in that case is ignored.  The SBML specifications provide
 * additional information about the semantics of assignments, rules and
 * values for simulation time <em>t</em> \f$\leq\f$ <em>0</em>.
 * 
 * SBML Level&nbsp;2 additionally stipulates that in cases where a species'
 * compartment has a "spatialDimensions" value of @c 0 (zero), the species
 * cannot have a value for "initialConcentration" because the concepts of
 * concentration and density break down when a container has zero
 * dimensions.
 *
 * @section species-units The units of a species' amount or concentration
 * 
 * When the attribute "initialAmount" is set, the unit of measurement
 * associated with the value of "initialAmount" is specified by the Species
 * attribute "substanceUnits".  When the "initialConcentration" attribute
 * is set, the unit of measurement associated with this concentration value
 * is {<em>unit of amount</em>} divided by {<em>unit of size</em>}, where
 * the {<em>unit of amount</em>} is specified by the Species
 * "substanceUnits" attribute, and the {<em>unit of size</em>} is specified
 * by the "units" attribute of the Compartment object in which the species
 * is located.  Note that in either case, a unit of <em>amount</em> is
 * involved and determined by the "substanceUnits" attribute.  Note
 * <strong>these two attributes alone do not determine the units of the
 * species when the species identifier appears in a mathematical
 * expression</strong>; <em>that</em> aspect is determined by the attribute
 * "hasOnlySubstanceUnits" discussed below.
 * 
 * In SBML Level&nbsp;3, if the "substanceUnits" attribute is not set on a
 * given Species object instance, then the unit of <em>amount</em> for that
 * species is inherited from the "substanceUnits" attribute on the
 * enclosing Model object instance.  If that attribute on Model is not set
 * either, then the unit associated with the species' quantity is
 * undefined.
 *
 * In SBML Level&nbsp;2, if the "substanceUnits" attribute is not set on a
 * given Species object instance, then the unit of <em>amount</em> for that
 * species is taken from the predefined SBML unit identifier @c
 * "substance".  The value assigned to "substanceUnits" must be chosen from
 * one of the following possibilities: one of the base unit identifiers
 * defined in SBML, the built-in unit identifier @c "substance", or the
 * identifier of a new unit defined in the list of unit definitions in the
 * enclosing Model object.  The chosen units for "substanceUnits" must be
 * be @c "dimensionless", @c "mole", @c "item", @c "kilogram", @c "gram",
 * or units derived from these.
 * 
 * As noted at the beginning of this section, simply setting
 * "initialAmount" or "initialConcentration" alone does @em not determine
 * whether a species identifier represents an amount or a concentration
 * when it appears elsewhere in an SBML model.  The role of the attribute
 * "hasOnlySubstanceUnits" is to indicate whether the units of the species,
 * when the species identifier appears in mathematical formulas, are
 * intended to be concentration or amount.  The attribute takes on a
 * boolean value.  In SBML Level&nbsp;3, the attribute has no default value
 * and must always be set in a model; in SBML Level&nbsp;2, it has a
 * default value of @c false.
 *
 * The <em>units of the species</em> are used in the following ways:
 * <ul>

 * <li> When the species' identifier appears in a MathML formula, it
 * represents the species' quantity, and the unit of measurement associated
 * with the quantity is as described above.
 * 
 * <li> The "math" elements of AssignmentRule, InitialAssignment and
 * EventAssignment objects referring to this species should all have the
 * same units as the unit of measurement associated with the species
 * quantity.
 * 
 * <li> In a RateRule object that defines the rate of change of the
 * species' quantity, the unit associated with the rule's "math" element
 * should be equal to the unit of the species' quantity divided by the
 * model-wide unit of <em>time</em>; in other words, {<em>unit of species
 * quantity</em>}/{<em>unit of time</em>}.
 * 
 * </ul>
 *
 *
 * @section species-constant The "constant" and "boundaryCondition" attributes
 *
 * The Species object class has two boolean attributes named "constant" and
 * "boundaryCondition", used to indicate whether and how the quantity of
 * that species can vary during a simulation.  In SBML Level&nbsp;2 they
 * are optional; in SBML Level&nbsp;3 they are mandatory.  The following
 * table shows how to interpret the combined values of these attributes.
 *
 * @htmlinclude species-boundarycondition.html
 * 
 * By default, when a species is a product or reactant of one or more
 * reactions, its quantity is determined by those reactions.  In SBML, it
 * is possible to indicate that a given species' quantity is <em>not</em>
 * determined by the set of reactions even when that species occurs as a
 * product or reactant; i.e., the species is on the <em>boundary</em> of
 * the reaction system, and its quantity is not determined by the
 * reactions.  The boolean attribute "boundaryCondition" can be used to
 * indicate this.  A value of @c false indicates that the species @em is
 * part of the reaction system.  In SBML Level&nbsp;2, the attribute has a
 * default value of @c false, while in SBML Level&nbsp;3, it has no
 * default.
 *
 * The "constant" attribute indicates whether the species' quantity can be
 * changed at all, regardless of whether by reactions, rules, or constructs
 * other than InitialAssignment.  A value of @c false indicates that the
 * species' quantity can be changed.  (This is also a common value because
 * the purpose of most simulations is precisely to calculate changes in
 * species quantities.)  In SBML Level&nbsp;2, the attribute has a default
 * value of @c false, while in SBML Level&nbsp;3, it has no default.  Note
 * that the initial quantity of a species can be set by an
 * InitialAssignment irrespective of the value of the "constant" attribute.
 *
 * In practice, a "boundaryCondition" value of @c true means a differential
 * equation derived from the reaction definitions should not be generated
 * for the species.  However, the species' quantity may still be changed by
 * AssignmentRule, RateRule, AlgebraicRule, Event, and InitialAssignment
 * constructs if its "constant" attribute is @c false.  Conversely, if the
 * species' "constant" attribute is @c true, then its value cannot be
 * changed by anything except InitialAssignment.
 *
 * A species having "boundaryCondition"=@c false and "constant"=@c false
 * can appear as a product and/or reactant of one or more reactions in the
 * model.  If the species is a reactant or product of a reaction, it must
 * @em not also appear as the target of any AssignmentRule or RateRule
 * object in the model.  If instead the species has "boundaryCondition"=@c
 * false and "constant"=@c true, then it cannot appear as a reactant or
 * product, or as the target of any AssignmentRule, RateRule or
 * EventAssignment object in the model.
 *
 *
 * @section species-l2-convfactor The conversionFactor attribute in SBML Level&nbsp;3
 * 
 * In SBML Level&nbsp;3, Species has an additional optional attribute,
 * "conversionFactor", that defines a conversion factor that applies to a
 * particular species.  The value must be the identifier of a Parameter
 * object instance defined in the model.  That Parameter object must be a
 * constant, meaning its "constant" attribute must be set to @c true.
 * If a given Species object definition defines a value for its
 * "conversionFactor" attribute, it takes precedence over any factor
 * defined by the Model object's "conversionFactor" attribute.
 * 
 * The unit of measurement associated with a species' quantity can be
 * different from the unit of extent of reactions in the model.  SBML
 * Level&nbsp;3 avoids implicit unit conversions by providing an explicit
 * way to indicate any unit conversion that might be required.  The use of
 * a conversion factor in computing the effects of reactions on a species'
 * quantity is explained in detail in the SBML Level&nbsp;3 specification
 * document.  Because the value of the "conversionFactor" attribute is the
 * identifier of a Parameter object, and because parameters can have units
 * attached to them, the transformation from reaction extent units to
 * species units can be completely specified using this approach.
 * 
 * Note that the unit conversion factor is <strong>only applied when
 * calculating the effect of a reaction on a species</strong>.  It is not
 * used in any rules or other SBML constructs that affect the species, and
 * it is also not used when the value of the species is referenced in a
 * mathematical expression.
 * 
 *
 * @section species-l2-type The speciesType attribute in SBML Level&nbsp;2 Versions&nbsp;2&ndash;4
 *
 * In SBML Level&nbsp;2 Versions&nbsp;2&ndash;4, each species in a model
 * may optionally be designated as belonging to a particular species type.
 * The optional attribute "speciesType" is used to identify the species
 * type of the chemical entities that make up the pool represented by the
 * Species objects.  The attribute's value must be the identifier of an
 * existing SpeciesType object in the model.  If the "speciesType"
 * attribute is not present on a particular species definition, it means
 * the pool contains chemical entities of a type unique to that pool; in
 * effect, a virtual species type is assumed for that species, and no other
 * species can belong to that species type.  The value of "speciesType"
 * attributes on species have no effect on the numerical interpretation of
 * a model; simulators and other numerical analysis software may ignore
 * "speciesType" attributes.
 * 
 * There can be only one species of a given species type in any given
 * compartment of a model.  More specifically, for all Species objects
 * having a value for the "speciesType" attribute, the pair
 * <center>
 * ("speciesType" attribute value, "compartment" attribute value)
 * </center>
 * 
 * must be unique across the set of all Species object in a model.
 *
 * 
 * @section species-other The spatialSizeUnits attribute in SBML Level&nbsp;2 Versions&nbsp;1&ndash;2
 *
 * In versions of SBML Level&nbsp;2 before Version&nbsp;3, the class
 * Species included an attribute called "spatialSizeUnits", which allowed
 * explicitly setting the units of size for initial concentration.  LibSBML
 * retains this attribute for compatibility with older definitions of
 * Level&nbsp;2, but its use is strongly discouraged because many software
 * tools do no properly interpret this unit declaration and it is
 * incompatible with all SBML specifications after Level&nbsp;2
 * Version&nbsp;3.
 *
 * 
 * @section species-math Additional considerations for interpreting the numerical value of a species
 * 
 * Species are unique in SBML in that they have a kind of duality: a
 * species identifier may stand for either substance amount (meaning, a
 * count of the number of individual entities) or a concentration or
 * density (meaning, amount divided by a compartment size).  The previous
 * sections explain the meaning of a species identifier when it is
 * referenced in a mathematical formula or in rules or other SBML
 * constructs; however, it remains to specify what happens to a species
 * when the compartment in which it is located changes in size.
 * 
 * When a species definition has a "hasOnlySubstanceUnits" attribute value
 * of @c false and the size of the compartment in which the species is
 * located changes, the default in SBML is to assume that it is the
 * concentration that must be updated to account for the size change.  This
 * follows from the principle that, all other things held constant, if a
 * compartment simply changes in size, the size change does not in itself
 * cause an increase or decrease in the number of entities of any species
 * in that compartment.  In a sense, the default is that the @em amount of
 * a species is preserved across compartment size changes.  Upon such size
 * changes, the value of the concentration or density must be recalculated
 * from the simple relationship <em>concentration = amount / size</em> if
 * the value of the concentration is needed (for example, if the species
 * identifier appears in a mathematical formula or is otherwise referenced
 * in an SBML construct).  There is one exception: if the species' quantity
 * is determined by an AssignmentRule, RateRule, AlgebraicRule, or an
 * EventAssignment and the species has a "hasOnlySubstanceUnits" attribute
 * value of @c false, it means that the <em>concentration</em> is assigned
 * by the rule or event; in that case, the <em>amount</em> must be
 * calculated when the compartment size changes.  (Events also require
 * additional care in this situation, because an event with multiple
 * assignments could conceivably reassign both a species quantity and a
 * compartment size simultaneously.  Please refer to the SBML
 * specifications for the details.)
 * 
 * Note that the above only matters if a species has a
 * "hasOnlySubstanceUnits" attribute value of @c false, meaning that the
 * species identifier refers to a concentration wherever the identifier
 * appears in a mathematical formula.  If instead the attribute's value is
 * @c true, then the identifier of the species <em>always</em> stands for
 * an amount wherever it appears in a mathematical formula or is referenced
 * by an SBML construct.  In that case, there is never a question about
 * whether an assignment or event is meant to affect the amount or
 * concentration: it is always the amount.
 * 
 * A particularly confusing situation can occur when the species has
 * "constant" attribute value of @c true in combination with a
 * "hasOnlySubstanceUnits" attribute value of @c false.  Suppose this
 * species is given a value for "initialConcentration".  Does a "constant"
 * value of @c true mean that the concentration is held constant if the
 * compartment size changes?  No; it is still the amount that is kept
 * constant across a compartment size change.  The fact that the species
 * was initialized using a concentration value is irrelevant.
 * 
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfSpecies
 * @sbmlbrief{core} A list of Species objects.
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
 * @class doc_warning_species_spatialSizeUnits
 *
 * @warning <span class="warning">In versions of SBML Level&nbsp;2 before
 * Version&nbsp;3, the class Species included an attribute called
 * "spatialSizeUnits", which allowed explicitly setting the units of size for
 * initial concentration.  This attribute was removed in SBML Level&nbsp;2
 * Version&nbsp;3.  LibSBML retains this attribute for compatibility with
 * older definitions of Level&nbsp;2, but its use is strongly discouraged
 * because it is incompatible with Level&nbsp;2 Version&nbsp;3 and
 * Level&nbsp;2 Version&nbsp;4.</span>
 *
 * @class doc_note_species_units
 * 
 * @note The "units" attribute is defined only in SBML Level&nbsp;1.  In
 * SBML Level&nbsp;2 and Level&nbsp;3, it has been replaced by a
 * combination of "substanceUnits" and the units of the Compartment
 * object in which a species is located.  In SBML Level&nbsp;2
 * Versions&nbsp;1&ndash;2, an additional attribute "spatialSizeUnits"
 * helps determine the units of the species quantity, but this attribute
 * was removed in later versions of SBML Level&nbsp;2.
 *
 * @class doc_note_charge_deprecated
 * 
 * @note Beginning in SBML Level&nbsp;2 Version&nbsp;2, the "charge"
 * attribute on Species is deprecated and in SBML Level&nbsp;3 it does
 * not exist at all.  Its use strongly discouraged.  Its presence is
 * considered a misfeature in earlier definitions of SBML because its
 * implications for the mathematics of a model were never defined, and in
 * any case, no known modeling system ever used it.  Instead, models take
 * account of charge values directly in their definitions of species by
 * (for example) having separate species identities for the charged and
 * uncharged versions of the same species.  This allows the condition to
 * affect model mathematics directly.  LibSBML retains this method for
 * easier compatibility with SBML Level&nbsp;1.

 */

#ifndef Species_h
#define Species_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN Species : public SBase
{
public:

  /**
   * Creates a new Species using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Species
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Species
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Species (unsigned int level, unsigned int version);


  /**
   * Creates a new Species using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * It is worth emphasizing that although this constructor does not take
   * an identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a Species is required to have a value.
   * Thus, callers are cautioned to assign a value after calling this
   * constructor.  Setting the identifier can be accomplished using the
   * method Species::setId(@if java String@endif).
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
  Species (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Species.
   */
  virtual ~Species ();


  /**
   * Copy constructor; creates a copy of this Species object.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Species(const Species& orig);


  /**
   * Assignment operator for Species.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Species& operator=(const Species& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Species.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Species object.
   *
   * @return the (deep) copy of this Species object.
   */
  virtual Species* clone () const;


  /**
   * Initializes the fields of this Species object to "typical" defaults
   * values.
   *
   * The SBML Species component has slightly different aspects and
   * default attribute values in different SBML Levels and Versions.
   * This method sets the values to certain common defaults, based
   * mostly on what they are in SBML Level&nbsp;2.  Specifically:
   * <ul>
   * <li> Sets "boundaryCondition" to @c false
   * <li> Sets "constant" to @c false
   * <li> sets "hasOnlySubstanceUnits" to @c false
   * <li> (Applies to Level&nbsp;3 models only) Sets attribute "substanceUnits" to @c mole
   * </ul>
   */
  void initDefaults ();


  /**
   * Returns the value of the "id" attribute of this Species object.
   * 
   * @return the id of this Species object.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this Species object.
   * 
   * @return the name of this Species object.
   */
  virtual const std::string& getName () const;


  /**
   * Get the type of this Species object object.
   * 
   * @return the value of the "speciesType" attribute of this
   * Species as a string.
   * 
   * @note The "speciesType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   */
  const std::string& getSpeciesType () const;


  /**
   * Get the compartment in which this species is located.
   *
   * The compartment is designated by its identifier.
   * 
   * @return the value of the "compartment" attribute of this Species
   * object, as a string.
   */
  const std::string& getCompartment () const;


  /**
   * Get the value of the "initialAmount" attribute.
   * 
   * @return the initialAmount of this Species, as a float-point number.
   */
  double getInitialAmount () const;


  /**
   * Get the value of the "initialConcentration" attribute.
   * 
   * @return the initialConcentration of this Species,, as a float-point
   * number.
   *
   * @note The attribute "initialConcentration" is only available in SBML
   * Level&nbsp;2 and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  double getInitialConcentration () const;


  /**
   * Get the value of the "substanceUnits" attribute.
   * 
   * @return the value of the "substanceUnits" attribute of this Species,
   * as a string.  An empty string indicates that no units have been
   * assigned.
   *
   * @copydetails doc_note_unassigned_unit_are_not_a_default
   *
   * @see isSetSubstanceUnits()
   * @see setSubstanceUnits(const std::string& sid)
   */
  const std::string& getSubstanceUnits () const;


  /**
   * Get the value of the "spatialSizeUnits" attribute.
   * 
   * @return the value of the "spatialSizeUnits" attribute of this Species
   * object, as a string.
   *
   * @copydetails doc_warning_species_spatialSizeUnits
   */
  const std::string& getSpatialSizeUnits () const;


  /**
   * Get the value of the "units" attribute.
   * 
   * @return the units of this Species (L1 only).
   *
   * @copydetails doc_note_species_units 
   */
  const std::string& getUnits () const;


  /**
   * Get the value of the "hasOnlySubstanceUnits" attribute.
   * 
   * @return @c true if this Species' "hasOnlySubstanceUnits" attribute
   * value is nonzero, @c false otherwise.
   *
   * @note The "hasOnlySubstanceUnits" attribute does not exist in SBML
   * Level&nbsp;1.
   */
  bool getHasOnlySubstanceUnits () const;


  /**
   * Get the value of the "boundaryCondition" attribute.
   * 
   * @return @c true if this Species' "boundaryCondition" attribute value
   * is nonzero, @c false otherwise.
   */
  bool getBoundaryCondition () const;


  /**
   * Get the value of the "charge" attribute.
   * 
   * @return the charge of this Species object.
   *
   * @copydetails doc_note_charge_deprecated
   */
  int getCharge () const;


  /**
   * Get the value of the "constant" attribute.
   * 
   * @return @c true if this Species's "constant" attribute value is
   * nonzero, @c false otherwise.
   *
   * @note The attribute "constant" is only available in SBML Levels&nbsp;2
   * and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  bool getConstant () const;


  /**
   * Get the value of the "conversionFactor" attribute.
   * 
   * @return the conversionFactor of this Species, as a string.
   * 
   * @note The "conversionFactor" attribute was introduced in SBML
   * Level&nbsp;3.  It does not exist on Species in SBML Levels&nbsp;1
   * and&nbsp;2.
   */
  const std::string& getConversionFactor () const;


  /**
   * Predicate returning @c true if this
   * Species object's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this Species is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * Species object's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this Species is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if this Species object's
   * "speciesType" attribute is set.
   *
   * @return @c true if the "speciesType" attribute of this Species is
   * set, @c false otherwise.
   * 
   * @note The "speciesType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   */
  bool isSetSpeciesType () const;


  /**
   * Predicate returning @c true if this
   * Species object's "compartment" attribute is set.
   *
   * @return @c true if the "compartment" attribute of this Species is
   * set, @c false otherwise.
   */
  bool isSetCompartment () const;


  /**
   * Predicate returning @c true if this
   * Species object's "initialAmount" attribute is set.
   *
   * @return @c true if the "initialAmount" attribute of this Species is
   * set, @c false otherwise.
   *
   * @note In SBML Level&nbsp;1, Species' "initialAmount" is required and
   * therefore <em>should always be set</em>.  (However, in Level&nbsp;1, the
   * attribute has no default value either, so this method will not return
   * @c true until a value has been assigned.)  In SBML Level&nbsp;2,
   * "initialAmount" is optional and as such may or may not be set.
   */
  bool isSetInitialAmount () const;


  /**
   * Predicate returning @c true if this
   * Species object's "initialConcentration" attribute is set.
   *
   * @return @c true if the "initialConcentration" attribute of this Species is
   * set, @c false otherwise.
   *
   * @note The attribute "initialConcentration" is only available in SBML
   * Level&nbsp;2 and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  bool isSetInitialConcentration () const;


  /**
   * Predicate returning @c true if this
   * Species object's "substanceUnits" attribute is set.
   *
   * @return @c true if the "substanceUnits" attribute of this Species is
   * set, @c false otherwise.
   */
  bool isSetSubstanceUnits () const;


  /**
   * Predicate returning @c true if this
   * Species object's "spatialSizeUnits" attribute is set.
   *
   * @return @c true if the "spatialSizeUnits" attribute of this Species is
   * set, @c false otherwise.
   *
   * @copydetails doc_warning_species_spatialSizeUnits
   */
  bool isSetSpatialSizeUnits () const;


  /**
   * Predicate returning @c true if
   * this Species object's "units" attribute is set.
   *
   * @return @c true if the "units" attribute of this Species is
   * set, @c false otherwise.
   */
  bool isSetUnits () const;


  /**
   * Predicate returning @c true if this
   * Species object's "charge" attribute is set.
   *
   * @return @c true if the "charge" attribute of this Species is
   * set, @c false otherwise.
   *
   * @copydetails doc_note_charge_deprecated 
   */
  bool isSetCharge () const;


  /**
   * Predicate returning @c true if this
   * Species object's "conversionFactor" attribute is set.
   *
   * @return @c true if the "conversionFactor" attribute of this Species is
   * set, @c false otherwise.
   * 
   * @note The "conversionFactor" attribute was introduced in SBML
   * Level&nbsp;3.  It does not exist on Species in SBML Levels&nbsp;1
   * and&nbsp;2.
   */
  bool isSetConversionFactor () const;


  /**
   * Predicate returning @c true if this
   * Species object's "boundaryCondition" attribute is set.
   *
   * @return @c true if the "boundaryCondition" attribute of this Species is
   * set, @c false otherwise.
   */
  bool isSetBoundaryCondition () const;


  /**
   * Predicate returning @c true if this
   * Species object's "hasOnlySubstanceUnits" attribute is set.
   *
   * @return @c true if the "hasOnlySubstanceUnits" attribute of this Species is
   * set, @c false otherwise.
   *
   * @note The "hasOnlySubstanceUnits" attribute does not exist in SBML
   * Level&nbsp;1.
   */
  bool isSetHasOnlySubstanceUnits () const;


  /**
   * Predicate returning @c true if this
   * Species object's "constant" attribute is set.
   *
   * @return @c true if the "constant" attribute of this Species is
   * set, @c false otherwise.
   *
   * @note The attribute "constant" is only available in SBML Levels&nbsp;2
   * and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  bool isSetConstant () const;


  /**
   * Sets the value of the "id" attribute of this Species object.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this Species
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this Species object.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the Species
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setName (const std::string& name);


  /**
   * Sets the "speciesType" attribute of this Species object.
   *
   * @param sid the identifier of a SpeciesType object defined elsewhere
   * in this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * 
   * @note The "speciesType" attribute is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   */
  int setSpeciesType (const std::string& sid);


  /**
   * Sets the "compartment" attribute of this Species object.
   *
   * @param sid the identifier of a Compartment object defined elsewhere
   * in this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setCompartment (const std::string& sid);


  /**
   * Sets the "initialAmount" attribute of this Species and marks the field
   * as set.
   *
   * This method also unsets the "initialConcentration" attribute.
   *
   * @param value the value to which the "initialAmount" attribute should
   * be set.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setInitialAmount (double value);


  /**
   * Sets the "initialConcentration" attribute of this Species and marks
   * the field as set.
   *
   * This method also unsets the "initialAmount" attribute.
   *
   * @param value the value to which the "initialConcentration" attribute
   * should be set.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The attribute "initialConcentration" is only available in SBML
   * Level&nbsp;2 and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  int setInitialConcentration (double value);


  /**
   * Sets the "substanceUnits" attribute of this Species object.
   *
   * @param sid the identifier of the unit to use.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setSubstanceUnits (const std::string& sid);


  /**
   * (SBML Level&nbsp;2 Versions&nbsp;1&ndash;2) Sets the "spatialSizeUnits" attribute of this Species object.
   *
   * @param sid the identifier of the unit to use.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_warning_species_spatialSizeUnits
   */
  int setSpatialSizeUnits (const std::string& sid);


  /**
   * (SBML Level&nbsp;1 only) Sets the units of this Species object.
   *
   * @param sname the identifier of the unit to use.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
  */
  int setUnits (const std::string& sname);


  /**
   * Sets the "hasOnlySubstanceUnits" attribute of this Species object.
   *
   * @param value boolean value for the "hasOnlySubstanceUnits" attribute.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The "hasOnlySubstanceUnits" attribute does not exist in SBML
   * Level&nbsp;1.
   */
  int setHasOnlySubstanceUnits (bool value);


  /**
   * Sets the "boundaryCondition" attribute of this Species object.
   *
   * @param value boolean value for the "boundaryCondition" attribute.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setBoundaryCondition (bool value);


  /**
   * Sets the "charge" attribute of this Species object.
   *
   * @param value an integer to which to set the "charge" to.
   *
   * @copydetails doc_note_charge_deprecated 
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  int setCharge (int value);


  /**
   * Sets the "constant" attribute of this Species object.
   *
   * @param value a boolean value for the "constant" attribute
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The attribute "constant" is only available in SBML Levels&nbsp;2
   * and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  int setConstant (bool value);


  /**
   * Sets the value of the "conversionFactor" attribute of this Species object.
   *
   * The string in @p sid is copied.
   *
   * @param sid the new conversionFactor for the Species
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * 
   * @note The "conversionFactor" attribute was introduced in SBML
   * Level&nbsp;3.  It does not exist on Species in SBML Levels&nbsp;1
   * and&nbsp;2.
   */
  int setConversionFactor (const std::string& sid);


  /**
   * Unsets the value of the "name" attribute of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Unsets the "speciesType" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The attribute "speciesType" is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.
   */
  int unsetSpeciesType ();


  /**
   * Unsets the "initialAmount" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetInitialAmount ();


  /**
   * Unsets the "initialConcentration" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The attribute "initialConcentration" is only available in SBML
   * Level&nbsp;2 and&nbsp;3.  It does not exist on Species in Level&nbsp;1.
   */
  int unsetInitialConcentration ();


  /**
   * Unsets the "substanceUnits" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetSubstanceUnits ();


  /**
   * Unsets the "spatialSizeUnits" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_warning_species_spatialSizeUnits
   */
  int unsetSpatialSizeUnits ();


  /**
   * Unsets the "units" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetUnits ();


  /**
   * Unsets the "charge" attribute
   * value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_charge_deprecated 
   */
  int unsetCharge ();


  /**
   * Unsets the "conversionFactor" attribute value of this Species object.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * 
   * @note The "conversionFactor" attribute was introduced in SBML
   * Level&nbsp;3.  It does not exist on Species in SBML Levels&nbsp;1
   * and&nbsp;2.
   */
  int unsetConversionFactor ();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Species' amount or concentration.
   *
   * Species in SBML have an attribute ("substanceUnits") for declaring the
   * units of measurement intended for the species' amount or concentration
   * (depending on which one applies).  In the absence of a value given for
   * "substanceUnits", the units are taken from the enclosing Model's
   * definition of @c "substance" or @c "substance"/<em>(size of the
   * compartment)</em> in which the species is located, or finally, if
   * these are not redefined by the Model, the relevant SBML default units
   * for those quantities.  Following that procedure, the method
   * @if java Species::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * returns a UnitDefinition based on the
   * interpreted units of this species's amount or concentration.
   *
   * Note that the functionality that facilitates unit analysis depends 
   * on the model as a whole.  Thus, in cases where the object has not 
   * been added to a model or the model itself is incomplete,
   * unit analysis is not possible and this method will return @c NULL.
   *
   * Note also that unit declarations for Species are in terms of the @em
   * identifier of a unit, but this method returns a UnitDefinition object,
   * not a unit identifier.  It does this by constructing an appropriate
   * UnitDefinition.  Callers may find this particularly useful when used
   * in conjunction with the helper methods on UnitDefinition for comparing
   * different UnitDefinition objects.
   * 
   * In SBML Level&nbsp;2 specifications prior to Version&nbsp;3, Species
   * includes an additional attribute named "spatialSizeUnits", which
   * allows explicitly setting the units of size for initial concentration.
   * The @if java Species::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * takes this into account for models
   * expressed in SBML Level&nbsp;2 Versions&nbsp;1 and&nbsp;2.
   *
   * @return a UnitDefinition that expresses the units of this 
   * Species, or @c NULL if one cannot be constructed.
   *
   * @see getSubstanceUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Species' amount or concentration.
   *
   * Species in SBML have an attribute ("substanceUnits") for declaring the
   * units of measurement intended for the species' amount or concentration
   * (depending on which one applies).  In the absence of a value given for
   * "substanceUnits", the units are taken from the enclosing Model's
   * definition of @c "substance" or @c "substance"/<em>(size of the
   * compartment)</em> in which the species is located, or finally, if
   * these are not redefined by the Model, the relevant SBML default units
   * for those quantities.  Following that procedure, the method
   * @if java Species::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * returns a UnitDefinition based on the
   * interpreted units of this species's amount or concentration.
   *
   * Note that the functionality that facilitates unit analysis depends 
   * on the model as a whole.  Thus, in cases where the object has not 
   * been added to a model or the model itself is incomplete,
   * unit analysis is not possible and this method will return @c NULL.
   *
   * Note also that unit declarations for Species are in terms of the @em
   * identifier of a unit, but this method returns a UnitDefinition object,
   * not a unit identifier.  It does this by constructing an appropriate
   * UnitDefinition.  Callers may find this particularly useful when used
   * in conjunction with the helper methods on UnitDefinition for comparing
   * different UnitDefinition objects.
   * 
   * In SBML Level&nbsp;2 specifications prior to Version&nbsp;3, Species
   * includes an additional attribute named "spatialSizeUnits", which
   * allows explicitly setting the units of size for initial concentration.
   * The @if java Species::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * takes this into account for models
   * expressed in SBML Level&nbsp;2 Versions&nbsp;1 and&nbsp;2.
   *
   * @return a UnitDefinition that expresses the units of this 
   * Species, or @c NULL if one cannot be constructed.
   *
   * @see getSubstanceUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Returns the libSBML type code for this SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_SPECIES, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Species, is
   * always @c "species".
   * 
   * @return the name of this element, i.e., @c "species".
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
   * Predicate returning @c true if
   * all the required attributes for this Species object
   * have been set.
   *
   * The required attributes for a Species object are:
   * @li "id" (or "name" in SBML Level&nbsp;1)
   * @li "compartment"
   * @li "initialAmount" (required in SBML Level&nbsp;1 only; optional otherwise)
   * @li "hasOnlySubstanceUnits" (required in SBML Level&nbsp;3; optional in SBML Level&nbsp;2)
   * @li "boundaryCondition" (required in SBML Level&nbsp;3; optional in Levels&nbsp;1 and&nbsp;2)
   * @li "constant" (required in SBML Level&nbsp;3; optional in SBML Level&nbsp;2)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * @copydoc doc_renameunitsidref_common
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);



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

  bool isExplicitlySetBoundaryCondition() const 
                            { return mExplicitlySetBoundaryCondition; } ;

  bool isExplicitlySetConstant() const 
                            { return mExplicitlySetConstant; } ;

  bool isExplicitlySetHasOnlySubsUnits() const 
                            { return mExplicitlySetHasOnlySubsUnits; } ;

  std::string  mId;
  std::string  mName;
  std::string  mSpeciesType;
  std::string  mCompartment;

  double  mInitialAmount;
  double  mInitialConcentration;

  std::string  mSubstanceUnits;
  std::string  mSpatialSizeUnits;

  bool  mHasOnlySubstanceUnits;
  bool  mBoundaryCondition;
  int   mCharge;
  bool  mConstant;

  bool  mIsSetInitialAmount;
  bool  mIsSetInitialConcentration;
  bool  mIsSetCharge;
  
  std::string  mConversionFactor;
  bool         mIsSetBoundaryCondition;
  bool         mIsSetHasOnlySubstanceUnits;
  bool         mIsSetConstant;

  bool  mExplicitlySetBoundaryCondition;
  bool  mExplicitlySetConstant;
  bool  mExplicitlySetHasOnlySubsUnits;

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



class LIBSBML_EXTERN ListOfSpecies : public ListOf
{
public:

  /**
   * Creates a new ListOfSpecies object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfSpecies (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfSpecies object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfSpecies object to be created.
   */
  ListOfSpecies (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfSpecies object.
   *
   * @return the (deep) copy of this ListOfSpecies object.
   */
  virtual ListOfSpecies* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Species objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_SPECIES, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfSpeciess, the XML element name is @c "listOfSpeciess".
   * 
   * @return the name of this element, i.e., @c "listOfSpeciess".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Species from the ListOfSpecies.
   *
   * @param n the index number of the Species to get.
   * 
   * @return the nth Species in this ListOfSpecies.
   *
   * @see size()
   */
  virtual Species * get(unsigned int n); 


  /**
   * Get a Species from the ListOfSpecies.
   *
   * @param n the index number of the Species to get.
   * 
   * @return the nth Species in this ListOfSpecies.
   *
   * @see size()
   */
  virtual const Species * get(unsigned int n) const; 


  /**
   * Get a Species from the ListOfSpecies
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Species to get.
   * 
   * @return Species in this ListOfSpecies
   * with the given @p sid or @c NULL if no such
   * Species exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Species* get (const std::string& sid);


  /**
   * Get a Species from the ListOfSpecies
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Species to get.
   * 
   * @return Species in this ListOfSpecies
   * with the given @p sid or @c NULL if no such
   * Species exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Species* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfSpeciess items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Species* remove (unsigned int n);


  /**
   * Removes item in this ListOfSpeciess items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual Species* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfSpeciess in
   * a model is (in SBML Level&nbsp;2 Version&nbsp;4) the sixth
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

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new Species_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Species_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Species_t
 *
 * @return a pointer to the newly created Species_t structure.
 *
 * @note Once a Species_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Species_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
Species_t *
Species_create (unsigned int level, unsigned int version);


/**
 * Creates a new Species_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this Species_t
 *
 * @return a pointer to the newly created Species_t structure.
 *
 * @note Once a Species_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Species_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
Species_t *
Species_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Species_t structure.
 *
 * @param s the Species_t structure to be freed.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
void
Species_free (Species_t *s);


/**
 * Creates a deep copy of the given Species_t structure
 * 
 * @param s the Species_t structure to be copied
 * 
 * @return a (deep) copy of the given Species_t structure.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
Species_t *
Species_clone (const Species_t *s);


/**
 * Initializes the attributes of the given Species_t structure to the
 * defaults defined in the specification of the relevant Level/Version of
 * SBML.
 * 
 * @li sets "boundaryCondition" to @c 1 (true)
 * @li (Level 2 only) sets "constant" to @c 0 (false)
 * @li (Level 2 only) sets "hasOnlySubstanceUnits" to @c 0 (false)
 *
 * @param s the Species_t structure.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
void
Species_initDefaults (Species_t *s);


/**
 * Returns a list of XMLNamespaces_t associated with this Species_t
 * structure.
 *
 * @param s the Species_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Species_getNamespaces(Species_t *s);


/**
 * Takes a Species_t structure and returns its identifier.
 *
 * @param s the Species_t structure whose identifier is sought
 * 
 * @return the identifier of the Species_t structure @p s, as a pointer
 * to a string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getId (const Species_t *s);


/**
 * Takes a Species_t structure and returns its name.
 *
 * @param s the Species_t structure whose name is sought.
 *
 * @return the name of the Species_t structure @p s, as a pointer to a
 * string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getName (const Species_t *s);


/**
 * Get the species type of this Species_t structure, as indicated by the
 * Species_t structure's "speciesType" attribute value.
 *
 * @param s the Species_t structure
 * 
 * @return the value of the "speciesType" attribute of the
 * Species_t structure @p s as a string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getSpeciesType (const Species_t *s);


/**
 * Get the compartment in which this species is located.
 *
 * @param s the Species_t structure
 * 
 * @return the value of the "compartment" attribute of the given Species_t
 * structure, as a string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getCompartment (const Species_t *s);


/**
 * Get the value of the "initialAmount" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the "initialAmount" attribute of the given Species_t structure,
 * as a float-point number.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
double
Species_getInitialAmount (const Species_t *s);


/**
 * Get the value of the "initialConcentration" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the "initialConcentration" of the given Species_t structure, as
 * a float-point number.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
double
Species_getInitialConcentration (const Species_t *s);


/**
 * Get the value of the "substanceUnit" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the "substanceUnits" attribute of the given Species_t structure,
 * as a string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getSubstanceUnits (const Species_t *s);


/**
 * Get the value of the "spatialSizeUnits" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the spatialSizeUnits of the given Species_t.
 * 
 * @warning In versions of SBML Level&nbsp;2 before Version&nbsp;3, the Species_t
 * structure included an attribute called "spatialSizeUnits", which allowed
 * explicitly setting the units of size for initial concentration.  This
 * attribute was removed in SBML Level 2 Version&nbsp;3.  LibSBML retains this
 * attribute for compatibility with older definitions of Level 2, but its
 * use is strongly discouraged because it is incompatible with Level 2
 * Versions 3 and 4.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getSpatialSizeUnits (const Species_t *s);


/**
 * (SBML Level 1 only) Get the value of the "units" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the units of the given Species_t structure.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getUnits (const Species_t *s);


/**
 * Get the value of the "hasOnlySubstanceUnits" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return nonzero (true) if the given Species_t structure's
 * "hasOnlySubstanceUnits" attribute value is nonzero, zero (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_getHasOnlySubstanceUnits (const Species_t *s);


/**
 * Get the value of the "boundaryCondition" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return nonzero (true) if the given Species_t structure's
 * "boundaryCondition" attribute value is nonzero, zero (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_getBoundaryCondition (const Species_t *s);


/**
 * Get the value of the "charge" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the charge of the given Species_t structure.
 *
 * @note Beginning in SBML Level 2 Version&nbsp;2, the "charge" attribute on
 * Species_t is deprecated and its use strongly discouraged.  Its presence
 * is considered a misfeature in earlier definitions of SBML because its
 * implications for the mathematics of a model were never defined, and in
 * any case, no known modeling system ever used it.  Instead, models take
 * account of charge values directly in their definitions of species by
 * (for example) having separate species identities for the charged and
 * uncharged versions of the same species.  This allows the condition to
 * affect model mathematics directly.  LibSBML retains this method for
 * easier compatibility with SBML Level 1.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_getCharge (const Species_t *s);


/**
 * Get the value of the "constant" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return nonzero (true) if the given Species_t structure's "constant"
 * attribute value is nonzero, @c false otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_getConstant (const Species_t *s);


/**
 * Get the value of the "conversionFactor" attribute.
 *
 * @param s the Species_t structure
 * 
 * @return the "conversionFactor" attribute of the given Species_t structure,
 * as a string.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
const char *
Species_getConversionFactor (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "id" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "id" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetId (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "name" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "name" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetName (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "speciesType" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "speciesType" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetSpeciesType (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "compartment" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "compartment" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetCompartment (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "initialAmount" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "initialAmount" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @note In SBML Level 1, Species_t' "initialAmount" is required and
 * therefore <em>should always be set</em>.  (However, in Level 1, the
 * attribute has no default value either, so this method will not return
 * nonzero until a value has been assigned.)  In SBML Level 2,
 * "initialAmount" is optional and as such may or may not be set.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetInitialAmount (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "compartment" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "compartment" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetInitialConcentration (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "substanceUnits" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "substanceUnits" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetSubstanceUnits (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "spatialSizeUnits" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "spatialSizeUnits" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 * 
 * @warning In versions of SBML Level&nbsp;2 before Version&nbsp;3, the 
 * Species_t included an attribute called "spatialSizeUnits", which allowed
 * explicitly setting the units of size for initial concentration.  This
 * attribute was removed in SBML Level 2 Version&nbsp;3.  LibSBML retains this
 * attribute for compatibility with older definitions of Level 2, but its
 * use is strongly discouraged because it is incompatible with Level 2
 * Versions 3 and 4.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetSpatialSizeUnits (const Species_t *s);


/**
 * (SBML Level 1 only) Predicate returning true or false depending on
 * whether the attribute "units" of the given Species_t structure is
 * set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "units" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetUnits (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "charge" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "charge" attribute of the given
 * Species_t structure is set, false (0) otherwise.
 *
 * @note Beginning in SBML Level 2 Version&nbsp;2, the "charge" attribute on
 * Species_t in SBML is deprecated and its use strongly discouraged.  Its
 * presence is considered a misfeature in earlier definitions of SBML
 * because its implications for the mathematics of a model were never
 * defined, and in any case, no known modeling system ever used it.
 * Instead, models take account of charge values directly in their
 * definitions of species by (for example) having separate species
 * identities for the charged and uncharged versions of the same species.
 * This allows the condition to affect model mathematics directly.
 * LibSBML retains this method for easier compatibility with SBML Level 1.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetCharge (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "conversionFactor" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "conversionFactor" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetConversionFactor (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "constant" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "constant" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetConstant (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "boundaryCondition" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "boundaryCondition" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetBoundaryCondition (const Species_t *s);


/**
 * Predicate returning true or false depending on whether the attribute
 * "hasOnlySubstanceUnits" of the given Species_t structure is set.
 *
 * @param s the Species_t structure
 * 
 * @return true (nonzero) if the "hasOnlySubstanceUnits" attribute of the given Species_t
 * structure is set, false (0) otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_isSetHasOnlySubstanceUnits (const Species_t *s);


/**
 * Sets the "id" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p sid.  If the string is
 * @c NULL, this function performs unsetId() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifier string to which the "id" attribute should be
 * set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setId (Species_t *s, const char *sid);


/**
 * Sets the "name" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p name.  If the string is
 * @c NULL, this function performs unsetName() instead.
 *
 * @param s the Species_t structure
 * 
 * @param name the name string to which the "name" attribute should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setName (Species_t *s, const char *name);


/**
 * Sets the "speciesType" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p sid.  If the string
 * is NULL, this function performs unsetSpeciesType() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifer to which the "speciesType" attribute
 * should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "speciesType" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setSpeciesType (Species_t *s, const char *sid);


/**
 * Sets the "compartment" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p compartment.  If the string
 * is NULL, this function performs unsetCompartment() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifer to which the "compartment" attribute
 * should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "compartment" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setCompartment (Species_t *s, const char *sid);


/**
 * Sets the "initialAmount" attribute value of the given Species_t
 * structure.
 *
 * As a side-effect, calling this function also unsets the
 * "initialConcentration" attribute.
 *
 * @param s the Species_t structure
 *
 * @param value the numerical value for the "initialAmount" attribute
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setInitialAmount (Species_t *s, double value);


/**
 * Sets the "initialConcentration" attribute value of the given Species_t
 * structure.
 *
 * As a side-effect, calling this function also unsets the "initialAmount"
 * attribute.
 *
 * @param s the Species_t structure
 *
 * @param value the numerical value for the "initialConcentration"
 * attribute
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setInitialConcentration (Species_t *s, double value);


/**
 * Sets the "substanceUnits" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p sid.  If the string
 * is NULL, this function performs unsetSubstanceUnits() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifer to which the "substanceUnits"
 * attribute should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "substanceUnits" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setSubstanceUnits (Species_t *s, const char *sid);


/**
 * Sets the "spatialSizeUnits" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p sid.  If the string is NULL,
 * this function performs unsetSpatialSizeUnits() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifer to which the "spatialSizeUnits"
 * attribute should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "spatialSizeUnits" attribute.
 * 
 * @warning In versions of SBML Level&nbsp;2 before Version&nbsp;3, the structure
 * Species_t included an attribute called "spatialSizeUnits", which allowed
 * explicitly setting the units of size for initial concentration.  This
 * attribute was removed in SBML Level 2 Version&nbsp;3.  LibSBML retains this
 * attribute for compatibility with older definitions of Level 2, but its
 * use is strongly discouraged because it is incompatible with Level 2
 * Versions 3 and 4.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setSpatialSizeUnits (Species_t *s, const char *sid);


/**
 * (SBML Level 1 only) Sets the "units" attribute of the given Species_t
 * structure.
 *
 * This function copies the string given in @p sid.  If the string is NULL,
 * this function performs unsetUnits() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sname the identifer to which the "units" attribute
 * should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "units" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setUnits (Species_t *s, const char *sname);


/**
 * Sets the "hasOnlySubstanceUnits" attribute of the given Species_t
 * structure.
 *
 * @param s the Species_t structure
 * 
 * @param value nonzero to indicate true, zero to indicate false.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setHasOnlySubstanceUnits (Species_t *s, int value);


/**
 * Sets the "boundaryCondition" attribute of the given Species_t
 * structure.
 *
 * @param s the Species_t structure
 * 
 * @param value nonzero to indicate true, zero to indicate false.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setBoundaryCondition (Species_t *s, int value);


/**
 * Sets the "charge" attribute of the given Species_t
 * structure.
 *
 * @param s the Species_t structure
 * 
 * @param value the value of charge to assign to the "charge" attribute
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Beginning in SBML Level 2 Version&nbsp;2, the "charge" attribute on
 * Species_t in SBML is deprecated and its use strongly discouraged.  Its
 * presence is considered a misfeature in earlier definitions of SBML
 * because its implications for the mathematics of a model were never
 * defined, and in any case, no known modeling system ever used it.
 * Instead, models take account of charge values directly in their
 * definitions of species by (for example) having separate species
 * identities for the charged and uncharged versions of the same species.
 * This allows the condition to affect model mathematics directly.
 * LibSBML retains this method for easier compatibility with SBML Level 1.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setCharge (Species_t *s, int value);


/**
 * Sets the "constant" attribute of the given Species_t
 * structure.
 *
 * @param s the Species_t structure
 * 
 * @param value nonzero to indicate true, zero to indicate false.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setConstant (Species_t *s, int value);


/**
 * Sets the "conversionFactor" attribute of the given Species_t structure.
 *
 * This function copies the string given in @p sid.  If the string
 * is NULL, this function performs unsetConversionFactor() instead.
 *
 * @param s the Species_t structure
 * 
 * @param sid the identifer to which the "conversionFactor" attribute
 * should be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "conversionFactor" attribute.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_setConversionFactor (Species_t *s, const char *sid);


/**
 * Unsets the "name" attribute of the given Species_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetName (Species_t *s);


/**
 * Unsets the "speciesType" attribute of the given Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetSpeciesType (Species_t *s);


/**
 * Unsets the "initialAmount" attribute of the given Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetInitialAmount (Species_t *s);


/**
 * Unsets the "initialConcentration" attribute of the given
 * Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetInitialConcentration (Species_t *s);


/**
 * Unsets the "substanceUnits" attribute of the given
 * Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetSubstanceUnits (Species_t *s);


/**
 * Unsets the "spatialSizeUnits" attribute of the given
 * Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * 
 * @warning In versions of SBML Level&nbsp;2 before Version&nbsp;3, the structure
 * Species_t included an attribute called "spatialSizeUnits", which allowed
 * explicitly setting the units of size for initial concentration.  This
 * attribute was removed in SBML Level 2 Version&nbsp;3.  LibSBML retains this
 * attribute for compatibility with older definitions of Level 2, but its
 * use is strongly discouraged because it is incompatible with Level 2
 * Versions 3 and 4.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetSpatialSizeUnits (Species_t *s);


/**
 * Unsets the "units" attribute of the given
 * Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetUnits (Species_t *s);


/**
 * Unsets the "charge" attribute of the given
 * Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @note Beginning in SBML Level 2 Version&nbsp;2, the "charge" attribute on
 * Species_t in SBML is deprecated and its use strongly discouraged.  Its
 * presence is considered a misfeature in earlier definitions of SBML
 * because its implications for the mathematics of a model were never
 * defined, and in any case, no known modeling system ever used it.
 * Instead, models take account of charge values directly in their
 * definitions of species by (for example) having separate species
 * identities for the charged and uncharged versions of the same species.
 * This allows the condition to affect model mathematics directly.
 * LibSBML retains this method for easier compatibility with SBML Level 1.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetCharge (Species_t *s);

/**
 * Unsets the "conversionFactor" attribute of the given Species_t structure.
 *
 * @param s the Species_t structure whose attribute is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_unsetConversionFactor (Species_t *s);


/**
 * Constructs and returns a UnitDefinition_t structure that expresses 
 * the units of this Species_t structure.
 *
 * @param s the Species_t structure whose units are to be returned.
 *
 * @return a UnitDefinition_t structure that expresses the units 
 * of this Species_t strucuture.
 *
 * @note This function returns the units of the Species_t expressed 
 * as a UnitDefinition_t. The units may be those explicitly declared 
 * or those derived from the default units of the Model_t containing
 * this Species_t and it's Compartment_t.
 *
 * Note that the functionality that facilitates unit analysis depends 
 * on the model as a whole.  Thus, in cases where the structure has not 
 * been added to a model or the model itself is incomplete,
 * unit analysis is not possible and this method will return @c NULL.
 *
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
Species_getDerivedUnitDefinition(Species_t *s);


/**
 * Predicate returning @c true or @c false depending on whether
 * all the required attributes for this Species_t structure
 * have been set.
 *
 * The required attributes for a Species_t structure are:
 * @li id (name L1)
 * @li compartment
 * @li initialAmount (L1 only)
 * @li hasOnlySubstanceUnits (L3 on)
 * @li boundaryCondition (L3 on)
 * @li constant (L3 on)
 *
 * @param s the Species_t structure to check.
 *
 * @return a true if all the required
 * attributes for this structure have been defined, false otherwise.
 *
 * @memberof Species_t
 */
LIBSBML_EXTERN
int
Species_hasRequiredAttributes (Species_t *s);


/**
 * Returns the Species_t structure having a given identifier.
 *
 * @param lo the ListOfSpecies_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfSpecies with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpecies_t
 */
LIBSBML_EXTERN
Species_t *
ListOfSpecies_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a Species_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of Species_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The Species_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpecies_t
 */
LIBSBML_EXTERN
Species_t *
ListOfSpecies_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* Species_h */
