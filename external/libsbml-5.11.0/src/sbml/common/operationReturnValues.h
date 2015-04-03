/**
 * @file    operationReturnValues.h
 * @brief   Enumeration of values returned by operations within libSBML.
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#ifndef LIBSBML_OPERATION_RETURN_VALUES_H
#define LIBSBML_OPERATION_RETURN_VALUES_H

#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_BEGIN

BEGIN_C_DECLS

/**
 * @enum OperationReturnValues_t
 * LibSBML diagnostic return codes.
 *
 * Many methods in libSBML return a status code to indicate whether the
 * operation requested by the caller succeeded or failed.  This enumeration
 * lists all the possible return codes from any libSBML methods.
 */
typedef enum
{
    LIBSBML_OPERATION_SUCCESS       = 0
    /*!< The operation was successful. */

  , LIBSBML_INDEX_EXCEEDS_SIZE      = -1
    /*!< An index parameter exceeded the bounds of a data array or other
     * collection used in the operation.  This return value is typically
     * returned by methods that take index numbers to refer to lists
     * of objects, when the caller has provided an index that exceeds
     * the bounds of the list.  LibSBML provides methods for checking the
     * size of list/sequence/collection structures, and callers should
     * verify the sizes before calling methods that take index numbers. */

  , LIBSBML_UNEXPECTED_ATTRIBUTE    = -2
    /*!< The attribute that is the subject of this operation is not valid
     * for the combination of SBML Level and Version for the underlying
     * object.  This can happen because libSBML strives to offer a uniform
     * API for all SBML Levels and Versions, but some object attributes and
     * elements are not defined for all SBML Levels and Versions.  Calling
     * programs are expected to be aware of which object structures they
     * are working with, but when errors of this kind occur, they are
     * reported using this return value. */

  , LIBSBML_OPERATION_FAILED        = -3
    /*!< The requested action could not be performed.  This can occur in
     * a variety of contexts, such as passing a null object as a parameter
     * in a situation where it does not make sense to permit a null object.
     */

  , LIBSBML_INVALID_ATTRIBUTE_VALUE = -4
    /*!< A value passed as an argument to the method is not of a type that
     * is valid for the operation or kind of object involved.  For example,
     * this return code is used when a calling program attempts to set an
     * SBML object identifier to a string whose syntax does not conform to
     * the SBML identifier syntax. */

  , LIBSBML_INVALID_OBJECT          = -5
    /*!< The object passed as an argument to the method is not of a type
     * that is valid for the operation or kind of object involved.  For
     * example, handing an invalidly-constructed ASTNode to a method
     * expecting an ASTNode will result in this error. */

  , LIBSBML_DUPLICATE_OBJECT_ID     = -6
    /*!< There already exists an object with this identifier in the
     * context where this operation is being attempted.  This error is
     * typically returned in situations where SBML object identifiers must be
     * unique, such as attempting to add two species with the same identifier
     * to a model. */

  , LIBSBML_LEVEL_MISMATCH          = -7
    /*!< The SBML Level associated with the object does not match the Level
     * of the parent object.  This error can happen when an SBML component
     * such as a species or compartment object is created outside of a model
     * and a calling program then attempts to add the object to a model that
     * has a different SBML Level defined. */

  , LIBSBML_VERSION_MISMATCH        = -8
    /*!< The SBML Version within the SBML Level associated with the object
     * does not match the Version of the parent object.  This error can
     * happen when an SBML component such as a species or compartment object
     * is created outside of a model and a calling program then attempts to
     * add the object to a model that has a different SBML Level+Version
     * combination. */

  , LIBSBML_INVALID_XML_OPERATION   = -9
    /*!< The XML operation attempted is not valid for the object or context
     * involved.  This error is typically returned by the XML interface layer
     * of libSBML, when a calling program attempts to construct or manipulate
     * XML in an invalid way.  */

  , LIBSBML_NAMESPACES_MISMATCH   = -10
    /*!< The SBML Namespaces associated with the object
     * do not match the SBML Namespaces of the parent object.  This error can
     * happen when an SBML component such as a species or compartment object
     * is created outside of a model and a calling program then attempts to
     * add the object to a model that has a different SBML Namespaces
     * combination. */

  , LIBSBML_DUPLICATE_ANNOTATION_NS   = -11
    /*!< There already exists a top level annotation with the same namespace as
     * annoation being appended.  This error is
     * typically returned in situations where the appendAnnotation function
     * is being used to add an annotation that has a namespace that is already
     * present in the existing annotation. */

  , LIBSBML_ANNOTATION_NAME_NOT_FOUND   = -12
    /*!< The existing annotation does not have a top-level element with
     * the given name. This error is
     * typically returned in situations where the 
     * replaceTopLevelAnnotationElement function or 
     * the removeTopLevelAnnotationElement function 
     * is being used to replace or remove an annotation with a name that does
     * not match the name of any top-level element that is already
     * present in the existing annotation. */

   , LIBSBML_ANNOTATION_NS_NOT_FOUND   = -13
    /*!< The existing annotation does not have a top-level element with
     * the given namespace. This error is
     * typically returned in situations where the 
     * replaceTopLevelAnnotationElement function or 
     * the removeTopLevelAnnotationElement function 
     * is being used to replace or remove an annotation with a namespace that does
     * not match the namespace of any top-level element that is already
     * present in the existing annotation. */
   /* ---------------------------------------------------------------------------
    *   
    *              Return codes for package extension
    *
    * -------------------------------------------------------------------------- */

  , LIBSBML_PKG_VERSION_MISMATCH  = -20
    /*!< The Version of package extension within the SBML Level and version
     * associated with the object does not match the Version of the parent 
     * object. This error can happen when an SBML component such as a layout
     * or group object is created outside of a model and a calling program 
     * then attempts to add the object to a model that has a different SBML 
     * Level+Version+Package Version combination. */

   , LIBSBML_PKG_UNKNOWN           = -21
    /*!< The required package extension is unknown. This error is typically 
     * returned when creating an object of SBase derived class with the required 
     * package, creating an object of SBMLNamespaces or its derived class with the 
     * required package, or invoking functions depending on the required package.
     * To avoid this error, the library of the required package needs to be 
     * linked.
     */

   , LIBSBML_PKG_UNKNOWN_VERSION    = -22
    /*!< The required version of the package extension is unknown. This error 
     * is typically returned when creating an object of SBase derived class with 
     * the required package, creating an object of SBMLNamespaces or its derived 
     * class with the required package, or invoking functions depending on the 
     * required package. This error may be avoided by updating the library of the 
     * required package to be linked.
     */

   , LIBSBML_PKG_DISABLED            = -23
    /*!< The required package extension is disabled. This error is typically 
     * returned when creating an object of SBase derived class with the required 
     * package, creating an object of SBMLNamespaces or its derived class with the 
     * required package, or invoking functions depending on the required  package.
     * To avoid this error, the library of the required package needs to be enabled.
     */

   , LIBSBML_PKG_CONFLICTED_VERSION  = -24
    /*!< Another version of the required package extension has already been enabled 
     * in the target SBase object, or enabled in the model to/in which the target 
     * object to be added/contained. This error is typically returned  when adding an 
     * object of some SBase derived class with the required package to other SBase 
     * derived object, or when enabling the required package in the target object.  
     * To avoid this error, the conflict of versions need to be avoided. 
     */

   , LIBSBML_PKG_CONFLICT            = -25
    /*!< Another SBML package extension for the same URI has already been registered. 
     * This error is typically returned when adding a SBML package extension to the 
     * SBMLExtensionRegistry. To avoid this error, ensure that SBML package 
     * extensions are only registered once. 
     */

   /* ---------------------------------------------------------------------------
    *   
    *              Return codes for conversion extensions
    *
    * -------------------------------------------------------------------------- */

  , LIBSBML_CONV_INVALID_TARGET_NAMESPACE  = -30
    /*!< The target namespace is not a valid SBML namespace. while
     * attempting to convert the SBML document using
     * SBMLLevelVersionConverter::convert() or related methods, the target
     * namespace has been found to be invalid or unset.  (The function
     * SBMLNamespaces::isValidCombination() may be useful in
     * detecting this situation and preventing the error.)
     */

  , LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE = -31
    /*!< Conversions involving packages are not available in the specified
     * routine. This error is typically returned when calling a converter
     * that does not have the functionality to deal with SBML Level&nbsp;3
     * packages. To avoid this error, ensure that the requested
     * ConversionProperties specifies packages.
     */

  , LIBSBML_CONV_INVALID_SRC_DOCUMENT = -32
    /*!< The document on which conversion is being requested is invalid and
     * the requested conversion cannot be performed. This error is
     * typically returned when a conversion routine has been given an
     * invalid target document or the conversion requires a certain degree
     * of validity that is not present in the document. To avoid this
     * error, use the SBMLDocument::checkConsistency() function to find and
     * resolve errors before passing the document to a conversion method.
     */

  , LIBSBML_CONV_CONVERSION_NOT_AVAILABLE = -33
    /*!< Conversion with the given properties is not yet available. 
     */

  , LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN = -34
    /*!< The package that is being stripped is not an enabled
     * package but considered by libSBML to be an unrecognized
     * package.  This error is typically returned when calling
     * the StripPackage converter requesting that a package
     * for which code is not available be stripped. Thus the
     * containing document will not be altered as the elements 
     * and attributes for this package are stored as unknown package 
     * information and will be written out as such. 
     */

} OperationReturnValues_t;

/**
 * This method takes an SBML operation return value and returns a string representing
 * the code.
 *
 * @param returnValue the operation return value to convert to a string
 *
 * @return a human readable name for the given
 * @if clike #OperationReturnValues_t value@else operation return value @endif.
 *
 * @note The caller does not own the returned string and is therefore not
 * allowed to modify it.
 */
LIBSBML_EXTERN
const char *
OperationReturnValue_toString (int returnValue);

END_C_DECLS

LIBSBML_CPP_NAMESPACE_END


#endif  /* LIBSBML_OPERATION_RETURN_VALUES_H */

