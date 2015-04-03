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
 * @sbmlbrief{core} A token in an XML stream.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The libSBML XML parser interface can read an XML file or data stream and
 * convert the contents into tokens.  The tokens represent items in the XML
 * stream, either XML elements (start or end tags) or text that appears as
 * content inside an element.  The XMLToken class is libSBML's low-level
 * representation of these entities.
 *
 * Each XMLToken has the following information associated with it:
 * <ol>
 * <li> <em>Qualified name</em>: every XML element or XML attribute has a
 * name (e.g., for the element <code>&lt;mytag&gt;</code>, the name is
 * <code>"mytag"</code>), but this name may be qualified with a namespace
 * (e.g., it may appear as <code>&lt;someNamespace:mytag&gt;</code> in the
 * input).  An XMLToken stores the name of a token, along with any namespace
 * qualification present, through the use of an XMLTriple object.  This
 * object stores the bare name of the element, its XML namespace prefix (if
 * any), and the XML namespace with which that prefix is associated.
 * <li> @em Namespaces: An XML token can have one or more XML namespaces
 * associated with it.  These namespaces may be specified explicitly on the
 * element or inherited from parent elements.  In libSBML, a list of
 * namespaces is stored in an XMLNamespaces object.  An XMLToken possesses a
 * field for storing an XMLNamespaces object.
 * <li> @em Attributes: XML elements can have attributes associated with
 * them, and these attributes can have values assigned to them.  The set of
 * attribute-value pairs is stored in an XMLAttributes object stored in an
 * XMLToken object.  (Note: only elements can have attributes&mdash;text
 * blocks cannot have them in XML.)
 * <li> @em Line number: the line number in the input where the token appears.
 * <li> @em Column number: the column number in the input where the token appears.
 * </ol>
 *
 * The XMLToken class serves as base class for XMLNode.  XML lends itself to
 * a tree-structured representation, and in libSBML, the nodes in an XML
 * document tree are XMLNode objects.  Most higher-level libSBML classes and
 * methods that offer XML-level functionality (such as the methods on SBase
 * for interacting with annotations) work with XMLNode objects rather than
 * XMLToken objects directly.
 *
 * @see XMLNode
 * @see XMLTriple
 * @see XMLAttributes
 * @see XMLNamespaces
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_only_for_start_elements
 *
 * @par
 * This operation only makes sense for XML start elements.  This
 * method will return @sbmlconstant{LIBSBML_INVALID_XML_OPERATION,
 * OperationReturnValues_t} if this XMLToken object is not an XML start
 * element.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_overwrites_existing_attribute
 *
 * @note If an attribute with the same name and XML namespace URI already
 * exists on this XMLToken object, then the previous value will be replaced
 * with the new value provided to this method.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_index_out_of_range_behavior
 *
 * @note If @p index is out of range, this method will return an empty
 * string.  XMLToken::hasAttr(@if java int@endif) can be used to test for an
 * attribute's existence explicitly, and XMLToken::getAttributesLength() can
 * be used to find out the number of attributes possessed by this token.
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
   * Creates a new empty XMLToken object.
   */
  XMLToken ();


  /**
   * Creates an XML start element with attributes and namespace declarations.
   *
   * @param triple an XMLTriple object describing the start tag.
   *
   * @param attributes XMLAttributes, the attributes to set on the element to
   * be created.
   *
   * @param namespaces XMLNamespaces, the namespaces to set on the element to
   * be created.
   *
   * @param line an unsigned int, the line number to associate with the
   * token (default = 0).
   *
   * @param column an unsigned int, the column number to associate with the
   * token (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&      triple
            , const XMLAttributes&  attributes
            , const XMLNamespaces&  namespaces
            , const unsigned int    line   = 0
            , const unsigned int    column = 0 );


  /**
   * Creates an XML start element with attributes.
   *
   * @param triple an XMLTriple object describing the start tag.
   *
   * @param attributes XMLAttributes, the attributes to set on the element to
   * be created.
   *
   * @param line an unsigned int, the line number to associate with the
   * token (default = 0).
   *
   * @param column an unsigned int, the column number to associate with the
   * token (default = 0).
   *
   * The XML namespace component of this XMLToken object will be left empty.
   * See the other variants of the XMLToken constructors for versions that
   * take namespace arguments.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&      triple
            , const XMLAttributes&  attributes
            , const unsigned int    line   = 0
            , const unsigned int    column = 0 );


  /**
   * Creates an XML end element.
   *
   * @param triple an XMLTriple object describing the end tag.
   *
   * @param line an unsigned int, the line number to associate with the
   * token (default = 0).
   *
   * @param column an unsigned int, the column number to associate with the
   * token (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const XMLTriple&    triple
            , const unsigned int  line   = 0
            , const unsigned int  column = 0 );


  /**
   * Creates a text object.
   *
   * @param chars a string, the text to be added to the XMLToken object.
   *
   * @param line an unsigned int, the line number to associate with the
   * token (default = 0).
   *
   * @param column an unsigned int, the column number to associate with the
   * token (default = 0).
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p chars is @c NULL.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLToken (  const std::string&  chars
            , const unsigned int  line   = 0
            , const unsigned int  column = 0 );


  /**
   * Destroys this XMLToken object.
   */
  virtual ~XMLToken ();


  /**
   * Copy constructor; creates a copy of this XMLToken object.
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
   * Returns the attributes of the XML element represented by this token.
   *
   * @return the attributes of this XML element, stored in an XMLAttributes
   * object.
   */
  const XMLAttributes& getAttributes () const;


  /**
   * Sets the attributes on the XML element represented by this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param attributes an XMLAttributes object to be assigned to this
   * XMLToken object, thereby setting the XML attributes associated with this
   * token.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note This function replaces any existing XMLAttributes object
   * on this XMLToken object with the one given by @p attributes.
   */
  int setAttributes(const XMLAttributes& attributes);


  /**
   * Adds an attribute to the XML element represented by this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param name a string, the so-called "local part" of the attribute name;
   * that is, the attribute name without any namespace qualifier or prefix.
   *
   * @param value a string, the value assigned to the attribute.
   *
   * @param namespaceURI a string, the XML namespace URI of the attribute.
   *
   * @param prefix a string, the prefix for the XML namespace.
   *
   * Recall that in XML, the complete form of an attribute on an XML element
   * is the following:
   * <center>
   * <code>prefix:name="value"</code>
   * </center>
   * The <code>name</code> part is the name of the attribute, the
   * <code>"value"</code> part is the value assigned to the attribute (and
   * it is always a quoted string), and the <code>prefix</code> part is
   * an optional XML namespace prefix.  Internally in libSBML, this data
   * is stored in an XMLAttributes object associated with this XMLToken.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @copydetails doc_note_overwrites_existing_attribute
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int addAttr (  const std::string& name
               , const std::string& value
               , const std::string& namespaceURI = ""
               , const std::string& prefix = "");


  /**
   * Adds an attribute to the XML element represented by this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param triple an XMLTriple object defining the attribute, its value,
   * and optionally its XML namespace (if any is provided).
   *
   * @param value a string, the value assigned to the attribute.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @copydetails doc_note_overwrites_existing_attribute
   */
  int addAttr ( const XMLTriple& triple, const std::string& value);


  /**
   * Removes the <em>n</em>th attribute from the XML element represented by
   * this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param n an integer the index of the resource to be deleted
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute on this
   * element at the given index @p n.
   *
   * @see getAttrIndex(const XMLTriple& triple) const
   * @see getAttrIndex(const std::string& name, const std::string& uri) const
   * @see getAttributesLength()
   */
  int removeAttr (int n);


  /**
   * Removes an attribute from the XML element represented by this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param name   a string, the name of the attribute to be removed.
   * @param uri    a string, the XML namespace URI of the attribute to be removed.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute on this
   * element with the given @p name (and @p uri if specified).
   *
   * @see hasAttr(const std::string name, const std::string uri) const
   */
  int removeAttr (const std::string& name, const std::string& uri = "");


  /**
   * Removes an attribute from the XML element represented by this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param triple an XMLTriple describing the attribute to be removed.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute on this
   * element matching the properties of the given @p triple.
   *
   * @see hasAttr(const XMLTriple& triple) const
   */
  int removeAttr (const XMLTriple& triple);


  /**
   * Removes all attributes of this XMLToken object.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   */
  int clearAttributes();


  /**
   * Returns the index of the attribute with the given name and namespace
   * URI.
   *
   * @param name a string, the name of the attribute.
   * @param uri  a string, the namespace URI of the attribute.
   *
   * @return the index of an attribute with the given local name and
   * namespace URI, or <code>-1</code> if it is not present on this token.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int getAttrIndex (const std::string& name, const std::string& uri="") const;


  /**
   * Returns the index of the attribute defined by the given XMLTriple
   * object.
   *
   * @param triple the XMLTriple object that defines the attribute whose
   * index is being sought.
   *
   * @return the index of an attribute with the given XMLTriple object, or
   * <code>-1</code> if no such attribute is present on this token.
   */
  int getAttrIndex (const XMLTriple& triple) const;


  /**
   * Returns the number of attributes on this XMLToken object.
   *
   * @return the number of attributes possessed by this token.
   *
   * @see hasAttr(@if java int@endif)
   */
  int getAttributesLength () const;


  /**
   * Returns the name of the <em>n</em>th attribute in this token's list of
   * attributes.
   *
   * @param index an integer, the position of the attribute whose name
   * is being sought.
   *
   * @return the name of the attribute located at position @p n in the list
   * of attributes possessed by this XMLToken object.
   *
   * @copydetails doc_note_index_out_of_range_behavior 
   *
   * @see hasAttr(@if java int@endif)
   * @see getAttributesLength()
   */
  std::string getAttrName (int index) const;


  /**
   * Returns the prefix of the <em>n</em>th attribute in this token's list of
   * attributes.
   *
   * @param index an integer, the position of the attribute whose prefix is
   * being sought.
   *
   * @return the XML namespace prefix of the attribute located at position @p
   * n in the list of attributes possessed by this XMLToken object.
   *
   * @copydetails doc_note_index_out_of_range_behavior
   *
   * @see hasAttr(@if java int@endif)
   * @see getAttributesLength()
   */
  std::string getAttrPrefix (int index) const;


  /**
   * Returns the prefixed name of the <em>n</em>th attribute in this token's
   * list of attributes.
   *
   * In this context, <em>prefixed name</em> means the name of the attribute
   * prefixed with the XML namespace prefix assigned to the attribute.  This
   * will be a string of the form <code>prefix:name</code>.
   *
   * @param index an integer, the position of the attribute whose prefixed
   * name is being sought.
   *
   * @return the prefixed name of the attribute located at position @p
   * n in the list of attributes possessed by this XMLToken object.
   *
   * @copydetails doc_note_index_out_of_range_behavior
   */
  std::string getAttrPrefixedName (int index) const;


  /**
   * Returns the XML namespace URI of the <em>n</em>th attribute in this
   * token's list of attributes.
   *
   * @param index an integer, the position of the attribute whose namespace
   * URI is being sought.
   *
   * @return the XML namespace URI of the attribute located at position @p n
   * in the list of attributes possessed by this XMLToken object.
   *
   * @copydetails doc_note_index_out_of_range_behavior
   */
  std::string getAttrURI (int index) const;


  /**
   * Returns the value of the <em>n</em>th attribute in this token's list of
   * attributes.
   *
   * @param index an integer, the position of the attribute whose value is
   * required.
   *
   * @return the value of the attribute located at position @p n in the list
   * of attributes possessed by this XMLToken object.
   *
   * @copydetails doc_note_index_out_of_range_behavior
   */
  std::string getAttrValue (int index) const;


  /**
   * Returns the value of the attribute with a given name and XML namespace URI.
   *
   * @param name a string, the name of the attribute whose value is being
   * sought.
   *
   * @param uri a string, the XML namespace URI of the attribute.
   *
   * @return The value of the attribute, as a string.
   *
   * @note If an attribute with the given @p name and @p uri does not exist
   * on this token object, this method will return an empty string.
   * XMLToken::hasAttr(@if java String, String@endif) can be used to test
   * explicitly for the presence of an attribute with a given name and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  std::string getAttrValue (const std::string name, const std::string uri="") const;


  /**
   * Returns the value of the attribute specified by a given XMLTriple object.
   *
   * @param triple an XMLTriple describing the attribute whose value is being
   * sought.
   *
   * @return The value of the attribute, as a string.
   *
   * @note If an attribute defined by the given @p triple does not exist on
   * this token object, this method will return an empty string.
   * XMLToken::hasAttr(@if java XMLTriple@endif) can be used to test
   * explicitly for the existence of an attribute with the properties of
   * a given triple.
   */
  std::string getAttrValue (const XMLTriple& triple) const;


  /**
   * Returns @c true if an attribute with the given index exists.
   *
   * @param index an integer, the position of the attribute.
   *
   * @return @c true if this token object possesses an attribute with the
   * given index, @c false otherwise.
   */
  bool hasAttr (int index) const;


  /**
   * Returns @c true if an attribute with a given name and namespace URI
   * exists.
   *
   * @param name a string, the name of the attribute being sought.
   *
   * @param uri a string, the XML namespace URI of the attribute being
   * sought.
   *
   * @return @c true if an attribute with the given local name and namespace
   * URI exists in the list of attributes on this token object, @c false
   * otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool hasAttr (const std::string name, const std::string uri="") const;


  /**
   * Returns @c true if an attribute defined by a given XMLTriple object
   * exists.
   *
   * @param triple an XMLTriple object describing the attribute being sought.
   *
   * @return @c true if an attribute matching the properties of the given
   * XMLTriple object exists in the list of attributes on this token, @c
   * false otherwise.
   */
  bool hasAttr (const XMLTriple& triple) const;


  /**
   * Returns @c true if this token has no attributes.
   *
   * @return @c true if the list of attributes on XMLToken object is empty,
   * @c false otherwise.
   */
  bool isAttributesEmpty () const;


  /**
   * Returns the XML namespaces declared for this token.
   *
   * @return the XML namespace declarations for this XML element.
   */
  const XMLNamespaces& getNamespaces () const;


  /**
   * Sets the XML namespaces on this XML element.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param namespaces the XMLNamespaces object to be assigned to this XMLToken object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note This function replaces any existing XMLNamespaces object on this
   * XMLToken object with the new one given by @p namespaces.
   */
  int setNamespaces(const XMLNamespaces& namespaces);


  /**
   * Appends an XML namespace declaration to this token.
   *
   * The namespace added will be defined by the given XML namespace URI and
   * an optional prefix.  If this XMLToken object already possesses an XML
   * namespace declaration with the given @p prefix, then the existing XML
   * namespace URI will be overwritten by the new one given by @p uri.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param uri a string, the XML namespace URI for the namespace.
   * 
   * @param prefix a string, the namespace prefix to use.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int addNamespace (const std::string& uri, const std::string& prefix = "");


  /**
   * Removes the <em>n</em>th XML namespace declaration.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param index an integer, the position of the namespace to be removed.
   * The position in this context refers to the position of the namespace in
   * the XMLNamespaces object stored in this XMLToken object.  Callers can
   * use one of the <code>getNamespace___()</code> methods to find the index
   * number of a given namespace.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * @see getNamespaceIndex(@if java String uri@endif)
   * @see getNamespaceIndexByPrefix(@if java String prefix@endif)
   * @see getNamespacesLength()
   */
  int removeNamespace (int index);


  /**
   * Removes an XML namespace declaration having a given prefix.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param prefix a string, the prefix of the namespace to be removed.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   * is returned if there is no namespace with the given @p prefix on this
   * element.
   *
   * @see getNamespaceIndexByPrefix(@if java String prefix@endif)
   */
  int removeNamespace (const std::string& prefix);


  /**
   * Removes all XML namespace declarations from this token.
   *
   * @copydetails doc_only_for_start_elements 
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int clearNamespaces ();


  /**
   * Returns the index of an XML namespace declaration based on its URI.
   *
   * @param uri a string, the XML namespace URI of the sought-after namespace.
   *
   * @return the index of the given declaration, or <code>-1</code> if
   * no such namespace URI is present on this XMLToken object.
   */
  int getNamespaceIndex (const std::string& uri) const;


  /**
   * Returns the index of an XML namespace declaration based on its prefix.
   *
   * @param prefix a string, the prefix of the sought-after XML namespace.
   *
   * @return the index of the given declaration, or <code>-1</code> if
   * no such namespace URI is present on this XMLToken object.
   */
  int getNamespaceIndexByPrefix (const std::string& prefix) const;


  /**
   * Returns the number of XML namespaces declared on this token.
   *
   * @return the number of XML namespaces stored in the XMLNamespaces
   * object of this XMLToken object.
   */
  int getNamespacesLength () const;


  /**
   * Returns the prefix of the <em>n</em>th XML namespace declaration.
   *
   * @param index an integer, position of the required prefix.
   *
   * @return the prefix of an XML namespace declaration in the XMLNamespaces
   * (by position).
   *
   * @note If @p index is out of range, this method will return an empty
   * string.  XMLToken::getNamespacesLength() can be used to find out how
   * many namespaces are defined on this XMLToken object.
   *
   * @see getNamespacesLength()
   */
  std::string getNamespacePrefix (int index) const;


  /**
   * Returns the prefix associated with a given XML namespace URI on this
   * token.
   *
   * @param uri a string, the URI of the namespace whose prefix is being
   * sought.
   *
   * @return the prefix of an XML namespace declaration on this XMLToken object.
   *
   * @note If there is no XML namespace with the given @p uri declared on
   * this XMLToken object, this method will return an empty string.
   */
  std::string getNamespacePrefix (const std::string& uri) const;


  /**
   * Returns the URI of the <em>n</em>th XML namespace declared on this token. 
   *
   * @param index an integer, the position of the sought-after XML namespace URI.
   *
   * @return the URI of the <em>n</em>th XML namespace stored in the
   * XMLNamespaces object in this XMLToken object.
   *
   * @note If @p index is out of range, this method will return an empty string.
   *
   * @see getNamespacesLength()
   */
  std::string getNamespaceURI (int index) const;


  /**
   * Returns the URI of an XML namespace with a given prefix.
   *
   * @param prefix a string, the prefix of the sought-after XML namespace URI.
   *
   * @return the URI of an XML namespace declaration given its prefix.
   *
   * @note If there is no XML namespace with the given @p prefix stored in
   * the XMLNamespaces object of this XMLToken object, this method will
   * return an empty string.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  std::string getNamespaceURI (const std::string& prefix = "") const;


  /**
   * Returns @c true if there are no namespaces declared on this token.
   *
   * @return @c true if the XMLNamespaces object stored in this XMLToken
   * token is empty, @c false otherwise.
   */
  bool isNamespacesEmpty () const;


  /**
   * Returns @c true if this token has an XML namespace with a given URI.
   *
   * @param uri a string, the URI of the XML namespace.
   *
   * @return @c true if an XML namespace with the given URI is contained in
   * the XMLNamespaces object of this XMLToken object, @c false otherwise.
   */
  bool hasNamespaceURI(const std::string& uri) const;


  /**
   * Returns @c true if this token has an XML namespace with a given prefix.
   *
   * @param prefix a string, the prefix for the XML namespace.
   *
   * @return @c true if an XML Namespace with the given URI is contained in the
   * XMLNamespaces of this XMLToken, @c false otherwise.
   */
  bool hasNamespacePrefix(const std::string& prefix) const;


  /**
   * Returns @c true if this token has an XML namespace with a given prefix
   * and URI combination.
   *
   * @param uri a string, the URI for the namespace.
   * @param prefix a string, the prefix for the namespace.
   *
   * @return @c true if an XML namespace with the given URI/prefix pair is
   * contained in the XMLNamespaces object of this XMLToken object, @c false
   * otherwise.
   */
  bool hasNamespaceNS(const std::string& uri, const std::string& prefix) const;


  /**
   * Sets the name, namespace prefix and namespace URI of this token.
   *
   * @copydetails doc_only_for_start_elements
   *
   * @param triple the new XMLTriple to use for this XMLToken object.  If
   * this XMLToken already had an XMLTriple object stored within it, that
   * object will be replaced.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setTriple(const XMLTriple& triple);


  /**
   * Returns the (unqualified) name of token.
   *
   * @return the (unqualified) name of token.
   */
  const std::string& getName () const;


  /**
   * Returns the XML namespace prefix of token.
   *
   * @return the XML namespace prefix of token.
   *
   * @note If no XML namespace prefix has been assigned to this token, this
   * method will return an empty string.
   */
  const std::string& getPrefix () const;


  /**
   * Returns the XML namespace URI of token.
   *
   * @return the XML namespace URI of token.
   */
  const std::string& getURI () const;


  /**
   * Returns the character text of token.
   *
   * @return the characters of this XML token.  If this token is not a
   * text token (i.e., it's an XML element and not character content),
   * then this will return an empty string.
   *
   * @see isText()
   * @see isElement()
   */
  const std::string& getCharacters () const;


  /**
   * Appends characters to the text content of token.
   *
   * This method only makes sense for XMLToken objects that contains text.
   * If this method is called on a token that represents an XML start or end
   * tag, it will return the code @sbmlconstant{LIBSBML_OPERATION_FAILED,
   * OperationReturnValues_t}.
   *
   * @param chars string, characters to append to the text of this token.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isText()
   * @see isElement()
   */
  int append (const std::string& chars);


  /**
   * Returns the column number at which this token occurs in the input.
   *
   * @return the column at which this XMLToken occurred.
   */
  unsigned int getColumn () const;


  /**
   * Returns the line number at which this token occurs in the input.
   *
   * @return the line at which this XMLToken occurred.
   */
  unsigned int getLine () const;


  /**
   * Returns @c true if this token represents an XML element.
   *
   * This generic predicate returns @c true if the element is either a start
   * or end tag, and @c false if it's a text object.  The related methods
   * XMLToken:isStart(), XMLToken::isEnd() and XMLToken::isText() are more
   * specific predicates.
   *
   * @return @c true if this XMLToken object represents an XML element, @c
   * false otherwise.
   *
   * @see isStart()
   * @see isEnd()
   * @see isText()
   */
  bool isElement () const;


  /**
   * Returns @c true if this token represents an XML end element.
   *
   * @return @c true if this XMLToken object represents an XML end element,
   * @c false otherwise.
   *
   * @see isStart()
   * @see isElement()
   * @see isText()
   */
  bool isEnd () const;


  /**
   * Returns @c true if this token represents an XML end element for a
   * particular start element.
   *
   * @param element XMLToken, the element with which the current object
   * should be compared to determined whether the current object is a
   * start element for the given one.
   *
   * @return @c true if this XMLToken object represents an XML end tag for
   * the start tag given by @p element, @c false otherwise.
   *
   * @see isElement()
   * @see isStart()
   * @see isEnd()
   * @see isText()
   */
  bool isEndFor (const XMLToken& element) const;


  /**
   * Returns @c true if this token is an end of file marker.
   *
   * @return @c true if this XMLToken object represents the end of the input,
   * @c false otherwise.
   *
   * @see setEOF()
   */
  bool isEOF () const;


  /**
   * Returns @c true if this token represents an XML start element.
   *
   * @return @c true if this XMLToken is an XML start element, @c false otherwise.
   *
   * @see isElement()
   * @see isEnd()
   * @see isText()
   */
  bool isStart () const;


  /**
   * Returns @c true if this token represents an XML text element.
   *
   * @return @c true if this XMLToken is an XML text element, @c false otherwise.
   *
   * @see isElement()
   * @see isStart()
   * @see isEnd()
   */
  bool isText () const;


  /**
   * Declares that this token represents an XML element end tag.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isStart()
   * @see isEnd()
   */
  int setEnd ();


  /**
   * Declares that this token is an end-of-file/input marker.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see isEOF()
   */
  int setEOF ();


  /**
   * Declares that this token no longer represents an XML start/end element.
   *
   * @copydetails doc_returns_success_code
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
   * Prints a string representation of the underlying token stream.
   *
   * This method is intended for debugging purposes.
   *
   * @return a text string representing this XMLToken object.
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @copydetails doc_note_overwrites_existing_attribute
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
 * @param token XMLToken_t structure to which an attribute to be added.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @copydetails doc_note_overwrites_existing_attribute
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 *        the index is being sought.
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
 * is being sought.
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
 * name is being sought.
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
 * URI is being sought.
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
 * @param name a string, the local name of the attribute whose value is being sought.
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
 * @param name a string, the local name of the attribute whose value is being sought.
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
 *        value is being sought.
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * Returns @c true or @c false depending on whether
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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
 * @copydetails doc_returns_success_code
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

