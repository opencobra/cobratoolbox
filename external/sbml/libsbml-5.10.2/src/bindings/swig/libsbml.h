/**
 * \file    libsbml.h
 * \brief   Language-independent SWIG includes for wrapping libSBML
 * \author  Ben Bornstein
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
 * ---------------------------------------------------------------------- -->*/

#include <sbml/common/libsbml-version.h>
#include <sbml/common/operationReturnValues.h>

#include <sbml/util/IdList.h>
#include <sbml/util/IdentifierTransformer.h>
#include <sbml/util/ElementFilter.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>
#include <sbml/UnitKind.h>
#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBase.h>
#include <sbml/ListOf.h>
#include <sbml/Model.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/CompartmentType.h>
#include <sbml/SpeciesType.h>
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/LocalParameter.h>
#include <sbml/InitialAssignment.h>
#include <sbml/Rule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/Constraint.h>
#include <sbml/Reaction.h>
#include <sbml/KineticLaw.h>
#include <sbml/SimpleSpeciesReference.h>
#include <sbml/SpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>
#include <sbml/Trigger.h>
#include <sbml/Delay.h>
#include <sbml/CompartmentType.h>
#include <sbml/Constraint.h>
#include <sbml/InitialAssignment.h>
#include <sbml/SpeciesType.h>
#include <sbml/SBO.h>
#include <sbml/SyntaxChecker.h>
#include <sbml/StoichiometryMath.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/SBMLTransforms.h>
#include <sbml/SBMLConstructorException.h>

#include <sbml/conversion/ConversionOption.h>
#include <sbml/conversion/ConversionProperties.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLFunctionDefinitionConverter.h>
#include <sbml/conversion/SBMLIdConverter.h>
#include <sbml/conversion/SBMLInferUnitsConverter.h>
#include <sbml/conversion/SBMLInitialAssignmentConverter.h>
#include <sbml/conversion/SBMLLevelVersionConverter.h>
#include <sbml/conversion/SBMLLocalParameterConverter.h>
#include <sbml/conversion/SBMLReactionConverter.h>
#include <sbml/conversion/SBMLRuleConverter.h>
#include <sbml/conversion/SBMLStripPackageConverter.h>
#include <sbml/conversion/SBMLUnitsConverter.h>

#include <sbml/validator/SBMLValidator.h>
#include <sbml/validator/SBMLExternalValidator.h>

#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLConstructorException.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLTriple.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/xml/XMLError.h>
#include <sbml/xml/XMLErrorLog.h>
#include <sbml/xml/XMLParser.h>
#include <sbml/xml/XMLHandler.h>
#include <sbml/xml/XMLTokenizer.h>

#include <sbml/annotation/CVTerm.h>
#include <sbml/annotation/Date.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/RDFAnnotationParser.h>

#include <sbml/extension/ISBMLExtensionNamespaces.h>
#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/extension/SBasePlugin.h>
#include <sbml/extension/SBMLDocumentPlugin.h>
#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionException.h>
#include <sbml/extension/SBMLExtensionNamespaces.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

#include "ListWrapper.h"

