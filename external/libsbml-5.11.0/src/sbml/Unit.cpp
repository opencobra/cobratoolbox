/**
 * @file    Unit.cpp
 * @brief   Implementations of Unit and ListOfUnits.
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
#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>

#include <sbml/extension/SBaseExtensionPoint.h>

#include <sstream>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

Unit::Unit (unsigned int level, unsigned int version) :
   SBase ( level, version )
  , mKind      ( UNIT_KIND_INVALID )
  , mExponent  ( 1   )
  , mExponentDouble  ( 1   )
  , mScale     ( 0      )
  , mMultiplier( 1.0 )
  , mOffset    ( 0.0     )
  , mIsSetExponent    ( false )
  , mIsSetScale       ( false )
  , mIsSetMultiplier  ( false )
  , mExplicitlySetExponent   ( false )
  , mExplicitlySetMultiplier ( false )
  , mExplicitlySetScale      ( false )
  , mExplicitlySetOffset     ( false )
  , mInternalUnitCheckingFlag ( false) 
{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  // if level 3 values have no defaults
  if (level == 3)
  {
    mExponentDouble = numeric_limits<double>::quiet_NaN();
    mScale = SBML_INT_MAX;//numeric_limits<int>::max();
    mMultiplier = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 exponent, scale and multiplier were set by default
  if (level < 3)
  {
    mIsSetExponent = true;
    mIsSetScale = true;
    mIsSetMultiplier = true;
  }
}


Unit::Unit (SBMLNamespaces * sbmlns) :
   SBase ( sbmlns )
  , mKind      ( UNIT_KIND_INVALID )
  , mExponent  ( 1  )
  , mExponentDouble  ( 1  )
  , mScale     ( 0      )
  , mMultiplier( 1.0 )
  , mOffset    ( 0.0     )
  , mIsSetExponent    ( false )
  , mIsSetScale       ( false )
  , mIsSetMultiplier  ( false )
  , mExplicitlySetExponent   ( false )
  , mExplicitlySetMultiplier ( false )
  , mExplicitlySetScale      ( false )
  , mExplicitlySetOffset     ( false )
  , mInternalUnitCheckingFlag ( false )
{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  // if level 3 values have no defaults
  if (sbmlns->getLevel() == 3)
  {
    mExponentDouble = numeric_limits<double>::quiet_NaN();
    mScale = numeric_limits<int>::max();
    mMultiplier = numeric_limits<double>::quiet_NaN();
  }
  // before level 3 exponent, scale and multiplier were set by default
  if (sbmlns->getLevel() < 3)
  {
    mIsSetExponent = true;
    mIsSetScale = true;
    mIsSetMultiplier = true;
  }

  loadPlugins(sbmlns);
}

                          
/*
 * Destroys the given Unit.
 */
Unit::~Unit ()
{
}


/*
 * Copy constructor. Creates a copy of this Unit.
 */
Unit::Unit(const Unit& orig) :
    SBase      ( orig             )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mKind             = orig.mKind;
    mExponent         = orig.mExponent;
    mExponentDouble   = orig.mExponentDouble;
    mScale            = orig.mScale;
    mMultiplier       = orig.mMultiplier;
    mOffset           = orig.mOffset;
    mIsSetExponent    = orig.mIsSetExponent;
    mIsSetScale       = orig.mIsSetScale;
    mIsSetMultiplier  = orig.mIsSetMultiplier;
    mExplicitlySetExponent    = orig.mExplicitlySetExponent;
    mExplicitlySetScale       = orig.mExplicitlySetScale;
    mExplicitlySetMultiplier  = orig.mExplicitlySetMultiplier;
    mExplicitlySetOffset      = orig.mExplicitlySetOffset;
    mInternalUnitCheckingFlag = orig.mInternalUnitCheckingFlag;
  }
}


/*
 * Assignment operator.
 */
Unit& Unit::operator=(const Unit& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mKind       = rhs.mKind       ;
    mExponent   = rhs.mExponent   ;
    mExponentDouble   = rhs.mExponentDouble   ;
    mScale      = rhs.mScale      ;
    mMultiplier = rhs.mMultiplier ;
    mOffset     = rhs.mOffset     ;
    mIsSetExponent    = rhs.mIsSetExponent;
    mIsSetScale       = rhs.mIsSetScale;
    mIsSetMultiplier  = rhs.mIsSetMultiplier;
    mExplicitlySetExponent    = rhs.mExplicitlySetExponent;
    mExplicitlySetScale       = rhs.mExplicitlySetScale;
    mExplicitlySetMultiplier  = rhs.mExplicitlySetMultiplier;
    mExplicitlySetOffset      = rhs.mExplicitlySetOffset;
    mInternalUnitCheckingFlag = rhs.mInternalUnitCheckingFlag;
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the UnitDefinition's next
 * Unit (if available).
 */
bool
Unit::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return a (deep) copy of this Unit.
 */
Unit*
Unit::clone () const
{
  return new Unit(*this);
}


/*
 * Initializes the fields of this Unit to their defaults:
 *
 *   - exponent   = 1
 *   - scale      = 0
 *   - multiplier = 1.0
 */
void
Unit::initDefaults ()
{
  //// level 3 has no defaults
  //if (getLevel() < 3)
  //{
    setExponent  ( 1   );
    setScale     ( 0   );
    setMultiplier( 1.0 );
    setOffset    ( 0.0 );
  //}
}


/*
 * @return the kind of this Unit.
 */
UnitKind_t
Unit::getKind () const
{
  return mKind;
}


/*
 * @return the exponent of this Unit.
 */
int
Unit::getExponent () const
{
  if (getLevel() < 3)
  {
    return mExponent;
  }
  else
  {
    if (isSetExponent())
    {
      if (ceil(mExponentDouble) == 
          floor(mExponentDouble))
      {
        return static_cast<int>(mExponentDouble);
      }
      else
      {
        return numeric_limits<int>::quiet_NaN();
      }
    }
    else
    {
      return static_cast<int>(mExponentDouble);
    }
  }
}


double
Unit::getExponentAsDouble () const
{
  if (getLevel() > 2)
    return mExponentDouble;
  else
    return static_cast<double>(mExponent);
}


/*
 * @return the scale of this Unit.
 */
int
Unit::getScale () const
{
  return mScale;
}


/*
 * @return the multiplier of this Unit.
 */
double
Unit::getMultiplier () const
{
  return mMultiplier;
}


/*
 * @return the offset of this Unit.
 */
double
Unit::getOffset () const
{
  return mOffset;
}


/*
 * @return true if the kind of this Unit is 'ampere', false otherwise.
 */
bool
Unit::isAmpere () const
{
  return (mKind == UNIT_KIND_AMPERE);
}


/*
 * @return true if the kind of this Unit is 'avogadro', false otherwise.
 */
bool
Unit::isAvogadro () const
{
  return (mKind == UNIT_KIND_AVOGADRO);
}


/*
 * @return true if the kind of this Unit is 'becquerel', false otherwise.
 */
bool
Unit::isBecquerel () const
{
  return (mKind == UNIT_KIND_BECQUEREL);
}


/*
 * @return true if the kind of this Unit is 'candela', false otherwise.
 */
bool
Unit::isCandela () const
{
  return (mKind == UNIT_KIND_CANDELA);
}


/*
 * @return true if the kind of this Unit is 'Celsius', false otherwise.
 */
bool
Unit::isCelsius () const
{
  return (mKind == UNIT_KIND_CELSIUS);
}


/*
 * @return true if the kind of this Unit is 'coulomb', false otherwise.
 */
bool
Unit::isCoulomb () const
{
  return (mKind == UNIT_KIND_COULOMB);
}


/*
 * @return true if the kind of this Unit is 'dimensionless', false
 * otherwise.
 */
bool
Unit::isDimensionless () const
{
  return (mKind == UNIT_KIND_DIMENSIONLESS);
}


/*
 * @return true if the kind of this Unit is 'farad', false otherwise.
 */
bool
Unit::isFarad () const
{
  return (mKind == UNIT_KIND_FARAD);
}


/*
 * @return true if the kind of this Unit is 'gram', false otherwise.
 */
bool
Unit::isGram () const
{
  return (mKind == UNIT_KIND_GRAM);
}


/*
 * @return true if the kind of this Unit is 'gray', false otherwise.
 */
bool
Unit::isGray () const
{
  return (mKind == UNIT_KIND_GRAY);
}


/*
 * @return true if the kind of this Unit is 'henry', false otherwise.
 */
bool
Unit::isHenry () const
{
  return (mKind == UNIT_KIND_HENRY);
}


/*
 * @return true if the kind of this Unit is 'hertz', false otherwise.
 */
bool
Unit::isHertz () const
{
  return (mKind == UNIT_KIND_HERTZ);
}


/*
 * @return true if the kind of this Unit is 'item', false otherwise.
 */
bool
Unit::isItem () const
{
  return (mKind == UNIT_KIND_ITEM);
}


/*
 * @return true if the kind of this Unit is 'joule', false otherwise.
 */
bool
Unit::isJoule () const
{
  return (mKind == UNIT_KIND_JOULE);
}


/*
 * @return true if the kind of this Unit is 'katal', false otherwise.
 */
bool
Unit::isKatal () const
{
  return (mKind == UNIT_KIND_KATAL);
}


/*
 * @return true if the kind of this Unit is 'kelvin', false otherwise.
 */
bool
Unit::isKelvin () const
{
  return (mKind == UNIT_KIND_KELVIN);
}


/*
 * @return true if the kind of this Unit is 'kilogram', false otherwise.
 */
bool
Unit::isKilogram () const
{
  return (mKind == UNIT_KIND_KILOGRAM);
}


/*
 * @return true if the kind of this Unit is 'litre' or 'liter', false
 * otherwise.
 */
bool
Unit::isLitre () const
{
  if (getLevel() == 1)
  {
    return (mKind == UNIT_KIND_LITRE || mKind == UNIT_KIND_LITER);
  }
  else
  {
    return (mKind == UNIT_KIND_LITRE);
  }
}


/*
 * @return true if the kind of this Unit is 'lumen', false otherwise.
 */
bool
Unit::isLumen () const
{
  return (mKind == UNIT_KIND_LUMEN);
}


/*
 * @return true if the kind of this Unit is 'lux', false otherwise.
 */
bool
Unit::isLux () const
{
  return (mKind == UNIT_KIND_LUX);
}


/*
 * @return true if the kind of this Unit is 'metre' or 'meter', false
 * otherwise.
 */
bool
Unit::isMetre () const
{
  if (getLevel() == 1)
  {
    return (mKind == UNIT_KIND_METRE || mKind == UNIT_KIND_METER);
  }
  else
  {
    return (mKind == UNIT_KIND_METRE);
  }
}


/*
 * @return true if the kind of this Unit is 'mole', false otherwise.
 */
bool
Unit::isMole () const
{
  return (mKind == UNIT_KIND_MOLE);
}


/*
 * @return true if the kind of this Unit is 'newton', false otherwise.
 */
bool
Unit::isNewton () const
{
  return (mKind == UNIT_KIND_NEWTON);
}


/*
 * @return true if the kind of this Unit is 'ohm', false otherwise.
 */
bool
Unit::isOhm () const
{
  return (mKind == UNIT_KIND_OHM);
}


/*
 * @return true if the kind of this Unit is 'pascal', false otherwise.
 */
bool
Unit::isPascal () const
{
  return (mKind == UNIT_KIND_PASCAL);
}


/*
 * @return true if the kind of this Unit is 'radian', false otherwise.
 */
bool
Unit::isRadian () const
{
  return (mKind == UNIT_KIND_RADIAN);
}


/*
 * @return true if the kind of this Unit is 'second', false otherwise.
 */
bool
Unit::isSecond () const
{
  return (mKind == UNIT_KIND_SECOND);
}


/*
 * @return true if the kind of this Unit is 'siemens', false otherwise.
 */
bool
Unit::isSiemens () const
{
  return (mKind == UNIT_KIND_SIEMENS);
}


/*
 * @return true if the kind of this Unit is 'sievert', false otherwise.
 */
bool
Unit::isSievert () const
{
  return (mKind == UNIT_KIND_SIEVERT);
}


/*
 * @return true if the kind of this Unit is 'steradian', false otherwise.
 */
bool
Unit::isSteradian () const
{
  return (mKind == UNIT_KIND_STERADIAN);
}


/*
 * @return true if the kind of this Unit is 'tesla', false otherwise.
 */
bool
Unit::isTesla () const
{
  return (mKind == UNIT_KIND_TESLA);
}


/*
 * @return true if the kind of this Unit is 'volt', false otherwise.
 */
bool
Unit::isVolt () const
{
  return (mKind == UNIT_KIND_VOLT);
}


/*
 * @return true if the kind of this Unit is 'watt', false otherwise.
 */
bool
Unit::isWatt () const
{
  return (mKind == UNIT_KIND_WATT);
}


/*
 * @return true if the kind of this Unit is 'weber', false otherwise.
 */
bool
Unit::isWeber () const
{
  return (mKind == UNIT_KIND_WEBER);
}


/*
 * @return true if the kind of this Unit is set, false otherwise.
 */
bool
Unit::isSetKind () const
{
  return (mKind != UNIT_KIND_INVALID);
}


/*
 * @return @c true if the "exponent" attribute of this Unit is set, 
 * @c false otherwise.
 */
bool 
Unit::isSetExponent () const
{
  return mIsSetExponent;
}

/*
 * @return @c true if the "scale" attribute of this Unit is set, 
 * @c false otherwise.
 */
bool 
Unit::isSetScale () const
{
  return mIsSetScale;
}


/*
 * @return @c true if the "multiplier" attribute of this Unit is set, 
 * @c false otherwise.
 */
bool 
Unit::isSetMultiplier () const
{
  return mIsSetMultiplier;
}

  
/*
 * Sets the kind of this Unit to the given UnitKind.
 */
int
Unit::setKind (UnitKind_t kind)
{
  if (!UnitKind_isValidUnitKindString(UnitKind_toString(kind),
                 getLevel(), getVersion()))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mKind = kind;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the exponent of this Unit to the given value.
 */
int
Unit::setExponent (int value)
{
  return setExponent((double) value);
}


/*
 * Sets the exponent of this Unit to the given value.
 */
int
Unit::setExponent (double value)
{
  bool representsInteger = true;
  if (floor(value) != value)
    representsInteger = false;

  if (getLevel() < 3)
  {
    if (!representsInteger)
    {
      return LIBSBML_INVALID_ATTRIBUTE_VALUE;
    }
    else
    {
      mExponentDouble = value;
      mExponent = (int) (value);
      mIsSetExponent = true;
      mExplicitlySetExponent = true;
      return LIBSBML_OPERATION_SUCCESS;
    }
  }

  mExponentDouble = value;
  mExponent = (int) (value);
  mIsSetExponent = true;
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the scale of this Unit to the given value.
 */
int
Unit::setScale (int value)
{
  mScale = value;
  mIsSetScale = true;
  mExplicitlySetScale = true;
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Sets the multiplier of this Unit to the given value.
 */
int
Unit::setMultiplier (double value)
{
  if (getLevel() < 2)
  {
    mMultiplier = value;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mMultiplier = value;
    mIsSetMultiplier = true;
    mExplicitlySetMultiplier = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the offset of this Unit to the given value.
 */
int
Unit::setOffset (double value)
{
  if (!(getLevel() == 2 && getVersion() == 1))
  {
    mOffset = 0;
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else
  {
    mOffset = value;
    mExplicitlySetOffset = true;
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
Unit::getTypeCode () const
{
  return SBML_UNIT;
}


/*
 * @return the name of this element ie "unit".
 */
const string&
Unit::getElementName () const
{
  static const string name = "unit";
  return name;
}


bool 
Unit::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for unit: 
  kind (exp, multiplier scale from L3)*/

  if (!isSetKind())
    allPresent = false;

  if (getLevel() > 2 && !isSetExponent())
    allPresent = false;

  if (getLevel() > 2 && !isSetMultiplier())
    allPresent = false;

  if (getLevel() > 2 && !isSetScale())
    allPresent = false;

  return allPresent;
}


/*
 * @return true if name is one of the five SBML built-in Unit names
 * ('substance', 'volume', 'area', 'length' or 'time'), false otherwise.
 */
bool
Unit::isBuiltIn (const std::string& name, unsigned int level)
{
  if (level == 1)
  {
    return
      name == "substance" ||
      name == "volume"    ||
      name == "time";
  }
  else if (level == 2)
  {
    return
      name == "substance" ||
      name == "volume"    ||
      name == "area"      ||
      name == "length"    ||
      name == "time";
  }
  else
    return false;
}

bool
Unit::isUnitKind(const std::string &name, unsigned int level, 
                                         unsigned int version)
{
  if (level == 1)
  {
    return isL1UnitKind(name);
  }
  else if ( level == 2)
  {
    if (version == 1)
    {
      return isL2V1UnitKind(name);
    }
    else
    {
      return isL2UnitKind(name);
    }
  }
  else
  {
    return isL3UnitKind(name);
  }
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return true if name is a valid UnitKind.
 */
bool
Unit::isL1UnitKind (const std::string& name)
{
  return (UnitKind_forName( name.c_str() ) != UNIT_KIND_INVALID);
}

/* slightly less restrictive version that util_isEqual
 * I had issues with this when one of the multipliers
 * had not been calculated and was just 1.0
 */
bool
isEqual(double a, double b)
{
  double tol;
  if (a < b)
    tol = a * 1e-10;
  else
    tol = b * 1e-10;
  return (fabs(a-b) < sqrt(tol)) ? true : false;
}

bool 
Unit::areIdentical(Unit * unit1, Unit * unit2)
{
  bool identical = false;

  if (!strcmp(UnitKind_toString(unit1->getKind()), 
              UnitKind_toString(unit2->getKind())))
  {
    if ((isEqual(unit1->getMultiplier(), unit2->getMultiplier()))
      && (unit1->getScale()     == unit2->getScale())
      && (unit1->getOffset()    == unit2->getOffset())
      && (unit1->getExponent()  == unit2->getExponent()))
    {
      identical = true;
    }
  }

  return identical;
}
/** 
 * Predicate returning @c true if 
 * Unit objects are equivalent (matching kind and exponent).
 *
 * @param unit1 the first Unit object to compare
 * @param unit2 the second Unit object to compare
 *
 * @return @c true if the kind and exponent attributes of unit1 are identical
 * to the kind and exponent attributes of unit2, @c false otherwise.
 *
 * @note For the purposes of comparison two units can be "identical",
 * i.e. all attributes are an exact match, or "equivalent" i.e. 
 * matching kind and exponent.
 *
 * @see areIdentical();
 */
bool 
Unit::areEquivalent(Unit * unit1, Unit * unit2)
{
  bool equivalent = false;

  if (!strcmp(UnitKind_toString(unit1->getKind()), 
              UnitKind_toString(unit2->getKind())))
  {
    // if the kind is dimensionless it doesnt matter 
    // what the exponent is
    if (unit1->getKind() != UNIT_KIND_DIMENSIONLESS)
    {
      if (unit1->isUnitChecking() || unit2->isUnitChecking())
      {
        if ( (unit1->getOffset()    == unit2->getOffset())
          && (unit1->getExponentUnitChecking()  == unit2->getExponentUnitChecking()))
        {
          equivalent = true;
        }      
      }
      else if ( (unit1->getOffset()    == unit2->getOffset())
        && (unit1->getExponent()  == unit2->getExponent()))
      {
        equivalent = true;
      }
    }
    else
    {
      equivalent = true;
    }
  }

  return equivalent;
}

/** 
 * Manipulates the attributes of the Unit to express the unit with the 
 * value of the scale attribute reduced to zero.
 *
 * For example, 1 mm can be expressed as a Unit with kind="metre"
 * multipier="1" scale="-3" exponent="1". It can also be expressed as
 * a Unit with kind="metre" multiplier="0.001" scale="0" exponent="1".
 *
 * @param unit the Unit object to manipulate.
 */
int 
Unit::removeScale(Unit * unit)
{
  if (unit == NULL) return LIBSBML_INVALID_OBJECT;
  double scaleFactor = pow(10.0, unit->getScale());
  double newMultiplier = unit->getMultiplier() * scaleFactor;
  /* hack to force multiplier to be double precision */
  std::ostringstream ossMultiplier;
  ossMultiplier.precision(15);
  ossMultiplier << newMultiplier;
  newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);
  unit->setMultiplier(newMultiplier);
  unit->setScale(0);
  return LIBSBML_OPERATION_SUCCESS;
}

/** 
 * Merges two Unit objects with the same kind attribute into
 * a single Unit.
 * 
 * For example 
 * <unit kind="metre" exponent="2"/>
 * <unit kind="metre" exponent="1"/>
 * merge to become
 * <unit kind="metre" exponent="3"/>
 *
 * @param unit1 the first Unit object 
 * @param unit2 the second Unit object to merge with the first
 */
void
Unit::merge(Unit * unit1, Unit * unit2)
{
  double newExponent;
  double newMultiplier;

  /* only applies if units have same kind */
  if (strcmp(UnitKind_toString(unit1->getKind()), 
             UnitKind_toString(unit2->getKind())))
    return;

  /* not yet implemented if offsets != 0 */
  if (unit1->getOffset() != 0 || unit2->getOffset() != 0)
    return;

  Unit::removeScale(unit1);
  Unit::removeScale(unit2);

  newExponent = unit1->getExponentAsDouble() + unit2->getExponentAsDouble();

  if (newExponent == 0)
  {
    // actually we do not want the new multiplier to be 1
    // there may be a scaling factor in the now dimensionless unit that
    // needs to propogate thru a units calculation
    // newMultiplier = 1;
    newMultiplier = pow(unit1->getMultiplier(), unit1->getExponentAsDouble())*
      pow(unit2->getMultiplier(), unit2->getExponentAsDouble());
  }
  else
  {
    newMultiplier = pow(pow(unit1->getMultiplier(), unit1->getExponentAsDouble())*
      pow(unit2->getMultiplier(), unit2->getExponentAsDouble()), 
                                                  1/(double)(newExponent));
  }
    
  /* hack to force multiplier to be double precision */
  std::ostringstream ossMultiplier;
  ossMultiplier.precision(15);
  ossMultiplier << newMultiplier;
  newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

  unit1->setScale(0);
  unit1->setExponent(newExponent);
  unit1->setMultiplier(newMultiplier);
}

/**
 * Returns a UnitDefinition object which contains the argument unit
 * converted to the appropriate SI unit.
 *
 * @param unit the Unit object to convert to SI
 *
 * @return a UnitDefinition object containing the SI unit.
 */
UnitDefinition * 
Unit::convertToSI(const Unit * unit)
{
  double newMultiplier;
  std::ostringstream ossMultiplier;
  UnitKind_t uKind = unit->getKind();
  Unit * newUnit = new Unit(unit->getSBMLNamespaces());
  newUnit->setKind(uKind);
  if (unit->isUnitChecking())
  {
    newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
  }
  else
  {
    newUnit->setExponent(unit->getExponent());
  }
  newUnit->setScale(unit->getScale());
  newUnit->setMultiplier(unit->getMultiplier());
  UnitDefinition * ud = new UnitDefinition(unit->getSBMLNamespaces());

  Unit::removeScale(newUnit);
  ossMultiplier.precision(15);

  switch (uKind)
  {
    case UNIT_KIND_AMPERE:
      /* Ampere is the SI unit of current */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_AVOGADRO:
      /* 1 Avogadro = 6.02214179e23 dimensionless */
      newUnit->setKind(UNIT_KIND_DIMENSIONLESS);
      newMultiplier = newUnit->getMultiplier()*6.02214179e23;

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_BECQUEREL:
    case UNIT_KIND_HERTZ:
      /* 1 becquerel = 1 sec^-1 = (0.1 sec)^-1 */
      /* 1 hertz = 1 sec^-1 = (0.1 sec) ^-1*/
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setExponentUnitChecking(newUnit->getExponentUnitChecking()*-1);
      /* hack to force multiplier to be double precision */
      newMultiplier = pow(newUnit->getMultiplier(), -1.0);

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_CANDELA:
      /* candela is the SI unit of luminous intensity */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_CELSIUS:
      /* 1 celsius = 1 Kelvin + 273.15*/
      newUnit->setKind(UNIT_KIND_KELVIN);
      newUnit->setOffset(273.15);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_COULOMB:
      /* 1 coulomb = 1 Ampere second */
      newUnit->setKind(UNIT_KIND_AMPERE);
      ud->addUnit(newUnit);
 //     newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      newUnit->setMultiplier(1);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_DIMENSIONLESS:
    case UNIT_KIND_RADIAN:
    case UNIT_KIND_STERADIAN:
      /* all dimensionless */
      newUnit->setKind(UNIT_KIND_DIMENSIONLESS);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_FARAD:
      /* 1 Farad = 1 m^-2 kg^-1 s^4 A^2 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = sqrt(newUnit->getMultiplier());

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(2*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-1*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(4*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_GRAM:
      /* 1 gram = 0.001 Kg */
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(0.001 * newUnit->getMultiplier());
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_GRAY:
    case UNIT_KIND_SIEVERT:
      /* 1 Gray = 1 m^2 sec^-2 */
      /* 1 Sievert = 1 m^2 sec^-2 */
      newUnit->setKind(UNIT_KIND_METRE);
      /* hack to force multiplier to be double precision */
      newMultiplier = sqrt(newUnit->getMultiplier());

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(2*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
 //     newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_HENRY:
      /* 1 Henry = 1 m^2 kg s^-2 A^-2 */
      newUnit->setKind(UNIT_KIND_AMPERE);
       /* hack to force multiplier to be double precision */
      newMultiplier = (1.0/sqrt(newUnit->getMultiplier()));

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(-2*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
 //     newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_ITEM:
      newUnit->setKind(UNIT_KIND_ITEM);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_JOULE:
      /* 1 joule = 1 m^2 kg s^-2 */
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_KATAL:
      /* 1 katal = 1 mol s^-1 */
      newUnit->setKind(UNIT_KIND_MOLE);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-1*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
     break;

    case UNIT_KIND_KELVIN:
      /* Kelvin is the SI unit of temperature */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_KILOGRAM:
      /* Kilogram is the SI unit of mass */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_LITER:
    case UNIT_KIND_LITRE:
      /* 1 litre = 0.001 m^3 = (0.1 m)^3*/ 
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setExponentUnitChecking(newUnit->getExponentUnitChecking()*3);
      /* hack to force multiplier to be double precision */
      newMultiplier = pow((newUnit->getMultiplier() * 0.001), 1.0/3.0);

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_LUMEN:
      /* 1 lumen = 1 candela*/ 
      newUnit->setKind(UNIT_KIND_CANDELA);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_LUX:
      /* 1 lux = 1 candela m^-2*/ 
      newUnit->setKind(UNIT_KIND_CANDELA);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_METER:
    case UNIT_KIND_METRE:
      /* metre is the SI unit of length */
      newUnit->setKind(UNIT_KIND_METRE);
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_MOLE:
      /* mole is the SI unit of substance */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_NEWTON:
      /* 1 newton = 1 m kg s^-2 */
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_OHM:
      /* 1 ohm = 1 m^2 kg s^-3 A^-2 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = (1.0/sqrt(newUnit->getMultiplier()));

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(-2*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-3*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_PASCAL:
      /* 1 pascal = 1 m^-1 kg s^-2 */
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-1*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_SECOND:
      /* second is the SI unit of time */
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_SIEMENS:
      /* 1 siemen = 1 m^-2 kg^-1 s^3 A^2 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = sqrt(newUnit->getMultiplier());

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(2*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-1*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(3*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_TESLA:
      /* 1 tesla = 1 kg s^-2 A^-1 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = (1.0/(newUnit->getMultiplier()));

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(-1*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_VOLT:
      /* 1 volt = 1 m^2 kg s^-3 A^-1 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = (1.0/(newUnit->getMultiplier()));

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(-1*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-3*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_WATT:
      /* 1 watt = 1 m^2 kg s^-3 */
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-3*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_WEBER:
      /* 1 weber = 1 m^2 kg s^-2 A^-1 */
      newUnit->setKind(UNIT_KIND_AMPERE);
      /* hack to force multiplier to be double precision */
      newMultiplier = (1.0/(newUnit->getMultiplier()));

      ossMultiplier << newMultiplier;
      newMultiplier = strtod(ossMultiplier.str().c_str(), NULL);

      newUnit->setMultiplier(newMultiplier); 
      newUnit->setExponentUnitChecking(-1*newUnit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_KILOGRAM);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(unit->getExponentUnitChecking());
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_METRE);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
//      newUnit = new Unit(uKind, unit->getExponent(), unit->getScale(), unit->getMultiplier());
      newUnit->setKind(UNIT_KIND_SECOND);
      newUnit->setMultiplier(1.0);
      newUnit->setExponentUnitChecking(-2*unit->getExponentUnitChecking());  
      ud->addUnit(newUnit);
      break;

    case UNIT_KIND_INVALID:
      break;
  }

  delete newUnit;

  return ud;
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return true if name is a valid UnitKind.
 */
bool
Unit::isL2V1UnitKind (const std::string& name)
{
  if (name == "meter" 
   || name == "liter"
   || name == "avogadro")
    return false;
  else
    return (UnitKind_forName( name.c_str() ) != UNIT_KIND_INVALID);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return true if name is a valid UnitKind.
 */
bool
Unit::isL2UnitKind (const std::string& name)
{
  if (name == "meter" 
   || name == "liter" 
   || name == "Celsius"
   || name == "avogadro")

    return false;
  else
    return (UnitKind_forName( name.c_str() ) != UNIT_KIND_INVALID);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return true if name is a valid UnitKind.
 */
bool
Unit::isL3UnitKind (const std::string& name)
{
  if (name == "meter" || name == "liter" || name == "Celsius")
    return false;
  else
    return (UnitKind_forName( name.c_str() ) != UNIT_KIND_INVALID);
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
Unit::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  attributes.add("kind");
  attributes.add("exponent");
  attributes.add("scale");

  if (level > 1)
  {
    attributes.add("multiplier");

    if (level == 2 && version == 1)
    {
      attributes.add("offset");
    }

    if (level == 2 && version == 2)
    {
      attributes.add("sboTerm");
    }
  }
}


/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Unit::readAttributes (const XMLAttributes& attributes,
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
Unit::readL1Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();


  //
  // kind: UnitKind  (L1v1, L1v2, L2v1->)
  //
  string kind;

  if ( attributes.readInto("kind", kind, getErrorLog(), true, getLine(), getColumn()) )
  {
    mKind = UnitKind_forName( kind.c_str() );
    if (mKind == UNIT_KIND_CELSIUS)
    {
      if (!(level == 1) && !(level == 2 && version == 1))
      {
        SBMLError * err = new SBMLError(CelsiusNoLongerValid);
        logError(NotSchemaConformant, level, version, err->getMessage());
        delete err;
      }
    }
  }

  //
  // exponent  { use="optional" default="1" }  (L1v1, L1v2, L2v1->)
  // exponent  { use="required" }  (L3v1 ->)
  //
  if (attributes.readInto("exponent", mExponent, getErrorLog(), false, getLine(), getColumn()))
  {
    mExponentDouble = (double)(mExponent);
    mIsSetExponent = true;
    mExplicitlySetExponent = true;

  }


  //
  // scale  { use="optional" default="0" }  (L1v1, L1v2, L2v1->)
  // scale  { use="required" }  (L3v1->)
  //
  mExplicitlySetScale = attributes.readInto("scale", mScale, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Unit::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  //
  // kind: UnitKind  (L1v1, L1v2, L2v1->)
  //
  string kind;
  if ( attributes.readInto("kind", kind, getErrorLog(), true, getLine(), getColumn()) )
  {
    mKind = UnitKind_forName( kind.c_str() );
    if (mKind == UNIT_KIND_CELSIUS)
    {
      if (!(level == 1) && !(level == 2 && version == 1))
      {
        SBMLError * err = new SBMLError(CelsiusNoLongerValid);
        logError(NotSchemaConformant, level, version, err->getMessage());
        delete err;
      }
    }
  }

  //
  // exponent  { use="optional" default="1" }  (L1v1, L1v2, L2v1->)
  // exponent  { use="required" }  (L3v1 ->)
  //
  if (attributes.readInto("exponent", mExponent, getErrorLog(), false, getLine(), getColumn()))
  {
    mExponentDouble = (double)(mExponent);
    mIsSetExponent = true;
    mExplicitlySetExponent = true;
  }

  //
  // scale  { use="optional" default="0" }  (L1v1, L1v2, L2v1->)
  // scale  { use="required" }  (L3v1->)
  //
  mExplicitlySetScale = attributes.readInto("scale", mScale, getErrorLog(), false, getLine(), getColumn());

  //
  // multiplier  { use="optional" default="1" }  (L2v1-> )
  // multiplier  { use="required" }  (L3v1-> )
  //
  mExplicitlySetMultiplier = attributes.readInto("multiplier", mMultiplier, getErrorLog(), false, getLine(), getColumn());

  //
  // offset  { use="optional" default="0" }  (L2v1)
  //
  if (version == 1)
    mExplicitlySetOffset = attributes.readInto("offset", mOffset, getErrorLog(), false, getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
Unit::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  //
  // kind: UnitKind  (L1v1, L1v2, L2v1->)
  //
  string kind;
  bool assigned;
  assigned = attributes.readInto("kind", kind, getErrorLog(), false, getLine(), getColumn());
  if ( assigned)
  {
    mKind = UnitKind_forName( kind.c_str() );
    if (mKind == UNIT_KIND_CELSIUS)
    {
      if (!(level == 1) && !(level == 2 && version == 1))
      {
        SBMLError * err = new SBMLError(CelsiusNoLongerValid);
        logError(NotSchemaConformant, level, version, err->getMessage());
        delete err;
      }
    }
  }
  else
  {
    logError(AllowedAttributesOnUnit, level, version, 
             "The required attribute 'kind' is missing.");
  }

  //
  // exponent  { use="required" }  (L3v1 ->)
  //
  mIsSetExponent = attributes.readInto("exponent", mExponentDouble, 
                                        getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetExponent)
  {
    logError(AllowedAttributesOnUnit, level, version, 
      "The required attribute 'exponent' is missing.");
  }
  else
  {
    mExponent = (int)(mExponentDouble);
  }

  //
  // scale  { use="required" }  (L3v1->)
  //
  mIsSetScale = attributes.readInto("scale", mScale, getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetScale)
  {
    logError(AllowedAttributesOnUnit, level, version, 
      "The required attribute 'scale' is missing.");
  }

  //
  // multiplier  { use="required" }  (L3v1-> )
  //
  mIsSetMultiplier = attributes.readInto("multiplier", mMultiplier, 
                                          getErrorLog(), false, getLine(), getColumn());
  if (!mIsSetMultiplier)
  {
    logError(AllowedAttributesOnUnit, level, version, 
      "The required attribute 'multiplier' is missing.");
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
Unit::writeElements (XMLOutputStream& stream) const
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
Unit::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level = getLevel();
  const unsigned int version = getVersion();

  //
  // kind: UnitKind  { use="required" }  (L1v1, L1v2, L2v1->)
  //
  const string kind = UnitKind_toString(mKind);
  if (level < 3)
  {
    stream.writeAttribute("kind", kind);
  }
  else
  {
    // in L3 only write it out if it has been set
    if (isSetKind())
      stream.writeAttribute("kind", kind);
  }

  //
  // exponent  { use="optional" default="1" }  (L1v1, L1v2, L2v1->)
  // exponent  { use="required" }  (L3v1 ->)
  //
  if (level < 3)
  {
    int e = static_cast<int>( mExponent );
    if (e != 1 || isExplicitlySetExponent()) 
      stream.writeAttribute("exponent", e);
  }
  else
  {
    // in L3 only write it out if it has been set
    if (isSetExponent())
      stream.writeAttribute("exponent", mExponentDouble);
  }
 
  //
  // scale  { use="optional" default="0" }  (L1v1, L1v2, L2v1->)
  // scale  { use="required" }  (L3v1->)
  //
  if (level < 3)
  {
    if (mScale != 0 || isExplicitlySetScale() ) 
      stream.writeAttribute("scale", mScale);
  }
  else
  {
    // in L3 only write it out if it has been set
    if (isSetScale())
      stream.writeAttribute("scale", mScale);
  }

  if (level > 1)
  {
    //
    // multiplier  { use="optional" default="1" }  (L2v1->)
    // multiplier  { use="required" }  (L3v1-> )
    //
    if (level < 3)
    {
      if (mMultiplier != 1 || isExplicitlySetMultiplier()) 
        stream.writeAttribute("multiplier", mMultiplier);
    }
    else
    {
      // in L3 only write it out if it has been set
      if (isSetMultiplier())
        stream.writeAttribute("multiplier", mMultiplier);
    }
    //
    // offset  { use="optional" default="0" }  (L2v1)
    //
    if (level == 2 && version == 1 && 
      (mOffset != 0 || isExplicitlySetOffset()) )
    {
      stream.writeAttribute("offset", mOffset);
    }

    //
    // sboTerm: SBOTerm { use="optional" }  (L2v3->)
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
/* private unit checking functions */
void 
Unit::setExponentUnitChecking (double value) 
{ 
  /* cannot use setExponent becuase want a double exponent 
   * - even if we are dealing with L2/L1
   */
  //setExponent(value);
  mExponentDouble = value;
  mExponent = (int)(value);
  mIsSetExponent = true;
  mInternalUnitCheckingFlag = true;
}


double 
Unit::getExponentUnitChecking() 
{ 
  return mExponentDouble; 
}


double 
Unit::getExponentUnitChecking() const
{ 
  return mExponentDouble; 
}


bool
Unit::isUnitChecking()
{
  return mInternalUnitCheckingFlag;
}

bool
Unit::isUnitChecking() const
{
  return mInternalUnitCheckingFlag;
}

/** @endcond */


/*
 * Creates a new ListOfUnits items.
 */
ListOfUnits::ListOfUnits (unsigned int level, unsigned int version)
  : ListOf(level,version)
{
}


/*
 * Creates a new ListOfUnits items.
 */
ListOfUnits::ListOfUnits (SBMLNamespaces* sbmlns)
  : ListOf(sbmlns)
{
  loadPlugins(sbmlns);
}


/*
 * @return a (deep) copy of this ListOfUnits.
 */
ListOfUnits*
ListOfUnits::clone () const
{
  return new ListOfUnits(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfUnits::getItemTypeCode () const
{
  return SBML_UNIT;
}


/*
 * @return the name of this element ie "listOfUnits".
 */
const string&
ListOfUnits::getElementName () const
{
  static const string name = "listOfUnits";
  return name;
}


/* return nth item in list */
Unit *
ListOfUnits::get(unsigned int n)
{
  return static_cast<Unit*>(ListOf::get(n));
}


/* return nth item in list */
const Unit *
ListOfUnits::get(unsigned int n) const
{
  return static_cast<const Unit*>(ListOf::get(n));
}


/* Removes the nth item from this list */
Unit*
ListOfUnits::remove (unsigned int n)
{
   return static_cast<Unit*>(ListOf::remove(n));
}


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its
 * siblings or -1 (default) to indicate the position is not significant.
 */
int
ListOfUnits::getElementPosition () const
{
  return 1;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
ListOfUnits::createObject (XMLInputStream& stream)
{
  const string& name   = stream.peek().getName();
  SBase*        object = NULL;


  if (name == "unit")
  {
    try
    {
      object = new Unit(getSBMLNamespaces());
    }
    catch (SBMLConstructorException*)
    {
      object = new Unit(SBMLDocument::getDefaultLevel(),
        SBMLDocument::getDefaultVersion());
    }
    catch ( ... )
    {
      object = new Unit(SBMLDocument::getDefaultLevel(),
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
Unit_t *
Unit_create (unsigned int level, unsigned int version)
{
  try
  {
    Unit* obj = new Unit(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
Unit_t *
Unit_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    Unit* obj = new Unit(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}

LIBSBML_EXTERN
void
Unit_free (Unit_t *u)
{
  if (u != NULL)
  delete u;
}


LIBSBML_EXTERN
Unit_t *
Unit_clone (const Unit_t* u)
{
  return (u != NULL) ? static_cast<Unit*>( u->clone() ) : NULL;
}


LIBSBML_EXTERN
void
Unit_initDefaults (Unit_t *u)
{
  if (u != NULL)
    u->initDefaults();
}


LIBSBML_EXTERN
const XMLNamespaces_t *
Unit_getNamespaces(Unit_t *u)
{
  return (u != NULL) ? u->getNamespaces() : NULL;
}


LIBSBML_EXTERN
UnitKind_t
Unit_getKind (const Unit_t *u)
{
  return (u != NULL) ? u->getKind() : UNIT_KIND_INVALID;
}


LIBSBML_EXTERN
int
Unit_getExponent (const Unit_t *u)
{
  return (u != NULL) ? u->getExponent() : SBML_INT_MAX;
}


LIBSBML_EXTERN
double
Unit_getExponentAsDouble (const Unit_t *u)
{
  return (u != NULL) ? u->getExponentAsDouble() 
                     : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
int
Unit_getScale (const Unit_t *u)
{
  return (u != NULL) ? u->getScale() : SBML_INT_MAX;
}


LIBSBML_EXTERN
double
Unit_getMultiplier (const Unit_t *u)
{
  return (u != NULL) ? u->getMultiplier()
                     : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
double
Unit_getOffset (const Unit_t *u)
{
  return (u != NULL) ? u->getOffset() : numeric_limits<double>::quiet_NaN();
}


LIBSBML_EXTERN
int
Unit_isAmpere (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isAmpere() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isBecquerel (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isBecquerel() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isCandela (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isCandela() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isCelsius (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isCelsius() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isCoulomb (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isCoulomb() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isDimensionless (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isDimensionless() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isFarad (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isFarad() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isGram (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isGram() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isGray (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isGray() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isHenry (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isHenry() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isHertz (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isHertz() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isItem (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isItem() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isJoule (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isJoule() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isKatal (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isKatal() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isKelvin (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isKelvin() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isKilogram (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isKilogram() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isLitre (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isLitre() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isLumen (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isLumen() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isLux (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isLux() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isMetre (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isMetre() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isMole (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isMole() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isNewton (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isNewton() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isOhm (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isOhm() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isPascal (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isPascal() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isRadian (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isRadian() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSecond (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSecond() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSiemens (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSiemens() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSievert (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSievert() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSteradian (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSteradian() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isTesla (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isTesla() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isVolt (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isVolt() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isWatt (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isWatt() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isWeber (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isWeber() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSetKind (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSetKind() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSetExponent (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSetExponent() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSetMultiplier (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSetMultiplier() ) : 0;
}


LIBSBML_EXTERN
int
Unit_isSetScale (const Unit_t *u)
{
  return (u != NULL) ? static_cast<int>( u->isSetScale() ) : 0;
}


LIBSBML_EXTERN
int
Unit_setKind (Unit_t *u, UnitKind_t kind)
{
  return (u != NULL) ? u->setKind(kind) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_setExponent (Unit_t *u, int value)
{
  return (u != NULL) ? u->setExponent(value) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_setExponentAsDouble (Unit_t *u, double value)
{
  return (u != NULL) ? u->setExponent(value) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_setScale (Unit_t *u, int value)
{
  return (u != NULL) ? u->setScale(value) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_setMultiplier (Unit_t *u, double value)
{
  return (u != NULL) ? u->setMultiplier(value) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_setOffset (Unit_t *u, double value)
{
  return (u != NULL) ? u->setOffset(value) : LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
Unit_hasRequiredAttributes(Unit_t *u)
{
  return (u != NULL) ? static_cast <int> (u->hasRequiredAttributes()) : 0;
}


LIBSBML_EXTERN
int
Unit_isBuiltIn (const char *name, unsigned int level)
{
  return Unit::isBuiltIn(name != NULL ? name : "", level);
}

LIBSBML_EXTERN
int 
Unit_areIdentical(Unit_t * unit1, Unit_t * unit2)
{
  if (unit1 != NULL && unit2 != NULL)
    return static_cast<int>(Unit::areIdentical(
      static_cast<Unit*>(unit1), static_cast<Unit*>(unit2)));
  else
    return 0;
}

LIBSBML_EXTERN
int
Unit_areEquivalent(Unit_t * unit1, Unit_t * unit2)
{
  if (unit1 != NULL && unit2 != NULL)
    return static_cast<int>(Unit::areEquivalent(
      static_cast<Unit*>(unit1), static_cast<Unit*>(unit2)));
  else
    return 0;
}

LIBSBML_EXTERN
int 
Unit_removeScale(Unit_t * unit)
{
  return (unit != NULL) ? Unit::removeScale(static_cast<Unit*>(unit)) 
                        : LIBSBML_INVALID_OBJECT;
}

LIBSBML_EXTERN
void 
Unit_merge(Unit_t * unit1, Unit_t * unit2)
{
  if (unit1 != NULL && unit2 != NULL)
    Unit::merge(static_cast<Unit*>(unit1), static_cast<Unit*>(unit2));
}

LIBSBML_EXTERN
UnitDefinition_t * 
Unit_convertToSI(Unit_t * unit)
{
  return (unit != NULL) ? static_cast<UnitDefinition_t*>(Unit::convertToSI(
    static_cast<Unit*>(unit))) : NULL;
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
