/**
 * @file    AssignmentRule.h
 * @brief   Definitions of AssignmentRule.
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
 * @class AssignmentRule
 * @sbmlbrief{core} An SBML <em>assignment rule</em> representing <em>x = f(<b>Y</b>)</em>.
 *
 * The rule type AssignmentRule is derived from the parent class Rule.  It
 * is used to express equations that set the values of variables.  The
 * left-hand side (the attribute named "variable") of an assignment rule
 * can refer to the identifier of a Species, SpeciesReference (in SBML
 * Level&nbsp;3), Compartment, or Parameter
 * @if conly structure @else object@endif@~ in the model (but not a
 * Reaction).  The entity identified must have its "constant" attribute set
 * to @c false.  The effects of an assignment rule construct are in general
 * terms the same, but differ in the precise details depending on the type of
 * SBML component being set:
 * <ul>
 *
 * <li> <em>In the case of a species</em>, an SBML assignment rule sets the
 * referenced species' quantity (whether a "concentration" or "amount") to
 * the value determined by the formula in the MathML subelement "math".
 * The unit associated with the value produced by the "math" formula @em
 * should (in SBML Level&nbsp;2 Version&nbsp;4 and in SBML Level&nbsp;3) or @em must (in
 * SBML releases prior to Level&nbsp;2 version&nbsp;4) be equal to the unit
 * associated with the species' quantity.  <em>Restrictions</em>: There
 * must not be both an AssignmentRule "variable" attribute and a
 * SpeciesReference "species" attribute having the same value in a model,
 * unless the referenced Species @if conly structure @else object@endif@~ has
 * its "boundaryCondition" attribute set to @c true.  In other words, an
 * assignment rule cannot be defined for a species that is created or
 * destroyed in a reaction unless that species is defined as a boundary
 * condition in the model.
 *
 * <li> (For SBML Level&nbsp;3 only) <em>In the case of a species
 * reference</em>, an assignment rule sets the stoichiometry of the
 * referenced reactant or product to the value determined by the formula in
 * "math".  The unit associated with the value produced by the "math"
 * formula should be consistent with the unit "dimensionless", because
 * reactant and product stoichiometries in reactions are dimensionless
 * quantities.
  *
 * <li> <em>In the case of a compartment</em>, an SBML assignment rule sets
 * the referenced compartment's size to the value determined by the formula
 * in the "math" subelement of the AssignmentRule
 * @if conly structure @else object@endif@~.  The overall units of the
 * formula in "math" @em should (in SBML Level&nbsp;2 Version&nbsp;4 and in
 * SBML Level&nbsp;3) or @em must (in SBML releases prior to Level&nbsp;2
 * version&nbsp;4) be the same as the units of the size of the compartment.
 *
 * <li> <em>In the case of a parameter</em>, an assignment rule sets the
 * referenced parameter's value to that determined by the formula in the
 * "math" subelement of the AssignmentRule
 * @if conly structure @else object@endif@~.  The overall units of the
 * formula in the "math" subelement @em should (in SBML Level&nbsp;2
 * Version&nbsp;4 and in SBML Level&nbsp;3) or @em must (in SBML releases
 * prior to Level&nbsp;2 version&nbsp;4) be the same as the units defined for
 * the parameter.  </ul>
 * 
 * In the context of a simulation, assignment rules are in effect at all
 * times, <em>t</em> \f$\geq\f$ <em>0</em>.  For purposes of evaluating
 * expressions that involve the <em>delay</em> "csymbol" (see the SBML
 * Level&nbsp;2 specification), assignment rules are considered to apply
 * also at <em>t</em> \f$\leq\f$ <em>0</em>.  Please consult the relevant
 * SBML specification for additional information about the semantics of
 * assignments, rules, and entity values for simulation time <em>t</em>
 * \f$\leq\f$ <em>0</em>.
 *
 * A model must not contain more than one AssignmentRule or RateRule
 * @if conly structure @else object@endif@~ having the same value of
 * "variable"; in other words, in the set of all assignment rules and rate
 * rules in an SBML model, each variable appearing in the left-hand sides can
 * only appear once.  This simply follows from the fact that an indeterminate
 * system would result if a model contained more than one assignment rule for
 * the same variable or both an assignment rule and a rate rule for the same
 * variable.
 *
 * Similarly, a model must also not contain <em>both</em> an AssignmentRule
 * and an InitialAssignment definition for the same variable, because both
 * kinds of constructs apply prior to and at the start of simulation time,
 * i.e., <em>t</em> \f$\leq\f$ <em>0</em>.  If a model contained both an
 * initial assignment and an assignment rule for the same variable, an
 * indeterminate system would result.
 *
 * The value calculated by an AssignmentRule
 * @if conly structure @else object@endif@~ overrides the value assigned to
 * the given symbol by the model component defining that symbol.  For
 * example, if a Compartment @if conly structure @else object@endif's
 * "size" attribute value is set in its definition, and the model also
 * contains an AssignmentRule @if conly structure @else object@endif@~ 
 * having that compartment's "id" as its "variable" value, then the "size"
 * assigned in the Compartment @if conly structure @else object@endif@~
 * definition is ignored and the value assigned based on the computation
 * defined in the AssignmentRule.  This does <em>not</em> mean that a
 * definition for a given symbol can be omitted if there is an AssignmentRule
 * @if conly structure @else object@endif@~ involving it.  For example, 
 * there must be a Parameter @if conly structure @else object@endif@~
 * definition for a given parameter if there is an AssignmentRule definition
 * for that parameter.  It is only a question of which value definition takes
 * precedence.
 *
 * @copydetails doc_rules_general_summary
 */

#ifndef AssignmentRule_h
#define AssignmentRule_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>



#ifdef __cplusplus


#include <string>

#include <sbml/Rule.h>
#include <sbml/SBMLVisitor.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLNamespaces;

class LIBSBML_EXTERN AssignmentRule : public Rule
{
public:

  /**
   * Creates a new AssignmentRule using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this AssignmentRule.
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * AssignmentRule.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   * 
   * @copydetails doc_note_setting_lv
   */
  AssignmentRule (unsigned int level, unsigned int version);


  /**
   * Creates a new AssignmentRule using the given SBMLNamespaces object
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
  AssignmentRule (SBMLNamespaces* sbmlns);


  /**
   * Destroys this AssignmentRule.
   */
  virtual ~AssignmentRule ();


  /**
   * Creates and returns a deep copy of this AssignmentRule object.
   *
   * @return the (deep) copy of this Rule object.
   */
  virtual AssignmentRule* clone () const;


  /**
   * Accepts the given SBMLVisitor for this instance of AssignmentRule.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next AssignmentRule object
   * in the list of rules within which @em the present object is embedded.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Predicate returning @c true if all the required attributes for this
   * AssignmentRule object have been set.
   *
   * In SBML Levels&nbsp;2&ndash;3, the only required attribute for
   * an AssignmentRule object is "variable".  For Level&nbsp;1, where the
   * equivalent attribute is known by different names ("compartment",
   * "species", or "name", depending on the type of object), there is an
   * additional required attribute called "formula".
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


protected:
  /** @cond doxygenLibsbmlInternal */

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

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new AssignmentRule_t structure using the given SBML @p level and
 * @p version values.
 *
 * @param level an unsigned int, the SBML level to assign to this
 * AssignmentRule_t structure.
 *
 * @param version an unsigned int, the SBML version to assign to this
 * AssignmentRule_t structure.
 *
 * @returns the newly-created AssignmentRule_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
AssignmentRule_t *
AssignmentRule_create(unsigned int level, unsigned int version);


/**
 * Creates a new AssignmentRule_t structure using the given SBMLNamespaces_t
 * structure, @p sbmlns.
 *
 * @copydetails doc_what_are_sbmlnamespaces
 *
 * @param sbmlns an SBMLNamespaces_t structure.
 *
 * @returns the newly-created AssignmentRule_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
AssignmentRule_t *
AssignmentRule_createWithNS(SBMLNamespaces_t* sbmlns);


/**
 * Frees the given AssignmentRule_t structure.
 * 
 * @param ar the AssignmentRule_t structure to be freed.
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
void
AssignmentRule_free(AssignmentRule_t * ar);


/**
 * Creates a deep copy of the given AssignmentRule_t structure.
 * 
 * @param ar the AssignmentRule_t structure to be copied.
 *
 * @returns a (deep) copy of the given AssignmentRule_t structure, or a null
 * pointer if a failure occurred.
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
AssignmentRule_t *
AssignmentRule_clone(AssignmentRule_t * ar);


/**
 * Returns the value of the "variable" attribute of the given AssignmentRule_t
 * structure.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @return the variable of this structure.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
const char *
AssignmentRule_getVariable(const AssignmentRule_t * ar);


/**
 * Gets the mathematical expression of this AssignmentRule_t structure as an
 * ASTNode_t structure.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @return the math for this AssignmentRule_t, as an ASTNode_t.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
const ASTNode_t*
AssignmentRule_getMath(const AssignmentRule_t * ar);


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
 * @return the formula for this AssignmentRule_t.
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
const char *
AssignmentRule_getFormula (const AssignmentRule_t *r);


/**
 * Predicate returning @c 1 if the given AssignmentRule_t structure's "variable"
 * is set.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @return @c 1 if the "variable" of this AssignmentRule_t structure is
 * set, @c 0 otherwise.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_isSetVariable(const AssignmentRule_t * ar);


/**
 * Predicate returning @c 1 if the given AssignmentRule_t structure's "math"
 * is set.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @return @c 1 if the "math" of this AssignmentRule_t structure is
 * set, @c 0 otherwise.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_isSetMath(const AssignmentRule_t * ar);


/**
 * @return true (non-zero) if the formula (or equivalently the math) for
 * this AssignmentRule_t is set, false (0) otherwise.
 *
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_isSetFormula (const AssignmentRule_t *r);


/**
 * Sets the "variable" attribute of the given AssignmentRule_t structure.
 *
 * This function copies the string given in @p string.  If the string is
 * a null pointer, this function performs AssignmentRule_unsetVariable() instead.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @param variable the string to which the structures "variable" attribute should be
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
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_setVariable(AssignmentRule_t * ar, const char * variable);


/**
 * Sets the mathematical expression of the given AssignmentRule_t structure.
 *
 * @param ar the AssignmentRule_t structure.
 *
 * @param math an ASTNode_t structure to be assigned as the "math"
 * subelement of this AssignmentRule_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_setMath(AssignmentRule_t * ar, const ASTNode_t* math);


/**
 * Sets the formula of this AssignmentRule_t to a copy of string.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @memberof AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_setFormula (AssignmentRule_t *r, const char *formula);


/**
 * Predicate returning @c 1 or *c 0 depending on whether all the required
 * attributes of the given AssignmentRule_t structure have been set.
 *
 * @param ar the AssignmentRule_t structure to check.
 *
 * @return @c 1 if all the required attributes for this
 * structure have been defined, @c 0 otherwise.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_hasRequiredAttributes(const AssignmentRule_t * ar);


/**
 * Predicate returning @c 1 or *c 0 depending on whether all the required
 * sub-elements of the given AssignmentRule_t structure have been set.
 *
 * @param ar the AssignmentRule_t structure to check.
 *
 * @return @c 1 if all the required sub-elements for this
 * structure have been defined, @c 0 otherwise.
 *
 * @member of AssignmentRule_t
 */
LIBSBML_EXTERN
int
AssignmentRule_hasRequiredElements(const AssignmentRule_t * ar);




END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG  */
#endif  /* AssignmentRule_h */

