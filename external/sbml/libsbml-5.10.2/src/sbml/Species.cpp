/**
 * @file    Species.cpp
 * @brief   Implementations of Species and ListOfSpecies.
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
#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/Species.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Species::Species (unsigned int level, unsigned int version) :
   SBase ( level, version )
  , mId                       ( ""    )
  , mName                     ( ""    )
  , mSpeciesType              ( ""    )
  , mCompartment              ( ""    )
  , mInitialAmount            ( 0.0   )
  , mInitialConcentration     ( 0.0   )
  , mSubstanceUnits           ( ""    )
  , mSpatialSizeUnits         ( ""    )
  , mHasOnlySubstanceUnits    ( false )
  , mBoundaryCondition        ( false )
  , mCharge                   ( 0     )
  , mConstant                 ( false )
  , mIsSetInitialAmount       ( false )
  , mIsSetInitialConcentration( false )
  , mIsSetCharge              ( false )
  , mConversionFactor         ( ""    )
  , mIsSetBoundaryCondition   ( false )
  , mIsSetHasOnlySubstanceUnits (false )
  , mIsSetConstant             ( false )
  , mExplicitlySetBoundaryCondition ( false )
  , mExplicitlySetConstant          ( false )
  , mExplicitlySetHasOnlySubsUnits  ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  // if level 3 values have no defaults
  if (level == 3)
  {
    mInitialAmount = numeric_limits<double>::quiet_NaN();
    mInitialConcentration = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 bc hOSU and constant were set by default
  if (level < 3)
  {
    mIsSetBoundaryCondition = true;
  }
  if (level == 2)
  {
    mIsSetHasOnlySubstanceUnits = true;
    mIsSetConstant = true;
  }
}


Species::Species (SBMLNamespaces *sbmlns) :
    SBase                     ( sbmlns    )
  , mId                       ( ""    )
  , mName                     ( ""    )
  , mSpeciesType              ( ""    )
  , mCompartment              ( ""    )
  , mInitialAmount            ( 0.0   )
  , mInitialConcentration     ( 0.0   )
  , mSubstanceUnits           ( ""    )
  , mSpatialSizeUnits         ( ""    )
  , mHasOnlySubstanceUnits    ( false )
  , mBoundaryCondition        ( false )
  , mCharge                   ( 0     )
  , mConstant                 ( false )
  , mIsSetInitialAmount       ( false )
  , mIsSetInitialConcentration( false )
  , mIsSetCharge              ( false )
  , mConversionFactor         ( ""    )
  , mIsSetBoundaryCondition   ( false )
  , mIsSetHasOnlySubstanceUnits (false )
  , mIsSetConstant             ( false )
  , mExplicitlySetBoundaryCondition ( false )
  , mExplicitlySetConstant          ( false )
  , mExplicitlySetHasOnlySubsUnits  ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  // if level 3 values have no defaults
  if (sbmlns->getLevel() == 3)
  {
    mInitialAmount = numeric_limits<double>::quiet_NaN();
    mInitialConcentration = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 bc hOSU and constant were set by default
  if (sbmlns->getLevel() < 3)
  {
    mIsSetBoundaryCondition = true;
  }
  if (sbmlns->getLevel() == 2)
  {
    mIsSetHasOnlySubstanceUnits = true;
    mIsSetConstant = true;
  }

  loadPlugins(sbmlns);
}


/*
 * Destroys this Species.
 */
Species::~Species ()
{
}


/*
 * Copy constructor. Creates a copy of this Species.
 */
Species::Species(const Species& orig) :
   SBase             ( orig                    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mId                         = orig.mId;
    mName                       = orig.mName;
    mSpeciesType                = orig.mSpeciesType;
    mCompartment                = orig.mCompartment;
    mInitialAmount              = orig.mInitialAmount;
    mInitialConcentration       = orig.mInitialConcentration;
    mSubstanceUnits             = orig.mSubstanceUnits;
    mSpatialSizeUnits           = orig.mSpatialSizeUnits;
    mHasOnlySubstanceUnits      = orig.mHasOnlySubstanceUnits;
    mBoundaryCondition          = orig.mBoundaryCondition;
    mCharge                     = orig.mCharge;
    mConstant                   = orig.mConstant;
    mIsSetInitialAmount         = orig.mIsSetInitialAmount;
    mIsSetInitialConcentration  = orig.mIsSetInitialConcentration;
    mIsSetCharge                = orig.mIsSetCharge;
    mConversionFactor           = orig.mConversionFactor;
    mIsSetBoundaryCondition     = orig.mIsSetBoundaryCondition;
    mIsSetHasOnlySubstanceUnits = orig.mIsSetHasOnlySubstanceUnits;
    mIsSetConstant              = orig.mIsSetConstant;
    mExplicitlySetBoundaryCondition = orig.mExplicitlySetBoundaryCondition;
    mExplicitlySetConstant          = orig.mExplicitlySetConstant;
    mExplicitlySetHasOnlySubsUnits  = orig.mExplicitlySetHasOnlySubsUnits;
  }
}


/*
 * Assignment operator.
 */
Species& Species::operator=(const Species& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    this->mId = rhs.mId;
    this->mName = rhs.mName;
    this->mSpeciesType = rhs.mSpeciesType;
    this->mCompartment = rhs.mCompartment;

    this->mInitialAmount = rhs.mInitialAmount;
    this->mInitialConcentration = rhs.mInitialConcentration;

    this->mSubstanceUnits = rhs.mSubstanceUnits;
    this->mSpatialSizeUnits = rhs.mSpatialSizeUnits;

    this->mHasOnlySubstanceUnits = rhs.mHasOnlySubstanceUnits;
    this->mBoundaryCondition = rhs.mBoundaryCondition;
    this->mCharge = rhs.mCharge;
    this->mConstant = rhs.mConstant;

    this->mIsSetInitialAmount = rhs.mIsSetInitialAmount;
    this->mIsSetInitialConcentration = rhs.mIsSetInitialConcentration;
    this->mIsSetCharge = rhs.mIsSetCharge;
    this->mConversionFactor         = rhs.mConversionFactor;
    this->mIsSetBoundaryCondition   = rhs.mIsSetBoundaryCondition;
    this->mIsSetHasOnlySubstanceUnits = rhs.mIsSetHasOnlySubstanceUnits;
    this->mIsSetConstant             = rhs.mIsSetConstant;
    this->mExplicitlySetBoundaryCondition = rhs.mExplicitlySetBoundaryCondition;
    this->mExplicitlySetConstant          = rhs.mExplicitlySetConstant;
    this->mExplicitlySetHasOnlySubsUnits  = rhs.mExplicitlySetHasOnlySubsUnits;
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Model's next
 * Species (if available).
 */
bool
Species::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Species.
 */
Species*
Species::clone () const
{
  return new Species(*this);
}


/*
 * Initializes the fields of this Species to their defaults:
 *
 *   - boundaryCondition     = false
 *   - constant              = false  (L2 only)
 *   - hasOnlySubstanceUnits = false  (L2 only)
 */
void
Species::initDefaults ()
{
  setBoundaryCondition     (false);
  setConstant              (false);
  setHasOnlySubstanceUnits (false);

  if (getLevel() > 2)
  {
    setSubstanceUnits("mole");
  }
}


/*
 * @return the id of this SBML object.
 */
const string&
Species::getId () const
{
  return mId;
}


/*
 * @return the name of this SBML object.
 */
const string&
Species::getName () const
{
  return (getLevel() == 1) ? mId : mName;
}


/*
 * @return the speciesType of this Species.
 */
const string&
Species::getSpeciesType () const
{
  return mSpeciesType;
}


/*
 * @return the compartment of this Species.
 */
const string&
Species::getCompartment () const
{
  return mCompartment;
}


/*
 * @return the initialAmount of this Species.
 */
double
Species::getInitialAmount () const
{
  double initialAmount = mInitialAmount;
  
  // need to cover case where user has changed level 
  // and expects an initial amount where there was none
  if ( getLevel() == 1 && isSetInitialConcentration() )
  {
    const Compartment *c = getModel()->getCompartment(getCompartment());
    if (c != NULL)
    {
      initialAmount = mInitialConcentration * c->getSize();
    }
  }

  return initialAmount;
}


/*
 * @return the initialConcentration of this Species.
 */
double
Species::getInitialConcentration () const
{
  return mInitialConcentration;
}


/*
 * @return the substanceUnits of this Species.
 */
const string&
Species::getSubstanceUnits () const
{
  return mSubstanceUnits;
}


/*
 * @return the spatialSizeUnits of this Species.
 */
const string&
Species::getSpatialSizeUnits () const
{
  return mSpatialSizeUnits;
}


/*
 * @return the units of this Species (L1 only).
 */
const string&
Species::getUnits () const
{
  return mSubstanceUnits;
}


/*
 * @return true if this Species hasOnlySubstanceUnits, false otherwise.
 */
bool
Species::getHasOnlySubstanceUnits () const
{
  return mHasOnlySubstanceUnits;
}


/*
 * @return true if this Species has boundaryCondition
 * true, false otherwise.
 */
bool
Species::getBoundaryCondition () const
{
  return mBoundaryCondition;
}


/*
 * @return the charge of this Species.
 */
int
Species::getCharge () const
{
  return mCharge;
}


/*
 * @return true if this Species is constant, false otherwise.
 */
bool
Species::getConstant () const
{
  return mConstant;
}


/*
 * @return the conversionFactor of this Species, as a string.
 */
const std::string& 
Species::getConversionFactor () const
{
  return mConversionFactor;
}


/*
 * @return true if the id of this SBML object has been set, false
 * otherwise.
 */
bool
Species::isSetId () const
{
  return (mId.empty() == false);
}


/*
 * @return true if the name of this SBML object is set, false
 * otherwise.
 */
bool
Species::isSetName () const
{
  return (getLevel() == 1) ? (mId.empty() == false) : 
                            (mName.empty() == false);
}


/*
 * @return true if the speciesType of this Species is set, false
 * otherwise.
 */
bool
Species::isSetSpeciesType () const
{
  return (mSpeciesType.empty() == false);
}


/*
 * @return true if the compartment of this Species is set, false
 * otherwise.
 */
bool
Species::isSetCompartment () const
{
  return (mCompartment.empty() == false);
}


/*
 * @return true if the initialAmount of this Species is set, false
 * otherwise.
 *
 * In SBML L1, a Species initialAmount is required and therefore <b>should
 * always be set</b>.  In L2, initialAmount is optional and as such may or
 * may not be set.
 */
bool
Species::isSetInitialAmount () const
{
  return mIsSetInitialAmount;
}


/*
 * @return true if the initialConcentration of this Species is set,
 * false otherwise.
 */
bool
Species::isSetInitialConcentration () const
{
  return mIsSetInitialConcentration;
}


/*
 * @return true if the substanceUnits of this Species is set, false
 * otherwise.
 */
bool
Species::isSetSubstanceUnits () const
{
  return (mSubstanceUnits.empty() == false);
}


/*
 * @return true if the spatialSizeUnits of this Species is set, false
 * otherwise.
 */
bool
Species::isSetSpatialSizeUnits () const
{
  return (mSpatialSizeUnits.empty() == false);
}


/*
 * @return true if the units of this Species is set, false otherwise
 * (L1 only).
 */
bool
Species::isSetUnits () const
{
  return isSetSubstanceUnits();
}


/*
 * @return true if the charge of this Species is set, false
 * otherwise.
 */
bool
Species::isSetCharge () const
{
  return mIsSetCharge;
}


/*
 * @return true if the conversionFactor of this Species is set, false
 * otherwise.
 */
bool
Species::isSetConversionFactor () const
{
  return (mConversionFactor.empty() == false);
}


/*
 * Predicate returning @c true if this
 * Species's "boundaryCondition" attribute is set.
 */
bool 
Species::isSetBoundaryCondition () const
{
  return mIsSetBoundaryCondition;
}


/*
 * Predicate returning @c true if this
 * Species's "hasOnlySubstanceUnits" attribute is set.
 */
bool 
Species::isSetHasOnlySubstanceUnits () const
{
  return mIsSetHasOnlySubstanceUnits;
}


/*
 * Predicate returning @c true if this
 * Species's "constant" attribute is set.
 */
bool 
Species::isSetConstant () const
{
  return mIsSetConstant;
}


/*
 * Sets the id of this SBML object to a copy of sid.
 */
int
Species::setId (const std::string& sid)
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
Species::setName (const std::string& name)
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
 * Sets the speciesType field of this Species to a copy of sid.
 */
int
Species::setSpeciesType (const std::string& sid)
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
    mSpeciesType = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the compartment of this Species to a copy of sid.
 */
int
Species::setCompartment (const std::string& sid)
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
    mCompartment = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the initialAmount of this Species to value and marks the field as
 * set.  This method also unsets the initialConcentration field.
 */
int
Species::setInitialAmount (double value)
{
  mInitialAmount      = value;
  mIsSetInitialAmount = true;

  unsetInitialConcentration();
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the initialConcentration of this Species to value and marks the
 * field as set.  This method also unsets the initialAmount field.
 */
int
Species::setInitialConcentration (double value)
{
  if ( getLevel() < 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mInitialConcentration      = value;
    mIsSetInitialConcentration = true;

    unsetInitialAmount();
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the substanceUnits of this Species to a copy of sid.
 */
int
Species::setSubstanceUnits (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSubstanceUnits = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the spatialSizeUnits of this Species to a copy of sid.
 */
int
Species::setSpatialSizeUnits (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  if ( (getLevel() != 2)
    || (getLevel() == 2 && getVersion() > 2))
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSpatialSizeUnits = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the units of this Species to a copy of sname (L1 only).
 */
int
Species::setUnits (const std::string& sname)
{
  return setSubstanceUnits(sname);
}


/*
 * Sets the hasOnlySubstanceUnits field of this Species to value.
 */
int
Species::setHasOnlySubstanceUnits (bool value)
{
  if (getLevel() < 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mHasOnlySubstanceUnits = value;
    mIsSetHasOnlySubstanceUnits = true;
    mExplicitlySetHasOnlySubsUnits = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the boundaryCondition of this Species to value.
 */
int
Species::setBoundaryCondition (bool value)
{
  mBoundaryCondition = value;
  mIsSetBoundaryCondition = true;
  mExplicitlySetBoundaryCondition = true;
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the charge of this Species to value and marks the field as set.
 */
int
Species::setCharge (int value)
{
  if ( !((getLevel() == 1)
    || (getLevel() == 2 && getVersion() == 1)))
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mCharge      = value;
    mIsSetCharge = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the constant field of this Species to value.
 */
int
Species::setConstant (bool value)
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
    mExplicitlySetConstant = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the conversionFactor field of this Species to a copy of sid.
 */
int
Species::setConversionFactor (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else  if (getLevel() < 3)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mConversionFactor = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Unsets the name of this SBML object.
 */
int
Species::unsetName ()
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
 * Unsets the speciesType of this Species.
 */
int
Species::unsetSpeciesType ()
{
  mSpeciesType.erase();

  if (mSpeciesType.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the initialAmount of this Species.
 */
int
Species::unsetInitialAmount ()
{
  mInitialAmount      = numeric_limits<double>::quiet_NaN();
  mIsSetInitialAmount = false;
  
  if (!isSetInitialAmount())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the initialConcentration of this Species.
 */
int
Species::unsetInitialConcentration ()
{
  mInitialConcentration      = numeric_limits<double>::quiet_NaN();
  mIsSetInitialConcentration = false;

  if (!isSetInitialConcentration())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the substanceUnits of this Species.
 */
int
Species::unsetSubstanceUnits ()
{
  mSubstanceUnits.erase();
  
  if (mSubstanceUnits.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the spatialSizeUnits of this Species.
 */
int
Species::unsetSpatialSizeUnits ()
{
  mSpatialSizeUnits.erase();

  if (mSpatialSizeUnits.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the units of this Species (L1 only).
 */
int
Species::unsetUnits ()
{
  return unsetSubstanceUnits();
}


/*
 * Unsets the charge of this Species.
 */
int
Species::unsetCharge ()
{
  if ( !((getLevel() == 1)
    || (getLevel() == 2 && getVersion() == 1)))
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }

  mCharge      = 0;
  mIsSetCharge = false;

  if (!isSetCharge())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }    
}


/*
 * Unsets the conversionFactor of this Species.
 */
int
Species::unsetConversionFactor ()
{
  /* only in L3 */
  if (getLevel() < 3)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }

  mConversionFactor.erase();

  if (mConversionFactor.empty()) 
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
  * Species.
  */
UnitDefinition *
Species::getDerivedUnitDefinition()
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
Species::getDerivedUnitDefinition() const
{
  return const_cast <Species *> (this)->getDerivedUnitDefinition();
}


/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
Species::getTypeCode () const
{
  return SBML_SPECIES;
}


/*
 * @return the name of this element ie "specie" (L1) or "species" (L2).
 */
const string&
Species::getElementName () const
{
  static const string specie  = "specie";
  static const string species = "species";

  return (getLevel() == 1 && getVersion() == 1) ? specie : species;
}


bool 
Species::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for species: 
   * @li id (name L1)
   * @li compartment
   * @li initialAmount (L1 only)
   * @li hasOnlySubstanceUnits (L3 on)
   * @li boundaryCondition (L3 on)
   * @li constant (L3 on)
   */

  if (!isSetId())
    allPresent = false;

  if (!isSetCompartment())
    allPresent = false;

  if (getLevel() == 1 && !isSetInitialAmount())
    allPresent = false;

  if (getLevel() > 2 && !isSetHasOnlySubstanceUnits())
    allPresent = false;

  if (getLevel() > 2 && !isSetBoundaryCondition())
    allPresent = false;

  if (getLevel() > 2 && !isSetConstant())
    allPresent = false;

  return allPresent;
}


void
Species::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetSpeciesType()) {
    if (mSpeciesType==oldid) setSpeciesType(newid);
  }
  if (isSetCompartment()) {
    if (mCompartment==oldid) setCompartment(newid);
  }
  if (isSetConversionFactor()) {
    if (mConversionFactor==oldid) setConversionFactor(newid);
  }
}

void 
Species::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetSubstanceUnits()) {
    if (mSubstanceUnits==oldid) setSubstanceUnits(newid);
  }
  if (isSetSpatialSizeUnits()) {
    if (mSpatialSizeUnits==oldid) setSpatialSizeUnits(newid);
  }
}

/** @cond doxygenLibsbmlInternal */
/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
Species::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  switch (level)
  {
  case 1:
    attributes.add("name");
    attributes.add("compartment");
    attributes.add("initialAmount");
    attributes.add("boundaryCondition");
    attributes.add("charge");
    attributes.add("units");
    break;
  case 2:
    attributes.add("name");
    attributes.add("compartment");
    attributes.add("initialAmount");
    attributes.add("boundaryCondition");
    attributes.add("charge");
    attributes.add("id");
    attributes.add("initialConcentration");
    attributes.add("substanceUnits");
    attributes.add("hasOnlySubstanceUnits");
    attributes.add("constant");
    if (version > 1)
    {
      attributes.add("speciesType");
    }
    if (version < 3)
    {
      attributes.add("spatialSizeUnits");
    }
    break;
  case 3:
  default:
    attributes.add("name");
    attributes.add("compartment");
    attributes.add("initialAmount");
    attributes.add("boundaryCondition");
    attributes.add("charge");
    attributes.add("id");
    attributes.add("initialConcentration");
    attributes.add("substanceUnits");
    attributes.add("hasOnlySubstanceUnits");
    attributes.add("constant");
    attributes.add("conversionFactor");
    break;
  }
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Species::readAttributes (const XMLAttributes& attributes,
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
Species::readL1Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();
 
  //
  // name: SName   { use="required" }  (L1v1, L1v2)
  //
  bool assigned = attributes.readInto("name", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("name", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // compartment: SName  { use="required" }  (L1v1, L2v1)
  //
  attributes.readInto("compartment", mCompartment, getErrorLog(), true, getLine(), getColumn());

  //
  // initialAmount: double  { use="required" }  (L1v1, L1v2)
  //
  mIsSetInitialAmount = attributes.readInto("initialAmount", mInitialAmount,
                                                  getErrorLog(), true, getLine(), getColumn());

  //
  //          units: SName  { use="optional" }  (L1v1, L1v2)
  //
  assigned = attributes.readInto("units", mSubstanceUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mSubstanceUnits.size() == 0)
  {
    logEmptyString("units", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mSubstanceUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // boundaryCondition: boolean
  // { use="optional" default="false" }  (L1v1, L1v2, L2v1->)
  //
  mExplicitlySetBoundaryCondition = 
                 attributes.readInto("boundaryCondition", mBoundaryCondition, getErrorLog(), false, getLine(), getColumn());

  //
  // charge: integer  { use="optional" }  (L1v1, L1v2, L2v1)
  //
  mIsSetCharge = attributes.readInto("charge", mCharge, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Species::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();
  //
  //   id: SId     { use="required" }  (L2v1->)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), true, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // compartment: SId    { use="required" }  (L2v1->)
  //
  attributes.readInto("compartment", mCompartment, getErrorLog(), true, getLine(), getColumn());

  //
  // initialAmount: double  { use="optional" }  (L2v1->)
  //
  mIsSetInitialAmount = attributes.readInto("initialAmount", mInitialAmount, getErrorLog(), false, getLine(), getColumn());

  //
  // substanceUntis: SId    { use="optional" }  (L2v1->)
  //
  assigned = attributes.readInto("substanceUnits", mSubstanceUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mSubstanceUnits.size() == 0)
  {
    logEmptyString("substanceUnits", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mSubstanceUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // boundaryCondition: boolean
  // { use="optional" default="false" }  (L1v1, L1v2, L2v1->)
  //
  mExplicitlySetBoundaryCondition = 
             attributes.readInto("boundaryCondition", mBoundaryCondition, getErrorLog(), false, getLine(), getColumn());

  //
  // charge: integer  { use="optional" }  (L1v1, L1v2, L2v1)
  // charge: integer  { use="optional" }  deprecated (L2v2)
  //
  mIsSetCharge = attributes.readInto("charge", mCharge, getErrorLog(), false, getLine(), getColumn());

  //
  // name: string  { use="optional" }  (L2v1->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());

  //
  // speciesType: SId  { use="optional" }  (L2v2-> L2v4)
  //
  if (version > 1)
  {
    attributes.readInto("speciesType", mSpeciesType, getErrorLog(), false, getLine(), getColumn());
  }

  //
  // initialConcentration: double  { use="optional" }  (L2v1->)
  //
  mIsSetInitialConcentration =
      attributes.readInto("initialConcentration", mInitialConcentration, getErrorLog(),false, getLine(), getColumn());

  //
  // spatialSizeUnits: SId  { use="optional" }  (L2v1, L2v2) removed in l2v3
  //
  if (version < 3)
  {
    assigned = attributes.readInto("spatialSizeUnits", mSpatialSizeUnits, getErrorLog(), false, getLine(), getColumn());
    if (assigned && mSpatialSizeUnits.size() == 0)
    {
      logEmptyString("spatialSizeUnits", level, version, "<species>");
    }
    if (!SyntaxChecker::isValidInternalUnitSId(mSpatialSizeUnits))
    {
      logError(InvalidUnitIdSyntax);
    }
  }

  //
  // hasOnlySubstanceUnits: boolean
  // { use="optional" default="false" }  (L2v1->)
  //
  mExplicitlySetHasOnlySubsUnits = 
    attributes.readInto("hasOnlySubstanceUnits", mHasOnlySubstanceUnits, getErrorLog(), false, getLine(), getColumn());

  //
  // constant: boolean  { use="optional" default="false" }  (L2v1->)
  //
  mExplicitlySetConstant = attributes.readInto("constant", mConstant, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Species::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  //   id: SId     { use="required" }  (L2v1->)
  //
  bool assigned = attributes.readInto("id", mId, getErrorLog(), 
                                      false, getLine(), getColumn());
  if (!assigned)
  {
    logError(AllowedAttributesOnSpecies, level, version, 
             "The required attribute 'id' is missing.");
  }
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // compartment: SId    { use="required" }  (L2v1->)
  //
  assigned = attributes.readInto("compartment", mCompartment, getErrorLog(), 
                                 false, getLine(), getColumn());
  if (!assigned)
  {
    logError(MissingSpeciesCompartment, level, version);
  }

  //
  // initialAmount: double  { use="optional" }  (L2v1->)
  //
  mIsSetInitialAmount = attributes.readInto("initialAmount", mInitialAmount, getErrorLog(), false, getLine(), getColumn());

  //
  // substanceUntis: SId    { use="optional" }  (L2v1->)
  //
  const string units = (level == 1) ? "units" : "substanceUnits";
  assigned = attributes.readInto(units, mSubstanceUnits, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mSubstanceUnits.size() == 0)
  {
    logEmptyString("substanceUnits", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalUnitSId(mSubstanceUnits))
  {
    logError(InvalidUnitIdSyntax);
  }

  //
  // boundaryCondition: boolean
  // { use="required" }  (L3v1->)
  //
  mIsSetBoundaryCondition = attributes.readInto("boundaryCondition", 
                               mBoundaryCondition, getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetBoundaryCondition)
  {
    logError(AllowedAttributesOnSpecies, level, version, 
             "The required attribute 'boundaryCondition' is missing.");
  }

  //
  // name: string  { use="optional" }  (L2v1->)
  //
  attributes.readInto("name", mName, getErrorLog(), false, getLine(), getColumn());

  //
  // initialConcentration: double  { use="optional" }  (L2v1->)
  //
  mIsSetInitialConcentration =
        attributes.readInto("initialConcentration", mInitialConcentration, getErrorLog(), false, getLine(), getColumn());

  //
  // hasOnlySubstanceUnits: boolean
  // { use="required" } (L3v1 -> )
  mIsSetHasOnlySubstanceUnits = attributes.readInto(
                         "hasOnlySubstanceUnits", mHasOnlySubstanceUnits,
                          getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetHasOnlySubstanceUnits)
  {
    logError(AllowedAttributesOnSpecies, level, version, 
             "The required attribute 'hasOnlySubstanceUnits' is missing.");
  }

  //
  // constant: boolean  { use="required" }  (L3v1->)
  //
  mIsSetConstant = attributes.readInto("constant", mConstant, getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetConstant)
  {
    logError(AllowedAttributesOnSpecies, level, version, 
             "The required attribute 'constant' is missing.");
  }

  //
  // conversionFactor: SIdRef {use="optional" } (L3v1 ->)
  //
  assigned = attributes.readInto("conversionFactor", mConversionFactor, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mConversionFactor.size() == 0)
  {
    logEmptyString("conversionFactor", level, version, "<species>");
  }
  if (!SyntaxChecker::isValidInternalSId(mConversionFactor))
  {
    logError(InvalidIdSyntax, getLevel(), getVersion(), 
      "The syntax of the attribute conversionFactor='" + mConversionFactor 
      + "' does not conform.");
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
Species::writeElements (XMLOutputStream& stream) const
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
 */
void
Species::writeAttributes (XMLOutputStream& stream) const
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
    // speciesType: SId  { use="optional" }  (L2v2->)
    //
    if (level == 2 && version > 1)
    {
      stream.writeAttribute("speciesType", mSpeciesType);
    }
  }

  //
  // compartment: SName  { use="required" }  (L1v1, L2v1)
  // compartment: SId    { use="required" }  (L2v1->)
  //
  stream.writeAttribute("compartment", mCompartment);

  //
  // initialAmount: double  { use="required" }  (L1v1, L1v2)
  // initialAmount: double  { use="optional" }  (L2v1->)
  //
  if ( isSetInitialAmount() )
  {
    stream.writeAttribute("initialAmount", mInitialAmount);
  }

  //
  // initialConcentration: double  { use="optional" }  (L2v1-> )
  //
  else if ( level > 1 && isSetInitialConcentration() )
  {
    stream.writeAttribute("initialConcentration", mInitialConcentration);
  }

  //
  // If user is converting a model from L2 to L1, two possiblities exist
  // that have not been covered:
  //
  //   1.  InitialConcentration has been used, so it must be converted to
  //       initialAmount
  //
  //   2.  No initialAmount/initialAmount has been set, but initialAmount
  //       is required in L1
  //
  else if (level == 1)
  {
    if ( isSetInitialConcentration() )
    {
      const Model*       m = getModel();
      const Compartment* c = m ? m->getCompartment( getCompartment() ) : NULL;

      if (c != NULL)
      {
        double amount = mInitialConcentration * c->getSize();
        stream.writeAttribute("initialAmount", amount);
      }
      else
      {
        stream.writeAttribute("initialAmount", mInitialConcentration);
      }
    }
    else
    {
      stream.writeAttribute("initialAmount", mInitialAmount);
    }
  }

  //
  //          units: SName  { use="optional" }  (L1v1, L1v2)
  // substanceUntis: SId    { use="optional" }  (L2v1->)
  //
  const string units = (level == 1) ? "units" : "substanceUnits";
  stream.writeAttribute( units, getUnits() );

  if (level > 1)
  {
    if (level == 2 && version < 3)
    {
      //
      // spatialSizeUnits: SId  { use="optional" }  (L2v1, L2v2)
      //
      stream.writeAttribute("spatialSizeUnits", mSpatialSizeUnits);
    }

    //
    // hasOnlySubstanceUnits: boolean
    // { use="optional" default="false" }  (L2v1->)
    // { use="required" }  (L3v1->)
    //
    if (level == 2 && 
      (mHasOnlySubstanceUnits || isExplicitlySetHasOnlySubsUnits()))
    {
      stream.writeAttribute( "hasOnlySubstanceUnits", 
                              mHasOnlySubstanceUnits );
    }
    else if (level > 2)
    {
      // in L3 only write it out if it has been set
      if (isSetHasOnlySubstanceUnits())
        stream.writeAttribute( "hasOnlySubstanceUnits", 
                              mHasOnlySubstanceUnits );
    }
  }

  //
  // boundaryCondition: boolean
  // { use="optional" default="false" }  (L1v1, L1v2, L2v1->)
  // { use="required" }  (L3v1->)
  //
  if (level < 3)
  {
    if (mBoundaryCondition || isExplicitlySetBoundaryCondition())
      stream.writeAttribute("boundaryCondition", mBoundaryCondition);
  }
  else
  {
    // in L3 only write it out if it has been set
    if (isSetBoundaryCondition())
      stream.writeAttribute("boundaryCondition", mBoundaryCondition);
  }


  //
  // charge: integer  { use="optional" }  (L1v1, L1v2, L2v1)
  // charge: integer  { use="optional" }  deprecated (L2v2)
  //
  if ( level < 3 && !(level == 2 && version > 2) && isSetCharge() )
  {
    stream.writeAttribute("charge", mCharge);
  }

  if (level > 1)
  {
    //
    // constant: boolean  { use="optional" default="false" }  (L2v1->)
    // constant: boolean  { use="required" }  (L3v1->)
    //
    if (level == 2 && 
      (mConstant != false || isExplicitlySetConstant()))
    {
      stream.writeAttribute("constant", mConstant);
    }
    else if (level > 2)
    {
      // in L3 only write it out if it has been set
      if (isSetConstant())
        stream.writeAttribute("constant", mConstant);
    }

    //
    // sboTerm: SBOTerm { use="optional" }  (L2v3->)
    // is written in SBase::writeAttributes()
    //
  }

  if (level > 2)
  {
    stream.writeAttribute("conversionFactor", mConversionFactor);
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Creates a new ListOfSpecies items.
 */
ListOfSpecies::ListOfSpecies (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfSpecies items.
 */
ListOfSpecies::ListOfSpecies (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfSpecies.
 */
ListOfSpecies*
ListOfSpecies::clone () const
{
  return new ListOfSpecies(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfSpecies::getItemTypeCode () const
{
  return SBML_SPECIES;
}


/*
 * @return the name of this element ie "listOfSpecies".
 */
const string&
ListOfSpecies::getElementName () const
{
  static const string name = "listOfSpecies";
  return name;
}


/* return nth item in list */
Species *
ListOfSpecies::get(unsigned int n)
{
  return static_cast<Species*>(ListOf::get(n));
}


/* return nth item in list */
const Species *
ListOfSpecies::get(unsigned int n) const
{
  return static_cast<const Species*>(ListOf::get(n));
}


/**
 * Used by ListOf::get() to lookup an SBase based by its id.
 */
struct IdEqS : public unary_function<SBase*, bool>
{
  const string& id;

  IdEqS (const string& id) : id(id) { }
  bool operator() (SBase* sb) 
       { return static_cast <Species *> (sb)->getId() == id; }
};
/* return item by id */
Species*
ListOfSpecies::get (const std::string& sid)
{
  return const_cast<Species*>( 
    static_cast<const ListOfSpecies&>(*this).get(sid) );
}


/* return item by id */
const Species*
ListOfSpecies::get (const std::string& sid) const
{
  vector<SBase*>::const_iterator result;

  if (&(sid) == NULL)
  {
    return NULL;
  }
  else
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqS(sid) );
    return (result == mItems.end()) ? NULL : static_cast <Species*> (*result);
  }
}


/* Removes the nth item from this list */
Species*
ListOfSpecies::remove (unsigned int n)
{
   return static_cast<Species*>(ListOf::remove(n));
}


/* Removes item in this list by id */
Species*
ListOfSpecies::remove (const std::string& sid)
{
  SBase* item = NULL;
  vector<SBase*>::iterator result;

  if (&(sid) != NULL)
  {
    result = find_if( mItems.begin(), mItems.end(), IdEqS(sid) );

    if (result != mItems.end())
    {
      item = *result;
      mItems.erase(result);
    }
  }

  return static_cast <Species*> (item);
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
ListOfSpecies::getElementPosition () const
{
  return 6;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfSpecies::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "species" || name == "specie")
  {
    try
    {
      object = new Species(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new Species(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new Species(SBMLDocument::getDefaultLevel(),
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
Species_t *
Species_create (unsigned int level, unsigned int version)
{
  try
  {
    Species* obj = new Species(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Species_t *
Species_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Species* obj = new Species(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
Species_free (Species_t *s)
{
  if (s != NULL)
  delete s;
}


LIBSBML_EXTERN
Species_t *
Species_clone (const Species_t *s)
{
  return (s != NULL) ? static_cast<Species*>( s->clone() ) : NULL;
}


LIBSBML_EXTERN
void
Species_initDefaults (Species_t *s)
{
  if (s != NULL)
    s->initDefaults();
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Species_getNamespaces(Species_t *s)
{
  return (s != NULL) ? s->getNamespaces() : NULL;
}

LIBSBML_EXTERN
const char *
Species_getId (const Species_t *s)
{
  return (s != NULL && s->isSetId()) ? s->getId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Species_getName (const Species_t *s)
{
  return (s != NULL && s->isSetName()) ? s->getName().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Species_getSpeciesType (const Species_t *s)
{
  return (s != NULL && s->isSetSpeciesType()) ? 
                       s->getSpeciesType().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Species_getCompartment (const Species_t *s)
{
  return (s != NULL && s->isSetCompartment()) ? 
                       s->getCompartment().c_str() : NULL;
}


LIBSBML_EXTERN
double
Species_getInitialAmount (const Species_t *s)
{
  return (s != NULL) ? s->getInitialAmount() : 
                       numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
double
Species_getInitialConcentration (const Species_t *s)
{
  return (s != NULL) ? s->getInitialConcentration() : 
                       numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
const char *
Species_getSubstanceUnits (const Species_t *s)
{
  return (s != NULL && s->isSetSubstanceUnits()) ? 
                       s->getSubstanceUnits().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Species_getSpatialSizeUnits (const Species_t *s)
{
  return (s != NULL && s->isSetSpatialSizeUnits()) ? 
                       s->getSpatialSizeUnits().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
Species_getUnits (const Species_t *s)
{
  return (s != NULL && s->isSetUnits()) ? s->getUnits().c_str() : NULL;
}


LIBSBML_EXTERN
int
Species_getHasOnlySubstanceUnits (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->getHasOnlySubstanceUnits() ) : 0;
}


LIBSBML_EXTERN
int
Species_getBoundaryCondition (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->getBoundaryCondition() ) : 0;
}


LIBSBML_EXTERN
int
Species_getCharge (const Species_t *s)
{ 
  return (s != NULL) ? s->getCharge() : SBML_INT_MAX;
}


LIBSBML_EXTERN
int
Species_getConstant (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->getConstant() ) : 0;
}


LIBSBML_EXTERN
const char *
Species_getConversionFactor (const Species_t *s)
{
  return (s != NULL && s->isSetConversionFactor()) ? 
                       s->getConversionFactor().c_str() : NULL;
}


LIBSBML_EXTERN
int
Species_isSetId (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetId() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetName (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetName() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetSpeciesType (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetSpeciesType() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetCompartment (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetCompartment() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetInitialAmount (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetInitialAmount() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetInitialConcentration (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetInitialConcentration() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetSubstanceUnits (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetSubstanceUnits() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetSpatialSizeUnits (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetSpatialSizeUnits() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetUnits (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetUnits() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetCharge (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetCharge() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetConversionFactor (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetConversionFactor() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetConstant (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetConstant() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetBoundaryCondition (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetBoundaryCondition() ) : 0;
}


LIBSBML_EXTERN
int
Species_isSetHasOnlySubstanceUnits (const Species_t *s)
{
  return (s != NULL) ? static_cast<int>( s->isSetHasOnlySubstanceUnits() ) : 0;
}


LIBSBML_EXTERN
int
Species_setId (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->setId("") : s->setId(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setName (Species_t *s, const char *name)
{
  if (s != NULL)
    return (name == NULL) ? s->unsetName() : s->setName(name);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setSpeciesType (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->unsetSpeciesType() : s->setSpeciesType(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setCompartment (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->setCompartment("") : s->setCompartment(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setInitialAmount (Species_t *s, double value)
{
  if (s != NULL)
    return s->setInitialAmount(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setInitialConcentration (Species_t *s, double value)
{
  if (s != NULL)
    return s->setInitialConcentration(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setSubstanceUnits (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->unsetSubstanceUnits() : s->setSubstanceUnits(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setSpatialSizeUnits (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->unsetSpatialSizeUnits() : 
                           s->setSpatialSizeUnits(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setUnits (Species_t *s, const char *sname)
{
  if (s != NULL)
    return (sname == NULL) ? s->unsetUnits() : s->setUnits(sname);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setHasOnlySubstanceUnits (Species_t *s, int value)
{
  if (s != NULL)
    return s->setHasOnlySubstanceUnits( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setBoundaryCondition (Species_t *s, int value)
{
  if (s != NULL)
    return s->setBoundaryCondition( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setCharge (Species_t *s, int value)
{
  if (s != NULL)
    return s->setCharge(value);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setConstant (Species_t *s, int value)
{
  if (s != NULL)
    return s->setConstant( static_cast<bool>(value) );
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_setConversionFactor (Species_t *s, const char *sid)
{
  if (s != NULL)
    return (sid == NULL) ? s->unsetConversionFactor() : 
                         s->setConversionFactor(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetName (Species_t *s)
{
  if (s != NULL)
    return s->unsetName();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetSpeciesType (Species_t *s)
{
  if (s != NULL)
    return s->unsetSpeciesType();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetInitialAmount (Species_t *s)
{
  if (s != NULL)
    return s->unsetInitialAmount();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetInitialConcentration (Species_t *s)
{
  if (s != NULL)
    return s->unsetInitialConcentration();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetSubstanceUnits (Species_t *s)
{
  if (s != NULL)
    return s->unsetSubstanceUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetSpatialSizeUnits (Species_t *s)
{
  if (s != NULL)
    return s->unsetSpatialSizeUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetUnits (Species_t *s)
{
  if (s != NULL)
    return s->unsetUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetCharge (Species_t *s)
{
  if (s != NULL)
    return s->unsetCharge();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Species_unsetConversionFactor (Species_t *s)
{
  if (s != NULL)
    return s->unsetConversionFactor();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
UnitDefinition_t * 
Species_getDerivedUnitDefinition(Species_t *s)
{
  return (s != NULL) ? s->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
int
Species_hasRequiredAttributes(Species_t *s)
{
  return (s != NULL) ? static_cast<int>(s->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
Species_t *
ListOfSpecies_getById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfSpecies *> (lo)->get(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
Species_t *
ListOfSpecies_removeById (ListOf_t *lo, const char *sid)
{
  if (lo != NULL)
    return (sid != NULL) ? 
      static_cast <ListOfSpecies *> (lo)->remove(sid) : NULL;
  else
    return NULL;
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
