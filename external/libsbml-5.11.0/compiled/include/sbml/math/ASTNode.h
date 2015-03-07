/**
 * @file    ASTNode.h
 * @brief   Abstract Syntax Tree (AST) for representing formula trees.
 * @author  Sarah Keating
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
 * @sbmlbrief{core} Abstract Syntax Trees for mathematical expressions.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * <a target="_blank"
 * href="http://en.wikipedia.org/wiki/Abstract_syntax_tree">Abstract Syntax
 * Trees</a> (ASTs) are a simple kind of data structure used in libSBML for
 * storing mathematical expressions.  LibSBML ASTs provide a canonical,
 * in-memory representation for all mathematical formulas regardless of their
 * original format (which might be MathML or might be text strings).
 *
 * @copydetails doc_what_is_astnode
 *
 * @if clike <h3><a class="anchor" name="ASTNodeType_t">
 * ASTNodeType_t</a></h3> @else <h3><a class="anchor"
 * name="ASTNodeType_t">The set of possible %ASTNode types</a></h3> @endif@~
 *
 * @copydetails doc_astnode_types
 *
 * <h3><a class="anchor" name="math-convert">Converting between ASTs and text
 * strings</a></h3>
 *
 * The text-string form of mathematical formulas produced by
 * @sbmlfunction{formulaToString, String} and
 * @sbmlfunction{formulaToL3String, String}, and read by
 * @sbmlfunction{parseFormula, ASTNode} and
 * @sbmlfunction{parseL3Formula, ASTNode}, are in a simple C-inspired
 * infix notation.  A formula in one of these two text-string formats can be
 * handed to a program that understands SBML mathematical expressions, or
 * used as part of a translation system.  The libSBML distribution comes with
 * example programs in the @c "examples" subdirectory that demonstrate such
 * things as translating infix formulas into MathML and vice-versa.
 *
 * Please see the documentation for the functions @sbmlfunction{parseFormula,
 * ASTNode} and @sbmlfunction{parseL3Formula, ASTNode} for detailed
 * explanations of the infix syntax they accept.
 *
 * <h3><a class="anchor" name="math-history">Historical notes</a></h3>
 *
 * Readers may wonder why this part of libSBML uses a seemingly less
 * object-oriented design than other parts.  Originally, much of libSBML was
 * written in&nbsp;C.  All subsequent development was done in C++, but the
 * complexity of some of the functionality for converting between infix, AST
 * and MathML, coupled with the desire to maintain stability and backward
 * compatibility, means that some of the underlying code is still written
 * in&nbsp;C.  This has lead to the exposed API being more C-like.

 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * @see @sbmlfunction{formulaToL3String, ASTNode}
 * @see @sbmlfunction{formulaToString, ASTNode}
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
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
 * formulas.  The method
 * @if conly ASTNode_isWellFormedASTNode()@else ASTNode::isWellFormedASTNode()@endif@~
 * may also be useful for checking the results of node modifications.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_about_mathml_semantic_annotations
 *
 * The <code>&lt;semantics&gt;</code> element is a MathML&nbsp;2.0 construct
 * that can be used to associate additional information with a MathML
 * construct.  The construct can be used to decorate a MathML expressions with
 * a sequence of one or more <code>&lt;annotation&gt;</code> or
 * <code>&lt;annotation-xml&gt;</code> elements.  Each such element contains a
 * pair of items; the first is a symbol that acts as an attribute or key, and
 * the second is the value associated with the attribute or key.  Please refer
 * to the MathML&nbsp;2.0 documentation, particularly the <a target="_blank"
 * href="http://www.w3.org/TR/2007/WD-MathML3-20071005/chapter5.html#mixing.semantic.annotations">Section
 * 5.2, Semantic Annotations</a> for more information about these constructs.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_mathml_semantic_annotations_uncommon
 *
 * @note Although SBML permits the use of the MathML
 * <code>&lt;semantics&gt;</code> annotation construct, the truth is that
 * this construct has so far (at this time of this writing, which is early
 * 2014) seen very little use in SBML software.  The full implications of
 * using these annotations are still poorly understood.  If you wish to
 * use this construct, we urge you to discuss possible uses and applications
 * on the SBML discussion lists, particularly <a target="_blank"
 * href="http://sbml.org/Forums">sbml-discuss</a> and/or <a target="_blank"
 * href="http://sbml.org/Forums">sbml-interoperability</a>.
 */

#ifndef ASTNode_h
#define ASTNode_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/math/FormulaTokenizer.h>

#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTTypes.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @typedef ASTNodePredicate
 * @brief Function signature for use with
 * @if conly ASTNode_fillListOfNodes() @else ASTNode::fillListOfNodes() @endif
 * and @if conly ASTNode_getListOfNodes() @else ASTNode::getListOfNodes() @endif.
 *
 * A pointer to a function that takes an ASTNode and returns @if conly @c 1
 * (true) or @c 0 (false) @else @c true (nonzero) or @c false (0)@endif.
 *
 * @if conly @see ASTNode_getListOfNodes()@else @see ASTNode::getListOfNodes()@endif
 * @if conly @see ASTNode_fillListOfNodes()@else @see ASTNode::fillListOfNodes()@endif
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
typedef int (*ASTNodePredicate) (const ASTNode_t *node);


LIBSBML_CPP_NAMESPACE_END

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ASTNode : public ASTBase
{
public:

  /**
   * Creates a new ASTNode.
   *
   * Unless the argument @p type is given, the returned node will by default
   * have a type of @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  If the type
   * isn't supplied when caling this constructor, the caller should set the
   * node type to something else as soon as possible using
   * @if clike setType()@else ASTNode::setType(int)@endif.
   *
   * @param type an optional
   * @if clike #ASTNodeType_t@else integer type@endif@~
   * code indicating the type of node to create.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ASTNode (ASTNodeType_t type);


  /** @cond doxygenLibsbmlInternal */

  /* constructor for use by mathml reader */
  ASTNode(SBMLNamespaces* sbmlns, ASTNodeType_t type);

  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  /*
   * Creates and returns a new ASTNode.
   */
  ASTNode (int type = AST_UNKNOWN);

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /* constructor for use by mathml reader */
  ASTNode(SBMLNamespaces* sbmlns, int type = AST_UNKNOWN);

  /** @endcond */

  /**
   * Creates a new ASTNode from the given Token.
   *
   * The resulting ASTNode will contain the same data as the given @p token.
   *
   * @param token the token to use as a starting point for creating the
   * ASTNode object.
   */
  ASTNode (Token_t *token);


  /**
   * Copy constructor; creates a deep copy of the given ASTNode.
   *
   * @param orig the ASTNode to be copied.
   */
  ASTNode (const ASTNode& orig);


  /**
   * Assignment operator for ASTNode.
   */
  ASTNode& operator=(const ASTNode& rhs);


  /**
   * Destroys this ASTNode, including any child nodes.
   */
  virtual ~ASTNode ();


  /**
   * Frees the name of this ASTNode and sets it to @c NULL.
   *
   * This operation is only applicable to ASTNode objects corresponding to
   * operators, numbers, or @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  This
   * method has no effect on other types of nodes.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  int freeName ();


  /**
   * Converts this ASTNode to a canonical form.
   *
   * The rules determining the canonical form conversion are as follows:
   *
   * @li If the node type is @sbmlconstant{AST_NAME, ASTNodeType_t}
   * and the node name matches @c "ExponentialE", @c "Pi", @c "True" or @c
   * "False" the node type is converted to the corresponding
   * <code>AST_CONSTANT_</code><em><span class="placeholder">X</span></em> type.
   * @li If the node type is an @sbmlconstant{AST_FUNCTION, ASTNodeType_t} and
   * the node name matches an SBML (MathML) function name, logical operator name,
   * or relational operator name, the node is converted to the corresponding
   * <code>AST_FUNCTION_</code><em><span class="placeholder">X</span></em> or
   * <code>AST_LOGICAL_</code><em><span class="placeholder">X</span></em> type.
   *
   * SBML Level&nbsp;1 function names are searched first; thus, for example,
   * canonicalizing @c log will result in a node type of
   * @sbmlconstant{AST_FUNCTION_LN, ASTNodeType_t}.  (See the SBML
   * Level&nbsp;1 Version&nbsp;2 Specification, Appendix C.)
   *
   * Sometimes, canonicalization of a node results in a structural conversion
   * of the node as a result of adding a child.  For example, a node with the
   * SBML Level&nbsp;1 function name @c sqr and a single child node (the
   * argument) will be transformed to a node of type
   * @sbmlconstant{AST_FUNCTION_POWER, ASTNodeType_t} with two children.  The
   * first child will remain unchanged, but the second child will be an
   * ASTNode of type @sbmlconstant{AST_INTEGER, ASTNodeType_t} and a value of
   * 2.  The function names that result in structural changes are: @c log10,
   * @c sqr, and @c sqrt.
   *
   * @return @c true if this node was successfully converted to
   * canonical form, @c false otherwise.
   */
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
  int addChild (ASTNode* child);


  /**
   * Adds the given node as a child of this ASTNode.
   *
   * This method adds child nodes from right to left.
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
  int removeChild(unsigned int n);


  /**
   * Replaces the nth child of this ASTNode with the given ASTNode.
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
  int replaceChild(unsigned int n, ASTNode *newChild, bool delreplaced=false);


  /**
   * Inserts the given ASTNode node at a given point in the current ASTNode's
   * list of children.
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
  int insertChild(unsigned int n, ASTNode *newChild);


  /**
   * Creates a recursive copy of this node and all its children.
   *
   * @return a copy of this ASTNode and all its children.  The caller owns
   * the returned ASTNode and is responsible for deleting it.
   */
  ASTNode* deepCopy () const;


  /**
   * Returns the child at index n of this node.
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
  virtual ASTNode* getChild (unsigned int n) const;


  /**
   * Returns the left child of this node.
   *
   * @return the left child of this ASTNode.  This is equivalent to calling
   * @if clike getChild()@else ASTNode::getChild(unsigned int)@endif@~
   * with an argument of @c 0.
   *
   * @see getNumChildren()
   * @see getChild(@if java unsigned int@endif)
   * @see getRightChild()
   */
  ASTNode* getLeftChild () const;


  /**
   * Returns the right child of this node.
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
   * @see getChild(@if java unsigned int@endif)
   */
  ASTNode* getRightChild () const;


  /**
   * Returns the number of children of this node.
   *
   * @return the number of children of this ASTNode, or 0 is this node has
   * no children.
   */
  unsigned int getNumChildren () const;


  /**
   * Adds the given XMLNode as a MathML <code>&lt;semantics&gt;</code>
   * element to this ASTNode.
   *
   * @copydetails doc_about_mathml_semantic_annotations
   *
   * @param sAnnotation the annotation to add.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_mathml_semantic_annotations_uncommon
   *
   * @see ASTNode::getNumSemanticsAnnotations()
   * @see ASTNode::getSemanticsAnnotation(@if java unsigned int@endif)
   */
  int addSemanticsAnnotation (XMLNode* sAnnotation);


  /**
   * Returns the number of MathML <code>&lt;semantics&gt;</code> element
   * elements on this node.
   *
   * @copydetails doc_about_mathml_semantic_annotations
   *
   * @return the number of annotations of this ASTNode.
   *
   * @copydetails doc_note_mathml_semantic_annotations_uncommon
   *
   * @see ASTNode::addSemanticsAnnotation(@if java XMLNode@endif)
   * @see ASTNode::getSemanticsAnnotation(@if java unsigned int@endif)
   */
  unsigned int getNumSemanticsAnnotations () const;


  /**
   * Returns the nth MathML <code>&lt;semantics&gt;</code> element on this
   * ASTNode.
   *
   * @copydetails doc_about_mathml_semantic_annotations
   *
   * @param n the index of the annotation to return.  Callers should
   * use ASTNode::getNumSemanticsAnnotations() to first find out how
   * many annotations there are.
   *
   * @return the nth annotation inside this ASTNode, or @c NULL if this node has
   * no nth annotation (<code>n &gt;</code>
   * @if clike getNumSemanticsAnnotations()@else ASTNode::getNumSemanticsAnnotations()@endif@~
   * <code>- 1</code>).
   *
   * @copydetails doc_note_mathml_semantic_annotations_uncommon
   *
   * @see ASTNode::addSemanticsAnnotation(@if java XMLNode@endif)
   * @see ASTNode::getNumSemanticsAnnotations()
   */
  XMLNode* getSemanticsAnnotation (unsigned int n) const;


  /**
   * Returns a list of nodes satisfying a given predicate.
   *
   * This performs a depth-first search of the tree rooted at this ASTNode
   * object, and returns a List of nodes for which the given function
   * <code>predicate(node)</code> returns @c true.  For portability between
   * different programming languages, the predicate is passed in as a pointer
   * to a function.  @if clike The function definition must have the type
   * @link ASTNode.h::ASTNodePredicate ASTNodePredicate@endlink, which is defined as
   * @code{.cpp}
int (*ASTNodePredicate) (const ASTNode *node);
@endcode
   * where a return value of nonzero represents @c true and zero
   * represents @c false. @endif
   *
   * @param predicate the predicate to use
   *
   * @return the list of nodes for which the predicate returned @c true.
   * The List returned is owned by the caller and should be
   * deleted after the caller is done using it.  The ASTNode objects in the
   * list; however, are not owned by the caller (as they still belong to
   * the tree itself), and therefore should not be deleted.
   *
   * @see ASTNode::fillListOfNodes(@if java ASTNodePredicate, List@endif)
   */
  List* getListOfNodes (ASTNodePredicate predicate) const;


  /**
   * Returns a list of nodes rooted at a given node and satisfying a given
   * predicate.
   *
   * This method is identical to calling
   * ASTNode::getListOfNodes(@if java ASTNodePredicate@endif), except
   * that instead of creating a new List object, it uses the one passed in as
   * argument @p lst.  This method a depth-first search of the tree rooted at
   * this ASTNode object, and adds to the list @p lst the nodes for which the
   * given function <code>predicate(node)</code> returns @c true.
   *
   * For portability between different programming languages, the predicate
   * is passed in as a pointer to a function.  The function definition must
   * have the type @link ASTNode.h::ASTNodePredicate
   * ASTNodePredicate@endlink, which is defined as
   * @code{.cpp}
int (*ASTNodePredicate) (const ASTNode_t *node);
@endcode
   * where a return value of nonzero represents @c true and zero
   * represents @c false.
   *
   * @param predicate the predicate to use.
   *
   * @param lst the List to which ASTNode objects should be added.
   *
   * @see getListOfNodes(@if java ASTNodePredicate@endif)
   */
  void fillListOfNodes (ASTNodePredicate predicate, List* lst) const;


  /**
   * Returns the value of this node as a single character.
   *
   * This function should be called only when ASTNode::getType() returns
   * @sbmlconstant{AST_MINUS, ASTNodeType_t}, @sbmlconstant{AST_TIMES,
   * ASTNodeType_t}, @sbmlconstant{AST_DIVIDE, ASTNodeType_t} or
   * @sbmlconstant{AST_POWER, ASTNodeType_t}.
   *
   * @return the value of this ASTNode as a single character
   */
  char getCharacter () const;


  /**
   * Returns the MathML @c id attribute value of this ASTNode.
   *
   * @return the MathML id of this ASTNode.
   *
   * @see isSetId()
   * @see setId(@if java const std::string& id@endif)
   * @see unsetId()
   */
  std::string getId () const;


  /**
   * Returns the MathML @c class attribute value of this ASTNode.
   *
   * @return the MathML class of this ASTNode, if any exists.
   *
   * @see isSetClass()
   * @see @if java setClassName(const std::string& id)@else setClass()@endif@~
   * @see unsetClass()
   */
  std::string getClass () const;


  /**
   * Returns the MathML @c style attribute value of this ASTNode.
   *
   * @return the MathML style of this ASTNode, if any exists.
   *
   * @see isSetStyle()
   * @see setStyle(@if java const std::string& id@endif)
   * @see unsetStyle()
   */
  std::string getStyle () const;


  /**
   * Returns the value of this node as an integer.
   *
   * If this node type is @sbmlconstant{AST_RATIONAL, ASTNodeType_t}, this
   * method returns the value of the numerator.
   *
   * @return the value of this ASTNode as a (<code>long</code>) integer.
   *
   * @note This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_INTEGER, ASTNodeType_t} or
   * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   * It will return @c 0 if the node type is @em not one of these, but since
   * @c 0 may be a valid value for integer, it is important to be sure that
   * the node type is one of the expected types in order to understand if @c
   * 0 is the actual value.
   */
  long getInteger () const;


  /**
   * Returns the value of this node as a string.
   *
   * This function may be called on nodes that (1) are not operators, i.e.,
   * nodes for which @if clike isOperator()@else ASTNode::isOperator()@endif@~
   * returns @c false, and (2) are not numbers, i.e.,
   * @if clike isNumber()@else ASTNode::isNumber()@endif@~ returns @c false.
   *
   * @return the value of this ASTNode as a string, or @c NULL if it is
   * a node that does not have a name equivalent (e.g., if it is a number).
   */
  const char* getName () const;


  /**
   * Returns the value of this operator node as a string.
   *
   * This function may be called on nodes that are operators, i.e., nodes for
   * which @if clike isOperator()@else ASTNode::isOperator()@endif@~ returns
   * @c true.
   *
   * @return the name of this operator ASTNode as a string (or @c NULL if not
   * an operator).
   */
  const char* getOperatorName () const;


  /**
   * Returns the value of the numerator of this node.
   *
   * This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_RATIONAL, ASTNodeType_t} or
   * @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
   *
   * @return the value of the numerator of this ASTNode.
   */
  long getNumerator () const;


  /**
   * Returns the value of the denominator of this node.
   *
   * @return the value of the denominator of this ASTNode, or @c 1 if
   * this node has no numerical value.
   *
   * @note This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   * It will return @c 1 if the node type is another type, but since @c 1 may
   * be a valid value for the denominator of a rational number, it is
   * important to be sure that the node type is the correct type in order to
   * correctly interpret the returned value.
   */
  long getDenominator () const;


  /**
   * Returns the real-numbered value of this node.
   *
   * This function performs the necessary arithmetic if the node type is
   * @sbmlconstant{AST_REAL_E, ASTNodeType_t} (<em>mantissa *
   * 10<sup> exponent</sup></em>) or
   * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}
   * (<em>numerator / denominator</em>).
   *
   * @return the value of this ASTNode as a real (double), or @c 0
   * if this is not a node that holds a number.
   *
   * @note This function should be called only when this ASTNode has a
   * numerical value type.  It will return @c 0 if the node type is another
   * type, but since @c 0 may be a valid value, it is important to be sure
   * that the node type is the correct type in order to correctly interpret
   * the returned value.
   */
  double getReal () const;


  /**
   * Returns the mantissa value of this node.
   *
   * If @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_REAL, ASTNodeType_t}, this method is
   * identical to ASTNode::getReal().
   *
   * @return the value of the mantissa of this ASTNode, or @c 0 if this
   * node is not a type that has a real-numbered value.
   *
   * @note This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~ returns
   * @sbmlconstant{AST_REAL_E, ASTNodeType_t},
   * @sbmlconstant{AST_REAL, ASTNodeType_t} or
   * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t}.  It
   * will return @c 0 if the node type is another type, but since @c 0 may be
   * a valid value, it is important to be sure that the node type is the
   * correct type in order to correctly interpret the returned value.
   */
  double getMantissa () const;


  /**
   * Returns the exponent value of this ASTNode.
   *
   * @return the value of the exponent of this ASTNode, or @c 0 if this
   * is not a type of node that has an exponent.
   *
   * @note This function should be called only when
   * @if clike getType()@else ASTNode::getType()@endif@~
   * returns @sbmlconstant{AST_REAL_E, ASTNodeType_t}.
   * It will return @c 0 if the node type is another type, but since @c 0 may
   * be a valid value, it is important to be sure that the node type is the
   * correct type in order to correctly interpret the returned value.
   */
  long getExponent () const;


  /**
   * Returns the precedence of this node in the infix math syntax of SBML
   * Level&nbsp;1.
   *
   * For more information about the infix syntax, see the discussion about <a
   * href="#math-convert">text string formulas</a> at the top of the
   * documentation for ASTNode.
   *
   * @return an integer indicating the precedence of this ASTNode
   */
  int getPrecedence () const;


  /**
   * Returns the type of this ASTNode.
   *
   * The value returned is one of the Core AST type codes such as
   * @sbmlconstant{AST_LAMBDA, ASTNodeType_t},
   * @sbmlconstant{AST_PLUS, ASTNodeType_t}, etc.
   *
   * @return the type of this ASTNode.
   *
   * @note The introduction of extensibility in SBML Level&nbsp;3 brings with
   * it a need to allow for the possibility of node types that are defined by
   * plug-ins implementing SBML Level&nbsp;3 packages.  If a given ASTNode is
   * a construct created by a package rather than libSBML Core, then
   * getType() will return
   * @sbmlconstant{AST_ORIGINATES_IN_PACKAGE, ASTNodeType_t}.
   * Callers can then obtain the package-specific type by
   * calling getExtendedType().
   *
   * @see getExtendedType()
   */
  ASTNodeType_t getType () const;


  /**
   * Returns the extended type of this ASTNode.
   *
   * The type may be either a core
   * @ifnot clike integer type code@else #ASTNodeType_t value@endif
   * or a value of a type code defined by an SBML Level&nbsp;3 package.
   *
   * @return the type of this ASTNode.
   *
   * @note When the ASTNode is of a type from a package, the value returned
   * by ASTNode::getType() will be
   * @sbmlconstant{AST_ORIGINATES_IN_PACKAGE, ASTNodeType_t}
   * and getExtendedType() will return a package-specific type
   * code.  To find out the possible package-specific types (if any), please
   * consult the documentation for the particular package.
   *
   * @see getType()
   */
  virtual int getExtendedType() const;


  /**
   * Returns the units of this ASTNode.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @return the units of this ASTNode.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   *
   * @see @sbmlfunction{parseL3Formula, String}
   */
  std::string getUnits () const;


  /**
   * Returns @c true if this node represents the predefined
   * value for Avogadro's constant.
   *
   * SBML Level&nbsp;3 introduced a predefined MathML <code>&lt;csymbol&gt;</code>
   * for the value of Avogadro's constant.  LibSBML stores this internally as
   * a node of type @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t}.
   * This method returns @c true if this node has that type.
   *
   * @return @c true if this ASTNode is the special symbol avogadro,
   * @c false otherwise.
   *
   * @see @sbmlfunction{parseL3Formula, String}
   */
  virtual bool isAvogadro () const;


  /**
   * Returns @c true if this node has a Boolean type.
   *
   * The ASTNode objects that have Boolean types are the logical operators,
   * relational operators, and the constants @c true or @c false.
   *
   * @return @c true if this ASTNode has a Boolean type, @c false otherwise.
   */
  virtual bool isBoolean () const;


  /**
   * Returns @c true if this node returns a Boolean value.
   *
   * This function looks at the whole ASTNode rather than just the top level
   * of the ASTNode. Thus, it will consider return values from piecewise
   * statements.  In addition, if this ASTNode uses a function call to a
   * user-defined function, the return value of the corresponding
   * FunctionDefinition object will be determined.  Note that this is only
   * possible where the ASTNode can trace its parent Model; that is, the
   * ASTNode must represent the <code>&lt;math&gt;</code> element of some
   * SBML object that has already been added to an instance of an
   * SBMLDocument.
   *
   * @param model the Model to use as context
   *
   * @see isBoolean()
   *
   * @return true if this ASTNode returns a boolean, @c false otherwise.
   */
  bool returnsBoolean (const Model* model=NULL) const;


  /**
   * Returns @c true if this node represents a MathML
   * constant.
   *
   * Examples of MathML constants include such things as pi.
   *
   * @return @c true if this ASTNode is a MathML constant, @c false
   * otherwise.
   *
   * @note This function will also return @c true for nodes of type
   * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t} in SBML Level&nbsp;3.
   */
  virtual bool isConstant () const;


  /**
   * Returns @c true if this node represents a function.
   *
   * The three types of functions in SBML are MathML functions (e.g.,
   * <code>abs()</code>), SBML Level&nbsp;1 functions (in the SBML
   * Level&nbsp;1 math syntax), and user-defined functions (using
   * FunctionDefinition in SBML Level&nbsp;2 and&nbsp;3).
   *
   * @return @c true if this ASTNode is a function, @c false otherwise.
   */
  virtual bool isFunction () const;


  /**
   * Returns @c true if this node represents the special IEEE 754
   * value for infinity.
   *
   * @return @c true if this ASTNode is the special IEEE 754 value infinity,
   * @c false otherwise.
   */
  bool isInfinity () const;


  /**
   * Returns @c true if this node contains an integer value.
   *
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_INTEGER,
   * ASTNodeType_t}, @c false otherwise.
   */
  virtual bool isInteger () const;


  /**
   * Returns @c true if this node is a MathML
   * <code>&lt;lambda&gt;</code>.
   *
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_LAMBDA,
   * ASTNodeType_t}, @c false otherwise.
   */
  virtual bool isLambda () const;


  /**
   * Returns @c true if this node represents a @c log10 function.
   *
   * More precisely, this predicate returns @c true if the node type is
   * @sbmlconstant{AST_FUNCTION_LOG, ASTNodeType_t} with two children, the
   * first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} equal to
   * 10.
   *
   * @return @c true if the given ASTNode represents a @c log10() function, @c
   * false otherwise.
   *
   * @see @sbmlfunction{parseL3Formula, String}
   */
  virtual bool isLog10 () const;


  /**
   * Returns @c true if this node is a MathML logical operator.
   *
   * The possible MathML logical operators are @c and, @c or, @c not, and @c
   * xor.
   *
   * @return @c true if this ASTNode is a MathML logical operator, @c false
   * otherwise.
   */
  virtual bool isLogical () const;


  /**
   * Returns @c true if this node is a user-defined variable name
   * or the symbols for time or Avogadro's constant.
   *
   * SBML Levels&nbsp;2 and&nbsp;3 provides <code>&lt;csymbol&gt;</code>
   * definitions for "time" and "avogadro", which can be used to represent
   * simulation time and Avogadro's constant in MathML.
   *
   * @return @c true if this ASTNode is a user-defined variable name in SBML
   * or the special symbols for time or Avogadro's constant. It returns @c
   * false otherwise.
   */
  virtual bool isName () const;


  /**
   * Returns @c true if this node represents the special IEEE 754
   * value "not a number" (NaN).
   *
   * @return @c true if this ASTNode is the special IEEE 754 NaN, @c false
   * otherwise.
   */
  bool isNaN () const;


  /**
   * Returns @c true if this node represents the special IEEE 754
   * value "negative infinity".
   *
   * @return @c true if this ASTNode is the special IEEE 754 value negative
   * infinity, @c false otherwise.
   */
  bool isNegInfinity () const;


  /**
   * Returns @c true if this node contains a number.
   *
   * @return @c true if this ASTNode is a number, @c false otherwise.
   */
  virtual bool isNumber () const;


  /**
   * Returns @c true if this node is a mathematical
   * operator.
   *
   * The possible mathematical operators in the MathML syntax supported by
   * SBML are <code>+</code>, <code>-</code>, <code>*</code>, <code>/</code>
   * and <code>^</code> (power).
   *
   * @return @c true if this ASTNode is an operator, @c false otherwise.
   */
  virtual bool isOperator () const;


  /**
   * Returns @c true if this node is the MathML
   * <code>&lt;piecewise&gt;</code> construct.
   *
   * @return @c true if this ASTNode is a MathML @c piecewise function,
   * @c false otherwise.
   */
  virtual bool isPiecewise () const;


  /**
   * Predicate returning @c true if this node is a MathML
   * qualifier.
   *
   * The MathML qualifier node types are @c bvar, @c degree, @c base, @c
   * piece, and @c otherwise.
   *
   * @return @c true if this ASTNode is a MathML qualifier, @c false
   * otherwise.
   */
  virtual bool isQualifier() const;


  /**
   * Returns @c true if this node represents a rational number.
   *
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_RATIONAL,
   * ASTNodeType_t}, @c false otherwise.
   */
  virtual bool isRational () const;


  /**
   * Returns @c true if this node can represent a real number.
   *
   * More precisely, this node must be of one of the following types:
   * @sbmlconstant{AST_REAL, ASTNodeType_t}, @sbmlconstant{AST_REAL_E,
   * ASTNodeType_t} or @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   *
   * @return @c true if the value of this ASTNode can represented as a real
   * number, @c false otherwise.
   */
  virtual bool isReal () const;


  /**
   * Returns @c true if this node is a MathML
   * relational operator.
   *
   * The MathML relational operators are <code>==</code>, <code>&gt;=</code>,
   * <code>&gt;</code>, <code>&lt;</code>, and <code>!=</code>.
   *
   * @return @c true if this ASTNode is a MathML relational operator, @c
   * false otherwise.
   */
  virtual bool isRelational () const;


  /**
   * Predicate returning @c true if this node is a MathML
   * semantics node.
   *
   * @return @c true if this ASTNode is a MathML semantics node, @c false
   * otherwise.
   */
  virtual bool isSemantics() const;


  /**
   * Returns @c true if this node represents a square root
   * function.
   *
   * More precisely, the node type must be @sbmlconstant{AST_FUNCTION_ROOT,
   * ASTNodeType_t} with two children, the first of which is an
   * @sbmlconstant{AST_INTEGER, ASTNodeType_t} node having value equal to 2.
   *
   * @return @c true if the given ASTNode represents a <code>sqrt()</code>
   * function, @c false otherwise.
   */
  bool isSqrt () const;


  /**
   * Returns @c true if this node is a unary minus operator.
   *
   * A node is defined as a unary minus node if it is of type
   * @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
   *
   * For numbers, unary minus nodes can be "collapsed" by negating the
   * number.  In fact, @sbmlfunction{parseFormula, String} does this during
   * its parsing process, and @sbmlfunction{parseL3Formula, String} has a
   * configuration option that allows this behavior to be turned on or off.
   * However, unary minus nodes for symbols (@sbmlconstant{AST_NAME,
   * ASTNodeType_t}) cannot be "collapsed", so this predicate function is
   * necessary.
   *
   * @return @c true if this ASTNode is a unary minus, @c false
   * otherwise.
   *
   * @see @sbmlfunction{parseL3Formula, String}
   */
  bool isUMinus () const;


  /**
   * Returns @c true if this node is a unary plus operator.
   *
   * A node is defined as a unary plus node if it is of type
   * @sbmlconstant{AST_PLUS, ASTNodeType_t} and has exactly one child.
   *
   * @return @c true if this ASTNode is a unary plus, @c false otherwise.
   */
  bool isUPlus () const;


  /**
  * Returns @c true if this node is of a certain type with a specific number
  * of children.
  *
  * Designed for use in cases where it is useful to discover if the node is a
  * unary not or unary minus, or a times node with no children, etc.
  *
  * @param type the type of ASTNode sought.
  * @param numchildren the number of child nodes sought.
  *
  * @return @c true if this ASTNode is has the specified type and number of
  * children, @c false otherwise.
  */
  int hasTypeAndNumChildren(int type, unsigned int numchildren) const;


  /**
   * Returns @c true if this node has an unknown type.
   *
   * "Unknown" nodes have the type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.
   * Nodes with unknown types will not appear in an ASTNode tree returned by
   * libSBML based upon valid SBML input; the only situation in which a node
   * with type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t} may appear is
   * immediately after having create a new, untyped node using the ASTNode
   * constructor.  Callers creating nodes should endeavor to set the type to
   * a valid node type as soon as possible after creating new nodes.
   *
   * @return @c true if this ASTNode is of type @sbmlconstant{AST_UNKNOWN,
   * ASTNodeType_t}, @c false otherwise.
   */
  virtual bool isUnknown() const;


  /**
   * Returns @c true if this node has a value for the MathML
   * attribute @c id.
   *
   * @return true if this ASTNode has an attribute id, @c false
   * otherwise.
   *
   * @see isSetClass()
   * @see isSetStyle()
   * @see setId(@if java const std::string& id@endif)
   * @see unsetId()
   */
  bool isSetId() const;


  /**
   * Returns @c true if this node has a value for the MathML
   * attribute @c class.
   *
   * @return true if this ASTNode has an attribute class, @c false
   * otherwise.
   *
   * @see isSetId()
   * @see isSetStyle()
   * @see @if java setClassName(const std::string& id)@else setClass()@endif@~
   * @see unsetClass()
   */
  bool isSetClass() const;


  /**
   * Returns @c true if this node has a value for the MathML
   * attribute @c style.
   *
   * @return true if this ASTNode has an attribute style, @c false
   * otherwise.
   *
   * @see isSetClass()
   * @see isSetId()
   * @see setStyle(@if java const std::string& id@endif)
   * @see unsetStyle()
   */
  bool isSetStyle() const;


  /**
   * Returns @c true if this node has the attribute
   * <code>sbml:units</code>.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @return @c true if this ASTNode has units associated with it, @c false
   * otherwise.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   *
   * @see hasUnits()
   * @see setUnits(@if java const std::string& units@endif)
   */
  bool isSetUnits() const;


  /**
   * Returns @c true if this node or any of its
   * children nodes have the attribute <code>sbml:units</code>.
   *
   * @htmlinclude about-sbml-units-attrib.html
   *
   * @return @c true if this ASTNode or its children has units associated
   * with it, @c false otherwise.
   *
   * @note The <code>sbml:units</code> attribute is only available in SBML
   * Level&nbsp;3.  It may not be used in Levels 1&ndash;2 of SBML.
   *
   * @see isSetUnits()
   * @see setUnits(@if java const std::string& units@endif)
   */
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
  int setCharacter(char value);


  /**
   * Sets the MathML attribute @c id of this ASTNode.
   *
   * @param id @c string representing the identifier.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see isSetId()
   * @see getId()
   * @see unsetId()
   */
  int setId(const std::string& id);


  /**
   * Sets the MathML attribute @c class of this ASTNode.
   *
   * @param className @c string representing the MathML class for this node.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @if java
   * @note In the API interfaces for languages other than Java, this method
   * is named <code>setClass()</code>, but in Java it is renamed
   * <code>setClassName()</code> to avoid a name collision with Java's
   * standard object method of the same name.
   * @endif@~
   *
   * @see isSetClass()
   * @see getClass()
   * @see unsetClass()
   */
  int setClass(const std::string& className);


  /**
   * Sets the MathML attribute @c style of this ASTNode.
   *
   * @param style @c string representing the identifier.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see isSetStyle()
   * @see getStyle()
   * @see unsetStyle()
   */
  int setStyle(const std::string& style);


  /**
   * Sets the value of this ASTNode to the given name.
   *
   * As a side effect, this ASTNode object's type will be reset to
   * @sbmlconstant{AST_NAME, ASTNodeType_t} if (and <em>only if</em>) the
   * ASTNode was previously an operator (i.e., @if clike isOperator()@else
   * ASTNode::isOperator()@endif@~ returns @c true), number (i.e., @if clike
   * isNumber()@else ASTNode::isNumber()@endif@~ returns @c true), or
   * unknown.  This allows names to be set for @sbmlconstant{AST_FUNCTION,
   * ASTNodeType_t} nodes and the like.
   *
   * @param name the string containing the name to which this node's value
   * should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setName(const char* name);


  /**
   * Sets the value of this ASTNode to the given integer
   *
   * As a side effect, this operation sets the node type to
   * @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
   *
   * @param value the integer to which this node's value should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue(int value);


  /**
   * Sets the value of this ASTNode to the given (@c long) integer
   *
   * As a side effect, this operation sets the node type to
   * @sbmlconstant{AST_INTEGER, ASTNodeType_t}.
   *
   * @param value the integer to which this node's value should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue(long value);


  /**
   * Sets the value of this ASTNode to the given rational.
   *
   * As a side effect, this operation sets the node type to
   * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
   *
   * @param numerator the numerator value of the rational.
   * @param denominator the denominator value of the rational.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue(long numerator, long denominator);


  /**
   * Sets the value of this ASTNode to the given real (@c double).
   *
   * As a side effect, this operation sets the node type to
   * @sbmlconstant{AST_REAL, ASTNodeType_t}.
   *
   * This is functionally equivalent to:
   * @verbatim
setValue(value, 0);
@endverbatim
   *
   * @param value the @c double format number to which this node's value
   * should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue(double value);


  /**
   * Sets the value of this ASTNode to the given real (@c double)
   *
   * As a side effet, this operation sets the node type to
   * @sbmlconstant{AST_REAL_E, ASTNodeType_t}.
   *
   * @param mantissa the mantissa of this node's real-numbered value.
   * @param exponent the exponent of this node's real-numbered value.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setValue(double mantissa, long exponent);


  /**
   * Sets the type of this ASTNode to the given type code.
   *
   * @param type the type to which this node should be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note A side-effect of doing this is that any numerical values
   * previously stored in this node are reset to zero.
   *
   * @see getType()
   * @see setType(int Type)
   */
  int setType (ASTNodeType_t type);


  /**
   * Sets the type of this ASTNode.
   *
   * This uses integer type codes, which may come from @if clike the
   * enumeration #ASTNodeType_t@else the set
   * of static integer constants whose names begin with the prefix
   * <code>AST_</code> @endif @if java defined in the interface class
   * <code><a href="libsbmlConstants.html">libsbmlConstants</a></code>
   * @endif@if python defined in the interface class @link libsbml
   * libsbml@endlink@endif@~ or an enumeration of AST types in an SBML
   * Level&nbsp;3 package.
   *
   * @param type the integer representing the type to which this node should
   * be set.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note A side-effect of doing this is that any numerical values
   * previously stored in this node are reset to zero.
   *
   * @see getType()
   * @see setType(@if java int@else ASTNodeType_t type@endif)
   */
  int setType (int type);


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
   *
   * @see isSetUnits()
   * @see hasUnits()
   */
  int setUnits(const std::string& units);


  /**
   * Swaps the children of this node with the children of another node.
   *
   * @param that the other node whose children should be used to replace
   * <em>this</em> node's children.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int swapChildren(ASTNode* that);


  /**
   * Renames all the SIdRef attributes on this node and its child nodes.
   *
   * @param oldid the old identifier.
   * @param newid the new identifier.
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * Renames all the UnitSIdRef attributes on this node and its child nodes.
   *
   * The only place UnitSIDRefs appear in MathML <code>&lt;cn&gt;</code>
   * elements, so the effects of this method are limited to that.
   *
   * @param oldid the old identifier.
   * @param newid the new identifier.
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Replace any nodes of type AST_NAME with the name 'id' from the child
   * 'math' object with the provided ASTNode.
   *
   */
  virtual void replaceIDWithFunction(const std::string& id, const ASTNode* function);

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /**
   * Replaces any 'AST_NAME_TIME' nodes with a node that multiplies time by
   * the given function.
   *
   */
  //virtual void multiplyTimeBy(const ASTNode* function);

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  virtual void setIsChildFlag(bool flag);

  /** @endcond */

  /**
   * Unsets the units of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetUnits();

  /**
   * Unsets the MathML @c id attribute of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetId();


  /**
   * Unsets the MathML @c class attribute of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetClass();


  /**
   * Unsets the MathML @c style attribute of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetStyle();


  /**
   * Sets the MathML attribute @c definitionURL.
   *
   * @param url the URL value for the @c definitionURL attribute.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @see setDefinitionURL(const std::string& url)
   * @see getDefinitionURL()
   * @see getDefinitionURLString()
   */
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
  int setDefinitionURL(const std::string& url);


  /**
   * Returns the MathML @c definitionURL attribute value.
   *
   * @return the value of the @c definitionURL attribute, in the form of
   * a libSBML XMLAttributes object.
   *
   * @see setDefinitionURL(XMLAttributes url)
   * @see setDefinitionURL(const std::string& url)
   * @see getDefinitionURLString()
   */
  XMLAttributes* getDefinitionURL() const;


  /**
   * Replaces occurrences of a given name with a given ASTNode.
   *
   * For example, if the formula in this ASTNode is <code>x + y</code>,
   * then the <code>&lt;bvar&gt;</code> is @c x and @c arg is an ASTNode
   * representing the real value @c 3.  This method substitutes @c 3 for @c
   * x within this ASTNode object.
   *
   * @param bvar a string representing the variable name to be substituted.
   *
   * @param arg an ASTNode representing the name/value/formula to use as
   * a replacement.
   */
  void replaceArgument(const std::string& bvar, ASTNode *arg);


  /**
   * Sets the parent SBML object.
   *
   * @param sb the parent SBML object of this ASTNode.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isSetParentSBMLObject()
   * @see getParentSBMLObject()
   */
  int setParentSBMLObject(SBase* sb);


  /**
   * Returns the parent SBML object.
   *
   * @return the parent SBML object of this ASTNode.
   *
   * @see isSetParentSBMLObject()
   * @if clike @see setParentSBMLObject()@endif@~
   */
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
  bool isSetParentSBMLObject() const;


  /**
   * Reduces this ASTNode to a binary tree.
   *
   * Example: if this ASTNode is <code>and(x, y, z)</code>, then the
   * formula of the reduced node is <code>and(and(x, y), z)</code>.  The
   * operation replaces the formula stored in the current ASTNode object.
   */
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
  *
  * @if clike
  * @see ASTNode::isSetUserData()
  * @see ASTNode::getUserData()
  * @see ASTNode::unsetUserData()
  * @endif
  */
  int setUserData(void *userData);


 /**
  * Returns the user data that has been previously set via setUserData().
  *
  * @return the user data of this node, or @c NULL if no user data has been
  * set.
  *
  * @if clike
  * @see ASTNode::isSetUserData()
  * @see ASTNode::setUserData()
  * @see ASTNode::unsetUserData()
  * @endif@~
  */
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
 bool isWellFormedASTNode() const;


 /**
  * Returns @c true if this ASTNode has the correct number of children for
  * its type.
  *
  * For example, an ASTNode with type @sbmlconstant{AST_PLUS, ASTNodeType_t}
  * expects 2 child nodes.
  *
  * @return @c true if this ASTNode has the appropriate number of children
  * for its type, @c false otherwise.
  *
  * @note This function performs a check on the top-level node only.  Child
  * nodes are not checked.
  *
  * @see isWellFormedASTNode()
  */
  bool hasCorrectNumberArguments() const;


  /* additional to original AST */

  /**
   * Returns the MathML @c definitionURL attribute value as a string.
   *
   * @return the value of the @c definitionURL attribute, as a string.
   *
   * @see getDefinitionURL()
   * @see setDefinitionURL(const std::string& url)
   * @see setDefinitionURL(XMLAttributes url)
   */
  std::string getDefinitionURLString() const;


  /** @cond doxygenLibsbmlInternal */

  virtual bool representsBvar() const;


  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /*
   * writes the node to the stream
   */
  virtual void write(XMLOutputStream& stream) const;

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /*
   * reads the node from the stream
   */
  virtual bool read(XMLInputStream& stream, const std::string& reqd_prefix="");

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  virtual void writeNodeOfType(XMLOutputStream& stream, int type,
    bool inChildNode = false) const;

  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  unsigned int getNumBvars() const;

  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  virtual int getTypeCode () const;

  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  virtual const std::string& getPackageName () const;

  /** @endcond */

protected:

  /** @cond doxygenLibsbmlInternal */

  ASTNumber * mNumber;
  ASTFunction * mFunction;

  /* put this here for historical purposes */
  char mChar;
  std::string mHistoricalName;

  bool containsVariable(const std::string id) const;


  unsigned int getNumVariablesWithUndeclaredUnits(Model * m = NULL) const;

  friend class UnitFormulaFormatter;
  friend class ASTFunctionBase;
  /**
   * Internal helper function for canonicalize().
   */

  bool canonicalizeConstant   ();
  bool canonicalizeFunction   ();
  bool canonicalizeFunctionL1 ();
  bool canonicalizeLogical    ();
  bool canonicalizeRelational ();

  /* additional to original astnode */
  bool hasCnUnits() const;
  const std::string& getUnitsPrefix() const;

  /* constructors for wrapping a number or a function node into
   * a newASTNode
   */
  ASTNode(ASTNumber* number);

  ASTNode(ASTFunction* function);


  void reset();

  void connectPlugins();


  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  /*
   * return the number member variable
   */
  virtual ASTNumber *   getNumber() const;

  /** @endcond */

  /** @cond doxygenLibsbmlInternal */

  /*
   * return the function member variable
   */
  virtual ASTFunction * getFunction() const;

  /** @endcond */

  friend class ASTSemanticsNode;
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
 * operators, numbers, or @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.  This
 * method will have no effect on other types of nodes.
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
 * @li If the node type is an @sbmlconstant{AST_FUNCTION, ASTNodeType_t} and
 * the node name matches an SBML (MathML) function name, logical operator
 * name, or relational operator name, the node is converted to the
 * corresponding <code>AST_FUNCTION_</code><em><span
 * class="placeholder">X</span></em> or <code>AST_LOGICAL_</code><em><span
 * class="placeholder">X</span></em> type.
 *
 * SBML Level&nbsp;1 function names are searched first; thus, for example,
 * canonicalizing @c log will result in a node type of
 * @sbmlconstant{AST_FUNCTION_LN, ASTNodeType_t}.  (See the SBML Level&nbsp;1
 * Version&nbsp;2 Specification, Appendix C.)
 *
 * Sometimes, canonicalization of a node results in a structural
 * conversion of the node as a result of adding a child.  For example, a
 * node with the SBML Level&nbsp;1 function name @c sqr and a single
 * child node (the argument) will be transformed to a node of type
 * @sbmlconstant{AST_FUNCTION_POWER, ASTNodeType_t} with
 * two children.  The first child will remain unchanged, but the second child
 * will be an ASTNode_t of type @sbmlconstant{AST_INTEGER, ASTNodeType_t} and
 * a value of 2.  The function names that result in structural changes are:
 * @c log10, @c sqr, and @c sqrt.
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
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
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
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
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
 * @copydetails doc_returns_success_code
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
 * Replaces but does not delete the nth child of a given node.
 *
 * @param node the ASTNode_t node to modify
 * @param n unsigned int the index of the child to replace
 * @param newChild ASTNode_t structure to replace the nth child
 *
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * Returns a child of a node according to its index number.
 *
 * @param node the node whose child should be obtained.
 * @param n the index of the desired child node.
 *
 * @return the nth child of this ASTNode_t or a null pointer if this node has
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
 * nonzero).
 *
 * The predicate is passed in as a pointer to a function.  The function
 * definition must have the type @sbmlconstant{AST_PLUS, ASTNode.h::ASTNodePredicate
 * ASTNodePredicate@endlink, which is defined as
 * @code{.c}
 int (*ASTNodePredicate) (const ASTNode_t *node);
 @endcode
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
 * definition must have the type @link ASTNode.h::ASTNodePredicate
 * ASTNodePredicate@endlink, which is defined as
 * @code{.c}
 int (*ASTNodePredicate) (const ASTNode_t *node);
 @endcode
 * where a return value of nonzero represents true and zero
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
 * Returns the value of a node as a single character.
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
 * Returns the value of a node as an integer.
 *
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_INTEGER, ASTNodeType_t} for the given @p node.
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
 * Returns the value of a node as a string.
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
 * Returns the numerator value of a node representing a rational number.
 *
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_RATIONAL, ASTNodeType_t} for the given @p node.
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
 * Returns the numerator value of a node representing a rational number.
 *
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_RATIONAL, ASTNodeType_t} for the given @p node.
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
 * This function should be called only when ASTNode_isReal() returns nonzero
 * for @p node. This function performs the necessary arithmetic if the node
 * type is @sbmlconstant{AST_REAL_E, ASTNodeType_t} (<em>mantissa * 10<sup>
 * exponent</sup></em>) or @sbmlconstant{AST_RATIONAL, ASTNodeType_t}
 * (<em>numerator / denominator</em>).
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
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_REAL_E, ASTNodeType_t} or
 * @sbmlconstant{AST_REAL, ASTNodeType_t} for the given @p node.  If
 * ASTNode_getType() returns @sbmlconstant{AST_REAL, ASTNodeType_t} for @p
 * node, this method behaves identically to ASTNode_getReal().
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
 * This function should be called only when ASTNode_getType() returns
 * @sbmlconstant{AST_REAL_E, ASTNodeType_t} or @sbmlconstant{AST_REAL,
 * ASTNodeType_t} for the given @p node.
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
 * Returns the precedence of a node in the infix math syntax of SBML
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
 * Returns the MathML @c id attribute of a given node.
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
 * Returns the MathML @c class attribute of a given node.
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
 * Returns the MathML @c style attribute of a given node.
 *
 * @param node the node
 *
 * @return a string representing the @c style value, or a null value if @p is
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
 * @return @c 1 if @p node is of type
 * @sbmlconstant{AST_INTEGER, ASTNodeType_t}, @c 0 otherwise.
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
 * @return @c 1 if @p node is of type
 * @sbmlconstant{AST_LAMBDA, ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isLambda (const ASTNode_t *node);


/**
 * Returns true if the given node represents the log base-10 function.
 *
 * More precisely, this function tests if the given @p node's type is
 * @sbmlconstant{AST_FUNCTION_LOG, ASTNodeType_t} with two children, the
 * first of which is an @sbmlconstant{AST_INTEGER, ASTNodeType_t} equal to @c
 * 10.
 *
 * @return @c 1 if @p node represents a @c log10() function, @c 0
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
 * @code{.c}
ASTNode_isInteger(node) || ASTNode_isReal(node).
@endcode
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
 * Returns true if the given node represents a MathML
 * qualifier (i.e., @c bvar, @c degree, @c base, @c piece, @c otherwise),
 * @c false (zero) otherwise.
 *
 * More precisely, this node must be of one of the following types:
 * @sbmlconstant{AST_QUALIFIER_BVAR, ASTNodeType_t},
 * @sbmlconstant{AST_QUALIFIER_LOGBASE, ASTNodeType_t},
 * @sbmlconstant{AST_QUALIFIER_DEGREE, ASTNodeType_t},
 * @sbmlconstant{AST_CONSTRUCTOR_PIECE, ASTNodeType_t} or
 * @sbmlconstant{AST_CONSTRUCTOR_OTHERWISE, ASTNodeType_t}.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is a MathML qualifier, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isQualifier (const ASTNode_t *node);


/**
 * Returns true if the given node represents a rational number.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type @sbmlconstant{AST_RATIONAL,
 * ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isRational (const ASTNode_t *node);


/**
 * Returns true if the given node represents a real number.
 *
 * More precisely, this node must be of one of the following types:
 * @sbmlconstant{AST_REAL, ASTNodeType_t}, @sbmlconstant{AST_REAL_E,
 * ASTNodeType_t} or @sbmlconstant{AST_RATIONAL, ASTNodeType_t}.
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
 * Returns true if the given node represents a semantics node.
 *
 * @param node the node to query
 *
 * @return @c 1 if @p node is of type
 * @sbmlconstant{AST_SEMANTICS, ASTNodeType_t}, @c 0 otherwise.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isSemantics (const ASTNode_t *node);


/**
 * Returns true if the given node is the MathML square-root operator.
 *
 * More precisely, the node type must be @sbmlconstant{AST_FUNCTION_ROOT,
 * ASTNodeType_t} with two children, the first of which is an
 * @sbmlconstant{AST_INTEGER, ASTNodeType_t} node having value equal to 2.
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
 * A node is defined as a unary minus node if it is of type
 * @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
 *
 * For numbers, unary minus nodes can be "collapsed" by negating the number.
 * In fact, SBML_parseFormula() does this during its parsing process, and
 * SBML_parseL3Formula() has a configuration option that allows this behavior
 * to be turned on or off.  However, unary minus nodes for symbols
 * (@sbmlconstant{AST_NAME, ASTNodeType_t}) cannot be "collapsed", so this
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
 * A node is defined as a unary minus node if it is of type
 * @sbmlconstant{AST_MINUS, ASTNodeType_t} and has exactly one child.
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
 * "Unknown" nodes have the type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t}.
 * Nodes with unknown types will not appear in an ASTNode_t tree returned by
 * libSBML based upon valid SBML input; the only situation in which a node
 * with type @sbmlconstant{AST_UNKNOWN, ASTNodeType_t} may appear is
 * immediately after having create a new, untyped node using the ASTNode_t
 * constructor.  Callers creating nodes should endeavor to set the type to a
 * valid node type as soon as possible after creating new nodes.
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
 * Returns true if the given node's MathML @c id attribute is set.
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
 * Returns true if the given node's MathML @c class attribute is set.
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
 * Returns true if the given node's MathML @c style attribute is set.
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
 * @copydetails doc_returns_success_code
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
 * As a side-effect, this ASTNode_t object's type will be reset to
 * @sbmlconstant{AST_NAME, ASTNodeType_t} if (and <em>only if</em>) the @p
 * node was previously an operator (i.e., ASTNode_isOperator() returns true),
 * number (i.e., ASTNode_isNumber() returns true), or unknown.  This allows
 * names to be set for @sbmlconstant{AST_FUNCTION, ASTNodeType_t} nodes and
 * the like.
 *
 * @param node the node to set
 * @param name the name value for the node
 *
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * As a side-effect, the @p node's type will be set to
 * @sbmlconstant{AST_REAL, ASTNodeType_t}.
 *
 * @param node the node to set
 * @param mantissa the mantissa of this node's real-numbered value
 * @param exponent the exponent of this node's real-numbered value
 *
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * Sets the MathML @c id attribute of the given node.
 *
 * @param node the node to set
 * @param id the identifier to use
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setId (ASTNode_t *node, const char *id);


/**
 * Sets the MathML @c class of the given node.
 *
 * @param node the node to set
 * @param className the new value for the @c class attribute
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setClass (ASTNode_t *node, const char *className);


/**
 * Sets the MathML @c style of the given node.
 *
 * @param node the node to set
 * @param style the new value for the @c style attribute
 *
 * @copydetails doc_returns_success_code
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
 * The units will be set @em only if the ASTNode_t structure in @p node
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_swapChildren (ASTNode_t *node, ASTNode_t *that);


/**
 * Unsets the MathML @c id attribute of the given node.
 *
 * @param node the node to modify
 *
 * @copydetails doc_returns_success_code
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
 * Unsets the MathML @c class attribute of the given node.
 *
 * @param node the node to modify
 *
 * @copydetails doc_returns_success_code
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
 * Unsets the MathML @c style attribute of the given node.
 *
 * @param node the node to modify
 *
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 *
 * @see ASTNode_replaceAndDeleteArgument()
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
 * Returns the parent SBase_t structure containing the given node.
 *
 * @param node the node to query
 *
 * @return a pointer to the structure containing the given node.
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


/**
 * Sets the parent SBase_t structure.
 *
 * @param node the node to modify
 * @param sb the parent SBase_t structure of this ASTNode_t.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setParentSBMLObject(ASTNode_t* node, SBase_t * sb);


/**
 * Unsets the parent SBase_t structure.
 *
 * @param node the node to modify
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_unsetParentSBMLObject(ASTNode_t* node);


/**
 * Adds a given XML node structure as a MathML <code>&lt;semantics&gt;</code> element
 * of a given ASTNode_t structure.
 *
 * @copydetails doc_about_mathml_semantic_annotations
 *
 * @param node the node to modify
 * @param annotation the annotation to add
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @copydetails doc_note_mathml_semantic_annotations_uncommon
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
 * @copydetails doc_about_mathml_semantic_annotations
 *
 * @param node the node to query
 * @param n the index of the semantic annotation to fetch
 *
 * @return the nth semantic annotation on @p node , or a null pointer if the
 * node has no nth annotation (which would mean that <code>n &gt;
 * ASTNode_getNumSemanticsAnnotations(node) - 1</code>).
 *
 * @copydetails doc_note_mathml_semantic_annotations_uncommon
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * For example, an ASTNode_t structure with type @sbmlconstant{AST_PLUS,
 * ASTNodeType_t} expects 2 child nodes.
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
 * @note An ASTNode_t may be well-formed, with each node and its children
 * having the appropriate number of children for the given type, but may
 * still be invalid in the context of its use within an SBML model.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isWellFormedASTNode(ASTNode_t* node);


/**
 * Returns the MathML @c definitionURL attribute value of the given node.
 *
 * @param node the node to query
 *
 * @return the value of the @c definitionURL attribute in the form of a
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
 * Returns the MathML @c definitionURL attribute value of the given node as a
 * string.
 *
 * @param node the node to query
 *
 * @return the value of the @c definitionURL attribute in the form of a
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
 * Sets the MathML @c definitionURL attribute of the given node.
 *
 * @param node the node to modify
 * @param defnURL the value to which the attribute should be set
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_setDefinitionURL(ASTNode_t* node, XMLAttributes_t * defnURL);


/**
 * Sets the MathML @c definitionURL attribute of the given node.
 *
 * @param node the node to modify
 * @param defnURL a string to which the attribute should be set
 *
 * @copydetails doc_returns_success_code
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

/** @cond doxygenLibsbmlInternal */
/**
 * Used internally for L3FormulaFormatter to know whether to write a package
 * function as 'functioname(arguments)' or not.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_isPackageInfixFunction(const ASTNode_t *node);
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * Used internally for L3FormulaFormatter to know whether writing a package
 * function has special package-specific syntax.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_hasPackageOnlyInfixSyntax(const ASTNode_t *node);
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * Used internally for L3FormulaFormatter to know what the precedence is for
 * a package function.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_getL3PackageInfixPrecedence(const ASTNode_t *node);
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * Used internally for L3FormulaFormatter to know whether writing a package
 * function has special package-specific syntax.
 *
 * @memberof ASTNode_t
 */
LIBSBML_EXTERN
int
ASTNode_hasUnambiguousPackageInfixGrammar(const ASTNode_t *node, const ASTNode_t *child);
/** @endcond */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* ASTNode_h */
