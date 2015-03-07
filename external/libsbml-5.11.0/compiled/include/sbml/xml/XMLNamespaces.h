/**
 * @file    XMLNamespaces.h
 * @brief   A list of XMLNamespace declarations (URI/prefix pairs)
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
 * @class XMLNamespaces
 * @sbmlbrief{core} An XML Namespace.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * This class serves to organize functionality for tracking XML namespaces
 * in a document or data stream.  The namespace declarations are stored as
 * a list of pairs of XML namespace URIs and prefix strings.  These
 * correspond to the parts of a namespace declaration on an XML element.
 * For example, in the following XML fragment,
 * @verbatim
<annotation>
    <mysim:nodecolors xmlns:mysim="urn:lsid:mysim.org"
         mysim:bgcolor="green" mysim:fgcolor="white"/>
</annotation>
@endverbatim
 * there is one namespace declaration.  Its URI is
 * <code>urn:lsid:mysim.org</code> and its prefix is <code>mysim</code>.
 * This pair could be stored as one item in an XMLNamespaces list.
 *
 * XMLNamespaces provides various methods for manipulating the list of
 * prefix-URI pairs.  Individual namespaces stored in a given XMLNamespace
 * object instance can be retrieved based on their index using
 * XMLNamespaces::getPrefix(int index), or by their characteristics such as
 * their URI or position in the list.
 */

#ifndef XMLNamespaces_h
#define XMLNamespaces_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>


#ifdef __cplusplus

#include <string>
#include <vector>

LIBSBML_CPP_NAMESPACE_BEGIN

/** @cond doxygenLibsbmlInternal */
class XMLOutputStream;
/** @endcond */


class LIBLAX_EXTERN XMLNamespaces
{
public:

  /**
   * Creates a new empty list of XML namespace declarations.
   */
  XMLNamespaces ();


  /**
   * Destroys this list of XML namespace declarations.
   */
  virtual ~XMLNamespaces ();


  /**
   * Copy constructor; creates a copy of this XMLNamespaces list.
   *
   * @param orig the XMLNamespaces object to copy
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  XMLNamespaces(const XMLNamespaces& orig);


  /**
   * Assignment operator for XMLNamespaces.
   *
   * @param rhs The XMLNamespaces object whose values are used as the basis
   * of the assignment.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  XMLNamespaces& operator=(const XMLNamespaces& rhs);


  /**
   * Creates and returns a deep copy of this XMLNamespaces object.
   *
   * @return the (deep) copy of this XMLNamespaces object.
   */
  XMLNamespaces* clone () const;


  /**
   * Appends an XML namespace prefix and URI pair to this list of namespace
   * declarations.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  If there is an XML namespace with the given @p uri prefix
   * in this list, then its corresponding URI will be overwritten by the
   * new @p uri unless the uri represents the core sbml namespace.
   * Calling programs could use one of the other XMLNamespaces
   * methods, such as
   * XMLNamespaces::hasPrefix(@if java String@endif) and 
   * XMLNamespaces::hasURI(@if java String@endif) to
   * inquire whether a given prefix and/or URI
   * is already present in this XMLNamespaces object.
   * If the @p uri represents the sbml namespaces then it will not be
   * overwritten, as this has potentially serious consequences. If it
   * is necessary to replace the sbml namespace the namespace should be removed
   * prior to adding the new namespace.
   *
   * @param uri a string, the uri for the namespace
   * @param prefix a string, the prefix for the namespace
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  int add (const std::string& uri, const std::string& prefix = "");


  /**
   * Removes an XML Namespace stored in the given position of this list.
   *
   * @param index an integer, position of the namespace to remove.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int remove (int index);


  /**
   * Removes an XML Namespace with the given prefix.
   *
   * @param prefix a string, prefix of the required namespace.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   *
   * @see remove(int index)
   */
  int remove (const std::string& prefix);


  /**
   * Clears (deletes) all XML namespace declarations in this XMLNamespaces
   * object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see remove(int index)
   */
  int clear ();


  /**
   * Look up the index of an XML namespace declaration by URI.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  If this XMLNamespaces object contains a pair with the given
   * URI @p uri, this method returns its index in the list.
   *
   * @param uri a string, the URI of the sought-after namespace.
   *
   * @return the index of the given declaration, or <code>-1</code> if not
   * present.
   */
  int getIndex (const std::string uri) const;

  /**
   * Tests whether the given uri is contained in this set of namespaces. 
   * 
   */
  bool containsUri(const std::string uri) const;

  /**
   * Look up the index of an XML namespace declaration by prefix.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  If this XMLNamespaces object contains a pair with the given
   * prefix @p prefix, this method returns its index in the list.
   *
   * @param prefix a string, the prefix string of the sought-after
   * namespace
   *
   * @return the index of the given declaration, or <code>-1</code> if not
   * present.
   */
  int getIndexByPrefix (const std::string prefix) const;


  /**
   * Returns the total number of URI-and-prefix pairs stored in this
   * particular XMLNamespaces instance.
   *
   * @return the number of namespaces in this list.
   */
  int getLength () const;


  /**
   * Returns the total number of URI-and-prefix pairs stored in this
   * particular XMLNamespaces instance.
   *
   * @return the number of namespaces in this list.
   *
   * This function is an alias for getLength introduced for consistency
   * with other XML classes.
   */
  int getNumNamespaces () const;


  /**
   * Look up the prefix of an XML namespace declaration by its position.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  This method returns the prefix of the <code>n</code>th
   * element in that list (if it exists).  Callers should use
   * XMLAttributes::getLength() first to find out how many namespaces are
   * stored in the list.
   *
   * @param index an integer, position of the sought-after prefix
   *
   * @return the prefix of an XML namespace declaration in this list (by
   * position), or an empty string if the @p index is out of range
   *
   * @see getLength()
   */
  std::string getPrefix (int index) const;


  /**
   * Look up the prefix of an XML namespace declaration by its URI.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  This method returns the prefix for a pair that has the
   * given @p uri.
   *
   * @param uri a string, the URI of the prefix being sought
   *
   * @return the prefix of an XML namespace declaration given its URI, or
   * an empty string if no such @p uri exists in this XMLNamespaces object
   */
  std::string getPrefix (const std::string& uri) const;


  /**
   * Look up the URI of an XML namespace declaration by its position.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  This method returns the URI of the <code>n</code>th element
   * in that list (if it exists).  Callers should use
   * XMLAttributes::getLength() first to find out how many namespaces are
   * stored in the list.
   *
   * @param index an integer, position of the required URI.
   *
   * @return the URI of an XML namespace declaration in this list (by
   * position), or an empty string if the @p index is out of range.
   *
   * @see getLength()
   */
  std::string getURI (int index) const;


  /**
   * Look up the URI of an XML namespace declaration by its prefix.
   *
   * An XMLNamespaces object stores a list of pairs of namespaces and their
   * prefixes.  This method returns the namespace URI for a pair that has
   * the given @p prefix.
   *
   * @param prefix a string, the prefix of the required URI
   *
   * @return the URI of an XML namespace declaration having the given @p
   * prefix, or an empty string if no such prefix-and-URI pair exists
   * in this XMLNamespaces object
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   * 
   * @see getURI()
   */
  std::string getURI (const std::string& prefix = "") const;


  /**
   * Predicate returning @c true or @c false depending on whether this
   * XMLNamespaces list is empty.
   * 
   * @return @c true if this XMLNamespaces list is empty, @c false otherwise.
   */
  bool isEmpty () const;


  /**
   * Predicate returning @c true or @c false depending on whether an XML
   * Namespace with the given URI is contained in this XMLNamespaces list.
   * 
   * @param uri a string, the uri for the namespace
   *
   * @return @c true if an XML Namespace with the given URI is contained in
   * this XMLNamespaces list, @c false otherwise.
   */
  bool hasURI(const std::string& uri) const;


  /**
   * Predicate returning @c true or @c false depending on whether an XML
   * Namespace with the given prefix is contained in this XMLNamespaces
   * list.
   *
   * @param prefix a string, the prefix for the namespace
   * 
   * @return @c true if an XML Namespace with the given URI is contained in
   * this XMLNamespaces list, @c false otherwise.
   */
  bool hasPrefix(const std::string& prefix) const;


  /**
   * Predicate returning @c true or @c false depending on whether an XML
   * Namespace with the given URI and prefix pair is contained in this
   * XMLNamespaces list.
   *
   * @param uri a string, the URI for the namespace
   * @param prefix a string, the prefix for the namespace
   * 
   * @return @c true if an XML Namespace with the given uri/prefix pair is
   * contained in this XMLNamespaces list, @c false otherwise.
   */
  bool hasNS(const std::string& uri, const std::string& prefix) const;


#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */

  /**
   * Writes this XMLNamespaces list to stream.
   *
   * @param stream XMLOutputStream, stream to which this XMLNamespaces
   * list is to be written.
   */
  void write (XMLOutputStream& stream) const;


  /**
   * Inserts this XMLNamespaces list into stream.
   *
   * @param stream XMLOutputStream, stream to which the XMLNamespaces
   * list is to be written.
   * @param namespaces XMLNamespaces, namespaces to be written to stream.
   *
   * @return the stream with the namespaces inserted.
   */
  LIBLAX_EXTERN
  friend XMLOutputStream&
  operator<< (XMLOutputStream& stream, const XMLNamespaces& namespaces);

  /** @endcond */

#endif  /* !SWIG */

  /** @cond doxygenLibsbmlInternal */

  friend class SBase;

  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Removes the default XML namespace.
   */
  void removeDefault ();


  bool containIdenticalSetNS(XMLNamespaces* rhs);

  typedef std::pair<std::string, std::string> PrefixURIPair;
  std::vector<PrefixURIPair> mNamespaces;

  /** @endcond */
};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLNamespaces_t structure.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
XMLNamespaces_t *
XMLNamespaces_create (void);


/**
 * Frees the given XMLNamespaces_t structure.
 *
 * @param ns XMLNamespaces structure to be freed.
 **
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
void
XMLNamespaces_free (XMLNamespaces_t *ns);


/**
 * Creates a deep copy of the given XMLNamespaces_t structure
 * 
 * @param ns the XMLNamespaces_t structure to be copied
 * 
 * @return a (deep) copy of the given XMLNamespaces_t structure.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
XMLNamespaces_t *
XMLNamespaces_clone (const XMLNamespaces_t* ns);


/**
 * Appends an XML namespace prefix/URI pair to this XMLNamespaces_t 
 * structure.
 *
 * @param ns the XMLNamespaces_t structure.
 * @param uri a string, the uri for the namespace.
 * @param prefix a string, the prefix for the namespace.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_add (XMLNamespaces_t *ns, 
		   const char *uri, const char *prefix);


/**
 * Removes an XML Namespace stored in the given position of this list.
 *
 * @param ns XMLNamespaces structure.
 * @param index an integer, position of the removed namespace.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int 
XMLNamespaces_remove (XMLNamespaces_t *ns, int index);


/**
 * Removes an XML Namespace with the given @p prefix.
 *
 * @param ns XMLNamespaces structure.
 * @param prefix a string, prefix of the required namespace.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int 
XMLNamespaces_removeByPrefix (XMLNamespaces_t *ns, const char* prefix);


/**
 * Clears this XMLNamespaces_t structure.
 *
 * @param ns XMLNamespaces structure.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 **
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_clear (XMLNamespaces_t *ns);


/**
 * Lookup the index of an XML namespace declaration by URI.
 *
 * @param ns the XMLNamespaces_t structure
 * @param uri a string, uri of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_getIndex (const XMLNamespaces_t *ns, const char *uri);


/**
 * Look up the index of an XML namespace declaration by Prefix.
 *
 * @param ns the XMLNamespaces_t structure
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int XMLNamespaces_getIndexByPrefix (const XMLNamespaces_t *ns, const char* prefix);


/**
 * Returns the total number of URI-and-prefix pairs stored in this
 * particular XMLNamespaces instance.
 *
 * @param ns the XMLNamespaces_t structure
 *
 * @return the number of namespaces in this list.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_getLength (const XMLNamespaces_t *ns);


/**
 * Returns the total number of URI-and-prefix pairs stored in this
 * particular XMLNamespaces instance.
 *
 * This function is an alias for getLength introduced for consistency
 * with other XML classes.
 *
 * @param ns the XMLNamespaces_t structure
 *
 * @return the number of namespaces in this list.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_getNumNamespaces (const XMLNamespaces_t *ns);


/**
 * Look up the prefix of an XML namespace declaration by its position.
 *
 * An XMLNamespaces structure stores a list of pairs of namespaces and their
 * prefixes.  This method returns the prefix of the <code>n</code>th
 * element in that list (if it exists).  Callers should use
 * XMLAttributes_getLength() first to find out how many namespaces are
 * stored in the list.
 *
 * @param ns the XMLNamespaces_t structure
 * @param index an integer, position of the sought-after prefix
 *
 * @return the prefix of an XML namespace declaration in this list (by
 * position), or an empty string if the @p index is out of range
 *
 * @see XMLNamespaces_getLength()
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
char *
XMLNamespaces_getPrefix (const XMLNamespaces_t *ns, int index);


/**
 * Look up the prefix of an XML namespace declaration by its URI.
 *
 * An XMLNamespaces structure stores a list of pairs of namespaces and their
 * prefixes.  This method returns the prefix for a pair that has the
 * given @p uri.
 *
 * @param ns the XMLNamespaces_t structure
 * @param uri a string, the URI of the prefix being sought
 *
 * @return the prefix of an XML namespace declaration given its URI, or
 * an empty string if no such @p uri exists in this XMLNamespaces_t structure
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
char *
XMLNamespaces_getPrefixByURI (const XMLNamespaces_t *ns, const char *uri);


/**
 * Look up the URI of an XML namespace declaration by its position.
 *
 * An XMLNamespaces structure stores a list of pairs of namespaces and their
 * prefixes.  This method returns the URI of the <code>n</code>th element
 * in that list (if it exists).  Callers should use
 * XMLAttributes::getLength() first to find out how many namespaces are
 * stored in the list.
 *
 * @param ns the XMLNamespaces_t structure
 * @param index an integer, position of the required URI.
 *
 * @return the URI of an XML namespace declaration in this list (by
 * position), or an empty string if the @p index is out of range.
 *
 * @see XMLNamespaces_getLength()
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
char *
XMLNamespaces_getURI (const XMLNamespaces_t *ns, int index);


/**
 * Look up the URI of an XML namespace declaration by its prefix.
 *
 * An XMLNamespaces object stores a list of pairs of namespaces and their
 * prefixes.  This method returns the namespace URI for a pair that has
 * the given @p prefix.
 *
 * @param ns the XMLNamespaces_t structure
 * @param prefix a string, the prefix of the required URI
 *
 * @return the URI of an XML namespace declaration having the given @p
 * prefix, or an empty string if no such prefix-and-URI pair exists
 * in this XMLNamespaces_t object
 *
 * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
 * 
 * @see getURI()
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
char *
XMLNamespaces_getURIByPrefix (const XMLNamespaces_t *ns, const char *prefix);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNamespaces_t list is empty.
 * 
 * @return @c true if this XMLNamespaces_t list is empty, @c false otherwise.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int
XMLNamespaces_isEmpty (const XMLNamespaces_t *ns);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given URI is contained in this XMLNamespaces_t list.
 * 
 * @return @c true if an XML Namespace with the given URI is contained in this 
 * XMLNamespaces list,  @c false otherwise.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int 
XMLNamespaces_hasURI(const XMLNamespaces_t *ns, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace the given @p prefix is contained in this XMLNamespaces_t list.
 * 
 * @return @c true if an XML Namespace with the given URI is contained in this 
 * XMLNamespaces list, @c false otherwise.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int 
XMLNamespaces_hasPrefix(const XMLNamespaces_t *ns, const char* prefix);


/**
 * Predicate returning @c true or @c false depending on whether
 * an XML Namespace with the given URI is contained in this XMLNamespaces_t list.
 *
 * @return @c true if an XML Namespace with the given uri/prefix pair is contained
 * in this XMLNamespaces_t list,  @c false otherwise.
 *
 * @memberof XMLNamespaces_t
 */
LIBLAX_EXTERN
int 
XMLNamespaces_hasNS(const XMLNamespaces_t *ns, const char* uri, const char* prefix);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLNamespaces_h */
