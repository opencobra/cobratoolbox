/**
 * @file    SBMLLocalParameterConverter.h
 * @brief   Definition of SBMLLocalParameterConverter, a converter replacing local parameters with global ones
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
 * @class SBMLLocalParameterConverter
 * @sbmlbrief{core} Converter to turn local parameters into global ones.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This converter essentially promotes local parameters to global parameters.
 * It works by examining every Reaction object for LocalParameter objects,
 * then creating Parameter objects on the model for each one found, and
 * finally removing the original LocalParameter objects.  It creates new
 * identifiers for the fresh Parameter objects by concatenating the
 * identifier of the reaction with the identifier of the original
 * LocalParameter object.
 *
 * This converter can be useful for software applications that do not have
 * the ability to handle local parameters on reactions.  Such applications
 * could check incoming models for local parameters and run those models
 * through this converter before proceeding with other steps.
 *
 * @section SBMLLocalParameterConverter-usage Configuration and use of SBMLLocalParameterConverter
 *
 * SBMLLocalParameterConverter is enabled by creating a ConversionProperties
 * object with the option @c "promoteLocalParameters", and passing this
 * properties object to SBMLDocument::convert(@if java
 * ConversionProperties@endif).  The converter offers no other options.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLLocalParameterConverter_h
#define SBMLLocalParameterConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLLocalParameterConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLLocalParameterConverter object.
   */
  SBMLLocalParameterConverter();


  /**
   * Copy constructor; creates a copy of an SBMLLocalParameterConverter
   * object.
   *
   * @param obj the SBMLLocalParameterConverter object to copy.
   */
  SBMLLocalParameterConverter(const SBMLLocalParameterConverter& obj);


  /**
   * Creates and returns a deep copy of this SBMLLocalParameterConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLLocalParameterConverter* clone() const;


  /**
   * Destroy this SBMLLocalParameterConverter object.
   */
  virtual ~SBMLLocalParameterConverter ();


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLLocalParameterConverter object to find out if the object's
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
#endif  /* SBMLLocalParameterConverter_h */

