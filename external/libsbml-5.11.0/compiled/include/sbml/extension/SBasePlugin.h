/**
 * @file    SBasePlugin.h
 * @brief   Definition of SBasePlugin, the base class of extension entities
 *          plugged in SBase derived classes in the SBML Core package.
 * @author  Akiya Jouraku
 *
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
 * @class SBasePlugin
 * @sbmlbrief{core} Base class for extending SBML objects in packages.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBasePlugin class is libSBML's base class for extensions of core SBML
 * component objects.  SBasePlugin defines basic virtual methods for
 * reading/writing/checking additional attributes and/or subobjects; these
 * methods should be overridden by subclasses to implement the necessary
 * features of an extended SBML object.
 *
 * Perhaps the easiest way to explain and motivate the role of SBasePlugin is
 * through an example.  The SBML %Layout package specifies the existence of an
 * element, <code>&lt;listOfLayouts&gt;</code>, contained inside an SBML
 * <code>&lt;model&gt;</code> element.  In terms of libSBML components, this
 * means a new ListOfLayouts class of objects must be defined, and this
 * object placed in an @em extended class of Model (because Model in
 * plain/core SBML does not allow the inclusion of a ListOfLayouts
 * subobject).  This extended class of Model is LayoutModelPlugin, and it is
 * derived from SBasePlugin.
 *
 * @section sbaseplugin-howto How to extend SBasePlugin for a package implementation
 * @copydetails doc_extension_sbaseplugin
 */

#ifndef SBasePlugin_h
#define SBasePlugin_h


#include <sbml/common/sbmlfwd.h>
#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBase.h>
#include <sbml/SBMLDocument.h>

#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/ASTBasePlugin.h>


#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBasePlugin
{
public:

  /**
   * Destroy this SBasePlugin object.
   */
  virtual ~SBasePlugin ();


  /**
   * Assignment operator for SBasePlugin.
   *
   * @param orig The object whose values are used as the basis of the
   * assignment.
   */
  SBasePlugin& operator=(const SBasePlugin& orig);


  /**
   * Returns the namespace URI of the package to which this plugin object
   * belongs.
   *
   * @return the XML namespace URI of the SBML Level&nbsp;3 package
   * implemented by this libSBML package extension.
   */
  const std::string& getElementNamespace() const;


  /**
   * Returns the XML namespace prefix of the package to which this plugin
   * object belongs.
   *
   * @return the XML namespace prefix of the SBML Level&nbsp;3 package
   * implemented by this libSBML package extension.
   */
  const std::string& getPrefix() const;


  /**
   * Returns the short-form name of the package to which this plugin
   * object belongs.
   *
   * @return the short-form package name (or nickname) of the SBML package
   * implemented by this package extension.
   */
  const std::string& getPackageName() const;


  /**
   * Creates and returns a deep copy of this SBasePlugin object.
   *
   * @return the (deep) copy of this SBasePlugin object.
   */
  virtual SBasePlugin* clone () const = 0;


  /**
   * Return the first child object found with a given identifier.
   *
   * This method searches all the subobjects under this one, compares their
   * identifiers to @p id, and returns the first one that machines.
   * @if clike It uses SBasePlugin::getAllElements(ElementFilter* filter) to
   * get the list of identifiers, so the order in which identifiers are
   * searched is the order in which they appear in the results returned by
   * that method.@endif@~
   *
   * Normally, <code>SId</code> type identifier values are unique across
   * a model in SBML.  However, in some circumstances they may not be, such
   * as if a model is invalid because of multiple objects having the same
   * identifier.
   *
   * @param id string representing the identifier of the object to find
   *
   * @return pointer to the first object with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);


  /**
   * Return the first child object found with a given meta identifier.
   *
   * This method searches all the subobjects under this one, compares their
   * meta identifiers to @p metaid, and returns the first one that machines.
   *
   * @param metaid string, the metaid of the object to find.
   *
   * @return pointer to the first object found with the given @p metaid.
   */
  virtual SBase* getElementByMetaId(const std::string& metaid);


  /**
   * Returns all child objects of this object.
   *
   * This returns a List object containing all child SBase objects of this
   * one, at any nesting depth.  Optionally, callers can supply a filter
   * that will establish the search criteria for matching objects.
   *
   * @param filter an ElementFilter to use for determining the properties
   * of the objects to be returned.
   *
   * @return a List of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);


  // --------------------------------------------------------
  //
  // virtual functions for reading/writing/checking elements
  //
  // --------------------------------------------------------

#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */
  /**
   * Takes the contents of the passed-in Model, makes copies of everything,
   * and appends those copies to the appropriate places in this Model.  Only
   * called from Model::appendFrom, and is intended to be extended for
   * packages that add new things to the Model object.
   *
   * @param The Model to merge with this one.
   *
   */
  virtual int appendFrom(const Model* model);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses must override this method to create, store, and then
   * return an SBML object corresponding to the next XMLToken in the
   * XMLInputStream if they have their specific elements.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to read (and store) XHTML,
   * MathML, etc. directly from the XMLInputStream if the target elements
   * can't be parsed by SBase::readAnnotation(XMLInputStream& stream)
   * and/or SBase::readNotes(XMLInputStream& stream) functions.
   *
   * @return true if the subclass read from the stream, false otherwise.
   */
  virtual bool readOtherXML (SBase* parentObject, XMLInputStream& stream);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Synchronizes the annotation of this SBML object.
   *
   * Annotation element (XMLNode* mAnnotation) is synchronized with the
   * current CVTerm objects (List* mCVTerm).
   * Currently, this method is called in getAnnotation, isSetAnnotation,
   * and writeElements methods.
   */
  virtual void syncAnnotation(SBase* parentObject, XMLNode *annotation);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Parse L2 annotation if supported
   *
   */
  virtual void parseAnnotation(SBase *parentObject, XMLNode *annotation);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses must override this method to write out their contained
   * SBML objects as XML elements if they have their specific elements.
   */
  virtual void writeElements (XMLOutputStream& stream) const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Checks if this plugin object has all the required elements.
   *
   * Subclasses should override this function if they have their specific
   * elements.
   *
   * @return true if this plugin object has all the required elements,
   * otherwise false will be returned.
   */
  virtual bool hasRequiredElements() const ;

  /** @endcond */


  // ----------------------------------------------------------
  //
  // virtual functions for reading/writing/checking attributes
  //
  // ----------------------------------------------------------


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to get the list of
   * expected attributes if they have their specific attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses must override this method to read values from the given
   * XMLAttributes if they have their specific attributes.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses must override this method to write their XML attributes
   * to the XMLOutputStream if they have their specific attributes.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /*
   * Checks if this plugin object has all the required attributes .
   *
   * Subclasses should override this function if if they have their specific
   * attributes.
   *
   * @return true if this plugin object has all the required attributes,
   * otherwise false will be returned.
   */
  virtual bool hasRequiredAttributes() const ;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write required xmlns attributes
   * to the XMLOutputStream (if any).
   * The xmlns attribute will be written in the element to which the object
   * is connected. For example, xmlns attributes written by this function will
   * be added to Model element if this plugin object connected to the Model
   * element.
   */
  virtual void writeXMLNS (XMLOutputStream& stream) const;
  /** @endcond */

#endif // SWIG


  // ---------------------------------------------------------
  //
  // virtual functions (internal implementation) which should
  // be overridden by subclasses.
  //
  // ---------------------------------------------------------

  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the parent SBMLDocument of this plugin object.
   *
   * Subclasses which contain one or more SBase derived elements must
   * override this function.
   *
   * @param d the SBMLDocument object to use
   *
   * @see connectToParent()
   * @see enablePackageInternal()
   */
  virtual void setSBMLDocument (SBMLDocument* d);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the parent SBML object of this plugin object to
   * this object and child elements (if any).
   * (Creates a child-parent relationship by this plugin object)
   *
   * This function is called when this object is created by
   * the parent element.
   * Subclasses must override this this function if they have one
   * or more child elements. Also, SBasePlugin::connectToParent(@if java SBase@endif)
   * must be called in the overridden function.
   *
   * @param sbase the SBase object to use
   *
   * @if cpp
   * @see setSBMLDocument()
   * @see enablePackageInternal()
   * @endif
   */
  virtual void connectToParent (SBase *sbase);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Enables/Disables the given package with child elements in this plugin
   * object (if any).
   * (This is an internal implementation invoked from
   *  SBase::enablePackageInternal() function)
   *
   * Subclasses which contain one or more SBase derived elements should
   * override this function if elements defined in them can be extended by
   * some other package extension.
   *
   * @if cpp
   * @see setSBMLDocument()
   * @see connectToParent()
   * @endif
   */
  virtual void enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  virtual bool stripPackage(const std::string& pkgPrefix, bool flag);
  /** @endcond */


  // ----------------------------------------------------------


  /**
   * Returns the SBMLDocument object containing this object instance.
   *
   * @copydetails doc_what_is_SBMLDocument
   *
   * This method allows the caller to obtain the SBMLDocument for the
   * current object.
   *
   * @return the parent SBMLDocument object of this plugin object.
   *
   * @see getParentSBMLObject()
   */
  SBMLDocument* getSBMLDocument ();


  /**
   * Returns the SBMLDocument object containing this object instance.
   *
   * @copydetails doc_what_is_SBMLDocument
   *
   * This method allows the caller to obtain the SBMLDocument for the
   * current object.
   *
   * @return the parent SBMLDocument object of this plugin object.
   *
   * @see getParentSBMLObject()
   */
  const SBMLDocument* getSBMLDocument () const;


  /**
   * Returns the XML namespace URI for the package to which this object belongs.
   *
   * @copydetails doc_what_are_xmlnamespaces
   *
   * This method first looks into the SBMLNamespaces object possessed by the
   * parent SBMLDocument object of the current object.  If this cannot be
   * found, this method returns the result of getElementNamespace().
   *
   * @return a string, the URI of the XML namespace to which this object belongs.
   *
   * @see getPackageName()
   * @see getElementNamespace()
   * @see SBMLDocument::getSBMLNamespaces()
   * @see getSBMLDocument()
   */
  std::string getURI() const;


  /**
   * Returns the parent object to which this plugin object is connected.
   *
   * @return the parent object of this object.
   */
  SBase* getParentSBMLObject ();


  /**
   * Returns the parent object to which this plugin object is connected.
   *
   * @return the parent object of this object.
   */
  const SBase* getParentSBMLObject () const;


  /**
   * Sets the XML namespace to which this object belongs.
   *
   * @copydetails doc_what_are_xmlnamespaces
   *
   * @param uri the URI to assign to this object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see getElementNamespace()
   */
  int setElementNamespace(const std::string &uri);


  /**
   * Returns the SBML Level of the package extension of this plugin object.
   *
   * @return the SBML Level.
   *
   * @see getVersion()
   */
  unsigned int getLevel() const;


  /**
   * Returns the Version within the SBML Level of the package extension of
   * this plugin object.
   *
   * @return the SBML Version.
   *
   * @see getLevel()
   */
  unsigned int getVersion() const;


  /**
   * Returns the package version of the package extension of this plugin
   * object.
   *
   * @return the package version of the package extension of this plugin
   * object.
   *
   * @see getLevel()
   * @see getVersion()
   */
  unsigned int getPackageVersion() const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * If this object has a child 'math' object (or anything with ASTNodes in
   * general), replace all nodes with the name 'id' with the provided
   * function.
   *
   * @note This function does nothing itself--subclasses with ASTNode subelements must override this function.
   */
  virtual void replaceSIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * If the function of this object is to assign a value has a child 'math'
   * object (or anything with ASTNodes in general), replace the 'math' object
   * with the function (existing/function).
   *
   * @note This function does nothing itself--subclasses with ASTNode subelements must override this function.
   */
  virtual void divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * If this assignment assigns a value to the 'id' element, replace the
   * 'math' object with the function (existing*function).
   */
  virtual void multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Check to see if the given prefix is used by any of the IDs defined by
   * extension elements.  A package that defines its own 'id' attribute for a
   * core element would check that attribute here.
   */
  virtual bool hasIdentifierBeginningWith(const std::string& prefix);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Add the given string to all identifiers in the object.  If the string is
   * added to anything other than an id or a metaid, this code is responsible
   * for tracking down and renaming all *idRefs in the package extention that
   * identifier comes from.
   */
  virtual int prependStringToAllIdentifiers(const std::string& prefix);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  virtual int transformIdentifiers(IdentifierTransformer* sidTransformer);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Returns the line number on which this object first appears in the XML
   * representation of the SBML document.
   *
   * @return the line number of the underlying SBML object.
   *
   * @note The line number for each construct in an SBML model is set upon
   * reading the model.  The accuracy of the line number depends on the
   * correctness of the XML representation of the model, and on the
   * particular XML parser library being used.  The former limitation
   * relates to the following problem: if the model is actually invalid
   * XML, then the parser may not be able to interpret the data correctly
   * and consequently may not be able to establish the real line number.
   * The latter limitation is simply that different parsers seem to have
   * their own accuracy limitations, and out of all the parsers supported
   * by libSBML, none have been 100% accurate in all situations. (At this
   * time, libSBML supports the use of <a target="_blank"
   * href="http://xmlsoft.org">libxml2</a>, <a target="_blank"
   * href="http://expat.sourceforge.net/">Expat</a> and <a target="_blank"
   * href="http://xerces.apache.org/xerces-c/">Xerces</a>.)
   *
   * @see getColumn()
   */
  unsigned int getLine() const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Returns the column number on which this object first appears in the XML
   * representation of the SBML document.
   *
   * @return the column number of the underlying SBML object.
   *
   * @note The column number for each construct in an SBML model is set
   * upon reading the model.  The accuracy of the column number depends on
   * the correctness of the XML representation of the model, and on the
   * particular XML parser library being used.  The former limitation
   * relates to the following problem: if the model is actually invalid
   * XML, then the parser may not be able to interpret the data correctly
   * and consequently may not be able to establish the real column number.
   * The latter limitation is simply that different parsers seem to have
   * their own accuracy limitations, and out of all the parsers supported
   * by libSBML, none have been 100% accurate in all situations. (At this
   * time, libSBML supports the use of <a target="_blank"
   * href="http://xmlsoft.org">libxml2</a>, <a target="_blank"
   * href="http://expat.sourceforge.net/">Expat</a> and <a target="_blank"
   * href="http://xerces.apache.org/xerces-c/">Xerces</a>.)
   *
   * @see getLine()
   */
  unsigned int getColumn() const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /* gets the SBMLnamespaces - internal use only*/
  virtual SBMLNamespaces * getSBMLNamespaces() const;
  /** @endcond */


  // -----------------------------------------------
  //
  // virtual functions for elements
  //
  // ------------------------------------------------

  /** @cond doxygenLibsbmlInternal */
  /**
   * Helper to log a common type of error for elements.
   */
  virtual void logUnknownElement(const std::string &element,
                                 const unsigned int sbmlLevel,
 			         const unsigned int sbmlVersion,
			         const unsigned int pkgVersion );
  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */
  /**
   * Constructor. Creates an SBasePlugin object with the URI and
   * prefix of an package extension.
   */
  SBasePlugin (const std::string &uri, const std::string &prefix,
               SBMLNamespaces *sbmlns);


  /**
   * Copy constructor. Creates a copy of this SBase object.
   */
  SBasePlugin(const SBasePlugin& orig);


  /**
   * Returns the SBMLErrorLog used to log errors while reading and
   * validating SBML.
   *
   * @return the SBMLErrorLog used to log errors while reading and
   * validating SBML.
   */
  SBMLErrorLog* getErrorLog ();


  //// -----------------------------------------------
  ////
  //// virtual functions for elements
  ////
  //// ------------------------------------------------

  ///**
  // * Helper to log a common type of error for elements.
  // */
  //virtual void logUnknownElement(const std::string &element,
  //                               const unsigned int sbmlLevel,
  //                               const unsigned int sbmlVersion,
  //                               const unsigned int pkgVersion );

  // -----------------------------------------------
  //
  // virtual functions for attributes
  //
  // ------------------------------------------------

  /**
   * Helper to log a common type of error.
   */
  virtual void logUnknownAttribute(const std::string &attribute,
                                   const unsigned int sbmlLevel,
                                   const unsigned int sbmlVersion,
                                   const unsigned int pkgVersion,
                                   const std::string& element);


  /**
   * Helper to log a common type of error.
   */
  virtual void logEmptyString(const std::string &attribute,
                              const unsigned int sbmlLevel,
                              const unsigned int sbmlVersion,
                              const unsigned int pkgVersion,
                              const std::string& element);


  /*-- data members --*/

  //
  // An SBMLExtension derived object of corresponding package extension
  // The owner of this object is SBMLExtensionRegistry class.
  //
  const SBMLExtension  *mSBMLExt;

  //
  // Parent SBMLDocument object of this plugin object.
  //
  SBMLDocument         *mSBML;

  //
  // Parent SBase derived object to which this plugin object
  // connected.
  //
  SBase                *mParent;

  //
  // XML namespace of corresponding package extension
  //
  std::string          mURI;

  //
  // SBMLNamespaces derived object of this plugin object.
  //
  SBMLNamespaces      *mSBMLNS;

  //
  // Prefix of corresponding package extension
  //
  std::string          mPrefix;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Returns the XML namespace (URI) of the package extension
 * of the given plugin structure.
 *
 * @param plugin the plugin structure
 *
 * @return the URI of the package extension of this plugin structure, or NULL
 * in case an invalid plugin structure is provided.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
const char*
SBasePlugin_getURI(SBasePlugin_t* plugin);

/**
 * Returns the prefix of the given plugin structure.
 *
 * @param plugin the plugin structure
 *
 * @return the prefix of the given plugin structure, or NULL
 * in case an invalid plugin structure is provided.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
const char*
SBasePlugin_getPrefix(SBasePlugin_t* plugin);

/**
 * Returns the package name of the given plugin structure.
 *
 * @param plugin the plugin structure
 *
 * @return the package name of the given plugin structure, or NULL
 * in case an invalid plugin structure is provided.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
const char*
SBasePlugin_getPackageName(SBasePlugin_t* plugin);

/**
 * Creates a deep copy of the given SBasePlugin_t structure
 *
 * @param plugin the SBasePlugin_t structure to be copied
 *
 * @return a (deep) copy of the given SBasePlugin_t structure.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBasePlugin_t*
SBasePlugin_clone(SBasePlugin_t* plugin);

/**
 * Frees the given SBasePlugin_t structure
 *
 * @param plugin the SBasePlugin_t structure to be freed
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_free(SBasePlugin_t* plugin);

/**
 * Subclasses must override this method to create, store, and then
 * return an SBML structure corresponding to the next XMLToken in the
 * XMLInputStream_t if they have their specific elements.
 *
 * @param plugin the SBasePlugin_t structure
 * @param stream the XMLInputStream_t structure to read from
 *
 * @return the SBML structure corresponding to next XMLToken in the
 * XMLInputStream_t or NULL if the token was not recognized or plugin or stream
 * were NULL.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBase_t*
SBasePlugin_createObject(SBasePlugin_t* plugin, XMLInputStream_t* stream);

/**
 * Subclasses should override this method to read (and store) XHTML,
 * MathML, etc. directly from the XMLInputStream_t if the target elements
 * can't be parsed by SBase::readAnnotation() and/or SBase::readNotes()
 * functions
 *
 * @param plugin the SBasePlugin_t structure
 * @param parentObject the SBase_t structure that will store the annotation.
 * @param stream the XMLInputStream_t structure to read from
 *
 * @return true (1) if the subclass read from the stream, false (0) otherwise.
 * If an invalid plugin or stream was provided LIBSBML_INVALID_OBJECT is returned.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_readOtherXML(SBasePlugin_t* plugin, SBase_t* parentObject, XMLInputStream_t* stream);

/**
 * Subclasses must override this method to write out their contained
 * SBML structures as XML elements if they have their specific elements.
 *
 * @param plugin the SBasePlugin_t structure
 * @param stream the XMLOutputStream_t structure to write to
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_writeElements(SBasePlugin_t* plugin, XMLInputStream_t* stream);

/**
 * Checks if the plugin structure has all the required elements.
 *
 * Subclasses should override this function if they have their specific
 * elements.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return true (1) if this plugin structure has all the required elements,
 * otherwise false (0) will be returned. If an invalid plugin
 * was provided LIBSBML_INVALID_OBJECT is returned.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_hasRequiredElements(SBasePlugin_t* plugin);

/**
 * Subclasses should override this method to get the list of
 * expected attributes if they have their specific attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 *
 * @param plugin the SBasePlugin_t structure
 * @param attributes the ExpectedAttributes_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_addExpectedAttributes(SBasePlugin_t* plugin,
        ExpectedAttributes_t* attributes);

/**
 * Subclasses must override this method to read values from the given
 * XMLAttributes_t if they have their specific attributes.
 *
 * @param plugin the SBasePlugin_t structure
 * @param attributes the XMLAttributes_t structure
 * @param expectedAttributes the ExpectedAttributes_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_readAttributes(SBasePlugin_t* plugin,
        XMLAttributes_t* attributes,
        ExpectedAttributes_t* expectedAttributes);

/**
 * Subclasses must override this method to write their XML attributes
 * to the XMLOutputStream_t if they have their specific attributes.
 *
 * @param plugin the SBasePlugin_t structure
 * @param stream the XMLOutputStream_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_writeAttributes(SBasePlugin_t* plugin,
        XMLOutputStream_t* stream);

/**
 * Checks if the plugin structure has all the required attributes.
 *
 * Subclasses should override this function if they have their specific
 * attributes.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return true (1) if this plugin structure has all the required attributes,
 * otherwise false (0) will be returned. If an invalid plugin
 * was provided LIBSBML_INVALID_OBJECT is returned.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_hasRequiredAttributes(SBasePlugin_t* plugin);

/**
 * Subclasses should override this method to write required xmlns attributes
 * to the XMLOutputStream_t (if any).
 * The xmlns attribute will be written in the element to which the structure
 * is connected. For example, xmlns attributes written by this function will
 * be added to Model_t element if this plugin structure connected to the Model_t
 * element.
 *
 * @param plugin the SBasePlugin_t structure
 * @param stream the XMLOutputStream_t structure
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_writeXMLNS(SBasePlugin_t* plugin, XMLOutputStream_t* stream);

/**
 * Sets the parent SBMLDocument of th plugin structure.
 *
 * Subclasses which contain one or more SBase derived elements must
 * override this function.
 *
 * @param plugin the SBasePlugin_t structure
 * @param d the SBMLDocument_t structure to use
 *
 * @see SBasePlugin_connectToParent
 * @see SBasePlugin_enablePackageInternal
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_setSBMLDocument(SBasePlugin_t* plugin, SBMLDocument_t* d);

/**
 * Sets the parent SBML structure of this plugin structure to
 * this structure and child elements (if any).
 * (Creates a child-parent relationship by this plugin structure)
 *
 * This function is called when this structure is created by
 * the parent element.
 * Subclasses must override this this function if they have one
 * or more child elements. Also, SBasePlugin::connectToParent()
 * must be called in the overridden function.
 *
 * @param plugin the SBasePlugin_t structure
 * @param sbase the SBase_t structure to use
 *
 * @see SBasePlugin_setSBMLDocument
 * @see SBasePlugin_enablePackageInternal
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_connectToParent(SBasePlugin_t* plugin, SBase_t* sbase);

/**
 * Enables/Disables the given package with child elements in this plugin
 * structure (if any).
 * (This is an internal implementation invoked from
 *  SBase::enablePackageInternal() function)
 *
 * Subclasses which contain one or more SBase derived elements should
 * override this function if elements defined in them can be extended by
 * some other package extension.
 *
 * @param plugin the SBasePlugin_t structure
 * @param pkgURI the package uri
 * @param pkgPrefix the package prefix
 * @param flag indicating whether the package should be enabled (1) or disabled(0)
 *
 * @see SBasePlugin_setSBMLDocument
 * @see SBasePlugin_connectToParent
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
int
SBasePlugin_enablePackageInternal(SBasePlugin_t* plugin,
        const char* pkgURI, const char* pkgPrefix, int flag);

/**
 * Returns the parent SBMLDocument of this plugin structure.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return the parent SBMLDocument_t structure of this plugin structure or NULL if
 * no document is set, or the plugin structure is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBMLDocument_t*
SBasePlugin_getSBMLDocument(SBasePlugin_t* plugin);

/**
 * Returns the parent SBase_t structure to which this plugin structure is connected.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return the parent SBase_t structure to which this plugin structure is connected
 * or NULL if sbase structure is set, or the plugin structure is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
SBase_t*
SBasePlugin_getParentSBMLObject(SBasePlugin_t* plugin);

/**
 * Returns the SBML level of the package extension of
 * this plugin structure.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return the SBML level of the package extension of
 * this plugin structure or SBML_INT_MAX if the structure is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
unsigned int
SBasePlugin_getLevel(SBasePlugin_t* plugin);

/**
 * Returns the SBML version of the package extension of
 * this plugin structure.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return the SBML version of the package extension of
 * this plugin structure or SBML_INT_MAX if the structure is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
unsigned int
SBasePlugin_getVersion(SBasePlugin_t* plugin);

/**
 * Returns the package version of the package extension of
 * this plugin structure.
 *
 * @param plugin the SBasePlugin_t structure
 *
 * @return the package version of the package extension of
 * this plugin structure or SBML_INT_MAX if the structure is invalid.
 *
 * @memberof SBasePlugin_t
 */
LIBSBML_EXTERN
unsigned int
SBasePlugin_getPackageVersion(SBasePlugin_t* plugin);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* SBasePlugin_h */
