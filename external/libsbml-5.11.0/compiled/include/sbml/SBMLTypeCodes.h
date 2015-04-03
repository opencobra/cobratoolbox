/**
 * @file    SBMLTypeCodes.h
 * @brief   Enumeration to identify SBML objects at runtime
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

#ifndef SBMLTypeCodes_h
#define SBMLTypeCodes_h


#include <sbml/common/libsbml-config.h>
#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * @enum  SBMLTypeCode_t
 * @brief The enumeration of possible SBML core object types.
 *
 * @copydetails doc_what_are_typecodes
 *
 * @copydetails doc_additional_typecode_details
 *
 */
typedef enum
{
      SBML_UNKNOWN                    =  0 /*!< An unknown SBase type.  The default, but will not be returned for any SBML core object, nor any fully-implemented package object. */
    , SBML_COMPARTMENT                =  1 /*!< Compartment */
    , SBML_COMPARTMENT_TYPE           =  2 /*!< CompartmentType (Note: L2 only) */
    , SBML_CONSTRAINT                 =  3 /*!< Constraint */
    , SBML_DOCUMENT                   =  4 /*!< SBMLDocument */
    , SBML_EVENT                      =  5 /*!< Event */
    , SBML_EVENT_ASSIGNMENT           =  6 /*!< EventAssignment */
    , SBML_FUNCTION_DEFINITION        =  7 /*!< FunctionDefinition */
    , SBML_INITIAL_ASSIGNMENT         =  8 /*!< InitialAssignment */
    , SBML_KINETIC_LAW                =  9 /*!< KineticLaw */
    , SBML_LIST_OF                    = 10 /*!< ListOf */
    , SBML_MODEL                      = 11 /*!< Model */
    , SBML_PARAMETER                  = 12 /*!< Parameter */
    , SBML_REACTION                   = 13 /*!< Reaction */
    , SBML_RULE                       = 14 /*!< Rule (Note: will not be returned from any getType function on any SBML core object, as it is an abstract base class only.) */
    , SBML_SPECIES                    = 15 /*!< Species */
    , SBML_SPECIES_REFERENCE          = 16 /*!< SpeciesReference */
    , SBML_SPECIES_TYPE               = 17 /*!< SpeciesType (Note: L2 only) */
    , SBML_MODIFIER_SPECIES_REFERENCE = 18 /*!< ModifierSpeciesReference */
    , SBML_UNIT_DEFINITION            = 19 /*!< UnitDefinition */
    , SBML_UNIT                       = 20 /*!< Unit */
    , SBML_ALGEBRAIC_RULE             = 21 /*!< AlgebraicRule */
    , SBML_ASSIGNMENT_RULE            = 22 /*!< AssignmentRule */
    , SBML_RATE_RULE                  = 23 /*!< RateRule */
    , SBML_SPECIES_CONCENTRATION_RULE = 24 /*!< A Rule of the L1 type SpeciesConcentrationRule */
    , SBML_COMPARTMENT_VOLUME_RULE    = 25 /*!< A Rule of the L1 type CompartmentVolumeRule */
    , SBML_PARAMETER_RULE             = 26 /*!< A Rule of the L1 type ParameterRule */
    , SBML_TRIGGER                    = 27 /*!< Trigger */
    , SBML_DELAY                      = 28 /*!< Delay */
    , SBML_STOICHIOMETRY_MATH         = 29 /*!< StoichiometryMath (Note: L2 only)*/
    , SBML_LOCAL_PARAMETER            = 30 /*!< LocalParameter */
    , SBML_PRIORITY                   = 31 /*!< Priority */
    , SBML_GENERIC_SBASE              = 32 /*!< Any SBase-derived class. Not returned by any getType function, but used internally for packages that extend the SBase class itself, in the PKGNAMEExtension classes (such as CompExtension). */
} SBMLTypeCode_t;



/**
 * This method takes an SBML type code and returns a string representing
 * the code.
 *
 * @if clike LibSBML attaches an identifying code to every kind of SBML
 * object.  These are known as <em>SBML type codes</em>.  The set of
 * possible type codes is defined in the enumeration #SBMLTypeCode_t.
 * The names of the type codes all begin with the characters @c
 * SBML_. @endif@if java LibSBML attaches an identifying code to every
 * kind of SBML object.  These are known as <em>SBML type codes</em>.  In
 * other languages, the set of type codes is stored in an enumeration; in
 * the Java language interface for libSBML, the type codes are defined as
 * static integer constants in the interface class {@link
 * libsbmlConstants}.  The names of the type codes all begin with the
 * characters @c SBML_. @endif@if python LibSBML attaches an identifying
 * code to every kind of SBML object.  These are known as <em>SBML type
 * codes</em>.  In the Python language interface for libSBML, the type
 * codes are defined as static integer constants in the interface class
 * @link libsbml@endlink.  The names of the type codes all begin with the
 * characters @c SBML_. @endif@if csharp LibSBML attaches an identifying
 * code to every kind of SBML object.  These are known as <em>SBML type
 * codes</em>.  In the C# language interface for libSBML, the type codes
 * are defined as static integer constants in the interface class @link
 * libsbml@endlink.  The names of the type codes all begin with
 * the characters @c SBML_. @endif@~
 *
 * @return a human readable name for the given
 * @if clike #SBMLTypeCode_t value@else SBML type code@endif.
 *
 * @note The caller does not own the returned string and is therefore not
 * allowed to modify it.
 *
 */
LIBSBML_EXTERN
const char *
SBMLTypeCode_toString (int tc, const char* pkgName);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* SBMLTypeCodes_h */
