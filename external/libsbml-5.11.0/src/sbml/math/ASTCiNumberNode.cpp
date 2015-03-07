/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ASTCiNumberNode.cpp
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

#include <sbml/math/ASTCiNumberNode.h>
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



ASTCiNumberNode::ASTCiNumberNode (int type) :
  ASTBase(type)
    , mName       ( "" )
    , mDefinitionURL ( "" )
{
    ASTBase::setType(type);
}
  


  /**
   * Copy constructor
   */
ASTCiNumberNode::ASTCiNumberNode (const ASTCiNumberNode& orig):
  ASTBase(orig)
    , mName      (orig.mName)
    , mDefinitionURL (orig.mDefinitionURL)
{
}
  /**
   * Assignment operator for ASTNode.
   */
ASTCiNumberNode&
ASTCiNumberNode::operator=(const ASTCiNumberNode& rhs)
{
  if(&rhs!=this)
  {
    this->ASTBase::operator =(rhs);
    this->mName = rhs.mName;
    this->mDefinitionURL = rhs.mDefinitionURL;
  }
  return *this;
}
  /**
   * Destroys this ASTNode, including any child nodes.
   */
ASTCiNumberNode::~ASTCiNumberNode ()
{
}

int
ASTCiNumberNode::getTypeCode () const
{
  return AST_TYPECODE_CI_NUMBER;
}


  /**
   * Creates a copy (clone).
   */
ASTCiNumberNode*
ASTCiNumberNode::deepCopy () const
{
  return new ASTCiNumberNode(*this);
}


  
const std::string& 
ASTCiNumberNode::getName() const
{
  return mName;
}

  
bool 
ASTCiNumberNode::isSetName() const
{
  return (mName.empty() != true);
}

  
int 
ASTCiNumberNode::setName(const std::string& name)
{
  mName = name;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCiNumberNode::unsetName()
{
  mName = "";
  return LIBSBML_OPERATION_SUCCESS;
}


const std::string& 
ASTCiNumberNode::getDefinitionURL() const
{
  return mDefinitionURL;
}

  
bool 
ASTCiNumberNode::isSetDefinitionURL() const
{
  return (mDefinitionURL.empty() != true);
}

  
int 
ASTCiNumberNode::setDefinitionURL(const std::string& url)
{
  mDefinitionURL = url;
  return LIBSBML_OPERATION_SUCCESS;

}


int 
ASTCiNumberNode::unsetDefinitionURL()
{
  mDefinitionURL = "";
  return LIBSBML_OPERATION_SUCCESS;
}


void
ASTCiNumberNode::write(XMLOutputStream& stream) const
{
  stream.startElement("ci");

  stream.setAutoIndent(false);
  
  ASTBase::writeAttributes(stream);

  if (isSetDefinitionURL() == true)
  {
    stream.writeAttribute("definitionURL", getDefinitionURL());
  }

  stream << " " << getName() << " ";
  
  stream.endElement("ci");
  
  stream.setAutoIndent(true);
}

void
ASTCiNumberNode::addExpectedAttributes(ExpectedAttributes& attributes, 
                                     XMLInputStream& stream)
{
  ASTBase::addExpectedAttributes(attributes, stream);

  if (stream.getSBMLNamespaces() != NULL
    && stream.getSBMLNamespaces()->getLevel() > 2)
  {
    attributes.add("definitionURL");
  }
}

bool 
ASTCiNumberNode::readAttributes(const XMLAttributes& attributes,
                       const ExpectedAttributes& expectedAttributes,
                               XMLInputStream& stream, const XMLToken& element)
{
  bool read = ASTBase::readAttributes(attributes, expectedAttributes,
                                      stream, element);

  if (read == false)
  {
    return read;
  }

  string url; 

  attributes.readInto( "definitionURL", url        );

  if (url.empty() == false)
  {
    setDefinitionURL(url);
  }


  return true;
}


bool
ASTCiNumberNode::read(XMLInputStream& stream, const std::string& reqd_prefix)
{
  bool read = false;
  const XMLToken element = stream.next ();
  const string&  nameE = element.getName();

  ASTBase::checkPrefix(stream, reqd_prefix, element);

  if (nameE != "ci")
  {
#if 0
    cout << "HELP\n";
#endif
    return read;
  }

  ExpectedAttributes expectedAttributes;
  addExpectedAttributes(expectedAttributes, stream);
  read = readAttributes(element.getAttributes(), expectedAttributes,
                        stream, element);

  const string name = trim( stream.next().getCharacters() );
    
  setName((name));
  ASTBase::setType(AST_NAME);

  if (read == true)
    stream.skipPastEnd(element);

  return read;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

