/**
 * @file    ConversionOption.cpp
 * @brief   Implementation of ConversionOption, the class encapsulating conversion options.
 * @author  Frank Bergmann
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
 * ------------------------------------------------------------------------ -->
 */


#ifdef __cplusplus

#include <sbml/conversion/ConversionOption.h>
#include <sbml/SBase.h>

#include <algorithm>
#include <string>
#include <sstream>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

ConversionOption::ConversionOption(const std::string& key, const std::string& value, 
    ConversionOptionType_t type, 
    const std::string& description) : 
    mKey(key)
  , mValue(value)
  , mType(type)
  , mDescription(description)
{
}

ConversionOption::ConversionOption(const std::string& key, const char* value, 
  const std::string& description) : 
    mKey(key)
  , mValue(value)
  , mType(CNV_TYPE_STRING)
  , mDescription(description)
{
}

ConversionOption::ConversionOption(const std::string& key, bool value, 
  const std::string& description) : 
    mKey(key)
  , mValue("")
  , mType(CNV_TYPE_STRING)
  , mDescription(description)
{
  setBoolValue(value);
}

ConversionOption::ConversionOption(const std::string& key, double value, 
  const std::string& description): 
    mKey(key)
  , mValue("")
  , mType(CNV_TYPE_STRING)
  , mDescription(description)
{
  setDoubleValue(value);
}

ConversionOption::ConversionOption(const std::string& key, float value, 
  const std::string& description) : 
    mKey(key)
  , mValue("")
  , mType(CNV_TYPE_STRING)
  , mDescription(description)
{
  setFloatValue(value);
}

ConversionOption::ConversionOption(const std::string& key, int value, 
  const std::string& description) : 
    mKey(key)
  , mValue("")
  , mType(CNV_TYPE_STRING)
  , mDescription(description)
{
      setIntValue(value);
}


ConversionOption::ConversionOption
  (const ConversionOption& orig)
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mDescription = orig.mDescription;
    mKey = orig.mKey;
    mType = orig.mType;
    mValue = orig.mValue;
  }
}



ConversionOption& 
ConversionOption::operator=(const ConversionOption& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else
  {
    mDescription = rhs.mDescription;
    mKey = rhs.mKey;
    mType = rhs.mType;
    mValue = rhs.mValue;
  }
   return *this;
}

ConversionOption* 
ConversionOption::clone() const
{
  return new ConversionOption(*this);
}

ConversionOption::~ConversionOption() {}

const std::string&
ConversionOption::getKey() const
{
  return mKey;
}

void 
ConversionOption::setKey(const std::string& key)
{
  mKey = key;
}

const std::string&
ConversionOption::getValue() const
{
  return mValue;
}

void 
ConversionOption::setValue(const std::string& value)
{
  mValue = value;
}

const std::string&
ConversionOption::getDescription() const
{
  return mDescription;
}

void 
ConversionOption::setDescription(const std::string& description)
{
  mDescription = description;
}

ConversionOptionType_t 
ConversionOption::getType() const
{
  return mType;
}

void 
ConversionOption::setType(ConversionOptionType_t type)
{
  mType = type;
}

bool 
ConversionOption::getBoolValue() const
{
  string value = mValue;
#ifdef __BORLANDC__
   std::transform(value.begin(), value.end(), value.begin(),  (int(*)(int))
std::tolower);
#else
   std::transform(value.begin(), value.end(), value.begin(), ::tolower);
#endif
  if (value == "true") return true;
  if (value == "false") return false;

  stringstream str; str << mValue;
  bool result; str >> result;
  return result;
}

void 
ConversionOption::setBoolValue(bool value)
{  
  mValue = (value ? "true" : "false");
  setType(CNV_TYPE_BOOL);
}

double 
ConversionOption::getDoubleValue() const
{
  stringstream str; str << mValue;
  double result; str >> result;
  return result;
}
 
void 
ConversionOption::setDoubleValue(double value)
{
  stringstream str; str << value;
  mValue = str.str();
  setType(CNV_TYPE_DOUBLE);
}

 
float 
ConversionOption::getFloatValue() const
{
  stringstream str; str << mValue;
  float result; str >> result;
  return result;
}

void 
ConversionOption::setFloatValue(float value)
{
  stringstream str; str << value;
  mValue = str.str();
  setType(CNV_TYPE_SINGLE);
}

 
int 
ConversionOption::getIntValue() const
{
  stringstream str; str << mValue;
  int result; str >> result;
  return result;
}
 
void 
ConversionOption::setIntValue(int value)
{
  stringstream str; str << value;
  mValue = str.str();
  setType(CNV_TYPE_INT);
}


LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_create(const char* key)
{
  return new ConversionOption(key);
}


LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_clone(const ConversionOption_t* co)
{
  if (co == NULL) return NULL;
  return co->clone();
}

LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_createWithKeyAndType(const char* key, ConversionOptionType_t type)
{
  return new ConversionOption(key, type);
}

LIBSBML_EXTERN
const char*
ConversionOption_getKey(const ConversionOption_t* co)
{
  if (co == NULL) return NULL;
  return co->getKey().c_str();
}

LIBSBML_EXTERN
const char*
ConversionOption_getDescription(const ConversionOption_t* co)
{
  if (co == NULL) return NULL;
  return co->getDescription().c_str();
}

LIBSBML_EXTERN
const char*
ConversionOption_getValue(const ConversionOption_t* co)
{
  if (co == NULL) return NULL;
  return co->getValue().c_str();
}

LIBSBML_EXTERN
int
ConversionOption_getBoolValue(const ConversionOption_t* co)
{
  if (co == NULL) return 0;
  return (int) co->getBoolValue();
}

LIBSBML_EXTERN
int
ConversionOption_getIntValue(const ConversionOption_t* co)
{
  if (co == NULL) return 0;
  return (int) co->getIntValue();
}

LIBSBML_EXTERN
float
ConversionOption_getFloatValue(const ConversionOption_t* co)
{
  if (co == NULL) return std::numeric_limits<float>::quiet_NaN();
  return co->getFloatValue();
}

LIBSBML_EXTERN
double
ConversionOption_getDoubleValue(const ConversionOption_t* co)
{
  if (co == NULL) return std::numeric_limits<double>::quiet_NaN();
  return co->getDoubleValue();
}

LIBSBML_EXTERN
ConversionOptionType_t
ConversionOption_getType(const ConversionOption_t* co)
{
  if (co == NULL) return CNV_TYPE_STRING;
  return co->getType();
}

LIBSBML_EXTERN
void
ConversionOption_setKey(ConversionOption_t* co, const char* key)
{
  if (co == NULL) return;
  co->setKey(key);
}

LIBSBML_EXTERN
void
ConversionOption_setDescription(ConversionOption_t* co, const char* description)
{
  if (co == NULL) return;
  co->setDescription(description);
    
}

LIBSBML_EXTERN
void
ConversionOption_setValue(ConversionOption_t* co, const char* value)
{
  if (co == NULL) return;
  co->setValue(value);
}

LIBSBML_EXTERN
void
ConversionOption_setBoolValue(ConversionOption_t* co, int value)
{
  if (co == NULL) return;
  co->setBoolValue(value != 0);
}

LIBSBML_EXTERN
void
ConversionOption_setIntValue(ConversionOption_t* co, int value)
{
  if (co == NULL) return;
  co->setIntValue(value);
}

LIBSBML_EXTERN
void
ConversionOption_setFloatValue(ConversionOption_t* co, float value)
{
  if (co == NULL) return;
  co->setFloatValue(value);
}

LIBSBML_EXTERN
void
ConversionOption_setDoubleValue(ConversionOption_t* co, double value)
{
  if (co == NULL) return;
  co ->setDoubleValue(value);
}

LIBSBML_EXTERN
void
ConversionOption_setType(ConversionOption_t* co, ConversionOptionType_t type)
{
  if (co == NULL) return;
  co->setType(type);
}


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
