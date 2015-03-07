/**
 * @file    XMLAttributes.h
 * @brief   XMLAttributes are a list of name/value pairs for XML elements
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
 * @class XMLAttributes
 * @sbmlbrief{core} A list of attributes on an XML element.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * In libSBML's XML interface layer, attributes on an element are stored as a
 * list of values kept in an XMLAttributes object.  XMLAttributes has methods
 * for adding and removing individual attributes as well as performing other
 * actions on the list of attributes.  Classes in libSBML that represent nodes
 * in an XML document (i.e., XMLNode and its parent class, XMLToken) use
 * XMLAttributes objects to manage attributes on XML elements.
 *
 * Attributes on an XML element can be written in one of two forms:
 * @li <code>name="value"</code>
 * @li <code>prefix:name="value"</code>
 *
 * An attribute in XML must always have a value, and the value must always be
 * a quoted string; i.e., it is always <code>name="value"</code> and not
 * <code>name=value</code>.  An empty value is represented simply as an
 * empty string; i.e., <code>name=""</code>.
 *
 * In cases when a <code>prefix</code> is provided with an attribute name,
 * general XML validity rules require that the prefix is an XML namespace
 * prefix that has been declared somewhere else (possibly as an another
 * attribute on the same element).  However, the XMLAttributes class does
 * @em not test for the proper existence or declaration of XML
 * namespaces&mdash;callers must arrange to do this themselves in some other
 * way.  This class only provides facilities for tracking and manipulating
 * attributes and their prefix/URI/name/value components.
 *
 * @copydetails doc_note_attributes_are_unordered
 *
 * @see XMLTriple
 * @see XMLNode
 * @see XMLToken
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_overwrites_existing_values
 *
 * @note If an attribute with the same name and XML namespace URI already
 * exists in the list of attributes held by this XMLAttributes object, then
 * the previous value of that attribute will be replaced with the new value
 * provided to this method.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_check_number_first
 *
 * @note If @p index is out of range, this method will return an empty
 * string.  Callers should use XMLAttributes::getLength() to check the number
 * of attributes contained in this object or XMLAttributes::hasAttribute(int
 * index) const to test for the existence of an attribute at a given
 * position.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_attributes_are_unordered
 *
 * @note Note that although XMLAttributes provides operations that can
 * manipulate attributes based on a numerical index, XML attributes are in
 * fact unordered when they appear in files and data streams.  The
 * XMLAttributes class provides some list-like facilities, but it is only for
 * the convenience of callers.  (For example, it permits callers to loop
 * across all attributes more easily.)  Users should keep in mind that the
 * order in which attributes are stored in XMLAttributes objects has no real
 * impact on the order in which the attributes are read or written from an
 * XML file or data stream.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_read_methods_and_namespaces
 *
 * @note The XML namespace associated with the attribute named @p name is not
 * considered when looking up the attribute.  If more than one attribute with
 * the same name exists with different XML namespace URI associations, this
 * method will operate on the first one it encounters; this behavior is
 * identical to XMLAttributes::getIndex (const std::string& name) const.  To
 * have XML namespaces be considered too, callers should use the variant
 * method that takes an XMLTriple object instead of a string @p name
 * argument.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_add_behavior_explanation
 *
 * @par
 * Some explanations are in order about the behavior of XMLAttributes with
 * respect to namespace prefixes and namespace URIs.  XMLAttributes does @em
 * not verify the consistency of different uses of an XML namespace and the
 * prefix used to refer to it in a given context.  It cannot, because the
 * prefix used for a given XML namespace in an XML document may intentionally
 * be different on different elements in the document.  Consequently, callers
 * need to manage their own prefix-to-namespace mappings, and need to ensure
 * that the desired prefix is used in any given context.
 *
 * When called with attribute names, prefixes and namespace URIs,
 * XMLAttributes pays attention to the namespace URIs and not the prefixes: a
 * match is established by a combination of attribute name and namespace URI,
 * and if on different occasions a different prefix is used for the same
 * name/namespace combination, the prefix associated with the namespace on
 * that attribute is overwritten.
 *
 * Some examples will hopefully clarify this.  Here are the results of a
 * sequence of calls to the XMLAttributes <code>add</code> methods with
 * different argument combinations.  First, we create the object and add
 * one attribute:
 *
 * @code{.cpp}
XMLAttributes * att = new XMLAttributes();
att->add("myattribute", "1", "myuri");
@endcode
 * The above adds an attribute named <code>myattribute</code> in the namespace
 * <code>myuri</code>, and with the attribute value <code>1</code>.  No
 * namespace prefix is associated with the attribute (but the attribute is
 * recorded to exist in the namespace <code>myuri</code>).  If
 * this attribute object were written out in XML, it would look like the
 * following (and note that, since no namespace prefix was assigned, none
 * is written out):
 * <center><pre>
myattribute="1"
 * </pre></center>
 *
 * Continuing with this series of examples, suppose we invoke the
 * <code>add</code> method again as follows:
 *
 * @code{.cpp}
att->add("myattribute", "2");
@endcode
 * The above adds a @em new attribute @em also named <code>myattribute</code>,
 * but in a different XML namespace: it is placed in the namespace with no
 * URI, which is to say, the default XML namespace.  Both attributes coexist
 * on this XMLAttributes object; both can be independently retrieved.
 *
 * @code{.cpp}
att->add("myattribute", "3");
@endcode
 * The code above now replaces the value of the attribute
 * <code>myattribute</code> that resides in the default namespace.  The
 * attribute in the namespace <code>myuri</code> remains untouched.
 *
 * @code{.cpp}
att->add("myattribute", "4", "myuri");
@endcode
 * The code above replaces the value of the attribute
 * <code>myattribute</code> that resides in the <code>myuri</code> namespace.
 * The attribute in the default namespace remains untouched.
 *
 * @code{.cpp}
att->add("myattribute", "5", "myuri", "foo");
@endcode
 * The code above replaces the value of the attribute
 * <code>myattribute</code> that resides in the <code>myuri</code> namespace.
 * It also now assigns a namespace prefix, <code>foo</code>, to the attribute.
 * The attribute <code>myattribute</code> in the default namespace remains
 * untouched. If this XMLAttributes object were written out in XML, it would
 * look like the following:
 * <center><pre>
myattribute="3"
foo:myattribute="5"
 * </pre></center>
 * Pressing on, now suppose we call the <code>add</code> method as follows:
 *
 * @code{.cpp}
att->add("myattribute", "6", "myuri", "bar");
@endcode
 * The code above replaces the value of the attribute
 * <code>myattribute</code> that resides in the <code>myuri</code> namespace.
 * It also assigns a different prefix to the attribute.  The namespace of
 * the attribute remains <code>myuri</code>.
 *
 * @code{.cpp}
att->add("myattribute", "7", "", "foo");
@endcode

 * The code above replaces the value of the attribute
 * <code>myattribute</code> that resides in the default namespace.  It also
 * now assigns a namespace prefix, <code>foo</code>, to that attribute.  If
 * this XMLAttributes object were written out in XML, it would look like the
 * following:
 * <center><pre>
bar:myattribute="6"
foo:myattribute="7"
 * </pre></center>
 */

#ifndef XMLAttributes_h
#define XMLAttributes_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>


#ifdef __cplusplus


#include <string>
#include <vector>
#include <stdexcept>

#include <sbml/xml/XMLTriple.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class XMLErrorLog;
/** @cond doxygenLibsbmlInternal */
class XMLOutputStream;
/** @endcond */

class LIBLAX_EXTERN XMLAttributes
{
public:

  /**
   * Creates a new, empty XMLAttributes object.
   */
  XMLAttributes ();


  /**
   * Destroys this XMLAttributes object.
   */
  virtual ~XMLAttributes ();


  /**
   * Copy constructor; creates a copy of this XMLAttributes object.
   *
   * @p orig the XMLAttributes object to copy.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  XMLAttributes(const XMLAttributes& orig);


  /**
   * Assignment operator for XMLAttributes.
   *
   * @param rhs The XMLAttributes object whose values are used as the basis
   * of the assignment.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  XMLAttributes& operator=(const XMLAttributes& rhs);


  /**
   * Creates and returns a deep copy of this XMLAttributes object.
   *
   * @return the (deep) copy of this XMLAttributes object.
   */
  XMLAttributes* clone () const;


  /**
   * Adds an attribute to this list of attributes.
   *
   * @copydetails doc_add_behavior_explanation
   *
   * @param name a string, the unprefixed name of the attribute.
   * @param value a string, the value of the attribute.
   * @param namespaceURI a string, the namespace URI of the attribute.
   * @param prefix a string, a prefix for the XML namespace.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}.
   * This value is returned if any of the arguments are @c NULL.  To set an
   * empty @p prefix and/or @p name value, use an empty string rather than @c
   * NULL.
   *
   * @copydetails doc_note_overwrites_existing_values
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see add(const XMLTriple& triple, const std::string& value)
   * @see getIndex(const std::string& name, const std::string& uri) const
   * @see getIndex(const XMLTriple& triple) const
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  int add (  const std::string& name
           , const std::string& value
           , const std::string& namespaceURI = ""
           , const std::string& prefix = "");


  /**
   * Adds an attribute to this list of attributes.
   *
   * @copydetails doc_add_behavior_explanation
   *
   * @param triple an XMLTriple object describing the attribute to be added.
   * @param value a string, the value of the attribute.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}. 
   * This value is returned if any of the arguments are @c NULL.  To set an
   * empty value for the attribute, use an empty string rather than @c NULL.
   *
   * @copydetails doc_note_overwrites_existing_values
   *
   * @see add(const std::string& name, const std::string& value, const std::string& namespaceURI, const std::string& prefix)
   * @see getIndex(const std::string& name, const std::string& uri) const
   * @see getIndex(const XMLTriple& triple) const
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
   int add ( const XMLTriple& triple, const std::string& value);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Adds an name/value pair to this XMLAttributes list.
   *
   * This method is similar to the add method but an attribute with same name wont
   * be overwritten. This facilitates the addition of multiple resource attributes
   * in CVTerm class.
   *
   * @param name a string, the name of the attribute.
   * @param value a string, the value of the attribute.
   *
   * @note This function is only internally used to store multiple rdf:resource
   * attributes in CVTerm class, and thus should not be used for other purposes.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int addResource (const std::string& name, const std::string& value);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Removes the <em>n</em>th attribute from this list of attributes.
   *
   * This method is simply an alias of XMLAttributes::remove(@if java
   * int@endif).
   *
   * @param n an integer the index of the resource to be deleted
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute at the
   * given index @p n.
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see remove(const XMLTriple& triple)
   * @see remove(const std::string& name, const std::string& uri)
   */
  int removeResource (int n);
  /** @endcond */


  /**
   * Removes the <em>n</em>th attribute from this list of attributes.
   *
   * @param n an integer the index of the resource to be deleted
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute at the
   * given index @p n.
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see remove(const XMLTriple& triple)
   * @see remove(const std::string& name, const std::string& uri)
   */
  int remove (int n);


  /**
   * Removes a named attribute from this list of attributes.
   *
   * @param name a string, the unprefixed name of the attribute to be
   * removed.
   *
   * @param uri a string, the namespace URI of the attribute to be removed.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute with the
   * given @p name (and @p uri if specified).
   *
   * @see remove(int n)
   * @see remove(const XMLTriple& triple)
   */
  int remove (const std::string& name, const std::string& uri = "");


  /**
   * Removes a specific attribute from this list of attributes.
   *
   * @param triple an XMLTriple describing the attribute to be removed.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * The value @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE,
   * OperationReturnValues_t} is returned if there is no attribute matching
   * the properties of the given @p triple.
   *
   * @see remove(int n)
   * @see remove(const std::string& name, const std::string& uri)
   */
  int remove (const XMLTriple& triple);


  /**
   * Removes all attributes in this XMLAttributes object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see remove(int n)
   * @see remove(const XMLTriple& triple)
   * @see remove(const std::string& name, const std::string& uri)
   */
  int clear();


  /**
   * Returns the index of an attribute having a given name.
   *
   * @note This method does not check XML namespaces.  Thus, if there are
   * multiple attributes with the same local @p name but different
   * namespaces, this method will return the first one found.  Callers should
   * use the more specific methods
   * XMLAttributes::getIndex(const std::string& name, const std::string& uri) const
   * or XMLAttributes::getIndex(const XMLTriple& triple) const
   * to find attributes in particular namespaces.
   *
   * @param name a string, the name of the attribute whose index is begin
   * sought.
   *
   * @return the index of an attribute with the given local name, or
   * <code>-1</code> if no such attribute is present.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  int getIndex (const std::string& name) const;


  /**
   * Returns the index of the attribute having a given name and XML namespace
   * URI.
   *
   * @param name a string, the name of the attribute being sought.
   * @param uri  a string, the namespace URI of the attribute being sought.
   *
   * @return the index of an attribute with the given local name and
   * namespace URI, or <code>-1</code> if no such attribute is present.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  int getIndex (const std::string& name, const std::string& uri) const;


  /**
   * Returns the index of the attribute defined by the given XMLTriple object.
   *
   * @param triple an XMLTriple describing the attribute being sought.
   *
   * @return the index of an attribute described by the given XMLTriple
   * object, or <code>-1</code> if no such attribute is present.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  int getIndex (const XMLTriple& triple) const;


  /**
   * Returns the number of attributes in this list of attributes.
   *
   * @return the number of attributes contained in this XMLAttributes object.
   */
  int getLength () const;


  /**
   * Returns the number of attributes in this list of attributes.
   *
   * This function is merely an alias of XMLAttributes::getLength()
   * introduced for consistency with other libXML classes.
   *
   * @return the number of attributes contained in this XMLAttributes object.
   */
  int getNumAttributes () const;


  /**
   * Returns the name of the <em>n</em>th attribute in this list of
   * attributes.
   *
   * @param index an integer, the position of the attribute whose name
   * is being sought.
   *
   * @return the local name of the <em>n</em>th attribute.
   *
   * @copydetails doc_note_check_number_first
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see hasAttribute(int index) const
   */
  std::string getName (int index) const;


  /**
   * Returns the namespace prefix of the <em>n</em>th attribute in this
   * attribute set.
   *
   * @param index an integer, the position of the attribute whose namespace
   * prefix is being sought.
   *
   * @return the XML namespace prefix of the <em>n</em>th attribute.
   *
   * @copydetails doc_note_check_number_first
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see hasAttribute(int index) const
   */
  std::string getPrefix (int index) const;


  /**
   * Returns the prefix name of the <em>n</em>th attribute in this attribute
   * set.
   *
   * @param index an integer, the position of the attribute whose prefixed
   * name is being sought.
   *
   * @return the prefixed name of the <em>n</em>th attribute.
   *
   * @copydetails doc_note_check_number_first
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see hasAttribute(int index) const
   */
  std::string getPrefixedName (int index) const;


  /**
   * Returns the XML namespace URI of the <em>n</em>th attribute in this
   * attribute set.
   *
   * @param index an integer, the position of the attribute whose namespace
   * URI is being sought.
   *
   * @return the XML namespace URI of the <em>n</em>th attribute.
   *
   * @copydetails doc_note_check_number_first
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see hasAttribute(int index) const
   */
  std::string getURI (int index) const;


  /**
   * Returns the value of the <em>n</em>th attribute in this list of attributes.
   *
   * @param index an integer, the position of the attribute whose value is
   * being sought.
   *
   * @return the XML value of the <em>n</em>th attribute.
   *
   * @copydetails doc_note_check_number_first
   *
   * @copydetails doc_note_attributes_are_unordered
   *
   * @see getLength()
   * @see hasAttribute(int index) const
   */
  std::string getValue (int index) const;


  /**
   * Returns a named attribute's value.
   *
   * @param name a string, the unprefixed name of the attribute whose value
   * is being sought.
   *
   * @return The attribute value as a string.
   *
   * @note If an attribute with the given local @p name does not exist in
   * this XMLAttributes object, this method will return an empty string.
   * Callers can use
   * XMLAttributes::hasAttribute(const std::string name, const std::string uri) const
   * to test for an attribute's existence.  This method also does not check
   * the XML namespace of the named attribute.  Thus, if there are multiple
   * attributes with the same local @p name but different namespaces, this
   * method will return the value of the first such attribute found.  Callers
   * should use the more specific methods
   * XMLAttributes::getIndex(const std::string& name, const std::string& uri) const
   * or XMLAttributes::getIndex(const XMLTriple& triple) const to find
   * attributes in particular namespaces.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  std::string getValue (const std::string name) const;


  /**
   * Returns a named attribute's value.
   *
   * @param name a string, the name of the attribute whose value is being sought.
   * @param uri  a string, the XML namespace URI of the attribute.
   *
   * @return The attribute value as a string.
   *
   * @note If an attribute with the given @p name and namespace @p uri does
   * not exist in this XMLAttributes object, this method will return an empty
   * string.  Callers can use
   * XMLAttributes::hasAttribute(const std::string name, const std::string uri) const
   * to test for an attribute's existence.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  std::string getValue (const std::string name, const std::string uri) const;


  /**
   * Return the value of an attribute described by a given XMLTriple object.
   *
   * @param triple an XMLTriple describing the attribute whose value is being
   * sought.
   *
   * @return The attribute value as a string.
   *
   * @note If an attribute with the properties given by @p triple does not
   * exist in this XMLAttributes object, this method will return an empty
   * string.  Callers can use
   * XMLAttributes::hasAttribute(const std::string name, const std::string uri) const
   * to test for an attribute's existence.
   *
   * @see hasAttribute(const std::string name, const std::string uri) const
   * @see hasAttribute(const XMLTriple& triple) const
   */
  std::string getValue (const XMLTriple& triple) const;


  /**
   * Returns @c true if an attribute exists at a given index.
   *
   * @param index an integer, the position of the attribute to be tested.
   *
   * @return @c true if an attribute with the given index exists in this
   * XMLAttributes object, @c false otherwise.
   *
   * @copydetails doc_note_attributes_are_unordered
   */
  bool hasAttribute (int index) const;


  /**
   * Returns @c true if an attribute with a given name and namespace URI
   * exists.
   *
   * @param name a string, the unprefixed name of the attribute.
   * @param uri  a string, the XML namespace URI of the attribute.
   *
   * @return @c true if an attribute with the given local name and XML
   * namespace URI exists in this XMLAttributes object, @c false otherwise.
   *
   * @see add(const std::string& name, const std::string& value, const std::string& namespaceURI, const std::string& prefix)
   * @see add(const XMLTriple& triple, const std::string& value)
   */
   bool hasAttribute (const std::string name, const std::string uri="") const;


  /**
   * Returns @c true if an attribute with the given properties exists.
   *
   * @param triple an XMLTriple describing the attribute to be tested.
   *
   * @return @c true if an attribute with the given XML triple exists in this
   * XMLAttributes object, @c false otherwise.
   *
   * @see add(const std::string& name, const std::string& value, const std::string& namespaceURI, const std::string& prefix)
   * @see add(const XMLTriple& triple, const std::string& value)
   */
  bool hasAttribute (const XMLTriple& triple) const;


  /**
   * Returns @c true if this list of attributes is empty.
   *
   * @return @c true if this XMLAttributes object is empty, @c false
   * otherwise.
   */
  bool isEmpty () const;


  /**
   * Interprets an attribute as a Boolean value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and attempts to interpret it as a Boolean.  If
   * successful, this method stores the value into the variable passed in as
   * @p value.  If no attribute named @p name can be found in this
   * XMLAttributes object or the value of the attribute could not be
   * interpreted as a Boolean, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#boolean">XML Schema</a>, the
   * valid Boolean values are: <code>"true"</code>, <code>"false"</code>,
   * <code>"1"</code>, and <code>"0"</code>, read in a case-insensitive
   * manner.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a Boolean, then the
   * error logged to @p log indicates that a value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value a Boolean, the return parameter into which the value should
   * be assigned.
   *
   * @copydetails doc_read_methods_common_args
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , bool&               value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a Boolean value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and attempts to interpret it as a
   * Boolean.  If successful, this method stores the value into the variable
   * passed in as @p value.  If no attribute named @p name can be found in
   * this XMLAttributes object or the value of the attribute could not be
   * interpreted as a Boolean, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#boolean">XML Schema</a>, the
   * valid Boolean values are: <code>"true"</code>, <code>"false"</code>,
   * <code>"1"</code>, and <code>"0"</code>, read in a case-insensitive
   * manner.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a Boolean, then the
   * error logged to @p log indicates that a value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute to read.
   *
   * @param value a Boolean, the return parameter into which the value should
   * be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , bool&        value
                 , XMLErrorLog* log          = NULL
                 , bool         required     = false
                 , const unsigned int line   = 0
                 , const unsigned int column = 0) const;



  /**
   * Interprets an attribute as a <code>double</code> value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and attempts to interpret it as a
   * <code>double</code>.  If successful, this method stores the value into
   * the variable passed in as @p value.  If no attribute named @p name can
   * be found in this XMLAttributes object or the value of the attribute
   * could not be interpreted as a <code>double</code>, @p value is left
   * unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#double">XML Schema</a>, valid
   * doubles are the same as valid doubles for the C language and in
   * addition, the special values <code>"INF"</code>, <code>"-INF"</code>,
   * and <code>"NaN"</code>, read in a case-insensitive manner.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>double</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value a <code>double</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , double&             value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a <code>double</code> value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and attempts to interpret it as a
   * <code>double</code>.  If successful, this method stores the value into
   * the variable passed in as @p value.  If no attribute named @p name can
   * be found in this XMLAttributes object or the value of the attribute
   * could not be interpreted as a <code>double</code>, @p value is left
   * unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#double">XML Schema</a>, valid
   * doubles are the same as valid doubles for the C language and in
   * addition, the special values <code>"INF"</code>, <code>"-INF"</code>,
   * and <code>"NaN"</code>, read in a case-insensitive manner.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>double</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute to read.
   *
   * @param value a <code>double</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple&  triple
                 , double&           value
                 , XMLErrorLog*      log      = NULL
                 , bool              required = false
                 , const unsigned int line    = 0
                 , const unsigned int column  = 0) const;


  /**
   * Interprets an attribute as a <code>long</code> integer value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and attempts to interpret it as a
   * <code>long</code>.  If successful, this method stores the value into the
   * variable passed in as @p value.  If no attribute named @p name can be
   * found in this XMLAttributes object or the value of the attribute could
   * not be interpreted as a <code>long</code>, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  This is unfortunately a larger space of
   * values than can be represented in a long integer, so libSBML limits the
   * possible values to those that can be stored in a <code>long</code> data
   * type.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value a <code>long</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , long&               value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a <code>long</code> integer value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and attempts to interpret it as a
   * <code>long</code>.  If successful, this method stores the value into the
   * variable passed in as @p value.  If no attribute named @p name can be
   * found in this XMLAttributes object or the value of the attribute could
   * not be interpreted as a <code>long</code>, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  This is unfortunately a larger space of
   * values than can be represented in a long, so libSBML limits the possible
   * values to those that can be stored in a <code>long</code> data type.

   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute
   *
   * @param value a <code>long</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , long&            value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false
                 , const unsigned int line   = 0
                 , const unsigned int column = 0) const;


  /**
   * Interprets an attribute as a <code>int</code> value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and attempts to interpret it as an
   * <code>int</code>.  If successful, this method stores the value into the
   * variable passed in as @p value.  If no attribute named @p name can be
   * found in this XMLAttributes object or the value of the attribute could
   * not be interpreted as an <code>int</code>, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  The present method is designed to interpret
   * numbers as signed <code>int</code> values and cannot represent larger
   * values.  Note that variant methods on XMLAttributes are available to
   * work with <code>unsigned int</code> type and <code>long</code> type
   * values; users may wish to investigate those methods if they need to
   * handle larger integer values.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value an <code>int</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , int&                value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a <code>int</code> value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and attempts to interpret it as an
   * <code>int</code>.  If successful, this method stores the value into the
   * variable passed in as @p value.  If no attribute named @p name can be
   * found in this XMLAttributes object or the value of the attribute could
   * not be interpreted as an <code>int</code>, @p value is left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  The present method is designed to interpret
   * numbers as signed <code>int</code> values and cannot represent larger
   * values.  Note that variant methods on XMLAttributes are available to
   * work with <code>unsigned int</code> type and <code>long</code> type
   * values; users may wish to investigate those methods if they need to
   * handle larger integer values.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute
   *
   * @param value an <code>int</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , int&             value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false
                 , const unsigned int line   = 0
                 , const unsigned int column = 0) const;


  /**
   * Interprets an attribute as a <code>unsigned int</code> value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and attempts to interpret it as an
   * <code>unsigned int</code>.  If successful, this method stores the value
   * into the variable passed in as @p value.  If no attribute named @p name
   * can be found in this XMLAttributes object or the value of the attribute
   * could not be interpreted as an <code>unsigned int</code>, @p value is
   * left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  The present method is designed to interpret
   * numbers as <code>unsigned int</code> and cannot represent larger values.
   * Note that a variant method on XMLAttributes is available to work with
   * <code>long</code> type values; users may wish to investigate that method
   * if they need to handle large integer values.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value an <code>int</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , unsigned int&       value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a <code>unsigned int</code> value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and attempts to interpret it as an
   * <code>unsigned int</code>.  If successful, this method stores the value
   * into the variable passed in as @p value.  If no attribute named @p name
   * can be found in this XMLAttributes object or the value of the attribute
   * could not be interpreted as an <code>unsigned int</code>, @p value is
   * left unmodified.
   *
   * According to the specification of <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#integer">XML Schema</a>, valid
   * <code>long</code>-type values are zero, all positive whole numbers and
   * all negative whole numbers.  The present method is designed to interpret
   * numbers as <code>unsigned int</code> and cannot represent larger values.
   * Note that a variant method on XMLAttributes is available to work with
   * <code>long</code> type values; users may wish to investigate that method
   * if they need to handle large integer values.
   *
   * Errors in attempting to interpret the format are logged to @p log, if an
   * error log object is supplied.  If the parameter @p required is @c true,
   * then if no attribute named @p name exists, an error will be logged to @p
   * log with a description that explains the error is due to a missing
   * required attribute.  If the parameter @p required is @c false (the
   * default), then if no attribute @p name exists, no error will be logged
   * and this method will simply return @c false to indicate an unsuccessful
   * assignment.  Finally, if @p log is provided, @p name exists, but the
   * value associated with @p name could not be parsed as a
   * <code>long</code>, then the error logged to @p log indicates that a
   * value type mismatch occurred.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute
   *
   * @param value an <code>int</code>, the return parameter into which the
   * value should be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , unsigned int&    value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false
                 , const unsigned int line   = 0
                 , const unsigned int column = 0) const;


  /**
   * Interprets an attribute as a string value.
   *
   * This method reads the value associated with the attribute @p name in
   * this XMLAttributes object and stores the value into the variable passed
   * in as @p value.  If no attribute named @p name can be found in this
   * XMLAttributes object, @p value is left unmodified.
   *
   * Unlike the other variant methods on XMLAttributes, there are no format
   * errors possible when reading strings, since XML attribute values @em are
   * strings.  However, the case of a missing attribute can still occur.
   * Errors will be logged to @p log, if an error log object is supplied.  If
   * the parameter @p required is @c true, then if no attribute named @p name
   * exists, an error will be logged to @p log with a description that
   * explains the error is due to a missing required attribute.  If the
   * parameter @p required is @c false (the default), then if no attribute @p
   * name exists, no error will be logged and this method will simply return
   * @c false to indicate an unsuccessful assignment.
   *
   * Values are read using the "C" locale.
   *
   * @param name a string, the name of the attribute.
   *
   * @param value a string, the return parameter into which the value should
   * be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @copydetails doc_note_read_methods_and_namespaces 
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , std::string&        value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line      = 0
                 , const unsigned int column    = 0) const;


  /**
   * Interprets an attribute as a string value.
   *
   * This method reads the value associated with the attribute described by
   * @p triple in this XMLAttributes object and stores the value into the
   * variable passed in as @p value.  If no attribute named @p name can be
   * found in this XMLAttributes object, @p value is left unmodified.
   *
   * Unlike the other variant methods on XMLAttributes, there are no format
   * errors possible when reading strings, since XML attribute values @em are
   * strings.  However, the case of a missing attribute can still occur.
   * Errors will be logged to @p log, if an error log object is supplied.  If
   * the parameter @p required is @c true, then if no attribute named @p name
   * exists, an error will be logged to @p log with a description that
   * explains the error is due to a missing required attribute.  If the
   * parameter @p required is @c false (the default), then if no attribute @p
   * name exists, no error will be logged and this method will simply return
   * @c false to indicate an unsuccessful assignment.
   *
   * Values are read using the "C" locale.
   *
   * @param triple an XMLTriple object describing the attribute
   *
   * @param value a string, the return parameter into which the value should
   * be assigned.
   *
   * @param log an XMLErrorLog object, an optional error log for reporting
   * problems.
   *
   * @param required a Boolean flag, to indicate whether it should be
   * considered an error if the attribute @p name cannot be found in this
   * XMLAttributes object.
   *
   * @param line an unsigned int, the line number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @param column an unsigned int, the column number at which the error
   * occurred.  Callers can supply this value if it makes sense for their
   * applications.
   *
   * @returns @c true if the attribute was successfully read into value, @c
   * false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , std::string&     value
                 , XMLErrorLog*     log       = NULL
                 , bool              required = false
                 , const unsigned int line    = 0
                 , const unsigned int column  = 0) const;


  /** @cond doxygenLibsbmlInternal */

  /**
   * Writes this XMLAttributes set to stream.
   *
   * @param stream XMLOutputStream, stream to which this XMLAttributes
   * set is to be written.
   */
  void write (XMLOutputStream& stream) const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * (Optional) Sets the log used when logging attributeTypeError() and
   * attributeRequired() errors.
   *
   * @param log the log to use
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setErrorLog (XMLErrorLog* log);
  /** @endcond */


#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */
  /**
   * Inserts this XMLAttributes set into stream.
   *
   * @param stream XMLOutputStream, stream to which the XMLAttributes
   * set is to be written.
   * @param attributes XMLAttributes, attributes to be written to stream.
   *
   * @return the stream with the attributes inserted.
   */
  LIBLAX_EXTERN
  friend XMLOutputStream&
  operator<< (XMLOutputStream& stream, const XMLAttributes& attributes);
  /** @endcond */

#endif  /* !SWIG */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Used by attributeTypeError().
   */
  enum DataType { Boolean = 0, Double = 1, Integer = 2 };


  /**
   * Logs an attribute datatype error.
   *
   * @param name  name of the attribute
   * @param type  the datatype of the attribute value.
   * @param log   the XMLErrorLog where the error should be logged
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   */
  void attributeTypeError (  const std::string& name
			   , DataType           type
			   , XMLErrorLog*       log
         , const unsigned int line     = 0
         , const unsigned int column   = 0) const;


  /**
   * Logs an error indicating a required attribute was missing.
   * Used internally.
   *
   * @param name  name of the attribute
   * @param log   the XMLErrorLog where the error should be logged
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   */
  void attributeRequiredError ( const std::string& name
        , XMLErrorLog* log
        , const unsigned int line     = 0
        , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If the attribute was not found or value could be interpreted as a boolean,
   * value is not modified.
   *
   * According to the W3C XML Schema, valid boolean values are: "true",
   * "false", "1", and "0" (case-insensitive).  For more information, see:
   * http://www.w3.org/TR/xmlschema-2/#boolean
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value a boolean, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int          index
                 , const std::string&  name
                 , bool&        value
                 , XMLErrorLog* log      = NULL
                 , bool         required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If name was not found or value could be interpreted as a double, value
   * is not modified.
   *
   * According to the W3C XML Schema, valid doubles are the same as valid
   * doubles for C and the special values "INF", "-INF", and "NaN"
   * (case-sensitive).  For more information, see:
   * http://www.w3.org/TR/xmlschema-2/#double
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value a double, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int          index
                 , const std::string&  name
                 , double&      value
                 , XMLErrorLog*  log      = NULL
                 , bool          required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If the attribute was not found or value could be interpreted as a long,
   * value is not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a long.  For more information,
   * see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value a long, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int          index
                 , const std::string&  name
                 , long&         value
                 , XMLErrorLog*  log      = NULL
                 , bool          required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If the attribute was not found or value could be interpreted as an integer,
   * value is not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a int.  For more information,
   * see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value an integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int          index
                 , const std::string&  name
                 , int&         value
                 , XMLErrorLog*  log      = NULL
                 , bool          required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If the attribute was not found or value could be interpreted as an
   * unsigned int, value is not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a unsigned int.  For more
   * information, see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value an unsigned integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int           index
                 , const std::string&  name
                 , unsigned int& value
                 , XMLErrorLog*  log      = NULL
                 , bool          required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given index into value.
   * If the attribute was not found, value is not modified.
   *
   * If an XMLErrorLog is passed in and required is true, missing
   * attributes are logged.
   *
   * @param index a int, the index of the attribute.
   * @param name a string, the name of the attribute
   * (only used for an error message (if error detected))
   * @param value a string, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is being sought.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   */
  bool readInto (  int          index
                 , const std::string&  name
                 , std::string& value
                 , XMLErrorLog* log      = NULL
                 , bool         required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;



  std::vector<XMLTriple>    mNames;
  std::vector<std::string>  mValues;

  std::string               mElementName;
  XMLErrorLog*              mLog;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */



#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLAttributes_t set.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
XMLAttributes_t *
XMLAttributes_create (void);


/**
 * Frees the given XMLAttributes_t structure.
 *
 * @param xa the XMLAttributes_t structure to be freed.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
void
XMLAttributes_free (XMLAttributes_t *xa);


/**
 * Creates a deep copy of the given XMLAttributes_t structure.
 *
 * @param att the XMLAttributes_t structure to be copied
 *
 * @return a (deep) copy of the given XMLAttributes_t structure.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
XMLAttributes_t *
XMLAttributes_clone (const XMLAttributes_t* att);


/**
 * Adds a name/value pair to this XMLAttributes_t structure.
 *
 * @param xa the XMLAttributes_t structure
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if local name already exists in this list of attributes, its value
 * will be replaced.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_add (XMLAttributes_t *xa, const char *name, const char *value);


/**
 * Adds a name/value pair to this XMLAttributes_t structure with a
 * prefix and URI defining a namespace.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 * @param uri a string, the namespace URI of the attribute.
 * @param prefix a string, the prefix of the namespace
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if local name with the same namespace URI already exists in this
 * attribute set, its value will be replaced.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_addWithNamespace (XMLAttributes_t *xa,
				const char *name,
				const char *value,
				const char* uri,
				const char* prefix);

/**
  * Adds an attribute with the given XMLtriple/value pair to this XMLAttributes_t structure.
  *
  * @param xa the XMLAttributes_t structure.
  * @param triple an XMLTriple_t, the triple of the attribute.
  * @param value a string, the value of the attribute.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_addWithTriple (XMLAttributes_t *xa, const XMLTriple_t* triple, const char* value);


/**
 * Removes an attribute (a name/value pair) from this XMLAttributes_t set.
 *
 * @param xa the XMLAttributes_t structure.
 * @param n an integer the index of the resource to be deleted
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_removeResource (XMLAttributes_t *xa, int n);


/**
 * Removes an attribute (a name/value pair) from this XMLAttributes_t set.
 *
 * @param xa the XMLAttributes_t structure.
 * @param n an integer the index of the resource to be deleted
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_remove (XMLAttributes_t *xa, int n);


/**
 * Removes an attribute with the given local name from this XMLAttributes_t set.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note A prefix and namespace URI bound to the local name are set to empty
 * in this function.
 * XMLAttributes_removeByNS(name,uri) or XMLAttributes_removeByTriple(triple)
 * should be used to remove an attribute with the given local name and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_removeByName (XMLAttributes_t *xa, const char* name);


/**
 * Removes an attribute with the given name and namespace URI from this
 * XMLAttributes_t set.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute for which the index is being sought.
 * @param uri a string, the namespace URI of the attribute.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_removeByNS (XMLAttributes_t *xa, const char* name, const char* uri);


/**
 * Removes an attribute with the given triple from this XMLAttributes_t set.
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute for which
 *        the index is being sought.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_removeByTriple (XMLAttributes_t *xa, const XMLTriple_t* triple);


/**
 * Clears (deletes) all attributes in this XMLAttributes_t structure.
 *
 * @param xa the XMLAttributes_t structure.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_clear(XMLAttributes_t *xa);


/**
 * Return the index of an attribute with the given name.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute for which the index is being sought.
 *
 * @return the index of an attribute with the given local name, or -1 if not present.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_getIndex (const XMLAttributes_t *xa, const char *name);


/**
 * Return the index of an attribute with the given name and namespace URI.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute for which the index is being sought.
 * @param uri a string, the namespace URI of the attribute.
 *
 * @return the index of an attribute with the given local name and namespace URI,
 * or -1 if not present.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_getIndexByNS (const XMLAttributes_t *xa, const char *name, const char *uri);


/**
 * Return the index of an attribute with the given XML triple.
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute for which
 *        the index is being sought.
 *
 * @return the index of an attribute with the given XMLTriple_t, or -1 if not present.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_getIndexByTriple (const XMLAttributes_t *xa, const XMLTriple_t *triple);


/**
 * Return the number of attributes in the set.
 *
 * @param xa the XMLAttributes_t structure.
 *
 * @return the number of attributes in this XMLAttributes_t structure.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_getLength (const XMLAttributes_t *xa);


/**
 * Return the number of attributes in the set.
 *
 * @param xa the XMLAttributes_t structure.
 *
 * @return the number of attributes in this XMLAttributes_t structure.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_getNumAttributes (const XMLAttributes_t *xa);


/**
 * Return the local name of an attribute in this XMLAttributes_t structure (by position).
 *
 * @param xa the XMLAttributes_t structure.
 * @param index an integer, the position of the attribute whose name is
 * required.
 *
 * @return the local name of an attribute in this list (by position).
 *         NULL will be returned if the name is empty.
 *
 * @note If index
 * is out of range, an empty string will be returned.
 * Use XMLNamespaces_hasAttribute(...) > 0 to test for attribute existence.
 * to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getName (const XMLAttributes_t *xa, int index);


/**
 * Return the value of an attribute in this XMLAttributes_t structure (by position).
 *
 * @param xa the XMLAttributes_t structure.
 * @param index an integer, the position of the attribute whose value is
 * required.
 *
 * @return the value of an attribute in the list (by position).
 *         NULL will be returned if the prefix is empty.
 *
 * @note If index
 * is out of range, an empty string will be returned.
 * Use XMLNamespaces_hasAttribute(...) > 0 to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getPrefix (const XMLAttributes_t *xa, int index);


/**
 * Return the namespace URI of an attribute in this XMLAttributes_t structure (by position).
 *
 * @param xa the XMLAttributes_t structure.
 * @param index an integer, the position of the attribute whose namespace URI is
 * required.
 *
 * @return the namespace URI of an attribute in this list (by position).
 *         NULL will be returned if the URI is empty.
 *
 * @note If index is out of range, an empty string will be returned.  Use
 * XMLNamespaces_hasAttribute(...) > 0 to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getURI (const XMLAttributes_t *xa, int index);


/**
 * Return the value of an attribute in this XMLAttributes_t structure (by position).
 *
 * @param xa the XMLAttributes_t structure.
 * @param index an integer, the position of the attribute whose value is
 * required.
 *
 * @return the value of an attribute in the list (by position).
 *         NULL will be returned if the value is empty.
 *
 * @note If index
 * is out of range, NULL will be returned.
 * Use XMLAttributes_hasAttribute(...) > 0 to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getValue (const XMLAttributes_t *xa, int index);


/**
 * Return an attribute's value by name.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute whose value is being sought.
 *
 * @return The attribute value as a string.
 *         NULL will be returned if the value is empty.
 *
 * @note If an attribute with the
 * given local name does not exist, NULL will be returned.  Use
 * XMLAttributes_hasAttributeWithName(...) > 0 to test for attribute existence.
 * A namespace bound to the local name is not checked by this function.
 * Thus, if there are multiple attributes with the given local name and
 * different namespaces, the value of an attribute with the smallest index
 * among those attributes will be returned.
 * XMLAttributes_getValueByNS(...) or XMLAttributes_getValueByTriple(...)
 * should be used to get a value of an attribute with the given local name
 * and namespace.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getValueByName (const XMLAttributes_t *xa, const char *name);


/**
 * Return a value of an attribute with the given local name and namespace URI.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute whose value is being sought.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return The attribute value as a string.
 * NULL will be returned if the value is empty.
 *
 * @note If an attribute with the
 * given local name and namespace URI does not exist, an empty string will be
 * returned.
 * Use XMLAttributes_hasAttributeWithNS(...) to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
char *
XMLAttributes_getValueByNS (const XMLAttributes_t *xa, const char* name, const char* uri);
LIBLAX_EXTERN

/**
 * Return an attribute's value by XMLTriple.
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute
 * whose value is being sought.
 *
 * @return The attribute value as a string.
 *         NULL will be returned if the value is empty.
 *
 * @note If an attribute with the
 * given XMLTriple_t does not exist, NULL will be returned.
 * Use XMLAttributes_hasAttributeWithTriple(..) > 0 to test for attribute existence.
 * Returned const char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLAttributes_t
 */
char *
XMLAttributes_getValueByTriple (const XMLAttributes_t *xa, const XMLTriple_t* triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given index exists in this XMLAttributes_t
 * structure.
 *
 * @param xa the XMLAttributes_t structure.
 * @param index an integer, the position of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given index exists
 * in this XMLAttributes_t structure, @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_hasAttribute (const XMLAttributes_t *xa, int index);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name exists in this XMLAttributes_t
 * structure.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name
 * exists in this XMLAttributes_t structure, @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_hasAttributeWithName (const XMLAttributes_t *xa, const char* name);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name and namespace URI exists in this
 * XMLAttributes_t structure.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name
 * and namespace URI exists in this XMLAttributes_t structure, @c zero (false)
 * otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_hasAttributeWithNS (const XMLAttributes_t *xa, const char* name, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given XMLtriple_t exists in this XMLAttributes_t
 * structure.
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given XMLTriple_t
 * exists in this XMLAttributes_t structure, @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_hasAttributeWithTriple (const XMLAttributes_t *xa, const XMLTriple_t* triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * this XMLAttributes_t structure is empty.
 *
 * @param xa the XMLAttributes_t structure.
 *
 * @return @c non-zero (true) if this XMLAttributes_t structure is empty,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_isEmpty (const XMLAttributes_t *xa);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could be interpreted as a boolean, value is
 * not modified.
 *
 * According to the W3C XML Schema, valid boolean values are: "true",
 * "false", "1", and "0" (case-insensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#boolean
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoBooleanByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoBoolean (XMLAttributes_t *xa,
			       const char *name,
			       int *value,
			       XMLErrorLog_t *log,
			       int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found or value could be interpreted as a boolean,
 * value is not modified.
 *
 * According to the W3C XML Schema, valid boolean values are: "true",
 * "false", "1", and "0" (case-insensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#boolean
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoBooleanByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               int *value,
                               XMLErrorLog_t *log,
                               int required);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could be interpreted as a double, value is
 * not modified.
 *
 * According to the W3C XML Schema, valid doubles are the same as valid
 * doubles for C and the special values "INF", "-INF", and "NaN"
 * (case-sensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#double
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoDoubleByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoDouble (XMLAttributes_t *xa,
			      const char *name,
			      double *value,
			      XMLErrorLog_t *log,
			      int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found or value could be interpreted as a double,
 * value is not modified.
 *
 * According to the W3C XML Schema, valid doubles are the same as valid
 * doubles for C and the special values "INF", "-INF", and "NaN"
 * (case-sensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#double
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoDoubleByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               double *value,
                               XMLErrorLog_t *log,
                               int required);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could be interpreted as a long, value is not
 * modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a long.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoLongByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoLong (XMLAttributes_t *xa,
			    const char *name,
			    long *value,
			    XMLErrorLog_t *log,
			    int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found or value could be interpreted as a long,
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a long.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoLongByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               long *value,
                               XMLErrorLog_t *log,
                               int required);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could be interpreted as an integer, value
 * is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a int.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoIntByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoInt (XMLAttributes_t *xa,
			   const char *name,
			   int *value,
			   XMLErrorLog_t *log,
			   int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found or value could be interpreted as an integer,
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a int.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a boolean, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoIntByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               int *value,
                               XMLErrorLog_t *log,
                               int required);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could be interpreted as an unsigned int,
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a unsigned int.  For more
 * information, see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value an unsigned int, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoUnsignedIntByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoUnsignedInt (XMLAttributes_t *xa,
				   const char *name,
				   unsigned int *value,
				   XMLErrorLog_t *log,
				   int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found or value could be interpreted as an unsigned
 * integer, value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a unsigned int.  For more
 * information, see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value an unsigned int, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoUnsignedIntByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               unsigned int *value,
                               XMLErrorLog_t *log,
                               int required);


/**
 * Reads the value for the attribute name into value.  If the given local
 * name was not found, value is not modified.
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @note A namespace bound to the given local name is not checked by this
 * function. readIntoStringByTriple(...) should be used to read a value for
 * an attribute name with a prefix and namespace.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoString (XMLAttributes_t *xa,
			      const char *name,
			      char **value,
			      XMLErrorLog_t *log,
			      int required);


/**
 * Reads the value for the attribute with the given XMLTriple_t into value.
 * If the XMLTriple_t was not found, value is not modified.
 *
 * If an XMLErrorLog_t is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 *
 * @param xa the XMLAttributes_t structure.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a string, the value of the attribute.
 * @param log an XMLErrorLog_t, the error log.
 * @param required a boolean, indicating whether the attribute is being sought.
 *
 * @returns @c non-zero (true) if the attribute was read into value,
 * @c zero (false) otherwise.
 *
 * @memberof XMLAttributes_t
 */
LIBLAX_EXTERN
int
XMLAttributes_readIntoStringByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               char **value,
                               XMLErrorLog_t *log,
                               int required);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* XMLAttributes_h */
