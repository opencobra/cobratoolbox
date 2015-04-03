/**
 * @file    L3FormulaFormatter.c
 * @brief   Formats an AST formula tree as an SBML L3 formula string.
 * @author  Lucian Smith (from FormulaFormatter, by Ben Bornstein)
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

#include <sbml/common/common.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/L3FormulaFormatter.h>
#include <sbml/math/L3ParserSettings.h>
#include <sbml/math/ASTNode.h>
#include <assert.h>

#include <sbml/util/util.h>

int
L3FormulaFormatter_hasUnambiguousGrammar(const ASTNode_t *node, 
                               const ASTNode_t *child, 
                               const L3ParserSettings_t *settings);


/** @cond doxygenIgnored */
LIBSBML_EXTERN
char *
SBML_formulaToL3String (const ASTNode_t *tree)
{
  L3ParserSettings_t* l3ps = L3ParserSettings_create();
  char* ret = SBML_formulaToL3StringWithSettings(tree, l3ps);
  L3ParserSettings_free(l3ps);
  return ret;
}


LIBSBML_EXTERN
char *
SBML_formulaToL3StringWithSettings (const ASTNode_t *tree, const L3ParserSettings_t *settings)
{
  char           *s;
  StringBuffer_t *sb;

  if (tree == NULL)
  {
    return NULL;
  }

  sb = StringBuffer_create(128);
  L3FormulaFormatter_visit(NULL, tree, sb, settings);
  s = StringBuffer_getBuffer(sb);
  safe_free(sb);
  return s;
}
/** @endcond */


/**
 * @cond doxygenLibsbmlInternal
 * The rest of this file is internal code.
 */

/* function used by the isTranslatedModulo function to compare 
 * children of the piecewise that can be used to construct
 * the modulo function
 */
int equals(const ASTNode_t* a, const ASTNode_t* b)
{
  char* ach = SBML_formulaToL3String(a);
  char* bch = SBML_formulaToL3String(b);
  int ret = !strcmp (ach, bch);
  free(ach);
  free(bch);
  return ret;
}

/* Used by getL3Precedence and other functions below.
 */
int isTranslatedModulo (const ASTNode_t* node)
{
  const ASTNode_t* child;
  const ASTNode_t* c2;
  const ASTNode_t* x;
  const ASTNode_t* y;
  //In l3v2 there may be an actual 'modulo' ASTNode, but for now,
  // it's all mimicked by the piecewise function:
  // piecewise(x - y * ceil(x / y), xor(x < 0, y < 0), x - y * floor(x / y))

  if (ASTNode_getType(node) != AST_FUNCTION_PIECEWISE) return 0;
  if (ASTNode_getNumChildren(node) != 3) return 0;

  //x - y * ceil(x/y)
  child = ASTNode_getChild(node, 0);
  if (ASTNode_getType(child) != AST_MINUS) return 0;
  if (ASTNode_getNumChildren(child) != 2) return 0;
  x  = ASTNode_getChild(child, 0);

  c2 = ASTNode_getChild(child, 1);
  if (ASTNode_getType(c2) != AST_TIMES) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  y = ASTNode_getChild(c2, 0);
  c2 = ASTNode_getChild(c2, 1);
  if (ASTNode_getType(c2) != AST_FUNCTION_CEILING) return 0;
  if (ASTNode_getNumChildren(c2) != 1) return 0;
  c2 = ASTNode_getChild(c2, 0);
  if (ASTNode_getType(c2) != AST_DIVIDE) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  if (!equals(x, ASTNode_getChild(c2, 0))) return 0;
  if (!equals(y, ASTNode_getChild(c2, 1))) return 0;

  //xor(x<0, y<0)
  child = ASTNode_getChild(node, 1);
  if (ASTNode_getType(child) != AST_LOGICAL_XOR) return 0;
  if (ASTNode_getNumChildren(child) != 2) return 0;
  c2 = ASTNode_getChild(child, 0);
  if (ASTNode_getType(c2) != AST_RELATIONAL_LT) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  if (!equals(x, ASTNode_getChild(c2, 0))) return 0;
  if (ASTNode_getType(ASTNode_getChild(c2, 1)) != AST_INTEGER) return 0;
  if (ASTNode_getInteger(ASTNode_getChild(c2, 1)) != 0) return 0;
  c2 = ASTNode_getChild(child, 1);
  if (ASTNode_getType(c2) != AST_RELATIONAL_LT) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  if (!equals(y, ASTNode_getChild(c2, 0))) return 0;
  if (ASTNode_getType(ASTNode_getChild(c2, 1)) != AST_INTEGER) return 0;
  if (ASTNode_getInteger(ASTNode_getChild(c2, 1)) != 0) return 0;

  //x - y * floor(x/y)
  child = ASTNode_getChild(node, 2);
  if (ASTNode_getType(child) != AST_MINUS) return 0;
  if (ASTNode_getNumChildren(child) != 2) return 0;
  if (!equals(x, ASTNode_getChild(child, 0))) return 0;

  c2 = ASTNode_getChild(child, 1);
  if (ASTNode_getType(c2) != AST_TIMES) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  if (!equals(y, ASTNode_getChild(c2, 0))) return 0;
  c2 = ASTNode_getChild(c2, 1);
  if (ASTNode_getType(c2) != AST_FUNCTION_FLOOR) return 0;
  if (ASTNode_getNumChildren(c2) != 1) return 0;
  c2 = ASTNode_getChild(c2, 0);
  if (ASTNode_getType(c2) != AST_DIVIDE) return 0;
  if (ASTNode_getNumChildren(c2) != 2) return 0;
  if (!equals(x, ASTNode_getChild(c2, 0))) return 0;
  if (!equals(y, ASTNode_getChild(c2, 1))) return 0;

  return 1;
}


/*
 * @return the precedence of this ASTNode as defined in the L3 parser documentation.
 */
int getL3Precedence(const ASTNode_t* node)
{
  int precedence;
  unsigned int numchildren = ASTNode_getNumChildren(node);

  if ( !ASTNode_hasCorrectNumberArguments((ASTNode_t*)node) )
  {
    //If the number of arguments is wrong, it'll be treated like a function call.
    precedence = 8;
  }
  else if ( isTranslatedModulo(node) )
  {
    precedence = 5;
  }
  else
  {
    switch (ASTNode_getType(node))
    {
      case AST_POWER:
      case AST_FUNCTION_POWER:
        //Anything other than two children is caught above, since that's the only correct number of arguments.
        precedence = 7;
        break;

      case AST_LOGICAL_NOT:
        //Anything other than unary not is caught above, since that's the wrong number of arguments.
        precedence = 6;
        break;

      case AST_DIVIDE:
      case AST_TIMES:
        if (numchildren < 2) {
          //Written in functional form.
          precedence = 8;
        }
        else {
          precedence = 5;
        }
        break;

      case AST_MINUS:
        if (numchildren == 1) {
          //Unary minus
          precedence = 6;
          break;
        }
        //Fallthrough to:
      case AST_PLUS:
        if (numchildren < 2) {
          //Written in functional form (unary minus caught above)
          precedence = 8;
        }
        else {
          precedence = 4;
        }
        break;

      case AST_RELATIONAL_EQ:
      case AST_RELATIONAL_GEQ:
      case AST_RELATIONAL_GT:
      case AST_RELATIONAL_LEQ:
      case AST_RELATIONAL_LT:
      case AST_RELATIONAL_NEQ:
        //The relational symbols (==, >=, etc.) are only used when there are two children.
        if (numchildren == 2) {
          precedence = 3;
        }
        else {
          precedence = 8;
        }
        break;

      case AST_LOGICAL_AND:
      case AST_LOGICAL_OR:
        //The logical symbols && and || are only used when there are two or more children.
        if (numchildren < 2) {
          precedence = 8;
        }
        else {
          precedence = 2;
        }
        break;

      case AST_ORIGINATES_IN_PACKAGE:
        precedence = ASTNode_getL3PackageInfixPrecedence(node);
        break;
      default:
        precedence = 8;
        break;
    }
  }

  return precedence;
}


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
L3FormulaFormatter_isGrouped (const ASTNode_t *parent, const ASTNode_t *child, const L3ParserSettings_t *settings)
{
  int pp, cp;
  int pt, ct;
  int group = 0;
  int parentmodulo = 0;


  if (parent != NULL)
  {
    parentmodulo = isTranslatedModulo(parent);
    if (parentmodulo || !L3FormulaFormatter_hasUnambiguousGrammar(parent, child, settings))
    {
      group = 1;
      pp = getL3Precedence(parent);
      cp = getL3Precedence(child);

      if (pp < cp)
      {
        group = 0;
      }
      else if (pp == cp)
      {
        if (parentmodulo) {
          //Always group:  x * y % z -> (x * y) % z
          group = 1;
        }
        /**
         * Don't group only if i) child is the first on the list and ii) both parent and
         * child are the same type, or if they
         * should be associative operators (i.e. not AST_MINUS or
         * AST_DIVIDE).  That is, do not group a parent and left child
         * that are either both AST_PLUS or both AST_TIMES operators, nor the logical operators
         * that have the same precedence.
         */
        if (ASTNode_getLeftChild(parent) == child)
        {
          pt = ASTNode_getType(parent);
          ct = ASTNode_getType(child);
          if (ASTNode_isLogical(parent) || ASTNode_isRelational(parent)) {
            group = !(pt == ct);
          }
          else {
            group = !((pt == ct) || (pt == AST_PLUS || pt == AST_TIMES));
          }
        }
      }
      else if (pp==7 && cp==6) {
        //If the parent is 'power' and the child is 'unary not' or 'unary minus', we only need
        // to group if the child is the *left* child:  '(-x)^y', but 'x^-y'.
        if (!(ASTNode_getLeftChild(parent) == child)) { 
          group = 0;
        }
      }
    }
  }

  return group;
}


/**
 * Formats the given ASTNode as an SBML L3 token and appends the result to
 * the given StringBuffer.
 */
void
L3FormulaFormatter_format (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings)
{
  if (sb == NULL) return;
  if (L3FormulaFormatter_isFunction(node, settings))
  {
    L3FormulaFormatter_formatFunction(sb, node, settings);
  }
  else if (ASTNode_isOperator(node) || ASTNode_getType(node) == AST_FUNCTION_POWER)
  {
    L3FormulaFormatter_formatOperator(sb, node);
  }
  else if (ASTNode_isLogical(node) || ASTNode_isRelational(node))
  {
    L3FormulaFormatter_formatLogicalRelational(sb, node);
  }
  else if (ASTNode_isRational(node))
  {
    L3FormulaFormatter_formatRational(sb, node, settings);
  }
  else if (ASTNode_isInteger(node))
  {
    L3FormulaFormatter_formatReal(sb, node, settings);
  }
  else if (ASTNode_isReal(node))
  {
    L3FormulaFormatter_formatReal(sb, node, settings);
  }
  else if ( !ASTNode_isUnknown(node) )
  {
    StringBuffer_append(sb, ASTNode_getName(node));
  }
}


/**
 * Formats the given ASTNode as an SBML L3 function name and appends the
 * result to the given StringBuffer.
 */
void
L3FormulaFormatter_formatFunction (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings)
{
  ASTNodeType_t type = ASTNode_getType(node);
  switch (type)
  {
  case AST_PLUS:
    StringBuffer_append(sb, "plus");
    break;
  case AST_TIMES:
    StringBuffer_append(sb, "times");
    break;
  case AST_MINUS:
    StringBuffer_append(sb, "minus");
    break;
  case AST_DIVIDE:
    StringBuffer_append(sb, "divide");
    break;
  case AST_POWER:
    StringBuffer_append(sb, "pow");
    break;
  case AST_FUNCTION_LN:
    StringBuffer_append(sb, "ln");
    break;

  default:
    FormulaFormatter_formatFunction(sb, node);
    break;
  }
}


/**
 * Formats the given ASTNode as an SBML L1 operator and appends the result
 * to the given StringBuffer.
 */
void
L3FormulaFormatter_formatOperator (StringBuffer_t *sb, const ASTNode_t *node)
{
  ASTNodeType_t type = ASTNode_getType(node);

  if (type == AST_FUNCTION_POWER ||
      type == AST_POWER) {
    StringBuffer_appendChar(sb, '^');
  }
  else 
  {
    StringBuffer_appendChar(sb, ' ');
    StringBuffer_appendChar(sb, ASTNode_getCharacter(node));
    StringBuffer_appendChar(sb, ' ');
  }
}


/**
 * Formats the given ASTNode as a rational number and appends the result to
 * the given StringBuffer.  For SBML L1 this amounts to:
 *
 *   "(numerator/denominator)"
 */
void
L3FormulaFormatter_formatRational (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings)
{
  char * units;
  StringBuffer_appendChar( sb, '(');
  StringBuffer_appendInt ( sb, ASTNode_getNumerator(node)   );
  StringBuffer_appendChar( sb, '/');
  StringBuffer_appendInt ( sb, ASTNode_getDenominator(node) );
  StringBuffer_appendChar( sb, ')');

  if (L3ParserSettings_getParseUnits(settings)) {
    if (ASTNode_hasUnits(node)) {
      StringBuffer_appendChar( sb, ' ');
      units = ASTNode_getUnits(node);
      StringBuffer_append( sb, units);
      safe_free(units);
    }
  }
}


/**
 * Formats the given ASTNode as a real number and appends the result to
 * the given StringBuffer.
 */
void
L3FormulaFormatter_formatReal (StringBuffer_t *sb, const ASTNode_t *node, const L3ParserSettings_t *settings)
{
  double value = ASTNode_getReal(node);
  int    sign;
  char * units;

  if (ASTNode_isInteger(node)) {
    value = ASTNode_getInteger(node);
  }

  if (util_isNaN(value))
  {
    StringBuffer_append(sb, "NaN");
  }
  else if ((sign = util_isInf(value)) != 0)
  {
    if (sign == -1)
    {
      StringBuffer_appendChar(sb, '-');
    }

    StringBuffer_append(sb, "INF");
  }
  else if (util_isNegZero(value))
  {
    StringBuffer_append(sb, "-0");
  }
  else
  {
    if (ASTNode_getType(node) == AST_REAL_E)
    {
      StringBuffer_appendExp(sb, value);
    }
    else
    {
      StringBuffer_appendReal(sb, value);
    }
  }
  if (L3ParserSettings_getParseUnits(settings)) {
    if (ASTNode_hasUnits(node)) {
      StringBuffer_appendChar( sb, ' ');
      units = ASTNode_getUnits(node);
      StringBuffer_append( sb, units);
      safe_free(units);
    }
  }
}

/**
 * Formats the given ASTNode as an SBML L1 operator and appends the result
 * to the given StringBuffer.
 */
void
L3FormulaFormatter_formatLogicalRelational (StringBuffer_t *sb, const ASTNode_t *node)
{
  ASTNodeType_t type = ASTNode_getType(node);

  StringBuffer_appendChar(sb, ' ');
  switch(type)
  {
  case AST_LOGICAL_AND:
    StringBuffer_append(sb, "&&");
    break;
  case AST_LOGICAL_OR:
    StringBuffer_append(sb, "||");
    break;
  case AST_RELATIONAL_EQ:
    StringBuffer_append(sb, "==");
    break;
  case AST_RELATIONAL_GEQ:
    StringBuffer_append(sb, ">=");
    break;
  case AST_RELATIONAL_GT:
    StringBuffer_append(sb, ">");
    break;
  case AST_RELATIONAL_LEQ:
    StringBuffer_append(sb, "<=");
    break;
  case AST_RELATIONAL_LT:
    StringBuffer_append(sb, "<");
    break;
  case AST_RELATIONAL_NEQ:
    StringBuffer_append(sb, "!=");
    break;
  case AST_LOGICAL_NOT:
  case AST_LOGICAL_XOR:
  default:
    //Should never be called for these cases; unary not is
    // handled by checking unary not earlier; xor always
    // claims that it's a function, and is caught with 'isFunction'
    assert(0); 
    StringBuffer_append(sb, "!!");
    break;
  }
  StringBuffer_appendChar(sb, ' ');
}


/**
 * Visits the given ASTNode node.  This function is really just a
 * dispatcher to either SBML_formulaToL3String_visitFunction() or
 * SBML_formulaToL3String_visitOther().
 */
void
L3FormulaFormatter_visit ( const ASTNode_t *parent,
                           const ASTNode_t *node,
                           StringBuffer_t  *sb, 
                           const L3ParserSettings_t *settings )
{

  if (ASTNode_isLog10(node))
  {
    L3FormulaFormatter_visitLog10(parent, node, sb, settings);
  }
  else if (ASTNode_isSqrt(node))
  {
    L3FormulaFormatter_visitSqrt(parent, node, sb, settings);
  }
  else if (isTranslatedModulo(node))
  {
    L3FormulaFormatter_visitModulo(parent, node, sb, settings);
  }
  else if (L3FormulaFormatter_isFunction(node, settings))
  {
    L3FormulaFormatter_visitFunction(parent, node, sb, settings);
  }
  else if (ASTNode_isUMinus(node))
  {
    L3FormulaFormatter_visitUMinus(parent, node, sb, settings);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_LOGICAL_NOT, 1))
  {
    L3FormulaFormatter_visitUNot(parent, node, sb, settings);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_QUALIFIER_LOGBASE, 1))
  {
    L3FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb, settings);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_QUALIFIER_DEGREE, 1))
  {
    L3FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb, settings);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_SEMANTICS, 1))
  {
    L3FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb, settings);
  }
  else if (ASTNode_hasPackageOnlyInfixSyntax(node))
  {
    L3ParserSettings_visitPackageInfixSyntax(parent, node, sb, settings);
  }
  else
  {
    L3FormulaFormatter_visitOther(parent, node, sb, settings);
  }
}


/**
 * Visits the given ASTNode as a function.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitFunction ( const ASTNode_t *parent,
                                   const ASTNode_t *node,
                                   StringBuffer_t  *sb, 
                                   const L3ParserSettings_t *settings )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  unsigned int n;


  L3FormulaFormatter_format(sb, node, settings);
  StringBuffer_appendChar(sb, '(');

  if (numChildren > 0)
  {
    L3FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb, settings);
  }

  for (n = 1; n < numChildren; n++)
  {
    StringBuffer_appendChar(sb, ',');
    StringBuffer_appendChar(sb, ' ');
    L3FormulaFormatter_visit( node, ASTNode_getChild(node, n), sb, settings);
  }

  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as the function "log(10, x)" and in doing so,
 * formats it as "log10(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitLog10 ( const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb, 
                                const L3ParserSettings_t *settings )
{
  StringBuffer_append(sb, "log10(");
  L3FormulaFormatter_visit(node, ASTNode_getChild(node, 1), sb, settings);
  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as the function "root(2, x)" and in doing so,
 * formats it as "sqrt(x)" (where x is any subexpression).
 */
void
L3FormulaFormatter_visitSqrt ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings )
{
  StringBuffer_append(sb, "sqrt(");
  L3FormulaFormatter_visit(node, ASTNode_getChild(node, 1), sb, settings);
  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as a unary minus.  For this node only the
 * traversal is preorder.
 */
void
L3FormulaFormatter_visitUMinus ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings )
{
  //Unary minus is *not* the highest precedence, since it is superceded by 'power'
  unsigned int group;
  
  //If we are supposed to collapse minuses, do so.
  if (L3ParserSettings_getParseCollapseMinus(settings)) {
    if (ASTNode_getNumChildren(node) == 1 &&
        ASTNode_isUMinus(ASTNode_getLeftChild(node))) {
      L3FormulaFormatter_visit(parent, ASTNode_getLeftChild(ASTNode_getLeftChild(node)), sb, settings);
      return;
    }
  }
  
  group = L3FormulaFormatter_isGrouped(parent, node, settings);

  if (group)
  {
    StringBuffer_appendChar(sb, '(');
  }
  StringBuffer_appendChar(sb, '-');
  L3FormulaFormatter_visit ( node, ASTNode_getLeftChild(node), sb, settings);
  if (group)
  {
    StringBuffer_appendChar(sb, ')');
  }
}


/**
 * Visits the given ASTNode as a unary not.
 */
void
L3FormulaFormatter_visitUNot ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb, 
                               const L3ParserSettings_t *settings )
{
  //Unary not is also not the highest precedence, since it is superceded by 'power'
  unsigned int group       = L3FormulaFormatter_isGrouped(parent, node, settings);

  if (group)
  {
    StringBuffer_appendChar(sb, '(');
  }
  StringBuffer_appendChar(sb, '!');
  L3FormulaFormatter_visit ( node, ASTNode_getLeftChild(node), sb, settings);
  if (group)
  {
    StringBuffer_appendChar(sb, ')');
  }
}


/**
 * Visits the given ASTNode, translating the piecewise function
 * to the much simpler 'x % y' format.
 */
void
L3FormulaFormatter_visitModulo ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb, 
                                 const L3ParserSettings_t *settings )
{
  unsigned int group       = L3FormulaFormatter_isGrouped(parent, node, settings);
  const ASTNode_t* subnode = ASTNode_getLeftChild(node);
  if (group)
  {
    StringBuffer_appendChar(sb, '(');
  }

  //Get x and y from the first child of the piecewise function, 
  // then the first child of that (times), and the first child
  // of that (minus).
  L3FormulaFormatter_visit ( subnode, ASTNode_getLeftChild(subnode), sb, settings);
  StringBuffer_appendChar(sb, ' ');
  StringBuffer_appendChar(sb, '%');
  StringBuffer_appendChar(sb, ' ');
  subnode = ASTNode_getRightChild(subnode);
  L3FormulaFormatter_visit ( node, ASTNode_getLeftChild(subnode), sb, settings);

  if (group)
  {
    StringBuffer_appendChar(sb, ')');
  }
}


/**
 * Visits the given ASTNode and continues the inorder traversal.
 */
void
L3FormulaFormatter_visitOther ( const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb, 
                                const L3ParserSettings_t *settings )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  unsigned int group       = L3FormulaFormatter_isGrouped(parent, node, settings);
  unsigned int n;


  if (group)
  {
    StringBuffer_appendChar(sb, '(');
  }

  if (numChildren == 0) {
    L3FormulaFormatter_format(sb, node, settings);
  }

  else if (numChildren == 1)
  {
    //I believe this would only be called for invalid ASTNode setups,
    // but this could in theory occur.  This is the safest 
    // behavior I can think of.
    L3FormulaFormatter_format(sb, node, settings);
    StringBuffer_appendChar(sb, '(');
    L3FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb, settings);
    StringBuffer_appendChar(sb, ')');
  }

  else {
    L3FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb, settings);

    for (n = 1; n < numChildren; n++)
    {
      L3FormulaFormatter_format(sb, node, settings);
      L3FormulaFormatter_visit( node, ASTNode_getChild(node, n), sb, settings);
    }
  }

  if (group)
  {
    StringBuffer_appendChar(sb, ')');
  }
}



//This function determines if the node in question has unambiguous grammar; that
// is, if it needs to worry about any of its components having parentheses.
int
L3FormulaFormatter_hasUnambiguousGrammar(const ASTNode_t *node, 
                               const ASTNode_t *child, 
                               const L3ParserSettings_t *settings)
{
  //All of the following situations have grammar that doesn't ever require the child
  // to have parentheses added when it's a child of 'node'.

  //Functions delimit their children with commas:
  if (L3FormulaFormatter_isFunction(node, settings)) return 1;

  //Packages have their own rules:
  if (ASTNode_hasUnambiguousPackageInfixGrammar(node, child)) return 1;

  //'8', the highest precedence, is only ever given to functions and other top-level 
  // unambiguous objects.
  if (getL3Precedence(child) == 8) return 1;
  return 0;
}


//This function determines if the node in question should be
// expressed in the form "functioname(children)" or if
// it should be expressed as "child1 [symbol] child2 [symbol] child3"
// etc.
int
L3FormulaFormatter_isFunction (const ASTNode_t *node, 
                               const L3ParserSettings_t *settings)
{
  if (node==NULL) return 0;
  switch(ASTNode_getType(node))
  {
  case AST_PLUS:
  case AST_TIMES:
  case AST_LOGICAL_AND:
  case AST_LOGICAL_OR:
    if (ASTNode_getNumChildren(node) >= 2) {
      return 0;
    }
    return 1;

  case AST_RELATIONAL_EQ:
  case AST_RELATIONAL_GEQ:
  case AST_RELATIONAL_GT:
  case AST_RELATIONAL_LEQ:
  case AST_RELATIONAL_LT:
    if (ASTNode_getNumChildren(node) == 2) {
      return 0;
    }
    return 1;

  case AST_MINUS:
    if (ASTNode_getNumChildren(node) == 1) {
      return 0;
    }
  case AST_DIVIDE:
  case AST_RELATIONAL_NEQ:
  case AST_POWER:
  case AST_FUNCTION_POWER:
    if (ASTNode_getNumChildren(node) == 2) {
      return 0;
    }
    return 1;

  case AST_LOGICAL_NOT:
    if (ASTNode_getNumChildren(node) == 1) {
      return 0;
    }
    return 1;

  case AST_INTEGER:
  case AST_REAL:
  case AST_REAL_E:
  case AST_RATIONAL:
  case AST_NAME:
  case AST_NAME_AVOGADRO:
  case AST_NAME_TIME:
  case AST_CONSTANT_E:
  case AST_CONSTANT_FALSE:
  case AST_CONSTANT_PI:
  case AST_CONSTANT_TRUE:
  /* new elements to the enum that should not get hit */
  case AST_QUALIFIER_BVAR:
  case AST_QUALIFIER_LOGBASE:
  case AST_QUALIFIER_DEGREE:
  case AST_SEMANTICS:
  case AST_CONSTRUCTOR_PIECE:
  case AST_CONSTRUCTOR_OTHERWISE:
    return 0;

  case AST_LOGICAL_XOR:
  case AST_LAMBDA:
  case AST_FUNCTION:
  case AST_FUNCTION_ABS:
  case AST_FUNCTION_ARCCOS:
  case AST_FUNCTION_ARCCOSH:
  case AST_FUNCTION_ARCCOT:
  case AST_FUNCTION_ARCCOTH:
  case AST_FUNCTION_ARCCSC:
  case AST_FUNCTION_ARCCSCH:
  case AST_FUNCTION_ARCSEC:
  case AST_FUNCTION_ARCSECH:
  case AST_FUNCTION_ARCSIN:
  case AST_FUNCTION_ARCSINH:
  case AST_FUNCTION_ARCTAN:
  case AST_FUNCTION_ARCTANH:
  case AST_FUNCTION_CEILING:
  case AST_FUNCTION_COS:
  case AST_FUNCTION_COSH:
  case AST_FUNCTION_COT:
  case AST_FUNCTION_COTH:
  case AST_FUNCTION_CSC:
  case AST_FUNCTION_CSCH:
  case AST_FUNCTION_DELAY:
  case AST_FUNCTION_EXP:
  case AST_FUNCTION_FACTORIAL:
  case AST_FUNCTION_FLOOR:
  case AST_FUNCTION_LN:
  case AST_FUNCTION_LOG:
  case AST_FUNCTION_PIECEWISE:
  case AST_FUNCTION_ROOT:
  case AST_FUNCTION_SEC:
  case AST_FUNCTION_SECH:
  case AST_FUNCTION_SIN:
  case AST_FUNCTION_SINH:
  case AST_FUNCTION_TAN:
  case AST_FUNCTION_TANH:
  case AST_UNKNOWN:
    return 1;

    /* this one will need work */
  case AST_ORIGINATES_IN_PACKAGE:
    return ASTNode_isPackageInfixFunction(node);
  }
  //Shouldn't ever get here
  assert(0);
  return 1;
}


/** @endcond */

