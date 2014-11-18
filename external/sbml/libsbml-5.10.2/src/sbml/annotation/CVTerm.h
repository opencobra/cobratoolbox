/**
 * @file    CVTerm.h
 * @brief   Definition of a CVTerm class for adding annotations to a Model.
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
 * ------------------------------------------------------------------------ -->
 *
 * @class CVTerm
 * @sbmlbrief{core} A MIRIAM-compliant controlled vocabulary term.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * The SBML Level&nbsp;2 and Level&nbsp;3 specifications define a simple
 * format for annotating models when (a) referring to controlled vocabulary
 * terms and database identifiers that define and describe biological and
 * biochemical entities, and (b) describing the creator of a model and the
 * model's modification history.  This SBML format is a concrete syntax that
 * conforms to the guidelines of MIRIAM (<a target="_blank"
 * href="http://www.nature.com/nbt/journal/v23/n12/abs/nbt1156.html">"Minimum
 * Information Requested in the Annotation of biochemical Models"</a>,
 * <i>Nature Biotechnology</i>, vol. 23, no. 12, Dec. 2005).  The format uses
 * a subset of W3C RDF (<a target="_blank"
 * href="http://www.w3.org/RDF/">Resource Description Format</a>).  In order
 * to help application developers work with annotations in this format,
 * libSBML provides several helper classes that provide higher-level
 * interfaces to the data elements; these classes include CVTerm,
 * ModelCreator, ModelHistory, RDFAnnotationParser, and Date.
 *
 * @section annotation-parts Components of an SBML annotation
 *
 * The SBML annotation format consists of RDF-based content placed inside
 * an <code>&lt;annotation&gt;</code> element attached to an SBML component
 * such as Species, Compartment, etc.  The following template illustrates
 * the different parts of SBML annotations in XML form:
 * 
 <pre class="fragment">
 &lt;<span style="background-color: #bbb">SBML_ELEMENT</span> <span style="background-color: #d0eed0">+++</span> metaid=&quot;<span style="border-bottom: 1px solid black">meta id</span>&quot; <span style="background-color: #d0eed0">+++</span>&gt;
   <span style="background-color: #d0eed0">+++</span>
   &lt;annotation&gt;
     <span style="background-color: #d0eed0">+++</span>
     &lt;rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:dcterm="http://purl.org/dc/terms/"
              xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#"
              xmlns:bqbiol="http://biomodels.net/biology-qualifiers/"
              xmlns:bqmodel="http://biomodels.net/model-qualifiers/" &gt;
       &lt;rdf:Description rdf:about=&quot;#<span style="border-bottom: 1px solid black">meta id</span>&quot;&gt;
         <span style="background-color: #e0e0e0; border-bottom: 2px dotted #888">HISTORY</span>
         &lt;<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
           &lt;rdf:Bag&gt;
             &lt;rdf:li rdf:resource=&quot;<span style="background-color: #d0d0ee">URI</span>&quot; /&gt;
             <span style="background-color: #edd">...</span>
           &lt;/rdf:Bag&gt;
         &lt;/<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
         <span style="background-color: #edd">...</span>
       &lt;/rdf:Description&gt;
       <span style="background-color: #d0eed0">+++</span>
     &lt;/rdf:RDF&gt;
     <span style="background-color: #d0eed0">+++</span>
   &lt;/annotation&gt;
   <span style="background-color: #d0eed0">+++</span>
 &lt;/<span style="background-color: #bbb">SBML_ELEMENT</span>&gt;
 </pre>
 * 
 * In the template above, the placeholder
 * <span class="code" style="background-color: #bbb">SBML_ELEMENT</span> stands for
 * the XML tag name of an SBML model component (e.g., <code>model</code>,
 * <code>reaction</code>, etc.) and the placeholder 
 * <span class="code" style="border-bottom: 1px solid black">meta id</span>
 * stands for the element's meta identifier, which is a field available
 * on all SBML components derived from the SBase base object class.
 * The <span style="border-bottom: 2px dotted #888">dotted</span>
 * portions are optional, the symbol
 * <span class="code" style="background-color: #d0eed0">+++</span> is a placeholder
 * for either no content or valid XML content that is not defined by
 * this annotation scheme, and the ellipses
 * <span class="code" style="background-color: #edd">...</span>
 * are placeholders for zero or more elements of the same form as the
 * immediately preceding element.  The optional content
 * <span class="code" style="background-color: #e0e0e0; border-bottom: 2px dotted #888">HISTORY</span>
 * is a creation and modification history; in libSBML, this is stored
 * using ModelHistory objects.
 *
 * The placeholder <span class="code" style="background-color:
 * #bbb">RELATION_ELEMENT</span> refers to a BioModels.net qualifier element
 * name.  This is an element in either the XML namespace
 * <code>"http://biomodels.net/model-qualifiers"</code> (for model
 * qualifiers) or <code>"http://biomodels.net/biology-qualifiers"</code> (for
 * biological qualifier).  Note that these namespace URIs are only labels,
 * and not actual Web locations, which means you cannot visit an address such
 * as <code>"http://biomodels.net/model-qualifiers"</code> in your browser or
 * try to have your application access it.  @if Refer instead to the enumerations
 * #ModelQualifierType_t and #BiolQualifierType_t for a list of the available
 * relationship elements that can be used for <span class="code"
 * style="background-color: #bbb">RELATION_ELEMENT</span>.@endif@~
 *
 * The <span class="code" style="background-color: #d0d0ee">URI</span> is a
 * required data value that uniquely identifies a resource and data within
 * that resource to which the annotation refers.  Again, being URIs, these do
 * not refer to physical Web locations; nevertheless, applications will often
 * want a means of finding the resource to which a given <span class="code"
 * style="background-color: #d0d0ee">URI</span> refers.  Providing the
 * facilities for this task is the purpose of MIRIAM Resources, described in
 * detail online at <a target="_blank"
 * href="http://biomodels.net/miriam">http://biomodels.net/miriam</a>) and
 * also in the paper <a target="_blank"
 * href="http://www.biomedcentral.com/1752-0509/1/58">"MIRIAM Resources: tools to generate and
 * resolve robust cross-references in Systems Biology"</a>, <i>BMC Systems
 * Biology</i>, 58(1), 2007.
 *
 * The relation-resource pairs above are the "controlled vocabulary" terms
 * that which CVTerm is designed to store and manipulate.  The next section
 * describes these parts in more detail.  For more information about
 * SBML annotations in general, please refer to Section&nbsp;6 in the
 * SBML Level&nbsp;2 (Versions 2&ndash;4) or Level&nbsp;3 specification
 * documents.
 * 
 *
 * @section cvterm-parts The parts of a CVTerm
 * 
 * Annotations that refer to controlled vocabularies are managed in libSBML
 * using CVTerm objects.  A set of RDF-based annotations attached to a
 * given SBML <code>&lt;annotation&gt;</code> element are read by
 * RDFAnnotationParser and converted into a list of these CVTerm objects.
 * Each CVTerm object instance stores the following components of an
 * annotation:
 * 
 * <ul>
 *
 * <li>The @em qualifier, which can be a BioModels.net "biological
 * qualifier", a BioModels.net "model qualifier", or an unknown qualifier
 * (as far as the CVTerm class is concerned).  Qualifiers are used in
 * MIRIAM to indicate the nature of the relationship between the object
 * being annotated and the resource.  In CVTerm, the qualifiers can be
 * manipulated using the methods CVTerm::getQualifierType(),
 * CVTerm::setQualifierType(@if java int@endif), and related methods.
 * 
 * <li>The @em resource, represented by a URI (which, we must remind
 * developers, is not the same as a URL).  In the CVTerm class, the
 * resource component can be manipulated using the methods
 * CVTerm::addResource(@if java String@endif) and
 * CVTerm::removeResource(@if java String@endif).
 *
 * </ul>
 *
 * Note that a CVTerm contains a single qualifier, but possibly more than
 * one resource.  This corresponds to the possibility of an annotation that
 * points to multiple resources, all of which are qualified by the same
 * BioModels.net qualifier.  The CVTerm object class supports this by
 * supporting a list of resources.
 *
 * Detailed explanations of the qualifiers defined by BioModels.net can be
 * found at <a target="_blank"
 * href="http://biomodels.net/qualifiers">http://biomodels.net/qualifiers</a>.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_cvterm_common_description
 *
 * @par
 * The RDF element used in the SBML format for referring to external entities
 * is <code>&lt;rdf:Description&gt;</code>, with a
 * <code>&lt;rdf:Bag&gt;</code> element inside of it containing one or more
 * <code>&lt;rdf:li&gt;</code> elements.  The following template illustrates
 * the structure:
 * <pre class="fragment">
 * &lt;rdf:Description rdf:about=&quot;#<span style="border-bottom: 1px solid black">meta id</span>&quot;&gt;
 * &nbsp;&nbsp;<span style="background-color: #ddd; border-bottom: 2px dotted #888">HISTORY</span>
 * &nbsp;&nbsp;&lt;<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;rdf:Bag&gt;
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;rdf:li rdf:resource=&quot;<span style="background-color: #d0d0ee">resource URI</span>&quot; /&gt;
 * &nbsp;&nbsp;&nbsp;&nbsp;<span style="background-color: #edd">...</span>
 * &nbsp;&nbsp;&nbsp;&nbsp;&lt;/rdf:Bag&gt;
 * &nbsp;&nbsp;&lt;/<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
 * &nbsp;&nbsp;<span style="background-color: #edd">...</span>
 * &lt;/rdf:Description&gt;
 * </pre>
 * In the template above, the placeholder <span class="code"
 * style="border-bottom: 1px solid black">meta id</span> stands for the
 * element's meta identifier, which is a field available on all SBML
 * components derived from the SBase base object class.  The <span
 * style="border-bottom: 2px dotted #888">dotted</span> portions are
 * optional, and the ellipses <span class="code" style="background-color:
 * #edd">...</span> are placeholders for zero or more elements of the same
 * form as the immediately preceding element.
 * 
 */

#ifndef CVTerm_h
#define CVTerm_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>

#include <sbml/xml/XMLAttributes.h>

LIBSBML_CPP_NAMESPACE_BEGIN


/**
 * @enum QualifierType_t
 *
 * Enumeration used to indicate the type of <a target="_blank"
 * href="http://biomodels.net/qualifiers/">BioModels.net</a> in a given
 * CVTerm object.  The qualification of an annotation is important to convey
 * the relationship between a given model component and the resource used to
 * annotate it. This relationship is rarely one-to-one, and the information
 * content of an annotation is greatly increased if one knows what it
 * represents (as opposed to knowing only that the two "are related").
 *
 * In the SBML/MIRIAM/BioModels.net scheme of things, there are currently two
 * kinds of qualifiers.  They are used for different purposes.  One purpose
 * is in the refinement of the relationship between an annotation resource
 * and the <em>modeling concept</em> represented by a model element.  The
 * second purpose is in the refinement of the relationship between an
 * annotation resource and the <em>biological object</em> represented by a
 * model element.  In libSBML, each of these two categories of qualifiers
 * have their own enumerations: #ModelQualifierType_t for the former type, and
 * #BiolQualifierType_t for the latter.
 *
 * One can view the annotation of a model component as a statement in the
 * form of a @em triple. The resource used in the annotation is the @em
 * object, while the qualifier is the @em predicate.  In situations where a
 * model qualifier is used, the @em subject of the relation is the modeling
 * concept represented by the model component referenced by the annotation.
 * The modeling concept may be the model itself, a mathematical construct,
 * or a hypothesis that is proposed, changing the way we previously
 * understood the model, etc.  Conversely, in situations where a biology
 * qualifier is used, the @em subject of the relation is the biological or
 * biochemical object represented by the enclosing model element.
 */
typedef enum
{
    MODEL_QUALIFIER       /*!< The qualifier is a model qualifier. */
  , BIOLOGICAL_QUALIFIER  /*!< The qualifier is a biological qualifier. */
  , UNKNOWN_QUALIFIER     /*!< The qualifier has not been set or is unknown. */
} QualifierType_t;


/**
 * @enum ModelQualifierType_t
 *
 * Enumeration of possible <em>model qualifiers</em> used for annotations.
 * Annotations with this type of qualifier express a relationship between an
 * annotation resource and the <em>modeling concept</em> represented by a
 * given object in the model.  The diagram below illustrates the relationship
 * in this case:
 *
 * @image html model-qualifiers.png "Relationship expressed by model qualifiers"
 * @image latex model-qualifiers.png "Relationship expressed by model qualifiers"
 * <br>
 */
typedef enum
{
    BQM_IS
    /*!< The modeling entity represented by the object in the model is
     * identical to the subject of the referenced resource. */

  , BQM_IS_DESCRIBED_BY
    /*!< The modeling entity represented by the object in the model is
     * described by the subject of the referenced resource.  For example,
     * this relationship could be used to link a model element to a
     * document (such as a paper published in the literature) describing
     * the element. */

  , BQM_IS_DERIVED_FROM
    /*!< The modeling entity represented by the object in the model is
     * derived from or adapted from the referenced resource.  This relation
     * could be used, for instance, to express a refinement or adaptation in
     * usage of a model component located elsewere. */
  , BQM_UNKNOWN
    /*!< The relationship is unknown. */

} ModelQualifierType_t;


/**
 * @enum BiolQualifierType_t
 *
 * Enumeration of possible <em>biological qualifiers</em> used for
 * annotations.  Annotations with this type of qualifier express a
 * relationship between an annotation resource and the <em>biological
 * concept</em> represented by a given object in the model.  The diagram
 * below illustrates the relationship in this case:
 *
 * @image html biology-qualifiers.png "Relationship expressed by biological qualifiers"
 * @image latex biology-qualifiers.png "Relationship expressed by biological qualifiers"
 * <br>
 */
typedef enum
{
    BQB_IS
    /*!< The biological entity represented by the object in the model is
     * identical to the subject of the referenced resource. */

  , BQB_HAS_PART
    /*!< The biological entity represented by the object in the model 
     * includes the subject of the referenced resource. */

  , BQB_IS_PART_OF
    /*!< The biological entity represented by the object in the model is a
     * physical or logical part of the subject of the referenced resource.
     * For example, this could be used to indicate that the molecular entity
     * represented by a given object in the model is part of the referenced
     * molecular complex. */

  , BQB_IS_VERSION_OF
    /*!< The biological entity represented by the object in the model is a
     * version or an instance of the subject of the referenced resource. */

  , BQB_HAS_VERSION
    /*!< The subject of the referenced resource is a version or an instance
     * of the biological entity represented by the model element. */

  , BQB_IS_HOMOLOG_TO
    /*!< The biological entity represented by the object in the model is
     * homologous to the subject of the referenced resource. */

  , BQB_IS_DESCRIBED_BY
    /*!< The biological entity represented by the object in the model is
     * described by the subject of the referenced resource.  This could be
     * used, for example, to link a species or a parameter to the literature
     * that describes the concentration of that species or the value of that
     * parameter. */

  , BQB_IS_ENCODED_BY
    /*!< The biological entity represented by the object in the model is
     * encoded, directly or transitively, by the subject of the referenced
     * resource. */

  , BQB_ENCODES
    /*!< The biological entity represented by the object in the model encodes
     * directly or transitively the subject of the referenced resource. */

  , BQB_OCCURS_IN
    /*!< The biological entity represented by the object in the model is
     * physically limited to a location.  The location is the subject of the
     * referenced resource. */

  , BQB_HAS_PROPERTY
    /*!< The subject of the referenced resource is a property of the
     * biological entity represented by the model element. */

  , BQB_IS_PROPERTY_OF
    /*!< The biological entity represented by the object in the model is
     * a property of the referenced resource. */

  , BQB_UNKNOWN
    /*!< The relationship is unknown. */

} BiolQualifierType_t;

LIBSBML_CPP_NAMESPACE_END

#ifdef __cplusplus


#include <limits>
#include <iomanip>
#include <string>
#include <sstream>

#include <cstdlib>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN CVTerm
{
public:

  /**
   * Creates an empty CVTerm, optionally with the given
   * @if clike #QualifierType_t value@else qualifier@endif@~ @p type.
   *
   * @copydetails doc_what_are_cvterms 
   *
   * This method creates an empty CVTerm object.  The possible qualifier
   * types usable as values of @p type are @sbmlconstant{MODEL_QUALIFIER, QualifierType_t} and @sbmlconstant{BIOLOGICAL_QUALIFIER, QualifierType_t}.  If
   * an explicit value for @p type is not given, this method defaults to
   * using @sbmlconstant{UNKNOWN_QUALIFIER, QualifierType_t}.  The @if clike #QualifierType_t value@else qualifier type@endif@~ 
   * can be set later using the
   * CVTerm::setQualifierType(@if java int@endif) method.
   *
   * Different BioModels.net qualifier elements encode different types of
   * relationships.  Please refer to the SBML specification or the <a
   * target="_blank" href="http://biomodels.net/qualifiers/">BioModels.net
   * qualifiers web page</a> for an explanation of the meaning of these
   * different qualifiers.
   *
   * @param type a @if clike #QualifierType_t value@else qualifier type@endif@~
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  CVTerm(QualifierType_t type = UNKNOWN_QUALIFIER);


  /**
   * Creates a new CVTerm from the given XMLNode.
   *
   * @copydetails doc_what_are_cvterms 
   * 
   * This method creates a CVTerm object from the given XMLNode object @p
   * node.  XMLNode is libSBML's representation of a node in an XML tree of
   * elements, and each such element can be placed in a namespace.  This
   * constructor looks for the element to be in the XML namespaces
   * <code>"http://biomodels.net/model-qualifiers"</code> (for
   * model qualifiers) and
   * <code>"http://biomodels.net/biology-qualifiers"</code> (for
   * biological qualifier), and if they are, creates CVTerm objects for
   * the result.
   *
   * @param node an %XMLNode representing a CVTerm.
   *
   * @note This method assumes that the given XMLNode object @p node is of
   * the correct structural form.
   */
  CVTerm(const XMLNode node);


  /**
   * Destroys this CVTerm.
   */
  ~CVTerm();


  /**
   * Copy constructor; creates a copy of a CVTerm object.
   * 
   * @param orig the CVTerm instance to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  CVTerm(const CVTerm& orig);


  /**
   * Assignment operator for CVTerm.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  CVTerm& operator=(const CVTerm& rhs);


  /**
   * Creates and returns a deep copy of this CVTerm object.
   *
   * @return the (deep) copy of this CVTerm object.
   */  
  CVTerm* clone() const; 


  /**
   * Returns the qualifier type of this CVTerm object.
   *
   * @copydetails doc_cvterm_common_description
   *
   * The placeholder <span class="code" style="background-color: #bbb">
   * RELATION_ELEMENT</span> refers to a BioModels.net qualifier
   * element name.  This is an element in either the XML namespace
   * <code>"http://biomodels.net/model-qualifiers"</code> (for model
   * qualifiers) or <code>"http://biomodels.net/biology-qualifiers"</code>
   * (for biological qualifier).  The present method returns a code
   * identifying which one of these two relationship namespaces is being
   * used; any other qualifier in libSBML is considered unknown (as far as
   * the CVTerm class is concerned).  Consequently, this method will return
   * one of the following values:
   * 
   * @li @sbmlconstant{MODEL_QUALIFIER, QualifierType_t}
   * @li @sbmlconstant{BIOLOGICAL_QUALIFIER, QualifierType_t}
   * @li @sbmlconstant{UNKNOWN_QUALIFIER, QualifierType_t}
   *
   * The specific relationship of this CVTerm to the enclosing SBML object
   * can be determined using the CVTerm methods such as
   * getModelQualifierType() and getBiologicalQualifierType().  Callers
   * will typically want to use the present method to find out which one of
   * the @em other two methods to call to find out the specific
   * relationship.
   *
   * @return the @if clike #QualifierType_t value@else qualifier type@endif@~
   * of this object or @sbmlconstant{UNKNOWN_QUALIFIER, QualifierType_t}
   * (the default).
   *
   * @see getResources()
   * @see getModelQualifierType()
   * @see getBiologicalQualifierType()
   */
  QualifierType_t getQualifierType();


  /**
   * Returns the model qualifier type of this CVTerm object.
   * 
   * @copydetails doc_cvterm_common_description
   *
   * The placeholder <span class="code" style="background-color: #bbb">
   * RELATION_ELEMENT</span> refers to a BioModels.net qualifier
   * element name.  This is an element in either the XML namespace
   * <code>"http://biomodels.net/model-qualifiers"</code> (for model
   * qualifiers) or <code>"http://biomodels.net/biology-qualifiers"</code>
   * (for biological qualifier).  Callers will typically use
   * getQualifierType() to find out the type of qualifier relevant to this
   * particular CVTerm object, then if it is a @em model qualifier, use the
   * present method to determine the specific qualifier.
   *
   * Annotations with model qualifiers express a relationship between an
   * annotation resource and the <em>modeling concept</em> represented by a
   * given object in the model.  The diagram below illustrates the
   * relationship in this case:
   *
   * @image html model-qualifiers.png "Relationship expressed by model qualifiers"
   * @image latex model-qualifiers.png "Relationship expressed by model qualifiers"
   *
   * <br> The set of known model qualifiers is, at the time of this libSBML
   * release, the following:
   *
   * @li @sbmlconstant{BQM_IS, ModelQualifierType_t}
   * @li @sbmlconstant{BQM_IS_DESCRIBED_BY, ModelQualifierType_t}
   * @li @sbmlconstant{BQM_IS_DERIVED_FROM, ModelQualifierType_t}
   *
   * Any other BioModels.net qualifier found in the model is considered
   * unknown by libSBML and reported as
   * @sbmlconstant{BQM_UNKNOWN, ModelQualifierType_t}.
   *
   * @return the @if clike #ModelQualifierType_t value@else model qualifier type@endif@~
   * of this object or @sbmlconstant{BQM_UNKNOWN, ModelQualifierType_t}
   * (the default).
   */
  ModelQualifierType_t getModelQualifierType();


  /**
   * Returns the biological qualifier type of this CVTerm object.
   * 
   * @copydetails doc_cvterm_common_description
   *
   * The placeholder <span class="code" style="background-color: #bbb">
   * RELATION_ELEMENT</span> refers to a BioModels.net qualifier
   * element name.  This is an element in either the XML namespace
   * <code>"http://biomodels.net/model-qualifiers"</code> (for model
   * qualifiers) or <code>"http://biomodels.net/biology-qualifiers"</code>
   * (for biological qualifier).  Callers will typically use
   * getQualifierType() to find out the type of qualifier relevant to this
   * particular CVTerm object, then if it is a @em biological qualifier,
   * use the present method to determine the specific qualifier.
   *
   * Annotations with biological qualifiers express a relationship between an
   * annotation resource and the <em>biological concept</em> represented by a
   * given object in the model.    The diagram
   * below illustrates the relationship in this case:
   *
   * @image html biology-qualifiers.png "Relationship expressed by biological qualifiers"
   * @image latex biology-qualifiers.png "Relationship expressed by biological qualifiers"
   *
   * <br> The set of known biological qualifiers is, at the time of this
   * libSBML release, the following:
   *
   * @li @sbmlconstant{BQB_IS, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_HAS_PART, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_PART_OF, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_VERSION_OF, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_HAS_VERSION, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_HOMOLOG_TO, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_DESCRIBED_BY, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_ENCODED_BY, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_ENCODES, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_OCCURS_IN, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_HAS_PROPERTY, BiolQualifierType_t}
   * @li @sbmlconstant{BQB_IS_PROPERTY_OF, BiolQualifierType_t}
   *
   * Any other BioModels.net qualifier found in the model is considered
   * unknown by libSBML and reported as
   * @sbmlconstant{BQB_UNKNOWN, BiolQualifierType_t}.
   *
   * @return the @if clike #BiolQualifierType_t value@else biology qualifier type@endif@~
   * of this object or @sbmlconstant{BQB_UNKNOWN, BiolQualifierType_t}
   * (the default).
   */
  BiolQualifierType_t getBiologicalQualifierType();


  /**
   * Returns the resource references for this CVTerm object.
   *
   * @copydetails doc_cvterm_common_description
   *
   * The <span class="code" style="background-color: #d0d0ee">resource
   * URI</span> values shown in the template above are stored internally in
   * CVTerm objects using an XMLAttributes object.  Each attribute stored
   * inside the XMLAttributes will have the same name (specifically,
   * &quot;<code>rdf:resource</code>&quot;) but a different value, and the
   * value will be a <span class="code" style="background-color: #d0d0ee">
   * resource URI</span> shown in the XML template above.
   *
   * A valid CVTerm entity must always have at least one resource and
   * a value for the relationship qualifier.
   * 
   * @return the XMLAttributes that store the resources of this CVTerm.
   *
   * @see getQualifierType()
   * @see addResource(const std::string& resource)
   * @see getResourceURI(unsigned int n)
   */
  XMLAttributes * getResources(); 

  
  /**
   * Returns the resources for this CVTerm object.
   * 
   * @copydetails doc_cvterm_common_description
   *
   * The <span class="code" style="background-color: #d0d0ee">resource
   * URI</span> values shown in the template above are stored internally in
   * CVTerm objects using an XMLAttributes object.  Each attribute stored
   * inside the XMLAttributes will have the same name (specifically,
   * &quot;<code>rdf:resource</code>&quot;) but a different value, and the
   * value will be a <span class="code" style="background-color: #d0d0ee">
   * resource URI</span> shown in the XML template above.
   *
   * A valid CVTerm entity must always have at least one resource and
   * a value for the relationship qualifier.
   * 
   * @return the XMLAttributes that store the resources of this CVTerm.
   *
   * @see getQualifierType()
   * @see addResource(const std::string& resource)
   * @see getResourceURI(unsigned int n)
   */
  const XMLAttributes * getResources() const; 

  
  /**
   * Returns the number of resources for this CVTerm object.
   * 
   * @copydetails doc_cvterm_common_description
   *
   * The fragment above illustrates that there can be more than one
   * resource referenced by a given relationship annotation (i.e., the
   * <span class="code" style="background-color: #d0d0ee">resource
   * URI</span> values associated with a particular <span class="code"
   * style="background-color: #bbb">RELATION_ELEMENT</span>).  The present
   * method returns a count of the resources stored in this CVTerm object.
   *
   * @return the number of resources in the set of XMLAttributes
   * of this CVTerm.
   *
   * @see getResources()
   * @see getResourceURI(unsigned int n)
   */
  unsigned int getNumResources(); 

  
  /**
   * Returns the value of the <em>n</em>th resource for this CVTerm object.
   *
   * @copydetails doc_cvterm_common_description
   *
   * The fragment above illustrates that there can be more than one
   * resource referenced by a given relationship annotation (i.e., the
   * <span class="code" style="background-color: #d0d0ee">resource
   * URI</span> values associated with a particular <span class="code"
   * style="background-color: #bbb">RELATION_ELEMENT</span>).  LibSBML
   * stores all resource URIs in a single CVTerm object for a given
   * relationship.  Callers can use getNumResources() to find out how many
   * resources are stored in this CVTerm object, then call this method to
   * retrieve the <em>n</em>th resource URI.
   * 
   * @param n the index of the resource to query
   *
   * @return string representing the value of the nth resource
   * in the set of XMLAttributes of this CVTerm.
   *
   * @see getNumResources()
   * @see getQualifierType()
   */
  std::string getResourceURI(unsigned int n); 

  
  /**
   * Sets the @if clike #QualifierType_t@else qualifier code@endif@~ of this
   * CVTerm object.
   *
   * @param type the @if clike #QualifierType_t value@else qualifier type@endif.
   * The possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see getQualifierType()
   */
  int setQualifierType(QualifierType_t type);


  /**
   * Sets the @if clike #ModelQualifierType_t value@else model qualifier type@endif@~
   * of this CVTerm object.
   *
   * @param type the @if clike #ModelQualifierType_t value@else model qualifier type@endif@~
   *
   * @return integer value indicating success/failure of the
   * function. The possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note If the Qualifier Type of this object is not
   * @sbmlconstant{MODEL_QUALIFIER, QualifierType_t}, 
   * then the ModelQualifierType_t value will default to
   * @sbmlconstant{BQM_UNKNOWN, QualifierType_t}.
   *
   * @see getQualifierType()
   * @see setQualifierType(@if java int@endif)
   */
  int setModelQualifierType(ModelQualifierType_t type);


  /**
   * Sets the @if clike #BiolQualifierType_t value@else biology qualifier type@endif@~
   * of this CVTerm object.
   *
   * @param type the @if clike #BiolQualifierType_t value@else biology qualifier type@endif.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note If the Qualifier Type of this object is not
   * @sbmlconstant{BIOLOGICAL_QUALIFIER, QualifierType_t},
   * then the @if clike #BiolQualifierType_t value@else biology qualifier type@endif@~ will default
   * to @sbmlconstant{BQB_UNKNOWN, BiolQualifierType_t}.
   *
   * @see getQualifierType()
   * @see setQualifierType(@if java int@endif)
   */
  int setBiologicalQualifierType(BiolQualifierType_t type);


  /**
   * Sets the @if clike #ModelQualifierType_t@endif@if java model qualifier type code@endif@~ value of this CVTerm object.
   *
   * @param qualifier the string representing a model qualifier
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note If the Qualifier Type of this object is not
   * @sbmlconstant{MODEL_QUALIFIER, QualifierType_t}, 
   * then the ModelQualifierType_t value will default to
   * @sbmlconstant{BQM_UNKNOWN, QualifierType_t}.
   *
   * @see getQualifierType()
   * @see setQualifierType(@if java int@endif)
   */
  int setModelQualifierType(const std::string& qualifier);


  /**
   * Sets the @if clike #BiolQualifierType_t@endif@if java biology qualifier
   * type code@endif@~ of this CVTerm object.
   *
   * @param qualifier the string representing a biology qualifier
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note If the Qualifier Type of this object is not
   * @sbmlconstant{BIOLOGICAL_QUALIFIER, QualifierType_t},
   * then the @if clike #BiolQualifierType_t@endif@if java biology qualifier type code@endif@~ value will default
   * to @sbmlconstant{BQB_UNKNOWN, BiolQualifierType_t}.
   *
   * @see getQualifierType()
   * @see setQualifierType(@if java int@endif)
   */
  int setBiologicalQualifierType(const std::string& qualifier);


  /**
   * Adds a resource reference to this CVTerm object.
   *
   * @copydetails doc_what_are_cvterms 
   *
   * The specific RDF element used in this SBML format for referring to
   * external entities is <code>&lt;rdf:Description&gt;</code>, with a
   * <code>&lt;rdf:Bag&gt;</code> element containing one or more
   * <code>&lt;rdf:li&gt;</code> elements.  Each such element refers to a
   * data item in an external resource; the resource and data item are
   * together identified uniquely using a URI.  The following template
   * illustrates the structure:
   *
   <pre class="fragment">
   &lt;rdf:Description rdf:about=&quot;#<span style="border-bottom: 1px solid black">meta id</span>&quot;&gt;
     <span style="background-color: #e0e0e0; border-bottom: 2px dotted #888">HISTORY</span>
     &lt;<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
       &lt;rdf:Bag&gt;
         &lt;rdf:li rdf:resource=&quot;<span style="background-color: #d0d0ee">resource URI</span>&quot; /&gt;
         <span style="background-color: #edd">...</span>
       &lt;/rdf:Bag&gt;
     &lt;/<span style="background-color: #bbb">RELATION_ELEMENT</span>&gt;
     <span style="background-color: #edd">...</span>
   &lt;/rdf:Description&gt;
   </pre>
   *
   * In the template above, the placeholder <span class="code"
   * style="border-bottom: 1px solid black">meta id</span> stands for the
   * element's meta identifier, which is a field available on all SBML
   * components derived from the SBase base object class.  The <span
   * style="border-bottom: 2px dotted #888">dotted</span> portions are
   * optional, and the ellipses <span class="code"
   * style="background-color: #edd">...</span> are placeholders for zero or
   * more elements of the same form as the immediately preceding element.
   * The placeholder <span class="code" style="background-color: #bbb">
   * RELATION_ELEMENT</span> refers to a BioModels.net qualifier element
   * name.  This is an element in either the XML namespace
   * <code>"http://biomodels.net/model-qualifiers"</code> (for model
   * qualifiers) or <code>"http://biomodels.net/biology-qualifiers"</code>
   * (for biological qualifier).
   *
   * The <span class="code" style="background-color: #d0d0ee">resource
   * URI</span> is a required data value that uniquely identifies a
   * resource and data within that resource to which the annotation refers.
   * The present method allows callers to add a reference to a resource URI
   * with the same relationship to the enclosing SBML object.  (In other
   * words, the argument to this method is a <span class="code"
   * style="background-color: #d0d0ee">resource URI</span> as shown in the
   * XML fragment above.)  Resources are stored in this CVTerm object
   * within an XMLAttributes object.
   * 
   * The relationship of this CVTerm to the enclosing SBML object can be
   * determined using the CVTerm methods such as getModelQualifierType()
   * and getBiologicalQualifierType().
   *
   * @param resource a string representing the URI of the resource and data
   * item being referenced; e.g.,
   * <code>"http://www.geneontology.org/#GO:0005892"</code>.
   *
   * @return integer value indicating success/failure of the call. The
   * possible values returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see getResources()
   * @see removeResource(std::string resource)
   * @see getQualifierType()
   * @see getModelQualifierType()
   * @see getBiologicalQualifierType()
   */
  int addResource(const std::string& resource);


  /**
   * Removes a resource URI from the set of resources stored in this CVTerm
   * object.
   *
   * @param resource a string representing the resource URI to remove;
   * e.g., <code>"http://www.geneontology.org/#GO:0005892"</code>.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see addResource(const std::string& resource)
   */
  int removeResource(std::string resource);
  

  /**
   * Predicate returning @c true if all the required elements for this
   * CVTerm object have been set.
   *
   * @note The required attributes for a CVTerm are:
   * @li a <em>qualifier type</em>, which can be either a model qualifier or a biological qualifier
   * @li at least one resource
   */ 
  bool hasRequiredAttributes();

  /** @cond doxygenLibsbmlInternal */
  
  bool hasBeenModified();

  void resetModifiedFlags();
   
  
  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  XMLAttributes * mResources;

  QualifierType_t       mQualifier;
  ModelQualifierType_t  mModelQualifier;
  BiolQualifierType_t   mBiolQualifier;

  bool mHasBeenModified;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new CVTerm_t with the given #QualifierType_t value @p type and
 * returns a pointer to it.
 *
 * The possible QualifierTypes are MODEL_QUALIFIER and BIOLOGICAL_QUALIFIER.  
 *
 * @param type a #QualifierType_t
 *
 * @return a pointer to the newly created CVTerm_t structure.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
CVTerm_t*
CVTerm_createWithQualifierType(QualifierType_t type);


/**
 * Create a new CVTerm_t from the given XMLNode_t and returns a 
 * pointer to it.
 *
 * RDFAnnotations within a model are stored as a List_t of CVTerm_t's.  This allows
 * the user to interact with the CVTerm_t's directly.  When LibSBML reads in a 
 * model containing RDFAnnotations it parses them into a %List of CVTerm_t's and
 * when writing a model it parses the CVTerm_t's into the appropriate annotation
 * structure.  This function creates a CVTerm_t from the XMLNode_t supplied.
 *
 * @param node an XMLNode_t representing a CVTerm_t.
 *
 * @return a pointer to the newly created CVTerm_t structure.
 *
 * @note this method assumes that the %XMLNode_t is of the correct form
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
CVTerm_t*
CVTerm_createFromNode(const XMLNode_t * node);


/**
 * Frees the given CVTerm_t structure.
 *
 * @param c the CVTerm_t structure to be freed.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
void
CVTerm_free(CVTerm_t * c);


/**
 * Creates a deep copy of the given CVTerm_t structure
 * 
 * @param term the CVTerm_t structure to be copied
 * 
 * @return a (deep) copy of the given CVTerm_t structure.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
CVTerm_t *
CVTerm_clone (const CVTerm_t* term);


/**
 * Takes a CVTerm_t structure and returns its #QualifierType_t type.
 *
 * @param term the CVTerm_t structure whose #QualifierType_t value is sought
 *
 * @return the #QualifierType_t value of this CVTerm_t or UNKNOWN_QUALIFIER
 * (default).
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
QualifierType_t 
CVTerm_getQualifierType(CVTerm_t* term);


/**
 * Takes a CVTerm_t structure and returns the #ModelQualifierType_t type.
 *
 * @param term the CVTerm_t structure whose #ModelQualifierType_t is sought.
 *
 * @return the #ModelQualifierType_t value of this CVTerm_t or BQM_UNKNOWN
 * (default).
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
ModelQualifierType_t 
CVTerm_getModelQualifierType(CVTerm_t* term);


/**
 * Takes a CVTerm_t structure and returns the #BiolQualifierType_t.
 *
 * @param term the CVTerm_t structure whose #BiolQualifierType_t value is
 * sought.
 *
 * @return the #BiolQualifierType_t value of this CVTerm_t or BQB_UNKNOWN
 * (default).
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
BiolQualifierType_t 
CVTerm_getBiologicalQualifierType(CVTerm_t* term);


/**
 * Takes a CVTerm_t structure and returns the resources.
 * 
 * @param term the CVTerm_t structure whose resources are sought.
 *
 * @return the XMLAttributes_t that store the resources of this CVTerm_t.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
XMLAttributes_t * 
CVTerm_getResources(CVTerm_t* term); 


/**
 * Returns the number of resources for this %CVTerm_t.
 *
 * @param term the CVTerm_t structure whose resources are sought.
 * 
 * @return the number of resources in the set of XMLAttributes
 * of this %CVTerm_t.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
unsigned int
CVTerm_getNumResources(CVTerm_t* term);


/**
 * Returns the value of the nth resource for this %CVTerm_t.
 *
 * @param term the CVTerm_t structure
 * @param n the index of the resource to query
 *
 * @return string representing the value of the nth resource
 * in the set of XMLAttributes of this %CVTerm_t.
 *
 * @note Since the values of the resource attributes in a CVTerm_t
 * are URIs this is a convenience function to facilitate
 * interaction with the CVTerm_t structure.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
char *
CVTerm_getResourceURI(CVTerm_t * term, unsigned int n);


/**
 * Sets the "QualifierType_t" of this %CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param type the QualifierType_t 
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_setQualifierType(CVTerm_t * term, QualifierType_t type);


/**
 * Sets the "ModelQualifierType_t" of this %CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param type the ModelQualifierType_t
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the QualifierType_t for this structure is not MODEL_QUALIFIER
 * then the ModelQualifierType_t will default to BQM_UNKNOWN.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_setModelQualifierType(CVTerm_t * term, ModelQualifierType_t type);


/**
 * Sets the "BiolQualifierType_t" of this %CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param type the BiolQualifierType_t
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the QualifierType_t for this structure is not BIOLOGICAL_QUALIFIER
 * then the BiolQualifierType_t will default to BQB_UNKNOWN.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_setBiologicalQualifierType(CVTerm_t * term, BiolQualifierType_t type);


/**
 * Sets the "ModelQualifierType_t" of this %CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param qualifier the string representing a model qualifier
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the QualifierType_t for this structure is not MODEL_QUALIFIER
 * then the ModelQualifierType_t will default to BQM_UNKNOWN.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_setModelQualifierTypeByString(CVTerm_t * term, const char* qualifier);


/**
 * Sets the "BiolQualifierType_t" of this %CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param qualifier the string representing a biol qualifier
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the QualifierType_t for this structure is not BIOLOGICAL_QUALIFIER
 * then the BiolQualifierType_t will default to BQB_UNKNOWN.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_setBiologicalQualifierTypeByString(CVTerm_t * term, const char* qualifier);

/**
 * Adds a resource to the CVTerm_t.
 *
 * @param term the CVTerm_t structure to set.
 * @param resource string representing the resource 
 * e.g. http://www.geneontology.org/#GO:0005892
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @note this method adds the name "rdf:resource" to the attribute prior
 * to adding it to the resources in this CVTerm_t.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_addResource(CVTerm_t * term, const char * resource);


/**
 * Removes a resource from the CVTerm_t.
 *
 * @param term the CVTerm_t structure.
 * @param resource string representing the resource 
 * e.g. http://www.geneontology.org/#GO:0005892
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int 
CVTerm_removeResource(CVTerm_t * term, const char * resource);


/** 
 * Checks if the CVTerm_t has all the required attributes.
 *
 * @param term the CVTerm_t structure
 * 
 * @return true (1) if this CVTerm_t has all the required elements,
 * otherwise false (0) will be returned. If an invalid CVTerm_t 
 * was provided LIBSBML_INVALID_OBJECT is returned.
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
int
CVTerm_hasRequiredAttributes(CVTerm_t *term);


/**
 * This method takes a model qualifier type code and returns a string 
 * representing the code.
 *
 * This method takes a model qualifier type as argument 
 * and returns a string name corresponding to that code.  For example, 
 * passing it the qualifier <code>BQM_IS_DESCRIBED_BY</code> will return 
 * the string "<code>isDescribedBy</code>". 
 *
 * @return a human readable qualifier name for the given type.
 *
 * @note The caller does not own the returned string and is therefore not
 * allowed to modify it.
 * 
 * @param type The ModelQualifierType_t to translate
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
const char* 
ModelQualifierType_toString(ModelQualifierType_t type);

/**
 * This method takes a biol qualifier type code and returns a string 
 * representing the code.
 *
 * This method takes a biol qualifier type as argument 
 * and returns a string name corresponding to that code.  For example, 
 * passing it the qualifier <code>BQB_HAS_VERSION</code> will return 
 * the string "<code>hasVersion</code>". 
 *
 * @return a human readable qualifier name for the given type.
 *
 * @note The caller does not own the returned string and is therefore not
 * allowed to modify it.
 * 
 * @param type The BiolQualifierType_t to translate
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
const char* 
BiolQualifierType_toString(BiolQualifierType_t type);

/**
 * This method takes a a string and returns a model qualifier
 * representing the string.
 *
 * This method takes a string as argument and returns a model qualifier type 
 * corresponding to that string.  For example, passing it the string 
 * "<code>isDescribedBy</code>" will return the qualifier 
 * <code>BQM_IS_DESCRIBED_BY</code>. 
 *
 * @return a qualifier for the given human readable qualifier name.
 *
 * @param s The string to translate to a ModelQualifierType_t
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
ModelQualifierType_t 
ModelQualifierType_fromString(const char* s);

/**
 * This method takes a a string and returns a biol qualifier
 * representing the string.
 *
 * This method takes a string as argument and returns a biol qualifier type 
 * corresponding to that string.  For example, passing it the string 
 * "<code>hasVersion</code>" will return the qualifier 
 * <code>BQB_HAS_VERSION</code>. 
 *
 * @return a qualifier for the given human readable qualifier name.
 *
 * @param s The string to translate to a BiolQualifierType_t
 *
 * @memberof CVTerm_t
 */
LIBSBML_EXTERN
BiolQualifierType_t 
BiolQualifierType_fromString(const char* s);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /** CVTerm_h **/
