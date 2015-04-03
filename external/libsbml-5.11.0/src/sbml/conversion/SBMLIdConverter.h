/**
 * @file    SBMLIdConverter.h
 * @brief   Definition of SBMLIdConverter, a converter renaming SIds
 * @author  Frank Bergmann
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
 * @class SBMLIdConverter
 * @sbmlbrief{core} Converter for replacing object identifiers.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This converter translates all instances of a given identifier (i.e., SBML object "id"
 * attribute value) of type "SId" in a Model to another identifier.  It does this based on a list of source
 * identifiers, translating each one to its corresponding replacement value
 * in a list of replacement identifiers.  It also updates all references to
 * the identifiers so replaced.  (More technically, it replaces all values
 * known as type @c SIdRef in the SBML Level&nbsp;3 specifications.)
 *
 * This converter only searches the global SId namespace for the Model child of the 
 * SBMLDocument.  It does not replace any IDs or SIdRefs for LocalParameters, nor
 * does it replace any UnitSIds or UnitSIdRefs.  It likewise does not replace any IDs
 * in a new namespace introduced by a package, such as the PortSId namespace
 * from the Hierarchical %Model Composition package, nor any Model objects that are
 * not the direct child of the SBMLDocument, such as the ModelDefinitions from 
 * the Hierarchical %Model Composition package.
 *
 * If, however, a package introduces a new element with an "id" attribute
 * of type SId, any attribute of type SIdRef, or child of type SIdRef (such as 
 * a new Math child of a package element), those IDs will be replaced if they
 * match a source identifier.
 *
 * @section SBMLIdConverter-usage Configuration and use of SBMLIdConverter
 *
 * SBMLIdConverter is enabled by creating a ConversionProperties object with
 * the option @c "renameSIds", and passing this properties object to
 * SBMLDocument::convert(@if java ConversionProperties@endif).
 * The converter accepts two options, and both must
 * be set or else no conversion is performed:
 *
 * @li @c "currentIds": A comma-separated list of identifiers to replace.
 * @li @c "newIds": A comma-separated list of identifiers to use as the
 * replacements.  The values should correspond one-to-one with the identifiers
 * in @c "currentIds" that should be replaced.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLIdConverter_h
#define SBMLIdConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLIdConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLIdConverter object.
   */
  SBMLIdConverter();


  /**
   * Copy constructor; creates a copy of an SBMLIdConverter
   * object.
   *
   * @param obj the SBMLIdConverter object to copy.
   */
  SBMLIdConverter(const SBMLIdConverter& obj);


  /**
   * Creates and returns a deep copy of this SBMLIdConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLIdConverter* clone() const;


  /**
   * Destroy this SBMLIdConverter object.
   */
  virtual ~SBMLIdConverter ();


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLIdConverter object to find out if the object's
   * property values match the given ones.  This method is also used by
   * SBMLConverterRegistry::getConverterFor(@if java ConversionProperties@endif)
   * to search across all registered converters for one matching particular
   * properties.
   *
   * @param props the properties to match.
   *
   * @return @c true if this converter's properties match, @c false
   * otherwise.
   */
  virtual bool matchesProperties(const ConversionProperties &props) const;


  /**
   * Perform the conversion.
   *
   * This method causes the converter to do the actual conversion work,
   * that is, to convert the SBMLDocument object set by
   * SBMLConverter::setDocument(@if java SBMLDocument@endif) and
   * with the configuration options set by
   * SBMLConverter::setProperties(@if java ConversionProperties@endif).
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int convert();


  /**
   * Returns the default properties of this converter.
   *
   * A given converter exposes one or more properties that can be adjusted
   * in order to influence the behavior of the converter.  This method
   * returns the @em default property settings for this converter.  It is
   * meant to be called in order to discover all the settings for the
   * converter object.
   *
   * @return the ConversionProperties object describing the default properties
   * for this converter.
   */
  virtual ConversionProperties getDefaultProperties() const;

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLIdConverter_h */

