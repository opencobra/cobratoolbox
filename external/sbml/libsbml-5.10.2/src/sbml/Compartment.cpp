/**
 * @file    Compartment.cpp
 * @brief   Implementations of Compartment and ListOfCompartments.
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

#include <limits>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/Compartment.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Compartment::Compartment (unsigned int level, unsigned int version) :
   SBase             ( level, version )
 , mId               ( ""       )
 , mName             ( ""       )
 , mSpatialDimensions( 3        )
 , mSpatialDimensionsDouble( 3        )
 , mSize             ( 1.0      )
 , mConstant         ( true     )
 , mIsSetSize        ( false    )
 , mIsSetSpatialDimensions ( false    )
 , mIsSetConstant          ( false    )
 , mExplicitlySetSpatialDimensions ( false )
 , mExplicitlySetConstant          ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  // if level 3 values have no defaults
  if (level == 3)
  {
    mSize = numeric_limits<double>::quiet_NaN();
    mSpatialDimensionsDouble = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 spatialDimensions and constant were set by default
  if (level < 3)
  {
    mIsSetSpatialDimensions = true;
  }
  if (level == 2)
  {
    mIsSetConstant = true;
  }
}

Compartment::Compartment(SBMLNamespaces * sbmlns) :
   SBase             ( sbmlns   )
 , mId               ( ""       )
 , mName             ( ""       )
 , mSpatialDimensions( 3        )
 , mSpatialDimensionsDouble( 3        )
 , mSize             ( 1.0      )
 , mConstant         ( true     )
 , mIsSetSize        ( false    )
 , mIsSetSpatialDimensions ( false    )
 , mIsSetConstant          ( false    )
 , mExplicitlySetSpatialDimensions ( false )
 , mExplicitlySetConstant          ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {    
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  loadPlugins(sbmlns);
 
  // if level 3 values have no defaults
  if (sbmlns->getLevel() == 3)
  {
    mSize = numeric_limits<double>::quiet_NaN();
    mSpatialDimensionsDouble = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 spatialDimensions and constant were set by default
  if (sbmlns->getLevel() < 3)
  {
    mIsSetSpatialDimensions = true;
  }
  if (sbmlns->getLevel() == 2)
  {
    mIsSetConstant = true;
  }
}

/** @cond doxygenLibsbmlInternal */


/** @endcond */
                          
/*
 * Destroys this Compartment.
 */
Compartment::~Compartment ()
{
}


/*
 * Copy constructor. Creates a copy of this compartment.
 */
Compartment::Compartment(const Compartment& orig) :
   SBase             ( orig                    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mSpatialDimensions       = orig.mSpatialDimensions;
    mSpatialDimensionsDouble = orig.mSpatialDimensionsDouble;
    mSize                    = orig.mSize;
    mConstant                = orig.mConstant;
    mIsSetSize               = orig.mIsSetSize;
    mCompartmentType         = orig.mCompartmentType;
    mUnits                   = orig.mUnits;
    mOutside                 = orig.mOutside;
    mId                      = orig.mId;
    mName                    = orig.mName;
    mIsSetSpatialDimensions  = orig.mIsSetSpatialDimensions;
    mIsSetConstant           = orig.mIsSetConstant;
    mExplicitlySetSpatialDimensions = orig.mExplicitlySetSpatialDimensions;
    mExplicitlySetConstant          = orig.mExplicitlySetConstant;
  }
}


/*
 * Assignment operator
 */
Compartment& Compartment::operator=(const Compartment& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mSpatialDimensions= rhs.mSpatialDimensions  ;
    mSpatialDimensionsDouble= rhs.mSpatialDimensionsDouble  ;
    mSize             = rhs.mSize      ;
    mConstant         = rhs.mConstant     ;
    mIsSetSize        = rhs.mIsSetSize    ;
    mCompartmentType  = rhs.mCompartmentType;
    mUnits            = rhs.mUnits ;
    mOutside          = rhs.mOutside ;
    mId               = rhs.mId;
    mName             = rhs.mName;
    mIsSetSpatialDimensions = rhs.mIsSetSpatialDimensions;
    mIsSetConstant          = rhs.mIsSetConstant;
    mExplicitlySetSpatialDimensions = rhs.mExplicitlySetSpatialDimensions;
    mExplicitlySetConstant          = rhs.mExplicitlySetConstant;
  }

  return *this;
}



/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Model's next
 * Compartment (if available).
 */
bool
Compartment::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Compartment.
 */
Compartment*
Compartment::clone () const
{
  return new Compartment(*this);
}


/*
 * Initializes the fields of this Compartment to their defaults:
 *
 *   - volume            = 1.0          (L1 only)
 *   - spatialDimensions = 3            (L2 only)
 *   - constant          = 1    (true)  (L2 only)
 */
LIBSBML_EXTERN
void
Compartment::initDefaults ()
{
  mSize      = 1.0;    // Actually, setting L1 volume not
  mIsSetSize = false;  // L2 size.

  unsigned int dims = 3;
  setSpatialDimensions(dims);
  setConstant(1);

  if (getLevel() > 2)
  {
    setUnits("litre");
  }
}


/*
 * @return the id of this SBML object.
 */
const string&
Compartment::getId () const
{
  return mId;
}


/*
 * @return the name of this SBML object.
 */
const string&
Compartment::getName () const
{
  return (getLevel() == 1) ? mId : mName;
}


/*
 * @return the compartmentType of this Compartment.
 */
const string&
Compartment::getCompartmentType () const
{
  return mCompartmentType;
}


/*
 * @return the spatialDimensions of this Compartment.
 */
unsigned int
Compartment::getSpatialDimensions () const
{
  if (getLevel() < 3)
  {
    return mSpatialDimensions;
  }
  else
  {
    if (isSetSpatialDimensions())
    {
      if (ceil(mSpatialDimensionsDouble) == 
          floor(mSpatialDimensionsDouble))
      {
        return static_cast<unsigned int>(mSpatialDimensionsDouble);
      }
      else
      {
        return numeric_limits<unsigned int>::quiet_NaN();
      }
    }
    else
    {
      return static_cast<unsigned int>(mSpatialDimensionsDouble);
    }
  }
}


/*
 * @return the spatialDimensions of this Compartment.
 */
double
Compartment::getSpatialDimensionsAsDouble () const
{
  if (getLevel() > 2)
    return mSpatialDimensionsDouble;
  else
    return static_cast<double>(mSpatialDimensions);
}


/*
 * @return the size (volume in L1) of this Compartment.
 */
double
Compartment::getSize () const
{
  return mSize;
}


/*
 * @return the volume (size in L2) of this Compartment.
 */
double
Compartment::getVolume () const
{
  return getSize();
}


/*
 * @return the units of this Compartment.
 */
const string&
Compartment::getUnits () const
{
  return mUnits;
}


/*
 * @return the outside of this Compartment.
 */
const string&
Compartment::getOutside () const
{
  return mOutside;
}


/*
 * @return true if this Compartment is constant, false otherwise.
 */
bool
Compartment::getConstant () const
{
  return mConstant;
}


/*
 * @return true if the id of this SBML object is  set, false
 * otherwise.
 */
bool
Compartment::isSetId () const
{
  return (mId.empty() == false);
}


/*
 * @return true if the name of this SBML object is  set, false
 * otherwise.
 */
bool
Compartment::isSetName () const
{
  return (getLevel() == 1) ? (mId.empty() == false) : 
                            (mName.empty() == false);
}


/*
 * @return true if the compartmentType of this Compartment is  set,
 * false otherwise. 
 */
bool
Compartment::isSetCompartmentType () const
{
  return (mCompartmentType.empty() == false);
}


/*
 * @return true if the size (volume in L1) of this Compartment is 
 * set, false otherwise.
 */
bool
Compartment::isSetSize () const
{
  return mIsSetSize;
}


/*
 * @return true if the volume (size in L2) of this Compartment is 
 * set, false otherwise.
 *
 * In SBML L1, a Compartment volume has a default value (1.0) and therefore
 * <b>should always be set</b>.  In L2, volume (size) is optional with no
 * default value and as such may or may not be set.
 */
bool
Compartment::isSetVolume () const
{
  return (getLevel() == 1) ? true : isSetSize();
}


/*
 * @return true if the units of this Compartment is set, false
 * otherwise.
 */
bool
Compartment::isSetUnits () const
{
  return (mUnits.empty() == false);
}


/*
 * @return true if the outside of this Compartment is set, false
 * otherwise.
 */
bool
Compartment::isSetOutside () const
{
  return (mOutside.empty() == false);
}


/*
 * @return true if the spatialDimenions of this Compartment is set, false
 * otherwise.
 */
bool
Compartment::isSetSpatialDimensions () const
{
  return mIsSetSpatialDimensions;
}


/*
 * @return true if the constant of this Compartment is set, false
 * otherwise.
 */
bool
Compartment::isSetConstant () const
{
  return mIsSetConstant;
}


/*
 * Sets the id of this SBML object to a copy of sid.
 */
int
Compartment::setId (const std::string& sid)
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
Compartment::setName (const std::string& name)
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
 * Sets the compartmentType field of this Compartment to a copy of sid.
 */
int
Compartment::setCompartmentType (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if ( (getLevel() < 2)
    || (getLevel() == 2 && getVersion() == 1))
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mCompartmentType = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the spatialDimensions of this Compartment to value.
 *
 * If value is not one of [0, 1, 2, 3] the function will have no effect
 * (i.e. spatialDimensions will not be set).
 */
int
Compartment::setSpatialDimensions (unsigned int value)
{
  return setSpatialDimensions((double) value);
}


/*
 * Sets the spatialDimensions of this Compartment to value.
 */
int
Compartment::setSpatialDimensions (double value)
{
  bool representsInteger = true;
  if (floor(value) != value)
    representsInteger = false;

  switch (getLevel())
  {
  case 1:
    /* level 1 spatialDimensions was not an attribute */
    mSpatialDimensions = 3;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
    break;
  case 2:
    if (!representsInteger || value < 0 || value > 3)
    {
      return LIBSBML_INVALID_ATTRIBUTE_VALUE;
    }
    else
    {
      mSpatialDimensions = (int) value;
      mSpatialDimensionsDouble = value;
      mIsSetSpatialDimensions  = true;
      mExplicitlySetSpatialDimensions = true;
      return LIBSBML_OPERATION_SUCCESS;
    }
    break;
  case 3:
  default:
      mSpatialDimensions = (int) value;
      mSpatialDimensionsDouble = value;
      mIsSetSpatialDimensions  = true;
      return LIBSBML_OPERATION_SUCCESS;
    break;
  }
}


/*
 * Sets the size (volume in L1) of this Compartment to value.
 */
int
Compartment::setSize (double value)
{
  /* since the setSize function has been used as an
   * alias for setVolume we cant require it to only
   * be used on a L2 model
   */
/*  if ( getLevel() < 2 )
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
*/
  mSize      = value;
  mIsSetSize = true;
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the volume (size in L2) of this Compartment to value.
 */
int
Compartment::setVolume (double value)
{
  /* since the setVolume function has been used as an
   * alias for setSize we cant require it to only
   * be used on a L1 model
   */
/*  if ( getLevel() != 1 )
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
*/
  return setSize(value);
}


/*
 * Sets the units of this Compartment to a copy of sid.
 */
int
Compartment::setUnits (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (!(SyntaxChecker::isValidInternalUnitSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mUnits = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the outside of this Compartment to a copy of sid.
 */
int
Compartment::setOutside (const std::string& sid)
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
    mOutside = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the constant field of this Compartment to value.
 */
int
Compartment::setConstant (bool value)
{
  if ( getLevel() < 2 )
  {
    mConstant = value;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mConstant = value;
    mIsSetConstant = true;
    if (getLevel() < 3)
    {
      mExplicitlySetConstant = true;
    }
    return LIBSBML_OPERATION_SUCCESS;
  }
}


void
Compartment::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (mCompartmentType==oldid) mCompartmentType = newid;
  if (mOutside==oldid) mOutside= newid; //You know, just in case.
}

void 
Compartment::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (mUnits==oldid) mUnits = newid;
}

/*
 * Unsets the name of this SBML object.
 */
int
Compartment::unsetName ()
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
 * Unsets the compartmentType of this Compartment.
 */
int
Compartment::unsetCompartmentType ()
{
  if ( (getLevel() < 2)
    || (getLevel() == 2 && getVersion() == 1))
  {
    mCompartmentType.erase();
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }

  mCompartmentType.erase();

  if (mCompartmentType.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the size (volume in L1) of this Compartment.
 */
int
Compartment::unsetSize ()
{
  if (getLevel() == 1) 
  {
    mSize = 1.0;
  }
  else
  {
    mSize = numeric_limits<double>::quiet_NaN();
  }

  mIsSetSize = false;
  
  if (!isSetSize())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the volume (size in L2) of this Compartment.
 *
 * In SBML L1, a Compartment volume has a default value (1.0) and therefore
 * <b>should always be set</b>.  In L2, volume is optional with no default
 * value and as such may or may not be set.
 */
int
Compartment::unsetVolume ()
{
  return unsetSize();
}


/*
 * Unsets the units of this Compartment.
 */
int
Compartment::unsetUnits ()
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
 * Unsets the outside of this Compartment.
 */
int
Compartment::unsetOutside ()
{
  mOutside.erase();

  if (mOutside.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}

/*
 * Unsets the spatialDimensions of this Compartment.
 */
int
Compartment::unsetSpatialDimensions ()
{
  if (getLevel() < 3) 
  {
    mSpatialDimensions = 3;
    mExplicitlySetSpatialDimensions = false;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mSpatialDimensionsDouble = numeric_limits<double>::quiet_NaN();
  }

  mIsSetSpatialDimensions = false;
  
  if (!isSetSpatialDimensions())
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
  * Compartment.
  */
UnitDefinition *
Compartment::getDerivedUnitDefinition()
{
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
    
    if (m->getFormulaUnitsData(getId(), getTypeCode()))
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
Compartment::getDerivedUnitDefinition() const
{
  return const_cast <Compartment *> (this)->getDerivedUnitDefinition();
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
Compartment::getTypeCode () const
{
  return SBML_COMPARTMENT;
}


/*
 * @return the name of this element ie "compartment".
 */
const string&
Compartment::getElementName () const
{
  static const string name = "compartment";
  return name;
}


bool 
Compartment::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for compartment: id (name in L1) 
   * constant (L3 -> )
   */

  if (!isSetId())
    allPresent = false;

  if (getLevel() > 2 && !isSetConstant())
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
Compartment::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("name");
  attributes.add("units");

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  switch (level)
  {
  case 1:
    attributes.add("name");
    attributes.add("units");
    attributes.add("outside");
    attributes.add("volume");
    break;
  case 2:
    attributes.add("name");
    attributes.add("units");
    attributes.add("outside");
    attributes.add("id");
    attributes.add("size");
    attributes.add("spatialDimensions");
    attributes.add("constant");
    if (version > 1)
    {
      attributes.add("compartmentType");
    }
    break;
  case 3:
  default:
    attributes.add("name");
    attributes.add("units");
    attributes.add("id");
    attributes.add("size");
    attributes.add("spatialDimensions");
    attributes.add("constant");
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
Compartment::readAttributes (const XMLAttributes& attributes,
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
 */
void
Compartment::readL1Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = 1;
  const unsigned int version = getVersion();

  //
  // name: SName   { use="required" }  (L1v1, L1v2)
  //
  bool assigned = attributes.readInto("name", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("name", level, version, "<compartment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // volume  { use="optional" default="1" }  (L1v1, L1v2)
  //
  mIsSetSize = attributes.readInto("volume", mSize, getErrorLog(), false, getLine(), getColumn());

  //
  // units  { use="optional" }  (L1v1 ->)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<compartment>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // outside  { use="optional" }  (L1v1 -> L2v4)
  //
  attributes.readInto("outside", mOutside, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Compartment::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = 2;
  const unsigned int version = getVersion();

  //
  //   id: SId     { use="required" }  (L2v1 ->)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<compartment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // size    { use="optional" }              (L2v1 ->)
  //
  mIsSetSize = attributes.readInto("size", mSize, getErrorLog(), false, getLine(), getColumn());

  //
  // units  { use="optional" }  (L1v1 ->)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<compartment>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // outside  { use="optional" }  (L1v1 -> L2v4)
  //
  attributes.readInto("outside", mOutside, getErrorLog(), false, getLine(), getColumn());

  //
  // name: string  { use="optional" }  (L2v1 ->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());
  
  //
  // spatialDimensions { maxInclusive="3" minInclusive="0" use="optional"
  //                     default="3" }  (L2v1 ->)
  mExplicitlySetSpatialDimensions = attributes.readInto("spatialDimensions", 
                                    mSpatialDimensions, getErrorLog(), false, getLine(), getColumn());
  if (/*mSpatialDimensions < 0 ||*/ mSpatialDimensions > 3)
  {
    std::string message = "The spatialDimensions attribute on ";
    message += "a <compartment> may only have values 0, 1, 2 or 3.";
    logError(NotSchemaConformant, level, version,
                                                          message);
  }
  else
  {
    // keep record as double
    mSpatialDimensionsDouble = (double)(mSpatialDimensions);
    mIsSetSpatialDimensions = true;
  }

  //
  // constant  { use="optional" default="true" }  (L2v1 ->)
  //
  mExplicitlySetConstant = attributes.readInto("constant", mConstant, getErrorLog(), false, getLine(), getColumn());

  //
  // compartmentType: SId  { use="optional" }  (L2v2 -> L2v4)
  //
  if (version != 1)
  {
    attributes.readInto("compartmentType", mCompartmentType, 
                                        getErrorLog(), false, getLine(), getColumn());
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
Compartment::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = 3;
  const unsigned int version = getVersion();

  //
  //   id: SId     { use="required" }  (L2v1 ->)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), false, getLine(), getColumn());
  if (!assigned)
  {
    logError(AllowedAttributesOnCompartment, level, version, 
      "The required attribute 'id' is missing.");
  }
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<compartment>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // size    { use="optional" }              (L2v1 ->)
  //
  mIsSetSize = attributes.readInto("size", mSize, getErrorLog(), false, getLine(), getColumn());

  //
  // units  { use="optional" }  (L1v1 ->)
  //
  assigned = attributes.readInto("units", mUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<compartment>");
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
  // spatialDimensions { use="optional"}  (L3v1 ->)
  //
  mIsSetSpatialDimensions = attributes.readInto("spatialDimensions", 
                        mSpatialDimensionsDouble, getErrorLog(), false, getLine(), getColumn());
  
  // keep integer value as record if spatial dimensions is 0, 1, 2, 3 
  if (mIsSetSpatialDimensions == true)
  {
    mSpatialDimensions = (int) (mSpatialDimensionsDouble);
  }
    
  //
  // constant  { use="required" }  (L3v1 ->)
  //
  mIsSetConstant = attributes.readInto("constant", mConstant, 
                                          getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetConstant)
  {
    logError(AllowedAttributesOnCompartment, level, version, 
      "The required attribute 'constant' is missing.");
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
Compartment::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // name: SName   { use="required" }  (L1v1, L1v2)
  //   id: SId     { use="required" }  (L2v1, L2v2)
  //
  const string id = (level == 1) ? "name" : "id";
  stream.writeAttribute(id, mId);

  if (level > 1)
  {
    //
    // name: string  { use="optional" }  (L2v1->)
    //
    stream.writeAttribute("name", mName);

    //
    // compartmentType: SId  { use="optional" }  (L2v2 -> L2v4)
    //
    if (level == 2 && version > 1)
    {
      stream.writeAttribute("compartmentType", mCompartmentType);
    }

    //
    // spatialDimensions { maxInclusive="3" minInclusive="0" use="optional"
    //                     default="3" }  (L2v1->L2v4)
    // spatialDimensions { use="optional"}  (L3v1 ->)
    //
    if (level == 2)
    {
      unsigned int sd = mSpatialDimensions;
      if (/*sd >= 0 &&*/ sd <= 2)
      {
        stream.writeAttribute("spatialDimensions", sd);
      }
      else if (isExplicitlySetSpatialDimensions())
      {
        // spatialDimensions has been explicitly set to the default value
        stream.writeAttribute("spatialDimensions", sd);
      }
    }
    else
    {
      if (isSetSpatialDimensions())
      {
        stream.writeAttribute("spatialDimensions", mSpatialDimensionsDouble);
      }
    }
  }

  //
  // volume  { use="optional" default="1" }  (L1v1, L1v2)
  // size    { use="optional" }              (L2v1->)
  //
  if (mIsSetSize)
  {
    const string size = (level == 1) ? "volume" : "size";
    stream.writeAttribute(size, mSize);
  }

  //
  // units  { use="optional" }  (L1v1, L1v2, L2v1->)
  //
  stream.writeAttribute("units", mUnits);

  //
  // outside  { use="optional" }  (L1v1-> L2v4)
  //
  if (level < 3)
  {
    stream.writeAttribute("outside", mOutside);
  }

  if (level > 1)
  {
    //
    // constant  { use="optional" default="true" }  (L2v1->)
    // constant  { use="required" }  (L3v1 ->)
    //
    if (level == 2)
    {
      if (mConstant != true || isExplicitlySetConstant())
      {
        stream.writeAttribute("constant", mConstant);
      }
    }
    else
    {
      // in L3 only write it out if it has been set
      if (isSetConstant())
        stream.writeAttribute("constant", mConstant);
    }
    //
    // sboTerm: SBOTerm { use="optional" }  (L2v3 ->)
    // is written in SBase::writeAttributes()
    //
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
Compartment::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */


/*
 * Creates a new ListOfCompartments items.
 */
ListOfCompartments::ListOfCompartments (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfCompartments items.
 */
ListOfCompartments::ListOfCompartments (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{    
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfCompartments.
 */
ListOfCompartments*
ListOfCompartments::clone () const
{
  return new ListOfCompartments(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfCompartments::getItemTypeCode () const
{
  return SBML_COMPARTMENT;
}


/*
 * @return the name of this element ie "listOfCompartments".
 */
const string&
ListOfCompartments::getElementName () const
{
  static const string name = "listOfCompartments";
  return name;
}

/* return nth item in list */
Compartment *
ListOfCompartments::get(unsigned int n)
{
  return static_cast<Compartment*>(ListOf::get(n));
}


/* return nth item in list */
const Compartment *
ListOfCompartments::get(unsigned int n) const
{
  return static_cast<const Compartment*>(ListOf::get(n));
}



/* return item by id */
Compartment*
ListOfCompartments::get (const std::string& sid)
{
  return const_cast<Compartment*>( 
    static_cast<const ListOfCompartments&>(*this).get(sid) );
}


/* return item by id */
const Compartment*
ListOfCompartments::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEq<Compartment>(sid) );
    return (result == mItems.end()) ? NULL : 
                                      static_cast <Compartment*> (*result);
  }
}


/* Removes the nth item from this list */
Compartment*
ListOfCompartments::remove (unsigned int n)
{
  return static_cast<Compartment*>(ListOf::remove(n));
}


/* Removes item in this list by id */
Compartment*
ListOfCompartments::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEq<Compartment>(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <Compartment*> (item);
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfCompartments::getElementPosition () const
{
  return 5;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfCompartments::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "compartment")
  {
    try
    {
      object = new Compartment(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new Compartment(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new Compartment(SBMLDocument::getDefaultLevel(),
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
Compartment_t *
Compartment_create (unsigned int level, unsigned int version)
{
  try
  {
    Compartment* obj = new Compartment(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Compartment_t *
Compartment_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Compartment* obj = new Compartment(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Compartment_free (Compartment_t *c)
{
  if (c != NULL)
  delete c;
}


LIBSBML_EXTERN
Compartment_t *
Compartment_clone (const Compartment_t* c)
{
  if (c != NULL)
  {
    return static_cast<Compartment*>(c->clone());
  }
  else
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Compartment_initDefaults (Compartment_t *c)
{
  if (c != NULL) c->initDefaults();
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Compartment_getNamespaces(Compartment_t *c)
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
const char *
Compartment_getId (const Compartment_t *c)
{
  return (c != NULL && c->isSetId()) ? c->getId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Compartment_getName (const Compartment_t *c)
{
  return (c != NULL && c->isSetName()) ? c->getName().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Compartment_getCompartmentType (const Compartment_t *c)
{
  return (c != NULL && c->isSetCompartmentType())
                                     ? c->getCompartmentType().c_str() : NULL;
}


LIBSBML_EXTERN
unsigned int
Compartment_getSpatialDimensions (const Compartment_t *c)
{
    return (c != NULL) ? c->getSpatialDimensions() : SBML_INT_MAX;
}


LIBSBML_EXTERN
double
Compartment_getSpatialDimensionsAsDouble (const Compartment_t *c)
{
  return (c != NULL) ? c->getSpatialDimensionsAsDouble() : 
                       numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
double
Compartment_getSize (const Compartment_t *c)
{
  return (c != NULL) ? c->getSize() : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
double
Compartment_getVolume (const Compartment_t *c)
{
  return (c != NULL) ? c->getVolume() : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
const char *
Compartment_getUnits (const Compartment_t *c)
{
  return (c != NULL && c->isSetUnits()) ? c->getUnits().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Compartment_getOutside (const Compartment_t *c)
{
  return (c != NULL && c->isSetOutside()) ? c->getOutside().c_str() : NULL;
}


LIBSBML_EXTERN
int
Compartment_getConstant (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->getConstant() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetId (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetId() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetName (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetName() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetCompartmentType (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetCompartmentType() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetSize (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetSize() ):0;
}


LIBSBML_EXTERN
int
Compartment_isSetVolume (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetVolume() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetUnits (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetUnits() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetOutside (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetOutside() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetSpatialDimensions (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetSpatialDimensions() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_isSetConstant (const Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>( c->isSetConstant() ) : 0;
}


LIBSBML_EXTERN
int
Compartment_setId (Compartment_t *c, const char *sid)
{
  if (c != NULL)
    return (sid == NULL) ? c->setId("") : c->setId(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setName (Compartment_t *c, const char *name)
{
   if (c != NULL)
    return (name == NULL) ? c->unsetName() : c->setName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setCompartmentType (Compartment_t *c, const char *sid)
{
  if (c != NULL)
    return (sid == NULL) ? 
             c->unsetCompartmentType() : c->setCompartmentType(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setSpatialDimensions (Compartment_t *c, unsigned int value)
{
  if (c != NULL)
    return c->setSpatialDimensions(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setSpatialDimensionsAsDouble (Compartment_t *c, double value)
{
  if (c != NULL)
    return c->setSpatialDimensions(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setSize (Compartment_t *c, double value)
{
  if (c != NULL)
    return c->setSize(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setVolume (Compartment_t *c, double value)
{
  if (c != NULL)
    return c->setVolume(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setUnits (Compartment_t *c, const char *sid)
{
  if (c != NULL)
    return (sid == NULL) ? c->unsetUnits() : c->setUnits(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setOutside (Compartment_t *c, const char *sid)
{
  if (c != NULL)
    return (sid == NULL) ? c->unsetOutside() : c->setOutside(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_setConstant (Compartment_t *c, int value)
{
  if (c != NULL)
    return c->setConstant( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetName (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetName();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int 
Compartment_unsetCompartmentType (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetCompartmentType();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetSize (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetSize();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetVolume (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetVolume();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetUnits (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetOutside (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetOutside();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Compartment_unsetSpatialDimensions (Compartment_t *c)
{
  if (c != NULL)
    return c->unsetSpatialDimensions();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
UnitDefinition_t * 
Compartment_getDerivedUnitDefinition(Compartment_t *c)
{
  if (c != NULL)
    return c->getDerivedUnitDefinition();
  else
    return NULL;
}


LIBSBML_EXTERN
int
Compartment_hasRequiredAttributes(Compartment_t *c)
{
  return (c != NULL) ? static_cast<int>(c->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
Compartment_t *
ListOfCompartments_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL) 
    return (sid != NULL) ? 
    static_cast <ListOfCompartments *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
Compartment_t *
ListOfCompartments_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
            static_cast <ListOfCompartments *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

