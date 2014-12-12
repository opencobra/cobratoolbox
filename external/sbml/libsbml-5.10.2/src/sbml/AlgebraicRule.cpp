/**
 * @file    AlgebraicRule.cpp
 * @brief   Implementations of AlgebraicRule.
 * @author  Ben Bornstein
 *
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

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/xml/XMLNamespaces.h>

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/AlgebraicRule.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus


AlgebraicRule::AlgebraicRule (unsigned int level, unsigned int version) :
  Rule(SBML_ALGEBRAIC_RULE, level, version)
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  mInternalIdOnly = false;
}


AlgebraicRule::AlgebraicRule (SBMLNamespaces * sbmlns) :
  Rule(SBML_ALGEBRAIC_RULE, sbmlns)
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  mInternalIdOnly = false;

  loadPlugins(sbmlns);
}


/*
 * Destroys this AlgebraicRule.
 */
AlgebraicRule::~AlgebraicRule ()
{
}

/*
 * @return a (deep) copy of this Rule.
 */
AlgebraicRule*
AlgebraicRule::clone () const
{
  return new AlgebraicRule(*this);
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Model's next Rule
 * (if available).
 */
bool
AlgebraicRule::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}

bool 
AlgebraicRule::hasRequiredAttributes() const
{
  bool allPresent = Rule::hasRequiredAttributes();

  return allPresent;
}



/** @cond doxygenLibsbmlInternal */

/*
 * sets the mInternalIdOnly flag
 */
void 
AlgebraicRule::setInternalIdOnly()
{
  mInternalIdOnly = true;
}

/*
 * gets the mInternalIdOnly flag
 */
bool 
AlgebraicRule::getInternalIdOnly() const
{
  return mInternalIdOnly;
}

/** @endcond */

#endif /* __cplusplus */


/** @cond doxygenIgnored */

LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_create(unsigned int level, unsigned int version)
{
  try
  {
    AlgebraicRule* obj = new AlgebraicRule(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    AlgebraicRule* obj = new AlgebraicRule(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
AlgebraicRule_free(AlgebraicRule_t * ar)
{
  if (ar != NULL)
    delete ar;
}


LIBSBML_EXTERN
AlgebraicRule_t *
AlgebraicRule_clone(AlgebraicRule_t * ar)
{
  if (ar != NULL)
  {
    return static_cast<AlgebraicRule_t*>(ar->clone());
  }
  else
  {
    return NULL;
  }
}


LIBSBML_EXTERN
const ASTNode_t*
AlgebraicRule_getMath(const AlgebraicRule_t * ar)
{
	if (ar == NULL)
		return NULL;

	return (ASTNode_t*)(ar->getMath());
}


LIBSBML_EXTERN
const char *
AlgebraicRule_getFormula (const AlgebraicRule_t *r)
{
  return (r != NULL && r->isSetFormula()) ? r->getFormula().c_str() : NULL;
}


LIBSBML_EXTERN
int
AlgebraicRule_isSetMath(const AlgebraicRule_t * ar)
{
  return (ar != NULL) ? static_cast<int>(ar->isSetMath()) : 0;
}


LIBSBML_EXTERN
int
AlgebraicRule_isSetFormula (const AlgebraicRule_t *r)
{
  return (r != NULL) ? static_cast<int>( r->isSetFormula() ) : 0;
}


LIBSBML_EXTERN
int
AlgebraicRule_setMath(AlgebraicRule_t * ar, const ASTNode_t* math)
{
	return (ar != NULL) ? ar->setMath(math) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
AlgebraicRule_setFormula (AlgebraicRule_t *r, const char *formula)
{
  if (r != NULL)
    return (formula == NULL) ? r->setMath(NULL) : r->setFormula(formula);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
AlgebraicRule_hasRequiredAttributes(const AlgebraicRule_t * ar)
{
  return (ar != NULL) ? static_cast<int>(ar->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
int
AlgebraicRule_hasRequiredElements(const AlgebraicRule_t * ar)
{
	return (ar != NULL) ? static_cast<int>(ar->hasRequiredElements()) : 0;
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
