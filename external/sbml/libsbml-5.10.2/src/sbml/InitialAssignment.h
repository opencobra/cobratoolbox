/**
 * @file    InitialAssignment.h
 * @brief   Definitions of InitialAssignment and ListOfInitialAssignments
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
 * @class InitialAssignment
 * @sbmlbrief{core} An SBML <em>initial assignment</em>, evaluated once only.
 *
 * SBML Level 2 Versions 2&ndash;4 and SBML Level&nbsp;3 provide two ways of assigning initial
 * values to entities in a model.  The simplest and most basic is to set
 * the values of the appropriate attributes in the relevant components; for
 * example, the initial value of a model parameter (whether it is a
 * constant or a variable) can be assigned by setting its "value" attribute
 * directly in the model definition.  However, this approach is not
 * suitable when the value must be calculated, because the initial value
 * attributes on different components such as species, compartments, and
 * parameters are single values and not mathematical expressions.  In those
 * situations, the InitialAssignment construct can be used; it permits the
 * calculation of the value of a constant or the initial value of a
 * variable from the values of @em other quantities in a model.
 *
 * As explained below, the provision of InitialAssignment does not mean
 * that models necessarily must use this construct when defining initial
 * values of quantities in a model.  If a value can be set directly using
 * the relevant attribute of a component in a model, then that
 * approach may be more efficient and more portable to other software
 * tools.  InitialAssignment should be used when the other mechanism is
 * insufficient for the needs of a particular model.
 *
 * The InitialAssignment construct has some similarities to AssignmentRule.
 * The main differences are: (a) an InitialAssignment can set the value of
 * a constant whereas an AssignmentRule cannot, and (b) unlike
 * AssignmentRule, an InitialAssignment definition only applies up to and
 * including the beginning of simulation time, i.e., <em>t \f$\leq\f$ 0</em>,
 * while an AssignmentRule applies at all times.
 *
 * InitialAssignment has a required attribute, "symbol", whose value must
 * follow the guidelines for identifiers described in the %SBML
 * specification (e.g., Section 3.3 in the Level 2 Version 4
 * specification).  The value of this attribute in an InitialAssignment
 * object can be the identifier of a Compartment, Species or global
 * Parameter elsewhere in the model.  The InitialAssignment defines the
 * initial value of the constant or variable referred to by the "symbol"
 * attribute.  (The attribute's name is "symbol" rather than "variable"
 * because it may assign values to constants as well as variables in a
 * model.)  Note that an initial assignment cannot be made to reaction
 * identifiers, that is, the "symbol" attribute value of an
 * InitialAssignment cannot be an identifier that is the "id" attribute
 * value of a Reaction object in the model.  This is identical to a
 * restriction placed on rules.
 *
 * InitialAssignment also has a required "math" subelement that contains a
 * MathML expression used to calculate the value of the constant or the
 * initial value of the variable.  The units of the value computed by the
 * formula in the "math" subelement should (in SBML Level&nbsp;2
 * Version&nbsp;4 and in SBML Level&nbsp;3) or must (in previous Versions) be identical to be the
 * units associated with the identifier given in the "symbol" attribute.
 * (That is, the units are the units of the species, compartment, or
 * parameter, as appropriate for the kind of object identified by the value
 * of "symbol".)
 *
 * InitialAssignment was introduced in SBML Level 2 Version 2.  It is not
 * available in SBML Level&nbsp;2 Version&nbsp;1 nor in any version of Level 1.
 *
 * @section initassign-semantics Semantics of Initial Assignments
 * 
 * The value calculated by an InitialAssignment object overrides the value
 * assigned to the given symbol by the object defining that symbol.  For
 * example, if a compartment's "size" attribute is set in its definition,
 * and the model also contains an InitialAssignment having that
 * compartment's identifier as its "symbol" attribute value, then the
 * interpretation is that the "size" assigned in the Compartment object
 * should be ignored and the value assigned based on the computation
 * defined in the InitialAssignment.  Initial assignments can take place
 * for Compartment, Species and global Parameter objects regardless of the
 * value of their "constant" attribute.
 * 
 * The actions of all InitialAssignment objects are in general terms
 * the same, but differ in the precise details depending on the type
 * of variable being set:
 * <ul>
 * <li> <em>In the case of a species</em>, an InitialAssignment sets the
 * referenced species' initial quantity (concentration or amount of
 * substance) to the value determined by the formula in the "math"
 * subelement.    The overall units of the formula should (in SBML
 * Level&nbsp;2 Version&nbsp;4 and in SBML Level&nbsp;3) or must (in previous Versions) be the same
 * as the units specified for the species.
 * 
 * <li> <em>In the case of a compartment</em>, an InitialAssignment sets
 * the referenced compartment's initial size to the size determined by the
 * formula in "math".  The overall units of the formula should (in SBML
 * Level&nbsp;2 Version&nbsp;4 and in SBML Level&nbsp;3) or must (in previous Versions) be the same
 * as the units specified for the size of the compartment.
 * 
 * <li> <em>In the case of a parameter</em>, an InitialAssignment sets the
 * referenced parameter's initial value to that determined by the formula
 * in "math".  The overall units of the formula should (in SBML
 * Level&nbsp;2 Version&nbsp;4 and SBML Level&nbsp;3) or must (in previous Versions) be the same
 * as the units defined for the parameter.  </ul>
 * 
 * In the context of a simulation, initial assignments establish values
 * that are in effect prior to and including the start of simulation time,
 * i.e., <em>t \f$\leq\f$ 0</em>.  Section 3.4.8 in the SBML Level 2
 * Version 4  and SBML Level&nbsp;3 Version&nbsp;1 Core specifications provides information about the interpretation of
 * assignments, rules, and entity values for simulation time up to and
 * including the start time <em>t = 0</em>; this is important for
 * establishing the initial conditions of a simulation if the model
 * involves expressions containing the <em>delay</em> "csymbol".
 * 
 * There cannot be two initial assignments for the same symbol in a model;
 * that is, a model must not contain two or more InitialAssignment objects
 * that both have the same identifier as their "symbol" attribute value.  A
 * model must also not define initial assignments <em>and</em> assignment
 * rules for the same entity.  That is, there cannot be <em>both</em> an
 * InitialAssignment and an AssignmentRule for the same symbol in a model,
 * because both kinds of constructs apply prior to and at the start of
 * simulated time---allowing both to exist for a given symbol would
 * result in indeterminism).
 * 
 * The ordering of InitialAssignment objects is not significant.  The
 * combined set of InitialAssignment, AssignmentRule and KineticLaw
 * objects form a set of assignment statements that must be considered as a
 * whole.  The combined set of assignment statements should not contain
 * algebraic loops: a chain of dependency between these statements should
 * terminate.  (More formally, consider the directed graph of assignment
 * statements where nodes are a model's assignment statements and directed
 * arcs exist for each occurrence of a symbol in an assignment statement
 * "math" attribute.  The directed arcs in this graph start from the
 * statement assigning the symbol and end at the statement that contains
 * the symbol in their math elements.  Such a graph must be acyclic.)
 *
 * Finally, it is worth being explicit about the expected behavior in the
 * following situation.  Suppose (1) a given symbol has a value <em>x</em>
 * assigned to it in its definition, and (2) there is an initial assignment
 * having the identifier as its "symbol" value and reassigning the value to
 * <em>y</em>, <em>and</em> (3) the identifier is also used in the
 * mathematical formula of a second initial assignment.  What value should
 * the second initial assignment use?  It is <em>y</em>, the value assigned
 * to the symbol by the first initial assignment, not whatever value was
 * given in the symbol's definition.  This follows directly from the
 * behavior described above: if an InitialAssignment object exists for a
 * given symbol, then the symbol's value is overridden by that initial
 * assignment.
 *
 * <!---------------------------------------------------------------------- -->
 *
 * @class ListOfInitialAssignments
 * @sbmlbrief{core} A list of InitialAssignment objects.
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
 * @class doc_initialassignment_units
 *
 * @par
 * The units are calculated based on the mathematical expression in the
 * InitialAssignment and the model quantities referenced by
 * <code>&lt;ci&gt;</code> elements used within that expression.  The method
 * InitialAssignment::getDerivedUnitDefinition() returns the calculated
 * units, to the extent that libSBML can compute them.
 *
 * <!---------------------------------------------------------------------- -->
 * @class doc_warning_initialassignment_math_literals
 *
 * @warning <span class="warning">Note that it is possible the "math"
 * expression in the InitialAssignment contains literal numbers or parameters
 * with undeclared units.  In those cases, it is not possible to calculate
 * the units of the overall expression without making assumptions.  LibSBML
 * does not make assumptions about the units, and
 * InitialAssignment::getDerivedUnitDefinition() only returns the units as
 * far as it is able to determine them.  For example, in an expression <em>X
 * + Y</em>, if <em>X</em> has unambiguously-defined units and <em>Y</em>
 * does not, it will return the units of <em>X</em>.  When using this method,
 * <strong>it is critical that callers also invoke the method</strong>
 * InitialAssignment::containsUndeclaredUnits() <strong>to determine whether
 * this situation holds</strong>.  Callers should take suitable action in
 * those situations.</span>
 *
 */

#ifndef InitialAssignment_h
#define InitialAssignment_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class SBMLVisitor;


class LIBSBML_EXTERN InitialAssignment : public SBase
{
public:

  /**
   * Creates a new InitialAssignment using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this InitialAssignment
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * InitialAssignment
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  InitialAssignment (unsigned int level, unsigned int version);


  /**
   * Creates a new InitialAssignment using the given SBMLNamespaces object
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
  InitialAssignment (SBMLNamespaces* sbmlns);


  /**
   * Destroys this InitialAssignment.
   */
  virtual ~InitialAssignment ();


  /**
   * Copy constructor; creates a copy of this InitialAssignment.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  InitialAssignment (const InitialAssignment& orig);


  /**
   * Assignment operator for InitialAssignment.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  InitialAssignment& operator=(const InitialAssignment& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of InitialAssignment.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next InitialAssignment in
   * the list of compartment types.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this InitialAssignment object.
   *
   * @return the (deep) copy of this InitialAssignment object.
   */
  virtual InitialAssignment* clone () const;


  /**
   * Get the value of the "symbol" attribute of this InitialAssignment.
   * 
   * @return the identifier string stored as the "symbol" attribute value
   * in this InitialAssignment.
   */
  const std::string& getSymbol () const;


  /**
   * Get the mathematical formula of this InitialAssignment.
   *
   * @return an ASTNode, the value of the "math" subelement of this
   * InitialAssignment
   */
  const ASTNode* getMath () const;


  /**
   * Predicate returning @c true if this
   * InitialAssignment's "symbol" attribute is set.
   * 
   * @return @c true if the "symbol" attribute of this InitialAssignment
   * is set, @c false otherwise.
   */
  bool isSetSymbol () const;


  /**
   * Predicate returning @c true if this
   * InitialAssignment's "math" subelement contains a value.
   * 
   * @return @c true if the "math" for this InitialAssignment is set,
   * @c false otherwise.
   */
  bool isSetMath () const;


  /**
   * Sets the "symbol" attribute value of this InitialAssignment.
   *
   * @param sid the identifier of a Species, Compartment or Parameter
   * object defined elsewhere in this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setSymbol (const std::string& sid);


  /**
   * Sets the "math" subelement of this InitialAssignment.
   *
   * The AST passed in @p math is copied.
   *
   * @param math an AST containing the mathematical expression to
   * be used as the formula for this InitialAssignment.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setMath (const ASTNode* math);


  /**
   * Calculates and returns a UnitDefinition that expresses the units
   * of measurement assumed for the "math" expression of this
   * InitialAssignment.
   *
   * @copydetails doc_initialassignment_units
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_initialassignment_math_literals
   *
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this InitialAssignment, or @c NULL if one cannot be constructed.
   * 
   * @see containsUndeclaredUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Calculates and returns a UnitDefinition that expresses the units
   * of measurement assumed for the "math" expression of this
   * InitialAssignment.
   *
   * @copydetails doc_initialassignment_units
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_initialassignment_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this InitialAssignment, or @c NULL if one cannot be constructed.
   * 
   * @see containsUndeclaredUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Predicate returning @c true if the math expression of this
   * InitialAssignment contains parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this InitialAssignment
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by InitialAssignment::getDerivedUnitDefinition may not
   * accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits();


  /**
   * Predicate returning @c true if the math expression of this
   * InitialAssignment contains parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this InitialAssignment
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by InitialAssignment::getDerivedUnitDefinition may not
   * accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits() const;


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_INITIAL_ASSIGNMENT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for
   * InitialAssignment, is always @c "initialAssignment".
   * 
   * @return the name of this element, i.e., @c "initialAssignment".
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
   * InitialAssignment object have been set.
   *
   * The required attributes for an InitialAssignment object are:
   * @li "symbol"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


  /**
   * Predicate returning @c true if all the required elements for this
   * InitialAssignment object have been set.
   *
   * @note The required elements for a InitialAssignment object are:
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
   * @note This function is an alias of getSymbol() function.
   *       (id attribute is not defined in InitialAssignment element.)
   *
   * @return the string of variable attribute of this object.
   *
   * @see getSymbol()
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
   *
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


  std::string mSymbol;
  ASTNode* mMath;

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



class LIBSBML_EXTERN ListOfInitialAssignments : public ListOf
{
public:

  /**
   * Creates a new ListOfInitialAssignments object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfInitialAssignments (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfInitialAssignments object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfInitialAssignments object to be created.
   */
  ListOfInitialAssignments (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfInitialAssignments object.
   *
   * @return the (deep) copy of this ListOfInitialAssignments object.
   */
  virtual ListOfInitialAssignments* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., InitialAssignment objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf:
   * @sbmlconstant{SBML_INITIAL_ASSIGNMENT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfInitialAssignments, the XML element name is @c
   * "listOfInitialAssignments".
   * 
   * @return the name of this element, i.e., @c "listOfInitialAssignments".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a InitialAssignment from the ListOfInitialAssignments.
   *
   * @param n the index number of the InitialAssignment to get.
   * 
   * @return the nth InitialAssignment in this ListOfInitialAssignments.
   *
   * @see size()
   */
  virtual InitialAssignment * get(unsigned int n); 


  /**
   * Get a InitialAssignment from the ListOfInitialAssignments.
   *
   * @param n the index number of the InitialAssignment to get.
   * 
   * @return the nth InitialAssignment in this ListOfInitialAssignments.
   *
   * @see size()
   */
  virtual const InitialAssignment * get(unsigned int n) const; 


  /**
   * Get a InitialAssignment from the ListOfInitialAssignments
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the InitialAssignment to get.
   * 
   * @return InitialAssignment in this ListOfInitialAssignments
   * with the given @p sid or @c NULL if no such
   * InitialAssignment exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual InitialAssignment* get (const std::string& sid);


  /**
   * Get a InitialAssignment from the ListOfInitialAssignments
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the InitialAssignment to get.
   * 
   * @return InitialAssignment in this ListOfInitialAssignments
   * with the given @p sid or @c NULL if no such
   * InitialAssignment exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const InitialAssignment* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfInitialAssignments items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual InitialAssignment* remove (unsigned int n);


  /**
   * Removes item in this ListOfInitialAssignments items with the given identifier.
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
  virtual InitialAssignment* remove (const std::string& sid);


  /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * Note that InitialAssignments do not actually have IDs, though the
   * libsbml interface pretends that they do: no initial assignment is
   * returned by this function.
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
   * The ordering of elements in the XML form of %SBML is generally fixed
   * for most components in %SBML.  So, for example, the
   * ListOfInitialAssignments in a model is (in %SBML Level 2 Version 4)
   * the eighth ListOf___.  (However, it differs for different Levels and
   * Versions of SBML.)
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
 * Creates a new InitialAssignment_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * InitialAssignment_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * InitialAssignment_t
 *
 * @return a pointer to the newly created InitialAssignment_t structure.
 *
 * @note Once a InitialAssignment_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the InitialAssignment_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
InitialAssignment_create (unsigned int level, unsigned int version);


/**
 * Creates a new InitialAssignment_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this InitialAssignment_t
 *
 * @return a pointer to the newly created InitialAssignment_t structure.
 *
 * @note Once a InitialAssignment_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the InitialAssignment_t.  Despite this, the ability to supply the values at 
 * creation time is an important aid to creating valid SBML.  Knowledge of the 
 * intended SBML Level and Version determine whether it is valid to assign a 
 * particular value to an attribute, or whether it is valid to add a structure to 
 * an existing SBMLDocument_t.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
InitialAssignment_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given InitialAssignment_t structure.
 *
 * @param ia the InitialAssignment_t structure to free.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
void
InitialAssignment_free (InitialAssignment_t *ia);


/**
 * Copy constructor; creates a copy of this InitialAssignment_t.
 *
 * @param ia the InitialAssignment_t structure
 *
 * @return a (deep) copy of the given InitialAssignment_t structure.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
InitialAssignment_clone (const InitialAssignment_t *ia);


/**
 * Returns a list of XMLNamespaces_t associated with this InitialAssignment_t
 * structure.
 *
 * @param ia the InitialAssignment_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
InitialAssignment_getNamespaces(InitialAssignment_t *ia);


/**
 * Get the value of the "symbol" attribute of this InitialAssignment_t.
 *
 * @param ia the InitialAssignment_t structure
 * 
 * @return the identifier string stored as the "symbol" attribute value
 * in this InitialAssignment_t.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
const char *
InitialAssignment_getSymbol (const InitialAssignment_t *ia);


/**
 * Get the mathematical formula of this InitialAssignment_t.
 *
 * @param ia the InitialAssignment_t structure
 *
 * @return an ASTNode_t, the value of the "math" subelement of this
 * InitialAssignment_t
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
const ASTNode_t *
InitialAssignment_getMath (const InitialAssignment_t *ia);


/**
 * Predicate returning @c true or @c false depending on whether this
 * InitialAssignment_t's "symbol" attribute is set.
 *
 * @param ia the InitialAssignment_t structure
 * 
 * @return nonzero if the "symbol" attribute of this InitialAssignment_t
 * is set, zero (0) otherwise.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
int
InitialAssignment_isSetSymbol (const InitialAssignment_t *ia);


/**
 * Predicate returning @c true or @c false depending on whether this
 * InitialAssignment_t's "math" subelement contains a value.
 *
 * @param ia the InitialAssignment_t structure
 * 
 * @return nonzero if the "math" for this InitialAssignment_t is set,
 * zero (0) otherwise.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
int
InitialAssignment_isSetMath (const InitialAssignment_t *ia);


/**
 * Sets the "symbol" attribute value of this InitialAssignment_t
 *
 * @param ia the InitialAssignment_t structure
 *
 * @param sid the identifier of a Species_t, Compartment_t or Parameter_t
 * structure defined elsewhere in this Model_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "symbol" attribute.
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
int
InitialAssignment_setSymbol (InitialAssignment_t *ia, const char *sid);


/**
 * Sets the "math" subelement of this InitialAssignment_t
 *
 * The ASTNode tree passed in @p math is copied.
 *
 * @param ia the InitialAssignment_t structure
 *
 * @param math an ASTNode_t tree containing the mathematical expression to
 * be used as the formula for this InitialAssignment_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
int
InitialAssignment_setMath (InitialAssignment_t *ia, const ASTNode_t *math);


/**
 * Calculates and returns a UnitDefinition_t that expresses the units
 * returned by the math expression of this InitialAssignment_t.
 *
 * @return a UnitDefinition_t that expresses the units of the math 
 * expression of this InitialAssignment_t.
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
 * @see InitialAssignment_containsUndeclaredUnits()
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
InitialAssignment_getDerivedUnitDefinition(InitialAssignment_t *ia);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the math expression of this InitialAssignment_t contains
 * parameters/numbers with undeclared units.
 * 
 * @return @c true if the math expression of this InitialAssignment_t
 * includes parameters/numbers 
 * with undeclared units, @c false otherwise.
 *
 * @note a return value of @c true indicates that the UnitDefinition_t
 * returned by the getDerivedUnitDefinition function may not 
 * accurately represent the units of the expression.
 *
 * @see InitialAssignment_getDerivedUnitDefinition()
 *
 * @memberof InitialAssignment_t
 */
LIBSBML_EXTERN
int 
InitialAssignment_containsUndeclaredUnits(InitialAssignment_t *ia);

/**
 * Returns the InitialAssignment_t structure having a given identifier.
 *
 * @param lo the ListOfInitialAssignments_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfInitialAssignments with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfInitialAssignments_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
ListOfInitialAssignments_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a InitialAssignment_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of InitialAssignment_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The InitialAssignment_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfInitialAssignments_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
ListOfInitialAssignments_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* InitialAssignment_h */

