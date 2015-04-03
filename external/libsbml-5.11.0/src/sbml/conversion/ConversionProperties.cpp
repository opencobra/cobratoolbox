/**
* @file    ConversionProperties.cpp
* @brief   Implemenentation of ConversionProperties, the class encapsulating conversion configuration.
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

#include <sbml/conversion/ConversionProperties.h>
#include <sbml/conversion/ConversionOption.h>
#include <sbml/util/util.h>
#include <sbml/SBase.h>

#include <algorithm>
#include <string>
#include <sstream>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

ConversionProperties::ConversionProperties(SBMLNamespaces* targetNS) : mTargetNamespaces(NULL)
{
  if (targetNS != NULL) mTargetNamespaces = targetNS->clone();
}

ConversionProperties::ConversionProperties(const ConversionProperties& orig)
{
  
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {    
    if (orig.mTargetNamespaces != NULL)
      mTargetNamespaces = orig.mTargetNamespaces->clone();
    else 
      mTargetNamespaces = NULL;

    map<string, ConversionOption*>::const_iterator it;
    for (it = orig.mOptions.begin(); it != orig.mOptions.end(); ++it)
    {
      mOptions.insert(pair<string, ConversionOption*>
        ( it->second->getKey(), it->second->clone()));
    }
  }
}

ConversionProperties& 
ConversionProperties::operator=(const ConversionProperties& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  if (&rhs == this)
  {
    return *this;
  }
    // clear 

    if (mTargetNamespaces != NULL)
    {
      delete mTargetNamespaces;
      mTargetNamespaces = NULL;
    }
    
    map<string, ConversionOption*>::iterator it1;
    for (it1 = mOptions.begin(); it1 != mOptions.end(); ++it1)
    {
      if (it1->second != NULL) 
      { 
        delete it1->second;
        it1->second=NULL;
      }
    }
    mOptions.clear();

    // assign

    if (rhs.mTargetNamespaces != NULL)
      mTargetNamespaces = rhs.mTargetNamespaces->clone();
    else 
      mTargetNamespaces = NULL;

    map<string, ConversionOption*>::const_iterator it;
    for (it = rhs.mOptions.begin(); it != rhs.mOptions.end(); ++it)
    {
      mOptions.insert(pair<string, ConversionOption*>
        ( it->second->getKey(), it->second->clone()));
    }

    return *this;
}

ConversionProperties* 
ConversionProperties::clone() const
{
  return new ConversionProperties(*this);
}

ConversionProperties::~ConversionProperties()
{
  if (mTargetNamespaces != NULL)
  {
    delete mTargetNamespaces;
    mTargetNamespaces = NULL;
  }

  map<string, ConversionOption*>::iterator it;
  for (it = mOptions.begin(); it != mOptions.end(); ++it)
  {
    if (it->second != NULL) 
    { 
      delete it->second;
      it->second=NULL;
    }
  }

}

SBMLNamespaces * 
ConversionProperties::getTargetNamespaces() const
{
  return mTargetNamespaces;
}

bool 
ConversionProperties::hasTargetNamespaces() const
{
  return mTargetNamespaces != NULL;
}


void 
ConversionProperties::setTargetNamespaces(SBMLNamespaces *targetNS)
{
  if (mTargetNamespaces != NULL) 
  {
      delete mTargetNamespaces;
      mTargetNamespaces = NULL;
  }
  if (targetNS == NULL) return;
  
  mTargetNamespaces = targetNS->clone();
}

const std::string& 
ConversionProperties::getDescription(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getDescription();

	static std::string empty = "";

	return empty;
}

ConversionOptionType_t 
ConversionProperties::getType(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getType();

  return CNV_TYPE_STRING;
}


ConversionOption* 
ConversionProperties::getOption(const std::string& key) const
{

  map<string, ConversionOption*>::const_iterator it;
  for (it = mOptions.begin(); it != mOptions.end(); ++it)
  {
    if (it->second != NULL && it->second->getKey() == key)
      return it->second;
  }
  return NULL;
}

ConversionOption* 
ConversionProperties::getOption(int index) const
{
  map<string, ConversionOption*>::const_iterator it;
  int count = 0;
  for (it = mOptions.begin(); it != mOptions.end(); ++it,++count)
  {
    if (count == index)
      return it->second;
  }
  return NULL;
}

int 
ConversionProperties::getNumOptions() const
{
  return (int)mOptions.size();
}

void 
ConversionProperties::addOption(const ConversionOption &option)
{
  if (&option == NULL) return;
  ConversionOption *old = removeOption(option.getKey());
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(option.getKey(), option.clone()));
}

void 
ConversionProperties::addOption(const std::string& key, const std::string& value, 
    ConversionOptionType_t type, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(key, new ConversionOption(key, value, type, description)));
}
void 
ConversionProperties::addOption(const std::string& key, const char* value, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(key, new ConversionOption(key, value, description)));
}
void 
ConversionProperties::addOption(const std::string& key, bool value, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>( key, new ConversionOption(key, value, description) ));
}
void 
ConversionProperties::addOption(const std::string& key, double value, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(key, new ConversionOption(key, value, description)));
}
void 
ConversionProperties::addOption(const std::string& key, float value, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(key, new ConversionOption(key, value, description)));
}
void 
ConversionProperties::addOption(const std::string& key, int value, 
    const std::string& description)
{
  ConversionOption *old = removeOption(key);
  if (old != NULL) delete old;

  mOptions.insert(pair<string, ConversionOption*>(key, new ConversionOption(key, value, description)));
}

ConversionOption* 
ConversionProperties::removeOption(const std::string& key)
{
  ConversionOption* result = getOption(key);
  if (result != NULL)
    mOptions.erase(key);
  return result;
}

bool 
ConversionProperties::hasOption(const std::string& key) const
{
  return (getOption(key) != NULL);
}

const std::string& 
ConversionProperties::getValue(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getValue();
	static std::string empty = "";

	return empty;
}

void 
ConversionProperties::setValue(const std::string& key, const std::string& value)
{
  ConversionOption *option = getOption(key);
  if (option != NULL) option->setValue(value);
}


bool 
ConversionProperties::getBoolValue(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getBoolValue();
  return false;
}

void 
ConversionProperties::setBoolValue(const std::string& key, bool value)
{
  ConversionOption *option = getOption(key);
  if (option != NULL) option->setBoolValue(value);
}

double 
ConversionProperties::getDoubleValue(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getDoubleValue();
  return std::numeric_limits<double>::quiet_NaN();
}

void 
ConversionProperties::setDoubleValue(const std::string& key, double value)
{
  ConversionOption *option = getOption(key);
  if (option != NULL) option->setDoubleValue(value);
}

float 
ConversionProperties::getFloatValue(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getFloatValue();
  return std::numeric_limits<float>::quiet_NaN();
}

void 
ConversionProperties::setFloatValue(const std::string& key, float value)
{
  ConversionOption *option = getOption(key);
  if (option != NULL) option->setFloatValue(value);

}

int 
ConversionProperties::getIntValue(const std::string& key) const
{
  ConversionOption *option = getOption(key);
  if (option != NULL) return option->getIntValue();
  return -1;
}

void 
ConversionProperties::setIntValue(const std::string& key, int value)
{
  ConversionOption *option = getOption(key);
  if (option != NULL) option->setIntValue(value);

}



LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_create()
{
  return new ConversionProperties();
}

LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_createWithSBMLNamespace(SBMLNamespaces_t* sbmlns)
{
  return new ConversionProperties(sbmlns);
}

LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_clone(const ConversionProperties_t* cp)
{
  return new ConversionProperties();
}

LIBSBML_EXTERN
int
ConversionProperties_getBoolValue(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return 0;
  return cp->getBoolValue(key);
}

LIBSBML_EXTERN
int
ConversionProperties_getIntValue(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return -1;
  return cp->getIntValue(key);
}

LIBSBML_EXTERN
char*
ConversionProperties_getDescription(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return NULL;
  return strdup(cp->getDescription(key).c_str());
}

LIBSBML_EXTERN
double
ConversionProperties_getDoubleValue(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return std::numeric_limits<double>::quiet_NaN();
  return cp->getDoubleValue(key);
}

LIBSBML_EXTERN
float
ConversionProperties_getFloatValue(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return std::numeric_limits<float>::quiet_NaN();
  return cp->getFloatValue(key);
}

LIBSBML_EXTERN
char*
ConversionProperties_getValue(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return NULL;
  return strdup(cp->getValue(key).c_str());
}

LIBSBML_EXTERN
const ConversionOption_t*
ConversionProperties_getOption(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return NULL;
  return cp->getOption(key);
}

LIBSBML_EXTERN
ConversionOptionType_t
ConversionProperties_getType(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return CNV_TYPE_STRING;
  return cp->getType(key);
}

LIBSBML_EXTERN
const SBMLNamespaces_t*
ConversionProperties_getTargetNamespaces(const ConversionProperties_t* cp)
{
  if (cp == NULL) return NULL;
  return cp->getTargetNamespaces();
}

LIBSBML_EXTERN
int
ConversionProperties_hasOption(const ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL) return 0;
  return (int)cp->hasOption(key);
}

LIBSBML_EXTERN
int
ConversionProperties_hasTargetNamespaces(const ConversionProperties_t* cp)
{
  if (cp == NULL) return 0;
  return (int)cp->hasTargetNamespaces();
}

LIBSBML_EXTERN
void
ConversionProperties_setTargetNamespaces(ConversionProperties_t* cp, SBMLNamespaces_t* sbmlns)
{
  if (cp == NULL) return;
  cp->setTargetNamespaces(sbmlns);
}

LIBSBML_EXTERN
void
ConversionProperties_setBoolValue(ConversionProperties_t* cp, const char* key, int value)
{
  if (cp == NULL) return;
  cp->setBoolValue(key, (bool)value);
}

LIBSBML_EXTERN
void
ConversionProperties_setIntValue(ConversionProperties_t* cp, const char* key, int value)
{
  if (cp == NULL) return;
  cp->setIntValue(key, value);
}

LIBSBML_EXTERN
void
ConversionProperties_setDoubleValue(ConversionProperties_t* cp, const char* key, double value)
{
  if (cp == NULL) return;
  cp->setDoubleValue(key, value);
}

LIBSBML_EXTERN
void
ConversionProperties_setFloatValue(ConversionProperties_t* cp, const char* key, float value)
{
  if (cp == NULL) return;
  cp->setFloatValue(key, value);
}

LIBSBML_EXTERN
void
ConversionProperties_setValue(ConversionProperties_t* cp, const char* key, const char* value)
{
  if (cp == NULL) return;
  cp->setValue(key, value);
}

LIBSBML_EXTERN
void
ConversionProperties_addOption(ConversionProperties_t* cp, const ConversionOption_t* option)
{
  if (cp == NULL || option == NULL) return;
  cp->addOption(*option);
}

LIBSBML_EXTERN
void
ConversionProperties_addOptionWithKey(ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL || key == NULL) return;
  cp->addOption(key);
}

LIBSBML_EXTERN 
ConversionOption_t* 
ConversionProperties_removeOption(ConversionProperties_t* cp, const char* key)
{
  if (cp == NULL || key == NULL) return NULL;
  return cp->removeOption(key);
}
  
LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
