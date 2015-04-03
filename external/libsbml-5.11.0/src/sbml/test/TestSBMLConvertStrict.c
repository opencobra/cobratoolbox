/**
 * \file    TestSBMLConvertStrict.c
 * \brief   SBMLConvert unit tests for strict conversion
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
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLTypes.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

START_TEST (test_SBMLConvertStrict_convertNonStrictUnits)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setConstant(c, 0);

  /* create  a parameter with units mole */
  Parameter_t * p = Model_createParameter(m);
  Parameter_setId(p, "p");
  Parameter_setUnits(p, "mole");

  /* create a math element */
  ASTNode_t *math = SBML_parseFormula("p");

  /* create an assignment rule */
  Rule_t *ar = Model_createAssignmentRule(m);
  Rule_setVariable(ar, "c");
  Rule_setMath(ar, math);

  /* these should all fail since the model has bad units */

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 1) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );
  
  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 2) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 3) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );
  
  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  SBMLDocument_free(d);
  ASTNode_free(math);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertNonStrictSBO1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment with SBO */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setConstant(c, 0);
  SBase_setSBOTerm((SBase_t *) (c), 64);

  /* conversion to L2V3 and L2V2 should fail due to bad SBO
   * but to L2V1 and L1 should pass as sbo terms not applicable
   */

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 3) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 2) == 0 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  /* check that sbo term has been removed */
  Compartment_t *c1 = Model_getCompartment(SBMLDocument_getModel(d), 0);

  fail_unless (SBase_getSBOTerm((SBase_t *) (c1)) == -1, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertNonStrictSBO2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment with SBO */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setConstant(c, 0);
  SBase_setSBOTerm((SBase_t *) (c), 64);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );
  
  /* check that sbo term has been removed */
  Compartment_t *c2 = Model_getCompartment(SBMLDocument_getModel(d), 0);

  fail_unless (SBase_getSBOTerm((SBase_t *) (c2)) == -1, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertToL1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  
  /* create model with metaid */
  Model_t * m = SBMLDocument_createModel(d);
  SBase_setMetaId((SBase_t *) (m), "_m");
  
  /* create a compartment with sbo*/
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  SBase_setSBOTerm((SBase_t *) (c), 240);

  /* create a species with hasOnlySubstanceUnits = true*/
  Species_t *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  ///* check that attributes that are no longer valid have been removed */
  Model_t * m1 = SBMLDocument_getModel(d);

  fail_unless (SBase_getMetaId((SBase_t *) (m1)) == NULL);

  Compartment_t *c1 = Model_getCompartment(m1, 0);

  fail_unless (SBase_getSBOTerm((SBase_t *) (c1)) == -1, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertSBO1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment with SBO */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  SBase_setSBOTerm((SBase_t *) (c), 240);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 3) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 3, NULL );
  
  /* check that sbo term has not been removed */
  Compartment_t *c1 = Model_getCompartment(SBMLDocument_getModel(d), 0);

  fail_unless (SBase_getSBOTerm((SBase_t *) (c1)) == 240, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertSBO2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment with SBO */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  SBase_setSBOTerm((SBase_t *) (c), 240);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 2) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  /* check that sbo term has been removed */
  Compartment_t *c1 = Model_getCompartment(SBMLDocument_getModel(d), 0);

  fail_unless (SBase_getSBOTerm((SBase_t *) (c1)) == -1, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertL1ParamRule)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create a compartment */
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");

  /* create  a parameter */
  Parameter_t * p = Model_createParameter(m);
  Parameter_setId(p, "p");
  Parameter_t * p1 = Model_createParameter(m);
  Parameter_setId(p1, "p1");

  /* create a math element */
  ASTNode_t *math = SBML_parseFormula("p");

  /* create an assignment rule */
  Rule_t *ar = Model_createAssignmentRule(m);
  Rule_setVariable(ar, "p1");
  Rule_setMath(ar, math);
  Rule_setUnits(ar, "mole");

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  Rule_t * r1 = Model_getRule(SBMLDocument_getModel(d), 0);

  fail_unless (Rule_getUnits(r1) == NULL );

  SBMLDocument_free(d);
  ASTNode_free(math);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);

  Parameter_t *p = Model_getParameter(m, 0);

  fail_unless(!strcmp(Parameter_getId(p), "parameterId_0"));
  fail_unless(Parameter_getConstant(p) == 0);

  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "parameterId_0"));
  safe_free(mathstr);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);

  Parameter_t *p = Model_getParameter(m, 0);

  fail_unless(!strcmp(Parameter_getId(p), "parameterId_0"));
  fail_unless(Parameter_getConstant(p) == 0);

  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "parameterId_0"));
  safe_free(mathstr);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 0);

  r = Model_getReaction(m, 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(Reaction_getReactant(r, 0)) == 0);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);

  Parameter_t *p = Model_getParameter(m, 0);

  fail_unless(!strcmp(Parameter_getId(p), "parameterId_0"));
  fail_unless(Parameter_getConstant(p) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "parameterId_0"));
  safe_free(mathstr);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath5)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  Rule_t *rule = Rule_createAssignment(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumRules(m) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "0.001"));
  safe_free(mathstr);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath6)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  Rule_t *rule = Rule_createAssignment(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumRules(m) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "0.001"));
  safe_free(mathstr);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath7)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  InitialAssignment_t *ia = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);

  

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumInitialAssignments(m) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "0.001"));
  safe_free(mathstr);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath8)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  InitialAssignment_t *ia = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);

  

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumInitialAssignments(m) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* mathstr = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(mathstr, "0.001"));
  safe_free(mathstr);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_stoichMath9)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setId(sr, "XREF");

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);

  Parameter_t *p = Model_getParameter(m, 0);

  fail_unless(!strcmp(Parameter_getId(p), "parameterId_0"));
  fail_unless(Parameter_getConstant(p) == 0);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* math = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(!strcmp(math, "parameterId_0"));
  safe_free(math);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_spatialDim1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  Compartment_t *p = Model_getCompartment(m, 0);

  fail_unless(!strcmp(Compartment_getId(p), "c"));
  fail_unless(Compartment_getConstant(p) == 1);
  fail_unless(Compartment_getSpatialDimensions(p) == 3);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_spatialDim2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 2);
  Compartment_setConstant(c, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  Compartment_t *p = Model_getCompartment(m, 0);

  fail_unless(!strcmp(Compartment_getId(p), "c"));
  fail_unless(Compartment_getConstant(p) == 1);
  fail_unless(Compartment_getSpatialDimensions(p) == 2);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_spatialDim3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 1);
  Compartment_setConstant(c, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  Compartment_t *p = Model_getCompartment(m, 0);

  fail_unless(!strcmp(Compartment_getId(p), "c"));
  fail_unless(Compartment_getConstant(p) == 1);
  fail_unless(Compartment_getSpatialDimensions(p) == 1);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_spatialDim4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 0);
  Compartment_setConstant(c, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  Compartment_t *p = Model_getCompartment(m, 0);

  fail_unless(!strcmp(Compartment_getId(p), "c"));
  fail_unless(Compartment_getConstant(p) == 1);
  fail_unless(Compartment_getSpatialDimensions(p) == 0);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_spatialDim5)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensionsAsDouble(c, 3.2);
  Compartment_setConstant(c, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 0);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFuncDefsToL1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  
  /* create model */
  Model_t * m = SBMLDocument_createModel(d);
  
  FunctionDefinition_t * fd = Model_createFunctionDefinition(m);
  FunctionDefinition_setId(fd, "fd");
  ASTNode_t *math = SBML_parseFormula("lambda(x, x+2)");
  FunctionDefinition_setMath(fd, math);

  /* create a parameter with sbo*/
  Compartment_t * c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setConstant(c, 0);
  Compartment_setSize(c, 1);

  Rule_t * ar = Model_createAssignmentRule(m);
  ASTNode_t *math1 = SBML_parseFormula("fd(3)");
  Rule_setMath(ar, math1);
  Rule_setVariable(ar, "c");

  fail_unless (Model_getNumFunctionDefinitions(m) == 1);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  Model_t * m1 = SBMLDocument_getModel(d);

  fail_unless (Model_getNumFunctionDefinitions(m1) == 0);

  Rule_t *ar1 = Model_getRule(m1, 0);

  fail_unless (!strcmp(Rule_getFormula(ar1), "3 + 2"));

  SBMLDocument_free(d);
  ASTNode_free(math);
  ASTNode_free(math1);
}
END_TEST

START_TEST (test_SBMLConvertStrict_convertInitialAssignmentsToL2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  
  /* create model */
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create three parameters*/
  Parameter_t * p1 = Model_createParameter(m);
  Parameter_setId(p1, "p1");
  Parameter_setConstant(p1, 1);
  Parameter_setValue(p1, 1);
  Parameter_t * p2 = Model_createParameter(m);
  Parameter_setId(p2, "p2");
  Parameter_setConstant(p2, 1);
  Parameter_setValue(p2, 4.6);
  Parameter_t * p3 = Model_createParameter(m);
  Parameter_setId(p3, "p3");
  Parameter_setConstant(p3, 1);

  Parameter_t * p4 = Model_createParameter(m);
  Parameter_setId(p4, "p4");
  Parameter_setConstant(p4, 1);

  Parameter_t * p5 = Model_createParameter(m);
  Parameter_setId(p5, "p5");
  Parameter_setConstant(p5, 1);

  Parameter_t * p6 = Model_createParameter(m);
  Parameter_setId(p6, "p6");
  Parameter_setConstant(p6, 1);


  /* create initialAssignments */
  InitialAssignment_t *ia1 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia1, "p1");
  ASTNode_t *math = SBML_parseFormula("piecewise(1, and(), 0)");
  InitialAssignment_setMath(ia1, math);

  InitialAssignment_t *ia2 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia2, "p2");
  ASTNode_t *math1 = SBML_parseFormula("piecewise(1, or(), 0)");
  InitialAssignment_setMath(ia2, math1);

  InitialAssignment_t *ia3 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia3, "p3");
  ASTNode_t *math2 = SBML_parseFormula("piecewise(1, xor(),  0)");
  InitialAssignment_setMath(ia3, math2);

 InitialAssignment_t *ia4 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia4, "p4");
  ASTNode_t *math3 = SBML_parseFormula("piecewise(1, and(true), 0)");
  InitialAssignment_setMath(ia4, math3);

  InitialAssignment_t *ia5 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia5, "p5");
  ASTNode_t *math4 = SBML_parseFormula("piecewise(1, or(false), 0)");
  InitialAssignment_setMath(ia5, math4);

  InitialAssignment_t *ia6 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia6, "p6");
  ASTNode_t *math5 = SBML_parseFormula("piecewise(1, xor(true),  0)");
  InitialAssignment_setMath(ia6, math5);

  fail_unless (Model_getNumInitialAssignments(m) == 6);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 2, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  Model_t * m1 = SBMLDocument_getModel(d);

  fail_unless (Model_getNumInitialAssignments(m1) == 0);

  fail_unless (Parameter_getValue(Model_getParameter(m1, 0)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 1)) == 0);
  fail_unless (Parameter_isSetValue(Model_getParameter(m1, 2)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 2)) == 0);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 3)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 4)) == 0);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 5)) == 1);

  SBMLDocument_free(d);
  ASTNode_free(math);
  ASTNode_free(math1);
  ASTNode_free(math2);
  ASTNode_free(math3);
  ASTNode_free(math4);
  ASTNode_free(math5);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertInitialAssignmentsToL1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  
  /* create model */
  Model_t * m = SBMLDocument_createModel(d);
  
  /* create three parameters*/
  Parameter_t * p1 = Model_createParameter(m);
  Parameter_setId(p1, "p1");
  Parameter_setValue(p1, 1);
  Parameter_t * p2 = Model_createParameter(m);
  Parameter_setId(p2, "p2");
  Parameter_setValue(p2, 4.6);
  Parameter_t * p3 = Model_createParameter(m);
  Parameter_setId(p3, "p3");

  /* create initialAssignments */
  InitialAssignment_t *ia1 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia1, "p1");
  ASTNode_t *math = SBML_parseFormula("3/3");
  InitialAssignment_setMath(ia1, math);

  InitialAssignment_t *ia2 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia2, "p2");
  ASTNode_t *math1 = SBML_parseFormula("3 + 2");
  InitialAssignment_setMath(ia2, math1);

  InitialAssignment_t *ia3 = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia3, "p3");
  ASTNode_t *math2 = SBML_parseFormula("pow(2,3)");
  InitialAssignment_setMath(ia3, math2);

  fail_unless (Model_getNumInitialAssignments(m) == 3);

  fail_unless (Parameter_getValue(Model_getParameter(m, 0)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m, 1)) == 4.6);
  fail_unless (Parameter_isSetValue(Model_getParameter(m, 2)) == 0);


  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  Model_t * m1 = SBMLDocument_getModel(d);

  fail_unless (Model_getNumInitialAssignments(m1) == 0);

  fail_unless (Parameter_getValue(Model_getParameter(m1, 0)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 1)) == 5);
  fail_unless (Parameter_isSetValue(Model_getParameter(m1, 2)) == 1);
  fail_unless (Parameter_getValue(Model_getParameter(m1, 2)) == 8);

  SBMLDocument_free(d);
  ASTNode_free(math);
  ASTNode_free(math1);
  ASTNode_free(math2);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L3_stoich)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setStoichiometry(sr, 3.2);


  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 3, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 3, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  m = SBMLDocument_getModel(d);
  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_getStoichiometry(sr) == 3.2);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L3_stoich1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Parameter_t      *p = Model_createParameter(m);
  Parameter_setId(p, "p");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setId(sr, "XREF");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);
  ASTNode_t* math = SBML_parseFormula("p");
  StoichiometryMath_setMath(sm, math);
  ASTNode_free(math);

  fail_unless( Model_getNumRules(m) == 0);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 3, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 3, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  m = SBMLDocument_getModel(d);

  fail_unless( Model_getNumRules(m) == 1);
  fail_unless( strcmp(Rule_getVariable(Model_getRule(m, 0)), "XREF") == 0 );
  
  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometry(sr) == 0);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L3_stoich2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Parameter_t      *p = Model_createParameter(m);
  Parameter_setId(p, "p");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);
  ASTNode_t* math = SBML_parseFormula("p");
  StoichiometryMath_setMath(sm, math);
  ASTNode_free(math);

  fail_unless( Model_getNumRules(m) == 0);
  fail_unless( SpeciesReference_isSetId(sr) == 0);

  fail_unless( SBMLDocument_setLevelAndVersionStrict(d, 3, 1) == 1 );
  fail_unless( SBMLDocument_getLevel  (d) == 3, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  m = SBMLDocument_getModel(d);
  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless( Model_getNumRules(m) == 1);
  fail_unless( strcmp(Rule_getVariable(Model_getRule(m, 0)), 
    SpeciesReference_getId(sr)) == 0 );
  
  fail_unless( SpeciesReference_isSetId(sr) == 1);
  fail_unless(SpeciesReference_isSetStoichiometry(sr) == 0);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL1_L2_stoich)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 3);
  SpeciesReference_setDenominator(sr, 2);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 1);
  char* math = SBML_formulaToString(StoichiometryMath_getMath(
    SpeciesReference_getStoichiometryMath(sr)));
  fail_unless(strcmp(math, "(3/2)") == 0);
  safe_free(math);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 1);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL1_L2_stoich1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 3);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 3);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL1_L3_stoich)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 3);
  SpeciesReference_setDenominator(sr, 2);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 3, 1) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetId(sr) == 1);
  char* math = SBML_formulaToString(InitialAssignment_getMath(
              Model_getInitialAssignment(m, 0)));
  fail_unless(strcmp(math, "(3/2)") == 0);
  safe_free(math);

  fail_unless(strcmp(SpeciesReference_getId(sr), 
              InitialAssignment_getSymbol(Model_getInitialAssignment(m, 0))) == 0);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL1_L3_stoich1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 3);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 3, 1) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetId(sr) == 0);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 3);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L1_stoich)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 2);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_getStoichiometry(sr) == 2);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L1_stoich1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);
  ASTNode_t *ast = ASTNode_create();
  ASTNode_setRational(ast, 5, 2);
  StoichiometryMath_setMath(sm, ast);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 5);
  fail_unless(SpeciesReference_getDenominator(sr) == 2);

  SBMLDocument_free(d);
  ASTNode_free(ast);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L1_stoich2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setStoichiometry(sr, 2.5);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  //m = SBMLDocument_getModel(d);

  //sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  //fail_unless(SpeciesReference_getStoichiometry(sr) == 5);
  //fail_unless(SpeciesReference_getDenominator(sr) == 2);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L1_stoich3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);
  ASTNode_t *ast = ASTNode_create();
  ASTNode_setInteger(ast, 5);
  StoichiometryMath_setMath(sm, ast);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 5);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
  ASTNode_free(ast);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL2_L1_stoich4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);
  ASTNode_t* math = SBML_parseFormula("5/2");
  StoichiometryMath_setMath(sm, math);
  ASTNode_free(math);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  //m = SBMLDocument_getModel(d);

  //sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  //fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  //fail_unless(SpeciesReference_getStoichiometry(sr) == 5);
  //fail_unless(SpeciesReference_getDenominator(sr) == 2);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 1);
  SpeciesReference_setStoichiometry(sr, 1.0);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 1);

  m = SBMLDocument_getModel(d);

  sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  fail_unless(SpeciesReference_getStoichiometry(sr) == 1);
  fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 1);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  //m = SBMLDocument_getModel(d);

  //sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  //fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  //fail_unless(SpeciesReference_getStoichiometry(sr) == 1);
  //fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath5)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  Rule_t *rule = Rule_createAssignment(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath6)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  Rule_t *rule = Rule_createAssignment(3,1);
  Rule_setVariable(rule, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  Rule_setMath(rule, math);
  ASTNode_free(math);
  Model_addRule(m, rule);

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  SBMLDocument_free(d);
  Rule_free(rule);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath7)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  InitialAssignment_t *ia = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);
  

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  //m = SBMLDocument_getModel(d);

  //fail_unless(Model_getNumInitialAssignments(m) == 0);

  //sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  //fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  //fail_unless(SpeciesReference_getStoichiometry(sr) == 1);
  //fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath8)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 0);
  SpeciesReference_setStoichiometry(sr, 1.0);
  InitialAssignment_t *ia = Model_createInitialAssignment(m);
  InitialAssignment_setSymbol(ia, "XREF");
  ASTNode_t* math = SBML_parseFormula("0.001");
  InitialAssignment_setMath(ia, math);
  ASTNode_free(math);
  

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvertStrict_convertFromL3_L1_stoichMath9)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Compartment_setConstant(c, 1);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");
  Species_setHasOnlySubstanceUnits(s, 0);
  Species_setBoundaryCondition(s, 0);
  Species_setConstant(s, 0);
  Reaction_t *r = Model_createReaction(m);
  Reaction_setId(r, "r");
  Reaction_setReversible(r, 0);
  Reaction_setFast(r, 0);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  SpeciesReference_setConstant(sr, 1);
  SpeciesReference_setId(sr, "XREF");

  fail_unless(SBMLDocument_setLevelAndVersionStrict(d, 1, 2) == 0);

  //m = SBMLDocument_getModel(d);


  //sr = Reaction_getReactant(Model_getReaction(m, 0), 0);

  //fail_unless(SpeciesReference_isSetStoichiometryMath(sr) == 0);
  //fail_unless(SpeciesReference_getStoichiometry(sr) == 1);
  //fail_unless(SpeciesReference_getDenominator(sr) == 1);

  SBMLDocument_free(d);
}
END_TEST


Suite *
create_suite_SBMLConvertStrict (void) 
{ 
  Suite *suite = suite_create("SBMLConvertStrict");
  TCase *tcase = tcase_create("SBMLConvertStrict");


  tcase_add_test( tcase, test_SBMLConvertStrict_convertNonStrictUnits       );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertNonStrictSBO1        );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertNonStrictSBO2        );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertToL1                 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertSBO1                 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertSBO2                 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertL1ParamRule          );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath3 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath4 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath5 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath6 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath7 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath8 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_stoichMath9 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_spatialDim1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_spatialDim2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_spatialDim3 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_spatialDim4 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_spatialDim5 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFuncDefsToL1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertInitialAssignmentsToL1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertInitialAssignmentsToL2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L3_stoich );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L3_stoich1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L3_stoich2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL1_L2_stoich );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL1_L2_stoich1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL1_L3_stoich );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL1_L3_stoich1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L1_stoich );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L1_stoich1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L1_stoich2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L1_stoich3 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL2_L1_stoich4 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath1 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath2 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath3 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath4 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath5 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath6 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath7 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath8 );
  tcase_add_test( tcase, test_SBMLConvertStrict_convertFromL3_L1_stoichMath9 );
  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

