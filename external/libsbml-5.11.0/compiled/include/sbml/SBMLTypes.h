/**
 * @file    SBMLTypes.h
 * @brief   Include all SBML types in a single header file.
 * @author  Ben Bornstein
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

#ifndef SBMLTypes_h
#define SBMLTypes_h


#include <sbml/common/sbmlfwd.h>

#include <sbml/SBMLDocument.h>
#include <sbml/xml/XMLError.h>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

#include <sbml/Model.h>

#include <sbml/FunctionDefinition.h>

#include <sbml/UnitKind.h>
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>

#include <sbml/CompartmentType.h>
#include <sbml/SpeciesType.h>

#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/LocalParameter.h>

#include <sbml/InitialAssignment.h>

#include <sbml/Reaction.h>
#include <sbml/KineticLaw.h>
#include <sbml/SpeciesReference.h>
#include <sbml/SimpleSpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>

#include <sbml/Rule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/RateRule.h>

#include <sbml/Constraint.h>

#include <sbml/Event.h>
#include <sbml/EventAssignment.h>

#include <sbml/Delay.h>
#include <sbml/StoichiometryMath.h>
#include <sbml/Trigger.h>
#include <sbml/Priority.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/MathML.h>
#include <sbml/math/L3Parser.h>
#include <sbml/math/L3ParserSettings.h>

#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>

#include <sbml/util/IdentifierTransformer.h>
#include <sbml/util/ElementFilter.h>

/* also include the extension types so they don't have to be added */
/*
#include <sbml/extension/SBasePlugin.h>
#include <sbml/extension/SBaseExtensionPoint.h>
#include <sbml/extension/SBMLDocumentPlugin.h>
#include <sbml/extension/SBMLExtension.h>
#include <sbml/extension/SBMLExtensionRegistry.h>
*/
#endif  /* SBMLTypes_h */
