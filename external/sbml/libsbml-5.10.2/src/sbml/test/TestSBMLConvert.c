/**
 * \file    TestSBMLConvert.c
 * \brief   SBMLConvert unit tests
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
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLTypes.h>
#include <sbml/SpeciesReference.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

START_TEST (test_SBMLConvert_invalidLevelVersion)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Compartment_t  *c = Model_createCompartment(m);

  Compartment_setId   ( c, sid );
  Compartment_setSize ( c, 1.2 ); 
  Compartment_setUnits( c, "volume");

  fail_unless(SBMLDocument_setLevelAndVersion(d, 1, 3) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 5) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 3, 2) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 4, 1) == 0);

}
END_TEST


START_TEST (test_SBMLConvert_convertFromL1_addModifiersToReaction)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Reaction_t     *r = Model_createReaction(m);
  KineticLaw_t  *kl = Reaction_createKineticLaw(r);
  KineticLaw_setFormula(kl, "k1*S1*S2*S3*S4*S5");

  SpeciesReference_t *ssr1;
  SpeciesReference_t *ssr2;


  Species_t *s1 = Model_createSpecies( m ); 
  Species_setId( s1, "S1" );
  Species_t *s2 = Model_createSpecies( m ); 
  Species_setId( s2, "S2");
  Species_t *s3 = Model_createSpecies( m ); 
  Species_setId( s3, "S3");
  Species_t *s4 = Model_createSpecies( m ); 
  Species_setId( s4, "S4");
  Species_t *s5 = Model_createSpecies( m ); 
  Species_setId( s5, "S5");

  SpeciesReference_t *sr1 = Reaction_createReactant( r );
  SpeciesReference_t *sr2 = Reaction_createReactant( r );
  SpeciesReference_t *sr3 = Reaction_createProduct ( r );

  SpeciesReference_setSpecies(sr1, "S1");
  SpeciesReference_setSpecies(sr2, "S2");
  SpeciesReference_setSpecies(sr3, "S5");

  fail_unless( Reaction_getNumModifiers(r) == 0, NULL );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );


  fail_unless( Reaction_getNumModifiers(Model_getReaction(m, 0)) == 2, NULL );

  ssr1 = (SpeciesReference_t *) Reaction_getModifier(Model_getReaction(m, 0), 0);
  ssr2 = (SpeciesReference_t *) Reaction_getModifier(Model_getReaction(m, 0), 1);

  fail_unless( !strcmp(SpeciesReference_getSpecies(ssr1), "S3"), NULL );
  fail_unless( !strcmp(SpeciesReference_getSpecies(ssr2), "S4"), NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL1_varyingComp)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Rule_t         *r = Model_createAssignmentRule(m);

  Compartment_setName(c, "c");
  Rule_setVariable(r, "c");
  Rule_setFormula(r, "1*2");

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  fail_unless( Compartment_getConstant(Model_getCompartment(m, 0)) == 0, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL1_varyingParam)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Parameter_t    *p = Model_createParameter(m);
  Rule_t         *r = Model_createAssignmentRule(m);

  Parameter_setName(p, "c");
  Rule_setVariable(r, "c");
  Rule_setFormula(r, "1*2");

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  fail_unless( Parameter_getConstant(Model_getParameter(m, 0)) == 0, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL2_SBMLDocument)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);


  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  d = SBMLDocument_createWithLevelAndVersion(1, 2);
  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  d = SBMLDocument_createWithLevelAndVersion(1, 2);
  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 3, NULL );

  d = SBMLDocument_createWithLevelAndVersion(1, 2);
  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );
  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL1_SBMLDocument)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1, NULL);

  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 2, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL1_noCompartment)
{
  SBMLDocument_t *d   = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t        *m   = SBMLDocument_createModel(d);
  Parameter_t    *c   = Model_createParameter(m);


  Parameter_setId   ( c, "p" );
  
  fail_unless( Model_getNumCompartments(m) == 0, NULL );


  fail_unless( SBMLDocument_setLevelAndVersion(d, 1, 2) == 1, NULL );

  fail_unless( Model_getNumCompartments(m) == 1, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL1_Species_Amount)
{
  SBMLDocument_t *d   = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t        *m   = SBMLDocument_createModel(d);
  const char     *sid = "C";
  Compartment_t  *c   = Compartment_create(2, 4);
  Species_t      *s   = Species_create(2, 4);


  Compartment_setId   ( c, sid );
  Model_addCompartment( m, c   );

  Species_setCompartment  ( s, sid  ); 
  Species_setInitialAmount( s, 2.34 );
  Model_addSpecies        ( m, s    );
  
  fail_unless( SBMLDocument_setLevelAndVersion(d, 1, 2) == 1, NULL );

  fail_unless( Species_getInitialAmount(s) == 2.34, NULL );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL1_Species_Concentration)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  const char   *sid = "C";
  Compartment_t  *c = 
    Compartment_create(2, 1);
  Species_t      *s = 
    Species_create(2, 1);


  Compartment_setId   ( c, sid );
  Compartment_setSize ( c, 1.2 ); 
  Model_addCompartment( m, c   );

  Species_setId                  ( s, "s"  );
  Species_setCompartment         ( s, sid  ); 
  Species_setInitialConcentration( s, 2.34 );
  Model_addSpecies               ( m, s    );
  
  fail_unless( SBMLDocument_setLevelAndVersion(d, 1, 2) == 1, NULL);

  fail_unless( 
    util_isEqual(
    Species_getInitialAmount(Model_getSpecies(m, 0)),
    2.808)
    );

  Species_t * s1 = Model_getSpecies(m, 0);
  fail_unless (s1 != NULL);
  fail_unless (!strcmp(Species_getCompartment(s1), "C"));
  fail_unless(Compartment_getSize(Model_getCompartmentById(m, "C")) == 1.2);
  fail_unless(Species_getInitialConcentration(s1) == 2.34);
  fail_unless(Species_isSetInitialConcentration(s1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL2v4_DuplicateAnnotations_doc)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  SBMLDocument_createModel(d);

  const char * annotation = "<rdf/>\n<rdf/>";

  int i = SBase_setAnnotationString((SBase_t *) (d), annotation);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );
  fail_unless( XMLNode_getNumChildren(SBase_getAnnotation((SBase_t *) (d))) == 2);

  fail_unless( SBMLDocument_setLevelAndVersion(d, 2, 4) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  fail_unless( XMLNode_getNumChildren(SBase_getAnnotation((SBase_t *) (d))) == 1);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL2v4_DuplicateAnnotations_model)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  Model_t * m = SBMLDocument_createModel(d);

  const char * annotation = "<rdf/>\n<rdf/>";

  int i = SBase_setAnnotationString((SBase_t *) (m), annotation);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );
  fail_unless( XMLNode_getNumChildren(SBase_getAnnotation((SBase_t *) (m))) == 2);

  fail_unless( SBMLDocument_setLevelAndVersion(d, 2, 4) == 1, NULL );

  fail_unless( SBMLDocument_getLevel  (d) == 2, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 4, NULL );

  m = SBMLDocument_getModel(d);
  fail_unless( XMLNode_getNumChildren(SBase_getAnnotation((SBase_t *) (m))) == 1);


  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_defaultUnits)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Compartment_t  *c = Model_createCompartment(m);

  Compartment_setId   ( c, sid );
  Compartment_setSize ( c, 1.2 ); 
  Compartment_setUnits( c, "volume");

  fail_unless(Model_getNumUnitDefinitions(m) == 0);
  
  fail_unless( SBMLDocument_setLevelAndVersion(d, 3, 1) == 1, NULL);


  fail_unless(Model_getNumUnitDefinitions(m) == 2);

  UnitDefinition_t *ud = Model_getUnitDefinition(m, 0);

  fail_unless (ud != NULL);
  fail_unless (!strcmp(UnitDefinition_getId( ud), "volume"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);

  Unit_t * u = UnitDefinition_getUnit(ud, 0);

  fail_unless(Unit_getKind(u) == UNIT_KIND_LITRE);
  fail_unless(Unit_getExponent(u) == 1);
  fail_unless(Unit_getMultiplier(u) == 1);
  fail_unless(Unit_getScale(u) == 0);

  ud = Model_getUnitDefinition(m, 1);

  fail_unless (ud != NULL);
  fail_unless (!strcmp(UnitDefinition_getId( ud), "area"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);
  
  u = UnitDefinition_getUnit(ud, 0);

  fail_unless(Unit_getKind(u) == UNIT_KIND_METRE);
  fail_unless(Unit_getExponent(u) == 2);
  fail_unless(Unit_getMultiplier(u) == 1);
  fail_unless(Unit_getScale(u) == 0);

  fail_unless(Model_isSetSubstanceUnits(m) == 1);
  fail_unless(Model_isSetTimeUnits(m) == 1);
  fail_unless(Model_isSetVolumeUnits(m) == 1);
  fail_unless(Model_isSetAreaUnits(m) == 1);
  fail_unless(Model_isSetLengthUnits(m) == 1);
  fail_unless(Model_isSetExtentUnits(m) == 1);

  fail_unless(!strcmp(Model_getSubstanceUnits(m), "mole"));
  fail_unless(!strcmp(Model_getTimeUnits(m), "second"));
  fail_unless(!strcmp(Model_getVolumeUnits(m), "volume"));
  fail_unless(!strcmp(Model_getAreaUnits(m), "area"));
  fail_unless(!strcmp(Model_getLengthUnits(m), "metre"));
  fail_unless(!strcmp(Model_getExtentUnits(m), "mole"));

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_defaultUnits1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Compartment_t  *c = Model_createCompartment(m);

  Compartment_setId   ( c, sid );

  UnitDefinition_t  *ud = Model_createUnitDefinition(m);

  UnitDefinition_setId   ( ud, "substance" );
  Unit_t * u = UnitDefinition_createUnit(ud);
  Unit_setKind(u, UNIT_KIND_MOLE);

  fail_unless(Model_getNumUnitDefinitions(m) == 1);
  fail_unless(Compartment_isSetUnits(c) == 0);
  
  fail_unless( SBMLDocument_setLevelAndVersion(d, 3, 1) == 1, NULL);

  fail_unless(Model_getNumUnitDefinitions(m) == 3);
  
  ud = Model_getUnitDefinition(m, 0);

  fail_unless (ud != NULL);
  fail_unless (!strcmp(UnitDefinition_getId( ud), "substance"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);

  u = UnitDefinition_getUnit(ud, 0);

  fail_unless(Unit_getKind(u) == UNIT_KIND_MOLE);
  fail_unless(Unit_getExponent(u) == 1);
  fail_unless(Unit_getMultiplier(u) == 1);
  fail_unless(Unit_getScale(u) == 0);

  ud = Model_getUnitDefinition(m, 1);

  fail_unless (ud != NULL);
  fail_unless (!strcmp(UnitDefinition_getId( ud), "volume"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);
  
  u = UnitDefinition_getUnit(ud, 0);

  fail_unless(Unit_getKind(u) == UNIT_KIND_LITRE);
  fail_unless(Unit_getExponent(u) == 1);
  fail_unless(Unit_getMultiplier(u) == 1);
  fail_unless(Unit_getScale(u) == 0);

  ud = Model_getUnitDefinition(m, 2);

  fail_unless (ud != NULL);
  fail_unless (!strcmp(UnitDefinition_getId( ud), "area"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);
  
  u = UnitDefinition_getUnit(ud, 0);

  fail_unless(Unit_getKind(u) == UNIT_KIND_METRE);
  fail_unless(Unit_getExponent(u) == 2);
  fail_unless(Unit_getMultiplier(u) == 1);
  fail_unless(Unit_getScale(u) == 0);

  fail_unless(Compartment_isSetUnits(c) == 1);
  fail_unless(!strcmp(Compartment_getUnits(c), "volume"));

  fail_unless(Model_isSetSubstanceUnits(m) == 1);
  fail_unless(Model_isSetTimeUnits(m) == 1);
  fail_unless(Model_isSetVolumeUnits(m) == 1);
  fail_unless(Model_isSetAreaUnits(m) == 1);
  fail_unless(Model_isSetLengthUnits(m) == 1);
  fail_unless(Model_isSetExtentUnits(m) == 1);

  fail_unless(!strcmp(Model_getSubstanceUnits(m), "substance"));
  fail_unless(!strcmp(Model_getTimeUnits(m), "second"));
  fail_unless(!strcmp(Model_getVolumeUnits(m), "volume"));
  fail_unless(!strcmp(Model_getAreaUnits(m), "area"));
  fail_unless(!strcmp(Model_getLengthUnits(m), "metre"));
  fail_unless(!strcmp(Model_getExtentUnits(m), "substance"));
  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_Comp)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Compartment_t  *c = Model_createCompartment(m);

  Compartment_setId   ( c, sid );
  Compartment_setSize ( c, 1.2 ); 
  Compartment_setConstant( c, 1);
  Compartment_setSpatialDimensionsAsDouble(c, 3.4);

  fail_unless(SBMLDocument_setLevelAndVersion(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 1, 2) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 2) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 3) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 4) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 3, 1) == 1);

}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_localParameters)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId   ( c, "c" );

  Species_t *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");

  Reaction_t * r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");

  KineticLaw_t *kl = Reaction_createKineticLaw(r);

  KineticLaw_setFormula(kl, "s*k");
  Parameter_t *p = KineticLaw_createParameter(kl);
  Parameter_setId(p, "k");

  fail_unless(KineticLaw_getNumLocalParameters(kl) == 0);
  
  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1 );

  m = SBMLDocument_getModel(d);
  r = Model_getReaction(m,0);
  kl = Reaction_getKineticLaw(r);


  fail_unless(KineticLaw_getNumLocalParameters(kl) == 1);

  LocalParameter_t *lp = KineticLaw_getLocalParameter(kl, 0);
  (void) lp;

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_stoichiometryMath)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId   ( c, "c" );

  Species_t *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Species_setCompartment(s, "c");

  Reaction_t * r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setSpecies(sr, "s");
  StoichiometryMath_t *sm = SpeciesReference_createStoichiometryMath(sr);

  ASTNode_t * ast = SBML_parseFormula("c*2");
  StoichiometryMath_setMath(sm, ast);

  fail_unless(Model_getNumRules(m) == 0);
  fail_unless(SpeciesReference_isSetId(sr) == 0);
  
  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  m = SBMLDocument_getModel(d);
  r = Model_getReaction(m, 0);
  sr = Reaction_getReactant(r, 0);

  fail_unless(Model_getNumRules(m) == 1);
  fail_unless(SpeciesReference_isSetId(sr) == 1);
  
  Rule_t *rule = Model_getRule(m, 0);

  fail_unless( strcmp(SpeciesReference_getId(sr), Rule_getVariable(rule)) == 0 );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_compartment)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_t *c1;

  Compartment_setId   ( c, sid );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  c1 = Model_getCompartment(m, 0);

  fail_unless(Compartment_hasRequiredAttributes(c1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_unit)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  UnitDefinition_t  *ud = Model_createUnitDefinition(m);
  UnitDefinition_setId   ( ud, sid );
  Unit_t *u = UnitDefinition_createUnit(ud);
  Unit_setKind(u, UNIT_KIND_MOLE);

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  Unit_t *u1 = UnitDefinition_getUnit(Model_getUnitDefinition(m, 0), 0);

  fail_unless(Unit_hasRequiredAttributes(u1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_reaction)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Reaction_t  *r = Model_createReaction(m);
  Reaction_setId   ( r, sid );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  Reaction_t *r1 = Model_getReaction(m, 0);

  fail_unless(Reaction_hasRequiredAttributes(r1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_species)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Species_t  *s = Model_createSpecies(m);
  Species_t *s1;

  Species_setId   ( s, sid );
  Species_setCompartment( s, "comp");

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  s1 = Model_getSpecies(m, 0);

  fail_unless(Species_hasRequiredAttributes(s1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_parameter)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  const char   *sid = "C";
  Parameter_t  *p = Model_createParameter(m);
  Parameter_t *p1;

  Parameter_setId   ( p, sid );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  p1 = Model_getParameter(m, 0);

  fail_unless(Parameter_hasRequiredAttributes(p1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_reactant)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Reaction_t     *r = Model_createReaction(m);

  SpeciesReference_t  *sr = Reaction_createReactant(r);
  SpeciesReference_t *sr1;

  SpeciesReference_setSpecies   ( sr, "s" );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  sr1 = Reaction_getReactant(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_hasRequiredAttributes(sr1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_product)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);
  Reaction_t     *r = Model_createReaction(m);

  SpeciesReference_t  *sr = Reaction_createProduct(r);
  SpeciesReference_t *sr1;

  SpeciesReference_setSpecies   ( sr, "s" );

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  sr1 = Reaction_getProduct(Model_getReaction(m, 0), 0);

  fail_unless(SpeciesReference_hasRequiredAttributes(sr1) == 1);

  SBMLDocument_free(d);
}
END_TEST

START_TEST (test_SBMLConvert_convertToL3_event)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  Event_t  *e = Model_createEvent(m);
  Event_t *e1;

  (void) e;

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  e1 = Model_getEvent(m, 0);

  fail_unless(Event_hasRequiredAttributes(e1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertToL3_trigger)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  Event_t  *e = Model_createEvent(m);
  Trigger_t *t = Event_createTrigger(e);
  (void) t;

  Trigger_t *t1;

  fail_unless( SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1, NULL);

  t1 = Event_getTrigger(Model_getEvent(m, 0));

  fail_unless(Trigger_hasRequiredAttributes(t1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_modelUnits)
{
  UnitDefinition_t *ud;
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Model_setVolumeUnits(m, "litre");

  fail_unless(Model_getNumUnitDefinitions(m) == 0);
  
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumUnitDefinitions(m) == 1);

  ud = Model_getUnitDefinition(m, 0);

  fail_unless(!strcmp(UnitDefinition_getId(ud), "volume"));
  fail_unless(UnitDefinition_getNumUnits(ud) == 1);
  fail_unless(Unit_getKind(UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_LITRE );

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_modelUnits1)
{
  UnitDefinition_t *ud2;
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Model_setSubstanceUnits(m, "foo");
  UnitDefinition_t *ud = Model_createUnitDefinition(m);
  UnitDefinition_setId(ud, "foo");
  Unit_t *u = UnitDefinition_createUnit(ud);
  Unit_initDefaults(u);
  Unit_setKind(u, UNIT_KIND_MOLE);
  Unit_setScale(u, -6);
  UnitDefinition_t *ud1 = Model_createUnitDefinition(m);
  UnitDefinition_setId(ud1, "substance");
  Unit_t *u1 = UnitDefinition_createUnit(ud1);
  Unit_initDefaults(u1);
  Unit_setKind(u1, UNIT_KIND_MOLE);
  Unit_setScale(u1, -3);
  Parameter_t *p = Model_createParameter(m);
  Parameter_setId(p, "p");
  Parameter_setUnits(p, "substance");

  fail_unless(Model_getNumUnitDefinitions(m) == 2);
  
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumUnitDefinitions(m) == 3);

  ud2 = Model_getUnitDefinition(m, 0);

  fail_unless(!strcmp(UnitDefinition_getId(ud2), "foo"));
  fail_unless(UnitDefinition_getNumUnits(ud2) == 1);
  fail_unless(Unit_getKind(UnitDefinition_getUnit(ud2, 0)) == UNIT_KIND_MOLE );
  fail_unless(Unit_getScale(UnitDefinition_getUnit(ud2, 0)) == -6 );

  ud2 = Model_getUnitDefinition(m, 1);

  fail_unless(!strcmp(UnitDefinition_getId(ud2), "substanceFromOriginal"));
  fail_unless(UnitDefinition_getNumUnits(ud2) == 1);
  fail_unless(Unit_getKind(UnitDefinition_getUnit(ud2, 0)) == UNIT_KIND_MOLE );
  fail_unless(Unit_getScale(UnitDefinition_getUnit(ud2, 0)) == -3 );

  ud2 = Model_getUnitDefinition(m, 2);

  fail_unless(!strcmp(UnitDefinition_getId(ud2), "substance"));
  fail_unless(UnitDefinition_getNumUnits(ud2) == 1);
  fail_unless(Unit_getKind(UnitDefinition_getUnit(ud2, 0)) == UNIT_KIND_MOLE );
  fail_unless(Unit_getScale(UnitDefinition_getUnit(ud2, 0)) == -6 );


  Parameter_t* p1 = Model_getParameter(m, 0);

  fail_unless(!strcmp(Parameter_getUnits(p1), "substanceFromOriginal"));

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_conversionFactor)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  const char   *sid = "P";

  Model_setConversionFactor(m, sid);
  Parameter_t  *c = Model_createParameter(m);

  Parameter_setId   ( c, sid );
  Parameter_setConstant( c, 1);

  fail_unless(SBMLDocument_setLevelAndVersion(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 1, 2) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 2) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 3) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 2, 4) == 0);
  fail_unless(SBMLDocument_setLevelAndVersion(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_priority1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1), *d2= NULL;
  Model_t        *m = SBMLDocument_createModel(d);

  Event_t * e = Model_createEvent(m);
  Priority_t * p = Event_createPriority(e);
  (void) p;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 1, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 1) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 3) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 4) == 1);
  SBMLDocument_free(d2);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_persistent)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1), *d2 = NULL;
  Model_t        *m = SBMLDocument_createModel(d);

  Event_t * e = Model_createEvent(m);
  Trigger_t * t = Event_createTrigger(e);
  Trigger_setPersistent(t, 0);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 1, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 1) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 3) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 4) == 1);
  SBMLDocument_free(d2);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_initialValue)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1), *d2=NULL;
  Model_t        *m = SBMLDocument_createModel(d);

  Event_t * e = Model_createEvent(m);
  Trigger_t * t = Event_createTrigger(e);
  Trigger_setInitialValue(t, 0);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 1, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 1) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 2) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 3) == 1);
  SBMLDocument_free(d2);
  d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 2, 4) == 1);
  SBMLDocument_free(d2);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_stoichMath1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Reaction_t *r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  Rule_setMath(rule, SBML_parseFormula("0.001"));
  Model_addRule(m, rule);

  

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);

  SBMLDocument_t *d2 = SBMLDocument_clone(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d2, 1, 2) == 1);
  SBMLDocument_free(d2);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);
  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  r = Model_getReaction(m, 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(Reaction_getReactant(r, 0)) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_stoichMath2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Reaction_t *r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  Rule_setMath(rule, SBML_parseFormula("0.001"));
  Model_addRule(m, rule);

  

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);
  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  r = Model_getReaction(m, 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(Reaction_getReactant(r, 0)) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_stoichMath3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Reaction_t *r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  Rule_setMath(rule, SBML_parseFormula("0.001"));
  Model_addRule(m, rule);

  

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);
  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  r = Model_getReaction(m, 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(Reaction_getReactant(r, 0)) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_stoichMath4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Reaction_t *r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  Rule_setMath(rule, SBML_parseFormula("0.001"));
  Model_addRule(m, rule);

  

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);

  m = SBMLDocument_getModel(d);

  fail_unless(Model_getNumParameters(m) == 1);
  fail_unless(!strcmp(Rule_getVariable(Model_getRule(m, 0)), "parameterId_0"));

  r = Model_getReaction(m, 0);

  fail_unless(SpeciesReference_isSetStoichiometryMath(Reaction_getReactant(r, 0)) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3_stoichMath5)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);
  Compartment_t  *c = Model_createCompartment(m);
  Compartment_setId(c, "c");
  Compartment_setSpatialDimensions(c, 3);
  Species_t      *s = Model_createSpecies(m);
  Species_setId(s, "s");
  Reaction_t *r = Model_createReaction(m);
  SpeciesReference_t *sr = Reaction_createReactant(r);
  SpeciesReference_setId(sr, "XREF");
  SpeciesReference_setSpecies(sr, "s");
  Rule_t *rule = Rule_createRate(3,1);
  Rule_setVariable(rule, "XREF");
  Rule_setMath(rule, SBML_parseFormula("0.001"));
  Model_addRule(m, rule);

  

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL1V1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
 
  d = SBMLDocument_createWithLevelAndVersion(1, 1);
  m = SBMLDocument_createModel(d);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
 
  d = SBMLDocument_createWithLevelAndVersion(1, 1);
  m = SBMLDocument_createModel(d);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
 
  d = SBMLDocument_createWithLevelAndVersion(1, 1);
  m = SBMLDocument_createModel(d);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
 
  d = SBMLDocument_createWithLevelAndVersion(1, 1);
  m = SBMLDocument_createModel(d);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
 
  d = SBMLDocument_createWithLevelAndVersion(1, 1);
  m = SBMLDocument_createModel(d);

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL1V2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(1, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL2V1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL2V2)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 2);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL2V3)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 3);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL2V4)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(2, 4);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_SBMLConvert_convertFromL3V1)
{
  SBMLDocument_t *d = SBMLDocument_createWithLevelAndVersion(3, 1);
  Model_t        *m = SBMLDocument_createModel(d);

  (void) m;

  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 1) == 0);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 1, 2) == 1);

  d = SBMLDocument_createWithLevelAndVersion(3, 1);
  m = SBMLDocument_createModel(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 1) == 1);
  
  d = SBMLDocument_createWithLevelAndVersion(3, 1);
  m = SBMLDocument_createModel(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 2) == 1);

  d = SBMLDocument_createWithLevelAndVersion(3, 1);
  m = SBMLDocument_createModel(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 3) == 1);
  
  d = SBMLDocument_createWithLevelAndVersion(3, 1);
  m = SBMLDocument_createModel(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 2, 4) == 1);
  
  d = SBMLDocument_createWithLevelAndVersion(3, 1);
  m = SBMLDocument_createModel(d);
  fail_unless(SBMLDocument_setLevelAndVersionNonStrict(d, 3, 1) == 1);

  SBMLDocument_free(d);
}
END_TEST


Suite *
create_suite_SBMLConvert (void) 
{ 
  Suite *suite = suite_create("SBMLConvert");
  TCase *tcase = tcase_create("SBMLConvert");

  tcase_add_test( tcase, test_SBMLConvert_invalidLevelVersion );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL1_addModifiersToReaction         );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL1_varyingParam         );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL1_varyingComp         );
  tcase_add_test( tcase, test_SBMLConvert_convertToL1_SBMLDocument          );
  tcase_add_test( tcase, test_SBMLConvert_convertToL1_noCompartment          );
  tcase_add_test( tcase, test_SBMLConvert_convertToL1_Species_Amount        );
  tcase_add_test( tcase, test_SBMLConvert_convertToL1_Species_Concentration );
  tcase_add_test( tcase, test_SBMLConvert_convertToL2_SBMLDocument       );
  tcase_add_test( tcase, test_SBMLConvert_convertToL2v4_DuplicateAnnotations_doc );
  tcase_add_test( tcase, test_SBMLConvert_convertToL2v4_DuplicateAnnotations_model );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_defaultUnits );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_defaultUnits1 );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_localParameters );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_stoichiometryMath );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_compartment );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_unit );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_reaction );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_species );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_species );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_parameter );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_reactant );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_product );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_event );
  tcase_add_test( tcase, test_SBMLConvert_convertToL3_trigger );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_Comp );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_modelUnits );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_modelUnits1 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_conversionFactor );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_priority1 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_persistent );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_initialValue );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_stoichMath1 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_stoichMath2 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_stoichMath3 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_stoichMath4 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3_stoichMath5 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL1V1 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL1V2 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL2V1 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL2V2 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL2V3 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL2V4 );
  tcase_add_test( tcase, test_SBMLConvert_convertFromL3V1 );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

