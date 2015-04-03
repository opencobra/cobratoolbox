/**
 * @file    SBMLInferUnitsConverter.h
 * @brief   Definition of SBMLInferUnitsConverter, infers units for parameters.
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
 * @class SBMLInferUnitsConverter
 * @sbmlbrief{core} Converter for inferring and setting parameter units.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This SBML converter takes an SBML document and attempts to infer units for
 * any Parameter objects whose units are undeclared.  It then sets the
 * "units" attribute of those parameters to the units inferred (if necessary,
 * creating new UnitDefinition objects on the model in the process).
 *
 * @section SBMLInferUnitsConverter-usage Configuration and use of SBMLInferUnitsConverter
 *
 * SBMLInferUnitsConverter is enabled by creating a ConversionProperties
 * object with the option @c "inferUnits", and passing this
 * properties object to SBMLDocument::convert(@if java ConversionProperties@endif).
 * The converter offers no other options.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLInferUnitsConverter_h
#define SBMLInferUnitsConverter_h

#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>



#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN  SBMLInferUnitsConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLInferUnitsConverter object.
   */
  SBMLInferUnitsConverter ();


  /**
   * Copy constructor; creates a copy of an SBMLInferUnitsConverter
   * object.
   *
   * @param obj the SBMLInferUnitsConverter object to copy.
   */
  SBMLInferUnitsConverter(const SBMLInferUnitsConverter& obj);


  /**
   * Destroys this object.
   */
  virtual ~SBMLInferUnitsConverter ();


  /**
   * Assignment operator for SBMLInferUnitsConverter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLInferUnitsConverter& operator=(const SBMLInferUnitsConverter& rhs);


  /**
   * Creates and returns a deep copy of this SBMLInferUnitsConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLInferUnitsConverter* clone() const;


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLInferUnitsConverter object to find out if the object's
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
   * @li @sbmlconstant{LIBSBML_CONV_INVALID_SRC_DOCUMENT, OperationReturnValues_t}
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


  /* Convenience functions for this converter */


#ifndef SWIG

#endif // SWIG


private:
  /** @cond doxygenLibsbmlInternal */

  std::string existsAlready(Model& m, UnitDefinition *newUD);

  unsigned int newIdCount;


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
#endif  /* SBMLInferUnitsConverter_h */

