/**
 * @file    XMLTriple.h
 * @brief   Stores an XML namespace triple.
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
 * @class XMLTriple
 * @sbmlbrief{core} A qualified XML name.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * A "triple" in the libSBML XML layer encapsulates the notion of qualified
 * name, meaning an element name or an attribute name with an optional
 * namespace qualifier.  Triples by themselves are not entities in an XML
 * stream&mdash;they are not, for example, elements or attributes; rather,
 * XMLTriple is used in libSBML to construct these other kinds of objects.
 *
 * An XMLTriple instance carries up to three data items:
 * <ol>
 * <li> The name of the attribute or element; that is, the attribute name
 * as it appears in an XML document or data stream;
 * <li> The XML namespace prefix (if any) of the attribute.  For example,
 * in the following fragment of XML, the namespace prefix is the string
 * <code>mysim</code> and it appears on both the element
 * <code>someelement</code> and the attribute <code>attribA</code>.  When
 * both the element and the attribute are stored as XMLTriple objects,
 * their <i>prefix</i> is <code>mysim</code>.
 * @verbatim
<mysim:someelement mysim:attribA="value" />
@endverbatim
 * <li> The XML namespace URI with which the prefix is associated.  In
 * XML, every namespace used must be declared and mapped to a URI.
 * </ol>
 *
 * XMLTriple objects are the lowest-level data item in the XML layer
 * of libSBML.  Other objects such as XMLToken make use of XMLTriple
 * objects.
 *
 * @see XMLToken
 * @see XMLNode
 * @see XMLAttributes
 * @see XMLNamespaces
 */

#ifndef XMLTriple_h
#define XMLTriple_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBLAX_EXTERN XMLTriple
{
public:

  /**
   * Creates a new, empty XMLTriple object.
   */
  XMLTriple ();


  /**
   * Creates a new XMLTriple object with a given @p name, @p uri and and @p
   * prefix.
   *
   * @param name a string, the name for the entity represented by this object.
   * @param uri a string, the XML namespace URI associated with the prefix.
   * @param prefix a string, the XML namespace prefix for this triple.
   *
   * @throws XMLConstructorException
   * Thrown if any of the arguments are @c NULL.
   */
  XMLTriple (  const std::string&  name
             , const std::string&  uri
             , const std::string&  prefix );


  /**
   * Creates an XMLTriple object by splitting a given string at a given
   * separator character.
   *
   * The "triplet" in this case is a string that may be in one of the
   * following three possible formats:
   * <ol>
   * <li> <span style="background-color: lightblue; padding-left: 2px; padding-right: 2px">name</span> </li>
   * <li> <span style="background-color: #ccc; padding-left: 2px; padding-right: 2px">URI</span><span style="background-color: purple; color: white; padding-left: 2px; padding-right: 2px">x</span><span style="background-color: lightblue; padding-left: 2px; padding-right: 2px">name</span></li>
   * <li> <span style="background-color: #ccc; padding-left: 2px; padding-right: 2px">URI</span><span style="background-color: purple; color: white; padding-left: 2px; padding-right: 2px">x</span><span style="background-color: lightblue; padding-left: 2px; padding-right: 2px">name</span><span style="background-color: purple; color: white; padding-left: 2px; padding-right: 2px">x</span><span style="background-color: #d0d0fd; padding-left: 2px; padding-right: 2px">prefix</span></li>
   * </ol>
   *
   * where <span style="background-color: purple; color: white; padding-left: 2px; padding-right: 2px">x</span>
   * represents the separator character, @p sepchar.
   *
   * @param triplet a string representing the triplet as shown above
   * @param sepchar a character, the sepchar used in the triplet
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p triplet is @c NULL.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLTriple (const std::string& triplet, const char sepchar = ' ');


  /**
   * Copy constructor; creates a copy of this XMLTriple object.
   *
   * @param orig the XMLTriple object to copy.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  XMLTriple(const XMLTriple& orig);


  /**
   * Assignment operator for XMLTriple.
   *
   * @param rhs The XMLTriple object whose values are used as the basis
   * of the assignment.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  XMLTriple& operator=(const XMLTriple& rhs);


  /**
   * Creates and returns a deep copy of this XMLTriple object.
   *
   * @return the (deep) copy of this XMLTriple object.
   */
  XMLTriple* clone () const;


  /**
   * Returns the @em name portion of this XMLTriple object.
   *
   * @return a string, the name portion of this XMLTriple object.
   */
  const std::string& getName () const;


  /**
   * Returns the @em prefix portion of this XMLTriple object.
   *
   * @return a string, the prefix portion of this XMLTriple object.
   */
  const std::string& getPrefix () const;


  /**
   * Returns the @em URI portion of this XMLTriple object.
   *
   * @return URI a string, the URI portion of this XMLTriple object.
   */
  const std::string& getURI () const;


  /**
   * Returns the prefixed name from this XMLTriple.
   *
   * @return a string, the prefixed name from this XMLTriple.  This is
   * constructed by concatenating the @em prefix stored in this XMLTriple
   * object, followed by a colon character <code>":"</code>, followed by the
   * @em name stored in this XMLTriple object.
   */
  const std::string getPrefixedName () const;


  /**
   * Returns @c true if this XMLTriple object is empty.
   *
   * @return @c true if this XMLTriple is empty, @c false otherwise.
   */
  bool isEmpty () const;


private:
  /** @cond doxygenLibsbmlInternal */

  std::string  mName;
  std::string  mURI;
  std::string  mPrefix;

  /** @endcond */
};


/**
 * Comparison (equal-to) operator for XMLTriple.
 *
 * @param lhs XMLTriple object to be compared with rhs.
 * @param rhs XMLTriple object to be compared with lhs.
 *
 * return @c non-zero (true) if the combination of name, URI, and
 * prefix of lhs is equal to that of rhs @c zero (false) otherwise.
 */
bool operator==(const XMLTriple& lhs, const XMLTriple& rhs);


/**
 *  Comparison (not equal-to) operator for XMLTriple.
 *
 * @param lhs XMLTriple object to be compared with rhs.
 * @param rhs XMLTriple object to be compared with lhs.
 *
 * return @c non-zero (true) if the combination of name, URI, and
 * prefix of lhs is not equal to that of rhs @c zero (false) otherwise.
 */
bool operator!=(const XMLTriple& lhs, const XMLTriple& rhs);


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLTriple_t structure and returns a pointer to it.
 *
 * @return pointer to created XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
XMLTriple_t *
XMLTriple_create (void);


/**
 * Creates a new XMLTriple_t structure with name, prefix and uri.
 *
 * @param name a string, name for the XMLTriple_t structure.
 * @param uri a string, URI of the XMLTriple_t structure.
 * @param prefix a string, prefix for the URI of the XMLTriple_t structure.
 *
 * @return pointer to the created XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
XMLTriple_t *
XMLTriple_createWith (const char *name, const char *uri, const char *prefix);


/**
 * Destroys this XMLTriple_t structure.
 *
 * @param triple XMLTriple_t structure to be freed.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
void
XMLTriple_free (XMLTriple_t *triple);


/**
 * Creates a deep copy of the given XMLTriple_t structure
 *
 * @param triple the XMLTriple_t structure to be copied
 *
 * @return a (deep) copy of the given XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
XMLTriple_t *
XMLTriple_clone (const XMLTriple_t* triple);


/**
 * Returns the name from this XMLTriple_t structure.
 *
 * @param triple XMLTriple_t structure to be queried.
 *
 * @return name from this XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
const char *
XMLTriple_getName (const XMLTriple_t *triple);


/**
 * Returns the prefix from this XMLTriple_t structure.
 *
 * @param triple XMLTriple_t structure to be queried.
 *
 * @return prefix from this XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
const char *
XMLTriple_getPrefix (const XMLTriple_t *triple);


/**
 * Returns the URI from this XMLTriple_t structure.
 *
 * @param triple XMLTriple_t structure to be queried.
 *
 * @return URI from this XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
const char *
XMLTriple_getURI (const XMLTriple_t *triple);


/**
 * Returns the prefixed name from this XMLTriple_t structure.
 *
 * @param triple XMLTriple_t structure to be queried.
 *
 * @return prefixed name from this XMLTriple_t structure.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
const char *
XMLTriple_getPrefixedName (const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * this XMLTriple_t is empty.
 *
 * @param triple XMLTriple_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLTriple_t is empty, @c zero (false) otherwise.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
int
XMLTriple_isEmpty(const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * this XMLTriple_t is equal to the given XMLTriple_t.
 *
 * @param lhs XMLTriple_t structure to be required.
 * @param rhs XMLTriple_t structure to be compared with this XMLTriple_t.
 *
 * @return @c non-zero (true) if the combination of name, URI, and prefix of this
 * XMLTriple_t is equal to that of the given XMLTriple_t,
 * @c zero (false) otherwise.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
int
XMLTriple_equalTo(const XMLTriple_t *lhs, const XMLTriple_t* rhs);


/**
 * Predicate returning @c true or @c false depending on whether
 * this XMLTriple_t is not equal to the given XMLTriple_t.
 *
 * @param lhs XMLTriple_t structure to be required.
 * @param rhs XMLTriple_t structure to be compared with this XMLTriple_t.
 *
 * @return @c non-zero (true) if the combination of name, URI, and prefix of this
 * XMLTriple_t is not equal to that of the given XMLTriple_t,
 * @c zero (false) otherwise.
 *
 * @memberof XMLTriple_t
 */
LIBLAX_EXTERN
int
XMLTriple_notEqualTo(const XMLTriple_t *lhs, const XMLTriple_t* rhs);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLTriple_h */
