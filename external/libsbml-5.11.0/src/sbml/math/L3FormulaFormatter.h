/**
 * @file    L3FormulaFormatter.h
 * @brief   Formats an L3 AST formula tree as an SBML formula string.
 * @author  Lucian Smith
 * 
 * @if conly
 * This file contains the SBML_formulaToL3String() and SBML_formulaToL3StringWithSettings()
 * functions, both associated with the ASTNode_t structure.
 * @endif
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
 * ---------------------------------------------------------------------- -->*/

#ifndef L3FormulaFormatter_h
#define L3FormulaFormatter_h


#include <sbml/common/extern.h>
#include <sbml/util/StringBuffer.h>

#include <sbml/math/ASTNode.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Converts an AST to a text string representation of a formula using an
 * extended syntax.
 *
 * @copydetails doc_summary_of_string_math_l3
 *
 * @param tree the AST to be converted.
 *
 * @return the formula from the given AST as text string, with a syntax
 * oriented towards the capabilities defined in SBML Level&nbsp;3.  The
 * caller owns the returned string and is responsible for freeing it when it
 * is no longer needed.  If @p tree is a null pointer, then a null pointer is
 * returned.
 *
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * @see @sbmlfunction{formulaToString, ASTNode}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see L3ParserSettings
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
 * @see @sbmlfunction{getLastParseL3Error,}
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
SBML_formulaToL3String (const ASTNode_t *tree);


/**
 * Converts an AST to a text string representation of a formula, using
 * specific formatter settings.
 *
 * This function behaves identically to @sbmlfunction{formulaToL3String,
 * ASTNode} but its behavior is controlled by two fields in the @p
 * settings object, namely:
 *
 * @li <em>parseunits</em> ("parse units"): If this field in the @p settings
 *     object is set to <code>true</code> (the default), the function will
 *     write out the units of any numerical ASTNodes that have them,
 *     producing (for example) &quot;<code>3 mL</code>&quot;,
 *     &quot;<code>(3/4) m</code>&quot;, or &quot;<code>5.5e-10
 *     M</code>&quot;.  If this is set to <code>false</code>, this function
 *     will only write out the number itself (&quot;<code>3</code>&quot;,
 *     &quot;<code>(3/4)</code>&quot;, and &quot;<code>5.5e-10</code>&quot;,
 *     in the previous examples).
 * @li <em>collapseminus</em> ("collapse minus"): If this field in the @p
 *     settings object is set to <code>false</code> (the default), the
 *     function will write out explicitly any doubly-nested unary minus
 *     ASTNodes, producing (for example) &quot;<code>- -x</code>&quot; or
 *     even &quot;<code>- - - - -3.1</code>&quot;.  If this is set to
 *     <code>true</code>, the function will collapse the nodes before
 *     producing the infix form, producing &quot;<code>x</code>&quot; and
 *     &quot;<code>-3.1</code>&quot; in the previous examples.
 *
 * All the other settings of the L3ParserSettings object passed in as @p
 * settings will be ignored for the purposes of this function: the
 * <em>parselog</em> ("parse log") setting is ignored so that
 * &quot;<code>log10(x)</code>&quot;, &quot;<code>ln(x)</code>&quot;, and
 * &quot;<code>log(x, y)</code>&quot; are always produced; the
 * <em>avocsymbol</em> ("Avogadro csymbol") is irrelevant to the behavior
 * of this function; and nothing in the Model object set via the
 * <em>model</em> setting is used.
 *
 * @param tree the AST to be converted.

 * @param settings the L3ParserSettings object used to modify the behavior of
 * this function.
 *
 * @return the formula from the given AST as text string, with a syntax
 * oriented towards the capabilities defined in SBML Level&nbsp;3.  The
 * caller owns the returned string and is responsible for freeing it when it
 * is no longer needed.  If @p tree is a null pointer, then a null pointer is
 * returned.
 *
 * @see @sbmlfunction{formulaToL3String, ASTNode}
 * @see @sbmlfunction{formulaToString, ASTNode}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see L3ParserSettings
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
 * @see @sbmlfunction{getLastParseL3Error,}
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
SBML_formulaToL3StringWithSettings (const ASTNode_t *tree, const L3ParserSettings_t *settings);


/** @cond doxygenLibsbmlInternal */

#ifndef SWIG


/**
 * @return true (non-zero) if the given ASTNode_t is to be 
 * formatted as a function.
 */
int
L3FormulaFormatter_isFunction (const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * @return true (non-zero) if the given child ASTNode_t should be grouped
 * (with parenthesis), false (0) otherwise.
 *
 * A node should be group if it is not an argument to a function and
 * either:
 *
 *   - The parent node has higher precedence than the child, or
 *
 *   - If parent node has equal precedence with the child and the child is
 *     to the right.  In this case, operator associativity and right-most
 *     AST derivation enforce the grouping.
 */
int
L3FormulaFormatter_isGrouped (const ASTNode_t *parent, const ASTNode_t *child, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode_t as an SBML L1 token and appends the result to
 * the given StringBuffer_t.
 */
void
L3FormulaFormatter_format (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode_t as an SBML L1 function name and appends the
 * result to the given StringBuffer_t.
 */
void
L3FormulaFormatter_formatFunction (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode_t as an SBML L3 operator and appends the result
 * to the given StringBuffer_t.
 */
void
L3FormulaFormatter_formatOperator (StringBuffer_t *sb, const ASTNode_t *node);

/**
 * Formats the given ASTNode_t as a rational number and appends the result to
 * the given StringBuffer_t.  This amounts to:
 *
 *   "(numerator/denominator)"
 *
 * If the ASTNode_t has defined units, and the settings object is set to parse units, this function will append
 * a string with that unit name.
 */
void
L3FormulaFormatter_formatRational (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode_t as a real number and appends the result to
 * the given StringBuffer_t.
 *
 * If the ASTNode_t has defined units, and the settings object is set to parse units, this function will append
 * a string with that unit name.
 */
void
L3FormulaFormatter_formatReal (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given logical or relational ASTNode_t as an infix 
 * internal operator and appends the result to the given StringBuffer_t.
 */
void
L3FormulaFormatter_formatLogicalRelational(StringBuffer_t *sb, const ASTNode_t *node);

/**
 * Visits the given ASTNode_t node.  This function is really just a
 * dispatcher to either SBML_formulaToL3String_visitFunction() or
 * SBML_formulaToL3String_visitOther().
 */
void
L3FormulaFormatter_visit ( const ASTNode_t *parent,
                           const ASTNode_t *node,
                           StringBuffer_t  *sb, 
                           const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode_t as a function.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitFunction ( const ASTNode_t *parent,
                                   const ASTNode_t *node,
                                   StringBuffer_t  *sb, 
                                   const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode_t as the function "log(10, x)" and in doing so,
 * formats it as "log10(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitLog10 ( const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb, 
                                const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode_t as the function "root(2, x)" and in doing so,
 * formats it as "sqrt(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitSqrt ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode_t as a unary minus.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitUMinus ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode_t as a unary not.
 */
void
L3FormulaFormatter_visitUNot ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings );
/**
 * Visits the given ASTNode_t, translating it from the complicated
 * piecewise function to the much simpler 'x % y' form.
 */
void
L3FormulaFormatter_visitModulo ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings );

/**
 * Visits the given ASTNode_t and continues the inorder traversal.
 */
void
L3FormulaFormatter_visitOther ( const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb, 
                                const L3ParserSettings_t *settings );


#endif  /* !SWIG */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

/** @endcond */

#endif  /* L3FormulaFormatter_h */

