/**
 * @file    RDFAnnotation.h
 * @brief   RDFAnnotation I/O
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
 * @class RDFAnnotationParser
 * @sbmlbrief{core} MIRIAM-compliant RDF annotation reader/writer.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * RDFAnnotationParser is a libSBML construct used as part of the libSBML
 * support for annotations conforming to the guidelines specified by MIRIAM
 * (<a target="_blank"
 * href="http://www.nature.com/nbt/journal/v23/n12/abs/nbt1156.html">"Minimum
 * Information Requested in the Annotation of biochemical Models"</a>,
 * <i>Nature Biotechnology</i>, vol. 23, no. 12, Dec. 2005).  Section 6 of
 * the SBML Level&nbsp;2 and Level&nbsp;3 specification documents defines a
 * recommended way of encoding MIRIAM information using a subset of RDF (<a
 * target="_blank" href="http://www.w3.org/RDF/">Resource Description
 * Format</a>).  The general scheme is as follows.  A set of RDF-based
 * annotations attached to a given SBML <code>&lt;annotation&gt;</code>
 * element are read by RDFAnnotationParser and converted into a list of
 * CVTerm objects.  There are different versions of the main method, @if clike RDFAnnotationParser::parseRDFAnnotation(const XMLNode *annotation, %List *CVTerms) @endif@if java RDFAnnotationParser::parseRDFAnnotation(const XMLNode *annotation, %CVTermList *CVTerms) @endif@~ and
 * RDFAnnotationParser::parseRDFAnnotation(const XMLNode *annotation), used
 * depending on whether the annotation in question concerns the MIRIAM model
 * history or other MIRIAM resource annotations.  A special object class,
 * ModelHistory, is used to make it easier to manipulate model history
 * annotations.
 *
 * All of the methods on RDFAnnotationParser are static; the class exists
 * only to encapsulate the annotation and CVTerm parsing and manipulation
 * functionality.
 */

#ifndef RDFAnnotationParser_h
#define RDFAnnotationParser_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/xml/XMLAttributes.h>

#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/annotation/ModelHistory.h>
#endif

#ifdef __cplusplus

#include <limits>
#include <iomanip>
#include <string>
#include <sstream>

#include <cstdlib>

LIBSBML_CPP_NAMESPACE_BEGIN

#ifdef LIBSBML_USE_STRICT_INCLUDES
class ModelHistory;
class ModelCreator;
class Date;
#endif

class XMLErrorLog;

class LIBSBML_EXTERN RDFAnnotationParser
{
public:

  /**
   * Parses an annotation (given as an XMLNode tree) into a list of
   * CVTerm objects.
   *
   * This is used to take an annotation that has been read into an SBML
   * model, identify the RDF elements within it, and create a list of
   * corresponding CVTerm (controlled vocabulary term) objects.
   *
   * @param annotation XMLNode containing the annotation.
   * @param CVTerms list of CVTerm objects to be created.
   * @param metaId optional metaId, if set only the RDF annotation for this metaId will be returned.
   * @param stream optional XMLInputStream that facilitates error logging.
   *
   * @copydetails doc_note_static_methods
   */
  static void parseRDFAnnotation(const XMLNode *annotation, List *CVTerms,
                  const char* metaId = NULL, XMLInputStream* stream = NULL);


  /**
   * Parses an annotation into a ModelHistory class instance.
   *
   * This is used to take an annotation that has been read into an SBML
   * model, identify the RDF elements representing model history
   * information, and create a list of corresponding CVTerm objects.
   *
   * @param annotation XMLNode containing the annotation.
   * @param stream optional XMLInputStream that facilitates error logging
   * @param metaId optional metaId, if set only the RDF annotation for this metaId will be returned.
   *
   * @copydetails doc_note_static_methods
   *
   * @return a pointer to the ModelHistory created.
   */
  static ModelHistory* parseRDFAnnotation(const XMLNode *annotation, 
    const char* metaId = NULL, XMLInputStream* stream = NULL);


  /**
   * Creates a blank annotation and returns its root XMLNode object.
   *
   * This creates a completely empty SBML <code>&lt;annotation&gt;</code>
   * element.  It is not attached to any SBML element.  An example of how
   * this might be used is illustrated in the following code fragment.  In
   * this example, suppose that @c content is an XMLNode object previously
   * created, containing MIRIAM-style annotations, and that @c sbmlObject
   * is an SBML object derived from SBase (e.g., a Model, or a Species, or
   * a Compartment, etc.).  Then:@if clike
@code{.cpp}
int success;                              // Status code variable, used below.

XMLNode *RDF = createRDFAnnotation();     // Create RDF annotation XML structure.
success = RDF->addChild(...content...);   // Put some content into it.
...                                       // Check "success" return code value.

XMLNode *ann = createAnnotation();        // Create <annotation> container.
success = ann->addChild(RDF);             // Put the RDF annotation into it.
...                                       // Check "success" return code value.

success = sbmlObject->setAnnotation(ann); // Set object's annotation to what we built.
...                                       // Check "success" return code value.
@endcode
   * @endif@if java
@code{.java}
int success;                                   // Status code variable, used below.

XMLNode RDF = createRDFAnnotation();          // Create RDF annotation XML structure.
success      = RDF.addChild(...content...);    // Put some content into it.
...                                            // Check "success" return code value.

XMLNode ann = createAnnotation();             // Create <annotation> container.
success      = ann.addChild(RDF);              // Put the RDF annotation into it.
...                                            // Check "success" return code value.

success      = sbmlObject.setAnnotation(ann); // Set object's annotation to what we built.
...                                            // Check "success" return code value.
@endcode
   * @endif@if python
@code{.py}
RDF     = RDFAnnotationParser.createRDFAnnotation() # Create RDF annotation XML structure.
success = RDF.addChild(...content...)               # Put some content into it.
...                                                 # Check "success" return code value.

annot   = RDFAnnotationParser.createAnnotation()    # Create <annotation> container.
success = annot.addChild(RDF)                       # Put the RDF annotation into it.
...                                                 # Check "success" return code value.

success = sbmlObject.setAnnotation(annot)           # Set object's annotation to what we built.
...                                                 # Check "success" return code value.
@endcode
   * @endif@~
   * The SBML specification contains more information about the format of
   * annotations.  We urge readers to consult Section&nbsp;6 of the SBML
   * Level&nbsp;2 (Versions 2&ndash;4) and SBML Level&nbsp;3 specification
   * documents.
   *
   * @return a pointer to an XMLNode for the annotation
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike createRDFAnnotation() @else RDFAnnotationParser::createRDFAnnotation() @endif@~
   */
  static XMLNode * createAnnotation();

 
  /**
   * Creates a blank RDF element suitable for use in SBML annotations.
   *
   * The annotation created by this method has namespace declarations for
   * all the relevant XML namespaces used in RDF annotations and also has
   * an empty RDF element.  The result is the following XML:
@verbatim
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:dcterms="http://purl.org/dc/terms/"
         xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#"
         xmlns:bqbiol="http://biomodels.net/biology-qualifiers/"
         xmlns:bqmodel="http://biomodels.net/model-qualifiers/" >

</rdf:RDF>
@endverbatim
   *
   * Note that this does not create the containing SBML
   * <code>&lt;annotation&gt;</code> element; the method
   * @if clike createAnnotation()@else RDFAnnotationParser::createAnnotation()@endif@~
   * is available for creating the container.
   *
   * @return a pointer to an XMLNode
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike createAnnotation() @else RDFAnnotationParser::createAnnotation() @endif@~
   */
  static XMLNode * createRDFAnnotation();


  /**
   * Takes an SBML object and creates an empty XMLNode corresponding to an
   * RDF "Description" element.
   *
   * This method is a handy way of creating RDF description objects linked
   * by the appropriate "metaid" field to the given @p object, for
   * insertion into RDF annotations in a model.  The method retrieves the
   * "metaid" attribute from the @p object passed in as argument, then
   * creates an empty element having the following form
   * (where <span class="code" style="background-color: #eed0d0">metaid</span> 
   * the value of the "metaid" attribute of the argument):
   * 
 <pre class="fragment">
 &lt;rdf:Description rdf:about=&quot;#<span style="background-color: #eed0d0">metaid</span>&quot; xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"&gt;
 ...
 &lt;/rdf:Description&gt;
 </pre>
   * Note that this method does @em not create a complete annotation or
   * even an RDF element; it only creates the "Description" portion.  Callers
   * will need to use other methods such as
   * @if clike createRDFAnnotation()@else RDFAnnotationParser::createRDFAnnotation()@endif@~
   * to create the rest of the structure for an annotation.
   *
   * @param obj the object to which the "Description" refers
   *
   * @return a new XMLNode containing the "rdf:Description" element with
   * its "about" attribute value set to the @p object meta identifier.
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike createRDFAnnotation() @else RDFAnnotationParser::createRDFAnnotation() @endif@~
   */
  static XMLNode * createRDFDescription(const SBase *obj);


  /**
   * Takes a list of CVTerm objects and creates a the RDF "Description"
   * element.
   *
   * This essentially takes the given SBML object, reads out the CVTerm
   * objects attached to it, creates an RDF "Description" element to hold
   * the terms, and adds each term with appropriate qualifiers.
   *
   * @param obj the SBML object to start from
   *
   * @return the XMLNode tree corresponding to the Description element of
   * an RDF annotation.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * createCVTerms(const SBase *obj);


  /**
   * Takes a list of CVTerm objects and creates a complete SBML annotation
   * around it.
   *
   * This essentially takes the given SBML object, reads out the CVTerm
   * objects attached to it, calls @if clike createRDFAnnotation()@else
   * RDFAnnotationParser::createRDFAnnotation()@endif@~ to create an RDF
   * annotation to hold the terms, and finally calls @if clike
   * createAnnotation()@else
   * RDFAnnotationParser::createAnnotation()@endif@~ to wrap the result as
   * an SBML <code>&lt;annotation&gt;</code> element.
   *
   * @param obj the SBML object to start from
   *
   * @return the XMLNode tree corresponding to the annotation.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * parseCVTerms(const SBase * obj);


  /**
   * Reads the model history and cvTerms stored in @p obj and creates the
   * XML structure for an SBML annotation representing that metadata if 
   * there is a model history stored in @p obj.
   *
   * @param obj any SBase object
   *
   * @return the XMLNode corresponding to an annotation containing 
   * MIRIAM-compliant model history and CV term information in RDF format.
   *
   * @note If the object does not have a history element stored then
   * @c NULL is returned even if CVTerms are present.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * parseModelHistory(const SBase * obj);


  /**
   * Reads the model history stored in @p obj and creates the
   * XML structure for an SBML annotation representing that history.
   *
   * @param obj any SBase object
   *
   * @return the XMLNode corresponding to an annotation containing 
   * MIRIAM-compliant model history information in RDF format.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * parseOnlyModelHistory(const SBase * obj);


  /**
   * Deletes any SBML MIRIAM RDF annotation found in the given XMLNode 
   * tree and returns
   * any remaining annotation content.
   *
   * The name of the XMLNode given as parameter @p annotation must be
   * "annotation", or else this method returns @c NULL.  The method will
   * walk down the XML structure looking for elements that are in the
   * RDF XML namespace, and remove them if they conform to the syntax
   * of a History or CVTerm element.
   *
   * @param annotation the XMLNode tree within which the RDF annotation is
   * to be found and deleted
   *
   * @return the XMLNode structure that is left after RDF annotations are
   * deleted.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * deleteRDFAnnotation(const XMLNode *annotation);


  /**
   * Deletes any SBML MIRIAM RDF 'History' annotation found in the given 
   * XMLNode tree and returns
   * any remaining annotation content.
   *
   * The name of the XMLNode given as parameter @p annotation must be
   * "annotation", or else this method returns @c NULL.  The method will
   * walk down the XML structure looking for elements that are in the
   * RDF XML namespace, and remove any that conform to the syntax of a
   * History element.
   *
   * @param annotation the XMLNode tree within which the RDF annotation is
   * to be found and deleted
   *
   * @return the XMLNode structure that is left after RDF annotations are
   * deleted.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * deleteRDFHistoryAnnotation(const XMLNode *annotation);


  /**
   * Deletes any SBML MIRIAM RDF 'CVTerm' annotation found in the given 
   * XMLNode tree and returns
   * any remaining annotation content.
   *
   * The name of the XMLNode given as parameter @p annotation must be
   * "annotation", or else this method returns @c NULL.  The method will
   * walk down the XML structure looking for elements that are in the
   * RDF XML namespace, and remove any that conform to the syntax of a
   * CVTerm element.
   *
   * @param annotation the XMLNode tree within which the RDF annotation is
   * to be found and deleted
   *
   * @return the XMLNode structure that is left after RDF annotations are
   * deleted.
   *
   * @copydetails doc_note_static_methods
   */
  static XMLNode * deleteRDFCVTermAnnotation(const XMLNode *annotation);


  /** @cond doxygenLibsbmlInternal */

  
  static bool hasRDFAnnotation(const XMLNode *annotation);


  static bool hasAdditionalRDFAnnotation(const XMLNode *annotation);


  static bool hasCVTermRDFAnnotation(const XMLNode *annotation);


  static bool hasHistoryRDFAnnotation(const XMLNode *annotation);

  /** @endcond */

  protected:

  /** @cond doxygenLibsbmlInternal */

  static XMLNode * createRDFDescription(const std::string& metaid);

  
  static XMLNode * createRDFDescriptionWithCVTerms(const SBase *obj);


  static XMLNode * createRDFDescriptionWithHistory(const SBase *obj);


  static void deriveCVTermsFromAnnotation(const XMLNode *annotation, List *CVTerms);

  
  static ModelHistory* deriveHistoryFromAnnotation(const XMLNode *annotation);

   /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
  * Parses an annotation (given as an XMLNode_t tree) into a list of
  * CVTerms.
  *
  * This is used to take an annotation that has been read into an SBML
  * model, identify the RDF elements within it, and create a list of
  * corresponding CVTerms.
  *
  * @param annotation XMLNode_t containing the annotation.
  * 
  * @param CVTerms list of CVTerms to be created.
  *
  * @see RDFAnnotationParser_parseRDFAnnotationWithModelHistory
  * (const XMLNode_t *annotation)
  *
  * @memberof RDFAnnotationParser_t
  */
void
RDFAnnotationParser_parseRDFAnnotation(const XMLNode_t * annotation, 
                                       List_t *CVTerms);

/**
  * Parses an annotation into a ModelHistory_t structure.
  *
  * This is used to take an annotation that has been read into an SBML
  * model, identify the RDF elements representing model history
  * information, and create a list of corresponding CVTerms.
  *
  * @param annotation XMLNode_t containing the annotation.
  *
  * @return a pointer to the ModelHistory_t created.
  *
  * @see RDFAnnotationParser_parseRDFAnnotation
  * (const XMLNode *annotation, List *CVTerms)
  *
  * @memberof RDFAnnotationParser_t
  */
ModelHistory_t *
RDFAnnotationParser_parseRDFAnnotationWithModelHistory(
                                        const XMLNode_t * annotation);

/**
  * Creates a blank annotation and returns the XMLNode_t 
  * corresonding to it.
  *
  * The annotation created by this method is a completely empty SBML
  * <code>&lt;annotation&gt;</code> element.  One use for this is to
  * then call createRDFAnnotation() to construct RDF content for this
  * empty annotation.
  *
  * @return a pointer to an XMLNode_t for the annotation
  *
  * @see RDFAnnotationParser_createRDFAnnotation()
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_createAnnotation();

/**
  * Creates blank RDF annotation content organized in the form defined in
  * Section 6 of the SBML Level 2 Version 4 specification .
  *
  * The annotation created by this method has namespace declarations for
  * all the relevant XML namespaces used in RDF annotations and also has
  * an empty RDF element.  Note that this is not the containing
  * <code>&lt;annotation&gt;</code> element; the method createAnnotation()
  * is available for that purpose.
  *
  * @return a pointer to an XMLNode_t represting the annotation.
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_createRDFAnnotation();

/**
  * Deletes any RDF annotation found in the given XMLNode_t tree and returns
  * any remaining annotation content.
  *
  * The name of the given XMLNode_t must be "annotation", or else this
  * method returns NULL.
  *
  * @param annotation the XMLNode_t tree within which the RDF annotation
  * is to be found and deleted
  *
  * @return the XMLNode_t structure with any RDF annotations deleted
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_deleteRDFAnnotation(XMLNode_t *annotation);

/**
  * Takes an SBML object and creates an XMLNode_t corresponding to an
  * RDF "Description" element.
  *
  * This method is a handy way of creating RDF description objects linked
  * by the appropriate "metaid" field, for insertion into RDF annotations
  * in a model.  (Note that this method does not create a complete
  * annotation; it only creates a description element.  For creating empty
  * RDF annotations that can serve as containers for RDF descriptions, see
  * RDFAnnotationParser_createRDFAnnotation().
  *
  * @param obj the object to be annotated
  *
  * @return a new XMLNode_t containing the "rdf:about" structure for an
  * RDF "Description" element.
  *
  * @see RDFAnnotationParser_createRDFAnnotation()
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_createRDFDescription(const SBase_t * obj);

/**
  * Takes a list of CVTerms form an SBML object and 
  * creates a the RDF "Description" element.
  *
  * This essentially takes the given SBML object, reads out the CVTerms
  * attached to it, calls createRDFDescriptiom() to create an RDF
  * "Description" element to hold the terms and adds each term with
  * appropriate qualifiers.
  *
  * @param obj the SBML object to start from
  *
  * @return the XMLNode_t tree corresponding to the Description element of
  * an RDF annotation.
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_createCVTerms(const SBase_t * obj);

/**
  * Takes a list of CVTerms from an SBML object and creates a 
  * complete SBML annotation around it.
  *
  * This essentially takes the given SBML object, calls createRDFDescriptionWithCVTerms
  * to read out the CVTerms
  * attached to it, calls createRDFAnnotation() to create an RDF
  * annotation to hold the terms, and finally calls createAnnotation() to
  * wrap the result as an SBML <code>&lt;annotation&gt;</code> element.
  *
  * @param obj the SBML object to start from
  *
  * @return the XMLNode_t tree corresponding to the annotation.
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_parseCVTerms(const SBase_t * obj);

/**
  * Takes an SBML Model_t structure, reads off the model history information
  * stored in it, and creates a complete SBML annotation to store that
  * history.
  *
  * @param obj a Model_t
  *
  * @return the XMLNode_t corresponding to an annotation containing 
  * MIRIAM-compliant model history information in RDF format
  *
  * @memberof RDFAnnotationParser_t
  */
XMLNode_t *
RDFAnnotationParser_parseModelHistory(const SBase_t * obj);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /** RDFAnnotation_h **/

