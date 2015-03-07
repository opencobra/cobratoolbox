/**
 * @file    ASTNode.h
 * @brief   Abstract Syntax Tree (AST) for representing formula trees.
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
 * ------------------------------------------------------------------------ -->
 *
 * @class ASTNode
 * @sbmlbrief{core} Abstract Syntax Tree (AST) representation of a
 * mathematical expression.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * Abstract Syntax Trees (ASTs) are a simple kind of data structure used in
 * libSBML for storing mathematical expressions.  The ASTNode is the
 * cornerstone of libSBML's AST representation.  An AST "node" represents the
 * most basic, indivisible part of a mathematical formula and come in many
 * types.  For instance, there are node types to represent numbers (with
 * subtypes to distinguish integer, real, and rational numbers), names
 * (e.g., constants or variables), simple mathematical operators, logical
 * or relational operators and functions. LibSBML ASTs provide a canonical,
 * in-memory representation for all mathematical formulas regardless of
 * their original format (which might be MathML or might be text strings).
 *
 * @copydetails doc_what_is_astnode
 *
 * @if clike <h3><a class="anchor" name="ASTNodeType_t">
 * ASTNodeType_t</a></h3> @else <h3><a class="anchor"
 * name="ASTNodeType_t">The set of possible %ASTNode types</a></h3> @endif@~
 *
 * @copydetails doc_astnode_types
 *
 * <h3><a class="anchor" name="math-convert">Converting between ASTs and text strings</a></h3>
 *
 * The text-string form of mathematical formulas produced by @if clike SBML_formulaToString()@endif@if csharp SBML_formulaToString()@endif@if python libsbml.formulaToString()@endif@if java <code><a href="libsbml.html#formulaToString(org.sbml.libsbml.ASTNode)">libsbml.formulaToString()</a></code>@endif@~ and
 * read by @if clike SBML_parseFormula()@endif@if csharp SBML_parseFormula()@endif@if python libsbml.parseFormula()@endif@if java <code><a href="libsbml.html#parseFormula(java.lang.String)">libsbml.parseFormula(String formula)</a></code>@endif@~
 * and
 * @if clike SBML_parseL3Formula()@endif@if csharp SBML_parseL3Formula()@endif@if python libsbml.parseL3Formula()@endif@if java <code><a href="libsbml.html#parseL3Formula(java.lang.String)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
 * are in a simple C-inspired infix notation.  A
 * formula in this text-string form can be handed to a program that
 * understands SBML mathematical expressions, or used as part
 * of a translation system.  The libSBML distribution comes with an example
 * program in the @c "examples" subdirectory called @c translateMath that
 * implements an interactive command-line demonstration of translating
 * infix formulas into MathML and vice-versa.
 *
 * The formula strings may contain operators, function calls, symbols, and
 * white space characters.  The allowable white space characters are tab
 * and space.  The following are illustrative examples of formulas
 * expressed in the syntax:
 * 
 * @verbatim
0.10 * k4^2
@endverbatim
 * @verbatim
(vm * s1)/(km + s1)
@endverbatim
 *
 * The following table shows the precedence rules in this syntax.  In the
 * Class column, @em operand implies the construct is an operand, @em
 * prefix implies the operation is applied to the following arguments, @em
 * unary implies there is one argument, and @em binary implies there are
 * two arguments.  The values in the Precedence column show how the order
 * of different types of operation are determined.  For example, the
 * expression <em>a * b + c</em> is evaluated as <em>(a * b) + c</em>
 * because the <code>*</code> operator has higher precedence.  The
 * Associates column shows how the order of similar precedence operations
 * is determined; for example, <em>a - b + c</em> is evaluated as <em>(a -
 * b) + c</em> because the <code>+</code> and <code>-</code> operators are
 * left-associative.  The precedence and associativity rules are taken from
 * the C programming language, except for the symbol <code>^</code>, which
 * is used in C for a different purpose.  (Exponentiation can be invoked
 * using either <code>^</code> or the function @c power.)
 * 
 * @htmlinclude math-precedence-table.html 
 *
 * A program parsing a formula in an SBML model should assume that names
 * appearing in the formula are the identifiers of Species, Parameter,
 * Compartment, FunctionDefinition, Reaction (in SBML Levels&nbsp;2
 * and&nbsp;3), or SpeciesReference (in SBML Level&nbsp;3 only) objects
 * defined in a model.  When a function call is involved, the syntax
 * consists of a function identifier, followed by optional white space,
 * followed by an opening parenthesis, followed by a sequence of zero or
 * more arguments separated by commas (with each comma optionally preceded
 * and/or followed by zero or more white space characters), followed by a
 * closing parenthesis.  There is an almost one-to-one mapping between the
 * list of predefined functions available, and those defined in MathML.
 * All of the MathML functions are recognized; this set is larger than the
 * functions defined in SBML Level&nbsp;1.  In the subset of functions that
 * overlap between MathML and SBML Level&nbsp;1, there exist a few
 * differences.  The following table summarizes the differences between the
 * predefined functions in SBML Level&nbsp;1 and the MathML equivalents in
 * SBML Levels&nbsp;2 and &nbsp;3:
 * 
 * @htmlinclude math-functions.html
 * 
 * @copydetails doc_warning_L1_math_string_syntax
 *
 * @if clike @see SBML_parseL3Formula()@endif@~
 * @if csharp @see SBML_parseL3Formula()@endif@~
 * @if python @see libsbml.parseL3Formula()@endif@~
 * @if java @see <code><a href="libsbml.html#parseL3Formula(String formula)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
 * @if clike @see SBML_parseFormula()@endif@~
 * @if csharp @see SBML_parseFormula()@endif@~
 * @if python @see libsbml.parseFormula()@endif@~
 * @if java @see <code><a href="libsbml.html#parseFormula(String formula)">libsbml.parseFormula(String formula)</a></code>@endif@~
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_warning_modifying_structure
 *
 * @warning Explicitly adding, removing or replacing children of an
 * @if conly ASTNode_t structure@else ASTNode object@endif@~ may change the
 * structure of the mathematical formula it represents, and may even render
 * the representation invalid.  Callers need to be careful to use this method
 * in the context of other operations to create complete and correct
 * formulas.  The method @if conly ASTNode_isWellFormedASTNode()@else
 * ASTNode::isWellFormedASTNode()@endif@~ may also be useful for checking the
 * results of node modifications.
 */

#ifndef ASTNode_h
#define ASTNode_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/math/FormulaTokenizer.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/SyntaxChecker.h>

#include <sbml/common/operationReturnValues.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @enum  ASTNodeType_t
 * @brief ASTNodeType_t is the enumeration of possible
 * @if conly ASTNode_t @else ASTNode @endif types.
 *
 * @copydetails doc_astnode_types
 * 
 * @see @if conly ASTNode_getType() @else ASTNode::getType() @endif
 * @see @if conly ASTNode_canonicalize() @else ASTNode::canonicalize() @endif
 */
typedef enum
{
    AST_PLUS    = 43 /*!< Plus (MathML <code>&lt;plus&gt;</code>) */
  , AST_MINUS   = 45 /*!< Minus (MathML <code>&lt;minus&gt;</code>) */
  , AST_TIMES   = 42 /*!< Times (MathML <code>&lt;times&gt;</code>) */
  , AST_DIVIDE  = 47 /*!< Divide (MathML <code>&lt;divide&gt;</code>) */
  , AST_POWER   = 94 /*!< Power (MathML <code>&lt;power&gt;</code>) */

  , AST_INTEGER = 256 /*!< Integer (MathML <code>&lt;cn type="integer"&gt;</code>) */
  , AST_REAL /*!< Real (MathML <code>&lt;cn&gt;</code>) */
  , AST_REAL_E /*!< Real number with e-notation (MathML <code>&lt;cn type="e-notation"&gt; [number] &lt;sep/&gt; [number] &lt;/cn&gt;</code>) */
  , AST_RATIONAL /*!< Rational (MathML <code>&lt;cn type="rational"&gt; [number] &lt;sep/&gt; [number] &lt;cn&gt;</code>) */

  , AST_NAME /*!< A named node (MathML <code>&lt;ci&gt;</code>) */
  , AST_NAME_AVOGADRO /*!< Avogadro (MathML <code>&lt;ci encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/avogadro"&gt;</code>) */
  , AST_NAME_TIME /*!< Time (MathML <code>&lt;ci encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/time"&gt;</code>) */

  , AST_CONSTANT_E /*!< Exponential E (MathML <code>&lt;exponentiale&gt;</code>) */
  , AST_CONSTANT_FALSE /*!< False (MathML <code>&lt;false&gt;</code>) */
  , AST_CONSTANT_PI /*!< Pi (MathML <code>&lt;pi&gt;</code>) */
  , AST_CONSTANT_TRUE /*!< True (MathML <code>&lt;true&gt;</code>) */

  , AST_LAMBDA /*!< Lambda (MathML <code>&lt;lambda&gt;</code>) */

  , AST_FUNCTION /*!< User-defined function (MathML <code>&lt;apply&gt;</code>) */
  , AST_FUNCTION_ABS /*!< Absolute value (MathML <code>&lt;abs&gt;</code>) */
  , AST_FUNCTION_ARCCOS /*!< Arccosine (MathML <code>&lt;arccos&gt;</code>) */
  , AST_FUNCTION_ARCCOSH /*!< Hyperbolic arccosine (MathML <code>&lt;arccosh&gt;</code>) */
  , AST_FUNCTION_ARCCOT /*!< Arccotangent (MathML <code>&lt;arccot&gt;</code>) */
  , AST_FUNCTION_ARCCOTH /*!< Hyperbolic arccotangent (MathML <code>&lt;arccoth&gt;</code>) */
  , AST_FUNCTION_ARCCSC /*!< Arccosecant (MathML <code>&lt;arccsc&gt;</code>) */
  , AST_FUNCTION_ARCCSCH /*!< Hyperbolic arccosecant (MathML <code>&lt;arccsch&gt;</code>) */
  , AST_FUNCTION_ARCSEC /*!< Arcsecant (MathML <code>&lt;arcsec&gt;</code>) */
  , AST_FUNCTION_ARCSECH /*!< Hyperbolic arcsecant (MathML <code>&lt;arcsech&gt;</code>) */
  , AST_FUNCTION_ARCSIN /*!< Arcsine (MathML <code>&lt;arcsin&gt;</code>) */
  , AST_FUNCTION_ARCSINH /*!< Hyperbolic arcsine (MathML <code>&lt;arcsinh&gt;</code>) */
  , AST_FUNCTION_ARCTAN /*!< Arctangent (MathML <code>&lt;arctan&gt;</code>) */
  , AST_FUNCTION_ARCTANH /*!< Hyperbolic arctangent (MathML <code>&lt;arctanh&gt;</code>) */
  , AST_FUNCTION_CEILING /*!< Ceiling (MathML <code>&lt;ceiling&gt;</code>) */
  , AST_FUNCTION_COS /*!< Cosine (MathML <code>&lt;cosine&gt;</code>) */
  , AST_FUNCTION_COSH /*!< Hyperbolic cosine (MathML <code>&lt;cosh&gt;</code>) */
  , AST_FUNCTION_COT /*!< Cotangent (MathML <code>&lt;cot&gt;</code>) */
  , AST_FUNCTION_COTH /*!< Hyperbolic cotangent (MathML <code>&lt;coth&gt;</code>) */
  , AST_FUNCTION_CSC /*!< Cosecant (MathML <code>&lt;csc&gt;</code>) */
  , AST_FUNCTION_CSCH /*!< Hyperbolic cosecant (MathML <code>&lt;csch&gt;</code>) */
  , AST_FUNCTION_DELAY /*!< %Delay (MathML <code>&lt;csymbol encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/delay"&gt;</code>) */
  , AST_FUNCTION_EXP /*!< Exponential (MathML <code>&lt;exp&gt;</code>) */
  , AST_FUNCTION_FACTORIAL /*!< Factorial (MathML <code>&lt;factorial&gt;</code>) */
  , AST_FUNCTION_FLOOR /*!< Floor (MathML <code>&lt;floor&gt;</code>) */
  , AST_FUNCTION_LN /*!< Natural Log (MathML <code>&lt;ln&gt;</code>) */
  , AST_FUNCTION_LOG /*!< Log (MathML <code>&lt;log&gt;</code>) */
  , AST_FUNCTION_PIECEWISE /*!< Piecewise (MathML <code>&lt;piecewise&gt;</code>) */
  , AST_FUNCTION_POWER /*!< Power (MathML <code>&lt;power&gt;</code>) */
  , AST_FUNCTION_ROOT /*!< Root (MathML <code>&lt;root&gt;</code>) */
  , AST_FUNCTION_SEC /*!< Secant (MathML <code>&lt;sec&gt;</code>) */
  , AST_FUNCTION_SECH /*!< Hyperbolic secant (MathML <code>&lt;sech&gt;</code>) */
  , AST_FUNCTION_SIN /*!< Sine (MathML <code>&lt;sin&gt;</code>) */
  , AST_FUNCTION_SINH /*!< Hyperbolic sine (MathML <code>&lt;sinh&gt;</code>) */
  , AST_FUNCTION_TAN /*!< Tangent (MathML <code>&lt;tan&gt;</code>) */
  , AST_FUNCTION_TANH /*!< Hyperbolic tangent (MathML <code>&lt;tanh&gt;</code>) */

  , AST_LOGICAL_AND /*!< Logical and (MathML <code>&lt;and&gt;</code>) */
  , AST_LOGICAL_NOT /*!< Logical not (MathML <code>&lt;not&gt;</code>) */
  , AST_LOGICAL_OR /*!< Logical or (MathML <code>&lt;or&gt;</code>) */
  , AST_LOGICAL_XOR /*!< Logical exclusive or (MathML <code>&lt;xor&gt;</code>) */

  , AST_RELATIONAL_EQ /*!< Equal (MathML <code>&lt;eq&gt;</code>) */
  , AST_RELATIONAL_GEQ /*!< Greater than or equal (MathML <code>&lt;geq&gt;</code>) */
  , AST_RELATIONAL_GT /*!< Greater than (MathML <code>&lt;gt&gt;</code>) */
  , AST_RELATIONAL_LEQ /*!< Less than or equal (MathML <code>&lt;leq&gt;</code>) */
  , AST_RELATIONAL_LT /*!< Less than (MathML <code>&lt;lt&gt;</code>) */
  , AST_RELATIONAL_NEQ /*!< Not equal (MathML <code>&lt;neq&gt;</code>) */

  , AST_UNKNOWN /*!< Unknown node:  will not produce any MathML */
} ASTNodeType_t;


/**
 * @typedef ASTNodePredicate
 * @brief Function signature for use with
 * @if conly ASTNode_fillListOfNodes() @else ASTNode::fillListOfNodes() @endif
 * and @if conly ASTNode_getListOfNodes() @else ASTNode::getListOfNodes() @endif.
 *
 * A pointer to a function that takes an ASTNode and returns @if conly @c 1
 * (true) or @c 0 (false) @else @c true (non-zero) or @c false (0)@endif.
 *
 * @if conly @see ASTNode_getListOfNodes()@else @see ASTNode::getListOfNodes()@endif
 * @if conly @see ASTNode_fillListOfNodes()@else @see ASTNode::fillListOfNodes()@endif
 */
typedef int (*ASTNodePredicate) (const ASTNode_t *node);


LIBSBML_CPP_NAMESPACE_END

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class List;

class ASTNode
{
public:

  /**
   * Creates and returns a new ASTNode.
   *
   * Unless the argument @p type is given, the returned node will by default
   * have a type of @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  If the type
   * isn't supplied when caling this constructor, the caller should set the
   * node type to something else as soon as possible using @if clike
   * setType()@else ASTNode::setType(int)@endif.
   *
   * @param type an optional @if clike #ASTNodeType_t@else type@endif@~
   * code indicating the type of node to create.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  LIBSBML_EXTERN
  ASTNode (ASTNodeType_t type = AST_UNKNOWN);


  /**
   * Creates a new ASTNode from the given Token.  The resulting ASTNode
   * will contain the same data as the Token.
   *
   * @param token the Token to add.
   */
  LIBSBML_EXTERN
  ASTNode (Token_t *token);

  
  /**
   * Copy constructor; creates a deep copy of the given ASTNode.
   *
   * @param orig the ASTNode to be copied.
   */
  LIBSBML_EXTERN
  ASTNode (const ASTNode& orig);
  

  /**
   * Assignment operator for ASTNode.
   */
  LIBSBML_EXTERN
  ASTNode& operator=(const ASTNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  LIBSBML_EXTERN
  virtual ~ASTNode ();


  /**
   * Frees the name of this ASTNode and sets it to @c NULL.
   * 
   * This operation is only applicable to ASTNode objects corresponding to
   * operators, numbers, or @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  This method has no effect on other types of
   * nodes.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int freeName ();


  /**
   * Converts this ASTNode to a canonical form and returns @c true if
   * successful, @c false otherwise.
   *
   * The rules determining the canonical form conversion are as follows:
   * <ul>
   *
   * <li> If the node type is @sbmlconstant{AST_NAME, ASTNodeType_t}
   * and the node name matches @c "ExponentialE", @c "Pi", @c "True" or @c
   * "False" the node type is converted to the corresponding 
   * <code>AST_CONSTANT_</code><em><span class="placeholder">X</span></em> type.
   *
   * <li> If the node type is an @sbmlconstant{AST_FUNCTION, ASTNodeType_t} and the node name matches an SBML (MathML) function name, logical operator name, or
   * relational operator name, the node is converted to the corresponding
   * <code>AST_FUNCTION_</code><em><span class="placeholder">X</span></em> or
   * <code>AST_LOGICAL_</code><em><span class="placeholder">X</span></em> type.
   *
   * </ul>
   *
   * SBML Level&nbsp;1 function names are searched first; thus, for
   * example, canonicalizing @c log will result in a node type of @sbmlconstant{AST_FUNCTION_LN, ASTNodeType_t}.  (See the SBML
   * Level&nbsp;1 Version&nbsp;2 Specification, Appendix C.)
   *
   * Sometimes, canonicalization of a node results in a structural
   * conversion of the node as a result of adding a child.  For example, a
   * node with the SBML Level&nbsp;1 function name @c sqr and a single
   * child node (the argument) will be transformed to a node of type
   * @sbmlconstant{AST_FUNCTION_POWER, ASTNodeType_t} with
   * two children.  The first child will remain unchanged, but the second
   * child will be an ASTNode of type @sbmlconstant{AST_INTEGER, ASTNodeType_t} and a value of 2.  The function names that result
   * in structural changes are: @c log10, @c sqr, and @c sqrt.
   */
  LIBSBML_EXTERN
  bool canonicalize ();


  /**
   * Adds the given node as a child of this ASTNode.
   *
   * Child nodes are added in-order, from left to right.
   *
   * @param child the ASTNode instance to add
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_warning_modifying_structure
   *
   * @see prependChild(ASTNode* child)
   * @see replaceChild(unsigned int n, ASTNode* child)
   * @see insertChild(unsigned int n, ASTNode* child)
   * @see removeChild(unsigned int n)
   * @see isWellFormedASTNode()
   */
  LIBSBML_EXTERN
  int addChild (ASTNode* child, bool inRead = false);


  /**
   * Adds the given node as a child of this ASTNode.  This method adds
   * child nodes from right to left.
   *
   * @param child the ASTNode instance to add
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_warning_modifying_structure
   *
   * @see addChild(ASTNode* child)
   * @see replaceChild(unsigned int n, ASTNode* child)
   * @see insertChild(unsigned int n, ASTNode* child)
   * @see removeChild(unsigned int n)
   */
  LIBSBML_EXTERN
  int prependChild (ASTNode* child);


  /**
   * Removes the nth child of this ASTNode object.
   *
   * @param n unsigned int the index of the child to remove
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * @copydetails doc_warning_modifying_structure
   *
   * @see addChild(ASTNode* child)
   * @see prependChild(ASTNode* child)
   * @see replaceChild(unsigned int n, ASTNode* child)
   * @see insertChild(unsigned int n, ASTNode* child)
   */
  LIBSBML_EXTERN
  int removeChild(unsigned int n);


  /**
   * Replaces and optionally deletes the nth child of this ASTNode with the given ASTNode.
   *
   * @param n unsigned int the index of the child to replace
   * @param newChild ASTNode to replace the nth child
   * @param delreplaced boolean indicating whether to delete the replaced child.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @copydetails doc_warning_modifying_structure
   *
   * @see addChild(ASTNode* child)
   * @see prependChild(ASTNode* child)
   * @see insertChild(unsigned int n, ASTNode* child)
   * @see removeChild(unsigned int n)
   */
  LIBSBML_EXTERN
  int replaceChild(unsigned int n, ASTNode *newChild, bool delreplaced=false);


  /**
   * Inserts the given ASTNode at point n in the list of children
   * of this ASTNode.
   *
   * @param n unsigned int the index of the ASTNode being added
   * @param newChild ASTNode to insert as the nth child
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @copydetails doc_warning_modifying_structure
   *
   * @see addChild(ASTNode* child)
   * @see prependChild(ASTNode* child)
   * @see replaceChild(unsigned int n, ASTNode* child)
   * @see removeChild(unsigned int n)
   */
  LIBSBML_EXTERN
  int insertChild(unsigned int n, ASTNode *newChild);


  /**
   * Creates a recursive copy of this node and all its children.
   *
   * @return a copy of this ASTNode and all its children.  The caller owns
   * the returned ASTNode and is responsible for deleting it.
   */
  LIBSBML_EXTERN
  ASTNode* deepCopy () const;


  /**
   * Gets a child of this node according to its index number.
   *
   * @param n the index of the child to get
   *
   * @return the nth child of this ASTNode or @c NULL if this node has no nth
   * child (<code>n &gt; </code>
   * @if clike getNumChildren()@else ASTNode::getNumChildren()@endif@~
   * <code>- 1</code>).
   *
   * @see getNumChildren()
   * @see getLeftChild()
   * @see getRightChild()
   */
  LIBSBML_EXTERN
  ASTNode* getChild (unsigned int n) const;


  /**
   * Gets the left child of this node.
   *
   * @return the left child of this ASTNode.  This is equivalent to calling
   * @if clike getChild()@else ASTNode::getChild(unsigned int)@endif@~
   * with an argument of @c 0.
   *
   * @see getNumChildren()
   * @see getChild()
   * @see getRightChild()
   */
  LIBSBML_EXTERN
  ASTNode* getLeftChild () const;


  /**
   * Gets the right child of this node.
   *
   * @return the right child of this ASTNode, or @c NULL if this node has no
   * right child.  If
   * @if clike getNumChildren()@else ASTNode::getNumChildren()@endif@~
   * <code>&gt; 1</code>, then this is equivalent to:
   * @verbatim
getChild( getNumChildren() - 1 );
@endverbatim
   *
   * @see getNumChildren()
   * @see getLeftChild()
   * @see getChild()
   */
  LIBSBML_EXTERN
  ASTNode* getRightChild () const;


  /**
   * Gets the number of children that this node has.
   *
   * @return the number of children of this ASTNode, or 0 is this node has
   * no children.
   */
  LIBSBML_EXTERN
  unsigned int getNumChildren () const;


  /**
   * Adds the given XMLNode as a <em>semantic annotation</em> of this ASTNode.
   *
   * @htmlinclude about-semantic-annotations.html
   *
   * @param sAnnotation the annotation to add.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note Although SBML permits the semantic annotation construct in
   * MathML expressions, the truth is that this construct has so far (at
   * this time of this writing, which is early 2011) seen very little use
   * in SBML software.  The full implications of using semantic annotations
   * are still poorly understood.  If you wish to use this construct, we
   * urge you to discuss possible uses and applications on the SBML
   * discussion lists, particularly <a target="_blank"
   * href="http://sbml.org/Forums">sbml-discuss&#64;caltech.edu</a> and/or <a
   * target="_blank"
   * href="http://sbml.org/Forums">sbml-interoperability&#64;caltech.edu</a>.
   */
  LIBSBML_EXTERN
  int addSemanticsAnnotation (XMLNode* sAnnotation);


  /**
   * Gets the number of <em>semantic annotation</em> elements inside this node.
   *
   * @htmlinclude about-semantic-annotations.html
   * 
   * @return the number of annotations of this ASTNode.
   *
   * @see ASTNode::addSemanticsAnnotation(XMLNode* sAnnotation)
   */
  LIBSBML_EXTERN
  unsigned int getNumSemanticsAnnotations () const;


  /**
   * Gets the nth semantic annotation of this node.
   *
   * @htmlinclude about-semantic-annotations.html
   * 
   * @return the nth annotation of this ASTNode, or @c NULL if this node has
   * no nth annotation (<code>n &gt;</code>
   * @if clike getNumSemanticsAnnotations()@else ASTNode::getNumSemanticsAnnotations()@endif@~
   * <code>- 1</code>).
   *
   * @see ASTNode::addSemanticsAnnotation(XMLNode* sAnnotation)
   */
  LIBSBML_EXTERN
  XMLNode* getSemanticsAnnotation (unsigned int n) const;


  /**
   * Returns a list of nodes satisfying a given predicate.
   *
   * This performs a depth-first search of the tree rooted at this ASTNode
   * object, and returns a List of nodes for which the given function
   * <code>predicate(node)</code> returns @c true (non-zero).
   *
   * For portability between different programming languages, the predicate
   * is passed in as a pointer to a function.  @if clike The function
   * definition must have the type @sbmlconstant{AST_PLUS, ASTNode.h::ASTNodePredicate
   * ASTNodePredicate@endlink, which is defined as
   * @verbatim
int (*ASTNodePredicate) (const ASTNode *node);
@endverbatim
   * where a return value of non-zero represents @c true and zero
   * represents @c false. @endif
   *
   * @param predicate the predicate to use
   *
   * @return the list of nodes for which the predicate returned @c true
   * (non-zero).  The List returned is owned by the caller and should be
   * deleted after the caller is done using it.  The ASTNode objects in the
   * list; however, are not owned by the caller (as they still belong to
   * the tree itself), and therefore should not be deleted.
   */
  LIBSBML_EXTERN
  List* getListOfNodes (ASTNodePredicate predicate) const;


  /**
   * Returns a list of nodes rooted at a given node and satisfying a given
   * predicate.
   *
   * This method is identical to calling
   * getListOfNodes(ASTNodePredicate predicate) const,
   * except that instead of creating a new List object, it uses the one
   * passed in as argument @p lst.  This method a depth-first search of the
   * tree rooted at this ASTNode object, and adds to the list @p lst the
   * nodes for which the given function <code>predicate(node)</code> returns
   * @c true (non-zero).
   *
   * For portability between different programming languages, the predicate
   * is passed in as a pointer to a function.  The function definition must
   * have the type @link ASTNode.h::ASTNodePredicate ASTNodePredicate
   *@endlink, which is defined as
   * @verbatim
int (*ASTNodePredicate) (const ASTNode_t *node);
@endverbatim
   * where a return value of non-zero represents @c true and zero
   * represents @c false.
   *
   * @param predicate the predicate to use.
   *
   * @param lst the List to which ASTNode objects should be added.
   *
   * @see getListOfNodes(ASTNodePredicate predicate) const
   */
  LIBSBML_EXTERN
  void fillListOfNodes (ASTNodePredicate predicate, List* lst) const;


  /**
   * Gets the value of this node as a single character.
   *
   * This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_PLUS, ASTNodeType_t},
   * @sbmlconstant{AST_MINUS, ASTNodeType_t},
   * @sbmlconstant{AST_TIMES, ASTNodeType_t},
   * @sbmlconstant{AST_DIVIDE, ASTNodeType_t} or
   * @sbmlconstant{AST_POWER, ASTNodeType_t}.
   *
   * @return the value of this ASTNode as a single character
   */
  LIBSBML_EXTERN
  char getCharacter () const;


  /**
   * Gets the id of this ASTNode.
   *
   * @return the MathML id of this ASTNode.
   */
  LIBSBML_EXTERN
  std::string getId () const;


  /**
   * Gets the class of this ASTNode.
   *
   * @return the MathML class of this ASTNode.
   */
  LIBSBML_EXTERN
  std::string getClass () const;


  /**
   * Gets the style of this ASTNode.
   *
   * @return the MathML style of this ASTNode.
   */
  LIBSBML_EXTERN
  std::string getStyle () const;


  /**
   * Gets the value of this node as an integer.
   *
   * This function should be called only when @if clike getType()@else
   * ASTNode::getType()@endif@~ <code>== @sbmlconstant{AST_INTEGER, ASTNodeType_t}</code>.
   *
   * @return the value of this ASTNode as a (<code>long</code>) integer.
   */
  LIBSBML_EXTERN
  long getInteger () const;


  /**
   * Gets the value of this node as a string.
   *
   * This function may be called on nodes that (1) are not operators, i.e.,
   * nodes for which @if clike isOperator()@else
   * ASTNode::isOperator()@endif@~ returns @c false, and (2) are not numbers,
   * i.e., @if clike isNumber()@else ASTNode::isNumber()@endif@~ returns @c
   * false.
   *
   * @return the value of this ASTNode as a string.
   */
  LIBSBML_EXTERN
  const char* getName () const;


  /**
   * Gets the value of this operator node as a string.  This function may be called
   * on nodes that are operators, i.e., nodes for which
   * @if clike isOperator()@else ASTNode::isOperator()@endif@~
   * returns @c true.
   * 
   * @return the name of this operator ASTNode as a string (or NULL if not an operator).
   */
  LIBSBML_EXTERN
  const char* getOperatorName () const;


  /**
   * Gets the value of the numerator of this node.  This function should be
   * called only when
   * @if clike getType()@else ASTNode::getType()@endif@~
   * <code>== @sbmlconstant{AST_RATIONAL, ASTNodeType_t}</code>.
   * 
   * @return the value of the numerator of this ASTNode.  
   */
  LIBSBML_EXTERN
  long getNumerator () const;


  /**
   * Gets the value of the denominator of this node.  This function should
   * be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~
   * <code>== @sbmlconstant{AST_RATIONAL, ASTNodeType_t}</code>.
   * 
   * @return the value of the denominator of this ASTNode.
   */
  LIBSBML_EXTERN
  long getDenominator () const;


  /**
   * Gets the real-numbered value of this node.  This function
   * should be called only when
   * @if clike isReal()@else ASTNode::isReal()@endif@~
   * <code>== true</code>.
   *
   * This function performs the necessary arithmetic if the node type is
   * @sbmlconstant{AST_REAL_E, ASTNodeType_t} (<em>mantissa *
   * 10<sup> exponent</sup></em>) or @sbmlconstant{AST_RATIONAL, ASTNodeType_t} (<em>numerator / denominator</em>).
   * 
   * @return the value of this ASTNode as a real (double).
   */
  LIBSBML_EXTERN
  double getReal () const;


  /**
   * Gets the mantissa value of this node.  This function should be called
   * only when @if clike getType()@else ASTNode::getType()@endif@~
   * returns @sbmlconstant{AST_REAL_E, ASTNodeType_t}
   * or @sbmlconstant{AST_REAL, ASTNodeType_t}.
   * If @if clike getType()@else ASTNode::getType()@endif@~
   * returns @sbmlconstant{AST_REAL, ASTNodeType_t},
   * this method is identical to
   * @if clike getReal()@else ASTNode::getReal()@endif.
   * 
   * @return the value of the mantissa of this ASTNode. 
   */
  LIBSBML_EXTERN
  double getMantissa () const;


  /**
   * Gets the exponent value of this ASTNode.  This function should be
   * called only when
   * @if clike getType()@else ASTNode::getType()@endif@~
   * returns @sbmlconstant{AST_REAL_E, ASTNodeType_t}
   * or @sbmlconstant{AST_REAL, ASTNodeType_t}.
   * 
   * @return the value of the exponent of this ASTNode.
   */
  LIBSBML_EXTERN
  long getExponent () const;


  /**
   * Gets the precedence of this node in the infix math syntax of SBML
   * Level&nbsp;1.  For more information about the infix syntax, see the
   * discussion about <a href="#math-convert">text string formulas</a> at
   * the top of the documentation for ASTNode.
   * 
   * @return an integer indicating the precedence of this ASTNode
   */
  LIBSBML_EXTERN
  int getPrecedence () const;


  /**
   * Gets the type of this ASTNode.  The value returned is one of the
   * enumeration values such as @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @sbmlconstant{AST_PLUS, ASTNodeType_t},
   * etc.
   * 
   * @return the type of this ASTNode.
   */
  LIBSBML_EXTERN
  ASTNodeType_t getType () const;


  /**
   * Gets the units of this ASTNode.  
   *
   * @htmlinclude about-sbml-units-attrib.html
   * 
   * @return the units of this ASTNode.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   * 
   * @if clike @see SBML_parseL3Formula()@endif@~
   * @if csharp @see SBML_parseL3Formula()@endif@~
   * @if python @see libsbml.parseL3Formula()@endif@~
   * @if java @see <code><a href="libsbml.html#parseL3Formula(String formula)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
   */
  LIBSBML_EXTERN
  std::string getUnits () const;


  /**
   * Returns @c true (non-zero) if this node is the special 
   * symbol @c avogadro.  The predicate returns @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is the special symbol avogadro.
   *
   * @if clike @see SBML_parseL3Formula()@endif@~
   * @if csharp @see SBML_parseL3Formula()@endif@~
   * @if python @see libsbml.parseL3Formula()@endif@~
   * @if java @see <code><a href="libsbml.html#parseL3Formula(String formula)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
   */
  LIBSBML_EXTERN
  bool isAvogadro () const;


  /**
   * Returns @c true (non-zero) if this node has a boolean type
   * (a logical operator, a relational operator, or the constants @c true
   * or @c false).
   *
   * @return true if this ASTNode is a boolean, false otherwise.
   */
  LIBSBML_EXTERN
  bool isBoolean () const;


  /**
   * Returns @c true (non-zero) if this node returns a boolean type
   * or @c false (zero) otherwise.
   *
   * This function looks at the whole ASTNode rather than just the top 
   * level of the ASTNode. Thus it will consider return values from
   * piecewise statements.  In addition, if this ASTNode uses a function
   * call, the return value of the functionDefinition will be determined.
   * Note that this is only possible where the ASTNode can trace its parent
   * Model, that is, the ASTNode must represent the math element of some
   * SBML object that has already been added to an instance of an SBMLDocument.
   *
   * @see isBoolean()
   *
   * @return true if this ASTNode returns a boolean, false otherwise.
   */
  LIBSBML_EXTERN
  bool returnsBoolean (const Model* model=NULL) const;


  /**
   * Returns @c true (non-zero) if this node represents a MathML
   * constant (e.g., @c true, @c Pi).
   * 
   * @return @c true if this ASTNode is a MathML constant, @c false otherwise.
   * 
   * @note this function will also return @c true for @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t} in SBML Level&nbsp;3.
   */
  LIBSBML_EXTERN
  bool isConstant () const;


  /**
   * Returns @c true (non-zero) if this node represents a
   * MathML function (e.g., <code>abs()</code>), or an SBML Level&nbsp;1
   * function, or a user-defined function.
   * 
   * @return @c true if this ASTNode is a function, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isFunction () const;


  /**
   * Returns @c true (non-zero) if this node represents
   * the special IEEE 754 value infinity, @c false (zero) otherwise.
   *
   * @return @c true if this ASTNode is the special IEEE 754 value infinity,
   * @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isInfinity () const;


  /**
   * Returns @c true (non-zero) if this node contains an
   * integer value, @c false (zero) otherwise.
   *
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_INTEGER, ASTNodeType_t}, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isInteger () const;


  /**
   * Returns @c true (non-zero) if this node is a MathML
   * <code>&lt;lambda&gt;</code>, @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isLambda () const;


  /**
   * Returns @c true (non-zero) if this node represents a 
   * @c log10 function, @c false (zero) otherwise.  More precisely, this
   * predicate returns @c true if the node type is @sbmlconstant{AST_FUNCTION_LOG, ASTNodeType_t} with two
   * children, the first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} equal to 10.
   * 
   * @return @c true if the given ASTNode represents a log10() function, @c
   * false otherwise.
   *
   * @if clike @see SBML_parseL3Formula()@endif@~
   * @if csharp @see SBML_parseL3Formula()@endif@~
   * @if python @see libsbml.parseL3Formula()@endif@~
   * @if java @see <code><a href="libsbml.html#parseL3Formula(String formula)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
   */
  LIBSBML_EXTERN
  bool isLog10 () const;


  /**
   * Returns @c true (non-zero) if this node is a MathML
   * logical operator (i.e., @c and, @c or, @c not, @c xor).
   * 
   * @return @c true if this ASTNode is a MathML logical operator
   */
  LIBSBML_EXTERN
  bool isLogical () const;


  /**
   * Returns @c true (non-zero) if this node is a user-defined
   * variable name in SBML L1, L2 (MathML), or the special symbols @c time
   * or @c avogadro.  The predicate returns @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is a user-defined variable name in SBML
   * L1, L2 (MathML) or the special symbols delay or time.
   */
  LIBSBML_EXTERN
  bool isName () const;


  /**
   * Returns @c true (non-zero) if this node represents the
   * special IEEE 754 value "not a number" (NaN), @c false (zero)
   * otherwise.
   * 
   * @return @c true if this ASTNode is the special IEEE 754 NaN.
   */
  LIBSBML_EXTERN
  bool isNaN () const;


  /**
   * Returns @c true (non-zero) if this node represents the
   * special IEEE 754 value "negative infinity", @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is the special IEEE 754 value negative
   * infinity, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isNegInfinity () const;


  /**
   * Returns @c true (non-zero) if this node contains a number,
   * @c false (zero) otherwise.  This is functionally equivalent to the
   * following code:
   * @verbatim
 isInteger() || isReal()
 @endverbatim
   * 
   * @return @c true if this ASTNode is a number, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isNumber () const;


  /**
   * Returns @c true (non-zero) if this node is a mathematical
   * operator, meaning, <code>+</code>, <code>-</code>, <code>*</code>, 
   * <code>/</code> or <code>^</code> (power).
   * 
   * @return @c true if this ASTNode is an operator.
   */
  LIBSBML_EXTERN
  bool isOperator () const;


  /**
   * Returns @c true (non-zero) if this node is the MathML
   * <code>&lt;piecewise&gt;</code> construct, @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is a MathML @c piecewise function
   */
  LIBSBML_EXTERN
  bool isPiecewise () const;


  /**
   * Returns @c true (non-zero) if this node represents a rational
   * number, @c false (zero) otherwise.
   * 
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   */
  LIBSBML_EXTERN
  bool isRational () const;


  /**
   * Returns @c true (non-zero) if this node can represent a
   * real number, @c false (zero) otherwise.
   *
   * More precisely, this node must be of one of the following types: @sbmlconstant{AST_REAL, ASTNodeType_t}, @sbmlconstant{AST_REAL_E, ASTNodeType_t} or @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   *
   * @return @c true if the value of this ASTNode can represented as a real
   * number, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isReal () const;


  /**
   * Returns @c true (non-zero) if this node is a MathML
   * relational operator, meaning <code>==</code>, <code>&gt;=</code>,
   * <code>&gt;</code>, <code>&lt;</code>, and <code>!=</code>.
   *
   * @return @c true if this ASTNode is a MathML relational operator, @c
   * false otherwise
   */
  LIBSBML_EXTERN
  bool isRelational () const;


  /**
   * Returns @c true (non-zero) if this node represents a
   * square root function, @c false (zero) otherwise.
   *
   * More precisely, the node type must be @sbmlconstant{AST_FUNCTION_ROOT, ASTNodeType_t} with two
   * children, the first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} node having value equal to 2.
   * 
   * @return @c true if the given ASTNode represents a sqrt() function,
   * @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isSqrt () const;


  /**
   * Returns @c true (non-zero) if this node is a unary minus
   * operator, @c false (zero) otherwise.
   *
   * A node is defined as a unary minus node if it is of type @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
   *
   * For numbers, unary minus nodes can be "collapsed" by negating the
   * number.  In fact, 
   * @if clike SBML_parseFormula()@endif@if csharp SBML_parseFormula()@endif@if python libsbml.parseFormula()@endif@if java <code><a href="libsbml.html#parseFormula(java.lang.String)">libsbml.parseFormula(String formula)</a></code>@endif@~
   * does this during its parsing process, and 
   * @if clike SBML_parseL3Formula()@endif@if csharp SBML_parseL3Formula()@endif@if python libsbml.parseL3Formula()@endif@if java <code><a href="libsbml.html#parseL3Formula(java.lang.String)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
   * has a configuration option that allows this behavior to be turned
   * on or off.  However, unary minus nodes for symbols
   * (@sbmlconstant{AST_NAME, ASTNodeType_t}) cannot
   * be "collapsed", so this predicate function is necessary.
   * 
   * @return @c true if this ASTNode is a unary minus, @c false otherwise.
   *
   * @if clike @see SBML_parseL3Formula()@endif@~
   * @if csharp @see SBML_parseL3Formula()@endif@~
   * @if python @see libsbml.parseL3Formula()@endif@~
   * @if java @see <code><a href="libsbml.html#parseL3Formula(String formula)">libsbml.parseL3Formula(String formula)</a></code>@endif@~
   */
  LIBSBML_EXTERN
  bool isUMinus () const;


  /**
   * Returns @c true (non-zero) if this node is a unary plus
   * operator, @c false (zero) otherwise.  A node is defined as a unary
   * minus node if it is of type @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
   *
   * @return @c true if this ASTNode is a unary plus, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isUPlus () const;


  /**
  * Returns @c true if this node is of type @param type
  * and has @param numchildren number of children.  Designed
  * for use in cases where it is useful to discover if the node is
  * a unary not or unary minus, or a times node with no children, etc.
  *
  * @return @c true if this ASTNode is has the specified type and number
  *         of children, @c false otherwise.
  */
  LIBSBML_EXTERN
  int hasTypeAndNumChildren(ASTNodeType_t type, unsigned int numchildren) const;


  /**
   * Returns @c true (non-zero) if this node has an unknown type.
   *
   * "Unknown" nodes have the type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  Nodes with unknown types will not appear in an
   * ASTNode tree returned by libSBML based upon valid SBML input; the only
   * situation in which a node with type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t} may appear is immediately after having create a
   * new, untyped node using the ASTNode constructor.  Callers creating
   * nodes should endeavor to set the type to a valid node type as soon as
   * possible after creating new nodes.
   * 
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool isUnknown () const;


  /**
   * Returns @c true (non-zero) if this node has a value for the MathML
   * attribute "id".
   *
   * @return true if this ASTNode has an attribute id, false otherwise.
   */
  LIBSBML_EXTERN
  bool isSetId() const;


  /**
   * Returns @c true (non-zero) if this node has a value for the MathML
   * attribute "class".
   *
   * @return true if this ASTNode has an attribute class, false otherwise.
   */
  LIBSBML_EXTERN
  bool isSetClass() const;


  /**
   * Returns @c true (non-zero) if this node has a value for the MathML
   * attribute "style".
   *
   * @return true if this ASTNode has an attribute style, false otherwise.
   */
  LIBSBML_EXTERN
  bool isSetStyle() const;


  /**
   * Returns @c true (non-zero) if this node has the attribute
   * <code>sbml:units</code>.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @return @c true if this ASTNode has units associated with it, @c false otherwise.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   */
  LIBSBML_EXTERN
  bool isSetUnits() const;


  /**
   * Returns @c true (non-zero) if this node or any of its
   * children nodes have the attribute <code>sbml:units</code>.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @return @c true if this ASTNode or its children has units associated
   * with it, @c false otherwise.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   */
  LIBSBML_EXTERN
  bool hasUnits() const;


  /**
   * Sets the value of this ASTNode to the given character.  If character
   * is one of @c +, @c -, <code>*</code>, <code>/</code> or @c ^, the node
   * type will be set accordingly.  For all other characters, the node type
   * will be set to @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.
   *
   * @param value the character value to which the node's value should be
   * set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setCharacter (char value);


  /**
   * Sets the MathML id of this ASTNode to id.
   *
   * @param id @c string representing the identifier.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setId (std::string id);


  /**
   * Sets the MathML class of this ASTNode to className.
   *
   * @param className @c string representing the MathML class for this node.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setClass (std::string className);


  /**
   * Sets the MathML style of this ASTNode to style.
   *
   * @param style @c string representing the identifier.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setStyle (std::string style);


  /**
   * Sets the value of this ASTNode to the given name.
   *
   * As a side-effect, this ASTNode object's type will be reset to
   * @sbmlconstant{AST_NAME, ASTNodeType_t} if (and <em>only
   * if</em>) the ASTNode was previously an operator (
   * @if clike isOperator()@else ASTNode::isOperator()@endif@~
   * <code>== true</code>), number (
   * @if clike isNumber()@else ASTNode::isNumber()@endif@~
   * <code>== true</code>), or unknown.
   * This allows names to be set for @sbmlconstant{AST_FUNCTION, ASTNodeType_t} nodes and the like.
   *
   * @param name the string containing the name to which this node's value
   * should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setName (const char *name);


  /**
   * Sets the value of this ASTNode to the given integer and sets the node
   * type to @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
   *
   * @param value the integer to which this node's value should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setValue (int value);


  /**
   * Sets the value of this ASTNode to the given (@c long) integer and sets
   * the node type to @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
   *
   * @param value the integer to which this node's value should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setValue (long value);


  /**
   * Sets the value of this ASTNode to the given rational in two parts: the
   * numerator and denominator.  The node type is set to @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   *
   * @param numerator the numerator value of the rational
   * @param denominator the denominator value of the rational
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setValue (long numerator, long denominator);


  /**
   * Sets the value of this ASTNode to the given real (@c double) and sets
   * the node type to @sbmlconstant{AST_REAL, ASTNodeType_t}.
   *
   * This is functionally equivalent to:
   * @verbatim
setValue(value, 0);
@endverbatim
   *
   * @param value the @c double format number to which this node's value
   * should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setValue (double value);


  /**
   * Sets the value of this ASTNode to the given real (@c double) in two
   * parts: the mantissa and the exponent.  The node type is set to
   * @sbmlconstant{AST_REAL_E, ASTNodeType_t}.
   *
   * @param mantissa the mantissa of this node's real-numbered value
   * @param exponent the exponent of this node's real-numbered value
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setValue (double mantissa, long exponent);


  /**
   * Sets the type of this ASTNode to the given type code.
   *
   * @param type the type to which this node should be set
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note A side-effect of doing this is that any numerical values previously
   * stored in this node are reset to zero.
   */
  LIBSBML_EXTERN
  int setType (ASTNodeType_t type);


  /**
   * Sets the units of this ASTNode to units.
   *
   * The units will be set @em only if this ASTNode object represents a
   * MathML <code>&lt;cn&gt;</code> element, i.e., represents a number.
   * Callers may use
   * @if clike isNumber()@else ASTNode::isNumber()@endif@~
   * to inquire whether the node is of that type.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @param units @c string representing the unit identifier.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   */
  LIBSBML_EXTERN
  int setUnits (std::string units);


  /**
   * Swaps the children of this ASTNode object with the children of the
   * given ASTNode object.
   *
   * @param that the other node whose children should be used to replace
   * <em>this</em> node's children
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int swapChildren (ASTNode *that);


  /**
   * Renames all the SIdRef attributes on this node and any child node
   */
  LIBSBML_EXTERN
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * Renames all the UnitSIdRef attributes on this node and any child node.
   * (The only place UnitSIDRefs appear in MathML <code>&lt;cn&gt;</code> elements.)
   */
  LIBSBML_EXTERN
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Replace any nodes of type AST_NAME with the name 'id' from the child 'math' object with the provided ASTNode. 
   *
   */
  LIBSBML_EXTERN
  virtual void replaceIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Replaces any 'AST_NAME_TIME' nodes with a node that multiplies time by the given function.
   *
   */
  LIBSBML_EXTERN
  virtual void multiplyTimeBy(const ASTNode* function);
  /** @endcond */


  /**
   * Unsets the units of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int unsetUnits ();

  /**
   * Unsets the MathML id of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int unsetId ();


  /**
   * Unsets the MathML class of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int unsetClass ();


  /**
   * Unsets the MathML style of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int unsetStyle ();


  /** @cond doxygenLibsbmlInternal */

  /**
   * Sets the flag indicating that this ASTNode has semantics attached.
   *
   * @htmlinclude about-semantic-annotations.html
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setSemanticsFlag();


  /**
   * Unsets the flag indicating that this ASTNode has semantics attached.
   *
   * @htmlinclude about-semantic-annotations.html
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int unsetSemanticsFlag();


  /**
   * Gets the flag indicating that this ASTNode has semantics attached.
   *
   * @htmlinclude about-semantic-annotations.html
   *
   * @return @c true if this node has semantics attached, @c false otherwise.
   */
  LIBSBML_EXTERN
  bool getSemanticsFlag() const;


  /**
   * Sets the attribute "definitionURL".
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  LIBSBML_EXTERN
  int setDefinitionURL(XMLAttributes url);


  /**
   * Sets the MathML attribute @c definitionURL.
   *
   * @param url the URL value for the @c definitionURL attribute.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @see setDefinitionURL(XMLAttributes url)
   * @see getDefinitionURL()
   * @see getDefinitionURLString()
   */
  LIBSBML_EXTERN
  int setDefinitionURL(const std::string& url);


  /** @endcond */


  /**
   * Gets the MathML "definitionURL" attribute value.
   *
   * @return the value of the @c definitionURL attribute, in the form of
   * a libSBML XMLAttributes object.
   */
  LIBSBML_EXTERN
  XMLAttributes* getDefinitionURL() const;


  /**
   * Replaces occurences of a given name within this ASTNode with the
   * name/value/formula represented by @p arg.
   * 
   * For example, if the formula in this ASTNode is <code>x + y</code>,
   * then the <code>&lt;bvar&gt;</code> is @c x and @c arg is an ASTNode
   * representing the real value @c 3.  This method substitutes @c 3 for @c
   * x within this ASTNode object.
   *
   * @param bvar a string representing the variable name to be substituted
   * @param arg an ASTNode representing the name/value/formula to substitute
   */
  LIBSBML_EXTERN
  void replaceArgument(const std::string bvar, ASTNode * arg);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Sets the parent SBML object.
   * 
   * @param sb the parent SBML object of this ASTNode.
   */
  LIBSBML_EXTERN
  void setParentSBMLObject(SBase * sb);

  /** @endcond */


  /**
   * Returns the parent SBML object.
   * 
   * @return the parent SBML object of this ASTNode.
   */
  LIBSBML_EXTERN
  SBase * getParentSBMLObject() const;


  /**
   * Unsets the parent SBML object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isSetParentSBMLObject()
   * @see getParentSBMLObject()
   */
  LIBSBML_EXTERN
  int unsetParentSBMLObject();


  /**
   * Returns @c true if this node has a value for the parent SBML
   * object.
   *
   * @return true if this ASTNode has an parent SBML object set, @c false otherwise.
   *
   * @see getParentSBMLObject()
   * @if clike @see setParentSBMLObject()@endif@~
   */
  LIBSBML_EXTERN
  bool isSetParentSBMLObject() const;


  /**
   * Reduces this ASTNode to a binary tree.
   * 
   * Example: if this ASTNode is <code>and(x, y, z)</code>, then the 
   * formula of the reduced node is <code>and(and(x, y), z)</code>.  The
   * operation replaces the formula stored in the current ASTNode object.
   */
  LIBSBML_EXTERN
  void reduceToBinary();

  
 /**
  * Sets the user data of this node.
  *
  * The user data can be used by the application developer to attach custom
  * information to the node.  In case of a deep copy, this attribute will
  * passed as it is. The attribute will be never interpreted by this class.
  * 
  * @param userData specifies the new user data. 
  *
  * @copydetails doc_returns_success_code
  * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
  * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
  */
  LIBSBML_EXTERN
  int setUserData(void *userData);


 /**
  * Returns the user data that has been previously set via setUserData().
  *
  * @return the user data of this node, or @c NULL if no user data has been set.
  *
  * @if clike
  * @see ASTNode::setUserData
  * @endif@~
  */
  LIBSBML_EXTERN
  void *getUserData() const;


 /**
  * Unsets the user data of this node.
  *
  * The user data can be used by the application developer to attach custom
  * information to the node.  In case of a deep copy, this attribute will
  * passed as it is. The attribute will be never interpreted by this class.
  *
  * @copydetails doc_returns_success_code
  * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
  * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
  *
  * @if clike
  * @see ASTNode::setUserData()
  * @see ASTNode::getUserData()
  * @see ASTNode::isSetUserData()
  * @endif@~
  */
  LIBSBML_EXTERN
  int unsetUserData();


 /**
  * Returns @c true if this node has a user data object.
  *
  * @return true if this ASTNode has a user data object set, @c false
  * otherwise.
  *
  * @if clike
  * @see ASTNode::setUserData()
  * @see ASTNode::getUserData()
  * @see ASTNode::unsetUserData()
  * @endif@~
  */
  LIBSBML_EXTERN
  bool isSetUserData() const;


 /**
  * Returns @c true or @c false depending on whether this
  * ASTNode is well-formed.
  *
  * @note An ASTNode may be well-formed, with each node and its children
  * having the appropriate number of children for the given type, but may
  * still be invalid in the context of its use within an SBML model.
  *
  * @return @c true if this ASTNode is well-formed, @c false otherwise.
  *
  * @see hasCorrectNumberArguments()
  */
  LIBSBML_EXTERN
  bool isWellFormedASTNode() const;


 /**
  * Returns @c true or @c false depending on whether this
  * ASTNode has the correct number of children for its type.
  *
  * For example, an ASTNode with type @sbmlconstant{AST_PLUS, ASTNodeType_t} expects 2 child nodes.
  *
  * @note This function performs a check on the top-level node only.  Child
  * nodes are not checked.
  *
  * @return @c true if this ASTNode has the appropriate number of children
  * for its type, @c false otherwise.
  *
  * @see isWellFormedASTNode()
  */
  LIBSBML_EXTERN
  bool hasCorrectNumberArguments() const;

  /**
   * Returns the MathML @c definitionURL attribute value as a string.
   *
   * @return the value of the @c definitionURL attribute, as a string.
   *
   * @see getDefinitionURL()
   * @see setDefinitionURL(const std::string& url)
   * @see setDefinitionURL(XMLAttributes url)
   */
  LIBSBML_EXTERN
  std::string getDefinitionURLString() const;


  /** @cond doxygenLibsbmlInternal */

  LIBSBML_EXTERN
  bool representsBvar() const;


  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
    
  LIBSBML_EXTERN
  bool isBvar() const;
  
  LIBSBML_EXTERN
  void setBvar();

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /**
  * Predicate returning @c true (non-zero) if this node is a MathML
  * qualifier (i.e., @c bvar, @c degree, @c base, @c piece, @c otherwise),
  * @c false (zero) otherwise.
  *
  * @return @c true if this ASTNode is a MathML qualifier.
  */
  LIBSBML_EXTERN
  virtual bool isQualifier() const;

  /**
  * Predicate returning @c true (non-zero) if this node is a MathML
  * semantics node, @c false (zero) otherwise.
  *
  * @return @c true if this ASTNode is a MathML semantics node.
  */
  LIBSBML_EXTERN
  virtual bool isSemantics() const;

  LIBSBML_EXTERN
  unsigned int getNumBvars() const;

  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  LIBSBML_EXTERN
  bool containsVariable(const std::string id) const;

  LIBSBML_EXTERN
  unsigned int getNumVariablesWithUndeclaredUnits(Model * m = NULL) const;

  friend class UnitFormulaFormatter;
  /**
   * Internal helper function for canonicalize().
   */

  bool canonicalizeConstant   ();
  bool canonicalizeFunction   ();
  bool canonicalizeFunctionL1 ();
  bool canonicalizeLogical    ();
  bool canonicalizeRelational ();


  ASTNodeType_t mType;

  char   mChar;
  char*  mName;
  long   mInteger;
  double mReal;
  long mDenominator;
  long mExponent;

  XMLAttributes* mDefinitionURL;
  bool hasSemantics;

  List *mChildren;

  List *mSemanticsAnnotations;

  SBase *mParentSBMLObject;

  std::string mUnits;

  // additional MathML attributes
  std::string mId;
  std::string mClass;
  std::string mStyle;

  bool mIsBvar;
  void *mUserData;
  
  friend class MathMLFormatter;
  friend class MathMLHandler;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new ASTNode_t structure and returns a pointer to it.
 *
 * The returned node will have a type of @c AST_UNKNOWN.  The caller should
 * be set the node type to something else as soon as possible using
 * ASTNode_setType().
 *
 * @returns a pointer to the fresh ASTNode_t structure.
 *
 * @see ASTNode_createWithType()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_create (void);


/**
 * Creates a new ASTNode_t structure and sets its type.
 *
 * @param type the type of node to create
 *
 * @returns a pointer to the fresh ASTNode_t structure.
 *
 * @see ASTNode_create()
 * 
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_createWithType (ASTNodeType_t type);


/**
 * Creates a new ASTNode_t structure from the given Token_t data and returns
 * a pointer to it.
 *
 * The returned ASTNode_t structure will contain the same data as the Token_t
 * structure.  The Token_t structure is used to store a token returned by
 * FormulaTokenizer_nextToken().  It contains a union whose members can store
 * different types of tokens, such as numbers and symbols.
 *
 * @param token the Token_t structure to use
 *
 * @returns a pointer to the new ASTNode_t structure.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_createFromToken (Token_t *token);


/**
 * Frees the given ASTNode_t structure, including any child nodes.
 *
 * @param node the node to be freed.
 * 
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void
ASTNode_free (ASTNode_t *node);


/**
 * Frees the name field of a given node and sets it to null.
 *
 * This operation is only applicable to ASTNode_t structures corresponding to
 * operators, numbers, or @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  This method will have no effect on other types of
 * nodes.
 *
 * @param node the node whose name field should be freed.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_freeName (ASTNode_t *node);


/**
 * Converts a given node to a canonical form and returns @c 1 if successful,
 * @c 0 otherwise.
 *
 * The rules determining the canonical form conversion are as follows:
 *
 * @li If the node type is @sbmlconstant{AST_NAME, ASTNodeType_t}
 * and the node name matches @c "ExponentialE", @c "Pi", @c "True" or @c
 * "False" the node type is converted to the corresponding 
 * <code>AST_CONSTANT_</code><em><span class="placeholder">X</span></em> type.
 * @li If the node type is an @sbmlconstant{AST_FUNCTION, ASTNodeType_t} and the node name matches an SBML (MathML) function name, logical operator name, or
 * relational operator name, the node is converted to the corresponding
 * <code>AST_FUNCTION_</code><em><span class="placeholder">X</span></em> or
 * <code>AST_LOGICAL_</code><em><span class="placeholder">X</span></em> type.
 *
 * SBML Level&nbsp;1 function names are searched first; thus, for
 * example, canonicalizing @c log will result in a node type of @sbmlconstant{AST_FUNCTION_LN, ASTNodeType_t}.  (See the SBML
 * Level&nbsp;1 Version&nbsp;2 Specification, Appendix C.)
 *
 * Sometimes, canonicalization of a node results in a structural
 * conversion of the node as a result of adding a child.  For example, a
 * node with the SBML Level&nbsp;1 function name @c sqr and a single
 * child node (the argument) will be transformed to a node of type
 * @sbmlconstant{AST_FUNCTION_POWER, ASTNodeType_t} with
 * two children.  The first child will remain unchanged, but the second
 * child will be an ASTNode of type @sbmlconstant{AST_INTEGER, ASTNodeType_t} and a value of 2.  The function names that result
 * in structural changes are: @c log10, @c sqr, and @c sqrt.
 *
 * @param node the node to be converted.
 *
 * @returns @c 1 if successful, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_canonicalize (ASTNode_t *node);


/**
 * Adds a node as a child of another node.
 *
 * Child nodes are added in order from "left-to-right".
 *
 * @param node the node which will get the new child node
 * @param child the ASTNode_t instance to add
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_prependChild()
 * @see ASTNode_replaceChild()
 * @see ASTNode_insertChild()
 * @see ASTNode_removeChild()
 * @see ASTNode_isWellFormedASTNode()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_addChild (ASTNode_t *node, ASTNode_t *child);


/**
 * Adds a node as a child of another node.
 *
 * This method adds child nodes from right to left.
 *
 * @param node the node that will receive the given child node.
 * @param child the ASTNode_t instance to add.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_addChild()
 * @see ASTNode_replaceChild()
 * @see ASTNode_insertChild()
 * @see ASTNode_removeChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_prependChild (ASTNode_t *node, ASTNode_t *child);


/**
 * Removes the nth child of a given node.
 *
 * @param node the node whose child element is to be removed.
 * @param n unsigned int the index of the child to remove.
 *
 * @return integer value indicating success/failure of the
 * function. The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_addChild()
 * @see ASTNode_prependChild()
 * @see ASTNode_replaceChild()
 * @see ASTNode_insertChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_removeChild(ASTNode_t* node, unsigned int n);


/**
 * Replaces the nth child of a given node.
 *
 * @param node the ASTNode_t node to modify
 * @param n unsigned int the index of the child to replace
 * @param newChild ASTNode_t structure to replace the nth child
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_addChild()
 * @see ASTNode_prependChild()
 * @see ASTNode_insertChild()
 * @see ASTNode_removeChild()
 * @see ASTNode_replaceAndDeleteChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_replaceChild(ASTNode_t* node, unsigned int n, ASTNode_t * newChild);


/**
 * Replaces and deletes the nth child of a given node.
 *
 * @param node the ASTNode_t node to modify
 * @param n unsigned int the index of the child to replace
 * @param newChild ASTNode_t structure to replace the nth child
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_addChild()
 * @see ASTNode_prependChild()
 * @see ASTNode_insertChild()
 * @see ASTNode_removeChild()
 * @see ASTNode_replaceChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_replaceAndDeleteChild(ASTNode_t* node, unsigned int n, ASTNode_t * newChild);


/**
 * Insert a new child node at a given point in the list of children of a
 * node.
 *
 * @param node the ASTNode_t structure to modify.
 * @param n unsigned int the index of the location where the @p newChild is
 * to be added.
 * @param newChild ASTNode_t structure to insert as the nth child.
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @copydetails doc_warning_modifying_structure
 *
 * @see ASTNode_addChild()
 * @see ASTNode_prependChild()
 * @see ASTNode_replaceChild()
 * @see ASTNode_removeChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_insertChild(ASTNode_t* node, unsigned int n, ASTNode_t * newChild);


/**
 * Creates a recursive copy of a node and all its children.
 *
 * @param node the ASTNode_t structure to copy.
 *
 * @return a copy of this ASTNode_t structure and all its children.  The
 * caller owns the returned structure and is reponsible for deleting it.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_deepCopy (const ASTNode_t *node);


/**
 * Gets a child of a node according to its index number.
 *
 * @param node the node whose child should be obtained.
 * @param n the index of the desired child node.
 *
 * @return the nth child of this ASTNode or a null pointer if this node has
 * no nth child (<code>n &gt; </code> ASTNode_getNumChildre() <code>- 1</code>).
 *
 * @see ASTNode_getNumChildren()
 * @see ASTNode_getLeftChild()
 * @see ASTNode_getRightChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_getChild (const ASTNode_t *node, unsigned int n);


/**
 * Returns the left-most child of a given node.
 *
 * This is equivalent to <code>ASTNode_getChild(node, 0)</code>.
 *
 * @param node the node whose child is to be returned.
 *
 * @return the left child, or a null pointer if there are no children.
 *
 * @see ASTNode_getNumChildren()
 * @see ASTNode_getChild()
 * @see ASTNode_getRightChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_getLeftChild (const ASTNode_t *node);


/**
 * Returns the right-most child of a given node.
 *
 * If <code>ASTNode_getNumChildren(node) > 1</code>, then this is equivalent
 * to:
 * @verbatim
ASTNode_getChild(node, ASTNode_getNumChildren(node) - 1);
@endverbatim
 *
 * @param node the node whose child node is to be obtained.
 *
 * @return the right child of @p node, or a null pointer if @p node has no
 * right child.
 *
 * @see ASTNode_getNumChildren()
 * @see ASTNode_getLeftChild()
 * @see ASTNode_getChild()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNode_t *
ASTNode_getRightChild (const ASTNode_t *node);


/**
 * Returns the number of children of a given node.
 *
 * @param node the ASTNode_t structure whose children are to be counted.
 *
 * @return the number of children of @p node, or @c 0 is it has no children.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
unsigned int
ASTNode_getNumChildren (const ASTNode_t *node);


/**
 * Returns a list of nodes rooted at a given node and satisfying a given
 * predicate.
 *
 * This function performs a depth-first search of the tree rooted at the
 * given ASTNode_t structure, and returns a List_t structure of nodes for
 * which the given function <code>predicate(node)</code> returns true (i.e.,
 * non-zero).
 *
 * The predicate is passed in as a pointer to a function.  The function
 * definition must have the type @link ASTNode.h::ASTNodePredicate
 * ASTNodePredicate@endlink, which is defined as
 * @verbatim
 int (*ASTNodePredicate) (const ASTNode_t *node);
 @endverbatim
 * where a return value of nonzero represents true and zero
 * represents false.
 *
 * @param node the node at which the search is to be started
 * @param predicate the predicate to use
 *
 * @return the list of nodes for which the predicate returned true (i.e.,
 * nonzero).  The List_t structure returned is owned by the caller and
 * should be deleted after the caller is done using it.  The ASTNode_t
 * structures in the list, however, are @em not owned by the caller (as they
 * still belong to the tree itself), and therefore should @em not be deleted.
 *
 * @see ASTNode_fillListOfNodes()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
List_t *
ASTNode_getListOfNodes (const ASTNode_t *node, ASTNodePredicate predicate);


/**
 * Returns a list of nodes rooted at a given node and satisfying a given
 * predicate.
 *
 * This method is identical to ASTNode_getListOfNodes(), except that instead
 * of creating a new List_t structure, it uses the one passed in as argument
 * @p lst.  This function performs a depth-first search of the tree rooted at
 * the given ASTNode_t structure, and adds to @p lst the nodes for which the
 * given function <code>predicate(node)</code> returns true (i.e., nonzero).
 *
 * The predicate is passed in as a pointer to a function.  The function
 * definition must have the type @link ASTNode.h::ASTNodePredicate ASTNodePredicate
 *@endlink, which is defined as
 * @verbatim
 int (*ASTNodePredicate) (const ASTNode_t *node);
 @endverbatim
 * where a return value of non-zero represents true and zero
 * represents false.
 *
 * @param node the node at which the search is to be started
 * @param predicate the predicate to use
 * @param lst the list to use
 *
 * @see ASTNode_getListOfNodes()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void
ASTNode_fillListOfNodes ( const ASTNode_t  *node,
                          ASTNodePredicate predicate,
                          List_t           *lst );


/**
 * Gets the value of a node as a single character.
 *
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_PLUS, ASTNodeType_t},
 * @sbmlconstant{AST_MINUS, ASTNodeType_t},
 * @sbmlconstant{AST_TIMES, ASTNodeType_t},
 * @sbmlconstant{AST_DIVIDE, ASTNodeType_t} or
 * @sbmlconstant{AST_POWER, ASTNodeType_t} for the given
 * @p node.
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of @p node as a single character, or the value @c
 * CHAR_MAX if @p is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char
ASTNode_getCharacter (const ASTNode_t *node);


/**
 * Gets the value of a node as an integer.
 *
 * This function should be called only when ASTNode_getType() returns @sbmlconstant{AST_INTEGER, ASTNodeType_t} for the given @p node.
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of the given ASTNode_t structure as a
 * (<code>long</code>) integer, or the value @c LONG_MAX if @p is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
long
ASTNode_getInteger (const ASTNode_t *node);


/**
 * Gets the value of a node as a string.
 *
 * This function may be called on nodes that (1) are not operators, i.e.,
 * nodes for which ASTNode_isOperator() returns false (@c 0), and (2) are not
 * numbers, i.e., for which ASTNode_isNumber() also returns false (@c 0).
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of @p node as a string, or a null pointer if @p is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
const char *
ASTNode_getName (const ASTNode_t *node);


/**
 * Gets the numerator value of a node representing a rational number.
 *
 * This function should be called only when ASTNode_getType() returns @sbmlconstant{AST_RATIONAL, ASTNodeType_t} for the given @p node.
 *
 * @param node the node whose value is to be returned.

 * @return the value of the numerator of @p node, or the value @c LONG_MAX if
 * @p is null.
 *
 * @see ASTNode_getDenominator()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
long
ASTNode_getNumerator (const ASTNode_t *node);


/**
 * Gets the numerator value of a node representing a rational number.
 *
 * This function should be called only when ASTNode_getType() returns @sbmlconstant{AST_RATIONAL, ASTNodeType_t} for the given @p node.
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of the denominator of @p node, or the value @c LONG_MAX
 * if @p is null.
 *
 * @see ASTNode_getNumerator()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
long
ASTNode_getDenominator (const ASTNode_t *node);


/**
 * Get the real-numbered value of a node.
 *
 * This function should be called only when ASTNode_isReal() returns non-zero
 * for @p node. This function performs the necessary arithmetic if the node
 * type is @sbmlconstant{AST_REAL_E, ASTNodeType_t} (<em>mantissa *
 * 10<sup> exponent</sup></em>) or @sbmlconstant{AST_RATIONAL, ASTNodeType_t} (<em>numerator / denominator</em>).
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of @p node as a real (double), or NaN if @p
 * is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
double
ASTNode_getReal (const ASTNode_t *node);


/**
 * Get the mantissa value of a node.
 *
 * This function should be called only when ASTNode_getType() returns @sbmlconstant{AST_REAL_E, ASTNodeType_t} or @sbmlconstant{AST_REAL, ASTNodeType_t} for the given @p node.  If
 * ASTNode_getType() returns @sbmlconstant{AST_REAL, ASTNodeType_t}
 * for @p node, this method behaves identically to ASTNode_getReal().
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of the mantissa of @p node, or NaN if @p is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
double
ASTNode_getMantissa (const ASTNode_t *node);


/**
 * Get the exponent value of a node.
 *
 * This function should be called only when ASTNode_getType() returns @sbmlconstant{AST_REAL_E, ASTNodeType_t} or @sbmlconstant{AST_REAL, ASTNodeType_t} for the given @p node.
 *
 * @param node the node whose value is to be returned.
 *
 * @return the value of the exponent field in the given @p node ASTNode_t
 * structure, or NaN if @p is null.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
long
ASTNode_getExponent (const ASTNode_t *node);


/**
 * Gets the precedence of a node in the infix math syntax of SBML
 * Level&nbsp;1.
 *
 * @copydetails doc_summary_of_string_math
 *
 * @param node the node whose precedence is to be calculated.
 *
 * @return the precedence of @p node (as defined in the SBML Level&nbsp;1
 * specification).
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_getPrecedence (const ASTNode_t *node);


/**
 * Returns the type of the given node.
 *
 * @param node the node
 *
 * @return the type of the given ASTNode_t structure.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
ASTNodeType_t
ASTNode_getType (const ASTNode_t *node);


/**
 * Returns the MathML "id" attribute of a given node.
 *
 * @param node the node whose identifier should be returned
 *
 * @returns the identifier of the node, or null if @p is a null pointer.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char *
ASTNode_getId(const ASTNode_t * node);


/**
 * Returns the MathML "class" attribute of a given node.
 *
 * @param node the node whose class should be returned
 *
 * @returns the class identifier, or null if @p is a null pointer.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char *
ASTNode_getClass(const ASTNode_t * node);


/**
 * Returns the MathML "style" attribute of a given node.
 *
 * @param node the node
 *
 * @return a string representing the "style" value, or a null value if @p is
 * a null pointer.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char *
ASTNode_getStyle(const ASTNode_t * node);


/**
 * Returns the SBML "units" attribute of a given node.
 *
 * @htmlinclude about-sbml-units-attrib.html
 *
 * @param node the node whose units are to be returned.
 *
 * @return the units, as a string, or a null value if @p is a null pointer.
 *
 * @note The <code>sbml:units</code> attribute for MathML expressions is only
 * defined in SBML Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of
 * SBML.
 *
 * @see SBML_parseL3Formula()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char *
ASTNode_getUnits(const ASTNode_t * node);


/**
 * Returns true if the given node represents the special symbol @c avogadro.
 *
 * @param node the node to query
 *
 * @return @c 1 if this stands for @c avogadro, @c 0 otherwise.
 *
 * @see SBML_parseL3Formula()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isAvogadro (const ASTNode_t * node);


/**
 * Returns true if this node is some type of Boolean value or operator.
 *
 * @param node the node in question
 *
 * @return @c 1 (true) if @p node is a Boolean (a logical operator, a
 * relational operator, or the constants @c true or @c false), @c 0
 * otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isBoolean (const ASTNode_t * node);


/**
 * Returns true if the given node is something that returns a Boolean value.
 *
 * This function looks at the whole ASTNode_t structure rather than just the
 * top level of @p node. Thus, it will consider return values from MathML @c
 * piecewise statements.  In addition, if the ASTNode_t structure in @p node
 * uses a function call, this function will examine the return value of the
 * function.  Note that this is only possible in cases the ASTNode_t
 * structure can trace its parent Model_t structure; that is, the ASTNode_t
 * structure must represent the <code>&lt;math&gt;</code> element of some
 * SBML object that has already been added to an instance of an
 * SBMLDocument_t structure.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node returns a boolean, @c 0 otherwise.
 *
 * @see ASTNode_isBoolean()
 * @see ASTNode_returnsBooleanForModel()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_returnsBoolean (const ASTNode_t *node);


/**
 * Returns true if the given node is something that returns a Boolean value.
 *
 * This function looks at the whole ASTNode_t structure rather than just the
 * top level of @p node. Thus, it will consider return values from MathML @c
 * piecewise statements.  In addition, if the ASTNode_t structure in @p node
 * uses a function call, this function will examine the return value of the
 * function using the definition of the function found in the given Model_t
 * structure given by @p model (rather than the model that might be traced
 * from @p node itself).  This function is similar to
 * ASTNode_returnsBoolean(), but is useful in situations where the ASTNode_t
 * structure has not been hooked into a model yet.
 *
 * @param node the node to query
 * @param model the model to use as the basis for finding the definition
 * of the function
 *
 * @return @c 1 if @p node returns a boolean, @c 0 otherwise.
 *
 * @see ASTNode_isBoolean()
 * @see ASTNode_returnsBoolean()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_returnsBooleanForModel (const ASTNode_t *node, const Model_t* model);


/**
 * Returns true if the given node represents a MathML constant.
 *
 * Examples of constants in this context are @c Pi, @c true, etc.
 *
 * @param node the node
 *
 * @return @c 1 if @p node is a MathML constant, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isConstant (const ASTNode_t * node);


/**
 * Returns true if the given node represents a function.
 *
 * @param node the node
 *
 * @return @c 1 if @p node is a function in SBML, whether predefined (in SBML
 * Level&nbsp;1), defined by MathML (SBML Levels&nbsp;2&ndash;3) or
 * user-defined.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isFunction (const ASTNode_t * node);


/**
 * Returns true if the given node stands for infinity.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is the special IEEE 754 value for infinity, @c 0
 * otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isInfinity (const ASTNode_t *node);


/**
 * Returns true if the given node contains an integer value.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type @sbmlconstant{AST_INTEGER, ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isInteger (const ASTNode_t *node);


/**
 * Returns true if the given node is a MathML lambda function.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isLambda (const ASTNode_t *node);


/**
 * Returns true if the given node represents the log base-10 function.
 *
 * More precisely, this function tests if the given @p node's type is @sbmlconstant{AST_FUNCTION_LOG, ASTNodeType_t} with two
 * children, the first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} equal to @c 10.
 *
 * @return @c 1 if @p node represents a log10() function, @c 0
 * otherwise.
 *
 * @see SBML_parseL3Formula()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isLog10 (const ASTNode_t *node);


/**
 * Returns true if the given node is a logical operator.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a MathML logical operator (@c and, @c or,
 * @c not, @c xor), @c 0otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isLogical (const ASTNode_t *node);


/**
 * Returns true if the given node is a named entity.
 *
 * More precisely, this returns a true value if @p node is a user-defined
 * variable name or the special symbols @c time or @c avogadro.

 * @param node the node to query
 *
 * @return @c 1 if @p node is a named variable, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isName (const ASTNode_t *node);


/**
 * Returns true if the given node represents not-a-number.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is the special IEEE 754 value NaN ("not a
 * number"), @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isNaN (const ASTNode_t *node);


/**
 * Returns true if the given node represents negative infinity.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is the special IEEE 754 value negative infinity,
 * @c 0 otherwise.
 *
 * @see ASTNode_isInfinity()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isNegInfinity (const ASTNode_t *node);


/**
 * Returns true if the given node contains a number.
 *
 * This is functionally equivalent to:
 * @verbatim
ASTNode_isInteger(node) || ASTNode_isReal(node).
@endverbatim
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a number, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isNumber (const ASTNode_t *node);


/**
 * Returns true if the given node is a mathematical operator.
 *
 * The possible mathematical operators are <code>+</code>, <code>-</code>,
 * <code>*</code>, <code>/</code> and <code>^</code> (power).
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is an operator, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isOperator (const ASTNode_t *node);


/**
 * Returns true if the given node represents the MathML
 * <code>&lt;piecewise&gt;</code> operator.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is the MathML piecewise function, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isPiecewise (const ASTNode_t *node);


/**
 * Returns true if the given node represents a rational number.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type @sbmlconstant{AST_RATIONAL, ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isRational (const ASTNode_t *node);


/**
 * Returns true if the given node represents a real number.
 *
 * More precisely, this node must be of one of the following types: @sbmlconstant{AST_REAL, ASTNodeType_t}, @sbmlconstant{AST_REAL_E, ASTNodeType_t} or @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
 *
 * @param node the node to query
 *
 * @return @c 1 if the value of @p node can represent a real number,
 * @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isReal (const ASTNode_t *node);


/**
 * Returns true if the given node represents a MathML relational operator.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a MathML relational operator, meaning
 * <code>==</code>, <code>&gt;=</code>, <code>&gt;</code>,
 * <code>&lt;</code>, and <code>!=</code>.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isRelational (const ASTNode_t *node);


/**
 * Returns true if the given node is the MathML square-root operator.
 *
 * More precisely, the node type must be @sbmlconstant{AST_FUNCTION_ROOT, ASTNodeType_t} with two
 * children, the first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} node having value equal to 2.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node represents a sqrt() function, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSqrt (const ASTNode_t *node);


/**
 * Returns true if the given node represents a unary minus.
 *
 * A node is defined as a unary minus node if it is of type @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
 *
 * For numbers, unary minus nodes can be "collapsed" by negating the number.
 * In fact, SBML_parseFormula() does this during its parsing process, and
 * SBML_parseL3Formula() has a configuration option that allows this behavior
 * to be turned on or off.  However, unary minus nodes for symbols (@sbmlconstant{AST_NAME, ASTNodeType_t}) cannot be "collapsed", so this
 * predicate function is still necessary.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a unary minus, @c 0 otherwise.
 *
 * @see SBML_parseL3Formula()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isUMinus (const ASTNode_t *node);


/**
 * Returns true if the given node is a unary plus.
 *
 * A node is defined as a unary minus node if it is of type @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a unary plus, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isUPlus (const ASTNode_t *node);


/**
 * Returns true if the given node is of a specific type and has a specific
 * number of children.
 *
 * This function is designed for use in cases such as when callers want to
 * determine if the node is a unary @c not or unary @c minus, or a @c times
 * node with no children, etc.
 *
 * @param node the node to query
 * @param type the type that the node should have
 * @param numchildren the number of children that the node should have.
 *
 * @return @c 1 if @p node is has the specified type and number of children,
 * @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_hasTypeAndNumChildren(const ASTNode_t *node, ASTNodeType_t type, unsigned int numchildren);


/**
 * Returns true if the type of the node is unknown.
 *
 * "Unknown" nodes have the type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  Nodes with unknown types will not appear in an
 * ASTNode tree returned by libSBML based upon valid SBML input; the only
 * situation in which a node with type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t} may appear is immediately after having create a new,
 * untyped node using the ASTNode_t constructor.  Callers creating nodes
 * should endeavor to set the type to a valid node type as soon as possible
 * after creating new nodes.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type @c AST_UNKNOWN, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isUnknown (const ASTNode_t *node);


/**
 * Returns true if the given node's MathML "id" attribute is set.
 *
 * @param node the node to query
 *
 * @return @c 1 if it is set, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetId (const ASTNode_t *node);


/**
 * Returns true if the given node's MathML "class" attribute is set.
 *
 * @param node the node to query
 *
 * @return @c 1 if the attribute is set, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetClass (const ASTNode_t *node);


/**
 * Returns true if the given node's MathML "style" attribute is set.
 *
 * @param node the node to query
 *
 * @return @c 1 if the attribute is set, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetStyle (const ASTNode_t *node);


/**
 * Returns true if this node's SBML "units" attribute is set.
 *
 * @htmlinclude about-sbml-units-attrib.html
 *
 * @param node the node to query
 *
 * @return @c 1 if the attribute is set, @c 0 otherwise.
 *
 * @note The <code>sbml:units</code> attribute is only available in SBML
 * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetUnits (const ASTNode_t *node);


/**
 * Returns true if the given node or any of its children have the SBML
 * "units" attribute set.
 *
 * @htmlinclude about-sbml-units-attrib.html
 *
 * @param node the node to query
 *
 * @return @c 1 if the attribute is set, @c 0 otherwise.
 *
 * @note The <code>sbml:units</code> attribute is only available in SBML
 * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
 *
 * @see ASTNode_isSetUnits()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_hasUnits (const ASTNode_t *node);


/**
 * Sets the value of a given node to a character.
 *
 * If character is one of @c +, @c -, <code>*</code>, <code>/</code> or @c ^,
 * the node type will be set accordingly.  For all other characters, the node
 * type will be set to @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.
 *
 * @param node the node to set
 * @param value the character value for the node.
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setCharacter (ASTNode_t *node, char value);


/**
 * Sets the node to represent a named entity.
 *
 * As a side-effect, this ASTNode object's type will be reset to @sbmlconstant{AST_NAME, ASTNodeType_t} if (and <em>only if</em>) the @p
 * node was previously an operator (i.e., ASTNode_isOperator() returns true),
 * number (i.e., ASTNode_isNumber() returns true), or unknown.  This allows
 * names to be set for @sbmlconstant{AST_FUNCTION, ASTNodeType_t}
 * nodes and the like.
 *
 * @param node the node to set
 * @param name the name value for the node
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setName (ASTNode_t *node, const char *name);


/**
 * Sets the given node to a integer and sets it type
 * to @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
 *
 * @param node the node to set
 * @param value the value to set it to
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setInteger (ASTNode_t *node, long value);


/**
 * Sets the value of a given node to a rational number and sets its type to
 * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
 *
 * @param node the node to set
 * @param numerator the numerator value to use
 * @param denominator the denominator value to use
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setRational (ASTNode_t *node, long numerator, long denominator);


/**
 * Sets the value of a given node to a real (@c double) and sets its type to
 * @sbmlconstant{AST_REAL, ASTNodeType_t}.
 *
 * This is functionally equivalent to:
 * @verbatim
ASTNode_setRealWithExponent(node, value, 0);
@endverbatim
 *
 * @param node the node to set
 * @param value the value to set the node to
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setReal (ASTNode_t *node, double value);


/**
 * Sets the value of a given node to a real (@c double) in two parts, a
 * mantissa and an exponent.
 *
 * As a side-effect, the @p node's type will be set to @sbmlconstant{AST_REAL, ASTNodeType_t}.
 *
 * @param node the node to set
 * @param mantissa the mantissa of this node's real-numbered value
 * @param exponent the exponent of this node's real-numbered value
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setRealWithExponent (ASTNode_t *node, double mantissa, long exponent);


/**
 * Explicitly sets the type of the given ASTNode_t structure.
 *
 * @param node the node to set
 * @param type the new type
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @note A side-effect of doing this is that any numerical values previously
 * stored in this node are reset to zero.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setType (ASTNode_t *node, ASTNodeType_t type);


/**
 * Sets the MathML "id" attribute of the given node.
 *
 * @param node the node to set
 * @param id the identifier to use
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setId (ASTNode_t *node, const char *id);


/**
 * Sets the MathML "class" of the given node.
 *
 * @param node the node to set
 * @param className the new value for the "class" attribute
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setClass (ASTNode_t *node, const char *className);


/**
 * Sets the MathML "style" of the given node.
 *
 * @param node the node to set
 * @param style the new value for the "style" attribute
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setStyle (ASTNode_t *node, const char *style);


/**
 * Sets the units of the given node.
 *
 * The units will be set @em only if the ASTNode_t object in @p node
 * represents a MathML <code>&lt;cn&gt;</code> element, i.e., represents a
 * number.  Callers may use ASTNode_isNumber() to inquire whether the node is
 * of that type.
 *
 *
 * @htmlinclude about-sbml-units-attrib.html
 *
 * @param node the node to modify
 * @param units the units to set it to.
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @note The <code>sbml:units</code> attribute is only available in SBML
 * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setUnits (ASTNode_t *node, const char *units);


/**
 * Swaps the children of two nodes.
 *
 * @param node the node to modify
 *
 * @param that the other node whose children should be used to replace those
 * of @p node
 *
 * @return integer value indicating success/failure of the function.  The
 * possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_swapChildren (ASTNode_t *node, ASTNode_t *that);


/**
 * Unsets the MathML "id" attribute of the given node.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetId (ASTNode_t *node);


/**
 * Unsets the MathML "class" attribute of the given node.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetClass (ASTNode_t *node);


/**
 * Unsets the MathML "style" attribute of the given node.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetStyle (ASTNode_t *node);


/**
 * Unsets the units associated with the given node.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetUnits (ASTNode_t *node);


/**
 * Replaces occurrences of a given name with a new ASTNode_t structure.
 *
 * For example, if the formula in @p node is <code>x + y</code>, then the
 * <code>&lt;bvar&gt;</code> is @c x and @c arg is an ASTNode_t structure
 * representing the real value @c 3.  This function substitutes @c 3 for @c x
 * within the @p node ASTNode_t structure.
 *
 * @param node the node to modify
 * @param bvar the MathML <code>&lt;bvar&gt;</code> to use
 * @param arg the replacement node or structure
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void
ASTNode_replaceArgument(ASTNode_t* node, const char * bvar, ASTNode_t* arg);


/**
 * Reduces the given node to a binary true.
 *
 * Example: if @p node is <code>and(x, y, z)</code>, then the formula of the
 * reduced node is <code>and(and(x, y), z)</code>.  The operation replaces
 * the formula stored in the current ASTNode_t structure.
 *
 * @param node the node to modify
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void
ASTNode_reduceToBinary(ASTNode_t* node);


/**
 * Returns the parent SBML structure containing the given node.
 *
 * @param node the node to query
 *
 * @return a pointer to the object structure containing the given node.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
SBase_t *
ASTNode_getParentSBMLObject(ASTNode_t* node);


/**
 * Returns true if the given node's parent SBML object is set.
 *
 * @param node the node to query
 *
 * @return @c 1 if the parent SBML object is set, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetParentSBMLObject(ASTNode_t* node);


/** @cond doxygenLibsbmlInternal */
/**
 * @param node the node to modify
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void 
ASTNode_setParentSBMLObject(ASTNode_t* node, SBase_t * sb);
/**
 * Unsets the parent SBase_t structure.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetParentSBMLObject(ASTNode_t* node);


/** @endcond */


/**
 * Adds a given XML node structure as a MathML <em>semantic annotation</em>
 * of a given ASTNode_t structure.
 *
 * @htmlinclude about-semantic-annotations.html
 *
 * @param node the node to modify
 * @param annotation the annotation to add
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @note Although SBML permits the semantic annotation construct in
 * MathML expressions, the truth is that this construct has so far (at
 * this time of this writing, which is early 2011) seen very little use
 * in SBML software.  The full implications of using semantic annotations
 * are still poorly understood.  If you wish to use this construct, we
 * urge you to discuss possible uses and applications on the SBML
 * discussion lists, particularly <a target="_blank"
 * href="http://sbml.org/Forums">sbml-discuss&#64;caltech.edu</a> and/or <a
 * target="_blank"
 * href="http://sbml.org/Forums">sbml-interoperability&#64;caltech.edu</a>.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_addSemanticsAnnotation(ASTNode_t* node, XMLNode_t * annotation);


/**
 * Returns the number of MathML semantic annotations inside the given node.
 *
 * @htmlinclude about-semantic-annotations.html
 *
 * @param node the node to query
 *
 * @return a count of the semantic annotations.
 *
 * @see ASTNode_addSemanticsAnnotation()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
unsigned int
ASTNode_getNumSemanticsAnnotations(ASTNode_t* node);


/**
 * Returns the nth MathML semantic annotation attached to the given node.
 *
 * @htmlinclude about-semantic-annotations.html
 *
 * @param node the node to query
 * @param n the index of the semantic annotation to fetch
 *
 * @return the nth semantic annotation on @p node , or a null pointer if the
 * node has no nth annotation (which would mean that <code>n &gt;
 * ASTNode_getNumSemanticsAnnotations(node) - 1</code>).
 *
 * @see ASTNode_addSemanticsAnnotation()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
XMLNode_t *
ASTNode_getSemanticsAnnotation(ASTNode_t* node, unsigned int n);


/**
 * Sets the user data of the given node.
 *
 * The user data can be used by the application developer to attach custom
 * information to the node. In case of a deep copy, this attribute will
 * passed as it is. The attribute will be never interpreted by this class.
 *
 * @param node the node to modify
 * @param userData the new user data
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @see ASTNode_getUserData()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setUserData(ASTNode_t* node, void *userData);


/**
 * Returns the user data associated with this node.
 *
 * @param node the node to query
 *
 * @return the user data of this node, or a null pointer if no user data has
 * been set.
 *
 * @see ASTNode_setUserData()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
void *
ASTNode_getUserData(ASTNode_t* node);


/**
 * Unsets the user data of the given node.
 *
 * The user data can be used by the application developer to attach custom
 * information to the node. In case of a deep copy, this attribute will
 * passed as it is. The attribute will be never interpreted by this class.
 *
 * @param node the node to modify
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @see ASTNode_getUserData()
 * @see ASTNode_setUserData()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetUserData(ASTNode_t* node);


/**
 * Returns true if the given node's user data object is set.
 *
 * @param node the node to query
 *
 * @return @c 1 if the user data object is set, @c 0 otherwise.
 *
 * @see ASTNode_setUserData()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSetUserData(ASTNode_t* node);


/**
 * Returns true if the given node has the correct number of children for its
 * type.
 *
 * For example, an ASTNode_t structure with type @sbmlconstant{AST_PLUS, ASTNodeType_t} expects 2 child nodes.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node has the appropriate number of children for its
 * type, @c 0 otherwise.
 *
 * @note This function performs a check on the top-level node only.  Child
 * nodes are not checked.
 *
 * @see ASTNode_isWellFormedASTNode()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_hasCorrectNumberArguments(ASTNode_t* node);


/**
 * Returns true if the given node is well-formed.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is well-formed, @c 0 otherwise.
 *
 * @note An ASTNode may be well-formed, with each node and its children
 * having the appropriate number of children for the given type, but may
 * still be invalid in the context of its use within an SBML model.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isWellFormedASTNode(ASTNode_t* node);


/**
 * Returns the MathML "definitionURL" attribute value of the given node.
 *
 * @param node the node to query
 *
 * @return the value of the "definitionURL" attribute in the form of a
 * libSBML XMLAttributes_t structure, or a null pointer if @p node does not
 * have a value for the attribute.
 *
 * @see ASTNode_getDefinitionURLString()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
XMLAttributes_t * 
ASTNode_getDefinitionURL(ASTNode_t* node);


/**
 * Returns the MathML "definitionURL" attribute value of the given node as a
 * string.
 *
 * @param node the node to query
 *
 * @return the value of the "definitionURL" attribute in the form of a
 * string, or a null pointer if @p node does not have a value for the
 * attribute.
 *
 * @see ASTNode_getDefinitionURL()
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
char *
ASTNode_getDefinitionURLString(ASTNode_t* node);


/**
 * Sets the MathML "definitionURL" attribute of the given node.
 *
 * @param node the node to modify
 * @param defnURL the value to which the attribute should be set
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int 
ASTNode_setDefinitionURL(ASTNode_t* node, XMLAttributes_t * defnURL);


/**
 * Sets the MathML "definitionURL" attribute of the given node.
 *
 * @param node the node to modify
 * @param defnURL a string to which the attribute should be set
 *
 * @return integer value indicating success/failure of the
 * function.  The possible values returned by this function are:
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int 
ASTNode_setDefinitionURLString(ASTNode_t* node, const char * defnURL);


/** @cond doxygenLibsbmlInternal */
/**
 * 
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_true(const ASTNode_t *node);
/** @endcond */


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* ASTNode_h */

