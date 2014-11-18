/**
 * \file    drawMath.c
 * \brief   outputs the math of a model as a dot graph
 * \author  Sarah Keating
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */


#include <stdio.h>
#include <stdlib.h>

#include <sbml/util/util.h>
#include <sbml/SBMLTypes.h>

#include "FormulaGraphvizFormatter.h"


static int noClusters = 0;

FILE * fout;

/**
 * @return the given formula AST as a directed graph.  The caller
 * owns the returned string and is responsible for freeing it.
 */
char *
SBML_formulaToDot (const ASTNode_t *tree)
{
  StringBuffer_t *sb = StringBuffer_create(128);
  char           *name;
  char           *s;

  if (FormulaGraphvizFormatter_isFunction(tree)
    || ASTNode_isOperator(tree)) 
  {
    FormulaGraphvizFormatter_visit(NULL, tree, sb);
  }
  else
  {
    name = FormulaGraphvizFormatter_format(tree);
    StringBuffer_append(sb, name);
  }
  
  StringBuffer_append(sb, "}\n");

  s = StringBuffer_getBuffer(sb);
  free(sb);

  return s;
}


/**
 * @return true (non-zero) if the given ASTNode is to formatted as a
 * function.
 */
int
FormulaGraphvizFormatter_isFunction (const ASTNode_t *node)
{
  return
    ASTNode_isFunction  (node) ||
    ASTNode_isLambda    (node) ||
    ASTNode_isLogical   (node) ||
    ASTNode_isRelational(node);
}


/**
 * Formats the given ASTNode as a directed graph token and returns the result as
 * a string.
 */
char *
FormulaGraphvizFormatter_format (const ASTNode_t *node)
{
  StringBuffer_t *p = StringBuffer_create(128);
  char           *s = NULL;
 
  if (ASTNode_isOperator(node))
  {
    s = FormulaGraphvizFormatter_formatOperator(node);
  }
  else if (ASTNode_isFunction(node))
  {
    s = FormulaGraphvizFormatter_formatFunction(node);
  }
  else if (ASTNode_isInteger(node))
  {
    StringBuffer_appendInt(p, ASTNode_getInteger(node));
    s = StringBuffer_toString(p);
  }
  else if (ASTNode_isRational(node))
  {
    s = FormulaGraphvizFormatter_formatRational(node);
  }
  else if (ASTNode_isReal(node))
  {
    s = FormulaGraphvizFormatter_formatReal(node);
  }
  else if ( !ASTNode_isUnknown(node) )
  {
    if (ASTNode_getName(node) == NULL)
    {
      StringBuffer_append(p, "unknown");
    }
    else
    {
      StringBuffer_append(p, ASTNode_getName(node));
    }
    
    s = StringBuffer_toString(p);
  }
  
  free(p);

  return s;
}


/**
 * Since graphviz will interpret identical names as referring to
 * the same node presentation-wise it is better if each function node
 * has a unique name.
 * 
 * Returns the name with the name of the first child
 * prepended
 *
 * THIS COULD BE DONE BETTER
 */
char *
FormulaGraphvizFormatter_getUniqueName (const ASTNode_t *node)
{
  StringBuffer_t *p = StringBuffer_create(128);
  char           *s = NULL;
  
  if (ASTNode_isOperator(node))
  {
    s = FormulaGraphvizFormatter_OperatorGetUniqueName(node);
  }
  else if (ASTNode_isFunction(node))
  {
    s = FormulaGraphvizFormatter_FunctionGetUniqueName(node);
  }
  else if (ASTNode_isInteger(node))
  {
    StringBuffer_appendInt(p, ASTNode_getInteger(node));
    s = StringBuffer_toString(p);
  }
  else if (ASTNode_isRational(node))
  {
    s = FormulaGraphvizFormatter_formatRational(node);
  }
  else if (ASTNode_isReal(node))
  {
    s = FormulaGraphvizFormatter_formatReal(node);
  }
  else if ( !ASTNode_isUnknown(node) )
  {
    StringBuffer_append(p, ASTNode_getName(node));
    s = StringBuffer_toString(p);
  }

  free(p);

  return s;
}

/**
 * Formats the given ASTNode as a directed graph function name and returns the
 * result as a string.
 */
char *
FormulaGraphvizFormatter_formatFunction (const ASTNode_t *node)
{
  char           *s;
  StringBuffer_t *p   = StringBuffer_create(128);
  ASTNodeType_t  type = ASTNode_getType(node);

  switch (type)
  {
    case AST_FUNCTION_ARCCOS:
      s =  "acos";
      break;

    case AST_FUNCTION_ARCSIN:
      s =  "asin";
      break;

    case AST_FUNCTION_ARCTAN:
      s =  "atan";
      break;

    case AST_FUNCTION_CEILING:
      s =  "ceil";
      break;

    case AST_FUNCTION_LN:
      s =  "log";
      break;

    case AST_FUNCTION_POWER:
      s =  "pow";
      break;

    default:
      if (ASTNode_getName(node) == NULL)
      {
        StringBuffer_append(p, "unknown");
      }
      else
      {
        StringBuffer_append(p, ASTNode_getName(node));
      }
      s = StringBuffer_toString(p);
      break;
  }

  free(p);

  return s;
}


/**
 * Since graphviz will interpret identical names as referring to
 * the same node presentation-wise it is better if each function node
 * has a unique name.
 * 
 * Returns the name of the function with the name of the first child
 * prepended
 *
 * THIS COULD BE DONE BETTER
 */
char *
FormulaGraphvizFormatter_FunctionGetUniqueName (const ASTNode_t *node)
{
  char           *s;
  StringBuffer_t *p   = StringBuffer_create(128);
  ASTNodeType_t  type = ASTNode_getType(node);
 
  if (ASTNode_getNumChildren(node) != 0)
  {
	const char* name = ASTNode_getName(ASTNode_getChild(node,0));
	if (name != NULL)
    StringBuffer_append(p, name);
  }
  else
  {
    StringBuffer_append(p, "unknown");
  }

  switch (type)
  {
    case AST_FUNCTION_ARCCOS:
      StringBuffer_append(p, "acos");
      break;

    case AST_FUNCTION_ARCSIN:
      StringBuffer_append(p, "asin");
      break;

    case AST_FUNCTION_ARCTAN:
      StringBuffer_append(p, "atan");
      break;

    case AST_FUNCTION_CEILING:
      StringBuffer_append(p, "ceil");
      break;

    case AST_FUNCTION_LN:
      StringBuffer_append(p, "log");
      break;

    case AST_FUNCTION_POWER:
      StringBuffer_append(p, "pow");
      break;

    default:
      if (ASTNode_getName(node) != NULL)
      {
        StringBuffer_append(p, ASTNode_getName(node));
      }
      break;
  }
  
  s = StringBuffer_toString(p);

  free(p);

  return s;
}


/**
 * Formats the given ASTNode as a directed graph operator and returns the result
 * as a string.
 */
char *
FormulaGraphvizFormatter_formatOperator (const ASTNode_t *node)
{
  char           *s;
  ASTNodeType_t  type = ASTNode_getType(node);
  StringBuffer_t *p   = StringBuffer_create(128);

  switch (type)
  {
    case AST_TIMES:
      s =  "times";
      break;

    case AST_DIVIDE:
      s =  "divide";
      break;

    case AST_PLUS:
      s =  "plus";
      break;

    case AST_MINUS:
      s =  "minus";
      break;

    case AST_POWER:
      s =  "power";
      break;

    default:
      StringBuffer_appendChar(p, ASTNode_getCharacter(node));
      s = StringBuffer_toString(p);
      break;
  }

  free(p);

  return s;
}

/**
 * Since graphviz will interpret identical names as referring to
 * the same node presentation-wise it is better if each function node
 * has a unique name.
 * 
 * Returns the name of the operator with the name of the first child
 * prepended
 *
 * THIS COULD BE DONE BETTER
 */
char *
FormulaGraphvizFormatter_OperatorGetUniqueName (const ASTNode_t *node)
{
  char           *s;
  char           number[10];
  StringBuffer_t *p   = StringBuffer_create(128);
  ASTNodeType_t  type = ASTNode_getType(node);
  
  if (FormulaGraphvizFormatter_isFunction(ASTNode_getChild(node,0))
    || ASTNode_isOperator(ASTNode_getChild(node,0))) 
  {
    StringBuffer_append(p, "func");
  }
  else
  {
    if (ASTNode_isInteger(ASTNode_getChild(node, 0)))
    {
      sprintf(number, "%d", (int)ASTNode_getInteger(ASTNode_getChild(node, 0)));
      StringBuffer_append(p, number);
    }
    else if (ASTNode_isReal(ASTNode_getChild(node, 0)))
    {
      sprintf(number, "%ld", ASTNode_getNumerator(ASTNode_getChild(node, 0)));
      StringBuffer_append(p, number);
    }
    else
    {
      StringBuffer_append(p, ASTNode_getName(ASTNode_getChild(node,0)));
    }
  }

  switch (type)
  {
    case AST_TIMES:
      StringBuffer_append(p,  "times");
      break;

    case AST_DIVIDE:
      StringBuffer_append(p,  "divide");
      break;

    case AST_PLUS:
      StringBuffer_append(p,  "plus");
      break;

    case AST_MINUS:
      StringBuffer_append(p,  "minus");
      break;

    case AST_POWER:
      StringBuffer_append(p,  "power");
      break;

    default:
      StringBuffer_appendChar(p, ASTNode_getCharacter(node));
      break;
  }
  
  s = StringBuffer_toString(p);

  free(p);

  return s;
}


/**
 * Formats the given ASTNode as a rational number and returns the result as
 * a string.  This amounts to:
 *
 *   "(numerator/denominator)"
 */
char *
FormulaGraphvizFormatter_formatRational (const ASTNode_t *node)
{
  char           *s;
  StringBuffer_t *p = StringBuffer_create(128);

  StringBuffer_appendChar( p, '(');
  StringBuffer_appendInt ( p, ASTNode_getNumerator(node)   );
  StringBuffer_appendChar( p, '/');
  StringBuffer_appendInt ( p, ASTNode_getDenominator(node) );
  StringBuffer_appendChar( p, ')');

  s = StringBuffer_toString(p);

  free(p);

  return s;
}


/**
 * Formats the given ASTNode as a real number and returns the result as
 * a string.
 */
char *
FormulaGraphvizFormatter_formatReal (const ASTNode_t *node)
{
  StringBuffer_t *p    = StringBuffer_create(128);
  double         value = ASTNode_getReal(node);
  int            sign;
  char           *s;

  if (util_isNaN(value))
  {
    s =  "NaN";
  }
  else if ((sign = util_isInf(value)) != 0)
  {
    if (sign == -1)
    {
      s = "-INF";
    }
    else
    {
      s =  "INF";
    }
  }
  else if (util_isNegZero(value))
  {
    s =  "-0";
  }
  else
  {
    StringBuffer_appendReal(p, value);
    s = StringBuffer_toString(p);
  }

  free(p);

  return s;
}


/**
 * Visits the given ASTNode node.  This function is really just a
 * dispatcher to either FormulaGraphvizFormatter_visitFunction() or
 * FormulaGraphvizFormatter_visitOther().
 */
void
FormulaGraphvizFormatter_visit (const ASTNode_t *parent,
                                const ASTNode_t *node,
                                StringBuffer_t  *sb )
{
  if (ASTNode_isLog10(node))
  {
    FormulaGraphvizFormatter_visitLog10(parent, node, sb);
  }
  else if (ASTNode_isSqrt(node))
  {
    FormulaGraphvizFormatter_visitSqrt(parent, node, sb);
  }
  else if (FormulaGraphvizFormatter_isFunction(node))
  {
    FormulaGraphvizFormatter_visitFunction(parent, node, sb);
  }
  else if (ASTNode_isUMinus(node))
  {
    FormulaGraphvizFormatter_visitUMinus(parent, node, sb);
  }
  else
  {
    FormulaGraphvizFormatter_visitOther(parent, node, sb);
  }
}


/**
 * Visits the given ASTNode as a function.  For this node only the
 * traversal is preorder.
 * Writes the function as a directed graph and appends the result
 * to the StringBuffer.
 */
void
FormulaGraphvizFormatter_visitFunction (const ASTNode_t *parent,
                                        const ASTNode_t *node,
                                        StringBuffer_t  *sb )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  unsigned int n;
  char         *name;
  char         *uniqueName;
  
  uniqueName = FormulaGraphvizFormatter_getUniqueName(node);
  name       = FormulaGraphvizFormatter_format(node);
  
  StringBuffer_append(sb, uniqueName);
  StringBuffer_append(sb, " [shape=box, label=");
  StringBuffer_append(sb, name);
  StringBuffer_append(sb, "];\n");

  if (parent != NULL) 
  {
    name = FormulaGraphvizFormatter_getUniqueName(node);
    uniqueName = FormulaGraphvizFormatter_getUniqueName(parent);
    
    if(strcmp(name, uniqueName)) 
    {
      StringBuffer_append(sb, uniqueName);
      StringBuffer_append(sb, " -> ");
      StringBuffer_append(sb, name);
      StringBuffer_append(sb, ";\n");
    }
  }

  if (numChildren > 0)
  {
    FormulaGraphvizFormatter_visit( node, ASTNode_getChild(node, 0), sb );
  }

  for (n = 1; n < numChildren; n++)
  {
    FormulaGraphvizFormatter_visit( node, ASTNode_getChild(node, n), sb );
  }

}


/**
 * Visits the given ASTNode as the function "log(10, x)" and in doing so,
 * formats it as "log10(x)" (where x is any subexpression).
 * Writes the function as a directed graph and appends the result
 * to the StringBuffer.
 * 
 * A seperate function may not be strictly speaking necessary for graphs
 */
void
FormulaGraphvizFormatter_visitLog10 (const ASTNode_t *parent,
                                     const ASTNode_t *node,
                                     StringBuffer_t  *sb )
{
  char *uniqueName = FormulaGraphvizFormatter_getUniqueName(node);
  char *name       = FormulaGraphvizFormatter_format(node);

  StringBuffer_append(sb, uniqueName);
  StringBuffer_append(sb, " [shape=box, label=");
  StringBuffer_append(sb, name);
  StringBuffer_append(sb, "];\n");

  FormulaGraphvizFormatter_visit(node, ASTNode_getChild(node, 1), sb);
}


/**
 * Visits the given ASTNode as the function "root(2, x)" and in doing so,
 * formats it as "sqrt(x)" (where x is any subexpression).
 * Writes the function as a directed graph and appends the result
 * to the StringBuffer.
 * 
 * A seperate function may not be strictly speaking necessary for graphs
 */
void
FormulaGraphvizFormatter_visitSqrt (const ASTNode_t *parent,
                                    const ASTNode_t *node,
                                    StringBuffer_t  *sb )
{
  char *uniqueName = FormulaGraphvizFormatter_getUniqueName(node);
  char *name       = FormulaGraphvizFormatter_format(node);

  StringBuffer_append(sb, uniqueName);
  StringBuffer_append(sb, " [shape=box, label=");
  StringBuffer_append(sb, name);
  StringBuffer_append(sb, "];\n");

  FormulaGraphvizFormatter_visit(node, ASTNode_getChild(node, 1), sb);
}


/**
 * Visits the given ASTNode as a unary minus.  For this node only the
 * traversal is preorder.
 * Writes the function as a directed graph and appends the result
 * to the StringBuffer.
 */
void
FormulaGraphvizFormatter_visitUMinus (const ASTNode_t *parent,
                                      const ASTNode_t *node,
                                      StringBuffer_t  *sb )
{
  char *uniqueName = FormulaGraphvizFormatter_getUniqueName(node);
  char *name       = FormulaGraphvizFormatter_format(node);

  StringBuffer_append(sb, uniqueName);
  StringBuffer_append(sb, " [shape=box, label=");
  StringBuffer_append(sb, name);
  StringBuffer_append(sb, "];\n");

  if (parent != NULL) 
  {
    uniqueName = FormulaGraphvizFormatter_getUniqueName(parent);
    name       = FormulaGraphvizFormatter_getUniqueName(node);

    if(strcmp(name, uniqueName)) 
    {
      StringBuffer_append(sb, uniqueName);
      StringBuffer_append(sb, " -> ");
      StringBuffer_append(sb, name);
      StringBuffer_append(sb, ";\n");
    }
  }
  
  FormulaGraphvizFormatter_visit ( node, ASTNode_getLeftChild(node), sb );
}


/**
 * Visits the given ASTNode and continues the inorder traversal.
 * Writes the function as a directed graph and appends the result
 * to the StringBuffer.
 */
void
FormulaGraphvizFormatter_visitOther (const ASTNode_t *parent,
                                     const ASTNode_t *node,
                                     StringBuffer_t  *sb )
{
  unsigned int numChildren = ASTNode_getNumChildren(node);
  char         *name;
  char         *uniqueName;

  if (numChildren > 0)
  {
    uniqueName = FormulaGraphvizFormatter_getUniqueName(node);
    name       = FormulaGraphvizFormatter_format(node);
    
    StringBuffer_append(sb, uniqueName);
    StringBuffer_append(sb, " [shape=box, label=");
    StringBuffer_append(sb, name);
    StringBuffer_append(sb, "];\n");
    
    FormulaGraphvizFormatter_visit( node, ASTNode_getLeftChild(node), sb );
  }

  if (parent != NULL) 
  {
    name       = FormulaGraphvizFormatter_getUniqueName(node);
    uniqueName = FormulaGraphvizFormatter_getUniqueName(parent);
    
    if(strcmp(name, uniqueName)) 
    {
      StringBuffer_append(sb, uniqueName);
      StringBuffer_append(sb, " -> ");
      StringBuffer_append(sb, name);
      StringBuffer_append(sb, ";\n");
    }
  }

  if (numChildren > 1)
  {
    FormulaGraphvizFormatter_visit( node, ASTNode_getRightChild(node), sb );
  }
}


void
printFunctionDefinition (unsigned int n, FunctionDefinition_t *fd)
{
  const ASTNode_t *math;
  char *formula;


  if ( FunctionDefinition_isSetMath(fd) )
  {
    math = FunctionDefinition_getMath(fd);

    /* Print function body. */
    if (ASTNode_getNumChildren(math) == 0)
    {
      printf("(no body defined)");
    }
    else
    {
      math    = ASTNode_getChild(math, ASTNode_getNumChildren(math) - 1);
      formula = SBML_formulaToDot(math);
      fprintf(fout, "subgraph cluster%u {\n", noClusters);
      fprintf(fout, "label=\"FunctionDefinition: %s\";\n%s\n", FunctionDefinition_getId(fd), formula);
      free(formula);
      noClusters++;
    }
  }
}


void
printRuleMath (unsigned int n, Rule_t *r)
{
  char *formula;

  if ( Rule_isSetMath(r) )
  {
    formula = SBML_formulaToDot( Rule_getMath(r));
    fprintf(fout, "subgraph cluster%u {\n", noClusters);
    fprintf(fout, "label=\"Rule: %u\";\n%s\n", n, formula);
    free(formula);
    noClusters++;
  }
}


void
printReactionMath (unsigned int n, Reaction_t *r)
{
  char         *formula;
  KineticLaw_t *kl;


  if (Reaction_isSetKineticLaw(r))
  {
    kl = Reaction_getKineticLaw(r);

    if ( KineticLaw_isSetMath(kl) )
    {
      formula = SBML_formulaToDot( KineticLaw_getMath(kl) );
      fprintf(fout, "subgraph cluster%u {\n", noClusters);
      fprintf(fout, "label=\"Reaction: %s\";\n%s\n", Reaction_getId(r), formula);
      free(formula);
      noClusters++;
    }
  }
}


void
printEventAssignmentMath (unsigned int n, EventAssignment_t *ea)
{
  const char *variable;
  char       *formula;


  if ( EventAssignment_isSetMath(ea) )
  {
    variable = EventAssignment_getVariable(ea);
    formula  = SBML_formulaToDot( EventAssignment_getMath(ea) );
    fprintf(fout, "subgraph cluster%u {\n", noClusters);
    fprintf(fout, "label=\"EventAssignment: %u\";\n", n);
    fprintf(fout, "%s [shape=box];\n%s -> %s\n", variable, variable, formula);
    noClusters++;
    free(formula);
  }
}


void
printEventMath (unsigned int n, Event_t *e)
{
  char         *formula;
  unsigned int i;


  if ( Event_isSetDelay(e) )
  {
    formula = SBML_formulaToDot( Delay_getMath(Event_getDelay(e)) );
    fprintf(fout, "subgraph cluster%u {\n", noClusters);
    fprintf(fout, "label=\"Event %s delay:\";\n%s\n", Event_getId(e), formula);
    free(formula);
    noClusters++;
  }

  if ( Event_isSetTrigger(e) )
  {
    formula = SBML_formulaToDot( Trigger_getMath(Event_getTrigger(e)) );
    fprintf(fout, "subgraph cluster%u {\n", noClusters);
    fprintf(fout, "label=\"Event %s trigger:\";\n%s\n", Event_getId(e), formula);
    noClusters++;
    free(formula);
  }

  for (i = 0; i < Event_getNumEventAssignments(e); ++i)
  {
    printEventAssignmentMath(i + 1, Event_getEventAssignment(e, i));
  }
}


void
printMath (Model_t *m)
{
  unsigned int  n;

  /* a digraph must have a name thus
   * need to check that Model_getId does not return NULL
   * and provide a name if it does
   */

  if (Model_getId(m) != NULL) {
    fprintf(fout, "digraph %s {\n", Model_getId(m));
  }
  else {
    fprintf(fout, "digraph example {\n");
  }
  fprintf(fout, "compound=true;\n");

  for (n = 0; n < Model_getNumFunctionDefinitions(m); ++n)
  {
    printFunctionDefinition(n + 1, Model_getFunctionDefinition(m, n));
  }

  for (n = 0; n < Model_getNumRules(m); ++n)
  {
    printRuleMath(n + 1, Model_getRule(m, n));
  }

  printf("\n");

  for (n = 0; n < Model_getNumReactions(m); ++n)
  {
    printReactionMath(n + 1, Model_getReaction(m, n));
  }

  printf("\n");

  for (n = 0; n < Model_getNumEvents(m); ++n)
  {
    printEventMath(n + 1, Model_getEvent(m, n));
  }

  fprintf(fout, "}\n");
}


int
main (int argc, char *argv[])
{
  SBMLDocument_t *d;
  Model_t        *m;

  if (argc != 3)
  {
    printf("\n  usage: drawMath <sbml filename> <output dot filename>\n\n");
    return 1;
  }
  
  d = readSBML(argv[1]);
  m = SBMLDocument_getModel(d);

  SBMLDocument_printErrors(d, stdout);

  if ((fout  = fopen( argv[2], "w" )) == NULL )
  {
    printf( "The output file was not opened\n" );
  }
  else
  {
    printMath(m);
    fclose(fout);
  }

  SBMLDocument_free(d);
   
  return 0;
}
