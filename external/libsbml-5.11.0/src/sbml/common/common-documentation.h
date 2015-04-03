/**
 * @file    common-documentation.h
 * @brief   Common text fragments used throughout libSBML's code documentation.
 * @author  Mike Hucka
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
 * This file contains no code; it simply defines text fragments used as
 * common documentation blocks in other libSBML files via the @copydetails
 * operator from Doxygen.  The use of @@class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  No classes are
 * actually defined, and symbols beginning with "doc_" are marked as ignored
 * in our Doxygen configuration.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_listof
 *
 * @par
 * The various ListOf___ @if conly structures @else classes@endif@~ in SBML
 * are merely containers used for organizing the main components of an SBML
 * model.  In libSBML's implementation, ListOf___
 * @if conly data structures @else classes@endif@~ are derived from the
 * intermediate utility @if conly structure @else class@endif@~ ListOf, which
 * is not defined by the SBML specifications but serves as a useful
 * programmatic construct.  ListOf is itself is in turn derived from SBase,
 * which provides all of the various ListOf___
 * @if conly data structures @else classes@endif@~ with common features
 * defined by the SBML specification, such as "metaid" attributes and
 * annotations.
 *
 * The relationship between the lists and the rest of an SBML model is
 * illustrated by the following (for SBML Level&nbsp;2 Version&nbsp;4):
 *
 * @htmlinclude listof-illustration.html
 *
 * Readers may wonder about the motivations for using the ListOf___
 * containers in SBML.  A simpler approach in XML might be to place the
 * components all directly at the top level of the model definition.  The
 * choice made in SBML is to group them within XML elements named after
 * %ListOf<em>Classname</em>, in part because it helps organize the
 * components.  More importantly, the fact that the container classes are
 * derived from SBase means that software tools can add information @em about
 * the lists themselves into each list container's "annotation".
 *
 * @see ListOfFunctionDefinitions
 * @see ListOfUnitDefinitions
 * @see ListOfCompartmentTypes
 * @see ListOfSpeciesTypes
 * @see ListOfCompartments
 * @see ListOfSpecies
 * @see ListOfParameters
 * @see ListOfInitialAssignments
 * @see ListOfRules
 * @see ListOfConstraints
 * @see ListOfReactions
 * @see ListOfEvents
 *
 * @if conly
 * @note In the C API for libSBML, functions that in other language APIs
 * would be inherited by the various ListOf___ structures not shown in the
 * pages for the individual ListOf___'s.  Instead, the functions are defined
 * on ListOf_t.  <strong>Please consult the documentation for ListOf_t for
 * the many common functions available for manipulating ListOf___
 * structures</strong>.  The documentation for the individual ListOf___
 * structures (ListOfCompartments_t, ListOfReactions_t, etc.) does not reveal
 * all of the functionality available. @endif@~
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_xmlnamespaces
 *
 * @par
 * In the XML representation of an SBML document, XML namespaces are used to
 * identify the origin of each XML construct used.  XML namespaces are
 * identified by their unique resource identifiers (URIs).  The core SBML
 * specifications stipulate the namespaces that must be used for core SBML
 * constructs; for example, all XML elements that belong to SBML Level&nbsp;3
 * Version&nbsp;1 Core must be placed in the XML namespace identified by the URI
 * <code>"http://www.sbml.org/sbml/level3/version1/core"</code>.  Individual
 * SBML Level&nbsp;3 packages define their own XML namespaces; for example,
 * all elements belonging to the SBML Level&nbsp;3 %Layout Version&nbsp;1
 * package must be placed in the XML namespace
 * <code>"http://www.sbml.org/sbml/level3/version1/layout/version1/"</code>.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_sbmlnamespaces
 *
 * @par
 * The SBMLNamespaces object encapsulates SBML Level/Version/namespaces
 * information.  It is used to communicate the SBML Level, Version, and (in
 * Level&nbsp;3) packages used in addition to SBML Level&nbsp;3 Core.  A
 * common approach to using libSBML's SBMLNamespaces facilities is to create an
 * SBMLNamespaces object somewhere in a program once, then hand that object
 * as needed to object constructors that accept SBMLNamespaces as arguments.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_SBMLDocument
 *
 * @par
 * LibSBML uses the class SBMLDocument as a top-level container for
 * storing SBML content and data associated with it (such as warnings and
 * error messages).  An SBML model in libSBML is contained inside an
 * SBMLDocument object.  SBMLDocument corresponds roughly to the class
 * <i>SBML</i> defined in the SBML Level&nbsp;3 and Level&nbsp;2
 * specifications, but it does not have a direct correspondence in SBML
 * Level&nbsp;1.  (But, it is created by libSBML no matter whether the
 * model is Level&nbsp;1, Level&nbsp;2 or Level&nbsp;3.)
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_required_attribute
 *
 * @par
 * SBML Level&nbsp;3 requires that every package defines an attribute named
 * "required" on the root <code>&lt;sbml&gt;</code> element in an SBML file
 * or data stream.  The attribute, being in the namespace of the Level&nbsp;3
 * package in question, must be prefixed by the XML namespace prefix
 * associated with the package.  The value of the "required" attribute
 * indicates whether constructs in that package may change the mathematical
 * interpretation of constructs defined in SBML Level&nbsp;3 Core.  A
 * "required" value of @c true indicates that the package may do so.  The
 * value of the attribute is set by the Level&nbsp;3 package specification,
 * and does @em not depend on the actual presence or absence of particular
 * package constructs in a given SBML document: in other words, if the
 * package specification defines any construct that can change the model's
 * meaning, the value of the "required" attribute must always be set to @c
 * true in any SBML document that uses the package.
 *
 * The XML namespace declaration for an SBML Level&nbsp;3 package is an
 * indication that a model makes use of features defined by that package,
 * while the "required" attribute indicates whether the features may be
 * ignored without compromising the mathematical meaning of the model.  Both
 * are necessary for a complete reference to an SBML Level&nbsp;3 package.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_metaid
 *
 * @par
 * The optional attribute named "metaid", present on every major SBML
 * component type, is for supporting metadata annotations using RDF (<a
 * href="http://www.w3.org/RDF/">Resource Description Format</a>).  The
 * attribute value has the data type <a
 * href="http://www.w3.org/TR/REC-xml/#id">XML <code>ID</code></a>, the XML
 * identifier type, which means each "metaid" value must be globally unique
 * within an SBML file.  The latter point is important, because the
 * uniqueness criterion applies across <em>any</em> attribute with type
 * <code>ID</code> anywhere in the file, not just the "metaid" attribute used
 * by SBML---something to be aware of if your application-specific XML
 * content inside the "annotation" subelement happens to use the XML
 * <code>ID</code> type.  Although SBML itself specifies the use of <a
 * href="http://www.w3.org/TR/REC-xml/#id">XML <code>ID</code></a> only for
 * the "metaid" attribute, SBML-compatible applications should be careful if
 * they use XML <code>ID</code>'s in XML portions of a model that are not
 * defined by SBML, such as in the application-specific content of the
 * "annotation" subelement.  Finally, note that LibSBML does not provide an
 * explicit XML <code>ID</code> data type; it uses ordinary character
 * strings, which is easier for applications to support.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_sid
 *
 * @par
 * In SBML, identifiers that are the values of "id" attributes on objects
 * must conform to a data type called <code>SId</code> in the SBML
 * specifications.  LibSBML does not provide an explicit <code>SId</code>
 * data type; it uses ordinary character strings, which is easier for
 * applications to support.  (LibSBML does, however, test for identifier
 * validity at various times, such as when reading in models from files
 * and data streams.)
 *
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_sidref
 *
 * @par

 * In SBML, object identifiers are of a data type called <code>SId</code>.
 * In SBML Level&nbsp;3, an explicit data type called <code>SIdRef</code> was
 * introduced for attribute values that refer to <code>SId</code> values; in
 * previous Levels of SBML, this data type did not exist and attributes were
 * simply described to as "referring to an identifier", but the effective
 * data type was the same as <code>SIdRef</code>in Level&nbsp;3.  These and
 * other methods of libSBML refer to the type <code>SIdRef</code> for all
 * Levels of SBML, even if the corresponding SBML specification did not
 * explicitly name the data type.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_unitsidref
 *
 * @par
 * In SBML, unit definitions have identifiers of type <code>UnitSId</code>.  In
 * SBML Level&nbsp;3, an explicit data type called <code>UnitSIdRef</code> was
 * introduced for attribute values that refer to <code>UnitSId</code> values; in
 * previous Levels of SBML, this data type did not exist and attributes were
 * simply described to as "referring to a unit identifier", but the effective
 * data type was the same as <code>UnitSIdRef</code> in Level&nbsp;3.  These and
 * other methods of libSBML refer to the type <code>UnitSIdRef</code> for all
 * Levels of SBML, even if the corresponding SBML specification did not
 * explicitly name the data type.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_metaidref
 *
 * @par
 * In SBML, object "meta" identifiers are of the XML data type <code>ID</code>;
 * the SBML object attribute itself is typically named <code>metaid</code>.  All
 * attributes that hold values <em>referring</em> to values of type
 * <code>ID</code> are of the XML data type <code>IDREF</code>.  They are also
 * sometimes informally referred to as "metaid refs", in analogy to the
 * SBML-defined type <code>SIdRef</code>.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_id_syntax
 *
 * @par
 * SBML has strict requirements for the syntax of identifiers, that is, the
 * values of the "id" attribute present on most types of SBML objects.
 * The following is a summary of the definition of the SBML identifier type
 * <code>SId</code>, which defines the permitted syntax of identifiers.  We
 * express the syntax using an extended form of BNF notation:
 * <pre style="margin-left: 2em; border: none; font-weight: bold; font-size: 13px; color: black">
 * letter ::= 'a'..'z','A'..'Z'
 * digit  ::= '0'..'9'
 * idChar ::= letter | digit | '_'
 * SId    ::= ( letter | '_' ) idChar*</pre>
 * The characters <code>(</code> and <code>)</code> are used for grouping, the
 * character <code>*</code> "zero or more times", and the character
 * <code>|</code> indicates logical "or".  The equality of SBML identifiers is
 * determined by an exact character sequence match; i.e., comparisons must be
 * performed in a case-sensitive manner.  In addition, there are a few
 * conditions for the uniqueness of identifiers in an SBML model.  Please
 * consult the SBML specifications for the exact details of the uniqueness
 * requirements.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_base_units
 *
 * @par
<table border="0" class="centered text-table width80 normal-font code"
       style="border: none !important">
<tr>
<td>ampere</td><td>farad</td><td>joule</td><td>lux</td><td>radian</td><td>volt</td>
</tr>
<tr>
<td>avogadro</td><td>gram</td><td>katal</td><td>metre</td><td>second</td><td>watt</td>
</tr>
<tr>
<td>becquerel</td><td>gray</td><td>kelvin</td><td>mole</td><td>siemens</td><td>weber</td>
</tr>
<tr>
<td>candela</td><td>henry</td><td>kilogram</td><td>newton</td><td>sievert</td>
</tr>
<tr>
<td>coulomb</td><td>hertz</td><td>litre</td><td>ohm</td><td>steradian</td>
</tr>
<tr>
<td>dimensionless</td><td>item</td><td>lumen</td><td>pascal</td><td>tesla</td>
</tr>
</table>
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_typecodes
 *
 * @par
 * LibSBML attaches an identifying code to every kind of SBML object.  These
 * are integer constants known as <em>SBML type codes</em>.  The names of all
 * the codes begin with the characters <code>SBML_</code>.
 * @if clike The set of possible type codes for core elements is defined in
 * the enumeration #SBMLTypeCode_t, and in addition, libSBML plug-ins for
 * SBML Level&nbsp;3 packages define their own extra enumerations of type
 * codes (e.g., #SBMLLayoutTypeCode_t for the Level&nbsp;3 Layout
 * package).@endif@if java In the Java language interface for libSBML, the
 * type codes are defined as static integer constants in the interface class
 * {@link libsbmlConstants}.  @endif@if python In the Python language
 * interface for libSBML, the type codes are defined as static integer
 * constants in the interface class @link libsbml@endlink.@endif@if csharp In
 * the C# language interface for libSBML, the type codes are defined as
 * static integer constants in the interface class
 * @link libsbmlcs.libsbml@endlink.@endif@~  Note that different Level&nbsp;3
 * package plug-ins may use overlapping type codes; to identify the package
 * to which a given object belongs, call the <code>getPackageName()</code>
 * method on the object.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_warning_typecodes_not_unique
 *
 * @warning <span class="warning">The specific integer values of the possible
 * type codes may be reused by different Level&nbsp;3 package plug-ins.
 * Thus, to identifiy the correct code, <strong>it is necessary to invoke
 * both getTypeCode() and getPackageName()</strong>.</span>
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_plugins
 *
 * @par
 * SBML Level&nbsp;3 consists of a <em>Core</em> definition that can be extended
 * via optional SBML Level&nbsp;3 <em>packages</em>.  A given model may indicate
 * that it uses one or more SBML packages, and likewise, a software tool may be
 * able to support one or more packages.  LibSBML does not come preconfigured
 * with all possible packages included and enabled, in part because not all
 * package specifications have been finalized.  To support the ability for
 * software systems to enable support for the Level&nbsp;3 packages they choose,
 * libSBML features a <em>plug-in</em> mechanism.  Each SBML Level&nbsp;3
 * package is implemented in a separate code plug-in that can be enabled by the
 * application to support working with that SBML package.  A given SBML model
 * may thus contain not only objects defined by SBML Level&nbsp;3 Core, but also
 * objects created by libSBML plug-ins supporting additional Level&nbsp;3
 * packages.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_notes
 *
 * @par
 * The optional SBML element named "notes", present on every major SBML
 * component type (and in SBML Level&nbsp;3, the "message" subelement of
 * Constraint), is intended as a place for storing optional information
 * intended to be seen by humans.  An example use of the "notes" element
 * would be to contain formatted user comments about the model element in
 * which the "notes" element is enclosed.  Every object derived directly or
 * indirectly from type SBase can have a separate value for "notes", allowing
 * users considerable freedom when adding comments to their models.
 *
 * The format of "notes" elements conform to the definition of <a
 * target="_blank" href="http://www.w3.org/TR/xhtml1/">XHTML&nbsp;1.0</a>.
 * However, the content cannot be @em entirely free-form; it must satisfy
 * certain requirements defined in the <a target="_blank"
 * href="http://sbml.org/Documents/Specifications">SBML specifications</a>
 * for specific SBML Levels.  To help verify the formatting of "notes"
 * content, libSBML provides the static utility method
 * SyntaxChecker::hasExpectedXHTMLSyntax(@if java XMLNode@endif); this
 * method implements a verification process that lets callers check whether
 * the content of a given XMLNode object conforms to the SBML requirements
 * for "notes" and "message" structure.  Developers are urged to consult the
 * appropriate <a target="_blank"
 * href="http://sbml.org/Documents/Specifications">SBML specification
 * document</a> for the Level and Version of their model for more in-depth
 * explanations of using "notes" in SBML.  The SBML Level&nbsp;2 and &nbsp;3
 * specifications have considerable detail about how "notes" element content
 * must be structured.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_annotations
 *
 * @par
 * Whereas the SBML "notes" subelement is a container for content to be
 * shown directly to humans, the "annotation" element is a container for
 * optional software-generated content @em not meant to be shown to
 * humans.  Every object derived from SBase can have its own value for
 * "annotation".  The element's content type is <a target="_blank"
 * href="http://www.w3.org/TR/2004/REC-xml-20040204/#elemdecls">XML type
 * "any"</a>, allowing essentially arbitrary well-formed XML data
 * content.
 *
 * SBML places a few restrictions on the organization of the content of
 * annotations; these are intended to help software tools read and write
 * the data as well as help reduce conflicts between annotations added by
 * different tools.  Please see the SBML specifications for more details.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_are_cvterms
 *
 * @par
 * The SBML Level&nbsp;2 and Level&nbsp;3 specifications define a simple
 * format for annotating models when (a) referring to controlled
 * vocabulary terms and database identifiers that define and describe
 * biological and other entities, and (b) describing the creator of a
 * model and the model's modification history.  The annotation content is
 * stored in <code>&lt;annotation&gt;</code> elements attached to
 * individual SBML elements.  The format for storing the content inside
 * SBML <code>&lt;annotation&gt;</code> elements is a subset of W3C RDF
 * (<a target="_blank" href="http://www.w3.org/RDF/">Resource Description
 * Format</a>) expressed in XML.  The CVTerm class provides a programming
 * interface for working directly with controlled vocabulary term ("CV
 * term") objects without having to deal directly with the XML form.
 * When libSBML reads in an SBML model containing RDF annotations, it
 * parses those annotations into a list of CVTerm objects, and when
 * writing a model, it parses the CVTerm objects back into the
 * appropriate SBML <code>&lt;annotation&gt;</code> structure.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_astnode
 *
 * @par
 * An AST @em node in libSBML is a recursive tree structure; each node has a
 * type, a pointer to a value, and a list of children nodes.  Each ASTNode
 * node may have none, one, two, or more children depending on its type.
 * There are node types to represent numbers (with subtypes to distinguish
 * integer, real, and rational numbers), names (e.g., constants or
 * variables), simple mathematical operators, logical or relational operators
 * and functions.  The following diagram illustrates an example of how the
 * mathematical expression <code>"1 + 2"</code> is represented as an AST with
 * one @em plus node having two @em integer children nodes for the numbers
 * <code>1</code> and <code>2</code>.  The figure also shows the
 * corresponding MathML representation:
 *
 * @htmlinclude astnode-illustration.html
 *
 * The following are other noteworthy points about the AST representation
 * in libSBML:

 * @li A numerical value represented in MathML as a real number with an
 * exponent is preserved as such in the AST node representation, even if the
 * number could be stored in a @c double data type.  This is done so that
 * when an SBML model is read in and then written out again, the amount of
 * change introduced by libSBML to the SBML during the round-trip activity is
 * minimized.
 *
 * @li Rational numbers are represented in an AST node using separate
 * numerator and denominator values.  These can be retrieved using the
 * methods ASTNode::getNumerator() and ASTNode::getDenominator().
 *
 * @li The children of an ASTNode are other ASTNode objects.  The list of
 * children is empty for nodes that are leaf elements, such as numbers.
 * For nodes that are actually roots of expression subtrees, the list of
 * children points to the parsed objects that make up the rest of the
 * expression.
 *
 * For many applications, the details of ASTs are irrelevant because libSBML
 * provides text-string based translation functions such as
 * @sbmlfunction{formulaToL3String, ASTNode} and
 * @sbmlfunction{parseL3Formula, String}.  If you find the complexity
 * of using the AST representation of expressions too high for your purposes,
 * perhaps the string-based functions will be more suitable.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_astnode_types
 *
 * @par
 * Every ASTNode has an associated type code to indicate whether, for
 * example, it holds a number or stands for an arithmetic operator.
 * @if clike The type is recorded as a value drawn from the enumeration
 * #ASTNodeType_t.@endif@~
 * @if java The type is recorded as a value drawn from a
 * set of static integer constants defined in the class @link
 * libsbmlConstants@endlink. Their names begin with the characters @c AST_.@endif
 * @if python The type is recorded as a value drawn from a
 * set of static integer constants defined in the class @link
 * libsbml@endlink. Their names begin with the characters @c AST_.@endif
 * @if csharp The type is recorded as a value drawn from a
 * set of static integer constants defined in the class @link
 * libsbml@endlink. Their names begin with the characters @c AST_.@endif
 * The list of possible types is quite long, because it covers all the
 * mathematical functions that are permitted in SBML. The values are shown
 * in the following table:
 *
 * @htmlinclude astnode-types.html
 *
 * The types have the following meanings:
 *
 * @li If the node is basic mathematical operator (e.g., @c "+"), then the
 * node's type will be @sbmlconstant{AST_PLUS,ASTNodeType_t},
 * @sbmlconstant{AST_MINUS, ASTNodeType_t},
 * @sbmlconstant{AST_TIMES, ASTNodeType_t},
 * @sbmlconstant{AST_DIVIDE, ASTNodeType_t}, or
 * @sbmlconstant{AST_POWER, ASTNodeType_t}, as appropriate.
 *
 * @li If the node is a predefined function or operator from %SBML
 * Level&nbsp;1 (in the string-based formula syntax used in Level&nbsp;1) or
 * %SBML Level&nbsp;2 and&nbsp;3 (in the subset of MathML used in SBML
 * Levels&nbsp;2 and&nbsp;3), then the node's type
 * will be either <code style="margin-right: 0">AST_FUNCTION_</code><span
 * class="placeholder-nospace">X</span>, <code style="margin-right: 0">AST_LOGICAL_</code><span
 * class="placeholder-nospace">X</span>, or <code style="margin-right: 0">AST_RELATIONAL_</code><span
 * class="placeholder-nospace">X</span>, as appropriate.  (Examples:
 * @sbmlconstant{AST_FUNCTION_LOG, ASTNodeType_t},
 * @sbmlconstant{AST_RELATIONAL_LEQ, ASTNodeType_t}.)
 *
 * @li If the node refers to a user-defined function, the node's type will
 * be @sbmlconstant{AST_FUNCTION, ASTNodeType_t} (because it holds the
 * name of the function).
 *
 * @li If the node is a lambda expression, its type will be
 * @sbmlconstant{AST_LAMBDA, ASTNodeType_t}.
 *
 * @li If the node is a predefined constant (@c "ExponentialE", @c "Pi", @c
 * "True" or @c "False"), then the node's type will be
 * @sbmlconstant{AST_CONSTANT_E, ASTNodeType_t},
 * @sbmlconstant{AST_CONSTANT_PI, ASTNodeType_t},
 * @sbmlconstant{AST_CONSTANT_TRUE, ASTNodeType_t}, or
 * @sbmlconstant{AST_CONSTANT_FALSE, ASTNodeType_t}.
 *
 * @li (Levels&nbsp;2 and&nbsp;3 only) If the node is the special MathML
 * csymbol @c time, the value of the node will be
 * @sbmlconstant{AST_NAME_TIME, ASTNodeType_t}.  (Note, however, that the
 * MathML csymbol @c delay is translated into a node of type
 * @sbmlconstant{AST_FUNCTION_DELAY, ASTNodeType_t}.  The difference is due to
 * the fact that @c time is a single variable, whereas @c delay is actually a
 * function taking arguments.)
 *
 * @li (Level&nbsp;3 only) If the node is the special MathML csymbol @c
 * avogadro, the value of the node will be
 * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t}.
 *
 * @li If the node contains a numerical value, its type will be
 * @sbmlconstant{AST_INTEGER, ASTNodeType_t},
 * @sbmlconstant{AST_REAL, ASTNodeType_t},
 * @sbmlconstant{AST_REAL_E, ASTNodeType_t}, or
 * @sbmlconstant{AST_RATIONAL, ASTNodeType_t}, as appropriate.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_summary_of_astnode_methods
 * 
 * @par
 * There are a number of methods for interrogating the type of an ASTNode and
 * for testing whether a node belongs to a general category of constructs.
 * The methods on ASTNode for this purpose are the following:
 * 
 * @if cpp
 * @li <code>ASTNodeType_t @link ASTNode::getType() getType()@endlink</code>
 * returns the type of this AST node.
 * @li <code>bool @link ASTNode::isConstant() isConstant()@endlink</code>
 * returns @c true if this AST node is a MathML constant (@c true, @c false,
 * @c pi, @c exponentiale), @c false otherwise.
 * @li <code>bool @link ASTNode::isBoolean() isBoolean()@endlink</code>
 * returns @c true if this AST node returns a boolean value (by being either a
 * logical operator, a relational operator, or the constant @c true or @c
 * false).
 * @li <code>bool @link ASTNode::isFunction() isFunction()@endlink</code>
 * returns @c true if this AST node is a function (i.e., a MathML defined
 * function such as @c exp or else a function defined by a FunctionDefinition
 * in the Model).
 * @li <code>bool @link ASTNode::isInfinity() isInfinity()@endlink</code>
 * returns @c true if this AST node is the special IEEE 754 value infinity.
 * @li <code>bool @link ASTNode::isInteger() isInteger()@endlink</code>
 * returns @c true if this AST node is holding an integer value.
 * @li <code>bool @link ASTNode::isNumber() isNumber()@endlink</code> returns
 * @c true if this AST node is holding any number.
 * @li <code>bool @link ASTNode::isLambda() isLambda()@endlink</code> returns
 * @c true if this AST node is a MathML @c lambda construct.
 * @li <code>bool @link ASTNode::isLog10() isLog10()@endlink</code> returns
 * @c true if this AST node represents the @c log10 function, specifically,
 * that its type is @c AST_FUNCTION_LOG and it has two children, the first of
 * which is an integer equal to 10.
 * @li <code>bool @link ASTNode::isLogical() isLogical()@endlink</code>
 * returns @c true if this AST node is a logical operator (@c and, @c or, @c
 * not, @c xor).
 * @li <code>bool @link ASTNode::isName() isName()@endlink</code> returns @c
 * true if this AST node is a user-defined name or (in SBML Levels&nbsp;2
 * and&nbsp;3) one of the two special @c csymbol constructs "delay" or "time".
 * @li <code>bool @link ASTNode::isNaN() isNaN()@endlink</code> returns @c
 * true if this AST node has the special IEEE 754 value "not a number" (NaN).
 * @li <code>bool @link ASTNode::isNegInfinity() isNegInfinity()
 * @endlink</code> returns @c true if this AST node has the special IEEE 754
 * value of negative infinity.
 * @li <code>bool @link ASTNode::isOperator() isOperator()@endlink</code>
 * returns @c true if this AST node is an operator (e.g., @c +, @c -, etc.)
 * @li <code>bool @link ASTNode::isPiecewise() isPiecewise()@endlink</code>
 * returns @c true if this AST node is the MathML @c piecewise function.
 * @li <code>bool @link ASTNode::isRational() isRational()@endlink</code>
 * returns @c true if this AST node is a rational number having a numerator
 * and a denominator.
 * @li <code>bool @link ASTNode::isReal() isReal()@endlink</code> returns @c
 * true if this AST node is a real number (specifically, @c AST_REAL_E or
 * @c AST_RATIONAL).
 * @li <code>bool @link ASTNode::isRelational() isRelational()@endlink</code>
 * returns @c true if this AST node is a relational operator.
 * @li <code>bool @link ASTNode::isSqrt() isSqrt()@endlink</code> returns @c
 * true if this AST node is the square-root operator
 * @li <code>bool @link ASTNode::isUMinus() isUMinus()@endlink</code> returns
 * @c true if this AST node is a unary minus.
 * @li <code>bool @link ASTNode::isUnknown() isUnknown()@endlink</code>
 * returns @c true if this AST node's type is unknown.
 * @endif
 * @if python
 * @li <code>long</code> @link libsbml.ASTNode.getType() ASTNode.getType()@endlink returns the type of
 * this AST node.
 * @li <code>bool</code> @link libsbml.ASTNode.isConstant() ASTNode.isConstant()@endlink returns @c True if this
 * AST node is a MathML constant (@c True, @c False, @c pi, @c exponentiale),
 * @c False otherwise.
 * @li <code>bool</code> @link libsbml.ASTNode.isBoolean() ASTNode.isBoolean()@endlink returns @c True if this
 * AST node returns a boolean value (by being either a logical operator, a
 * relational operator, or the constant @c True or @c False).
 * @li <code>bool</code> @link libsbml.ASTNode.isFunction() ASTNode.isFunction()@endlink returns @c True if this
 * AST node is a function (i.e., a MathML defined function such as @c exp or
 * else a function defined by a FunctionDefinition in the Model).
 * @li <code>bool</code> @link libsbml.ASTNode.isInfinity() ASTNode.isInfinity()@endlink returns @c True if this
 * AST node is the special IEEE 754 value infinity.
 * @li <code>bool</code> @link libsbml.ASTNode.isInteger() ASTNode.isInteger()@endlink returns @c True if this
 * AST node is holding an integer value.
 * @li <code>bool</code> @link libsbml.ASTNode.isNumber() ASTNode.isNumber()@endlink  returns @c True if this
 * AST node is holding any number.
 * @li <code>bool</code> @link libsbml.ASTNode.isLambda() ASTNode.isLambda()@endlink  returns @c True if this
 * AST node is a MathML @c lambda construct.
 * @li <code>bool</code> @link libsbml.ASTNode.isLog10() ASTNode.isLog10()@endlink  returns @c True if this
 * AST node represents the @c log10 function, specifically, that its type is
 * @c AST_FUNCTION_LOG and it has two children, the first of which is an integer
 * equal to 10.
 * @li <code>bool</code> @link libsbml.ASTNode.isLogical() ASTNode.isLogical()@endlink  returns @c True if this
 * AST node is a logical operator (@c and, @c or, @c not, @c xor).
 * @li <code>bool</code> @link libsbml.ASTNode.isName() ASTNode.isName()@endlink  returns @c True if this
 * AST node is a user-defined name or (in SBML Level 2) one of the two special
 * @c csymbol constructs "delay" or "time".
 * @li <code>bool</code> @link libsbml.ASTNode.isNaN() ASTNode.isNaN()@endlink  returns @c True if this
 * AST node has the special IEEE 754 value "not a number" (NaN).
 * @li <code>bool</code> @link libsbml.ASTNode.isNegInfinity() ASTNode.isNegInfinity()@endlink  returns @c True if this
 * AST node has the special IEEE 754 value of negative infinity.
 * @li <code>bool</code> @link libsbml.ASTNode.isOperator() ASTNode.isOperator()@endlink  returns @c True if this
 * AST node is an operator (e.g., <code>+</code>, <code>-</code>, etc.)
 * @li <code>bool</code> @link libsbml.ASTNode.isPiecewise() ASTNode.isPiecewise()@endlink  returns @c True if this
 * AST node is the MathML @c piecewise function.
 * @li <code>bool</code> @link libsbml.ASTNode.isRational() ASTNode.isRational()@endlink  returns @c True if this
 * AST node is a rational number having a numerator and a denominator.
 * @li <code>bool</code> @link libsbml.ASTNode.isReal() ASTNode.isReal()@endlink  returns @c True if this
 * AST node is a real number (specifically, @c AST_REAL_E or @c AST_RATIONAL).
 * @li <code>bool</code> @link libsbml.ASTNode.isRelational() ASTNode.isRelational()@endlink  returns @c True if this
 * AST node is a relational operator.
 * @li <code>bool</code> @link libsbml.ASTNode.isSqrt() ASTNode.isSqrt()@endlink  returns @c True if this
 * AST node is the square-root operator
 * @li <code>bool</code> @link libsbml.ASTNode.isUMinus() ASTNode.isUMinus()@endlink  returns @c True if this
 * AST node is a unary minus.
 * @li <code>bool</code> @link libsbml.ASTNode.isUnknown() ASTNode.isUnknown()@endlink  returns @c True if this
 * AST node's type is unknown.
 * @endif
 * @if conly
 * @li <code>ASTNodeType_t ASTNode_getType()</code>
 * returns the type of this AST node.
 * @li <code>bool ASTNode_isConstant()</code>
 * returns @c 1 if this AST node is a MathML constant (@c true, @c false,
 * @c pi, @c exponentiale), @c 0 otherwise.
 * @li <code>bool ASTNode_isBoolean()</code>
 * returns @c 1 if this AST node returns a boolean value (by being either a
 * logical operator, a relational operator, or the constant @c true or @c
 * false).
 * @li <code>bool ASTNode_isFunction()</code>
 * returns @c 1 if this AST node is a function (i.e., a MathML defined
 * function such as @c exp or else a function defined by a FunctionDefinition
 * in the Model).
 * @li <code>bool ASTNode_isInfinity()</code>
 * returns @c 1 if this AST node is the special IEEE 754 value infinity.
 * @li <code>bool ASTNode_isInteger()</code>
 * returns @c 1 if this AST node is holding an integer value.
 * @li <code>bool ASTNode_isNumber()</code> returns
 * @c 1 if this AST node is holding any number.
 * @li <code>bool ASTNode_isLambda()</code> returns
 * @c 1 if this AST node is a MathML @c lambda construct.
 * @li <code>bool ASTNode_isLog10()</code> returns
 * @c 1 if this AST node represents the @c log10 function, specifically,
 * that its type is @c AST_FUNCTION_LOG and it has two children, the first of
 * which is an integer equal to 10.
 * @li <code>bool ASTNode_isLogical()</code>
 * returns @c 1 if this AST node is a logical operator (@c and, @c or, @c
 * not, @c xor).
 * @li <code>bool ASTNode_isName()</code> returns @c
 * true if this AST node is a user-defined name or (in SBML Levels&nbsp;2
 * and&nbsp;3) one of the two special @c csymbol constructs "delay" or "time".
 * @li <code>bool ASTNode_isNaN()</code> returns @c
 * true if this AST node has the special IEEE 754 value "not a number" (NaN).
 * @li <code>bool ASTNode_isNegInfinity()</code> returns @c 1 if this AST node has the special IEEE 754
 * value of negative infinity.
 * @li <code>bool ASTNode_isOperator()</code>
 * returns @c 1 if this AST node is an operator (e.g., @c +, @c -, etc.)
 * @li <code>bool ASTNode_isPiecewise()</code>
 * returns @c 1 if this AST node is the MathML @c piecewise function.
 * @li <code>bool ASTNode_isRational()</code>
 * returns @c 1 if this AST node is a rational number having a numerator
 * and a denominator.
 * @li <code>bool ASTNode_isReal()</code> returns @c
 * true if this AST node is a real number (specifically, @c AST_REAL_E or
 * @c AST_RATIONAL).
 * @li <code>bool ASTNode_isRelational()</code>
 * returns @c 1 if this AST node is a relational operator.
 * @li <code>bool ASTNode_isSqrt()</code> returns @c
 * true if this AST node is the square-root operator
 * @li <code>bool ASTNode_isUMinus()</code> returns
 * @c 1 if this AST node is a unary minus.
 * @li <code>bool ASTNode_isUnknown()</code>
 * returns @c 1 if this AST node's type is unknown.
 * @endif
 * 
 * Programs manipulating AST node structures should check the type of a given
 * node before calling methods that return a value from the node.  The
 * following are the ASTNode object methods available for returning values
 * from nodes:
 * 
 * @if cpp
 * @li <code>long @link ASTNode::getInteger() getInteger()@endlink</code> 
 * @li <code>char @link ASTNode::getCharacter() getCharacter()@endlink</code> 
 * @li <code>const char* @link ASTNode::getName() getName()@endlink</code> 
 * @li <code>long @link ASTNode::getNumerator() getNumerator()@endlink</code> 
 * @li <code>long @link ASTNode::getDenominator() getDenominator()@endlink</code>
 * @li <code>double @link ASTNode::getReal() getReal()@endlink</code> 
 * @li <code>double @link ASTNode::getMantissa() getMantissa()@endlink</code> 
 * @li <code>long @link ASTNode::getExponent() getExponent()@endlink</code> 
 * @endif
 * @if python
 * @li <code>long</code> @link libsbml.ASTNode.getInteger() ASTNode.getInteger()@endlink 
 * @li <code>char</code> @link libsbml.ASTNode.getCharacter() ASTNode.getCharacter()@endlink 
 * @li <code>string</code> @link libsbml.ASTNode.getName() ASTNode.getName()@endlink 
 * @li <code>long</code> @link libsbml.ASTNode.getNumerator() ASTNode.getNumerator()@endlink 
 * @li <code>long</code> @link libsbml.ASTNode.getDenominator() ASTNode.getDenominator()@endlink 
 * @li <code>float</code> @link libsbml.ASTNode.getReal() ASTNode.getReal()@endlink 
 * @li <code>float</code> @link libsbml.ASTNode.getMantissa() ASTNode.getMantissa()@endlink 
 * @li <code>long</code> @link libsbml.ASTNode.getExponent() ASTNode.getExponent()@endlink 
 * @endif
 * @if conly
 * @li <code>long ASTNode_getInteger()</code> 
 * @li <code>char ASTNode_getCharacter()</code> 
 * @li <code>const char* ASTNode_getName()</code> 
 * @li <code>long ASTNode_getNumerator()</code> 
 * @li <code>long ASTNode_getDenominator()</code>
 * @li <code>double ASTNode_getReal()</code> 
 * @li <code>double ASTNode_getMantissa()</code> 
 * @li <code>long ASTNode_getExponent()</code> 
 * @endif
 * 
 * Of course, all of this would be of little use if libSBML didn't also
 * provide methods for @em setting the values of AST node objects!  And it
 * does.  The methods are the following:
 * 
 * @if cpp
 * @li <code>void @link ASTNode::setCharacter(char value) setCharacter(char
 * value)@endlink</code> sets the value of this ASTNode to the given
 * character <code>value</code>.  If character is one of @c +, @c -, @c *, @c
 * / or @c ^, the node type will be to the appropriate operator type.  For all
 * other characters, the node type will be set to @c AST_UNKNOWN.
 * @li <code>void @link ASTNode::setName(const char *name) setName(const char
 * *name)@endlink</code> sets the value of this AST node to the given
 * <code>name</code>.  The node type will be set (to @c AST_NAME) <em>only
 * if</em> the AST node was previously an operator (<code>isOperator(node) !=
 * 0</code>) or number (<code>isNumber(node) != 0</code>).  This allows names
 * to be set for @c AST_FUNCTIONs and the like.
 * @li <code>void @link ASTNode::setValue(int value) setValue(int value)
 * @endlink</code> sets the value of the node to the given integer
 * <code>value</code>.  Equivalent to the next method.
 * @li <code>void @link ASTNode::setValue(long value) setValue(long value)
 * @endlink</code> sets the value of the node to the given integer
 * <code>value</code>.  Equivalent to the previous method.  No, this is not a
 * G&ouml;delian self-referential loop.
 * @li <code>void @link ASTNode::setValue(long numerator, long denominator)
 * setValue(long numerator, long denominator)@endlink</code> sets the value
 * of this ASTNode to the given rational <code>value</code> in two parts: the
 * numerator and denominator.  The node type is set to @c AST_RATIONAL.
 * @li <code>void @link ASTNode::setValue(double value) setValue(double value)
 * @endlink</code> sets the value of this ASTNode to the given real (double)
 * <code>value</code> and sets the node type to @c AST_REAL.
 * @li <code>void @link ASTNode::setValue(double mantissa, long exponent)
 * setValue(double mantissa, long exponent)@endlink</code> sets the value of
 * this ASTNode to a real (double) using the two parts given: the mantissa and
 * the exponent.  The node type is set to @c AST_REAL_E.
 * @endif
 * @if python
 * @li @link libsbml.ASTNode.setCharacter() ASTNode.setCharacter(char)@endlink sets the value of
 * this ASTNode to the given character.  If character is one of @c +, @c -, @c
 * *, @c / or @c ^, the node type will be to the appropriate operator type.
 * For all other characters, the node type will be set to @c AST_UNKNOWN.
 * @li @link libsbml.ASTNode.setName() ASTNode.setName(string)@endlink sets the value of
 * this AST node to the given name.  The node type will be set (to @c AST_NAME)
 * <em>only if</em> the AST node was previously an operator
 * (<code>isOperator(node) != 0</code>) or number (<code>isNumber(node) !=
 * 0</code>).  This allows names to be set for @c AST_FUNCTIONs and the like.
 * @li @link libsbml.ASTNode.setValue() ASTNode.setValue(int)@endlink sets the value of the
 * node to the given integer.  Equivalent to the next method.
 * @li @link libsbml.ASTNode.setValue() ASTNode.setValue(long)@endlink sets the value of the
 * node to the given integer.
 * @li @link libsbml.ASTNode.setValue() ASTNode.setValue(long, long)@endlink
 * sets the value of this ASTNode to the given rational in two parts: the
 * numerator and denominator.  The node type is set to @c AST_RATIONAL.
 * @li @link libsbml.ASTNode.setValue() ASTNode.setValue(float)@endlink sets the value of
 * this ASTNode to the given real (float) and sets the node type to @c AST_REAL.
 * @li @link libsbml.ASTNode.setValue() ASTNode.setValue(float, long)@endlink
 * sets the value of this ASTNode to the given real (float) in two parts: the
 * mantissa and the exponent.  The node type is set to @c AST_REAL_E.
 * @endif
 * @if conly
 * @li <code>void ASTNode_setCharacter(ASTNode_t *node, char value)</code> sets the value of this
 * ASTNode to the given character <code>value</code>.  If character is one of @c
 * +, @c -, @c *, @c / or @c ^, the node type will be to the appropriate
 * operator type.  For all other characters, the node type will be set to @c
 * AST_UNKNOWN.
 * @li <code>void ASTNode_setName(ASTNode_t *node, const char *name)</code> sets the value of
 * this AST node to the given <code>name</code>.  The node type will be set (to
 * @c AST_NAME) <em>only if</em> the AST node was previously an operator
 * (<code>isOperator(node) != 0</code>) or number (<code>isNumber(node) !=
 * 0</code>).  This allows names to be set for @c AST_FUNCTIONs and the like.
 * @li <code>void ASTNode_setInteger(ASTNode_t *node, long value)</code> sets the value of the node
 * to the given integer <code>value</code>.  
 * @li <code>void ASTNode_setRational(ASTNode_t *node, long numerator, long denominator)</code> sets
 * the value of this ASTNode to the given rational <code>value</code> in two
 * parts: the numerator and denominator.  The node type is set to @c
 * AST_RATIONAL.
 * @li <code>void ASTNode_setReal(ASTNode_t *node, double value)</code> sets the value of this
 * ASTNode to the given real (double) <code>value</code> and sets the node type
 * to @c AST_REAL.
 * @li <code>void ASTNode_setRealWithExponent(ASTNode_t *node, double mantissa, long exponent)</code> sets
 * the value of this ASTNode to a real (double) using the two parts given: the
 * mantissa and the exponent.  The node type is set to @c AST_REAL_E.
 * @endif
 * 
 * Finally, ASTNode also defines some miscellaneous methods for manipulating
 * ASTs:
 * 
 * @if cpp
 * @li <code>ASTNode* @link ASTNode::ASTNode(ASTNodeType_t type)
 * ASTNode(ASTNodeType_t type)@endlink</code> creates a new ASTNode object
 * and returns a pointer to it.  The returned node will have the given
 * <code>type</code>, or a type of @c AST_UNKNOWN if no argument
 * <code>type</code> is explicitly given or the type code is unrecognized.
 * @li <code>unsigned int @link ASTNode::getNumChildren() getNumChildren()
 * @endlink</code> returns the number of children of this AST node or
 * <code>0</code> is this node has no children.
 * @li <code>void @link ASTNode::addChild(ASTNode* child) addChild(ASTNode*
 * child)@endlink</code> adds the given node as a child of this AST node.
 * Child nodes are added in left-to-right order.
 * @li <code>void @link ASTNode::prependChild(ASTNode* child)
 * prependChild(ASTNode* child)@endlink</code> adds the given node as a child
 * of this AST node.  This method adds child nodes in right-to-left order.
 * @li <code>ASTNode* @link ASTNode::getChild() getChild(unsigned int n)
 * @endlink</code> returns the <code>n</code>th child of this
 * AST node or @c NULL if this node has no <code>n</code>th child [i.e., if
 * <code>n &gt; (node->getNumChildren() - 1)</code>, where <code>node</code>
 * is a pointer to a node].
 * @li <code>ASTNode* @link ASTNode::getLeftChild() getLeftChild()
 * @endlink</code> returns the left child of this AST node.  This is
 * equivalent to <code>getChild(0)</code>.
 * @li <code>ASTNode* @link ASTNode::getRightChild() getRightChild()
 * @endlink</code> returns the right child of this AST node or @c NULL if this
 * node has no right child.
 * @li <code>void @link ASTNode::swapChildren(ASTNode *that)
 * swapChildren(ASTNode *that)@endlink</code> swaps the children of this
 * ASTNode with the children of @c that ASTNode.
 * @li <code>void @link ASTNode::setType(ASTNodeType_t type)
 * setType(ASTNodeType_t type)@endlink</code> sets the type of this ASTNode
 * to the given #ASTNodeType_t enumeration value.
 * @endif
 * @if python
 * @li <code>ASTNode</code> @link libsbml.ASTNode(long) ASTNode(long)@endlink creates a new ASTNode object
 * and returns a pointer to it.  The returned node will have the type
 * identified by the code passed as the argument, or a type of @c AST_UNKNOWN if
 * no type is explicitly given or the type code is unrecognized.
 * @li <code>unsigned int</code> @link libsbml.ASTNode.getNumChildren() ASTNode.getNumChildren()@endlink returns the number
 * of children of this AST node or 0 is this node has no children.
 * @li @link libsbml.ASTNode.addChild() ASTNode.addChild(ASTNode)@endlink adds the given node
 * as a child of this AST node.  Child nodes are added in left-to-right order.
 * @li @link libsbml.ASTNode.prependChild() ASTNode.prependChild(ASTNode)@endlink adds the given
 * node as a child of this AST node.  This method adds child nodes in
 * right-to-left order.
 * @li <code>ASTNode</code> @link libsbml.ASTNode.getChild() ASTNode.getChild(unsigned int)@endlink returns the nth
 * child of this AST node or @c NULL if this node has no nth child (<code>n &gt;
 * (@link libsbml.ASTNode.getNumChildren() ASTNode.getNumChildren()@endlink - 1)</code>).
 * @li <code>ASTNode</code> @link libsbml.ASTNode.getLeftChild() ASTNode.getLeftChild()@endlink returns the left child of
 * this AST node.  This is equivalent to @link libsbml.ASTNode.getChild() ASTNode.getChild()@endlink;
 * @li <code>ASTNode</code> @link libsbml.ASTNode.getRightChild() ASTNode.getRightChild()@endlink
 * returns the right child of this AST node or @c NULL if this node has no right
 * child.
 * @li @link libsbml.ASTNode.swapChildren() ASTNode.swapChildren(ASTNode)@endlink swaps the
 * children of this ASTNode with the children of @c that ASTNode.
 * @li @link libsbml.ASTNode.setType() ASTNode.setType(long)@endlink
 * sets the type of this ASTNode to the type identified by the
 * type code passed as argument, or to @c AST_UNKNOWN if the type
 * is unrecognized.
 * @endif
 * @if conly
 * @li <code>ASTNode_t* ASTNode_createWithType(ASTNodeType_t type)</code> creates a new
 * ASTNode object and returns a pointer to it.  The returned node will have the
 * given <code>type</code>, or a type of @c AST_UNKNOWN if no argument
 * <code>type</code> is explicitly given or the type code is unrecognized.
 * @li <code>unsigned int ASTNode_getNumChildren(const ASTNode_t *node)</code> returns the number of
 * children of this AST node or <code>0</code> is this node has no children.
 * @li <code>void ASTNode_addChild(ASTNode_t *node, ASTNode_t* child)</code> adds the given node as
 * a child of this AST node.  Child nodes are added in left-to-right order.
 * @li <code>void ASTNode_prependChild(ASTNode_t *node, ASTNode_t* child)</code> adds the given
 * node as a child of this AST node.  This method adds child nodes in
 * right-to-left order.
 * @li <code>ASTNode_t* ASTNode_getChild (const ASTNode_t *node, unsigned int n)</code> returns the
 * <code>n</code>th child of this AST node or @c NULL if this node has no
 * <code>n</code>th child [i.e., if <code>n &gt; (node->getNumChildren() -
 * 1)</code>, where <code>node</code> is a pointer to a node].
 * @li <code>ASTNode_t* ASTNode_getLeftChild(const ASTNode_t *node)</code> returns the left child of
 * this AST node.  This is equivalent to <code>getChild(0)</code>.
 * @li <code>ASTNode_t* ASTNode_getRightChild(const ASTNode_t *node)</code> returns the right child of
 * this AST node or @c NULL if this node has no right child.
 * @li <code>void ASTNode_swapChildren(ASTNode_t *node, ASTNode *that)</code> swaps the children
 * of this ASTNode with the children of @c that ASTNode.
 * @li <code>void ASTNode_setType(ASTNode_t *node, ASTNodeType_t type)</code> sets the type of
 * this ASTNode to the given #ASTNodeType_t enumeration value.
 * @endif
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_summary_of_writing_mathml_directly
 * 
 * @par
 * As mentioned above, applications often can avoid working with raw MathML by
 * using either libSBML's text-string interface or the AST API.  However, when
 * needed, reading MathML content directly and creating ASTs is easily done in
 * libSBML using a method designed for this purpose:
 * 
 * @if cpp
 * @li <code>ASTNode_t* @sbmlfunction{readMathMLFromString, String}</code> reads raw
 * MathML from a text string, constructs an AST from it, then returns the root
 * ASTNode of the resulting expression tree.
 * @endif
 * @if python
 * @li <code>ASTNode</code> @link libsbml.readMathMLFromString() readMathMLFromString(string)@endlink reads raw
 * MathML from a text string, constructs an AST from it, then returns the root
 * ASTNode of the resulting expression tree.
 * @endif
 * @if conly
 * @li <code>ASTNode_t* @sbmlfunction{readMathMLFromString, String}</code> reads raw
 * MathML from a text string, constructs an AST from it, then returns the root
 * ASTNode_t of the resulting expression tree.
 * @endif
 * 
 * Similarly, writing out Abstract Syntax Tree structures is easily done using
 * the following method:
 * 
 * @if cpp
 * @li <code>char* @sbmlfunction{writeMathMLToString, ASTNode}</code> writes an
 * AST to a string.  The caller owns the character string returned and should free
 * it after it is no longer needed.
 * @endif
 * @if python
 * @li <code>string</code> @link libsbml.writeMathMLToString() writeMathMLToString(ASTNode)@endlink writes an AST to a
 * string.  The caller owns the character string returned and should free it
 * after it is no longer needed.
 * @endif
 * @if conly
 * @li <code>char* @sbmlfunction{writeMathMLToString, ASTNode}</code> writes an
 * AST to a string.  The caller owns the character string returned and should free
 * it after it is no longer needed.
 * @endif
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_summary_of_string_math
 *
 * @par
 * The text-string form of mathematical formulas produced by
 * @sbmlfunction{formulaToString, ASTNode} and read by
 * @sbmlfunction{parseFormula, String} use a simple C-inspired infix
 * notation taken from SBML Level&nbsp;1.  A formula in this text-string form
 * therefore can be handed to a program that understands SBML Level&nbsp;1
 * mathematical expressions, or used as part of a formula translation system.
 * The syntax is described in detail in the documentation for ASTNode.  The
 * following are illustrative examples of formulas expressed using this syntax:
 * @verbatim
0.10 * k4^2
@endverbatim
@verbatim
(vm * s1)/(km + s1)
@endverbatim
 *
 * Note that this facility is provided as a convenience by libSBML---the
 * MathML standard does not actually define a "string-form" equivalent to
 * MathML expression trees, so the choice of formula syntax is somewhat
 * arbitrary.  The approach taken by libSBML is to use the syntax defined by
 * SBML Level&nbsp;1 (which in fact used a text-string representation of
 * formulas and not MathML).  This formula syntax is based mostly on C
 * programming syntax, and may contain operators, function calls, symbols,
 * and white space characters.  The following table provides the precedence
 * rules for the different entities that may appear in formula strings.
 *
 * @htmlinclude math-precedence-table.html
 *
 * In the table above, @em operand implies the construct is an operand, @em
 * prefix implies the operation is applied to the following arguments, @em
 * unary implies there is one argument, and @em binary implies there are
 * two arguments.  The values in the <b>Precedence</b> column show how the
 * order of different types of operation are determined.  For example, the
 * expression <code>a * b + c</code> is evaluated as <code>(a * b) +
 * c</code> because the @c * operator has higher precedence.  The
 * <b>Associates</b> column shows how the order of similar precedence
 * operations is determined; for example, <code>a - b + c</code> is
 * evaluated as <code>(a - b) + c</code> because the @c + and @c -
 * operators are left-associative.
 *
 * The function call syntax consists of a function name, followed by optional
 * white space, followed by an opening parenthesis token, followed by a
 * sequence of zero or more arguments separated by commas (with each comma
 * optionally preceded and/or followed by zero or more white space
 * characters, followed by a closing parenthesis token.  The function name
 * must be chosen from one of the pre-defined functions in SBML or a
 * user-defined function in the model.  The following table lists the names
 * of certain common mathematical functions; this table corresponds to
 * Table&nbsp;6 in the <a target="_blank" href="http://sbml.org/Documents/Specifications#SBML_Level_1_Version_2">SBML Level&nbsp;1 Version&nbsp;2 specification</a>:
 *
 * @htmlinclude string-functions-table.html
 *
 * @warning <span class="warning">There are differences between the symbols
 * used to represent the common mathematical functions and the corresponding
 * MathML token names.  This is a potential source of incompatibilities.
 * Note in particular that in this text-string syntax, <code>log(x)</code>
 * represents the natural logarithm, whereas in MathML, the natural logarithm
 * is <code>&lt;ln/&gt;</code>.  Application writers are urged to be careful
 * when translating between text forms and MathML forms, especially if they
 * provide a direct text-string input facility to users of their software
 * systems.</span>
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_summary_of_string_math_l3
 *
 * @par
 * The text-string form of mathematical formulas read by the function
 * @sbmlfunction{parseL3Formula, String} and written by the function
 * @sbmlfunction{formulaToL3String, ASTNode} uses an expanded version of
 * the syntax read and written by @sbmlfunction{parseFormula, String}
 * and @sbmlfunction{formulaToString, ASTNode}, respectively.  The
 * latter two libSBML functions were originally developed to support
 * conversion between SBML Levels&nbsp;1 and&nbsp;2, and were focused on the
 * syntax of mathematical formulas used in SBML Level&nbsp;1.  With time, and
 * the use of MathML in SBML Levels&nbsp;2 and&nbsp;3, it became clear that
 * supporting Level&nbsp;2 and&nbsp;3's expanded mathematical syntax would be
 * useful for software developers.  To maintain backwards compatibility for
 * libSBML users, the original @sbmlfunction{formulaToString, ASTNode}
 * and @sbmlfunction{parseFormula, String} have been left untouched,
 * and instead, the new functionality is provided in the form of
 * @sbmlfunction{parseL3Formula, String} and
 * @sbmlfunction{formulaToL3String, ASTNode}.
 *
 * The following lists the main differences in the formula syntax supported by
 * the "Level 3" or L3 versions of the formula parsers and formatters,
 * compared to what is supported by the Level&nbsp;1-oriented
 * @sbmlfunction{parseFormula, String} and
 * @sbmlfunction{formulaToString, ASTNode}:
 *
 * @li Units may be asociated with bare numbers, using the following syntax:
 * <div style="margin: 10px auto 10px 25px; display: block">
 * <span class="code" style="background-color: #d0d0ee">number</span>
 * <span class="code" style="background-color: #edd">unit</span>
 * </div>
 * The <span class="code" style="background-color: #d0d0ee">number</span>
 * may be in any form (an integer, real, or rational
 * number), and the
 * <span class="code" style="background-color: #edd">unit</span>
 * must conform to the syntax of an SBML identifier (technically, the
 * type defined as @c SId in the SBML specifications).  The whitespace between
 * <span class="code" style="background-color: #d0d0ee">number</span>
 * and <span class="code" style="background-color: #edd">unit</span>
 * is optional.
 *
 * @li The Boolean function symbols @c &&, @c ||, @c !, and @c != may be
 * used.
 *
 * @li The @em modulo operation is allowed as the symbol @c @% and will
 * produce a <code>&lt;piecewise&gt;</code> function in the corresponding
 * MathML output.
 *
 * @li All inverse trigonometric functions may be defined in the infix either
 * using @c arc as a prefix or simply @c a; in other words, both @c arccsc
 * and @c acsc are interpreted as the operator @em arccosecant as defined in
 * MathML&nbsp;2.0.  (Many functions in the simpler SBML Level&nbsp;1
 * oriented parser implemented by @sbmlfunction{parseFormula, String}
 * are defined this way as well, but not all.)
 *
 * @li The following expression is parsed as a rational number instead of
 * as a numerical division:
 * <pre style="display: block; margin-left: 25px">
 * (<span class="code" style="background-color: #d0d0ee">integer</span>/<span class="code" style="background-color: #d0d0ee">integer</span>)</pre>
 * <strong>Spaces are not allowed</strong> in this construct; in other words,
 * &quot;<code>(3 / 4)</code>&quot; (with whitespace between the numbers and
 * the operator) will be parsed into the MathML <code>&lt;divide&gt;</code>
 * construct rather than a rational number.  You can, however, assign units to a
 * rational number as a whole; here is an example: &quot;<code>(3/4) ml</code>&quot;.
 * (In the case of division rather than a rational number, units are not interpreted
 * in this way.)
 *
 * @li Various parser and formatter behaviors may be altered through the use
 * of a L3ParserSettings object in conjunction with the functions
 * @sbmlfunction{parseL3FormulaWithSettings, String\, L3ParserSettings} and
 * @sbmlfunction{formulaToL3StringWithSettings, ASTNode\, L3ParserSettings}
 * The settings available include the following:
 * <ul style="list-style-type: circle">
 *
 * <li style="margin-bottom: 0.5em"> The function @c log with a single
 * argument (&quot;<code>log(x)</code>&quot;) can be parsed as
 * <code>log10(x)</code>, <code>ln(x)</code>, or treated as an error, as
 * desired.
 *
 * <li style="margin-bottom: 0.5em"> Unary minus signs can be collapsed or
 * preserved; that is, sequential pairs of unary minuses (e.g., &quot;<code>-
 * -3</code>&quot;) can be removed from the input entirely and single unary
 * minuses can be incorporated into the number node, or all minuses can be
 * preserved in the AST node structure.
 *
 * <li style="margin-bottom: 0.5em"> Parsing of units embedded in the input
 * string can be turned on and off.
 *
 * <li style="margin-bottom: 0.5em"> The string @c avogadro can be parsed as
 * a MathML @em csymbol or as an identifier.
 *
 * <li style="margin-bottom: 0.5em"> A Model object may optionally be
 * provided to the parser using the variant function call
 * @sbmlfunction{parseL3FormulaWithModel, String\, Model} or
 * stored in a L3ParserSettings object passed to the variant function
 * @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings}.  When a Model object is provided, identifiers
 * (values of type @c SId) from that model are used in preference to
 * pre-defined MathML definitions for both symbols and functions.
 * More precisely:
 * <ul style="list-style-type: square">
 *
 * <li style="margin-bottom: 0.5em"> <em>In the case of symbols</em>: the
 * Model entities whose identifiers will shadow identical symbols in the
 * mathematical formula are: Species, Compartment, Parameter, Reaction, and
 * SpeciesReference.  For instance, if the parser is given a Model containing
 * a Species with the identifier &quot;<code>pi</code>&quot;, and the formula
 * to be parsed is &quot;<code>3*pi</code>&quot;, the MathML produced will
 * contain the construct <code>&lt;ci&gt; pi &lt;/ci&gt;</code> instead of
 * the construct <code>&lt;pi/&gt;</code>.
 *
 * <li style="margin-bottom: 0.5em"> <em>In the case of user-defined
 * functions</em>: when a Model object is provided, @c SId values of
 * user-defined functions present in the model will be used preferentially
 * over pre-defined MathML functions.  For example, if the passed-in Model
 * contains a FunctionDefinition object with the identifier
 * &quot;<code>sin</code>&quot;, that function will be used instead of the
 * predefined MathML function <code>&lt;sin/&gt;</code>.
 * </ul>
 *
 * <li style="margin-bottom: 0.5em"> An SBMLNamespaces object may optionally
 * be provided to identify SBML Level&nbsp;3 packages that extend the
 * syntax understood by the formula parser.  When the namespaces are provided,
 * the parser will interpret possible additional syntax defined by the libSBML
 * plug-ins implementing the SBML Level&nbsp;3 packages; for example, it may
 * understand vector/array extensions introduced by the SBML Level&nbsp;3 @em
 * Arrays package.
 * </ul>
 *
 * These configuration settings cannot be changed directly using the basic
 * parser and formatter functions, but @em can be changed on a per-call basis
 * by using the alternative functions @sbmlfunction{parseL3FormulaWithSettings,
 * String\, L3ParserSettings} and
 * @sbmlfunction{formulaToL3StringWithSettings, ASTNode\,
 * L3ParserSettings}.
 *
 * Neither SBML nor the MathML standard define a "string-form" equivalent to
 * MathML expressions.  The approach taken by libSBML is to start with the
 * formula syntax defined by SBML Level&nbsp;1 (which in fact used a custom
 * text-string representation of formulas, and not MathML), and expand it to
 * include the functionality described above.  This formula syntax is based
 * mostly on C programming syntax, and may contain operators, function calls,
 * symbols, and white space characters.  The following table provides the
 * precedence rules for the different entities that may appear in formula
 * strings.
 *
 * @htmlinclude math-precedence-table-l3.html
 *
 * In the table above, @em operand implies the construct is an operand, @em
 * prefix implies the operation is applied to the following arguments, @em
 * unary implies there is one argument, and @em binary implies there are
 * two arguments.  The values in the <b>Precedence</b> column show how the
 * order of different types of operation are determined.  For example, the
 * expression <code>a + b * c</code> is evaluated as <code>a + (b * c)</code>
 * because the @c * operator has higher precedence.  The
 * <b>Associates</b> column shows how the order of similar precedence
 * operations is determined; for example, <code>a && b || c</code> is
 * evaluated as <code>(a && b) || c</code> because the @c && and @c ||
 * operators are left-associative and have the same precedence.
 *
 * The function call syntax consists of a function name, followed by optional
 * white space, followed by an opening parenthesis token, followed by a
 * sequence of zero or more arguments separated by commas (with each comma
 * optionally preceded and/or followed by zero or more white space
 * characters), followed by a closing parenthesis token.  The function name
 * must be chosen from one of the pre-defined functions in SBML or a
 * user-defined function in the model.  The following table lists the names
 * of certain common mathematical functions; this table corresponds to
 * Table&nbsp;6 in the <a target="_blank"
 * href="http://sbml.org/Documents/Specifications#SBML_Level_1_Version_2">SBML
 * Level&nbsp;1 Version&nbsp;2 specification</a> with additions based on the
 * functions added in SBML Level 2 and Level 3:
 *
 * @htmlinclude string-functions-table-l3.html
 *
 * Parsing of the various MathML functions and constants are all
 * case-insensitive by default: function names such as <code>cos</code>,
 * <code>Cos</code> and <code>COS</code> are all parsed as the MathML cosine
 * operator, <code>&lt;cos&gt;</code>.  However, <em>when a Model object is
 * used</em> in conjunction with either
 * @sbmlfunction{parseL3FormulaWithModel, String\, Model} or
 * @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings}, any identifiers found in that model will be
 * parsed in a case-<em>sensitive</em> way.  For example, if a model contains
 * a Species having the identifier <code>Pi</code>, the parser will parse
 * &quot;<code>Pi</code>&quot; in the input as &quot;<code>&lt;ci&gt; Pi
 * &lt;/ci&gt;</code>&quot; but will continue to parse the symbols
 * &quot;<code>pi</code>&quot; and &quot;<code>PI</code>&quot; as
 * &quot;<code>&lt;pi&gt;</code>&quot;.
 *
 * As mentioned above, the manner in which the "L3" versions of the formula
 * parser and formatter interpret the function &quot;<code>log</code>&quot;
 * can be changed.  To do so, callers should use the function
 * @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings} and pass it an appropriate L3ParserSettings
 * object.  By default, unlike the SBML Level&nbsp;1 parser implemented by
 * @sbmlfunction{parseFormula, String}, the string
 * &quot;<code>log</code>&quot; is interpreted as the base&nbsp;10 logarithm,
 * and @em not as the natural logarithm.  However, you can change the
 * interpretation to be base-10 log, natural log, or as an error; since the
 * name "log" by itself is ambiguous, you require that the parser uses @c
 * log10 or @c ln instead, which are more clear.  Please refer to
 * @sbmlfunction{parseL3FormulaWithSettings, String\,
 * L3ParserSettings}.
 *
 * In addition, the following symbols will be translated to their MathML
 * equivalents, if no symbol with the same @c SId identifier string exists
 * in the Model object provided:
 *
 * @htmlinclude string-values-table-l3.html
 *
 * Again, as mentioned above, whether the string
 * &quot;<code>avogadro</code>&quot; is parsed as an AST node of type
 * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t} or
 * @sbmlconstant{AST_NAME, ASTNodeType_t} is configurable; use the version of
 * the parser function called @sbmlfunction{parseL3FormulaWithSettings,
 * String\, L3ParserSettings}.  This Avogadro-related
 * functionality is provided because SBML Level&nbsp;2 models may not use
 * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t} AST nodes.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_l3_parser_configuration_options
 *
 * @li A Model object may optionally be provided to use identifiers (values
 * of type @c SId) from the model in preference to pre-defined MathML symbols
 * More precisely, the Model entities whose identifiers will shadow identical
 * symbols in the mathematical formula are: Species, Compartment, Parameter,
 * Reaction, and SpeciesReference.  For instance, if the parser is given a
 * Model containing a Species with the identifier
 * &quot;<code>pi</code>&quot;, and the formula to be parsed is
 * &quot;<code>3*pi</code>&quot;, the MathML produced by the parser will
 * contain the construct <code>&lt;ci&gt; pi &lt;/ci&gt;</code> instead of
 * the construct <code>&lt;pi/&gt;</code>.  Another example, if the passed-in
 * Model contains a FunctionDefinition with the identifier
 * &quot;<code>sin</code>&quot;, that function will be used instead of the
 * predefined MathML function <code>&lt;sin/&gt;</code>.
 * @li The function @c log with a single argument
 * (&quot;<code>log(x)</code>&quot;) can be parsed as <code>log10(x)</code>,
 * <code>ln(x)</code>, or treated as an error, as desired.
 * @li Unary minus signs can be either collapsed or preserved; that is, the
 * parser can either (1) remove sequential pairs of unary minuses (e.g.,
 * &quot;<code>- -3</code>&quot;) from the input and incorporate single unary
 * minuses into the number node, or (2) preserve all minuses in the AST node
 * structure, turning them into ASTNode objects of type
 * @sbmlconstant{AST_MINUS, ASTNodeType_t}.
 * @li The character sequence &quot;<code>number id</code>&quot; can be
 * interpreted as a numerical value @c number followed by units of measurement
 * indicated by @c id, or it can be treated as a syntax error.  (In
 * Level&nbsp;3, MathML <code>&lt;cn&gt;</code> elements can have an
 * attribute named @c units placed in the SBML namespace, which can be used
 * to indicate the units to be associated with the number.  The text-string
 * infix formula parser allows units to be placed after raw numbers; they are
 * interpreted as unit identifiers for units defined by the SBML
 * specification or in the containing Model object.)
 * @li The symbol @c avogadro can be parsed either as a MathML @em csymbol or
 * as a identifier.  More specifically, &quot;<code>avogadro</code>&quot; can
 * be treated as an ASTNode of type
 * @sbmlconstant{AST_NAME_AVOGADRO, ASTNodeType_t} or of type
 * @sbmlconstant{AST_NAME, ASTNodeType_t}.
 * @li Strings that match built-in functions and constants can either be parsed
 * as a match regardless of capitalization, or may be required to be
 * all-lower-case to be considered a match.  
 * @li LibSBML plug-ins implementing support for SBML Level&nbsp;3 packages
 * may introduce extensions to the syntax understood by the parser.  The
 * precise nature of the extensions will be documented by the individual
 * package plug-ins.  An example of a possible extension is a notation for
 * vectors and arrays, introduced by the SBML Level&nbsp;3 @em Arrays
 * package.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_l3_parser_encouraged
 *
 * @note
 * Callers using SBML Level&nbsp;3 are encouraged to use the facilities
 * provided by libSBML's newer and more powerful Level&nbsp;3-oriented
 * formula parser and formatter.  The entry points to this second system are
 * @sbmlfunction{parseL3Formula, String} and
 * @sbmlfunction{formulaToL3String, ASTNode}.  The Level&nbsp;1-oriented
 * system (i.e., what is provided by @sbmlfunction{formulaToString, String}
 * and @sbmlfunction{parseFormula, ASTNode}) is provided 
 * untouched for backwards compatibility.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_config_for_reading_zipped_files
 *
 * @par
 * To read a gzip/zip file, libSBML needs to be configured and linked with the
 * <a target="_blank" href="http://www.zlib.net/">zlib</a> library at compile
 * time.  It also needs to be linked with the <a target="_blank"
 * href="">bzip2</a> library to read files in <em>bzip2</em> format.  (Both of
 * these are the default configurations for libSBML.)  Errors about unreadable
 * files will be logged if a compressed filename is given and libSBML was
 * <em>not</em> linked with the corresponding required library.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_config_for_writing_zipped_files
 *
 * @par
 * To write a gzip/zip file, libSBML needs to be configured and linked with
 * the <a target="_blank" href="http://www.zlib.net/">zlib</a> library at
 * compile time.  It also needs to be linked with the <a target="_blank"
 * href="">bzip2</a> library to write files in <em>bzip2</em> format.  (Both
 * of these are the default configurations for libSBML.)  Errors about
 * unreadable files will be logged and this method will return
 * <code>false</code> if a compressed filename is given and libSBML was
 * <em>not</em> linked with the corresponding required library.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_rules_general_summary
 *
 * @section rules-general General summary of SBML rules
 *
 * In SBML Level&nbsp;3 as well as Level&nbsp;2, rules are separated into three
 * subclasses for the benefit of model analysis software.  The three
 * subclasses are based on the following three different possible functional
 * forms (where <em>x</em> is a variable, <em>f</em> is some arbitrary
 * function returning a numerical result, <b><em>V</em></b> is a vector of
 * variables that does not include <em>x</em>, and <b><em>W</em></b> is a
 * vector of variables that may include <em>x</em>):
 *
 * <table border="0" cellpadding="0" class="centered" style="font-size: small">
 * <tr><td width="120px"><em>Algebraic:</em></td><td width="250px">left-hand side is zero</td><td><em>0 = f(<b>W</b>)</em></td></tr>
 * <tr><td><em>Assignment:</em></td><td>left-hand side is a scalar:</td><td><em>x = f(<b>V</b>)</em></td></tr>
 * <tr><td><em>Rate:</em></td><td>left-hand side is a rate-of-change:</td><td><em>dx/dt = f(<b>W</b>)</em></td></tr>
 * </table>
 *
 * In their general form given above, there is little to distinguish
 * between <em>assignment</em> and <em>algebraic</em> rules.  They are treated as
 * separate cases for the following reasons:
 *
 * @li <em>Assignment</em> rules can simply be evaluated to calculate
 * intermediate values for use in numerical methods.  They are statements
 * of equality that hold at all times.  (For assignments that are only
 * performed once, see InitialAssignment.)

 * @li SBML needs to place restrictions on assignment rules, for example
 * the restriction that assignment rules cannot contain algebraic loops.
 *
 * @li Some simulators do not contain numerical solvers capable of solving
 * unconstrained algebraic equations, and providing more direct forms such
 * as assignment rules may enable those simulators to process models they
 * could not process if the same assignments were put in the form of
 * general algebraic equations;
 *
 * @li Those simulators that <em>can</em> solve these algebraic equations make a
 * distinction between the different categories listed above; and
 *
 * @li Some specialized numerical analyses of models may only be applicable
 * to models that do not contain <em>algebraic</em> rules.
 *
 * The approach taken to covering these cases in SBML is to define an
 * abstract Rule structure containing a subelement, "math", to hold the
 * right-hand side expression, then to derive subtypes of Rule that add
 * attributes to distinguish the cases of algebraic, assignment and rate
 * rules.  The "math" subelement must contain a MathML expression defining the
 * mathematical formula of the rule.  This MathML formula must return a
 * numerical value.  The formula can be an arbitrary expression referencing
 * the variables and other entities in an SBML model.
 *
 * Each of the three subclasses of Rule (AssignmentRule, AlgebraicRule,
 * RateRule) inherit the the "math" subelement and other fields from SBase.
 * The AssignmentRule and RateRule classes add an additional attribute,
 * "variable".  See the definitions of AssignmentRule, AlgebraicRule and
 * RateRule for details about the structure and interpretation of each one.
 *
 * @section rules-restrictions Additional restrictions on SBML rules
 *
 * An important design goal of SBML rule semantics is to ensure that a
 * model's simulation and analysis results will not be dependent on when or
 * how often rules are evaluated.  To achieve this, SBML needs to place two
 * restrictions on rule use.  The first concerns algebraic loops in the system
 * of assignments in a model, and the second concerns overdetermined systems.
 *
 * @subsection rules-no-loops A model must not contain algebraic loops
 *
 * The combined set of InitialAssignment, AssignmentRule and KineticLaw
 * objects in a model constitute a set of assignment statements that should be
 * considered as a whole.  (A KineticLaw object is counted as an assignment
 * because it assigns a value to the symbol contained in the "id" attribute of
 * the Reaction object in which it is defined.)  This combined set of
 * assignment statements must not contain algebraic loops---dependency
 * chains between these statements must terminate.  To put this more formally,
 * consider a directed graph in which nodes are assignment statements and
 * directed arcs exist for each occurrence of an SBML species, compartment or
 * parameter symbol in an assignment statement's "math" subelement.  Let the
 * directed arcs point from the statement assigning the symbol to the
 * statements that contain the symbol in their "math" subelement expressions.
 * This graph must be acyclic.
 *
 * SBML does not specify when or how often rules should be evaluated.
 * Eliminating algebraic loops ensures that assignment statements can be
 * evaluated any number of times without the result of those evaluations
 * changing.  As an example, consider the set of equations <em>x = x + 1</em>,
 * <em>y = z + 200</em> and <em>z = y + 100</em>.  If this set of equations
 * were interpreted as a set of assignment statements, it would be invalid
 * because the rule for <em>x</em> refers to <em>x</em> (exhibiting one type
 * of loop), and the rule for <em>y</em> refers to <em>z</em> while the rule
 * for <em>z</em> refers back to <em>y</em> (exhibiting another type of loop).
 * Conversely, the following set of equations would constitute a valid set of
 * assignment statements: <em>x = 10</em>, <em>y = z + 200</em>, and <em>z = x
 * + 100</em>.
 *
 * @subsection rules-not-overdetermined A model must not be overdetermined
 *
 * An SBML model must not be overdetermined; that is, a model must not
 * define more equations than there are unknowns in a model.  An SBML model
 * that does not contain AlgebraicRule structures cannot be overdetermined.
 *
 * LibSBML implements the static analysis procedure described in
 * Appendix&nbsp;B of the SBML Level&nbsp;3 Version&nbsp;1 Core
 * specification for assessing whether a model is overdetermined.
 *
 * (In summary, assessing whether a given continuous, deterministic,
 * mathematical model is overdetermined does not require dynamic analysis; it
 * can be done by analyzing the system of equations created from the model.
 * One approach is to construct a bipartite graph in which one set of vertices
 * represents the variables and the other the set of vertices represents the
 * equations.  Place edges between vertices such that variables in the system
 * are linked to the equations that determine them.  For algebraic equations,
 * there will be edges between the equation and each variable occurring in the
 * equation.  For ordinary differential equations (such as those defined by
 * rate rules or implied by the reaction rate definitions), there will be a
 * single edge between the equation and the variable determined by that
 * differential equation.  A mathematical model is overdetermined if the
 * maximal matchings of the bipartite graph contain disconnected vertexes
 * representing equations.  If one maximal matching has this property, then
 * all the maximal matchings will have this property; i.e., it is only
 * necessary to find one maximal matching.)
 *
 * @section RuleType_t Rule types for SBML Level 1
 *
 * SBML Level 1 uses a different scheme than SBML Level 2 and Level 3 for
 * distinguishing rules; specifically, it uses an attribute whose value is
 * drawn from an enumeration of 3 values.  LibSBML supports this using methods
 * that work @if clike a libSBML enumeration type,
 * @link Rule::RuleType_t RuleType_t@endlink, whose values
 * are @else with the enumeration values @endif@~ listed below.
 *
 * @li @sbmlconstant{RULE_TYPE_RATE, RuleType_t}: Indicates
 * the rule is a "rate" rule.
 * @li @sbmlconstant{RULE_TYPE_SCALAR, RuleType_t}:
 * Indicates the rule is a "scalar" rule.
 * @li @sbmlconstant{RULE_TYPE_INVALID, RuleType_t}:
 * Indicates the rule type is unknown or not yet set.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_unassigned_unit_are_not_a_default
 *
 * @note There is an important distinction to be made between <em>no units
 * assigned</em>, and assuming a value without units has any specific unit
 * such as <code>dimensionless</code>.  In SBML, default units are never
 * attributed to numbers, and numbers without units are not automatically
 * assumed to have the unit <code>dimensionless</code>.  Please consult the
 * relevant SBML specification document for a more in-depth explanation of
 * this topic and the SBML unit system.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_unit_inference_depends_on_model
 *
 * @note The functionality that facilitates unit analysis depends on the
 * model as a whole.  Thus, in cases where the object has not been added to
 * a model or the model itself is incomplete, unit analysis is not possible
 * and this method will return @c NULL.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_object_is_copied
 *
 * @note This method should be used with some caution.  The fact that this
 * method @em copies the object passed to it means that the caller will be
 * left holding a physically different object instance than the one contained
 * inside this object.  Changes made to the original object instance (such as
 * resetting attribute values) will <em>not affect the instance in this
 * object</em>.  In addition, the caller should make sure to free the
 * original object if it is no longer being used, or else a memory leak will
 * result.  Please see other methods on this class (particularly a
 * corresponding method whose name begins with the word <code>create</code>)
 * for alternatives that do not lead to these issues.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_math_string_syntax
 *
 * @note We urge developers to keep in mind that the text-string formula
 * syntax is specific to libSBML.  <em>Neither MathML nor SBML define a
 * text-string format for mathematical formulas.</em> LibSBML's particular
 * syntax should not be considered to be a canonical or standard
 * general-purpose mathematical expression syntax.  LibSBML provides methods
 * for parsing and transforming text-string math formulas back and forth from
 * AST structures for the convenience of calling applications, but it is
 * important to keep the system's limitations in mind.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_additional_typecode_details
 *
 * @par
 * Here follow some additional general information about libSBML type codes:
 *
 * @li The codes are the possible return values (integers) for the following
 * functions:
 * <ul>
 *     <li> SBase::getTypeCode()
 *     <li> ListOf::getItemTypeCode()
 * </ul>
 * (Compatibility note: in libSBML 5, the type of return values of these
 * functions changed from an enumeration to an integer for extensibility
 * in the face of different programming languages.)
 *
 * @li Each package extension must define similar sets of values for each
 * SBase subclass (e.g. <code>SBMLLayoutTypeCode_t</code> for the SBML Level&nbsp;3
 * %Layout extension, <code>SBMLFbcTypeCode_t</code> for the SBML Level&nbsp;3 Flux
 * Balance Constraints extension, etc.).
 *
 * @li The value of each package-specific type code can be duplicated between
 * those of different packages.  (This is necessary because the development
 * of libSBML extensions for different SBML packages may be undertaken by
 * different developers at different times; requiring the developers to
 * coordinate their use of type codes would be nettlesome and probably
 * doomed to failure.)
 *
 * @li To distinguish between the type codes of different packages, both the
 * return value of SBase::getTypeCode() and SBase::getPackageName() must be
 * checked.  This is particularly important for functions that take an SBML
 * type code as an argument, such as
 * SBase::getAncestorOfType(@if java int, String@endif), which by
 * default assumes you are handing it a core type, and will return @c NULL if
 * the value you give it is actually from a package.
 *
 * The following example code illustrates the combined use of
 * SBase::getPackageName() and SBase::getTypeCode():
 * @if cpp
 * @code{.cpp}
 void example (const SBase *sb)
 {
   cons std::string pkgName = sb->getPackageName();
   if (pkgName == "core")
   {
     switch (sb->getTypeCode())
     {
       case SBML_MODEL:
          ....
          break;
       case SBML_REACTION:
          ....
     }
   }
   else if (pkgName == "layout")
   {
     switch (sb->getTypeCode())
     {
       case SBML_LAYOUT_LAYOUT:
          ....
          break;
       case SBML_LAYOUT_REACTIONGLYPH:
          ....
     }
   }
   ...
 }
@endcode
@endif
@if python
@code{.py}
def example(item):
  pkg_name  = item.getPackageName()
  type_code = item.getTypeCode()
  if pkg_name == "core":
    print("Got a " + SBMLTypeCode_toString(type_code, "core") + " object")
    if type_code == SBML_MODEL:
      print("This is a very, very nice model")
      # Do whatever the application wants to do with the model.
    elif type_code == SBML_COMPARTMENT:
      print("This is a very, very nice compartment")
      # Do whatever the application wants to do with the compartment.
    elif type_code == SBML_SPECIES:
      print("This is a very, very nice species")
      # Do whatever the application wants to do with the species.
    elif ...
      ...
  elif pkg_name == "layout":
    print("Got a " + SBMLTypeCode_toString(type_code, "layout") + " object")
    if type_code == SBML_LAYOUT_POINT:
      print("This is a very, very nice layout point")
      # Do whatever the application wants to do with the layout point.
    elif type_code == SBML_LAYOUT_BOUNDINGBOX:
      print("This is a very, very nice layout bounding box")
      # Do whatever the application wants to do with the layout bounding box.
    elif ...
      ...
  elif pkg_name == "unknown":
    print("Something went wrong -- libSBML did not recognize the object type")
    # Handle errors
@endcode
@endif
@if java
@code{.java}
void example (SBase sb)
{
  String pkgName = sb.getPackageName();
  if (pkgName.equals("core"))
  {
    switch (sb.getTypeCode())
    {
      case libsbml.SBML_MODEL:
         ....
         break;
      case libsbml.SBML_REACTION:
         ....
    }
  }
  else if (pkgName.equals("layout"))
  {
    switch (sb.getTypeCode())
    {
      case libsbml.SBML_LAYOUT_LAYOUT:
         ....
         break;
      case libsbml.SBML_LAYOUT_REACTIONGLYPH:
         ....
    }
  }
  ...
}
@endcode
@endif
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_sbml_error_code_ranges
 *
 * @par
 * Calling programs may wish to check which enumeration a given SBMLError
 * object's error identifier is actually from:
 * @li 0000000 to 0009999: #XMLErrorCode_t (a low-level XML problem)
 *
 * @li 0010000 to 0099999: #SBMLErrorCode_t (a problem with the SBML
 * core specification)
 * @li 1000000 to 1099999: #CompSBMLErrorCode_t (a problem with the SBML
 * Level&nbsp;3 Hierarchical %Model Composition package specification).
 *
 * @li 2000000 to 2099999: #FbcSBMLErrorCode_t (a problem with the SBML
 * Level&nbsp;3 Flux Balance Constraints package specification).
 *
 * @li 3000000 to 3099999: #QualSBMLErrorCode_t (a problem with the SBML
 * Level&nbsp;3 Qualitative Models package specification).
 *
 * @li 6000000 to 6099999: #LayoutSBMLErrorCode_t (a problem with the SBML
 * Level&nbsp;3 %Layout package specification).
 *
 * Other error code ranges are reserved for other packages.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_static_methods
 *
 * @if python @note Because this is a static method on a class, the Python
 * language interface for libSBML will contain two variants.  One will be the
 * expected, normal static method on the class (i.e., a regular
 * <em>methodName</em>), and the other will be a standalone top-level
 * function with the name <em>ClassName_methodName()</em>. This is merely an
 * artifact of how the language interfaces are created in libSBML.  The
 * methods are functionally identical. @endif@~
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_setting_lv
 *
 * @note Attempting to add an object to an SBMLDocument having a different
 * combination of SBML Level, Version and XML namespaces than the object
 * itself will result in an error at the time a caller attempts to make the
 * addition.  A parent object must have compatible Level, Version and XML
 * namespaces.  (Strictly speaking, a parent may also have more XML
 * namespaces than a child, but the reverse is not permitted.)  The
 * restriction is necessary to ensure that an SBML model has a consistent
 * overall structure.  This requires callers to manage their objects
 * carefully, but the benefit is increased flexibility in how models can be
 * created by permitting callers to create objects bottom-up if desired.  In
 * situations where objects are not yet attached to parents (e.g.,
 * SBMLDocument), knowledge of the intented SBML Level and Version help
 * libSBML determine such things as whether it is valid to assign a
 * particular value to an attribute.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_what_is_user_data
 *
 * @par
 * The user data associated with an SBML object can be used by an application
 * developer to attach custom information to that object in the model.  In case
 * of a deep copy, this attribute will passed as it is.  The attribute will never
 * be interpreted by libSBML.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_renamesidref_common
 *
 * Replaces all uses of a given @c SIdRef type attribute value with another
 * value.
 *
 * @copydetails doc_what_is_sidref
 *
 * This method works by looking at all attributes and (if appropriate)
 * mathematical formulas in MathML content, comparing the referenced
 * identifiers to the value of @p oldid.  If any matches are found, the
 * matching values are replaced with @p newid.  The method does @em not
 * descend into child elements.
 *
 * @param oldid the old identifier
 * @param newid the new identifier
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_renameunitsidref_common
 *
 * Replaces all uses of a given @c UnitSIdRef type attribute value with
 * another value.
 *
 * @copydetails doc_what_is_unitsidref
 *
 * This method works by looking at all unit identifier attribute values
 * (including, if appropriate, inside mathematical formulas), comparing the
 * referenced unit identifiers to the value of @p oldid.  If any matches
 * are found, the matching values are replaced with @p newid.  The method
 * does @em not descend into child elements.
 *
 * @param oldid the old identifier
 * @param newid the new identifier
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_renamemetasidref_common
 *
 * Replaces all uses of a given meta identifier attribute value with
 * another value.
 *
 * @copydetails doc_what_is_metaidref
 *
 * This method works by looking at all meta-identifier attribute values,
 * comparing the identifiers to the value of @p oldid.  If any matches are
 * found, the matching identifiers are replaced with @p newid.  The method
 * does @em not descend into child elements.
 *
 * @param oldid the old identifier
 * @param newid the new identifier
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_section_using_sbml_converters
 *
 * @section using-converters General information about the use of SBML converters
 *
 * The use of all the converters follows a similar approach.  First, one
 * creates a ConversionProperties object and calls
 * ConversionProperties::addOption(@if java ConversionOption@endif)
 * on this object with one arguments: a text string that identifies the desired
 * converter.  (The text string is specific to each converter; consult the
 * documentation for a given converter to find out how it should be enabled.)
 *
 * Next, for some converters, the caller can optionally set some
 * converter-specific properties using additional calls to
 * ConversionProperties::addOption(@if java ConversionOption@endif).
 * Many converters provide the ability to
 * configure their behavior to some extent; this is realized through the use
 * of properties that offer different options.  The default property values
 * for each converter can be interrogated using the method
 * SBMLConverter::getDefaultProperties() on the converter class in question .
 *
 * Finally, the caller should invoke the method
 * SBMLDocument::convert(@if java ConversionProperties@endif)
 * with the ConversionProperties object as an argument.
 *
 * @subsection converter-example Example of invoking an SBML converter
 *
 * The following code fragment illustrates an example using
 * SBMLReactionConverter, which is invoked using the option string @c
 * "replaceReactions":
 *
 * @if cpp
 * @code{.cpp}
ConversionProperties props;
props.addOption("replaceReactions");
@endcode
@endif
@if python
@code{.py}
config = ConversionProperties()
if config != None:
  config.addOption("replaceReactions")
@endcode
@endif
@if java
@code{.java}
ConversionProperties props = new ConversionProperties();
if (props != null) {
  props.addOption("replaceReactions");
} else {
  // Deal with error.
}
@endcode
@endif
 *
 * In the case of SBMLReactionConverter, there are no options to affect
 * its behavior, so the next step is simply to invoke the converter on
 * an SBMLDocument object.  Continuing the example code:
 *
 * @if cpp
 * @code{.cpp}
// Assume that the variable "document" has been set to an SBMLDocument object.
int status = document->convert(props);
if (status != LIBSBML_OPERATION_SUCCESS)
{
  cerr << "Unable to perform conversion due to the following:" << endl;
  document->printErrors(cerr);
}
@endcode
@endif
@if python
@code{.py}
  # Assume that the variable "document" has been set to an SBMLDocument object.
  status = document.convert(config)
  if status != LIBSBML_OPERATION_SUCCESS:
    # Handle error somehow.
    print("Error: conversion failed due to the following:")
    document.printErrors()
@endcode
@endif
@if java
@code{.java}
  // Assume that the variable "document" has been set to an SBMLDocument object.
  status = document.convert(config);
  if (status != libsbml.LIBSBML_OPERATION_SUCCESS)
  {
    // Handle error somehow.
    System.out.println("Error: conversion failed due to the following:");
    document.printErrors();
  }
@endcode
@endif
 *
 * Here is an example of using a converter that offers an option. The
 * following code invokes SBMLStripPackageConverter to remove the
 * SBML Level&nbsp;3 @em %Layout package from a model.  It sets the name
 * of the package to be removed by adding a value for the option named
 * @c "package" defined by that converter:
 *
 * @if cpp
 * @code{.cpp}
ConversionProperties props;
props.addOption("stripPackage");
props.addOption("package", "layout");

int status = document->convert(props);
if (status != LIBSBML_OPERATION_SUCCESS)
{
    cerr << "Unable to strip the Layout package from the model";
    cerr << "Error returned: " << status;
}
@endcode
@endif
@if python
@code{.py}
def strip_layout_example(document):
  config = ConversionProperties()
  if config != None:
    config.addOption("stripPackage")
    config.addOption("package", "layout")
    status = document.convert(config)
    if status != LIBSBML_OPERATION_SUCCESS:
      # Handle error somehow.
      print("Error: unable to strip the Layout package.")
      print("LibSBML returned error: " + OperationReturnValue_toString(status).strip())
  else:
    # Handle error somehow.
    print("Error: unable to create ConversionProperties object")
@endcode
@endif
@if java
@code{.java}
ConversionProperties config = new ConversionProperties();
if (config != None) {
  config.addOption("stripPackage");
  config.addOption("package", "layout");
  status = document.convert(config);
  if (status != LIBSBML_OPERATION_SUCCESS) {
    // Handle error somehow.
    System.out.println("Error: unable to strip the Layout package");
    document.printErrors();
  }
} else {
  // Handle error somehow.
  System.out.println("Error: unable to create ConversionProperties object");
}
@endcode
@endif
 *
 * @subsection available-converters Available SBML converters in libSBML
 *
 * LibSBML provides a number of built-in converters; by convention, their
 * names end in @em Converter. The following are the built-in converters
 * provided by libSBML @htmlinclude libsbml-version.html:
 *
 * @copydetails doc_list_of_libsbml_converters
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_formulaunitsdata
 *
 * @par The first element of the list of FormulaUnitsData refers to the default
 * units of <em>"substance per time"</em> derived from the Model object,
 * and has a <code>unitReferenceId</code> attribute of
 * 'subs_per_time'. This facilitates the comparison of units derived from
 * mathematical formula with the expected units.  The next elements of the
 * list record the units of the compartments and species established from
 * either explicitly declared or default units.  Following those, the list
 * contains the units of any parameters in the model.  Finally, subsequent
 * elements of the list record the units derived for each mathematical
 * expression encountered within the model.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_returns_success_code
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmlextension
 *
 * @par
 * Each package implementation must contain a class that extends
 * SBMLExtension.  For example, the class <code>GroupsExtension</code> serves
 * this purpose for the SBML Level&nbsp;3 @em Groups package extension in
 * libSBML. The following subsections detail the basic steps involved in
 * implementing such an extended class.
 *
 * @subsection ext-getpackagename 1. Define the getPackageName() method
 *
 * Define a method named <code>getPackageName()</code> that returns the
 * name of the package as a string.  The following is an example from the
 * implementation of the Groups package extension:
@code{.cpp}
const std::string& GroupsExtension::getPackageName ()
{
      static const std::string pkgName = "groups";
      return pkgName;
}
@endcode
 *
 *
 * @subsection ext-version-methods 2. Define methods returning package version information
 *
 * Define a set of methods that return the default SBML Level, SBML
 * Version and version of the package.  These methods must be named
 * <code>getDefaultLevel()</code>, <code>getDefaultVersion()</code> and
 * <code>getDefaultPackageVersion()</code>, respectively.  The following
 * are examples drawn from the Groups package implementation:
@code{.cpp}
unsigned int GroupsExtension::getDefaultLevel()
{
      return 3;
}
unsigned int GroupsExtension::getDefaultVersion()
{
      return 1;
}
unsigned int GroupsExtension::getDefaultPackageVersion()
{
      return 1;
}
@endcode
 *
 *
 * @subsection ext-ns 3. Define methods returning the package namespace URIs
 *
 * Define methods that return strings representing the XML namespace URI
 * for the package.  One method should be defined for each SBML Level/Version
 * combination for which the package can be used.  For instance, if a package
 * is only usable in SBML Level&nbsp;3 Version&nbsp;1, and the libSBML
 * extension for the package implements version&nbsp;1 of the package, the
 * necessary method is <code>getXmlnsL3V1V1()</code>.  
@code{.cpp}
const std::string& GroupsExtension::getXmlnsL3V1V1 ()
{
      static const std::string xmlns = "http://www.sbml.org/sbml/level3/version1/groups/version1";
      return xmlns;
}
@endcode
 *
 * Define other similar methods to return additional namespace URIs if the
 * package extension implements other package versions or supports other SBML
 * Level/Version combinations.
 *
 *
 * @subsection ext-virtual 4. Override basic pure virtual methods
 *
 * Override the following pure virtual methods on SBMLExtension:
 *
 * @li <code>virtual const std::string& getName() const =0</code>. This
 * method returns the nickname of the package (e.g., "layout",
 * "groups").
 *
 * @li <code>virtual unsigned int getLevel(const std::string &uri) const
 * =0</code>. This method returns the SBML Level with the given URI of
 * this package.
 *
 * @li <code>virtual unsigned int getVersion(const std::string &uri)
 * const =0</code>. This method returns the SBML Version with the given
 * URI of this package.
 *
 * @li <code>virtual unsigned int getPackageVersion(const std::string
 * &uri) const =0</code>. This method returns the package version with
 * the given URI of this package.
 *
 * @li <code>virtual unsigned int getURI(unsigned int sbmlLevel,
 * unsigned int sbmlVersion, unsigned int pkgVersion) const =0</code>.
 * This method returns the URI (namespace) of the package corresponding
 * to the combination of the given SBML Level, SBML Version, and package
 * version
 *
 * @li <code>virtual SBMLExtension* clone() const = 0</code>. This
 * method creates and returns a deep copy of this derived object.
 *
 * As an example, the following are the versions of these methods for
 * the Groups package:
 * @code{.cpp}
const std::string& GroupsExtension::getName() const
{
  return getPackageName();
}

unsigned int GroupsExtension::getLevel(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
    return 3;
  else
    return 0;
}

unsigned int GroupsExtension::getVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
    return 1;
  else
    return 0;
}

unsigned int GroupsExtension::getPackageVersion(const std::string &uri) const
{
  if (uri == getXmlnsL3V1V1())
    return 1;
  else
    return 0;
}

const std::string& GroupsExtension::getURI(unsigned int sbmlLevel,
                                           unsigned int sbmlVersion,
                                           unsigned int pkgVersion) const
{
  if (sbmlLevel == 3 && sbmlVersion == 1 && pkgVersion == 1)
    return getXmlnsL3V1V1();

  static std::string empty = "";
  return empty;
}

GroupsExtension* GroupsExtension::clone() const
{
  return new GroupsExtension(*this);
}
@endcode
 *
 * Constructor, copy constructor, and destructor methods also must be
 * overridden if additional data members are defined in the derived class.
 *
 *
 * @subsection ext-typedef 5. Create SBMLExtensionNamespaces-related definitions
 *
 * Define typedef and template instantiation code for a package-specific
 * subclass of the SBMLExtensionNamespaces template class.  The
 * SBMLExtensionNamespaces template class is a derived class of
 * SBMLNamespaces and can be used as an argument of constructors of
 * SBase-derived classes defined in the package extensions.
 *
 * <ol>
 *
 * <li> Define a typedef.  For example, the typedef for
 * <code>GroupsExtension</code> is implemented in the file
 * <code>GroupsExtension.h</code> as follows:
@code{.cpp}
// GroupsPkgNamespaces is derived from the SBMLNamespaces class.
// It is used when creating a Groups package object of a class
// derived from SBase.
typedef SBMLExtensionNamespaces<GroupsExtension> GroupsPkgNamespaces;
@endcode
 * </li>
 *
 * <li> Define a template instantiation for the typedef.  For example, the
 * template instantiation code for <code>GroupsExtension is</code> implemented
 * in the file <code>GroupsExtension.cpp</code> as follows:
@code{.cpp}
template class LIBSBML_EXTERN SBMLExtensionNamespaces<GroupsExtension>;
@endcode
 * </li>
 *
 * </ol>
 *
 * Here is example of how the resulting class is used.  The definitions above
 * allow a <code>GroupsPkgNamespaces</code> object to be used when creating a
 * new <code>Group</code> object.  The <code>GroupsPkgNamespaces</code> is
 * handed to the constructor as an argument, as shown below:
@code{.cpp}
GroupPkgNamespaces gpns(3, 1, 1);  // SBML Level, Version, & pkg version.
Group g = new Group(&gpns);        // Creates a Group object.
@endcode
 *
 * The <code>GroupsPkgNamespaces</code> object can also be used when creating
 * an SBMLDocument object with the Groups package.  The code fragment
 * below shows an example of this:
@code{.cpp}
   GroupsPkgNamespaces gpns(3, 1, 1);
   SBMLDocument* doc;
   doc  = new SBMLDocument(&gnps);
@endcode
 *
 *
 * @subsection ext-virtual-ns 6. Override the method getSBMLExtensionNamespaces()
 *
 * Override the pure virtual method <code>getSBMLExtensionNamespaces()</code>,
 * which returns an SBMLNamespaces derived object.  For example, the method
 * is overridden in the class <code>GroupsExtension</code> as follows:
@code{.cpp}
SBMLNamespaces*
GroupsExtension::getSBMLExtensionNamespaces(const std::string &uri) const
{
  GroupsPkgNamespaces* pkgns = NULL;
  if ( uri == getXmlnsL3V1V1())
  {
    pkgns = new GroupsPkgNamespaces(3, 1, 1);
  }
  return pkgns;
}
@endcode
 *
 *
 * @subsection ext-enum 7. Define an enumeration for the package object type codes
 *
 * Define an enum type for representing the type code of the objects defined
 * in the package extension.  For example, the enumeration
 * <code>SBMLGroupsTypeCode_t</code> for the Groups package is defined in
 * <code>GroupsExtension.h</code> as follows:
@code{.cpp}
typedef enum
{
   SBML_GROUPS_GROUP  = 200
 , SBML_GROUPS_MEMBER = 201
} SBMLGroupsTypeCode_t;
@endcode
 *
 * In the enumeration above, <code>SBML_GROUPS_GROUP</code> corresponds to
 * the <code>Group</code> class (for the <code>&lt;group&gt;</code> element
 * defined by the SBML Level&nbsp;3 Groups package) and
 * <code>SBML_GROUPS_MEMBER</code> corresponds to the <code>Member</code>
 * class (for the <code>&lt;member&gt;</code> element defined by the
 * Level&nbsp;3 Groups package), respectively.
 *
 * Similarly, #SBMLLayoutTypeCode_t for the Layout package is defined in
 * the file <code>LayoutExtension.h</code> as follows:
 *
@code{.cpp}
typedef enum
{
   SBML_LAYOUT_BOUNDINGBOX           = 100
 , SBML_LAYOUT_COMPARTMENTGLYPH      = 101
 , SBML_LAYOUT_CUBICBEZIER           = 102
 , SBML_LAYOUT_CURVE                 = 103
 , SBML_LAYOUT_DIMENSIONS            = 104
 , SBML_LAYOUT_GRAPHICALOBJECT       = 105
 , SBML_LAYOUT_LAYOUT                = 106
 , SBML_LAYOUT_LINESEGMENT           = 107
 , SBML_LAYOUT_POINT                 = 108
 , SBML_LAYOUT_REACTIONGLYPH         = 109
 , SBML_LAYOUT_SPECIESGLYPH          = 110
 , SBML_LAYOUT_SPECIESREFERENCEGLYPH = 111
 , SBML_LAYOUT_TEXTGLYPH             = 112
} SBMLLayoutTypeCode_t;
@endcode
 *
 * These enum values are returned by corresponding <code>getTypeCode()</code>
 * methods.  (E.g., <code>SBML_GROUPS_GROUP</code> is returned in
 * <code>Group::getTypeCode()</code>.)
 *
 * Note that libSBML does not require that type codes are unique across all
 * packages&mdash;the same type codes may be used within individual package
 * extensions.  LibSBML development must permit this because package
 * implementations are developed by separate groups at different times;
 * coordinating the type codes used is impractical.  It does mean that
 * callers must check two things when identifying objects: to distinguish the
 * type codes of different packages, callers much check not only the return
 * value of the method <code>getTypeCode()</code> method but also that of the
 * method <code>getPackageName()</code>.  Here is an example of doing that:
@code{.cpp}
void example (const SBase *sb)
{
  const std::string pkgName = sb->getPackageName();
  if (pkgName == "core") {
    switch (sb->getTypeCode()) {
      case SBML_MODEL:
         ....
         break;
      case SBML_REACTION:
         ....
    }
  }
  else if (pkgName == "layout") {
    switch (sb->getTypeCode()) {
      case SBML_LAYOUT_LAYOUT:
         ....
         break;
      case SBML_LAYOUT_REACTIONGLYPH:
         ....
    }
  }
  else if (pkgName == "groups") {
    switch (sb->getTypeCode()) {
      case SBML_GROUPS_GROUP:
         ....
         break;
      case SBML_GROUPS_MEMBER:
         ....
    }
  }
  ...
}
@endcode
 *
 * Readers may have noticed that in the #SBMLLayoutTypeCode_t and
 * <code>SBMLGroupsTypeCode_t</code> enumerations above, unique values
 * are in fact assigned to the enumeration values.  This can be convenient
 * when it can be arranged, but it is not required by libSBML.
 *
 *
 * @subsection ext-virtual-typecodes 8. Override the method getStringFromTypeCode()
 *
 * Override the pure virtual method <code>getStringFromTypeCode()</code>,
 * which returns a string corresponding to the given type code.  Here is an
 * example, again drawn from the implementation of the Groups package:
@code{.cpp}
virtual const char* SBMLExtension::(int typeCode) const;
@endcode
 *
 * For example, the method for the Groups extension is implemented as
 * shown below:
@code{.cpp}
static const char* SBML_GROUPS_TYPECODE_STRINGS[] =
{
    "Group"
  , "Member"
};

const char* GroupsExtension::getStringFromTypeCode(int typeCode) const
{
  int min = SBML_GROUPS_GROUP;
  int max = SBML_GROUPS_MEMBER;

  if (typeCode < min || typeCode > max)
  {
    return "(Unknown SBML Groups Type)";
  }

  return SBML_GROUPS_TYPECODE_STRINGS[typeCode - min];
}
@endcode
 *
 *
 * @subsection ext-init 9. Implement an init() method
 *
 * Implement a <code>static void init()</code> method in the derived class.
 * This method serves to encapsulate initialization code that creates an
 * instance of the derived class and registration code that registers the
 * instance with the SBMLExtensionRegistry class.
 *
 * For example, the <code>init()</code> method for the Groups package is
 * implemented as follows:
@code{.cpp}
void GroupsExtension::init()
{
  // 1. Check if the Groups package has already been registered.

  if ( SBMLExtensionRegistry::getInstance().isRegistered(getPackageName()) )
  {
    // do nothing;
    return;
  }

  // 2. Create an SBMLExtension derived object.

  GroupsExtension gext;

  // 3. Create SBasePluginCreator-derived objects. The derived classes
  // can be instantiated by using the following template class:
  //
  //   template<class SBasePluginType> class SBasePluginCreator
  //
  // The constructor of the creator class takes two arguments:
  //
  // 1) SBaseExtensionPoint: extension point to which the plugin connects
  // 2) std::vector<std::string>: a vector that contains a list of URI
  // (package versions) supported by the plugin object.
  //
  // For example, two plugin objects are required as part of the Groups
  // implementation: one plugged into SBMLDocument and one into Model.
  // For the former, since the specification for the SBML Groups package
  // mandates that the 'required' flag is always 'false', the existing
  // SBMLDocumentPluginNotRequired class can be used as-is as part of
  // the implementation.  For Model, since the lists of supported
  // package versions (currently only SBML L3V1 Groups V1) are equal
  // in the both plugin objects, the same vector can be handed to each
  // constructor.

  std::vector<std::string> pkgURIs;
  pkgURIs.push_back(getXmlnsL3V1V1());

  SBaseExtensionPoint docExtPoint("core", SBML_DOCUMENT);
  SBaseExtensionPoint modelExtPoint("core", SBML_MODEL);

  SBasePluginCreator<GroupsSBMLDocumentPlugin, GroupsExtension> docPluginCreator(docExtPoint, pkgURIs);
  SBasePluginCreator<GroupsModelPlugin, GroupsExtension> modelPluginCreator(modelExtPoint, pkgURIs);

  // 4. Add the above objects to the SBMLExtension-derived object.

  gext.addSBasePluginCreator(&docPluginCreator);
  gext.addSBasePluginCreator(&modelPluginCreator);

  // 5. Register the SBMLExtension-derived object with the extension
  // registry, SBMLExtensionRegistry.

  int result = SBMLExtensionRegistry::getInstance().addExtension(&gext);
  if (result != LIBSBML_OPERATION_SUCCESS)
  {
    std::cerr << "[Error] GroupsExtension::init() failed." << std::endl;
  }
}
@endcode
 *
 *
 * @subsection ext-extensionregister 10. Instantiate a SBMLExtensionRegister variable
 *
 * Instantiate a global SBMLExtensionRegister object using the
 * class derived from SBMLExtension (discussed above).  Here is an example for
 * the Groups package extension, for the object <code>GroupsExtension</code>.
 * This could is placed in the <code>GroupsExtension.cpp</code>:
@code{.cpp}
static SBMLExtensionRegister<GroupsExtension> groupsExtensionRegister;
@endcode
 *
 * The <code>init()</code> method on <code>GroupsExtension</code> is
 * automatically invoked when the "register" object is instantiated.  This
 * results in initialization and registration of the package extension
 * with libSBML.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_sbaseplugincreator_objects
 *
 * @par
 * Package extensions in libSBML are hooked into individual SBML objects
 * using objects of class SBaseExtensionPoint.  These objects are added to
 * the set of objects created when a plugin is invoked through the use of
 * SBasePluginCreatorBase objects.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_note_override_in_extensions
 *
 * @note
 * This is a method that package extension implementations must override.
 * See the libSBML documentation on extending libSBML to support SBML
 * packages for more information on this topic.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_basics_of_extensions
 *
 * @section ext-basics Basic principles of SBML package extensions in libSBML
 *
 * @par
 * SBML Level&nbsp;3's package structure permits modular extensions to the
 * core SBML format.  In libSBML, support for SBML Level&nbsp;3 packages is
 * provided through <em>package extensions</em>.  LibSBML defines a number of
 * classes that developers of package extensions can use to implement support
 * for an SBML Level&nbsp;3 package.  These classes make it easier to extend
 * libSBML objects with new attributes and/or subobjects as needed by a
 * particular Level&nbsp;3 package.  Users of the libSBML library can also
 * choose which extensions are enabled in their software applications.
 *
 * Three overall categories of classes make up libSBML's facilities for
 * implementing package extensions.  There are (1) classes that serve as
 * base classes meant to be subclassed, (2) template classes meant to be
 * instantiated rather than subclassed, and (3) support classes that
 * provide utility features.  These are summarized further below.
 *
 * A given package implementation for libSBML will take the form of code
 * using these and other libSBML classes, placed in a subdirectory of
 * <code>src/sbml/packages/</code>.  Examples already exist in the libSBML
 * distribution; the Level&nbsp;3 packages <em>Flux Balance Constraints</em>
 * ("fbc"), <em>Hierarchical %Model Composition</em> ("comp"), <em>%Layout</em>
 * ("layout"), and <em>Qualitative Models</em> ("qual") are now standard with
 * libSBML and can be found in that directory.  They can serve as working
 * examples for developers working to implement other packages.
 *
 * Extensions in libSBML can currently only be implemented in C++ or C;
 * there is no mechanism to implement them in language bindings such as
 * Java or Python.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_summary_of_extension_classes
 *
 * @section ext-classes Summary of libSBML package extension classes
 *
 * Implementing support for a given SBML Level&nbsp;3 package means
 * creating new SBML component objects (some may be extensions of existing
 * SBML components and others may be entirely new ones), plugging those
 * object implementations into libSBML, and finally, doing some additional
 * chores to make everything work.  Here is a summary of the support
 * classes provided by the libSBML extension mechanism for accomplishing
 * these tasks.
 *
 *
 * @subsection ext-to-be-extended Classes to be extended
 *
 * The following are the classes that typically need to be extended by
 * creating subclasses specific to a given package extension:
 *
 * @li SBMLExtension: For each extension, a subclass of this class is used
 * to implement methodality related to the package extension itself, such
 * as the version(s) of the SBML package it supports.  This class provides
 * methods for getting common attributes of package extension, and methods
 * for initializing and registering the package when the package code is
 * loaded into libSBML.
 *
 * @li SBasePlugin: This is the base class of extensions to existing SBML
 * objects derived from SBase.  A typical package extension will derive
 * multiple classes from SBasePlugin, each one extending a different SBML
 * object with new features defined by the package.  For a given
 * extended SBML object, the derived class will typically be designed to
 * contain additional attributes and/or subobjects of an SBML package,
 * and it will provide methods for accessing the additional attributes
 * and/or elements.
 *
 * @li SBMLDocumentPlugin: This is a base class that a package
 * implementation can either use directly if it adds no attribute other
 * than the "required" attribute to the <code>&lt;sbml&gt;</code> element,
 * or else must subclass if the SBML package defines more attributes.
 *
 *
 * @subsection ext-to-be-instantiated Classes to be instantiated
 *
 * Some classes in the libSBML package extension facilities are not meant
 * to be subclassed, but rather are designed to be instantiated.
 *
 * @li SBasePluginCreator: This is a template class used to create factory
 * objects that in turn construct new instances of package plugin objects
 * when necessary.  These factory objects are invoked when, for example,
 * libSBML encounters an SBML Level&nbsp;3 package in an SBML document and
 * needs to activate the corresponding libSBML package extension.  Package
 * implementations need to use SBasePluginCreator to create factory objects
 * for each class derived from SBasePlugin, and then they have to register
 * these factory objects with the SBMLExtension derived class for the package
 * extension.
 *
 * @li SBMLExtensionNamespaces: This is a template class; it is itself an
 * extension of SBMLNamespaces, and adds information specific to each
 * package implementation.  The resulting namespace object is used when
 * creating package objects extended from SBase.  Each libSBML package
 * extension must define its own variant using the SBMLExtensionNamespaces
 * template class.
 *
 * @li SBMLExtensionRegister: This is a registration template class.  It is
 * used by package extensions to register themselves with the
 * SBMLExtensionRegistry (see below) when libSBML starts up.  An instance of
 * this class needs to be created by each package extension and used in a
 * call to a method on SBMLExtensionRegistry.
 *
 *
 * @subsection ext-additional-helpers Additional helper classes
 *
 * The following additional classes do not need to be extended or
 * instantiated; rather, they need to be called by other parts of a package
 * implementation to accomplish bookkeeping or other tasks necessary to
 * make the extension work in libSBML:
 *
 * @li SBaseExtensionPoint: This class is used as part of the mechanism that
 * connects plugin objects (implemented using SBasePlugin or
 * SBMLDocumentPlugin) to a package extension.  For instance, an
 * implementation of an extended version of Model (e.g., LayoutModelPlugin in
 * the %Layout package) would involve the creation of an extension point
 * using SBaseExtensionPoint and a mediator object created with
 * SBasePluginCreator, to "plug" the extended Model object
 * (LayoutModelPlugin) into the overall LayoutExtension object.
 *
 * @li SBMLExtensionRegistry: This class provides a central registry of all
 * extensions known to libSBML.  Each package extension is registered with
 * the registry.  The registry class is accessed by various classes to
 * retrieve information about known package extensions and to create
 * additional attributes and/or elements by factory objects of the package
 * extensions.  LibSBML cannot parse package extensions which are not
 * registered with the registry.
 *
 * @li SBMLExtensionException: As its name implies, this is an exception
 * class.  It is the class of exceptions thrown when package extensions
 * encounter exceptions.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbaseplugin
 *
 * @par
 * LibSBML package extensions can extend existing libSBML objects such as Model
 * using SBasePlugin as a base class, to hold attributes and/or subcomponents
 * necessary for the SBML package being implemented.  Package developers must
 * implement an SBasePlugin extended class for each element to be extended
 * (e.g., Model, Reaction, and others) where additional attributes and/or
 * top-level objects of the package extension are directly contained.  The
 * following subsections detail the basic steps necessary to use SBasePlugin
 * for the implementation of a class extension.
 *
 * @subsection sbp-identify 1. Identify the SBML components that need to be extended
 *
 * The specification for a SBML Level&nbsp;3 package will define the
 * attributes and subojects that make up the package constructs.  Those
 * constructs that modify existing SBML components such as Model,
 * Reaction, etc., will be the ones that need to be extended using SBasePlugin.
 *
 * For example, the Layout package makes additions to Model,
 * SpeciesReference, and the <code>&lt;sbml&gt;</code> element (which is
 * represented in libSBML by SBMLDocument).  This means that the Layout
 * package extension in libSBML needs to define extended versions of Model,
 * SpeciesReference and SBMLDocument.  Elements @em other than the SBML
 * document need to be implemented using SBasePlugin; the document component
 * must be implemented using SBMLDocumentPlugin instead.
 *
 *
 * @subsection sbp-implement 2. Create a SBasePlugin subclass for each extended SBML component
 *
 * A new class definition that subclasses SBasePlugin needs to be created for
 * each SBML component to be extended by the package.  For instance, the
 * Layout package needs LayoutModelPlugin and LayoutSpeciesReferencePlugin.
 * (As mentioned above, the Layout class also needs LayoutSBMLDocumentPlugin,
 * but this one is implemented using SBMLDocumentPlugin instead of
 * SBasePlugin.)  Below, we describe in detail the different parts of an
 * SBasePlugin subclass definition.
 *
 * @subsubsection sbp-protected 2.1 Define protected data members
 *
 * Data attributes on each extended class in an SBML package will have one of
 * the data types <code>std::string</code>, <code>double</code>,
 * <code>int</code>, or <code>bool</code>.  Subelements/subobjects will normally
 * be derived from the ListOf class or from SBase.
 *
 * The additional data members must be properly initialized in the class
 * constructor, and must be properly copied in the copy constructor and
 * assignment operator.  For example, the following data member is defined in
 * the <code>GroupsModelPlugin</code> class (in the file
 * <code>GroupsModelPlugin.h</code>):
 * @code{.cpp}
ListOfGroups mGroups;
@endcode
 *
 * @subsubsection sbp-class-methods 2.2 Override SBasePlugin class-related methods
 *
 * The derived class must override the constructor, copy constructor, assignment
 * operator (<code>operator=</code>) and <code>clone()</code> methods from
 * SBasePlugin.
 *
 *
 * @subsubsection sbp-methods-attribs 2.3 Override SBasePlugin virtual methods for attributes
 *
 * If the extended component is defined by the SBML Level&nbsp;3 package to have
 * attributes, then the extended class definition needs to override the
 * following internal methods on SBasePlugin and provide appropriate
 * implementations:
 *
 * @li <code>addExpectedAttributes(ExpectedAttributes& attributes)</code>: This
 * method should add the attributes that are expected to be found on this kind
 * of extended component in an SBML file or data stream.
 *
 * @li <code>readAttributes(XMLAttributes& attributes, ExpectedAttributes&
 * expectedAttributes)</code>: This method should read the attributes
 * expected to be found on this kind of extended component in an SBML file or
 * data stream.
 *
 * @li <code>hasRequiredAttributes()</code>: This method should return @c true
 * if all of the required attribute for this extended component are present on
 * instance of the object.
 *
 * @li <code>writeAttributes(XMLOutputStream& stream)</code>: This method should
 * write out the attributes of an extended component.  The implementation should
 * use the different kinds of <code>writeAttribute</code> methods defined by
 * XMLOutputStream to achieve this.
 *
 *
 * @subsubsection sbp-methods-elem 2.4 Override SBasePlugin virtual methods for subcomponents
 *
 * If the extended component is defined by the Level&nbsp;3 package to have
 * subcomponents (i.e., full XML elements rather than mere attributes), then the
 * extended class definition needs to override the following internal
 * SBasePlugin methods and provide appropriate implementations:
 *
 * @li <code>createObject(XMLInputStream& stream)</code>: Subclasses must
 * override this method to create, store, and then return an SBML object
 * corresponding to the next XMLToken in the XMLInputStream.  To do this,
 * implementations can use methods like <code>peek()</code> on XMLInputStream to
 * test if the next object in the stream is something expected for the package.
 * For example, LayoutModelPlugin uses <code>peek()</code> to examine the next
 * element in the input stream, then tests that element against the Layout
 * namespace and the element name <code>"listOfLayouts"</code> to see if it's
 * the single subcomponent (ListOfLayouts) permitted on a Model object using the
 * Layout package.  If it is, it returns the appropriate object.
 *
 * @li <code>connectToParent(SBase *sbase)</code>: This creates a parent-child
 * relationship between a given extended component and its subcomponent(s).
 *
 * @li <code>setSBMLDocument(SBMLDocument* d)</code>: This method should set the
 * parent SBMLDocument object on the subcomponent object instances, so that the
 * subcomponent instances know which SBMLDocument contains them.
 *
 * @li <code>enablePackageInternal(std::string& pkgURI, std::string& pkgPrefix,
 * bool flag)</code>: This method should enable or disable the subcomponent
 * based on whether a given XML namespace is active.
 *
 * @li <code>writeElements(XMLOutputStream& stream)</code>: This method must be
 * overridden to provide an implementation that will write out the expected
 * subcomponents/subelements to the XML output stream.
 *
 * @li <code>readOtherXML(SBase* parentObject, XMLInputStream& stream)</code>:
 * This function should be overridden if elements of annotation, notes, MathML
 * content, etc., need to be directly parsed from the given XMLInputStream
 * object.
 *
 * @li <code>hasRequiredElements()</code>: This method should return @c true if
 * a given object contains all the required subcomponents defined by the
 * specification for that SBML Level&nbsp;3 package.
 *
 *
 * @subsubsection sbp-methods-xmlns 2.5 Override SBasePlugin virtual methods for XML namespaces
 *
 * If the package needs to add additional <code>xmlns</code> attributes to
 * declare additional XML namespace URIs, the extended class should override the
 * following method:
 *
 * @li <code>writeXMLNS(XMLOutputStream& stream)</code>: This method should
 * write out any additional XML namespaces that might be needed by a package
 * implementation.
 *
 *
 * @subsubsection sbp-methods-hooks 2.6 Implement additional methods as needed
 *
 * Extended component implementations can add whatever additional utility
 * methods are useful for their implementation.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmldocumentplugin
 *
 * @par
 * The following subsections detail the basic steps necessary to use
 * SBMLDocumentPlugin to extend SBMLDocument for a given package extension.
 *
 *
 * @subsection sdp-identify 1. Identify the changes necessary to SBMLDocument
 *
 * The specification for a SBML Level&nbsp;3 package will define the
 * changes to the SBML <code>&lt;sbml&gt;</code> element.  Packages
 * typically do not make any changes beyond adding an attribute named
 * "required" (discussed below), so in most cases, the extension of
 * SBMLDocument is very simple.  However, some packages do more.  For
 * instance, the Hierarchical %Model Composition package adds subobjects
 * for lists of model definitions.  SBMLDocumentPlugin supports all these
 * cases.
 *
 *
 * @subsection sdp-implement 2. Create the SBMLDocumentPlugin subclass
 *
 * A package extension will only define one subclass of SBMLDocumentPlugin.
 * Below, we describe in detail the different parts of a subclass
 * definition.
 *
 *
 * @subsubsection sdp-class  2.1 Override SBasePlugin class-related methods
 *
 * The derived class must override the constructor, copy constructor, assignment
 * operator (<code>operator=</code>) and <code>clone()</code> methods from
 * SBasePlugin.
 *
 *
 * @subsubsection sdp-required 2.2 Determine the necessary value of the "required" attribute
 *
 * At minimum, it is necessary for a package implementation to add the
 * "required" attribute to the SBML <code>&lt;sbml&gt;</code> element
 * mandated by SBML for all Level&nbsp;3 packages, and this is done using
 * this class as a base.  If the 'required' attribute is the @em only
 * addition necessary for a particular SBML Level&nbsp;3 package, then the
 * subclass of SBMLDocumentPlugin for the package can have a very simple
 * implementation.  Some Level&nbsp;3 packages add additional attributes or
 * elements to <code>&lt;sbml&gt;</code>, and their implementations would
 * go into the subclassed SBMLDocumentPlugin.
 *
 * SBMLDocumentPlugin provides methods with default implementations that
 * support managing the "required" attribute, so package extension code
 * does not need to provide implementations&mdash;they only need to set the
 * correct value for the SBML Level&nbsp;3 package based on its
 * specification.  The following are the virtual methods for working with
 * the "required" attribute.  Package extensions would only need to
 * override them in special circumstances:
 *
 * @li <code>setRequired(bool value)</code>: This method sets the value
 * of the flag.
 *
 * @li <code>getRequired()</code>: This method gets the value of the
 * "required" flag.
 *
 * @li <code>isSetRequired()</code>: This method tests if the value has
 * been set.
 *
 * @li <code>unsetRequired()</code>: This method unsets the value of the
 * "required" flag.
 *
 *
 * @subsubsection sdp-protected 2.3 Define protected data members
 *
 * An extended SBMLDocument object may need more than just the "required"
 * attribute, depending on what is defined in the specification for the
 * package being implemented.  Data attributes on the extended
 * <code>&lt;sbml&gt;</code> object in an SBML package will have one of the
 * data types <code>std::string</code>, <code>double</code>,
 * <code>int</code>, or <code>bool</code>.  Subelements/subobjects will
 * normally be derived from the ListOf class or from SBase.
 *
 * The additional data members must be properly initialized in the class
 * constructor, and must be properly copied in the copy constructor and
 * assignment operator.
 *
 *
 * @subsubsection sdp-methods-attribs 2.4 Override virtual methods for attributes
 *
 * If the extended component is defined by the SBML Level&nbsp;3 package to
 * have attributes, then the extended SBMLDocumentPlugin class definition
 * needs to override the following internal methods that come from
 * SBasePlugin (the base class of SBMLDocumentPlugin) and provide
 * appropriate implementations:
 *
 * @li <code>addExpectedAttributes(ExpectedAttributes& attributes)</code>: This
 * method should add the attributes that are expected to be found on this kind
 * of extended component in an SBML file or data stream.
 *
 * @li <code>readAttributes(XMLAttributes& attributes, ExpectedAttributes&
 * expectedAttributes)</code>: This method should read the attributes
 * expected to be found on this kind of extended component in an SBML file or
 * data stream.
 *
 * @li <code>hasRequiredAttributes()</code>: This method should return @c true
 * if all of the required attribute for this extended component are present on
 * instance of the object.
 *
 * @li <code>writeAttributes(XMLOutputStream& stream)</code>: This method should
 * write out the attributes of an extended component.  The implementation should
 * use the different kinds of <code>writeAttribute</code> methods defined by
 * XMLOutputStream to achieve this.
 *
 *
 * @subsubsection sdp-methods-elem 2.5 Override virtual methods for subcomponents
 *
 * If the extended component is defined by the Level&nbsp;3 package to have
 * subcomponents (i.e., full XML elements rather than mere attributes),
 * then the extended class definition needs to override the following
 * internal methods on SBasePlugin (the base class of SBMLDocumentPlugin)
 * and provide appropriate implementations:
 *
 * @li <code>createObject(XMLInputStream& stream)</code>: Subclasses must
 * override this method to create, store, and then return an SBML object
 * corresponding to the next XMLToken in the XMLInputStream.  To do this,
 * implementations can use methods like <code>peek()</code> on XMLInputStream to
 * test if the next object in the stream is something expected for the package.
 * For example, LayoutModelPlugin uses <code>peek()</code> to examine the next
 * element in the input stream, then tests that element against the Layout
 * namespace and the element name <code>"listOfLayouts"</code> to see if it's
 * the single subcomponent (ListOfLayouts) permitted on a Model object using the
 * Layout package.  If it is, it returns the appropriate object.
 *
 * @li <code>connectToParent(SBase *sbase)</code>: This creates a parent-child
 * relationship between a given extended component and its subcomponent(s).
 *
 * @li <code>setSBMLDocument(SBMLDocument* d)</code>: This method should set the
 * parent SBMLDocument object on the subcomponent object instances, so that the
 * subcomponent instances know which SBMLDocument contains them.
 *
 * @li <code>enablePackageInternal(std::string& pkgURI, std::string& pkgPrefix,
 * bool flag)</code>: This method should enable or disable the subcomponent
 * based on whether a given XML namespace is active.
 *
 * @li <code>writeElements(XMLOutputStream& stream)</code>: This method must be
 * overridden to provide an implementation that will write out the expected
 * subcomponents/subelements to the XML output stream.
 *
 * @li <code>readOtherXML(SBase* parentObject, XMLInputStream& stream)</code>:
 * This function should be overridden if elements of annotation, notes, MathML
 * content, etc., need to be directly parsed from the given XMLInputStream
 * object.
 *
 * @li <code>hasRequiredElements()</code>: This method should return @c true if
 * a given object contains all the required subcomponents defined by the
 * specification for that SBML Level&nbsp;3 package.
 *
 *
 * @subsubsection sdp-methods-xmlns 2.6 Override virtual methods for XML namespaces
 *
 * If the package needs to add additional <code>xmlns</code> attributes to
 * declare additional XML namespace URIs, the extended class should
 * override the following method coming from SBasePlugin (the parent class
 * of SBMLDocumentPlugin):
 *
 * @li <code>writeXMLNS(XMLOutputStream& stream)</code>: This method should
 * write out any additional XML namespaces that might be needed by a package
 * implementation.
 *
 *
 * @subsubsection sdp-methods-hooks 2.7 Implement additional methods as needed
 *
 * Extended SBMLDocumentPlugin implementations can add whatever additional
 * utility methods are useful for their implementation.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmlextensionexception
 *
 * @par
 * Certain situations can result in an exception being thrown by libSBML
 * package extensions.  A prominent example involves the constructor for
 * SBMLNamespaces (and its subclasses), which will throw
 * SBMLExtensionException if the arguments it is given refer to an unknown
 * SBML Level&nbsp;3 package.  The situation can arise for legitimate SBML
 * files if the necessary package extension has not been registered with
 * a given copy of libSBML.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmlextensionnamespaces
 *
 * @par
 * Each package extension in libSBML needs to extend and instantiate the
 * template class SBMLExtensionNamespaces, as well as declare a specific
 * <code>typedef</code>.  The following sections explain these steps in detail.
 *
 *
 * @subsection sen-identify 1. Define the typedef
 *
 * Each package needs to declare a package-specific version of the
 * SBMLExtensionNamespaces class using a <code>typedef</code>.  The following
 * example code demonstrates how this is done in the case of the Layout package:
 *
 * @code{.cpp}
 * typedef SBMLExtensionNamespaces<LayoutExtension> LayoutPkgNamespaces;
 * @endcode
 *
 * This creates a new type called LayoutPkgNamespaces.  The code above is
 * usually placed in the same file that contains the SBMLExtension-derived
 * definition of the package extension base class.  In the case of the Layout
 * package, this is in the file
 * <code>src/packages/layout/extension/LayoutExtension.h</code> in the libSBML
 * source distribution.
 *
 *
 * @subsection sen-instantiate 2. Instantiate a template instance
 *
 * Each package needs to instantiate a template instance of the
 * SBMLExtensionNamespaces class.  The following
 * example code demonstrates how this is done in the case of the Layout package:
 *
 * @code{.cpp}
 * template class LIBSBML_EXTERN SBMLExtensionNamespaces<LayoutExtension>;
 * @endcode
 *
 * In the case of the Layout package, the code above is located in the file
 * <code>src/packages/layout/extension/LayoutExtension.cpp</code> in the libSBML
 * source distribution.
 *
 *
 * @subsection sen-derive 3. Create constructors that accept the class
 *
 * Each SBase-derived class in the package extension should implement a
 * constructor that accepts the SBMLExtensionNamespaces-derived class as an
 * argument.  For example, in the Layout package, the class BoundBox has a
 * constructor declared as follows
 *
 * @code{.cpp}
 * BoundingBox(LayoutPkgNamespaces* layoutns);
 * @endcode
 *
 * The implementation of this constructor must, among other things, take the
 * argument namespace object and use it to set the XML namespace URI for the
 * object.  Again, for the BoundingBox example:
 *
 * @code{.cpp}
 * BoundingBox::BoundingBox(LayoutPkgNamespaces* layoutns)
 *  : SBase(layoutns)
 *   ,mPosition(layoutns)
 *   ,mDimensions(layoutns)
 *   ,mPositionExplicitlySet (false)
 *   ,mDimensionsExplicitlySet (false)
 * {
 *   // Standard extension actions.
 *   setElementNamespace(layoutns->getURI());
 *   connectToChild();
 *
 *   // Package-specific actions.
 *   mPosition.setElementName("position");
 *
 *   // Load package extensions bound with this object (if any).
 *   loadPlugins(layoutns);
 * }
 * @endcode
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmlextensionregister
 *
 * @par
 * When a package extension is first loaded, it must register itself with
 * the registry of extensions maintained by the cleverly-named
 * SBMLExtensionRegistry class.  That registry is how other classes in
 * libSBML access information about the packages recognized by a particular
 * copy of libSML; a corollary is that libSBML can't parse or even
 * recognize SBML Level&nbsp;3 packages that have no corresponding
 * extension registered with SBMLExtensionRegistry.
 *
 * The SBMLExtensionRegister class is a template class for automatically
 * registering each package extension to the SBMLExtensionRegistry class at
 * startup time.  The class and its use are very simple.  An implementation
 * of a package extension merely needs to use it to instantiate one object.
 * The class used in the template invocation should be the extension
 * derived from SBMLExtension (e.g., LayoutExtension for the %Layout
 * package).  The following is an example:
 *
 * @code{.cpp}
 * static SBMLExtensionRegister<LayoutExtension> layoutExtensionRegistry;
 * @endcode
 *
 * The line above is typically be placed in the <code>.cpp</code> file
 * associated with the definition of the SBMLExtension-derived class; in
 * the case of the %Layout package, this is <code>LayoutExtension.cpp</code>.
 *
 * The result of doing the above is that the <code>init()</code> method on
 * <code>LayoutExtension</code> will be automatically invoked when the
 * "register" object is instantiated.  This results in initialization and
 * registration of the package extension with libSBML.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbmlextensionregistry
 *
 * @par
 * The package extension registry is implemented as a singleton instance of
 * SBMLExtensionRegistry.  The class provides only utility functionality;
 * implementations of SBML packages do not need to implement any subclasses or
 * methods of this class.  SBMLExtensionRegistry is useful for its facilities
 * to query the known packages, and to enable or disable packages selectively.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbaseextensionpoint
 *
 * @par
 * This class is used as part of the mechanism that connects plugin objects
 * (implemented using SBasePlugin or SBMLDocumentPlugin) to a given package
 * extension.  For instance, an implementation of an extended version of
 * Model (e.g., LayoutModelPlugin in the %Layout package) would involve the
 * creation of an extension point using SBaseExtensionPoint and a mediator
 * object created using SBasePluginCreator, to "plug" the extended Model
 * object (LayoutModelPlugin) into the overall LayoutExtension object.
 *
 * The use of SBaseExtensionPoint is relatively straightforward.  The
 * class needs to be used for each extended SBML object implemented using
 * SBMLDocumentPlugin or SBasePlugin.  Doing so requires knowing just two
 * things:
 *
 * @li The short-form name of the @em parent package being extended.  The
 * parent package is often simply core SBML, identified in libSBML by the
 * nickname <code>"core"</code>, but a SBML Level&nbsp;3 package could
 * conceivably extend another Level&nbsp;3 package.
 *
 * @li The libSBML type code assigned to the object being extended.  For
 * example, if an extension of Model is implemented, the relevant type code
 * is SBMLTypeCode_t#SBML_MODEL, found in #SBMLTypeCode_t.
 *
 * The typical use of SBaseExtensionPoint is illustrated by the following
 * code fragment:
 *
 * @code{.cpp}
 * SBaseExtensionPoint docExtPoint("core", SBML_DOCUMENT);
 * SBaseExtensionPoint modelExtPoint("core", SBML_MODEL);
 *
 * SBasePluginCreator<GroupsSBMLDocumentPlugin, GroupsExtension> docPluginCreator(docExtPoint, pkgURIs);
 * SBasePluginCreator<GroupsModelPlugin, GroupsExtension> modelPluginCreator(modelExtPoint, pkgURIs);
 * @endcode
 *
 * The code above shows two core SBML components being extended: the
 * document object, and the Model object.  These extended objects are
 * created elsewhere (not shown) as the
 * <code>GroupsSBMLDocumentPlugin</code> and <code>GroupsModelPlugin</code>
 * objects.  The corresponding SBaseExtensionPoint objects are handed as
 * arguments to the constructor for SBasePluginCreator to create the
 * connection between the extended core components and the overall package
 * extension (here, for the Groups package, with the
 * <code>GroupsExtension</code> object).
 *
 * The code above is typically placed in the implementation of the
 * <code>init()</code> method of the package class derived from
 * SBMLExtension.  (For the example above, it would be in the
 * <code>GroupsExtension.cpp</code> file.)
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_sbaseplugincreator
 *
 * @par
 * This is a template class that constitutes another piece of glue used to
 * connect package extension objects to the overall package support
 * framework in libSBML.  This particular template class is used to create
 * factory objects that in turn construct new instances of package plugin
 * objects when necessary.  These factories are invoked when, for example,
 * libSBML encounters an SBML Level&nbsp;3 package in an SBML document and
 * needs to activate the corresponding libSBML package extension.
 *
 * The use of SBasePluginCreator is a simple matter of invoking it on every
 * object derived from SBasePlugin or SBMLDocumentPlugin (which is itself
 * derived from SBasePlugin).  The typical use is illustrated by the
 * following code fragment:
 *
 * @code{.cpp}
 * SBaseExtensionPoint docExtPoint("core", SBML_DOCUMENT);
 * SBaseExtensionPoint modelExtPoint("core", SBML_MODEL);
 *
 * SBasePluginCreator<GroupsSBMLDocumentPlugin, GroupsExtension> docPluginCreator(docExtPoint, pkgURIs);
 * SBasePluginCreator<GroupsModelPlugin, GroupsExtension> modelPluginCreator(modelExtPoint, pkgURIs);
 * @endcode
 *
 * The code above is typically placed in the implementation of the
 * <code>init()</code> method of the package class derived from
 * SBMLExtension.  (For the example above, it would be in the
 * <code>GroupsExtension.cpp</code> file.)
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_extension_layout_plugin_is_special
 *
 * @par
 * Due to the historical background of the SBML %Layout package, libSBML
 * implements special behavior for that package: it @em always creates a
 * %Layout plugin object for any SBML Level&nbsp;2 document it reads in,
 * regardless of whether that document actually uses %Layout constructs.  This
 * is unlike the case for SBML Level&nbsp;3 documents that use %Layout; for
 * them, libSBML will @em not create a plugin object unless the document
 * actually declares the use of the %Layout package (via the usual Level&nbsp;3
 * namespace declaration for Level&nbsp;3 packages).
 *
 * This has the following consequence.  If an application queries for the
 * presence of %Layout in an SBML Level&nbsp;2 document by testing only for
 * the existence of the plugin object, <strong>it will always get a positive
 * result</strong>; in other words, the presence of a %Layout extension
 * object is not an indication of whether a read-in Level&nbsp;2 document
 * does or does not use SBML %Layout.  Instead, callers have to query
 * explicitly for the existence of layout information.  An example of such a
 * query is the following code:
 * @if cpp
@code{.cpp}
// Assume "m" below is a Model object.
LayoutModelPlugin* lmp = static_cast<LayoutModelPlugin*>(m->getPlugin("layout"));
if (lmp != NULL)
{
  unsigned int numLayouts = lmp->getNumLayouts();
  // If numLayouts is greater than zero, then the model uses Layout.
}
@endcode
@endif
@if python
@code{.py}
# Assume "doc" below is an SBMLDocument object.
m = doc.getModel()
if m != None:
    layoutPlugin = m.getPlugin('layout')
    if layoutPlugin != None:
        numLayouts = layoutPlugin.getNumLayouts()
        # If numLayouts is greater than zero, then the model uses Layout.
@endcode
@endif
@if java
@code{.java}
// Assume "doc" below is an SBMLDocument object.
Model m = doc.getModel();
LayoutModelPlugin lmp = (LayoutModelPlugin) m.getPlugin("layout");
if (lmp != null)
{
  int numLayouts = lmp.getNumLayouts();
  // If numLayouts is greater than zero, then the model uses Layout.
}
@endcode
@endif
@if csharp
@code{.cs}
// Assume "doc" below is an SBMLDocument object.
Model m = doc.getModel();
LayoutModelPlugin lmp = (LayoutModelPlugin) m.getPlugin("layout");
if (lmp != null)
{
  int numLayouts = lmp.getNumLayouts();
  // If numLayouts is greater than zero, then the model uses Layout.
}
@endcode
@endif
 *
 * The special, always-available Level&nbsp;2 %Layout behavior was motivated
 * by a desire to support legacy applications.  In SBML Level&nbsp;3, the
 * %Layout package uses the normal SBML Level&nbsp;3 scheme of requiring
 * declarations on the SBML document element.  This means that upon reading a
 * model, libSBML knows right away whether it contains layout information.
 * In SBML Level&nbsp;2, there is no top-level declaration because layout is
 * stored as annotations in the body of the model.  Detecting the presence of
 * layout information when reading a Level&nbsp;2 model requires parsing the
 * annotations.  For efficiency reasons, libSBML normally does not parse
 * annotations automatically when reading a model.  However, applications
 * that predated the introduction of Level&nbsp;3 %Layout and the updated
 * version of libSBML never had to do anything special to enable parsing
 * layout; the facilities were always available for every Level&nbsp;2 model
 * as long as libSBML was compiled with %Layout support.  To avoid burdening
 * developers of legacy applications with the need to modify their software,
 * libSBML provides backward compatibility by always preloading the %Layout
 * package extension when reading Level&nbsp;2 models.  The same applies to
 * the creation of Level&nbsp;2 models: with the plugin-oriented libSBML,
 * applications normally would have to take deliberate steps to activate
 * package code, instantiate objects, manage namespaces, and so on.  LibSBML
 * again loads the %Layout package plugin automatically when creating a
 * Level&nbsp;2 model, thereby making the APIs available to legacy
 * applications without further work on their part.
 *
 * @if clike
 * The mechanisms for triggering this Level&nbsp;2-specific behavior
 * involves a set of virtual methods on the SBMLExtension class that must
 * be implemented by individual package extensions.  These methods are
 * SBMLExtension::addL2Namespaces(),
 * SBMLExtension::removeL2Namespaces(), and
 * SBMLExtension::enableL2NamespaceForDocument().
 * @endif
 */
