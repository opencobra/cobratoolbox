/**
 * @file    LocalParameter.cpp
 * @brief   Implementations of LocalLocalParameter and ListOfLocalLocalParameters.
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <limits>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/KineticLaw.h>
#include <sbml/LocalParameter.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

LocalParameter::LocalParameter (unsigned int level, unsigned int version) :
   Parameter ( level, version )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  // if level 3 values have no defaults
  if (level == 3)
  {
    mValue = numeric_limits<double>::quiet_NaN();
  }
}


LocalParameter::LocalParameter (SBMLNamespaces * sbmlns) :
   Parameter ( sbmlns )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);

  // if level 3 values have no defaults
  if (sbmlns->getLevel() == 3)
  {
    mValue = numeric_limits<double>::quiet_NaN();
  }
}


/*
 * Destroys this LocalParameter.
 */
LocalParameter::~LocalParameter ()
{
}


/*
 * Copy constructor. Creates a copy of this LocalParameter.
 */
LocalParameter::LocalParameter(const LocalParameter& orig) :
    Parameter      ( orig             )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
}


/*
 * Copy constructor. Creates a copy of this LocalParameter.
 */
LocalParameter::LocalParameter(const Parameter& orig) :
    Parameter      ( orig             )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
}
/*
 * Assignment operator.
 */
LocalParameter& LocalParameter::operator=(const LocalParameter& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->Parameter::operator =(rhs);
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the parent Model's or
 * KineticLaw's next LocalParameter (if available).
 */
bool
LocalParameter::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this LocalParameter.
 */
LocalParameter*
LocalParameter::clone () const
{
  return new LocalParameter(*this);
}


/* a local Parameter does not have a constant attribute but
 * because it derives from parameter it inherits one
 * need to make sure these do the right thing
 */

/** @cond doxygenLibsbmlInternal */
/*
 * @return true as a localParameter is always constant.
 */
bool
LocalParameter::getConstant () const
{
  return true;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return false as a local parameter does not have this attribute
 */
bool
LocalParameter::isSetConstant () const
{
  return false;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the constant field of this Parameter to value.
 */
int
LocalParameter::setConstant (bool flag)
{
  return LIBSBML_UNEXPECTED_ATTRIBUTE;
}
/** @endcond */


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * LocalParameter.
  */
UnitDefinition *
LocalParameter::getDerivedUnitDefinition()
{
  return Parameter::getDerivedUnitDefinition();
}


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * Compartment.
  */
const UnitDefinition *
LocalParameter::getDerivedUnitDefinition() const
{
  return const_cast <LocalParameter *> (this)->getDerivedUnitDefinition();
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
LocalParameter::getTypeCode () const
{
  return SBML_LOCAL_PARAMETER;
}


/*
 * @return the name of this element ie "localparameter".
 */
const string&
LocalParameter::getElementName () const
{
  static const string name = "localParameter";
  return name;
}


bool 
LocalParameter::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for parameter: id (name in L1)
   * and value (in L1V1 only)*/

  if (!isSetId())
    allPresent = false;

  if (getLevel() == 1
    && getVersion() == 1
    && !isSetValue())
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
LocalParameter::addExpectedAttributes(ExpectedAttributes& attributes)
{
  Parameter::addExpectedAttributes(attributes);
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 *
 * @param attributes the XMLAttributes object to use
 */
void
LocalParameter::readAttributes (const XMLAttributes& attributes,
                                const ExpectedAttributes& expectedAttributes)
{
  Parameter::readAttributes(attributes,expectedAttributes);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 *
 * @param stream the XMLOutputStream to use
 */
void
LocalParameter::writeAttributes (XMLOutputStream& stream) const
{
  Parameter::writeAttributes(stream);
}
/** @endcond */


/*
 * Creates a new ListOfLocalParameters items.
 */
ListOfLocalParameters::ListOfLocalParameters (unsigned int level, unsigned int version)
  : ListOfParameters(level,version)
{
}


/*
 * Creates a new ListOfLocalParameters items.
 */
ListOfLocalParameters::ListOfLocalParameters (SBMLNamespaces* sbmlns)
  : ListOfParameters(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfLocalParameters.
 */
ListOfLocalParameters*
ListOfLocalParameters::clone () const
{
  return new ListOfLocalParameters(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfLocalParameters::getItemTypeCode () const
{
  return SBML_LOCAL_PARAMETER;
}


/*
 * @return the name of this element ie "listOfLocalParameters".
 */
const string&
ListOfLocalParameters::getElementName () const
{
  static const string name = "listOfLocalParameters";
  return name;
}


/* return nth item in list */
LocalParameter *
ListOfLocalParameters::get(unsigned int n)
{
  return static_cast<LocalParameter*>(ListOf::get(n));
}


/* return nth item in list */
const LocalParameter *
ListOfLocalParameters::get(unsigned int n) const
{
  return static_cast<const LocalParameter*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqP : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqP (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <LocalParameter *> (sb)->getId() == id; }
};


/* return item by id */
LocalParameter*
ListOfLocalParameters::get (const std::string& sid)
{
  return const_cast<LocalParameter*>( 
    static_cast<const ListOfLocalParameters&>(*this).get(sid) );
}


/* return item by id */
const LocalParameter*
ListOfLocalParameters::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqP(sid) );
    return (result == mItems.end()) ? NULL : 
                             static_cast <LocalParameter*> (*result);
  }
}


SBase*
ListOfLocalParameters::getElementBySId(const std::string& id)
{
  for (unsigned int i = 0; i < size(); i++)
  {
    SBase* obj = get(i);
    //LocalParameters are not in the SId namespace, so don't check 'getId'.  However, their children (through plugins) may have the element we are looking for, so we still need to check all of them.
    obj = obj->getElementBySId(id);
    if (obj != NULL) return obj;
  }

  return getElementFromPluginsBySId(id);
}
  
/* Removes the nth item from this list */
LocalParameter*
ListOfLocalParameters::remove (unsigned int n)
{
   return static_cast<LocalParameter*>(ListOf::remove(n));
}


/* Removes item in this list by id */
LocalParameter*
ListOfLocalParameters::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqP(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <LocalParameter*> (item);
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfLocalParameters::getElementPosition () const
{
  return 7;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 *
 * @param stream the XMLInputStream to use
 */
SBase*
ListOfLocalParameters::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "localParameter")
  {
    try
    {
      object = new LocalParameter(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new LocalParameter(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new LocalParameter(SBMLDocument::getDefaultLevel(),
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
LocalParameter_t *
LocalParameter_create (unsigned int level, unsigned int version)
{
  try
  {
    LocalParameter* obj = new LocalParameter(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
LocalParameter_t *
LocalParameter_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    LocalParameter* obj = new LocalParameter(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
LocalParameter_free (LocalParameter_t *p)
{
  if (p != NULL)
  delete p;
}


LIBSBML_EXTERN
LocalParameter_t *
LocalParameter_clone (const LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<LocalParameter_t*>( p->clone() ) : NULL;
}


LIBSBML_EXTERN
void
LocalParameter_initDefaults (LocalParameter_t *p)
{
  return;
}

LIBSBML_EXTERN
const XMLNamespaces_t *
LocalParameter_getNamespaces(LocalParameter_t *p)
{
  return (p != NULL) ? p->getNamespaces() : NULL;
}

LIBSBML_EXTERN
const char *
LocalParameter_getId (const LocalParameter_t *p)
{
  return (p != NULL && p->isSetId()) ? p->getId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
LocalParameter_getName (const LocalParameter_t *p)
{
  return (p != NULL && p->isSetName()) ? p->getName().c_str() : NULL;
}


LIBSBML_EXTERN
double
LocalParameter_getValue (const LocalParameter_t *p)
{
  return (p != NULL) ? p->getValue() : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
const char *
LocalParameter_getUnits (const LocalParameter_t *p)
{
  return (p != NULL && p->isSetUnits()) ? p->getUnits().c_str() : NULL;
}


LIBSBML_EXTERN
int
LocalParameter_getConstant (const LocalParameter_t *p)
{
  return (p != NULL) ?  static_cast<int>( p->getConstant() ) : 0;
}


LIBSBML_EXTERN
int
LocalParameter_isSetId (const LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetId() ) : 0;
}


LIBSBML_EXTERN
int
LocalParameter_isSetName (const LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetName() ) : 0;
}


LIBSBML_EXTERN
int
LocalParameter_isSetValue (const LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetValue() ) : 0;
}


LIBSBML_EXTERN
int
LocalParameter_isSetUnits (const LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetUnits() ) : 0;
}


LIBSBML_EXTERN
int
LocalParameter_setId (LocalParameter_t *p, const char *sid)
{
  if (p != NULL)
    return (sid == NULL) ? p->setId("") : p->setId(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_setName (LocalParameter_t *p, const char *name)
{
  if (p != NULL)
    return (name == NULL) ? p->unsetName() : p->setName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_setValue (LocalParameter_t *p, double value)
{
  if (p != NULL)
    return p->setValue(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_setUnits (LocalParameter_t *p, const char *units)
{
  if (p != NULL)
    return (units == NULL) ? p->unsetUnits() : p->setUnits(units);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_setConstant (LocalParameter_t *p, int value)
{
  if (p != NULL)
    return p->setConstant( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}

LIBSBML_EXTERN
int
LocalParameter_unsetName (LocalParameter_t *p)
{
  if (p != NULL)
    return p->unsetName();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_unsetValue (LocalParameter_t *p)
{
  if (p != NULL)
    return p->unsetValue();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_unsetUnits (LocalParameter_t *p)
{
  if (p != NULL)
    return p->unsetUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
LocalParameter_hasRequiredAttributes(LocalParameter_t *p)
{
  return (p != NULL) ? static_cast<int>(p->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
UnitDefinition_t * 
LocalParameter_getDerivedUnitDefinition(LocalParameter_t *p)
{
  return (p != NULL) ? p->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
ListOfLocalParameters_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfLocalParameters *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
ListOfLocalParameters_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfLocalParameters *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END
