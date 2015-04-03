/**
 * \file    TestRequiredAttributes.cpp
 * \brief   Test hasRequiredAttributes unit tests
 * \author  Ben Bornstein
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
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/units/FormulaUnitsData.h>

#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/math/ASTNode.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


CK_CPPSTART

START_TEST ( test_Compartment )
{
  Compartment* c = new Compartment(2, 4);
  
  fail_unless (!(c->hasRequiredAttributes()));

  c->setId("c");

  fail_unless (c->hasRequiredAttributes());

  delete c;
}
END_TEST

START_TEST ( test_CompartmentType )
{
  CompartmentType* ct = new CompartmentType(2, 4);
  
  fail_unless (!(ct->hasRequiredAttributes()));

  ct->setId("c");

  fail_unless (ct->hasRequiredAttributes());

  delete ct;
}
END_TEST

START_TEST ( test_Constraint )
{
  Constraint* c = new Constraint(2, 4);
  
  fail_unless (c->hasRequiredAttributes());

  delete c;
}
END_TEST

START_TEST ( test_Delay )
{
  Delay* d = new Delay(2, 4);
  
  fail_unless (d->hasRequiredAttributes());

  delete d;
}
END_TEST

START_TEST ( test_Event )
{
  Event* e = new Event(2, 4);
  
  fail_unless (e->hasRequiredAttributes());

  delete e;
}
END_TEST

START_TEST ( test_EventAssignment )
{
  EventAssignment* ea = new EventAssignment(2, 4);
  
  fail_unless (!(ea->hasRequiredAttributes()));

  ea->setVariable("ea");

  fail_unless (ea->hasRequiredAttributes());

  delete ea;
}
END_TEST

START_TEST ( test_FunctionDefinition )
{
  FunctionDefinition* fd = new FunctionDefinition(2, 4);
  
  fail_unless (!(fd->hasRequiredAttributes()));

  fd->setId("fd");

  fail_unless (fd->hasRequiredAttributes());

  delete fd;
}
END_TEST

START_TEST ( test_InitialAssignment )
{
  InitialAssignment* ia = new InitialAssignment(2, 4);
  
  fail_unless (!(ia->hasRequiredAttributes()));

  ia->setSymbol("ia");

  fail_unless (ia->hasRequiredAttributes());

  delete ia;
}
END_TEST

START_TEST ( test_KineticLaw )
{
  KineticLaw* kl = new KineticLaw(2, 4);
  
  fail_unless (kl->hasRequiredAttributes());

  delete kl;
}
END_TEST

START_TEST ( test_KineticLaw_L1 )
{
  KineticLaw* kl = new KineticLaw(1, 2);
  
  fail_unless (!(kl->hasRequiredAttributes()));

  kl->setFormula("kl");

  fail_unless (kl->hasRequiredAttributes());

  delete kl;
}
END_TEST

START_TEST ( test_Model )
{
  Model* m = new Model(2, 4);
  
  fail_unless (m->hasRequiredAttributes());

  delete m;
}
END_TEST

START_TEST ( test_Parameter )
{
  Parameter* p = new Parameter(2, 4);
  
  fail_unless (!(p->hasRequiredAttributes()));

  p->setId("p");

  fail_unless (p->hasRequiredAttributes());

  delete p;
}
END_TEST

START_TEST ( test_Parameter_L1V1 )
{
  Parameter* p = new Parameter(1, 1);
  
  fail_unless (!(p->hasRequiredAttributes()));

  p->setId("p");

  fail_unless (!(p->hasRequiredAttributes()));

  p->setValue(12);

  fail_unless (p->hasRequiredAttributes());

  delete p;
}
END_TEST

START_TEST ( test_Reaction )
{
  Reaction* r = new Reaction(2, 4);
  
  fail_unless (!(r->hasRequiredAttributes()));

  r->setId("r");

  fail_unless (r->hasRequiredAttributes());

  delete r;
}
END_TEST

START_TEST ( test_AlgebraicRule )
{
  AlgebraicRule* ar = new AlgebraicRule(2, 4);
  
  fail_unless (ar->hasRequiredAttributes());

  delete ar;
}
END_TEST

START_TEST ( test_AlgebraicRule_L1 )
{
  AlgebraicRule* ar = new AlgebraicRule(1, 2);
  
  fail_unless (!(ar->hasRequiredAttributes()));

  ar->setFormula("ar");

  fail_unless (ar->hasRequiredAttributes());

  delete ar;
}
END_TEST

START_TEST ( test_AssignmentRule )
{
  AssignmentRule* r = new AssignmentRule(2, 4);
  
  fail_unless (!(r->hasRequiredAttributes()));

  r->setVariable("r");

  fail_unless (r->hasRequiredAttributes());

  delete r;
}
END_TEST

START_TEST ( test_AssignmentRule_L1 )
{
  AssignmentRule* r = new AssignmentRule(1, 2);
  
  fail_unless (!(r->hasRequiredAttributes()));

  r->setVariable("r");

  fail_unless (!(r->hasRequiredAttributes()));

  r->setFormula ("r");
  
  fail_unless (r->hasRequiredAttributes());

  delete r;
}
END_TEST

START_TEST ( test_RateRule )
{
  RateRule* r = new RateRule(2, 4);
  
  fail_unless (!(r->hasRequiredAttributes()));

  r->setVariable("r");

  fail_unless (r->hasRequiredAttributes());

  delete r;
}
END_TEST

START_TEST ( test_RateRule_L1 )
{
  RateRule* r = new RateRule(1, 2);
  
  fail_unless (!(r->hasRequiredAttributes()));

  r->setVariable("r");

  fail_unless (!(r->hasRequiredAttributes()));

  r->setFormula ("r");
  
  fail_unless (r->hasRequiredAttributes());

  delete r;
}
END_TEST

START_TEST ( test_Species )
{
  Species* s = new Species(2, 4);
  
  fail_unless (!(s->hasRequiredAttributes()));

  s->setId("s");

  fail_unless (!(s->hasRequiredAttributes()));

  s->setCompartment("c");

  fail_unless (s->hasRequiredAttributes());

  delete s;
}
END_TEST

START_TEST ( test_Species_L1 )
{
  Species* s = new Species(1, 2);
  
  fail_unless (!(s->hasRequiredAttributes()));

  s->setId("s");

  fail_unless (!(s->hasRequiredAttributes()));

  s->setCompartment("c");

  fail_unless (!(s->hasRequiredAttributes()));

  s->setInitialAmount(2);

  fail_unless (s->hasRequiredAttributes());

  delete s;
}
END_TEST

START_TEST ( test_SpeciesReference )
{
  SpeciesReference* sr = new SpeciesReference(2, 4);
  
  fail_unless (!(sr->hasRequiredAttributes()));

  sr->setSpecies("sr");

  fail_unless (sr->hasRequiredAttributes());

  delete sr;
}
END_TEST

START_TEST ( test_ModifierSpeciesReference )
{
  ModifierSpeciesReference* msr = new ModifierSpeciesReference(2, 4);
  
  fail_unless (!(msr->hasRequiredAttributes()));

  msr->setSpecies("msr");

  fail_unless (msr->hasRequiredAttributes());

  delete msr;
}
END_TEST

START_TEST ( test_SpeciesType )
{
  SpeciesType* st = new SpeciesType(2, 4);
  
  fail_unless (!(st->hasRequiredAttributes()));

  st->setId("st");

  fail_unless (st->hasRequiredAttributes());

  delete st;
}
END_TEST

START_TEST ( test_StoichiometryMath )
{
  StoichiometryMath* sm = new StoichiometryMath(2, 4);
  
  fail_unless (sm->hasRequiredAttributes());

  delete sm;
}
END_TEST

START_TEST ( test_Trigger )
{
  Trigger* t = new Trigger(2, 4);
  
  fail_unless (t->hasRequiredAttributes());

  delete t;
}
END_TEST

START_TEST ( test_Unit )
{
  Unit* u = new Unit(2, 4);
  
  fail_unless (!(u->hasRequiredAttributes()));

  u->setKind(UNIT_KIND_MOLE);

  fail_unless (u->hasRequiredAttributes());

  delete u;
}
END_TEST

START_TEST ( test_UnitDefinition )
{
  UnitDefinition* ud = new UnitDefinition(2, 4);
  
  fail_unless (!(ud->hasRequiredAttributes()));

  ud->setId("ud");

  fail_unless (ud->hasRequiredAttributes());

  delete ud;
}
END_TEST

Suite *
create_suite_HasReqdAtt (void)
{
  Suite *suite = suite_create("HasReqdAtt");
  TCase *tcase = tcase_create("HasReqdAtt");

  tcase_add_test( tcase, test_Compartment);
  tcase_add_test( tcase, test_CompartmentType);
  tcase_add_test( tcase, test_Constraint);
  tcase_add_test( tcase, test_Delay);
  tcase_add_test( tcase, test_Event);
  tcase_add_test( tcase, test_EventAssignment);
  tcase_add_test( tcase, test_FunctionDefinition);
  tcase_add_test( tcase, test_InitialAssignment);
  tcase_add_test( tcase, test_KineticLaw);
  tcase_add_test( tcase, test_KineticLaw_L1);
  tcase_add_test( tcase, test_Model);
  tcase_add_test( tcase, test_Parameter);
  tcase_add_test( tcase, test_Parameter_L1V1);
  tcase_add_test( tcase, test_Reaction);
  tcase_add_test( tcase, test_AlgebraicRule);
  tcase_add_test( tcase, test_AlgebraicRule_L1);
  tcase_add_test( tcase, test_AssignmentRule);
  tcase_add_test( tcase, test_AssignmentRule_L1);
  tcase_add_test( tcase, test_RateRule);
  tcase_add_test( tcase, test_RateRule_L1);
  tcase_add_test( tcase, test_Species);
  tcase_add_test( tcase, test_Species_L1);
  tcase_add_test( tcase, test_SpeciesReference);
  tcase_add_test( tcase, test_ModifierSpeciesReference);
  tcase_add_test( tcase, test_StoichiometryMath);
  tcase_add_test( tcase, test_SpeciesType);
  tcase_add_test( tcase, test_Trigger);
  tcase_add_test( tcase, test_Unit);
  tcase_add_test( tcase, test_UnitDefinition);


  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND
