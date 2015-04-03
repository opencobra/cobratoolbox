/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbolAvogadroNode.cpp
 * @brief   Constant Number Abstract Syntax Tree (AST) class.
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
 * in the file Valued "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/math/ASTCSymbolAvogadroNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>

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



ASTCSymbolAvogadroNode::ASTCSymbolAvogadroNode (int type) :
  ASTConstantNumberNode(type)
    , mEncoding ( "" )
    , mName       ( "" )
    , mDefinitionURL ( "" )
{
  ASTConstantNumberNode::setType(type);
  ASTConstantNumberNode::setValue(6.02214179e23);
  setEncoding("text");
  setDefinitionURL("http://www.sbml.org/sbml/symbols/avogadro");
}
  


  /**
   * Copy constructor
   */
ASTCSymbolAvogadroNode::ASTCSymbolAvogadroNode (const ASTCSymbolAvogadroNode& orig):
  ASTConstantNumberNode(orig)
    , mEncoding (orig.mEncoding)
    , mName      (orig.mName)
    , mDefinitionURL (orig.mDefinitionURL)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCSymbolAvogadroNode&
ASTCSymbolAvogadroNode::operator=(const ASTCSymbolAvogadroNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTConstantNumberNode::operator =(rhs);
    mEncoding = rhs.mEncoding;
    this->mName = rhs.mName;
    this->mDefinitionURL = rhs.mDefinitionURL;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCSymbolAvogadroNode::~ASTCSymbolAvogadroNode ()
{
}

int
ASTCSymbolAvogadroNode::getTypeCode () const
{
  return AST_TYPECODE_CSYMBOL_AVOGADRO;
}


  /**
   * Creates a copy (clone).
   */
ASTCSymbolAvogadroNode*
ASTCSymbolAvogadroNode::deepCopy () const
{
  return new ASTCSymbolAvogadroNode(*this);
}

const std::string& 
ASTCSymbolAvogadroNode::getEncoding() const
{
  return mEncoding;
}

  
bool 
ASTCSymbolAvogadroNode::isSetEncoding() const
{
  return (mEncoding.empty() != true);
}

  
int 
ASTCSymbolAvogadroNode::setEncoding(const std::string& encoding)
{
  mEncoding = encoding;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolAvogadroNode::unsetEncoding()
{
  mEncoding = "";
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string& 
ASTCSymbolAvogadroNode::getName() const
{
  return mName;
}

  
bool 
ASTCSymbolAvogadroNode::isSetName() const
{
  return (mName.empty() != true);
}

  
int 
ASTCSymbolAvogadroNode::setName(const std::string& name)
{
  mName = name;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolAvogadroNode::unsetName()
{
  mName = "";
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string& 
ASTCSymbolAvogadroNode::getDefinitionURL() const
{
  return mDefinitionURL;
}

  
bool 
ASTCSymbolAvogadroNode::isSetDefinitionURL() const
{
  return (mDefinitionURL.empty() != true);
}

  
int 
ASTCSymbolAvogadroNode::setDefinitionURL(const std::string& url)
{
  mDefinitionURL = url;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolAvogadroNode::unsetDefinitionURL()
{
  mDefinitionURL = "";
  return LIBSBML_OPERATION_SUCCESS;
}



  
void
ASTCSymbolAvogadroNode::write(XMLOutputStream& stream) const
{
  stream.startElement("csymbol");

  stream.setAutoIndent(false);
  
  ASTBase::writeAttributes(stream);

  stream.writeAttribute( "encoding"     , mEncoding );
  stream.writeAttribute( "definitionURL", mDefinitionURL  );

  stream << " " << getName() << " ";
  
  stream.endElement("csymbol");
  
  stream.setAutoIndent(true);
}


void
ASTCSymbolAvogadroNode::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  attributes.add("definitionURL");
  attributes.add("encoding");
}


bool 
ASTCSymbolAvogadroNode::readAttributes(const XMLAttributes& attributes,
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
ASTCSymbolAvogadroNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.peek ();
  const string&  nameE = element.getName();

  if (nameE != "csymbol")
  {
#if 0
    cout << "HELP\n";
#endif
    return read;
  }

  ASTBase::read(stream, reqd_prefix);

  const string name = trim( stream.next().getCharacters() );
    
  setName((name));
  ASTBase::setType(AST_NAME_AVOGADRO);
  read = true;

  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

