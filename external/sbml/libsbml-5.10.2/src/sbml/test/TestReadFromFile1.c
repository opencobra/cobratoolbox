/**
 * \file    TestReadFromFile1.c
 * \brief   Reads tests/l1v1-branch.xml into memory and tests it.
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


START_TEST (test_read_l1v1_branch)
{
  SBMLDocument_t     *d;
  Model_t            *m;
  Compartment_t      *c;
  KineticLaw_t       *kl;
  Parameter_t        *p;
  Reaction_t         *r;
  Species_t          *s;
  SpeciesReference_t *sr;

  UnitDefinition_t   *ud;

  char *filename = safe_strcat(TestDataDirectory, "l1v1-branch.xml");


  d = readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l1v1-branch.xml\") returned a NULL pointer.");
  }

  safe_free(filename);


  /**
   * <sbml level="1" version="1" ...>
   */
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );


  /**
   * <model name="Branch">
   */
  m = SBMLDocument_getModel(d);

  fail_unless( !strcmp( Model_getName(m) , "Branch"), NULL );


  /**
   * <listOfCompartments>
   *  <compartment name="compartmentOne" volume="1"/>
   * </listOfCompartments>
   */
  fail_unless( Model_getNumCompartments(m) == 1, NULL );

  c = Model_getCompartment(m, 0);
  fail_unless( !strcmp(Compartment_getName(c), "compartmentOne"), NULL );
  fail_unless( Compartment_getVolume(c) == 1, NULL );

  /**
   * tests for the unit API functions
   */
  ud = Compartment_getDerivedUnitDefinition(c);
  fail_unless (UnitDefinition_getNumUnits(ud) == 1, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_LITRE, NULL );


  /**
   * <listOfSpecies>
   *   <specie name="S1" initialAmount="0" compartment="compartmentOne"
   *           boundaryCondition="false"/>
   *   <specie name="X0" initialAmount="0" compartment="compartmentOne"
   *           boundaryCondition="true"/>
   *   <specie name="X1" initialAmount="0" compartment="compartmentOne"
   *           boundaryCondition="true"/>
   *   <specie name="X2" initialAmount="0" compartment="compartmentOne"
   *           boundaryCondition="true"/>
   * </listOfSpecies>
   */
  fail_unless( Model_getNumSpecies(m) == 4, NULL );

  s = Model_getSpecies(m, 0);
  fail_unless( !strcmp( Species_getName       (s), "S1"             ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "compartmentOne" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  /**
   * tests for the unit API functions
   */
  ud = Species_getDerivedUnitDefinition(s);
  fail_unless (UnitDefinition_getNumUnits(ud) == 2, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 0)) ==  1, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 1)) == UNIT_KIND_LITRE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 1)) ==  -1, NULL );


  s = Model_getSpecies(m, 1);
  fail_unless( !strcmp( Species_getName       (s), "X0"             ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "compartmentOne" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 1, NULL );

  s = Model_getSpecies(m, 2);
  fail_unless( !strcmp( Species_getName       (s), "X1"             ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "compartmentOne" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 1, NULL );

  s = Model_getSpecies(m, 3);
  fail_unless( !strcmp( Species_getName       (s), "X2"             ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "compartmentOne" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 1, NULL );


  /**
   * <listOfReactions>
   *   <reaction name="reaction_1" reversible="false"> ... </reaction>
   *   <reaction name="reaction_2" reversible="false"> ... </reaction>
   *   <reaction name="reaction_3" reversible="false"> ... </reaction>
   * </listOfReactions>
   */
  fail_unless( Model_getNumReactions(m) == 3, NULL );

  r = Model_getReaction(m, 0);
  fail_unless( !strcmp(Reaction_getName(r), "reaction_1"), NULL );
  fail_unless( Reaction_getReversible(r) == 0, NULL );
  fail_unless( Reaction_getFast      (r) == 0, NULL );

  /**
   * tests for the unit API functions
   */
  ud = KineticLaw_getDerivedUnitDefinition(Reaction_getKineticLaw(r));
  fail_unless (UnitDefinition_getNumUnits(ud) == 2, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 0)) ==  1, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 1)) == UNIT_KIND_LITRE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 1)) ==  -1, NULL );

  fail_unless( KineticLaw_containsUndeclaredUnits(Reaction_getKineticLaw(r)) == 1, NULL);


  r = Model_getReaction(m, 1);
  fail_unless( !strcmp(Reaction_getName(r), "reaction_2"), NULL );
  fail_unless( Reaction_getReversible(r) == 0, NULL );
  fail_unless( Reaction_getFast      (r) == 0, NULL );

  r = Model_getReaction(m, 2);
  fail_unless( !strcmp(Reaction_getName(r), "reaction_3"), NULL );
  fail_unless( Reaction_getReversible(r) == 0, NULL );
  fail_unless( Reaction_getFast      (r) == 0, NULL );

  /**
   * <reaction name="reaction_1" reversible="false">
   *   <listOfReactants>
   *     <specieReference specie="X0" stoichiometry="1"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="S1" stoichiometry="1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="k1 * X0">
   *     <listOfParameters>
   *       <parameter name="k1" value="0"/>
   *     </listOfParameters>
   *   </kineticLaw>
   * </reaction>
   */
  r = Model_getReaction(m, 0);

  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X0"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "S1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k1 * X0"), NULL );
  fail_unless( KineticLaw_getNumParameters(kl) == 1, NULL );

  p = KineticLaw_getParameter(kl, 0);
  fail_unless( !strcmp(Parameter_getName(p), "k1"), NULL );
  fail_unless( Parameter_getValue(p) == 0, NULL );


  /**
   * <reaction name="reaction_2" reversible="false">
   *   <listOfReactants>
   *     <specieReference specie="S1" stoichiometry="1"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="X1" stoichiometry="1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="k2 * S1">
   *     <listOfParameters>
   *       <parameter name="k2" value="0"/>
   *     </listOfParameters>
   *   </kineticLaw>
   * </reaction>
   */
  r = Model_getReaction(m, 1);
  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "S1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k2 * S1"), NULL );
  fail_unless( KineticLaw_getNumParameters(kl) == 1, NULL );

  p = KineticLaw_getParameter(kl, 0);
  fail_unless( !strcmp(Parameter_getName(p), "k2"), NULL );
  fail_unless( Parameter_getValue(p) == 0, NULL );


  /**
   * <reaction name="reaction_3" reversible="false">
   *   <listOfReactants>
   *     <specieReference specie="S1" stoichiometry="1"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="X2" stoichiometry="1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="k3 * S1">
   *     <listOfParameters>
   *       <parameter name="k3" value="0"/>
   *     </listOfParameters>
   *   </kineticLaw>
   * </reaction>
   */
  r = Model_getReaction(m, 2);
  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "S1"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X2"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k3 * S1"), NULL );
  fail_unless( KineticLaw_getNumParameters(kl) == 1, NULL );

  p = KineticLaw_getParameter(kl, 0);
  fail_unless( !strcmp(Parameter_getName(p), "k3"), NULL );
  fail_unless( Parameter_getValue(p) == 0, NULL );

  SBMLDocument_free(d);
}
END_TEST


Suite *
create_suite_TestReadFromFile1 (void)
{ 
  Suite *suite = suite_create("test-data/l1v1-branch.xml");
  TCase *tcase = tcase_create("test-data/l1v1-branch.xml");


  tcase_add_test(tcase, test_read_l1v1_branch);

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


