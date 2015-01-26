/**
 * @file    Constraint.cpp
 * @brief   Implementations of Constraint and ListOfConstraints.
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/Constraint.h>

#include <sbml/util/util.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Constraint::Constraint (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mMath   (  NULL )
 , mMessage(  NULL )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


Constraint::Constraint (SBMLNamespaces* sbmlns) :
   SBase   ( sbmlns )
 , mMath   (  NULL )
 , mMessage(  NULL )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
}


/*
 * Destroys this Constraint.
 */
Constraint::~Constraint ()
{
  if(mMath != NULL)    delete mMath;
  if(mMessage != NULL) delete mMessage;
}


/*
 * Copy constructor. Creates a copy of this Constraint.
 */
Constraint::Constraint (const Constraint& orig) :
   SBase   ( orig )
 , mMath   ( NULL   )
 , mMessage( NULL   )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    if (orig.mMath != NULL)    
    {
      mMath    = orig.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
    if (orig.mMessage != NULL) mMessage = new XMLNode(*orig.mMessage);
  }
}


/*
 * Assignment operator
 */
Constraint& Constraint::operator=(const Constraint& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);

    delete mMath;
    if (rhs.mMath != NULL)    
    {
      mMath    = rhs.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
    else
    {
      mMath = NULL;
    }

    delete mMessage;
    if (rhs.mMessage != NULL) 
      mMessage = new XMLNode(*rhs.mMessage);
    else
      mMessage = NULL;
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Model's next
 * Constraint (if available).
 */
bool
Constraint::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Constraint.
 */
Constraint*
Constraint::clone () const
{
  return new Constraint(*this);
}


/*
 * @return the message for this Constraint.
 */
const XMLNode*
Constraint::getMessage () const
{
  return mMessage;
}


/*
 * @return the message for this Constraint.
 */
std::string
Constraint::getMessageString () const
{
  return mMessage->toXMLString();
}


/*
 * @return the math for this Constraint.
 */
const ASTNode*
Constraint::getMath () const
{
  return mMath;
}


/*
 * @return true if the message of this Constraint is set,
 * false otherwise.
 */
bool
Constraint::isSetMessage () const
{
  return (mMessage != NULL);
}


/*
 * @return true if the math for this Constraint is set,
 * false otherwise.
 */
bool
Constraint::isSetMath () const
{
  return (mMath != NULL);
}


/*
 * Sets the message of this Constraint to a copy of xhtml.
 */
int
Constraint::setMessage (const XMLNode* xhtml)
{
  if (mMessage == xhtml)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (xhtml == NULL)
  {
    delete mMessage;
    mMessage = NULL;
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (!SyntaxChecker::hasExpectedXHTMLSyntax(xhtml, getSBMLNamespaces()))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else
  {
    delete mMessage;
    mMessage = (xhtml != NULL) ? new XMLNode(*xhtml) : NULL;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the math of this Constraint to a copy of the given
 * ASTNode.
 */
int
Constraint::setMath (const ASTNode* math)
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
    if (mMath) mMath->setParentSBMLObject(this);
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Unsets the message of this Constraint.
 */
int 
Constraint::unsetMessage ()
{
  delete mMessage;
  mMessage = NULL;
  
  if (mMessage)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  else
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
}


void
Constraint::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
Constraint::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
}

/** @cond doxygenLibsbmlInternal */
void 
Constraint::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
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

/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
Constraint::getTypeCode () const
{
  return SBML_CONSTRAINT;
}


/*
 * @return the name of this element ie "constraint".
 */
const string&
Constraint::getElementName () const
{
  static const string name = "constraint";
  return name;
}


bool 
Constraint::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for constraint: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read (and store) XHTML,
 * MathML, etc. directly from the XMLInputStream.
 *
 * @return true if the subclass read from the stream, false otherwise.
 */
bool
Constraint::readOtherXML (XMLInputStream& stream)
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

    if (mMath)
    {
      if (getLevel() < 3) 
      {
        logError(NotSchemaConformant, getLevel(), getVersion(),
	        "Only one <math> element is permitted inside a "
	        "particular containing element.");
      }
      else
      {
        logError(OneMathElementPerConstraint, getLevel(), getVersion());
      }
    }
    // If there's a <message>, it's supposed to show up first

    if (mMessage && getLevel() == 2) logError(IncorrectOrderInConstraint);

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
  else if (name == "message")
  {
    if (mMessage)
    {
      if (getLevel() < 3) 
      {
        logError(NotSchemaConformant, getLevel(), getVersion(),
	        "Only one <message> element is permitted inside a "
	        "particular containing element.");
      }
      else
      {
        logError(OneMessageElementPerConstraint, getLevel(), getVersion());
      }
    }
    delete mMessage;

    mMessage = new XMLNode(stream);

    //
    // checks if the given default namespace (if any) is a valid
    // SBML namespace
    //
    const XMLNamespaces &xmlns = mMessage->getNamespaces();
    checkDefaultNamespace(&xmlns,"message");

    if (getSBMLDocument() != NULL)
    {
      if (getSBMLDocument()->getNumErrors() == 0)
      {
        checkXHTML(mMessage);
      }
    }
    read     = true;
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
Constraint::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);
  if (mURI == SBML_XMLNS_L2V2)
    attributes.add("sboTerm");
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Constraint::readAttributes (const XMLAttributes& attributes,
                            const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "Constraint is not a valid component for this level/version.");
    break;
  case 2:
    if (version == 1)
    {
      logError(NotSchemaConformant, level, version,
	        "Constraint is not a valid component for this level/version.");
    }
    else
    {
      readL2Attributes(attributes);
    }
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
Constraint::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2 -> )
  //
  if (version == 2)
    mSBOTerm = SBO::readTerm(attributes, this->getErrorLog(), level, version,
				getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Constraint::readL3Attributes (const XMLAttributes& attributes)
{
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
Constraint::writeAttributes (XMLOutputStream& stream) const
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  /* invalid level/version */
  if (level < 2 || (level == 2 && version == 1))
  {
    return;
  }

  SBase::writeAttributes(stream);

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2 ->)
  //
  // sboTerm for L2V3 or later is read in SBase::readAttributes()
  //
  if ( (level == 2) && (version == 2) )
  {
    SBO::writeTerm(stream, mSBOTerm);
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
Constraint::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if (mMath) writeMathML(mMath, stream, getSBMLNamespaces());

  if (mMessage) stream << *mMessage;

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */


/*
 * Creates a new ListOfConstraints items.
 */
ListOfConstraints::ListOfConstraints (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfConstraints items.
 */
ListOfConstraints::ListOfConstraints (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfConstraints.
 */
ListOfConstraints*
ListOfConstraints::clone () const
{
  return new ListOfConstraints(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfConstraints::getItemTypeCode () const
{
  return SBML_CONSTRAINT;
}


/*
 * @return the name of this element ie "listOfConstraints".
 */
const string&
ListOfConstraints::getElementName () const
{
  static const string name = "listOfConstraints";
  return name;
}


/* return nth item in list */
Constraint *
ListOfConstraints::get(unsigned int n)
{
  return static_cast<Constraint*>(ListOf::get(n));
}


/* return nth item in list */
const Constraint *
ListOfConstraints::get(unsigned int n) const
{
  return static_cast<const Constraint*>(ListOf::get(n));
}


/* Removes the nth item from this list */
Constraint*
ListOfConstraints::remove (unsigned int n)
{
   return static_cast<Constraint*>(ListOf::remove(n));
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfConstraints::getElementPosition () const
{
  return 10;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfConstraints::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "constraint")
  {
    try
    {
      object = new Constraint(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new Constraint(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new Constraint(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    
    if (object != NULL) mItems.push_back(object);
  }

  return object;
}
/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
Constraint_t *
Constraint_create (unsigned int level, unsigned int version)
{
  try
  {
    Constraint* obj = new Constraint(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Constraint_t *
Constraint_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Constraint* obj = new Constraint(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Constraint_free (Constraint_t *c)
{
  if (c != NULL)
  delete c;
}


LIBSBML_EXTERN
Constraint_t *
Constraint_clone (const Constraint_t *c)
{
  if (c != NULL)
  {
    return static_cast<Constraint*>( c->clone() );
  }
  else
  {
    return NULL;
  }
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Constraint_getNamespaces(Constraint_t *c)
{
  if (c != NULL)
  {
    return c->getNamespaces();
  }
  else
  {
    return NULL;
  }
}

LIBSBML_EXTERN
const XMLNode_t *
Constraint_getMessage (const Constraint_t *c)
{
  return (c != NULL && c->isSetMessage()) ? c->getMessage() : NULL;
}


LIBSBML_EXTERN
char*
Constraint_getMessageString (const Constraint_t *c)
{
  return (c != NULL && c->isSetMessage()) ? 
                       safe_strdup(c->getMessageString().c_str()) : NULL;
}


LIBSBML_EXTERN
const ASTNode_t *
Constraint_getMath (const Constraint_t *c)
{
  return (c != NULL && c->isSetMath()) ? c->getMath() : NULL;
}


LIBSBML_EXTERN
int
Constraint_isSetMessage (const Constraint_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetMessage() ) : 0;
}


LIBSBML_EXTERN
int
Constraint_isSetMath (const Constraint_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
Constraint_setMessage (Constraint_t *c, const XMLNode_t *xhtml)
{
  if (c != NULL)
  {
    return c->setMessage(xhtml);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


LIBSBML_EXTERN
int
Constraint_setMath (Constraint_t *c, const ASTNode_t *math)
{
  if (c != NULL)
  {
    return c->setMath(math);
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}


LIBSBML_EXTERN
int 
Constraint_unsetMessage (Constraint_t *c)
{
  if (c != NULL)
  {
    return c->unsetMessage();
  }
  else
  {
    return LIBSBML_INVALID_OBJECT;
  }
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

