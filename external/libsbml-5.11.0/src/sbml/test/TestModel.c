/**
 * \file    TestModel.c
 * \brief   SBML Model unit tests
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
#include <sbml/SBMLTypes.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Model_t *M;


void
ModelTest_setup (void)
{
  M = Model_create(2, 4);

  if (M == NULL)
  {
    fail("Model_create() returned a NULL pointer.");
  }
}


void
ModelTest_teardown (void)
{
  Model_free(M);
}


START_TEST (test_Model_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) M) == SBML_MODEL );
  fail_unless( SBase_getMetaId    ((SBase_t *) M) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) M) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) M) == NULL );

  fail_unless( Model_getId  (M) == NULL );
  fail_unless( Model_getName(M) == NULL );

  fail_unless( !Model_isSetId(M)   );
  fail_unless( !Model_isSetName(M) );

  fail_unless( Model_getNumUnitDefinitions(M) == 0 );
  fail_unless( Model_getNumCompartments   (M) == 0 );
  fail_unless( Model_getNumSpecies        (M) == 0 );
  fail_unless( Model_getNumParameters     (M) == 0 );
  fail_unless( Model_getNumReactions      (M) == 0 );
}
END_TEST


START_TEST (test_Model_free_NULL)
{
  Model_free(NULL);
}
END_TEST


//START_TEST (test_Model_createWith)
//{
//  Model_t *m = Model_createWith("repressilator", "");
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) m) == SBML_MODEL );  
//  fail_unless( SBase_getMetaId    ((SBase_t *) m) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) m) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) m) == NULL );
//
//  fail_unless( Model_getName(m) == NULL );
//
//  fail_unless( !strcmp(Model_getId(m), "repressilator") );
//  fail_unless( Model_isSetId(m) );
//
//  fail_unless( Model_getNumUnitDefinitions(m) == 0 );
//  fail_unless( Model_getNumFunctionDefinitions(m) == 0 );
//  fail_unless( Model_getNumCompartments   (m) == 0 );
//  fail_unless( Model_getNumSpecies        (m) == 0 );
//  fail_unless( Model_getNumParameters     (m) == 0 );
//  fail_unless( Model_getNumReactions      (m) == 0 );
//  fail_unless( Model_getNumRules          (m) == 0 );
//  fail_unless( Model_getNumConstraints    (m) == 0 );
//  fail_unless( Model_getNumEvents         (m) == 0 );
//  fail_unless( Model_getNumCompartmentTypes(m) == 0 );
//  fail_unless( Model_getNumSpeciesTypes    (m) == 0 );
//  fail_unless( Model_getNumInitialAssignments (m) == 0 );
//
//  Model_free(m);
//}
//END_TEST


START_TEST (test_Model_setId)
{
  const char *id = "Branch";


  Model_setId(M, id);

  fail_unless( !strcmp(Model_getId(M), id) );
  fail_unless( Model_isSetId(M)   );

  if (Model_getId(M) == id)
  {
    fail("Model_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Model_setId(M, Model_getId(M));
  fail_unless( !strcmp(Model_getId(M), id) );

  Model_setId(M, NULL);
  fail_unless( !Model_isSetId(M) );

  if (Model_getId(M) != NULL)
  {
    fail("Model_setId(M, NULL) did not clear string.");
  }

  Model_setId(M, id);
  Model_unsetId(M);
  fail_unless( !Model_isSetId(M) );

}
END_TEST


START_TEST (test_Model_setName)
{
  const char *name = "My_Branch_Model";


  Model_setName(M, name);

  fail_unless( !strcmp(Model_getName(M), name) );
  fail_unless( Model_isSetName(M) );

  if (Model_getName(M) == name)
  {
    fail("Model_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Model_setName(M, Model_getName(M));
  fail_unless( !strcmp(Model_getName(M), name) );

  Model_setName(M, NULL);
  fail_unless( !Model_isSetName(M) );

  if (Model_getName(M) != NULL)
  {
    fail("Model_setName(M, NULL) did not clear string.");
  }
}
END_TEST

START_TEST(test_Model_setgetModelHistory)
{
  SBase_setMetaId((SBase_t *) (M), "_001");
  ModelHistory_t * history = ModelHistory_create();
  ModelCreator_t * mc = ModelCreator_create();
  Date_t * date = 
    Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  ModelHistory_addCreator(history, mc);
  ModelHistory_setCreatedDate(history, date);
  ModelHistory_setModifiedDate(history, date);

  fail_unless(Model_isSetModelHistory(M) == 0);

  Model_setModelHistory(M, history);

  fail_unless(Model_isSetModelHistory(M) == 1);

  ModelCreator_t *newMC = ModelHistory_getCreator(history, 0);

  fail_unless(newMC != NULL);

  fail_unless(!strcmp(ModelCreator_getFamilyName(newMC), "Keating"));
  fail_unless(!strcmp(ModelCreator_getGivenName(newMC), "Sarah"));
  fail_unless(!strcmp(ModelCreator_getEmail(newMC), "sbml-team@caltech.edu"));
  fail_unless(!strcmp(ModelCreator_getOrganisation(newMC), "UH"));

  Model_unsetModelHistory(M);
  fail_unless(Model_isSetModelHistory(M) == 0);


  ModelHistory_free(history);
  ModelCreator_free(mc);
  Date_free(date);
}
END_TEST


START_TEST (test_Model_createFunctionDefinition)
{
  FunctionDefinition_t *fd = Model_createFunctionDefinition(M);


  fail_unless( fd != NULL );
  fail_unless( Model_getNumFunctionDefinitions(M) == 1  );
  fail_unless( Model_getFunctionDefinition(M, 0)  == fd );
}
END_TEST


START_TEST (test_Model_createUnitDefinition)
{
  UnitDefinition_t *ud = Model_createUnitDefinition(M);


  fail_unless( ud != NULL );
  fail_unless( Model_getNumUnitDefinitions(M) == 1  );
  fail_unless( Model_getUnitDefinition(M, 0)  == ud );
}
END_TEST


START_TEST (test_Model_createUnit)
{
  UnitDefinition_t *ud;
  Unit_t           *u;


  Model_createUnitDefinition(M);
  Model_createUnitDefinition(M);

  u = Model_createUnit(M);

  fail_unless( u != NULL );
  fail_unless( Model_getNumUnitDefinitions(M) == 2 );

  ud = Model_getUnitDefinition(M, 1);

  fail_unless( UnitDefinition_getNumUnits(ud) == 1 );
  fail_unless( UnitDefinition_getUnit(ud, 0)  == u );
}
END_TEST


START_TEST (test_Model_createUnit_noUnitDefinition)
{
  fail_unless( Model_getNumUnitDefinitions(M) == 0 );
  fail_unless( Model_createUnit(M) == NULL );
}
END_TEST


START_TEST (test_Model_createCompartment)
{
  Compartment_t *c = Model_createCompartment(M);


  fail_unless( c != NULL );
  fail_unless( Model_getNumCompartments(M) == 1 );
  fail_unless( Model_getCompartment(M, 0)  == c );
}
END_TEST


START_TEST (test_Model_createCompartmentType)
{
  CompartmentType_t *c = Model_createCompartmentType(M);


  fail_unless( c != NULL );
  fail_unless( Model_getNumCompartmentTypes(M) == 1 );
  fail_unless( Model_getCompartmentType(M, 0)  == c );
}
END_TEST


START_TEST (test_Model_createSpeciesType)
{
  SpeciesType_t *c = Model_createSpeciesType(M);


  fail_unless( c != NULL );
  fail_unless( Model_getNumSpeciesTypes(M) == 1 );
  fail_unless( Model_getSpeciesType(M, 0)  == c );
}
END_TEST


START_TEST (test_Model_createInitialAssignment)
{
  InitialAssignment_t *c = Model_createInitialAssignment(M);


  fail_unless( c != NULL );
  fail_unless( Model_getNumInitialAssignments(M) == 1 );
  fail_unless( Model_getInitialAssignment(M, 0)  == c );
}
END_TEST


START_TEST (test_Model_createConstraint)
{
  Constraint_t *c = Model_createConstraint(M);


  fail_unless( c != NULL );
  fail_unless( Model_getNumConstraints(M) == 1 );
  fail_unless( Model_getConstraint(M, 0)  == c );
}
END_TEST


START_TEST (test_Model_createSpecies)
{
  Species_t *s = Model_createSpecies(M);


  fail_unless( s != NULL );
  fail_unless( Model_getNumSpecies(M) == 1 );
  fail_unless( Model_getSpecies(M, 0) == s );
}
END_TEST


START_TEST (test_Model_createParameter)
{
  Parameter_t *p = Model_createParameter(M);


  fail_unless( p != NULL );
  fail_unless( Model_getNumParameters(M) == 1 );
  fail_unless( Model_getParameter(M, 0)  == p );
}
END_TEST


START_TEST (test_Model_createAssignmentRule)
{
  Rule_t *ar = Model_createAssignmentRule(M);


  fail_unless( ar != NULL );
  fail_unless( Model_getNumRules(M) == 1 );
  fail_unless( Model_getRule(M, 0)  == (Rule_t *) ar );
}
END_TEST


START_TEST (test_Model_createRateRule)
{
  Rule_t *rr = Model_createRateRule(M);


  fail_unless( rr != NULL );
  fail_unless( Model_getNumRules(M) == 1 );
  fail_unless( Model_getRule(M, 0)  == (Rule_t *) rr );
}
END_TEST


START_TEST (test_Model_createAlgebraicRule)
{
  Rule_t *ar = Model_createAlgebraicRule(M);


  fail_unless( ar != NULL );
  fail_unless( Model_getNumRules(M) == 1 );
  fail_unless( Model_getRule(M, 0)  == (Rule_t *) ar );
}
END_TEST

START_TEST (test_Model_createReaction)
{
  Reaction_t *r = Model_createReaction(M);


  fail_unless( r != NULL );
  fail_unless( Model_getNumReactions(M) == 1 );
  fail_unless( Model_getReaction(M, 0)  == r );
}
END_TEST


START_TEST (test_Model_createReactant)
{
  Reaction_t         *r;
  SpeciesReference_t *sr;


  Model_createReaction(M);
  Model_createReaction(M);

  sr = Model_createReactant(M);

  fail_unless( sr != NULL );
  fail_unless( Model_getNumReactions(M) == 2 );

  r = Model_getReaction(M, 1);

  fail_unless( Reaction_getNumReactants(r) == 1  );
  fail_unless( Reaction_getReactant(r, 0)  == sr );
}
END_TEST


START_TEST (test_Model_createReactant_noReaction)
{
  fail_unless( Model_getNumReactions(M) == 0    );
  fail_unless( Model_createReactant(M)  == NULL );
}
END_TEST


START_TEST (test_Model_createProduct)
{
  Reaction_t         *r;
  SpeciesReference_t *sr;


  Model_createReaction(M);
  Model_createReaction(M);

  sr = Model_createProduct(M);

  fail_unless( sr != NULL );
  fail_unless( Model_getNumReactions(M) == 2 );

  r = Model_getReaction(M, 1);

  fail_unless( Reaction_getNumProducts(r) == 1  );
  fail_unless( Reaction_getProduct(r, 0)  == sr );
}
END_TEST


START_TEST (test_Model_createProduct_noReaction)
{
  fail_unless( Model_getNumReactions(M) == 0    );
  fail_unless( Model_createProduct(M)   == NULL );
}
END_TEST


START_TEST (test_Model_createModifier)
{
  Reaction_t                 *r;
  SpeciesReference_t *msr;


  Model_createReaction(M);
  Model_createReaction(M);

  msr = Model_createModifier(M);

  fail_unless( msr != NULL );
  fail_unless( Model_getNumReactions(M) == 2 );

  r = Model_getReaction(M, 1);

  fail_unless( Reaction_getNumModifiers(r) == 1   );
  fail_unless( Reaction_getModifier(r, 0)  == msr );
}
END_TEST


START_TEST (test_Model_createModifier_noReaction)
{
  fail_unless( Model_getNumReactions(M) == 0    );
  fail_unless( Model_createModifier(M)  == NULL );
}
END_TEST


START_TEST (test_Model_createKineticLaw)
{
  Reaction_t   *r;
  KineticLaw_t *kl;


  Model_createReaction(M);
  Model_createReaction(M);

  kl = Model_createKineticLaw(M);

  fail_unless( kl != NULL );
  fail_unless( Model_getNumReactions(M) == 2 );

  r = Model_getReaction(M, 0);
  fail_unless( Reaction_getKineticLaw(r) == NULL );

  r = Model_getReaction(M, 1);
  fail_unless( Reaction_getKineticLaw(r) == kl );
}
END_TEST


START_TEST (test_Model_createKineticLaw_alreadyExists)
{
  Reaction_t   *r;
  KineticLaw_t *kl;


  r  = Model_createReaction(M);
  kl = Model_createKineticLaw(M);

  fail_unless( Reaction_getKineticLaw(r) == kl );
}
END_TEST


START_TEST (test_Model_createKineticLaw_noReaction)
{
  fail_unless( Model_getNumReactions(M)  == 0    );
  fail_unless( Model_createKineticLaw(M) == NULL );
}
END_TEST


START_TEST (test_Model_createKineticLawParameter)
{
  Reaction_t   *r;
  KineticLaw_t *kl;
  Parameter_t  *p;


  Model_createReaction(M);
  Model_createReaction(M);
  Model_createKineticLaw(M);

  p = Model_createKineticLawParameter(M);

  fail_unless( Model_getNumReactions(M) == 2 );

  r = Model_getReaction(M, 0);
  fail_unless( Reaction_getKineticLaw(r) == NULL );

  r = Model_getReaction(M, 1);
  fail_unless( Reaction_getKineticLaw(r) != NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless( KineticLaw_getNumParameters(kl) == 1 );
  fail_unless( KineticLaw_getParameter(kl, 0)  == p );
}
END_TEST


START_TEST (test_Model_createKineticLawParameter_noReaction)
{
  fail_unless( Model_getNumReactions(M)           == 0    );
  fail_unless( Model_createKineticLawParameter(M) == NULL );
}
END_TEST


START_TEST (test_Model_createKineticLawParameter_noKineticLaw)
{
  Reaction_t *r;


  r = Model_createReaction(M);

  fail_unless( Reaction_getKineticLaw(r) == NULL );
  fail_unless( Model_createKineticLawParameter(M) == NULL );
}
END_TEST


START_TEST (test_Model_createEvent)
{
  Event_t *e = Model_createEvent(M);


  fail_unless( e != NULL );
  fail_unless( Model_getNumEvents(M) == 1 );
  fail_unless( Model_getEvent(M, 0)  == e );
}
END_TEST


START_TEST (test_Model_createEventAssignment)
{
  Event_t           *e;
  EventAssignment_t *ea;


  Model_createEvent(M);
  Model_createEvent(M);

  ea = Model_createEventAssignment(M);

  fail_unless( ea != NULL );
  fail_unless( Model_getNumEvents(M) == 2 );

  e = Model_getEvent(M, 1);

  fail_unless( Event_getNumEventAssignments(e) == 1  );
  fail_unless( Event_getEventAssignment(e, 0)  == ea );
}
END_TEST


START_TEST (test_Model_createEventAssignment_noEvent)
{
  fail_unless( Model_getNumEvents(M)          == 0    );
  fail_unless( Model_createEventAssignment(M) == NULL );
}
END_TEST


/**
 * If I had time to do it over again, this is how I would write and
 * combine the get / add tests for collection (see below).
 */
START_TEST (test_Model_add_get_FunctionDefinitions)
{
  FunctionDefinition_t *fd1 = FunctionDefinition_create(2, 4);
  FunctionDefinition_t *fd2 = FunctionDefinition_create(2, 4);

  FunctionDefinition_setId(fd1, "fd1");
  FunctionDefinition_setId(fd2, "fd2");

  ASTNode_t* math = SBML_parseFormula("2");
  FunctionDefinition_setMath(fd1, math);
  FunctionDefinition_setMath(fd2, math);
  ASTNode_free(math);

  Model_addFunctionDefinition(M, fd1);
  Model_addFunctionDefinition(M, fd2);

  fail_unless( Model_getNumFunctionDefinitions(M) == 2    );
  fail_unless( Model_getFunctionDefinition(M, 0)  != fd1  );
  fail_unless( Model_getFunctionDefinition(M, 1)  != fd2  );
  fail_unless( Model_getFunctionDefinition(M, 2)  == NULL );
  
  FunctionDefinition_free(fd1);
  FunctionDefinition_free(fd2);
}
END_TEST


/**
 * If I had time to do it over again, this is how I would write and
 * combine the get / add tests for collection (see below).
 */
START_TEST (test_Model_add_get_FunctionDefinitions_neg_arg)
{
  FunctionDefinition_t *fd1 = FunctionDefinition_create(2, 4);
  FunctionDefinition_t *fd2 = FunctionDefinition_create(2, 4);

  FunctionDefinition_setId(fd1, "fd1");
  FunctionDefinition_setId(fd2, "fd2");

  ASTNode_t* math = SBML_parseFormula("2");
  FunctionDefinition_setMath(fd1, math);
  FunctionDefinition_setMath(fd2, math);
  ASTNode_free(math);

  Model_addFunctionDefinition(M, fd1);
  Model_addFunctionDefinition(M, fd2);

  fail_unless( Model_getNumFunctionDefinitions(M) == 2    );
  fail_unless( Model_getFunctionDefinition(M, -2) == NULL );
  
  FunctionDefinition_free(fd1);
  FunctionDefinition_free(fd2);
}
END_TEST


START_TEST (test_Model_add_get_UnitDefinitions)
{
  UnitDefinition_t *ud1 = UnitDefinition_create(2, 4);
  UnitDefinition_t *ud2 = UnitDefinition_create(2, 4);

  UnitDefinition_setId(ud1, "ud1");
  UnitDefinition_setId(ud2, "ud2");

  UnitDefinition_createUnit(ud1);
  UnitDefinition_createUnit(ud2);

  Model_addUnitDefinition(M, ud1);
  Model_addUnitDefinition(M, ud2);

  fail_unless( Model_getNumUnitDefinitions(M) == 2    );
  fail_unless( Model_getUnitDefinition(M, 0)  != ud1  );
  fail_unless( Model_getUnitDefinition(M, 1)  != ud2  );
  fail_unless( Model_getUnitDefinition(M, 2)  == NULL );

  UnitDefinition_free(ud1);
  UnitDefinition_free(ud2);
}
END_TEST


START_TEST (test_Model_add_get_UnitDefinitions_neg_arg)
{
  UnitDefinition_t *ud1 = UnitDefinition_create(2, 4);
  UnitDefinition_t *ud2 = UnitDefinition_create(2, 4);

  UnitDefinition_setId(ud1, "ud1");
  UnitDefinition_setId(ud2, "ud2");

  UnitDefinition_createUnit(ud1);
  UnitDefinition_createUnit(ud2);

  Model_addUnitDefinition(M, ud1);
  Model_addUnitDefinition(M, ud2);

  fail_unless( Model_getNumUnitDefinitions(M) == 2    );
  fail_unless( Model_getUnitDefinition(M, -2) == NULL );

  UnitDefinition_free(ud1);
  UnitDefinition_free(ud2);
}
END_TEST


START_TEST (test_Model_addCompartment)
{
  Compartment_t *c = Compartment_create(2, 4);
  Compartment_setId(c, "c");
  Model_addCompartment(M, c);

  fail_unless( Model_getNumCompartments(M) == 1 );
  Compartment_free(c);
}
END_TEST


START_TEST (test_Model_addSpecies)
{
  Species_t * s = Species_create(2, 4);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Model_addSpecies(M, s);

  fail_unless( Model_getNumSpecies(M) == 1 );
  Species_free(s);
}
END_TEST


START_TEST (test_Model_addParameter)
{
  Parameter_t * p = Parameter_create(2, 4);
  Parameter_setId(p, "p");
  Model_addParameter(M, p);

  fail_unless( Model_getNumParameters(M) == 1 );
  Parameter_free(p);
}
END_TEST


START_TEST (test_Model_addRules)
{
  Rule_t *r1 = Rule_createAlgebraic(2, 4);
  Rule_t *r2 = Rule_createAssignment(2, 4);
  Rule_t *r3 = Rule_createRate(2, 4);

  Rule_setVariable(r2, "r2");
  Rule_setVariable(r3, "r3");
 
  ASTNode_t* math = SBML_parseFormula("2");
  Rule_setMath(r1, math);
  Rule_setMath(r2, math);
  Rule_setMath(r3, math);
  ASTNode_free(math);
  
  Model_addRule( M, r1);
  Model_addRule( M, r2);
  Model_addRule( M, r3);

  fail_unless( Model_getNumRules(M) == 3 );

  Rule_free(r1);
  Rule_free(r2);
  Rule_free(r3);
}
END_TEST


START_TEST (test_Model_addReaction)
{
  Reaction_t *r = Reaction_create(2, 4);
  Reaction_setId(r, "r");
  Model_addReaction(M, r);

  fail_unless( Model_getNumReactions(M) == 1 );
  Reaction_free(r);
}
END_TEST


START_TEST (test_Model_add_get_Event)
{
  Event_t *e1 = Event_create(2, 4);
  Event_t *e2 = Event_create(2, 4);
  Trigger_t *t = Trigger_create(2, 4);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Event_setTrigger(e1, t);
  Event_setTrigger(e2, t);
  Event_createEventAssignment(e1);
  Event_createEventAssignment(e2);

  Model_addEvent(M, e1);
  Model_addEvent(M, e2);

  fail_unless( Model_getNumEvents(M) == 2    );
  fail_unless( Model_getEvent(M, 0)  != e1   );
  fail_unless( Model_getEvent(M, 1)  != e2   );
  fail_unless( Model_getEvent(M, 2)  == NULL );

  Event_free(e1);
  Event_free(e2);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_add_get_Event_neg_arg)
{
  Event_t *e1 = Event_create(2, 4);
  Event_t *e2 = Event_create(2, 4);
  Trigger_t *t = Trigger_create(2, 4);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Event_setTrigger(e1, t);
  Event_setTrigger(e2, t);
  Event_createEventAssignment(e1);
  Event_createEventAssignment(e2);

  Model_addEvent(M, e1);
  Model_addEvent(M, e2);

  fail_unless( Model_getNumEvents(M) == 2    );
  fail_unless( Model_getEvent(M, -2) == NULL );

  Event_free(e1);
  Event_free(e2);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_getFunctionDefinitionById)
{
  FunctionDefinition_t *fd1 = FunctionDefinition_create(2, 4);
  FunctionDefinition_t *fd2 = FunctionDefinition_create(2, 4);

  FunctionDefinition_setId( fd1, "sin" );
  FunctionDefinition_setId( fd2, "cos" );

  ASTNode_t* math = SBML_parseFormula("2");
  FunctionDefinition_setMath(fd1, math);
  FunctionDefinition_setMath(fd2, math);
  ASTNode_free(math);

  Model_addFunctionDefinition(M, fd1);
  Model_addFunctionDefinition(M, fd2);

  fail_unless( Model_getNumFunctionDefinitions(M) == 2 );

  fail_unless( Model_getFunctionDefinitionById(M, "sin" ) != fd1  );
  fail_unless( Model_getFunctionDefinitionById(M, "cos" ) != fd2  );
  fail_unless( Model_getFunctionDefinitionById(M, "tan" ) == NULL );

  FunctionDefinition_free(fd1);
  FunctionDefinition_free(fd2);
}
END_TEST


START_TEST (test_Model_getUnitDefinition)
{
  UnitDefinition_t *ud1 = UnitDefinition_create(2, 4);
  UnitDefinition_t *ud2 = UnitDefinition_create(2, 4);

  UnitDefinition_setId( ud1, "mmls"   );
  UnitDefinition_setId( ud2, "volume" );

  UnitDefinition_createUnit(ud1);
  UnitDefinition_createUnit(ud2);

  Model_addUnitDefinition(M, ud1);
  Model_addUnitDefinition(M, ud2);

  fail_unless( Model_getNumUnitDefinitions(M) == 2 );

  UnitDefinition_free(ud1);
  UnitDefinition_free(ud2);

  ud1 = Model_getUnitDefinition(M, 0);
  ud2 = Model_getUnitDefinition(M, 1);

  fail_unless( !strcmp( UnitDefinition_getId(ud1), "mmls"   ) );
  fail_unless( !strcmp( UnitDefinition_getId(ud2), "volume" ) );
}
END_TEST


START_TEST (test_Model_getUnitDefinitionById)
{
  UnitDefinition_t *ud1 = UnitDefinition_create(2, 4);
  UnitDefinition_t *ud2 = UnitDefinition_create(2, 4);

  UnitDefinition_setId( ud1, "mmls"   );
  UnitDefinition_setId( ud2, "volume" );

  UnitDefinition_createUnit(ud1);
  UnitDefinition_createUnit(ud2);

  Model_addUnitDefinition(M, ud1);
  Model_addUnitDefinition(M, ud2);

  fail_unless( Model_getNumUnitDefinitions(M) == 2 );

  fail_unless( Model_getUnitDefinitionById(M, "mmls"       ) != ud1  );
  fail_unless( Model_getUnitDefinitionById(M, "volume"     ) != ud2  );
  fail_unless( Model_getUnitDefinitionById(M, "rototillers") == NULL );

  UnitDefinition_free(ud1);
  UnitDefinition_free(ud2);
}
END_TEST


START_TEST (test_Model_getCompartment)
{
  Compartment_t *c1 = Compartment_create(2, 4);
  Compartment_t *c2 = Compartment_create(2, 4);

  Compartment_setId(c1, "A");
  Compartment_setId(c2, "B");

  Model_addCompartment(M, c1);
  Model_addCompartment(M, c2);

  fail_unless( Model_getNumCompartments(M) == 2 );

  Compartment_free(c1);
  Compartment_free(c2);

  c1 = Model_getCompartment(M, 0);
  c2 = Model_getCompartment(M, 1);

  fail_unless( !strcmp(Compartment_getId(c1), "A") );
  fail_unless( !strcmp(Compartment_getId(c2), "B") );
}
END_TEST


START_TEST (test_Model_getCompartmentById)
{
  Compartment_t *c1 = Compartment_create(2, 4);
  Compartment_t *c2 = Compartment_create(2, 4);

  Compartment_setId( c1, "A" );
  Compartment_setId( c2, "B" );

  Model_addCompartment(M, c1);
  Model_addCompartment(M, c2);

  fail_unless( Model_getNumCompartments(M) == 2 );

  fail_unless( Model_getCompartmentById(M, "A" ) != c1   );
  fail_unless( Model_getCompartmentById(M, "B" ) != c2   );
  fail_unless( Model_getCompartmentById(M, "C" ) == NULL );

  Compartment_free(c1);
  Compartment_free(c2);
}
END_TEST


START_TEST (test_Model_getSpecies)
{
  Species_t *s1 = Species_create(2, 4);
  Species_t *s2 = Species_create(2, 4);

  Species_setId( s1, "Glucose"     );
  Species_setId( s2, "Glucose_6_P" );

  Species_setCompartment( s1, "c");
  Species_setCompartment( s2, "c");

  Model_addSpecies(M, s1);
  Model_addSpecies(M, s2);

  fail_unless( Model_getNumSpecies(M) == 2 );

  Species_free(s1);
  Species_free(s2);

  s1 = Model_getSpecies(M, 0);
  s2 = Model_getSpecies(M, 1);

  fail_unless( !strcmp( Species_getId(s1), "Glucose"     ) );
  fail_unless( !strcmp( Species_getId(s2), "Glucose_6_P" ) );
}
END_TEST


START_TEST (test_Model_getSpeciesById)
{
  Species_t *s1 = Species_create(2, 4);
  Species_t *s2 = Species_create(2, 4);

  Species_setId( s1, "Glucose"     );
  Species_setId( s2, "Glucose_6_P" );

  Species_setCompartment( s1, "c");
  Species_setCompartment( s2, "c");

  Model_addSpecies(M, s1);
  Model_addSpecies(M, s2);

  fail_unless( Model_getNumSpecies(M) == 2 );

  fail_unless( Model_getSpeciesById(M, "Glucose"    ) != s1   );
  fail_unless( Model_getSpeciesById(M, "Glucose_6_P") != s2   );
  fail_unless( Model_getSpeciesById(M, "Glucose2"   ) == NULL );

  Species_free(s1);
  Species_free(s2);
}
END_TEST


START_TEST (test_Model_getParameter)
{
  Parameter_t *p1 = Parameter_create(2, 4);
  Parameter_t *p2 = Parameter_create(2, 4);

  Parameter_setId(p1, "Km1");
  Parameter_setId(p2, "Km2");

  Model_addParameter(M, p1);
  Model_addParameter(M, p2);

  fail_unless( Model_getNumParameters(M) == 2 );

  Parameter_free(p1);
  Parameter_free(p2);

  p1 = Model_getParameter(M, 0);
  p2 = Model_getParameter(M, 1);

  fail_unless( !strcmp(Parameter_getId(p1), "Km1") );
  fail_unless( !strcmp(Parameter_getId(p2), "Km2") );
}
END_TEST


START_TEST (test_Model_getParameterById)
{
  Parameter_t *p1 = Parameter_create(2, 4);
  Parameter_t *p2 = Parameter_create(2, 4);

  Parameter_setId( p1, "Km1" );
  Parameter_setId( p2, "Km2" );

  Model_addParameter(M, p1);
  Model_addParameter(M, p2);

  fail_unless( Model_getNumParameters(M) == 2 );

  fail_unless( Model_getParameterById(M, "Km1" ) != p1   );
  fail_unless( Model_getParameterById(M, "Km2" ) != p2   );
  fail_unless( Model_getParameterById(M, "Km3" ) == NULL );

  Parameter_free(p1);
  Parameter_free(p2);
}
END_TEST


START_TEST (test_Model_getRules)
{
  Rule_t *ar  = Rule_createAlgebraic(2, 4);
  Rule_t *scr = Rule_createAssignment(2, 4);
  Rule_t *cvr = Rule_createAssignment(2, 4);
  Rule_t *pr  = Rule_createAssignment(2, 4);

  Rule_setVariable(scr, "r2");
  Rule_setVariable(cvr, "r3");
  Rule_setVariable(pr, "r4");


  Rule_setFormula(  ar , "x + 1"         );
  Rule_setFormula(  scr, "k * t/(1 + k)" );
  Rule_setFormula(  cvr, "0.10 * t"      );
  Rule_setFormula(  pr , "k3/k2"         );

  Model_addRule( M,  ar  );
  Model_addRule( M,  scr );
  Model_addRule( M,  cvr );
  Model_addRule( M,  pr  );

  fail_unless( Model_getNumRules(M) == 4 );

  Rule_free(ar);
  Rule_free(scr);
  Rule_free(cvr);
  Rule_free(pr);

  ar  = Model_getRule(M, 0);
  scr = Model_getRule(M, 1);
  cvr = Model_getRule(M, 2);
  pr  = Model_getRule(M, 3);

  fail_unless( !strcmp(Rule_getFormula( ar) , "x + 1"        ) );
  fail_unless( !strcmp(Rule_getFormula( scr), "k * t/(1 + k)") );
  fail_unless( !strcmp(Rule_getFormula( cvr), "0.10 * t"     ) );
  fail_unless( !strcmp(Rule_getFormula( pr) , "k3/k2"        ) );
}
END_TEST


START_TEST (test_Model_getReaction)
{
  Reaction_t *r1 = Reaction_create(2, 4);
  Reaction_t *r2 = Reaction_create(2, 4);

  Reaction_setId(r1, "reaction_1");
  Reaction_setId(r2, "reaction_2");

  Model_addReaction(M, r1);
  Model_addReaction(M, r2);

  fail_unless( Model_getNumReactions(M) == 2 );

  Reaction_free(r1);
  Reaction_free(r2);

  r1 = Model_getReaction(M, 0);
  r2 = Model_getReaction(M, 1);

  fail_unless( !strcmp(Reaction_getId(r1), "reaction_1") );
  fail_unless( !strcmp(Reaction_getId(r2), "reaction_2") );
}
END_TEST


START_TEST (test_Model_getReactionById)
{
  Reaction_t *r1 = Reaction_create(2, 4);
  Reaction_t *r2 = Reaction_create(2, 4);

  Reaction_setId( r1, "reaction_1" );
  Reaction_setId( r2, "reaction_2" );

  Model_addReaction(M, r1);
  Model_addReaction(M, r2);

  fail_unless( Model_getNumReactions(M) == 2 );

  fail_unless( Model_getReactionById(M, "reaction_1" ) != r1   );
  fail_unless( Model_getReactionById(M, "reaction_2" ) != r2   );
  fail_unless( Model_getReactionById(M, "reaction_3" ) == NULL );

  Reaction_free(r1);
  Reaction_free(r2);
}
END_TEST

START_TEST (test_Model_getSpeciesReferenceById)
{
  Reaction_t *r1 = Reaction_create(2, 4);
  Reaction_setId(r1, "r1");

  SpeciesReference_t *sr = Reaction_createReactant(r1);
  SpeciesReference_setId(sr, "s1");

  Model_addReaction(M, r1);

  fail_unless( Model_getNumReactions(M) == 1 );

  fail_unless( Model_getSpeciesReferenceById(M, "s1" ) != sr   );

  Reaction_free(r1);
}
END_TEST

/* THIS IS NOT LOGICAL BUT NEEDS A WHOLE MODEL TO TEST */
START_TEST (test_KineticLaw_getParameterById)
{
  Parameter_t *k1 = Parameter_create(2, 4);
  Parameter_t *k2 = Parameter_create(2, 4);

  Parameter_setId(k1, "k1");
  Parameter_setId(k2, "k2");

  Parameter_setValue(k1, 3.14);
  Parameter_setValue(k2, 2.72);

  Model_addParameter(M, k1);
  Model_addParameter(M, k2);

  Reaction_t *r1 = Reaction_create(2, 4);

  Reaction_setId( r1, "reaction_1" );

  KineticLaw_t *kl = KineticLaw_create(2, 4);
  KineticLaw_setFormula(kl, "k1 * X0");
  
  Parameter_t *k3 = Parameter_create(2, 4);
  Parameter_t *k4 = Parameter_create(2, 4);

  Parameter_setId(k3, "k1");
  Parameter_setId(k4, "k2");

  Parameter_setValue(k3, 2.72);
  Parameter_setValue(k4, 3.14);

  KineticLaw_addParameter(kl, k3);
  KineticLaw_addParameter(kl, k4);

  Reaction_setKineticLaw(r1, kl);
  Model_addReaction(M, r1);

  KineticLaw_t * kl1 = Reaction_getKineticLaw(Model_getReaction(M,0));

  fail_unless( KineticLaw_getParameterById(kl1, "k1" ) != k3   );
  fail_unless( KineticLaw_getParameterById(kl1, "k1" ) != k1   );
  fail_unless( KineticLaw_getParameterById(kl1, "k2" ) != k4   );
  fail_unless( KineticLaw_getParameterById(kl1, "k3" ) == NULL );

  Parameter_free(k1);
  Parameter_free(k2);
  Reaction_free(r1);
  KineticLaw_free(kl);
  Parameter_free(k3);
  Parameter_free(k4);
}
END_TEST


START_TEST (test_Model_getEventById)
{
  Event_t *e1 = Event_create(2, 4);
  Event_t *e2 = Event_create(2, 4);
  Trigger_t *t = Trigger_create(2, 4);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Event_setTrigger(e1, t);
  Event_setTrigger(e2, t);
  Event_createEventAssignment(e1);
  Event_createEventAssignment(e2);

  Event_setId( e1, "e1" );
  Event_setId( e2, "e2" );

  Model_addEvent(M, e1);
  Model_addEvent(M, e2);

  fail_unless( Model_getNumEvents(M) == 2 );

  fail_unless( Model_getEventById(M, "e1" ) != e1   );
  fail_unless( Model_getEventById(M, "e2" ) != e2   );
  fail_unless( Model_getEventById(M, "e3" ) == NULL );

  Event_free(e1);
  Event_free(e2);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_getNumSpeciesWithBoundaryCondition)
{
  Species_t *s1 = Species_create(2, 4);
  Species_t *s2 = Species_create(2, 4);
  Species_t *s3 = Species_create(2, 4);

  Species_setId(s1, "s1");
  Species_setId(s2, "s2");
  Species_setId(s3, "s3");

  Species_setCompartment(s1, "c1");
  Species_setCompartment(s2, "c2");
  Species_setCompartment(s3, "c3");

  Species_setBoundaryCondition(s1, 1);
  Species_setBoundaryCondition(s2, 0);
  Species_setBoundaryCondition(s3, 1);


  fail_unless( Model_getNumSpecies(M) == 0 );
  fail_unless( Model_getNumSpeciesWithBoundaryCondition(M) == 0 );

  Model_addSpecies(M, s1);

  fail_unless( Model_getNumSpecies(M) == 1 );
  fail_unless( Model_getNumSpeciesWithBoundaryCondition(M) == 1 );

  Model_addSpecies(M, s2);

  fail_unless( Model_getNumSpecies(M) == 2 );
  fail_unless( Model_getNumSpeciesWithBoundaryCondition(M) == 1 );

  Model_addSpecies(M, s3);

  fail_unless( Model_getNumSpecies(M) == 3 );
  fail_unless( Model_getNumSpeciesWithBoundaryCondition(M) == 2 );

  Species_free(s1);
  Species_free(s2);
  Species_free(s3);
}
END_TEST


START_TEST (test_Model_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Model_t *object = 
    Model_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_MODEL );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Model_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Model_getNamespaces(object)) == 2 );

  Model_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST

START_TEST (test_Model_removeFunctionDefinition)
{
  FunctionDefinition_t *o1, *o2, *o3; 

  o1 = Model_createFunctionDefinition(M);
  o2 = Model_createFunctionDefinition(M);
  o3 = Model_createFunctionDefinition(M);
  FunctionDefinition_setId(o3,"test");

  fail_unless( Model_removeFunctionDefinition(M,0) == o1 );
  fail_unless( Model_getNumFunctionDefinitions(M)  == 2  );
  fail_unless( Model_removeFunctionDefinition(M,0) == o2 );
  fail_unless( Model_getNumFunctionDefinitions(M)  == 1  );
  fail_unless( Model_removeFunctionDefinitionById(M,"test") == o3 );
  fail_unless( Model_getNumFunctionDefinitions(M)  == 0  );

  FunctionDefinition_free(o1);
  FunctionDefinition_free(o2);
  FunctionDefinition_free(o3);
}
END_TEST


START_TEST (test_Model_removeUnitDefinition)
{
  UnitDefinition_t *o1, *o2, *o3;

  o1 = Model_createUnitDefinition(M);
  o2 = Model_createUnitDefinition(M);
  o3 = Model_createUnitDefinition(M);
  UnitDefinition_setId(o3,"test");

  fail_unless( Model_removeUnitDefinition(M,0) == o1 );
  fail_unless( Model_getNumUnitDefinitions(M)  == 2  );
  fail_unless( Model_removeUnitDefinition(M,0) == o2 );
  fail_unless( Model_getNumUnitDefinitions(M)  == 1  );
  fail_unless( Model_removeUnitDefinitionById(M,"test") == o3 );
  fail_unless( Model_getNumUnitDefinitions(M)  == 0  );

  UnitDefinition_free(o1);
  UnitDefinition_free(o2);
  UnitDefinition_free(o3);
}
END_TEST


START_TEST (test_Model_removeCompartmentType)
{
  CompartmentType_t *o1, *o2, *o3;

  o1 = Model_createCompartmentType(M);
  o2 = Model_createCompartmentType(M);
  o3 = Model_createCompartmentType(M);
  CompartmentType_setId(o3,"test");

  fail_unless( Model_removeCompartmentType(M,0) == o1 );
  fail_unless( Model_getNumCompartmentTypes(M)  == 2  );
  fail_unless( Model_removeCompartmentType(M,0) == o2 );
  fail_unless( Model_getNumCompartmentTypes(M)  == 1  );
  fail_unless( Model_removeCompartmentTypeById(M,"test") == o3 );
  fail_unless( Model_getNumCompartmentTypes(M)  == 0  );

  CompartmentType_free(o1);
  CompartmentType_free(o2);
  CompartmentType_free(o3);
}
END_TEST


START_TEST (test_Model_removeSpeciesType)
{
  SpeciesType_t *o1, *o2, *o3;

  o1 = Model_createSpeciesType(M);
  o2 = Model_createSpeciesType(M);
  o3 = Model_createSpeciesType(M);
  SpeciesType_setId(o3,"test");

  fail_unless( Model_removeSpeciesType(M,0) == o1 );
  fail_unless( Model_getNumSpeciesTypes(M)  == 2  );
  fail_unless( Model_removeSpeciesType(M,0) == o2 );
  fail_unless( Model_getNumSpeciesTypes(M)  == 1  );
  fail_unless( Model_removeSpeciesTypeById(M,"test") == o3 );
  fail_unless( Model_getNumSpeciesTypes(M)  == 0  );

  SpeciesType_free(o1);
  SpeciesType_free(o2);
  SpeciesType_free(o3);
}
END_TEST


START_TEST (test_Model_removeCompartment)
{
  Compartment_t *o1, *o2, *o3;

  o1 = Model_createCompartment(M);
  o2 = Model_createCompartment(M);
  o3 = Model_createCompartment(M);
  Compartment_setId(o3,"test");

  fail_unless( Model_removeCompartment(M,0) == o1 );
  fail_unless( Model_getNumCompartments(M)  == 2  );
  fail_unless( Model_removeCompartment(M,0) == o2 );
  fail_unless( Model_getNumCompartments(M)  == 1  );
  fail_unless( Model_removeCompartmentById(M,"test") == o3 );
  fail_unless( Model_getNumCompartments(M)  == 0  );

  Compartment_free(o1);
  Compartment_free(o2);
  Compartment_free(o3);
}
END_TEST


START_TEST (test_Model_removeSpecies)
{
  Species_t *o1, *o2, *o3;

  o1 = Model_createSpecies(M);
  o2 = Model_createSpecies(M);
  o3 = Model_createSpecies(M);
  Species_setId(o3,"test");

  fail_unless( Model_removeSpecies(M,0) == o1 );
  fail_unless( Model_getNumSpecies(M)  == 2  );
  fail_unless( Model_removeSpecies(M,0) == o2 );
  fail_unless( Model_getNumSpecies(M)  == 1  );
  fail_unless( Model_removeSpeciesById(M,"test") == o3 );
  fail_unless( Model_getNumSpecies(M)  == 0  );

  Species_free(o1);
  Species_free(o2);
  Species_free(o3);
}
END_TEST


START_TEST (test_Model_removeParameter)
{
  Parameter_t *o1, *o2, *o3;

  o1 = Model_createParameter(M);
  o2 = Model_createParameter(M);
  o3 = Model_createParameter(M);
  Parameter_setId(o3,"test");

  fail_unless( Model_removeParameter(M,0) == o1 );
  fail_unless( Model_getNumParameters(M)  == 2  );
  fail_unless( Model_removeParameter(M,0) == o2 );
  fail_unless( Model_getNumParameters(M)  == 1  );
  fail_unless( Model_removeParameterById(M,"test") == o3 );
  fail_unless( Model_getNumParameters(M)  == 0  );

  Parameter_free(o1);
  Parameter_free(o2);
  Parameter_free(o3);
}
END_TEST


START_TEST (test_Model_removeInitialAssignment)
{
  InitialAssignment_t *o1, *o2, *o3;

  o1 = Model_createInitialAssignment(M);
  o2 = Model_createInitialAssignment(M);
  o3 = Model_createInitialAssignment(M);
  InitialAssignment_setSymbol(o3,"test");

  fail_unless( Model_removeInitialAssignment(M,0) == o1 );
  fail_unless( Model_getNumInitialAssignments(M)  == 2  );
  fail_unless( Model_removeInitialAssignment(M,0) == o2 );
  fail_unless( Model_getNumInitialAssignments(M)  == 1  );
  fail_unless( Model_removeInitialAssignmentBySym(M,"test") == o3 );
  fail_unless( Model_getNumInitialAssignments(M)  == 0  );

  InitialAssignment_free(o1);
  InitialAssignment_free(o2);
  InitialAssignment_free(o3);
}
END_TEST


START_TEST (test_Model_removeRule)
{
  Rule_t *o1, *o2, *o3;

  o1 = Model_createAssignmentRule(M);
  o2 = Model_createAlgebraicRule(M);
  o3 = Model_createRateRule(M);
  Rule_setVariable(o3,"test");

  fail_unless( Model_removeRule(M,0) == o1 );
  fail_unless( Model_getNumRules(M)  == 2  );
  fail_unless( Model_removeRule(M,0) == o2 );
  fail_unless( Model_getNumRules(M)  == 1  );
  fail_unless( Model_removeRuleByVar(M,"test") == o3 );
  fail_unless( Model_getNumRules(M)  == 0  );

  Rule_free(o1);
  Rule_free(o2);
  Rule_free(o3);
}
END_TEST


START_TEST (test_Model_removeConstraint)
{
  Constraint_t *o1, *o2, *o3;

  o1 = Model_createConstraint(M);
  o2 = Model_createConstraint(M);
  o3 = Model_createConstraint(M);

  fail_unless( Model_removeConstraint(M,0) == o1 );
  fail_unless( Model_getNumConstraints(M)  == 2  );
  fail_unless( Model_removeConstraint(M,0) == o2 );
  fail_unless( Model_getNumConstraints(M)  == 1  );
  fail_unless( Model_removeConstraint(M,0) == o3 );
  fail_unless( Model_getNumConstraints(M)  == 0  );

  Constraint_free(o1);
  Constraint_free(o2);
  Constraint_free(o3);
}
END_TEST


START_TEST (test_Model_removeReaction)
{
  Reaction_t *o1, *o2, *o3;

  o1 = Model_createReaction(M);
  o2 = Model_createReaction(M);
  o3 = Model_createReaction(M);
  Reaction_setId(o3,"test");

  fail_unless( Model_removeReaction(M,0) == o1 );
  fail_unless( Model_getNumReactions(M)  == 2  );
  fail_unless( Model_removeReaction(M,0) == o2 );
  fail_unless( Model_getNumReactions(M)  == 1  );
  fail_unless( Model_removeReactionById(M,"test") == o3 );
  fail_unless( Model_getNumReactions(M)  == 0  );

  Reaction_free(o1);
  Reaction_free(o2);
  Reaction_free(o3);
}
END_TEST


START_TEST (test_Model_removeEvent)
{
  Event_t *o1, *o2, *o3;

  o1 = Model_createEvent(M);
  o2 = Model_createEvent(M);
  o3 = Model_createEvent(M);
  Event_setId(o3,"test");

  fail_unless( Model_removeEvent(M,0) == o1 );
  fail_unless( Model_getNumEvents(M)  == 2  );
  fail_unless( Model_removeEvent(M,0) == o2 );
  fail_unless( Model_getNumEvents(M)  == 1  );
  fail_unless( Model_removeEventById(M,"test") == o3 );
  fail_unless( Model_getNumEvents(M)  == 0  );

  Event_free(o1);
  Event_free(o2);
  Event_free(o3);
}
END_TEST


START_TEST (test_Model_conversionFactor)
{
  fail_unless( !Model_isSetConversionFactor(M) );
  int ret = Model_unsetConversionFactor(M);
  fail_unless( ret == LIBSBML_UNEXPECTED_ATTRIBUTE );
}
END_TEST



Suite *
create_suite_Model (void)
{
  Suite *s = suite_create("Model");
  TCase *t = tcase_create("Model");


  tcase_add_checked_fixture(t, ModelTest_setup, ModelTest_teardown);

  tcase_add_test( t, test_Model_create         );
  tcase_add_test( t, test_Model_free_NULL      );
  //tcase_add_test( t, test_Model_createWith     );
  tcase_add_test( t, test_Model_setId          );
  tcase_add_test( t, test_Model_setName        );


  tcase_add_test( t, test_Model_setgetModelHistory        );
  /**
   * Model_createXXX() methods
   */
  tcase_add_test( t, test_Model_createFunctionDefinition               );
  tcase_add_test( t, test_Model_createUnitDefinition                   );
  tcase_add_test( t, test_Model_createUnit                             );
  tcase_add_test( t, test_Model_createUnit_noUnitDefinition            );
  tcase_add_test( t, test_Model_createCompartment                      );
  tcase_add_test( t, test_Model_createCompartmentType                      );
  tcase_add_test( t, test_Model_createConstraint                      );
  tcase_add_test( t, test_Model_createSpeciesType                      );
  tcase_add_test( t, test_Model_createInitialAssignment                      );
  tcase_add_test( t, test_Model_createSpecies                          );
  tcase_add_test( t, test_Model_createParameter                        );
  tcase_add_test( t, test_Model_createAssignmentRule                   );
  tcase_add_test( t, test_Model_createRateRule                         );
  tcase_add_test( t, test_Model_createAlgebraicRule                    );
  tcase_add_test( t, test_Model_createReaction                         );
  tcase_add_test( t, test_Model_createReactant                         );
  tcase_add_test( t, test_Model_createReactant_noReaction              );
  tcase_add_test( t, test_Model_createProduct                          );
  tcase_add_test( t, test_Model_createProduct_noReaction               );
  tcase_add_test( t, test_Model_createModifier                         );
  tcase_add_test( t, test_Model_createModifier_noReaction              );
  tcase_add_test( t, test_Model_createKineticLaw                       );
  tcase_add_test( t, test_Model_createKineticLaw_alreadyExists         );
  tcase_add_test( t, test_Model_createKineticLaw_noReaction            );
  tcase_add_test( t, test_Model_createKineticLawParameter              );
  tcase_add_test( t, test_Model_createKineticLawParameter_noReaction   );
  tcase_add_test( t, test_Model_createKineticLawParameter_noKineticLaw );
  tcase_add_test( t, test_Model_createEvent                            );
  tcase_add_test( t, test_Model_createEventAssignment                  );
  tcase_add_test( t, test_Model_createEventAssignment_noEvent          );

  /**
   * Model_addXXX() methods
   */
  tcase_add_test( t, test_Model_add_get_FunctionDefinitions         );
  tcase_add_test( t, test_Model_add_get_FunctionDefinitions_neg_arg );
  tcase_add_test( t, test_Model_add_get_UnitDefinitions             );
  tcase_add_test( t, test_Model_add_get_UnitDefinitions_neg_arg     );
  tcase_add_test( t, test_Model_addCompartment                      );
  tcase_add_test( t, test_Model_addSpecies                          );
  tcase_add_test( t, test_Model_addParameter                        );
  tcase_add_test( t, test_Model_addRules                            );
  tcase_add_test( t, test_Model_addReaction                         );
  tcase_add_test( t, test_Model_add_get_Event                       );
  tcase_add_test( t, test_Model_add_get_Event_neg_arg               );

  /**
   * Model_getXXX() methods
   */
  tcase_add_test( t, test_Model_getFunctionDefinitionById );
  tcase_add_test( t, test_Model_getUnitDefinition         );
  tcase_add_test( t, test_Model_getUnitDefinitionById     );
  tcase_add_test( t, test_Model_getCompartment            );
  tcase_add_test( t, test_Model_getCompartmentById        );
  tcase_add_test( t, test_Model_getSpecies                );
  tcase_add_test( t, test_Model_getSpeciesById            );
  tcase_add_test( t, test_Model_getSpeciesReferenceById   );
  tcase_add_test( t, test_Model_getParameter              );
  tcase_add_test( t, test_Model_getParameterById          );
  tcase_add_test( t, test_Model_getRules                  );
  tcase_add_test( t, test_Model_getReaction               );
  tcase_add_test( t, test_Model_getReactionById           );
  tcase_add_test( t, test_Model_getEventById              );
 
  tcase_add_test( t, test_KineticLaw_getParameterById              );

  tcase_add_test( t, test_Model_getNumSpeciesWithBoundaryCondition );

  tcase_add_test( t, test_Model_createWithNS         );

  tcase_add_test( t, test_Model_conversionFactor          );

  /**
   * Model_removeXXX() methods
   */
  tcase_add_test( t, test_Model_removeFunctionDefinition  );
  tcase_add_test( t, test_Model_removeUnitDefinition      );
  tcase_add_test( t, test_Model_removeCompartmentType      );
  tcase_add_test( t, test_Model_removeSpeciesType         );
  tcase_add_test( t, test_Model_removeCompartment         );
  tcase_add_test( t, test_Model_removeSpecies             );
  tcase_add_test( t, test_Model_removeParameter           );
  tcase_add_test( t, test_Model_removeInitialAssignment   );
  tcase_add_test( t, test_Model_removeRule                );
  tcase_add_test( t, test_Model_removeConstraint          );
  tcase_add_test( t, test_Model_removeReaction            );
  tcase_add_test( t, test_Model_removeEvent               );

  suite_add_tcase(s, t);

  return s;
}

END_C_DECLS


