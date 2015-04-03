/**
 * \file    TestReadFromFile7.cpp
 * \brief   Reads test-data/l2v3-all.xml into memory and tests it.
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_read_l2v3_all)
{
  SBMLReader        reader;
  SBMLDocument*     d;
  Model*            m;
  Compartment*      c;
  CompartmentType*  ct;
  Species*          s;
  Parameter*        p;
  AssignmentRule*   ar;
  Reaction*         r;
  SpeciesReference* sr;
  KineticLaw*       kl;
  UnitDefinition*   ud;
  Constraint*       con;
  Event*            e;
  Delay*            delay;
  Trigger*          trigger;
  EventAssignment*  ea;
  FunctionDefinition* fd;
  InitialAssignment* ia;
  AlgebraicRule*   alg;
  RateRule*        rr;
  SpeciesType*     st;
  StoichiometryMath* stoich;
  Unit* u;
  ListOfEvents *loe;
  Event *e1;
  ListOfEventAssignments *loea;
  EventAssignment *ea1;
  ListOfFunctionDefinitions *lofd;
  FunctionDefinition * fd1;
  ListOfParameters *lop;
  Parameter *p1;
  ListOfSpeciesTypes *lost;
  SpeciesType *st1;
  ListOfUnitDefinitions *loud;
  UnitDefinition *ud1;
  ListOfUnits *lou;
  Unit * u1;
  
  const ASTNode*   ast;

  std::string filename(TestDataDirectory);
  filename += "l2v3-all.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l2v3-all.xml\") returned a NULL pointer.");
  }



  //
  // <sbml level="2" version="3" ...>
  //
  fail_unless( d->getLevel  () == 2, NULL );
  fail_unless( d->getVersion() == 3, NULL );


  //
  // <model id="l2v3_all">
  //
  m = d->getModel();
  fail_unless( m != NULL, NULL );

  fail_unless(m->getId() == "l2v3_all", NULL);


  //<listOfCompartments>
  //  <compartment id="a" size="2.3" compartmentType="hh" sboTerm="SBO:0000236"/>
  //</listOfCompartments>
  fail_unless( m->getNumCompartments() == 1, NULL );

  c = m->getCompartment(0);
  fail_unless( c          != NULL  , NULL );
  fail_unless( c->getId() == "a", NULL );
  fail_unless( c->getCompartmentType() == "hh", NULL );
  fail_unless( c->getSBOTerm() == 236, NULL );
  fail_unless( c->getSBOTermID() == "SBO:0000236", NULL );
  fail_unless( c->getSize() == 2.3, NULL );

  //<listOfCompartmentTypes>
  //  <compartmentType id="hh" sboTerm="SBO:0000236"/>
  //</listOfCompartmentTypes>
  fail_unless( m->getNumCompartmentTypes() == 1, NULL );

  ct = m->getCompartmentType(0);
  fail_unless( ct         != NULL  , NULL );
  fail_unless( ct->getId() == "hh", NULL );
  fail_unless( ct->getSBOTerm() == 236, NULL );
  fail_unless( ct->getSBOTermID() == "SBO:0000236", NULL );

  //<listOfSpeciesTypes>
  //  <speciesType id="gg" name="dd" sboTerm="SBO:0000236"/>
  //</listOfSpeciesTypes>
  fail_unless( m->getNumSpeciesTypes() == 1, NULL );

  st = m->getSpeciesType(0);
  fail_unless( st         != NULL  , NULL );
  fail_unless( st->getId() == "gg", NULL );
  fail_unless( st->getName() == "dd", NULL );
  fail_unless( st->getSBOTerm() == 236, NULL );
  fail_unless( st->getSBOTermID() == "SBO:0000236", NULL );

  lost = m->getListOfSpeciesTypes();
  st1 = lost->get(0);
  fail_unless( st1 == st);

  st1 = lost->get("gg");
  fail_unless( st1 == st);

  //<listOfConstraints>
  //  <constraint>
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <lt/>
  //        <ci> x </ci>
  //        <cn type="integer"> 3 </cn>
  //      </apply>
  //    </math>
  //  </constraint>
  //</listOfConstraints>
  fail_unless( m->getNumConstraints() == 1, NULL );

  con = m->getConstraint(0);
  fail_unless( con         != NULL  , NULL );

  ast = con->getMath();
  char* math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "lt(x, 3)"), NULL);           
  safe_free(math);

  //<event id="e1" sboTerm="SBO:0000231">
  //  <trigger sboTerm="SBO:0000231">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <lt/>
  //        <ci> x </ci>
  //        <cn type="integer"> 3 </cn>
  //      </apply>
  //    </math>
  //  </trigger>
  //  <delay sboTerm="SBO:0000064">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <plus/>
  //        <ci> x </ci>
  //        <cn type="integer"> 3 </cn>
  //      </apply>
  //    </math>
  //  </delay>
  //  <listOfEventAssignments>
  //    <eventAssignment variable="a" sboTerm="SBO:0000064">
  //      <math xmlns="http://www.w3.org/1998/Math/MathML">
  //        <apply>
  //          <times/>
  //          <ci> x </ci>
  //          <ci> p3 </ci>
  //        </apply>
  //      </math>
  //    </eventAssignment>
  //  </listOfEventAssignments>
  //</event>
  fail_unless( m->getNumEvents() == 1, NULL );

  e = m->getEvent(0);
  fail_unless(e != NULL, NULL);

  fail_unless(e->getId() == "e1", NULL);

  fail_unless(e->getSBOTerm() == 231, NULL);
  fail_unless(e->getSBOTermID() == "SBO:0000231");

  fail_unless(e->isSetDelay(), NULL);
  
  delay = e->getDelay();
  fail_unless(delay != NULL, NULL);

  fail_unless(delay->getSBOTerm() == 64, NULL);
  fail_unless(delay->getSBOTermID() == "SBO:0000064");

  ast = delay->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "p + 3"), NULL);
  safe_free(math);

  fail_unless(e->isSetTrigger(), NULL);
  
  trigger = e->getTrigger();
  fail_unless(trigger != NULL, NULL);

  fail_unless(trigger->getSBOTerm() == 64, NULL);
  fail_unless(trigger->getSBOTermID() == "SBO:0000064");

  ast = trigger->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "lt(x, 3)"), NULL);
  safe_free(math);

  loe = m->getListOfEvents();
  e1 = loe->get(0);
  fail_unless( e1 == e);

  e1 = loe->get("e1");
  fail_unless( e1 == e);

  fail_unless( e->getNumEventAssignments() == 1, NULL );

  ea = e->getEventAssignment(0);
  fail_unless(ea != NULL, NULL);

  fail_unless(ea->getVariable() == "a", NULL);
  fail_unless(ea->getSBOTerm() == 64, NULL);
  fail_unless(ea->getSBOTermID() == "SBO:0000064");

  ast = ea->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "x * p3"), NULL);
  safe_free(math);

  loea = e->getListOfEventAssignments();
  ea1 = loea->get(0);
  fail_unless( ea1 == ea);

  ea1 = loea->get("a");
  fail_unless( ea1 == ea);

  //<listOfFunctionDefinitions>
  //  <functionDefinition id="fd" sboTerm="SBO:0000064">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <lambda>
  //        <bvar>
  //          <ci> x </ci>
  //        </bvar>
  //        <apply>
  //          <power/>
  //          <ci> x </ci>
  //          <cn type="integer"> 3 </cn>
  //        </apply>
  //      </lambda>
  //    </math>
  //  </functionDefinition>
  //</listOfFunctionDefinitions>

  fail_unless( m->getNumFunctionDefinitions() == 1, NULL );

  fd = m->getFunctionDefinition(0);
  fail_unless(fd != NULL, NULL);

  fail_unless(fd->getId() == "fd", NULL);

  fail_unless(fd->getSBOTerm() == 64, NULL);
  fail_unless(fd->getSBOTermID() == "SBO:0000064");

  ast = fd->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "lambda(x, pow(x, 3))"), NULL);
  safe_free(math);

  lofd = m->getListOfFunctionDefinitions();
  fd1 = lofd->get(0);
  fail_unless( fd1 == fd);

  fd1 = lofd->get("fd");
  fail_unless( fd1 == fd);

  //<listOfInitialAssignments>
  //  <initialAssignment symbol="p1">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <times/>
  //        <ci> x </ci>
  //        <ci> p3 </ci>
  //      </apply>
  //    </math>
  //  </initialAssignment>
  //</listOfInitialAssignments>
  fail_unless( m->getNumInitialAssignments() == 1, NULL );

  ia = m->getInitialAssignment(0);
  fail_unless( ia         != NULL  , NULL );
  fail_unless(ia->getSymbol() == "p1", NULL);

  ast = ia->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "x * p3"), NULL);
  safe_free(math);

  //<listOfRules>
  fail_unless( m->getNumRules() == 3, NULL );
  
  
  //  <algebraicRule sboTerm="SBO:0000064">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <power/>
  //        <ci> x </ci>
  //        <cn type="integer"> 3 </cn>
  //      </apply>
  //    </math>
  //  </algebraicRule>
  alg = static_cast<AlgebraicRule*>( m->getRule(0));

  fail_unless( alg         != NULL  , NULL );
  fail_unless(alg->getSBOTerm() == 64, NULL);
  fail_unless(alg->getSBOTermID() == "SBO:0000064");

  ast = alg->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "pow(x, 3)"), NULL);
  safe_free(math);

  //  <assignmentRule variable="p2" sboTerm="SBO:0000064">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <times/>
  //        <ci> x </ci>
  //        <ci> p3 </ci>
  //      </apply>
  //    </math>
  //  </assignmentRule>
  ar = static_cast <AssignmentRule*>(m->getRule(1));

  fail_unless( ar         != NULL  , NULL );
  fail_unless( ar->getVariable() == "p2", NULL);
  fail_unless(ar->getSBOTerm() == 64, NULL);
  fail_unless(ar->getSBOTermID() == "SBO:0000064");

  ast = ar->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "x * p3"), NULL);
  safe_free(math);


  //  <rateRule variable="p3" sboTerm="SBO:0000064">
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <divide/>
  //        <ci> p1 </ci>
  //        <ci> p </ci>
  //      </apply>
  //    </math>
  //  </rateRule>
  rr = static_cast<RateRule*> (m->getRule(2));

  fail_unless( rr         != NULL  , NULL );
  fail_unless( rr->getVariable() == "p3", NULL);
  fail_unless(rr->getSBOTerm() == 64, NULL);
  fail_unless(rr->getSBOTermID() == "SBO:0000064");

  ast = rr->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "p1 / p"), NULL);
  safe_free(math);

  //<listOfSpecies>
  //  <species id="s" compartment="a" initialAmount="0" speciesType="gg" sboTerm="SBO:000236"/>
  //</listOfSpecies>
  fail_unless( m->getNumSpecies() == 1, NULL );

  s = m->getSpecies(0);
  fail_unless( s          != NULL  , NULL );
  fail_unless( s->getId() == "s", NULL );
  fail_unless( s->getSpeciesType() == "gg", NULL );
  fail_unless( s->getCompartment() == "a", NULL );
  fail_unless(s->getSBOTerm() == 236, NULL);
  fail_unless(s->getSBOTermID() == "SBO:0000236");
  fail_unless(s->isSetInitialAmount(), NULL);
  fail_unless(!s->isSetInitialConcentration(), NULL);
  fail_unless(s->getInitialAmount() == 0, NULL);


  //<listOfReactions>
  //  <reaction id="r" fast="true" reversible="false">
  //    <listOfReactants>
  //      <speciesReference species="s" sboTerm="SBO:0000011">
  //        <stoichiometryMath sboTerm="SBO:0000064">
  //          <math xmlns="http://www.w3.org/1998/Math/MathML">
  //            <apply>
  //              <times/>
  //              <ci> s </ci>
  //              <ci> p </ci>
  //            </apply>
  //          </math>
  //        </stoichiometryMath>
  //      </speciesReference>
  //    </listOfReactants>
  //    <kineticLaw>
  //      <math xmlns="http://www.w3.org/1998/Math/MathML">
  //        <apply>
  //          <divide/>
  //          <apply>
  //            <times/>
  //            <ci> s </ci>
  //            <ci> k </ci>
  //          </apply>
  //          <ci> p </ci>
  //        </apply>
  //      </math>
  //      <listOfParameters>
  //        <parameter id="k" value="9" units="litre"/>
  //      </listOfParameters>
  //    </kineticLaw>
  //  </reaction>
  //</listOfReactions>
  fail_unless( m->getNumReactions() == 1, NULL );

  r = m->getReaction(0);
  fail_unless( r         != NULL  , NULL );
  fail_unless(r->getId() == "r", NULL);
  fail_unless(!r->getReversible(), NULL);
  fail_unless(r->getFast(), NULL);

  fail_unless(r->isSetKineticLaw(), NULL);

  kl = r->getKineticLaw();
  fail_unless( kl         != NULL  , NULL );

  fail_unless(kl->isSetMath(), NULL);

  ast = kl->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "s * k / p"), NULL);
  safe_free(math);

  fail_unless(kl->getNumParameters() == 2, NULL);

  p = kl->getParameter(0);
  fail_unless( p         != NULL  , NULL );
  fail_unless(p->getId() == "k", NULL);
  fail_unless(p->getUnits() == "litre", NULL);
  fail_unless(p->getValue() == 9, NULL);

  ud = p->getDerivedUnitDefinition();
  fail_unless (ud->getNumUnits() == 1, NULL);
  fail_unless( ud->getUnit(0)->getKind() == UNIT_KIND_LITRE, NULL );
  fail_unless( ud->getUnit(0)->getExponent() ==  1, NULL );

  lop = kl->getListOfParameters();
  p1 = lop->get(0);
  fail_unless( p1 == p);

  p1 = lop->get("k");
  fail_unless( p1 == p);

  p = kl->getParameter(1);
  fail_unless( p         != NULL  , NULL );
  fail_unless(p->getId() == "k1", NULL);
  fail_unless(p->getUnits() == "ud1", NULL);
  fail_unless(p->getValue() == 9, NULL);

  ud = p->getDerivedUnitDefinition();
  fail_unless (ud->getNumUnits() == 1, NULL);
  fail_unless( ud->getUnit(0)->getKind() == UNIT_KIND_MOLE, NULL );
  fail_unless( ud->getUnit(0)->getExponent() ==  1, NULL );

  fail_unless(r->getNumReactants() == 1, NULL);
  fail_unless(r->getNumProducts() == 0, NULL);
  fail_unless(r->getNumModifiers() == 0, NULL);

  sr = r->getReactant(0);
  fail_unless( sr         != NULL  , NULL );
  fail_unless(sr->getSpecies() == "s", NULL);
  fail_unless(sr->getSBOTerm() == 11, NULL);
  fail_unless(sr->getSBOTermID() == "SBO:0000011", NULL);

  stoich = sr->getStoichiometryMath();
  fail_unless( stoich         != NULL  , NULL );
  fail_unless(stoich->getSBOTerm() == 64, NULL);
  fail_unless(stoich->getSBOTermID() == "SBO:0000064", NULL);

  ast = stoich->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "s * p"), NULL);
  safe_free(math);

  //<listOfUnitDefinitions>
  //  <unitDefinition id="ud1">
  //    <listOfUnits>
  //      <unit kind="mole"/>
  //    </listOfUnits>
  //  </unitDefinition>
  //</listOfUnitDefinitions>

  fail_unless(m->getNumUnitDefinitions() == 1, NULL);

  ud = m->getUnitDefinition(0);
  fail_unless( ud          != NULL  , NULL );
  fail_unless( ud->getId() == "ud1", NULL );

  loud = m->getListOfUnitDefinitions();
  ud1 = loud->get(0);
  fail_unless (ud1 == ud);

  ud1 = loud->get("ud1");
  fail_unless ( ud1 == ud);

  fail_unless(ud->getNumUnits() == 1, NULL);

  u = ud->getUnit(0);
  fail_unless( u          != NULL  , NULL );
  fail_unless( u->getKind() == UNIT_KIND_MOLE, NULL );

  lou = ud->getListOfUnits();
  u1 = lou->get(0);
  fail_unless (u1 == u);

  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile7 (void)
{ 
  Suite *suite = suite_create("test-data/l2v3-all.xml");
  TCase *tcase = tcase_create("test-data/l2v3-all.xml");


  tcase_add_test(tcase, test_read_l2v3_all);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
