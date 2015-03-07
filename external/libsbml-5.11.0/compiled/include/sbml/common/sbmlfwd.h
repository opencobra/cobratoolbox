/**
 * @file    sbmlfwd.h
 * @brief   Forward declarations for all opaque C types.
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * Declaring all types up-front avoids compilation errors of the form
 * <em>"Redefinition of type 'Foo'"</em>, and allows our combined C/C++
 * headers to depend minimally upon each other.  Put another way, the type
 * definitions below serve the same purpose as <tt>class Foo;</tt> forward
 * declarations in C++ code.
 */

#ifndef sbmlfwd_h
#define sbmlfwd_h


#include <sbml/common/libsbml-namespace.h>
#include <sbml/common/libsbml-config.h>


#ifdef __cplusplus
/**
 * Defined as a class when compiling for C++ and as a C struct when
 * compiling for C.
 */
#  define CLASS_OR_STRUCT class
#else
/**
 * Defined as a class when compiling for C++ and as a C struct when
 * compiling for C.
 */
#  define CLASS_OR_STRUCT struct
#endif  /* __cplusplus */

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @var typedef class SBase SBase_t
 * @copydoc SBase
 */
typedef CLASS_OR_STRUCT SBase                     SBase_t;

/**
 * @var typedef class SBMLDocument SBMLDocument_t
 * @copydoc SBMLDocument
 */
typedef CLASS_OR_STRUCT SBMLDocument              SBMLDocument_t;

/**
 * @var typedef class Model Model_t
 * @copydoc Model
 */
typedef CLASS_OR_STRUCT Model                     Model_t;

/**
 * @var typedef class FunctionDefinition FunctionDefinition_t
 * @copydoc FunctionDefinition
 */
typedef CLASS_OR_STRUCT FunctionDefinition        FunctionDefinition_t;

/**
 * @var typedef class Unit Unit_t
 * @copydoc Unit
 */
typedef CLASS_OR_STRUCT Unit                      Unit_t;

/**
 * @var typedef class UnitDefinition UnitDefinition_t
 * @copydoc UnitDefinition
 */
typedef CLASS_OR_STRUCT UnitDefinition            UnitDefinition_t;

/**
 * @var typedef class CompartmentType CompartmentType_t
 * @copydoc CompartmentType
 */
typedef CLASS_OR_STRUCT CompartmentType           CompartmentType_t;

/**
 * @var typedef class SpeciesType SpeciesType_t
 * @copydoc SpeciesType
 */
typedef CLASS_OR_STRUCT SpeciesType               SpeciesType_t;

/**
 * @var typedef class Compartment Compartment_t
 * @copydoc Compartment
 */
typedef CLASS_OR_STRUCT Compartment               Compartment_t;

/**
 * @var typedef class Species Species_t
 * @copydoc Species
 */
typedef CLASS_OR_STRUCT Species                   Species_t;

/**
 * @var typedef class Parameter Parameter_t
 * @copydoc Parameter
 */
typedef CLASS_OR_STRUCT Parameter                 Parameter_t;

/**
 * @var typedef class LocalParameter LocalParameter_t
 * @copydoc LocalParameter
 */
typedef CLASS_OR_STRUCT LocalParameter             LocalParameter_t;

/**
 * @var typedef class InitialAssignment InitialAssignment_t
 * @copydoc InitialAssignment
 */
typedef CLASS_OR_STRUCT InitialAssignment         InitialAssignment_t;

/**
 * @var typedef class Rule Rule_t
 * @copydoc Rule
 */
typedef CLASS_OR_STRUCT Rule                      Rule_t;

/**
 * @var typedef class Constraint Constraint_t
 * @copydoc Constraint
 */
typedef CLASS_OR_STRUCT Constraint                Constraint_t;

/**
 * @var typedef class Reaction Reaction_t
 * @copydoc Reaction
 */
typedef CLASS_OR_STRUCT Reaction                  Reaction_t;

/**
 * @var typedef class KineticLaw KineticLaw_t
 * @copydoc KineticLaw
 */
typedef CLASS_OR_STRUCT KineticLaw                KineticLaw_t;

/**
 * In C, a SpeciesReference_t is actually a synonym for the
 * SimpleSpeciesReference base class.
 */
typedef CLASS_OR_STRUCT SimpleSpeciesReference    SpeciesReference_t;

/**
 * @var typedef class Event Event_t
 * @copydoc Event
 */
typedef CLASS_OR_STRUCT Event                     Event_t;

/**
 * @var typedef class EventAssignment EventAssignment_t
 * @copydoc EventAssignment
 */
typedef CLASS_OR_STRUCT EventAssignment           EventAssignment_t;

/**
 * @var typedef class Trigger Trigger_t
 * @copydoc Trigger
 */
typedef CLASS_OR_STRUCT Trigger                   Trigger_t;

/**
 * @var typedef class Delay Delay_t
 * @copydoc Delay
 */
typedef CLASS_OR_STRUCT Delay                     Delay_t;

/**
 * @var typedef class StoichiometryMath StoichiometryMath_t
 * @copydoc StoichiometryMath
 */
typedef CLASS_OR_STRUCT StoichiometryMath          StoichiometryMath_t;

/**
 * @var typedef class Priority Priority_t
 * @copydoc Priority
 */
typedef CLASS_OR_STRUCT Priority                     Priority_t;

/**
 * @var typedef class AlgebraicRule AlgebraicRule_t
 * @copydoc AlgebraicRule
 */
typedef CLASS_OR_STRUCT AlgebraicRule                AlgebraicRule_t;

/**
 * @var typedef class AssignmentRule AssignmentRule_t
 * @copydoc AssignmentRule
 */
typedef CLASS_OR_STRUCT AssignmentRule                AssignmentRule_t;

/**
 * @var typedef class RateRule RateRule_t
 * @copydoc RateRule
 */
typedef CLASS_OR_STRUCT RateRule                RateRule_t;

/**
 * @var typedef class ModifierSpeciesReference ModifierSpeciesReference_t
 * @copydoc ModifierSpeciesReference
 */
typedef CLASS_OR_STRUCT ModifierSpeciesReference                ModifierSpeciesReference_t;

/**
 * @var typedef class SBMLReader SBMLReader_t
 * @copydoc SBMLReader
 */
typedef CLASS_OR_STRUCT SBMLReader                SBMLReader_t;

/**
 * @var typedef class SBMLWriter SBMLWriter_t
 * @copydoc SBMLWriter
 */
typedef CLASS_OR_STRUCT SBMLWriter                SBMLWriter_t;

/**
 * @var typedef class SBMLError SBMLError_t
 * @copydoc SBMLError
 */
typedef CLASS_OR_STRUCT SBMLError                 SBMLError_t;

/**
 * @var typedef class ASTNode ASTNode_t
 * @copydoc ASTNode
 */
typedef CLASS_OR_STRUCT ASTNode                   ASTNode_t;

/**
 * @var typedef class List List_t
 * @copydoc List
 */
typedef CLASS_OR_STRUCT List                      List_t;

/** @cond doxygenLibsbmlInternal */
/**
 * @var typedef class ListNode ListNode_t
 * @copydoc ListNode
 */
typedef CLASS_OR_STRUCT ListNode                  ListNode_t;
/** @endcond */

/**
 * @var typedef class ListOf ListOf_t
 * @copydoc ListOf
 */
typedef CLASS_OR_STRUCT ListOf                    ListOf_t;

/**
 * @var typedef class XMLError XMLError_t
 * @copydoc XMLError
 */
typedef CLASS_OR_STRUCT XMLError                  XMLError_t;

/**
 * @var typedef class XMLErrorLog XMLErrorLog_t
 * @copydoc XMLErrorLog
 */
typedef CLASS_OR_STRUCT XMLErrorLog               XMLErrorLog_t;

/**
 * @var typedef class XMLNode XMLNode_t
 * @copydoc XMLNode
 */
typedef CLASS_OR_STRUCT XMLNode                   XMLNode_t;

/**
 * @var typedef class XMLAttributes XMLAttributes_t
 * @copydoc XMLAttributes
 */
typedef CLASS_OR_STRUCT XMLAttributes             XMLAttributes_t;

/**
 * @var typedef class XMLNamespaces XMLNamespaces_t
 * @copydoc XMLNamespaces
 */
typedef CLASS_OR_STRUCT XMLNamespaces		  XMLNamespaces_t;

/**
 * @var typedef class XMLToken XMLToken_t
 * @copydoc XMLToken
 */
typedef CLASS_OR_STRUCT XMLToken                  XMLToken_t;

/** @cond doxygenLibsbmlInternal */
/**
 * @var typedef class XMLInputStream XMLInputStream_t
 * @copydoc XMLInputStream
 */
typedef CLASS_OR_STRUCT XMLInputStream            XMLInputStream_t;
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * @var typedef class XMLOutputStream XMLOutputStream_t
 * @copydoc XMLOutputStream
 */
typedef CLASS_OR_STRUCT XMLOutputStream           XMLOutputStream_t;
/** @endcond */

/**
 * @var typedef class XMLTriple XMLTriple_t
 * @copydoc XMLTriple
 */
typedef CLASS_OR_STRUCT XMLTriple                 XMLTriple_t;

/**
 * @var typedef class CVTerm CVTerm_t
 * @copydoc CVTerm
 */
typedef CLASS_OR_STRUCT CVTerm                    CVTerm_t;

/**
 * @var typedef class Date Date_t
 * @copydoc Date
 */
typedef CLASS_OR_STRUCT Date                      Date_t;

/**
 * @var typedef class ModelCreator ModelCreator_t
 * @copydoc ModelCreator
 */
typedef CLASS_OR_STRUCT ModelCreator              ModelCreator_t;

/**
 * @var typedef class ModelHistory ModelHistory_t
 * @copydoc ModelHistory
 */
typedef CLASS_OR_STRUCT ModelHistory              ModelHistory_t;

/**
 * @var typedef class SBMLNamespaces SBMLNamespaces_t
 * @copydoc SBMLNamespaces
 */
typedef CLASS_OR_STRUCT SBMLNamespaces            SBMLNamespaces_t;

/**
 * @var typedef class SBaseExtensionPoint SBaseExtensionPoint_t
 * @copydoc SBaseExtensionPoint
 */
typedef CLASS_OR_STRUCT SBaseExtensionPoint       SBaseExtensionPoint_t;

/**
 * @var typedef class SBMLExtension SBMLExtension_t
 * @copydoc SBMLExtension
 */
typedef CLASS_OR_STRUCT SBMLExtension             SBMLExtension_t;

/**
 * @var typedef class SBasePluginCreatorBase SBasePluginCreatorBase_t
 */
typedef CLASS_OR_STRUCT SBasePluginCreatorBase    SBasePluginCreatorBase_t;


/**
 * @var typedef class SBMLExtensionNamespaces SBMLExtensionNamespaces_t
 * @copydoc SBMLExtensionNamespaces
 */
typedef CLASS_OR_STRUCT ISBMLExtensionNamespaces    SBMLExtensionNamespaces_t;

/**
 * @var typedef class ExpectedAttributes ExpectedAttributes_t
 */
typedef CLASS_OR_STRUCT ExpectedAttributes    ExpectedAttributes_t;


/**
 * @var typedef class SBasePlugin    SBasePlugin_t
 */
typedef CLASS_OR_STRUCT SBasePlugin    SBasePlugin_t;

/**
 * @var typedef class SBMLDocumentPlugin SBMLDocumentPlugin_t
 * @copydoc SBMLDocumentPlugin
 */
typedef CLASS_OR_STRUCT SBMLDocumentPlugin    SBMLDocumentPlugin_t;

/**
 * @var typedef class L3ParserSettings L3ParserSettings_t
 */
typedef CLASS_OR_STRUCT L3ParserSettings    L3ParserSettings_t;


/**
 * @var typedef class ConversionOption ConversionOption_t
 */
typedef CLASS_OR_STRUCT ConversionOption    ConversionOption_t;

/**
 * @var typedef class ConversionProperties ConversionProperties_t
 */
typedef CLASS_OR_STRUCT ConversionProperties    ConversionProperties_t;

/**
 * @var typedef class ConversionProperties ConversionProperties_t
 */
typedef CLASS_OR_STRUCT IdentifierTransformer    IdentifierTransformer_t;

/**
 * @var typedef class ElementTransformer ElementTransformer_t
 */
typedef CLASS_OR_STRUCT ElementTransformer    ElementTransformer_t;


LIBSBML_CPP_NAMESPACE_END

#undef CLASS_OR_STRUCT

#endif  /* sbmlfwd_h  */
