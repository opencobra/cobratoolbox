/**
 * @file    EventAssignment.h
 * @brief   Definition of EventAssignment and ListOfEventAssignments.
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
 * @class EventAssignment
 * @sbmlbrief{core} An assignment to a variable by an SBML <em>event</em>.
 *
 * Event contains an optional element called "listOfEventAssignments", of
 * class ListOfEventAssignments.  In every instance of an event definition
 * in a model, the object's "listOfEventAssignments" element must have a
 * non-empty list of one or more "eventAssignment" elements of class
 * EventAssignment.  The object class EventAssignment has one required
 * attribute, "variable", and a required element, "math".  Being derived
 * from SBase, it also has all the usual attributes and elements of its
 * parent class.
 *
 * An Event object defines when the event can occur, the variables that are
 * affected by the event, and how the variables are affected.  The purpose
 * of the EventAssignment object class is to define how variables are
 * affected by an Event.  In SBML Level&nbsp;2, every Event object instance
 * must have a nonempty list of event assignments; in SBML Level&nbsp;3,
 * the list of assignments is optional.
 *
 * The operation of an Event is divided into two phases (regardless of
 * whether a delay is involved): one phase when the event is @em triggered,
 * and the other when the event is @em executed.   EventAssignment objects
 * are interpreted when an event is executed.  The effects are described
 * below.
 *
 * @section event-variable The attribute "variable"
 * 
 * The EventAssignment attribute "variable" must be the identifier of an
 * existing Compartment, Species, SpeciesReference, or Parameter
 * instance defined in the model.  When the event is executed, the value of
 * the model component identified by "variable" is changed by the
 * EventAssignment to the value computed by the "math" element; that is, a
 * species' quantity, species reference's stoichiometry, compartment's size
 * or parameter's value are reset to the value computed by "math".
 *
 * Certain restrictions are placed on what can appear in "variable":
 * <ul>
 * <li> The object identified by the value of the EventAssignment attribute
 * "variable" must not have its "constant" attribute set to or default to
 * @c true.  (Constants cannot be affected by events.)
 *
 * <li> The "variable" attribute must not contain the identifier of a
 * reaction; only species, species references, compartment and parameter
 * values may be set by an Event.
 *
 * <li> The value of every "variable" attribute must be unique among the set
 * of EventAssignment structures within a given Event structure.  In other
 * words, a single event cannot have multiple EventAssignment objects
 * assigning the same variable.  (All of them would be performed at the
 * same time when that particular Event triggers, resulting in
 * indeterminacy.)  However, @em separate Event instances can refer to the
 * same variable.
 *  
 * <li> A variable cannot be assigned a value in an EventAssignment object
 * instance and also be assigned a value by an AssignmentRule; i.e., the
 * value of an EventAssignment's "variable" attribute cannot be the same as
 * the value of a AssignmentRule' "variable" attribute.  (Assignment rules
 * hold at all times, therefore it would be inconsistent to also define an
 * event that reassigns the value of the same variable.)
 * </ul>
 *
 * Note that the time of assignment of the object identified by the
 * value of the "variable" attribute is always the time at which the Event
 * is <em>executed</em>, not when it is <em>triggered</em>.  The timing is
 * controlled by the optional Delay in an Event.  The time of
 * assignment is not affected by the "useValuesFromTriggerTime"
 * attribute on Event---that attribute affects the time at which the
 * EventAssignment's "math" expression is @em evaluated.  In other
 * words, SBML allows decoupling the time at which the
 * "variable" is assigned from the time at which its value
 * expression is calculated.
 *
 * @section event-math The "math" subelement in an EventAssignment
 * 
 * The MathML expression contained in an EventAssignment defines the new
 * value of the variable being assigned by the Event.
 * 
 * As mentioned above, the time at which the expression in "math" is
 * evaluated is determined by the attribute "useValuesFromTriggerTime" on
 * Event.  If the attribute value is @c true, the expression must be
 * evaluated when the event is @em triggered; more precisely, the values of
 * identifiers occurring in MathML <code>&lt;ci&gt;</code> elements in the
 * EventAssignment's "math" expression are the values they have at the
 * point when the event @em triggered.  If, instead,
 * "useValuesFromTriggerTime"'s value is @c false, it means the values at
 * @em execution time should be used; that is, the values of identifiers
 * occurring in MathML <code>&lt;ci&gt;</code> elements in the
 * EventAssignment's "math" expression are the values they have at the
 * point when the event @em executed.
 *
 * @section eventassignment-version-diffs SBML Level/Version differences
 * 
 * Between Version&nbsp;4 and previous versions of SBML Level&nbsp;2, the
 * requirements regarding the matching of units between an
 * EvengAssignment's formula and the units of the object identified by the
 * "variable" attribute changed.  Previous versions required consistency,
 * but in SBML Level&nbsp;2 Version&nbsp;4 and in SBML Level&nbsp;3, unit
 * consistency is only @em recommended.  More precisely:
 * <ul>
 *
 * <li> In the case of a species, an EventAssignment sets the referenced
 * species' quantity (concentration or amount of substance) to the value
 * determined by the formula in the EventAssignment's "math" subelement.
 * The units of the "math" formula should (in SBML Level&nbsp;2
 * Version&nbsp;4 and in Level&nbsp;3) or must (in previous Versions of
 * Level&nbsp;2) be identical to the units of the species.
 *
 * <li> (SBML Level&nbsp;3 only.) In the case of a species reference, an
 * EventAssignment sets the stoichiometry of the reactant or product
 * referenced by the SpeciesReference object to the value determined by the
 * formula in the "math" element.  The unit associated with the value
 * produced by the "math" formula should be @c dimensionless, because
 * reactant and product stoichiometries in reactions are dimensionless
 * quantities.
 *
 * <li> In the case of a compartment, an EventAssignment sets the
 * referenced compartment's size to the size determined by the formula in
 * the "math" subelement of the EventAssignment.  The overall units of the
 * formula should (in SBML Level&nbsp;2 Version&nbsp;4 and in Level&nbsp;3)
 * or must (in previous Versions of Level&nbsp;2) be identical to the units
 * specified for the size of the compartment identified by the
 * EventAssignment's "variable" attribute.
 *
 * <li> In the case of a parameter, an EventAssignment sets the referenced
 * parameter's value to that determined by the formula in "math".  The
 * overall units of the formula should (in SBML Level&nbsp;2 Version&nbsp;4
 * and Level&nbsp;3) or must (in previous Versions of Level&nbsp;2) be
 * identical to the units defined for the parameter.
 * </ul>
 * 
 * Note that the formula placed in the "math" element <em>has no assumed
 * units</em>.  The consistency of the units of the formula, and the units
 * of the entity which the assignment affects, must be explicitly
 * established just as in the case of the value of the Delay subelement.
 * An approach similar to the one discussed in the context of Delay may be
 * used for the formula of an EventAssignment.
 *
 * @see Event
 *
 * 
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfEventAssignments
 * @sbmlbrief{core} A list of EventAssignment objects.
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
 * @class doc_eventassignment_units
 *
 * @par
 * The units are calculated based on the mathematical expression in the
 * EventAssignment and the model quantities referenced by
 * <code>&lt;ci&gt;</code> elements used within that expression.  The method
 * EventAssignment::getDerivedUnitDefinition() returns the calculated units,
 * to the extent that libSBML can compute them.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_warning_eventassignment_math_literals
 * 
 * @warning Note that it is possible the "math" expression in the
 * EventAssignment contains literal numbers or parameters with undeclared
 * units.  In those cases, it is not possible to calculate the units of the
 * overall expression without making assumptions.  LibSBML does not make
 * assumptions about the units, and
 * EventAssignment::getDerivedUnitDefinition() only returns the units as far
 * as it is able to determine them.  For example, in an expression <em>X +
 * Y</em>, if <em>X</em> has unambiguously-defined units and <em>Y</em> does
 * not, it will return the units of <em>X</em>.  When using this method,
 * <strong>it is critical that callers also invoke the method</strong>
 * EventAssignment::containsUndeclaredUnits() <strong>to determine whether
 * this situation holds</strong>.  Callers should take suitable action in
 * those situations.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_eventassignment_units
 *
 * @par
 * The units are calculated based on the mathematical expression in the
 * EventAssignment and the model quantities referenced by
 * <code>&lt;ci&gt;</code> elements used within that expression.  The method
 * EventAssignment::getDerivedUnitDefinition() returns the calculated units,
 * to the extent that libSBML can compute them.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_warning_eventassignment_math_literals
 * 
 * @warning <span class="warning">Note that it is possible the "math"
 * expression in the EventAssignment contains literal numbers or parameters
 * with undeclared units.  In those cases, it is not possible to calculate
 * the units of the overall expression without making assumptions.  LibSBML
 * does not make assumptions about the units, and
 * EventAssignment::getDerivedUnitDefinition() only returns the units as far
 * as it is able to determine them.  For example, in an expression <em>X +
 * Y</em>, if <em>X</em> has unambiguously-defined units and <em>Y</em> does
 * not, it will return the units of <em>X</em>.  When using this method,
 * <strong>it is critical that callers also invoke the method</strong>
 * EventAssignment::containsUndeclaredUnits() <strong>to determine whether
 * this situation holds</strong>.  Callers should take suitable action in
 * those situations.</span>
 *   
 */

#ifndef EventAssignment_h
#define EventAssignment_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class SBMLVisitor;


class LIBSBML_EXTERN EventAssignment : public SBase
{
public:

  /**
   * Creates a new EventAssignment using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this EventAssignment
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * EventAssignment
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  EventAssignment (unsigned int level, unsigned int version);


  /**
   * Creates a new EventAssignment using the given SBMLNamespaces object
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
  EventAssignment (SBMLNamespaces* sbmlns);


  /**
   * Destroys this EventAssignment.
   */
  virtual ~EventAssignment ();


  /**
   * Copy constructor; creates a copy of this EventAssignment.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  EventAssignment (const EventAssignment& orig);


  /**
   * Assignment operator.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  EventAssignment& operator=(const EventAssignment& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of EventAssignment.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next EventAssignment in
   * the list within which this EventAssignment is embedded (i.e., in the
   * ListOfEventAssignments located in the enclosing Event instance).
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this EventAssignment object.
   *
   * @return the (deep) copy of this EventAssignment object.
   */
  virtual EventAssignment* clone () const;


  /**
   * Get the value of this EventAssignment's "variable" attribute.
   * 
   * @return the identifier stored in the "variable" attribute of this
   * EventAssignment.
   */
  const std::string& getVariable () const;


  /**
   * Get the mathematical expression in this EventAssignment's "math"
   * subelement.
   * 
   * @return the top ASTNode of an abstract syntax tree representing the
   * mathematical formula in this EventAssignment.
   */
  const ASTNode* getMath () const;


  /**
   * Predicate for testing whether the attribute "variable" of this
   * EventAssignment is set.
   * 
   * @return @c true if the "variable" attribute of this EventAssignment
   * is set, @c false otherwise.
   */
  bool isSetVariable () const;


  /**
   * Predicate for testing whether the "math" subelement of this
   * EventAssignment is set.
   * 
   * @return @c true if this EventAssignment has a "math" subelement,
   * @c false otherwise.
   */
  bool isSetMath () const;


  /**
   * Sets the attribute "variable" of this EventAssignment to a copy of
   * the given identifier string.
   *
   * @param sid the identifier of a Compartment, Species or (global)
   * Parameter defined in this model.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setVariable (const std::string& sid);


  /**
   * Sets the "math" subelement of this EventAssignment to a copy of the
   * given ASTNode.
   *
   * @param math an ASTNode that will be copied and stored as the
   * mathematical formula for this EventAssignment.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setMath (const ASTNode* math);


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this EventAssignment.
   *
   * @copydetails doc_eventassignment_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_eventassignment_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this EventAssignment, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this EventAssignment.
   *
   * @copydetails doc_eventassignment_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_eventassignment_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this EventAssignment, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Predicate returning @c true if the math expression of this
   * EventAssignment contains literal numbers or parameters with undeclared
   * units.
   *
   * @copydetails doc_eventassignment_units
   *
   * If the expression contains literal numbers or parameters with undeclared
   * units, libSBML may not be able to compute the full units of the
   * expression and will only return what it can compute.  Callers should
   * always use EventAssignment::containsUndeclaredUnits() when using
   * EventAssignment::getDerivedUnitDefinition() to decide whether the
   * returned units may be incomplete.
   * 
   * @return @c true if the math expression of this EventAssignment
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by EventAssignment::getDerivedUnitDefinition() may not
   * accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits();


  /**
   * Predicate returning @c true if the math expression of this
   * EventAssignment contains literal numbers or parameters with undeclared
   * units.
   *
   * @copydetails doc_eventassignment_units
   *
   * If the expression contains literal numbers or parameters with undeclared
   * units, libSBML may not be able to compute the full units of the
   * expression and will only return what it can compute.  Callers should
   * always use EventAssignment::containsUndeclaredUnits() when using
   * EventAssignment::getDerivedUnitDefinition() to decide whether the
   * returned units may be incomplete.
   * 
   * @return @c true if the math expression of this EventAssignment
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by EventAssignment::getDerivedUnitDefinition() may not
   * accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits() const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_EVENT_ASSIGNMENT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for
   * EventAssignment, is always @c "eventAssignment".
   * 
   * @return the name of this element, i.e., @c "eventAssignment". 
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
   * EventAssignment object have been set.
   *
   * The required attributes for a EventAssignment object are:
   * @li "variable"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const;


  /**
   * Predicate returning @c true if all the required elements for this
   * EventAssignment object have been set.
   *
   * @note The required elements for a EventAssignment object are:
   * @li "math"
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const ;


  /** @cond doxygenLibsbmlInternal */
  /*
   * Return the variable attribute of this object.
   *
   * @note This function is an alias of getVariable() function.
   *       (id attribute is not defined in EventAssignment element.)
   *
   * @return the string of variable attribute of this object.
   *
   * @see getVariable()
   */
  virtual const std::string& getId() const;
  /** @endcond */


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * @copydoc doc_renameunitsidref_common
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Replace all nodes with the name 'id' from the child 'math' object with the provided function. 
   */
  virtual void replaceSIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */
  /**
   * If this assignment assigns a value to the 'id' element, replace the 'math' object with the function (existing/function). 
   */
  virtual void divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */
  /**
   * If this assignment assigns a value to the 'id' element, replace the 'math' object with the function (existing*function). 
   */
  virtual void multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Subclasses should override this method to read (and store) XHTML,
   * MathML, etc. directly from the XMLInputStream.
   *
   * @return true if the subclass read from the stream, false otherwise.
   */
  virtual bool readOtherXML (XMLInputStream& stream);


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

  void readL2Attributes (const XMLAttributes& attributes);
  
  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;


  std::string  mVariable;
  ASTNode*     mMath;

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
  friend class MathMLConsistencyValidator;
  friend class ModelingPracticeValidator;
  friend class OverdeterminedValidator;
  friend class SBOConsistencyValidator;
  friend class UnitConsistencyValidator;

  /** @endcond */
};



class LIBSBML_EXTERN ListOfEventAssignments : public ListOf
{
public:

  /**
   * Creates a new ListOfEventAssignments object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfEventAssignments (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfEventAssignments object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfEventAssignments object to be created.
   */
  ListOfEventAssignments (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfEventAssignments object.
   *
   * @return the (deep) copy of this ListOfEventAssignments object.
   */
  virtual ListOfEventAssignments* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., EventAssignment objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf:
   * @sbmlconstant{SBML_EVENT_ASSIGNMENT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfEventAssignments, the XML element name is @c
   * "listOfEventAssignments".
   * 
   * @return the name of this element, i.e., @c "listOfEventAssignments".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a EventAssignment from the ListOfEventAssignments.
   *
   * @param n the index number of the EventAssignment to get.
   * 
   * @return the nth EventAssignment in this ListOfEventAssignments.
   *
   * @see size()
   */
  virtual EventAssignment * get(unsigned int n); 


  /**
   * Get a EventAssignment from the ListOfEventAssignments.
   *
   * @param n the index number of the EventAssignment to get.
   * 
   * @return the nth EventAssignment in this ListOfEventAssignments.
   *
   * @see size()
   */
  virtual const EventAssignment * get(unsigned int n) const; 

  /**
   * Get a EventAssignment from the ListOfEventAssignments
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the EventAssignment to get.
   * 
   * @return EventAssignment in this ListOfEventAssignments
   * with the given @p sid or @c NULL if no such
   * EventAssignment exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual EventAssignment* get (const std::string& sid);


  /**
   * Get a EventAssignment from the ListOfEventAssignments
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the EventAssignment to get.
   * 
   * @return EventAssignment in this ListOfEventAssignments
   * with the given @p sid or @c NULL if no such
   * EventAssignment exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const EventAssignment* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfEventAssignments items and returns
   * a pointer to it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual EventAssignment* remove (unsigned int n);


  /**
   * Removes item in this ListOfEventAssignments items with the given
   * identifier.
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
  virtual EventAssignment* remove (const std::string& sid);


  /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * Note that EventAssignments do not actually have IDs, but the libsbml
   * interface pretends that they do: no event assignment is returned by this
   * function.
   *
   * @param id string representing the id of objects to find
   *
   * @return pointer to the first element found with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);
  
  
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
 * Creates a new EventAssignment_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * EventAssignment_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * EventAssignment_t
 *
 * @return a pointer to the newly created EventAssignment_t structure.
 *
 * @note Once a EventAssignment_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the EventAssignment_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
EventAssignment_t *
EventAssignment_create (unsigned int level, unsigned int version);


/**
 * Creates a new EventAssignment_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this EventAssignment_t
 *
 * @return a pointer to the newly created EventAssignment_t structure.
 *
 * @note Once a EventAssignment_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the EventAssignment_t.  Despite this, the ability to supply the values at 
 * creation time is an important aid to creating valid SBML.  Knowledge of the 
 * intended SBML Level and Version determine whether it is valid to assign a 
 * particular value to an attribute, or whether it is valid to add a structure to 
 * an existing SBMLDocument_t.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
EventAssignment_t *
EventAssignment_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given EventAssignment_t structure.
 *
 * @param ea the EventAssignment_t to be freed.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
void
EventAssignment_free (EventAssignment_t *ea);


/**
 * Creates a (deep) copy of the given EventAssignment_t structure.
 *
 * @param ea the EventAssignment_t to be copied
 * 
 * @return a (deep) copy of @p ea.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
EventAssignment_t *
EventAssignment_clone (const EventAssignment_t *ea);


/**
 * Returns a list of XMLNamespaces_t associated with this EventAssignment_t
 * structure.
 *
 * @param ea the EventAssignment_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
EventAssignment_getNamespaces(EventAssignment_t *ea);


/**
 * Gets the value of the "variable" attribute of this EventAssignment_t
 * structure.
 *
 * @param ea the EventAssignment_t structure to query.
 *
 * @return the identifier stored in the "variable" attribute of @p ea.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
const char *
EventAssignment_getVariable (const EventAssignment_t *ea);


/**
 * Gets the mathematical formula stored in the given EventAssignment_t
 * structure.
 *
 * @param ea the EventAssignment_t structure to query.
 *
 * @return the ASTNode_t tree stored in @p ea.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
const ASTNode_t *
EventAssignment_getMath (const EventAssignment_t *ea);


/**
 * Predicate for testing whether the attribute "variable" of the
 * given EventAssignment_t structure is set.
 *
 * @param ea the EventAssignment_t structure to query.
 * 
 * @return nonzero (for true) if the "variable" attribute of @p ea
 * is set, zero (0) otherwise.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
int
EventAssignment_isSetVariable (const EventAssignment_t *ea);


/**
 * Predicate for testing whether the attribute "variable" of the
 * given EventAssignment_t structure is set.
 *
 * @param ea the EventAssignment_t structure to query.
 * 
 * @return nonzero (for true) if the "variable" attribute of @p ea
 * is set, zero (0) otherwise.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
int
EventAssignment_isSetMath (const EventAssignment_t *ea);


/**
 * Sets the attribute "variable" of the given EventAssignment_t structure
 * to a copy of the given identifier string.
 *
 * @param ea the EventAssignment_t to set.
 * @param sid the identifier of a Compartment_t, Species_t or (global)
 * Parameter_t defined in this model.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "variable" attribute.
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
int
EventAssignment_setVariable (EventAssignment_t *ea, const char *sid);


/**
 * Sets the "math" subelement content of the given EventAssignment_t
 * structure to the given ASTNode_t.
 *
 * The given @p math ASTNode_t is copied.
 *
 * @param ea the EventAssignment_t to set.
 * @param math the ASTNode_t to copy into @p ea
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
int
EventAssignment_setMath (EventAssignment_t *ea, const ASTNode_t *math);


/**
 * Calculates and returns a UnitDefinition_t that expresses the units
 * returned by the math expression of this EventAssignment_t.
 *
 * @return a UnitDefinition_t that expresses the units of the math 
 * expression of this EventAssignment_t.
 *
 * Note that the functionality that facilitates unit analysis depends 
 * on the model as a whole.  Thus, in cases where the structure has not 
 * been added to a model or the model itself is incomplete,
 * unit analysis is not possible and this method will return @c NULL.
 *
 * @note The units are calculated by applying the mathematics 
 * from the expression to the units of the &lt;ci&gt; elements used 
 * within the expression. Where there are parameters/numbers
 * with undeclared units the UnitDefinition_t returned by this
 * function may not accurately represent the units of the expression.
 *
 * @see EventAssignment_containsUndeclaredUnits()
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
EventAssignment_getDerivedUnitDefinition(EventAssignment_t *ea);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the math expression of this EventAssignment_t contains
 * parameters/numbers with undeclared units.
 * 
 * @return @c true if the math expression of this EventAssignment_t
 * includes parameters/numbers 
 * with undeclared units, @c false otherwise.
 *
 * @note a return value of @c true indicates that the UnitDefinition_t
 * returned by the getDerivedUnitDefinition function may not 
 * accurately represent the units of the expression.
 *
 * @see EventAssignment_getDerivedUnitDefinition()
 *
 * @memberof EventAssignment_t
 */
LIBSBML_EXTERN
int 
EventAssignment_containsUndeclaredUnits(EventAssignment_t *ea);


/**
 * Returns the EventAssignment_t structure having a given identifier.
 *
 * @param lo the ListOfEventAssignments_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfEventAssignments with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfEventAssignments_t
 */
LIBSBML_EXTERN
EventAssignment_t *
ListOfEventAssignments_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a EventAssignment_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of EventAssignment_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The EventAssignment_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfEventAssignments_t
 */
LIBSBML_EXTERN
EventAssignment_t *
ListOfEventAssignments_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* EventAssignment_h */
