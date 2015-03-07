/**
 * \file    TestModel_newSetters.c
 * \brief   Model unit tests for new set function API
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
#include <sbml/math/FormulaParser.h>

#include <sbml/SBase.h>
#include <sbml/Model.h>
#include <sbml/Reaction.h>
#include <sbml/Event.h>
#include <sbml/UnitDefinition.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/CompartmentType.h>
#include <sbml/SpeciesType.h>
#include <sbml/InitialAssignment.h>
#include <sbml/Constraint.h>
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/Rule.h>
#include <sbml/KineticLaw.h>
#include <sbml/Trigger.h>
#include <sbml/annotation/ModelHistory.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>




#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Model_t *M;


void
ModelTest1_setup (void)
{
  M = Model_create(2, 4);

  if (M == NULL)
  {
    fail("Model_create() returned a NULL pointer.");
  }
}


void
ModelTest1_teardown (void)
{
  Model_free(M);
}


START_TEST (test_Model_setId1)
{
  const char *id = "1e1";
  int i = Model_setId(M, id);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Model_isSetId(M) );
}
END_TEST


START_TEST (test_Model_setId2)
{
  const char *id = "e1";
  int i = Model_setId(M, id);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Model_getId(M), id) );
  fail_unless( Model_isSetId(M) );

  i = Model_setId(M, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetId(M) );
}
END_TEST


START_TEST (test_Model_setId3)
{
  const char *id = "e1";
  int i = Model_setId(M, id);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Model_getId(M), id) );
  fail_unless( Model_isSetId(M) );

  i = Model_unsetId(M);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetId(M) );
}
END_TEST


START_TEST (test_Model_setName1)
{
  const char *name = "3Set_k2";

  int i = Model_setName(M, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Model_isSetName(M) );
}
END_TEST


START_TEST (test_Model_setName2)
{
  const char *name = "Set k2";

  int i = Model_setName(M, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Model_getName(M), name) );
  fail_unless( Model_isSetName(M) );

  i = Model_unsetName(M);


  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetName(M) );
}
END_TEST


START_TEST (test_Model_setName3)
{
  int i = Model_setName(M, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetName(M) );
}
END_TEST


START_TEST (test_Model_setName4)
{
  Model_t * m = Model_create(1, 2);
  int i = Model_setName(m, "11dd");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Model_isSetName(m) );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_setModelHistory1)
{
  SBase_setMetaId((SBase_t *) (M), "_001");
  ModelHistory_t *mh = ModelHistory_create();
  int i = Model_setModelHistory(M, mh);

  fail_unless( i == LIBSBML_INVALID_OBJECT );
  fail_unless( !Model_isSetModelHistory(M) );

  i = Model_unsetModelHistory(M);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetModelHistory(M) );

  ModelHistory_free(mh);
}
END_TEST


START_TEST (test_Model_setModelHistory2)
{
  SBase_setMetaId((SBase_t *) (M), "_001");
  int i = Model_setModelHistory(M, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetModelHistory(M) );

  i = Model_unsetModelHistory(M);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Model_isSetModelHistory(M) );

}
END_TEST


START_TEST (test_Model_addFunctionDefinition1)
{
  Model_t *m = Model_create(2, 2);
  FunctionDefinition_t *fd 
    = FunctionDefinition_create(2, 2);

  int i = Model_addFunctionDefinition(m, fd);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  FunctionDefinition_setId(fd, "fd");
  
  i = Model_addFunctionDefinition(m, fd);
  
  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  ASTNode_t* math = SBML_parseFormula("fd");
  FunctionDefinition_setMath(fd, math);
  ASTNode_free(math);
  
  i = Model_addFunctionDefinition(m, fd);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumFunctionDefinitions(m) == 1);

  FunctionDefinition_free(fd);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addFunctionDefinition2)
{
  Model_t *m = Model_create(2, 2);
  FunctionDefinition_t *fd 
    = FunctionDefinition_create(2, 1);
  FunctionDefinition_setId(fd, "fd");
  ASTNode_t* math = SBML_parseFormula("fd");
  FunctionDefinition_setMath(fd, math);
  ASTNode_free(math);

  int i = Model_addFunctionDefinition(m, fd);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumFunctionDefinitions(m) == 0);

  FunctionDefinition_free(fd);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addFunctionDefinition3)
{
  Model_t *m = Model_create(2, 2);
  FunctionDefinition_t *fd = NULL; 

  int i = Model_addFunctionDefinition(m, fd);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumFunctionDefinitions(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addFunctionDefinition4)
{
  Model_t *m = Model_create(2, 2);
  FunctionDefinition_t *fd 
    = FunctionDefinition_create(2, 2);
  FunctionDefinition_setId(fd, "fd");
  ASTNode_t* math = SBML_parseFormula("fd");
  FunctionDefinition_setMath(fd, math);
  ASTNode_free(math);
  FunctionDefinition_t *fd1 
    = FunctionDefinition_create(2, 2);
  FunctionDefinition_setId(fd1, "fd");
  math = SBML_parseFormula("fd");
  FunctionDefinition_setMath(fd1, math);
  ASTNode_free(math);

  int i = Model_addFunctionDefinition(m, fd);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumFunctionDefinitions(m) == 1);

  i = Model_addFunctionDefinition(m, fd1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumFunctionDefinitions(m) == 1);

  FunctionDefinition_free(fd);
  FunctionDefinition_free(fd1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartmentType1)
{
  Model_t *m = Model_create(2, 2);
  CompartmentType_t *ct 
    = CompartmentType_create(2, 2);

  int i = Model_addCompartmentType(m, ct);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  CompartmentType_setId(ct, "ct");

  i = Model_addCompartmentType(m, ct);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumCompartmentTypes(m) == 1);

  CompartmentType_free(ct);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartmentType2)
{
  Model_t *m = Model_create(2, 2);
  CompartmentType_t *ct 
    = CompartmentType_create(2, 3);
  CompartmentType_setId(ct, "ct");

  int i = Model_addCompartmentType(m, ct);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumCompartmentTypes(m) == 0);

  CompartmentType_free(ct);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartmentType3)
{
  Model_t *m = Model_create(2, 2);
  CompartmentType_t *ct = NULL; 

  int i = Model_addCompartmentType(m, ct);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumCompartmentTypes(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartmentType4)
{
  Model_t *m = Model_create(2, 2);
  CompartmentType_t *ct 
    = CompartmentType_create(2, 2);
  CompartmentType_setId(ct, "ct");
  CompartmentType_t *ct1 
    = CompartmentType_create(2, 2);
  CompartmentType_setId(ct1, "ct");

  int i = Model_addCompartmentType(m, ct);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumCompartmentTypes(m) == 1);

  i = Model_addCompartmentType(m, ct1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumCompartmentTypes(m) == 1);

  CompartmentType_free(ct);
  CompartmentType_free(ct1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpeciesType1)
{
  Model_t *m = Model_create(2, 2);
  SpeciesType_t *st 
    = SpeciesType_create(2, 2);

  int i = Model_addSpeciesType(m, st);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  SpeciesType_setId(st, "st");
  
  i = Model_addSpeciesType(m, st);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumSpeciesTypes(m) == 1);

  SpeciesType_free(st);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpeciesType2)
{
  Model_t *m = Model_create(2, 2);
  SpeciesType_t *st 
    = SpeciesType_create(2, 3);
  SpeciesType_setId(st, "st");

  int i = Model_addSpeciesType(m, st);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumSpeciesTypes(m) == 0);

  SpeciesType_free(st);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpeciesType3)
{
  Model_t *m = Model_create(2, 2);
  SpeciesType_t *st = NULL; 

  int i = Model_addSpeciesType(m, st);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumSpeciesTypes(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpeciesType4)
{
  Model_t *m = Model_create(2, 2);
  SpeciesType_t *st 
    = SpeciesType_create(2, 2);
  SpeciesType_setId(st, "st");
  SpeciesType_t *st1 
    = SpeciesType_create(2, 2);
  SpeciesType_setId(st1, "st");

  int i = Model_addSpeciesType(m, st);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumSpeciesTypes(m) == 1);

  i = Model_addSpeciesType(m, st1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumSpeciesTypes(m) == 1);

  SpeciesType_free(st);
  SpeciesType_free(st1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addInitialAssignment1)
{
  Model_t *m = Model_create(2, 2);
  InitialAssignment_t *ia 
    = InitialAssignment_create(2, 2);

  int i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  InitialAssignment_setSymbol(ia, "i");
  i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  ASTNode_t* math = SBML_parseFormula("gg");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);
  i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumInitialAssignments(m) == 1);

  InitialAssignment_free(ia);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addInitialAssignment2)
{
  Model_t *m = Model_create(2, 2);
  InitialAssignment_t *ia 
    = InitialAssignment_create(2, 3);
  InitialAssignment_setSymbol(ia, "i");
  ASTNode_t* math = SBML_parseFormula("gg");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);

  int i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumInitialAssignments(m) == 0);

  InitialAssignment_free(ia);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addInitialAssignment3)
{
  Model_t *m = Model_create(2, 2);
  InitialAssignment_t *ia = NULL; 

  int i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumInitialAssignments(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addInitialAssignment4)
{
  Model_t *m = Model_create(2, 2);
  InitialAssignment_t *ia 
    = InitialAssignment_create(2, 2);
  InitialAssignment_setSymbol(ia, "ia");
  ASTNode_t* math = SBML_parseFormula("a+b");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);
  InitialAssignment_t *ia1 
    = InitialAssignment_create(2, 2);
  InitialAssignment_setSymbol(ia1, "ia");
  math = SBML_parseFormula("a+b");
  InitialAssignment_setMath(ia1, math);
  ASTNode_free(math);

  int i = Model_addInitialAssignment(m, ia);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumInitialAssignments(m) == 1);

  i = Model_addInitialAssignment(m, ia1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumInitialAssignments(m) == 1);

  InitialAssignment_free(ia);
  InitialAssignment_free(ia1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addConstraint1)
{
  Model_t *m = Model_create(2, 2);
  Constraint_t *c 
    = Constraint_create(2, 2);

  int i = Model_addConstraint(m, c);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  ASTNode_t* math = SBML_parseFormula("a+b");
  Constraint_setMath(c, math);
  ASTNode_free(math);
  i = Model_addConstraint(m, c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumConstraints(m) == 1);

  Constraint_free(c);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addConstraint2)
{
  Model_t *m = Model_create(2, 2);
  Constraint_t *c 
    = Constraint_create(2, 3);
  ASTNode_t* math = SBML_parseFormula("a+b");
  Constraint_setMath(c, math);
  ASTNode_free(math);

  int i = Model_addConstraint(m, c);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumConstraints(m) == 0);

  Constraint_free(c);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addConstraint3)
{
  Model_t *m = Model_create(2, 2);
  Constraint_t *c = NULL; 

  int i = Model_addConstraint(m, c);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumConstraints(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addEvent1)
{
  Model_t *m = Model_create(2, 2);
  Event_t *e 
    = Event_create(2, 2);
  Trigger_t *t 
    = Trigger_create(2, 2);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);

  int i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Event_setTrigger(e, t);
  i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  Event_createEventAssignment(e);
  i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumEvents(m) == 1);

  Event_free(e);
  Model_free(m);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_addEvent2)
{
  Model_t *m = Model_create(2, 2);
  Event_t *e 
    = Event_create(2, 1);
  Trigger_t *t 
    = Trigger_create(2, 1);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Event_setTrigger(e, t);
  Event_createEventAssignment(e);

  int i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumEvents(m) == 0);

  Event_free(e);
  Model_free(m);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_addEvent3)
{
  Model_t *m = Model_create(2, 2);
  Event_t *e = NULL; 

  int i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumEvents(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addEvent4)
{
  Model_t *m = Model_create(2, 2);
  Event_t *e 
    = Event_create(2, 2);
  Trigger_t *t 
    = Trigger_create(2, 2);
  ASTNode_t* math = SBML_parseFormula("true");
  Trigger_setMath(t, math);
  ASTNode_free(math);
  Event_setId(e, "e");
  Event_setTrigger(e, t);
  Event_createEventAssignment(e);
  Event_t *e1 
    = Event_create(2, 2);
  Event_setId(e1, "e");
  Event_setTrigger(e1, t);
  Event_createEventAssignment(e1);

  int i = Model_addEvent(m, e);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumEvents(m) == 1);

  i = Model_addEvent(m, e1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumEvents(m) == 1);

  Event_free(e);
  Event_free(e1);
  Model_free(m);
  Trigger_free(t);
}
END_TEST


START_TEST (test_Model_addUnitDefinition1)
{
  Model_t *m = Model_create(2, 2);
  UnitDefinition_t *ud 
    = UnitDefinition_create(2, 2);

  int i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  UnitDefinition_createUnit(ud);
  i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  UnitDefinition_setId(ud, "ud");
  i = Model_addUnitDefinition(m, ud);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumUnitDefinitions(m) == 1);

  UnitDefinition_free(ud);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addUnitDefinition2)
{
  Model_t *m = Model_create(2, 2);
  UnitDefinition_t *ud 
    = UnitDefinition_create(2, 1);
  UnitDefinition_createUnit(ud);
  UnitDefinition_setId(ud, "ud");

  int i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumUnitDefinitions(m) == 0);

  UnitDefinition_free(ud);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addUnitDefinition3)
{
  Model_t *m = Model_create(2, 2);
  UnitDefinition_t *ud 
    = UnitDefinition_create(1, 2);
  UnitDefinition_createUnit(ud);
  UnitDefinition_setId(ud, "ud");

  int i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumUnitDefinitions(m) == 0);

  UnitDefinition_free(ud);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addUnitDefinition4)
{
  Model_t *m = Model_create(2, 2);
  UnitDefinition_t *ud = NULL; 

  int i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumUnitDefinitions(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addUnitDefinition5)
{
  Model_t *m = Model_create(2, 2);
  UnitDefinition_t *ud 
    = UnitDefinition_create(2, 2);
  UnitDefinition_setId(ud, "ud");
  UnitDefinition_createUnit(ud);
  UnitDefinition_t *ud1 
    = UnitDefinition_create(2, 2);
  UnitDefinition_setId(ud1, "ud");
  UnitDefinition_createUnit(ud1);

  int i = Model_addUnitDefinition(m, ud);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumUnitDefinitions(m) == 1);

  i = Model_addUnitDefinition(m, ud1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumUnitDefinitions(m) == 1);

  UnitDefinition_free(ud);
  UnitDefinition_free(ud1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartment1)
{
  Model_t *m = Model_create(2, 2);
  Compartment_t *c 
    = Compartment_create(2, 2);

  int i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  Compartment_setId(c, "c");
  i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumCompartments(m) == 1);

  Compartment_free(c);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartment2)
{
  Model_t *m = Model_create(2, 2);
  Compartment_t *c 
    = Compartment_create(2, 1);
  Compartment_setId(c, "c");

  int i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumCompartments(m) == 0);

  Compartment_free(c);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartment3)
{
  Model_t *m = Model_create(2, 2);
  Compartment_t *c 
    = Compartment_create(1, 2);
  Compartment_setId(c, "c");

  int i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumCompartments(m) == 0);

  Compartment_free(c);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartment4)
{
  Model_t *m = Model_create(2, 2);
  Compartment_t *c = NULL; 

  int i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumCompartments(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addCompartment5)
{
  Model_t *m = Model_create(2, 2);
  Compartment_t *c 
    = Compartment_create(2, 2);
  Compartment_setId(c, "c");
  Compartment_t *c1 
    = Compartment_create(2, 2);
  Compartment_setId(c1, "c");

  int i = Model_addCompartment(m, c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumCompartments(m) == 1);

  i = Model_addCompartment(m, c1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumCompartments(m) == 1);

  Compartment_free(c);
  Compartment_free(c1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpecies1)
{
  Model_t *m = Model_create(2, 2);
  Species_t *s 
    = Species_create(2, 2);

  int i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  Species_setId(s, "s");
  i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_INVALID_OBJECT);

  Species_setCompartment(s, "c");
  i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumSpecies(m) == 1);

  Species_free(s);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpecies2)
{
  Model_t *m = Model_create(2, 2);
  Species_t *s 
    = Species_create(2, 1);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");

  int i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumSpecies(m) == 0);

  Species_free(s);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpecies3)
{
  Model_t *m = Model_create(2, 2);
  Species_t *s 
    = Species_create(1, 2);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setInitialAmount(s, 2);

  int i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumSpecies(m) == 0);

  Species_free(s);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpecies4)
{
  Model_t *m = Model_create(2, 2);
  Species_t *s = NULL; 

  int i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumSpecies(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addSpecies5)
{
  Model_t *m = Model_create(2, 2);
  Species_t *s 
    = Species_create(2, 2);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_t *s1 
    = Species_create(2, 2);
  Species_setId(s1, "s");
  Species_setCompartment(s1, "c");

  int i = Model_addSpecies(m, s);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumSpecies(m) == 1);

  i = Model_addSpecies(m, s1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumSpecies(m) == 1);

  Species_free(s);
  Species_free(s1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addParameter1)
{
  Model_t *m = Model_create(2, 2);
  Parameter_t *p 
    = Parameter_create(2, 2);

  int i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Parameter_setId(p, "p");
  i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumParameters(m) == 1);

  Parameter_free(p);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addParameter2)
{
  Model_t *m = Model_create(2, 2);
  Parameter_t *p 
    = Parameter_create(2, 1);
  Parameter_setId(p, "p");

  int i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumParameters(m) == 0);

  Parameter_free(p);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addParameter3)
{
  Model_t *m = Model_create(2, 2);
  Parameter_t *p 
    = Parameter_create(1, 2);
  Parameter_setId(p, "p");

  int i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumParameters(m) == 0);

  Parameter_free(p);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addParameter4)
{
  Model_t *m = Model_create(2, 2);
  Parameter_t *p = NULL; 

  int i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumParameters(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addParameter5)
{
  Model_t *m = Model_create(2, 2);
  Parameter_t *p 
    = Parameter_create(2, 2);
  Parameter_setId(p, "p");
  Parameter_t *p1 
    = Parameter_create(2, 2);
  Parameter_setId(p1, "p");

  int i = Model_addParameter(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumParameters(m) == 1);

  i = Model_addParameter(m, p1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumParameters(m) == 1);

  Parameter_free(p);
  Parameter_free(p1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addRule1)
{
  Model_t *m = Model_create(2, 2);
  Rule_t *r 
    = Rule_createAssignment(2, 2);

  int i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Rule_setVariable(r, "f");
  i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  ASTNode_t* math = SBML_parseFormula("a-n");
  Rule_setMath(r, math);
  ASTNode_free(math);
  i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumRules(m) == 1);

  Rule_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addRule2)
{
  Model_t *m = Model_create(2, 2);
  Rule_t *r 
    = Rule_createAssignment(2, 1);
  Rule_setVariable(r, "f");
  ASTNode_t* math = SBML_parseFormula("a-n");
  Rule_setMath(r, math);
  ASTNode_free(math);

  int i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumRules(m) == 0);

  Rule_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addRule3)
{
  Model_t *m = Model_create(2, 2);
  Rule_t *r 
    = Rule_createAssignment(1, 2);
  Rule_setVariable(r, "f");
  ASTNode_t* math = SBML_parseFormula("a-n");
  Rule_setMath(r, math);
  ASTNode_free(math);

  int i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumRules(m) == 0);

  Rule_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addRule4)
{
  Model_t *m = Model_create(2, 2);
  Rule_t *r = NULL; 

  int i = Model_addRule(m, r);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumRules(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addRule5)
{
  Model_t *m = Model_create(2, 2);
  Rule_t *ar 
    = Rule_createAssignment(2, 2);
  Rule_setVariable(ar, "ar");
  ASTNode_t* math = SBML_parseFormula("a-j");
  Rule_setMath(ar, math);
  ASTNode_free(math);
  Rule_t *ar1 
    = Rule_createAssignment(2, 2);
  Rule_setVariable(ar1, "ar");
  math = SBML_parseFormula("a-j");
  Rule_setMath(ar1, math);
  ASTNode_free(math);

  int i = Model_addRule(m, ar);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumRules(m) == 1);

  i = Model_addRule(m, ar1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumRules(m) == 1);

  Rule_free(ar);
  Rule_free(ar1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addReaction1)
{
  Model_t *m = Model_create(2, 2);
  Reaction_t *r 
    = Reaction_create(2, 2);

  int i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Reaction_setId(r, "r");
  i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumReactions(m) == 1);

  Reaction_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addReaction2)
{
  Model_t *m = Model_create(2, 2);
  Reaction_t *r 
    = Reaction_create(2, 1);
  Reaction_setId(r, "r");

  int i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Model_getNumReactions(m) == 0);

  Reaction_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addReaction3)
{
  Model_t *m = Model_create(2, 2);
  Reaction_t *r 
    = Reaction_create(1, 2);
  Reaction_setId(r, "r");

  int i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Model_getNumReactions(m) == 0);

  Reaction_free(r);
  Model_free(m);
}
END_TEST


START_TEST (test_Model_addReaction4)
{
  Model_t *m = Model_create(2, 2);
  Reaction_t *r = NULL; 

  int i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Model_getNumReactions(m) == 0);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_addReaction5)
{
  Model_t *m = Model_create(2, 2);
  Reaction_t *r 
    = Reaction_create(2, 2);
  Reaction_setId(r, "r");
  Reaction_t *r1 
    = Reaction_create(2, 2);
  Reaction_setId(r1, "r");

  int i = Model_addReaction(m, r);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Model_getNumReactions(m) == 1);

  i = Model_addReaction(m, r1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Model_getNumReactions(m) == 1);

  Reaction_free(r);
  Reaction_free(r1);

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createFunctionDefinition)
{
  Model_t *m = Model_create(2, 2);
  
  FunctionDefinition_t *p = Model_createFunctionDefinition(m);

  fail_unless( Model_getNumFunctionDefinitions(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createUnitDefinition)
{
  Model_t *m = Model_create(2, 2);
  
  UnitDefinition_t *p = Model_createUnitDefinition(m);

  fail_unless( Model_getNumUnitDefinitions(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createCompartmentType)
{
  Model_t *m = Model_create(2, 2);
  
  CompartmentType_t *p = Model_createCompartmentType(m);

  fail_unless( Model_getNumCompartmentTypes(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createSpeciesType)
{
  Model_t *m = Model_create(2, 2);
  
  SpeciesType_t *p = Model_createSpeciesType(m);

  fail_unless( Model_getNumSpeciesTypes(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createCompartment)
{
  Model_t *m = Model_create(2, 2);
  
  Compartment_t *p = Model_createCompartment(m);

  fail_unless( Model_getNumCompartments(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createSpecies)
{
  Model_t *m = Model_create(2, 2);
  
  Species_t *p = Model_createSpecies(m);

  fail_unless( Model_getNumSpecies(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createParameter)
{
  Model_t *m = Model_create(2, 2);
  
  Parameter_t *p = Model_createParameter(m);

  fail_unless( Model_getNumParameters(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createInitialAssignment)
{
  Model_t *m = Model_create(2, 2);
  
  InitialAssignment_t *p = Model_createInitialAssignment(m);

  fail_unless( Model_getNumInitialAssignments(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createRule)
{
  Model_t *m = Model_create(2, 2);
  
  Rule_t *p = Model_createAssignmentRule(m);

  fail_unless( Model_getNumRules(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createConstraint)
{
  Model_t *m = Model_create(2, 2);
  
  Constraint_t *p = Model_createConstraint(m);

  fail_unless( Model_getNumConstraints(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createReaction)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *p = Model_createReaction(m);

  fail_unless( Model_getNumReactions(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createEvent)
{
  Model_t *m = Model_create(2, 2);
  
  Event_t *p = Model_createEvent(m);

  fail_unless( Model_getNumEvents(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createUnit)
{
  Model_t *m = Model_create(2, 2);
  
  UnitDefinition_t *p = Model_createUnitDefinition(m);
  Unit_t *u = Model_createUnit(m);

  fail_unless( UnitDefinition_getNumUnits(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (u)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (u)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createReactant)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *p = Model_createReaction(m);
  SpeciesReference_t *sr = Model_createReactant(m);

  fail_unless( Reaction_getNumReactants(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (sr)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (sr)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createProduct)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *p = Model_createReaction(m);
  SpeciesReference_t *sr = Model_createProduct(m);

  fail_unless( Reaction_getNumProducts(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (sr)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (sr)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createModifier)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *p = Model_createReaction(m);
  SpeciesReference_t *sr = Model_createModifier(m);

  fail_unless( Reaction_getNumModifiers(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (sr)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (sr)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createKineticLaw)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *p = Model_createReaction(m);
  KineticLaw_t *kl = Model_createKineticLaw(m);

  fail_unless( Reaction_isSetKineticLaw(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (kl)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (kl)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createKineticLawParameters)
{
  Model_t *m = Model_create(2, 2);
  
  Reaction_t *r = Model_createReaction(m);
  KineticLaw_t *kl = Model_createKineticLaw(m);
  Parameter_t *p = Model_createKineticLawParameter(m);

  fail_unless( Reaction_isSetKineticLaw(r) == 1);
  fail_unless( KineticLaw_getNumParameters(kl) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Model_free(m);
}
END_TEST


START_TEST (test_Model_createEventAssignment)
{
  Model_t *m = Model_create(2, 2);
  
  Event_t *p = Model_createEvent(m);
  EventAssignment_t *ea = Model_createEventAssignment(m);

  fail_unless( Event_getNumEventAssignments(p) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (ea)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (ea)) == 2 );

  Model_free(m);
}
END_TEST


Suite *
create_suite_Model_newSetters (void)
{
  Suite *suite = suite_create("Model_newSetters");
  TCase *tcase = tcase_create("Model_newSetters");


  tcase_add_checked_fixture( tcase,
                             ModelTest1_setup,
                             ModelTest1_teardown );

  tcase_add_test( tcase, test_Model_setId1        );
  tcase_add_test( tcase, test_Model_setId2        );
  tcase_add_test( tcase, test_Model_setId3        );
  tcase_add_test( tcase, test_Model_setName1      );
  tcase_add_test( tcase, test_Model_setName2      );
  tcase_add_test( tcase, test_Model_setName3      );
  tcase_add_test( tcase, test_Model_setName4      );
  tcase_add_test( tcase, test_Model_setModelHistory1 );
  tcase_add_test( tcase, test_Model_setModelHistory2 );
  tcase_add_test( tcase, test_Model_addFunctionDefinition1        );
  tcase_add_test( tcase, test_Model_addFunctionDefinition2        );
  tcase_add_test( tcase, test_Model_addFunctionDefinition3        );
  tcase_add_test( tcase, test_Model_addFunctionDefinition4        );
  tcase_add_test( tcase, test_Model_addCompartmentType1        );
  tcase_add_test( tcase, test_Model_addCompartmentType2        );
  tcase_add_test( tcase, test_Model_addCompartmentType3        );
  tcase_add_test( tcase, test_Model_addCompartmentType4        );
  tcase_add_test( tcase, test_Model_addSpeciesType1        );
  tcase_add_test( tcase, test_Model_addSpeciesType2        );
  tcase_add_test( tcase, test_Model_addSpeciesType3        );
  tcase_add_test( tcase, test_Model_addSpeciesType4        );
  tcase_add_test( tcase, test_Model_addInitialAssignment1        );
  tcase_add_test( tcase, test_Model_addInitialAssignment2        );
  tcase_add_test( tcase, test_Model_addInitialAssignment3        );
  tcase_add_test( tcase, test_Model_addInitialAssignment4        );
  tcase_add_test( tcase, test_Model_addConstraint1        );
  tcase_add_test( tcase, test_Model_addConstraint2        );
  tcase_add_test( tcase, test_Model_addConstraint3        );
  tcase_add_test( tcase, test_Model_addEvent1        );
  tcase_add_test( tcase, test_Model_addEvent2        );
  tcase_add_test( tcase, test_Model_addEvent3        );
  tcase_add_test( tcase, test_Model_addEvent4        );
  tcase_add_test( tcase, test_Model_addUnitDefinition1        );
  tcase_add_test( tcase, test_Model_addUnitDefinition2        );
  tcase_add_test( tcase, test_Model_addUnitDefinition3        );
  tcase_add_test( tcase, test_Model_addUnitDefinition4        );
  tcase_add_test( tcase, test_Model_addUnitDefinition5        );
  tcase_add_test( tcase, test_Model_addCompartment1        );
  tcase_add_test( tcase, test_Model_addCompartment2        );
  tcase_add_test( tcase, test_Model_addCompartment3        );
  tcase_add_test( tcase, test_Model_addCompartment4        );
  tcase_add_test( tcase, test_Model_addCompartment5        );
  tcase_add_test( tcase, test_Model_addSpecies1        );
  tcase_add_test( tcase, test_Model_addSpecies2        );
  tcase_add_test( tcase, test_Model_addSpecies3        );
  tcase_add_test( tcase, test_Model_addSpecies4        );
  tcase_add_test( tcase, test_Model_addSpecies5        );
  tcase_add_test( tcase, test_Model_addParameter1        );
  tcase_add_test( tcase, test_Model_addParameter2        );
  tcase_add_test( tcase, test_Model_addParameter3        );
  tcase_add_test( tcase, test_Model_addParameter4        );
  tcase_add_test( tcase, test_Model_addParameter5        );
  tcase_add_test( tcase, test_Model_addRule1        );
  tcase_add_test( tcase, test_Model_addRule2        );
  tcase_add_test( tcase, test_Model_addRule3        );
  tcase_add_test( tcase, test_Model_addRule4        );
  tcase_add_test( tcase, test_Model_addRule5        );
  tcase_add_test( tcase, test_Model_addReaction1        );
  tcase_add_test( tcase, test_Model_addReaction2        );
  tcase_add_test( tcase, test_Model_addReaction3        );
  tcase_add_test( tcase, test_Model_addReaction4        );
  tcase_add_test( tcase, test_Model_addReaction5        );
  tcase_add_test( tcase, test_Model_createFunctionDefinition     );
  tcase_add_test( tcase, test_Model_createUnitDefinition     );
  tcase_add_test( tcase, test_Model_createCompartmentType     );
  tcase_add_test( tcase, test_Model_createSpeciesType     );
  tcase_add_test( tcase, test_Model_createCompartment     );
  tcase_add_test( tcase, test_Model_createSpecies     );
  tcase_add_test( tcase, test_Model_createParameter     );
  tcase_add_test( tcase, test_Model_createInitialAssignment     );
  tcase_add_test( tcase, test_Model_createRule     );
  tcase_add_test( tcase, test_Model_createConstraint     );
  tcase_add_test( tcase, test_Model_createReaction     );
  tcase_add_test( tcase, test_Model_createEvent     );
  tcase_add_test( tcase, test_Model_createUnit     );
  tcase_add_test( tcase, test_Model_createReactant     );
  tcase_add_test( tcase, test_Model_createProduct     );
  tcase_add_test( tcase, test_Model_createModifier     );
  tcase_add_test( tcase, test_Model_createKineticLaw     );
  tcase_add_test( tcase, test_Model_createKineticLawParameters     );
  tcase_add_test( tcase, test_Model_createEventAssignment     );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


