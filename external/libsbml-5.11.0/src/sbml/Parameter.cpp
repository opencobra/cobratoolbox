/**
 * @file    Parameter.cpp
 * @brief   Implementations of Parameter and ListOfParameters.
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
#include <sbml/Parameter.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Parameter::Parameter (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mId        ( ""       )
 , mName      ( ""       )
 , mValue     ( 0.0      )
 , mUnits     ( ""       )
 , mConstant  ( true     )
 , mIsSetValue( false    )
 , mIsSetConstant (false )
 , mExplicitlySetConstant ( false )
 , mCalculatingUnits (false)
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  // if level 3 values have no defaults
  if (level == 3)
  {
    mValue = numeric_limits<double>::quiet_NaN();
  }
  // in level 2 constant was set by default
  if (level == 2)
  {
    mIsSetConstant = true;
  }
}


Parameter::Parameter (SBMLNamespaces * sbmlns) :
   SBase      ( sbmlns   )
 , mId        ( ""       )
 , mName      ( ""       )
 , mValue     ( 0.0      )
 , mUnits     ( ""       )
 , mConstant  ( true     )
 , mIsSetValue( false    )
 , mIsSetConstant (false )
 , mExplicitlySetConstant ( false )
 , mCalculatingUnits (false)
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
  // in level 2 constant was set by default
  if (sbmlns->getLevel() == 2)
  {
    mIsSetConstant = true;
  }
}


/** @cond doxygenLibsbmlInternal */
Parameter::Parameter (SBMLNamespaces * sbmlns, bool isLocal) :
   SBase      ( sbmlns   )
 , mId        ( ""       )
 , mName      ( ""       )
 , mValue     ( 0.0      )
 , mUnits     ( ""       )
 , mConstant  ( true     )
 , mIsSetValue( false    )
 , mIsSetConstant (false )
 , mExplicitlySetConstant ( false )
 , mCalculatingUnits (false)
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  // we are creating a L3 LocalParameter so L3 defaults apply
  mValue = numeric_limits<double>::quiet_NaN();
}
/** @endcond */


/*
 * Destroys this Parameter.
 */
Parameter::~Parameter ()
{
}


/*
 * Copy constructor. Creates a copy of this Parameter.
 */
Parameter::Parameter(const Parameter& orig) :
    SBase      ( orig             )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mValue         = orig.mValue    ;
    mUnits         = orig.mUnits    ;
    mConstant      = orig.mConstant ;
    mIsSetValue    = orig.mIsSetValue;
    mId            = orig.mId;
    mName          = orig.mName;
    mIsSetConstant = orig.mIsSetConstant;
    mExplicitlySetConstant = orig.mExplicitlySetConstant;
    mCalculatingUnits = false; // only set by units converter
  }
}


/*
 * Assignment operator.
 */
Parameter& Parameter::operator=(const Parameter& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mValue      = rhs.mValue    ;
    mUnits      = rhs.mUnits    ;
    mConstant   = rhs.mConstant ;
    mIsSetValue = rhs.mIsSetValue;
    mId = rhs.mId;
    mName = rhs.mName;
    mIsSetConstant = rhs.mIsSetConstant;
    mExplicitlySetConstant = rhs.mExplicitlySetConstant;
    mCalculatingUnits = false; // only set by units converter
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the parent Model's or
 * KineticLaw's next Parameter (if available).
 */
bool
Parameter::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Parameter.
 */
Parameter*
Parameter::clone () const
{
  return new Parameter(*this);
}


/*
 * Initializes the fields of this Parameter to their defaults:
 *
 *   - constant = true  (L2 only)
 */
void
Parameter::initDefaults ()
{
  //// level 3 has no defaults
  //if (getLevel() < 3)
  //{
    setConstant(true);
  //}
}


/*
 * @return the id of this SBML object.
 */
const string&
Parameter::getId () const
{
  return mId;
}


/*
 * @return the name of this SBML object.
 */
const string&
Parameter::getName () const
{
  return (getLevel() == 1) ? mId : mName;
}


/*
 * @return the value of this Parameter.
 */
double
Parameter::getValue () const
{
  return mValue;
}


/*
 * @return the units of this Parameter.
 */
const string&
Parameter::getUnits () const
{
  return mUnits;
}


/*
 * @return true if this Parameter is constant, false otherwise.
 */
bool
Parameter::getConstant () const
{
  return mConstant;
}


/*
 * @return true if the id of this SBML object is set, false
 * otherwise.
 */
bool
Parameter::isSetId () const
{
  return (mId.empty() == false);
}


/*
 * @return true if the name of this SBML object is set, false
 * otherwise.
 */
bool
Parameter::isSetName () const
{
  return (getLevel() == 1) ? (mId.empty() == false) : 
                            (mName.empty() == false);
}


/*
 * @return true if the value of this Parameter is set, false
 * otherwise.
 *
 * In SBML L1v1, a Parameter value is required and therefore <b>should
 * always be set</b>.  In L1v2 and beyond, a value is optional and as such
 * may or may not be set.
 */
bool
Parameter::isSetValue () const
{
  return mIsSetValue;
}


/*
 * @return true if the units of this Parameter is set, false
 * otherwise.
 */
bool
Parameter::isSetUnits () const
{
  return (mUnits.empty() == false);
}


/*
 * @return true if the constant of this Parameter is set, false
 * otherwise.
 */
bool
Parameter::isSetConstant () const
{
  return mIsSetConstant;
}


/*
 * Sets the id of this SBML object to a copy of sid.
 */
int
Parameter::setId (const std::string& sid)
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
Parameter::setName (const std::string& name)
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
 * Sets the value of this Parameter to value and marks the field as set.
 */
int
Parameter::setValue (double value)
{
  mValue      = value;
  mIsSetValue = true;
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the units of this Parameter to a copy of sid.
 */
int
Parameter::setUnits (const std::string& units)
{
  if (&(units) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  if (!(SyntaxChecker::isValidInternalUnitSId(units)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mUnits = units;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the constant field of this Parameter to value.
 */
int
Parameter::setConstant (bool flag)
{
  if ( getLevel() < 2 )
  {
    mConstant = flag;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mConstant = flag;
    mIsSetConstant = true;
    mExplicitlySetConstant = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Unsets the name of this SBML object.
 */
int
Parameter::unsetName ()
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
 * Unsets the value of this Parameter.
 *
 * In SBML L1v1, a Parameter value is required and therefore <b>should
 * always be set</b>.  In L1v2 and beyond, a value is optional and as such
 * may or may not be set.
 */
int
Parameter::unsetValue ()
{
  mValue      = numeric_limits<double>::quiet_NaN();
  mIsSetValue = false;
  if (!isSetValue())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the units of this Parameter.
 */
int
Parameter::unsetUnits ()
{
  mUnits.erase();

  if (mUnits.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * Parameter.
  */
UnitDefinition *
Parameter::getDerivedUnitDefinition()
{
  bool calculate = getCalculatingUnits();

  /* we need to unset this flag because the code that does the unit
   * calculations will try and establish whether 
   * variables in math have units set possible using this
   * function - but assuming that it is not calculating the units
   * thus unless we unset the flag immediately 
   * this may cause an infinite loop
   */
  this->setCalculatingUnits(false);

  UnitDefinition * derivedUD = NULL;
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

  if (m == NULL)
  {
    return NULL;
  }
  else
  {
  /* if we have a model calculate all units */
    if (!m->isPopulatedListFormulaUnitsData())
    {
      m->populateListFormulaUnitsData();
    }
  }

  /* need to distinguish between a global and local parameter
   * in order to determine the id that will be used
   * in the ListFormulaUnitsData
   */
    
  bool globalParameter = false;
  SBase *parent  = getParentSBMLObject();
  SBase *pparent = (parent) ? parent->getParentSBMLObject() : NULL; 
  if (pparent != NULL && dynamic_cast<Model*>(pparent) != 0)
  {
    globalParameter = true;
  }

  std::string id = this->getId();
  int typecode = getTypeCode();

  if (globalParameter == false)
  {
    // need the id of the reaction
    Reaction * r = static_cast<Reaction*>(getAncestorOfType(SBML_REACTION));
    
    // should not get NULL here but just in case
    if (r == NULL) return NULL;
    
    id = getId() + '_' + r->getId();
    typecode = SBML_LOCAL_PARAMETER;
  }

  if (calculate == true)
  {
    derivedUD = inferUnits(m, globalParameter);
  }
  else
  {
    /* here we do not want to try to infer the unit from any formula
    * we just use what is given
    */
    if (m->getFormulaUnitsData(id, typecode) != NULL)
    {
      // we already have the ud in memory return it

      derivedUD = m->getFormulaUnitsData(id, typecode)->getUnitDefinition();
    }
  }

  return derivedUD;
}


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * Compartment.
  */
const UnitDefinition *
Parameter::getDerivedUnitDefinition() const
{
  return const_cast <Parameter *> (this)->getDerivedUnitDefinition();
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
Parameter::getTypeCode () const
{
  return SBML_PARAMETER;
}


/*
 * @return the name of this element ie "parameter".
 */
const string&
Parameter::getElementName () const
{
  static const string name = "parameter";
  return name;
}


bool 
Parameter::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for parameter: id (name in L1)
   * and value (in L1V1 only)
   * and constant (in L3) */

  if (!isSetId())
    allPresent = false;

  if (getLevel() == 1
    && getVersion() == 1
    && !isSetValue())
    allPresent = false;

  if (getLevel() > 2 && !isSetConstant())
    allPresent = false;

  return allPresent;
}


void 
Parameter::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (mUnits == oldid) mUnits= newid;
}

/** @cond doxygenLibsbmlInternal */
/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
Parameter::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  switch (level)
  {
  case 1:
    attributes.add("name");
    attributes.add("units");
    attributes.add("value");
    break;
  case 2:
    attributes.add("name");
    attributes.add("units");
    attributes.add("value");
    attributes.add("id");
    attributes.add("constant");
    if (version == 2)
    {
      attributes.add("sboTerm");
    }
    break;
  case 3:
  default:
    attributes.add("name");
    attributes.add("units");
    attributes.add("value");
    attributes.add("id");
    if (dynamic_cast<LocalParameter*>(this) == 0)
    {
      attributes.add("constant");
    }
    break;
  }
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 *
 * @param attributes the XMLAttributes object to use
 */
void
Parameter::readAttributes (const XMLAttributes& attributes,
                           const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    readL1Attributes(attributes);
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
 *
 * @param attributes the XMLAttributes object to use
 */
void
Parameter::readL1Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  // name: SName   { use="required" }  (L1v1, L1v2)
  //
  bool assigned = attributes.readInto("name", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("name", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // value: double  { use="required" }  (L1v2)
  // value: double  { use="optional" }  (L1v2->)
  //
  if (version == 1)
  {
    mIsSetValue = attributes.readInto("value", mValue, getErrorLog(), true, getLine(), getColumn());
  }
  else
  {
    mIsSetValue = attributes.readInto("value", mValue, getErrorLog(), false, getLine(), getColumn());
  }

  //
  // units: SName  { use="optional" }  (L1v1, L1v2)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mUnits))
  {
    logError(InvalidUnitIdSyntax);
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 *
 * @param attributes the XMLAttributes object to use
 */
void
Parameter::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //   id: SId     { use="required" }  (L2v1, L2v2)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // value: double  { use="optional" }  (L1v2->)
  //
  mIsSetValue = attributes.readInto("value", mValue, getErrorLog(), false, getLine(), getColumn());

  //
  // units: SId    { use="optional" }  (L2v1, L2v2)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // name: string  { use="optional" }  (L2v1 ->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());

  //
  // constant: boolean  { use="optional" default="true" }  (L2v1->)
  //
  mExplicitlySetConstant = attributes.readInto("constant", mConstant, getErrorLog(), false, getLine(), getColumn());

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2->)
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
 *
 * @param attributes the XMLAttributes object to use
 */
void
Parameter::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //   id: SId     { use="required" }  (L2v1, L2v2)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), false, getLine(), getColumn());
  if (!assigned)
  {
    if (this->getTypeCode() == SBML_PARAMETER)
    {
      logError(AllowedAttributesOnParameter, level, version, 
        "The required attribute 'id' is missing.");
    }
    else
    {
      logError(AllowedAttributesOnLocalParameter, 
                       level, version, "The required attribute 'id' is missing.");
    }
  }
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // value: double  { use="optional" }  (L1v2->)
  //
  mIsSetValue = attributes.readInto("value", mValue, getErrorLog(), false, getLine(), getColumn());

  //
  // units: SId    { use="optional" }  (L2v1, L2v2)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<parameter>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // name: string  { use="optional" }  (L2v1 ->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());

  if (this->getTypeCode() == SBML_PARAMETER)
  {
    mIsSetConstant = attributes.readInto("constant", mConstant,
                                          getErrorLog(), false, getLine(), getColumn());
    if (!mIsSetConstant)
    {
      logError(AllowedAttributesOnParameter, level, version, 
        "The required attribute 'constant' is missing.");
    }
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
Parameter::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
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
Parameter::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2->)
  //
  // sboTerm for L2V3 or later is written in SBase::writeAttributes()
  //
  if ( (level == 2) && (version == 2) )
  {
    SBO::writeTerm(stream, mSBOTerm);
  }

  //
  // name: SName   { use="required" }  (L1v1, L1v2)
  //   id: SId     { use="required" }  (L2v1->)
  //
  const string id = (level == 1) ? "name" : "id";
  stream.writeAttribute(id, mId);

  if (level > 1)
  {
    //
    // name: string  { use="optional" }  (L2v1->)
    //
    stream.writeAttribute("name", mName);
  }

  //
  // value: double  { use="required" }  (L1v1)
  // value: double  { use="optional" }  (L1v2->)
  //
  if (mIsSetValue || (level == 1 && version == 1))
  {
    stream.writeAttribute("value", mValue);
  }

  //
  // units: SName  { use="optional" }  (L1v1, L1v2)
  // units: SId    { use="optional" }  (L2v1-> )
  //
  stream.writeAttribute("units", mUnits);

  if (level > 1)
  {
    //
    // constant: boolean  { use="optional" default="true" }  (L2v1->)
    // constant: boolean  { use="required" }  (L3v1->)
    //
    if (level == 2)
    {
      if (mConstant != true || isExplicitlySetConstant())
      {
        stream.writeAttribute("constant", mConstant);
      }
    }
    else if (dynamic_cast<const LocalParameter*>(this) == 0)
    {
      // in L3 only write it out if it has been set
      if (isSetConstant())
        stream.writeAttribute("constant", mConstant);
    }

  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */

/* private functions used for inferring units */
/** @cond doxygenLibsbmlInternal */

void
Parameter::setCalculatingUnits(bool calculatingUnits)
{
  mCalculatingUnits = calculatingUnits;
}

/** @endcond */

/** @cond doxygenLibsbmlInternal */

bool
Parameter::getCalculatingUnits() const
{
  return mCalculatingUnits;
}

/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnits(Model* m, bool globalParameter)
{
  UnitDefinition * derivedUD = NULL;
  UnitFormulaFormatter *uff = new UnitFormulaFormatter(m);

  if (globalParameter == true)
  {
    derivedUD = inferUnitsFromAssignments(uff, m);

    if (derivedUD == NULL)
    {
      derivedUD = inferUnitsFromRules(uff, m);
    }

    if (derivedUD == NULL)
    {
      derivedUD = inferUnitsFromReactions(uff, m);
    }

    if (derivedUD == NULL)
    {
      derivedUD = inferUnitsFromEvents(uff, m);
    }
  }
  else
  {
    // local parameter
    // so we will have a parent that is a kineticLaw
    KineticLaw * kl = NULL;
    kl = static_cast<KineticLaw *>(
                       this->getAncestorOfType(SBML_KINETIC_LAW, "core"));

    derivedUD = inferUnitsFromKineticLaw(kl, uff, m);
  }

  delete uff;
  return derivedUD;
}


/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromRules(UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;
  
  std::string id = this->getId();
  
  bool found = false;
  unsigned int i;
  FormulaUnitsData *fud;

  /* look in initialAssignments */
  for (i = 0; found == false && i < m->getNumInitialAssignments(); i++)
  {
    const ASTNode *math = m->getInitialAssignment(i)->isSetMath() ?
           m->getInitialAssignment(i)->getMath() : NULL;
    if (uff->variableCanBeDeterminedFromMath(math, id) == true)
    {
      /* do we know the units of the LHS */
      std::string symbol = m->getInitialAssignment(i)->getSymbol();
      fud = m->getFormulaUnitsDataForVariable(symbol);

      if (uff->possibleToUseUnitsData(fud) == true)
      {
        derivedUD = uff->inferUnitDefinition(fud->getUnitDefinition(),
                                             math, id);
        found = true;
      }
    }
  }        
  /* look in rules */
  for (i = 0; found == false && i < m->getNumRules(); i++)
  {
    const ASTNode * math = m->getRule(i)->isSetMath() ? 
                           m->getRule(i)->getMath() : NULL;
    if (uff->variableCanBeDeterminedFromMath(math, id) == true)
    {
      /* do we know the units of the LHS */
      std::string symbol = m->getRule(i)->getVariable();
      fud = m->getFormulaUnitsDataForVariable(symbol);

      if (uff->possibleToUseUnitsData(fud) == true)
      {
        if (m->getRule(i)->getTypeCode() == SBML_ASSIGNMENT_RULE)
        {
          derivedUD = uff->inferUnitDefinition(fud->getUnitDefinition(),
                                               math, id);
        }
        else if (m->getRule(i)->getTypeCode() == SBML_RATE_RULE)
        {
          derivedUD = uff->inferUnitDefinition(fud->getPerTimeUnitDefinition(),
                                               math, id);
        }
        found = true;
      }
    }
  }        

  return derivedUD;
}


/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromAssignments(UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;
  std::string id = this->getId();
  bool found = false;

  /* is it the variable of an initalAssignment/assignmentRule */
  FormulaUnitsData *fud = m->getFormulaUnitsDataForAssignment(id);
  if (uff->possibleToUseUnitsData(fud) == true)
  {
    derivedUD = new UnitDefinition(*(fud->getUnitDefinition()));
    found = true;
  }

  /* is it the variable of a raterule */
  if (m->getRateRule(id) != NULL)
  {
    fud = m->getFormulaUnitsData(id, SBML_RATE_RULE);
    if (uff->possibleToUseUnitsData(fud) == true)
    {
      FormulaUnitsData *time = m->getFormulaUnitsData("time", SBML_MODEL);
      if (time->getContainsUndeclaredUnits() == false)
      {
        derivedUD = UnitDefinition::combine(fud->getUnitDefinition(),
                                      time->getUnitDefinition());
        found = true;
      }
    }
  }

  /* is it the variable of an eventAssignment */
  for (unsigned int i = 0; found == false && i < m->getNumEvents(); i++)
  {
    Event * e = m->getEvent(i);
    EventAssignment * ea = e->getEventAssignment(id);
    if (ea != NULL)
    {
      const string& variable = id + e->getId();
      fud = m->getFormulaUnitsData(variable, SBML_EVENT_ASSIGNMENT);
      if (uff->possibleToUseUnitsData(fud) == true)
      {
        derivedUD = new UnitDefinition(*(fud->getUnitDefinition()));
        found = true;
      }
    }
  }

  return derivedUD;
}


/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromReactions(UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;
  bool found = false;

  for (unsigned int i = 0; found == false && i < m->getNumReactions(); i++)
  {
    if (m->getReaction(i)->isSetKineticLaw() == true)
    {
      derivedUD = inferUnitsFromKineticLaw(m->getReaction(i)->getKineticLaw(),
                                           uff, m);
      if (derivedUD != NULL)
      {
        found = true;
      }
    }
  }

  return derivedUD;
}

/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromEvents(UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;

  bool found = false;

  for (unsigned int i = 0; found == false && i < m->getNumEvents(); i++)
  {
    derivedUD = inferUnitsFromEvent(m->getEvent(i), uff, m);
    if (derivedUD != NULL)
    {
      found = true;
    }
  }

  return derivedUD;
}

/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromEvent(Event * e, UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;
  bool found = false;
  std::string id = this->getId();
  unsigned int i;

  /* look at eventAssignments */
  for (i = 0; found == false && i < e->getNumEventAssignments(); i++)
  {
    const ASTNode * math = e->getEventAssignment(i)->isSetMath() ?
      e->getEventAssignment(i)->getMath() : NULL;

    if (uff->variableCanBeDeterminedFromMath(math, id) == true)
    {
      /* do we know the units of the LHS */
      std::string symbol = e->getEventAssignment(i)->getVariable();
      FormulaUnitsData *fud = m->getFormulaUnitsDataForVariable(symbol);

      if (uff->possibleToUseUnitsData(fud) == true)
      {
        derivedUD = uff->inferUnitDefinition(fud->getUnitDefinition(),
                                             math, id);
        found = false;
      }
    }
  }        

  /* look in delay*/
  if (found == false && e->isSetDelay() == true)
  {
    const ASTNode * math = e->getDelay()->isSetMath() ?
      e->getDelay()->getMath() : NULL;

    if (uff->variableCanBeDeterminedFromMath(math, id) == true)
    {
      /* the units of the LHS will be the time units of the model */
      FormulaUnitsData *fud = m->getFormulaUnitsData(e->getId(), SBML_EVENT);

      // usually at this point we check the fud which should represent the
      // LHS
      // delay cannot use the possibleToUseUnitsData function as
      // for a delay this refers to the RHS which we know 
      // has a variable with undeclared units  SO it will claim it
      // cannot be used
   
      if (fud != NULL)
      {
        if (fud->getEventTimeUnitDefinition()->getNumUnits() > 0)
        {
          derivedUD = uff->inferUnitDefinition(
                                fud->getEventTimeUnitDefinition(), math, id);
          found = true;
        }
      }
    }
  }        
    
  /* look in priority*/
  if (found == false && e->isSetPriority() == true)
  {
    const ASTNode * math = e->getPriority()->isSetMath() ?
                           e->getPriority()->getMath() : NULL;

    if (uff->variableCanBeDeterminedFromMath(math, id) == true)
    {
      /* the units of the LHS will be dimensionless */
      UnitDefinition * dim = new UnitDefinition(getSBMLNamespaces());
      Unit * u = dim->createUnit();
      u->initDefaults();
      u->setKind(UNIT_KIND_DIMENSIONLESS);

      derivedUD = uff->inferUnitDefinition(dim, math, id);
      delete dim;
      //found = true;
    }
  }              

  return derivedUD;
}

/** @endcond */

/** @cond doxygenLibsbmlInternal */

UnitDefinition *
Parameter::inferUnitsFromKineticLaw(KineticLaw* kl, 
                                    UnitFormulaFormatter *uff, Model *m)
{
  UnitDefinition * derivedUD = NULL;

  if (kl == NULL)
  {
    return derivedUD;
  }

  std::string id = this->getId();

  int index = -1;
  // unfortunately we need the index of the reaction
  // that really should be done with id !!
  std::string rnId = (kl->getAncestorOfType(SBML_REACTION) != NULL) ?
                      kl->getAncestorOfType(SBML_REACTION)->getId() : std::string();
  if (rnId.empty() == false)
  {
    for (unsigned int i = 0; i < m->getNumReactions(); i++)
    {
      if (rnId == m->getReaction(i)->getId())
      {
        index = i;
        break;
      }
    }
  }

  const ASTNode * math = kl->isSetMath() ? kl->getMath() : NULL;
        
  if (index > -1 && uff->variableCanBeDeterminedFromMath(math, id) == true)
  {
    FormulaUnitsData * fud = 
                       m->getFormulaUnitsData("subs_per_time", SBML_UNKNOWN);
        
    if (uff->possibleToUseUnitsData(fud) == true)
    {
      derivedUD = uff->inferUnitDefinition(fud->getUnitDefinition(),
            math, id, true, index);
    }
  }

  return derivedUD;
}

/** @endcond */

/*
 * Creates a new ListOfParameters items.
 */
ListOfParameters::ListOfParameters (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfParameters items.
 */
ListOfParameters::ListOfParameters (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfParameters.
 */
ListOfParameters*
ListOfParameters::clone () const
{
  return new ListOfParameters(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfParameters::getItemTypeCode () const
{
  return SBML_PARAMETER;
}


/*
 * @return the name of this element ie "listOfParameters".
 */
const string&
ListOfParameters::getElementName () const
{
  static const string name = "listOfParameters";
  return name;
}


/* return nth item in list */
Parameter *
ListOfParameters::get(unsigned int n)
{
  return static_cast<Parameter*>(ListOf::get(n));
}


/* return nth item in list */
const Parameter *
ListOfParameters::get(unsigned int n) const
{
  return static_cast<const Parameter*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqP : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqP (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <Parameter *> (sb)->getId() == id; }
};
/* return item by id */
Parameter*
ListOfParameters::get (const std::string& sid)
{
  return const_cast<Parameter*>( 
    static_cast<const ListOfParameters&>(*this).get(sid) );
}


/* return item by id */
const Parameter*
ListOfParameters::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqP(sid) );
    return (result == mItems.end()) ? NULL : static_cast <Parameter*> (*result);
  }
}


/* Removes the nth item from this list */
Parameter*
ListOfParameters::remove (unsigned int n)
{
   return static_cast<Parameter*>(ListOf::remove(n));
}


/* Removes item in this list by id */
Parameter*
ListOfParameters::remove (const std::string& sid)
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

  return static_cast <Parameter*> (item);
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfParameters::getElementPosition () const
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
ListOfParameters::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "parameter")
  {
    try
    {
      object = new Parameter(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new Parameter(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new Parameter(SBMLDocument::getDefaultLevel(),
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
Parameter_t *
Parameter_create (unsigned int level, unsigned int version)
{
  try
  {
    Parameter* obj = new Parameter(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Parameter_t *
Parameter_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Parameter* obj = new Parameter(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Parameter_free (Parameter_t *p)
{
  delete p;
}


LIBSBML_EXTERN
Parameter_t *
Parameter_clone (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<Parameter_t*>( p->clone() ) : NULL;
}


LIBSBML_EXTERN
void
Parameter_initDefaults (Parameter_t *p)
{
  if (p != NULL)
    p->initDefaults();
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Parameter_getNamespaces(Parameter_t *p)
{
  return (p != NULL) ? p->getNamespaces() : NULL;
}

LIBSBML_EXTERN
const char *
Parameter_getId (const Parameter_t *p)
{
  return (p != NULL && p->isSetId()) ? p->getId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Parameter_getName (const Parameter_t *p)
{
  return (p != NULL && p->isSetName()) ? p->getName().c_str() : NULL;
}


LIBSBML_EXTERN
double
Parameter_getValue (const Parameter_t *p)
{
  return (p != NULL) ? p->getValue() : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
const char *
Parameter_getUnits (const Parameter_t *p)
{
  return (p != NULL && p->isSetUnits()) ? p->getUnits().c_str() : NULL;
}


LIBSBML_EXTERN
int
Parameter_getConstant (const Parameter_t *p)
{
  return (p != NULL) ? p->getConstant() : 0;
}


LIBSBML_EXTERN
int
Parameter_isSetId (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetId() ) : 0;
}


LIBSBML_EXTERN
int
Parameter_isSetName (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetName() ) : 0;
}


LIBSBML_EXTERN
int
Parameter_isSetValue (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetValue() ) : 0;
}


LIBSBML_EXTERN
int
Parameter_isSetUnits (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetUnits() ) : 0;
}


LIBSBML_EXTERN
int
Parameter_isSetConstant (const Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>( p->isSetConstant() ) : 0;
}


LIBSBML_EXTERN
int
Parameter_setId (Parameter_t *p, const char *sid)
{
  if (p != NULL)
    return (sid == NULL) ? p->setId("") : p->setId(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_setName (Parameter_t *p, const char *name)
{
  if (p != NULL)
    return (name == NULL) ? p->unsetName() : p->setName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_setValue (Parameter_t *p, double value)
{
  if (p != NULL)
    return p->setValue(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_setUnits (Parameter_t *p, const char *units)
{
  if (p != NULL)
    return (units == NULL) ? p->unsetUnits() : p->setUnits(units);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_setConstant (Parameter_t *p, int value)
{
  if (p != NULL)
    return p->setConstant( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_unsetName (Parameter_t *p)
{
  if (p != NULL)
    return p->unsetName();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_unsetValue (Parameter_t *p)
{
  if (p != NULL)
    return p->unsetValue();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Parameter_unsetUnits (Parameter_t *p)
{
  if (p != NULL)
    return p->unsetUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
UnitDefinition_t * 
Parameter_getDerivedUnitDefinition(Parameter_t *p)
{
  return (p != NULL) ? p->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
int
Parameter_hasRequiredAttributes(Parameter_t *p)
{
  return (p != NULL) ? static_cast<int>(p->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
Parameter_t *
ListOfParameters_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfParameters *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
Parameter_t *
ListOfParameters_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfParameters *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END
