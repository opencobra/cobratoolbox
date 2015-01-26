/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTQualifierNode.cpp
 * @brief   Base Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTQualifierNode.h>
#include <sbml/math/ASTNaryFunctionNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTQualifierNode::ASTQualifierNode (int type) :
  ASTFunctionBase(type)

{
  ASTFunctionBase::setType(type);
}
  
  
  /**
   * Copy constructor
   */
ASTQualifierNode::ASTQualifierNode (const ASTQualifierNode& orig):
  ASTFunctionBase(orig)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTQualifierNode&
ASTQualifierNode::operator=(const ASTQualifierNode& rhs)
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
ASTQualifierNode::~ASTQualifierNode ()
{
}

int
ASTQualifierNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_QUALIFIER;
}


  /**
   * Creates a copy (clone).
   */
ASTQualifierNode*
ASTQualifierNode::deepCopy () const
{
  return new ASTQualifierNode(*this);
}

  
int
ASTQualifierNode::addChild(ASTBase* child, bool inRead)
{
  return ASTFunctionBase::addChild(child);
}


int
ASTQualifierNode::swapChildren(ASTFunction* that)
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



void
ASTQualifierNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  const char * name = ASTBase::getNameFromType(getExtendedType());
  
  ASTBase::writeStartElement(stream);

  int type = getExtendedType();
  /* HACK TO REPLICATE OLD AST */
  /* old ast behaviour would only write one child 
   * for a qualifier degree/logbase/bvar
   * always the first child
   * but most other things do write any children they have 
   * (whether valid or not)
   */
  if (getNumChildren() > 0)
  {
    if (type == AST_CONSTRUCTOR_PIECE)
    {
      for (unsigned int i = 0; i < getNumChildren(); i++)
      {
        getChild(i)->write(stream);
      }
    }
    else
    {
      ASTFunctionBase::getChild(0)->write(stream);
    }
  }
  else
  {
  /* HACK TO REPLICATE OLD AST */
  /* logbase reverts to base 10
   * degree reverts to 2
   */
    if (type == AST_QUALIFIER_LOGBASE)
    {
      ASTCnIntegerNode * int10 = new ASTCnIntegerNode(AST_INTEGER);
      int10->setInteger(10);
      int10->write(stream);
      delete int10;
    }
    else if (type == AST_QUALIFIER_DEGREE)
    {
      ASTCnIntegerNode * int2 = new ASTCnIntegerNode(AST_INTEGER);
      int2->setInteger(2);
      int2->write(stream);
      delete int2;
    }
  }

  stream.endElement(name);
}

bool
ASTQualifierNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
   const XMLToken element = stream.peek ();
 
  /* note here we have already consumed the name of the qualifier
   * and are only looking at children
   */

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  ASTBase * child = NULL;
  const char*      name;

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
    stream.skipText();
    read = true;
  }

  return read;
}




bool 
ASTQualifierNode::hasCorrectNumberArguments() const
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

