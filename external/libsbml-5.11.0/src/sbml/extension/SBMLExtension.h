/**
 * @file    SBMLExtension.h
 * @brief   Definition of SBMLExtension, the core component of SBML package extension.
 * @author  Akiya Jouraku
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
 * @class SBMLExtension
 * @sbmlbrief{core} Base class for SBML Level 3 package plug-ins.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBMLExtension class is a component of the libSBML package extension
 * mechanism.  It is an abstract class that is extended by each package
 * extension implementation. @if clike The SBMLExtension class provides
 * methods for managing common attributes of package extensions (e.g.,
 * package name, package version), registration of instantiated
 * SBasePluginCreator objects, and initialization/registration of package
 * extensions when the library code for the package is loaded. @endif@~
 *
 * @if clike
 * @section sbmlextension-howto How to extend SBMLExtension for a package implementation
 * @copydetails doc_extension_sbmlextension
 * @endif@~
 *
 * @section sbmlextension-l2-special Special handling for SBML Level&nbsp;2
 * @copydetails doc_extension_layout_plugin_is_special
 */
/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_virtual_method_for_l2namespaces
 *
 * @par
 * This method is related to special facilities designed to support
 * legacy behaviors surrounding SBML Level&nbsp;2 models.  Due to the
 * historical background of the SBML %Layout package, libSBML implements
 * special behavior for that package: it @em always creates a %Layout
 * plugin object for any SBML Level&nbsp;2 document it reads in,
 * regardless of whether that document actually uses %Layout constructs.
 * Since Level&nbsp;2 does not use namespaces on the top level of the
 * SBML document object, libSBML simply keys off the fact that the model
 * is a Level&nbsp;2 model.  To allow the extensions for the %Layout and
 * %Render (and possibly other) packages to support this behavior, the
 * SBMLExtension class contains special methods to allow packages to
 * hook themselves into the Level&nbsp;2 parsing apparatus when necessary.
 *
 * @if clike
 * This virtual method should be overridden by all package extensions
 * that want to serialize to an SBML Level&nbsp;2 annotation.  In
 * Level&nbsp;2, the XML namespace declaration for the package is not
 * placed on the top-level SBML document object but rather inside
 * individual annotations.  addL2Namespaces() is invoked automatically
 * for Level&nbsp;2 documents when an SBMLExtensionNamespace object is
 * created; removeL2Namespaces() is automatically invoked by
 * SBMLDocument to prevent the namespace(s) from being put on the
 * top-level SBML Level&nbsp;2 element (because Level&nbsp;2 doesn't
 * support namespaces there); and enableL2NamespaceForDocument() is
 * called automatically when any SBML document (of any Level/Version) is
 * read in.
 * @endif@~
 */

#ifndef SBMLExtension_h
#define SBMLExtension_h


#ifndef EXTENSION_CREATE_NS
#define EXTENSION_CREATE_NS(type,variable,sbmlns)\
  type* variable;\
  {\
      XMLNamespaces* xmlns = sbmlns->getNamespaces();\
      variable = dynamic_cast<type*>(sbmlns);\
      if (variable == NULL)\
      {\
       variable = new type(sbmlns->getLevel(), sbmlns->getVersion());\
       for (int i = 0; i < xmlns->getNumNamespaces(); i++)\
       {\
         if (!variable->getNamespaces()->hasURI(xmlns->getURI(i)))\
           variable->getNamespaces()->add(xmlns->getURI(i), xmlns->getPrefix(i));\
       }\
      }\
      else { variable = new type(*variable); }\
  }
#endif

#include <sbml/common/libsbml-config-common.h>

#include <sbml/extension/SBasePluginCreatorBase.h>
#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/extension/ASTBasePlugin.h>

  /** @cond doxygenLibsbmlInternal */
#ifndef SWIG
typedef struct {
  const char * ref_l3v1;
} packageReferenceEntry;


typedef struct {
  unsigned int code;
  const char*  shortMessage;
  unsigned int category;
  unsigned int l3v1_severity;
  const char*  message;
  packageReferenceEntry reference;
} packageErrorTableEntry;

#endif
  /** @endcond */

#ifdef __cplusplus

#include <vector>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBMLExtension
{
public:

/** @cond doxygenLibsbmlInternal */
  typedef std::vector<std::string>           SupportedPackageURIList;
  typedef std::vector<std::string>::iterator SupportedPackageURIListIter;
/** @endcond */

  /**
   * Constructor.
   */
  SBMLExtension ();


  /**
   * Copy constructor.
   *
   * This creates a copy of an SBMLExtension object.
   *
   * @param orig The SBMLExtension object to copy.
   */
  SBMLExtension(const SBMLExtension& orig);


  /**
   * Destroy this SBMLExtension object.
   */
  virtual ~SBMLExtension ();


  /**
   * Assignment operator for SBMLExtension.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   */
  SBMLExtension& operator=(const SBMLExtension& rhs);


#ifndef SWIG
  /**
   * Adds a SBasePluginCreatorBase object to this package extension.
   *
   * @copydetails doc_sbaseplugincreator_objects
   *
   * @param sbaseExt the SBasePluginCreatorBase object to add
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int addSBasePluginCreator(const SBasePluginCreatorBase* sbaseExt);


  /**
   * Returns an SBasePluginCreatorBase object for a given extension point.
   *
   * @copydetails doc_sbaseplugincreator_objects
   *
   * @param extPoint the SBaseExtensionPoint to which the returned
   * SBasePluginCreatorBase object is supposed to be bound.
   *
   * @return an SBasePluginCreatorBase object of this package extension
   * bound to the given extension point, or @c NULL if none is found.
   */
  SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint);


  /**
   * Returns an SBasePluginCreatorBase object for a given extension point.
   *
   * @copydetails doc_sbaseplugincreator_objects
   *
   * @param extPoint the SBaseExtensionPoint to which the returned
   * SBasePluginCreatorBase object is supposed to be bound.
   *
   * @return an SBasePluginCreatorBase object of this package extension
   * bound to the given extension point, or @c NULL if none is found.
   */
  const SBasePluginCreatorBase* getSBasePluginCreator(const SBaseExtensionPoint& extPoint) const;


  /**
   * Returns the nth SBasePluginCreatorBase object of this package extension.
   *
   * @param n the index of the SBasePluginCreatorBase object being sought.
   *
   * @return the SBasePluginCreatorBase object of this package extension
   * with the given index @p n, or @c NULL if none such exists.
   *
   * @see getNumOfSBasePlugins()
   */
  SBasePluginCreatorBase* getSBasePluginCreator(unsigned int n);


  /**
   * Returns the nth SBasePluginCreatorBase object of this package extension.
   *
   * @param n the index of the SBasePluginCreatorBase object being sought.
   *
   * @return the SBasePluginCreatorBase object of this package extension
   * with the given index @p n, or @c NULL if none such exists.
   *
   * @see getNumOfSBasePlugins()
   */
  const SBasePluginCreatorBase*  getSBasePluginCreator(unsigned int n) const;


#ifndef LIBSBML_USE_LEGACY_MATH
  /**
   * Adds the given ASTBasePlugin object to this package
   * extension.
   *
   * @param astPlugin the ASTBasePlugin object
   * of this package extension.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setASTBasePlugin(const ASTBasePlugin* astPlugin);


  /**
   * Returns an ASTBasePlugin of this package extension.
   *
   * @return an ASTBasePlugin of this package extension.
   */
  const ASTBasePlugin* getASTBasePlugin() const;


  /**
   * Returns an ASTBasePlugin of this package extension.
   *
   * @return an ASTBasePlugin of this package extension.
   */
  ASTBasePlugin* getASTBasePlugin();



  /**
  * Predicate returning @c true if this package extension has
  * an ASTBasePlugin attribute set.
  *
  * @return @c true if the ASTBasePlugin of
  * this package extension is set, @c false otherwise.
  */
  bool isSetASTBasePlugin() const;


#endif /* LIBSBML_USE_LEGACY_MATH */

#endif // SWIG

  /**
   * Returns the number of SBasePluginCreatorBase objects stored in this
   * object.
   *
   * @return the total number of SBasePluginCreatorBase objects stored in
   * this SBMLExtension-derived object.
   */
  int getNumOfSBasePlugins() const;


  /**
   * Returns the number of supported package namespace URIs.
   *
   * @return the number of supported package XML namespace URIs of this
   * package extension.
   */
  unsigned int getNumOfSupportedPackageURI() const;


  /**
   * Returns @c true if the given XML namespace URI is supported by this
   * package extension.
   *
   * @return @c true if the given XML namespace URI (equivalent to a package
   * version) is supported by this package extension, @c false otherwise.
   */
  bool isSupported(const std::string& uri) const;


  /**
   * Returns the nth XML namespace URI.
   *
   * @param n the index number of the namespace URI being sought.

   * @return a string representing the XML namespace URI understood to be
   * supported by this package.  An empty string will be returned if there is
   * no nth URI.
   */
  const std::string& getSupportedPackageURI(unsigned int n) const;


  /**
   * Creates and returns a deep copy of this SBMLExtension object.
   *
   * @return a (deep) copy of this SBMLExtension object.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual SBMLExtension* clone () const = 0;


  /**
   * Returns the nickname of this package.
   *
   * This returns the short-form name of an SBML Level&nbsp;3 package
   * implemented by a given SBMLExtension-derived class.  Examples of
   * such names are "layout", "fbc", etc.
   *
   * @return a string, the nickname of SBML package.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual const std::string& getName() const = 0;


  /**
   * Returns the XML namespace URI for a given Level and Version.
   *
   * @param sbmlLevel the SBML Level.
   * @param sbmlVersion the SBML Version.
   * @param pkgVersion the version of the package.
   *
   * @return a string, the XML namespace URI for the package for the given
   * SBML Level, SBML Version, and package version.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual const std::string& getURI(unsigned int sbmlLevel,
                                    unsigned int sbmlVersion,
                                    unsigned int pkgVersion) const = 0;


  /**
   * Returns the SBML Level associated with the given XML namespace URI.
   *
   * @param uri the string of URI that represents a version of the package.
   *
   * @return the SBML Level associated with the given URI of this package.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual unsigned int getLevel(const std::string &uri) const = 0;


  /**
   * Returns the SBML Version associated with the given XML namespace URI.
   *
   * @param uri the string of URI that represents a version of the package.
   *
   * @return the SBML Version associated with the given URI of this package.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual unsigned int getVersion(const std::string &uri) const = 0;


  /**
   * Returns the package version associated with the given XML namespace URI.
   *
   * @param uri the string of URI that represents a version of this package.
   *
   * @return the package version associated with the given URI of this package.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual unsigned int getPackageVersion(const std::string &uri) const = 0;


  /**
   * Returns a string representation of a type code.
   *
   * This method takes a numerical type code @p typeCode for a component
   * object implemented by this package extension, and returns a string
   * representing that type code.
   *
   * @param typeCode the type code to turn into a string.
   *
   * @return the string representation of @p typeCode.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual const char* getStringFromTypeCode(int typeCode) const = 0;


  /**
   * Returns a specialized SBMLNamespaces object corresponding to a given
   * namespace URI.
   *
   * LibSBML package extensions each define a subclass of
   * @if clike SBMLExtensionNamespaces @else SBMLNamespaces@endif@~.
   * @if clike This object has the form
   * @verbatim
SBMLExtensionNamespaces<class SBMLExtensionType>
@endverbatim
   * For example, this kind of object for the Layout package is
   * @verbatim
SBMLExtensionNamespaces<LayoutExtension>
@endverbatim
@endif@~
   * The present method returns the appropriate object corresponding
   * to the given XML namespace URI in argument @p uri.
   *
   * @param uri the namespace URI that represents one of versions of the
   * package implemented in this extension.
   *
   * @return an @if clike SBMLExtensionNamespaces @else SBMLNamespaces @endif@~ 
   * object, or @c NULL if the given @p uri is not defined in the
   * corresponding package.
   *
   * @copydetails doc_note_override_in_extensions
   */
  virtual SBMLNamespaces* getSBMLExtensionNamespaces(const std::string &uri) const = 0;


  /**
   * Enable or disable this package.
   *
   * @param isEnabled flag indicating whether to enable (if @c true) or
   * disable (@c false) this package extension.
   *
   * @return @c true if this call succeeded; @c false otherwise.
   */
  bool setEnabled(bool isEnabled);


  /**
   * Returns @c true if this package is enabled.
   *
   * @return @c true if this package is enabled, @c false otherwise.
   */
  bool isEnabled() const;


  /**
   * Removes the package's Level&nbsp;2 namespace(s).
   *
   * @copydetails doc_virtual_method_for_l2namespaces
   *
   * @param xmlns an XMLNamespaces object that will be used for the annotation.
   * Implementations should override this method with something that removes
   * the package's namespace(s) from the set of namespaces in @p xmlns.  For
   * instance, here is the code from the %Layout package extension:
   * @code{.cpp}
for (int n = 0; n < xmlns->getNumNamespaces(); n++)
{
  if (xmlns->getURI(n) == LayoutExtension::getXmlnsL2())
    xmlns->remove(n);
}
@endcode
   */
  virtual void removeL2Namespaces(XMLNamespaces* xmlns)  const;


  /**
   * Adds the package's Level&nbsp;2 namespace(s).
   *
   * @copydetails doc_virtual_method_for_l2namespaces
   *
   * @param xmlns an XMLNamespaces object that will be used for the annotation.
   * Implementation should override this method with something that adds
   * the package's namespace(s) to the set of namespaces in @p xmlns.  For
   * instance, here is the code from the %Layout package extension:
   * @code{.cpp}
if (!xmlns->containsUri( LayoutExtension::getXmlnsL2()))
  xmlns->add(LayoutExtension::getXmlnsL2(), "layout");
@endcode
   */
  virtual void addL2Namespaces(XMLNamespaces *xmlns) const;


  /**
   * Called to enable the package on the SBMLDocument object.
   *
   * @copydetails doc_virtual_method_for_l2namespaces
   *
   * @param doc the SBMLDocument object for the model.
   * Implementations should override this method with something that
   * enables the package based on the package's namespace(s). For example,
   * here is the code from the %Layout package extension:
   * @code{.cpp}
if (doc->getLevel() == 2)
  doc->enablePackage(LayoutExtension::getXmlnsL2(), "layout", true);
@endcode
   */
  virtual void enableL2NamespaceForDocument(SBMLDocument* doc)  const;


  /**
   * Indicates whether this extension is being used by the given SBMLDocument.
   *
   * The default implementation returns @c true.  This means that when a
   * document had this extension enabled, it will not be possible to convert
   * it to SBML Level&nbsp;2 as we cannot make sure that the extension can be
   * converted.
   *
   * @param doc the SBML document to test.
   *
   * @return a boolean indicating whether the extension is actually being
   * used by the document.
   */
  virtual bool isInUse(SBMLDocument *doc) const;


  /** @cond doxygenLibsbmlInternal */
  /*
   * functions for use with error logging
   */
  virtual unsigned int getErrorTableIndex(unsigned int errorId) const;

#ifndef SWIG
  virtual packageErrorTableEntry getErrorTable(unsigned int index) const;
#endif
  virtual unsigned int getErrorIdOffset() const;

  unsigned int getSeverity(unsigned int index, unsigned int pkgVersion) const;

  unsigned int getCategory(unsigned int index) const;

  std::string getMessage(unsigned int index, unsigned int pkgVersion,
                         const std::string& details) const;

  std::string getShortMessage(unsigned int index) const;


  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  bool                                 mIsEnabled;
  SupportedPackageURIList              mSupportedPackageURI;
  std::vector<SBasePluginCreatorBase*> mSBasePluginCreators;

#ifndef LIBSBML_USE_LEGACY_MATH
  ASTBasePlugin*                       mASTBasePlugin;
#endif /* LIBSBML_USE_LEGACY_MATH */
  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */

  friend class SBMLExtensionRegistry;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a deep copy of the given SBMLExtension_t structure
 *
 * @param ext the SBMLExtension_t structure to be copied
 *
 * @return a (deep) copy of the given SBMLExtension_t structure.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBMLExtension_t*
SBMLExtension_clone(SBMLExtension_t* ext);

/**
 * Frees the given SBMLExtension_t structure
 *
 * @param ext the SBMLExtension_t structure to be freed
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_free(SBMLExtension_t* ext);

/**
 * Adds the given SBasePluginCreatorBase_t structure to this package
 * extension.
 *
 * @param ext the SBMLExtension_t structure to be freed
 * @param sbaseExt the SBasePluginCreatorBase_t structure bound to
 * some SBML element and creates a corresponding SBasePlugin_t structure
 * of this package extension.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_addSBasePluginCreator(SBMLExtension_t* ext,
      SBasePluginCreatorBase_t *sbaseExt );

/**
 * Returns an SBasePluginCreatorBase_t structure of this package extension
 * bound to the given extension point.
 *
 * @param ext the SBMLExtension_t structure
 * @param extPoint the SBaseExtensionPoint_t to which the returned
 * SBasePluginCreatorBase_t structure bound.
 *
 * @return an SBasePluginCreatorBase_t structure of this package extension
 * bound to the given extension point, or @c NULL for invalid extension of
 * extension point.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreator(SBMLExtension_t* ext,
      SBaseExtensionPoint_t *extPoint );

/**
 * Returns an SBasePluginCreatorBase_t structure of this package extension
 * with the given index.
 *
 * @param ext the SBMLExtension_t structure
 * @param index the index of the returned SBasePluginCreatorBase_t structure for
 * this package extension.
 *
 * @return an SBasePluginCreatorBase_t structure of this package extension
 * with the given index, or @c NULL for an invalid extension structure.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBasePluginCreatorBase_t *
SBMLExtension_getSBasePluginCreatorByIndex(SBMLExtension_t* ext,
      unsigned int index);

/**
 * Returns the number of SBasePlugin_t structures stored in the structure.
 *
 * @param ext the SBMLExtension_t structure
 *
 * @return the number of SBasePlugin_t structures stored in the structure,
 * or LIBSBML_INVALID_OBJECT.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_getNumOfSBasePlugins(SBMLExtension_t* ext);

/**
 * Returns the number of supported package namespaces (package versions)
 * for this package extension.
 *
 * @param ext the SBMLExtension_t structure
 *
 * @return the number of supported package namespaces (package versions)
 * for this package extension or LIBSBML_INVALID_OBJECT.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_getNumOfSupportedPackageURI(SBMLExtension_t* ext);

/**
 * Returns a flag indicating, whether the given URI (package version) is
 * supported by this package extension.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the package uri
 *
 * @return true (1) if the given URI (package version) is supported by this
 * package extension, otherwise false (0) is returned.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_isSupported(SBMLExtension_t* ext, const char* uri);


/**
 * Returns the package URI (package version) for the given index.
 *
 * @param ext the SBMLExtension_t structure
 * @param index the index of the supported package uri to return
 *
 * @return the package URI (package version) for the given index or NULL.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getSupportedPackageURI(SBMLExtension_t* ext, unsigned int index);


/**
 * Returns the name of the package extension. (e.g. "layout", "multi").
 *
 * @param ext the SBMLExtension_t structure
 *
 * @return the name of the package extension. (e.g. "layout", "multi").
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getName(SBMLExtension_t* ext);

/**
 * Returns the uri corresponding to the given SBML level, SBML version,
 * and package version for this extension.
 *
 * @param ext the SBMLExtension_t structure
 * @param sbmlLevel the level of SBML
 * @param sbmlVersion the version of SBML
 * @param pkgVersion the version of package
 *
 * @return a string of the package URI
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getURI(SBMLExtension_t* ext, unsigned int sbmlLevel,
      unsigned int sbmlVersion, unsigned int pkgVersion);

/**
 * Returns the SBML level associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the SBML level associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getLevel(SBMLExtension_t* ext, const char* uri);

/**
 * Returns the SBML version associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the SBML version associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getVersion(SBMLExtension_t* ext, const char* uri);

/**
 * Returns the package version associated with the given URI of this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents a versions of the package
 *
 * @return the package version associated with the given URI of this package.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
unsigned int
SBMLExtension_getPackageVersion(SBMLExtension_t* ext, const char* uri);

/**
 * This method takes a type code of this package and returns a string
 * representing the code.
 *
 * @param ext the SBMLExtension_t structure
 * @param typeCode the typeCode supported by the package
 *
 * @return the string representing the given typecode, or @c NULL in case an
 * invalid extension was provided.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
const char*
SBMLExtension_getStringFromTypeCode(SBMLExtension_t* ext, int typeCode);

/**
 * Returns an SBMLNamespaces_t structure corresponding to the given uri.
 * NULL will be returned if the given uri is not defined in the corresponding
 * package.
 *
 * @param ext the SBMLExtension_t structure
 * @param uri the string of URI that represents one of versions of the package
 *
 * @return an SBMLNamespaces_t structure corresponding to the uri. NULL
 *         will be returned if the given uri is not defined in the corresponding
 *         package or an invalid extension structure was provided.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
SBMLNamespaces_t*
SBMLExtension_getSBMLExtensionNamespaces(SBMLExtension_t* ext, const char* uri);

/**
 * Enable/disable this package.
 *
 * @param ext the SBMLExtension_t structure
 * @param isEnabled the value to set : true (1) (enabled) or false (0) (disabled)
 *
 * @return true (1) if this function call succeeded, otherwise false (0)is returned.
 * If the extension is invalid, LIBSBML_INVALID_OBJECT will be returned.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_setEnabled(SBMLExtension_t* ext, int isEnabled);

/**
 * Check if this package is enabled (true/1) or disabled (false/0).
 *
 * @param ext the SBMLExtension_t structure
 *
 * @return true if the package is enabled, otherwise false is returned.
 * If the extension is invalid, LIBSBML_INVALID_OBJECT will be returned.
 *
 * @memberof SBMLExtension_t
 */
LIBSBML_EXTERN
int
SBMLExtension_isEnabled(SBMLExtension_t* ext);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLExtension_h */

