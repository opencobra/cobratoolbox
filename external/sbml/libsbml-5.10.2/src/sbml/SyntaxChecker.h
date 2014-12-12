/**
 * @file    SyntaxChecker.h
 * @brief   Syntax checking functions
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
 * ---------------------------------------------------------------------- -->
 *
 * @class SyntaxChecker
 * @sbmlbrief{core} Methods for checking the validity of SBML identifiers.
 * 
 * @htmlinclude not-sbml-warning.html
 * 
 * This utility class provides static methods for checking the syntax of
 * identifiers and other text used in an SBML model.  The methods allow
 * callers to verify that strings such as SBML identifiers and XHTML notes
 * text conform to the SBML specifications.
 */

#ifndef SyntaxChecker_h
#define SyntaxChecker_h


#include <sbml/common/extern.h>
#include <sbml/SBase.h>
#include <sbml/util/util.h>

#ifdef __cplusplus


#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN SyntaxChecker
{
public:

  /**
   * Returns true @c true or @c false depending on whether the argument
   * string conforms to the syntax of SBML identifiers.
   *
   * @copydetails doc_what_is_sid 
   *
   * This method provides programs with the ability to test explicitly that
   * the identifier strings they create conform to the SBML identifier
   * syntax.
   *
   * @param sid string to be checked for conformance to SBML identifier
   * syntax.
   *
   * @return @c true if the string conforms to type SBML data type
   * <code>SId</code>, @c false otherwise.
   *
   * @copydetails doc_id_syntax
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike isValidUnitSId(std::string sid) @else SyntaxChecker::isValidUnitSId(std::string sid) @endif@~
   * @see @if clike isValidXMLID(std::string sid) @else SyntaxChecker::isValidXMLID(std::string sid) @endif@~
   */  
  static bool isValidSBMLSId(std::string sid);


#ifndef SWIG
  /**
   *
   * Checks the validity of the given srcId and sets the srcId to dstId
   * and returns LIBSBML_OPERATION_SUCCESS if the srcId is valid, otherwise 
   * srcId is not set to the dstId and returns LIBSBML_INVALID_ATTRIBUTE_VALUE.
   *
   * @param srcId the string of SId to be set to the dstId
   * @param dstId the string of SId to be set by the srcId
   *
   * @return LIBSBML_OPERATION_SUCCESS if the srcId is valid, otherwise 
   * LIBSBML_INVALID_ATTRIBUTE_VALUE will be returned.
   */
  static int checkAndSetSId(const std::string &srcId, std::string &dstId);
#endif //SWIG

  
  /**
   * Returns @c true or @c false depending on whether the argument string
   * conforms to the XML data type <code>ID</code>.
   *
   * @copydetails doc_what_is_metaid 
   *
   * This method provides programs with the ability to test explicitly that
   * the identifier strings they create conform to the SBML identifier
   * syntax.
   *
   * @param id string to be checked for conformance to the syntax of
   * <a target="_blank" href="http://www.w3.org/TR/REC-xml/#id">XML ID</a>.
   *
   * @return @c true if the string is a syntactically-valid value for the
   * XML type <a target="_blank"
   * href="http://www.w3.org/TR/REC-xml/#id">ID</a>, @c false otherwise.
   *
   * @note @htmlinclude xmlid-syntax.html
   *
   * @copydetails doc_note_static_methods
   * 
   * @see @if clike isValidSBMLSId(std::string sid) @else SyntaxChecker::isValidSBMLSId(std::string sid) @endif@~
   * @see @if clike isValidUnitSId(std::string sid) @else SyntaxChecker::isValidUnitSId(std::string sid) @endif@~
   */  
  static bool isValidXMLID(std::string id);

  
  /**
   * Returns @c true or @c false depending on whether the @p uri argument string
   * conforms to the XML data type <code>anyURI</code>.
   *
   * Type anyURI is defined by XML Schema 1.0. It is a character string 
   * data type whose values are interpretable as URIs (Universal Resource 
   * Identifiers) as described by the W3C document RFC 3986.  LibSBML
   * does not provide an explicit XML <code>anyURI</code> data type; it uses
   * ordinary character strings, which is easier for applications to
   * support.  LibSBML does, however, test for anyURI validity at
   * various times, such as when reading in models from files and data
   * streams.
   *
   * This method provides programs with the ability to test explicitly that
   * the strings they create conform to the XML anyURI syntax.
   *
   * @param uri string to be checked for conformance to the syntax of
   * <a target="_blank" 
   * href="http://www.w3.org/TR/xmlschema-2/#anyURI">anyURI</a>.
   *
   * @return @c true if the string is a syntactically-valid value for the
   * XML type <a target="_blank"
   * href="http://www.w3.org/TR/xmlschema-2/#anyURI">anyURI</a>, 
   * @c false otherwise.
   *
   * @copydetails doc_note_static_methods
   */  
  static bool isValidXMLanyURI(std::string uri);

 
  /**
   * Returns @c true or @c false depending on whether the argument string
   * conforms to the syntax of SBML unit identifiers.
   *
   * In SBML, the identifiers of units (of both the predefined units and
   * user-defined units) must conform to a data type called
   * <code>UnitSId</code> in the SBML specifications.  LibSBML does not
   * provide an explicit <code>UnitSId</code> data type; it uses ordinary
   * character strings, which is easier for applications to support.
   * LibSBML does, however, test for identifier validity at various times,
   * such as when reading in models from files and data streams.
   *
   * This method provides programs with the ability to test explicitly that
   * the identifier strings they create conform to the SBML identifier
   * syntax.
   *
   * @param units string to be checked for conformance to SBML unit
   * identifier syntax.
   *
   * @return @c true if the string conforms to type SBML data type
   * <code>UnitSId</code>, @c false otherwise.
   *
   * @note @htmlinclude unitid-syntax.html
   *
   * @copydetails doc_note_static_methods
   *
   * @see @if clike isValidSBMLSId(std::string sid) @else SyntaxChecker::isValidSBMLSId(std::string sid) @endif@~
   * @see @if clike isValidXMLID(std::string sid) @else SyntaxChecker::isValidXMLID(std::string sid) @endif@~
   */
   static bool isValidUnitSId(std::string units);


  /**
   * Returns @c true or @c false depending on whether the given XMLNode
   * object contains valid XHTML content.
   *
   * @copydetails doc_what_are_notes
   *
   * An aspect of XHTML validity is that the content is declared to be in
   * the XML namespace for XHTML&nbsp;1.0.  There is more than one way in
   * which this can be done in XML.  In particular, a model might not
   * contain the declaration within the "notes" or "message" subelement
   * itself, but might instead place the declaration on an enclosing
   * element and use an XML namespace prefix within the "notes" element to
   * refer to it.  In other words, the following is valid:
   * @verbatim
<sbml xmlns="http://www.sbml.org/sbml/level2/version3" level="2" version="3"
      xmlns:xhtml="http://www.w3.org/1999/xhtml">
  <model>
    <notes>
      <xhtml:body>
        <xhtml:center><xhtml:h2>A Simple Mitotic Oscillator</xhtml:h2></xhtml:center>
        <xhtml:p>A minimal cascade model for the mitotic oscillator.</xhtml:p>
      </xhtml:body>
    </notes>
  ... rest of model ...
</sbml>
@endverbatim
   * Contrast the above with the following, self-contained version, which
   * places the XML namespace declaration within the <code>&lt;notes&gt;</code>
   * element itself:
   * @verbatim
<sbml xmlns="http://www.sbml.org/sbml/level2/version3" level="2" version="3">
  <model>
    <notes>
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <title/>
        </head>
        <body>
          <center><h2>A Simple Mitotic Oscillator</h2></center>
          <p>A minimal cascade model for the mitotic oscillator.</p>
        </body>
      </html>
    </notes>
  ... rest of model ...
</sbml>
@endverbatim
   *
   * Both of the above are valid XML.  The purpose of the @p sbmlns
   * argument to this method is to allow callers to check the validity of
   * "notes" and "message" subelements whose XML namespace declarations
   * have been put elsewhere in the manner illustrated above.  Callers can
   * can pass in the SBMLNamespaces object of a higher-level model
   * component if the XMLNode object does not itself have the XML namespace
   * declaration for XHTML&nbsp;1.0.
   * 
   * @param xhtml the XMLNode to be checked for conformance.
   * @param sbmlns the SBMLNamespaces associated with the object.
   *
   * @return @c true if the XMLNode content conforms, @c false otherwise.
   *
   * @copydetails doc_note_static_methods
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  static bool hasExpectedXHTMLSyntax(const XMLNode * xhtml, 
                                     SBMLNamespaces * sbmlns = NULL); 


  /** @cond doxygenLibsbmlInternal */

  /**
   * Returns true @c true or @c false depending on whether the argument
   * string conforms to the syntax of SBML identifiers or is empty.
   */  
  static bool isValidInternalSId(std::string sid);

  static bool isValidInternalUnitSId(std::string sid);

  /*
   * return true if element is an allowed xhtml element
   */
  static bool isAllowedElement(const XMLNode &node);

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /*
   * return true has the xhtml ns correctly declared
   */
  static bool hasDeclaredNS(const XMLNode &node, const XMLNamespaces* toplevelNS);

  /** @endcond */


  /** @cond doxygenLibsbmlInternal */

  /*
   * return true if the html tag contains both a title
   * and a body tag 
   */
  static bool isCorrectHTMLNode(const XMLNode &node);

  /** @endcond */


protected:  
  /** @cond doxygenLibsbmlInternal */
  /**
   * Checks if a character is part of the Unicode Letter set.
   * @return true if the character is a part of the set, false otherwise.
   */
  static bool isUnicodeLetter(std::string::iterator, unsigned int);


  /**
   * Checks if a character is part of the Unicode Digit set.
   * @return true if the character is a part of the set, false otherwise.
   */
  static bool isUnicodeDigit(std::string::iterator, unsigned int);


  /**
   * Checks if a character is part of the Unicode CombiningChar set.
   * @return true if the character is a part of the set, false otherwise.
   */
  static bool isCombiningChar(std::string::iterator, unsigned int);


  /**
   * Checks if a character is part of the Unicode Extender set.
   * @return true if the character is a part of the set, false otherwise.
   */
  static bool isExtender(std::string::iterator, unsigned int);

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Predicate indicating whether the
 * argument string conforms to the SBML type SId. 
 *
 * @param sid string to be checked for conformance
 *
 * @return @c true (non-zero) if the string conforms to type SId, 
 * @c false (0) otherwise.
 *
 * @note The literal representation of SBML type SId consists of strings 
 * of characters restricted to:
 *
 *  - letter ::= 'a'..'z','A'..'Z'
 *  - digit  ::= '0'..'9'
 *  - idChar ::= letter | digit | '_'
 *  - SId    ::= ( letter | '_' ) idChar*
 *
 * @memberof SyntaxChecker_t
 */  
LIBSBML_EXTERN
int
SyntaxChecker_isValidSBMLSId(const char * sid);


/**
 * Predicate indicating whether the
 * argument string conforms to the XML 1.0 type ID. 
 *
 * @param id string to be checked for conformance
 *
 * @return @c true (non-zero) if the string conforms to type ID, 
 * @c false (0) otherwise.
 *
 * @note The literal representation of XML 1.0 type ID consists of strings 
 * of characters restricted to:
 *
 *  - NCNameChar ::= letter | digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
 *  - ID ::= ( letter | '_' | ':' ) NCNameChar*
 *
 * @memberof SyntaxChecker_t
 */  
LIBSBML_EXTERN
int
SyntaxChecker_isValidXMLID(const char * id);


/**
 * Predicate indicating whether the
 * argument string conforms to the SBML type UnitSId. 
 *
 * @param units string to be checked for conformance
 *
 * @return @c true (non-zero) if the string conforms to type UnitSId, 
 * @c false (0) otherwise.
 *
 * @note The literal representation of SBML type UniySId consists of strings 
 * of characters restricted to:
 *
 *  - letter ::= 'a'..'z','A'..'Z'
 *  - digit  ::= '0'..'9'
 *  - idChar ::= letter | digit | '_'
 *  - UnitSId    ::= ( letter | '_' ) idChar*
 *
 * @memberof SyntaxChecker_t
 */
LIBSBML_EXTERN
int
SyntaxChecker_isValidUnitSId(const char * units);


/**
 * Predicate indicating whether the
 * argument XMLNode_t structure represents XHTML that conforms to the 
 * requirements of the SBML specification.
 *
 * @param node the XMLNode_t structure to be checked for conformance.
 * @param sbmlns the SBMLNamespaces_t structure associated with the @p node.
 *
 * @return @c true (non-zero) if the XMLNode_t structure conforms, 
 * @c false (0) otherwise.
 *
 * @note the optional SBMLNamespaces_t argument can be used to
 * check for the declaration of the XHTML namespace at the top-level
 * within an SBMLDocument_t.
 *
 * @memberof SyntaxChecker_t
 */
LIBSBML_EXTERN
int
SyntaxChecker_hasExpectedXHTMLSyntax(XMLNode_t * node, 
                                     SBMLNamespaces_t * sbmlns);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* SyntaxChecker_h */
