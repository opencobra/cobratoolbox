/**
 * @file    FormulaFormatter.c
 * @brief   Formats an AST formula tree as an SBML formula string.
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
#include <sbml/math/FormulaFormatter.h>

#include <sbml/util/util.h>

/**
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
SBML_formulaToString (const ASTNode_t *tree)
{
  char           *s;

  if (tree == NULL)
  {
    s = NULL;
  }
  else
  {
    StringBuffer_t *sb = StringBuffer_create(128);

    FormulaFormatter_visit(NULL, tree, sb);
    s = StringBuffer_getBuffer(sb);
    safe_free(sb);
  }
  return s;
}


/**
 * @cond doxygenLibsbmlInternal
 * The rest of this file is internal code.
 */


/**
 * @return true (non-zero) if the given ASTNode is to formatted as a
 * function.
 */
int
FormulaFormatter_isFunction (const ASTNode_t *node)
{
  return
    ASTNode_isFunction  (node) ||
    ASTNode_isLambda    (node) ||
    ASTNode_isLogical   (node) ||
    ASTNode_isRelational(node) ||
    ASTNode_getType(node) == AST_ORIGINATES_IN_PACKAGE;
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
FormulaFormatter_isGrouped (const ASTNode_t *parent, const ASTNode_t *child)
{
  int pp, cp;
  int pt, ct;
  int group = 0;


  if (parent != NULL)
  {
    if (!FormulaFormatter_isFunction(parent))
    {
      pp = ASTNode_getPrecedence(parent);
      cp = ASTNode_getPrecedence(child);

      if (pp > cp)
      {
        group = 1;
      }
      else if (pp == cp)
      {
        /**
         * Group only if i) child is to the right and ii) both parent and
         * child are either not the same, or if they are the same, they
         * should be non-associative operators (i.e. AST_MINUS or
         * AST_DIVIDE).  That is, do not group a parent and right child
         * that are either both AST_PLUS or both AST_TIMES operators.
         */
        if (ASTNode_getRightChild(parent) == child)
        {
          pt = ASTNode_getType(parent);
          ct = ASTNode_getType(child);

          group = ((pt != ct) || (pt == AST_MINUS || pt == AST_DIVIDE));
        }
      }
    }
  }

  return group;
}


/**
 * Formats the given ASTNode as an SBML L1 token and appends the result to
 * the given StringBuffer.
 */
void
FormulaFormatter_format (StringBuffer_t *sb, const ASTNode_t *node)
{
  if (sb == NULL) return;
  if (ASTNode_isOperator(node))
  {
    FormulaFormatter_formatOperator(sb, node);
  }
  else if (ASTNode_isFunction(node))
  {
    FormulaFormatter_formatFunction(sb, node);
  }
  else if (ASTNode_isInteger(node))
  {
    StringBuffer_appendInt(sb, ASTNode_getInteger(node));
  }
  else if (ASTNode_isRational(node))
  {
    FormulaFormatter_formatRational(sb, node);
  }
  else if (ASTNode_isReal(node))
  {
    FormulaFormatter_formatReal(sb, node);
  }
  else if ( !ASTNode_isUnknown(node) )
  {
    StringBuffer_append(sb, ASTNode_getName(node));
  }
}


/**
 * Formats the given ASTNode as an SBML L1 function name and appends the
 * result to the given StringBuffer.
 */
void
FormulaFormatter_formatFunction (StringBuffer_t *sb, const ASTNode_t *node)
{
  ASTNodeType_t type = ASTNode_getType(node);


  switch (type)
  {
    case AST_FUNCTION_ARCCOS:
      StringBuffer_append(sb, "acos");
      break;

    case AST_FUNCTION_ARCSIN:
      StringBuffer_append(sb, "asin");
      break;

    case AST_FUNCTION_ARCTAN:
      StringBuffer_append(sb, "atan");
      break;

    case AST_FUNCTION_CEILING:
      StringBuffer_append(sb, "ceil");
      break;

    case AST_FUNCTION_LN:
      StringBuffer_append(sb, "log");
      break;

    case AST_FUNCTION_POWER:
      StringBuffer_append(sb, "pow");
      break;

    default:
      StringBuffer_append(sb, ASTNode_getName(node));
      break;
  }
}


/**
 * Formats the given ASTNode as an SBML L1 operator and appends the result
 * to the given StringBuffer.
 */
void
FormulaFormatter_formatOperator (StringBuffer_t *sb, const ASTNode_t *node)
{
  ASTNodeType_t type = ASTNode_getType(node);


  if (type != AST_POWER)
  {
    StringBuffer_appendChar(sb, ' ');
  }

  StringBuffer_appendChar(sb, ASTNode_getCharacter(node));

  if (type != AST_POWER)
  {
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
FormulaFormatter_formatRational (StringBuffer_t *sb, const ASTNode_t *node)
{
  StringBuffer_appendChar( sb, '(');
  StringBuffer_appendInt ( sb, ASTNode_getNumerator(node)   );
  StringBuffer_appendChar( sb, '/');
  StringBuffer_appendInt ( sb, ASTNode_getDenominator(node) );
  StringBuffer_appendChar( sb, ')');
}


/**
 * Formats the given ASTNode as a real number and appends the result to
 * the given StringBuffer.
 */
void
FormulaFormatter_formatReal (StringBuffer_t *sb, const ASTNode_t *node)
{
  double value = ASTNode_getReal(node);
  int    sign;


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
}

/**
 * Visits the given ASTNode node.  This function is really just a
 * dispatcher to either SBML_formulaToString_visitFunction() or
 * SBML_formulaToString_visitOther().
 */
void
FormulaFormatter_visit ( const ASTNode_t *parent,
                         const ASTNode_t *node,
                         StringBuffer_t  *sb )
{

  if (ASTNode_isLog10(node))
  {
    FormulaFormatter_visitLog10(parent, node, sb);
  }
  else if (ASTNode_isSqrt(node))
  {
    FormulaFormatter_visitSqrt(parent, node, sb);
  }
  else if (FormulaFormatter_isFunction(node))
  {
    FormulaFormatter_visitFunction(parent, node, sb);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_MINUS, 1))
  {
    FormulaFormatter_visitUMinus(parent, node, sb);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_PLUS, 1) || ASTNode_hasTypeAndNumChildren(node, AST_TIMES, 1))
  {
    FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_PLUS, 0))
  {
    StringBuffer_appendInt(sb, 0);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_TIMES, 0))
  {
    StringBuffer_appendInt(sb, 1);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_QUALIFIER_LOGBASE, 1))
  {
    FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_QUALIFIER_DEGREE, 1))
  {
    FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb);
  }
  else if (ASTNode_hasTypeAndNumChildren(node, AST_SEMANTICS, 1))
  {
    FormulaFormatter_visit(node, ASTNode_getChild(node, 0), sb);
  }
  else
  {
    FormulaFormatter_visitOther(parent, node, sb);
  }
}


/**
 * Visits the given ASTNode as a function.  For this node only the
 * traversal is preorder.
 */
void
FormulaFormatter_visitFunction ( const ASTNode_t *parent,
                                 const ASTNode_t *node,
                                 StringBuffer_t  *sb )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  unsigned int n;


  FormulaFormatter_format(sb, node);
  StringBuffer_appendChar(sb, '(');

  if (numChildren > 0)
  {
    FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb );
  }

  for (n = 1; n < numChildren; n++)
  {
    StringBuffer_appendChar(sb, ',');
    StringBuffer_appendChar(sb, ' ');
    FormulaFormatter_visit( node, ASTNode_getChild(node, n), sb );
  }

  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as the function "log(10, x)" and in doing so,
 * formats it as "log10(x)" (where x is any subexpression).
 */
void
FormulaFormatter_visitLog10 ( const ASTNode_t *parent,
                              const ASTNode_t *node,
                              StringBuffer_t  *sb )
{
  StringBuffer_append(sb, "log10(");
  FormulaFormatter_visit(node, ASTNode_getChild(node, 1), sb);
  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as the function "root(2, x)" and in doing so,
 * formats it as "sqrt(x)" (where x is any subexpression).
 */
void
FormulaFormatter_visitSqrt ( const ASTNode_t *parent,
                             const ASTNode_t *node,
                             StringBuffer_t  *sb )
{
  StringBuffer_append(sb, "sqrt(");
  FormulaFormatter_visit(node, ASTNode_getChild(node, 1), sb);
  StringBuffer_appendChar(sb, ')');
}


/**
 * Visits the given ASTNode as a unary minus.  For this node only the
 * traversal is preorder.
 */
void
FormulaFormatter_visitUMinus ( const ASTNode_t *parent,
                               const ASTNode_t *node,
                               StringBuffer_t  *sb )
{
  StringBuffer_appendChar(sb, '-');
  FormulaFormatter_visit ( node, ASTNode_getLeftChild(node), sb );
}


/**
 * Visits the given ASTNode and continues the inorder traversal.
 */
void
FormulaFormatter_visitOther ( const ASTNode_t *parent,
                              const ASTNode_t *node,
                              StringBuffer_t  *sb )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  unsigned int group       = FormulaFormatter_isGrouped(parent, node);
  unsigned int n;


  if (group)
  {
    StringBuffer_appendChar(sb, '(');
  }

  if (numChildren == 0) {
    FormulaFormatter_format(sb, node);
  }

  else if (numChildren == 1)
  {
    //I believe this would only be called for invalid ASTNode setups,
    // but this could in theory occur.  This is the safest 
    // behavior I can think of.
    FormulaFormatter_format(sb, node);
    StringBuffer_appendChar(sb, '(');
    FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb );
    StringBuffer_appendChar(sb, ')');
  }

  else {
    FormulaFormatter_visit( node, ASTNode_getChild(node, 0), sb );

    for (n = 1; n < numChildren; n++)
    {
      FormulaFormatter_format(sb, node);
      FormulaFormatter_visit( node, ASTNode_getChild(node, n), sb );
    }
  }

  if (group)
  {
    StringBuffer_appendChar(sb, ')');
  }
}

/** @endcond */

