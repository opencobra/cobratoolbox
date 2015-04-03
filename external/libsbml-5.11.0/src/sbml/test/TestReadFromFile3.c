/**
 * \file    TestReadFromFile3.c
 * \brief   Reads tests/l1v1-rules.xml into memory and tests it.
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


START_TEST (test_read_l1v1_rules)
{
  SBMLDocument_t             *d;
  Model_t                    *m;
  Compartment_t              *c;
  KineticLaw_t               *kl;
  Parameter_t                *p;
  Rule_t                     *pr;
  Reaction_t                 *r;
  Species_t                  *s;
  Rule_t                     *scr;
  SpeciesReference_t         *sr;
  UnitDefinition_t           *ud;

  char *filename = safe_strcat(TestDataDirectory, "l1v1-rules.xml");


  d = readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l1v1-rules.xml\") returned a NULL pointer.");
  }

  safe_free(filename);


  /**
   * <sbml level="1" version="1" ...>
   */
  fail_unless( SBMLDocument_getLevel  (d) == 1, NULL );
  fail_unless( SBMLDocument_getVersion(d) == 1, NULL );


  /**
   * <model>
   */
  m = SBMLDocument_getModel(d);

  /**
   * <listOfCompartments>
   *  <compartment name="cell" volume="1"/>
   * </listOfCompartments>
   */
  fail_unless( Model_getNumCompartments(m) == 1, NULL );

  c = Model_getCompartment(m, 0);
  fail_unless( !strcmp(Compartment_getName(c), "cell"), NULL );
  fail_unless( Compartment_getVolume(c) == 1, NULL );


  /**
   * <listOfSpecies>
   *   <specie name="s1" compartment="cell" initialAmount="4"/>
   *   <specie name="s2" compartment="cell" initialAmount="2"/>
   *   <specie name="x0" compartment="cell" initialAmount="1"/>
   *   <specie name="x1" compartment="cell" initialAmount="0"/>
   *   <specie name="x2" compartment="cell" initialAmount="1"/>
   *   <specie name="x3" compartment="cell" initialAmount="0"/>
   * </listOfSpecies>
   */
  fail_unless( Model_getNumSpecies(m) == 6, NULL );

  s = Model_getSpecies(m, 0);
  fail_unless( !strcmp( Species_getName(s)       , "s1"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 4, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 1);
  fail_unless( !strcmp( Species_getName(s)       , "s2"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 2, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 2);
  fail_unless( !strcmp( Species_getName(s)       , "x0"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 3);
  fail_unless( !strcmp( Species_getName(s)       , "x1"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 4);
  fail_unless( !strcmp( Species_getName(s)       , "x2"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );

  s = Model_getSpecies(m, 5);
  fail_unless( !strcmp( Species_getName(s)       , "x3"   ), NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "cell" ), NULL );
  fail_unless( Species_getInitialAmount    (s) == 0, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );


  /**
   * <listOfParameters>
   *   <parameter name="k1" value="1.2"/>
   *   <parameter name="k2" value="1000"/>
   *   <parameter name="k3" value="3000"/>
   *   <parameter name="k4" value="4.5"/>
   * </listOfParameters>
   */
  fail_unless( Model_getNumParameters(m) == 7, NULL );

  p = Model_getParameter(m, 0);
  fail_unless( !strcmp(Parameter_getName(p), "k1"), NULL );
  fail_unless( Parameter_getValue(p) == 1.2, NULL );

  p = Model_getParameter(m, 1);
  fail_unless( !strcmp(Parameter_getName(p), "k2"), NULL );
  fail_unless( Parameter_getValue(p) == 1000, NULL );

  p = Model_getParameter(m, 2);
  fail_unless( !strcmp(Parameter_getName(p), "k3"), NULL );
  fail_unless( Parameter_getValue(p) == 3000, NULL );

  p = Model_getParameter(m, 3);
  fail_unless( !strcmp(Parameter_getName(p), "k4"), NULL );
  fail_unless( Parameter_getValue(p) == 4.5, NULL );


  /**
   * <listOfRules>
   *   <parameterRule name="t" formula="s1 + s2"/>
   *   <parameterRule name="k" formula="k3/k2"/>
   *   <specieConcentrationRule specie="s2" formula="k * t/(1 + k)"/>
   *   <specieConcentrationRule specie="s1" formula="t - s2"/>
   * </listOfRules>
   */
  fail_unless( Model_getNumRules(m) == 4, NULL );

  pr = Model_getRule(m, 0);
  fail_unless( !strcmp(Rule_getVariable(pr), "t"), NULL );
  fail_unless( !strcmp(Rule_getFormula( pr), "s1 + s2"), NULL );

  /**
   * tests for the unit API functions
   */
  ud = Rule_getDerivedUnitDefinition(pr);
  fail_unless (UnitDefinition_getNumUnits(ud) == 2, NULL);
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 0)) == UNIT_KIND_MOLE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 0)) ==  1, NULL );
  fail_unless( Unit_getKind (UnitDefinition_getUnit(ud, 1)) == UNIT_KIND_LITRE, NULL );
  fail_unless( Unit_getExponent(UnitDefinition_getUnit(ud, 1)) ==  -1, NULL );

  fail_unless( Rule_containsUndeclaredUnits(pr) == 0, NULL);

  pr = Model_getRule(m, 1);
  fail_unless( !strcmp(Rule_getVariable(pr), "k"), NULL );
  fail_unless( !strcmp(Rule_getFormula( pr), "k3/k2"), NULL );

  /**
   * tests for the unit API functions
   */
  ud = Rule_getDerivedUnitDefinition(pr);
  fail_unless (UnitDefinition_getNumUnits(ud) == 0, NULL);

  fail_unless( Rule_containsUndeclaredUnits(pr) == 1, NULL);

  scr = Model_getRule(m, 2);
  fail_unless( !strcmp(Rule_getVariable(scr), "x2"), NULL );
  fail_unless( !strcmp(Rule_getFormula( scr), "k * (s1+s2)/(1 + k)"),
               NULL );

  scr = Model_getRule(m, 3);
  fail_unless( !strcmp(Rule_getVariable(scr), "x3"), NULL );
  fail_unless( !strcmp(Rule_getFormula((Rule_t *) scr), "p*(t - s2)"), NULL );


  /**
   * <listOfReactions>
   *   <reaction name="j1" > ... </reaction>
   *   <reaction name="j3" > ... </reaction>
   * </listOfReactions>
   */
  fail_unless( Model_getNumReactions(m) == 2, NULL );

  r = Model_getReaction(m, 0);
  fail_unless( !strcmp(Reaction_getName(r), "j1"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );

  r = Model_getReaction(m, 1);
  fail_unless( !strcmp(Reaction_getName(r), "j3"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );


  /**
   * <reaction name="j1">
   *   <listOfReactants>
   *     <specieReference specie="x0"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="s1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="k1 * x0"/>
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
  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k1 * x0"), NULL );


  /**
   * <reaction name="j3">
   *   <listOfReactants>
   *     <specieReference specie="s2"/>
   *   </listOfReactants>
   *   <listOfProducts>
   *     <specieReference specie="x1"/>
   *   </listOfProducts>
   *   <kineticLaw formula="k4 * s2"/>
   * </reaction>
   */
  r = Model_getReaction(m, 1);

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
  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k4 * s2"), NULL );

  SBMLDocument_free(d);
}
END_TEST


Suite *
create_suite_TestReadFromFile3 (void)
{ 
  Suite *suite = suite_create("test-data/l1v1-rules.xml");
  TCase *tcase = tcase_create("test-data/l1v1-rules.xml");


  tcase_add_test(tcase, test_read_l1v1_rules);

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


