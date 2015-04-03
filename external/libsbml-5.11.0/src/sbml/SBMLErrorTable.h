/**
 * @file    SBMLErrorTable.h
 * @brief   Represents SBML errors and other diagnostics
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
 * ---------------------------------------------------------------------- -->*/

#include <string>
#include <iostream>
#include <sstream>

#include <sbml/xml/XMLError.h>
#include <sbml/SBMLError.h>


LIBSBML_CPP_NAMESPACE_BEGIN

/** @cond doxygenLibsbmlInternal */
typedef struct {
  const char * ref_l1;
  const char * ref_l2v1;
  const char * ref_l2v2;
  const char * ref_l2v3;
  const char * ref_l2v4;
  const char * ref_l3v1;
} referenceEntry;


typedef struct {
  unsigned int code;
  const char*  shortMessage;
  unsigned int category;
  unsigned int l1v1_severity;
  unsigned int l1v2_severity;
  unsigned int l2v1_severity;
  unsigned int l2v2_severity;
  unsigned int l2v3_severity;
  unsigned int l2v4_severity;
  unsigned int l3v1_severity;
  const char*  message;
  referenceEntry reference;
} sbmlErrorTableEntry;


static const sbmlErrorTableEntry errorTable[] =
{
  // 10000
  { UnknownError, 
    "Encountered unknown internal libSBML error",
    LIBSBML_CAT_INTERNAL, 
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    LIBSBML_SEV_FATAL,
    "Unrecognized error encountered by libSBML" },

  //10101
  {
    NotUTF8,
    "File does not use UTF-8 encoding",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An SBML XML file must use UTF-8 as the character encoding. More "
    "precisely, the 'encoding' attribute of the XML declaration at the "
    "beginning of the XML data stream cannot have a value other than "
    "'UTF-8'. An example valid declaration is "
    "'<?xml version=\"1.0\" encoding=\"UTF-8\"?>'.",
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //10102
  {
    UnrecognizedElement,
    "Encountered unrecognized element",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An SBML XML document must not contain undefined elements or attributes "
    "in the SBML namespace. Documents containing unknown elements or "
    "attributes placed in the SBML namespace do not conform to the SBML "
    "specification.",  
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //10103
  {
    NotSchemaConformant,
    "Document does not conform to the SBML XML schema",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An SBML XML document must conform to the XML Schema for the corresponding "
    "SBML Level, Version and Release. The XML Schema for SBML defines the "
    "basic SBML object structure, the data types used by those objects, and the "
    "order in which the objects may appear in an SBML document.",
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     ""}
  },

  //10104
  {
    L3NotSchemaConformant,
    "Document is not well-formed XML",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An SBML document must conform to the rules of XML well-formedness "
    "defined in the XML 1.0 specification. These rules define the basic "
    "structural and syntactic constraints with which all XML documents "
    "must comply.",
    {"",
     "",
     "",
     "",
     "",
     ""}
  },

  //10201
  {
    InvalidMathElement,
    "Invalid MathML",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "All MathML content in SBML must appear within a <math> element, and the "
    "<math> element must be either explicitly or implicitly in the XML "
    "namespace \"http://www.w3.org/1998/Math/MathML\".",
    {"",
     "",
     "L2V2 Section 3.5",
     "L2V3 Section 3.4",
     "L2V4 Section 3.4",
     "L3V1 Section 3.4"}
  },

  //10202
  {
    DisallowedMathMLSymbol,
    "Disallowed MathML symbol found",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The only permitted MathML 2.0 elements in SBML Level 2 are "
    "the following: <cn>, <ci>, <csymbol>, <sep>, <apply>, <piecewise>, "
    "<piece>, <otherwise>, <eq>, <neq>, <gt>, <lt>, <geq>, <leq>, <plus>, "
    "<minus>, <times>, <divide>, <power>, <root>, <abs>, <exp>, <ln>, <log>, "
    "<floor>, <ceiling>, <factorial>, <and>, <or>, <xor>, <not>, <degree>, "
    "<bvar>, <logbase>, <sin>, <cos>, <tan>, <sec>, <csc>, <cot>, <sinh>, "
    "<cosh>, <tanh>, <sech>, <csch>, <coth>, <arcsin>, <arccos>, <arctan>, "
    "<arcsec>, <arccsc>, <arccot>, <arcsinh>, <arccosh>, <arctanh>, "
    "<arcsech>, <arccsch>, <arccoth>, <true>, <false>, <notanumber>, <pi>, "
    "<infinity>, <exponentiale>, <semantics>, <annotation>, and "
    "<annotation-xml>. ",
    {"",
     "",
     "L2V2 Section 3.5.1",
     "L2V3 Section 3.4.1",
     "L2V4 Section 3.4.1",
     "L3V1 Section 3.4.1"}
  },

  //10203
  {
    DisallowedMathMLEncodingUse,
    "Use of the MathML 'encoding' attribute is not allowed on this element",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In the SBML subset of MathML 2.0, the MathML attribute "
    "'encoding' is only permitted on <csymbol>. No other MathML elements may "
    "have an 'encoding' attribute. ",
    {"",
     "",
     "L2V2 Section 3.5.1",
     "L2V3 Section 3.4.1",
     "L2V4 Section 3.4.1",
     "L3V1 Section 3.4.1"}
  },

  //10204
  { /**
      * This is a rule that was not implemented in libSBML-2.3.4
      Category_* To be strictly in line with sbml specifications it should
      * only allow semantics on csymbol until l2v3 rel 2
      * BUT since no one ever applied it anyway I havent implemented
      * this as it would require a separate rule that then
      * reverted to this id
      */
    DisallowedDefinitionURLUse,
    "Use of the MathML 'definitionURL' attribute is not allowed on this element",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In the SBML subset of MathML 2.0, the MathML attribute "
    "'definitionURL' is only permitted on <csymbol>, <semantics> or <ci> (Level 3 only). "
    "No other MathML elements may have a 'definitionURL' attribute. ",
    {"",
     "",
     "L2V2 Section 3.5.1",
     "L2V3 Section 3.4.1",
     "L2V4 Section 3.4.1",
     "L3V1 Section 3.4.1"}
  },

  //10205
  {
    BadCsymbolDefinitionURLValue,
    "Invalid <csymbol> 'definitionURL' attribute value",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In SBML Level 2, the only values permitted for 'definitionURL' on "
    "a <csymbol> element are \"http://www.sbml.org/sbml/symbols/time\" "
    "and \"http://www.sbml.org/sbml/symbols/delay\". SBML Level 3 added "
    "\"http://www.sbml.org/sbml/symbols/avogadro\". ", 
    {"",
     "",
     "L2V2 Section 3.5.5",
     "L2V3 Section 3.4.6",
     "L2V4 Section 3.4.6",
     "L3V1 Section 3.4.6"}
  },

  //10206
  {
    DisallowedMathTypeAttributeUse,
    "Use of the MathML 'type' attribute is not allowed on this element",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In the SBML subset of MathML 2.0, the MathML attribute "
    "'type' is only permitted on the <cn> construct. No other MathML elements "
    "may have a 'type' attribute.",
    {"",
     "",
     "L2V2 Section 3.5.1",
     "L2V3 Section 3.4.1",
     "L2V4 Section 3.4.1",
     "L3V1 Section 3.4.1"}
  },

  //10207
  {
    DisallowedMathTypeAttributeValue,
    "Disallowed MathML 'type' attribute value",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The only permitted values for the 'type' attribute on MathML <cn> "
    "elements are 'e-notation', 'real', 'integer', and 'rational'. ",
    {"",
     "",
     "L2V2 Section 3.5.2",
     "L2V3 Section 3.4.2",
     "L2V4 Section 3.4.2",
     "L3V1 Section 3.4.2"}
  },

  //10208
  {
    LambdaOnlyAllowedInFunctionDef,
    "Use of <lambda> not permitted outside of FunctionDefinition objects",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "MathML <lambda> elements are only permitted as the first element inside "
    "the 'math' element of a <functionDefinition> or as the first element "
    "of a semantics element immediately inside inside the math element "
    "of a <functionDefinition>; they may not be used "
    "elsewhere in an SBML model.",
    {"",
     "",
     "L2V2 Sections 3.5.1 and 4.3",
     "L2V3 Sections 3.4.1 and 4.3.2",
     "L2V4 Sections 3.4.1 and 4.3.2",
     "L3V1 Sections 3.4.1 and 4.3.2"}
  },

  //10209
  {
    BooleanOpsNeedBooleanArgs,
    "Non-Boolean argument given to Boolean operator",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The arguments of the MathML logical operators <and>, <or>, <xor>, and "
    "<not> must have Boolean values.",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //10210
  {
    NumericOpsNeedNumericArgs,
    "Non-numerical argument given to numerical operator",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The arguments to the following MathML constructs must have a numeric "
    "type: <plus>, <minus>, <times>, <divide>, <power>, <root>, <abs>, "
    "<exp>, <ln>, <log>, <floor>, <ceiling>, <factorial>, <sin>, <cos>, "
    "<tan>, <sec>, <csc>, <cot>, <sinh>, <cosh>, <tanh>, <sech>, <csch>, "
    "<coth>, <arcsin>, <arccos>, <arctan>, <arcsec>, <arccsc>, <arccot>, "
    "<arcsinh>, <arccosh>, <arctanh>, <arcsech>, <arccsch>, <arccoth>. ",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //10211
  {
    ArgsToEqNeedSameType,
    "Arguments to <eq> and <neq> must have the same data types",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The values of all arguments to <eq> and <neq> operators must have the "
    "same type (either all Boolean or all numeric). ",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //10212
  {
    PiecewiseNeedsConsistentTypes,
    "Terms in a <piecewise> expression must have consistent data types",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The types of values within <piecewise> operators must all be "
    "consistent: the set of expressions that make up the first arguments of "
    "the <piece> and <otherwise> operators within the same <piecewise> "
    "operator should all return values of the same type.",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //10213
  {
    PieceNeedsBoolean,
    "The second argument of a <piece> expression must yield a Boolean value",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The second argument of a MathML <piece> operator must have a Boolean "
    "value. ",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //10214
  {
    ApplyCiMustBeUserFunction,
    "A <ci> element in this context must refer to a function definition",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Outside of a <functionDefinition>, if a <ci> element is the first "
    "element within a MathML <apply>, then the <ci>'s value can only be "
    "chosen from the set of identifiers of <functionDefinition>s defined in "
    "the SBML model.",
    {"",
     "",
     "L2V2 Section 4.3.2",
     "L2V3 Section 4.3.2",
     "L2V4 Section 4.3.2",
     "L3V1 Section 4.3.2"}
  },

  //10215
  {
    ApplyCiMustBeModelComponent,
    "A <ci> element in this context must refer to a model component",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Outside of a <functionDefinition>, if a <ci> element is not the first "
    "element within a MathML <apply>, then the <ci>'s value can only be "
    "chosen from the set of identifiers of <species>, <compartment>, "
    "<parameter>, <reaction>, or (in Level 3) <speciesReference> objects defined in the SBML model. (In L2V1, the "
    "<ci>'s value can't be chosen from the identifiers of <reaction> objects). ",
    {"",
     "",
     "L2V2 Section 3.5.4",
     "L2V3 Section 3.4.3",
     "L2V4 Section 3.4.3",
     "L3V1 Section 3.4.3"}
  },

  //10216
  {
    KineticLawParametersAreLocalOnly,
    "Cannot use a KineticLaw local parameter outside of its local scope",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The 'id' value of a <parameter> defined within a <kineticLaw> can only "
    "be used in <ci> elements within the MathML content of that same "
    "<kineticLaw>; the identifier is not visible to other parts of the "
    "model. ",
    {"",
     "",
     "L2V2 Sections 3.4.1, 3.5.3 and 4.13.5",
     "L2V3 Sections 3.3.1, 3.4.3 and 4.13.5",
     "L2V4 Sections 3.3.1, 3.4.3 and 4.13.5",
     "L3V1 Sections 3.3.1, 3.4.3 and 4.13.5"}
  },

  //10217
  {
    MathResultMustBeNumeric,
    "A formula's result in this context must be a numerical value",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The MathML formulas in the following elements must yield numeric "
    "expressions: <math> in <kineticLaw>, <stoichiometryMath> in "
    "<speciesReference>, <math> in <initialAssignment>, <math> in "
    "<assignmentRule>, <math> in <rateRule>, <math> in <algebraicRule>, and "
    "<delay> in <event>, and <math> in <eventAssignment>. ",
    {"",
     "",
     "L2V2 Sections 4.10, 4.11, 4.12 and 4.13",
     "L2V3 Sections 4.10, 4.11, 4.12 and 4.13",
     "L2V4 Sections 4.10, 4.11, 4.12 and 4.13",
     "L3V1 Sections 4.8, 4.9, 4.11 and 4.12"}
  },

  //10218
  {
    OpsNeedCorrectNumberOfArgs,
    "Incorrect number of arguments given to MathML operator",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A MathML operator must be supplied the number of arguments "
    "appropriate for that operator.",
    {"",
     "",
     "L2V2 Section 3.5.1",
     "L2V3 Section 3.4.1",
     "L2V4 Section 3.4.1",
     "L3V1 Section 3.4.1"}
  },

  //10219
  {
    InvalidNoArgsPassedToFunctionDef,
    "Incorrect number of arguments given to function invocation",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The number of arguments used in a call to a function defined by a "
    "<functionDefinition> must equal the number of arguments accepted by "
    "that function, or in other words, the number of <bvar> elements "
    "inside the <lambda> element of the function definition.  ",
    {"",
     "",
     "",
     "",
     "L2V4 Section 4.3.4",
     "L3V1 Section 4.3.4"}
  },

  //10220
  {
    DisallowedMathUnitsUse,
    "Attribute 'units' is only permitted on <cn> elements",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The SBML attribute 'units' may only be added to MathML <cn> elements; "
    "no other MathML elements are permitted to have the 'units' attribute. ",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.4.2"}
  },

  //10221
  {
    InvalidUnitsValue,
    "Invalid value given for the 'units' attribute",
    LIBSBML_CAT_MATHML_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The value of the SBML attribute 'units' on a MathML <cn> element must "
    "be chosen from either the set of identifiers of UnitDefinition "
    "objects in the model, or the set of base units defined by SBML. ",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.4.2"}
  },

  //10301
  {
    DuplicateComponentId,
    "Duplicate 'id' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'id' field on every instance of the following type of "
    "object in a model must be unique: <model>, <functionDefinition>, "
    "<compartmentType>, <compartment>, <speciesType>, <species>, <reaction>, "
    "<speciesReference>, <modifierSpeciesReference>, <event>, and model-wide "
    "<parameter>s. Note that <unitDefinition> and parameters defined inside "
    "a reaction are treated separately. ",
    {"",
     "L2V1 Section 3.5",
     "L2V2 Section 3.4.1",
     "L2V3 Section 3.3",
     "L2V4 Section 3.3",
     "L3V1 Section 3.3"}
  },

  //10302
  {
    DuplicateUnitDefinitionId,
    "Duplicate unit definition 'id' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'id' field of every <unitDefinition> must be unique "
    "across the set of all <unitDefinition>s in the entire model. ",
    {"",
     "L2V1 Sections 3.5 and 4.4",
     "L2V2 Sections 3.4.1 and 4.4",
     "L2V3 Sections 3.3 and 4.4",
     "L2V4 Sections 3.3 and 4.4",
     "L3V1 Sections 3.3 and 4.4"}
  },

  //10303
  {
    DuplicateLocalParameterId,
    "Duplicate local parameter 'id' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'id' field of each parameter defined locally within a "
    "<kineticLaw> must be unique across the set of all such parameter "
    "definitions in that <kineticLaw>.",
    {"",
     "L2V1 Sections 3.4.1 and 4.13.9",
     "L2V2 Sections 3.4.1 and 4.13.5",
     "L2V3 Sections 3.3.1 and 4.13.5",
     "L2V4 Sections 3.3.1 and 4.13.5",
     "L3V1 Sections 3.3.1 and 4.11.5"}
  },

  //10304
  {
    MultipleAssignmentOrRateRules,
    "Multiple rules for the same variable are not allowed",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'variable' field in all <assignmentRule> and "
    "<rateRule> definitions must be unique across the set of all such rule "
    "definitions in a model.",
    {"",
     "L2V1 Section 4.8.4",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //10305
  {
    MultipleEventAssignmentsForId,
    "Multiple event assignments for the same variable are not allowed",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In each <event>, the value of the 'variable' field within every "
    "<eventAssignment> definition must be unique across the set of all "
    "<eventAssignment>s within that <event>.",
    {"",
     "L2V1 erratum 17",
     "L2V2 Section 4.14.2",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //10306
  {
    EventAndAssignmentRuleForId,
    "An event assignment and an assignment rule must not have the same value for 'variable'",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An identifier used as the value of 'variable' in an <eventAssignment> "
    "cannot also appear as the value of 'variable' in an <assignmentRule>. ",
    {"",
     "L2V1 Section 4.10.5",
     "L2V2 Section 4.14",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //10307
  {
    DuplicateMetaId,
    "Duplicate 'metaid' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Every 'metaid' attribute value must be unique across the set of all "
    "'metaid' values in a model.",
    {"",
     "",
     "L2V2 Sections 3.3.1 and 3.1.6",
     "L2V3 Sections 3.1.6 and 3.2.1",
     "L2V4 Sections 3.1.6 and 3.2.1",
     "L3V1 Sections 3.1.6 and 3.2.1"}
  },

  //10308
  {
    InvalidSBOTermSyntax,
    "Invalid syntax for an 'sboTerm' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of an 'sboTerm' attribute must have the data type 'SBOTerm', "
    "which is a string consisting of the characters 'S', 'B', 'O', ':' "
    "followed by exactly seven digits.",
    {"",
     "",
     "L2V2 Section 3.1.9",
     "L2V3 Section 3.1.9",
     "L2V4 Section 3.1.9",
     "L3V1 Section 3.1.11"}
  },

  //10309
  {
    InvalidMetaidSyntax,
    "Invalid syntax for a 'metaid' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The syntax of 'metaid' attribute values must conform to the syntax of the "
    "XML type 'ID'.", 
    {"",
     "",
     "L2V2 Sections 3.3.1 and 3.1.6",
     "L2V3 Sections 3.2.1 and 3.1.6",
     "L2V4 Sections 3.2.1 and 3.1.6",
     "L3V1 Sections 3.2.1 and 3.1.6"}
  },

  //10310
  {
    InvalidIdSyntax,
    "Invalid syntax for an 'id' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The syntax of 'id' attribute values must conform to the syntax of the SBML "
    "type 'SId'.", 
    {"",
     "",
     "L2V2 Section 3.1.7",
     "L2V3 Section 3.1.7",
     "L2V4 Section 3.1.7",
     "L3V1 Section 3.1.7"}
},

  //10311
  {
    InvalidUnitIdSyntax,
    "Invalid syntax for the identifier of a unit",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The syntax of unit identifiers (i.e., the values of the 'id' attribute "
    "on UnitDefinition, the 'units' attribute on Compartment, the 'units' "
    "attribute on Parameter, and the 'substanceUnits' attribute on Species) "
    "must conform to the syntax of the SBML type UnitSId.",
    {"",
     "",
     "",
     "L2V3 Section 3.1.8",
     "L2V4 Section 3.1.8",
     "L3V1 Section 3.1.9"}
  },

  //10312
  {
    InvalidNameSyntax,
    "Invalid syntax for a 'name' attribute value",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Message", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.1.1"}
},

  //10401
  {
    MissingAnnotationNamespace,
    "Missing declaration of the XML namespace for the annotation",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Every top-level element within an annotation element must "
    "have a namespace declared.",
    {"",
     "",
     "L2V2 Section 3.3.3",
     "L2V3 Section 3.2.4",
     "L2V4 Section 3.2.4",
     "L3V1 Section 3.2.4"}
  },

  //10402
  {
    DuplicateAnnotationNamespaces,
    "Multiple annotations using the same XML namespace",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "There cannot be more than one top-level element using a "
    "given namespace inside a given annotation element. ", 
    {"",
     "",
     "L2V2 Section 3.3.3",
     "L2V3 Section 3.2.4",
     "L2V4 Section 3.2.4",
     "L3V1 Section 3.2.4"}
  },

  //10403
  {
    SBMLNamespaceInAnnotation,
    "The SBML XML namespace cannot be used in an Annotation object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Top-level elements within an annotation element cannot use any SBML "
    "namespace, whether explicitly (by declaring the namespace to be one of "
    "the URIs \"http://www.sbml.org/sbml/level1\", "
    "\"http://www.sbml.org/sbml/level2\", "
    "\"http://www.sbml.org/sbml/level2/version2\", or "
    "\"http://www.sbml.org/sbml/level2/version3\", or "
    "\"http://www.sbml.org/sbml/level2/version4\", or implicitly (by failing "
    "to declare any namespace).",
    {"",
     "",
     "L2V2 Section 3.3.3",
     "L2V3 Section 3.2.4",
     "L2V4 Section 3.2.4",
     ""}
  },

  //10404
  {
    MultipleAnnotations,
    "Only one Annotation object is permitted under a given SBML object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A given SBML object may contain at most one <annotation> element.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.2"}
  },

  //10501
  {
    InconsistentArgUnits,
    "The units of the function call's arguments are not consistent with its definition",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The units of the expressions used as arguments to a function call are expected to "
    "match the units expected for the arguments of that function. ",
    {"",
     "",
     "L2V2 Section 3.5",
     "L2V3 Section 3.4",
     "L2V4 Section 3.4",
     "L3V1 Section 3.4"}
  },

  //10503
  {
    InconsistentKineticLawUnitsL3,
    "The kinetic law's units are inconsistent with those of other kinetic laws in the model",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The unit of measurement associated with the mathematical formula in the "
    "MathML math element of every KineticLaw object in a model should be "
    "identical to all KineticLaw objects in the model.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.4"}
},

  //10511
  {
    AssignRuleCompartmentMismatch,
    "Mismatched units in assignment rule for compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <assignmentRule> refers to a <compartment>, "
    "the units of the rule's right-hand side are expected to be consistent with the "
    "units of that compartment's size. ",
    {"",
     "",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //10512
  {
    AssignRuleSpeciesMismatch,
    "Mismatched units in assignment rule for species",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <assignmentRule> refers to a <species>, the "
    "units of the rule's right-hand side are expected to be consistent with the units "
    "of the species' quantity.",
    {"",
     "",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //10513
  {
    AssignRuleParameterMismatch,
    "Mismatched units in assignment rule for parameter",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <assignmentRule> refers to a <parameter>, the "
    "units of the rule's right-hand side are expected to be consistent with the units "
    "declared for that parameter. ",
    {"",
     "",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //10514
  {
    AssignRuleStoichiometryMismatch,
    "Mismatched units in assignment rule for stoichiometry",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "When the value of the attribute variable in an AssignmentRule object "
    "refers to a SpeciesReference object, the unit of measurement associated "
    "with the rule's right-hand side should be consistent with the unit of "
    "stoichiometry, that is, dimensionless.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.9.3"}
},

  //10521
  {
    InitAssignCompartmenMismatch,
    "Mismatched units in initial assignment to compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <initialAssignment> refers to a "
    "<compartment>, the units of the <initialAssignment>'s <math> expression "
    "are expected to be consistent with the units of that compartment's size. ",
    {"",
     "",
     "L2V2 Section 4.10.4",
     "L2V3 Section 4.10",
     "L2V4 Section 4.10",
     "L3V1 Section 4.8"}
  },

  //10522
  {
    InitAssignSpeciesMismatch,
    "Mismatched units in initial assignment to species",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <initialAssignment> refers to a <species>, "
    "the units of the <initialAssignment>'s <math> expression are expected to be "
    "consistent with the units of that species' quantity.",
    {"",
     "",
     "L2V2 Section 4.10.4",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.8"}
  },

  //10523
  {
    InitAssignParameterMismatch,
    "Mismatched units in initial assignment to parameter",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <initialAssignment> refers to a <parameter>, "
    "the units of the <initialAssignment>'s <math> expression are expected to be "
    "consistent with the units declared for that parameter.",
    {"",
     "",
     "L2V2 Section 4.10.4",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.8"}
  },

  //10524
  {
    InitAssignStoichiometryMismatch,
    "Mismatched units in initial assignment to stoichiometry",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "When the value of the attribute variable in an InitialAssignment object "
    "refers to a SpeciesReference object, the unit of measurement associated "
    "with the InitialAssignment's math expression should be consistent with "
    "the unit of stoichiometry, that is, dimensionless.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.8"}
},

  //10531
  {
    RateRuleCompartmentMismatch,
    "Mismatched units in rate rule for compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in a <rateRule> definition refers to a "
    "<compartment>, the units of the rule's right-hand side are expected to be of the "
    "form _x per time_, where _x_ is either the 'units' in that "
    "<compartment> definition, or (in the absence of explicit units declared "
    "for the compartment size) the default units for that compartment, and "
    "_time_ refers to the units of time for the model.",
    {"",
     "",
     "L2V2 Section 4.11.4",
     "L2V3 Section 4.11.4",
     "L2V4 Section 4.11.4",
     "L3V1 Sections 4.5.4, 4.2.4 AND 4.9.4"}
  },

  //10532
  {
    RateRuleSpeciesMismatch,
    "Mismatched units in rate rule for species",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in a <rateRule> definition refers to a <species>, "
    "the units of the rule's right-hand side are expected to be of the form _x per "
    "time_, where _x_ is the units of that species' quantity, and _time_ "
    "refers to the units of time for the model.",
    {"",
     "",
     "L2V2 Section 4.11.4",
     "L2V3 Section 4.11.4",
     "L2V4 Section 4.11.4",
     "L3V1 Sections 4.6.5, 4.2.4 AND 4.9.4"}
  },

  //10533
  {
    RateRuleParameterMismatch,
    "Mismatched units in rate rule for parameter",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in a <rateRule> definition refers to a <parameter>, "
    "the units of the rule's right-hand side are expected to be of the form _x per "
    "time_, where _x_ is the 'units' in that <parameter> definition, and "
    "_time_ refers to the units of time for the model.",
    {"",
     "",
     "L2V2 Section 4.11.4",
     "L2V3 Section 4.11.4",
     "L2V4 Section 4.11.4",
     "L3V1 Sections 4.7.3, 4.2.4 AND 4.9.4"}
  },

  //10534
  {
    RateRuleStoichiometryMismatch,
    "Mismatched units in rate rule for stoichiometry",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "When the value of the attribute variable in a RateRule object refers to "
    "a SpeciesReference object, the unit of measurement associated with the "
    "RateRule's math expression should be consistent with {unit derived from "
    "dimensionless}/{unit of time}.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Sections 4.11.3, 4.2.4 and 4.9.4"}
},

  //10541
  {
    KineticLawNotSubstancePerTime,
    "The units of the kinetic law are not 'substance'/'time'",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The units of the 'math' formula in a <kineticLaw> definition are expected to be "
    "the equivalent of _substance per time_.",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "L2V3 Section 4.13.5",
     "L2V4 Section 4.13.5",
     "L3V1 Sections 4.11.7, 4.2.4 AND 4.9.4"}
  },

  //10542
  {
    SpeciesInvalidExtentUnits,
    "The species' units are not consistent with units of extent",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "For every Species object produced or consumed in a reaction (that is, "
    "referenced by a SpeciesReference object), the unit of measurement of the "
    "species' substance should be consistent with the unit of extent for the "
    "model times the unit of the conversion factor for that species. More "
    "precisely, the product of the units indicated by the Model object's "
    "extentUnits and the conversionFactor attribute for that particular "
    "Species (whether the attribute is set directly on the Species object or "
    "inherited from the enclosing Model object) should be consistent with the "
    "unit specified by that Species object's substanceUnits attribute value.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.6"}
},

  //10551
  {
    DelayUnitsNotTime,
    "The units of the delay expression are not units of time",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When a value for <delay> is given in a <event> definition, the units of "
    "the delay formula are expected to correspond to either the value of 'timeUnits' in "
    "the <event> or (if no 'timeUnits' are given), the model's default units "
    "of time.",
    {"",
     "",
     "L2V2 Section 4.14",
     "L2V3 Section 4.14.3",
     "L2V4 Section 4.14.3",
     "L3V1 Section 4.12.3"}
  },

  //10561
  {
    EventAssignCompartmentMismatch,
    "Mismatched units in event assignment for compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <eventAssignment> refers to a <compartment>, "
    "the units of the <eventAssignment>'s <math> expression are expected to be consistent "
    "with the units of that compartment's size.",
    {"",
     "",
     "L2V2 Section 4.14.2",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //10562
  {
    EventAssignSpeciesMismatch,
    "Mismatched units in event assignment for species",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <eventAssignment> refers to a <species>, the "
    "units of the <eventAssignment>'s <math> expression are expected to be consistent "
    "with the units of the species' quantity.",
    {"",
     "",
     "L2V2 Section 4.14.2",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //10563
  {
    EventAssignParameterMismatch,
    "Mismatched units in event assignment for parameter",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "When the 'variable' in an <eventAssignment> refers to a <parameter>, the "
    "units of the <eventAssignment>'s <math> expression are expected to be consistent "
    "with the units declared for that parameter.",
    {"",
     "",
     "L2V2 Section 4.14.2",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //10564
  {
    EventAssignStoichiometryMismatch,
    "Mismatched units in event assignment for stoichiometry",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "When the value of the attribute variable of an EventAssignment object "
    "is the identifier of a SpeciesReference object, the unit of measurement "
    "associated with the EventAssignment's math expression should be "
    "consistent with the unit of stoichiometry, i.e., dimensionless.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12.4"}
},

  //10565
  {
    PriorityUnitsNotDimensionless,
    "The units of a priority expression must be 'dimensionless'",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "In an Event object, the unit of measurement associated with a Priority "
    "object's <math> expression object should be 'dimensionless'. ",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12.3"}
  },

  //10599
  {
    UpperUnitBound,
    "Upper boundary of unit validation diagnostic codes",
    LIBSBML_CAT_INTERNAL,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "", 
    {"",
     "",
     "",
     "",
     "",
     ""}
  },

  //10601
  {
    OverdeterminedSystem,
    "The model is overdetermined",
    LIBSBML_CAT_OVERDETERMINED_MODEL,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The system of equations created from an SBML model must not be "
    "overdetermined.",
    {"",
     "",
     "L2V2 Section 4.11.5",
     "L2V3 Section 4.11.5",
     "L2V4 Section 4.11.5",
     "L3V1 Section 4.9.5"}
  },

  //10701
  {
    InvalidModelSBOTerm,
    "Invalid 'sboTerm' attribute value for a Model object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <model> is expected to "
    "be an SBO identifier (http://www.biomodels.net/SBO/).  In SBML "
    "Level 2 prior to Version 4 the value is expected to be a term "
    "derived from SBO:0000004, \"modeling framework\"; in Version 4 "
    "and above it is expected to be a term derived from SBO:0000231 "
    "\"interaction\"",
    {"",
     "",
     "L2V2 Section 4.2.1",
     "L2V3 Sections 4.2.2 and 5",
     "L2V4 Sections 4.2.2 and 5",
     "L3V1 Section 5"}
  },

  //10702
  {
    InvalidFunctionDefSBOTerm,
    "Invalid 'sboTerm' attribute value for a FunctionDefinition object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <functionDefinition> is expected to be "
    "an SBO identifier (http://www.biomodels.net/SBO/) referring to a "
    "mathematical expression (i.e., terms derived from SBO:0000064, "
    "\"mathematical expression\"). ",
    {"",
     "",
     "L2V2 Section 4.3.3",
     "L2V3 Sections 4.3.3 and 5",
     "L2V4 Sections 4.3.3 and 5",
     "L3V1 Section 5"}
  },

  //10703
  {
    InvalidParameterSBOTerm,
    "Invalid 'sboTerm' attribute value for a Parameter object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <parameter> is expected to be an "
    "SBO identifier (http://www.biomodels.net/SBO/) referring to a "
    "quantitative parameter defined in SBO (i.e., terms derived from "
    "SBO:0000002, \"quantitative parameter\"). ",
    {"",
     "",
     "L2V2 Section 4.9.5",
     "L2V3 Sections 4.9.5 and 5",
     "L2V4 Sections 4.9.5 and 5",
     "L3V1 Section 5"}
  },

  //10704
  {
    InvalidInitAssignSBOTerm,
    "Invalid 'sboTerm' attribute value for an InitialAssignment object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on an <initialAssignment> is expected to "
    "be an SBO identifier (http://www.biomodels.net/SBO/) referring to a "
    "mathematical expression (i.e., terms derived from SBO:0000064, "
    "\"mathematical expression\"). ",
    {"",
     "",
     "L2V2 Section 4.10.3",
     "L2V3 Sections 4.10.3 and 5",
     "L2V4 Sections 4.10.3 and 5",
     "L3V1 Section 5"}
  },

  //10705
  {
    InvalidRuleSBOTerm,
    "Invalid 'sboTerm' attribute value for a Rule object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a rule is expected to be an SBO identifier "
    "(http://www.biomodels.net/SBO/) referring to a mathematical expression "
    "(i.e., terms derived from SBO:0000064, \"mathematical expression\"). "
    "Note: This applies to Algebraic Rules in addition to Rate and Assignment "
    "Rules.",
    {"",
     "",
     "L2V2 Section 4.11.1",
     "L2V3 Sections 4.11.1 and 5",
     "L2V4 Sections 4.11.1 and 5",
     "L3V1 Section 5"}
  },

  //10706
  {
    InvalidConstraintSBOTerm,
    "Invalid 'sboTerm' attribute value for a Constraint object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <constraint> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
    "expression (i.e., terms derived from SBO:0000064, \"mathematical "
    "expression\"). ",
    {"",
     "",
     "L2V2 Section 4.12.3",
     "L2V3 Sections 4.12.3 and 5",
     "L2V4 Sections 4.12.3 and 5",
     "L3V1 Section 5"}
  },

  //10707
  {
    InvalidReactionSBOTerm,
    "Invalid 'sboTerm' attribute value for a Reaction object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <reaction> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to an interaction defined "
    "in SBO (i.e., terms derived from SBO:0000231, \"interaction\"). ",
    {"",
     "",
     "L2V2 Section 4.13.1",
     "L2V3 Sections 4.13.1 and 5",
     "L2V4 Sections 4.13.1 and 5",
     "L3V1 Section 5"}
  },

  //10708
  {
    InvalidSpeciesReferenceSBOTerm,
    "Invalid 'sboTerm' attribute value for a SpeciesReference object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <speciesReference> "
    "or <modifierSpeciesReference> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to a participant "
    "role. The appropriate term depends on whether the object is a reactant, "
    "product or modifier. If a reactant, then it should be a term in the "
    "SBO:0000010, \"reactant\" hierarchy; if a product, then it should be a "
    "term in the SBO:0000011, \"product\" hierarchy; and if a modifier, then "
    "it should be a term in the SBO:0000019, \"modifier\" hierarchy. ",
    {"",
     "",
     "L2V2 Section 4.13.2",
     "L2V3 Sections 4.13.1 and 5",
     "L2V4 Sections 4.13.1 and 5",
     "L3V1 Section 5"}
  },

  //10709
  {
    InvalidKineticLawSBOTerm,
    "Invalid 'sboTerm' attribute value for a KineticLaw object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <kineticLaw> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring rate law defined "
    "in SBO (i.e., terms derived from SBO:0000001, \"rate law\"). ",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "L2V3 Sections 4.13.1 and 5",
     "L2V4 Sections 4.13.1 and 5",
     "L3V1 Section 5"}
  },

  //10710
  {
    InvalidEventSBOTerm,
    "Invalid 'sboTerm' attribute value for an Event object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on an <event> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to an interaction "
    "defined in SBO (i.e., terms derived from SBO:0000231, \"interaction\"). ",
    {"",
     "",
     "L2V2 Section 4.14.1",
     "L2V3 Sections 4.14.1 and 5",
     "L2V4 Sections 4.14.1 and 5",
     "L3V1 Section 5"}
  },

  //10711
  {
    InvalidEventAssignmentSBOTerm,
    "Invalid 'sboTerm' attribute value for an EventAssignment object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on an <eventAssignment> is expected to be an "
    "SBO identifier (http://www.biomodels.net/SBO/) referring to a "
    "mathematical expression (i.e., terms derived from SBO:0000064, "
    "\"mathematical expression\"). ",
    {"",
     "",
     "L2V2 Section 4.14.2",
     "L2V3 Sections 4.14.1 and 5",
     "L2V4 Sections 4.14.1 and 5",
     "L3V1 Section 5"}
  },

  //10712
  {
    InvalidCompartmentSBOTerm,
    "Invalid 'sboTerm' attribute value for a Compartment object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <compartment> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/). In SBML Level 2 prior "
    "to Version 4 it is expected to refer to a participant "
    "physical type (i.e., terms derived from SBO:0000236, \"participant "
    "physical type\"); in Versions 4 and above it is expected to refer "
    "to a material entity (i.e., terms derived from SBO:0000240, "
    "\"material entity\").",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     "L3V1 Section 5"}
  },

  //10713
  {
    InvalidSpeciesSBOTerm,
    "Invalid 'sboTerm' attribute value for a Species object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <species> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/). In SBML Level 2 prior "
    "to Version 4 it is expected to refer to a participant "
    "physical type (i.e., terms derived from SBO:0000236, \"participant "
    "physical type\"); in Versions 4 and above it is expected to refer "
    "to a material entity (i.e., terms derived from SBO:0000240, "
    "\"material entity\").",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     "L3V1 Section 5"}
  },

  //10714
  {
    InvalidCompartmentTypeSBOTerm,
    "Invalid 'sboTerm' attribute value for a CompartmentType object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The value of the 'sboTerm' attribute on a <compartmentType> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/). In SBML Level 2 prior "
    "to Version 4 it is expected to refer to a participant "
    "physical type (i.e., terms derived from SBO:0000236, \"participant "
    "physical type\"); in Versions 4 and above it is expected to refer "
    "to a material entity (i.e., terms derived from SBO:0000240, "
    "\"material entity\").",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     "L3V1 Section 5"}
  },

  //10715
  {
    InvalidSpeciesTypeSBOTerm,
    "Invalid 'sboTerm' attribute value for a SpeciesType object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The value of the 'sboTerm' attribute on a <speciesType> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/). In SBML Level 2 prior "
    "to Version 4 it is expected to refer to a participant "
    "physical type (i.e., terms derived from SBO:0000236, \"participant "
    "physical type\"); in Versions 4 and above it is expected to refer "
    "to a material entity (i.e., terms derived from SBO:0000240, "
    "\"material entity\"). ",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     ""}
  },

  //10716
  {
    InvalidTriggerSBOTerm,
    "Invalid 'sboTerm' attribute value for an Event Trigger object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <trigger> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
    "expression (i.e., terms derived from SBO:0000064, \"mathematical "
    "expression\"). ",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     ""}
  },

  //10717
  {
    InvalidDelaySBOTerm,
    "Invalid 'sboTerm' attribute value for an Event Delay object",
    LIBSBML_CAT_SBO_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The value of the 'sboTerm' attribute on a <delay> is expected to be an SBO "
    "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
    "expression (i.e., terms derived from SBO:0000064, \"mathematical "
    "expression\").",
    {"",
     "",
     "",
     "L2V3 Section 5",
     "L2V4 Section 5",
     "L3V1 Section 5"}
  },

  //10801
  {
    NotesNotInXHTMLNamespace,
    "Notes must be placed in the XHTML XML namespace",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The contents of the <notes> element must be explicitly placed in the "
    "XHTML XML namespace.", 
    {"",
     "",
     "",
     "L2V3 Section 3.2.3",
     "L2V4 Section 3.2.3",
     "L3V1 Section 3.2.3"}
  },

  //10802
  {
    NotesContainsXMLDecl,
    "XML declarations are not permitted in Notes objects",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The contents of the <notes> element must not contain an XML declaration "
    "(i.e., a string of the form \"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\" "
    "or similar).",
    {"",
     "",
     "",
     "L2V3 Section 3.2.3",
     "L2V4 Section 3.2.3",
     "L3V1 Section 3.2.3"}
  },

  //10803
  {
    NotesContainsDOCTYPE,
    "XML DOCTYPE elements are not permitted in Notes objects",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The contents of the <notes> element must not contain an XML DOCTYPE "
    "declaration (i.e., a string beginning with the characters \"<!DOCTYPE\". ",
    {"",
     "",
     "",
     "L2V3 Section 3.2.3",
     "L2V4 Section 3.2.3",
     "L3V1 Section 3.2.3"}
  },

  //10804
  {
    InvalidNotesContent,
    "Invalid notes content found",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The XHTML content inside a <notes> element can only take one of the "
    "following general forms: (1) a complete XHTML document beginning with "
    "the element <html> and ending with </html>; (2) the \"body\" portion of "
    "a document beginning with the element <body> and ending with </body>; or "
    "(3) XHTML content that is permitted within a <body> ... </body> elements. ",
    {"",
     "",
     "L2V2 Section 3.3.2",
     "L2V3 Section 3.2.3",
     "L2V4 Section 3.2.3",
     ""}
  },

  //10805
  {
    OnlyOneNotesElementAllowed,
    "Only one Notes subobject is permitted on a given SBML object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A given SBML object may contain at most one <notes> element. ",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.2"}
  },

  //20101
  {
    InvalidNamespaceOnSBML,
    "Invalid XML namespace for the SBML container element",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The <sbml> container element must declare the XML Namespace for SBML, "
    "and this declaration must be consistent with the values of the 'level' "
    "and 'version' attributes on the <sbml> element. ",
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //20102
  {
    MissingOrInconsistentLevel,
    "Missing or inconsistent value for the 'level' attribute",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The <sbml> container element must declare the SBML Level using the "
    "attribute 'level', and this declaration must be consistent with the XML "
    "Namespace declared for the <sbml> element.",
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //20103
  {
    MissingOrInconsistentVersion,
    "Missing or inconsistent value for the 'version' attribute",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The <sbml> container element must declare the SBML Version using the "
    "attribute 'version', and this declaration must be consistent with the "
    "XML Namespace declared for the <sbml> element.", 
    {"",
     "",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //20104 
  {
    PackageNSMustMatch,
    "Inconsistent or invalid SBML Level/Version for the package namespace declaration",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The <sbml> container element must declare the XML Namespace for any "
    "SBML Level 3 packages used within the SBML document. This declaration "
    "must be consistent with the values of the 'level' and 'version' attributes "
    "on the <sbml> element.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.1.2"}
  },

  //20105
  {
    LevelPositiveInteger,
    "The 'level' attribute must have a positive integer value",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The attribute 'level' on the <sbml> container element must have a value "
    "of type 'positiveInteger'.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.1.4"}
  },

  //20106
  {
    VersionPositiveInteger,
    "The 'version' attribute must have a positive integer value",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The attribute 'version' on the <sbml> container element must have a value "
    "of type 'positiveInteger'.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 3.1.4"}
  },

  //20108
  {
    AllowedAttributesOnSBML,
    "Invalid attribute found on the SBML container element",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The <sbml> object may only have the optional attributes 'metaid' and 'sboTerm'.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.1"}
  },

  //20109
  {
    L3PackageOnLowerSBML,
    "An L3 package ns found on the SBML container element",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "It is not possible to use SBML L3 packages with earlier levels of SBML.",
    {"",
     "",
     "",
     "",
     "",
     ""}
  },

  //20201
  {
    MissingModel,
    "No model definition found",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An SBML document must contain a <model> element. ", 
    {"",
     "L2V1 Section 4.1",
     "L2V2 Section 4.1",
     "L2V3 Section 4.1",
     "L2V4 Section 4.1",
     "L3V1 Section 4.1"}
  },

  //20202
  {
    IncorrectOrderInModel,
    "Incorrect ordering of components within the Model object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The order of subelements within a <model> element must be the following "
    "(where any one may be optional, but the ordering must be maintained): "
    "<listOfFunctionDefinitions>, <listOfUnitDefinitions>, "
    "<listOfCompartmentTypes>, <listOfSpeciesTypes>, <listOfCompartments>, "
    "<listOfSpecies>, <listOfParameters>, <listOfInitialAssignments>, "
    "<listOfRules>, <listOfConstraints>, <listOfReactions> "
    "and <listOfEvents>. ", 
    {"",
     "",
     "L2V2 Section 4.2",
     "L2V3 Section 4.2",
     "L2V4 Section 4.2",
     ""}
  },

  //20203
  {
    EmptyListElement,
    "Empty ListOf___ object found",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The <listOf___> containers in a <model> are optional, but if present, "
    "the lists cannot be empty. Specifically, if any of the following are "
    "present in a <model>, they must not be empty: "
    "<listOfFunctionDefinitions>, <listOfUnitDefinitions>, "
    "<listOfCompartmentTypes>, <listOfSpeciesTypes>, <listOfCompartments>,  "
    "<listOfSpecies>, <listOfParameters>, <listOfInitialAssignments>, "
    "<listOfRules>, <listOfConstraints>, <listOfReactions> and "
    "<listOfEvents>.", 
    {"",
     "",
     "L2V2 Section 4.2",
     "L2V3 Section 4.2",
     "L2V4 Section 4.2",
     "L3V1 Section 4.2"}
  },

  //20204
  {
    NeedCompartmentIfHaveSpecies,
    "The presence of a species requires a compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "If a model defines any species, then the model must also define at "
    "least one compartment. This is an implication of the fact that the "
    "'compartment' attribute on the <species> element is not optional. ",
    {"",
     "L2V1 Section 4.5",
     "L2V2 Section 4.8.3",
     "L2V3 Section 4.8.3",
     "L2V4 Section 4.8.3",
     "L3V1 Section 4.6.3"}
  },

  //20205
  {
    OneOfEachListOf,
    "Only one of each kind of ListOf___ object is allowed inside a Model object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "There may be at most one instance of each of the following kind of "
    "element in a <model> object: ListOfFunctionDefinitions, "
    "ListOfUnitDefinitions, ListOfCompartments, ListOfSpecies, "
    "ListOfParameters, ListOfInitialAssignments, ListOfRules, "
    "ListOfConstraints, ListOfReactions and ListOfEvents.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2"}
  },

  //20206
  {
    OnlyFuncDefsInListOfFuncDefs,
    "Only FunctionDefinition, Notes and Annotation objects are allowed in ListOfFunctionDefinitions",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfFunctionDefinitions container object may only "
    "contain FunctionDefinition objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20207
  {
    OnlyUnitDefsInListOfUnitDefs,
    "Only UnitDefinition, Notes and Annotation objects are allowed in ListOfUnitDefinitions objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfUnitDefinitions container object may only "
    "contain UnitDefinition objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20208
  {
    OnlyCompartmentsInListOfCompartments,
    "Only Compartment, Notes and Annotation objects are allowed in ListOfCompartments objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfCompartments container object may only "
    "contain Compartment objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20209
  {
    OnlySpeciesInListOfSpecies,
    "Only Species, Notes and Annotation objects are allowed in ListOfSpecies objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfSpecies container object may only "
    "contain Species objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20210
  {
    OnlyParametersInListOfParameters,
    "Only Parameter, Notes and Annotation objects are allowed in ListOfParameters objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfParameters container object may only "
    "contain Parameter objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20211
  {
    OnlyInitAssignsInListOfInitAssigns,
    "Only InitialAssignment, Notes and Annotation objects are allowed in ListOfInitialAssignments objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfInitialAssignments container object may only "
    "contain InitialAssignment objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20212
  {
    OnlyRulesInListOfRules,
    "Only Rule, Notes and Annotation objects are allowed in ListOfRules objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfRules container object may only "
    "contain Rule objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20213
  {
    OnlyConstraintsInListOfConstraints,
    "Only Constraint, Notes and Annotation objects are allowed in ListOfConstraints objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfConstraints container object may only "
    "contain Constraint objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20214
  {
    OnlyReactionsInListOfReactions,
    "Only Reaction, Notes and Annotation objects are allowed in ListOfReactions objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfReactions container object may only "
    "contain Reaction objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20215
  {
    OnlyEventsInListOfEvents,
    "Only Event, Notes and Annotation objects are allowed in ListOfEvents objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfEvents container object may only "
    "contain Event objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20216
  {
    L3ConversionFactorOnModel,
    "A 'conversionFactor' attribute value must reference a Parameter object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The value of the attribute 'conversionFactor' on a Model object "
    "must be the identifier of an existing Parameter object defined "
    "in the Model object's ListOfParameters.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2"}
  },

  //20217
  {
    L3TimeUnitsOnModel,
    "Invalid 'timeUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute 'timeUnits' on a Model object should be either "
    "the units 'second', 'dimensionless', or the identifier of a "
    "UnitDefinition object based on these units.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.4"}
  },

  //20218
  {
    L3VolumeUnitsOnModel,
    "Invalid 'volumeUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute 'volumeUnits' on a Model object should be "
    "either the units 'litre', 'dimensionless', or the identifier of a "
    "UnitDefinition object based on these units or a unit derived from "
    "'metre' (with an exponent of '3').",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.5"}
  },

  //20219
  {
    L3AreaUnitsOnModel,
    "Invalid 'areaUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute 'areaUnits' on a Model object should be "
    "either 'dimensionless' or the identifier of a UnitDefinition object "
    "based on 'dimensionless' or a unit derived from 'metre' (with an "
    "exponent of '2').",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.5"}
  },

  //20220
  {
    L3LengthUnitsOnModel,
    "Invalid 'lengthUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute 'lengthUnits' on a Model object should be "
    "either the units 'metre', 'dimensionless', or the identifier of a "
    "UnitDefinition object based on these units.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.5"}
  },

  //20221
  {
    L3ExtentUnitsOnModel,
    "Invalid 'extentUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute extentUnits on a Model object should be "
    "either the units 'mole', 'item', 'avogadro', 'dimensionless', "
    "'kilogram', 'gram', or the identifier of a UnitDefinition object "
    "based on these units.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.6"}
  },

  //20222
  {
    AllowedAttributesOnModel,
    "Invalid attribute found on the Model object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Model object may only have the following attributes, all of "
    "which are optional: 'metaid', 'sboTerm', 'id', 'name', 'substanceUnits', "
    "'timeUnits', 'volumeUnits', 'areaUnits', 'lengthUnits', 'extentUnits' and "
    "'conversionFactor'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a Model object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2"}
  },

  //20223
  {
    AllowedAttributesOnListOfFuncs,
    "Invalid attribute found on the ListOfFunctionDefinitions object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfFunctionDefinitions object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfFunctionDefinitions object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20224
  {
    AllowedAttributesOnListOfUnitDefs,
    "Invalid attribute found on the ListOfUnitDefinitions object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfUnitDefinitions object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfUnitDefinitions object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20225
  {
    AllowedAttributesOnListOfComps,
    "Invalid attribute found on the ListOfCompartments object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfCompartments object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfCompartments object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20226
  {
    AllowedAttributesOnListOfSpecies,
    "Invalid attribute found on the ListOfSpecies object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfSpecies object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfSpecies object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20227
  {
    AllowedAttributesOnListOfParams,
    "Invalid attribute found on the ListOfParameters object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfParameters object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfParameters object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20228
  {
    AllowedAttributesOnListOfInitAssign,
    "Invalid attribute found on the ListOfInitialAssignments object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfInitialAssignments object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfInitialAssignments object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20229
  {
    AllowedAttributesOnListOfRules,
    "Invalid attribute found on the ListOfRules object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfRules object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfRules object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20230
  {
    AllowedAttributesOnListOfConstraints,
    "Invalid attribute found on the ListOfConstraints object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfConstraints object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfConstraints object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20231
  {
    AllowedAttributesOnListOfReactions,
    "Invalid attribute found on the ListOfReactions object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfReactions object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfReactions object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20232
  {
    AllowedAttributesOnListOfEvents,
    "Invalid attribute found on the ListOfEvents object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfEvents object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfEvents object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20301
  {
    FunctionDefMathNotLambda,
    "Invalid expression found in the function definition",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The top-level element within <math> in a <functionDefinition> is "
    "restricted.",
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
    {"",
     "L2V1 Section 4.3.2",
     "L2V2 Section 4.3.2",
     "L2V3 Section 4.3.2",
     "L2V4 Section 4.3.2",
     "L3V1 Section 4.3.2"}
  },

  //20302
  {
    InvalidApplyCiInLambda,
    "Invalid forward reference in the MathML <apply><ci>...</ci></apply> expression",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Inside the <lambda> of a <functionDefinition>, if a <ci> element is the "
    "first element within a MathML <apply>, then the <ci>'s value can only "
    "be chosen from the set of identifiers of other SBML "
    "<functionDefinition>s defined prior to that point in the SBML model. In "
    "other words, forward references to user-defined functions are not "
    "permitted. ",
    {"",
     "",
     "L2V2 Section 3.5.3",
     "L2V3 Section 3.4.3",
     "",
     ""}
  },

  //20303
  {
    RecursiveFunctionDefinition,
    "Recursive function definitions are not permitted",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Inside the <lambda> of a <functionDefinition>, the identifier of that "
    "<functionDefinition> cannot appear as the value of a <ci> element. SBML "
    "functions are not permitted to be recursive. ",
    {"",
     "",
     "L2V2 Sections 3.5.3 and 4.3.2",
     "L2V3 Sections 3.4.3 and 4.3.2",
     "L2V4 Sections 3.4.3 and 4.3.2",
     "L3V1 Sections 3.4.3 and 4.3.2"}
  },

  //20304
  {
    InvalidCiInLambda,
    "Invalid <ci> reference found inside the <lambda> mathematical formula",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Inside the <lambda> of a <functionDefinition>, if a <ci> element is not "
    "the first element within a MathML <apply>, then the <ci>'s value can "
    "only be the value of a <bvar> element declared in that <lambda>. In "
    "other words, all model entities referenced inside a function definition "
    "must be passed arguments to that function. ",
    {"",
     "",
     "L2V2 Sections 3.5.3 and 4.3.2",
     "L2V3 Sections 3.4.3 and 4.3.2",
     "L2V4 Sections 3.4.3 and 4.3.2",
     "L3V1 Sections 3.4.3 and 4.3.2"}
  },

  //20305
  {
    InvalidFunctionDefReturnType,
    "A function's return type must be either a number or a Boolean",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value type returned by a <functionDefinition>'s <lambda> must be "
    "either Boolean or numeric.",
    {"",
     "",
     "L2V2 Section 3.5.8",
     "L2V3 Section 3.4.9",
     "L2V4 Section 3.4.9",
     "L3V1 Section 3.4.9"}
  },

  //20306
  {
    OneMathElementPerFunc,
    "A FunctionDefinition object must contain one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A FunctionDefinition object must contain exactly one MathML math "
    "element. ",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.3"}
  },

  //20307
  {
    AllowedAttributesOnFunc,
    "Invalid attribute found on the FunctionDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "FunctionDefinition object must have the required attribute 'id', and "
    "may have the optional attributes 'metaid', 'sboTerm' and 'name'. No other "
    "attributes from the SBML Level 3 Core namespace are permitted on a "
    "FunctionDefinition object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.3"}
  },

  //20401
  {
    InvalidUnitDefId,
    "Invalid 'id' attribute value for a UnitDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'id' attribute in a <unitDefinition> must be of "
    "type 'UnitSId' and not be identical to any unit predefined in SBML. ",
    // actual unit are listed in constraint 
    // as these vary between levels/versions
    {"",
     "L2V1 erratum 14",
     "L2V2 Section 4.4.2",
     "L2V3 Section 4.4.2",
     "L2V4 Section 4.4.2",
     "L3V1 Section 4.4.2"}
  },

  //20402
  {
    InvalidSubstanceRedefinition,
    "Invalid redefinition of built-in type 'substance'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Redefinitions of the built-in unit 'substance' are restricted.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
     // actual restrictions are listed in constraint 
    // as these vary between levels/versions
  },

  //20403
  {
    InvalidLengthRedefinition,
    "Invalid redefinition of built-in type 'length'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Redefinitions of the built-in unit 'length' are restricted.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
  },

  //20404
  {
    InvalidAreaRedefinition,
    "Invalid redefinition of built-in type name 'area'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Redefinitions of the built-in unit 'area' are restricted. ",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
  },

  //20405
  {
    InvalidTimeRedefinition,
    "Invalid redefinition of built-in type name 'time'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Redefinitions of the built-in unit 'time' are restricted.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
  },

  //20406
  {
    InvalidVolumeRedefinition,
    "Invalid redefinition of built-in type name 'volume'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Redefinitions of the built-in unit 'volume' are restricted.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
  },

  //20407
  {
    VolumeLitreDefExponentNotOne,
    "Must use 'exponent'=1 when defining 'volume' in terms of litres",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <unitDefinition> for 'volume' simplifies to a <unit> in which the "
    "'kind' attribute value is 'litre', then its 'exponent' attribute value "
    "must be '1'.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
  },

  //20408
  {
    VolumeMetreDefExponentNot3,
    "Must use 'exponent'=3 when defining 'volume' in terms of metres",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <unitDefinition> for 'volume' simplifies to a <unit> in which the "
    "'kind' attribute value is 'metre', then its 'exponent' attribute value "
    "must be '3'.",
    {"",
     "L2V1 Section 4.4.3",
     "L2V2 Section 4.4.3",
     "L2V3 Section 4.4.3",
     "L2V4 Section 4.4.3",
     ""}
  },

  //20409
  {
    EmptyListOfUnits,
    "An empty list of Unit objects is not permitted in a UnitDefinition object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <listOfUnits> container in a <unitDefinition> cannot be empty. ", 
    {"",
     "",
     "L2V2 Section 4.4",
     "L2V3 Section 4.4",
     "L2V4 Section 4.4",
     ""}
  },

  //20410
  {
    InvalidUnitKind,
    "Invalid value for the 'kind' attribute of a UnitDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the 'kind' attribute of a <unit> can only be one of the "
    "base units enumerated by 'UnitKind'; that is, the SBML unit "
    "system is not hierarchical and user-defined units cannot be defined "
    "using other user-defined units. ",
    {"",
     "",
     "L2V2 Section 4.4.1",
     "L2V3 Section 4.4.2",
     "L2V4 Section 4.4.2",
     "L3V1 Section 4.4.2"}
  },

  //20411
  {
    OffsetNoLongerValid,
    "Unit attribute 'offset' is not supported in this Level+Version of SBML",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> previously available in SBML Level 2 "
    "Version 1, has been removed as of SBML Level 2 Version 2. ",
    {"",
     "",
     "L2V2 Section 4.4",
     "",
     "",
     ""}
  },

  //20412
  {
    CelsiusNoLongerValid,
    "Unit name 'Celsius' is not defined in this Level+Version of SBML",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The predefined unit 'Celsius', previously available in SBML Level 1 and "
    "Level 2 Version 1, has been removed as of SBML Level 2 Version 2. ",
    {"",
     "",
     "L2V2 Section 4.4",
     "",
     "",
     ""}
  },

  //20413
  {
    EmptyUnitListElement,
    "A ListOfUnits object must not be empty",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The ListOfUnits container object in a UnitDefinition object is "
    "optional, but if present, it must not be empty.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.4"}
  },

  //20414
  {
    OneListOfUnitsPerUnitDef,
    "At most one ListOfUnits object is allowed inside a UnitDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "There may be at most one ListOfUnits container objects in a "
    "UnitDefinition object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.4"}
  },

  //20415
  {
    OnlyUnitsInListOfUnits,
    "Only Unit, Notes and Annotation objects are allowed in ListOfUnits objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfUnits container object may only contain "
    "Unit objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20419
  {
    AllowedAttributesOnUnitDefinition,
    "Invalid attribute found on the UnitDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A UnitDefinition object must have the required attribute 'id' and "
    "may have the optional attributes 'metaid', 'sboTerm' and 'name'. No other "
    "attributes from the SBML Level 3 Core namespace are permitted on "
    "a UnitDefinition object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.4"}
  },

  //20420
  {
    AllowedAttributesOnListOfUnits,
    "Invalid attribute found on the ListOfUnits object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfUnits object may have the optional attributes 'metaid' and "
    "'sboTerm'. No other attributes from the SBML Level 3 Core namespace "
    "are permitted on a ListOfUnits object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //20421
  {
    AllowedAttributesOnUnit,
    "Invalid attribute found on the Unit object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Unit object must have the required attributes 'kind', 'exponent', "
    "'scale' and 'multiplier', and may have the optional attributes 'metaid' "
    "and 'sboTerm'. No other attributes from the SBML Level 3 Core namespace "
    "are permitted on a Unit object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.4"}
  },

  //20501
  {
    ZeroDimensionalCompartmentSize,
    "Invalid use of the 'size' attribute for a zero-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The size of a <compartment> must not be set if the compartment's "
    "'spatialDimensions' attribute has value '0'.",
    {"",
     "L2V1 Section 4.5.3",
     "L2V2 Section 4.7.4",
     "L2V3 Section 4.7.5",
     "L2V4 Section 4.7.5",
     ""}
  },

  //20502
  {
    ZeroDimensionalCompartmentUnits,
    "Invalid use of the 'units' attribute for a zero-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <compartment> definition has a 'spatialDimensions' value of '0', "
    "then its 'units' attribute must not be set. If the compartment has no "
    "dimensions, then no units can be associated with a non-existent size. ",
    {"",
     "L2V1 Section 4.5.4",
     "L2V2 Section 4.7.5",
     "L2V3 Section 4.7.5",
     "L2V4 Section 4.7.5",
     ""}
  },

  //20503
  {
    ZeroDimensionalCompartmentConst,
    "Zero-dimensional compartments must be defined to be constant",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <compartment> definition has a 'spatialDimensions' value of '0', "
    "then its 'constant' attribute value must either default to or be set to "
    "'true'. If the compartment has no dimensions, then its size can never "
    "change.",
    {"",
     "L2V1 Section 4.5.5",
     "L2V2 Section 4.7.4",
     "L2V3 Section 4.7.6",
     "L2V4 Section 4.7.6",
     ""}
  },

  //20504
  {
    UndefinedOutsideCompartment,
    "Invalid value for the 'outside' attribute of a Compartment object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'outside' attribute value of a <compartment> must be the identifier of "
    "another <compartment> defined in the model.",
    {"",
     "L2V1 Section 4.5.6",
     "L2V2 Section 4.7.7",
     "L2V3 Section 4.7.7",
     "L2V4 Section 4.7.7",
     ""}
  },

  //20505
  {
    RecursiveCompartmentContainment,
    "Recursive nesting of compartments via the 'outside' attribute is not permitted",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A <compartment> may not enclose itself through a chain of references "
    "involving the 'outside' field. This means that a compartment cannot "
    "have its own identifier as the value of 'outside', nor can it point to "
    "another compartment whose 'outside' field points directly or indirectly "
    "to the compartment.",
    {"",
     "L2V1 erratum 11",
     "L2V2 Section 4.7.7",
     "L2V3 Section 4.7.7",
     "L2V4 Section 4.7.7",
     ""}
  },

  //20506
  {
    ZeroDCompartmentContainment,
    "Invalid nesting of zero-dimensional compartments",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'outside' attribute value of a <compartment> cannot be a compartment "
    "whose 'spatialDimensions' value is '0', unless both compartments have "
    "'spatialDimensions'='0'. Simply put, a zero-dimensional compartment "
    "cannot enclose compartments that have anything other than zero "
    "dimensions themselves.",
    {"",
     "",
     "L2V2 Section 4.7.7",
     "L2V3 Section 4.7.7",
     "L2V4 Section 4.7.7",
     ""}
  },

  //20507
  {
    Invalid1DCompartmentUnits,
    "Invalid value for the 'units' attribute of a one-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    "The value of the 'units' attribute on a <compartment> having "
    "'spatialDimensions' of '1' is restricted. ",
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
    {"",
     "",
     "L2V2 Section 4.7.5",
     "L2V3 Section 4.7.5",
     "L2V4 Section 4.7.5",
     "L3V1 Section 4.5.4"}
  },

  //20508
  {
    Invalid2DCompartmentUnits,
    "Invalid value for the 'units' attribute of a two-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    "The value of the 'units' attribute on a <compartment> having "
    "'spatialDimensions' of '2' is restricted.",
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
    {"",
     "L2V1 Section 4.5.4",
     "L2V2 Section 4.7.5",
     "L2V3 Section 4.7.5",
     "L2V4 Section 4.7.5",
     "L3V1 Section 4.5.4"}
  },

  //20509
  {
    Invalid3DCompartmentUnits,
    "Invalid value for the 'units' attribute of a three-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    "The value of the 'units' attribute on a <compartment> having "
    "'spatialDimensions' of '3' is restricted. ",
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
    {"",
     "L2V1 Section 4.5.4",
     "L2V2 Section 4.7.5",
     "L2V3 Section 4.7.5",
     "L2V4 Section 4.7.5",
     "L3V1 Section 4.5.4"}
  },

  //20510
  {
    InvalidCompartmentTypeRef,
    "Invalid value for the 'compartmentType' attribute of a compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If the 'compartmentType' attribute is given a value in a <compartment> "
    "definition, it must contain the identifier of an existing "
    "<compartmentType>.",
    {"",
     "",
     "L2V2 Section 4.7.2",
     "L2V3 Section 4.7.2",
     "L2V4 Section 4.7.2",
     ""}
  },

  //20511
  {
    OneDimensionalCompartmentUnits,
    "No units defined for 1-D compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If the attribute 'units' on a Compartment object having a 'spatialDimensions' "
    "attribute value of '1' has not been set, then the unit of measurement "
    "associated with the compartment's size is determined by the value of the "
    "enclosing Model object's 'lengthUnits' attribute. If neither the Compartment "
    "object's 'units' nor the enclosing Model object's 'lengthUnits' attributes "
    "are set, the unit of compartment size is undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.5.4"}
  },

  //20512
  {
    TwoDimensionalCompartmentUnits,
    "No units defined for 2-D compartment",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If the attribute 'units' on a Compartment object having a 'spatialDimensions' "
    "attribute value of '2' has not been set, then the unit of measurement "
    "associated with the compartment's size is determined by the value of the "
    "enclosing Model object's 'areaUnits' attribute. If neither the Compartment "
    "object's 'units' nor the enclosing Model object's 'areaUnits' attributes "
    "are set, the unit of compartment size is undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.5.4"}
  },

  //20513
  {
    ThreeDimensionalCompartmentUnits,
    "No units defined for 3-D Compartment object",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If the attribute 'units' on a Compartment object having a 'spatialDimensions' "
    "attribute value of '3' has not been set, then the unit of measurement "
    "associated with the compartment's size is determined by the value of the "
    "enclosing Model object's 'volumeUnits' attribute. If neither the Compartment "
    "object's 'units' nor the enclosing Model object's 'volumeUnits' attributes "
    "are set, the unit of compartment size is undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.5.4"}
  },

  //20517
  {
    AllowedAttributesOnCompartment,
    "Invalid attribute found on Compartment object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Compartment object must have the required attributes 'id' and 'constant', "
    "and may have the optional attributes 'metaid', 'sboTerm', 'name', "
    "'spatialDimensions', 'size' and 'units'. No other attributes from the SBML "
    "Level 3 Core namespace are permitted on a Compartment object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.5"}
  },

  //20518
  {
    NoUnitsOnCompartment,
    "No units defined for Compartment object",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If neither the attribute 'units' nor the attribute 'spatialDimensions' "
    "on a Compartment object is set, the unit associated with that "
    "compartment's size is undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.5"}
  },

  //20601
  {
    InvalidSpeciesCompartmentRef,
    "Invalid value found for Species 'compartment' attribute",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of 'compartment' in a <species> definition must be the "
    "identifier of an existing <compartment> defined in the model. ",
    {"",
     "L2V1 Section 4.6.2",
     "L2V2 Section 4.8.3",
     "L2V3 Section 4.8.3",
     "L2V4 Section 4.8.3",
     "L3V1 Section 4.6.3"}
  },

  //20602
  {
    HasOnlySubsNoSpatialUnits,
    "Attribute 'spatialSizeUnits' must not be set if 'hasOnlySubstanceUnits'='true'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <species> definition sets 'hasOnlySubstanceUnits' to 'true', then "
    "it must not have a value for 'spatialSizeUnits'.",
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "",
     "",
     ""}
  },

  //20603
  {
    NoSpatialUnitsInZeroD,
    "Attribute 'spatialSizeUnits' must not be set if the compartment is zero-dimensional",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A <species> definition must not set 'spatialSizeUnits' if the "
    "<compartment> in which it is located has a 'spatialDimensions' value of "
    "'0'.",
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "",
     "",
     ""}
  },

  //20604
  {
    NoConcentrationInZeroD,
    "Attribute 'initialConcentration' must not be set if the compartment is zero-dimensional",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <species> located in a <compartment> whose 'spatialDimensions' is "
    "set to '0', then that <species> definition cannot set "
    "'initialConcentration'.",
    {"",
     "L2V1 Section 4.6.3",
     "L2V2 Section 4.8.4",
     "L2V3 Section 4.8.4",
     "L2V4 Section 4.8.4",
     ""}
  },

  //20605
  {
    SpatialUnitsInOneD,
    "Invalid value for 'spatialSizeUnits' attribute of a one-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <species> is located in a <compartment> whose 'spatialDimensions' "
    "has value '1', then that <species> definition can only set "
    "'spatialSizeUnits' to a value of 'length', 'metre', 'dimensionless', or "
    "the identifier of a <unitDefinition> derived from 'metre' (with an "
    "'exponent' value of '1') or 'dimensionless'.",
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "",
     "",
     ""}
  },

  //20606
  {
    SpatialUnitsInTwoD,
    "Invalid value for the 'spatialSizeUnits' attribute of a two-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <species> is located in a <compartment> whose 'spatialDimensions' "
    "has value '2', then that <species> definition can only set "
    "'spatialSizeUnits' to a value of 'area', 'dimensionless', or the "
    "identifier of a <unitDefinition> derived from either 'metre' (with an "
    "'exponent' value of '2') or 'dimensionless'.",
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "",
     "",
     ""}
  },

  //20607
  {
    SpatialUnitsInThreeD,
    "Invalid value for the 'spatialSizeUnits' attribute of a three-dimensional compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If a <species> is located in a <compartment> whose 'spatialDimensions' "
    "has value '3', then that <species> definition can only set "
    "'spatialSizeUnits' to a value of 'volume', 'litre', 'dimensionless', or "
    "the identifier of a <unitDefinition> derived from either 'litre', "
    "'metre' (with an 'exponent' value of '3') or 'dimensionless'. ",
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "",
     "",
     ""}
  },

  //20608
  {
    InvalidSpeciesSusbstanceUnits,
    "Invalid value for a Species 'units' attribute",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    "The value of a <species>'s 'units' attribute is restricted. ",
    // actual restrictions are listed in constraint 
    // as these vary between levels/versions
    {"",
     "L2V1 Section 4.6.4",
     "L2V2 Section 4.8.5",
     "L2V3 Section 4.8.5",
     "L2V4 Section 4.8.5",
     "L3V1 Section 4.6.5"}
  },

  //20609
  {
    BothAmountAndConcentrationSet,
    "Cannot set both 'initialConcentration' and 'initialAmount' attributes simultaneously",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <species> cannot set values for both 'initialConcentration' and "
    "'initialAmount' because they are mutually exclusive.",
    {"",
     "L2V1 Section 4.6.3",
     "L2V2 Section 4.8.4",
     "L2V3 Section 4.8.4",
     "L2V4 Section 4.8.4",
     "L3V1 Section 4.6.4"}
  },

  //20610
  {
    NonBoundarySpeciesAssignedAndUsed,
    "Cannot use a non-boundary species in both reactions and rules simultaneously",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <species>'s quantity cannot be determined simultaneously by both "
    "reactions and rules. More formally, if the identifier of a <species> "
    "definition having 'boundaryCondition'='false' and 'constant'='false' is "
    "referenced by a <speciesReference> anywhere in a model, then this "
    "identifier cannot also appear as the value of a 'variable' in an "
    "<assignmentRule> or a <rateRule>.", 
    {"",
     "L2V1 Section 4.6.5",
     "L2V2 Section 4.8.6",
     "L2V3 Section 4.8.6",
     "L2V4 Section 4.8.6",
     "L3V1 Section 4.6.6"}
  },

  //20611
  {
    NonConstantSpeciesUsed,
    "Cannot use a constant, non-boundary species as a reactant or product",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <species> having boundaryCondition='false' cannot appear as a "
    "reactant or product in any reaction if that Species also has "
    "constant='true'.",
    {"",
     "L2V1 Section 4.6.5",
     "L2V2 Section 4.8.6",
     "L2V3 Section 4.8.6",
     "L2V4 Section 4.8.6",
     "L3V1 Section 4.6.6"}
  },

  //20612
  {
    InvalidSpeciesTypeRef,
    "Invalid value for the 'speciesType' attribute of a species",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The value of 'speciesType' in a <species> definition must be the "
    "identifier of an existing <speciesType>.",
    {"",
     "",
     "L2V2 Section 4.8.2",
     "L2V3 Section 4.8.2",
     "L2V4 Section 4.8.2",
     ""}
  },

  //20613
  {
    MultSpeciesSameTypeInCompartment,
    "Cannot have multiple species of the same species type in the same compartment",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "There cannot be more than one species of a given <speciesType> in the "
    "same compartment of a model. More formally, for any given compartment, "
    "there cannot be more than one <species> definition in which both of the "
    "following hold simultaneously: (i) the <species>' 'compartment' value "
    "is set to that compartment's identifier and (ii) the <species>' "
    "'speciesType' is set the same value as the 'speciesType' of another "
    "<species> that also sets its 'compartment' to that compartment "
    "identifier.",
    {"",
     "",
     "L2V2 Section 4.8.2",
     "L2V3 Section 4.8.2",
     "L2V4 Section 4.8.2",
     ""}
  },

  //20614
  {
    MissingSpeciesCompartment,
    "Missing value for the 'compartment' attribute",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The 'compartment' attribute in a <species> is mandatory. A <species> "
    "definition in a model must include a value for this attribute. ",
    {"",
     "",
     "L2V2 Section 4.8.3",
     "L2V3 Section 4.8.3",
     "L2V4 Section 4.8.3",
     "L3V1 Section 4.6.3"}
  },

  //20615
  {
    SpatialSizeUnitsRemoved,
    "Attribute 'spatialSizeUnits' is not supported in this Level+Version of SBML",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialSizeUnits' attribute on <species>, previously available "
    "in SBML Level 2 versions prior to Version 3, has been removed as "
    "of SBML Level 2 Version 3. ",
    {"",
     "",
     "",
     "L2V3 Section 4.8",
     "L2V4 Section 4.8",
     ""}
  },

  //20616
  {
    SubstanceUnitsOnSpecies,
    "No substance units defined for the species",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If the attribute 'substanceUnits' in a Species object has not been set, "
    "then the unit of measurement associated with the species' quantity is "
    "determined by the value of the enclosing Model object's 'substanceUnits' "
    "attribute. If neither the Species object's 'substanceUnits' attribute nor "
    "the enclosing Model object's 'substanceUnits' attribute are set, then the "
    "unit of that species' quantity is undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.6.5"}
  },

  //20617
  {
    ConversionFactorOnSpecies,
    "Invalid value for the 'conversionFactor' attribute",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The value of the attribute 'conversionFactor' on a Species object must be "
    "the identifier of an existing Parameter object defined in the enclosing "
    "Model object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.6.7"}
  },

  //20623
  {
    AllowedAttributesOnSpecies,
    "Invalid attribute found on Species object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Species object must have the required attributes 'id', 'compartment', "
    "'hasOnlySubstanceUnits', 'boundaryCondition' and 'constant', and may have "
    "the optional attributes 'metaid', 'sboTerm', 'name', 'initialAmount', "
    "'initialConcentration', 'substanceUnits' and 'conversionFactor'. No other "
    "attributes from the SBML Level 3 Core namespace are permitted on a "
    "Species object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.6"}
  },

  //20701
  {
    InvalidParameterUnits,
    "Invalid value for the 'units' attribute of a Parameter object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_WARNING,
    "The 'units' in a <Parameter> definition must be a value chosen from "
    "among the following: a predefined unit (e.g., 'substance', 'time', "
    "etc.), the identifier of a <UnitDefinition> in the model, or one of the "
    "base units in SBML (e.g., 'litre', 'mole', 'metre', etc.)",
    {"",
     "L2V1 Section 4.7.3",
     "L2V2 Section 4.9.3",
     "L2V3 Section 4.9.3",
     "L2V4 Section 4.9.3",
     "L3V1 Section 4.7.3"}
  },

  //20702
  {
    ParameterUnits,
    "No units defined for the parameter",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "If the attribute 'units' on a given Parameter object has not been set, "
    "then the unit of measurement associated with that parameter's value is "
    "undefined.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.7.3"}
  },

  //20705
  {
    ConversionFactorMustConstant,
    "A conversion factor must reference a Parameter object declared to be a constant",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Parameter object referenced by the attribute 'conversionFactor' "
    "on a Species or Model object must have a value of 'true' for its "
    "attribute 'constant'.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.6.7"}
  },

  //20706
  {
    AllowedAttributesOnParameter,
    "Invalid attribute found on Parameter object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Parameter object must have the required attributes 'id' and 'constant', "
    "and may have the optional attributes 'metaid', 'sboTerm', 'name', 'value' and "
    "'units'. No other attributes from the SBML Level 3 Core namespace are "
    "permitted on a Parameter object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.7"}
  },

  //20801
  {
    InvalidInitAssignSymbol,
    "Invalid value for the 'symbol' attribute of an InitialAssignment object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of 'symbol' in an <initialAssignment> definition must be the "
    "identifier of an existing <compartment>, <species>, or <parameter> "
    "defined in the model or <speciesReference> in Level 3.",
    {"",
     "",
     "L2V2 Section 4.10",
     "L2V3 Section 4.10",
     "L2V4 Section 4.10",
     "L3V1 Section 4.8"}
  },

  //20802
  {
    MultipleInitAssignments,
    "Multiple initial assignments for the same 'symbol' value are not allowed",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A given identifier cannot appear as the value of more than one 'symbol' "
    "field across the set of <initialAssignment>s in a model.",
    {"",
     "",
     "L2V2 Section 4.10",
     "L2V3 Section 4.10",
     "L2V4 Section 4.10",
     "L3V1 Section 4.8"}
  },

  //20803
  {
    InitAssignmentAndRuleForSameId,
    "Cannot set a value using both an initial assignment and an assignment rule simultaneously",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of a 'symbol' field in any <initialAssignment> definition "
    "cannot also appear as the value of a 'variable' field in an "
    "<assignmentRule>. ",
    {"",
     "",
     "L2V2 Section 4.10.4",
     "L2V3 Section 4.10",
     "L2V4 Section 4.10",
     "L3V1 Section 4.8"}
  },

  //20804
  {
    OneMathElementPerInitialAssign,
    "An InitialAssignment object must contain one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An InitialAssignment object must contain exactly one MathML <math> element.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.8"}
  },

  //20805
  {
    AllowedAttributesOnInitialAssign,
    "Invalid attribute found on an InitialAssignment object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An InitialAssignment object must have the required attribute 'symbol' and "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other attributes "
    "from the SBML Level 3 Core namespace are permitted on an "
    "InitialAssignment object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.8"}
  },

  //20901
  {
    InvalidAssignRuleVariable,
    "Invalid value for the 'variable' attribute of an AssignmentRule object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of an <assignmentRule>'s 'variable' must be the identifier of "
    "an existing <compartment>, <species>, globally-defined <parameter>, or (in Level 3) <speciesReference>. ",
    {"",
     "L2V1 Section 4.8.2",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //20902
  {
    InvalidRateRuleVariable,
    "Invalid value for the 'variable' attribute of a RateRule object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of a <rateRule>'s 'variable' must be the identifier of an "
    "existing <compartment>, <species>, globally-defined <parameter>, or (in Level 3) <speciesReference>. ",
    {"",
     "L2V1 Section 4.8.3",
     "L2V2 Section 4.11.4",
     "L2V3 Section 4.11.4",
     "L2V4 Section 4.11.4",
     "L3V1 Section 4.9.4"}
  },

  //20903
  {
    AssignmentToConstantEntity,
    "An assignment rule cannot assign an entity declared to be constant",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Any <compartment>, <species>, <parameter>, or (in Level 3) <speciesReference> whose identifier is the "
    "value of a 'variable' attribute in an <assignmentRule>, must have a value "
    "of 'false' for 'constant'.",
    {"",
     "L2V1 Section 4.8.4",
     "L2V2 Section 4.11.3",
     "L2V3 Section 4.11.3",
     "L2V4 Section 4.11.3",
     "L3V1 Section 4.9.3"}
  },

  //20904
  {
    RateRuleForConstantEntity,
    "A rate rule cannot assign an entity declared to be constant",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Any <compartment>, <species>, <parameter>, or (in Level 3) <speciesReference> whose identifier is the "
    "value of a 'variable' attribute in an <rateRule>, must have a value of "
    "'false' for 'constant'.",
    {"",
     "L2V1 Section 4.8.4",
     "L2V2 Section 4.11.4",
     "L2V3 Section 4.11.4",
     "L2V4 Section 4.11.4",
     "L3V1 Section 4.9.4"}
  },

  //20905
  {
    RepeatedRule10304,
    "",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    ""
  },

  //20906
  {
    CircularRuleDependency,
    "Circular dependencies involving rules and reactions are not permitted",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "There must not be circular dependencies in the combined set of "
    "<initialAssignment>, <assignmentRule> and <kineticLaw> definitions in a "
    "model. Each of these constructs has the effect of assigning a value to "
    "an identifier (i.e. the identifier given in the field 'symbol' in "
    "<initialAssignment>, the field 'variable' in <assignmentRule>, and the "
    "field 'id' on the <kineticLaw>'s enclosing <reaction>). Each of these "
    "constructs computes the value using a mathematical formula. The formula "
    "for a given identifier cannot make reference to a second identifier "
    "whose own definition depends directly or indirectly on the first "
    "identifier.",
    {"",
     "",
     "L2V2 Section 4.11.5",
     "L2V3 Section 4.11.5",
     "L2V4 Section 4.11.5",
     "L3V1 Section 4.9.5"}
  },

  //20907
  {
    OneMathElementPerRule,
    "A rule object must contain one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Every AssignmentRule, RateRule and AlgebraicRule object must contain "
    "exactly one MathML <math> element.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.9"}
  },

  //20908
  {
    AllowedAttributesOnAssignRule,
    "Invalid attribute found on an AssignmentRule object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An AssignmentRule object must have the required attribute 'variable' and "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other attributes "
    "from the SBML Level 3 Core namespace are permitted on an "
    "AssignmentRule object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.9"}
  },

  //20909
  {
    AllowedAttributesOnRateRule,
    "Invalid attribute found on a RateRule object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A RateRule object must have the required attribute 'variable' and "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other attributes "
    "from the SBML Level 3 Core namespace are permitted on a "
    "RateRule object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.9"}
  },

  //20910
  {
    AllowedAttributesOnAlgRule,
    "Invalid attribute found on an AlgebraicRule object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An AlgebraicRule object "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other attributes "
    "from the SBML Level 3 Core namespace are permitted on an "
    "AlgebraicRule object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.9"}
  },

  //21001
  {
    ConstraintMathNotBoolean,
    "A Constraint object's <math> must evaluate to a Boolean value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <constraint>'s <math> expression must evaluate to a value of type "
    "Boolean.",
    {"",
     "",
     "L2V2 Section 4.12.1",
     "L2V3 Section 4.12",
     "L2V4 Section 4.12",
     "L3V1 Section 4.10"}
  },

  //21002
  {
    IncorrectOrderInConstraint,
    "Subobjects inside the Constraint object are not in the prescribed order",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The order of subelements within <constraint> must be the following: "
    "<math>, <message>. The <message> element is optional, but if present, "
    "must follow the <math> element.",
    {"",
     "",
     "L2V2 Section 4.12",
     "L2V3 Section 4.12",
     "L2V4 Section 4.12",
     ""}
  },

  //21003
  {
    ConstraintNotInXHTMLNamespace,
    "A Constraint's Message subobject must be in the XHTML XML namespace",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The contents of the <message> element in a <constraint> must be "
    "explicitly placed in the XHTML XML namespace.", 
    {"",
     "",
     "",
     "L2V3 Section 4.12.2",
     "L2V4 Section 4.12.2",
     ""}
  },

  //21004
  {
    ConstraintContainsXMLDecl,
    "XML declarations are not permitted within Constraint's Message objects",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The contents of the <message> element must not contain an XML declaration "
    "(i.e., a string of the form \"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\" "
    "or similar).",
    {"",
     "",
     "",
     "L2V3 Section 4.12.2",
     "L2V4 Section 4.12.2",
     "L3V1 Section 4.10.2"}
  },

  //21005
  {
    ConstraintContainsDOCTYPE,
    "XML DOCTYPE elements are not permitted within Constraint's Message objects",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The contents of the message element must not contain an XML DOCTYPE "
    "declaration (i.e., a string beginning with the characters \"<!DOCTYPE\". ",
    {"",
     "",
     "",
     "L2V3 Section 4.12.2",
     "L2V4 Section 4.12.2",
     "L3V1 Section 4.10.2"}
  },

  //21006
  {
    InvalidConstraintContent,
    "Invalid content for a Constraint object's Message object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The XHTML content inside a <constraint>s message element can only take one "
    "of the following general forms: (1) a complete XHTML document beginning "
    "with the element <html> and ending with </html>; (2) the \"body\" portion "
    "of a document beginning with the element <body> and ending with </body>; "
    "or (3) XHTML content that is permitted within a <body> ... </body> "
    "elements.", 
    {"",
     "",
     "",
     "L2V3 Section 4.12.2",
     "L2V4 Section 4.12.2",
     ""}
  },

  //21007
  {
    OneMathElementPerConstraint,
    "A Constraint object must contain one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Constraint object must contain exactly one MathML math element",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.10"}
  },

  //21008
  {
    OneMessageElementPerConstraint,
    "A Constraint object must contain one Message subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Constraint object may contain at most one Message subobject.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.10"}
  },

  //21009
  {
    AllowedAttributesOnConstraint,
    "Invalid attribute found on Constraint object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Constraint object "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other attributes "
    "from the SBML Level 3 Core namespace are permitted on a "
    "Constraint object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.10"}
  },

  //21101
  {
    NoReactantsOrProducts,
    "Cannot have a reaction with neither reactants nor products",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <reaction> definition must contain at least one <speciesReference>, "
    "either in its <listOfReactants> or its <listOfProducts>. A reaction "
    "without any reactant or product species is not permitted, regardless of "
    "whether the reaction has any modifier species.",
    {"",
     "",
     "L2V2 Section 4.13.1",
     "L2V3 Section 4.13.3",
     "L2V4 Section 4.13.3",
     "L3V1 Section 4.11.3"}
  },

  //21102
  {
    IncorrectOrderInReaction,
    "Subobjects inside the Reaction object are not in the prescribed order",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The order of subelements within <reaction> must be the following: "
    "<listOfReactants> (optional), <listOfProducts> (optional), "
    "<listOfModifiers> (optional), <kineticLaw>.",
    {"",
     "",
     "L2V2 Section 4.13",
     "L2V3 Section 4.13",
     "L2V4 Section 4.13",
     ""}
  },

  //21103
  {
    EmptyListInReaction,
    "Reaction components, if present, cannot be empty",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The following containers are all optional in a <reaction>, but if any "
    "is present, it must not be empty: <listOfReactants>, <listOfProducts>, "
    "<listOfModifiers>, <kineticLaw>.",
    {"",
     "",
     "L2V2 Section 4.13",
     "L2V3 Section 4.13",
     "L2V4 Section 4.13",
     "L3V1 Section 4.11"}
  },

  //21104
  {
    InvalidReactantsProductsList,
    "Invalid object found in the list of reactants or products",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The list of reactants (<listOfReactants>) and list of products "
    "(<listOfProducts>) in a <reaction> can only contain <speciesReference> "
    "elements.",
    {"",
     "L2V1 Section 4.9",
     "L2V2 Section 4.13",
     "L2V3 Section 4.13",
     "L2V4 Section 4.13",
     "L3V1 Section 4.11"}
  },

  //21105
  {
    InvalidModifiersList,
    "Invalid object found in the list of modifiers",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The list of modifiers (<listOfModifiers>) in a <reaction> can only "
    "contain <modifierSpeciesReference> elements.",
    {"",
     "L2V1 Section 4.9",
     "L2V2 Section 4.13",
     "L2V3 Section 4.13",
     "L2V4 Section 4.13",
     "L3V1 Section 4.11"}
  },

  //21106
  {
    OneSubElementPerReaction,
    "A Reaction object can only contain one of each allowed type of object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Reaction object may contain at most one of each of the following "
    "elements: <listOfReactants>, <listOfProducts>, <listOfModifiers>, and "
    "<kineticLaw>.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21107
  {
    CompartmentOnReaction,
    "Invalid value for the Reaction 'compartment' attribute",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The value of the attribute 'compartment' in a Reaction object is "
    "optional, but if present, must be the identifier of an existing "
    "Compartment object defined in the model.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11.1"}
  },

  //21110
  {
    AllowedAttributesOnReaction,
    "Invalid attribute for a Reaction object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Reaction object must have the required attributes 'id', 'reversible' "
    "and 'fast', and may have the optional attributes 'metaid', 'sboTerm', 'name' "
    "and 'compartment'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a Reaction object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21111
  {
    InvalidSpeciesReference,
    "Invalid 'species' attribute value in SpeciesReference object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of a <speciesReference> 'species' attribute must be the "
    "identifier of an existing <species> in the model. ",
    {"",
     "L2V1 Section 4.9.5",
     "L2V2 Section 4.13.2",
     "L2V3 Section 4.13.3",
     "L2V4 Section 4.13.3",
     "L3V1 Section 4.11.3"}
  },

  //21112
  {
    RepeatedRule20611,
    "",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    ""
  },

  //21113
  {
    BothStoichiometryAndMath,
    "The 'stoichiometry' attribute and StoichiometryMath subobject are mutually exclusive",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A <speciesReference> must not have a value for both 'stoichiometry' and "
    "'stoichiometryMath'; they are mutually exclusive.",
    {"",
     "L2V1 Section 4.9.5",
     "L2V2 Section 4.13.3",
     "L2V3 Section 4.13.3",
     "L2V4 Section 4.13.3",
     ""}
  },

  //21116
  {
    AllowedAttributesOnSpeciesReference,
    "Invalid attribute found on the SpeciesReference object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A SpeciesReference object must have the required attributes 'species' "
    "and 'constant', and may have the optional attributes 'metaid', 'sboTerm', 'name' "
    "'id' and 'stoichiometry'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a SpeciesReference object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21117
  {
    AllowedAttributesOnModifier,
    "Invalid attribute found on the ModifierSpeciesReference object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ModifierSpeciesReference object must have the required attribute 'species' "
    "and may have the optional attributes 'metaid', 'sboTerm', 'id' "
    "and 'name'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ModifierSpeciesReference object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21121
  {
    UndeclaredSpeciesRef,
    "Unknown species referenced in the kinetic law <math> formula",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "All species referenced in the <kineticLaw> formula of a given reaction "
    "must first be declared using <speciesReference> or "
    "<modifierSpeciesReference>. More formally, if a <species> identifier "
    "appears in a <ci> element of a <reaction>'s <kineticLaw> formula, that "
    "same identifier must also appear in at least one <speciesReference> or "
    "<modifierSpeciesReference> in the <reaction> definition.",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "L2V3 Section 4.13.5",
     "L2V4 Section 4.13.5",
     "L3V1 Section 4.11.5"}
  },

  //21122
  {
    IncorrectOrderInKineticLaw,
    "Incorrect ordering of components in the KineticLaw object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The order of subelements within <kineticLaw> must be the following: "
    "<math>, <listOfParameters>. The <listOfParameters> is optional, but "
    "if present, must follow <math>.",
    {"",
     "",
     "L2V2 Section 4.13.9",
     "L2V3 Section 4.13.5",
     "L2V4 Section 4.13.5",
     ""}
  },

  //21123
  {
    EmptyListInKineticLaw,
    "The list of parameters, if present, cannot be empty",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "If present, the <listOfParameters> in a <kineticLaw> must not be an "
    "empty list.",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "L2V3 Section 4.13",
     "L2V4 Section 4.13",
     "L3V1 Section 4.11"}
  },

  //21124
  {
    NonConstantLocalParameter,
    "Parameters local to a KineticLaw object must have a 'constant' attribute value of 'true'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'constant' attribute on a <parameter> local to a <kineticLaw> cannot "
    "have a value other than 'true'. The values of parameters local to "
    "<kineticLaw> definitions cannot be changed, and therefore they are "
    "always constant.",
    {"",
     "",
     "L2V2 Section 4.9.4",
     "L2V3 Section 4.9.4",
     "L2V4 Section 4.9.4",
     ""}
  },

  //21125
  {
    SubsUnitsNoLongerValid,
    "Attribute 'substanceUnits' is not supported in this Level+Version of SBML",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
    "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 2, the substance units of a reaction "
    "rate expression are those of the global 'substance' units of the model. ",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "",
     "",
     ""}
  },

  //21126
  {
    TimeUnitsNoLongerValid,
    "Attribute 'timeUnits' is not supported in this Level+Version of SBML",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
    "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 2, the time units of a reaction rate "
    "expression are those of the global 'time' units of the model. ",
    {"",
     "",
     "L2V2 Section 4.13.5",
     "",
     "",
     ""}
  },

  //21127
  {
    OneListOfPerKineticLaw,
    "Only one ListOfLocalParameters object is permitted within a KineticLaw object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A KineticLaw object may contain at most one ListOfLocalParameters "
    "container object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21128
  {
    OnlyLocalParamsInListOfLocalParams,
    "Only LocalParameter, Notes and Annotation objects are allowed in ListOfLocalParameter objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfLocalParameters container object may only "
    "contain LocalParameter objects.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.8"}
  },

  //21129
  {
    AllowedAttributesOnListOfLocalParam,
    "Invalid attribute found on the ListOfLocalParameters object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfLocalParameters object may have the optional attributes 'metaid' "
    "and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfLocalParameters object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21130
  {
    OneMathPerKineticLaw,
    "Only one <math> element is allowed in a KineticLaw object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    "A KineticLaw object must contain exactly one MathML <math> element.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21131
  {
    UndeclaredSpeciesInStoichMath,
    "Unknown species referenced in the StoichiometryMath object's <math> formula",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "All species referenced in the <stoichiometryMath> formula of a given "
    "reaction must first be declared using <speciesReference> or "
    "<modifierSpeciesReference>. More formally, if a <species> identifier "
    "appears in a <ci> element of a <reaction>'s <stoichiometryMath> "
    "formula, that same identifier must also appear in at least one "
    "<speciesReference> or <modifierSpeciesReference> in the <reaction> "
    "definition.",
    {"",
     "",
     "L2V2 Sections 4.13.2 and 4.13.4",
     "L2V3 Sections 4.13.2 and 4.13.4",
     "L2V4 Sections 4.13.2 and 4.13.4",
     ""}
  },

  //21132
  {
    AllowedAttributesOnKineticLaw,
    "Invalid attribute found on the KineticLaw object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A KineticLaw object may have the optional attributes 'metaid' and "
    "'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a KineticLaw object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21150
  {
    AllowedAttributesOnListOfSpeciesRef,
    "Invalid attribute found on the ListOfSpeciesReferences object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfSpeciesReferences object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfSpeciesReferences object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21151
  {
    AllowedAttributesOnListOfMods,
    "Invalid attribute found on the ListOfModifiers object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfModifierSpeciesReferences object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfModifierSpeciesReferences object.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
  },

  //21172
  {
    AllowedAttributesOnLocalParameter,
    "Invalid attribute found on the LocalParameter object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A LocalParameter object must have the required attribute 'id' and "
    "may have the optional attributes 'metaid', 'sboTerm', 'name', 'value' and "
    "'units'. No other attributes from the SBML Level 3 Core namespace "
    "are permitted on a LocalParameter object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.11"}
},

  //21201
  {
    MissingTriggerInEvent,
    "The Event object is missing a Trigger subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_SCHEMA_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An <event> object must have a 'trigger'.",
    {"",
     "L2V1 Section 4.10.2",
     "L2V2 Section 4.14.1",
     "L2V3 Section 4.14.2",
     "L2V4 Section 4.14.2",
     "L3V1 Section 4.12.2"}
  },

  //21202
  {
    TriggerMathNotBoolean,
    "A Trigger object's <math> expression must evaluate to a Boolean value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An <event>'s <trigger> expression must evaluate to a value of type "
    "Boolean.",
    {"",
     "L2V1 Section 4.10.2",
     "L2V2 Section 4.14.1",
     "L2V3 Section 4.14.2",
     "L2V4 Section 4.14.2",
     "L3V1 Section 4.12.2"}
  },

  //21203
  {
    MissingEventAssignment,
    "The Event object is missing an EventAssignment subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An <event> object must have at least one <eventAssignment> object in "
    "its <listOfEventAssignments>.",
    {"",
     "L2V1 Section 4.10.5",
     "L2V2 Section 4.14",
     "L2V3 Section 4.14",
     "L2V4 Section 4.14",
     "L3V1 Section 4.12"}
  },

  //21204
  {
    TimeUnitsEvent,
    "Units referenced by 'timeUnits' attribute are not compatible with units of time",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The value of an <event>'s 'timeUnits' attribute must be 'time', 'second', "
    "'dimensionless', or the identifier of a <unitDefinition> derived from "
    "either 'second' (with an 'exponent' value of '1') or 'dimensionless'. ",
    {"",
     "L2V1 Section 4.10.4",
     "L2V2 Section 4.14",
     "",
     "",
     ""}
  },

  //21205
  {
    IncorrectOrderInEvent,
    "Incorrect ordering of components in Event object",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The order of subelements within <event> must be the following: "
    "<trigger>, <delay>, <listOfEventAssignments>. The <delay> element "
    "is optional, but if present, must follow <trigger>.", 
    {"",
     "",
     "L2V2 Section 4.14",
     "L2V3 Section 4.14",
     "L2V4 Section 4.14",
     ""}
  },

  //21206
  {
    ValuesFromTriggerTimeNeedDelay,
    "Attribute 'useValuesFromTriggerTime'='false', but the Event object does not define a delay",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If an <event>'s 'useValuesFromTriggerTime' attribute has the "
    "value 'false', then the <event> must contain a <delay> "
    "element.  The implication of 'useValuesFromTriggerTime=false' "
    "is that there is a delay between the time of trigger and the "
    "time of value assignments performed by the <event>.  ",
    {"",
     "",
     "",
     "",
     "L2V4 Section 4.14",
     "L3V1 Section 4.12"}
  },

  //21207
  {
    DelayNeedsValuesFromTriggerTime,
    "The use of a Delay object requires the Event attribute 'useValuesFromTriggerTime'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "If an Event object contains a Delay subobject, then the Event must "
    "have a value for the attribute 'useValuesFromTriggerTime'.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21209
  {
    OneMathPerTrigger,
    "A Trigger object must have one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Trigger object must contain exactly one MathML <math> element.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21210
  {
    OneMathPerDelay,
    "A Delay object must have one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Delay object must contain exactly one MathML <math> element.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

 //21211
  {
    InvalidEventAssignmentVariable,
    "Invalid 'variable' attribute value in Event object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The value of the attribute 'variable' in an <eventAssignment> can only be "
    "the identifier of a <compartment>, <species>, model-wide <parameter> "
    "definition, or <speciesReference> in Level 3.",
    {"",
     "L2V1 Section 4.10.5",
     "L2V2 Section 4.14.3",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //21212
  {
    EventAssignmentForConstantEntity,
    "An EventAssignment object cannot assign to a component having attribute 'constant'='true'",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Any <compartment>, <species>, <parameter>, or (in Level 3) <speciesReference> definition whose identifier "
    "is used as the value of 'variable' in an <eventAssignment> must have a "
    "value of 'false' for its 'constant' attribute.",
    {"",
     "L2V1 Section 4.10.5",
     "L2V2 Section 4.14.2",
     "L2V3 Section 4.14.4",
     "L2V4 Section 4.14.4",
     "L3V1 Section 4.12.4"}
  },

  //21213
  {
    OneMathPerEventAssignment,
    "An EventAssignment object must have one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An EventAssignment object must contain exactly one MathML <math> element.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21214
  {
    AllowedAttributesOnEventAssignment,
    "Invalid attribute found on the EventAssignment object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An EventAssignment object must have the required attribute 'variable' and "
    "may have the optional attributes 'metaid' and 'sboTerm'. No other "
    "attributes from the SBML Level 3 Core namespace are permitted on "
    "an EventAssignment object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21221
  {
    OnlyOneDelayPerEvent,
    "An Event object can only have one Delay subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An Event object may contain at most one Delay object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21222
  {
    OneListOfEventAssignmentsPerEvent,
    "An Event object can only have one ListOfEventAssignments subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An Event object may contain at most one ListOfEventAssignments object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21223
  {
    OnlyEventAssignInListOfEventAssign,
    "Only EventAssignment, Notes and Annotation objects are allowed in ListOfEventAssignments",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Apart from the general Notes and Annotation subobjects permitted on "
    "all SBML components, a ListOfEventAssignments container object may "
    "only contain EventAssignment objects.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12.4"}
    },

  //21224
  {
    AllowedAttributesOnListOfEventAssign,
    "Invalid attribute found on the ListOfEventAssignments object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A ListOfEventAssignments object may have the optional attributes "
    "'metaid' and 'sboTerm'. No other attributes from the SBML Level 3 Core "
    "namespace are permitted on a ListOfEventAssignments object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21225
  {
    AllowedAttributesOnEvent,
    "Invalid attribute found on the Event object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An Event object must have the required attribute 'useValuesFromTriggerTime' "
    "and in addition may have the optional attributes 'metaid', 'sboTerm', 'id', "
    " and 'name'. No other attributes from the SBML Level 3 "
    "Core namespace are permitted on an Event object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21226
  {
    AllowedAttributesOnTrigger,
    "Invalid attribute found on the Trigger object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Trigger object must have the required attributes 'persistent' and "
    "'initialValue', and in addition, may have the optional attributes 'metaid' "
    "and 'sboTerm'. "
    "No other attributes from the SBML Level 3 Core namespace are permitted "
    "on a Trigger object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21227
  {
    AllowedAttributesOnDelay,
    "Invalid attribute found on the Delay object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Delay object may have the optional attributes 'metaid' and 'sboTerm'. "
    "No other attributes from the SBML Level 3 Core namespace are permitted "
    "on a Delay object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21228
  {
    PersistentNotBoolean,
    "The Trigger attribute 'persistent' must evaluate to a Boolean value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The attribute 'persistent' on a Trigger object must have a value "
    "of type Boolean.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21229
  {
    InitialValueNotBoolean,
    "The Trigger attribute 'initialValue' must evaluate to a Boolean value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "The attribute 'initialValue' on a Trigger object must have a value "
    "of type Boolean.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21230
  {
    OnlyOnePriorityPerEvent,
    "An Event object can only have one Priority subobject",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An Event object may contain at most one Priority object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21231
  {
    OneMathPerPriority,
    "A Priority object must have one <math> element",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "An Priority object must contain exactly one MathML <math> element.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //21232
  {
    AllowedAttributesOnPriority,
    "Invalid attribute found on the Priority object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "A Priority object may have the optional attributes 'metaid' and 'sboTerm'. "
    "No other attributes from the SBML Level 3 Core namespace are permitted "
    "on a Priority object.", 
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.12"}
    },

  //29999
  {
    GeneralWarningNotSpecified,
    "Unknown error",
    LIBSBML_CAT_INTERNAL,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "", 
    {"",
     "",
     "",
     "",
     "",
     ""}
    },


  /* --------------------------------------------------------------------------
   * Modeling practice rules
   * ----------------------------------------------------------------------- */

  // 80501
  {
    CompartmentShouldHaveSize,
    "It's best to define a size for every compartment in a model",
    LIBSBML_CAT_MODELING_PRACTICE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "As a principle of best modeling practice, the size of a <compartment> "
    "should be set to a value rather than be left undefined. Doing so "
    "improves the portability of models between different simulation and "
    "analysis systems, and helps make it easier to detect potential errors "
    "in models."
  },


  // 80601
  {
    SpeciesShouldHaveValue,
    "It's best to define an initial amount or initial concentration for every species in a model",
    LIBSBML_CAT_MODELING_PRACTICE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "As a principle of best modeling practice, the <species> "
    "should set an initial value(amount or concentration) rather than be left undefined. Doing so "
    "improves the portability of models between different simulation and "
    "analysis systems, and helps make it easier to detect potential errors "
    "in models."
  },


  // 80701
  {
    ParameterShouldHaveUnits,
    "It's best to declare units for every parameter in a model",
    LIBSBML_CAT_MODELING_PRACTICE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "As a principle of best modeling practice, the units of a <parameter> "
    "should be declared rather than be left undefined. Doing so "
    "improves the ability of software to check the consistency of units "
    "and helps make it easier to detect potential errors in models."
  },


  // 81121
  {
    LocalParameterShadowsId,
    "Local parameters defined within a kinetic law shadow global object symbols",
    LIBSBML_CAT_MODELING_PRACTICE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "In SBML's simple symbol system, there is no separation of symbols "
    "by class of object; consequently, inside the kinetic law mathematical "
    "formula, the value of a local parameter having the same identifier as "
    "a species or compartment or other global model entity will override "
    "the global value. Modelers may wish to take precautions to avoid this "
    "happening accidentally."
  },


  /* --------------------------------------------------------------------------
   * Lower bound for additional error codes returned by libSBML but not
   * defined in SBML specifications.
   * ----------------------------------------------------------------------- */

  //90000
  {
    LibSBMLAdditionalCodesLowerBound,
    "Lower boundary of libSBML-specific diagnostic codes",
    LIBSBML_CAT_INTERNAL,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "", 
    {"",
     "",
     "",
     "",
     "",
     ""}
    },

  //90001
  {
    CannotConvertToL1V1,
    "Cannot convert to SBML Level 1 Version 1",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "Use of SBML Level 1 Version 1 is not recommended and conversion is "
    "not supported by libSBML."
  },

  ////90501
  //{
  //  L2V4InconsistentArgUnits,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "The units of the expressions used as arguments to a function call should "
  //  "match the units expected for the arguments of that function. "
  //},

  ////90502
  //// This is an internal error that reverts to 90501
  //{
  //  L2V4InconsistentArgUnitsWarnings,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  ""
  //},

  ////90503
  //// This is an internal error that reverts to 90501
  //{
  //  L2V4InconsistentPowerUnitsWarnings,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  ""
  //},

  ////90504
  //// This is an internal error that reverts to 90501
  //{
  //  L2V4InconsistentExponUnitsWarnings,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  ""
  //},

  ////90511
  //{
  //  L2V4AssignRuleCompartmentMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <assignmentRule> refers to a <compartment>, "
  //  "the units of the rule's right-hand side should be consistent with the "
  //  "units of that compartment's size."
  //},

  ////90512
  //{
  //  L2V4AssignRuleSpeciesMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <assignmentRule> refers to a <species>, the "
  //  "units of the rule's right-hand side should be consistent with the units "
  //  "of the species' quantity."
  //},

  ////90513
  //{
  //  L2V4AssignRuleParameterMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <assignmentRule> refers to a <parameter>, the "
  //  "units of the rule's right-hand side should be consistent with the units "
  //  "declared for that parameter."
  //},

  ////90521
  //{
  //  L2V4InitAssignCompartmenMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <initialAssignment> refers to a "
  //  "<compartment>, the units of the <initialAssignment>'s <math> expression "
  //  "should be consistent with the units of that compartment's size."
  //},

  ////90522
  //{
  //  L2V4InitAssignSpeciesMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <initialAssignment> refers to a <species>, "
  //  "the units of the <initialAssignment>'s <math> expression should be "
  //  "consistent with the units of that species' quantity."
  //},

  ////90523
  //{
  //  L2V4InitAssignParameterMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <initialAssignment> refers to a <parameter>, "
  //  "the units of the <initialAssignment>'s <math> expression should be "
  //  "consistent with the units declared for that parameter."
  //},

  ////90531
  //{
  //  L2V4RateRuleCompartmentMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in a <rateRule> definition refers to a "
  //  "<compartment>, the units of the rule's right-hand side should be of the "
  //  "form _x per time_, where _x_ is either the 'units' in that "
  //  "<compartment> definition, or (in the absence of explicit units declared "
  //  "for the compartment size) the default units for that compartment, and "
  //  "_time_ refers to the units of time for the model."
  //},

  ////90532
  //{
  //  L2V4RateRuleSpeciesMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in a <rateRule> definition refers to a <species>, "
  //  "the units of the rule's right-hand side should be of the form _x per "
  //  "time_, where _x_ is the units of that species' quantity, and _time_ "
  //  "refers to the units of time for the model."
  //},

  ////90533
  //{
  //  L2V4RateRuleParameterMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in a <rateRule> definition refers to a <parameter>, "
  //  "the units of the rule's right-hand side should be of the form _x per "
  //  "time_, where _x_ is the 'units' in that <parameter> definition, and "
  //  "_time_ refers to the units of time for the model."
  //},

  ////90541
  //{
  //  L2V4KineticLawNotSubstancePerTime,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "The units of the 'math' formula in a <kineticLaw> definition should be "
  //  "the equivalent of _substance per time_."
  //},

  ////90551
  //{
  //  L2V4DelayUnitsNotTime,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When a value for <delay> is given in a <event> definition, the units of "
  //  "the delay formula should correspond to either the value of 'timeUnits' in "
  //  "the <event> or (if no 'timeUnits' are given), the model's default units "
  //  "of time."
  //},

  ////90561
  //{
  //  L2V4EventAssignCompartmentMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <eventAssignment> refers to a <compartment>, "
  //  "the units of the <eventAssignment>'s <math> expression should be consistent "
  //  "with the units of that compartment's size."
  //},

  ////90562
  //{
  //  L2V4EventAssignSpeciesMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <eventAssignment> refers to a <species>, the "
  //  "units of the <eventAssignment>'s <math> expression should be consistent "
  //  "with the units of the species' quantity."
  //},

  ////90563
  //{
  //  L2V4EventAssignParameterMismatch,
  //  LIBSBML_CAT_UNITS_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_GENERAL_WARNING,
  //  "When the 'variable' in an <eventAssignment> refers to a <parameter>, the "
  //  "units of the <eventAssignment>'s <math> expression should be consistent "
  //  "with the units declared for that parameter."
  //},


  /* --------------------------------------------------------------------------
   * L1 compatibility.
   * ----------------------------------------------------------------------- */

  //91001
  {
    NoEventsInL1,
    "SBML Level 1 does not support events",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A model with <event> definitions cannot be represented in SBML Level 1."
  },

  //91002
  {
    NoFunctionDefinitionsInL1,
    "SBML Level 1 does not support function definitions",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 1 does not have <functionDefinitions>. The "
    "<functionDefinitions> in the original model have been "
    "replaced by appropriate formula."
  },

  //91003
  {
    NoConstraintsInL1,
    "SBML Level 1 does not support constraints",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "Conversion of a model with <constraint>s to SBML Level 1 may result "
    "in loss of information."
  },

  //91004
  {
    NoInitialAssignmentsInL1,
    "SBML Level 1 does not support initial assignments",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 1 does not have <initialAssignments>. The "
    "<initialAssignments> in the original model have been "
    "replaced by appropriate values."
  },

  //91005
  {
    NoSpeciesTypesInL1,
    "SBML Level 1 does not support species types",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<speciesType> definitions cannot be represented in SBML Level 1."
  },

  //91006
  {
    NoCompartmentTypeInL1,
    "SBML Level 1 does not support compartment types",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<compartmentType> definitions cannot be represented in SBML Level 1."
  },

  //91007
  {
    NoNon3DCompartmentsInL1,
    "SBML Level 1 only supports three-dimensional compartments",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <compartment> with 'spatialDimensions' not equal to 3 cannot be "
    "represented in SBML Level 1."
  },

  //91008
  {
    NoFancyStoichiometryMathInL1,
    "SBML Level 1 does not support non-integer nor non-rational stoichiometry formulas",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <speciesReference> containing a non-integer or non-rational "
    "<stoichiometryMath> subelement cannot be represented in SBML Level 1."
  },

  //91009
  {
    NoNonIntegerStoichiometryInL1,
    "SBML Level 1 does not support non-integer 'stoichiometry' attribute values",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <speciesReference> containing a non-integer 'stoichiometry' attribute "
    "value cannot be represented in SBML Level 1."
  },

  //91010
  {
    NoUnitMultipliersOrOffsetsInL1,
    "SBML Level 1 does not support multipliers or offsets in unit definitions",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <unit> containing multipliers or offsets cannot be represented in "
    "SBML Level 1."
  },

  //91011
  {
    SpeciesCompartmentRequiredInL1,
    "In SBML Level 1, a value for 'compartment' is mandatory in species definitions",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "A <species> that does not identify its compartment cannot be "
    "represented in SBML Level 1."
  },

  //91012
  {
    NoSpeciesSpatialSizeUnitsInL1,
    "SBML Level 1 does not support species 'spatialSizeUnits' settings",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The information represented by the value of a 'spatialSizeUnit' "
    "attribute on a <species> definition cannot be represented in "
    "SBML Level 1."
  },

  //91013
  {
    NoSBOTermsInL1,
    "SBML Level 1 does not support the 'sboTerm' attribute",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBO terms cannot be represented directly in SBML Level 1."
  },

  //91014
  {
    StrictUnitsRequiredInL1,
    "SBML Level 1 requires strict unit consistency",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all units "
    "be consistent.  This model contains units that produce "
    "inconsistencies and thus conversion to Level 1 "
    "would produce an invalid model."
  },

  //91015
  {
    ConversionFactorNotInL1,
    "SBML Level 1 does not support the 'conversionFactor' attribute",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "This model contains conversion factors "
    "and thus conversion to earlier levels "
    "is not supported."
  },

  //91016
  {
    CompartmentNotOnL1Reaction,
    "SBML Level 1 does not support the 'compartment' attribute on Reaction objects",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "SBML Level 1/2 do not have the 'compartment' attribute on a "
    "Reaction.  This information will be lost in the conversion."
  },

  //91017
  {
    ExtentUnitsNotSubstance,
    "Units of extent must be compatible with units of substance",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Conversion to SBML Level 1 requires that 'extent' units be a "
    "variant of substance",
  },

  //91018
  {
    GlobalUnitsNotDeclared,
    "Global units must be refer to unit kind or unitDefinition.",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Conversion to SBML Levels 1 and 2 requires that any global units "
    "must refer to a valid unit kind or the id of "
    "a valid unitDefinition.",
  },

  //91019
  {
    HasOnlySubstanceUnitsNotinL1,
    "The concept of hasOnlySubstanceUnits was not available in SBML Level 1.",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The concept of a Species having only substance units "
    "and not units of concentration cannot be correctly interpreted "
    "in SBML Level 1 without alteration of any mathematical formula. "
    "LibSBML does not do this alteration",
  },

  //91020
  {
    AvogadroNotSupported,
    "Avogadro not supported in Levels 2 and 1.",
    LIBSBML_CAT_SBML_L1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Conversion of the csymbol avogadro is not yet supported.",
  },
  /* --------------------------------------------------------------------------
   * L2 compatibility.
   * ----------------------------------------------------------------------- */

  //92001
  {
    NoConstraintsInL2v1,
    "SBML Level 2 Version 1 does not support Constraint objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "Conversion of a model with <constraints> to SBML Level 2 Version 1 may "
    "result in loss of information."
  },

  //92002
  {
    NoInitialAssignmentsInL2v1,
    "SBML Level 2 Version 1 does not support InitialAssignment objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 1 does not have <initialAssignments>. The "
    "<initialAssignments> in the original model have been "
    "replaced by appropriate values."
  },

  //92003
  {
    NoSpeciesTypeInL2v1,
    "SBML Level 2 Version 1 does not support SpeciesType objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<speciesType> definitions cannot be represented in SBML Level 2 "
    "Version 1."
  },

  //92004
  {
    NoCompartmentTypeInL2v1,
    "SBML Level 2 Version 1 does not support CompartmentType objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<compartmentType> definitions cannot be represented in SBML Level 2 "
    "Version 1."
  },

  //92005
  {
    NoSBOTermsInL2v1,
    "SBML Level 2 Version 1 does not support the 'sboTerm' attribute",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBO terms cannot be represented directly in SBML Level 2 Version 1."
  },

  //92006
  {
    NoIdOnSpeciesReferenceInL2v1,
    "SBML Level 2 Version 1 does not support the 'id' attribute on SpeciesReference objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The 'id' attribute value of a <speciesReference> cannot be "
    "represented directly in SBML Level 2 Version 1."
  },

  //92007
  {
    NoDelayedEventAssignmentInL2v1,
    "SBML Level 2 Version 1 does not support the 'useValuesFromTriggerTime' attribute",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The implication of 'useValuesFromTriggerTime=false' "
    "is that there is a delay between the time of trigger and the "
    "time of value assignments performed by the <event>.  This interpretation is "
    "not supported by SBML Level 2 versions prior to Version 4. "
    "(References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //92008
  {
    StrictUnitsRequiredInL2v1,
    "SBML Level 2 Version 1 requires strict unit consistency",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all units "
    "be consistent.  This model contains units that produce "
    "inconsistencies and thus conversion to Level 2 Version 1 "
    "would produce an invalid model."
  },

  //92009
  {
    IntegerSpatialDimensions,
    "SBML Level 2 Version 1 requires that compartments have spatial dimensions of 0-3",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Models in SBML Level 2 Versions 1-4 can only represent compartments "
    "with integer values 0, 1, 2,or 3 as spatial dimensions."
  },

  //92010
  {
    StoichiometryMathNotYetSupported,
    "Conversion to StoichiometryMath objects not yet supported",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Conversion of a varying stoichiometry to an SBML L2 StoichiometryMath "
    "element is not yet supported."
  },

  //92011
  {
    PriorityLostFromL3,
    "SBML Level 2 Version 1 does not support priorities on Event objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Event priority is not supported in SBML Level 2."
  },

  //92012
  {
    NonPersistentNotSupported,
    "SBML Level 2 Version 1 does not support the 'persistent' attribute on Trigger objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Non persistent events are not supported in SBML Level 2."
  },

  //92013
  {
    InitialValueFalseEventNotSupported,
    "SBML Level 2 Version 1 does not support the 'initialValue' attribute on Trigger objects",
    LIBSBML_CAT_SBML_L2V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Initialvalue of event Triggers was assumed true in L2."
  },

  /* --------------------------------------------------------------------------
   * L2V2 compatibility.
   * ----------------------------------------------------------------------- */

  //93001
  {
    SBOTermNotUniversalInL2v2,
    "The 'sboTerm' attribute is invalid for this component in SBML Level 2 Version 2",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "In SBML Level 2 Version 2, an 'sboTerm' attribute is only permitted on "
    "the following elements: <model>, <functionDefinition>, <parameter>, "
    "<initialAssignment>, <rule>, <constraint>, <reaction>, "
    "<speciesReference>, <kineticLaw>, <event> and <eventAssignment>."
  },

  //93002
  {
    NoUnitOffsetInL2v2,
    "This Level+Version of SBML does not support the 'offset' attribute on Unit objects",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> previously available in SBML Level 2 "
    "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
    "L2V2 Section 4.4.)"
  },

  //93003
  {
    NoKineticLawTimeUnitsInL2v2,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
    "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 2, the time units of a reaction rate "
    "expression are those of the global 'time' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //93004
  {
    NoKineticLawSubstanceUnitsInL2v2,
    "This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
    "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 2, the substance units of a reaction "
    "rate expression are those of the global 'substance' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //93005
  {
    NoDelayedEventAssignmentInL2v2,
    "This Level+Version of SBML does not support the 'useValuesFromTriggerTime' attribute",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The implication of 'useValuesFromTriggerTime=false' "
    "is that there is a delay between the time of trigger and the "
    "time of value assignments performed by the <event>.  This interpretation is "
    "not supported by SBML Level 2 versions prior to Version 4. "
    "(References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //93006
  {
    ModelSBOBranchChangedBeyondL2v2,
    "The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In SBML Level 2 prior to Version 4 the value  of the 'sboTerm' "
    "attribute on a <model> is expected to be a term "
    "derived from SBO:0000004, \"modeling framework\"; in Version 4 "
    "and above it is expected to be a term derived from SBO:0000231 "
    "\"interaction\". Using the existing term will create an invalid "
    " L2V2 model. (References: L2V2 Section 4.2.1; L2V3 "
    "Sections 4.2.2 and 5; L2V4 Sections 4.2.2 and 5)"
  },

  //93007
  {
    StrictUnitsRequiredInL2v2,
    "SBML Level 2 Version 2 requires strict unit consistency",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all units "
    "be consistent.  This model contains units that produce "
    "inconsistencies and thus conversion to Level 2 Version 2 "
    "would produce an invalid model."
  },

  //93008
  {
    StrictSBORequiredInL2v2,
    "SBML Level 2 Version 2 requires strict SBO term consistency",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all sboTerms "
    "be drawn from a given branch of SBO (http://www.biomodels.net/SBO/). "
    "This model contains sboTerms that produce "
    "inconsistencies and thus conversion to Level 2 Version 2 "
    "would produce an invalid model."
  },

  /* --------------------------------------------------------------------------
   * L2V3 compatibility.
   * ----------------------------------------------------------------------- */

  //93009
  {
    DuplicateAnnotationInvalidInL2v2,
    "Duplicate top-level annotations are invalid in SBML Level 2 Version 2",
    LIBSBML_CAT_SBML_L2V2_COMPAT,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML prior to Level 2 Version 1 annotations it was permissible "
    "to have multiple top level elements using the same namespace. "
    "This is no longer valid.  (References: L2V2 Section 3.3.3; "
    "L2V3 Section 3.2.4; L2V4 Section 3.2.4.)  Any duplicate top level "
    "elements will be placed inside a new top level element named "
    "\"duplicateTopLevelElements\" with the namespace "
    "\"http://www.sbml.org/libsbml/annotation\""
  },

  //94001
  {
    NoUnitOffsetInL2v3,
    "This Level+Version of SBML does not support the 'offset' attribute on Unit objects",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> previously available in SBML Level 2 "
    "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
    "L2V2 Section 4.4.)"
  },

  //94002
  {
    NoKineticLawTimeUnitsInL2v3,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
    "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the time units of a reaction rate "
    "expression are those of the global 'time' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //94003
  {
    NoKineticLawSubstanceUnitsInL2v3,
    "This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
    "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the substance units of a reaction "
    "rate expression are those of the global 'substance' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //94004
  {
    NoSpeciesSpatialSizeUnitsInL2v3,
    "This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialSizeUnits' attribute on <species>, previously available "
    "in SBML Level 2 versions prior to Version 3, has been removed as "
    "of SBML Level 2 Version 3. (References: L2V3 Section 4.8; L2V4 Section 4.8)"
  },

  //94005
  {
    NoEventTimeUnitsInL2v3,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <event>, previously available in SBML "
    "Level 2 versions prior to Version 3, has been removed as of SBML "
    "Level 2 Version 3. (References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //94006
  {
    NoDelayedEventAssignmentInL2v3,
    "This Level+Version of SBML does not support the 'useValuesFromTriggerTime' attribute",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The implication of 'useValuesFromTriggerTime=false' "
    "is that there is a delay between the time of trigger and the "
    "time of value assignments performed by the <event>.  This interpretation is "
    "not supported by SBML Level 2 versions prior to Version 4. "
    "(References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //94007
  {
    ModelSBOBranchChangedBeyondL2v3,
    "The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "In SBML Level 2 prior to Version 4 the value  of the 'sboTerm' "
    "attribute on a <model> is expected to be a term "
    "derived from SBO:0000004, \"modeling framework\"; in Version 4 "
    "and above it is expected to be a term derived from SBO:0000231 "
    "\"interaction\". Using the existing term will create an invalid "
    " L2V3 model. (References: L2V2 Section 4.2.1; L2V3 "
    "Sections 4.2.2 and 5; L2V4 Sections 4.2.2 and 5)"
  },

  //94008
  {
    StrictUnitsRequiredInL2v3,
    "SBML Level 2 Version 3 requires strict unit consistency",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all units "
    "be consistent.  This model contains units that produce "
    "inconsistencies and thus conversion to Level 2 Version 3 "
    "would produce an invalid model."
  },

  //94009
  {
    StrictSBORequiredInL2v3,
    "SBML Level 2 Version 3 requires strict SBO term consistency",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "SBML Level 2 Version 4 removed the requirement that all sboTerms "
    "be drawn from a given branch of SBO (http://www.biomodels.net/SBO/). "
    "This model contains sboTerms that produce "
    "inconsistencies and thus conversion to Level 2 Version 3 "
    "would produce an invalid model."
  },

  //94010
  {
    DuplicateAnnotationInvalidInL2v3,
    "Duplicate top-level annotations are invalid in SBML Level 2 Version 3",
    LIBSBML_CAT_SBML_L2V3_COMPAT,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML prior to Level 2 Version 1 annotations it was permissible "
    "to have multiple top level elements using the same namespace. "
    "This is no longer valid.  (References: L2V2 Section 3.3.3; "
    "L2V3 Section 3.2.4; L2V4 Section 3.2.4.)  Any duplicate top level "
    "elements will be placed inside a new top level element named "
    "\"duplicateTopLevelElements\" with the namespace "
    "\"http://www.sbml.org/libsbml/annotation\""
  },

  /* --------------------------------------------------------------------------
   * L2V4 compatibility.
   * ----------------------------------------------------------------------- */

  //95001
  {
    NoUnitOffsetInL2v4,
    "This Level+Version of SBML does not support the 'offset' attribute on Unit objects",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> previously available in SBML Level 2 "
    "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
    "L2V2 Section 4.4.)"
  },

  //95002
  {
    NoKineticLawTimeUnitsInL2v4,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
    "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the time units of a reaction rate "
    "expression are those of the global 'time' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //95003
  {
    NoKineticLawSubstanceUnitsInL2v4,
    "This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
    "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the substance units of a reaction "
    "rate expression are those of the global 'substance' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //95004
  {
    NoSpeciesSpatialSizeUnitsInL2v4,
    "This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialSizeUnits' attribute on <species>, previously available "
    "in SBML Level 2 versions prior to Version 3, has been removed as "
    "of SBML Level 2 Version 3. (References: L2V3 Section 4.8; L2V4 Section 4.8)"
  },

  //95005
  {
    NoEventTimeUnitsInL2v4,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <event>, previously available in SBML "
    "Level 2 versions prior to Version 3, has been removed as of SBML "
    "Level 2 Version 3. (References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //95006
  {
    ModelSBOBranchChangedInL2v4,
    "The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML Level 2 prior to Version 4 the value  of the 'sboTerm' "
    "attribute on a <model> is expected to be a term "
    "derived from SBO:0000004, \"modeling framework\"; in Version 4 "
    "and above it is expected to be a term derived from SBO:0000231 "
    "\"interaction\". Using the existing term will create an invalid "
    " L2V4 model. (References: L2V2 Section 4.2.1; L2V3 "
    "Sections 4.2.2 and 5; L2V4 Sections 4.2.2 and 5)"
  },

  //95007
  {
    DuplicateAnnotationInvalidInL2v4,
    "Duplicate top-level annotations are invalid in SBML Level 2 Version 4",
    LIBSBML_CAT_SBML_L2V4_COMPAT,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML prior to Level 2 Version 1 annotations it was permissible "
    "to have multiple top level elements using the same namespace. "
    "This is no longer valid.  (References: L2V2 Section 3.3.3; "
    "L2V3 Section 3.2.4; L2V4 Section 3.2.4.)  Any duplicate top level "
    "elements will be placed inside a new top level element named "
    "\"duplicateTopLevelElements\" with the namespace "
    "\"http://www.sbml.org/libsbml/annotation\""
  },

  /* --------------------------------------------------------------------------
   * L3V1 compatibility.
   * ----------------------------------------------------------------------- */

  //96001
  {
    NoSpeciesTypeInL3v1,
    "SBML Level 3 Version 1 does not support SpeciesType objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<speciesType> definitions cannot be represented in SBML Level 3 "
    "Version 1."
  },

  //96002
  {
    NoCompartmentTypeInL3v1,
    "SBML Level 3 Version 1 does not support CompartmentType objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "<compartmentType> definitions cannot be represented in SBML Level 3 "
    "Version 1."
  },

  //96003
  {
    NoUnitOffsetInL3v1,
    "This Level+Version of SBML does not support the 'offset' attribute on Unit objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> previously available in SBML Level 2 "
    "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
    "L2V2 Section 4.4.)"
  },

  //96004
  {
    NoKineticLawTimeUnitsInL3v1,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
    "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the time units of a reaction rate "
    "expression are those of the global 'time' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //96005
  {
    NoKineticLawSubstanceUnitsInL3v1,
    "This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
    "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
    "Version 2. In SBML Level 2 Version 3, the substance units of a reaction "
    "rate expression are those of the global 'substance' units of the model. "
    "(References: L2V2 Section 4.13.5.)"
  },

  //96006
  {
    NoSpeciesSpatialSizeUnitsInL3v1,
    "This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialSizeUnits' attribute on <species>, previously available "
    "in SBML Level 2 versions prior to Version 3, has been removed as "
    "of SBML Level 2 Version 3. (References: L2V3 Section 4.8; L2V4 Section 4.8)"
  },

  //96007
  {
    NoEventTimeUnitsInL3v1,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'timeUnits' attribute on <event>, previously available in SBML "
    "Level 2 versions prior to Version 3, has been removed as of SBML "
    "Level 2 Version 3. (References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //96008
  {
    ModelSBOBranchChangedInL3v1,
    "The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML Level 2 prior to Version 4 the value  of the 'sboTerm' "
    "attribute on a <model> is expected to be a term "
    "derived from SBO:0000004, \"modeling framework\"; in Version 4 "
    "and above it is expected to be a term derived from SBO:0000231 "
    "\"interaction\". Using the existing term will create an invalid "
    " L2V4 model. (References: L2V2 Section 4.2.1; L2V3 "
    "Sections 4.2.2 and 5; L2V4 Sections 4.2.2 and 5)"
  },

  //96009
  {
    DuplicateAnnotationInvalidInL3v1,
    "Duplicate top-level annotations are invalid in SBML Level 3 Version 1",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In SBML prior to Level 2 Version 1 annotations it was permissible "
    "to have multiple top level elements using the same namespace. "
    "This is no longer valid.  (References: L2V2 Section 3.3.3; "
    "L2V3 Section 3.2.4; L2V4 Section 3.2.4.)  Any duplicate top level "
    "elements will be placed inside a new top level element named "
    "\"duplicateTopLevelElements\" with the namespace "
    "\"http://www.sbml.org/libsbml/annotation\""
  },

  //96010
  {
    NoCompartmentOutsideInL3v1,
    "This Level+Version of SBML does not support the 'outside' attribute on Compartment objects",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'outside' attribute on <compartment>, previously available "
    "in SBML Level 2 has been removed as "
    "of SBML Level 3 Version 1."
  },

  //96011
  {
    NoStoichiometryMathInL3v1,
    "This Level+Version of SBML does not support the StoichiometryMath object",
    LIBSBML_CAT_SBML_L3V1_COMPAT,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Conversion of a model with <stoichiometryMath> to SBML Level 3 is not "
    "yet supported."
  },

  /* --------------------------------------------------------------------------
   * These are errors checked by libSBML that were never published in a spec.
   * ----------------------------------------------------------------------- */

  //99101
  {
    InvalidSBMLLevelVersion,
    "Unknown Level+Version combination of SBML",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The level and version specified for the document must be "
    "consistent with a valid published SBML specification.  These are "
    "Level 1, Versions 1 and 2 and Level 2, Versions 1, 2, 3 and 4."
  },

  //99104
  {
    AnnotationNotesNotAllowedLevel1,
    "Annotation objects on the SBML container element are not permitted in SBML Level 1",
    LIBSBML_CAT_SBML,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <sbml> container element cannot contain <notes> or <annotations> in "
    "an SBML Level 1 document."
  },

  //99106
  {
    InvalidRuleOrdering,
    "Invalid ordering of rules",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The math field of an assignment rule structure can contain any "
    "identifier in a MathML <ci> element except for the following: (a) "
    "identifiers for which there exists a subsequent assignment rule, "
    "and (b) the identifier for which the rule is defined. (L2V1 Section "
    "4.8.4)."
  },

  //99107
  {
    RequiredPackagePresent,
    "The SBML document requires an SBML Level 3 package unavailable in this software",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    "Every SBML Level 3 package is identified uniquely by an XML namespace "
    "URI and defines the attribute named 'required'. A value of required="
    "true indicates that interpreting the package is necessary for complete "
    "mathematical interpretation of the model. (L3V1 Section 4.1.2) "
    "This instance of libSBML version 5 cannot find the code necessary to "
    "interpret the package information."
  },

  //99108
  {
    UnrequiredPackagePresent,
    "The SBML document uses an SBML Level 3 package unavailable in this software",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "Every SBML Level 3 package is identified uniquely by an XML namespace "
    "URI and defines the attribute named 'required'. LibSBML has detected "
    "what appears to be an SBML Level 3 package with required=false but "
    "this instance of libSBML-5 cannot find the code necessary to parse "
    "this information."
  },

  //99109
  {
    PackageRequiredShouldBeFalse,
    "This package expects required to be false",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The 'required' attribute for this package is expected to be 'false' "
    "as there is no way to change the mathematical interpretation of the "
    "model using the constructs in this package."
  },

  //99127
  {
    SubsUnitsAllowedInKL,
    "Disallowed value for attribute 'substanceUnits' on KineticLaw object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A KineticLaw's substanceUnits must be 'substance', 'item', 'mole', or "
    "the id of a UnitDefinition that defines a variant of 'item' or 'mole' "
    "(L2v1 Section 4.9.7)."
  },

  //99128
  {
    TimeUnitsAllowedInKL,
    "Disallowed value for attribute 'timeUnits' on KineticLaw object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A KineticLaw's timeUnits must be 'time', 'second', or the id of a "
    "UnitDefnition that defines a variant of 'second' with exponent='1' "
    "(L2v1 Section 4.9.7)."
  },

  //99129
  {
    FormulaInLevel1KL,
    "Only predefined functions are allowed in SBML Level 1 formulas",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "In a Level 1 model, only predefined functions are permitted "
    "within the formula. (L1V2 Appendix C) "
  },

  //99130
  // should be in the spec but is not
  {
    L3SubstanceUnitsOnModel,
    "Invalid 'substanceUnits' attribute value",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The value of the attribute substanceUnits on a Model object should be "
    "either the units 'mole', 'item', 'avogadro', 'dimensionless', "
    "'kilogram', 'gram', or the identifier of a UnitDefinition object "
    "based on these units.",
    {"",
     "",
     "",
     "",
     "",
     "L3V1 Section 4.2.6"}
  },

  //99206
  {
    TimeUnitsRemoved,
    "This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The 'timeUnits' attribute on <event>, previously available in SBML "
    "Level 2 versions prior to Version 3, has been removed as of SBML "
    "Level 2 Version 3. (References: L2V3 Section 4.14; L2V4 Section 4.14)"
  },

  //99219
  {   
    BadMathML,   
    "Invalid MathML expression",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Invalid MathML. The body of an <apply> tag must begin with an operator."   
  },

  //99220
  {   
    FailedMathMLReadOfDouble,   
    "Missing or invalid floating-point number in MathML expression",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Failed to read a valid double value from MathML."   
  },

  //99221
  {   
    FailedMathMLReadOfInteger,   
    "Missing or invalid integer in MathML expression",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Failed to read a valid integer value from MathML."   
  },

  //99222
  {   
    FailedMathMLReadOfExponential,   
    "Missing or invalid exponential expression in MathML",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Failed to read a valid exponential value from MathML."   
  },

  //99223
  {   
    FailedMathMLReadOfRational,   
    "Missing or invalid rational expression in MathML",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Failed to read a valid rational value from MathML."   
  },

  //99224
  {   
    BadMathMLNodeType,   
    "Invalid MathML element",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "Invalid MathML. The body of a <math> tag or the body of "
    "a <lambda> element must begin with one of "   
    "the following: <cn>, <ci>, <csymbol>, <apply>, <piecewise>, "
    "<true>, <false>, <notanumber>, <pi>, <infinity>, <exponentiale>, "
    "<semantics>. (References: L2V3 Appendix B)"
  },

  //99225
  {   
    InvalidMathMLAttribute,   
    "Invalid MathML attribute",
    LIBSBML_CAT_MATHML_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "An invalid MathML attribute has been encountered."
  },

  //99301
  {   
    NoTimeSymbolInFunctionDef,   
    "Use of <csymbol> for 'time' not allowed within FunctionDefinition objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_GENERAL_WARNING,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "The csymbol 'time' should not be used within the <math> element "
    "of a <functionDefinition>. (References: L2V3 Section 4.3.2; " 
    "L2V4 Section 4.3.2)"
  },

  //99302
  {   
    NoBodyInFunctionDef,   
    "There must be a <lambda> body within the <math> element of a FunctionDefinition object",
    LIBSBML_CAT_GENERAL_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "The <lambda> element of a FunctionDefinition object must contain a function "
    "body in addition to zero or more arguments."
  },

  //99301
  {   
    NoTimeSymbolInFunctionDef,   
    "Use of <csymbol> for 'time' not allowed within FunctionDefinition objects",
    LIBSBML_CAT_GENERAL_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_GENERAL_WARNING,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    "The csymbol 'time' should not be used within a the <math> element "
    "of a <FunctionDefinition>. (References: L2V3 Section 4.3.2; " 
    "L2V4 Section 4.3.2)"
  },

  //99303
  {   
    DanglingUnitSIdRef,   
    "Units must refer to valid unit or unitDefinition",
    LIBSBML_CAT_IDENTIFIER_CONSISTENCY,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "Where a component has an attribute that refers to a unit identifier, " 
    "that attribute must refer to a unit defined in SBML or be the id "
    "of a UnitDefinition in the model."
   },

  //99401
  {   
    RDFMissingAboutTag,   
    "RDF missing the <about> tag",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "In order to follow the general syntax for a standard SBML RDF annotation "
    "the first element of RDF element must be a Description element with an "
    "'about' attribute.",
    {"",
     "",
     "L2V2 Section 6.3",
     "L2V3 Section 6.3",
     "L2V4 Section 6.3",
     "L3V1 Section 6.3"}
   },

  //99402
  {   
    RDFEmptyAboutTag,   
    "RDF empty <about> tag",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "In order to follow the general syntax for a standard SBML RDF annotation, "
    "the 'about' attribute of the Description element must be of the form "
    "#string. ",
    {"",
     "",
     "L2V2 Section 6.3",
     "L2V3 Section 6.3",
     "L2V4 Section 6.3",
     "L3V1 Section 6.3"}
   },

  //99403
  {   
    RDFAboutTagNotMetaid,   
    "RDF <about> tag is not metaid",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "In order to follow the general syntax for a standard SBML RDF annotation, "
    "the 'about' attribute of the Description element must be of the form "
    "#string, where the string component is equal to the value of the "
    "metaid attribute of the containing SBML element. ",
    {"",
     "",
     "L2V2 Section 6.3",
     "L2V3 Section 6.3",
     "L2V4 Section 6.3",
     "L3V1 Section 6.3"}
   },

  //99404
  {   
    RDFNotCompleteModelHistory,   
    "RDF does not contain valid ModelHistory",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "LibSBML expected to read the annotation into a ModelHistory "
    "object. Unfortunately, some attributes were not present or correct "
    "and the resulting ModelHistory object will not correctly "
    "produce the annotation.  This functionality will be improved in "
    "later versions of libSBML. ",
    {"",
     "",
     "L2V2 Section 6.3",
     "L2V3 Section 6.3",
     "L2V4 Section 6.3",
     "L3V1 Section 6.3"}
   },

  //99405
  {   
    RDFNotModelHistory,   
    "RDF does not result in a ModelHistory",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    "LibSBML expected to read the annotation into a ModelHistory "
    "object. Unfortunately, some attributes were not present or correct "
    "and the resulting ModelHistory object is NULL. Thus it will fail to "
    "produce the annotation.  This functionality will be improved in "
    "later versions of libSBML. ",
    {"",
     "",
     "L2V2 Section 6.3",
     "L2V3 Section 6.3",
     "L2V4 Section 6.3",
     "L3V1 Section 6.3"}
   },
  
  //99406
  {   
    AnnotationNotElement,   
    "Annotation must contain element",
    LIBSBML_CAT_SBML,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "An annotation must contain elements; with each top-level element "
    "placed in a unique namespace.",
    {"",
     "",
     "L2V2 Section 3.3.3",
     "L2V3 Section 3.2.4",
     "L2V4 Section 3.2.4",
     "L3V1 Section 3.2.4"}
   },

  /* --------------------------------------------------------------------------
   * These are internal errors that reverts to 10501.
   * ----------------------------------------------------------------------- */

  //99502
  // This is an internal error that reverts to 10501
  {
    InconsistentArgUnitsWarnings,
    "",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    ""
  },

  //99503
  // This is an internal error that reverts to 10501
  {
    InconsistentPowerUnitsWarnings,
    "",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    ""
  },

  //99504
  // This is an internal error that reverts to 10501
  {
    InconsistentExponUnitsWarnings,
    "",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_GENERAL_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    ""
  },

  //99505
  {
    UndeclaredUnits,
    "Missing unit declarations on parameters or literal numbers in expression",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "In situations where a mathematical expression contains literal numbers "
    "or parameters whose units have not been declared, it is not possible "
    "to verify accurately the consistency of the units in the expression. "
  },

  //99506
  {
    UndeclaredTimeUnitsL3,
    "Unable to verify consistency of units: the unit of time has not been declared",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "In situations where a mathematical expression refers to time, the units "
    "of time should be consistent with the global time units of the model. "
    "In models where the 'timeUnits' attribute has not been declared, libSBML "
    "does not yet have the functionality to verify accurately the consistency "
    "of the units in such expressions. "
  },

  //99507
  {
    UndeclaredExtentUnitsL3,
    "Unable to verify consistency of units: the units of reaction extent have not been declared",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "In situations where a mathematical expression refers to extent, the units "
    "of extent should be consistent with the global extent units of the model. "
    "In models where the 'extentUnits' attribute has not been declared, libSBML "
    "does not yet have the functionality to verify accurately the consistency "
    "of the units in such expressions. "
  },

  //99508
  {
    UndeclaredObjectUnitsL3,
    "Unable to verify consistency of units: encountered a model entity with no declared units",
    LIBSBML_CAT_UNITS_CONSISTENCY,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "In situations where a mathematical expression refers to a compartment, "
    "species or parameter, it is necessary to know the units "
    "of the object to establish unit consistency. "
    "In models where the units of an object have not been declared, libSBML "
    "does not yet have the functionality to accurately verify the consistency "
    "of the units in mathematical expressions referring to that object. "
  },
  //99701
  {   
    UnrecognisedSBOTerm,   
    "Unrecognized 'sboTerm' attribute value",
    LIBSBML_CAT_SBO_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The SBOTerm used is not recognized by libSBML and therefore the correct "
    "parentage cannot be checked. However, since libSBML is referring to a "
    "snapshot of the SBO tree the term may now exist."
  },

  //99701
  {   
    ObseleteSBOTerm,   
    "Obsolete 'sboTerm' attribute value",
    LIBSBML_CAT_SBO_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,   
    LIBSBML_SEV_WARNING,
    LIBSBML_SEV_WARNING,
    "The SBOTerm value used is considered obsolete."
  },

  /* --------------------------------------------------------------------------
   * Internal consistency checks.
   * ----------------------------------------------------------------------- */

  //99901
  {   
    IncorrectCompartmentSpatialDimensions,   
    "In SBML Level 1, only three-dimensional compartments are allowed",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialDimensions' attribute on <compartment> was not available "
    "in SBML Level 1. In order for the internal representation of a "
    "<compartment> to be correct, the value for the spatialDimensions "
    "member variable should be '3'."
  },

  //99902
  {   
    CompartmentTypeNotValidAttribute,   
    "CompartmentType objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,   
    "The 'compartmentType' attribute on <compartment> was not available "
    "in SBML Level 1 or SBML Level 2 Version 1. In order for the internal "
    "representation of a <compartment> to be correct, the value for the "
    "compartmentType member variable should be not be set."
  },

  //99903
  {   
    ConstantNotValidAttribute,   
    "This Level+Version of SBML does not support the 'constant' attribute on this component",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'constant' attribute on <compartment> and <parameter> was not "
    "available in SBML Level 1. In order for the internal representation "
    "of <compartment> and <parameter> to be correct, the value for the "
    "constant member variable should be 'false' if the <compartment> or "
    "<parameter> is the variable of a <rule> otherwise it can be either "
    "'true' or 'false' without affecting the interpretation of the model."
  },

  //99904
  {   
    MetaIdNotValidAttribute,   
    "Attribute 'metaid' is not available in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'metaid' attribute on all <SBase> objects was not available "
    "in SBML Level 1. In order for the internal "
    "representation to be correct, the value for the "
    "'metaid' member variable should be not be set."
  },

  //99905
  {   
    SBOTermNotValidAttributeBeforeL2V3,   
    "The 'sboTerm' attribute is not available on this component before SBML Level 2 Version 3",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'sboTerm' attribute on <compartment>, <compartmentType> "
    "<delay>, <species>, <speciesType>, <stoichiometryMath>, <trigger> "
    "<unit> and <unitDefinition> was not available before SBML Level 2 "
    "Version 3. In order for the internal "
    "representation of these components to be correct, the value for the "
    "sboTerm member variable should be '-1'."
  },

  //99906
  {   
    InvalidL1CompartmentUnits,   
    "Invalid units for a compartment in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The value of the 'units' attribute on a <compartment> must be either "
    "'volume', 'litre', 'liter' or the identifier of a <unitDefinition> "
    "based on either 'litre'/'liter' or 'metre'/'meter' (with "
    "'exponent' equal to '3')."
  },

  //99907
  {   
    L1V1CompartmentVolumeReqd,   
    "In SBML Level 1, a compartment's volume must be specified",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "A value for the compartment 'volume' attribute must be specified "
    "in this Level+Version of SBML."
  },


  //99908
  {   
    CompartmentTypeNotValidComponent,   
    "CompartmentType objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,   
    "The <compartmentType> component was introduced in SBML Level 2 Version "
    "2. In order for the internal representation of a <model> to "
    "be correct, the <listOfCompartmentTypes> component should be empty."
  },

  //99909
  {   
    ConstraintNotValidComponent,   
    "Constraint objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <constraint> component was introduced in SBML Level 2 Version "
    "2. In order for the internal representation of a <model> to "
    "be correct, the <listOfConstraints> component should be empty."
  },

  //99910
  {   
    EventNotValidComponent,   
    "Event objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <event> component was introduced in SBML Level 2 Version "
    "1. In order for the internal representation of a <model> to "
    "be correct, the <listOfEvents> component should be empty."
  },

  //99911
  {   
    SBOTermNotValidAttributeBeforeL2V2,   
    "The 'sboTerm' attribute is invalid for this component before Level 2 Version 2",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'sboTerm' attribute on <event>, <eventAssignment> "
    "<functionDefinition>, <kineticLaw>, <model>, <parameter>, <reaction> "
    "<rule> and <speciesReferenece> was not available before SBML Level 2 "
    "Version 2. In order for the internal "
    "representation of these components to be correct, the value for the "
    "sboTerm member variable should be '-1'."
  },

  //99912
  {   
    FuncDefNotValidComponent,   
    "FunctionDefinition objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <functionDefinition> component was introduced in SBML Level 2 Version "
    "1. In order for the internal representation of a <model> to "
    "be correct, the <listOfFunctionDefinitions> component should be empty."
  },

  //99913
  {   
    InitialAssignNotValidComponent,   
    "InitialAssignment objects are not available in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The <initialAssignment> component was introduced in SBML Level 2 Version "
    "2. In order for the internal respresentation of a <model> to "
    "be correct, the <listOfInitialAssignments> component should be empty."
  },

  //99914
  {   
    VariableNotValidAttribute,   
    "Attribute 'variable' is not available on this component in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "An <algebraicRule> does not assign a value to a particular variable "
    "and does not carry an attribute named 'variable'."
  },

  //99915
  {   
    UnitsNotValidAttribute,   
    "Attribute 'units' is not available on this component in this Level+Version of SBML",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,
    "The 'units' attribute on <rule> was only applicable to a <parameterRule> "
    "in SBML Level 1. In order for the internal respresentation of a <rule> to "
    "be correct, the value for the units member variable should not be set."
  },

  //99916
  {   
    ConstantSpeciesNotValidAttribute,   
    "Attribute 'constant' is not available on Species objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'constant' attribute on <species> was not available in SBML Level "
    "1. In order for the internal respresentation "
    "of <species> to be correct, the value for the "
    "constant member variable should be 'false' if (1) the <species> is the "
    "variable of a <rule> or (2) the 'boundaryCondition' attribute is 'false' "
    "and the <species> is a product/reactant in a <reaction>. Otherwise it "
    "can be either 'true' or 'false' without affecting the interpretation of "
    "the model."
  },

  //99917
  {   
    SpatialSizeUnitsNotValidAttribute,   
    "Attribute 'spatialSizeUnits' is not available on Species objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'spatialSizeUnits' attribute on <species> was not available "
    "in SBML Level 1. In order for the internal "
    "respresentation of a <species> to be correct, the value for the "
    "spatialSizeUnits member variable should be not be set."
  },

  //99918
  {   
    SpeciesTypeNotValidAttribute,   
    "Attribute 'speciesType' is not available on Species objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,   
    "The 'speciesType' attribute on <species> was not available "
    "in SBML Level 1 or SBML Level 2 Version 1. In order for the internal "
    "respresentation of a <species> to be correct, the value for the "
    "speciesType member variable should be not be set."
  },

  //99919
  {   
    HasOnlySubsUnitsNotValidAttribute,   
    "Attribute 'hasOnlySubstanceUnits' is not available on Species objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'hasOnlySubstanceUnits' attribute on <species> was not available "
    "in SBML Level 1. In order for the internal "
    "respresentation of a <species> to be correct, the value for the "
    "hasOnlySubstanceUnits member variable should be 'false'."
  },

  //99920
  {   
    IdNotValidAttribute,   
    "Attribute 'id' is not available on SpeciesReference objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'id' attribute on <speciesReference> was not available "
    "in SBML Level 1 or SBML Level 2 Version 1. In order for the internal "
    "respresentation of a <speciesReference> to be correct, the value for the "
    "id member variable should be not be set."
  },

    //99921
  {   
    NameNotValidAttribute,   
    "Attribute 'name' is not available on SpeciesReference objects in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'name' attribute on <speciesReference> was not available "
    "in SBML Level 1 or SBML Level 2 Version 1. In order for the internal "
    "respresentation of a <speciesReference> to be correct, the value for the "
    "name member variable should be not be set."
   },

  //99922
  {   
    SpeciesTypeNotValidComponent,   
    "The SpeciesType object is not supported in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,   
    "The <speciesType> component was introduced in SBML Level 2 Version "
    "2. In order for the internal respresentation of a <model> to "
    "be correct, the <listOfSpeciesTypes> component should be empty."
  },

  //99923
  {   
    StoichiometryMathNotValidComponent,   
    "The StoichiometryMath object is not supported in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_ERROR,   
    "The <stoichiometryMath> component on a <speciesReference> was "
    "introduced in SBML Level 2. "
    "In order for the internal respresentation of a <speciesReference> to "
    "be correct, the <stoichiometryMath> component should be 'NULL'."
  },

  //99924
  {   
    MultiplierNotValidAttribute,   
    "Attribute 'multiplier' on Unit objects is not supported in SBML Level 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'multiplier' attribute on <unit> was not available in SBML Level 1. "
    "In order for the internal respresentation of a <unit> to "
    "be correct, the value for the multiplier member variable should be '1.0'."
  }, 

  //99925
  {   
    OffsetNotValidAttribute,   
    "Attribute 'offset' on Unit objects is only available in SBML Level 2 Version 1",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "The 'offset' attribute on <unit> was only available in SBML Level 2 "
    "Version 1. In order for the internal respresentation of a <unit> to "
    "be correct, the value for the offset member variable should be '0'."
  }, 

  //99926
  {   
    L3SpatialDimensionsUnset,   
    "No value given for 'spatialDimensions' attribute; assuming a value of 3",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,   
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_WARNING,
    "The 'spatialDimensions' attribute on <compartment> was left unset on "
    "the SBML Level 3 model.  Conversion will apply a default value of '3'."
  }, 

  ////99927
  //// should be in the spec but is not
  //{
  //  L3SubstanceUnitsOnModel,
  //  "Invalid 'substanceUnits' attribute value",
  //  LIBSBML_CAT_GENERAL_CONSISTENCY,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_NOT_APPLICABLE,
  //  LIBSBML_SEV_WARNING,
  //  "The value of the attribute substanceUnits on a Model object should be "
  //  "either the units 'mole', 'item', 'avogadro', 'dimensionless', "
  //  "'kilogram', 'gram', or the identifier of a UnitDefinition object "
  //  "based on these units.",
  //  {"",
  //   "",
  //   "",
  //   "",
  //   "",
  //   "L3V1 Section 4.2.6"}
  //},


/* Explanation about 99994 and 99995:

If SBase::readAttributes function finds an attribute it does not know about
in a namespace it does not recognize, it stores the attribute BUT.  If it
*does* know about the namespace but the attribute is not recognized, then
since this is the generic base function, it logs a generic error 99994/5.

The readAttributes function for the derived class calls SBase::readAttributes
and then looks to see if these generic errors have been logged. If so, they
remove the error and replace it with an error that is specific to the object
that is logging the error.

For example, instead of getting a general error, you would get a specific
error such as

    "A <layout> object may have the optional SBML Level~3 Core "
    "attributes 'metaid' and 'sboTerm'. No other attributes from "
    "the SBML Level 3 Core namespace are permitted on a <layout> object. ",

This error is actually within the layout package so this "add a generic error
and then replace it with a specific one 'hack' " keeps the error codes for
packages separate -- so that libsbml will work if a certain package has not
been included in the build but if the package is in the build you get proper
package related errors without the SBase::readAttributes function needing to
know about them.

*/

  //99994
  {   
    UnknownCoreAttribute,   
    "Encountered an unknown attribute in the SBML Core namespace",
    LIBSBML_CAT_INTERNAL,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,   
    ""
  },

  //99995
  {   
    UnknownPackageAttribute,   
    "Encountered an unknown attribute in an SBML Level 3 package namespace",
    LIBSBML_CAT_INTERNAL,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,   
    ""
  },



  //99996
  {   
    PackageConversionNotSupported,   
    "Conversion of SBML Level 3 package constructs is not yet supported",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,   
    "Conversion of SBML Level 3 package information is not yet supported."
  },

  //99997
  {   
    InvalidTargetLevelVersion,   
    "The requested SBML Level/Version combination is not known to exist",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,   
    "Conversion is only possible to an existing SBML Level and Version."
  },

  //99998
  {   
    L3NotSupported,   
    "SBML Level 3 is not yet supported",
    LIBSBML_CAT_INTERNAL_CONSISTENCY,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,   
    LIBSBML_SEV_ERROR,
    LIBSBML_SEV_ERROR,   
    "Validation of or conversion from L3 documents/models is not yet "
    "supported."
  },

  /* --------------------------------------------------------------------------
   * Boundary marker.  Application-specific codes should begin at 100000.
   * ----------------------------------------------------------------------- */

  //99999
  {
    SBMLCodesUpperBound,
    "Upper boundary of libSBML-specific diagnostic codes",
    LIBSBML_CAT_INTERNAL,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    LIBSBML_SEV_NOT_APPLICABLE,
    "Application-specific codes should begin at 100000.", 
    {"",
     "",
     "",
     "",
     "",
     ""}
    }
};

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

