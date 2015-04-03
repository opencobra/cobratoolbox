/**
 * \file    TestWriteL3SBML.cpp
 * \brief   Write SBML unit tests
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

#include <iostream>
#include <sstream>

#include <sbml/xml/XMLOutputStream.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/util/util.h>

#include <sbml/SBMLTypes.h>
#include <sbml/SBMLWriter.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


#include <sbml/common/extern.h>

BEGIN_C_DECLS

/**
 * Wraps the string s in the appropriate XML boilerplate.
 */
#define XML_START   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define SBML_START  "<sbml "
#define NS_L3v1     "xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" "
#define LV_L3v1     "level=\"3\" version=\"1\">\n"
#define SBML_END    "</sbml>\n"

#define wrapXML(s)        XML_START s
#define wrapSBML_L3v1(s)  XML_START SBML_START NS_L3v1 LV_L3v1 s SBML_END


static SBMLDocument* D;


static void
WriteL3SBML_setup ()
{
  D = new SBMLDocument();
  D->setLevelAndVersion(3, 1, false);
}


static void
WriteL3SBML_teardown ()
{
  delete D;
}


static bool
equals (const char* expected, const char* actual)
{
  if ( !strcmp(expected, actual) ) return true;

  printf( "\nStrings are not equal:\n"  );
  printf( "Expected:\n[%s]\n", expected );
  printf( "Actual:\n[%s]\n"  , actual   );

  return false;
}


START_TEST (test_WriteL3SBML_error)
{
  SBMLDocument *d = new SBMLDocument();
  SBMLWriter   *w = new SBMLWriter();

  fail_unless( ! w->writeSBML(d, "/tmp/impossible/path/should/fail") );
  fail_unless( d->getNumErrors() == 1 );
  fail_unless( d->getError(0)->getErrorId() == XMLFileUnwritable );

  delete d;
  delete w;
}
END_TEST


START_TEST (test_SBMLWriter_L3_create)
{
  SBMLWriter_t   *w = SBMLWriter_create();

  fail_unless( w != NULL );

  SBMLWriter_free(w);
}
END_TEST


START_TEST (test_SBMLWriter_L3_setProgramName)
{
  SBMLWriter_t   *w = SBMLWriter_create();

  fail_unless( w != NULL );

  int i = SBMLWriter_setProgramName(w, "sss");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  i = SBMLWriter_setProgramName(w, NULL);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  
  SBMLWriter_free(w);
}
END_TEST


START_TEST (test_SBMLWriter_L3_setProgramVersion)
{
  SBMLWriter_t   *w = SBMLWriter_create();

  fail_unless( w != NULL );

  int i = SBMLWriter_setProgramVersion(w, "sss");

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  i = SBMLWriter_setProgramVersion(w, NULL);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  
  SBMLWriter_free(w);
}
END_TEST


START_TEST (test_WriteL3SBML_SBMLDocument_L3v1)
{
  const char *expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" "
    "level=\"3\" version=\"1\"/>\n"
  );


  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Model)
{
  const char* expected = wrapSBML_L3v1(
    "  <model/>\n"
    );

  Model * m = D->createModel("");
  (void) m;

  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Model_substanceUnits)
{
  const char* expected = wrapSBML_L3v1(
    "  <model substanceUnits=\"mole\"/>\n"
    );

  Model * m = D->createModel("");
  m->setSubstanceUnits("mole");


  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Model_timeUnits)
{
  const char* expected = wrapSBML_L3v1(
    "  <model timeUnits=\"second\"/>\n"
    );

  Model * m = D->createModel("");
  m->setTimeUnits("second");


  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Model_otherUnits)
{
  const char* expected = wrapSBML_L3v1(
    "  <model volumeUnits=\"litre\" areaUnits=\"area\" lengthUnits=\"metre\"/>\n"
    );

  Model * m = D->createModel("");
  m->setVolumeUnits("litre");
  m->setAreaUnits("area");
  m->setLengthUnits("metre");

  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Model_conversionFactor)
{
  const char* expected = wrapSBML_L3v1(
    "  <model conversionFactor=\"p\"/>\n"
    );

  Model * m = D->createModel("");
  m->setConversionFactor("p");


  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST


START_TEST (test_WriteL3SBML_Unit)
{
  const char* expected = "<unit kind=\"kilogram\" exponent=\"0.2\""
    " scale=\"-3\" multiplier=\"3.2\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  double exp = 0.2;
  u->setExponent(exp);
  u->setScale(-3);
  u->setMultiplier(3.2);

  char* sbml = u->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Unit_noValues)
{
  const char* expected = "<unit/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();

  char* usbml = u->toSBML();
  fail_unless( equals(expected, usbml) );
  safe_free(usbml);

}
END_TEST


START_TEST (test_WriteL3SBML_UnitDefinition)
{

  const char* expected = 
    "<unitDefinition id=\"myUnit\">\n"
    "  <listOfUnits>\n"
    "    <unit kind=\"mole\" exponent=\"1\" scale=\"0\" multiplier=\"1.8\"/>\n"
    "  </listOfUnits>\n"
    "</unitDefinition>";

  UnitDefinition* ud = D->createModel()->createUnitDefinition();
  ud->setId("myUnit");

  Unit* u1 = ud->createUnit();
  u1->setKind(UnitKind_forName("mole"));
  u1->setMultiplier(1.8);
  u1->setScale(0);
  u1->setExponent(1);

  char* sbml = ud->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Compartment)
{
  const char* expected = "<compartment id=\"A\" constant=\"true\"/>";

  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");

  c->setConstant(true);

  char* sbml = c->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Compartment_spatialDimensions)
{
  const char* expected = "<compartment id=\"A\" spatialDimensions=\"2.1\" "
    "constant=\"false\"/>";

  const char* expected1 = "<compartment id=\"A\" constant=\"false\"/>";

  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");

  c->setConstant(false);
  c->setSpatialDimensions(2.1);

  char* sbml = c->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);

  c->unsetSpatialDimensions();

  sbml = c->toSBML();
  fail_unless( equals(expected1, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Species)
{
  const char* expected = 
    "<species id=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\""
    " substanceUnits=\"mole\" hasOnlySubstanceUnits=\"false\""
    " boundaryCondition=\"true\" constant=\"true\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");
  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setUnits("mole");
  s->setBoundaryCondition(true);
  s->setHasOnlySubstanceUnits(false);
  s->setConstant(true);

  char* sbml = s->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Species_conversionFactor)
{
  const char* expected = 
    "<species id=\"Ca2\" compartment=\"cell\""
    " hasOnlySubstanceUnits=\"false\""
    " boundaryCondition=\"true\" constant=\"true\""
    " conversionFactor=\"p\"/>";

  const char* expected1 = 
    "<species id=\"Ca2\" compartment=\"cell\""
    " hasOnlySubstanceUnits=\"false\""
    " boundaryCondition=\"true\" constant=\"true\"/>";

  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");
  s->setCompartment("cell");
  s->setBoundaryCondition(true);
  s->setHasOnlySubstanceUnits(false);
  s->setConstant(true);
  s->setConversionFactor("p");

  char* sbml = s->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);

  s->unsetConversionFactor();

  sbml = s->toSBML();
  fail_unless( equals(expected1, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Parameter)
{
  const char* expected = "<parameter id=\"Km1\" value=\"2.3\""
    " units=\"second\" constant=\"true\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");
  p->setValue(2.3);
  p->setUnits("second");
  p->setConstant(true);

  char* sbml = p->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Reaction)
{
  const char* expected = "<reaction id=\"r\" reversible=\"false\""
    " fast=\"true\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");
  r->setReversible(false);
  r->setFast(true);

  char* sbml = r->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Reaction_compartment)
{
  const char* expected = "<reaction id=\"r\" reversible=\"false\""
    " fast=\"true\" compartment=\"c\"/>";

  const char* expected1 = "<reaction id=\"r\" reversible=\"false\""
    " fast=\"true\"/>";

  Reaction *r = D->createModel()->createReaction();
  r->setId("r");
  r->setReversible(false);
  r->setFast(true);
  r->setCompartment("c");

  char* sbml = r->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);

  r->unsetCompartment();

  sbml = r->toSBML();
  fail_unless( equals(expected1, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Reaction_full)
{
  const char* expected = 
    "<reaction id=\"v1\" reversible=\"true\" fast=\"false\">\n"
    "  <listOfReactants>\n"
    "    <speciesReference species=\"x0\"/>\n"
    "  </listOfReactants>\n"
    "  <listOfProducts>\n"
    "    <speciesReference species=\"s1\"/>\n"
    "  </listOfProducts>\n"
    "  <listOfModifiers>\n"
    "    <modifierSpeciesReference species=\"m1\"/>\n"
    "  </listOfModifiers>\n"
    "  <kineticLaw>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <divide/>\n"
    "        <apply>\n"
    "          <times/>\n"
    "          <ci> vm </ci>\n"
    "          <ci> s1 </ci>\n"
    "        </apply>\n"
    "        <apply>\n"
    "          <plus/>\n"
    "          <ci> km </ci>\n"
    "          <ci> s1 </ci>\n"
    "        </apply>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </kineticLaw>\n"
    "</reaction>";


  D->createModel();

  Reaction* r = D->getModel()->createReaction();

  r->setId("v1");
  r->setReversible(true);
  r->setFast(false);

  r->createReactant()->setSpecies("x0");
  r->createProduct ()->setSpecies("s1");
  r->createModifier()->setSpecies("m1");

  r->createKineticLaw()->setFormula("(vm * s1)/(km + s1)");

  char* sbml = r->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_SpeciesReference)
{
  const char* expected = "<speciesReference species=\"s\""
    " stoichiometry=\"3\" constant=\"true\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3);
  sr->setConstant(true);

  char* sbml = sr->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_KineticLaw_ListOfParameters)
{
  const char* expected = 
    "<kineticLaw>\n"
    "  <listOfLocalParameters>\n"
    "    <localParameter id=\"n\" value=\"1.2\"/>\n"
    "  </listOfLocalParameters>\n"
    "</kineticLaw>";

  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();

  LocalParameter *p = kl->createLocalParameter();
  p->setId("n");
  p->setValue(1.2);

  char* sbml = kl->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Event)
{
  const char* expected = "<event id=\"e\" useValuesFromTriggerTime=\"true\"/>";

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  e->setUseValuesFromTriggerTime(true);
  
  char* sbml = e->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Event_useValues)
{
  const char* expected = 
    "<event id=\"e\" useValuesFromTriggerTime=\"false\">\n"
    "  <delay/>\n"
    "</event>";

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  e->setUseValuesFromTriggerTime(false);
  e->createDelay();
  
  char* sbml = e->toSBML();
  fail_unless( equals(expected, sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Trigger)
{
  const char* expected = "<trigger/>";

  Trigger *t = D->createModel()->createEvent()->createTrigger();
  
  char* tsbml = t->toSBML();
  fail_unless( equals(expected,tsbml) );
  safe_free(tsbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Trigger_initialValue)
{
  const char* expected = "<trigger initialValue=\"false\" persistent=\"true\"/>";

  Trigger *t = D->createModel()->createEvent()->createTrigger();
  t->setInitialValue(false);
  t->setPersistent(true);
  
  char* tsbml = t->toSBML();
  fail_unless( equals(expected,tsbml) );
  safe_free(tsbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Trigger_persistent)
{
  const char* expected = "<trigger initialValue=\"true\" persistent=\"false\"/>";

  Trigger *t = D->createModel()->createEvent()->createTrigger();
  t->setPersistent(false);
  t->setInitialValue(true);
  
  char* tsbml = t->toSBML();
  fail_unless( equals(expected,tsbml) );
  safe_free(tsbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Priority)
{
  const char* expected = "<priority/>";

  Priority *p = D->createModel()->createEvent()->createPriority();
  
  char* sbml = p->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_Event_full)
{
  const char* expected = 
    "<event useValuesFromTriggerTime=\"true\">\n"
    "  <trigger initialValue=\"true\" persistent=\"false\">\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <true/>\n"
    "    </math>\n"
    "  </trigger>\n"
    "  <priority>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </math>\n"
    "  </priority>\n"
    "</event>";

  Event *e = D->createModel()->createEvent();
  e->setUseValuesFromTriggerTime(true);
  Trigger *t = e->createTrigger();
  t->setInitialValue(true);
  t->setPersistent(false);
  ASTNode         *math1   = SBML_parseFormula("true");
  t->setMath(math1);
  Priority *p = e->createPriority();
  ASTNode         *math2   = SBML_parseFormula("2");
  p->setMath(math2);

 
  char* sbml = e->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);
  delete math1;
  delete math2;
}
END_TEST


START_TEST (test_WriteL3SBML_NaN)
{
  const char* expected = "<parameter id=\"p\" value=\"NaN\""
    " constant=\"true\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_NaN());
  p->setConstant(true);

  char* sbml = p->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_INF)
{
  const char* expected = "<parameter id=\"p\" value=\"INF\""
    " constant=\"true\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_PosInf());
  p->setConstant(true);

  char* sbml = p->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_NegINF)
{
  const char* expected = "<parameter id=\"p\" value=\"-INF\""
    " constant=\"true\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_NegInf());
  p->setConstant(true);

  char* sbml = p->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);
}
END_TEST


START_TEST (test_WriteL3SBML_locale)
{
  const char* expected = "<parameter id=\"p\" value=\"3.31\""
    " constant=\"true\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(3.31);
  p->setConstant(true);


  setlocale(LC_NUMERIC, "de_DE");

  char* sbml = p->toSBML();
  fail_unless( equals(expected,sbml) );
  safe_free(sbml);

  setlocale(LC_NUMERIC, "C");
}
END_TEST

#ifdef USE_ZLIB
START_TEST (test_WriteL3SBML_gzip)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-3/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-3/delay.xml",
                        "../../../examples/sample-models/from-spec/level-3/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-3/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-3/events.xml",
                        "../../../examples/sample-models/from-spec/level-3/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-3/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-3/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-3/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-3/units.xml"
                        };
  const char* gzfile = "test.xml.gz";

  for(unsigned int i=0; i < filenum; i++)
  {
    SBMLDocument* d = readSBML(file[i]);
    fail_unless( d != NULL);

    if ( ! SBMLWriter::hasZlib() )
    {
      fail_unless( writeSBML(d, gzfile) == false);
      delete d;
      continue;
    }

    bool result = writeSBML(d, gzfile);
    fail_unless( result );

    SBMLDocument* dg = readSBML(gzfile);
    fail_unless( dg != NULL);

    char* dtos = d->toSBML();
    char* dgtos = dg->toSBML();
    fail_unless( strcmp(dtos, dgtos) == 0 );
    safe_free(dtos);
    safe_free(dgtos);

    delete d;
    delete dg;
  }

}
END_TEST
#endif

#ifdef USE_BZ2
START_TEST (test_WriteL3SBML_bzip2)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-3/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-3/delay.xml",
                        "../../../examples/sample-models/from-spec/level-3/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-3/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-3/events.xml",
                        "../../../examples/sample-models/from-spec/level-3/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-3/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-3/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-3/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-3/units.xml"
                        };

  const char* bz2file = "test.xml.bz2";

  for(unsigned int i=0; i < filenum; i++)
  {
    SBMLDocument* d = readSBML(file[i]);
    fail_unless( d != NULL);

    if ( ! SBMLWriter::hasBzip2() )
    {
      fail_unless( writeSBML(d, bz2file) == false );
      delete d;
      continue;
    }

    bool result = writeSBML(d, bz2file);
    fail_unless( result );

    SBMLDocument* dg = readSBML(bz2file);
    fail_unless( dg != NULL);

    char* dtos = d->toSBML();
    char* dgtos = dg->toSBML();
    fail_unless( strcmp(dtos, dgtos) == 0 );
    safe_free(dtos);
    safe_free(dgtos);

    delete d;
    delete dg;
  }
}
END_TEST
#endif

#ifdef USE_ZLIB
START_TEST (test_WriteL3SBML_zip)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-3/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-3/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-3/delay.xml",
                        "../../../examples/sample-models/from-spec/level-3/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-3/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-3/events.xml",
                        "../../../examples/sample-models/from-spec/level-3/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-3/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-3/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-3/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-3/units.xml"
                        };

  const char* zipfile = "test.xml.zip";

  for(unsigned int i=0; i < filenum; i++)
  {
    SBMLDocument* d = readSBML(file[i]);
    fail_unless( d != NULL);

    if ( ! SBMLWriter::hasZlib() )
    {
      fail_unless( writeSBML(d, zipfile) == false );
      delete d;
      continue;
    }

    bool result = writeSBML (d, zipfile);
    fail_unless( result );

    SBMLDocument* dg = readSBML(zipfile);
    fail_unless( dg != NULL);

    char* dtos = d->toSBML();
    char* dgtos = dg->toSBML();
    fail_unless( strcmp(dtos, dgtos) == 0 );
    safe_free(dtos);
    safe_free(dgtos);

    delete d;
    delete dg;
  }
}
END_TEST
#endif

START_TEST (test_WriteL3SBML_elements)
{
  const char* expected = wrapSBML_L3v1(
    "  <model>\n"
    "    <listOfFunctionDefinitions>\n"
    "      <functionDefinition/>\n"
    "    </listOfFunctionDefinitions>\n"
    "    <listOfUnitDefinitions>\n"
    "      <unitDefinition/>\n"
    "    </listOfUnitDefinitions>\n"
    "    <listOfCompartments>\n"
    "      <compartment/>\n"
    "    </listOfCompartments>\n"
    "    <listOfSpecies>\n"
    "      <species/>\n"
    "    </listOfSpecies>\n"
    "    <listOfParameters>\n"
    "      <parameter/>\n"
    "    </listOfParameters>\n"
    "    <listOfInitialAssignments>\n"
    "      <initialAssignment/>\n"
    "    </listOfInitialAssignments>\n"
    "    <listOfRules>\n"
    "      <algebraicRule/>\n"
    "    </listOfRules>\n"
    "    <listOfConstraints>\n"
    "      <constraint/>\n"
    "    </listOfConstraints>\n"
    "    <listOfReactions>\n"
    "      <reaction/>\n"
    "    </listOfReactions>\n"
    "    <listOfEvents>\n"
    "      <event/>\n"
    "    </listOfEvents>\n"
    "  </model>\n");

  Model * m = D->createModel();
  m->createUnitDefinition();
  m->createFunctionDefinition();
  m->createCompartment();
  m->createEvent();
  m->createParameter();
  m->createAlgebraicRule();
  m->createInitialAssignment();
  m->createConstraint();
  m->createReaction();
  m->createSpecies();

  string S = writeSBMLToStdString(D);

  fail_unless( equals(expected, S.c_str()) );
}
END_TEST



Suite *
create_suite_WriteL3SBML ()
{
  Suite *suite = suite_create("WriteL3SBML");
  TCase *tcase = tcase_create("WriteL3SBML");


  tcase_add_checked_fixture(tcase, WriteL3SBML_setup, WriteL3SBML_teardown);
 
  // create/setProgramName/setProgramVersion
  tcase_add_test( tcase, test_SBMLWriter_L3_create );  
  tcase_add_test( tcase, test_SBMLWriter_L3_setProgramName );  
  tcase_add_test( tcase, test_SBMLWriter_L3_setProgramVersion );  

  // Basic writing capability
  tcase_add_test( tcase, test_WriteL3SBML_error );  

  // SBMLDocument
  tcase_add_test( tcase, test_WriteL3SBML_SBMLDocument_L3v1 );


  // Model
  tcase_add_test( tcase, test_WriteL3SBML_Model                   );
  tcase_add_test( tcase, test_WriteL3SBML_Model_substanceUnits    );
  tcase_add_test( tcase, test_WriteL3SBML_Model_timeUnits    );
  tcase_add_test( tcase, test_WriteL3SBML_Model_otherUnits    );
  tcase_add_test( tcase, test_WriteL3SBML_Model_conversionFactor    );

  //// Unit
  tcase_add_test( tcase, test_WriteL3SBML_Unit          );
  tcase_add_test( tcase, test_WriteL3SBML_Unit_noValues          );

  //// UnitDefinition
  tcase_add_test( tcase, test_WriteL3SBML_UnitDefinition           );
  //tcase_add_test( tcase, test_WriteL3SBML_UnitDefinition_full      );  
  //tcase_add_test( tcase, test_WriteL3SBML_UnitDefinition_L2v1      );
  //tcase_add_test( tcase, test_WriteL3SBML_UnitDefinition_L2v1_full );

  //// Compartment
  tcase_add_test( tcase, test_WriteL3SBML_Compartment                );
  tcase_add_test( tcase, test_WriteL3SBML_Compartment_spatialDimensions );

  //// Species
  tcase_add_test( tcase, test_WriteL3SBML_Species                   );
  tcase_add_test( tcase, test_WriteL3SBML_Species_conversionFactor  );

  // Parameter
  tcase_add_test( tcase, test_WriteL3SBML_Parameter                   );

  // Reaction
  tcase_add_test( tcase, test_WriteL3SBML_Reaction           );
  tcase_add_test( tcase, test_WriteL3SBML_Reaction_compartment  );
  tcase_add_test( tcase, test_WriteL3SBML_Reaction_full         );

  //// SpeciesReference

  tcase_add_test( tcase, test_WriteL3SBML_SpeciesReference          );

  //// KineticLaw
  tcase_add_test( tcase, test_WriteL3SBML_KineticLaw_ListOfParameters );

  //// Event
  tcase_add_test( tcase, test_WriteL3SBML_Event         );
  tcase_add_test( tcase, test_WriteL3SBML_Event_useValues );
 
  //// Trigger
  tcase_add_test( tcase, test_WriteL3SBML_Trigger         );
  tcase_add_test( tcase, test_WriteL3SBML_Trigger_initialValue );
  tcase_add_test( tcase, test_WriteL3SBML_Trigger_persistent );
 
  tcase_add_test( tcase, test_WriteL3SBML_Priority         );
  tcase_add_test( tcase, test_WriteL3SBML_Event_full         );
   // Miscellaneous
  tcase_add_test( tcase, test_WriteL3SBML_NaN     );
  tcase_add_test( tcase, test_WriteL3SBML_INF     );
  tcase_add_test( tcase, test_WriteL3SBML_NegINF  );
  tcase_add_test( tcase, test_WriteL3SBML_locale  );

  // Compressed SBML
#ifdef USE_ZLIB
  tcase_add_test( tcase, test_WriteL3SBML_gzip  );
  tcase_add_test( tcase, test_WriteL3SBML_zip  );
#endif
#ifdef USE_BZ2
  tcase_add_test( tcase, test_WriteL3SBML_bzip2  );
#endif

  tcase_add_test( tcase, test_WriteL3SBML_elements);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
