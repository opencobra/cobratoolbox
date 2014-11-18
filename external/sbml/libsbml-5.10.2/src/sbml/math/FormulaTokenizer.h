/**
 * @file    FormulaTokenizer.h
 * @brief   Tokenizes an SBML formula string
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
 * ---------------------------------------------------------------------- -->
 *
 * @class FormulaTokenizer
 * @sbmlbrief{core} Tokenizes a math formula in SBML Level 1 syntax.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This file contains functions to tokenize a text string containing a
 * mathematical formula in SBML Level&nbsp;1 syntax.  The first entry
 * point is the function FormulaTokenizer_createFromFormula(), which
 * returns a FormulaTokenizer_t structure.  The structure tracks the
 * current position in the string to be tokenized, and can be handed
 * to other functions such as FormulaTokenizer_nextToken().  Tokens
 * are returned as Token_t structures.
 *
 * @section Token_t The Token_t structure
 *
 * The Token_t structure is used to store a token returned by
 * FormulaTokenizer_nextToken().  It contains a union whose members
 * can store different types of tokens, such as numbers and symbols.
 *
 * @section FormulaTokenizer_t The FormulaTokenizer_t structure
 *
 * An instance of a FormulaTokenizer_t maintains its own internal copy of
 * the formula being tokenized and the current position within the formula
 * string.  Callers do not need to manipulate the fields of a
 * FormulaTokenizer_t structure themselves; instances of FormulaTokenizer_t
 * are only meant to be passed around between the functions of the formula
 * tokenizer system, such as FormulaTokenizer_createFromFormula() and
 * FormulaTokenizer_getName().
 *
 * @copydetails doc_note_l3_parser_encouraged
 *
 * @copydetails doc_note_math_string_syntax
 */

#ifndef FormulaTokenizer_h
#define FormulaTokenizer_h


#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * @struct FormulaTokenizer_t
 * @sbmlbrief{core} Tracks the state of tokenizing a formula string.
 *
 * This structure (FormulaTokenizer_t) are part of the simpler mathematical
 * formula translation system designed to help convert between SBML
 * Level&nbsp;1 and Levels&nbsp;2 and&nbsp;3.  SBML Level&nbsp;1 uses a
 * simple text-string representation of mathematical formulas, rather than
 * the MathML-based representation used in SBML Levels&nbsp;2 and&nbsp;3.
 * LibSBML implements a parser and converter to translate formulas between
 * this text-string representation and MathML.  The principal entry points to
 * the translation system are @sbmlfunction{formulaToString, String}
 * and @sbmlfunction{parseFormula, ASTNode}.
 *
 * LibSBML also provides a lower-level interface to the formula parser.
 * This takes the form of the C functions
 * FormulaTokenizer_createFromFormula() and FormulaTokenizer_nextToken().
 * The structure FormulaTokenizer_t is used to store the current parser
 * state when callers invoke these methods.
 * 
 * An instance of a FormulaTokenizer_t maintains its own internal copy of
 * the formula being tokenized and the current position within the formula
 * string.  The field @c formula holds the former, and the field @c pos
 * holds the latter.  Callers do not need to manipulate these fields
 * themselves; instances of FormulaTokenizer_t are only meant to be
 * passed around between the functions of the formula tokenizer system.
 *
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{formulaToString, ASTNode}
 *
 * @copydetails doc_note_l3_parser_encouraged
 */
typedef struct
{
  char         *formula; /*!< Field used to store the formula string. */
  unsigned int  pos;     /*!< Field used to store the current parsing position. */
} FormulaTokenizer_t;


/**
 * @enum TokenType_t
 * Enumeration of possible token types.
 *
 * "TT" is short for "TokenType".
 *
 * @see Token_t
 */
typedef enum
{
    TT_PLUS    = '+' /*!< The '+' token */
  , TT_MINUS   = '-' /*!< The '-' token */
  , TT_TIMES   = '*' /*!< The '*' token */
  , TT_DIVIDE  = '/' /*!< The '/' token */
  , TT_POWER   = '^' /*!< The '^' token */
  , TT_LPAREN  = '(' /*!< The '(' token */
  , TT_RPAREN  = ')' /*!< The ')' token */
  , TT_COMMA   = ',' /*!< The ',' token */
  , TT_END     = '\0'/*!< The end-of-input token */
  , TT_NAME    = 256/*!< The token for a name*/
  , TT_INTEGER /*!< The token for an integer */
  , TT_REAL /*!< The token for a real number (number with a decimal point) */
  , TT_REAL_E /*!< The token for a real number using e-notation*/
  , TT_UNKNOWN /*!< An unknown token */
} TokenType_t;


/**
 * @struct Token_t
 * @sbmlbrief{core} A token from FormulaTokenizer_nextToken().
 * 
 * A Token_t token has a @c type and a @c value.  The @c value field is a
 * union of different possible members; the member that holds the value for
 * a given token (and thus the name of the member that is to be accessed
 * programmatically) depends on the value of the @c TokenType_t field @c
 * type.  The following table lists the possible scenarios:
 *
 * <center>
 * <table border="0" class="text-table width80 normal-font alt-row-colors">
 * <tr><th>Value of the field <code>type</code></th><th>Member within <code>value</code> to use</th></tr>
 * <tr><td><code>TT_NAME</code></td><td><code>name</code></td></tr>
 * <tr><td><code>TT_INTEGER</code></td><td><code>integer</code></td></tr>
 * <tr><td><code>TT_REAL</code></td><td><code>real</code></td></tr>
 * <tr><td><code>TT_REAL</code>_E</td><td><code>real</code> and <code>exponent</code></td></tr>
 * <tr><td><i>Anything else</i></td><td><code>ch</code></td></tr>
 * </table>
 * </center>
 * 
 * If this token encodes a real number in e-notation, @c type will be
 * @c TT_REAL_E instead of @c TT_REAL. The field @c value.real will then contain
 * the mantissa, and the separate field named @c exponent will contain (can you
 * guess?) the exponent.  For example, if we have a pointer to a structure
 * named @c t, then the representation for &quot;<code>1.2e3</code>&quot; will
 * be:
 * @verbatim
t->type       = TT_REAL_E;
t->value.real = 1.2;
t->exponent   = 3;
@endverbatim
 * 
 * When the @c type has a value of @c TT_UNKNOWN, the field @c ch will
 * contain the unrecognized character.  When the type is @c TT_END, the
 * field @c ch will contain @c '\\0'.  For all others, the @c value.ch will
 * contain the corresponding character.
 */
typedef struct
{
  TokenType_t type; /*!< This token's type. */

  union
  {
    char   ch;      /*!< Member used when the token is a character. */
    char   *name;   /*!< Member used when the token is a symbol. */
    long   integer; /*!< Member used when the token is an integer. */
    double real;    /*!< Member used when the token is a real. */
  } value;          /*!< Value of the token. */

  long exponent;    /*!< Secondary field used when the token is a real in e-notation. */

} Token_t;


/**
 * Creates a new FormulaTokenizer_t structure for the given @p formula string
 * and returns a pointer to the structure.
 *
 * SBML Level 1 uses a simple text-string representation of mathematical
 * formulas, rather than the MathML-based representation used in SBML
 * Levels&nbsp;2 and&nbsp;3.  LibSBML implements a parser and converter to
 * translate formulas between this text-string representation and MathML.
 * The first entry point is the function
 * FormulaTokenizer_createFromFormula(), which returns a FormulaTokenizer_t
 * structure.  The structure tracks the current position in the string to
 * be tokenized, and can be handed to other functions such as
 * FormulaTokenizer_nextToken().  Tokens are returned as Token_t
 * structures.
 *
 * @param formula the text string that contains the mathematical formula to
 * be tokenized.
 * 
 * @return a FormulaTokenizer_t structure that tracks the state of tokenizing
 * the string.
 *
 * @see FormulaTokenizer_nextToken()
 * @see FormulaTokenizer_free()
 *
 * @copydetails doc_note_math_string_syntax
 *
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
FormulaTokenizer_t *
FormulaTokenizer_createFromFormula (const char *formula);


/**
 * Frees the given FormulaTokenizer_t structure @p ft.
 *
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
void
FormulaTokenizer_free (FormulaTokenizer_t *ft);


/**
 * Returns the next token in the formula string.
 *
 * SBML Level 1 uses a simple text-string representation of mathematical
 * formulas, rather than the MathML-based representation used in SBML
 * Levels&nbsp;2 and&nbsp;3.  LibSBML implements a parser and converter to
 * translate formulas between this text-string representation and MathML.
 * The first entry point is the function
 * FormulaTokenizer_createFromFormula(), which returns a FormulaTokenizer_t
 * structure.  The structure tracks the current position in the string to
 * be tokenized, and can be handed to other functions such as
 * FormulaTokenizer_nextToken().  Tokens are returned as Token_t
 * structures.
 *
 * An instance of a FormulaTokenizer_t maintains its own internal copy of
 * the formula being tokenized and the current position within the formula
 * string.  Callers do not need to manipulate the fields of a
 * FormulaTokenizer_t structure themselves; instances of FormulaTokenizer_t
 * are only meant to be passed around between the functions of the formula
 * tokenizer system, such as FormulaTokenizer_createFromFormula() and
 * FormulaTokenizer_getName().
 *
 * @param ft the structure tracking the current tokenization state.
 *
 * @return a pointer to a token.  If no more tokens are available, the
 * token type will be @c TT_END.  Please consult the documentation for the
 * structure Token_t for more information about the possible data values it
 * can hold.
 *
 * @see FormulaTokenizer_free()
 * @see FormulaTokenizer_createFromFormula()
 *
 * @copydetails doc_note_math_string_syntax
 *
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
Token_t *
FormulaTokenizer_nextToken (FormulaTokenizer_t *ft);


/** @cond doxygenLibsbmlInternal */

/**
 * Creates a new Token and returns a point to it.
 *
 * @return a pointer to a token.
 *
 * @if conly
 * @memberof Token_t
 * @endif
 */
LIBSBML_EXTERN
Token_t *
Token_create (void);


/**
 * Frees the given Token @p t.
 *
 * @if conly
 * @memberof Token_t
 * @endif
 */
LIBSBML_EXTERN
void
Token_free (Token_t *t);


/**
 * Returns the value of this token as a (long) integer.
 *
 * This function should be called only when the token's type is @c
 * TT_INTEGER.  If the type is @c TT_REAL or @c TT_REAL_E, the function
 * will cope by truncating the number's fractional part.
 *
 * @param t the token to be parsed into an integer.
 *
 * @return the value of the token after it is interpreted as an integer.
 *
 * @if conly
 * @memberof Token_t
 * @endif
 */
long
Token_getInteger (const Token_t *t);


/**
 * Returns the value of this token as a real (double).
 *
 * This function should be called only when the token is a number
 * (@c TT_REAL, @c TT_REAL_E or @c TT_INTEGER).
 *
 * @param t the token to be parsed into a real number.
 *
 * @return the value of the token after it is interpreted as a
 * real number.
 *
 * @if conly
 * @memberof Token_t
 * @endif
 */
double
Token_getReal (const Token_t *t);


/**
 * Negates the numerical value of the given token @p t.
 *
 * The token stored in @p t is modified in place.  This operation is only
 * valid if the token's type is @c TT_INTEGER, @c TT_REAL, or @c TT_REAL_E.
 *
 * @param t the token whose value is to be negated.
 *
 * @if conly
 * @memberof Token_t
 * @endif
 */
void
Token_negateValue (Token_t *t);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

/** @endcond */

#endif  /** FormulaTokenizer_h **/
