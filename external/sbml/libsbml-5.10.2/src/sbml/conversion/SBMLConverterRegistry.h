/**
 * @file    SBMLConverterRegistry.h
 * @brief   Definition of SBMLConverterRegistry, a registry of available converters.
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
 * @class SBMLConverterRegistry
 * @sbmlbrief{core} Registry of all libSBML SBML converters.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * LibSBML provides facilities for transforming and converting SBML
 * documents in various ways.  These transformations can involve
 * essentially anything that can be written algorithmically; examples
 * include converting the units of measurement in a model, or converting
 * from one Level+Version combination of SBML to another.  Converters are
 * implemented as objects derived from the class SBMLConverter.
 *
 * The converter registry, implemented as a singleton object of class
 * SBMLConverterRegistry, maintains a list of known converters and provides
 * methods for discovering them.  Callers can use the method
 * SBMLConverterRegistry::getNumConverters() to find out how many
 * converters are registered, then use
 * SBMLConverterRegistry::getConverterByIndex(@if java int@endif) to
 * iterate over each one; alternatively, callers can use
 * SBMLConverterRegistry::getConverterFor(@if java const ConversionProperties@endif)
 * to search for a converter having specific properties.
 */

#ifndef SBMLConverterRegistry_h
#define SBMLConverterRegistry_h


#include <sbml/common/extern.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/ConversionProperties.h>
#include <map>
#include <vector>


#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLConverterRegistry
{
public:
  /**
   * Returns the singleton instance for the converter registry.
   *
   * Prior to using the registry, callers have to obtain a copy of the
   * registry.  This static method provides the means for doing that.
   * 
   * @return the singleton for the converter registry. 
   */
  static SBMLConverterRegistry& getInstance();


  /** 
   * Adds the given converter to the registry of SBML converters.
   * 
   * @param converter the converter to add to the registry.
   * 
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The possible values are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int addConverter (const SBMLConverter* converter);

  
  /** 
   * Returns the converter with the given index number.
   *
   * Converters are given arbitrary index numbers by the registry.  Callers
   * can use the method SBMLConverterRegistry::getNumConverters() to find
   * out how many converters are registered, then use this method to
   * iterate over the list and obtain each one in turn.
   * 
   * @param index the zero-based index of the converter to fetch.
   * 
   * @return the converter with the given index number, or @c NULL if the
   * number is less than @c 0 or there is no converter at the given index
   * position.
   */
  SBMLConverter* getConverterByIndex(int index) const;


  /** 
   * Returns the converter that best matches the given configuration
   * properties.
   * 
   * Many converters provide the ability to configure their behavior.  This
   * is realized through the use of @em properties that offer different @em
   * options.  The present method allows callers to search for converters
   * that have specific property values.  Callers can do this by creating a
   * ConversionProperties object, adding the desired option(s) to the
   * object, then passing the object to this method.
   * 
   * @param props a ConversionProperties object defining the properties
   * to match against.
   * 
   * @return the converter matching the properties, or @c NULL if no
   * suitable converter is found.
   *
   * @see getConverterByIndex(@if java int@endif)
   */
  SBMLConverter* getConverterFor(const ConversionProperties& props) const;


  /**
   * Returns the number of converters known by the registry.
   * 
   * @return the number of registered converters.
   *
   * @see getConverterByIndex(@if java int@endif)
   */
  int getNumConverters() const;
  

  /** 
   * Destructor
   */
  virtual ~SBMLConverterRegistry();

protected:
  /** @cond doxygenLibsbmlInternal */

  /** 
   * protected constructor, use the getInstance() method to access the registry.
   */ 
  SBMLConverterRegistry();
  /** @endcond */


protected: 
  /** @cond doxygenLibsbmlInternal */
  std::vector<const SBMLConverter*>  mConverters;
  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif /* !SBMLConverterRegistry_h */

