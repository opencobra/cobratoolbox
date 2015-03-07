/**
 * @file    SBMLFunctionDefinitionConverter.h
 * @brief   Definition of SBMLFunctionDefinitionConverter, a converter replacing function definitions
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
 * @class SBMLFunctionDefinitionConverter
 * @sbmlbrief{core} Converter to expand user-defined functions in-line.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This converter manipulates user-defined functions in an SBML file.  When
 * invoked on a model, it performs the following operations:
 *
 * @li Reads the list of user-defined functions in the model (i.e., the list
 * of FunctionDefinition objects);
 * @li Looks for invocations of the function in mathematical expressions
 * throughout the model; and
 * @li For each invocation found, replaces the invocation with a in-line copy
 * of the function's body, similar to how macro expansions might be performed
 * in scripting and programming languages.
 *
 * For example, suppose the model contains a function definition
 * representing the function <code>f(x, y) = x * y</code>.  Further
 * suppose this functions invoked somewhere else in the model, in
 * a mathematical formula, as <code>f(s, p)</code>.  The outcome of running
 * SBMLFunctionDefinitionConverter on the model will be to replace
 * the call to <code>f</code> with the expression <code>s * p</code>.
 *
 * @section usage Configuration and use of SBMLFunctionDefinitionConverter
 *
 * SBMLFunctionDefinitionConverter is enabled by creating a
 * ConversionProperties object with the option @c
 * "expandFunctionDefinitions", and passing this properties object to
 * SBMLDocument::convert(@if java ConversionProperties@endif).
 * The converter accepts one option:
 *
 * @li @c "skipIds": if set, it should be a string containing a
 * comma-separated list of identifiers (SBML "id" values) that are to be
 * skipped during function conversion.  Functions whose identifiers are
 * found in this list will not be converted.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLFunctionDefinitionConverter_h
#define SBMLFunctionDefinitionConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>


#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLFunctionDefinitionConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLFunctionDefinitionConverter object.
   */
  SBMLFunctionDefinitionConverter();


  /**
   * Copy constructor; creates a copy of an SBMLFunctionDefinitionConverter
   * object.
   *
   * @param obj the SBMLFunctionDefinitionConverter object to copy.
   */
  SBMLFunctionDefinitionConverter(const SBMLFunctionDefinitionConverter& obj);


  /**
   * Creates and returns a deep copy of this SBMLFunctionDefinitionConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLFunctionDefinitionConverter* clone() const;


  /**
   * Destroy this SBMLFunctionDefinitionConverter object.
   */
  virtual ~SBMLFunctionDefinitionConverter ();


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLFunctionDefinitionConverter object to find out if the object's
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


private:
  /** @cond doxygenLibsbmlInternal */

  bool expandFD_errors(unsigned int errors);

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
#endif  /* SBMLFunctionDefinitionConverter_h */

