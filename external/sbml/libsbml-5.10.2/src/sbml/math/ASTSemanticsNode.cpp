/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTSemanticsNode.cpp
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

#include <sbml/math/ASTSemanticsNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>
#include <sbml/math/ASTNode.h>
#include <sbml/util/List.h>
#include <sbml/xml/XMLNode.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

ASTSemanticsNode::ASTSemanticsNode (int type) 
  : ASTFunctionBase(type)
  , mDefinitionURL ( "" )
  , mNumAnnotations ( 0 )
{
  mSemanticsAnnotations = new List;

}
  

/**
 * Copy constructor
 */
ASTSemanticsNode::ASTSemanticsNode (const ASTSemanticsNode& orig)
  : ASTFunctionBase(orig)
  , mDefinitionURL (orig.mDefinitionURL)
  , mNumAnnotations (orig.mNumAnnotations)
{
  mSemanticsAnnotations = new List;
  for (unsigned int c = 0; c < orig.getNumSemanticsAnnotations(); ++c)
  {
    addSemanticsAnnotation( orig.getSemanticsAnnotation(c)->clone() );
  }
}


/**
 * Assignment operator for ASTNode.
 */
ASTSemanticsNode&
ASTSemanticsNode::operator=(const ASTSemanticsNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTFunctionBase::operator =(rhs);
    this->mDefinitionURL = rhs.mDefinitionURL;
    mNumAnnotations = rhs.mNumAnnotations;
    
    unsigned int size = mSemanticsAnnotations->getSize();
    while (size-- > 0) 
    {
      delete static_cast<XMLNode*>( mSemanticsAnnotations->remove(0) );
    }
    delete mSemanticsAnnotations;
    mSemanticsAnnotations = new List();
    for (unsigned int c = 0; c < rhs.getNumSemanticsAnnotations(); ++c)
    {
      addSemanticsAnnotation( rhs.getSemanticsAnnotation(c)->clone() );
    }
  }
  return *this;
}


/**
 * Destroys this ASTNode, including any child nodes.
 */
ASTSemanticsNode::~ASTSemanticsNode ()
{
  unsigned int size = mSemanticsAnnotations->getSize();
  while (size-- > 0) 
  {
    delete static_cast<XMLNode*>( mSemanticsAnnotations->remove(0) );
  }
  delete mSemanticsAnnotations;
}


int
ASTSemanticsNode::getTypeCode () const
{
  return AST_TYPECODE_FUNCTION_SEMANTIC;
}


/**
 * Creates a copy (clone).
 */
ASTSemanticsNode*
ASTSemanticsNode::deepCopy () const
{
  return new ASTSemanticsNode(*this);
}


int 
ASTSemanticsNode::addSemanticsAnnotation (XMLNode* sAnnotation)
{
  if (sAnnotation == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  mSemanticsAnnotations->add(sAnnotation);
  return LIBSBML_OPERATION_SUCCESS;

}


unsigned int 
ASTSemanticsNode::getNumSemanticsAnnotations () const
{
  return mSemanticsAnnotations->getSize();
}


XMLNode* 
ASTSemanticsNode::getSemanticsAnnotation (unsigned int n) const
{
  return static_cast<XMLNode*>( mSemanticsAnnotations->get(n) );
}


unsigned int 
ASTSemanticsNode::getNumAnnotations() const
{
  return mNumAnnotations;
}

  
  
int 
ASTSemanticsNode::setNumAnnotations(unsigned int numAnnotations)
{
  mNumAnnotations = numAnnotations;
  return LIBSBML_OPERATION_SUCCESS;

}

const std::string& 
ASTSemanticsNode::getDefinitionURL() const
{
  return mDefinitionURL;
}

  
bool 
ASTSemanticsNode::isSetDefinitionURL() const
{
  return (mDefinitionURL.empty() != true);
}


int 
ASTSemanticsNode::setDefinitionURL(const std::string& url)
{
  mDefinitionURL = url;
  return LIBSBML_OPERATION_SUCCESS;
}


int 
ASTSemanticsNode::unsetDefinitionURL()
{
  mDefinitionURL = "";
  return LIBSBML_OPERATION_SUCCESS;
}


int
ASTSemanticsNode::swapChildren(ASTFunction* that)
{
  int success = LIBSBML_OPERATION_FAILED;
  // the original ast nodes did not have a type for semantics
  // so we actually want to swap the children of the child
  // of this sematics node

  // catch case when this node has no children
  if (getNumChildren() == 0 || getNumChildren() > 1)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  if (getChild(0)->isFunctionNode() == false)
  {
    return LIBSBML_INVALID_OBJECT;
  }


  ASTNode * child0 = dynamic_cast<ASTNode*>(getChild(0));
  if (child0 == NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  ASTFunction * childFunc = child0->getFunction();

  ASTFunction * child = new ASTFunction(child0->getExtendedType());
  child->syncMembersAndTypeFrom(childFunc, child0->getExtendedType());

  success = child->swapChildren(that);

  if (success == LIBSBML_OPERATION_SUCCESS)
  {
    this->removeChild(0);
    this->addChild(child);
  }

  return success;
}


void 
ASTSemanticsNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  stream.startElement("semantics");

  ASTBase::writeAttributes(stream);

  if (isSetDefinitionURL() == true)
  {
    stream.writeAttribute( "definitionURL", mDefinitionURL  );
  }

  if (getNumChildren() > 0)
  {
    getChild(0)->write(stream);
  }


  for (unsigned int n = 0; n < getNumSemanticsAnnotations(); n++)
  {
    stream << *getSemanticsAnnotation(n);
  }

  stream.endElement("semantics");
}

void
ASTSemanticsNode::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  attributes.add("definitionURL");
}


bool 
ASTSemanticsNode::readAttributes(const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element)
{
  bool read = ASTBase::readAttributes(attributes, expectedAttributes,
                                      stream, element);

  if (read == false)
  {
    return read;
  }

  std::string url;

  attributes.readInto("definitionURL", url);

  if (url.empty() == false)
  {
    setDefinitionURL(url);
  }


  return true;
}


bool 
ASTSemanticsNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  //bool read = false;
  ASTBase * child = NULL;
  const XMLToken element = stream.peek ();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  const char*      name;// = element.getName().c_str();
  if (stream.isGood())// && stream.peek().isEndFor(element) == false)
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

    child->read(stream, reqd_prefix);

    stream.skipText();

    addChild(child);
  }

  unsigned int i = 0;
  while ( i < getNumAnnotations())
  {
    if (stream.peek().getName() == "annotation"
      || stream.peek().getName() == "annotation-xml")
    {
      XMLNode semanticAnnotation = XMLNode(stream);
      addSemanticsAnnotation(semanticAnnotation.clone());
      i++;
    }
    else
    {
      stream.next();
    }
  }

  return true;
}



bool 
ASTSemanticsNode::hasCorrectNumberArguments() const
{
  bool correctNumArgs = true;

  if (getNumChildren() > 1)
  {
    correctNumArgs = false;
  }

  return correctNumArgs;
}



LIBSBML_CPP_NAMESPACE_END

/** @endcond */

