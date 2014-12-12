/**
 * @file    SBMLDocumentPlugin.cpp
 * @brief   Implementation of SBMLDocumentPlugin, the derived class of
 *          SBasePlugin.
 * @author  Akiya Jouraku
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/extension/SBMLDocumentPlugin.h>

#include <iostream>
using namespace std;


#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

SBMLDocumentPlugin::SBMLDocumentPlugin (const std::string &uri,
                                        const std::string &prefix,
                                        SBMLNamespaces *sbmlns)
  : SBasePlugin(uri,prefix,sbmlns)
  , mRequired(true)
  , mIsSetRequired(false)
{
}


/**
 * Copy constructor. Creates a copy of this SBase object.
 */
SBMLDocumentPlugin::SBMLDocumentPlugin(const SBMLDocumentPlugin& orig)
  : SBasePlugin(orig)
  , mRequired(orig.mRequired)
  , mIsSetRequired(orig.mIsSetRequired)
{
}


/**
 * Destroy this object.
 */
SBMLDocumentPlugin::~SBMLDocumentPlugin () {}

/**
 * Assignment operator for SBMLDocumentPlugin.
 */
SBMLDocumentPlugin&
SBMLDocumentPlugin::operator=(const SBMLDocumentPlugin& orig)
{
  if(&orig!=this)
  {
    this->SBasePlugin::operator =(orig);
    mRequired = orig.mRequired;
    mIsSetRequired = orig.mIsSetRequired;
  }

  return *this;
}


/**
 * Creates and returns a deep copy of this SBMLDocumentPlugin object.
 *
 * @return a (deep) copy of this SBase object
 */
SBMLDocumentPlugin*
SBMLDocumentPlugin::clone () const
{
  return new SBMLDocumentPlugin(*this);
}


// -----------------------------------------------
//
// virtual functions for attributes
//
// ------------------------------------------------


/** @cond doxygenLibsbmlInternal */

/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
SBMLDocumentPlugin::addExpectedAttributes(ExpectedAttributes& attributes)
{
  if (&attributes == NULL) return;
  //
  // required attribute is not defined for SBML Level 2 .
  //
  if ( mSBMLExt->getLevel(mURI) > 2)
  {
    attributes.add("required");
  }
}


/** @cond doxygenLibsbmlInternal */
void
SBMLDocumentPlugin::readAttributes (const XMLAttributes& attributes,
                                    const ExpectedAttributes& expectedAttributes)
{
  if (&attributes == NULL || &expectedAttributes == NULL ) return;

  SBasePlugin::readAttributes(attributes, expectedAttributes);

  if ( getLevel() > 2)
  {
    // check level of document version smaller than plugin
    // and report invalid if it is
    if (this->getSBMLDocument() != NULL &&
        this->getSBMLDocument()->getLevel() < mSBMLExt->getLevel(mURI))
    {
      // we should not have a package ns in an l2 document
      this->getSBMLDocument()->getErrorLog()->logError(L3PackageOnLowerSBML,
                                      this->getSBMLDocument()->getLevel(),
                                      this->getSBMLDocument()->getVersion());
    }
    else
    {
      XMLTriple tripleRequired("required", mURI, mPrefix);
      if (attributes.readInto(tripleRequired, mRequired, getErrorLog(),
                              true, getLine(), getColumn()))
      {
        mIsSetRequired = true;
      }
    }
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
void
SBMLDocumentPlugin::writeAttributes (XMLOutputStream& stream) const
{
  if (&stream == NULL) return;
  //
  // required attribute is not defined for SBML Level 2 .
  //
  if (getLevel() < 3)
    return;

  //cout << "[DEBUG] SBMLDocumentPlugin::writeAttributes() " << endl;
  if (isSetRequired()) {
    XMLTriple tripleRequired("required", mURI, mPrefix);
    stream.writeAttribute(tripleRequired, mRequired);
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLDocumentPlugin::isCompFlatteningImplemented() const
{
  return false;
}
/** @endcond */



/** @cond doxygenLibsbmlInternal */
unsigned int 
SBMLDocumentPlugin::checkConsistency()
{
  return 0;
}

/** @endcond */


/**
 *
 *  (EXTENSION) Additional public functions
 *
 */

bool
SBMLDocumentPlugin::getRequired() const
{
  return mRequired;
}


bool
SBMLDocumentPlugin::isSetRequired() const
{
  return mIsSetRequired;
}

int
SBMLDocumentPlugin::setRequired(bool required)
{
  //
  // required attribute is not defined for SBML Level 2 .
  //
  if ( getLevel()  < 3) {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }

  mRequired = required;
  mIsSetRequired = true;
  return LIBSBML_OPERATION_SUCCESS;
}


int
SBMLDocumentPlugin::unsetRequired()
{
  mRequired = false;
  mIsSetRequired = false;
  return LIBSBML_OPERATION_SUCCESS;
}


#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
SBMLDocumentPlugin_t*
SBMLDocumentPlugin_create(const char* uri, const char* prefix,
      SBMLNamespaces_t* sbmlns)
{
  if (uri == NULL || prefix == NULL) return NULL;
  string sUri(uri); string sPrefix(prefix);
  return new SBMLDocumentPlugin(sUri, sPrefix, sbmlns);
}

LIBSBML_EXTERN
SBMLDocumentPlugin_t*
SBMLDocumentPlugin_clone(SBMLDocumentPlugin_t* plugin)
{
  if (plugin == NULL) return NULL;
  return plugin->clone();
}

LIBSBML_EXTERN
int
SBMLDocumentPlugin_addExpectedAttributes(SBMLDocumentPlugin_t* plugin,
      ExpectedAttributes_t* attributes)
{
  if (plugin == NULL || attributes == NULL) return LIBSBML_INVALID_OBJECT;
  plugin->addExpectedAttributes(*attributes);
  return LIBSBML_OPERATION_SUCCESS;
}

LIBSBML_EXTERN
int
SBMLDocumentPlugin_readAttributes(SBMLDocumentPlugin_t* plugin,
      const XMLAttributes_t* attributes,
      const ExpectedAttributes_t* expectedAttributes)
{
  if (plugin == NULL || attributes == NULL || expectedAttributes == NULL)
    return LIBSBML_INVALID_OBJECT;
  plugin->readAttributes(*attributes, *expectedAttributes);
  return LIBSBML_OPERATION_SUCCESS;
}

LIBSBML_EXTERN
int
SBMLDocumentPlugin_writeAttributes(SBMLDocumentPlugin_t* plugin,
      XMLOutputStream_t* stream)
{
  if (plugin == NULL || stream == NULL) return LIBSBML_INVALID_OBJECT;
  plugin->writeAttributes(*stream);
  return LIBSBML_OPERATION_SUCCESS;
}

LIBSBML_EXTERN
int
SBMLDocumentPlugin_getRequired(SBMLDocumentPlugin_t* plugin)
{
  if (plugin == NULL) return LIBSBML_INVALID_OBJECT;
  return plugin->getRequired();
}

LIBSBML_EXTERN
int
SBMLDocumentPlugin_setRequired(SBMLDocumentPlugin_t* plugin, int required)
{
  if (plugin == NULL) return LIBSBML_INVALID_OBJECT;
  return plugin->setRequired((bool)required);
}


LIBSBML_EXTERN
int
SBMLDocumentPlugin_isSetRequired(SBMLDocumentPlugin_t* plugin)
{
  if (plugin == NULL) return LIBSBML_INVALID_OBJECT;
  return plugin->isSetRequired();
}


LIBSBML_EXTERN
int
SBMLDocumentPlugin_unsetRequired(SBMLDocumentPlugin_t* plugin)
{
  if (plugin == NULL) return LIBSBML_INVALID_OBJECT;
  return plugin->unsetRequired();
}


/** @endcond */
LIBSBML_CPP_NAMESPACE_END
