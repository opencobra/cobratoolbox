/**
 * \file    TestInternalConsistencyChecks.cpp
 * \brief   Tests the internal consistency validation.
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS



START_TEST (test_internal_consistency_check_99901)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  unsigned int dim = 2;
  c->setSpatialDimensions(dim);
  c->setId("c");
  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99901);
  */
  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99902)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setCompartmentType("hh");
  c->setId("c");
  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99902);
  */
  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99903)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setConstant(true);
  c->setId("c");
  m->addCompartment(c);

  Rule * r = m->createAssignmentRule();
  r->setVariable("c");
  r->setFormula("2*3");


  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99903);
  */
  /* this will give several errors as level 1 models
   * required a compartment
   * which wont have been added
   * which means the rule cant work out what type of rule
   */
  fail_unless(errors == 3);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99903_param)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Parameter *p = new Parameter(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");

  p->setConstant(true);
  p->setId("c");
  m->addParameter(p);

  Rule * r = m->createAssignmentRule();
  r->setVariable("c");
  r->setFormula("2*3");

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99903);
  */
  /* this will give several errors
   * parameter wont have been added
   * the rule cant work out what type of rule
   */
  fail_unless(errors == 2);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99903_localparam)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Parameter *p = new Parameter(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  Reaction *r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  KineticLaw *kl = r->createKineticLaw();
  kl->setFormula("2");

  p->setId("p");
  p->setConstant(false);
  kl->addParameter(p);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99903);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setId("c");
  c->setMetaId("mmm");
  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_kl)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  KineticLaw *kl = new KineticLaw(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(1, 2, false);
  Compartment *c = m->createCompartment();
  c->setId("cc");
  Reaction *r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");

  kl->setFormula("2");
  kl->setMetaId("mmm");
  r->setKineticLaw(kl);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_model)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  d->setLevelAndVersion(1, 2, false);
  Model * m = new Model(2, 4);
  Compartment *c = m->createCompartment();
  c->setId("cc");

  m->setMetaId("mmm");
  d->setModel(m);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  /* this will have error because the model is not added
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20201);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_param)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Parameter *p = new Parameter(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");

  p->setId("p");
  p->setMetaId("mmm");
  m->addParameter(p);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_react)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Reaction *r = new Reaction(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");

  r->setId("r");
  r->setMetaId("mmm");
  m->addReaction(r);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_rule_assign)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Rule *r = new AssignmentRule(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  c->setConstant(false);

  r->setVariable("cc");
  r->setFormula("2");
  r->setMetaId("mmm");
  m->addRule(r);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_rule_rate)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Rule *r = new RateRule(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  c->setConstant(false);

  r->setVariable("cc");
  r->setFormula("2");
  r->setMetaId("mmm");
  m->addRule(r);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_rule_alg)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Rule *r = new AlgebraicRule(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");

  r->setMetaId("mmm");
  r->setFormula("2");
  m->addRule(r);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_species)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");

  s->setCompartment("c");
  s->setId("s");
  s->setMetaId("mmm");
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_speciesRef)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesReference *sr = new SpeciesReference(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  Species * s = m->createSpecies();
  s->setId("s");
  s->setCompartment("c");
  Reaction *r = m->createReaction();
  r->setId("r");

  sr->setSpecies("s");
  sr->setMetaId("mmm");
  r->addProduct(sr);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  BUT the missing product gives an error 
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21101);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_unit)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Unit *u = new Unit(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("ud");

  u->setMetaId("mmm");
  u->setKind(UNIT_KIND_MOLE);
  ud->addUnit(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99904_unitdef)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  UnitDefinition *u = new UnitDefinition(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");

  u->setId("ud");
  u->setMetaId("mmm");
  u->createUnit();
  m->addUnitDefinition(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99904);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setId("c");
  c->setSBOTerm(2);
  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_ct)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  CompartmentType *ct = new CompartmentType(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 2, false);
  
  ct->setId("ct");
  ct->setSBOTerm(5);
  m->addCompartmentType(ct);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_delay)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Delay *delay = new Delay(2, 4);
  Event *e = new Event(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 2, false);
  delay->setSBOTerm(5);
  e->setDelay(delay);
  m->addEvent(e);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_species)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");

  s->setId("s");
  s->setCompartment("c");
  s->setSBOTerm(2);
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_st)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesType *ct = new SpeciesType(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 2, false);
  
  ct->setId("st");
  ct->setSBOTerm(5);
  m->addSpeciesType(ct);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_stoichmath)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  StoichiometryMath *sm = new StoichiometryMath(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 2, false);
  Species *s = m->createSpecies();
  s->setId("s");
  Compartment *c = m->createCompartment();
  c->setId("c");
  s->setCompartment("c");
  Reaction *r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createProduct();
  sr->setSpecies("s");
  
  sm->setSBOTerm(5);
  sr->setStoichiometryMath(sm);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_trigger)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Trigger *trigger = new Trigger(2, 4);
  Event *e = new Event(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 2, false);
  trigger->setSBOTerm(5);
  e->setTrigger(trigger);
  m->addEvent(e);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_unit)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Unit *u = new Unit(2, 4);
  d->setLevelAndVersion(2, 2, false);
  Model *m = d->createModel();
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("ud");

  u->setKind(UNIT_KIND_MOLE);
  u->setSBOTerm(9);
  ud->addUnit(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99905_unitdef)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  UnitDefinition *u = new UnitDefinition(2, 4);
  d->setLevelAndVersion(2, 2, false);
  Model *m = d->createModel();

  u->setId("ud");
  u->setSBOTerm(9);
  u->createUnit();
  m->addUnitDefinition(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99905);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99906)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setId("c");
  c->setUnits("mole");
  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99906);
  */
  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99907)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Compartment *c = new Compartment(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();

  c->setId("c");
  /* note - it is impossible to create the situation where a l1 model
   * has no volume set as the code doesnt let you !!!
   */
  c->unsetVolume();

  m->addCompartment(c);

  errors = d->checkInternalConsistency();

  /* this will give schema error as level 1 models
   * required a compartment
   * which wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 10103);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99908)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  CompartmentType *ct = new CompartmentType(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 1, false);

  ct->setId("ct");
  m->addCompartmentType(ct);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99908);
  */
  fail_unless(errors == 0);


  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99909)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Constraint *ct = new Constraint(2, 4);
  Model *m = d->createModel();

  d->setLevelAndVersion(2, 1, false);
  m->addConstraint(ct);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99909);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99910)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Event *e = new Event(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(1, 2, false);
  Compartment *c = m->createCompartment();
  c->setId("cc");
  c->setConstant(false);
  m->addEvent(e);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99910);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_event)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Event *e = new Event(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(2, 1, false);

  e->setSBOTerm(2);
  m->addEvent(e);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_ea)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  d->setLevelAndVersion(2, 1, false);
  unsigned int errors;
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setConstant(false);
  Event *e = m->createEvent();
  ASTNode *ast = SBML_parseFormula("2*x");
  Trigger *t = e->createTrigger();
  t->setMath(ast);
  EventAssignment *ea = new EventAssignment(2, 4);

  ea->setVariable("c");
  ea->setSBOTerm(2);
  ea->setMath(ast);
  e->addEventAssignment(ea);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  BUT missing event assignment will give error
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21203);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_fd)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  FunctionDefinition *fd = new FunctionDefinition(2, 4);
  d->setLevelAndVersion(2, 1, false);

  fd->setId("fd");
  fd->setSBOTerm(2);
  m->addFunctionDefinition(fd );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_kl)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  d->setLevelAndVersion(2, 1, false);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  KineticLaw *kl = new KineticLaw(2, 4);

  kl->setSBOTerm(2);
  Parameter *p = kl->createParameter();
  p->setId("p");
  r->setKineticLaw(kl );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_model)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  d->setLevelAndVersion(2, 1, false);
  Model * m = new Model(2, 4);

  m->setSBOTerm(2);
  d->setModel(m );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  /* this will have error as model wont have been added
   */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20201);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_param)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Parameter *p = new Parameter(2, 4);
  d->setLevelAndVersion(2, 1, false);

  p->setId("p");
  p->setSBOTerm(2);
  m->addParameter(p );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_react)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = new Reaction(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setId("r");
  r->setSBOTerm(2);
  m->addReaction(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_rule_assign)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("p");
  p->setConstant(false);
  Rule *r = new AssignmentRule(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setVariable("p");
  r->setSBOTerm(2);
  m->addRule(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_rule_rate)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Parameter *p = m->createParameter();
  p->setId("p");
  p->setConstant(false);
  Rule *r = new RateRule(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setVariable("p");
  r->setSBOTerm(2);
  m->addRule(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_rule_alg)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Rule *r = new AlgebraicRule(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setSBOTerm(2);
  m->addRule(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99911_speciesRef)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesReference *sr = new SpeciesReference(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  Species * s = m->createSpecies();
  s->setId("s");
  Reaction *r = m->createReaction();
  r->setId("r");

  s->setCompartment("c");
  sr->setSpecies("s");
  sr->setSBOTerm(4);
  r->addReactant(sr);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99911);
  But missing product/reactant will give error
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21101);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99912)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  FunctionDefinition *fd = new FunctionDefinition(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(1, 2, false);
  Compartment *c = m->createCompartment();
  c->setId("cc");
  c->setConstant(false);
 
  m->addFunctionDefinition(fd );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99912);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99913)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  InitialAssignment *ia = new InitialAssignment(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(1, 2, false);
  Compartment *c = m->createCompartment();
  c->setId("cc");
  c->setConstant(false);
  m->addInitialAssignment(ia );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99913);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99914)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Rule *r = new AlgebraicRule(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setVariable("kk");
  m->addRule(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99914);
  */

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99915_alg)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Rule *r = new AlgebraicRule(2, 4);
  d->setLevelAndVersion(2, 1, false);

  r->setUnits("kk");
  m->addRule(r );

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99915);
  */

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99915_assign)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setConstant(false);
  AssignmentRule *r = m->createAssignmentRule();
  r->setL1TypeCode(SBML_SPECIES_CONCENTRATION_RULE);

  r->setVariable("c");
  r->setFormula("2");
  r->setUnits("mmm");

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99915);
  */

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99915_rate)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setConstant(false);
  RateRule *r = m->createRateRule();
  r->setL1TypeCode(SBML_SPECIES_CONCENTRATION_RULE);

  r->setFormula("2");
  r->setVariable("c");
  r->setUnits("mmm");

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99915);
  */

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99916_rule)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment * c = m->createCompartment();
  c->setId("c");

  s->setId("s");
  s->setCompartment("c");
  s->setConstant(true);
  m->addSpecies(s);

  Rule * r = m->createAssignmentRule();
  r->setVariable("s");
  r->setFormula("2");


  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99916);
  */
  /* this will give several errors
   * species wont have been added
   * the rule cant work out what type of rule
   */
  fail_unless(errors == 2);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99916_reaction)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment * c = m->createCompartment();
  c->setId("c");
  Reaction * r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createReactant();

  s->setId("s");
  s->setCompartment("c");
  s->setConstant(true);
  sr->setSpecies("s");
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99916);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99917)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment * c = m->createCompartment();
  c->setId("c");

  s->setId("s");
  s->setCompartment("c");
  s->setSpatialSizeUnits("kkk");
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99917);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99918)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment * c = m->createCompartment();
  c->setId("c");

  s->setId("s");
  s->setCompartment("c");
  s->setSpeciesType("kkk");
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99918);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99919)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Species *s = new Species(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment * c = m->createCompartment();
  c->setId("c");

  s->setId("s");
  s->setCompartment("c");
  s->setHasOnlySubstanceUnits(true);
  m->addSpecies(s);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99919);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99920)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesReference *sr = new SpeciesReference(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  Species * s = m->createSpecies();
  s->setId("s");
  Reaction *r = m->createReaction();
  r->setId("r");

  s->setCompartment("c");
  sr->setSpecies("s");
  sr->setId("mmm");
  r->addProduct(sr);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 99920);
  fail_unless(d->getError(1)->getErrorId() == 99921);
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21101);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99921)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesReference *sr = new SpeciesReference(2, 4);
  d->setLevelAndVersion(2, 1, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  Species * s = m->createSpecies();
  s->setId("s");
  Reaction *r = m->createReaction();
  r->setId("r");

  s->setCompartment("c");
  sr->setSpecies("s");
  sr->setName("mmm");
  r->addReactant(sr);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(1)->getErrorId() == 99921);
  */
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21101);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99922)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  SpeciesType *ct = new SpeciesType(2, 4);
  Model *m = d->createModel();

  ct->setId("st");
  d->setLevelAndVersion(2, 1, false);
  m->addSpeciesType(ct);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(1)->getErrorId() == 99922);
  */
  fail_unless(errors == 0);


  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99923)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  StoichiometryMath *sm = new StoichiometryMath(2, 4);
  Model *m = d->createModel();
  d->setLevelAndVersion(1, 2, false);
  Species *s = m->createSpecies();
  s->setId("s");
  Compartment *c = m->createCompartment();
  c->setId("c");
  s->setCompartment("c");
  Reaction *r = m->createReaction();
  r->setId("r");
  SpeciesReference *sr = r->createProduct();
  sr->setSpecies("s");
  
  sr->setStoichiometryMath(sm);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99923);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99924)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Unit *u = new Unit(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("ud");

  u->setKind(UNIT_KIND_MOLE);
  u->setMultiplier(9);
  ud->addUnit(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(1)->getErrorId() == 99924);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_99925)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Unit *u = new Unit(2, 4);
  d->setLevelAndVersion(1, 2, false);
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("cc");
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("ud");

  u->setKind(UNIT_KIND_MOLE);
  u->setOffset(9);
  ud->addUnit(u);

  errors = d->checkInternalConsistency();

  /* as I change the set functions these should become 
   * impossible to create
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 99925);
  */
  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20306)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  FunctionDefinition *fd = m->createFunctionDefinition();
  fd->setId("fd");

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20306);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  fd->setMath(ast);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20307)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  FunctionDefinition *fd = m->createFunctionDefinition();
  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  fd->setMath(ast);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20307);

  fd->setId("fd");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20419)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  UnitDefinition *ud = m->createUnitDefinition();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20419);

  ud->setId("ud");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20421)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  UnitDefinition *ud = m->createUnitDefinition();
  ud->setId("ud");

  Unit *u = ud->createUnit();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 4);
  fail_unless(d->getError(0)->getErrorId() == 20421);
  fail_unless(d->getError(1)->getErrorId() == 20421);
  fail_unless(d->getError(2)->getErrorId() == 20421);
  fail_unless(d->getError(3)->getErrorId() == 20421);

  u->setKind(UNIT_KIND_MOLE);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 3);
  fail_unless(d->getError(0)->getErrorId() == 20421);
  fail_unless(d->getError(1)->getErrorId() == 20421);
  fail_unless(d->getError(2)->getErrorId() == 20421);

  u->setExponent(1.0);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 20421);
  fail_unless(d->getError(1)->getErrorId() == 20421);

  u->setScale(0);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20421);

  u->setMultiplier(1.0);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20517)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 20517);
  fail_unless(d->getError(1)->getErrorId() == 20517);

  c->setId("c");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20517);

  c->setConstant(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20623)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Compartment *c = m->createCompartment();
  c->setId("c");
  c->setConstant(true);

  Species *s = m->createSpecies();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 5);
  fail_unless(d->getError(0)->getErrorId() == 20623);
  fail_unless(d->getError(1)->getErrorId() == 20614);
  fail_unless(d->getError(2)->getErrorId() == 20623);
  fail_unless(d->getError(3)->getErrorId() == 20623);
  fail_unless(d->getError(4)->getErrorId() == 20623);

  s->setId("s");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 4);
  fail_unless(d->getError(0)->getErrorId() == 20614);
  fail_unless(d->getError(1)->getErrorId() == 20623);
  fail_unless(d->getError(2)->getErrorId() == 20623);
  fail_unless(d->getError(3)->getErrorId() == 20623);

  s->setCompartment("c");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 3);
  fail_unless(d->getError(0)->getErrorId() == 20623);
  fail_unless(d->getError(1)->getErrorId() == 20623);
  fail_unless(d->getError(2)->getErrorId() == 20623);

  s->setHasOnlySubstanceUnits(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 20623);
  fail_unless(d->getError(1)->getErrorId() == 20623);

  s->setBoundaryCondition(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20623);

  s->setConstant(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20706)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Parameter *p = m->createParameter();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 20706);
  fail_unless(d->getError(1)->getErrorId() == 20706);

  p->setId("c");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20706);

  p->setConstant(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20804)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  InitialAssignment *ia = m->createInitialAssignment();
  ia->setSymbol("fd");

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20804);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  ia->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20805)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  InitialAssignment *ia = m->createInitialAssignment();
  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  ia->setMath(ast);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20805);

  ia->setSymbol("fd");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20907_assign)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  AssignmentRule *r = m->createAssignmentRule();
  r->setVariable("fd");

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20907);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20907_rate)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  RateRule *r = m->createRateRule();
  r->setVariable("fd");

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20907);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20907_alg)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  AlgebraicRule *r = m->createAlgebraicRule();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20907);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20908)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  AssignmentRule *r = m->createAssignmentRule();
  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20908);

  r->setVariable("fd");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_20909)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  RateRule *r = m->createRateRule();
  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 20909);

  r->setVariable("fd");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21007)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Constraint *r = m->createConstraint();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21007);

  ASTNode *ast = SBML_parseFormula("lambda(x, 2*x)");
  r->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21101)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  r->setReversible(true);
  r->setFast(false);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21101);

  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  sr->setConstant(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21110)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  SpeciesReference *sr = r->createProduct();
  sr->setSpecies("s");
  sr->setConstant(true);

  errors = d->checkInternalConsistency();

  fail_unless(errors == 3);
  fail_unless(d->getError(0)->getErrorId() == 21110);
  fail_unless(d->getError(1)->getErrorId() == 21110);
  fail_unless(d->getError(2)->getErrorId() == 21110);

  r->setId("r");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 21110);
  fail_unless(d->getError(1)->getErrorId() == 21110);

  r->setReversible(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21110);

  r->setFast(false);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21116)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  r->setReversible(true);
  r->setFast(false);
  SpeciesReference *sr = r->createReactant();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 21116);
  fail_unless(d->getError(1)->getErrorId() == 21116);

  sr->setSpecies("s");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21116);

  sr->setConstant(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21117)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  r->setReversible(true);
  r->setFast(false);
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  sr->setConstant(true);
  ModifierSpeciesReference *msr = r->createModifier();

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21117);

  msr->setSpecies("s");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21130)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  r->setReversible(true);
  r->setFast(false);
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  sr->setConstant(true);
  KineticLaw *kl = r->createKineticLaw();
  LocalParameter *lp = kl->createLocalParameter();
  lp->setId("s");

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21130);

  ASTNode *ast = SBML_parseFormula("2*x");
  kl->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21172)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Reaction *r = m->createReaction();
  r->setId("r");
  r->setReversible(true);
  r->setFast(false);
  SpeciesReference *sr = r->createReactant();
  sr->setSpecies("s");
  sr->setConstant(true);
  KineticLaw *kl = r->createKineticLaw();
  ASTNode *ast = SBML_parseFormula("2*x");
  kl->setMath(ast);
  LocalParameter *lp = kl->createLocalParameter();

  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21172);

  lp->setId("pp");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21201)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("s");
  ASTNode *ast = SBML_parseFormula("2*x");
  ea->setMath(ast);


  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21201);

  Trigger *t = r->createTrigger();
  t->setPersistent(true);
  t->setInitialValue(false);
  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21203)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  ASTNode *ast = SBML_parseFormula("2*x");

  Trigger *t = r->createTrigger();
  t->setMath(ast);
  t->setPersistent(true);
  t->setInitialValue(false);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);

  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("ea");
  ea->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST

START_TEST (test_internal_consistency_check_21203_l2v4)
{
  SBMLDocument*     d = new SBMLDocument(2, 4);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  ASTNode *ast = SBML_parseFormula("2*x");

  Trigger *t = r->createTrigger();
  t->setMath(ast);
  t->setPersistent(true);
  t->setInitialValue(false);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  // in l2v4 this is an error
  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21203);
  
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("ea");
  ea->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST

START_TEST (test_internal_consistency_check_21209)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("s");
  ASTNode *ast = SBML_parseFormula("2*x");
  ea->setMath(ast);

  Trigger *t = r->createTrigger();
  t->setPersistent(true);
  t->setInitialValue(false);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21209);

  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21210)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  ASTNode *ast = SBML_parseFormula("2*x");

  Trigger *t = r->createTrigger();
  t->setMath(ast);
  t->setPersistent(true);
  t->setInitialValue(false);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("ea");
  ea->setMath(ast);
  Delay *delay = r->createDelay();

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21210);

  delay->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21213)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("s");
  ASTNode *ast = SBML_parseFormula("2*x");
  Trigger *t = r->createTrigger();
  t->setPersistent(true);
  t->setInitialValue(false);
  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21213);

  ea->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21214)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  EventAssignment *ea = r->createEventAssignment();
  ASTNode *ast = SBML_parseFormula("2*x");
  ea->setMath(ast);
  Trigger *t = r->createTrigger();
  t->setPersistent(true);
  t->setInitialValue(false);
  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21214);

  ea->setVariable("s");

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21225)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("s");
  ASTNode *ast = SBML_parseFormula("2*x");
  ea->setMath(ast);
  Trigger *t = r->createTrigger();
  t->setPersistent(true);
  t->setInitialValue(false);
  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21225);

  r->setUseValuesFromTriggerTime(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21226)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("s");
  ASTNode *ast = SBML_parseFormula("2*x");
  ea->setMath(ast);

  Trigger *t = r->createTrigger();
  t->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 2);
  fail_unless(d->getError(0)->getErrorId() == 21226);
  fail_unless(d->getError(1)->getErrorId() == 21226);

  t->setPersistent(true);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21226);
  
  t->setInitialValue(false);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


START_TEST (test_internal_consistency_check_21231)
{
  SBMLDocument*     d = new SBMLDocument(3, 1);
  unsigned int errors;
  Model *m = d->createModel();
  Event *r = m->createEvent();
  r->setUseValuesFromTriggerTime(true);
  ASTNode *ast = SBML_parseFormula("2*x");

  Trigger *t = r->createTrigger();
  t->setMath(ast);
  t->setPersistent(true);
  t->setInitialValue(false);
  EventAssignment *ea = r->createEventAssignment();
  ea->setVariable("ea");
  ea->setMath(ast);
  Priority *prior = r->createPriority();

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 1);
  fail_unless(d->getError(0)->getErrorId() == 21231);

  prior->setMath(ast);

  d->getErrorLog()->clearLog();
  errors = d->checkInternalConsistency();

  fail_unless(errors == 0);
  delete d;
}
END_TEST


Suite *
create_suite_TestInternalConsistencyChecks (void)
{ 
  Suite *suite = suite_create("InternalConsistencyChecks");
  TCase *tcase = tcase_create("InternalConsistencyChecks");


  tcase_add_test(tcase, test_internal_consistency_check_99901);
  tcase_add_test(tcase, test_internal_consistency_check_99902);
  tcase_add_test(tcase, test_internal_consistency_check_99903);
  tcase_add_test(tcase, test_internal_consistency_check_99903_param);
  tcase_add_test(tcase, test_internal_consistency_check_99903_localparam);
  tcase_add_test(tcase, test_internal_consistency_check_99904);
  tcase_add_test(tcase, test_internal_consistency_check_99904_kl);
  tcase_add_test(tcase, test_internal_consistency_check_99904_model);
  tcase_add_test(tcase, test_internal_consistency_check_99904_param);
  tcase_add_test(tcase, test_internal_consistency_check_99904_react);
  tcase_add_test(tcase, test_internal_consistency_check_99904_rule_assign);
  tcase_add_test(tcase, test_internal_consistency_check_99904_rule_rate);
  tcase_add_test(tcase, test_internal_consistency_check_99904_rule_alg);
  tcase_add_test(tcase, test_internal_consistency_check_99904_species);
  tcase_add_test(tcase, test_internal_consistency_check_99904_speciesRef);
  tcase_add_test(tcase, test_internal_consistency_check_99904_unit);
  tcase_add_test(tcase, test_internal_consistency_check_99904_unitdef);
  tcase_add_test(tcase, test_internal_consistency_check_99905);
  tcase_add_test(tcase, test_internal_consistency_check_99905_ct);
  tcase_add_test(tcase, test_internal_consistency_check_99905_delay);
  tcase_add_test(tcase, test_internal_consistency_check_99905_species);
  tcase_add_test(tcase, test_internal_consistency_check_99905_st);
  tcase_add_test(tcase, test_internal_consistency_check_99905_stoichmath);
  tcase_add_test(tcase, test_internal_consistency_check_99905_trigger);
  tcase_add_test(tcase, test_internal_consistency_check_99905_unit);
  tcase_add_test(tcase, test_internal_consistency_check_99905_unitdef);
  tcase_add_test(tcase, test_internal_consistency_check_99906);
  tcase_add_test(tcase, test_internal_consistency_check_99907);
  tcase_add_test(tcase, test_internal_consistency_check_99908);
  tcase_add_test(tcase, test_internal_consistency_check_99909);
  tcase_add_test(tcase, test_internal_consistency_check_99910);
  tcase_add_test(tcase, test_internal_consistency_check_99911_event);
  tcase_add_test(tcase, test_internal_consistency_check_99911_ea);
  tcase_add_test(tcase, test_internal_consistency_check_99911_fd);
  tcase_add_test(tcase, test_internal_consistency_check_99911_kl);
  tcase_add_test(tcase, test_internal_consistency_check_99911_model);
  tcase_add_test(tcase, test_internal_consistency_check_99911_param);
  tcase_add_test(tcase, test_internal_consistency_check_99911_react);
  tcase_add_test(tcase, test_internal_consistency_check_99911_rule_assign);
  tcase_add_test(tcase, test_internal_consistency_check_99911_rule_rate);
  tcase_add_test(tcase, test_internal_consistency_check_99911_rule_alg);
  tcase_add_test(tcase, test_internal_consistency_check_99911_speciesRef);
  tcase_add_test(tcase, test_internal_consistency_check_99912);
  tcase_add_test(tcase, test_internal_consistency_check_99913);
  tcase_add_test(tcase, test_internal_consistency_check_99914);
  tcase_add_test(tcase, test_internal_consistency_check_99915_alg);
  tcase_add_test(tcase, test_internal_consistency_check_99915_assign);
  tcase_add_test(tcase, test_internal_consistency_check_99915_rate);
  tcase_add_test(tcase, test_internal_consistency_check_99916_rule);
  tcase_add_test(tcase, test_internal_consistency_check_99916_reaction);
  tcase_add_test(tcase, test_internal_consistency_check_99917);
  tcase_add_test(tcase, test_internal_consistency_check_99918);
  tcase_add_test(tcase, test_internal_consistency_check_99919);
  tcase_add_test(tcase, test_internal_consistency_check_99920);
  tcase_add_test(tcase, test_internal_consistency_check_99921);
  tcase_add_test(tcase, test_internal_consistency_check_99922);
  tcase_add_test(tcase, test_internal_consistency_check_99923);
  tcase_add_test(tcase, test_internal_consistency_check_99924);
  tcase_add_test(tcase, test_internal_consistency_check_99925);
  tcase_add_test(tcase, test_internal_consistency_check_20306);
  tcase_add_test(tcase, test_internal_consistency_check_20307);
  tcase_add_test(tcase, test_internal_consistency_check_20419);
  tcase_add_test(tcase, test_internal_consistency_check_20421);
  tcase_add_test(tcase, test_internal_consistency_check_20517);
  tcase_add_test(tcase, test_internal_consistency_check_20623);
  tcase_add_test(tcase, test_internal_consistency_check_20706);
  tcase_add_test(tcase, test_internal_consistency_check_20804);
  tcase_add_test(tcase, test_internal_consistency_check_20805);
  tcase_add_test(tcase, test_internal_consistency_check_20907_assign);
  tcase_add_test(tcase, test_internal_consistency_check_20907_rate);
  tcase_add_test(tcase, test_internal_consistency_check_20907_alg);
  tcase_add_test(tcase, test_internal_consistency_check_20908);
  tcase_add_test(tcase, test_internal_consistency_check_20909);
  tcase_add_test(tcase, test_internal_consistency_check_21007);
  tcase_add_test(tcase, test_internal_consistency_check_21101);
  tcase_add_test(tcase, test_internal_consistency_check_21110);
  tcase_add_test(tcase, test_internal_consistency_check_21116);
  tcase_add_test(tcase, test_internal_consistency_check_21117);
  tcase_add_test(tcase, test_internal_consistency_check_21130);
  tcase_add_test(tcase, test_internal_consistency_check_21172);
  tcase_add_test(tcase, test_internal_consistency_check_21201);
  tcase_add_test(tcase, test_internal_consistency_check_21203);
  tcase_add_test(tcase, test_internal_consistency_check_21203_l2v4);
  tcase_add_test(tcase, test_internal_consistency_check_21209);
  tcase_add_test(tcase, test_internal_consistency_check_21210);
  tcase_add_test(tcase, test_internal_consistency_check_21213);
  tcase_add_test(tcase, test_internal_consistency_check_21214);
  tcase_add_test(tcase, test_internal_consistency_check_21225);
  tcase_add_test(tcase, test_internal_consistency_check_21226);
  tcase_add_test(tcase, test_internal_consistency_check_21231);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
