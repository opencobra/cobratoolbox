/**
 * \file    TestReadFromFile9.c
 * \brief   Reads tests/l3v1-new.xml into memory and tests it.
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
#include <limits>

#include <check.h>



LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

extern char *TestDataDirectory;


START_TEST (test_read_l3v1_new)
{
  SBMLReader        reader;
  SBMLDocument*     d;
  Model*            m;
  UnitDefinition*   ud;
  Unit*             u;
  Compartment*      c;
  Species*          s;
  Parameter*        p;
  Reaction*         r;
  SpeciesReference* sr;
  KineticLaw*       kl;
  LocalParameter*   lp;
  Event *           e;
  Trigger *         t;
  Priority*         pr;

  std::string filename(TestDataDirectory);
  filename += "l3v1-new-invalid.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l3v1-new-invalid.xml\") returned a NULL pointer.");
  }


  //
  // <sbml level="3" version="1" ...>
  //
  fail_unless( d->getLevel  () == 3, NULL );
  fail_unless( d->getVersion() == 1, NULL );


  //
  // <model>
  //
  m = d->getModel();
  fail_unless( m != NULL, NULL );

  //<model timeUnits="second" extentUnits="mole"
  //       volumeUnits="litre" areaUnits="metre" lengthUnits="metre"
  //       conversionFactor="p">

  fail_unless(m->isSetSubstanceUnits());
  fail_unless(m->isSetTimeUnits());
  fail_unless(m->isSetVolumeUnits());
  fail_unless(m->isSetLengthUnits());
  fail_unless(m->isSetAreaUnits());
  fail_unless(m->isSetExtentUnits());
  fail_unless(m->isSetConversionFactor());

  fail_unless(m->getSubstanceUnits() == "mole");
  fail_unless(m->getTimeUnits() == "second");
  fail_unless(m->getVolumeUnits() == "litre");
  fail_unless(m->getLengthUnits() == "metre");
  fail_unless(m->getAreaUnits() == "metre");
  fail_unless(m->getExtentUnits() == "mole");
  fail_unless(m->getConversionFactor() == "p");

     //<listOfUnitDefinitions>
     //  <unitDefinition id="per_second">
     //     <listOfUnits>
     //        <unit kind="second"/>
     //     </listOfUnits>
     //  </unitDefinition>
     //  <unitDefinition id="nonsense">
     //     <listOfUnits>
     //        <unit kind="mole"   exponent="-1" scale="2" multiplier="1.3"/>
     //        <unit kind="litre"  exponent="1.5"  scale="10" multiplier="0.5"/>
     //        <unit kind="second" exponent="1" scale="0" multiplier="1"/>
     //     </listOfUnits>
     //  </unitDefinition>
     //</listOfUnitDefinitions>

  fail_unless(m->getNumUnitDefinitions() == 2);

  ud = m->getUnitDefinition(0);

  fail_unless(ud->getNumUnits() == 1);

  u = ud->getUnit(0);

  fail_unless(!u->isSetExponent());
  fail_unless(!u->isSetScale());
  fail_unless(!u->isSetMultiplier());
  fail_unless(util_isNaN(u->getExponentAsDouble()));
  fail_unless( u->getScale() == SBML_INT_MAX );
  fail_unless(util_isNaN(u->getMultiplier()));

  
  ud = m->getUnitDefinition(1);

  fail_unless(ud->getNumUnits() == 3);

  u = ud->getUnit(0);

  fail_unless(u->isSetExponent());
  fail_unless(u->isSetScale());
  fail_unless(u->isSetMultiplier());
  fail_unless(u->getExponent() == -1);
  fail_unless(u->getExponentAsDouble() == -1);
  fail_unless(u->getScale() == 2);
  fail_unless(u->getMultiplier() == 1.3);

  u = ud->getUnit(1);

  fail_unless(u->isSetExponent());
  fail_unless(u->isSetScale());
  fail_unless(u->isSetMultiplier());
  fail_unless(u->getExponentAsDouble() == 1.5);
  fail_unless(u->getScale() == 10);
  fail_unless(u->getMultiplier() == 0.5);

  u = ud->getUnit(2);

  fail_unless(u->isSetExponent());
  fail_unless(u->isSetScale());
  fail_unless(u->isSetMultiplier());
  fail_unless(u->getExponent() == 1);
  fail_unless(u->getScale() == 0);
  fail_unless(u->getMultiplier() == 1);

     //<listOfCompartments>
     //  <compartment id="comp" size="1e-14" spatialDimensions="3" units="litre" constant="true"/>
     // <compartment id="comp1" constant="false"/>
     // <compartment id="comp2" spatialDimensions="4.6"/>
     //</listOfCompartments>

  fail_unless (m->getNumCompartments() == 3);

  c = m->getCompartment(0);

  fail_unless(c->isSetSize());
  fail_unless(c->isSetSpatialDimensions());
  fail_unless(c->isSetConstant());
  fail_unless(c->getId() == "comp");
  fail_unless(c->getSize() == 1e-14);
  fail_unless(c->getSpatialDimensions() == 3);
  fail_unless(c->getSpatialDimensionsAsDouble() == 3);
  fail_unless(c->getUnits() == "litre");
  fail_unless(c->getConstant() == true);

  c = m->getCompartment(1);

  fail_unless(!c->isSetSize());
  fail_unless(!c->isSetSpatialDimensions());
  fail_unless(c->isSetConstant());
  fail_unless(c->getId() == "comp1");
  fail_unless(util_isNaN(c->getSize()));
  fail_unless(util_isNaN(c->getSpatialDimensionsAsDouble()));
  //fail_unless(util_isNaN(c->getSpatialDimensions()));
  fail_unless(c->getConstant() == false);

  c = m->getCompartment(2);

  fail_unless(!c->isSetSize());
  fail_unless(c->isSetSpatialDimensions());
  fail_unless(!c->isSetConstant());
  fail_unless(c->getId() == "comp2");
  fail_unless(c->getSpatialDimensionsAsDouble() == 4.6);
  //fail_unless(util_isNaN(c->getSpatialDimensions()));
//  fail_unless(c->getConstant() == false);


       //<species compartment="comp" id="ES" initialAmount="0"     boundaryCondition="false"
       //         hasOnlySubstanceUnits="false" substanceUnits="mole" constant="false" conversionFactor="p"/>
       //<species compartment="comp" id="P"/>

  fail_unless(m->getNumSpecies() == 2);

  s = m->getSpecies(0);

  fail_unless(s->getId() == "ES");
  fail_unless(s->getCompartment() == "comp");
  fail_unless(s->isSetConversionFactor());
  fail_unless(s->getConversionFactor() == "p");
  fail_unless(s->isSetBoundaryCondition());
  fail_unless(s->getBoundaryCondition() == false);
  fail_unless(s->isSetHasOnlySubstanceUnits());
  fail_unless(s->getHasOnlySubstanceUnits() == false);
  fail_unless(s->isSetSubstanceUnits());
  fail_unless(s->getSubstanceUnits() == "mole");
  fail_unless(s->isSetConstant());
  fail_unless(s->getConstant() == false);
  fail_unless(s->isSetInitialAmount());
  fail_unless(s->getInitialAmount() == 0);
  fail_unless(!s->isSetInitialConcentration());
  fail_unless(util_isNaN(s->getInitialConcentration()));

  s = m->getSpecies(1);

  fail_unless(s->getId() == "P");
  fail_unless(s->getCompartment() == "comp");
  fail_unless(!s->isSetConversionFactor());
  fail_unless(s->getConversionFactor() == "");
  fail_unless(!s->isSetBoundaryCondition());
//  fail_unless(s->getBoundaryCondition() == false);
  fail_unless(!s->isSetHasOnlySubstanceUnits());
//  fail_unless(s->getHasOnlySubstanceUnits() == false);
  fail_unless(!s->isSetSubstanceUnits());
  fail_unless(s->getSubstanceUnits() == "");
  fail_unless(!s->isSetConstant());
//  fail_unless(s->getConstant() == false);
  fail_unless(!s->isSetInitialAmount());
  fail_unless(util_isNaN(s->getInitialAmount()));
  fail_unless(!s->isSetInitialConcentration());
  fail_unless(util_isNaN(s->getInitialConcentration()));

     //<listOfParameters>
     //   <parameter id="Keq" value="2.5" units="dimensionless" constant="true"/>
     //   <parameter id="Keq1" constant="false"/>
     //   <parameter id="Keq2"/>
     //</listOfParameters>

  fail_unless(m->getNumParameters() == 3);

  p = m->getParameter(0);

  fail_unless(p->getId() == "Keq");
  fail_unless(p->isSetValue());
  fail_unless(p->getValue() == 2.5);
  fail_unless(p->isSetUnits());
  fail_unless(p->getUnits() == "dimensionless");
  fail_unless(p->isSetConstant());
  fail_unless(p->getConstant() == true);

  p = m->getParameter(1);

  fail_unless(p->getId() == "Keq1");
  fail_unless(!p->isSetValue());
  fail_unless(util_isNaN(p->getValue()));
  fail_unless(!p->isSetUnits());
  fail_unless(p->getUnits() == "");
  fail_unless(p->isSetConstant());
  fail_unless(p->getConstant() == false);

  p = m->getParameter(2);

  fail_unless(p->getId() == "Keq2");
  fail_unless(!p->isSetValue());
  fail_unless(util_isNaN(p->getValue()));
  fail_unless(!p->isSetUnits());
  fail_unless(p->getUnits() == "");
  fail_unless(!p->isSetConstant());
//  fail_unless(p->getConstant() == false);



  fail_unless(m->getNumReactions() == 3);

  r = m->getReaction(0);

  fail_unless(r->isSetFast());
  fail_unless(r->getFast() == false);
  fail_unless(r->isSetReversible());
  fail_unless(r->getReversible() == false);
  fail_unless(r->isSetCompartment());
  fail_unless(r->getCompartment() == "comp");

  sr = r->getReactant(0);

  fail_unless(sr->isSetConstant());
  fail_unless(sr->getConstant() == true);
  fail_unless(sr->isSetStoichiometry());
  fail_unless(sr->getStoichiometry() == 1);

  sr = r->getProduct(0);

  fail_unless(sr->isSetConstant());
  fail_unless(sr->getConstant() == false);
  fail_unless(!sr->isSetStoichiometry());
  fail_unless(util_isNaN(sr->getStoichiometry()));


  kl = r->getKineticLaw();

  fail_unless(kl->getNumLocalParameters() == 2);
  fail_unless(kl->getNumParameters() == 2);

  p = kl->getParameter(0);
  
  fail_unless(p->isSetUnits());
  fail_unless(p->getUnits() == "per_second");
  fail_unless(p->isSetValue());
  fail_unless(p->getValue() == 0.1);

  lp = kl->getLocalParameter(0);

  fail_unless(lp->isSetUnits());
  fail_unless(lp->getUnits() == "per_second");
  fail_unless(lp->isSetValue());
  fail_unless(lp->getValue() == 0.1);

  lp = kl->getLocalParameter(1);

  fail_unless(!lp->isSetUnits());
  fail_unless(lp->getUnits() == "");
  fail_unless(!lp->isSetValue());
  fail_unless(util_isNaN(lp->getValue()));


  r = m->getReaction(1);

  fail_unless(r->isSetFast());
  fail_unless(r->getFast() == true);
  fail_unless(r->isSetReversible());
  fail_unless(r->getReversible() == true);
  fail_unless(!r->isSetCompartment());
  fail_unless(r->getCompartment() == "");

  sr = r->getReactant(0);

  fail_unless(!sr->isSetConstant());
//  fail_unless(sr->getConstant() == true);

  r = m->getReaction(2);

  fail_unless(!r->isSetFast());
//  fail_unless(r->getFast() == false);
  fail_unless(!r->isSetReversible());
//  fail_unless(r->getReversible() == false);
  fail_unless(!r->isSetCompartment());
  fail_unless(r->getCompartment() == "");

     //<listOfEvents>
     //  <event useValuesFromTriggerTime="true">
     //    <trigger initialValue="false" persistent="false">
     //       <math xmlns="http://www.w3.org/1998/Math/MathML">
     //           <true/>
     //       </math>
     //    </trigger>
         // <priority>
         //   <math xmlns="http://www.w3.org/1998/Math/MathML">
         //       <cn> 1 </cn>
         //   </math>
         //</priority>
    //  </event>
     //  <event>
     //    <trigger>
     //       <math xmlns="http://www.w3.org/1998/Math/MathML">
     //           <true/>
     //       </math>
     //    </trigger>
     //  </event>
     //</listOfEvents>

  e = m->getEvent(0);
  t = e->getTrigger();

  fail_unless (t->isSetPersistent());
  fail_unless (t->getPersistent() == false );
  fail_unless (t->isSetInitialValue());
  fail_unless (t->getInitialValue() == false );

  fail_unless (e->isSetPriority());

  pr = e->getPriority();

  fail_unless (pr != NULL);
  fail_unless (pr->isSetMath());


  e = m->getEvent(1);
  fail_unless (!e->isSetPriority());
  t = e->getTrigger();

  fail_unless (!(t->isSetPersistent()));
  fail_unless (!(t->isSetInitialValue()));

  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile9 (void)
{ 
  Suite *suite = suite_create("test-data/l3v1-new.xml");
  TCase *tcase = tcase_create("test-data/l3v1-new.xml");


  tcase_add_test(tcase, test_read_l3v1_new);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

