/**
 * @file    EventAssignment.cpp
 * @brief   Implementation of EventAssignment.
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

#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/EventAssignment.h>

#include <signal.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

EventAssignment::EventAssignment (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mVariable ( "" )
 , mMath     ( NULL  )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


EventAssignment::EventAssignment (SBMLNamespaces * sbmlns) :
   SBase ( sbmlns )
 , mVariable ( "" )
 , mMath     ( NULL  )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
}


/*
 * Destroys this EventAssignment.
 */
EventAssignment::~EventAssignment ()
{
  delete mMath;
}


/*
 * Copy constructor. Creates a copy of this EventAssignment.
 */
EventAssignment::EventAssignment (const EventAssignment& orig) :
   SBase   ( orig )
  , mMath  ( NULL    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mVariable  = orig.mVariable;

    if (orig.mMath != NULL) 
    {
      mMath = orig.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
  }
}


/*
 * Assignment operator
 */
EventAssignment& EventAssignment::operator=(const EventAssignment& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    this->mVariable = rhs.mVariable;

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
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Event's next
 * EventAssignment (if available).
 */
bool
EventAssignment::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this EventAssignment.
 */
EventAssignment*
EventAssignment::clone () const
{
  return new EventAssignment(*this);
}


/*
 * @return the variable of this EventAssignment.
 */
const string&
EventAssignment::getVariable () const
{
  return mVariable;
}


/*
 * @return the math of this EventAssignment.
 */
const ASTNode*
EventAssignment::getMath () const
{
  return mMath;
}


/*
 * @return true if the variable of this EventAssignment is set, false
 * otherwise.
 */
bool
EventAssignment::isSetVariable () const
{
  return (mVariable.empty() == false);
}


/*
 * @return true if the math of this EventAssignment is set, false
 * otherwise.
 */
bool
EventAssignment::isSetMath () const
{
  return (mMath != NULL);
}


/*
 * Sets the variable of this EventAssignment to a copy of sid.
 */
int
EventAssignment::setVariable (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mVariable = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the math of this EventAssignment to a copy of the given ASTNode.
 */
int
EventAssignment::setMath (const ASTNode* math)
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
  * Calculates and returns a UnitDefinition that expresses the units
  * returned by the math expression of this EventAssignment.
  */
UnitDefinition * 
EventAssignment::getDerivedUnitDefinition()
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
    
    std::string id = getVariable() + getAncestorOfType(SBML_EVENT)->getId();
    if (m->getFormulaUnitsData(id, getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(id, getTypeCode())
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
EventAssignment::getDerivedUnitDefinition() const
{
  return const_cast <EventAssignment *> (this)->getDerivedUnitDefinition();
}


/*
 * Predicate returning @c true if 
 * the math expression of this EventAssignment contains
 * parameters/numbers with undeclared units that cannot be ignored.
 */
bool 
EventAssignment::containsUndeclaredUnits()
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

    std::string id = getVariable() + getAncestorOfType(SBML_EVENT)->getId();
    if (m->getFormulaUnitsData(id, getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(id, getTypeCode())
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
EventAssignment::containsUndeclaredUnits() const
{
  return const_cast<EventAssignment *> (this)->containsUndeclaredUnits();
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the string of variable attribute of this object.
 * 
 * @note this function is an alias for getVariable()
 * 
 * @see getVariable()
 */
const std::string& 
EventAssignment::getId() const
{
  return getVariable();
}
/** @endcond */


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
EventAssignment::getTypeCode () const
{
  return SBML_EVENT_ASSIGNMENT;
}


/*
 * @return the name of this element ie "eventAssignment".
 */
const string&
EventAssignment::getElementName () const
{
  static const string name = "eventAssignment";
  return name;
}


bool 
EventAssignment::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for eventAssignment: variable */

  if (!isSetVariable())
    allPresent = false;

  return allPresent;
}


bool 
EventAssignment::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for eventAssignment: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}


void
EventAssignment::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (mVariable == oldid) {
    setVariable(newid);
  }
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
EventAssignment::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
}

/** @cond doxygenLibsbmlInternal */
void 
EventAssignment::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
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
void 
EventAssignment::divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  if (mVariable == id && isSetMath()) {
    ASTNode* temp = mMath;
    mMath = new ASTNode(AST_DIVIDE);
    mMath->addChild(temp);
    mMath->addChild(function->deepCopy());
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
EventAssignment::multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  if (mVariable == id && isSetMath()) {
    ASTNode* temp = mMath;
    mMath = new ASTNode(AST_TIMES);
    mMath->addChild(temp);
    mMath->addChild(function->deepCopy());
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
EventAssignment::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if (mMath != NULL) writeMathML(mMath, stream, getSBMLNamespaces());

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
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
EventAssignment::readOtherXML (XMLInputStream& stream)
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
        logError(OneMathPerEventAssignment, getLevel(), getVersion());
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
EventAssignment::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("variable");

  const unsigned int level   = getLevel();
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
EventAssignment::readAttributes (const XMLAttributes& attributes,
                                 const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "EventAssignment is not a valid component for this level/version.");
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
EventAssignment::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();
  //
  // variable: SId  { use="required" }  (L2v1 ->)
  //
  bool assigned = attributes.readInto("variable", mVariable, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mVariable.size() == 0)
  {
    logEmptyString("variable", level, version, "<eventAssignment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mVariable)) 
    logError(InvalidIdSyntax, getLevel(), getVersion(), 
    "The syntax of the attribute variable='" + mVariable + "' does not conform.");


  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2 ->)
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
EventAssignment::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  //
  // variable: SId  { use="required" }  (L2v1 ->)
  //
  bool assigned = attributes.readInto("variable", mVariable, getErrorLog(), false, getLine(), getColumn());
  if (!assigned)
  {
    logError(AllowedAttributesOnEventAssignment, level, version, 
      "The required attribute 'variable' is missing.");
  }
  if (assigned && mVariable.size() == 0)
  {
    logEmptyString("variable", level, version, "<eventAssignment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mVariable)) logError(InvalidIdSyntax);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
EventAssignment::writeAttributes (XMLOutputStream& stream) const
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  /* invalid level/version */
  if (level < 2)
  {
    return;
  }

  SBase::writeAttributes(stream);

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2 ->)
  //
  // sboTerm for L2V3 or later is written in SBase::writeAttributes()
  //
  if ( (level == 2) && (version == 2) )
  {
    SBO::writeTerm(stream, mSBOTerm);
  }

  //
  // variable: SId  { use="required" }  (L2v1 ->)
  //
  stream.writeAttribute("variable", mVariable);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Creates a new ListOfEventAssignments items.
 */
ListOfEventAssignments::ListOfEventAssignments (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfEventAssignments items.
 */
ListOfEventAssignments::ListOfEventAssignments (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfEventAssignments.
 */
ListOfEventAssignments*
ListOfEventAssignments::clone () const
{
  return new ListOfEventAssignments(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfEventAssignments::getItemTypeCode () const
{
  return SBML_EVENT_ASSIGNMENT;
}


/*
 * @return the name of this element ie "listOfEventAssignments".
 */
const string&
ListOfEventAssignments::getElementName () const
{
  static const string name = "listOfEventAssignments";
  return name;
}


/* return nth item in list */
EventAssignment *
ListOfEventAssignments::get(unsigned int n)
{
  return static_cast<EventAssignment*>(ListOf::get(n));
}


/* return nth item in list */
const EventAssignment *
ListOfEventAssignments::get(unsigned int n) const
{
  return static_cast<const EventAssignment*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqEA : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqEA (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <EventAssignment *> (sb)->getVariable() == id; }
};


/* return item by id */
EventAssignment*
ListOfEventAssignments::get (const std::string& sid)
{
  return const_cast<EventAssignment*>( 
    static_cast<const ListOfEventAssignments&>(*this).get(sid) );
}


/* return item by id */
const EventAssignment*
ListOfEventAssignments::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqEA(sid) );
    return (result == mItems.end()) ? NULL : 
                      static_cast <EventAssignment*> (*result);
  }
}


/* Removes the nth item from this list */
EventAssignment*
ListOfEventAssignments::remove (unsigned int n)
{
   return static_cast<EventAssignment*>(ListOf::remove(n));
}


/* Removes item in this list by id */
EventAssignment*
ListOfEventAssignments::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqEA(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <EventAssignment*> (item);
}


SBase*
ListOfEventAssignments::getElementBySId(const std::string& id)
{
  for (unsigned int i = 0; i < size(); i++)
  {
    SBase* obj = get(i);
    //Event Assignments are not in the SId namespace, so don't check 'getId'.  However, their children (through plugins) may have the element we are looking for, so we still need to check all of them.
    obj = obj->getElementBySId(id);
    if (obj != NULL) return obj;
  }

  return getElementFromPluginsBySId(id);
}
  
/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its
 * siblings or -1 (default) to indicate the position is not significant.
 */
int
ListOfEventAssignments::getElementPosition () const
{
  return 3;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfEventAssignments::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "eventAssignment")
  {
    try
    {
      object = new EventAssignment(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new EventAssignment(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new EventAssignment(SBMLDocument::getDefaultLevel(),
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
EventAssignment_t *
EventAssignment_create (unsigned int level, unsigned int version)
{
  try
  {
    EventAssignment* obj = new EventAssignment(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
EventAssignment_t *
EventAssignment_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    EventAssignment* obj = new EventAssignment(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
EventAssignment_free (EventAssignment_t *ea)
{
  if (ea != NULL)
  delete ea;
}


LIBSBML_EXTERN
EventAssignment_t *
EventAssignment_clone (const EventAssignment_t *ea)
{
  return (ea != NULL) ? static_cast<EventAssignment*>( ea->clone() ) : NULL;
}


LIBSBML_EXTERN
const XMLNamespaces_t *
EventAssignment_getNamespaces(EventAssignment_t *ea)
{
  return (ea != NULL) ? ea->getNamespaces() : NULL;
}


LIBSBML_EXTERN
const char *
EventAssignment_getVariable (const EventAssignment_t *ea)
{
  return (ea != NULL && ea->isSetVariable()) ? ea->getVariable().c_str() : NULL;
}


LIBSBML_EXTERN
const ASTNode_t *
EventAssignment_getMath (const EventAssignment_t *ea)
{
  return (ea != NULL) ? ea->getMath() : NULL;
}


LIBSBML_EXTERN
int
EventAssignment_isSetVariable (const EventAssignment_t *ea)
{
  return (ea != NULL) ? static_cast<int>( ea->isSetVariable() ) : 0;
}


LIBSBML_EXTERN
int
EventAssignment_isSetMath (const EventAssignment_t *ea)
{
  return (ea != NULL) ? static_cast<int>( ea->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
EventAssignment_setVariable (EventAssignment_t *ea, const char *sid)
{
  if (ea != NULL)  
    return ea->setVariable((sid != NULL) ? sid : "");
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
EventAssignment_setMath (EventAssignment_t *ea, const ASTNode_t *math)
{
  if (ea != NULL)
    return ea->setMath(math);
  else
    return LIBSBML_INVALID_OBJECT;
}

LIBSBML_EXTERN
UnitDefinition_t * 
EventAssignment_getDerivedUnitDefinition(EventAssignment_t *ea)
{
  return (ea != NULL) ? ea->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
int 
EventAssignment_containsUndeclaredUnits(EventAssignment_t *ea)
{
  return (ea != NULL) ? static_cast<int>(ea->containsUndeclaredUnits()) : 0;
}


LIBSBML_EXTERN
EventAssignment_t *
ListOfEventAssignments_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfEventAssignments *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
EventAssignment_t *
ListOfEventAssignments_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfEventAssignments *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

