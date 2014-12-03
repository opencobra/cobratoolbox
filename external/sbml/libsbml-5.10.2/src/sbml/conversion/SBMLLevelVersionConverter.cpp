/**
 * @file    SBMLLevelVersionConverter.cpp
 * @brief   Implementation of SBMLLevelVersionConverter, the base class of package extensions.
 * @author  Sarah Keating
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

#include <sbml/conversion/SBMLLevelVersionConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/extension/SBMLExtensionRegistry.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLReader.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

  
/** @cond doxygenLibsbmlInternal */
void SBMLLevelVersionConverter::init()
{
  SBMLLevelVersionConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLLevelVersionConverter::SBMLLevelVersionConverter () 
  : SBMLConverter("SBML Level Version Converter")
{
}


/*
 * Copy constructor.
 */
SBMLLevelVersionConverter::SBMLLevelVersionConverter(const SBMLLevelVersionConverter& orig) :
    SBMLConverter(orig)
{
}


/*
 * Destroy this object.
 */
SBMLLevelVersionConverter::~SBMLLevelVersionConverter ()
{
}


/*
 * Assignment operator for SBMLLevelVersionConverter.
 */
SBMLLevelVersionConverter& 
SBMLLevelVersionConverter::operator=(const SBMLLevelVersionConverter& rhs)
{  
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBMLConverter::operator =(rhs);
  }

  return *this;
}


SBMLLevelVersionConverter*
SBMLLevelVersionConverter::clone () const
{
  return new SBMLLevelVersionConverter(*this);
}


ConversionProperties
SBMLLevelVersionConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    SBMLNamespaces * sbmlns = new SBMLNamespaces(); // default namespaces
    prop.setTargetNamespaces(sbmlns); // this gets cloned
    prop.addOption("strict", true,
                   "Whether validity should be strictly preserved");
    prop.addOption("setLevelAndVersion", true, 
                   "Convert the model to a given Level and Version of SBML");
    delete sbmlns;
    init = true;
    return prop;
  }
}


bool 
SBMLLevelVersionConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("setLevelAndVersion"))
    return false;
  return true;
}


unsigned int 
SBMLLevelVersionConverter::getTargetLevel()
{
  if (getTargetNamespaces() != NULL)
  {
    return getTargetNamespaces()->getLevel();
  }
  else
  {
    return SBML_DEFAULT_LEVEL;
  }
}


unsigned int 
SBMLLevelVersionConverter::getTargetVersion()
{
  if (getTargetNamespaces() != NULL)
  {
    return getTargetNamespaces()->getVersion();
  }
  else
  {
    return SBML_DEFAULT_VERSION;
  }
}


bool 
SBMLLevelVersionConverter::getValidityFlag()
{
  if (getProperties() == NULL)
  {
    return true;
  }
  else if (getProperties()->hasOption("strict") == false)
  {
    return true;
  }
  else
  {
    return getProperties()->getBoolValue("strict");
  }
}


int
SBMLLevelVersionConverter::convert()
{
  SBMLNamespaces *ns = getTargetNamespaces();
  if (ns == NULL)
  {
    return LIBSBML_CONV_INVALID_TARGET_NAMESPACE;
  }
  bool hasValidNamespace = ns->isValidCombination();
  if (hasValidNamespace == false)
  {
    return LIBSBML_CONV_INVALID_TARGET_NAMESPACE;
  }
  
  if (mDocument == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  bool strict = getValidityFlag();

  //bool success = mDocument->setLevelAndVersion(mTargetNamespaces->getLevel(), 
  //  mTargetNamespaces->getVersion(), false);
  /* mDocument->check we are not already the level and version */

  unsigned int currentLevel = mDocument->getLevel();
  unsigned int currentVersion = mDocument->getVersion();
  unsigned int targetLevel = getTargetLevel(); 
  unsigned int targetVersion = getTargetVersion();

  if (currentLevel == targetLevel && currentVersion == targetVersion)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  /* since this function will write to the error log we should
   * clear anything in the log first
   */
  mDocument->getErrorLog()->clearLog();
  Model * currentModel = mDocument->getModel();

  bool conversion = false;

  bool ignorePackages = getProperties()->getBoolValue("ignorePackages");

  /* if model has extensions we cannot convert */
  if (!ignorePackages && mDocument->getNumPlugins() > 0)
  {

    // disable all unused packages
    SBMLExtensionRegistry::getInstance().disableUnusedPackages(mDocument);
    if (mDocument->getNumPlugins() > 0)
    {
      // if there are still plugins enabled fail
      mDocument->getErrorLog()->logError(PackageConversionNotSupported, 
                                         currentLevel, currentVersion);
      return LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE;

    }
  }


  // deal with the case where a package that libsbml does not know about
  // has been read in
  // the model is not L3V1 core ONLY and so should not be
  // converted by this function

  // TO DO - SK Comment

  //if (mDocument->mAttributesOfUnknownPkg.isEmpty())
  //{
  //  mDocument->getErrorLog()->logError(PackageConversionNotSupported, 
  //                                     currentLevel, currentVersion);
  //  return LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE;
  //}
  unsigned char origValidators = mDocument->getApplicableValidators();
  unsigned char convValidators = mDocument->getConversionValidators();
  /* if strict = true we will only convert a valid model
   * to a valid model with a valid internal representation
   */
  /* see whether the unit validator is on */
  //bool strictSBO   = ((convValidators & 0x04) == 0x04);
  bool strictUnits = strict && ((convValidators & UnitsCheckON) == UnitsCheckON);
  
  if (strict == true)
  {
    /* use validators that the user has selected
    */
    /* hack to catch errors caught at read time */
    char* doc = writeSBMLToString(mDocument);
    SBMLDocument *d = readSBMLFromString(doc);
    util_free(doc);
    unsigned int errors = d->getNumErrors();

    for (unsigned int i = 0; i < errors; i++)
    {
      mDocument->getErrorLog()->add(*(d->getError(i)));
    }
    delete d;

    mDocument->checkConsistency();
    errors = mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR);

    /* if the current model is not valid dont convert 
    */
    if (errors > 0)
    {
      return LIBSBML_CONV_INVALID_SRC_DOCUMENT;
    }

    mDocument->getErrorLog()->clearLog();
  }

  unsigned int i;
  bool duplicateAnn = false;
  //look at annotation on sbml element - since validation only happens on the model :-(
  XMLNode *ann = mDocument->getAnnotation();
  if (ann != NULL)
  {
    for (i = 0; i < ann->getNumChildren(); i++)
    {
      std::string name = ann->getChild(i).getPrefix();
      for( unsigned int n= i+1; n < ann->getNumChildren(); n++)
      {
        if (ann->getChild(n).getPrefix() == name)
          duplicateAnn = true;
      }
    }
  }

  if (currentModel != NULL)
  {
    unsigned int origLevel;
    unsigned int origVersion;
    Model *origModel;
    if (strict)
    {
      /* here we are strict and only want to do
       * conversion if output will be valid
       *
       * save a copy of the model so it can be restored
       */
      origLevel = currentLevel;
      origVersion = currentVersion;
      origModel = currentModel->clone();
    }

    conversion = performConversion(strict, strictUnits, duplicateAnn);
      
    if (conversion == false)
    {
      /* if we were strict restore original model */

      if (strict)
      {
        delete origModel;
        mDocument->setApplicableValidators(origValidators);
        mDocument->updateSBMLNamespace("core", origLevel, origVersion);
      }
    }
    else
    {
      if (strict)
      {
        /* now we want to mDocument->check whether the resulting model is valid
         */
        mDocument->validateSBML();
        unsigned int errors = 
           mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR);
        if (errors > 0)
        { /* error - we dont covert
           * restore original values and return
           */
          conversion = false;
          /* undo any changes */
          *currentModel = *(origModel->clone());
          mDocument->updateSBMLNamespace("core", origLevel, origVersion);
          mDocument->setApplicableValidators(origValidators);
          delete origModel;
        }
        else
        {
          delete origModel;
        }
      }
    }
  }
  else
  {
    mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
    conversion = true;
  }

  /* restore original value */
  mDocument->setApplicableValidators(origValidators); 
  

  if (conversion)
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}
 

/** @cond doxygenLibsbmlInternal */
bool
SBMLLevelVersionConverter::performConversion(bool strict, bool strictUnits, 
                                        bool duplicateAnn)
{
  bool conversion = false;
 
  bool doConversion = false;
  
  unsigned int currentLevel = mDocument->getLevel();
  unsigned int currentVersion = mDocument->getVersion();
  unsigned int targetLevel = getTargetLevel(); 
  unsigned int targetVersion = getTargetVersion();
  Model * currentModel = mDocument->getModel();

  unsigned int i = 0;
  
  if (currentLevel == 1)
  {
    switch (targetLevel)
    {
    case 1:
      switch (targetVersion)
      {
      case 1:
        mDocument->getErrorLog()->logError(CannotConvertToL1V1);
        break;
      case 2:
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        conversion = true;
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      break;
    case 2:    
      switch (targetVersion)
      {
      case 1:
        if (!conversion_errors(mDocument->checkL2v1Compatibility()))
        {
          doConversion = true;
        }
        break;
      case 2:
        if (!conversion_errors(mDocument->checkL2v2Compatibility()))
        {
          doConversion = true;
        }
        break;
      case 3:
        if (!conversion_errors(mDocument->checkL2v3Compatibility()))
        {
          doConversion = true;
        }
        break;
      case 4:
        if (!conversion_errors(mDocument->checkL2v4Compatibility()))
        {
          doConversion = true;
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
        currentModel->removeParameterRuleUnits(strict);
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        currentModel->convertL1ToL2();
        conversion = true;
      }
      break;
    case 3:
      switch (targetVersion)
      {
      case 1:
        if (!conversion_errors(mDocument->checkL3v1Compatibility()))
        {
          doConversion = true;
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
         
        currentModel->removeParameterRuleUnits(strict);
        currentModel->convertParametersToLocals(targetLevel, targetVersion);
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        currentModel->convertL1ToL3();
        conversion = true;
      }
      break;
    default:
      mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
      break;
    }
  }
  else if (currentLevel == 2)
  {
    switch (targetLevel)
    {
    case 1:
      switch (targetVersion)
      {
      case 1:
        mDocument->getErrorLog()->logError(CannotConvertToL1V1);
        break;
      case 2:
        if (!conversion_errors(mDocument->checkL1Compatibility()))
        {
          doConversion = true;
          /* if existing model is L2V4 need to mDocument->check that
          * units are strict
          */
          if (currentVersion == 4 && strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL1);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL1);
                doConversion = false;
              }
            }
          }
          else
          {
            doConversion = true;
          }
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
        mDocument->expandFunctionDefinitions();
        mDocument->expandInitialAssignments();
        currentModel->convertL2ToL1(strict);
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        conversion = true;
      }
      break;
    case 2:
      switch (targetVersion)
      {
      case 1:
        if (!conversion_errors(mDocument->checkL2v1Compatibility()))
        {
          doConversion = true;
          /* if existing model is L2V4 need to mDocument->check that
          * units are strict
          */
          if (currentVersion == 4 && strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v1);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v1);
                doConversion = false;
              }
            }
          }
          else
          {
            doConversion = true;
          }
        }
        break;
      case 2:
        if (!conversion_errors(mDocument->checkL2v2Compatibility()))
        {
          doConversion = true;
          /* if existing model is L2V4 need to mDocument->check that
          * units are strict
          */
          if (currentVersion == 4 && strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v2);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v2);
                doConversion = false;
              }
            }
          }
          
          if (currentVersion == 4 && !hasStrictSBO())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictSBORequiredInL2v2);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictSBORequiredInL2v2);
                doConversion = false;
              }
            }
          }
          // look for duplicate top targetLevel annotations
          for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
          {
            if (mDocument->getErrorLog()->getError(i)->getErrorId() 
                                == DuplicateAnnotationInvalidInL2v2)
              duplicateAnn = true;
          }
         }
        break;
      case 3:
        if (!conversion_errors(mDocument->checkL2v3Compatibility()))
        {
          doConversion = true;
          /* if existing model is L2V4 need to mDocument->check that
          * units are strict
          */
          if (currentVersion == 4 && strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v3);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v3);
                doConversion = false;
              }
            }
          }
          
          if (currentVersion == 4 && !hasStrictSBO())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictSBORequiredInL2v3);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictSBORequiredInL2v3);
                doConversion = false;
              }
            }
          }
          // look for duplicate top targetLevel annotations
          for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
          {
            if (mDocument->getErrorLog()->getError(i)->getErrorId() 
                            == DuplicateAnnotationInvalidInL2v3)
              duplicateAnn = true;
          }
         }
        break;
      case 4:
        if (!conversion_errors(mDocument->checkL2v4Compatibility()))
        {
          doConversion = true;
          // look for duplicate top targetLevel annotations
          for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
          {
            if (mDocument->getErrorLog()->getError(i)->getErrorId() 
                            == DuplicateAnnotationInvalidInL2v4)
              duplicateAnn = true;
          }
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
        if (duplicateAnn == true)
        {
          mDocument->removeDuplicateAnnotations();
          currentModel->removeDuplicateTopLevelAnnotations();
        }
        if (targetVersion == 1)
        {
          currentModel->removeSBOTerms(strict);
          mDocument->expandInitialAssignments();
        }
        else if (targetVersion == 2)
        {
          currentModel->removeSBOTermsNotInL2V2(strict);
        }
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        conversion = true;
      }
      break;
    case 3:
      switch (targetVersion)
      {
      case 1:
        if (!conversion_errors(mDocument->checkL3v1Compatibility()))
        {
          doConversion = true;
          // look for duplicate top targetLevel annotations
          for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
          {
            if (mDocument->getErrorLog()->getError(i)->getErrorId() 
                            == DuplicateAnnotationInvalidInL2v4)
              duplicateAnn = true;
          }
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
        if (duplicateAnn == true)
        {
          mDocument->removeDuplicateAnnotations();
          currentModel->removeDuplicateTopLevelAnnotations();
        }
        currentModel->convertParametersToLocals(targetLevel, targetVersion);
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        currentModel->convertL2ToL3();
        conversion = true;
      }
      break;
    default:
      mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
      break;
    }      
  }
  else if (currentLevel == 3)
  {
    switch (targetLevel)
    {
    case 1:
      switch (targetVersion)
      {
      case 1:
        mDocument->getErrorLog()->logError(CannotConvertToL1V1);
        break;
      case 2:
        if (!conversion_errors(mDocument->checkL1Compatibility(), strictUnits))
        {
          doConversion = true;
          if (strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL1);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL1);
                doConversion = false;
              }
            }
          }
          if (doConversion == true)
          {
            mDocument->expandFunctionDefinitions();
            mDocument->expandInitialAssignments();
            mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
            currentModel->convertL3ToL1();
            conversion = true;
          }
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      break;
    case 2:
      switch (targetVersion)
      {
      case 1:
        if (!conversion_errors(mDocument->checkL2v1Compatibility(), strictUnits))
        {
          doConversion = true;
           if (strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v1);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v1);
                doConversion = false;
              }
            }
          }
       }
        break;
      case 2:
        if (!conversion_errors(mDocument->checkL2v2Compatibility(), strictUnits))
        {
          doConversion = true;
          if (strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v2);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v2);
                doConversion = false;
              }
            }
          }
          if (!hasStrictSBO())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictSBORequiredInL2v2);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictSBORequiredInL2v2);
                doConversion = false;
              }
            }
          }
       }
        break;
      case 3:
        if (!conversion_errors(mDocument->checkL2v3Compatibility(), strictUnits))
        {
          doConversion = true;
          if (strictUnits == true && !hasStrictUnits())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v3);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictUnitsRequiredInL2v3);
                doConversion = false;
              }
            }
          }
          if (!hasStrictSBO())
          {
            if (strict == false)
            {
              mDocument->getErrorLog()->logError(StrictSBORequiredInL2v3);
            }
            else
            {
              if (strictUnits == true)
              {
                mDocument->getErrorLog()->logError(StrictSBORequiredInL2v3);
                doConversion = false;
              }
            }
          }
        }
        break;
      case 4:
        if (!conversion_errors(mDocument->checkL2v4Compatibility(), strictUnits))
        {
          doConversion = true;
        }
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      if (doConversion == true)
      {
        if (targetVersion == 1)
        {
          mDocument->expandInitialAssignments();
        }
        mDocument->updateSBMLNamespace("core", targetLevel, targetVersion);
        currentModel->convertL3ToL2(strict);
        conversion = true;
      }
      break;
    case 3:
      switch (targetVersion)
      {
      case 1:
        conversion = true;
        break;
      default:
        mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
        break;
      }
      break;
    default:
      mDocument->getErrorLog()->logError(InvalidTargetLevelVersion, currentLevel, currentVersion);
      break;
    }

  }

  return conversion;

}

/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Predicate returning true if the errors encountered are not ignorable.
 */
bool
SBMLLevelVersionConverter::conversion_errors(unsigned int errors, bool strictUnits)
{  
  // if people have declared that they want to convert, even should 
  // conversion errors occur, then return false, so the conversion will 
  // proceed. In that case we leave the error log in tact, so people are
  // notified about potential issues. 
  if (!getValidityFlag())
  {
    return false;
  }


  /* if we are converting back from L3 and do not care about units
   * then we will allow a conversion where the spatialDimensions
   * has not been set
   */
  if (!strictUnits && errors > 0)
  {
    for (unsigned int n = 0; n < errors; n++)
    {
      if (mDocument->getErrorLog()->getError(n)->getErrorId() == L3SpatialDimensionsUnset)
      {
        mDocument->getErrorLog()->remove(NoNon3DCompartmentsInL1);
        mDocument->getErrorLog()->remove(IntegerSpatialDimensions);
      }
    }
    mDocument->getErrorLog()->remove(GlobalUnitsNotDeclared);
    // also allow extend units that are not in substance (or use undefined substance)
    mDocument->getErrorLog()->remove(ExtentUnitsNotSubstance);
  }
  /** 
   * changed this code in line with the rest of the validation 
   * errors: ie each now assigns a severity
   * Error would imply conversion not possible
   * Warning implies lose of data but conversion still possible
   */
  if (errors > 0)
  {
    if (mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      return true;
    else
      return false;
  }
  else
  {
    return false;
  }

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLLevelVersionConverter::hasStrictUnits()
{
  unsigned int errors = 0;

  UnitConsistencyValidator unit_validator;
  unit_validator.init();
  errors = unit_validator.validate(*mDocument);

  /* only want to return true if there are errors
  * not warnings
  * but in a L2V4 model they will only be warnings
  * so need to go by ErrorId
  */
  if (errors > 0)
  {
    const std::list<SBMLError>& fails = unit_validator.getFailures();
    std::list<SBMLError>::const_iterator iter;

    for (iter = fails.begin(); iter != fails.end(); ++iter)
    {
      if ( iter->getErrorId() > UpperUnitBound)
      {
        --errors;
      }
    }
  }
    
  return (errors == 0);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLLevelVersionConverter::hasStrictSBO()
{
  unsigned int errors = 0;

  SBOConsistencyValidator sbo_validator;
  sbo_validator.init();
  errors = sbo_validator.validate(*mDocument);

  /* only want to return true if there are errors
  * not warnings
  * but in a L2V4 model they will only be warnings
  * so need to go by ErrorId
  * InvalidDelaySBOTerm is the largest errorId that
  * would be considered an error in other level/versions
  */
  if (errors > 0)
  {
    const std::list<SBMLError>& fails = sbo_validator.getFailures();
    std::list<SBMLError>::const_iterator iter;

    for (iter = fails.begin(); iter != fails.end(); ++iter)
    {
      if ( iter->getErrorId() > InvalidDelaySBOTerm)
      {
        --errors;
      }
    }
  }

  return (errors == 0);

}
/** @endcond */



/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


