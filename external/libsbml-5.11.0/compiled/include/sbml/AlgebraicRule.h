/**
 * @file    AlgebraicRule.h
 * @brief   Definitions of AlgebraicRule.
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
 * @class AlgebraicRule
 * @sbmlbrief{core} An SBML <em>algebraic rule</em> representing <em>0 = f(<b>W</b>)</em>.
 *
 * The rule type AlgebraicRule is derived from the parent class Rule.  It
 * is used to express equations that are neither assignments of model
 * variables nor rates of change.  AlgebraicRule does not add any
 * attributes to the basic Rule; its role is simply to distinguish this
 * case from the other cases.
 *
 * In the context of a simulation, algebraic rules are in effect at all
 * times, <em>t</em> \f$\geq\f$ <em>0</em>.  For purposes of evaluating
 * expressions that involve the delay "csymbol" (see the SBML
 * specification), algebraic rules are considered to apply also at
 * <em>t</em> \f$\leq\f$ <em>0</em>.  Please consult the relevant SBML
 * specification for additional information about the semantics of
 * assignments, rules, and entity values for simulation time <em>t</em>
 * \f$\leq\f$ <em>0</em>.
 *
 * An SBML model must not be overdetermined.  The ability to define
 * arbitrary algebraic expressions in an SBML model introduces the
 * possibility that a model is mathematically overdetermined by the overall
 * system of equations constructed from its rules, reactions and events.
 * Therefore, if an algebraic rule is introduced in a model, for at least
 * one of the entities referenced in the rule's "math" element the value of
 * that entity must not be completely determined by other constructs in the
 * model.  This means that at least this entity must not have the attribute
 * "constant"=@c true and there must also not be a rate rule or assignment
 * rule for it.  Furthermore, if the entity is a Species object, its value
 * must not be determined by reactions, which means that it must either
 * have the attribute "boundaryCondition"=@c true or else not be involved
 * in any reaction at all.  These restrictions are explained in more detail
 * in the SBML specification documents.
 *
 * In SBML Levels 2 and&nbsp;3, Reaction object identifiers can be
 * referenced in the "math" expression of an algebraic rule, but reaction
 * rates can never be <em>determined</em> by algebraic rules.  This is true
 * even when a reaction does not contain a KineticLaw
 * @if conly structure @else object@endif.  (In such cases of missing
 * kinetic law definitions, the model is valid but incomplete; the rates of
 * reactions lacking kinetic laws are simply undefined, and not determined by
 * the algebraic rule.)
 *
 * @copydetails doc_rules_general_summary
 */

#ifndef AlgebraicRule_h
#define AlgebraicRule_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>



#ifdef __cplusplus


#include <string>

#include <sbml/Rule.h>
#include <sbml/SBMLVisitor.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLNamespaces;

class LIBSBML_EXTERN AlgebraicRule : public Rule
{
public:

  /**
   * Creates a new AlgebraicRule object using the given SBML @p level and @p
   * version values.
   *
   * @param level the SBML Level to assign to this AlgebraicRule object.
   *
   * @param version the SBML Version to assign to this AlgebraicRule object.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  AlgebraicRule (unsigned int level, unsigned int version);


  /**
   * Creates a new AlgebraicRule object using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind of
   * SBML object, are either invalid or mismatched with respect to the parent
   * SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  AlgebraicRule (SBMLNamespaces* sbmlns);


  /**
   * Destroys this AlgebraicRule.
   */
  virtual ~AlgebraicRule ();


  /**
   * Creates and returns a deep copy of this AlgebraicRule object.
   *
   * @return the (deep) copy of this Rule object.
   */
  virtual AlgebraicRule* clone () const;


  /**
   * Accepts the given SBMLVisitor for this instance of AlgebraicRule.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next AlgebraicRule object
   * in the list of rules within which @em the present object is embedded.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /** @cond doxygenLibsbmlInternal */

  /**
   * sets the mInternalIdOnly flag
   */

  void setInternalIdOnly();
  bool getInternalIdOnly() const;

  /** @endcond */


  /**
   * Predicate returning @c true if all the required attributes for this
   * AlgebraicRule object have been set.
   *
   * In SBML Levels&nbsp;2&ndash;3, there is no required attribute
   * for an AlgebraicRule object.  For Level&nbsp;1, the only required
   * attribute is "formula".
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


protected:
  /** @cond doxygenLibsbmlInternal */

  bool mInternalIdOnly;

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
 * Creates a new AlgebraicRule_t structure using the given SBML @p level and
 * @p version values.
 *
 * @param level an unsigned int, the SBML level to assign to this
 * AlgebraicRule_t structure.
 *
 * @param version an unsigned int, the SBML version to assign to this
 * AlgebraicRule_t structure.
 *
 * @returns the newly-created AlgebraicRule_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_create(unsigned int level, unsigned int version);


/**
 * Creates a new AlgebraicRule_t structure using the given SBMLNamespaces_t
 * structure, @p sbmlns.
 *
 * @copydetails doc_what_are_sbmlnamespaces
 *
 * @param sbmlns an SBMLNamespaces_t structure.
 *
 * @returns the newly-created AlgebraicRule_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_createWithNS(SBMLNamespaces_t* sbmlns);


/**
 * Frees the given AlgebraicRule_t structure.
 * 
 * @param ar the AlgebraicRule_t structure to be freed.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
void
AlgebraicRule_free(AlgebraicRule_t * ar);


/**
 * Creates a deep copy of the given AlgebraicRule_t structure.
 * 
 * @param ar the AlgebraicRule_t structure to be copied.
 *
 * @returns a (deep) copy of the given AlgebraicRule_t structure, or a null
 * pointer if a failure occurred.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_clone(AlgebraicRule_t * ar);


/**
 * Gets the mathematical expression of this AlgebraicRule_t structure as an
 * ASTNode_t structure.
 *
 * @param ar the AlgebraicRule_t structure.
 *
 * @return the math for this AlgebraicRule_t, as an ASTNode_t.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
const ASTNode_t*
AlgebraicRule_getMath(const AlgebraicRule_t * ar);


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
 * @return the formula for this AlgebraicRule_t.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
const char *
AlgebraicRule_getFormula (const AlgebraicRule_t *r);


/**
 * Predicate returning @c 1 if the given AlgebraicRule_t structure's "math"
 * is set.
 *
 * @param ar the AlgebraicRule_t structure.
 *
 * @return @c 1 if the "math" of this AlgebraicRule_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_isSetMath(const AlgebraicRule_t * ar);


/**
 * @return true (non-zero) if the formula (or equivalently the math) for
 * this AlgebraicRule_t is set, false (0) otherwise.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_isSetFormula (const AlgebraicRule_t *r);


/**
 * Sets the mathematical expression of the given AlgebraicRule_t structure.
 *
 * @param ar the AlgebraicRule_t structure.
 *
 * @param math an ASTNode_t structure to be assigned as the "math"
 * subelement of this AlgebraicRule_t.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_setMath(AlgebraicRule_t * ar, const ASTNode_t* math);


/**
 * Sets the formula of this AlgebraicRule_t to a copy of string.
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
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_setFormula (AlgebraicRule_t *r, const char *formula);


/**
 * Predicate returning @c 1 or *c 0 depending on whether all the required
 * attributes of the given AlgebraicRule_t structure have been set.
 *
 * @param ar the AlgebraicRule_t structure to check.
 *
 * @return @c 1 if all the required attributes for this
 * structure have been defined, @c 0 otherwise.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_hasRequiredAttributes(const AlgebraicRule_t * ar);


/**
 * Predicate returning @c 1 or *c 0 depending on whether all the required
 * sub-elements of the given AlgebraicRule_t structure have been set.
 *
 * @param ar the AlgebraicRule_t structure to check.
 *
 * @return @c 1 if all the required sub-elements for this
 * structure have been defined, @c 0 otherwise.
 *
 * @memberof AlgebraicRule_t
 */
LIBSBML_EXTERN
int
AlgebraicRule_hasRequiredElements(const AlgebraicRule_t * ar);




END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG  */
#endif  /* AlgebraicRule_h */

