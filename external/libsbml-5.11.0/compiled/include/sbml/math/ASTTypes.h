/**
 * @file    ASTTypes.h
 * @brief   Abstract Syntax Tree (AST) class types.
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
 * Copyright (C) 2009-2012 jointly by the following organizations: 
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
 */

#ifndef ASTTypes_h
#define ASTTypes_h

#include <sbml/common/extern.h>



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
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
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

  , AST_QUALIFIER_BVAR/*!< Bvar qualifier (MathML <code>&lt;bvar&gt;</code>) */
  , AST_QUALIFIER_LOGBASE/*!< Logbase qualifier (MathML <code>&lt;logbase&gt;</code>) */
  , AST_QUALIFIER_DEGREE/*!< Degree qualifier (MathML <code>&lt;degree&gt;</code>) */

  , AST_SEMANTICS/*!< Semantics (MathML <code>&lt;semantics&gt;</code>) */

  , AST_CONSTRUCTOR_PIECE/*!< Piece constructor (MathML <code>&lt;piece&gt;</code>) */
  , AST_CONSTRUCTOR_OTHERWISE/*!< Otherwise constructor (MathML <code>&lt;otherwise&gt;</code>) */

  , AST_UNKNOWN /*!< Unknown node:  will not produce any MathML */
  , AST_ORIGINATES_IN_PACKAGE /*!< This node uses math that is only available in an L3 package */
} ASTNodeType_t;


/** @cond doxygenLibsbmlInternal */

typedef enum
{
  AST_TYPECODE_BASE
, AST_TYPECODE_CN_BASE
, AST_TYPECODE_FUNCTION_BASE
, AST_TYPECODE_NUMBER
, AST_TYPECODE_CN_INTEGER
, AST_TYPECODE_CN_EXPONENTIAL
, AST_TYPECODE_CN_RATIONAL
, AST_TYPECODE_CN_REAL
, AST_TYPECODE_CONSTANT_NUMBER
, AST_TYPECODE_CI_NUMBER
, AST_TYPECODE_CSYMBOL
, AST_TYPECODE_CSYMBOL_AVOGADRO
, AST_TYPECODE_CSYMBOL_DELAY
, AST_TYPECODE_CSYMBOL_TIME
, AST_TYPECODE_FUNCTION
, AST_TYPECODE_FUNCTION_UNARY
, AST_TYPECODE_FUNCTION_BINARY
, AST_TYPECODE_FUNCTION_NARY
, AST_TYPECODE_FUNCTION_PIECEWISE
, AST_TYPECODE_FUNCTION_LAMBDA
, AST_TYPECODE_FUNCTION_CI
, AST_TYPECODE_FUNCTION_SEMANTIC
, AST_TYPECODE_FUNCTION_QUALIFIER
, AST_TYPECODE_ASTNODE
} AST_Class_TypeCode_t;

/** @endcond */


LIBSBML_CPP_NAMESPACE_END

/** @cond doxygenLibsbmlInternal */

#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTBasePlugin;

/**
 * Note to developers: leave at least one comment here.  Without it, something
 * doesn't go right when docs are generated.
 */
LIBSBML_EXTERN
bool representsNumber(int type);


LIBSBML_EXTERN
bool representsFunction(int type, ASTBasePlugin* plugin = NULL);


LIBSBML_EXTERN
bool representsUnaryFunction(int type, ASTBasePlugin* plugin = NULL);


LIBSBML_EXTERN
bool representsBinaryFunction(int type, ASTBasePlugin* plugin = NULL);


LIBSBML_EXTERN
bool representsNaryFunction(int type, ASTBasePlugin* plugin = NULL);


LIBSBML_EXTERN
bool representsQualifier(int type, ASTBasePlugin* plugin = NULL);


LIBSBML_EXTERN
bool representsFunctionRequiringAtLeastTwoArguments(int type);


LIBSBML_EXTERN
int getCoreTypeFromName(const std::string& name);

LIBSBML_EXTERN
const char* getNameFromCoreType(int type);

LIBSBML_EXTERN
bool isCoreTopLevelMathMLFunctionNodeTag(const std::string& name);

LIBSBML_EXTERN
bool isCoreTopLevelMathMLNumberNodeTag(const std::string& name);

LIBSBML_CPP_NAMESPACE_END

#endif /* cplusplus */

/** @endcond */

#endif  /* ASTTypes_h */



