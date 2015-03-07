/**
 * @file    SBMLNamespaces.h
 * @brief   SBMLNamespaces class to store level/version and namespace 
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
 * @class SBMLNamespaces
 * @sbmlbrief{core} Set of SBML Level + Version + namespace triples.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * There are differences in the definitions of components between different
 * SBML Levels, as well as Versions within Levels.  For example, the
 * "sboTerm" attribute was not introduced until Level&nbsp;2
 * Version&nbsp;2, and then only on certain component classes; the SBML
 * Level&nbsp;2 Version&nbsp;3 specification moved the "sboTerm" attribute
 * to the SBase class, thereby allowing nearly all components to have SBO
 * annotations.  As a result of differences such as those, libSBML needs to
 * track the SBML Level and Version of every object created.
 * 
 * The purpose of the SBMLNamespaces object class is to make it easier to
 * communicate SBML Level and Version data between libSBML constructors and
 * other methods.  The SBMLNamespaces object class tracks 3-tuples
 * (triples) consisting of SBML Level, Version, and the corresponding SBML
 * XML namespace.
 *
 * The plural name (SBMLNamespaces) is not a mistake, because in SBML
 * Level&nbsp;3, objects may have extensions added by Level&nbsp;3 packages
 * used by a given model and therefore may have multiple namespaces
 * associated with them; however, until the introduction of SBML
 * Level&nbsp;3, the SBMLNamespaces object only records one SBML
 * Level/Version/namespace combination at a time.  Most constructors for
 * SBML objects in libSBML take a SBMLNamespaces object as an argument,
 * thereby allowing the constructor to produce the proper combination of
 * attributes and other internal data structures for the given SBML Level
 * and Version.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_sbmlnamespaces_what_is_it
 *
 * @par
 * SBMLNamespaces objects are used in libSBML to communicate SBML Level and
 * Version data between constructors and other methods.  The SBMLNamespaces
 * object class holds triples consisting of SBML Level, Version, and the
 * corresponding SBML XML namespace.  Most constructors for SBML objects in
 * libSBML take a SBMLNamespaces object as an argument, thereby allowing
 * the constructor to produce the proper combination of attributes and
 * other internal data structures for the given SBML Level and Version.
 *
 * The plural name (SBMLNamespaces) is not a mistake, because in SBML
 * Level&nbsp;3, objects may have extensions added by Level&nbsp;3 packages
 * used by a given model and therefore may have multiple namespaces
 * associated with them.  In SBML Levels below Level&nbsp;3, the
 * SBMLNamespaces object only records one SBML Level/Version/namespace
 * combination at a time.  Most constructors for SBML objects in libSBML
 * take a SBMLNamespaces object as an argument, thereby allowing the
 * constructor to produce the proper combination of attributes and other
 * internal data structures for the given SBML Level and Version.
 *
 */

#ifndef SBMLNamespaces_h
#define SBMLNamespaces_h

#include <sbml/xml/XMLNamespaces.h>
#include <sbml/common/common.h>

#ifdef __cplusplus
namespace LIBSBML_CPP_NAMESPACE {
  const unsigned int SBML_DEFAULT_LEVEL   = 3;
  const unsigned int SBML_DEFAULT_VERSION = 1;
  const char* const SBML_XMLNS_L1   = "http://www.sbml.org/sbml/level1";
  const char* const SBML_XMLNS_L2V1 = "http://www.sbml.org/sbml/level2";
  const char* const SBML_XMLNS_L2V2 = "http://www.sbml.org/sbml/level2/version2";
  const char* const SBML_XMLNS_L2V3 = "http://www.sbml.org/sbml/level2/version3";
  const char* const SBML_XMLNS_L2V4 = "http://www.sbml.org/sbml/level2/version4";
  const char* const SBML_XMLNS_L3V1 = "http://www.sbml.org/sbml/level3/version1/core";
}
#else
static const unsigned int SBML_DEFAULT_LEVEL   = 3;
static const unsigned int SBML_DEFAULT_VERSION = 1;
static const char* const SBML_XMLNS_L1   = "http://www.sbml.org/sbml/level1";
static const char* const SBML_XMLNS_L2V1 = "http://www.sbml.org/sbml/level2";
static const char* const SBML_XMLNS_L2V2 = "http://www.sbml.org/sbml/level2/version2";
static const char* const SBML_XMLNS_L2V3 = "http://www.sbml.org/sbml/level2/version3";
static const char* const SBML_XMLNS_L2V4 = "http://www.sbml.org/sbml/level2/version4";
static const char* const SBML_XMLNS_L3V1 = "http://www.sbml.org/sbml/level3/version1/core";
#endif

#ifdef __cplusplus

#include <string>
#include <stdexcept>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBMLNamespaces
{
public:

  /**
   * Creates a new SBMLNamespaces object corresponding to the given SBML
   * @p level and @p version.
   *
   * @copydetails doc_sbmlnamespaces_what_is_it 
   *
   * @param level the SBML level
   * @param version the SBML version
   * 
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  SBMLNamespaces(unsigned int level = SBML_DEFAULT_LEVEL, 
                 unsigned int version = SBML_DEFAULT_VERSION);


  /**
   * (For extensions) Creates a new SBMLNamespaces object corresponding to
   * the combination of (1) the given SBML @p level and @p version, and (2)
   * the given @p package with the @p package @p version.
   *
   * @copydetails doc_sbmlnamespaces_what_is_it 
   *
   * @param level   the SBML Level
   * @param version the SBML Version
   * @param pkgName the string of package name (e.g. "layout", "multi")
   * @param pkgVersion the package version
   * @param pkgPrefix the prefix of the package namespace (e.g. "layout", "multi") to be added.
   *        The package's name will be used if the given string is empty (default).
   *
   * @throws SBMLExtensionException if the extension module that supports the
   * combination of the given SBML Level, SBML Version, package name, and
   * package version has not been registered with libSBML.
   */
  SBMLNamespaces(unsigned int level, unsigned int version, const std::string &pkgName,
                 unsigned int pkgVersion, const std::string& pkgPrefix = ""); 
  

  /**
   * Destroys this SBMLNamespaces object.
   */
  virtual ~SBMLNamespaces();

  
  /**
   * Copy constructor; creates a copy of a SBMLNamespaces.
   * 
   * @param orig the SBMLNamespaces instance to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SBMLNamespaces(const SBMLNamespaces& orig);


  /**
   * Assignment operator for SBMLNamespaces.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLNamespaces& operator=(const SBMLNamespaces& rhs);


  /**
   * Creates and returns a deep copy of this SBMLNamespaces object.
   *
   * @return the (deep) copy of this SBMLNamespaces object.
   */
  virtual SBMLNamespaces* clone () const;


  /**
   * Returns a string representing the SBML XML namespace for the 
   * given @p level and @p version of SBML.
   *
   * @param level the SBML level
   * @param version the SBML version
   *
   * @return a string representing the SBML namespace that reflects the
   * SBML Level and Version specified.
   *
   * @copydetails doc_note_static_methods
   */
  static std::string getSBMLNamespaceURI(unsigned int level,
                                         unsigned int version);

  
  /**
   * Returns a list of all supported SBMLNamespaces in this version of 
   * libsbml. 
   * 
   * @return a list with supported SBML namespaces. 
   *
   * @copydetails doc_note_static_methods
   */
  static const List* getSupportedNamespaces();


  /**
   * Frees the list of supported namespaces as generated by
   * getSupportedNamespaces().
   *
   * @param supportedNS the list to be freed.
   *
   * @copydetails doc_note_static_methods
   */
  static void freeSBMLNamespaces(List * supportedNS);


  /**
   * Returns a string representing the SBML XML namespace of this
   * object.
   *
   * @return a string representing the SBML namespace that reflects the
   * SBML Level and Version of this object.
   */
  virtual std::string getURI() const;


  /**
   * Get the SBML Level of this SBMLNamespaces object.
   *
   * @return the SBML Level of this SBMLNamespaces object.
   */
  unsigned int getLevel();


  /**
   * Get the SBML Level of this SBMLNamespaces object.
   *
   * @return the SBML Level of this SBMLNamespaces object.
   */
  unsigned int getLevel() const;


  /**
   * Get the SBML Version of this SBMLNamespaces object.
   *
   * @return the SBML Version of this SBMLNamespaces object.
   */
  unsigned int getVersion();


  /**
   * Get the SBML Version of this SBMLNamespaces object.
   *
   * @return the SBML Version of this SBMLNamespaces object.
   */
  unsigned int getVersion() const;


  /**
   * Get the XML namespaces list for this SBMLNamespaces object.
   *
   * @copydetails doc_sbmlnamespaces_what_is_it
   *
   * @return the XML namespaces of this SBMLNamespaces object.
   */
  XMLNamespaces * getNamespaces();


  /**
   * Get the XML namespaces list for this SBMLNamespaces object.
   * 
   * @copydetails doc_sbmlnamespaces_what_is_it
   *
   * @return the XML namespaces of this SBMLNamespaces object.
   */
  const XMLNamespaces * getNamespaces() const;


  /**
   * Add the given XML namespaces list to the set of namespaces within this
   * SBMLNamespaces object.
   *
   * The following code gives an example of how one could add the XHTML
   * namespace to the list of namespaces recorded by the top-level
   * <code>&lt;sbml&gt;</code> element of a model.  It gives the new
   * namespace a prefix of <code>html</code>.
   * @if cpp
   * @code{.cpp}
SBMLDocument *sd;
try
{
    sd = new SBMLDocument(3, 1);
}
catch (SBMLConstructorException e)
{
    // Here, have code to handle a truly exceptional situation. Candidate
    // causes include invalid combinations of SBML Level and Version
    // (impossible if hardwired as given here), running out of memory, and
    // unknown system exceptions.
}

SBMLNamespaces sn = sd->getNamespaces();
if (sn != NULL)
{
    sn->add("http://www.w3.org/1999/xhtml", "html");
}
else
{
    // Handle another truly exceptional situation.
}
@endcode
@endif
@if java
@code{.java}
SBMLDocument sd;
try
{
    sd = new SBMLDocument(3, 1);
}
catch (SBMLConstructorException e)
{
    // Here, have code to handle a truly exceptional situation. Candidate
    // causes include invalid combinations of SBML Level and Version
    // (impossible if hardwired as given here), running out of memory, and
    // unknown system exceptions.
}

SBMLNamespaces sn = sd.getNamespaces();
if (sn != null)
{
    sn.add("http://www.w3.org/1999/xhtml", "html");
}
else
{
    // Handle another truly exceptional situation.
 }
@endcode
@endif
@if python
@code{.py}
sbmlDoc = None
try:
  sbmlDoc = SBMLDocument(3, 1)
except ValueError:
  # Do something to handle exceptional situation.  Candidate
  # causes include invalid combinations of SBML Level and Version
  # (impossible if hardwired as given here), running out of memory, and
  # unknown system exceptions.

namespaces = sbmlDoc.getNamespaces()
if namespaces == None:
  # Do something to handle case of no namespaces.

status = namespaces.add("http://www.w3.org/1999/xhtml", "html")
if status != LIBSBML_OPERATION_SUCCESS:
  # Do something to handle failure.
@endcode
@endif
@if csharp
@code{.cs}
SBMLDocument sd = null;
try
{
    sd = new SBMLDocument(3, 1);
}
catch (SBMLConstructorException e)
{
    // Here, have code to handle a truly exceptional situation.
    // Candidate causes include invalid combinations of SBML
    // Level and Version (impossible if hardwired as given here),
    // running out of memory, and unknown system exceptions.
}

XMLNamespaces sn = sd.getNamespaces();
if (sn != null)
{
    sn.add("http://www.w3.org/1999/xhtml", "html");
}
else
{
    // Handle another truly exceptional situation.
}
@endcode
   * @endif@~
   *
   * @param xmlns the XML namespaces to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int addNamespaces(const XMLNamespaces * xmlns);


  /**
   * Add an XML namespace (a pair of URI and prefix) to the set of namespaces
   * within this SBMLNamespaces object.
   * 
   * @param uri    the XML namespace to be added.
   * @param prefix the prefix of the namespace to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int addNamespace(const std::string& uri, const std::string &prefix);


  /**
   * Removes an XML namespace from the set of namespaces within this 
   * SBMLNamespaces object.
   * 
   * @param uri    the XML namespace to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removeNamespace(const std::string& uri);


  /**
   * Add an XML namespace (a pair of URI and prefix) of a package extension
   * to the set of namespaces within this SBMLNamespaces object.
   *
   * The SBML Level and SBML Version of this object is used.
   * 
   * @param pkgName the string of package name (e.g. "layout", "multi")
   * @param pkgVersion the package version
   * @param prefix the prefix of the package namespace to be added.
   *        The package's name will be used if the given string is empty (default).
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note An XML namespace of a non-registered package extension can't be
   * added by this function (@sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t} 
   * will be returned).
   *
   * @see addNamespace(@if java String, String@endif)
   */
  int addPackageNamespace(const std::string &pkgName, unsigned int pkgVersion, 
                      const std::string &prefix = "");


  /**
   * Add the XML namespaces of package extensions in the given XMLNamespace
   * object to the set of namespaces within this SBMLNamespaces object
   * (Non-package XML namespaces are not added by this function).
   * 
   * @param xmlns the XML namespaces to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note XML namespaces of a non-registered package extensions are not
   * added (just ignored) by this function. @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t} will be returned if the given
   * xmlns is null.
   */
  int addPackageNamespaces(const XMLNamespaces* xmlns);


  /**
   * Removes an XML namespace of a package extension from the set of namespaces 
   * within this SBMLNamespaces object.
   *
   * @param level   the SBML level
   * @param version the SBML version
   * @param pkgName the string of package name (e.g. "layout", "multi")
   * @param pkgVersion the package version
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removePackageNamespace(unsigned int level, unsigned version, const std::string &pkgName,
                         unsigned int pkgVersion);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Add an XML namespace (a pair of URI and prefix) of a package extension
   * to the set of namespaces within this SBMLNamespaces object.
   * 
   * The SBML Level and SBML Version of this object is used.
   * 
   * @param pkgName the string of package name (e.g. "layout", "multi")
   * @param pkgVersion the package version
   * @param prefix the prefix of the package namespace to be added.
   *        The package's name will be used if the given string is empty (default).
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note An XML namespace of a non-registered package extension can't be
   * added by this function (@sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t} 
   * will be returned).
   *
   * @see addNamespace(@if java String, String@endif)
   */
  int addPkgNamespace(const std::string &pkgName, unsigned int pkgVersion, 
                      const std::string &prefix = "");


  /**
   * Add the XML namespaces of package extensions in the given XMLNamespace
   * object to the set of namespaces within this SBMLNamespaces object.
   * 
   * Non-package XML namespaces are not added by this function.
   * 
   * @param xmlns the XML namespaces to be added.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note XML namespaces of a non-registered package extensions are not
   * added (just ignored) by this function. @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t} will be returned if the given
   * xmlns is null.
   */
  int addPkgNamespaces(const XMLNamespaces* xmlns);


  /**
   * Removes an XML namespace of a package extension from the set of
   * namespaces within this SBMLNamespaces object.
   *
   * @param level   the SBML level
   * @param version the SBML version
   * @param pkgName the string of package name (e.g. "layout", "multi")
   * @param pkgVersion the package version
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
   */
  int removePkgNamespace(unsigned int level, unsigned version, const std::string &pkgName,
                         unsigned int pkgVersion);

  /** @endcond */

  /**
   * Predicate returning @c true if the given URL is one of SBML XML
   * namespaces.
   *
   * @param uri the URI of namespace
   *
   * @return @c true if the "uri" is one of SBML namespaces, @c false otherwise.
   *
   * @copydetails doc_note_static_methods
   */
  static bool isSBMLNamespace(const std::string& uri);


  /**
   * Predicate returning @c true if the given set of namespaces represent a
   * valid set
   *
   * @return @c true if the set of namespaces is valid, @c false otherwise.
   */
  bool isValidCombination();


  /** @cond doxygenLibsbmlInternal */
  void setLevel(unsigned int level);


  void setVersion(unsigned int version);


  void setNamespaces(XMLNamespaces * xmlns);
  /** @endcond */

  /**
   * Returns the name of the main package for this namespace.
   *
   * @return the name of the main package for this namespace.
   * "core" will be returned if this namespace is defined in the SBML 
   * core. 
   */
   virtual const std::string& getPackageName () const;	
	
protected:  
  /** @cond doxygenLibsbmlInternal */

  void initSBMLNamespace();

  unsigned int    mLevel;
  unsigned int    mVersion;
  XMLNamespaces * mNamespaces;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new SBMLNamespaces_t structure corresponding to the given SBML
 * @p level and @p version.
 *
 * SBMLNamespaces_t structures are used in libSBML to communicate SBML Level
 * and Version data between constructors and other methods.  The
 * SBMLNamespaces_t structure class tracks 3-tuples (triples) consisting of
 * SBML Level, Version, and the corresponding SBML XML namespace.  Most
 * constructors for SBML structures in libSBML take a SBMLNamespaces_t structure
 * as an argument, thereby allowing the constructor to produce the proper
 * combination of attributes and other internal data structures for the
 * given SBML Level and Version.
 *
 * The plural name "SBMLNamespaces" is not a mistake, because in SBML
 * Level&nbsp;3, structures may have extensions added by Level&nbsp;3
 * packages used by a given model; however, until the introduction of
 * SBML Level&nbsp;3, the SBMLNamespaces_t structure only records one SBML
 * Level/Version/namespace combination at a time.
 *
 * @param level the SBML level
 * @param version the SBML version
 *
 * @return SBMLNamespaces_t structure created
 *
 * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
SBMLNamespaces_t *
SBMLNamespaces_create(unsigned int level, unsigned int version);


/**
 * Destroys this SBMLNamespaces_t structure.
 *
 * @param ns SBMLNamespaces_t structure to be freed.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
void
SBMLNamespaces_free (SBMLNamespaces_t *ns);


/**
 * Get the SBML Level of this SBMLNamespaces_t structure.
 *
 * @param sbmlns the SBMLNamespaces_t structure to query
 *
 * @return the SBML Level of this SBMLNamespaces_t structure.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
unsigned int
SBMLNamespaces_getLevel(SBMLNamespaces_t *sbmlns);


/**
 * Get the SBML Version of this SBMLNamespaces_t structure.
 *
 * @param sbmlns the SBMLNamespaces_t structure to query
 *
 * @return the SBML Version of this SBMLNamespaces_t structure.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
unsigned int
SBMLNamespaces_getVersion(SBMLNamespaces_t *sbmlns);


/**
 * Get the SBML Version of this SBMLNamespaces_t structure.
 *
 * @param sbmlns the SBMLNamespaces_t structure to query
 *
 * @return the XMLNamespaces_t structure of this SBMLNamespaces_t structure.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
XMLNamespaces_t *
SBMLNamespaces_getNamespaces(SBMLNamespaces_t *sbmlns);


/**
 * Returns a string representing the SBML XML namespace for the 
 * given @p level and @p version of SBML.
 *
 * @param level the SBML level
 * @param version the SBML version
 *
 * @return a string representing the SBML namespace that reflects the
 * SBML Level and Version specified.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
char *
SBMLNamespaces_getSBMLNamespaceURI(unsigned int level, unsigned int version);


/**
 * Add the XML namespaces list to the set of namespaces
 * within this SBMLNamespaces_t structure.
 * 
 * @param sbmlns the SBMLNamespaces_t structure to add to
 * @param xmlns the XML namespaces to be added.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
int
SBMLNamespaces_addNamespaces(SBMLNamespaces_t *sbmlns,
                             const XMLNamespaces_t * xmlns);


/**
 * Returns an array of SBML Namespaces supported by this version of 
 * LibSBML. 
 *
 * @param length an integer holding the length of the array
 * @return an array of SBML namespaces, or @c NULL if length is @c NULL. The array 
 *         has to be freed by the caller.
 *
 * @memberof SBMLNamespaces_t
 */
LIBSBML_EXTERN
SBMLNamespaces_t **
SBMLNamespaces_getSupportedNamespaces(int *length);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLNamespaces_h */
