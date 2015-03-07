/**
 * @file    SBaseExtensionPoint.h
 * @brief   Definition of SBaseExtensionPoint
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
 * @class SBaseExtensionPoint
 * @sbmlbrief{core} Base class for extending SBML components
 *
 * @htmlinclude not-sbml-warning.html
 *
 * @ifnot clike @internal @endif@~
 *
 * @copydetails doc_extension_sbaseextensionpoint
 */

#ifndef SBaseExtensionPoint_h
#define SBaseExtensionPoint_h

#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SBaseExtensionPoint
{
public:

  /**
   * Constructor for SBaseExtensionPoint.
   *
   * The use of SBaseExtensionPoint is relatively straightforward.  The
   * class needs to be used for each extended SBML object implemented
   * using SBMLDocumentPlugin or SBasePlugin.  Doing so requires knowing
   * just two things:
   *
   * @li The short-form name of the @em parent package being extended.
   * The parent package is often simply core SBML, identified in libSBML
   * by the nickname <code>"core"</code>, but a SBML Level&nbsp;3
   * package could conceivably extend another Level&nbsp;3 package and
   * the mechanism supports this.
   *
   * @li The libSBML type code assigned to the object being extended.
   * For example, if an extension of Model is implemented, the relevant
   * type code is SBML_MODEL, found in #SBMLTypeCode_t.
   *
   * @param pkgName the short-form name of the parent package where
   * that this package extension is extending.
   *
   * @param typeCode the type code of the object being extended.
   */
  SBaseExtensionPoint(const std::string& pkgName, int typeCode);


  /**
   * Destroys this SBaseExtensionPoint object.
   */
  virtual ~SBaseExtensionPoint();


  /**
   * Copy constructor.
   *
   * This creates a copy of an SBaseExtensionPoint instance.
   *
   * @param rhs the object to copy.
   */
  SBaseExtensionPoint(const SBaseExtensionPoint& rhs);


  /**
   * Creates and returns a deep copy of this SBaseExtensionPoint object.
   *
   * @return the (deep) copy of this SBaseExtensionPoint object.
   */
  SBaseExtensionPoint* clone() const;


  /**
   * Returns the package name of this extension point.
   */
  const std::string& getPackageName() const;


  /**
   * Returns the libSBML type code of this extension point.
   */
  virtual int getTypeCode() const;


private:
  std::string mPackageName;
  int         mTypeCode;
};


#ifndef SWIG

/**
 * Comparison (equal-to) operator for SBaseExtensionPoint
 */
bool operator==(const SBaseExtensionPoint& lhs, const SBaseExtensionPoint& rhs);


/**
 * Comparison (less-than) operator for SBaseExtensionPoint
 */
bool operator<(const SBaseExtensionPoint& lhs, const SBaseExtensionPoint& rhs);

#endif //SWIG


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new SBaseExtensionPoint_t structure with the given arguments
 *
 * @param pkgName the package name for the new structure
 * @param typeCode the SBML Type code for the new structure
 *
 * @return the newly created SBaseExtensionPoint_t structure or NULL in case
 * the given pkgName is invalid (NULL).
 *
 * @memberof SBaseExtensionPoint_t
 */
LIBSBML_EXTERN
SBaseExtensionPoint_t *
SBaseExtensionPoint_create(const char* pkgName, int typeCode);

/**
 * Frees the given SBaseExtensionPoint_t structure
 *
 * @param extPoint the SBaseExtensionPoint_t structure to be freed
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof SBaseExtensionPoint_t
 */
LIBSBML_EXTERN
int
SBaseExtensionPoint_free(SBaseExtensionPoint_t *extPoint);

/**
 * Creates a deep copy of the given SBaseExtensionPoint_t structure
 *
 * @param extPoint the SBaseExtensionPoint_t structure to be copied
 *
 * @return a (deep) copy of the given SBaseExtensionPoint_t structure.
 *
 * @memberof SBaseExtensionPoint_t
 */
LIBSBML_EXTERN
SBaseExtensionPoint_t *
SBaseExtensionPoint_clone(const SBaseExtensionPoint_t *extPoint);

/**
 * Returns the package name for the given SBaseExtensionPoint_t structure
 *
 * @param extPoint the SBaseExtensionPoint_t structure
 *
 * @return the package name for the given SBaseExtensionPoint_t structure or
 * NULL.
 *
 * @memberof SBaseExtensionPoint_t
 */
LIBSBML_EXTERN
char *
SBaseExtensionPoint_getPackageName(const SBaseExtensionPoint_t *extPoint);

/**
 * Returns the type code for the given SBaseExtensionPoint_t structure
 *
 * @param extPoint the SBaseExtensionPoint_t structure
 *
 * @return the type code for the given SBaseExtensionPoint_t structure or
 * LIBSBML_INVALID_OBJECT in case an invalid object is given.
 *
 * @memberof SBaseExtensionPoint_t
 */
LIBSBML_EXTERN
int
SBaseExtensionPoint_getTypeCode(const SBaseExtensionPoint_t *extPoint);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#endif  /* SBaseExtensionPoint_h */


