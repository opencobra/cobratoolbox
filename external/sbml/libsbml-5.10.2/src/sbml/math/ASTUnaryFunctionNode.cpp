/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTUnaryFunctionNode.cpp
 * @brief   UnaryFunction Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTUnaryFunctionNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTUnaryFunctionNode::ASTUnaryFunctionNode (int type) :
  ASTFunctionBase(type)
{
}
  

/**
 * Copy constructor
 */
ASTUnaryFunctionNode::ASTUnaryFunctionNode (const ASTUnaryFunctionNode& orig):
  ASTFunctionBase(orig)
{
}

/**
 * Assignment operator for ASTNode.
 */
ASTUnaryFunctionNode&
ASTUnaryFunctionNode::operator=(const ASTUnaryFunctionNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTFunctionBase::operator =(rhs);
  }
  return *this;
}


/**
 * Destroys this ASTNode, including any child nodes.
 */
ASTUnaryFunctionNode::~ASTUnaryFunctionNode ()
{
}


int
ASTUnaryFunctionNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_UNARY;
}


/**
 * Creates a copy (clone).
 */
ASTUnaryFunctionNode*
ASTUnaryFunctionNode::deepCopy () const
{
  return new ASTUnaryFunctionNode(*this);
}


int
ASTUnaryFunctionNode::swapChildren(ASTFunction* that)
{
  if (that->getUnaryFunction() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getUnaryFunction());
  }
  else if (that->getBinaryFunction() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getBinaryFunction());
  }
  else if (that->getNaryFunction() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getNaryFunction());
  }
  else if (that->getUserFunction() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getUserFunction());
  }
  else if (that->getLambda() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getLambda());
  }
  else if (that->getPiecewise() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getPiecewise());
  }
  else if (that->getCSymbol() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getCSymbol()->getDelay());;
  }
  else if (that->getQualifier() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getQualifier());
  }
  else if (that->getSemantics() != NULL)
  {
    return ASTFunctionBase::swapChildren(that->getSemantics());
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


bool
ASTUnaryFunctionNode::isLog10() const
{
  bool valid = false;

  if (getType() == AST_FUNCTION_LOG)
  {
    if (getNumChildren() == 1)
    {
      ASTBase * base1 = getChild(0);
      if (base1->isQualifier() == false)
      {
        valid = true;
      }
    }
  }

  return valid;
}


bool
ASTUnaryFunctionNode::isSqrt() const
{
  bool valid = false;

  if (getType() == AST_FUNCTION_ROOT)
  {
    if (getNumChildren() == 1)
    {
      ASTBase * base1 = getChild(0);
      if (base1->isQualifier() == false)
      {
        valid = true;
      }
    }
  }

  return valid;
}


void
ASTUnaryFunctionNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  stream.startElement("apply");
    
  //const char * name = ASTBase::getNameFromType(type);
  		
  ASTBase::writeStartEndElement(stream);

  /* write the one child
   * note we expect to have one child but cannot guarantee it 
   */
   
  unsigned int numChildren = getNumChildren();

  /* HACK TO REPLICATE OLD AST */
  /* for log 10 write out the logbase explicilty
   * for sqrt write out the degree explicilty
   * NOTE the qualifier node will add the necessary integers
   */
  if (numChildren == 1)
  {
    if (isLog10() == true)
    {
      ASTQualifierNode * logbase = new ASTQualifierNode(AST_QUALIFIER_LOGBASE);
      logbase->write(stream);
      delete logbase;
    }
    else if (isSqrt() == true)
    {
      ASTQualifierNode * degree = new ASTQualifierNode(AST_QUALIFIER_DEGREE);
      degree->write(stream);
      delete degree;
    }

    ASTFunctionBase::getChild(0)->write(stream);
  }
  else
  {
    for (unsigned int n = 0; n < numChildren; n++)
    {
      ASTFunctionBase::getChild(n)->write(stream);
    }
  }

  stream.endElement("apply");
}

bool
ASTUnaryFunctionNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  ASTBase * child = NULL;
  const XMLToken element = stream.peek ();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  const char*      name = element.getName().c_str();

  setType(getTypeFromName(name));
  ASTBase::read(stream, reqd_prefix);

  unsigned int numChildrenAdded = 0;

  if (getExpectedNumChildren() > 0)
  {
    while (stream.isGood() && numChildrenAdded < getExpectedNumChildren())
    {
      stream.skipText();

      name = stream.peek().getName().c_str();

      if (representsNumber(ASTBase::getTypeFromName(name)) == true)
      {
        child = new ASTNumber();
      }
      else 
      {
        child = new ASTFunction();
      }

      read = child->read(stream, reqd_prefix);

      stream.skipText();

      if (read == true && addChild(child) == LIBSBML_OPERATION_SUCCESS)
      {
        numChildrenAdded++;
      }
      else
      {
        read = false;
        break;
      }
    }
  }
  else
  {
    stream.skipPastEnd(element);
    read = true;
  }

  return read;
}


bool 
ASTUnaryFunctionNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = true;

  if (getNumChildren() != 1)
  {
    correctNumArgs = false;
  }

  return correctNumArgs;
}




LIBSBML_CPP_NAMESPACE_END


/** @endcond */

