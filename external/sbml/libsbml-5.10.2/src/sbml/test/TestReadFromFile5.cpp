/**
 * \file    TestReadFromFile5.c
 * \brief   Reads test-data/l2v1-assignment.xml into memory and tests it.
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
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_read_l2v1_assignment)
{
  SBMLReader        reader;
  SBMLDocument*     d;
  Model*            m;
  Compartment*      c;
  Species*          s;
  Parameter*        p;
  AssignmentRule*   ar;
  Reaction*         r;
  SpeciesReference* sr;
  KineticLaw*       kl;
  UnitDefinition*   ud;
  Reaction*         r1;
  ListOfCompartments *loc;
  Compartment * c1;
  ListOfRules *lor;
  AssignmentRule *ar1; 
  ListOfParameters *lop;
  Parameter *p1;
  ListOfSpecies *los;
  Species *s1;

  std::string filename(TestDataDirectory);
  filename += "l2v1-assignment.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l2v1-assignment.xml\") returned a NULL pointer.");
  }



  //
  // <sbml level="2" version="1" ...>
  //
  fail_unless( d->getLevel  () == 2, NULL );
  fail_unless( d->getVersion() == 1, NULL );


  //
  // <model>
  //
  m = d->getModel();
  fail_unless( m != NULL, NULL );


  //
  // <listOfCompartments>
  //   <compartment id="cell"/>
  // </listOfCompartments>
  //
  fail_unless( m->getNumCompartments() == 1, NULL );

  c = m->getCompartment(0);
  fail_unless( c          != NULL  , NULL );
  fail_unless( c->getId() == "cell", NULL );

  /**
   * tests for the unit API functions
   */
  ud = c->getDerivedUnitDefinition();
  fail_unless (ud->getNumUnits() == 1, NULL);
  fail_unless( ud->getUnit(0)->getKind() == UNIT_KIND_LITRE, NULL );

  /*
   * test for derived list of functions
   */
  loc = m->getListOfCompartments();
  c1 = loc->get(0);
  fail_unless (c1 == c);

  c1 = loc->get("cell");
  fail_unless (c1 == c);

  //
  // <listOfSpecies>
  //   <species id="X0" compartment="cell" initialConcentration="1"/>
  //   <species id="X1" compartment="cell" initialConcentration="0"/>
  //   <species id="T"  compartment="cell" initialConcentration="0"/>
  //   <species id="S1" compartment="cell" initialConcentration="0"/>
  //   <species id="S2" compartment="cell" initialConcentration="0"/>
  // </listOfSpecies>
  //
  fail_unless( m->getNumSpecies() == 5, NULL );

  s = m->getSpecies(0);
  fail_unless( s                            != NULL  , NULL );
  fail_unless( s->getId()                   == "X0"  , NULL );
  fail_unless( s->getCompartment()          == "cell", NULL );
  fail_unless( s->getInitialConcentration() == 1.0   , NULL );

  los = m->getListOfSpecies();
  s1 = los->get(0);
  fail_unless ( s1 == s);

  s1 = los->get("X0");
  fail_unless ( s1 == s);

  s = m->getSpecies(1);
  fail_unless( s                            != NULL  , NULL );
  fail_unless( s->getId()                   == "X1"  , NULL );
  fail_unless( s->getCompartment()          == "cell", NULL );
  fail_unless( s->getInitialConcentration() == 0.0   , NULL );

  s = m->getSpecies(2);
  fail_unless( s                            != NULL  , NULL );
  fail_unless( s->getId()                   == "T"   , NULL );
  fail_unless( s->getCompartment()          == "cell", NULL );
  fail_unless( s->getInitialConcentration() == 0.0   , NULL );

  s = m->getSpecies(3);
  fail_unless( s                            != NULL  , NULL );
  fail_unless( s->getId()                   == "S1"  , NULL );
  fail_unless( s->getCompartment()          == "cell", NULL );
  fail_unless( s->getInitialConcentration() == 0.0   , NULL );

  s = m->getSpecies(4);
  fail_unless( s                            != NULL  , NULL );
  fail_unless( s->getId()                   == "S2"  , NULL );
  fail_unless( s->getCompartment()          == "cell", NULL );
  fail_unless( s->getInitialConcentration() == 0.0   , NULL );


  //
  // <listOfParameters>
  //   <parameter id="Keq" value="2.5"/>
  // </listOfParameters>
  //
  fail_unless( m->getNumParameters() == 1, NULL );

  p = m->getParameter(0);

  fail_unless( p             != NULL , NULL );
  fail_unless( p->getId()    == "Keq", NULL );
  fail_unless( p->getValue() == 2.5  , NULL );

  lop = m->getListOfParameters();
  p1 = lop->get(0);
  fail_unless( p1 == p);

  p1 = lop->get("Keq");
  fail_unless( p1 == p);

  /**
   * tests for the unit API functions
   */
  ud = p->getDerivedUnitDefinition();
  fail_unless (ud->getNumUnits() == 0, NULL);

  //
  // <listOfRules> ... </listOfRules>
  //
  fail_unless( m->getNumRules() == 2, NULL );

  //
  // <assignmentRule variable="S1">
  //   <math xmlns="http://www.w3.org/1998/Math/MathML">
  //     <apply>
  //       <divide/>
  //       <ci> T </ci>
  //       <apply>
  //         <plus/>
  //         <cn> 1 </cn>
  //         <ci> Keq </ci>
  //       </apply>
  //     </apply>
  //   </math>
  // </assignmentRule>
  //
  ar = static_cast<AssignmentRule*>( m->getRule(0) );
  fail_unless( ar != NULL, NULL );
  fail_unless( ar->getVariable() == "S1"           , NULL );
  fail_unless( ar->getFormula()  == "T / (1 + Keq)", NULL );

  /**
   * tests for the unit API functions
   */
  ud = ar->getDerivedUnitDefinition();
  fail_unless (ud->getNumUnits() == 2, NULL);
  fail_unless( ud->getUnit(0)->getKind() == UNIT_KIND_MOLE, NULL );
  fail_unless( ud->getUnit(0)->getExponent() ==  1, NULL );
  fail_unless( ud->getUnit(1)->getKind() == UNIT_KIND_LITRE, NULL );
  fail_unless( ud->getUnit(1)->getExponent() ==  -1, NULL );

  fail_unless( ar->containsUndeclaredUnits() == 1, NULL);

  lor = m->getListOfRules();
  ar1 = static_cast <AssignmentRule*> (lor->get(0));
  fail_unless (ar1 == ar);
  
  ar1 = static_cast <AssignmentRule*> (lor->get("S1"));
  fail_unless (ar1 == ar);
  
  //
  // <assignmentRule variable="S2">
  //   <math xmlns="http://www.w3.org/1998/Math/MathML">
  //     <apply>
  //       <times/>
  //       <ci> Keq </ci>
  //       <ci> S1 </ci>
  //     </apply>
  //   </math>
  // </assignmentRule>
  //
  ar = static_cast<AssignmentRule*>( m->getRule(1) );
  fail_unless( ar != NULL, NULL );
  fail_unless( ar->getVariable() == "S2"      , NULL );
  fail_unless( ar->getFormula()  == "Keq * S1", NULL );


  //
  // <listOfReactions> ... </listOfReactions>
  //
  fail_unless( m->getNumReactions() == 2, NULL );

  //
  // <reaction id="in">
  //   <listOfReactants>
  //     <speciesReference species="X0"/>
  //   </listOfReactants>
  //   <listOfProducts>
  //     <speciesReference species="T"/>
  //   </listOfProducts>
  //   <kineticLaw>
  //     <math xmlns="http://www.w3.org/1998/Math/MathML">
  //       <apply>
  //         <times/>
  //         <ci> k1 </ci>
  //         <ci> X0 </ci>
  //       </apply>
  //     </math>
  //     <listOfParameters>
  //       <parameter id="k1" value="0.1"/>
  //     </listOfParameters>
  //   </kineticLaw>
  // </reaction>
  //
  r = m->getReaction(0);

  fail_unless( r          != NULL, NULL );
  fail_unless( r->getId() == "in", NULL );

  fail_unless( r->getNumReactants() == 1, NULL );
  fail_unless( r->getNumProducts () == 1, NULL );

  sr = r->getReactant(0);
  fail_unless( sr               != NULL, NULL );
  fail_unless( sr->getSpecies() == "X0", NULL );

  sr = r->getProduct(0);
  fail_unless( sr               != NULL, NULL );
  fail_unless( sr->getSpecies() == "T" , NULL );

  kl = r->getKineticLaw();
  fail_unless( kl                     != NULL     , NULL );
  fail_unless( kl->getFormula()       == "k1 * X0", NULL );
  fail_unless( kl->getNumParameters() == 1        , NULL );

  r1 = static_cast <Reaction *> (kl->getParentSBMLObject());
  fail_unless( r1          != NULL, NULL );
  fail_unless( r1->getId() == "in", NULL );

  fail_unless( r1->getNumReactants() == 1, NULL );
  fail_unless( r1->getNumProducts () == 1, NULL );


  p = kl->getParameter(0);
  fail_unless( p             != NULL, NULL );
  fail_unless( p->getId()    == "k1", NULL );
  fail_unless( p->getValue() == 0.1 , NULL );

  // the parent of Parameter is ListOfParameters
  // whose parent is the KineticLaw
  kl = static_cast <KineticLaw*> (p->getParentSBMLObject()
    ->getParentSBMLObject());
  fail_unless( kl                     != NULL     , NULL );
  fail_unless( kl->getFormula()       == "k1 * X0", NULL );
  fail_unless( kl->getNumParameters() == 1        , NULL );

  //
  // <reaction id="out">
  //   <listOfReactants>
  //     <speciesReference species="T"/>
  //   </listOfReactants>
  //   <listOfProducts>
  //     <speciesReference species="X1"/>
  //   </listOfProducts>
  //   <kineticLaw>
  //     <math xmlns="http://www.w3.org/1998/Math/MathML">
  //       <apply>
  //         <times/>
  //         <ci> k2 </ci>
  //         <ci> S2 </ci>
  //       </apply>
  //     </math>
  //     <listOfParameters>
  //       <parameter id="k2" value="0.15"/>
  //     </listOfParameters>
  //   </kineticLaw>
  // </reaction>
  //
  r = m->getReaction(1);

  fail_unless( r          != NULL , NULL );
  fail_unless( r->getId() == "out", NULL );

  fail_unless( r->getNumReactants() == 1, NULL );
  fail_unless( r->getNumProducts () == 1, NULL );

  sr = r->getReactant(0);
  fail_unless( sr               != NULL, NULL );
  fail_unless( sr->getSpecies() == "T" , NULL );

  sr = r->getProduct(0);
  fail_unless( sr               != NULL, NULL );
  fail_unless( sr->getSpecies() == "X1", NULL );

  kl = r->getKineticLaw();
  fail_unless( kl                     != NULL     , NULL );
  fail_unless( kl->getFormula()       == "k2 * T", NULL );
  fail_unless( kl->getNumParameters() == 1        , NULL );

  p = kl->getParameter(0);
  fail_unless( p             != NULL, NULL );
  fail_unless( p->getId()    == "k2", NULL );
  fail_unless( p->getValue() == 0.15, NULL );

  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile5 (void)
{ 
  Suite *suite = suite_create("test-data/l2v1-assignment.xml");
  TCase *tcase = tcase_create("test-data/l2v1-assignment.xml");


  tcase_add_test(tcase, test_read_l2v1_assignment);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
