/**
 * @file    L3ParserSettings.h
 * @brief   Definition of the level 3 infix-to-mathml parser settings.
 * @author  Lucian Smith
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
 * ---------------------------------------------------------------------- -->
 *
 * @class L3ParserSettings
 * @sbmlbrief{core} Controls the behavior of the Level 3 formula parser.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The function
 * @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings},
 * along with its variants @sbmlfunction{parseL3Formula, String} and
 * @sbmlfunction{parseL3FormulaWithModel, String\, Model},
 * are the interfaces to a parser for mathematical formulas written as
 * text strings.  The inverse function is @sbmlfunction{formulaToL3String,
 * ASTNode} and its variants such as
 * @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}.
 * The parsers and the formula writers convert between a text-string
 * representation of mathematical formulas and Abstract Syntax Trees (ASTs),
 * represented in libSBML using ASTNode objects.
 * Compared to the parser and writer implemented by the functions
 * @sbmlfunction{parseFormula, String} and
 * @sbmlfunction{formulaToString, ASTNode},
 * which were designed primarily for converting the mathematical formula
 * strings in SBML Level&nbsp;1, the SBML Level&nbsp;3 or "L3" variants of
 * the parser and writer use an extended formula syntax.  They also have a
 * number of configurable behaviors.  This class (L3ParserSettings) is an
 * object used to communicate the configuration settings with callers.
 *
 * The following aspects of the parser are configurable using
 * L3ParserSettings objects.  (For the formula writer, only a subset of these
 * settings is relevant; please see the documentation for
 * @sbmlfunction{formulaToL3StringWithSettings, ASTNode\,
 * L3ParserSettings} for more information about which ones).
 *
 * @copydetails doc_l3_parser_configuration_options
 *
 * To obtain the default configuration values, callers can use the function
 * @sbmlfunction{getDefaultL3ParserSettings,}.  To change the configuration,
 * callers can create an L3ParserSettings object, set the desired
 * characteristics using the methods provided, and pass that object to
 * @sbmlfunction{parseL3FormulaWithSettings, String formula\, L3ParserSettings settings}.
 *
 * @see @sbmlfunction{parseL3Formula, String}
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{parseL3FormulaWithModel, String\, Model}
 * @see @sbmlfunction{parseFormula, String}
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * @see @sbmlfunction{formulaToL3String, ASTNode}
 * @see @sbmlfunction{formulaToString, ASTNode}
 * @see @sbmlfunction{getDefaultL3ParserSettings,}
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_use_of_model
 *
 * @par
 * When a Model object is provided, identifiers (values of type @c SId)
 * from that model are used in preference to pre-defined MathML symbol
 * definitions.  More precisely, the Model entities whose identifiers will
 * shadow identical symbols in the mathematical formula are: Species,
 * Compartment, Parameter, Reaction, and SpeciesReference.  For instance, if
 * the parser is given a Model containing a Species with the identifier
 * &quot;<code>pi</code>&quot;, and the formula to be parsed is
 * &quot;<code>3*pi</code>&quot;, the MathML produced will contain the
 * construct <code>&lt;ci&gt; pi &lt;/ci&gt;</code> instead of the construct
 * <code>&lt;pi/&gt;</code>.  Similarly, when a Model object is provided, @c
 * SId values of user-defined functions present in the Model will be used
 * preferentially over pre-defined MathML functions.  For example, if the
 * passed-in Model contains a FunctionDefinition with the identifier
 * &quot;<code>sin</code>&quot;, that function will be used instead of the
 * predefined MathML function <code>&lt;sin/&gt;</code>.
 *
 * @class doc_unary_minus_settings
 *
 * @par
 * This setting affects two behaviors.  First, pairs of multiple unary
 * minuses in a row (e.g., &quot;<code>- -3</code>&quot;) can be collapsed
 * and ignored in the input, or the multiple minuses can be preserved in the
 * AST node tree that is generated by the parser.  Second, minus signs in
 * front of numbers can be collapsed into the number node itself; for
 * example, a &quot;<code>- 4.1</code>&quot; can be turned into a single
 * ASTNode of type @sbmlconstant{AST_REAL,ASTNodeType_t} with a value of
 * <code>-4.1</code>, or it can be turned into a node of type
 * @sbmlconstant{AST_MINUS,ASTNodeType_t} having a child node of type
 * @sbmlconstant{AST_REAL,ASTNodeType_t}.
 *
 * @class doc_unary_minus_values
 *
 * <ul>
 * <li> @sbmlconstant{L3P_COLLAPSE_UNARY_MINUS,} (value = @c true): collapse
 * unary minuses where possible.
 * <li> @sbmlconstant{L3P_EXPAND_UNARY_MINUS,} (value = @c false): do not
 * collapse unary minuses, and instead translate each one into an AST node of
 * type @sbmlconstant{AST_MINUS,ASTNodeType_t}.
 * </ul>
 *
 * @class doc_parsing_units
 *
 * @par
 * In SBML Level&nbsp;2, there is no means of associating a unit of
 * measurement with a pure number in a formula, while SBML Level&nbsp;3 does
 * define a syntax for this.  In Level&nbsp;3, MathML <code>&lt;cn&gt;</code>
 * elements can have an attribute named @c units placed in the SBML
 * namespace, which can be used to indicate the units to be associated with
 * the number.  The text-string infix formula parser allows units to be
 * placed after raw numbers; they are interpreted as unit identifiers for
 * units defined by the SBML specification or in the containing Model object.
 * Some examples include: &quot;<code>4 mL</code>&quot;, &quot;<code>2.01
 * Hz</code>&quot;, &quot;<code>3.1e-6 M</code>&quot;, and &quot;<code>(5/8)
 * inches</code>&quot;.  To produce a valid SBML model, there must either
 * exist a UnitDefinition corresponding to the identifier of the unit, or the
 * unit must be defined in Table&nbsp;2 of the SBML Level&nbsp;3 specification.
 *
 * @class doc_parsing_units_values
 *
 * <ul>
 * <li> @sbmlconstant{L3P_PARSE_UNITS,} (value = @c true): parse units in the
 * text-string formula.
 * <li> @sbmlconstant{L3P_NO_UNITS,} (value = @c false): treat units in the
 * text-string formula as errors.
 * </ul>
 *
 * @class doc_parsing_avogadro
 *
 * @par
 * SBML Level&nbsp;3 defines a symbol for representing the value of
 * Avogadro's constant, but it is not defined in SBML Level&nbsp;2.  As a
 * result, the text-string formula parser must behave differently
 * depending on which SBML Level is being targeted.  For Level&nbsp;3
 * documents, it can interpret instances of @c avogadro in the input
 * as a reference to the MathML @em csymbol for Avogadro's constant
 * defined in the SBML Level&nbsp;3 specification.  For Level&nbsp;2,
 * it must treat @c avogadro as just another plain symbol.
 *
 * @class doc_avogadro_values
 *
 * <ul>
 * <li> @sbmlconstant{L3P_AVOGADRO_IS_CSYMBOL,} (value = @c true): tells the
 * parser to translate the string @c avogadro (in any capitalization) into an
 * AST node of type @sbmlconstant{AST_NAME_AVOGADRO,ASTNodeType_t}.
 * <li> @sbmlconstant{L3P_AVOGADRO_IS_NAME,} (value = @c false): tells the
 * parser to translate the string @c avogadro into an AST of type
 * @sbmlconstant{AST_NAME,ASTNodeType_t}.
 * </ul>
 *
 * @class doc_case_sensitivity
 *
 * @par
 * By default, the parser compares symbols in a case insensitive manner for
 * built-in functions such as @c "sin" and @c "piecewise", and for constants
 * such as @c "true" and @c "avogadro".  Setting this option to @c false, you
 * can force the string comparison to @em only match lower-case strings.
 * Thus, for example, @c "sin" and @c "true" will match the built-in values, but
 * @c "SIN" and @c "TRUE" will not.
 */

#ifndef L3ParserSettings_h
#define L3ParserSettings_h

#include <sbml/common/libsbml-namespace.h>
#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/util/StringBuffer.h>


/**
 * @enum ParseLogType_t
 * @brief Configuration values for handling the @c log function in
 * mathematical formulas.
 *
 * The L3ParserSettings object can be used to modify the behavior of the SBML
 * Level&nbsp;3-oriented formula parser.  One of the behaviors that can be
 * modified is how it should translate the function <code>log(x)</code>.  It
 * has three different behavior modes, each settable using values from this
 * enumeration.
 *
 * @see L3ParserSettings
 * @see @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings}
 * @see @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 */
typedef enum
{
    L3P_PARSE_LOG_AS_LOG10 = 0,
    /*!< Parse <code>log(x)</code> as the base-10 logarithm of @c x. */

    L3P_PARSE_LOG_AS_LN    = 1,
    /*!< Parse <code>log(x)</code> as the natural logarithm of @c x. */

    L3P_PARSE_LOG_AS_ERROR = 2
    /*!< Refuse to parse <code>log(x)</code> at all, and set an error message 
      telling the user to use <code>log10(x)</code>, <code>ln(x)</code>,
      or <code>log(base, x)</code> instead. */

} ParseLogType_t;


/**
 * Collapse unary minuses where possible.
 *
 * @see L3ParserSettings::getParseCollapseMinus()
 * @see L3ParserSettings::setParseCollapseMinus()
 */
#define L3P_COLLAPSE_UNARY_MINUS true

/**
 * Retain unary minuses in the AST representation.
 *
 * @see L3ParserSettings::getParseCollapseMinus()
 * @see L3ParserSettings::setParseCollapseMinus()
 */
#define L3P_EXPAND_UNARY_MINUS   false

/**
 * Parse units in text-string formulas.
 *
 * @see L3ParserSettings::getParseUnits()
 * @see L3ParserSettings::setParseUnits()
 */
#define L3P_PARSE_UNITS  true

/**
 * Do not recognize units in text-string formulas---treat them as errors.
 *
 * @see L3ParserSettings::getParseUnits()
 * @see L3ParserSettings::setParseUnits()
 */
#define L3P_NO_UNITS false

/**
 * Recognize 'avogadro' as an SBML Level 3 symbol.
 *
 * @see L3ParserSettings::getParseAvogadroCsymbol()
 * @see L3ParserSettings::setParseAvogadroCsymbol()
 */
#define L3P_AVOGADRO_IS_CSYMBOL true

/**
 * Do not treat 'avogadro' specially---consider it a plain symbol name.
 *
 * @see L3ParserSettings::getParseAvogadroCsymbol()
 * @see L3ParserSettings::setParseAvogadroCsymbol()
 */
#define L3P_AVOGADRO_IS_NAME    false


/**
 * Treat all forms of built-in functions as referencing that function, 
 * regardless of the capitalization of that string.
 *
 * @see L3ParserSettings::getComparisonCaseSensitivity()
 * @see L3ParserSettings::setComparisonCaseSensitivity()
 */
#define L3P_COMPARE_BUILTINS_CASE_INSENSITIVE false

/**
 * Treat only the all-lower-case form of built-in functions as referencing
 * that function, and all other forms of capitalization of that string
 * as referencing user-defined functions or values.
 *
 * @see L3ParserSettings::getComparisonCaseSensitivity()
 * @see L3ParserSettings::setComparisonCaseSensitivity()
 */
#define L3P_COMPARE_BUILTINS_CASE_SENSITIVE true


typedef enum
{
    INFIX_SYNTAX_NAMED_SQUARE_BRACKETS
  , INFIX_SYNTAX_CURLY_BRACES
  , INFIX_SYNTAX_CURLY_BRACES_SEMICOLON
} L3ParserGrammarLineType_t;



#ifdef __cplusplus

#include <vector>
#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class Model;
class ASTBasePlugin;
class L3Parser;

class LIBSBML_EXTERN L3ParserSettings
{
private:
  /** @cond doxygenLibsbmlInternal */

  const Model* mModel;
  ParseLogType_t mParselog;
  bool mCollapseminus;
  bool mParseunits;
  bool mAvoCsymbol;
  bool mStrCmpIsCaseSensitive;
  std::vector<ASTBasePlugin*> mPlugins;

  /** @endcond */

public:

  /**
   * Creates a new L3ParserSettings object with default values.
   *
   * This is the default constructor for the L3ParserSettings object.  It
   * sets the stored Model object to @c NULL and sets the following
   * field values in the L3ParserSettings object:
   *
   * @li <em>parseunits</em> ("parse units") is set to
   * @sbmlconstant{L3P_PARSE_UNITS,}.
   *
   * @li <em>collapseminus</em> ("collapse minus") is set to
   * @sbmlconstant{L3P_EXPAND_UNARY_MINUS,}.
   *
   * @li <em>parselog</em> ("parse log") is set to
   * @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t}.
   *
   * @li <em>avocsymbol</em> ("Avogadro csymbol") is set to
   * @sbmlconstant{L3P_AVOGADRO_IS_CSYMBOL,}.
   *
   * @li <em>sbmlns</em> ("SBML namespaces") is set to @c NULL (which
   * indicates that no syntax extensions due to SBML Level&nbsp;3 packages
   * will be assumed---the formula parser will only understand the
   * core syntax described in the documentation for
   * @sbmlfunction{parseL3Formula, String}).
   */
  L3ParserSettings();


  /**
   * Creates a new L3ParserSettings object with specific values for all
   * possible settings.
   *
   * @param model a Model object to be used for disambiguating identifiers
   * encountered by @sbmlfunction{parseL3FormulaWithSettings, String\,
   * L3ParserSettings} in mathematical formulas.
   *
   * @param parselog ("parse log") a flag that controls how the parser will
   * handle the symbol @c log in mathematical formulas. The function @c log
   * with a single argument (&quot;<code>log(x)</code>&quot;) can be parsed
   * as <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error, as
   * desired, by using the parameter values
   * @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t},
   * @sbmlconstant{L3P_PARSE_LOG_AS_LN,ParseLogType_t}, or
   * @sbmlconstant{L3P_PARSE_LOG_AS_ERROR,ParseLogType_t}, respectively.
   *
   * @param collapseminus ("collapse minus") a flag that controls how the
   * parser will handle minus signs in formulas.  Unary minus signs can be
   * collapsed or preserved; that is, sequential pairs of unary minuses
   * (e.g., &quot;<code>- -3</code>&quot;) can be removed from the input
   * entirely and single unary minuses can be incorporated into the number
   * node, or all minuses can be preserved in the AST node structure.
   * The possible values of this field are
   * @sbmlconstant{L3P_COLLAPSE_UNARY_MINUS,} (to collapse unary minuses) and
   * @sbmlconstant{L3P_EXPAND_UNARY_MINUS,} (to expand unary minuses).
   *
   * @param parseunits ("parse units") a flag that controls how the parser
   * will handle apparent references to units of measurement associated with
   * raw numbers in a formula.  If set to the value
   * @sbmlconstant{L3P_PARSE_UNITS,}, units are parsed; if set to the value
   * @sbmlconstant{L3P_NO_UNITS,}, units are not parsed.
   *
   * @param avocsymbol ("Avogadro csymbol") a flag that controls how the
   * parser will handle the appearance of the symbol @c avogadro in a
   * formula.  If set to the value @sbmlconstant{L3P_AVOGADRO_IS_CSYMBOL,},
   * the symbol is interpreted as the SBML/MathML @em csymbol @c avogadro; if
   * set to the value @sbmlconstant{L3P_AVOGADRO_IS_NAME,}, the symbol is
   * interpreted as a plain symbol name.
   *
   * @param caseSensitive a flag that controls how the
   * parser will handle case sensitivity of any function name.
   * If set to the value @sbmlconstant{L3P_COMPARE_BUILTINS_CASE_INSENSITIVE,},
   * the name is interpreted as teh relevant math function regardless of case; if
   * set to the value @sbmlconstant{L3P_COMPARE_BUILTINS_CASE_SENSITIVE,}, the name is
   * interpreted as a user defined function unless it is all lower case.
   *
   * @param sbmlns ("SBML namespaces") an SBML namespaces object.  The
   * namespaces identify the SBML Level&nbsp;3 packages that can extend the
   * syntax understood by the formula parser.  When non-@c NULL, the parser
   * will interpret additional syntax defined by the packages; for example,
   * it may understand vector/array extensions introduced by the SBML
   * Level&nbsp;3 @em Arrays package.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   *
   * @see getModel()
   * @see setModel(@if java Model@endif)
   * @see unsetModel()
   * @see getParseLog()
   * @see setParseLog(@if java int@endif)
   * @see getParseUnits()
   * @see setParseUnits(@if java boolean@endif)
   * @see getParseCollapseMinus()
   * @see setParseCollapseMinus(@if java boolean@endif)
   * @see getParseAvogadroCsymbol()
   * @see setParseAvogadroCsymbol(@if java boolean@endif)
   */
  L3ParserSettings(Model* model, ParseLogType_t parselog,
                   bool collapseminus, bool parseunits, bool avocsymbol,
                   bool caseSensitive = false, 
                   SBMLNamespaces* sbmlns = NULL);


  /**
   * Destroys this L3ParserSettings object.
   */
  virtual ~L3ParserSettings();


  /**
   * Sets the model reference in this L3ParserSettings object.
   *
   * @copydetails doc_use_of_model
   *
   * @param model a Model object to be used for disambiguating identifiers.
   *
   * @warning <span class="warning">This does @em not copy the Model object.
   * This means that modifications made to the Model after invoking this
   * method may affect parsing behavior, because the parser will query the
   * @em current contents of the model.</span>
   *
   * @see getModel()
   * @see unsetModel()
   */
  void setModel(const Model* model);


  /**
   * Returns the Model object referenced by this L3ParserSettings object.
   *
   * @copydetails doc_use_of_model
   *
   * @see setModel(@if java Model@endif)
   * @see unsetModel()
   */
  const Model* getModel() const;


  /**
   * Unsets the Model reference in this L3ParserSettings object.
   *
   * The effect of calling this method is to set the stored model value
   * to @c NULL.
   *
   * @see setModel(@if java Model@endif)
   * @see getModel()
   */
  void unsetModel();


  /**
   * Sets the behavior for handling @c log in mathematical formulas.
   *
   * The function @c log with a single argument
   * (&quot;<code>log(x)</code>&quot;) can be parsed as
   * <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error.
   * These three behaviors are set, respectively, by using the value
   * @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t},
   * @sbmlconstant{L3P_PARSE_LOG_AS_LN,ParseLogType_t}, or
   * @sbmlconstant{L3P_PARSE_LOG_AS_ERROR,ParseLogType_t}
   * for the @p type parameter.
   *
   * @param type a constant, one of following three possibilities:
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t}
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_LN,ParseLogType_t}
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_ERROR,ParseLogType_t}
   *
   * @see getParseLog()
   */
  void setParseLog(ParseLogType_t type);


  /**
   * Indicates the current behavior set for handling the function @c log with
   * one argument.
   *
   * The function @c log with a single argument
   * (&quot;<code>log(x)</code>&quot;) can be parsed as
   * <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error, as
   * desired.  These three possible behaviors are indicated, respectively, by
   * the values
   * @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t},
   * @sbmlconstant{L3P_PARSE_LOG_AS_LN,ParseLogType_t}, and
   * @sbmlconstant{L3P_PARSE_LOG_AS_ERROR,ParseLogType_t}.
   *
   * @return One of following three constants:
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_LOG10,ParseLogType_t}
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_LN,ParseLogType_t}
   * @li @sbmlconstant{L3P_PARSE_LOG_AS_ERROR,ParseLogType_t}
   *
   * @see setParseLog(@if java int@endif)
   */
  ParseLogType_t getParseLog() const;


  /**
   * Sets the behavior for handling unary minuses appearing in mathematical
   * formulas.
   *
   * @copydetails doc_unary_minus_settings
   *
   * This method lets you tell the parser which behavior to use---either
   * collapse minuses or always preserve them.  The two possibilities are
   * represented using the following constants:
   *
   * @copydetails doc_unary_minus_values
   *
   * @param collapseminus a boolean value (one of the constants
   * @sbmlconstant{L3P_COLLAPSE_UNARY_MINUS,} or
   * @sbmlconstant{L3P_EXPAND_UNARY_MINUS,})
   * indicating how unary minus signs in the input should be handled.
   *
   * @see getParseCollapseMinus()
   */
  void setParseCollapseMinus(bool collapseminus);


  /**
   * Indicates the current behavior set for handling multiple unary minuses
   * in formulas.
   *
   * @copydetails doc_unary_minus_settings
   *
   * @return A boolean indicating the behavior currently set.  The possible
   * values are as follows:
   * @copydetails doc_unary_minus_values
   *
   * @see setParseCollapseMinus(@if java boolean@endif)
   */
  bool getParseCollapseMinus() const;


  /**
   * Sets the parser's behavior in handling units associated with numbers
   * in a mathematical formula.
   *
   * @copydetails doc_parsing_units
   *
   * This method sets the formula parser's behavior with respect to units.
   *
   * @param units A boolean indicating whether to parse units.  The
   * possible values are as follows:
   * @copydetails doc_parsing_units_values
   *
   * @see getParseUnits()
   */
  void setParseUnits(bool units);


  /**
   * Indicates the current behavior set for handling units in text-string
   * mathematical formulas.
   *
   * @copydetails doc_parsing_units
   *
   * Since SBML Level&nbsp;2 does not have the ability to associate units
   * with pure numbers, the value should be expected to be @c false
   * (@sbmlconstant{L3P_NO_UNITS,}) when parsing text-string
   * formulas intended for use in SBML Level&nbsp;2 documents.
   *
   * @return A boolean indicating whether to parse units.  The
   * possible values are as follows:
   * @copydetails doc_parsing_units_values
   *
   * @see setParseUnits(@if java boolean@endif)
   */
  bool getParseUnits() const;


  /**
   * Sets the parser's behavior in handling the symbol @c avogadro in
   * mathematical formulas.
   *
   * @copydetails doc_parsing_avogadro
   *
   * This method allows callers to set the <code>avogadro</code>-handling
   * behavior in this L3ParserSettings object.  The possible values of @p
   * l2only are as follows:
   *
   * @copydetails doc_avogadro_values
   *
   * Since SBML Level&nbsp;2 does not define a symbol for Avogadro's
   * constant, the value should be set to
   * @sbmlconstant{L3P_AVOGADRO_IS_NAME,} when parsing text-string formulas
   * intended for use in SBML Level&nbsp;2 documents.
   *
   * @param l2only a boolean value indicating how the string @c avogadro
   * should be treated when encountered in a formula.  This will be one of
   * the values @sbmlconstant{L3P_AVOGADRO_IS_CSYMBOL,} or
   * @sbmlconstant{L3P_AVOGADRO_IS_NAME,}.
   *
   * @see getParseAvogadroCsymbol()
   */
  void setParseAvogadroCsymbol(bool l2only);


  /**
   * Indicates the current behavior set for handling @c avogadro for SBML
   * Level&nbsp;3.
   *
   * @copydetails doc_parsing_avogadro
   *
   * This method returns the current setting of the
   * <code>avogadro</code>-handling behavior in this L3ParserSettings object.
   * The possible values are as follows:
   *
   * @copydetails doc_avogadro_values
   *
   * @return A boolean indicating which mode is currently set; one of
   * @sbmlconstant{L3P_AVOGADRO_IS_CSYMBOL,}
   * or
   * @sbmlconstant{L3P_AVOGADRO_IS_NAME,}.
   *
   * @see setParseAvogadroCsymbol(@if java boolean@endif)
   */
  bool getParseAvogadroCsymbol() const;


  /**
   * Sets the parser's behavior with respect to case sensitivity for
   * recognizing predefined symbols.
   *
   * @copydetails doc_case_sensitivity
   *
   * @param strcmp a boolean indicating whether to be case sensitive (if @c
   * true) or be case insensitive (if @c false).
   *
   * @see getComparisonCaseSensitivity()
   */
  void setComparisonCaseSensitivity(bool strcmp);


  /**
   * Returns @c true if the parser is configured to match built-in symbols
   * in a case-insensitive way.
   *
   * @copydetails doc_case_sensitivity
   *
   * @return @c true if matches are done in a case-sensitive manner, and 
   * @c false if the parser will recognize built-in functions and
   * constants regardless of case,.
   *
   * @see setComparisonCaseSensitivity(@if java boolean@endif)
   */
  bool getComparisonCaseSensitivity() const;


  /**
   * Set up the plugins for this L3ParserSettings, based on the
   * SBMLNamespaces object.
   *
   * When a SBMLNamespaces object is provided, the parser will only interpret
   * infix syntax understood by the core libSBML @em plus the packages
   * indicated by the SBMLNamespaces objects provided.  ASTNode objects
   * returned by the L3Parser will contain those SBMLNamespaces objects, and
   * will be used to parse certain constructs that may only be understood by
   * packages (e.g., vectors for the SBML Level&nbsp;3 "arrays" package).
   * Note that by default, all packages that were compiled with this version
   * of libSBML are included, so this function is most useful as a way to
   * turn @em off certain namespaces, such as might be desired if your tool
   * does not support vectors, for example.
   *
   * @param sbmlns a SBMLNamespaces object to be used.  If @c NULL is given
   * as the value, all plugins will be loaded.
   */
  void setPlugins(const SBMLNamespaces * sbmlns);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Visits the given ASTNode_t and continues the inorder traversal for nodes
   * whose syntax are determined by packages.
   */
  void visitPackageInfixSyntax ( const ASTNode_t *parent,
                            const ASTNode_t *node,
                            StringBuffer_t  *sb) const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  friend class L3Parser;
  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */

  /**
   * This function checks the provided ASTNode function to see if it is a
   * known function with the wrong number of arguments.  If so, the error is
   * set and 'true' is returned.  If the correct number of arguments is
   * provided, 'false' is returned.  It is used for ASTNodes created from
   * packages.
   */
  bool checkNumArgumentsForPackage(const ASTNode* function,
                                   std::stringstream& error) const;


  /**
   * The generic parsing function for grammar lines that packages recognize,
   * but not core.  When a package recognizes the 'type', it will parse and
   * return the correct ASTNode.  If it does not recognize the 'type', or if
   * the arguments are incorrect, NULL is returned.
   */
  virtual ASTNode* parsePackageInfix(L3ParserGrammarLineType_t type, 
                                     std::vector<ASTNode*> *nodeList = NULL,
                                     std::vector<std::string*> *stringList = NULL,
                                     std::vector<double> *doubleList = NULL) const;


  /**
   * The user input a string of the form "name(...)", and we want to know if
   * 'name' is recognized by a package as being a particular function.  We
   * already know that it is not used in the Model as a FunctionDefinition.
   * Should do caseless string comparison.  Return the type of the function,
   * or AST_UNKNOWN if nothing found.
   */
  int getPackageFunctionFor(const std::string& name) const;


  /**
   * Delete the plugin objects.
   */
  void deletePlugins();

  /** @endcond */
};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new L3ParserSettings_t structure and returns a pointer to it
 *
 * @note This functions sets the Model* to NULL, and other settings to 
 * L3P_PARSE_LOG_AS_LOG10, L3P_EXPAND_UNARY_MINUS, L3P_PARSE_UNITS, 
 * and L3P_AVOGADRO_IS_CSYMBOL.
 *
 * @return a pointer to the newly created L3ParserSettings_t structure.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
L3ParserSettings_t *
L3ParserSettings_create ();


/**
 * Frees the given L3ParserSettings_t structure.
 *
 * @param settings the L3ParserSettings_t to free
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_free (L3ParserSettings_t * settings);


/**
 * Sets the model associated with this L3ParserSettings_t structure
 * to the provided pointer.
 *
 * @note A copy of the Model_t is not made, so modifications to the Model_t
 * itself may affect future parsing.
 *
 * @param settings the L3ParserSettings_t structure on which to set the Model_t.
 * @param model The Model_t structure to which infix strings are to be compared.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_setModel (L3ParserSettings_t * settings, const Model_t * model);


/**
 * Retrieves the model associated with this L3ParserSettings_t structure.
 *
 * @param settings the L3ParserSettings_t structure from which to get the Model_t.
 *
 * @return the Model_t structure associated with this L3ParserSettings_t structure.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
const Model_t *
L3ParserSettings_getModel (const L3ParserSettings_t * settings);


/**
 * Unsets the model associated with this L3ParserSettings_t structure.
 *
 * @param settings the L3ParserSettings_t structure on which to unset the Model_t.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_unsetModel (L3ParserSettings_t * settings);


/**
 * Sets the log parsing option associated with this L3ParserSettings_t structure.  
 *
 * This option allows the user to specify how the infix expression 'log(x)'
 * is parsed in a MathML ASTNode. The options are:
 * @li L3P_PARSE_LOG_AS_LOG10 (0)
 * @li L3P_PARSE_LOG_AS_LN (1)
 * @li L3P_PARSE_LOG_AS_ERROR (2)
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param type ParseLogType_t log parsing option to associate with this 
 * L3ParserSettings_t structure.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseLog (L3ParserSettings_t * settings, ParseLogType_t type);


/**
 * Retrieves the log parsing option associated with this L3ParserSettings_t structure.  
 *
 * This option allows the user to specify how the infix expression 'log(x)'
 * is parsed in a MathML ASTNode. The options are:
 * @li L3P_PARSE_LOG_AS_LOG10 (0)
 * @li L3P_PARSE_LOG_AS_LN (1)
 * @li L3P_PARSE_LOG_AS_ERROR (2)
 *
 * @param settings the L3ParserSettings_t structure on which to set the Model_t.
 *
 * @return ParseLogType_t log parsing option to associate with this 
 * L3ParserSettings_t structure.  Returns L3P_PARSE_LOG_AS_LOG10 (0) if @param settings
 * is NULL.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
ParseLogType_t
L3ParserSettings_getParseLog (const L3ParserSettings_t * settings);


/**
 * Sets the collapse minus option associated with this L3ParserSettings_t structure.  
 *
 * This option allows the user to specify how the infix expression '-4'
 * is parsed in a MathML ASTNode. 
 * 
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether unary minus should be collapsed 
 * (non-zero) or not (zero).
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseCollapseMinus (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the collapse minus option associated with this L3ParserSettings_t structure.  
 *
 * This option allows the user to specify how the infix expression '-4'
 * is parsed in a MathML ASTNode. 
 * 
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether unary minus should be collapsed 
 * (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseCollapseMinus (const L3ParserSettings_t * settings);


/**
 * Sets the units option associated with this L3ParserSettings_t structure.  
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether numbers should be considered as 
 * a having units (non-zero) or not (zero).
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseUnits (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the units option associated with this L3ParserSettings_t structure.  
 *
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether numbers should be considered as 
 * a having units (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseUnits (const L3ParserSettings_t * settings);


/**
 * Sets the avogadro csymbol option associated with this L3ParserSettings_t structure.  
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether avogadro should be considered as 
 * a csymbol (non-zero) or not (zero).
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseAvogadroCsymbol (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the avogadro csymbol option associated with this L3ParserSettings_t structure.  
 *
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether avogadro should be considered as 
 * a csymbol (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 *
 * @memberof L3ParserSettings_t
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseAvogadroCsymbol (const L3ParserSettings_t * settings);


/**
 * Visits the given ASTNode_t and continues the inorder traversal for nodes
 * whose syntax are determined by packages.
 */
void
L3ParserSettings_visitPackageInfixSyntax ( const ASTNode_t *parent,
                                           const ASTNode_t *node,
                                           StringBuffer_t  *sb, 
                                           const L3ParserSettings_t *settings );


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif

#endif /* L3ParserSettings_h */
