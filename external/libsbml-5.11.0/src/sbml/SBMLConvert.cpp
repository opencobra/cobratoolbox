/**
 * @file    SBMLConvert.cpp
 * @brief   Performs conversion between SBML levels
 * @author  Ben Bornstein and Sarah Keating
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

#include <sbml/util/List.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBase.h>
#include <sbml/Model.h>
#include <sbml/KineticLaw.h>
#include <sbml/Compartment.h>

#include <sbml/SpeciesReference.h>
#include <sbml/SimpleSpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>

#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/util/IdList.h>
#include <sbml/util/ElementFilter.h>

#include <sbml/math/FormulaParser.h>

LIBSBML_CPP_NAMESPACE_BEGIN
/** @cond doxygenLibsbmlInternal **/

static const char* ASSIGNED_COMPARTMENT = "AssignedName";

/* functions used in adjusting L3 -> L2 stoichiometryMath */

void createNoValueStoichMath(Model & m, SpeciesReference & sr, 
                             unsigned int idCount);
void createParameterAsRateRule(Model &m, SpeciesReference &sr, Rule &rr, 
                          unsigned int idCount);

void useStoichMath(Model & m, SpeciesReference &sr, bool isRule);

/* functions used in adjusting L1 -> L2 stoichiometryMath */

void dealWithL1Stoichiometry(Model & m, bool l2 = true);

void dealWithAssigningL1Stoichiometry(Model & m, bool l2 = true);

class UnitRefsFilter : public ElementFilter
{
public:
  UnitRefsFilter (): ElementFilter ()
  {
  };


	virtual bool filter(const SBase* element)
  {
	  // return in case we don't have a valid element
    if (element == NULL)
    {
        return false;
    }


    // otherwise we want to keep the element
    // if it has units
    int tc = element->getTypeCode();
    bool keep = false;
    switch (tc)
    {
      case SBML_COMPARTMENT: 
      case SBML_PARAMETER: 
      case SBML_LOCAL_PARAMETER:
      case SBML_CONSTRAINT:          
      case SBML_EVENT_ASSIGNMENT:    
      case SBML_FUNCTION_DEFINITION:
      case SBML_INITIAL_ASSIGNMENT:
      case SBML_KINETIC_LAW:
      case SBML_RULE:
      case SBML_TRIGGER:
      case SBML_DELAY:
      case SBML_STOICHIOMETRY_MATH:
      case SBML_PRIORITY:
      case SBML_SPECIES:
        keep = true;
        break;
    default:
      break;
    }

    return keep;			
  };

};

/*
 * Converts the model to a from SBML L1 to L2.  Most of the necessary
 * changes occur during the various writeAttributes() methods, however
 * there are some difference between L1 and L2 that require the underlying
 * Model to be changed.
 */
void 
Model::convertL1ToL2 ()
{
  addModifiers();

  addConstantAttribute();

  dealWithL1Stoichiometry(*this);
}

/* convert from L1 to L3 */
void 
Model::convertL1ToL3 ()
{
  addModifiers();

  addConstantAttribute();

  setSpatialDimensions();

  addDefinitionsForDefaultUnits();

  assignRequiredValues();

  dealWithL1Stoichiometry(*this, false);
}


/* convert from L2 to L3 */
void 
Model::convertL2ToL3 ()
{
  addDefinitionsForDefaultUnits();

  setSpeciesReferenceConstantValueAndStoichiometry();

  convertStoichiometryMath();

  assignRequiredValues();
}


/*
 * Converts the model to a from SBML L2 to L1.  Most of the necessary
 * changes occur during the various writeAttributes() methods, however
 * there are some difference between L1 and L2 that require the underlying
 * Model to be changed.
 */
void 
Model::convertL2ToL1 (bool strict)
{
  //
  // Level 2 allows a model to be specified without a Compartment.  However
  // this is not valid in Level 1.  Thus if a L2 model has no Compartment
  // one must be included 
  //
  if (getNumCompartments() == 0)
  {
    createCompartment()->setId(ASSIGNED_COMPARTMENT);

  }

  dealWithAssigningL1Stoichiometry(*this, true);
  /* make sure underlying model is correct */
  if (strict)
  {
    removeMetaId();
    removeSBOTerms(strict);
    removeHasOnlySubstanceUnits();
  }
}

/* convert from L1 to L3 */
void 
Model::convertL3ToL1 ()
{
  //
  // Level 3 allows a model to be specified without a Compartment.  However
  // this is not valid in Level 1.  Thus if a L3 model has no Compartment
  // one must be included 
  //
  if (getNumCompartments() == 0)
  {
    createCompartment()->setId(ASSIGNED_COMPARTMENT);

  }
  dealWithModelUnits();
  
  dealWithAssigningL1Stoichiometry(*this, false);
  for (unsigned int i = 0; i < getNumReactions(); i++)
  {
    Reaction *r = getReaction(i);
    if (r->isSetKineticLaw())
    {
      KineticLaw *kl = r->getKineticLaw();
      for (unsigned int j = 0; j < kl->getNumLocalParameters(); j++)
      {
        Parameter *lp = new Parameter(getLevel(), getVersion());
        (*lp) = *(kl->getLocalParameter(j));
        kl->addParameter(lp);
        delete kl->removeLocalParameter(j);
        delete lp;
      }
    }
  }
}


/* convert from L1 to L3 */
void 
Model::convertL3ToL2 (bool strict)
{
  dealWithModelUnits();

  dealWithStoichiometry();

  dealWithEvents(strict);

  for (unsigned int i = 0; i < getNumReactions(); i++)
  {
    Reaction *r = getReaction(i);
    if (r->isSetKineticLaw())
    {
      KineticLaw *kl = r->getKineticLaw();
      for (unsigned int j = 0; j < kl->getNumLocalParameters(); j++)
      {
        Parameter *lp = new Parameter(getLevel(), getVersion());
        (*lp) = *(kl->getLocalParameter(j));
        kl->addParameter(lp);
        delete kl->removeLocalParameter(j);
        delete lp;
      }
    }
  }
}


void
Model::setSpeciesReferenceConstantValueAndStoichiometry()
{
  for (unsigned int i = 0; i < getNumReactions(); i++)
  {
    Reaction *r = getReaction(i);
    unsigned int j;
    for (j = 0; j < r->getNumReactants(); j++)
    {
      if (!(r->getReactant(j)->isSetStoichiometryMath()))
      {
        r->getReactant(j)->setConstant(true);
        if (!(r->getReactant(j)->isSetStoichiometry()))
        {
          r->getReactant(j)->setStoichiometry(1);
        }
      }
      else
      {
        r->getReactant(j)->setConstant(false);
      }
    }
    for (j = 0; j < r->getNumProducts(); j++)
    {
      if (!(r->getProduct(j)->isSetStoichiometryMath()))
      {
        r->getProduct(j)->setConstant(true);
        if (!(r->getProduct(j)->isSetStoichiometry()))
        {
          r->getProduct(j)->setStoichiometry(1);
        }
      }
      else
      {
        r->getProduct(j)->setConstant(false);
      }
    }
  }
}
/* adds species referred to in a KineticLaw to the ListOfModifiers
 * this will only be applicable when up converting an L1 model
 */
void 
Model::addModifiers ()
{
  //
  // Level 2/3 has a listOfModifiers associated with a Reaction
  // which are not listed in a L1 Model.
  // For each symbol in the Reaction's KineticLaw,
  // that symbol is a modifier iff:
  //
  //   1. It is defined as a Species in the Model
  //   2. It is not a Reactant or Product in this Reaction.
  //
  // Thus modifiers must be added where appropriate.
  //
  const char *id;

  unsigned int size;
  unsigned int n, l;

  const ASTNode *node;
  List          *names;
  KineticLaw* kl;

  for (n = 0; n < getNumReactions(); n++)
  {
    kl = getReaction(n)->getKineticLaw();

    if (kl == NULL || kl->isSetMath() == false) continue;
   
    node  = kl->getMath();
    names = node->getListOfNodes((ASTNodePredicate) ASTNode_isName);
    size  = names->getSize();

    for (l = 0; l < size; l++)
    {
      node = (ASTNode *) names->get(l);
      id   = node->getName();

      // 1. It is an AST_NAME (not AST_NAME_TIME), and
      if (node->getType() != AST_NAME) continue;

      // 2. It refers to a Species in this Model, and
      if (id == NULL || getSpecies(id) == NULL) continue;

      // 3. It is not a Reactant, Product, or (already) a Modifier
      if (getReaction(n)->getReactant(id) != NULL) continue;
      if (getReaction(n)->getProduct (id) != NULL) continue;
      if (getReaction(n)->getModifier(id) != NULL) continue;

      getReaction(n)->createModifier()->setSpecies(id);
    }

    delete names;
  }
}


/* declares constant = false for any L1 compartment/parameter
 * assigned by a rule
 */
void
Model::addConstantAttribute()
{
  unsigned int n;
  // parameters and compartments are declared to have constant=true
  // by default. Since in L1 the constant attribute didnt exist 
  // parameters/compartments that are the subjcet of rules must have
  // the value changed

  for ( n = 0; n < getNumParameters(); n++)
  {
    if (getRule(getParameter(n)->getId()) != NULL)
    {
      getParameter(n)->setConstant(false);
    }
  }

  for ( n = 0; n < getNumCompartments(); n++)
  {
    if (getRule(getCompartment(n)->getId()) != NULL)
    {
      getCompartment(n)->setConstant(false);
    }
  }
}


/* in L1 spatialDimensions did not exist as an attribute
 * but was considered to be '3'
 * L3 does not require the attribute and will
 * only record it is officially set
 */
void
Model::setSpatialDimensions(double dims)
{
  for (unsigned int n = 0; n < getNumCompartments(); n++)
  {
    getCompartment(n)->setSpatialDimensions(dims);
  }
}

/* in L1 and L2 there were built in values for key units
 * such as 'volume', 'length', 'area', 'substance' and 'time'
 * In L3 these have been removed - thus if a model uses one of these
 * it needs a unitDefinition to define it
 */
void
Model::addDefinitionsForDefaultUnits()
{
  /* create a list of unit values */
  IdList unitsUsed;
  unsigned int n;
  bool implicitVolume = false;
  bool implicitLength = false;
  bool implicitSubstance = false;

  for (n = 0; n < getNumCompartments(); n++)
  {
    if (getCompartment(n)->isSetUnits())
    {
      unitsUsed.append(getCompartment(n)->getUnits());
    }
    else
    {
      if (getCompartment(n)->getSpatialDimensions() == 3)
      {
        implicitVolume = true;
        getCompartment(n)->setUnits("volume");
      }
      else if (getCompartment(n)->getSpatialDimensions() == 2)
      {
        getCompartment(n)->setUnits("area");
      }
      else if (getCompartment(n)->getSpatialDimensions() == 1)
      {
        implicitLength = true;
        getCompartment(n)->setUnits("length");
      }
    }
  }

  for (n = 0; n < getNumSpecies(); n++)
  {
    if (getSpecies(n)->isSetSubstanceUnits())
    {
      unitsUsed.append(getSpecies(n)->getSubstanceUnits());
    }
    else
    {
      implicitSubstance = true;
      getSpecies(n)->setSubstanceUnits("substance");
    }
 
    if (getSpecies(n)->isSetSpatialSizeUnits())
      unitsUsed.append(getSpecies(n)->getSpatialSizeUnits());
  }

  for (n = 0; n < getNumParameters(); n++)
  {
    if (getParameter(n)->isSetUnits())
      unitsUsed.append(getParameter(n)->getUnits());
  }

  if (getUnitDefinition("volume") == NULL)
  {
    if (unitsUsed.contains("volume") || implicitVolume)
    {
      UnitDefinition * ud = createUnitDefinition();
      ud->setId("volume");
      Unit * u = ud->createUnit();
      u->setKind(UnitKind_forName("litre"));
      u->setScale(0);
      u->setExponent(1.0);
      u->setMultiplier(1.0);
      setVolumeUnits("volume");
    }
    else
    {
      setVolumeUnits("litre");
    }
  }
  else
  {
    setVolumeUnits("volume");
  }


  if (getUnitDefinition("substance") == NULL)
  {
    if (unitsUsed.contains("substance") || implicitSubstance)
    {
      UnitDefinition * ud = createUnitDefinition();
      ud->setId("substance");
      Unit * u = ud->createUnit();
      u->setKind(UnitKind_forName("mole"));
      u->setScale(0);
      u->setExponent(1.0);
      u->setMultiplier(1.0);
      setSubstanceUnits("substance");
      setExtentUnits("substance");
    }
    else
    {
      setSubstanceUnits("mole");
      setExtentUnits("mole");
    }
  }
  else
  {
    setSubstanceUnits("substance");
    setExtentUnits("substance");
  }

  if (getUnitDefinition("area") == NULL)
  {
    UnitDefinition * ud = createUnitDefinition();
    ud->setId("area");
    Unit * u = ud->createUnit();
    u->setKind(UnitKind_forName("metre"));
    u->setScale(0);
    u->setExponent(2.0);
    u->setMultiplier(1.0);
    setAreaUnits("area");
  }
  else
  {
    setAreaUnits("area");
  }

  if (getUnitDefinition("length") == NULL)
  {
    if (unitsUsed.contains("length") || implicitLength)
    {
      UnitDefinition * ud = createUnitDefinition();
      ud->setId("length");
      Unit * u = ud->createUnit();
      u->setKind(UnitKind_forName("metre"));
      u->setScale(0);
      u->setExponent(1.0);
      u->setMultiplier(1.0);
      setLengthUnits("length");
    }
    else
    {
      setLengthUnits("metre");
    }
  }
  else
  {
    setLengthUnits("length");
  }

  if (getUnitDefinition("time") == NULL)
  {
    setTimeUnits("second");
  }
  else
  {
    setTimeUnits("time");
  }

}

void
Model::convertParametersToLocals(unsigned int level, unsigned int version)
{
  for (unsigned int i = 0; i < getNumReactions(); i++)
  {
    Reaction *r = getReaction(i);
    if (r->isSetKineticLaw())
    {
      KineticLaw *kl = r->getKineticLaw();
      for (unsigned int j = 0; j < kl->getNumParameters(); j++)
      {
        LocalParameter *lp = new LocalParameter(level, version);
        (*lp) = *(kl->getParameter(j));
        kl->getListOfLocalParameters()->appendAndOwn(lp);
//        kl->addLocalParameter(lp);
      }
    }
  }
}
/* the new strict setters mean that for a conversion to L2 to
 * take place the model needs to think it still l1 for
 * some actions and think it is already L2 for others
 */
void 
Model::removeParameterRuleUnits (bool strict)
{
  if (strict == true)
  {
    /* in L1 a parameterRule coulkd specify units
     * for a strict conversion this attribute should be unset
     */
    for (unsigned int n = 0; n < getNumParameters(); n++)
    {
      if (getRule(getParameter(n)->getId()) != NULL)
      {
        getRule(getParameter(n)->getId())->unsetUnits();
      }
    }
  }
}

/* converting to l1 any metaid attributes should be removed */
void
Model::removeMetaId()
{
  unsigned int n, i;

  unsetMetaId();
  
  for (n = 0; n < getNumUnitDefinitions(); n++)
  {
    getUnitDefinition(n)->unsetMetaId();
    for (i = 0; i < getUnitDefinition(n)->getNumUnits(); i++)
    {
      getUnitDefinition(n)->getUnit(i)->unsetMetaId();
    }
  }

  for (n = 0; n < getNumCompartments(); n++)
  {
    getCompartment(n)->unsetMetaId();
  }

  for (n = 0; n < getNumSpecies(); n++)
  {
    getSpecies(n)->unsetMetaId();
  }

  for (n = 0; n < getNumParameters(); n++)
  {
    getParameter(n)->unsetMetaId();
  }

  for (n = 0; n < getNumRules(); n++)
  {
    getRule(n)->unsetMetaId();
  }

  for (n = 0; n < getNumReactions(); n++)
  {
    getReaction(n)->unsetMetaId();
    for (i = 0; i < getReaction(n)->getNumReactants(); i++)
    {
      getReaction(n)->getReactant(i)->unsetMetaId();
    }
    for (i = 0; i < getReaction(n)->getNumProducts(); i++)
    {
      getReaction(n)->getProduct(i)->unsetMetaId();
    }
    if (getReaction(n)->isSetKineticLaw())
    {
      getReaction(n)->getKineticLaw()->unsetMetaId();
    }
  }
}


/* converting to l1 or l2v1 any sboTerm attributes should be removed */

void
Model::removeSBOTerms(bool strict)
{
  unsigned int n, i;

  if (strict == true)
  {
    unsetSBOTerm();
    
    for (n = 0; n < getNumUnitDefinitions(); n++)
    {
      getUnitDefinition(n)->unsetSBOTerm();
      for (i = 0; i < getUnitDefinition(n)->getNumUnits(); i++)
      {
        getUnitDefinition(n)->getUnit(i)->unsetSBOTerm();
      }
    }

    for (n = 0; n < getNumCompartments(); n++)
    {
      getCompartment(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumSpecies(); n++)
    {
      getSpecies(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumParameters(); n++)
    {
      getParameter(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumRules(); n++)
    {
      getRule(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumReactions(); n++)
    {
      getReaction(n)->unsetSBOTerm();
      for (i = 0; i < getReaction(n)->getNumReactants(); i++)
      {
        getReaction(n)->getReactant(i)->unsetSBOTerm();
        if (getReaction(n)->getReactant(i)->isSetStoichiometryMath())
        {
          getReaction(n)->getReactant(i)->getStoichiometryMath()->unsetSBOTerm();
        }
      }
      for (i = 0; i < getReaction(n)->getNumProducts(); i++)
      {
        getReaction(n)->getProduct(i)->unsetSBOTerm();
        if (getReaction(n)->getProduct(i)->isSetStoichiometryMath())
        {
          getReaction(n)->getProduct(i)->getStoichiometryMath()->unsetSBOTerm();
        }
      }
      for (i = 0; i < getReaction(n)->getNumModifiers(); i++)
      {
        getReaction(n)->getModifier(i)->unsetSBOTerm();
      }
      if (getReaction(n)->isSetKineticLaw())
      {
        getReaction(n)->getKineticLaw()->unsetSBOTerm();
      }
    }

    for (n = 0; n < getNumFunctionDefinitions(); n++)
    {
      getFunctionDefinition(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumEvents(); n++)
    {
      getEvent(n)->unsetSBOTerm();
      for (i = 0; i < getEvent(n)->getNumEventAssignments(); i++)
      {
        getEvent(n)->getEventAssignment(i)->unsetSBOTerm();
      }
      if (getEvent(n)->isSetTrigger())
      {
        getEvent(n)->getTrigger()->unsetSBOTerm();
      }
      if (getEvent(n)->isSetDelay())
      {
        getEvent(n)->getDelay()->unsetSBOTerm();
      }
    }
  }
}

/* converting to l1 any hasOnlySubstanceUnits attributes should be removed */
void
Model::removeHasOnlySubstanceUnits()
{
  for (unsigned int i = 0; i < getNumSpecies(); i++)
  {
    getSpecies(i)->setHasOnlySubstanceUnits(false);
  }
}

/* converting to l2v2 some sboTerm attributes should be removed */

void
Model::removeSBOTermsNotInL2V2(bool strict)
{
  unsigned int n, i;

  if (strict == true)
  {
    for (n = 0; n < getNumUnitDefinitions(); n++)
    {
      getUnitDefinition(n)->unsetSBOTerm();
      for (i = 0; i < getUnitDefinition(n)->getNumUnits(); i++)
      {
        getUnitDefinition(n)->getUnit(i)->unsetSBOTerm();
      }
    }

    for (n = 0; n < getNumCompartments(); n++)
    {
      getCompartment(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumSpecies(); n++)
    {
      getSpecies(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumCompartmentTypes(); n++)
    {
      getCompartmentType(n)->unsetSBOTerm();
    }

    for (n = 0; n < getNumSpeciesTypes(); n++)
    {
      getSpeciesType(n)->unsetSBOTerm();
    }


    for (n = 0; n < getNumReactions(); n++)
    {
      for (i = 0; i < getReaction(n)->getNumReactants(); i++)
      {
        if (getReaction(n)->getReactant(i)->isSetStoichiometryMath())
        {
          getReaction(n)->getReactant(i)->getStoichiometryMath()->unsetSBOTerm();
        }
      }
      for (i = 0; i < getReaction(n)->getNumProducts(); i++)
      {
        if (getReaction(n)->getProduct(i)->isSetStoichiometryMath())
        {
          getReaction(n)->getProduct(i)->getStoichiometryMath()->unsetSBOTerm();
        }
      }
    }

    for (n = 0; n < getNumEvents(); n++)
    {
      if (getEvent(n)->isSetTrigger())
      {
        getEvent(n)->getTrigger()->unsetSBOTerm();
      }
      if (getEvent(n)->isSetDelay())
      {
        getEvent(n)->getDelay()->unsetSBOTerm();
      }
    }
  }
}

void
Model::convertStoichiometryMath()
{
  unsigned int n, j;
  Reaction * r;
  SpeciesReference *sr;
  unsigned int idCount = 0;
  char newid[15];
  std::string id;

  for (n = 0; n < getNumReactions(); n++)
  {
    r = getReaction(n);
    for (j = 0; j < r->getNumReactants(); j++)
    {
      sr = r->getReactant(j);
      if (sr->isSetStoichiometryMath())
      {
        if (!sr->isSetId())
        {
          sprintf(newid, "generatedId_%u", idCount);
          id.assign(newid);
          sr->setId(id);
          idCount++;
        }
        else
        {
          id = sr->getId();
        }
        sr->setConstant(false);

        AssignmentRule * ar = createAssignmentRule();
        ar->setVariable(id);
        if (sr->getStoichiometryMath()->isSetMath())
        {
          ar->setMath(sr->getStoichiometryMath()->getMath());
        }
      }
    }
    for (j = 0; j < r->getNumProducts(); j++)
    {
      sr = r->getProduct(j);
      if (sr->isSetStoichiometryMath())
      {
        if (!sr->isSetId())
        {
          sprintf(newid, "generatedId_%u", idCount);
          id.assign(newid);
          sr->setId(id);
          idCount++;
        }
        else
        {
          id = sr->getId();
        }

        sr->setConstant(false);
        AssignmentRule * ar = createAssignmentRule();
        ar->setVariable(id);
        if (sr->getStoichiometryMath()->isSetMath())
        {
          ar->setMath(sr->getStoichiometryMath()->getMath());
        }
      }
    }
  }
}

void
Model::removeDuplicateTopLevelAnnotations()
{
  unsigned int i, n;
  this->removeDuplicateAnnotations();

  if (getNumFunctionDefinitions() > 0)
  {
    getListOfFunctionDefinitions()->removeDuplicateAnnotations();
    for (i = 0; i < getNumFunctionDefinitions(); i++)
    {
      getFunctionDefinition(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumUnitDefinitions() > 0)
  {
    getListOfUnitDefinitions()->removeDuplicateAnnotations();
    for (i = 0; i < getNumUnitDefinitions(); i++)
    {
      getUnitDefinition(i)->removeDuplicateAnnotations();
      getUnitDefinition(i)->getListOfUnits()->removeDuplicateAnnotations();
      for (n = 0; n < getUnitDefinition(i)->getNumUnits(); n++)
      {
        getUnitDefinition(i)->getUnit(n)->removeDuplicateAnnotations();
      }
    }
  }
  if (getNumCompartmentTypes() > 0)
  {
    getListOfCompartmentTypes()->removeDuplicateAnnotations();
    for (i = 0; i < getNumCompartmentTypes(); i++)
    {
      getCompartmentType(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumSpeciesTypes() > 0)
  {
    getListOfSpeciesTypes()->removeDuplicateAnnotations();
    for (i = 0; i < getNumSpeciesTypes(); i++)
    {
      getSpeciesType(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumCompartments() > 0)
  {
    getListOfCompartments()->removeDuplicateAnnotations();
    for (i = 0; i < getNumCompartments(); i++)
    {
      getCompartment(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumSpecies() > 0)
  {
    getListOfSpecies()->removeDuplicateAnnotations();
    for (i = 0; i < getNumSpecies(); i++)
    {
      getSpecies(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumParameters() > 0)
  {
    getListOfParameters()->removeDuplicateAnnotations();
    for (i = 0; i < getNumParameters(); i++)
    {
      getParameter(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumInitialAssignments() > 0)
  {
    getListOfInitialAssignments()->removeDuplicateAnnotations();
    for (i = 0; i < getNumInitialAssignments(); i++)
    {
      getInitialAssignment(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumConstraints() > 0)
  {
    getListOfConstraints()->removeDuplicateAnnotations();
    for (i = 0; i < getNumConstraints(); i++)
    {
      getConstraint(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumRules() > 0)
  {
    getListOfRules()->removeDuplicateAnnotations();
    for (i = 0; i < getNumRules(); i++)
    {
      getRule(i)->removeDuplicateAnnotations();
    }
  }
  if (getNumReactions() > 0)
  {
    getListOfReactions()->removeDuplicateAnnotations();
    for (i = 0; i < getNumReactions(); i++)
    {
      Reaction * r = getReaction(i);
      r->removeDuplicateAnnotations();
      if (r->getNumReactants() > 0)
      {
        r->getListOfReactants()->removeDuplicateAnnotations();
        for (n = 0; n < r->getNumReactants(); n++)
        {
          r->getReactant(n)->removeDuplicateAnnotations();
        }
      }
      if (r->getNumProducts() > 0)
      {
        r->getListOfProducts()->removeDuplicateAnnotations();
        for (n = 0; n < r->getNumProducts(); n++)
        {
          r->getProduct(n)->removeDuplicateAnnotations();
        }
      }
      if (r->getNumModifiers() > 0)
      {
        r->getListOfModifiers()->removeDuplicateAnnotations();
        for (n = 0; n < r->getNumModifiers(); n++)
        {
          r->getModifier(n)->removeDuplicateAnnotations();
        }
      }
      if (r->isSetKineticLaw())
      {
        r->getKineticLaw()->removeDuplicateAnnotations();
        if (r->getKineticLaw()->getNumParameters() > 0)
        {
          r->getKineticLaw()->getListOfParameters()
                            ->removeDuplicateAnnotations();
          for (n = 0; n < r->getKineticLaw()->getNumParameters(); n++)
          {
            r->getKineticLaw()->getParameter(n)->removeDuplicateAnnotations();
          }
        }
      }
    }
  }
  if (getNumEvents() > 0)
  {
    getListOfEvents()->removeDuplicateAnnotations();
    for (i = 0; i < getNumEvents(); i++)
    {
      getEvent(i)->removeDuplicateAnnotations();
      if (getEvent(i)->getNumEventAssignments() > 0)
      {
        getEvent(i)->getListOfEventAssignments()->removeDuplicateAnnotations();
        for (n = 0; n < getEvent(i)->getNumEventAssignments(); n++)
        {
          getEvent(i)->getEventAssignment(n)->removeDuplicateAnnotations();
        }
      }
    }
  }
}

void
Model::assignRequiredValues()
{
  // when converting to L3 some attributes which have default values in L1/L2
  // but are required in L3 are not present or set
  unsigned int i, n;

  if (getNumUnitDefinitions() > 0)
  {
    for (i = 0; i < getNumUnitDefinitions(); i++)
    {
      for (n = 0; n < getUnitDefinition(i)->getNumUnits(); n++)
      {
        Unit *u = getUnitDefinition(i)->getUnit(n);
        if (!u->isSetExponent())
          u->setExponent(1.0);
        if (!u->isSetScale())
          u->setScale(0);
        if (!u->isSetMultiplier())
          u->setMultiplier(1.0);
      }
    }
  }
  
  if (getNumCompartments() > 0)
  {
    for (i = 0; i < getNumCompartments(); i++)
    {
      Compartment *c = getCompartment(i);
      c->setConstant(c->getConstant());
    }
  }
  if (getNumSpecies() > 0)
  {
    for (i = 0; i < getNumSpecies(); i++)
    {
      Species * s = getSpecies(i);
      s->setBoundaryCondition(s->getBoundaryCondition());
      s->setHasOnlySubstanceUnits(s->getHasOnlySubstanceUnits());
      s->setConstant(s->getConstant());
    }
  }
  if (getNumParameters() > 0)
  {
    for (i = 0; i < getNumParameters(); i++)
    {
      Parameter * p = getParameter(i);
      p->setConstant(p->getConstant());
    }
  }
  if (getNumReactions() > 0)
  {
    for (i = 0; i < getNumReactions(); i++)
    {
      Reaction * r = getReaction(i);
      r->setFast(r->getFast());
      r->setReversible(r->getReversible());
      if (r->getNumReactants() > 0)
      {
        for (n = 0; n < r->getNumReactants(); n++)
        {
          SpeciesReference *sr = r->getReactant(n);
          if (sr->isSetStoichiometryMath())
          {
            sr->setConstant(false);
          }
          else
          {
            sr->setConstant(true);
          }
        }
      }
      if (r->getNumProducts() > 0)
      {
        for (n = 0; n < r->getNumProducts(); n++)
        {
          SpeciesReference *sr = r->getProduct(n);
          if (sr->isSetStoichiometryMath())
          {
            sr->setConstant(false);
          }
          else
          {
            sr->setConstant(true);
          }
        }
      }
    }
  }
  if (getNumEvents() > 0)
  {
    for (i = 0; i < getNumEvents(); i++)
    {
      Event * e = getEvent(i);
      e->setUseValuesFromTriggerTime(e->getUseValuesFromTriggerTime());

      if (e->isSetTrigger())
      {
        Trigger *t = e->getTrigger();
        t->setPersistent(true);
        t->setInitialValue(true);
      }
    }
  }

}

void
Model::dealWithEvents(bool strict)
{
  // if strict conversion want to unset L3 prioirty
  if (strict == true)
  {
    if (getNumEvents() > 0)
    {
      for (unsigned int i = 0; i < getNumEvents(); i++)
      {
        Event * e = getEvent(i);
        e->unsetPriority();
      }
    }
  }
}

void
Model::dealWithModelUnits()
{
  UnitRefsFilter filter;
  List * elements = getAllElements(&filter);
  unsigned int n = 0;
  unsigned int num = elements->getSize();
  
  if (isSetVolumeUnits())
  {
    std::string volume = getVolumeUnits();
    // if in an L3 model a user used volume as an id of a UnitDefinition
    // but they declared the volume units of the model to be something 
    // else then the UD with id volume is nothing to do with the 
    // L2 interpretation of volume
    // so replace that UD and all references to it 
    if (volume != "volume")
    {
      UnitDefinition * existingUD = removeUnitDefinition("volume");
      if (existingUD != NULL)
      {
        std::string newSubsName = "volumeFromOriginal";
        existingUD->setId(newSubsName);
        SBase* obj;
        for (n = 0; n < num; n++)
        {
          obj = (SBase*)(elements->get(n));
          obj->renameUnitSIdRefs("volume", newSubsName);
        }
        addUnitDefinition(existingUD);
        delete existingUD;
      }
    }
    UnitDefinition * ud = getUnitDefinition(volume) != NULL ? 
                          getUnitDefinition(volume)->clone() : NULL;
    if (ud != NULL)
    {
      ud->setId("volume");
    }
    else
    {
      ud = new UnitDefinition(getSBMLNamespaces());
      ud->setId("volume");
      Unit *u = ud->createUnit();
      u->initDefaults();
      u->setKind(UnitKind_forName(volume.c_str()));
    }
    addUnitDefinition(ud);
    delete ud;
  }
  if (isSetAreaUnits())
  {
    std::string area = getAreaUnits();
    // if in an L3 model a user used area as an id of a UnitDefinition
    // but they declared the area units of the model to be something 
    // else then the UD with id area is nothing to do with the 
    // L2 interpretation of area
    // so replace that UD and all references to it 
    if (area != "area")
    {
      UnitDefinition * existingUD = removeUnitDefinition("area");
      if (existingUD != NULL)
      {
        std::string newSubsName = "areaFromOriginal";
        existingUD->setId(newSubsName);
        SBase* obj;
        for (n = 0; n < num; n++)
        {
          obj = (SBase*)(elements->get(n));
          obj->renameUnitSIdRefs("area", newSubsName);
        }
        addUnitDefinition(existingUD);
        delete existingUD;
      }
    }
    UnitDefinition * ud = getUnitDefinition(area) != NULL ? 
                          getUnitDefinition(area)->clone() : NULL;
    if (ud != NULL)
    {
      ud->setId("area");
    }
    else
    {
      ud = new UnitDefinition(getSBMLNamespaces());
      ud->setId("area");
      Unit *u = ud->createUnit();
      u->initDefaults();
      u->setKind(UnitKind_forName(area.c_str()));
    }
    addUnitDefinition(ud);
    delete ud;
  }
  if (isSetLengthUnits())
  {
    std::string length = getLengthUnits();
    // if in an L3 model a user used length as an id of a UnitDefinition
    // but they declared the length units of the model to be something 
    // else then the UD with id length is nothing to do with the 
    // L2 interpretation of length
    // so replace that UD and all references to it 
    if (length != "length")
    {
      UnitDefinition * existingUD = removeUnitDefinition("length");
      if (existingUD != NULL)
      {
        std::string newSubsName = "lengthFromOriginal";
        existingUD->setId(newSubsName);
        SBase* obj;
        for (n = 0; n < num; n++)
        {
          obj = (SBase*)(elements->get(n));
          obj->renameUnitSIdRefs("length", newSubsName);
        }
        addUnitDefinition(existingUD);
        delete existingUD;
      }
    }
    UnitDefinition * ud = getUnitDefinition(length) != NULL ? 
                          getUnitDefinition(length)->clone() : NULL;
    if (ud != NULL)
    {
      ud->setId("length");
    }
    else
    {
      ud = new UnitDefinition(getSBMLNamespaces());
      ud->setId("length");
      Unit *u = ud->createUnit();
      u->initDefaults();
      u->setKind(UnitKind_forName(length.c_str()));
    }
    addUnitDefinition(ud);
    delete ud;
  }
  if (isSetSubstanceUnits())
  {
    std::string substance = getSubstanceUnits();
    // if in an L3 model a user used substance as an id of a UnitDefinition
    // but they declared the substance units of the model to be something 
    // else then the UD with id substance is nothing to do with the 
    // L2 interpretation of substance
    // so replace that UD and all references to it 
    if (substance != "substance")
    {
      UnitDefinition * existingUD = removeUnitDefinition("substance");
      if (existingUD != NULL)
      {
        std::string newSubsName = "substanceFromOriginal";
        existingUD->setId(newSubsName);
        SBase* obj;
        for (n = 0; n < num; n++)
        {
          obj = (SBase*)(elements->get(n));
          obj->renameUnitSIdRefs("substance", newSubsName);
        }
        addUnitDefinition(existingUD);
        delete existingUD;
      }
    }
    UnitDefinition * ud = getUnitDefinition(substance) != NULL ? 
                          getUnitDefinition(substance)->clone() : NULL;
    if (ud != NULL)
    {
      ud->setId("substance");
    }
    else
    {
      ud = new UnitDefinition(getSBMLNamespaces());
      ud->setId("substance");
      Unit *u = ud->createUnit();
      u->initDefaults();
      u->setKind(UnitKind_forName(substance.c_str()));
    }
    addUnitDefinition(ud);
    delete ud;
  }
  if (isSetTimeUnits())
  {
    std::string time = getTimeUnits();
    // if in an L3 model a user used time as an id of a UnitDefinition
    // but they declared the time units of the model to be something 
    // else then the UD with id time is nothing to do with the 
    // L2 interpretation of time
    // so replace that UD and all references to it 
    if (time != "time")
    {
      UnitDefinition * existingUD = removeUnitDefinition("time");
      if (existingUD != NULL)
      {
        std::string newSubsName = "timeFromOriginal";
        existingUD->setId(newSubsName);
        SBase* obj;
        for (n = 0; n < num; n++)
        {
          obj = (SBase*)(elements->get(n));
          obj->renameUnitSIdRefs("time", newSubsName);
        }
        addUnitDefinition(existingUD);
        delete existingUD;
      }
    }
    UnitDefinition * ud = getUnitDefinition(time) != NULL ? 
                          getUnitDefinition(time)->clone() : NULL;
    if (ud == NULL)
    {
      ud = new UnitDefinition(getSBMLNamespaces());
      Unit *u = ud->createUnit();
      u->initDefaults();
      u->setKind(UnitKind_forName(time.c_str()));
    }
    ud->setId("time");
    addUnitDefinition(ud);
    delete ud;
  }

  delete elements;
}

void
Model::dealWithStoichiometry()
{
  unsigned int idCount = 0;
  for (unsigned int i = 0; i < getNumReactions(); i++)
  {
    Reaction *r = getReaction(i);
    unsigned int j;

    for (j = 0; j < r->getNumReactants(); j++)
    {
      SpeciesReference *sr = r->getReactant(j);
      if (sr->isSetStoichiometry() == false)
      {
        if (sr->isSetId() == false)
        {
          createNoValueStoichMath(*this, *sr, idCount);
          idCount++;
        }
        else
        {
          // id is set it could be used by initialAssignment
          // used by rule
          // not used
          if (getInitialAssignment(sr->getId()) != NULL)
          {
            useStoichMath(*this, *sr, false);
          }
          else if (getRule(sr->getId()) != NULL)
          {
            //assignmentRule
            if (getRule(sr->getId())->getTypeCode() == SBML_ASSIGNMENT_RULE)
            {  
              useStoichMath(*this, *sr, true);
            }
            else if (getRule(sr->getId())->getTypeCode() == SBML_RATE_RULE)
            {
              createParameterAsRateRule(*this, *sr, *(getRule(sr->getId())), idCount);
              idCount++;
            }
          }
          else
          {
            createNoValueStoichMath(*this, *sr, idCount);
            idCount++;
          }
        }
      }
      else
      {
        // stoichiometry is set
        if (sr->isSetId())
        {
          // id is set it could be used by initialAssignment
          // used by rule
          // not used
          if (getInitialAssignment(sr->getId()) != NULL)
          {
            useStoichMath(*this, *sr, false);
          }
          else if (getRule(sr->getId()) != NULL)
          {
            //assignmentRule
            if (getRule(sr->getId())->getTypeCode() == SBML_ASSIGNMENT_RULE)
            {            
              useStoichMath(*this, *sr, true);
            }
            else if (getRule(sr->getId())->getTypeCode() == SBML_RATE_RULE)
            {
              createParameterAsRateRule(*this, *sr, *(getRule(sr->getId())), idCount);
              idCount++;
            }
          }
        }
        // no id set - do not need to do anything
      }
    }
    for (j = 0; j < r->getNumProducts(); j++)
    {
      SpeciesReference *sr = r->getProduct(j);
      if (sr->isSetStoichiometry() == false)
      {
        if (sr->isSetId() == false)
        {
          createNoValueStoichMath(*this, *sr, idCount);
          idCount++;
        }
        else
        {
          // id is set it could be used by initialAssignment
          // used by rule
          // not used
          if (getInitialAssignment(sr->getId()) != NULL)
          {
            useStoichMath(*this, *sr, false);
          }
          else if (getRule(sr->getId()) != NULL)
          {
            //assignmentRule
            if (getRule(sr->getId())->getTypeCode() == SBML_ASSIGNMENT_RULE)
            {  
              useStoichMath(*this, *sr, true);
            }
            else if (getRule(sr->getId())->getTypeCode() == SBML_RATE_RULE)
            {
              createParameterAsRateRule(*this, *sr, *(getRule(sr->getId())), idCount);
              idCount++;
            }
          }
          else
          {
            createNoValueStoichMath(*this, *sr, idCount);
            idCount++;
          }
        }
      }
      else
      {
        // stoichiometry is set
        if (sr->isSetId())
        {
          // id is set it could be used by initialAssignment
          // used by rule
          // not used
          if (getInitialAssignment(sr->getId()) != NULL)
          {
            useStoichMath(*this, *sr, false);
          }
          else if (getRule(sr->getId()) != NULL)
          {
            //assignmentRule
            if (getRule(sr->getId())->getTypeCode() == SBML_ASSIGNMENT_RULE)
            {            
              useStoichMath(*this, *sr, true);
            }
            else if (getRule(sr->getId())->getTypeCode() == SBML_RATE_RULE)
            {
              createParameterAsRateRule(*this, *sr, *(getRule(sr->getId())), idCount);
              idCount++;
            }
          }
        }
        // no id set - do not need to do anything
      }
    }
  }
}

void
createNoValueStoichMath(Model & m, SpeciesReference & sr, unsigned int idCount)
{
  char newid[15];
  std::string id;

  // no stoichiometry and no id to set the stoichiometry
  // replace with stoichiometryMath using a parameter with no value

  sprintf(newid, "parameterId_%u", idCount);
  id.assign(newid);

  Parameter *p = m.createParameter();
  p->setId(id);
  p->setConstant(false);

  StoichiometryMath *sm = sr.createStoichiometryMath();
  if (sm != NULL)
  {
    ASTNode *ast = SBML_parseFormula(id.c_str());
    sm->setMath(ast);
    delete ast;
  }
}


void
createParameterAsRateRule(Model &m, SpeciesReference &sr, Rule &rr, 
                          unsigned int idCount)
{
  char newid[15];
  std::string id;

  // create parameter as variable of rate rule 
  // and use stoichiometryMath to point to this
  sprintf(newid, "parameterId_%u", idCount);
  id.assign(newid);

  Parameter *p = m.createParameter();
  p->setId(id);
  p->setConstant(false);

  rr.setVariable(id);
  
  StoichiometryMath *sm = sr.createStoichiometryMath();
  if (sm != NULL)
  {
    ASTNode *ast = SBML_parseFormula(id.c_str());
    sm->setMath(ast);
    delete ast;
  }
}

void
useStoichMath(Model & m, SpeciesReference &sr, bool isRule)
{
  // use stoichiometryMath instead
  StoichiometryMath *sm = sr.createStoichiometryMath();
  if (sm != NULL)
  {
    if (isRule == true)
    {
      sm->setMath(m.getRule(sr.getId())->getMath());
      delete m.removeRule(sr.getId());
    }
    else
    {
      sm->setMath(m.getInitialAssignment(sr.getId())->getMath());
      delete m.removeInitialAssignment(sr.getId());
    }
  }
}

void dealWithL1Stoichiometry(Model & m, bool l2)
{
  unsigned int idCount = 0;
  char newid[15];
  std::string id;

  for (unsigned int i = 0; i < m.getNumReactions(); i++)
  {
    Reaction *r = m.getReaction(i);
    unsigned int j;

    for (j = 0; j < r->getNumReactants(); j++)
    {
      SpeciesReference *sr = r->getReactant(j);
      if (sr->getDenominator() != 1)
      {
        long stoich = static_cast<long>(sr->getStoichiometry());
        int denom = sr->getDenominator();
        ASTNode node;
        node.setValue(stoich, denom);   
        if (l2 == true)
        {
          StoichiometryMath * sm = sr->createStoichiometryMath();
          sm->setMath(&node);
        }
        else
        {
          sprintf(newid, "speciesRefId_%u", idCount);
          id.assign(newid);
          idCount++;
          sr->setId(id);
          InitialAssignment * ar = m.createInitialAssignment();
          ar->setSymbol(id);
          ar->setMath(&node);
          sr->unsetStoichiometry();
        }
      }
    }
    for (j = 0; j < r->getNumProducts(); j++)
    {
      SpeciesReference *sr = r->getProduct(j);
      if (sr->getDenominator() != 1)
      {
        long stoich = static_cast<long>(sr->getStoichiometry());
        int denom = sr->getDenominator();
        ASTNode node;
        node.setValue(stoich, denom);   
        if (l2 == true)
        {
          StoichiometryMath * sm = sr->createStoichiometryMath();
          sm->setMath(&node);
        }
        else
        {
          sprintf(newid, "speciesRefId_%u", idCount);
          id.assign(newid);
          idCount++;
          sr->setId(id);
          InitialAssignment * ar = m.createInitialAssignment();
          ar->setSymbol(id);
          ar->setMath(&node);
          sr->unsetStoichiometry();
        }
      }
    }
  }
}

void dealWithAssigningL1Stoichiometry(Model & m, bool l2)
{
  //char newid[15];
  std::string id;

  for (unsigned int i = 0; i < m.getNumReactions(); i++)
  {
    Reaction *r = m.getReaction(i);
    unsigned int j;

    for (j = 0; j < r->getNumReactants(); j++)
    {
      SpeciesReference *sr = r->getReactant(j);
      // we do not get here unless the stoichiometryMath is an integer
      // or a rational 
      if (l2 == true && sr->isSetStoichiometryMath() == true)
      {
        const ASTNode* ast = sr->getStoichiometryMath()->getMath();
        if (ast->isInteger())
        {
          int num = (int)ast->getInteger();
          sr->setStoichiometry(num);
          sr->setDenominator(1);
        }
        else
        {
          int num = (int)ast->getNumerator();
          int denom = (int)ast->getDenominator();
          sr->setStoichiometry(num);
          sr->setDenominator(denom);
        }
        sr->unsetStoichiometryMath();
      }
      else
      {
        sr->setStoichiometry(sr->getStoichiometry());
        sr->setDenominator(1);
      }
    }
    for (j = 0; j < r->getNumProducts(); j++)
    {
      SpeciesReference *sr = r->getProduct(j);
      // we do not get here unless the stoichiometryMath is an integer
      // or a rational 
      if (l2 == true && sr->isSetStoichiometryMath() == true)
      {
        const ASTNode* ast = sr->getStoichiometryMath()->getMath();
        if (ast->isInteger())
        {
          int num = (int)ast->getInteger();
          sr->setStoichiometry(num);
          sr->setDenominator(1);
        }
        else
        {
          int num = (int)ast->getNumerator();
          int denom = (int)ast->getDenominator();
          sr->setStoichiometry(num);
          sr->setDenominator(denom);
        }
        sr->unsetStoichiometryMath();
      }
      else
      {
        sr->setStoichiometry(sr->getStoichiometry());
        sr->setDenominator(1);
      }
    }
  }
}

/** @endcond **/

LIBSBML_CPP_NAMESPACE_END


