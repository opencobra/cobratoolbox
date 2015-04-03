/**
 * @file    Rule.h
 * @brief   Definitions of Rule and ListOfRules.
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
 * @class Rule
 * @sbmlbrief{core} Parent class for SBML <em>rules</em> in libSBML.
 *
 * In SBML, @em rules provide additional ways to define the values of
 * variables in a model, their relationships, and the dynamical behaviors
 * of those variables.  They enable encoding relationships that cannot be
 * expressed using Reaction nor InitialAssignment objects alone.
 *
 * The libSBML implementation of rules mirrors the SBML Level&nbsp;3
 * Version&nbsp;1 Core definition (which is in turn is very similar to the
 * Level&nbsp;2 Version&nbsp;4 definition), with Rule being the parent
 * class of three subclasses as explained below.  The Rule class itself
 * cannot be instantiated by user programs and has no constructor; only the
 * subclasses AssignmentRule, AlgebraicRule and RateRule can be
 * instantiated directly.
 *
 * @copydetails doc_rules_general_summary
 *
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfRules
 * @sbmlbrief{core} A list of Rule objects.
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
 * @class doc_rule_level_1
 *
 * @par
 * In SBML Level&nbsp;1, the different rule types each have a different
 * name for the attribute holding the reference to the object constituting
 * the left-hand side of the rule.  (E.g., for SBML Level&nbsp;1's
 * SpeciesConcentrationRule the attribute is "species", for
 * CompartmentVolumeRule it is "compartment", etc.)  In SBML Levels&nbsp;2
 * and&nbsp;3, the only two types of Rule objects with a left-hand side
 * object reference are AssignmentRule and RateRule, and both of them use the
 * same name for attribute: "variable".  In order to make it easier for
 * application developers to work with all Levels of SBML, libSBML uses a
 * uniform name for all such attributes, and it is "variable", regardless of
 * whether Level&nbsp;1 rules or Level&nbsp;2&ndash;3 rules are being used.
 * 
 * @class doc_rule_units
 *
 * @par
 * The units are calculated based on the mathematical expression in the
 * Rule and the model quantities referenced by <code>&lt;ci&gt;</code>
 * elements used within that expression.  The method
 * Rule::getDerivedUnitDefinition() returns the calculated units, to the
 * extent that libSBML can compute them.
 * 
 * @class doc_warning_rule_math_literals
 * 
 * @warning <span class="warning">Note that it is possible the "math"
 * expression in the Rule contains pure numbers or parameters with undeclared
 * units.  In those cases, it is not possible to calculate the units of the
 * overall expression without making assumptions.  LibSBML does not make
 * assumptions about the units, and Rule::getDerivedUnitDefinition() only
 * returns the units as far as it is able to determine them.  For example, in
 * an expression <em>X + Y</em>, if <em>X</em> has unambiguously-defined
 * units and <em>Y</em> does not, it will return the units of <em>X</em>.
 * <strong>It is important that callers also invoke the method</strong>
 * Rule::containsUndeclaredUnits() <strong>to determine whether this
 * situation holds</strong>.  Callers may wish to take suitable actions in
 * those scenarios.</span>
 *
 */

#ifndef Rule_h
#define Rule_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


BEGIN_C_DECLS

/**
 * @enum RuleType_t
 * @brief Enumeration of the valid values for the 'type' attribute of an
 * SBML Level&nbsp;1 Rule.
 */
typedef enum
{
    RULE_TYPE_RATE /*!< 'rate' */
  , RULE_TYPE_SCALAR /*!< 'scalar' */
  , RULE_TYPE_INVALID /*!< An invalid value:  anything other than 'rate' or 'scalar'. */
} RuleType_t;

END_C_DECLS


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ExpectedAttributes.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/ListOf.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class ListOfRules;
class SBMLNamespaces;


class LIBSBML_EXTERN Rule : public SBase
{
public:
  /**
   * Destroys this Rule.
   */
  virtual ~Rule ();


  /**
   * Copy constructor; creates a copy of this Rule.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Rule (const Rule& orig);


  /**
   * Assignment operator for Rule.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Rule& operator=(const Rule& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Rule.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next Rule object in the
   * list of rules within which @em the present object is embedded.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Rule object.
   *
   * @return the (deep) copy of this Rule object.
   */
  virtual Rule* clone () const;


  /**
   * Returns the mathematical expression of this Rule in text-string form.
   *
   * The text string is produced by
   * @if java <code><a href="libsbml.html#formulaToString(org.sbml.libsbml.ASTNode)">libsbml.formulaToString()</a></code>@else SBML_formulaToString()@endif; please consult
   * the documentation for that function to find out more about the format
   * of the text-string formula.
   * 
   * @return the formula text string for this Rule.
   *
   * @note The attribute "formula" is specific to SBML Level&nbsp;1; in
   * higher Levels of SBML, it has been replaced with a subelement named
   * "math".  However, libSBML provides a unified interface to the
   * underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see getMath()
   */
  const std::string& getFormula () const;


  /**
   * Get the mathematical formula of this Rule as an ASTNode tree.
   *
   * @return an ASTNode, the value of the "math" subelement of this Rule.
   *
   * @note The subelement "math" is present in SBML Levels&nbsp;2
   * and&nbsp;3.  In SBML Level&nbsp;1, the equivalent construct is the
   * attribute named "formula".  LibSBML provides a unified interface to
   * the underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see getFormula()
   */
  const ASTNode* getMath () const;


  /**
   * Get the value of the "variable" attribute of this Rule object.
   *
   * @copydetails doc_rule_level_1
   * 
   * @return the identifier string stored as the "variable" attribute value
   * in this Rule, or @c NULL if this object is an AlgebraicRule object.
   */
  const std::string& getVariable () const;


  /**
   * Returns the units for the
   * mathematical formula of this Rule.
   * 
   * @return the identifier of the units for the expression of this Rule.
   *
   * @note The attribute "units" exists on SBML Level&nbsp;1 ParameterRule
   * objects only.  It is not present in SBML Levels&nbsp;2 and&nbsp;3.
   */
  const std::string& getUnits () const;


  /**
   * Predicate returning @c true if this Rule's mathematical expression is
   * set.
   * 
   * This method is equivalent to isSetMath().  This version is present for
   * easier compatibility with SBML Level&nbsp;1, in which mathematical
   * formulas were written in text-string form.
   * 
   * @return @c true if the mathematical formula for this Rule is
   * set, @c false otherwise.
   *
   * @note The attribute "formula" is specific to SBML Level&nbsp;1; in
   * higher Levels of SBML, it has been replaced with a subelement named
   * "math".  However, libSBML provides a unified interface to the
   * underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see isSetMath()
   */
  bool isSetFormula () const;


  /**
   * Predicate returning @c true if this Rule's mathematical expression is
   * set.
   *
   * This method is equivalent to isSetFormula().
   * 
   * @return @c true if the formula (or equivalently the math) for this
   * Rule is set, @c false otherwise.
   *
   * @note The subelement "math" is present in SBML Levels&nbsp;2
   * and&nbsp;3.  In SBML Level&nbsp;1, the equivalent construct is the
   * attribute named "formula".  LibSBML provides a unified interface to
   * the underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see isSetFormula()
   */
  bool isSetMath () const;


  /**
   * Predicate returning @c true if this Rule's "variable" attribute is set.
   *
   * @copydetails doc_rule_level_1
   * 
   * @return @c true if the "variable" attribute value of this Rule is
   * set, @c false otherwise.
   */
  bool isSetVariable () const;


  /**
   * Predicate returning @c true if this Rule's "units" attribute is set.
   *
   * @return @c true if the units for this Rule is set, @c false
   * otherwise
   *
   * @note The attribute "units" exists on SBML Level&nbsp;1 ParameterRule
   * objects only.  It is not present in SBML Levels&nbsp;2 and&nbsp;3.
   */
  bool isSetUnits () const;


  /**
   * Sets the "math" subelement of this Rule to an expression in text-string
   * form.
   *
   * This is equivalent to setMath(const ASTNode* math).  The provision of
   * using text-string formulas is retained for easier SBML Level&nbsp;1
   * compatibility.  The formula is converted to an ASTNode internally.
   *
   * @param formula a mathematical formula in text-string form.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note The attribute "formula" is specific to SBML Level&nbsp;1; in
   * higher Levels of SBML, it has been replaced with a subelement named
   * "math".  However, libSBML provides a unified interface to the
   * underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see setMath(const ASTNode* math)
   */
  int setFormula (const std::string& formula);


  /**
   * Sets the "math" subelement of this Rule to a copy of the given
   * ASTNode.
   *
   * @param math the AST structure of the mathematical formula.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note The subelement "math" is present in SBML Levels&nbsp;2
   * and&nbsp;3.  In SBML Level&nbsp;1, the equivalent construct is the
   * attribute named "formula".  LibSBML provides a unified interface to
   * the underlying math expression and this method can be used for models
   * of all Levels of SBML.
   *
   * @see setFormula(const std::string& formula)
   */
  int setMath (const ASTNode* math);


  /**
   * Sets the "variable" attribute value of this Rule object.
   *
   * @copydetails doc_rule_level_1
   * 
   * @param sid the identifier of a Compartment, Species or Parameter
   * elsewhere in the enclosing Model object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  int setVariable (const std::string& sid);


  /**
   * Sets the units for this Rule.
   *
   * @param sname the identifier of the units
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The attribute "units" exists on SBML Level&nbsp;1 ParameterRule
   * objects only.  It is not present in SBML Levels&nbsp;2 and&nbsp;3.
   */
  int setUnits (const std::string& sname);


  /**
   * Unsets the "units" for this Rule.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @note The attribute "units" exists on SBML Level&nbsp;1 ParameterRule
   * objects only.  It is not present in SBML Levels&nbsp;2 and&nbsp;3.
   */
  int unsetUnits ();


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this Rule.
   *
   * @copydetails doc_rule_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_rule_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this Rule, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this Rule.
   *
   * @copydetails doc_rule_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_rule_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this Rule, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Predicate returning @c true if the math expression of this Rule contains
   * parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this Rule includes
   * parameters/numbers with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by getDerivedUnitDefinition() may not accurately represent
   * the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits();


  /**
   * Predicate returning @c true if the math expression of this Rule contains
   * parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this Rule includes
   * parameters/numbers with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by getDerivedUnitDefinition() may not accurately represent the
   * units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits() const;


  /**
   * Returns a code representing the type of rule this is.
   *
   * @return the rule type, which will be one of the following three possible
   * values:
   * @li @sbmlconstant{RULE_TYPE_RATE, RuleType_t}
   * @li @sbmlconstant{RULE_TYPE_SCALAR, RuleType_t}
   * @li @sbmlconstant{RULE_TYPE_INVALID, RuleType_t}
   *
   * @note The attribute "type" on Rule objects is present only in SBML
   * Level&nbsp;1.  In SBML Level&nbsp;2 and later, the type has been
   * replaced by subclassing the Rule object.
   */
  RuleType_t getType () const;


  /**
   * Predicate returning @c true if this Rule is an AlgebraicRule.
   * 
   * @return @c true if this Rule is an AlgebraicRule, @c false otherwise.
   */
  bool isAlgebraic () const;


  /**
   * Predicate returning @c true if this Rule is an AssignmentRule.
   * 
   * @return @c true if this Rule is an AssignmentRule, @c false otherwise.
   */
  bool isAssignment () const;


  /**
   * Predicate returning @c true if this Rule is an CompartmentVolumeRule
   * or equivalent.
   *
   * This libSBML method works for SBML Level&nbsp;1 models (where there is
   * such a thing as an explicit CompartmentVolumeRule), as well as other Levels of
   * SBML.  For Levels above Level&nbsp;1, this method checks the symbol
   * being affected by the rule, and returns @c true if the symbol is the
   * identifier of a Compartment object defined in the model.
   *
   * @return @c true if this Rule is a CompartmentVolumeRule, @c false
   * otherwise.
   */
  bool isCompartmentVolume () const;


  /**
   * Predicate returning @c true if this Rule is an ParameterRule or
   * equivalent.
   *
   * This libSBML method works for SBML Level&nbsp;1 models (where there is
   * such a thing as an explicit ParameterRule), as well as other Levels of
   * SBML.  For Levels above Level&nbsp;1, this method checks the symbol
   * being affected by the rule, and returns @c true if the symbol is the
   * identifier of a Parameter object defined in the model.
   *
   * @return @c true if this Rule is a ParameterRule, @c false
   * otherwise.
   */
  bool isParameter () const;


  /**
   * Predicate returning @c true if this Rule is a RateRule (SBML
   * Levels&nbsp;2&ndash;3) or has a "type" attribute value of @c "rate"
   * (SBML Level&nbsp;1).
   *
   * @return @c true if this Rule is a RateRule (Level&nbsp;2) or has
   * type "rate" (Level&nbsp;1), @c false otherwise.
   */
  bool isRate () const;


  /**
   * Predicate returning @c true if this Rule is an AssignmentRule (SBML
   * Levels&nbsp;2&ndash;3) or has a "type" attribute value of @c "scalar"
   * (SBML Level&nbsp;1).
   *
   * @return @c true if this Rule is an AssignmentRule (Level&nbsp;2) or has
   * type "scalar" (Level&nbsp;1), @c false otherwise.
   */
  bool isScalar () const;


  /**
   * Predicate returning @c true if this Rule is a SpeciesConcentrationRule
   * or equivalent.
   *
   * This libSBML method works for SBML Level&nbsp;1 models (where there is
   * such a thing as an explicit SpeciesConcentrationRule), as well as
   * other Levels of SBML.  For Levels above Level&nbsp;1, this method
   * checks the symbol being affected by the rule, and returns @c true if
   * the symbol is the identifier of a Species object defined in the model.
   *
   * @return @c true if this Rule is a SpeciesConcentrationRule, @c false
   * otherwise.
   */
  bool isSpeciesConcentration () const;


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object, either
   * @sbmlconstant{SBML_ASSIGNMENT_RULE, SBMLTypeCode_t},
   * @sbmlconstant{SBML_RATE_RULE, SBMLTypeCode_t}, or
   * @sbmlconstant{SBML_ALGEBRAIC_RULE, SBMLTypeCode_t} 
   * for %SBML Core.
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the SBML Level&nbsp;1 type code for this Rule object.
   *
   * This method only applies to SBML Level&nbsp;1 model objects.  If this is
   * not an SBML Level&nbsp;1 rule object, this method will return
   * @sbmlconstant{SBML_UNKNOWN, SBMLTypeCode_t}.
   *
   * @return the SBML Level&nbsp;1 type code for this Rule (namely,
   * @sbmlconstant{SBML_COMPARTMENT_VOLUME_RULE, SBMLTypeCode_t},
   * @sbmlconstant{SBML_PARAMETER_RULE, SBMLTypeCode_t},
   * @sbmlconstant{SBML_SPECIES_CONCENTRATION_RULE, SBMLTypeCode_t}, or
   * @sbmlconstant{SBML_UNKNOWN, SBMLTypeCode_t}).
   */
  int getL1TypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * The returned value can be any of a number of different strings,
   * depending on the SBML Level in use and the kind of Rule object this
   * is.  The rules as of libSBML version @htmlinclude libsbml-version.html
   * are the following:
   * <ul>
   * <li> (Level&nbsp;2 and&nbsp;3) RateRule: returns @c "rateRule"
   * <li> (Level&nbsp;2 and&nbsp;3) AssignmentRule: returns @c "assignmentRule" 
   * <li> (Level&nbsp;2 and&nbsp;3) AlgebraicRule: returns @c "algebraicRule"
   * <li> (Level&nbsp;1 Version&nbsp;1) SpecieConcentrationRule: returns @c "specieConcentrationRule"
   * <li> (Level&nbsp;1 Version&nbsp;2) SpeciesConcentrationRule: returns @c "speciesConcentrationRule"
   * <li> (Level&nbsp;1) CompartmentVolumeRule: returns @c "compartmentVolumeRule"
   * <li> (Level&nbsp;1) ParameterRule: returns @c "parameterRule"
   * <li> Unknown rule type: returns @c "unknownRule"
   * </ul>
   *
   * Beware that the last (@c "unknownRule") is not a valid SBML element
   * name.
   * 
   * @return the name of this element
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
   * Sets the SBML Level&nbsp;1 type code for this Rule.
   *
   * @param type the SBML Level&nbsp;1 type code for this Rule. The allowable
   * values are @sbmlconstant{SBML_COMPARTMENT_VOLUME_RULE, SBMLTypeCode_t},
   * @sbmlconstant{SBML_PARAMETER_RULE, SBMLTypeCode_t}, and
   * @sbmlconstant{SBML_SPECIES_CONCENTRATION_RULE, SBMLTypeCode_t}.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * if given @p type value is not one of the above.
   */
  int setL1TypeCode (int type);


  /**
   * Predicate returning @c true if all the required elements for this Rule
   * object have been set.
   *
   * The only required element for a Rule object is the "math" subelement.
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const ;


  /**
   * Predicate returning @c true if all the required attributes for this Rule
   * object have been set.
   *
   * The required attributes for a Rule object depend on the type of Rule
   * it is.  For AssignmentRule and RateRule objects (and SBML
   * Level&nbsp1's SpeciesConcentrationRule, CompartmentVolumeRule, and
   * ParameterRule objects), the required attribute is "variable"; for
   * AlgebraicRule objects, there is no required attribute.
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



  /** @cond doxygenLibsbmlInternal */

  /* function to set/get an identifier for unit checking */
  std::string getInternalId() const { return mInternalId; };
  void setInternalId(std::string id) { mInternalId = id; };
  /** @endcond */

  
  /** @cond doxygenLibsbmlInternal */
  /*
   * Return the variable attribute of this object.
   *
   * @note This function is an alias of getVariable() function.
   *       (id attribute is not defined in Rule element.)
   *
   * @return the string of variable attribute of this object.
   *
   * @see getVariable()
   */
  virtual const std::string& getId() const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Replace all nodes with the name 'id' from the child 'math' object with the provided function. 
   *
   */
  virtual void replaceSIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * If this rule assigns a value or a change to the 'id' element, replace the 'math' object with the function (existing/function). 
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
   * Only subclasses may create Rules.
   */
  Rule (  int      type
        , unsigned int        level
        , unsigned int        version );

  Rule (  int      type
        , SBMLNamespaces *    sbmlns );


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

  void readL1Attributes (const XMLAttributes& attributes);

  void readL2Attributes (const XMLAttributes& attributes);
  
  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;




  std::string mVariable;
  mutable std::string  mFormula;
  mutable ASTNode*     mMath;
  std::string          mUnits;

  int mType;
  int mL1Type;


  /* internal id used by unit checking */
  std::string mInternalId;

  friend class ListOfRules;

  /** @endcond */
};

class LIBSBML_EXTERN ListOfRules : public ListOf
{
public:

  /**
   * Creates a new ListOfRules object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfRules (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfRules object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfRules object to be created.
   */
  ListOfRules (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfRules object.
   *
   * @return the (deep) copy of this ListOfRules object.
   */
  virtual ListOfRules* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Rule objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_RULE, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfRules, the XML element name is @c "listOfRules".
   * 
   * @return the name of this element, i.e., @c "listOfRules".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Rule from the ListOfRules.
   *
   * @param n the index number of the Rule to get.
   * 
   * @return the nth Rule in this ListOfRules.
   *
   * @see size()
   */
  virtual Rule * get(unsigned int n); 


  /**
   * Get a Rule from the ListOfRules.
   *
   * @param n the index number of the Rule to get.
   * 
   * @return the nth Rule in this ListOfRules.
   *
   * @see size()
   */
  virtual const Rule * get(unsigned int n) const; 


  /**
   * Get a Rule from the ListOfRules based on its identifier.
   *
   * @param sid a string representing the identifier of the Rule to get.
   * 
   * @return Rule in this ListOfRules with the given @p id or @c NULL if no
   * such Rule exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Rule* get (const std::string& sid);


  /**
   * Get a Rule from the ListOfRules based on its identifier.
   *
   * @param sid a string representing the identifier of the Rule to get.
   * 
   * @return Rule in this ListOfRules with the given @p sid or @c NULL if no
   * such Rule exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Rule* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfRules items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Rule* remove (unsigned int n);


  /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * Note that AssignmentRules and RateRules do not actually have IDs, but
   * the libsbml interface pretends that they do: no assignment rule or rate
   * rule is returned by this function.
   *
   * @param id string representing the id of objects to find
   *
   * @return pointer to the first element found with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);
  
  
  /**
   * Removes item in this ListOfRules items with the given identifier.
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
  virtual Rule* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of %SBML is generally fixed
   * for most components in %SBML.
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create and return a listOfRules object, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  virtual bool isValidTypeForList(SBase * item);
  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new AlgebraicRule (Rule_t) structure using the given SBML 
 * @p level and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * algebraic Rule_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * algebraic Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once an algebraic Rule_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the algebraic Rule_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createAlgebraic (unsigned int level, unsigned int version);


/**
 * Creates a new AlgebraicRule (Rule_t) structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this algebraic Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once an algebraic Rule_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the algebraic Rule_t.  Despite this, the ability to supply the values at creation 
 * time is an important aid to creating valid SBML.  Knowledge of the intended 
 * SBML Level and Version determine whether it is valid to assign a particular 
 * value to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createAlgebraicWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Creates a new AssignmentRule (Rule_t) structure using the given SBML
 * @p level and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * assignment Rule_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * assignment Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once an assignment Rule_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the assignment Rule_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createAssignment (unsigned int level, unsigned int version);


/**
 * Creates a new AssignmentRule (Rule_t) structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this assignment Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once an assignment Rule_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the assignment Rule_t.  Despite this, the ability to supply the values at creation
 * time is an important aid to creating valid SBML.  Knowledge of the intended
 * SBML Level and Version determine whether it is valid to assign a particular
 * * value to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createAssignmentWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Creates a new RateRule (Rule_t) structure using the given SBML
 * @p level and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * rate Rule_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * rate Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once a rate Rule_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the rate Rule_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createRate (unsigned int level, unsigned int version);


/**
 * Creates a new RateRule (Rule_t) structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this rate Rule_t
 *
 * @return a pointer to the newly created Rule_t structure.
 *
 * @note Once a rate Rule_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the rate Rule_t.  Despite this, the ability to supply the values at creation
 * time is an important aid to creating valid SBML.  Knowledge of the intended
 * SBML Level and Version determine whether it is valid to assign a particular
 * * value to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_createRateWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Destroys this Rule_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
void
Rule_free (Rule_t *r);


/**
 * @return a (deep) copy of this Rule_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
Rule_t *
Rule_clone (const Rule_t *r);


/**
 * Returns a list of XMLNamespaces_t associated with this Rule_t
 * structure.
 *
 * @param r the Rule_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Rule_getNamespaces(Rule_t *r);


/**
 * @note SBML Level 1 uses a text-string format for mathematical formulas.
 * SBML Level 2 uses MathML, an XML format for representing mathematical
 * expressions.  LibSBML provides an Abstract Syntax Tree API for working
 * with mathematical expressions; this API is more powerful than working
 * with formulas directly in text form, and ASTs can be translated into
 * either MathML or the text-string syntax.  The libSBML methods that
 * accept text-string formulas directly (such as this one) are
 * provided for SBML Level 1 compatibility, but developers are encouraged
 * to use the AST mechanisms.  
 *
 * @return the formula for this Rule_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
const char *
Rule_getFormula (const Rule_t *r);


/**
 * @return the math for this Rule_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
const ASTNode_t *
Rule_getMath (const Rule_t *r);


/**
 * @return the type of this Rule_t, either RULE_TYPE_RATE or
 * RULE_TYPE_SCALAR.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
RuleType_t
Rule_getType (const Rule_t *r);


/**
 * @return the variable for this Rule_t.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
const char *
Rule_getVariable (const Rule_t *r);


/**
 * @return the units for this Rule_t (L1 ParameterRules only).
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
const char *
Rule_getUnits (const Rule_t *r);


/**
 * @return true (non-zero) if the formula (or equivalently the math) for
 * this Rule_t is set, false (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isSetFormula (const Rule_t *r);


/**
 * @return true (non-zero) if the math (or equivalently the formula) for
 * this Rule_t is set, false (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isSetMath (const Rule_t *r);


/**
 * @return true (non-zero) if the variable of this Rule_t is set, false
 * (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isSetVariable (const Rule_t *r);


/**
 * @return true (non-zero) if the units for this Rule_t is set, false
 * (0) otherwise (L1 ParameterRules only).
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isSetUnits (const Rule_t *r);


/**
 * Sets the formula of this Rule_t to a copy of string.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note SBML Level 1 uses a text-string format for mathematical formulas.
 * SBML Level 2 uses MathML, an XML format for representing mathematical
 * expressions.  LibSBML provides an Abstract Syntax Tree API for working
 * with mathematical expressions; this API is more powerful than working
 * with formulas directly in text form, and ASTs can be translated into
 * either MathML or the text-string syntax.  The libSBML methods that
 * accept text-string formulas directly (such as this one) are
 * provided for SBML Level 1 compatibility, but developers are encouraged
 * to use the AST mechanisms.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_setFormula (Rule_t *r, const char *formula);


/**
 * Sets the math of this Rule_t to a copy of the given ASTNode_t.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_setMath (Rule_t *r, const ASTNode_t *math);


/**
 * Sets the variable of this Rule_t to a copy of sid.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "variable" attribute.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_setVariable (Rule_t *r, const char *sid);


/**
 * Sets the units for this Rule_t to a copy of sname (L1 ParameterRules
 * only).
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "units" attribute.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_setUnits (Rule_t *r, const char *sname);


/**
 * Unsets the units for this Rule_t (L1 ParameterRules only).
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_unsetUnits (Rule_t *r);


/**
 * @return true (non-zero) if this Rule_t is an AlgebraicRule, false (0)
 * otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isAlgebraic (const Rule_t *r);


/**
 * @return true (non-zero) if this Rule_t is an AssignmentRule, false (0)
 * otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isAssignment (const Rule_t *r);


/**
 * This method attempts to lookup the Rule_t's variable in the Model_t's list
 * of Compartments.
 *
 * @return true (non-zero) if this Rule_t is a CompartmentVolumeRule, false
 * (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isCompartmentVolume (const Rule_t *r);


/**
 * This method attempts to lookup the Rule_t's variable in the Model_t's list
 * of Parameters.
 *
 * @return true (non-zero) if this Rule_t is a ParameterRule, false (0)
 * otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isParameter (const Rule_t *r);


/**
 * @return true (non-zero) if this Rule_t is a RateRule (L2) or has
 * type="rate" (L1), false (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isRate (const Rule_t *r);


/**
 * @return true (non-zero) if this Rule_t is an AssignmentRule (L2) has
 * type="scalar" (L1), false (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isScalar (const Rule_t *r);


/**
 * This method attempts to lookup the Rule_t's variable in the Model_t's list
 * of Species.
 *
 * @return true (non-zero) if this Rule_t is a species concentration Rule_t, false
 * (0) otherwise.
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_isSpeciesConcentration (const Rule_t *r);


/**
 * @return the typecode (int) of SBML structures contained in this ListOf_t or
 * (default).
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_getTypeCode (const Rule_t *r);


/**
 * @return the SBML Level 1 typecode for this Rule_t or SBML_UNKNOWN
 * (default).
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_getL1TypeCode (const Rule_t *r);


/**
 * Sets the SBML Level&nbsp;1 typecode for this Rule_t.
 *
 * @param r the Rule_t structure
 * @param L1Type the SBML Level&nbsp;1 typecode for this Rule_t
 * (@c SBML_COMPARTMENT_VOLUME_RULE, @c SBML_PARAMETER_RULE,
 * or @c SBML_SPECIES_CONCENTRATION_RULE).
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int
Rule_setL1TypeCode (Rule_t *r, int L1Type);


/**
 * Calculates and returns a UnitDefinition_t that expresses the units
 * returned by the math expression of this Rule_t.
 *
 * @return a UnitDefinition_t that expresses the units of the math 
 * expression of this Rule_t.
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
 * @see Rule_containsUndeclaredUnits()
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
Rule_getDerivedUnitDefinition(Rule_t *ia);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the math expression of this Rule_t contains
 * parameters/numbers with undeclared units.
 * 
 * @return @c true if the math expression of this Rule_t
 * includes parameters/numbers 
 * with undeclared units, @c false otherwise.
 *
 * @note a return value of @c true indicates that the UnitDefinition_t
 * returned by the getDerivedUnitDefinition function may not 
 * accurately represent the units of the expression.
 *
 * @see Rule_getDerivedUnitDefinition()
 *
 * @memberof Rule_t
 */
LIBSBML_EXTERN
int 
Rule_containsUndeclaredUnits(Rule_t *ia);


/**
 * Returns the Rule_t structure having a given identifier.
 *
 * @param lo the ListOfRules_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfRules with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfRules_t
 */
LIBSBML_EXTERN
Rule_t *
ListOfRules_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a Rule_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of Rule_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The Rule_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfRules_t
 */
LIBSBML_EXTERN
Rule_t *
ListOfRules_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG  */

#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#endif

#endif  /* Rule_h */

