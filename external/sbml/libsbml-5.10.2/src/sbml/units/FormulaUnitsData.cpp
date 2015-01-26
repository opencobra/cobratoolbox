/** 
 *@cond doxygenLibsbmlInternal 
 **
 *
 * @file    FormulaUnitsData.cpp
 * @brief   Class for storing information relating to units of a formula
 * @author  SBML Team <sbml-team@caltech.edu>
 *
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

#include <sbml/Model.h>
#include <sbml/SBMLDocument.h>
#include <sbml/units/FormulaUnitsData.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN

FormulaUnitsData::FormulaUnitsData()
{
  mUnitReferenceId = "";
  mContainsUndeclaredUnits = false;
  mCanIgnoreUndeclaredUnits = true;
  mTypeOfElement = SBML_UNKNOWN;
  mUnitDefinition = 
    new UnitDefinition(SBMLDocument::getDefaultLevel(), 
                       SBMLDocument::getDefaultVersion());
  mPerTimeUnitDefinition = 
    new UnitDefinition(SBMLDocument::getDefaultLevel(),
                       SBMLDocument::getDefaultVersion());
  mEventTimeUnitDefinition = 
    new UnitDefinition(SBMLDocument::getDefaultLevel(),
                       SBMLDocument::getDefaultVersion());
  mSpeciesExtentUnitDefinition = 
    new UnitDefinition(SBMLDocument::getDefaultLevel(),
                       SBMLDocument::getDefaultVersion());
  mSpeciesSubstanceUnitDefinition = 
    new UnitDefinition(SBMLDocument::getDefaultLevel(),
                       SBMLDocument::getDefaultVersion());
}

FormulaUnitsData::FormulaUnitsData(const FormulaUnitsData& orig)
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mUnitReferenceId = orig.mUnitReferenceId;
    mContainsUndeclaredUnits = 
                            orig.mContainsUndeclaredUnits;
    mCanIgnoreUndeclaredUnits = orig.mCanIgnoreUndeclaredUnits;
    mTypeOfElement = orig.mTypeOfElement;
    if (orig.mUnitDefinition) 
    {
      mUnitDefinition = static_cast <UnitDefinition*> 
                                        (orig.mUnitDefinition->clone());
    }
    else
    {
      mUnitDefinition = NULL;
    }
    if (orig.mPerTimeUnitDefinition)
    {
      mPerTimeUnitDefinition = static_cast <UnitDefinition*> 
                                  (orig.mPerTimeUnitDefinition->clone());
    }
    else
    {
      mPerTimeUnitDefinition = NULL;
    }
    if (orig.mEventTimeUnitDefinition)
    {
      mEventTimeUnitDefinition = static_cast <UnitDefinition*> 
                                (orig.mEventTimeUnitDefinition->clone());
    }
    else
    {
      mEventTimeUnitDefinition = NULL;
    }
    if (orig.mSpeciesExtentUnitDefinition)
    {
      mSpeciesExtentUnitDefinition = static_cast <UnitDefinition*> 
                                (orig.mSpeciesExtentUnitDefinition->clone());
    }
    else
    {
      mSpeciesExtentUnitDefinition = NULL;
    }
    if (orig.mSpeciesSubstanceUnitDefinition)
    {
      mSpeciesSubstanceUnitDefinition = static_cast <UnitDefinition*> 
                                (orig.mSpeciesSubstanceUnitDefinition->clone());
    }
    else
    {
      mSpeciesSubstanceUnitDefinition = NULL;
    }
  }
}

/*
 * Assignment operator
 */
FormulaUnitsData& FormulaUnitsData::operator=(const FormulaUnitsData& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    mUnitReferenceId = rhs.mUnitReferenceId;
    mContainsUndeclaredUnits = 
                            rhs.mContainsUndeclaredUnits;
    mCanIgnoreUndeclaredUnits = rhs.mCanIgnoreUndeclaredUnits;
    mTypeOfElement = rhs.mTypeOfElement;

    delete mUnitDefinition;
    if (rhs.mUnitDefinition) 
    {
      mUnitDefinition = static_cast <UnitDefinition*> 
                                        (rhs.mUnitDefinition->clone());
    }
    else
    {
      mUnitDefinition = NULL;
    }

    delete mPerTimeUnitDefinition;
    if (rhs.mPerTimeUnitDefinition)
    {
      mPerTimeUnitDefinition = static_cast <UnitDefinition*> 
                                  (rhs.mPerTimeUnitDefinition->clone());
    }
    else
    {
      mPerTimeUnitDefinition = NULL;
    }

    delete mEventTimeUnitDefinition;
    if (rhs.mEventTimeUnitDefinition)
    {
      mEventTimeUnitDefinition = static_cast <UnitDefinition*> 
                                (rhs.mEventTimeUnitDefinition->clone());
    }
    else
    {
      mEventTimeUnitDefinition = NULL;
    }

    delete mSpeciesExtentUnitDefinition;
    if (rhs.mSpeciesExtentUnitDefinition)
    {
      mSpeciesExtentUnitDefinition = static_cast <UnitDefinition*> 
                                (rhs.mSpeciesExtentUnitDefinition->clone());
    }
    else
    {
      mSpeciesExtentUnitDefinition = NULL;
    }

    delete mSpeciesSubstanceUnitDefinition;
    if (rhs.mSpeciesSubstanceUnitDefinition)
    {
      mSpeciesSubstanceUnitDefinition = static_cast <UnitDefinition*> 
                                (rhs.mSpeciesSubstanceUnitDefinition->clone());
    }
    else
    {
      mSpeciesSubstanceUnitDefinition = NULL;
    }
  }

  return *this;
}


FormulaUnitsData::~FormulaUnitsData()
{
  if (mUnitDefinition)              delete mUnitDefinition;
  if (mPerTimeUnitDefinition)       delete mPerTimeUnitDefinition;
  if (mEventTimeUnitDefinition)     delete mEventTimeUnitDefinition;
  if (mSpeciesExtentUnitDefinition)     delete mSpeciesExtentUnitDefinition;
  if (mSpeciesSubstanceUnitDefinition)     delete mSpeciesSubstanceUnitDefinition;
}

FormulaUnitsData*
FormulaUnitsData::clone() const
{
  return new FormulaUnitsData(*this);
}


/*
 * Get the unitReferenceId of this FormulaUnitsData.
 * 
 * @return the value of the unitReferenceId of this 
 * FormulaUnitsData as a string.
 */
const string& 
FormulaUnitsData::getUnitReferenceId() 
{ 
  return mUnitReferenceId; 
}

/*
 * Get the unitReferenceId of this FormulaUnitsData.
 * 
 * @return the value of the unitReferenceId of this 
 * FormulaUnitsData as a string.
 */
const string& 
FormulaUnitsData::getUnitReferenceId() const 
{ 
  return mUnitReferenceId; 
}


int
FormulaUnitsData::getComponentTypecode() 
{ 
  return mTypeOfElement; 
}

int
FormulaUnitsData::getComponentTypecode() const 
{ 
  return mTypeOfElement; 
}

/**
  * Predicate returning @c true or @c false depending on whether this
  * FormulaUnitsData includes parameters/numbers with undeclared units.
  * 
  * @return @c true if the FormulaUnitsData includes parameters/numbers 
  * with undeclared units, @c false otherwise.
  */
bool 
FormulaUnitsData::getContainsUndeclaredUnits() 
{ 
  return mContainsUndeclaredUnits; 
}

/**
  * Predicate returning @c true or @c false depending on whether this
  * FormulaUnitsData includes parameters/numbers with undeclared units.
  * 
  * @return @c true if the FormulaUnitsData includes parameters/numbers 
  * with undeclared units, @c false otherwise.
  */
bool 
FormulaUnitsData::getContainsUndeclaredUnits() const
{ 
  return mContainsUndeclaredUnits; 
}

/**
  * @return @c true if the parameters/numbers 
  * with undeclared units can be ignored, @c false otherwise.
  */
bool 
FormulaUnitsData::getCanIgnoreUndeclaredUnits() 
{ 
  return mCanIgnoreUndeclaredUnits; 
}

/**
  * @return @c true if the parameters/numbers 
  * with undeclared units can be ignored, @c false otherwise.
  */
bool 
FormulaUnitsData::getCanIgnoreUndeclaredUnits() const 
{ 
  return mCanIgnoreUndeclaredUnits; 
}

/**
  * Get the unit definition for this FormulaUnitsData.
  * 
  * @return the UnitDefinition object of this FormulaUnitsData.
  *
  * @note the UnitDefinition object is constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object.
  */
UnitDefinition * 
FormulaUnitsData::getUnitDefinition() 
{ 
  return mUnitDefinition; 
}

/**
  * Get the unit definition for this FormulaUnitsData.
  * 
  * @return the UnitDefinition object of this FormulaUnitsData.
  *
  * @note the UnitDefinition object is constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object.
  */
const UnitDefinition * 
FormulaUnitsData::getUnitDefinition() const 
{ 
  return mUnitDefinition; 
}

/**
  * Get the 'perTime' unit definition for this FormulaUnitsData.
  * 
  * @return the 'perTime' UnitDefinition object of this FormulaUnitsData.
  *
  * @note the perTime UnitDefinition object is constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object divided by the time units for the model.
  */
UnitDefinition * 
FormulaUnitsData::getPerTimeUnitDefinition() 
{ 
  return mPerTimeUnitDefinition; 
}

/**
  * Get the 'perTime' unit definition for this FormulaUnitsData.
  * 
  * @return the 'perTime' UnitDefinition object of this FormulaUnitsData.
  *
  * @note the perTime UnitDefinition object is constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object divided by the time units for the model.
  */
const UnitDefinition * 
FormulaUnitsData::getPerTimeUnitDefinition() const 
{ 
  return mPerTimeUnitDefinition; 
}

/**
  * Get the 'EventTime' unit definition for this FormulaUnitsData.
  * 
  * @return the 'EventTime' UnitDefinition object of this FormulaUnitsData.
  *
  * @note the EventTime UnitDefinition object is constructed to represent
  * the time units associated with the Event used to populate 
  * this FormulaUnitsData object.
  */
UnitDefinition * 
FormulaUnitsData::getEventTimeUnitDefinition() 
{ 
  return mEventTimeUnitDefinition; 
}

/**
  * Get the 'EventTime' unit definition for this FormulaUnitsData.
  * 
  * @return the 'EventTime' UnitDefinition object of this FormulaUnitsData.
  *
  * @note the EventTime UnitDefinition object is constructed to represent
  * the time units associated with the Event used to populate 
  * this FormulaUnitsData object.
  */
const UnitDefinition * 
FormulaUnitsData::getEventTimeUnitDefinition() const 
{ 
  return mEventTimeUnitDefinition; 
}

const UnitDefinition * 
FormulaUnitsData::getSpeciesExtentUnitDefinition() const 
{ 
  return mSpeciesExtentUnitDefinition; 
}

UnitDefinition * 
FormulaUnitsData::getSpeciesExtentUnitDefinition()
{ 
  return mSpeciesExtentUnitDefinition; 
}

const UnitDefinition * 
FormulaUnitsData::getSpeciesSubstanceUnitDefinition() const 
{ 
  return mSpeciesSubstanceUnitDefinition; 
}

UnitDefinition * 
FormulaUnitsData::getSpeciesSubstanceUnitDefinition()
{ 
  return mSpeciesSubstanceUnitDefinition; 
}

/**
  * Sets the unitReferenceId attribute of this FormulaUnitsData.
  *
  * @param unitReferenceId the identifier of the object defined
  * elsewhere in this Model for which this FormulaUnitsData contains
  * unit information.
  */
void 
FormulaUnitsData::setUnitReferenceId(const std::string& unitReferenceId) 
{ 
  mUnitReferenceId = unitReferenceId; 
}

/**
  * Sets the SBMLTypecode of this FormulaUnitsData.
  * 
  * @param typecode the typecode (int) of the object defined
  * elsewhere in this Model for which this FormulaUnitsData contains
  * unit information.
  */
void 
FormulaUnitsData::setComponentTypecode(int typecode) 
{ 
  mTypeOfElement = typecode; 
}


/**
  * Sets the value of the "containsUndeclaredUnits" flag for this 
  * FormulaUnitsData.
  * 
  * @parameter flag boolean value indicating whether the FormulaUnitsData 
  * includes parameters/numbers with undeclared units.
  */
void 
FormulaUnitsData::setContainsParametersWithUndeclaredUnits(bool flag)
{ 
  mContainsUndeclaredUnits = flag; 
}

/**
  * Sets the value of the "canIgnoreUndeclaredUnits" flag for this 
  * FormulaUnitsData.
  * 
  * @parameter flag boolean value indicating whether parameters/numbers 
  * with undeclared units can be ignored.
  */
void 
FormulaUnitsData::setCanIgnoreUndeclaredUnits(bool flag)
{ 
  mCanIgnoreUndeclaredUnits = flag; 
}

/**
  * Set the unit definition for this FormulaUnitsData.
  * 
  * @parameter ud the UnitDefinition object constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object.
  */
void 
FormulaUnitsData::setUnitDefinition(UnitDefinition * ud) 
{ 
  if(ud == mUnitDefinition) return;
  
  delete mUnitDefinition; 
  mUnitDefinition = ud; 
}

/**
  * Set the 'perTime' unit definition for this FormulaUnitsData.
  * 
  * @parameter ud the UnitDefinition object constructed to represent
  * the units associated with the component used to populate 
  * this FormulaUnitsData object divided by the time units for the model.
  */
void 
FormulaUnitsData::setPerTimeUnitDefinition(UnitDefinition * ud) 
{ 
  if(ud == mPerTimeUnitDefinition) return;
  
  delete mPerTimeUnitDefinition;
  mPerTimeUnitDefinition = ud; 
}

/**
  * Set the 'EventTime' unit definition for this FormulaUnitsData.
  * 
  * @parameter ud the UnitDefinition object constructed to represent
  * the time units associated with the Event used to populate 
  * this FormulaUnitsData object.
  */
void 
FormulaUnitsData::setEventTimeUnitDefinition(UnitDefinition * ud) 
{ 
  if(ud == mEventTimeUnitDefinition) return;
  
  delete mEventTimeUnitDefinition;
  mEventTimeUnitDefinition = ud; 
}

void 
FormulaUnitsData::setSpeciesExtentUnitDefinition(UnitDefinition * ud) 
{ 
  if(ud == mSpeciesExtentUnitDefinition) return;
  
  delete mSpeciesExtentUnitDefinition;
  mSpeciesExtentUnitDefinition = ud; 
}

void 
FormulaUnitsData::setSpeciesSubstanceUnitDefinition(UnitDefinition * ud) 
{ 
  if(ud == mSpeciesSubstanceUnitDefinition) return;
  
  delete mSpeciesSubstanceUnitDefinition;
  mSpeciesSubstanceUnitDefinition = ud; 
}


/* NOT YET NECESSARY

LIBSBML_EXTERN
FormulaUnitsData_t* 
FormulaUnitsData_create()
{
  return new(nothrow) FormulaUnitsData;
}


LIBSBML_EXTERN
const char* 
FormulaUnitsData_getUnitReferenceId(FormulaUnitsData_t* fud)
{
  return fud->getUnitReferenceId().c_str();
}

LIBSBML_EXTERN
SBMLTypeCode_t 
FormulaUnitsData_getComponentTypecode(FormulaUnitsData_t* fud)
{
  return fud->getComponentTypecode();
}

LIBSBML_EXTERN
int 
FormulaUnitsData_getContainsUndeclaredUnits(FormulaUnitsData_t* fud)
{
  return static_cast <int> (fud->getContainsUndeclaredUnits());
}

LIBSBML_EXTERN
int 
FormulaUnitsData_getCanIgnoreUndeclaredUnits(FormulaUnitsData_t* fud)
{
  return static_cast <int> (fud->getCanIgnoreUndeclaredUnits());
}

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getUnitDefinition(FormulaUnitsData_t* fud)
{
  return fud->getUnitDefinition();
}

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getPerTimeUnitDefinition(FormulaUnitsData_t* fud)
{
  return fud->getPerTimeUnitDefinition();
}

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getEventTimeUnitDefinition(FormulaUnitsData_t* fud)
{
  return fud->getEventTimeUnitDefinition();
}


LIBSBML_EXTERN
void 
FormulaUnitsData_setUnitReferenceId(FormulaUnitsData_t* fud, const char* id)
{
  fud->setUnitReferenceId(id);
}

LIBSBML_EXTERN
void 
FormulaUnitsData_setComponentTypecode(FormulaUnitsData_t* fud, 
                                      SBMLTypeCode_t typecode)
{
  fud->setComponentTypecode(typecode);
}

LIBSBML_EXTERN
void 
FormulaUnitsData_setContainsUndeclaredUnits(FormulaUnitsData_t* fud, 
                                            int flag)
{
  fud->setContainsParametersWithUndeclaredUnits(flag);
}

LIBSBML_EXTERN
void 
FormulaUnitsData_setCanIgnoreUndeclaredUnits(FormulaUnitsData_t* fud, 
                                             int flag)
{
  fud->setCanIgnoreUndeclaredUnits(flag);
}

LIBSBML_EXTERN
void 
FormulaUnitsData_setUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud)
{
  fud->setUnitDefinition(ud);
}

LIBSBML_EXTERN
void 
FormulaUnitsData_setPerTimeUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud)
{
  fud->setPerTimeUnitDefinition(ud);
}


LIBSBML_EXTERN
void 
FormulaUnitsData_setEventTimeUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud)
{
  fud->setEventTimeUnitDefinition(ud);
}

*/

/** @endcond */

LIBSBML_CPP_NAMESPACE_END
