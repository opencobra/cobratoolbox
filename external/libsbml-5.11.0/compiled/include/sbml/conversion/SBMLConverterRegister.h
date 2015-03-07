/**
 * @cond doxygenCppOnly
 * 
 * @file    SBMLConverterRegister.h
 * @brief   Definition of SBMLConverterRegister, a template to register converters.
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
 * @class SBMLConverterRegister
 * @sbmlbrief{core} Template for SBML converter registry registrations.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * The converter registry, implemented as a singleton object of class
 * SBMLConverterRegistry, maintains a list of known converters and provides
 * methods for discovering them.  LibSBML comes with a number of converters
 * built-in, but applications can create their own converters and add them
 * to the set known to libSBML.  Such converters would be subclasses of
 * SBMLConverter.
 *
 * To register themselves, the subclasses should provide
 * an @c init() method that calls the SBMLConverterRegistry::addConverter()
 * method on the SBMLConverter instance.  For example, if a new converter
 * class named @c SweetConverter were to be created, it should provide
 * an @c init() method along the following lines:
 * @code{.cpp}
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

void SweetConverter::init()
{
  SBMLConverterRegistry::getInstance().addConverter(new SweetConverter());
}
@endcode
 * Then, to perform the registration, the caller code should perform a
 * final step of instantiatiating the template in a separate file used
 * for this purpose for all user-defined converters:
 * @code{.cpp}
#include <sbml/conversion/SBMLConverterRegister.h>

static SBMLConverterRegister<SweetConverter> registerSweetConverter;
... other converter template instantiations here ... 
@endcode
 * 
 * For more information about the registry, please consult the introduction
 * to the class SBMLRegistry.
 */

#ifndef SBMLConverterRegister_h
#define SBMLConverterRegister_h

#include <sbml/common/extern.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

template<class SBMLConversionType>
class LIBSBML_EXTERN SBMLConverterRegister
{
public:

  /**
   * Constructor.
   *
   * This constructor invokes the @c init() method of the class given as
   * the template parameter.  When an object of the concrete class is
   * created (typically as a static instance in the caller's code),
   * the act of calling the @c init() method should do the steps of
   * registering the converter with the SBML converter registry.
   */
  SBMLConverterRegister() { SBMLConversionType::init(); };

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBMLConverterRegister_h */

/** @endcond */
