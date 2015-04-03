/**
 * @file    MathML.cpp
 * @brief   Utilities for reading and writing MathML to/from text strings.
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

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLInputStream.h>

#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

#include <sbml/util/util.h>

#include <sbml/common/common.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus
/** @cond doxygenLibsbmlInternal */

//static const int SBML_INT_MAX = 2147483647;
//static const int SBML_INT_MIN = -2147483647 - 1;

static const char* URL_TIME  = "http://www.sbml.org/sbml/symbols/time";
static const char* URL_DELAY = "http://www.sbml.org/sbml/symbols/delay";
static const char* URL_AVOGADRO = "http://www.sbml.org/sbml/symbols/avogadro";

static const char* MATHML_ELEMENTS[] =
{
    "abs"
  , "and"
  , "annotation"
  , "annotation-xml"
  , "apply"
  , "arccos"
  , "arccosh"
  , "arccot"
  , "arccoth"
  , "arccsc"
  , "arccsch"
  , "arcsec"
  , "arcsech"
  , "arcsin"
  , "arcsinh"
  , "arctan"
  , "arctanh"
  , "bvar"
  , "ceiling"
  , "ci"
  , "cn"
  , "cos"
  , "cosh"
  , "cot"
  , "coth"
  , "csc"
  , "csch"
  , "csymbol"
  , "degree"
  , "divide"
  , "eq"
  , "exp"
  , "exponentiale"
  , "factorial"
  , "false"
  , "floor"
  , "geq"
  , "gt"
  , "infinity"
  , "lambda"
  , "leq"
  , "ln"
  , "log"
  , "logbase"
  , "lt"
  , "math"
  , "minus"
  , "neq"
  , "not"
  , "notanumber"
  , "or"
  , "otherwise"
  , "pi"
  , "piece"
  , "piecewise"
  , "plus"
  , "power"
  , "root"
  , "sec"
  , "sech"
  , "semantics"
  , "sep"
  , "sin"
  , "sinh"
  , "tan"
  , "tanh"
  , "times"
  , "true"
  , "xor"
};


static const char* MATHML_FUNCTIONS[] =
{
    "abs"
  , "arccos"
  , "arccosh"
  , "arccot"
  , "arccoth"
  , "arccsc"
  , "arccsch"
  , "arcsec"
  , "arcsech"
  , "arcsin"
  , "arcsinh"
  , "arctan"
  , "arctanh"
  , "ceiling"
  , "cos"
  , "cosh"
  , "cot"
  , "coth"
  , "csc"
  , "csch"
  , "csymbol"
  , "exp"
  , "factorial"
  , "floor"
  , "ln"
  , "log"
  , "piecewise"
  , "power"
  , "root"
  , "sec"
  , "sech"
  , "sin"
  , "sinh"
  , "tan"
  , "tanh"
  , "and"
  , "not"
  , "or"
  , "xor"
  , "eq"
  , "geq"
  , "gt"
  , "leq"
  , "lt"
  , "neq"
};


static const ASTNodeType_t MATHML_TYPES[] =
{
    AST_FUNCTION_ABS
  , AST_LOGICAL_AND
  , AST_UNKNOWN
  , AST_UNKNOWN
  , AST_FUNCTION
  , AST_FUNCTION_ARCCOS
  , AST_FUNCTION_ARCCOSH
  , AST_FUNCTION_ARCCOT
  , AST_FUNCTION_ARCCOTH
  , AST_FUNCTION_ARCCSC
  , AST_FUNCTION_ARCCSCH
  , AST_FUNCTION_ARCSEC
  , AST_FUNCTION_ARCSECH
  , AST_FUNCTION_ARCSIN
  , AST_FUNCTION_ARCSINH
  , AST_FUNCTION_ARCTAN
  , AST_FUNCTION_ARCTANH
  , AST_UNKNOWN
  , AST_FUNCTION_CEILING
  , AST_NAME
  , AST_REAL
  , AST_FUNCTION_COS
  , AST_FUNCTION_COSH
  , AST_FUNCTION_COT
  , AST_FUNCTION_COTH
  , AST_FUNCTION_CSC
  , AST_FUNCTION_CSCH
  , AST_NAME
  , AST_UNKNOWN
  , AST_DIVIDE
  , AST_RELATIONAL_EQ
  , AST_FUNCTION_EXP
  , AST_CONSTANT_E
  , AST_FUNCTION_FACTORIAL
  , AST_CONSTANT_FALSE
  , AST_FUNCTION_FLOOR
  , AST_RELATIONAL_GEQ
  , AST_RELATIONAL_GT
  , AST_REAL
  , AST_LAMBDA
  , AST_RELATIONAL_LEQ
  , AST_FUNCTION_LN
  , AST_FUNCTION_LOG
  , AST_UNKNOWN
  , AST_RELATIONAL_LT
  , AST_UNKNOWN
  , AST_MINUS
  , AST_RELATIONAL_NEQ
  , AST_LOGICAL_NOT
  , AST_REAL
  , AST_LOGICAL_OR
  , AST_UNKNOWN
  , AST_CONSTANT_PI
  , AST_UNKNOWN
  , AST_FUNCTION_PIECEWISE
  , AST_PLUS
  , AST_FUNCTION_POWER
  , AST_FUNCTION_ROOT
  , AST_FUNCTION_SEC
  , AST_FUNCTION_SECH
  , AST_UNKNOWN
  , AST_UNKNOWN
  , AST_FUNCTION_SIN
  , AST_FUNCTION_SINH
  , AST_FUNCTION_TAN
  , AST_FUNCTION_TANH
  , AST_TIMES
  , AST_CONSTANT_TRUE
  , AST_LOGICAL_XOR
};
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * logs the given erroron the error log of the stream.
 * 
 * @param stream the stream to log the error on
 * @param element the element to log the error for
 * @param code the error code to log
 * @param msg optional message
 */
static void
logError (XMLInputStream& stream, const XMLToken& element, SBMLErrorCode_t code,
          const std::string& msg = "")
{
  if (&element == NULL || &stream == NULL) return;

  SBMLNamespaces* ns = stream.getSBMLNamespaces();
  if (ns != NULL)
  {
    static_cast <SBMLErrorLog*>
      (stream.getErrorLog())->logError(
      code,
      ns->getLevel(), 
      ns->getVersion(),
      msg, 
      element.getLine(), 
      element.getColumn());
  }
  else
  {
    static_cast <SBMLErrorLog*>
      (stream.getErrorLog())->logError(
      code, 
      SBML_DEFAULT_LEVEL, 
      SBML_DEFAULT_VERSION, 
      msg, 
      element.getLine(), 
      element.getColumn());
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * @return s with whitespace removed from the beginning and end.
 */
static const string
trim (const string& s)
{
  if (&s == NULL) return s;

  static const string whitespace(" \t\r\n");

  string::size_type begin = s.find_first_not_of(whitespace);
  string::size_type end   = s.find_last_not_of (whitespace);

  return (begin == string::npos) ? string() : s.substr(begin, end - begin + 1);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/* ---------------------------------------------------------------------- */
/*                             MathML Input                               */
/* ---------------------------------------------------------------------- */

/*
 * Ensures the given ASTNode has the appropriate number of arguments.  If
 * arguments are missing, appropriate defaults (per the MathML 2.0
 * specification) are added:
 *
 *   log (x) -> log (10, x)
 *   root(x) -> root( 2, x)
 */
static void
checkFunctionArgs (ASTNode& node)
{
  if (&node == NULL) return;

  if (node.getNumChildren() == 1)
  {
    if (node.getType() == AST_FUNCTION_LOG)
    {
      ASTNode* child = new ASTNode;
      child->setValue(10);

      node.prependChild(child);
    }
    else if (node.getType() == AST_FUNCTION_ROOT)
    {
      ASTNode* child = new ASTNode;
      child->setValue(2);

      node.prependChild(child);
    }
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * In MathML, &lt;plus/> and &lt;times/> are n-ary operators but the infix
 * FormulaParser represents them as binary operators.  To ensure a
 * consistent AST representation, this function is part of the n-ary to
 * binary reduction process.
 */
static void
reduceBinary (ASTNode& node)
{
  if (&node == NULL) return;

  if (node.getNumChildren() == 2)
  {
    ASTNode* op = new ASTNode( node.getType() );
    node.swapChildren(op);
    node.prependChild(op);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets the type of an ASTNode based on the given MathML &lt;ci&gt; element.
 * Errors will be logged in the stream's SBMLErrorLog object.
 */
static void
setTypeCI (ASTNode& node, const XMLToken& element, XMLInputStream& stream)
{
  if (&node == NULL || &element == NULL || &stream == NULL) return;

  if (element.getName() == "csymbol")
  {
    string url;
    element.getAttributes().readInto("definitionURL", url);

    if (stream.getSBMLNamespaces()->getLevel() < 3)
    {
      if ( url == URL_DELAY ) node.setType(AST_FUNCTION_DELAY);
      else if ( url == URL_TIME  ) node.setType(AST_NAME_TIME);
      else 
      {
        logError(stream, element, BadCsymbolDefinitionURLValue);      
      }
    }
    else
    {
      if ( url == URL_DELAY ) node.setType(AST_FUNCTION_DELAY);
      else if ( url == URL_TIME  ) node.setType(AST_NAME_TIME);
      else if ( url == URL_AVOGADRO  ) node.setType(AST_NAME_AVOGADRO);
      else 
      {
        logError(stream, element, BadCsymbolDefinitionURLValue);      
      }
    }
  }
  else if (element.getName() == "ci")
  {
    if (element.getAttributes().hasAttribute("definitionURL") == true)
    {
      node.setDefinitionURL(element.getAttributes());
    }
  }

  const string name = trim( stream.next().getCharacters() );
  node.setName( name.c_str() );
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets the type of an ASTNode based on the given MathML &lt;cn> element.
 * Errors will be logged in the stream's SBMLErrorLog object.
 */
static void
setTypeCN (ASTNode& node, const XMLToken& element, XMLInputStream& stream)
{
  if (&node == NULL || &element == NULL || &stream == NULL) return;

  string type = "real";
  element.getAttributes().readInto("type", type);

  // here is the only place we might encounter the sbml:units attribute
  string units = "";
  element.getAttributes().readInto("units", units);

  if (type == "real")
  {
    double value = 0;
    istringstream isreal;
    isreal.str( stream.next().getCharacters() );
    isreal >> value;

    node.setValue(value);

    if (isreal.fail() 
      || node.isInfinity()
      || node.isNegInfinity()
      )
    {
      logError(stream, element, FailedMathMLReadOfDouble);      
    }

  }

  else if (type == "integer")
  {
    int value = 0;
    istringstream isint;
    isint.str( stream.next().getCharacters() );
    isint >> value;

    if (isint.fail())
    {
      logError(stream, element, FailedMathMLReadOfInteger);      
    }
    else if ( sizeof(int) > 4 && ( (value > SBML_INT_MAX) || (value < SBML_INT_MIN) ) )
    {
      logError(stream, element, FailedMathMLReadOfInteger);      
    }

    node.setValue(value);
  }

  else if (type == "e-notation")
  {
    double mantissa = 0;
    long   exponent = 0;
    istringstream ismantissa;
    istringstream isexponent;
    ismantissa.str( stream.next().getCharacters() );
    ismantissa >> mantissa;

    if (stream.peek().getName() == "sep")
    {
      stream.next();
      isexponent.str( stream.next().getCharacters() );
      isexponent >> exponent;
    }

    node.setValue(mantissa, exponent);

    if (ismantissa.fail() 
      || isexponent.fail()
      || node.isInfinity()
      || node.isNegInfinity())
    {
      logError(stream, element, FailedMathMLReadOfExponential);     
    }
    
  }

  else if (type == "rational")
  {
    int numerator = 0;
    int denominator = 1;

    istringstream isnumerator;
    istringstream isdenominator;
    isnumerator.str( stream.next().getCharacters() );
    isnumerator >> numerator;

    if (stream.peek().getName() == "sep")
    {
      stream.next();
      isdenominator.str( stream.next().getCharacters() );
      isdenominator >> denominator;
    }

    if (isnumerator.fail() || isdenominator.fail())
    {
      logError(stream, element, FailedMathMLReadOfRational);      
    }
    else if ( sizeof(int) > 4 && 
        ( ( (numerator > SBML_INT_MAX) || (numerator < SBML_INT_MIN) ) 
          ||
          ( (denominator > SBML_INT_MAX) || (denominator < SBML_INT_MIN) ) 
        ))
    {
      logError(stream, element, FailedMathMLReadOfRational);
    }

    node.setValue(static_cast<long>(numerator), static_cast<long>(denominator));
  }
  else
  {
    logError(stream, element, DisallowedMathTypeAttributeValue);    
  }

  // set the units
  // has to be here so node knows it is a number
  if (!units.empty())
  { 
    node.setUnits(units);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets the type of an ASTNode based on the given MathML element (not <ci>
 * or <cn>).
 */
static void
setTypeOther (ASTNode& node, const XMLToken& element, XMLInputStream& stream)
{
  if (&node == NULL || &element == NULL || &stream == NULL) return;

  static const int size = sizeof(MATHML_ELEMENTS) / sizeof(MATHML_ELEMENTS[0]);
  const char*      name = element.getName().c_str();

  int  index = util_bsearchStringsI(MATHML_ELEMENTS, name, 0, size - 1);
  bool found = (index < size);

  if (found) node.setType(MATHML_TYPES[index]);

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets the type of an ASTNode based on the given MathML element.
 */
static void
setType (ASTNode& node, const XMLToken& element, XMLInputStream& stream)
{
  if (&node == NULL || &element == NULL || &stream == NULL) return;

  const string& name = element.getName();

  if (name == "ci" || name == "csymbol")
  {
    setTypeCI(node, element, stream);
  }
  else if (name == "cn")
  {
    setTypeCN(node, element, stream);
  }
  else if (name == "notanumber")
  {
    node.setValue( numeric_limits<double>::quiet_NaN() );
  }

  else if (name == "infinity")
  {
    node.setValue( numeric_limits<double>::infinity() );
  }
  else
  {
    setTypeOther(node, element, stream);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/* in the MathML spec only certain tags can follow the <math> tag
 * this function returns true if the name represents 
 * these tags called Node within the mathML schema
 */
bool
isMathMLNodeTag(const string& name)
{
  if (&name == NULL) return false;

  if ( name == "apply"
    || name == "cn"
    || name == "ci"
    || name == "csymbol"
    || name == "true"
    || name == "false"
    || name == "notanumber"
    || name == "pi"
    || name == "infinity"
    || name == "exponentiale"
    || name == "semantics"
    || name == "piecewise")
      return true;
    else
      return false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Essentially an s-expression parser.
 * Errors will be logged in the stream's SBMLErrorLog object.
 */
static void
readMathML (ASTNode& node, XMLInputStream& stream, std::string reqd_prefix,
            bool inRead)
{
  if (&node == NULL || &stream == NULL) return;

  std::string prefix;
  bool prefix_reqd = false;
  if (!reqd_prefix.empty())
  {
    prefix_reqd = true;
  }

  stream.skipText();

  // catch case where user has an empty math tags ( <math ...></math> )
  if( stream.peek().getName() == "math" && stream.peek().isEnd() )
  {
    // check any reqd prefix is correct
    if (prefix_reqd)
    {
      prefix = stream.peek().getPrefix();
      if (prefix != reqd_prefix)
      {
        const string message = "Element <" + stream.peek().getName() + "> should have prefix \"" + reqd_prefix + "\".";

        logError(stream, stream.peek(), InvalidMathElement, message);        
      }
    }
    stream.skipPastEnd(stream.peek());
    return;
  }
 
  const XMLToken elem = stream.next ();
  const string&  name = elem.getName();

  static const int size = sizeof(MATHML_ELEMENTS) / sizeof(MATHML_ELEMENTS[0]);

  int  index = util_bsearchStringsI(MATHML_ELEMENTS, name.c_str(), 0, size - 1);
  bool found = (index < size);

  if (!found)
  {
    logError(stream, elem, DisallowedMathMLSymbol);    
  }

  // check any reqd prefix is correct
  if (prefix_reqd)
  {
    prefix = elem.getPrefix();
    if (prefix != reqd_prefix)
    {
      const string message = "Element <" + name + "> should have prefix \"" + reqd_prefix + "\".";
      logError(stream, elem, InvalidMathElement, message);      
    }
  }

  string encoding;
  string type;
  string url;
  string units;
  string id; 
  string className;
  string style;

  elem.getAttributes().readInto( "encoding"     , encoding  );
  elem.getAttributes().readInto( "type"         , type      );
  elem.getAttributes().readInto( "definitionURL", url       );
  elem.getAttributes().readInto( "units"        , units     );
  elem.getAttributes().readInto( "id"           , id        );
  elem.getAttributes().readInto( "class"        , className );
  elem.getAttributes().readInto( "style"        , style     );

  if (!id.empty())
	  node.setId(id);

  if (!className.empty())
	  node.setClass(className);

  if (!style.empty())
	  node.setStyle(style);

  if ( !type.empty() && name != "cn")
  {
    logError(stream, elem, DisallowedMathTypeAttributeUse);    
  }

  if ( !encoding.empty() && name != "csymbol")
  {
    logError(stream, elem, DisallowedMathMLEncodingUse);    
  }

  // allow definition url on csymbol/semantics and bvar
  // and on ci in L3
  if ( !url.empty())
  {      
    SBMLNamespaces* ns = stream.getSBMLNamespaces();
    if (ns != NULL && ns->getLevel() > 2)
    {
      if (name != "csymbol" && name != "semantics" && name != "ci")
      {
        logError(stream, elem, DisallowedDefinitionURLUse);
      }
    }
    else
    {
      if (name != "csymbol" && name != "semantics")
      {
        logError(stream, elem, DisallowedDefinitionURLUse);
      }
    }

  }


  if ( !units.empty())
  {
    if (stream.getSBMLNamespaces() != NULL
      && stream.getSBMLNamespaces()->getLevel() > 2)
    {
      if (name != "cn")
      {
        logError(stream, elem, DisallowedMathUnitsUse);    
      }
    }
    else
    {
      logError(stream, elem, InvalidMathMLAttribute);
    }
  }

  if (name == "apply" || name == "lambda" || name == "piecewise")
  {
    if (name == "apply")
    {
      /* catch case where user has used <apply/> */
      if (elem.isStart() && elem.isEnd()) return;

      /* catch case where user has applied a function that
       * has no arguments 
       */
      if (elem.isEnd()) return;

      readMathML(node, stream, reqd_prefix, inRead);

      if (node.isName()) node.setType(AST_FUNCTION);

      /* there are several <apply> <...> constructs that are invalid
       * these need to caught here as they will mess up validation later
       * These are
       * <apply> <cn>
       * <apply> <true> OR <false>
       * <apply> <pi> OR <exponentiale>
       * <apply
       */
      if (node.isNumber())   
      {
        std::string message = "A number is not an operator and cannot be used ";
        message += "directly following an <apply> tag.";

        logError(stream, elem, BadMathML, message);
        
        return;

      }
      else if ((node.getType() == AST_CONSTANT_TRUE)
        || (node.getType() == AST_CONSTANT_FALSE)
        || (node.getType() == AST_CONSTANT_PI)
        || (node.getType() == AST_CONSTANT_E)
        ) 
      {
        std::string message = "<";
        message += node.getName();
        message += "> is not an operator and cannot be used directly following an";
        message += " <apply> tag.";

        logError(stream, elem, BadMathML, message);

        return;

      }
    }
    else if (name == "lambda")
    {
      node.setType(AST_LAMBDA);
    }
    else
    {
      /* catch case where there is no otherwise
       * BUT do not return if we are dealing with <piecewise/>
       */
      //if (elem.isEnd()) 
      //{
      //  //node = NULL;
      //  return;
      //}
      node.setType(AST_FUNCTION_PIECEWISE);
    }

    while (stream.isGood() && stream.peek().isEndFor(elem) == false)
    {
      /* it is possible to have a piecewise with no otherwise
       * OR a function with no arguments
       */
      stream.skipText();
      if (elem.getName() == "piecewise" 
        && stream.peek().getName() == "piecewise") continue;
      else if (stream.peek().isEndFor(elem)) continue;

      ASTNodeType_t type = node.getType();
      if (type == AST_PLUS || type == AST_TIMES) reduceBinary(node);
      if (type == AST_CONSTANT_TRUE || type == AST_CONSTANT_FALSE) break;

      ASTNode* child = new ASTNode();

      // this is catch the situation where someone has used a <math>
      // tag in the middle of the math
      bool addChild = true;
      if (stream.peek().getName() == "math" && stream.peek().isStart() == true)
      {
        std::string message = "<";
        message += stream.peek().getName();
        message += "> incorrectly used.";

        logError(stream, elem, BadMathMLNodeType, message);
        addChild = false;
      }
      readMathML(*child, stream, reqd_prefix, inRead);

      stream.skipText();
       /* look to see whether a lambda is followed by an
       * appropriate tag
       */
      if (elem.getName() == "lambda" 
        && stream.peek().getName() != "lambda"
        && stream.peek().getName() != "bvar")
      {
        if ( !isMathMLNodeTag(stream.peek().getName()))
        {
          std::string message = "<";
          message += stream.peek().getName();
          message += "> cannot be used directly following a";
          message += " <bvar> element.";

          logError(stream, elem, BadMathMLNodeType, message);
          
        }
      }

      /* it is possible to have a function that has no children
       * ie a lambda with no bvars
       * dont want to add the child since this makes it look like
       * it has a bvar
       */
      if (stream.peek().getName() == "math") 
      {
        delete child;
        break;
      }
      if (addChild == true)
      {
        node.addChild(child, true);
      }

      if (stream.peek().getName() == "piece" && stream.isGood()) 
        stream.next();
    }
  }

  else if (name == "bvar")
  {
    node.setBvar();
    readMathML(node, stream, reqd_prefix, inRead);
  }

  else if (name == "degree" || name == "logbase" ||
           name == "piece" || name == "otherwise" )
  {
    readMathML(node, stream, reqd_prefix, inRead);
    if (name == "piece") return;
  }

  else if (name == "semantics")
  {
    /* read in attributes */
    XMLAttributes tempAtt = elem.getAttributes();
    //node.setDefinitionURL(elem.getAttributes());
    readMathML(node, stream, reqd_prefix, inRead);
    node.setSemanticsFlag();
    if (tempAtt.hasAttribute("definitionURL") == true)
    {
      node.setDefinitionURL(tempAtt);
    }
    /* need to look for any annotation on the semantics element **/
    while ( stream.isGood() && !stream.peek().isEndFor(elem))
    {
      if (stream.peek().getName() == "annotation"
        || stream.peek().getName() == "annotation-xml")
      {
        XMLNode semanticAnnotation = XMLNode(stream);
        node.addSemanticsAnnotation(semanticAnnotation.clone());
      }
      else
      {
        stream.next();
      }
    }
  }
  else
  {
    setType(node, elem, stream);
  }

  checkFunctionArgs(node);

  stream.skipPastEnd(elem);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/* ---------------------------------------------------------------------- */
/*                             MathML Output                              */
/* ---------------------------------------------------------------------- */

static void writeAttributes(const ASTNode&, XMLOutputStream&);
static void writeNode      (const ASTNode&, XMLOutputStream&, SBMLNamespaces* sbmlns=NULL);
static void writeCSymbol   (const ASTNode&, XMLOutputStream&, SBMLNamespaces *sbmlns=NULL);
static void writeDouble    (const double& , XMLOutputStream&);
static void writeENotation (const double& , long, XMLOutputStream&);
static void writeENotation (const string& , const string&, XMLOutputStream&);
static void writeStartEndElement (const string&, const ASTNode&, XMLOutputStream&);
/** @endcond */

/** @cond doxygenLibsbmlInternal */
static void 
writeStartEndElement (const string& name, const ASTNode& node, XMLOutputStream& stream)
{
	stream.startElement(name);
	writeAttributes(node, stream);
	stream.endElement(name);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the mathml attributes id, class and style if set.
 */
static void 
writeAttributes(const ASTNode& node, XMLOutputStream& stream)
{
  if (node.isSetId())
    stream.writeAttribute("id", node.getId());
  if (node.isSetClass())
	  stream.writeAttribute("class", node.getClass());
  if (node.isSetStyle())
    stream.writeAttribute("style", node.getStyle());
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as a <ci> or <csymbol> element as appropriate.
 */
static void
writeCI (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  ASTNodeType_t type = node.getType();

  if (type == AST_FUNCTION_DELAY || type == AST_NAME_TIME
    || type == AST_NAME_AVOGADRO )
  {
    writeCSymbol(node, stream, sbmlns);
  }
  else if (type == AST_NAME || type == AST_FUNCTION)
  {
    stream.startElement("ci");
    stream.setAutoIndent(false);
	  writeAttributes(node, stream);
    if (node.getDefinitionURL() != NULL)
    {
      stream.writeAttribute("definitionURL", 
                            node.getDefinitionURL()->getValue(0));
    }

    if (node.getName() != NULL)
    {
      stream << " " << node.getName() << " ";
    }

    stream.endElement("ci");
    stream.setAutoIndent(true);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as <cn type="real">, <cn type='e-notation'>,
 * <cn type='integer'>, or <cn type='rational'> as appropriate.
 */
static void
writeCN (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns=NULL)
{
  if (&node == NULL || &stream == NULL) return;

  if ( node.isNaN() )
  {
	  writeStartEndElement("notanumber", node, stream);
    //stream.startEndElement("notanumber");
  }
  else if ( !(node.getType() == AST_REAL_E) && node.isInfinity() )
  {
	  writeStartEndElement("infinity", node, stream);
    //stream.startEndElement("infinity");
  }
  else if ( node.isNegInfinity() )
  {
    stream.startElement("apply");
    stream.setAutoIndent(false);
    stream << " ";
    stream.startEndElement("minus");
    stream << " ";
    writeStartEndElement("infinity", node, stream);
    stream << " ";
    stream.endElement("apply");
    stream.setAutoIndent(true);
  }
  else
  {
    stream.startElement("cn");
  	writeAttributes(node, stream);
    if (!node.getUnits().empty())
    {
      // we only write out the units iff, we don't know what namespace we 
      // have been given, or if we know that we are dealing with a L3 model
      if (sbmlns == NULL || sbmlns->getLevel() == 3)
      stream.writeAttribute("sbml:units", node.getUnits());
    }
    
    stream.setAutoIndent(false);

    if ( node.isInteger() )
    {
      static const string integer = "integer";
      stream.writeAttribute("type", integer);

      stream << " " << node.getInteger() << " ";
    }
    else if ( node.isRational() )
    {
      static const string rational = "rational";
      stream.writeAttribute("type", rational);

      stream << " " << node.getNumerator() << " ";
      stream.startEndElement("sep");
      stream << " " << node.getDenominator() << " ";
    }
    else if ( node.getType() == AST_REAL_E )
    {
      writeENotation( node.getMantissa(), node.getExponent(), stream );
    }
    else
    {
      writeDouble( node.getReal(), stream );
    }

    stream.endElement("cn");
    stream.setAutoIndent(true);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as a MathML constant.
 */
static void
writeConstant (const ASTNode& node, XMLOutputStream& stream)
{
  if (&node == NULL || &stream == NULL) return;

  switch ( node.getType() )
  {
	case AST_CONSTANT_PI:    writeStartEndElement("pi", node, stream);           break;
    case AST_CONSTANT_TRUE:  writeStartEndElement("true", node, stream);         break;
    case AST_CONSTANT_FALSE: writeStartEndElement("false", node, stream);        break;
    case AST_CONSTANT_E:     writeStartEndElement("exponentiale", node, stream); break;

 //   case AST_CONSTANT_PI:    stream.startEndElement("pi");            break;
 //   case AST_CONSTANT_TRUE:  stream.startEndElement("true");          break;
 //   case AST_CONSTANT_FALSE: stream.startEndElement("false");         break;
 //   case AST_CONSTANT_E:     stream.startEndElement("exponentiale");  break;
    default:  break;
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as a <csymbol> time or delay element as
 * appropriate.
 */
static void
writeCSymbol (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  ASTNodeType_t type = node.getType();
  string url;

       if (type == AST_FUNCTION_DELAY) url = URL_DELAY;
  else if (type == AST_NAME_TIME)      url = URL_TIME;
  else if (type == AST_NAME_AVOGADRO)  url = URL_AVOGADRO;

  stream.startElement("csymbol");
  stream.setAutoIndent(false);
  writeAttributes(node, stream);
  static const string text = "text";
  stream.writeAttribute( "encoding"     , text );
  stream.writeAttribute( "definitionURL", url  );

  stream << " " << node.getName() << " ";

  stream.endElement("csymbol");
  stream.setAutoIndent(true);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given double precision value.  This function handles the
 * special case where the value, converted to a string, contains an
 * exponent part.
 */
static void
writeDouble (const double& value, XMLOutputStream& stream)
{
  if (&value == NULL || &stream == NULL) return;

  ostringstream output;

  output.precision(LIBSBML_DOUBLE_PRECISION);
  output << value;

  string            value_string = output.str();
  string::size_type position     = value_string.find('e');

  if (position == string::npos)
  {
    stream << " " << value_string << " ";
  }
  else
  {
    const string mantissa_string = value_string.substr(0, position);
    const string exponent_string = value_string.substr(position + 1);

    double mantissa = strtod(mantissa_string.c_str(), 0);
    long   exponent = strtol(exponent_string.c_str(), 0, 10);

    writeENotation(mantissa, exponent, stream);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given mantissa and exponent.  This function handles the
 * special case where the mantissa, converted to a string, contains an
 * exponent part.
 */
static void
writeENotation (  const double&    mantissa
                , long             exponent
                , XMLOutputStream& stream )
{
  if (&mantissa == NULL || &stream == NULL) return;

  ostringstream output;

  output.precision(LIBSBML_DOUBLE_PRECISION);
  output << mantissa;

  const string      value_string = output.str();
  string::size_type position     = value_string.find('e');

  if (position != string::npos)
  {
    const string exponent_string = value_string.substr(position + 1);
    exponent += strtol(exponent_string.c_str(), NULL, 10);
  }

  output.str("");
  output << exponent;

  const string mantissa_string = value_string.substr(0, position);
  const string exponent_string = output.str();

  writeENotation(mantissa_string, exponent_string, stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given string mantissa and exponent.
 */
static void
writeENotation (  const string&    mantissa
                , const string&    exponent
                , XMLOutputStream& stream )
{
  if (&mantissa == NULL || &exponent == NULL || &stream == NULL) return;

  static const string enotation = "e-notation";
  stream.writeAttribute("type", enotation);

  stream << " " << mantissa << " ";
  stream.startEndElement("sep");
  stream << " " << exponent << " ";
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the two children of the given ASTNode.  The first child is
 * wrapped in a <logbase> element.
 */
static void
writeFunctionLog (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  if ( node.getNumChildren() > 1 )
  {
    stream.startElement("logbase");

    if ( node.getLeftChild() )  writeNode(*node.getLeftChild(), stream, sbmlns);

    stream.endElement("logbase");
  }

  if ( node.getRightChild() ) writeNode(*node.getRightChild(), stream, sbmlns);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the children of the given ASTNode.  The first child is wrapped
 * in a <degree> element.
 */
static void
writeFunctionRoot (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  if ( node.getNumChildren() > 1 )
  {
    stream.startElement("degree");

    if ( node.getLeftChild() )  writeNode(*node.getLeftChild(), stream, sbmlns);

    stream.endElement("degree");
  }
  else if (node.getNumChildren() == 1)
  {
    /* case where degree is not specified and defaults to 2 */
    writeNode(*node.getChild(0), stream);
  }

  if ( node.getRightChild() ) writeNode(*node.getRightChild(), stream, sbmlns);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as <apply> <fn/> ... </apply>.
 */
static void
writeFunction (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  ASTNodeType_t type        = node.getType();
  unsigned int  numChildren = node.getNumChildren();


  stream.startElement("apply");

  if (type >= AST_FUNCTION && type < AST_UNKNOWN)
  {
    //
    // Format function name
    //
    if (type == AST_FUNCTION)
    {
      writeCI(node, stream,sbmlns);
    }
    else if (type == AST_FUNCTION_DELAY)
    {
      writeCSymbol(node, stream,sbmlns);
    }
    else
    {
      const char* name = MATHML_FUNCTIONS[type - AST_FUNCTION_ABS];
	  writeStartEndElement(name, node, stream);
      //stream.startEndElement(name);
    }

    //
    // Format function arguments (children of this node)
    //
    if (type == AST_FUNCTION_LOG)
    {
      writeFunctionLog(node, stream, sbmlns);
    }
    else if (type == AST_FUNCTION_ROOT)
    {
      writeFunctionRoot(node, stream, sbmlns);
    }
    else
    {
      for (unsigned int c = 0; c < numChildren; c++)
      {
        writeNode(*node.getChild(c), stream, sbmlns);
      }
    }
  }

  stream.endElement("apply");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as a <lambda> element.
 */
static void
writeLambda (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  bool bodyPresent = true;
  unsigned int bvars = node.getNumChildren() - 1;
  unsigned int n = bvars;

  /* look for the case where the element is missing a body- 
   * not valid I know but it messes up roundtripping
   */
  if (node.getChild(n)->isBvar() == true)
  {
    bvars = bvars + 1;
    bodyPresent = false;
  }

  stream.startElement("lambda");

  for (n = 0; n < bvars; n++)
  {
    stream.startElement("bvar");
    writeNode(*node.getChild(n), stream, sbmlns);
    stream.endElement("bvar");
  }
  if (bodyPresent == true)
  {
    writeNode( *node.getChild(n), stream, sbmlns);
  }

  stream.endElement("lambda");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * This function formats the children of the given ASTNode and is called by
 * doOperator().
 */
static void
writeOperatorArgs (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  ASTNodeType_t type  = node.getType();
  ASTNode*      left  = node.getLeftChild();
  ASTNode*      right = node.getRightChild();
  unsigned int num = node.getNumChildren();


  //
  // AST_PLUS and AST_TIMES nodes are always binary.  MathML, however,
  // allows n-ary <plus/> and <times/> operators.
  //
  // The recursive call to doOperatorArgs() has the effect of "unrolling"
  // multiple levels of binary AST_PLUS or AST_TIMES nodes into an n-ary
  // expression.
  //

  // BUT whilst it is true that the MathML reader will always create
  // binary nodes; it is possible to create a PLUS or TIMES ASTNode with
  // more than 2 children - need to deal with this as the function
  // loses a child when written out

  if (type == AST_PLUS || type == AST_TIMES)
  {
    if (num <= 2)
    {
      // two or less children - do what we always did
      if (left != NULL)
      {
        if (left->getType() == type) writeOperatorArgs(*left, stream, sbmlns);
        else writeNode(*left, stream, sbmlns);
      }

      if (right != NULL)
      {
        if (right->getType() == type) writeOperatorArgs(*right, stream, sbmlns);
        else writeNode(*right, stream, sbmlns);
      }
    }
    else
    {
      // more than two children that might or might not be functions
      for (unsigned int n = 0; n < num; n++)
      {
        writeNode(*(node.getChild(n)), stream, sbmlns);
      }

    }

  }
  else
  {
    if (left != NULL)  writeNode(*left , stream, sbmlns);
    if (right != NULL) writeNode(*right, stream, sbmlns);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode as a <apply> <op/> ... </apply>.
 */
static void
writeOperator (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  stream.startElement("apply");

  switch ( node.getType() )
  {
    case AST_PLUS  :  writeStartEndElement( "plus"  , node, stream );  break;
    case AST_TIMES :  writeStartEndElement( "times" , node, stream );  break;
    case AST_MINUS :  writeStartEndElement( "minus" , node, stream );  break;
    case AST_DIVIDE:  writeStartEndElement( "divide", node, stream );  break;
    case AST_POWER :  writeStartEndElement( "power" , node, stream );  break;

	//case AST_PLUS  :  stream.startEndElement( "plus"   );  break;
    //case AST_TIMES :  stream.startEndElement( "times"  );  break;
    //case AST_MINUS :  stream.startEndElement( "minus"  );  break;
    //case AST_DIVIDE:  stream.startEndElement( "divide" );  break;
    //case AST_POWER :  stream.startEndElement( "power"  );  break;
    default:  break;
  }

  writeOperatorArgs(node, stream, sbmlns);

  stream.endElement("apply");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Formats the given ASTNode as a <piecewise> element.
 */
static void
writePiecewise (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  unsigned int numChildren = node.getNumChildren();
  unsigned int numPieces   = numChildren;

  //
  // An odd number of children means the last element is an <otherwise>,
  // not a <piece>
  //
  if ((numChildren % 2) != 0) numPieces--;

  stream.startElement("piecewise");

  for (unsigned int n = 0; n < numPieces; n += 2)
  {
    stream.startElement("piece");

    writeNode( *node.getChild(n)    , stream, sbmlns );
    writeNode( *node.getChild(n + 1), stream, sbmlns );

    stream.endElement("piece");
  }

  if (numPieces < numChildren)
  {
    stream.startElement("otherwise");

    writeNode( *node.getChild(numPieces), stream, sbmlns );

    stream.endElement("otherwise");
  }

  stream.endElement("piecewise");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Formats the given ASTNode as a <semantics> element.
 */
static void
writeSemantics(const ASTNode& node, XMLOutputStream& stream, bool &inSemantics, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL || &inSemantics == NULL) return;

  inSemantics = true;
  stream.startElement("semantics");
  writeAttributes(node, stream);
  if (node.getDefinitionURL())
    stream.writeAttribute("definitionURL", 
                            node.getDefinitionURL()->getValue(0));
  writeNode(node, stream, sbmlns);

  for (unsigned int n = 0; n < node.getNumSemanticsAnnotations(); n++)
  {
    stream << *node.getSemanticsAnnotation(n);
  }
  stream.endElement("semantics");
  inSemantics = false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the given ASTNode (and its children) to the XMLOutputStream as
 * MathML.
 */
static void
writeNode (const ASTNode& node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (&node == NULL || &stream == NULL) return;

  static bool inSemantics = false;
  
  if (node.getSemanticsFlag() && !inSemantics)
                     writeSemantics(node, stream, inSemantics, sbmlns);

  else if (  node.isNumber   () ) writeCN       (node, stream, sbmlns);
  else if (  node.isName     () ) writeCI       (node, stream, sbmlns);
  else if (  node.isConstant () ) writeConstant (node, stream);
  else if (  node.isOperator () ) writeOperator (node, stream, sbmlns);
  else if (  node.isLambda   () ) writeLambda   (node, stream, sbmlns);
  else if (  node.isPiecewise() ) writePiecewise(node, stream, sbmlns);
  else if ( !node.isUnknown  () ) writeFunction (node, stream, sbmlns);
}
/** @endcond */


#endif /* __cplusplus */


/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
ASTNode*
readMathML (XMLInputStream& stream, std::string reqd_prefix, bool inRead)
{
  if (&stream == NULL) return NULL;

  std::string prefix;
  bool prefix_reqd = false;
  if (!reqd_prefix.empty())
  {
    prefix_reqd = true;
  }

  stream.skipText();

  ASTNode*      node = new ASTNode;
  const string& name = stream.peek().getName();

  // check any reqd prefix is correct
  if (prefix_reqd)
  {
    prefix = stream.peek().getPrefix();
    if (prefix != reqd_prefix)
    {
      const string message = "Element <" + name + "> should have prefix \"" + reqd_prefix + "\".";

      logError(stream, stream.peek(), InvalidMathElement, message);
      
    }
  }


  /* this code is slightly redundant as you will only
   * get here if the name is "math"
   * but does serve as a catch
   */
  if (name == "math")
  {
    const XMLToken elem = stream.next();
      
    if (elem.isStart() && elem.isEnd()) return node;

    /* check that math tag is followed by an appropriate
     * tag
     */
    stream.skipText();
    const string& name1 = stream.peek().getName();

    // check any reqd prefix is correct
    if (prefix_reqd)
    {
      prefix = stream.peek().getPrefix();
      if (prefix != reqd_prefix)
      {
        const string message = "Element <" + name1 + "> should have prefix \"" + reqd_prefix + "\".";

        logError(stream, stream.peek(), InvalidMathElement, message);       
      }
    }
    if ( isMathMLNodeTag(name1) || name1 == "lambda")
    {
      readMathML(*node, stream, reqd_prefix, inRead);
    }
    else
    {
        std::string message = "<";
        message += name1;
        message += "> cannot be used directly following a";
        message += " <math> tag.";

        logError(stream, stream.peek(), BadMathMLNodeType, message);      
    }

    stream.skipPastEnd(elem);
  }
  else if (name == "apply" )
  {
    const XMLToken elem = stream.next();
      
    if (elem.isStart() && elem.isEnd()) return node;

    readMathML(*node, stream, reqd_prefix, inRead);
    stream.skipPastEnd(elem);
  }
  else
  {
    readMathML(*node, stream, reqd_prefix, inRead);
  }

  return node;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
LIBSBML_EXTERN
void
writeMathML (const ASTNode* node, XMLOutputStream& stream, SBMLNamespaces *sbmlns)
{
  if (node == NULL || &stream == NULL) return;

  static const string uri = "http://www.w3.org/1998/Math/MathML";

  stream.startElement("math");
  stream.writeAttribute("xmlns", uri);

  if (node) 
  {
	// FIX-ME need to know what level and version
	if (node->hasUnits())
	{
    if (sbmlns == NULL || sbmlns->getLevel() == 3)
		stream.writeAttribute(XMLTriple("sbml", "", "xmlns"), 
		                   SBMLNamespaces::getSBMLNamespaceURI(3,1));
	}
	
	writeNode(*node, stream,sbmlns);
  }

  stream.endElement("math");
}
/** @endcond */

/* ---------------------------------------------------------------------- */
/*                           Public Functions                             */
/* ---------------------------------------------------------------------- */


/**
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
readMathMLFromString (const char *xml)
{
  if (xml == NULL) return NULL;

  bool needDelete = false;

  const char* dummy_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
  const char* xmlstr_c;
  
  if (!strncmp(xml, dummy_xml, 14))
  {
    xmlstr_c = xml;
  }
  else
  {
    std::ostringstream oss;
    const char* dummy_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

    oss << dummy_xml;
    oss << xml;


    xmlstr_c = safe_strdup(oss.str().c_str());
    needDelete = true;
  }

  XMLInputStream stream(xmlstr_c, false);
  SBMLErrorLog   log;

  stream.setErrorLog(&log);
  SBMLNamespaces sbmlns;
  stream.setSBMLNamespaces(&sbmlns);

  ASTNode_t* ast = readMathML(stream);
  
  if (needDelete == true)
  {
    safe_free((void *)(xmlstr_c));
  }
  if (log.getNumErrors() > 0)
  {
    delete ast;
    return NULL;
  }

  return ast;
}


/**
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
writeMathMLToString (const ASTNode* node)
{
  ostringstream   os;
  XMLOutputStream stream(os);

  char * result = NULL;

  if (node != NULL)
  {
    writeMathML(node, stream);
    result = safe_strdup( os.str().c_str() );
  }

  return result;
}

LIBSBML_EXTERN
std::string
writeMathMLToStdString (const ASTNode* node)
{
  ostringstream   os;
  XMLOutputStream stream(os);

  if (node != NULL)
  {
    writeMathML(node, stream);
    return os.str();
  }
  else
  {
    return "";
  }
}



/** @endcond */

LIBSBML_CPP_NAMESPACE_END
