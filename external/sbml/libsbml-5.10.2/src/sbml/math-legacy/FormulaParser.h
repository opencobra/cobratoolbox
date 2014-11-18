/**
 * @file    FormulaParser.h
 * @brief   Parses an SBML formula string into an AST.
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
 * ---------------------------------------------------------------------- -->*/

#ifndef FormulaParser_h
#define FormulaParser_h


#include <sbml/common/extern.h>
#include <sbml/util/Stack.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaTokenizer.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Parses the given SBML formula and returns a representation of it as an
 * Abstract Syntax Tree (AST).
 *
 * @copydetails doc_summary_of_string_math 
 *
 * @copydetails doc_warning_L1_math_string_syntax
 * 
 * @param formula the text-string formula expression to be parsed
 *
 * @return the root node of the AST corresponding to the @p formula, or @c
 * NULL if an error occurred in parsing the formula
 *
 * @if clike @see SBML_formulaToString()
 * @see SBML_parseL3FormulaWithSettings()
 * @see SBML_parseL3Formula()
 * @see SBML_parseL3FormulaWithModel()
 * @see SBML_getLastParseL3Error()
 * @see SBML_getDefaultL3ParserSettings()
 * @endif@~
 * @if csharp @see SBML_formulaToString()
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
 */
LIBSBML_EXTERN
ASTNode_t *
SBML_parseFormula (const char *formula);


/** @cond doxygenLibsbmlInternal */

#ifndef SWIG


/**
 * @return the action for the current state and token.
 *
 * ACCEPT_STATE and ERROR_STATE are special and should be tested for first.
 *
 * Postive actions less-than represent shifts.  Negative actions greater
 * than represent reductions by a grammar rule.
 */
long
FormulaParser_getAction (long state, Token_t *token);

/**
 * @return the number of consective tokens in the Action[] table for the
 * given token type.
 *
 * This function is machine-generated.  DO NOT EDIT.
 */
long
FormulaParser_getActionLength (TokenType_t type);

/**
 * @return the starting offset into the Action[] table for the given token
 * type.
 *
 * This function is machine-generated.  DO NOT EDIT.
 */
long
FormulaParser_getActionOffset (TokenType_t type);

/**
 * @return the next (or goto) state for the current state and grammar rule.
 *
 * ERROR_STATE is special and should be tested for first.
 */
long
FormulaParser_getGoto (long state, long rule);

/**
 * Reduces the given stack (containing SLR parser states and ASTNodes) by
 * the given grammar rule.
 */
ASTNode_t *
FormulaParser_reduceStackByRule (Stack_t *stack, long rule);


#endif  /* !SWIG */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

/** @endcond */

#endif  /* FormulaParser_h */
