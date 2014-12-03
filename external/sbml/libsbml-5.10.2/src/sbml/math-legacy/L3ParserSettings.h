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
 * @if clike SBML_parseL3FormulaWithSettings()@endif@if csharp SBML_parseL3FormulaWithSettings()@endif@if python libsbml.parseL3FormulaWithSettings()@endif@if java <code><a href="libsbml.html#parseL3FormulaWithSettings(java.lang.String, org.sbml.libsbml.L3ParserSettings)">libsbml.parseL3FormulaWithSettings(String formula, L3ParserSettings settings)</a></code>@endif@~,
 * along with its variants
 * @if clike SBML_parseFormula()@endif@if csharp SBML_parseFormula()@endif@if python libsbml.parseFormula()@endif@if java <code><a href="libsbml.html#parseFormula(java.lang.String)">libsbml.parseFormula(java.lang.String formula)</a></code>@endif@~
 * and
 * @if clike SBML_parseL3FormulaWithModel()@endif@if csharp SBML_parseL3FormulaWithModel()@endif@if python libsbml.parseL3FormulaWithModel()@endif@if java <code><a href="libsbml.html#parseL3FormulaWithModel(java.lang.String, org.sbml.libsbml.Model)">libsbml.parseL3FormulaWithModel(String formula, Model model)</a></code>@endif@~,
 * are the interfaces to a parser for mathematical formulas expressed as
 * text strings.  The parser converts the text-string formulas into
 * Abstract Syntax Trees (ASTs), represented in libSBML using ASTNode
 * objects. Compared to the parser implemented by the function
 * @if clike SBML_parseFormula()@endif@if csharp SBML_parseFormula()@endif@if python libsbml.parseFormula()@endif@if java <code><a href="libsbml.html#parseFormula(java.lang.String)">libsbml.parseFormula(java.lang.String formula)</a></code>@endif@~,
 * which was designed primarily for converting the mathematical formula
 * strings in SBML Level&nbsp;1, the "L3" variant of the parser accepts an
 * extended formula syntax.  It also has a number of configurable behaviors.
 * This class (L3ParserSettings) is an object used to communicate the
 * configuration settings with callers.
 *
 * The following aspects of the parser are configurable:
 * <ul>
 * <li> The function @c log with a single argument (&quot;<code>log(x)</code>&quot;)
 * can be parsed as <code>log10(x)</code>, <code>ln(x)</code>, or treated
 * as an error, as desired.
 * <li> Unary minus signs can be collapsed or preserved; that is,
 * sequential pairs of unary minuses (e.g., &quot;<code>- -3</code>&quot;)
 * can be removed from the input entirely and single unary minuses can be
 * incorporated into the number node, or all minuses can be preserved in
 * the AST node structure.
 * <li> Parsing of units embedded in the input string can be turned on and
 * off.
 * <li> The string @c avogadro can be parsed as a MathML @em csymbol or
 * as an identifier.
 * <li> A Model object may optionally be provided to the parser using
 * the variant function call @if clike  SBML_parseL3FormulaWithModel()@endif@if csharp  SBML_parseL3FormulaWithModel()@endif@if python  libsbml.SBML_parseL3FormulaWithModel()@endif@if java <code><a href="libsbml.html#parseL3FormulaWithModel(java.lang.String, org.sbml.libsbml.Model)">libsbml.parseL3FormulaWithModel(String formula, Model model)</a></code>@endif@~.
 * or stored in a L3ParserSettings object passed to the variant function
 * @if clike SBML_parseL3FormulaWithSettings()@endif@if csharp SBML_parseL3FormulaWithSettings()@endif@if python libsbml.parseL3FormulaWithSettings()@endif@if java <code><a href="libsbml.html#parseL3FormulaWithSettings(java.lang.String, org.sbml.libsbml.L3ParserSettings)">libsbml.parseL3FormulaWithSettings(String formula, org.sbml.libsbml.L3ParserSettings settings)</a></code>@endif@~.
 * When a Model object is provided, identifiers (values of type @c SId)
 * from that model are used in preference to pre-defined MathML
 * definitions.  More precisely, the Model entities whose identifiers will
 * shadow identical symbols in the mathematical formula are: Species,
 * Compartment, Parameter, Reaction, and SpeciesReference.  For instance,
 * if the parser is given a Model containing a Species with the identifier
 * &quot;<code>pi</code>&quot;, and the formula to be parsed is
 * &quot;<code>3*pi</code>&quot;, the MathML produced will contain the
 * construct <code>&lt;ci&gt; pi &lt;/ci&gt;</code> instead of the
 * construct <code>&lt;pi/&gt;</code>.
 * <li> Similarly, when a Model object is provided, @c SId values of
 * user-defined functions present in the Model will be used preferentially
 * over pre-defined MathML functions.  For example, if the passed-in Model
 * contains a FunctionDefinition with the identifier
 * &quot;<code>sin</code>&quot;, that function will be used instead of the
 * predefined MathML function <code>&lt;sin/&gt;</code>.
 * </ul>
 *
 * To obtain the default configuration values, callers can use the function
 * @if clike SBML_getDefaultL3ParserSettings()@endif@if csharp SBML_getDefaultL3ParserSettings()@endif@if python libsbml.SBML_getDefaultL3ParserSettings()@endif@if java <code><a href="libsbml.html#getDefaultL3ParserSettings()">libsbml.getDefaultL3ParserSettings()</a></code>@endif@~.
 * To change the configuration, callers can create an L3ParserSettings
 * object, set the desired characteristics using the methods
 * provided, and pass that object to
 * @if clike SBML_parseL3FormulaWithSettings()@endif@if csharp SBML_parseL3FormulaWithSettings()@endif@if python libsbml.parseL3FormulaWithSettings()@endif@if java <a href="libsbml.html#parseL3FormulaWithSettings(java.lang.String, org.sbml.libsbml.L3ParserSettings)"><code>libsbml.parseL3FormulaWithSettings(String formula, L3ParserSettings settings)</code></a>@endif@~.
 *
 * @if clike @see SBML_parseL3FormulaWithSettings()
 * @see SBML_parseL3Formula()
 * @see SBML_parseL3FormulaWithModel()
 * @endif@~
 * @if csharp @see SBML_parseL3FormulaWithSettings()
 * @see SBML_parseL3Formula()
 * @see SBML_parseL3FormulaWithModel()
 * @endif@~
 * @if python @see libsbml.parseL3FormulaWithSettings()
 * @see libsbml.parseL3Formula()
 * @see libsbml.parseL3FormulaWithModel()
 * @endif@~
 * @if java @see <code><a href="libsbml.html#parseL3FormulaWithSettings(java.lang.String, org.sbml.libsbml.L3ParserSettings)">libsbml.parseL3FormulaWithSettings(String formula, L3ParserSettings settings)</a></code>
 * @see <code><a href="libsbml.html#parseL3Formula(java.lang.String)">libsbml.parseL3Formula(String formula)</a></code>
 * @see <code><a href="libsbml.html#parseL3FormulaWithModel(java.lang.String, org.sbml.libsbml.Model)">parseL3FormulaWithModel(String formula, Model model)</a></code>
 * @endif@~
 */

#ifndef L3ParserSettings_h
#define L3ParserSettings_h

#include <sbml/common/libsbml-namespace.h>
#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


/**
 * @enum ParseLogType_t
 * @brief Configuration values for handling @c log in formulas.
 *
 * The L3ParserSettings object can be used to modify the SBML L3 parser to translate the function <code>log(x)</code> three different ways, each settable with this type enum.
 *
 * @see L3ParserSettings
 * @if clike @see SBML_parseL3FormulaWithSettings()
 * @endif@~
 * @if csharp @see SBML_parseL3FormulaWithSettings()
 * @endif@~
 * @if python @see libsbml.parseL3FormulaWithSettings()
 * @endif@~
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


#define L3P_COLLAPSE_UNARY_MINUS true
/*!<
 * Collapse unary minuses where possible.
 * @see getParseCollapseMinus()
 * @see setParseCollapseMinus()
 */
#define L3P_EXPAND_UNARY_MINUS   false
/*!<
 * Retain unary minuses in the AST representation.
 * @see getParseCollapseMinus()
 * @see setParseCollapseMinus()
 */

#define L3P_PARSE_UNITS  true
/*!<
 * Parse units in text-string formulas.
 * @see setParseCollapseMinus()
 * @see getParseCollapseMinus()
 */
#define L3P_NO_UNITS false
/*!<
 * Do not recognize units in text-string formulas---treat them as errors.
 * @see setParseCollapseMinus()
 * @see getParseCollapseMinus()
 */

#define L3P_AVOGADRO_IS_CSYMBOL true
/*!<
 * Recognize 'avogadro' as an SBML Level 3 symbol.
 * @see getParseAvogadroCsymbol()
 * @see setParseAvogadroCsymbol()
 */
#define L3P_AVOGADRO_IS_NAME    false
/*!<
 * Do not treat 'avogadro' specially---consider it a plain symbol name.
 * @see getParseAvogadroCsymbol()
 * @see setParseAvogadroCsymbol()
 */

#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN

class Model;

class LIBSBML_EXTERN L3ParserSettings
{
private:
  const Model* mModel;
  ParseLogType_t mParselog;
  bool mCollapseminus;
  bool mParseunits;
  bool mAvoCsymbol;

public:

  /**
   * Creates a new L3ParserSettings object with default values.
   *
   * This is the default constructor for the L3ParserSettings object.  It
   * sets the Model to @c NULL and other settings to @c
   * L3P_PARSE_LOG_AS_LOG10, @c L3P_EXPAND_UNARY_MINUS, @c L3P_PARSE_UNITS,
   * and @c L3P_AVOGADRO_IS_CSYMBOL.
   */
  L3ParserSettings();


  /**
   * Creates a new L3ParserSettings object with specific values for all
   * possible settings.
   *
   * @param model a Model object to be used for disambiguating identifiers
   *
   * @param parselog a flag that controls how the parser will handle
   * the symbol @c log in formulas
   *
   * @param collapseminus a flag that controls how the parser will handle
   * minus signs
   *
   * @param parseunits a flag that controls how the parser will handle
   * apparent references to units of measurement associated with raw
   * numbers in a formula
   *
   * @param avocsymbol a flag that controls how the parser will handle
   * the appearance of the symbol @c avogadro in a formula
   *
   * @see getModel()
   * @see setModel(@if java Model model@endif)
   * @see unsetModel()
   * @see getParseLog()
   * @see setParseLog(@if java int type@endif)
   * @see getParseUnits()
   * @see setParseUnits(@if java boolean units@endif)
   * @see getParseCollapseMinus()
   * @see setParseCollapseMinus(@if java boolean collapseminus@endif)
   * @see getParseAvogadroCsymbol()
   * @see setParseAvogadroCsymbol(@if java boolean l2only@endif)
   */
  L3ParserSettings(Model* model, ParseLogType_t parselog,
                   bool collapseminus, bool parseunits, bool avocsymbol);


  /**
   * Destroys this L3ParserSettings object.
   */
  ~L3ParserSettings();


  /**
   * Sets the model reference in this L3ParserSettings object.
   *
   * When a Model object is provided, identifiers (values of type @c SId)
   * from that model are used in preference to pre-defined MathML
   * definitions.  More precisely, the Model entities whose identifiers will
   * shadow identical symbols in the mathematical formula are: Species,
   * Compartment, Parameter, Reaction, and SpeciesReference.  For instance,
   * if the parser is given a Model containing a Species with the identifier
   * &quot;<code>pi</code>&quot;, and the formula to be parsed is
   * &quot;<code>3*pi</code>&quot;, the MathML produced will contain the
   * construct <code>&lt;ci&gt; pi &lt;/ci&gt;</code> instead of the
   * construct <code>&lt;pi/&gt;</code>.
   * Similarly, when a Model object is provided, @c SId values of
   * user-defined functions present in the Model will be used preferentially
   * over pre-defined MathML functions.  For example, if the passed-in Model
   * contains a FunctionDefinition with the identifier
   * &quot;<code>sin</code>&quot;, that function will be used instead of the
   * predefined MathML function <code>&lt;sin/&gt;</code>.
   *
   * @param model a Model object to be used for disambiguating identifiers
   *
   * @warning <span class="warning">This does @em not copy the Model object.
   * This means that modifications made to the object after invoking this
   * method may affect parsing behavior.</span>
   *
   * @see getModel()
   * @see unsetModel()
   */
  void setModel(const Model* model);


  /**
   * Returns the Model object referenced by this L3ParserSettings object.
   *
   * @see setModel(@if java Model model@endif)
   * @see unsetModel()
   */
  const Model* getModel() const;


  /**
   * Sets the Model reference in this L3ParserSettings object to @c NULL.
   *
   * @see setModel(@if java Model model@endif)
   * @see getModel()
   */
  void unsetModel();


  /**
   * Sets the behavior for handling @c log in mathematical formulas.
   *
   * The function @c log with a single argument
   * (&quot;<code>log(x)</code>&quot;) can be parsed as
   * <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error, as
   * desired.
   *
   * @param type a constant, one of following three possibilities:
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_LOG10 L3P_PARSE_LOG_AS_LOG10@endlink
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_LN L3P_PARSE_LOG_AS_LN@endlink
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_ERROR L3P_PARSE_LOG_AS_ERROR@endlink
   *
   * @see getParseLog()
   */
  void setParseLog(ParseLogType_t type);


  /**
   * Returns the current setting indicating what to do with formulas
   * containing the function @c log with one argument.
   *
   * The function @c log with a single argument
   * (&quot;<code>log(x)</code>&quot;) can be parsed as
   * <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error, as
   * desired.
   *
   * @return One of following three constants:
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_LOG10 L3P_PARSE_LOG_AS_LOG10@endlink
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_LN L3P_PARSE_LOG_AS_LN@endlink
   * @li @link ParseLogType_t#L3P_PARSE_LOG_AS_ERROR L3P_PARSE_LOG_AS_ERROR@endlink
   *
   * @see setParseLog(@if java int type@endif)
   */
  ParseLogType_t getParseLog() const;


  /**
   * Sets the behavior for handling unary minuses appearing in mathematical
   * formulas.
   *
   * This setting affects two behaviors.  First, pairs of multiple unary
   * minuses in a row (e.g., &quot;<code>- -3</code>&quot;) can be
   * collapsed and ignored in the input, or the multiple minuses can be
   * preserved in the AST node tree that is generated by the parser.
   * Second, minus signs in front of numbers can be collapsed into the
   * number node itself; for example, a &quot;<code>- 4.1</code>&quot; can
   * be turned into a single ASTNode of type @link ASTNodeType_t#AST_REAL
   * AST_REAL@endlink with a value of <code>-4.1</code>, or it can be
   * turned into a node of type @link ASTNodeType_t#AST_MINUS
   * AST_MINUS@endlink having a child node of type @link
   * ASTNodeType_t#AST_REAL AST_REAL@endlink.  This method lets you tell
   * the parser which behavior to use---either collapse minuses or
   * always preserve them.  The two possibilities are represented using the
   * following constants:
   *
   * @li @link ParseLogType_t#L3P_COLLAPSE_UNARY_MINUS
   * L3P_COLLAPSE_UNARY_MINUS@endlink (value = @c true): collapse unary
   * minuses where possible.
   * @li @link ParseLogType_t#L3P_EXPAND_UNARY_MINUS
   * L3P_EXPAND_UNARY_MINUS@endlink (value = @c false): do not collapse
   * unary minuses, and instead translate each one into an AST node of type
   * @link ASTNodeType_t#AST_MINUS AST_MINUS@endlink.
   *
   * @param collapseminus a boolean value (one of the constants
   * @link ParseLogType_t#L3P_COLLAPSE_UNARY_MINUS
   * L3P_COLLAPSE_UNARY_MINUS@endlink or
   * @link ParseLogType_t#L3P_EXPAND_UNARY_MINUS
   * L3P_EXPAND_UNARY_MINUS@endlink) indicating how unary minus signs in
   * the input should be handled.
   *
   * @see getParseCollapseMinus()
   */
  void setParseCollapseMinus(bool collapseminus);


  /**
   * Returns a flag indicating the current behavior set for handling
   * multiple unary minuses in formulas.
   *
   * This setting affects two behaviors.  First, pairs of multiple unary
   * minuses in a row (e.g., &quot;<code>- -3</code>&quot;) can be
   * collapsed and ignored in the input, or the multiple minuses can be
   * preserved in the AST node tree that is generated by the parser.
   * Second, minus signs in front of numbers can be collapsed into the
   * number node itself; for example, a &quot;<code>- 4.1</code>&quot; can
   * be turned into a single ASTNode of type @link ASTNodeType_t#AST_REAL
   * AST_REAL@endlink with a value of <code>-4.1</code>, or it can be
   * turned into a node of type @link ASTNodeType_t#AST_MINUS
   * AST_MINUS@endlink having a child node of type @link
   * ASTNodeType_t#AST_REAL AST_REAL@endlink.  This method lets you tell
   * the parser which behavior to use---either collapse minuses or
   * always preserve them.  The two possibilities are represented using the
   * following constants:
   *
   * @li @link ParseLogType_t#L3P_COLLAPSE_UNARY_MINUS
   * L3P_COLLAPSE_UNARY_MINUS@endlink (value = @c true): collapse unary
   * minuses where possible.
   * @li @link ParseLogType_t#L3P_EXPAND_UNARY_MINUS
   * L3P_EXPAND_UNARY_MINUS@endlink (value = @c false): do not collapse
   * unary minuses, and instead translate each one into an AST node of type
   * @link ASTNodeType_t#AST_MINUS AST_MINUS@endlink.
   *
   * @return A boolean, one of @link
   * ParseLogType_t#L3P_COLLAPSE_UNARY_MINUS
   * L3P_COLLAPSE_UNARY_MINUS@endlink or @link
   * ParseLogType_t#L3P_EXPAND_UNARY_MINUS L3P_EXPAND_UNARY_MINUS@endlink.
   *
   * @see setParseCollapseMinus(@if java boolean collapseminus@endif)
   */
  bool getParseCollapseMinus() const;


  /**
   * Sets the parser's behavior in handling units associated with numbers
   * in a mathematical formula.
   *
   * In SBML Level&nbsp;2, there is no means of associating a unit of
   * measurement with a pure number in a formula, while SBML Level&nbsp;3
   * does define a syntax for this.  In Level&nbsp;3, MathML
   * <code>&lt;cn&gt;</code> elements can have an attribute named @c units
   * placed in the SBML namespace, which can be used to indicate the units
   * to be associated with the number.  The text-string infix formula
   * parser allows units to be placed after raw numbers; they are
   * interpreted as unit identifiers for units defined by the SBML
   * specification or in the containing Model object.  Some examples
   * include: &quot;<code>4 mL</code>&quot;, &quot;<code>2.01
   * Hz</code>&quot;, &quot;<code>3.1e-6 M</code>&quot;, and
   * &quot;<code>(5/8) inches</code>&quot;.  To produce a valid SBML model,
   * there must either exist a UnitDefinition corresponding to the
   * identifier of the unit, or the unit must be defined in Table&nbsp;2 of
   * the SBML specification.
   *
   * @param units A boolean indicating whether to parse units:
   * @li @link ParseLogType_t#L3P_PARSE_UNITS L3P_PARSE_UNITS@endlink
   * (value = @c true): parse units in the text-string formula.
   * @li @link ParseLogType_t#L3P_NO_UNITS L3P_NO_UNITS@endlink (value = @c
   * false): treat units in the text-string formula as errors.
   *
   * @see getParseUnits()
   */
  void setParseUnits(bool units);


  /**
   * Returns @c if the current settings allow units in text-string
   * mathematical formulas.
   *
   * In SBML Level&nbsp;2, there is no means of associating a unit of
   * measurement with a pure number in a formula, while SBML Level&nbsp;3
   * does define a syntax for this.  In Level&nbsp;3, MathML
   * <code>&lt;cn&gt;</code> elements can have an attribute named @c units
   * placed in the SBML namespace, which can be used to indicate the units
   * to be associated with the number.  The text-string infix formula
   * parser allows units to be placed after raw numbers; they are
   * interpreted as unit identifiers for units defined by the SBML
   * specification or in the containing Model object.  Some examples
   * include: &quot;<code>4 mL</code>&quot;, &quot;<code>2.01
   * Hz</code>&quot;, &quot;<code>3.1e-6 M</code>&quot;, and
   * &quot;<code>(5/8) inches</code>&quot;.  To produce a valid SBML model,
   * there must either exist a UnitDefinition corresponding to the
   * identifier of the unit, or the unit must be defined in Table&nbsp;2 of
   * the SBML specification.
   *
   * Since SBML Level&nbsp;2 does not have the ability to associate units with
   * pure numbers, the value should be set to @c false when parsing text-string
   * formulas intended for use in SBML Level&nbsp;2 documents.
   *
   * @return A boolean indicating whether to parse units:
   * @li @link ParseLogType_t#L3P_PARSE_UNITS L3P_PARSE_UNITS@endlink
   * (value = @c true): parse units in the text-string formula.
   * @li @link ParseLogType_t#L3P_NO_UNITS L3P_NO_UNITS@endlink (value = @c
   * false): treat units in the text-string formula as errors.
   *
   * @see setParseUnits(@if java boolean units@endif)
   */
  bool getParseUnits() const;


  /**
   * Sets the parser's behavior in handling the string @c avogadro in
   * mathematical formulas.
   *
   * SBML Level&nbsp;3 defines a symbol for representing the value of
   * Avogadro's constant, but it is not defined in SBML Level&nbsp;2.  As a
   * result, the text-string formula parser must behave differently
   * depending on which SBML Level is being targeted.  The argument to this
   * method can be one of two values:
   *
   * @li @link ParseLogType_t#L3P_AVOGADRO_IS_CSYMBOL
   * L3P_AVOGADRO_IS_CSYMBOL@endlink (value = @c true): tells the parser to
   * translate the string @c avogadro (in any capitalization) into an AST
   * node of type @link ASTNodeType_t#AST_NAME_AVOGADRO
   * AST_NAME_AVOGADRO@endlink.
   * @li @link ParseLogType_t#L3P_AVOGADRO_IS_NAME
   * L3P_AVOGADRO_IS_NAME@endlink (value = @c false): tells the parser to
   * translate the string @c avogadro into an AST of type @link
   * ASTNodeType_t#AST_NAME AST_NAME@endlink.
   *
   * Since SBML Level&nbsp;2 does not define a symbol for Avogadro's
   * constant, the value should be set to @c false when parsing text-string
   * formulas intended for use in SBML Level&nbsp;2 documents.
   *
   * @param l2only a boolean value (one of the constants
   * @link ParseLogType_t#L3P_AVOGADRO_IS_CSYMBOL
   * L3P_AVOGADRO_IS_CSYMBOL@endlink or
   * @link ParseLogType_t#L3P_AVOGADRO_IS_NAME
   * L3P_AVOGADRO_IS_NAME@endlink) indicating how the string @c avogadro
   * should be treated when encountered in a formula.
   *
   * @see getParseAvogadroCsymbol()
   */
  void setParseAvogadroCsymbol(bool l2only);


  /**
   * Returns @c true if the current settings are oriented towards handling
   * @c avogadro for SBML Level&nbsp;3.
   *
   * SBML Level&nbsp;3 defines a symbol for representing the value of
   * Avogadro's constant, but it is not defined in SBML Level&nbsp;2.  As a
   * result, the text-string formula parser must behave differently
   * depending on which SBML Level is being targeted.
   *
   * @return A boolean indicating which mode is currently set; the value is
   * one of the following possibilities:
   * @li @link ParseLogType_t#L3P_AVOGADRO_IS_CSYMBOL
   * L3P_AVOGADRO_IS_CSYMBOL@endlink (value = @c true): tells the parser to
   * translate the string @c avogadro (in any capitalization) into an AST
   * node of type @link ASTNodeType_t#AST_NAME_AVOGADRO
   * AST_NAME_AVOGADRO@endlink.
   * @li @link ParseLogType_t#L3P_AVOGADRO_IS_NAME
   * L3P_AVOGADRO_IS_NAME@endlink (value = @c false): tells the parser to
   * translate the string @c avogadro into an AST of type @link
   * ASTNodeType_t#AST_NAME AST_NAME@endlink.
   *
   * @see setParseAvogadroCsymbol(@if java boolean l2only@endif)
   */
  bool getParseAvogadroCsymbol() const;
};


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new L3ParserSettings_t object and returns a pointer to it
 *
 * @note This functions sets the Model* to NULL, and other settings to
 * L3P_PARSE_LOG_AS_LOG10, L3P_EXPAND_UNARY_MINUS, L3P_PARSE_UNITS,
 * and L3P_AVOGADRO_IS_CSYMBOL.
 *
 * @return a pointer to the newly created L3ParserSettings_t structure.
 */
LIBSBML_EXTERN
L3ParserSettings_t *
L3ParserSettings_create ();


LIBSBML_EXTERN
void
L3ParserSettings_free (L3ParserSettings_t * settings);


/**
 * Sets the model associated with this L3ParserSettings_t object
 * to the provided pointer.
 *
 * @note A copy of the Model is not made, so modifications to the Model itself
 * may affect future parsing.
 *
 * @param settings the L3ParserSettings_t structure on which to set the Model.
 * @param model The Model* object to which infix strings are to be compared.
 */
LIBSBML_EXTERN
void
L3ParserSettings_setModel (L3ParserSettings_t * settings, const Model_t * model);


/**
 * Retrieves the model associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure from which to get the Model.
 *
 * @return the Model_t* object associated with this L3ParserSettings_t object.
 */
LIBSBML_EXTERN
const Model_t *
L3ParserSettings_getModel (const L3ParserSettings_t * settings);


/**
 * Unsets the model associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure on which to unset the Model.
 */
LIBSBML_EXTERN
void
L3ParserSettings_unsetModel (L3ParserSettings_t * settings);


/**
 * Sets the log parsing option associated with this L3ParserSettings_t object.
 *
 * This option allows the user to specify how the infix expression 'log(x)'
 * is parsed in a MathML ASTNode. The options are:
 * @li L3P_PARSE_LOG_AS_LOG10 (0)
 * @li L3P_PARSE_LOG_AS_LN (1)
 * @li L3P_PARSE_LOG_AS_ERROR (2)
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param type ParseLogType_t log parsing option to associate with this
 * L3ParserSettings_t object.
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseLog (L3ParserSettings_t * settings, ParseLogType_t type);


/**
 * Retrieves the log parsing option associated with this L3ParserSettings_t object.
 *
 * This option allows the user to specify how the infix expression 'log(x)'
 * is parsed in a MathML ASTNode. The options are:
 * @li L3P_PARSE_LOG_AS_LOG10 (0)
 * @li L3P_PARSE_LOG_AS_LN (1)
 * @li L3P_PARSE_LOG_AS_ERROR (2)
 *
 * @param settings the L3ParserSettings_t structure on which to set the Model.
 *
 * @return ParseLogType_t log parsing option to associate with this
 * L3ParserSettings_t object.  Returns L3P_PARSE_LOG_AS_LOG10 (0) if @param settings
 * is NULL.
 */
LIBSBML_EXTERN
ParseLogType_t
L3ParserSettings_getParseLog (const L3ParserSettings_t * settings);


/**
 * Sets the collapse minus option associated with this L3ParserSettings_t object.
 *
 * This option allows the user to specify how the infix expression '-4'
 * is parsed in a MathML ASTNode.
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether unary minus should be collapsed
 * (non-zero) or not (zero).
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseCollapseMinus (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the collapse minus option associated with this L3ParserSettings_t object.
 *
 * This option allows the user to specify how the infix expression '-4'
 * is parsed in a MathML ASTNode.
 *
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether unary minus should be collapsed
 * (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseCollapseMinus (const L3ParserSettings_t * settings);


/**
 * Sets the units option associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether numbers should be considered as
 * a having units (non-zero) or not (zero).
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseUnits (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the units option associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether numbers should be considered as
 * a having units (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseUnits (const L3ParserSettings_t * settings);


/**
 * Sets the avogadro csymbol option associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure on which to set the option.
 * @param flag an integer indicating whether avogadro should be considered as
 * a csymbol (non-zero) or not (zero).
 */
LIBSBML_EXTERN
void
L3ParserSettings_setParseAvogadroCsymbol (L3ParserSettings_t * settings, int flag);


/**
 * Retrieves the avogadro csymbol option associated with this L3ParserSettings_t object.
 *
 * @param settings the L3ParserSettings_t structure from which to get the option.
 *
 * @return an integer indicating whether avogadro should be considered as
 * a csymbol (non-zero) or not (zero).  Returns zero (0) if @param settings
 * is NULL.
 */
LIBSBML_EXTERN
int
L3ParserSettings_getParseAvogadroCsymbol (const L3ParserSettings_t * settings);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif

#endif /* L3ParserSettings_h */
