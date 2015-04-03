/**
 * \file    TestReadFromFile4.c
 * \brief   Reads tests/l1v1-minimal.xml into memory and tests it.
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


START_TEST (test_read_l1v1_minimal)
{
  SBMLDocument_t     *d;
  Model_t            *m;
  Compartment_t      *c;
  Reaction_t         *r;
  Species_t          *s;
  SpeciesReference_t *sr;

  char *filename = safe_strcat(TestDataDirectory, "l1v1-minimal.xml");


  d = readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l1v1-minimal.xml\") returned a NULL pointer.");
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
   *  <compartment name="x"/>
   * </listOfCompartments>
   */
  fail_unless( Model_getNumCompartments(m) == 1, NULL );

  c = Model_getCompartment(m, 0);
  fail_unless( !strcmp(Compartment_getName(c), "x"), NULL );


  /**
   * <listOfSpecies>
   *   <specie name="y" compartment="x" initialAmount="1"/>
   * </listOfSpecies>
   */
  fail_unless( Model_getNumSpecies(m) == 1, NULL );

  s = Model_getSpecies(m, 0);
  fail_unless( !strcmp( Species_getName(s)       , "y" )  , NULL );
  fail_unless( !strcmp( Species_getCompartment(s), "x" )  , NULL );
  fail_unless( Species_getInitialAmount    (s) == 1, NULL );
  fail_unless( Species_getBoundaryCondition(s) == 0, NULL );


  /**
   * <listOfReactions>
   *   <reaction name="x">
   *     <listOfReactants>
   *       <specieReference specie="y"/>
   *     </listOfReactants>
   *     <listOfProducts>
   *       <specieReference specie="y"/>
   *     </listOfProducts>
   *   </reaction>
   * </listOfReactions>
   */
  fail_unless( Model_getNumReactions(m) == 1, NULL );

  r = Model_getReaction(m, 0);
  fail_unless( !strcmp(Reaction_getName(r), "r"), NULL );
  fail_unless( Reaction_getReversible(r) != 0, NULL );
  fail_unless( Reaction_getFast(r)       == 0, NULL );

  fail_unless( Reaction_getNumReactants(r) == 1, NULL );
  fail_unless( Reaction_getNumProducts(r)  == 1, NULL );

  sr = Reaction_getReactant(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "y"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  sr = Reaction_getProduct(r, 0);
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "y"), NULL );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1, NULL );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1, NULL );

  SBMLDocument_free(d);
}
END_TEST


Suite *
create_suite_TestReadFromFile4 (void)
{ 
  Suite *suite = suite_create("test-data/l1v1-minimal.xml");
  TCase *tcase = tcase_create("test-data/l1v1-minimal.xml");


  tcase_add_test(tcase, test_read_l1v1_minimal);

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


