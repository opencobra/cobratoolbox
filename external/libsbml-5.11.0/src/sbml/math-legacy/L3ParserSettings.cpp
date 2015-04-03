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
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/util/StringBuffer.h>
#include <sbml/math/L3FormulaFormatter.h>
#include <cstddef>
#include <string>
#include <new>

#ifndef LIBSBML_USE_LEGACY_MATH
#include <sbml/extension/ASTBasePlugin.h>
#endif


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
  , mStrCmpIsCaseSensitive(L3P_COMPARE_BUILTINS_CASE_INSENSITIVE)
#ifndef LIBSBML_USE_LEGACY_MATH
  , mPlugins()
#endif
{
  setPlugins(NULL);
}

L3ParserSettings::L3ParserSettings(Model* model, ParseLogType_t parselog, bool collapseminus, bool parseunits, bool avocsymbol, bool caseSensitive, SBMLNamespaces* sbmlns)
  : mModel (model)
  , mParselog(parselog)
  , mCollapseminus(collapseminus)
  , mParseunits(parseunits)
  , mAvoCsymbol(avocsymbol)
  , mStrCmpIsCaseSensitive(caseSensitive)
#ifndef LIBSBML_USE_LEGACY_MATH
  , mPlugins()
#endif
{
  setPlugins(sbmlns);
}

L3ParserSettings::L3ParserSettings(const L3ParserSettings& source)
{
  mModel = source.mModel;
  mParselog = source.mParselog;
  mCollapseminus = source.mCollapseminus;
  mParseunits = source.mParseunits;
  mAvoCsymbol = source.mAvoCsymbol;
  mStrCmpIsCaseSensitive = source.mStrCmpIsCaseSensitive;

#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t mp=0; mp<source.mPlugins.size(); mp++) 
  {
    mPlugins.push_back(source.mPlugins[mp]->clone());
  }
#endif
}

L3ParserSettings& L3ParserSettings::operator=(const L3ParserSettings& source)
{
  mModel = source.mModel;
  mParselog = source.mParselog;
  mCollapseminus = source.mCollapseminus;
  mParseunits = source.mParseunits;
  mAvoCsymbol = source.mAvoCsymbol;
  mStrCmpIsCaseSensitive = source.mStrCmpIsCaseSensitive;

#ifndef LIBSBML_USE_LEGACY_MATH
  deletePlugins();
  for (size_t mp=0; mp<source.mPlugins.size(); mp++) 
  {
    mPlugins.push_back(source.mPlugins[mp]->clone());
  }
#endif 
  return *this;
}


L3ParserSettings::~L3ParserSettings()
{
  deletePlugins();
}

void
L3ParserSettings::setPlugins(const SBMLNamespaces * sbmlns)
{
#ifndef LIBSBML_USE_LEGACY_MATH
  deletePlugins();
  if (sbmlns == NULL)
  {
    unsigned int numPkgs = SBMLExtensionRegistry::getNumRegisteredPackages();

    for (unsigned int i=0; i < numPkgs; i++)
    {
      const std::string &uri = SBMLExtensionRegistry::getRegisteredPackageName(i);
      const SBMLExtension* sbmlext = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);

      if (sbmlext && sbmlext->isEnabled())
      {

        //const std::string &prefix = xmlns->getPrefix(i);
        const ASTBasePlugin* l3psPlugin = sbmlext->getASTBasePlugin();
        if (l3psPlugin != NULL)
        {
          //// need to give the plugin information about itself
          //l3psPlugin->setSBMLExtension(sbmlext);
          //l3psPlugin->connectToParent(this);
          mPlugins.push_back(l3psPlugin->clone());
        }

      }
    }
  }
  else
  {
    const XMLNamespaces *xmlns = sbmlns->getNamespaces();

    if (xmlns)
    {
      int numxmlns= xmlns->getLength();
      for (int i=0; i < numxmlns; i++)
      {
        const std::string &uri = xmlns->getURI(i);
        const SBMLExtension* sbmlext = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);

        if (sbmlext && sbmlext->isEnabled())
        {
          const ASTBasePlugin* l3psPlugin = sbmlext->getASTBasePlugin();
          if (l3psPlugin != NULL)
          {
            //ASTBasePlugin* myl3psPlugin = l3psPlugin->clone();
            //myl3psPlugin->setSBMLExtension(sbmlext);
            //myl3psPlugin->setPrefix(xmlns->getPrefix(i));
            mPlugins.push_back(l3psPlugin->clone());
          }
        }
      }
    }
  }
#endif
}


/** @cond doxygenLibsbmlInternal */
void L3ParserSettings::deletePlugins()
{
#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t p=0; p<mPlugins.size(); p++) {
    delete mPlugins[p];
  }
  mPlugins.clear();
#endif
}
/** @endcond */


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

/** @cond doxygenLibsbmlInternal */
bool L3ParserSettings::checkNumArgumentsForPackage(const ASTNode* function, stringstream& error) const
{
#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t p=0; p<mPlugins.size(); p++) {
    switch(mPlugins[p]->checkNumArguments(function, error)) {
    case -1:
      //The plugin knows that the function has the wrong number of arguments.
      return true;
    case 1:
      //The plugin knows that the function has the correct number of arguments.
      return false;
    case 0:
    default:
      //The plugin knows nothing about the function.
      break;
    }
  }

  //None of the plugins knew about the function!  This should never happen!
  assert(false);
#endif
  //However, we might as well assume that it got it right...
  return false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
ASTNode* L3ParserSettings::parsePackageInfix(L3ParserGrammarLineType_t type, 
    vector<ASTNode*> *nodeList, vector<std::string*> *stringList,
    vector<double> *doubleList) const
{
#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t p=0; p<mPlugins.size(); p++) {
    ASTNode* ret = mPlugins[p]->parsePackageInfix(
                         type, nodeList, stringList, doubleList);
    if (ret != NULL) return ret;
  }
#endif
  return NULL;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
int L3ParserSettings::getPackageFunctionFor(const std::string& name) const
{
#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t p=0; p<mPlugins.size(); p++) {
    int ret = mPlugins[p]->getPackageFunctionFor(name);
    if (ret != AST_UNKNOWN) return ret;
  }
#endif
  return AST_UNKNOWN;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void L3ParserSettings::visitPackageInfixSyntax(const ASTNode_t *parent,
                                          const ASTNode_t *node,
                                          StringBuffer_t  *sb) const
{
#ifndef LIBSBML_USE_LEGACY_MATH
  for (size_t p=0; p<mPlugins.size(); p++) {
    mPlugins[p]->visitPackageInfixSyntax(parent, node, sb, this);
  }
#endif
}
/** @endcond */

void L3ParserSettings::setComparisonCaseSensitivity(bool strcmp)
{
  mStrCmpIsCaseSensitive = strcmp;
}

bool L3ParserSettings::getComparisonCaseSensitivity() const
{
  return mStrCmpIsCaseSensitive;
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
  delete settings;
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

/**
 * Visits the given ASTNode and continues the inorder traversal.
 */
void
L3ParserSettings_visitPackageInfixSyntax( const ASTNode_t *parent,
                                     const ASTNode_t *node,
                                     StringBuffer_t  *sb, 
                                     const L3ParserSettings_t *settings )
{
  if (settings == NULL) return;
  settings->visitPackageInfixSyntax(parent, node, sb);
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END
