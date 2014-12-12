/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTNaryFunctionNode.cpp
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

#include <sbml/math/ASTNaryFunctionNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTNode.h>
#include <sbml/extension/ASTBasePlugin.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTNaryFunctionNode::ASTNaryFunctionNode (int type) :
  ASTFunctionBase(type)
    , mReducedToBinary (false)
{
}
  

  /**
   * Copy constructor
   */
ASTNaryFunctionNode::ASTNaryFunctionNode (const ASTNaryFunctionNode& orig):
  ASTFunctionBase(orig)
    , mReducedToBinary (orig.mReducedToBinary)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTNaryFunctionNode&
ASTNaryFunctionNode::operator=(const ASTNaryFunctionNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTFunctionBase::operator =(rhs);
    mReducedToBinary = rhs.mReducedToBinary;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTNaryFunctionNode::~ASTNaryFunctionNode ()
{
}

int
ASTNaryFunctionNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_NARY;
}


  /**
   * Creates a copy (clone).
   */
ASTNaryFunctionNode*
ASTNaryFunctionNode::deepCopy () const
{
  return new ASTNaryFunctionNode(*this);
}

int
ASTNaryFunctionNode::swapChildren(ASTFunction* that)
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
    return ASTFunctionBase::swapChildren(that->getCSymbol()->getDelay());
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


ASTBase* 
ASTNaryFunctionNode::getChild (unsigned int n) const
{
  if (this->getType() != AST_FUNCTION_ROOT)
  {
    return ASTFunctionBase::getChild(n);
  }
  else
  {
    /* HACK TO REPLICATE OLD AST */
    /* do not return a node with the degree type
     * return the child of the degree
     */
    if (ASTFunctionBase::getNumChildren() <= n)
    {
      return NULL;
    }

    if (ASTFunctionBase::getChild(n)->getType() == AST_QUALIFIER_DEGREE)
    {
      ASTBase * base = ASTFunctionBase::getChild(n);
      ASTNode * degree = dynamic_cast<ASTNode*>(base);
      if (degree != NULL)
      {
        if (degree->getNumChildren() > 0)
        {
          return degree->getChild(0);
        }
        else
        {
          return NULL;
        }
      }
      else
      {
        return NULL;
      }
    }
    else
    {
      return ASTFunctionBase::getChild(n);
    }
  }
}



bool
ASTNaryFunctionNode::isUMinus() const
{
  bool isUMinus = false;

  if (getType() == AST_MINUS && getNumChildren() == 1)
  {
    isUMinus = true;
  }

  return isUMinus;
}


bool
ASTNaryFunctionNode::isUPlus() const
{
  bool isUPlus = false;

  if (getType() == AST_PLUS && getNumChildren() == 1)
  {
    isUPlus = true;
  }

  return isUPlus;
}


bool
ASTNaryFunctionNode::isLog10() const
{
  bool valid = false;

  if (getType() == AST_FUNCTION_LOG)
  {
    // a log can have either one child that is not the logbase qualifier
    // or two where the first is the logbase of 10
    if (getNumChildren() == 1)
    {
      ASTBase * base1 = ASTFunctionBase::getChild(0);
      if (base1->isQualifier() == false)
      {
        valid = true;
      }
    }
    else if (getNumChildren() == 2)
    {
      ASTBase * base1 = ASTFunctionBase::getChild(0);
      ASTFunction* fun = dynamic_cast<ASTFunction*>(base1);
      if (fun != NULL)
      {
        if (fun->getType() == AST_QUALIFIER_LOGBASE
          && fun->getNumChildren() == 1)
        {
          ASTBase *base2 = fun->getChild(0);
          if (base2->getType() == AST_INTEGER)
          {
            ASTNumber *child = static_cast<ASTNumber*>(base2);
            if (child->getInteger() == 10)
            {
              valid = true;
            }
          }
        }
      }
      else
      {
        // here we are working the ASTNode so the casting
        // is more difficult

        ASTNode* newAST = dynamic_cast<ASTNode*>(base1);
        if (newAST != NULL && newAST->getType() == AST_QUALIFIER_LOGBASE
          && newAST->getNumChildren() == 1 )
        {
          ASTNode* newAST1 = newAST->getChild(0);
          if (newAST1->getType() == AST_INTEGER)
          {
            if (newAST1->getInteger() == 10)
            {
              valid = true;
            }
          }
        }
        else
        {
          if (newAST != NULL && newAST->getType() == AST_INTEGER)
          {
            if (newAST->getInteger() == 10)
            {
              valid = true;
            }
          }
        }

      }
    }
  }

  return valid;
}


bool
ASTNaryFunctionNode::isSqrt() const
{
  bool valid = false;

  if (getType() == AST_FUNCTION_ROOT)
  {
    // a sqrt can have either one child that is not the degree qualifier
    // or two where the first is the degree of 2
    if (getNumChildren() == 1)
    {
      /* HACK to replicate OLD AST whic says a sqrt must have two children*/
      valid = false;
      //ASTBase * base1 = getChild(0);
      //if (base1->isQualifier() == false)
      //{
      //  valid = true;
      //}
    }
    else if (getNumChildren() == 2)
    {
      ASTBase * base1 = ASTFunctionBase::getChild(0);
      ASTFunction* fun = dynamic_cast<ASTFunction*>(base1);
      if (fun != NULL)
      {
        if (fun->getType() == AST_QUALIFIER_DEGREE 
          && fun->getNumChildren() == 1)
        {
          ASTBase *base2 = fun->getChild(0);
          if (base2->getType() == AST_INTEGER)
          {
            ASTNumber *child = static_cast<ASTNumber*>(base2);
            if (child->getInteger() == 2)
            {
              valid = true;
            }
          }
        }
      }
      else
      {
        // here we are working the ASTNode so the casting
        // is more difficult

        ASTNode* newAST = dynamic_cast<ASTNode*>(base1);
        if (newAST != NULL && newAST->getType() == AST_QUALIFIER_DEGREE
          && newAST->getNumChildren() == 1)
        {
          ASTNode* newAST1 = newAST->getChild(0);
          if (newAST1->getType() == AST_INTEGER)
          {
            if (newAST1->getInteger() == 2)
            {
              valid = true;
            }
          }
        }
        else
        {
          if (newAST != NULL && newAST->getType() == AST_INTEGER)
          {
            if (newAST->getInteger() == 2)
            {
              valid = true;
            }
          }
        }
      }
    }
  }

  return valid;
}


void
ASTNaryFunctionNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  int type  = getType();
  unsigned int numChildren = getNumChildren();

  if (numChildren <= 2 && (type == AST_PLUS || type == AST_TIMES))
  {
    writeNodeOfType(stream, type);
  }
  else if (type == AST_UNKNOWN && numChildren == 0)
  {
    // we have an empty apply tag
    stream.startEndElement("apply");
  }
  else
  {

    stream.startElement("apply");
      
    //const char * name = ASTBase::getNameFromType(type);
    		
    ASTBase::writeStartEndElement(stream);
      
      /* write children */
     

    /* HACK TO REPLICATE OLD AST */
    /* for log/root with two or more children assume first is logbase/degree
     * and last is the value operated on
     * 
     * however if the node is read in with a logbase and then more than
     * further children it uses the first as the value operated on
     */
    if (type == AST_FUNCTION_ROOT)
    {
      if (numChildren > 1)
      {
        if (ASTFunctionBase::getChild(0)->getType() != AST_QUALIFIER_DEGREE)
        {
          ASTQualifierNode * logbase = new ASTQualifierNode(AST_QUALIFIER_DEGREE);
          logbase->addChild(ASTFunctionBase::getChild(0)->deepCopy());
          logbase->write(stream);
          delete logbase;
          ASTFunctionBase::getChild(numChildren-1)->write(stream);
        }
        else
        {
          /* if there is only 1 child that is logbase we dont write either */
          ASTFunctionBase::getChild(0)->write(stream);
          ASTFunctionBase::getChild(numChildren-1)->write(stream);
        }
      }
      else
      {
        ASTFunctionBase::getChild(0)->write(stream);
      }
    }
    else
    {
      for (unsigned int i = 0; i < ASTFunctionBase::getNumChildren(); i++)
      {
        ASTFunctionBase::getChild(i)->write(stream);
      }
    }
    stream.endElement("apply");
  }
}


void
ASTNaryFunctionNode::writeNodeOfType(XMLOutputStream& stream, int type, 
                                     bool inChildNode) const
{
  if (inChildNode == false)
  {
    stream.startElement("apply");
      
    ASTBase::writeStartEndElement(stream);
  }
      

  unsigned int numChildren = getNumChildren();

  {
    for (unsigned int i = 0; i < numChildren; i++)
    {
      if (ASTFunctionBase::getChild(i)->getType() == type)
      {
        ASTFunction* fun = dynamic_cast<ASTFunction*>(ASTFunctionBase::getChild(i));
        if (fun != NULL)
        {
          fun->writeNodeOfType(stream, type, true);
        }
        else
        {
          ASTNode* newAST = dynamic_cast<ASTNode*>(ASTFunctionBase::getChild(i));
          if (newAST != NULL)
          {
            newAST->writeNodeOfType(stream, type, true);
          }
        }
      }
      else
      {
        ASTFunctionBase::getChild(i)->write(stream);
      }
    }
  }
  
  if (inChildNode == false)
  {
    stream.endElement("apply");
  }
}


bool
ASTNaryFunctionNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  ASTBase * child = NULL;
  const XMLToken element = stream.peek ();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  const char*      name = element.getName().c_str();

  int type = getTypeFromName(name);
  setType(type);
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

  if (read == true && type == AST_FUNCTION_ROOT 
    && getExpectedNumChildren() == 1 
    && ASTFunctionBase::getChild(0)->getType() != AST_QUALIFIER_DEGREE)
  {
    /* HACK TO REPLICATE OLD BEHAVIOUR */
    /* we need to add the qualifier child for the degree 2 */
    ASTFunction * degree = new ASTFunction(AST_QUALIFIER_DEGREE);
    ASTNumber * int2 = new ASTNumber(AST_INTEGER);
    int2->setInteger(2);
    degree->addChild(int2->deepCopy());
    this->prependChild(degree->deepCopy());
    delete int2;
    delete degree;

  }

  //if (read == false)
  //{
  //  stream.skipPastEnd(element);
  //}

  return read;
}


bool 
ASTNaryFunctionNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = true;

  int type = getType();
  unsigned int numChildren = getNumChildren();

  // look at specific types that have odd requirements
  // based on being backward compatible or having different numbers
  // of required children
  if (type == AST_MINUS)
  {
    if (numChildren < 1 || numChildren > 2)
    {
      correctNumArgs = false;
    }
  }
  else if (type == AST_FUNCTION_ROOT)
  {
    if (numChildren < 1 || numChildren > 2)
    {
      correctNumArgs = false;
    }
    else if (numChildren == 1)
    {
      // we have only one child
      // if it is a qualifier type then it is incorrect
      if (representsQualifier(ASTFunctionBase::getChild(0)->getType()) == true)
      {
        correctNumArgs = false;
      }
    }
  }
  else if (representsFunctionRequiringAtLeastTwoArguments(type) == true
    && numChildren < 2)
  {
    correctNumArgs = false;
  }
  else if (type == AST_ORIGINATES_IN_PACKAGE)
  {
    correctNumArgs = 
      getPlugin(getPackageName())->hasCorrectNumberArguments(getExtendedType());
  }

  return correctNumArgs;
}


void
ASTNaryFunctionNode::reduceOperatorsToBinary()
{
  unsigned int numChildren = getNumChildren();
  /* number of children should be greater than 2 */
  if (numChildren < 3)
    return;

  /* only work with times and plus */
  int type = getType();
  if (type != AST_TIMES && type != AST_PLUS)
    return;


  ASTFunction* op = new ASTFunction( getExtendedType() );
  ASTFunction* op2 = new ASTFunction( getExtendedType() );

  // add the first two children to the first node
  op->addChild(getChild(0));
  op->addChild(getChild(1));

  op2->addChild(op);

  for (unsigned int n = 2; n < numChildren; n++)
  {
    op2->addChild(getChild(n));
  }

  swapChildren(op2);

  // valgrind says we are leaking a lot of memory here 
  // but we cannot delete op2 since its children are the children of the
  // current element
  // neither addChild not swapChildren make copies of things

  // we could remove the children and delete the object
  // removeChild does not destroy the object
  // merely removes it from the mChildren vector
  unsigned int i = op2->getNumChildren();
  while (i > 0)
  {
    op2->removeChild(i-1);
    i--;
  }

  delete op2;

  setReducedToBinary(true);

  reduceOperatorsToBinary();
}


void
ASTNaryFunctionNode::setReducedToBinary(bool reduced)
{
  mReducedToBinary = reduced;
}


bool
ASTNaryFunctionNode::getReducedToBinary() const
{
  return mReducedToBinary;
}
LIBSBML_CPP_NAMESPACE_END


/** @endcond */

