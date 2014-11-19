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
 * @sbmlbrief{core} An attribute on an XML node.
 *
 * @htmlinclude not-sbml-warning.html
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
   * Creates a new empty XMLAttributes set.
   */
  XMLAttributes ();


  /**
   * Destroys this XMLAttributes set.
   */
  virtual ~XMLAttributes ();


  /**
   * Copy constructor; creates a copy of this XMLAttributes set.
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
   * Adds an attribute (a name/value pair) to this XMLAttributes object,
   * optionally with a prefix and URI defining a namespace.
   *
   * @param name a string, the local name of the attribute.
   * @param value a string, the value of the attribute.
   * @param namespaceURI a string, the namespace URI of the attribute.
   * @param prefix a string, the prefix of the namespace
   *
   * @return an integer code indicating the success or failure of the
   * function.  The possible values returned by this
   * function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @note if local name with the same namespace URI already exists in this 
   * attribute set, its value and prefix will be replaced.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int add (  const std::string& name
	    , const std::string& value
	    , const std::string& namespaceURI = ""
	    , const std::string& prefix = "");


  /**
   * Adds an attribute with the given XMLTriple/value pair to this XMLAttributes set.
   *
   * @note if local name with the same namespace URI already exists in this attribute set, 
   * its value and prefix will be replaced.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a string, the value of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
   int add ( const XMLTriple& triple, const std::string& value);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Adds an name/value pair to this XMLAttributes set.  
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
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int addResource (const std::string& name, const std::string& value);

  /** @endcond */


  /**
   * Removes an attribute with the given index from this XMLAttributes set.  
   *
   * @param n an integer the index of the resource to be deleted
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeResource (int n);


  /**
   * Removes an attribute with the given index from this XMLAttributes set.  
   * (This function is an alias of XMLAttributes::removeResource(@if java int@endif) ).
   *
   * @param n an integer the index of the resource to be deleted
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int remove (int n);


  /**
   * Removes an attribute with the given local name and namespace URI from 
   * this XMLAttributes set.  
   *
   * @param name   a string, the local name of the attribute.
   * @param uri    a string, the namespace URI of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int remove (const std::string& name, const std::string& uri = "");


  /**
   * Removes an attribute with the given XMLTriple from this XMLAttributes set.  
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int remove (const XMLTriple& triple); 


  /**
   * Clears (deletes) all attributes in this XMLAttributes object.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int clear();


  /**
   * Return the index of an attribute with the given name.
   *
   * @note A namespace bound to the name is not checked by this function.
   * Thus, if there are multiple attributes with the given local name and
   * different namespaces, the smallest index among those attributes will
   * be returned.  XMLAttributes::getIndex(const std::string& name, const std::string& uri) const or
   * XMLAttributes::getIndex(const XMLTriple& triple) const should be used to get an index of an
   * attribute with the given local name and namespace.
   *
   * @param name a string, the local name of the attribute for which the 
   * index is required.
   *
   * @return the index of an attribute with the given local name, or -1 if not present.
   */
  int getIndex (const std::string& name) const;


  /**
   * Return the index of an attribute with the given local name and namespace URI.
   *
   * @param name a string, the local name of the attribute.
   * @param uri  a string, the namespace URI of the attribute.
   *
   * @return the index of an attribute with the given local name and namespace URI, 
   * or -1 if not present.
   */
  int getIndex (const std::string& name, const std::string& uri) const;


  /**
   * Return the index of an attribute with the given XMLTriple.
   *
   * @param triple an XMLTriple, the XML triple of the attribute for which 
   *        the index is required.
   *
   * @return the index of an attribute with the given XMLTriple, or -1 if not present.
   */
  int getIndex (const XMLTriple& triple) const;


  /**
   * Return the number of attributes in the set.
   *
   * @return the number of attributes in this XMLAttributes set.
   */
  int getLength () const;


  /**
   * Return the number of attributes in the set.
   *
   * @return the number of attributes in this XMLAttributes set.
   *
   * This function is an alias for getLength introduced for consistency
   * with other XML classes.
   */
  int getNumAttributes () const;


  /**
   * Return the local name of an attribute in this XMLAttributes set (by position).
   *
   * @param index an integer, the position of the attribute whose local name is 
   * required.
   *
   * @return the local name of an attribute in this list (by position).  
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLAttributes::hasAttribute(int index) const to test for the attribute
   * existence.
   */
  std::string getName (int index) const;


  /**
   * Return the prefix of an attribute in this XMLAttributes set (by position).
   *
   * @param index an integer, the position of the attribute whose prefix is 
   * required.
   *
   * @return the namespace prefix of an attribute in this list (by
   * position).  
   *
   * @note If index is out of range, an empty string will be returned. Use
   * XMLAttributes::hasAttribute(int index) const to test for the attribute
   * existence.
   */
  std::string getPrefix (int index) const;


  /**
   * Return the prefixed name of an attribute in this XMLAttributes set (by position).
   *
   * @param index an integer, the position of the attribute whose prefixed 
   * name is required.
   *
   * @return the prefixed name of an attribute in this list (by
   * position).  
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLAttributes::hasAttribute(int index) const to test for attribute existence.
   */
  std::string getPrefixedName (int index) const;


  /**
   * Return the namespace URI of an attribute in this XMLAttributes set (by position).
   *
   * @param index an integer, the position of the attribute whose namespace URI is 
   * required.
   *
   * @return the namespace URI of an attribute in this list (by position).
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLAttributes::hasAttribute(int index) const to test for attribute existence.
   */
  std::string getURI (int index) const;


  /**
   * Return the value of an attribute in this XMLAttributes set (by position).
   *
   * @param index an integer, the position of the attribute whose value is 
   * required.
   *
   * @return the value of an attribute in the list (by position).  
   *
   * @note If index is out of range, an empty string will be returned.  Use
   * XMLAttributes::hasAttribute(int index) const to test for attribute existence.
   */
  std::string getValue (int index) const;


  /**
   * Return an attribute's value by name.
   *
   * @param name a string, the local name of the attribute whose value is required.
   *
   * @return The attribute value as a string.  
   *
   * @note If an attribute with the given local name does not exist, an
   * empty string will be returned.  Use
   * XMLAttributes::hasAttribute(const std::string name, const std::string uri) const
   * to test for attribute existence.  A namespace bound to the local name
   * is not checked by this function.  Thus, if there are multiple
   * attributes with the given local name and different namespaces, the
   * value of an attribute with the smallest index among those attributes
   * will be returned.  XMLAttributes::getValue(const std::string name) const or
   * XMLAttributes::getValue(const XMLTriple& triple) const should be used to get a value of an
   * attribute with the given local name and namespace.
   */
  std::string getValue (const std::string name) const;


  /**
   * Return a value of an attribute with the given local name and namespace URI.
   *
   * @param name a string, the local name of the attribute whose value is required.
   * @param uri  a string, the namespace URI of the attribute.
   *
   * @return The attribute value as a string.  
   *
   * @note If an attribute with the given local name and namespace URI does
   * not exist, an empty string will be returned.  Use
   * XMLAttributes::hasAttribute(const std::string name, const std::string uri) const
   * to test for attribute existence.
   */
  std::string getValue (const std::string name, const std::string uri) const;

  /**
   * Return a value of an attribute with the given XMLTriple.
   *
   * @param triple an XMLTriple, the XML triple of the attribute whose 
   *        value is required.
   *
   * @return The attribute value as a string.  
   *
   * @note If an attribute with the given XMLTriple does not exist, an
   * empty string will be returned.  Use
   * XMLAttributes::hasAttribute(const XMLTriple& triple) const to test for attribute existence.
   */
  std::string getValue (const XMLTriple& triple) const;


  /**
   * Predicate returning @c true or @c false depending on whether
   * an attribute with the given index exists in this XMLAttributes.
   *
   * @param index an integer, the position of the attribute.
   *
   * @return @c true if an attribute with the given index exists in this
   * XMLAttributes, @c false otherwise.
   */
  bool hasAttribute (int index) const;


  /**
   * Predicate returning @c true or @c false depending on whether
   * an attribute with the given local name and namespace URI exists in this 
   * XMLAttributes.
   *
   * @param name a string, the local name of the attribute.
   * @param uri  a string, the namespace URI of the attribute.
   *
   * @return @c true if an attribute with the given local name and namespace 
   * URI exists in this XMLAttributes, @c false otherwise.
   */
  bool hasAttribute (const std::string name, const std::string uri="") const;


  /**
   * Predicate returning @c true or @c false depending on whether
   * an attribute with the given XML triple exists in this XMLAttributes.
   *
   * @param triple an XMLTriple, the XML triple of the attribute 
   *
   * @return @c true if an attribute with the given XML triple exists in this
   * XMLAttributes, @c false otherwise.
   *
   */
  bool hasAttribute (const XMLTriple& triple) const;


  /**
   * Predicate returning @c true or @c false depending on whether 
   * this XMLAttributes set is empty.
   * 
   * @return @c true if this XMLAttributes set is empty, @c false otherwise.
   */
  bool isEmpty () const;


  /**
   * Reads the value for the attribute name into value.  If the given local
   * name was not found or value could be interpreted as a boolean, value 
   * is not modified.
   *
   * According to the W3C XML Schema, valid boolean values are: "true",
   * "false", "1", and "0" (case-insensitive).  For more information, see:
   * http://www.w3.org/TR/xmlschema-2/#boolean
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   *
   * @param name a string, the local name of the attribute.
   * @param value a boolean, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function. XMLAttributes::readInto(const XMLTriple, bool&, ...) const should
   * be used to read a value for an attribute name with a prefix and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , bool&               value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false 
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given XMLTriple into value.  
   * If the XMLTriple was not found or value could be interpreted as a boolean, 
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
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a boolean, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , bool&        value
                 , XMLErrorLog* log      = NULL
                 , bool         required = false 
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;



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
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param name a string, the local name of the attribute.
   * @param value a double, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function.  XMLAttributes::readInto(const XMLTriple, double&, ...) const
   * should be used to read a value for an attribute name with a prefix and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , double&             value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given XMLTriple into value.  
   * If the triple was not found or value could be interpreted as a double, 
   *value is not modified.
   *
   * According to the W3C XML Schema, valid doubles are the same as valid
   * doubles for C and the special values "INF", "-INF", and "NaN"
   * (case-sensitive).  For more information, see:
   * http://www.w3.org/TR/xmlschema-2/#double
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a double, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple&  triple
                 , double&           value
                 , XMLErrorLog*      log      = NULL
                 , bool              required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute name into value.  If the given local
   * name was not found or value could be interpreted as an long, value is 
   * not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a long.  For more information,
   * see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param name a string, the local name of the attribute.
   * @param value a long, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function.  XMLAttributes::readInto(const XMLTriple, long&, ...) const should
   * be used to read a value for an attribute name with a prefix and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , long&               value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute XMLTriple into value.  
   * If the XMLTriple was not found or value could be interpreted as a long, 
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
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a long, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , long&            value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute name into value.  If the given local
   * name was not found or value could be interpreted as an int, value is 
   * not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a int.  For more information,
   * see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param name a string, the local name of the attribute.
   * @param value an integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function.  XMLAttributes::readInto(const XMLTriple, int&, ...) const should
   * be used to read a value for an attribute name with a prefix and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , int&                value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given XMLTriple into value.  
   * If the XMLTriple was not found or value could be interpreted as an int, 
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
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value an integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , int&             value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


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
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param name a string, the local name of the attribute.
   * @param value an unsigned integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function.  XMLAttributes::readInto(const XMLTriple, unsigned int&,
   * ...) const should be used to read a value for an attribute name with a
   * prefix and namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , unsigned int&       value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given XMLTriple into value.  
   * If the XMLTriple was not found or value could be interpreted as an unsigned int, 
   * value is not modified.
   *
   * According to the W3C XML Schema valid integers include zero, *all*
   * positive and *all* negative whole numbers.  For practical purposes, we
   * limit values to what can be stored in a unsigned int.  For more
   * information, see: http://www.w3.org/TR/xmlschema-2/#integer
   *
   * If an XMLErrorLog is passed in datatype format errors are logged.  If
   * required is true, missing attributes are also logged.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value an unsigned integer, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , unsigned int&    value
                 , XMLErrorLog*     log      = NULL
                 , bool             required = false 
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute name into value.  If the given local
   * name was not found, value is not modified.
   *
   * If an XMLErrorLog is passed in and required is true, missing
   * attributes are logged.
   *
   * @param name a string, the local name of the attribute.
   * @param value a string, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @note A namespace bound to the given local name is not checked by this
   * function. XMLAttributes::readInto(const XMLTriple, std::string&, ...) const
   * should be used to read a value for an attribute name with a prefix and
   * namespace.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const std::string&  name
                 , std::string&        value
                 , XMLErrorLog*        log      = NULL
                 , bool                required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


  /**
   * Reads the value for the attribute with the given XMLTriple into value.  
   * If the XMLTriple was not found, value is not modified.
   *
   * If an XMLErrorLog is passed in and required is true, missing
   * attributes are logged.
   *
   * @param triple an XMLTriple, the XML triple of the attribute.
   * @param value a string, the value of the attribute.
   * @param log an XMLErrorLog, the error log.
   * @param required a boolean, indicating whether the attribute is required.
   * @param line an unsigned int, the line number at which the error occured.
   * @param column an unsigned int, the column number at which the error occured.
   *
   * @returns @c true if the attribute was read into value, @c false otherwise.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  bool readInto (  const XMLTriple& triple
                 , std::string&     value
                 , XMLErrorLog*     log       = NULL
                 , bool              required = false
                 , const unsigned int line     = 0
                 , const unsigned int column   = 0) const;


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
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
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
   * @param required a boolean, indicating whether the attribute is required.
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
   * @param required a boolean, indicating whether the attribute is required.
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
   * @param required a boolean, indicating whether the attribute is required.
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
   * @param required a boolean, indicating whether the attribute is required.
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
   * @param required a boolean, indicating whether the attribute is required.
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
   * @param required a boolean, indicating whether the attribute is required.
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if local name already exists in this attribute set, its value 
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @param name a string, the local name of the attribute for which the index is required.
 * @param uri a string, the namespace URI of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 *        the index is required.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
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
 * @param name a string, the local name of the attribute for which the index is required.
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
 * @param name a string, the local name of the attribute for which the index is required.
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
 *        the index is required.
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
 * @param name a string, the local name of the attribute whose value is required.
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
 * @param name a string, the local name of the attribute whose value is required.
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
 * whose value is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
 * @param required a boolean, indicating whether the attribute is required.
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
