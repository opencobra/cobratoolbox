/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTPiecewiseFunctionNode.cpp
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

#include <sbml/math/ASTPiecewiseFunctionNode.h>
#include <sbml/math/ASTNaryFunctionNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTNode.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTPiecewiseFunctionNode::ASTPiecewiseFunctionNode (int type) :
  ASTNaryFunctionNode(type)
    , mNumPiece (0)
    , mHasOtherwise (false)
{
}
  
  
  /**
   * Copy constructor
   */
ASTPiecewiseFunctionNode::ASTPiecewiseFunctionNode (const ASTPiecewiseFunctionNode& orig):
  ASTNaryFunctionNode(orig)
    , mNumPiece (orig.mNumPiece)
    , mHasOtherwise (orig.mHasOtherwise)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTPiecewiseFunctionNode&
ASTPiecewiseFunctionNode::operator=(const ASTPiecewiseFunctionNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTNaryFunctionNode::operator =(rhs);
    mNumPiece = rhs.mNumPiece;
    mHasOtherwise = rhs.mHasOtherwise;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTPiecewiseFunctionNode::~ASTPiecewiseFunctionNode ()
{
}

int
ASTPiecewiseFunctionNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_PIECEWISE;
}


  /**
   * Creates a copy (clone).
   */
ASTPiecewiseFunctionNode*
ASTPiecewiseFunctionNode::deepCopy () const
{
  return new ASTPiecewiseFunctionNode(*this);
}

int
ASTPiecewiseFunctionNode::swapChildren(ASTFunction* that)
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


int
ASTPiecewiseFunctionNode::addChild(ASTBase* child, bool inRead)
{
  // now here what I want to do is just keep track of the number
  // of children being added so the mNumPiece and mHasOtherwise
  // variables can be given appropriate values

  // but not if we are reading a stream because then we already know

  if (inRead == false)
  {
    if (child->getType() != AST_CONSTRUCTOR_PIECE && 
        child->getType() != AST_CONSTRUCTOR_OTHERWISE)
    {
      // this child does not have a piece/otherwise but if 
      // the rest of the function does then it needs to fit in with that

      unsigned int currentNum = getNumChildren();

      if (usingChildConstructors() == false)
      {
        if ((currentNum+1)%2 == 0)
        {
          setNumPiece(getNumPiece()+1);
          setHasOtherwise(false);
        }
        else
        {
          setHasOtherwise(true);
        }
     
        return ASTFunctionBase::addChild(child);
      }
      else
      {
        ASTBase * lastChild = 
          ASTFunctionBase::getChild(ASTFunctionBase::getNumChildren()-1);
        if (lastChild == NULL)
        { // we have a serious issue going on but may as well just
          // add the child
          return ASTFunctionBase::addChild(child);
        }
        else if (lastChild->getType() == AST_CONSTRUCTOR_PIECE)
        {
          ASTNode * piece = dynamic_cast<ASTNode*>(lastChild);

          if (piece == NULL)
          {
            return LIBSBML_OPERATION_FAILED;
          }
          if (piece->getNumChildren() == 1)
          {
            return piece->addChild((ASTNode*)(child));
          }
          else
          {
            ASTNode * otherwise = new ASTNode(AST_CONSTRUCTOR_OTHERWISE);
            if (otherwise->addChild((ASTNode*)(child)) == LIBSBML_OPERATION_SUCCESS)
            {
              setHasOtherwise(true);
              return ASTFunctionBase::addChild(otherwise);
            }
            else
            {
              return LIBSBML_OPERATION_FAILED;
            }
          }
        }
        else
        {
          ASTNode * otherwise = dynamic_cast<ASTNode*>(lastChild);

          if (otherwise == NULL || otherwise->getNumChildren() != 1)
          {
            return LIBSBML_OPERATION_FAILED;
          }

          ASTNode * piece = new ASTNode(AST_CONSTRUCTOR_PIECE);
          // add the child from the otherwise
          if (piece->addChild(otherwise->getChild(0)) != LIBSBML_OPERATION_SUCCESS)
          {
            return LIBSBML_OPERATION_FAILED;
          }
          else
          {
            if (piece->addChild((ASTNode*)(child)) == LIBSBML_OPERATION_SUCCESS)
            {
              this->removeChild(currentNum-1);
              setHasOtherwise(false);
              setNumPiece(getNumPiece() + 1);
              return ASTFunctionBase::addChild(piece);
            }
            else
            {
              return LIBSBML_OPERATION_FAILED;
            }
          }
        }
      }
    }
    else
    {
      if (child->getType() == AST_CONSTRUCTOR_PIECE)
      {
        setNumPiece(getNumPiece()+1);
      }
      else
      {
        setHasOtherwise(true);
      }
    
      return ASTFunctionBase::addChild(child);
    }
  }
  else
  {
    return ASTFunctionBase::addChild(child);
  }
}

ASTBase* 
ASTPiecewiseFunctionNode::getChild (unsigned int n) const
{
  /* HACK TO REPLICATE OLD AST */
  /* do not return a node with the piece or otherwise type
   * return the correct child of the piece type
   * or the child of the otherwise
   */

  unsigned int numChildren = ASTFunctionBase::getNumChildren();
  if (numChildren == 0)
  {
    return NULL;
  }

  // determine index that we actually want
  unsigned int childNo = (unsigned int)(n/2);
  unsigned int pieceIndex = (unsigned int)(n%2);

  ASTBase * base = NULL;
  if (childNo < numChildren)
  {
    base = ASTFunctionBase::getChild(childNo);
  }


  if (getHasOtherwise() == true && childNo == numChildren - 1)
  {
    if (base == NULL)
    {
      return NULL;
    }

    if (base->getType() == AST_CONSTRUCTOR_OTHERWISE)
    {
      ASTNode * otherwise = dynamic_cast<ASTNode*>(base);

      if (otherwise != NULL)
      {
        if (otherwise->getNumChildren() > 0)
        {
          return otherwise->getChild(0);
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
      return base;
    }
  }
  else if (base != NULL && base->getType() == AST_CONSTRUCTOR_PIECE)
  {
    ASTNode * piece = dynamic_cast<ASTNode*>(base);

    if (piece != NULL)
    {
      if (piece->getNumChildren() > pieceIndex)
      {
        return piece->getChild(pieceIndex);
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
  else if (n < numChildren)
  {
    return ASTFunctionBase::getChild(n);
  }
  else
  {
    return NULL;
  }
}


unsigned int
ASTPiecewiseFunctionNode::getNumChildren() const
{
  /* HACK TO REPLICATE OLD AST */
  unsigned int numChildren = 0;
  
  for (unsigned int i = 0; i < getNumPiece(); i++)
  {
    ASTBase * base = ASTFunctionBase::getChild(i);
    ASTNode * piece = dynamic_cast<ASTNode*>(base);

    if (piece != NULL && piece->getType() == AST_CONSTRUCTOR_PIECE)
    {
      numChildren += piece->getNumChildren();
    }
    else
    {
      // fail safe - a piece should have 2 children
      numChildren += 2;
    }
  }
  if (getHasOtherwise() == true)
  {
    numChildren++;
  }

  return numChildren;
}


int 
ASTPiecewiseFunctionNode::removeChild(unsigned int n)
{
  int removed = LIBSBML_INDEX_EXCEEDS_SIZE;
  /* HACK TO REPLICATE OLD AST */
  /* do not return a node with the piece or otherwise type
   * return the correct child of the piece type
   * or the child of the otherwise
   */

  unsigned int numChildren = ASTFunctionBase::getNumChildren();
  // determine index that we actually want
  unsigned int childNo = (unsigned int)(n/2);
  unsigned int pieceIndex = (unsigned int)(n%2);
  unsigned int size = getNumChildren();
  if (size == 0)
  {
    return LIBSBML_OPERATION_FAILED;
  }

  if (n < size)
  {
    if (getHasOtherwise() == true && childNo == numChildren - 1)
    {
      removed = ASTFunctionBase::removeChild(childNo);
      mHasOtherwise = false;
    }
    else if (ASTFunctionBase::getChild(childNo)->getType() 
                                                 == AST_CONSTRUCTOR_PIECE)
    {
      ASTBase * base = ASTFunctionBase::getChild(childNo);
      ASTNode * piece = dynamic_cast<ASTNode*>(base);

      if (piece != NULL)
      {
        if (piece->getNumChildren() > pieceIndex)
        {
          removed = piece->removeChild(pieceIndex);
          if (removed == LIBSBML_OPERATION_SUCCESS &&
            piece->getNumChildren() == 0)
          {
            removed = this->ASTFunctionBase::removeChild(childNo);
            mNumPiece = mNumPiece - 1;
          }
        }
        else
        {
          removed = LIBSBML_OPERATION_FAILED;
        }
      }
      else
      {
        removed = LIBSBML_OPERATION_FAILED;
      }
    }
    else if (n < numChildren)
    {
      removed =  ASTFunctionBase::removeChild(n);
    }
    else
    {
      removed = LIBSBML_OPERATION_FAILED;
    }
  }

  return removed;
}


int 
ASTPiecewiseFunctionNode::prependChild(ASTBase* child)
{
  return insertChild(0, child);
}


int 
ASTPiecewiseFunctionNode::insertChild(unsigned int n, ASTBase* newChild)
{
  int inserted = LIBSBML_INDEX_EXCEEDS_SIZE;
  
  unsigned int numChildrenForUser = getNumChildren();

  if (n > numChildrenForUser)
  {
    return inserted;
  }
  else if (n == numChildrenForUser)
  {
    return addChild(newChild);
  }
  else
  {
    vector < ASTBase *> copyChildren;
    unsigned int i;
    for (i = n; i < numChildrenForUser; i++)
    {
      copyChildren.push_back(getChild(i));
    }
    for (i = numChildrenForUser; i > n; i--)
    {
      removeChild(i-1);
    }

    unsigned int success = addChild(newChild);

    i = 0;
    while (success == LIBSBML_OPERATION_SUCCESS && i < copyChildren.size())
    {
      success = addChild(copyChildren.at(i));
      i++;
    }

    inserted = success;
  }

  return inserted;
}



int 
ASTPiecewiseFunctionNode::replaceChild(unsigned int n, ASTBase* newChild)
{
  int replaced = LIBSBML_INDEX_EXCEEDS_SIZE;
  
  unsigned int numChildrenForUser = getNumChildren();

  if (n > numChildrenForUser)
  {
    return replaced;
  }
  else
  {
    //replaced = removeChild(n);
    //if (replaced == LIBSBML_OPERATION_SUCCESS)
    //{
      // really want to call insert child but this can have issues with
      // the fact that we have just removed a child
      // so call a private version
      replaced = insertChildForReplace(n, newChild);
    //}
  }

  return replaced;
}


int 
ASTPiecewiseFunctionNode::insertChildForReplace(unsigned int n, ASTBase* newChild)
{
  int inserted = LIBSBML_INDEX_EXCEEDS_SIZE;

  unsigned int numChildren = ASTFunctionBase::getNumChildren();
  unsigned int numChildrenForUser = getNumChildren();

  // determine index that we actually want
  unsigned int childNo = (unsigned int)(n/2);
  unsigned int pieceIndex = (unsigned int)(n%2);

  if (numChildren == numChildrenForUser)
  {
    // we have an old style piecewise function
    childNo = n;
    pieceIndex = n;
  }

  ASTBase * base = NULL;
  if (childNo < numChildren)
  {
    base = ASTFunctionBase::getChild(childNo);
  }


  if (getHasOtherwise() == true && childNo == numChildren - 1)
  {
    if (base == NULL)
    {
      return inserted;
    }

    if (base->getType() == AST_CONSTRUCTOR_OTHERWISE)
    {
      ASTNode * otherwise = dynamic_cast<ASTNode*>(base);

      if (otherwise != NULL)
      {
        inserted = otherwise->replaceChild(0, 
                                            static_cast<ASTNode*>(newChild));
      }
      else
      {
        return inserted;
      }
    }
    else
    {
      inserted = ASTFunctionBase::replaceChild(childNo, newChild);
    }
  }
  else if (base != NULL && base->getType() == AST_CONSTRUCTOR_PIECE)
  {
    ASTNode * piece = dynamic_cast<ASTNode*>(base);

    if (piece != NULL)
    {
      if (piece->getNumChildren() > pieceIndex)
      {
        inserted = piece->replaceChild(pieceIndex, static_cast<ASTNode*>(newChild));
      }
      else
      {
        return inserted;
      }
    }
    else
    {
      return inserted;
    }
  }
  else if (n < numChildren)
  {
    return ASTFunctionBase::replaceChild(n, newChild);
  }
  else
  {
    return inserted;
  }

  return inserted;

  //unsigned int numChildren = ASTFunctionBase::getNumChildren();

  //vector < ASTBase *> copyChildren;
  //unsigned int i;
  //for (i = n; i < numChildren; i++)
  //{
  //  ASTBase * child = getChild(i);
  //  // this might be NULL if we have deleted part of the piece function
  //  if (child != NULL)
  //  {
  //    copyChildren.push_back(getChild(i));
  //  }
  //}
  //for (i = numChildren; i > n; i--)
  //{
  //  ASTFunctionBase::removeChild(i-1);
  //}

  //unsigned int success = addChild(newChild);

  //i = 0;
  //while (success == LIBSBML_OPERATION_SUCCESS && i < copyChildren.size())
  //{
  //  success = addChild(copyChildren.at(i));
  //  i++;
  //}

  //inserted = success;

  //return inserted;
}





bool
ASTPiecewiseFunctionNode::usingChildConstructors() const
{
  bool usingChildConstructors = false;

  if (getNumChildren() != ASTFunctionBase::getNumChildren())
  {
    // generally this will be true
    usingChildConstructors = true;
  }
  else
  {
    ASTBase * base = ASTFunctionBase::getChild(getNumChildren() - 1);
    if (base != NULL && (base->getType() == AST_CONSTRUCTOR_PIECE
      || base->getType() == AST_CONSTRUCTOR_OTHERWISE))
    {
      usingChildConstructors = true;
    }
  }

  return usingChildConstructors;
}


unsigned int 
ASTPiecewiseFunctionNode::getNumPiece() const
{
  return mNumPiece;
}
  
  
int 
ASTPiecewiseFunctionNode::setNumPiece(unsigned int numPiece)
{
  mNumPiece = numPiece;
  return LIBSBML_OPERATION_SUCCESS;

}


bool
ASTPiecewiseFunctionNode::getHasOtherwise() const
{
  return mHasOtherwise;
}
  
  
int 
ASTPiecewiseFunctionNode::setHasOtherwise(bool otherwise)
{
  mHasOtherwise = otherwise;
  return LIBSBML_OPERATION_SUCCESS;

}

void
ASTPiecewiseFunctionNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  ASTBase::writeStartElement(stream);

  unsigned int i;
  unsigned int numChild = 0;
  unsigned int numChildren = ASTFunctionBase::getNumChildren();
  for (i = 0; i < getNumPiece(); i++)
  {
  /* HACK TO REPLICATE OLD AST */
  /* old ast behaviour would take each child in turn as elements of piece
   * and then otherwise
   */
    if (ASTFunctionBase::getChild(i)->getType() == AST_CONSTRUCTOR_PIECE)
    {
      ASTFunctionBase::getChild(i)->write(stream);
    }
    else
    {
      stream.startElement("piece");
      if (numChild < numChildren)
      {
        ASTFunctionBase::getChild(numChild)->write(stream);
        numChild++;
      }
      if (numChild < numChildren)
      {
        ASTFunctionBase::getChild(numChild)->write(stream);
        numChild++;
      }
      stream.endElement("piece");
    }
  }

  if (getHasOtherwise() == true)
  {
    if (ASTFunctionBase::getChild(numChildren-1)->getType() 
                                             == AST_CONSTRUCTOR_OTHERWISE)
    {
      ASTFunctionBase::getChild(numChildren-1)->write(stream);
    }
    else
    {
      stream.startElement("otherwise");
      ASTFunctionBase::getChild(numChildren-1)->write(stream);
      stream.endElement("otherwise");
    }
  }

  
    
  stream.endElement("piecewise");
}

bool
ASTPiecewiseFunctionNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  ASTBase * child = NULL;

  unsigned int numPiece = getNumPiece();
  unsigned int numChildrenAdded = 0;
  
  // read in piece
  // these are functions as they will be created as ASTQualifierNodes

  while(numChildrenAdded < numPiece)
  {
    child = new ASTFunction();
    read = child->read(stream, reqd_prefix);

    if (read == true && addChild(child, true) == LIBSBML_OPERATION_SUCCESS)
    {
      numChildrenAdded++;
    }
    else
    {
      read = false;
      break;
    }
  }

  // if there were no piece statements mark read true so we can continue
  if (numPiece == 0)
  {
    read = true;
  }


  if (read == true && getHasOtherwise() == true)
  {
    child = new ASTFunction();
    read = child->read(stream, reqd_prefix);
    
    if (read == true && addChild(child, true) == LIBSBML_OPERATION_SUCCESS)
    {
      numChildrenAdded++;
    }
    else
    {
      read = false;
    }
  }
  return read;
}



bool 
ASTPiecewiseFunctionNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = true;

  if (getNumChildren() < 1)
  {
    correctNumArgs = false;
  }

  return correctNumArgs;
}



LIBSBML_CPP_NAMESPACE_END


/** @endcond */

