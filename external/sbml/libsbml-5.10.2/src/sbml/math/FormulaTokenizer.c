/**
 * @file    FormulaTokenizer.c
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
 * @ingroup core
 * @brief Tokenizes a mathematical formula string in SBML Level 1 syntax.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This file contains functions to tokenize a text string containing a
 * mathematical formula in SBML Level&nbsp;1 syntax.  
 */

#include <ctype.h>
#include <sbml/common/common.h>

#include <sbml/math/FormulaTokenizer.h>


/* Forward references */

/** @cond doxygenLibsbmlInternal */

void Token_convertNaNInf (Token_t *t);

/** @endcond */


/**
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
FormulaTokenizer_t *
FormulaTokenizer_createFromFormula (const char *formula)
{
  FormulaTokenizer_t *ft;

  if (formula == NULL) return NULL;

  ft = (FormulaTokenizer_t *) safe_malloc( sizeof(FormulaTokenizer_t) );

  ft->formula = safe_strdup(formula);
  ft->pos     = 0;

  return ft;
}


/**
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
void
FormulaTokenizer_free (FormulaTokenizer_t *ft)
{
  if (ft == NULL) return;


  safe_free(ft->formula);
  safe_free(ft);
}


/** @cond doxygenInternalLibsbml */

void
FormulaTokenizer_getName (FormulaTokenizer_t *ft, Token_t *t)
{
  char c;
  int  start, stop, len;


  t->type = TT_NAME;

  start = ft->pos;
  c     = ft->formula[ ++ft->pos ];

  while (isalpha(c) || isdigit(c) || c == '_')
  {
    c = ft->formula[ ++ft->pos ];
  }

  stop = ft->pos;
  len  = stop - start;

  t->value.name      = (char *) safe_malloc(len + 1);
  t->value.name[len] = '\0';
  strncpy(t->value.name, ft->formula + start, len);
}


void
FormulaTokenizer_getNumber (FormulaTokenizer_t *ft, Token_t *t)
{
  char c;
  char endchar;
  char *endptr;

  unsigned int start, stop, len;

  unsigned int exppos = 0;
  unsigned int endpos = 0;

  unsigned int seendot = 0;
  unsigned int seenexp = 0;
  unsigned int seensgn = 0;


  start = ft->pos;
  c     = ft->formula[ start ];

  /**
   * ([0-9]+\.?[0-9]*|\.[0-9]+)([eE][-+]?[0-9]+)?
   */
  while (1)
  {
    if (c == '.' && seendot == 0)
    {
      seendot = 1;
    }
    else if ((c == 'e' || c == 'E') && seenexp == 0)
    {
      seenexp = 1;
      exppos  = ft->pos;
    }
    else if ((c == '+' || c == '-') && seenexp == 1 && seensgn == 0)
    {
      seensgn = 1;
    }
    else if (c < '0' || c > '9')
    {
      endchar = c;
      endpos  = ft->pos;
      break;
    }

    c = ft->formula[ ++ft->pos ];
  }

  /*
   * Temporarily terminate ft->formula will a NULL at the character just
   * beyond the end of the number.  This prevents strtod() and strtol()
   * (below) from reading past the end of the number.
   *
   * This prevents at least one obscure bug where something like '3e 4' is
   * understood as one token 3e4 instead of two: 3e0 and 4.
   */
  ft->formula[ endpos ] = '\0';

  stop = ft->pos;
  len  = stop - start;

  /*
   * If the token is composed only of some combination of '.', 'e|E' or
   * '+|-' mark it as TT_UNKNOWN.  Otherwise, strtod() or strtol() should
   * be able to convert it, as all the syntax checking was performed above.
   */
  if (len == (seendot + seenexp + seensgn))
  {
    t->type     = TT_UNKNOWN;
    t->value.ch = ft->formula[start];
  }
  else if (seendot || seenexp)
  {
    /*
     * Temporarily "hide" the exponent part, so strtod below will convert
     * only the mantissa part.
     */
    if (seenexp)
    {
      c                     = ft->formula[ exppos ];
      ft->formula[ exppos ] = '\0';
    }

    t->type       = TT_REAL;
    t->value.real = c_locale_strtod(ft->formula + start, &endptr);

    /*
     * Convert the exponent part and "unhide" it.
     */
    if (seenexp)
    {
      t->type     = TT_REAL_E;
      t->exponent = strtol(ft->formula + exppos + 1, &endptr, 10);

      ft->formula[ exppos ] = c;
    }
  }
  else
  {
    t->type          = TT_INTEGER;
    t->value.integer = strtol(ft->formula + start, &endptr, 10);
  }

  /*
   * Restore the character overwritten above.
   */
  ft->formula[ endpos ] = endchar;
}

/** @endcond */


/**
 * @if conly
 * @memberof FormulaTokenizer_t
 * @endif
 */
LIBSBML_EXTERN
Token_t *
FormulaTokenizer_nextToken (FormulaTokenizer_t *ft)
{
  char     c;
  Token_t *t;
  
  if (ft == NULL) return NULL;
  
  c = ft->formula[ ft->pos ];
  t = Token_create();


  /**
   * Skip whitespace
   */
  while (isspace(c))
  {
    c = ft->formula[ ++ft->pos ];
  }


  if (c == '\0')
  {
    t->type     = TT_END;
    t->value.ch = c;
  }
  else if (c == '+' || c == '-' || c == '*' || c == '/' ||
           c == '^' || c == '(' || c == ')' || c == ',' )
  {
    t->type     = (TokenType_t) c;
    t->value.ch = c;
    ft->pos++;
  }
  else if (isalpha(c) || c == '_')
  {
    FormulaTokenizer_getName(ft, t);
  }
  else if (c == '.' || isdigit(c))
  {
    FormulaTokenizer_getNumber(ft, t);
  }
  else
  {
    t->type     = TT_UNKNOWN;
    t->value.ch = c;
    ft->pos++;
  }

  if (t->type == TT_NAME)
  {
    Token_convertNaNInf(t);
  }

  return t;
}


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
Token_t *
Token_create (void)
{
  Token_t *t = (Token_t *) safe_calloc(1, sizeof(Token_t));


  t->type = TT_UNKNOWN;

  return t;
}


LIBSBML_EXTERN
void
Token_free (Token_t *t)
{
  if (t == NULL) return;


  if (t->type == TT_NAME)
  {
    safe_free(t->value.name);
  }

  safe_free(t);
}


void
Token_convertNaNInf (Token_t *t)
{
  if ( !strcmp_insensitive(t->value.name, "NaN") )
  {
    safe_free(t->value.name);
    t->type       = TT_REAL;
    t->value.real = util_NaN();
  }
  else if ( !strcmp_insensitive(t->value.name, "Inf") )
  {
    safe_free(t->value.name);
    t->type       = TT_REAL;
    t->value.real = util_PosInf();
  }
}


long
Token_getInteger (const Token_t *t)
{
  TokenType_t type   = t->type;
  long        result = 0;


  if (type == TT_INTEGER)
  {
    result = t->value.integer;
  }
  else if (type == TT_REAL || type == TT_REAL_E)
  {
    result = (int) Token_getReal(t);
  }

  return result;
}


double
Token_getReal (const Token_t *t)
{
  TokenType_t type   = t->type;
  double      result = 0.0;


  if (type == TT_REAL || type == TT_REAL_E)
  {
    result = t->value.real;
  
    if (type == TT_REAL_E)
    {
      result *= pow(10,  t->exponent);
    }
  }
  else if (type == TT_INTEGER)
  {
    result = (double) t->value.integer;
  }

  return result;
}


void
Token_negateValue (Token_t *t)
{
  TokenType_t type = t->type;


  if (type == TT_INTEGER)
  {
    t->value.integer = - (t->value.integer);
  }
  else if (type == TT_REAL || type == TT_REAL_E)
  {
    t->value.real = - (t->value.real);
  }
}
/** @endcond */
