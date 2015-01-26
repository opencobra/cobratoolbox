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
 * Converts an AST to a string representation of a formula using a syntax
 * derived from SBML Level&nbsp;1, but extended to include elements from
 * SBML Level&nbsp;2 and SBML Level&nbsp;3.
 *
 * @copydetails doc_summary_of_string_math_l3
 *
 * @param tree the AST to be converted.
 * 
 * @return the formula from the given AST as an SBML Level 3 text-string
 * mathematical formula.  The caller owns the returned string and is
 * responsible for freeing it when it is no longer needed.
 *
 * @if clike @see SBML_formulaToL3String()
 * @see SBML_parseL3FormulaWithSettings()
 * @see SBML_parseL3Formula()
 * @see SBML_parseL3FormulaWithModel()
 * @see SBML_getLastParseL3Error()
 * @see SBML_getDefaultL3ParserSettings()
 * @endif@~
 * @if csharp @see SBML_formulaToL3String()
 * @see SBML_parseL3FormulaWithSettings()
 * @see SBML_parseL3Formula()
 * @see SBML_parseL3FormulaWithModel()
 * @see SBML_getLastParseL3Error()
 * @see SBML_getDefaultL3ParserSettings()
 * @endif@~
 * @if python @see libsbml.formulaToString()
 * @see libsbml.parseL3FormulaWithSettings()
 * @see libsbml.parseL3Formula()
 * @see libsbml.parseL3FormulaWithModel()
 * @see libsbml.getLastParseL3Error()
 * @see libsbml.getDefaultL3ParserSettings()
 * @endif@~
 * @if java @see <code><a href="libsbml.html#formulaToString(org.sbml.libsbml.ASTNode tree)">libsbml.formulaToString(ASTNode tree)</a></code>
 * @see <code><a href="libsbml.html#parseL3FormulaWithSettings(java.lang.String, org.sbml.libsbml.L3ParserSettings)">libsbml.parseL3FormulaWithSettings(String formula, L3ParserSettings settings)</a></code>
 * @see <code><a href="libsbml.html#parseL3Formula(java.lang.String)">libsbml.parseL3Formula(String formula)</a></code>
 * @see <code><a href="libsbml.html#parseL3FormulaWithModel(java.lang.String, org.sbml.libsbml.Model)">parseL3FormulaWithModel(String formula, Model model)</a></code>
 * @see <code><a href="libsbml.html#getLastParseL3Error()">getLastParseL3Error()</a></code>
 * @see <code><a href="libsbml.html#getDefaultL3ParserSettings()">getDefaultL3ParserSettings()</a></code>
 * @endif@~
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
SBML_formulaToL3String (const ASTNode_t *tree);


/**
 * Converts an AST to a string representation of a formula using a syntax
 * basically derived from SBML Level&nbsp;1, with behavior modifiable with
 * custom settings.
 *
 * This function behaves identically to SBML_formulaToL3String(), but 
 * its behavior can be modified by two settings in the @param settings
 * object, namely:
 *
 * @li ParseUnits:  If this is set to 'true' (the default), the function will 
 *     write out the units of any numerical ASTNodes that have them, producing
 *     (for example) "3 mL", "(3/4) m", or "5.5e-10 M".  If this is set to
 *     'false', this function will only write out the number itself ("3",
 *     "(3/4)", and "5.5e-10", in the previous examples).
 *
 * @li CollapseMinus: If this is set to 'false' (the default), the function
 *     will write out explicitly any doubly-nested unary minus ASTNodes,
 *     producing (for example) "--x" or even "-----3.1".  If this is set
 *     to 'true', the function will collapse the nodes before producing the
 *     infix, producing "x" and "-3.1" in the previous examples.
 *
 * All other settings will not affect the behavior of this function:  the
 * 'parseLog' setting is ignored, and "log10(x)", "ln(x)", and "log(x, y)" 
 * are always produced.  Nothing in the Model object is used, and whether
 * Avogadro is a csymbol or not is immaterial to the produced infix.
 *
 * @param tree the AST to be converted.
 * @param settings the L3ParserSettings object used to modify behavior.
 * 
 * @return the formula from the given AST as an SBML Level 3 text-string
 * mathematical formula.  The caller owns the returned string and is
 * responsible for freeing it when it is no longer needed.
 *
 * @see SBML_parseFormula()
 * @see SBML_parseL3Formula()
 * @see SBML_formulaToL3String()
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
 * @return true (non-zero) if the given ASTNode is to be 
 * formatted as a function.
 */
int
L3FormulaFormatter_isFunction (const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * @return true (non-zero) if the given child ASTNode should be grouped
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
 * Formats the given ASTNode as an SBML L1 token and appends the result to
 * the given StringBuffer.
 */
void
L3FormulaFormatter_format (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode as an SBML L1 function name and appends the
 * result to the given StringBuffer.
 */
void
L3FormulaFormatter_formatFunction (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode as an SBML L3 operator and appends the result
 * to the given StringBuffer.
 */
void
L3FormulaFormatter_formatOperator (StringBuffer_t *sb, const ASTNode_t *node);

/**
 * Formats the given ASTNode as a rational number and appends the result to
 * the given StringBuffer.  This amounts to:
 *
 *   "(numerator/denominator)"
 *
 * If the ASTNode has defined units, and the settings object is set to parse units, this function will append
 * a string with that unit name.
 */
void
L3FormulaFormatter_formatRational (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given ASTNode as a real number and appends the result to
 * the given StringBuffer.
 *
 * If the ASTNode has defined units, and the settings object is set to parse units, this function will append
 * a string with that unit name.
 */
void
L3FormulaFormatter_formatReal (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings);


/**
 * Formats the given logical or relational ASTNode as an infix 
 * internal operator and appends the result to the given StringBuffer.
 */
void
L3FormulaFormatter_formatLogicalRelational(StringBuffer_t *sb, const ASTNode_t *node);

/**
 * Visits the given ASTNode node.  This function is really just a
 * dispatcher to either SBML_formulaToL3String_visitFunction() or
 * SBML_formulaToL3String_visitOther().
 */
void
L3FormulaFormatter_visit ( const ASTNode_t *parent,
                           const ASTNode_t *node,
                           StringBuffer_t  *sb, 
                           const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode as a function.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitFunction ( const ASTNode_t *parent,
                                   const ASTNode_t *node,
                                   StringBuffer_t  *sb, 
                                   const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode as the function "log(10, x)" and in doing so,
 * formats it as "log10(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitLog10 ( const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb, 
                                const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode as the function "root(2, x)" and in doing so,
 * formats it as "sqrt(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitSqrt ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode as a unary minus.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitUMinus ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings );


/**
 * Visits the given ASTNode as a unary not.
 */
void
L3FormulaFormatter_visitUNot ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings );
/**
 * Visits the given ASTNode, translating it from the complicated
 * piecewise function to the much simpler 'x % y' form.
 */
void
L3FormulaFormatter_visitModulo ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings );

  /**
 * Visits the given ASTNode and continues the inorder traversal.
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

