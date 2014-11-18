/**
 * @file    XMLToken.h
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * @class XMLToken
 * @sbmlbrief{core} A token in libSBML's XML stream.
 *
 * @htmlinclude not-sbml-warning.html
 *
 */


#ifndef XMLToken_h
#define XMLToken_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/xml/XMLAttributes.h>
/** @cond doxygenLibsbmlInternal */
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLOutputStream.h>
/** @endcond */
#include <sbml/xml/XMLToken.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

/** @cond doxygenLibsbmlInternal */
class XMLOutputStream;
/** @endcond */


class LIBLAX_EXTERN XMLToken
{
public:

  /**
   * Creates a new empty XMLToken.
   */
  XMLToken ();


  /**
   * Creates a start element XMLToken with the given set of attributes and
   * namespace declarations.
   *
   * @param triple XMLTriple.
   * @param attributes XMLAttributes, the attributes to set.
   * @param namespaces XMLNamespaces, the namespaces to set.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&      triple
            , const XMLAttributes&  attributes
            , const XMLNamespaces&  namespaces
            , const unsigned int    line   = 0
            , const unsigned int    column = 0 );


  /**
   * Creates a start element XMLToken with the given set of attributes.
   *
   * @param triple XMLTriple.
   * @param attributes XMLAttributes, the attributes to set.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&      triple
            , const XMLAttributes&  attributes
            , const unsigned int    line   = 0
            , const unsigned int    column = 0 );


  /**
   * Creates an end element XMLToken.
   *
   * @param triple XMLTriple.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&    triple
            , const unsigned int  line   = 0
            , const unsigned int  column = 0 );


  /**
   * Creates a text XMLToken.
   *
   * @param chars a string, the text to be added to the XMLToken
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const std::string&  chars
            , const unsigned int  line   = 0
            , const unsigned int  column = 0 );


  /**
   * Destroys this XMLToken.
   */
  virtual ~XMLToken ();


  /**
   * Copy constructor; creates a copy of this XMLToken.
   *
   * @param orig the XMLToken object to copy.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  XMLToken(const XMLToken& orig);


  /**
   * Assignment operator for XMLToken.
   *
   * @param rhs The XMLToken object whose values are used as the basis
   * of the assignment.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  XMLToken& operator=(const XMLToken& rhs);


  /**
   * Creates and returns a deep copy of this XMLToken object.
   *
   * @return the (deep) copy of this XMLToken object.
   */
  XMLToken* clone () const;


  /**
   * Returns the attributes of this element.
   *
   * @return the XMLAttributes of this XML element.
   */
  const XMLAttributes& getAttributes () const;


  /**
   * Sets an XMLAttributes to this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param attributes XMLAttributes to be set to this XMLToken.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note This function replaces the existing XMLAttributes with the new one.
   */
  int setAttributes(const XMLAttributes& attributes);


  /**
   * Adds an attribute to the attribute set in this XMLToken optionally 
   * with a prefix and URI defining a namespace.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param name a string, the local name of the attribute.
   * @param value a string, the value of the attribute.
   * @param namespaceURI a string, the namespace URI of the attribute.
   * @param prefix a string, the prefix of the namespace
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @note if local name with the same namespace URI already exists in the
   * attribute set, its value and prefix will be replaced.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int addAttr (  const std::string& name
	        , const std::string& value
	        , const std::string& namespaceURI = ""
	        , const std::string& prefix = "");

  /**
   * Adds an attribute with the given XMLTriple/value pair to the attribute set
   * in this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @note if local name with the same namespace URI already exists in the 
   * attribute set, its value and prefix will be replaced.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a string, the value of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   */
   int addAttr ( const XMLTriple& triple, const std::string& value);


  /**
   * Removes an attribute with the given index from the attribute set in
   * this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param n an integer the index of the resource to be deleted
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeAttr (int n);


  /**
   * Removes an attribute with the given local name and namespace URI from 
   * the attribute set in this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param name   a string, the local name of the attribute.
   * @param uri    a string, the namespace URI of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeAttr (const std::string& name, const std::string& uri = "");


  /**
   * Removes an attribute with the given XMLTriple from the attribute set 
   * in this XMLToken.  
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeAttr (const XMLTriple& triple); 


  /**
   * Clears (deletes) all attributes in this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   */
  int clearAttributes();


  /**
   * Return the index of an attribute with the given local name and namespace URI.
   *
   * @param name a string, the local name of the attribute.
   * @param uri  a string, the namespace URI of the attribute.
   *
   * @return the index of an attribute with the given local name and namespace URI, 
   * or <code>-1</code> if not present.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int getAttrIndex (const std::string& name, const std::string& uri="") const;


  /**
   * Return the index of an attribute with the given XMLTriple.
   *
   * @param triple an XMLTriple, the XML triple of the attribute for which 
   *        the index is required.
   *
   * @return the index of an attribute with the given XMLTriple, or <code>-1</code> if not present.
   */
  int getAttrIndex (const XMLTriple& triple) const;


  /**
   * Return the number of attributes in the attributes set.
   *
   * @return the number of attributes in the attributes set in this XMLToken.
   */
  int getAttributesLength () const;


  /**
   * Return the local name of an attribute in the attributes set in this 
   * XMLToken (by position).
   *
   * @param index an integer, the position of the attribute whose local name 
   * is required.
   *
   * @return the local name of an attribute in this list (by position).  
   *
   * @note If index
   * is out of range, an empty string will be returned.  Use
   * XMLToken::hasAttr(@if java int@endif)
   * to test for the attribute existence.
   */
  std::string getAttrName (int index) const;


  /**
   * Return the prefix of an attribute in the attribute set in this 
   * XMLToken (by position).
   *
   * @param index an integer, the position of the attribute whose prefix is 
   * required.
   *
   * @return the namespace prefix of an attribute in the attribute set
   * (by position).  
   *
   * @note If index is out of range, an empty string will be returned. Use
   * XMLToken::hasAttr(@if java int@endif) to test
   * for the attribute existence.
   */
  std::string getAttrPrefix (int index) const;


  /**
   * Return the prefixed name of an attribute in the attribute set in this 
   * XMLToken (by position).
   *
   * @param index an integer, the position of the attribute whose prefixed 
   * name is required.
   *
   * @return the prefixed name of an attribute in the attribute set 
   * (by position).  
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLToken::hasAttr(@if java int@endif) to test
   * for attribute existence.
   */
  std::string getAttrPrefixedName (int index) const;


  /**
   * Return the namespace URI of an attribute in the attribute set in this 
   * XMLToken (by position).
   *
   * @param index an integer, the position of the attribute whose namespace 
   * URI is required.
   *
   * @return the namespace URI of an attribute in the attribute set (by position).
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLToken::hasAttr(@if java int@endif) to test
   * for attribute existence.
   */
  std::string getAttrURI (int index) const;


  /**
   * Return the value of an attribute in the attribute set in this XMLToken  
   * (by position).
   *
   * @param index an integer, the position of the attribute whose value is 
   * required.
   *
   * @return the value of an attribute in the attribute set (by position).  
   *
   * @note If index is out of range, an empty string will be returned. Use
   * XMLToken::hasAttr(@if java int@endif) to test
   * for attribute existence.
   */
  std::string getAttrValue (int index) const;


  /**
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
   * Use XMLToken::hasAttr(@if java String, String@endif)
   * to test for attribute existence.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  std::string getAttrValue (const std::string name, const std::string uri="") const;


  /**
   * Return a value of an attribute with the given XMLTriple.
   *
   * @param triple an XMLTriple, the XML triple of the attribute whose 
   *        value is required.
   *
   * @return The attribute value as a string.  
   *
   * @note If an attribute with the
   * given XMLTriple does not exist, an empty string will be returned.  
   * Use XMLToken::hasAttr(@if java XMLTriple@endif)
   * to test for attribute existence.
   */
  std::string getAttrValue (const XMLTriple& triple) const;


  /**
   * Predicate returning @c true or @c false depending on whether
   * an attribute with the given index exists in the attribute set in this 
   * XMLToken.
   *
   * @param index an integer, the position of the attribute.
   *
   * @return @c true if an attribute with the given index exists in the attribute 
   * set in this XMLToken, @c false otherwise.
   */
  bool hasAttr (int index) const;


  /**
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
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool hasAttr (const std::string name, const std::string uri="") const;


  /**
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
  bool hasAttr (const XMLTriple& triple) const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * the attribute set in this XMLToken set is empty.
   * 
   * @return @c true if the attribute set in this XMLToken is empty, 
   * @c false otherwise.
   */
  bool isAttributesEmpty () const;



  /**
   * Returns the XML namespace declarations for this XML element.
   *
   * @return the XML namespace declarations for this XML element.
   */
  const XMLNamespaces& getNamespaces () const;


  /**
   * Sets an XMLnamespaces to this XML element.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param namespaces XMLNamespaces to be set to this XMLToken.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note This function replaces the existing XMLNamespaces with the new one.
   */
  int setNamespaces(const XMLNamespaces& namespaces);


  /**
   * Appends an XML namespace prefix and URI pair to this XMLToken.
   * If there is an XML namespace with the given prefix in this XMLToken, 
   * then the existing XML namespace will be overwritten by the new one.
   *
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param uri a string, the uri for the namespace
   * @param prefix a string, the prefix for the namespace
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int addNamespace (const std::string& uri, const std::string& prefix = "");


  /**
   * Removes an XML Namespace stored in the given position of the XMLNamespaces
   * of this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param index an integer, position of the removed namespace.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeNamespace (int index);


  /**
   * Removes an XML Namespace with the given prefix.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @param prefix a string, prefix of the required namespace.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeNamespace (const std::string& prefix);


  /**
   * Clears (deletes) all XML namespace declarations in the XMLNamespaces of
   * this XMLToken.
   * Nothing will be done if this XMLToken is not a start element.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   */
  int clearNamespaces ();


  /**
   * Look up the index of an XML namespace declaration by URI.
   *
   * @param uri a string, uri of the required namespace.
   *
   * @return the index of the given declaration, or <code>-1</code> if not present.
   */
  int getNamespaceIndex (const std::string& uri) const;


  /**
   * Look up the index of an XML namespace declaration by prefix.
   *
   * @param prefix a string, prefix of the required namespace.
   *
   * @return the index of the given declaration, or <code>-1</code> if not present.
   */
  int getNamespaceIndexByPrefix (const std::string& prefix) const;


  /**
   * Returns the number of XML namespaces stored in the XMLNamespaces 
   * of this XMLToken.
   *
   * @return the number of namespaces in this list.
   */
  int getNamespacesLength () const;


  /**
   * Look up the prefix of an XML namespace declaration by position.
   *
   * Callers should use getNamespacesLength() to find out how many 
   * namespaces are stored in the XMLNamespaces.
   *
   * @param index an integer, position of the required prefix.
   *
   * @return the prefix of an XML namespace declaration in the XMLNamespaces 
   * (by position).  
   *
   * @note If index is out of range, an empty string will be
   * returned.
   *
   * @see getNamespacesLength()
   */
  std::string getNamespacePrefix (int index) const;


  /**
   * Look up the prefix of an XML namespace declaration by its URI.
   *
   * @param uri a string, the URI of the prefix being sought
   *
   * @return the prefix of an XML namespace declaration given its URI.  
   *
   * @note If @p uri does not exist, an empty string will be returned.
   */
  std::string getNamespacePrefix (const std::string& uri) const;


  /**
   * Look up the URI of an XML namespace declaration by its position.
   *
   * @param index an integer, position of the required URI.
   *
   * @return the URI of an XML namespace declaration in the XMLNamespaces
   * (by position).  
   *
   * @note If @p index is out of range, an empty string will be
   * returned.
   *
   * @see getNamespacesLength()
   */
  std::string getNamespaceURI (int index) const;


  /**
   * Look up the URI of an XML namespace declaration by its prefix.
   *
   * @param prefix a string, the prefix of the required URI
   *
   * @return the URI of an XML namespace declaration given its prefix.  
   *
   * @note If @p prefix does not exist, an empty string will be returned.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  std::string getNamespaceURI (const std::string& prefix = "") const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * the XMLNamespaces of this XMLToken is empty.
   * 
   * @return @c true if the XMLNamespaces of this XMLToken is empty, 
   * @c false otherwise.
   */
  bool isNamespacesEmpty () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * an XML Namespace with the given URI is contained in the XMLNamespaces of
   * this XMLToken.
   * 
   * @param uri a string, the uri for the namespace
   *
   * @return @c true if an XML Namespace with the given URI is contained in the
   * XMLNamespaces of this XMLToken,  @c false otherwise.
   */
  bool hasNamespaceURI(const std::string& uri) const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * an XML Namespace with the given prefix is contained in the XMLNamespaces of
   * this XMLToken.
   *
   * @param prefix a string, the prefix for the namespace
   * 
   * @return @c true if an XML Namespace with the given URI is contained in the
   * XMLNamespaces of this XMLToken, @c false otherwise.
   */
  bool hasNamespacePrefix(const std::string& prefix) const;


  /**
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
  bool hasNamespaceNS(const std::string& uri, const std::string& prefix) const;


  /**
   * Sets the XMLTripe (name, uri and prefix) of this XML element.
   * Nothing will be done if this XML element is a text node.
   *
   * @param triple XMLTriple to be added to this XML element.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setTriple(const XMLTriple& triple);


  /**
   * Returns the (unqualified) name of this XML element.
   *
   * @return the (unqualified) name of this XML element.
   */
  const std::string& getName () const;


  /**
   * Returns the namespace prefix of this XML element.
   *
   * @return the namespace prefix of this XML element.  
   *
   * @note If no prefix
   * exists, an empty string will be return.
   */
  const std::string& getPrefix () const;


  /**
   * Returns the namespace URI of this XML element.
   *
   * @return the namespace URI of this XML element.
   */
  const std::string& getURI () const;


  /**
   * Returns the text of this element.
   *
   * @return the characters of this XML text.
   */
  const std::string& getCharacters () const;


  /**
   * Appends characters to this XML text content.
   *
   * @param chars string, characters to append
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int append (const std::string& chars);

  
  /**
   * Returns the column at which this XMLToken occurred in the input
   * document or data stream.
   *
   * @return the column at which this XMLToken occurred.
   */
  unsigned int getColumn () const;


  /**
   * Returns the line at which this XMLToken occurred in the input document
   * or data stream.
   *
   * @return the line at which this XMLToken occurred.
   */
  unsigned int getLine () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an XML element.
   * 
   * @return @c true if this XMLToken is an XML element, @c false otherwise.
   */
  bool isElement () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an XML end element.
   * 
   * @return @c true if this XMLToken is an XML end element, @c false otherwise.
   */
  bool isEnd () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an XML end element for the given start element.
   * 
   * @param element XMLToken, element for which query is made.
   *
   * @return @c true if this XMLToken is an XML end element for the given
   * XMLToken start element, @c false otherwise.
   */
  bool isEndFor (const XMLToken& element) const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an end of file marker.
   * 
   * @return @c true if this XMLToken is an end of file (input) marker, @c false
   * otherwise.
   */
  bool isEOF () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an XML start element.
   * 
   * @return @c true if this XMLToken is an XML start element, @c false otherwise.
   */
  bool isStart () const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLToken is an XML text element.
   * 
   * @return @c true if this XMLToken is an XML text element, @c false otherwise.
   */
  bool isText () const;


  /**
   * Declares this XML start element is also an end element.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int setEnd ();


  /**
   * Declares this XMLToken is an end-of-file (input) marker.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int setEOF ();


  /**
   * Declares this XML start/end element is no longer an end element.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetEnd ();


  /** @cond doxygenLibsbmlInternal */
  /**
   * Writes this XMLToken to stream.
   *
   * @param stream XMLOutputStream, stream to which this XMLToken
   * is to be written.
   */
  void write (XMLOutputStream& stream) const;
  /** @endcond */

  /**
   * Prints a string representation of the underlying token stream, for
   * debugging purposes.
   */
  std::string toString ();


#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */

  /**
   * Inserts this XMLToken into stream.
   *
   * @param stream XMLOutputStream, stream to which the XMLToken
   * set is to be written.
   * @param token XMLToken, token to be written to stream.
   *
   * @return the stream with the token inserted.
   */
  LIBLAX_EXTERN
  friend
  XMLOutputStream& operator<< (XMLOutputStream& stream, const XMLToken& token);

  /** @endcond */

#endif  /* !SWIG */


protected:
  /** @cond doxygenLibsbmlInternal */

  XMLTriple     mTriple;
  XMLAttributes mAttributes;
  XMLNamespaces mNamespaces;

  std::string mChars;

  bool mIsStart;
  bool mIsEnd;
  bool mIsText;

  unsigned int mLine;
  unsigned int mColumn;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLToken_t structure and returns a pointer to it.
 *
 * @return pointer to new XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_create (void);


/**
 * Creates a new end element XMLToken_t structure with XMLTriple_t structure set
 * and returns a pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 *
 * @return pointer to new XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTriple (const XMLTriple_t *triple);


/**
 * Creates a new start element XMLToken_t structure with XMLTriple_t and XMLAttributes_t
 * structures set and returns a pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 * @param attr XMLAttributes_t structure to be set.
 *
 * @return pointer to new XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTripleAttr (const XMLTriple_t *triple,
			       const XMLAttributes_t *attr);


/**
 * Creates a new start element XMLToken_t structure with XMLTriple_t, XMLAttributes_t
 * and XMLNamespaces_t structures set and returns a pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 * @param attr XMLAttributes_t structure to be set.
 * @param ns XMLNamespaces_t structure to be set.
 *
 * @return pointer to new XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithTripleAttrNS (const XMLTriple_t *triple,
				 const XMLAttributes_t *attr,
				 const XMLNamespaces_t *ns);


/**
 * Creates a text XMLToken_t structure.
 *
 * @param text a string, the text to be added to the XMLToken_t structure
 *
 * @return pointer to new XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_createWithText (const char *text);


/**
 * Destroys this XMLToken_t structure.
 *
 * @param token XMLToken_t structure to be freed.
 **
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
void
XMLToken_free (XMLToken_t *token);


/**
 * Creates a deep copy of the given XMLToken_t structure
 * 
 * @param token the XMLToken_t structure to be copied
 * 
 * @return a (deep) copy of the given XMLToken_t structure.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
XMLToken_t *
XMLToken_clone (const XMLToken_t *token);


/**
 * Appends characters to this XML text content.
 *
 * @param token XMLToken_t structure to be appended to.
 * @param text string, characters to append
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 **
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_append (XMLToken_t *token, const char *text);


/**
 * Returns the text of this element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the characters of this XML text.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const char *
XMLToken_getCharacters (const XMLToken_t *token);


/**
 * Returns the column at which this XMLToken_t structure occurred.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the column at which this XMLToken_t structure occurred.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
unsigned int
XMLToken_getColumn (const XMLToken_t *token);


/**
 * Returns the line at which this XMLToken_t structure occurred.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the line at which this XMLToken_t structure occurred.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
unsigned int
XMLToken_getLine (const XMLToken_t *token);


/**
 * Returns the attributes of this element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the XMLAttributes_t of this XML element.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const XMLAttributes_t *
XMLToken_getAttributes (const XMLToken_t *token);


/**
 * Sets an XMLAttributes_t to this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be set.
 * @param attributes XMLAttributes_t to be set to this XMLToken_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 *
 * @note This function replaces the existing XMLAttributes_t with the new one.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_setAttributes (XMLToken_t *token, const XMLAttributes_t* attributes);


/**
 * Adds an attribute with the given local name to the attribute set in this XMLToken_t.
 * (namespace URI and prefix are empty)
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to which an attribute to be added.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the local name without namespace URI already exists in the
 * attribute set, its value will be replaced.
 *
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_addAttr ( XMLToken_t *token,  const char* name, const char* value );


/**
 * Adds an attribute with a prefix and namespace URI to the attribute set 
 * in this XMLToken_t optionally 
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to which an attribute to be added.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 * @param namespaceURI a string, the namespace URI of the attribute.
 * @param prefix a string, the prefix of the namespace
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if local name with the same namespace URI already exists in the
 * attribute set, its value and prefix will be replaced.
 *
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_addAttrWithNS ( XMLToken_t *token,  const char* name
	                , const char* value
    	                , const char* namespaceURI
	                , const char* prefix      );


/**
 * Adds an attribute with the given XMLTriple_t/value pair to the attribute set
 * in this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @note if local name with the same namespace URI already exists in the 
 * attribute set, its value and prefix will be replaced.
 *
 * @param token XMLToken_t structure to which an attribute to be added.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_addAttrWithTriple (XMLToken_t *token, const XMLTriple_t *triple, const char* value);


/**
 * Removes an attribute with the given index from the attribute set in
 * this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure from which an attribute to be removed.
 * @param n an integer the index of the resource to be deleted
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeAttr (XMLToken_t *token, int n);


/**
 * Removes an attribute with the given local name (without namespace URI) 
 * from the attribute set in this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure from which an attribute to be removed.
 * @param name   a string, the local name of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeAttrByName (XMLToken_t *token, const char* name);


/**
 * Removes an attribute with the given local name and namespace URI from 
 * the attribute set in this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure from which an attribute to be removed.
 * @param name   a string, the local name of the attribute.
 * @param uri    a string, the namespace URI of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeAttrByNS (XMLToken_t *token, const char* name, const char* uri);


/**
 * Removes an attribute with the given XMLTriple_t from the attribute set 
 * in this XMLToken_t.  
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure from which an attribute to be removed.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeAttrByTriple (XMLToken_t *token, const XMLTriple_t *triple);


/**
 * Clears (deletes) all attributes in this XMLToken_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure from which attributes to be removed.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_clearAttributes(XMLToken_t *token);


/**
 * Return the index of an attribute with the given local name and namespace URI.
 *
 * @param token XMLToken_t structure to be queried.
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return the index of an attribute with the given local name and namespace URI, 
 * or -1 if not present.
 *
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getAttrIndex (const XMLToken_t *token, const char* name, const char* uri);


/**
 * Return the index of an attribute with the given XMLTriple_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute for which 
 *        the index is required.
 *
 * @return the index of an attribute with the given XMLTriple_t, or -1 if not present.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getAttrIndexByTriple (const XMLToken_t *token, const XMLTriple_t *triple);


/**
 * Return the number of attributes in the attributes set.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the number of attributes in the attributes set in this XMLToken_t.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getAttributesLength (const XMLToken_t *token);


/**
 * Return the local name of an attribute in the attributes set in this 
 * XMLToken_t (by position).
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute whose local name 
 * is required.
 *
 * @return the local name of an attribute in this list (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned.  Use XMLToken_hasAttr(...) 
 * to test for the attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrName (const XMLToken_t *token, int index);


/**
 * Return the prefix of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute whose prefix is 
 * required.
 *
 * @return the namespace prefix of an attribute in the attribute set
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned. Use XMLToken_hasAttr(...) to test for the attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrPrefix (const XMLToken_t *token, int index);


/**
 * Return the prefixed name of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute whose prefixed 
 * name is required.
 *
 * @return the prefixed name of an attribute in the attribute set 
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned.  Use XMLToken_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrPrefixedName (const XMLToken_t *token, int index);


/**
 * Return the namespace URI of an attribute in the attribute set in this 
 * XMLToken (by position).
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute whose namespace 
 * URI is required.
 *
 * @return the namespace URI of an attribute in the attribute set (by position).
 *
 * @note If index is out of range, an empty string will be returned.  Use
 * XMLToken_hasAttr(index) to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrURI (const XMLToken_t *token, int index);


/**
 * Return the value of an attribute in the attribute set in this XMLToken_t
 * (by position).
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute whose value is 
 * required.
 *
 * @return the value of an attribute in the attribute set (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned. Use XMLToken_hasAttr(...)
 * to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrValue (const XMLToken_t *token, int index);


/**
 * Return a value of an attribute with the given local name (without namespace URI).
 *
 * @param token XMLToken_t structure to be queried.
 * @param name a string, the local name of the attribute whose value is required.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the given local name (without namespace URI) 
 * does not exist, an empty string will be returned.  
 * Use XMLToken_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByName (const XMLToken_t *token, const char* name);


/**
 * Return a value of an attribute with the given local name and namespace URI.
 *
 * @param token XMLToken_t structure to be queried.
 * @param name a string, the local name of the attribute whose value is required.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the 
 * given local name and namespace URI does not exist, an empty string will be 
 * returned.  
 * Use XMLToken_hasAttr(name, uri) to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByNS (const XMLToken_t *token, const char* name, const char* uri);


/**
 * Return a value of an attribute with the given XMLTriple_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute whose 
 *        value is required.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the
 * given XMLTriple_t does not exist, an empty string will be returned.  
 * Use XMLToken_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getAttrValueByTriple (const XMLToken_t *token, const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given index exists in the attribute set in this 
 * XMLToken.
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, the position of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given index exists in 
 * the attribute set in this XMLToken_t, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasAttr (const XMLToken_t *token, int index);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name (without namespace URI) 
 * exists in the attribute set in this XMLToken_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param name a string, the local name of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name 
 * (without namespace URI) exists in the attribute set in this XMLToken_t, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasAttrWithName (const XMLToken_t *token, const char* name);

/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name and namespace URI exists 
 * in the attribute set in this XMLToken_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name 
 * and namespace URI exists in the attribute set in this XMLToken_t, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasAttrWithNS (const XMLToken_t *token, const char* name, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given XML triple exists in the attribute set in 
 * this XMLToken_t
 *
 * @param token XMLToken_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute 
 *
 * @return @c non-zero (true) if an attribute with the given XML triple exists
 * in the attribute set in this XMLToken_t, @c zero (false) otherwise.
 *
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasAttrWithTriple (const XMLToken_t *token, const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the attribute set in this XMLToken_t set is empty.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if the attribute set in this XMLToken_t is empty, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isAttributesEmpty (const XMLToken_t *token);



/**
 * Returns the XML namespace declarations for this XML element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the XML namespace declarations for this XML element.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const XMLNamespaces_t *
XMLToken_getNamespaces (const XMLToken_t *token);


/**
 * Sets an XMLnamespaces_t to this XML element.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be queried.
 * @param namespaces XMLNamespaces_t to be set to this XMLToken_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note This function replaces the existing XMLNamespaces_t with the new one.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_setNamespaces(XMLToken_t *token, const XMLNamespaces_t* namespaces);


/**
 * Appends an XML namespace prefix and URI pair to this XMLToken_t.
 * If there is an XML namespace with the given prefix in this XMLToken_t, 
 * then the existing XML namespace will be overwritten by the new one.
 *
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be queried.
 * @param uri a string, the uri for the namespace
 * @param prefix a string, the prefix for the namespace
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_addNamespace (XMLToken_t *token, const char* uri, const char* prefix);


/**
 * Removes an XML Namespace stored in the given position of the XMLNamespaces_t
 * of this XMLNode_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeNamespace (XMLToken_t *token, int index);


/**
 * Removes an XML Namespace with the given prefix.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_removeNamespaceByPrefix (XMLToken_t *token, const char* prefix);


/**
 * Clears (deletes) all XML namespace declarations in the XMLNamespaces_t 
 * of this XMLNode_t.
 * Nothing will be done if this XMLToken_t is not a start element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_clearNamespaces (XMLToken_t *token);


/**
 * Look up the index of an XML namespace declaration by URI.
 *
 * @param token XMLToken_t structure to be queried.
 * @param uri a string, uri of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getNamespaceIndex (const XMLToken_t *token, const char* uri);


/**
 * Look up the index of an XML namespace declaration by prefix.
 *
 * @param token XMLToken_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getNamespaceIndexByPrefix (const XMLToken_t *token, const char* prefix);


/**
 * Returns the number of XML namespaces stored in the XMLNamespaces_t 
 * of this XMLNode_t.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the number of namespaces in this list.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_getNamespacesLength (const XMLToken_t *token);


/**
 * Look up the prefix of an XML namespace declaration by position.
 *
 * Callers should use getNamespacesLength() to find out how many 
 * namespaces are stored in the XMLNamespaces_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 * 
 * @return the prefix of an XML namespace declaration in the XMLNamespaces_t
 * (by position).  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getNamespacePrefix (const XMLToken_t *token, int index);


/**
 * Look up the prefix of an XML namespace declaration by its URI.
 *
 * @param token XMLToken_t structure to be queried.
 * @param uri a string, uri of the required namespace.
 *
 * @return the prefix of an XML namespace declaration given its URI.  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getNamespacePrefixByURI (const XMLToken_t *token, const char* uri);


/**
 * Look up the URI of an XML namespace declaration by its position.
 *
 * @param token XMLToken_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 *
 * @return the URI of an XML namespace declaration in the XMLNamespaces_t
 * (by position).  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getNamespaceURI (const XMLToken_t *token, int index);


/**
 * Look up the URI of an XML namespace declaration by its prefix.
 *
 * @param token XMLToken_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the URI of an XML namespace declaration given its prefix.  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
char* 
XMLToken_getNamespaceURIByPrefix (const XMLToken_t *token, const char* prefix);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the XMLNamespaces_t of this XMLToken_t is empty.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if the XMLNamespaces_t of this XMLToken_t is empty, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isNamespacesEmpty (const XMLToken_t *token);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given URI is contained in the XMLNamespaces_t of
 * this XMLToken_t.
 * 
 * @param token XMLToken_t structure to be queried.
 * @param uri a string, the uri for the namespace
 *
 * @return @c no-zero (true) if an XML Namespace with the given URI is 
 * contained in the XMLNamespaces_t of this XMLToken_t,  @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasNamespaceURI(const XMLToken_t *token, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given prefix is contained in the XMLNamespaces_t of
 * this XMLToken_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c no-zero (true) if an XML Namespace with the given URI is 
 * contained in the XMLNamespaces_t of this XMLToken_t, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasNamespacePrefix(const XMLToken_t *token, const char* prefix);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given uri/prefix pair is contained in the 
 * XMLNamespaces_t ofthis XMLToken_t.
 *
 * @param token XMLToken_t structure to be queried.
 * @param uri a string, the uri for the namespace
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c non-zero (true) if an XML Namespace with the given uri/prefix pair is 
 * contained in the XMLNamespaces_t of this XMLToken_t,  @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_hasNamespaceNS(const XMLToken_t *token, const char* uri, const char* prefix);
                        

/**
 * Sets the XMLTriple_t (name, uri and prefix) of this XML element.
 * Nothing will be done if this XML element is a text node.
 *
 * @param token XMLToken_t structure to be queried. 
 * @param triple an XMLTriple_t, the XML triple to be set to this XML element.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int 
XMLToken_setTriple(XMLToken_t *token, const XMLTriple_t *triple);


/**
 * Returns the (unqualified) name of this XML element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the (unqualified) name of this XML element.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const char *
XMLToken_getName (const XMLToken_t *token);


/**
 * Returns the namespace prefix of this XML element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the namespace prefix of this XML element.  
 *
 * @note If no prefix
 * exists, an empty string will be return.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const char *
XMLToken_getPrefix (const XMLToken_t *token);


/**
 * Returns the namespace URI of this XML element.
 *
 * @param token XMLToken_t structure to be queried.
 *
 * @return the namespace URI of this XML element.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
const char *
XMLToken_getURI (const XMLToken_t *token);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an XML element.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLToken_t structure is an XML element, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isElement (const XMLToken_t *token);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an XML end element.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLToken_t structure is an XML end element, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isEnd (const XMLToken_t *token); 


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an XML end element for the given start element.
 * 
 * @param token XMLToken_t structure to be queried.
 * @param element XMLToken_t structure, element for which query is made.
 *
 * @return @c non-zero (true) if this XMLToken_t structure is an XML end element for the given
 * XMLToken_t structure start element, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isEndFor (const XMLToken_t *token, const XMLToken_t *element);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an end of file marker.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLToken_t structure is an end of file (input) marker, @c zero (false)
 * otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isEOF (const XMLToken_t *token);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an XML start element.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c true if this XMLToken_t structure is an XML start element, @c false otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isStart (const XMLToken_t *token);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLToken_t structure is an XML text element.
 * 
 * @param token XMLToken_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLToken_t structure is an XML text element, @c zero (false) otherwise.
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_isText (const XMLToken_t *token);


/**
 * Declares this XML start element is also an end element.
 *
 * @param token XMLToken_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_setEnd (XMLToken_t *token);


/**
 * Declares this XMLToken_t structure is an end-of-file (input) marker.
 *
 * @param token XMLToken_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_setEOF (XMLToken_t *token);


/**
 * Declares this XML start/end element is no longer an end element.
 *
 * @param token XMLToken_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLToken_t
 */
LIBLAX_EXTERN
int
XMLToken_unsetEnd (XMLToken_t *token);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLToken_h */

