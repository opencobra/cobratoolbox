/**
 * @file    SBMLInferUnitsConverter.cpp
 * @brief   Implementation of SBMLInferUnitsConverter.
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

#include <sbml/conversion/SBMLInferUnitsConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
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
void SBMLInferUnitsConverter::init()
{
  SBMLInferUnitsConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLInferUnitsConverter::SBMLInferUnitsConverter () 
  : SBMLConverter("SBML Infer Units Converter")
{
  newIdCount = 0;
}


/*
 * Copy constructor.
 */
SBMLInferUnitsConverter::SBMLInferUnitsConverter(const SBMLInferUnitsConverter& orig) :
    SBMLConverter(orig)
{
  newIdCount = orig.newIdCount;
}


/*
 * Destroy this object.
 */
SBMLInferUnitsConverter::~SBMLInferUnitsConverter ()
{
}


/*
 * Assignment operator for SBMLInferUnitsConverter.
 */
SBMLInferUnitsConverter& 
SBMLInferUnitsConverter::operator=(const SBMLInferUnitsConverter& rhs)
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


SBMLInferUnitsConverter*
SBMLInferUnitsConverter::clone () const
{
  return new SBMLInferUnitsConverter(*this);
}


ConversionProperties
SBMLInferUnitsConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("inferUnits", true, 
                   "Infer the units of Parameters");
    init = true;
    return prop;
  }
}


bool 
SBMLInferUnitsConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("inferUnits"))
    return false;
  return true;
}


int
SBMLInferUnitsConverter::convert()
{
  if (mDocument == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  
  Model* mModel = mDocument->getModel();
  if (mModel == NULL) 
  {
    return LIBSBML_INVALID_OBJECT;
  }

  /* check consistency of model */
  /* since this function will write to the error log we should
  * clear anything in the log first
  */
  mDocument->getErrorLog()->clearLog();
  unsigned char origValidators = mDocument->getApplicableValidators();

  mDocument->setApplicableValidators(AllChecksON);

  mDocument->checkConsistency();


  /* replace original consistency checks */
  mDocument->setApplicableValidators(origValidators);

  if (mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) != 0)
  {
    return LIBSBML_CONV_INVALID_SRC_DOCUMENT;
  }

  /* so we have a consistent model - we can try inferring units */
  // TO DO keep a copy of model so we can revert back to it if things go wrong
  std::string newId;
  char number[4];
  for (unsigned int i = 0; i < mModel->getNumParameters(); i++)
  {
    if (mModel->getParameter(i)->isSetUnits() == false)
    {
      UnitDefinition * inferred = NULL;
      mModel->getParameter(i)->setCalculatingUnits(true);
      inferred = mModel->getParameter(i)->getDerivedUnitDefinition();
      mModel->getParameter(i)->setCalculatingUnits(false);
      
      if (inferred != NULL && inferred->getNumUnits() != 0)
      {
        bool baseUnit = false;

        newId = existsAlready(*(mModel), inferred);
        
        if (newId.empty())
        {
          if (inferred->isVariantOfDimensionless())
          {
            newId = "dimensionless";
            baseUnit = true;
          }
          else if (inferred->getNumUnits() == 1)
          {
            Unit * u = inferred->getUnit(0);
            Unit * defaultU = new Unit(u->getSBMLNamespaces());
            defaultU->initDefaults();
            defaultU->setKind(u->getKind());
            if (Unit::areIdentical(u, defaultU) == true)
            {
              newId = UnitKind_toString(u->getKind());
              baseUnit = true;
            }
          }
        }

        if (newId.empty())
        {
          /* create an id for the unitDef */
          sprintf(number, "%u", newIdCount);
          newId = "unitSid_" + string(number);
          newIdCount++;

          /* double check that this id has not been used */
          while (mModel->getUnitDefinition(newId) != NULL)
          {
            sprintf(number, "%u", newIdCount);
            newId = "unitSid_" + string(number);
            newIdCount++;
          }
        }
      
        if (baseUnit == false)
        {
          inferred->setId(newId);
          mModel->addUnitDefinition(inferred);
        }

        mModel->getParameter(i)->setUnits(newId);
      }
    }
  }

  return LIBSBML_OPERATION_SUCCESS;
}
 




/** @cond doxygenLibsbmlInternal */
std::string 
SBMLInferUnitsConverter::existsAlready(Model& m, UnitDefinition *newUD)
{
  std::string id = "";
  for (unsigned int i = 0; i < m.getNumUnitDefinitions(); i++)
  {
    if (UnitDefinition::areIdentical(m.getUnitDefinition(i), newUD))
    {
      return m.getUnitDefinition(i)->getId();
    }
  }

  return id;
}
/** @endcond */



/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


