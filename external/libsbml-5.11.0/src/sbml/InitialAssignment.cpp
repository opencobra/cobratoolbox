/**
 * @file    InitialAssignment.cpp
 * @brief   Implementation of InitialAssignment and ListOfInitialAssignments.
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
#include <sbml/InitialAssignment.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

InitialAssignment::InitialAssignment (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mSymbol ( "" )
 , mMath   ( NULL      )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


InitialAssignment::InitialAssignment (SBMLNamespaces * sbmlns) :
   SBase ( sbmlns )
 , mSymbol ( "" )
 , mMath   ( NULL      )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
}


/*
 * Destroys this InitialAssignment.
 */
InitialAssignment::~InitialAssignment ()
{
  if(mMath != NULL) delete mMath;
}


/*
 * Copy constructor. Creates a copy of this InitialAssignment.
 */
InitialAssignment::InitialAssignment (const InitialAssignment& orig) :
   SBase   ( orig )
 , mMath   ( NULL    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mSymbol  = orig.mSymbol;

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
InitialAssignment& InitialAssignment::operator=(const InitialAssignment& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    this->mSymbol = rhs.mSymbol;

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
 * whether or not the Visitor would like to visit the Model's next
 * InitialAssignment (if available).
 */
bool
InitialAssignment::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this InitialAssignment.
 */
InitialAssignment*
InitialAssignment::clone () const
{
  return new InitialAssignment(*this);
}


/*
 * @return the symbol for this InitialAssignment.
 */
const string&
InitialAssignment::getSymbol () const
{
  return mSymbol;
}


/** @cond doxygenLibsbmlInternal */
/**
 * @return the string of symbol attribute of this object.
 * 
 * @note this function is an alias for getSymbol()
 * 
 * @see getSymbol()
 */
const std::string& 
InitialAssignment::getId() const
{
  return getSymbol();
}
/** @endcond */


/*
 * @return the math for this InitialAssignment.
 */
const ASTNode*
InitialAssignment::getMath () const
{
  return mMath;
}


/*
 * @return true if the symbol of this InitialAssignment is set,
 * false otherwise.
 */
bool
InitialAssignment::isSetSymbol () const
{
  return (mSymbol.empty() == false);
}


/*
 * @return true if the math for this InitialAssignment is set,
 * false otherwise.
 */
bool
InitialAssignment::isSetMath () const
{
  return (mMath != NULL);
}


/*
 * Sets the symbol of this InitialAssignment to a copy of sid.
 */
int
InitialAssignment::setSymbol (const std::string& sid)
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
    mSymbol = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the math of this InitialAssignment to a copy of the given
 * ASTNode.
 */
int
InitialAssignment::setMath (const ASTNode* math)
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
  * returned by the math expression of this InitialAssignment.
  */
UnitDefinition * 
InitialAssignment::getDerivedUnitDefinition()
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
    
    if (m->getFormulaUnitsData(getId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getId(), getTypeCode())
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
InitialAssignment::getDerivedUnitDefinition() const
{
  return const_cast <InitialAssignment *> (this)->getDerivedUnitDefinition();
}


/*
 * Predicate returning @c true if 
 * the math expression of this InitialAssignment contains
 * parameters/numbers with undeclared units that cannot be ignored.
 */
bool 
InitialAssignment::containsUndeclaredUnits()
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
    
    if (m->getFormulaUnitsData(getId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getId(), getTypeCode())
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
InitialAssignment::containsUndeclaredUnits() const
{
  return const_cast<InitialAssignment *> (this)->containsUndeclaredUnits();
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
InitialAssignment::getTypeCode () const
{
  return SBML_INITIAL_ASSIGNMENT;
}


/*
 * @return the name of this element ie "initialAssignment".
 */
const string&
InitialAssignment::getElementName () const
{
  static const string name = "initialAssignment";
  return name;
}


bool 
InitialAssignment::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for initialAssignment: symbol */

  if (!isSetSymbol())
    allPresent = false;

  return allPresent;
}


bool 
InitialAssignment::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for initialAssignment: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}


void
InitialAssignment::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (mSymbol == oldid) {
    setSymbol(newid);
  }
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
InitialAssignment::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
}

/** @cond doxygenLibsbmlInternal */
void 
InitialAssignment::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
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
InitialAssignment::divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  if (mSymbol == id && isSetMath()) {
    ASTNode* temp = mMath;
    mMath = new ASTNode(AST_DIVIDE);
    mMath->addChild(temp);
    mMath->addChild(function->deepCopy());
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
InitialAssignment::multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  if (mSymbol == id && isSetMath()) {
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
InitialAssignment::writeElements (XMLOutputStream& stream) const
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
InitialAssignment::readOtherXML (XMLInputStream& stream)
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
        logError(OneMathElementPerInitialAssign, getLevel(), getVersion(),
          "The <initialAssignment> with symbol '" + getSymbol() + 
          "' contains more than one <math> element.");
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
InitialAssignment::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("symbol");

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  if (level == 2 && version == 2)
    attributes.add("sboTerm");
}

/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
InitialAssignment::readAttributes (const XMLAttributes& attributes,
                                   const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "InitialAssignment is not a valid component for this level/version.");
    break;
  case 2:
    if (version == 1)
    {
      logError(NotSchemaConformant, level, version,
	        "InitialAssignment is not a valid component for this level/version.");
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
InitialAssignment::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // symbol: SId  { use="required" }  (L2v2 -> )
  //
  bool assigned = attributes.readInto("symbol", mSymbol, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mSymbol.size() == 0)
  {
    logEmptyString("symbol", level, version, "<initialAssignment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mSymbol)) 
        logError(InvalidIdSyntax, getLevel(), getVersion(), 
        "The syntax of the attribute symbol='" + mSymbol + "' does not conform.");

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
InitialAssignment::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // symbol: SId  { use="required" }  (L2v2 -> )
  //
  bool assigned = attributes.readInto("symbol", mSymbol, getErrorLog(), false, getLine(), getColumn());
  if (!assigned)
  {
    logError(AllowedAttributesOnInitialAssign, level, version, 
      "The required attribute 'symbol' is missing.");
  }
  if (assigned && mSymbol.size() == 0)
  {
    logEmptyString("symbol", level, version, "<initialAssignment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mSymbol)) 
    logError(InvalidIdSyntax, getLevel(), getVersion(), 
    "The syntax of the attribute symbol='" + mSymbol + "' does not conform.");

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
InitialAssignment::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2)
  //
  // sboTerm for L2V3 or later is written in SBase::writeAttributes()
  //
  if ( (level == 2) && (version == 2) )
  {
    SBO::writeTerm(stream, mSBOTerm);
  }

  //
  // symbol: SId  { use="required" }  (L2v2)
  //
  stream.writeAttribute("symbol", mSymbol);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Creates a new ListOfInitialAssignments items.
 */
ListOfInitialAssignments::ListOfInitialAssignments (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfInitialAssignments items.
 */
ListOfInitialAssignments::ListOfInitialAssignments (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfInitialAssignments.
 */
ListOfInitialAssignments*
ListOfInitialAssignments::clone () const
{
  return new ListOfInitialAssignments(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfInitialAssignments::getItemTypeCode () const
{
  return SBML_INITIAL_ASSIGNMENT;
}


/*
 * @return the name of this element ie "listOfInitialAssignments".
 */
const string&
ListOfInitialAssignments::getElementName () const
{
  static const string name = "listOfInitialAssignments";
  return name;
}


/* return nth item in list */
InitialAssignment *
ListOfInitialAssignments::get(unsigned int n)
{
  return static_cast<InitialAssignment*>(ListOf::get(n));
}


/* return nth item in list */
const InitialAssignment *
ListOfInitialAssignments::get(unsigned int n) const
{
  return static_cast<const InitialAssignment*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqIA : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqIA (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <InitialAssignment *> (sb)->getId() == id; }
};


/* return item by id */
InitialAssignment*
ListOfInitialAssignments::get (const std::string& sid)
{
  return const_cast<InitialAssignment*>( 
    static_cast<const ListOfInitialAssignments&>(*this).get(sid) );
}


/* return item by id */
const InitialAssignment*
ListOfInitialAssignments::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqIA(sid) );
    return (result == mItems.end()) ? NULL : 
                                static_cast <InitialAssignment*> (*result);
  }
}


/* Removes the nth item from this list */
InitialAssignment*
ListOfInitialAssignments::remove (unsigned int n)
{
   return static_cast<InitialAssignment*>(ListOf::remove(n));
}


/* Removes item in this list by id */
InitialAssignment*
ListOfInitialAssignments::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqIA(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <InitialAssignment*> (item);
}


SBase*
ListOfInitialAssignments::getElementBySId(const std::string& id)
{
  for (unsigned int i = 0; i < size(); i++)
  {
    SBase* obj = get(i);
    //Initial assignments are not in the SId namespace, so don't check 'getId'.  However, their children (through plugins) may have the element we are looking for, so we still need to check all of them.
    obj = obj->getElementBySId(id);
    if (obj != NULL) return obj;
  }

  return getElementFromPluginsBySId(id);
}
  
/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfInitialAssignments::getElementPosition () const
{
  return 8;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfInitialAssignments::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "initialAssignment")
  {
    try
    {
      object = new InitialAssignment(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new InitialAssignment(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new InitialAssignment(SBMLDocument::getDefaultLevel(),
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
InitialAssignment_t *
InitialAssignment_create (unsigned int level, unsigned int version)
{
  try
  {
    InitialAssignment* obj = new InitialAssignment(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
InitialAssignment_t *
InitialAssignment_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    InitialAssignment* obj = new InitialAssignment(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
InitialAssignment_free (InitialAssignment_t *ia)
{
  if (ia != NULL)
  delete ia;
}


LIBSBML_EXTERN
InitialAssignment_t *
InitialAssignment_clone (const InitialAssignment_t *ia)
{
  return (ia != NULL) ? static_cast<InitialAssignment*>( ia->clone() ) : NULL;
}


LIBSBML_EXTERN
const XMLNamespaces_t *
InitialAssignment_getNamespaces(InitialAssignment_t *ia)
{
  return (ia != NULL) ? ia->getNamespaces() : NULL;
}


LIBSBML_EXTERN
const char *
InitialAssignment_getSymbol (const InitialAssignment_t *ia)
{
  return (ia != NULL && ia->isSetSymbol()) ? ia->getSymbol().c_str() : NULL;
}


LIBSBML_EXTERN
const ASTNode_t *
InitialAssignment_getMath (const InitialAssignment_t *ia)
{
  return (ia != NULL) ? ia->getMath() : NULL;
}


LIBSBML_EXTERN
int
InitialAssignment_isSetSymbol (const InitialAssignment_t *ia)
{
  return (ia != NULL) ? static_cast<int>( ia->isSetSymbol() ) : 0;
}


LIBSBML_EXTERN
int
InitialAssignment_isSetMath (const InitialAssignment_t *ia)
{
  return (ia != NULL) ? static_cast<int>( ia->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
InitialAssignment_setSymbol (InitialAssignment_t *ia, const char *sid)
{
  if (ia != NULL)
    return ia->setSymbol((sid != NULL) ? sid : "");
  return
    LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
InitialAssignment_setMath (InitialAssignment_t *ia, const ASTNode_t *math)
{
  if (ia != NULL)
    return ia->setMath(math);
  else
    return LIBSBML_INVALID_OBJECT;
}

LIBSBML_EXTERN
UnitDefinition_t * 
InitialAssignment_getDerivedUnitDefinition(InitialAssignment_t *ia)
{
  return (ia != NULL) ? ia->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
int 
InitialAssignment_containsUndeclaredUnits(InitialAssignment_t *ia)
{
  return (ia != NULL) ? static_cast<int>(ia->containsUndeclaredUnits()) : 0;
}


LIBSBML_EXTERN
InitialAssignment_t *
ListOfInitialAssignments_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfInitialAssignments *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
InitialAssignment_t *
ListOfInitialAssignments_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfInitialAssignments *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
