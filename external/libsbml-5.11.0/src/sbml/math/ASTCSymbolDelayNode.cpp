/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbolDelayNode.cpp
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

#include <sbml/math/ASTCSymbolDelayNode.h>
#include <sbml/math/ASTNumber.h>
#include <sbml/math/ASTFunction.h>

/* open doxygen comment */

using namespace std;

/* end doxygen comment */

LIBSBML_CPP_NAMESPACE_BEGIN

/**
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


ASTCSymbolDelayNode::ASTCSymbolDelayNode (int type) :
  ASTBinaryFunctionNode(type)
    , mEncoding ( "" )
    , mName       ( "" )
    , mDefinitionURL ( "" )
{
  setEncoding("text");
  setDefinitionURL("http://www.sbml.org/sbml/symbols/delay");
}
  

/**
 * Copy constructor
 */
ASTCSymbolDelayNode::ASTCSymbolDelayNode (const ASTCSymbolDelayNode& orig):
  ASTBinaryFunctionNode(orig)
    , mEncoding (orig.mEncoding)
    , mName      (orig.mName)
    , mDefinitionURL (orig.mDefinitionURL)
{
}

/**
 * Assignment operator for ASTNode.
 */
ASTCSymbolDelayNode&
ASTCSymbolDelayNode::operator=(const ASTCSymbolDelayNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBinaryFunctionNode::operator =(rhs);
    mEncoding = rhs.mEncoding;
    this->mName = rhs.mName;
    this->mDefinitionURL = rhs.mDefinitionURL;
  }
  return *this;
}


/**
 * Destroys this ASTNode, including any child nodes.
 */
ASTCSymbolDelayNode::~ASTCSymbolDelayNode ()
{
}


int
ASTCSymbolDelayNode::getTypeCode () const
{
  return AST_TYPECODE_CSYMBOL_DELAY;
}


/**
 * Creates a copy (clone).
 */
ASTCSymbolDelayNode*
ASTCSymbolDelayNode::deepCopy () const
{
  return new ASTCSymbolDelayNode(*this);
}

int
ASTCSymbolDelayNode::swapChildren(ASTFunction* that)
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




const std::string& 
ASTCSymbolDelayNode::getEncoding() const
{
  return mEncoding;
}

  
bool 
ASTCSymbolDelayNode::isSetEncoding() const
{
  return (mEncoding.empty() != true);
}

  
int 
ASTCSymbolDelayNode::setEncoding(const std::string& encoding)
{
  mEncoding = encoding;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolDelayNode::unsetEncoding()
{
  mEncoding = "";
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string& 
ASTCSymbolDelayNode::getName() const
{
  return mName;
}

  
bool 
ASTCSymbolDelayNode::isSetName() const
{
  return (mName.empty() != true);
}

  
int 
ASTCSymbolDelayNode::setName(const std::string& name)
{
  mName = name;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolDelayNode::unsetName()
{
  mName = "";
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string& 
ASTCSymbolDelayNode::getDefinitionURL() const
{
  return mDefinitionURL;
}

  
bool 
ASTCSymbolDelayNode::isSetDefinitionURL() const
{
  return (mDefinitionURL.empty() != true);
}

  
int 
ASTCSymbolDelayNode::setDefinitionURL(const std::string& url)
{
  mDefinitionURL = url;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolDelayNode::unsetDefinitionURL()
{
  mDefinitionURL = "";
  return LIBSBML_OPERATION_SUCCESS;
}



void
ASTCSymbolDelayNode::write(XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  stream.startElement("apply");
  
  stream.startElement("csymbol");

  stream.setAutoIndent(false);
  
  ASTBase::writeAttributes(stream);

  stream.writeAttribute( "encoding"     , mEncoding );
  stream.writeAttribute( "definitionURL", mDefinitionURL  );

  stream << " " << getName() << " ";
  
  stream.endElement("csymbol");
  
  stream.setAutoIndent(true);

  for (unsigned int n = 0; n < getNumChildren(); n++)
  {
    ASTFunctionBase::getChild(n)->write(stream);
  }
  
  stream.endElement("apply");
}



void
ASTCSymbolDelayNode::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  attributes.add("definitionURL");
  attributes.add("encoding");
}


bool 
ASTCSymbolDelayNode::readAttributes(const XMLAttributes& attributes,
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
  std::string encoding;

  attributes.readInto("definitionURL", url);
  attributes.readInto("encoding", encoding);

  if (encoding != "text")
  {
    //logError(stream, element, DisallowedMathMLEncodingUse);
  }

  setEncoding(encoding);
  //setDefinitionURL(url);


  if (url.empty() == false)
  {
    setDefinitionURL(url);
  }


  return true;
}



bool
ASTCSymbolDelayNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  XMLToken element = stream.peek ();
  const string&  nameE = element.getName();

  if (nameE != "csymbol")
  {
#if 0
    cout << "HELP\n";
#endif
    return read;
  }

  ASTBase::read(stream, reqd_prefix);

  const string nameDelay = trim( stream.next().getCharacters() );
    
  setName((nameDelay));
  ASTBase::setType(AST_FUNCTION_DELAY);

  stream.skipPastEnd(element);
  
  const char * name;
  ASTBase * child = NULL;

  unsigned int numChildrenAdded = 0;
  // catch if we do not have two children
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

  return read;
}



LIBSBML_CPP_NAMESPACE_END


/** @endcond */

