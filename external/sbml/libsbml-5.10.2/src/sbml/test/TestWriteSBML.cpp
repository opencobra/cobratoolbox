/**
 * \file    TestWriteSBML.cpp
 * \brief   Write SBML unit tests
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

CK_CPPSTART

/**
 * Wraps the string s in the appropriate XML boilerplate.
 */
#define XML_START   "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define SBML_START  "<sbml "
#define NS_L1       "xmlns=\"http://www.sbml.org/sbml/level1\" "
#define NS_L2v1     "xmlns=\"http://www.sbml.org/sbml/level2\" "
#define NS_L2v2     "xmlns=\"http://www.sbml.org/sbml/level2/version2\" "
#define NS_L2v3     "xmlns=\"http://www.sbml.org/sbml/level2/version3\" "
#define LV_L1v1     "level=\"1\" version=\"1\">\n"
#define LV_L1v2     "level=\"1\" version=\"2\">\n"
#define LV_L2v1     "level=\"2\" version=\"1\">\n"
#define LV_L2v2     "level=\"2\" version=\"2\">\n"
#define LV_L2v3     "level=\"2\" version=\"3\">\n"
#define SBML_END    "</sbml>\n"

#define wrapXML(s)        XML_START s
#define wrapSBML_L1v1(s)  XML_START SBML_START NS_L1   LV_L1v1 s SBML_END
#define wrapSBML_L1v2(s)  XML_START SBML_START NS_L1   LV_L1v2 s SBML_END
#define wrapSBML_L2v1(s)  XML_START SBML_START NS_L2v1 LV_L2v1 s SBML_END
#define wrapSBML_L2v2(s)  XML_START SBML_START NS_L2v2 LV_L2v2 s SBML_END
#define wrapSBML_L2v3(s)  XML_START SBML_START NS_L2v3 LV_L2v3 s SBML_END


static SBMLDocument* D;
static char*         S;


static void
WriteSBML_setup ()
{
  D = new SBMLDocument;
  S = NULL;
}


static void
WriteSBML_teardown ()
{
  delete D;
  free(S);
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


START_TEST (test_WriteSBML_error)
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


START_TEST (test_SBMLWriter_create)
{
  SBMLWriter_t   *w = SBMLWriter_create();

  fail_unless( w != NULL );

  SBMLWriter_free(w);
}
END_TEST


START_TEST (test_SBMLWriter_setProgramName)
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


START_TEST (test_SBMLWriter_setProgramVersion)
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


START_TEST (test_WriteSBML_SBMLDocument_L1v1)
{
  D->setLevelAndVersion(1, 1, false);

  const char *expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level1\" "
    "level=\"1\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_L1v2)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level1\" "
    "level=\"1\" version=\"2\"/>\n"
  );


  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level2/version2\" "
    "level=\"2\" version=\"2\"/>\n"
  );


  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_updateNamespace_1)
{
  const char* input = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level1\" "
    "level=\"1\" version=\"2\"/>\n"
  );
 
  SBMLDocument *d = readSBMLFromString(input);

  d->updateSBMLNamespace("", 2, 1);

  const char* expected = wrapXML
  (
    "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(d);

  fail_unless( equals(expected, S) );

  delete d;
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_updateNamespace_2)
{
  // note this is invalid but we would fix it
  const char* input = wrapXML
  (
  "<sbml xmlns:foo=\"http://www.sbml.org/sbml/level2/version4\" "
    "level=\"2\" version=\"4\"/>\n"
  );
 
  SBMLDocument *d = readSBMLFromString(input);

  d->updateSBMLNamespace("", 2, 1);

  const char* expected = wrapXML
  (
  "<foo:sbml xmlns:foo=\"http://www.sbml.org/sbml/level2\" "
    "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(d);

  fail_unless( equals(expected, S) );

  delete d;
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_updateNamespace_3)
{
  const char* input = wrapXML
  (
  "<foo:sbml xmlns:foo=\"http://www.sbml.org/sbml/level3/version1/core\" "
  "level=\"3\" version=\"1\"/>\n"
  );
 
  SBMLDocument *d = readSBMLFromString(input);

  d->updateSBMLNamespace("", 2, 1);

  const char* expected = wrapXML
  (
  "<foo:sbml xmlns:foo=\"http://www.sbml.org/sbml/level2\" "
  "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(d);

  fail_unless( equals(expected, S) );

  delete d;
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_updateNamespace_4)
{
  const char* input = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" "
  "xmlns:foo=\"http://www.sbml.org/sbml/level3/version1/core\" "
  "level=\"3\" version=\"1\"/>\n"
  );
 
  SBMLDocument *d = readSBMLFromString(input);

  d->updateSBMLNamespace("", 2, 1);

  const char* expected = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" "
  "xmlns:foo=\"http://www.sbml.org/sbml/level2\" "
  "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(d);

  fail_unless( equals(expected, S) );

  delete d;
}
END_TEST


START_TEST (test_WriteSBML_SBMLDocument_updateNamespace_5)
{
  const char* input = wrapXML
  (
  "<foo:sbml xmlns:foo=\"http://www.sbml.org/sbml/level3/version1/core\" "
  "xmlns=\"http://www.sbml.org/sbml/level3/version1/core\" "
  "level=\"3\" version=\"1\"/>\n"
  );
 
  SBMLDocument *d = readSBMLFromString(input);

  d->updateSBMLNamespace("", 2, 1);

  const char* expected = wrapXML
  (
  "<foo:sbml xmlns:foo=\"http://www.sbml.org/sbml/level2\" "
  "xmlns=\"http://www.sbml.org/sbml/level2\" "
  "level=\"2\" version=\"1\"/>\n"
  );


  S = writeSBMLToString(d);

  fail_unless( equals(expected, S) );

  delete d;
}
END_TEST


START_TEST (test_WriteSBML_Model)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = wrapSBML_L1v1("  <model name=\"Branch\"/>\n");


  D->createModel("Branch");
  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_Model_skipOptional)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = wrapSBML_L1v2("  <model/>\n");


  D->createModel();
  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_Model_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = wrapSBML_L2v1("  <model id=\"Branch\"/>\n");


  D->createModel("Branch");
  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_Model_L2v1_skipOptional)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = wrapSBML_L2v1("  <model/>\n");


  D->createModel();
  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_Model_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = wrapSBML_L2v2("  <model sboTerm=\"SBO:0000004\" id=\"Branch\"/>\n");

  Model * m = D->createModel("Branch");
  m->setSBOTerm(4);

  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_FunctionDefinition)
{
  const char* expected = 
    "<functionDefinition id=\"pow3\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <lambda>\n"
    "      <bvar>\n"
    "        <ci> x </ci>\n"
    "      </bvar>\n"
    "      <apply>\n"
    "        <power/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 3 </cn>\n"
    "      </apply>\n"
    "    </lambda>\n"
    "  </math>\n"
    "</functionDefinition>";

  FunctionDefinition fd(2, 4);
  fd.setId("pow3");
  fd.setMath(SBML_parseFormula("lambda(x, x^3)"));

  fail_unless( equals(expected,fd.toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_FunctionDefinition_withSBO)
{
  const char* expected = 
  "<functionDefinition sboTerm=\"SBO:0000064\" id=\"pow3\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <lambda>\n"
    "      <bvar>\n"
    "        <ci> x </ci>\n"
    "      </bvar>\n"
    "      <apply>\n"
    "        <power/>\n"
    "        <ci> x </ci>\n"
    "        <cn type=\"integer\"> 3 </cn>\n"
    "      </apply>\n"
    "    </lambda>\n"
    "  </math>\n"
    "</functionDefinition>";

  FunctionDefinition fd(2, 4);
  fd.setId("pow3");
  fd.setMath(SBML_parseFormula("lambda(x, x^3)"));
  fd.setSBOTerm(64);

  fail_unless( equals(expected,fd.toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit)
{
  D->setLevelAndVersion(2, 4, false);

  const char* expected = "<unit kind=\"kilogram\" exponent=\"2\" scale=\"-3\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  u->setExponent(2);
  u->setScale(-3);

  fail_unless( equals(expected, u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_l2v3)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<unit kind=\"kilogram\" exponent=\"2\" scale=\"-3\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  u->setExponent(2);
  u->setScale(-3);
  u->setOffset(32);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<unit kind=\"kilogram\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_L1_explicit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<unit kind=\"kilogram\" exponent=\"1\" scale=\"0\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  u->setExponent(1);
  u->setScale(0);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_L2v1_explicit_defaults)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<unit kind=\"kilogram\" exponent=\"1\" scale=\"0\" multiplier=\"1\" offset=\"0\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  u->setExponent(1);
  u->setScale(0);
  u->setMultiplier(1.0);
  u->setOffset(0);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<unit kind=\"kilogram\" exponent=\"1\" scale=\"0\" multiplier=\"1\"/>";


  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UNIT_KIND_KILOGRAM);
  u->setExponent(1);
  u->setScale(0);
  u->setMultiplier(1.0);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Unit_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<unit kind=\"Celsius\" multiplier=\"1.8\" offset=\"32\"/>";

  Unit* u = D->createModel()->createUnitDefinition()->createUnit();
  u->setKind(UnitKind_forName("Celsius"));
  u->setMultiplier(1.8);
  u->setOffset(32);

  fail_unless( equals(expected,u->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_UnitDefinition)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<unitDefinition name=\"mmls\"/>";


  UnitDefinition* ud = D->createModel()->createUnitDefinition();
  ud->setId("mmls");

  fail_unless( equals(expected,ud->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_UnitDefinition_full)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<unitDefinition name=\"mmls\">\n"
    "  <listOfUnits>\n"
    "    <unit kind=\"mole\" scale=\"-3\"/>\n"
    "    <unit kind=\"liter\" exponent=\"-1\"/>\n"
    "    <unit kind=\"second\" exponent=\"-1\"/>\n"
    "  </listOfUnits>\n"
    "</unitDefinition>";


  UnitDefinition* ud = D->createModel()->createUnitDefinition();
  ud->setId("mmls");

  Unit* u1 = ud->createUnit();
  u1->setKind(UNIT_KIND_MOLE);
  u1->setScale(-3);
  Unit* u2 = ud->createUnit();
  u2->setKind(UNIT_KIND_LITER);
  u2->setExponent(-1);
  Unit* u3 = ud->createUnit();
  u3->setKind(UNIT_KIND_SECOND);
  u3->setExponent(-1);

  fail_unless( equals(expected,ud->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_UnitDefinition_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<unitDefinition id=\"mmls\"/>";

  UnitDefinition* ud = D->createModel()->createUnitDefinition();
  ud->setId("mmls");

  fail_unless( equals(expected, ud->toSBML()) );
}
END_TEST



START_TEST (test_WriteSBML_UnitDefinition_L2v1_full)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<unitDefinition id=\"Fahrenheit\">\n"
    "  <listOfUnits>\n"
    "    <unit kind=\"Celsius\" multiplier=\"1.8\" offset=\"32\"/>\n"
    "  </listOfUnits>\n"
    "</unitDefinition>";

  UnitDefinition* ud = D->createModel()->createUnitDefinition();
  ud->setId("Fahrenheit");

  Unit* u1 = ud->createUnit();
  u1->setKind(UnitKind_forName("Celsius"));
  u1->setMultiplier(1.8);
  u1->setOffset(32);

  fail_unless( equals(expected,ud->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<compartment name=\"A\" volume=\"2.1\" outside=\"B\"/>";

  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");

  c->setSize(2.1);
  c->setOutside("B");

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L1_explicit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<compartment name=\"A\"/>";

  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");

  fail_unless( equals(expected,c->toSBML()) );

  const char* expected1 = "<compartment name=\"A\" volume=\"1\"/>";
  c->setVolume(1);

  fail_unless( equals(expected1,c->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<compartment id=\"A\"/>";

  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");

  fail_unless( equals(expected,c->toSBML()) );

  const char* expected1 = "<compartment id=\"A\" spatialDimensions=\"3\" constant=\"true\"/>";
  c->setSpatialDimensions((unsigned int)(3));
  c->setConstant(true);

  fail_unless( equals(expected1,c->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_Compartment_unsetVolume)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<compartment name=\"A\"/>";

  Compartment *c = D->createModel()->createCompartment();

  c->setId("A");
  c->unsetVolume();

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<compartment id=\"M\" spatialDimensions=\"2\" size=\"2.5\"/>";


  Compartment *c = D->createModel()->createCompartment(); 
  c->setId("M");
  c->setSize(2.5);
  unsigned int dim = 2;
  c->setSpatialDimensions(dim);

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2v1_constant)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<compartment id=\"cell\" size=\"1.2\" constant=\"false\"/>";

  Compartment *c = D->createModel()->createCompartment(); 
  c->setId("cell");
  c->setSize(1.2);
  c->setConstant(false);

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2v1_unsetSize)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<compartment id=\"A\"/>";


  Compartment *c = D->createModel()->createCompartment();
  c->setId("A");
  c->unsetSize();

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2v2_compartmentType)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<compartment id=\"cell\" compartmentType=\"ct\"/>";

  Compartment *c = D->createModel()->createCompartment(); 
  c->setId("cell");
  c->setCompartmentType("ct");

  fail_unless( equals(expected, c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Compartment_L2v3_SBO)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<compartment sboTerm=\"SBO:0000005\" id=\"cell\"/>";

  Compartment *c = D->createModel()->createCompartment(); 
  c->setId("cell");
  c->setSBOTerm(5);

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<species name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\""
    " units=\"mole\" boundaryCondition=\"true\" charge=\"2\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setName("Ca2");
  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setUnits("mole");
  s->setBoundaryCondition(true);
  s->setCharge(2);

  fail_unless( equals(expected, s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L1_explicit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<species name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setName("Ca2");
  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  
  fail_unless( equals(expected, s->toSBML()) );

  const char* expected1 = 
    "<species name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\" boundaryCondition=\"false\"/>";
  s->setBoundaryCondition(false);

  fail_unless( equals(expected1, s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
    "<species id=\"Ca2\" compartment=\"cell\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");
  s->setCompartment("cell");
  
  fail_unless( equals(expected, s->toSBML()) );

  const char* expected1 = 
    "<species id=\"Ca2\" compartment=\"cell\" "
    "hasOnlySubstanceUnits=\"false\" boundaryCondition=\"false\" constant=\"false\"/>";
  s->setBoundaryCondition(false);
  s->setHasOnlySubstanceUnits(false);
  s->setConstant(false);

  fail_unless( equals(expected1, s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L1v1)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = 
    "<specie name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\""
    " units=\"mole\" boundaryCondition=\"true\" charge=\"2\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setName("Ca2");

  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setUnits("mole");
  s->setBoundaryCondition(true);
  s->setCharge(2);

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<species name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\""
    " units=\"mole\" charge=\"2\"/>";


  Species *s = D->createModel()->createSpecies();

  s->setName("Ca2");

  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setUnits("mole");
  s->setCharge(2);

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_skipOptional)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<species name=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\"/>";


  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");

  s->setCompartment("cell");
  s->setInitialAmount(0.7);

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<species id=\"Ca2\" compartment=\"cell\" initialAmount=\"0.7\" "
    "substanceUnits=\"mole\" constant=\"true\"/>";

  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");

  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setSubstanceUnits("mole");
  s->setConstant(true);

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L2v1_skipOptional)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<species id=\"Ca2\" compartment=\"cell\"/>";

  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");
  s->setCompartment("cell");

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
    "<species id=\"Ca2\" speciesType=\"st\" compartment=\"cell\" initialAmount=\"0.7\" "
    "substanceUnits=\"mole\" constant=\"true\"/>";

  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");

  s->setCompartment("cell");
  s->setInitialAmount(0.7);
  s->setSubstanceUnits("mole");
  s->setConstant(true);
  s->setSpeciesType("st");

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Species_L2v3)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<species sboTerm=\"SBO:0000007\" id=\"Ca2\" compartment=\"cell\"/>";

  Species *s = D->createModel()->createSpecies();
  s->setId("Ca2");

  s->setCompartment("cell");
  s->setSBOTerm(7);

  fail_unless( equals(expected,s->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<parameter name=\"Km1\" value=\"2.3\" units=\"second\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");
  p->setValue(2.3);
  p->setUnits("second");

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<parameter id=\"Km1\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");

  fail_unless( equals(expected,p->toSBML()) );

  const char* expected1 = "<parameter id=\"Km1\" constant=\"false\"/>";

  p->setConstant(false);

  fail_unless( equals(expected1,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L1v1_required)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<parameter name=\"Km1\" value=\"NaN\"/>";

  Parameter *p = D->createModel()->createParameter();

  p->setId("Km1");
  p->unsetValue();

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L1v2_skipOptional)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<parameter name=\"Km1\"/>";


  Parameter *p = D->createModel()->createParameter();

  p->setId("Km1");
  p->unsetValue();

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<parameter id=\"Km1\" value=\"2.3\" units=\"second\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");
  p->setValue(2.3);
  p->setUnits("second");

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L2v1_skipOptional)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<parameter id=\"Km1\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L2v1_constant)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<parameter id=\"x\" constant=\"false\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("x");

  p->setConstant(false);

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Parameter_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<parameter sboTerm=\"SBO:0000002\" id=\"Km1\" value=\"2.3\" units=\"second\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("Km1");
  p->setValue(2.3);
  p->setUnits("second");
  p->setSBOTerm(2);

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_AlgebraicRule)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<algebraicRule formula=\"x + 1\"/>";


  AlgebraicRule *r = D->createModel()->createAlgebraicRule();
  r->setFormula("x + 1");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_AlgebraicRule_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<algebraicRule>\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 1 </cn>\n"
    "    </apply>\n"
    "  </math>\n"
    "</algebraicRule>";


  AlgebraicRule *r = D->createModel()->createAlgebraicRule();
  r->setFormula("x + 1");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_AlgebraicRule_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
    "<algebraicRule sboTerm=\"SBO:0000004\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <cn type=\"integer\"> 1 </cn>\n"
    "    </apply>\n"
    "  </math>\n"
    "</algebraicRule>";


  AlgebraicRule *r = D->createModel()->createAlgebraicRule();
  r->setFormula("x + 1");
  r->setSBOTerm(4);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesConcentrationRule)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<speciesConcentrationRule "
    "formula=\"t * s\" type=\"rate\" species=\"s\"/>";


  D->createModel();
  D->getModel()->createSpecies()->setId("s");

  Rule* r = D->getModel()->createRateRule();

  r->setVariable("s");
  r->setFormula("t * s");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesConcentrationRule_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<speciesConcentrationRule formula=\"t * s\" species=\"s\"/>";

  D->createModel();
  D->getModel()->createSpecies()->setId("s");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("s");
  r->setFormula("t * s");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesConcentrationRule_L1v1)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<specieConcentrationRule formula=\"t * s\" specie=\"s\"/>";


  D->createModel();
  D->getModel()->createSpecies()->setId("s");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("s");
  r->setFormula("t * s");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesConcentrationRule_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<assignmentRule variable=\"s\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <times/>\n"
    "      <ci> t </ci>\n"
    "      <ci> s </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</assignmentRule>";


  D->createModel();
  D->getModel()->createSpecies()->setId("s");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("s");
  r->setFormula("t * s");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesConcentrationRule_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<assignmentRule sboTerm=\"SBO:0000006\" variable=\"s\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <times/>\n"
    "      <ci> t </ci>\n"
    "      <ci> s </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</assignmentRule>";


  D->createModel();
  D->getModel()->createSpecies()->setId("s");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("s");
  r->setFormula("t * s");
  r->setSBOTerm(6);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentVolumeRule)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = 
    "<compartmentVolumeRule "
    "formula=\"v + c\" type=\"rate\" compartment=\"c\"/>";


  D->createModel();
  D->getModel()->createCompartment()->setId("c");

  Rule* r = D->getModel()->createRateRule();

  r->setVariable("c");
  r->setFormula("v + c");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentVolumeRule_defaults)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<compartmentVolumeRule formula=\"v + c\" compartment=\"c\"/>";


  D->createModel();
  D->getModel()->createCompartment()->setId("c");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("c");
  r->setFormula("v + c");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentVolumeRule_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<assignmentRule variable=\"c\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> v </ci>\n"
    "      <ci> c </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</assignmentRule>";


  D->createModel();
  D->getModel()->createCompartment()->setId("c");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("c");
  r->setFormula("v + c");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentVolumeRule_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<assignmentRule sboTerm=\"SBO:0000005\" variable=\"c\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> v </ci>\n"
    "      <ci> c </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</assignmentRule>";


  D->createModel();
  D->getModel()->createCompartment()->setId("c");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("c");
  r->setFormula("v + c");
  r->setSBOTerm(5);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_ParameterRule)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = 
    "<parameterRule "
    "formula=\"p * t\" type=\"rate\" name=\"p\"/>";


  D->createModel();
  D->getModel()->createParameter()->setId("p");

  Rule* r = D->getModel()->createRateRule();

  r->setVariable("p");
  r->setFormula("p * t");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_ParameterRule_defaults)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<parameterRule formula=\"p * t\" name=\"p\"/>";


  D->createModel();
  D->getModel()->createParameter()->setId("p");

  Rule* r = D->getModel()->createAssignmentRule();

  r->setVariable("p");
  r->setFormula("p * t");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_ParameterRule_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<rateRule variable=\"p\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <times/>\n"
    "      <ci> p </ci>\n"
    "      <ci> t </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</rateRule>";


  D->createModel();
  D->getModel()->createParameter()->setId("p");

  Rule* r = D->getModel()->createRateRule();

  r->setVariable("p");
  r->setFormula("p * t");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_ParameterRule_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<rateRule sboTerm=\"SBO:0000007\" variable=\"p\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <times/>\n"
    "      <ci> p </ci>\n"
    "      <ci> t </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</rateRule>";


  D->createModel();
  D->getModel()->createParameter()->setId("p");

  Rule* r = D->getModel()->createRateRule();

  r->setVariable("p");
  r->setFormula("p * t");
  r->setSBOTerm(7);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<reaction name=\"r\" reversible=\"false\" fast=\"true\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");
  r->setReversible(false);
  r->setFast(true);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<reaction name=\"r\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_L1_explicit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<reaction name=\"r\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");

  fail_unless( equals(expected,r->toSBML()) );
  
  const char* expected1 = "<reaction name=\"r\" reversible=\"true\" fast=\"false\"/>";
  r->setFast(false);
  r->setReversible(true);
  
  fail_unless( equals(expected1,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<reaction id=\"r\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");

  fail_unless( equals(expected,r->toSBML()) );
  
  const char* expected1 = "<reaction id=\"r\" reversible=\"true\" fast=\"false\"/>";
  r->setFast(false);
  r->setReversible(true);
  
  fail_unless( equals(expected1,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_full)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<reaction name=\"v1\">\n"
    "  <listOfReactants>\n"
    "    <speciesReference species=\"x0\"/>\n"
    "  </listOfReactants>\n"
    "  <listOfProducts>\n"
    "    <speciesReference species=\"s1\"/>\n"
    "  </listOfProducts>\n"
    "  <kineticLaw formula=\"(vm * s1)/(km + s1)\"/>\n"
    "</reaction>";


  D->createModel();

  Reaction* r = D->getModel()->createReaction();

  r->setId("v1");

  r->createReactant()->setSpecies("x0");
  r->createProduct ()->setSpecies("s1");

  r->createKineticLaw()->setFormula("(vm * s1)/(km + s1)");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<reaction id=\"r\" reversible=\"false\"/>";


  Reaction *r = D->createModel()->createReaction();
  r->setId("r");
  r->setReversible(false);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_L2v1_full)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<reaction id=\"v1\">\n"
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

  r->createReactant()->setSpecies("x0");
  r->createProduct ()->setSpecies("s1");
  r->createModifier()->setSpecies("m1");

  r->createKineticLaw()->setFormula("(vm * s1)/(km + s1)");

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Reaction_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<reaction sboTerm=\"SBO:0000064\" id=\"r\" name=\"r1\" reversible=\"false\" fast=\"true\"/>";


  Reaction* r = D->createModel()->createReaction();
  r->setId("r");
  r->setName("r1");
  r->setReversible(false);
  r->setFast(true);
  r->setSBOTerm(64);

  fail_unless( equals(expected,r->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<speciesReference species=\"s\" stoichiometry=\"3\" denominator=\"2\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3);
  sr->setDenominator(2);

  fail_unless( equals(expected,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L1v1)
{
  D->setLevelAndVersion(1, 1, false);

  const char* expected = "<specieReference specie=\"s\" stoichiometry=\"3\" denominator=\"2\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3);
  sr->setDenominator(2);

  fail_unless( equals(expected,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<speciesReference species=\"s\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");

  fail_unless( equals(expected,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L1_explicit_defaults)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<speciesReference species=\"s\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");

  fail_unless( equals(expected,sr->toSBML()) );
  
  const char* expected1 = "<speciesReference species=\"s\" stoichiometry=\"1\" denominator=\"1\"/>";
  
  sr->setStoichiometry(1);
  sr->setDenominator(1);

  fail_unless( equals(expected1,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2_explicit_defaults)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<speciesReference species=\"s\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");

  fail_unless( equals(expected,sr->toSBML()) );
  
  const char* expected1 = "<speciesReference species=\"s\" stoichiometry=\"1\"/>";
  
  sr->setStoichiometry(1);

  fail_unless( equals(expected1,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2v1_1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<speciesReference species=\"s\">\n"
    "  <stoichiometryMath>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"rational\"> 3 <sep/> 2 </cn>\n"
    "    </math>\n"
    "  </stoichiometryMath>\n"
    "</speciesReference>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3);
  sr->setDenominator(2);

  fail_unless( equals(expected,sr->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2v1_2)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = "<speciesReference species=\"s\" stoichiometry=\"3.2\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3.2);

  fail_unless( equals(expected,sr->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2v1_3)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<speciesReference species=\"s\">\n"
    "  <stoichiometryMath>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <divide/>\n"
    "        <cn type=\"integer\"> 1 </cn>\n"
    "        <ci> d </ci>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </stoichiometryMath>\n"
    "</speciesReference>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  ASTNode *math = SBML_parseFormula("1/d");
  StoichiometryMath *stoich = sr->createStoichiometryMath();
  stoich->setMath(math);
  sr->setStoichiometryMath(stoich);

  fail_unless( equals(expected,sr->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2v2_1)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<speciesReference sboTerm=\"SBO:0000009\" id=\"ss\" name=\"odd\" species=\"s\">\n"
    "  <stoichiometryMath>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"rational\"> 3 <sep/> 2 </cn>\n"
    "    </math>\n"
    "  </stoichiometryMath>\n"
    "</speciesReference>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3);
  sr->setDenominator(2);
  sr->setId("ss");
  sr->setName("odd");
  sr->setSBOTerm(9);

  sr->setId("ss");
  sr->setName("odd");
  sr->setSBOTerm(9);
  fail_unless( equals(expected,sr->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_SpeciesReference_L2v3_1)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<speciesReference sboTerm=\"SBO:0000009\" id=\"ss\" name=\"odd\" species=\"s\" stoichiometry=\"3.2\"/>";


  SpeciesReference *sr = D->createModel()->createReaction()->createReactant();
  sr->setSpecies("s");
  sr->setStoichiometry(3.2);
  sr->setId("ss");
  sr->setName("odd");
  sr->setSBOTerm(9);

  fail_unless( equals(expected,sr->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_StoichiometryMath)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<stoichiometryMath>\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <divide/>\n"
    "      <cn type=\"integer\"> 1 </cn>\n"
    "      <ci> d </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</stoichiometryMath>";

  ASTNode *math = SBML_parseFormula("1/d");
  StoichiometryMath* stoich = D->createModel()->createReaction()->createReactant()->createStoichiometryMath();
  stoich->setMath(math);

  fail_unless( equals(expected,stoich->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_StoichiometryMath_withSBO)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = 
  "<stoichiometryMath sboTerm=\"SBO:0000333\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <divide/>\n"
    "      <cn type=\"integer\"> 1 </cn>\n"
    "      <ci> d </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</stoichiometryMath>";

  ASTNode *math = SBML_parseFormula("1/d");
  StoichiometryMath* stoich = D->createModel()->createReaction()->createReactant()->createStoichiometryMath();
  stoich->setMath(math);
  stoich->setSBOTerm(333);

  fail_unless( equals(expected,stoich->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_KineticLaw)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<kineticLaw formula=\"k * e\" timeUnits=\"second\" "
    "substanceUnits=\"item\"/>";


  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();
  kl->setFormula("k * e");
  kl->setTimeUnits("second");
  kl->setSubstanceUnits("item");

  fail_unless( equals(expected,kl->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_KineticLaw_skipOptional)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = "<kineticLaw formula=\"k * e\"/>";


  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();
  kl->setFormula("k * e");

  fail_unless( equals(expected,kl->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_KineticLaw_ListOfParameters)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = 
    "<kineticLaw formula=\"nk * e\" timeUnits=\"second\" "
    "substanceUnits=\"item\">\n"
    "  <listOfParameters>\n"
    "    <parameter name=\"n\" value=\"1.2\"/>\n"
    "  </listOfParameters>\n"
    "</kineticLaw>";

  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();
  kl->setFormula("nk * e");
  kl->setTimeUnits("second");
  kl->setSubstanceUnits("item");

  Parameter *p = kl->createParameter();
  p->setName("n");
  p->setValue(1.2);

  fail_unless( equals(expected,kl->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_KineticLaw_l2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = 
    "<kineticLaw timeUnits=\"second\" substanceUnits=\"item\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <divide/>\n"
    "      <apply>\n"
    "        <times/>\n"
    "        <ci> vm </ci>\n"
    "        <ci> s1 </ci>\n"
    "      </apply>\n"
    "      <apply>\n"
    "        <plus/>\n"
    "        <ci> km </ci>\n"
    "        <ci> s1 </ci>\n"
    "      </apply>\n"
    "    </apply>\n"
    "  </math>\n"
    "</kineticLaw>";


  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();
  kl->setTimeUnits("second");
  kl->setSubstanceUnits("item");
  kl->setFormula("(vm * s1)/(km + s1)");

  fail_unless( equals(expected,kl->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_KineticLaw_withSBO)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<kineticLaw sboTerm=\"SBO:0000001\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <divide/>\n"
    "      <apply>\n"
    "        <times/>\n"
    "        <ci> vm </ci>\n"
    "        <ci> s1 </ci>\n"
    "      </apply>\n"
    "      <apply>\n"
    "        <plus/>\n"
    "        <ci> km </ci>\n"
    "        <ci> s1 </ci>\n"
    "      </apply>\n"
    "    </apply>\n"
    "  </math>\n"
    "</kineticLaw>";


  KineticLaw *kl = D->createModel()->createReaction()->createKineticLaw();
  kl->setFormula("(vm * s1)/(km + s1)");
  kl->setSBOTerm(1);

  fail_unless( equals(expected,kl->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event)
{
  D->setLevelAndVersion(2, 1, false);
  const char* expected = "<event id=\"e\"/>";

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  
  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_L2v4_explicit_defaults)
{
  D->setLevelAndVersion(2, 1, false);
  const char* expected = "<event id=\"e\"/>";

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  
  fail_unless( equals(expected,e->toSBML()) );
  
  const char* expected1 = "<event id=\"e\"/>";

  e->setUseValuesFromTriggerTime(true);

  fail_unless( equals(expected1,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_WithSBO)
{
  D->setLevelAndVersion(2, 3, false);
  const char* expected = "<event sboTerm=\"SBO:0000076\" id=\"e\"/>";


  Event *e = D->createModel()->createEvent();
  e->setId("e");
  e->setSBOTerm(76);
  
  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_WithUseValuesFromTriggerTime)
{
  const char* expected = "<event id=\"e\" useValuesFromTriggerTime=\"false\"/>";
  D->setLevelAndVersion(2, 4, false);


  Event *e = D->createModel()->createEvent();
  e->setId("e");
  e->setUseValuesFromTriggerTime(false);
  
  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_trigger)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <trigger>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <leq/>\n"
    "        <ci> P1 </ci>\n"
    "        <ci> t </ci>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </trigger>\n"
    "</event>";
  D->setLevelAndVersion(2, 1, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node = SBML_parseFormula("leq(P1,t)");
  Trigger t(2, 1);
  t.setMath(node);
  e->setTrigger(&t);

  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_delay)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <delay>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"integer\"> 5 </cn>\n"
    "    </math>\n"
    "  </delay>\n"
    "</event>";
  D->setLevelAndVersion(2, 1, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node = SBML_parseFormula("5");
  Delay d(2, 1);
  d.setMath(node);
  e->setDelay(&d);

  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_delayWithSBO)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <delay sboTerm=\"SBO:0000064\">\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"integer\"> 5 </cn>\n"
    "    </math>\n"
    "  </delay>\n"
    "</event>";
  D->setLevelAndVersion(2, 3, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node = SBML_parseFormula("5");
  Delay d(2, 3);
  d.setMath(node);
  d.setSBOTerm(64);
  e->setDelay(&d);

  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_trigger_withSBO)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <trigger sboTerm=\"SBO:0000064\">\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <leq/>\n"
    "        <ci> P1 </ci>\n"
    "        <ci> t </ci>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </trigger>\n"
    "</event>";
  D->setLevelAndVersion(2, 3, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node = SBML_parseFormula("leq(P1,t)");
  Trigger t(2, 3);
  t.setMath(node);
  t.setSBOTerm(64);

  e->setTrigger(&t);
  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_both)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <trigger>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <leq/>\n"
    "        <ci> P1 </ci>\n"
    "        <ci> t </ci>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </trigger>\n"
    "  <delay>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <cn type=\"integer\"> 5 </cn>\n"
    "    </math>\n"
    "  </delay>\n"
    "</event>";
  D->setLevelAndVersion(2, 1, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node1 = SBML_parseFormula("leq(P1,t)");
  Trigger t(2, 1);
  t.setMath(node1);
  ASTNode *node = SBML_parseFormula("5");
  Delay d(2, 1);
  d.setMath(node);
  e->setDelay(&d);
  e->setTrigger(&t);

  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Event_full)
{
  const char* expected = 
    "<event id=\"e\">\n"
    "  <trigger>\n"
    "    <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "      <apply>\n"
    "        <leq/>\n"
    "        <ci> P1 </ci>\n"
    "        <ci> t </ci>\n"
    "      </apply>\n"
    "    </math>\n"
    "  </trigger>\n"
    "  <listOfEventAssignments>\n"
    "    <eventAssignment sboTerm=\"SBO:0000064\" variable=\"k2\">\n"
    "      <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "        <cn type=\"integer\"> 0 </cn>\n"
    "      </math>\n"
    "    </eventAssignment>\n"
    "  </listOfEventAssignments>\n"
    "</event>";
  D->setLevelAndVersion(2, 3, false);

  Event *e = D->createModel()->createEvent();
  e->setId("e");
  ASTNode *node = SBML_parseFormula("leq(P1,t)");
  Trigger t(2, 3);
  t.setMath(node);
  ASTNode *math = SBML_parseFormula("0");
  EventAssignment ea(2, 3);
  ea.setVariable("k2");
  ea.setMath(math);
  ea.setSBOTerm(64);

  e->setTrigger(&t);
  e->addEventAssignment( &ea );

  fail_unless( equals(expected,e->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentType)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<compartmentType id=\"ct\"/>";


  CompartmentType *ct = D->createModel()->createCompartmentType();
  ct->setId("ct");
  ct->setSBOTerm(4);
  
  fail_unless( equals(expected,ct->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_CompartmentType_withSBO)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<compartmentType sboTerm=\"SBO:0000004\" id=\"ct\"/>";


  CompartmentType *ct = D->createModel()->createCompartmentType();
  ct->setId("ct");
  ct->setSBOTerm(4);
  
  fail_unless( equals(expected,ct->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesType)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<speciesType id=\"st\"/>";


  SpeciesType *st = D->createModel()->createSpeciesType();
  fail_unless(st != NULL);

  st->setId("st");
  st->setSBOTerm(4);
  
  fail_unless( equals(expected,st->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_SpeciesType_withSBO)
{
  D->setLevelAndVersion(2, 3, false);

  const char* expected = "<speciesType sboTerm=\"SBO:0000004\" id=\"st\"/>";


  SpeciesType *st = D->createModel()->createSpeciesType();
  st->setId("st");
  st->setSBOTerm(4);
  
  fail_unless( equals(expected,st->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Constraint)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<constraint sboTerm=\"SBO:0000064\"/>";


  Constraint *ct = D->createModel()->createConstraint();
  ct->setSBOTerm(64);
  
  fail_unless( equals(expected,ct->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Constraint_math)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
    "<constraint>\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <leq/>\n"
    "      <ci> P1 </ci>\n"
    "      <ci> t </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</constraint>";

  Constraint *c = D->createModel()->createConstraint();
  ASTNode *node = SBML_parseFormula("leq(P1,t)");
  c->setMath(node);

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_Constraint_full)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = 
  "<constraint sboTerm=\"SBO:0000064\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <leq/>\n"
    "      <ci> P1 </ci>\n"
    "      <ci> t </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "  <message>\n"
    "    <p xmlns=\"http://www.w3.org/1999/xhtml\"> Species P1 is out of range </p>\n"
    "  </message>\n"
    "</constraint>";

  Constraint *c = D->createModel()->createConstraint();
  ASTNode *node = SBML_parseFormula("leq(P1,t)");
  c->setMath(node);
  c->setSBOTerm(64);

  const XMLNode *text = XMLNode::convertStringToXMLNode(" Species P1 is out of range ");
  XMLTriple triple = XMLTriple("p", "http://www.w3.org/1999/xhtml", "");
  XMLAttributes att = XMLAttributes();
  XMLNamespaces xmlns = XMLNamespaces();
  xmlns.add("http://www.w3.org/1999/xhtml");
  
  XMLNode *p = new XMLNode(triple, att, xmlns);
  p->addChild(*(text));
  
  XMLTriple triple1 = XMLTriple("message", "", "");
  XMLAttributes att1 = XMLAttributes();
  XMLNode *message = new XMLNode(triple1, att1);

  message->addChild(*(p));

  c->setMessage(message);

  fail_unless( equals(expected,c->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_InitialAssignment)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = "<initialAssignment sboTerm=\"SBO:0000064\" symbol=\"c\"/>";


  InitialAssignment *ia = D->createModel()->createInitialAssignment();
  ia->setSBOTerm(64);
  ia->setSymbol("c");
  
  fail_unless( equals(expected,ia->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_InitialAssignment_math)
{
  const char* expected = 
    "<initialAssignment symbol=\"c\">\n"
    "  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> a </ci>\n"
    "      <ci> b </ci>\n"
    "    </apply>\n"
    "  </math>\n"
    "</initialAssignment>";

  InitialAssignment *ia = D->createModel()->createInitialAssignment();
  ASTNode *node = SBML_parseFormula("a + b");
  ia->setMath(node);
  ia->setSymbol("c");

  fail_unless( equals(expected,ia->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_NaN)
{
  const char* expected = "<parameter id=\"p\" value=\"NaN\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_NaN());


  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_INF)
{
  const char* expected = "<parameter id=\"p\" value=\"INF\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_PosInf());

  fail_unless( equals(expected,p->toSBML()) );

}
END_TEST


START_TEST (test_WriteSBML_NegINF)
{
  const char* expected = "<parameter id=\"p\" value=\"-INF\"/>";


  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(util_NegInf());

  fail_unless( equals(expected,p->toSBML()) );
}
END_TEST


START_TEST (test_WriteSBML_locale)
{
  const char* expected = "<parameter id=\"p\" value=\"3.31\" constant=\"true\"/>";

  Parameter *p = D->createModel()->createParameter();
  p->setId("p");
  p->setValue(3.31);
  p->setConstant(true);


  setlocale(LC_NUMERIC, "de_DE");

  fail_unless( equals(expected,p->toSBML()) );

  setlocale(LC_NUMERIC, "C");
}
END_TEST


#ifdef USE_ZLIB
START_TEST (test_WriteSBML_gzip)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-2/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-2/delay.xml",
                        "../../../examples/sample-models/from-spec/level-2/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-2/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-2/events.xml",
                        "../../../examples/sample-models/from-spec/level-2/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-2/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-2/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-2/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-2/units.xml"
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

    fail_unless( strcmp(d->toSBML(), dg->toSBML()) == 0 );

    delete d;
    delete dg;
  }

}
END_TEST
#endif

#ifdef USE_BZ2
START_TEST (test_WriteSBML_bzip2)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-2/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-2/delay.xml",
                        "../../../examples/sample-models/from-spec/level-2/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-2/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-2/events.xml",
                        "../../../examples/sample-models/from-spec/level-2/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-2/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-2/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-2/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-2/units.xml"
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

    fail_unless( strcmp(d->toSBML(), dg->toSBML()) == 0 );

    delete d;
    delete dg;
  }
}
END_TEST
#endif

#ifdef USE_ZLIB
START_TEST (test_WriteSBML_zip)
{
  const unsigned int filenum = 12;
  const char* file[filenum] = {
                        "../../../examples/sample-models/from-spec/level-2/algebraicrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/assignmentrules.xml",
                        "../../../examples/sample-models/from-spec/level-2/boundarycondition.xml",
                        "../../../examples/sample-models/from-spec/level-2/delay.xml",
                        "../../../examples/sample-models/from-spec/level-2/dimerization.xml",
                        "../../../examples/sample-models/from-spec/level-2/enzymekinetics.xml",
                        "../../../examples/sample-models/from-spec/level-2/events.xml",
                        "../../../examples/sample-models/from-spec/level-2/functiondef.xml",
                        "../../../examples/sample-models/from-spec/level-2/multicomp.xml",
                        "../../../examples/sample-models/from-spec/level-2/overdetermined.xml",
                        "../../../examples/sample-models/from-spec/level-2/twodimensional.xml",
                        "../../../examples/sample-models/from-spec/level-2/units.xml"
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

    fail_unless( strcmp(d->toSBML(), dg->toSBML()) == 0 );

    delete d;
    delete dg;
  }
}
END_TEST
#endif

START_TEST (test_WriteSBML_elements_L1v2)
{
  D->setLevelAndVersion(1, 2, false);

  const char* expected = wrapSBML_L1v2(
    "  <model>\n"
    "    <listOfUnitDefinitions>\n"
    "      <unitDefinition/>\n"
    "    </listOfUnitDefinitions>\n"
    "    <listOfCompartments>\n"
    "      <compartment/>\n"
    "    </listOfCompartments>\n"
    "    <listOfSpecies>\n"
    "      <species initialAmount=\"0\"/>\n"
    "    </listOfSpecies>\n"
    "    <listOfParameters>\n"
    "      <parameter/>\n"
    "    </listOfParameters>\n"
    "    <listOfRules>\n"
    "      <algebraicRule/>\n"
    "    </listOfRules>\n"
    "    <listOfReactions>\n"
    "      <reaction/>\n"
    "    </listOfReactions>\n"
    "  </model>\n");

  Model * m = D->createModel();
  m->createUnitDefinition();
  m->createCompartment();
  m->createParameter();
  m->createAlgebraicRule();
  m->createReaction();
  m->createSpecies();

  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_elements_L2v1)
{
  D->setLevelAndVersion(2, 1, false);

  const char* expected = wrapSBML_L2v1(
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
    "    <listOfRules>\n"
    "      <algebraicRule/>\n"
    "    </listOfRules>\n"
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

  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_WriteSBML_elements_L2v2)
{
  D->setLevelAndVersion(2, 2, false);

  const char* expected = wrapSBML_L2v2(
    "  <model>\n"
    "    <listOfFunctionDefinitions>\n"
    "      <functionDefinition/>\n"
    "    </listOfFunctionDefinitions>\n"
    "    <listOfUnitDefinitions>\n"
    "      <unitDefinition/>\n"
    "    </listOfUnitDefinitions>\n"
    "    <listOfCompartmentTypes>\n"
    "      <compartmentType/>\n"
    "    </listOfCompartmentTypes>\n"
    "    <listOfSpeciesTypes>\n"
    "      <speciesType/>\n"
    "    </listOfSpeciesTypes>\n"
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
  m->createCompartmentType();
  m->createSpeciesType();
  m->createCompartment();
  m->createEvent();
  m->createParameter();
  m->createAlgebraicRule();
  m->createInitialAssignment();
  m->createConstraint();
  m->createReaction();
  m->createSpecies();

  S = writeSBMLToString(D);

  fail_unless( equals(expected, S) );
}
END_TEST


Suite *
create_suite_WriteSBML ()
{
  Suite *suite = suite_create("WriteSBML");
  TCase *tcase = tcase_create("WriteSBML");


  tcase_add_checked_fixture(tcase, WriteSBML_setup, WriteSBML_teardown);
 
  // create/setProgramName/setProgramVersion
  tcase_add_test( tcase, test_SBMLWriter_create );  
  tcase_add_test( tcase, test_SBMLWriter_setProgramName );  
  tcase_add_test( tcase, test_SBMLWriter_setProgramVersion );  

  // Basic writing capability
  tcase_add_test( tcase, test_WriteSBML_error );  

  // SBMLDocument
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_L1v1 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_L1v2 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_L2v1 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_L2v2 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_updateNamespace_1 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_updateNamespace_2 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_updateNamespace_3 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_updateNamespace_4 );
  tcase_add_test( tcase, test_WriteSBML_SBMLDocument_updateNamespace_5 );


  // Model
  tcase_add_test( tcase, test_WriteSBML_Model                   );
  tcase_add_test( tcase, test_WriteSBML_Model_skipOptional      );
  tcase_add_test( tcase, test_WriteSBML_Model_L2v1              );
  tcase_add_test( tcase, test_WriteSBML_Model_L2v1_skipOptional );
  tcase_add_test( tcase, test_WriteSBML_Model_L2v2              );

  // FunctionDefinition
  tcase_add_test( tcase, test_WriteSBML_FunctionDefinition );
  tcase_add_test( tcase, test_WriteSBML_FunctionDefinition_withSBO );

  // Unit
  tcase_add_test( tcase, test_WriteSBML_Unit          );
  tcase_add_test( tcase, test_WriteSBML_Unit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Unit_L1_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Unit_L2v1_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Unit_L2_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Unit_L2v1     );
  tcase_add_test( tcase, test_WriteSBML_Unit_l2v3     );

  // UnitDefinition
  tcase_add_test( tcase, test_WriteSBML_UnitDefinition           );
  tcase_add_test( tcase, test_WriteSBML_UnitDefinition_full      );  
  tcase_add_test( tcase, test_WriteSBML_UnitDefinition_L2v1      );
  tcase_add_test( tcase, test_WriteSBML_UnitDefinition_L2v1_full );

  // Compartment
  tcase_add_test( tcase, test_WriteSBML_Compartment                );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L1_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Compartment_unsetVolume    );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2v1           );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2v1_constant  );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2v1_unsetSize );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2v2_compartmentType  );
  tcase_add_test( tcase, test_WriteSBML_Compartment_L2v3_SBO  );

  // Species
  tcase_add_test( tcase, test_WriteSBML_Species                   );
  tcase_add_test( tcase, test_WriteSBML_Species_L1_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Species_L2_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Species_L1v1              );
  tcase_add_test( tcase, test_WriteSBML_Species_defaults          );
  tcase_add_test( tcase, test_WriteSBML_Species_skipOptional      );
  tcase_add_test( tcase, test_WriteSBML_Species_L2v1              );
  tcase_add_test( tcase, test_WriteSBML_Species_L2v1_skipOptional );
  tcase_add_test( tcase, test_WriteSBML_Species_L2v2              );
  tcase_add_test( tcase, test_WriteSBML_Species_L2v3              );

  // Parameter
  tcase_add_test( tcase, test_WriteSBML_Parameter                   );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L2_explicit_defaults );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L1v1_required     );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L1v2_skipOptional );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L2v1              );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L2v1_skipOptional );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L2v1_constant     );
  tcase_add_test( tcase, test_WriteSBML_Parameter_L2v2              );

  // AlgebraicRule
  tcase_add_test( tcase, test_WriteSBML_AlgebraicRule      );
  tcase_add_test( tcase, test_WriteSBML_AlgebraicRule_L2v1 );
  tcase_add_test( tcase, test_WriteSBML_AlgebraicRule_L2v2 );

  // SpeciesConcentrationRule
  tcase_add_test( tcase, test_WriteSBML_SpeciesConcentrationRule          );
  tcase_add_test( tcase, test_WriteSBML_SpeciesConcentrationRule_defaults );
  tcase_add_test( tcase, test_WriteSBML_SpeciesConcentrationRule_L1v1     );
  tcase_add_test( tcase, test_WriteSBML_SpeciesConcentrationRule_L2v1     );
  tcase_add_test( tcase, test_WriteSBML_SpeciesConcentrationRule_L2v2     );

  // CompartmentVolumeRule
  tcase_add_test( tcase, test_WriteSBML_CompartmentVolumeRule          );
  tcase_add_test( tcase, test_WriteSBML_CompartmentVolumeRule_defaults );
  tcase_add_test( tcase, test_WriteSBML_CompartmentVolumeRule_L2v1     );
  tcase_add_test( tcase, test_WriteSBML_CompartmentVolumeRule_L2v2     );

  // ParameterRule
  tcase_add_test( tcase, test_WriteSBML_ParameterRule          );
  tcase_add_test( tcase, test_WriteSBML_ParameterRule_defaults );
  tcase_add_test( tcase, test_WriteSBML_ParameterRule_L2v1     );
  tcase_add_test( tcase, test_WriteSBML_ParameterRule_L2v2     );

  // Reaction
  tcase_add_test( tcase, test_WriteSBML_Reaction           );
  tcase_add_test( tcase, test_WriteSBML_Reaction_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Reaction_L1_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Reaction_L2_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Reaction_full      );
  tcase_add_test( tcase, test_WriteSBML_Reaction_L2v1      );
  tcase_add_test( tcase, test_WriteSBML_Reaction_L2v1_full );
  tcase_add_test( tcase, test_WriteSBML_Reaction_L2v2      );

  // SpeciesReference

  tcase_add_test( tcase, test_WriteSBML_SpeciesReference          );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L1v1     );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_defaults );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L1_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2v1_1   );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2v1_2   );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2v1_3   );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2v2_1   );
  tcase_add_test( tcase, test_WriteSBML_SpeciesReference_L2v3_1   );

  // StoichiometryMath
  tcase_add_test( tcase, test_WriteSBML_StoichiometryMath   );
  tcase_add_test( tcase, test_WriteSBML_StoichiometryMath_withSBO   );

  // KineticLaw
  tcase_add_test( tcase, test_WriteSBML_KineticLaw                  );
  tcase_add_test( tcase, test_WriteSBML_KineticLaw_skipOptional     );
  tcase_add_test( tcase, test_WriteSBML_KineticLaw_ListOfParameters );
  tcase_add_test( tcase, test_WriteSBML_KineticLaw_l2v1                  );
  tcase_add_test( tcase, test_WriteSBML_KineticLaw_withSBO                  );

  // Event
  tcase_add_test( tcase, test_WriteSBML_Event         );
  tcase_add_test( tcase, test_WriteSBML_Event_L2v4_explicit_defaults  );
  tcase_add_test( tcase, test_WriteSBML_Event_WithSBO         );
  tcase_add_test( tcase, test_WriteSBML_Event_WithUseValuesFromTriggerTime         );
  tcase_add_test( tcase, test_WriteSBML_Event_trigger );
  tcase_add_test( tcase, test_WriteSBML_Event_trigger_withSBO );
  tcase_add_test( tcase, test_WriteSBML_Event_delay   );
  tcase_add_test( tcase, test_WriteSBML_Event_delayWithSBO   );
  tcase_add_test( tcase, test_WriteSBML_Event_both    );
  tcase_add_test( tcase, test_WriteSBML_Event_full    );

  //CompartmentType
  tcase_add_test( tcase, test_WriteSBML_CompartmentType    );
  tcase_add_test( tcase, test_WriteSBML_CompartmentType_withSBO    );

  //SpeciesType
  tcase_add_test( tcase, test_WriteSBML_SpeciesType    );
  tcase_add_test( tcase, test_WriteSBML_SpeciesType_withSBO    );

  //Constraint
  tcase_add_test( tcase, test_WriteSBML_Constraint    );
  tcase_add_test( tcase, test_WriteSBML_Constraint_math    );
  tcase_add_test( tcase, test_WriteSBML_Constraint_full    );

  //InitialAssignment
  tcase_add_test( tcase, test_WriteSBML_InitialAssignment    );
  tcase_add_test( tcase, test_WriteSBML_InitialAssignment_math    );

  // Miscellaneous
  tcase_add_test( tcase, test_WriteSBML_NaN     );
  tcase_add_test( tcase, test_WriteSBML_INF     );
  tcase_add_test( tcase, test_WriteSBML_NegINF  );
  tcase_add_test( tcase, test_WriteSBML_locale  );

  // Compressed SBML
#ifdef USE_ZLIB
  tcase_add_test( tcase, test_WriteSBML_gzip  );
  tcase_add_test( tcase, test_WriteSBML_zip  );
#endif
#ifdef USE_BZ2
  tcase_add_test( tcase, test_WriteSBML_bzip2  );
#endif

  tcase_add_test( tcase, test_WriteSBML_elements_L1v2  );
  tcase_add_test( tcase, test_WriteSBML_elements_L2v1  );
  tcase_add_test( tcase, test_WriteSBML_elements_L2v2  );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

