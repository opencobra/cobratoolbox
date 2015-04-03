/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTBinaryFunctionNode.cpp
 * @brief   BinaryFunction Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTBinaryFunctionNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTQualifierNode.h>
#include <sbml/math/ASTNode.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTBinaryFunctionNode::ASTBinaryFunctionNode (int type) :
  ASTFunctionBase(type)
{
}
  

/**
 * Copy constructor
 */
ASTBinaryFunctionNode::ASTBinaryFunctionNode (const ASTBinaryFunctionNode& orig):
  ASTFunctionBase(orig)
{
}

/**
 * Assignment operator for ASTNode.
 */
ASTBinaryFunctionNode&
ASTBinaryFunctionNode::operator=(const ASTBinaryFunctionNode& rhs)
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
ASTBinaryFunctionNode::~ASTBinaryFunctionNode ()
{
}


int
ASTBinaryFunctionNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_BINARY;
}


/**
 * Creates a copy (clone).
 */
ASTBinaryFunctionNode*
ASTBinaryFunctionNode::deepCopy () const
{
  return new ASTBinaryFunctionNode(*this);
}

int
ASTBinaryFunctionNode::swapChildren(ASTFunction* that)
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


ASTBase* 
ASTBinaryFunctionNode::getChild (unsigned int n) const
{
  if (this->getType() != AST_FUNCTION_LOG)
  {
    return ASTFunctionBase::getChild(n);
  }
  else
  {
    /* HACK TO REPLICATE OLD AST */
    /* do not return a node with the logbase type
     * return the child of the logbase
     */
    if (ASTFunctionBase::getNumChildren() <= n)
    {
      return NULL;
    }

    if (ASTFunctionBase::getChild(n)->getType() == AST_QUALIFIER_LOGBASE)
    {
      ASTBase * base = ASTFunctionBase::getChild(n);
      ASTNode * logbase = dynamic_cast<ASTNode*>(base);
      if (logbase != NULL)
      {
        if (logbase->getNumChildren() > 0)
        {
          return logbase->getChild(0);
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




int 
ASTBinaryFunctionNode::removeChild (unsigned int n)
{
  int removed = LIBSBML_OPERATION_FAILED;
  if (this->getType() != AST_FUNCTION_LOG)
  {
    removed = ASTFunctionBase::removeChild(n);
  }
  else
  {
   /* HACK TO REPLICATE OLD AST */
   /* Hack to remove memory since the overall
     * remove does not remove memory
     * but the  old api does not give access to the new
     * intermediate parents so these can never
     * be explicilty deleted by the user
     *
     * in this case the first remove is accessible
     */
    if (ASTFunctionBase::getChild(n)->getType() == AST_QUALIFIER_LOGBASE)
    {
      ASTBase * base = ASTFunctionBase::getChild(n);
      ASTNode * logbase = dynamic_cast<ASTNode*>(base);
      if (logbase != NULL && logbase->getNumChildren() == 1)
      {
        removed = logbase->removeChild(0);
        if (removed == LIBSBML_OPERATION_SUCCESS)
        {    
          ASTBase * removedAST = NULL;
          removedAST = this->ASTFunctionBase::getChild(n);
          removed = ASTFunctionBase::removeChild(n);
          if (removedAST != NULL) delete removedAST;
        }
      }
    }
    else
    {
      removed = ASTFunctionBase::removeChild(n);
    }
  }

  return removed;
}


bool
ASTBinaryFunctionNode::isLog10() const
{
  bool valid = false;

  ASTBase * base1 = NULL;

  if (getType() == AST_FUNCTION_LOG)
  {
    if (getNumChildren() == 2)
    {
      base1 = ASTFunctionBase::getChild(0);
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
          && newAST->getNumChildren() == 1)
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
ASTBinaryFunctionNode::isSqrt() const
{
  bool valid = false;

  ASTBase * base1 = NULL;

  if (getType() == AST_FUNCTION_ROOT)
  {
    if (getNumChildren() == 2)
    {
      base1 = getChild(0);
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
ASTBinaryFunctionNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  int type  = getType();

  stream.startElement("apply");
    
  //const char * name = ASTBase::getNameFromType(type);
  		
  ASTBase::writeStartEndElement(stream);

  /* HACK TO REPLICATE OLD AST */
  /* for divide/power(operator) only write the first and last child
   * any other write all children
   */
  
  /* write the two children
   * note we expect to have two children but cannot guarantee it 
   */
   
  unsigned int numChildren = getNumChildren();

  if (type == AST_DIVIDE || type == AST_POWER)
  {
    if (numChildren > 0)
    {
      ASTFunctionBase::getChild(0)->write(stream);
    }

    if (numChildren > 1)
    {
      ASTFunctionBase::getChild(numChildren - 1)->write(stream);
    }
    
  }
  /* HACK TO REPLICATE OLD AST */
  /* for log/root with two or more children assume first is logbase/degree
   * and last is the value operated on
   * 
   * however if the node is read in with a logbase and then more than
   * further children it uses the first as the value operated on
   */
  else if (type == AST_FUNCTION_LOG)
  {
    if (numChildren > 1)
    {
      if (ASTFunctionBase::getChild(0)->getType() != AST_QUALIFIER_LOGBASE)
      {
        ASTQualifierNode * logbase = new ASTQualifierNode(AST_QUALIFIER_LOGBASE);
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
ASTBinaryFunctionNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
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
        delete child;
        child = NULL;
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

  if (read == true && type == AST_FUNCTION_LOG 
    && getExpectedNumChildren() == 1)
  {
    /* HACK TO REPLICATE OLD BEHAVIOUR */
    /* we need to add the qualifier child for the log base 10 */
    ASTFunction * logbase = new ASTFunction(AST_QUALIFIER_LOGBASE);
    ASTNumber * int10 = new ASTNumber(AST_INTEGER);
    int10->setInteger(10);
    logbase->addChild(int10->deepCopy());
    this->prependChild(logbase->deepCopy());
    delete int10;
    delete logbase;

  }

  return read;
}


bool 
ASTBinaryFunctionNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = true;

  ASTNodeType_t type = getType();
  unsigned int numChildren = getNumChildren();

  // look at specific types that have odd requirements
  // based on being backward compatible or having different numbers
  // of required children
  if (type == AST_FUNCTION_LOG)
  {
    if (numChildren < 1 || numChildren > 2)
    {
      correctNumArgs = false;
    }
    else if (numChildren == 1)
    {
      // we have only one child
      // if it is a qualifier type then it is incorrect
      if (representsQualifier(ASTFunctionBase::getChild(0)->getExtendedType()) == true)
      {
        correctNumArgs = false;
      }
    }
  }
  else if (getNumChildren() != 2)
  {
    correctNumArgs = false;
  }

  return correctNumArgs;
}



LIBSBML_CPP_NAMESPACE_END


/** @endcond */

