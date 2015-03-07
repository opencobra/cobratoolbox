/**
 * @file    MathML.h
 * @brief   Utilities for reading and writing MathML to/from text strings.
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
 * ---------------------------------------------------------------------- -->*/

#ifndef MathML_h
#define MathML_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus

#include <limits>
#include <iomanip>
#include <string>
#include <sstream>

#include <cstdlib>

LIBSBML_CPP_NAMESPACE_BEGIN

/** @cond doxygenLibsbmlInternal */

class ASTNode;
class XMLInputStream;
class XMLOutputStream;


/**
 * Reads the MathML from the given XMLInputStream, constructs a corresponding
 * abstract syntax tree and returns a pointer to the root of the tree.
 */
LIBSBML_EXTERN
ASTNode*
readMathML (XMLInputStream& stream, std::string reqd_prefix="", bool inRead = true);


/**
 * Writes the given ASTNode (and its children) to the XMLOutputStream as
 * MathML.
 */
LIBSBML_EXTERN
void
writeMathML (const ASTNode* node, XMLOutputStream& stream, SBMLNamespaces *sbmlns=NULL);


/** @endcond */

/**
 * Writes the given ASTNode (and its children) to a string as MathML, and
 * returns the string.
 *
 * @param node the root of an AST to write out to the stream.
 *
 * @return a string containing the written-out MathML representation
 * of the given AST.
 *
 * @note The string is owned by the caller and should be freed (with
 * free()) when no longer needed.  @c NULL is returned if the given
 * argument is @c NULL.
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
std::string
writeMathMLToStdString (const ASTNode_t* node);


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Reads the MathML from the given XML string, constructs a corresponding
 * abstract syntax tree, and returns a pointer to the root of the tree.
 *
 * @param xml a string containing a full MathML expression
 *
 * @return the root of an AST corresponding to the given mathematical
 * expression, otherwise @c NULL is returned if the given string is @c NULL
 * or invalid.
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
ASTNode_t *
readMathMLFromString (const char *xml);


/**
 * Writes the given ASTNode (and its children) to a string as MathML, and
 * returns the string.
 *
 * @param node the root of an AST to write out to the stream.
 *
 * @return a string containing the written-out MathML representation
 * of the given AST.
 *
 * @note The string is owned by the caller and should be freed (with
 * free()) when no longer needed.  @c NULL is returned if the given
 * argument is @c NULL.
 *
 * @if conly
 * @memberof ASTNode_t
 * @endif
 */
LIBSBML_EXTERN
char *
writeMathMLToString (const ASTNode_t* node);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /** MathML_h **/

