/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTFunctionBase.cpp
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

#include <limits.h>

#include <sbml/math/ASTFunctionBase.h>
#include <sbml/util/List.h>
#include <sbml/math/ASTNode.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTFunctionBase::ASTFunctionBase (int type) :
  ASTBase(type)
  , mChildren()
  , mCalcNumChildren ( 0 )
{  
}
  

  /**
   * Copy constructor
   */
ASTFunctionBase::ASTFunctionBase (const ASTFunctionBase& orig):
  ASTBase(orig)
  , mChildren ()
  , mCalcNumChildren (orig.mCalcNumChildren)
{
  for (unsigned int c = 0; c < orig.getNumChildren(); ++c)
  {
    addChild( orig.getChild(c)->deepCopy() );
  }

}
  /**
   * Assignment operator for ASTNode.
   */
ASTFunctionBase&
ASTFunctionBase::operator=(const ASTFunctionBase& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    mCalcNumChildren = rhs.mCalcNumChildren;
    
    vector<ASTBase*>::iterator it = mChildren.begin();
    while (it != mChildren.end())
    {
      delete *it;
      ++it;
    }
    mChildren.clear();

    for (unsigned int c = 0; c < rhs.getNumChildren(); ++c)
    {
      addChild( rhs.getChild(c)->deepCopy() );
    }

  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTFunctionBase::~ASTFunctionBase ()
{

  vector<ASTBase*>::iterator it = mChildren.begin();
  while (it != mChildren.end())
  {
    delete *it;
    ++it;
  }
  mChildren.clear();
}


int
ASTFunctionBase::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_BASE;
}



int 
ASTFunctionBase::addChild(ASTBase * child, bool /*inRead = false*/)
{
  if (child == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  unsigned int numBefore = ASTFunctionBase::getNumChildren();

  bool childIsNode = dynamic_cast<ASTNode*>(child);
  if (childIsNode)
  {
    mChildren.push_back(child);
    child->setIsChildFlag(true);
  }
  else
  {
    ASTFunction* childAsFunction = dynamic_cast<ASTFunction*>(child);
    ASTNumber* childAsNumber = dynamic_cast<ASTNumber*>(child);

    // wrap it
    ASTNode* tmp = childAsFunction != NULL ? new ASTNode(childAsFunction) : new ASTNode(childAsNumber);
    mChildren.push_back(tmp);
    tmp->setIsChildFlag(true);


  }

  if (ASTFunctionBase::getNumChildren() == numBefore + 1)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}

ASTBase* 
ASTFunctionBase::getChild (unsigned int n) const
{
  // should not get here if the index is too big - but why not just check
  if (n >= mChildren.size())
  {
    return NULL;
  }

  return static_cast<ASTBase*>( mChildren[n] );
}

unsigned int 
ASTFunctionBase::getNumChildren() const
{
  if (mChildren.size() > UINT_MAX)
  {
    return UINT_MAX;
  }
  return static_cast<unsigned int>(mChildren.size());
}


int
ASTFunctionBase::removeChild(unsigned int n)
{
  int removed = LIBSBML_INDEX_EXCEEDS_SIZE;
  unsigned int size = static_cast<unsigned int>(mChildren.size());
  if (n < size)
  {
    mChildren.erase(mChildren.begin() + n);
    if (mChildren.size() == size-1)
    {
      removed = LIBSBML_OPERATION_SUCCESS;
    }
  }

  return removed;
}


int
ASTFunctionBase::prependChild(ASTBase* child)
{
  if (child == NULL) return LIBSBML_INVALID_OBJECT;

  unsigned int numBefore = ASTFunctionBase::getNumChildren();
  child->setIsChildFlag(true);
  
  bool childIsNode = dynamic_cast<ASTNode*>(child);
  if (childIsNode)
  {
    mChildren.insert(mChildren.begin(),child);
    child->setIsChildFlag(true);
  }
  else
  {
    ASTFunction* childAsFunction = dynamic_cast<ASTFunction*>(child);
    ASTNumber* childAsNumber = dynamic_cast<ASTNumber*>(child);

    // wrap it
    ASTNode* tmp = childAsFunction != NULL ? new ASTNode(childAsFunction) : new ASTNode(childAsNumber);
    mChildren.insert(mChildren.begin(), tmp);
    tmp->setIsChildFlag(true);


  }
  
  if (ASTFunctionBase::getNumChildren() == numBefore + 1)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


int
ASTFunctionBase::replaceChild(unsigned int n, ASTBase* newChild)
{
  if (newChild == NULL) return LIBSBML_INVALID_OBJECT;

  int replaced = LIBSBML_INDEX_EXCEEDS_SIZE;

  unsigned int size = ASTFunctionBase::getNumChildren();
  if (n < size)
  {
    //delete mChildren[n];
    mChildren.erase(mChildren.begin() + n);
    if (ASTFunctionBase::insertChild(n, newChild) == LIBSBML_OPERATION_SUCCESS)
    {
      replaced = LIBSBML_OPERATION_SUCCESS;
    }
  }
    
  return replaced;
}


int
ASTFunctionBase::insertChild(unsigned int n, ASTBase* newChild)
{
  if (newChild == NULL) return LIBSBML_INVALID_OBJECT;

  int inserted = LIBSBML_INDEX_EXCEEDS_SIZE;

  unsigned int size = ASTFunctionBase::getNumChildren();
  if (n == 0)
  {
    ASTFunctionBase::prependChild(newChild);
    inserted = LIBSBML_OPERATION_SUCCESS;
  }
  else if (n <= size) 
  {
    /* starting at the end take each child in the list and prepend it
    * then remove it from the end
    * at the insertion point prepend the newChild
    * eg list: a, b, c 
    * inserting d at position 2
    * list goes: c, a, b :  d, c, a, b : b, d, c, a : a, b, d, c
    */

    bool childIsNode = dynamic_cast<ASTNode*>(newChild);
    if (childIsNode)
    {
      mChildren.insert(mChildren.begin() + n, newChild);
      newChild->setIsChildFlag(true);
    }
    else
    {
      ASTFunction* childAsFunction = dynamic_cast<ASTFunction*>(newChild);
      ASTNumber* childAsNumber = dynamic_cast<ASTNumber*>(newChild);

      // wrap it
      ASTNode* tmp = childAsFunction != NULL ? new ASTNode(childAsFunction) : new ASTNode(childAsNumber);
      mChildren.insert(mChildren.begin()+n, tmp);
      tmp->setIsChildFlag(true);


    }

    if (ASTFunctionBase::getNumChildren() == size + 1)
    {
      inserted = LIBSBML_OPERATION_SUCCESS;
    }
  }

  return inserted;
}


int
ASTFunctionBase::swapChildren(ASTFunctionBase* that)
{
  if (that == NULL)
    return LIBSBML_OPERATION_FAILED;

  vector<ASTBase*> temp      = this->mChildren;
  this->mChildren = that->mChildren;
  that->mChildren = temp;
  return LIBSBML_OPERATION_SUCCESS;
}


void 
ASTFunctionBase::write(XMLOutputStream& stream) const
{
}
bool
ASTFunctionBase::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  return false;
}


bool 
ASTFunctionBase::hasChildren() const
{
  return (getNumChildren() != 0);
}


void
ASTFunctionBase::writeArgumentsOfType(XMLOutputStream& stream, int type) const
{
  if (&stream == NULL) return;

  int thisType = getExtendedType();

  unsigned int numChildren = getNumChildren();

  if (numChildren <= 2 && type == thisType)
  {
    // replicate old behaviour of rolling out embedded plus/time nodes
    for (unsigned int i = 0; i < numChildren; i++)
    {
      if (getChild(i)->getExtendedType() == type)
      {
        ASTFunctionBase * c = static_cast<ASTFunctionBase*>(getChild(i));
        if (c != NULL)
        {
          c->writeArgumentsOfType(stream, type);
        }
      }
      else
      {
        getChild(i)->write(stream);
      }
    }
  }
  else
  {
    for (unsigned int i = 0; i < numChildren; i++)
    {
      getChild(i)->write(stream);
    }
  }
}


void 
ASTFunctionBase::setExpectedNumChildren(unsigned int n) 
{
  mCalcNumChildren = n; 
}


unsigned int 
ASTFunctionBase::getExpectedNumChildren() const
{ 
  return mCalcNumChildren; 
} 


bool 
ASTFunctionBase::isWellFormedNode() const
{
  bool valid = hasCorrectNumberArguments();
  unsigned int numChildren = getNumChildren();
  unsigned int i = 0;

  // check number of arguments
  while (valid && i < numChildren)
  {
    valid = getChild(i)->isWellFormedNode();
    i++;
  }
  return valid;
}


bool 
ASTFunctionBase::hasCorrectNumberArguments() const
{
  return true;
}


bool
ASTFunctionBase::hasCnUnits() const
{
  bool hasUnits = false;

  unsigned int i = 0;
  while (hasUnits == false && i < ASTFunctionBase::getNumChildren())
  {
    hasUnits = ASTFunctionBase::getChild(i)->hasCnUnits();
    i++;
  }

  return hasUnits;
}


const std::string&
ASTFunctionBase::getUnitsPrefix() const
{
  std::string units("");

  unsigned int i = 0;
  unsigned int numChildren = ASTFunctionBase::getNumChildren();
  while (units.empty() == true && i < numChildren)
  {
    units = ASTFunctionBase::getChild(i)->getUnitsPrefix();
    i++;
  }

  if (units.empty() == false && i <= numChildren)
  {
    return ASTFunctionBase::getChild(i-1)->getUnitsPrefix();
  }
  else
  {
    return ASTBase::getUnitsPrefix();
  }
}







LIBSBML_CPP_NAMESPACE_END


/** @endcond */

