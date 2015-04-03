/**
 * \file    TestReadFromFile2.c
 * \brief   Reads tests/l1v1-units.xml into memory and tests it.
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
#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

extern char *TestDataDirectory;


START_TEST (test_read_l1v1_units)
{
  SBMLDocument_t     *d;
  Model_t            *m;
  Compartment_t      *c;
  KineticLaw_t       *kl;
  Parameter_t        *p;
  Reaction_t         *r;
  Species_t          *s;
  SpeciesReference_t *sr;
  Unit_t             *u;
  UnitDefinition_t   *ud;

  char *filename = safe_strcat(TestDataDirectory, "l1v1-units.xml");


  d = readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l1v1-units.xml\") returned a NULL pointer.");
  }

  safe_free(filename);


  /**
   * <sbml level="1" version="1">
   */
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );

  m = SBMLDocument_getModel(d);


  /**
   * <listOfUnitDefinitions>
   *   <unitDefinition name="substance"> ... </unitDefinition>
   *   <unitDefinition name="mls">       ... </unitDefinition>
   * </listOfUnitDefinitions>
   */
  fail_unless( Model_getNumUnitDefinitions(m) == 2, NULL );

  ud = Model_getUnitDefinition(m, 0);
  fail_unless ( !strcmp(UnitDefinition_getName(ud), "substance"), NULL );

  ud = Model_getUnitDefinition(m, 1);
  fail_unless ( !strcmp(UnitDefinition_getName(ud), "mls"), NULL );


  /**
   * <unitDefinition name="substance">
   *   <listOfUnits>
   *     <unit kind="mole" scale="-3"/>
   *   </listOfUnits>
   * </unitDefinition>
   */
  ud = Model_getUnitDefinition(m, 0);
  fail_unless( UnitDefinition_getNumUnits(ud) == 1, NULL );

  u = UnitDefinition_getUnit(ud, 0);
  fail_unless( Unit_getKind    (u) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(u) ==  1, NULL );
  fail_unless( Unit_getScale   (u) == -3, NULL );


  /**
   * <unitDefinition name="mls">
   *   <listOfUnits>
   *     <unit kind="mole"   scale="-3"/>
   *     <unit kind="liter"  exponent="-1"/>
   *     <unit kind="second" exponent="-1"/>
   *   </listOfUnits>
   * </unitDefinition>
   */
  ud = Model_getUnitDefinition(m, 1);
  fail_unless( UnitDefinition_getNumUnits(ud) == 3, NULL );

  u = UnitDefinition_getUnit(ud, 0);
  fail_unless( Unit_getKind    (u) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(u) ==  1, NULL );
  fail_unless( Unit_getScale   (u) == -3, NULL );

  u = UnitDefinition_getUnit(ud, 1);
  fail_unless( Unit_getKind    (u) == UNIT_KIND_LITER, NULL );
  fail_unless( Unit_getExponent(u) == -1, NULL );
  fail_unless( Unit_getScale   (u) ==  0, NULL );

  u = UnitDefinition_getUnit(ud, 2);
  fail_unless( Unit_getKind    (u) == UNIT_KIND_SECOND, NULL );
  fail_unless( Unit_getExponent(u) == -1, NULL );
  fail_unless( Unit_getScale   (u) ==  0, NULL );

  /**
   * <listOfCompartments>
   *   <compartment name="cell"/>
   * </listOfCompartments>
   */
  fail_unless( Model_getNumCompartments(m) == 1, NULL );

  c = Model_getCompartment(m, 0);
  fail_unless( !strcmp(Compartment_getName(c), "cell"), NULL );


  /**
   * <listOfSpecies>
   *   <specie name="x0" compartment="cell" initialAmount="1"/>
   *   <specie name="x1" compartment="cell" initialAmount="1"/>
   *   <specie name="s1" compartment="cell" initialAmount="1"/>
   *   <specie name="s2" compartment="cell" initialAmount="1"/>
   * </listOfSpecies>
   */
  fail_unless( Model_getNumSpecies(m) == 4, NULL );

  s = Model_getSpecies(m, 0);
  fail_unless( !strcmp( Species_getName(s)       , "x0"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );
  
  /**
   * tests for the unit API functions
   */
  ud = Species_getDerivedUnitDefinition(s);
  fail_unless (UnitDefinition_getNumUnits(ud) == 2, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 0)) ==  1, NULL );
  fail_unless( Unit_getScale(UnitDefinition_getUnit(ud, 0)) ==  -3, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 1)) == UNIT_KIND_LITRE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 1)) ==  -1, NULL );


  s = Model_getSpecies(m, 1);
  fail_unless( !strcmp( Species_getName(s)       , "x1"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 2);
  fail_unless( !strcmp( Species_getName(s)       , "s1"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 3);
  fail_unless( !strcmp( Species_getName(s)       , "s2"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );


  /**
   * <listOfParameters>
   *   <parameter name="vm" value="2" units="mls"/>
   *   <parameter name="km" value="2"/>
   * </listOfParameters>
   */
  fail_unless( Model_getNumParameters(m) == 2, NULL );

  p = Model_getParameter(m, 0);
  fail_unless( !strcmp( Parameter_getName (p), "vm"  ), NULL );
  fail_unless( !strcmp( Parameter_getUnits(p), "mls" ), NULL );
  fail_unless( Parameter_getValue(p) == 2, NULL );

  /**
   * tests for the unit API functions
   */
  ud = Parameter_getDerivedUnitDefinition(p);
  fail_unless (UnitDefinition_getNumUnits(ud) == 3, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 0)) ==  1, NULL );
  fail_unless( Unit_getScale(UnitDefinition_getUnit(ud, 0)) ==  -3, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 1)) == UNIT_KIND_LITER, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 1)) ==  -1, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 2)) == UNIT_KIND_SECOND, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 2)) ==  -1, NULL );

  p = Model_getParameter(m, 1);
  fail_unless( !strcmp( Parameter_getName(p), "km"  ), NULL );
  fail_unless( Parameter_getValue(p) == 2, NULL );

  /**
   * tests for the unit API functions
   */
  ud = Parameter_getDerivedUnitDefinition(p);
  fail_unless (UnitDefinition_getNumUnits(ud) == 0, NULL);

  /**
   * <listOfReactions>
   *   <reaction name="v1"> ... </reaction>
   *   <reaction name="v2"> ... </reaction>
   *   <reaction name="v3"> ... </reaction>
   * </listOfReactions>
   */
  fail_unless( Model_getNumReactions(m) == 3, NULL );

  r = Model_getReaction(m, 0);
  fail_unless( !strcmp(Reaction_getName(r), "v1"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );

  r = Model_getReaction(m, 1);
  fail_unless( !strcmp(Reaction_getName(r), "v2"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );

  r = Model_getReaction(m, 2);
  fail_unless( !strcmp(Reaction_getName(r), "v3"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );


  /**
   * <reaction name="v1">
   *   <listOfReactants>
   *     <specieReference specie="x0"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="s1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
   * </reaction>
   */
  r = Model_getReaction(m, 0);

  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "x0"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "s1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless(!strcmp(KineticLaw_getFormula(kl), "cell * (vm * s1)/(km + s1)"), NULL);


  /**
   * <reaction name="v2">
   *   <listOfReactants>
   *     <specieReference specie="s1"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="s2"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s2)/(km + s2)"/>
   * </reaction>
   */
  r = Model_getReaction(m, 1);

  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "s1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "s2"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless(!strcmp(KineticLaw_getFormula(kl), "cell * (vm * s2)/(km + s2)"), NULL);


  /**
   * <reaction name="v3">
   *   <listOfReactants>
   *     <specieReference specie="s2"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="x1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
   * </reaction>
   */
  r = Model_getReaction(m, 2);

  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "s2"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "x1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless(!strcmp(KineticLaw_getFormula(kl), "cell * (vm * s1)/(km + s1)"), NULL);

  SBMLDocument_free(d);
}
END_TEST


START_TEST (test_create_l1v1_units)
{
  Model_t            *m;
  Compartment_t      *c;
  KineticLaw_t       *kl;
  Parameter_t        *p;
  Reaction_t         *r;
  Species_t          *s;
  SpeciesReference_t *sr;
  Unit_t             *u;
  UnitDefinition_t   *ud;


  /**
   * <sbml level="1" version="1">
   */
  m = Model_create(2, 4);

  /**
   * <unitDefinition name="substance">
   *   <listOfUnits>
   *     <unit kind="mole" scale="-3"/>
   *   </listOfUnits>
   * </unitDefinition>
   */
  ud = Model_createUnitDefinition(m);
  UnitDefinition_setName(ud, "substance");

  u = Model_createUnit(m);
  Unit_setKind(u,UNIT_KIND_MOLE);
  Unit_setScale(u, -3);

  /**
   * <unitDefinition name="mls">
   *   <listOfUnits>
   *     <unit kind="mole"   scale="-3"/>
   *     <unit kind="liter"  exponent="-1"/>
   *     <unit kind="second" exponent="-1"/>
   *   </listOfUnits>
   * </unitDefinition>
   */
  ud = Model_createUnitDefinition(m);
  UnitDefinition_setName(ud, "mls");

  u = Model_createUnit(m);
  Unit_setKind(u, UNIT_KIND_MOLE);
  Unit_setScale(u, -3);

  u = Model_createUnit(m);
  Unit_setKind(u, UNIT_KIND_LITER);
  Unit_setExponent(u, -1);

  u = Model_createUnit(m);
  Unit_setKind(u, UNIT_KIND_SECOND);
  Unit_setExponent(u, -1);

  /**
   * <listOfCompartments>
   *   <compartment name="cell"/>
   * </listOfCompartments>
   */
  c = Model_createCompartment(m);
  Compartment_setName(c, "cell");

  /**
   * <listOfSpecies>
   *   <specie name="x0" compartment="cell" initialAmount="1"/>
   *   <specie name="x1" compartment="cell" initialAmount="1"/>
   *   <specie name="s1" compartment="cell" initialAmount="1"/>
   *   <specie name="s2" compartment="cell" initialAmount="1"/>
   * </listOfSpecies>
   */
  s = Model_createSpecies(m);
  Species_setName(s, "x0");
  Species_setCompartment(s, "cell");
  Species_setInitialAmount(s, 1);

  s = Model_createSpecies(m);
  Species_setName(s, "x1");
  Species_setCompartment(s, "cell");
  Species_setInitialAmount(s, 1);

  s = Model_createSpecies(m);
  Species_setName(s, "s1");
  Species_setCompartment(s, "cell");
  Species_setInitialAmount(s, 1);

  s = Model_createSpecies(m);
  Species_setName(s, "s2");
  Species_setCompartment(s, "cell"); 
  Species_setInitialAmount(s, 1);

  /**
   * <listOfParameters>
   *   <parameter name="vm" value="2" units="mls"/>
   *   <parameter name="km" value="2"/>
   * </listOfParameters>
   */
  p = Model_createParameter(m);
  Parameter_setName (p, "vm");
  Parameter_setUnits(p, "mls");
  Parameter_setValue(p, 2);

  p = Model_createParameter(m);
  Parameter_setName (p, "km");
  Parameter_setValue(p, 2);

  /**
   * <reaction name="v1">
   *   <listOfReactants>
   *     <specieReference specie="x0"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="s1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
   * </reaction>
   */
  r = Model_createReaction(m);
  Reaction_setName(r, "v1");

  sr = Model_createReactant(m);
  SpeciesReference_setSpecies(sr, "x0");

  sr = Model_createProduct(m);
  SpeciesReference_setSpecies(sr, "s1");

  kl = Model_createKineticLaw(m);
  KineticLaw_setFormula(kl, "(vm * s1)/(km + s1)");

  /**
   * <reaction name="v2">
   *   <listOfReactants>
   *     <specieReference specie="s1"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="s2"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s2)/(km + s2)"/>
   * </reaction>
   */
  r = Model_createReaction(m);
  Reaction_setName(r, "v2");

  sr = Model_createReactant(m);
  SpeciesReference_setSpecies(sr, "s1");

  sr = Model_createProduct(m);
  SpeciesReference_setSpecies(sr, "s2");

  kl = Model_createKineticLaw(m);
  KineticLaw_setFormula(kl, "(vm * s2)/(km + s2)");

  /**
   * <reaction name="v3">
   *   <listOfReactants>
   *     <specieReference specie="s2"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="x1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="(vm * s1)/(km + s1)"/>
   * </reaction>
   */
  r = Model_createReaction(m);
  Reaction_setName(r, "v3");

  sr = Model_createReactant(m);
  SpeciesReference_setSpecies(sr, "s2");

  sr = Model_createProduct(m);
  SpeciesReference_setSpecies(sr, "x1");

  kl = Model_createKineticLaw(m);
  KineticLaw_setFormula(kl, "(vm * s1)/(km + s1)");

  Model_free(m);
}
END_TEST


Suite *
create_suite_TestReadFromFile2 (void) 
{ 
  Suite *suite = suite_create("test-data/l1v1-units.xml");
  TCase *tcase = tcase_create("test-data/l1v1-units.xml");


  tcase_add_test( tcase, test_read_l1v1_units   );
  tcase_add_test( tcase, test_create_l1v1_units );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

