/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCSymbolTimeNode.cpp
 * @brief   Ci Number Abstract Syntax Tree (AST) class.
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

#include <sbml/math/ASTCSymbolTimeNode.h>
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



ASTCSymbolTimeNode::ASTCSymbolTimeNode (int type) :
  ASTCiNumberNode(type)
    , mEncoding ( "" )
{
  setEncoding("text");
  setDefinitionURL("http://www.sbml.org/sbml/symbols/time");
}
  


  /**
   * Copy constructor
   */
ASTCSymbolTimeNode::ASTCSymbolTimeNode (const ASTCSymbolTimeNode& orig):
  ASTCiNumberNode(orig)
    , mEncoding (orig.mEncoding)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCSymbolTimeNode&
ASTCSymbolTimeNode::operator=(const ASTCSymbolTimeNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTCiNumberNode::operator =(rhs);
    mEncoding = rhs.mEncoding;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCSymbolTimeNode::~ASTCSymbolTimeNode ()
{
}

int
ASTCSymbolTimeNode::getTypeCode () const
{
  return AST_TYPECODE_CSYMBOL_TIME;
}


  /**
   * Creates a copy (clone).
   */
ASTCSymbolTimeNode*
ASTCSymbolTimeNode::deepCopy () const
{
  return new ASTCSymbolTimeNode(*this);
}

const std::string& 
ASTCSymbolTimeNode::getEncoding() const
{
  return mEncoding;
}

  
bool 
ASTCSymbolTimeNode::isSetEncoding() const
{
  return (mEncoding.empty() != true);
}

  
int 
ASTCSymbolTimeNode::setEncoding(const std::string& encoding)
{
  mEncoding = encoding;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCSymbolTimeNode::unsetEncoding()
{
  mEncoding = "";
  return LIBSBML_OPERATION_SUCCESS;
}



  
void
ASTCSymbolTimeNode::write(XMLOutputStream& stream) const
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
ASTCSymbolTimeNode::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  attributes.add("definitionURL");
  attributes.add("encoding");
}


bool 
ASTCSymbolTimeNode::readAttributes(const XMLAttributes& attributes,
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
ASTCSymbolTimeNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
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
  ASTBase::setType(AST_NAME_TIME);
  read = true;

  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

