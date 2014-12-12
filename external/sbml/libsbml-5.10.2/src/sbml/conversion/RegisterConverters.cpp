/**
* @file    RegisterConverters.cpp
* @brief   Registers all available converters. 
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
*/

#ifndef RegisterConverters_cpp
#define RegisterConverters_cpp

#include <sbml/conversion/SBMLConverterRegister.h>

#include <sbml/conversion/SBMLFunctionDefinitionConverter.h>
#include <sbml/conversion/SBMLInitialAssignmentConverter.h>
#include <sbml/conversion/SBMLLevelVersionConverter.h>
#include <sbml/conversion/SBMLStripPackageConverter.h>
#include <sbml/conversion/SBMLUnitsConverter.h>
#include <sbml/conversion/SBMLRuleConverter.h>
#include <sbml/conversion/SBMLIdConverter.h>
#include <sbml/conversion/SBMLInferUnitsConverter.h>
#include <sbml/conversion/SBMLLocalParameterConverter.h>
#include <sbml/conversion/SBMLReactionConverter.h>


LIBSBML_CPP_NAMESPACE_BEGIN

// All new converters are registered here once. If a converter is not in this
// list it needs to be registered manually. 
  
/** @cond doxygenLibsbmlInternal */
static SBMLConverterRegister<SBMLRuleConverter> registerRuleConverter;
static SBMLConverterRegister<SBMLIdConverter> registerIdConverter;
static SBMLConverterRegister<SBMLFunctionDefinitionConverter> registerFDConverter;
static SBMLConverterRegister<SBMLInitialAssignmentConverter> registerIAConverter;
static SBMLConverterRegister<SBMLLevelVersionConverter> registerLVConverter;
static SBMLConverterRegister<SBMLStripPackageConverter> registerStripConverter;
static SBMLConverterRegister<SBMLUnitsConverter> registerUnitsConverter;
static SBMLConverterRegister<SBMLInferUnitsConverter> registerInferUnitsConverter;
static SBMLConverterRegister<SBMLLocalParameterConverter> registerlocaLParameterConverter;
static SBMLConverterRegister<SBMLReactionConverter> registerReactionConverter;
/** @endcond */

LIBSBML_CPP_NAMESPACE_END



#endif /* RegisterConverters_cpp */

