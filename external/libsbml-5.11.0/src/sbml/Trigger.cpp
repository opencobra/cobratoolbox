/**
 * @file    Trigger.cpp
 * @brief   Implementation of Trigger.
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
#include <sbml/Trigger.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Trigger::Trigger (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mMath      ( NULL              )
 , mInitialValue      ( true )
 , mPersistent        ( true )
 , mIsSetInitialValue ( false )
 , mIsSetPersistent   ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


Trigger::Trigger (SBMLNamespaces * sbmlns) :
   SBase ( sbmlns )
 , mMath      ( NULL              )
 , mInitialValue      ( true )
 , mPersistent        ( true )
 , mIsSetInitialValue ( false )
 , mIsSetPersistent   ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
}


/*
 * Destroys this Trigger.
 */
Trigger::~Trigger ()
{
  delete mMath;
}


/*
 * Copy constructor. Creates a copy of this Trigger.
 */
Trigger::Trigger (const Trigger& orig) :
   SBase          ( orig )
 , mMath          ( NULL    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mInitialValue      = orig.mInitialValue;
    mPersistent        = orig.mPersistent;
    mIsSetInitialValue = orig.mIsSetInitialValue;
    mIsSetPersistent   = orig.mIsSetPersistent;

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
Trigger& Trigger::operator=(const Trigger& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    this->mInitialValue      = rhs.mInitialValue;
    this->mPersistent        = rhs.mPersistent;
    this->mIsSetInitialValue = rhs.mIsSetInitialValue;
    this->mIsSetPersistent   = rhs.mIsSetPersistent;

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
Trigger::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Trigger.
 */
Trigger*
Trigger::clone () const
{
  return new Trigger(*this);
}


/*
 * @return the math of this Trigger.
 */
const ASTNode*
Trigger::getMath () const
{
  return mMath;
}


/*
 * @return the initialValue of this Trigger.
 */
bool
Trigger::getInitialValue () const
{
  return mInitialValue;
}


/*
 * @return the persistent of this Trigger.
 */
bool
Trigger::getPersistent () const
{
  return mPersistent;
}


/*
 * @return true if the math (or equivalently the formula) of this
 * Trigger is set, false otherwise.
 */
bool
Trigger::isSetMath () const
{
  return (mMath != NULL);
}



/*
 * @return true if initialValue is set of this Trigger.
 */
bool
Trigger::isSetInitialValue () const
{
  return mIsSetInitialValue;
}


/*
 * @return true if persistent is set of this Trigger.
 */
bool
Trigger::isSetPersistent () const
{
  return mIsSetPersistent;
}


/*
 * Sets the math of this Trigger to a copy of the given ASTNode.
 */
int
Trigger::setMath (const ASTNode* math)
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
 * Sets the initialvalue of this Trigger.
 */
int
Trigger::setInitialValue (bool initialValue)
{
  if (getLevel() < 3)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mInitialValue = initialValue;
    mIsSetInitialValue = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the persistent of this Trigger.
 */
int
Trigger::setPersistent (bool persistent)
{
  if (getLevel() < 3)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mPersistent = persistent;
    mIsSetPersistent = true;
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
Trigger::getTypeCode () const
{
  return SBML_TRIGGER;
}


/*
 * @return the name of this element ie "trigger".
 */
const string&
Trigger::getElementName () const
{
  static const string name = "trigger";
  return name;
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
Trigger::getElementPosition () const
{
  return 0;
}
/** @endcond */


bool 
Trigger::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for trigger: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}


bool 
Trigger::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for event: persistent and initialvalue (L3 ->) 
   */

  if (getLevel() > 2)
  {
    if(!isSetPersistent())
      allPresent = false;

    if(!isSetInitialValue())
      allPresent = false;
  }

  return allPresent;
}

int Trigger::removeFromParentAndDelete()
{
  SBase* parent = getParentSBMLObject();
  if (parent==NULL) return LIBSBML_OPERATION_FAILED;
  Event* parentEvent = static_cast<Event*>(parent);
  if (parentEvent == NULL) return LIBSBML_OPERATION_FAILED;
  return parentEvent->unsetTrigger();
}


void
Trigger::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
Trigger::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
}

/** @cond doxygenLibsbmlInternal */
void 
Trigger::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
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
Trigger::readOtherXML (XMLInputStream& stream)
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

    if (mMath != NULL)
    {
      if (getLevel() < 3) 
      {
        logError(NotSchemaConformant, getLevel(), getVersion(),
	        "Only one <math> element is permitted inside a "
	        "particular containing element.");
      }
      else
      {
        logError(OneMathPerTrigger, getLevel(), getVersion());
      }
    }
    /* check for MathML namespace 
     * this may be explicitly declared here
     * or implicitly declared on the whole document
     */
    const XMLToken elem = stream.peek();
    const std::string prefix = checkMathMLNamespace(elem);

    delete mMath;
    mMath = readMathML(stream, prefix);
    if (mMath != NULL) mMath->setParentSBMLObject(this);
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
Trigger::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();

  switch (level)
  {
  case 3:
    attributes.add("persistent");
    attributes.add("initialValue");
    break;
  }

}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Trigger::readAttributes (const XMLAttributes& attributes,
                         const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "Trigger is not a valid component for this level/version.");
    break;
  case 2:
    readL2Attributes(attributes);
    break;
  case 3:
  default:
    readL3Attributes(attributes);
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
Trigger::readL2Attributes (const XMLAttributes& attributes)
{
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Trigger::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // initailValue { use="required"}  (L3v1 ->)
  //
  mIsSetInitialValue = attributes.readInto("initialValue", 
                        mInitialValue, getErrorLog(), false, getLine(), getColumn());

  if (!mIsSetInitialValue)
  {
    logError(AllowedAttributesOnTrigger, level, version, 
             "The required attribute 'initialValue' is missing.");
  }

  //
  // persistent { use="required"}  (L3v1 ->)
  //
  mIsSetPersistent = attributes.readInto("persistent", 
                        mPersistent, getErrorLog(), false, getLine(), getColumn());

  if (!mIsSetPersistent)
  {
    logError(AllowedAttributesOnTrigger, level, version, 
             "The required attribute 'persistent' is missing.");
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
Trigger::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
 
  /* invalid level/version */
  if (level < 2)
  {
    return;
  }

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v3->)
  // is written in SBase::writeAttributes()
  //
  if (level > 2)
  {
    // in L3 only write it out if it has been set
    if (isSetInitialValue())
      stream.writeAttribute("initialValue", mInitialValue);
      // in L3 only write it out if it has been set
    if (isSetPersistent())
      stream.writeAttribute("persistent", mPersistent);
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
Trigger::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if ( getLevel() > 1 && isSetMath() ) writeMathML(getMath(), stream, getSBMLNamespaces());

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
Trigger_t *
Trigger_create (unsigned int level, unsigned int version)
{
  try
  {
    Trigger* obj = new Trigger(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Trigger_t *
Trigger_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Trigger* obj = new Trigger(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Trigger_free (Trigger_t *t)
{
  if (t != NULL)
  delete t;
}


LIBSBML_EXTERN
Trigger_t *
Trigger_clone (const Trigger_t *t)
{
  return (t != NULL) ? t->clone() : NULL;
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Trigger_getNamespaces(Trigger_t *t)
{
  return (t != NULL) ? t->getNamespaces() : NULL;
}

LIBSBML_EXTERN
const ASTNode_t *
Trigger_getMath (const Trigger_t *t)
{
  return (t != NULL) ? t->getMath() : NULL;
}


LIBSBML_EXTERN
int
Trigger_getInitialValue (const Trigger_t *t)
{
  return (t != NULL) ? static_cast<int>(t->getInitialValue()) : 0;
}


LIBSBML_EXTERN
int
Trigger_getPersistent (const Trigger_t *t)
{
  return (t != NULL) ? static_cast<int>(t->getPersistent()) : 0;
}


LIBSBML_EXTERN
int
Trigger_isSetMath (const Trigger_t *t)
{
  return (t != NULL) ? static_cast<int>( t->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
Trigger_isSetInitialValue (const Trigger_t *t)
{
  return (t != NULL) ? static_cast<int>( t->isSetInitialValue() ) : 0;
}


LIBSBML_EXTERN
int
Trigger_isSetPersistent (const Trigger_t *t)
{
  return (t != NULL) ? static_cast<int>( t->isSetPersistent() ) : 0;
}


LIBSBML_EXTERN
int
Trigger_setMath (Trigger_t *t, const ASTNode_t *math)
{
  return (t != NULL) ? t->setMath(math) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Trigger_setInitialValue (Trigger_t *t, int initialValue)
{
  return (t != NULL) ? t->setInitialValue( static_cast<bool>(initialValue) )
    : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Trigger_setPersistent (Trigger_t *t, int persistent)
{
  return (t != NULL) ? t->setPersistent( static_cast<bool>(persistent) )
    : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Trigger_hasRequiredAttributes (Trigger_t *t)
{
  return (t != NULL) ? static_cast <int> (t->hasRequiredAttributes()) : 0;
}



LIBSBML_EXTERN
int
Trigger_hasRequiredElements (Trigger_t *t)
{
  return (t != NULL) ? static_cast <int> (t->hasRequiredElements() ) : 0;
}




/** @endcond */

LIBSBML_CPP_NAMESPACE_END
