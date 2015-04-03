/**
 * @cond doxygenLibsbmlInternal
 *
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

#include <sbml/math/ASTTypes.h>
#include <sbml/util/util.h>
#include <sbml/extension/ASTBasePlugin.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */


LIBSBML_CPP_NAMESPACE_BEGIN

static const int MATHML_TYPES[] =
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
  , AST_QUALIFIER_BVAR
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
  , AST_QUALIFIER_DEGREE
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
  , AST_QUALIFIER_LOGBASE
  , AST_RELATIONAL_LT
  , AST_UNKNOWN
  , AST_MINUS
  , AST_RELATIONAL_NEQ
  , AST_LOGICAL_NOT
  , AST_REAL
  , AST_LOGICAL_OR
  , AST_CONSTRUCTOR_OTHERWISE
  , AST_CONSTANT_PI
  , AST_CONSTRUCTOR_PIECE
  , AST_FUNCTION_PIECEWISE
  , AST_PLUS
  , AST_FUNCTION_POWER
  , AST_FUNCTION_ROOT
  , AST_FUNCTION_SEC
  , AST_FUNCTION_SECH
  , AST_SEMANTICS
  , AST_UNKNOWN
  , AST_FUNCTION_SIN
  , AST_FUNCTION_SINH
  , AST_FUNCTION_TAN
  , AST_FUNCTION_TANH
  , AST_TIMES
  , AST_CONSTANT_TRUE
  , AST_LOGICAL_XOR
};

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



LIBSBML_EXTERN
bool representsNumber(int type)
{
  bool valid = false;

  switch (type)
  {
    case AST_INTEGER:
    case AST_REAL:
    case AST_REAL_E:
    case AST_RATIONAL:

    case AST_NAME_AVOGADRO:
    case AST_NAME_TIME:

    case AST_CONSTANT_E:
    case AST_CONSTANT_PI:

    case AST_NAME:

      // for now !!
    case AST_CONSTANT_FALSE:
    case AST_CONSTANT_TRUE:
      valid = true;
      break;
    default:
      break;

  }
  return valid;
}


LIBSBML_EXTERN
bool representsFunction(int type, ASTBasePlugin* plugin)
{
  bool valid = false;

  if (representsUnaryFunction(type, plugin) == true
    || representsBinaryFunction(type, plugin) == true
    || representsNaryFunction(type, plugin) == true
    || representsFunctionRequiringAtLeastTwoArguments(type) == true
    || type == AST_MINUS)
  {
    valid = true;
  }

  return valid;
}
LIBSBML_EXTERN
bool representsUnaryFunction(int type, ASTBasePlugin* plugin)
{
  bool valid = false;

  switch (type)
  {
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
    case AST_FUNCTION_EXP:
    case AST_FUNCTION_FACTORIAL:
    case AST_FUNCTION_FLOOR:
    case AST_FUNCTION_LN:
    case AST_FUNCTION_SEC:
    case AST_FUNCTION_SECH:
    case AST_FUNCTION_SIN:
    case AST_FUNCTION_SINH:
    case AST_FUNCTION_TAN:
    case AST_FUNCTION_TANH:

    case AST_LOGICAL_NOT:

      valid = true;
      break;
    default:
      break;

  }

  if (valid == false && plugin != NULL)
  {
    if (plugin->representsUnaryFunction(type) == true)
    {
      valid = true;
    }
  }

  return valid;
}


LIBSBML_EXTERN
bool representsBinaryFunction(int type, ASTBasePlugin* plugin)
{
  bool valid = false;

  switch (type)
  {
    case AST_DIVIDE:
    case AST_POWER:

    case AST_FUNCTION_DELAY:
    case AST_FUNCTION_POWER:

    case AST_RELATIONAL_NEQ:
  
    // hack to replicate old behaviour
    case AST_FUNCTION_LOG:       // a log may or may not have a base
      valid = true;
      break;
    default:
      break;

  }

  if (valid == false && plugin != NULL)
  {
    if (plugin->representsBinaryFunction(type) == true)
    {
      valid = true;
    }
  }
  return valid;
}


LIBSBML_EXTERN
bool representsNaryFunction(int type, ASTBasePlugin* plugin)
{
  bool valid = false;

  switch (type)
  {
    case AST_TIMES:
    case AST_PLUS:
    case AST_LOGICAL_AND:
    case AST_LOGICAL_OR:
    case AST_LOGICAL_XOR:

    // put these here for now
      // they require at least 2 arguments
    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_GEQ:
    case AST_RELATIONAL_GT:
    case AST_RELATIONAL_LEQ:
    case AST_RELATIONAL_LT:

    case AST_MINUS:
    case AST_FUNCTION_ROOT:      // a root may or may not have a degree
    //case AST_FUNCTION_LOG:       // a log may or may not have a base
      valid = true;
      break;
    default:
      break;

  }

  if (valid == false && plugin != NULL)
  {
    if (plugin->representsNaryFunction(type) == true)
    {
      valid = true;
    }
  }
  return valid;
}


LIBSBML_EXTERN
bool representsQualifier(int type, ASTBasePlugin* plugin)
{
  bool valid = false;

  switch (type)
  {
    case AST_QUALIFIER_BVAR:
    case AST_QUALIFIER_LOGBASE:
    case AST_QUALIFIER_DEGREE:
    case AST_CONSTRUCTOR_PIECE:
    case AST_CONSTRUCTOR_OTHERWISE:

      valid = true;
      break;
    default:
      break;

  }

  if (valid == false && plugin != NULL)
  {
    if (plugin->representsQualifier(type) == true)
    {
      valid = true;
    }
  }
  return valid;
}


LIBSBML_EXTERN
bool representsFunctionRequiringAtLeastTwoArguments(int type)
{
  bool valid = false;

  switch (type)
  {
    case AST_RELATIONAL_EQ:
    case AST_RELATIONAL_GEQ:
    case AST_RELATIONAL_GT:
    case AST_RELATIONAL_LEQ:
    case AST_RELATIONAL_LT:
      valid = true;
      break;
    default:
      break;

  }

  return valid;
}


bool
isCoreTopLevelMathMLFunctionNodeTag(const std::string& name)
{
  if (&name == NULL) 
  {
    return false;
  }

  if ( name == "apply"
    || name == "lambda"
    || name == "semantics"
    || name == "piecewise")
  {
    return true;
  }
  else if (representsQualifier(getCoreTypeFromName(name)) == true)
  {
    return true;
  }
  else
  {
    return false;
  }
}


bool
isCoreTopLevelMathMLNumberNodeTag(const std::string& name)
{
  if (&name == NULL) 
  {
    return false;
  }

  if ( name == "cn"
    || name == "ci"
    || name == "csymbol"
    || name == "true"
    || name == "false"
    || name == "notanumber"
    || name == "pi"
    || name == "infinity"
    || name == "exponentiale")
  {
    return true;
  }
  else
  {
    return false;
  }
}


int 
getCoreTypeFromName(const std::string& name)
{
  int type = AST_UNKNOWN;
  static const int size = sizeof(MATHML_ELEMENTS) / sizeof(MATHML_ELEMENTS[0]);

  int  index = util_bsearchStringsI(MATHML_ELEMENTS, name.c_str(), 0, size - 1);

  if (index < size)
  {
    type = MATHML_TYPES[index];
  }

  return type;
}


const char*
getNameFromCoreType(int type)
{
  const char* name = "";
  if (type == AST_UNKNOWN
    || type == AST_FUNCTION)
  {
    // do nothing
  }
  else if (type <= AST_NAME_TIME)
  {
    switch (type)
    {
    case AST_PLUS:
      name = "plus";
      break;
    case AST_MINUS:
      name = "minus";
      break;
    case AST_TIMES:
      name = "times";
      break;
    case AST_DIVIDE:
      name = "divide";
      break;
    case AST_POWER:
      name = "power";
      break;
    }
  }
  else if (type == AST_FUNCTION_DELAY)
  {
    name = "delay";
  }
  else
  {

    if (type < AST_UNKNOWN)
    {
      bool found = false;
      static const int size = sizeof(MATHML_ELEMENTS) / sizeof(MATHML_ELEMENTS[0]);
      unsigned int i;
      for (i = 0; i < size && found == false; i++)
      {
        if (type == MATHML_TYPES[i])
          found = true;
      }
      if (found == true)
      {
        name = MATHML_ELEMENTS[i-1];
      }
    }
  }

  return name;
}


/** @endcond */


LIBSBML_CPP_NAMESPACE_END
