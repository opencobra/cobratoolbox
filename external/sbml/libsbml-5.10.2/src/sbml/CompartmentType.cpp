/**
 * @file    CompartmentType.cpp
 * @brief   Implementation of CompartmentType and ListOfCompartmentTypes.
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

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/CompartmentType.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

CompartmentType::CompartmentType (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mId   ( "" )
 , mName ( "" )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();
}


CompartmentType::CompartmentType (SBMLNamespaces* sbmlns) :
   SBase ( sbmlns )
 , mId   ( "" )
 , mName ( "" )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
}

                          
/*
 * Destroys this CompartmentType.
 */
CompartmentType::~CompartmentType ()
{
}


/*
 * Copy constructor. Creates a copy of this CompartmentType.
 */
CompartmentType::CompartmentType(const CompartmentType& orig) :
   SBase             ( orig                    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mId               = orig.mId;
    mName             = orig.mName;
  }

}


/*
 * Assignment operator
 */
CompartmentType& CompartmentType::operator=(const CompartmentType& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mId = rhs.mId;
    mName = rhs.mName;
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Model's next
 * CompartmentType (if available).
 */
bool
CompartmentType::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this CompartmentType.
 */
CompartmentType*
CompartmentType::clone () const
{
  return new CompartmentType(*this);
}


/*
 * @return the id of this SBML object.
 */
const string&
CompartmentType::getId () const
{
  return mId;
}


/*
 * @return the name of this SBML object.
 */
const string&
CompartmentType::getName () const
{
  return (getLevel() == 1) ? mId : mName;
}


/*
 * @return true if the id of this SBML object is set, false
 * otherwise.
 */
bool
CompartmentType::isSetId () const
{
  return (mId.empty() == false);
}


/*
 * @return true if the name of this SBML object is set, false
 * otherwise.
 */
bool
CompartmentType::isSetName () const
{
  return (getLevel() == 1) ? (mId.empty() == false) : 
                            (mName.empty() == false);
}


/*
 * Sets the id of this SBML object to a copy of sid.
 */
int
CompartmentType::setId (const std::string& sid)
{
  /* since the setId function has been used as an
   * alias for setName we cant require it to only
   * be used on a L2 model
   */
/*  if (getLevel() == 1)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
*/
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
    mId = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the name of this SBML object to a copy of name.
 */
int
CompartmentType::setName (const std::string& name)
{
  /* if this is setting an L2 name the type is string
   * whereas if it is setting an L1 name its type is SId
   */
  if (&(name) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (getLevel() == 1)
  {
    if (!(SyntaxChecker::isValidInternalSId(name)))
    {
      return LIBSBML_INVALID_ATTRIBUTE_VALUE;
    }
    else
    {
      mId = name;
      return LIBSBML_OPERATION_SUCCESS;
    }
  }
  else
  {
    mName = name;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Unsets the name of this SBML object.
 */
int
CompartmentType::unsetName ()
{
  if (getLevel() == 1) 
  {
    mId.erase();
  }
  else 
  {
    mName.erase();
  }

  if (getLevel() == 1 && mId.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (mName.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
CompartmentType::getTypeCode () const
{
  return SBML_COMPARTMENT_TYPE;
}


/*
 * @return the name of this element ie "compartmentType".
 */
const string&
CompartmentType::getElementName () const
{
  static const string name = "compartmentType";
  return name;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
CompartmentType::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
  /** @endcond */


bool 
CompartmentType::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for compartmentType: id */

  if (!isSetId())
    allPresent = false;

  return allPresent;
}


/** @cond doxygenLibsbmlInternal */

/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
CompartmentType::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("name");
  attributes.add("id");
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
CompartmentType::readAttributes (const XMLAttributes& attributes,
                                 const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    logError(NotSchemaConformant, level, version,
	      "CompartmentType is not a valid component for this level/version.");
    break;
  case 2:
    if (version == 1)
    {
      logError(NotSchemaConformant, level, version,
	        "CompartmentType is not a valid component for this level/version.");
    }
    else
    {
      readL2Attributes(attributes);
    }
    break;
  case 3:
  default:
    logError(NotSchemaConformant, level, version,
	      "CompartmentType is not a valid component for this level/version.");
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
CompartmentType::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // id: SId  { use="required" }  (L2v2 ->)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<compartmentType>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // name: string  { use="optional" }  (L2v2 ->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
CompartmentType::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  /* invalid level/version */
  if (level < 2 || (level == 2 && version == 1))
  {
    return;
  }

  //
  // id: SId  { use="required" }  (L2v2 ->)
  //
  stream.writeAttribute("id", mId);

  //
  // name: string  { use="optional" }  (L2v2 ->)
  //
  stream.writeAttribute("name", mName);
  //
  // sboTerm: SBOTerm { use="optional" }  (L2v3 ->)
  // is written in SBase::writeAttributes()
  //

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Creates a new ListOfCompartmentTypes items.
 */
ListOfCompartmentTypes::ListOfCompartmentTypes (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfCompartmentTypes items.
 */
ListOfCompartmentTypes::ListOfCompartmentTypes (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfCompartmentTypes.
 */
ListOfCompartmentTypes*
ListOfCompartmentTypes::clone () const
{
  return new ListOfCompartmentTypes(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfCompartmentTypes::getItemTypeCode () const
{
  return SBML_COMPARTMENT_TYPE;
}


/*
 * @return the name of this element ie "listOfCompartmentTypes".
 */
const string&
ListOfCompartmentTypes::getElementName () const
{
  static const string name = "listOfCompartmentTypes";
  return name;
}


/* return nth item in list */
CompartmentType *
ListOfCompartmentTypes::get(unsigned int n)
{
  return static_cast<CompartmentType*>(ListOf::get(n));
}


/* return nth item in list */
const CompartmentType *
ListOfCompartmentTypes::get(unsigned int n) const
{
  return static_cast<const CompartmentType*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqCT : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqCT (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <CompartmentType *> (sb)->getId() == id; }
};


/* return item by id */
CompartmentType*
ListOfCompartmentTypes::get (const std::string& sid)
{
  return const_cast<CompartmentType*>( 
    static_cast<const ListOfCompartmentTypes&>(*this).get(sid) );
}


/* return item by id */
const CompartmentType*
ListOfCompartmentTypes::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqCT(sid) );
    return (result == mItems.end()) ? NULL : 
                      static_cast <CompartmentType*> (*result);
  }
}


/* Removes the nth item from this list */
CompartmentType*
ListOfCompartmentTypes::remove (unsigned int n)
{
   return static_cast<CompartmentType*>(ListOf::remove(n));
}


/* Removes item in this list by id */
CompartmentType*
ListOfCompartmentTypes::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqCT(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <CompartmentType*> (item);
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfCompartmentTypes::getElementPosition () const
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
ListOfCompartmentTypes::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "compartmentType")
  {
    try
    {
      object = new CompartmentType(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      // compartment type does not exist in L3
      object = new CompartmentType(2,4);
    }
    catch ( ... )
    {
      // compartment type does not exist in l3
      object = new CompartmentType(2,4);
    }
    
    if (object !=NULL) mItems.push_back(object);
  }

  return object;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_create (unsigned int level, unsigned int version)
{
  try
  {
    CompartmentType* obj = new CompartmentType(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    CompartmentType* obj = new CompartmentType(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
CompartmentType_free (CompartmentType_t *ct)
{
  if (ct != NULL)
  delete ct;
}


LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_clone (const CompartmentType_t *ct)
{
  if (ct != NULL)
  {
    return static_cast<CompartmentType*>( ct->clone() );
  }
  else
  {
    return NULL;
  }
}


LIBSBML_EXTERN
const XMLNamespaces_t *
CompartmentType_getNamespaces(CompartmentType_t *ct)
{
  if (ct != NULL)
  {
    return ct->getNamespaces();
  }
  else
  {
    return NULL;
  }
}

LIBSBML_EXTERN
const char *
CompartmentType_getId (const CompartmentType_t *ct)
{
  return (ct != NULL && ct->isSetId()) ? ct->getId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
CompartmentType_getName (const CompartmentType_t *ct)
{
  return (ct != NULL && ct->isSetName()) ? ct->getName().c_str() : NULL;
}


LIBSBML_EXTERN
int
CompartmentType_isSetId (const CompartmentType_t *ct)
{
  return (ct != NULL) ? static_cast<int>( ct->isSetId() ) : 0;
}


LIBSBML_EXTERN
int
CompartmentType_isSetName (const CompartmentType_t *ct)
{
  return (ct != NULL) ? static_cast<int>( ct->isSetName() ) : 0;
}


LIBSBML_EXTERN
int
CompartmentType_setId (CompartmentType_t *ct, const char *sid)
{
  if (ct != NULL)
    return (sid == NULL) ? ct->setId("") : ct->setId(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
CompartmentType_setName (CompartmentType_t *ct, const char *name)
{
  if (ct != NULL)
    return (name == NULL) ? ct->unsetName() : ct->setName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
CompartmentType_unsetName (CompartmentType_t *ct)
{
  if (ct != NULL)
    return ct->unsetName();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
CompartmentType_t *
ListOfCompartmentTypes_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL) 
    return (sid != NULL) ? 
      static_cast <ListOfCompartmentTypes *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
CompartmentType_t *
ListOfCompartmentTypes_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfCompartmentTypes *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
