/**
 * @file    FormulaParser.c
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

#include <sbml/common/common.h>

#include <sbml/math/FormulaTokenizer.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/ASTTypes.h>


/** @cond doxygenLibsbmlInternal */


/**
 * The FormulaParser is a Simple Left-to-right Rightmost-derivation (SLR)
 * shift-reduce parser.
 *
 * The Action / Goto table for this parser is shown below:
 * <pre>

-----+---------------------------------------------+--------------------------
     |                    Action                   |          Goto
-----+---------------------------------------------+--------------------------
State| Id  Num  (   )   ^   *   /   +   -   ,   $  | Expr  Stmt  Args  OptArgs
-----+---------------------------------------------+--------------------------
    0| s6  s1   s3                      s5         |   4     2
    1|              r9      r9  r9  r9  r9  r9  r9 |
    2|                                          acc|
    3| s6  s1  s3                       s5         |   7
    4|                  s10 s12 s9  s8  s11     r1 |
    5| s6  s1  s3                       s5         |  13
    6|         s14  r10 r10 r10 r10 r10 r10 r10 r10|
    7|              s15 s10 s12 s9  s8  s11        |
    8| s6  s1  s3                       s5         |  16
    9| s6  s1  s3                       s5         |  17
   10| s6  s1  s3                       s5         |  18
   11| s6  s1  s3                       s5         |  19
   12| s6  s1  s3                       s5         |  20
   13|              r7  r7  r7  r7  r7  r7  r7  r7 |
   14| s6  s1  s3   r12                 s5         |  23           22       21
   15|              r8  r8  r8  r8  r8  r8  r8  r8 |
   16|              r2  s10 s12 s9  r2  r2  r2  r2 |
   17|              r5  s10 r5  r5  r5  r5  r5  r5 |
   18|              r6  r6  r6  r6  r6  r6  r6  r6 |
   19|              r3  s10 s12 s9  r3  r3  r3  r3 |
   20|              r4  s10 r4  r4  r4  r4  r4  r4 |
   21|              s24                            |
   22|              r13                     s25    |
   23|              r14 s10 s12 s9  s8  s11 r14    |
   24|              r11 r11 r11 r11 r11 r11 r11 r11|
   25| s6  s1  s3                       s5         |  26
   26|              r15 s10 s12 s9  s8  s11 r15    |      
-----+---------------------------------------------+--------------------------

*
* The Grammar rules are:
*
*   %Rule 1     Stmt    -> Expr
*   %Rule 2     Expr    -> Expr PLUS   Expr
*   %Rule 3     Expr    -> Expr MINUS  Expr
*   %Rule 4     Expr    -> Expr TIMES  Expr
*   %Rule 5     Expr    -> Expr DIVIDE Expr
*   %Rule 6     Expr    -> Expr POWER  Expr
*   %Rule 7     Expr    -> MINUS Expr
*   %Rule 8     Expr    -> LPAREN Expr RPAREN
*   %Rule 9     Expr    -> NUMBER
*   %Rule 10    Expr    -> NAME
*   %Rule 11    Expr    -> NAME LPAREN OptArgs RPAREN
*   %Rule 12    OptArgs -> [empty]
*   %Rule 13    OptArgs -> Args
*   %Rule 14    Args    -> Expr
*   %Rule 15    Args    -> Args COMMA Expr
* </pre>
*
* Both are implemented in a reasonably compact form in the code below.
*
* For more information, see "Compilers: Principles, Techniques, and Tools",
* by Aho, Sethi, and Ullman, Chapter 4, Section 4.7: LR Parsers (p. 216).
*/


#define START_STATE   0
#define ACCEPT_STATE  0
#define ERROR_STATE  27


typedef struct
{
  char state;
  char action;
} StateActionPair_t;


/**
 * Each Action[] table entry is a state action pair.  Positive action
 * numbers represent a "shift and goto that state" action.  Negative action
 * numbers represent a "reduce by that production number" action.
 *
 * To lookup an action, use the FormulaParser_getAction() function.
 *
 * This is machine-generated.  DO NOT EDIT.
 */
static const StateActionPair_t Action[] =
{
  { 0,   6},  /* TT_NAME:     0 */
  { 3,   6},  /* TT_NAME:     1 */
  { 5,   6},  /* TT_NAME:     2 */
  { 8,   6},  /* TT_NAME:     3 */
  { 9,   6},  /* TT_NAME:     4 */
  {10,   6},  /* TT_NAME:     5 */
  {11,   6},  /* TT_NAME:     6 */
  {12,   6},  /* TT_NAME:     7 */
  {14,   6},  /* TT_NAME:     8 */
  {25,   6},  /* TT_NAME:     9 */

  { 0,   1},  /* TT_NUMBER:  10 */
  { 3,   1},  /* TT_NUMBER:  11 */
  { 5,   1},  /* TT_NUMBER:  12 */
  { 8,   1},  /* TT_NUMBER:  13 */
  { 9,   1},  /* TT_NUMBER:  14 */
  {10,   1},  /* TT_NUMBER:  15 */
  {11,   1},  /* TT_NUMBER:  16 */
  {12,   1},  /* TT_NUMBER:  17 */
  {14,   1},  /* TT_NUMBER:  18 */
  {25,   1},  /* TT_NUMBER:  19 */

  { 1,  -9},  /* TT_PLUS:    20 */
  { 4,   8},  /* TT_PLUS:    21 */
  { 6, -10},  /* TT_PLUS:    22 */
  { 7,   8},  /* TT_PLUS:    23 */
  {13,  -7},  /* TT_PLUS:    24 */
  {15,  -8},  /* TT_PLUS:    25 */
  {16,  -2},  /* TT_PLUS:    26 */
  {17,  -5},  /* TT_PLUS:    27 */
  {18,  -6},  /* TT_PLUS:    28 */
  {19,  -3},  /* TT_PLUS:    29 */
  {20,  -4},  /* TT_PLUS:    30 */
  {23,   8},  /* TT_PLUS:    31 */
  {24, -11},  /* TT_PLUS:    32 */
  {26,   8},  /* TT_PLUS:    33 */

  { 0,   5},  /* TT_MINUS:   34 */
  { 1,  -9},  /* TT_MINUS:   35 */
  { 3,   5},  /* TT_MINUS:   36 */
  { 4,  11},  /* TT_MINUS:   37 */
  { 5,   5},  /* TT_MINUS:   38 */
  { 6, -10},  /* TT_MINUS:   39 */
  { 7,  11},  /* TT_MINUS:   40 */
  { 8,   5},  /* TT_MINUS:   41 */
  { 9,   5},  /* TT_MINUS:   42 */
  {10,   5},  /* TT_MINUS:   43 */
  {11,   5},  /* TT_MINUS:   44 */
  {12,   5},  /* TT_MINUS:   45 */
  {13,  -7},  /* TT_MINUS:   46 */
  {14,   5},  /* TT_MINUS:   47 */
  {15,  -8},  /* TT_MINUS:   48 */
  {16,  -2},  /* TT_MINUS:   49 */
  {17,  -5},  /* TT_MINUS:   50 */
  {18,  -6},  /* TT_MINUS:   51 */
  {19,  -3},  /* TT_MINUS:   52 */
  {20,  -4},  /* TT_MINUS:   53 */
  {23,  11},  /* TT_MINUS:   54 */
  {24, -11},  /* TT_MINUS:   55 */
  {25,   5},  /* TT_MINUS:   56 */
  {26,  11},  /* TT_MINUS:   57 */

  { 1,  -9},  /* TT_TIMES:   58 */
  { 4,  12},  /* TT_TIMES:   59 */
  { 6, -10},  /* TT_TIMES:   60 */
  { 7,  12},  /* TT_TIMES:   61 */
  {13,  -7},  /* TT_TIMES:   62 */
  {15,  -8},  /* TT_TIMES:   63 */
  {16,  12},  /* TT_TIMES:   64 */
  {17,  -5},  /* TT_TIMES:   65 */
  {18,  -6},  /* TT_TIMES:   66 */
  {19,  12},  /* TT_TIMES:   67 */
  {20,  -4},  /* TT_TIMES:   68 */
  {23,  12},  /* TT_TIMES:   69 */
  {24, -11},  /* TT_TIMES:   70 */
  {26,  12},  /* TT_TIMES:   71 */

  { 1,  -9},  /* TT_DIVIDE:  72 */
  { 4,   9},  /* TT_DIVIDE:  73 */
  { 6, -10},  /* TT_DIVIDE:  74 */
  { 7,   9},  /* TT_DIVIDE:  75 */
  {13,  -7},  /* TT_DIVIDE:  76 */
  {15,  -8},  /* TT_DIVIDE:  77 */
  {16,   9},  /* TT_DIVIDE:  78 */
  {17,  -5},  /* TT_DIVIDE:  79 */
  {18,  -6},  /* TT_DIVIDE:  80 */
  {19,   9},  /* TT_DIVIDE:  81 */
  {20,  -4},  /* TT_DIVIDE:  82 */
  {23,   9},  /* TT_DIVIDE:  83 */
  {24, -11},  /* TT_DIVIDE:  84 */
  {26,   9},  /* TT_DIVIDE:  85 */

  { 1,  -9},  /* TT_POWER:   86 */
  { 4,  10},  /* TT_POWER:   87 */
  { 6, -10},  /* TT_POWER:   88 */
  { 7,  10},  /* TT_POWER:   89 */
  {13,  -7},  /* TT_POWER:   90 */
  {15,  -8},  /* TT_POWER:   91 */
  {16,  10},  /* TT_POWER:   92 */
  {17,  10},  /* TT_POWER:   93 */
  {18,  -6},  /* TT_POWER:   94 */
  {19,  10},  /* TT_POWER:   95 */
  {20,  10},  /* TT_POWER:   96 */
  {23,  10},  /* TT_POWER:   97 */
  {24, -11},  /* TT_POWER:   98 */
  {26,  10},  /* TT_POWER:   99 */

  { 0,   3},  /* TT_LPAREN: 100 */
  { 3,   3},  /* TT_LPAREN: 101 */
  { 5,   3},  /* TT_LPAREN: 102 */
  { 6,  14},  /* TT_LPAREN: 103 */
  { 8,   3},  /* TT_LPAREN: 104 */
  { 9,   3},  /* TT_LPAREN: 105 */
  {10,   3},  /* TT_LPAREN: 106 */
  {11,   3},  /* TT_LPAREN: 107 */
  {12,   3},  /* TT_LPAREN: 108 */
  {14,   3},  /* TT_LPAREN: 109 */
  {25,   3},  /* TT_LPAREN: 110 */

  { 1,  -9},  /* TT_RPAREN: 111 */
  { 6, -10},  /* TT_RPAREN: 112 */
  { 7,  15},  /* TT_RPAREN: 113 */
  {13,  -7},  /* TT_RPAREN: 114 */
  {14, -12},  /* TT_RPAREN: 115 */
  {15,  -8},  /* TT_RPAREN: 116 */
  {16,  -2},  /* TT_RPAREN: 117 */
  {17,  -5},  /* TT_RPAREN: 118 */
  {18,  -6},  /* TT_RPAREN: 119 */
  {19,  -3},  /* TT_RPAREN: 120 */
  {20,  -4},  /* TT_RPAREN: 121 */
  {21,  24},  /* TT_RPAREN: 122 */
  {22, -13},  /* TT_RPAREN: 123 */
  {23, -14},  /* TT_RPAREN: 124 */
  {24, -11},  /* TT_RPAREN: 125 */
  {26, -15},  /* TT_RPAREN: 126 */

  { 1,  -9},  /* TT_COMMA:  127 */
  { 6, -10},  /* TT_COMMA:  128 */
  {13,  -7},  /* TT_COMMA:  129 */
  {15,  -8},  /* TT_COMMA:  130 */
  {16,  -2},  /* TT_COMMA:  131 */
  {17,  -5},  /* TT_COMMA:  132 */
  {18,  -6},  /* TT_COMMA:  133 */
  {19,  -3},  /* TT_COMMA:  134 */
  {20,  -4},  /* TT_COMMA:  135 */
  {22,  25},  /* TT_COMMA:  136 */
  {23, -14},  /* TT_COMMA:  137 */
  {24, -11},  /* TT_COMMA:  138 */
  {26, -15},  /* TT_COMMA:  139 */

  { 1,  -9},  /* TT_END:    140 */
  { 2,   0},  /* TT_END:    141 */
  { 4,  -1},  /* TT_END:    142 */
  { 6, -10},  /* TT_END:    143 */
  {13,  -7},  /* TT_END:    144 */
  {15,  -8},  /* TT_END:    145 */
  {16,  -2},  /* TT_END:    146 */
  {17,  -5},  /* TT_END:    147 */
  {18,  -6},  /* TT_END:    148 */
  {19,  -3},  /* TT_END:    149 */
  {20,  -4},  /* TT_END:    150 */
  {24, -11},  /* TT_END:    151 */
};


/** @endcond */


/**
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
SBML_parseFormula (const char *formula)
{
  long rule, state, action;

  ASTNode_t *node = NULL;

  FormulaTokenizer_t *tokenizer = NULL; 
  Stack_t            *stack     = NULL;
  Token_t            *token     = NULL;

  if (formula == NULL) return NULL;
  
  tokenizer = FormulaTokenizer_createFromFormula(formula);
  token     = FormulaTokenizer_nextToken(tokenizer);
  stack     = Stack_create(20);


  Stack_push(stack, (void *) START_STATE);

  while (1)
  {
    state  = (long) Stack_peek(stack);
    action = FormulaParser_getAction(state, token);

    if (action == ACCEPT_STATE)
    {
      node = Stack_peekAt(stack, 1);
      break;
    }

    else if (action == ERROR_STATE)
    {
      /**
       * Free ASTNodes on the Stack, skip the states.
       */
      while (Stack_size(stack) > 1)
      {
        Stack_pop(stack);
        ASTNode_free( Stack_pop(stack) );
      }

      node = NULL;
      break;
    }

    /**
     * Shift
     */
    else if (action > 0)
    {
      Stack_push( stack, ASTNode_createFromToken(token) );
      Stack_push( stack, (void *) action );

      Token_free(token);
      token = FormulaTokenizer_nextToken(tokenizer);
    }

    /**
     * Reduce
     */
    else if (action < 0)
    {
      rule  = -action;
      node  = FormulaParser_reduceStackByRule(stack, rule);
      state = (long) Stack_peek(stack);

      Stack_push( stack, node );
      Stack_push( stack, (void *) FormulaParser_getGoto(state, rule) );
    }
  }

  FormulaTokenizer_free(tokenizer);
  Stack_free(stack);
  Token_free(token);

  return node;
}


/** @cond doxygenLibsbmlInternal */

/**
 * @return the action for the current state and token.
 *
 * ACCEPT_STATE and ERROR_STATE are special and should be tested for first.
 *
 * Postive actions less-than represent shifts.  Negative actions greater
 * than represent reductions by a grammar rule.
 */
long
FormulaParser_getAction (long state, Token_t *token)
{
  long result = ERROR_STATE;
  long n, max;

  if (token == NULL) return ERROR_STATE;

  n   = FormulaParser_getActionOffset(token->type);
  max = FormulaParser_getActionLength(token->type) + n;

  for ( ; n < max; n++)
  {
    if (Action[n].state == state)
    {
      result = Action[n].action;
      break;
    }
  }

  return result;
}


/**
 * @return the number of consective tokens in the Action[] table for the
 * given token type.
 *
 * This function is machine-generated.  DO NOT EDIT.
 */
long
FormulaParser_getActionLength (TokenType_t type)
{
  long result;


  /**
   * This cannot be reduced to an array lookup as the TokenTypes are far
   * from consecutive.
   */
  switch (type)
  {
    case TT_NAME:    result =  10; break;
    case TT_INTEGER: result =  10; break;
    case TT_REAL:    result =  10; break;
    case TT_REAL_E:  result =  10; break;
    case TT_PLUS:    result =  14; break;
    case TT_MINUS:   result =  24; break;
    case TT_TIMES:   result =  14; break;
    case TT_DIVIDE:  result =  14; break;
    case TT_POWER:   result =  14; break;
    case TT_LPAREN:  result =  11; break;
    case TT_RPAREN:  result =  16; break;
    case TT_COMMA:   result =  13; break;
    case TT_END:     result =  12; break;
    default:         result =  -1; break;
  }

  return result;
}


/**
 * @return the starting offset into the Action[] table for the given token
 * type.
 *
 * This function is machine-generated.  DO NOT EDIT.
 */
long
FormulaParser_getActionOffset (TokenType_t type)
{
  long result;


  /**
   * This cannot be reduced to an array lookup as the TokenTypes are far
   * from consecutive.
   */
  switch (type)
  {
    case TT_NAME:    result =   0; break;
    case TT_INTEGER: result =  10; break;
    case TT_REAL:    result =  10; break;
    case TT_REAL_E:  result =  10; break;
    case TT_PLUS:    result =  20; break;
    case TT_MINUS:   result =  34; break;
    case TT_TIMES:   result =  58; break;
    case TT_DIVIDE:  result =  72; break;
    case TT_POWER:   result =  86; break;
    case TT_LPAREN:  result = 100; break;
    case TT_RPAREN:  result = 111; break;
    case TT_COMMA:   result = 127; break;
    case TT_END:     result = 140; break;
    default:         result =  -1; break;
  }

  return result;
}


/**
 * @return the next (or goto) state for the current state and grammar rule.
 *
 * ERROR_STATE is special and should be tested for first.
 */
long
FormulaParser_getGoto (long state, long rule)
{
  long result = ERROR_STATE;


  if (rule == 1 && state == 0)
  {
    result = 2;
  }
  if (rule >= 2 && rule <= 11)
  {
    switch (state)
    {
      case  0: result =  4; break;
      case  3: result =  7; break;
      case  5: result = 13; break;
      case  8: result = 16; break;
      case  9: result = 17; break;
      case 10: result = 18; break;
      case 11: result = 19; break;
      case 12: result = 20; break;
      case 14: result = 23; break;
      case 25: result = 26; break;
    }
  }
  else if ((rule == 12 || rule == 13) && state == 14)
  {
    result = 21;
  }
  else if ((rule == 14 || rule == 15) && state == 14)
  {
    result = 22;
  }

  return result;
}


/**
 * Reduces the given stack (containing SLR parser states and ASTNodes) by
 * the given grammar rule.
 */
ASTNode_t *
FormulaParser_reduceStackByRule (Stack_t *stack, long rule)
{
  ASTNode_t *result = NULL;
  ASTNode_t *lexpr, *rexpr, *operator;

  /**
   * Rule  1: Stmt    -> Expr
   * Rule  9: Expr    -> NUMBER
   * Rule 10: Expr    -> NAME
   * Rule 13: OptArgs -> Args
   */
  if (rule == 1 || rule == 9 || rule == 10 || rule == 13)
  {
    Stack_pop(stack);
    result = Stack_pop(stack);

    if (rule == 10)
    {
      /**
       * Convert result to a recognized L2 function constant (if
       * applicable).
       */
      ASTNode_canonicalize(result);
    }
  }

  /**
   * Rule 2: Expr -> Expr PLUS   Expr
   * Rule 3: Expr -> Expr MINUS  Expr
   * Rule 4: Expr -> Expr TIMES  Expr
   * Rule 5: Expr -> Expr DIVIDE Expr
   * Rule 6: Expr -> Expr POWER  Expr
   */
  else if (rule >= 2 && rule <= 6)
  {
    Stack_pop(stack);
    rexpr = Stack_pop(stack);

    Stack_pop(stack);
    operator = Stack_pop(stack);

    Stack_pop(stack);
    lexpr = Stack_pop(stack);

    ASTNode_addChild(operator, lexpr);
    ASTNode_addChild(operator, rexpr);

    result = operator;
  }

  /**
   * Rule 7: Expr -> MINUS Expr
   */
  else if (rule == 7)
  {
    Stack_pop(stack);
    lexpr = Stack_pop(stack);

    Stack_pop(stack);
    operator = Stack_pop(stack);

    /**
     * Perform a simple tree reduction, if possible.
     *
     * If Expr is an AST_INTEGER or AST_REAL (or AST_REAL_E), simply negate
     * the numeric value.  Otheriwse, a (unary) AST_MINUS node should be
     * returned.
     */
    if (ASTNode_getType(lexpr) == AST_INTEGER)
    {
      ASTNode_setInteger(lexpr, - ASTNode_getInteger(lexpr));
      ASTNode_free(operator);
      result = lexpr;
    }
    else if ( ASTNode_getType(lexpr) == AST_REAL)
    {
      ASTNode_setReal(lexpr, - ASTNode_getReal(lexpr));
      ASTNode_free(operator);
      result = lexpr;
    }
    else if (ASTNode_getType(lexpr) == AST_REAL_E)
    {
      ASTNode_setRealWithExponent( lexpr,
                                   - ASTNode_getMantissa(lexpr),
                                     ASTNode_getExponent(lexpr) );
      ASTNode_free(operator);
      result = lexpr;
    }
    else
    {
      ASTNode_addChild(operator, lexpr);
      result = operator;
    }
  }

  /**
   * Rule 8: Expr -> LPAREN Expr RPAREN
   */
  else if (rule == 8)
  {
    Stack_pop(stack);
    ASTNode_free( Stack_pop(stack) );

    Stack_pop(stack);
    result = Stack_pop(stack);

    Stack_pop(stack);
    ASTNode_free( Stack_pop(stack) );
  }

  /**
   * Rule 11: Expr -> NAME LPAREN OptArgs RPAREN
   */
  else if (rule == 11)
  {
    Stack_pop(stack);
    ASTNode_free( Stack_pop(stack) );

    Stack_pop(stack);
    lexpr = Stack_pop(stack);

    Stack_pop(stack);
    ASTNode_free( Stack_pop(stack) );

    Stack_pop(stack);
    result = Stack_pop(stack);
    ASTNode_setType(result, AST_FUNCTION);

    if (lexpr != NULL)
    {
      /**
       * Swap child pointers.  In effect the NAME / AST_FUNCTION
       * represented by result (which has no children) will "adopt" the
       * children of OptArgs which are the arguments to the AST_FUNCTION.
       *
       * After this, OptArgs (lexpr) is no longer needed.
       */
      ASTNode_swapChildren(lexpr, result);
      ASTNode_free(lexpr);
    }

    /**
     * Convert result to a recognized L2 function constant (if applicable).
     */
    ASTNode_canonicalize(result);
  }

  /**
   * Rule 12: OptArgs -> [empty]
   */
  else if (rule == 12)
  {
    result = NULL;
  }

  /**
   * Rule 14: Args -> Expr
   */
  else if (rule == 14)
  {
    Stack_pop(stack);
    lexpr = Stack_pop(stack);


    result = ASTNode_create();
    ASTNode_addChild(result, lexpr);
  }

  /**
   * Rule 15: Args -> Args COMMA Expr
   */
  else if (rule == 15)
  {
    Stack_pop(stack);
    lexpr = Stack_pop(stack);

    Stack_pop(stack);
    ASTNode_free( Stack_pop(stack) );

    Stack_pop(stack);
    result = Stack_pop(stack);

    ASTNode_addChild(result, lexpr);
  }

  return result;
}


/** @endcond */
