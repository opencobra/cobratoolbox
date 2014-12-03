/**
 * @file    XMLToken.cpp
 * @brief   A unit of XML syntax, either an XML element or text.
 * @author  Ben Bornstein
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
 * Copyright (C) 2009-2013 jointly by the following organizations: 
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
 * ---------------------------------------------------------------------- -->*/

#include <sstream>

/** @cond doxygenLibsbmlInternal */
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/util/util.h>
#include <sbml/xml/XMLConstructorException.h>
/** @endcond */
#include <sbml/xml/XMLToken.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new empty XMLToken.
 */
XMLToken::XMLToken () :
   mIsStart   ( false )
 , mIsEnd     ( false )
 , mIsText    ( false )
 , mLine      ( 0     )
 , mColumn    ( 0     )
{
}


/*
 * Creates a start element XMLToken with the given set of attributes and
 * namespace declarations.
 */
XMLToken::XMLToken (  const XMLTriple&      triple
                    , const XMLAttributes&  attributes
                    , const XMLNamespaces&  namespaces
                    , const unsigned int    line
                    , const unsigned int    column ) :
   mTriple    ( triple     )
 , mAttributes( attributes )
 , mNamespaces( namespaces )
 , mIsStart   ( true       )
 , mIsEnd     ( false      )
 , mIsText    ( false      )
 , mLine      ( line       )
 , mColumn    ( column     )
{
}


/*
 * Creates a start element XMLToken with the given set of attributes.
 */
XMLToken::XMLToken (  const XMLTriple&      triple
                    , const XMLAttributes&  attributes
                    , const unsigned int    line
                    , const unsigned int    column ) :
   mTriple    ( triple     )
 , mAttributes( attributes )
 , mIsStart   ( true       )
 , mIsEnd     ( false      )
 , mIsText    ( false      )
 , mLine      ( line       )
 , mColumn    ( column     )
{
}


/*
 * Creates an end element XMLToken.
 */
XMLToken::XMLToken (  const XMLTriple&    triple
                    , const unsigned int  line
                    , const unsigned int  column ) :
   mTriple    ( triple )
 , mIsStart   ( false  )
 , mIsEnd     ( true   )
 , mIsText    ( false  )
 , mLine      ( line   )
 , mColumn    ( column )

{
}


/*
 * Creates a text XMLToken.
 */
XMLToken::XMLToken (  const std::string&  chars
                    , const unsigned int  line
                    , const unsigned int  column ) :
   mIsStart   ( false  )
 , mIsEnd     ( false  )
 , mIsText    ( true   )
 , mLine      ( line   )
 , mColumn    ( column )
{
  if (&chars == NULL)
  {
    throw XMLConstructorException("NULL reference in XML constructor");
  }
  else
  {
    mChars = chars;
  }
}


/*
 * Destroys this XMLToken.
 */
XMLToken::~XMLToken ()
{
}


/*
 * Copy constructor; creates a copy of this XMLToken.
 */
XMLToken::XMLToken(const XMLToken& orig)
{
  if (&orig == NULL)
  {
    throw XMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    if (orig.mTriple.isEmpty())
      mTriple = XMLTriple();
    else
      mTriple = XMLTriple(orig.getName(), orig.getURI(), orig.getPrefix());
    
    if (orig.mAttributes.isEmpty())
      mAttributes = XMLAttributes();
    else
      mAttributes = XMLAttributes(orig.getAttributes());
    
    if (orig.mNamespaces.isEmpty())
      mNamespaces = XMLNamespaces();
    else
      mNamespaces = XMLNamespaces(orig.getNamespaces());

    mChars = orig.mChars;

    mIsStart = orig.mIsStart;
    mIsEnd = orig.mIsEnd;
    mIsText = orig.mIsText;

    mLine = orig.mLine;
    mColumn = orig.mColumn;
  }
}


/*
 * Assignment operator for XMLToken.
 */
XMLToken& 
XMLToken::operator=(const XMLToken& rhs)
{
  if (&rhs == NULL)
  {
    throw XMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    if (rhs.mTriple.isEmpty())
      mTriple = XMLTriple();
    else
      mTriple = XMLTriple(rhs.getName(), rhs.getURI(), rhs.getPrefix());
    
    if (rhs.mAttributes.isEmpty())
      mAttributes = XMLAttributes();
    else
      mAttributes = XMLAttributes(rhs.getAttributes());
    
    if (rhs.mNamespaces.isEmpty())
      mNamespaces = XMLNamespaces();
    else
      mNamespaces = XMLNamespaces(rhs.getNamespaces());

    mChars = rhs.mChars;

    mIsStart = rhs.mIsStart;
    mIsEnd = rhs.mIsEnd;
    mIsText = rhs.mIsText;

    mLine = rhs.mLine;
    mColumn = rhs.mColumn;
  }

  return *this;
}

/*
 * Creates and returns a deep copy of this XMLToken.
 * 
 * @return a (deep) copy of this XMLToken set.
 */
XMLToken* 
XMLToken::clone () const
{
  return new XMLToken(*this);
}


/*
 * Appends characters to this XML text content.
 */
int
XMLToken::append (const std::string& chars)
{
  if (chars.empty())
  {
    return LIBSBML_OPERATION_FAILED;
  }
  else
  {
    mChars.append(chars);
    return LIBSBML_OPERATION_SUCCESS;
  }
}



/*
 * @return the characters of this XML text.
 */
const string&
XMLToken::getCharacters () const
{
  return mChars;
} 


/*
 * @return the column at which this XMLToken occurred.
 */
unsigned int
XMLToken::getColumn () const
{
  return mColumn;
}


/*
 * @return the line at which this XMLToken occurred.
 */
unsigned int
XMLToken::getLine () const
{
  return mLine;
}


/*
 * @return the XMLAttributes of this XML element.
 */
const XMLAttributes&
XMLToken::getAttributes () const
{
  return mAttributes;
}


/*
 * Sets an XMLAttributes to this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param attributes XMLAttributes to be set to this XMLToken.
 *
 * @note This function replaces the existing XMLAttributes with the new one.
 */
int 
XMLToken::setAttributes(const XMLAttributes& attributes)
{
	// test whether argument is valid
	if(&attributes == NULL)
		return LIBSBML_INVALID_OBJECT;


  /* the code will crash if the attributes points to NULL
   * put in a try catch statement to check
   */
  if (mIsStart)
  {
    try
    {
      mAttributes = attributes;
      return LIBSBML_OPERATION_SUCCESS;
    }
    catch (...)
    {
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Adds an attribute to the attribute set in this XMLToken optionally 
 * with a prefix and URI defining a namespace.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 * @param namespaceURI a string, the namespace URI of the attribute.
 * @param prefix a string, the prefix of the namespace
 *
 * @note if local name with the same namespace URI already exists in the
 * attribute set, its value and prefix will be replaced.
 *
 * The native C++ implementation of this method defines a
 * default argument value.  In the documentation generated for different
 * libSBML language bindings, you may or may not see corresponding
 * arguments in the method declarations.  For example, in Java, a default
 * argument is handled by declaring two separate methods, with one of
 * them having the argument and the other one lacking the argument.
 * However, the libSBML documentation will be @em identical for both
 * methods.  Consequently, if you are reading this and do not see an
 * argument even though one is described, please look for descriptions of
 * other variants of this method near where this one appears in the
 * documentation.
 */
int 
XMLToken::addAttr (  const std::string& name
	           , const std::string& value
    	           , const std::string& namespaceURI
	           , const std::string& prefix      )
{
  if (mIsStart) 
  {
    return mAttributes.add(name, value, namespaceURI, prefix);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Adds an attribute with the given XMLTriple/value pair to the attribute set
 * in this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @note if local name with the same namespace URI already exists in the 
 * attribute set, its value and prefix will be replaced.
 *
 * @param triple an XMLTriple, the XML triple of the attribute.
 * @param value a string, the value of the attribute.
 */
int 
XMLToken::addAttr ( const XMLTriple& triple, const std::string& value)
{
  if (mIsStart) 
  {
    return mAttributes.add(triple, value);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Removes an attribute with the given index from the attribute set in
 * this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param n an integer the index of the resource to be deleted
 */
int 
XMLToken::removeAttr (int n)
{
  if (mIsStart) 
  {
    return mAttributes.remove(n);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Removes an attribute with the given local name and namespace URI from 
 * the attribute set in this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param name   a string, the local name of the attribute.
 * @param uri    a string, the namespace URI of the attribute.
 */
int 
XMLToken::removeAttr (const std::string& name, const std::string& uri)
{
  if (mIsStart) 
  {
    return mAttributes.remove(name, uri);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Removes an attribute with the given XMLTriple from the attribute set 
 * in this XMLToken.  
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param triple an XMLTriple, the XML triple of the attribute.
 */
int 
XMLToken::removeAttr (const XMLTriple& triple)
{
  if (mIsStart) 
  {
    return mAttributes.remove(triple);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Clears (deletes) all attributes in this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 */
int 
XMLToken::clearAttributes()
{
  if (mIsStart) 
  {
    return mAttributes.clear();
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Return the index of an attribute with the given local name and namespace URI.
 *
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return the index of an attribute with the given local name and namespace URI, 
 * or -1 if not present.
 *
 * The native C++ implementation of this method defines a
 * default argument value.  In the documentation generated for different
 * libSBML language bindings, you may or may not see corresponding
 * arguments in the method declarations.  For example, in Java, a default
 * argument is handled by declaring two separate methods, with one of
 * them having the argument and the other one lacking the argument.
 * However, the libSBML documentation will be @em identical for both
 * methods.  Consequently, if you are reading this and do not see an
 * argument even though one is described, please look for descriptions of
 * other variants of this method near where this one appears in the
 * documentation.
 */
int 
XMLToken::getAttrIndex (const std::string& name, const std::string& uri) const
{
  return mAttributes.getIndex(name, uri);
}


/*
 * Return the index of an attribute with the given XMLTriple.
 *
 * @param triple an XMLTriple, the XML triple of the attribute for which 
 *        the index is required.
 *
 * @return the index of an attribute with the given XMLTriple, or -1 if not present.
 */
int 
XMLToken::getAttrIndex (const XMLTriple& triple) const
{
  return mAttributes.getIndex(triple);
}


/*
 * Return the number of attributes in the attributes set.
 *
 * @return the number of attributes in the attributes set in this XMLToken.
 */
int 
XMLToken::getAttributesLength () const
{
  return mAttributes.getLength();
}


/*
 * Return the local name of an attribute in the attributes set in this 
 * XMLToken (by position).
 *
 * @param index an integer, the position of the attribute whose local name 
 * is required.
 *
 * @return the local name of an attribute in this list (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned.  Use hasAttr(index) 
 * to test for the attribute existence.
 */
std::string 
XMLToken::getAttrName (int index) const
{
  return mAttributes.getName(index);
}


/*
 * Return the prefix of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param index an integer, the position of the attribute whose prefix is 
 * required.
 *
 * @return the namespace prefix of an attribute in the attribute set
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned. Use hasAttr(index) to test for the attribute existence.
 */
std::string 
XMLToken::getAttrPrefix (int index) const
{
  return mAttributes.getPrefix(index);
}


/*
 * Return the prefixed name of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param index an integer, the position of the attribute whose prefixed 
 * name is required.
 *
 * @return the prefixed name of an attribute in the attribute set 
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned.  Use hasAttr(index) to test for attribute existence.
 */
std::string 
XMLToken::getAttrPrefixedName (int index) const
{
  return mAttributes.getPrefixedName(index);
}


/*
 * Return the namespace URI of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param index an integer, the position of the attribute whose namespace 
 * URI is required.
 *
 * @return the namespace URI of an attribute in the attribute set (by position).
 *
 * @note If index is out of range, an empty string will be returned.  Use
 * hasAttr(index) to test for attribute existence.
 */
std::string 
XMLToken::getAttrURI (int index) const
{
  return mAttributes.getURI(index);
}


/*
 * Return the value of an attribute in the attribute set in this XMLToken  
 * (by position).
 *
 * @param index an integer, the position of the attribute whose value is 
 * required.
 *
 * @return the value of an attribute in the attribute set (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned. Use hasAttr(index)
 * to test for attribute existence.
 */
std::string 
XMLToken::getAttrValue (int index) const
{
  return mAttributes.getValue(index);
}


/*
 * Return a value of an attribute with the given local name and namespace URI.
 *
 * @param name a string, the local name of the attribute whose value is required.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the 
 * given local name and namespace URI does not exist, an empty string will be 
 * returned.  
 * Use hasAttr(name, uri) to test for attribute existence.
 *
 * The native C++ implementation of this method defines a
 * default argument value.  In the documentation generated for different
 * libSBML language bindings, you may or may not see corresponding
 * arguments in the method declarations.  For example, in Java, a default
 * argument is handled by declaring two separate methods, with one of
 * them having the argument and the other one lacking the argument.
 * However, the libSBML documentation will be @em identical for both
 * methods.  Consequently, if you are reading this and do not see an
 * argument even though one is described, please look for descriptions of
 * other variants of this method near where this one appears in the
 * documentation.
 */
std::string 
XMLToken::getAttrValue (const std::string name, const std::string uri) const
{
  return mAttributes.getValue(name, uri);
}


/*
 * Return a value of an attribute with the given XMLTriple.
 *
 * @param triple an XMLTriple, the XML triple of the attribute whose 
 *        value is required.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the
 * given XMLTriple does not exist, an empty string will be returned.  
 * Use hasAttr(triple) to test for attribute existence.
 */
std::string 
XMLToken::getAttrValue (const XMLTriple& triple) const
{
  return mAttributes.getValue(triple);
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given index exists in the attribute set in this 
 * XMLToken.
 *
 * @param index an integer, the position of the attribute.
 *
 * @return @c true if an attribute with the given index exists in the attribute 
 * set in this XMLToken, @c false otherwise.
 */
bool 
XMLToken::hasAttr (int index) const
{
  return mAttributes.hasAttribute(index);
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name and namespace URI exists 
 * in the attribute set in this XMLToken.
 *
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return @c true if an attribute with the given local name and namespace 
 * URI exists in the attribute set in this XMLToken, @c false otherwise.
 *
 * @if notcpp @htmlinclude warn-default-args-in-docs.html @endif@~
 */
bool 
XMLToken::hasAttr (const std::string name, const std::string uri) const
{
  return mAttributes.hasAttribute(name, uri);
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given XML triple exists in the attribute set in 
 * this XMLToken 
 *
 * @param triple an XMLTriple, the XML triple of the attribute 
 *
 * @return @c true if an attribute with the given XML triple exists
 * in the attribute set in this XMLToken, @c false otherwise.
 *
 */
bool 
XMLToken::hasAttr (const XMLTriple& triple) const
{
  return mAttributes.hasAttribute(triple);
}


/*
 * Predicate returning @c true or @c false depending on whether 
 * the attribute set in this XMLToken set is empty.
 * 
 * @return @c true if the attribute set in this XMLToken is empty, 
 * @c false otherwise.
 */
bool 
XMLToken::isAttributesEmpty () const
{
  return mAttributes.isEmpty();
}




/*
 * @return the XML namespace declarations for this XML element.
 */
const XMLNamespaces&
XMLToken::getNamespaces () const
{
  return mNamespaces;
}


/*
 * Sets an XMLnamespaces to this XML element.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @note This function replaces the existing XMLNamespaces with the new one.
 */
int 
XMLToken::setNamespaces(const XMLNamespaces& namespaces)
{
	// test whether argument is valid
	if(&namespaces == NULL)
		return LIBSBML_INVALID_OBJECT;

  /* the code will crash if the namespaces points to NULL
   * put in a try catch statement to check
   */
  if (mIsStart)
  {
    try
    {
      mNamespaces = namespaces;
      return LIBSBML_OPERATION_SUCCESS;
    }
    catch (...)
    {
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Appends an XML namespace prefix and URI pair to this XMLToken.
 * If there is an XML namespace with the given prefix in this XMLToken, 
 * then the existing XML namespace will be overwritten by the new one.
 *
 * Nothing will be done if this XMLToken is not a start element.
 */
int 
XMLToken::addNamespace (const std::string& uri, const std::string& prefix)
{
  if (&uri == NULL || &prefix == NULL ) return LIBSBML_INVALID_OBJECT;

   if (mIsStart)  
   {
     mNamespaces.add(uri, prefix);
     return LIBSBML_OPERATION_SUCCESS;
   }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Removes an XML Namespace stored in the given position of the XMLNamespaces
 * of this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param index an integer, position of the removed namespace.
 */
int 
XMLToken::removeNamespace (int index)
{
   if (mIsStart) 
   {
     return mNamespaces.remove(index);
   }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Removes an XML Namespace with the given prefix.
 * Nothing will be done if this XMLToken is not a start element.
 *
 * @param prefix a string, prefix of the required namespace.
 */
int 
XMLToken::removeNamespace (const std::string& prefix)
{
  if (mIsStart)  
  {
    return mNamespaces.remove(prefix);
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Clears (deletes) all XML namespace declarations in the XMLNamespaces of
 * this XMLToken.
 * Nothing will be done if this XMLToken is not a start element.
 */
int 
XMLToken::clearNamespaces ()
{
   if (mIsStart) 
   {
     return mNamespaces.clear();
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }
}


/*
 * Look up the index of an XML namespace declaration by URI.
 *
 * @param uri a string, uri of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 */
int 
XMLToken::getNamespaceIndex (const std::string& uri) const
{
  return mNamespaces.getIndex(uri);
}


/*
 * Look up the index of an XML namespace declaration by prefix.
 *
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 */
int 
XMLToken::getNamespaceIndexByPrefix (const std::string& prefix) const
{
  return mNamespaces.getIndexByPrefix(prefix);
}


/*
 * Returns the number of XML namespaces stored in the XMLNamespaces 
 * of this XMLToken.
 *
 * @return the number of namespaces in this list.
 */
int 
XMLToken::getNamespacesLength () const
{
  return mNamespaces.getLength();
}


/*
 * Look up the prefix of an XML namespace declaration by position.
 *
 * Callers should use getNamespacesLength() to find out how many 
 * namespaces are stored in the XMLNamespaces.
 * 
 * @return the prefix of an XML namespace declaration in the XMLNamespaces 
 * (by position).  
 */
std::string 
XMLToken::getNamespacePrefix (int index) const
{
  return mNamespaces.getPrefix(index);
}


/*
 * Look up the prefix of an XML namespace declaration by its URI.
 *
 * @return the prefix of an XML namespace declaration given its URI.  
 */
std::string 
XMLToken::getNamespacePrefix (const std::string& uri) const
{
  return mNamespaces.getPrefix(uri);
}


/*
 * Look up the URI of an XML namespace declaration by its position.
 *
 * @return the URI of an XML namespace declaration in the XMLNamespaces
 * (by position).  
 */
std::string 
XMLToken::getNamespaceURI (int index) const
{
  return mNamespaces.getURI(index);
}


/*
 * Look up the URI of an XML namespace declaration by its prefix.
 *
 * @return the URI of an XML namespace declaration given its prefix.  
 */
std::string 
XMLToken::getNamespaceURI (const std::string& prefix) const
{
  return mNamespaces.getURI(prefix);
}


/*
 * Predicate returning @c true or @c false depending on whether 
 * the XMLNamespaces of this XMLToken is empty.
 * 
 * @return @c true if the XMLNamespaces of this XMLToken is empty, 
 * @c false otherwise.
 */
bool 
XMLToken::isNamespacesEmpty () const
{
  return mNamespaces.isEmpty();
}


/*
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given URI is contained in the XMLNamespaces of
 * this XMLToken.
 *
 * @return @c true if an XML Namespace with the given URI is contained in the
 * XMLNamespaces of this XMLToken,  @c false otherwise.
 */
bool 
XMLToken::hasNamespaceURI(const std::string& uri) const
{
  return mNamespaces.hasURI(uri);
}


/*
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given prefix is contained in the XMLNamespaces of
 * this XMLToken.
 *
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c true if an XML Namespace with the given URI is contained in the
 * XMLNamespaces of this XMLToken, @c false otherwise.
 */
bool 
XMLToken::hasNamespacePrefix(const std::string& prefix) const
{
  return mNamespaces.hasPrefix(prefix);
}


/*
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given uri/prefix pair is contained in the 
 * XMLNamespaces ofthis XMLToken.
 *
 * @param uri a string, the uri for the namespace
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c true if an XML Namespace with the given uri/prefix pair is 
 * contained in the XMLNamespaces of this XMLToken,  @c false otherwise.
 */
bool 
XMLToken::hasNamespaceNS(const std::string& uri, const std::string& prefix) const
{
  return mNamespaces.hasNS(uri,prefix);
}


/*
 * Sets the XMLTripe (name, uri and prefix) of this XML element.
 * Nothing will be done if this XML element is a text node.
 */
int 
XMLToken::setTriple(const XMLTriple& triple)
{
	// test whether argument is valid
	if(&triple == NULL)
		return LIBSBML_INVALID_OBJECT;

  /* the code will crash if the triple points to NULL
   * put in a try catch statement to check
   */
  if (! mIsText ) 
  {
    try
    {
      mTriple = triple;
      return LIBSBML_OPERATION_SUCCESS;
    }
    catch (...)
    {
      return LIBSBML_OPERATION_FAILED;
    }
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }

}


/*
 * @return the (unqualified) name of this XML element.
 */
const string&
XMLToken::getName () const
{
  return mTriple.getName();
}


/*
 * @return the namespace prefix of this XML element.  If no prefix
 * exists, an empty string will be return.
 */
const string&
XMLToken::getPrefix () const
{
  return mTriple.getPrefix();
}


/*
 * @return the namespace URI of this XML element.
 */
const string&
XMLToken::getURI () const
{
  return mTriple.getURI();
}



/*
 * @return true if this XMLToken is an XML element.
 */
bool
XMLToken::isElement () const
{
  return mIsStart || mIsEnd;
}

 
/*
 * @return true if this XMLToken is an XML end element, false
 * otherwise.
 */
bool
XMLToken::isEnd () const
{
  return mIsEnd;
}


/*
 * @return true if this XMLToken is an XML end element for the given XML
 * start element, false otherwise.
 */
bool
XMLToken::isEndFor (const XMLToken& element) const
{
  return
    isEnd()                        &&
    !isStart()                     &&
    element.isStart()              &&
    element.getName() == getName() &&
    element.getURI () == getURI ();
}


/*
 * @return true if this XMLToken is an end of file (input) marker, false
 * otherwise.
 */
bool
XMLToken::isEOF () const
{
  return (mIsStart == false && mIsEnd == false && mIsText == false);
}


/*
 * @return true if this XMLToken is an XML start element, false
 * otherwise.
 */
bool
XMLToken::isStart () const
{
  return mIsStart;
}


/*
 * @return true if this XMLToken is text, false otherwise.
 */
bool
XMLToken::isText () const
{
  return mIsText;
}


/*
 * Declares this XML start element is also an end element.
 */
int
XMLToken::setEnd ()
{
  mIsEnd = true;
  if (isEnd())
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}


/*
 * Declares this XML start/end element is no longer an end element.
 */
int
XMLToken::unsetEnd ()
{
  mIsEnd = false;
  if (!isEnd())
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}


/*
 * Declares this XMLToken is an end-of-file (input) marker.
 */
int
XMLToken::setEOF ()
{
  mIsStart = false;
  mIsEnd   = false;
  mIsText  = false;

  if (isEOF())
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Writes this XMLToken to stream.
 */
void
XMLToken::write (XMLOutputStream& stream) const
{
  if ( isEOF () ) return;

  if ( isText() )
  {
    stream << getCharacters();
    return;
  }

  if ( isStart() ) stream.startElement( mTriple );
  if ( isStart() ) stream << mNamespaces << mAttributes;
  if ( isEnd()   ) stream.endElement( mTriple );
}
/** @endcond */


/*
 * Prints a string representation of the underlying token stream, for
 * debugging purposes.
 */
string
XMLToken::toString ()
{
  ostringstream stream;

  if ( isText() )
  {
    stream << getCharacters();
  }
  else
  {
    stream << '<';
    if ( !isStart() && isEnd() ) stream << '/';

    stream << getName();

    if (  isStart() && isEnd() ) stream << '/';
    stream << '>';
  }

  return stream.str();
}


/** @cond doxygenLibsbmlInternal */
/*
 * Inserts this XMLToken into stream.
 */
LIBLAX_EXTERN
XMLOutputStream&
operator<< (XMLOutputStream& stream, const XMLToken& token)
{
  token.write(stream);
  return stream;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBLAX_EXTERN
XMLToken_t *
XMLToken_create (void)
{
  return new(nothrow) XMLToken;
}


LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTriple (const XMLTriple_t *triple)
{
  if (triple == NULL) return NULL;
  return new(nothrow) XMLToken(*triple);
}


LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTripleAttr (const XMLTriple_t *triple,
			       const XMLAttributes_t *attr)
{
  if (triple == NULL || attr == NULL) return NULL;
  return new(nothrow) XMLToken(*triple, *attr);
}


LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTripleAttrNS (const XMLTriple_t *triple,
				 const XMLAttributes_t *attr,
				 const XMLNamespaces_t *ns)
{
  if (triple == NULL || attr == NULL || ns == NULL) return NULL;
  return new(nothrow) XMLToken(*triple, *attr, *ns);
}


LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithText (const char *text)
{
  return (text != NULL) ? new(nothrow) XMLToken(text) : new(nothrow) XMLToken;
}

LIBLAX_EXTERN
void
XMLToken_free (XMLToken_t *token)
{
  if (token == NULL) return;
  delete static_cast<XMLToken*>( token );
}


LIBLAX_EXTERN
XMLToken_t *
XMLToken_clone (const XMLToken_t* t)
{
  if (t == NULL) return NULL;
  return static_cast<XMLToken*>( t->clone() );
}


LIBLAX_EXTERN
int
XMLToken_append (XMLToken_t *token, const char *text)
{
  if (token != NULL && text != NULL)
  {
    return token->append(text);
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


LIBLAX_EXTERN
const char *
XMLToken_getCharacters (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return token->getCharacters().empty() ? NULL : token->getCharacters().c_str();
}


LIBLAX_EXTERN
unsigned int
XMLToken_getColumn (const XMLToken_t *token)
{
  if (token == NULL) return 0;
  return token->getColumn();
}    


LIBLAX_EXTERN
unsigned int
XMLToken_getLine (const XMLToken_t *token)
{
  if (token == NULL) return 0;
  return token->getLine();
}    



LIBLAX_EXTERN
const XMLAttributes_t *
XMLToken_getAttributes (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return &(token->getAttributes());
}


LIBLAX_EXTERN
int 
XMLToken_setAttributes(XMLToken_t *token, const XMLAttributes_t* attributes)
{
  if (token == NULL || attributes == NULL) return LIBSBML_INVALID_OBJECT;
  return token->setAttributes(*attributes);
}


LIBLAX_EXTERN
int 
XMLToken_addAttr ( XMLToken_t *token,  const char* name, const char* value )
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->addAttr(name, value, "", "");
}


LIBLAX_EXTERN
int 
XMLToken_addAttrWithNS ( XMLToken_t *token,  const char* name
	                , const char* value
    	                , const char* namespaceURI
	                , const char* prefix      )
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->addAttr(name, value, namespaceURI, prefix);
}



LIBLAX_EXTERN
int 
XMLToken_addAttrWithTriple (XMLToken_t *token, const XMLTriple_t *triple, const char* value)
{
  if (token == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return token->addAttr(*triple, value);
}


LIBLAX_EXTERN
int 
XMLToken_removeAttr (XMLToken_t *token, int n)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeAttr(n);
}


LIBLAX_EXTERN
int 
XMLToken_removeAttrByName (XMLToken_t *token, const char* name)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeAttr(name, "");
}


LIBLAX_EXTERN
int 
XMLToken_removeAttrByNS (XMLToken_t *token, const char* name, const char* uri)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeAttr(name, uri);
}


LIBLAX_EXTERN
int 
XMLToken_removeAttrByTriple (XMLToken_t *token, const XMLTriple_t *triple)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeAttr(*triple);
}


LIBLAX_EXTERN
int 
XMLToken_clearAttributes(XMLToken_t *token)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->clearAttributes();
}



LIBLAX_EXTERN
int 
XMLToken_getAttrIndex (const XMLToken_t *token, const char* name, const char* uri)
{
  if (token == NULL) return -1;
  return token->getAttrIndex(name, uri);
}


LIBLAX_EXTERN
int 
XMLToken_getAttrIndexByTriple (const XMLToken_t *token, const XMLTriple_t *triple)
{
  if (token == NULL || triple == NULL) return -1;
  return token->getAttrIndex(*triple);
}


LIBLAX_EXTERN
int 
XMLToken_getAttributesLength (const XMLToken_t *token)
{
  if (token == NULL) return 0;
  return token->getAttributesLength();
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrName (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrName(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrPrefix (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrPrefix(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrPrefixedName (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrPrefixedName(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrURI (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrURI(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrValue (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrValue(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByName (const XMLToken_t *token, const char* name)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrValue(name, "");

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByNS (const XMLToken_t *token, const char* name, const char* uri)
{
  if (token == NULL) return NULL;
  const std::string str = token->getAttrValue(name, uri);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByTriple (const XMLToken_t *token, const XMLTriple_t *triple)
{
  if (token == NULL || triple == NULL) return NULL;
  const std::string str = token->getAttrValue(*triple);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
int
XMLToken_hasAttr (const XMLToken_t *token, int index)
{
  if (token == NULL) return (int) false;
  return token->hasAttr(index);
}


LIBLAX_EXTERN
int
XMLToken_hasAttrWithName (const XMLToken_t *token, const char* name)
{
  if (token == NULL) return (int) false;
  return token->hasAttr(name, "");
}


LIBLAX_EXTERN
int
XMLToken_hasAttrWithNS (const XMLToken_t *token, const char* name, const char* uri)
{
  if (token == NULL) return (int) false;
  return token->hasAttr(name, uri);
}


LIBLAX_EXTERN
int
XMLToken_hasAttrWithTriple (const XMLToken_t *token, const XMLTriple_t *triple)
{
  if (token == NULL || triple == NULL) return (int) false;
  return token->hasAttr(*triple);
}


LIBLAX_EXTERN
int
XMLToken_isAttributesEmpty (const XMLToken_t *token)
{
  if (token == NULL) return (int) false;
  return token->isAttributesEmpty();
}



LIBLAX_EXTERN
const XMLNamespaces_t *
XMLToken_getNamespaces (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return &(token->getNamespaces());
}


LIBLAX_EXTERN
int 
XMLToken_setNamespaces(XMLToken_t *token, const XMLNamespaces_t* namespaces)
{
  if (token == NULL || namespaces == NULL) return LIBSBML_INVALID_OBJECT;
  return token->setNamespaces(*namespaces);
}


LIBLAX_EXTERN
int 
XMLToken_addNamespace (XMLToken_t *token, const char* uri, const char* prefix)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->addNamespace(uri, prefix);
}


LIBLAX_EXTERN
int 
XMLToken_removeNamespace (XMLToken_t *token, int index)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeNamespace(index);
}


LIBLAX_EXTERN
int 
XMLToken_removeNamespaceByPrefix (XMLToken_t *token, const char* prefix)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->removeNamespace(prefix);
}


LIBLAX_EXTERN
int 
XMLToken_clearNamespaces (XMLToken_t *token)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->clearNamespaces();
}


LIBLAX_EXTERN
int 
XMLToken_getNamespaceIndex (const XMLToken_t *token, const char* uri)
{
  if (token == NULL) return -1;
  return token->getNamespaceIndex(uri);
}


LIBLAX_EXTERN
int 
XMLToken_getNamespaceIndexByPrefix (const XMLToken_t *token, const char* prefix)
{
  if (token == NULL) return -1;
  return token->getNamespaceIndexByPrefix(prefix);
}


LIBLAX_EXTERN
int 
XMLToken_getNamespacesLength (const XMLToken_t *token)
{
  if (token == NULL) return 0;
  return token->getNamespacesLength();
}


LIBLAX_EXTERN
char* 
XMLToken_getNamespacePrefix (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getNamespacePrefix(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getNamespacePrefixByURI (const XMLToken_t *token, const char* uri)
{
  if (token == NULL) return NULL;
  const std::string str = token->getNamespacePrefix(uri);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getNamespaceURI (const XMLToken_t *token, int index)
{
  if (token == NULL) return NULL;
  const std::string str = token->getNamespaceURI(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLToken_getNamespaceURIByPrefix (const XMLToken_t *token, const char* prefix)
{
  if (token == NULL) return NULL;
  const std::string str = token->getNamespaceURI(prefix);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
int
XMLToken_isNamespacesEmpty (const XMLToken_t *token)
{
  if (token == NULL) return (int) false;
   return static_cast<int>(token->isNamespacesEmpty());
}


LIBLAX_EXTERN
int
XMLToken_hasNamespaceURI(const XMLToken_t *token, const char* uri)
{
  if (token == NULL) return (int)false;
  return static_cast<int>(token->hasNamespaceURI(uri));
}


LIBLAX_EXTERN
int
XMLToken_hasNamespacePrefix(const XMLToken_t *token, const char* prefix)
{
  if (token == NULL) return (int)false;
  return static_cast<int>(token->hasNamespacePrefix(prefix));
}


LIBLAX_EXTERN
int
XMLToken_hasNamespaceNS(const XMLToken_t *token, const char* uri, const char* prefix)
{
  if (token == NULL) return (int) false;
  return static_cast<int>(token->hasNamespaceNS(uri, prefix));
}


LIBLAX_EXTERN
int 
XMLToken_setTriple(XMLToken_t *token, const XMLTriple_t *triple)
{
  if (token == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return token->setTriple(*triple);
}


LIBLAX_EXTERN
const char *
XMLToken_getName (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return token->getName().empty() ? NULL : token->getName().c_str();
}


LIBLAX_EXTERN
const char *
XMLToken_getPrefix (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return token->getPrefix().empty() ? NULL : token->getPrefix().c_str();
}


LIBLAX_EXTERN
const char *
XMLToken_getURI (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return token->getURI().empty() ? NULL : token->getURI().c_str();
}


LIBLAX_EXTERN
int
XMLToken_isElement (const XMLToken_t *token)
{
  if (token == NULL) return (int)false;
  return static_cast<int>( token->isElement() );
}


LIBLAX_EXTERN
int
XMLToken_isEnd (const XMLToken_t *token) 
{
  if (token == NULL) return (int)false;
  return static_cast<int>( token->isEnd() );
}


LIBLAX_EXTERN
int
XMLToken_isEndFor (const XMLToken_t *token, const XMLToken_t *element)
{
  if (token == NULL || element== NULL) return (int)false;
  return static_cast<int>( token->isEndFor(*element) );
}


LIBLAX_EXTERN
int
XMLToken_isEOF (const XMLToken_t *token)
{
  if (token == NULL) return (int) false;
  return static_cast<int>( token->isEOF() );
}


LIBLAX_EXTERN
int
XMLToken_isStart (const XMLToken_t *token)
{
  if (token == NULL) return (int) false;
  return static_cast<int>( token->isStart() );
}


LIBLAX_EXTERN
int
XMLToken_isText (const XMLToken_t *token)
{
  if (token == NULL) return (int) false;
  return static_cast<int>( token->isText() );
}


LIBLAX_EXTERN
int
XMLToken_setEnd (XMLToken_t *token)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->setEnd();
}


LIBLAX_EXTERN
int
XMLToken_setEOF (XMLToken_t *token)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->setEOF();
}


LIBLAX_EXTERN
int
XMLToken_unsetEnd (XMLToken_t *token)
{
  if (token == NULL) return LIBSBML_INVALID_OBJECT;
  return token->unsetEnd();
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

