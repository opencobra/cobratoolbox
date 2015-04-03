/**
 * @file    L3Parser.h
 * @brief   Definition of the level 3 infix-to-mathml parser C functions.
 * @author  Lucian Smith
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

#ifndef L3Parser_h
#define L3Parser_h

#include <sbml/common/extern.h>
#include <sbml/math/ASTNode.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Parses a text string as a mathematical formula and returns an AST
 * representation of it.
 *
 * @copydetails doc_summary_of_string_math_l3
 *
 * @param formula the text-string formula expression to be parsed
 *
 * @return the root node of an AST representing the mathematical formula, or
 * @c NULL if an error occurred while parsing the formula.  When @c NULL is
 * returned, an error is recorded internally; information about the error can
 * be retrieved using @sbmlfunction{getLastParseL3Error,}.
 *
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * @see @sbmlfunction{formulaToL3String, ASTNode}
 * @see @sbmlfunction{formulaToString, ASTNode}
 * @see L3ParserSettings
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
 * @see @sbmlfunction{getLastParseL3Error,}
 *
 * @copydetails doc_note_math_string_syntax
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
SBML_parseL3Formula (const char *formula);


/**
 * Parses a text string as a mathematical formula using a Model to resolve
 * symbols, and returns an AST representation of the result.
 *
 * This is identical to @sbmlfunction{parseL3Formula, String}, except
 * that this function uses the given model in the argument @p model to check
 * against identifiers that appear in the @p formula.  For more information
 * about the parser, please see the definition of L3ParserSettings and
 * the function @sbmlfunction{parseL3Formula, String}.
 *
 * @param formula the mathematical formula expression to be parsed
 *
 * @param model the Model object to use for checking identifiers
 *
 * @return the root node of an AST representing the mathematical formula,
 * or @c NULL if an error occurred while parsing the formula.  When @c NULL
 * is returned, an error is recorded internally; information about the
 * error can be retrieved using @sbmlfunction{getLastParseL3Error,}.
 *
 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{getLastParseL3Error,}
 * @see L3ParserSettings
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
SBML_parseL3FormulaWithModel (const char *formula, const Model_t * model);


/**
 * Parses a text string as a mathematical formula using specific parser
 * settings and returns an AST representation of the result.
 *
 * This is identical to @sbmlfunction{parseL3Formula, String}, except
 * that this function uses the parser settings given in the argument @p
 * settings.  The settings override the default parsing behavior.  The
 * following parsing behaviors can be configured:
 *
 * @copydetails doc_l3_parser_configuration_options
 *
 * For more details about the parser, please see the definition of
 * L3ParserSettings and @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings}.
 *
 * @param formula the mathematical formula expression to be parsed
 *
 * @param settings the settings to be used for this parser invocation
 *
 * @return the root node of an AST representing the mathematical formula,
 * or @c NULL if an error occurred while parsing the formula.  When @c NULL
 * is returned, an error is recorded internally; information about the
 * error can be retrieved using @sbmlfunction{getLastParseL3Error,}.
 *
 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{getLastParseL3Error,}
 * @see L3ParserSettings
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
SBML_parseL3FormulaWithSettings (const char *formula, const L3ParserSettings_t *settings);


/**
 * Returns a copy of the default Level&nbsp;3 ("L3") formula parser settings.
 *
 * The data structure storing the settings allows callers to change the
 * following parsing behaviors:
 *
 * @copydetails doc_summary_of_string_math_l3
 *
 * For more details about the parser, please see the definition of
 * L3ParserSettings and @sbmlfunction{parseL3Formula, String}.
 *
 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * @see L3ParserSettings
 *
 * @if conly
 * @memberof L3ParserSettings_t
 * @endif
 */
LIBSBML_EXTERN
L3ParserSettings_t*
SBML_getDefaultL3ParserSettings ();


/**
 * Returns the last error reported by the "L3" mathematical formula parser.
 *
 * If the functions @sbmlfunction{parseL3Formula, String},
 * @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings}, or @sbmlfunction{parseL3FormulaWithModel,
 * String\, Model} return @c NULL, an error is set internally.
 * This function allows callers to retrieve information about the error.
 *
 * @return a string describing the error that occurred.  This will contain
 * the input string the parser was trying to parse, the character it had
 * parsed when it encountered the error, and a description of the error.
 *
 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char*
SBML_getLastParseL3Error();


/** @cond doxygenLibsbmlInternal */

LIBSBML_EXTERN
void
SBML_deleteL3Parser();

/** @endcond */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END
#endif /* L3Parser_h */
