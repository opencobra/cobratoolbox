/**
 * @file    local.cpp
 * @brief   Python-specific SWIG support code for wrapping libSBML API
 * @author  Ben Bornstein
 * @author  Ben Kovitz
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

#include <cstddef>
#include "sbml/SBase.h"

/**
 * @return the most specific Swig type for the given SBMLExtension object.
 */
struct swig_type_info*
GetDowncastSwigType (SBMLExtension* se)
{
	if (se == 0) return SWIGTYPE_p_SBMLExtension;
	
	const std::string pkgName = se->getName();

#include "local-downcast-extension.cpp"

	return SWIGTYPE_p_SBMLExtension;
}

/**
 * @return the most specific Swig type for the given SBMLConverter object.
 */
struct swig_type_info*
GetDowncastSwigType (SBMLConverter* con)
{
	if (con == 0) return SWIGTYPE_p_SBMLConverter;
	
	const std::string& conName = con->getName();
	
     if (conName == "SBML Units Converter")
       return SWIGTYPE_p_SBMLUnitsConverter;
     else if (conName == "SBML Strip Package Converter")
       return SWIGTYPE_p_SBMLStripPackageConverter;
     else if (conName == "SBML Rule Converter")
       return SWIGTYPE_p_SBMLRuleConverter;
     else if (conName == "SBML Reaction Converter")
       return SWIGTYPE_p_SBMLReactionConverter;
     else if (conName == "SBML Local Parameter Converter")
       return SWIGTYPE_p_SBMLLocalParameterConverter;
     else if (conName == "SBML Level Version Converter")
       return SWIGTYPE_p_SBMLLevelVersionConverter;
     else if (conName == "SBML Initial Assignment Converter")
       return SWIGTYPE_p_SBMLInitialAssignmentConverter;
     else if (conName == "SBML Infer Units Converter")
       return SWIGTYPE_p_SBMLInferUnitsConverter;
     else if (conName == "SBML Id Converter")
       return SWIGTYPE_p_SBMLIdConverter;
     else if (conName == "SBML Function Definition Converter")
       return SWIGTYPE_p_SBMLFunctionDefinitionConverter;

#include "local-downcast-converters.cpp"	
	   
	return SWIGTYPE_p_SBMLConverter;
}

/**
 * @return the most specific Swig type for the given SBMLNamespaces object.
 */
struct swig_type_info*
GetDowncastSwigType (SBMLNamespaces* se)
{
	if (se == 0) return SWIGTYPE_p_SBMLNamespaces;
	
	const std::string pkgName = se->getPackageName();

#include "local-downcast-namespaces.cpp"

	return SWIGTYPE_p_SBMLNamespaces;
}

/**
 * @return the most specific Swig type for the given SBasePlugin object.
 */
struct swig_type_info*
GetDowncastSwigType (SBasePlugin* sbp)
{
  if (sbp == 0) return SWIGTYPE_p_SBasePlugin;

  const std::string pkgName = sbp->getPackageName();
  SBase* sb = sbp->getParentSBMLObject();
  if (!sb) return SWIGTYPE_p_SBasePlugin;
	
#include "local-downcast-plugins.cpp"

  return SWIGTYPE_p_SBasePlugin;
}


struct swig_type_info*
GetDowncastSwigTypeForPackage (SBase* sb, const std::string &pkgName);

/**
 * @return the most specific Swig type for the given SBase object.
 */
struct swig_type_info*
GetDowncastSwigType (SBase* sb)
{
  if (sb == 0) return SWIGTYPE_p_SBase;  
  const std::string pkgName = sb->getPackageName();
  return GetDowncastSwigTypeForPackage(sb, pkgName);
}
/**
 * @return the most specific Swig type for the given SBase object.
 */
struct swig_type_info*
GetDowncastSwigTypeForPackage (SBase* sb, const std::string &pkgName)
{
  if (sb == 0) return SWIGTYPE_p_SBase;
  
  std::string name;

  if (pkgName == "core")
  {
    switch (sb->getTypeCode())
    {
      case SBML_COMPARTMENT:
        return SWIGTYPE_p_Compartment;
  
      case SBML_COMPARTMENT_TYPE:
        return SWIGTYPE_p_CompartmentType;
  
      case SBML_CONSTRAINT:
        return SWIGTYPE_p_Constraint;

      case SBML_DOCUMENT:
        return SWIGTYPE_p_SBMLDocument;
  
      case SBML_EVENT:
        return SWIGTYPE_p_Event;
  
      case SBML_EVENT_ASSIGNMENT:
        return SWIGTYPE_p_EventAssignment;
  
      case SBML_FUNCTION_DEFINITION:
        return SWIGTYPE_p_FunctionDefinition;
  
      case SBML_INITIAL_ASSIGNMENT:
        return SWIGTYPE_p_InitialAssignment;
  
      case SBML_KINETIC_LAW:
        return SWIGTYPE_p_KineticLaw;
  
      case SBML_LIST_OF:
        name = sb->getElementName();
        if(name == "listOf"){
          return SWIGTYPE_p_ListOf;
        }
        else if(name == "listOfCompartments"){
          return SWIGTYPE_p_ListOfCompartments;
        }
        else if(name == "listOfCompartmentTypes"){
          return SWIGTYPE_p_ListOfCompartmentTypes;
        }
        else if(name == "listOfConstraints"){
          return SWIGTYPE_p_ListOfConstraints;
        }
        else if(name == "listOfEvents"){
          return SWIGTYPE_p_ListOfEvents;
        }
        else if(name == "listOfEventAssignments"){
          return SWIGTYPE_p_ListOfEventAssignments;
        }
        else if(name == "listOfFunctionDefinitions"){
          return SWIGTYPE_p_ListOfFunctionDefinitions;
        }
        else if(name == "listOfInitialAssignments"){
          return SWIGTYPE_p_ListOfInitialAssignments;
        }
        else if(name == "listOfParameters"){
          return SWIGTYPE_p_ListOfParameters;
        }
        else if(name == "listOfLocalParameters"){
          return SWIGTYPE_p_ListOfLocalParameters;
        }
        else if(name == "listOfReactions"){
          return SWIGTYPE_p_ListOfReactions;
        }
        else if(name == "listOfRules"){
          return SWIGTYPE_p_ListOfRules;
        }
        else if(name == "listOfSpecies"){
          return SWIGTYPE_p_ListOfSpecies;
        }
        else if(name == "listOfUnknowns"){
          return SWIGTYPE_p_ListOfSpeciesReferences;
        }
        else if(name == "listOfReactants"){
          return SWIGTYPE_p_ListOfSpeciesReferences;
        }
        else if(name == "listOfProducts"){
          return SWIGTYPE_p_ListOfSpeciesReferences;
        }
        else if(name == "listOfModifiers"){
          return SWIGTYPE_p_ListOfSpeciesReferences;
        }
        else if(name == "listOfSpeciesTypes"){
          return SWIGTYPE_p_ListOfSpeciesTypes;
        }
        else if(name == "listOfUnits"){
          return SWIGTYPE_p_ListOfUnits;
        }
        else if(name == "listOfUnitDefinitions"){
          return SWIGTYPE_p_ListOfUnitDefinitions;
        }
      return SWIGTYPE_p_ListOf;

      case SBML_MODEL:
        return SWIGTYPE_p_Model;

      case SBML_PARAMETER:
        return SWIGTYPE_p_Parameter;
  
      case SBML_LOCAL_PARAMETER:
        return SWIGTYPE_p_LocalParameter;

      case SBML_REACTION:
        return SWIGTYPE_p_Reaction;

      case SBML_SPECIES:
        return SWIGTYPE_p_Species;

      case SBML_SPECIES_REFERENCE:
        return SWIGTYPE_p_SpeciesReference;

      case SBML_MODIFIER_SPECIES_REFERENCE:
        return SWIGTYPE_p_ModifierSpeciesReference;

      case SBML_SPECIES_TYPE:
        return SWIGTYPE_p_SpeciesType;

      case SBML_UNIT_DEFINITION:
        return SWIGTYPE_p_UnitDefinition;

      case SBML_UNIT:
        return SWIGTYPE_p_Unit;

      case SBML_ALGEBRAIC_RULE:
        return SWIGTYPE_p_AlgebraicRule;

      case SBML_ASSIGNMENT_RULE:
        return SWIGTYPE_p_AssignmentRule;

      case SBML_RATE_RULE:
        return SWIGTYPE_p_RateRule;

      case SBML_DELAY:
        return SWIGTYPE_p_Delay;

      case SBML_TRIGGER:
        return SWIGTYPE_p_Trigger;

      case SBML_STOICHIOMETRY_MATH:
       return SWIGTYPE_p_StoichiometryMath;
      
    case SBML_PRIORITY:
      return SWIGTYPE_p_Priority;
      
      default:
        return SWIGTYPE_p_SBase;
    }
  }
  
#include "local-downcast.cpp"  
  
  return SWIGTYPE_p_SBase;
}

/* Compatibility bug fix for swig 2.0.7 and Python 3. 
 * See http://patch-tracker.debian.org/patch/series/view/swig2.0/2.0.7-3/pyint_fromsize_t.diff
 */
#if (PY_MAJOR_VERSION >= 3)
#define PyInt_FromSize_t(x) PyLong_FromSize_t(x)
#endif
