/**
 * @file    L3ParserSettings.cpp
 * @brief   Definition of the level 3 infix-to-mathml parser settings.
 * @author  Lucian Smith
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

#include <sbml/math/L3ParserSettings.h>
#include <cstddef>
#include <new>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */
LIBSBML_CPP_NAMESPACE_BEGIN

#ifdef __cplusplus
L3ParserSettings::L3ParserSettings()
  : mModel (NULL)
  , mParselog(L3P_PARSE_LOG_AS_LOG10)
  , mCollapseminus(L3P_EXPAND_UNARY_MINUS)
  , mParseunits(L3P_PARSE_UNITS)
  , mAvoCsymbol(L3P_AVOGADRO_IS_CSYMBOL)
{
}

L3ParserSettings::L3ParserSettings(Model* model, ParseLogType_t parselog, bool collapseminus, bool parseunits, bool avocsymbol)
  : mModel (model)
  , mParselog(parselog)
  , mCollapseminus(collapseminus)
  , mParseunits(parseunits)
  , mAvoCsymbol(avocsymbol)
{
}

L3ParserSettings::~L3ParserSettings()
{
}



void L3ParserSettings::setModel(const Model* model)
{
  mModel = model;
}

const Model* L3ParserSettings::getModel() const
{
  return mModel;
}

void L3ParserSettings::unsetModel()
{
  mModel = NULL;
}


void L3ParserSettings::setParseLog(ParseLogType_t type)
{
  mParselog = type;
}

ParseLogType_t L3ParserSettings::getParseLog() const
{
  return mParselog;
}


void L3ParserSettings::setParseCollapseMinus(bool collapseminus)
{
  mCollapseminus = collapseminus;
}

bool L3ParserSettings::getParseCollapseMinus() const
{
  return mCollapseminus;
}

void L3ParserSettings::setParseUnits(bool units)
{
  mParseunits = units;
}

bool L3ParserSettings::getParseUnits() const
{
  return mParseunits;
}


void L3ParserSettings::setParseAvogadroCsymbol(bool avo)
{
  mAvoCsymbol = avo;
}

bool L3ParserSettings::getParseAvogadroCsymbol() const
{
  return mAvoCsymbol;
}


#endif /* __cplusplus */


/** @cond doxygenIgnored */

LIBSBML_EXTERN
L3ParserSettings_t *
L3ParserSettings_create ()
{
  return new(nothrow) L3ParserSettings;
}


LIBSBML_EXTERN
void
L3ParserSettings_free (L3ParserSettings_t * settings)
{
  settings = NULL;
}


LIBSBML_EXTERN
void
L3ParserSettings_setModel (L3ParserSettings_t * settings, const Model_t * model)
{
  if (settings == NULL)
    return;

  settings->setModel(model);
}


LIBSBML_EXTERN
const Model_t *
L3ParserSettings_getModel (const L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return NULL;

  return settings->getModel();
}


LIBSBML_EXTERN
void
L3ParserSettings_unsetModel (L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return;

  settings->unsetModel();
}


LIBSBML_EXTERN
void
L3ParserSettings_setParseLog (L3ParserSettings_t * settings, ParseLogType_t type)
{
  if (settings == NULL)
    return;

  settings->setParseLog(type);
}


LIBSBML_EXTERN
ParseLogType_t
L3ParserSettings_getParseLog (const L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return L3P_PARSE_LOG_AS_LOG10;

  return settings->getParseLog();
}


LIBSBML_EXTERN
void
L3ParserSettings_setParseCollapseMinus (L3ParserSettings_t * settings, int flag)
{
  if (settings == NULL)
    return;

  settings->setParseCollapseMinus(static_cast<bool>(flag));
}


LIBSBML_EXTERN
int
L3ParserSettings_getParseCollapseMinus (const L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return 0;

  return (static_cast<int>(settings->getParseCollapseMinus()));
}


LIBSBML_EXTERN
void
L3ParserSettings_setParseUnits (L3ParserSettings_t * settings, int flag)
{
  if (settings == NULL)
    return;

  settings->setParseUnits(static_cast<bool>(flag));
}


LIBSBML_EXTERN
int
L3ParserSettings_getParseUnits (const L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return 0;

  return (static_cast<int>(settings->getParseUnits()));
}


LIBSBML_EXTERN
void
L3ParserSettings_setParseAvogadroCsymbol (L3ParserSettings_t * settings, int flag)
{
  if (settings == NULL)
    return;

  settings->setParseAvogadroCsymbol(static_cast<bool>(flag));
}


LIBSBML_EXTERN
int
L3ParserSettings_getParseAvogadroCsymbol (const L3ParserSettings_t * settings)
{
  if (settings == NULL)
    return 0;

  return (static_cast<int>(settings->getParseAvogadroCsymbol()));
}


/** @endcond */
LIBSBML_CPP_NAMESPACE_END
