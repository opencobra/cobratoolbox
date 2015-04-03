/**
 * \file    TestSBMLParentObject.cpp
 * \brief   SBML parent object unit tests
 * \author  Sarah Keating
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

#include <sbml/common/common.h>

#include <sbml/SBase.h>
#include <sbml/Compartment.h>
#include <sbml/CompartmentType.h>
#include <sbml/Constraint.h>
#include <sbml/Delay.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/InitialAssignment.h>
#include <sbml/KineticLaw.h>
#include <sbml/ListOf.h>
#include <sbml/Model.h>
#include <sbml/Parameter.h>
#include <sbml/Reaction.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Species.h>
#include <sbml/SpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/SpeciesType.h>

#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/units/FormulaUnitsData.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaParser.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


BEGIN_C_DECLS

START_TEST ( test_Compartment_parent_add )
{
  Compartment *c = new Compartment(2, 4);
  c->setId("c");
  Model *m = new Model(2, 4);

  m->addCompartment(c);

  delete c;

  ListOf *lo = m->getListOfCompartments();

  fail_unless(lo == m->getCompartment(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_CompartmentType_parent_add )
{
  CompartmentType *ct = new CompartmentType(2, 4);
  Model *m = new Model(2, 4);
  ct->setId("ct");
  m->addCompartmentType(ct);

  delete ct;

  ListOf *lo = m->getListOfCompartmentTypes();

  fail_unless(lo == m->getCompartmentType(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Constraint_parent_add )
{
  Constraint *ct = new Constraint(2, 4);
  Model *m = new Model(2, 4);
  ASTNode_t* math = SBML_parseFormula("a-k");
  ct->setMath(math);
  ASTNode_free(math);
  m->addConstraint(ct);

  delete ct;

  ListOf *lo = m->getListOfConstraints();

  fail_unless(lo == m->getConstraint(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Delay_parent_add )
{
  Delay *d = new Delay(2, 4);
  Event *e = new Event(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  d->setMath(math);
  ASTNode_free(math);

  e->setDelay(d);

  delete d;

  fail_unless(e == e->getDelay()->getParentSBMLObject());

  delete e;
}
END_TEST


START_TEST ( test_Event_parent_add )
{
  Event *e = new Event(2, 4);
  Trigger *t = new Trigger(2, 4);
  ASTNode_t* math = SBML_parseFormula("true");
  t->setMath(math);
  ASTNode_free(math);
  e->setTrigger(t);
  e->createEventAssignment();
  Model *m = new Model(2, 4);

  m->addEvent(e);

  ListOf *lo = m->getListOfEvents();

  fail_unless(lo == m->getEvent(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete e;
  delete t;
  delete m;
}
END_TEST


START_TEST ( test_EventAssignment_parent_add )
{
  Event *e = new Event(2, 4);
  EventAssignment *ea = new EventAssignment(2, 4);
  ea->setVariable("c");
  ASTNode_t* math = SBML_parseFormula("K+L");
  ea->setMath(math);
  ASTNode_free(math);

  e->addEventAssignment(ea);

  delete ea;

  ListOf *lo = e->getListOfEventAssignments();

  fail_unless(lo == e->getEventAssignment(0)->getParentSBMLObject());
  fail_unless(e == lo->getParentSBMLObject());

  delete e;
}
END_TEST


START_TEST ( test_FunctionDefinition_parent_add )
{
  FunctionDefinition *fd = new FunctionDefinition(2, 4);
  Model *m = new Model(2, 4);
  fd->setId("fd");
  ASTNode_t* math = SBML_parseFormula("l");
  fd->setMath(math);
  ASTNode_free(math);

  m->addFunctionDefinition(fd);

  delete fd;

  ListOf *lo = m->getListOfFunctionDefinitions();

  fail_unless(lo == m->getFunctionDefinition(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_InitialAssignment_parent_add )
{
  InitialAssignment *ia = new InitialAssignment(2, 4);
  Model *m = new Model(2, 4);
  ia->setSymbol("c");
  ASTNode_t* math = SBML_parseFormula("9");
  ia->setMath(math);
  ASTNode_free(math);

  m->addInitialAssignment(ia);

  delete ia;

  ListOf *lo = m->getListOfInitialAssignments();

  fail_unless(lo == m->getInitialAssignment(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_parent_add )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  ASTNode_t* math = SBML_parseFormula("a");
  kl->setMath(math);
  ASTNode_free(math);
  
  Reaction * r = new Reaction(2, 4);

  r->setKineticLaw(kl);

  fail_unless(r == r->getKineticLaw()->getParentSBMLObject());

  delete r;
  delete kl;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_parent_add )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  
  Parameter *p = new Parameter(2, 4);
  p->setId("jake");
  kl->addParameter(p);
  delete p;

  fail_unless(kl->getNumParameters() == 1);
  fail_unless(kl->getParameter(0)->getId() == "jake");

  ListOfParameters *lop = kl->getListOfParameters();

  fail_unless(kl == lop->getParentSBMLObject());
  fail_unless(lop == kl->getParameter(0)->getParentSBMLObject());

  delete kl;
}
END_TEST


START_TEST ( test_Model_parent_add )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = new Model(2, 4);

  d->setModel(m);

  fail_unless(d == d->getModel()->getParentSBMLObject());

  delete d;
  delete m;
}
END_TEST


START_TEST ( test_Parameter_parent_add )
{
  Parameter *ia = new Parameter(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("p");

  m->addParameter(ia);

  delete ia;

  ListOf *lo = m->getListOfParameters();

  fail_unless(lo == m->getParameter(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Reaction_parent_add )
{
  Reaction *ia = new Reaction(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("k");

  m->addReaction(ia);

  delete ia;

  ListOf *lo = m->getListOfReactions();

  fail_unless(lo == m->getReaction(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST



START_TEST ( test_Rule_parent_add )
{
  Rule *ia = new RateRule(2, 4);
  ia->setVariable("a");
  ASTNode_t* math = SBML_parseFormula("9");
  ia->setMath(math);
  ASTNode_free(math);
  Model *m = new Model(2, 4);

  m->addRule(ia);

  delete ia;

  ListOf *lo = m->getListOfRules();

  fail_unless(lo == m->getRule(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST



START_TEST ( test_Species_parent_add )
{
  Species *ia = new Species(2, 4);
  ia->setId("s");
  ia->setCompartment("c");
  Model *m = new Model(2, 4);

  m->addSpecies(ia);

  delete ia;

  ListOf *lo = m->getListOfSpecies();

  fail_unless(lo == m->getSpecies(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST



START_TEST ( test_SpeciesReference_Product_parent_add )
{
  SpeciesReference *sr = new SpeciesReference(2, 4);
  Reaction *r = new Reaction(2, 4);
  sr->setSpecies("p");

  r->addProduct(sr);

  delete sr;

  ListOf *lo = r->getListOfProducts();

  fail_unless(lo == r->getProduct(0)->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_parent_add )
{
  SpeciesReference *sr = new SpeciesReference(2, 4);
  Reaction *r = new Reaction(2, 4);

  sr->setSpecies("s");
  r->addReactant(sr);

  delete sr;

  ListOf *lo = r->getListOfReactants();

  fail_unless(lo == r->getReactant(0)->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_parent_add )
{
  ModifierSpeciesReference *sr = new ModifierSpeciesReference(2, 4);
  sr->setSpecies("s");
  Reaction *r = new Reaction(2, 4);

  r->addModifier(sr);

  delete sr;

  ListOf *lo = r->getListOfModifiers();

  fail_unless(lo == r->getModifier(0)->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesType_parent_add )
{
  SpeciesType *ia = new SpeciesType(2, 4);
  ia->setId("s");
  Model *m = new Model(2, 4);

  m->addSpeciesType(ia);

  delete ia;

  ListOf *lo = m->getListOfSpeciesTypes();

  fail_unless(lo == m->getSpeciesType(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_StoichiometryMath_parent_add )
{
  StoichiometryMath *m = new StoichiometryMath(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  m->setMath(math);
  ASTNode_free(math);
  SpeciesReference *sr = new SpeciesReference(2, 4);

  sr->setStoichiometryMath(m);

  delete m;

  fail_unless(sr == sr->getStoichiometryMath()->getParentSBMLObject());

  delete sr;
}
END_TEST


START_TEST ( test_Trigger_parent_add )
{
  Trigger *d = new Trigger(2, 4);
  ASTNode_t* math = SBML_parseFormula("false");
  d->setMath(math);
  ASTNode_free(math);
  Event *e = new Event(2, 4);

  e->setTrigger(d);

  delete d;

  fail_unless(e == e->getTrigger()->getParentSBMLObject());

  delete e;
}
END_TEST


START_TEST ( test_Unit_parent_add )
{
  UnitDefinition* ud=new UnitDefinition(2, 4);
  
  Unit * u = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  ud->addUnit(u);
  delete u;

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();

  fail_unless(lo == ud->getUnit(0)->getParentSBMLObject());
  fail_unless(ud == lo->getParentSBMLObject());

  delete ud;
}
END_TEST


START_TEST ( test_UnitDefinition_parent_add )
{
  UnitDefinition *ia = new UnitDefinition(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("u");
  ia->createUnit();

  m->addUnitDefinition(ia);

  delete ia;

  ListOf *lo = m->getListOfUnitDefinitions();

  fail_unless(lo == m->getUnitDefinition(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Compartment_parent_create )
{
  Model *m = new Model(2, 4);
  Compartment *c = m->createCompartment();

  ListOf *lo = m->getListOfCompartments();

  fail_unless(lo == m->getCompartment(0)->getParentSBMLObject());
  fail_unless(lo == c->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_CompartmentType_parent_create )
{
  Model *m = new Model(2, 4);
  CompartmentType *ct = m->createCompartmentType();

  ListOf *lo = m->getListOfCompartmentTypes();

  fail_unless(lo == m->getCompartmentType(0)->getParentSBMLObject());
  fail_unless(lo == ct->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Constraint_parent_create )
{
  Model *m = new Model(2, 4);
  Constraint *ct = m->createConstraint();

  ListOf *lo = m->getListOfConstraints();

  fail_unless(lo == m->getConstraint(0)->getParentSBMLObject());
  fail_unless(lo == ct->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Event_parent_create )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  ListOf *lo = m->getListOfEvents();

  fail_unless(lo == m->getEvent(0)->getParentSBMLObject());
  fail_unless(lo == e->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_EventAssignment_parent_create )
{
  Event *e = new Event(2, 4);

  EventAssignment *ea = e->createEventAssignment();

  ListOf *lo = e->getListOfEventAssignments();

  fail_unless(lo == e->getEventAssignment(0)->getParentSBMLObject());
  fail_unless(lo == ea->getParentSBMLObject());
  fail_unless(e == lo->getParentSBMLObject());

  delete e;
}
END_TEST


START_TEST ( test_EventAssignment_parent_create_model )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  EventAssignment *ea = m->createEventAssignment();

  ListOf *lo = e->getListOfEventAssignments();

  fail_unless(lo == e->getEventAssignment(0)->getParentSBMLObject());
  fail_unless(lo == ea->getParentSBMLObject());
  fail_unless(e == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_FunctionDefinition_parent_create )
{
  Model *m = new Model(2, 4);
  FunctionDefinition *fd = m->createFunctionDefinition();

  ListOf *lo = m->getListOfFunctionDefinitions();

  fail_unless(lo == m->getFunctionDefinition(0)->getParentSBMLObject());
  fail_unless(lo == fd->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_InitialAssignment_parent_create )
{
  Model *m = new Model(2, 4);
  InitialAssignment *ia = m->createInitialAssignment();

  ListOf *lo = m->getListOfInitialAssignments();

  fail_unless(lo == m->getInitialAssignment(0)->getParentSBMLObject());
  fail_unless(lo == ia->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_parent_create )
{
  Reaction * r = new Reaction(2, 4);
  KineticLaw* kl = r->createKineticLaw();

  fail_unless(r == kl->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_KineticLaw_parent_create_model )
{
  Model *m = new Model(2, 4);
  Reaction * r = m->createReaction();
  KineticLaw* kl = r->createKineticLaw();

  fail_unless(r == kl->getParentSBMLObject());
  fail_unless(r == r->getKineticLaw()->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_parent_create )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  Parameter * p = kl->createParameter();

  fail_unless(kl->getNumParameters() == 1);

  ListOfParameters *lop = kl->getListOfParameters();

  fail_unless(kl == lop->getParentSBMLObject());
  fail_unless(lop == p->getParentSBMLObject());
  fail_unless(lop == kl->getParameter(0)->getParentSBMLObject());

  delete kl;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_parent_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  KineticLaw* kl = m->createKineticLaw();
  Parameter * p = m->createKineticLawParameter();

  fail_unless(kl->getNumParameters() == 1);

  ListOfParameters *lop = kl->getListOfParameters();

  fail_unless(r == kl->getParentSBMLObject());
  fail_unless(kl == lop->getParentSBMLObject());
  fail_unless(lop == p->getParentSBMLObject());
  fail_unless(lop == kl->getParameter(0)->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Model_parent_create )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = d->createModel();

  fail_unless(d == m->getParentSBMLObject());

  delete d;
}
END_TEST


START_TEST ( test_Parameter_parent_create )
{
  Model *m = new Model(2, 4);
  Parameter *p = m->createParameter();

  ListOf *lo = m->getListOfParameters();

  fail_unless(lo == m->getParameter(0)->getParentSBMLObject());
  fail_unless(lo == p->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Reaction_parent_create )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();

  ListOf *lo = m->getListOfReactions();

  fail_unless(lo == m->getReaction(0)->getParentSBMLObject());
  fail_unless(lo == r->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST



START_TEST ( test_AlgebraicRule_parent_create )
{
  Model *m = new Model(2, 4);
  AlgebraicRule *r = m->createAlgebraicRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(lo == m->getRule(0)->getParentSBMLObject());
  fail_unless(lo == r->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_AssignmentRule_parent_create )
{
  Model *m = new Model(2, 4);
  AssignmentRule *r = m->createAssignmentRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(lo == m->getRule(0)->getParentSBMLObject());
  fail_unless(lo == r->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_RateRule_parent_create )
{
  Model *m = new Model(2, 4);
  RateRule *r = m->createRateRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(lo == m->getRule(0)->getParentSBMLObject());
  fail_unless(lo == r->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Species_parent_create )
{
  Model *m = new Model(2, 4);
  Species *s = m->createSpecies();

  ListOf *lo = m->getListOfSpecies();

  fail_unless(lo == s->getParentSBMLObject());
  fail_unless(lo == m->getSpecies(0)->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Product_parent_create )
{
  Reaction *r = new Reaction(2, 4);
  SpeciesReference *sr = r->createProduct();

  ListOf *lo = r->getListOfProducts();

  fail_unless(lo == r->getProduct(0)->getParentSBMLObject());
  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Product_parent_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  SpeciesReference *sr = m->createProduct();

  ListOf *lo = r->getListOfProducts();

  fail_unless(lo == r->getProduct(0)->getParentSBMLObject());
  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_parent_create )
{
  Reaction *r = new Reaction(2, 4);
  SpeciesReference *sr = r->createReactant();

  ListOf *lo = r->getListOfReactants();

  fail_unless(lo == r->getReactant(0)->getParentSBMLObject());
  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_parent_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  SpeciesReference *sr = m->createReactant();

  ListOf *lo = r->getListOfReactants();

  fail_unless(lo == r->getReactant(0)->getParentSBMLObject());
  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_parent_create )
{
  Reaction *r = new Reaction(2, 4);
  ModifierSpeciesReference *sr = r->createModifier();

  ListOf *lo = r->getListOfModifiers();

  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(lo == r->getModifier(0)->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_parent_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  ModifierSpeciesReference *sr = m->createModifier();

  ListOf *lo = r->getListOfModifiers();

  fail_unless(lo == sr->getParentSBMLObject());
  fail_unless(lo == r->getModifier(0)->getParentSBMLObject());
  fail_unless(r == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_SpeciesType_parent_create )
{
  Model *m = new Model(2, 4);
  SpeciesType *st = m->createSpeciesType();

  ListOf *lo = m->getListOfSpeciesTypes();

  fail_unless(lo == m->getSpeciesType(0)->getParentSBMLObject());
  fail_unless(lo == st->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Unit_parent_create )
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  Unit * u = ud->createUnit();

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();

  fail_unless(lo == ud->getUnit(0)->getParentSBMLObject());
  fail_unless(lo == u->getParentSBMLObject());
  fail_unless(ud == lo->getParentSBMLObject());

  delete ud;
}
END_TEST


START_TEST ( test_Unit_parent_create_model )
{
  Model *m = new Model(2, 4);
  UnitDefinition* ud = m->createUnitDefinition();
  Unit * u = m->createUnit();

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();

  fail_unless(lo == ud->getUnit(0)->getParentSBMLObject());
  fail_unless(lo == u->getParentSBMLObject());
  fail_unless(ud == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_UnitDefinition_parent_create )
{
  Model *m = new Model(2, 4);
  UnitDefinition *ud = m->createUnitDefinition();

  ListOf *lo = m->getListOfUnitDefinitions();

  fail_unless(lo == m->getUnitDefinition(0)->getParentSBMLObject());
  fail_unless(lo == ud->getParentSBMLObject());
  fail_unless(m == lo->getParentSBMLObject());

  delete m;
}
END_TEST


START_TEST ( test_Compartment_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  
  Compartment *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_CompartmentType_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = d->createModel();
  CompartmentType *c = m->createCompartmentType();
  
  CompartmentType *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_Constraint_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  Constraint *c = m->createConstraint();
  
  Constraint *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_Event_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = d->createModel();
  Event *c = m->createEvent();
  EventAssignment *ea = c->createEventAssignment();
  Trigger *t = new Trigger(2, 4);
  ASTNode math;
  t->setMath(&math);
  Delay *dy = new Delay(2, 4);
  dy->setMath(&math);
  c->setTrigger(t);
  c->setDelay(dy);
  
  fail_unless(c->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(c->getTrigger()->getParentSBMLObject() == c);
  fail_unless (c->getDelay()->getSBMLDocument() == d);
  fail_unless(ea->getAncestorOfType(SBML_EVENT) == c);

  Event *c1 = c->clone();
  delete d;
  delete t;
  delete dy;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  fail_unless(c1->getEventAssignment(0)->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getEventAssignment(0)->getAncestorOfType(SBML_EVENT) == c1);
  fail_unless(c1->getEventAssignment(0)->getParentSBMLObject() != NULL);
  fail_unless(c1->getEventAssignment(0)->getSBMLDocument() == NULL);

  fail_unless(c1->getTrigger()->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getTrigger()->getAncestorOfType(SBML_EVENT) == c1);
  fail_unless(c1->getTrigger()->getParentSBMLObject() != NULL);
  fail_unless(c1->getTrigger()->getSBMLDocument() == NULL);

  fail_unless(c1->getDelay()->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getDelay()->getAncestorOfType(SBML_EVENT) == c1);
  fail_unless(c1->getDelay()->getParentSBMLObject() != NULL);
  fail_unless(c1->getDelay()->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_FunctionDefinition_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  FunctionDefinition *c = m->createFunctionDefinition();
  
  FunctionDefinition *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_InitialAssignment_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  InitialAssignment *c = m->createInitialAssignment();
  
  InitialAssignment *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_KineticLaw_parent_NULL )
{
  Reaction * r = new Reaction(2, 4);
  KineticLaw *kl = r->createKineticLaw();
  Parameter *p = kl->createParameter();

  fail_unless(r == kl->getParentSBMLObject());
  fail_unless(r == p->getAncestorOfType(SBML_REACTION));
  fail_unless(kl == p->getAncestorOfType(SBML_KINETIC_LAW));

  KineticLaw *kl1 = kl->clone();

  fail_unless(kl1->getParentSBMLObject() == NULL);
  fail_unless(kl1->getParameter(0)->getAncestorOfType(SBML_REACTION) == NULL);
  fail_unless(kl1 == kl1->getParameter(0)->getAncestorOfType(SBML_KINETIC_LAW));
  
  delete r;
  delete kl1;
}
END_TEST


START_TEST ( test_Parameter_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  Parameter *c = m->createParameter();
  
  Parameter *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_Reaction_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  Reaction *c = m->createReaction();
  SpeciesReference *sr = c->createReactant();
  KineticLaw *kl = c->createKineticLaw();

  fail_unless(c->getAncestorOfType(SBML_MODEL) == m);
  fail_unless (c->getSBMLDocument() == d);
  fail_unless(sr->getAncestorOfType(SBML_REACTION) == c);
  fail_unless(kl->getAncestorOfType(SBML_REACTION) == c);

  Reaction *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  SpeciesReference *sr1 = c1->getReactant(0);
  fail_unless(sr1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(sr1->getAncestorOfType(SBML_REACTION) == c1);
  fail_unless (sr1->getSBMLDocument() == NULL);

  fail_unless(c1->getKineticLaw()->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getKineticLaw()->getAncestorOfType(SBML_REACTION) == c1);
  fail_unless (c1->getKineticLaw()->getSBMLDocument() == NULL);


  delete c1;
}
END_TEST


START_TEST ( test_Species_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  Species *c = m->createSpecies();
  
  Species *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_SpeciesType_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = d->createModel();
  SpeciesType *c = m->createSpeciesType();
  
  SpeciesType *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  delete c1;
}
END_TEST


START_TEST ( test_UnitDefinition_parent_NULL )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();
  UnitDefinition *c = m->createUnitDefinition();
  Unit *u = c->createUnit();
  
  fail_unless(u->getAncestorOfType(SBML_UNIT_DEFINITION) == c);
  
  UnitDefinition *c1 = c->clone();
  delete d;

  fail_unless(c1->getAncestorOfType(SBML_MODEL) == NULL);
  fail_unless(c1->getParentSBMLObject() == NULL);
  fail_unless (c1->getSBMLDocument() == NULL);

  fail_unless(c1->getUnit(0)->getAncestorOfType(SBML_UNIT_DEFINITION) == c1);
  fail_unless(c1->getUnit(0)->getParentSBMLObject() != NULL);
  fail_unless (c1->getUnit(0)->getSBMLDocument() == NULL);
  
  delete c1;
}
END_TEST


START_TEST ( test_Compartment_parent_mismatch )
{
  Compartment *c = new Compartment(2, 3);
  c->setId("c");
  Model *m = new Model(2, 4);

  int success = m->addCompartment(c);

  fail_unless(success == LIBSBML_VERSION_MISMATCH);

  delete c;
  delete m;
}
END_TEST


START_TEST ( test_CompartmentType_parent_mismatch )
{
  CompartmentType *ct = new CompartmentType(2, 4);
  Model *m = new Model(3, 1);
  ct->setId("ct");
  
  int success = m->addCompartmentType(ct);

  fail_unless(success == LIBSBML_LEVEL_MISMATCH);

  delete ct;
  delete m;
}
END_TEST


START_TEST ( test_Constraint_parent_mismatch )
{
  Constraint *ct = NULL;
  Model *m = new Model(2, 4);

  int success = m->addConstraint(ct);

  fail_unless(success == LIBSBML_OPERATION_FAILED);

  delete ct;
  delete m;
}
END_TEST


START_TEST ( test_Delay_parent_mismatch )
{
  Event *e = new Event(3, 1);
  Delay *d = NULL;

  int success = e->setDelay(d);

  fail_unless(success == LIBSBML_OPERATION_SUCCESS);

  delete e;
  delete d;
}
END_TEST


START_TEST ( test_Event_parent_mismatch )
{
  Event *e = new Event(3, 1);
  Model *m = new Model(3, 1);

  int success = m->addEvent(e);

  fail_unless(success == LIBSBML_INVALID_OBJECT);

  delete e;
  delete m;
}
END_TEST


START_TEST ( test_EventAssignment_parent_mismatch )
{
  SBMLNamespaces sbmlns(3, 1);
  Event *e = new Event(&sbmlns);
  //sbmlns->addPackageNamespace("comp", 1);
  sbmlns.addNamespace("http://www.sbml.org/sbml/level3/version1/comp/version1", "comp");
  EventAssignment *ea = new EventAssignment(&sbmlns);
  ea->setVariable("c");
  ASTNode_t* math = SBML_parseFormula("K+L");
  ea->setMath(math);
  ASTNode_free(math);

  int success = e->addEventAssignment(ea);

  fail_unless(success == LIBSBML_NAMESPACES_MISMATCH);

  delete e;
  delete ea;
}
END_TEST


START_TEST ( test_KineticLaw_parent_mismatch )
{
  KineticLaw* kl=new KineticLaw(2, 3);
  ASTNode_t* math = SBML_parseFormula("true");
  kl->setMath(math);
  ASTNode_free(math);
  
  Reaction * r = new Reaction(2, 4);

  int success = r->setKineticLaw(kl);

  fail_unless(success == LIBSBML_VERSION_MISMATCH);

  delete r;
  delete kl;
}
END_TEST


START_TEST ( test_Model_parent_mismatch )
{
  SBMLNamespaces sbmlns(3, 1);
  SBMLDocument *d = new SBMLDocument(&sbmlns);
  //sbmlns->addPackageNamespace("comp", 1);
  sbmlns.addNamespace("http://www.sbml.org/sbml/level3/version1/comp/version1", "comp");
  Model *m = new Model(&sbmlns);

  int success = d->setModel(m);

  fail_unless(success == LIBSBML_NAMESPACES_MISMATCH);

  delete d;
  delete m;
}
END_TEST


START_TEST ( test_StoichiometryMath_parent_mismatch )
{
  StoichiometryMath *m = new StoichiometryMath(2, 4);
  SpeciesReference *sr = new SpeciesReference(2, 4);

  int success = sr->setStoichiometryMath(m);

  fail_unless(success == LIBSBML_INVALID_OBJECT);

  delete sr;
  delete m;
}
END_TEST


START_TEST ( test_Priority_parent_mismatch )
{
  Event *e = new Event(3, 1);
  Priority *p= new Priority(3, 1);
  ASTNode_t* math = SBML_parseFormula("K+L");
  p->setMath(math);
  ASTNode_free(math);

  int success = e->setPriority(p);

  fail_unless(success == LIBSBML_OPERATION_SUCCESS);

  success = e->setPriority(e->getPriority());

  fail_unless(success == LIBSBML_OPERATION_SUCCESS);

  delete e;
  delete p;
}
END_TEST


START_TEST ( test_Trigger_parent_mismatch )
{
  Event *e = new Event(3, 1);
  Trigger *t= new Trigger(2, 4);
  ASTNode_t* math = SBML_parseFormula("true");
  t->setMath(math);
  ASTNode_free(math);

  int success = e->setTrigger(t);

  fail_unless(success == LIBSBML_LEVEL_MISMATCH);

  delete e;
  delete t;
}
END_TEST


Suite *
create_suite_ParentObject (void)
{
  Suite *suite = suite_create("ParentObject");
  TCase *tcase = tcase_create("ParentObject");

  tcase_add_test( tcase, test_Compartment_parent_add );
  tcase_add_test( tcase, test_CompartmentType_parent_add );
  tcase_add_test( tcase, test_Constraint_parent_add );
  tcase_add_test( tcase, test_Delay_parent_add );
  tcase_add_test( tcase, test_Event_parent_add );
  tcase_add_test( tcase, test_EventAssignment_parent_add );
  tcase_add_test( tcase, test_FunctionDefinition_parent_add );
  tcase_add_test( tcase, test_InitialAssignment_parent_add );
  tcase_add_test( tcase, test_KineticLaw_parent_add );
  tcase_add_test( tcase, test_KineticLaw_Parameter_parent_add );
  tcase_add_test( tcase, test_Model_parent_add );
  tcase_add_test( tcase, test_Parameter_parent_add );
  tcase_add_test( tcase, test_Reaction_parent_add );
  tcase_add_test( tcase, test_Rule_parent_add );
  tcase_add_test( tcase, test_Species_parent_add );
  tcase_add_test( tcase, test_SpeciesReference_Product_parent_add );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_parent_add );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_parent_add );
  tcase_add_test( tcase, test_SpeciesType_parent_add );
  tcase_add_test( tcase, test_StoichiometryMath_parent_add );
  tcase_add_test( tcase, test_Trigger_parent_add );
  tcase_add_test( tcase, test_Unit_parent_add );
  tcase_add_test( tcase, test_UnitDefinition_parent_add );
  tcase_add_test( tcase, test_Compartment_parent_create );
  tcase_add_test( tcase, test_CompartmentType_parent_create );
  tcase_add_test( tcase, test_Constraint_parent_create );
  tcase_add_test( tcase, test_Event_parent_create );
  tcase_add_test( tcase, test_EventAssignment_parent_create );
  tcase_add_test( tcase, test_EventAssignment_parent_create_model );
  tcase_add_test( tcase, test_FunctionDefinition_parent_create );
  tcase_add_test( tcase, test_InitialAssignment_parent_create );
  tcase_add_test( tcase, test_KineticLaw_parent_create );
  tcase_add_test( tcase, test_KineticLaw_parent_create_model );
  tcase_add_test( tcase, test_KineticLaw_Parameter_parent_create );
  tcase_add_test( tcase, test_KineticLaw_Parameter_parent_create_model );
  tcase_add_test( tcase, test_Model_parent_create );
  tcase_add_test( tcase, test_Parameter_parent_create );
  tcase_add_test( tcase, test_Reaction_parent_create );
  tcase_add_test( tcase, test_AlgebraicRule_parent_create );
  tcase_add_test( tcase, test_AssignmentRule_parent_create );
  tcase_add_test( tcase, test_RateRule_parent_create );
  tcase_add_test( tcase, test_Species_parent_create );
  tcase_add_test( tcase, test_SpeciesReference_Product_parent_create );
  tcase_add_test( tcase, test_SpeciesReference_Product_parent_create_model );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_parent_create );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_parent_create_model );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_parent_create );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_parent_create_model );
  tcase_add_test( tcase, test_SpeciesType_parent_create );
  tcase_add_test( tcase, test_Unit_parent_create );
  tcase_add_test( tcase, test_Unit_parent_create_model );
  tcase_add_test( tcase, test_UnitDefinition_parent_create );
  tcase_add_test( tcase, test_Compartment_parent_NULL );
  tcase_add_test( tcase, test_CompartmentType_parent_NULL );
  tcase_add_test( tcase, test_Constraint_parent_NULL );
  tcase_add_test( tcase, test_Event_parent_NULL );
  tcase_add_test( tcase, test_FunctionDefinition_parent_NULL );
  tcase_add_test( tcase, test_InitialAssignment_parent_NULL );
  tcase_add_test( tcase, test_KineticLaw_parent_NULL );
  tcase_add_test( tcase, test_Parameter_parent_NULL );
  tcase_add_test( tcase, test_Reaction_parent_NULL );
  tcase_add_test( tcase, test_Species_parent_NULL );
  tcase_add_test( tcase, test_SpeciesType_parent_NULL );
  tcase_add_test( tcase, test_UnitDefinition_parent_NULL );
  tcase_add_test( tcase, test_Compartment_parent_mismatch );
  tcase_add_test( tcase, test_CompartmentType_parent_mismatch );
  tcase_add_test( tcase, test_Constraint_parent_mismatch );
  tcase_add_test( tcase, test_Delay_parent_mismatch );
  tcase_add_test( tcase, test_Event_parent_mismatch );
  tcase_add_test( tcase, test_EventAssignment_parent_mismatch );
  tcase_add_test( tcase, test_KineticLaw_parent_mismatch );
  tcase_add_test( tcase, test_Model_parent_mismatch );
  tcase_add_test( tcase, test_StoichiometryMath_parent_mismatch );
  tcase_add_test( tcase, test_Priority_parent_mismatch );
  tcase_add_test( tcase, test_Trigger_parent_mismatch );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

