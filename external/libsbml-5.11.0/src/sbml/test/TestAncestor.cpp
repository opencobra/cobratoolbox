/**
 * \file    TestAncestor.cpp
 * \brief   SBML ancestor objects unit tests
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

#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/SBMLDocument.h>
#include <sbml/Species.h>
#include <sbml/SpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/SpeciesType.h>
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


CK_CPPSTART
START_TEST ( test_Compartment_ancestor_add )
{
  Compartment *c = new Compartment(2, 4);
  c->setId("C");
  Model *m = new Model(2, 4);

  m->addCompartment(c);

  delete c;

  ListOf *lo = m->getListOfCompartments();
  Compartment *obj = m->getCompartment(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_CompartmentType_ancestor_add )
{
  CompartmentType *ct = new CompartmentType(2, 4);
  Model *m = new Model(2, 4);

  ct->setId("ct");
  m->addCompartmentType(ct);

  delete ct;

  ListOf *lo = m->getListOfCompartmentTypes();
  CompartmentType *obj = m->getCompartmentType(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Constraint_ancestor_add )
{
  Constraint *ct = new Constraint(2, 4);
  Model *m = new Model(2, 4);

  ASTNode_t* math = SBML_parseFormula("k+k");
  ct->setMath(math);
  delete math;
  m->addConstraint(ct);

  delete ct;

  ListOf *lo = m->getListOfConstraints();
  Constraint *obj = m->getConstraint(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Delay_ancestor_add )
{
  Delay *d = new Delay(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  d->setMath(math);
  delete math;
  Event *e = new Event(2, 4);

  e->setDelay(d);

  delete d;

  Delay *obj = e->getDelay();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);

  delete e;
}
END_TEST


START_TEST ( test_Event_ancestor_add )
{
  Event *e = new Event(2, 4);
  Model *m = new Model(2, 4);
  Trigger *t = new Trigger(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  t->setMath(math);
  delete math;
  e->setTrigger(t);
  e->createEventAssignment();

  m->addEvent(e);

  delete e;

  ListOf *lo = m->getListOfEvents();
  Event *obj = m->getEvent(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
  delete t;
}
END_TEST


START_TEST ( test_EventAssignment_ancestor_add )
{
  Event *e = new Event(2, 4);
  EventAssignment *ea = new EventAssignment(2, 4);
  ea->setVariable("c");
  ASTNode_t* math = SBML_parseFormula("K+L");
  ea->setMath(math);
  delete math;

  e->addEventAssignment(ea);

  delete ea;

  ListOf *lo = e->getListOfEventAssignments();
  EventAssignment *obj = e->getEventAssignment(0);

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete e;
}
END_TEST


START_TEST ( test_FunctionDefinition_ancestor_add )
{
  FunctionDefinition *fd = new FunctionDefinition(2, 4);
  Model *m = new Model(2, 4);
  fd->setId("fd");
  ASTNode_t* math = SBML_parseFormula("l");
  fd->setMath(math);
  delete math;

  m->addFunctionDefinition(fd);

  delete fd;

  ListOf *lo = m->getListOfFunctionDefinitions();
  FunctionDefinition *obj = m->getFunctionDefinition(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_InitialAssignment_ancestor_add )
{
  InitialAssignment *ia = new InitialAssignment(2, 4);
  Model *m = new Model(2, 4);
  ia->setSymbol("c");
  ASTNode_t* math = SBML_parseFormula("9");
  ia->setMath(math);
  delete math;

  m->addInitialAssignment(ia);

  delete ia;

  ListOf *lo = m->getListOfInitialAssignments();
  InitialAssignment *obj = m->getInitialAssignment(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_ancestor_add )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  kl->setMath(math);
  delete math;
  
  Reaction * r = new Reaction(2, 4);

  r->setKineticLaw(kl);
  KineticLaw *obj = r->getKineticLaw();

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);

  delete r;
  delete kl;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_ancestor_add )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  
  Parameter *p = new Parameter(2, 4);
  p->setId("jake");
  kl->addParameter(p);
  delete p;

  ListOfParameters *lop = kl->getListOfParameters();
  Parameter *obj = kl->getParameter(0);

  fail_unless(obj->getAncestorOfType(SBML_KINETIC_LAW)    == kl);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lop);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete kl;
}
END_TEST


START_TEST ( test_Model_ancestor_add )
{
  SBMLDocument *d = new SBMLDocument(2, 4);
  Model *m = new Model(2, 4);

  d->setModel(m);

  fail_unless(d == d->getModel()->getAncestorOfType(SBML_DOCUMENT));

  delete d;
  delete m;
}
END_TEST


START_TEST ( test_Parameter_ancestor_add )
{
  Parameter *ia = new Parameter(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("p");

  m->addParameter(ia);

  delete ia;

  ListOf *lo = m->getListOfParameters();
  Parameter *obj = m->getParameter(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Reaction_ancestor_add )
{
  Reaction *ia = new Reaction(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("k");

  m->addReaction(ia);

  delete ia;

  ListOf *lo = m->getListOfReactions();
  Reaction *obj = m->getReaction(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST



START_TEST ( test_Rule_ancestor_add )
{
  Rule *ia = new RateRule(2, 4);
  ia->setVariable("a");
  ASTNode_t* math = SBML_parseFormula("9");
  ia->setMath(math);
  delete math;

  Model *m = new Model(2, 4);

  m->addRule(ia);

  delete ia;

  ListOf *lo = m->getListOfRules();
  Rule *obj = m->getRule(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST



START_TEST ( test_Species_ancestor_add )
{
  Species *ia = new Species(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("s");
  ia->setCompartment("c");

  m->addSpecies(ia);

  delete ia;

  ListOf *lo = m->getListOfSpecies();
  Species *obj = m->getSpecies(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST



START_TEST ( test_SpeciesReference_Product_ancestor_add )
{
  SpeciesReference *sr = new SpeciesReference(2, 4);
  Reaction *r = new Reaction(2, 4);
  sr->setSpecies("p");

  r->addProduct(sr);

  delete sr;

  ListOf *lo = r->getListOfProducts();
  SpeciesReference *obj = r->getProduct(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_ancestor_add )
{
  SpeciesReference *sr = new SpeciesReference(2, 4);
  Reaction *r = new Reaction(2, 4);
  sr->setSpecies("s");

  r->addReactant(sr);

  delete sr;

  ListOf *lo = r->getListOfReactants();
  SpeciesReference *obj = r->getReactant(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_ancestor_add )
{
  ModifierSpeciesReference *sr = new ModifierSpeciesReference(2, 4);
  sr->setSpecies("s");
  Reaction *r = new Reaction(2, 4);

  r->addModifier(sr);

  delete sr;

  ListOf *lo = r->getListOfModifiers();
  ModifierSpeciesReference *obj = r->getModifier(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesType_ancestor_add )
{
  SpeciesType *ia = new SpeciesType(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("s");

  m->addSpeciesType(ia);

  delete ia;

  ListOf *lo = m->getListOfSpeciesTypes();
  SpeciesType *obj = m->getSpeciesType(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_StoichiometryMath_ancestor_add )
{
  StoichiometryMath *m = new StoichiometryMath(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  m->setMath(math);
  delete math;
  SpeciesReference *sr = new SpeciesReference(2, 4);

  sr->setStoichiometryMath(m);

  delete m;

  StoichiometryMath *obj = sr->getStoichiometryMath();

  fail_unless(obj->getAncestorOfType(SBML_SPECIES_REFERENCE)    == sr);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);

  delete sr;
}
END_TEST


START_TEST ( test_Trigger_ancestor_add )
{
  Trigger *d = new Trigger(2, 4);
  ASTNode_t* math = SBML_parseFormula("1");
  d->setMath(math);
  delete math;
  Event *e = new Event(2, 4);

  e->setTrigger(d);

  delete d;

  Trigger *obj = e->getTrigger();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);

  delete e;
}
END_TEST


START_TEST ( test_Unit_ancestor_add )
{
  UnitDefinition* ud=new UnitDefinition(2, 4);
  
  Unit * u = new Unit(2, 4);
  u->setKind(UNIT_KIND_MOLE);
  ud->addUnit(u);
  delete u;

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();
  Unit *obj = ud->getUnit(0);

  fail_unless(obj->getAncestorOfType(SBML_UNIT_DEFINITION) == ud);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete ud;
}
END_TEST


START_TEST ( test_UnitDefinition_ancestor_add )
{
  UnitDefinition *ia = new UnitDefinition(2, 4);
  Model *m = new Model(2, 4);
  ia->setId("u");
  ia->createUnit();

  m->addUnitDefinition(ia);

  delete ia;

  ListOf *lo = m->getListOfUnitDefinitions();
  UnitDefinition *obj = m->getUnitDefinition(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Compartment_ancestor_create )
{
  Model *m = new Model(2, 4);
  Compartment *c = m->createCompartment();

  ListOf *lo = m->getListOfCompartments();
  
  fail_unless(c->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(c->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(c->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(c->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Compartment *obj = m->getCompartment(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_CompartmentType_ancestor_create )
{
  Model *m = new Model(2, 4);
  CompartmentType *ct = m->createCompartmentType();

  ListOf *lo = m->getListOfCompartmentTypes();

  fail_unless(ct->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ct->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ct->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ct->getAncestorOfType(SBML_EVENT)    == NULL);
  
  CompartmentType *obj = m->getCompartmentType(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Constraint_ancestor_create )
{
  Model *m = new Model(2, 4);
  Constraint *ct = m->createConstraint();

  ListOf *lo = m->getListOfConstraints();

  fail_unless(ct->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ct->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ct->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ct->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Constraint *obj = m->getConstraint(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Delay_ancestor_create )
{
  Event *e = new Event(2, 4);

  Delay *ea = e->createDelay();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Delay *obj = e->getDelay();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete e;
}
END_TEST


START_TEST ( test_Delay_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  Delay *ea = m->createDelay();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Delay *obj = e->getDelay();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Event_ancestor_create )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  ListOf *lo = m->getListOfEvents();

  fail_unless(e->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(e->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(e->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(e->getAncestorOfType(SBML_PARAMETER)    == NULL);
  
  Event *obj = m->getEvent(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_EventAssignment_ancestor_create )
{
  Event *e = new Event(2, 4);

  EventAssignment *ea = e->createEventAssignment();

  ListOf *lo = e->getListOfEventAssignments();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  EventAssignment *obj = e->getEventAssignment(0);

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete e;
}
END_TEST


START_TEST ( test_EventAssignment_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  EventAssignment *ea = m->createEventAssignment();

  ListOf *lo = e->getListOfEventAssignments();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ea->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  EventAssignment *obj = e->getEventAssignment(0);

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_FunctionDefinition_ancestor_create )
{
  Model *m = new Model(2, 4);
  FunctionDefinition *fd = m->createFunctionDefinition();

  ListOf *lo = m->getListOfFunctionDefinitions();

  fail_unless(fd->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(fd->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(fd->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(fd->getAncestorOfType(SBML_EVENT)    == NULL);
  
  FunctionDefinition *obj = m->getFunctionDefinition(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_InitialAssignment_ancestor_create )
{
  Model *m = new Model(2, 4);
  InitialAssignment *ia = m->createInitialAssignment();

  ListOf *lo = m->getListOfInitialAssignments();

  fail_unless(ia->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ia->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ia->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ia->getAncestorOfType(SBML_EVENT)    == NULL);
  
  InitialAssignment *obj = m->getInitialAssignment(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_ancestor_create )
{
  Reaction * r = new Reaction(2, 4);
  KineticLaw* kl = r->createKineticLaw();

  fail_unless(kl->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(kl->getAncestorOfType(SBML_DELAY)    == NULL);
  fail_unless(kl->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(kl->getAncestorOfType(SBML_DOCUMENT) == NULL);

  KineticLaw *obj = r->getKineticLaw();

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DELAY)    == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);

  delete r;
}
END_TEST


START_TEST ( test_KineticLaw_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Reaction * r = m->createReaction();
  KineticLaw* kl = r->createKineticLaw();

  fail_unless(kl->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(kl->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(kl->getAncestorOfType(SBML_DELAY)    == NULL);
  fail_unless(kl->getAncestorOfType(SBML_DOCUMENT) == NULL);

  KineticLaw *obj = r->getKineticLaw();

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_DELAY)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_ancestor_create )
{
  KineticLaw* kl=new KineticLaw(2, 4);
  Parameter * p = kl->createParameter();

  fail_unless(kl->getNumParameters() == 1);

  ListOfParameters *lop = kl->getListOfParameters();

  fail_unless(p->getAncestorOfType(SBML_KINETIC_LAW)    == kl);
  fail_unless(p->getAncestorOfType(SBML_LIST_OF)  == lop);
  fail_unless(p->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(p->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Parameter *obj = kl->getParameter(0);

  fail_unless(obj->getAncestorOfType(SBML_KINETIC_LAW)    == kl);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lop);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete kl;
}
END_TEST


START_TEST ( test_KineticLaw_Parameter_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  KineticLaw* kl = m->createKineticLaw();
  Parameter * p = m->createKineticLawParameter();

  fail_unless(kl->getNumParameters() == 1);

  ListOfParameters *lop = kl->getListOfParameters();

  fail_unless(p->getAncestorOfType(SBML_KINETIC_LAW)    == kl);
  fail_unless(p->getAncestorOfType(SBML_LIST_OF)  == lop);
  fail_unless(p->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(p->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(p->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(p->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Parameter *obj = kl->getParameter(0);

  fail_unless(obj->getAncestorOfType(SBML_KINETIC_LAW)    == kl);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lop);
  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Model_ancestor_create )
{
  SBMLDocument *d = new SBMLDocument();
  Model *m = d->createModel();

  fail_unless(m->getAncestorOfType(SBML_DOCUMENT) == d);

  Model *obj = d->getModel();
 
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == d);

  delete d;
}
END_TEST


START_TEST ( test_Parameter_ancestor_create )
{
  Model *m = new Model(2, 4);
  Parameter *p = m->createParameter();

  ListOf *lo = m->getListOfParameters();

  fail_unless(p->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(p->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(p->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(p->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Parameter *obj = m->getParameter(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Reaction_ancestor_create )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();

  ListOf *lo = m->getListOfReactions();

  fail_unless(r->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(r->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(r->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(r->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Reaction *obj = m->getReaction(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_AlgebraicRule_ancestor_create )
{
  Model *m = new Model(2, 4);
  AlgebraicRule *r = m->createAlgebraicRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(r->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(r->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(r->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(r->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Rule *obj = m->getRule(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_AssignmentRule_ancestor_create )
{
  Model *m = new Model(2, 4);
  AssignmentRule *r = m->createAssignmentRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(r->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(r->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(r->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(r->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Rule *obj = m->getRule(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_RateRule_ancestor_create )
{
  Model *m = new Model(2, 4);
  RateRule *r = m->createRateRule();

  ListOf *lo = m->getListOfRules();

  fail_unless(r->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(r->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(r->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(r->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Rule *obj = m->getRule(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Species_ancestor_create )
{
  Model *m = new Model(2, 4);
  Species *s = m->createSpecies();

  ListOf *lo = m->getListOfSpecies();

  fail_unless(s->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(s->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(s->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(s->getAncestorOfType(SBML_EVENT)    == NULL);
  
  Species *obj = m->getSpecies(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Product_ancestor_create )
{
  Reaction *r = new Reaction(2, 4);
  SpeciesReference *sr = r->createProduct();

  ListOf *lo = r->getListOfProducts();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  SpeciesReference *obj = r->getProduct(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Product_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  SpeciesReference *sr = m->createProduct();

  ListOf *lo = r->getListOfProducts();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  SpeciesReference *obj = r->getProduct(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_ancestor_create )
{
  Reaction *r = new Reaction(2, 4);
  SpeciesReference *sr = r->createReactant();

  ListOf *lo = r->getListOfReactants();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  SpeciesReference *obj = r->getReactant(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Reactant_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  SpeciesReference *sr = m->createReactant();

  ListOf *lo = r->getListOfReactants();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  SpeciesReference *obj = r->getReactant(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_ancestor_create )
{
  Reaction *r = new Reaction(2, 4);
  ModifierSpeciesReference *sr = r->createModifier();

  ListOf *lo = r->getListOfModifiers();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  ModifierSpeciesReference *obj = r->getModifier(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete r;
}
END_TEST


START_TEST ( test_SpeciesReference_Modifier_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Reaction *r = m->createReaction();
  ModifierSpeciesReference *sr = m->createModifier();

  ListOf *lo = r->getListOfModifiers();

  fail_unless(sr->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(sr->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(sr->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(sr->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sr->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  ModifierSpeciesReference *obj = r->getModifier(0);

  fail_unless(obj->getAncestorOfType(SBML_REACTION) == r);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_SpeciesType_ancestor_create )
{
  Model *m = new Model(2, 4);
  SpeciesType *st = m->createSpeciesType();

  ListOf *lo = m->getListOfSpeciesTypes();

  fail_unless(st->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(st->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(st->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(st->getAncestorOfType(SBML_EVENT)    == NULL);
  
  SpeciesType *obj = m->getSpeciesType(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_StoichiometryMath_ancestor_create )
{
  SpeciesReference *sr = new SpeciesReference(2, 4);
  StoichiometryMath *sm = sr->createStoichiometryMath();

  fail_unless(sm->getAncestorOfType(SBML_SPECIES_REFERENCE) == sr);
  fail_unless(sm->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(sm->getAncestorOfType(SBML_COMPARTMENT) == NULL);

  StoichiometryMath *obj = sr->getStoichiometryMath();

  fail_unless(obj->getAncestorOfType(SBML_SPECIES_REFERENCE) == sr);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT) == NULL);

  delete sr;
}
END_TEST


START_TEST ( test_Trigger_ancestor_create )
{
  Event *e = new Event(2, 4);

  Trigger *ea = e->createTrigger();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Trigger *obj = e->getTrigger();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete e;
}
END_TEST


START_TEST ( test_Trigger_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  Event *e = m->createEvent();

  Trigger *ea = m->createTrigger();

  fail_unless(ea->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(ea->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ea->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ea->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Trigger *obj = e->getTrigger();

  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == e);
  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_Unit_ancestor_create )
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  Unit * u = ud->createUnit();

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();

  fail_unless(u->getAncestorOfType(SBML_UNIT_DEFINITION) == ud);
  fail_unless(u->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(u->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(u->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Unit *obj = ud->getUnit(0);

  fail_unless(obj->getAncestorOfType(SBML_UNIT_DEFINITION) == ud);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete ud;
}
END_TEST


START_TEST ( test_Unit_ancestor_create_model )
{
  Model *m = new Model(2, 4);
  UnitDefinition* ud = m->createUnitDefinition();
  Unit * u = m->createUnit();

  fail_unless(ud->getNumUnits() == 1);

  ListOf *lo = ud->getListOfUnits();

  fail_unless(u->getAncestorOfType(SBML_UNIT_DEFINITION) == ud);
  fail_unless(u->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(u->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(u->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(u->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  Unit *obj = ud->getUnit(0);

  fail_unless(obj->getAncestorOfType(SBML_UNIT_DEFINITION) == ud);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_MODEL) == m);
  fail_unless(obj->getAncestorOfType(SBML_COMPARTMENT)    == NULL);

  delete m;
}
END_TEST


START_TEST ( test_UnitDefinition_ancestor_create )
{
  Model *m = new Model(2, 4);
  UnitDefinition *ud = m->createUnitDefinition();

  ListOf *lo = m->getListOfUnitDefinitions();

  fail_unless(ud->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(ud->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(ud->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(ud->getAncestorOfType(SBML_EVENT)    == NULL);
  
  UnitDefinition *obj = m->getUnitDefinition(0);

  fail_unless(obj->getAncestorOfType(SBML_MODEL)    == m);
  fail_unless(obj->getAncestorOfType(SBML_LIST_OF)  == lo);
  fail_unless(obj->getAncestorOfType(SBML_DOCUMENT) == NULL);
  fail_unless(obj->getAncestorOfType(SBML_EVENT)    == NULL);

  delete m;
}
END_TEST


Suite *
create_suite_AncestorObject (void)
{
  Suite *suite = suite_create("AncestorObject");
  TCase *tcase = tcase_create("AncestorObject");

  tcase_add_test( tcase, test_Compartment_ancestor_add );
  tcase_add_test( tcase, test_CompartmentType_ancestor_add );
  tcase_add_test( tcase, test_Constraint_ancestor_add );
  tcase_add_test( tcase, test_Delay_ancestor_add );
  tcase_add_test( tcase, test_Event_ancestor_add );
  tcase_add_test( tcase, test_EventAssignment_ancestor_add );
  tcase_add_test( tcase, test_FunctionDefinition_ancestor_add );
  tcase_add_test( tcase, test_InitialAssignment_ancestor_add );
  tcase_add_test( tcase, test_KineticLaw_ancestor_add );
  tcase_add_test( tcase, test_KineticLaw_Parameter_ancestor_add );
  tcase_add_test( tcase, test_Model_ancestor_add );
  tcase_add_test( tcase, test_Parameter_ancestor_add );
  tcase_add_test( tcase, test_Reaction_ancestor_add );
  tcase_add_test( tcase, test_Rule_ancestor_add );
  tcase_add_test( tcase, test_Species_ancestor_add );
  tcase_add_test( tcase, test_SpeciesReference_Product_ancestor_add );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_ancestor_add );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_ancestor_add );
  tcase_add_test( tcase, test_SpeciesType_ancestor_add );
  tcase_add_test( tcase, test_StoichiometryMath_ancestor_add );
  tcase_add_test( tcase, test_Trigger_ancestor_add );
  tcase_add_test( tcase, test_Unit_ancestor_add );
  tcase_add_test( tcase, test_UnitDefinition_ancestor_add );
  tcase_add_test( tcase, test_Compartment_ancestor_create );
  tcase_add_test( tcase, test_CompartmentType_ancestor_create );
  tcase_add_test( tcase, test_Constraint_ancestor_create );
  tcase_add_test( tcase, test_Delay_ancestor_create );
  tcase_add_test( tcase, test_Delay_ancestor_create_model );
  tcase_add_test( tcase, test_Event_ancestor_create );
  tcase_add_test( tcase, test_EventAssignment_ancestor_create );
  tcase_add_test( tcase, test_EventAssignment_ancestor_create_model );
  tcase_add_test( tcase, test_FunctionDefinition_ancestor_create );
  tcase_add_test( tcase, test_InitialAssignment_ancestor_create );
  tcase_add_test( tcase, test_KineticLaw_ancestor_create );
  tcase_add_test( tcase, test_KineticLaw_ancestor_create_model );
  tcase_add_test( tcase, test_KineticLaw_Parameter_ancestor_create );
  tcase_add_test( tcase, test_KineticLaw_Parameter_ancestor_create_model );
  tcase_add_test( tcase, test_Model_ancestor_create );
  tcase_add_test( tcase, test_Parameter_ancestor_create );
  tcase_add_test( tcase, test_Reaction_ancestor_create );
  tcase_add_test( tcase, test_AlgebraicRule_ancestor_create );
  tcase_add_test( tcase, test_AssignmentRule_ancestor_create );
  tcase_add_test( tcase, test_RateRule_ancestor_create );
  tcase_add_test( tcase, test_Species_ancestor_create );
  tcase_add_test( tcase, test_SpeciesReference_Product_ancestor_create );
  tcase_add_test( tcase, test_SpeciesReference_Product_ancestor_create_model );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_ancestor_create );
  tcase_add_test( tcase, test_SpeciesReference_Reactant_ancestor_create_model );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_ancestor_create );
  tcase_add_test( tcase, test_SpeciesReference_Modifier_ancestor_create_model );
  tcase_add_test( tcase, test_SpeciesType_ancestor_create );
  tcase_add_test( tcase, test_StoichiometryMath_ancestor_create );
  tcase_add_test( tcase, test_Trigger_ancestor_create );
  tcase_add_test( tcase, test_Trigger_ancestor_create_model );
  tcase_add_test( tcase, test_Unit_ancestor_create );
  tcase_add_test( tcase, test_Unit_ancestor_create_model );
  tcase_add_test( tcase, test_UnitDefinition_ancestor_create );

  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND

