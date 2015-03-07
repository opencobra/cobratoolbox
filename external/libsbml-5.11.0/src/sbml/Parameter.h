/**
 * @file    Parameter.h
 * @brief   Definitions of Parameter and ListOfParameters.
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
 * ------------------------------------------------------------------------ -->
 * 
 * @class Parameter.
 * @sbmlbrief{core} An SBML parameter: a named symbol with a value.
 *
 * A Parameter is used in SBML to define a symbol associated with a value;
 * this symbol can then be used in mathematical formulas in a model.  By
 * default, parameters have constant value for the duration of a
 * simulation, and for this reason are called @em parameters instead of @em
 * variables in SBML, although it is crucial to understand that <em>SBML
 * parameters represent both concepts</em>.  Whether a given SBML
 * parameter is intended to be constant or variable is indicated by the
 * value of its "constant" attribute.
 * 
 * SBML's Parameter has a required attribute, "id", that gives the
 * parameter a unique identifier by which other parts of an SBML model
 * definition can refer to it.  A parameter can also have an optional
 * "name" attribute of type @c string.  Identifiers and names must be used
 * according to the guidelines described in the SBML specifications.
 * 
 * The optional attribute "value" determines the value (of type @c double)
 * assigned to the parameter.  A missing value for "value" implies that
 * the value either is unknown, or to be obtained from an external source,
 * or determined by an initial assignment.  The unit of measurement
 * associated with the value of the parameter can be specified using the
 * optional attribute "units".  Here we only mention briefly some notable
 * points about the possible unit choices, but readers are urged to consult
 * the SBML specification documents for more information:
 * <ul>
 *
 * <li> In SBML Level&nbsp;3, there are no constraints on the units that
 * can be assigned to parameters in a model; there are also no units to
 * inherit from the enclosing Model object (unlike the case for, e.g.,
 * Species and Compartment).
 *
 * <li> In SBML Level&nbsp;2, the value assigned to the parameter's "units"
 * attribute must be chosen from one of the following possibilities: one of
 * the base unit identifiers defined in SBML; one of the built-in unit
 * identifiers @c "substance", @c "time", @c "volume", @c "area" or @c
 * "length"; or the identifier of a new unit defined in the list of unit
 * definitions in the enclosing Model structure.  There are no constraints
 * on the units that can be chosen from these sets.  There are no default
 * units for parameters.
 * </ul>
 *
 * The Parameter structure has another boolean attribute named "constant"
 * that is used to indicate whether the parameter's value can vary during a
 * simulation.  (In SBML Level&nbsp;3, the attribute is mandatory and must
 * be given a value; in SBML Levels below Level&nbsp;3, the attribute is
 * optional.)  A value of @c true indicates the parameter's value cannot be
 * changed by any construct except InitialAssignment.  Conversely, if the
 * value of "constant" is @c false, other constructs in SBML, such as rules
 * and events, can change the value of the parameter.
 *
 * SBML Level&nbsp;3 uses a separate object class, LocalParameter, for
 * parameters that are local to a Reaction's KineticLaw.  In Levels prior
 * to SBML Level&nbsp;3, the Parameter class is used both for definitions
 * of global parameters, as well as reaction-local parameters stored in a
 * list within KineticLaw objects.  Parameter objects that are local to a
 * reaction (that is, those defined within the KineticLaw structure of a
 * Reaction) cannot be changed by rules and therefore are <em>implicitly
 * always constant</em>; consequently, in SBML Level&nbsp;2, parameter
 * definitions within Reaction structures should @em not have their
 * "constant" attribute set to @c false.
 * 
 * What if a global parameter has its "constant" attribute set to @c false,
 * but the model does not contain any rules, events or other constructs
 * that ever change its value over time?  Although the model may be
 * suspect, this situation is not strictly an error.  A value of @c false
 * for "constant" only indicates that a parameter @em can change value, not
 * that it @em must.
 *
 * As with all other major SBML components, Parameter is derived from
 * SBase, and the methods defined on SBase are available on Parameter.
 * 
 * @note The use of the term @em parameter in SBML sometimes leads to
 * confusion among readers who have a particular notion of what something
 * called "parameter" should be.  It has been the source of heated debate,
 * but despite this, no one has yet found an adequate replacement term that
 * does not have different connotations to different people and hence leads
 * to confusion among @em some subset of users.  Perhaps it would have been
 * better to have two constructs, one called @em constants and the other
 * called @em variables.  The current approach in SBML is simply more
 * parsimonious, using a single Parameter construct with the boolean flag
 * "constant" indicating which flavor it is.  In any case, readers are
 * implored to look past their particular definition of a @em parameter and
 * simply view SBML's Parameter as a single mechanism for defining both
 * constants and (additional) variables in a model.  (We write @em
 * additional because the species in a model are usually considered to be
 * the central variables.)  After all, software tools are not required to
 * expose to users the actual names of particular SBML constructs, and
 * thus tools can present to their users whatever terms their designers
 * feel best matches their target audience.
 *
 * @see ListOfParameters
 *
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfParameters
 * @sbmlbrief{core} A list of Parameter objects.
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
 * @class doc_note_parameter_about_constant
 *
 * @note Readers who view the documentation for LocalParameter may be
 * confused about the presence of this method.  LibSBML derives
 * LocalParameter from Parameter; however, this does not precisely match
 * the object hierarchy defined by SBML Level&nbsp;3, where
 * LocalParameter is derived directly from SBase and not Parameter.  We
 * believe this arrangement makes it easier for libSBML users to program
 * applications that work with both SBML Level&nbsp;2 and SBML
 * Level&nbsp;3, but programmers should also keep in mind this difference
 * exists.  A side-effect of libSBML's scheme is that certain methods on
 * LocalParameter that are inherited from Parameter do not actually have
 * relevance to LocalParameter objects.  An example of this is the
 * methods pertaining to Parameter's attribute "constant" (i.e.,
 * isSetConstant(), setConstant(), and getConstant()).
 *
 */

#ifndef Parameter_h
#define Parameter_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>


#ifdef __cplusplus


#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;
class UnitFormulaFormatter;


class LIBSBML_EXTERN Parameter : public SBase
{
public:

  /**
   * Creates a new Parameter using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Parameter
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Parameter
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Parameter (unsigned int level, unsigned int version);


  /**
   * Creates a new Parameter using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * It is worth emphasizing that although this constructor does not take
   * an identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a Parameter is required to have a value.
   * Thus, callers are cautioned to assign a value after calling this
   * constructor if no identifier is provided as an argument.  Setting the
   * identifier can be accomplished using the method
   * @if java setId(String id)@else setId()@endif.
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
  Parameter (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Parameter.
   */
  virtual ~Parameter ();


  /**
   * Copy constructor; creates a copy of a Parameter.
   * 
   * @param orig the Parameter instance to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Parameter(const Parameter& orig);


  /**
   * Assignment operator for Parameter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Parameter& operator=(const Parameter& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Parameter.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, indicating
   * whether the Visitor would like to visit the next Parameter object in
   * the list of parameters within which @em the present object is
   * embedded.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Parameter object.
   *
   * @return the (deep) copy of this Parameter object.
   */
  virtual Parameter* clone () const;


  /**
   * Initializes the fields of this Parameter object to "typical" defaults
   * values.
   *
   * The SBML Parameter component has slightly different aspects and
   * default attribute values in different SBML Levels and Versions.  Many
   * SBML object classes defined by libSBML have an initDefaults() method
   * to set the values to certain common defaults, based mostly on what
   * they are in SBML Level&nbsp;2.  In the case of Parameter, this method
   * only sets the value of the "constant" attribute to @c true.
   *
   * @see getConstant()
   * @see isSetConstant()
   * @see setConstant(@if java boolean@endif)
   */
  void initDefaults ();

  
  /**
   * Returns the value of the "id" attribute of this Parameter.
   * 
   * @return the id of this Parameter.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this Parameter.
   * 
   * @return the name of this Parameter.
   */
  virtual const std::string& getName () const;


  /**
   * Gets the numerical value of this Parameter.
   * 
   * @return the value of the "value" attribute of this Parameter, as a
   * number of type @c double.
   *
   * @note <b>It is crucial</b> that callers not blindly call
   * Parameter::getValue() without first using Parameter::isSetValue() to
   * determine whether a value has ever been set.  Otherwise, the value
   * return by Parameter::getValue() may not actually represent a value
   * assigned to the parameter.  The reason is simply that the data type
   * @c double in a program always has @em some value.  A separate test is
   * needed to determine whether the value is a true model value, or
   * uninitialized data in a computer's memory location.
   * 
   * @see isSetValue()
   * @see setValue(double value)
   * @see getUnits()
   */
  double getValue () const;


  /**
   * Gets the units defined for this Parameter.
   *
   * The value of an SBML parameter's "units" attribute establishes the
   * unit of measurement associated with the parameter's value.
   *
   * @return the value of the "units" attribute of this Parameter, as a
   * string.  An empty string indicates that no units have been assigned.
   *
   * @copydetails doc_note_unassigned_unit_are_not_a_default
   * 
   * @see isSetUnits()
   * @see setUnits(@if java String@endif)
   * @see getValue()
   */
  const std::string& getUnits () const;


  /**
   * Gets the value of the "constant" attribute of this Parameter instance.
   * 
   * @return @c true if this Parameter is declared as being constant,
   * @c false otherwise.
   *
   * @copydetails doc_note_parameter_about_constant
   * 
   * @see isSetConstant()
   * @see setConstant(@if java boolean@endif)
   */
  virtual bool getConstant () const;


  /**
   * Predicate returning @c true if this
   * Parameter's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this Parameter is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * Parameter's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this Parameter is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if the
   * "value" attribute of this Parameter is set.
   *
   * In SBML definitions after SBML Level&nbsp;1 Version&nbsp;1,
   * parameter values are optional and have no defaults.  If a model read
   * from a file does not contain a setting for the "value" attribute of a
   * parameter, its value is considered unset; it does not default to any
   * particular value.  Similarly, when a Parameter object is created in
   * libSBML, it has no value until given a value.  The
   * Parameter::isSetValue() method allows calling applications to
   * determine whether a given parameter's value has ever been set.
   *
   * In SBML Level&nbsp;1 Version&nbsp;1, parameters are required to have
   * values and therefore, the value of a Parameter <b>should always be
   * set</b>.  In Level&nbsp;1 Version&nbsp;2 and beyond, the value is
   * optional and as such, the "value" attribute may or may not be set.
   *
   * @return @c true if the value of this Parameter is set,
   * @c false otherwise.
   *
   * @see getValue()
   * @see setValue(double value)
   */
  bool isSetValue () const;


  /**
   * Predicate returning @c true if the
   * "units" attribute of this Parameter is set.
   *
   * @return @c true if the "units" attribute of this Parameter is
   * set, @c false otherwise.
   *
   * @copydetails doc_note_unassigned_unit_are_not_a_default
   */
  bool isSetUnits () const;


  /**
   * Predicate returning @c true if the
   * "constant" attribute of this Parameter is set.
   *
   * @return @c true if the "constant" attribute of this Parameter is
   * set, @c false otherwise.
   *
   * @copydetails doc_note_parameter_about_constant
   *
   * @see getConstant()
   * @see setConstant(@if java boolean@endif)
   */
  virtual bool isSetConstant () const;


  /**
   * Sets the value of the "id" attribute of this Parameter.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this Parameter
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this Parameter.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the Parameter
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setName (const std::string& name);


  /**
   * Sets the "value" attribute of this Parameter to the given @c double
   * value and marks the attribute as set.
   *
   * @param value a @c double, the value to assign
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue (double value);


  /**
   * Sets the "units" attribute of this Parameter to a copy of the given
   * units identifier @p units.
   *
   * @param units a string, the identifier of the units to assign to this
   * Parameter instance
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setUnits (const std::string& units);


  /**
   * Sets the "constant" attribute of this Parameter to the given boolean
   * @p flag.
   *
   * @param flag a boolean, the value for the "constant" attribute of this
   * Parameter instance
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_note_parameter_about_constant
   *
   * @see getConstant()
   * @see isSetConstant()
   */
  virtual int setConstant (bool flag);


  /**
   * Unsets the value of the "name" attribute of this Parameter.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Unsets the "value" attribute of this Parameter instance.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * In SBML Level&nbsp;1 Version&nbsp;1, parameters are required to have
   * values and therefore, the value of a Parameter <b>should always be
   * set</b>.  In SBML Level&nbsp;1 Version&nbsp;2 and beyond, the value
   * is optional and as such, the "value" attribute may or may not be set.
   */
  int unsetValue ();


  /**
   * Unsets the "units" attribute of this Parameter instance.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetUnits ();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Parameter's value.
   *
   * Parameters in SBML have an attribute ("units") for declaring the units
   * of measurement intended for the parameter's value.  <b>No defaults are
   * defined</b> by SBML in the absence of a definition for "units".  This
   * method returns a UnitDefinition object based on the units declared for
   * this Parameter using its "units" attribute, or it returns @c NULL if
   * no units have been declared.
   *
   * Note that unit declarations for Parameter objects are specified in
   * terms of the @em identifier of a unit (e.g., using setUnits()), but
   * @em this method returns a UnitDefinition object, not a unit
   * identifier.  It does this by constructing an appropriate
   * UnitDefinition.For SBML Level&nbsp;2 models, it will do this even when
   * the value of the "units" attribute is one of the special SBML
   * Level&nbsp;2 unit identifiers @c "substance", @c "volume", @c "area",
   * @c "length" or @c "time".  Callers may find this useful in conjunction
   * with the helper methods provided by the UnitDefinition class for
   * comparing different UnitDefinition objects.
   *
   * @return a UnitDefinition that expresses the units of this 
   * Parameter, or @c NULL if one cannot be constructed.
   *
   * @note The libSBML system for unit analysis depends on the model as a
   * whole.  In cases where the Parameter object has not yet been added to
   * a model, or the model itself is incomplete, unit analysis is not
   * possible, and consequently this method will return @c NULL.
   *
   * @see isSetUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this Parameter's value.
   *
   * Parameters in SBML have an attribute ("units") for declaring the units
   * of measurement intended for the parameter's value.  <b>No defaults are
   * defined</b> by SBML in the absence of a definition for "units".  This
   * method returns a UnitDefinition object based on the units declared for
   * this Parameter using its "units" attribute, or it returns @c NULL if
   * no units have been declared.
   *
   * Note that unit declarations for Parameter objects are specified in
   * terms of the @em identifier of a unit (e.g., using setUnits()), but
   * @em this method returns a UnitDefinition object, not a unit
   * identifier.  It does this by constructing an appropriate
   * UnitDefinition.  For SBML Level&nbsp;2 models, it will do this even
   * when the value of the "units" attribute is one of the predefined SBML
   * units @c "substance", @c "volume", @c "area", @c "length" or @c
   * "time".  Callers may find this useful in conjunction with the helper
   * methods provided by the UnitDefinition class for comparing different
   * UnitDefinition objects.
   *
   * @return a UnitDefinition that expresses the units of this 
   * Parameter, or @c NULL if one cannot be constructed.
   *
   * @note The libSBML system for unit analysis depends on the model as a
   * whole.  In cases where the Parameter object has not yet been added to
   * a model, or the model itself is incomplete, unit analysis is not
   * possible, and consequently this method will return @c NULL.
   * 
   * @see isSetUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Returns the libSBML type code for this SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_PARAMETER, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Parameter, is
   * always @c "parameter".
   * 
   * @return the name of this element, i.e., @c "parameter".
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
   * all the required attributes for this Parameter object
   * have been set.
   *
   * The required attributes for a Parameter object are:
   * @li "id" (or "name" in SBML Level&nbsp;1)
   * @li "value" (required in Level&nbsp;1, optional otherwise)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


  /**
   * Renames all the @c UnitSIdRef attributes on this element.
   *
   * @copydetails doc_what_is_unitsidref
   *
   * This method works by looking at all unit identifier attribute values
   * (including, if appropriate, inside mathematical formulas), comparing the
   * unit identifiers to the value of @p oldid.  If any matches are found,
   * the matching identifiers are replaced with @p newid.  The method does
   * @em not descend into child elements.
   * 
   * @param oldid the old identifier
   * @param newid the new identifier
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */

  /* set a flag to indicate that a parameter should 
   * calculate its units from math */
  virtual void setCalculatingUnits(bool calculatingUnits);
  
  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  Parameter (SBMLNamespaces* sbmlns, bool isLocal);

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

  bool isExplicitlySetConstant() const 
                            { return mExplicitlySetConstant; } ;

  std::string  mId;
  std::string  mName;
  double       mValue;
  std::string  mUnits;
  bool         mConstant;

  bool mIsSetValue;
  bool mIsSetConstant;

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
  friend class MathMLConsistencyValidator;
  friend class ModelingPracticeValidator;
  friend class OverdeterminedValidator;
  friend class SBOConsistencyValidator;
  friend class UnitConsistencyValidator;

  /** @endcond */


private:
  
  /** @cond doxygenLibsbmlInternal */
  
  UnitDefinition * inferUnits(Model* m, bool globalParameter);

  UnitDefinition * inferUnitsFromAssignments(UnitFormulaFormatter *uff, 
                                             Model *m);
  
  UnitDefinition * inferUnitsFromRules(UnitFormulaFormatter *uff, 
                                             Model *m);

  UnitDefinition * inferUnitsFromReactions(UnitFormulaFormatter *uff, 
                                             Model *m);

  UnitDefinition * inferUnitsFromEvents(UnitFormulaFormatter *uff, 
                                             Model *m);

  UnitDefinition * inferUnitsFromEvent(Event * e, UnitFormulaFormatter *uff, 
                                             Model *m);
  
  UnitDefinition * inferUnitsFromKineticLaw(KineticLaw* kl,
                  UnitFormulaFormatter *uff, Model *m);
  
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  /* flag to indicate that a parameter should calculate its units from math */
  bool getCalculatingUnits() const;
  
  bool mCalculatingUnits;

  /** @endcond */

};


class LIBSBML_EXTERN ListOfParameters : public ListOf
{
public:

  /**
   * Creates a new ListOfParameters object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfParameters (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfParameters object.
   * 
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfParameters object to be created.
   */
  ListOfParameters (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfParameters object.
   *
   * @return the (deep) copy of this ListOfParameters object.
   */
  virtual ListOfParameters* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Parameter objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this objects contained in this list:
   * @sbmlconstant{SBML_PARAMETER, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfParameters, the XML element name is @c "listOfParameters".
   * 
   * @return the name of this element, i.e., @c "listOfParameters".
   */
  virtual const std::string& getElementName () const;


  /**
   * Returns the Parameter object located at position @p n within this
   * ListOfParameters instance.
   *
   * @param n the index number of the Parameter to get.
   * 
   * @return the nth Parameter in this ListOfParameters.  If the index @p n
   * is out of bounds for the length of the list, then @c NULL is returned.
   *
   * @see size()
   * @see get(const std::string& sid)
   */
  virtual Parameter * get(unsigned int n); 


  /**
   * Returns the Parameter object located at position @p n within this
   * ListOfParameters instance.
   *
   * @param n the index number of the Parameter to get.
   * 
   * @return the nth Parameter in this ListOfParameters.  If the index @p n
   * is out of bounds for the length of the list, then @c NULL is returned.
   *
   * @see size()
   * @see get(const std::string& sid)
   */
  virtual const Parameter * get(unsigned int n) const; 


  /**
   * Returns the first Parameter object matching the given identifier.
   *
   * @param sid a string, the identifier of the Parameter to get.
   * 
   * @return the Parameter object found.  The caller owns the returned
   * object and is responsible for deleting it.  If none of the items have
   * an identifier matching @p sid, then @c NULL is returned.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Parameter* get (const std::string& sid);


  /**
   * Returns the first Parameter object matching the given identifier.
   *
   * @param sid a string representing the identifier of the Parameter to
   * get.
   * 
   * @return the Parameter object found.  The caller owns the returned
   * object and is responsible for deleting it.  If none of the items have
   * an identifier matching @p sid, then @c NULL is returned.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Parameter* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfParameters, and returns a pointer
   * to it.
   *
   * @param n the index of the item to remove
   *
   * @return the item removed.  The caller owns the returned object and is
   * responsible for deleting it.  If the index number @p n is out of
   * bounds for the length of the list, then @c NULL is returned.
   *
   * @see size()
   */
  virtual Parameter* remove (unsigned int n);


  /**
   * Removes the first Parameter object in this ListOfParameters
   * matching the given identifier, and returns a pointer to it.
   *
   * @param sid the identifier of the item to remove.
   *
   * @return the item removed.  The caller owns the returned object and is
   * responsible for deleting it.  If none of the items have an identifier
   * matching @p sid, then @c NULL is returned.
   */
  virtual Parameter* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Gets the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfParameters
   * in a model is (in SBML Level&nbsp;2 Version&nbsp;4) the seventh
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
   * Create a ListOfParameters object corresponding to the next token in
   * the XML input stream.
   * 
   * @return the SBML object corresponding to next XMLToken in the
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
 * Creates a new Parameter_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Parameter_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Parameter_t
 *
 * @return a pointer to the newly created Parameter_t structure.
 *
 * @note Once a Parameter_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Parameter_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
Parameter_t *
Parameter_create (unsigned int level, unsigned int version);


/**
 * Creates a new Parameter_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this Parameter_t
 *
 * @return a pointer to the newly created Parameter_t structure.
 *
 * @note Once a Parameter_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Parameter_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
Parameter_t *
Parameter_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Parameter_t structure.
 *
 * @param p the Parameter_t structure to be freed.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
void
Parameter_free (Parameter_t *p);


/**
 * Creates a deep copy of the given Parameter_t structure
 * 
 * @param p the Parameter_t structure to be copied
 * 
 * @return a (deep) copy of the given Parameter_t structure.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
Parameter_t *
Parameter_clone (const Parameter_t *p);


/**
 * Initializes the attributes of this Parameter_t structure to their defaults.
 *
 * The exact results depends on the %SBML Level and Version in use.  The
 * cases are currently the following:
 * 
 * @li (%SBML Level 2 only) constant = 1 (true)
 *
 * @param p the Parameter_t structure to initialize
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
void
Parameter_initDefaults (Parameter_t *p);


/**
 * Returns a list of XMLNamespaces_t associated with this Parameter_t
 * structure.
 *
 * @param p the Parameter_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Parameter_getNamespaces(Parameter_t *p);


/**
 * Takes a Parameter_t structure and returns its identifier.
 *
 * @param p the Parameter_t structure whose identifier is sought
 * 
 * @return the identifier of this Parameter_t, as a pointer to a string.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
const char *
Parameter_getId (const Parameter_t *p);


/**
 * Takes a Parameter_t structure and returns its name.
 *
 * @param p the Parameter_t whose name is sought.
 *
 * @return the name of this Parameter_t, as a pointer to a string.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
const char *
Parameter_getName (const Parameter_t *p);


/**
 * Takes a Parameter_t structure and returns its value.
 *
 * @param p the Parameter_t whose value is sought.
 *
 * @return the value assigned to this Parameter_t structure, as a @c double.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
double
Parameter_getValue (const Parameter_t *p);


/**
 * Takes a Parameter_t structure and returns its units.
 *
 * @param p the Parameter_t whose units are sought.
 *
 * @return the units assigned to this Parameter_t structure, as a pointer
 * to a string.  
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
const char *
Parameter_getUnits (const Parameter_t *p);


/**
 * Takes a Parameter_t structure and returns zero or nonzero, depending
 * on the value of the parameter's "constant" attribute.
 *
 * @param p the Parameter_t whose constant value is sought.
 *
 * @return the value of the "constant" attribute, with nonzero meaning
 * true and zero meaning false.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_getConstant (const Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Parameter_t structure's identifier is set.
 *
 * @param p the Parameter_t structure to query
 * 
 * @return @c non-zero (true) if the "id" attribute of the given
 * Parameter_t structure is set, zero (false) otherwise.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_isSetId (const Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Parameter_t structure's name is set.
 *
 * @param p the Parameter_t structure to query
 * 
 * @return @c non-zero (true) if the "name" attribute of the given
 * Parameter_t structure is set, zero (false) otherwise.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_isSetName (const Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Parameter_t structure's value is set.
 * 
 * @param p the Parameter_t structure to query
 * 
 * @return @c non-zero (true) if the "value" attribute of the given
 * Parameter_t structure is set, zero (false) otherwise.
 *
 * @note In SBML Level 1 Version 1, a Parameter_t value is required and
 * therefore <em>should always be set</em>.  In Level 1 Version 2 and
 * later, the value is optional, and as such, may or may not be set.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_isSetValue (const Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Parameter_t structure's units have been set.
 *
 * @param p the Parameter_t structure to query
 * 
 * @return @c non-zero (true) if the "units" attribute of the given
 * Parameter_t structure is set, zero (false) otherwise.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_isSetUnits (const Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Parameter_t structure's constant attribute have been set.
 *
 * @param p the Parameter_t structure to query
 * 
 * @return @c non-zero (true) if the "constant" attribute of the given
 * Parameter_t structure is set, zero (false) otherwise.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_isSetConstant (const Parameter_t *p);


/**
 * Assigns the identifier of a Parameter_t structure.
 *
 * This makes a copy of the string passed in the param @p sid.
 *
 * @param p the Parameter_t structure to set.
 * @param sid the string to use as the identifier.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_setId (Parameter_t *p, const char *sid);


/**
 * Assign the name of a Parameter_t structure.
 *
 * This makes a copy of the string passed in as the argument @p name.
 *
 * @param p the Parameter_t structure to set.
 * @param name the string to use as the name.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_setName (Parameter_t *p, const char *name);


/**
 * Assign the value of a Parameter_t structure.
 *
 * @param p the Parameter_t structure to set.
 * @param value the @c double value to use.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_setValue (Parameter_t *p, double value);


/**
 * Assign the units of a Parameter_t structure.
 *
 * This makes a copy of the string passed in as the argument @p units.
 *
 * @param p the Parameter_t structure to set.
 * @param units the string to use as the identifier of the units to assign.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units set to NULL is equivalent to
 * unsetting the "units" attribute.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_setUnits (Parameter_t *p, const char *units);


/**
 * Assign the "constant" attribute of a Parameter_t structure.
 *
 * @param p the Parameter_t structure to set.
 * @param value the value to assign as the "constant" attribute
 * of the parameter, either zero for false or nonzero for true.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_setConstant (Parameter_t *p, int value);


/**
 * Unsets the name of this Parameter_t structure.
 * 
 * @param p the Parameter_t structure whose name is to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_unsetName (Parameter_t *p);


/**
 * Unsets the value of this Parameter_t structure.
 *
 * In SBML Level 1 Version 1, a parameter is required to have a value and
 * therefore this attribute <em>should always be set</em>.  In Level 1
 * Version 2 and beyond, a value is optional, and as such, may or may not be
 * set.
 *
 * @param p the Parameter_t structure whose value is to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_unsetValue (Parameter_t *p);


/**
 * Unsets the units of this Parameter_t structure.
 * 
 * @param p the Parameter_t structure whose units are to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_unsetUnits (Parameter_t *p);


/**
 * Constructs and returns a UnitDefinition_t structure that expresses 
 * the units of this Parameter_t structure.
 *
 * @param p the Parameter_t structure whose units are to be returned.
 *
 * @return a UnitDefinition_t structure that expresses the units 
 * of this Parameter_t strucuture.
 *
 * @note This function returns the units of the Parameter_t expressed 
 * as a UnitDefinition_t. The units may be those explicitly declared. 
 * In the case where no units have been declared, @c NULL is returned.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
Parameter_getDerivedUnitDefinition(Parameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether
 * all the required attributes for this Parameter_t structure
 * have been set.
 *
 * The required attributes for a Parameter_t structure are:
 * @li id (name in L1)
 * @li constant (in L3 only)
 *
 * @param p the Parameter_t structure to check.
 *
 * @return a true if all the required
 * attributes for this structure have been defined, false otherwise.
 *
 * @memberof Parameter_t
 */
LIBSBML_EXTERN
int
Parameter_hasRequiredAttributes (Parameter_t *p);


/**
 * Returns the Parameter_t structure having a given identifier.
 *
 * @param lo the ListOfParameters_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfParameters with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfParameters_t
 */
LIBSBML_EXTERN
Parameter_t *
ListOfParameters_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a Parameter_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of Parameter_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The Parameter_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfParameters_t
 */
LIBSBML_EXTERN
Parameter_t *
ListOfParameters_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* Parameter_h */

