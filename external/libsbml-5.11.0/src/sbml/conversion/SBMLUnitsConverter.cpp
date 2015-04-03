/**
 * @file    SBMLUnitsConverter.cpp
 * @brief   Implementation of SBMLUnitsConverter, for converting units to SI.
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

#include <sbml/conversion/SBMLUnitsConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/extension/SBasePlugin.h>

#include <sbml/Model.h>
#include <sbml/AlgebraicRule.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

  
/** @cond doxygenLibsbmlInternal */
void SBMLUnitsConverter::init()
{
  SBMLUnitsConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLUnitsConverter::SBMLUnitsConverter () 
  : SBMLConverter("SBML Units Converter")
{
  newIdCount = 0;
}


/*
 * Copy constructor.
 */
SBMLUnitsConverter::SBMLUnitsConverter(const SBMLUnitsConverter& orig) 
  : SBMLConverter(orig)
{
  newIdCount = orig.newIdCount;
}


/*
 * Destroy this object.
 */
SBMLUnitsConverter::~SBMLUnitsConverter ()
{
}


/*
 * Assignment operator for SBMLUnitsConverter.
 */
SBMLUnitsConverter& 
SBMLUnitsConverter::operator=(const SBMLUnitsConverter& rhs)
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


SBMLUnitsConverter*
SBMLUnitsConverter::clone () const
{
  return new SBMLUnitsConverter(*this);
}


ConversionProperties
SBMLUnitsConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("units", true,
                   "Convert units in the model to SI units");
    prop.addOption("removeUnusedUnits", true, 
                 "Whether unused UnitDefinition objects should be removed");
    init = true;
    return prop;
  }
}


bool 
SBMLUnitsConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("units"))
    return false;
  return true;
}


/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::getRemoveUnusedUnitsFlag()
{
  if (getProperties() == NULL)
  {
    return true;
  }
  else if (getProperties()->hasOption("removeUnusedUnits") == false)
  {
    return true;
  }
  else
  {
    return getProperties()->getBoolValue("removeUnusedUnits");
  }
}
/** @endcond */

int
SBMLUnitsConverter::convert()
{

  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  Model* m = mDocument->getModel();
  if (m == NULL) return LIBSBML_INVALID_OBJECT;

  /* do not yet deal with the following units */
  if (m->getLevel() > 2)
  {
    ////if (m->isSetSubstanceUnits() == true)
    ////  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
    //if (m->isSetTimeUnits() == true)
    //  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
    ////else if (m->isSetLengthUnits() == true)
    ////  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
    ////else if (m->isSetAreaUnits() == true)
    ////  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
    ////else if (m->isSetVolumeUnits() == true)
    ////  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
    //else if (m->isSetExtentUnits() == true)
    //  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;

    //if (hasCnUnits(*m) == true)
    //  return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
  }

  unsigned int i;
  if (m->getLevel() == 2 && m->getVersion() < 3)
  {
    for (i = 0; i < m->getNumSpecies(); i++)
    {
      if (m->getSpecies(i)->isSetSpatialSizeUnits() == true)
      {
        return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
      }
    }
    for (i = 0; i < m->getNumEvents(); i++)
    {
      if (m->getEvent(i)->isSetTimeUnits() == true)
      {
        return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
      }
    }
  }
  if (m->getLevel() == 1 ||(m->getLevel() == 2 && m->getVersion() == 1))
  {
    for (i = 0; i < m->getNumReactions(); i++)
    {
      if (m->getReaction(i)->isSetKineticLaw() == true
        && ((m->getReaction(i)->getKineticLaw()->isSetTimeUnits() == true)
        || (m->getReaction(i)->getKineticLaw()->isSetSubstanceUnits() == true)))
      {
        return LIBSBML_CONV_CONVERSION_NOT_AVAILABLE;
      }
    }

  }

  /* need to check consistency - cannot convert if units are not declared */
  mDocument->getErrorLog()->clearLog();
  unsigned char origValidators = mDocument->getApplicableValidators();

  mDocument->setApplicableValidators(AllChecksON);


  unsigned int errors = mDocument->checkConsistency();

  if (unacceptable_errors(errors) == true)
  {
    mDocument->setApplicableValidators(origValidators);
    return LIBSBML_CONV_INVALID_SRC_DOCUMENT;
  }

  //create a copy of any global units
  if (m->getLevel() > 2)
  {
    if (m->isSetSubstanceUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("substance", m->getSubstanceUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("substance", ""));
    }
    if (m->isSetVolumeUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("volume", m->getVolumeUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("volume", ""));
    }
    if (m->isSetAreaUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("area", m->getAreaUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("area", ""));
    }
    if (m->isSetLengthUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("length", m->getLengthUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("length", ""));
    }
    if (m->isSetTimeUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("time", m->getTimeUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("time", ""));
    }
    if (m->isSetExtentUnits() == true)
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("extent", m->getExtentUnits()));
    }
    else
    {
      mGlobalUnits.insert(pair<const std::string, const std::string>
        ("extent", ""));
    }
  }

  bool conversion = true;

  for (i = 0; i < m->getNumParameters() && conversion == true; i++)
  {
    Parameter *p = m->getParameter(i);
    conversion = convertUnits(*p, *m);
  }

  for (i = 0; i < m->getNumCompartments() && conversion == true; i++)
  {
    Compartment *c = m->getCompartment(i);
    conversion = convertUnits(*c, *m);
  }
  for (i = 0; i < m->getNumSpecies() && conversion == true; i++)
  {
    Species *s = m->getSpecies(i);
    conversion = convertUnits(*s, *m);
  }
  for (i = 0; i < m->getNumReactions() && conversion == true; i++)
  {
    Reaction *r = m->getReaction(i);
    if (r->isSetKineticLaw() == true)
    {
      for (unsigned int j = 0; j < r->getKineticLaw()->getNumParameters(); j++)
      {
        Parameter *p = r->getKineticLaw()->getParameter(j);
        conversion = convertUnits(*p, *m);
      }
    }
  }


  if (m->getLevel() > 2)
  {
    if (conversion == true)
      conversion = convertGlobalUnits(*m);
    if (conversion == true)
      conversion = convertCnUnits(*m);
  }

  if (getRemoveUnusedUnitsFlag() == true)
  {
    removeUnusedUnitDefinitions(*m);
  }
    
  mDocument->setApplicableValidators(origValidators);

  if (conversion == true)
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}
  
/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::convertUnits(SBase &sb, Model &m)
{
  std::string emptyString = "";
  return convertUnits(sb, m, emptyString);

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::convertUnits(SBase &sb, Model &m, 
                                 std::string &modelUnitAttribute,
                                 ASTNode *ast)
{
  /* NOTE: the getDerivedUnitDefinition functions will return
   * units from the original model - they do not get updated
   * until after the conversion is complete
   */
  bool conversion = false;
  bool deleteUD = false;

  int tc = sb.getTypeCode();

  UnitDefinition *ud = NULL;
  UnitDefinition *ud_vol = NULL;

  bool hasValue = false;
  bool speciesHasSize = true;
  double oldValue = 0;
  switch(tc)
  {
    case SBML_PARAMETER:
      hasValue = static_cast<Parameter &>(sb).isSetValue();
      if (hasValue == true)
        oldValue = static_cast<Parameter &>(sb).getValue();
      ud = static_cast<Parameter &>(sb).getDerivedUnitDefinition();
      break;
    case SBML_LOCAL_PARAMETER:
      hasValue = static_cast<Parameter &>(sb).isSetValue();
      if (hasValue == true)
        oldValue = static_cast<Parameter &>(sb).getValue();
      ud = static_cast<Parameter &>(sb).getDerivedUnitDefinition();
      break;
    case SBML_COMPARTMENT:
      hasValue = static_cast<Compartment &>(sb).isSetSize();
      if (hasValue == true)
        oldValue = static_cast<Compartment &>(sb).getSize();
      ud = static_cast<Compartment &>(sb).getDerivedUnitDefinition();
      break;
    case SBML_SPECIES:
      if (static_cast<Species &>(sb).isSetInitialAmount() == true)
      {
        hasValue = true;
        oldValue = static_cast<Species &>(sb).getInitialAmount();
      }
      else
      {
        hasValue = static_cast<Species &>(sb).isSetInitialConcentration();
        if (hasValue == true)
          oldValue = static_cast<Species &>(sb).getInitialConcentration();
      }
      ud = static_cast<Species &>(sb).getDerivedUnitDefinition();
      /* the derived units will be concentration unless species
       * hasOnlySubstanceUnits is true or species is within
       * a 0D compartment
       */
      if (static_cast<Species &>(sb).getHasOnlySubstanceUnits() == false)
      {
        ud_vol = m.getCompartment(static_cast<Species &>(sb).getCompartment())
                                          ->getDerivedUnitDefinition();
      }
      else
      {
        ud_vol = NULL;
      }
      speciesHasSize = m.getCompartment(static_cast<Species &>(sb).getCompartment())
                                          ->isSetSize();
      break;
    case SBML_MODEL:
      if (modelUnitAttribute == "substance")
      {
        ud =  m.getFormulaUnitsData("substance", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      else if (modelUnitAttribute == "volume")
      {
        ud =  m.getFormulaUnitsData("volume", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      else if (modelUnitAttribute == "area")
      {
        ud =  m.getFormulaUnitsData("area", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      else if (modelUnitAttribute == "length")
      {
        ud =  m.getFormulaUnitsData("length", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      else if (modelUnitAttribute == "time")
      {
        ud =  m.getFormulaUnitsData("time", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      else if (modelUnitAttribute == "extent")
      {
        ud =  m.getFormulaUnitsData("extent", SBML_MODEL)
                                                 ->getUnitDefinition();
      }
      break;
    default:
      if (ast != NULL)
      {
        hasValue = true;
        if (ast->isInteger())
        {
          oldValue = ast->getInteger(); 
        }
        else if (ast->isReal())
        {
          oldValue = ast->getReal();
        }
        else
        {
          hasValue = false;
        }
        std::string units = ast->getUnits();
        if (UnitKind_isValidUnitKindString(units.c_str(), m.getLevel(), m.getVersion()))
        {
          ud = new UnitDefinition(m.getSBMLNamespaces());
          Unit * u = ud->createUnit();
          u->initDefaults();
          u->setKind(UnitKind_forName(units.c_str()));
          deleteUD = true;
        }
        else
        {
          // unit value refers to a unitDefinition
          ud = m.getUnitDefinition(units);
        }
      }
      else
      {
        return conversion;
      }
      break;
  }


 
  UnitDefinition *siud = UnitDefinition::convertToSI(ud);
  /* catch in case things have gone wrong */
  if (ud == NULL || siud == NULL)
    return false;

  /* if we are dealing in substance only then we need to use substance
   * units when calculating the newvalue 
   */
  if (speciesHasSize == false 
    && static_cast<Species &>(sb).isSetInitialAmount() == true
    && ud_vol != NULL)
  {
    /* we are dealing in concentration 
    * but the unit of the species must be substance
    */
    ud = UnitDefinition::combine(ud, ud_vol);
    siud = UnitDefinition::convertToSI(ud);
  }

  double newValue= 0.0;
  if (hasValue == true)
    newValue = oldValue;

  for (unsigned int n = 0; n < siud->getNumUnits(); n++)
  {
    if (hasValue == true)
      newValue = newValue * pow(siud->getUnit(n)->getMultiplier(),
                          siud->getUnit(n)->getExponentAsDouble());
    siud->getUnit(n)->setMultiplier(1.0);
  }

  if ((speciesHasSize == true && ud_vol != NULL)
    || (speciesHasSize == false 
        && static_cast<Species &>(sb).isSetInitialConcentration() == true 
        && ud_vol != NULL))

    {
      /* we are dealing in concentration 
      * but the unit of the species must be substance
      */
      UnitDefinition * tempud = UnitDefinition::combine(ud, ud_vol);
      if (siud != NULL)
      {
        delete siud;
        siud = NULL;
      }
      siud = UnitDefinition::convertToSI(tempud);
      delete tempud;
    }


  int i = LIBSBML_OPERATION_SUCCESS;
  if (hasValue == true)
  {
    switch(tc)
    {
      case SBML_PARAMETER:
        i = static_cast<Parameter &>(sb).setValue(newValue);
        break;
      case SBML_LOCAL_PARAMETER:
        i = static_cast<Parameter &>(sb).setValue(newValue);
        break;
      case SBML_COMPARTMENT:
        i = static_cast<Compartment &>(sb).setSize(newValue);
        break;
      case SBML_SPECIES:
        if (static_cast<Species &>(sb).isSetInitialAmount() == true)
        {
          if (static_cast<Species &>(sb).getHasOnlySubstanceUnits() == false)
          {
            if (speciesHasSize == true &&
              m.getCompartment(static_cast<Species &>(sb).getCompartment())
                                              ->getSpatialDimensions() != 0
                                              && ud_vol != NULL && ud_vol->getNumUnits() > 0)
            {
              newValue = newValue * 
                m.getCompartment(static_cast<Species &>(sb).getCompartment())
                                              ->getSize();
            }
          }
          i = static_cast<Species &>(sb).setInitialAmount(newValue);
        }
        else
        {
          if (speciesHasSize == true)
            i = static_cast<Species &>(sb).setInitialConcentration(newValue);
          else
            i = static_cast<Species &>(sb).setInitialAmount(newValue);

        }
        break;
      default:
        if (ast != NULL)
          i = ast->setValue(newValue);
        else
          i = LIBSBML_INVALID_OBJECT;
        break;
    }
  }

  if (i == LIBSBML_OPERATION_SUCCESS)
  {
    /* si unit has more than one base unit and so will need a unitDefinition */
    if (siud->getNumUnits() > 1)
    {
      i = siud->getUnit(0)->setMultiplier(1.0);
      if (i == LIBSBML_OPERATION_SUCCESS)
      {
        i = applyNewUnitDefinition(sb, m, siud, modelUnitAttribute, ast);
      }
    }
    else if (siud->getNumUnits() == 1)
    {
      Unit *u = siud->getUnit(0);
      i = u->setMultiplier(1.0);
      if (i == LIBSBML_OPERATION_SUCCESS)
      {
        /* only one base unit if exponent is 1 do not need definition */
        if (u->getExponentAsDouble() == 1)
        {
          std::string newUnit = UnitKind_toString(u->getKind());
          switch(tc)
          {
            case SBML_PARAMETER:
              i = static_cast<Parameter &>(sb).setUnits(newUnit);
              break;
            case SBML_LOCAL_PARAMETER:
              i = static_cast<Parameter &>(sb).setUnits(newUnit);
              break;
            case SBML_COMPARTMENT:
              // units might have come from model attributes
              if (static_cast<Compartment &>(sb).getUnits().empty())
              {
                unsigned int dims 
                  = static_cast<Compartment &>(sb).getSpatialDimensions();
                if (m.getLevel() > 2)
                {
                  switch (dims)
                  {
                  case 1:
                    i = m.setLengthUnits(newUnit);
                    break;
                  case 2:
                    i = m.setAreaUnits(newUnit);
                    break;
                  case 3:
                    i = m.setVolumeUnits(newUnit);
                    break;
                  default:
                    i = -1;
                    break;
                  }
                }
                else
                {
                  // the builtin unit might be already declared
                  switch (dims)
                  {
                  case 1:
                    if (UnitDefinition::areIdentical(m.getUnitDefinition("length"),
                               siud))
                    {
                      i = LIBSBML_OPERATION_SUCCESS;
                    }
                    else if (m.getUnitDefinition("length") == NULL 
                      && newUnit == "metre")
                    {
                      i = LIBSBML_OPERATION_SUCCESS;
                    }
                    else
                    {
                      i = static_cast<Compartment &>(sb).setUnits(newUnit);
                    }
                    break;
                  case 2:
                    if (UnitDefinition::areIdentical(m.getUnitDefinition("area"),
                               siud))
                    {
                      i = LIBSBML_OPERATION_SUCCESS;
                    }
                    else
                    {
                      i = static_cast<Compartment &>(sb).setUnits(newUnit);
                    }
                    break;
                  case 3:
                    if (UnitDefinition::areIdentical(m.getUnitDefinition("volume"),
                               siud))
                    {
                      i = LIBSBML_OPERATION_SUCCESS;
                    }
                    else
                    {
                      i = static_cast<Compartment &>(sb).setUnits(newUnit);
                    }
                    break;
                  default:
                    i = -1;
                    break;
                  }
                }
              }
              else
              {
                i = static_cast<Compartment &>(sb).setUnits(newUnit);
              }
              break;
            case SBML_SPECIES:
              // units might have come from model attributes
              if (static_cast<Species &>(sb).getSubstanceUnits().empty())
              {
                if (m.getLevel() > 2)
                {
                  i = m.setSubstanceUnits(newUnit);
                }
                else
                {
                  if (UnitDefinition::areIdentical(m.getUnitDefinition("substance"),
                               siud))
                  {
                    i = LIBSBML_OPERATION_SUCCESS;
                  }
                  else if (m.getUnitDefinition("substance") == NULL 
                    && newUnit == "mole")
                  {
                    i = LIBSBML_OPERATION_SUCCESS;
                  }
                  else
                  {
                    i = static_cast<Species &>(sb).setSubstanceUnits(newUnit);
                  }
                }
              }
              else
              {
                i = static_cast<Species &>(sb).setSubstanceUnits(newUnit);
              }
              break;
            case SBML_MODEL:
              if (modelUnitAttribute == "substance")
              {
                i = m.setSubstanceUnits(newUnit);
              }
              else if (modelUnitAttribute == "volume")
              {
                i = m.setVolumeUnits(newUnit);
              }
              else if (modelUnitAttribute == "area")
              {
                i = m.setAreaUnits(newUnit);
              }
              else if (modelUnitAttribute == "length")
              {
                i = m.setLengthUnits(newUnit);
              }
              else if (modelUnitAttribute == "time")
              {
                i = m.setTimeUnits(newUnit);
              }
              else if (modelUnitAttribute == "extent")
              {
                i = m.setExtentUnits(newUnit);
              }
              break;
            default:
              if (ast != NULL)
              {
                i = ast->setUnits(newUnit);
              }
              else
              {
                i = LIBSBML_INVALID_OBJECT;
              }
              break;
          }
        }
        else
        {
          i = applyNewUnitDefinition(sb, m, siud, modelUnitAttribute, ast);
        }
      }
    }
    else
    {
      i = LIBSBML_OPERATION_SUCCESS;
    }
  }


  if (i == LIBSBML_OPERATION_SUCCESS)
    conversion = true;

  if (siud != NULL) delete siud;
  if (deleteUD == true) delete ud;

  return conversion;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
int
SBMLUnitsConverter::applyNewUnitDefinition(SBase &sb, Model &m, 
                                           UnitDefinition* newUD,
                                           std::string &modelUnitAttribute,
                                           ASTNode * ast)
{

  int tc = sb.getTypeCode();
  std::string oldUnits;

  switch(tc)
  {
    case SBML_PARAMETER:
      oldUnits = static_cast<Parameter &>(sb).getUnits();
      break;
    case SBML_LOCAL_PARAMETER:
      oldUnits = static_cast<Parameter &>(sb).getUnits();
      break;
    case SBML_COMPARTMENT:
      oldUnits = static_cast<Compartment &>(sb).getUnits();
      break;
    case SBML_SPECIES:
      oldUnits = static_cast<Species &>(sb).getSubstanceUnits();
      break;
    case SBML_MODEL:
      if (modelUnitAttribute == "substance")
      {
        oldUnits = m.getSubstanceUnits();
      }
      else if (modelUnitAttribute == "volume")
      {
        oldUnits = m.getVolumeUnits();
      }
      else if (modelUnitAttribute == "area")
      {
        oldUnits = m.getAreaUnits();
      }
      else if (modelUnitAttribute == "length")
      {
        oldUnits = m.getLengthUnits();
      }
      else if (modelUnitAttribute == "time")
      {
        oldUnits = m.getTimeUnits();
      }
      else if (modelUnitAttribute == "extent")
      {
        oldUnits = m.getExtentUnits();
      }
      break;
    default:
      if (ast != NULL)
      {
        oldUnits = ast->getUnits();
      }
      else
      {
        return LIBSBML_INVALID_OBJECT;
      }
      break;
  }


  /* object already points to a unit def
   * check whether the existing defn matches the si ud */
  if (m.getUnitDefinition(oldUnits) != NULL)
  {
    if (UnitDefinition::areIdentical(m.getUnitDefinition(oldUnits), newUD))
    {
      return LIBSBML_OPERATION_SUCCESS;
    }
  }

  /* does it the newUD already exist */


  std::string newId;
  char number[4];
  int i=0;
  bool changedId = false;
  newId = existsAlready(m, newUD);
  if (newId.empty())
  {
    if (newUD->isVariantOfDimensionless())
    {
      newId = "dimensionless";
    }
  }
  if (newId.empty())
  {
    sprintf(number, "%u", newIdCount);
    newId = "unitSid_" + string(number);
    newIdCount++;

    /* double check that this id has not been used */
    while (m.getUnitDefinition(newId) != NULL)
    {
      sprintf(number, "%u", newIdCount);
      newId = "unitSid_" + string(number);
      newIdCount++;
    }
  
    i = newUD->setId(newId);
    if (i == LIBSBML_OPERATION_SUCCESS)
    {
      switch(tc)
      {
        case SBML_PARAMETER:
          i = static_cast<Parameter &>(sb).setUnits(newId);
          break;
        case SBML_LOCAL_PARAMETER:
          i = static_cast<Parameter &>(sb).setUnits(newId);
          break;
        case SBML_COMPARTMENT:
          // units might have come from model attributes or default unit
          if (oldUnits.empty())
          {
            unsigned int dims 
              = static_cast<Compartment &>(sb).getSpatialDimensions();
            if (m.getLevel() > 2)
            {
              switch (dims)
              {
              case 1:
                i = m.setLengthUnits(newId);
                break;
              case 2:
                i = m.setAreaUnits(newId);
                break;
              case 3:
                i = m.setVolumeUnits(newId);
                break;
              default:
                i = -1;
                break;
              }
            }
            else
            {
              switch (dims)
              {
              case 1:
                newId = "length";
                break;
              case 2:
                newId = "area";
                break;
              case 3:
                newId = "volume";
                break;
              default:
                newId = "12345";
                break;
              }
              i = newUD->setId(newId);
              if (i == LIBSBML_OPERATION_SUCCESS)
                changedId = true;
            }
          }
          else
          {
            i = static_cast<Compartment &>(sb).setUnits(newId);
          }
          break;
        case SBML_SPECIES:
          if (oldUnits.empty())
          {
            if (m.getLevel() > 2)
            {
              i = m.setSubstanceUnits(newId);
            }
            else
            {
              newId = "substance";
              i = newUD->setId(newId);
              if (i == LIBSBML_OPERATION_SUCCESS)
                changedId = true;
           }
          }
          else
          {
            i = static_cast<Species &>(sb).setSubstanceUnits(newId);
          }
          break;
        case SBML_MODEL:
          if (modelUnitAttribute == "substance")
          {
            i = m.setSubstanceUnits(newId);
          }
          else if (modelUnitAttribute == "volume")
          {
            i = m.setVolumeUnits(newId);
          }
          else if (modelUnitAttribute == "area")
          {
            i = m.setAreaUnits(newId);
          }
          else if (modelUnitAttribute == "length")
          {
            i = m.setLengthUnits(newId);
          }
          else if (modelUnitAttribute == "time")
          {
            i = m.setTimeUnits(newId);
          }
          else if (modelUnitAttribute == "extent")
          {
            i = m.setExtentUnits(newId);
          }
          break;
        default:
          if (ast != NULL)
          {
            i = ast->setUnits(newId);
          }
          else
          {
            i = LIBSBML_INVALID_OBJECT;
          }
          break;
      }
      if (i == LIBSBML_OPERATION_SUCCESS)
      {
        // in L2 models where there is a definition of a builtin unit that is 
        // not SI we will have changed the id to be the builtin unit
        // thus the add function will not work
        // need to check for this
        if (changedId == true)
        {
          if (m.getUnitDefinition(newId) != NULL)
          {
            delete m.removeUnitDefinition(newId);
          }
        }
        i = m.addUnitDefinition(newUD);
      }
    }
  }
  else
  {
    switch(tc)
    {
      case SBML_PARAMETER:
        i = static_cast<Parameter &>(sb).setUnits(newId);
        break;
      case SBML_LOCAL_PARAMETER:
        i = static_cast<Parameter &>(sb).setUnits(newId);
        break;
      case SBML_COMPARTMENT:
        // units might have come from model attributes or default unit
        if (oldUnits.empty())
        {
          unsigned int dims 
            = static_cast<Compartment &>(sb).getSpatialDimensions();
          if (m.getLevel() > 2)
          {
            switch (dims)
            {
            case 1:
              i = m.setLengthUnits(newId);
              break;
            case 2:
              i = m.setAreaUnits(newId);
              break;
            case 3:
              i = m.setVolumeUnits(newId);
              break;
            default:
              i = -1;
              break;
            }
          }
          else
          {
            bool isNew = false;
            switch (dims)
            {
            case 1:
              if (newId != "length")
                isNew = true;
              break;
            case 2:
              if (newId != "area")
                isNew = true;
              break;
            case 3:
              if (newId != "volume")
                isNew = true;
              break;
            default:
              break;
            }
            if (isNew == true)
            {
              i = static_cast<Compartment &>(sb).setUnits(newId);
            }
            else
            {
              i = LIBSBML_OPERATION_SUCCESS;
            }
          }
        }
        else
        {
          i = static_cast<Compartment &>(sb).setUnits(newId);
        }
        break;
      case SBML_SPECIES:
        if (oldUnits.empty())
        {
          if (m.getLevel() > 2)
          {
            i = m.setSubstanceUnits(newId);
          }
          else
          {
            if (newId != "substance")
              i = static_cast<Species &>(sb).setSubstanceUnits(newId);
            else
              i = LIBSBML_OPERATION_SUCCESS;
          }
        }
        else
        {
          i = static_cast<Species &>(sb).setSubstanceUnits(newId);
        }
        break;
      case SBML_MODEL:
        if (modelUnitAttribute == "substance")
        {
          i = m.setSubstanceUnits(newId);
        }
        else if (modelUnitAttribute == "volume")
        {
          i = m.setVolumeUnits(newId);
        }
        else if (modelUnitAttribute == "area")
        {
          i = m.setAreaUnits(newId);
        }
        else if (modelUnitAttribute == "length")
        {
          i = m.setLengthUnits(newId);
        }
        else if (modelUnitAttribute == "time")
        {
          i = m.setTimeUnits(newId);
        }
        else if (modelUnitAttribute == "extent")
        {
          i = m.setExtentUnits(newId);
        }
        break;
      default:
        if (ast != NULL)
        {
          i = ast->setUnits(newId);
        }
        else
        {
          i = LIBSBML_INVALID_OBJECT;
        }
        break;
    }
  }

  return i;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/* if a global unit has been set but not used by a compartment
 * species or parameter it will not have been converted.
 * Thus we check whether the value of the attribute has changed
 * and if not we do conversion just to make sure
 */
bool
SBMLUnitsConverter::convertGlobalUnits(Model &m)
{
  bool converted = true;

  std::string attrib = "substance";

  GlobalUnitsIter it = mGlobalUnits.find(attrib);
  std::string origUnits = (*it).second;

  // very unlikely that the model does not have units 
  // calculated as unit consistency checks will have been done
  // but just in case
  if (!m.isPopulatedListFormulaUnitsData())
  {
    m.populateListFormulaUnitsData();
  }


  if (converted == true && origUnits.empty() == false)
  { /* the substanceUnits have not been converted */
    if (m.getSubstanceUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  attrib = "volume";
  it = mGlobalUnits.find(attrib);
  origUnits = (*it).second;
  if (converted == true && origUnits.empty() == false)
  { /* the volume Units have not been converted */
    if (m.getVolumeUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  attrib = "area";
  it = mGlobalUnits.find(attrib);
  origUnits = (*it).second;
  if (converted == true && origUnits.empty() == false)
  { /* the area Units have not been converted */
    if (m.getAreaUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  attrib = "length";
  it = mGlobalUnits.find(attrib);
  origUnits = (*it).second;
  if (converted == true && origUnits.empty() == false)
  { /* the length Units have not been converted */
    if (m.getLengthUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  attrib = "time";
  it = mGlobalUnits.find(attrib);
  origUnits = (*it).second;
  if (converted == true && origUnits.empty() == false)
  { /* the time Units have not been converted */
    if (m.getTimeUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  attrib = "extent";
  it = mGlobalUnits.find(attrib);
  origUnits = (*it).second;
  if (converted == true && origUnits.empty() == false)
  { /* the extent Units have not been converted */
    if (m.getExtentUnits() == origUnits)
    {
      converted = convertUnits(m, m, attrib);
    }    
  }

  return converted;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::convertCnUnits(Model& m)
{
  bool converted = true;
  /* check all math within a model */

  unsigned int n;
  for (n = 0; n < m.getNumRules(); n++)
  {
    if (m.getRule(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getRule(n)->getMath()) == true)
      {
        if (convertAST(const_cast<ASTNode *>
                        (m.getRule(n)->getMath()), m) != true)
          converted = false;
      }
    }
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      if (m.getReaction(n)->getKineticLaw()->isSetMath())
      {
        if (mathHasCnUnits(m.getReaction(n)->getKineticLaw()->getMath()) == true)
        {
          if (convertAST(const_cast<ASTNode *>
                    (m.getReaction(n)->getKineticLaw()->getMath()), m) != true)
            converted = false;
        }
      }
    }
  }

  for (n = 0; n < m.getNumEvents(); n++)
  {
    if (m.getEvent(n)->isSetTrigger())
    {
      if (m.getEvent(n)->getTrigger()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getTrigger()->getMath()) == true)
        {
          if (convertAST(const_cast<ASTNode *>(
                           m.getEvent(n)->getTrigger()->getMath()), m) != true)
            converted = false;
        }
      }
    }
    if (m.getEvent(n)->isSetDelay())
    {
      if (m.getEvent(n)->getDelay()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getDelay()->getMath()) == true)
        {
          if (convertAST(const_cast<ASTNode *>(
                             m.getEvent(n)->getDelay()->getMath()), m) != true)
            converted = false;
        }
      }
    }
    if (m.getEvent(n)->isSetPriority())
    {
      if (m.getEvent(n)->getPriority()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getPriority()->getMath()) == true)
        {
          if (convertAST(const_cast<ASTNode *>(
                          m.getEvent(n)->getPriority()->getMath()), m) != true)
            converted = false;
        }
      }
    }
    for (unsigned int ea = 0; ea < m.getEvent(n)->getNumEventAssignments(); ea++)
    {
      if (m.getEvent(n)->getEventAssignment(ea)->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getEventAssignment(ea)->getMath()) == true)
        {
          if (convertAST(const_cast<ASTNode *>(
                  m.getEvent(n)->getEventAssignment(ea)->getMath()), m) != true)
            converted = false;
        }
      }
    }
  }

  for (n = 0; n < m.getNumInitialAssignments(); n++)
  {
    if (m.getInitialAssignment(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getInitialAssignment(n)->getMath()) == true)
      {
        if (convertAST(const_cast<ASTNode *>(
                             m.getInitialAssignment(n)->getMath()), m) != true)
          converted = false;
      }
    }
  }

  for (n = 0; n < m.getNumConstraints(); n++)
  {
    if (m.getConstraint(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getConstraint(n)->getMath()) == true)
      {
        if (convertAST(const_cast<ASTNode *>(
                                    m.getConstraint(n)->getMath()), m) != true)
          converted = false;
      }
    }
  }

  for (n = 0; n < m.getNumFunctionDefinitions(); n++)
  {
    if (m.getFunctionDefinition(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getFunctionDefinition(n)->getMath()) == true)
      {
        if (convertAST(const_cast<ASTNode *>(
                             m.getFunctionDefinition(n)->getMath()), m) != true)
          converted = false;
      }
    }
  }

  return converted;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::convertAST(ASTNode *ast, Model & m)
{
  bool converted = true;
  std::string emptyString = "";
 
  if (ast->isNumber() && ast->hasUnits() == true)
  {
    // do the conversion
    SBase *sb = ast->getParentSBMLObject();
    bool dummySBaseObject = false;
    if (sb == NULL)
    {
      // here we just need a default SBase object so that
      // convertUnits can look at what type of object
      // I chose AlgebraicRule as it will never have units
      // and I accnot create a generic SBase object
      sb = new AlgebraicRule(m.getSBMLNamespaces());
      dummySBaseObject = true;
    }
    converted = convertUnits(*(sb), m, emptyString, ast);
    if (dummySBaseObject == true)
    {
      delete sb;
    }
  }

  unsigned int n = 0; 
  while(n < ast->getNumChildren() && converted == true)
  {
    converted = convertAST(ast->getChild(n), m);
    n++;
  }

  return converted;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
std::string 
SBMLUnitsConverter::existsAlready(Model& m, UnitDefinition *newUD)
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


/** @cond doxygenLibsbmlInternal */
void
SBMLUnitsConverter::removeUnusedUnitDefinitions(Model& m)
{
  unsigned int num = m.getNumUnitDefinitions()-1;
  for (int i = num; i >= 0; i--)
  {
    if (Unit::isBuiltIn(m.getUnitDefinition(i)->getId(), m.getLevel()) == false
      && (isUsed(m, m.getUnitDefinition(i)->getId()) == false))
    {
      delete m.removeUnitDefinition(i);
    }
  }

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::isUsed(Model& m, std::string unitSId)
{
  unsigned int i = 0;

  if (m.getLevel() > 2)
  {
    if (unitSId == m.getSubstanceUnits())
      return true;
    else if (unitSId == m.getTimeUnits())
      return true;
    else if (unitSId == m.getLengthUnits())
      return true;
    else if (unitSId == m.getAreaUnits())
      return true;
    else if (unitSId == m.getVolumeUnits())
      return true;
    else if (unitSId == m.getExtentUnits())
      return true;

    if (matchesCnUnits(m, unitSId) == true)
      return true;
  }

  for (i = 0; i < m.getNumParameters(); i++)
  {
    if (unitSId == m.getParameter(i)->getUnits())
    {
      return true;
    }
  }
  for (i = 0; i < m.getNumCompartments(); i++)
  {
    if (unitSId == m.getCompartment(i)->getUnits())
    {
      return true;
    }
  }
  for (i = 0; i < m.getNumSpecies(); i++)
  {
    if (unitSId == m.getSpecies(i)->getSubstanceUnits())
    {
      return true;
    }
    if (m.getLevel() == 2 && m.getVersion() < 3)
    {
      if (unitSId == m.getSpecies(i)->getSpatialSizeUnits())
      {
        return true;
      }
    }
  }
  for (i = 0; i < m.getNumEvents(); i++)
  {
    if (m.getLevel() == 2 && m.getVersion() < 3)
    {
      if (unitSId == m.getEvent(i)->getTimeUnits())
      {
        return true;
      }
    }
  }
  for (i = 0; i < m.getNumReactions(); i++)
  {
    if (m.getReaction(i)->isSetKineticLaw() == true)
    {
      KineticLaw * kl = m.getReaction(i)->getKineticLaw();
      if ((m.getLevel() == 1 || (m.getLevel() == 2 && m.getVersion() == 1)))
      {
        if (unitSId == kl->getTimeUnits())
        {
          return true;
        }
        if (unitSId == kl->getSubstanceUnits())
        {
          return true;
        }
      }
      for (unsigned int j = 0; j < kl->getNumParameters(); j++)
      {
        if (unitSId == kl->getParameter(j)->getUnits())
        {
          return true;
        }
      }
    }
  }


  return false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Predicate returning true if the errors encountered are not ignorable.
 */
bool
SBMLUnitsConverter::unacceptable_errors(unsigned int errors)
{
  unsigned int i;
  if (errors > 0)
  {
    if (mDocument->getErrorLog()
                              ->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      return true;
    else
    {  
      for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
      {
        if (mDocument->getErrorLog()->getError(i)->getErrorId() == 
                                               ParameterShouldHaveUnits)
        {
          return true;
        }
        else if (mDocument->getErrorLog()->getError(i)->getErrorId() == 
                                                UndeclaredUnits)
        {
          return true;
        }
        else if (mDocument->getErrorLog()->getError(i)->getErrorId() == 
                                                UndeclaredTimeUnitsL3)
        {
          return true;
        }
        else if (mDocument->getErrorLog()->getError(i)->getErrorId() == 
                                                 UndeclaredExtentUnitsL3)
        {
          return true;
        }
        else if (mDocument->getErrorLog()->getError(i)->getErrorId() > 10500 &&
          mDocument->getErrorLog()->getError(i)->getErrorId() < 10599)
        {
          return true;
        }
      }
    }
  
    // look for species in conc units with substance units declared but
    // comp size undeclared

    bool checkSpecies = false;
    for (i = 0; i < mDocument->getErrorLog()->getNumErrors(); i++)
    {
      if (mDocument->getErrorLog()->getError(i)->getErrorId() 
                                                  == CompartmentShouldHaveSize)
      {
        checkSpecies = true;
      }
    }
    if (checkSpecies == true)
    {
      Species *s;
      Compartment *c;
      for (i = 0; i < mDocument->getModel()->getNumSpecies(); i++)
      {
        s = mDocument->getModel()->getSpecies(i);
        if (s->getHasOnlySubstanceUnits() == false)
        {
          c = mDocument->getModel()->getCompartment(s->getCompartment());
          if (c->getSpatialDimensions() != 0)
          {
            if (c->isSetSize() == false)
            {
              return true;
            }
          }
        }
      }
    }
   
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
SBMLUnitsConverter::hasCnUnits(Model& m)
{
  /* check all math within a model */

  unsigned int n;
  for (n = 0; n < m.getNumRules(); n++)
  {
    if (m.getRule(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getRule(n)->getMath()) == true)
        return true;
    }
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      if (m.getReaction(n)->getKineticLaw()->isSetMath())
      {
        if (mathHasCnUnits(m.getReaction(n)->getKineticLaw()->getMath()) == true)
          return true;
      }
    }
  }

  for (n = 0; n < m.getNumEvents(); n++)
  {
    if (m.getEvent(n)->isSetTrigger())
    {
      if (m.getEvent(n)->getTrigger()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getTrigger()->getMath()) == true)
          return true;
      }
    }
    if (m.getEvent(n)->isSetDelay())
    {
      if (m.getEvent(n)->getDelay()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getDelay()->getMath()) == true)
          return true;
      }
    }
    if (m.getEvent(n)->isSetPriority())
    {
      if (m.getEvent(n)->getPriority()->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getPriority()->getMath()) == true)
          return true;
      }
    }
    for (unsigned int ea = 0; ea < m.getEvent(n)->getNumEventAssignments(); ea++)
    {
      if (m.getEvent(n)->getEventAssignment(ea)->isSetMath())
      {
        if (mathHasCnUnits(m.getEvent(n)->getEventAssignment(ea)->getMath()) == true)
          return true;
      }
    }
  }

  for (n = 0; n < m.getNumInitialAssignments(); n++)
  {
    if (m.getInitialAssignment(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getInitialAssignment(n)->getMath()) == true)
        return true;
    }
  }

  for (n = 0; n < m.getNumConstraints(); n++)
  {
    if (m.getConstraint(n)->isSetMath())
    {
      if (mathHasCnUnits(m.getConstraint(n)->getMath()) == true)
        return true;
    }
  }

  return false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::matchesCnUnits(Model& m, std::string& units)
{
  /* check all math within a model */

  unsigned int n;
  for (n = 0; n < m.getNumRules(); n++)
  {
    if (m.getRule(n)->isSetMath())
    {
      if (mathMatchesCnUnits(m.getRule(n)->getMath(), units) == true)
        return true;
    }
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    if (m.getReaction(n)->isSetKineticLaw())
    {
      if (m.getReaction(n)->getKineticLaw()->isSetMath())
      {
        if (mathMatchesCnUnits(m.getReaction(n)->getKineticLaw()->getMath(), units) == true)
          return true;
      }
    }
  }

  for (n = 0; n < m.getNumEvents(); n++)
  {
    if (m.getEvent(n)->isSetTrigger())
    {
      if (m.getEvent(n)->getTrigger()->isSetMath())
      {
        if (mathMatchesCnUnits(m.getEvent(n)->getTrigger()->getMath(), units) == true)
          return true;
      }
    }
    if (m.getEvent(n)->isSetDelay())
    {
      if (m.getEvent(n)->getDelay()->isSetMath())
      {
        if (mathMatchesCnUnits(m.getEvent(n)->getDelay()->getMath(), units) == true)
          return true;
      }
    }
    if (m.getEvent(n)->isSetPriority())
    {
      if (m.getEvent(n)->getPriority()->isSetMath())
      {
        if (mathMatchesCnUnits(m.getEvent(n)->getPriority()->getMath(), units) == true)
          return true;
      }
    }
    for (unsigned int ea = 0; ea < m.getEvent(n)->getNumEventAssignments(); ea++)
    {
      if (m.getEvent(n)->getEventAssignment(ea)->isSetMath())
      {
        if (mathMatchesCnUnits(m.getEvent(n)->getEventAssignment(ea)->getMath(), units) == true)
          return true;
      }
    }
  }

  for (n = 0; n < m.getNumInitialAssignments(); n++)
  {
    if (m.getInitialAssignment(n)->isSetMath())
    {
      if (mathMatchesCnUnits(m.getInitialAssignment(n)->getMath(), units) == true)
        return true;
    }
  }

  for (n = 0; n < m.getNumConstraints(); n++)
  {
    if (m.getConstraint(n)->isSetMath())
    {
      if (mathMatchesCnUnits(m.getConstraint(n)->getMath(), units) == true)
        return true;
    }
  }

  return false;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::mathHasCnUnits(const ASTNode * ast)
{
  bool hasCnUnits = false;
  if (ast->isNumber() && ast->hasUnits() == true)
  {
     return true;
  }
  unsigned int n = 0; 
  while(n < ast->getNumChildren() && hasCnUnits == false)
  {
    hasCnUnits = mathHasCnUnits(ast->getChild(n));
    n++;
  }
  return hasCnUnits;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
SBMLUnitsConverter::mathMatchesCnUnits(const ASTNode * ast, std::string & units)
{
  bool hasCnUnits = false;
  if (ast->isNumber() && ast->hasUnits() == true)
  {
    if (ast->getUnits() == units)
      return true;
  }
  unsigned int n = 0; 
  while(n < ast->getNumChildren() && hasCnUnits == false)
  {
    hasCnUnits = mathMatchesCnUnits(ast->getChild(n), units);
    n++;
  }
  return hasCnUnits;
}
/** @endcond */


/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


