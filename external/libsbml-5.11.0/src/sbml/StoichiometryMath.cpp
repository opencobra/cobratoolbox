/**
 * @file    StoichiometryMath.cpp
 * @brief   Implementation of StoichiometryMath.
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

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/Parameter.h>
#include <sbml/StoichiometryMath.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

StoichiometryMath::StoichiometryMath (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mMath      ( NULL              )
 , mInternalId ( "" )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


StoichiometryMath::StoichiometryMath (SBMLNamespaces * sbmlns) :
   SBase ( sbmlns )
 , mMath      ( NULL              )
 , mInternalId ( "" )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  loadPlugins(sbmlns);
}


/*
 * Destroys this StoichiometryMath.
 */
StoichiometryMath::~StoichiometryMath ()
{
  delete mMath;
}


/*
 * Copy constructor. Creates a copy of this StoichiometryMath.
 */
StoichiometryMath::StoichiometryMath (const StoichiometryMath& orig) :
   SBase          ( orig )
 , mMath          ( NULL    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mInternalId = orig.mInternalId;
 
    if (orig.mMath != NULL) 
    {
      mMath = orig.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
  }
}


/*
 * Assignment operator.
 */
StoichiometryMath& StoichiometryMath::operator=(const StoichiometryMath& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    this->mInternalId = rhs.mInternalId;

    delete mMath;
    if (rhs.mMath != NULL) 
    {
      mMath = rhs.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
    else
    {
      mMath = NULL;
    }
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
StoichiometryMath::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this StoichiometryMath.
 */
StoichiometryMath*
StoichiometryMath::clone () const
{
  return new StoichiometryMath(*this);
}


/*
 * @return the math of this StoichiometryMath.
 */
const ASTNode*
StoichiometryMath::getMath () const
{
  return mMath;
}


/*
 * @return true if the math (or equivalently the formula) of this
 * StoichiometryMath is set, false otherwise.
 */
bool
StoichiometryMath::isSetMath () const
{
  return (mMath != NULL);
}



/*
 * Sets the math of this StoichiometryMath to a copy of the given ASTNode.
 */
int
StoichiometryMath::setMath (const ASTNode* math)
{
  if (mMath == math) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (math == NULL)
  {
    delete mMath;
    mMath = NULL;
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (!(math->isWellFormedASTNode()))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else
  {
    delete mMath;
    mMath = (math != NULL) ? math->deepCopy() : NULL;
    if (mMath != NULL) mMath->setParentSBMLObject(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
StoichiometryMath::getTypeCode () const
{
  return SBML_STOICHIOMETRY_MATH;
}


/*
 * @return the name of this element ie "stoichiometryMath".
 */
const string&
StoichiometryMath::getElementName () const
{
  static const string name = "stoichiometryMath";
  return name;
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
StoichiometryMath::getElementPosition () const
{
  return 0;
}
/** @endcond */


bool 
StoichiometryMath::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for stoichiometryMath: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}

int StoichiometryMath::removeFromParentAndDelete()
{
  SBase* parent = getParentSBMLObject();
  if (parent==NULL) return LIBSBML_OPERATION_FAILED;
  SpeciesReference* parentSR = static_cast<SpeciesReference*>(parent);
  if (parentSR == NULL) return LIBSBML_OPERATION_FAILED;
  return parentSR->unsetStoichiometryMath();
}


void
StoichiometryMath::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
StoichiometryMath::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
}

/** @cond doxygenLibsbmlInternal */
void 
StoichiometryMath::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
{
  if (isSetMath()) {
    if (mMath->getType() == AST_NAME && mMath->getId() == id) {
      delete mMath;
      mMath = function->deepCopy();
    }
    else {
      mMath->replaceIDWithFunction(id, function);
    }
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read (and store) XHTML,
 * MathML, etc. directly from the XMLInputStream.
 *
 * @return true if the subclass read from the stream, false otherwise.
 */
bool
StoichiometryMath::readOtherXML (XMLInputStream& stream)
{
  bool          read = false;
  const string& name = stream.peek().getName();

  if (name == "math")
  {
    // if this is level 1 there shouldnt be any math!!!
    if (getLevel() == 1) 
    {
      logError(NotSchemaConformant, getLevel(), getVersion(),
	       "SBML Level 1 does not support MathML.");
      delete mMath;
      return false;
    }

    /* check for MathML namespace 
     * this may be explicitly declared here
     * or implicitly declared on the whole document
     */
    const XMLToken elem = stream.peek();
    const std::string prefix = checkMathMLNamespace(elem);

    delete mMath;
    mMath = readMathML(stream, prefix);
    if (mMath) mMath->setParentSBMLObject(this);
    read  = true;
  }

  /* ------------------------------
   *
   *   (EXTENSION)
   *
   * ------------------------------ */
  if ( SBase::readOtherXML(stream) )
    read = true;

  return read;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
StoichiometryMath::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

    if (level == 2 && version == 2)
  {
    attributes.add("sboTerm");
  }
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
StoichiometryMath::readAttributes (const XMLAttributes& attributes,
                                   const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "StoichiometryMath is not a valid component for this level/version.");
    break;
  case 2:
    readL2Attributes(attributes);
    break;
  case 3:
  default:
    logError(NotSchemaConformant, level, version,
	      "StoichiometryMath is not a valid component for this level/version.");
    break;
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
StoichiometryMath::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();
  if (version == 2) 
    mSBOTerm = SBO::readTerm(attributes, this->getErrorLog(), level, version,
				getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
StoichiometryMath::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  const unsigned int level = getLevel();

  /* invalid level/version */
  if (level < 2)
  {
    return;
  }
  //
  // sboTerm: SBOTerm { use="optional" }  (L2v3->)
  // is written in SBase::writeAttributes()
  //

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
  * Calculates and returns a UnitDefinition that expresses the units
  * returned by the math expression of this StoichiometryMath.
  */
UnitDefinition * 
StoichiometryMath::getDerivedUnitDefinition()
{
  if (!isSetMath())
    return NULL;
  /* if we have the whole model but it is not in a document
   * it is still possible to determine the units
   */
  
  /* VERY NASTY HACK THAT WILL WORK IF WE DONT KNOW ABOUT COMP
   * but will identify if the parent model is a ModelDefinition
   */
  Model * m = NULL;
  
  if (this->isPackageEnabled("comp"))
  {
    m = static_cast <Model *> (getAncestorOfType(251, "comp"));
  }

  if (m == NULL)
  {
    m = static_cast <Model *> (getAncestorOfType(SBML_MODEL));
  }

  /* we should have a model by this point 
   * OR the object is not yet a child of a model
   */

  if (m != NULL)
  {
    if (!m->isPopulatedListFormulaUnitsData())
    {
      m->populateListFormulaUnitsData();
    }
    
    if (m->getFormulaUnitsData(getInternalId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getInternalId(), getTypeCode())
                                             ->getUnitDefinition();
    }
    else
    {
      return NULL;
    }  
  }
  else
  {
    return NULL;
  }
}


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * Compartment.
  */
const UnitDefinition *
StoichiometryMath::getDerivedUnitDefinition() const
{
  return const_cast <StoichiometryMath *> (this)->getDerivedUnitDefinition();
}


/*
 * Predicate returning @c true if 
 * the math expression of this StoichiometryMath contains
 * parameters/numbers with undeclared units that cannot be ignored.
 */
bool 
StoichiometryMath::containsUndeclaredUnits()
{
  if (!isSetMath())
    return false;
  /* if we have the whole model but it is not in a document
   * it is still possible to determine the units
   */
  
  /* VERY NASTY HACK THAT WILL WORK IF WE DONT KNOW ABOUT COMP
   * but will identify if the parent model is a ModelDefinition
   */
  Model * m = NULL;
  
  if (this->isPackageEnabled("comp"))
  {
    m = static_cast <Model *> (getAncestorOfType(251, "comp"));
  }

  if (m == NULL)
  {
    m = static_cast <Model *> (getAncestorOfType(SBML_MODEL));
  }

  /* we should have a model by this point 
   * OR the object is not yet a child of a model
   */


  if (m != NULL)
  {
    if (!m->isPopulatedListFormulaUnitsData())
    {
      m->populateListFormulaUnitsData();
    }
    
    if (m->getFormulaUnitsData(getInternalId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getInternalId(), getTypeCode())
      ->getContainsUndeclaredUnits();
    }
    else
    {
      return false;
    }  
  }
  else
  {
    return false;
  }
}


bool 
StoichiometryMath::containsUndeclaredUnits() const
{
  return const_cast<StoichiometryMath *> (this)->containsUndeclaredUnits();
}


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
StoichiometryMath::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if ( getLevel() == 2 && isSetMath() ) writeMathML(getMath(), stream, getSBMLNamespaces());

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
StoichiometryMath_t *
StoichiometryMath_create (unsigned int level, unsigned int version)
{
  try
  {
    StoichiometryMath* obj = new StoichiometryMath(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
StoichiometryMath_t *
StoichiometryMath_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    StoichiometryMath* obj = new StoichiometryMath(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
StoichiometryMath_free (StoichiometryMath_t *stoichMath)
{
  if (stoichMath != NULL)
  delete stoichMath;
}


LIBSBML_EXTERN
StoichiometryMath_t *
StoichiometryMath_clone (const StoichiometryMath_t *stoichMath)
{
  return (stoichMath != NULL) ? stoichMath->clone() : NULL;
}


LIBSBML_EXTERN
const XMLNamespaces_t *
StoichiometryMath_getNamespaces(StoichiometryMath_t *sm)
{
  return (sm != NULL) ? sm->getNamespaces() : NULL;
}


LIBSBML_EXTERN
const ASTNode_t *
StoichiometryMath_getMath (const StoichiometryMath_t *stoichMath)
{
  return (stoichMath != NULL) ? stoichMath->getMath() : NULL;
}


LIBSBML_EXTERN
int
StoichiometryMath_isSetMath (const StoichiometryMath_t *stoichMath)
{
  return (stoichMath != NULL) ? static_cast<int>( stoichMath->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
StoichiometryMath_setMath (StoichiometryMath_t *stoichMath, const ASTNode_t *math)
{
  return (stoichMath != NULL) ? stoichMath->setMath(math) :
                                LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
UnitDefinition_t * 
StoichiometryMath_getDerivedUnitDefinition(StoichiometryMath_t *stoichMath)
{
  return (stoichMath != NULL) ? 
    static_cast<StoichiometryMath*>(stoichMath)->getDerivedUnitDefinition() :
    NULL;
}


LIBSBML_EXTERN
int 
StoichiometryMath_containsUndeclaredUnits(StoichiometryMath_t *stoichMath)
{
  return (stoichMath != NULL) ? 
    static_cast<int>(static_cast<StoichiometryMath*>(stoichMath)
                                ->containsUndeclaredUnits()) : 0;
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
