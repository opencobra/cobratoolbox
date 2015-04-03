/**
 * @file    SBMLStripPackageConverter.h
 * @brief   Definition of SBMLStripPackageConverter, the base class for SBML conversion.
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
 * @class SBMLStripPackageConverter
 * @sbmlbrief{core} Converter that removes SBML Level 3 packages.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This SBML converter takes an SBML document and removes (strips) an SBML
 * Level&nbsp;3 package from it.  No conversion is performed; the package
 * constructs are simply removed from the SBML document.  The package to be
 * stripped is determined by the value of the option @c "package" on the
 * conversion properties.
 *
 * @section SBMLStripPackageConverter-usage Configuration and use of SBMLStripPackageConverter
 *
 * SBMLStripPackageConverter is enabled by creating a ConversionProperties
 * object with the option @c "stripPackage", and passing this properties
 * object to SBMLDocument::convert(@if java ConversionProperties@endif).
 * This converter takes one required option:
 *
 * @li @c "package": the value of this option should be a text string, the
 * nickname of the SBML Level&nbsp;3 package to be stripped from the model.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLStripPackageConverter_h
#define SBMLStripPackageConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>

#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLStripPackageConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLStripPackageConverter object.
   */
  SBMLStripPackageConverter ();


  /**
   * Copy constructor; creates a copy of an SBMLStripPackageConverter
   * object.
   *
   * @param obj the SBMLStripPackageConverter object to copy.
   */
  SBMLStripPackageConverter(const SBMLStripPackageConverter& obj);


  /**
   * Destroys this object.
   */
  virtual ~SBMLStripPackageConverter ();


  /**
   * Assignment operator for SBMLStripPackageConverter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLStripPackageConverter& operator=(const SBMLStripPackageConverter& rhs);


  /**
   * Creates and returns a deep copy of this SBMLStripPackageConverter
   * object.
   *
   * @return the (deep) copy of this converter object.
   */
  virtual SBMLStripPackageConverter* clone() const;


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLStripPackageConverter object to find out if the object's
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
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN, OperationReturnValues_t}
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



#ifndef SWIG

#endif // SWIG



private:
  /** @cond doxygenLibsbmlInternal */

  std::string getPackageToStrip();


  /** @endcond */


};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLStripPackageConverter_h */

